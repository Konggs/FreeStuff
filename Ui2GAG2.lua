local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if gethui then
    local hui = gethui()
    if hui:FindFirstChild("KaitunTracker") then
        hui.KaitunTracker:Destroy()
    end
end
if CoreGui:FindFirstChild("KaitunTracker") then
    CoreGui.KaitunTracker:Destroy()
end

local env = getgenv()
if not env.DiscordLink then env.DiscordLink = "discord.gg/SeaHub" end

local SeaConfigs = {
    PlayerInfo = {
        {key = "Username", value = LocalPlayer.Name},
        {key = "Coins", value = "0"},
        {key = "Planting", value = "0 / 0"},
        {key = "Pets", value = "0"},
        {key = "Max Slots", value = "0"},
        {key = "Expansion", value = "0"},
    },

    GameInfo = {
        {key = "Status", value = "Waiting..."},
    },
     
    ColorMapping = {
        ["username"] = Color3.fromRGB(255, 255, 255),
        ["coins"] = Color3.fromRGB(255, 219, 93),
        ["planting"] = Color3.fromRGB(0, 255, 106),
        ["pets"] = Color3.fromRGB(255, 120, 120),
        ["max slots"] = Color3.fromRGB(255, 150, 150),
        ["expansion"] = Color3.fromRGB(150, 200, 255),
        ["status"] = Color3.fromRGB(252, 255, 60),
    },

    BackgroundColor = Color3.fromRGB(20, 20, 20),
    BorderColor = Color3.fromRGB(0, 255, 106),
    TitleColor = Color3.fromRGB(255, 255, 255),
    SubTitleColor = Color3.fromRGB(0, 255, 106),
    TextColor = Color3.fromRGB(180, 180, 180),

    FullScreen = true,
    ShowTime = true
}

function Trackstack()
		
	local ScreenGui = Instance.new("ScreenGui")
	local MainFrame = Instance.new("Frame")

	local HeaderFrame = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local SubTitle = Instance.new("TextLabel")
	local TimeLabel = Instance.new("TextLabel")

	local PlayerFrame = Instance.new("Frame")
	local PlayerTitle = Instance.new("TextLabel")

	local GameFrame = Instance.new("Frame")
	local GameTitle = Instance.new("TextLabel")

	ScreenGui.Name = "KaitunTracker"
	if gethui then
		ScreenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = CoreGui
	else
		pcall(function()
			ScreenGui.Parent = CoreGui
		end)
	end
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Enabled = true

	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = SeaConfigs.BackgroundColor
	MainFrame.BorderColor3 = SeaConfigs.BorderColor
	MainFrame.BorderSizePixel = 3
	MainFrame.Position = UDim2.new(0, 0, 0, 0)
	MainFrame.Size = UDim2.new(1, 0, 1, 0)

	HeaderFrame.Name = "HeaderFrame"
	HeaderFrame.Parent = MainFrame
	HeaderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	HeaderFrame.BorderColor3 = SeaConfigs.BorderColor
	HeaderFrame.BorderSizePixel = 2
	HeaderFrame.Position = UDim2.new(0.4, 0, 0.03, 0)
	HeaderFrame.Size = UDim2.new(0.2, 0, 0.15, 0)

	Title.Name = "Title"
	Title.Parent = HeaderFrame
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 0, 0.08, 0)
	Title.Size = UDim2.new(1, 0, 0, 25)
	Title.Font = Enum.Font.SourceSansBold
	Title.Text = "Status: ".. tostring(LocalPlayer.Name)
	Title.TextColor3 = SeaConfigs.TitleColor
	Title.TextSize = 20

	SubTitle.Name = "SubTitle"
	SubTitle.Parent = HeaderFrame
	SubTitle.BackgroundTransparency = 1
	SubTitle.Position = UDim2.new(0, 0, 0.40, 0)
	SubTitle.Size = UDim2.new(1, 0, 0, 28)
	SubTitle.Font = Enum.Font.SourceSansBold
	SubTitle.Text = "Sea Hub: Grow A Garden 2"
	SubTitle.TextColor3 = SeaConfigs.SubTitleColor
	SubTitle.TextSize = 24

	if SeaConfigs.ShowTime then
		TimeLabel.Name = "TimeLabel"
		TimeLabel.Parent = HeaderFrame
		TimeLabel.BackgroundTransparency = 1
		TimeLabel.Position = UDim2.new(0, 0, 0.75, 0)
		TimeLabel.Size = UDim2.new(1, 0, 0, 20)
		TimeLabel.Font = Enum.Font.SourceSansBold
		TimeLabel.Text = "Time: 00:00:00"
		TimeLabel.TextColor3 = SeaConfigs.TextColor
		TimeLabel.TextSize = 16
	end

	function updateLayout()
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local isSmallScreen = viewportSize.X < 1200 or viewportSize.Y < 700
		
		if isSmallScreen then
			HeaderFrame.Position = UDim2.new(0.35, 0, 0.02, 0)
			HeaderFrame.Size = UDim2.new(0.3, 0, 0.18, 0)
			
			PlayerFrame.Position = UDim2.new(0.1, 0, 0.25, 0)
			PlayerFrame.Size = UDim2.new(0.8, 0, 0.32, 0)
			
			GameFrame.Position = UDim2.new(0.1, 0, 0.6, 0)
			GameFrame.Size = UDim2.new(0.8, 0, 0.32, 0)
			
			local playerLine = PlayerFrame:FindFirstChild("PlayerLine")
			local gameLine = GameFrame:FindFirstChild("GameLine")
			if playerLine then
				playerLine.Position = UDim2.new(0.1, 0, 0.15, 0)
				playerLine.Size = UDim2.new(0.8, 0, 0, 2)
			end
			if gameLine then
				gameLine.Position = UDim2.new(0.1, 0, 0.15, 0)
				gameLine.Size = UDim2.new(0.8, 0, 0, 2)
			end
			
			Title.TextSize = 20
			SubTitle.TextSize = 24
			TimeLabel.TextSize = 16
			PlayerTitle.TextSize = 20
			GameTitle.TextSize = 20
		else
			HeaderFrame.Position = UDim2.new(0.4, 0, 0.03, 0)
			HeaderFrame.Size = UDim2.new(0.2, 0, 0.15, 0)
			
			PlayerFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
			PlayerFrame.Size = UDim2.new(0.42, 0, 0.68, 0)
			
			GameFrame.Position = UDim2.new(0.53, 0, 0.25, 0)
			GameFrame.Size = UDim2.new(0.42, 0, 0.68, 0)
			
			local playerLine = PlayerFrame:FindFirstChild("PlayerLine")
			local gameLine = GameFrame:FindFirstChild("GameLine")
			if playerLine then
				playerLine.Position = UDim2.new(0.05, 0, 0.12, 0)
				playerLine.Size = UDim2.new(0.9, 0, 0, 2)
			end
			if gameLine then
				gameLine.Position = UDim2.new(0.05, 0, 0.12, 0)
				gameLine.Size = UDim2.new(0.9, 0, 0, 2)
			end
			
			Title.TextSize = 22
			SubTitle.TextSize = 26
			TimeLabel.TextSize = 18
			PlayerTitle.TextSize = 28
			GameTitle.TextSize = 28
		end
		
		for _, child in pairs(PlayerFrame:GetChildren()) do
			if child:IsA("TextLabel") and child.Name ~= "PlayerTitle" then
				child.TextSize = isSmallScreen and 20 or 24
			end
		end
		
		for _, child in pairs(GameFrame:GetChildren()) do
			if child:IsA("TextLabel") and child.Name ~= "GameTitle" then
				child.TextSize = isSmallScreen and 20 or 24
			end
		end
	end

	PlayerFrame.Name = "PlayerFrame"
	PlayerFrame.Parent = MainFrame
	PlayerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	PlayerFrame.BorderColor3 = SeaConfigs.BorderColor
	PlayerFrame.BorderSizePixel = 2
	PlayerFrame.Position = UDim2.new(0.05, 0, 0.28, 0)
	PlayerFrame.Size = UDim2.new(0.4, 0, 0.65, 0)

	PlayerTitle.Name = "PlayerTitle"
	PlayerTitle.Parent = PlayerFrame
	PlayerTitle.BackgroundTransparency = 1
	PlayerTitle.Position = UDim2.new(0, 0, 0.02, 0)
	PlayerTitle.Size = UDim2.new(1, 0, 0, 35)
	PlayerTitle.Font = Enum.Font.SourceSansBold
	PlayerTitle.Text = "Player Information"
	PlayerTitle.TextColor3 = SeaConfigs.SubTitleColor
	PlayerTitle.TextSize = 24

	local PlayerLine = Instance.new("Frame")
	PlayerLine.Name = "PlayerLine"
	PlayerLine.Parent = PlayerFrame
	PlayerLine.BackgroundColor3 = SeaConfigs.BorderColor
	PlayerLine.BorderSizePixel = 0
	PlayerLine.Position = UDim2.new(0.05, 0, 0.12, 0)
	PlayerLine.Size = UDim2.new(0.9, 0, 0, 2)

	GameFrame.Name = "GameFrame"
	GameFrame.Parent = MainFrame
	GameFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	GameFrame.BorderColor3 = SeaConfigs.BorderColor
	GameFrame.BorderSizePixel = 2
	GameFrame.Position = UDim2.new(0.55, 0, 0.28, 0)
	GameFrame.Size = UDim2.new(0.4, 0, 0.65, 0)

	GameTitle.Name = "GameTitle"
	GameTitle.Parent = GameFrame
	GameTitle.BackgroundTransparency = 1
	GameTitle.Position = UDim2.new(0, 0, 0.02, 0)
	GameTitle.Size = UDim2.new(1, 0, 0, 35)
	GameTitle.Font = Enum.Font.SourceSansBold
	GameTitle.Text = "Game Information"
	GameTitle.TextColor3 = SeaConfigs.SubTitleColor
	GameTitle.TextSize = 24

	local GameLine = Instance.new("Frame")
	GameLine.Name = "GameLine"
	GameLine.Parent = GameFrame
	GameLine.BackgroundColor3 = SeaConfigs.BorderColor
	GameLine.BorderSizePixel = 0
	GameLine.Position = UDim2.new(0.05, 0, 0.12, 0)
	GameLine.Size = UDim2.new(0.9, 0, 0, 2)

	function createInfoLabels(frame, infoTable, startY)
		local yOffset = startY or 0.15
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local isSmallScreen = viewportSize.X < 1200 or viewportSize.Y < 700
		
		local totalItems = #infoTable
		
		local maxRowsPerColumn, columnThreshold
		if isSmallScreen then
			maxRowsPerColumn = 5
			columnThreshold = 6
		else
			maxRowsPerColumn = 6
			columnThreshold = 7 
		end
		
		local columnsNeeded = 1
		if totalItems >= columnThreshold then
			columnsNeeded = math.ceil(totalItems / maxRowsPerColumn)
		end
		
		local columnWidth = 1 / columnsNeeded
		local spacing = isSmallScreen and 0.13 or 0.10
		
		for _, child in pairs(frame:GetChildren()) do
			if child.Name == "ColumnDivider" then
				child:Destroy()
			end
		end
		
		if columnsNeeded > 1 then
			for i = 1, columnsNeeded - 1 do
				local divider = Instance.new("Frame")
				divider.Name = "ColumnDivider"
				divider.Parent = frame
				divider.BackgroundColor3 = SeaConfigs.BorderColor
				divider.BorderSizePixel = 0
				divider.Position = UDim2.new(i * columnWidth - 0.005, 0, yOffset - 0.02, 0)
				divider.Size = UDim2.new(0, 1, 0.8, 0)
			end
		end
		
		for index, item in ipairs(infoTable) do
			local key = item.key
			local value = item.value
			
			local currentColumn = math.floor((index - 1) / maxRowsPerColumn)
			local rowInColumn = (index - 1) % maxRowsPerColumn
			
			local label = Instance.new("TextLabel")
			label.Name = key .. "Label"
			label.Parent = frame
			label.BackgroundTransparency = 1
			
			local xPosition, xSize
			if columnsNeeded == 1 then
				xPosition = 0.02
				xSize = 0.96
			else
				xPosition = currentColumn * columnWidth
				xSize = columnWidth - 0.04
				xPosition = xPosition + 0.02
			end
			
			label.Position = UDim2.new(xPosition, 0, yOffset + (rowInColumn * spacing), 0)
			label.Size = UDim2.new(xSize, 0, 0, isSmallScreen and 22 or 28)
			label.Font = Enum.Font.SourceSansBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextWrapped = true
			label.TextTruncate = Enum.TextTruncate.AtEnd
			
			local textColor = SeaConfigs.TextColor 
			local keyLower = key:lower()
			
			for colorKey, color in pairs(SeaConfigs.ColorMapping) do
				if keyLower:find(colorKey) then
					textColor = color
					break
				end
			end
			
			label.TextColor3 = textColor
			
			local fontSize
			if columnsNeeded >= 3 then
				fontSize = isSmallScreen and 16 or 20
			elseif columnsNeeded == 2 then
				fontSize = isSmallScreen and 18 or 22
			else
				fontSize = isSmallScreen and 20 or 24
			end
			
			label.TextSize = fontSize
			label.Text = tostring(value)
		end
	end

	function recreateLabels()
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local isSmallScreen = viewportSize.X < 1200 or viewportSize.Y < 700
		
		for _, child in pairs(PlayerFrame:GetChildren()) do
			if (child:IsA("TextLabel") and child.Name ~= "PlayerTitle") or child.Name == "ColumnDivider" then
				child:Destroy()
			end
		end
		
		for _, child in pairs(GameFrame:GetChildren()) do
			if (child:IsA("TextLabel") and child.Name ~= "GameTitle") or child.Name == "ColumnDivider" then
				child:Destroy()
			end
		end
		
		local startY = isSmallScreen and 0.22 or 0.18
		createInfoLabels(PlayerFrame, SeaConfigs.PlayerInfo, startY)
		createInfoLabels(GameFrame, SeaConfigs.GameInfo, startY)
	end

	function updateLayoutAndLabels()
		updateLayout()
		recreateLabels()
	end

	createInfoLabels(PlayerFrame, SeaConfigs.PlayerInfo, 0.18)
	createInfoLabels(GameFrame, SeaConfigs.GameInfo, 0.18)

	updateLayout()

	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayoutAndLabels)

	local startTime = os.time()
	function updateTime()
		if SeaConfigs.ShowTime and TimeLabel then
			local elapsedTime = os.time() - startTime
			local hours = math.floor(elapsedTime / 3600)
			local minutes = math.floor((elapsedTime % 3600) / 60)
			local seconds = elapsedTime % 60
			
			TimeLabel.Text = string.format("Time: %02d:%02d:%02d", hours, minutes, seconds)
		end
	end
	local idMapping = {
		["Account"]    = { category = "Player", key = "Username" },
		["Stats1"]     = { category = "Player", key = "Coins" },
		["Stats2"]     = { category = "Player", key = "Planting" },
		["Pets"]       = { category = "Player", key = "Pets" },
		["MaxSlots"]   = { category = "Player", key = "Max Slots" },
		["Expansion"]  = { category = "Player", key = "Expansion" },
		["Status"]     = { category = "Game",   key = "Status" },
	}

	function UpdateUIInfo(id, text)
		Title.Text = "Status: " .. tostring(env.DiscordLink)
		updateTime()

		if id == "Uptime" then
			if SeaConfigs.ShowTime and TimeLabel then
				TimeLabel.Text = tostring(text)
			end
			return
		end

		local mapping = idMapping[id]
		if not mapping then return end

		local category = mapping.category
		local key = mapping.key
		local infoTable
		if category == "Player" then
			infoTable = SeaConfigs.PlayerInfo
		elseif category == "Game" then
			infoTable = SeaConfigs.GameInfo
		end

		if infoTable then
			for _, item in ipairs(infoTable) do
				if item.key == key then
					item.value = text
					break
				end
			end
		end
		local frame = (category == "Player") and PlayerFrame or GameFrame
		local label = frame:FindFirstChild(key .. "Label")
		if label then
			label.Text = tostring(text)
		end
	end

	env.UpdateUIInfo = UpdateUIInfo
end

Trackstack()
