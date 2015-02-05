module("utp",package.seeall)

local json=require("cjson")
local redis=require("resty.redis")
local str=require("letv.utils_string")
local tableutils=require("letv.utils_table")

-- utp upgrade api
function upgrade4utp(req,resp,name)
    local locSoVersion=req.uri_args.locSoVersion
    local locSoVersion=tonumber(locSoVersion)
    if not locSoVersion then
      resp:writeln(json.encode({upgradeSo=0}))
      return
    end
    if str.isBlank(req.uri_args.appid) then
      resp:writeln(json.encode({upgradeSo=0}))
      return
    end
    local appId=req.uri_args.appid
    if appId=="0" then
        if "mips"==string.lower(req.uri_args.model) and "mips"==string.lower(req.uri_args.vendor) then
            appId=-2
        else
            appId=-1
        end
    end
    local redis=redis_conn()
    local appKey,err=redis:get("utp_appid:" .. appId .. ":model:" .. 1 ..":appkey:")
    if not appKey then
      resp:writeln(json.encode({upgradeSo=0}))
      return
    end
    local pkgId,err=redis:get("pkg:" .. appKey .. ":id")
    if not pkgId then
      resp:writeln(json.encode({upgradeSo=0}))
      return
    end
    local curVersion=math.floor(locSoVersion/1000) .. "." .. math.floor(locSoVersion/100) .. "." .. (locSoVersion%100)
    local test=require("test")
    local curVersionNo=test.parse_version(curVersion)
    local versionScore=curVersionNo[1]*1000000+curVersionNo[2]*1000+curVersionNo[3]
    local curVersionId,err=redis:get("pkg:" .. pkgId .. ":vno:" .. versionScore)
    local curProfile=2
    if curVersionId then
       local profileStr,err=redis:hmget("ver:" .. curVersionId)
       if profileStr then
          profileStr=tonumber(profileStr[1])
       end
       if profileStr then
         curProfile=profileStr
       end
    end
    local versionTup=false
   if curProfile==2 then
      local versionTuple,err=redis:zrange("pkg:" .. pkgId ..":effVers",-1,-1,"WITHSCORES")
      if versionTuple then
        versionTup=versionTuple
      end
   elseif curProfile==1 then 
      local versionTuple,err=redis:zrange("pkg:" .. pkgId .. ":effTestVers",-1,-1,"WITHSCORES")
      if versionTuple then
        versionTup=versionTuple
      end
   else
      resp:writeln(json.encode({upgradeSo=0}))
      return
    end
    if not versionTup then 
      resp:writeln(json.encode({upgradeSo=0}))
      return
    end 
    if versionScore>=tonumber(versionTup[2]) then
      resp:writeln(json.encode({upgradeSo=0}))
      return 
    end    
    local pkgInf,err=redis:hgetall("pkg:" .. pkgId) 
    if not pkgInf then
      resp:writeln(json.encode({upgradeSo=0}))
      return 
    end 
    local verId=versionTup[1]
    local verInf,err=redis:hgetall("ver:" .. verId)
    if not verInf then
      resp:writeln(json.encode({upgradeSo=0}))
      return
    end    
    -- todo  filter need add 
    local pkgInf=tableutils.array2table(pkgInf)
    local verInf=tableutils.array2table(verInf)
    local res={} 
    res.upgradeSo=1
    res.so={}
    res.so.version=tostring(tonumber(verInf.noF)*1000+tonumber(verInf.noS)*100+tonumber(verInf.noT))
    res.so.file=verInf.upUrl
    res.so.sozipmd5=verInf.upMd5
    res.so.somd5=verInf.utpSoMd5
    res.so.config={}
    res.so.config.cmdlineOptions="cache.max_size=30M&downloader.pre_download_size=10M&enable_keep_alive=off&pp.enable_upnp=on&downloader.urgent_slice_num=3&m3u8_target_duration=3&enable_android_log=off&app_id=2000"
    res.locNewConfig={}
    res.locNewConfig.cmdlineOptions="cache.max_size=30M&downloader.pre_download_size=10M&enable_keep_alive=off&pp.enable_upnp=on&downloader.urgent_slice_num=3&m3u8_target_duration=3&enable_android_log=off&app_id=2000"
    
    resp:writeln(json.encode(res))
end

