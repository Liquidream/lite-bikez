-- Welcome to your new Castle project!
-- https://castle.games/get-started
-- Castle uses Love2D 11.1 for rendering and input: https://love2d.org/
-- See here for some useful Love2D documentation:
-- https://love2d-community.github.io/love-api/

if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'moonshine/glow.lua',
    'moonshine/scanlines.lua',
    'assets/level-1-bg.png',
    'assets/level-1-data.png',
    'assets/level-1-gfx.png',
    'assets/level-2-data.png',
    'assets/level-2-gfx.png',
    'network/cs.lua',
    'network/state.lua',
    'network/tests.lua',
    'sugarcoat/sugarcoat.lua',
    'common.lua',
    'example_client.lua',
    'example_local.lua',
    'example_server.lua',
    'level.lua',
    'player.lua',
    'ui_input.lua',
  })
 end

-- This requests a cloud server from Castle

USE_CASTLE_CONFIG = true

--## DON'T LOAD THE SERVER HERE
--## .CASTLE FILE WILL HANDLE IT
--require 'example_server'

require 'example_client'
