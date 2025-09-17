local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Noir Hub",
    LoadingTitle = "Loading NoirHub...",
    LoadingSubtitle = "Script By Noir",
    ConfigurationSaving = {
        Enabled = false,
    }
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")

local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateSection("Thông Tin Bản Thân")
MainTab:CreateLabel("Username: " .. LocalPlayer.Name)
MainTab:CreateLabel("DisplayName: " .. LocalPlayer.DisplayName)
MainTab:CreateLabel("UserId: " .. LocalPlayer.UserId)
MainTab:CreateLabel("Account Age: " .. LocalPlayer.AccountAge .. " days")

-- Ping
local PingLabel = MainTab:CreateLabel("Ping: ...")
RunService.Heartbeat:Connect(function()
    PingLabel:Set("Ping: " .. tostring(math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms")
end)

-- Thời gian chơi (tính từ lúc join)
local joinTime = tick()
local TimePlayedLabel = MainTab:CreateLabel("Time Played: 0s")
RunService.RenderStepped:Connect(function()
    local elapsed = math.floor(tick() - joinTime)
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    TimePlayedLabel:Set(string.format("Time Played: %d min %02d s", mins, secs))
end)

-- Toạ độ
local PosLabel = MainTab:CreateLabel("Position: ...")
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        PosLabel:Set(string.format("Position: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
    else
        PosLabel:Set("Position: -")
    end
end)

-- Tên game
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    MainTab:CreateLabel("Game Name: " .. info.Name)
end)

-- PlaceId, GameId, JobId, Version
MainTab:CreateLabel("PlaceId: " .. game.PlaceId)
MainTab:CreateLabel("GameId: " .. game.GameId)
MainTab:CreateLabel("JobId: " .. game.JobId)
MainTab:CreateLabel("Game Version: " .. game.PlaceVersion)

-- Số người chơi trong server
local PlayerCountLabel = MainTab:CreateLabel("Players: " .. #Players:GetPlayers())

Players.PlayerAdded:Connect(function()
    PlayerCountLabel:Set("Players: " .. #Players:GetPlayers())
end)

Players.PlayerRemoving:Connect(function()
    PlayerCountLabel:Set("Players: " .. #Players:GetPlayers())
end)

-- Dropdown danh sách người chơi
local function GetPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    return names
end

local PlayerDropdown = MainTab:CreateDropdown({
    Name = "Danh Sách Người Chơi",
    Options = GetPlayerNames(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "PlayerDropdown",
    Callback = function(Option)
        print("Chọn: " .. Option)
    end,
})

-- Tự động refresh danh sách khi có thay đổi
local function RefreshDropdown()
    PlayerDropdown:Refresh(GetPlayerNames())
end

Players.PlayerAdded:Connect(RefreshDropdown)
Players.PlayerRemoving:Connect(RefreshDropdown)

MainTab:CreateButton({
   Name = "Reset GUI Rayfield",
   Callback = function() Rayfield:Destroy() end,
})

local PlayerTab = Window:CreateTab("Player", "user")

PlayerTab:CreateSection("Tools")

--Speed
local walkspeed = 16
PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {16, 1000},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        walkspeed = v
    end
})

--InSpeed
local speedLoop = nil
PlayerTab:CreateToggle({
    Name = "Increase Speed",
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

--Jumpslider
local jumppower = 50
PlayerTab:CreateSlider({
    Name = "Power Jump",
    Range = {50, 1000},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        jumppower = v
    end
})

--InJump
local jumpLoop = nil
PlayerTab:CreateToggle({
    Name = "Increase Power Jump",
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


--infJump
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

--noclip
PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(state)
        local RunService = game:GetService("RunService")
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()

        RunService:UnbindFromRenderStep("NoirNoClip")

        if state then
            RunService:BindToRenderStep("NoirNoClip", Enum.RenderPriority.Character.Value, function()
                local char = plr.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(11)
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
})

--esp1
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

local function createESP(plr)
    if plr == game.Players.LocalPlayer then return end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NoirESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.LightInfluence = 0
    billboard.MaxDistance = math.huge
    billboard.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = false
    txt.Font = Enum.Font.SourceSansBold
    txt.TextSize = 14
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextStrokeTransparency = 0.5
    txt.Text = plr.Name
    txt.Parent = billboard

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            txt.Text = plr.Name .. " | " .. math.floor(dist) .. "m"
        end
    end)

    table.insert(espInstances, billboard)
    table.insert(espConnections, conn)
end

PlayerTab:CreateToggle({
    Name = "ESP (@name)",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        removeAllESP()
        if not state then return end

        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                if plr.Character then
                    createESP(plr)
                end
                
                table.insert(espConnections, plr.CharacterAdded:Connect(function()
                    if espEnabled then
                        task.wait(0.5)
                        createESP(plr)
                    end
                end))
            end
        end

        table.insert(espConnections, game.Players.PlayerAdded:Connect(function(plr)
            if espEnabled then
                plr.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    createESP(plr)
                end)
            end
        end))
    end
})

--esp2
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

local function createESP(plr)
    if plr == game.Players.LocalPlayer then return end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NoirESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.LightInfluence = 0
    billboard.MaxDistance = math.huge
    billboard.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = false
    txt.Font = Enum.Font.SourceSansBold
    txt.TextSize = 14
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextStrokeTransparency = 0.5
    txt.Text = plr.Name
    txt.Parent = billboard

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            txt.Text = plr.DisplayName .. " | " .. math.floor(dist) .. "m"
        end
    end)

    table.insert(espInstances, billboard)
    table.insert(espConnections, conn)
end

PlayerTab:CreateToggle({
    Name = "ESP (display name)",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        removeAllESP()
        if not state then return end

        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                if plr.Character then
                    createESP(plr)
                end
                
                table.insert(espConnections, plr.CharacterAdded:Connect(function()
                    if espEnabled then
                        task.wait(0.5)
                        createESP(plr)
                    end
                end))
            end
        end

        table.insert(espConnections, game.Players.PlayerAdded:Connect(function(plr)
            if espEnabled then
                plr.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    createESP(plr)
                end)
            end
        end))
    end
})

--esp3
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

local function createESP(plr)
    if plr == game.Players.LocalPlayer then return end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NoirESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.LightInfluence = 0
    billboard.MaxDistance = math.huge
    billboard.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = false
    txt.Font = Enum.Font.SourceSansBold
    txt.TextSize = 14
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextStrokeTransparency = 0.5
    txt.Text = plr.Name
    txt.Parent = billboard

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            txt.Text = plr.DisplayName .. " (@" .. plr.Name .. ") | " .. math.floor(dist) .. "m"
        end
    end)

    table.insert(espInstances, billboard)
    table.insert(espConnections, conn)
end

PlayerTab:CreateToggle({
    Name = "ESP (@name+display name)",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        removeAllESP()
        if not state then return end

        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                if plr.Character then
                    createESP(plr)
                end
                
                table.insert(espConnections, plr.CharacterAdded:Connect(function()
                    if espEnabled then
                        task.wait(0.5)
                        createESP(plr)
                    end
                end))
            end
        end

        table.insert(espConnections, game.Players.PlayerAdded:Connect(function(plr)
            if espEnabled then
                plr.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    createESP(plr)
                end)
            end
        end))
    end
})

--anti afk
PlayerTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        for _, conn in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
            conn:Disable()
        end
    end
})

PlayerTab:CreateSection("Funny Tools")

--spin
PlayerTab:CreateSlider({
    Name = "Spin Speed",
    Range = {1,50},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v)
        spinSpeed = v
    end
})
RunService.RenderStepped:Connect(function()
    if spinning and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(spinSpeed), 0)
    end
end)

--active spin
local spinning = false
local spinSpeed = 5
PlayerTab:CreateToggle({
    Name = "Spin",
    CurrentValue = false,
    Callback = function(v)
        spinning = v
    end
})

PlayerTab:CreateToggle({
    Name = "Sit",
    CurrentValue = false,
    Callback = function(state)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if state then
                LocalPlayer.Character.Humanoid.Sit = true
            else
                LocalPlayer.Character.Humanoid.Sit = false
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
})

--gravity
PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 500},
    Increment = 1,
    CurrentValue = math.floor(workspace.Gravity),
    Callback = function(v)
        customGravity = v
        if gravityToggle then
            workspace.Gravity = v
        end
    end
})

--toggle gravity
local gravityToggle = false
local customGravity = workspace.Gravity
PlayerTab:CreateToggle({
    Name = "Gravity Toggle",
    CurrentValue = false,
    Callback = function(v)
        gravityToggle = v
        if v then
            workspace.Gravity = customGravity
        else
            workspace.Gravity = 196.2
        end
    end
})

--ping&fps
local statsGui
local showStats = false

local function createStatsGui()
    if statsGui then statsGui:Destroy() end

    statsGui = Instance.new("ScreenGui")
    statsGui.Name = "NoirStatsGui"
    statsGui.IgnoreGuiInset = true
    statsGui.ResetOnSpawn = false
    statsGui.Parent = game:GetService("CoreGui")

    local label = Instance.new("TextLabel")
    label.Name = "StatsLabel"
    label.Size = UDim2.new(0, 200, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 55)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = statsGui

    game:GetService("RunService").RenderStepped:Connect(function()
        if not showStats then return end
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait()) .. " FPS"
        label.Text = "Ping: " .. ping .. "   FPS: " .. fps
    end)
end

PlayerTab:CreateToggle({
    Name = "Show Ping & FPS",
    CurrentValue = false,
    Callback = function(state)
        showStats = state
        if state then
            createStatsGui()
        else
            if statsGui then
                statsGui:Destroy()
                statsGui = nil
            end
        end
    end
})

--minimap
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MapGui, MapFrame, MapObjects = nil, nil, {}
local MapEnabled = false

local function createMap()
MapGui = Instance.new("ScreenGui")
MapGui.IgnoreGuiInset = true
MapGui.ResetOnSpawn = false
MapGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MapGui.Parent = game.CoreGui

MapFrame = Instance.new("Frame")  
MapFrame.Size = UDim2.new(0,150,0,150)  
MapFrame.Position = UDim2.new(1,-160,0,10)   
MapFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)  
MapFrame.BackgroundTransparency = 0.4  
MapFrame.BorderSizePixel = 0  
MapFrame.Parent = MapGui  
MapFrame.ClipsDescendants = true

end

local function getDotColor(player)
if player == LocalPlayer then
return Color3.fromRGB(0,255,0), Color3.fromRGB(0,150,0), 3
elseif LocalPlayer:IsFriendsWith(player.UserId) then
return Color3.fromRGB(0,170,255), Color3.fromRGB(0,100,200), 2
else
return Color3.fromRGB(255,255,255), Color3.fromRGB(80,80,80), 1
end
end

local function createDot(player)
if MapObjects[player] then return end

local dot = Instance.new("Frame")  
dot.Size = UDim2.new(0,8,0,8)  
dot.AnchorPoint = Vector2.new(0.5,0.5)  

local color, border, zindex = getDotColor(player)  
dot.BackgroundColor3 = color  
dot.ZIndex = zindex  
dot.Parent = MapFrame  

local UICorner = Instance.new("UICorner")  
UICorner.CornerRadius = UDim.new(1,0) 
UICorner.Parent = dot  

local UIStroke = Instance.new("UIStroke")  
UIStroke.Thickness = 2  
UIStroke.Color = border  
UIStroke.Parent = dot  

MapObjects[player] = dot

end

local function updateDots()
    if not MapEnabled then return end
    local center = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not center then return end

    local camYaw = math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + math.rad(45)

    for player, dot in pairs(MapObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local offset = (hrp.Position - center.Position) / 4

            local rx = offset.X*math.cos(camYaw) + offset.Z*math.sin(camYaw)
            local rz = -offset.X*math.sin(camYaw) + offset.Z*math.cos(camYaw)

            if math.abs(rx) <= 70 and math.abs(rz) <= 70 then
                dot.Visible = true
                dot.Position = UDim2.new(0.5,rx,0.5,rz)
            else
            dot.Visible = false
            end
        else
            dot.Visible = false
        end
    end
end

local function initMap()
createMap()
for _,p in pairs(Players:GetPlayers()) do
createDot(p)
end
Players.PlayerAdded:Connect(createDot)
Players.PlayerRemoving:Connect(function(p)
if MapObjects[p] then MapObjects[p]:Destroy() MapObjects[p]=nil end
end)
RunService.RenderStepped:Connect(updateDots)
end

PlayerTab:CreateToggle({
Name = "MiniMap",
CurrentValue = false,
Flag = "MiniMapToggle",
Callback = function(state)
MapEnabled = state
if state then
if not MapGui then initMap() end
MapGui.Enabled = true
else
if MapGui then MapGui.Enabled = false end
end
end
})

-- Vẽ tâm ảo 
local crosshair = Drawing.new("Circle")
crosshair.Visible = false
crosshair.Color = Color3.fromRGB(255, 255, 255) 
crosshair.Thickness = 1
crosshair.Radius = 2
crosshair.Filled = true
crosshair.Position = workspace.CurrentCamera.ViewportSize / 2

-- Cập nhật vị trí khi đổi độ phân giải
game:GetService("RunService").RenderStepped:Connect(function()
    crosshair.Position = workspace.CurrentCamera.ViewportSize / 2
end)

-- Toggle Rayfield
PlayerTab:CreateToggle({
    Name = "Crosshair",
    CurrentValue = false,
    Flag = "CrosshairToggle",
    Callback = function(Value)
        crosshair.Visible = Value
    end,
})

--FOV
PlayerTab:CreateSlider({
    Name = "Field Of View",
    Range = {30,120},
    Increment = 1,
    CurrentValue = Camera.FieldOfView,
    Callback = function(v)
        Camera.FieldOfView = v
    end
})

--Lock cam
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local locked = false
local savedCFrame
local conn

PlayerTab:CreateToggle({
    Name = "Lock Camera",
    CurrentValue = false,
    Callback = function(Value)
        locked = Value
        if locked then
            savedCFrame = Camera.CFrame
            conn = RunService.RenderStepped:Connect(function()
                if locked and savedCFrame then
                    Camera.CFrame = savedCFrame
                end
            end)
        else
            if conn then conn:Disconnect() conn = nil end
            savedCFrame = nil
        end
    end,
})

--firstp
PlayerTab:CreateButton({
    Name = "Lock First Person",
    Callback = function()
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMaxZoomDistance = 0
    end
})

--thirdp
PlayerTab:CreateButton({
    Name = "Unlock Third Person",
    Callback = function()
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMaxZoomDistance = 1000
    end
})

--resetchar
PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
        end
    end
})

--respawn
PlayerTab:CreateButton({
    Name = "Respawn",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:Destroy()
        end
    end
})

local PacksTab = Window:CreateTab("Packs", "package")

PacksTab:CreateSection("Not Fe & just use for R15")

PacksTab:CreateButton({
    Name = "Korblox",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Korblox.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Headless",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Headless.lua"))()
    end,
})

PacksTab:CreateSection("FE & just use for R15")

PacksTab:CreateButton({
    Name = "Ninja",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Ninja.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Robot",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Robot.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Levitate",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Levitate.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Mage",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Mage.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Stylish",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Stylish.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Hero",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Hero.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Astronaut",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Astronaut.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Bubbly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Bubbly.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Cartoony",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Cartoony.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Elder",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Elder.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Ghost",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Ghost.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Knight",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Knight.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Vampire",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Vampire.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Werewolf",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Werewolf.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Zombie",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Zombie.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Oldschool",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Oldschool.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Bold",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Bold.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Adidas",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Adidas.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Adidas2",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Adidas2.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Catwalk",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Catwalk.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Walmart",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Walmart.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Wicked",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Wicked.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "NFL",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/NFL.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Pirate",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Pirate.lua"))()
    end,
})

local ScriptsTab = Window:CreateTab("Scripts", "file-text")

ScriptsTab:CreateSection("Funny Scripts")

ScriptsTab:CreateButton({
    Name = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Vehicle%20Fly%20Gui"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Funny by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirFunny.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "PvP by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirPvP.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Wallhop",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ScpGuest666/Random-Roblox-script/refs/heads/main/Roblox%20WallHop%20V4%20script"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Keyboard",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt", true))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Delta Keyboard",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sparezirt/Script/refs/heads/main/.github/workflows/JustABaseplate.txt"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Aim Bot",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-Universal-For-Mobile-and-PC-29153"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Hitbox Extender (aimbot)",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/UI_LimbExtender.lua'))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Aimbot by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/Aimbot"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "SilentAim by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/SilentAim.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "SilentAimNPC by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/SilentAimNPC"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "AimNPC by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/AimNPC"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Reset UI by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/ResetGUI"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "BloxsTrap",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/Initiate.lua'), 'lol')()
    end,
})

ScriptsTab:CreateSection("Animation & Emote Scripts")

ScriptsTab:CreateButton({
    Name = "Animation v2.5",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/ScriptR6/AnimGuiV2.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Emote Tiktok",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Free-emote/refs/heads/main/Delta%20mad%20stuffs"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Emote (emote walk)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FREE UGC EMOTES",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Free-UGC-Emotes-Script-48649"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Animation GUI by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Animation_GUI"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Reanimation by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Reanimation"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Krystal Dance v3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/somethingsimade/KDV3-Fixed/refs/heads/main/KrystalDance3"))()
    end,
})

ScriptsTab:CreateSection("Shaders")

ScriptsTab:CreateButton({
    Name = "Shaders Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua"))()
    end,
})

ScriptsTab:CreateSection("Admin Scripts")

ScriptsTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Infinite Fun (IY)",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Xane123/InfiniteFun_IY/master/source'))()
    end,
})

ScriptsTab:CreateButton({
    Name = "NameLess",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "NameLess version Testing",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "CMD-X",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", true))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Fates Admin",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Reviz Admin",
    Callback = function()
        loadstring(game:HttpGetAsync("https://pastebin.com/raw/gQg0G6iA"))()
    end,
})

ScriptsTab:CreateSection("All in One Scripts")

ScriptsTab:CreateButton({
    Name = "Anon Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sa435125/AnonHub/refs/heads/main/anonhub.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Lua Land Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Angelo-Gitland/LuaLandHubV4Keyless/refs/heads/main/Lua%20Land%20Hub%20%7C%20V4%20Keyless%20Script%20Hub"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Ghost Hub",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/GhostHub'))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Altair Script Hub",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/MxnvA12M/raw"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Solara Hub",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/samuraa1/Solara-Hub/refs/heads/main/SH.lua'))()
    end,
})

ScriptsTab:CreateButton({
    Name = "KRware Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KRWareHub/KRWare/refs/heads/main/KRWare%20Hub%20Loader.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "System Broken",
    Callback = function()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Ragdoll-Engine-BEST-SCRIPT-WORKING-SystemBroken-7544"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Cryton v3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/thesigmacorex/Crypton/main/Free"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "XVC hub",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/Piw5bqGq"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Trolling GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/FE%20Trolling%20GUI.luau"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "IndexZ Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/IndexZHub/Loader/main/Loader"))()
    end,
})

ScriptsTab:CreateSection("Funny FE Scripts :))")

ScriptsTab:CreateButton({
    Name = "Stalkie (key is: pizza)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Stalkie"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Inventory Viewer by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Inventory_Viewer"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Part Controller GUI by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Part_Controller"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Telekinesis V5",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/ FE_Telekinesis"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Sandevistan FE",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Sandevistan"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Emperor Crimson v3.5",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/p4QY0AsL"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Sharingan [for mobile]",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/zSEfVjPE"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Sharingan [only R6]",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/bidQM5Bz"))()
    end,
})

ScriptsTab:CreateLabel("(E)Fireball Jutsu")

ScriptsTab:CreateLabel("(Q)Sharingan (copy movement)")

ScriptsTab:CreateLabel("(R)Kamui")

ScriptsTab:CreateLabel("(F)Amaterasu")

ScriptsTab:CreateLabel("(P)Pose")

ScriptsTab:CreateButton({
    Name = "Tap to TP",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Tap_to_TP"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Invincible Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/FE_invincible_v1"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Wally West [Mobile]",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/zNHefpgc"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Wally West [For R15]",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/XQZ-official/XQZscripts/refs/heads/main/WallyWest.txt'))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Wally West [for mobile v2]",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Wally-West-Roblox-51462"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Silly Car",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-SILLY-CAR-V1-48227"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Car Drift [Recommend for R6]",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AstraOutlight/my-scripts/refs/heads/main/fe%20car%20v3"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Replication UI",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/tMYrf22E"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "F3X Panel (building script)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SkireScripts/F3X-Panel/main/Main.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Server Menu Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lumpiasallad/Roblox_ServerHop/refs/heads/main/ServerHopScript.lua"))()
    end,
})

ScriptsTab:CreateSection("For Some Game")

ScriptsTab:CreateButton({
    Name = "M1 reset",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/M1Reset.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "TSB (by YQANTG v3.3)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yqantg-pixel/Find/refs/heads/main/Protected_3334988263341522.lua.txt"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "tsb by EBHUBR (key is: PLSDONATE!)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/r3k33551-bot/Acortador-de-scripts/refs/heads/main/EBHUBR%20V7.txt"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "AK Gaming Ez Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hehej97/AkGamingEzv2.1/refs/heads/main/AKGaming.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Forsaken",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Snowt69/SNT-HUB/refs/heads/main/Forsaken"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Murder Mystery 2",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/real-bluez/MM2/refs/heads/main/AutoFarm'))()
    end,
})

ScriptsTab:CreateButton({
    Name = "MeMe Sea",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZaqueHub/ShinyHub-MMSea/main/MEME%20SEA%20PROTECT.txt"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "99 Night In The Forest",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/loader.lua", true))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Ink Game",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wefwef127382/inkgames.github.io/refs/heads/main/ringta.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Deadrail",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wefwef127382/DEADRAILS.github.io/refs/heads/main/mainringta.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Farm Bond (Skull Hub)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/SkullHub/main/loader.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Blade Ball",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AgentX771/ArgonHubX/main/Loader.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Break In 1",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Iptxt/AXHub-Loader/refs/heads/main/Loader"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Break In 2",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EnesXVC/Breakin2/main/script"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Doors",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/NewBestDoorsScriptIliankytb"))()
    end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Tab4 = Window:CreateTab("People", "users")

local currentTarget = nil
local loopTeleport = false
local watching = false

local playerDropdown = Tab4:CreateDropdown({
    Name = "Player List",
    Options = {},
    CurrentOption = {},
    Multi = false,
    Flag = "obj_playerlist",
    Callback = function(option)
        if type(option) == "table" and #option > 0 then
            currentTarget = option[1]
        else
            currentTarget = nil
        end
    end
})

local function refreshPlayers()
    local opts = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(opts, p.Name)
        end
    end
    playerDropdown:Refresh(opts, true)
    if not table.find(opts, currentTarget) then
        currentTarget = nil
    end
end

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
refreshPlayers()

local function getTarget()
    if not currentTarget then return nil end
    return Players:FindFirstChild(currentTarget)
end

local function getChar(p)
    if not p then return nil end
    return p.Character
end

Tab4:CreateButton({
    Name = "Teleport to player",
    Callback = function()
        local t = getTarget()
        if t and getChar(t) and getChar(LocalPlayer) then
            local hrp1 = getChar(LocalPlayer):FindFirstChild("HumanoidRootPart")
            local hrp2 = getChar(t):FindFirstChild("HumanoidRootPart")
            if hrp1 and hrp2 then
                hrp1.CFrame = hrp2.CFrame * CFrame.new(2,0,2)
            end
        end
    end
})

Tab4:CreateToggle({
    Name = "Teleport loop",
    CurrentValue = false,
    Callback = function(v)
        loopTeleport = v
    end
})

RunService.Heartbeat:Connect(function()
    if loopTeleport then
        local t = getTarget()
        if t and getChar(t) and getChar(LocalPlayer) then
            local hrp1 = getChar(LocalPlayer):FindFirstChild("HumanoidRootPart")
            local hrp2 = getChar(t):FindFirstChild("HumanoidRootPart")
            if hrp1 and hrp2 then
                hrp1.CFrame = hrp2.CFrame * CFrame.new(2,0,2)
            end
        end
    end
end)

Tab4:CreateToggle({
    Name = "Watch player",
    CurrentValue = false,
    Callback = function(v)
        watching = v
        if not v then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

RunService.RenderStepped:Connect(function()
    if watching then
    local t = getTarget()
        if t and getChar(t) then
            local hum = getChar(t):FindFirstChildOfClass("Humanoid")
            if hum then
                Camera.CameraSubject = hum
            end
        end
    end
end)

local aimingTarget = false

Tab4:CreateToggle({
    Name = "Aim to player",
    CurrentValue = false,
    Callback = function(v)
        aimingTarget = v
    end
})

RunService.RenderStepped:Connect(function()
    if aimingTarget then
        local t = getTarget()
        if t and getChar(t) then
            local hrp = getChar(t):FindFirstChild("HumanoidRootPart") or getChar(t):FindFirstChild("Head")
            if hrp then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
            end
        end
    end
end)
