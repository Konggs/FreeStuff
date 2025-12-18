local PlaceID = game.PlaceId local AllIDs = {} local foundAnything = "" local actualHour = os.date("!*t").hour local Deleted = false
local HttpService = game:GetService("HttpService") local TeleportService = game:GetService("TeleportService") local Players = game:GetService("Players")
local FailCount = 0 local MaxFail = 5
local File = pcall(function() AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json")) end)
if not File then table.insert(AllIDs,actualHour) writefile("NotSameServers.json",HttpService:JSONEncode(AllIDs)) end
function TPReturner()
    local Site
    if foundAnything == "" then Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"))
    else Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100&cursor="..foundAnything)) end
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" then foundAnything = Site.nextPageCursor end
    local num = 0
    for i,v in pairs(Site.data) do
        local Possible = true local ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) and tonumber(v.playing) >= 1 then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then if ID == tostring(Existing) then Possible = false end
                else if tonumber(actualHour) ~= tonumber(Existing) then pcall(function() delfile("NotSameServers.json") AllIDs = {} table.insert(AllIDs,actualHour) end) end end
                num = num + 1
            end
            if Possible then
                table.insert(AllIDs,ID)
                local ok = pcall(function() writefile("NotSameServers.json",HttpService:JSONEncode(AllIDs)) TeleportService:TeleportToPlaceInstance(PlaceID,ID,Players.LocalPlayer) end)
                if ok then FailCount = 0 else FailCount = FailCount + 1 end
                if FailCount >= MaxFail then TeleportService:Teleport(PlaceID) end
                task.wait(4)
            end
        end
    end
end
while task.wait(1) do pcall(function() TPReturner() if foundAnything ~= "" then TPReturner() end end) end
