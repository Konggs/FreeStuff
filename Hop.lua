local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = game.Players.LocalPlayer
local FileLockLib = {}
function FileLockLib.SetupFile(name,default,timeout)
    if not isfile(name) then 
        writefile(name,HttpService:JSONEncode(default))
    end
end
function FileLockLib.ReadFile(name)
    if isfile(name) then 
        return HttpService:JSONDecode(readfile(name)), false
    end
    return {}, true
end
function FileLockLib.SaveFile(name,data)
    writefile(name,HttpService:JSONEncode(data))
end
function AutoHopServer()
    local PlaceID = game.PlaceId
    FileLockLib.SetupFile("HopServerData.json",{},2*60)
    local Data,NeedUpdateData = FileLockLib.ReadFile("HopServerData.json")
    if NeedUpdateData or #Data == 0 then
        local ListSite = {}
        local Cursor = ""
        for i = 1,3 do 
            local Url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
            if Cursor ~= "" then 
                Url = Url .. "&cursor=" .. Cursor
            end
            local Ret = game:HttpGet(Url)
            local Site = HttpService:JSONDecode(Ret)
            if Site and Site.data then 
                for _,v in pairs(Site.data) do 
                    table.insert(ListSite,v.id)
                end
            end
            if Site.nextPageCursor and Site.nextPageCursor ~= "null" then
                Cursor = Site.nextPageCursor
            else
                break
            end
            task.wait(1)
        end
        if #ListSite > 0 then
            FileLockLib.SaveFile("HopServerData.json",ListSite)
            Data = ListSite
        else
            warn("Không lấy được server list")
            return
        end
    end
    local ServerIdJoined = {}
    if isfile("ServerIdJoined.json") then 
        ServerIdJoined = HttpService:JSONDecode(readfile("ServerIdJoined.json"))
    end
    for k,v in pairs(ServerIdJoined) do 
        if tick() - v > 60*40 then 
            ServerIdJoined[k] = nil
        end
    end
    local Site
    local c = 0
    while not Site and c < 500 do 
        local r = math.random(1,#Data)
        local Sited = Data[r]
        if not ServerIdJoined[Sited] then 
            Site = Sited
        end
        c = c + 1
        if c % 100 == 0 then task.wait() end
    end
    if not Site then
        warn("Không tìm được server hợp lệ")
        return
    end
    ServerIdJoined[Site] = tick()
    writefile("ServerIdJoined.json",HttpService:JSONEncode(ServerIdJoined))
    TeleportService:TeleportToPlaceInstance(PlaceID, Site, Player)
end
AutoHopServer()
