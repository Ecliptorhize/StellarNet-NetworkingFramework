-- Simple token bucket rate limiter per player per remote
local Players = game:GetService("Players")
local ExploitLogger = require(script.Parent.Parent.Logger.ExploitLogger)
local EventDefinitions = require(script.Parent.Parent.Remotes.EventDefinitions)

local DEFAULT_LIMIT = 60
local DEFAULT_WINDOW = 60
local perRemoteLimits = {}

local bucket = {}

local function getKey(player, remote)
    return player.UserId .. ":" .. remote
end

local function getLimits(remoteName)
    local override = perRemoteLimits[remoteName]
    local definition = EventDefinitions[remoteName]
    local rateConfig = override or (definition and definition.RateLimit)

    local limit = DEFAULT_LIMIT
    local window = DEFAULT_WINDOW

    if rateConfig then
        limit = rateConfig.Limit or limit
        window = rateConfig.Window or window
    end

    return limit, window
end

local function RateLimitMiddleware(context, nextFn)
    local limit, window = getLimits(context.RemoteName)
    local key = getKey(context.Player, context.RemoteName)
    local data = bucket[key]
    local now = os.time()
    local expired = not data or now - data.start >= window

    if expired then
        data = {start = now, count = 0}
        bucket[key] = data
    end

    data.count += 1

    if data.count > limit then
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

function RateLimitMiddleware.ConfigureDefault(limit, window)
    DEFAULT_LIMIT = limit or DEFAULT_LIMIT
    DEFAULT_WINDOW = window or DEFAULT_WINDOW
end

function RateLimitMiddleware.SetRemoteLimit(remoteName, limit, window)
    perRemoteLimits[remoteName] = {
        Limit = limit,
        Window = window or DEFAULT_WINDOW,
    }
end

function RateLimitMiddleware.ClearRemoteLimit(remoteName)
    perRemoteLimits[remoteName] = nil
end

function RateLimitMiddleware.GetLimits()
    return {
        Default = {Limit = DEFAULT_LIMIT, Window = DEFAULT_WINDOW},
        Overrides = perRemoteLimits,
    }
end

return RateLimitMiddleware
