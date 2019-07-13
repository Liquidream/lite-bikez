
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
                createMessage(share, player.me.shortname.." was squished by "..share.players[player.killedBy].me.shortname, 
                    37, { player.killedBy, player.id })
            
            elseif player.killedBy > 0 then
                -- tell the world
                createMessage(share, player.me.shortname.." squished themselves", 
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
    resetRNG()
    log("Resetting player "..(player.id or "<new>").."IS_SERVER="..tostring(IS_SERVER))--..", seed="..seed)
    
    player.waypoints={}
    player.pointCount=0
    player.last_xDir, player.last_yDir = -2,-2

    if IS_SERVER then
        -- the server decides the random start position
        -- (and tells the client)
        local attemptCount=0
        repeat 
            log("allocating player start position")
            player.x = math.random(share.levelSize-1)
            player.y = math.random(share.levelSize-1)
            player.gridX = player.x
            player.gridY = player.y
            player.lastGridX = player.gridX
            player.lastGridY = player.gridY
            player.speed = PLAYER_START_SPEED
            player.boostCount = 0
            -- check we're in the "safe" zone
            --local r, g, b = levelData:getPixel(player.x, player.y)            
            -- in case player connects before server ready...
            local r, g, b = 0,5,5
            if levelData then 
                local r, g, b = levelData:getPixel(player.x, player.y)
            end
            local hitObstacle = r > 0 -- red means level obstacles/boundary
            local inSafeZone = g > 0 -- red means level obstacles/boundary
            attemptCount = attemptCount + 1
        until (not hitObstacle) and inSafeZone or attemptCount > 20 --or (levelData==nil)

        -- now face "inward"
        if math.random(2)>1 then
            player.xDir = (player.x < share.levelSize/2) and 1 or -1
            player.yDir = 0
        else
            player.xDir = 0
            player.yDir = (player.y < share.levelSize/2) and 1 or -1
        end

        -- col based on id
        player.col = player.id * 2
        player.col2 = player.id * 2 + 1
    else
        -- CLIENT only 
        if player.expEmitterIdx and player.expEmitterIdx > 0 then
            table.remove(pSystems, player.expEmitterIdx)
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
    pEmitter.max_rnd_start = 5--30
    pEmitter.cols = {1, player.col, player.col+1, 29}   --{2,3,28,29}
    pEmitter.size_min = 1
    pEmitter.size_max = 2

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

    -- Add to global list of systems    
    local idx = #pSystems + 1
    --https://stackoverflow.com/questions/25762102/table-insert-remember-key-of-inserted-value
    pSystems[idx] = pEmitter
    
    -- Remember pSystem index
    player.expEmitterIdx = idx

    -- Stop "boost" emitter (if present)
    if player.boostEmitterIdx > 0 then
        table.remove(pSystems, player.boostEmitterIdx)
        player.boostEmitterIdx = 0
    end
end

function boostPlayer(player)

    if player.boostEmitterIdx == 0 then 
        -- create a new particle system
        local pEmitter = Sprinklez:createSystem(
            player.x * zoom_scale, 
            player.y * zoom_scale)
        
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

        -- Add to global list of systems    
        local idx = #pSystems + 1
        --https://stackoverflow.com/questions/25762102/table-insert-remember-key-of-inserted-value
        pSystems[idx] = pEmitter
        
        -- Remember pSystem index
        player.boostEmitterIdx = idx
    else
        -- update existing emitter
        local pEmitter = pSystems[player.boostEmitterIdx]
        pEmitter.lifetime = -1
        pEmitter.xpos = player.smoothX * zoom_scale - zoom_scale
        pEmitter.ypos = player.smoothY * zoom_scale - zoom_scale
    end

    -- TODO: Delete "dead" systems!!
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
        -- TODO: Check this, coz it SEEMS wrong/bloated!
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

    -- Boost effect?
    -- if player.boost then
    --     rectfill(
    --         player.smoothX*draw_zoom_scale-draw_zoom_scale, player.smoothY*draw_zoom_scale-draw_zoom_scale,
    --         (player.smoothX*draw_zoom_scale)+draw_zoom_scale+draw_zoom_scale, (player.smoothY*draw_zoom_scale)+draw_zoom_scale+draw_zoom_scale, 1)
        
    --     -- particles
    --     local px = (player.smoothX + rnd(6+draw_zoom_scale)-1.5-draw_zoom_scale)*draw_zoom_scale
    --     local py = (player.smoothY + rnd(6+draw_zoom_scale)-1.5-draw_zoom_scale)*draw_zoom_scale
    --     local colNum=irnd(#ak54Paired)
    --     rectfill(px, py, px+draw_zoom_scale/2, py+draw_zoom_scale/2, ak54Paired[colNum]) 
    -- end
end

return Player