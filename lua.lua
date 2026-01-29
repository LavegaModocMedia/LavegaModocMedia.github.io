obs = obslua

----------------------------------------------------
-- USER SETTINGS
----------------------------------------------------
source_name = ""
move_step = 10      -- pixels per move
zoom_step = 0.1     -- scale per zoom

----------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------
-- Get scene item by source name
local function get_scene_item(source_name)
    local scenes = obs.obs_frontend_get_scenes()
    if not scenes then return nil end

    for _, scene in ipairs(scenes) do
        local scene_items = obs.obs_scene_enum_items(scene)
        for _, item in ipairs(scene_items) do
            local item_source = obs.obs_sceneitem_get_source(item)
            if item_source and obs.obs_source_get_name(item_source) == source_name then
                obs.obs_source_release(item_source)
                obs.sceneitem_release(scene_items)
                obs.obs_scene_release(scene)
                return item
            end
            if item_source then obs.obs_source_release(item_source) end
        end
        obs.sceneitem_release(scene_items)
        obs.obs_scene_release(scene)
    end

    obs.sceneitem_release(scenes)
    return nil
end

-- Move scene item
local function move_source(direction)
    local item = get_scene_item(source_name)
    if not item then return end

    local pos = obs.vec2()
    pos = obs.obs_sceneitem_get_pos(item)

    if direction == "up" then
        pos.y = pos.y - move_step
    elseif direction == "down" then
        pos.y = pos.y + move_step
    elseif direction == "left" then
        pos.x = pos.x - move_step
    elseif direction == "right" then
        pos.x = pos.x + move_step
    end

    obs.obs_sceneitem_set_pos(item, pos)
end

-- Zoom scene item
local function zoom_source(action)
    local item = get_scene_item(source_name)
    if not item then return end

    local scale = obs.vec2()
    scale = obs.obs_sceneitem_get_scale(item)

    if action == "in" then
        scale.x = scale.x + zoom_step
        scale.y = scale.y + zoom_step
    elseif action == "out" then
        scale.x = math.max(0.01, scale.x - zoom_step)
        scale.y = math.max(0.01, scale.y - zoom_step)
    end

    obs.obs_sceneitem_set_scale(item, scale)
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
    obs.obs_properties_add_float(props, "zoom_step", "Zoom Step", 0.01, 2.0, 0.01)

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
