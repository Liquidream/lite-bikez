
require("common")

-- defaults
levelName = LEVEL_LIST[1]
levelDataPath = LEVEL_DATA_LIST[levelName].imgData
levelGfxPaths = LEVEL_DATA_LIST[levelName].imgGfxList

function createLevel(levelNum, levelSize, IS_SERVER)
    log("createLevel()... IS_SERVER="..tostring(IS_SERVER))
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
    
    network.async(function()            
        -- load level collision data (Client AND Server)
        -- TODO: This needs to be dynamic - based on current level
        log("loading level collision data...")
        --local levelDataPath = "assets/level-1-data.png"
        levelData = love.image.newImageData(levelDataPath)

        if not IS_SERVER then
            -- load drawing data
            log("loading level asset images...")
            load_png("levelgfx-bg", "assets/level-1-bg.png", nil, true)
            for i=1,#levelGfxPaths do
                load_png("levelgfx-"..i, levelGfxPaths[i], nil, true)
            end
            log("done loading level asset images.")
        end
    end)
    

    return level
end
    
-- Update grid state, based on player pos/direction/state
-- (used for Server AND Local copies)
function updateLevelGrid(player, level)
    if #player.waypoints == 0 then
        log("no waypoints yet")
        return
    end
    
    --local level = share.level
    local lastPoint_x = player.waypoints[#player.waypoints].x
    local lastPoint_y = player.waypoints[#player.waypoints].y
    
    -- Bail out now if not enought data yet
    if (lastPoint_x==nil) then return end
    
    while lastPoint_x ~= player.gridX 
    or lastPoint_y ~= player.gridY do 
        
        if lastPoint_x ~= player.gridX then
            local dx=lastPoint_x-player.gridX
            dx=dx/math.abs(dx)
            lastPoint_x = lastPoint_x-dx
        end

        if lastPoint_y ~= player.gridY then
            local dy=lastPoint_y-player.gridY
            dy=dy/math.abs(dy)
            lastPoint_y = lastPoint_y-dy
        end

        -- Valid movement
        level.grid[lastPoint_x][lastPoint_y] = player.id
    end
end

function remove_player_from_grid(level, player)
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

-- Update player pos/direction/state
function updatePlayerPos(player, dt)
    -- remember last pos
    player.lastGridX = player.gridX
    player.lastGridY = player.gridY

    --local level = share.level

    -- abort if no position given yet
    if player.x == nil then
        return
    end

    -- check for "SPEED" boost
    player.boost = false
    if love.keyboard.isDown("space") then
        -- Boost pressed
        player.boostCount = player.boostCount+1
        if player.boostCount < PLAYER_MAX_BOOST then
            player.boost = true
        end
    end

    -- Boost comedown
    if not player.boost then
        player.boostCount = math.max(player.boostCount-1, 0)
    end

    -- Apply acceleration
    local targetSpeed = player.boost and (PLAYER_NORM_SPEED * 1.5) or PLAYER_NORM_SPEED
    player.speed = player.speed + ((player.speed < targetSpeed) and 1 or -1)

    -- Update player pos, based on direction
    -- player.diff_x = lerp(player.diff_x, 0, (0.01) * 10 * dt)
    -- player.diff_y = lerp(player.diff_y, 0, (0.01) * 10 * dt)
    
    player.x = player.x + player.xDir * dt * player.speed
    player.y = player.y + player.yDir * dt * player.speed
    player.gridX = math.floor(player.x + 0.5)
    player.gridY = math.floor(player.y + 0.5)    
end

-- Update player pos/direction/state
function checkLevelPlayer(share, player, level)
    
    local lastPoint_x = player.lastGridX
    local lastPoint_y = player.lastGridY 

    -- log(">player pos = "..tostring(player.x)..","..tostring(player.y))
    -- log(">player gridpos = "..tostring(player.gridX)..","..tostring(player.gridY))
    -- log(">player lastpoint = "..tostring(lastPoint_x)..","..tostring(lastPoint_y))

    -- Abort if player is hasn't moved pos since last time
    if lastPoint_x == player.gridX 
        and lastPoint_y == player.gridY then
        -- log("No change in player pos, aborting check")
        return
    end

    -- Check if player has hit game boundary
    if player.x <= 1
     or player.y <= 1
     or player.x > level.levelSize-1
     or player.y > level.levelSize-1
    then
        -- Player has hit boundary of game
        killPlayer(player, level, share, -1, false)
        return
    end

    -- now check, pixel by pixel, from player's last known pos
    
    -- Bail out now if not enought data yet
    if (lastPoint_x==nil) then return end
    while lastPoint_x ~= player.gridX 
    or lastPoint_y ~= player.gridY do 
        
        if lastPoint_x ~= player.gridX then
            local dx=lastPoint_x-player.gridX
            dx=dx/math.abs(dx)
            lastPoint_x = lastPoint_x-dx
        end

        if lastPoint_y ~= player.gridY then
            local dy=lastPoint_y-player.gridY
            dy=dy/math.abs(dy)
            lastPoint_y = lastPoint_y-dy
        end

        -- Valid movement
        --level.grid[lastPoint_x][lastPoint_y] = player.id

        -- Check if player has hit level object/boundary
        local r, g, b = levelData:getPixel(lastPoint_x, lastPoint_y)
        local hitObstacle = r > 0 -- red means level obstacles/boundary
        if hitObstacle then
            -- Player has hit obstacle/boundary of game
            killPlayer(player, level, share, -1, false)
            return
        end
    
        -- Check player has hit another Player's trail
        local blockOwner = level.grid[lastPoint_x][lastPoint_y]
        if blockOwner > 0 then
            -- Player hit something (someone)
            log("test > "..type(blockOwner))
            log("test > "..blockOwner)
            killPlayer(player, level, share, blockOwner, false)
            return
        else
            --log("<empty grid cell>")
        end
    end
    

end


function drawBG(levelSize, draw_zoom_scale)    
    -- draw background gfx
    spr_sheet("levelgfx-bg", 0,0, levelSize*draw_zoom_scale,levelSize*draw_zoom_scale)
end

function drawLevel(levelSize, otherPlayers, homePlayer, level, homeLevel, draw_zoom_scale)
    
    -- draw background gfx
    drawBG(levelSize, draw_zoom_scale)
    --spr_sheet("levelgfx-bg", 0,0, level.levelSize*draw_zoom_scale,level.levelSize*draw_zoom_scale)
       
    -- draw players
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
                        rectfill(x,y, x+draw_zoom_scale, y+draw_zoom_scale, level.grid[c][r])
                        --pset(c+1,r+1, 12)
                    end
                end  
            end

             -- draw local collision data
             for r = 1,homeLevel.levelSize do
                for c = 1,homeLevel.levelSize do
                    if homeLevel.grid[c][r] > 0 then                   
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


    -- Draw all particle systems    
    for index, psys in pairs(boostParticles) do
        psys:draw()
    end
    for index, psys in pairs(deathParticles) do
        psys:draw()
    end


     -- draw entire level in fake-3d
     local layerNum = 1
     if levelData then
        -- calc fake 3d
        local xpos = camx*draw_zoom_scale + (GAME_WIDTH /2) 
        local ypos = camy*draw_zoom_scale + (GAME_HEIGHT /2)
        local csx,csy = xpos, ypos
        local sf=1

        --log("draw 3d level ----------------------------")

        for i=1,10 do  
            local wx = level.levelSize * sf
            local wy = level.levelSize * sf

            local cmx,cmy = wx/2, wy/2
            
            local d3x = (csx-cmx) - ((xpos - (level.levelSize/2)) * sf)
            local d3y = (csy-cmy) - ((ypos - (level.levelSize/2)) * sf)

            --log("i="..i)

            -- switch sprite (if necessary)
            if (i-1>0 and (i-1)%3==0 and #levelGfxPaths > layerNum) then 
                layerNum=layerNum + 1 
                --log("layer increase to:"..layerNum)
            end
            if (get_spritesheet() ~= "levelgfx-"..layerNum) then
                sugar.gfx.spritesheet("levelgfx-"..layerNum)
            end
            sspr(0, 0, level.levelSize, level.levelSize, d3x,d3y, wx*draw_zoom_scale, wy*draw_zoom_scale)

            sf = sf + .06
        end
    end
    
end


--return Level;