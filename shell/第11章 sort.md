# shell工具
## sort
sort命令是在Linux里非常有用，它将文件进行排序，并将排序结果标准输出。
1. 基本语法
    sort(选项)(参数)

    |选项|	说明|
    |--|--|
    |-n|	依照数值的大小排序|
    |-r|	以相反的顺序来排序|
    |-t|	设置排序时所用的分隔字符|
    |-k|	指定需要排序的列|
    参数：指定待排序的文件列表
2. 案例实操
+ 数据准备
```C
[atguigu@hadoop102 datas]$ touch sort.sh
[atguigu@hadoop102 datas]$ vim sort.sh 
bb:40:5.4
bd:20:4.2
xz:50:2.3
cls:10:3.5
ss:30:1.6
```
+ 按照“：”分割后的第三列倒序排序。
```C
[atguigu@hadoop102 datas]$ sort -t : -nrk 3  sort.sh 
bb:40:5.4
bd:20:4.2
cls:10:3.5
xz:50:2.3
ss:30:1.6
```