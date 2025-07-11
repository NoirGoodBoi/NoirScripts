local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "NoirMiniGui"

local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 40, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 200)
toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 20
toggle.Text = "⚙️"
toggle.Active = true
toggle.Draggable = true

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 200)
frame.Position = UDim2.new(0, 60, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
frame.Active = true
frame.Draggable = true

local list = Instance.new("UIListLayout", frame)
list.Padding = UDim.new(0, 5)
list.SortOrder = Enum.SortOrder.LayoutOrder

local function createToggle(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	local toggled = false
	btn.Text = "[OFF] " .. text
	btn.MouseButton1Click:Connect(function()
		toggled = not toggled
		btn.Text = (toggled and "[ON] " or "[OFF] ") .. text
		callback(toggled)
	end)
end

local noclipConn
createToggle("NoClip + AntiVoid", function(on)
	if on then
		noclipConn = RS.Stepped:Connect(function()
			for _, v in pairs(Char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
					if v.Position.Y < -50 then Char:MoveTo(Vector3.new(0, 10, 0)) end
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() end
		for _, v in pairs(Char:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = true end
		end
	end
end)

local infJump = false
createToggle("Infinite Jump", function(on)
	infJump = on
end)

UIS.JumpRequest:Connect(function()
	if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
		LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)

local flyLoaded = false
local flyBtn = Instance.new("TextButton", frame)
flyBtn.Size = UDim2.new(1, -10, 0, 30)
flyBtn.Position = UDim2.new(0, 5, 0, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Font = Enum.Font.GothamBold
flyBtn.TextSize = 14
flyBtn.Text = "Bay"
flyBtn.MouseButton1Click:Connect(function()
	if not flyLoaded then
		flyLoaded = true
		pcall(function()
			loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Vehicle%20Fly%20Gui'))()
		end)
	end
end)

local savedPos = nil
local tpGui = Instance.new("Frame", gui)
tpGui.Size = UDim2.new(0, 120, 0, 80)
tpGui.Position = UDim2.new(0, 280, 0, 200)
tpGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpGui.Visible = false
tpGui.Active = true
tpGui.Draggable = true

local tpLayout = Instance.new("UIListLayout", tpGui)
tpLayout.Padding = UDim.new(0, 5)
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function tpBtn(txt, func)
	local b = Instance.new("TextButton", tpGui)
	b.Size = UDim2.new(1, -10, 0, 30)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.MouseButton1Click:Connect(func)
end

tpBtn("📍 Đặt điểm", function()
	if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		savedPos = LP.Character.HumanoidRootPart.Position
	end
end)

tpBtn("🚀 Quay về", function()
	if savedPos and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		LP.Character.HumanoidRootPart.CFrame = CFrame.new(savedPos)
	end
end)

createToggle("Quick TP", function(on)
	tpGui.Visible = on
end)

toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- ✅ PATH FEATURE
local pathToggle = false
local pathBtn

createToggle("Path", function(on)
	pathToggle = on
	if pathToggle then
		if not pathBtn then
			pathBtn = Instance.new("TextButton", gui)
			pathBtn.Size = UDim2.new(0, 50, 0, 30)
			pathBtn.Position = UDim2.new(0, 220, 0, 200)
			pathBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			pathBtn.Text = "+"
			pathBtn.TextColor3 = Color3.new(1, 1, 1)
			pathBtn.Font = Enum.Font.GothamBold
			pathBtn.TextSize = 16
			pathBtn.Active = true
			pathBtn.Draggable = true

			pathBtn.MouseButton1Click:Connect(function()
				if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
					local p = Instance.new("Part")
					p.Size = Vector3.new(5, 1, 5)
					p.Position = LP.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
					p.Anchored = true
					p.CanCollide = true
					p.Transparency = 0.2
					p.BrickColor = BrickColor.Random()
					p.Parent = workspace
					game.Debris:AddItem(p, 10)
				end
			end)
		end
		pathBtn.Visible = true
	else
		if pathBtn then pathBtn.Visible = false end
	end
end)
