#!/usr/bin/env lua
-- -*- lua -*-
-- Copyright 2014 Appwill Inc.
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

module('fuhao.utils_number', package.seeall)

-- Int

function int(value, default)
	local int_value = default

	local value_type = type(value)
	if value_type=='number' then
		int_value = value
	elseif value_type=='string' then
		int_value = tonumber(value)
		if not int_value then int_value = default end
	end

	return int_value
end

function basen(n, b)
	if not b or b==10 then
		return tostring(n)
	end

	if b<=1 then return nil end

	local digits = "0123456789abcdefghijklmnopqrstuvwxyz"

	local t = {}

	local sign = nil
	if n < 0 then
		sign = "-"
		n = -n
	end

	n = math_floor(n)
	repeat
		local d = (n % b) + 1
		n = math_floor(n / b)
		table_insert(t, 1, digits:sub(d,d))
	until n == 0

	if sign then
		return sign .. table_concat(t)
	end

	return table_concat(t)
end

function base10to36(i)
	if type(i)=='string' then i=tonumber(i) end
	-- if type(i)~='number' then return nil end
	return basen(i, 36)
end

function base36to10(s)
	return tonumber(s, 36)
end