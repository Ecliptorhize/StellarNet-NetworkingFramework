-- Sanitizes string payloads to mitigate exploits or injection
local function sanitize(value)
    if type(value) == "string" then
        value = value:gsub("%c", "")
        value = value:sub(1, 200)
    end
    return value
end

local function SanitizationMiddleware(context, nextFn)
    if type(context.Payload) == "table" then
        for i, v in ipairs(context.Payload) do
            context.Payload[i] = sanitize(v)
        end
    end
    return nextFn()
end

return SanitizationMiddleware
