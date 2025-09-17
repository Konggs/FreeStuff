local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local AllIDs, foundAnything = {}, ""
local actualHour = os.date("!*t").hour
local currentServers,serverIndex = {},1
pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
end)
if type(AllIDs) ~= "table" or AllIDs[1] ~= actualHour then
    print("[DEBUG] Resetting server list for new hour: " .. actualHour)
    AllIDs = {actualHour}
    pcall(function()
        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
    end)
else
    print("[DEBUG] Loaded existing server list for this hour.")
end
local function GetServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor and cursor ~= "" then url = url .. "&cursor=" .. cursor end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if not success or not result or not result.data then
        print("[DEBUG] Failed to fetch servers.")
        return nil
    end
    print("[DEBUG] Fetched " .. (#result.data) .. " servers.")
    return result
end
local function TPReturner()
    if #currentServers == 0 or serverIndex > 10 then
        local servers = GetServers(foundAnything)
        if not servers then
            print("[DEBUG] No server data available.")
            return
        end
        foundAnything = servers.nextPageCursor or ""
        table.sort(servers.data, function(a, b)
            return (tonumber(a.ping) or 9999) < (tonumber(b.ping) or 9999)
        end)
        currentServers = servers.data
        serverIndex = 1
    end
    local v = currentServers[serverIndex]
    serverIndex += 1
    if not v then return end
    local ping = tonumber(v.ping) or 9999
    local id = tostring(v.id)
    local duplicate = false
    for _, existing in ipairs(AllIDs) do
        if id == tostring(existing) then
            duplicate = true
            break
        end
    end
    if duplicate then
        print("[DEBUG] Skipping duplicate server ID: " .. id)
    elseif ping >= 500 then
        print("[DEBUG] Skipping high ping server (" .. ping .. " ms) ID: " .. id)
    else
        print("[DEBUG] Teleporting to server ID: " .. id .. " with ping: " .. ping)
        table.insert(AllIDs, id)
        pcall(function()
            writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
        end)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, id, game.Players.LocalPlayer)
        task.wait(4)
    end
end
while task.wait(2) do
    pcall(TPReturner)
end
