#!/usr/bin/env lua
-- -*- lua -*-

module('fuhao.mysql_conn',package.seeall)

local fuhao_MySQL = require("resty.mysql")

local mysql_pool = {}

function mysql_pool:get_mysql_conf()
    local fuhaoutil = require("fuhao.util")
    local mysql_config = fuhaoutil.get_config("mysql")
    local mysql_host = "127.0.0.1"
    local mysql_port = 6379
    local mysql_db =  "taps" 
    local mysql_charset = "UTF8"
    local mysql_username = "root"
    local mysql_passwd = "fuhao@2014"
    local mysql_timeout = 1000
    local mysql_max_packet_size= 1024*1024
    local mysql_poolsize= 2000
    if mysql_config and type(mysql_config.host) == "string" then
        mysql_host = mysql_config.host
    end
    
    if mysql_config and type(mysql_config.port) == "number" then
        mysql_port = mysql_config.port
    end

    if mysql_config and type(mysql_config.db) == "string" then
        mysql_db= mysql_config.db
    end

    if mysql_config and type(mysql_config.charset) == "string" then
        mysql_charset= mysql_config.charset
    end

    if mysql_config and type(mysql_config.username) == "string" then
        mysql_username= mysql_config.username
    end

    if mysql_config and type(mysql_config.passwd) == "string" then
        mysql_passwd= mysql_config.passwd
    end

    if mysql_config and type(mysql_config.timeout) == "number" then
        mysql_timeout= mysql_config.timeout
    end

    if mysql_config and type(mysql_config.max_packet_size) == "number" then
        mysql_max_packet_size= mysql_config.max_packet_size
    end
    
    if mysql_config and type(mysql_config.poolsize) == "number" then
        mysql_poolsize= mysql_config.poolsize
    end
    logger:i(mysql_host..":"..tostring(mysql_port).."  "..tostring(mysql_db).."  "..mysql_charset.."  "..mysql_username.."  "..mysql_passwd.."  "..tostring(mysql_timeout).." "..tostring(mysql_max_packet_size).."  "..tostring(mysql_poolsize))
    return mysql_host,mysql_port,mysql_db,mysql_charset,mysql_username,mysql_passwd,mysql_timeout,mysql_max_packet_size,mysql_poolsize
end

function mysql_pool:get_mysql_conn()
    if ngx.ctx[mysql_pool] then
         return ngx.ctx[mysql_pool]
    end
    local mysql_conn, err = fuhao_MySQL:new()
    if not mysql_conn then
        -- ngx.say("failed to instantiate mysql: ", err)
        logger:e("failed to instantiate mysql: ", err)
        return nil,err
    end
    local mysql_host,mysql_port,mysql_db,mysql_charset,mysql_username,mysql_passwd,mysql_timeout,mysql_max_packet_size,mysql_poolsize  = mysql_pool:get_mysql_conf()
    local ok, errmsg, errno, sqlstate= mysql_conn:connect{host=mysql_host,port=mysql_port,database=mysql_db,user=mysql_username,password=mysql_passwd,max_packet_size=mysql_max_packet_size}
    if not ok then
        local errinfo = "mysql can not_connect: " .. (errmsg or "nil") .. ", errno:" .. (errno or "nil") ..", sql_state:" .. (sqlstate or "nil")
        logger:e(errinfo)
        return nil, errinfo
    end
    logger:i("connect mysql completed!")
    mysql_conn:set_timeout(mysql_timeout)

    local query = "SET NAMES " ..mysql_charset 
    local result, errmsg1, errno1, sqlstate1 = mysql_conn:query(query)
    if not result then
        return nil, "mysql set charset failed: " .. (errmsg1 or "nil") .. ", errno1:" .. (errno1 or "nil") ..", sql_state1:" .. (sqlstate1 or "nil")
    end
    ngx.ctx[mysql_pool] = mysql_conn 
    return ngx.ctx[mysql_pool]
end

function mysql_pool:close()
     if ngx.ctx[mysql_pool] then
         local mysql_host,mysql_port,mysql_db,mysql_charset,mysql_username,mysql_passwd,mysql_timeout,mysql_max_packet_size,mysql_poolsize = mysql_pool:get_mysql_conf()
         ngx.ctx[mysql_pool]:set_keepalive(mysql_timeout, mysql_poolsize)
         ngx.ctx[mysql_pool] = nil
     end
 end

return mysql_pool
