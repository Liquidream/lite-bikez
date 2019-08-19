
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
  0x000000, 0xffffff, 0x07ffff, 0x48fec4, 
  0xff3b18, 0xe53a2d, 0xff45e4, 0xb832c4, 
  0xffff5b, 0xebfe31, 0x74ff4b, 0x00ff1f, 
  0xffa1ff, 0xf447ff, 0xffff25, 0xffd13b, 
  0xff5182, 0xffb9a4, 0x41bf45, 0x3d7724, 
  0xcecbff, 0xa58ee7, 0xffffff, 0xf6ffff, 
  0xffaf34, 0xe98845, 0xffb7ec, 0xdb97ac, 
  0x51a58c, 0x284a3d, 0xebffce, 0xbfd49c, 
  0xd53871, 0x672554, 0xffffff, 0xeeccff, 
  0xffffff, 0x712f25, 0xb7a925, 0x886f3a, 
  0xffffff, 0xffffd2, 0xf8cbab, 0x84747f, 
  0xaeffff, 0xffffff, 0x07ffff, 0x6ae7f6, 
  0x2d91ff, 0x3567b7, 0x51d7ff, 0x449ebc, 
  0x4e17ff, 0x341a95, 
  0x170b42,
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
GAME_LENGTH = 60*3 -- 3 mins
VOTE_LENGTH = 30   -- 30 secs

PLAYER_START_SPEED = 5
PLAYER_NORM_SPEED = 75
PLAYER_SLOW_SPEED = 50  -- Speed player goes to AFTER boosting
PLAYER_ACC_SPEED = 1
PLAYER_MAX_BOOST = 100 -- Cap the duration players can boost for

MAX_MESSAGES = 4
MAX_MSG_LIFE = 10

LEVEL_LIST = {
    "Pillars of Doom",
    "Castle of Chaos",
    "Grid City"
}

START_LEVEL = 1


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
    ["Grid City"] = {
      imgData="assets/level-2-data.png",
      imgGfxList={
          "assets/level-2-gfx-a.png",
          "assets/level-2-gfx-b.png",
          "assets/level-2-gfx-c.png",
          "assets/level-2-gfx-d.png"},
      votes=0
  },
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

-- https://stackoverflow.com/a/15706820
function spairs(t, order)
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys 
  if order then
      table.sort(keys, function(a,b) return order(t, a, b) end)
  else
      table.sort(keys)
  end

  -- return the iterator function
  local i = 0
  return function()
      i = i + 1
      if keys[i] then
          return keys[i], t[keys[i]]
      end
  end
end