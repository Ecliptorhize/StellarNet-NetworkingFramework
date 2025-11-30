-- AI-style anomaly guard that flags abnormal call bursts
local ExploitLogger = require(script.Parent.Parent.Logger.ExploitLogger)
local AnomalyDetector = require(script.Parent.Parent.AI.AnomalyDetector)

local detector = AnomalyDetector.new()
local enabled = true
local blockOnAnomaly = false

local AIMiddleware = {}

local function buildReason(remoteName, score)
    return string.format("AI anomaly on %s (z=%.2f)", remoteName, score)
end

local function executeMiddleware(context, nextFn)
    if not enabled then
        return nextFn()
    end

    local now = tick()
    local anomaly, score = detector:Observe(context.Player.UserId, context.RemoteName, now)
    if anomaly then
        local reason = buildReason(context.RemoteName, score)
        ExploitLogger.Log(context.Player, context.RemoteName, context.Payload, reason)
        if blockOnAnomaly then
            return false, reason
        end
    end

    return nextFn()
end

function AIMiddleware.Configure(options)
    options = options or {}
    if options.Enabled ~= nil then
        enabled = options.Enabled
    end
    if options.BlockOnAnomaly ~= nil then
        blockOnAnomaly = options.BlockOnAnomaly
    end
    detector:Configure(options)
end

function AIMiddleware.Clear(player)
    detector:Clear(player and player.UserId or nil)
end

function AIMiddleware.GetState()
    return {
        Enabled = enabled,
        BlockOnAnomaly = blockOnAnomaly,
        Detector = detector:GetSnapshot(),
    }
end

setmetatable(AIMiddleware, {
    __call = function(_, ...)
        return executeMiddleware(...)
    end,
})

return AIMiddleware
