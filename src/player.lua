
require("common")


local MOVE_SPEED = 1

function killPlayer(player, level, share)
    -- 
    if (player ~= nil) then
        log("player DIED ("..(player.id or "<no id>")..")")
        player.dead = true

    --  if IS_SERVER then 
    
        log("clear the player grid data...")

        -- clear player's data form grid
        for r = 1,level.levelSize do
            for c = 1,level.levelSize do
                if level.grid[c][r] == player.id then
                    level.grid[c][r] = 0
                end
            end
        end

    --  end

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
        player.col = player.id + 1
    end

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
end


function drawPlayer(player)
    local lastPoint = player.waypoints[1]

    -- Bail out if no colours
    if player.col==nil then 
        log("no col !!")
        return 
    end

    -- set colour
    --love.graphics.setColor({ player.col1, player.col2, player.col3 })
    
    -- draw path
    for i=1,player.pointCount do
        local point = player.waypoints[i]
    --    log(">>> "..point.x..","..point.y)
        line(
            lastPoint.x, lastPoint.y,
            point.x, point.y, player.col)
        -- remember
        lastPoint = point
    end
    -- draw to player current pos
    line(
            lastPoint.x, lastPoint.y,
            player.x, player.y, player.col)

end

return Player