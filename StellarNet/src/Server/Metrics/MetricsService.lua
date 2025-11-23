-- Central metrics collection service
local EventStats = require(script.EventStats)
local MetricsService = {}
MetricsService.Stats = {}

local function getStats(remoteName)
    local stats = MetricsService.Stats[remoteName]
    if not stats then
        stats = EventStats.new()
        MetricsService.Stats[remoteName] = stats
    end
    return stats
end

function MetricsService.IncrementEvent(remoteName, payload, player)
    getStats(remoteName):Increment(payload, player)
end

function MetricsService.LogError(remoteName, reason)
    getStats(remoteName):LogError(reason)
end

function MetricsService.LogReject(remoteName, reason)
    getStats(remoteName):LogReject(reason)
end

function MetricsService.TrackRTT(remoteName, duration)
    getStats(remoteName):TrackRTT(duration)
end

function MetricsService.GetAll()
    return MetricsService.Stats
end

function MetricsService.GetSnapshot()
    local snapshot = {}
    for name, stats in pairs(MetricsService.Stats) do
        snapshot[name] = stats:GetSnapshot()
    end
    return snapshot
end

return MetricsService
