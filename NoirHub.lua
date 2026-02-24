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

-- Lấy danh sách player dạng DisplayName (@Username)
local function GetPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        table.insert(names, plr.DisplayName .. " (@" .. plr.Name .. ")")
    end
    return names
end

-- Dropdown danh sách người chơi
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

-- Tự động refresh khi có người join/leave
local function RefreshDropdown()
    PlayerDropdown:Refresh(GetPlayerNames(), true)
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

--jump
local jumppower = 50
local jumpEnabled = false
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local function applyJump()
    if plr.Character then
        local hum = plr.Character:FindFirstChild("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = jumpEnabled and jumppower or 50
        end
    end
end

-- slider
PlayerTab:CreateSlider({
    Name = "Power Jump",
    Range = {50, 1000},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        jumppower = v
        applyJump()
    end
})

-- toggle
PlayerTab:CreateToggle({
    Name = "Increase Power Jump",
    CurrentValue = false,
    Callback = function(state)
        jumpEnabled = state
        applyJump()
    end
})

-- giữ sau khi respawn
plr.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyJump()
end)

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

--Auto Jump
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local autoJumpEnabled = false
local humanoid
local jumpConnection

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

humanoid = getHumanoid()
player.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
end)

local function setAutoJump(state)
    autoJumpEnabled = state
    if autoJumpEnabled then
        jumpConnection = RunService.RenderStepped:Connect(function()
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                humanoid.Jump = true
            end
        end)
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
    end
end

PlayerTab:CreateToggle({
    Name = "Auto Jump",
    CurrentValue = false,
    Callback = function(value)
        setAutoJump(value)
    end
})

PlayerTab:CreateButton({
    Name = "ShiftLock",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/shiftlock"))()
    end,
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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ESP Tab
local ESP = Window:CreateTab("Visual", "eye")

ESP:CreateSection("ESP")

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

ESP:CreateToggle({
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

ESP:CreateToggle({
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

ESP:CreateToggle({
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

ESP:CreateSection("highlight")

-- GLOBAL SETTINGS
local espSettings = {
    UseOutline = false,
    UseFill = false,
    Color = Color3.fromRGB(0,255,0),
    ShowHitbox = false,
    HitboxTransparency = 0.5,
    HitboxColor = Color3.fromRGB(255,0,0),
}

-- Tạo highlight cho 1 player
local function createHighlight(char)
    if char and not char:FindFirstChild("ESPHighlight") then
        local h = Instance.new("Highlight")
        h.Name = "ESPHighlight"
        h.Adornee = char
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
        h.Enabled = true
        h.FillTransparency = espSettings.UseFill and 0.5 or 1
        h.OutlineTransparency = espSettings.UseOutline and 0 or 1
        h.FillColor = espSettings.Color
        h.OutlineColor = espSettings.Color
    end
end

-- Update highlight settings
local function updateHighlight(char)
    local h = char and char:FindFirstChild("ESPHighlight")
    if h then
        h.FillTransparency = espSettings.UseFill and 0.5 or 1
        h.OutlineTransparency = espSettings.UseOutline and 0 or 1
        h.FillColor = espSettings.Color
        h.OutlineColor = espSettings.Color
    end
end

-- Tạo hitbox (BoxHandleAdornment vào HumanoidRootPart)
local function createHitbox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("ESPHitbox") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPHitbox"
        box.Adornee = hrp
        box.Size = hrp.Size * 2
        box.AlwaysOnTop = true
        box.ZIndex = 0
        box.Color3 = espSettings.HitboxColor
        box.Transparency = espSettings.HitboxTransparency
        box.Parent = hrp
    end
end

-- Update hitbox settings
local function updateHitbox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local box = hrp and hrp:FindFirstChild("ESPHitbox")
    if box then
        box.Color3 = espSettings.HitboxColor
        box.Transparency = espSettings.HitboxTransparency
    end
end

-- Apply ESP cho tất cả players
local function applyESP(player)
    if player.Character then
        createHighlight(player.Character)
        updateHighlight(player.Character)
        if espSettings.ShowHitbox then
            createHitbox(player.Character)
            updateHitbox(player.Character)
        end
    end
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        createHighlight(char)
        updateHighlight(char)
        if espSettings.ShowHitbox then
            createHitbox(char)
            updateHitbox(char)
        end
    end)
end

-- Gán ESP cho tất cả player hiện tại + player mới
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        applyESP(p)
    end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        applyESP(p)
    end
end)

-------------------------------------------------
-- GUI Controls
-------------------------------------------------

ESP:CreateToggle({
    Name = "Highlight Outline",
    CurrentValue = false,
    Callback = function(v)
        espSettings.UseOutline = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then updateHighlight(p.Character) end
        end
    end,
})

ESP:CreateToggle({
    Name = "Highlight Fill",
    CurrentValue = false,
    Callback = function(v)
        espSettings.UseFill = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then updateHighlight(p.Character) end
        end
    end,
})

ESP:CreateColorPicker({
    Name = "Highlight Color",
    Color = espSettings.Color,
    Callback = function(c)
        espSettings.Color = c
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then updateHighlight(p.Character) end
        end
    end,
})

ESP:CreateSection("hitbox")

ESP:CreateToggle({
    Name = "Show Hitbox",
    CurrentValue = false,
    Callback = function(v)
        espSettings.ShowHitbox = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                if v then
                    createHitbox(p.Character)
                else
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:FindFirstChild("ESPHitbox") then
                        hrp.ESPHitbox:Destroy()
                    end
                end
            end
        end
    end,
})

ESP:CreateColorPicker({
    Name = "Hitbox Color",
    Color = espSettings.HitboxColor,
    Callback = function(c)
        espSettings.HitboxColor = c
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then updateHitbox(p.Character) end
        end
    end,
})

ESP:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0,1},
    Increment = 0.1,
    CurrentValue = espSettings.HitboxTransparency,
    Callback = function(v)
        espSettings.HitboxTransparency = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then updateHitbox(p.Character) end
        end
    end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Config
local AimbotEnabled = false
local TeamCheck = true
local WallCheck = true
local DeathCheck = true -- ✅ mới: bật/tắt dead check
local FOVRadius = 100
local FOVColor = Color3.fromRGB(0, 255, 0)

local Smoothness = 0.4
local AimPart = "Head" -- mặc định aim vào đầu

-- FOV Circle
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Noir_FOVGui"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOV"
FOVCircle.Parent = ScreenGui
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false

local UIStroke = Instance.new("UIStroke", FOVCircle)
UIStroke.Thickness = 2
UIStroke.Color = FOVColor

local UICorner = Instance.new("UICorner", FOVCircle)
UICorner.CornerRadius = UDim.new(1, 0)

-- Main Tab
local Taba = Window:CreateTab("Aimbot", "target")

Taba:CreateToggle({
    Name = "Active Aimbot",
    CurrentValue = false,
    Callback = function(value)
        AimbotEnabled = value
    end
})

Taba:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(value)
        FOVCircle.Visible = value
    end
})

Taba:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(value)
        TeamCheck = value
    end
})

Taba:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Callback = function(value)
        WallCheck = value
    end
})

-- ✅ Toggle mới: Death/Dead check
Taba:CreateToggle({
    Name = "Death Check",
    CurrentValue = true,
    Callback = function(value)
        DeathCheck = value
    end
})

Taba:CreateSlider({
    Name = "Circle FOV",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(value)
        FOVRadius = value
        FOVCircle.Size = UDim2.new(0, value * 2, 0, value * 2)
    end
})

Taba:CreateSlider({
    Name = "Smooth",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 0.4,
    Callback = function(value)
        Smoothness = value
    end
})

-- Dropdown chọn part để aim
Taba:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Torso"},
    CurrentOption = "Head",
    MultipleOptions = false,
    Callback = function(option)
        AimPart = option
    end
})

-- Aimbot logic
local function GetClosestTarget()
    local closest = nil
    local shortestDist = FOVRadius

    if not Camera then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

            -- Dead check: nếu bật DeathCheck thì bỏ qua player không có Humanoid hoặc Health <= 0
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if DeathCheck then
                if not humanoid or humanoid.Health <= 0 then
                    continue
                end
            end

            if not (TeamCheck and player.Team == LocalPlayer.Team) then
                local targetPart = player.Character:FindFirstChild("HumanoidRootPart")
                if AimPart == "Head" and player.Character:FindFirstChild("Head") then
                    targetPart = player.Character.Head
                end

                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude

                    if dist <= shortestDist then
                        if WallCheck then
                            local origin = Camera.CFrame.Position
                            local direction = (targetPart.Position - origin).Unit * 1000
                            local raycastParams = RaycastParams.new()
                            if LocalPlayer.Character then
                                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            else
                                raycastParams.FilterDescendantsInstances = {}
                            end
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                            local result = workspace:Raycast(origin, direction, raycastParams)
                            if result and result.Instance and result.Instance:IsDescendantOf(player.Character) then
                                closest = player
                                shortestDist = dist
                            end
                        else
                            closest = player
                            shortestDist = dist
                        end
                    end
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and Camera then
        local target = GetClosestTarget()
        if target and target.Character then
            local part = nil
            if AimPart == "Head" then
                part = target.Character:FindFirstChild("Head")
            else
                part = target.Character:FindFirstChild("HumanoidRootPart") -- torso
            end

            if part then
                local targetPos = part.Position
                local camPos = Camera.CFrame.Position
                local newCF = CFrame.new(camPos, targetPos)
                -- Smoothly lerp camera orientation towards target
                Camera.CFrame = Camera.CFrame:Lerp(newCF, math.clamp(Smoothness, 0, 1))
            end
        end
    end
end)

local ScriptsTab = Window:CreateTab("Scripts", "file-text")

ScriptsTab:CreateSection("Funny Scripts")

ScriptsTab:CreateButton({
    Name = "Vehicle Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Vehicle%20Fly%20Gui"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Fly GUI V3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirGui/main/fly_gui_v3"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Funny by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirFunny.lua"))()
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
    Name = "FE Fling GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/FE_fling"))()
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
    Name = "Yunas FE Script Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yunus154524/YunusLo1545-HUB/refs/heads/main/YunusLo1545%20HUB"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "c00lkidd GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Angelo-Gitland/c00lkidd-Gui-V1-By-Lua-land/refs/heads/main/c00lkidd%20Gui%20V1%20By%20Lua%20Land"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "n0tGUI",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/Cz3xbk8h"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Rob Visual Script Hub",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/KSvbtcPE"))()
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
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/FE_Telekinesis"))()
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
    Name = "Tap to TP",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Tap_to_TP"))()
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
    Name = "FE Cat",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/Y1MkBRn3"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE NPC Controller",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/dacXGb2W"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Invisible",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/FE_invisible"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Invincible Fly [R6]",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/FE_invincible_v1"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Invincible Fly [R15]",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/FE_invincible_v2"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Conqueror's Haki",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/eALfcADv"))()
    end,
})

ScriptsTab:CreateLabel("(E) to active")

ScriptsTab:CreateLabel("time:8s CD:10s")

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
    Name = "Server VIP I",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZenithExility/ZenikazeHub/refs/heads/main/ZenikazeV3.1"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Server VIP II",
    Callback = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/Tesker-103/ed48b3ae8120b0c040584b661cbda063/raw/210408b3f107dc740a4c9b832bfa647f92aa25d1/FreePrivateServerGUI"))()
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

PacksTab = Window:CreateTab("Packs", "package")

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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Tab4 = Window:CreateTab("People", "users")

local currentTarget = nil
local loopTeleport = false
local watching = false
local aimingTarget = false
local aimStrength = 0.35

-- orbit variables
local orbiting = false
local orbitRadius = 10
local orbitSpeed = 30
local orbitAngle = 0

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

Tab4:CreateToggle({
    Name = "Aim to player",
    CurrentValue = false,
    Callback = function(v)
        aimingTarget = v
    end
})

Tab4:CreateSlider({
    Name = "Aim strength",
    Range = {0.1, 1},
    Increment = 0.05,
    CurrentValue = 0.35,
    Callback = function(v)
        aimStrength = v
    end
})

RunService.RenderStepped:Connect(function()
    if aimingTarget then
        local t = getTarget()
        if t and getChar(t) then
            local hrp = getChar(t):FindFirstChild("HumanoidRootPart")
            if hrp then
                local predictedPos = hrp.Position + (hrp.Velocity * 0.1)
                local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, aimStrength)
            end
        end
    end
end)

-- ORBIT UI
Tab4:CreateToggle({
    Name = "Orbit player",
    CurrentValue = false,
    Callback = function(v)
        orbiting = v
    end
})

Tab4:CreateSlider({
    Name = "Orbit radius",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(v)
        orbitRadius = v
    end
})

Tab4:CreateSlider({
    Name = "Orbit speed",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 30,
    Callback = function(v)
        orbitSpeed = v
    end
})

-- ORBIT LOGIC
RunService.Heartbeat:Connect(function(dt)
    if orbiting then
        local t = getTarget()
        if t and getChar(t) and getChar(LocalPlayer) then
            local hrp1 = getChar(LocalPlayer):FindFirstChild("HumanoidRootPart")
            local hrp2 = getChar(t):FindFirstChild("HumanoidRootPart")

            if hrp1 and hrp2 then
                orbitAngle += orbitSpeed * dt

                local offset = Vector3.new(
                    math.cos(orbitAngle) * orbitRadius,
                    0,
                    math.sin(orbitAngle) * orbitRadius
                )

                hrp1.CFrame = CFrame.new(hrp2.Position + offset, hrp2.Position)
            end
        end
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().le = getgenv().le or loadstring(game:HttpGet('https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/LimbExtender.lua'))()
local LimbExtender = getgenv().le

local le = LimbExtender({
    LISTEN_FOR_INPUT = false,
    USE_HIGHLIGHT = false,
})

local Settings = Window:CreateTab("Limbs", "scale-3d")

local function safeCreate(tab, methodName, opts)
    local method = tab[methodName]
    if type(method) == "function" then
        return method(tab, opts)
    else
        warn("Method " .. tostring(methodName) .. " not found on tab")
    end
end

local function createOption(params)
    local methodName = "Create" .. params.method
    local opts = {
        Name = params.name,
        SectionParent = params.section,
        CurrentValue = params.value,
        Flag = params.flag,
        Options = params.options,
        CurrentOption = params.currentOption,
        MultipleOptions = params.multipleOptions,
        Range = params.range,
        Color = params.color,
        Increment = params.increment,
        Callback = function(Value)
            
            if params.multipleOptions == false and type(Value) == "table" then
                Value = Value[1]
            end
            le:Set(params.flag, Value)
        end,
    }
    return safeCreate(params.tab, methodName, opts)
end

local ModifyLimbs = Settings:CreateToggle({
    Name = "Modify Limbs",
    SectionParent = nil,
    CurrentValue = false,
    Flag = "ModifyLimbs",
    Callback = function(Value)
        le:Toggle(Value)
    end,
})
Settings:CreateDivider()

local toggleSettings = {
    { method = "Toggle", name = "Team Check", flag = "TEAM_CHECK", tab = Settings, value = le:Get("TEAM_CHECK") },
    { method = "Toggle", name = "ForceField Check", flag = "FORCEFIELD_CHECK", tab = Settings, value = le:Get("FORCEFIELD_CHECK") },
    { method = "Toggle", name = "Limb Collisions", flag = "LIMB_CAN_COLLIDE", tab = Settings, value = le:Get("LIMB_CAN_COLLIDE"), createDivider = true },
    { method = "Slider", name = "Limb Transparency", flag = "LIMB_TRANSPARENCY", tab = Settings, range = {0,1}, increment = 0.1, value = le:Get("LIMB_TRANSPARENCY") },
    { method = "Slider", name = "Limb Size", flag = "LIMB_SIZE", tab = Settings, range = {5,100}, increment = 0.5, value = le:Get("LIMB_SIZE"), createDivider = true },
}

for _, setting in pairs(toggleSettings) do
    createOption(setting)
    if setting.createDivider then
        setting.tab:CreateDivider()
    end
end

Settings:CreateKeybind({
    Name = "Toggle Keybind",
    CurrentKeybind = le:Get("TOGGLE"),
    HoldToInteract = false,
    SectionParent = nil,
    Flag = "ToggleKeybind",
    Callback = function()
        ModifyLimbs:Set(not le._running)
    end,
})


local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
Sense.teamSettings.enemy.enabled = true
Sense.teamSettings.friendly.enabled = true

local function setBoth(settingName, value)
    if Sense and Sense.teamSettings then
        Sense.teamSettings.enemy[settingName] = value
        Sense.teamSettings.friendly[settingName] = value
    end
end

local function createControl(def)
    if not def or not def.type then return end

    local function applyPropsToTeams(value)
        if not def.props then return end
        local function wrapColor(c)
            if def.alpha ~= nil then
                return {c, def.alpha}
            end
            return c
        end

        if def.props.friendly then
            local target = Sense.teamSettings.friendly
            for _, propName in ipairs(def.props.friendly) do
                target[propName] = (def.type == "color") and wrapColor(value) or value
            end
        end
        if def.props.enemy then
            local target = Sense.teamSettings.enemy
            for _, propName in ipairs(def.props.enemy) do
                target[propName] = (def.type == "color") and wrapColor(value) or value
            end
        end
    end

    local function controlCallback(v)
        if def.setting then
            setBoth(def.setting, v)
        end
        applyPropsToTeams(v)
        if def.onChange then def.onChange(v) end
    end

    if def.type == "section" then
        Tab:CreateSection(def.name or "")
        return
    elseif def.type == "label" then
        Tab:CreateLabel(def.name or "")
        return
    elseif def.type == "toggle" then
        return Tab:CreateToggle({ Name = def.name, CurrentValue = def.default or false, Flag = def.flag or "", Callback = controlCallback })
    elseif def.type == "color" then
        return Tab:CreateColorPicker({ Name = def.name, Color = def.color or Color3.fromRGB(255,255,255), Flag = def.flag or "", Callback = controlCallback })
    elseif def.type == "dropdown" then
        return Tab:CreateDropdown({ Name = def.name, Options = def.options or {}, CurrentOption = def.current, Flag = def.flag or "", Callback = controlCallback })
    elseif def.type == "slider" then
        return Tab:CreateSlider({ Name = def.name, Range = def.range or {0,100}, CurrentValue = (def.default ~= nil and def.default) or ((def.range and def.range[1]) or 0), Increment = def.increment or 1, Suffix = def.suffix or "", Flag = def.flag or "", Callback = controlCallback })
    end
end

local function colorBoth(name, flag, propertiesList, defaultColor, alpha)
    return { type = "color", name = name, flag = flag, color = defaultColor, alpha = alpha or 1, props = { friendly = propertiesList, enemy = propertiesList } }
end
local function colorFriendly(name, flag, friendlyProps, defaultColor, alpha)
    return { type = "color", name = name, flag = flag, color = defaultColor, alpha = alpha or 1, props = { friendly = friendlyProps } }
end
local function colorEnemy(name, flag, enemyProps, defaultColor, alpha)
    return { type = "color", name = name, flag = flag, color = defaultColor, alpha = alpha or 1, props = { enemy = enemyProps } }
end
local function toggle(name, flag, setting, default)
    return { type = "toggle", name = name, flag = flag, setting = setting, default = default }
end
local function slider(name, flag, range, default, inc, setting)
    return { type = "slider", name = name, flag = flag, range = range, default = default, increment = inc, setting = setting }
end

local ui = {
    { type = "section", name = "Team Settings" },
    { type = "toggle", name = "Hide Team", flag = "HideTeam", default = false, onChange = function(v) Sense.teamSettings.friendly.enabled = not v end },

    colorBoth("Team Color",  "TeamColor", {"boxColor","box3dColor","offScreenArrowColor","tracerColor"}, Color3.fromRGB(0,255,0), 1),
    colorBoth("Enemy Color", "EnemyColor", {"boxColor","box3dColor","offScreenArrowColor","tracerColor"}, Color3.fromRGB(255,0,0), 1),

    { type = "section", name = "Box" },
    toggle("Enabled", "Boxes", "box", false),
    toggle("Outline", "BoxesOutlined", "boxOutline", true),
    toggle("Fill", "BoxesFilled", "boxFill", false),
    colorFriendly("Team Fill Color", "TeamFillColor", {"boxFillColor"}, Color3.fromRGB(0,255,0), 0.5),
    colorEnemy("Enemy Fill Color", "EnemyFillColor", {"boxFillColor"}, Color3.fromRGB(255,0,0), 0.5),
    toggle("3D Boxes", "3DBoxes", "box3d", false),

    { type = "section", name = "Health" },
    toggle("Enabled", "HealthBar", "healthBar", false),
    { type = "color", name = "Health Color", flag = "HealthColor", color = Color3.fromRGB(0,255,0), onChange = function(c) setBoth("healthyColor", c) end },
    { type = "color", name = "Dying Color", flag = "DyingColor", color = Color3.fromRGB(255,0,0), onChange = function(c) setBoth("dyingColor", c) end },
    toggle("Outline", "HBsOutlined", "healthBarOutline", true),

    { type = "section", name = "Tracer" },
    toggle("Enabled", "Tracers", "tracer", false),
    toggle("Outline", "TracersOutlined", "tracerOutline", true),
    { type = "dropdown", name = "Origin", flag = "TracerOrigin", options = {"Bottom","Top","Mouse"}, current = "Bottom", onChange = function(v) setBoth("tracerOrigin", v) end },

    { type = "section", name = "Chams" },
    toggle("Enabled", "Chams", "chams", false),
    toggle("Visible Only", "ChamsVisOnly", "chamsVisibleOnly", false),
    colorFriendly("Team Fill Color", "TeamFillColorChams", {"chamsFillColor"}, Color3.new(0.2,0.2,0.2), 0.5),
    colorFriendly("Team Outline Color", "TeamOutlineColorChams", {"chamsOutlineColor"}, Color3.new(0,1,0), 0),
    colorEnemy("Enemy Fill Color", "EnemyFillColorChams", {"chamsFillColor"}, Color3.new(0.2,0.2,0.2), 0.5),
    colorEnemy("Enemy Outline Color", "EnemyOutlineColorChams", {"chamsOutlineColor"}, Color3.new(1,0,0), 0),

    { type = "section", name = "Off Screen Arrow" },
    toggle("Enabled", "OSA", "offScreenArrow", false),
    slider("Size", "OSASize", {15,100}, 15, 1, "offScreenArrowSize"),
    slider("Radius", "OSARadius", {150,360}, 150, 1, "offScreenArrowRadius"),
    toggle("Outline", "OSAOutlined", "offScreenArrowOutline", true),

    { type = "section", name = "Weapon" },
    toggle("Enabled", "Weapons", "weapon", false),
    toggle("Outline", "WeaponOutlined", "weaponOutline", true),
}

for _, entry in ipairs(ui) do
    createControl(entry)
end

Sense.Load()
Rayfield:LoadConfiguration()

local limbs = {}
local function addLimbIfNew(name)
    if not name then return end
    if not table.find(limbs, name) then
        table.insert(limbs, name)
        table.sort(limbs)
        TargetLimb:Refresh(limbs)
    end
end

local function characterAdded(Character)
    if not Character then return end
    local function onChildChanged(child)
        if not child or not child:IsA("BasePart") then return end
        addLimbIfNew(child.Name)
    end

    Character.ChildAdded:Connect(onChildChanged)

    for _, child in ipairs(Character:GetChildren()) do
        onChildChanged(child)
    end
end

LocalPlayer.CharacterAdded:Connect(characterAdded)
if LocalPlayer.Character then
    characterAdded(LocalPlayer.Character)
end
