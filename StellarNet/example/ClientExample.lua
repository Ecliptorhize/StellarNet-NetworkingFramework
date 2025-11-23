-- Example client usage of StellarNet
local StellarNet = require(script.Parent.Parent.src)
local interface = require(StellarNet.Client)

-- Fire PlayerMove event
interface:Fire("PlayerMove", Vector3.new(0, 0, 1), 12)

-- Listen for broadcasts
local remote = interface:GetRemote("SystemBroadcast")
if remote then
    remote:OnClientEvent(function(content)
        print("Broadcast:", content)
    end)
end
