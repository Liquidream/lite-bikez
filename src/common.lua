
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

-- Andrew Kensler
-- https://lospec.com/palette-list/andrew-kensler-54
ak54 = {
    0x000000, 0x05fec1, 0x32af87, 0x387261,  
    0x1c332a, 0x2a5219, 0x2d8430, 0x00b716, 
    0x50fe34, 0xa2d18e, 0x84926c, 0xaabab3, 
    0xcdfff1, 0x05dcdd, 0x499faa, 0x2f6d82, 
    0x3894d7, 0x78cef8, 0xbbc6ec, 0x8e8cfd, 
    0x1f64f4, 0x25477e, 0x72629f, 0xa48db5, 
    0xf5b8f4, 0xdf6ff1, 0xa831ee, 0x3610e3, 
    0x241267, 0x7f2387, 0x471a3a, 0x93274e, 
    0x976877, 0xe57ea3, 0xd5309d, 0xdd385a, 
    0xf28071, 0xee2911, 0x9e281f, 0x4e211a, 
    0x5b5058, 0x5e4d28, 0x7e751a, 0xa2af22, 
    0xe0f53f, 0xfffbc6, 0xffffff, 0xdfb9ba, 
    0xab8c76, 0xeec191, 0xc19029, 0xf8cb1a, 
    0xea7924, 0xa15e30,
    -- custom colours
    0x10082e
}

ak54Paired = {
    0x000000, 0xffffff, 0x05fec1, 0x32af87, 
    0xee2911, 0x9e281f, 0xd5309d, 0x7f2387, 
    0xe0f53f, 0xa2af22, 0x50fe34, 0x00b716, 
    0xdf6ff1, 0xa831ee, 0xf8cb1a, 0xc19029, 
    0xdd385a, 0xf28071, 0x2d8430, 0x2a5219, 
    0x8e8cfd, 0x72629f, 0xcdfff1, 0xaabab3, 
    0xea7924, 0xa15e30, 0xe57ea3, 0x976877, 
    0x387261, 0x1c332a, 0xa2d18e, 0x84926c, 
    0x93274e, 0x471a3a, 0xf5b8f4, 0xa48db5, 
    0xdfb9ba, 0x4e211a, 0x7e751a, 0x5e4d28, 
    0xfffbc6, 0xeec191, 0xab8c76, 0x5b5058, 
    0x78cef8, 0xbbc6ec, 0x05dcdd, 0x499faa, 
    0x1f64f4, 0x25477e, 0x3894d7, 0x2f6d82, 
    0x3610e3, 0x241267,
    -- custom colours
    0x10082e
}

--
-- Globals
--
DEBUG_MODE = false
GAME_WIDTH = 512  -- 16:9 aspect ratio that fits nicely
GAME_HEIGHT = 288 -- within the default Castle window size
GAME_SCALE = 3

PLAYER_START_SPEED = 5
PLAYER_NORM_SPEED = 75
PLAYER_SLOW_SPEED = 50  -- Speed player goes to AFTER boosting
PLAYER_ACC_SPEED = 1
PLAYER_MAX_BOOST = 100 -- Cap the duration players can boost for

MAX_MESSAGES = 6
MAX_MSG_LIFE = 10

LEVEL_LIST = {
    "Pillars of Doom",
    "Corridors of Chaos"
}


LEVEL_DATA_LIST = {
    ["Pillars of Doom"] = {
        imgData="assets/level-1-data.png",
        imgGfx="assets/level-1-gfx.png" },
    ["Corridors of Chaos"] = {
        imgData="assets/level-2-data.png",
        imgGfx="assets/level-2-gfx.png" },    
}

--
-- Global functions
--
function createMessage(share, messageText, col, taggedIds)
    local msg = {
        text=messageText,
        col=col or 24,
        taggedIds=taggedIds,
        created=love.timer.getTime()
    }
    share.messageCount = share.messageCount + 1
    -- cap number of messages
    if share.messageCount > MAX_MESSAGES then
        share.messageCount = MAX_MESSAGES
        -- move all messages up one slot
        for i=1,share.messageCount-1 do
            share.messages[i] = share.messages[i+1]
        end
    end
    -- add latest message
    share.messages[share.messageCount] = msg
end

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