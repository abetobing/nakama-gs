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
  for _, message in ipairs(messages) do
    print(("Received %s from %s"):format(message.data, message.sender.username))
    local decoded = nk.json_decode(message.data)
    for k, v in pairs(decoded) do
      print(("Message key %s contains value %s"):format(k, v))
    end
    -- Broadcast message back to all
    -- local presences = nil
    dispatcher.broadcast_message(messages.op_code, message.data, nil)
  end
  return state
end

function M.match_terminate(context, dispatcher, tick, state, grace_seconds)
  local message = "Server shutting down in " .. grace_seconds .. " seconds"
  dispatcher.broadcast_message(901, message)
  return nil
end

return M