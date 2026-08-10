require "PoisonRelief/PoisonRelief_Treatment"

local function sendRejection(player, reason)
    sendServerCommand(
        player,
        PoisonRelief.NET_MODULE,
        PoisonRelief.NET_TREATMENT_REJECTED,
        {
            onlineID = player:getOnlineID(),
            reason = reason,
        }
    )
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
        return nil, "tablet is not in the player's inventory"
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
    local currentUses = nil

    if tablet:IsDrainable() then
        tablet:Use()
        itemRemoved = tablet:getContainer() == nil
        currentUses = itemRemoved and 0 or tablet:getCurrentUsesFloat()
        if not itemRemoved then sendItemStats(tablet) end
    else
        container:Remove(tablet)
        itemRemoved = true
    end

    return {
        itemId = itemID,
        itemRemoved = itemRemoved,
        currentUses = currentUses,
    }
end

local function handleTakeTablet(player, args)
    local tablet, reason = findRequestedTablet(player, args)
    if not tablet then
        sendRejection(player, reason)
        return
    end

    local itemType = tablet:getFullType()
    local consumed = consumeTablet(tablet)
    if not consumed then
        sendRejection(player, "tablet could not be consumed")
        return
    end

    local state = PoisonRelief.startTreatment(player, itemType)
    if not state then
        sendRejection(player, "treatment could not be started")
        return
    end

    sendPlayerEffects(player)
    player:transmitModData()
    sendServerCommand(
        player,
        PoisonRelief.NET_MODULE,
        PoisonRelief.NET_TREATMENT_STARTED,
        {
            onlineID = player:getOnlineID(),
            itemId = consumed.itemId,
            itemRemoved = consumed.itemRemoved,
            currentUses = consumed.currentUses,
            remaining = state.remaining,
            rate = state.rate,
            lastHour = state.lastHour,
        }
    )
end

local function onClientCommand(module, command, player, args)
    if module ~= PoisonRelief.NET_MODULE then return end
    if command == PoisonRelief.NET_TAKE_TABLET then
        handleTakeTablet(player, args)
    end
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
