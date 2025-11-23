-- Chains middleware functions for remote invocation
local MiddlewarePipeline = {}
MiddlewarePipeline.__index = MiddlewarePipeline

function MiddlewarePipeline.new()
    local self = setmetatable({}, MiddlewarePipeline)
    self.middlewares = {}
    return self
end

function MiddlewarePipeline:Register(middleware)
    table.insert(self.middlewares, middleware)
end

function MiddlewarePipeline:Execute(context)
    local index = 0
    local function nextFn()
        index += 1
        local middleware = self.middlewares[index]
        if middleware then
            return middleware(context, nextFn)
        end
        return true
    end
    return nextFn()
end

return MiddlewarePipeline
