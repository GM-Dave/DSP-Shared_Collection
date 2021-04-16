-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Poroggo Gent
-----------------------------------
local ID = require("scripts/zones/Zhayolm_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------

function onMobDeath(mob, player, isKiller, firstCall)
    if firstCall then
        local instance = mob:getInstance()
        if instance:getStage() == 1 then
            instance:setProgress(2)
            if noCellUsage(player) then
                SpawnMob(ID.mob[1].POROGGO_MADAME, instance)
            end
        end
        if math.random(1,1000) >= 960 then
            local params = {}
            salvageUtil.spawnTempChest(mob, params)
        end
    end
end

function noCellUsage(player)
    local instance = player:getInstance()
    local Chars = instance:getChars()
    local effects =
    {
        {power = 0xFFFF, effect = dsp.effect.ENCUMBRANCE_I},
        {power =      1, effect = dsp.effect.OBLIVISCENCE},
        {power =   0x3F, effect = dsp.effect.OMERTA},
        {power =      3, effect = dsp.effect.IMPAIRMENT},
        {power =  0x1FF, effect = dsp.effect.DEBILITATION}
    }

    if instance:getLocalVar("allySize") ~= #Chars then
        return false
    end

    for i, players in pairs(Chars) do
        if players:getHP() == 0 then
            return false
        end
        for i, statusEffect in pairs(effects) do
            if players:hasStatusEffect(statusEffect.effect) then
                if players:getStatusEffect(statusEffect.effect):getPower() ~= statusEffect.power then
                    return false
                end
            else
                return false
            end
        end
        return true
    end
end
