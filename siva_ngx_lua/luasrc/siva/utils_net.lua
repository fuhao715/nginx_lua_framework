#!/usr/bin/env lua
-- -*- lua -*-
-- Copyright 2015 siva Inc.
-- Author : fuhao 
--
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
--

local json          = require("cjson")

module('siva.utils_net', package.seeall)

-- Simplistic URL decoding that can handle + space encoding too.
function url_decode(data)
    return data:gsub("%+", ' '):gsub('%%(%x%x)', function (s)
        return string.char(tonumber(s, 16))
    end)
end

-- Simplistic URL encoding
function url_encode(data)
    return data:gsub("\n","\r\n"):gsub("([^%w%-%-%.])", 
        function (c) return ("%%%02X"):format(string.byte(c)) 
    end)
end


-- Basic URL parsing that handles simple key=value&key=value setups
-- and decodes both key and value.
function url_parse(data, sep)
    local result = {}
    sep = sep or '&'
    data = data .. sep

    for piece in data:gmatch("(.-)" .. sep) do
        local k,v = piece:match("%s*(.-)%s*=(.*)")

        if k then
            result[url_decode(k)] = url_decode(v)
        else
            result[#result + 1] = url_decode(piece)
        end
    end

    return result
end
