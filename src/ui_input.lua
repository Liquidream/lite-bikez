

local ui = castle.ui

local circles = {}


-- All the UI-related code is just in this function. Everything below it is normal game code!

function castle.uiupdate()

    ui.markdown('![](assets/title-text.png)')   

    ui.markdown([[
Welcome to The Grid.

The GOAL is... to survive!
]])

--seed_num = ui.numberInput("Test", seed_num or 0)

ui.section("Controls", function()

    ui.markdown([[
### Player Controls
**⬆⬇⬅➡** = *Turn*

**\[SPACE\]** = *Boost!*

### Advanced controls
**S** = *Toggle GFX Shader*
]])

end)


    --log("gameState = "..gameState)

    -- Only allow level select/vote during gameplay
    -- TODO: only allow this at the END of a session (score screen)
    if gameState == GAME_STATE.ROUND_OVER then

        ui.markdown([[
#### Level Select
]])
        ui.dropdown("Vote to change battle arena:", client.home.vote or levelName, LEVEL_LIST,
            { onChange=function(value) 
                -- Get details of selected level            
                log("value="..value)
                client.home.vote = value

                client.send("level_vote", 
                    value,
                    LEVEL_DATA_LIST[value].imgData,
                    LEVEL_DATA_LIST[value].imgGfxList)

                -- client.send("level_select", 
                --     value,
                --     LEVEL_DATA_LIST[value].imgData,
                --     LEVEL_DATA_LIST[value].imgGfxList)
            end}
        )
        if client.home.vote then
            ui.markdown([[
*(Voted)*
]])
        end

        if not client.home.vote then
          -- show current map
          ui.markdown('![]('..levelGfxPaths[1]..')')    
        else
          -- show map that was voted for
          ui.markdown('![]('..LEVEL_DATA_LIST[client.home.vote].imgGfxList[1]..')')    
        end
        --ui.markdown('![]('..levelGfxPaths[1]..')')    
    
    end -- if vote allowed


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
