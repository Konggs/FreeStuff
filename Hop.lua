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
local function PickNewServer(PlaceID)
    FileLockLib.SetupFile("HopServerData.json",{},2*60)
    local Data,NeedUpdateData = FileLockLib.ReadFile("HopServerData.json")
    if NeedUpdateData or #Data == 0 then
        local ListSite, Cursor = {}, ""
        for i = 1,3 do 
            local Url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
            if Cursor ~= "" then 
                Url = Url .. "&cursor=" .. Cursor
            end
            local Success, Ret = pcall(function()
                return game:HttpGet(Url)
            end)
            if not Success then
                warn("[AutoHopServer] Failed to fetch server list. Retrying...")
                task.wait(5)
                break
            end
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
            print("[AutoHopServer] Server list refreshed. Found "..tostring(#ListSite).." servers.")
        else
            warn("[AutoHopServer] Unable to retrieve a valid server list.")
            return nil
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
        local Candidate = Data[r]
        if not ServerIdJoined[Candidate] then 
            Site = Candidate
        end
        c = c + 1
        if c % 100 == 0 then task.wait() end
    end
    if not Site then
        warn("[AutoHopServer] Could not find a suitable server to join.")
        return nil
    end
    ServerIdJoined[Site] = tick()
    writefile("ServerIdJoined.json",HttpService:JSONEncode(ServerIdJoined))
    return Site
end
function AutoHopServer()
    local PlaceID = game.PlaceId
    local CurrentJobId = game.JobId
    print("[AutoHopServer] Starting server hop process...")
    while true do
        local Site = PickNewServer(PlaceID)
        if Site then
            print("[AutoHopServer] Attempting to join server:", Site)
            TeleportService:TeleportToPlaceInstance(PlaceID, Site, Player)
        else
            warn("[AutoHopServer] No server available, retrying...")
        end
        task.wait(5)
        if game.JobId ~= CurrentJobId then
            print("[AutoHopServer] Successfully hopped to a new server:", game.JobId)
            break
        end
    end
end

AutoHopServer()
