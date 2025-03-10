-----------------------------------
-- Keeping Notes
-- Ahkk Jharcham, Whitegate , !pos 0.1 -1 -76 50
-----------------------------------
require("scripts/globals/items")
require("scripts/globals/quests")
require("scripts/globals/npc_util")
require('scripts/globals/interaction/quest')
-----------------------------------

local quest = Quest:new(AHT_URHGAN, KEEPING_NOTES)

quest.sections = {

    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE
        end,

        [dsp.zone.AHT_URHGAN_WHITEGATE] = {
            ['Ahkk_Jharcham'] = {
                onTrigger = function(player, npc)
                    return quest:progressEvent(9)
                end,
            },

            onEventFinish = {
                [9] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == QUEST_ACCEPTED
        end,

        [dsp.zone.AHT_URHGAN_WHITEGATE] = {
            ['Ahkk_Jharcham'] = {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10)
                end,
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, {dsp.items.SHEET_OF_PARCHMENT, dsp.items.JAR_OF_BLACK_INK}) then
                        return quest:progressEvent(11)
                    else
                        return quest:event(14)
                    end
                end,
            },

            onEventFinish = {
                [11] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:moghouseFlag(16)
                    quest:complete(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == QUEST_COMPLETED
        end,

        [dsp.zone.AHT_URHGAN_WHITEGATE] = {
            ['Ahkk_Jharcham'] = {
                onTrigger = function(player, npc)
                    return quest:event(12)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, dsp.items.SHEET_OF_PARCHMENT) then
                        return quest:event(13)
                    else
                        return quest:event(14)
                    end
                end,
            },
        },
    },
}

return quest
