#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2012 Appwill Inc.
-- author : ldmiao
--

module("test", package.seeall)

local JSON = require("cjson")
local Redis = require("resty.redis")

function hello(req, resp, name)
    logger:i("hello request started!")
    if req.method=='GET' then
        -- resp:writeln('Host: ' .. req.host)
        -- resp:writeln('Hello, ' .. ngx.unescape_uri(name))
        -- resp:writeln('name, ' .. req.uri_args['name'])
        resp.headers['Content-Type'] = 'application/json'
        resp:writeln(JSON.encode(req.uri_args))

        resp:writeln({{'a','c',{'d','e', {'f'}}},'b'})
    elseif req.method=='POST' then
        -- resp:writeln('POST to Host: ' .. req.host)
        req:read_body()
        resp.headers['Content-Type'] = 'application/json'
        resp:writeln(JSON.encode(req.post_args))
    end
    logger:i("hello request completed!")
end


function longtext(req, resp)
    -- local a = string.rep("xxxxxxxxxx", 10)
    -- resp:writeln(a)
    -- resp:finish()
    local exc_begin = os.time() 
    logger:i("-----"..tostring(exc_begin))
    local red = Redis:new()
    local ok, err = red:connect("10.154.252.153", 6379)
    if not ok then
        resp:writeln({"failed to connect: ", err})
        logger:i({"failed to connect: ", err})
    end

    logger:i("connect redis completed!")
   

    red:set_timeout(30)

    local res_redis = {}
    for i=1,10 do
        local k = "foo"..tostring(i)
        -- red:set(k, "bar"..tostring(i))
        local v = red:get(k)
        ngx.log(ngx.ERR, "i:"..tostring(i), ", v:", v)
        res_redis[k] = v
        
        ngx.sleep(1)
    end
    logger:i("---end--"..(os.time()-exc_begin))
    resp:writeln(JSON.encode(res_redis))
    resp:finish()
    logger:i("---last--"..(os.time()-exc_begin))
end

string.split = function(str, sep)
    local fields = {}
    str:gsub("[^"..sep.."]+", function(c) fields[#fields+1] = c end)
    return fields
end

function getIP(req,resp)
    local exc_begin = os.time() 
    local ip = req.uri_args["ip"]
    logger:i("ip is ----"..ip)
    local ipAry = string.split(ip, "%.");
    local ipLong  = 16777216 * ipAry[1] + 65536 * ipAry[2] + 256 * ipAry[3] + ipAry[4];
    local offset = ipLong % 65536;
    local pageId = (ipLong - offset) / 65536;
    local key_ip_lib = "ip_lib:" .. pageId;
    --[[
    local red = Redis:new()
    local ok, err = red:connect("10.154.252.153", 6379)
    if not ok then
        resp:writeln({"failed to connect: ", err})
        logger:i({"failed to connect: ", err})
    end
    logger:i("connect redis completed!")
    red:set_timeout(30)
    --]]
    local red = redis_conn();
    local startSet, err = red:zrevrangebyscore(key_ip_lib, offset, 0, "limit", 0, 1); 
    local startAry = string.split(startSet[1], ":");

    local key_start = "ip_info:" .. startAry[2];
    local ip_info = red:hmget(key_start, "country", "countryId", "area", "areaId", "region", "regionId", "city", "cityId", "isp", "ispId");

    logger:i("-----post args"..JSON.encode(req.post_args))
    logger:i("-----file args"..JSON.encode(req.upload_data))
    
    local result = {
        code= "A000000",
        data= {
            area= ip_info[3],
            areaId= ip_info[4],
            city= ip_info[7],
            cityId= ip_info[8],
            country= ip_info[1],
            countryId= ip_info[2],
            isp= ip_info[9],
            ispId= ip_info[10],
            region= ip_info[5],
            regionId= ip_info[6]
      },
      message= "OK",
      timestamp= "20141112120224"
}
-- ngx.say(cjson.encode(result));
    resp:writeln(JSON.encode(result))
    resp:finish()
    logger:i("-ip--last--"..(os.time()-exc_begin))

end

function ltp(req, resp)
    resp:ltp("ltp.html", {v="hello, fuhao_ngx_lua!"})
end

function upload(req,resp)
   -- ngx.req.read_body()  
   -- local args = ngx.req.get_post_args() 
   -- local id = args["id"]   -- req:get_post_arg("id","default")
   -- logger:i("upload args is "..id)
   local fn = req.up_data["filename"]
   logger:i("upload fileName is "..fn)
   local fileln = req.up_data["filelen"]
   local file_data = req.up_data["data"]
   resp:writeln(JSON.encode({fn,file_data}))
   resp:finish()
end


function get_mysql_opsystem(req,resp)
   local id = req.uri_args["id"]
   local db= mysql_conn();
   local res, err, errno, sqlstate =  db:query("select * from PS_OPSYSTEM  order by id asc", 10)
   if not res then
        logger:i("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
   end
   resp:writeln(JSON.encode(res))
   resp:finish()
end


function upgrade(req,resp)
    logger:i("-----upgrade1111111111111111----")
    local appkey = req.uri_args["appkey"] 
    local appVersion = req.uri_args["appversion"]   -- "5.0.1" -- req.uri_args["appversion"] 
    local result
    if not appkey or not appVersion or not tonumber(appkey) or string.len(appkey) ~= 20 then
       local default_rt = require("default_json")
       logger:i(JSON.encode(default_rt:param_error()))
       result = default_rt:param_error()
    else 
       logger:i("appkey="..appkey.."  appVersion="..appVersion)
       local red = redis_conn();
       local pkgId, err = red:get("pkg:"..appkey..":id")  
       logger:i("----pkgId----"..type(pkgId))
       if "userdata" == type(pkgId) then
           local default_rt = require("default_json")
           result = default_rt:data_not_found()
       else 
           logger:i("----pkgId----"..pkgId)
           local ret = parse_version(appVersion) -- appVersion
           logger:i(JSON.encode(ret))
           local verScore = ret[1]* 1000 * 1000 + ret[2]* 1000 + ret[3];
           logger:i(verScore) 
           local currentVerId, err = red:get("pkg:"..pkgId..":vno:"..verScore)
           local currentProfile = 2
           if "userdata" ~= type(currentVerId) then
              logger:i("----currentVerId----"..currentVerId)
              local currentProfile_str, err = red:hmget("ver:"..currentVerId,"profile")
              logger:i("----currentProfile_str----"..type(currentProfile_str))
              currentProfile = tonumber(currentProfile_str[1])
              logger:i("---currentProfile -----"..currentProfile )
           end

           local versions = nil
           if 1 == currentProfile then
               local versionTuple,err = red:zrange("pkg:"..pkgId..":effTestVers",-1,-1,"WITHSCORES")
               logger:i("----versionTuple test ----"..JSON.encode(versionTuple))
               versions = versionTuple 
           else
               local versionTuple,err = red:zrange("pkg:"..pkgId..":effVers",-1,-1,"WITHSCORES")
               logger:i("----versionTuple pro ----"..JSON.encode(versionTuple))
               versions = versionTuple 
           end
           logger:i("----versions----"..JSON.encode(versions))
           logger:i("----versions type----"..type(versions))

           if 0 == table.getn(versions) then
               logger:i("----versions getn  nil----")
               local default_rt = require("default_json")
               result = default_rt:data_not_found()
           else 
               if verScore >= tonumber(versions[2]) then
                   local default_rt = require("default_json")
                   result = default_rt:no_update()
               else 
                  local pkgHash_t = red:hgetall("pkg:"..pkgId)
                  if 0 == table.getn(pkgHash_t) then
                     logger:i("----pkgHash_t getn  nil----")
                     local default_rt = require("default_json")
                     result = default_rt:data_not_found()
                  else 
                      local utils = require("fuhao.util")
                      local pkgHash = utils.redis_hash_to_table(pkgHash_t) 
                      logger:i("----pkgHash----"..JSON.encode(pkgHash ))

                      local verId = versions[1]
                      local verHash_t = red:hgetall("ver:"..verId)
                      if 0 == table.getn(verHash_t) then
                          logger:i("----verHash_t getn  nil----")
                          local default_rt = require("default_json")
                          result = default_rt:data_not_found()
                      else 
                          local verHash = utils.redis_hash_to_table(verHash_t) 
                          logger:i("----verHash----"..JSON.encode(verHash))
                          local upType = verHash.upType
                          local related = true    
                          --[[
                              过滤例外
                          --]]
                      
                          local ver = verHash.noF.."."..verHash.noS.."."..verHash.noT
                          local upgradeTitle = "V"..appVersion.."升级到V"..ver
                          local data_table = {
                                     upgrade = 1, 
                                     version = ver, 
                                     vername = verHash.verName,
                                     uptype =upType
                                  } 
                          if upType == 1 then
                             data_table["title"] = verHash.titleForce..upgradeTitle 
                             data_table["desc"] = verHash.descForce 
                          else
                             data_table["title"] = verHash.title..upgradeTitle  
                             data_table["desc"] = verHash.desc 
                          end
                          data_table["upurl"] =  verHash.upUrl
                          data_table["filemd5"] =  verHash.upMd5
                          data_table["somd5"]  = verHash.utpSoMd5
                          local pkgName = pkgHash.pkgName
                          if pkgName then
                              data_table["pkgname"] = pkgName;
                              fileName =pkgName.."_v"..ver..".apk"
                              data_table["filename"] = fileName 
	                  end

                          data_table["silentnotice"] = verHash.silentNotice.."V" .. ver.. "新版本！"
                          data_table["silentdl"] = tonumber(verHash.silentDl)
                          data_table["silentinstall"] = tonumber(verHash.silentInstall)
                          data_table["enable"] = tonumber(verHash. enable)
                          data_table["reseved"] = verHash.reseved
                          -- 版本提示升级设置，若redis没值，设置为1-提示升级
                          data_table["isprompt"] = tonumber(verHash.isPrompt)
                          -- 设置升级提示规则
                          data_table["promptalways"] = tonumber(verHash.promptAlways)
                          data_table["promptinterval"] = tonumber(verHash.promptInterval)
                          -- 关联是否勾选
                          data_table["relatedcheck"] = tonumber(pkgHash.clientRelated)
                          data_table["relatedinfo"] = pkgHash.relatedInfo
                           -- 获取关联app列表
                          if related then
                              data_table["relatedapps"] = getRelatedApps(pkgId, pkgName)  -- todo getRelatedApps(pkgId, pkgName))
                          else
                              data_table["relatedapps"] = {} --没有推荐app列表
                          end 



                          result = {
                             code= "A000000",
                             data= data_table,
                             message= "OK",
                             timestamp= os.date('%Y%m%d%H%M%S', os.time())
                          }
                   end       
                 end 
              end
           end 
      end
    end
    logger:i(JSON.encode(result))
    resp:writeln(JSON.encode(result))
    resp:finish()
    logger:i("-----upgrade----")
end

function getRelatedApps(pkgId, pkgName)
  local relatedApps = {}

  local red = redis_conn();
  local relatedPkgs,err = red:zrange("pkg:"..pkgId..":relatedPkgs",0,-1)
  if 0 ~= table.getn(relatedPkgs) then
    for i = 1, #relatedPkgs do
      local pkgHash_t = red:hgetall("pkg:"..relatedPkgs[i])
      if 0 ~= table.getn(pkgHash_t) then
        logger:i("----pkgHash_t getn not  nil----")

        local utils = require("fuhao.util")
        local pkgHash = utils.redis_hash_to_table(pkgHash_t)
        logger:i("----pkgHash----"..JSON.encode(pkgHash ))
        local versions,err = red:zrange("pkg:"..pkgId..":effVers",-1,-1,"WITHSCORES")
        if 0 ~= table.getn(versions) then
          local verId = versions[1]
          local verHash_t = red:hgetall("ver:"..verId)
          if 0 ~= table.getn(verHash_t) then
            logger:i("----verHash_t getn not nil----")
            local verHash = utils.redis_hash_to_table(verHash_t)
            logger:i("----verHash----"..JSON.encode(verHash))

            local ver = verHash.noF.."."..verHash.noS.."."..verHash.noT
            local data_table = {
              relatedtitle = pkgHash.relatedTitle,
              version = ver,
              vername = verHash.verName
            }

            data_table["upurl"] =  verHash.upUrl
            data_table["filemd5"] =  verHash.upMd5

            local pkgName = pkgHash.pkgName
            if pkgName then
              data_table["pkgname"] = pkgName;
              fileName =pkgName.."_v"..ver..".apk"
              data_table["filename"] = fileName
            end

            data_table["silentdl"] = tonumber(verHash.silentDl)
            data_table["silentinstall"] = tonumber(verHash.silentInstall)

            table.insert(relatedApps,data_table)
          end
        end
      end
    end
    logger:i("----relatedPkgs test ----"..JSON.encode(relatedPkgs))
  end
  return relatedApps
end


function parse_version(version)
   if  version then
      local utils = require("fuhao.util")
      local v_ta =  utils.lua_string_split(version,"%p")
      local noF = 0 
      local noS = 0 
      local noT= 0 
      if v_ta[1] then
          noF = v_ta[1]
      end
      if v_ta[2] then
          noS = v_ta[2]
      end
      if v_ta[3] then
          noT= v_ta[3]
      end
      return {noF,noS,noT}
   end
end
