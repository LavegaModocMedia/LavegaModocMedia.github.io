obs = obslua

----------------------------------------------------
-- USER SETTINGS
----------------------------------------------------
source_name = ""
move_step = 10      -- pixels per move
zoom_step = 0.1     -- scale per zoom

----------------------------------------------------
-- HELPERS
----------------------------------------------------
function move_source(direction)
    local source = obs.obs_get_source_by_name(source_name)
    if not source then return end

    local settings = obs.obs_source_get_settings(source)
    local x = obs.obs_data_get_int(settings, "cx") or 0
    local y = obs.obs_data_get_int(settings, "cy") or 0
    local scale = obs.obs_data_get_double(settings, "scale") or 1

    if direction == "up" then y = y - move_step
    elseif direction == "down" then y = y + move_step
    elseif direction == "left" then x = x - move_step
    elseif direction == "right" then x = x + move_step
    end

    obs.obs_data_set_int(settings, "cx", x)
    obs.obs_data_set_int(settings, "cy", y)

    obs.obs_source_update(source, settings)
    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

function zoom_source(action)
    local source = obs.obs_get_source_by_name(source_name)
    if not source then return end

    local settings = obs.obs_source_get_settings(source)
    local scale = obs.obs_data_get_double(settings, "scale") or 1

    if action == "in" then
        scale = scale + zoom_step
    elseif action == "out" then
        scale = math.max(0.1, scale - zoom_step)
    end

    obs.obs_data_set_double(settings, "scale", scale)
    obs.obs_source_update(source, settings)
    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

----------------------------------------------------
-- SCRIPT PROPERTIES
----------------------------------------------------
function script_properties()
    local props = obs.obs_properties_create()

    local p = obs.obs_properties_add_list(
        props,
        "source",
        "Source to Control",
        obs.OBS_COMBO_TYPE_EDITABLE,
        obs.OBS_COMBO_FORMAT_STRING
    )

    local sources = obs.obs_enum_sources()
    if sources then
        for _, s in ipairs(sources) do
            local name = obs.obs_source_get_name(s)
            obs.obs_property_list_add_string(p, name, name)
        end
    end
    obs.source_list_release(sources)

    obs.obs_properties_add_int(props, "move_step", "Move Step (px)", 1, 100, 1)
    obs.obs_properties_add_float(props, "zoom_step", "Zoom Step", 0.01, 1.0, 0.01)

    return props
end

----------------------------------------------------
-- SCRIPT UPDATE
----------------------------------------------------
function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
    move_step = obs.obs_data_get_int(settings, "move_step")
    zoom_step = obs.obs_data_get_double(settings, "zoom_step")
end
