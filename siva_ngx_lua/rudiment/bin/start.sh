#!/bin/bash
# start nginx in app

NGINX_RUNTIME="nginx_runtime"
APP_PATH=$PWD
APP_NAME=`basename $(APP_PATH)`

mkdir -p "$NGINX_RUNTIME/logs"

#export OPENRESTY_HOME=/usr/local/openresty
#export SIVA_NGX_LUA_HOME=/YOUR PATH/siva_ngx_lua
#export HADDIT_APP_CONFIG=/YOUR PATH/new_reddit/haddit.config


SIVA_NGX_LUA_APP_EXTRA=$PWD

sed -e "s|__SIVA_NGX_LUA_HOME_VALUE__|$SIVA_NGX_LUA_HOME|" \
    -e "s|__SIVA_NGX_LUA_APP_PATH_VALUE__|$APP_PATH|" \
    -e "s|__SIVA_NGX_LUA_APP_NAME_VALUE__|$APP_NAME|" \
    -e "s|__HADDIT_APP_CONFIG__|$HADDIT_APP_CONFIG|" \
    cat conf/nginx.conf > $NGINX_RUNTIME/conf/p-nginx.conf

#$OPENRESTY_HOME/nginx/sbin/nginx -p `pwd`/ -c conf/p-nginx.conf
$OPENRESTY_HOME/nginx/sbin/nginx -p $NGINX_RUNTIME/ -c conf/p-nginx.conf

echo "start nginx!"
