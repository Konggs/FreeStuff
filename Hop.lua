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

local function ToUnix(timeStr)
    local y,m,d,H,M,S = timeStr:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
    return os.time({year=y, month=m, day=d, hour=H, min=M, sec=S})
end

local function PickNewServer(PlaceID)
    FileLockLib.SetupFile("HopServerData.json",{},2*60)
    local Data,NeedUpdateData = FileLockLib.ReadFile("HopServerData.json")
    if NeedUpdateData or #Data == 0 then
        local ListSite, Cursor = {}, ""
        for i = 1,3 do 
            local Url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
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
                    if v.created then
                        local createdUnix = ToUnix(v.created)
                        local age = os.time() - createdUnix
                        local serverPing = v.ping or 9999
                        if age >= 20 * 60 and serverPing <= 150 then
                            table.insert(ListSite, {id=v.id, playing=v.playing, ping=serverPing})
                        end
                    end
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
            table.sort(ListSite, function(a,b)
                if a.playing == b.playing then
                    return a.ping < b.ping
                else
                    return a.playing < b.playing
                end
            end)
            FileLockLib.SaveFile("HopServerData.json",ListSite)
            Data = ListSite
            print("[AutoHopServer] Server list refreshed. Found "..tostring(#ListSite).." valid servers.")
        else
            warn("[AutoHopServer] No valid servers (age >20min & ping <=150ms).")
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
    for _,entry in ipairs(Data) do
        local id = entry.id or entry
        if not ServerIdJoined[id] then
            ServerIdJoined[id] = tick()
            writefile("ServerIdJoined.json",HttpService:JSONEncode(ServerIdJoined))
            return id, entry.playing, entry.ping
        end
    end
    warn("[AutoHopServer] Could not find a suitable server to join.")
    return nil
end

local PlaceID = game.PlaceId
local CurrentJobId = game.JobId
print("[AutoHopServer] Starting server hop process...")
while true do
    local Site, Players, Ping = PickNewServer(PlaceID)
    if Site then
        print(string.format("[AutoHopServer] Attempting to join server: %s | Players: %d | Ping: %dms", Site, Players or -1, Ping or -1))
        TeleportService:TeleportToPlaceInstance(PlaceID, Site, Player)
    else
        warn("[AutoHopServer] No valid server found. Retrying...")
    end
    task.wait(5)
    if game.JobId ~= CurrentJobId then
        print("[AutoHopServer] Successfully hopped to a new server:", game.JobId)
        break
    end
end
