local nk = require("nakama")

local M = {}

function M.match_init(context, setupstate)
  local gamestate = {
    presences = {}
  }
  local tickrate = 20 -- per sec
  local label = ""
  return gamestate, tickrate, label
end

function M.match_join_attempt(context, dispatcher, tick, state, presence, metadata)
  local acceptuser = true
  return state, acceptuser
end

function M.match_join(context, dispatcher, tick, state, presences)
  for _, presence in ipairs(presences) do
    state.presences[presence.session_id] = presence
  end
  return state
end

function M.match_leave(context, dispatcher, tick, state, presences)
  for _, presence in ipairs(presences) do
    state.presences[presence.session_id] = nil
    nk.logger_info(("---- someone leave the match: %q -------"):format(presence.user_id))
end
  return state
end

function M.match_loop(context, dispatcher, tick, state, messages)
  for _, presence in pairs(state.presences) do
    print(("Presence %s named %s"):format(presence.user_id, presence.username))
  end
  for _, msg in ipairs(messages) do
    nk.logger_info(("Received MSG: %s"):format(nk.json_encode(msg)))
    nk.logger_info(("Received %s from %s"):format(msg.data, msg.sender.username))
    local decoded = nk.json_decode(msg.data)
    for k, v in pairs(decoded) do
        nk.logger_info(("Message key %s contains value %s"):format(k, v))
    end
    -- Broadcast message back to all
    -- local presences = nil
    if msg ~= nil
    then
        -- Process based on op_code
        if msg.op_code == 201
        then
            dispatcher.broadcast_message(msg.op_code, msg.data, state.presences, msg.sender)
        end
    end
  end
  return state
end

function M.match_terminate(context, dispatcher, tick, state, grace_seconds)
  local message = "Server shutting down in " .. grace_seconds .. " seconds"
  dispatcher.broadcast_message(901, message)
  return nil
end

return M