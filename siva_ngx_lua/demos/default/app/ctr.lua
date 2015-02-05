#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2015 letv Inc.
-- author : fuhao 
--

module("ctr", package.seeall)

local JSON = require("cjson")
local Redis = require("resty.redis")

local control = require("letv.controller")

ctr= control.Controller:new()

function ctr:new()
    local o={}
    
    self.__index=self
    return setmetatable(o,self)
end

function ctr:get(req,resp,...)
    logger:i('--------client get begin---------')
    local _ = require 'underscore'
    local se = _.select({1,2,3}, function(i) return i%2 == 1 end)
    logger:i(se)
    local default_rt = require("default_json")
    result = default_rt:data_not_found()
    logger:i(JSON.encode(result))
    resp:writeln(JSON.encode(result))
    resp:finish()
    logger:i('--------client get finish ---------')
end


function ctr:post(req,resp,...)
    logger:i('--------client post begin---------')
    local default_rt = require("default_json")
    result = default_rt:data_not_found()
    logger:i(JSON.encode(result))
    resp:writeln(JSON.encode(result))
    resp:finish()
    logger:i('--------client post finish ---------')
end
