print("server start...")

-- updated ver with player info for each Castle multiplayer session
local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/b94c77cacc9e842877e7d8dd71c17792bd8cbc32/cs.lua'
-- prev ver
--local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/b94c77cacc9e842877e7d8dd71c17792bd8cbc32/cs.lua'

require("player")
require("level")

local server = cs.server
local frameTime = 0
local FPS = 60

SUGAR_SERVER_MODE = true
-- Sugarcoat alias
log = print

if castle then
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
end

function server.disconnect(id) -- Called on disconnect from client with `id`
    log('client ' .. id .. ' disconnected')
    
    
    killPlayer(share.players[id], serverPrivate.level, share, id, true)
    
    -- announce player left
    createMessage(share, share.players[id].me.shortname.." left the game", 
                    37, { id, id })

    share.players[id]=nil
end

function server.receive(id, ...) -- Called when client with `id` does `client.send(...)`
    -- Doing it this way to reduce latency with player movement
    local arg = {...}
    local player = share.players[id]
    local msg = arg[1]
    log("server msg = "..msg.."(id="..id..")")

    if msg == "player_ready" then        
        local newPlayer = { 
            id = id,
            score = 0,
            announce = false
        }
        log("server player reset")
        resetPlayer(newPlayer, share, true)
        -- tell client start pos
        server.send(id, "player_start", 
            newPlayer.xDir, newPlayer.yDir, 
            newPlayer.x, newPlayer.y, newPlayer.col,
            serverPrivate.levelName, levelDataPath, levelGfxPaths)        
        share.players[id] = newPlayer

    elseif msg == "player_update" then
        player.xDir = arg[2]
        player.yDir = arg[3]
        player.x = arg[4]
        player.y = arg[5]
        player.gridX = arg[6]
        player.gridY = arg[7]
        -- Now record player pos-change
        addWaypoint(player)

    elseif msg == "player_dead" then
        local killedBy = arg[2]
        killPlayer(player, serverPrivate.level, share, killedBy, true)
    
    elseif msg == "level_vote" then
        log("server: vote received")
        -- player voted to change level
        log("levelName = "..arg[2])
        log("levelDataPath = "..arg[3])
        log("#levelGfxPaths = "..#arg[4])

        local levelName = arg[2]
        local levelDataPath = arg[3]
        local levelGfxPaths = arg[4]
        -- cast vote
        player.vote = levelName

        -- announce it
        createMessage(share, player.me.shortname.." voted to change", 
                        18, { player.id, player.id })
    end
end


-- Server only gets `.load`, `.update`, `.quit` Love events (also `.lowmemory` and `.threaderror`
-- which are less commonly used)
-- function love.load()
--     server.load()
-- end

function server.load()
    log("server load...")
    
    -- create level
    serverPrivate.level = createLevel(START_LEVEL, 512, true) --game size (square)
    serverPrivate.levelName = LEVEL_LIST[START_LEVEL]
    serverPrivate.lastTime = love.timer.getTime()
    share.levelSize = serverPrivate.level.levelSize
    -- create players
    share.players = {}
    -- create message notifications/history (kills/deaths/etc.)
    share.messages={}
    share.messageCount=0
    -- start in "round ended" mode, so can select starting level
    share.timer = VOTE_LENGTH
    share.game_ended = true    
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

    if not share.game_ended then
        -- Go through all players and update level grid, 
        -- based on their direction/state for this frame
        for id, home in pairs(server.homes) do
            -- Current player
            local player = share.players[id]

            if player then
                if not player.dead then
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
                        player.gridX = home.gridX
                        player.gridY = home.gridY
                        player.boost = home.boost
                    end

                    -- Have to do this on the server,
                    -- as it's a collation of all player trails
                    -- (but also doing it at client too)
                    updateLevelGrid(share.players[id], share.level)

                    -- -- Check for deaths
                    -- if player.dead then
                    --     -- Reset player
                    --     resetPlayer(player, share)
                    -- end
                elseif (love.timer.getTime()-player.killedAt) >= 3 then
                    -- Respawn player
                    resetPlayer(player, share, true)        
                    -- tell client start pos
                    server.send(id, "player_start", 
                        player.xDir, player.yDir, 
                        player.x, player.y, player.col,
                        serverPrivate.levelName, levelDataPath, levelGfxPaths)

                end

                if not player.announced and player.me then
                    -- announce new player
                    createMessage(share, player.me.shortname.." joined the game", 
                        18, { player.id, player.id })
                    player.announced = true
                end

                -- -- check for vote (this frame)
                -- if player.vote then
                --     LEVEL_DATA_LIST[player.vote].votes = LEVEL_DATA_LIST[player.vote].votes + 1
                -- end
            end
        end -- all players

    else
        
        -- round over update code...

        -- Go through all players and check for votes for this frame
        for id, home in pairs(server.homes) do
          -- Current player
          local player = share.players[id]
          if player then
            -- check for vote (this frame)
            if player.vote then
              LEVEL_DATA_LIST[player.vote].votes = LEVEL_DATA_LIST[player.vote].votes + 1
            end
          end
        end
    end


    -- sort players by score
    if math.floor(love.timer.getTime())%2==0 then
        -- make a table of players
        -- (as can't sort userdata)
        local scoreTable = {}
        for clientId, player in pairs(share.players) do
            scoreTable[clientId]=clientId
        end

        table.sort(scoreTable, function (a, b)
            return a.score < b.score
        end)
        -- share scoretable
        share.scoreTable = scoreTable
    end

    
    -- check (& reset) vote counts
    for key, level in pairs(LEVEL_DATA_LIST) do
        -- do we have a majority?
        if level.votes >= math.floor(#share.players/2)+1 then
            -- switch level
            loadLevel(key)
            -- start new game
            share.game_ended = false
            -- countdown to restart
            share.timer = GAME_LENGTH 
        end
        -- reset count either way (for this frame)
        level.votes = 0
    end

    -- update game timer
    if math.floor(serverPrivate.lastTime) ~= math.floor(love.timer.getTime()) then        
        share.timer = share.timer - 1
        -- check for "end game" #MCU
        if share.timer <= 0 then
            -- level over - declare winner? (nah, prob just show a table)
            share.game_ended = not share.game_ended
            log("share.timer reached 0")
            log("share.game_ended = "..tostring(share.game_ended))
            -- countdown to restart
            share.timer = share.game_ended and VOTE_LENGTH or GAME_LENGTH 
            -- starting a new game?
            if not share.game_ended then
                loadLevel(serverPrivate.levelName)            
            end            
        end
        serverPrivate.lastTime = love.timer.getTime()
    end
    
end

function loadLevel(levelName)
  log("loadLevel("..tostring(levelName)..")")
    levelDataPath = LEVEL_DATA_LIST[levelName].imgData
    levelGfxPaths = LEVEL_DATA_LIST[levelName].imgGfxList
    -- 
    serverPrivate.level = createLevel(1, 512, true) --game size (square)
    serverPrivate.levelName = levelName
    share.levelSize = serverPrivate.level.levelSize
    share.timer = GAME_LENGTH

    -- reset all players
    log("server resetting players to new level")
    for clientId, player in pairs(share.players) do                
        -- reset player client
        player.score = 0
        resetPlayer(player, share, true)                
        -- reset player vote
        player.vote = nil
        server.send(clientId, "player_start", 
            player.xDir, player.yDir, 
            player.x, player.y, player.col,
            levelName, levelDataPath, levelGfxPaths)
    end
end