local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/b94c77cacc9e842877e7d8dd71c17792bd8cbc32/cs.lua'
--local cs = require 'src/network/cs'
local gfx = require 'src/gfx'
require 'src/player'
require 'src/level'


local client = cs.client

if USE_CASTLE_CONFIG then
    client.useCastleConfig()
else
    client.enabled = true
    client.start('127.0.0.1:22122') -- IP address ('127.0.0.1' is same computer) and port of server
end


-- Client connects to server. It gets a unique `id` to identify it.
--
-- `client.share` represents the shared state that server can write to and any client can read from.
-- `client.home` represents the home for this client that only it can write to and only server can
-- read from. `client.id` is the `id` for this client (set once it connects).
--
-- Client can also send or receive individual messages to or from server.


local share = client.share -- Maps to `server.share` -- can read
local home = client.home -- Maps to `server.homes[id]` with our `id` -- can write

local homePlayer = home

local clientPrivate = {}


function client.connect() -- Called on connect from serverfo
    homePlayer.id = client.id

    -- home.col = serverPlayer.col
    --print("col type:"..type(homePlayer.col))
    
    -- Photo
    home.me = castle.user.getMe and castle.user.getMe()
end

function client.disconnect() -- Called on disconnect from server
end

function client.receive(...) -- Called when server does `server.send(id, ...)` with our `id`
     -- Doing it this way to reduce latency with player movement
     local arg = {...}
     local msg = arg[1]
     print("client receive msg = "..msg)

     if msg == "player_start" then
        print("client reset")        
        homePlayer.xDir = arg[2]
        homePlayer.yDir = arg[3]
        homePlayer.x = arg[4]
        homePlayer.y = arg[5]
        homePlayer.col1 = arg[6]
        homePlayer.col2 = arg[7]
        homePlayer.col3 = arg[8]
        --homePlayer.col= { arg[6][1], arg[6][2], arg[6][3] }
        -- print("-----------------")
        -- print(">>> ".. type(arg[6][1]))
        -- print(">>> ".. arg[6][2])
        -- print(">>> ".. arg[6][3])

        resetPlayer(homePlayer, share, false)

        clientPrivate.level=createLevel(1, 512) --game size (square)

        print("size="..clientPrivate.level.levelSize)

        -- if not USE_CASTLE_CONFIG then 
        --     -- Give player a fake ID when playing locally
        --     homePlayer.id=0
        -- end
        -- print("player id="..homePlayer.id)
     end

end


-- Client gets all Love events

function client.load()
    -- initialise and update the gfx display
    gfx:init()
    gfx:updateDisplay()

    -- default player to dead
    homePlayer.dead = true
end

function client.update(dt)
    
    -- if DEBUG_MODE then
    --     print(love.timer.getTime().." - player.dead="..tostring(homePlayer.dead))
    -- end

    if client.connected
     and not homePlayer.dead  then

        -- update player (controls)
        

        -- Check for deaths
        if not homePlayer.dead then
            home.x = homePlayer.x
            home.y = homePlayer.y
                 
            -- move player
            updatePlayerPos(homePlayer)

            -- Now check against local collisions 
            -- (e.g. have we hit ourselves - as that lag-free)
            checkLevelPlayer(share, homePlayer, clientPrivate.level)

            -- Now check against remote collisions
            -- (e.g. have we hit another player)
            checkLevelPlayer(share, homePlayer, share.level)

            -- Update local player grid status, for collisions
            -- (As can be a lag getting it from the server)
            updateLevelGrid(homePlayer, clientPrivate.level)

            if homePlayer.dead then
                -- tell the server we died
                client.send("player_dead")
            end
        end
    end
end

function client.draw()

    -- Setup the drawing to canvas, etc.
    gfx:preRender()

    love.graphics.clear({0,0,0.1})
        
    if client.connected then
        -- Draw whole level
        drawLevel(share.levelSize, share.players, homePlayer, share.level, clientPrivate.level)
    end
    
    drawUI(share.players)

    -- Draw the canvas to screen, scale and center
    gfx:postRender()
end

function drawUI(players)
    -- Draw UI (inc. Player info)
    
    -- Players    
    if players then
        local playerPos = 1
        local xoff=100
        for clientId, player in pairs(players) do
            -- Obtain photo
            if player.me then
                if not player.photoRequested then
                    player.photoRequested = true
                    network.async(function()
                        player.photo = love.graphics.newImage(player.me.photoUrl)
                    end)
                end
            end

            -- Draw photo
            if player.photo then
                local G=25
                local x=xoff+(playerPos-1)*(G+10)
                local y=2--gfx.GAME_HEIGHT-player.photo:getHeight()-5
                if player.photo then
                    love.graphics.setColor( { player.col1, player.col2, player.col3 } )
                    love.graphics.rectangle(
                        'fill',  x-2, y-2, 
                        G+4,G+4)
                    
                    love.graphics.setColor(1,1,1)
                    love.graphics.draw(
                        player.photo, 
                        x, y, 0, 
                        G / player.photo:getWidth(), G / player.photo:getHeight())
                else
                    love.graphics.circle('fill', x + 0.5 * G, y + 0.5 * G, 0.5 * G)
                    if isOwn then
                        love.graphics.setLineWidth(4)
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.circle('line', x + 0.5 * G, y + 0.5 * G, 0.5 * G - 2)
                    end
                end
            end
            playerPos = playerPos + 1
        end
    end

    if client.connected then
        -- Draw our ping
        love.graphics.setColor(1,1,1)
        love.graphics.print('ping: ' .. client.getPing(), 2, 2)
    else
        love.graphics.print('not connected', 2, 2)
    end
end


function love.keypressed( key, scancode, isrepeat )
    -- Debug switch
    if key=="d" then
        DEBUG_MODE = not DEBUG_MODE
        print("Debug mode: "..(DEBUG_MODE and "Enabled" or "Disabled"))
        return
    end

    --updatePlayer(home, key)

    if not homePlayer.dead then

        -- keyboard controls
        if key == "right" then
            homePlayer.xDir = 1
            homePlayer.yDir = 0
        end
        if key == "left" then
            homePlayer.xDir = -1
            homePlayer.yDir = 0
        end
        if key == "up" then
            homePlayer.xDir = 0
            homePlayer.yDir = -1
        end
        if key == "down" then
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
            print("send player update...")
            client.send("player_update", homePlayer.xDir, homePlayer.yDir, homePlayer.x, homePlayer.y)
        end

    end
    -- Remember
    homePlayer.last_xDir = homePlayer.xDir
    homePlayer.last_yDir = homePlayer.yDir
end

-- Force recalc of render dimensions on resize
-- (especially on Fullscreen switch)
function love.resize(w,h)
    gfx:updateDisplay()
end