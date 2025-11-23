-- Handles server side key distribution and encryption helpers
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EncryptionUtils = require(script.Parent.Parent.Shared.EncryptionUtils)

local RemoteEncryption = {}

function RemoteEncryption.PublishKey()
    local keyValue = ReplicatedStorage:FindFirstChild("StellarNet_Key") or Instance.new("StringValue")
    keyValue.Name = "StellarNet_Key"
    keyValue.Value = EncryptionUtils.GetKey()
    keyValue.Parent = ReplicatedStorage
end

return RemoteEncryption
