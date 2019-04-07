

Player = {}

local MOVE_SPEED = 1

function Player:new(home, id, col, xDir, yDir)
    local o = {}
    o.home = home   -- writable n/w data
    o.id = id
    o.col = col
    o.speed = MOVE_SPEED
    o.home.xDir = xDir or 0
    o.home.yDir = yDir or 0
    --
    self.__index = self;
    setmetatable(o, self);
    return o;
end



function Player:update(key)
    -- keyboard controls

    
    if key == "right" then
        self.home.xDir = 1
        self.home.yDir = 0
    end
    if key == "left" then
        self.home.xDir = -1
        self.home.yDir = 0
    end
    if key == "up" then
        self.home.xDir = 0
        self.home.yDir = -1
    end
    if key == "down" then
        self.home.xDir = 0
        self.home.yDir = 1
    end

    -- print("home.xdir="..self.home.xDir)
    -- print("home.ydir="..self.home.yDir)
    -- self.home.x = self.home.x + self.xDir
    -- self.home.y = self.home.y + self.yDir
end

function Player:draw()
    --self.sourc 
end

return Player