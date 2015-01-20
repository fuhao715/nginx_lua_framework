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

module('fuhao.utils_table', package.seeall)

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
