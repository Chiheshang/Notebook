+在这个服务中，我负责了几个接口的编写（疯狂写bug）和压测

接口编写：

   +   打印日志格式：
       
       ​	TINT64：%ld
       
       ​	字符串：c_str()%
    
   +   日志应易于查找（打出当前位置）并打印当前关键信息

   +   注意Json层数
      在for循环中要改变状态量时，应在第一行更改，防止循环太长在底部忘记更改

压测：

压测流程：

​	两台服务器，一台运行被测试的服务（1/3/6线程），一台疯狂发请求（混测，单侧），在被测试的服务器里查找进程的状态，资源占有率，qps数。

要求：1. 不能崩

​			2. 对与qps特别低的要查看瓶颈，优化

   + 由于服务器时间为美国时间，所以上传后时间戳可能会错误，用：

     `find ./|xargs touch`

   + 压测时出现问题应该通过按通过session，时间等多方式来查找错误

   + 查看pid：`ps -ef |grep "..."`

   + 查看cpu使用状态：`htop -p pid`

json压榨性能：
 +    不用getmember（），而是用直接用迭代器

      ```c++
      Json::Value::Members members = jLockInfo.getMemberNames();
      for (Json::Value::Members::iterator it = members.begin(); it != members.end(); it++)
          
      for(auto it= jLockInfo.begin();it!=jLockInfo.end();it++)
      ```

 +    不用json.append（），而是先resize（）然后用下标赋值

 +    json1=json2，可以换为swp（）

      





