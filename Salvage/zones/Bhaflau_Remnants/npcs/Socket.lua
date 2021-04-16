-----------------------------------
-- Area: Bhaflau Remnants
-- NPC: Socket
-- 50% chance to spawn east or west upon opening door
-- Trade Slavage Cells to pop Flux Flan
-- Flux Flan drops 2x the Cells traded
-----------------------------------
local ID = require("scripts/zones/Bhaflau_Remnants/IDs")
require("scripts/globals/items")
-----------------------------------

function onTrade(player,npc,trade)
    local instance = npc:getInstance()
    local mob = instance:getEntity(bit.band(ID.mob[2].FLUX_FLAN, 0xFFF), dsp.objType.MOB)
    local COUNT = trade:getItemCount()
    local pos = npc:getPos()

    for i = dsp.items.INCUS_CELL, dsp.items.SPISSATUS_CELL do
        if COUNT <= 5 and trade:hasItemQty(i, COUNT) then
            mob:setSpawn(pos.x + math.random(-2, 2), pos.y, pos.z + math.random(-2, 2), 0)
            SpawnMob(ID.mob[2].FLUX_FLAN, instance):updateClaim(player)
            player:tradeComplete()
            mob:setLocalVar("Cell", i)
            mob:setLocalVar("Qnt", COUNT)
        end
    end
end
