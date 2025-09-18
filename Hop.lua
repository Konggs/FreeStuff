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
    print("[DEBUG] Reset NotSameServers for new hour:", actualHour)
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
    if cursor and cursor ~= "" then
        url ..= "&cursor=" .. cursor
    end
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if success and result and result.data then
        print("[DEBUG] Fetched", #result.data, "servers")
        return result
    else
        print("[DEBUG] Failed to fetch servers")
    end
end

local function EnsureServerCache()
    if #currentServers - serverIndex < 50 then
        local servers = GetServers(foundAnything)
        if servers then
            foundAnything = servers.nextPageCursor or ""
            for _, v in ipairs(servers.data) do
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
            print("[DEBUG] Cache updated, total:", #currentServers)
        end
    end
end

local function TPReturner()
    EnsureServerCache()
    local v = currentServers[serverIndex]
    if not v then
        print("[DEBUG] No server to teleport")
        return
    end
    serverIndex += 1
    local id = tostring(v.id)
    local playing, maxPlayers = tonumber(v.playing) or 0, tonumber(v.maxPlayers) or 0
    for _, existing in ipairs(AllIDs) do
        if id == tostring(existing) then
            print("[DEBUG] Skipping duplicate ID:", id)
            return
        end
    end
    print(("[DEBUG] Teleporting to server %s | Players: %d/%d"):format(id, playing, maxPlayers))
    table.insert(AllIDs, id)
    pcall(function() writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs)) end)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, id, Player)
    task.wait(2)
end

TeleportService.TeleportInitFailed:Connect(function(_, result, reason)
    warn("[DEBUG] Teleport failed:", result, reason)
    task.wait(0.5)
    TPReturner()
end)

while task.wait(1) do
    pcall(TPReturner)
end
