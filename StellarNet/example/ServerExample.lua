-- Example server usage of StellarNet
local StellarNet = require(script.Parent.Parent.src)
local PermissionLevels = require(StellarNet.Server.Permissions.PermissionLevels)
local PermissionService = require(StellarNet.Server.Permissions.PermissionService)
local EventDefinitions = require(StellarNet.Server.Remotes.EventDefinitions)

-- Assign admin permission to game creator for demonstration
local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
    if player.UserId == game.CreatorId then
        PermissionService.SetPermission(player, PermissionLevels.ADMIN)
    end
end)

-- Initialize server remotes
local services = require(StellarNet.Server)
print("StellarNet server initialized", services)
