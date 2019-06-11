
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
            end
        end

        player.smoothX = 0
        player.smoothY = 0
    
        log("clear the player grid data...")

        -- clear player's data from grid
        for r = 1,level.levelSize do
            for c = 1,level.levelSize do
                if level.grid[c][r] == player.id then
                    level.grid[c][r] = 0
                end
            end
        end

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
        repeat 
            player.x = math.random(share.levelSize-1)
            player.y = math.random(share.levelSize-1)
            player.gridX = player.x
            player.gridY = player.y
            player.lastGridX = player.gridX
            player.lastGridY = player.gridY
            player.speed = PLAYER_START_SPEED
            -- check we're in the "safe" zone
            local r, g, b = levelData:getPixel(player.x, player.y)
            local hitObstacle = r > 0 -- red means level obstacles/boundary
            local inSafeZone = g > 0 -- red means level obstacles/boundary
        until (not hitObstacle) and inSafeZone --or (levelData==nil)

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


function drawPlayer(player, draw_zoom_scale)
    local lastPoint = player.waypoints[1]

    -- Bail out if no colours
    if player.col==nil then 
        log("no col !!")
        return 
    end

    -- Bail out if no colours
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
    local x, y = player.gridX, player.gridY
    if not player.smoothX then
        player.smoothX = player.gridX
    end
    if not player.smoothY then
        player.smoothY = player.gridY
    end
    
    -- only apply smoothing to OTHER players, not us
    if player.id ~= client.id then
        player.smoothX = player.smoothX + 0.4 * (player.gridX - player.smoothX)
        player.smoothY = player.smoothY + 0.4 * (player.gridY - player.smoothY)
        player.smoothX = player.smoothX + 0.2 * (x - player.smoothX)
        player.smoothY = player.smoothY + 0.2 * (y - player.smoothY)
    else
        player.smoothX = player.gridX
        player.smoothY = player.gridY
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