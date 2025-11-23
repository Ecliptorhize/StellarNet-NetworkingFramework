-- Simple token bucket rate limiter per player per remote
local Players = game:GetService("Players")
local ExploitLogger = require(script.Parent.Parent.Logger.ExploitLogger)

local LIMIT_PER_MIN = 60
local WINDOW = 60

local bucket = {}

local function getKey(player, remote)
    return player.UserId .. ":" .. remote
end

local function RateLimitMiddleware(context, nextFn)
    local key = getKey(context.Player, context.RemoteName)
    local data = bucket[key]
    local now = os.time()
    if not data or now - data.start >= WINDOW then
        data = {start = now, count = 0}
        bucket[key] = data
    end
    data.count += 1
    if data.count > LIMIT_PER_MIN then
        ExploitLogger.Log(context.Player, context.RemoteName, context.Payload, "Rate limit exceeded")
        return false, "Rate limited"
    end
    return nextFn()
end

function RateLimitMiddleware.Clear(player)
    for key in pairs(bucket) do
        if string.find(key, tostring(player.UserId), 1, true) == 1 then
            bucket[key] = nil
        end
    end
end

return RateLimitMiddleware
