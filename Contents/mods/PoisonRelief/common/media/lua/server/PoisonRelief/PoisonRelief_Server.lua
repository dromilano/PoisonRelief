require "PoisonRelief/PoisonRelief_Treatment"

local processedRequests = {}
local MAX_REQUESTS_PER_PLAYER = 64

local function requestDetails(args)
    return "request=" .. tostring(args and args.requestId)
        .. " item=" .. tostring(args and args.itemId)
        .. " type=" .. tostring(args and args.itemType)
end

local function sendResponse(player, command, response)
    sendServerCommand(
        player,
        PoisonRelief.NET_MODULE,
        command,
        response
    )
end

local function rejectionResponse(player, args, reason)
    local response = {
        onlineID = player:getOnlineID(),
        requestId = tostring(args and args.requestId or ""),
        itemId = tonumber(args and args.itemId),
        itemType = tostring(args and args.itemType or ""),
        reason = reason,
    }
    print("PoisonRelief: rejected " .. requestDetails(args)
        .. " reason=" .. tostring(reason))
    return PoisonRelief.NET_TREATMENT_REJECTED, response
end

local function findRequestedTablet(player, args)
    if not player or not args then return nil, "missing request data" end

    local itemID = tonumber(args.itemId)
    local requestedType = tostring(args.itemType or "")
    if not itemID or not PoisonRelief.TREATMENTS[requestedType] then
        return nil, "invalid tablet"
    end

    local inventory = player:getInventory()
    local tablet = inventory:getItemById(itemID)

    if not tablet or not inventory:contains(tablet) then
        return nil, "tablet is not in the player's main inventory"
    end
    if tablet:getFullType() ~= requestedType then
        return nil, "tablet type does not match"
    end
    if tablet:IsDrainable() and tablet:getCurrentUsesFloat() <= 0 then
        return nil, "tablet blister is empty"
    end

    return tablet, nil
end

local function consumeTablet(tablet)
    local container = tablet:getContainer()
    if not container then return nil end

    local itemID = tablet:getID()
    local itemRemoved = false
    local usedDelta = nil

    if tablet:IsDrainable() then
        tablet:Use()
        itemRemoved = tablet:getContainer() == nil
        usedDelta = itemRemoved and 0 or tablet:getCurrentUsesFloat()
        if not itemRemoved then sendItemStats(tablet) end
    else
        container:Remove(tablet)
        sendRemoveItemFromContainer(container, tablet)
        itemRemoved = true
    end

    return {
        itemId = itemID,
        itemRemoved = itemRemoved,
        usedDelta = usedDelta,
    }
end

local function handleTakeTablet(player, args)
    local tablet, reason = findRequestedTablet(player, args)
    if not tablet then return rejectionResponse(player, args, reason) end

    local itemType = tablet:getFullType()
    local consumed = consumeTablet(tablet)
    if not consumed then
        return rejectionResponse(player, args, "tablet could not be consumed")
    end

    local state = PoisonRelief.startTreatment(player, itemType)
    if not state then
        return rejectionResponse(player, args, "treatment could not be started")
    end

    local stats = player:getStats()
    sendPlayerEffects(player)
    player:transmitModData()

    return PoisonRelief.NET_TREATMENT_STARTED, {
        onlineID = player:getOnlineID(),
        requestId = tostring(args.requestId),
        itemId = consumed.itemId,
        itemType = itemType,
        itemRemoved = consumed.itemRemoved,
        usedDelta = consumed.usedDelta,
        foodSickness = stats:get(CharacterStat.FOOD_SICKNESS),
        poison = stats:get(CharacterStat.POISON),
        remaining = state.remaining,
        rate = state.rate,
        lastHour = state.lastHour,
    }
end

local function getPlayerRequests(player)
    local onlineID = player:getOnlineID()
    local requests = processedRequests[onlineID]
    if requests then return requests end

    requests = { responses = {}, order = {} }
    processedRequests[onlineID] = requests
    return requests
end

local function rememberResponse(requests, requestId, command, response)
    requests.responses[requestId] = {
        command = command,
        response = response,
    }
    table.insert(requests.order, requestId)

    if #requests.order > MAX_REQUESTS_PER_PLAYER then
        local expired = table.remove(requests.order, 1)
        requests.responses[expired] = nil
    end
end

local function onClientCommand(module, command, player, args)
    if module ~= PoisonRelief.NET_MODULE then return end
    if command ~= PoisonRelief.NET_TAKE_TABLET then return end

    local requestId = tostring(args and args.requestId or "")
    print("PoisonRelief: received " .. requestDetails(args))
    if requestId == "" then
        local responseCommand, response = rejectionResponse(
            player,
            args,
            "missing request ID"
        )
        sendResponse(player, responseCommand, response)
        return
    end

    local requests = getPlayerRequests(player)
    local previous = requests.responses[requestId]
    if previous then
        sendResponse(player, previous.command, previous.response)
        return
    end

    local responseCommand, response = handleTakeTablet(player, args)
    rememberResponse(requests, requestId, responseCommand, response)
    sendResponse(player, responseCommand, response)
end

local function updateServerTreatments()
    if not isServer() then return end

    local players = getOnlinePlayers()
    for index = 0, players:size() - 1 do
        local player = players:get(index)
        local changed, finished = PoisonRelief.updateTreatment(player)
        if changed and finished then
            player:transmitModData()
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)
Events.EveryOneMinute.Add(updateServerTreatments)
