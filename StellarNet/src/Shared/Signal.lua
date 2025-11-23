-- Simple Signal implementation for events
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    self._listening = true
    return self
end

function Signal:Connect(callback)
    local connection = {Callback = callback, Connected = true}
    function connection:Disconnect()
        self.Connected = false
    end
    table.insert(self._connections, connection)
    return connection
end

function Signal:Once(callback)
    local connection
    connection = self:Connect(function(...)
        callback(...)
        if connection then
            connection:Disconnect()
        end
    end)
    return connection
end

function Signal:Fire(...)
    if not self._listening then
        return
    end
    for _, connection in ipairs(self._connections) do
        if connection.Connected then
            task.spawn(connection.Callback, ...)
        end
    end
end

function Signal:Destroy()
    self._listening = false
    for _, connection in ipairs(self._connections) do
        connection.Connected = false
    end
    table.clear(self._connections)
end

return Signal
