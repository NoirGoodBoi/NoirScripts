local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Noir Hub",
    LoadingTitle = "Loading NoirHub...",
    LoadingSubtitle = "Script By Noir & Binbeo",
    ConfigurationSaving = {
        Enabled = false,
    }
})

Rayfield:Notify({
    Title = "Loading successful ! ",
    Content = "Mấy con gà thì biết j 😌😭",
    Duration = 2,
    Image = 4483362458
})

Rayfield:Notify({
    Title = "⚠️ Warming !",
    Content = "ĐÂY LÀ BẢN RÚT GỌN CHO DELTA 😭😓",
    Duration = 5,
    Image = 4483362458
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ProximityPromptService = game:GetService("ProximityPromptService")
local mouse = player:GetMouse()
local VirtualUser = game:GetService("VirtualUser")

local PlayerTab = Window:CreateTab("Player", "user")

PlayerTab:CreateSection("Movement")

--Speed
local walkspeed = 16
local defaultSpeed = nil

PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {1, 1000},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        walkspeed = v
    end
})

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

local function applyJump()
    if plr.Character then
        local hum = plr.Character:FindFirstChild("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = jumpEnabled and jumppower or 50
        end
    end
end

PlayerTab:CreateSlider({
    Name = "Power Jump",
    Range = {1, 1000},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        jumppower = v
        applyJump()
    end
})

PlayerTab:CreateToggle({
    Name = "Increase Power Jump",
    CurrentValue = false,
    Callback = function(state)
        jumpEnabled = state
        applyJump()
    end
})

plr.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyJump()
end)

--infJump
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

-- Auto Jump System
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

--dash
local dashLength = 5
local dashTime = 0.05
local yBoost = 20
local dashByCamera = false

local dashGui = nil

local function Dash()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(0, 1e5, 0)
    bg.CFrame = hrp.CFrame

    local dir

    if dashByCamera then
        local cam = workspace.CurrentCamera
        local look = cam.CFrame.LookVector
        dir = look.Unit
    else
        local look = hrp.CFrame.LookVector
        dir = Vector3.new(look.X, 0, look.Z).Unit
    end

    local speed = dashLength / dashTime

    if dashByCamera then
        bv.Velocity = dir * speed
    else
        bv.Velocity = (dir * speed) + Vector3.new(0, yBoost, 0)
    end

    bv.Parent = hrp
    bg.Parent = hrp

    task.wait(dashTime)

    bv:Destroy()
    bg:Destroy()
end

local function createDashButton()
    if game.CoreGui:FindFirstChild("NoirDashUI") then
        game.CoreGui.NoirDashUI:Destroy()
    end

    dashGui = Instance.new("ScreenGui")
    dashGui.Name = "NoirDashUI"
    dashGui.Parent = game.CoreGui

    local btn = Instance.new("TextButton")
    btn.Parent = dashGui
    btn.Size = UDim2.new(0, 75, 0, 75)
    btn.Position = UDim2.new(0.8, 0, 0.6, 0)

    btn.Text = "DASH"
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold

    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)

    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(90, 90, 90)
    stroke.Parent = btn

    btn.Active = true
    btn.Draggable = true

    btn.MouseButton1Click:Connect(Dash)
end

local function removeDashButton()
    if dashGui then
        dashGui:Destroy()
        dashGui = nil
    end
end

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

PlayerTab:CreateToggle({
    Name = "Dash Theo Camera",
    CurrentValue = false,
    Callback = function(v)
        dashByCamera = v
    end
})

PlayerTab:CreateSlider({
    Name = "Dash Length",
    Range = {5, 50},
    Increment = 5,
    CurrentValue = 5,
    Callback = function(v)
        dashLength = v
    end
})

--cdash
local URL_SCRIPT = "https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/CD"

local loaded = false

PlayerTab:CreateToggle({
    Name = "Curve Dash/ Side Dash",
    CurrentValue = false,
    Callback = function(val)
        if val then
            if not loaded then
                loaded = true
                loadstring(game:HttpGet(URL_SCRIPT))()
            end
        else
            loaded = false
            if _G.CDashUI then
                pcall(function()
                    _G.CDashUI:Destroy()
                end)
                _G.CDashUI = nil
            end
        end
    end
})

PlayerTab:CreateSection("Player")

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
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
})

--instant..
local promptConn
local clickConn

local function enable()
    promptConn = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if prompt then
            fireproximityprompt(prompt)
        end
    end)

    clickConn = mouse.Button1Down:Connect(function()
        local target = mouse.Target
        if target then
            local cd = target:FindFirstChildOfClass("ClickDetector")
            if cd then
                fireclickdetector(cd)
            end
        end
    end)
end
local function disable()
    if promptConn then
        promptConn:Disconnect()
        promptConn = nil
    end
    if clickConn then
        clickConn:Disconnect()
        clickConn = nil
    end
end
PlayerTab:CreateToggle({
    Name = "Instant Interact",
    CurrentValue = false,
    Callback = function(state)
        if state then
            enable()
        else
            disable()
        end
    end
})


--crosshair
local crosshairEnabled = false

local crosshair = Drawing.new("Circle")
crosshair.Visible = false
crosshair.Color = Color3.fromRGB(255,255,255)
crosshair.Thickness = 1
crosshair.Radius = 2
crosshair.Filled = true

local lines = {}
for i = 1,4 do
	local line = Drawing.new("Line")
	line.Visible = false
	line.Color = Color3.fromRGB(255,0,0)
	line.Thickness = 2
	table.insert(lines,line)
end

local function drawPlus(pos)

	local size = 8
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
		local offset = camera.CFrame.RightVector * 3 + camera.CFrame.UpVector * 1
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

PlayerTab:CreateToggle({
	Name = "Crosshair",
	CurrentValue = false,
	Flag = "CrosshairToggle",
	Callback = function(Value)
		crosshairEnabled = Value
	end,
})

PlayerTab:CreateButton({
    Name = "ShiftLock",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/Shift_Lock"))()
    end,
})

PlayerTab:CreateSection("Camera")

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

--firstp
PlayerTab:CreateButton({
    Name = "Lock First Person",
    Callback = function()
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMaxZoomDistance = 0
    end
})

local Toggles = {
    AntiFling = false,
    AntiVoid = false,
    SafePosition = false,
    SmartAntiTP = false,
    AntiStun = false
}

local LastSafePos = nil
local AntiAFKActive = false

local AntiFlingData = {
    LastVelocity = nil,
    LastPosition = nil,
    LastTime = nil,
    FlingCount = 0,
    LastAlertTime = 0
}

local function getChar()
    return LocalPlayer.Character
end

local function getHum()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function fixCharacter(hum, root)
    if not hum or not root then return end

    if hum.PlatformStand 
    or hum:GetState() == Enum.HumanoidStateType.Physics
    or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
        
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.AssemblyAngularVelocity = Vector3.zero

        if root.Orientation.Z > 45 or root.Orientation.Z < -45 then
            root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(0, 0, 1))
        end
    end
end

PlayerTab:CreateSection("Protection")

PlayerTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = false,
    Callback = function(v) Toggles.AntiFling = v end
})

PlayerTab:CreateToggle({
    Name = "Anti Stun",
    CurrentValue = false,
    Callback = function(v) Toggles.AntiStun = v end
})

PlayerTab:CreateButton({
    Name = "Anti AFK",
    Callback = function()
        if AntiAFKActive then return end
        AntiAFKActive = true
        
        local success, err = pcall(function()
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Disable()
            end
            
            task.spawn(function()
                while AntiAFKActive do
                    task.wait(30)
                    pcall(function()
                        if VirtualUser then
                            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                            task.wait(0.1)
                            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        end
                    end)
                end
            end)
        end)
        
        if success then
            Rayfield:Notify({Title = "Anti AFK", Content = "Đã bật chống AFK", Duration = 2})
        else
            AntiAFKActive = false
            Rayfield:Notify({Title = "Lỗi", Content = "Chống AFK thất bại", Duration = 2})
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Anti Void",
    CurrentValue = false,
    Callback = function(v) Toggles.AntiVoid = v end
})

PlayerTab:CreateToggle({
    Name = "Safe Position (Chống kéo)",
    CurrentValue = false,
    Callback = function(v) Toggles.SafePosition = v end
})

PlayerTab:CreateToggle({
    Name = "Smart Anti TP",
    CurrentValue = false,
    Callback = function(v) Toggles.SmartAntiTP = v end
})

RunService.Heartbeat:Connect(function()
    local char = getChar()
    local hum = getHum()
    local hrp = getHRP()
    if not char or not hum or not hrp then return end

    if Toggles.AntiFling then
        local now = tick()
        local currentVel = hrp.AssemblyLinearVelocity
        local currentPos = hrp.Position
        
        if AntiFlingData.LastVelocity and AntiFlingData.LastTime then
            local dt = now - AntiFlingData.LastTime
            if dt > 0 and dt < 0.2 then  -- Chỉ check trong khoảng ngắn
                local deltaVel = (currentVel - AntiFlingData.LastVelocity).Magnitude
                local velJump = currentVel.Magnitude - AntiFlingData.LastVelocity.Magnitude
                local posJump = (currentPos - AntiFlingData.LastPosition).Magnitude
                
                local isFling = false
                local reason = ""
                
                if deltaVel > 1000 then
                    isFling = true
                    reason = "đột biến vận tốc"
                elseif velJump > 1000 and currentVel.Magnitude > 80 then
                    isFling = true
                    reason = "tăng tốc đột ngột"
                elseif posJump > 100 and dt < 0.1 then
                    isFling = true
                    reason = "dịch chuyển đột ngột"
                end
                
                if isFling then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = CFrame.new(AntiFlingData.LastPosition or currentPos)
                    
                    hrp.Anchored = true
                    task.spawn(function()
                        task.wait(0.1)
                        if hrp then hrp.Anchored = false end
                    end)
                    
                    AntiFlingData.FlingCount = AntiFlingData.FlingCount + 1
                    if now - AntiFlingData.LastAlertTime > 3 then
                        AntiFlingData.LastAlertTime = now
                        Rayfield:Notify({
                            Title = "⚠️ Anti Fling",
                            Content = "Đã chặn fling! (" .. reason .. ")",
                            Duration = 1.5
                        })
                    end
                    
                    currentVel = Vector3.zero
                end
            end
        end
        
        AntiFlingData.LastVelocity = currentVel
        AntiFlingData.LastPosition = currentPos
        AntiFlingData.LastTime = now
    end

    if Toggles.AntiVoid and hrp.Position.Y < -10 then
        hrp.CFrame = CFrame.new(hrp.Position.X, 20, hrp.Position.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end

    if Toggles.SafePosition then
        LastSafePos = LastSafePos or hrp.Position
        local dist = (hrp.Position - LastSafePos).Magnitude
        
        if dist < 30 then
            LastSafePos = hrp.Position
        elseif dist > 80 then
            hrp.CFrame = CFrame.new(LastSafePos)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    if Toggles.SmartAntiTP then
        if LastSafePos and (hrp.Position - LastSafePos).Magnitude > 100 then
            hrp.CFrame = CFrame.new(LastSafePos)
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end

    if Toggles.AntiStun then
        fixCharacter(hum, hrp)
    end
end)

local FPSTab = Window:CreateTab("FPS", "gauge")


FPSTab:CreateButton({
    Name = "UniverHub FPS Booster",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Uranus197/-Univers-Hub-Graphics-Script-/refs/heads/main/UniversHub"))()
    end,
})

FPSTab:CreateSection("Performance")

local statsGui = nil
local fpsFrame = nil
local memFrame = nil

local function destroyStats()
    if statsGui then
        statsGui:Destroy()
        statsGui = nil
    end
end

local function getPingColor(ping)
    if ping <= 50 then
        return Color3.fromRGB(0, 255, 0)
    elseif ping <= 100 then
        return Color3.fromRGB(255, 255, 0)
    elseif ping <= 200 then
        return Color3.fromRGB(255, 165, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function getFPSColor(fps)
    if fps >= 60 then
        return Color3.fromRGB(0, 255, 0)
    elseif fps >= 30 then
        return Color3.fromRGB(255, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function getMemoryColor(mem)
    if mem <= 1000 then
        return Color3.fromRGB(0, 255, 0)
    elseif mem <= 2000 then
        return Color3.fromRGB(255, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function createStats()
    destroyStats()

    statsGui = Instance.new("ScreenGui")
    statsGui.Name = "NoirStats"
    statsGui.IgnoreGuiInset = true
    statsGui.ResetOnSpawn = false
    statsGui.Parent = game:GetService("CoreGui")

    fpsFrame = Instance.new("TextLabel")
    fpsFrame.Size = UDim2.new(0, 180, 0, 28)
    fpsFrame.Position = UDim2.new(0, 10, 0, 60)
    fpsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fpsFrame.BackgroundTransparency = 0.5
    fpsFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsFrame.Font = Enum.Font.SourceSansBold
    fpsFrame.TextSize = 14
    fpsFrame.Text = ""
    fpsFrame.Visible = false
    fpsFrame.Parent = statsGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = fpsFrame

    memFrame = Instance.new("TextLabel")
    memFrame.Size = UDim2.new(0, 180, 0, 28)
    memFrame.Position = UDim2.new(0, 10, 0, 93)
    memFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    memFrame.BackgroundTransparency = 0.5
    memFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    memFrame.Font = Enum.Font.SourceSansBold
    memFrame.TextSize = 14
    memFrame.Text = ""
    memFrame.Visible = false
    memFrame.Parent = statsGui

    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 6)
    corner2.Parent = memFrame

    local stats = game:GetService("Stats")

    game:GetService("RunService").RenderStepped:Connect(function(dt)
        if fpsFrame and fpsFrame.Visible then
            local pingStat = stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            local ping = pingStat and math.floor(pingStat:GetValue()) or 0
            local fps = math.floor(1 / dt)
            
            local pingColor = getPingColor(ping)
            local fpsColor = getFPSColor(fps)
            
            fpsFrame.Text = string.format("Ping: <font color='rgb(%d,%d,%d)'>%dms</font> | FPS: <font color='rgb(%d,%d,%d)'>%d</font>",
                pingColor.R * 255, pingColor.G * 255, pingColor.B * 255, ping,
                fpsColor.R * 255, fpsColor.G * 255, fpsColor.B * 255, fps)
            fpsFrame.RichText = true
        end

        if memFrame and memFrame.Visible then
            local mem = math.floor(stats:GetTotalMemoryUsageMb())
            local memColor = getMemoryColor(mem)
            
            memFrame.Text = string.format("Memory: <font color='rgb(%d,%d,%d)'>%d MB</font>",
                memColor.R * 255, memColor.G * 255, memColor.B * 255, mem)
            memFrame.RichText = true
        end
    end)
end

local fpsToggle = false
local memToggle = false

FPSTab:CreateToggle({
    Name = "Show FPS & Ping",
    CurrentValue = false,
    Callback = function(v)
        fpsToggle = v

        if not statsGui then
            createStats()
        end

        if fpsFrame then
            fpsFrame.Visible = v
        end

        if not fpsToggle and not memToggle then
            destroyStats()
        end
    end
})

FPSTab:CreateToggle({
    Name = "Show Memory",
    CurrentValue = false,
    Callback = function(v)
        memToggle = v

        if not statsGui then
            createStats()
        end

        if memFrame then
            memFrame.Visible = v
        end

        if not fpsToggle and not memToggle then
            destroyStats()
        end
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local espSettings = {
    UseOutline = false,
    UseFill = false,
    Color = Color3.fromRGB(0,255,0),
    ShowHitbox = false,
    HitboxTransparency = 0.5,
    HitboxColor = Color3.fromRGB(255,0,0),
}

local function getESPColor(plr)
    if plr.Team ~= nil and LocalPlayer.Team ~= nil then
        if plr.Team == LocalPlayer.Team then
            return Color3.fromRGB(0, 255, 0)
        else
            return Color3.fromRGB(255, 0, 0)
        end
    end
    return espSettings.Color
end

local ESP = Window:CreateTab("Visual","eye")

ESP:CreateSection("Player")

local espEnabled = false
local espConnections = {}
local espInstances = {}
local nameMode = 2

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
    txt.TextStrokeTransparency = 0.5
    txt.Parent = billboard

    local conn = RunService.RenderStepped:Connect(function()

        if not plr.Character 
        or not plr.Character:FindFirstChild("HumanoidRootPart") 
        or not LocalPlayer.Character 
        or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            txt.Visible = false
            return
        end

        txt.Visible = true

        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude

        txt.Text = getName(plr).." | "..math.floor(dist).."m"
        txt.TextColor3 = getESPColor(plr)

    end)

    table.insert(espInstances, billboard)
    table.insert(espConnections, conn)
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
                    end)
                )
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
            end)
        )

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
        local plr = Players:GetPlayerFromCharacter(char)
        local color = plr and getESPColor(plr) or espSettings.Color

        h.FillTransparency = espSettings.UseFill and 0.5 or 1
        h.OutlineTransparency = espSettings.UseOutline and 0 or 1
        h.FillColor = color
        h.OutlineColor = color
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
        local plr = Players:GetPlayerFromCharacter(char)
        local color = plr and getESPColor(plr) or espSettings.HitboxColor

        box.Color3 = color
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

RunService.RenderStepped:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            updateHighlight(p.Character)
            updateHitbox(p.Character)
        end
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
    Name = "Highlight Color (fallback)",
    Color = espSettings.Color,
    Callback = function(c)
        espSettings.Color = c
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
    Name = "Hitbox Color (fallback)",
    Color = espSettings.HitboxColor,
    Callback = function(c)
        espSettings.HitboxColor = c
    end
})

ESP:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0,1},
    Increment = 0.1,
    CurrentValue = espSettings.HitboxTransparency,
    Callback = function(v)
        espSettings.HitboxTransparency = v
    end
})

ESP:CreateSection("X-Ray")

local xrayEnabled = false
local saved = {}
local transparencyValue = 0.5

local function isPlayerCharacter(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    if model and Players:GetPlayerFromCharacter(model) then
        return true
    end
    return false
end

local function applyXray(state)
    xrayEnabled = state

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if isPlayerCharacter(obj) then continue end
            if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then continue end

            if state then
                if not saved[obj] then
                    saved[obj] = obj.Transparency
                end
                obj.Transparency = transparencyValue
            else
                if saved[obj] then
                    obj.Transparency = saved[obj]
                end
            end
        end
    end
end

ESP:CreateToggle({
    Name = "X-Ray",
    CurrentValue = false,
    Callback = function(value)
        applyXray(value)
    end
})

ESP:CreateSlider({
    Name = "X-Ray Transparency",
    Range = {0.3, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(value)
        transparencyValue = value

        if xrayEnabled then
            applyXray(true)
        end
    end
})

ESP:CreateSection("Tracer")

local showTracer = false
local tracerDistance = 2000

local Tracers = {}
local Boxes = {}
local HealthBars = {}

local function getESPColor(plr)
    if plr.Team and LocalPlayer.Team then
        return (plr.Team == LocalPlayer.Team)
            and Color3.fromRGB(0,255,0)
            or Color3.fromRGB(255,0,0)
    end
    return Color3.fromRGB(255,255,255)
end

local function createBoxESP(player)
    if Boxes[player] then return end

    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Visible = false

    Boxes[player] = box
end

local function createHealthBar(player)
    if HealthBars[player] then return end

    local bar = Drawing.new("Square")
    bar.Filled = true
    bar.Thickness = 1
    bar.Visible = false

    HealthBars[player] = bar
end

local function removeESP(player)
    if Tracers[player] then
        Tracers[player]:Remove()
        Tracers[player] = nil
    end

    if Boxes[player] then
        Boxes[player]:Remove()
        Boxes[player] = nil
    end

    if HealthBars[player] then
        HealthBars[player]:Remove()
        HealthBars[player] = nil
    end
end

local function setupPlayer(plr)
    if plr == LocalPlayer then return end

    createBoxESP(plr)
    createHealthBar(plr)
end

for _, plr in pairs(Players:GetPlayers()) do
    setupPlayer(plr)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar then return end

    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if not hrp or not humanoid then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (myHRP.Position - hrp.Position).Magnitude
            local color = getESPColor(player)

            if showTracer and onScreen and dist <= tracerDistance then
                
                if not Tracers[player] then
                    local line = Drawing.new("Line")
                    line.Thickness = 1.5
                    Tracers[player] = line
                end

                local line = Tracers[player]
                line.From = center
                line.To = Vector2.new(pos.X, pos.Y)
                line.Color = color
                line.Visible = true

                createBoxESP(player)

                local scale = (Camera.CFrame.Position - hrp.Position).Magnitude
                local size = math.clamp(1500 / scale, 15, 150)

                local box = Boxes[player]
                if box then
                    box.Size = Vector2.new(size, size * 1.4)
                    box.Position = Vector2.new(pos.X - size/2, pos.Y - size + 5) -- hạ xuống
                    box.Color = color
                    box.Visible = true
                end

                createHealthBar(player)

                local hb = HealthBars[player]
                if hb then
                    local hp = humanoid.Health / humanoid.MaxHealth

                    local fullHeight = size * 1.4
                    local barHeight = fullHeight * hp

                    hb.Size = Vector2.new(3, barHeight)
                    hb.Position = Vector2.new(
                        pos.X - size/2 - 6,
                        pos.Y - size + 5 + (fullHeight - barHeight)
                    )

                    hb.Color = Color3.fromRGB(
                        255 - (hp * 255),
                        hp * 255,
                        0
                    )

                    hb.Visible = true
                end

            else
                if Tracers[player] then
                    Tracers[player].Visible = false
                end

                if Boxes[player] then
                    Boxes[player].Visible = false
                end

                if HealthBars[player] then
                    HealthBars[player].Visible = false
                end
            end

        end
    end
end)

ESP:CreateToggle({
    Name = "Tracer",
    CurrentValue = false,
    Callback = function(v)
        showTracer = v
    end
})

ESP:CreateSlider({
    Name = "Tracer Distance",
    Range = {500, 10000},
    Increment = 100,
    CurrentValue = 2000,
    Callback = function(v)
        tracerDistance = v
    end
})

ESP:CreatSection("NPC")

local Settings = {
    EspName = true,
    Outline = true,
    Fill = true,
    TracerBox = true
}

local Colors = {
    Default = Color3.fromRGB(0, 255, 255),
    Team = Color3.fromRGB(255, 255, 0),
    Enemy = Color3.fromRGB(255, 165, 0)
}

local function IsPlayer(model)
    if Players:GetPlayerFromCharacter(model) then
        return true
    end
    return false
end

local function GetColor(npc)
    if npc:FindFirstChild("TeamColor") then
        return (npc.TeamColor == LocalPlayer.TeamColor) and Colors.Team or Colors.Enemy
    end
    return Colors.Default
end

local function ApplyNPC_ESP(npc)
    if IsPlayer(npc) then return end
    if not npc:FindFirstChild("HumanoidRootPart") then return end

    local NameTag = Drawing.new("Text")
    local Tracer = Drawing.new("Line")
    local Box = Drawing.new("Square")
    
    local hl = Instance.new("Highlight")
    hl.Parent = npc
    hl.Adornee = npc

    local renderLoop
    renderLoop = RunService.RenderStepped:Connect(function()
        if not npc or not npc.Parent or not npc:FindFirstChild("Humanoid") or npc.Humanoid.Health <= 0 then
            NameTag:Remove()
            Tracer:Remove()
            Box:Remove()
            hl:Destroy()
            renderLoop:Disconnect()
            return
        end

        local color = GetColor(npc)
        local hrp = npc.HumanoidRootPart
        local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)

        hl.Enabled = (Settings.Outline or Settings.Fill)
        hl.OutlineColor = color
        hl.FillColor = color
        hl.OutlineTransparency = Settings.Outline and 0 or 1
        hl.FillTransparency = Settings.Fill and 0.5 or 1

        if onScreen then
            if Settings.EspName then
                NameTag.Visible = true
                NameTag.Text = npc.Name
                NameTag.Position = Vector2.new(vector.X, vector.Y - (2500 / vector.Z) / 2 - 20)
                NameTag.Color = color
                NameTag.Center = true
                NameTag.Outline = true
                NameTag.Size = 14
            else
                NameTag.Visible = false
            end

            if Settings.TracerBox then
                local sizeX = 2200 / vector.Z
                local sizeY = 3200 / vector.Z
                
                Box.Visible = true
                Box.Size = Vector2.new(sizeX, sizeY)
                Box.Position = Vector2.new(vector.X - sizeX / 2, vector.Y - sizeY / 2)
                Box.Color = color
                Box.Thickness = 1
                Box.Filled = false

                Tracer.Visible = true
                Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                Tracer.To = Vector2.new(vector.X, vector.Y + sizeY / 2)
                Tracer.Color = color
                Tracer.Thickness = 1
            else
                Box.Visible = false
                Tracer.Visible = false
            end
        else
            NameTag.Visible = false
            Box.Visible = false
            Tracer.Visible = false
        end
    end)
end

local function ScanNPCs()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= LocalPlayer.Character then
            ApplyNPC_ESP(v)
        end
    end

    workspace.DescendantAdded:Connect(function(v)
        if v:IsA("Model") then
            task.wait(0.2)
            if v:FindFirstChild("Humanoid") and v ~= LocalPlayer.Character then
                ApplyNPC_ESP(v)
            end
        end
    end)
end

ESP:CreateToggle({
   Name = "Esp Name (NPC)",
   CurrentValue = true,
   Callback = function(Value) Settings.EspName = Value end,
})

ESP:CreateToggle({
   Name = "Highlight Outline",
   CurrentValue = true,
   Callback = function(Value) Settings.Outline = Value end,
})

ESP:CreateToggle({
   Name = "Highlight Fill",
   CurrentValue = true,
   Callback = function(Value) Settings.Fill = Value end,
})

ESP:CreateToggle({
   Name = "Tracer + Box 2D",
   CurrentValue = true,
   Callback = function(Value) Settings.TracerBox = Value end,
})

ScanNPCs()

--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotEnabled = false
local NPCAimbotEnabled = false
local TeamCheck = true
local WallCheck = true
local DeathCheck = true
local FOVRadius = 100
local Smoothness = 0.3
local AimPart = "Head"
local Prediction = 0.12
local LockSwitchDelay = 0.5

local LockedTarget = nil
local LastVelocity = Vector3.new()
local LastSwitchTime = 0
local NPCList = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local success, err = pcall(function()
    ScreenGui.Parent = LocalPlayer.PlayerGui
end)
if not success then
    ScreenGui.Parent = game:GetService("CoreGui")
end

local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false

Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", FOVCircle)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 0)

local Tab = Window:CreateTab("Aimbot", "target")

Tab:CreateSection("Aimbot")
Tab:CreateToggle({
    Name = "Active Aimbot",
    CurrentValue = false,
    Callback = function(v)
        AimbotEnabled = v
        if not v then LockedTarget = nil end
    end
})

Tab:CreateToggle({
    Name = "Aimbot NPC",
    CurrentValue = false,
    Callback = function(v)
        NPCAimbotEnabled = v
        if not v then LockedTarget = nil end
    end
})

Tab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(v)
        FOVCircle.Visible = v
    end
})

Tab:CreateSection("Check")

Tab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v)
        TeamCheck = v
    end
})

Tab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Callback = function(v)
        WallCheck = v
    end
})

Tab:CreateToggle({
    Name = "Death Check",
    CurrentValue = true,
    Callback = function(v)
        DeathCheck = v
    end
})

Tab:CreateSection("Settings")

Tab:CreateSlider({
    Name = "Circle FOV",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(v)
        FOVRadius = v
        FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
    end
})

Tab:CreateSlider({
    Name = "Smooth",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 0.3,
    Callback = function(v)
        Smoothness = v
    end
})

Tab:CreateSlider({
    Name = "Prediction",
    Range = {0, 0.5},
    Increment = 0.01,
    CurrentValue = 0.12,
    Callback = function(v)
        Prediction = v
    end
})

Tab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = {"Head"},
    Callback = function(v)
        AimPart = v[1]
        LockedTarget = nil
    end
})

local function IsDead(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return true end
    if humanoid.Health <= 0 then return true end
    return false
end

local function IsVisible(origin, targetPart)
    if not targetPart then return false end
    
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    
    if not result then return true end
    if result.Instance:IsDescendantOf(targetPart.Parent) then return true end
    
    return false
end

local function IsSameTeam(player)
    if not LocalPlayer.Team or not player.Team then return false end
    return LocalPlayer.Team == player.Team
end

local function IsCurrentTargetValid(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    
    local character = targetPart.Parent
    local player = Players:GetPlayerFromCharacter(character)
    
    if DeathCheck and IsDead(character) then
        return false
    end
    
    if TeamCheck and player and player ~= LocalPlayer then
        if IsSameTeam(player) then
            return false
        end
    end
    
    if WallCheck then
        local origin = Camera.CFrame.Position
        if not IsVisible(origin, targetPart) then
            return false
        end
    end
    
    return true
end

local function IsValidTarget(character, player)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp.Parent then return false end
    
    if DeathCheck and IsDead(character) then
        return false
    end
    
    if TeamCheck and player then
        if IsSameTeam(player) then
            return false
        end
    end
    
    return true
end

local function RefreshNPCs()
    NPCList = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if not Players:GetPlayerFromCharacter(obj) then
                table.insert(NPCList, obj)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        RefreshNPCs()
    end
end)

local function GetClosestTarget()
    local closest = nil
    local shortest = FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    local function check(character, player)
        if not IsValidTarget(character, player) then return end
        
        local part = character:FindFirstChild(AimPart) or character:FindFirstChild("HumanoidRootPart")
        if not part or not part.Parent then return end
        
        if WallCheck then
            local origin = Camera.CFrame.Position
            if not IsVisible(origin, part) then
                return
            end
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then return end
        
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < shortest and dist >= 5 then
            closest = part
            shortest = dist
        end
    end
    
    if AimbotEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.Parent then
                check(player.Character, player)
            end
        end
    end
    
    if NPCAimbotEnabled then
        for _, npc in pairs(NPCList) do
            if npc and npc.Parent then
                check(npc, nil)
            end
        end
    end
    
    return closest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2)
    
    if not (AimbotEnabled or NPCAimbotEnabled) then
        LockedTarget = nil
        return
    end
    
    if LockedTarget then
        if not IsCurrentTargetValid(LockedTarget) then
            LockedTarget = nil
        end
    end
    
    if not LockedTarget then
        LockedTarget = GetClosestTarget()
    else
    
        local newTarget = GetClosestTarget()
        if newTarget and newTarget ~= LockedTarget and (tick() - LastSwitchTime) >= LockSwitchDelay then
            local function getScreenDist(part)
                if not part then return 1e9 end
                local pos = Camera:WorldToViewportPoint(part.Position)
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                return (Vector2.new(pos.X, pos.Y) - center).Magnitude
            end
            
            local currentDist = getScreenDist(LockedTarget)
            local newDist = getScreenDist(newTarget)
            
            if newDist + 30 < currentDist then
                LockedTarget = newTarget
                LastSwitchTime = tick()
            end
        end
    end
    
    if LockedTarget and LockedTarget.Parent then
        local targetPos = LockedTarget.Position
        local velocity = LockedTarget.AssemblyLinearVelocity or Vector3.new()
        local distance = (Camera.CFrame.Position - targetPos).Magnitude
        
        LastVelocity = LastVelocity:Lerp(velocity, 0.2)
        
        local dynamicPrediction = math.clamp(distance / 100, 0, 1) * Prediction
        if distance > 15 then
            targetPos = targetPos + (LastVelocity * dynamicPrediction)
        end
        
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.new(camPos, targetPos)
        local finalCF = Camera.CFrame:Lerp(targetCF, math.clamp(Smoothness, 0, 0.8))
        
        Camera.CFrame = finalCF
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

getgenv().le = getgenv().le or loadstring(game:HttpGet("https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/LimbExtender.lua"))()
local LimbExtender = getgenv().le

local le = LimbExtender({
    LISTEN_FOR_INPUT = false,
    USE_HIGHLIGHT = false,
})

local LimbTab = Window:CreateTab("Limbs", "scale-3d")

LimbTab:CreateSection("Limbs")

local ModifyLimbs = LimbTab:CreateToggle({
    Name = "Modify Limbs",
    CurrentValue = false,
    Callback = function(v)
        le:Toggle(v)
    end,
})

LimbTab:CreateSection("Check")

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

LimbTab:CreateSection("Settings")

LimbTab:CreateSlider({
    Name = "Limb Size",
    Range = {5,500},
    Increment = 1,
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

local GameTab = Window:CreateTab("Games", "gamepad-2")

GameTab:CreateSection("Battleground")

GameTab:CreateButton({
    Name = "Jujutsu Shenanigans (TBO)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/cool5013/TBO/main/TBOscript"))()
    end,
})

GameTab:CreateButton({
    Name = "Jujutsu Shenanigans II",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/Jujutsu-Shenanigans/refs/heads/main/hai.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "M1 reset",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/M1Reset.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "The Strongest Battleground (TThanh Hub)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kaimm2/TSB/refs/heads/main/Tthanh%20Tong%20Hop%20Tech.txt"))()
    end,
})

GameTab:CreateButton({
    Name = "The Strongest Battleground II",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/TheStrongestBattlegrounds/refs/heads/main/main.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Legend Battleground",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/solarastuff/legendsbattlegrounds/refs/heads/main/legendary.lua"))()
    end,
})

GameTab:CreateSection("Nextbot")

GameTab:CreateButton({
    Name = "Evade (Elderwyrm Hub)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Vraigos/Elderwyrm-Hub-X/refs/heads/main/Scripts/Evade/Overhaul.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Evade",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/evade/refs/heads/main/shabi.lua"))()
    end,
})

GameTab:CreateSection("Survival Killer")

GameTab:CreateButton({
    Name = "Forsaken I",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Snowt69/SNT-HUB/refs/heads/main/Forsaken"))()
    end,
})

GameTab:CreateButton({
    Name = "Forsaken II",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/Forsaken/refs/heads/main/null.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Bite By Night",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/BiteBynight/refs/heads/main/ty.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Murder Mystery 2 I",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/wwfom1bX/raw", true))()
    end,
})

GameTab:CreateButton({
    Name = "Murder Mystery 2 II",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/mm2/refs/heads/main/bawe.lua", true))()
    end,
})

GameTab:CreateSection("Shooter/FPS games")

GameTab:CreateButton({
    Name = "Rivals",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/rivals/refs/heads/main/loot.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Arsenal",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/Arsenal/refs/heads/main/nah.lua"))()
    end,
})

GameTab:CreateSection("Survival")

GameTab:CreateButton({
    Name = "99 Night In The Forest I",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/loader.lua", true))()
    end,
})

GameTab:CreateButton({
    Name = "99 Night In The Forest II",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/99Nights/refs/heads/main/shiba.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Ink Game",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wefwef34/inkgames.github.io/refs/heads/main/ringta.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Deadrail (Ringta)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/erewe23/deadrailsring.github.io/refs/heads/main/ringta.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Deadrail II",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/Dead-Rails/refs/heads/main/hola.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Farm Bond (Skull Hub)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/SkullHub/main/loader.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Tower Of Zombies",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/TowerofZombies"))()
    end,
})

GameTab:CreateButton({
    Name = "Survive Zombie Arena",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/qcHi3xbp/raw"))()
    end,
})

GameTab:CreateButton({
    Name = "Raft 101 Survival",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/NUunqb1w"))()
    end,
})

GameTab:CreateSection("Racer")

GameTab:CreateButton({
    Name = "Uma Racing",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/UPDATE-1.0-Uma-Racing-Simple-And-Open-Source-63947"))()
    end,
})

GameTab:CreateSection("RNG")

GameTab:CreateButton({
    Name = "Blox Fruit",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/bloxfruit/refs/heads/main/main.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Sailor Piece",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/SailorPiece/refs/heads/main/heh.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "AK Gaming Ez Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hehej97/AkGamingEzv2.1/refs/heads/main/AKGaming.lua"))()
    end,
})

GameTab:CreateSection("Brainrot")

GameTab:CreateButton({
    Name = "Steal A Brainrot",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/stealabrainrot/refs/heads/main/shiba.lua"))()
    end,
})

GameTab:CreateSection("Battles")

GameTab:CreateButton({
    Name = "Blade Ball I",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AgentX771/ArgonHubX/main/Loader.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Blade Ball II",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/test2/refs/heads/main/bladeball.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Aura-Ascension",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/Aura-Ascension/refs/heads/main/looot.lua"))()
    end,
})

GameTab:CreateSection("Simulator")

GameTab:CreateButton({
    Name = "Bee Swarm Simulator",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/BeeSwarmSimulator/refs/heads/main/loot.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Brookhaven RP",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/Brookhaven-RP/refs/heads/main/wsp.lua"))()
    end,
})

GameTab:CreateButton({
    Name = "Adopt Me",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/testadp/main/adpt.lua"))()
    end,
})

GameTab:CreateSection("Horror")

GameTab:CreateButton({
    Name = "Doors I",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/NewBestDoorsScriptIliankytb"))()
    end,
})

GameTab:CreateButton({
    Name = "Doors II",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/Doors/refs/heads/main/wwsp.lua"))()
    end,
})

GameTab:CreateSection("Fishing")

GameTab:CreateButton({
    Name = "Fish It",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptjame/fishit/refs/heads/main/nice.lua"))()
    end,
})

GameTab:CreateSection("Story.")

GameTab:CreateButton({
    Name = "Break In 1",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Iptxt/AXHub-Loader/refs/heads/main/Loader"))()
    end,
})

GameTab:CreateButton({
    Name = "Break In 2",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EnesXVC/Breakin2/main/script"))()
    end,
})

GameTab:CreateSection("i dont know :)")

GameTab:CreateButton({
    Name = "Fling Things And People (key: ...)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BloodyV2/BloodyScript/refs/heads/main/Free"))()
    end,
})

local ScriptsTab = Window:CreateTab("Scripts", "file-text")

ScriptsTab:CreateSection("Script")

ScriptsTab:CreateButton({
    Name = "Noir Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirGui/main/Noir_Fly"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Fly GUI V3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirGui/main/fly_gui_v3"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Fly GUI V4",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/linhmcfake/Script/refs/heads/main/FLYGUIV4"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "SilentAim by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/SilentAim.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Funny by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirFunny.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Wallhop by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirGui/main/wallhop"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Wallhop",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ScpGuest666/Random-Roblox-script/refs/heads/main/Roblox%20WallHop%20V4%20script"))()
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
    Name = "BloxsTrap",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/Initiate.lua'), 'lol')()
    end,
})

ScriptsTab:CreateSection("Admin Script")

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

ScriptsTab:CreateSection("Script Hub")

ScriptsTab:CreateButton({
    Name = "Ghost Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/blabla6767yoo-cmyk/Scripts/refs/heads/main/Ghost%20Hub%20Key%20Bypass"))()
    end,
})

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
    Name = "Ultimate Trolling GUI [REBRON]",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/cZhmvb1G/raw"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "IndexZ Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/IndexZHub/Loader/main/Loader"))()
    end,
})

ScriptsTab:CreateSection("Funny Script")

ScriptsTab:CreateButton({
    Name = "Prismatica Fling",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/zood1k/Prismatica-Fling/main/PrismaticaFling"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Sandevistan FE",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Sandevistan"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Wally West [For Mobile]",
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
    Name = "Server Menu Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lumpiasallad/Roblox_ServerHop/refs/heads/main/ServerHopScript.lua"))()
    end,
})

PacksTab = Window:CreateTab("Packs", "package")

PacksTab:CreateSection("Outfit")

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

PacksTab:CreateSection("Emote & Animation")

PacksTab:CreateButton({
    Name = "Animation Pack",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gwnrdt/gwnrdt/refs/heads/main/Animation.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Animation v2.5",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/ScriptR6/AnimGuiV2.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Emote Tiktok",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Free-emote/refs/heads/main/Delta%20mad%20stuffs"))()
    end,
})

PacksTab:CreateButton({
    Name = "FE Emote (emote walk)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "FE Emote GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sypcerr/scripts/refs/heads/main/c15.lua",true))()
    end,
})

PacksTab:CreateButton({
    Name = "FE Animation Script Hub",
    Callback = function()
        loadstring(game:HttpGet("https://kbauu.neocities.org/animation-hub"))()
    end,
})

PacksTab:CreateButton({
    Name = "Animation GUI by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Animation_GUI"))()
    end,
})

PacksTab:CreateButton({
    Name = "Reanimation by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/Funny_FE_Scripts/main/Reanimation"))()
    end,
})

PacksTab:CreateButton({
    Name = "Krystal Dance v3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/somethingsimade/KDV3-Fixed/refs/heads/main/KrystalDance3"))()
    end,
})

PacksTab:CreateSection("Shader")

PacksTab:CreateButton({
    Name = "Shaders Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua"))()
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
local aimStrength = 0.4
local following = false
local followSpeed = 20
local orbiting = false
local orbitRadius = 10
local orbitSpeed = 30
local orbitHeight = 0
local orbitAngle = 0

local function getChar(p) return p and p.Character end
local function getHRP(p) local c = getChar(p) return c and c:FindFirstChild("HumanoidRootPart") end
local function getTarget() return currentTarget and Players:FindFirstChild(currentTarget) end
local function teleportTo(p)
    local hrp1 = getHRP(LocalPlayer)
    local hrp2 = getHRP(p)
    if hrp1 and hrp2 then hrp1.CFrame = hrp2.CFrame * CFrame.new(2,0,2) end
end

local function getAllTargets()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list,p) end
    end
    return list
end

local function getNearest()
    local best, dist = nil, math.huge
    local my = getHRP(LocalPlayer)
    if not my then return end
    for _, p in ipairs(getAllTargets()) do
        local hrp = getHRP(p)
        if hrp then
            local d = (my.Position - hrp.Position).Magnitude
            if d < dist then dist = d best = p end
        end
    end
    return best
end

local function getFarthest()
    local best, dist = nil, 0
    local my = getHRP(LocalPlayer)
    if not my then return end
    for _, p in ipairs(getAllTargets()) do
        local hrp = getHRP(p)
        if hrp then
            local d = (my.Position - hrp.Position).Magnitude
            if d > dist then dist = d best = p end
        end
    end
    return best
end

Tab4:CreateSection("Random")

Tab4:CreateButton({ Name="TP nearest player", Callback=function() teleportTo(getNearest()) end })
Tab4:CreateButton({ Name="TP farthest player", Callback=function() teleportTo(getFarthest()) end })
Tab4:CreateButton({ Name="TP random player", Callback=function()
    local list=getAllTargets()
    if #list>0 then teleportTo(list[math.random(1,#list)]) end
end })

Tab4:CreateSection("List")

local playerDropdown = Tab4:CreateDropdown({
    Name = "Player List",
    Options = {},
    CurrentOption = {},
    Multi = false,
    Callback = function(opt)
        if opt[1] then
            local name = opt[1]:match("%[@(.-)%]")
            currentTarget = name
        end
    end
})

local function refreshPlayers()
    local opts = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(opts, p.DisplayName.." [@"..p.Name.."]")
        end
    end
    playerDropdown:Refresh(opts, true)
end

Tab4:CreateButton({ Name="Refresh player list", Callback=refreshPlayers })
refreshPlayers()

Tab4:CreateButton({ Name="Teleport to player", Callback=function()
    local t=getTarget()
    teleportTo(t)
end })

Tab4:CreateToggle({ Name="Teleport loop (target)", CurrentValue=false, Callback=function(v) loopTeleport=v end })

Tab4:CreateToggle({ Name="Follow player", Callback=function(v) following=v end })
Tab4:CreateSlider({ Name="Follow speed", Range={5,1000}, Increment=5, CurrentValue=20, Callback=function(v) followSpeed=v end })

Tab4:CreateSection("Aim Camera")

Tab4:CreateToggle({ Name="Aim to player", CurrentValue=false, Callback=function(v) aimingTarget=v end })
Tab4:CreateSlider({ Name="Aim strength", Range={0.1,1}, Increment=0.05, CurrentValue=0.35, Callback=function(v) aimStrength=v end })

Tab4:CreateSection("Orbit")

Tab4:CreateToggle({ Name="Orbit player", CurrentValue=false, Callback=function(v) orbiting=v end })
Tab4:CreateSlider({ Name="Orbit radius", Range={1,1000}, Increment=1, CurrentValue=10, Callback=function(v) orbitRadius=v end })
Tab4:CreateSlider({ Name="Orbit speed", Range={1,1000}, Increment=1, CurrentValue=30, Callback=function(v) orbitSpeed=v end })
Tab4:CreateSlider({ Name="Orbit height (Y)", Range={-200,200}, Increment=1, CurrentValue=0, Callback=function(v) orbitHeight=v end })

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Enabled=false
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,120)
frame.Position = UDim2.new(1,-270,0.3,0)
frame.BackgroundTransparency=0.2

local avatar = Instance.new("ImageLabel", frame)
avatar.Size = UDim2.new(0,50,0,50)
avatar.Position = UDim2.new(0,10,0,10)
avatar.BackgroundTransparency=1

local info = Instance.new("TextLabel", frame)
info.Size=UDim2.new(1,-70,1,-20)
info.Position=UDim2.new(0,70,0,10)
info.BackgroundTransparency=1
info.TextScaled=true
info.TextXAlignment=Enum.TextXAlignment.Left

local left = Instance.new("TextButton", frame)
left.Size=UDim2.new(0,25,0,25)
left.Position=UDim2.new(0,10,1,-30)
left.Text="<"

local right = Instance.new("TextButton", frame)
right.Size=UDim2.new(0,25,0,25)
right.Position=UDim2.new(0,40,1,-30)
right.Text=">"

local function getIndex()
    local list=getAllTargets()
    for i,v in ipairs(list) do
        if v.Name==currentTarget then return i,list end
    end
end

left.MouseButton1Click:Connect(function()
    local i,list=getIndex()
    if i and list[i-1] then currentTarget=list[i-1].Name end
end)
right.MouseButton1Click:Connect(function()
    local i,list=getIndex()
    if i and list[i+1] then currentTarget=list[i+1].Name end
end)

Tab4:CreateSection("Spectate")

Tab4:CreateToggle({ Name="Spectate player", Callback=function(v)
    watching=v
    gui.Enabled=v
    if not v then Camera.CameraSubject=LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
end })

RunService.Heartbeat:Connect(function(dt)
    local t=getTarget()
    local hrp1=getHRP(LocalPlayer)
    local hrp2=t and getHRP(t)

    if loopTeleport and t then teleportTo(t) end

    if following and hrp1 and hrp2 then
        local pos = hrp2.Position+Vector3.new(0,0,3)
        hrp1.CFrame=hrp1.CFrame:Lerp(CFrame.new(pos), dt*(followSpeed/10))
    end

    if orbiting and hrp1 and hrp2 then
        local angularSpeed = orbitSpeed / math.max(orbitRadius, 0.1) -- tránh chia 0
        orbitAngle = orbitAngle + angularSpeed * dt
        local offset = Vector3.new(math.cos(orbitAngle) * orbitRadius, orbitHeight, math.sin(orbitAngle) * orbitRadius)
        hrp1.CFrame = CFrame.new(hrp2.Position + offset, hrp2.Position)
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local t=getTarget()
    if aimingTarget and t then
        local hrp=getHRP(t)
        if hrp then
            local predictedPos=hrp.Position + (hrp.Velocity*0.1)
            local targetCF=CFrame.new(Camera.CFrame.Position,predictedPos)
            Camera.CFrame=Camera.CFrame:Lerp(targetCF,aimStrength)
        end
    end

    if watching and t then
        local hum=getChar(t) and getChar(t):FindFirstChildOfClass("Humanoid")
        local hrp=getHRP(t)
        if hum and hrp then
            Camera.CameraSubject=hum
            local myHRP=getHRP(LocalPlayer)
            local dist=myHRP and math.floor((myHRP.Position-hrp.Position).Magnitude) or 0
            local velocity=hrp.Velocity
            local realSpeed=math.floor(Vector3.new(velocity.X,0,velocity.Z).Magnitude)
            local jumpState=hum:GetState()==Enum.HumanoidStateType.Jumping and "Jumping" or "Ground"
            avatar.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..t.UserId.."&width=150&height=150&format=png"
            info.Text=t.DisplayName.." [@"..t.Name.."]\nDist: "..dist.."\nSpeed: "..realSpeed.."\nState: "..jumpState
        end
    elseif gui.Enabled then
        info.Text=""
        avatar.Image=""
    end
end)
