local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Noir Hub",
    LoadingTitle = "Loading NoirHub...",
    LoadingSubtitle = "Script By Noir_Adono",
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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local MainTab = Window:CreateTab("Main", "home")

local AllIDs = {}
local foundAnything = ""

-- Rejoin
MainTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
   end,
})

-- Server Hop
MainTab:CreateButton({
   Name = "Server Hop",
   Callback = function()

      local Site
      if foundAnything == "" then
         Site = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
      else
         Site = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..foundAnything))
      end

      if Site.nextPageCursor then
         foundAnything = Site.nextPageCursor
      end

      for i,v in pairs(Site.data) do
         local ID = tostring(v.id)
         if tonumber(v.playing) < tonumber(v.maxPlayers) and ID ~= game.JobId then

            local Possible = true
            for _,Existing in pairs(AllIDs) do
               if ID == Existing then
                  Possible = false
               end
            end

            if Possible then
               table.insert(AllIDs, ID)
               TeleportService:TeleportToPlaceInstance(game.PlaceId, ID)
               break
            end

         end
      end

   end,
})

-- Join Server Small
MainTab:CreateButton({
   Name = "Join Server Small",
   Callback = function()

      local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
      local servers = HttpService:JSONDecode(game:HttpGet(url))

      local lowest = nil
      local players = math.huge

      for _,v in pairs(servers.data) do
         if v.playing < players and v.id ~= game.JobId then
            players = v.playing
            lowest = v.id
         end
      end

      if lowest then
         TeleportService:TeleportToPlaceInstance(game.PlaceId, lowest)
      end

   end,
})

-- Join Server Fast
MainTab:CreateButton({
   Name = "Join Server Fast",
   Callback = function()

      local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
      local servers = HttpService:JSONDecode(game:HttpGet(url))

      for _,v in pairs(servers.data) do
         if v.playing < v.maxPlayers and v.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
            break
         end
      end

   end,
})

MainTab:CreateButton({
   Name = "Reset GUI Rayfield",
   Callback = function() Rayfield:Destroy() end,
})

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

local Players = game:GetService("Players")

MainTab:CreateLabel("Players:")

local function AddPlayerLabels()
    for _, player in pairs(Players:GetPlayers()) do
        MainTab:CreateLabel(player.DisplayName .. " [@" .. player.Name .. "]")
    end
end

AddPlayerLabels()

Players.PlayerAdded:Connect(function(player)
    MainTab:CreateLabel(player.DisplayName .. " [@" .. player.Name .. "]")
end)

local PlayerTab = Window:CreateTab("Player", "user")

PlayerTab:CreateSection("Tools")

--Speed
local walkspeed = 16
local defaultSpeed = nil

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

        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            if not defaultSpeed then
                defaultSpeed = plr.Character.Humanoid.WalkSpeed
            end
        end

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
                plr.Character.Humanoid.WalkSpeed = defaultSpeed or 16
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

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local noclipEnabled = false

PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(state)
        noclipEnabled = state

        if state then
            RunService:BindToRenderStep("NoirNoClip", Enum.RenderPriority.Character.Value, function()
                local char = plr.Character
                if not char then return end

                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not humanoid then return end

                humanoid:ChangeState(Enum.HumanoidStateType.Physics)

                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("NoirNoClip")

            local char = plr.Character
            if not char then return end

            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                humanoid.Jump = true
            end

            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local enabled = false
local connection

local function fixCharacter(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    humanoid.PlatformStand = false
    humanoid.AutoRotate = true
    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    humanoid.WalkSpeed = math.max(humanoid.WalkSpeed, 16)
    humanoid.JumpPower = math.max(humanoid.JumpPower, 50)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Priority == Enum.AnimationPriority.Action then
            track:Stop()
        end
    end

    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BallSocketConstraint") 
        or v:IsA("HingeConstraint") then
            v:Destroy()
        end
    end

    root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    root.AssemblyAngularVelocity = Vector3.new(0,0,0)

    for _, v in pairs(root:GetChildren()) do
        if v:IsA("BodyVelocity")
        or v:IsA("BodyGyro")
        or v:IsA("BodyPosition") then
            v:Destroy()
        end
    end
end

PlayerTab:CreateToggle({
    Name = "Anti Stun",
    CurrentValue = false,
    Callback = function(state)
        enabled = state

        if state then
            connection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    fixCharacter(char)
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
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

local MapGui, MapFrame, InfoPanel = nil, nil, nil
local MapObjects = {}
local MapEnabled = false
local RenderConnection

local Zoom = 4
local SmoothYaw = 0
local CurrentTarget = nil
local TPMode = false

--// UI
local function createMap()
    MapGui = Instance.new("ScreenGui")
    MapGui.IgnoreGuiInset = true
    MapGui.ResetOnSpawn = false
    MapGui.Parent = game.CoreGui

    -- minimap
    MapFrame = Instance.new("Frame")
    MapFrame.Size = UDim2.new(0,150,0,150)
    MapFrame.Position = UDim2.new(1,-160,0,10)
    MapFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    MapFrame.BackgroundTransparency = 0.4
    MapFrame.BorderSizePixel = 0
    MapFrame.ClipsDescendants = true
    MapFrame.Parent = MapGui
    Instance.new("UICorner", MapFrame)

    -- TP BUTTON
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0,150,0,30)
    tpBtn.Position = UDim2.new(1,-160,0,165)
    tpBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Text = "TP: OFF"
    tpBtn.Parent = MapGui
    Instance.new("UICorner", tpBtn)

    tpBtn.MouseButton1Click:Connect(function()
        TPMode = not TPMode
        tpBtn.Text = TPMode and "TP: ON" or "TP: OFF"
    end)

    -- info panel
    InfoPanel = Instance.new("Frame")
    InfoPanel.Size = UDim2.new(0,170,0,95)
    InfoPanel.Position = UDim2.new(1,-340,0,10)
    InfoPanel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    InfoPanel.BackgroundTransparency = 0.3
    InfoPanel.Visible = false
    InfoPanel.Parent = MapGui
    Instance.new("UICorner", InfoPanel)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.Size = UDim2.new(1,0,0.4,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextScaled = true
    nameLabel.Parent = InfoPanel

    local hp = Instance.new("TextLabel")
    hp.Name = "HP"
    hp.Size = UDim2.new(1,0,0.3,0)
    hp.Position = UDim2.new(0,0,0.4,0)
    hp.BackgroundTransparency = 1
    hp.TextColor3 = Color3.new(0,1,0)
    hp.TextScaled = true
    hp.Parent = InfoPanel

    local dist = Instance.new("TextLabel")
    dist.Name = "Distance"
    dist.Size = UDim2.new(1,0,0.3,0)
    dist.Position = UDim2.new(0,0,0.7,0)
    dist.BackgroundTransparency = 1
    dist.TextColor3 = Color3.new(1,1,0)
    dist.TextScaled = true
    dist.Parent = InfoPanel
end

--// DOT
local function createDot(player)
    if MapObjects[player] then return end

    local dot = Instance.new("ImageButton")
    dot.Size = UDim2.new(0,20,0,20)
    dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.BackgroundTransparency = 1
    dot.Parent = MapFrame

    dot.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"
    Instance.new("UICorner", dot)

    dot.MouseButton1Click:Connect(function()
        if TPMode then
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if myHRP and hrp then
                myHRP.CFrame = hrp.CFrame + Vector3.new(0,3,0)
            end
            return
        end

        if CurrentTarget == player then
            CurrentTarget = nil
            InfoPanel.Visible = false
        else
            CurrentTarget = player
            InfoPanel.Visible = true
            InfoPanel.PlayerName.Text = player.DisplayName.." (@"..player.Name..")"
        end
    end)

    MapObjects[player] = dot
end

--// UPDATE
local function updateDots(dt)
    if not MapEnabled then return end

    local char = LocalPlayer.Character
    local center = char and char:FindFirstChild("HumanoidRootPart")
    if not center then return end

    local targetYaw = math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X)
    SmoothYaw = SmoothYaw + (targetYaw - SmoothYaw) * math.clamp(dt * 8, 0, 1)

    for player, dot in pairs(MapObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hrp then
            local offset = (hrp.Position - center.Position) / Zoom

            local rx = offset.X*math.cos(SmoothYaw) + offset.Z*math.sin(SmoothYaw)
            local rz = -offset.X*math.sin(SmoothYaw) + offset.Z*math.cos(SmoothYaw)

            if math.abs(rx) <= 70 and math.abs(rz) <= 70 then
                dot.Visible = true
                dot.Position = UDim2.new(0.5, rx, 0.5, rz)
            else
                dot.Visible = false
            end
        else
            dot.Visible = false
        end

        if player == CurrentTarget then
            dot.ImageColor3 = Color3.fromRGB(255,100,100)
        else
            dot.ImageColor3 = Color3.fromRGB(255,255,255)
        end
    end

    if CurrentTarget and InfoPanel.Visible then
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

        local char = CurrentTarget.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hum then
            InfoPanel.HP.Text = "HP: "..math.floor(hum.Health)
        else
            InfoPanel.HP.Text = "HP: N/A"
        end

        if myHRP and hrp then
            local dist = (hrp.Position - myHRP.Position).Magnitude
            InfoPanel.Distance.Text = "Dist: "..math.floor(dist).."m"
        else
            InfoPanel.Distance.Text = "Dist: N/A"
        end
    end
end

--// INIT
local function initMap()
    createMap()

    for _,p in pairs(Players:GetPlayers()) do
        createDot(p)
    end

    Players.PlayerAdded:Connect(createDot)

    Players.PlayerRemoving:Connect(function(p)
        if MapObjects[p] then
            MapObjects[p]:Destroy()
            MapObjects[p] = nil
        end

        if CurrentTarget == p then
            CurrentTarget = nil
            InfoPanel.Visible = false
        end
    end)

    RenderConnection = RunService.RenderStepped:Connect(updateDots)
end

--// TOGGLE
PlayerTab:CreateToggle({
    Name = "MiniMap FINAL ABSOLUTE",
    CurrentValue = false,
    Callback = function(state)
        MapEnabled = state

        if state then
            if not MapGui then initMap() end
            MapGui.Enabled = true
        else
            if MapGui then MapGui.Enabled = false end
            if RenderConnection then
                RenderConnection:Disconnect()
                RenderConnection = nil
            end
        end
    end
})

-- Auto Jump System
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local humanoid
local jumpConnection
local mode = "Normal"

local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

humanoid = getHumanoid()

player.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
end)

local function stopJump()
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end
end

local function startJump()

    stopJump()

    jumpConnection = RunService.RenderStepped:Connect(function()

        if not humanoid then return end
        if humanoid.FloorMaterial == Enum.Material.Air then return end

        if mode == "Normal" then
            humanoid.Jump = true

        elseif mode == "Bhop" then
            humanoid.Jump = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

        elseif mode == "Smart" then
            if humanoid.MoveDirection.Magnitude > 0 then
                humanoid.Jump = true
            end

        elseif mode == "Force" then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

        end

    end)

end


PlayerTab:CreateDropdown({
    Name = "Auto Jump Mode",
    Options = {"Normal","Bhop","Smart","Force"},
    CurrentOption = {"Normal"},
    Callback = function(option)
        mode = option[1]
    end
})


PlayerTab:CreateToggle({
    Name = "Auto Jump",
    CurrentValue = false,
    Callback = function(state)
        if state then
            startJump()
        else
            stopJump()
        end
    end
})

PlayerTab:CreateButton({
    Name = "ShiftLock",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/Shift_Lock"))()
    end,
})

-- Vẽ tâm ảo
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local crosshairEnabled = false

-- Circle crosshair
local crosshair = Drawing.new("Circle")
crosshair.Visible = false
crosshair.Color = Color3.fromRGB(255,255,255)
crosshair.Thickness = 1
crosshair.Radius = 2
crosshair.Filled = true

-- + crosshair
local lines = {}
for i = 1,4 do
	local line = Drawing.new("Line")
	line.Visible = false
	line.Color = Color3.fromRGB(255,0,0)
	line.Thickness = 2
	table.insert(lines,line)
end

local function drawPlus(pos)

	local size = 6
	local gap = 2

	lines[1].From = Vector2.new(pos.X - size, pos.Y)
	lines[1].To   = Vector2.new(pos.X - gap, pos.Y)

	lines[2].From = Vector2.new(pos.X + gap, pos.Y)
	lines[2].To   = Vector2.new(pos.X + size, pos.Y)

	lines[3].From = Vector2.new(pos.X, pos.Y - size)
	lines[3].To   = Vector2.new(pos.X, pos.Y - gap)

	lines[4].From = Vector2.new(pos.X, pos.Y + gap)
	lines[4].To   = Vector2.new(pos.X, pos.Y + size)

end

RunService.RenderStepped:Connect(function()

	if not crosshairEnabled then
		crosshair.Visible = false
		for _,l in pairs(lines) do
			l.Visible = false
		end
		return
	end

	local viewport = camera.ViewportSize
	local center = viewport / 2

	local character = player.Character
	if not character or not character:FindFirstChild("Head") then return end

	local head = character.Head
	local distance = (camera.CFrame.Position - head.Position).Magnitude

	local pos = center

	if distance > 1 then
		local offset = camera.CFrame.RightVector * 3.5 + camera.CFrame.UpVector * 0.5
		local worldPoint = camera.CFrame.Position + camera.CFrame.LookVector * 1000 + offset
		local screenPoint = camera:WorldToViewportPoint(worldPoint)
		pos = Vector2.new(screenPoint.X,screenPoint.Y)
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist

	local ray = workspace:Raycast(
		camera.CFrame.Position,
		camera.CFrame.LookVector * 1000,
		rayParams
	)

	local enemyFound = false

	if ray and ray.Instance then
		local model = ray.Instance:FindFirstAncestorOfClass("Model")
		if model and Players:GetPlayerFromCharacter(model) then
			enemyFound = true
		end
	end

	if enemyFound then
		crosshair.Visible = false
		drawPlus(pos)

		for _,l in pairs(lines) do
			l.Visible = true
		end
	else
		crosshair.Visible = true
		crosshair.Position = pos

		for _,l in pairs(lines) do
			l.Visible = false
		end
	end

end)

-- Rayfield toggle
PlayerTab:CreateToggle({
	Name = "Crosshair",
	CurrentValue = false,
	Flag = "CrosshairToggle",
	Callback = function(Value)
		crosshairEnabled = Value
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

-- Third Person Force Toggle
local thirdPersonEnabled = false
local thirdPersonLoop = nil

PlayerTab:CreateToggle({
    Name = "Force Third Person",
    CurrentValue = false,
    Callback = function(state)
        thirdPersonEnabled = state

        if state then
            thirdPersonLoop = game:GetService("RunService").RenderStepped:Connect(function()
                if LocalPlayer and LocalPlayer.Character then
                    LocalPlayer.CameraMode = Enum.CameraMode.Classic
                    LocalPlayer.CameraMinZoomDistance = 0
                    LocalPlayer.CameraMaxZoomDistance = math.huge
                end
            end)
        else
            if thirdPersonLoop then
                thirdPersonLoop:Disconnect()
                thirdPersonLoop = nil
            end
        end
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local connection
local lastCF

PlayerTab:CreateToggle({
    Name = "No Camera Shake (GOD)",
    CurrentValue = false,
    Callback = function(state)

        if state then
            lastCF = Camera.CFrame

            connection = RunService.RenderStepped:Connect(function()
                if not Camera then return end

                local currentCF = Camera.CFrame

                local newPos = lastCF.Position:Lerp(currentCF.Position, 0.2)

                Camera.CFrame = CFrame.new(newPos) * (currentCF - currentCF.Position)

                lastCF = Camera.CFrame

                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.CameraOffset = Vector3.new(0,0,0)
                    end
                end
            end)

        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- SETTINGS
local dashLength = 100
local dashTime = 0.05
local yBoost = 10

local dashGui = nil

-- DASH FUNCTION
local function Dash()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(0, 1e5, 0)
    bg.CFrame = hrp.CFrame

    local look = hrp.CFrame.LookVector
    local dir = Vector3.new(look.X, 0, look.Z).Unit

    local speed = dashLength / dashTime

    bv.Velocity = (dir * speed) + Vector3.new(0, yBoost, 0)

    bv.Parent = hrp
    bg.Parent = hrp

    task.wait(dashTime)

    bv:Destroy()
    bg:Destroy()
end

-- CREATE FLOAT BUTTON
local function createDashButton()
    if dashGui then return end

    dashGui = Instance.new("ScreenGui")
    dashGui.Name = "NoirDashUI"
    dashGui.Parent = game.CoreGui

    local btn = Instance.new("TextButton")
    btn.Parent = dashGui
    btn.Size = UDim2.new(0, 90, 0, 90)
    btn.Position = UDim2.new(0.8, 0, 0.6, 0)

    btn.Text = "DASH"
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold

    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- tròn chuẩn
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    -- viền nhẹ
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(90, 90, 90)
    stroke.Parent = btn

    -- draggable
    btn.Active = true
    btn.Draggable = true

    -- click dash
    btn.MouseButton1Click:Connect(function()
        Dash()
    end)
end

-- REMOVE BUTTON
local function removeDashButton()
    if dashGui then
        dashGui:Destroy()
        dashGui = nil
    end
end

-- TOGGLE
PlayerTab:CreateToggle({
    Name = "Enable Dash",
    CurrentValue = false,
    Callback = function(v)
        if v then
            createDashButton()
        else
            removeDashButton()
        end
    end
})

-- SLIDER LENGTH
PlayerTab:CreateSlider({
    Name = "Dash Length",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(v)
        dashLength = v
    end
})

local Lighting = game:GetService("Lighting")

local FPSTab = Window:CreateTab("FPS", "gauge")

FPSTab:CreateSection("Visual Boost")

local oldBrightness = Lighting.Brightness
local oldClockTime = Lighting.ClockTime
local oldFogEnd = Lighting.FogEnd
local oldGlobalShadows = Lighting.GlobalShadows
local fullbrightValue = 5

FPSTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)

        if v then
            Lighting.Brightness = fullbrightValue
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = oldBrightness
            Lighting.ClockTime = oldClockTime
            Lighting.FogEnd = oldFogEnd
            Lighting.GlobalShadows = oldGlobalShadows
        end

    end,
})

FPSTab:CreateSlider({
    Name = "Fullbright Brightness",
    Range = {1,15},
    Increment = 0.5,
    CurrentValue = 5,
    Callback = function(v)

        fullbrightValue = v

        if Lighting.ClockTime == 14 then
            Lighting.Brightness = v
        end

    end,
})

local oldFogStart = Lighting.FogStart
local removedFogEffects = {}

FPSTab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Callback = function(v)

        if v then

            Lighting.FogEnd = 100000
            Lighting.FogStart = 0

            for _,obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("Atmosphere") or obj:IsA("BlurEffect") then
                    removedFogEffects[obj] = obj.Parent
                    obj.Parent = nil
                end
            end

        else

            Lighting.FogEnd = oldFogEnd
            Lighting.FogStart = oldFogStart

            for obj,parent in pairs(removedFogEffects) do
                if obj then
                    obj.Parent = parent
                end
            end

            removedFogEffects = {}

        end

    end,
})

FPSTab:CreateSection("Performance")

FPSTab:CreateToggle({
    Name = "Unlock FPS",
    CurrentValue = false,
    Callback = function(v)

        if v then
            setfpscap(0)
        else
            setfpscap(60)
        end

    end,
})

-- Boost FPS
local removedEffects = {}

FPSTab:CreateToggle({
    Name = "Boost FPS",
    CurrentValue = false,
    Callback = function(v)

        if v then

            Lighting.GlobalShadows = false

            for _,obj in pairs(game:GetDescendants()) do
                if obj:IsA("BloomEffect")
                or obj:IsA("SunRaysEffect")
                or obj:IsA("DepthOfFieldEffect")
                or obj:IsA("ColorCorrectionEffect")
                or obj:IsA("BlurEffect")
                or obj:IsA("Atmosphere")
                or obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles") then

                    removedEffects[obj] = obj.Parent
                    obj.Parent = nil

                end
            end

        else

            Lighting.GlobalShadows = true

            for obj,parent in pairs(removedEffects) do
                if obj then
                    obj.Parent = parent
                end
            end

            removedEffects = {}

        end

    end,
})

-- Ultra Boost
local removedUltra = {}

FPSTab:CreateToggle({
    Name = "Ultra Boost FPS",
    CurrentValue = false,
    Callback = function(v)

        if v then

            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false

            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
            workspace.Terrain.WaterReflectance = 0
            workspace.Terrain.WaterTransparency = 1

            for _,obj in pairs(game:GetDescendants()) do

                if obj:IsA("BloomEffect")
                or obj:IsA("SunRaysEffect")
                or obj:IsA("DepthOfFieldEffect")
                or obj:IsA("ColorCorrectionEffect")
                or obj:IsA("BlurEffect")
                or obj:IsA("Atmosphere")
                or obj:IsA("ParticleEmitter")
                or obj:IsA("Trail")
                or obj:IsA("Smoke")
                or obj:IsA("Fire")
                or obj:IsA("Sparkles")
                or obj:IsA("Texture")
                or obj:IsA("Decal") then

                    removedUltra[obj] = obj.Parent
                    obj.Parent = nil
                end
            end
        else

            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

            for obj,parent in pairs(removedUltra) do
                if obj then
                    obj.Parent = parent
                end
            end

            removedUltra = {}
        end
    end,
})

FPSTab:CreateButton({
    Name = "FINAL POTATO MODE",
    Callback = function()

        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")

        -- 1 Shadows OFF
        Lighting.GlobalShadows = false

        -- 2 Water + Grass
        if Terrain then
            Terrain.Decoration = false
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end

        -- 3 Graphics Level
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)

        -- 4 Simplify nearby objects ONLY
        local function process(obj)

            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.CastShadow = false
                obj.Reflectance = 0
            end

            if obj:IsA("MeshPart") then
                obj.RenderFidelity = Enum.RenderFidelity.Performance
            end

        end

        -- Không scan toàn map
        for _,v in ipairs(workspace:GetChildren()) do
            for _,obj in ipairs(v:GetDescendants()) do
                process(obj)
            end
        end

        -- xử lý object spawn sau
        workspace.DescendantAdded:Connect(function(obj)
            task.spawn(function()
                process(obj)
            end)
        end)

    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local ESP = Window:CreateTab("Visual","eye")

ESP:CreateSection("ESP")

local espEnabled = false
local espConnections = {}
local espInstances = {}
local nameMode = 3

local espSettings = {
UseOutline = false,
UseFill = false,
Color = Color3.fromRGB(0,255,0),
ShowHitbox = false,
HitboxTransparency = 0.5,
HitboxColor = Color3.fromRGB(255,0,0),
}

-- NAME MODE

local function getName(plr)

if nameMode == 1 then
return "@"..plr.Name
elseif nameMode == 2 then
return plr.DisplayName
else
return plr.DisplayName.." (@"..plr.Name..")"
end

end

local function removeAllESP()

for _,gui in pairs(espInstances) do
if gui and gui.Parent then
gui:Destroy()
end
end

for _,conn in pairs(espConnections) do
conn:Disconnect()
end

espInstances = {}
espConnections = {}

end

local function createESP(plr)

if plr == LocalPlayer then return end
if not plr.Character then return end

local head = plr.Character:FindFirstChild("Head")
local hrp = plr.Character:FindFirstChild("HumanoidRootPart")

if not head or not hrp then return end

local billboard = Instance.new("BillboardGui")
billboard.Name = "NoirESP"
billboard.AlwaysOnTop = true
billboard.Size = UDim2.new(0,200,0,50)
billboard.StudsOffset = Vector3.new(0,2,0)
billboard.Parent = head

local txt = Instance.new("TextLabel")
txt.Size = UDim2.new(1,0,1,0)
txt.BackgroundTransparency = 1
txt.Font = Enum.Font.SourceSansBold
txt.TextSize = 14
txt.TextColor3 = Color3.new(1,1,1)
txt.TextStrokeTransparency = 0.5
txt.Parent = billboard

local conn = RunService.RenderStepped:Connect(function()

if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude

txt.Text = getName(plr).." | "..math.floor(dist).."m"

end

end)

table.insert(espInstances,billboard)
table.insert(espConnections,conn)

end

ESP:CreateToggle({
Name = "Player ESP",
CurrentValue = false,
Callback = function(state)

espEnabled = state
removeAllESP()

if not state then return end

for _,plr in pairs(Players:GetPlayers()) do

if plr ~= LocalPlayer then

if plr.Character then
createESP(plr)
end

table.insert(espConnections,
plr.CharacterAdded:Connect(function()

if espEnabled then
task.wait(0.5)
createESP(plr)
end

end))

end

end

table.insert(espConnections,
Players.PlayerAdded:Connect(function(plr)

plr.CharacterAdded:Connect(function()

if espEnabled then
task.wait(0.5)
createESP(plr)
end

end)

end))

end
})

ESP:CreateDropdown({
Name = "ESP Name Mode",
Options = {"@Username","DisplayName","Display + @Username"},
CurrentOption = {"Display + @Username"},
MultipleOptions = false,
Callback = function(opt)

local o = opt[1]

if o == "@Username" then
nameMode = 1
elseif o == "DisplayName" then
nameMode = 2
else
nameMode = 3
end

end
})

ESP:CreateSection("Highlight")

local function createHighlight(char)

if char and not char:FindFirstChild("ESPHighlight") then

local h = Instance.new("Highlight")
h.Name = "ESPHighlight"
h.Adornee = char
h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
h.Parent = char

end

end

local function updateHighlight(char)

local h = char and char:FindFirstChild("ESPHighlight")
if h then

h.FillTransparency = espSettings.UseFill and 0.5 or 1
h.OutlineTransparency = espSettings.UseOutline and 0 or 1
h.FillColor = espSettings.Color
h.OutlineColor = espSettings.Color

end

end

local function createHitbox(char)

local hrp = char:FindFirstChild("HumanoidRootPart")

if hrp and not hrp:FindFirstChild("ESPHitbox") then

local box = Instance.new("BoxHandleAdornment")
box.Name = "ESPHitbox"
box.Adornee = hrp
box.Size = hrp.Size * 2
box.AlwaysOnTop = true
box.Color3 = espSettings.HitboxColor
box.Transparency = espSettings.HitboxTransparency
box.Parent = hrp

end

end

local function updateHitbox(char)

local hrp = char:FindFirstChild("HumanoidRootPart")
local box = hrp and hrp:FindFirstChild("ESPHitbox")

if box then

box.Color3 = espSettings.HitboxColor
box.Transparency = espSettings.HitboxTransparency

end

end

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

for _,p in ipairs(Players:GetPlayers()) do
if p ~= LocalPlayer then
applyESP(p)
end
end

Players.PlayerAdded:Connect(function(p)
if p ~= LocalPlayer then
applyESP(p)
end
end)

ESP:CreateToggle({
Name = "Highlight Outline",
CurrentValue = false,
Callback = function(v)

espSettings.UseOutline = v

for _,p in ipairs(Players:GetPlayers()) do
if p.Character then updateHighlight(p.Character) end
end

end
})

ESP:CreateToggle({
Name = "Highlight Fill",
CurrentValue = false,
Callback = function(v)

espSettings.UseFill = v

for _,p in ipairs(Players:GetPlayers()) do
if p.Character then updateHighlight(p.Character) end
end

end
})

ESP:CreateColorPicker({
Name = "Highlight Color",
Color = espSettings.Color,
Callback = function(c)

espSettings.Color = c

for _,p in ipairs(Players:GetPlayers()) do
if p.Character then updateHighlight(p.Character) end
end

end
})

ESP:CreateSection("Hitbox")

ESP:CreateToggle({
Name = "Show Hitbox",
CurrentValue = false,
Callback = function(v)

espSettings.ShowHitbox = v

for _,p in ipairs(Players:GetPlayers()) do

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

end
})

ESP:CreateColorPicker({
Name = "Hitbox Color",
Color = espSettings.HitboxColor,
Callback = function(c)

espSettings.HitboxColor = c

for _,p in ipairs(Players:GetPlayers()) do
if p.Character then updateHitbox(p.Character) end
end

end
})

ESP:CreateSlider({
Name = "Hitbox Transparency",
Range = {0,1},
Increment = 0.1,
CurrentValue = espSettings.HitboxTransparency,
Callback = function(v)

espSettings.HitboxTransparency = v

for _,p in ipairs(Players:GetPlayers()) do
if p.Character then updateHitbox(p.Character) end
end

end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Config
local AimbotEnabled = false
local NPCAimbotEnabled = false
local TeamCheck = true
local WallCheck = true
local DeathCheck = true
local FOVRadius = 100
local Smoothness = 0.4
local AimPart = "Head"
local Prediction = 0.12

-- FOV
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Noir_FOVGui"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.Position = UDim2.new(0.5,0,0.5,0)
FOVCircle.Size = UDim2.new(0,FOVRadius*2,0,FOVRadius*2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local stroke = Instance.new("UIStroke",FOVCircle)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0,255,0)

local corner = Instance.new("UICorner",FOVCircle)
corner.CornerRadius = UDim.new(1,0)

-- TAB
local Taba = Window:CreateTab("Aimbot","target")

Taba:CreateToggle({
Name="Active Aimbot",
CurrentValue=false,
Callback=function(v)
AimbotEnabled=v
end
})

Taba:CreateToggle({
Name="Aimbot NPC",
CurrentValue=false,
Callback=function(v)
NPCAimbotEnabled=v
end
})

Taba:CreateToggle({
Name="Show FOV Circle",
CurrentValue=false,
Callback=function(v)
FOVCircle.Visible=v
end
})

Taba:CreateToggle({
Name="Team Check",
CurrentValue=true,
Callback=function(v)
TeamCheck=v
end
})

Taba:CreateToggle({
Name="Wall Check",
CurrentValue=true,
Callback=function(v)
WallCheck=v
end
})

Taba:CreateToggle({
Name="Death Check",
CurrentValue=true,
Callback=function(v)
DeathCheck=v
end
})

Taba:CreateSlider({
Name="Circle FOV",
Range={50,300},
Increment=5,
CurrentValue=100,
Callback=function(v)
FOVRadius=v
FOVCircle.Size=UDim2.new(0,v*2,0,v*2)
end
})

Taba:CreateSlider({
Name="Smooth",
Range={0,1},
Increment=0.05,
CurrentValue=0.4,
Callback=function(v)
Smoothness=v
end
})

Taba:CreateSlider({
Name="Prediction",
Range={0,0.5},
Increment=0.01,
CurrentValue=0.12,
Callback=function(v)
Prediction=v
end
})

Taba:CreateDropdown({
Name="Aim Part",
Options={"Head","Torso"},
CurrentOption="Head",
MultipleOptions=false,
Callback=function(v)
AimPart=v
end
})

-- NPC Cache (FPS Boost)
local NPCList={}

local function RefreshNPCs()

NPCList={}

for _,obj in pairs(workspace:GetDescendants()) do
if obj:IsA("Model") then
if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
if not Players:GetPlayerFromCharacter(obj) then
table.insert(NPCList,obj)
end
end
end
end

end

RefreshNPCs()

task.spawn(function()
while true do
task.wait(5)
RefreshNPCs()
end
end)

-- Target Finder
local function GetClosestTarget()

local closest=nil
local shortest=FOVRadius

local function checkCharacter(char,player)

local hrp=char:FindFirstChild("HumanoidRootPart")
if not hrp then return end

local humanoid=char:FindFirstChildOfClass("Humanoid")

if DeathCheck then
if not humanoid or humanoid.Health<=0 then
return
end
end

if player and TeamCheck and player.Team==LocalPlayer.Team then
return
end

local part=hrp

if AimPart=="Head" and char:FindFirstChild("Head") then
part=char.Head
end

local pos,onScreen=Camera:WorldToViewportPoint(part.Position)
if not onScreen then return end

local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
local dist=(Vector2.new(pos.X,pos.Y)-center).Magnitude

if dist<=shortest then

if WallCheck then

local origin=Camera.CFrame.Position
local direction=(part.Position-origin).Unit*1000

local params=RaycastParams.new()
params.FilterDescendantsInstances={LocalPlayer.Character}
params.FilterType=Enum.RaycastFilterType.Blacklist

local result=workspace:Raycast(origin,direction,params)

if result and result.Instance and result.Instance:IsDescendantOf(char) then
closest=part
shortest=dist
end

else

closest=part
shortest=dist

end

end

end

-- PLAYER
if AimbotEnabled then
for _,p in pairs(Players:GetPlayers()) do
if p~=LocalPlayer and p.Character then
checkCharacter(p.Character,p)
end
end
end

-- NPC
if NPCAimbotEnabled then
for _,npc in pairs(NPCList) do
checkCharacter(npc,nil)
end
end

return closest

end

-- AIM LOOP
RunService.RenderStepped:Connect(function()

if not (AimbotEnabled or NPCAimbotEnabled) then return end
if not Camera then return end

local part=GetClosestTarget()

if part then

local targetPos=part.Position
local velocity=part.AssemblyLinearVelocity or Vector3.new()

targetPos=targetPos+(velocity*Prediction)

local camPos=Camera.CFrame.Position
local newCF=CFrame.new(camPos,targetPos)

Camera.CFrame=Camera.CFrame:Lerp(newCF,math.clamp(Smoothness,0,1))

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
    Name = "SilentAim by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/SilentAim.lua"))()
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
    Name = "Aimbot Hub (player + NPC)",
    Callback = function()
        loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/71d988cded3d4e480f4ac8f009dbf117c82320704ce873bff04c64ddd7e6d550/download"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "SilentAimNPC by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/SilentAimNPC"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Aura (Like Gojo's Infinite)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hellohellohell012321/KAWAII-AURA/main/kawaii_aura.lua", true))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Fake Items Script",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/bUEfYpZn"))()
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

ScriptsTab:CreateSection("For Some Game")

ScriptsTab:CreateButton({
    Name = "Jujutsu Shenanigans",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cool5013/TBO/main/TBOscript"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Black flash Chain (JJS)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ggab2351-stack/Jjs/refs/heads/main/Betterblackflashchain"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Uma Racing",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/UPDATE-1.0-Uma-Racing-Simple-And-Open-Source-63947"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "M1 reset",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/M1Reset.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "The Strongest Battleground",
    Callback = function()
        loadstring(game:HttpGet("https://api.getpolsec.com/scripts/hosted/7bad5e3679f40a89db9300800355a40cd92b70f3ca4c354ffe0e52444c6341fb.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "AK Gaming Ez Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hehej97/AkGamingEzv2.1/refs/heads/main/AKGaming.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Build A Bunker (Right-Shift for toggle)",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/CE0TU9ye"))()
    end,
})

ScriptsTab:CreateLabel("For in-game use only, not recommended for use in the lobby.")

ScriptsTab:CreateButton({
    Name = "Forsaken",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Snowt69/SNT-HUB/refs/heads/main/Forsaken"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Murder Mystery 2",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/wwfom1bX/raw", true))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Tower Of Zombies",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/TowerofZombies"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Survive Zombie Arena",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/qcHi3xbp/raw"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Raft 101 Survival",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/NUunqb1w"))()
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
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wefwef34/inkgames.github.io/refs/heads/main/ringta.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Deadrail",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/erewe23/deadrailsring.github.io/refs/heads/main/ringta.lua"))()
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
    Name = "FE Emote GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sypcerr/scripts/refs/heads/main/c15.lua",true))()
    end,
})


ScriptsTab:CreateButton({
    Name = "FE Animation Script Hub",
    Callback = function()
        loadstring(game:HttpGet("https://kbauu.neocities.org/animation-hub"))()
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
    Name = "Welding Abuse Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/rangell8/Rexys-Welding-Hub/refs/heads/main/script"))()
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
    Name = "Wikipedia Tool",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/4UMAeFvE"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Sandevistan FE",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Sandevistan"))()
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
    Name = "FE Wally West [For Mobile V2]",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Wally-West-Roblox-51462"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE The Flash",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/The_Flash"))()
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

--Tab Limbs
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().le = getgenv().le or loadstring(game:HttpGet("https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/LimbExtender.lua"))()
local LimbExtender = getgenv().le

local le = LimbExtender({
    LISTEN_FOR_INPUT = false,
    USE_HIGHLIGHT = false,
})

local LimbTab = Window:CreateTab("Limbs", "scale-3d")

local ModifyLimbs = LimbTab:CreateToggle({
    Name = "Modify Limbs",
    CurrentValue = false,
    Callback = function(v)
        le:Toggle(v)
    end,
})

LimbTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = le:Get("TEAM_CHECK"),
    Callback = function(v)
        le:Set("TEAM_CHECK", v)
    end,
})

LimbTab:CreateToggle({
    Name = "ForceField Check",
    CurrentValue = le:Get("FORCEFIELD_CHECK"),
    Callback = function(v)
        le:Set("FORCEFIELD_CHECK", v)
    end,
})

LimbTab:CreateToggle({
    Name = "Limb Collisions",
    CurrentValue = le:Get("LIMB_CAN_COLLIDE"),
    Callback = function(v)
        le:Set("LIMB_CAN_COLLIDE", v)
    end,
})

LimbTab:CreateSlider({
    Name = "Limb Size",
    Range = {5,100},
    Increment = 0.5,
    CurrentValue = le:Get("LIMB_SIZE"),
    Callback = function(v)
        le:Set("LIMB_SIZE", v)
    end,
})

LimbTab:CreateSlider({
    Name = "Limb Transparency",
    Range = {0,1},
    Increment = 0.1,
    CurrentValue = le:Get("LIMB_TRANSPARENCY"),
    Callback = function(v)
        le:Set("LIMB_TRANSPARENCY", v)
    end,
})

local TargetLimb = LimbTab:CreateDropdown({
    Name = "Target Limb",
    Options = {},
    CurrentOption = { le:Get("TARGET_LIMB") },
    MultipleOptions = false,
    Callback = function(opt)
        le:Set("TARGET_LIMB", opt[1])
    end,
})

local limbs = {}

local function addLimbIfNew(name)
    if not table.find(limbs, name) then
        table.insert(limbs, name)
        table.sort(limbs)
        TargetLimb:Refresh(limbs)
    end
end

local function characterAdded(Character)
    for _, part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            addLimbIfNew(part.Name)
        end
    end

    Character.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            addLimbIfNew(child.Name)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(characterAdded)

if LocalPlayer.Character then
    characterAdded(LocalPlayer.Character)
end
