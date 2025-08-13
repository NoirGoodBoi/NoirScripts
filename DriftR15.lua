local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local iceMode = false
local slidePower = 1.5 -- Độ trượt khi di chuyển
local friction = 0.94 -- Ma sát, càng thấp trượt càng lâu
local maxSpeed = 20 -- Giới hạn tốc độ trượt

-- UI Toggle
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local iceBtn = Instance.new("TextButton", screenGui)
iceBtn.Size = UDim2.new(0, 100, 0, 50)
iceBtn.Position = UDim2.new(1, -110, 1, -120)
iceBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
iceBtn.Text = "ICE: OFF"
iceBtn.TextScaled = true
iceBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", iceBtn).CornerRadius = UDim.new(0.3, 0)

-- Cho kéo nút
local dragging = false
local dragStart, startPos
iceBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = iceBtn.Position
	end
end)
iceBtn.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStart
		iceBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Toggle Ice Mode
iceBtn.MouseButton1Click:Connect(function()
	if not dragging then
		iceMode = not iceMode
		if iceMode then
			iceBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			iceBtn.Text = "ICE: ON"
		else
			iceBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			iceBtn.Text = "ICE: OFF"
		end
	end
end)

-- Xử lý trượt
local storedVelocity = Vector3.zero
RunService.RenderStepped:Connect(function()
	if not hrp or not hum then return end

	if iceMode then
		if hum.MoveDirection.Magnitude > 0 then
			storedVelocity = storedVelocity + hum.MoveDirection * slidePower
			if storedVelocity.Magnitude > maxSpeed then
				storedVelocity = storedVelocity.Unit * maxSpeed
			end
		else
			storedVelocity = storedVelocity * friction
		end
		hrp.Velocity = Vector3.new(storedVelocity.X, hrp.Velocity.Y, storedVelocity.Z)
	else
		storedVelocity = Vector3.zero
	end
end)

-- Reset khi respawn
player.CharacterAdded:Connect(function(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	hrp = c:WaitForChild("HumanoidRootPart")
	storedVelocity = Vector3.zero
end)
