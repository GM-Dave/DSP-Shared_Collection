-----------------------------------
--  MOB: Racing Chariot
-- Area: Nyzul Isle
-- Info: Specified Mob Group
-----------------------------------
mixins = {require("scripts/mixins/families/chariot")}
require("scripts/globals/utils/nyzul")
-----------------------------------

local this = {}

this.onMobDeath = function(mob, player, isKiller, firstCall)
    if firstCall then
        nyzul.spawnChest(mob, player)
        nyzul.specifiedGroupKill(mob)
    end
end

return this
