local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Noir Hub",
    LoadingTitle = "Loading NoirHub...",
    LoadingSubtitle = "Script By Noir",
    ConfigurationSaving = {
        Enabled = false,
    }
})

local PlayerTab = Window:CreateTab("Player", "user")

-- 1. Slider Speed
local walkspeed = 16
PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {16, 1000},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        walkspeed = v
    end
})

-- 2. Toggle increase speed
local speedLoop = nil
PlayerTab:CreateToggle({
    Name = "Increase Speed",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer
        if state then
            speedLoop = task.spawn(function()
                while task.wait() do
                    if not state then break end
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        plr.Character.Humanoid.WalkSpeed = walkspeed
                    end
                end
            end)
        else
            if speedLoop then
                task.cancel(speedLoop)
                speedLoop = nil
            end
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

-- 3. Slider Power Jump
local jumppower = 50
PlayerTab:CreateSlider({
    Name = "Power Jump",
    Range = {50, 1000},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        jumppower = v
    end
})

-- 4. Toggle increase power jump 
local jumpLoop = nil
PlayerTab:CreateToggle({
    Name = "Increase Power Jump",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer
        if state then
            jumpLoop = task.spawn(function()
                while task.wait() do
                    if not state then break end
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        plr.Character.Humanoid.JumpPower = jumppower
                    end
                end
            end)
        else
            if jumpLoop then
                task.cancel(jumpLoop)
                jumpLoop = nil
            end
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.JumpPower = 50
            end
        end
    end
})

-- 5. Infinity Jump
local infJumpConnection
PlayerTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Callback = function(state)
        if state then
            infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConnection then
                infJumpConnection:Disconnect()
                infJumpConnection = nil
            end
        end
    end
})

--6. Noclip
PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(state)
        local RunService = game:GetService("RunService")
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()

        RunService:UnbindFromRenderStep("NoirNoClip")

        if state then
            RunService:BindToRenderStep("NoirNoClip", Enum.RenderPriority.Character.Value, function()
                local char = plr.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(11)
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
})

-- 7. ESP (tên+dist)
local espEnabled = false
local espConnections = {}
local espInstances = {}

local function removeAllESP()
    for _, gui in pairs(espInstances) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    espInstances = {}
    espConnections = {}
end

local function createESP(plr)
    if plr == game.Players.LocalPlayer then return end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NoirESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.LightInfluence = 0
    billboard.MaxDistance = math.huge
    billboard.Parent = head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = false
    txt.Font = Enum.Font.SourceSansBold
    txt.TextSize = 14
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.TextStrokeTransparency = 0.5
    txt.Text = plr.Name
    txt.Parent = billboard

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            txt.Text = plr.Name .. " | " .. math.floor(dist) .. "m"
        end
    end)

    table.insert(espInstances, billboard)
    table.insert(espConnections, conn)
end

PlayerTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        removeAllESP()
        if not state then return end

        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                if plr.Character then
                    createESP(plr)
                end
                
                table.insert(espConnections, plr.CharacterAdded:Connect(function()
                    if espEnabled then
                        task.wait(0.5)
                        createESP(plr)
                    end
                end))
            end
        end

        table.insert(espConnections, game.Players.PlayerAdded:Connect(function(plr)
            if espEnabled then
                plr.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    createESP(plr)
                end)
            end
        end))
    end
})

--8. Show Ping & FPS
local statsGui
local showStats = false

local function createStatsGui()
    if statsGui then statsGui:Destroy() end

    statsGui = Instance.new("ScreenGui")
    statsGui.Name = "NoirStatsGui"
    statsGui.IgnoreGuiInset = true
    statsGui.ResetOnSpawn = false
    statsGui.Parent = game:GetService("CoreGui")

    local label = Instance.new("TextLabel")
    label.Name = "StatsLabel"
    label.Size = UDim2.new(0, 200, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 55)
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = statsGui

    game:GetService("RunService").RenderStepped:Connect(function()
        if not showStats then return end
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait()) .. " FPS"
        label.Text = "Ping: " .. ping .. "   FPS: " .. fps
    end)
end

PlayerTab:CreateToggle({
    Name = "Show Ping & FPS",
    CurrentValue = false,
    Callback = function(state)
        showStats = state
        if state then
            createStatsGui()
        else
            if statsGui then
                statsGui:Destroy()
                statsGui = nil
            end
        end
    end
})

--9. Mini Map
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MapGui, MapFrame, MapObjects = nil, nil, {}
local MapEnabled = false

local function createMap()
MapGui = Instance.new("ScreenGui")
MapGui.IgnoreGuiInset = true
MapGui.ResetOnSpawn = false
MapGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MapGui.Parent = game.CoreGui

MapFrame = Instance.new("Frame")  
MapFrame.Size = UDim2.new(0,150,0,150)  
MapFrame.Position = UDim2.new(1,-160,0,10)   
MapFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)  
MapFrame.BackgroundTransparency = 0.4  
MapFrame.BorderSizePixel = 0  
MapFrame.Parent = MapGui  
MapFrame.ClipsDescendants = true

end

local function getDotColor(player)
if player == LocalPlayer then
return Color3.fromRGB(0,255,0), Color3.fromRGB(0,150,0), 3
elseif LocalPlayer:IsFriendsWith(player.UserId) then
return Color3.fromRGB(0,170,255), Color3.fromRGB(0,100,200), 2
else
return Color3.fromRGB(255,255,255), Color3.fromRGB(80,80,80), 1
end
end

local function createDot(player)
if MapObjects[player] then return end

local dot = Instance.new("Frame")  
dot.Size = UDim2.new(0,8,0,8)  
dot.AnchorPoint = Vector2.new(0.5,0.5)  

local color, border, zindex = getDotColor(player)  
dot.BackgroundColor3 = color  
dot.ZIndex = zindex  
dot.Parent = MapFrame  

local UICorner = Instance.new("UICorner")  
UICorner.CornerRadius = UDim.new(1,0) -- dot tròn  
UICorner.Parent = dot  

local UIStroke = Instance.new("UIStroke")  
UIStroke.Thickness = 2  
UIStroke.Color = border  
UIStroke.Parent = dot  

MapObjects[player] = dot

end

local function updateDots()
    if not MapEnabled then return end
    local center = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not center then return end

    -- góc xoay theo camera + nghiêng 45° sang trái
    local camYaw = math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + math.rad(45)

    for player, dot in pairs(MapObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local offset = (hrp.Position - center.Position) / 4

            -- xoay offset theo yaw đã nghiêng
            local rx = offset.X*math.cos(camYaw) + offset.Z*math.sin(camYaw)
            local rz = -offset.X*math.sin(camYaw) + offset.Z*math.cos(camYaw)

            if math.abs(rx) <= 70 and math.abs(rz) <= 70 then
                dot.Visible = true
                dot.Position = UDim2.new(0.5,rx,0.5,rz)
            else
            dot.Visible = false
            end
        else
            dot.Visible = false
        end
    end
end

local function initMap()
createMap()
for _,p in pairs(Players:GetPlayers()) do
createDot(p)
end
Players.PlayerAdded:Connect(createDot)
Players.PlayerRemoving:Connect(function(p)
if MapObjects[p] then MapObjects[p]:Destroy() MapObjects[p]=nil end
end)
RunService.RenderStepped:Connect(updateDots)
end

PlayerTab:CreateToggle({
Name = "MiniMap",
CurrentValue = false,
Flag = "MiniMapToggle",
Callback = function(state)
MapEnabled = state
if state then
if not MapGui then initMap() end
MapGui.Enabled = true
else
if MapGui then MapGui.Enabled = false end
end
end
})

-- 10. Anti-AFK (Button)
PlayerTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        for _, conn in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
            conn:Disable()
        end
    end
})

local PacksTab = Window:CreateTab("Packs", "package")

PacksTab:CreateButton({
    Name = "Korblox",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Korblox.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Headless",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Headless.lua"))()
    end,
})

-- ----------------------------- --

PacksTab:CreateButton({
    Name = "Ninja",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Ninja.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Robot",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Robot.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Levitate",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Levitate.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Mage",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Mage.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Stylish",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Stylish.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Hero",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Hero.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Astronaut",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Astronaut.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Bubbly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Bubbly.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Cartoony",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Cartoony.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Elder",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Elder.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Ghost",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Ghost.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Knight",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Knight.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Vampire",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Vampire.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Werewolf",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Werewolf.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Zombie",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Zombie.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Oldschool",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Oldschool.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Bold",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Bold.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Adidas",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Adidas.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Adidas2",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Adidas2.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Catwalk",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Catwalk.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Walmart",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Walmart.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Wicked",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Wicked.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "NFL",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/NFL.lua"))()
    end,
})

PacksTab:CreateButton({
    Name = "Pirate",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirPacks/main/Pirate.lua"))()
    end,
})

local ScriptsTab = Window:CreateTab("Scripts", "file-text")

ScriptsTab:CreateButton({
    Name = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Vehicle%20Fly%20Gui"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Funny by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirFunny.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "PvP by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirPvP.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Wallhop",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ScpGuest666/Random-Roblox-script/refs/heads/main/Roblox%20WallHop%20V4%20script"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Aim Bot",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-Universal-For-Mobile-and-PC-29153"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "SilentAim by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/SilentAim.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "M1 reset",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/M1Reset.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "ResetUI by Noir",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/ResetUi.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Animation v2.5",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/ScriptR6/AnimGuiV2.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Emote R15",
    Callback = function()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-all-emotes-6849"))
    end,
})

ScriptsTab:CreateButton({
    Name = "Keyboard",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt", true))()
    end,
})

ScriptsTab:CreateButton({
    Name = "FE Trolling GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/FE%20Trolling%20GUI.luau"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Krystal Dance v3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sparezirt/Script/refs/heads/main/.github/workflows/JustABaseplate.txt"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "AK Gaming Ez Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hehej97/AkGamingEzv2.1/refs/heads/main/AKGaming.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "IndexZ Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/IndexZHub/Loader/main/Loader"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "NodeX",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NodeX-Enc/NodeX/refs/heads/main/Main.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "TBS (by YQANTG)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Kietba/Fr/refs/heads/main/Wekinda.txt"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Forsaken",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/notzanocoddz4/BobHub/main/main.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "MM2 (X Hub)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Au0yX/Community/main/XhubMM2"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "MeMe Sea",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZaqueHub/ShinyHub-MMSea/main/MEME%20SEA%20PROTECT.txt"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Ink Game",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wefwef127382/inkgames.github.io/refs/heads/main/ringta.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Deadrail",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/wefwef127382/DEADRAILS.github.io/refs/heads/main/mainringta.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Farm Bond (Skull Hub)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hungquan99/SkullHub/main/loader.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Blade Ball",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AgentX771/ArgonHubX/main/Loader.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Break In 1",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Iptxt/AXHub-Loader/refs/heads/main/Loader"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Break In 2",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EnesXVC/Breakin2/main/script"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Doors",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/NewBestDoorsScriptIliankytb"))()
    end,
})


