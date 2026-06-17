local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if CoreGui:FindFirstChild("HubInfoUI") then
    CoreGui.HubInfoUI:Destroy()
elseif LocalPlayer.PlayerGui:FindFirstChild("HubInfoUI") then
    LocalPlayer.PlayerGui.HubInfoUI:Destroy()
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HubInfoUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    local success, _ = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0
MainFrame.AnchorPoint = Vector2.new(0, 0)
MainFrame.Position = UDim2.new(0, 0, 0, 0)

MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.AutomaticSize = Enum.AutomaticSize.None
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 25)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🌸 KAITUN STATUS 🌸"
TitleLabel.TextColor3 = Color3.fromRGB(255, 170, 255)
TitleLabel.TextSize = 40
TitleLabel.LayoutOrder = 0

local Line = Instance.new("Frame")
Line.Name = "Line"
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line.BackgroundTransparency = 0.8
Line.BorderSizePixel = 0
Line.Size = UDim2.new(1, 0, 0, 2)
Line.LayoutOrder = 1

local infoLabels = {}
local layoutOrderCounter = 2

local function CreateInfoLabel(id, defaultText)
    local Label = Instance.new("TextLabel")
    Label.Name = id
    Label.Parent = MainFrame
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 45)
    Label.Font = Enum.Font.GothamMedium
    Label.Text = defaultText
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Center
    
    Label.TextScaled = true 
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
    UITextSizeConstraint.MaxTextSize = 35
    UITextSizeConstraint.MinTextSize = 20
    UITextSizeConstraint.Parent = Label
    Label.LayoutOrder = layoutOrderCounter
    layoutOrderCounter = layoutOrderCounter + 1
    infoLabels[id] = Label
    return Label
end

CreateInfoLabel("Account", "👤 Account: " .. LocalPlayer.Name)
CreateInfoLabel("Status", "⚡ Status: Waiting...")
CreateInfoLabel("Stats1", "💰 Coins: 0")
CreateInfoLabel("Stats2", "🌱 Planting: 0 / 0")
CreateInfoLabel("Uptime", "⏱️ Uptime: 00:00:00")

local function UpdateInfo(id, text)
    if infoLabels[id] then
        infoLabels[id].Text = text
    end
end

getgenv().UpdateUIInfo = UpdateInfo
