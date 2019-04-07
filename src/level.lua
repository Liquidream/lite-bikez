
Level = {}

function Level:new(levelNum, levelSize)
    local this={
        levelSize = levelSize,
        grid = {}
    }
    -- TODO: Create new level "grid" for level specified
    --local grid={}

    for r = 1,levelSize do
        this.grid[r]={}
        for c = 1,levelSize do
            this.grid[r][c]=0
        end  
    end

    -- Store the new level grid
    -- o.grid = grid
    -- o.levelSize = levelSize
    
    -- Update grid state, based on player pos/direction/state
    function this:updatePlayer(home)
        -- print("home.x="..home.x)
        -- print("home.y="..home.y)
        -- print("grid size="..#self.grid)
        self.grid[home.x][home.y] = 1
    end

    -- Can't do this with Share.lua (not too surprising)
    -- self.__index = self;
    -- setmetatable(o, self);
    return this;
end

function Level.draw(share)
    if share.level.levelSize then
        -- draw the whole grid
        for r = 1,share.level.levelSize do
            for c = 1,share.level.levelSize do
                if share.level.grid[c][r] > 0 then
                    --actually draw particle
                    love.graphics.setColor({1,1,1}) --colour[col])
                    love.graphics.points(c,r)    
                end
            end  
        end
    end
end


--return Level;