-- Welcome to your new Castle project!
-- https://castle.games/get-started
-- Castle uses Love2D 11.1 for rendering and input: https://love2d.org/
-- See here for some useful Love2D documentation:
-- https://love2d-community.github.io/love-api/

if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'assets/MatchupPro.ttf',
    'assets/level-1-bg.png',
    'assets/level-1-data.png',
    'assets/level-1-gfx.png',
    'assets/level-2-data.png',
    'assets/level-2-gfx.png',
    'assets/bounce.mp3',    
    'assets/bounce_2.mp3',    
    'network/cs.lua',
    'network/state.lua',
    'network/tests.lua',
    'sugarcoat/sugarcoat.lua',
    'common.lua',
    'game_client.lua',
    'game_server.lua',
    --'example_local.lua',
    'level.lua',
    'player.lua',
    'ui_input.lua',
  })
 end

-- This requests a cloud server from Castle

USE_CASTLE_CONFIG = true

--## DON'T LOAD THE SERVER HERE
--## .CASTLE FILE WILL HANDLE IT
--require 'game_server'

require 'game_client'
