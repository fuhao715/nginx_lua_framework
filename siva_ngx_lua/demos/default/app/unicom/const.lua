#!/usr/bin/env lua

module("const",package.seeall)
local M={}
M.ERROR={result="1",errorcode="A000001",errmsg="参数无效"}
M.SUCCESS={result="0",errorcode=""}
M.EFFECTIVE=1
M.INEFFECTIVE=0
M.sql={
 getIp="select ID from ISP_UNICOM_IP_LIB where IP_START_LONG=${ipStartLong} and IP_END_LONG=${ipEndLong}",
 insertIp=[[insert into ISP_UNICOM_IP_LIB(
			IP_START_LONG,IP_END_LONG,IP_START,IP_END,COUNTRY,COUNTRY_ID,
			PROVINCE,PROVINCE_ID,CITY,CITY_ID,ISP,ISP_ID,
			IS_3G,IS_EFFECTIVE,OP_TIME,CREATE_TIME,UPDATE_TIME
    	) values (
	 ${ipStartLong}, ${ipEndLong}, ${ipStart}, ${ipEnd}, ${country}, ${countryId},
	 ${province}, ${provinceId}, ${city}, ${cityId}, ${isp}, ${ispId},
	 ${is3g}, ${isEffective}, ${opTime}, ${createTime}, ${updateTime}
    	)]],
 updateIp=[[update ISP_UNICOM_IP_LIB set IP_START_LONG=${ipStartLong},IP_END_LONG=${ipEndLong},IP_START=${ipStart},IP_END=${ipEnd},COUNTRY=${country},COUNTRY_ID=${countryId},PROVINCE=${province},PROVINCE_ID=${provinceId},CITY=${city},CITY_ID=${cityId},ISP=${isp},ISP_ID=${ispId},IS_3G=${is3g},IS_EFFECTIVE=${isEffective},OP_TIME=${opTime},UPDATE_TIME=now() where ID=${id}]] 
}

return M
