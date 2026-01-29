obs = obslua

local MOVE_STEP = 10
local SCALE_STEP = 0.05

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

-- WebSocket command handler
function handle_command(cmd, scene, source)
    if cmd == "up" then move_source(scene, source, 0, -MOVE_STEP)
    elseif cmd == "down" then move_source(scene, source, 0, MOVE_STEP)
    elseif cmd == "left" then move_source(scene, source, -MOVE_STEP, 0)
    elseif cmd == "right" then move_source(scene, source, MOVE_STEP, 0)
    elseif cmd == "bigger" then scale_source(scene, source, SCALE_STEP)
    elseif cmd == "smaller" then scale_source(scene, source, -SCALE_STEP)
    elseif cmd == "reset" then reset_source(scene, source)
    end
end
