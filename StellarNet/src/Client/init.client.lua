-- Client bootstrap for StellarNet
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Shared = script.Parent.Parent.Shared
local EncryptionUtils = require(Shared.EncryptionUtils)
local ClientRemote = require(script.ClientRemote)
local ClientDebugger = require(script.ClientDebugger)
local EventDefinitions = require(ReplicatedStorage:WaitForChild("StellarNet_EventDefinitions"))

-- In production, the key should be transmitted via secure channel from server
local keyValue = ReplicatedStorage:WaitForChild("StellarNet_Key")
EncryptionUtils.SetKey(keyValue.Value)

local remotesFolder = ReplicatedStorage:WaitForChild("StellarNetRemotes")
local NetworkInterface = require(script.NetworkInterface)

local interface = NetworkInterface.new(remotesFolder, EventDefinitions)

ClientDebugger.Attach(interface)

return interface
