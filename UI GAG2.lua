local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Remove existing UI to prevent overlapping
if CoreGui:FindFirstChild("HubInfoUI") then
    CoreGui.HubInfoUI:Destroy()
elseif LocalPlayer.PlayerGui:FindFirstChild("HubInfoUI") then
    LocalPlayer.PlayerGui.HubInfoUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HubInfoUI"
ScreenGui.ResetOnSpawn = false

-- Safe place for the UI
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

-- Main Background Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2

-- Căn giữa màn hình hoàn hảo
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) 

MainFrame.Size = UDim2.new(0, 320, 0, 0)
MainFrame.AutomaticSize = Enum.AutomaticSize.Y
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent = MainFrame
UIPadding.PaddingTop = UDim.new(0, 16)
UIPadding.PaddingBottom = UDim.new(0, 16)
UIPadding.PaddingLeft = UDim.new(0, 16)
UIPadding.PaddingRight = UDim.new(0, 16)

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 0, 28)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🌸 KAITUN STATUS 🌸"
TitleLabel.TextColor3 = Color3.fromRGB(255, 170, 255)
TitleLabel.TextSize = 22
TitleLabel.LayoutOrder = 0

local Line = Instance.new("Frame")
Line.Name = "Line"
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line.BackgroundTransparency = 0.8
Line.BorderSizePixel = 0
Line.Size = UDim2.new(1, 0, 0, 2)
Line.LayoutOrder = 1

-- Info Labels Management
local infoLabels = {}
local layoutOrderCounter = 2

local function CreateInfoLabel(id, defaultText)
    local Label = Instance.new("TextLabel")
    Label.Name = id
    Label.Parent = MainFrame
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 26)
    Label.Font = Enum.Font.GothamMedium
    Label.Text = defaultText
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    Label.TextScaled = true 
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
    UITextSizeConstraint.MaxTextSize = 18
    UITextSizeConstraint.MinTextSize = 12
    UITextSizeConstraint.Parent = Label
    
    Label.LayoutOrder = layoutOrderCounter
    layoutOrderCounter = layoutOrderCounter + 1
    
    infoLabels[id] = Label
    return Label
end

-- Default Labels
CreateInfoLabel("Account", "👤 Account: " .. LocalPlayer.Name)
CreateInfoLabel("Status", "⚡ Status: Waiting...")
CreateInfoLabel("Stats1", "💰 Coins: 0")
CreateInfoLabel("Stats2", "🌱 Planting: 0 / 0")
CreateInfoLabel("Uptime", "⏱️ Uptime: 00:00:00")

-- Function to Update Text
local function UpdateInfo(id, text)
    if infoLabels[id] then
        infoLabels[id].Text = text
    end
end

-- Smooth Dragging Logic
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Global variable for other scripts to call
getgenv().UpdateUIInfo = UpdateInfo
