local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Noir Hub",
    LoadingTitle = "Loading NoirHub...",
    LoadingSubtitle = "Script By Noir",
    ConfigurationSaving = {
        Enabled = false,
    }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)

-- 1. Slider Speed
local walkspeed = 16
PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        walkspeed = v
    end
})

-- 2. Toggle Tăng tốc độ (✅ FIXED)
local speedLoop = nil
PlayerTab:CreateToggle({
    Name = "Tăng tốc độ",
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
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        jumppower = v
    end
})

-- 4. Toggle Tăng power jump (✅ FIXED)
local jumpLoop = nil
PlayerTab:CreateToggle({
    Name = "Tăng power jump",
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

-- 6. NoClip + Bypass void
local noclip = false
local lastPosition = nil

PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(state)
        noclip = state
        local plr = game.Players.LocalPlayer
        game:GetService("RunService"):UnbindFromRenderStep("NoirNoClip")
        if state then
            game:GetService("RunService"):BindToRenderStep("NoirNoClip", Enum.RenderPriority.Character.Value, function()
                local char = plr.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide == true then
                            v.CanCollide = false
                        end
                    end
                    if char:FindFirstChild("HumanoidRootPart") then
                        local posY = char.HumanoidRootPart.Position.Y
                        if posY < -10 and lastPosition then
                            char.HumanoidRootPart.CFrame = lastPosition
                        else
                            lastPosition = char.HumanoidRootPart.CFrame
                        end
                    end
                end
            end)
        end
    end
})

-- 7. ESP (Tên + khoảng cách, không scale)
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

PlayerTab:CreateToggle({
    Name = "ESP (Tên + Khoảng cách)",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        removeAllESP()
        if not state then return end

        local function createESP(plr)
            if plr == game.Players.LocalPlayer then return end
            local billboard = Instance.new("BillboardGui", plr.Character:WaitForChild("Head"))
            billboard.Name = "NoirESP"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.LightInfluence = 0
            billboard.MaxDistance = math.huge

            local txt = Instance.new("TextLabel", billboard)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.TextScaled = false
            txt.Font = Enum.Font.SourceSansBold
            txt.TextSize = 14
            txt.TextColor3 = Color3.new(1, 1, 1)
            txt.TextStrokeTransparency = 0.5
            txt.Text = plr.Name

            local conn = game:GetService("RunService").RenderStepped:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    txt.Text = plr.Name .. " | " .. math.floor(dist) .. "m"
                end
            end)

            table.insert(espInstances, billboard)
            table.insert(espConnections, conn)
        end

        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character then
                createESP(plr)
            end
        end

        table.insert(espConnections, game.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                wait(1)
                createESP(plr)
            end)
        end))
    end
})

-- 8. Anti-AFK (Button)
PlayerTab:CreateButton({
    Name = "Bật Anti-AFK",
    Callback = function()
        for _, conn in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
            conn:Disable()
        end
    end
})

local PacksTab = Window:CreateTab("Packs", 4483362458)

-- 📦 Không FE
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

-- ✨ FE
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

local ScriptsTab = Window:CreateTab("Scripts", 4483362458)

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
    Name = "Animation v2.5",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/ScriptR6/AnimGuiV2.lua"))()
    end,
})

ScriptsTab:CreateButton({
    Name = "Keyboard",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/advxzivhsjjdhxhsidifvsh/mobkeyboard/main/main.txt", true))()
    end,
})

ScriptsTab:CreateButton({
    Name = "GhostHub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/GhostHub"))()
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
    Name = "TBS (by YQANTG)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/YQANTG/YQANTG/refs/heads/main/YQANTGV31.txt"))()
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

ScriptsTab:CreateButton({
    Name = "Dangerous Night",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Bac0nHck/Scripts/refs/heads/main/dangerousnight.lua"))()
    end,
})



