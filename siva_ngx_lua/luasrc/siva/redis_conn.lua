#!/usr/bin/env lua
-- -*- lua -*-
-- Copyright 2015 siva Inc.
-- Author : fuhao 

module('siva.redis_conn', package.seeall)

local Redis = require("resty.redis")

local redis_pool = {}

function redis_pool:get_redis_conf(redis_name)
    local sivautil = require("siva.util")
    local redis_config = sivautil.get_config(redis_name)
    local redis_host = "127.0.0.1"
    local redis_port = 6379
    local redis_timeout = 10000
    local redis_poolsize= 2000
    if redis_config and type(redis_config.host) == "string" then
        redis_host = redis_config.host
    end
    
    if redis_config and type(redis_config.port) == "number" then
        redis_port = redis_config.port
    end

    if redis_config and type(redis_config.timeout) == "number" then
        redis_timeout= redis_config.timeout
    end
    
    if redis_config and type(redis_config.poolsize) == "number" then
        redis_poolsize= redis_config.poolsize
    end
    logger:i(redis_host..":"..tostring(redis_port).."  "..tostring(redis_timeout).."  "..tostring(redis_poolsize))
    return redis_host,redis_port,redis_timeout,redis_poolsize
end

function redis_pool:get_redis_conn(red_name)
    local app_name = ngx.ctx.SIVA_APP_NAME
    local redis_name= red_name or 'redis'
    local pool_name= app_name..redis_name
    local red_pool = ngx.ctx[redis_pool]
    if red_pool and red_pool[pool_name] then
         return  red_pool[pool_name]
    end
    if not red_pool then
        red_pool = {}
    end 
    local red = Redis:new()
    local redis_host,redis_port,redis_timeout,redis_poolsize= redis_pool:get_redis_conf(redis_name)
    local ok, err = red:connect(redis_host,redis_port)
    if not ok then
        logger:e({"failed to connect: ", err})
        return nil, err
    end
    logger:i("connect redis completed!")
    red:set_timeout(redis_timeout)

--[[
    local ok1, err1 = red:set_keepalive(redis_timeout, redis_poolsize)
    if not ok1 then
         ngx.log(ngx.ERR, err);
         ngx.say("failed to set keepalive: ", err1)
         return nil,err
    end
--]]
    red_pool[pool_name] = red
    ngx.ctx[redis_pool] = red_pool 
    return  red  -- ngx.ctx[redis_pool]
end

function redis_pool:close(red_name)
    local app_name = ngx.ctx.SIVA_APP_NAME
    local redis_name= red_name or 'redis'
    local pool_name= app_name..redis_name
    local red_pool = ngx.ctx[redis_pool]
    if red_pool and red_pool[pool_name] then
         local redis_host,redis_port,redis_timeout,redis_poolsize= redis_pool:get_redis_conf(redis_name)
	 local red = red_pool[pool_name] 
         red:set_keepalive(redis_timeout, redis_poolsize)
         -- ngx.ctx[redis_pool] = nil
         red_pool[pool_name] = nil
     end
 end

return redis_pool
