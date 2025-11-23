-- Tracks statistics for a single remote event
local EventStats = {}
EventStats.__index = EventStats

function EventStats.new()
    local self = setmetatable({}, EventStats)
    self.eventCount = 0
    self.avgPayloadSize = 0
    self.avgRTT = 0
    self.errors = 0
    self.rejects = 0
    return self
end

function EventStats:Increment(payload)
    self.eventCount += 1
    local size = payload and #game:GetService("HttpService"):JSONEncode(payload) or 0
    self.avgPayloadSize = ((self.avgPayloadSize * (self.eventCount - 1)) + size) / self.eventCount
end

function EventStats:LogError()
    self.errors += 1
end

function EventStats:LogReject()
    self.rejects += 1
end

function EventStats:TrackRTT(duration)
    self.avgRTT = ((self.avgRTT * (self.eventCount - 1)) + duration) / math.max(self.eventCount, 1)
end

return EventStats
