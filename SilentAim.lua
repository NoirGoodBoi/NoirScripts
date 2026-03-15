local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
pcall(function() gui.Parent = gethui() end)
if not gui.Parent then gui.Parent = LP.PlayerGui end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,165,0,75)
frame.Position = UDim2.new(0,40,0,180)
frame.BackgroundColor3 = Color3.fromRGB(25,25,28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-25,0,16)
title.Position = UDim2.new(0,6,0,0)
title.BackgroundTransparency = 1
title.Text = "Silent Aim"
title.TextColor3 = Color3.fromRGB(230,230,235)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,18,0,16)
minimize.Position = UDim2.new(1,-20,0,0)
minimize.Text = "-"
minimize.BackgroundTransparency = 1
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 14
minimize.TextColor3 = Color3.fromRGB(240,240,240)
minimize.Parent = frame

local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(1,-12,0,18)
dropdown.Position = UDim2.new(0,6,0,18)
dropdown.BackgroundColor3 = Color3.fromRGB(40,40,45)
dropdown.Text = "Mode : Character"
dropdown.TextColor3 = Color3.fromRGB(240,240,240)
dropdown.Font = Enum.Font.Gotham
dropdown.TextSize = 11
dropdown.Parent = frame
Instance.new("UICorner",dropdown)

local list = Instance.new("Frame")
list.Size = UDim2.new(1,-12,0,54)
list.Position = UDim2.new(0,6,0,-54)
list.BackgroundColor3 = Color3.fromRGB(35,35,40)
list.Visible = false
list.ZIndex = 5
list.Parent = frame
Instance.new("UICorner",list)

local function option(text,y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,18)
	b.Position = UDim2.new(0,0,0,y)
	b.BackgroundTransparency = 1
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240,240,240)
	b.Font = Enum.Font.Gotham
	b.TextSize = 11
	b.ZIndex = 6
	b.Parent = list
	return b
end

local charBtn = option("Character",0)
local camBtn = option("Camera",18)
local bothBtn = option("Character + Camera",36)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1,-9,0,30)
toggle.Position = UDim2.new(0,4,1,-35)
toggle.Text = "Off"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12
toggle.BackgroundColor3 = Color3.fromRGB(80,80,85)
toggle.TextColor3 = Color3.fromRGB(240,240,240)
toggle.Parent = frame
Instance.new("UICorner",toggle)

local highlight = Instance.new("Highlight")
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.fromRGB(60,255,120)
highlight.Parent = gui

local enabled = false
local target = nil
local aimMode = "Character"
local minimized = false

local function aliveChar(plr)
	local c = plr.Character
	if not c then return end
	local hum = c:FindFirstChildOfClass("Humanoid")
	local hrp = c:FindFirstChild("HumanoidRootPart")
	if hum and hrp and hum.Health > 0 then
		return c,hum,hrp
	end
end

local function getTarget()
	local center = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
	local closest = nil
	local shortest = 120

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= LP then
			local c,hum,hrp = aliveChar(p)
			if c then
				local pos,visible = Camera:WorldToViewportPoint(hrp.Position)
				if visible then
					local dist = (Vector2.new(pos.X,pos.Y)-center).Magnitude
					if dist < shortest then
						shortest = dist
						closest = p
					end
				end
			end
		end
	end

	return closest
end

dropdown.MouseButton1Click:Connect(function()
	list.Visible = not list.Visible
end)

charBtn.MouseButton1Click:Connect(function()
	aimMode = "Character"
	dropdown.Text = "Mode : Character"
	list.Visible = false
end)

camBtn.MouseButton1Click:Connect(function()
	aimMode = "Camera"
	dropdown.Text = "Mode : Camera"
	list.Visible = false
end)

bothBtn.MouseButton1Click:Connect(function()
	aimMode = "Both"
	dropdown.Text = "Mode : Character + Camera"
	list.Visible = false
end)

minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		frame.Size = UDim2.new(0,165,0,16)
		dropdown.Visible = false
		list.Visible = false
		toggle.Visible = false
	else
		frame.Size = UDim2.new(0,165,0,75)
		dropdown.Visible = true
		toggle.Visible = true
	end
end)

toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		target = getTarget()
		if target then
			toggle.Text = "On"
			toggle.BackgroundColor3 = Color3.fromRGB(60,170,90)
		else
			enabled = false
		end
	else
		toggle.Text = "Off"
		toggle.BackgroundColor3 = Color3.fromRGB(80,80,85)
		target = nil
		highlight.Adornee = nil
	end
end)

RunService.RenderStepped:Connect(function()

	if not enabled then return end
	if not target then return end

	local tc,th,thrp = aliveChar(target)
	local myc,myh,myhrp = aliveChar(LP)

	if not tc then
		target = nil
		enabled = false
		toggle.Text = "Off"
		highlight.Adornee = nil
		return
	end

	highlight.Adornee = target.Character

	local myPos = myhrp.Position
	local targetPos = thrp.Position

	if aimMode == "Character" then

		myh.AutoRotate = false
		myhrp.CFrame = CFrame.new(
			myPos,
			Vector3.new(targetPos.X,myPos.Y,targetPos.Z)
		)

	elseif aimMode == "Camera" then

		Camera.CFrame = CFrame.new(
			Camera.CFrame.Position,
			targetPos
		)

	elseif aimMode == "Both" then

		myh.AutoRotate = false
		myhrp.CFrame = CFrame.new(
			myPos,
			Vector3.new(targetPos.X,myPos.Y,targetPos.Z)
		)

		local camPos = Camera.CFrame.Position
		local offset =
			myhrp.CFrame.RightVector * 3 +
			Vector3.new(0,2,0)

		local newPos = camPos + offset

		Camera.CFrame = CFrame.new(
			newPos,
			targetPos
		)

	end

end)
