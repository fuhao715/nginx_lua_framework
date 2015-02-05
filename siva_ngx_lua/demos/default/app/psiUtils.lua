#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2015 letv Inc.
-- author : fuhao 
--

module("psiUtils", package.seeall)

function parse_version(version)
   if  version then
      local utils = require("letv.util")
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

function getScore(version)
    local verNo = parse_version(version)
    return verNo[1]* 1000 * 1000 + verNo[2]* 1000 + verNo[3]
end
