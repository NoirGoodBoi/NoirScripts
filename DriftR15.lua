local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local iceMode = false
local slidePower = 4 -- độ trượt (cao = trượt nhiều)
local friction = 0.97 -- hệ số ma sát (thấp = trượt lâu hơn)

-- Tạo nút Ice Mode
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local iceBtn = Instance.new("TextButton", screenGui)
iceBtn.Size = UDim2.new(0, 100, 0, 50)
iceBtn.Position = UDim2.new(1, -110, 1, -120)
iceBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
iceBtn.Text = "ICE: OFF"
iceBtn.TextScaled = true
iceBtn.Font = Enum.Font.SourceSansBold

local corner = Instance.new("UICorner", iceBtn)
corner.CornerRadius = UDim.new(0.3, 0)

-- Toggle Ice Mode
iceBtn.MouseButton1Click:Connect(function()
	iceMode = not iceMode
	if iceMode then
		iceBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		iceBtn.Text = "ICE: ON"
	else
		iceBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		iceBtn.Text = "ICE: OFF"
	end
end)

-- Xử lý trượt
local storedVelocity = Vector3.zero
RunService.RenderStepped:Connect(function()
	if not hrp or not hum then return end

	if iceMode then
		if hum.MoveDirection.Magnitude > 0 then
			storedVelocity = storedVelocity + hum.MoveDirection * slidePower
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
