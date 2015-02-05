#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2015 letv Inc.
-- author : fuhao 
--

module("client", package.seeall)

local JSON = require("cjson")
local Redis = require("resty.redis")


function inner(req,resp)
   logger:i("-----开始调用httpclient------")
   local http = require "letv.http"
            local hc = http:new()

            local ok, code, headers, status, body  = hc:request {
                url = 'http://10.154.156.34:9800/upgrade?appkey=01001020101006800010&appversion=5.0.1',  -- "http://www.qunar.com/",
                --- proxy = "http://127.0.0.1:8888",
                --- timeout = 3000,
                method = "GET", -- POST or GET
                -- add post content-type and cookie
                headers = { Cookie = "ABCDEFG", ["Content-Type"] = "application/x-www-form-urlencoded" },
                body = "uid=1234567890",
            }
   logger:i("-----body-------"..body)
   logger:i("-------结束httpclient------")
   resp:writeln(body)
   resp:finish()
end

