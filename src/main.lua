-- Welcome to your new Castle project!
-- https://castle.games/get-started
-- Castle uses Love2D 11.1 for rendering and input: https://love2d.org/
-- See here for some useful Love2D documentation:
-- https://love2d-community.github.io/love-api/

if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    "assets/SoftballGold.ttf",
    "assets/title-text.png",
    "assets/splash.png",
    "assets/level-1-bg.png",
    "assets/level-1-data.png",
    "assets/level-1-gfx-ab.png",
    "assets/level-1-gfx-c.png",
    "assets/level-2-data.png",
    "assets/level-2-gfx-a.png",
    "assets/level-2-gfx-b.png",
    "assets/level-2-gfx-c.png",
    "assets/level-2-gfx-d.png",
    "assets/level-3-data.png",
    "assets/level-3-gfx-a.png",
    "assets/level-3-gfx-b.png",
    "assets/level-3-gfx-c.png",
    "assets/level-3-gfx-d.png",
    "network/cs.lua",
    "network/state.lua",
    "network/tests.lua",
    "sugarcoat/sugarcoat.lua",
    "sprinklez.lua",
    "common.lua",
    "game_client.lua",
    "game_server.lua",
    "level.lua",
    "player.lua",
    "ui_input.lua",
    "assets/snd/bike_start.mp3",
    "assets/snd/casette_intro.mp3",
    "assets/snd/music_cocaine_lambo.mp3",
    "assets/snd/music_microwave_robocop.mp3",
    "assets/snd/music_payphone_cybersex.mp3",
    "assets/snd/music_profunctor_optics.mp3",
    "assets/snd/music_skyking.mp3",
    "assets/snd/music_zima_hangover.mp3",
    "assets/snd/title_loop.mp3",
    "assets/snd/bike_birth.mp3",
    "assets/snd/bike_cruising.mp3",
    "assets/snd/bike_start.mp3",
    "assets/snd/bike_turn.mp3",
    "assets/snd/speed_boost.mp3",
    "assets/snd/earn_frag.mp3",
    "assets/snd/die.mp3"
  })
end

-- This requests a cloud server from Castle

--### REPLACED with just "castle"
--USE_CASTLE_CONFIG = true

--## DON'T LOAD THE SERVER HERE
--## .CASTLE FILE WILL HANDLE IT
--require 'game_server'

require 'game_client'
