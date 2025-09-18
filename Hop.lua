local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = game.Players.LocalPlayer
local AllIDs, ServerCache, CacheCursor = {}, {}, ""
local actualHour = os.date("!*t").hour
local serverIndex = 1
pcall(function()
    local data = HttpService:JSONDecode(readfile("ServerCache.json"))
    if type(data) == "table" and data.hour == actualHour then
        ServerCache = data.servers or {}
        CacheCursor = data.cursor or ""
        print("[DEBUG] Loaded cached servers:", #ServerCache)
    end
end)
local function SaveCache()
    local data = {
        hour = actualHour,
        servers = ServerCache,
        cursor = CacheCursor
    }
    pcall(function()
        writefile("ServerCache.json", HttpService:JSONEncode(data))
    end)
end
local function GetServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
    if cursor and cursor ~= "" then url ..= "&cursor=" .. cursor end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and result and result.data then
        print("[DEBUG] Fetched", #result.data, "servers")
        return result
    else
        warn("[DEBUG] Failed to fetch servers")
    end
end
local function RefreshCache()
    local result = GetServers(CacheCursor)
    if not result then return end
    CacheCursor = result.nextPageCursor or ""
    ServerCache = result.data or {}
    SaveCache()
    serverIndex = 1
    print("[DEBUG] Refreshed cache:", #ServerCache)
end
local function TPReturner()
    if serverIndex > #ServerCache or (#ServerCache - serverIndex) < 50 then
        RefreshCache()
    end
    local v = ServerCache[serverIndex]
    serverIndex += 1
    if not v then return end
    local id = tostring(v.id)
    local playing, maxPlayers = tonumber(v.playing) or 0, tonumber(v.maxPlayers) or 0
    for _, existing in ipairs(AllIDs) do
        if id == existing then
            print("[DEBUG] Skipping duplicate:", id)
            return
        end
    end
    table.insert(AllIDs, id)
    print(("[DEBUG] Teleporting to server %s | %d/%d players"):format(id, playing, maxPlayers))
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
