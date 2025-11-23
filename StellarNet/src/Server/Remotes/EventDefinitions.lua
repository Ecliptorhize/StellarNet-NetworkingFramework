-- Central remote definitions with type-safe schemas and handlers
local PermissionLevels = require(script.Parent.Parent.Permissions.PermissionLevels)
local TableUtils = require(script.Parent.Parent.Shared.TableUtils)

local EventDefinitions = {
    PlayerMove = {
        Name = "PlayerMove",
        Description = "Broadcasts player movement direction and speed",
        Permission = PermissionLevels.USER,
        Params = {
            {Name = "Direction", Type = "Vector3"},
            {Name = "Speed", Type = "number"},
        },
        Handler = function(player, direction, speed)
            -- Example handler: would route to movement system
        end,
    },
    ChatMessage = {
        Name = "ChatMessage",
        Description = "Sends a chat message through middleware stack",
        Permission = PermissionLevels.USER,
        Params = {
            {Name = "Message", Type = "string"},
        },
        Handler = function(player, message)
            -- Example sanitized chat relay
            print(string.format("[StellarNet] %s says: %s", player.Name, message))
        end,
    },
    SystemBroadcast = {
        Name = "SystemBroadcast",
        Description = "High-privilege system wide broadcast",
        Permission = PermissionLevels.ADMIN,
        Params = {
            {Name = "Content", Type = "string"},
        },
        Handler = function(player, content)
            -- Admin broadcast placeholder
            print("[StellarNet:SystemBroadcast]", content)
        end,
    },
}

return EventDefinitions
