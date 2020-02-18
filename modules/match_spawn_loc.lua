local nk = require("nakama")

local function request_match_spawn_loc(context, payload)
    nk.logger_info(
        ("Payload  RPC [request_match_spawn_loc]: %q"):format(payload))

    -- "payload" is bytes sent by the client we'll JSON decode it.
    local json = nk.json_decode(payload)
    local spawnloc = nk.storage_read({
        collection = "spawns",
        key = json.match_id,
    })

    return nk.json_encode(spawnloc)
end

nk.register_rpc(request_match_spawn_loc, "request_match_spawn_loc")
