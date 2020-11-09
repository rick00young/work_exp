# python中np.multiply（）、np.dot（）和星号（*）三种乘法运算的区别
为了区分三种乘法运算的规则，具体分析如下：

```
import numpy as np
```

## 1. np.multiply()函数
函数作用
> 数组和矩阵对应位置相乘，输出与相乘数组/矩阵的大小一致
  
### 1.1数组场景
```
A = np.arange(1,5).reshape(2,2)
A
array([[1, 2],
       [3, 4]])
B = np.arange(0,4).reshape(2,2)
B

array([[0, 1],
       [2, 3]])
np.multiply(A,B)       #数组对应元素位置相乘

array([[ 0,  2],
       [ 6, 12]])
```
### 1.2 矩阵场景
```
np.multiply(np.mat(A),np.mat(B))     #矩阵对应元素位置相乘，利用np.mat()将数组转换为矩阵
1
matrix([[ 0,  2],
        [ 6, 12]])
np.sum(np.multiply(np.mat(A),np.mat(B)))    #输出为标量
20
```
## 2. np.dot()函数
函数作用
> 对于秩为1的数组，执行对应位置相乘，然后再相加；

> 对于秩不为1的二维数组，执行矩阵乘法运算；超过二维的可以参考numpy库介绍。

### 2.1 数组场景
#### 2.1.1 数组秩不为1的场景
```
A = np.arange(1,5).reshape(2,2)
A

array([[1, 2],
       [3, 4]])
B = np.arange(0,4).reshape(2,2)
B

array([[0, 1],
       [2, 3]])
np.dot(A,B)    #对数组执行矩阵相乘运算

array([[ 4,  7],
       [ 8, 15]])
```
#### 2.1.2 数组秩为1的场景
```
C = np.arange(1,4)
C

array([1, 2, 3])
D = np.arange(0,3)
D


array([0, 1, 2])
np.dot(C,D)   #对应位置相乘，再求和

```

###2.2 矩阵场景
```
np.dot(np.mat(A),np.mat(B))   #执行矩阵乘法运算
1
matrix([[ 4,  7],
        [ 8, 15]])
```
## 3. 星号（*）乘法运算
作用
> 对数组执行对应位置相乘

> 对矩阵执行矩阵乘法运算

### 3.1 数组场景
```
A = np.arange(1,5).reshape(2,2)
A

array([[1, 2],
       [3, 4]])
B = np.arange(0,4).reshape(2,2)
B

array([[0, 1],
       [2, 3]])
A*B  #对应位置点乘
1
array([[ 0,  2],
       [ 6, 12]])
```

### 3.2矩阵场景
```
(np.mat(A))*(np.mat(B))  #执行矩阵运算
1
matrix([[ 4,  7],
        [ 8, 15]])
```