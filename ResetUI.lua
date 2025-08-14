local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "ResetUi by Noir"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
pcall(function() gui.Parent = gethui() end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,55)
frame.Position = UDim2.new(0,50,0,200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,28)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,16)
corner.Parent = frame

local dragging = false
local dragStart, startPos
frame.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		dragging=true
		dragStart=i.Position
		startPos=frame.Position
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		dragging=false
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local delta=i.Position-dragStart
		frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
	end
end)

local function createButton(text,color,pos,callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,160,0,36)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.Parent = frame
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0,8)
	bc.Parent = btn
	btn.MouseButton1Click:Connect(callback)
	return btn
end

createButton("Reset",Color3.fromRGB(200,60,60),UDim2.new(0,20,0,10),function()
	local char = LP.Character
	if char then
		char:BreakJoints()
	end
end) 
