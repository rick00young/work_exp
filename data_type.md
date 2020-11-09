## 基本类型char,int,float,double在内存中占用的大小

short、int、long、char、float、double 这六个关键字代表C 语言里的六种基本数据类型。

在不同的系统上，这些类型占据的字节长度是不同的：

在32 位的系统上

* short 占据的内存大小是 2 个byte；
* int 占据的内存大小是 4 个byte；
* long 占据的内存大小是 4 个byte；
* float 占据的内存大小是 4 个byte；
* double 占据的内存大小是 8 个byte；
* char 占据的内存大小是1 个byte。

在64 位的系统上

* short 占据的内存大小是 2 个byte；
* int 占据的内存大小是 4 个byte；
* long 占据的内存大小是 8 个byte；
* float 占据的内存大小是 4 个byte；
* double 占据的内存大小是 8 个byte；
* char 占据的内存大小是1 个byte。

具体可以用sizeof测试一下即可。