 

# shell工具

## awk

一个强大的文本分析工具，把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行分析处理。

### 基本用法
`awk` [选项参数] `pattern1{action1}  pattern2{action2}...` filename
`pattern`：表示AWK在数据中查找的内容，就是匹配模式
`action`：在找到匹配内容时所执行的一系列命令

###	选项参数说明

|选项参数|	功能|
|--|--|
|-F|	指定输入文件折分隔符|
|-v|	赋值一个用户定义变量|
|### 案例实操||
  1. 数据准备

    ```C
    [atguigu@hadoop102 datas]$ sudo cp /etc/passwd ./
    ```
   2. 搜索passwd文件以root关键字开头的所有行，并输出该行的第7列。

    ```C
    [atguigu@hadoop102 datas]$ awk -F: '/^root/{print $7}' passwd 
    /bin/bash
    ```
   3. 搜索passwd文件以root关键字开头的所有行，并输出该行的第1列和第7列，中间以“，”号分割。

    ```C
    [atguigu@hadoop102 datas]$ awk -F: '/^root/{print $1","$7}' passwd 
    root,/bin/bash
    ```
    **只有匹配了pattern的行才会执行action**
   4. 只显示/etc/passwd的第一列和第七列，以逗号分割，且在所有行前面添加列名user，shell在最后一行添加"dahaige，/bin/zuishuai"。

    ```C
    [atguigu@hadoop102 datas]$ awk -F : 'BEGIN{print "user, shell"} {print $1","$7} END{print "dahaige,/bin/zuishuai"}' passwd
    user, shell
    root,/bin/bash
    bin,/sbin/nologin
    。。。
    atguigu,/bin/bash
    dahaige,/bin/zuishuai
    ```
    **BEGIN 在所有数据读取行之前执行；END 在所有数据执行之后执行。**
   5. 将passwd文件中的用户id增加数值1并输出


```C
[atguigu@hadoop102 datas]$ awk -v i=1 -F: '{print $3+i}' passwd
1
2
3
4
```

6.   awk的内置变量
            
        ARGC               命令行参数个数
        ARGV               命令行参数排列
        ENVIRON       	支持队列中系统环境变量的使用
        FILENAME    	awk浏览的文件名
        FNR                	浏览文件的记录数
        FS                 	设置输入域分隔符，等价于命令行 -F选项
        NF                 	浏览记录的域的个数
        NR                 	已读的记录数
        OFS                	输出域分隔符
        ORS              	输出记录分隔符
        RS                 	控制记录分隔符

     ​	$n   				按照指定分隔符（默认为空格/tab）分割后的第几域，从1开始。$0为所有域
     
7.   自定义变量

自变量最好初始化，可以为string，int。
		数组：数组实质上是key-velue对，实质是map，key为数组下标，可以为string也可以为int。数组长度：`length（array）`，遍历array：for(k in array){print k,array[k]}

8.块

awk中通过{}来定义块,块中用；来分割语句，`BEGIN{}{}END{}`中的BEGIN后为所有行处理前执行的，相当与初始化，第二个{}为每一行都要执行的。END后的{}内为所有行执行完后执行的。

eg:

```c
grep "cmd_stat:" stat_log.1 |awk -F ":" '{if($7 in cmd) cmd[$7]=cmd[$7]+$8;else cmd[$7]=$8}END{for(k in cmd){print k,cmd[k]}}
```

9.   案例实操

   + 统计passwd文件名，每行的行号，每行的列数

    ```C
    [atguigu@hadoop102 datas]$ awk -F: '{print "filename:"  FILENAME ", linenumber:" NR  ",columns:" NF}' passwd 
    filename:passwd, linenumber:1,columns:7
    filename:passwd, linenumber:2,columns:7
    filename:passwd, linenumber:3,columns:7
	
	 ```
	+ 切割IP
	```C
	[atguigu@hadoop102 datas]$ ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk -F " " '{print $1}' 
	192.168.1.102
	```
	+ 查询sed.txt中空行所在的行号
	```C
	[atguigu@hadoop102 datas]$ awk '/^$/{print NR}' sed.txt 
	5
	123=qwe+12ewqd+daf
	```

### 其他语法

