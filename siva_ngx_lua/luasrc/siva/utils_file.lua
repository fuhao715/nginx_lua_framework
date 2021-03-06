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

module('siva.utils_file', package.seeall)

-- Helper function that loads a file into ram.
function load_file(from_dir, name)
    local intmp = assert(io.open(from_dir .. name, 'r'))
    local content = intmp:read('*a')
    intmp:close()

    return content
end


-- Loads a source file, but converts it with line numbering only showing
-- from firstline to lastline.
function load_lines(source, firstline, lastline)
    local f = io.open(source)
    local lines = {}
    local i = 0

    -- TODO: this seems kind of dumb, probably a better way to do this
    for line in f:lines() do
        i = i + 1

        if i >= firstline and i <= lastline then
            lines[#lines+1] = ("%0.4d: %s"):format(i, line)
        end
    end

    return table.concat(lines,'\n')
end

function is_dir(dir)
   if type(dir) ~= 'string' then return false end
   -- TODO 
end


-- 只能判定文件是否能打开被取钱，并不能判定文件是否存在
-- TODO  判定文件是否存在，得需要用c写
function is_file(name)
   if type(name) ~= 'string' then return false end
   local f = io.open(name,'r')
   if f~=nil then io.close(f) return true else return false end
end


-- 创建目录，返回 true 表示创建成功，或 nil
function mkdir(dir)
end


-- 删除目录，返回 true 表示删除成功，或 nil
function rmdir(dir)
end

-- 读取目录下的文件列表，以 table 类型返回 
function readdir(dir)
end



