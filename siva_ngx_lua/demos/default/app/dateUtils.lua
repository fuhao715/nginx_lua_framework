#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2015 letv Inc.
-- author : fuhao 
--

module("dateUtils", package.seeall)

function getMinuteOfDay(date)
    return 60*os.date('%H', date) + os.date('%M', date)
end
