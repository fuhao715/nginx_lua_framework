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

module('siva.request',package.seeall)

local string_len = string.len
local match = string.match

Request = {}

function Request:new()
    local ngx_var = ngx.var
    local ngx_req = ngx.req
    local ngx_upload = require("siva.upload") 
    local up_data = ngx_upload.SivaUpload:new()
    local ret = {
        method          = ngx_var.request_method,
        schema          = ngx_var.schema,
        host            = ngx_var.host,
        hostname        = ngx_var.hostname,
        uri             = ngx_var.request_uri,
        path            = ngx_var.uri,
        filename        = ngx_var.request_filename,
        query_string    = ngx_var.query_string,
        headers         = ngx_req.get_headers(),
        user_agent      = ngx_var.http_user_agent,
        remote_addr     = ngx_var.remote_addr,
        remote_port     = ngx_var.remote_port,
        remote_user     = ngx_var.remote_user,
        remote_passwd   = ngx_var.remote_passwd,
        content_type    = ngx_var.content_type,
        content_length  = ngx_var.content_length,
        uri_args        = ngx_req.get_uri_args(),
	body            = self:read_body(),
        post_args       = up_data,
        upload_data     = up_data,
        socket          = ngx_req.socket
    }

    setmetatable(ret,self)
    self.__index=self
    return ret
end


function Request:get_post_param()
    local js = require("cjson") --- delete this line
    local ngx_var = ngx.var
    local ngx_req = ngx.req
    local args = {}
    local req_method = ngx_var.request_method
    local is_have_file_param = false
    if "GET" == req_method then
        args = ngx.req.get_uri_args()
    elseif "POST" == req_method then
        local receive_headers = ngx_req.get_headers()
        ngx_req.read_body()
        if string.sub(receive_headers["content-type"],1,20) == "multipart/form-data;" then --判断是否是multipart/form-data类型的表单
            is_have_file_param = true
        else
          logger:i("not file post")
          args = ngx_req.get_post_args()   
        end
    end
    logger:i("args is -----"..js.encode(args))
    return args
end 

function Request:get_uri_arg(name, default)
    if name==nil then return nil end

    local arg = self.uri_args[name]
    if arg~=nil then
        if type(arg)=='table' then
            for _, v in ipairs(arg) do
                if v and string_len(v)>0 then
                    return v
                end
            end

            return ""
        end

        return arg
    end

    return default
end

function Request:get_post_arg(name, default)
    if name==nil then return nil end
    if self.post_args==nil then return nil end

    local arg = self.post_args[name]
    if arg~=nil then
        if type(arg)=='table' then
            for _, v in ipairs(arg) do
                if v and string_len(v)>0 then
                    return v
                end
            end

            return ""
        end

        return arg
    end

    return default
end

function Request:get_arg(name, default)
    return self:get_post_arg(name) or self:get_uri_arg(name, default)
end

function Request:read_body()
    local ngx_req = ngx.req
    ngx_req.read_body()
    -- self.post_args = ngx_req.get_post_args()
    --  self.body      = ngx.var.request_body
    return ngx.var.request_body 
end

function Request:get_cookie(key, decrypt)
    local value = ngx.var['cookie_'..key]

    if value and value~="" and decrypt==true then
        value = ndk.set_var.set_decode_base64(value)
        value = ndk.set_var.set_decrypt_session(value)
    end

    return value
end

function Request:rewrite(uri, jump)
    return ngx.req.set_uri(uri, jump)
end

function Request:set_uri_args(args)
    return ngx.req.set_uri_args(args)
end

-- to prevent use of casual module global variables
getmetatable(siva.request).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end

