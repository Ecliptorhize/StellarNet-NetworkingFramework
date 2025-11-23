-- Ensures the Player object exists and is authenticated
local ExploitLogger = require(script.Parent.Parent.Logger.ExploitLogger)

local function AuthMiddleware(context, nextFn)
    if not context.Player or not context.Player.Parent then
        ExploitLogger.Log(context.Player, context.RemoteName, context.Payload, "Unauthenticated player")
        return false, "Unauthenticated"
    end
    return nextFn()
end

return AuthMiddleware
