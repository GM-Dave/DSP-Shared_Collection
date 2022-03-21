-----------------------------------
--
-- Assault 51 Nyzul Isle Investigation
--
-----------------------------------
local ID = require("scripts/zones/Nyzul_Isle/IDs")
require("scripts/globals/instance")
require("scripts/globals/keyitems")
require("scripts/globals/status")
require("scripts/globals/utils/nyzul")
require("scripts/globals/utils")
require("scripts/zones/Nyzul_Isle/globals/points")
-----------------------------------

function afterInstanceRegister(player)
    local instance = player:getInstance()

    player:messageName(ID.text.COMMENCE, player, player:getCurrentAssault())
    player:messageName(ID.text.TIME_TO_COMPLETE, player, instance:getTimeLimit())

    player:addTempItem(5348)
end

function onInstanceCreated(instance)
    local data = instance:getData()

    data.evenFloorNMs =
    {
        [1] = -- floor 1 to 19 NM's
        {
            17092824, 17092825, 17092826, 17092827, 17092828, 17092829, 17092830, 17092831, 17092832,
        },
        [2] = -- floor 21 to 39 NM's
        {
            17092842, 17092843, 17092844, 17092845, 17092846, 17092847, 17092848, 17092849, 17092850,
        },
        [3] = -- floor 41 to 59 NM's
        {
            17092860, 17092861, 17092862, 17092863, 17092864, 17092865, 17092866, 17092867, 17092868,
        },
        [4] = -- floor 61 to 79 NM's
        {
            17092878, 17092879, 17092880, 17092881, 17092882, 17092883, 17092884, 17092885, 17092886,
        },
        [5] = -- floor 81 to 99 NM's
        {
            17092896, 17092897, 17092898, 17092899, 17092900, 17092901, 17092902, 17092903, 17092904,
        },
    }

    data.oddFloorNMs =
    {
        [1] = -- floor 1 to 19 NM's
        {
            17092833, 17092834, 17092835, 17092836, 17092837, 17092838, 17092839, 17092840, 17092841,
        },
        [2] = -- floor 21 to 39 NM's
        {
            17092851, 17092852, 17092853, 17092854, 17092855, 17092856, 17092857, 17092858, 17092859,
        },
        [3] = -- floor 41 to 59 NM's
        {
            17092869, 17092870, 17092871, 17092872, 17092873, 17092874, 17092875, 17092876, 17092877,
        },
        [4] = -- floor 61 to 79 NM's
        {
            17092887, 17092888, 17092889, 17092890, 17092891, 17092892, 17092893, 17092894, 17092895,
        },
        [5] = -- floor 81 to 99 NM's
        {
            17092905, 17092906, 17092907, 17092908, 17092909, 17092910, 17092911, 17092912, 17092913,
        },
    }
end

function onInstanceTimeUpdate(instance, elapsed)
    updateInstanceTime(instance, elapsed, ID.text)
end

function onInstanceFailure(instance)
    local chars = instance:getChars()

    for _, players in ipairs(chars) do
        players:messageSpecial(ID.text.MISSION_FAILED, 10, 10)
        players:startEvent(1)
    end
end

function onInstanceProgressUpdate(instance, progress)
    if progress > 0 then
        if nyzul.handleProgress(instance, progress) then
            nyzul.activateRuneOfTransfer(instance)
        end
    end
end

function onInstanceComplete(instance)
end

function pickSetPoint(instance)
    local chars = instance:getChars()
    local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")

    -- Random the floor layout
    instance:setLocalVar("Nyzul_Isle_FloorLayout", math.random(1, (#nyzul.FloorLayout - 1)))
    instance:setLocalVar("gearObjective", 0)

    -- Condition for floors
    if currentFloor % 20 == 0 then -- hard set objective and floor to boss stage for every 20th floor
        instance:setStage(nyzul.objective.ELIMINATE_ENEMY_LEADER)
        instance:setLocalVar("Nyzul_Isle_FloorLayout", 0)
    elseif math.random(1, 30) == 1 and instance:getLocalVar("freeFloor") == 0 then -- 3.33% for a free floor
        instance:setStage(nyzul.objective.FREE_FLOOR)
        instance:setLocalVar("freeFloor", 1)
        GetNPCByID(ID.npc.RUNE_TRANSFER_START, instance):timer(9000, function(m) local instance = m:getInstance() instance:setProgress(15) end) -- Completes objective for free floor
    else
        instance:setStage(math.random(nyzul.objective.ELIMINATE_ENEMY_LEADER, nyzul.objective.ELIMINATE_ALL_ENEMIES)) -- Randoms floor objective
        if math.random(1, 30) <= 5 then
            instance:setLocalVar("gearObjective", math.random(nyzul.gearObjective.AVOID_AGRO, nyzul.gearObjective.DO_NOT_DESTROY))
        end
    end

    -- Setup points to travel to
    local layoutPoint = nyzul.FloorLayout[instance:getLocalVar("Nyzul_Isle_FloorLayout")]
    local posX = layoutPoint[1] local posY = layoutPoint[2] local posZ = layoutPoint[3]

    -- Set Rune of Transfer to Point
    for _, npcID in pairs(ID.npc.RUNE_OF_TRANSFER) do
        local runeOfTransfer = GetNPCByID(npcID, instance)
        if runeOfTransfer:getStatus() == dsp.status.DISAPPEAR then
            runeOfTransfer:AnimationSub(0)
            runeOfTransfer:setPos(posX, posY, posZ)
            runeOfTransfer:setStatus(dsp.status.NORMAL)
            break
        end
    end

    -- Set players to Point and messaging
    for _, players in pairs(chars) do
        players:setPos(posX, posY, posZ)
        players:messageName(ID.text.WELCOME_TO_FLOOR, players, currentFloor, currentFloor)
        if instance:getStage() ~= nyzul.objective.FREE_FLOOR then
            players:messageName(ID.text.ELIMINATE_ENEMY_LEADER + instance:getStage(), players)
            local gearObjective = instance:getLocalVar("gearObjective")
            if gearObjective > 0 then
                players:messageSpecial(ID.text.ELIMINATE_ALL_ENEMIES + gearObjective)
            end
        end
    end

    -- Set Rune of Transfer Menu
    instance:setLocalVar("menuChoice", math.random(1, 20))
end

function pickMobs(instance)
    local data = instance:getData()
    local currentFloor = instance:getLocalVar("Nyzul_Current_Floor")
    local mobFamily = math.random(1, 16)
    local floorLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local pointTable = nyzulPoint.SpawnPoint[floorLayout]
    local spawnPoint = {}

    -- 20th floor bosses
    if currentFloor % 20 == 0 then
        local floorBoss = 0

        if currentFloor == 20 or currentFloor == 40 then
            floorBoss = math.random(nyzul.pickMobs[0][40].ADAMANTOISE, nyzul.pickMobs[0][40].FAFNIR)
        elseif currentFloor == 60 or currentFloor == 80 or currentFloor == 100 then
            floorBoss = math.random(nyzul.pickMobs[0][100].KHIMAIRA, nyzul.pickMobs[0][100].CERBERUS)
        end

        GetMobByID(ID.mob[51].ARCHAIC_RAMPART1, instance):setSpawn(-36, 0, -362, 0)
        GetMobByID(floorBoss, instance):setSpawn(-55.000, 1, -380.000, 250)
        SpawnMob(ID.mob[51].ARCHAIC_RAMPART1, instance)
        SpawnMob(floorBoss, instance)
    else
        for i = 1, #pointTable do
            table.insert(spawnPoint, i, pointTable[i])
        end

        -- All other floors
        if instance:getStage() ~= nyzul.objective.FREE_FLOOR then
            -- Enemy Leader Objective
            if instance:getStage() == nyzul.objective.ELIMINATE_ENEMY_LEADER then
                local floorBoss = math.random(nyzul.pickMobs[1].MOKKE, nyzul.pickMobs[1].LONG_HORNED_CHARIOT)
                if floorBoss == 17092962 then
                    floorBoss = 17092961 + (math.random(0,1)*2)
                end
                local sPoint = math.random(1, #spawnPoint)
                GetMobByID(floorBoss, instance):setSpawn(spawnPoint[sPoint])
                SpawnMob(floorBoss, instance)
                table.remove(spawnPoint, sPoint)
            -- Specified Enemy Group Objective
            elseif instance:getStage() == nyzul.objective.ELIMINATE_SPECIFIED_ENEMIES then
                local specificEnemies = {}
                local specificGroup = math.random(0,6)
                local groupAmount = math.random(2, #nyzul.pickMobs[2][specificGroup])
                local specificEnemyGroup = nyzul.pickMobs[2][specificGroup]

                for i = 1, #specificEnemyGroup do
                    table.insert(specificEnemies, specificEnemyGroup[i])
                end

                while groupAmount > 0 do
                    local randomEnemy = math.random(1, #specificEnemies)
                    local enemy = specificEnemies[randomEnemy]
                    local sPoint = math.random(1, #spawnPoint)

                    GetMobByID(enemy, instance):setSpawn(spawnPoint[sPoint])
                    SpawnMob(enemy, instance)
                    table.remove(spawnPoint, sPoint)
                    table.remove(specificEnemies, randomEnemy)
                    instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)

                    groupAmount = groupAmount - 1
                end
            -- Eliminate All Objective
            elseif instance:getStage() == nyzul.objective.ELIMINATE_ALL_ENEMIES then
                if math.random(0,100) >= 80 then -- 20% chance that Dahank will spawn
                    local sPoint = math.random(1, #spawnPoint)
                    GetMobByID(ID.mob[51].DAHAK, instance):setSpawn(spawnPoint[sPoint])
                    SpawnMob(ID.mob[51].DAHAK, instance)
                    table.remove(spawnPoint, sPoint)
                    instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
                end
            -- Activate Lamps Objective
            elseif instance:getStage() == nyzul.objective.ACTIVATE_ALL_LAMPS then
                instance:setLocalVar("[Lamps]Objective", math.random(nyzul.lampsObjective.REGISTER, nyzul.lampsObjective.ORDER))
                lampsActivate(instance)
            end
            -- 1st Rampart: 90% spawn rate
            if math.random(0,100) >= 90 then
                local sPoint = math.random(1, #spawnPoint)
                GetMobByID(ID.mob[51].ARCHAIC_RAMPART1, instance):setSpawn(spawnPoint[sPoint])
                SpawnMob(ID.mob[51].ARCHAIC_RAMPART1, instance)
                table.remove(spawnPoint, sPoint)
                if instance:getStage() == nyzul.objective.ELIMINATE_ALL_ENEMIES then
                    instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
                end
            end
            -- 2nd Rampart: 20% spawn rate
            if math.random(0,100) >= 20 then
                local sPoint = math.random(1, #spawnPoint)
                GetMobByID(ID.mob[51].ARCHAIC_RAMPART2, instance):setSpawn(spawnPoint[sPoint])
                SpawnMob(ID.mob[51].ARCHAIC_RAMPART2, instance)
                table.remove(spawnPoint, sPoint)
                if instance:getStage() == nyzul.objective.ELIMINATE_ALL_ENEMIES then
                    instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
                end
            end
            -- Spawn Gears
            if instance:getLocalVar("gearObjective") > 0 then
                for i = nyzul.FloorEntities[17].start, nyzul.FloorEntities[17].stop do
                    local sPoint = math.random(1, #spawnPoint)
                    instance:setLocalVar("gearPenalty", math.random(nyzul.penalty.TIME, nyzul.penalty.PATHOS))
                    GetMobByID(i, instance):setSpawn(spawnPoint[sPoint])
                    SpawnMob(i, instance)
                    table.remove(spawnPoint, sPoint)
                end
            end

             -- Trash NM's of floor
            local spawnmedNMs = math.random(0, 4)
            if spawnmedNMs > 0 then
                local floorSection = math.floor(currentFloor/20) + 1

                while spawnmedNMs > 2 do
                    local sPoint = math.random(1, #spawnPoint)
                    local randomNM = 0
                    local NM_mob = 0

                    if currentFloor % 2 == 0 then
                        randomNM = math.random(1, #data.evenFloorNMs[floorSection])
                        NM_mob = data.evenFloorNMs[floorSection][randomNM]
                        table.remove(data.evenFloorNMs[floorSection], randomNM)
                    else
                        randomNM = math.random(1, #data.oddFloorNMs[floorSection])
                        NM_mob = data.oddFloorNMs[floorSection][randomNM]
                        table.remove(data.oddFloorNMs[floorSection], randomNM)
                    end
                    GetMobByID(NM_mob, instance):setSpawn(spawnPoint[sPoint])
                    SpawnMob(NM_mob, instance)

                    table.remove(spawnPoint, sPoint)

                    spawnmedNMs = spawnmedNMs - 1

                    if instance:getStage() == nyzul.objective.ELIMINATE_ALL_ENEMIES then
                        instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
                    end
                end
            end
            -- Add rest of mobs for all Objectives
            local groupAmount = math.random(6, #nyzul.FloorEntities[mobFamily])
            local enemyGroup = nyzul.FloorEntities[mobFamily]
            local enemies = {}

            for i = 1, #enemyGroup do
                table.insert(enemies, enemyGroup[i])
            end

            while groupAmount > 0 do
                local randomEnemy = math.random(1, #enemies)
                local enemy = enemies[randomEnemy]
                local sPoint = math.random(1, #spawnPoint)

                if instance:getStage() == nyzul.objective.ELIMINATE_ALL_ENEMIES then
                    instance:setLocalVar("Eliminate", instance:getLocalVar("Eliminate") + 1)
                elseif instance:getStage() == nyzul.objective.ELIMINATE_SPECIFIED_ENEMY and instance:getLocalVar("Nyzul_Specified_Enemy") == 0 then
                    instance:setLocalVar("Nyzul_Specified_Enemy", enemy)
                end
                GetMobByID(enemy, instance):setSpawn(spawnPoint[sPoint])
                SpawnMob(enemy, instance)
                table.remove(enemies, randomEnemy)
                table.remove(spawnPoint, sPoint)

                groupAmount = groupAmount - 1
            end
        end
    end
end

function lampsActivate(instance)
    local floorLayout = instance:getLocalVar("Nyzul_Isle_FloorLayout")
    local lampsObjective = instance:getLocalVar("[Lamps]Objective")
    local runicLamp_1 = GetNPCByID(ID.npc.RUNIC_LAMP_1, instance)
    local partySize = instance:getLocalVar("partySize")
    if partySize > 4 then partySize = 5 elseif partySize < 3 then partySize = 3 end
    local lampPoints = {}

    for i = 1, #nyzulPoint.LampPoint[floorLayout] do
        table.insert(lampPoints, i, nyzulPoint.LampPoint[floorLayout][i])
    end

    -- Lamp Objective: Register
    if lampsObjective == nyzul.lampsObjective.REGISTER then
        local spawnPoint = math.random(1, #lampPoints)

        instance:setLocalVar("[Lamp]PartySize", instance:getLocalVar("partySize"))
        runicLamp_1:setPos(lampPoints[spawnPoint])
        runicLamp_1:setStatus(dsp.status.NORMAL)
    -- Lamp Objective: Activate All
    elseif lampsObjective == nyzul.lampsObjective.ACTIVATE_ALL then
        local runicLamps = math.random(2, partySize - 1)
        instance:setLocalVar("[Lamp]count", runicLamps)
        for i = ID.npc.RUNIC_LAMP_1, ID.npc.RUNIC_LAMP_1 + runicLamps do
            local spawnPoint = math.random(1, #lampPoints)

            GetNPCByID(i, instance):setPos(lampPoints[spawnPoint])
            GetNPCByID(i, instance):setStatus(dsp.status.NORMAL)
            table.remove(lampPoints, spawnPoint)
        end
    -- Lamp Objective: Activate in Order
    elseif lampsObjective == nyzul.lampsObjective.ORDER then
        local runicLamps = math.random(2, 4)
        local lampOrder = {}
        for j = 1, runicLamps + 1 do
            table.insert(lampOrder, j)
        end
        instance:setLocalVar("[Lamp]count", runicLamps)
        instance:setLocalVar("[Lamp]lampRegister", 0)
        for i = ID.npc.RUNIC_LAMP_1, ID.npc.RUNIC_LAMP_1 + runicLamps do
            local spawnPoint = math.random(1, #lampPoints)
            local lampRandom = math.random(1, #lampOrder)

            GetNPCByID(i, instance):setPos(lampPoints[spawnPoint])
            GetNPCByID(i, instance):setStatus(dsp.status.NORMAL)
            GetNPCByID(i, instance):setLocalVar("[Lamp]order", lampOrder[lampRandom])

            table.remove(lampOrder, lampRandom)
            table.remove(lampPoints, spawnPoint)
        end
    end
end

function onEventUpdate(player, csid, option)
    if csid == 95 then
        local instance = player:getInstance()
        if instance:getLocalVar("runeHandler") == player:getID() then
            pickSetPoint(instance)
        end
    end
end

function onEventFinish(player, csid, option, npc)
    local instance = player:getInstance()
    local chars = instance:getChars()

    if csid == 1 then
        for _, players in ipairs(chars) do
            players:setPos(0, 0, 0, 0, dsp.zone.ALZADAAL_UNDERSEA_RUINS)
        end
    elseif csid == 95 then
        if instance:getLocalVar("runeHandler") == player:getID() then
            pickMobs(instance)
            nyzul.removePathos(instance)
            nyzul.addFloorPathos(instance)
            instance:setLocalVar("runeHandler", 0)
        end
    end
end
