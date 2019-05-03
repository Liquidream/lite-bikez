

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
-- (used for Server AND Local copies)
function updateLevelGrid(player, level)
    if #player.waypoints == 0 then
        return
    end
    
    --local level = share.level
    local lastPoint_x = player.waypoints[#player.waypoints].x
    local lastPoint_y = player.waypoints[#player.waypoints].y
    
    -- Bail out now if not enought data yet
    if (lastPoint_x==nil) then return end
    
    while lastPoint_x ~= player.x 
    or lastPoint_y ~= player.y do 
        
        if lastPoint_x ~= player.x then
            local dx=lastPoint_x-player.x
            dx=dx/math.abs(dx)
            lastPoint_x = lastPoint_x-dx
        end

        if lastPoint_y ~= player.y then
            local dy=lastPoint_y-player.y
            dy=dy/math.abs(dy)
            lastPoint_y = lastPoint_y-dy
        end

        -- Valid movement
        level.grid[lastPoint_x][lastPoint_y] = player.id
    end
end

-- Update player pos/direction/state
function updatePlayerPos(player)
    
    --local level = share.level

    -- abort if no position given yet
    if player.x == nil then
        return
    end

    -- Update player pos, based on direction
    player.x = player.x + player.xDir
    player.y = player.y + player.yDir
end

-- Update player pos/direction/state
function checkLevelPlayer(share, player, level)
    
    -- Abort if player is stationary
    if player.xDir == 0 and player.yDir == 0 then
        print("Player not moving")
        return
    end

    -- Check if player has hit game boundary
    if player.x <= 1
     or player.y <= 1
     or player.x > level.levelSize-1
     or player.y > level.levelSize-1
    then
        -- Player has hit boundary of game
        killPlayer(player, level, share)
        return
    end
    
    -- Check player has hit another Player's trail
    if level.grid[player.x][player.y] > 0 then
        -- Player hit something (someone)
        killPlayer(player, level, share)
        return
    end

end


function drawLevel(levelSize, otherPlayers, homePlayer, level, homeLevel)
    
    if levelSize and otherPlayers and homePlayer then
        -- draw the waypoints
        for id, player in pairs(otherPlayers) do
            -- for all other players
            if player.id ~= homePlayer.id
            and player.x
            and not player.dead then
                drawPlayer(player)
          end
        end

        -- now draw local player
        -- (done so that local movement is snappy)
        if not homePlayer.dead then
            drawPlayer(homePlayer)
        end

        -- DEBUG grid collision data!
        -- draw the whole grid
        if DEBUG_MODE then
            -- draw synced collision data
            for r = 1,level.levelSize do
                for c = 1,level.levelSize do
                    if level.grid[c][r] > 0 then
                        --actually draw particle
                        love.graphics.setColor({0,0,1})
                        --love.graphics.setColor(players[level.grid[c][r]].col)                        
                        love.graphics.points(c+1,r+1)    
                    end
                end  
            end

             -- draw local collision data
             for r = 1,homeLevel.levelSize do
                for c = 1,homeLevel.levelSize do
                    if homeLevel.grid[c][r] > 0 then
                        --actually draw particle
                        love.graphics.setColor({0,0.5,0})
                        --love.graphics.setColor(players[level.grid[c][r]].col)                        
                        love.graphics.points(c+1,r+1)    
                    end
                end  
            end
        end
    end
end


--return Level;