

--Player = {}

local MOVE_SPEED = 1

-- function Player:new(home, id, col, xDir, yDir)
--     local o = {}
--     o.home = home   -- writable n/w data
--     o.id = id
--     o.col = col
--     o.speed = MOVE_SPEED
--     o.home.xDir = xDir or 0
--     o.home.yDir = yDir or 0
--     --
--     self.__index = self;
--     setmetatable(o, self);
--     return o;
-- end


function killPlayer(player)
    -- 
    print("player DIED ("..player.id..")")
    player.dead = true

    -- any more?

end

function resetPlayer(player, share)
    player.dead = false
    -- Start at a random position
    player.x = math.random(share.level.levelSize)
    player.y = math.random(share.level.levelSize/2)
    player.xDir = math.random(2)-1
    player.yDir = math.random(2)-1
    print("player.xDir="..player.xDir)
    -- col based on id
    math.randomseed(player.id)
    player.col = { math.random(), math.random(), math.random()}
end

function updatePlayer(clientPlayer, key)

    -- keyboard controls
    if key == "right" then
        clientPlayer.xDir = 1
        clientPlayer.yDir = 0
    end
    if key == "left" then
        clientPlayer.xDir = -1
        clientPlayer.yDir = 0
    end
    if key == "up" then
        clientPlayer.xDir = 0
        clientPlayer.yDir = -1
    end
    if key == "down" then
        clientPlayer.xDir = 0
        clientPlayer.yDir = 1
    end
    if key == "space" then
        clientPlayer.xDir = 0
        clientPlayer.yDir = 0
    end
   
end

function drawPlayer(player)
    --self.sourc 
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', player.x, player.y, 5)
end

return Player