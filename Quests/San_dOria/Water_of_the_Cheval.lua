-----------------------------------
-- Water of the Cheval
-- Miageau !pos 115 0 108 231
-- Nouveil !pos 123 0 106 231
-- Cheval_River !pos 223 -58 426 101
-----------------------------------
require("scripts/globals/items")
require("scripts/globals/quests")
require('scripts/globals/interaction/quest')
require("scripts/globals/npc_util")
-----------------------------------

local quest = Quest:new(SANDORIA, WATER_OF_THE_CHEVAL)

quest.reward = {
    fame = 30,
    item = dsp.items.WING_PENDANT,
    title = dsp.title.THE_PURE_ONE,
}

quest.sections = {

    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE
        end,

        [dsp.zone.EAST_RONFAURE] = {
            ['Cheval_River'] = {
                onTrigger = function(player, npc)
                    return quest:messageSpecial(zones[player:getZoneID()].text.NOTHING_OUT_OF_ORDINARY)
                end,
            },
        },

        [dsp.zone.NORTHERN_SAN_DORIA] = {
            ['Nouveil'] = {
                onTrigger = function(player, npc)
                    return quest:event(574)
                end,
            },
            ['Miageau'] = {
                onTrigger = function(player, npc)
                    return quest:progressEvent(504)
                end,
            },

            onEventFinish = {
                [504] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == QUEST_ACCEPTED
        end,

        [dsp.zone.NORTHERN_SAN_DORIA] = {
            ['Miageau'] = {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, dsp.items.SKIN_OF_CHEVAL_RIVER_WATER) then
                       return quest:progressEvent(515)
                    end
                end,
                onTrigger = function(player, npc)
                    if player:hasItem(dsp.items.BLESSED_WATERSKIN) then
                        return quest:event(512)
                    else
                        return quest:event(519)
                    end
                end,
            },
            ['Nouveil'] = {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, {{"gil", 10}}) then
                        return quest:progressEvent(571)
                    end
                end,
                onTrigger = function(player, npc)
                    if player:hasItem(dsp.items.SKIN_OF_CHEVAL_RIVER_WATER) then
                        return quest:event(573)
                    elseif player:hasItem(dsp.items.BLESSED_WATERSKIN) then
                        return quest:event(572)
                    else
                        return quest:event(575)
                    end
                end,
            },

            onEventFinish = {
                [515] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,
                [571] = function(player, csid, option, npc)
                    player:delGil(10)
                    npcUtil.giveItem(player, dsp.items.BLESSED_WATERSKIN)
                end,
            },
        },
        [dsp.zone.EAST_RONFAURE] = {
            ['Cheval_River'] = {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, dsp.items.BLESSED_WATERSKIN) then
                        if npcUtil.giveItem(player, dsp.items.SKIN_OF_CHEVAL_RIVER_WATER) then
                            return player:confirmTrade()
                        end
                    end
                end,
                onTrigger = function(player, npc)
                    if player:hasItem(dsp.items.BLESSED_WATERSKIN) then
                        return quest:messageSpecial(zones[player:getZoneID()].text.BLESSED_WATERSKIN)
                    else
                        return quest:messageSpecial(zones[player:getZoneID()].text.NOTHING_OUT_OF_ORDINARY)
                    end
                end,
            },
        },
    },
    {
        check = function(player, status, vars)
            return status == QUEST_COMPLETED
        end,

        [dsp.zone.NORTHERN_SAN_DORIA] = {
            ['Miageau'] = {
                onTrigger = function(player, npc)
                    return quest:event(517)
                end,
            },
            ['Nouveil'] = {
                onTrigger = function(player, npc)
                    return quest:event(574)
                end,
            },
        },
        [dsp.zone.EAST_RONFAURE] = {
            ['Cheval_River'] = {
                onTrigger = function(player, npc)
                    return quest:messageSpecial(zones[player:getZoneID()].text.NOTHING_OUT_OF_ORDINARY)
                end,
            },
        },
    },
}

return quest
