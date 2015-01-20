#!/usr/bin/env lua
-- -*- lua -*-

module('default_json', package.seeall)

local JSON = require("cjson")

local default_json = {}


function default_json:param_error()
    local result = {
        code= "A000001",
        message= "参数无效",
        timestamp= os.date('%Y%m%d%H%M%S', os.time())
    }
   return result
end

function default_json:data_not_found()
    local result = {
        code= "A000004",
        message= "没有数据",
        timestamp= os.date('%Y%m%d%H%M%S', os.time())
    }
   return result
end

function default_json:no_update()
   local result = {
         code= "A000000",
         data= {
             upgrade = 0
         },
         message= "OK",
         timestamp= os.date('%Y%m%d%H%M%S', os.time())
   }
   return result
end

return default_json
