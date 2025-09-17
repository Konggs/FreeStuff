local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = game.Players.LocalPlayer

local RATE_MAX = 40
local RATE_PERIOD = 60
local requestTimestamps = {}

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

local function toUnix(str)
    local y,m,d,H,M,S = str:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
    return os.time({year=y,month=m,day=d,hour=H,min=M,sec=S})
end

local function enforceRateLimit()
    local now = tick()
    while true do
        for i = #requestTimestamps, 1, -1 do
            if now - requestTimestamps[i] > RATE_PERIOD then
                table.remove(requestTimestamps, i)
            end
        end
        if #requestTimestamps < RATE_MAX then
            table.insert(requestTimestamps, now)
            return
        end
        local oldest = requestTimestamps[1] or now
        local waitTime = RATE_PERIOD - (now - oldest) + (math.random() * 0.2)
        task.wait(math.max(0.3, waitTime))
        now = tick()
    end
end

local function safeHttpGet(url)
    local retries, backoff = 0, 0.5
    while retries < 4 do
        enforceRateLimit()
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if ok and body and #body > 0 then
            return true, body
        end
        retries = retries + 1
        task.wait(backoff + math.random() * 0.25)
        backoff = math.min(4, backoff * 2 + 0.5)
    end
    return false, "HttpGet failed after retries"
end

local function fetchServers(placeId)
    local cached = readFile("HopServerData.json", {})
    local servers, cursor = {}, ""
    local maxPages = 5
    for _ = 1, maxPages do
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=false"):format(placeId)
        if cursor ~= "" then url ..= "&cursor="..cursor end
        local ok, body = safeHttpGet(url)
        if not ok then
            warn("[AutoHopServer] fetch page failed, keeping cache")
            return cached
        end
        local success, site = pcall(function() return HttpService:JSONDecode(body) end)
        if not success or not site then
            warn("[AutoHopServer] invalid json, keeping cache")
            return cached
        end
        for _,v in ipairs(site.data or {}) do
            local ping = tonumber(v.ping) or 9999
            if ping < 500 then
                local created = v.created and toUnix(v.created) or os.time()
                table.insert(servers, {
                    id = v.id,
                    playing = tonumber(v.playing) or 0,
                    ping = ping,
                    age = os.time() - created
                })
            end
        end
        cursor = site.nextPageCursor or ""
        if cursor == "" then break end
        task.wait(0.4 + math.random() * 0.15)
    end
    if #servers == 0 then
        if #cached > 0 then
            warn("[AutoHopServer] fetched 0 servers, returning cache")
            return cached
        end
        warn("[AutoHopServer] fetched 0 servers and cache empty")
        return {}
    end
    table.sort(servers, function(a,b)
        local scoreA = (a.age>=1200 and 1 or 0)*1e5 - a.ping - a.playing
        local scoreB = (b.age>=1200 and 1 or 0)*1e5 - b.ping - b.playing
        return scoreA > scoreB
    end)
    writeFile("HopServerData.json", servers)
    return servers
end

local function pickServer(placeId, failCount)
    local servers = fetchServers(placeId)
    if not servers or #servers == 0 then
        warn("[AutoHopServer] no servers available from fetch")
        return nil
    end
    local joined = readFile("ServerIdJoined.json", {})
    for id,t in pairs(joined) do if tick()-t>2400 then joined[id]=nil end end
    for _,s in ipairs(servers) do
        if s.ping and s.ping < 500 and not joined[s.id] then
            joined[s.id] = tick()
            writeFile("ServerIdJoined.json", joined)
            return s
        end
    end
    return nil
end

local function attemptTeleport(placeId, sid)
    local ok, err = pcall(function() TeleportService:TeleportToPlaceInstance(placeId, sid, Player) end)
    if ok then return true end
    local msg = tostring(err or "")
    if string.find(msg, "GameFull") or string.find(msg, "Requested experience is full") then
        return false, "GameFull"
    end
    return false, msg
end

local placeId, jobId, fails = game.PlaceId, game.JobId, 0
print("[AutoHopServer] Starting server hop...")

while task.wait(0.5) do
    local s = pickServer(placeId, fails)
    if s then
        local sid, players, ping = tostring(s.id), tonumber(s.playing) or -1, tonumber(s.ping) or -1
        local ageMin = math.floor((s.age or 0)/60)
        print(("[AutoHopServer] Attempting server %s | Players: %d | Ping: %dms | Age: %dm"):format(sid, players, ping, ageMin))
        local ok, err = attemptTeleport(placeId, sid)
        if ok then
            print("[AutoHopServer] Teleport initiated to", sid)
            break
        else
            fails = fails + 1
            if err == "GameFull" then
                warn("[AutoHopServer] Server full, removing from cache:", sid)
                local servers = readFile("HopServerData.json", {})
                for i,v in ipairs(servers) do if v.id == sid then table.remove(servers, i); break end end
                writeFile("HopServerData.json", servers)
            else
                warn("[AutoHopServer] Teleport failed:", tostring(err))
            end
            task.wait(1 + math.random() * 0.6)
        end
    else
        fails = fails + 1
        warn("[AutoHopServer] No valid server. Will retry after delay.")
        task.wait(3 + math.random() * 1.2)
    end
    if fails >= 8 then
        fails = 0
        task.wait(6 + math.random() * 2)
    end
    if game.JobId ~= jobId then
        print("[AutoHopServer] Hopped successfully to new server:", game.JobId)
        break
    end
end
