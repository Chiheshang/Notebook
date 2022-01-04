# Shell工具
## sed
sed是一种流编辑器，它一次处理一行内容。处理时，把当前处理的行存储在临时缓冲区中，称为“模式空间”，接着用sed命令处理缓冲区中的内容，处理完成后，把缓冲区的内容送往屏幕。接着处理下一行，这样不断重复，直到文件末尾。文件内容并没有改变，除非你使用重定向存储输出。
1.	基本用法
sed [选项参数]  ‘command’  filename
2.	选项参数说明

    |选项参数|	功能|
    |--|--|
    |-e|	直接在指令列模式上进行sed的动作编辑|
3.	命令功能描述

    |命令|	功能描述|
    |--|--|
    |a |	新增，a的后面可以接字串，在下一行出现|
    |d	|删除|
    |s	|查找并替换 |
4.	案例实操
    1. 数据准备
    ```C
    [atguigu@hadoop102 datas]$ touch sed.txt
    [atguigu@hadoop102 datas]$ vim sed.txt
    dong shen
    guan zhen
    wo  wo
    lai  lai

    le  le
    ```
    2. 将“mei nv”这个单词插入到sed.txt第二行下，打印。
    ```C
    [atguigu@hadoop102 datas]$ sed '2a mei nv' sed.txt 
    dong shen
    guan zhen
    mei nv
    wo  wo
    lai  lai

    le  le
    ```
    **注意：文件并没有改变**
    3. 删除sed.txt文件所有包含wo的行
    ```C
    [atguigu@hadoop102 datas]$ sed '/wo/d' sed.txt
    dong shen
    guan zhen
    lai  lai

    le  le
    ```
    4. 将sed.txt文件中wo替换为ni
    ```C
    [atguigu@hadoop102 datas]$ sed 's/wo/ni/g' sed.txt 
    dong shen
    guan zhen
    ni  ni
    lai  lai

    le  le
    ```
    **注意：‘g’表示global，全部替换**
    5. 将sed.txt文件中的第二行删除并将wo替换为ni
    ```C
    [atguigu@hadoop102 datas]$ sed -e '2d' -e 's/wo/ni/g' sed.txt #/g是全局改变
    dong shen
    ni  ni
    lai  lai

    le  le
    ```
