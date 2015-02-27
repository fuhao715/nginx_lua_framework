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


module('siva.service', package.seeall)

function callService(uri,mtd,cp_all_vars,share_all_vars,...)
    local options = {method = mtd or ngx.HTTP_GET,args = arg,copy_all_vars=cp_all_vars or false,share_all_vars=share_all_vars or false,ctx = ngx.ctx}
    local res = ngx.location.capture(uri,options)  
    if resp.status ~= 200 then
        ngx.exit(500)
    end
    return  res.body  
end

function callMultiService(options)
    -- 多service调用，options中是一个table，其中每一项为如下所示
    -- option ={uri, {method = ngx.HTTP_GET,args = {arg1='arg1',arg2='arg2',...},copy_all_vars= false,share_all_vars=false,ctx = ngx.ctx}}
    -- 其中option第二个参数可选,其中method默认为GET，copy_all_vars和share_all_vars为false
    return  ngx.location.capture_multi(options)  
end
