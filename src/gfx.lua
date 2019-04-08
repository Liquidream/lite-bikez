
--
-- Constants
--
local GAME_WIDTH = 512  -- 16:9 aspect ratio that fits nicely
local GAME_HEIGHT = 288 -- within the default Castle window size
local GAME_LEFT = 0
local GAME_RIGHT = GAME_WIDTH
local GAME_TOP = 0
local GAME_BOTTOM = GAME_HEIGHT
local GAME_MIDDLE_X = GAME_WIDTH / 2
local GAME_MIDDLE_Y = GAME_HEIGHT / 2

--
-- Fields
--
-- Screen dimensions are hardware-based (what's the size of the display device)
local SCREEN_WIDTH
local SCREEN_HEIGHT
-- Render dimenisions reflect how the game should be drawn to the canvas
local RENDER_SCALE
local RENDER_WIDTH
local RENDER_HEIGHT
local RENDER_X
local RENDER_Y
local RENDER_CANVAS
-- Camera shake-related
local shakeAmount = 0 -- how much to shake the screen (will stablise over time)
local shakeX = 0
local shakeY = 0
-- Other 
local particles={}
local fonts={}


local function init(self)
    -- Load fonts/sizes
    -- font = love.graphics.newFont("assets/rent.ttf",16)
    -- font:setFilter("nearest", "nearest", 0 )
    -- table.insert(fonts, font)
    -- -- Default to first font
    -- self.setFont(1)
end

-- Recalibrate the render display, based on current display dimensions
-- (e.g. after change to/from Fullscreen)
local function updateDisplay(self)
  -- Screen dimensions are hardware-based (what's the size of the display device)
  local width, height = love.graphics.getDimensions()
  self.SCREEN_WIDTH = width
  self.SCREEN_HEIGHT = height

  print("game res:    "..GAME_WIDTH..","..GAME_HEIGHT)
  print("window size: "..width..","..height)

  -- Create new canvas for drawing on
  self.RENDER_CANVAS = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)
  self.RENDER_CANVAS:setFilter("nearest", "nearest")

  self.RENDER_SCALE = math.floor(math.min(self.SCREEN_WIDTH / GAME_WIDTH, self.SCREEN_HEIGHT / GAME_HEIGHT))
  self.RENDER_WIDTH = self.RENDER_SCALE * GAME_WIDTH
  self.RENDER_HEIGHT = self.RENDER_SCALE * GAME_HEIGHT
  print("RENDER_SCALE="..self.RENDER_SCALE)
  print("RENDER_WIDTH="..self.RENDER_WIDTH)
  print("RENDER_HEIGHT="..self.RENDER_HEIGHT)

  self.RENDER_X = math.floor((self.SCREEN_WIDTH - self.RENDER_WIDTH) / 2)
  self.RENDER_Y = math.floor((self.SCREEN_HEIGHT - self.RENDER_HEIGHT) / 2)
end

-- Setup the drawing to canvas, etc.
local function preRender(self)
    --This sets the draw target to the canvas
    love.graphics.setCanvas(self.RENDER_CANVAS)

    -- Camera translatons (Shake)
    love.graphics.push()

    -- Set "Point/Non-AA" Filters for...
    love.graphics.setDefaultFilter('nearest', 'nearest') -- Sprites (Quads)
    love.graphics.setLineStyle("rough")                  -- Shapes (Circles, Lines...)

    -- Apply camera transformations
    love.graphics.translate(self.shakeX, self.shakeY)
end

-- Draw the canvas to screen, scale and center
local function postRender(self)
    -- Draw game bounds
    love.graphics.setColor({0,1,0})
    love.graphics.rectangle('line', 0, 0, self.GAME_WIDTH, self.GAME_HEIGHT)

    -- Pop camera translations (Shake)
    love.graphics.pop()

    -- Draw the canvas, scaled, to screen
    love.graphics.setCanvas() --This sets the target back to the screen

    -- Center everything within Castle window
    love.graphics.push()

    -- Apply "Center to Window" transformations
    love.graphics.translate(self.RENDER_X, self.RENDER_Y)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.RENDER_CANVAS, 0, 0, 0, self.RENDER_SCALE, self.RENDER_SCALE)

    -- Pop centering within Castle window
    love.graphics.pop()

    -- Draw screen bounds
    -- love.graphics.setColor(0, 1, 0, 1)
    -- love.graphics.rectangle('line', 0, 0, self.SCREEN_WIDTH, self.SCREEN_HEIGHT)
end




-- Switch font bank
local function setFont(num)
    love.graphics.setFont(fonts[num])
end



return {
    -- constants
    GAME_WIDTH = GAME_WIDTH,
    GAME_HEIGHT = GAME_HEIGHT,
    GAME_LEFT = GAME_LEFT,
    GAME_RIGHT = GAME_RIGHT,
    GAME_TOP = GAME_TOP,
    GAME_BOTTOM = GAME_BOTTOM,
    GAME_MIDDLE_X = GAME_MIDDLE_X,
    GAME_MIDDLE_Y = GAME_MIDDLE_Y,

    -- properties
    SCREEN_WIDTH = SCREEN_WIDTH,
    SCREEN_HEIGHT = SCREEN_HEIGHT,
    RENDER_SCALE = RENDER_SCALE,
    RENDER_WIDTH = RENDER_WIDTH,
    RENDER_HEIGHT = RENDER_HEIGHT,
    RENDER_X = RENDER_X,
    RENDER_Y = RENDER_Y,
    RENDER_CANVAS = RENDER_CANVAS,
   
    --font = font,
   
    -- functions
    init = init,
    updateDisplay = updateDisplay,
    preRender = preRender,
    postRender = postRender,
    --setFont = setFont,
    --drawOutlineText = drawOutlineText,
   
    -- boom = boom,
    -- spawnParticle = spawnParticle,
    -- updateParticles = updateParticles,
    -- drawParticles = drawParticles,
   
    -- Camera related
    

    -- Camera shake
    shake = shake, --function
    shakeX = shakeX,
    shakeY = shakeY,
    updateShake = updateShake,



   }