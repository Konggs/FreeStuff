local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

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
end

local function GetServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
    if cursor and cursor ~= "" then url ..= "&cursor=" .. cursor end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and result and result.data then
        return result
    end
end

local function TPReturner()
    if #currentServers == 0 or serverIndex > #currentServers then
        local servers = GetServers(foundAnything)
        if not servers then return end
        foundAnything = servers.nextPageCursor or ""
        currentServers = {}
        for _, v in ipairs(servers.data) do
            local age = tonumber(v.age) or 0
            if age >= 1200 then
                table.insert(currentServers, v)
            end
        end
        if #currentServers == 0 then
            currentServers = servers.data
        end
        serverIndex = 1
    end
    local v = currentServers[serverIndex]
    serverIndex += 1
    if not v then return end
    local id = tostring(v.id)
    for _, existing in ipairs(AllIDs) do
        if id == tostring(existing) then
            return
        end
    end
    table.insert(AllIDs, id)
    pcall(function()
        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
    end)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, id, game.Players.LocalPlayer)
    task.wait(3)
end

while task.wait(1) do
    pcall(TPReturner)
end
