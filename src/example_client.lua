local cs = require 'src/network/cs'
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


--local player = nil

function client.connect() -- Called on connect from server

    -- Initialise Player state
    -- home.xDir = 0
    -- home.yDir = 0
    -- Grab Player info (photo)
    home.me = castle.user.getMe and castle.user.getMe()
end

function client.disconnect() -- Called on disconnect from server
end

function client.receive(...) -- Called when server does `server.send(id, ...)` with our `id`
end


-- Client gets all Love events

function client.load()
    -- initialise and update the gfx display
    gfx:init()
    gfx:updateDisplay()

end

function client.update(dt)
    if client.connected then

        -- update player (controls)
        -- local player = home
        -- updatePlayer(player)
        --if player ~= nil then player:update() end

        -- -- keyboard controls
        -- if love.keyboard.isDown("right") then
        --     home.x = home.x + 1
        -- end
        -- if love.keyboard.isDown("left") then
        --     home.x = home.x - 1
        -- end
        -- if love.keyboard.isDown("up") then
        --     home.y = home.y - 1
        -- end
        -- if love.keyboard.isDown("down") then
        --     home.y = home.y + 1
        -- end

        --home.x,home.y = 20,20
        --home.mouse.x, home.mouse.y = love.mouse.getPosition()
    end
end

function client.draw()

    -- Setup the drawing to canvas, etc.
    gfx:preRender()

    love.graphics.clear({0,0,0.1})
        
    if client.connected then
        -- Draw whole level
        drawLevel(share.levelSize, share.players)

        -- Draw our own mouse in a special way (bigger radius)
        --love.graphics.circle('fill', home.mouse.x, home.mouse.y, 40, 40)

        -- Draw other mice
        -- for id, mouse in pairs(share.mice) do
        --     if id ~= client.id then -- Only draw others' mice this way
        --         love.graphics.circle('fill', mouse.x, mouse.y, 30, 30)
        --     end
        -- end
    end
    
    drawUI(share.players)

        
  --  else
  --      love.graphics.print('not connected', 2, 2)
  --  end

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
                    love.graphics.setColor(player.col)
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
    -- if key=="d" then
    --     constants.DEBUG_MODE = not constants.DEBUG_MODE
    -- end

    --updatePlayer(home, key)d

    local xDir = 0
    local yDir = 0
    -- keyboard controls
    if key == "right" then
        xDir = 1
        yDir = 0
    end
    if key == "left" then
        xDir = -1
        yDir = 0
    end
    if key == "up" then
        xDir = 0
        yDir = -1
    end
    if key == "down" then
        xDir = 0
        yDir = 1
    end
    if key == "space" then
        xDir = 0
        yDir = 0
    end
    
    -- test to try to reduce latency
    -- (Sends the player's input directly to server
    --  seems a *bit* faster/more responsive)
    client.send(xDir, yDir)

end

-- Force recalc of render dimensions on resize
-- (especially on Fullscreen switch)
function love.resize(w,h)
    gfx:updateDisplay()
end