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

--🌟 1. Slider Speed
local walkspeed = 16
PlayerTab:CreateSlider({
   Name = "Speed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v)
      walkspeed = v
   end
})

--🌟 2. Slider JumpPower
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

--🌟 3. Infinity Jump (fix leak + ổn định)
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
