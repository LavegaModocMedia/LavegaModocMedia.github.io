obs = obslua

source_name = ""
move_step = 20
zoom_step = 0.1

pos_x = 0
pos_y = 0
scale = 1

function script_description()
    return "PTZ Source Controller"
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "source_name", "Source Name", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(props, "move_step", "Move Step", 1, 200, 1)
    obs.obs_properties_add_float(props, "zoom_step", "Zoom Step", 0.01, 1, 0.01)

    obs.obs_properties_add_button(props, "up", "Up", move_up)
    obs.obs_properties_add_button(props, "down", "Down", move_down)
    obs.obs_properties_add_button(props, "left", "Left", move_left)
    obs.obs_properties_add_button(props, "right", "Right", move_right)
    obs.obs_properties_add_button(props, "zin", "Zoom In", zoom_in)
    obs.obs_properties_add_button(props, "zout", "Zoom Out", zoom_out)
    obs.obs_properties_add_button(props, "reset", "Reset", reset)

    return props
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
    move_step = obs.obs_data_get_int(settings, "move_step")
    zoom_step = obs.obs_data_get_double(settings, "zoom_step")
end

function get_item()
    local scene_src = obs.obs_frontend_get_current_scene()
    if scene_src == nil then return nil end

    local scene = obs.obs_scene_from_source(scene_src)
    if scene == nil then return nil end

    return obs.obs_scene_find_source(scene, source_name)
end

function apply()
    local item = get_item()
    if item == nil then return end

    local info = obs.obs_sceneitem_get_info(item)

    info.pos.x = pos_x
    info.pos.y = pos_y
    info.scale.x = scale
    info.scale.y = scale

    obs.obs_sceneitem_set_info(item, info)
end

function move_up()    pos_y = pos_y - move_step; apply() end
function move_down()  pos_y = pos_y + move_step; apply() end
function move_left()  pos_x = pos_x - move_step; apply() end
function move_right() pos_x = pos_x + move_step; apply() end

function zoom_in()  scale = scale + zoom_step; apply() end
function zoom_out() scale = scale - zoom_step; if scale < 0.1 then scale = 0.1 end; apply() end

function reset()
    pos_x = 0
    pos_y = 0
    scale = 1
    apply()
end
