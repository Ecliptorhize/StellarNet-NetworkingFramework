-- ClientRemote wraps RemoteEvent with encryption and promise-like yield
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local EncryptionUtils = require(script.Parent.Parent.Shared.EncryptionUtils)

local ClientRemote = {}
ClientRemote.__index = ClientRemote

function ClientRemote.new(remote, definition)
    local self = setmetatable({}, ClientRemote)
    self.Remote = remote
    self.Definition = definition
    return self
end

function ClientRemote:FireServer(...)
    local args = {...}
    local encrypted = EncryptionUtils.Encrypt(args)
    self.Remote:FireServer(encrypted)
end

function ClientRemote:InvokeServer(...)
    local args = {...}
    local encrypted = EncryptionUtils.Encrypt(args)
    return self.Remote:InvokeServer(encrypted)
end

function ClientRemote:OnClientEvent(callback)
    return self.Remote.OnClientEvent:Connect(function(payload)
        local decrypted, err = EncryptionUtils.Decrypt(payload)
        if not decrypted then
            warn("[StellarNet] Failed to decrypt payload:", err)
            return
        end
        callback(unpack(decrypted))
    end)
end

return ClientRemote
