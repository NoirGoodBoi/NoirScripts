-- SETTINGS
getgenv().Setting = {
    ["Body"] = {
        ["Korblox"] = true,
        ["Headless"] = true,
    },
}

-- Auto apply Korblox + Headless
loadstring(game:HttpGet("https://raw.githubusercontent.com/khen791/script-khen/refs/heads/main/KorbloxAndHeadless.txt", true))()
