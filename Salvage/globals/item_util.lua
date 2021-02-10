-----------------------------------
-- Item Utilities
-- desc: Common functionality for Items
-----------------------------------
require("scripts/globals/magic")
require("scripts/globals/msg")
require("scripts/globals/status")
require("scripts/globals/weather")
require("scripts/globals/zone")
-----------------------------------
itemUtil = {}
-----------------------------------

function itemUtil.onSalvageItemCheck(target, effect, count)
    local statusEffect = target:getStatusEffect(effect)
    if (statusEffect) then
        local power = statusEffect:getPower()
        if bit.band(power, count) > 0 then
            return 0
        end
    end
    return 55
end

function itemUtil.onSalvageItemUse(target, effect, count, offset)
    local statusEffect = target:getStatusEffect(effect)
    local power = statusEffect:getPower()
    local newpower = bit.band(power, bit.bnot(count))
    local pet = target:getPet()

    target:delStatusEffectSilent(effect)
    if (newpower > 0) then
        local duration = math.floor(statusEffect:getTimeRemaining()/1000)
        target:addStatusEffectEx(effect, effect, newpower, 0, duration)
    end
    if pet ~= nil and effect == dsp.effect.DEBILITATION then
        pet:delStatusEffectSilent(effect)
        if (newpower > 0) then
            local duration = math.floor(statusEffect:getTimeRemaining()/1000)
            pet:addStatusEffectEx(effect, effect, newpower, 0, duration)
        end
    end
    target:messageText(target, zones[target:getZoneID()].text.CELL_OFFSET + offset)
end
