

local ui = castle.ui

local circles = {}


-- All the UI-related code is just in this function. Everything below it is normal game code!

function castle.uiupdate()

    ui.markdown([[
## Lite Bikez
Welcome to The Grid.

The GOAL is... to survive!
]])

-- Only if "host" of session 
-- (TODO: Allow subsequent hosts!)
if home and home.id == 1 
 or not USE_CASTLE_CONFIGs then

    ui.markdown([[
#### Level Select
]])

    ui.dropdown("Choose the battle arena:", levelName, LEVEL_LIST,
        { onChange=function(value) 
            -- Get details of selected level            
            log("value="..value)
            -- levelDataPath = LEVEL_DATA_LIST[value].imgData
            -- levelGfxPath = LEVEL_DATA_LIST[value].imgGfx

            client.send("level_select", 
                value,
                LEVEL_DATA_LIST[value].imgData,
                LEVEL_DATA_LIST[value].imgGfx)
        end}
    )
    
    --ui.markdown('![](https://raw.githubusercontent.com/Liquidream/lite-bikez/dev/src/'..levelGfxPath..')')
    ui.markdown('![](https://api.castle.games/api/hosted/@liquidream/lite-bikez-wip/src/'..levelGfxPath..')')

    ui.markdown([[
#### Shader settings
hello from Remy - I didn't consult Paul before doing this ui bit so this is all going to get deleted probably... :,(
but hey the game's great! :D
]])

    ui.toggle("Shader OFF", "Shader ON", useShader,
        { onToggle = function()
            useShader = not useShader
            shader_switch(useShader)
        end }
    )
    
    local refresh = false
    shader_crt_curve      = ui.slider("CRT Curve",      shader_crt_curve,      0, 0.25, { step = 0.0025, onChange = function() refresh = true end })
    shader_glow_strength  = ui.slider("Glow Strength",  shader_glow_strength,  0, 1,    { step = 0.01, onChange = function() refresh = true end })
    shader_distortion_ray = ui.slider("Distortion Ray", shader_distortion_ray, 0, 10,   { step = 0.1, onChange = function() refresh = true end })
    shader_scan_lines     = ui.slider("Scan Lines",     shader_scan_lines,     0, 1.0,  { step = 0.01, onChange = function() refresh = true end })
    if refresh then update_shader_parameters() end
    
    ui.markdown([[
#### B-)
]])
end
    -- -- Button for adding circles
    -- if ui.button('add circle') then
    --     table.insert(circles, {
    --         x = love.graphics.getWidth() * math.random(),
    --         y = love.graphics.getHeight() * math.random(),
    --         radius = math.random(30, 105),
    --         color = ({ 'red', 'blue', 'green' })[math.floor(3 * math.random()) + 1]
    --     })
    -- end

    -- -- Section per circle
    -- for i, circle in ipairs(circles) do
    --     ui.section('circle ' .. i, function()
    --         -- Labels of inputs (such as 'color', 'x', etc.) need to be unique only within each section
    --         circle.color = ui.radioButtonGroup('color', circle.color, { 'red', 'blue', 'green' })
    --         circle.x = ui.slider('x', circle.x, 0, love.graphics.getWidth())
    --         circle.y = ui.slider('y', circle.y, 0, love.graphics.getHeight())
    --         circle.radius = ui.slider('radius', circle.radius, 30, 105)
    --     end)
    -- end
end
