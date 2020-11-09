## return 200 json
```
 /user_behavior {
          default_type application/json;
          return 200 '{"stauts": 0, "msg":"", "data":[]}';
      }
```

### collect_user_behavior
```
    location /user_behavior {
        default_type application/json;
        #content_by_lua_block {
        #    ngx.say("lua redis test")
        #}
        content_by_lua_file "lua/collect_user_behavior.lua";
        #return 200 '{"stauts": 0, "msg":"", "data":[]}';
    }
```
      
  
      
## nginx json_log
```
'{ "@timestamp": "$time_iso8601", '
                         '"@fields": { '
                         '"remote_addr": "$remote_addr", '
                         '"remote_user": "$remote_user", '
                         '"body_bytes_sent": "$body_bytes_sent", '
                         '"request_time": "$request_time", '
                         '"status": "$status", '
                         '"request": "$request", '
                         '"request_method": "$request_method", '
                         '"request_method": "$time_iso8601",'
                         '"http_referrer": "$http_referer", '
                         '"body_bytes_sent":"$body_bytes_sent", '
                         '"http_x_forwarded_for": "$http_x_forwarded_for", '
                         '"http_user_agent": "$http_user_agent",'
                         '"query_string": "$query_string",'
                         '"http_cookie" : "$http_cookie",'
                         '"http_header" : "$http_header",'
                         '"request_body": "$request_body",'
                         '"geoip_latitude":"$geoip_latitude",'
                         '"geoip_longitude":"$geoip_longitude",'
                         '"geoip_country_code":"$geoip_country_code",'
                         '"geoip_city":"$geoip_city",'
                         '"geoip_city_country_code":"$geoip_city_country_code",'
                         '"geoip_city_country_name":"$geoip_city_country_name",'
                         '"geoip_city_continent_code":"$geoip_city_continent_code",'
                         '"geoip_country_code3":"$geoip_country_code3",'
                         '"geoip_city_country_code3":"$geoip_city_country_code3",'
                         '"geoip_country_name":"$geoip_country_name"} }';
```

