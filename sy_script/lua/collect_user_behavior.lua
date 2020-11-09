-- 公共方法 
local cjson = require "cjson"
--local redis = require "resty.redis"

local response_success = {
    status=0,
    msg='success',
    data={}
}
local ngx_env = ngx.var.ngx_env

ngx.req.read_body()
local header_info = {
    timestamp                   = ngx.var.time_local or '',
    remote_addr                 = ngx.var.remote_addr or '',
    remote_user                 = ngx.var.remote_user or '',
    request_time                = ngx.var.time_iso8601 or '',
    request                     = ngx.var.request or '',
    request_method              = ngx.var.request_method or '',
    http_referrer               = ngx.var.http_referer or '',
    http_x_forwarded_for        = ngx.var.http_x_forwarded_for or '',
    http_user_agent             = ngx.var.http_user_agent or '',
    query_string                = ngx.var.query_string or '',
    http_cookie                 = ngx.var.http_cookie or '',
    request_body                = ngx.req.get_body_data() or '',
}


local geo_info = {
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


local device_info = {}
local behavior_info = {}

local query_dic = ngx.req.get_uri_args()
local request_dic = ngx.req.get_post_args()

local platform =  query_dic['platform'] or nil
platform = platform or (request_dic['platform'] or nil)
platform = platform or ''


for k, v in pairs(query_dic) do
    if not request_dic[k] then
        request_dic[k] = v
    end
end

-- for iso
if 'android' ~= platform then
    local event_time = request_dic['event_time'] or ''
    event_time = string.gsub(event_time, "(%s+)", '+')
    request_dic['event_time'] = event_time
end

local device_keys = {
            'os',
            'osv',
            'ostype',
            'app',
            'appv',
            'platform',
            'udid',
            'macid',
            'net',
            'mcc',
            'mnc',
            'lac',
            'cid',
            'bsss',
            'ip',
            'brand',
            'model',
}

for k,v in ipairs(device_keys) do
    if(request_dic[v]) then
        device_info[v] = request_dic[v]
        request_dic[v] = nil
    end
end

local user_id   = request_dic['user_id']
local event         = request_dic['event']
local event_time    = request_dic['event_time']
local action        = request_dic['action']
local channel       = request_dic['channel']

request_dic['user_id'] = nil
request_dic['event'] = nil
request_dic['event_time'] = nil
request_dic['action'] = nil
request_dic['channel'] = nil

for k,v in pairs(request_dic) do
    if(v) then
        behavior_info[k] = v
    end
end

local user_behavior = {
    user_id = user_id,   
    event = event,     
    event_time = event_time,
    action    = action,
    channel  = channel,
    geo_info = geo_info,
    header_info = header_info,
    device_info = device_info,
    behavior_info = behavior_info        
 }


local log_dir = '/Users/rick/var/log/user_behavior/'
if 'product' == ngx_env then
    log_dir = '/opt/bi/user_behavior/'
end

local log_file = log_dir .. 'user_behavior_' .. os.date('%Y%m%d%H')  .. '.log'
local _file, _error = io.open(log_file, 'a+')
if not _file then
    ngx.say(_error)
    return
end
local _res, _error = _file:write(cjson.encode(user_behavior) .. "\n")

_file:close()

-- ngx.say(cjson.encode(user_behavior))
ngx.say(cjson.encode(response_success))

