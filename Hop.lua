local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local actualHour = os.date("!*t").hour
local AllIDs, AllIDsSet, currentServers = {}, {}, {}
local foundCursor, serverIndex = "", 1
local isTeleporting = false
local rejoinTimerStarted = false
local lastRetry = 0
local function safeRead(path)
    local ok, content = pcall(readfile, path)
    if not ok or not content then return nil end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 then return nil end
    return decoded
end
local function safeWrite(path, obj) pcall(function() writefile(path, HttpService:JSONEncode(obj)) end) end
local function loadAllIDs()
    local data = safeRead("NotSameServers.json")
    if type(data) ~= "table" or data[1] ~= actualHour then
        AllIDs = {actualHour}
        AllIDsSet = {}
        safeWrite("NotSameServers.json", AllIDs)
        return
    end
    AllIDs = data
    AllIDsSet = {}
    for i = 2, #AllIDs do AllIDsSet[tostring(AllIDs[i])] = true end
end
local function loadServerCache()
    local data = safeRead("ServerCache.json")
    if type(data) == "table" then currentServers = data else currentServers = {} end
    serverIndex = 1
end
loadAllIDs()
loadServerCache()
local function trimAllIDs(limit)
    limit = limit or 5000
    if #AllIDs <= limit + 1 then return end
    local keep = {AllIDs[1]}
    local startIdx = #AllIDs - limit + 1
    for i = startIdx, #AllIDs do table.insert(keep, AllIDs[i]) end
    AllIDs = keep
    AllIDsSet = {}
    for i = 2, #AllIDs do AllIDsSet[tostring(AllIDs[i])] = true end
    safeWrite("NotSameServers.json", AllIDs)
end
local function sanitizeCurrentServers()
    if serverIndex > 200 then
        local newTbl = {}
        for i = serverIndex, #currentServers do table.insert(newTbl, currentServers[i]) end
        currentServers = newTbl
        serverIndex = 1
        safeWrite("ServerCache.json", currentServers)
    end
end
local function httpGetJson(url, retries)
    retries = retries or 3
    local backoff = 0.2
    for i = 1, retries do
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res then local ok2, decoded = pcall(function() return HttpService:JSONDecode(res) end) if ok2 and decoded then return decoded end end
        task.wait(backoff)
        backoff = math.min(2, backoff * 2)
    end
    return nil
end
local function addServerToCache(v) if not v or not v.id then return end table.insert(currentServers, v) end
local function GetServers(cursor)
    local loops = 0
    while loops < 6 do
        loops += 1
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
        if cursor and cursor ~= "" then url ..= "&cursor=" .. cursor end
        local result = httpGetJson(url, 3)
        if not result or type(result) ~= "table" or not result.data then break end
        foundCursor = result.nextPageCursor or ""
        for _, v in ipairs(result.data) do
            local id = tostring(v.id)
            local playing, maxPlayers = tonumber(v.playing) or 0, tonumber(v.maxPlayers) or 0
            if id ~= tostring(game.JobId) and not AllIDsSet[id] and playing <= maxPlayers - 2 then
                addServerToCache(v)
            end
        end
        safeWrite("ServerCache.json", currentServers)
        if foundCursor == "" then break end
        cursor = foundCursor
        if #currentServers > 300 then break end
    end
end
local function EnsureServerCache() if #currentServers - serverIndex < 50 then GetServers(foundCursor ~= "" and foundCursor or "") end end
local function saveAllIDsIfNeeded() pcall(function() safeWrite("NotSameServers.json", AllIDs) end) end
local function TPReturner()
    if isTeleporting then return end
    isTeleporting = true
    if not rejoinTimerStarted then
        rejoinTimerStarted = true
        task.delay(60, function() pcall(function() TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer) end) end)
    end
    while true do
        EnsureServerCache()
        local v = currentServers[serverIndex]
        if not v then
            if foundCursor ~= "" then
                GetServers(foundCursor)
                task.wait(0.2)
                v = currentServers[serverIndex]
            end
            if not v then break end
        end
        serverIndex += 1
        local id = tostring(v.id)
        if AllIDsSet[id] then sanitizeCurrentServers() continue end
        AllIDsSet[id] = true
        table.insert(AllIDs, id)
        trimAllIDs(5000)
        saveAllIDsIfNeeded()
        local ok, err = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, id, game.Players.LocalPlayer) end)
        if ok then return end
        sanitizeCurrentServers()
        task.wait(0.15)
    end
    task.spawn(function()
        task.wait(1)
        serverIndex = 1
        currentServers = {}
        foundCursor = ""
        GetServers("")
        isTeleporting = false
    end)
end
TeleportService.TeleportInitFailed:Connect(function()
    local now = tick()
    if now - lastRetry < 5 then return end
    lastRetry = now
    task.spawn(function() TPReturner() end)
end)
task.spawn(function() TPReturner() end)
task.spawn(function()
    while task.wait(10) do
        sanitizeCurrentServers()
        trimAllIDs(5000)
        safeWrite("ServerCache.json", currentServers)
        safeWrite("NotSameServers.json", AllIDs)
    end
end)
