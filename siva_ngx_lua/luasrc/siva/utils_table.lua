#!/usr/bin/env lua
-- -*- lua -*-
-- Copyright 2014 Appwill Inc.
-- Author : siva 
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

module('siva.utils_table', package.seeall)

function table_print(tt, indent, done)
  local done = done or {}
  local indent = indent or 0
  local space = string.rep(" ", indent)

  if type(tt) == "table" then
    local sb = {}

    for key, value in pairs(tt) do
      table.insert(sb, space) -- indent it

      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, table_print(value, indent + 2, done))
        table.insert(sb, space) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\" ", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring(key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function table_print2(t)
	local s1="\n* Table String:"
	local s2="\n* End Table"
	ngx.log(ngx.DEBUG,s1 .. strify(t) .. s2)
end


function table_index(t, value)
	if type(t) ~= 'table' then return nil end
	for i,v in ipairs(t) do
		if v==value then
			return i
		end
	end

	return nil
end

function table_sub(t, s, e)
	local t_count = #t

	if s<0 then
		s = t_count + s + 1
	end

	if e<0 then
		e = t_count + e + 1
	end

	if s<=0 or s>t_count or e<=0 then
		return nil
	end

	e = math_min(t_count, e)

	local new_t = {}
	for i=s,e,1 do
		table_insert(new_t, t[i])
	end

	return new_t
end

function table_extend(t, t1)
	for _,v in ipairs(t1) do
		table_insert(t, v)
	end
	return t
end

function table_merge(t1, t2)
	local new_t = {}
	for i,v in ipairs(t1) do
		table_insert(new_t, v)
	end
	for i,v in ipairs(t2) do
		table_insert(new_t, v)
	end
	return new_t
end

function table_update(t1, t2)
	for k,v in pairs(t2) do
		t1[k] = v
	end
	return t1
end

function table_rm_value(t, value)
	local idx = table_index(t, value)
	if idx then
		table_remove(t, idx)
	end
	return idx
end

function table_contains_value(t, value)
	for _, v in pairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

function table_contains_key(t, element)
	return t[element]~=nil
end

function table_count(t, value)
	local count = 0
	for _,v in ipairs(t) do
		if v==value then
			count = count + 1
		end
	end
	return count
end

function table_real_length(t)
	local count = 0
	for k,v in pairs(t) do
		count = count + 1
	end
	return count
end

function table_empty(t)
	if not t then return true end
	if type(t)=='table' and #t<=0 then return true end
	return false
end

function table_unique(t)
	local n_t1 = {}
	local n_t2 = {}
	for k,v in ipairs(t) do
		if n_t1[v] == nil then
			n_t1[v] = v
			table.insert(n_t2, v)
		end
	end
	return n_t2
end

function table_excepted(t1, t2)
	local ret = {}
	for _,v1 in ipairs(t1) do
		local finded = false
		for _,v2 in ipairs(t2) do
			if type(v2) == type(v1) and v1==v2 then
				finded = true
				break
			end
		end
		if not finded then
			table.insert(ret,v1)
		end
	end
	return ret
end
