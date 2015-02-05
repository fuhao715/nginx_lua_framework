#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2015 letv Inc.
-- author : fuhao 
--

module("versionRuleService", package.seeall)

local JSON = require("cjson")



function throughUpgradeByRule(ci,verId)
    logger:i('---------verId is -------'..verId)
    local throughResult = {}
    throughResult[1]=false
    local red = redis_conn()
    local throughRuleSet, err = red:smembers('ver:'..verId..':through_rules')
    logger:i('through'..JSON.encode(throughRuleSet))
    local utils_table = require('letv.utils_table')
    if utils_table.table_empty(throughResult) then
        return throughResult
    end 
    local clientMap = getClientMap(ci, verId)
    logger:i('clientMap '..JSON.encode(clientMap))
    local _ = require 'underscore'
    for i in _.iter(throughRuleSet) do
         local versionRules = getVersionRules(i)  
         local ruleInfor,error = red:hgetall('ver_rule:'..':info')
         if 0 ~= table.getn(ruleInfor) then
            local ruleHash = utils.redis_hash_to_table(ruleInfor) 
            local ruleId = ruleHash.ruleId
            local versionRules = {}
            versionRules['ruleId'] = ruleHash.ruleId
            versionRules['ruleType'] = ruleHash.ruleType
            
            rule:{0} 





         end
    end
    
end


function existsVersionUpcountByVerId(verId,clientKey)
    local red = redis_conn()
    local exist,err = red:sismember('ver:'..verId..':upcount',clientKey)
    logger:i('exist '..JSON.encode(exist))
    
    return exist==1 and true or false 
end

function getVersionUpcountSizeByVerId(verId)
    local red = redis_conn()
    local upCount,err = red:scard('ver:'..verId..'upcount')
    logger:i('upCount '..JSON.encode(upCount))
    return upCount
end

function  getClientMap(clientInfo, verId)
   local clientMap = {} 
   local _ = require 'underscore'
   local ipAry = _.to_array(string.gmatch(clientInfo['ip'],"%d+"))
   local ip =_.reduce( _.map(_.keys(ipAry), function(i) return 256^(4-i)*ipAry[i] end),0,function(memo, i) return memo+i end)
   clientMap['ip'] = ip
   local ipService = require('ipService')
   local ipInfor = ipService.getIP(clientInfo['ip']) 
   if ipInfor then
      clientMap['province'] = ipInfor['regionId'] 
      clientMap['city'] = ipInfor['cityId'] 
      clientMap['isp'] = ipInfor['ispId'] 
   end
   local psiUtils= require('psiUtils')
   clientMap['oldVersion'] = psiUtils.getScore(clientInfo['appversion'])
   clientMap['mac'] = clientInfo['macaddr']
   clientMap['model'] = clientInfo['devmodel']
   if clientInfo['devid'] or clientInfo['macaddr'] then
       local clientKey =clientInfo['macaddr'] ..  clientInfo['devid'] 
       local utils_object = require('letv.utils_object')
       local logic = utils_object.consistencyHash(clientKey)%10
       logger:i('----logic is ----'..logic)
       clientMap['logic'] = logic 
       local upCount = 0
       if not existsVersionUpcountByVerId(verId,clientKey) then
           upCount = getVersionUpcountSizeByVerId(verId) + 1; 
           logger:i('----upCount is ----'..upCount)
       end
       clientMap['upCount'] = upCount 
   end
   local dateUtils = require('dateUtils')
   clientMap['time'] =  dateUtils.getMinuteOfDay(os.time())
   return clientMap
end

