local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

-- Hàm thêm bo góc
local function roundify(obj, rad)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, rad or 8)
	corner.Parent = obj
end

-- GUI chính
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "NoirMiniGui"

-- Nút mở menu
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 45, 0, 45)
toggle.Position = UDim2.new(0, 10, 0, 200)
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- xám
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 27
toggle.Text = "🇻🇳"
toggle.Active = true
toggle.Draggable = true
roundify(toggle)

-- Khung menu
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 170, 0, 110)
frame.Position = UDim2.new(0, 60, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- đen
frame.Visible = false
frame.Active = true
frame.Draggable = true
roundify(frame)

local list = Instance.new("UIListLayout", frame)
list.Padding = UDim.new(0, 5)
list.SortOrder = Enum.SortOrder.LayoutOrder

-- Hàm tạo toggle (giảm chiều dài)
local function createToggle(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.9, 0, 0, 30) -- chỉ chiếm 90% chiều ngang
	btn.Position = UDim2.new(0.05, 0, 0, 0) -- căn giữa
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- mặc định xám
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	local toggled = false
	btn.Text = "[OFF] " .. text
	roundify(btn)

	btn.MouseButton1Click:Connect(function()
		toggled = not toggled
		if toggled then
			btn.Text = "[ON] " .. text
			btn.BackgroundColor3 = Color3.fromRGB(0, 160, 0) -- xanh lá
		else
			btn.Text = "[OFF] " .. text
			btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- xám
		end
		callback(toggled)
	end)
end

-- Hàm tạo button thường
local function createButton(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.9, 0, 0, 30)
	btn.Position = UDim2.new(0.05, 0, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = text
	roundify(btn)
	btn.MouseButton1Click:Connect(callback)
end

-- ✅ Path feature
local pathToggle = false
local pathBtn
createToggle("Path", function(on)
	pathToggle = on
	if pathToggle then
		if not pathBtn then
			pathBtn = Instance.new("TextButton", gui)
			pathBtn.Size = UDim2.new(0, 60, 0, 40)
			pathBtn.Position = UDim2.new(0, 220, 0, 200)
			pathBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- xám
			pathBtn.Text = "+"
			pathBtn.TextColor3 = Color3.new(1, 1, 1)
			pathBtn.Font = Enum.Font.GothamBold
			pathBtn.TextSize = 25
			pathBtn.Active = true
			pathBtn.Draggable = true
			roundify(pathBtn)

			pathBtn.MouseButton1Click:Connect(function()
				if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
					local p = Instance.new("Part")
					p.Size = Vector3.new(5, 1, 5)
					p.Position = LP.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
					p.Anchored = true
					p.CanCollide = true
					p.Transparency = 0.5
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

-- ✅ TP Behind
createButton("TP Behind", function()
	local closest, dist = nil, math.huge
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local d = (LP.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
			if d < dist then
				closest = plr
				dist = d
			end
		end
	end
	if closest then
		LP.Character.HumanoidRootPart.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
	end
end)

-- ✅ Quick TP Multi-Slot
local savedSlots = {nil, nil, nil, nil} -- 3 slot lưu tọa độ
local currentSlot = 1 -- mặc định slot 1

local tpGui = Instance.new("Frame", gui)
tpGui.Size = UDim2.new(0, 150, 0, 95)
tpGui.Position = UDim2.new(0, 280, 0, 200)
tpGui.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
tpGui.Visible = false
tpGui.Active = true
tpGui.Draggable = true
roundify(tpGui)

local tpLayout = Instance.new("UIListLayout", tpGui)
tpLayout.Padding = UDim.new(0, 5)
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Hàm tạo nút
local function tpBtn(txt, func)
	local b = Instance.new("TextButton", tpGui)
	b.Size = UDim2.new(0.9, 0, 0, 25)
	b.Position = UDim2.new(0.05, 0, 0, 0)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	roundify(b)
	b.MouseButton1Click:Connect(func)
	return b
end

-- Nút đặt điểm
tpBtn("📍 Đặt điểm", function()
	if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		savedSlots[currentSlot] = LP.Character.HumanoidRootPart.Position
	end
end)

-- Nút quay về
tpBtn("🚀 Quay về", function()
	if savedSlots[currentSlot] and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		LP.Character.HumanoidRootPart.CFrame = CFrame.new(savedSlots[currentSlot])
	end
end)

-- Khung chọn slot
local slotFrame = Instance.new("Frame", tpGui)
slotFrame.Size = UDim2.new(1, -10, 0, 25)
slotFrame.BackgroundTransparency = 1
slotFrame.LayoutOrder = 99

local slotLayout = Instance.new("UIListLayout", slotFrame)
slotLayout.FillDirection = Enum.FillDirection.Horizontal
slotLayout.Padding = UDim.new(0, 5)
slotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Tạo 3 nút số
for i = 1, 4 do
	local btn = Instance.new("TextButton", slotFrame)
	btn.Size = UDim2.new(0, 30, 1, 0)
	btn.Text = tostring(i)
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	roundify(btn)

	btn.MouseButton1Click:Connect(function()
		currentSlot = i
		-- highlight nút đang chọn
		for _, other in ipairs(slotFrame:GetChildren()) do
			if other:IsA("TextButton") then
				other.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
	end)
end

-- Toggle bật tắt GUI
createToggle("Quick TP", function(on)
	tpGui.Visible = on
end)

-- Toggle menu
toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)
