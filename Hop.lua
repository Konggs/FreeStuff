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

local function RefreshServerList(PlaceID)
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
            task.wait(3)
            break
        end
        local Site = HttpService:JSONDecode(Ret)
        if Site and Site.data then 
            for _,v in pairs(Site.data) do 
                local createdUnix = v.created and ToUnix(v.created) or os.time()
                local age = os.time() - createdUnix
                local serverPing = v.ping or 9999
                table.insert(ListSite, {
                    id = v.id,
                    playing = v.playing or 0,
                    ping = serverPing,
                    age = age
                })
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
            local scoreA = (a.age >= 20*60 and 1 or 0) * 10000 - a.ping - a.playing
            local scoreB = (b.age >= 20*60 and 1 or 0) * 10000 - b.ping - b.playing
            return scoreA > scoreB
        end)
        FileLockLib.SaveFile("HopServerData.json",ListSite)
        return ListSite
    end
    return {}
end

local function PickNewServer(PlaceID, FailCount)
    local Data,NeedUpdateData = FileLockLib.ReadFile("HopServerData.json")
    if NeedUpdateData or #Data == 0 or FailCount >= 10 then
        Data = RefreshServerList(PlaceID)
        FailCount = 0
        print("[AutoHopServer] Server list refreshed. Found "..tostring(#Data).." servers.")
    end
    if #Data == 0 then return nil, FailCount end

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
            return entry, FailCount
        end
    end
    return nil, FailCount
end

local PlaceID = game.PlaceId
local CurrentJobId = game.JobId
local FailCount = 0

print("[AutoHopServer] Starting server hop process...")

while true do
    local Entry; Entry, FailCount = PickNewServer(PlaceID, FailCount)
    if Entry then
        local AgeMin = math.floor((Entry.age or 0) / 60)
        print(string.format("[AutoHopServer] Attempting server: %s | Players: %d | Ping: %dms | Age: %dm", Entry.id, Entry.playing, Entry.ping, AgeMin))
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceID, Entry.id, Player)
        end)
        if not success then
            FailCount = FailCount + 1
            warn("[AutoHopServer] Teleport failed: ".. tostring(err))
            task.wait(2)
        end
    else
        warn("[AutoHopServer] No valid server found. Retrying...")
        task.wait(3)
    end
    task.wait(5)
    if game.JobId ~= CurrentJobId then
        print("[AutoHopServer] Successfully hopped to new server:", game.JobId)
        break
    end
end
