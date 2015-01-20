
-- name="demo1"

ltp=true

logger = {
    file = "/tmp/siva_demo1.log",
    level = "DEBUG",
}

debug={
    on=true,
    to="response", -- "ngx.log"
}

config={
    templates="templates",
}

subapps={
    demo3 = {        
        path="/Volumes/KDr2/Work/appwill/siva/demos/demo3",
        config={
            test="a test config",
            ltp=true
        },
        test=ngx.var.TEST,
    },
}


