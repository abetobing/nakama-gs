local nk = require("nakama")

local function matchmaker_matched(context, matched_users)
    nk.logger_info("--------------MatchMakerMatched----------------")
    nk.logger_info(("Context: %q"):format(nk.json_encode(context)))
    nk.logger_info(("Matched users: %q"):format(nk.json_encode(matched_users)))

    if #matched_users ~= 2 then
        return nil
    end

    local possible_spawn_pos = {
        {x = -15, y = 0, z = 17},
        {x = 13, y = 0, z = 17}
    }
    -- possible_spawn_pos[#possible_spawn_pos + 1] = {x = -15, y = 0, z = 17}
    -- possible_spawn_pos[#possible_spawn_pos + 1] = {x = 13, y = 0, z = 17}

    local i = 1
    local spawnpos = {}
    for _, m in ipairs(matched_users) do
        -- spawnpos[m.presence["user_id"]] = possible_spawn_pos[i]
        spawnpos[i] = {
            UserId = m.presence["user_id"],
            spawnpos = possible_spawn_pos[i]
        }
        i = i + 1
    end
    for _, m in ipairs(matched_users) do
        local stored_object = {
            collection = "match_metadata",
            key = m.presence["user_id"],
            user_id = m.presence["user_id"],
            value = {spawnpos = spawnpos}
        }
        nk.storage_write({stored_object})
    end

    local matchid = nk.match_create("g_jeembeem", {debug = true, expected_users = matched_users})

    --   if matched_users[1].properties["mode"] ~= "authoritative" then
    --     return nil
    --   end
    --   if matched_users[2].properties["mode"] ~= "authoritative" then
    --     return nil
    --   end

    nk.logger_info(("--------%q--------"):format(matchid))
    return matchid
end
nk.register_matchmaker_matched(matchmaker_matched)
