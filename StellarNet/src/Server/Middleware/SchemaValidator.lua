-- Validates payloads against remote schemas
local ExploitLogger = require(script.Parent.Parent.Logger.ExploitLogger)
local RemoteTypes = require(script.Parent.Parent.Remotes.RemoteTypes)

local function validateParams(definition, payload)
    if type(payload) ~= "table" then
        return false, "Payload not table"
    end
    for idx, param in ipairs(definition.Params) do
        local value = payload[idx]
        if value == nil and not param.Optional then
            return false, "Missing param: " .. param.Name
        end
        if value ~= nil then
            local ok, reason = RemoteTypes.Validate(param.Type, value)
            if not ok then
                return false, string.format("Param %s failed type %s: %s", param.Name, param.Type, tostring(reason))
            end
        end
    end
    return true
end

local function SchemaValidator(context, nextFn)
    local def = require(script.Parent.Parent.Remotes.EventDefinitions)[context.RemoteName]
    if not def then
        ExploitLogger.Log(context.Player, context.RemoteName, context.Payload, "Unknown remote")
        return false, "Unknown remote"
    end
    local ok, reason = validateParams(def, context.Payload)
    if not ok then
        ExploitLogger.Log(context.Player, context.RemoteName, context.Payload, "Schema violation: " .. tostring(reason))
        return false, reason
    end
    return nextFn()
end

return SchemaValidator
