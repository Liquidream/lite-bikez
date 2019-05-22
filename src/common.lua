
--
-- Constants
--
amstradCPC = {
    0x000000, 0x000080, 0x0000ff, 0x800000, 
    0x800080, 0x8000ff, 0xff0000, 0xff0080, 
    0xff00ff, 0x008000, 0x008080, 0x0080ff, 
    0x808000, 0x808080, 0x8080ff, 0xff8000, 
    0xff8080, 0xff80ff, 0x00ff00, 0x00ff80, 
    0x00ffff, 0x80ff00, 0x80ff80, 0x80ffff, 
    0xffff00, 0xffff80, 0xffffff
}

--
-- Globals
--
DEBUG_MODE = false
GAME_WIDTH = 512  -- 16:9 aspect ratio that fits nicely
GAME_HEIGHT = 288 -- within the default Castle window size


--
-- Helper Functions
--

-- Re-seed the Random Number Generation
-- so that if called quickly (sub-seconds)
-- it'll still be random
_incSeed=0
function resetRNG()
    _incSeed = _incSeed + 1
    local seed=os.time() + _incSeed
    math.randomseed(seed)
    --print("Re-seeding RNG="..seed)
end

-- https://helloacm.com/split-a-string-in-lua/
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end