-- In-game debugging dashboard for StellarNet
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local ClientDebugger = {}

local function createScreenGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "StellarNetDebugger"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 220)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 24)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "StellarNet Debugger"
    title.Parent = frame

    local logBox = Instance.new("TextLabel")
    logBox.Size = UDim2.new(1, -20, 1, -40)
    logBox.Position = UDim2.new(0, 10, 0, 32)
    logBox.BackgroundTransparency = 1
    logBox.TextXAlignment = Enum.TextXAlignment.Left
    logBox.TextYAlignment = Enum.TextYAlignment.Top
    logBox.Font = Enum.Font.Code
    logBox.TextWrapped = true
    logBox.TextColor3 = Color3.fromRGB(150, 200, 255)
    logBox.TextSize = 12
    logBox.Text = ""
    logBox.Parent = frame

    return gui, logBox
end

function ClientDebugger.Attach(interface)
    local player = Players.LocalPlayer
    local gui, logBox = createScreenGui()
    gui.Parent = player:WaitForChild("PlayerGui")
    local lines = {}

    local function log(text)
        table.insert(lines, 1, string.format("[%s] %s", os.date("%H:%M:%S"), text))
        if #lines > 15 then
            table.remove(lines)
        end
        logBox.Text = table.concat(lines, "\n")
    end

    for name, remote in pairs(interface.Remotes) do
        remote.Remote.OnClientEvent:Connect(function(payload)
            local start = tick()
            local decrypted, err = require(script.Parent.Parent.Shared.EncryptionUtils).Decrypt(payload)
            if decrypted then
                local rtt = tick() - start
                log(string.format("Event %s received RTT %.2fms", name, rtt * 1000))
            else
                log(string.format("Event %s failed decrypt: %s", name, tostring(err)))
            end
        end)
    end

    interface.Events:Connect(function(msg)
        log(msg)
    end)
end

return ClientDebugger
