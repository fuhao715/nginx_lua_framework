--
-- application configuration
--
-- var in this file can be got by "letv.util.get_config(key)"
--

debug={
    on=false,
    to="response", -- "ngx.log"
}

logger = {
    file = "letv_ngx_lua_demo.log",
    level = "DEBUG",
}
redis = {
    host = "10.154.252.153",
    port = 6379,
    timeout= 10000,
    poolsize= 2000
}

mysql= {
    host = "10.154.252.153",
    port = 3306,
    db= "taps",
    charset = "UTF8",
    username = "root",
    passwd= "letv@2014",
    timeout= 10000,
    max_packet_size= 1024*1024,
    poolsize= 2000
}

config={
    templates="templates",
}

subapps={
    -- subapp_name = {path="/path/to/another/letv_ngx_luaapp", config={}},
}


