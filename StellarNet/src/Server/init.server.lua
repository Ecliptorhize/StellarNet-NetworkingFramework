-- Server bootstrap for StellarNet
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local RemotesFolder = Instance.new("Folder")
RemotesFolder.Name = "StellarNetRemotes"
RemotesFolder.Parent = ReplicatedStorage

local TableUtils = require(script.Parent.Shared.TableUtils)
local EncryptionUtils = require(script.Parent.Shared.EncryptionUtils)
local PermissionService = require(script.Permissions.PermissionService)
local MiddlewarePipeline = require(script.Middleware.MiddlewarePipeline)
local AuthMiddleware = require(script.Middleware.AuthMiddleware)
local RateLimitMiddleware = require(script.Middleware.RateLimitMiddleware)
local AIMiddleware = require(script.Middleware.AIMiddleware)
local SchemaValidator = require(script.Middleware.SchemaValidator)
local SanitizationMiddleware = require(script.Middleware.SanitizationMiddleware)
local RemoteBinder = require(script.Remotes.RemoteBinder)
local EventDefinitions = require(script.Remotes.EventDefinitions)
local MetricsService = require(script.Metrics.MetricsService)
local ServerConsole = require(script.Logger.ServerConsole)
local ExploitLogger = require(script.Logger.ExploitLogger)

-- Initialize encryption key (server-only)
local key = HttpService:GenerateGUID(false)
EncryptionUtils.SetKey(key)

-- Setup remotes
local remotes = RemoteBinder.Bind(RemotesFolder, EventDefinitions)

-- Middleware pipeline configuration
local pipeline = MiddlewarePipeline.new()
pipeline:Register(AuthMiddleware)
pipeline:Register(PermissionService.Middleware)
pipeline:Register(RateLimitMiddleware)
pipeline:Register(AIMiddleware)
pipeline:Register(SchemaValidator)
pipeline:Register(SanitizationMiddleware)

-- Attach handlers to remotes
for name, remote in pairs(remotes) do
    remote.OnServerEvent:Connect(function(player, payload)
        local decrypted, err = EncryptionUtils.Decrypt(payload)
        if not decrypted then
            ExploitLogger.Log(player, name, payload, "Decryption failed: " .. tostring(err))
            MetricsService.LogReject(name, "Decryption failed")
            return
        end

        local context = {
            Player = player,
            RemoteName = name,
            Payload = decrypted,
            Time = tick(),
            Permission = PermissionService.GetPermissionLevel(player),
        }

        local ok, reason = pipeline:Execute(context)
        if ok then
            MetricsService.IncrementEvent(name, decrypted, player)
            local handler = EventDefinitions[name].Handler
            local start = tick()
            local success, handlerErr = xpcall(handler, debug.traceback, player, unpack(decrypted))
            local duration = tick() - start
            MetricsService.TrackRTT(name, duration)

            if not success then
                MetricsService.LogError(name, handlerErr)
                ExploitLogger.Log(player, name, decrypted, "Handler error: " .. tostring(handlerErr))
            end
        else
            MetricsService.LogReject(name, reason)
            ExploitLogger.Log(player, name, decrypted, reason or "Rejected")
        end
    end)
end

-- Register console commands
ServerConsole.Register()

-- Revoke key when player leaves (cleanup example)
Players.PlayerRemoving:Connect(function(player)
    RateLimitMiddleware.Clear(player)
    AIMiddleware.Clear(player)
end)

return {
    Remotes = remotes,
    Pipeline = pipeline,
}
