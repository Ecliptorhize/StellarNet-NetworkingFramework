-- Binds event definitions to RemoteEvents and exposes them to ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RemoteEncryption = require(script.RemoteEncryption)

local RemoteBinder = {}

local function buildPublicDefinitions(definitions)
    local public = {__Shared = {}}
    for name, def in pairs(definitions) do
        public[name] = {
            Name = def.Name,
            Params = def.Params,
            Description = def.Description,
            Permission = def.Permission,
        }
    end
    return public
end

function RemoteBinder.Bind(folder, definitions)
    local remotes = {}

    local publicDefs = buildPublicDefinitions(definitions)
    local defModule = Instance.new("ModuleScript")
    defModule.Name = "StellarNet_EventDefinitions"
    defModule.Source = "return " .. HttpService:JSONEncode(publicDefs)
    defModule.Parent = ReplicatedStorage

    RemoteEncryption.PublishKey()

    for name, def in pairs(definitions) do
        local remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = folder
        remotes[name] = remote
    end

    return remotes
end

return RemoteBinder
