---
layout: post
title: "Python 3"
description: "Python 学习笔记"
date: 2016-10-25
tags: [Language]
comments: true
share: false
---

[TOC]

[廖雪峰的 Python 教程](http://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/001374738150500472fd5785c194ebea336061163a8a974000)

# 前言
## 使用 Python

```
/// 进入使用环境
$ python 
/// 运行程序
$ python <file>.py
/// 退出环境
$ exit()

/* 在 .py 文件头加上声明并将文件改成可执行文件则可以在 Unix 环境下直接双击运行。*/

// 头声明
#!/usr/bin/env python

// 改成可执行文件
$ chmod a+x <file>.py
```

## 输入输出

```
print('...')                // ...
print('100+200=',100+200)   // 100+200= 300
name = input()              // 输入的时候默认都是字符串
name = input('input some:') // 先输出 input some: 再等待输入
```

## 注释

```
# 注释以 '#' 号开头
```

# 基础

## 数据类型和变量

* 整数
* 浮点数
* 字符串
* 布尔
* 空值
* 变量
* 常量

```python
// 整数
int = 1     // 10 进制
int = 0xff  // 16 进制

// 浮点数
float = 1.23
float = 1.23e9 // 1.23 * 10^9
float = 1.2e-5 // 0.00012

// 字符串
/*
以 单引号 或 双引号 括起来的任意文本。
... 可以用于表示换行
r'' 表示内部不转义
*/
str = 'string'
str = 'line1
...line2'
str = 'r'can \''

// 布尔值
True False
可以使用 and or not 进行运算

// 空值
None

// 变量可声明可不声明
a = 123
int a = 123

// 常量用大写
PI = 3.14
```

## 字符跟编码

* ord() 获取字符的整数表示
* chr() 把编码转换成字符
* b''   表示 bytes 类型
    * encode() 把字符串编码为指定的 bytes
    * decode() 把 bytes 按指定的方式转换
* len() 计算字符串包含多少个字符
* 格式化
* replace('old', 'new') // 把旧的字符替换成新的

```python
// 转换
    >>> ord('A')
    65
    >>> ord('中')
    20013
    >>> chr(66)
    'B'
    >>> chr(25991)
    '文'


// bytes
    x = b'ABC'
    >>> 'ABC'.encode('ascii')
    b'ABC'
    >>> '中文'.encode('utf-8')
    b'\xe4\xb8\xad\xe6\x96\x87'
    >>> '中文'.encode('ascii')
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
    UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-1: ordinal not in range(128)
    
    >>> b'ABC'.decode('ascii')
    'ABC'
    >>> b'\xe4\xb8\xad\xe6\x96\x87'.decode('utf-8')
    '中文'

// 格式化
    %d	整数
    %f	浮点数
    %s	字符串
    %x	十六进制整数
    
    // %s 可以把任意数据类型转换成字符串
    >>> 'Age: %s. Gender: %s' % (25, True)
    'Age: 25. Gender: True'
```

## list 跟 tuple

### 数组 list

list 中的元素可以是另一个 list.

```python
list = [123, 45.6, "789"]
len(list)           // 获取 list 长度
list[0]             // 获取第一个元素
list[-1]            // 获取最后一个元素
list.append('new')  // 添加元素
list.insert(1,'n')  // 插入元素
list.pop()          // 删除最后的元素
list.pop(1)         // 删除第2个元素
list.sort()         // 排序
```

### tuple 元祖

tuple 不可以变，但是如果包含数组，则数组可变

```python
tuple = (123, 'ddd', [list])
tuple[1]
```

### 条件判断

```
if a < b:
    print('...')
elif b < c:
    print('...')
else:
    print('...')
```

### 循环

```
for x in [1,2,3,4]:
    print('in for')
print('out for')

for x in range(101): // [0..<101]
    print('in for')
print('out for')

while n > 0:
    print('in while')
print('out while')

for i, v in enumerate(List): // 输出下标
    print(i, v)
```

### 字典 dict

```
dict = {'key': 94, 'key2': 393}
dict['key']     // 如果不存在 key 会崩溃

'key' in dict   // 判断 dict 有没有 key
dict.get('key') // 不存在则返回 None
dict.get('k',-1)// 不存在返回 -1
dict.pop('k')   // 删除 k 

dict.items()    // 用于循环 k,v
```

### 集合 set

```
s = set([1,2,3])
s.add(8)
s.remove(8)

s1 = set([1,2,3])
s2 = set([2,3,4])
s1 & s2 // {2,3}
s1 | s2 // {1,2,3,4}
```

# 函数

[Python 官方文档函数部分](http://docs.python.org/3/library/functions.html#abs)

## 常用函数

* abs(-1) 绝对值
* max(1,2...) 最大值
* 数据类型转换函数
    * int(x [,base ])         将x转换为一个整数    
    * long(x [,base ])        将x转换为一个长整数    
    * float(x )               将x转换到一个浮点数    
    * complex(real [,imag ])  创建一个复数    
    * str(x )                 将对象 x 转换为字符串    
    * repr(x )                将对象 x 转换为表达式字符串    
    * eval(str )              用来计算在字符串中的有效Python表达式,并返回一个对象    
    * tuple(s )               将序列 s 转换为一个元组    
    * list(s )                将序列 s 转换为一个列表    
    * chr(x )                 将一个整数转换为一个字符    
    * unichr(x )              将一个整数转换为Unicode字符    
    * ord(x )                 将一个字符转换为它的整数值    
    * hex(x )                 将一个整数转换为一个十六进制字符串    
    * oct(x )                 将一个整数转换为一个八进制字符串    
* isinstance(x, (int, float)) 检查数据类型


## 函数定义

* pass 关键字，表示跳过这部分，作为占位符用
* raise TypeError('bad operand type') 抛出错误
* 可以返回多个值，实际上是返回一个tuple
* 可以有默认参数，默认参数如果指向不可变对象就会每次都被修改
* 可变参数: 可变参数允许你传入0个或任意个参数，这些可变参数在函数调用时自动组装为一个tuple。
* 关键字参数: 而关键字参数允许你传入0个或任意个含参数名的参数，这些关键字参数在函数内部自动组装为一个dict。

```
def functionName(x):
    return x
    
// 默认参数
def functionName(x=2, y=3):
    return x
    
// 多个默认参数下的指定调用
functionName(y=4)

// 传入数组作为默认参数时
def add_end(L=None):
    if L is None:
        L = []
    L.append('END')
    return L
    
// 可变参数
def calc(*numbers):
    sum = 0
    for n in numbers:
        sum = sum + n * n
    return sum

// 关键字参数    
def person(name, age, **kw):
    print('name:', name, 'age:', age, 'other:', kw)

>>> person('Bob', 35, city='Beijing')
name: Bob age: 35 other: {'city': 'Beijing'}

// 关键字检查
def person(name, age, **kw):
    if 'city' in kw:
        # 有city参数
        pass
    if 'job' in kw:
        # 有job参数
        pass
    print('name:', name, 'age:', age, 'other:', kw)
```

## 递归函数


# 高级特性

## 切片

可以对 list 跟 tuple 有效

```
L = ['Michael', 'Sarah', 'Tracy', 'Bob', 'Jack']
L[0:3]          // ['Michael', 'Sarah', 'Tracy'] 取 0..<3 个元素
L[:3] == L[0:3]
L[-2:]          // 倒数第二个到结束，包括最后一个
L[-2:-1]        // 倒数第二个到最后一个，不包括最后一个


L = list(range(100))
L[:10]          // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
L[-10:]         // [90, 91, 92, 93, 94, 95, 96, 97, 98, 99]
L[10:20]        // [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
L[:10:2]        // [0, 2, 4, 6, 8] 前十个里每2个取一个
L[::5]          // [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95] 每5个取一个
```

## 迭代

导入 collections 模块中的 Iterable 类

```
from collections import Iterable

isinstance('abc', Iterable) // str是否可迭代
```

## 列表生成器

```python
>>> [x * x for x in range(1, 11)]
[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
从 1 ..< 11 每个数的平方

// 两层循环
>>> [m + n for m in 'ABC' for n in 'XYZ']
['AX', 'AY', 'AZ', 'BX', 'BY', 'BZ', 'CX', 'CY', 'CZ']
```

# 错误调试

error name 可以使用 BaseException，所有错误都是它派生的。

```
try:
    ...
except <error name>, e:
    ...
finally:
    ...
```

---

---


# 文件读取和保存

```
import os

import os
print(os.getcwd())
os.chdir('C:\Python33\HeadFirstPython\chapter3')
man=[]
other=[]
try:
    data=open("sketch.txt")
    for each_line in data:
        try:
            (role, line_spoken)=each_line.split(':', 1)
            line_spoken=line_spoken.strip()
            if role=='Man':
                man.append(line_spoken)
            elif role=='Other Man':
                other.append(line_spoken)
        except ValueError:
                pass
    data.close()
except IOError:
    print('The datafile is missing!')
try:
    man_file=open('man.txt', 'w')      #以w模式访问文件man.txt
    other_file=open('other.txt','w')   #以w模式访问文件other.txt
    print (man, file=man_file)           #将列表man的内容写到文件中
    print (other, file=other_file)
except IOError:
    print ('File error')
finally:
    man_file.close()
    other_file.close()
```

# 模拟浏览器 Selenium

## 环境配置

```
$ cd pipfile
$ python setup.py install
$ pip install -U selenium

下载 geckodriver 跟 Firefox 浏览
```

## 打开火狐浏览器

```
# 插入路径
from selenium import webdriver
```

```
# executable_path 为 geckodriver 路径
browser = webdriver.Firefox(executable_path='/Users/Myron/Downloads/geckodriver')
```

```
# 进入某个网页
browser.get("http://www.baidu.com")
```

```
# 查到 kw 元素并输入 selenium
browser.find_element_by_id("kw").send_keys("selenium")
```

```
# 查到 su 元素并点击
browser.find_element_by_id("su").click()
```

```
# 退出浏览器
browser.quit()
```

## 休眠

```
import  time
time.sleep(3)
```

## 流浪器控制

```
browser.maximize_window()           # 最大化
browser.set_window_size(480, 800)   # 参数数字为像素点

browser.back()      # 后退
browser.forward()   # 前进
```

## 对象定位方法

* id
* name
* class name
* link text
* partial link text
* tag name
* xpath
* css selector

```
// id and nam
<input id="kw" class="s_ipt" type="text" maxlength="100" name="wd" autocomplete="off"
```

```python
#coding=utf-8

from selenium import webdriver
import time

browser = webdriver.Firefox()

browser.get("http://www.baidu.com")
time.sleep(2)

#########百度输入框的定位方式##########

#通过id方式定位
browser.find_element_by_id("kw").send_keys("selenium")

#通过name方式定位
browser.find_element_by_name("wd").send_keys("selenium")

#通过tag name方式定位
browser.find_element_by_tag_name("input").send_keys("selenium")

#通过class name 方式定位
browser.find_element_by_class_name("s_ipt").send_keys("selenium")

#通过CSS方式定位
browser.find_element_by_css_selector("#kw").send_keys("selenium")

#通过xphan方式定位
browser.find_element_by_xpath("//input[@id='kw']").send_keys("selenium")

############################################

browser.find_element_by_id("su").click()
time.sleep(3)
browser.quit()
```

# Socket

```
import socket     #socket模块
import commands   #执行系统命令模块
import sys        

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # 创建 AF_INET STREAM 的 socket 文件

host = "127.0.0.1"
port = 1234

# 服务端
sock.bind((host, port))
sock.listen(1)

client, address = sock.accept() # 接受TCP连接，并返回新的套接字与IP地址

# 客户端

sock.connect((host, port))


# 接收发送
sock.sendall("")
sock.send("")
sock.recv("")

# 关闭套接字
sock.close()

```

[参考博客](http://blog.csdn.net/rebelqsp/article/details/22109925)

```

socket函数
描述
服务端socket函数
s.bind(address) 将套接字绑定到地址, 在AF_INET下,以元组（host,port）的形式表示地址.
s.listen(backlog) 开始监听TCP传入连接。backlog指定在拒绝连接之前，操作系统可以挂起的最大连接数量。该值至少为1，大部分应用程序设为5就可以了。
s.accept()
接受TCP连接并返回（conn,address）,其中conn是新的套接字对象，可以用来接收和发送数据。address是连接客户端的地址。
客户端socket函数
s.connect(address)
连接到address处的套接字。一般address的格式为元组（hostname,port），如果连接出错，返回socket.error错误。
s.connect_ex(adddress)
功能与connect(address)相同，但是成功返回0，失败返回errno的值。
公共socket函数
s.recv(bufsize[,flag])
接受TCP套接字的数据。数据以字符串形式返回，bufsize指定要接收的最大数据量。flag提供有关消息的其他信息，通常可以忽略。
s.send(string[,flag])
发送TCP数据。将string中的数据发送到连接的套接字。返回值是要发送的字节数量，该数量可能小于string的字节大小。
s.sendall(string[,flag])
完整发送TCP数据。将string中的数据发送到连接的套接字，但在返回之前会尝试发送所有数据。成功返回None，失败则抛出异常。
s.recvfrom(bufsize[.flag])
接受UDP套接字的数据。与recv()类似，但返回值是（data,address）。其中data是包含接收数据的字符串，address是发送数据的套接字地址。
s.sendto(string[,flag],address)
发送UDP数据。将数据发送到套接字，address是形式为（ipaddr，port）的元组，指定远程地址。返回值是发送的字节数。
s.close()
关闭套接字。
s.getpeername()
返回连接套接字的远程地址。返回值通常是元组（ipaddr,port）。
s.getsockname()
返回套接字自己的地址。通常是一个元组(ipaddr,port)
s.setsockopt(level,optname,value)
设置给定套接字选项的值。
s.getsockopt(level,optname[.buflen])
返回套接字选项的值。
s.settimeout(timeout)
设置套接字操作的超时期，timeout是一个浮点数，单位是秒。值为None表示没有超时期。一般，超时期应该在刚创建套接字时设置，因为它们可能用于连接的操作（如connect()）
s.gettimeout()
返回当前超时期的值，单位是秒，如果没有设置超时期，则返回None。
s.fileno()
返回套接字的文件描述符。
s.setblocking(flag)
如果flag为0，则将套接字设为非阻塞模式，否则将套接字设为阻塞模式（默认值）。非阻塞模式下，如果调用recv()没有发现任何数据，或send()调用无法立即发送数据，那么将引起socket.error异常。
s.makefile()
创建一个与该套接字相关连的文件
```

