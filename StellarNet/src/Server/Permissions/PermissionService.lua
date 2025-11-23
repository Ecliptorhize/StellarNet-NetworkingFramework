-- Determines player permission levels and middleware enforcement
local PermissionLevels = require(script.PermissionLevels)
local ExploitLogger = require(script.Parent.Parent.Logger.ExploitLogger)

local PermissionService = {}
PermissionService.UserPermissions = {}

function PermissionService.SetPermission(player, level)
    PermissionService.UserPermissions[player.UserId] = level
end

function PermissionService.GetPermissionLevel(player)
    return PermissionService.UserPermissions[player.UserId] or PermissionLevels.USER
end

function PermissionService.HasPermission(player, requiredLevel)
    return PermissionService.GetPermissionLevel(player) >= requiredLevel
end

function PermissionService.Middleware(context, nextFn)
    local required = require(script.Parent.Parent.Remotes.EventDefinitions)[context.RemoteName].Permission or PermissionLevels.USER
    if not PermissionService.HasPermission(context.Player, required) then
        ExploitLogger.Log(context.Player, context.RemoteName, context.Payload, "Permission denied")
        return false, "Insufficient permission"
    end
    return nextFn()
end

return PermissionService
