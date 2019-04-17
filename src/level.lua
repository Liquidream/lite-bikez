
--Level = {}

function createLevel(levelNum, levelSize)
    local level={
        levelSize = levelSize,
        grid = {}
    }

    -- TODO: Create new level "grid" for level specified

    for r = 1,levelSize do
        level.grid[r]={}
        for c = 1,levelSize do
            level.grid[r][c]=0
        end  
    end

    return level
end
    -- Store the new level grid
    -- o.grid = grid
    -- o.levelSize = levelSize
    
-- Update grid state, based on player pos/direction/state
function updateLevelPlayer(share, serverPlayer, level)
    -- Check for player input
    -- if clientHome.xDir 
    --  and clientHome.yDir
    --  and (clientHome.xDir ~= serverPlayer.lastClientXDir 
    --  or clientHome.yDir ~= serverPlayer.lastClientYDir)
    --  and (clientHome.xDir ~= 0 
    --   or clientHome.yDir ~= 0)
    --  then
    --     -- Update player direction
    --     serverPlayer.xDir = clientHome.xDir
    --     serverPlayer.yDir = clientHome.yDir
    --     -- Update cache of last player controls
    --     serverPlayer.lastClientXDir = clientHome.xDir
    --     serverPlayer.lastClientYDir = clientHome.yDir
    -- end

    -- Update player pos, based on direction
    serverPlayer.x = serverPlayer.x + serverPlayer.xDir
    serverPlayer.y = serverPlayer.y + serverPlayer.yDir

    -- Abort if player is stationary
    if serverPlayer.xDir == 0 and serverPlayer.yDir == 0 then
        print("Player not moving")
        return
    end

    -- Check if player has hit game boundary
    if serverPlayer.x < 1
     or serverPlayer.y < 1
     or serverPlayer.x > level.levelSize
     or serverPlayer.y > level.levelSize 
    then
        -- Player has hit boundary of game
        killPlayer(serverPlayer, share)
        return
    end
    
    -- Check player has hit another Player's trail
    if level.grid[serverPlayer.x][serverPlayer.y] > 0 then
        -- Player hit something (someone)
        killPlayer(serverPlayer, share)
        return
    end

    -- Valid movement
    level.grid[serverPlayer.x][serverPlayer.y] = id
end


function drawLevel(levelSize, players)
    if levelSize and players then
        -- draw the waypoints
        for id, player in pairs(players) do
            local lastPoint = player.waypoints[1]
            -- set colour
            love.graphics.setColor(player.col)
            -- draw path
            for _, point in pairs(player.waypoints) do
                love.graphics.line(
                    lastPoint.x, lastPoint.y,
                    point.x, point.y)
                -- remember
                lastPoint = point
            end
        end

        -- -- draw the whole grid
        -- for r = 1,level.levelSize do
        --     for c = 1,level.levelSize do
        --         if level.grid[c][r] > 0 then
        --             --actually draw particle
        --             love.graphics.setColor(players[level.grid[c][r]].col)
        --             --love.graphics.setColor({1,1,1})
        --             love.graphics.points(c,r)    
        --         end
        --     end  
        -- end
    end
end


--return Level;