local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local LP=Players.LocalPlayer
local Camera=workspace.CurrentCamera

local gui=Instance.new("ScreenGui")
gui.Name="NoirSilentAimUI"
gui.IgnoreGuiInset=true
gui.ResetOnSpawn=false
pcall(function() gui.Parent=gethui() end)
if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end

local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,220,0,68)
frame.Position=UDim2.new(0,40,0,180)
frame.BackgroundColor3=Color3.fromRGB(25,25,28)
frame.BorderSizePixel=0
frame.Active=true
frame.Parent=gui

local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,16)
corner.Parent=frame

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-20,0,28)
title.Position=UDim2.new(0,12,0,6)
title.BackgroundTransparency=1
title.Text="Silent Aim by Noir"
title.TextColor3=Color3.fromRGB(230,230,235)
title.TextSize=18
title.Font=Enum.Font.GothamMedium
title.Parent=frame

local toggle=Instance.new("TextButton")
toggle.Size=UDim2.new(0,120,0,28) 
toggle.Position=UDim2.new(1,-132,1,-36)
toggle.BackgroundColor3=Color3.fromRGB(80,80,85)
toggle.BorderSizePixel=0
toggle.Text="Off"
toggle.TextColor3=Color3.fromRGB(240,240,240)
toggle.TextSize=16
toggle.Font=Enum.Font.GothamBold
toggle.Parent=frame

local toggleCorner=Instance.new("UICorner")
toggleCorner.CornerRadius=UDim.new(0,10)
toggleCorner.Parent=toggle

local dragging=false
local dragStart
local startPos
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
		local d=i.Position-dragStart
		frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
	end
end)

local highlight=Instance.new("Highlight")
highlight.FillTransparency=1
highlight.OutlineColor=Color3.fromRGB(60,255,120)
highlight.OutlineTransparency=0
pcall(function() highlight.Parent=gethui() end)
if not highlight.Parent then highlight.Parent=gui end

local enabled=false
local target=nil
local diedConn=nil

local function aliveChar(plr)
	local c=plr.Character
	if not c then return end
	local hum=c:FindFirstChildWhichIsA("Humanoid")
	local hrp=c:FindFirstChild("HumanoidRootPart")
	if hum and hrp and hum.Health>0 then return c,hum,hrp end
end

local function getNearest()
	local myChar,myHum,myHRP=aliveChar(LP)
	if not myChar then return end
	local best,bd= nil,1e9
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local c,hum,hrp=aliveChar(p)
			if c then
				local d=(hrp.Position-myHRP.Position).Magnitude
				if d<bd then
					bd=d
					best=p
				end
			end
		end
	end
	return best
end

local function trackTarget(plr)
	if diedConn then diedConn:Disconnect() diedConn=nil end
	target=plr
	if not target then highlight.Adornee=nil return end
	local c,hum=aliveChar(target)
	if not c then target=nil highlight.Adornee=nil return end
	highlight.Adornee=c
	diedConn=hum.Died:Connect(function()
		target=nil
		highlight.Adornee=nil
	end)
end

local function setToggle(state)
	enabled=state
	if enabled then
		toggle.BackgroundColor3=Color3.fromRGB(60,170,90)
		toggle.Text="On"
	else
		toggle.BackgroundColor3=Color3.fromRGB(80,80,85)
		toggle.Text="Off"
		trackTarget(nil)
	end
end

toggle.MouseButton1Click:Connect(function()
	setToggle(not enabled)
end)

RunService.Heartbeat:Connect(function()
	if not enabled then return end
	if not target then
		local p=getNearest()
		if p then trackTarget(p) end
	end
end)

RunService.RenderStepped:Connect(function()
	if not enabled then return end
	if not target then return end
	local tc,th,thrp=aliveChar(target)
	local myc,myh,myhrp=aliveChar(LP)
	if not tc or not myc then trackTarget(nil) return end
	local camPos=Camera.CFrame.Position
	local aimPos=thrp.Position
	local look=CFrame.new(camPos,aimPos)
	Camera.CFrame=look
end)
