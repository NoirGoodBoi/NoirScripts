local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Noir Hub",
    LoadingTitle = "Loading NoirHub...",
    LoadingSubtitle = "Script By Noir",
    ConfigurationSaving = {
        Enabled = false,
    }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)

-- 1. Slider Speed
local walkspeed = 16
PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        walkspeed = v
    end
})

-- 2. Toggle Tăng tốc độ (✅ FIXED)
local speedLoop = nil
PlayerTab:CreateToggle({
    Name = "Tăng tốc độ",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer
        if state then
            speedLoop = task.spawn(function()
                while task.wait() do
                    if not state then break end
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        plr.Character.Humanoid.WalkSpeed = walkspeed
                    end
                end
            end)
        else
            if speedLoop then
                task.cancel(speedLoop)
                speedLoop = nil
            end
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

-- 3. Slider Power Jump
local jumppower = 50
PlayerTab:CreateSlider({
    Name = "Power Jump",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        jumppower = v
    end
})

-- 4. Toggle Tăng power jump (✅ FIXED)
local jumpLoop = nil
PlayerTab:CreateToggle({
    Name = "Tăng power jump",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer
        if state then
            jumpLoop = task.spawn(function()
                while task.wait() do
                    if not state then break end
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        plr.Character.Humanoid.JumpPower = jumppower
                    end
                end
            end)
        else
            if jumpLoop then
                task.cancel(jumpLoop)
                jumpLoop = nil
            end
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.JumpPower = 50
            end
        end
    end
})

-- 5. Infinity Jump
local infJumpConnection
PlayerTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Callback = function(state)
        if state then
            infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConnection then
                infJumpConnection:Disconnect()
                infJumpConnection = nil
            end
        end
    end
})

-- 6. NoClip + Bypass void
local noclip = false
local lastPosition = nil

PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(state)
        noclip = state
        local plr = game.Players.LocalPlayer
        game:GetService("RunService"):UnbindFromRenderStep("NoirNoClip")
        if state then
            game:GetService("RunService"):BindToRenderStep("NoirNoClip", Enum.RenderPriority.Character.Value, function()
                local char = plr.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide == true then
                            v.CanCollide = false
                        end
                    end
                    if char:FindFirstChild("HumanoidRootPart") then
                        local posY = char.HumanoidRootPart.Position.Y
                        if posY < -10 and lastPosition then
                            char.HumanoidRootPart.CFrame = lastPosition
                        else
                            lastPosition = char.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
        end
    end
})

-- 7. ESP (Tên + khoảng cách, không scale)
local espEnabled = false
local espConnections = {}
local espInstances = {}

local function removeAllESP()
    for _, gui in pairs(espInstances) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    espInstances = {}
    espConnections = {}
end

PlayerTab:CreateToggle({
    Name = "ESP (Tên + Khoảng cách)",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        removeAllESP()
        if not state then return end

        local function createESP(plr)
            if plr == game.Players.LocalPlayer then return end
            local billboard = Instance.new("BillboardGui", plr.Character:WaitForChild("Head"))
            billboard.Name = "NoirESP"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.LightInfluence = 0
            billboard.MaxDistance = math.huge

            local txt = Instance.new("TextLabel", billboard)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextScaled = false
            txt.Font = Enum.Font.SourceSansBold
            txt.TextSize = 14
            txt.TextColor3 = Color3.new(1, 1, 1)
            txt.TextStrokeTransparency = 0.5
            txt.Text = plr.Name

            local conn = game:GetService("RunService").RenderStepped:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    txt.Text = plr.Name .. " | " .. math.floor(dist) .. "m"
                end
            end)

            table.insert(espInstances, billboard)
            table.insert(espConnections, conn)
        end

        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character then
                createESP(plr)
            end
        end

        table.insert(espConnections, game.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                wait(1)
                createESP(plr)
            end)
        end))
    end
})

-- 8. Anti-AFK (Button)
PlayerTab:CreateButton({
    Name = "Bật Anti-AFK",
    Callback = function()
        for _, conn in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
            conn:Disable()
        end
    end
})
