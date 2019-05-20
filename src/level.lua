

function createLevel(levelNum, levelSize, IS_SERVER)
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

    if not IS_SERVER then
        -- Load level collision data
        -- TODO: This needs to be dynamic - based on current level
        local levelDataPath = "assets/level-1.png"

        network.async(function()
            load_png("leveldata", levelDataPath, nil, true)
            levelData = love.image.newImageData(levelDataPath)
        end)
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
        --log("Player not moving")
        return
    end

    -- Check if player has hit game boundary
    if player.x <= 1
     or player.y <= 1
     or player.x > level.levelSize-1
     or player.y > level.levelSize-1
    then
        -- Player has hit boundary of game
        killPlayer(player, level, share, false)
        return
    end
    
    -- Check if player has hit level object/boundary
    local r, g, b = levelData:getPixel(player.x, player.y)
    local hitObstacle = r > 0 -- red means level obstacles/boundary
    if hitObstacle then
        -- Player has hit obstacle/boundary of game
        killPlayer(player, level, share, false)
        return
    end

    -- Check player has hit another Player's trail
    if level.grid[player.x][player.y] > 0 then
        -- Player hit something (someone)
        killPlayer(player, level, share, false)
        return
    end

end


function drawLevel(levelSize, otherPlayers, homePlayer, level, homeLevel, draw_zoom_scale)
    
    -- draw entire level
    if levelData then 
        --spr_sheet("leveldata", 0,0, level.levelSize*draw_zoom_scale,level.levelSize*draw_zoom_scale)
        sugar.gfx.spritesheet("leveldata")

        -- draw fake-3d level

        -- calc fake 3d
        local xpos = camx + (GAME_WIDTH/2)
        local ypos = camy + (GAME_HEIGHT/2)
        local csx,csy = xpos, ypos
        local sf=1

        for i=1,10 do  
            local wx = level.levelSize * sf
            local wy = level.levelSize * sf

            local cmx,cmy = wx/2, wy/2
            
            local d3x = (csx-cmx) - ((xpos - (level.levelSize/2)) * sf)
            local d3y = (csy-cmy) - ((ypos - (level.levelSize/2)) * sf)

            sspr(0, 0, level.levelSize, level.levelSize, d3x,d3y, wx,wy)

            sf = sf + .04
            --sf*=1.03
        end

        -- for i=1,1.5,.01 do
        --     sspr(0, 0, level.levelSize, level.levelSize, 
        --         camx/i, camy/i, level.levelSize*draw_zoom_scale*i, level.levelSize*draw_zoom_scale*i)
        -- end
    end
    
    if levelSize and otherPlayers and homePlayer then
        -- draw the waypoints
        for id, player in pairs(otherPlayers) do
            -- for all other players
            if player.id ~= homePlayer.id
            and player.x
            and not player.dead then
                drawPlayer(player, draw_zoom_scale)
          end
        end

        -- now draw local player
        -- (done so that local movement is snappy)
        if not homePlayer.dead then
            drawPlayer(homePlayer, draw_zoom_scale)
        end

        -- DEBUG grid collision data!
        -- draw the whole grid
        if DEBUG_MODE then
            -- draw synced collision data
            for r = 1,level.levelSize do
                for c = 1,level.levelSize do
                    if level.grid[c][r] > 0 then
                        --actually draw "block"
                        local x=(c+1)*draw_zoom_scale
                        local y=(r+1)*draw_zoom_scale
                        rectfill(x,y, x+draw_zoom_scale, y+draw_zoom_scale, 12)
                        --pset(c+1,r+1, 12)
                    end
                end  
            end

             -- draw local collision data
             for r = 1,homeLevel.levelSize do
                for c = 1,homeLevel.levelSize do
                    if homeLevel.grid[c][r] > 0 then
                        --actually draw particle
                        --love.graphics.setColor({0,0.5,0})
                        --love.graphics.setColor(players[level.grid[c][r]].col)                        
                        --actually draw "block"
                        local x=(c+2)*draw_zoom_scale
                        local y=(r+2)*draw_zoom_scale
                        rectfill(x,y, x+draw_zoom_scale, y+draw_zoom_scale, 11)
                        --pset(c+1,r+1, 12)
                    end
                end  
            end
        end
    end
end


--return Level;