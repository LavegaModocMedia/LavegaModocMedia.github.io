obs = obslua

-- SETTINGS
local MOVE_STEP = 10
local SCALE_STEP = 0.05

-- Saved defaults / persistent storage
local scene_name = "Camera Scene"
local source_name = "Atem Mini Pro"

-- Called on script description
function script_description()
    return "Controls a source via WebSocket from HTML Dock and arrow keys.\nSupports Move, Scale, Reset, and saves last scene/source."
end

-- Load saved settings
function script_load(settings)
    scene_name = obs.obs_data_get_string(settings, "scene_name") or scene_name
    source_name = obs.obs_data_get_string(settings, "source_name") or source_name
end

-- Save settings
function script_save(settings)
    obs.obs_data_set_string(settings, "scene_name", scene_name)
    obs.obs_data_set_string(settings, "source_name", source_name)
end

-- Script UI for OBS properties
function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "scene_name", "Scene Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "source_name", "Source Name", obs.OBS_TEXT_DEFAULT)
    return props
end

-- Update settings
function script_update(settings)
    scene_name = obs.obs_data_get_string(settings, "scene_name") or scene_name
    source_name = obs.obs_data_get_string(settings, "source_name") or source_name
end

-- Utility: get scene item
local function get_sceneitem(scene, source)
    local sources = obs.obs_frontend_get_scenes()
    for _, s in ipairs(sources) do
        if obs.obs_source_get_name(s) == scene then
            local sc = obs.obs_scene_from_source(s)
            local item = obs.obs_scene_find_source(sc, source)
            obs.source_list_release(sources)
            return item
        end
    end
    obs.source_list_release(sources)
    return nil
end

-- Move source
local function move_source(scene, source, dx, dy)
    local item = get_sceneitem(scene, source)
    if not item then return end
    local pos = obs.vec2()
    obs.obs_sceneitem_get_pos(item, pos)
    pos.x = pos.x + dx
    pos.y = pos.y + dy
    obs.obs_sceneitem_set_pos(item, pos)
end

-- Scale source
local function scale_source(scene, source, ds)
    local item = get_sceneitem(scene, source)
    if not item then return end
    local scale = obs.vec2()
    obs.obs_sceneitem_get_scale(item, scale)
    scale.x = scale.x + ds
    scale.y = scale.y + ds
    obs.obs_sceneitem_set_scale(item, scale)
end

-- Reset source
local function reset_source(scene, source)
    local item = get_sceneitem(scene, source)
    if not item then return end
    local pos = obs.vec2()
    pos.x = 0
    pos.y = 0
    local scale = obs.vec2()
    scale.x = 1
    scale.y = 1
    obs.obs_sceneitem_set_pos(item, pos)
    obs.obs_sceneitem_set_scale(item, scale)
end

-- Handle Dock commands
function handle_command(cmd, scene, source)
    if scene and scene ~= "" then scene_name = scene end
    if source and source ~= "" then source_name = source end

    if cmd == "up" then
        move_source(scene_name, source_name, 0, -MOVE_STEP)
    elseif cmd == "down" then
        move_source(scene_name, source_name, 0, MOVE_STEP)
    elseif cmd == "left" then
        move_source(scene_name, source_name, -MOVE_STEP, 0)
    elseif cmd == "right" then
        move_source(scene_name, source_name, MOVE_STEP, 0)
    elseif cmd == "bigger" then
        scale_source(scene_name, source_name, SCALE_STEP)
    elseif cmd == "smaller" then
        scale_source(scene_name, source_name, -SCALE_STEP)
    elseif cmd == "reset" then
        reset_source(scene_name, source_name)
    end
end

-- ARROW KEYS SUPPORT
local function on_event(event)
    if event == obs.OBS_FRONTEND_EVENT_KEY_PRESSED then
        local key = obs.obs_frontend_get_current_key()
        if key == obs.OBS_KEY_UP then
            move_source(scene_name, source_name, 0, -MOVE_STEP)
        elseif key == obs.OBS_KEY_DOWN then
            move_source(scene_name, source_name, 0, MOVE_STEP)
        elseif key == obs.OBS_KEY_LEFT then
            move_source(scene_name, source_name, -MOVE_STEP, 0)
        elseif key == obs.OBS_KEY_RIGHT then
            move_source(scene_name, source_name, MOVE_STEP, 0)
        end
    end
end

-- OBS callback
function script_load_post()
    obs.obs_frontend_add_event_callback(function(event)
        -- Only move keys when Dock is connected
        if identified then
            local keyboard = obs.obs_frontend_get_key_pressed()
            if keyboard[obs.OBS_KEY_UP] then move_source(scene_name, source_name, 0, -MOVE_STEP) end
            if keyboard[obs.OBS_KEY_DOWN] then move_source(scene_name, source_name, 0, MOVE_STEP) end
            if keyboard[obs.OBS_KEY_LEFT] then move_source(scene_name, source_name, -MOVE_STEP, 0) end
            if keyboard[obs.OBS_KEY_RIGHT] then move_source(scene_name, source_name, MOVE_STEP, 0) end
        end
    end)
end
