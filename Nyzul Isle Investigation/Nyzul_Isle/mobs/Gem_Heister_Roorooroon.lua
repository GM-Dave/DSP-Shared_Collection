-----------------------------------
--  MOB: Gem Heister Roorooroon
-- Area: Nyzul Isle
-- Info: Enemy Leader, Thief job, runs around dropping bombs
-----------------------------------
require("scripts/globals/pathfind")
require("scripts/globals/status")
require("scripts/globals/utils/nyzul")
-----------------------------------

function onMobSpawn(mob)
    local instance = mob:getInstance()

    SpawnMob(mob:getID() + 1, instance)
end

function onMobEngaged(mob, target)
    mob:setLocalVar("runTime", math.random(10, 25))
end

function pickRunPoint(mob)
    mob:setLocalVar("ignore", 1)
    local distance = math.random(10, 25)
    local angle = math.random() * math.pi
    local fromTarget = mob:getTarget()
    if fromTarget == nil then
        fromTarget = mob
    end
    local pos = GetFurthestValidPosition(fromTarget, distance, angle)
    mob:setLocalVar("posX", pos.x)
    mob:setLocalVar("posY", pos.y)
    mob:setLocalVar("posZ", pos.z)
    mob:pathTo(pos.x, pos.y, pos.z, dsp.path.flag.RUN)
end

function continuePoints(mob)
    local pos = mob:getPos()
    local pathX = mob:getLocalVar("posX")
    local pathY = mob:getLocalVar("posY")
    local pathZ = mob:getLocalVar("posZ")
    local cycles = mob:getLocalVar("cycles")

    if pos.x ~= pathX and pos.z ~= pathZ then
        mob:pathTo(pathX, pathY, pathZ, dsp.path.flag.RUN)
    elseif cycles > 0 then
        mob:setLocalVar("cycles", cycles - 1)
        pickRunPoint(mob)
    else
        mob:setLocalVar("runTime", mob:getBattleTime() + math.random(10, 25))
        mob:setLocalVar("ignore", 0)
    end
end

function dropBomb(mob)
    local instance = mob:getInstance()
    local bomb = GetMobByID(mob:getID() + 1, instance)
    local target = mob:getTarget()
    local pos = mob:getPos()

    bomb:setPos(pos.x, pos.y, pos.z, pos.rot)
    bomb:setStatus(dsp.status.UPDATE)
    if target ~= nil then
        bomb:updateEnmity(target)
        bomb:timer(1000, function(bomb) bomb:useMobAbility(1838) end)
    end
    bomb:timer(4500, function(bomb) bomb:setStatus(dsp.status.DISAPPEAR) end)
end

function onMobFight(mob, target)
    local instance = mob:getInstance()
    local battletime = mob:getBattleTime()
    local runTime = mob:getLocalVar("runTime")
    local ignore = mob:getLocalVar("ignore")

    -- setup inital run around logic point and how many cycle of points
    if battletime > runTime and ignore == 0 then
        mob:setLocalVar("cycles", math.random(3, 6))
        pickRunPoint(mob)
    -- make sure mob keeps running and cycle to new plotted points
    elseif ignore == 1 then
        continuePoints(mob)
        if GetMobByID(mob:getID() + 1, instance):getStatus() == dsp.status.DISAPPEAR then
            if math.random(1, 5) == 2 then
                dropBomb(mob)
            end
        end
    end
end

function onMobDeath(mob, player, isKiller, firstCall)
    if firstCall then
        nyzul.spawnChest(mob, player)
        nyzul.enemyLeaderKill(mob)
    end
end
