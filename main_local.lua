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
    'src/example_local.lua',
    'src/example_server.lua',
    'src/gfx.lua',
    'src/level.lua',
    'src/player.lua',
  })
 end

-- This requests a cloud server from Castle

USE_CASTLE_CONFIG = false
require 'src/example_server'
require 'src/example_client'

