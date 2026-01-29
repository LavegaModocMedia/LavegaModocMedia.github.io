obs = obslua
socket = require("socket")

host = "127.0.0.1"
port = 4455

server = nil
client = nil

source_name = "Camera"

move_speed = 10
zoom_speed = 0.05

------------------------------------------------

function script_description()
    return "WebSocket Remote Source Controller"
end

------------------------------------------------

function start_server()
    server = assert(socket.bind(host, port))
    server:settimeout(0)
end

------------------------------------------------

function script_load(settings)
    start_server()
end

------------------------------------------------

function move_source(dx, dy)
    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then return end

    local scene = obs.obs_frontend_get_current_scene()
    local scene_source = obs.obs_scene_from_source(scene)

    local item = obs.obs_scene_find_source(scene_source, source_name)
    if item == nil then return end

    local pos = obs.vec2()
    obs.obs_sceneitem_get_pos(item, pos)

    pos.x = pos.x + dx
    pos.y = pos.y + dy

    obs.obs_sceneitem_set_pos(item, pos)

    obs.obs_source_release(source)
end

------------------------------------------------

function scale_source(amount)
    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then return end

    local scene = obs.obs_frontend_get_current_scene()
    local scene_source = obs.obs_scene_from_source(scene)

    local item = obs.obs_scene_find_source(scene_source, source_name)
    if item == nil then return end

    local scale = obs.vec2()
    obs.obs_sceneitem_get_scale(item, scale)

    scale.x = scale.x + amount
    scale.y = scale.y + amount

    obs.obs_sceneitem_set_scale(item, scale)

    obs.obs_source_release(source)
end

------------------------------------------------

function handle_message(msg)
    if msg == "up" then move_source(0, -move_speed) end
    if msg == "down" then move_source(0, move_speed) end
    if msg == "left" then move_source(-move_speed, 0) end
    if msg == "right" then move_source(move_speed, 0) end
    if msg == "zoom_in" then scale_source(zoom_speed) end
    if msg == "zoom_out" then scale_source(-zoom_speed) end
end

------------------------------------------------

function script_tick(seconds)
    if server == nil then return end

    if client == nil then
        client = server:accept()
        if client then client:settimeout(0) end
    end

    if client then
        local msg, err = client:receive()
        if msg then
            handle_message(msg)
        end
    end
end
