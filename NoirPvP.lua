local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local gui = Instance.new("ScreenGui", game.CoreGui)
guicore = gui
gui.Name = "PvPMobileGUI"

-- Toggle Icon
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 200)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 20
toggleButton.Text = "⚙️"
toggleButton.Active = true
toggleButton.Draggable = true

local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0, 60, 0, 200)
frame.Size = UDim2.new(0, 160, 0, 160)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Visible = false
frame.Draggable = true

local uilist = Instance.new("UIListLayout", frame)
uilist.Padding = UDim.new(0, 5)
uilist.FillDirection = Enum.FillDirection.Vertical
uilist.SortOrder = Enum.SortOrder.LayoutOrder

toggleButton.MouseButton1Click:Connect(function()
frame.Visible = not frame.Visible
end)

function createButton(text, callback)
local b = Instance.new("TextButton", frame)
b.Size = UDim2.new(1, -10, 0, 30)
b.Position = UDim2.new(0, 5, 0, 0)
b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
b.TextColor3 = Color3.new(1,1,1)
b.Text = text
b.Font = Enum.Font.GothamBold
b.TextSize = 14
b.MouseButton1Click:Connect(function()
callback(b)
end)
end

-- ESP
local function addESP(player)
RS.RenderStepped:Connect(function()
if player.Character and player.Character:FindFirstChild("Head") and LP.Character and LP.Character:FindFirstChild("Head") then
local tag = player.Character.Head:FindFirstChild("ESP")
if not tag then
local gui = Instance.new("BillboardGui", player.Character.Head)
gui.Name = "ESP"
gui.Size = UDim2.new(0, 60, 0, 20)
gui.StudsOffset = Vector3.new(0, 2, 0)
gui.AlwaysOnTop = true
local txt = Instance.new("TextLabel", gui)
txt.Size = UDim2.new(1, 0, 1, 0)
txt.BackgroundTransparency = 1
txt.TextColor3 = Color3.new(1, 1, 1)
txt.Font = Enum.Font.SourceSansBold
txt.TextScaled = true
end
local label = player.Character.Head:FindFirstChild("ESP"):FindFirstChildOfClass("TextLabel")
if label then
local dist = math.floor((player.Character.Head.Position - LP.Character.Head.Position).Magnitude)
label.Text = player.Name .. " [" .. dist .. "]"
end
end
end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then addESP(p) end end
Players.PlayerAdded:Connect(function(p)
if p ~= LP then
p.CharacterAdded:Connect(function() wait(1) addESP(p) end)
end
end)

-- TP Behind
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

-- Path Feature
local pathEnabled = false
local pathButton
createButton("Path Mode [OFF]", function(btn)
pathEnabled = not pathEnabled
btn.Text = pathEnabled and "Path Mode [ON]" or "Path Mode [OFF]"
if pathEnabled then
if not pathButton then
pathButton = Instance.new("TextButton", gui)
pathButton.Size = UDim2.new(0, 50, 0, 30)
pathButton.Position = UDim2.new(0, 200, 0, 200)
pathButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
pathButton.Text = "+"
pathButton.TextColor3 = Color3.new(1, 1, 1)
pathButton.Font = Enum.Font.GothamBold
pathButton.TextSize = 16
pathButton.Active = true
pathButton.Draggable = true
pathButton.MouseButton1Click:Connect(function()
if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
local p = Instance.new("Part")
p.Size = Vector3.new(5, 1, 5)
p.Position = LP.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
p.Anchored = true
p.CanCollide = true
p.Transparency = 0.2
p.BrickColor = BrickColor.Random()
p.Parent = workspace
local noTouch = Instance.new("LocalScript", p)
noTouch.Source = "script.Parent.CanCollide = true"
end
end)
end
pathButton.Visible = true
else
if pathButton then pathButton.Visible = false end
end
end)

-- Inf Jump
local infJump = false
createButton("Inf Jump [OFF]", function(btn)
infJump = not infJump
btn.Text = infJump and "Inf Jump [ON]" or "Inf Jump [OFF]"
end)

UIS.JumpRequest:Connect(function()
if infJump and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
end
end)

-- Quick TP (GUI phụ có on/off)
local savedPos = nil
local tpGui = Instance.new("Frame", gui)
tpGui.Size = UDim2.new(0, 120, 0, 80)
tpGui.Position = UDim2.new(0, 220, 0, 260)
tpGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpGui.Active = true
tpGui.Draggable = true
tpGui.Visible = false

local tpLayout = Instance.new("UIListLayout", tpGui)
tpLayout.Padding = UDim.new(0, 5)
tpLayout.FillDirection = Enum.FillDirection.Vertical
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function tpSubBtn(txt, func)
local b = Instance.new("TextButton", tpGui)
b.Size = UDim2.new(1, -10, 0, 30)
b.Text = txt
b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
b.TextColor3 = Color3.new(1,1,1)
b.Font = Enum.Font.GothamBold
b.TextSize = 14
b.MouseButton1Click:Connect(func)
end

tpSubBtn("📍 Đặt điểm", function()
if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
savedPos = LP.Character.HumanoidRootPart.Position
end
end)

tpSubBtn("🚀 Quay về", function()
if savedPos and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
LP.Character.HumanoidRootPart.CFrame = CFrame.new(savedPos)
end
end)

createButton("Quick TP [OFF]", function(btn)
tpGui.Visible = not tpGui.Visible
btn.Text = tpGui.Visible and "Quick TP [ON]" or "Quick TP [OFF]"
end)

