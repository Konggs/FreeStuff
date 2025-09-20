local Players = game:GetService("Players")
local VInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

local oldGui = pgui:FindFirstChild("CustomUIButton")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.Parent = "CustomUIButton", false, pgui

local button = Instance.new("ImageButton")
button.Name, button.Size, button.Position = "CircleButton", UDim2.fromOffset(60, 60), UDim2.fromOffset(10, 10)
button.Image, button.BackgroundColor3, button.BackgroundTransparency = "rbxassetid://72278895962822", Color3.fromRGB(40, 40, 40), 0
button.Parent = gui

local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(1, 0)

local glow = Instance.new("UIStroke", button)
glow.Thickness, glow.Color, glow.Transparency = 2, Color3.fromRGB(100, 200, 255), 0.5

local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

button.MouseEnter:Connect(function()
    tween(button, {BackgroundColor3 = Color3.fromRGB(70,70,70)}, 0.15)
    tween(glow, {Transparency = 0}, 0.15)
end)

button.MouseLeave:Connect(function()
    tween(button, {BackgroundColor3 = Color3.fromRGB(40,40,40)}, 0.15)
    tween(glow, {Transparency = 0.5}, 0.15)
end)

button.MouseButton1Click:Connect(function()
    tween(button, {Size = UDim2.fromOffset(54, 54)}, 0.08)
    task.wait(0.08)
    tween(button, {Size = UDim2.fromOffset(60, 60)}, 0.08)
    if VInput then
        VInput:SendKeyEvent(true, Enum.KeyCode.G, false, game)
        task.wait(0.05)
        VInput:SendKeyEvent(false, Enum.KeyCode.G, false, game)
    end
end)
