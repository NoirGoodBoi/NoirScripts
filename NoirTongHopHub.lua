local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "Noir Scripts Hub",
   LoadingTitle = "Loading NoirHub...",
   LoadingSubtitle = "Powered by Rayfield",
   ConfigurationSaving = {
      Enabled = false,
   }
})

local Tab = Window:CreateTab("Noir Scripts", Color3.fromRGB(44, 120, 224))

Tab:CreateButton({
   Name = "1. PvP by Noir",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirPvP.lua"))()
   end,
})

Tab:CreateButton({
   Name = "2. Animation Pack by Noir",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/AnimationPackByNoir.lua"))()
   end,
})

Tab:CreateButton({
   Name = "3. Body by Noir",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/BodyByNoir.lua"))()
   end,
})

Tab:CreateButton({
   Name = "4. Funny by Noir",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirFunny.lua"))()
   end,
})

Tab:CreateButton({
   Name = "5. Emote Pack",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/ScriptR6/AnimGuiV2.lua"))()
   end,
})

Tab:CreateButton({
   Name = "6. Aim Bot",
   Callback = function()
       loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Volcano-universal-aimbot-36995"))()
   end,
})

Tab:CreateButton({
   Name = "7. Infinity Yield",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end,
})

Tab:CreateButton({
   Name = "8. Wallhop by Noir",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/ScpGuest666/Random-Roblox-script/refs/heads/main/Roblox%20WallHop%20V4%20script"))()
   end,
})
