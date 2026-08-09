require "PoisonRelief/PoisonRelief_Treatment"

local function findTablet(items, player)
    for _, entry in ipairs(items) do
        local item = entry
        if type(entry) == "table" and entry.items then
            item = entry.items[1]
        end
        if item and item.getFullType then
            local itemType = item:getFullType()
            if PoisonRelief.TREATMENTS[itemType]
                and player:getInventory():containsRecursive(item) then
                return item
            end
        end
    end
    return nil
end

local function consumeTabletLocally(tablet, player)
    if not tablet or not player then return false end
    if not player:getInventory():containsRecursive(tablet) then return false end

    local container = tablet:getContainer()
    if not container then return false end

    if tablet:IsDrainable() then
        if tablet:getUsedDelta() <= 0 then return false end
        tablet:Use()
    else
        container:Remove(tablet)
    end

    return true
end

local function takeTablet(tablet, playerNum)
    local player = getSpecificPlayer(playerNum)
    if not player or not tablet then return end

    local itemType = tablet:getFullType()
    if not PoisonRelief.TREATMENTS[itemType] then return end

    if isClient() then
        sendClientCommand(
            player,
            PoisonRelief.NET_MODULE,
            PoisonRelief.NET_TAKE_TABLET,
            {
                itemId = tablet:getID(),
                itemType = itemType,
            }
        )
        return
    end

    -- Single-player keeps the immediate local path.
    if consumeTabletLocally(tablet, player) then
        PoisonRelief.startTreatment(player, itemType)
    end
end

local function findLocalPlayer(onlineID)
    local wantedID = tonumber(onlineID)
    for playerNum = 0, 3 do
        local player = getSpecificPlayer(playerNum)
        if player and (wantedID == nil or player:getOnlineID() == wantedID) then
            return player
        end
    end
    return nil
end

local function mirrorConsumedItem(player, args)
    local itemID = tonumber(args.itemId)
    if not itemID then return end

    local inventory = player:getInventory()
    local tablet = inventory:getItemById(itemID)
        or inventory:getItemWithIDRecursiv(itemID)
    if not tablet then return end

    if args.itemRemoved then
        local container = tablet:getContainer()
        if container then container:Remove(tablet) end
        return
    end

    local usedDelta = tonumber(args.usedDelta)
    if tablet:IsDrainable() and usedDelta then
        tablet:setUsedDelta(math.max(0, usedDelta))
    end
end

local function onServerCommand(module, command, args)
    if module ~= PoisonRelief.NET_MODULE or not args then return end

    local player = findLocalPlayer(args.onlineID)
    if not player then return end

    if command == PoisonRelief.NET_TREATMENT_STARTED then
        mirrorConsumedItem(player, args)
        PoisonRelief.setTreatmentState(player, args)
    elseif command == PoisonRelief.NET_TREATMENT_REJECTED then
        print("PoisonRelief: server rejected tablet request: "
            .. tostring(args.reason or "unknown reason"))
    end
end

local function addContextOption(playerNum, context, items)
    local player = getSpecificPlayer(playerNum)
    if not player then return end

    local tablet = findTablet(items, player)
    if not tablet then return end

    context:addOption(
        getText("ContextMenu_PoisonRelief_TakeTablet"),
        tablet,
        takeTablet,
        playerNum
    )
end

Events.OnServerCommand.Add(onServerCommand)
Events.OnFillInventoryObjectContextMenu.Add(addContextOption)
