obs = obslua

-- Script settings
source_name = ""      -- Name of the source to move
move_speed = 5        -- Base movement speed in pixels per tick
speed_increment = 1   -- How much speed increases while holding key
max_speed = 20        -- Max speed
is_enabled = false    -- Movement toggle
current_speed = move_speed

-- Key states
left_pressed = false
right_pressed = false

-- UI text for toggle
toggle_text = "OFF"

-- Function to move source
function move_source()
    if not is_enabled or source_name == "" then
        return
    end

    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local settings = obs.obs_source_get_settings(source)
        local x = obs.obs_data_get_int(settings, "pos_x")
        local y = obs.obs_data_get_int(settings, "pos_y")

        if left_pressed then
            x = x - current_speed
            current_speed = math.min(current_speed + speed_increment, max_speed)
        elseif right_pressed then
            x = x + current_speed
            current_speed = math.min(current_speed + speed_increment, max_speed)
        else
            current_speed = move_speed
        end

        obs.obs_data_set_int(settings, "pos_x", x)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end

-- Timer function
function tick()
    move_source()
end

-- Script UI
function script_description()
    return "Move a source left/right with arrow keys. Toggle on/off with button."
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "source_name", "Source Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_button(props, "toggle_button", "Toggle On/Off", toggle_button_pressed)

    return props
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
end

-- Toggle button
function toggle_button_pressed(props, prop)
    is_enabled = not is_enabled
    toggle_text = is_enabled and "ON" or "OFF"
    print("Movement is now: " .. toggle_text)
    return false
end

-- Key press detection
function on_event(event)
    if event == obs.OBS_FRONTEND_EVENT_KEY_DOWN then
        local key = obs.obs_hotkey_get_key(obs.OBS_KEY_LEFT)
        if key then left_pressed = true end
        key = obs.obs_hotkey_get_key(obs.OBS_KEY_RIGHT)
        if key then right_pressed = true end
    elseif event == obs.OBS_FRONTEND_EVENT_KEY_UP then
        local key = obs.obs_hotkey_get_key(obs.OBS_KEY_LEFT)
        if key then left_pressed = false end
        key = obs.obs_hotkey_get_key(obs.OBS_KEY_RIGHT)
        if key then right_pressed = false end
    end
end

-- Script load/unload
function script_load(settings)
    obs.timer_add(tick, 16)  -- roughly 60fps
end

function script_unload()
    obs.timer_remove(tick)
end
