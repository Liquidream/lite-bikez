
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

   -- ### this seems to break the clearing of player sync data!
        -- Update score
        if IS_SERVER then
            player.score = math.max(player.score - 1, 0)
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
        local dirs={
            {1,0},{0,1},{-1,0},{0,-1}
        }
        local dir=math.random(4)
        player.xDir,player.yDir = dirs[dir][1],dirs[dir][2]
        player.x = math.random(share.levelSize)
        player.y = math.random(share.levelSize/2)
        -- col based on id
        player.col = player.id * 2
        player.col2 = player.id * 2 + 1
        --player.col = player.id + 1
    end

    -- smoothing out network lag
    player.smoothX = 0
    player.smoothY = 0


    log("player pos = "..player.x..","..player.y)

    -- Add starting waypoint
    addWaypoint(player)


    log("#player.waypoints "..#player.waypoints)
end

function addWaypoint(player)
    local point={        
        x=player.x,
        y=player.y,
    }
    log("addWaypoint("..(player.id or "<nil>")..") ="..point.x..","..point.y)
    player.pointCount = player.pointCount + 1
    player.waypoints[player.pointCount] = point
    player.smoothX = player.x
    player.smoothY = player.y
end


function drawPlayer(player, draw_zoom_scale)
    local lastPoint = player.waypoints[1]

    -- Bail out if no colours
    if player.col==nil then 
        log("no col !!")
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
    local x, y = player.x, player.y
    if not player.smoothX then
        player.smoothX = player.x
    end
    if not player.smoothY then
        player.smoothY = player.y
    end
    player.smoothX = player.smoothX + 0.4 * (player.x - player.smoothX)
    player.smoothY = player.smoothY + 0.4 * (player.y - player.smoothY)
    player.smoothX = player.smoothX + 0.2 * (x - player.smoothX)
    player.smoothY = player.smoothY + 0.2 * (y - player.smoothY)

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