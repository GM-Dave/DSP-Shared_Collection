-----------------------------------
-- The Walls Of Your Mind
-- Oggbi !pos -159 -7 5 236
-- qm1 !pos 20 17 -140 167
-----------------------------------
require("scripts/globals/items")
require("scripts/globals/quests")
require("scripts/globals/npc_util")
require('scripts/globals/interaction/quest')
require("scripts/globals/weaponskillids")
-----------------------------------

local quest = Quest:new(BASTOK, THE_WALLS_OF_YOUR_MIND)

quest.reward = {
    fame = 30,
}

quest.sections = {

    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE and
                player:canEquipItem(dsp.items.KNUCKLES_OF_TRIALS, true) and
                player:getCharSkillLevel(dsp.skill.HAND_TO_HAND) / 10 >= 250 and
                not player:hasKeyItem(dsp.keyItem.WEAPON_TRAINING_GUIDE)
        end,

        [dsp.zone.PORT_BASTOK] = {
            ['Oggbi'] = {
                onTrigger = function(player, npc)
                    return quest:progressEvent(286)
                end,
            },

            onEventFinish = {
                [286] = function(player, csid, option, npc)
                    if npcUtil.giveItem(player, dsp.items.KNUCKLES_OF_TRIALS) then
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

        [dsp.zone.PORT_BASTOK] = {
            ['Oggbi'] = {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(dsp.ki.ANNALS_OF_TRUTH) then
                        return quest:progressEvent(290)
                    else
                        return quest:event(287)
                    end
                end,

                onTrade = function(player, npc, trade)
                    local wsPoints = (trade:getItem(0):getWeaponskillPoints())
                    if npcUtil.tradeHasExactly(trade, dsp.items.KNUCKLES_OF_TRIALS) then
                        if wsPoints < 300 then
                            return quest:event(288)
                        else
                            return quest:progressEvent(289)
                        end
                    end
                end,
            },

            onEventFinish = {
                [287] = function(player, csid, option, npc)
                    if option == 1 then
                        npcUtil.giveItem(player, dsp.items.KNUCKLES_OF_TRIALS)
                    elseif option == 2 then
                        player:delQuest(BASTOK, THE_WALLS_OF_YOUR_MIND)
                        player:delKeyItem(dsp.ki.WEAPON_TRAINING_GUIDE)
                        player:delKeyItem(dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH)
                    end
                end,
                [289] = function(player, csid, option, npc)
                    player:confirmTrade()
                    npcUtil.giveKeyItem(player, dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH)
                end,
                [290] = function(player, csid, option, npc)
                    player:delKeyItem(dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH)
                    player:delKeyItem(dsp.ki.ANNALS_OF_TRUTH)
                    player:delKeyItem(dsp.ki.WEAPON_TRAINING_GUIDE)
                    player:addLearnedWeaponskill(dsp.ws_unlock.ASURAN_FISTS)
                    player:messageSpecial(zones[player:getZoneID()].text.ASURAN_FISTS_LEARNED)
                    quest:complete(player)
                end,
            },
        },

        [dsp.zone.BOSTAUNIEUX_OUBLIETTE] = {
            ['qm1'] = {
                onTrigger = function(player, npc)
                    if player:getLocalVar('killed_wsnm') == 1 then
                        player:setLocalVar('killed_wsnm', 0)
                        player:addKeyItem(dsp.ki.ANNALS_OF_TRUTH)
                        return quest:messageSpecial(zones[player:getZoneID()].text.KEYITEM_OBTAINED, dsp.ki.ANNALS_OF_TRUTH)
                    elseif player:hasKeyItem(dsp.ki.MAP_TO_THE_ANNALS_OF_TRUTH) and not player:hasKeyItem(dsp.keyItem.ANNALS_OF_TRUTH) and npcUtil.popFromQM(player, npc, zones[player:getZoneID()].mob.BODACH, {hide = 0}) then
                        return quest:messageSpecial(zones[player:getZoneID()].text.SENSE_OMINOUS_PRESENCE)
                    end
                end,
            },
            ['Bodach'] = {
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

        [dsp.zone.BOSTAUNIEUX_OUBLIETTE] = {
            ['qm1'] = {
                onTrigger = function(player, npc)
                    return quest:messageSpecial(zones[player:getZoneID()].text.NOTHING_OUT_OF_ORDINARY)
                end,
            },
        },
    },
}


return quest
