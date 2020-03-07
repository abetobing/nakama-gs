local nk = require("nakama")

local function matchmaker_matched(context, matched_users)
    -- nk.logger_info("--------------MatchMakerMatched----------------")
    -- nk.logger_info(("Context: %q"):format(nk.json_encode(context)))
    -- nk.logger_info(("Matched users: %q"):format(nk.json_encode(matched_users)))

    if #matched_users ~= 2 then
        return nil
    end

    local possible_spawn_pos = {
        {x = -15, y = 0, z = 17},
        {x = 13, y = 0, z = 17}
    }
    local possible_roles = {
        "P01",  -- player 01
        "E01"   -- enemy 01
    }
    -- possible_spawn_pos[#possible_spawn_pos + 1] = {x = -15, y = 0, z = 17}
    -- possible_spawn_pos[#possible_spawn_pos + 1] = {x = 13, y = 0, z = 17}

    local i = 1
    local spawnpos = {}
    local playerroles = {}
    for _, m in ipairs(matched_users) do
        -- spawnpos[m.presence["user_id"]] = possible_spawn_pos[i]
        spawnpos[i] = {
            UserId = m.presence["user_id"],
            spawnpos = possible_spawn_pos[i]
        }

        playerroles[i] = {
            UserId = m.presence["user_id"],
            role = possible_roles[i]
        }

        i = i + 1
    end

    local matchid = nk.match_create("g_jeembeem", {debug = true, expected_users = matched_users})

    -- for _, m in ipairs(matched_users) do
        local stored_object = {
            collection = "match_state",
            key = matchid,
            user_id = nil,
            value = {
                spawnpos = spawnpos,
                roles = playerroles,
                level = "level1"
            },
            permission_read = 2, permission_write = 1
        }
        nk.storage_write({stored_object})
    -- end


    --   if matched_users[1].properties["mode"] ~= "authoritative" then
    --     return nil
    --   end
    --   if matched_users[2].properties["mode"] ~= "authoritative" then
    --     return nil
    --   end

    -- nk.logger_info(("-------MatchID: %q created--------"):format(matchid))
    return matchid
end
nk.register_matchmaker_matched(matchmaker_matched)
