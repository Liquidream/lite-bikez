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
end

function server.disconnect(id) -- Called on disconnect from client with `id`
    print('client ' .. id .. ' disconnected')
    --share.mice[id] = nil
end

function server.receive(id, ...) -- Called when client with `id` does `client.send(...)`
end


-- Server only gets `.load`, `.update`, `.quit` Love events (also `.lowmemory` and `.threaderror`
-- which are less commonly used)

function server.load()
    -- create level
    share.level = Level:new(1,500)

    --share.mice = {}
end

function server.update(dt)
    -- TODO: Go through all players and update grid, based on their direction/state for this frame
    for id, home in pairs(server.homes) do -- Combine mouse info from clients into share
        if home.x then
            -- print("home.x="..home.x)
            -- print("home.y="..home.y)
            share.level:updatePlayer(home)
        end
    end

    -- for id, home in pairs(server.homes) do -- Combine mouse info from clients into share
    --     share.mice[id] = home.mouse
    -- end
end
