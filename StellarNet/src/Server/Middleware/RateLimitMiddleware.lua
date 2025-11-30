local ExploitLogger = require(script.Parent.Parent.Logger.ExploitLogger)
local EventDefinitions = require(script.Parent.Parent.Remotes.EventDefinitions)

local DEFAULT_LIMIT = 60
local DEFAULT_WINDOW = 60
local DEFAULT_GLOBAL_LIMIT = nil
local DEFAULT_GLOBAL_WINDOW = 60
local COOLDOWN_THRESHOLD = 3
local COOLDOWN_DURATION = 10
local perRemoteLimits = {}

local bucket = {}
local globalBucket = {}
local bypassUserIds = {}
local RateLimitMiddleware = {}

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

local function shouldBypass(player)
    return player and bypassUserIds[player.UserId] == true
end

local function getBucket(store, key, limit, window, now)
    local data = store[key]
    local expired = not data or now - data.start >= window
    if expired then
        local cooldown = data and data.cooldownUntil
        if cooldown and cooldown <= now then
            cooldown = nil
        end
        data = {
            start = now,
            count = 0,
            limit = limit,
            window = window,
            violations = 0,
            cooldownUntil = cooldown,
        }
        store[key] = data
    end
    return data
end

local function isCoolingDown(data, now)
    return data.cooldownUntil ~= nil and data.cooldownUntil > now
end

local function applyLimit(data, limit, now, context, label)
    if isCoolingDown(data, now) then
        local remaining = math.max(0, data.cooldownUntil - now)
        local reason = string.format("%s rate limited (cooldown %ds)", label, remaining)
        ExploitLogger.Log(context.Player, context.RemoteName, context.Payload, reason)
        return false, reason
    end

    data.count += 1

    if data.count > limit then
        data.violations = (data.violations or 0) + 1
        local reason = string.format("%s rate limit exceeded (%d/%d)", label, data.count, limit)

        if data.violations >= COOLDOWN_THRESHOLD then
            data.cooldownUntil = now + COOLDOWN_DURATION
            data.violations = 0
            reason = string.format("%s temporary block (%ds)", label, COOLDOWN_DURATION)
        end

        ExploitLogger.Log(context.Player, context.RemoteName, context.Payload, reason)
        return false, reason
    end

    return true
end

local function executeMiddleware(context, nextFn)
    if shouldBypass(context.Player) then
        return nextFn()
    end

    local now = os.time()
    local limit, window = getLimits(context.RemoteName)
    local key = getKey(context.Player, context.RemoteName)
    local data = getBucket(bucket, key, limit, window, now)

    local ok, reason = applyLimit(data, limit, now, context, "Remote")
    if not ok then
        return false, reason
    end

    if DEFAULT_GLOBAL_LIMIT then
        local globalData = getBucket(globalBucket, context.Player.UserId, DEFAULT_GLOBAL_LIMIT, DEFAULT_GLOBAL_WINDOW, now)
        local globalOk, globalReason = applyLimit(globalData, DEFAULT_GLOBAL_LIMIT, now, context, "Global")
        if not globalOk then
            return false, globalReason
        end
    end

    return nextFn()
end

function RateLimitMiddleware.Clear(player)
    if not player then
        return
    end
    for key in pairs(bucket) do
        if string.find(key, tostring(player.UserId), 1, true) == 1 then
            bucket[key] = nil
        end
    end
    globalBucket[player.UserId] = nil
end

function RateLimitMiddleware.ConfigureDefault(limit, window)
    DEFAULT_LIMIT = limit or DEFAULT_LIMIT
    DEFAULT_WINDOW = window or DEFAULT_WINDOW
end

function RateLimitMiddleware.ConfigureGlobal(limit, window)
    DEFAULT_GLOBAL_LIMIT = limit
    DEFAULT_GLOBAL_WINDOW = window or DEFAULT_GLOBAL_WINDOW
end

function RateLimitMiddleware.ConfigureCooldown(threshold, duration)
    COOLDOWN_THRESHOLD = threshold or COOLDOWN_THRESHOLD
    COOLDOWN_DURATION = duration or COOLDOWN_DURATION
end

function RateLimitMiddleware.SetBypass(userId, shouldBypass)
    if shouldBypass then
        bypassUserIds[userId] = true
    else
        bypassUserIds[userId] = nil
    end
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
    local overridesCopy = {}
    for remoteName, data in pairs(perRemoteLimits) do
        overridesCopy[remoteName] = {Limit = data.Limit, Window = data.Window}
    end

    local bypassList = {}
    for userId in pairs(bypassUserIds) do
        table.insert(bypassList, userId)
    end

    return {
        Default = {Limit = DEFAULT_LIMIT, Window = DEFAULT_WINDOW},
        Overrides = overridesCopy,
        Global = DEFAULT_GLOBAL_LIMIT and {Limit = DEFAULT_GLOBAL_LIMIT, Window = DEFAULT_GLOBAL_WINDOW} or nil,
        Cooldown = {Threshold = COOLDOWN_THRESHOLD, Duration = COOLDOWN_DURATION},
        BypassUserIds = bypassList,
    }
end

function RateLimitMiddleware.GetPlayerState(player)
    local now = os.time()
    local userId = player and player.UserId
    if not userId then
        return {}
    end

    local state = {PerRemote = {}}
    for key, data in pairs(bucket) do
        if string.find(key, tostring(userId), 1, true) == 1 then
            local separator = string.find(key, ":", 1, true)
            local remoteName = separator and string.sub(key, separator + 1) or key
            state.PerRemote[remoteName] = {
                Count = data.count,
                Limit = data.limit,
                Window = data.window,
                ResetsIn = math.max(data.window - (now - data.start), 0),
                CooldownFor = data.cooldownUntil and math.max(data.cooldownUntil - now, 0) or nil,
                Violations = data.violations or 0,
            }
        end
    end

    local globalData = globalBucket[userId]
    if globalData then
        state.Global = {
            Count = globalData.count,
            Limit = globalData.limit,
            Window = globalData.window,
            ResetsIn = math.max(globalData.window - (now - globalData.start), 0),
            CooldownFor = globalData.cooldownUntil and math.max(globalData.cooldownUntil - now, 0) or nil,
            Violations = globalData.violations or 0,
        }
    end

    return state
end

setmetatable(RateLimitMiddleware, {
    __call = function(_, ...)
        return executeMiddleware(...)
    end,
})

return RateLimitMiddleware
