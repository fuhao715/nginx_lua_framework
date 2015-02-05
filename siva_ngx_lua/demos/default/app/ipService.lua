#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2015 letv Inc.
-- author : fuhao 
--

module("ipService", package.seeall)

local JSON = require("cjson")


string.split = function(str, sep)
    local fields = {}
    str:gsub("[^"..sep.."]+", function(c) fields[#fields+1] = c end)
    return fields
end

function getIP(ip)
    local exc_begin = os.time() 
    logger:i("ip is ----"..ip)
    local ipAry = string.split(ip, "%.");
    local ipLong  = 16777216 * ipAry[1] + 65536 * ipAry[2] + 256 * ipAry[3] + ipAry[4];
    local offset = ipLong % 65536;
    local pageId = (ipLong - offset) / 65536;
    local key_ip_lib = "ip_lib:" .. pageId;
    local red = redis_conn();
    local startSet, err = red:zrevrangebyscore(key_ip_lib, offset, 0, "limit", 0, 1); 
    local startAry = string.split(startSet[1], ":");

    local key_start = "ip_info:" .. startAry[2];
    local ip_info = red:hmget(key_start, "country", "countryId", "area", "areaId", "region", "regionId", "city", "cityId", "isp", "ispId");
    if not ip_info then
        return nil
    end
    
    local ipInfor= {
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
    }
    return ipInfor
end

