obs = obslua

local MOVE_STEP = 10
local SCALE_STEP = 0.05

-- Saved settings / defaults
local ws_ip = "10.111.0.61"         -- IP
local ws_port = "4455"              -- Port
local ws_password = ""              -- Password (optional)
local scene_name = "Camera Scene"   -- Default scene
local source_name = "Atem Mini Pro" -- Default source

function script_description()
    return "Controls a source position/scale via WebSocket.\nSaves last used scene/source and WS info between sessions."
end

-- Load saved settings
function script_load(settings)
    ws_ip = obs.obs_data_get_string(settings, "ws_ip") or ws_ip
    ws_port = obs.obs_data_get_string(settings, "ws_port") or ws_port
    ws_password = obs.obs_data_get_string(settings, "ws_password") or ws_password
    scene_name = obs.obs_data_get_string(settings, "scene_name") or scene_name
    source_name = obs.obs_data_get_string(settings, "source_name") or source_name
end

-- Save settings
function script_save(settings)
    obs.obs_data_set_string(settings, "ws_ip", ws_ip)
    obs.obs_data_set_string(settings, "ws_port", ws_port)
    obs.obs_data_set_string(settings, "ws_password", ws_password)
    obs.obs_data_set_string(settings, "scene_name", scene_name)
    obs.obs_data_set_string(settings, "source_name", source_name)
end

-- OBS script UI
function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "ws_ip", "WebSocket IP", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "ws_port", "WebSocket Port", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "ws_password", "WebSocket Password", obs.OBS_TEXT_PASSWORD)
    obs.obs_properties_add_text(props, "scene_name", "Scene Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "source_name", "Source Name", obs.OBS_TEXT_DEFAULT)
    return props
end

function script_update(settings)
    ws_ip = obs.obs_data_get_string(settings, "ws_ip") or ws_ip
    ws_port = obs.obs_data_get_string(settings, "ws_port") or ws_port
    ws_password = obs.obs_data_get_string(settings, "ws_password") or ws_password
    scene_name = obs.obs_data_get_string(settings, "scene_name") or scene_name
    source_name = obs.obs_data_get_string(settings, "source_name") or source_name
end

-- Helper: get OBS scene item
local function get_sceneitem(scene_name, source_name)
    local scenes = obs.obs_frontend_get_scenes()
    for _, scene_source in ipairs(scenes) do
        if obs.obs_source_get_name(scene_source) == scene_name then
            local scene = obs.obs_scene_from_source(scene_source)
            local item = obs.obs_scene_find_source(scene, source_name)
            obs.source_list_release(scenes)
            return item
        end
    end
    obs.source_list_release(scenes)
    return nil
end

-- Movement & scaling
function move_source(scene, source, dx, dy)
    local item = get_sceneitem(scene, source)
    if not item then return end
    local pos = obs.vec2()
    obs.obs_sceneitem_get_pos(item, pos)
    pos.x = pos.x + dx
    pos.y = pos.y + dy
    obs.obs_sceneitem_set_pos(item, pos)
end

function scale_source(scene, source, ds)
    local item = get_sceneitem(scene, source)
    if not item then return end
    local scale = obs.vec2()
    obs.obs_sceneitem_get_scale(item, scale)
    scale.x = scale.x + ds
    scale.y = scale.y + ds
    obs.obs_sceneitem_set_scale(item, scale)
end

function reset_source(scene, source)
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

-- WebSocket command handler called from Dock
function handle_command(cmd, scene, source)
    if scene and scene ~= "" then scene_name = scene end
    if source and source ~= "" then source_name = source end

    if cmd == "up" then move_source(scene_name, source_name, 0, -MOVE_STEP)
    elseif cmd == "down" then move_source(scene_name, source_name, 0, MOVE_STEP)
    elseif cmd == "left" then move_source(scene_name, source_name, -MOVE_STEP, 0)
    elseif cmd == "right" then move_source(scene_name, source_name, MOVE_STEP, 0)
    elseif cmd == "bigger" then scale_source(scene_name, source_name, 0.05)
    elseif cmd == "smaller" then scale_source(scene_name, source_name, -0.05)
    elseif cmd == "reset" then reset_source(scene_name, source_name)
    end
end
