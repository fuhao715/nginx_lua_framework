#!/usr/bin/env lua
-- -*- lua -*-
-- Copyright 2012 Appwill Inc.
-- Author : KDr2
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

local string_match   = string.match
local package_loaded = package.loaded

siva_vars = nil
siva_debug = nil

function is_inited(app_name, init)
    -- get/set the inited flag for app_name
    local r_G = _G
    local mt = getmetatable(_G)
    if mt then
        r_G = rawget(mt, "__index")
    end
    if not r_G['siva_ngx_lua_inited'] then
        r_G['siva_ngx_lua_inited'] = {}
    end
    if init == nil then
        return r_G['siva_ngx_lua_inited'][app_name]
    else
        r_G['siva_ngx_lua_inited'][app_name] = init
        if init then
            -- put logger into _G
            local logger = require("siva.logger")
            r_G["logger"] = logger.logger()
            local redis_conn = require("siva.redis_conn")
            local red ,err = redis_conn:get_redis_conn()
            if not red then
                 local error_info = "SIVA_NGX_LUA APP SETUP ERROR: failed to connect redis : " ..err 
                 -- ngx.status = 500
                 -- ngx.say(error_info)
                 -- logger:i(error_info)
                 ngx.log(ngx.ERR, error_info)
                 return
            else 
                r_G["redis_conn"] = redis_conn.get_redis_conn 
                r_G["redis_close"] = redis_conn.close 
            end

            local mysql_conn = require("siva.mysql_conn")
            local mysql ,err = mysql_conn:get_mysql_conn()
            if not mysql then
                 local error_info = "SIVA_NGX_LUA APP SETUP ERROR: failed to connect mysql : " ..err 
                 -- ngx.status = 500
                 -- ngx.say(error_info)
                 -- logger:i(error_info)
                 ngx.log(ngx.ERR, error_info)
                 return
            else
               r_G["mysql_conn"] = mysql_conn.get_mysql_conn 
               r_G["mysql_close"] = mysql_conn.close 
            end

        end
    end
end

function setup_app()
    local siva_home = ngx.var.SIVA_NGX_LUA_HOME or os.getenv("SIVA_NGX_LUA_HOME")
    local app_name = ngx.var.SIVA_NGX_LUA_APP_NAME
    local app_path = ngx.var.SIVA_NGX_LUA_APP_PATH
    local app_config = app_path .. "/application.lua"

    package.path = siva_home .. '/luasrc/?.lua;' .. package.path
    siva_vars = require("siva.vars")
    siva_debug = require("siva.debug")
    local sivautil = require("siva.util")
    -- setup vars and add to package.path
    sivautil.setup_app_env(siva_home, app_name, app_path,
                          siva_vars.vars(app_name))

    local logger = require("siva.logger")
        
    local config = sivautil.loadvars(app_config)
    if not config then config={} end
    siva_vars.set(app_name,"APP_CONFIG",config)
    
    is_inited(app_name, true)
    
    if type(config.subapps) == "table" then
        for k, t in pairs(config.subapps) do
            local subpath = t.path
            package.path = subpath .. '/app/?.lua;' .. package.path
            local env = setmetatable({__CURRENT_APP_NAME__ = k,
                                      __MAIN_APP_NAME__ = app_name,
                                      __LOGGER = logger.logger()},
                                     {__index = _G})
            setfenv(assert(loadfile(subpath .. "/routing.lua")), env)()
        end
    end

    -- load the main-app's routing
    local env = setmetatable({__CURRENT_APP_NAME__ = app_name,
                              __MAIN_APP_NAME__ = app_name,
                              __LOGGER = logger.logger()},
                             {__index = _G})
    setfenv(assert(loadfile(app_path .. "/routing.lua")), env)()
    
    -- merge routings
    sivarouter = require("siva.router")
    sivarouter.merge_routings(app_name, config.subapps or {})

    if config.debug and config.debug.on and siva_debug then
        debug.sethook(siva_debug.debug_hook, "cr")
    end

end

function content()
    local ngx_ctx = ngx.ctx
    ngx_ctx.SIVA_NGX_LUA_APP_NAME = ngx.var.SIVA_NGX_LUA_APP_NAME
    if (not is_inited(ngx_ctx.SIVA_NGX_LUA_APP_NAME)) or (not package_loaded["siva.vars"]) then
        local ok, ret = pcall(setup_app)
        if not ok then
            local error_info = "SIVA_NGX_LUA APP SETUP ERROR: " .. ret
            ngx.status = 500
            ngx.say(error_info)
            -- logger:e(error_info)
            ngx.log(ngx.ERR, error_info)
            return
        end
    else
        siva_vars  = require("siva.vars")
        siva_debug = require("siva.debug")
    end

    if not is_inited(ngx_ctx.SIVA_NGX_LUA_APP_NAME) then
        local error_info = 'Can not setup SIVA_NGX_LUA APP: ' .. ngx_ctx.SIVA_NGX_LUA_APP_NAME
        ngx.status = 501
        ngx.say(error_info)
        logger:e(error_info)
        ngx.log(ngx.ERR, error_info)
        return
    end

    local siva_ngx_lua_app_name = ngx_ctx.SIVA_NGX_LUA_APP_NAME

    local uri         = ngx.var.REQUEST_URI
    local route_map   = siva_vars.get(siva_ngx_lua_app_name, "ROUTE_INFO")['ROUTE_MAP']
    local route_order = siva_vars.get(siva_ngx_lua_app_name, "ROUTE_INFO")['ROUTE_ORDER']
    local page_found  = false

    -- match order by definition order
    for _, k in ipairs(route_order) do
        local args = {string_match(uri, k)}
        if args and #args>0 then
            page_found = true
            local v = route_map[k]
            local request  = siva_vars.get(siva_ngx_lua_app_name, 'SIVA_NGX_LUA_MODULES')['request']
            local response = siva_vars.get(siva_ngx_lua_app_name, 'SIVA_NGX_LUA_MODULES')['response']

            local requ = request.Request:new()
            local resp = response.Response:new()
            ngx_ctx.request  = requ
            ngx_ctx.response = resp

            if type(v) == "function" then                
                if siva_debug then siva_debug.debug_clear() end
                local ok, ret = pcall(v, requ, resp, unpack(args))
                logger:i("redis-------------"..type(_G["redis_close"])) 
                if _G["redis_close"] then
                    redis_close() 
                end
                logger:i("mysql-------------"..type(_G["mysql_close"])) 
                if  _G["mysql_close"] then
                    mysql_close() 
                end
                if not ok then resp:error(ret) end
                resp:finish()
                resp:do_defers()
                resp:do_last_func()
            elseif type(v) == "table" then
                v:_handler(requ, resp, unpack(args))
            else
                ngx.exit(500)
            end
            break
        end
    end

    if not page_found then
        ngx.exit(404)
    end
end

----------
content()
----------

