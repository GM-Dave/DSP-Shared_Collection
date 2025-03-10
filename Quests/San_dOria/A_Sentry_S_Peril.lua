-----------------------------------
-- A Sentry's Peril
-- Gleen - Southern Sandoria, !pos -122 -2 15 230
-- Aaveleon - West Ronfaure, !pos -431 -45 343 100
-----------------------------------
require('scripts/globals/items')
require('scripts/globals/quests')
require('scripts/globals/titles')
require('scripts/globals/interaction/quest')
require('scripts/globals/npc_util')
-----------------------------------

local quest = Quest:new(SANDORIA, A_SENTRY_S_PERIL)

quest.reward = {
    fame = 30,
    title = dsp.title.RONFAURIAN_RESCUER,
    item = dsp.items.BRONZE_SUBLIGAR,
}

quest.sections = {
    -- Section: Begin quest
    {
        check = function(player, status)
            return status == QUEST_AVAILABLE
        end,

        [dsp.zone.SOUTHERN_SAN_DORIA] = {
            ['Glenne'] = quest:progressEvent(510),

            onEventFinish = {
                [510] = function(player, csid, option, npc)
                    if option == 0 and npcUtil.giveItem(player, dsp.items.DOSE_OF_OINTMENT) then
                        quest:begin(player)
                    end
                end,
            },
        }
    },

    -- Section: Deliver ointment and return with ointment case
    {
        check = function(player, status)
            return status == QUEST_ACCEPTED
        end,

        [dsp.zone.SOUTHERN_SAN_DORIA] = {
            ['Glenne'] = {
                onTrigger = function(player, npc)
                    if player:hasItem(dsp.items.DOSE_OF_OINTMENT) or player:hasItem(dsp.items.OINTMENT_CASE) then
                        return quest:event(520)
                    else
                        -- Reaquire ointment
                        return quest:progressEvent(644)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, dsp.items.OINTMENT_CASE) then
                        return quest:progressEvent(513)
                    else
                        return quest:event(514) -- "I cannot accept this. Take it back."
                    end
                end,
            },

            onEventFinish = {
                [644] = function(player, csid, option, npc)
                    npcUtil.giveItem(player, dsp.items.DOSE_OF_OINTMENT)
                end,
                [513] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },

        [dsp.zone.WEST_RONFAURE] = {
            ['Aaveleon'] = {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, dsp.items.DOSE_OF_OINTMENT) then
                        if player:getFreeSlotsCount() == 0 then
                            return quest:event(118)
                        else
                            return quest:progressEvent(100)
                        end
                    else
                        return quest:event(106)
                    end
                end,
            },

            onEventFinish = {
                [100] = function(player, csid, option)
                    if npcUtil.giveItem(player, dsp.items.OINTMENT_CASE) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}


return quest
