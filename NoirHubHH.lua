local Rayfield = loadstring(readfile("Sirius/Rayfield.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "Noir Loader",
    LoadingTitle = "NoirHub by Noir",
    LoadingSubtitle = "Key System",
    ConfigurationSaving = {Enabled=false},
    Discord = {Enabled=false},
    KeySystem = false
})

local Tab = Window:CreateTab("Key")
local current = ""
local fails = 0
local msgs = {
    "Key Sai",
    "lại sai",
    "ĐM SAI",
    'Đm key đây: "NOIRDEPTRAIHH"',
    'Ko thì đây cũng đc: "KEYDAYNE"',
    "đm m có vấn đề đọc hiểu à >:(",
    ".",
    "...",
    "...",
    "thôi bỏ đi, dùng làm j nữa, có cái key, t gợi ý rồi cũng nhập sai",
    'Key là: "NOIRDEPTRAIHH" & "KEYDAYNE"',
    "Thôi bỏ >:("
    "..."
}
local keys = {"NOIRDEPTRAIHH","KEYDAYNE","1"}

local function valid(k)
    for _,v in ipairs(keys) do
        if string.lower(k) == string.lower(v) then return true end
    end
    return false
end

Tab:CreateInput({
    Name = "Nhập key để mở",
    PlaceholderText = "Key...",
    RemoveTextAfterFocusLost = false,
    OnEnter = true,
    Callback = function(v) current = v end
})

Tab:CreateButton({
    Name = "Mở khoá",
    Callback = function()
        if valid(current) then
            fails = 0
            Rayfield:Notify({Title="Thành công", Content="Key đúng", Duration=2})
            task.delay(0.2,function() Rayfield:Destroy() end)
            task.delay(0.1,function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/NoirGoodBoi/NoirScripts/main/NoirHubByNoir.lua"))()
            end)
        else
            fails = fails + 1
            local m = msgs[fails] or msgs[#msgs]
            Rayfield:Notify({Title="Sai key", Content=m, Duration=3})
        end
    end
})
