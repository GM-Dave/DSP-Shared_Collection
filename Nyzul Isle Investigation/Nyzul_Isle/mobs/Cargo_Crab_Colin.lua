-----------------------------------
--  MOB: Cargo Crab Colin
-- Area: Nyzul Isle
-- Info: NM
-----------------------------------
require("scripts/globals/utils/nyzul")
require("scripts/globals/status")
require("scripts/globals/additional_effects")
-----------------------------------

local this = {}

this.onMobInitialize = function(mob)
    mob:setMobMod(dsp.mobMod.ADD_EFFECT, 1)
    mob:addImmunity(dsp.immunity.SLEEP)
    mob:addImmunity(dsp.immunity.BIND)
    mob:addImmunity(dsp.immunity.POISON)
end

this.onAdditionalEffect = function(mob, player)
    -- poison tick and duration unverified
    return effectUtil.mobOnAddEffect(mob, player, damage, effectUtil.mobAdditionalEffect.POISON, {chance = 40, tick = 3, duration = 15})
end

this.onMobDeath = function(mob, player, isKiller, firstCall)
    if firstCall then
        nyzul.spawnChest(mob, player)
        nyzul.eliminateAllKill(mob)
    end
end

return this
