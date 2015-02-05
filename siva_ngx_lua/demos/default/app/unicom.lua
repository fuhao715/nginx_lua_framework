#!/usr/bin/env lua

module("unicom",package.seeall)

local dbutils=require("letvdb.dbutils")
local json=require("cjson")
local redis=require("resty.redis") 
local servie=require("unicom.service")
local const=require("unicom.const")

function abc(req,resp)
   local flag,res,err,errno,sqlstate=dbutils.query("select * from CDN_CALL_CONF where ID=${id}",{id=1})   
   
   resp:writeln(json.encode({flag=flag,res=res,err=err,errno=errno,sqlstate=sqlstate}))

   local flag,res,err,errno,sqlstate=dbutils.execute("delete from SYS_LOG where id=999")
   
   resp:writeln(json.encode({flag=flag,res=res,err=err,errno=errno,sqlstate=sqlstate}))
end

--sync ip
function ipsync(req,resp)
 -- local body=req:read_body() 
--logger:i(ngx)
--logger:i(ngx.req)
--logger:i(ngx.req.read_body())
 -- local json.decode(body)
  local body=[[
{"ipbegin":"139214253001","ipend":"139214253255",
"province":"纽约","isopen":"1","opertime":"20150204135900"}
]]
logger:i(type(body))
logger:i(body)
local ip=json.decode(body)
 ip.ipStartLong=service.ip2long(ip.ipbegin)
 ip.ipEndLong=service.ip2long(ip.ipend)
 ip.ipStart=ip.ipbegin
 ip.ipEnd=ip.ipend
 ip.ispId="unicom"
 ip.isp="联通"
 ip.is3g=1
 ip.isEffective=(tonumber(ip.isopen))
 ip.opTime=(ip.opertime)
 local flag,res,err,errno,sqlstate=service.saveIp(ip)
 logger:i(json.encode({flag=flag,res=res}))
 if flag then 
  res,err=service.saveIpLib(ip) 
  logger:i(json.encode({res=res}))
  if res then 
    resp:writeln(json.encode(const.SUCCESS)) 
  else
    logger:e(err)
    resp:writeln(json.encode(const.ERROR)) 
  end 
 else
   logger:e("" .. err .. errno,sqlstate) 
   resp:writeln(json.encode(const.ERROR))
 end
end
