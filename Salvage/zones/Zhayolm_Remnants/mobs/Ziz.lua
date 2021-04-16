-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Ziz
-----------------------------------
local ID = require("scripts/zones/Zhayolm_Remnants/IDs")
require("scripts/globals/status")
require("scripts/globals/utils/salvage")
-----------------------------------

function onMobDeath(mob, player, isKiller, firstCall)
    if firstCall then
        if salvageUtil.groupKilled(mob, ID.mob[1][1].STAGE_START.ZIZ) then
            local instance = mob:getInstance()
            SpawnMob(ID.mob[1].POROGGO_GENT_ZIZ, instance):setDropID(7305)
        end
        if math.random(1,1000) >= 960 then
            local params = {}
            salvageUtil.spawnTempChest(mob, params)
        end
    end
end
