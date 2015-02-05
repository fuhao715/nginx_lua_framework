#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2015 letv Inc.
-- author : fuhao 
--

local router = require('letv.router')
router.setup()

---------------------------------------------------------------------
map('^/letvconsole',                 'letv.console.start')

map('^/hello%?name=(.*)',           'test.hello')
map('^/longtext',                   'test.longtext')
map('^/ltp',                        'test.ltp')
map('^/ip',                        'test.getIP')
map('^/upload',                        'test.upload')
map('^/mysql',                        'test.get_mysql_opsystem')
map('^/upgrade',                        'test.upgrade')
map('^/httpclient',                        'client.inner')
map('^/ctr',                        'ctr.ctr')
map('^/utpupgrade',                 'utp.upgrade4utp')
map('^/unicom/ipsync',               'unicom.ipsync')
---------------------------------------------------------------------
