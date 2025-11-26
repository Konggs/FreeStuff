local PlaceID = 3978370137
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local File = pcall(function() AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json")) end)
if not File then table.insert(AllIDs, actualHour) writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs)) end
function TPReturner()
    local Site
    if foundAnything == "" then
        Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"))
    else
        Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then foundAnything = Site.nextPageCursor end
    local num = 0
    for i, v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) and tonumber(v.playing) >= 1 then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then Possible = false end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then local delFile = pcall( function() delfile("NotSameServers.json") AllIDs = {} table.insert(AllIDs, actualHour) end) end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                task.wait()
                pcall(function() writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs)) task.wait() TeleportService:TeleportToPlaceInstance(PlaceID,ID,game.Players.LocalPlayer)end)
                task.wait(4)
            end
        end
    end
end
while task.wait(1) do pcall(function() TPReturner() if foundAnything ~= "" then TPReturner() end end) end
