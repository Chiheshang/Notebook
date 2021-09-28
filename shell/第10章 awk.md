# shell工具
## awk
一个强大的文本分析工具，把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行分析处理。
1.	基本用法
awk [选项参数] ‘pattern1{action1}  pattern2{action2}...’ filename
pattern：表示AWK在数据中查找的内容，就是匹配模式
action：在找到匹配内容时所执行的一系列命令
2.	选项参数说明

|选项参数|	功能|
|--|--|
|-F|	指定输入文件折分隔符|
|-v|	赋值一个用户定义变量|
3.	案例实操
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
    6.	awk的内置变量
   
    |变量|	说明|
    |--|--|
    |FILENAME|	文件名|
    |NR|	已读的记录数（行号）|
    |NF|	浏览记录的域的个数（切割后，列的个数）| 
    7.	案例实操
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