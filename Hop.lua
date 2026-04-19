local PlaceID=game.PlaceId;local HttpService,TeleportService,Players=game:GetService("HttpService"),game:GetService("TeleportService"),game:GetService("Players")
local FOLDER="ServerHop";local TIME=FOLDER.."/time.json"
if not isfolder(FOLDER) then makefolder(FOLDER) end
local function GetFiles() local t={}; for _,f in ipairs(listfiles(FOLDER)) do if f:find(".json") and not f:find("time") then t[#t+1]=f end; end; return t end
local function Load(p) local ok,d=pcall(function() return HttpService:JSONDecode(readfile(p)) end) ;return ok and d or {} end
local function Save(p,d) writefile(p,HttpService:JSONEncode(d)) end
local function Last() return isfile(TIME) and (Load(TIME).t or 0) or 0 end
local function Set() Save(TIME,{t=os.time()}) end
local function GetRandom() local f=GetFiles() ;if #f==0 then return end;local d=Load(f[math.random(#f)]) ;if #d==0 then return end ;return d[math.random(#d)] end
local function Fetch()
    local cursor,index,page="",0,0
    local success=false
    repeat page+=1
        local url="https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Desc&limit=100"..(cursor~="" and "&cursor="..cursor or "")
        local ok,res=pcall(function() return game:HttpGet(url) end)
        if not ok then break end ;local dec=HttpService:JSONDecode(res) ;if dec.errors then break end
        local list={} ;for _,v in pairs(dec.data or {}) do if v.playing>=15 and v.playing<v.maxPlayers then list[#list+1]=v.id end end
        print("page:",page,"servers:",#list)
        Save(FOLDER.."/"..index..".json",list)
        index+=1 ;success=true ;cursor=dec.nextPageCursor or "" ;task.wait(0.3)
    until cursor=="" or page>=5
    Set()
end
while task.wait(2) do
    pcall(function()
        if os.time()-Last()>=3600 then Fetch() end ;local id=GetRandom()
        if id then TeleportService:TeleportToPlaceInstance(PlaceID,id,Players.LocalPlayer) else TeleportService:Teleport(PlaceID) end
    end)
end
