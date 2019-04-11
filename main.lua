-- Welcome to your new Castle project!
-- https://castle.games/get-started
-- Castle uses Love2D 11.1 for rendering and input: https://love2d.org/
-- See here for some useful Love2D documentation:
-- https://love2d-community.github.io/love-api/


if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'main.lua',
    'src/network/cs.lua',
    'src/network/state.lua',
    'src/network/tests.lua',
    'src/common.lua',
    'src/example_castle.lua',
    'src/example_client.lua',
    'src/example_server.lua',
    'src/example_local.lua',
    'src/example_server.lua',
    'src/gfx.lua',
    'src/level.lua',
    'src/player.lua',
  })
 end

-- This requests a cloud server from Castle

USE_CASTLE_CONFIG = true
require 'src/example_server'
require 'src/example_client'


-- local total_time_elapsed = 0

-- function love.draw()
--   local y_offset = 8 * math.sin(total_time_elapsed * 3)
--   love.graphics.print('Edit main.lua to get started!', 400, 300 + y_offset)
--   love.graphics.print('Press Cmd/Ctrl + R to reload.', 400, 316 + y_offset)
-- end

-- function love.update(dt)
--   total_time_elapsed = total_time_elapsed + dt
-- end

