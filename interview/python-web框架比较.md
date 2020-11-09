# python web框架比较
## Django
* 注重高效开发
* 全自动化的管理后台（只需要使用起ORM，做简单的定义，就能自动生成数据库结构，全功能的管理后台）
* session功能

## Tornado
* 注重性能优越，速度快
* 解决高并发
* 异步非阻塞
* websockets 长连接
* 内嵌了HTTP服务器
* 单线程的异步网络程序，默认启动时根据CPU数量运行多个实例；利用CPU多核的优势。


## Flask 和 Django 的比较
1. Flask

* Flask 确实很“轻”，不愧是 Micro Framework ，从 Django 转向 Flask 的开发者一定会如此感慨，除非二者均为深入使用过
* Flask 自由、灵活，可扩展性强，第三方库的选择面广，开发时可以结合自己最喜欢用的轮子，也能结合最流行最强大的 Python 库
* 入门简单，即便没有多少 web 开发经验，也能很快做出网站
* 非常适用于小型网站
* 非常适用于开发 web 服务的 API
* 开发大型网站无压力，但代码架构需要自己设计，开发成本取决于开发者的能力和经验
* 各方面性能均等于或优于 Django
* Django 自带的或第三方的好评如潮的功能， Flask 上总会找到与之类似第三方库
* Flask 灵活开发， Python 高手基本都会喜欢 Flask ，但对 Django 却可能褒贬不一
* Flask 与关系型数据库的配合使用不弱于 Django ，而其与 NoSQL 数据库的配合远远优于 Django
* Flask 比 Django 更加 Pythonic ，与 Python 的 philosophy 更加吻合

2. Django

* Django 太重了，除了 web 框架，自带 ORM 和模板引擎，灵活和自由度不够高
* Django 能开发小应用，但总会有“杀鸡焉用牛刀”的感觉
* Django 的自带 ORM 非常优秀，综合评价略强与 SQLAlchemy
* Django 自带的模板引擎简单好用，但其强大程度和综合评价略低于 Jinja
* Django 自带 ORM 也使 Django 与关系型数据库耦合度过高，如果想使用 MongoDB 等 NoSQL 数据，需要选取合适的第三方库，且总感觉 Django+SQL 才是天生一对的搭配， Django+NoSQL 砍掉了 Django 的半壁江山
* Django 目前支持 Jinja 等非官方模板引擎
* Django 自带的数据库管理 app 好评如潮
* Django 非常适合企业级网站的开发：快速、靠谱、稳定
* Django 成熟、稳定、完善，但相比于 Flask ， Django 的整体生态相对封闭
* Django 是 Python web 框架的先驱，用户多，第三方库最丰富，最好的 Python 库，如果不能直接用到 Django 中，也一定能找到与之对应的移植
* Django 上手也比较容易，开发文档详细、完善，相关资料丰富