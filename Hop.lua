local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local AllIDs, foundAnything = {}, ""
local actualHour = os.date("!*t").hour
pcall(function()
    AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
end)
if type(AllIDs) ~= "table" or AllIDs[1] ~= actualHour then
    AllIDs = {actualHour}
    pcall(function()
        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
    end)
end
local function GetServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then url = url .. "&cursor=" .. cursor end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    return success and result or nil
end
local function TPReturner()
    local servers = GetServers(foundAnything)
    if not servers or not servers.data then return end
    foundAnything = servers.nextPageCursor or ""
    table.sort(servers.data, function(a, b)
        return (tonumber(a.ping) or 9999) < (tonumber(b.ping) or 9999)
    end)
    for _, v in ipairs(servers.data) do
        local ping = tonumber(v.ping) or 9999
        if ping < 500 then
            local id = tostring(v.id)
            local duplicate = false
            for _, existing in ipairs(AllIDs) do
                if id == tostring(existing) then
                    duplicate = true
                    break
                end
            end
            if not duplicate then
                table.insert(AllIDs, id)
                pcall(function()
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                end)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, id, game.Players.LocalPlayer)
                task.wait(4)
            end
        end
    end
end
while task.wait(2) do
    pcall(TPReturner)
end
