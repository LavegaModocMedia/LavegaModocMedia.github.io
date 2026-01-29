obs = obslua

----------------------------------------------------
-- USER SETTINGS
----------------------------------------------------
source_name = ""    -- name of the source to move
move_speed = 5      -- pixels per key press
enabled = true      -- whether movement is active

----------------------------------------------------
-- INTERNAL STATE
----------------------------------------------------
hotkey_left = nil
hotkey_right = nil

----------------------------------------------------
-- HELPERS
----------------------------------------------------
local function get_scene_item(source_name)
    local scene = obs.obs_frontend_get_current_scene()
    if not scene then return nil end
    local scene = obs.obs_scene_from_source(scene)
    
    local items = obs.obs_scene_enum_items(scene)
    for _, item in ipairs(items) do
        local item_source = obs.obs_sceneitem_get_source(item)
        if item_source and obs.obs_source_get_name(item_source) == source_name then
            if item_source then obs.obs_source_release(item_source) end
            obs.sceneitem_release(items)
            return item
        end
        if item_source then obs.obs_source_release(item_source) end
    end
    obs.sceneitem_release(items)
    return nil
end

local function move_source(dx)
    if not enabled then return end  -- skip if disabled

    local item = get_scene_item(source_name)
    if not item then return end

    local pos = obs.vec2()
    pos = obs.obs_sceneitem_get_pos(item)
    pos.x = pos.x + dx
    obs.obs_sceneitem_set_pos(item, pos)
end

----------------------------------------------------
-- HOTKEY CALLBACKS
----------------------------------------------------
function move_left(pressed)
    if not pressed then return end
    move_source(-move_speed)
end

function move_right(pressed)
    if not pressed then return end
    move_source(move_speed)
end

----------------------------------------------------
-- SCRIPT PROPERTIES
----------------------------------------------------
function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "source", "Source Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(props, "move_speed", "Move Speed (px)", 1, 50, 1)

    -- Toggle On/Off button
    local p = obs.obs_properties_add_button(props, "toggle_enabled", "Toggle On/Off", function()
        enabled = not enabled
        if enabled then
            obs.script_log(obs.LOG_INFO, "Source movement ENABLED")
        else
            obs.script_log(obs.LOG_INFO, "Source movement DISABLED")
        end
    end)

    return props
end

----------------------------------------------------
-- SCRIPT UPDATE
----------------------------------------------------
function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
    move_speed = obs.obs_data_get_int(settings, "move_speed")
end

----------------------------------------------------
-- HOTKEY REGISTRATION
----------------------------------------------------
function script_load(settings)
    hotkey_left = obs.obs_hotkey_register_frontend("move_left", "Move Source Left", move_left)
    hotkey_right = obs.obs_hotkey_register_frontend("move_right", "Move Source Right", move_right)

    -- load saved hotkeys
    local hotkey_save_array = obs.obs_data_get_array(settings, "hotkeys")
    obs.obs_hotkey_load(hotkey_left, hotkey_save_array)
    obs.obs_hotkey_load(hotkey_right, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

function script_save(settings)
    local hotkey_save_array = obs.obs_hotkey_save(hotkey_left)
    obs.obs_hotkey_save(hotkey_right, hotkey_save_array)
    obs.obs_data_set_array(settings, "hotkeys", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end
