-----------------------------------
-- What Friends Are For
-- Region !pos -389 13 -445 68
-- Tsetseroon !pos -13 -6 69 53
-- Qm9 !pos -406 6.5 -440 68
-----------------------------------
require("scripts/globals/items")
require("scripts/globals/keyitems")
require("scripts/globals/quests")
require("scripts/globals/npc_util")
require('scripts/globals/npc/quest')
-----------------------------------

local quest = Quest:new(AHT_URHGAN, WHAT_FRIENDS_ARE_FOR)

quest.sections = {


    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE and vars.Prog == 0
        end,

        [dsp.zone.AYDEEWA_SUBTERRANE] = {
            ['qm9'] = {
                onTrigger = function(player, npc)
                    return quest:messageSpecial(zones[player:getZoneID()].text.NOTHING_OUT_OF_ORDINARY)
                end,
            },
            onRegionEnter = {
                [2] = function(player, region)
                    return quest:progressEvent(7)
                end,
            },

            onEventFinish = {
                [7] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
        [dsp.zone.NASHMAU] = {
            ['Tsetseroon'] = {
                onTrigger = function(player, npc)
                    return quest:event(4)
                end,
            },
        },
    },
    {
        check = function(player, status, vars)
            return status == QUEST_AVAILABLE and vars.Prog == 1
        end,

        [dsp.zone.NASHMAU] = {
            ['Tsetseroon'] = {
                onTrigger = function(player, npc)
                    return quest:progressEvent(16)
                end,
            },

            onEventFinish = {
                [16] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                    quest:begin(player)
                end,
            },
        },
    },
    {
        check = function(player, status, vars)
            return status == QUEST_ACCEPTED
        end,

        [dsp.zone.NASHMAU] = {
            ['Tsetseroon'] = {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 2 then
                        return quest:event(17)
                    elseif quest:getVar(player, 'Prog') == 3 then
                        return quest:event(19)
                    elseif quest:getVar(player, 'Prog') == 4 then
                        return quest:progressEvent(20)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if quest:getVar(player, 'Prog') == 2 and npcUtil.tradeHasExactly(trade, {dsp.items.CHUNK_OF_TIN_ORE, dsp.items.COBALT_JELLYFISH}) then
                        return quest:progressEvent(18)
                    end
                end,
            },

            onEventFinish = {
                [16] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                    quest:begin(player)
                end,
                [18] = function(player, csid, option, npc)
                    player:confirmTrade()
                    npcUtil.giveKeyItem(player, dsp.ki.POT_OF_TSETSEROONS_STEW)
                    quest:setVar(player, 'Prog', 3)
                end,
                [20] = function(player, csid, option, npc)
                    if player:hasKeyItem(dsp.ki.MAP_OF_AYDEEWA_SUBTERRANE) then
                        if npcUtil.giveItem(player, dsp.items.IMPERIAL_BRONZE_PIECE) then
                            quest:complete(player)
                        end
                    else
                        npcUtil.giveKeyItem(player, dsp.ki.MAP_OF_AYDEEWA_SUBTERRANE)
                        quest:complete(player)
                    end
                end,
            },
        },
        [dsp.zone.AYDEEWA_SUBTERRANE] = {
            ['qm9'] = {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 3 and player:hasKeyItem(dsp.ki.POT_OF_TSETSEROONS_STEW) then
                        return quest:progressEvent(8)
                    else
                        return quest:messageSpecial(zones[player:getZoneID()].text.NOTHING_OUT_OF_ORDINARY)
                    end
                end,
            },
            onEventFinish = {
                [8] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                    player:delKeyItem(dsp.ki.POT_OF_TSETSEROONS_STEW)
                    if option == 1 then
                        npcUtil.giveKeyItem(player, dsp.ki.MAP_OF_AYDEEWA_SUBTERRANE)
                    end
                end,
            },
        },
    },
    {
        check = function(player, status, vars)
            return status == QUEST_COMPLETED
        end,

        [dsp.zone.NASHMAU] = {
            ['Tsetseroon'] = {
                onTrigger = function(player, npc)
                    return quest:event(21)
                end,
            },
        },
        [dsp.zone.AYDEEWA_SUBTERRANE] = {
            ['qm9'] = {
                onTrigger = function(player, npc)
                    return quest:messageSpecial(zones[player:getZoneID()].text.NOTHING_OUT_OF_ORDINARY)
                end,
            },
        },
    },
}


return quest
