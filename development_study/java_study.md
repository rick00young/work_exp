# Java常用知识

### 有CentOS下装openjdk
```
yum install -y java-1.8.0-openjdk


java接口的方法全部都是public。不存在默认的权限

```
#### Annotation
```
@FunctionalInterface 此为函数式接口，只能够定义一个方法

	interface IMessage<R> {
		public R upper();
	}
```
### java8方法引用
```
1. 引用表态方法： 类名称 :: static 普通方法
2. 引用某个对象的方法:  实例化对象 :: 普通方法
3. 引用特定类型方法: 特定类 :: 普通方法
4. 引用构造方法: 类名称 :: new
```

### 内建函数式接口
```
1. 功能性接口（Function）: public interface Function <T,R>{public R apply(T r)};此接口需要一个参数，并且返回一个处理结果
2. 消费性接口（Consumer）: public interface Consumer<T> {public void accept(T r)};此接口只负责接收数据（引用数据不需要反回），并且不返回处理结果
3. 供给型接口（Supplier）: public inteface Supplier<T>{public T get()};此接口不接收参数，但是可以返回结果
4. 断言型接口（Predicate）: public interface Predict<T>{public boolean test(T t)};进行判断操作使用 
```

### java多线程
```
继承Thread类
实现Runnable接口
Callable接口(可以返回操作结果)

Thread与Runnable的区别或多线程两种实现方式的区别？
1.Thread是Runnable接口的子类，使用Runnable接口实现多线程可以避免单继承
2.Runnable实现的多线程比Thread类实现在的多线程更加清楚的描述数据共享的概念
```

### 多线程资源共享
	多个线程访问同一资源时一定要处理好同步，可能使用同步代码或是同步方法来解决
	> 同步代码块
	> 同步方法
	但是过多地使用同步，有可能千万死锁
	
### sleep() 与 wait()
	sleep()是Thread类的方法，而wait()是object类的方法
	sleep()可以设置休眠时间，时间一到自动唤醒，而wait()需要等待notify()进行唤醒
	
### String类
	String类的两种实例化方式：
		直接赋值：只开辟一块堆内存空间，可以自动入池
		构造方法：开辟两块堆内存空间，不会自动入池，需要intern()手工入池
	任何一个字符串都是String类的匿名对象；
	字符串一旦声明则不可改变，能改变的只是它的引用；

### StringBuffer
	可以修改字符串的内容
	
### 关键字
	final 关键字，定义不能被继承的类，不能被覆写的方法，常量
	finally 关键字，异常的统一出口
	finalize 方法，Object类提供的方法，类销毁时的收尾工作，即使出现了异常也不会导致程序中断执行。
	
### 对象比较
	1. 如果对象数据要进行排序那么必须设置排序规则，可以使用Comparable或Comparator
	2. java.lang.Comparable是一个类定义的时候实现好的接口，这样本类数组对象接口下定义一个public int compareTo()的方法
	3. java.util.Comparator是专门定义一个指定类的比较规则

	
### 正则表达式
在java.util.regix
	1. Pattern类： 此类对象如果要想取得必须使用compile对象
	2. Matcher类：通过Pattern类取得

### 反射
	1. 解耦合，提升扩展性

### java HashMap keys join
```
Map<String,String> mm = new HashMap<String,String>();
     mm.put("a", "a");
     mm.put("b", "b");
     mm.put("c", "c");
     
     String[] arr = mm.keySet().toArray(new String[0]);
     Arrays.sort(arr);
     
     List<String> listStrings = Arrays.asList(arr);
     String aaaa = String.join("_", arr);
     
     System.out.println(aaaa);
     System.out.println(String.join("-", keys_list));
     
```

### java md5
```
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class MD5Util {
 public static String encrypteMD5(String str) {
  try {
   /* 获得MD5摘要算法的 MessageDigest 对象 */
   MessageDigest md5 = MessageDigest.getInstance("MD5");
   /* 使用指定的字节更新摘要 */
   md5.update(str.getBytes());

   /* 获得密文 */
   byte[] md = md5.digest();

   /* 把密文转换成十六进制的字符串形式 */
   StringBuffer hexString = new StringBuffer();
   /* 字节数组转换为 十六进制数 */
   for (int i = 0; i < md.length; i++) {
    String shaHex = Integer.toHexString(md[i] & 0xFF);
    if (shaHex.length() < 2) {
     hexString.append(0);
    }
    hexString.append(shaHex);
   }
   return hexString.toString();
  } catch (NoSuchAlgorithmException e) {
   return null;
  }
 }
 
 public static void main(String[] strs){
  System.out.println(MD5Util.encrypteMD5("11"));
 }
}
```

### java 获取环境变量
```
System.out.println("");
Map<String,String> map = System.getenv();
Set<Map.Entry<String,String>> entries = map.entrySet();
for (Map.Entry<String, String> entry : entries) {
    System.out.println(entry.getKey() + ":" + entry.getValue());
}
System.out.println("========");
System.out.println(map.get("ALGO_ENV"));
```
	