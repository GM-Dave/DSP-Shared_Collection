-----------------------------------
-- Equipped for All Occasions
-- Corsair AF1 Quest
-----------------------------------
-- Log ID: 6, Quest ID: 24
-- qm6 (H-10/Boat)  : !pos 468.767 -12.292 111.817 54
-- _5i0 (Iron Door) : !pos 247.735 18.499 -142.267 198
-- Ratihb           : !pos 75.225 -6.000 -137.203 50
-----------------------------------
require("scripts/globals/items")
require("scripts/globals/npc_util")
require("scripts/globals/quests")
require('scripts/globals/interaction/quest')
-----------------------------------
local mazeID = require("scripts/zones/Maze_of_Shakhrami/IDs")
-----------------------------------

local quest = Quest:new(AHT_URHGAN, EQUIPPED_FOR_ALL_OCCASIONS)

quest.reward =
{
    item  = dsp.items.TRUMP_GUN,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE and
                quest:getVar(player, 'Stage') == 1 and
                player:getMainJob() == dsp.job.COR and
                player:getMainLvl() >= 40
        end,

        [dsp.zone.ARRAPAGO_REEF] =
        {
            ['qm6'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressCutscene(228)
                end,
            },

            onEventFinish =
            {
                [228] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Prog', 1)
                    quest:setVar(player, 'Stage', 0)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == QUEST_ACCEPTED
        end,

        [dsp.zone.MAZE_OF_SHAKHRAMI] =
        {
            ['_5i0'] =
            {
                onTrigger = function(player, npc)
                    local questProgress = quest:getVar(player, 'Prog')

                    if questProgress == 1 then
                        npcUtil.popFromQM(player, npc, mazeID.mob.LOST_SOUL, {hide = 0})
                    elseif questProgress == 2 then
                        return quest:progressCutscene(66)
                    end
                end,
            },

            ['Lost_Soul'] =
            {
                onMobDeath = function(mob, player, isKiller, noKiller)
                    if quest:getVar(player, 'Prog') == 1 then
                        quest:setVar(player, 'Prog', 2)
                    end
                end,
            },

            onEventFinish =
            {
                [66] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, dsp.ki.WHEEL_LOCK_TRIGGER)
                    quest:setVar(player, 'Prog', 3)
                end,
            },
        },

        [dsp.zone.ARRAPAGO_REEF] =
        {
            ['qm6'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 3 then
                        return quest:progressEvent(231)
                    end
                end,
            },

            onEventFinish =
            {
                [231] = function(player, csid, option, npc)
                    player:delKeyItem(dsp.ki.WHEEL_LOCK_TRIGGER)
                    quest:setVar(player, 'Prog', 4)
                end,
            },
        },

        [dsp.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Ratihb'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 4 then
                        return quest:progressEvent(772)
                    end
                end,
            },

            onEventFinish =
            {
                [772] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
