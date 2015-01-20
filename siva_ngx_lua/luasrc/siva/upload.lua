#!/usr/bin/env lua
-- -*- lua -*-

module('siva.upload',package.seeall)


SivaUpload= {}

function get_post_args(upload_data)
    local fmatch = string.gmatch(upload_data, '"(.-)"')
    -- local filename = ngx.re.match(upload_data,'name="(.+)"')
    if fmatch then 
        local key = fmatch()
        local filename = fmatch() 
        return key,filename -- 返回key，filename
    end
end

function SivaUpload:new()
    local upload = require "resty.upload"
    local json = require("cjson") 
    local chunk_size = 4096
    local upload_obj = upload:new(chunk_size)
    if not upload_obj then
       return 
    end 

    upload_obj:set_timeout(0) -- 1 sec
    local up_data ={} 
    local i = 0
    local upkey ,filename =nil,nil 
    while true do
        local typ, upload_data, err = upload_obj:read()
        if not typ then
            logger:i("failed to read: ", err)
            -- ngx.say("failed to read: ", err)
            break
        end
        if typ == "header" then
            if upload_data[1] ~= "Content-Type" then
                upkey ,filename = get_post_args(upload_data[2])
                logger:i("---- upkey----"..upkey)
                if upkey then 
                    i = i + 1
                    local file_infor = {}
                    file_infor["filename"] = filename
                    up_data[upkey] = file_infor 
                end
            end
        elseif typ == "body" then
                local flen= tonumber(string.len(upload_data))    
                local f_infor = up_data[upkey]
                f_infor["value"] = upload_data
                f_infor["flen"] = flen 
                up_data[upkey] = f_infor 
        elseif typ == "part_end" then
                logger:i("file upload success")
        elseif typ == "eof" then
            break
        else
        end
    end
    if i==0 then
        logger:i("no file upload")
        -- ngx.say("please upload at least one file!")
        return
    else
        logger:i("----post_args is ----"..json.encode(up_data))
	setmetatable(up_data,self)
	self.__index=self
        return up_data 
    end
end


