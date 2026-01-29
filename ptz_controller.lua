obs = obslua

-- Global variables
source_name = ""
zoom_level = 1.0

-- Function to update the zoom/position
function apply_transform()
    local scene_resource = obs.obs_frontend_get_current_scene()
    local scene = obs.obs_scene_from_source(scene_resource)
    local scene_item = obs.obs_scene_find_source(scene, source_name)

    if scene_item then
        local transform = obs.obs_transform_info()
        obs.obs_sceneitem_get_info(scene_item, transform)
        
        -- Apply Scale
        transform.scale.x = zoom_level
        transform.scale.y = zoom_level
        
        obs.obs_sceneitem_set_info(scene_item, transform)
    end

    obs.obs_source_release(scene_resource)
end

-- UI in OBS Script Window
function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_text(props, "source_name", "Source to Control", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_float_slider(props, "zoom_level", "Manual Zoom", 1.0, 5.0, 0.1)
    return props
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source_name")
    zoom_level = obs.obs_data_get_double(settings, "zoom_level")
    apply_transform()
end
