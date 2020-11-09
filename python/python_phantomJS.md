### 常用配置
```
from selenium import webdriver
# 引入配置对象DesiredCapabilities
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
dcap = dict(DesiredCapabilities.PHANTOMJS)
#从USER_AGENTS列表中随机选一个浏览器头，伪装浏览器
dcap["phantomjs.page.settings.userAgent"] = (random.choice(USER_AGENTS))
# 不载入图片，爬页面速度会快很多
dcap["phantomjs.page.settings.loadImages"] = False
# 设置代理
service_args = ['--proxy=127.0.0.1:9999','--proxy-type=socks5']
#打开带配置信息的phantomJS浏览器
driver = webdriver.PhantomJS(phantomjs_driver_path, desired_capabilities=dcap,service_args=service_args)                
# 隐式等待5秒，可以自己调节
driver.implicitly_wait(5)
# 设置10秒页面超时返回，类似于requests.get()的timeout选项，driver.get()没有timeout选项
# 以前遇到过driver.get(url)一直不返回，但也不报错的问题，这时程序会卡住，设置超时选项能解决这个问题。
driver.set_page_load_timeout(10)
# 设置10秒脚本超时时间
driver.set_script_timeout(10)

链接：http://www.jianshu.com/p/9d408e21dc3a
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

### 多进程
```
from multiprocessing import Pool
pool = Pool(8)
data_list = pool.map(get, url_list)
pool.close()
pool.join()
```

### 内存管理
```
try:
    self.driver.get(url)
    self.wait_()
    return True
except Exception as e:
    return False
```