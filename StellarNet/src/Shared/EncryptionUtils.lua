-- Encryption utilities for payload protection
-- Uses simple XOR stream cipher fallback; AES placeholder for Roblox compatibility.
local HttpService = game:GetService("HttpService")

local EncryptionUtils = {}

-- Server-only secret key; should be set on the server and replicated to client via secure channel
local secretKey = nil

local function xor(str, key)
    local res = {}
    for i = 1, #str do
        local keyByte = string.byte(key, ((i - 1) % #key) + 1)
        res[i] = string.char(bit32.bxor(string.byte(str, i), keyByte))
    end
    return table.concat(res)
end

-- Public API to set the secret key (should only be called on server during setup)
function EncryptionUtils.SetKey(key)
    secretKey = key
end

function EncryptionUtils.GetKey()
    return secretKey
end

-- Serializes payload with timestamp to prevent replay
function EncryptionUtils.Serialize(payload)
    return HttpService:JSONEncode({
        t = os.time(),
        p = payload,
    })
end

function EncryptionUtils.Deserialize(data)
    local decoded = HttpService:JSONDecode(data)
    return decoded.t, decoded.p
end

function EncryptionUtils.Encrypt(payload)
    assert(secretKey, "Encryption key not set")
    local serialized = EncryptionUtils.Serialize(payload)
    return xor(serialized, secretKey)
end

function EncryptionUtils.Decrypt(data)
    assert(secretKey, "Encryption key not set")
    local decrypted = xor(data, secretKey)
    local timestamp, payload = EncryptionUtils.Deserialize(decrypted)
    local now = os.time()
    if math.abs(now - timestamp) > 10 then
        return nil, "Replay or delayed payload"
    end
    return payload, nil
end

return EncryptionUtils
