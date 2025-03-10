-----------------------------------
-- Black Tiger Skins
-----------------------------------
-- Log ID: 0, Quest ID: 31
-- Hanaa Punaa : !pos -179.726 -8.8 27.574 230
-----------------------------------
require("scripts/globals/npc_util")
require("scripts/globals/quests")
require("scripts/globals/status")
require("scripts/globals/titles")
require("scripts/globals/zone")
require("scripts/globals/interaction/quest")
-----------------------------------

local quest = Quest:new(SANDORIA, BLACK_TIGER_SKINS)

quest.reward =
{
    fame = 30,
    item = dsp.items.TIGER_STOLE,
    itemParams = { fromTrade = true },
    title = dsp.title.CAT_SKINNER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE and
                player:getFameLevel(SANDORIA) >= 3 and
                player:hasCompletedQuest(SANDORIA, LIZARD_SKINS)
        end,

        [dsp.zone.SOUTHERN_SAN_DORIA] = {
            ['Hanaa_Punaa'] =
            {
                onTrigger = function(player, npc)
                    local questProgress = quest:getVar(player, 'Prog')

                    if questProgress == 0 then
                        return quest:progressEvent(576)
                    elseif questProgress == 1 then
                        return quest:progressEvent(579)
                    end
                end,
            },

            onEventFinish =
            {
                [576] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    else
                        quest:setVar(player, 'Prog', 1)
                    end
                end,

                [579] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == QUEST_ACCEPTED
        end,

        [dsp.zone.SOUTHERN_SAN_DORIA] = {
            ['Hanaa_Punaa'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, {{ dsp.items.BLACK_TIGER_HIDE, 3 }}) then
                        return quest:progressEvent(577)
                    end
                end,

                onTrigger = quest:progressEvent(578),
            },

            onEventFinish =
            {
                [577] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == QUEST_COMPLETED and player:getFameLevel(SANDORIA) >= 3
        end,

        [dsp.zone.SOUTHERN_SAN_DORIA] = {
            ['Hanaa_Punaa'] = quest:event(592):replaceDefault()
        },
    },
}

return quest
