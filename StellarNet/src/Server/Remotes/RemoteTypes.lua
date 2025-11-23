-- Type mapping utilities for schema validation
local RemoteTypes = {}

RemoteTypes.Allowed = {
    string = function(v) return type(v) == "string" end,
    number = function(v) return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge end,
    boolean = function(v) return type(v) == "boolean" end,
    table = function(v) return type(v) == "table" end,
    Vector3 = function(v) return typeof(v) == "Vector3" end,
    CFrame = function(v) return typeof(v) == "CFrame" end,
    Instance = function(v) return typeof(v) == "Instance" end,
}

function RemoteTypes.Validate(paramType, value)
    local validator = RemoteTypes.Allowed[paramType]
    if not validator then
        return false, "Unknown type " .. tostring(paramType)
    end
    return validator(value)
end

return RemoteTypes
