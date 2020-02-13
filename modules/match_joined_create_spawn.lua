local nk = require("nakama")

local function match_joined_create_spawn(context, outgoing_payload, incoming_payload)
    local possible_spawn_pos = {
        {pos = {x = -15, y = 0, z = 17}},
        {pos = {x = 13, y = 0, z = 17}}
    }

    local objectid = {
        collection = "spawns",
        key = context.match_id
    }
    local spawns = nk.storage_read(objectid)
    local existing_spawns = spawns.value
    nk.logger_info(("Context: %q"):format(context))
    nk.logger_info(("Existing spawns: %q"):format(existing_spawns))

    -- math.randomseed(os.time())
    local value = {}

    if existing_spawns ~= nil then
        value = possible_spawn_pos[1]
        existing_spawns[1] = value
    else
        value = possible_spawn_pos[0]
        existing_spawns[0] = value
    end
    nk.logger_info(("Value: %q"):format(value))

    local object = {
        collection = "spawns",
        -- key = context.user_id,
        -- user_id = context.user_id,
        key = context.match_id,
        value = existing_spawns
    }
    nk.storage_write({object})
    nk.logger_info(("Outgoing payload: %q"):format(outgoing_payload))
end

nk.register_rt_after(match_joined_create_spawn, "MatchJoin")
