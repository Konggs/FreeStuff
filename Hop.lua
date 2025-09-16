local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = game.Players.LocalPlayer
local function readFile(name, default)
    if isfile(name) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(name)) end)
        if ok and data then return data end
    end
    return default
end
local function writeFile(name, data)
    writefile(name, HttpService:JSONEncode(data))
end
local function toUnix(timeStr)
    local y,m,d,H,M,S = timeStr:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
    return os.time({year=y,month=m,day=d,hour=H,min=M,sec=S})
end
local function fetchServers(placeId)
    local servers, cursor = {}, ""
    for _ = 1,3 do
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"):format(placeId)
        if cursor ~= "" then url ..= "&cursor="..cursor end
        local ok, body = pcall(game.HttpGet, game, url)
        if not ok then task.wait(3) break end
        local site = HttpService:JSONDecode(body)
        for _,v in pairs(site.data or {}) do
            local created = v.created and toUnix(v.created) or os.time()
            table.insert(servers, {
                id = v.id,
                playing = v.playing or 0,
                ping = v.ping or 9999,
                age = os.time() - created
            })
        end
        cursor = site.nextPageCursor or ""
        if cursor == "" then break end
        task.wait(1)
    end
    table.sort(servers, function(a,b)
        local scoreA = (a.age>=1200 and 1 or 0)*1e5 - a.ping - a.playing
        local scoreB = (b.age>=1200 and 1 or 0)*1e5 - b.ping - b.playing
        return scoreA > scoreB
    end)
    return servers
end
local function pickServer(placeId, failCount)
    local servers = readFile("HopServerData.json", {})
    if #servers==0 or failCount>=10 then
        servers = fetchServers(placeId)
        writeFile("HopServerData.json", servers)
        print(("[AutoHopServer] Refreshed server list (%d servers)."):format(#servers))
    end
    local joined = readFile("ServerIdJoined.json", {})
    for id,t in pairs(joined) do if tick()-t>2400 then joined[id]=nil end end
    for _,s in ipairs(servers) do
        if not joined[s.id] then
            joined[s.id]=tick()
            writeFile("ServerIdJoined.json", joined)
            return s
        end
    end
end
local placeId, jobId, fails = game.PlaceId, game.JobId, 0
print("[AutoHopServer] Starting server hop...")
while task.wait() do
    local s = pickServer(placeId, fails)
    if s then
        local ageMin = math.floor((s.age or 0)/60)
        local sid, players, ping = tostring(s.id or "Unknown"), tonumber(s.playing) or -1, tonumber(s.ping) or -1
        print(("[AutoHopServer] Attempting server %s | Players: %d | Ping: %dms | Age: %dm"):format(sid,players,ping,ageMin))
        local ok, err = pcall(function() TeleportService:TeleportToPlaceInstance(placeId, sid, Player) end)
        if not ok then
            fails+=1
            warn("[AutoHopServer] Teleport failed: "..tostring(err))
            local servers = readFile("HopServerData.json",{})
            for i,v in ipairs(servers) do if v.id==sid then table.remove(servers,i) break end end
            writeFile("HopServerData.json",servers)
            task.wait(2)
        end
    else
        fails+=1
        warn("[AutoHopServer] No valid server. Retrying...")
        task.wait(3)
    end
    task.wait(5)
    if game.JobId ~= jobId then
        print("[AutoHopServer] Hopped successfully to new server:", game.JobId)
        break
    end
end
