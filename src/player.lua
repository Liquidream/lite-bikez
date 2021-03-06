
require("common")

local MOVE_SPEED = 1

function killPlayer(player, level, share, killedBy, IS_SERVER)
    -- 
    if (player ~= nil) then
        log("player DIED ("..(player.id or "<no id>")..")")
        log(">IS_SERVER="..tostring(IS_SERVER))

        player.dead = true
        player.killedAt = love.timer.getTime()
        player.killedBy = killedBy
        log("Player killed by: "..tonumber(player.killedBy))

        -- Update score
        if IS_SERVER then
            -- lose score point
            --player.score = math.max(player.score - 1, 0)
            if player.killedBy > 0 
            and player.killedBy ~= player.id then
                -- Increase "killer's" score 
                -- (if not ourselves!)
                share.players[player.killedBy].score = share.players[player.killedBy].score + 1
                -- tell the world
                createMessage(share, player.me.shortname.." squished by "..share.players[player.killedBy].me.shortname, 
                    37, { player.killedBy, player.id })
            
            elseif player.killedBy > 0 then
                -- tell the world
                createMessage(share, player.me.shortname.." squished self", 
                    37, { player.killedBy, player.id })
            else
                -- tell the world
                createMessage(share, player.me.shortname.." hit a wall", 
                    37, { player.killedBy, player.id })
            end
        else
            --CLIENT only            
            explodePlayer(player)
        end

        player.smoothX = 0
        player.smoothY = 0
    
        -- clear player grid data
        remove_player_from_grid(level, player)

    end
end


function resetPlayer(player, share, IS_SERVER)
    
    player.dead = false
    
    -- Start at a random position
    resetRNG(IS_SERVER)
    log("Resetting player "..(player.id or "<new>").."IS_SERVER="..tostring(IS_SERVER))--..", seed="..seed)
    
    player.waypoints={}
    player.pointCount=0
    player.last_xDir, player.last_yDir = -2,-2

    if IS_SERVER then
        -- the server decides the random start position
        -- (and tells the client)
        local attemptCount=0
        local r, g, b = 0,0,0

        ------------------------------------------------------------------------
        -- keep retrying player positions until has enough room to start
        ------------------------------------------------------------------------        
        repeat 
            log("allocating player start position")
            player.x = math.random(share.levelSize-3)+1
            player.y = math.random(share.levelSize-3)+1
            player.gridX = player.x
            player.gridY = player.y
            player.lastGridX = player.gridX
            player.lastGridY = player.gridY
            player.speed = PLAYER_START_SPEED
            player.boostCount = 0
            
    
            -- now face "inward"
            if math.random(2)>1 then
                player.xDir = (player.x < share.levelSize/2) and 1 or -1
                player.yDir = 0
            else
                player.xDir = 0
                player.yDir = (player.y < share.levelSize/2) and 1 or -1
            end

            r, g, b = 0,0,0
            
            
            ------------------------------------------------------------------------            
            -- check that there are at least X amount of free pixels ahead
            --
            local safeDistLength = 30
            local currDist = 1            
            local xPosCheck = player.x
            local yPosCheck = player.y
            local hitObstacle = false
            local hitOccupiedCell = false

            repeat
              
              -- in case player connects before server ready...
              if levelData then 
                r, g, b = levelData:getPixel(xPosCheck, yPosCheck)                
              end

              -- check we've not hit a level obstacle/boundary
              hitObstacle = r > 0 -- red means level obstacles/boundary              
              hitOccupiedCell = share.level.grid[xPosCheck][yPosCheck] > 0
                            
              --log(">>> r,g,b ="..tostring(r)..","..tostring(g)..","..tostring(b).."| hitObstacle="..tostring(hitObstacle)..", hitOccupiedCell="..tostring(hitOccupiedCell)..", currDist="..currDist)              

              -- move ahead to next pixel in face dir
              xPosCheck = xPosCheck + player.xDir
              yPosCheck = yPosCheck + player.yDir
              currDist = currDist + 1

            until hitObstacle or hitOccupiedCell or currDist > safeDistLength

            ------------------------------------------------------------------------
            

            attemptCount = attemptCount + 1 -- (don't let this loop infinitely!)

        until ((not hitObstacle) and (not hitOccupiedCell)) or (attemptCount > 100)

        log(".attemptCount="..attemptCount.."| r, g, b="..r..","..g..","..b)

        -- col based on id
        player.col = player.id * 2
        player.col2 = player.id * 2 + 1
    else
        -- CLIENT only 
        if deathParticles[player.id] then 
            table.remove(deathParticles, player.id)
        end
    end

    -- smoothing out network lag
    player.smoothX = 0
    player.smoothY = 0


    log("player pos = "..player.x..","..player.y)
    log("player gridpos = "..player.gridX..","..player.gridY)

    -- Add starting waypoint
    addWaypoint(player)


    log("#player.waypoints "..#player.waypoints)
end

function addWaypoint(player)
    local point={        
        x=player.gridX,
        y=player.gridY,
    }
    log("addWaypoint("..(player.id or "<nil>")..") ="..point.x..","..point.y)
    player.pointCount = player.pointCount + 1
    player.waypoints[player.pointCount] = point
    player.smoothX = player.gridX
    player.smoothY = player.gridY
end

function explodePlayer(player)
    log("in explodePlayer("..player.id..")...")
    -- create a new particle system
    local pEmitter = Sprinklez:createSystem(
        player.x * zoom_scale, 
        player.y * zoom_scale)
    
    -- set clip bounds
    pEmitter.game_width = 512 * zoom_scale + 20 -- add some leway for particles to spawn at edges
    pEmitter.game_height = 512 * zoom_scale + 20
    
    -- tweak effect for impact explosion
    pEmitter.fake_bounce = true
    pEmitter.spread = math.pi    --180
    pEmitter.lifetime = 5            -- Only want 1 burst
    pEmitter.rate = 20
    pEmitter.acc_min = 10
    pEmitter.acc_max = 100
    pEmitter.max_rnd_start = 7-- 5
    pEmitter.cols = {1, player.col, player.col+1, 56}   --{2,3,28,29}
    pEmitter.size_min = 1
    pEmitter.size_max = 3 --2

    -- Set angle, based on direction
    if (player.xDir < 0) then
        -- left
        pEmitter.angle = 0
    elseif (player.yDir < 0) then
        -- up
        pEmitter.angle = (math.pi/2)*3
    elseif (player.xDir > 0) then
        -- right
        pEmitter.angle = math.pi
    elseif (player.yDir > 0) then
        -- down
        pEmitter.angle = (math.pi/2)
    end

    -- Add to particle system
    deathParticles[player.id] = pEmitter    

    -- Stop "boost" emitter (if present)
    if boostParticles[player.id] then 
        table.remove(boostParticles, player.id)
    end
end

function boostPlayer(player)
    --log("in boostPlayer("..player.id..")...")
    if boostParticles[player.id] == nil 
     or boostParticles[player.id].lifetime == 0 then
        -- create a new particle system
        local pEmitter = Sprinklez:createSystem(
            player.smoothX * zoom_scale, 
            player.smoothY * zoom_scale)
        
        -- set clip bounds
        pEmitter.game_width = 512 * zoom_scale + 20 -- add some leway for particles to spawn at edges
        pEmitter.game_height = 512 * zoom_scale + 20
        
        -- tweak effect for trail
        pEmitter.rate = 5
        pEmitter.acc_min = 10
        pEmitter.acc_max = 10
        pEmitter.max_rnd_start = 5--30
        pEmitter.cols = {1, player.col, player.col+1, 29}   --{2,3,28,29}
        pEmitter.gravity = 0
        pEmitter.max_rnd_start = 10
        pEmitter.size_min = 0
        pEmitter.size_max = 2

        -- Add to particle system
        boostParticles[player.id]=pEmitter
    else
        -- update existing emitter
        local pEmitter = boostParticles[player.id]
        pEmitter.lifetime = -1
        pEmitter.xpos = player.smoothX * zoom_scale - zoom_scale
        pEmitter.ypos = player.smoothY * zoom_scale - zoom_scale
    end

end

function drawPlayer(player, draw_zoom_scale)
    local lastPoint = player.waypoints[1]
    
    -- Bail out if no colours
    if player.col==nil then 
        log("no col !!")
        return 
    end

    -- Bail out if waypoint
    if lastPoint==nil then 
        log("no lastPoint !!")
        return 
    end
    
    -- draw path
    for i=1,player.pointCount do
        local point = player.waypoints[i]
        --"corner"
        rectfill(
            lastPoint.x*draw_zoom_scale, lastPoint.y*draw_zoom_scale,
            lastPoint.x*draw_zoom_scale+draw_zoom_scale, lastPoint.y*draw_zoom_scale+draw_zoom_scale, player.col)
        --"line"
        rectfill(
            lastPoint.x*draw_zoom_scale, lastPoint.y*draw_zoom_scale,
            (point.x*draw_zoom_scale)+draw_zoom_scale, (point.y*draw_zoom_scale)+draw_zoom_scale, player.col)
        -- remember
        lastPoint = point
    end


    --
    -- draw to player current pos
    --

    -- apply client-side player postion "smoothing"
    --local x, y = player.gridX, player.gridY
    local x = player.xDir~=0 and player.x or player.gridX
    local y = player.yDir~=0 and player.y or player.gridY
    if not player.smoothX then
        player.smoothX = x
    end
    if not player.smoothY then
        player.smoothY = y
    end
    
    -- only apply smoothing to OTHER players, not us
    if player.id ~= client.id then
        --
        -- TODO: Check/improve this, coz it SEEMS a bit bloated!
        --
        player.smoothX = player.smoothX + 0.4 * (x - player.smoothX)
        player.smoothY = player.smoothY + 0.4 * (y - player.smoothY)
        player.smoothX = player.smoothX + 0.2 * (x - player.smoothX)
        player.smoothY = player.smoothY + 0.2 * (y - player.smoothY)
    else
        player.smoothX = x
        player.smoothY = y
    end

    --"corner"
    rectfill(
        lastPoint.x*draw_zoom_scale, lastPoint.y*draw_zoom_scale,
        lastPoint.x*draw_zoom_scale+draw_zoom_scale, lastPoint.y*draw_zoom_scale+draw_zoom_scale, player.col)
    -- "line"
    rectfill(
        lastPoint.x*draw_zoom_scale, lastPoint.y*draw_zoom_scale,
            (player.smoothX*draw_zoom_scale)+draw_zoom_scale, (player.smoothY*draw_zoom_scale)+draw_zoom_scale, player.col)

    -- "Head"
    rectfill(
        player.smoothX*draw_zoom_scale, player.smoothY*draw_zoom_scale,
            (player.smoothX*draw_zoom_scale)+draw_zoom_scale, (player.smoothY*draw_zoom_scale)+draw_zoom_scale, 1)

end

return Player