
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
    -- Update player pos, based on direction
    serverPlayer.x = serverPlayer.x + clientHome.xDir
    serverPlayer.y = serverPlayer.y + clientHome.yDir

    -- print("x="..playerShare.x)
    -- print("y="..playerShare.y)

    level.grid[serverPlayer.x][serverPlayer.y] = id

    -- print("home.x="..home.x)
    -- print("home.y="..home.y)
    -- print("grid size="..#self.grid)
    --self.grid[home.x][home.y] = 1
end


function drawLevel(share)
    if share.level.levelSize then
        -- draw the whole grid
        for r = 1,share.level.levelSize do
            for c = 1,share.level.levelSize do
                if share.level.grid[c][r] > 0 then
                    --actually draw particle
                    love.graphics.setColor(share.players[share.level.grid[c][r]].col)
                    --love.graphics.setColor({1,1,1})
                    love.graphics.points(c,r)    
                end
            end  
        end
    end
end


--return Level;