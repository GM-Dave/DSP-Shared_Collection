-----------------------------------
-- Axe the Competition
-- Brutus !pos -55 8 95 244
-- qm9 !pos 218 -8 206 159
-----------------------------------
require("scripts/globals/items")
require("scripts/globals/quests")
require("scripts/globals/npc_util")
require('scripts/globals/interaction/quest')
require("scripts/globals/weaponskillids")
-----------------------------------

local quest = Quest:new(JEUNO, AXE_THE_COMPETITION)

quest.reward = {
    fame = 30,
}

quest.sections = {

    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE and
                player:canEquipItem(dsp.items.PICK_OF_TRIALS, true) and
                player:getCharSkillLevel(dsp.skill.AXE) / 10 >= 240 and
                not player:hasKeyItem(dsp.keyItem.WEAPON_TRAINING_GUIDE)
        end,

        [dsp.zone.UPPER_JEUNO] = {
            ['Brutus'] = {
                onTrigger = function(player, npc)
                    return quest:progressEvent(12) -- start
                end,
            },

            onEventFinish = {
                [12] = function(player, csid, option, npc)
                    if npcUtil.giveItem(player, dsp.items.PICK_OF_TRIALS) and option == 1 then
                        npcUtil.giveKeyItem(player, dsp.keyItem.WEAPON_TRAINING_GUIDE)
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

        [dsp.zone.UPPER_JEUNO] = {
            ['Brutus'] = {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(dsp.ki.ANNALS_OF_TRUTH) then
                        return quest:progressEvent(17) -- complete
                    elseif player:hasKeyItem(dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH) then
                        return quest:event(16) -- cont 2
                    else
                        return quest:event(15) -- cont 1
                    end
                end,

                onTrade = function(player, npc, trade)
                    local wsPoints = (trade:getItem(0):getWeaponskillPoints())
                    if npcUtil.tradeHasExactly(trade, dsp.items.PICK_OF_TRIALS) then
                        if wsPoints < 300 then
                            return quest:event(14) -- unfinished weapon
                        else
                            return quest:progressEvent(13) -- finished weapon
                        end
                    end
                end,
            },

            onEventFinish = {
                [15] = function(player, csid, option, npc)
                    if option == 1 then
                        npcUtil.giveItem(player, dsp.items.PICK_OF_TRIALS)
                    elseif option == 2 then
                        player:delQuest(JEUNO, AXE_THE_COMPETITION)
                        player:delKeyItem(dsp.ki.WEAPON_TRAINING_GUIDE)
                        player:delKeyItem(dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH)
                    end
                end,
                [13] = function(player, csid, option, npc)
                    player:confirmTrade()
                    npcUtil.giveKeyItem(player, dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH)
                end,
                [17] = function(player, csid, option, npc)
                    player:delKeyItem(dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH)
                    player:delKeyItem(dsp.ki.ANNALS_OF_TRUTH)
                    player:delKeyItem(dsp.ki.WEAPON_TRAINING_GUIDE)
                    player:addLearnedWeaponskill(dsp.ws_unlock.DECIMATION)
                    player:messageSpecial(zones[player:getZoneID()].text.DECIMATION_LEARNED)
                    quest:complete(player)
                end,
            },
        },

        [dsp.zone.TEMPLE_OF_UGGALEPIH] = {
            ['qm9'] = {
                onTrigger = function(player, npc)
                    if player:getLocalVar('killed_wsnm') == 1 then
                        player:setLocalVar('killed_wsnm', 0)
                        player:addKeyItem(dsp.ki.ANNALS_OF_TRUTH)
                        return quest:messageSpecial(zones[player:getZoneID()].text.KEYITEM_OBTAINED, dsp.ki.ANNALS_OF_TRUTH)
                    elseif player:hasKeyItem(dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH) and not player:hasKeyItem(dsp.keyItem.ANNALS_OF_TRUTH) and npcUtil.popFromQM(player, npc, zones[player:getZoneID()].mob.YALLERY_BROWN, {hide = 0}) then
                        return quest:messageSpecial(zones[player:getZoneID()].text.SENSE_OMINOUS_PRESENCE)
                    end
                end,
            },
            ['Yallery_Brown'] = {
                onMobDeath = function(mob, player, isKiller, firstCall)
                    player:setLocalVar('killed_wsnm', 1)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status >= QUEST_AVAILABLE
        end,

        [dsp.zone.QUICKSAND_CAVES] = {
            ['qm9'] = {
                onTrigger = function(player, npc)
                    return quest:messageSpecial(zones[player:getZoneID()].text.NOTHING_OUT_OF_ORDINARY)
                end,
            },
        },
    },
}


return quest
