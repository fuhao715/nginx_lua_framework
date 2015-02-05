#!/usr/bin/env lua
-- -*- lua -*-
-- copyright: 2015 letv Inc.
-- author : fuhao 
--

module("hashAlgorithm", package.seeall)

function consistencyHash(source)
    return 60*os.date('%H', date) + os.date('%M', date)
end
