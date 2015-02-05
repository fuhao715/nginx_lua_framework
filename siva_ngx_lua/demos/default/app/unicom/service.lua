#!/usr/env/bin lua

module("service",package.seeall)


local dbutils=require("letvdb.dbutils")
local const=require("unicom.const")

function ip2long(ipstr)
  local a=tonumber(string.sub(ipstr,1,3))*16777216
  local b=tonumber(string.sub(ipstr,4,6))*65536
  local c=tonumber(string.sub(ipstr,7,9))*256
  local d=tonumber(string.sub(ipstr,10,12))
  return a+b+c+d
end

function saveIp(ipInfo)
 local flag,res,err,errno,sqlstate=dbutils.query(const.sql.getIp,ipInfo)
 if not flag then
  return flag,res,err,errno,sqlstate
 end 
 --logger:i(res)
 if not res[1] then
  local flag,res,err,errno,sqlstate= dbutils.query(const.sql.insertIp,ipInfo)
  if flag then 
    ipInfo.id=res.insert_id
  end
 else
  ipInfo.id=res[1].ID
  return dbutils.query(const.sql.updateIp,ipInfo)
 end
end

function save2RedisIp(ipInfo)
  local redis=redis_conn()
  local res,err=redis:hmset("isp_unicom_ip_info:" .. ipInfo.id,ipInfo)  
  if not  res then 
    logger:e("" .. err)
    return false,err 
  end
  local start=ipInfo.ipStartLong
  local enda=ipInfo.ipEndLong
  local startOffset=start%65536
  local endOffset=enda%65536
  local startPage=(start-startOffset)/65536
  local endPage=(enda-endOffset)/65536
  for i=startPage,endPage do
   if i==startPage then 
     res,err=redis:zadd("isp_unicom_ip_lib:" .. i,startPage,"s:" .. ipInfo.id)
     if not  res then 
       logger:e("" .. err)
       return false,err 
     end
     if i~=endPage then
      res,flag=redis:zadd("isp_unicom_ip_lib:" .. i,65535,"e:" .. ipInfo.id)
       if not  res then 
         logger:e("" .. err)
         return false,err 
       end
     end
   end
   if i==endPage then 
     res,err=redis:zadd("isp_unicom_ip_lib:" .. i,endOffset,"e:" .. ipInfo.id)
       if not  res then 
         logger:e("" .. err)
         return false,err 
       end
     if i~=startPage then 
      res,flag=redis:zadd("isp_unicom_ip_lib:" .. i,0,"s:" .. ipInfo.id)
       if not  res then 
         logger:e("" .. err)
         return false,err 
       end
     end
   end
   if i~=startPage and i~=endPage then 
    res,err=redis:zadd("isp_unicom_ip_lib:" .. i ,0,"s:" .. ipInfo.id)
       if not  res then 
         logger:e("" .. err)
         return false,err 
       end
    res,err=redis:zadd("isp_unicom_ip_lib:" .. i, 65535,"e:" .. ipInfo.id) 
       if not  res then 
         logger:e("" .. err)
         return false,err 
       end
   end
  end
  return true,nil
end

function delIpFromRedis(ipInfo)
  local redis=redis_conn()
  local res,err=redis:del("isp_unicom_ip_info:" .. ipInfo.id)  
  if not  res then 
      logger:e("" .. err)
    return false,err 
  end
  local start=ipInfo.ipStartLong
  local enda=ipInfo.ipEndLong
  local startOffset=start%65536
  local endOffSet=enda%65536
  local startPage=(start-startOffset)/65536
  local endPage=(enda-endOffSet)/65536
  for i=startPage,endPage do
   if i==startPage then 
     res,err=redis:zrem("isp_unicom_ip_lib:" .. i,"s:" .. ipInfo.id) 
     if not  res then 
       logger:e("" .. err)
       return false,err 
     end
     if i~=endPage then
      res,err=redis:zrem("isp_unicom_ip_lib:" .. i,"e:" .. ipInfo.id)
       if not  res then 
       logger:e("" .. err)
         return false,err 
       end
     end
   end
   if i==endPage then 
     res,err=redis:zrem("isp_unicom_ip_lib:" .. i,"e:" .. ipInfo.id)
       if not  res then 
       logger:e("" .. err)
         return false,err 
       end
     if i~=startPage then 
      res,err=redis:zrem("isp_unicom_ip_lib:" .. i,"s:" .. ipInfo.id)
       if not  res then 
       logger:e("" .. err)
         return false,err 
       end
     end
   end
   if i~=startPage and i~=endPage then 
    res,err=redis:zrem("isp_unicom_ip_lib:" .. i ,"s:" .. ipId)
       if not  res then 
       logger:e("" .. err)
         return false,err 
       end
    res,err=redis:zrem("isp_unicom_ip_lib:" .. i, "e:" .. ipId) 
       if not  res then 
       logger:e("" .. err)
         return false,err 
       end
   end
  end
  return true,nil
end

function saveIpLib(ipInfo)
  if ipInfo.isEffective == 1 then
    return save2RedisIp(ipInfo)
  else 
    return delIpFromRedis(ipInfo)  
  end 
end
