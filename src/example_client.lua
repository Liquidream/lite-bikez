local cs = require 'network/cs'
local gfx = require 'gfx'

local client = cs.client

if USE_CASTLE_CONFIG then
    client.useCastleConfig()
else
    client.enabled = true
    client.start('127.0.0.1:22122') -- IP address ('127.0.0.1' is same computer) and port of server
end

require 'level'

-- Client connects to server. It gets a unique `id` to identify it.
--
-- `client.share` represents the shared state that server can write to and any client can read from.
-- `client.home` represents the home for this client that only it can write to and only server can
-- read from. `client.id` is the `id` for this client (set once it connects).
--
-- Client can also send or receive individual messages to or from server.


local share = client.share -- Maps to `server.share` -- can read
local home = client.home -- Maps to `server.homes[id]` with our `id` -- can write


function client.connect() -- Called on connect from server

    
    -- Start at a random position
    home.x = math.random(share.level.levelSize)  -- TODO: Base this on grid size!
    home.y = math.random(share.level.levelSize)

    print("home.x="..home.x)
    print("home.y="..home.y)
    
    -- home.mouse = {}
    -- home.mouse.x, home.mouse.y = love.mouse.getPosition()
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
        -- keyboard controls
        if love.keyboard.isDown("right") then
            home.x = home.x + 1
        end
        if love.keyboard.isDown("left") then
            home.x = home.x - 1
        end
        if love.keyboard.isDown("up") then
            home.y = home.y - 1
        end
        if love.keyboard.isDown("down") then
            home.y = home.y + 1
        end

        --home.x,home.y = 20,20
        --home.mouse.x, home.mouse.y = love.mouse.getPosition()
    end
end

function client.draw()

    -- Setup the drawing to canvas, etc.
    gfx:preRender()

    if client.connected then
        -- Draw whole level
        love.graphics.clear()
        Level.draw(share)

        -- Draw our own mouse in a special way (bigger radius)
        --love.graphics.circle('fill', home.mouse.x, home.mouse.y, 40, 40)

        -- Draw other mice
        -- for id, mouse in pairs(share.mice) do
        --     if id ~= client.id then -- Only draw others' mice this way
        --         love.graphics.circle('fill', mouse.x, mouse.y, 30, 30)
        --     end
        -- end

        -- Draw our ping
        love.graphics.print('ping: ' .. client.getPing(), 2, 2)
    else
        love.graphics.print('not connected', 2, 2)
    end

    -- Draw the canvas to screen, scale and center
    gfx:postRender()
end

-- Force recalc of render dimensions on resize
-- (especially on Fullscreen switch)
function love.resize(w,h)
    gfx:updateDisplay()
end