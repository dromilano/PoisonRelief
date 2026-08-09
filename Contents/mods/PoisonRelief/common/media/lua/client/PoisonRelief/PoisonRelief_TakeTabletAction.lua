require "TimedActions/ISBaseTimedAction"

PoisonReliefTakeTabletAction = ISBaseTimedAction:derive(
    "PoisonReliefTakeTabletAction"
)

function PoisonReliefTakeTabletAction:isValid()
    if self.didComplete or not self.item or not self.character then
        return false
    end

    if not self.character:getInventory():containsRecursive(self.item) then
        return false
    end

    if not PoisonRelief.TREATMENTS[self.item:getFullType()] then
        return false
    end

    return not self.item:IsDrainable() or self.item:getUsedDelta() > 0
end

function PoisonReliefTakeTabletAction:update()
    self.item:setJobDelta(self:getJobDelta())
    self:setActionAnim(CharacterActionAnims.TakePills)
end

function PoisonReliefTakeTabletAction:start()
    self.item:setJobType(getText(
        "ContextMenu_PoisonRelief_TakeTablet"
    ))
    self.item:setJobDelta(0.0)
    self:setOverrideHandModels(nil, self.item)
end

function PoisonReliefTakeTabletAction:stop()
    self.item:setJobDelta(0.0)
    ISBaseTimedAction.stop(self)
end

function PoisonReliefTakeTabletAction:perform()
    self.item:setJobDelta(0.0)
    ISBaseTimedAction.perform(self)
end

function PoisonReliefTakeTabletAction:complete()
    if self.didComplete or not self:isValid() then
        return false
    end

    self.didComplete = true
    self.onComplete(self.item, self.playerNum)
    return true
end

function PoisonReliefTakeTabletAction:new(
    character,
    item,
    playerNum,
    onComplete
)
    local action = ISBaseTimedAction.new(self, character)
    action.item = item
    action.playerNum = playerNum
    action.onComplete = onComplete
    action.didComplete = false
    action.stopOnWalk = true
    action.stopOnRun = true
    action.stopOnAim = true
    action.maxTime = character:isTimedActionInstant() and 1 or 80
    action.isEating = true
    return action
end
