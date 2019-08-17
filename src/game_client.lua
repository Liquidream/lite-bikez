local cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/b94c77cacc9e842877e7d8dd71c17792bd8cbc32/cs.lua'

--local gfx = require 'src/gfx'
require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)

require("common")
require("player")
require("level")
require("ui_input")
require("sprinklez")

local Sounds = require 'sounds'

-- made client global so UI and others can use
client = cs.client

if castle then
    client.useCastleConfig()
else
    client.enabled = true
    client.start('127.0.0.1:22122') -- IP address ('127.0.0.1' is same computer) and port of server
end

useShader = true

-- Client connects to server. It gets a unique `id` to identify it.
--
-- `client.share` represents the shared state that server can write to and any client can read from.
-- `client.home` represents the home for this client that only it can write to and only server can
-- read from. `client.id` is the `id` for this client (set once it connects).
--
-- Client can also send or receive individual messages to or from server.


local share = client.share  -- Maps to `server.share` -- can read
local home = client.home    -- Maps to `server.homes[id]` with our `id` -- can write
local homePlayer = home
local clientPrivate = {}    -- data private to the client (not synced)
local playerPhotos = {}
camx,camy = 0,0       -- made it global, so "level" can access
zoom_scale = 2        -- 2
-- particle systems
boostParticles = {}
deathParticles = {}
--pSystems = {}

-- shader parameters
shader_crt_curve      = 0.025
shader_glow_strength  = 0.5
shader_distortion_ray = 3.0
shader_scan_lines     = 1.0
gameState = -1 -- nothing by default



-- Client gets all Love events

function  client.load()
    local width, height = love.graphics.getDimensions()
    log(">>>> client getDimensions: "..width..","..height)

    -- (init sound first - as seems to do a pause, 
    --  which don't want to interfere with splash duration)
    initSounds()

     -- enable/initialise Sugarcoat engine for rendering
    initSugarcoat()

    -- default player to dead
    homePlayer.dead = true

    log("Game initialized.")
end


function initSugarcoat()
    -- initialise and update the gfx display
    init_sugar("Light Ryders", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)

    screen_render_stretch(false)
    screen_render_integer_scale(false)
    --screen_render_integer_scale(true)

    shader_switch(useShader)

    set_frame_waiting(60)

    
    -- start with splash screen palette 
    use_palette(palettes.pico8)    
    
    --use_palette(ak54Paired)
    --use_palette(ak54)
    --use_palette(amstradCPC)
    --use_palette(palettes.pico8)
    --set_background_color(0)

    --network.async(function()
        -- load splash img first (to show while others dnload)
        log("loading splash images...")        
        load_png("splash", "assets/splash.png", palettes.pico8, true)
        
        -- load other graphics
        load_png("titlegfx-text", "assets/title-text.png", ak54Paired, true)
        load_png("titlegfx-bg", "assets/level-1-bg.png", ak54Paired, true)

        --end)
        
        -- new font!
        load_font('assets/SoftballGold.ttf', 32, 'corefont-big', true)
        load_font('assets/SoftballGold.ttf', 16, 'corefont', true)
        -- load_font('assets/MatchupPro.ttf', 32, 'corefont-big', true)
        -- load_font('assets/MatchupPro.ttf', 16, 'corefont', true)

        initSplash()
end


--
-- Intro/Splash screen
--
function initSplash()
    log("initSplash()...,.")
    Sounds.casetteTape:play()
    gameState = GAME_STATE.SPLASH    
    -- start with splash screen palette 
    use_palette(palettes.pico8)    
    startTime = love.timer.getTime()
    shader_switch(false)
  end

function updateSplash(dt)
    if startTime then
        duration = love.timer.getTime()-startTime 
        if duration > 3.53 then
        -- load the title screen      
        --Sounds.titleLoop:play()
        initTitle()
        end
    end
end

function drawSplash()
    cls()
    local offset = math.sin(duration)*2
    fade(max(14-(offset-1.1)*25,0))
    -- title logo
    if surface_exists("splash") then
        local w,h = surface_size("splash")
        local scale = 2
        w=w*scale
        h=h*scale
        spr_sheet("splash", GAME_WIDTH/2-w/2, GAME_HEIGHT/2-h/2, w,h)
    end

end


   
function fade(i)
    for c=0,15 do
        if flr(i+1)>=16 or flr(i+1)<=0 then
            pal(c,0)
        else
            pal(c,fadeBlackTable[c+1][flr(i+1)])
        end
    end
end

--
-- Title screen
--

function initTitle()
    log("initTitle()...")
    
    gameState = GAME_STATE.TITLE
    -- switch to main palette for title screen
    use_palette(ak54Paired)
    shader_switch(true)
end

function updateTitle(dt)
    -- wait until connected (and for user to press space) to start
    if client.connected and love.keyboard.isDown("space") then
        -- tell the server we're ready to start
        client.send("player_ready")
    end
end


local pgrid=0
function drawTitle(levelSize, draw_zoom_scale)    
    
    -- Make text more "readable"
    --print("!!!",50,1,1)
    printp(0x0330, 0x3123, 0x0330, 0x0, 0x0)
    printp_color(0, 0, 0)

    -- Reset camera for UI
    camera(0,0)

    local pcols = {13, 7,  33, 55}
    local pdist = {288,180,134,127}
    local vpoint_y=120
    palt(0,true)

    -- stars
    srand(197)  --197 --194 --56 --131  --139 --220 --236
    for i=1,100 do
        local x=rnd(GAME_WIDTH)
        local y=rnd(vpoint_y)
        local s=(irnd(20)==0) and rnd(3) or 0
        rectfill(x,y,x+s,y+s,1)
    end

    -- draw grid
    for i=1,#pcols do
        clip(0, 0, GAME_WIDTH, pdist[i])
        for n=-130,130 do
            w=63+(n-pgrid)*140
            line(GAME_WIDTH/2,vpoint_y,w,GAME_HEIGHT,pcols[i])
            y=vpoint_y+n*n*0.75
            line(0,y,GAME_WIDTH,y,pcols[i])
        end
    end
    pgrid=0.05+pgrid%1
    clip()

    -- title logo
    if surface_exists("titlegfx-text") then
        spr_sheet("titlegfx-text", GAME_WIDTH/2-384/2, GAME_HEIGHT/2-50)
    end

    
    -- Reset camera for UI
    camera(0,0)
    
    --use_font("corefont-big")    
    
    if client.connected then          
        pprintc('Press <SPACE> to start', GAME_HEIGHT/2+48, 11)
    else
        pprintc('Connecting to the grid...', GAME_HEIGHT/2+48, 19)
    end

    pprintc('      Code + Art                                                      Music', 
        GAME_HEIGHT/2+75, 51) --24 
    
    pprintc('    PAUL NICHOLAS                                                KEN WHEELER', 
        GAME_HEIGHT/2+92, 45) --24 
    
    --use_font("corefont")
end



function client.connect() -- Called on connect from serverfo
    log(" client.connect()... ")

    homePlayer.id = client.id
    
    -- Player info
    home.me = castle.user.getMe and castle.user.getMe()

    -- Name
    local parts = split(home.me.name," ")
    if #parts>0 then
        home.me.shortname = parts[1]
    else
        home.me.shortname = home.me.name
    end

end

function client.disconnect() -- Called on disconnect from server
  log("client.disconnect()...")

  gameState = GAME_STATE.TITLE

  Sounds.playingLoop:stop()
end

function client.receive(...) -- Called when server does `server.send(id, ...)` with our `id`
     -- Doing it this way to reduce latency with player movement
     local arg = {...}
     local msg = arg[1]
     log("client receive msg = "..msg)

     if msg == "player_start" then

        log("client reset")
               
        -- first start?
        if gameState ~= GAME_STATE.LVL_PLAY then
            -- start game        
            initGameplay()
        end

        homePlayer.xDir = arg[2]
        homePlayer.yDir = arg[3]
        homePlayer.x = arg[4]
        homePlayer.y = arg[5]
        homePlayer.col = arg[6]
        homePlayer.gridX = math.floor(homePlayer.x)
        homePlayer.gridY = math.floor(homePlayer.y)
        homePlayer.lastGridX = homePlayer.gridX
        homePlayer.lastGridY = homePlayer.gridY
        homePlayer.speed = PLAYER_START_SPEED
        homePlayer.boostCount = 0
        
        log(">>> arg 7 = ".. arg[7])
        log(">>> arg 8 =".. arg[8])
        log(">>> arg #9 =".. #arg[9])

        log(">>> curr datapath=".. levelDataPath)

        -- Always recreate level - as could be same level after a vote round
        -- (So ALL level data needs to be recreated)
        levelName = arg[7]
        levelDataPath = arg[8]
        levelGfxPaths = arg[9]
        
        homePlayer.vote = nil

        log(">>> ".. levelDataPath)
        log(">>> #levelGfxPaths=".. #levelGfxPaths)

        clientPrivate.level=createLevel(1, 512, false) --game size (square)

        resetPlayer(homePlayer, share, false)

        Sounds.bikeBirth:play()
        Sounds.bikeStart:play()

        -- Only create level once (on connection)
        if clientPrivate.level == nil then
            clientPrivate.level=createLevel(1, 512, false) --game size (square)
        end

        log("size="..clientPrivate.level.levelSize)

        -- if not USE_CASTLE_CONFIG then 
        --     -- Give player a fake ID when playing locally
        --     homePlayer.id=0
        -- end
        -- log("player id="..homePlayer.id)
     end

end

function initSounds()
  Sounds.playingLoop = Sound:new('music_cocaine_lambo.mp3', 1)
  Sounds.playingLoop:setVolume(0.7)
  Sounds.playingLoop:setLooping(true)

  Sounds.casetteTape = Sound:new('casette_intro.mp3', 1)
  Sounds.casetteTape:setVolume(0.7)

  Sounds.bikeBirth = Sound:new('bike_birth.mp3', 1)
  Sounds.bikeBirth:setVolume(0.5)

  Sounds.bikeStart = Sound:new('bike_start.mp3', 1)
  Sounds.bikeStart:setVolume(0.5)

  Sounds.die = Sound:new('die.mp3', 1)
  Sounds.die:setVolume(0.5)

  Sounds.earnFrag = Sound:new('earn_frag.mp3', 3)
  Sounds.earnFrag:setVolume(0.5)

  Sounds.speedBoost = Sound:new('speed_boost.mp3', 3)
  Sounds.speedBoost:setVolume(0.5)
end

function initGameplay()
    gameState = GAME_STATE.LVL_PLAY

    Sounds.playingLoop:play()
end


function shader_switch(enable)
  if not enable then
    screen_shader()
    return
  end
  
  screen_shader([[
    varying vec2 v_vTexcoord;
    varying vec4 v_vColour;
    
    extern float crt_curve;      // default: 0.025
    extern float glow_strength;  // default: 0.5
    extern float distortion_ray; // default: 3.0
    extern float scan_lines;     // default: 1.0
    extern float time;
    
    const float PI = 3.1415926535897932384626433832795;
    
    float get_line_k(float y){
      return mix(1.0, abs(sin(y * SCREEN_SIZE.y * PI)), scan_lines);
    }
    
    float sqr(float a){
      return a*a;
    }
    
    vec4 effect(vec4 color, Image texture, vec2 coords, vec2 screen_coords)
    {
      coords = coords * 2.0 - vec2(1.0, 1.0);
      coords += (coords.yx * coords.yx) * coords * crt_curve;
      
      float mask = min(sign(1.0 - abs(coords.x)), sign(1.0 - abs(coords.y)));
      mask = max(mask, 0.0);

      coords = coords * 0.5 + vec2(0.5, 0.5);
      
      float distor_k = distortion_ray * max(sqr(cos(-time*1.73 - coords.y*13.456)) - 0.7, 0.05) * sin(0.4*sqr(cos(-time*20.023 - coords.y*185.785 + 0.127654)));
      coords.x += 0.002 * distor_k;
    
      vec4 col = Texel_color(texture, coords);
      
      float yk = get_line_k(coords.y);
      col.rgb *= yk;
      
      col.rgb += 1.2 * abs(distor_k) * vec3(
        col.r + col.b,
        col.g + col.r,
        col.b + col.g
      );
      
      float n = 0.9;
      vec2 tca = vec2(0.98 * n, 0.2 * n) / SCREEN_SIZE;
      vec2 tcb = vec2(-0.98 * n, 0.2 * n) / SCREEN_SIZE;
      vec2 tcc = vec2(0.2 * n, 0.98 * n) / SCREEN_SIZE;
      vec2 tcd = vec2(-0.2 * n, 0.98 * n) / SCREEN_SIZE;
      
      vec4 glow = 0.15 * (
        Texel_color(texture, coords + tca) +
        Texel_color(texture, coords - tca) +
        Texel_color(texture, coords + tcb) +
        Texel_color(texture, coords - tcb) +
        Texel_color(texture, coords + tcc) +
        Texel_color(texture, coords - tcc) +
        Texel_color(texture, coords + tcd) +
        Texel_color(texture, coords - tcd)
      );
      
      tca *= 2.0;
      tcb *= 2.0;
      tcc *= 2.0;
      tcd *= 2.0;
      
      glow += 0.1 * (
        Texel_color(texture, coords + tca) +
        Texel_color(texture, coords - tca) +
        Texel_color(texture, coords + tcb) +
        Texel_color(texture, coords - tcb) +
        Texel_color(texture, coords + tcc) +
        Texel_color(texture, coords - tcc) +
        Texel_color(texture, coords + tcd) +
        Texel_color(texture, coords - tcd)
      );
      
      tca *= 1.5;
      tcb *= 1.5;
      tcc *= 1.5;
      tcd *= 1.5;
      
      glow += 0.05 * (
        Texel_color(texture, coords + tca) +
        Texel_color(texture, coords - tca) +
        Texel_color(texture, coords + tcb) +
        Texel_color(texture, coords - tcb) +
        Texel_color(texture, coords + tcc) +
        Texel_color(texture, coords - tcc) +
        Texel_color(texture, coords + tcd) +
        Texel_color(texture, coords - tcd)
      );
      
      tca *= 1.3333;
      tcb *= 1.3333;
      tcc *= 1.3333;
      tcd *= 1.3333;
      
      glow += 0.035 * (
        Texel_color(texture, coords + tca) +
        Texel_color(texture, coords - tca) +
        Texel_color(texture, coords + tcb) +
        Texel_color(texture, coords - tcb) +
        Texel_color(texture, coords + tcc) +
        Texel_color(texture, coords - tcc) +
        Texel_color(texture, coords + tcd) +
        Texel_color(texture, coords - tcd)
      );
      
      tca *= 1.25;
      tcb *= 1.25;
      tcc *= 1.25;
      tcd *= 1.25;
      
      glow += 0.02 * (
        Texel_color(texture, coords + tca) +
        Texel_color(texture, coords - tca) +
        Texel_color(texture, coords + tcb) +
        Texel_color(texture, coords - tcb) +
        Texel_color(texture, coords + tcc) +
        Texel_color(texture, coords - tcc) +
        Texel_color(texture, coords + tcd) +
        Texel_color(texture, coords - tcd)
      );
      
      return mix((col + glow_strength * glow * (1.0 + abs(distor_k))), glow, glow_strength) * mask;
    }
  ]])
  
  update_shader_parameters()
end

function update_shader_parameters()
  screen_shader_input({
    crt_curve      = shader_crt_curve,
    glow_strength  = shader_glow_strength,
    distortion_ray = shader_distortion_ray,
    scan_lines     = shader_scan_lines
  })
end


function  client.update(dt) ---(but now delaying client init!)
    -- update shader (even if disabled)
    screen_shader_input({ time = t() })


    

        -- Check for round over (regardless of alive or dead)
-- #need to handle this better (as can't wait for this to sync to players)        
-- # or clients keep tripping to round ended and stay there

    
    -- start with the splash screen...
    if gameState == GAME_STATE.SPLASH then
        updateSplash(dt)
    
    
    elseif gameState == GAME_STATE.TITLE then
        updateTitle(dt)

    -- anything else (play/vote)
    elseif gameState >0 then
      -- Play/Vote state check
      if not share.game_ended then
        gameState = GAME_STATE.LVL_PLAY 
      else
        gameState = GAME_STATE.ROUND_OVER
      end
    
      -- --------------------------
      -- Gameplay
      -- --------------------------
      if gameState == GAME_STATE.LVL_PLAY then
        
        -- TODO: put player back to title
        if client.connected
        and not homePlayer.dead  then

            -- -- Check for round over
            -- if share.game_ended then
            --     gameState = GAME_STATE.ROUND_OVER
            -- end

            -- Check for deaths
            if not homePlayer.dead then
                home.x = homePlayer.x
                home.y = homePlayer.y
                
                -- update player (controls)

                -- move player
                updatePlayerPos(homePlayer, dt)

                -- Now check against local collisions 
                -- (e.g. have we hit ourselves - as that lag-free)
                checkLevelPlayer(share, homePlayer, clientPrivate.level)

                -- Now check against remote collisions
                -- (e.g. have we hit another player)
                if not homePlayer.dead then
                -- NOTE: Can't reset the level data here
                -- (even though it'll try)
                -- Server will do it tho when receives "dead" message
                checkLevelPlayer(share, homePlayer, share.level)
                

                -- Update local player grid status, for collisions
                -- (As can be a lag getting it from the server)
                updateLevelGrid(homePlayer, clientPrivate.level)
                end

                if homePlayer.dead then
                    -- TODO(jason): maybe diff sound for hitting walls vs. player trails
                    Sounds.die:play()
                    -- tell the server we died
                    client.send("player_dead", homePlayer.killedBy)
                    -- clear local player grid data
                    remove_player_from_grid(clientPrivate.level, homePlayer)
                end
            end
        end

        -- Look for player updates for particle effects
        -- other players...
        if share.players then        
            for id, player in pairs(share.players) do    
                if player.id ~= homePlayer.id then
                    -- Boost particles?
                    if player.boost then
                        -- update boost visual effect
                        boostPlayer(player)

                    elseif boostParticles[player.id] then 
                        -- kill particle system        
                        boostParticles[player.id].lifetime = 0
                    end
                    -- death?
                    if player.dead 
                    and (deathParticles[player.id]==nil 
                    or deathParticles[player.id].lifetime == 0) then
                        if player.killedBy == homePlayer.id then
                          Sounds.earnFrag:play()
                        end
                        explodePlayer(player)
                    elseif not player.dead 
                    and deathParticles[player.id] then
                        -- remove death particles for other players after respawn
                        -- (coz we don't get that explicit event)
                        table.remove(deathParticles, player.id)
                    end
                end
            end
        end
        -- local player
        if not homePlayer.dead then
            -- Boost particles?
            if homePlayer.boost then
                -- update boost visual effect
                boostPlayer(homePlayer)
                
            elseif boostParticles[homePlayer.id] then 
                -- kill particle system        
                boostParticles[homePlayer.id].lifetime = 0
            end
            -- explode already taken care of
        end
        
        -- Update all particle systems
        for index, psys in pairs(boostParticles) do
            psys:update(dt)
        end
        for index, psys in pairs(deathParticles) do
            psys:update(dt)
        end


      elseif gameState == GAME_STATE.ROUND_OVER then
        -- todo: anything?

      end
    end
end

function  client.draw() --(but now delaying client init!)
    -- Draw game to canvas/screen
    cls()
        
    -- Rémy's fix for "black display" issue
    -- (shouldn't need now - fixed in Sugarcoat)
    color(1) color(2)

    -- start with the splash screen...
    if gameState == GAME_STATE.SPLASH then
        drawSplash()
    
    elseif gameState == GAME_STATE.TITLE then
     --or not client.connected then

        -- draw title/connecting screen
        drawTitle(512, zoom_scale)

    elseif gameState == GAME_STATE.LVL_PLAY 
     or gameState == GAME_STATE.ROUND_OVER then
        -- --------------------------
        -- Gameplay
        -- --------------------------
    --elseif client.connected then
        -- Update camera pos
        local cam_edge=40        
        
        --log("p_gridPos = "..homePlayer.gridX..","..homePlayer.gridY)

        camx = homePlayer.x - flr(GAME_WIDTH/(2*zoom_scale))
        camy = homePlayer.y - flr(GAME_HEIGHT/(2*zoom_scale))
        camx = mid(-cam_edge, camx, clientPrivate.level.levelSize-(GAME_WIDTH/zoom_scale)+cam_edge)
        camy = mid(-cam_edge, camy, clientPrivate.level.levelSize-(GAME_HEIGHT/zoom_scale)+cam_edge)
        camera(camx*zoom_scale, camy*zoom_scale)
        
        -- Draw whole level
        drawLevel(share.levelSize, share.players, homePlayer, share.level, clientPrivate.level, zoom_scale)
        
        -- Reset camera for UI
        camera(0,0)
        drawUI(share.players)
    end
end

function checkAndGetPlayerPhoto(playerId, photoUrl)

    if playerPhotos[playerId] == nil then
        -- go and download the player photo
        playerPhotos[playerId]="pending..."
        network.async(function()
            
            local key = "photo_"..playerId
            -- create a spritesheet/surface for player photo
            -- (Process with LIGHTER palette, so it'll draw darker)
            load_png(key, photoUrl, ak54PairedLight) 
            --load_png(key, photoUrl)
                        
            -- ...and store reference to it
            playerPhotos[playerId] = key

            -- Make sure we're using the right palette
            --use_palette(ak54Paired)

        end)
    end
    -- else do nothing, as we already got it
end



function drawUI(players)
    -- Draw UI (inc. Player info)
    --pal()
    palt(0,false)

    -- Make text more "readable"
    --print("!!!",50,1,1)
    printp(0x2222, 
           0x2122, 
           0x2222, 
           0x0)
    printp_color(0, 0, 0)
    
    --
    -- In-Game UI #######
    --
    if gameState == GAME_STATE.LVL_PLAY then

      -- Players    
      if players then
          local playerPos = 1
          local G=25
          local gap = (GAME_WIDTH-50)/#players
          local xoff=(GAME_WIDTH /2) + G/2 - (#players * gap+2)


          for clientId, player in pairs(players) do
          --for i=1,#players do
            --  local clientId = share.scoreTable[i]
              local player = players[clientId]

              -- Does player have a photo?
              if player then
                if player.me 
                 and player.me.photoUrl then               
                    -- Go get the photo (if we haven't already)
                    checkAndGetPlayerPhoto(player.id, player.me.photoUrl)
                end


                local x=xoff+(playerPos-1)*(G+10)
                local y=2
                --
                -- Draw photo (if we have one?)
                --
                if playerPhotos[player.id] ~= nil 
                and playerPhotos[player.id] ~= "pending..." then
                    -- draw bg frame in player's colour
                    rectfill(x-2, y-2, x+G+2, y+G+2, player.col)
                    -- draw the actual photo
                    sugar.gfx.spritesheet(playerPhotos[player.id])
                    local w,h = sugar.gfx.surface_size(playerPhotos[player.id])
                    sugar.gfx.sspr(0, 0, w, h, x, y,  G, G)
                    -- draw a shortened version of player name (if longer than 1 chars)
                    pprint(string.sub(player.me.shortname,1,8),
                            x+12-((#player.me.shortname/2)*7), G+6, 28)
                    -- draw player score
                    pprint(player.score, x+7, G+18, 28)
                else
                    -- ...otherwise, draw a shape with player col
                    rectfill(x, y, x+G, y+G, player.col)
                end
                
                playerPos = playerPos + 1
              end --if player
          end
      end
      -- did we die?
      if homePlayer.dead and homePlayer.killedBy then
          -- display info about our "killer"
          use_font("corefont-big")
          pprintc('YOU DIED', GAME_HEIGHT/2 - 10, 24)
          use_font("corefont")
          local msg = ""
          if homePlayer.killedBy > 0 then
              if homePlayer.killedBy ~= homePlayer.id then
                  msg = share.players[homePlayer.killedBy].me.shortname.." squished you!"
              else
                  msg = "You squished yourself!"
              end
          else
              msg = "You hit a wall!"
          end
          pprintc(msg, GAME_HEIGHT/2+20, 28) --25

      end


    elseif gameState == GAME_STATE.ROUND_OVER then
        
      -- draw scoreboard
      use_font("corefont-big")
      pprint('- SCORES -', 3, 5, 45)
      use_font("corefont")

      if players then
        local playerPos = 1
        local G=17
        local yoff=45
        local scoreTable = "-----------------------------------"
        -- this uses an custom sorting function ordering by score descending
        for id,player in spairs(players, function(t,a,b) 
          return t[a].score > t[b].score    
        end) 
        do
          scoreTable = scoreTable.."\n"..
           playerPos..") "..player.me.name.." | score = "..player.score

          -- Does player have a photo?
          if player then
            if player.me 
             and player.me.photoUrl then               
                -- Go get the photo (if we haven't already)
                checkAndGetPlayerPhoto(player.id, player.me.photoUrl)
            end

            local x=8
            local y=yoff+(playerPos-1)*(G+10)
            --
            -- Draw photo (if we have one?)
            --
            if playerPhotos[player.id] ~= nil 
            and playerPhotos[player.id] ~= "pending..." then
                -- draw bg frame in player's colour
                rectfill(x-1, y-1, x+G+1, y+G+1, player.col)
                -- draw the actual photo
                sugar.gfx.spritesheet(playerPhotos[player.id])
                local w,h = sugar.gfx.surface_size(playerPhotos[player.id])
                sugar.gfx.sspr(0, 0, w, h, x, y,  G, G)
                -- draw player score + full name
                pprint(player.score.." : "..player.me.name, x+G+7, y+1, playerPos==1 and 24 or 45)
                
            else
                -- ...otherwise, draw a shape with player col
                rectfill(x, y, x+G, y+G, player.col)
            end

          end --if player

          playerPos = playerPos + 1
        end

        --log(scoreTable)
      end

      -- 
      use_font("corefont-big")
      pprintc('ROUND OVER', GAME_HEIGHT/2 - 10, 24)
      use_font("corefont")
      pprintc("Please vote for the next round...", GAME_HEIGHT/2+20, 28)

    end

    
      
    if client.connected then
        -- Draw our ping        
        pprint('Ping: ' .. client.getPing(),   85, GAME_HEIGHT-22, 49)--49 --51
    end

    if DEBUG_MODE then
        pprint('FPS: ' .. love.timer.getFPS(), 85, GAME_HEIGHT-36, 49)--49 --51
    end


    -- draw game message history
    if share.messageCount and share.messageCount > 0 then
        local yOff = share.messageCount*10
        for i=1,share.messageCount do
            local msg = share.messages[i]
            if msg then
                --local ourMsg = msg.taggedIds[1]==homePlayer.id or msg.taggedIds[2]==homePlayer.id
                pprint(msg.text, GAME_WIDTH-185, GAME_HEIGHT-22-yOff+(i*10), 
                 msg.taggedIds[2]==homePlayer.id and 24 
                 or msg.taggedIds[1]==homePlayer.id and 11 
                 or msg.col)
            end
        end
    end

    
    -- draw game timer
    if share.timer then
        local s = share.timer * 1000
        local ms = s % 1000
        s = (s - ms) / 1000
        local secs = s % 60
        s = (s - secs) / 60
        local mins = s % 60
        -- local mins = flr(share.timer/1000) % 60
        -- local secs = flr(share.timer/1000) - (minutes * 60)
        use_font("corefont-big")
        pprint(mins..":"..(secs<10 and "0" or "")..secs, 8, GAME_HEIGHT-36, 1)
        use_font("corefont")
    end

    

    -- Reset pretty print 
    -- (otherwise it affects the drawing of players)
    printp()
    printp_color()

    -- reset trans again
    palt(0,true)
end


-- print centered
function pprintc(text, y, col)
    local letterWidth = (get_font()=="corefont") and 6 or 12
    pprint(text, GAME_WIDTH/2-(#text*letterWidth)/2, y, col)
end



function love.keypressed( key, scancode, isrepeat )
    -- Debug switch
    if key=="d" and love.keyboard.isDown('lctrl') then
        DEBUG_MODE = not DEBUG_MODE
        log("Debug mode: "..(DEBUG_MODE and "Enabled" or "Disabled"))
        return
    end

    -- shader switch
    if key=="s" then
        useShader = not useShader
        shader_switch(useShader)
        log("Shader mode: "..(useShader and "Enabled" or "Disabled"))
        return
    end

    --updatePlayer(home, key)

    if not homePlayer.dead then

        -- keyboard controls
        if key == "right" 
         and (homePlayer.xDir ~= -1
         and homePlayer.yDir ~= 0) then
            homePlayer.xDir = 1
            homePlayer.yDir = 0
        end
        if key == "left" 
         and (homePlayer.xDir ~= 1
         and homePlayer.yDir ~= 0) then
            homePlayer.xDir = -1
            homePlayer.yDir = 0
        end
        if key == "up" 
         and (homePlayer.xDir ~= 0
         and homePlayer.yDir ~= 1) then
            homePlayer.xDir = 0
            homePlayer.yDir = -1
        end
        if key == "down" 
         and (homePlayer.xDir ~= 0
         and homePlayer.yDir ~= -1) then
            homePlayer.xDir = 0
            homePlayer.yDir = 1
        end

        if homePlayer.xDir ~= homePlayer.last_xDir
        and homePlayer.yDir ~= homePlayer.last_yDir then
            -- Now record player pos-change
            addWaypoint(homePlayer)

            -- test to try to reduce latency
            -- (Sends the player's input DIRECTLY to server
            --  seems a *bit* faster/more responsive)
            log("send player update...")
            client.send("player_update", homePlayer.xDir, homePlayer.yDir, homePlayer.x, homePlayer.y, homePlayer.gridX, homePlayer.gridY)
        end

    end
    -- Remember
    homePlayer.last_xDir = homePlayer.xDir
    homePlayer.last_yDir = homePlayer.yDir
end
