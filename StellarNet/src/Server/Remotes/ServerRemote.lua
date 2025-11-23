local Players = game:GetService("Players")
local EncryptionUtils = require(script.Parent.Parent.Shared.EncryptionUtils)

local ServerRemote = {}
ServerRemote._index = ServerRemote

function ServerRemote.new(remoteEvent, definition)
    local self = setmetatable({}, ServerRemote)
    self.RemoteEvent = remoteEvent
    self.Definition = definition
    self.OnServerEvent = remoteEvent.OnServerEvent
    return self
end

function ServerRemote:GetInstance()
    return self.RemoteEvent    
end

local function encryptPayload(...)
    return EncryptionUtils.Encrypt({...})
end

function ServerRemote:FireExcept(excludePlayers, ...)
    local blacklist = {}
    for _, player in ipairs(excludePlayers) do
        blacklist
    end