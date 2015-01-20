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

module('fuhao.utils_object', package.seeall)


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
