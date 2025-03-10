-----------------------------------
-- A Taste for Meat
-----------------------------------
-- Log ID: 0, Quest ID: 100
-- Antreneau : !pos -71 -5 -39 232
-- Thierride : !pos -67 -5 -28 232
-----------------------------------
require("scripts/globals/npc_util")
require("scripts/globals/quests")
require("scripts/globals/titles")
require("scripts/globals/zone")
require("scripts/globals/interaction/quest")
-----------------------------------

local quest = Quest:new(SANDORIA, A_TASTE_FOR_MEAT)

quest.reward =
{
    fame = 30,
    gil = 150,
    title = dsp.title.RABBITER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE
        end,

        -- This entire quest is not flagged; however, the quest is accepted and
        -- completed in the same step (on trading 5 hare meat after progressing).
        [dsp.zone.PORT_SAN_DORIA] =
        {
            ['Antreneau'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 1 and
                        npcUtil.tradeHas(trade, dsp.items.SLICE_OF_HARE_MEAT)
                    then
                        return quest:progressEvent(531)
                    else
                        return quest:progressEvent(532)
                    end
                end,

                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 0 then
                        return quest:progressEvent(527)
                    else
                        return quest:progressEvent(525)
                    end
                end,
            },

            ['Thierride'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 1 and
                        npcUtil.tradeHasExactly(trade, {{dsp.items.SLICE_OF_HARE_MEAT, 5}})
                    then
                        return quest:progressEvent(528)
                    else
                        return quest:progressEvent(529)
                    end
                end,

                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 1 then
                        return quest:progressEvent(526)
                    end
                end,
            },

            onEventFinish =
            {
                [527] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,

                [528] = function(player, csid, option, npc)
                    quest:begin(player)
                    if quest:complete(player) then
                        player:confirmTrade()

                        -- This variable is set after quest has been cleared, and is cleaned
                        -- up after receiving Grilled Hare item from Antreneau.
                        quest:setVar(player, 'Option', 1)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == QUEST_COMPLETED
        end,

        [dsp.zone.PORT_SAN_DORIA] =
        {
            ['Antreneau'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Option') == 1 then
                        return quest:progressEvent(530)
                    end
                end,
            },

            ['Thierride'] = quest:event(524):replaceDefault(),

            onEventFinish =
            {
                [530] = function(player, csid, option, npc)
                    if npcUtil.giveItem(player, dsp.items.SLICE_OF_GRILLED_HARE) then
                        quest:setVar(player, 'Option', 0)
                    else
                        return quest:progressEvent(538)
                    end
                end,
            },
        },
    },
}

return quest
