local validKeys = {
    ["NOIRDEPTRAIHH"] = true,
    ["KEYDAYNE"] = true,
    ["3107210"] = true,
    ["6697"] = true,
    ["7"] = true,
}

local SCRIPT_URL = "https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirHubByNoir.lua"

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local UICorner = Instance.new("UICorner", Frame)
local TextBox = Instance.new("TextBox", Frame)
local Button = Instance.new("TextButton", Frame)
local Label = Instance.new("TextLabel", Frame)

Frame.Size = UDim2.new(0, 250, 0, 140)
Frame.Position = UDim2.new(0.5, -125, 0.5, -70)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true
UICorner.CornerRadius = UDim.new(0,12)

TextBox.Size = UDim2.new(0, 200, 0, 30)
TextBox.Position = UDim2.new(0.5, -100, 0, 20)
TextBox.PlaceholderText = "Nhập key..."
TextBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
TextBox.TextColor3 = Color3.fromRGB(255,255,255)
TextBox.ClearTextOnFocus = false
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0,8)

Button.Size = UDim2.new(0, 200, 0, 30)
Button.Position = UDim2.new(0.5, -100, 0, 60)
Button.BackgroundColor3 = Color3.fromRGB(70,70,70)
Button.Text = "Load Script"
Button.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", Button).CornerRadius = UDim.new(0,8)

Label.Size = UDim2.new(0, 200, 0, 20)
Label.Position = UDim2.new(0.5, -100, 0, 100)
Label.BackgroundTransparency = 1
Label.Text = "Chưa nhập key"
Label.TextColor3 = Color3.fromRGB(255,255,255)
Label.TextScaled = true

Button.MouseButton1Click:Connect(function()
    local key = TextBox.Text
    if validKeys[key] then
        Label.Text = "Key hợp lệ ✔, đang load..."
        local ok,err = pcall(function()
            loadstring(game:HttpGet(SCRIPT_URL))()
        end)
        if ok then
            Label.Text = "Load thành công!"
            Frame:Destroy()
        else
            Label.Text = "Lỗi: "..tostring(err)
        end
    else
        Label.Text = "Key sai ❌"
    end
end)
