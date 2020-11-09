-- 公共方法 
local cjson = require "cjson"
local redis = require "resty.redis"


local response_success = {
    status=0,
    msg='success',
    data={}
}

ngx.req.read_body()
local user_behavior = {
    timestamp                   = ngx.var.time_local or '',
    remote_addr                 = ngx.var.remote_addr or '',
    remote_user                 = ngx.var.remote_user or '',
    request_time                = ngx.var.time_iso8601 or '',
    --status                    = ngx.var.status or '',
    request                     = ngx.var.request or '',
    request_method              = ngx.var.request_method or '',
    http_referrer               = ngx.var.http_referer or '',
    --body_bytes_sent           = ngx.var.body_bytes_sent or '',
    http_x_forwarded_for        = ngx.var.http_x_forwarded_for or '',
    http_user_agent             = ngx.var.http_user_agent or '',
    query_string                = ngx.var.query_string or '',
    http_cookie                 = ngx.var.http_cookie or '',
    --http_header               = ngx.var.http_header or '',
    request_body                = ngx.req.get_body_data() or '',
    geoip_latitude              = ngx.var.geoip_latitude or '',
    geoip_longitude             = ngx.var.geoip_longitude or '',
    geoip_country_code          = ngx.var.geoip_country_code or '',
    geoip_city                  = ngx.var.geoip_city or '',
    geoip_city_country_code     = ngx.var.geoip_city_country_code or '',
    geoip_city_country_name     = ngx.var.geoip_city_country_name or '',
    geoip_city_continent_code   = ngx.var.geoip_city_continent_code or '',
    geoip_country_code3         = ngx.var.geoip_country_code3 or '',
    geoip_city_country_code3    = ngx.var.geoip_city_country_code3 or '',
    geoip_country_name          = ngx.var.geoip_country_name or ''
}

local red = redis:new()
local ok, err = red:connect("127.0.0.1", 6379)

local user_behavior_redis_key = 'user_behavior_list'

if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local _res, _err = red:rpush(user_behavior_redis_key, cjson.encode(user_behavior))
if not _res then
    ngx.say('failed to rpush: ', _err)
    return
end

ngx.say(cjson.encode(response_success))

--debug('key', 'value')
--ngx.say(ngx.var.remote_addr)
--ngx.say(cjson.encode(response_success))
--ngx.say(cjson.encode(user_behavior))
--ngx.say("lua redis tes88888tss9999ssssssssssssss-")
