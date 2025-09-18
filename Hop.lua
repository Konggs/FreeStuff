local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = game.Players.LocalPlayer

local AllIDs, foundAnything = {}, ""
local actualHour = os.date("!*t").hour
local currentServers, serverIndex = {}, 1

pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
end)
if type(AllIDs) ~= "table" or AllIDs[1] ~= actualHour then
    AllIDs = {actualHour}
    pcall(function() writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs)) end)
else
    print("[DEBUG] Loaded NotSameServers for hour:", actualHour)
end

pcall(function()
    currentServers = HttpService:JSONDecode(readfile("ServerCache.json"))
end)
if type(currentServers) ~= "table" then
    currentServers = {}
end

local function GetServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
    if cursor and cursor ~= "" then url ..= "&cursor=" .. cursor end
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if success and result and result.data then
        foundAnything = result.nextPageCursor or ""
        for _, v in ipairs(result.data) do
            local id = tostring(v.id)
            local playing, maxPlayers = tonumber(v.playing) or 0, tonumber(v.maxPlayers) or 0
            local duplicate = false
            for _, existing in ipairs(AllIDs) do
                if id == tostring(existing) then
                    duplicate = true
                    break
                end
            end
            if not duplicate and playing <= maxPlayers - 2 then
                table.insert(currentServers, v)
            end
        end
        pcall(function() writefile("ServerCache.json", HttpService:JSONEncode(currentServers)) end)
    end
end

local function EnsureServerCache()
    if #currentServers - serverIndex < 50 then
        GetServers(foundAnything)
    end
end

local function TPReturner()
    EnsureServerCache()
    local v = currentServers[serverIndex]
    if not v then return end
    serverIndex += 1
    local id = tostring(v.id)
    for _, existing in ipairs(AllIDs) do
        if id == tostring(existing) then
            table.remove(currentServers, serverIndex - 1)
            pcall(function() writefile("ServerCache.json", HttpService:JSONEncode(currentServers)) end)
            return TPReturner()
        end
    end
    table.insert(AllIDs, id)
    pcall(function() writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs)) end)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, id, Player)
end

TeleportService.TeleportInitFailed:Connect(function()
    task.defer(TPReturner)
end)

task.defer(TPReturner)
