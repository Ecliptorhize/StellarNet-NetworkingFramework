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

function MetricsService.IncrementEvent(remoteName, payload)
    getStats(remoteName):Increment(payload)
end

function MetricsService.LogError(remoteName)
    getStats(remoteName):LogError()
end

function MetricsService.LogReject(remoteName)
    getStats(remoteName):LogReject()
end

function MetricsService.TrackRTT(remoteName, duration)
    getStats(remoteName):TrackRTT(duration)
end

function MetricsService.GetAll()
    return MetricsService.Stats
end

return MetricsService
