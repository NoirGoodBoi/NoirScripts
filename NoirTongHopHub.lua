local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "Noir Hub",
   LoadingTitle = "Loading NoirHub...",
   LoadingSubtitle = "Script By Noir",
   ConfigurationSaving = {
      Enabled = false,
   }
})

local Tab = Window:CreateTab("Player", Color3.fromRGB(44, 120, 224))

local PlayerTab = Window:CreateTab("Player", 4483362458)

--🌟 1. Slider Speed
local walkspeed = 16
PlayerTab:CreateSlider({
   Name = "Speed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v)
      walkspeed = v
   end
})

--🌟 2. Toggle Speed
PlayerTab:CreateToggle({
   Name = "Tăng tốc độ",
   CurrentValue = false,
   Callback = function(state)
      local plr = game.Players.LocalPlayer
      while state do
         task.wait()
         if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.WalkSpeed = walkspeed
         end
      end
      if plr.Character and plr.Character:FindFirstChild("Humanoid") then
         plr.Character.Humanoid.WalkSpeed = 16
      end
   end
})

--🌟 3. Slider JumpPower
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

--🌟 4. Toggle Power Jump
PlayerTab:CreateToggle({
   Name = "Tăng power jump",
   CurrentValue = false,
   Callback = function(state)
      local plr = game.Players.LocalPlayer
      while state do
         task.wait()
         if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.JumpPower = jumppower
         end
      end
      if plr.Character and plr.Character:FindFirstChild("Humanoid") then
         plr.Character.Humanoid.JumpPower = 50
      end
   end
})

--🌟 5. Infinity Jump
PlayerTab:CreateToggle({
   Name = "Infinity Jump",
   CurrentValue = false,
   Callback = function(state)
      if state then
         game:GetService("UserInputService").JumpRequest:Connect(function()
            if game.Players.LocalPlayer.Character then
               game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
         end)
      end
   end
})

tabPlayer:CreateToggle({
	Name = "NoClip + AntiVoid",
	CurrentValue = false,
	Flag = "NoClipAntiVoid",
	Callback = function(on)
		if on then
			noclipConn = game:GetService("RunService").Stepped:Connect(function()
				for _, part in ipairs(Char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
						if part.Position.Y < -50 then
							local hrp = Char:FindFirstChild("HumanoidRootPart")
							if hrp then
								hrp.CFrame = CFrame.new(0, 10, 0)
							end
						end
					end
				end
			end)
		else
			if noclipConn then
				noclipConn:Disconnect()
				noclipConn = nil
			end
			for _, part in ipairs(Char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
})

Tab:CreateButton({
    Name = "Ghost Fly GUI",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Vehicle%20Fly%20Gui'))()
    end,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espConnections = {}
local espInstances = {}

local function removeAllESP()
	for _, gui in pairs(espInstances) do
		if gui and gui.Parent then
			gui:Destroy()
		end
	end
	for _, conn in pairs(espConnections) do
		if conn then
			conn:Disconnect()
		end
	end
	table.clear(espInstances)
	table.clear(espConnections)
end

local function createESP(player)
	if player == LocalPlayer then return end
	if not player.Character or not player.Character:FindFirstChild("Head") then return end

	local head = player.Character:FindFirstChild("Head")
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not head or not hrp then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Noir_ESP"
	billboard.Size = UDim2.new(0, 200, 0, 30)
	billboard.AlwaysOnTop = true
	billboard.Adornee = head
	billboard.StudsOffset = Vector3.new(0, 2, 0)

	local textLabel = Instance.new("TextLabel", billboard)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = player.TeamColor.Color
	textLabel.Text = player.Name .. " [0]"
	textLabel.Parent = billboard

	billboard.Parent = head
	table.insert(espInstances, billboard)

	local conn = RunService.RenderStepped:Connect(function()
		if not player.Character or not hrp or not hrp:IsDescendantOf(workspace) then
			billboard:Destroy()
			return
		end
		local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
		textLabel.Text = player.Name .. " [" .. dist .. "]"
	end)

	table.insert(espConnections, conn)
end

-- Rayfield Toggle
tabPlayer:CreateToggle({
	Name = "ESP (Username [Distance])",
	CurrentValue = false,
	Flag = "ESP_Toggle",
	Callback = function(state)
		if state then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer then
					if plr.Character and plr.Character:FindFirstChild("Head") then
						createESP(plr)
					end
					plr.CharacterAdded:Connect(function()
						repeat task.wait() until plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart")
						createESP(plr)
					end)
				end
			end
			Players.PlayerAdded:Connect(function(plr)
				plr.CharacterAdded:Connect(function()
					repeat task.wait() until plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart")
					createESP(plr)
				end)
			end)
		else
			removeAllESP()
		end
	end
})

-- Toggle Rayfield gắn trong tab bất kỳ
Tab:CreateToggle({
	Name = "Hiện nút tạo path",
	CurrentValue = false,
	Callback = function(state)
		local pathGui = game.CoreGui:FindFirstChild("PathMiniByNoir")
		if pathGui then
			pathGui.Enabled = state
		end
	end
})

-- GUI nhỏ chứa nút Path (gắn dưới cùng script Rayfield)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PathMiniByNoir"
gui.Enabled = false
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 90, 0, 32)
btn.Position = UDim2.new(0.5, -45, 0.75, 0)
btn.Text = "Path"
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.BorderSizePixel = 0
btn.BackgroundTransparency = 0.05
btn.AutoButtonColor = true
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Parent = gui
btn.Active = true
btn.Draggable = true

local uicorner = Instance.new("UICorner", btn)
uicorner.CornerRadius = UDim.new(0, 8)

local function randomColor()
	return Color3.fromHSV(math.random(), 1, 1)
end

btn.MouseButton1Click:Connect(function()
	local plr = game.Players.LocalPlayer
	local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local path = Instance.new("Part")
	path.Anchored = true
	path.Size = Vector3.new(5, 0.2, 5)
	path.CFrame = hrp.CFrame - Vector3.new(0, 3, 0)
	path.Color = randomColor()
	path.Material = Enum.Material.Neon
	path.CanCollide = true
	path.Parent = workspace

	game.Debris:AddItem(path, 10)
end)

local Point = nil

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "QuickTP"
gui.ResetOnSpawn = false
gui.Enabled = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 140, 0, 80)
frame.Position = UDim2.new(0.5, -70, 0.6, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 0.2
frame.ClipsDescendants = true
frame.AutomaticSize = Enum.AutomaticSize.None
frame.Visible = true
frame.Name = "QuickTPFrame"
frame:SetAttribute("OpenedByRayfield", true)
frame:FindFirstChildWhichIsA("UICorner") or Instance.new("UICorner", frame)

local uiLayout = Instance.new("UIListLayout", frame)
uiLayout.Padding = UDim.new(0, 5)
uiLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function makeButton(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 120, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.Text = text
	btn.TextSize = 14
	btn.AutoButtonColor = true
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

makeButton("📍 Đặt điểm", function()
	local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		Point = hrp.Position
	end
end)

makeButton("🚀 Quay về", function()
	if Point then
		local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(Point)
		end
	end
end)

-- Toggle phù hợp Rayfield (chỉ bật/tắt gui)
_G.QuickTP_Toggle = function(state)
	gui.Enabled = state
end

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local function getNearestPlayer()
	local nearest, minDist = nil, math.huge
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
			if dist < minDist then
				minDist = dist
				nearest = plr
			end
		end
	end
	return nearest
end

local tpBtn
local dragging, dragInput, dragStart, startPos

function createTPBehindButton()
	if tpBtn then return end

	tpBtn = Instance.new("TextButton")
	tpBtn.Size = UDim2.new(0, 120, 0, 40)
	tpBtn.Position = UDim2.new(0.5, -60, 0.85, 0)
	tpBtn.Text = "TP Behind"
	tpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tpBtn.BorderSizePixel = 0
	tpBtn.BackgroundTransparency = 0.1
	tpBtn.TextScaled = true
	tpBtn.AutoButtonColor = true
	tpBtn.Font = Enum.Font.GothamBold
	tpBtn.Name = "TPBehindBtn"
	tpBtn.Active = true
	tpBtn.Draggable = false
	tpBtn.ClipsDescendants = true
	tpBtn.Parent = game.CoreGui

	local corner = Instance.new("UICorner", tpBtn)
	corner.CornerRadius = UDim.new(0, 10)

	tpBtn.MouseButton1Click:Connect(function()
		local target = getNearestPlayer()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local root = target.Character.HumanoidRootPart
			local backPos = root.CFrame * CFrame.new(0, 0, 3)
			char:MoveTo(backPos.Position)
		end
	end)

	-- Make draggable
	tpBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = tpBtn.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	tpBtn.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			tpBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function destroyTPBehindButton()
	if tpBtn then
		tpBtn:Destroy()
		tpBtn = nil
	end
end

-- ⚙️ Toggle Rayfield dạng gọi trực tiếp:
createToggle("TP Behind", function(state)
	if state then
		createTPBehindButton()
	else
		destroyTPBehindButton()
	end
end)

task.spawn(function()
	while true do
		game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
		task.wait(300) -- 5 phút
	end
end)

game:GetService("Players").LocalPlayer.Idled:Connect(function()
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

