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
function script_description()
    return "Camera Source Controller (Move & Zoom)"
end

------------------------------------------------
function script_properties()
    props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "source_name", "Source Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(props, "move_step", "Move Pixels", 1, 200, 1)
    obs.obs_properties_add_float(props, "zoom_step", "Zoom Amount", 0.01, 1.0, 0.01)

    obs.obs_properties_add_button(props, "up", "Up", move_up)
    obs.obs_properties_add_button(props, "down", "Down", move_down)
    obs.obs_properties_add_button(props, "left", "Left", move_left)
    obs.obs_properties_add_button(props, "right", "Right", move_right)

    obs.obs_properties_add_button(props, "zin", "Zoom In", zoom_in)
    obs.obs_properties_add_button(props, "zout", "Zoom Out", zoom_out)

    obs.obs_properties_add_button(props, "reset", "Reset", reset_transform)

    return props
end

------------------------------------------------
function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
    move_step = obs.obs_data_get_int(settings, "move_step")
    zoom_step = obs.obs_data_get_double(settings, "zoom_step")
end

------------------------------------------------
-- GET SCENE ITEM
------------------------------------------------
function get_scene_item()
    local scene_source = obs.obs_frontend_get_current_scene()
    if scene_source == nil then return nil end

    local scene = obs.obs_scene_from_source(scene_source)
    if scene == nil then return nil end

    return obs.obs_scene_find_source(scene, source_name)
end

------------
