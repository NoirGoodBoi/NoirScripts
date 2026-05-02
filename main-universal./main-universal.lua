-- ========== LOAD NOIRUI ==========
local NoirUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/UI/refs/heads/main/Main.lua"))()

-- ========== TẠO CỬA SỔ CHÍNH ==========
local Window = NoirUI:CreateWindow({
    Name = "🔥 NOIR HUB UNIVERSAL 🔥",
    Accent = Color3.fromRGB(255, 50, 100),
    LogoID = nil,
    Icon = 94389307911620,
    DefaultPosition = UDim2.new(0.5, -210, 0.5, -150),
    FloatDefaultPosition = UDim2.new(0, 15, 0.5, -22),
})

-- ========== DECLARE SERVICES ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

-- ========== TẠO TAB ==========
local PlayerTab = Window:CreateTab("Player", 16898612819)
local VisualTab = Window:CreateTab("Visual", 16898613353)
local AimbotTab = Window:CreateTab("Aimbot", 16898613869)
local LimbsTab = Window:CreateTab("Limbs", 16898613699)
local PeopleTab = Window:CreateTab("People", 16898613869)
local MiscTab = Window:CreateTab("Misc", 16898673999)

-- ======================== PLAYER TAB ========================
PlayerTab:CreateSection("🏃 Movement")

-- Speed
local walkspeed = 16
local defaultSpeed = nil
local speedLoop = nil

PlayerTab:CreateSlider({
    Name = "Speed",
    Min = 1,
    Max = 1000,
    Default = 16,
    Callback = function(v)
        walkspeed = v
    end
})

PlayerTab:CreateToggle({
    Name = "Increase Speed",
    Default = false,
    Callback = function(state)
        local plr = LocalPlayer
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

-- Jump Power
local jumppower = 50
local jumpEnabled = false

local function applyJump()
    local plr = LocalPlayer
    if plr.Character then
        local hum = plr.Character:FindFirstChild("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = jumpEnabled and jumppower or 50
        end
    end
end

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Min = 1,
    Max = 1000,
    Default = 50,
    Callback = function(v)
        jumppower = v
        applyJump()
    end
})

PlayerTab:CreateToggle({
    Name = "Increase Jump Power",
    Default = false,
    Callback = function(state)
        jumpEnabled = state
        applyJump()
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyJump()
end)

-- Infinity Jump
local infJumpConnection
PlayerTab:CreateToggle({
    Name = "Infinity Jump",
    Default = false,
    Callback = function(state)
        if state then
            infJumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
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
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

humanoid = getHumanoid()

LocalPlayer.CharacterAdded:Connect(function(char)
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
    Options = {"Normal", "Bhop", "Smart", "Force"},
    Default = "Normal",
    Callback = function(option)
        mode = option
    end
})

PlayerTab:CreateToggle({
    Name = "Auto Jump",
    Default = false,
    Callback = function(state)
        if state then startJump() else stopJump() end
    end
})

-- NoClip
local noclipEnabled = false
PlayerTab:CreateToggle({
    Name = "NoClip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
            RunService:BindToRenderStep("NoirNoClip", Enum.RenderPriority.Character.Value, function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("NoirNoClip")
            local char = LocalPlayer.Character
            if not char then return end
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
})

-- Instant Interact
local promptConn, clickConn
local function enableInstant()
    promptConn = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if prompt then fireproximityprompt(prompt) end
    end)
    clickConn = mouse.Button1Down:Connect(function()
        local target = mouse.Target
        if target then
            local cd = target:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd) end
        end
    end)
end
local function disableInstant()
    if promptConn then promptConn:Disconnect() promptConn = nil end
    if clickConn then clickConn:Disconnect() clickConn = nil end
end

PlayerTab:CreateToggle({
    Name = "Instant Interact",
    Default = false,
    Callback = function(state)
        if state then enableInstant() else disableInstant() end
    end
})

PlayerTab:CreateSection("📷 Camera")

-- Force Third Person
local thirdPersonEnabled = false
local thirdPersonLoop = nil
PlayerTab:CreateToggle({
    Name = "Force Third Person",
    Default = false,
    Callback = function(state)
        thirdPersonEnabled = state
        if state then
            thirdPersonLoop = RunService.RenderStepped:Connect(function()
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

PlayerTab:CreateButton({
    Name = "Lock First Person",
    Callback = function()
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMaxZoomDistance = 0
    end
})

PlayerTab:CreateSection("🛡️ Protection")

local Toggles = { AntiFling = false, AntiVoid = false, SafePosition = false, SmartAntiTP = false, AntiStun = false }
local LastSafePos = nil
local AntiAFKActive = false

local AntiFlingData = { LastVelocity = nil, LastPosition = nil, LastTime = nil, FlingCount = 0, LastAlertTime = 0 }

local function getChar() return LocalPlayer.Character end
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
    if hum.PlatformStand or hum:GetState() == Enum.HumanoidStateType.Physics or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.AssemblyAngularVelocity = Vector3.zero
        if root.Orientation.Z > 45 or root.Orientation.Z < -45 then
            root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(0, 0, 1))
        end
    end
end

PlayerTab:CreateToggle({ Name = "Anti Fling", Default = false, Callback = function(v) Toggles.AntiFling = v end })
PlayerTab:CreateToggle({ Name = "Anti Stun", Default = false, Callback = function(v) Toggles.AntiStun = v end })
PlayerTab:CreateToggle({ Name = "Anti Void", Default = false, Callback = function(v) Toggles.AntiVoid = v end })
PlayerTab:CreateToggle({ Name = "Safe Position", Default = false, Callback = function(v) Toggles.SafePosition = v end })
PlayerTab:CreateToggle({ Name = "Smart Anti TP", Default = false, Callback = function(v) Toggles.SmartAntiTP = v end })

PlayerTab:CreateButton({
    Name = "Anti AFK",
    Callback = function()
        if AntiAFKActive then return end
        AntiAFKActive = true
        pcall(function()
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do v:Disable() end
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
        NoirUI:Notify("Anti AFK", "Đã bật chống AFK")
    end
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
            if dt > 0 and dt < 0.2 then
                local deltaVel = (currentVel - AntiFlingData.LastVelocity).Magnitude
                local velJump = currentVel.Magnitude - AntiFlingData.LastVelocity.Magnitude
                local posJump = (currentPos - AntiFlingData.LastPosition).Magnitude
                
                local isFling = false
                local reason = ""
                
                if deltaVel > 1000 then isFling = true reason = "đột biến vận tốc"
                elseif velJump > 1000 and currentVel.Magnitude > 80 then isFling = true reason = "tăng tốc đột ngột"
                elseif posJump > 100 and dt < 0.1 then isFling = true reason = "dịch chuyển đột ngột"
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
                        NoirUI:Notify("⚠️ Anti Fling", "Đã chặn fling! (" .. reason .. ")")
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
        if dist < 30 then LastSafePos = hrp.Position
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

    if Toggles.AntiStun then fixCharacter(hum, hrp) end
end)

-- ======================== VISUAL TAB ========================
VisualTab:CreateSection("👥 Player ESP")

local espEnabled = false
local espConnections = {}
local espInstances = {}
local nameMode = 2

local function getName(plr)
    if nameMode == 1 then return "@"..plr.Name
    elseif nameMode == 2 then return plr.DisplayName
    else return plr.DisplayName.." (@"..plr.Name..")"
    end
end

local function getESPColor(plr)
    if plr.Team ~= nil and LocalPlayer.Team ~= nil then
        if plr.Team == LocalPlayer.Team then return Color3.fromRGB(0, 255, 0)
        else return Color3.fromRGB(255, 0, 0)
        end
    end
    return Color3.fromRGB(0, 255, 0)
end

local function removeAllESP()
    for _,gui in pairs(espInstances) do if gui and gui.Parent then gui:Destroy() end end
    for _,conn in pairs(espConnections) do conn:Disconnect() end
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
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
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

VisualTab:CreateToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(state)
        espEnabled = state
        removeAllESP()
        if not state then return end
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if plr.Character then createESP(plr) end
                table.insert(espConnections, plr.CharacterAdded:Connect(function()
                    if espEnabled then task.wait(0.5); createESP(plr) end
                end))
            end
        end
        table.insert(espConnections, Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                if espEnabled then task.wait(0.5); createESP(plr) end
            end)
        end))
    end
})

VisualTab:CreateDropdown({
    Name = "ESP Name Mode",
    Options = {"@Username", "DisplayName", "Display + @Username"},
    Default = "Display + @Username",
    Callback = function(opt)
        if opt == "@Username" then nameMode = 1
        elseif opt == "DisplayName" then nameMode = 2
        else nameMode = 3 end
    end
})

VisualTab:CreateSection("✨ Highlight")

local highlightSettings = { UseOutline = false, UseFill = false, Color = Color3.fromRGB(0,255,0) }

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
        local color = plr and getESPColor(plr) or highlightSettings.Color
        h.FillTransparency = highlightSettings.UseFill and 0.5 or 1
        h.OutlineTransparency = highlightSettings.UseOutline and 0 or 1
        h.FillColor = color
        h.OutlineColor = color
    end
end

local function applyHighlight(player)
    if player.Character then
        createHighlight(player.Character)
        updateHighlight(player.Character)
    end
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        createHighlight(char)
        updateHighlight(char)
    end)
end

for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then applyHighlight(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then applyHighlight(p) end end)
RunService.RenderStepped:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then updateHighlight(p.Character) end
    end
end)

VisualTab:CreateToggle({ Name = "Highlight Outline", Default = false, Callback = function(v)
    highlightSettings.UseOutline = v
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then updateHighlight(p.Character) end end
end })
VisualTab:CreateToggle({ Name = "Highlight Fill", Default = false, Callback = function(v)
    highlightSettings.UseFill = v
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then updateHighlight(p.Character) end end
end })
VisualTab:CreateColorPicker({ Name = "Highlight Color", Default = highlightSettings.Color, Callback = function(c) highlightSettings.Color = c end })

VisualTab:CreateSection("🔍 X-Ray")

local xrayEnabled = false
local saved = {}
local transparencyValue = 0.5

local function isPlayerCharacter(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    if model and Players:GetPlayerFromCharacter(model) then return true end
    return false
end

local function applyXray(state)
    xrayEnabled = state
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if isPlayerCharacter(obj) then continue end
            if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then continue end
            if state then
                if not saved[obj] then saved[obj] = obj.Transparency end
                obj.Transparency = transparencyValue
            else
                if saved[obj] then obj.Transparency = saved[obj] end
            end
        end
    end
end

VisualTab:CreateToggle({ Name = "X-Ray", Default = false, Callback = function(v) applyXray(v) end })
VisualTab:CreateSlider({ Name = "X-Ray Transparency", Min = 0.3, Max = 1, Default = 0.5, Callback = function(v)
    transparencyValue = v
    if xrayEnabled then applyXray(true) end
end })

VisualTab:CreateSection("📊 Tracer")

local showTracer = false
local tracerDistance = 2000
local Tracers = {}
local Boxes = {}
local HealthBars = {}

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
    if Tracers[player] then Tracers[player]:Remove() Tracers[player] = nil end
    if Boxes[player] then Boxes[player]:Remove() Boxes[player] = nil end
    if HealthBars[player] then HealthBars[player]:Remove() HealthBars[player] = nil end
end

local function setupPlayer(plr)
    if plr == LocalPlayer then return end
    createBoxESP(plr)
    createHealthBar(plr)
end

for _, plr in pairs(Players:GetPlayers()) do setupPlayer(plr) end
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
                    box.Position = Vector2.new(pos.X - size/2, pos.Y - size + 5)
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
                    hb.Position = Vector2.new(pos.X - size/2 - 6, pos.Y - size + 5 + (fullHeight - barHeight))
                    hb.Color = Color3.fromRGB(255 - (hp * 255), hp * 255, 0)
                    hb.Visible = true
                end
            else
                if Tracers[player] then Tracers[player].Visible = false end
                if Boxes[player] then Boxes[player].Visible = false end
                if HealthBars[player] then HealthBars[player].Visible = false end
            end
        end
    end
end)

VisualTab:CreateToggle({ Name = "Tracer", Default = false, Callback = function(v) showTracer = v end })
VisualTab:CreateSlider({ Name = "Tracer Distance", Min = 500, Max = 10000, Default = 2000, Callback = function(v) tracerDistance = v end })

VisualTab:CreateSection("🤖 NPC ESP")

local npcSettings = { EspName = true, Outline = true, Fill = true, TracerBox = true }
local npcColors = { Default = Color3.fromRGB(0, 255, 255), Team = Color3.fromRGB(255, 255, 0), Enemy = Color3.fromRGB(255, 165, 0) }

local function IsPlayer(model) return Players:GetPlayerFromCharacter(model) and true or false end
local function GetNPCColor(npc)
    if npc:FindFirstChild("TeamColor") then
        return (npc.TeamColor == LocalPlayer.TeamColor) and npcColors.Team or npcColors.Enemy
    end
    return npcColors.Default
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
            NameTag:Remove(); Tracer:Remove(); Box:Remove(); hl:Destroy(); renderLoop:Disconnect()
            return
        end
        local color = GetNPCColor(npc)
        local hrp = npc.HumanoidRootPart
        local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        hl.Enabled = (npcSettings.Outline or npcSettings.Fill)
        hl.OutlineColor = color
        hl.FillColor = color
        hl.OutlineTransparency = npcSettings.Outline and 0 or 1
        hl.FillTransparency = npcSettings.Fill and 0.5 or 1

        if onScreen then
            if npcSettings.EspName then
                NameTag.Visible = true
                NameTag.Text = npc.Name
                NameTag.Position = Vector2.new(vector.X, vector.Y - (2500 / vector.Z) / 2 - 20)
                NameTag.Color = color
                NameTag.Center = true
                NameTag.Outline = true
                NameTag.Size = 14
            else NameTag.Visible = false end

            if npcSettings.TracerBox then
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
            else Box.Visible = false; Tracer.Visible = false end
        else NameTag.Visible = false; Box.Visible = false; Tracer.Visible = false end
    end)
end

local function ScanNPCs()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= LocalPlayer.Character then ApplyNPC_ESP(v) end
    end
    workspace.DescendantAdded:Connect(function(v)
        if v:IsA("Model") then
            task.wait(0.2)
            if v:FindFirstChild("Humanoid") and v ~= LocalPlayer.Character then ApplyNPC_ESP(v) end
        end
    end)
end

VisualTab:CreateToggle({ Name = "ESP Name (NPC)", Default = true, Callback = function(v) npcSettings.EspName = v end })
VisualTab:CreateToggle({ Name = "Highlight Outline (NPC)", Default = true, Callback = function(v) npcSettings.Outline = v end })
VisualTab:CreateToggle({ Name = "Highlight Fill (NPC)", Default = true, Callback = function(v) npcSettings.Fill = v end })
VisualTab:CreateToggle({ Name = "Tracer + Box 2D (NPC)", Default = true, Callback = function(v) npcSettings.TracerBox = v end })
ScanNPCs()

-- ======================== AIMBOT TAB ========================
AimbotTab:CreateSection("🎯 Aimbot Settings")

local aimbotSettings = {
    Enabled = false, NPCEnabled = false, TeamCheck = true, WallCheck = true, DeathCheck = true,
    FOVRadius = 200, Smoothness = 1, AimPart = "Head", Prediction = 0, LockSwitchDelay = 0.5
}
local LockedTarget = nil
local LastVelocity = Vector3.new()
local LastSwitchTime = 0
local NPCList = {}

-- FOV Circle
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = LocalPlayer.PlayerGui end)
if not ScreenGui.Parent then ScreenGui.Parent = game:GetService("CoreGui") end

local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", FOVCircle)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 0)

AimbotTab:CreateToggle({ Name = "Active Aimbot", Default = false, Callback = function(v) aimbotSettings.Enabled = v; if not v then LockedTarget = nil end end })
AimbotTab:CreateToggle({ Name = "Aimbot NPC", Default = false, Callback = function(v) aimbotSettings.NPCEnabled = v; if not v then LockedTarget = nil end end })
AimbotTab:CreateToggle({ Name = "Show FOV Circle", Default = false, Callback = function(v) FOVCircle.Visible = v end })
AimbotTab:CreateSection("⚙️ Checks")
AimbotTab:CreateToggle({ Name = "Team Check", Default = true, Callback = function(v) aimbotSettings.TeamCheck = v end })
AimbotTab:CreateToggle({ Name = "Wall Check", Default = true, Callback = function(v) aimbotSettings.WallCheck = v end })
AimbotTab:CreateToggle({ Name = "Death Check", Default = true, Callback = function(v) aimbotSettings.DeathCheck = v end })
AimbotTab:CreateSection("⚙️ Settings")
AimbotTab:CreateSlider({ Name = "Circle FOV", Min = 50, Max = 300, Default = 200, Callback = function(v)
    aimbotSettings.FOVRadius = v
    FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
end })
AimbotTab:CreateSlider({ Name = "Smooth", Min = 0, Max = 1, Default = 1, Callback = function(v) aimbotSettings.Smoothness = v end })
AimbotTab:CreateSlider({ Name = "Prediction", Min = 0, Max = 0.5, Default = 0, Callback = function(v) aimbotSettings.Prediction = v end })
AimbotTab:CreateDropdown({ Name = "Aim Part", Options = {"Head", "HumanoidRootPart"}, Default = "Head", Callback = function(v) aimbotSettings.AimPart = v; LockedTarget = nil end })

local function IsDead(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return true end
    return humanoid.Health <= 0
end

local function IsVisible(origin, targetPart)
    if not targetPart then return false end
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
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
    if aimbotSettings.DeathCheck and IsDead(character) then return false end
    if aimbotSettings.TeamCheck and player and player ~= LocalPlayer and IsSameTeam(player) then return false end
    if aimbotSettings.WallCheck then
        local origin = Camera.CFrame.Position
        if not IsVisible(origin, targetPart) then return false end
    end
    return true
end

local function IsValidTarget(character, player)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp.Parent then return false end
    if aimbotSettings.DeathCheck and IsDead(character) then return false end
    if aimbotSettings.TeamCheck and player and IsSameTeam(player) then return false end
    return true
end

local function RefreshNPCs()
    NPCList = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if not Players:GetPlayerFromCharacter(obj) then table.insert(NPCList, obj) end
        end
    end
end
task.spawn(function() while true do task.wait(2) RefreshNPCs() end end)

local function GetClosestTarget()
    local closest = nil
    local shortest = aimbotSettings.FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    local function check(character, player)
        if not IsValidTarget(character, player) then return end
        local part = character:FindFirstChild(aimbotSettings.AimPart) or character:FindFirstChild("HumanoidRootPart")
        if not part or not part.Parent then return end
        if aimbotSettings.WallCheck then
            local origin = Camera.CFrame.Position
            if not IsVisible(origin, part) then return end
        end
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then return end
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < shortest and dist >= 5 then closest = part; shortest = dist end
    end
    
    if aimbotSettings.Enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character.Parent then check(player.Character, player) end
        end
    end
    if aimbotSettings.NPCEnabled then
        for _, npc in pairs(NPCList) do if npc and npc.Parent then check(npc, nil) end end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UDim2.new(0, Camera.ViewportSize.X / 2, 0, Camera.ViewportSize.Y / 2)
    if not (aimbotSettings.Enabled or aimbotSettings.NPCEnabled) then LockedTarget = nil; return end
    
    if LockedTarget then
        if not IsCurrentTargetValid(LockedTarget) then LockedTarget = nil end
    end
    
    if not LockedTarget then LockedTarget = GetClosestTarget()
    else
        local newTarget = GetClosestTarget()
        if newTarget and newTarget ~= LockedTarget and (tick() - LastSwitchTime) >= aimbotSettings.LockSwitchDelay then
            local function getScreenDist(part)
                if not part then return 1e9 end
                local pos = Camera:WorldToViewportPoint(part.Position)
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                return (Vector2.new(pos.X, pos.Y) - center).Magnitude
            end
            if getScreenDist(newTarget) + 30 < getScreenDist(LockedTarget) then
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
        local dynamicPrediction = math.clamp(distance / 100, 0, 1) * aimbotSettings.Prediction
        if distance > 15 then targetPos = targetPos + (LastVelocity * dynamicPrediction) end
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.new(camPos, targetPos)
        local finalCF = Camera.CFrame:Lerp(targetCF, math.clamp(aimbotSettings.Smoothness, 0, 0.8))
        Camera.CFrame = finalCF
    end
end)

-- ======================== LIMBS TAB (LimbExtender) ========================
local LimbExtender = loadstring(game:HttpGet("https://raw.githubusercontent.com/AAPVdev/scripts/refs/heads/main/LimbExtender.lua"))()
local le = LimbExtender({ LISTEN_FOR_INPUT = false, USE_HIGHLIGHT = false })

LimbsTab:CreateSection("🦴 Limb Settings")
LimbsTab:CreateToggle({ Name = "Modify Limbs", Default = false, Callback = function(v) le:Toggle(v) end })
LimbsTab:CreateSection("⚙️ Checks")
LimbsTab:CreateToggle({ Name = "Team Check", Default = le:Get("TEAM_CHECK"), Callback = function(v) le:Set("TEAM_CHECK", v) end })
LimbsTab:CreateToggle({ Name = "ForceField Check", Default = le:Get("FORCEFIELD_CHECK"), Callback = function(v) le:Set("FORCEFIELD_CHECK", v) end })
LimbsTab:CreateToggle({ Name = "Limb Collisions", Default = le:Get("LIMB_CAN_COLLIDE"), Callback = function(v) le:Set("LIMB_CAN_COLLIDE", v) end })
LimbsTab:CreateSection("⚙️ Settings")
LimbsTab:CreateSlider({ Name = "Limb Size", Min = 5, Max = 500, Default = le:Get("LIMB_SIZE"), Callback = function(v) le:Set("LIMB_SIZE", v) end })
LimbsTab:CreateSlider({ Name = "Limb Transparency", Min = 0, Max = 1, Default = le:Get("LIMB_TRANSPARENCY"), Callback = function(v) le:Set("LIMB_TRANSPARENCY", v) end })

local TargetLimbDropdown
local limbs = {}
local function addLimbIfNew(name)
    if not table.find(limbs, name) then
        table.insert(limbs, name)
        table.sort(limbs)
        if TargetLimbDropdown then TargetLimbDropdown:Refresh(limbs) end
    end
end

local function characterAdded(Character)
    for _, part in ipairs(Character:GetChildren()) do if part:IsA("BasePart") then addLimbIfNew(part.Name) end end
    Character.ChildAdded:Connect(function(child) if child:IsA("BasePart") then addLimbIfNew(child.Name) end end)
end

TargetLimbDropdown = LimbsTab:CreateDropdown({
    Name = "Target Limb", Options = {}, Default = le:Get("TARGET_LIMB"),
    Callback = function(opt) le:Set("TARGET_LIMB", opt) end
})
LocalPlayer.CharacterAdded:Connect(characterAdded)
if LocalPlayer.Character then characterAdded(LocalPlayer.Character) end

LimbsTab:CreateSection("🤖 NPC Hitbox")
local npcHitboxSettings = { Enabled = false, HitboxSize = 5, Transparency = 0.9, SelectedPart = "HumanoidRootPart", TeamCheck = false, Collision = false }
local OldSizes = {}

LimbsTab:CreateToggle({ Name = "Enable NPC Hitbox", Default = false, Callback = function(v)
    npcHitboxSettings.Enabled = v
    if not v then
        for part, data in pairs(OldSizes) do
            if part and part.Parent then
                part.Size = data.Size
                part.Transparency = data.Transparency
                part.CanCollide = data.CanCollide
            end
        end
        OldSizes = {}
    end
end })
LimbsTab:CreateSlider({ Name = "NPC Hitbox Size", Min = 5, Max = 100, Default = 5, Callback = function(v) npcHitboxSettings.HitboxSize = v end })
LimbsTab:CreateSlider({ Name = "NPC Transparency", Min = 0, Max = 1, Default = 0.9, Callback = function(v) npcHitboxSettings.Transparency = v end })
LimbsTab:CreateToggle({ Name = "NPC Team Check", Default = false, Callback = function(v) npcHitboxSettings.TeamCheck = v end })
LimbsTab:CreateToggle({ Name = "NPC Collision", Default = false, Callback = function(v) npcHitboxSettings.Collision = v end })

task.spawn(function()
    while task.wait(0.5) do
        if npcHitboxSettings.Enabled then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local isPlayer = Players:GetPlayerFromCharacter(obj)
                    if hum and not isPlayer then
                        local isShop = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Shop")
                        local isEnemy = true
                        if npcHitboxSettings.TeamCheck then
                            if (obj:FindFirstChild("TeamColor") and obj.TeamColor == LocalPlayer.TeamColor) then isEnemy = false end
                        end
                        if not isShop and isEnemy then
                            local target = obj:FindFirstChild(npcHitboxSettings.SelectedPart) or obj:FindFirstChild("HumanoidRootPart")
                            if target and target:IsA("BasePart") then
                                if not OldSizes[target] then
                                    OldSizes[target] = { Size = target.Size, Transparency = target.Transparency, CanCollide = target.CanCollide }
                                end
                                target.Size = Vector3.new(npcHitboxSettings.HitboxSize, npcHitboxSettings.HitboxSize, npcHitboxSettings.HitboxSize)
                                target.Transparency = npcHitboxSettings.Transparency
                                target.CanCollide = npcHitboxSettings.Collision
                                target.Color = Color3.fromRGB(0,255,255)
                            end
                        end
                    end
                end
            end
            for part in pairs(OldSizes) do if not part or not part.Parent then OldSizes[part] = nil end end
        end
    end
end)

-- ======================== PEOPLE TAB ========================
PeopleTab:CreateSection("🎲 Random")

local function getChar2(p) return p and p.Character end
local function getHRP2(p) local c = getChar2(p) return c and c:FindFirstChild("HumanoidRootPart") end
local function teleportTo(p)
    local hrp1 = getHRP2(LocalPlayer)
    local hrp2 = getHRP2(p)
    if hrp1 and hrp2 then hrp1.CFrame = hrp2.CFrame * CFrame.new(2,0,2) end
end

local function getAllTargets()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(list,p) end end
    return list
end

local function getNearest()
    local best, dist = nil, math.huge
    local my = getHRP2(LocalPlayer)
    if not my then return end
    for _, p in ipairs(getAllTargets()) do
        local hrp = getHRP2(p)
        if hrp then
            local d = (my.Position - hrp.Position).Magnitude
            if d < dist then dist = d; best = p end
        end
    end
    return best
end

local function getFarthest()
    local best, dist = nil, 0
    local my = getHRP2(LocalPlayer)
    if not my then return end
    for _, p in ipairs(getAllTargets()) do
        local hrp = getHRP2(p)
        if hrp then
            local d = (my.Position - hrp.Position).Magnitude
            if d > dist then dist = d; best = p end
        end
    end
    return best
end

PeopleTab:CreateButton({ Name = "TP to Nearest Player", Callback = function() teleportTo(getNearest()) end })
PeopleTab:CreateButton({ Name = "TP to Farthest Player", Callback = function() teleportTo(getFarthest()) end })
PeopleTab:CreateButton({ Name = "TP to Random Player", Callback = function()
    local list = getAllTargets()
    if #list > 0 then teleportTo(list[math.random(1,#list)]) end
end })

PeopleTab:CreateSection("👥 Player List")
local currentTarget = nil
local loopTeleport = false

local playerDropdown = PeopleTab:CreateDropdown({
    Name = "Player List", Options = {}, Default = "",
    Callback = function(opt)
        if opt and opt ~= "" then
            local name = opt:match("%[@(.-)%]") or opt
            currentTarget = name
        end
    end
})

local function refreshPlayers()
    local opts = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(opts, p.DisplayName.." [@"..p.Name.."]") end
    end
    playerDropdown:Refresh(opts)
end

PeopleTab:CreateButton({ Name = "Refresh Player List", Callback = refreshPlayers })
refreshPlayers()

PeopleTab:CreateButton({ Name = "Teleport to Selected Player", Callback = function()
    local t = currentTarget and Players:FindFirstChild(currentTarget)
    if t then teleportTo(t) end
end })
PeopleTab:CreateToggle({ Name = "Teleport Loop", Default = false, Callback = function(v) loopTeleport = v end })

local following = false
local followSpeed = 20
local orbiting = false
local orbitRadius = 10
local orbitSpeed = 30
local orbitHeight = 0
local orbitAngle = 0
local aimingTarget = false
local aimStrength = 0.4

PeopleTab:CreateSection("🔄 Follow & Orbit")
PeopleTab:CreateToggle({ Name = "Follow Player", Default = false, Callback = function(v) following = v end })
PeopleTab:CreateSlider({ Name = "Follow Speed", Min = 5, Max = 1000, Default = 20, Callback = function(v) followSpeed = v end })
PeopleTab:CreateToggle({ Name = "Orbit Player", Default = false, Callback = function(v) orbiting = v end })
PeopleTab:CreateSlider({ Name = "Orbit Radius", Min = 1, Max = 1000, Default = 10, Callback = function(v) orbitRadius = v end })
PeopleTab:CreateSlider({ Name = "Orbit Speed", Min = 1, Max = 1000, Default = 30, Callback = function(v) orbitSpeed = v end })
PeopleTab:CreateSlider({ Name = "Orbit Height", Min = -200, Max = 200, Default = 0, Callback = function(v) orbitHeight = v end })
PeopleTab:CreateSection("🎯 Camera Aim")
PeopleTab:CreateToggle({ Name = "Aim Camera at Player", Default = false, Callback = function(v) aimingTarget = v end })
PeopleTab:CreateSlider({ Name = "Aim Strength", Min = 0.1, Max = 1, Default = 0.35, Callback = function(v) aimStrength = v end })

-- Spectate GUI
local spectateGui = Instance.new("ScreenGui", game.CoreGui)
spectateGui.Enabled = false
local frame = Instance.new("Frame", spectateGui)
frame.Size = UDim2.new(0,260,0,120)
frame.Position = UDim2.new(1,-270,0.3,0)
frame.BackgroundTransparency = 0.2
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

local avatar = Instance.new("ImageLabel", frame)
avatar.Size = UDim2.new(0,50,0,50)
avatar.Position = UDim2.new(0,10,0,10)
avatar.BackgroundTransparency = 1

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1,-70,1,-20)
info.Position = UDim2.new(0,70,0,10)
info.BackgroundTransparency = 1
info.TextScaled = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextColor3 = Color3.fromRGB(255,255,255)

local left = Instance.new("TextButton", frame)
left.Size = UDim2.new(0,25,0,25)
left.Position = UDim2.new(0,10,1,-30)
left.Text = "<"
left.BackgroundColor3 = Color3.fromRGB(50,50,50)
left.TextColor3 = Color3.fromRGB(255,255,255)

local right = Instance.new("TextButton", frame)
right.Size = UDim2.new(0,25,0,25)
right.Position = UDim2.new(0,40,1,-30)
right.Text = ">"
right.BackgroundColor3 = Color3.fromRGB(50,50,50)
right.TextColor3 = Color3.fromRGB(255,255,255)

local function getIndex()
    local list = getAllTargets()
    for i,v in ipairs(list) do if v.Name == currentTarget then return i, list end end
end

left.MouseButton1Click:Connect(function()
    local i, list = getIndex()
    if i and list[i-1] then currentTarget = list[i-1].Name end
end)
right.MouseButton1Click:Connect(function()
    local i, list = getIndex()
    if i and list[i+1] then currentTarget = list[i+1].Name end
end)

local watching = false
PeopleTab:CreateToggle({ Name = "Spectate Player", Default = false, Callback = function(v)
    watching = v
    spectateGui.Enabled = v
    if not v then Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
end })

-- Main loops for People tab
RunService.Heartbeat:Connect(function(dt)
    local t = currentTarget and Players:FindFirstChild(currentTarget)
    local hrp1 = getHRP2(LocalPlayer)
    local hrp2 = t and getHRP2(t)

    if loopTeleport and t then teleportTo(t) end
    if following and hrp1 and hrp2 then
        local pos = hrp2.Position + Vector3.new(0,0,3)
        hrp1.CFrame = hrp1.CFrame:Lerp(CFrame.new(pos), dt * (followSpeed/10))
    end
    if orbiting and hrp1 and hrp2 then
        local angularSpeed = orbitSpeed / math.max(orbitRadius, 0.1)
        orbitAngle = orbitAngle + angularSpeed * dt
        local offset = Vector3.new(math.cos(orbitAngle) * orbitRadius, orbitHeight, math.sin(orbitAngle) * orbitRadius)
        hrp1.CFrame = CFrame.new(hrp2.Position + offset, hrp2.Position)
    end
end)

RunService.RenderStepped:Connect(function()
    local t = currentTarget and Players:FindFirstChild(currentTarget)
    if aimingTarget and t then
        local hrp = getHRP2(t)
        if hrp then
            local predictedPos = hrp.Position + (hrp.Velocity * 0.1)
            local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, aimStrength)
        end
    end
    if watching and t then
        local hum = getChar2(t) and getChar2(t):FindFirstChildOfClass("Humanoid")
        local hrp = getHRP2(t)
        if hum and hrp then
            Camera.CameraSubject = hum
            local myHRP = getHRP2(LocalPlayer)
            local dist = myHRP and math.floor((myHRP.Position - hrp.Position).Magnitude) or 0
            local velocity = hrp.Velocity
            local realSpeed = math.floor(Vector3.new(velocity.X,0,velocity.Z).Magnitude)
            local jumpState = hum:GetState() == Enum.HumanoidStateType.Jumping and "Jumping" or "Ground"
            avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..t.UserId.."&width=150&height=150&format=png"
            info.Text = t.DisplayName.." [@"..t.Name.."]\nDist: "..dist.."\nSpeed: "..realSpeed.."\nState: "..jumpState
        end
    elseif spectateGui.Enabled then
        info.Text = ""
        avatar.Image = ""
    end
end)

-- ======================== MISC TAB ========================
MiscTab:CreateSection("⚡ Performance")
MiscTab:CreateButton({
    Name = "UniverHub FPS Booster",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Uranus197/-Univers-Hub-Graphics-Script-/refs/heads/main/UniversHub"))()
    end
})

local statsGui = nil
local fpsFrame = nil
local memFrame = nil

local function destroyStats()
    if statsGui then statsGui:Destroy(); statsGui = nil end
end

local function getPingColor(ping)
    if ping <= 50 then return Color3.fromRGB(0,255,0)
    elseif ping <= 100 then return Color3.fromRGB(255,255,0)
    elseif ping <= 200 then return Color3.fromRGB(255,165,0)
    else return Color3.fromRGB(255,0,0) end
end

local function getFPSColor(fps)
    if fps >= 60 then return Color3.fromRGB(0,255,0)
    elseif fps >= 30 then return Color3.fromRGB(255,255,0)
    else return Color3.fromRGB(255,0,0) end
end

local function getMemoryColor(mem)
    if mem <= 1000 then return Color3.fromRGB(0,255,0)
    elseif mem <= 2000 then return Color3.fromRGB(255,255,0)
    else return Color3.fromRGB(255,0,0) end
end

local function createStats()
    destroyStats()
    statsGui = Instance.new("ScreenGui")
    statsGui.Name = "NoirStats"
    statsGui.IgnoreGuiInset = true
    statsGui.ResetOnSpawn = false
    statsGui.Parent = game:GetService("CoreGui")

    fpsFrame = Instance.new("TextLabel")
    fpsFrame.Size = UDim2.new(0,180,0,28)
    fpsFrame.Position = UDim2.new(0,10,0,60)
    fpsFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    fpsFrame.BackgroundTransparency = 0.5
    fpsFrame.TextColor3 = Color3.fromRGB(255,255,255)
    fpsFrame.Font = Enum.Font.SourceSansBold
    fpsFrame.TextSize = 14
    fpsFrame.Text = ""
    fpsFrame.Visible = false
    fpsFrame.Parent = statsGui
    Instance.new("UICorner", fpsFrame).CornerRadius = UDim.new(0,6)

    memFrame = Instance.new("TextLabel")
    memFrame.Size = UDim2.new(0,180,0,28)
    memFrame.Position = UDim2.new(0,10,0,93)
    memFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    memFrame.BackgroundTransparency = 0.5
    memFrame.TextColor3 = Color3.fromRGB(255,255,255)
    memFrame.Font = Enum.Font.SourceSansBold
    memFrame.TextSize = 14
    memFrame.Text = ""
    memFrame.Visible = false
    memFrame.Parent = statsGui
    Instance.new("UICorner", memFrame).CornerRadius = UDim.new(0,6)

    local stats = game:GetService("Stats")
    RunService.RenderStepped:Connect(function(dt)
        if fpsFrame and fpsFrame.Visible then
            local pingStat = stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            local ping = pingStat and math.floor(pingStat:GetValue()) or 0
            local fps = math.floor(1 / dt)
            local pingColor = getPingColor(ping)
            local fpsColor = getFPSColor(fps)
            fpsFrame.Text = string.format("Ping: <font color='rgb(%d,%d,%d)'>%dms</font> | FPS: <font color='rgb(%d,%d,%d)'>%d</font>",
                pingColor.R*255, pingColor.G*255, pingColor.B*255, ping,
                fpsColor.R*255, fpsColor.G*255, fpsColor.B*255, fps)
            fpsFrame.RichText = true
        end
        if memFrame and memFrame.Visible then
            local mem = math.floor(stats:GetTotalMemoryUsageMb())
            local memColor = getMemoryColor(mem)
            memFrame.Text = string.format("Memory: <font color='rgb(%d,%d,%d)'>%d MB</font>",
                memColor.R*255, memColor.G*255, memColor.B*255, mem)
            memFrame.RichText = true
        end
    end)
end

local fpsToggle = false
local memToggle = false

MiscTab:CreateToggle({ Name = "Show FPS & Ping", Default = false, Callback = function(v)
    fpsToggle = v
    if not statsGui then createStats() end
    if fpsFrame then fpsFrame.Visible = v end
    if not fpsToggle and not memToggle then destroyStats() end
end })
MiscTab:CreateToggle({ Name = "Show Memory", Default = false, Callback = function(v)
    memToggle = v
    if not statsGui then createStats() end
    if memFrame then memFrame.Visible = v end
    if not fpsToggle and not memToggle then destroyStats() end
end })

task.wait(2)
NoirUI:Notify("NOIR HUB UNIVERSAL 🤑", "Đã tải thành công!")
