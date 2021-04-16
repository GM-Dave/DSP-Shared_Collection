-----------------------------------
-- Area: Zhayolm Remnants
-- MOB: Vagrant Lindwurm
-----------------------------------
local ID = require("scripts/zones/Zhayolm_Remnants/IDs")
require("scripts/globals/status")
require("scripts/globals/utils/salvage")
-----------------------------------

function onMobDeath(mob, player, isKiller, firstCall)
    if firstCall then
        if salvageUtil.groupKilled(mob, ID.mob[1][1].STAGE_START.LINDWURM) then
            local instance = mob:getInstance()
            SpawnMob(ID.mob[1].POROGGO_GENT_LINDWURM, instance):setDropID(7304)
        end
        if math.random(1,1000) >= 960 then
            local params = {}
            salvageUtil.spawnTempChest(mob, params)
        end
    end
end
