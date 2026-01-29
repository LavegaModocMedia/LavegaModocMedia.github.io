obs = obslua

-- Configuration
scene_name = "Camera Scene"
source_name = "Atem Mini Pro"

move_speed = 5
speed_increment = 1
max_speed = 20
current_speed = move_speed
is_enabled = false

-- Key states
left_pressed = false
right_pressed = false

-- Hotkey objects
left_hotkey = nil
right_hotkey = nil

-- Move the source each tick
function move_source()
    if not is_enabled then return end

    -- Move in Program (live) scene
    local program_scene_source = obs.obs_frontend_get_current_program_scene()
    if program_scene_source then
        local program_scene = obs.obs_scene_from_source(program_scene_source)
        if program_scene then
            local item = obs.obs_scene_find_source(program_scene, source_name)
            if item then
                local pos = obs.vec2()
                obs.obs_sceneitem_get_pos(item, pos)

                if left_pressed then
                    pos.x = pos.x - current_speed
                    current_speed = math.min(current_speed + speed_increment, max_speed)
                elseif right_pressed then
                    pos.x = pos.x + current_speed
                    current_speed = math.min(current_speed + speed_increment, max_speed)
                else
                    current_speed = move_speed
                end

                obs.obs_sceneitem_set_pos(item, pos)
            end
        end
        obs.obs_source_release(program_scene_source)
    end

    -- Also move in Preview scene if Studio Mode is active
    if obs.obs_frontend_preview_program_mode_active() then
        local preview_scene_source = obs.obs_frontend_get_current_preview_scene()
        if preview_scene_source then
            local preview_scene = obs.obs_scene_from_source(preview_scene_source)
            if preview_scene then
                local item = obs.obs_scene_find_source(preview_scene, source_name)
                if item then
                    local pos = obs.vec2()
                    obs.obs_sceneitem_get_pos(item, pos)

                    -- Apply same movement
                    if left_pressed then
                        pos.x = pos.x - current_speed
                    elseif right_pressed then
                        pos.x = pos.x + current_speed
                    end

                    obs.obs_sceneitem_set_pos(item, pos)
                end
            end
            obs.obs_source_release(preview_scene_source)
        end
    end
end

-- Timer tick
function tick()
    move_source()
end

-- Toggle button
function toggle_button_pressed(props, prop)
    is_enabled = not is_enabled
    print("Movement is now: " .. (is_enabled and "ON" or "OFF"))
    return false
end

-- Script UI
function script_description()
    return "Move 'Atem Mini Pro' left/right in 'Camera Scene'. Works continuously in Program (live) scene and Preview in Studio Mode. Use hotkeys to control movement."
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_button(props, "toggle_button", "Toggle On/Off", toggle_button_pressed)
    return props
end

-- Hotkey callbacks
function left_pressed_callback(pressed)
    left_pressed = pressed
end

function right_pressed_callback(pressed)
    right_pressed = pressed
end

-- Load script
function script_load(settings)
    obs.timer_add(tick, 16)  -- ~60 FPS

    left_hotkey = obs.obs_hotkey_register_frontend("left_move", "Move Left", left_pressed_callback)
    right_hotkey = obs.obs_hotkey_register_frontend("right_move", "Move Right", right_pressed_callback)

    -- Load saved hotkeys
    local left_array = obs.obs_data_get_array(settings, "left_move")
    obs.obs_hotkey_load(left_hotkey, left_array)
    obs.obs_data_array_release(left_array)

    local right_array = obs.obs_data_get_array(settings, "right_move")
    obs.obs_hotkey_load(right_hotkey, right_array)
    obs.obs_data_array_release(right_array)
end

-- Save script
function script_save(settings)
    local left_array = obs.obs_hotkey_save(left_hotkey)
    obs.obs_data_set_array(settings, "left_move", left_array)
    obs.obs_data_array_release(left_array)

    local right_array = obs.obs_hotkey_save(right_hotkey)
    obs.obs_data_set_array(settings, "right_move", right_array)
    obs.obs_data_array_release(right_array)
end

-- Unload script
function script_unload()
    obs.timer_remove(tick)
end
