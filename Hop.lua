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
    pcall(function()
        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
    end)
    print("[DEBUG] Reset server list for new hour:", actualHour)
else
    print("[DEBUG] Loaded server list for hour:", actualHour)
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
        print("[DEBUG] Failed to fetch servers")
    end
end

local function TPReturner()
    if #currentServers == 0 or serverIndex > #currentServers then
        local servers = GetServers(foundAnything)
        if not servers then return end
        foundAnything = servers.nextPageCursor or ""
        currentServers, serverIndex = {}, 1
        for _, v in ipairs(servers.data) do
            local id, age = tostring(v.id), tonumber(v.age) or 0
            local duplicate = false
            for _, existing in ipairs(AllIDs) do
                if id == tostring(existing) then
                    duplicate = true
                    break
                end
            end
            if not duplicate and (age >= 1200) then
                table.insert(currentServers, v)
            end
        end
        if #currentServers == 0 then
            print("[DEBUG] No server with age >= 20m, fallback to all")
            currentServers = servers.data
        else
            print("[DEBUG] Found", #currentServers, "servers with age >= 20m")
        end
    end

    local v = currentServers[serverIndex]
    serverIndex += 1
    if not v then return end

    local id, age = tostring(v.id), tonumber(v.age) or 0
    for _, existing in ipairs(AllIDs) do
        if id == tostring(existing) then
            print("[DEBUG] Skipping duplicate ID:", id)
            return
        end
    end

    print("[DEBUG] Teleporting to server:", id, " Age:", age, "s")
    table.insert(AllIDs, id)
    pcall(function()
        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
    end)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, id, Player)
    task.wait(2)
end

while task.wait(1) do
    pcall(TPReturner)
end
