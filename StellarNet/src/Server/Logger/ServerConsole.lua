-- Simple command interface for diagnostics
local Players = game:GetService("Players")
local MetricsService = require(script.Parent.Parent.Metrics.MetricsService)
local ExploitLogger = require(script.ExploitLogger)
local PermissionService = require(script.Parent.Parent.Permissions.PermissionService)
local PermissionLevels = require(script.Parent.Parent.Permissions.PermissionLevels)
local RateLimitMiddleware = require(script.Parent.Parent.Middleware.RateLimitMiddleware)

local ServerConsole = {}

local function printStats()
    print("[StellarNet] Metrics Snapshot")
    for name, stats in pairs(MetricsService.GetSnapshot()) do
        local lastCall = stats.lastCallAt and os.date("%X", stats.lastCallAt) or "n/a"
        print(string.format(
            "[%s] calls=%d avgSize=%.1fB peakSize=%.1fB rejects=%d errors=%d lastCaller=%s lastCall=%s",
            name,
            stats.eventCount,
            stats.avgPayloadSize,
            stats.peakPayloadSize,
            stats.rejects,
            stats.errors,
            stats.lastCaller or "n/a",
            lastCall
        ))
        if stats.lastRejectReason then
            print(string.format("    lastReject=%s", stats.lastRejectReason))
        end
        if stats.lastErrorReason then
            print(string.format("    lastError=%s", stats.lastErrorReason))
        end
    end
end

local function printRemotes()
    for name in pairs(require(script.Parent.Parent.Remotes.EventDefinitions)) do
        print("[StellarNet] Remote:", name)
    end
end

local function printLimits()
    local limits = RateLimitMiddleware.GetLimits()
    print(string.format("[StellarNet] Default rate limit: %d calls / %ds", limits.Default.Limit, limits.Default.Window))
    for remoteName, data in pairs(limits.Overrides) do
        print(string.format("[StellarNet] %s override: %d calls / %ds", remoteName, data.Limit, data.Window))
    end
end

local function printViolations()
    for _, log in ipairs(ExploitLogger.Logs) do
        print("[StellarNet][Violation]", log.Player, log.RemoteName, log.Reason)
    end
end

function ServerConsole.Register()
    Players.PlayerChatted:Connect(function(player, message)
        if not PermissionService.HasPermission(player, PermissionLevels.MOD) then
            return
        end
        if message == "/stellarnet stats" then
            printStats()
        elseif message == "/stellarnet remotes" then
            printRemotes()
        elseif message == "/stellarnet limits" then
            printLimits()
        elseif message == "/stellarnet violations" then
            printViolations()
        end
    end)
end

return ServerConsole
