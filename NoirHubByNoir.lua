
-- 📋 AUTO COPY LINK
local link = "https://lootdest.org/s?2DqfqD7L"
setclipboard(link)

-- 🔑 KEY
local DailyKey = "NOIR-JQKA-AA22"
local VIPKey = "NOIRKEY"

-- 🖥️ GUI
local gui = Instance.new("ScreenGui")
gui.Name = "NoirKeyUI"
gui.Parent = game.CoreGui

-- FRAME
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 340, 0, 200)
frame.Position = UDim2.new(0.5, -170, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- ❌ CLOSE BUTTON
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -32, 0, 4)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.BackgroundColor3 = Color3.fromRGB(50,50,50)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)

close.MouseEnter:Connect(function()
    close.BackgroundColor3 = Color3.fromRGB(200,60,60)
end)

close.MouseLeave:Connect(function()
    close.BackgroundColor3 = Color3.fromRGB(50,50,50)
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.Text = "Noir Hub [FREE]"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- INFO
local info = Instance.new("TextLabel", frame)
info.Position = UDim2.new(0,0,0,30)
info.Size = UDim2.new(1,0,0,20)
info.Text = "Link đã được copy vào clipboard"
info.TextColor3 = Color3.fromRGB(180,180,180)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextSize = 13

-- INPUT
local box = Instance.new("TextBox", frame)
box.Position = UDim2.new(0.1,0,0.4,0)
box.Size = UDim2.new(0.8,0,0,32)
box.PlaceholderText = "Enter key..."
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.new(1,1,1)
box.Font = Enum.Font.Gotham
box.TextSize = 14
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

-- STATUS
local status = Instance.new("TextLabel", frame)
status.Position = UDim2.new(0,0,0.65,0)
status.Size = UDim2.new(1,0,0,20)
status.Text = ""
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 13

-- BUTTON
local btn = Instance.new("TextButton", frame)
btn.Position = UDim2.new(0.25,0,0.8,0)
btn.Size = UDim2.new(0.5,0,0,32)
btn.Text = "Submit"
btn.BackgroundColor3 = Color3.fromRGB(60,120,255)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

-- 🔑 CHECK KEY
btn.MouseButton1Click:Connect(function()
    local key = box.Text

    if key == VIPKey or key == DailyKey then
        status.Text = "Key đúng, loading..."
        status.TextColor3 = Color3.fromRGB(0,255,100)

        task.wait(1)

        gui:Destroy()

        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirHub.lua"))()
    else
        status.Text = "Key sai!"
        status.TextColor3 = Color3.fromRGB(255,80,80)
    end
end)
