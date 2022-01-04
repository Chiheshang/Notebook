# Shell工具
## cut
cut的工作就是“剪”，具体的说就是在文件中负责剪切数据用的。cut 命令从文件的每一行剪切字节、字符和字段并将这些字节、字符和字段输出。
1. 基本用法
cut [选项参数]  filename
说明：默认分隔符是制表符
2. 选项参数说明

    | 选项参数 | 功能 |
    | -- | -- |
    | -f | 列号提取第几列 |
    | -d | 分隔符按照指定分隔符分割列 |
3. 案例实操
   1. 数据准备
    ```C
    [atguigu@hadoop101 datas]$ touch cut.txt
    [atguigu@hadoop101 datas]$ vim cut.txt
    dong shen
    guan zhen
    wo  wo
    lai  lai
    le  le
    ```
    2. 切割cut.txt第一列
    ```C
    [atguigu@hadoop101 datas]$ cut -d " " -f 1 cut.txt 
    dong
    guan
    wo
    lai
    le
    ```
    3. 切割cut.txt第二、三列
    ```C
    [atguigu@hadoop101 datas]$ cut -d " " -f 2,3 cut.txt 
    shen
    zhen
    wo
    lai
    le
    ```
    4. 在cut.txt文件中切割出guan
    ```C
    [atguigu@hadoop101 datas]$ cat cut.txt | grep "guan" | cut -d " " -f 1
    guan
    ```
    5. 选取系统PATH变量值，第2个“：”开始后的所有路径：
    ```C
    [atguigu@hadoop101 datas]$ echo $PATH
    /usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/atguigu/bin

    [atguigu@hadoop102 datas]$ echo $PATH | cut -d: -f 2-
    /usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/atguigu/bin
    ```
    6. 切割ifconfig 后打印的IP地址
    ```C
    [atguigu@hadoop101 datas]$ ifconfig eth0 | grep "inet addr" | cut -d: -f 2 | cut -d" " -f1
    192.168.1.102
    ```
