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

module('siva.utils_object', package.seeall)


-- useful for tables and params and stuff
function clone(source, keys)
    local target = {}
    update(target, source, keys)
    return target
end




function update(target, source, keys)
    if keys then 
        for _, key in ipairs(keys) do
            target[key] = source[key]
        end
    else
        for k,v in pairs(source) do
            target[k] = v
        end
    end
end

function map(func, t)
	local new_t = {}
	for i,v in ipairs(t) do
		table_insert(new_t, func(v, i))
	end
	return new_t
end


function isNull(v)
	return (v==nil or v==ngx.null)
end

function isNotNull(v)
	return not isNull(v)
end



function deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function md5(source)
    local resty_md5 = require "resty.md5"
    local md5 = resty_md5:new()
    if not md5 then
        logger:e("failed to create md5 object")
        return
    end

    ok = md5:update(source)
    if not ok then
        logger:e("failed to add data")
        return
    end

    local digest = md5:final()

    local str = require "resty.string"
    logger:i("md5: "..str.to_hex(digest))
    return str.to_hex(digest)
    -- yield "md5: 5d41402abc4b2a76b9719d911017c592"
end


function computeMD5(source)
    local resty_md5 = require "resty.md5"
    local md5 = resty_md5:new()
    if not md5 then
        logger:e("failed to create md5 object")
        return
    end
    md5:reset()
    -- local sbyte = {string.byte(source,1,string.len(source))}
    ok = md5:update(source)
    if not ok then
        logger:e("failed to add data")
        return
    end

    local digest = md5:final()
    local str = require "resty.string"
    logger:i("md5: "..str.to_hex(digest))
    return {string.byte(digest,1,string.len(digest))}
end

function hash(digest,nTime)
    local bit = require "bit"
    local band = bit.band -- 位与 &
    local bor = bit.bor -- 位或  |
    local lshift = bit.lshift -- 左移  <<
    rv = bor(bor(bor(lshift(band(digest[4 + nTime * 4],0xFF),24),lshift(band(digest[3 + nTime * 4],0xFF),16)),lshift(band(digest[2 + nTime * 4],0xFF),8)),band(digest[1 + nTime * 4],0xFF))
    return band(rv , 0xffffffff) -- Truncate to 32-bits 
end

function consistencyHash(str)
    return hash(computeMD5(str),0);
end