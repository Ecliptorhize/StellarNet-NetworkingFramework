-- Lightweight anomaly detector using exponential moving stats
local AnomalyDetector = {}
AnomalyDetector.__index = AnomalyDetector

local DEFAULT_ALPHA = 0.25
local DEFAULT_THRESHOLD = 3
local DEFAULT_MIN_SAMPLES = 6

function AnomalyDetector.new(config)
    local self = setmetatable({}, AnomalyDetector)
    self.alpha = config and config.Alpha or DEFAULT_ALPHA
    self.threshold = config and config.Threshold or DEFAULT_THRESHOLD
    self.minSamples = config and config.MinSamples or DEFAULT_MIN_SAMPLES
    self.records = {}
    return self
end

local function getKey(userId, remoteName)
    return tostring(userId) .. ":" .. remoteName
end

local function ensureRecord(self, key)
    local record = self.records[key]
    if not record then
        record = {
            mean = 0,
            variance = 0,
            samples = 0,
            lastAt = nil,
            score = 0,
        }
        self.records[key] = record
    end
    return record
end

local function updateStats(self, record, interval)
    local alpha = self.alpha
    if record.samples == 0 then
        record.mean = interval
        record.variance = 0
    else
        local prevMean = record.mean
        record.mean = alpha * interval + (1 - alpha) * prevMean
        local diff = interval - prevMean
        record.variance = alpha * (diff * diff) + (1 - alpha) * record.variance
    end
    record.samples += 1
end

local function computeScore(self, record, interval)
    if record.samples < self.minSamples then
        return 0, false
    end
    local variance = math.max(record.variance, 1e-6)
    local stdDev = math.sqrt(variance)
    local deviation = math.abs(interval - record.mean) / stdDev
    local anomaly = deviation >= self.threshold and interval < record.mean
    return deviation, anomaly
end

function AnomalyDetector:Observe(userId, remoteName, now)
    local key = getKey(userId, remoteName)
    local record = ensureRecord(self, key)

    if record.lastAt == nil then
        record.lastAt = now
        return false, 0, record
    end

    local interval = math.max(now - record.lastAt, 0)
    record.lastAt = now

    updateStats(self, record, interval)
    local score, anomaly = computeScore(self, record, interval)
    record.score = score
    return anomaly, score, record
end

function AnomalyDetector:Configure(config)
    if not config then
        return
    end
    if config.Alpha then
        self.alpha = config.Alpha
    end
    if config.Threshold then
        self.threshold = config.Threshold
    end
    if config.MinSamples then
        self.minSamples = config.MinSamples
    end
end

function AnomalyDetector:Clear(userId)
    if not userId then
        self.records = {}
        return
    end
    for key in pairs(self.records) do
        if string.find(key, tostring(userId), 1, true) == 1 then
            self.records[key] = nil
        end
    end
end

function AnomalyDetector:GetSnapshot()
    local copy = {}
    for key, record in pairs(self.records) do
        copy[key] = {
            mean = record.mean,
            variance = record.variance,
            samples = record.samples,
            lastAt = record.lastAt,
            score = record.score,
        }
    end
    return copy
end

return AnomalyDetector
