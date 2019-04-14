local cs = require("src/network/cs")
require("src/player")
require("src/level")

local server = cs.server
local frameTime = 0
local FPS = 60

if USE_CASTLE_CONFIG then
    server.useCastleConfig()
else
    server.enabled = true
    server.start('22122') -- Port of server
end


-- Server has many clients connecting to it. Each client has a unique `id` to identify it.
--
-- `server.share` represents shared state that the server can write to and all clients can read
-- from. `server.homes[id]` each represents state that the server can read from and client with
-- that `id` can write to (clients can't see each other's homes). Thus the server gets data
-- from each client and combines them for all clients to see.
--
-- Server can also send or receive individual messages to or from any client.


local share = server.share -- Maps to `client.share` -- can write
local homes = server.homes -- `homes[id]` maps to `client.home` for that `id` -- can read


function server.connect(id) -- Called on connect from client with `id`
    print('client ' .. id .. ' connected')

    local newPlayer = { id = id }
    resetPlayer(newPlayer, share)
    
    share.players[id] = newPlayer
end

function server.disconnect(id) -- Called on disconnect from client with `id`
    print('client ' .. id .. ' disconnected')
    
    killPlayer(share.players[id], share)
    share.players[id]=nil
    --share.mice[id] = nil
end

function server.receive(id, ...) -- Called when client with `id` does `client.send(...)`
end


-- Server only gets `.load`, `.update`, `.quit` Love events (also `.lowmemory` and `.threaderror`
-- which are less commonly used)

function server.load()
    -- create level
    share.level = createLevel(1, 512) --game size (square)
    -- create players
    share.players = {}

    --share.mice = {}
end

function server.update(dt)
    -- Is it time to update the 'frame' of the game yet?
    frameTime = frameTime + dt
    print(frameTime)
    if frameTime < 1/FPS then
        -- bail out now, not time to update yet
        return
    end
    -- Must be time to do update
    frameTime = frameTime - FPS
    print("UPDATE!")

    -- Player info
    for clientId, player in pairs(share.players) do
        player.me = homes[clientId].me
    end

    -- Go through all players and update level grid, 
    -- based on their direction/state for this frame
    for id, home in pairs(server.homes) do
        -- Current player
        local player = share.players[id]

        if not player.dead 
            --and home.xDir
        then
            -- print("home.x="..home.x)
            -- print("home.y="..home.y)
            updateLevelPlayer(share, id, home)
            -- Check for deaths
            if player.dead then
                -- Reset player
                resetPlayer(player, share)
            end
        end
    end

    -- for id, home in pairs(server.homes) do -- Combine mouse info from clients into share
    --     share.mice[id] = home.mouse
    -- end
end
