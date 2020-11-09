## EChart for Spluck
```
https://github.com/gangtao/echarts_for_splunk/tree/v1.0
http://zkread.com/article/1317716.html

http://docs.splunk.com/Documentation/Splunk/6.0.1/Alert/Definescheduledalerts#Schedule_the_alert

source="drinks.csv" host="ricks-MacBook-Pro.local" sourcetype="echart_drink.csv" | table country, wine_servings,  beer_servings, spirit_servings,total_litres_of_pure_alcohol
  | head 5

```

## Splunk Search
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open | fields channel udid |dedup 1 channel udid | timechart span=1d count by channel
```

## 解析从pgsql导出的数据，数据中部分字段为json格式，将这样的字段解析成json
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open | rex "geo_info=\"(?<geo_info>.+)\", header_info=" | spath input=geo_info | table geo_info
```

## 城市地理位置解析
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open | dedup 1 channel udid | rex "geo_info=\"(?<geo_info>.+)\", header_info=" | fields geo_info |eval _raw=geo_info | spath input=geo_info | timechart span=1d count by geoip_city

index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open | dedup 1 channel udid | rex "geo_info=\"(?<geo_info>.+)\", header_info=" | fields geo_info |eval _raw=geo_info | spath input=geo_info | geostats latfield=geoip_latitude longfield=geoip_longitude count
```

## feed_click report
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=feed_on_entry referer != '' |eval feed_type=case(
referer == "feed/comment", "乐评",
referer == "feed/hot", "精选",
referer == "feed/listen_top", "收听榜",
referer == "feed/new", "最新",
referer == "feed/question", "问答",
referer == "feed/ranklist", "榜单",
referer == "feed/ranklist-new", "新榜单",
referer == "feed/recommend", "推荐",
referer == "feed/sale", "销量榜",
referer == "feed/star", "明星",
referer == "feed/topic", "话题") | timechart span=1d count by feed_type
```

## 统计去留

```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open earliest=-4d@d latest=-3d@d | dedup 1 channel udid |fields udid | eval zero=1 | join type=outer udid [search index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open earliest=-3d@d latest=-2d@d | dedup 1 channel udid | eval first=1 | table udid first] | stats sum(zero) as zero_sum, sum(first) as first_sum | eval first_day_ratio = first_sum/zero_sum*100 | table *


index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open earliest=-31d latest=-30d | dedup 1 channel udid |fields udid | eval zero=1
| join type=outer udid [search index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open earliest=-30d latest=-29d | dedup 1 channel udid | eval first=1 | table udid first]
| join type=outer udid [search index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open earliest=-29d latest=-28d | dedup 1 channel udid | eval second=1 | table udid second]
| stats sum(zero) as zero_sum, sum(first) as first_sum, sum(second) as second_sum
| eval first_ratio = first_sum/zero_sum*100, second_raio=second_sum/zero_sum*100


convert mktime(_time) AS ms_time | table ms_time

| convert mktime(_time) AS s_time | where s_time > 1484236800 and s_time < 1484323199| table _time

convert mktime(_time) AS s_time | where s_time > 1484236800 and s_time < 1484323199| table _time

convert timeformat='%Y-%m-%d' mktime('2017-01-13') AS ms_time | table ms_time

index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_open platform="ios" | dedup 1 channel udid | fields udid  | convert mktime(_time) AS s_time | where s_time >= 1484236800 and s_time <= 1484323199 | table _time

```

```
source="/Users/rick/service/splunk/splunk_data/feed/last_rank_listen_count.csv" host="ricks-MacBook-Pro.local" index="last_rank_listen_count" sourcetype="csv" earliest=-3h latest=-2h | join works_id [ | search source="/Users/rick/service/splunk/splunk_data/feed/last_rank_listen_count.csv" host="ricks-MacBook-Pro.local" index="last_rank_listen_count" sourcetype="csv" earliest=-2h latest=-h | eval listen_count=play_num | table works_id listen_count]
| eval top_hot_=if(top_hot == 1, "热度榜", "") | eval top_origin_=if(top_origin == 1, "原创榜", "") | eval top_cover_=if(top_cover ==  1, "翻唱榜", "") | eval top_video_=if(top_video == 1, "视频榜", "") | eval rank_type= top_hot_ ."_". top_origin_ ."_". top_cover_ ."_". top_video_ | eval increase_ratio=listen_count/play_num | table  title, works_id, rank_type, play_num,, listen_count , increase_ratio | sort +increase_ratio | rename increase_ratio as 两小时增长
```

### 用户活跃度
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior platform=android | fields behavior_event udid platform |stats count by udid  | sort -count | rename count as "活跃度" |table *

index=behavior source=suiyue_behavior sourcetype=suiyue_behavior platform=android AND (channel=yingyongbao1 OR channel= yingyongbaofufei1 OR channel= chuanbo1) | fields behavior_event udid platform |stats count by udid  | sort -count | rename count as "活跃度" |table *

index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event = device_on_activate platform=ios | fields platform channel udid | stats count by udid

```


### test
```
| savedsearch "tbl_suiyuedb_user_relation" relation_type=1 | top 100 to_user_id | join type=left to_user_id [| savedsearch "tbl_suiyuedb_user" | rename id as to_user_id | table to_user_id, nickname] | table to_user_id, nickname, count, percent | rename count as 粉丝数, nickname as 用户名称, to_user_id as 用户id, percent as 占比


| savedsearch "tbl_suiyuedb_user" | rename id as to_user_id | table to_user_id, nickname | join type=left to_user_id [| savedsearch "tbl_suiyuedb_user_relation" relation_type=1 | top 100 to_user_id] | table to_user_id, nickname, count, percent | rename count as 粉丝数, nickname as 用户名称, to_user_id as 用户id, percent as 占比


-------
碎乐单
| savedsearch "tbl_suiyuedb_user"  | rename id as user_id | table user_id, nickname| join user_id  [| savedsearch "tbl_suiyuedb_play_list" | top 100 user_id | table user_id count percent] | sort -count|rename count as 碎乐单, nickname as 用户名称, user_id as 用户id, percent as 占比

粉丝数
| savedsearch "tbl_suiyuedb_user"  | rename id as user_id | table user_id, nickname| join user_id  [| savedsearch "tbl_suiyuedb_user_relation"  | top 100 to_user_id |rename to_user_id as user_id |table user_id count percent] | sort -count|rename count as 粉丝数, nickname as 用户名称, user_id as 用户id, percent as 占比
```


###审核作品数

```
|dbxquery query="select count(*) as dc, date_trunc('day', create_time::TIMESTAMP without time zone) as ts from works where status=2 group by ts order by ts" connection="suiyue_db" shortnames="yes" | eval _time=strptime(ts,"%Y-%m-%d %H:%M:%S") | eval weeknumber= tonumber(strftime(_time,"%U"))+1,monthnumber=strftime(_time,"%m"),yearnumber=strftime(_time,"%Y") | timechart span=1d values(dc) as 审核通过作品数
```

```

1.index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= subscribe_channel_on_entry | rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info | eval _raw=behavior_info | spath input=behavior_info | rename item_id as channel_id | stats count by channel_id | join type=left channel_id [| savedsearch "tbl_suiyuedb_channel" | rename id as channel_id | table channel_id,name] | table name channel_id count| sort -count |rename count as 浏览数, channel_id as 频道id, name as 频道名称

2.index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= subscribe_btn_on_click | rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info | eval _raw=behavior_info | spath input=behavior_info | rename item_id as channel_id | stats count by channel_id | join type=left channel_id [| savedsearch "tbl_suiyuedb_channel" | rename id as channel_id | table channel_id,name] | table name channel_id count| sort -count |rename count as 点击数, channel_id as 频道id, name as 频道名称

3.index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= guess_like_on_click | rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info | eval _raw=behavior_info | spath input=behavior_info | rename item_id as works_id | stats count by works_id | join works_id [| savedsearch "snap_suiyuedb_works_dbxquery" | rename id as works_id | table works_id,title] | table title works_id count| sort -count |rename count as 浏览数, works_id as 作品id, title as 作品名称

4.index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= subscribe_channel_on_entry | rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info | eval _raw=behavior_info | spath input=behavior_info | rename item_id as channel_id | stats count by channel_id | join type=left channel_id [| savedsearch "tbl_suiyuedb_channel_dbxquery" | rename id as channel_id | table channel_id,name] | table name channel_id count| sort -count | rename count as 点击数, channel_id as 频道id, name as 频道名称
```

### 根据版本号，时间，查数据
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=feed_on_entry referer != "" |rex "device_info=\"(?<device_info>.+)\", behavior_info=" | fields device_info, referer | eval json_data=device_info | spath input=json_data  | where appv=172  |eval feed_type=case(
referer == "feed/comment", "乐评",
referer == "feed/hot", "精选",
referer == "feed/listen_top", "收听榜",
referer == "feed/new", "最新",
referer == "feed/question", "问答",
referer == "feed/ranklist", "榜单",
referer == "feed/ranklist-new", "新榜单",
referer == "feed/recommend", "推荐",
referer == "feed/sale", "销量榜",
referer == "feed/star", "明星",
referer == "feed/topic", "话题") | timechart span=1d count by feed_type
```

```
SELECT create_time::TIMESTAMP without time zone as ts, * FROM "node_music_weapon"."public"."works_playtimes"


|dbxquery query="select count(*) as dc, date_trunc('day', create_time::TIMESTAMP without time zone) as ts from works_playtimes group by ts order by ts" connection="suiyue_db" shortnames="yes" | eval _time=strptime(ts,"%Y-%m-%d %H:%M:%S") | eval weeknumber= tonumber(strftime(_time,"%U"))+1,monthnumber=strftime(_time,"%m"),yearnumber=strftime(_time,"%Y") | timechart span=1d values(dc) as 每日播放量
```

### 每日作品收听报表
```
| savedsearch "tbl_suiyuedb_play_times" | top 200 works_id | rename count as listen_num | join type=outer works_id [search index="suiyuedb"  sourcetype="suiyuedb_works" earliest=-5y latest=now | rename id as works_id | table works_id,title] | table works_id title listen_num | rename works_id as 作品id, title as 作品名称, listen_num as 试听次数
```

### 每日搜索热词报表
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= search_on_display | rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info | eval _raw=behavior_info | spath input=behavior_info | where event_result=1 | stats count by item | sort -count | head 300 | rename item as 搜索词语, count as 搜索次数
```

####
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= feed_on_out |
eval feed_type=case(
referer == "feed/comment",
 "乐评", referer == "feed/hot",
 "精选", referer == "feed/listen_top",
 "收听榜", referer == "feed/new",
 "最新", referer == "feed/question",
 "问答", referer == "feed/ranklist",
 "榜单", referer == "feed/ranklist-new",
 "新榜单", referer == "feed/recommend",
 "推荐", referer == "feed/sale",
 "销量榜", referer == "feed/star",
 "明星", referer == "feed/topic",
 "话题") | timechart span=1d c(udid) as feed_count by feed_type
```

### null 过滤
```
| savedsearch "tbl_subscribe_channel" | where isnotnull(order_no) | `apply_timerange(_time)` | eval statusname=case( status == 0, "取消订阅", status == 1, "订阅")  | timechart span=1d count by statusname
```

### feed uv pv
```
uv:
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= feed_on_out | timechart span=1d dc(udid) by referer
| rename feed/comment as 乐评, feed/follow as 关注, feed/hot as 推荐, feed/hot_question as 最热问答, feed/music_talk as 乐谈, feed/new as 最新, feed/hot_recommend as 热评, feed/question as 问答, feed/topic as 话题, feed/recommend as 乐评2

pv:
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= feed_on_out | timechart span=1d count by referer
| rename feed/comment as 乐评, feed/follow as 关注, feed/hot as 推荐, feed/hot_question as 最热问答, feed/music_talk as 乐谈, feed/new as 最新, feed/hot_recommend as 热评, feed/question as 问答, feed/topic as 话题, feed/recommend as 乐评2
```

### 添加关注音乐人加载数页数报表
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= follow_btn_on_click | where referer="musician" | rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info, udid | eval behavior=behavior_info | spath input=behavior| where page <= 10 | timechart span=1d count by page | rename 1 as 1页, 2 as 2页, 3 as 3页, 4 as 4页, 5 as 5页, 6 as 6页, 7 as 7页, 8 as 8页, 9 as 9页, 10 as 10页数
```

### 开屏广告页统计
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= launch_graph_on_click | rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info, udid | eval behavior=behavior_info | spath input=behavior| timechart span=1d count by event_result | rename 0 as 默认, 1 as 进入, 2 as 跳过
```


### 首叶入口统计
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=home_sub_on_entry | timechart span=1d count by referer | addtotals |rename me as 我, upload as 上传, search as 搜索, player as 播放器, Total as 总量
```

### 频道统计
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= subscribe_channel_on_entry | timechart span=1d count by referer | addtotals | rename channel_all as 全部频道, channel_apply as 频道申请, channel_entry as 进入频道, channel_me as 我的频道, channel_subscribed as 已定阅频道, Total as 总量
```

### 作品下载数统计
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= works_download_on_start | rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info, udid | eval behavior=behavior_info | spath input=behavior| stats count by item_id | sort -count | join type=outer item_id [search index="suiyuedb"  sourcetype="suiyuedb_works" earliest=-5y latest=now | rename id as item_id | table item_id,title] | rename item_id as 作品id, count as 下载数, title as 作品名称
```

### display_position
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=works_detail_on_entry platform=android referer=feed/hot| rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info, udid, referer | eval behavior=behavior_info | spath input=behavior|stats count by display_position | where display_position < 60 AND display_position > 0 | rename display_position as position
```

### 位置转化率
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=works_detail_on_entry referer=feed/music_talk| rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info, udid, referer | eval behavior=behavior_info | spath input=behavior|stats count by display_position | where display_position < 60 AND display_position > 0 | sort display_position|rename display_position as position  |eval load_num=[|search index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=feed_on_out referer=feed/music_talk| rex "behavior_info=\"(?<behavior_info>.+)\", geo_info=" | fields behavior_info, udid, referer | eval behavior=behavior_info | spath input=behavior |  stats sum(page) as page_num | eval page_num=page_num*20 | return $page_num] | eval ratio=count/load_num | rename position as 卡片位置, count as 进入次数, load_num as 加载卡片数, ratio as 转化率
```

### 用户增长预测
```
source="suiyue_mta" | sort -ts | head 1 | rex mode=sed "s/\r?\n/--BREAKER--/g" | eval raw_lines=split(_raw, "--BREAKER--") | mvexpand raw_lines | fields raw_lines | eval _raw=raw_lines | spath input=_raw path=data.ret_data{} output=daily | rename data.ret_data.* as * | fields daily | eval _raw=daily | mvexpand daily | eval _raw=daily | spath | eval _time=strptime(date,"%Y-%m-%d") | timechart span=1d sum(ActiveUser) as DAU | predict DAU as Predict algorithm=LLP5 upper90=high lower97=low future_timespan=60 holdback=0 | eval Predict=round(Predict,0)
```

### Mobile Apps: What’s A Good Retention Rate?
	http://info.localytics.com/blog/mobile-apps-whats-a-good-retention-rate


### 时间转换
```
|stats count | addinfo | eval earliest=relative_time(info_max_time,"-7d@d") | eval latest=relative_time(info_max_time,"-1d@d") | eval next_time=relative_time("-1d@d","-7d@d") | convert ctime(info_max_time) as info_max_time, ctime(info_min_time) as info_min_time , ctime(earliest) ctime(latest)
```


### 导入imei号
```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_close platform=android |rex "device_info=\"(?<device_info>.+)\", geo_info=" | fields device_info | eval _raw=device_info | spath input=device_info | table imei | stats count by imei |sort -count
```

### 查看作品收藏用户udid
```
|dbxquery query="select l.works_id, l.user_id, l.create_time from works_like as l where works_id=80170" connection="suiyue_db" shortnames="true" | eval _time=strptime(ts,"%Y-%m-%d %H:%M:%S") |eval weeknumber= tonumber(strftime(_time,"%U"))+1,monthnumber=strftime(_time,"%m"),yearnumber=strftime(_time,"%Y") | table works_id, user_id, create_time |join type=outer user_id [search index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_close |where isnotnull(udid)| table user_id udid]

```


## for backup
```
source="/opt/splunk/etc/apps/suiyue_bi/test_bi/splunk_report_test.csv" host="iZ25dk22zoxZ" index="splunk_report_test" sourcetype="splunk_report_test" | table _time


source="/opt/splunk/etc/apps/suiyue_bi/h5_bi/h5_dau.csv" host="iZ25dk22zoxZ" index="h5_dau_index" sourcetype="h5_dau.csv" | fields pv uv vv iv | timechart span=1d values(pv) as 浏览数 values(uv) as 独立访客 values(vv) as 访问次数 values(iv) as 访问IP

index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= user_event_on_edit | timechart span=1d count(id) as PV,dc(udid) AS UV


index="suiyuedb"  sourcetype="suiyuedb_subscribe_channel" | eval weeknumber= tonumber(strftime(_time,"%U"))+1,monthnumber=strftime(_time,"%m"),yearnumber=strftime(_time,"%Y")


|dbxquery query="select count(*) as dc, date_trunc('day', create_time::TIMESTAMP without time zone) as ts from works_comment group by ts order by ts" connection="suiyue_db" shortnames="yes" | eval _time=strptime(ts,"%Y-%m-%d %H:%M:%S") | eval weeknumber= tonumber(strftime(_time,"%U"))+1,monthnumber=strftime(_time,"%m"),yearnumber=strftime(_time,"%Y") | timechart span=1d values(dc) as 每日评论量


index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=feed_on_entry feed/user_event earliest=-6d latest=@d| timechart span=1d count(id) as pv,dc(udid) AS uv|eval day_time=strftime(_time, "%Y-%m-%d %H:%M")


index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=feed_on_entry feed/user_event earliest=-1d latest=@d| timechart span=1d count(id) as pv,dc(udid) AS uv|eval day_time=strftime(_time, "%Y-%m-%d %H:%M:%S") |dbxoutput output="suiyue_report_pv_test"

SELECT to_timestamp(create_time) as ts, event_time, create_time, request_time_stamp FROM "node_music_bi"."public"."user_behavior"

index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=feed_on_entry feed/user_event earliest=-1d latest=@d| timechart span=1d count(id) as pv,dc(udid) AS uv|eval day_time=_time |eval report_type=1 |dbxoutput output="suiyue_report_pv"

SELECT to_timestamp(day_time) as ts, * FROM "node_music_bi"."public"."sy_report_pv_uv";


index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event= user_event_on_edit | timechart span=1d count(id) as PV,dc(udid) AS UV | sort -_time

index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_user_event_comment | timechart span=1d count as 评论数,dc(user_id) as 评论人数,dc(user_event_id) as 被评论的动态数| sort -_time

index=ix_suiyuebi source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=db_event_like status=1 | timechart span=1d count as 点赞数,dc(user_id) as 点赞用户数,dc(dest_id) as 被点赞动态数 | sort -_time

<!--获取作品信息及点赞评论数-->
index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_works earliest=-1d@d latest=@d| table ts,id,title | rename id as works_id | sort ts  |  join type=outer works_id [search index=ix_suiyuebi source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=db_works_comment status=0 earliest=-1d@d| stats count as cnt_comment by works_id] | join type=outer works_id [search index=ix_suiyuebi source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=db_works_like  earliest=-1d@d| eval cnt_like=case(status==1,1) | eval cnt_unlike=case(status==0,1) | stats sum(cnt_like) as cnt_like,sum(cnt_unlike) as cnt_unlike by works_id]  | join type=outer works_id [search index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_play_times earliest=-1d@d | stats count as cnt_playtimes by works_id ] | table ts,works_id,title,cnt_playtimes,cnt_comment,cnt_like,cnt_unlike| sort -cnt_playtimes | rename ts as 上传时间, works_id as 作品id, title as 作品名称, cnt_playtimes as 播放次数, cnt_comment as 评论数, cnt_like as 点赞数, cnt_unlike as 点赞后取消数

<!--获取设备版本号-->
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=device_on_activate OR behavior_event=device_on_active channel=yunos1  | fields platform channel udid |rex "device_info=\"(?<device_info>.+)\", geo_info=" | fields device_info| eval dd=device_info | spath input=dd | table *

<!--获取imei号-->
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_close | fields platform channel udid |rex "device_info=\"(?<device_info>.+)\", geo_info=" | fields device_info| eval dd=device_info | spath input=dd | where imei!="" | dedup 1 imei | table imei

<!--点赞数-->
index=ix_suiyuebi source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=db_event_like status=1 | timechart span=1d count as 点赞数,dc(user_id) as 点赞用户数,dc(dest_id) as 被点赞动态数 | sort -_time

<!--评论数-->
index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_user_event_comment | timechart span=1d count as 评论数,dc(user_id) as 评论人数,dc(user_event_id) as 被评论的动态数| sort -_time

<!--DJ评论数-->
index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_user (id=1351) OR (id=80711) OR (id=76926) OR (id=77242) OR (id=78121) OR (id=84567) OR (id=1306) OR (id=2697) OR (id=82376) OR (id=77250) OR (id=1301) OR (id=77252) OR (id=1143) OR (id=82184) OR (id=1260) OR (id=77247) OR (id=1544) OR (id=89085) OR (id=77255) OR (id=80967) OR (id=77510) OR (id=80628) OR (id=4930) OR (id=7137) OR (id=93550) OR (id=77246) OR (id=76920) OR (id=4863) OR (id=1336) OR (id=378234) OR (id=77264)  earliest=01/01/2016:0:0:0 latest=06/20/2017:0:0:0| table id,nickname| rename id as user_id | join type=inner user_id[search index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_recommend | stats count by user_id| table user_id,count]

<!--运营-每日播放-->
index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_play_times | eval daynum=strftime(_time,"%Y-%m-%d") | eval ios=if(platform=1,if(len(uuid)>0,uuid,1),NULL) | eval android=if(platform=2,if(len(uuid)>0,uuid,1),NULL) | eval iosapp=if(platform=1,uuid,NULL) | eval androidapp=if(platform=2,uuid,NULL) | eval web=if(platform!=1 AND platform!=2,ts,NULL) | stats count as total,dc(works_id) as works,count(ios) as ios_total,count(iosapp) as ios_app,dc(ios) as ios_app_user,count(android) as android_total,count(androidapp) as android_app,dc(android) as android_app_user,count(web) as H5 by daynum | eval avgios=ios_app/ios_app_user | eval avgandroid=android_app/android_app_user | table daynum,total,works,ios_total,ios_app,ios_app_user,avgios,android_total,android_app,android_app_user,avgandroid,H5 | sort -daynum | rename daynum as 统计日期 | rename total as 总播放数 | rename ios_total as ios播放数 | rename ios_app as iosAPP播放数 | rename ios_app_user as iosAPP播放用户数 | rename avgios as iosAPP人均播放数 | rename android_total as android播放数 | rename android_app as androidAPP播放数 | rename android_app_user as androidAPP播放用户数 | rename avgandroid as androidAPP人均播放数 | rename H5 as H5播放数 | rename works as 被播放作品数


<!--昨日上线作品数据-->
index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_works earliest=-1d@d latest=@d| table ts,id,title | rename id as works_id | sort ts  |  join type=outer works_id [search index=ix_suiyuebi source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=db_works_comment status=0 earliest=-1d@d| stats count as cnt_comment by works_id] | join type=outer works_id [search index=ix_suiyuebi source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=db_works_like  earliest=-1d@d| eval cnt_like=case(status==1,1) | eval cnt_unlike=case(status==0,1) | stats sum(cnt_like) as cnt_like,sum(cnt_unlike) as cnt_unlike by works_id]  | join type=outer works_id [search index=suiyuedb source=/opt/splunk/var/log/splunk/dbx2.log sourcetype=suiyuedb_play_times earliest=-1d@d | stats count as cnt_playtimes by works_id ] | table ts,works_id,title,cnt_playtimes,cnt_comment,cnt_like,cnt_unlike| sort -cnt_playtimes | rename ts as 上传时间, works_id as 作品id, title as 作品名称, cnt_playtimes as 播放次数, cnt_comment as 评论数, cnt_like as 点赞数, cnt_unlike as 点赞后取消数

<!---->
```

#### 城市地区dau

```
index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_close | rex "geo_info=\"(?<geo_info>.+)\", header_info=" | fields geo_info |eval _raw=geo_info | spath input=geo_info | timechart span=1d count by geoip_city


index=behavior source=suiyue_behavior sourcetype=suiyue_behavior behavior_event=app_on_close | rex "geo_info=\"(?<geo_info>.+)\", header_info=" | fields geo_info |eval _raw=geo_info | spath input=geo_info |table geoip_city|where geoip_city!="" |stats count by geoip_city | sort -count |head 300
```


```
index=algo_ad_report sourcetype=algo_report source=algo_test_mysql | where report_ad_type = 1 and (report_type = 1 or report_type = 11 or report_type = 21) and report_date = 20180604 and report_key < 24 | eval report_value=if(report_type == 1, report_value*6, report_value) | eval report_value=if(report_type == 21, report_value*6, report_value) | chart values(report_value) as V by  report_key report_type | rename 1 as A-apply, 11 as B-apply, 21 as C-apply, report_key as hours


index=algo_ad_report sourcetype=algo_report source=algo_test_mysql earliest=-0d@d | where report_ad_type = 1 and (report_type = 7 or report_type = 17 or report_type = 27) and report_key < 24 | chart values(report_value) as V by  report_key report_type | rename 7 as "A-ecpm_bid", 17 as "B-ecpm_bid", 27 as "C-ecpm_bid", report_key as hours
```


```
index=algo_ad_report sourcetype=algo_report source=algo_test_mysql | where report_ad_type = 3 and (report_type = 73 or report_type = 93 or report_type = 113 or report_type = 83 or report_type = 103 or report_type = 123) and report_key = 24 | table report_type, report_date, report_value | chart sum(report_value) BY  report_date report_type | addtotals row=t fieldname="cash_123" 73 93 113 | addtotals  row=t fieldname="cash_45" 83 103 123 | table report_date, cash_123, cash_45 | join type=inner report_date [search index=algo_ad_report sourcetype=algo_report source=algo_test_mysql | where report_ad_type = 3 and (report_type = 79 or report_type = 99 or report_type = 119 or report_type = 89 or report_type = 109 or report_type = 129) and report_key = 24 | table report_type, report_date, report_value | chart sum(report_value) BY  report_date report_type | addtotals row=t fieldname="expo_123" 79 99 119 | addtotals  row=t fieldname="expo_45" 89 109 129 | table report_date, expo_123, expo_45] | eval ecpm_cash_123=cash_123/expo_123*1000 | eval ecpm_cash_45=cash_45/expo_45*1000 | table report_date, ecpm_cash_123, ecpm_cash_45 |chart values(ecpm_cash_123) as ecpm_cash_123, values(ecpm_cash_45) as ecpm_cash_45 by report_date

index=algo_ad_report sourcetype=algo_report source=algo_test_mysql earliest=-7d@d | where report_ad_type = 1 and (report_type = 2 or report_type = 12 or report_type = 22) and report_key = 24 | eval report_type=report_type+7  |rename report_value as bid | join type=inner report_date report_type [search index=algo_ad_report sourcetype=algo_report source=algo_test_mysql earliest=-7d@d | where report_ad_type = 1 and (report_type = 9 or report_type = 19 or report_type = 29) and report_key = 24 |rename report_value as expo] | eval ecpm_bid=bid/expo*1000 | table ecpm_bid bid expo report_date report_key report_type | chart values(ecpm_bid) as "ecpm_bid(收入/曝光)" by report_date report_type | rename 9 as "A-ecpm_bid", 19 as "B-ecpm_bid", 29 as "C-ecpm_bid", report_date as day

```