

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



function updatePlayer(player, key)
    -- keyboard controls
    if key == "right" then
        player.xDir = 1
        player.yDir = 0
    end
    if key == "left" then
        player.xDir = -1
        player.yDir = 0
    end
    if key == "up" then
        player.xDir = 0
        player.yDir = -1
    end
    if key == "down" then
        player.xDir = 0
        player.yDir = 1
    end
    if key == "space" then
        player.xDir = 0
        player.yDir = 0
    end
    -- print("home.xdir="..self.home.xDir)
    -- print("home.ydir="..self.home.yDir)
    -- self.home.x = self.home.x + self.xDir
    -- self.home.y = self.home.y + self.yDir
end

function drawPlayer(player)
    --self.sourc 
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', player.x, player.y, 5)
end

return Player