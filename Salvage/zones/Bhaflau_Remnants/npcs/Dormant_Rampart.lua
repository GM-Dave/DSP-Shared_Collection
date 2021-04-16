-----------------------------------
-- NPC: Dormant Rampart
-----------------------------------
local ID = require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------

function onTrigger(player, npc)
    player:startEvent(3)
end

function onEventUpdate(player, csid, option)
end

function onEventFinish(player, csid, option, npc)
    local instance = player:getInstance()
    local stage = instance:getStage()
    local chars = instance:getChars()
    local progress = instance:getProgress()

    if csid == 3 and option == 1 then
        for _, players in ipairs(chars) do
            players:startCutscene(5)
            local pos = ID.pos[stage][progress].enter
            players:timer(3000, function(npc) players:setPos(pos[1], pos[2], pos[3], pos[4]) end)
        end
        npc:AnimationSub(0)
    elseif csid == 5 then
        npc:setStatus(dsp.status.INVISIBLE)
        if stage == 3 then
            if progress == 5 then
                instance:getEntity(bit.band(ID.mob[3].RAMPART, 0xFFF), dsp.objType.MOB):setSpawn(-340, -0.5, -515, 64)
                for value = 1, 6 do
                    instance:getEntity(bit.band(ID.mob[3].RAMPART + value, 0xFFF), dsp.objType.MOB):setSpawn(-340, -0.5, -518.5, 64)
                end
            end
        end
        SpawnMob(ID.mob[stage].RAMPART, instance)
    end
end
