local PlaceID=game.PlaceId
local HttpService,TeleportService,Players=game:GetService("HttpService"),game:GetService("TeleportService"),game:GetService("Players")
local FOLDER="YuukiHubServerHop" if not isfolder(FOLDER) then makefolder(FOLDER) end
local function GetFiles() local t={} for _,f in ipairs(listfiles(FOLDER)) do if f:find(".json") then t[#t+1]=f end end return t end
local function LoadFile(p) local ok,d=pcall(function() return HttpService:JSONDecode(readfile(p)) end) return ok and d or {} end
local function SaveFile(p,d) writefile(p,HttpService:JSONEncode(d)) end
local function Fetch()
    local cursor,index,page="",os.time(),0
    repeat
        page+=1
        local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Desc&limit=100"..(cursor~="" and "&cursor="..cursor or "")
        local ok,res=pcall(function() return game:HttpGet(url) end) if not ok then return end
        local dec=HttpService:JSONDecode(res) if dec.errors then return end
        local list={}
        for _,v in pairs(dec.data or {}) do if v.playing >= 22 and v.playing < v.maxPlayers then list[#list+1]=v.id end end
        print("page:",page,"servers:",#list)
        if #list>0 then SaveFile(FOLDER.."/"..index..".json",list) index+=1 end
        cursor=dec.nextPageCursor or "" task.wait(0.3)
    until cursor=="" or page>=5
end
local function GetRandomServer()
    local files=GetFiles() if #files==0 then return end
    local data=LoadFile(files[math.random(#files)]) if #data==0 then delfile(files[1]) return end
    return data[math.random(#data)]
end
local function CountServers() local n=0 for _,f in ipairs(GetFiles()) do n+=#LoadFile(f) end return n end
local function Clean() for _,f in ipairs(GetFiles()) do if #LoadFile(f)==0 then delfile(f) end end end
while task.wait(2) do
    pcall(function()
        Clean()
        if CountServers()<20 then Fetch() end
        local id=GetRandomServer()
        if id then TeleportService:TeleportToPlaceInstance(PlaceID,id,Players.LocalPlayer) else TeleportService:Teleport(PlaceID) end
    end)
end
