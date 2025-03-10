-----------------------------------
-- Regaining Trust
-- [3][82]
-- Luto Mewrilah !pos -53 0 45 244
-- Neptune's spire door (_6td) !pos 20 -1.5 -4
-- Mirror Pond !pos 251 1 219 111
-- Fellow Emotes do not currently work
-----------------------------------
require('scripts/globals/items')
require('scripts/globals/keyitems')
require("scripts/globals/pets/fellow")
require('scripts/globals/quests')
require('scripts/globals/interaction/quest')
require('scripts/globals/npc_util')
require('scripts/globals/status')
-----------------------------------


local quest = Quest:new(JEUNO, BLESSED_RADIANCE)

quest.reward = {}

quest.sections = {

    -- Section: Begin quest
    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE
                and player:getQuestStatus(JEUNO, BLIGHTED_GLOOM) == QUEST_COMPLETED
                and player:getFellowValue("bond") >= 65
        end,

        [dsp.zone.UPPER_JEUNO] = {
            ['Luto_Mewrilah'] = {
                onTrigger = function(player, npc)
                    local fellowParam = getFellowParam(player)
                    return quest:progressEvent(10071, {[3] = 6})
                end,
            },
        },

        [dsp.zone.LOWER_JEUNO] = {
            ['_6td'] = {
                onTrigger = function(player, npc)
                    local fellowParam = getFellowParam(player)
                    return quest:progressEvent(10049, {[7] = fellowParam})
                end,
            },

            onEventFinish = {
                [10049] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                    quest:begin(player)
                end,

                [10050] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                end,
            },
        },
    },


    -- Section: Questing
    {
        check = function(player, status, vars)
            return status == QUEST_ACCEPTED
        end,

        [dsp.zone.LOWER_JEUNO] = {
            ['_6td'] = {
                onTrigger = function(player, npc)
                    local fellowParam = getFellowParam(player)
                    if quest:getVar(player, "Prog") == 3 then
                        return quest:progressEvent(10050, {[7] = fellowParam})
                    else
                        return quest:messageSpecial(zones[player:getZoneID()].text.DO_NOT_DISTURB)
                    end
                end,
            },

            onEventFinish = {
                [10050] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                end,
            },
        },

        [dsp.zone.UPPER_JEUNO] = {
            ['Luto_Mewrilah'] = {
                onTrigger = function(player, npc)
                    if quest:getVar(player, "Prog") == 4 then
                        local fellowParam = getFellowParam(player)
                        return quest:progressEvent(10073, {[7] = fellowParam})
                    else
                        return quest:event(10071, {[3] = 7})
                    end
                end,
            },

            onEventFinish = {
                [10073] = function(player, csid, option, npc)
                    player:setFellowValue("bondcap", 90)
                    quest:complete(player)
                end,
            },
        },

        [dsp.zone.GIDDEUS] = {
            ['Harvesting_Point'] = {
                onTrade = function(player, npc, trade)
                    if quest:getVar(player, "Prog") == 1 and not player:hasKeyItem(dsp.keyItem.MISTROOT) and npcUtil.tradeHasExactly(trade, dsp.items.SICKLE) then
                        if player:isFellowSpawned() then
--                           player:getFellow():sendEntityEmote(player:getFellow(), dsp.emote.HARVESTING, dsp.emoteMode.MOTION)
                            player:setLocalVar("questHelm", dsp.keyItem.MISTROOT)
                            return quest:progressEvent(70, {[0] = 4294966559})
                        elseif player:getLocalVar("questHelm") == 0 then
                            player:setLocalVar("questHelm", 1)
                            return quest:progressEvent(70, {[0] = 4294966559})
                        end
                    end
                end,
            },

            onEventFinish = {
                [70] = function(player, csid, option, npc)
                    if player:getLocalVar("questHelm") == dsp.keyItem.MISTROOT then
                        if npcUtil.giveKeyItem(player, dsp.keyItem.MISTROOT) then
                            player:setLocalVar("questHelm", 0)
                        end
                    elseif player:getLocalVar("questHelm") == 1 then
                        player:setLocalVar("questHelm", 2)
                        player:messageSpecial(zones[player:getZoneID()].text.NEED_FELLOW)
                    end
                end,
            },
        },

        [dsp.zone.JUGNER_FOREST] = {
            ['Logging_Point'] = {
                onTrade = function(player, npc, trade)
                    if quest:getVar(player, "Prog") == 1 and not player:hasKeyItem(dsp.keyItem.LUNASCENT_LOG) and npcUtil.tradeHasExactly(trade, dsp.items.HATCHET) then
                        if player:isFellowSpawned() then
--                            player:getFellow():sendEntityEmote(player:getFellow(), dsp.emote.LOGGING, dsp.emoteMode.MOTION)
                            player:setLocalVar("questHelm", dsp.keyItem.LUNASCENT_LOG)
                            return quest:progressEvent(20, {[0] = 4294966558})
                        elseif player:getLocalVar("questHelm") == 0 then
                            player:setLocalVar("questHelm", 1)
                            return quest:progressEvent(20, {[0] = 4294966558})
                        end
                    end
                end,
            },

            onEventFinish = {
                [20] = function(player, csid, option, npc)
                    if player:getLocalVar("questHelm") == dsp.keyItem.LUNASCENT_LOG then
                        if npcUtil.giveKeyItem(player, dsp.keyItem.LUNASCENT_LOG) then
                            player:setLocalVar("questHelm", 0)
                        end
                    elseif player:getLocalVar("questHelm") == 1 then
                        player:setLocalVar("questHelm", 2)
                        player:messageSpecial(zones[player:getZoneID()].text.NEED_FELLOW)
                    end
                end,
            },
        },

        [dsp.zone.MAZE_OF_SHAKHRAMI] = {
            ['Excavation_Point'] = {
                onTrade = function(player, npc, trade)
                    if quest:getVar(player, "Prog") == 1 and not player:hasKeyItem(dsp.keyItem.GLIMMERING_MICA) and npcUtil.tradeHasExactly(trade, dsp.items.PICKAXE) then
                        if player:isFellowSpawned() then
--                            player:getFellow():sendEntityEmote(player:getFellow(), dsp.emote.EXCAVATION, dsp.emoteMode.MOTION)
                            player:setLocalVar("questHelm", dsp.keyItem.GLIMMERING_MICA)
                            return quest:progressEvent(60, {[0] = 4294966560})
                        elseif player:getLocalVar("questHelm") == 0 then
                            player:setLocalVar("questHelm", 1)
                            return quest:progressEvent(60, {[0] = 4294966560})
                        end
                    end
                end,
            },

            onEventFinish = {
                [60] = function(player, csid, option, npc)
                    if player:getLocalVar("questHelm") == dsp.keyItem.GLIMMERING_MICA then
                        if npcUtil.giveKeyItem(player, dsp.keyItem.GLIMMERING_MICA) then
                            player:setLocalVar("questHelm", 0)
                        end
                    elseif player:getLocalVar("questHelm") == 1 then
                        player:setLocalVar("questHelm", 2)
                        player:messageSpecial(zones[player:getZoneID()].text.NEED_FELLOW)
                    end
                end,
            },
        },

        [dsp.zone.BEAUCEDINE_GLACIER] = {
            ['Mirror_Pond'] = {
                onTrigger = function(player, npc)
                    if quest:getVar(player, "Prog") == 2 then
                        return quest:progressEvent(152, {[7] = getFellowParam(player)})
                    end
                end,
            },

            onZoneIn = {
                function(player, prevZone)
                    if quest:getVar(player, "Prog") == 1 and player:hasKeyItem(dsp.keyItem.GLIMMERING_MICA)
                    and player:hasKeyItem(dsp.keyItem.LUNASCENT_LOG) and player:hasKeyItem(dsp.keyItem.MISTROOT) then
                        return 151
                    end
                end,
            },

            onEventUpdate = {
                [151] = function(player, csid, option, npc)
                    player:updateEvent(0,0,0,0,0,0,0,getFellowParam(player))
                end,
            },

            onEventFinish = {
                [151] = function(player, csid, option, npc)
                    quest:setVar(player, "Prog", 2)
                end,

                [152] = function(player, csid, option, npc)
                    quest:setVar(player, "Prog", 3)
                    player:delKeyItem(dsp.keyItem.GLIMMERING_MICA)
                    player:delKeyItem(dsp.keyItem.LUNASCENT_LOG)
                    player:delKeyItem(dsp.keyItem.MISTROOT)
                end,
            },
        },
    },

        -- Doors normal state
    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE or status == QUEST_COMPLETED
        end,

        [dsp.zone.LOWER_JEUNO] = {
            ['_6td'] = {
                onTrigger = function(player, npc)
                    return quest:messageSpecial(zones[player:getZoneID()].text.DO_NOT_DISTURB)
                end
            },
        },
    },
}

return quest
