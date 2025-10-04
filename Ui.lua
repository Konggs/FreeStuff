local YuukiGui = Instance.new("ScreenGui")
YuukiGui.Name = "YuukiUI"
YuukiGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
YuukiGui.IgnoreGuiInset = true
YuukiGui.ResetOnSpawn = false
YuukiGui.Parent = game:GetService("CoreGui")
YuukiGui.Enabled = true
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.Position = UDim2.new(0, 0, 0, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.35
Overlay.BorderSizePixel = 0
Overlay.Name = "Overlay"
Overlay.Parent = YuukiGui
local Title = Instance.new("TextLabel")
Title.AnchorPoint = Vector2.new(0.5, 0.5)
Title.Position = UDim2.new(0.5, 0, 0.4, 0)
Title.Size = UDim2.new(1, 0, 0, 80)
Title.BackgroundTransparency = 1
Title.Text = "Yuuki Hub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 72
Title.TextColor3 = Color3.fromRGB(175, 187, 230)
Title.Parent = Overlay
local TimeLabel = Instance.new("TextLabel")
TimeLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TimeLabel.Position = UDim2.new(0.5, 0, 0.48, 0)
TimeLabel.Size = UDim2.new(1, 0, 0, 30)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "Time: 00:00:00"
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 20
TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeLabel.Parent = Overlay
local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.AnchorPoint = Vector2.new(0.5, 0.5)
MoneyLabel.Position = UDim2.new(0.5, 0, 0.54, 0)
MoneyLabel.Size = UDim2.new(1, 0, 0, 30)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.Text = "Money: 0"
MoneyLabel.Font = Enum.Font.Gotham
MoneyLabel.TextSize = 20
MoneyLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
MoneyLabel.Parent = Overlay
local TotalDamageLabel = Instance.new("TextLabel")
TotalDamageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TotalDamageLabel.Position = UDim2.new(0.5, 0, 0.60, 0)
TotalDamageLabel.Size = UDim2.new(1, 0, 0, 30)
TotalDamageLabel.BackgroundTransparency = 1
TotalDamageLabel.Text = "Total Damage: 0"
TotalDamageLabel.Font = Enum.Font.Gotham
TotalDamageLabel.TextSize = 20
TotalDamageLabel.TextColor3 = Color3.fromRGB(253, 0, 0)
TotalDamageLabel.Parent = Overlay
local RebirthLabel = Instance.new("TextLabel")
RebirthLabel.AnchorPoint = Vector2.new(0.5, 0.5)
RebirthLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
RebirthLabel.Size = UDim2.new(1, 0, 0, 30)
RebirthLabel.BackgroundTransparency = 1
RebirthLabel.Text = "Rebirth: 0"
RebirthLabel.Font = Enum.Font.Gotham
RebirthLabel.TextSize = 20
RebirthLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
RebirthLabel.Parent = Overlay
local Note = Instance.new("TextButton")
Note.AnchorPoint = Vector2.new(0.5, 1)
Note.Position = UDim2.new(0.5, 0, 0.8, 0)
Note.Size = UDim2.new(1, 0, 0, 40)
Note.BackgroundTransparency = 1
Note.Text = "Click Here To Copy Discord Invite"
Note.Font = Enum.Font.Gotham
Note.TextSize = 14
Note.TextTransparency = 0.4
Note.TextColor3 = Color3.fromRGB(255, 255, 255)
Note.TextWrapped = true
Note.Parent = Overlay
local Blur = Instance.new("BlurEffect")
Blur.Size = 50
Blur.Parent = game.Lighting
Blur.Enabled = true
local startTime = tick()
local function getTimeSinceStart()
    local elapsed = tick() - startTime
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    local s = math.floor(elapsed % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end
getgenv().money = 0
getgenv().rebirth = 0
getgenv().damage = 0
local function UpdateUI()
    TimeLabel.Text = "Time: " .. getTimeSinceStart()
    MoneyLabel.Text = "Money: " .. tostring(getgenv().money)
    TotalDamageLabel.Text = "Total Damage: " .. tostring(getgenv().damage)
    RebirthLabel.Text = "Rebirth: " .. tostring(getgenv().rebirth)
end
local function GetCurrentMoney() getgenv().money = game.Players.LocalPlayer.leaderstats.Money.Value end
local function GetRebirthTime() getgenv().rebirth = tonumber(game.Players.LocalPlayer.PlayerGui.Main.Stats.Frame.ScrollingFrame.Rebirth.Value.Text) end
local function GetTotalDamage() getgenv().damage = game.Players.LocalPlayer:GetAttribute("TotalDamage") end
spawn(function()
    while task.wait(1) do
        GetRebirthTime()
        GetCurrentMoney()
        GetTotalDamage()
        UpdateUI()
    end
end)
Note.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/YuukiHub")
    else
        warn("Your exploit does not support clipboard copy!")
    end
end)
