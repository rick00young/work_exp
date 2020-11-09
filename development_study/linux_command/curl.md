### 获取站点的各类响应时间
```
curl -o /dev/null -s -w %{http_code}:%{http_connect}:%{time_namelookup}:%{time_connect}:%{time_pretransfer}:%{time_starttransfer}:%{time_total}:%{size_download}:%{speed_download} www.ttlsa.com
```