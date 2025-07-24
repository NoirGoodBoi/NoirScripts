-- SETTINGS
getgenv().Setting = {
    ["Body"] = {
        ["Korblox"] = true,
        ["Headless"] = true,
    },
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/khen791/script-khen/refs/heads/main/KorbloxAndHeadless.txt", true))()

-- GUI Toggle Icon 🤖
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Check if GUI already exists
if CoreGui:FindFirstChild("NoirToggleGUI") then
    CoreGui:FindFirstChild("NoirToggleGUI"):Destroy()
end

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "NoirToggleGUI"
toggleBtn.Parent = CoreGui
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "🤖"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextScaled = true
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 999999
toggleBtn.Active = true
toggleBtn.Draggable = true

-- Tìm GUI chính
local function findMainGui()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name ~= "NoirToggleGUI" then
            if v:FindFirstChildWhichIsA("Frame") then
                return v
            end
        end
    end
    return nil
end

-- Toggle hiển thị GUI chính
local visible = true
toggleBtn.MouseButton1Click:Connect(function()
    local mainGui = findMainGui()
    if mainGui then
        visible = not visible
        mainGui.Enabled = visible
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Noir GUI",
            Text = "Không tìm thấy GUI chính 😓",
            Duration = 3
        })
    end
end) 
