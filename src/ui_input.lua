

local ui = castle.ui

local circles = {}


-- All the UI-related code is just in this function. Everything below it is normal game code!

function castle.uiupdate()

    ui.markdown([[
## Lite Bikez
Welcome to The Grid.

The GOAL is... to survive!
]])

ui.section("Controls", function()

    ui.markdown([[
### Player Controls
**⬆⬇⬅➡** = *Turn Bike*

**\[SPACE\]** = *Boost!*

### Advanced controls
**S** = *Toggle GFX Shader*
]])

end)

    -- Only if "host" of session 
    -- (TODO: Allow subsequent hosts!)

    if (client.home and client.home.id==1)
      or not USE_CASTLE_CONFIG 
      then

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
    
    else
        ui.markdown([[
#### Current Level
    ]])
        
    end -- if "host"

    ui.markdown('![]('..levelGfxPath..')')    

    ui.markdown([[
#### Other Settings
]])

    ui.section("Shader settings", function()

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

    end)



end
