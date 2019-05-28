print("server start...")


local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/b94c77cacc9e842877e7d8dd71c17792bd8cbc32/cs.lua'
--local cs = require("network/cs")

require("player")
require("level")

local server = cs.server
local frameTime = 0
local FPS = 60

local IS_SERVER = true
SUGAR_SERVER_MODE = USE_CASTLE_CONFIG --true
-- Sugarcoat alias
log = print

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

local serverPrivate = share --{}   -- Data private to the server

function server.connect(id) -- Called on connect from client with `id`
    log('client ' .. id .. ' connected')

    local newPlayer = { id = id }
    log("server reset")
    resetPlayer(newPlayer, share, IS_SERVER)
    -- tell client start pos
    server.send(id, "player_start", newPlayer.xDir, newPlayer.yDir, newPlayer.x, newPlayer.y, 
                 newPlayer.col)
    
    share.players[id] = newPlayer
end

function server.disconnect(id) -- Called on disconnect from client with `id`
    log('client ' .. id .. ' disconnected')
    
    killPlayer(share.players[id], serverPrivate.level, share, id, true)
    share.players[id]=nil
end

function server.receive(id, ...) -- Called when client with `id` does `client.send(...)`
    -- Doing it this way to reduce latency with player movement
    local arg = {...}
    local player = share.players[id]
    local msg = arg[1]
    log("server msg = "..msg.."(id="..id..")")

    if msg == "player_update" then
        player.xDir = arg[2]
        player.yDir = arg[3]
        player.x = arg[4]
        player.y = arg[5]
        -- Now record player pos-change
        addWaypoint(player)

    elseif msg == "player_dead" then
        local killedBy = arg[2]
        killPlayer(player, serverPrivate.level, share, killedBy, true)

        -- TODO: Stagger this after a cooldown!
        --resetPlayer(player, share, IS_SERVER)        
        -- tell client start pos
        --server.send(id, "player_start", player.xDir, player.yDir, player.x, player.y, player.col)
    end
end


-- Server only gets `.load`, `.update`, `.quit` Love events (also `.lowmemory` and `.threaderror`
-- which are less commonly used)

function server.load()
    log("server load...")
    
    -- create level
    serverPrivate.level = createLevel(1, 512, IS_SERVER) --game size (square)
    share.levelSize = serverPrivate.level.levelSize
    -- create players
    share.players = {}
end

function server.update(dt)
    -- Is it time to update the 'frame' of the game yet?
    frameTime = frameTime + dt
    if frameTime < 1/FPS then
        -- bail out now, not time to update yet
        return
    end
    -- Must be time to do update
    frameTime = frameTime - (1/FPS)

    -- Player info
    for clientId, player in pairs(share.players) do
        player.me = homes[clientId].me
    end

    -- Go through all players and update level grid, 
    -- based on their direction/state for this frame
    for id, home in pairs(server.homes) do
        -- Current player
        local player = share.players[id]

        if player and not player.dead then
            -- update with latest position
            -- (if not too big a change - else rely on server value
            --  as could be after a player restart and still getting old player pos msg)
            -- IDEA: maybe have a "lifecount" to check against!
            if home.x 
            and math.abs(player.x-home.x)<10
            and math.abs(player.y-home.y)<10
            then
                player.x = home.x
                player.y = home.y
            end

            -- Have to do this on the server,
            -- as it's a collation of all player trails
            -- (but also doing it at )
            updateLevelGrid(share.players[id], share.level)

            -- -- Check for deaths
            -- if player.dead then
            --     -- Reset player
            --     resetPlayer(player, share)
            -- end
        elseif player.dead 
         and (love.timer.getTime()-player.killedAt) >= 3 then
            -- Respawn player
            resetPlayer(player, share, IS_SERVER)        
            -- tell client start pos
            server.send(id, "player_start", player.xDir, player.yDir, player.x, player.y, player.col)

        end
    end

end
