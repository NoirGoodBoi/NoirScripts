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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local le = loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirGui/refs/heads/noiryy/Limb_By_Noir"))()
le.LISTEN_FOR_INPUT = false

local limbs = {}

local limbExtenderData = getgenv().limbExtenderData

local TabL = Window:CreateTab("Limb", "scale-3d")

-- function tạo option
local function createOption(params)
    local methodName = 'Create' .. params.method  
    local method = params.tab[methodName]
    
    if type(method) == 'function' then
        method(params.tab, {
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
                if params.multipleOptions == false then
                    Value = Value[1]
                end
                le[params.flag] = Value
            end,
        })
    else
        warn("Method " .. methodName .. " not found in params.tab")
    end
end

-- Toggle chính
local ModifyLimbs = TabL:CreateToggle({
    Name = "Modify Limbs",
    CurrentValue = false,
    Flag = "ModifyLimbs",
    Callback = function(Value)
        le.toggleState(Value)
    end,
})

TabL:CreateDivider()

local UseHighlights = TabL:CreateToggle({
    Name = "Use Highlights",
    CurrentValue = le.USE_HIGHLIGHT,
    Flag = "USE_HIGHLIGHT",
    Callback = function(Value)
        le.USE_HIGHLIGHT = Value
    end,
})

TabL:CreateDivider()

-- Gộp Settings + Highlights chung vào TabL
local toggleSettings = {
    {
        method = "Toggle",
        name = "Team Check",
        flag = "TEAM_CHECK",
        tab = TabL,
        value = le.TEAM_CHECK,
    },
    {
        method = "Toggle",
        name = "ForceField Check",
        flag = "FORCEFIELD_CHECK",
        tab = TabL,
        value = le.FORCEFIELD_CHECK,
    },
    {
        method = "Toggle",
        name = "Limb Collisions",
        flag = "LIMB_CAN_COLLIDE",
        tab = TabL,
        value = le.LIMB_CAN_COLLIDE,
        createDivider = true,
    },
    {
        method = "Slider",
        name = "Limb Transparency",
        flag = "LIMB_TRANSPARENCY",
        tab = TabL,
        range = {0, 1},
        increment = 0.1,
        value = le.LIMB_TRANSPARENCY,
    },
    {
        method = "Slider",
        name = "Limb Size",
        flag = "LIMB_SIZE",
        tab = TabL,
        range = {5, 50},
        increment = 0.1,
        value = le.LIMB_SIZE,
        createDivider = true,
    },
    {
        method = "Dropdown",
        name = "Depth Mode",
        flag = "DEPTH_MODE",
        options = {"Occluded","AlwaysOnTop"},
        currentOption = {le.DEPTH_MODE},
        multipleOptions = false,
        tab = TabL,
        createDivider = true,
    },
}

for _, setting in pairs(toggleSettings) do
    createOption(setting)
    if setting.createDivider then
        TabL:CreateDivider()
    end
end

-- Dropdown chọn Limb
local TargetLimb = TabL:CreateDropdown({
   Name = "Target Limb",
   Options = {},
   CurrentOption = {le.TARGET_LIMB},
   MultipleOptions = false,
   Flag = "TARGET_LIMB",
   Callback = function(Options)
		le.TARGET_LIMB = Options[1]
   end,
})

-- Đổi Theme
TabL:CreateDropdown({
   Name = "Current Theme",
   Options = {"Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
   CurrentOption = {"Default"},
   MultipleOptions = false,
   Flag = "CurrentTheme",
   Callback = function(Options)
		Window.ModifyTheme(Options[1])
   end,
})

Rayfield:LoadConfiguration()

-- Cập nhật list Limb
local function characterAdded(Character)
    local function onChildChanged(child)
        if not child:IsA("BasePart") then return end
        if not table.find(limbs, child.Name) then
            table.insert(limbs, child.Name)
            table.sort(limbs)
            TargetLimb:Refresh(limbs)
        end
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
    Name = "Ghost Hub",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/GhostHub'))()
    end,
})

ScriptsTab:CreateButton({
    Name = "c00lkidd GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Angelo-Gitland/c00lkidd-Gui-V1-By-Lua-land/refs/heads/main/c00lkidd%20Gui%20V1%20By%20Lua%20Land"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Altair Script Hub",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/MxnvA12M/raw"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "n0tGUI",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/Cz3xbk8h"))()
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
    Name = "Conqueror's Haki",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/eALfcADv"))()
    end,
})

ScriptsTab:CreateLabel("(E) to active")

ScriptsTab:CreateLabel("time:8s CD:10s")

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
    Name = "FE Invisible",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/FE_invisible"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Invincible Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/FE_invincible_v1"))()
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

--fling
local flingTarget = false

Tab4:CreateToggle({
    Name = "Fling player",
    CurrentValue = false,
    Callback = function(v)
        flingTarget = v
        if not v and getChar(LocalPlayer) then
            local hrp = getChar(LocalPlayer):FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.zero
                local bv = hrp:FindFirstChild("FlingVelocity")
                if bv then bv:Destroy() end
            end
        end
    end
})

RunService.Heartbeat:Connect(function()
    if flingTarget then
        local t = getTarget()
        if t and getChar(t) and getChar(LocalPlayer) then
            local hrp1 = getChar(LocalPlayer):FindFirstChild("HumanoidRootPart")
            local hrp2 = getChar(t):FindFirstChild("HumanoidRootPart")
            if hrp1 and hrp2 then
                -- Gắn vào gần target
                hrp1.CFrame = hrp2.CFrame * CFrame.new(0,2,0)
                -- Thêm lực để fling
                local bv = hrp1:FindFirstChild("FlingVelocity") or Instance.new("BodyVelocity")
                bv.Name = "FlingVelocity"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = Vector3.new(200,200,200) -- chỉnh tốc độ fling ở đây
                bv.Parent = hrp1
            end
        end
    end
end)
