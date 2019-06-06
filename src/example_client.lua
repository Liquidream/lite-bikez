local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/b94c77cacc9e842877e7d8dd71c17792bd8cbc32/cs.lua'

--local gfx = require 'src/gfx'
require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)

local moonshine = require("moonshine")

require("common")
require("player")
require("level")
require("ui_input")

-- made client global so UI and others can use
client = cs.client

if USE_CASTLE_CONFIG then
    client.useCastleConfig()
else
    client.enabled = true
    client.start('127.0.0.1:22122') -- IP address ('127.0.0.1' is same computer) and port of server
end

local useShader = true

-- Client connects to server. It gets a unique `id` to identify it.
--
-- `client.share` represents the shared state that server can write to and any client can read from.
-- `client.home` represents the home for this client that only it can write to and only server can
-- read from. `client.id` is the `id` for this client (set once it connects).
--
-- Client can also send or receive individual messages to or from server.


local share = client.share  -- Maps to `server.share` -- can read
local home = client.home    -- Maps to `server.homes[id]` with our `id` -- can write
local homePlayer = home
local clientPrivate = {}    -- data private to the client (not synced)
local playerPhotos = {}
camx,camy = 0,0       -- made it global, so "level" can access
local zoom_scale = 2        -- 2


function client.connect() -- Called on connect from serverfo
    homePlayer.id = client.id

    -- home.col = serverPlayer.col
    --log("col type:"..type(homePlayer.col))
    
    -- Photo
    home.me = castle.user.getMe and castle.user.getMe()

    -- Name
    local parts = split(home.me.name," ")
    if #parts>0 then
        home.me.shortname = parts[1]
    else
        home.me.shortname = home.me.name
    end
end

function client.disconnect() -- Called on disconnect from server
end

function client.receive(...) -- Called when server does `server.send(id, ...)` with our `id`
     -- Doing it this way to reduce latency with player movement
     local arg = {...}
     local msg = arg[1]
     log("client receive msg = "..msg)

     if msg == "player_start" then
        log("client reset")        
        homePlayer.xDir = arg[2]
        homePlayer.yDir = arg[3]
        homePlayer.x = arg[4]
        homePlayer.y = arg[5]
        homePlayer.col = arg[6]
        
        log(">>> arg 7 = ".. arg[7])
        log(">>> arg 8 =".. arg[8])
        log(">>> arg 9 =".. arg[9])

        -- new level?
        if arg[7] ~= levelDataPath then
            -- level changed!
            levelName = arg[7]
            levelDataPath = arg[8]
            levelGfxPath = arg[9]

            log(">>> ".. levelDataPath)
            log(">>> ".. levelGfxPath)

            clientPrivate.level=createLevel(1, 512, false) --game size (square)
        end

        --homePlayer.col= { arg[6][1], arg[6][2], arg[6][3] }
        -- log("-----------------")
        -- log(">>> ".. type(arg[6][1]))
        -- log(">>> ".. arg[6][2])
        -- log(">>> ".. arg[6][3])

        resetPlayer(homePlayer, share, false)

        -- TODO: Review this, as only needs to be created once (on connection)
        if clientPrivate.level == nil then
            clientPrivate.level=createLevel(1, 512, false) --game size (square)
        end

        log("size="..clientPrivate.level.levelSize)

        -- if not USE_CASTLE_CONFIG then 
        --     -- Give player a fake ID when playing locally
        --     homePlayer.id=0
        -- end
        -- log("player id="..homePlayer.id)
     end

end

function sugar.after_render()    
    love.graphics.setScissor()
    local width, height = love.graphics.getDimensions()
    local sugar_w, sugar_h = rendercanvas:getDimensions()
    
    love.graphics.setCanvas()

    if fxShader then 
        fxShader(function()
            love.graphics.draw(rendercanvas,
                width/2 - sugar_w/2, 
                height/2 - sugar_h/2 )
        end)
    -- else
    --     love.graphics.draw(rendercanvas,
    --         width/2 - sugar_w/2, 
    --         height/2 - sugar_h/2 )
    end

end



local savedCanvas
function network.paused()
  savedCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas()
end

function network.resumed()
  love.graphics.setCanvas(savedCanvas)
end

function love.resize(w,h)
    log("hello, resizing")

    rendercanvas = love.graphics.newCanvas(w,h)
    render_to_canvas(rendercanvas)
    
   if useShader then
    fxShader = moonshine(
            moonshine.effects.glow)
            .chain(moonshine.effects.scanlines)
        -- 80's glow baby!
        fxShader.glow.strength = 5 --10
        fxShader.glow.min_luma = 0
        -- Bit of the ol' arcade too!
        fxShader.scanlines.opacity = 0.1
   end
end
  

-- Client gets all Love events

function client.load()

    -- Test for Nikki
    local width, height = love.graphics.getDimensions()
    log(">>>> Nikki: "..width..","..height)

    -- initialise and update the gfx display
    init_sugar("Lite Bikez", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)
    
    screen_render_stretch(false)
    screen_render_integer_scale(false)
    --screen_render_integer_scale(true)

    local sugar_w,sugar_h = screen_size()
    rendercanvas = love.graphics.newCanvas(width, height)
    render_to_canvas(rendercanvas)

    -- Moonshine
    if useShader then
        -- Initialise moonshine
        fxShader = moonshine(
            moonshine.effects.glow)
            .chain(moonshine.effects.scanlines)
        -- 80's glow baby!
        fxShader.glow.strength = 5 --10
        fxShader.glow.min_luma = 0
        -- Bit of the ol' arcade too!
        fxShader.scanlines.opacity = 0.1
    end

    set_frame_waiting(60)

    use_palette(ak54Paired)
    --use_palette(ak54)
    --use_palette(amstradCPC)
    --use_palette(palettes.pico8)
    --set_background_color(0)

    -- default player to dead
    homePlayer.dead = true

    log("Game initialized.")
end


function client.update(dt)
    
    -- if DEBUG_MODE then
    --     log(love.timer.getTime().." - player.dead="..tostring(homePlayer.dead))
    -- end

    if client.connected
     and not homePlayer.dead  then

        -- update player (controls)
        

        -- Check for deaths
        if not homePlayer.dead then
            home.x = homePlayer.x
            home.y = homePlayer.y
                 
            -- move player
            updatePlayerPos(homePlayer, dt)

            -- Now check against local collisions 
            -- (e.g. have we hit ourselves - as that lag-free)
            checkLevelPlayer(share, homePlayer, clientPrivate.level)

            -- Now check against remote collisions
            -- (e.g. have we hit another player)
            if not homePlayer.dead then
             -- NOTE: Can't reset the level data here
             -- (even though it'll try)
             -- Server will do it tho when receives "dead" message
             checkLevelPlayer(share, homePlayer, share.level)
            

             -- Update local player grid status, for collisions
             -- (As can be a lag getting it from the server)
             updateLevelGrid(homePlayer, clientPrivate.level)
            end

            if homePlayer.dead then
                -- tell the server we died
                client.send("player_dead", homePlayer.killedBy)
            end
        end
    end
end

function client.draw()
    -- Draw game to canvas/screen
    cls() --53
    --cls(1)

    
    if client.connected then
        -- Update camera pos
        local cam_edge=40
        camx = homePlayer.x - flr(GAME_WIDTH/(2*zoom_scale))
        camy = homePlayer.y - flr(GAME_HEIGHT/(2*zoom_scale))
        camx = mid(-cam_edge, camx, clientPrivate.level.levelSize-(GAME_WIDTH/zoom_scale)+cam_edge)
        camy = mid(-cam_edge, camy, clientPrivate.level.levelSize-(GAME_HEIGHT/zoom_scale)+cam_edge)
        camera(camx*zoom_scale, camy*zoom_scale)
        
        -- Draw whole level
        drawLevel(share.levelSize, share.players, homePlayer, share.level, clientPrivate.level, zoom_scale)
    end
    
    -- Reset camera for UI
    camera(0,0)
    drawUI(share.players)
end

function checkAndGetPlayerPhoto(playerId, photoUrl)
    if playerPhotos[playerId] == nil then
        -- go and download the player photo
        playerPhotos[playerId]="pending..."
        network.async(function()
            
            local key = "photo_"..playerId
            -- create a spritesheet/surface for player photo
            load_png(key, photoUrl)
                        
            -- ...and store reference to it
            playerPhotos[playerId] = key

        end)
    end
    -- else do nothing, as we already got it
end



function drawUI(players)
    -- Draw UI (inc. Player info)
    --pal()
    palt(0,false)
    
    -- Players    
    if players then
        local playerPos = 1
        local xoff=100
        for clientId, player in pairs(players) do
            -- Does player have a photo?
            if player.me 
             and player.me.photoUrl then               
                -- Go get the photo (if we haven't already)
                checkAndGetPlayerPhoto(player.id, player.me.photoUrl)
            end


            local G=25
            local x=xoff+(playerPos-1)*(G+10)
            local y=2
            --
            -- Draw photo (if we have one?)
            --
            if playerPhotos[player.id] ~= nil 
            and playerPhotos[player.id] ~= "pending..." then
                -- draw bg frame in player's colour
                rectfill(x-2, y-2, x+G+2, y+G+2, player.col)
                -- draw the actual photo
                sugar.gfx.spritesheet(playerPhotos[player.id])
                local w,h = sugar.gfx.surface_size(playerPhotos[player.id])
                sugar.gfx.sspr(0, 0, w, h, x, y,  G, G)
                -- draw a shortened version of player name (if longer than 1 chars)
                print(string.sub(player.me.shortname,1,8),
                        x+12-((#player.me.shortname/2)*7), G+6, 1)
                -- draw player score
                print(player.score, x+4, G+16, 1)
            else
                -- ...otherwise, draw a shape with player col
                love.graphics.circle('fill', x + 0.5 * G, y + 0.5 * G, 0.5 * G)
                if isOwn then
                    love.graphics.setLineWidth(4)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.circle('line', x + 0.5 * G, y + 0.5 * G, 0.5 * G - 2)
                end
            end
            


            playerPos = playerPos + 1
        end
    end

    if client.connected then
        -- Draw our ping
        --love.graphics.setColor(1,1,1)
        print('ping: ' .. client.getPing(), 2, 2, 51)
    else
        print('not connected', 2, 2, 24)
    end

    -- did we die?
    if homePlayer.dead and homePlayer.killedBy then
        -- display info about our "killer"
        print('YOU DIED', GAME_WIDTH/2, GAME_HEIGHT/2, 1)
        local msg = ""
        if homePlayer.killedBy > 0 then
            msg = share.players[homePlayer.killedBy].me.shortname.." squished you!"
        else
            msg = "You hit a wall!"
        end
        print(msg, GAME_WIDTH/2-(#msg/2*4), GAME_HEIGHT/2+20, 1)

    end

    print('FPS: ' .. love.timer.getFPS(), 10, GAME_HEIGHT-20, 51)


    -- reset trans again
    palt(0,true)
end


function love.keypressed( key, scancode, isrepeat )
    -- Debug switch
    if key=="d" and love.keyboard.isDown('lctrl') then
        DEBUG_MODE = not DEBUG_MODE
        log("Debug mode: "..(DEBUG_MODE and "Enabled" or "Disabled"))
        return
    end

    -- shader switch
    if key=="s" then
        useShader = not useShader
        log("Shader mode: "..(useShader and "Enabled" or "Disabled"))
        if useShader then 
            fxShader.enable("glow", "scanlines")
        else
            fxShader.disable("glow", "scanlines")
        end
        return
    end

    --updatePlayer(home, key)

    if not homePlayer.dead then

        -- keyboard controls
        if key == "right" 
         and (homePlayer.xDir ~= -1
         and homePlayer.yDir ~= 0) then
            homePlayer.xDir = 1
            homePlayer.yDir = 0
        end
        if key == "left" 
         and (homePlayer.xDir ~= 1
         and homePlayer.yDir ~= 0) then
            homePlayer.xDir = -1
            homePlayer.yDir = 0
        end
        if key == "up" 
         and (homePlayer.xDir ~= 0
         and homePlayer.yDir ~= 1) then
            homePlayer.xDir = 0
            homePlayer.yDir = -1
        end
        if key == "down" 
         and (homePlayer.xDir ~= 0
         and homePlayer.yDir ~= -1) then
            homePlayer.xDir = 0
            homePlayer.yDir = 1
        end

        -- DEBUG
        if DEBUG_MODE and key == "space" then
            homePlayer.xDir = 0
            homePlayer.yDir = 0
        end


        if homePlayer.xDir ~= homePlayer.last_xDir
        and homePlayer.yDir ~= homePlayer.last_yDir then
            -- Now record player pos-change
            addWaypoint(homePlayer)

            -- test to try to reduce latency
            -- (Sends the player's input DIRECTLY to server
            --  seems a *bit* faster/more responsive)
            log("send player update...")
            client.send("player_update", homePlayer.xDir, homePlayer.yDir, homePlayer.x, homePlayer.y)
        end

    end
    -- Remember
    homePlayer.last_xDir = homePlayer.xDir
    homePlayer.last_yDir = homePlayer.yDir
end
