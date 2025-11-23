-- Generates client-side remote interfaces from definitions
local ClientRemote = require(script.Parent.ClientRemote)
local Signal = require(script.Parent.Parent.Shared.Signal)

local NetworkInterface = {}
NetworkInterface.__index = NetworkInterface

function NetworkInterface.new(remotesFolder, definitions)
    local self = setmetatable({}, NetworkInterface)
    self.Remotes = {}
    self.Definitions = definitions
    self.Events = Signal.new()

    for name, def in pairs(definitions) do
        local remote = remotesFolder:WaitForChild(name)
        self.Remotes[name] = ClientRemote.new(remote, def)
    end

    return self
end

function NetworkInterface:GetRemote(name)
    return self.Remotes[name]
end

function NetworkInterface:Fire(remoteName, ...)
    local remote = self.Remotes[remoteName]
    if not remote then
        warn("[StellarNet] Unknown remote:", remoteName)
        return
    end
    remote:FireServer(...)
end

return NetworkInterface
