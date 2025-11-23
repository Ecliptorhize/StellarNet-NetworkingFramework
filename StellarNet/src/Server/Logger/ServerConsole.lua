-- Simple command interface for diagnostics
local Players = game:GetService("Players")
local MetricsService = require(script.Parent.Parent.Metrics.MetricsService)
local ExploitLogger = require(script.ExploitLogger)
local PermissionService = require(script.Parent.Parent.Permissions.PermissionService)
local PermissionLevels = require(script.Parent.Parent.Permissions.PermissionLevels)

local ServerConsole = {}

local function printStats()
    print("[StellarNet] Metrics Snapshot")
    for name, stats in pairs(MetricsService.GetAll()) do
        print(name, stats)
    end
end

local function printRemotes()
    for name in pairs(require(script.Parent.Parent.Remotes.EventDefinitions)) do
        print("[StellarNet] Remote:", name)
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
        elseif message == "/stellarnet violations" then
            printViolations()
        end
    end)
end

return ServerConsole
