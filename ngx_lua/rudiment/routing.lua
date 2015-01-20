#!/usr/bin/env lua
-- -*- lua -*-
-- This is a Moochine Application Routing file
--


fuhao_router=require 'fuhao.router'
fuhao_router.setup('__FUHAO_NGX_LUA_APP_NAME__')

-----------------------------------------------
-- 1.simple function mapping
map('^/1/hello%?name=(.*)',"d1_test.hello")
map('^/1/ltp$',"d1_test.ltp")


-- 2.fuhao controller mapping
map('^/1/hello_v2%?name=(.*)',"d1_test_v2.ctller_v2")
map('^/1/ltp_v2',"d1_test_v2.ctller_ltpv2")

-----------------------------------------------



