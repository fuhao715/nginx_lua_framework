#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2012 Appwill Inc.
-- author : ldmiao
--

local router = require('siva.router')
router.setup()

---------------------------------------------------------------------
map('^/sivaconsole',                 'siva.console.start')

map('^/hello%?name=(.*)',           'test.hello')
map('^/longtext',                   'test.longtext')
map('^/ltp',                        'test.ltp')
map('^/ip',                        'test.getIP')
map('^/upload',                        'test.upload')
map('^/mysql',                        'test.get_mysql_opsystem')
map('^/upgrade',                        'test.upgrade')
map('^/httpclient',                        'test.inner')


---------------------------------------------------------------------
