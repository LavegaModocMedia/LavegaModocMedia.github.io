obs = obslua

-- Configuration
scene_name = "Camera Scene"
source_name = "Atem Mini Pro"

move_speed = 5        -- Base speed in pixels per tick
speed_increment = 1   -- Speed increase per tick while holding
max_speed = 20        -- Maximum speed
current_speed = move_speed
is_enabled = false    -- Toggle for movement

-- Key states
left_pressed = false
right_pressed = false

-- Move the source each tick
function move_source()
    if not is_enabled then return end

    local scene_source = obs.obs_get_source_by_name(scene_name)
    if scene_source == nil then return end

    local scene = obs.obs_scene_from_source(scene_source)
    obs.obs_source_release(scene_source)
    if scene == nil then return end

    local item = obs.obs_scene_find_source(scene, source_name)
    if item == nil then return end

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
    return "Move 'Atem Mini Pro' left/right in 'Camera Scene'. Use hotkeys to control movement."
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

-- Register hotkeys
function script_load(settings)
    obs.timer_add(tick, 16)  -- roughly 60 FPS

    local left_hotkey_id = obs.obs_hotkey_register_frontend("left_move", "Move Left", left_pressed_callback)
    local right_hotkey_id = obs.obs_hotkey_register_frontend("right_move", "Move Right", right_pressed_callback)

    -- Load hotkeys from saved settings
    local hotkey_save_array = obs.obs_data_get_array(settings, "left_move")
    obs.obs_hotkey_load(left_hotkey_id, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)

    hotkey_save_array = obs.obs_data_get_array(settings, "right_move")
    obs.obs_hotkey_load(right_hotkey_id, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

function script_save(settings)
    -- Save hotkeys
    local left_hotkey_id = obs.obs_hotkey_get_id("left_move")
    local right_hotkey_id = obs.obs_hotkey_get_id("right_move")

    local left_hotkey_array = obs.obs_hotkey_save(left_hotkey_id)
    obs.obs_data_set_array(settings, "left_move", left_hotkey_array)
    obs.obs_data_array_release(left_hotkey_array)

    local right_hotkey_array = obs.obs_hotkey_save(right_hotkey_id)
    obs.obs_data_set_array(settings, "right_move", right_hotkey_array)
    obs.obs_data_array_release(right_hotkey_array)
end

function script_unload()
    obs.timer_remove(tick)
end
