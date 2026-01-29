obs = obslua

------------------------------------------------
-- VARIABLES
------------------------------------------------
source_name = ""
move_step = 20
zoom_step = 0.1

pos_x = 0
pos_y = 0
scale = 1

------------------------------------------------
-- DESCRIPTION
------------------------------------------------
function script_description()
    return "Camera Source Controller (Move & Zoom)\nControl one source's transform from OBS."
end

------------------------------------------------
-- UI PROPERTIES
------------------------------------------------
function script_properties()
    props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "source_name", "Source Name", obs.OBS_TEXT_DEFAULT)

    obs.obs_properties_add_int(props, "move_step", "Move Pixels", 1, 200, 1)
    obs.obs_properties_add_float(props, "zoom_step", "Zoom Amount", 0.01, 1.0, 0.01)

    obs.obs_properties_add_button(props, "up", "⬆ Up", move_up)
    obs.obs_properties_add_button(props, "down", "⬇ Down", move_down)
    obs.obs_properties_add_button(props, "left", "⬅ Left", move_left)
    obs.obs_properties_add_button(props, "right", "➡ Right", move_right)

    obs.obs_properties_add_button(props, "zin", "➕ Zoom In", zoom_in)
    obs.obs_properties_add_button(props, "zout", "➖ Zoom Out", zoom_out)

    obs.obs_properties_add_button(props, "reset", "🔄 Reset", reset_transform)

    return props
end

------------------------------------------------
-- UPDATE SETTINGS
------------------------------------------------
function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
    move_step = obs.obs_data_get_int(settings, "move_step")
    zoom_step = obs.obs_data_get_double(settings, "zoom_step")
end

------------------------------------------------
-- FIND SOURCE IN CURRENT SCENE
------------------------------------------------
function get_scene_item()
    local scene = obs.obs_frontend_get_current_scene()
    if scene == nil then return nil end

    local scene_obj = obs.obs_scene_from_source(scene)
    if scene_obj == nil then return nil end

    return obs.obs_scene_find_source(scene_obj, source_name)
end

------------------------------------------------
-- APPLY TRANSFORM
------------------------------------------------
function apply_transform()
    local item = get_scene_item()
    if item == nil then return end

    local transform = obs.obs_sceneitem_get_transform(item)

    transform.pos.x = pos_x
    transform.pos.y = pos_y
    transform.scale.x = scale
    transform.scale.y = scale

    obs.obs_sceneitem_set_transform(item, transform)
end

------------------------------------------------
-- MOVE FUNCTIONS
------------------------------------------------
function move_up()
    pos_y = pos_y - move_step
    apply_transform()
end

function move_down()
    pos_y = pos_y + move_step
    apply_transform()
end

function move_left()
    pos_x = pos_x - move_step
    apply_transform()
end

function move_right()
    pos_x = pos_x + move_step
    apply_transform()
end

------------------------------------------------
-- ZOOM FUNCTIONS
------------------------------------------------
function zoom_in()
    scale = scale + zoom_step
    apply_transform()
end

function zoom_out()
    scale = scale - zoom_step
    if scale < 0.1 then scale = 0.1 end
    apply_transform()
end

------------------------------------------------
-- RESET
------------------------------------------------
function reset_transform()
    pos_x = 0
    pos_y = 0
    scale = 1
    apply_transform()
end

------------------------------------------------
-- HOTKEY SUPPORT
------------------------------------------------
function script_load(settings)
    obs.obs_hotkey_register_frontend("move_up", "Camera Move Up", move_up)
    obs.obs_hotkey_register_frontend("move_down", "Camera Move Down", move_down)
    obs.obs_hotkey_register_frontend("move_left", "Camera Move Left", move_left)
    obs.obs_hotkey_register_frontend("move_right", "Camera Move Right", move_right)
    obs.obs_hotkey_register_frontend("zoom_in", "Camera Zoom In", zoom_in)
    obs.obs_hotkey_register_frontend("zoom_out", "Camera Zoom Out", zoom_out)
end
