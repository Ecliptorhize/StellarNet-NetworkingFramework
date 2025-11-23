--[=[
    StellarNet Shared Types
    Provides shared type definitions for consistent annotations across server and client.
]=]

export type SchemaParam = {
    Name: string,
    Type: string,
    Optional: boolean?,
}

export type RemoteDefinition = {
    Name: string,
    Params: {SchemaParam},
    Description: string?,
    Permission: number?,
}

export type Context = {
    Player: Player?,
    RemoteName: string,
    Payload: any,
    Time: number,
    Permission: number?,
}

export type Middleware = (Context, (() -> (boolean, string?))) -> (boolean, string?)

export type MetricsRecord = {
    eventCount: number,
    avgPayloadSize: number,
    avgRTT: number,
    errors: number,
    rejects: number,
}

return {}
