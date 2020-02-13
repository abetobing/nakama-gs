local nk = require("nakama")

local function match_joined_create_spawn(context, outgoing_payload,
                                         incoming_payload)

    local possible_spawn_pos = {
        {p = {x = -15, y = 0, z = 17}},
        {p = {x = 13, y = 0, z = 17}}
    }

    local objectid = {
        collection = "spawns",
        key = outgoing_payload.match.match_id
    }
    local spawns = nk.storage_read(objectid)
    local existing_spawns = spawns.value

    -- math.randomseed(os.time())
    local value = {}

    if existing_spawns ~= nil then
        value = possible_spawn_pos[1]
        existing_spawns[1] = value
    else
        value = possible_spawn_pos[0]
        existing_spawns[0] = value
    end

    local object = {
        collection = "spawns",
        -- key = context.user_id,
        -- user_id = context.user_id,
        key = outgoing_payload.match.match_id,
        value = existing_spawns
    }
    nk.storage_write({object})
    nk.logger_info(("Payload HOOK [match_joined_create_spawn]: %q"):format(
                       outgoing_payload))

end

nk.register_rt_after(match_joined_create_spawn, "MatchJoin")
