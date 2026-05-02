--[[
    ⚔️ ZO SAMURAI: INTERNAL VERSION 1.0
    ==========================================
    FEATURES: Jitter Orbit, Auto-Parry, Kill Aura
    STATUS: UNDETECTED (2026 Bypass)
    ==========================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Range = 16,
    SpinSpeed = 25,
    JitterAmount = 2, 
    AutoBlock = true,
    Enabled = true
}

local function AutoParry()
    for _, enemy in pairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Character then
            local tool = enemy.Character:FindFirstChildOfClass("Tool")
            if tool and (enemy.Character:FindFirstChild("Attacking") or tool:FindFirstChild("Active")) then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - enemy.Character.HumanoidRootPart.Position).Magnitude
                if dist < 12 then
                    local myTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if myTool and myTool:FindFirstChild("BlockRemote") then
                        myTool.BlockRemote:FireServer(true)
                        task.wait(0.1)
                        myTool.BlockRemote:FireServer(false)
                    end
                end
            end
        end
    end
end

local function GetTarget()
    local target, dist = nil, Config.Range
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") then
                local mag = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then
                    dist = mag
                    target = v
                end
            end
        end
    end
    return target
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not Config.Enabled then return end

    if Config.AutoBlock then AutoParry() end

    local target = GetTarget()
    local tool = char:FindFirstChildOfClass("Tool")

    if target and target.Character then
        local tHrp = target.Character.HumanoidRootPart
        local timer = tick() * Config.SpinSpeed
        local jitter = (math.random(-Config.JitterAmount, Config.JitterAmount) / 10)
        
        local goalPos = tHrp.Position + Vector3.new(
            math.cos(timer) * (5 + jitter), 
            math.sin(timer * 0.5) * 2, 
            math.sin(timer) * (5 + jitter)
        )
        
        hrp.CFrame = CFrame.new(goalPos, tHrp.Position)

        if tool then
            local remote = tool:FindFirstChild("RemoteClick") or tool:FindFirstChild("Attack")
            if remote then
                remote:FireServer()
            else
                tool:Activate()
            end
        end
    end
end)

print("⚔️ ZO INTERNAL V1 LOADED")

