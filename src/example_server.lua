local cs = require 'network/cs'
local server = cs.server

require 'level'
--local Level = require 'level'


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

    local newPlayer = {}
    -- Start at a random position
    newPlayer.x = math.random(share.level.levelSize)
    newPlayer.y = math.random(share.level.levelSize/2)
    share.players[id] = newPlayer
end

function server.disconnect(id) -- Called on disconnect from client with `id`
    print('client ' .. id .. ' disconnected')
    
    share.players[id]=nil
    --share.mice[id] = nil
end

function server.receive(id, ...) -- Called when client with `id` does `client.send(...)`
end


-- Server only gets `.load`, `.update`, `.quit` Love events (also `.lowmemory` and `.threaderror`
-- which are less commonly used)

function server.load()
    -- create level
    share.level = Level:new(1,500)
    -- create players
    share.players = {}

    --share.mice = {}
end

function server.update(dt)
    -- TODO: Go through all players and update grid, based on their direction/state for this frame
    for id, home in pairs(server.homes) do
        --print("xtype="..type(home.xDir))
        if home.xDir then
            -- print("home.x="..home.x)
            -- print("home.y="..home.y)
            share.level:updatePlayer(share.players[id], home)
        end
    end

    -- for id, home in pairs(server.homes) do -- Combine mouse info from clients into share
    --     share.mice[id] = home.mouse
    -- end
end
