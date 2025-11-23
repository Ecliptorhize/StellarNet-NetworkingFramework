-- Tracks statistics for a single remote event
local EventStats = {}
EventStats.__index = EventStats

function EventStats.new()
    local self = setmetatable({}, EventStats)
    self.eventCount = 0
    self.avgPayloadSize = 0
    self.peakPayloadSize = 0
    self.avgRTT = 0
    self.errors = 0
    self.rejects = 0
    self.lastCaller = nil
    self.lastPayloadSize = 0
    self.lastCallAt = nil
    self.lastErrorReason = nil
    self.lastRejectReason = nil
    return self
end

function EventStats:Increment(payload, player)
    self.eventCount += 1
    local size = payload and #game:GetService("HttpService"):JSONEncode(payload) or 0
    self.avgPayloadSize = ((self.avgPayloadSize * (self.eventCount - 1)) + size) / self.eventCount
    self.peakPayloadSize = math.max(self.peakPayloadSize, size)
    self.lastCaller = player and player.Name or "Unknown"
    self.lastPayloadSize = size
    self.lastCallAt = os.time()
end

function EventStats:LogError(reason)
    self.errors += 1
    self.lastErrorReason = reason
end

function EventStats:LogReject(reason)
    self.rejects += 1
    self.lastRejectReason = reason
end

function EventStats:TrackRTT(duration)
    self.avgRTT = ((self.avgRTT * (self.eventCount - 1)) + duration) / math.max(self.eventCount, 1)
end

function EventStats:GetSnapshot()
    return {
        eventCount = self.eventCount,
        avgPayloadSize = self.avgPayloadSize,
        peakPayloadSize = self.peakPayloadSize,
        avgRTT = self.avgRTT,
        errors = self.errors,
        rejects = self.rejects,
        lastCaller = self.lastCaller,
        lastPayloadSize = self.lastPayloadSize,
        lastCallAt = self.lastCallAt,
        lastErrorReason = self.lastErrorReason,
        lastRejectReason = self.lastRejectReason,
    }
end

return EventStats
