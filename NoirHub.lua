-- ===== FINAL INTRO UPDATED =====
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

-- FLASH
local flash = Instance.new("Frame", gui)
flash.Size = UDim2.new(1,0,1,0)
flash.BackgroundColor3 = Color3.new(1,1,1)
flash.BackgroundTransparency = 1
TweenService:Create(flash, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
task.wait(0.1)
TweenService:Create(flash, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()

-- BACKGROUND
local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
bg.BackgroundTransparency = 0.15
TweenService:Create(bg, TweenInfo.new(0.25), {BackgroundTransparency = 0.15}):Play()

-- BLUR
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(1.5), {Size = 20}):Play()

-- LOGO
local logo = Instance.new("Frame", bg)
logo.Size = UDim2.new(0,260,0,260)
logo.Position = UDim2.new(0.5,0,0.5,0)
logo.AnchorPoint = Vector2.new(0.5,0.5)
logo.BackgroundTransparency = 1

-- HALO
local function createHalo(size, transparency)
    local f = Instance.new("Frame", logo)
    f.Size = UDim2.new(0,size,0,size)
    f.Position = UDim2.new(0.5,0,0.5,0)
    f.AnchorPoint = Vector2.new(0.5,0.5)
    f.BackgroundColor3 = Color3.fromRGB(0,180,255)
    f.BackgroundTransparency = transparency
    f.BorderSizePixel = 0
    local uic = Instance.new("UICorner", f)
    uic.CornerRadius = UDim.new(1,0)
    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 6
    stroke.Color = Color3.fromRGB(0,200,255)
    stroke.Transparency = transparency - 0.3
    return f
end
local halo1 = createHalo(260,0.85)
local halo2 = createHalo(220,0.9)

-- NH LOGO
local nh = Instance.new("TextLabel", logo)
nh.Size = UDim2.new(0,140,0,140)
nh.Position = UDim2.new(0.5,0,0.3,0)
nh.AnchorPoint = Vector2.new(0.5,0.5)
nh.BackgroundTransparency = 1
nh.Text = "NH"
nh.TextScaled = true
nh.Font = Enum.Font.GothamBlack
nh.TextColor3 = Color3.fromRGB(0,200,255)
nh.TextTransparency = 1
nh.ZIndex = 10

-- GLOW
local glow1 = nh:Clone()
glow1.Parent = logo
glow1.TextTransparency = 0.7
local glow2 = nh:Clone()
glow2.Parent = logo
glow2.TextTransparency = 0.85

-- TITLE
local title = Instance.new("TextLabel", logo)
title.Size = UDim2.new(1,0,0.25,0)
title.Position = UDim2.new(0,0,0.6,0)
title.BackgroundTransparency = 1
title.Text = "NOIR HUB"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.TextTransparency = 1

-- PARTICLES
local particles = {}
for i=1,20 do
    local p = Instance.new("Frame", bg)
    p.Size = UDim2.new(0,4,0,4)
    p.Position = UDim2.new(math.random(),0,math.random(),0)
    p.BackgroundColor3 = Color3.fromRGB(0,200,255)
    p.BackgroundTransparency = 0
    p.BorderSizePixel = 0
    table.insert(particles,p)
end

-- LOADING BAR
local barBG = Instance.new("Frame", bg)
barBG.Size = UDim2.new(0.3,0,0.03,0)
barBG.Position = UDim2.new(0.35,0,0.85,0)
barBG.BackgroundColor3 = Color3.fromRGB(20,20,20)
barBG.BackgroundTransparency = 0.1
barBG.BorderSizePixel = 0
barBG.ZIndex = 15
barBG.ClipsDescendants = true

local uic = Instance.new("UICorner", barBG)
uic.CornerRadius = UDim.new(0.5,0) -- bo góc nhẹ

local barFill = Instance.new("Frame", barBG)
barFill.Size = UDim2.new(0,0,1,0)
barFill.Position = UDim2.new(0,0,0,0)
barFill.BackgroundColor3 = Color3.fromRGB(0,200,255)
barFill.BorderSizePixel = 0
barFill.ZIndex = 16
local uic2 = Instance.new("UICorner", barFill)
uic2.CornerRadius = UDim.new(0.5,0)

local barText = Instance.new("TextLabel", barBG)
barText.Size = UDim2.new(1,0,1,0)
barText.Position = UDim2.new(0,0,0,0)
barText.BackgroundTransparency = 1
barText.TextColor3 = Color3.new(1,1,1)
barText.TextScaled = true
barText.Font = Enum.Font.GothamBold
barText.Text = "0%"
barText.ZIndex = 17

-- FADE IN WHOLE INTRO
TweenService:Create(nh, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
TweenService:Create(title, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
TweenService:Create(halo1, TweenInfo.new(0.25), {BackgroundTransparency = 0.85}):Play()
TweenService:Create(halo2, TweenInfo.new(0.25), {BackgroundTransparency = 0.9}):Play()

-- ANIMATION
local baseSize = 260
local conn
conn = RunService.RenderStepped:Connect(function()
    local pulse = math.sin(tick()*2)*15
    nh.Size = UDim2.new(0,140 + pulse,0,140 + pulse)
    nh.Rotation += 1.5
    glow1.Rotation = nh.Rotation
    glow2.Rotation = nh.Rotation
    local zoom = 1 + math.sin(tick()*2)*0.05
    logo.Size = UDim2.new(0,baseSize*zoom,0,baseSize*zoom)
    halo1.Size = UDim2.new(0,baseSize + pulse,0,baseSize + pulse)
    halo2.Size = UDim2.new(0,baseSize - 40 + pulse,0,baseSize - 40 + pulse)
end)

-- ===== RUN INTRO 3.5s THEN LOAD UI =====
task.spawn(function()
    local loadTime = 3.5
    for i=0,100 do
        barFill.Size = UDim2.new(i/100,0,1,0)
        barText.Text = i.."%"
        task.wait(loadTime/100)
    end
    barText.Text = "LOAD SUCCESS"
    task.wait(0.5)

    local fadeTime = 1.5
    TweenService:Create(bg, TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
    TweenService:Create(nh, TweenInfo.new(fadeTime), {TextTransparency = 1}):Play()
    TweenService:Create(title, TweenInfo.new(fadeTime), {TextTransparency = 1}):Play()
    TweenService:Create(halo1, TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
    TweenService:Create(halo2, TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
    TweenService:Create(barBG, TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
    for _,p in pairs(particles) do
        TweenService:Create(p, TweenInfo.new(fadeTime), {BackgroundTransparency = 1}):Play()
    end
    TweenService:Create(blur, TweenInfo.new(fadeTime), {Size = 0}):Play()
    task.wait(fadeTime + 0.5)

    gui:Destroy()
    blur:Destroy()
    conn:Disconnect()

    -- LOAD SCRIPT NOIR HUB
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirHubHH"))()
end)
