-- Entry point for StellarNet package
local Server = require(script.Server)
local Client = require(script.Client)
local Shared = require(script.Shared)

return {
    Server = Server,
    Client = Client,
    Shared = Shared,
}
