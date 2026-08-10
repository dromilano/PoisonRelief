PoisonRelief = PoisonRelief or {}

PoisonRelief.MAX_BANKED_RELIEF = 70.0

PoisonRelief.TREATMENTS = {
    ["PoisonRelief.GastroCalmTablet"] = {
        immediateRelief = 10.0,
        progressiveRelief = 25.0,
        hours = 0.75,
    },
    ["PoisonRelief.CrudeHerbalTablet"] = {
        immediateRelief = 7.0,
        progressiveRelief = 15.0,
        hours = 1.0,
    },
}

PoisonRelief.NET_MODULE = "PoisonRelief"
PoisonRelief.NET_TAKE_TABLET = "TakeTablet"
PoisonRelief.NET_TREATMENT_STARTED = "TreatmentStarted"
PoisonRelief.NET_TREATMENT_REJECTED = "TreatmentRejected"

local KEY_REMAINING = "PoisonRelief_remaining"
local KEY_RATE = "PoisonRelief_ratePerHour"
local KEY_LAST_HOUR = "PoisonRelief_lastHour"
local LEGACY_KEY_END_HOUR = "PoisonRelief_endHour"

local function clearTreatment(data)
    data[KEY_REMAINING] = nil
    data[KEY_RATE] = nil
    data[KEY_LAST_HOUR] = nil
    data[LEGACY_KEY_END_HOUR] = nil
end

local function applyRelief(player, relief)
    local stats = player and player:getStats()
    if not stats then return false end

    local foodSickness = stats:get(CharacterStat.FOOD_SICKNESS)
    local poison = stats:get(CharacterStat.POISON)

    stats:set(
        CharacterStat.FOOD_SICKNESS,
        math.max(0, foodSickness - relief)
    )
    stats:set(CharacterStat.POISON, math.max(0, poison - relief))
    return true
end

function PoisonRelief.getTreatmentState(player)
    if not player then return nil end

    local data = player:getModData()
    local remaining = tonumber(data[KEY_REMAINING]) or 0
    local rate = tonumber(data[KEY_RATE]) or 0

    if remaining <= 0 or rate <= 0 then return nil end

    return {
        remaining = remaining,
        rate = rate,
        lastHour = tonumber(data[KEY_LAST_HOUR])
            or getGameTime():getWorldAgeHours(),
    }
end

function PoisonRelief.setTreatmentState(player, state)
    if not player or not state then return false end

    local remaining = tonumber(state.remaining) or 0
    local rate = tonumber(state.rate) or 0
    local data = player:getModData()

    if remaining <= 0 or rate <= 0 then
        clearTreatment(data)
        return false
    end

    data[KEY_REMAINING] = math.min(
        PoisonRelief.MAX_BANKED_RELIEF,
        remaining
    )
    data[KEY_RATE] = rate
    data[KEY_LAST_HOUR] = tonumber(state.lastHour)
        or getGameTime():getWorldAgeHours()
    data[LEGACY_KEY_END_HOUR] = nil
    return true
end

function PoisonRelief.updateTreatment(player)
    if not player then return false, false end

    local data = player:getModData()
    local remaining = tonumber(data[KEY_REMAINING]) or 0
    if remaining <= 0 then return false, false end

    local now = getGameTime():getWorldAgeHours()
    local lastHour = tonumber(data[KEY_LAST_HOUR]) or now
    local rate = tonumber(data[KEY_RATE]) or 0

    -- Continue old in-progress treatments after updating the mod.
    if rate <= 0 then
        local legacyEndHour = tonumber(data[LEGACY_KEY_END_HOUR]) or now
        rate = remaining / math.max(0.001, legacyEndHour - lastHour)
        data[KEY_RATE] = rate
    end

    local elapsed = math.max(0, now - lastHour)
    if elapsed <= 0 then return false, false end

    local relief = math.min(remaining, rate * elapsed)
    if not applyRelief(player, relief) then return false, false end

    data[KEY_REMAINING] = math.max(0, remaining - relief)
    data[KEY_LAST_HOUR] = now

    local finished = data[KEY_REMAINING] <= 0
    if finished then
        clearTreatment(data)
    end

    return relief > 0, finished
end

function PoisonRelief.startTreatment(player, itemType)
    if not player then return nil end

    local treatment = PoisonRelief.TREATMENTS[itemType]
    if not treatment then return nil end

    -- Bank any relief earned since the previous update before adding a dose.
    PoisonRelief.updateTreatment(player)

    -- This function is called only after a tablet was successfully consumed.
    if not applyRelief(player, treatment.immediateRelief) then return nil end

    local now = getGameTime():getWorldAgeHours()
    local data = player:getModData()
    local remaining = tonumber(data[KEY_REMAINING]) or 0
    local currentRate = tonumber(data[KEY_RATE]) or 0

    data[KEY_REMAINING] = math.min(
        PoisonRelief.MAX_BANKED_RELIEF,
        remaining + treatment.progressiveRelief
    )
    data[KEY_RATE] = math.max(
        currentRate,
        treatment.progressiveRelief / treatment.hours
    )
    data[KEY_LAST_HOUR] = now
    data[LEGACY_KEY_END_HOUR] = nil

    return PoisonRelief.getTreatmentState(player)
end

local function onPlayerUpdate(player)
    -- Single-player and MP clients update the local sickness display here.
    -- Dedicated/listen servers advance authoritative state once per game minute.
    if isServer() then return end
    if isClient() and not player:isLocalPlayer() then return end

    PoisonRelief.updateTreatment(player)
end

Events.OnPlayerUpdate.Add(onPlayerUpdate)
