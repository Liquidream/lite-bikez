
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
function updateLevelPlayer(level, serverPlayer, id, clientHome)

    -- Check for player input
    -- print("player.xDir="..clientHome.xDir)
    -- print("player.xDir="..clientHome.lastXDir)
    if clientHome.xDir 
     and clientHome.yDir
     and (clientHome.xDir ~= serverPlayer.lastClientXDir 
     or clientHome.yDir ~= serverPlayer.lastClientYDir)
     and (clientHome.xDir ~= 0 
      or clientHome.yDir ~= 0)
     then
        -- Update player direction
        serverPlayer.xDir = clientHome.xDir
        serverPlayer.yDir = clientHome.yDir
        -- Update cache of last player controls
        serverPlayer.lastClientXDir = clientHome.xDir
        serverPlayer.lastClientYDir = clientHome.yDir
    end

    -- Update player pos, based on direction
    serverPlayer.x = serverPlayer.x + serverPlayer.xDir
    serverPlayer.y = serverPlayer.y + serverPlayer.yDir

    --clientHome.xDir
    --clientHome.yDir
    
    -- print("x="..serverPlayer.x)
    -- print("y="..serverPlayer.y)

    -- Abort if player is stationary
    if clientHome.xDir == 0 and clientHome.yDir == 0 then
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
        killPlayer(serverPlayer)
        return
    end
    
    -- Check player has hit another Player's trail
    if level.grid[serverPlayer.x][serverPlayer.y] > 0 then
        -- Player hit something (someone)
        killPlayer(serverPlayer)
        return
    end

    -- Valid movement
    level.grid[serverPlayer.x][serverPlayer.y] = id
end


function drawLevel(level, players)
    if level.levelSize then
        -- draw the whole grid
        for r = 1,level.levelSize do
            for c = 1,level.levelSize do
                if level.grid[c][r] > 0 then
                    --actually draw particle
                    love.graphics.setColor(players[level.grid[c][r]].col)
                    --love.graphics.setColor({1,1,1})
                    love.graphics.points(c,r)    
                end
            end  
        end
    end
end


--return Level;