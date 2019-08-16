
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
    0x10082e
    -- custom colours
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
    0x10082e, 

    -- custom colours
    0x2c1024, -- v.dark purp/pink
    --0x661c37
    0x151515  -- almost black
}

ak54PairedLight = {
    0x000000, 0xffffff, 0x05ffde, 0x39c99b,
    0xff2f13, 0xb62e23, 0xf537b4, 0x92289b, 
    0xffff48, 0xbac927, 0x5cff3b, 0x00d219, 
    0xff7fff, 0xc138ff, 0xffe91d, 0xdea52f, 
    0xfe4067, 0xff9382, 0x339837, 0x305e1c, 
    0xa3a1ff, 0x8370b7, 0xecffff, 0xc3d6ce, 
    0xff8b29, 0xb96c37, 0xff91bb, 0xad7789, 
    0x40836f, 0x203a30, 0xbaf0a3, 0x98a87c, 
    0xa92c59, 0x511d42, 0xffd4ff, 0xbca2d0, 
    0xffd5d6, 0x59261d, 0x91861d, 0x6c582e, 
    0xffffe4, 0xffdea7, 0xc5a187, 0x685c65, 
    0x8aedff, 0xd7e4ff, 0x05fdfe, 0x54b7c3, 
    0x2373ff, 0x2a5191, 0x40aaf7, 0x367d95, 
    0x3e12ff, 0x291476, 
    0x120935, 
}

fadeBlackTable={
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
    {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
    {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
    {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
    {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
    {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
    {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
    {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
    {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
    {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
    {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
    {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
    {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
    {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
    {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

--
-- Globals
--
DEBUG_MODE = false
GAME_WIDTH = 512  -- 16:9 aspect ratio that fits nicely
GAME_HEIGHT = 288 -- within the default Castle window size
GAME_SCALE = 3
GAME_STATE = { SPLASH=0, TITLE=1, INFO=2, LVL_INTRO=3, LVL_PLAY=4, 
                LVL_END=5, LOSE_LIFE=6, GAME_OVER=7, ROUND_OVER=8 }
GAME_LENGTH = 15 --60*5 -- 5 mins
VOTE_LENGTH = 10 --60

PLAYER_START_SPEED = 5
PLAYER_NORM_SPEED = 75
PLAYER_SLOW_SPEED = 50  -- Speed player goes to AFTER boosting
PLAYER_ACC_SPEED = 1
PLAYER_MAX_BOOST = 100 -- Cap the duration players can boost for

MAX_MESSAGES = 4
MAX_MSG_LIFE = 10

LEVEL_LIST = {
    "Pillars of Doom",
    "Castle of Chaos"
}


LEVEL_DATA_LIST = {
    ["Pillars of Doom"] = {
        imgData="assets/level-1-data.png",
        imgGfxList={
            "assets/level-1-gfx-ab.png",
            "assets/level-1-gfx-ab.png",
            "assets/level-1-gfx-ab.png",
            "assets/level-1-gfx-c.png"},
        votes=0
    },
    ["Castle of Chaos"] = {
        imgData="assets/level-3-data.png",
        imgGfxList={
            "assets/level-3-gfx-a.png",
            "assets/level-3-gfx-b.png",
            "assets/level-3-gfx-c.png",
            "assets/level-3-gfx-d.png"} ,
            votes=0
    }, 
    -- ["Corridors of Chaos"] = {
    --     imgData="assets/level-2-data.png",
    --     imgGfxList={
    --         "assets/level-2-gfx-a.png",
    --         "assets/level-2-gfx-b.png"} 
    -- },    
}

--
-- Global functions
--
function createMessage(share, messageText, col, taggedIds)
    local msg = {
        text=messageText,
        col=col or 51,
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