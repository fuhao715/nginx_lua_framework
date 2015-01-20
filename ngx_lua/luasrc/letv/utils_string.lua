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

local math_floor    = math.floor
local string_char   = string.char
local string_byte   = string.byte
local string_rep    = string.rep
local string_sub    = string.sub
local debug_getinfo = debug.getinfo


module('fuhao.utils_string', package.seeall)


function to_string(data)
    if "nil" == type(data) then
        return tostring(nil)
    elseif "table" == type(data) then
        return table_print(data)
    elseif  "string" == type(data) then
        return data
    else
        return tostring(data)
    end
end

function dump(data, name)
    print(to_string({name or "*", data}))
end





-- lua 字符串分割函数
-------------------------------------------------------
-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function lua_string_split(str, split_char)    
    local sub_str_tab = {};
    while (true) do        
        local pos = string.find(str, split_char);  
        if (not pos) then            
            local size_t = table.getn(sub_str_tab)
            table.insert(sub_str_tab,size_t+1,str);
            break;  
        end
 
        local sub_str = string.sub(str, 1, pos - 1);              
        local size_t = table.getn(sub_str_tab)
        table.insert(sub_str_tab,size_t+1,sub_str);
        local t = string.len(str);
        str = string.sub(str, pos + 1, t);   
    end    
    return sub_str_tab;
end



--[[
-------------------------------------------------------
-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function lua_string_split(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end
--]]

function redis_hash_to_table(hash_data)
    local new_reply = { }
    for i = 1, #hash_data, 2 do new_reply[hash_data[i]] = hash_data[i + 1] end
    return new_reply
end
