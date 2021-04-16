-----------------------------------
-- NPC: Door
-- Area: Bhaflau Remnants
-- !st floor East entrance
-- Sets up mobs spawning, locks opposite side and unlocks exit to East wing
-- !pos 360 14 -500
-----------------------------------
local ID = require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/utils/salvage")
-----------------------------------

function onTrigger(player, npc)
    if npc:getLocalVar("unSealed") == 1 then
        player:startEvent(300)
    else
        player:messageSpecial(ID.text.DOOR_IS_SEALED)
    end
end

function onEventFinish(player, csid, option, npc)
    if csid == 300 and option == 1 then
        local random = math.random(100)
        salvageUtil.onDoorOpen(npc, 1, 1)
        salvageUtil.unsealDoors(npc, ID.npc[1].EAST_EXIT)
        salvageUtil.sealDoors(npc, ID.npc[1].WEST_ENTRANCE)
        salvageUtil.spawnStage(player)
        if random >= 50 then
            local instance = player:getInstance()
            if random >= 75 then
                instance:getEntity(bit.band(ID.mob[1].MAD_BOMBER, 0xFFF), dsp.objType.MOB):setSpawn(420, 16, -291, 62)
                instance:getEntity(bit.band(ID.npc[1].DORMANT, 0xFFF), dsp.objType.NPC):setPos(420, 16, -283, 62)
            else
                instance:getEntity(bit.band(ID.mob[1].MAD_BOMBER, 0xFFF), dsp.objType.MOB):setSpawn(450, 16, -460, 0)
                instance:getEntity(bit.band(ID.npc[1].DORMANT, 0xFFF), dsp.objType.NPC):setPos(443, 16, -460, 0)
            end
            SpawnMob(ID.mob[1].MAD_BOMBER, instance)
        end
    end
end
