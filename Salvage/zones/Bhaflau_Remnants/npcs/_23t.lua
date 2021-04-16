
-----------------------------------
-- NPC: Door
-- Area: Bhaflau Remnants
-- 4th Floor West to central area
-- !pos -360 -2 140, 17084918
-----------------------------------
local ID = require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/utils/salvage")
-----------------------------------

function onTrigger(player, npc)
    local instance = npc:getInstance()
    if instance:getProgress() == 1 then
        player:startEvent(300)
    else
        player:messageSpecial(ID.text.DOOR_IS_SEALED)
    end
end

function onEventFinish(player, csid, option, npc)
    if csid == 300 and option == 1 then
        salvageUtil.onDoorOpen(npc)
    end
end
