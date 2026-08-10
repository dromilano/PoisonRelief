require "PoisonRelief/PoisonRelief_Treatment"
require "TimedActions/ISBaseTimedAction"

PoisonReliefTakeTabletAction = ISBaseTimedAction:derive(
    "PoisonReliefTakeTabletAction"
)

local function findTabletById(character, itemId)
    if not character or not itemId then return nil end

    local inventory = character:getInventory()
    return inventory:getItemById(itemId)
end

local function isUsableTablet(item)
    if not item or not PoisonRelief.TREATMENTS[item:getFullType()] then
        return false
    end

    return not item:IsDrainable() or item:getCurrentUsesFloat() > 0
end

function PoisonReliefTakeTabletAction:isValid()
    if self.didComplete or not self.character then return false end

    if isClient() then
        return isUsableTablet(findTabletById(
            self.character,
            self.itemId
        ))
    end

    return self.item
        and self.character:getInventory():contains(self.item)
        and isUsableTablet(self.item)
end

function PoisonReliefTakeTabletAction:update()
    self.item:setJobDelta(self:getJobDelta())
    self:setActionAnim(CharacterActionAnims.TakePills)
end

function PoisonReliefTakeTabletAction:start()
    if isClient() then
        self.item = findTabletById(self.character, self.itemId)
    end

    self.item:setJobType(getText(
        "ContextMenu_PoisonRelief_TakeTablet"
    ))
    self.item:setJobDelta(0.0)
    self:setOverrideHandModels(nil, self.item)
end

function PoisonReliefTakeTabletAction:stop()
    if self.item then self.item:setJobDelta(0.0) end
    if PoisonRelief.clearPendingTabletSource then
        PoisonRelief.clearPendingTabletSource(self.itemId)
    end
    ISBaseTimedAction.stop(self)
end

function PoisonReliefTakeTabletAction:perform()
    if self.item then self.item:setJobDelta(0.0) end
    ISBaseTimedAction.perform(self)
end

function PoisonReliefTakeTabletAction:complete()
    if self.didComplete or not self:isValid() then return false end

    if isClient() then
        self.item = findTabletById(self.character, self.itemId)
    end

    self.didComplete = true
    if self.character:isLocalPlayer()
        and PoisonRelief.completeTabletAction then
        PoisonRelief.completeTabletAction(self.item, self.playerNum)
    end
    return true
end

function PoisonReliefTakeTabletAction:new(character, item, playerNum)
    local action = ISBaseTimedAction.new(self, character)
    action.item = item
    action.itemId = item:getID()
    action.playerNum = playerNum
    action.didComplete = false
    action.stopOnWalk = true
    action.stopOnRun = true
    action.stopOnAim = true
    action.maxTime = character:isTimedActionInstant() and 1 or 80
    action.isEating = true
    return action
end
