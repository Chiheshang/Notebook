# 失落之地rank说明文档

## 需求描述
---
- 进入失落之地的玩家和联盟的各种积分，都需要进行排名再展示给玩家。
- 分门别类的积分都需要排名，排进入排行榜前1000的玩家。
- 排行榜更新间隔大于1分钟。
- 排行榜有两个类别：个人排行和联盟排行
- 拉取排名数据分为两种：
1. 拉首页的数据，各种排行榜榜一的数据。
![图片](images_rank/首页排行.png "首页排行")
2. 拉具体排名的数据，一种排行前1000人的数据。
![图片](images_rank/具体排行.png "具体排行")
- 重启服务，排行数据不丢失。
- 维护排名时会用到的用户的额外数据。
## 解决方案
---
### 最小堆
- ![图片](images_rank/小顶堆.png "小顶堆")

- 之所以选择使用最小堆，主要基于两点：
1. 不需要实时更新排名。
2. 维护最小堆的速度比维护红黑树快。
3. 不需要真正实现链表。
![图片](images_rank/最小堆数组.png "最小堆数组")
- 最小堆是一个子节点比父节点大的完全二叉树。根结点一定是最小的节点。
- 二叉树的更新有两种：
1. 作为一个新节点，插入到二叉树的末尾，然后调整在二叉树中的位置。
2. 老节点数值更新，更新节点后，调整在二叉树中的位置。
- 位置的调整主要有两种
1. 上浮： 当需要调整的节点的数值比父节点小时，直接交换两个节点的位置。
![图片](images_rank/上浮.gif "上浮") 
2. 下沉： 当需要调整的节点的数值比子节点大时，和子结点中数值最小的那个节点交换位置。
![图片](images_rank/下沉.gif "下称")
- 当二叉树的节点数达到人为规定的上限时，插入的节点有两种情况：
1. 和根结点（最小值）作比较，如果数值小于最小值，不能进入排行，不操作。
2. 和根结点（最小值）作比较，如果数值大于最小值，进入排行，替换掉根结点，然后调整位置。
### 堆排序
- 间隔一分钟进行排序的时候，使用的是堆排序。因为要进行排序的内容已经是最小堆了，可以利用最小堆根结点为最小值的特性，快速进行排序。
- 排序的过程为：
1. 设置一个指针指向最小堆最末尾的位置。
2. 根结点与指针指向的节点交换。
3. 根结点调整位置，指针之后的节点不参与调整，二叉树重新成为最小堆。
4. 指针指向当前节点的前一个节点
5. 执行第2条，直到指针指向根结点。

- ![图片](images_rank/排序.gif "排序")
### 文件流读写
- 按sid、类型（个人/联盟）、排名类型创建文件目录存放数据。
- 每次提取排名数据的时候，将当前的最小堆的数据写在文件里，随后覆盖之前的数据。
- 每次服务重启的时候，读取各个文件夹中文件数据，恢复rank。
### lru
- 维护用户数据时，采取lru算法来维持一定数量的用户数据。
- 该算法主要是维护一个链式哈希表。
- 算法的过程为：
1. 有一个新的节点插入时，将它放在链表的头部。
2. 有一个节点被使用时，将它从原有的位置提出，放在头部。
3. 当节点数量已达上限，又需要插入新的节点时，将链表尾部的节点删除。
![图片](images_rank/lru.png "lru")
## 数据结构
---
### 排行榜的数据结构图
```mermaid
graph LR

RankMgr-->RankData_1

RankMgr-->RankData_2



RankMgr-->....

RankData_1-->RankHeap_1

RankData_1-->.....

RankHeap_1-->vector(最小堆)

vector-->SRankItem_1

vector-->SRankItem_2

vector-->......
```


### 用户数据的数据结构图
```mermaid
graph LR
CUserDataMgr-->SUserDataItem_1

CUserDataMgr-->SUserDataItem_2

CUserDataMgr-->SUserDataItem_3

CUserDataMgr-->.....

```
## 代码实现
---
### SRankItem
#### SRankItem结构图
```mermaid
classDiagram
class SRankItem{
    m_id
    m_rank_type
    m_value
    m_updt_time
    operator < ()
    operator == ()
    operator = ()
}
```
- **SRankItem**
SRankItem是一个结构体，一个SRankItem包含着一个玩家或者一个联盟在排行榜上的信息，最小堆以SRankItem作为节点。
- **TINT64 m_id**
玩家的uid或者联盟的aid
- **TINT64 m_rank_type**
表示排行榜的类型，比如是战力排行还是摧毁战力排行
- **TINT64 m_value**
表示一个玩家或者联盟的的分数
- **TINT64 m_updt_time**
表示这个结构体的信息进入排行榜的时间
- **operator < ()**
因为维护最小堆时，需要比较结点的大小，所以要重载小于运算符。比较规则为：两个结构体中m_value小的结构体小，结构体的m_value相同时，m_updt_time大的结构体小，前面两个都相同的时候，m_id小的结构体小。
- **operator == ()**
如果两个结构体的m_value，m_updt_time，m_id均相同，则两个结构体相同。
- **operator = ()**
因为最小堆中，交换两个节点时，执行的是互相赋值的操作，因此需要重载等于运算符，用右值的结构的数值覆盖左值结构体的数值。


### CRankItemPool
#### CRankItemPool类图
```mermaid
classDiagram
class CRankItemPool{
-m_pool_size
-m_rank_item_pool
-m_all_rank_node
-m_lock
+GetItem()
+ReleaseItem()
}
```
- **CRankItemPool**
将玩家或者联盟的信息封装成SRankItem结构体，然后该结构体作为最小堆节点时，需要开辟内存，来存放结构体的数据。正常情况下是要在玩家信息或者联盟信息进入和离开最小堆时不断的开辟内存和释放内存的，但这样会造成很多的时间开销以及可能出现内存泄露。为此，我们建立一个节点池，在初始化的时候就开辟好用来存放节点的内存，然后内存不断的复用。
- **TINT64 m_pool_size**
表示节点池的大小，由配置文件中的数值决定，现在的节点池的大小为2001，这是因为最小堆的大小为2000，至少需要2000个节点，之所以要多一个节点，是为了在最小堆上已经有2000个节点时，还能拿出一个节点来存放玩家或者联盟的信息，之后该节点如果不进入最小堆，就返回节点池，如果进入最小堆，就会置换出一个节点，返回节点池，保证最小堆有2000个节点时，始终还有节点可以用来存放新的玩家或者联盟的信息。
- **list<SRankItem\*> m_rank_item_pool**
该列表用来存放所有实现开辟内存的节点，需要用到节点时，从队列的头提取一个元素，节点不在最小堆时，放回队列的尾部。
- **SRankItem\* m_all_rank_node**
使用这个指针，只是为了开辟多个节点的内存。开辟完内存后，一个一个的将开辟的节点加入到队列中。
- **Mutexlock m_lock**
之所以要加锁，是为了防止多个线程同时从队列里提出节点，或者多个线程同时将同一个节点放回队列时造成的冲突。

### CRankHeap
#### CRankHeap类图
```mermaid
classDiagram
class CRankHeap{
    -m_rank_item_pool
    -m_rank_vector
    -m_rank_index
    -m_top_one
    -m_heap_size
    -m_top_rank_size
    -m_lock
	-m_rank_sid
	-m_type
	-m_rank_type

    +UpdateRankItem()
    +GetTopRank()
    +GetTopOne()
    +Recover()
    -UpdateHeap(rank_vector)
    -UpdateHeap(top_rank)
    -UpdateTopRank()
}
```
- **CRankHeap**
每有一个排行榜就会有一个对应的CRankHeap，它的作用就是为排行榜维护一个最小堆，需要排行榜数据的时候就以最小堆为依据，进行堆排序。
- **CRankItemPool\* m_rank_item_pool**
每个RankHeap都有一个节点池，为最小堆提供节点。
- **vector<SRankItem\*> m_rank_vector**
通过一个节点数组去维护最小堆，之所以选择数组，是因为最小堆本就是一个平衡二叉树，可以通过简单的x2，/2找到一个节点的父节点和子节点，并且可以很容易找到最后一个节点，这方便进行堆排序。
- **unordered_map<TINT64, TINT64> m_rank_index**
如果每次都是加入一个新的节点，然后进行调整，不需要记录某个玩家或联盟在最小堆中的位置，但是涉及同一个玩家或者联盟的信息被更新，就需要找到原本在最小堆中的节点，然后更新节点信息了。为此，我们需要记录一个排行榜中，每个id对应的节点所在最小堆的位置，每次最小堆为了平衡进行调整的时候，节点位置发生改变，也需要更新节点所在位置。
- **SRankItem m_top_one**
用来记录排行榜的第一名的信息，因为拉排行榜首页的时候需要排行榜第一名的信息，为了获取第一名信息的方便，专门记录一下第一名的信息。
- **TINT64 m_heap_size**
表示最小堆的大小，即有多少个节点，这由配置文件决定，现在的大小为2000。我们实际需要的是前1000名的数据，但如果我们只维护1000个节点，那么当排名前1000的多个玩家由于积分下降而掉出排行榜时，我们将没有原本排名1000以外的玩家立刻进入前1000名。因为积分存在下降的情况，因此我们也需要记录1000以外的替补的信息。
- **TINT64 m_top_rank_size**
用来表示实际需要得到排行的数量，由配置文件决定，现在为1000，客户端展示排行榜时，只需要前1000名的数据。
- **Mutexlock m_lock**
保证在多线程的情况下，每次只加入一个节点到一个最小堆里。
- **TINT32 m_rank_sid**
记录该RankHeap属于哪一个战场。备份排行榜数据的时候需要用到。
- **TINT32 m_type**
记录该RankHeap属于哪一个类型，是用来记录玩家排名，还算是记录联盟的排名的。备份排行榜数据的时候需要用到。
- **TINT32 m_rank_type**
记录该RankHeap是属于具体哪一种排行榜的。备份排行榜数据的时候需要用到。
- **UpdateRankItem()**
该接口的作用是更新最小堆，更新最小堆分3种情况处理，第一种情况该玩家或者联盟已有节点在最小堆上了，需要找到节点，然后更新节点，之后调用UpdateHeap(rank_vector)，使最小堆重新达到平衡。第二种情况是玩家或者联盟没有节点在最小堆上，并且最小堆的节点数量没有达到最大值，此时从节点池取出一个节点，附上玩家或者联盟的信息，然后把节点插入到最后，再调用UpdateHeap(rank_vector)，使最小堆重新达到平衡。第三种情况是，玩家或者联盟之前没有节点，并且最小堆的节点数量到达最大值，此时需要从节点池取出一个节点，附上玩家或者联盟的的信息，和最小堆的第一个节点，也就是当前堆的最小值进行比较，如果小于最小值，那么节点不进入最小堆，如果大于最小值，那么节点和第一个节点进行交换，再调用UpdateHeap(rank_vector)，使最小堆重新达到平衡，之后再将不上榜的节点放回节点池。

```flow
st=>start: 同步数据

is_have_node=>condition: 已有节点？
have_node=>operation: 更新节点，调整平衡。
no_node=>condition: 最小堆已满？
is_max=>condition: 大于最小值？
no_max=>operation: 插入节点到最小堆末尾，调整平衡。
more=>operation: 和第一个节点交换，调整平衡。
less=>operation: 什么也不做

st->is_have_node(yes)->have_node
is_have_node(no)->no_node
no_node(yes)->is_max
no_node(no)->no_max
is_max(yes)->more
is_max(no)->less
```

- **GetTopRank()**
调用UpdateTopRank()。
- **GetTopOne()**
返回当前排行榜的第一名的信息。
- **Recover()**
恢复数据用的。其实就是读取备份的数据，从节点池取出节点，附上备份的信息，一个一个插回最小堆数组。
- **UpdateHeap(rank_vector)**
该函数，要将最小堆数组和当前需要调整的节点的位置，以及最小堆的当前的节点数量作为参数传入。只需要考虑需要调整的节点的下沉和上浮即可。需要调整的节点不再上浮和下沉的时候，最小堆重新到达平衡。
- **UpdateHeap(top_rank)**
和上一个函数的作用相同，不过上一个函数传入的是最小堆数组，这里传入的是指针数组。
- **UpdateTopRank()**
因为top_rank只需要前1000名的数据，所以只要用top_rank建立一个节点数量为1000的最小堆即可，因此将最小堆数组的节点一个个取出来，然后往top_rank里插入即可。这时候的插入只有两种情况，因为不会有相同玩家或者联盟的信息更新的情况了。插好了之后，先需要利用最小堆数组备份数据，然后对top_rank进行堆排序，得到有序的前1000名，然后将第一名的信息保存在m_top_one中。

```flow
st=>start: 同步数据

no_node=>condition: 最小堆已满？
is_max=>condition: 大于最小值？
no_max=>operation: 插入节点到最小堆末尾，调整平衡。
more=>operation: 和第一个节点交换，调整平衡。
less=>operation: 什么也不做

st->no_node
no_node(yes)->is_max
no_node(no)->no_max
is_max(yes)->more
is_max(no)->less
```

### CTopRank
#### CTopRank类图
```mermaid
classDiagram
class CTopRank{
-m_updt_time
-m_top_rank_size
-m_top_rank_list[3]
-m_update_idx
-m_get_idx
-m_lock
+UpdateList()
+GetList()
+Swap()
+GetRankSize()
}
```
- **CTopRank**
客户端需要排行榜数据的时候，需要对最小堆进行排序，然后返回有序的排行榜数据，最开始的做法是复制最小堆，然后对复制的最小堆进行排序，然后再拷贝复制的最小堆到拼返包的地方，这样做的话拷贝操作过多，影响性能，所以选择创建节点的指针数组，将最小堆的节点信息拷贝到指针数组，然后对指针数组进行排序，然后拷贝指针到返包的地方就可以了。每个最小堆都有一个对应的CTopRank。
- **TINT64 m_updt_time**
表示CTopRank上一次更新的时间
- **TINT64 m_top_rank_size**
表示指针数组的大小，这个大小就是客户端实际展示的排行榜大小，为1000，排行榜只展示前1000
- **SRankItem\* m_top_rank_list[3]**
正常来说，只需要一个指针数组即可，但是这里设置了3个，主要是为了防止一个线程在读指针数组的数据，但是读的很慢，另一个线程在更新排行榜的数据了，这个时候就会导致读到的指针数组的数据不正确。因此读和写的指针数组分开，比如读的是第一个指针数组，写的是第二个指针数组，写操作执行完后，之后的读操作取读第二个指针数组，之后写操作去写第三个指针数组。
- **TINT32 m_update_idx**
用于记录写操作应该写第几个指针数组的索引。
- **TINT32 m_get_idx**
用于记录读操作应该用第几个指针数组的索引。
- **Mutexlock m_lock**
防止多个线程同时写或者读一个指针数组，因此价格线程锁。
- **SRankItem\* UpdateList()**
返回要写的那一个指针数组
- **SRankItem\* GetList()**
返回要读的那一个指针数组
- **TVOID Swap()**
每写操作之后，都要调用一下这个函数，来改变读写的索引的指向
- **TINT32 GetRankSize()**
返回排行数据的个数

### CRankData
#### CRankData类图
```mermaid
classDiagram
class CRankData{
-m_top_rank
-m_rank_heap
-m_lock
-m_rank_sid
-m_type
-m_rank_type
-m_heap_size
-m_rank_beg
-m_rank_end
-m_rank_champion
+GetRankHeap()
+GetTopRank()
+GetChampionRank()
+GetTopRankSize()
-UpdateTopRank()
-UpdateChampion()
}
```
- **CRankData**
一个rank_data管理一个战场的个人或者联盟的所有类型的排行。
- **map<TINT32, CTopRank\*> m_top_rank**
key值为具体排行榜的类型，通过具体的排行类型可以得到具体排行榜对应的top_rank。
- **map<TINT64, CRankHeap\*> m_rank_heap**
key值为具体排行榜的类型，通过具体的排行类型可以得到具体排行榜对应的rank_heap。
- **Mutexlock m_lock**
防止冲突
- **m_rank_sid**
记录该rank_data属于那一个战场。
- **m_type**
记录该rank_data属于那一个类型(个人/联盟)
- **m_heap_size**
表示最小堆的大小。
- **m_rank_beg**
记录排行榜类型的起始位置
- **m_rank_end**
记录排行榜类型的结束位置
- **m_rank_champion**
记录排行榜类型中的首页为哪个类型。
- **GetRankHeap()**
通过rank_type排行榜类型在m_rank_heap中找到对应的rank_heap。
- **GetTopRank()**
通过rank_type排行榜类型在m_top_rank中找到对应的top_rank。然后根据时间看top_rank是否需要更新，如果需要调UpdateTopRank()，并调用top_rank的GetList()，获取排行榜数据的指针数组。
- **GetChampionRank()**
rank_type设置为首页类型，调GetTopRank()。
- **GetTopRankSize()**
返回top_rank的大小，现在为1000。
- **UpdateTopRank()**
如果rank_type为首页，则调UpdateChampion()，不是则更新rank_type对应的top_rank的指针数组。
- **UpdateChampion()**
遍历个人或者联盟所有的排行榜类型，更新他们对应的top_rank的指针数组，然后取指针数组的第一位，也就是第一名。

### CRankMgr
#### CRankMgr类图
```mermaid
classDiagram
class CRankMgr{
-m_player_rank_data
-m_alliance_rank_data
-m_lock
-m_path
-m_heap_size
+Init()
+GetRankData()
+Destory()
-GetRankData()
-Clear()
-Creat()
}
```
- **CRankMgr**
用来管理所有战场所有排行榜的管理器
- **unordered_map<TINT64, CRankData\*> m_player_rank_data**
key为rank_sid(战场),type为个人的时候，用这个结构。
- **unordered_map<TINT64, CRankData\*> m_alliance_rank_data**
key为rank_sid(战场),type为联盟的时候，用这个结构。
- **Mutexlock m_lock**
防止冲突。
- **TINT32 m_heap_size**
表示最小堆的大小。
- **Init()**
设置最小堆的大小。
- **GetRankData()**
通过传入的type决定使用那个结构，然后将结构作为参数，调用下面的GetRankData()。
- **Destory()**
根据传入的rank_sid来删除对应的rank_data，用于战场关闭后，清理数据，不仅是内存的数据，还有在磁盘的备份数据。
- **GetRankData()**
如果结构里有rank_sid对应的rank_data,就返回，没有就开辟一个。
- **Clear()**
删除rank_data指针。
- **Creat()**
开辟传入rank_sid对应的rank_data。

### CUserDataMgr
#### CUserDataMgr类图
```mermaid
classDiagram
class CUserDataMgr{
-user_data
-m_lock
+Init()
+GetUserData()
+UpdateUserData()
}
```
- **CUserDataMgr**
用来存放所有的用户数据
-  **MemoryCache<string, SUserDataItem> \*user_data**
排行榜用来展示的用户或者联盟的数据会存放在这里，该结构为一个链式哈希表。key由id和type组成。
- **Mutexlock m_lock**
防止冲突
- **Init()**
按照配置文件的数值设置user_data的大小，现在为100000。
- **GetUserData()**
通过type和id来获取链式哈希表的对应节点。
- **UpdateUserData()**
将玩家或者联盟的信息插入到练习哈希表中。

### SBackupElement 
#### SBackupElement结构图
```mermaid
classDiagram
class SBackupElement{
m_rank_sid
m_type
m_rank_type
m_rank_vector
}
```
- **SBackupElement**
一个备份和删除数据时的工作单元，执行工作的依据。
- **TINT32 m_rank_sid**
表示那个战场
- **TINT32 m_type**
表示那个类型
- **TINT32 m_rank_type**
表示排行榜类型
- **vector<SRankItem\*> m_rank_vector**
最小堆，最要是备份的时候要把整个最小堆的数据都备份，需要将最小堆的数据暂存在这里，方便往磁盘里写。
### SBackupTask
#### SBackupTask结构图
```mermaid
classDiagram
class SBackupTask{
m_task
m_backup_element
}
```
- **SBackupTask**
表示一个备份或者删除的任务。
- **TINT32 m_task**
表明执行的是什么任务，备份或则和删除。
- **TINT32 m_backup_element**
工作单元
### CBackupMgr
#### CBackupMgr类图
```mermaid
classDiagram
class CBackupMgr{
-m_queue_size
-m_backup_task
-m_empty_queue
-m_backup_queue
+Init()
+EmptyQueuePush()
+EmptyQueuePop()
+BackupQueuePush()
+BackupQueuePop()
}
```
- **CBackupMgr**
用来管理备份数据和删除备份数据的管理器。
- **TINT32 m_queue_size**
表示工作队列和空闲队列的大小
- **CBackupQueue m_empty_queue**
空闲队列，元素为SBackupTask
- **CBackupQueue m_backup_queue**
工作队列，元素为SBackupTask
- **Init()**
按数值配置填满空闲队列。
- **EmptyQueuePush()**
向空闲队列插入SBackupTask
- **EmptyQueuePop()**
向空闲队列取SBackupTask
- **BackupQueuePush()**
向工作队列插入SBackupTask
- **BackupQueuePop()**
向工作队列取SBackupTask
## 对外接口
---
```C++
/*
用于更新排行榜时的接口
*/
{"user_info_sync", CProcessSyncUserInfo::GetInstance(), NULL},

/*
用于拉取排行榜首页时的接口，返回pb
*/
{"rank_get", NULL, COutputRankGet::GetInstance()},

/*
用于拉取具体某个排行时的接口，返回pb
*/
{"rank_detail_get", NULL, COutputRankDetailGet::GetInstance()},

/*
用于拉取具体某个排行时的接口，返回json
*/
{"rank_detail_get_for_svr", NULL, COutputRankDetailGetForSvr::GetInstance()},

/*
活动结束后，用来清理排行榜数据的接口
*/
{"set_state_rank", CProcessSetStateRank::GetInstance(), NULL},

/*
用于拉取具体某个排行一定数量的数据时的接口，返回pb
*/
{"rank_detail_get_by_num", NULL, COutputRankDetailGetByNum::GetInstance()},
```

## 命令字流程
---
- 同步数据到排行榜

```sequence
title:同步数据

participant Client as C
participant Serve as S
participant RankMgr as RM
participant RankData as RD
participant RankHeap as RH
participant m_rank_vector as MRV


C->S:user_info_sync\n客户端发起请求
S->RM:GetInstance\n调用排行榜管理器
RM->RD:GetRankData\n根据战场和排行榜\n类型找到具体的排行\n榜数据对象
RD->RH:GetRankHeap\n根据具体的排行榜\n排行类型，找到对应\n的最小堆
RH->MRV:UpdateRankItem\n更新装最小堆节点的\n数据结构
```
说明：
1. 客户端给服务器发送一个同步信息的请求，请求包含用户数据
2. 服务器调用排行榜管理器对象，排行榜管理器对象(RankMgr)通过用户数据中的战场id(sid)和排行榜类型(type)找到对应的排行榜数据对象。
3. 排行榜数据对象(RankData),通过用户数据的排行榜类型(rank_type)来找到对应的排行榜对象(RankHeap)
4. 将数据封装到节点，更新到最小堆(m_rank_vector)
- 拉首页排行榜数据
```sequence
title:拉取首页排行榜数据

participant Client as C
participant Serve as S
participant RankMgr as RM
participant RankData as RD
participant RankHeap as RH
participant m_rank_vector as MRV
participant COutputRankGet as OP

C->S:rank_get\n客户端发起请求
S->RM:GetInstance\n调用排行榜管理器
RM->RD:GetRankData\n根据战场和排行榜\n类型找到具体的排行\n榜数据对象
RD->RD:GetChampionRank
RD->RD:UpdateTopRank
RD->RD:UpdateChampion
RD->RH:通过排行榜排行类型\n找到对应的最小堆
RH->RH:GetTopRank
RH->RH:UpdateTopRank
RH->MRV:UpdateHeap\n更新最小堆
MRV->MRV:GetTopOne\n获取当前排名的第一名
MRV->OP:封装每个排行榜第一名的数据
OP->C:返回每个排行榜的第一名的数据
```
说明：
1. 客户端给服务器发送一个拉取排行榜首页数据的请求，包含sid、type
2. 服务器调用排行榜管理器对象，排行榜管理器对象(RankMgr)通过用户数据中的战场id(sid)和排行榜类型(type)找到对应的排行榜数据对象(RankData)。
3. 遍历该RankData的所有RankHeap,对他们的最小堆进行排序。
4. 取每个排行榜的第一名的数据，返回给客户端。

- 拉具体排行榜数据
```sequence
title:拉具体排行榜数据

participant Client as C
participant Serve as S
participant RankMgr as RM
participant RankData as RD
participant RankHeap as RH
participant m_rank_vector as MRV
participant COutputRankGet as OP

C->S:rank_detail_get\n客户端发起请求
S->RM:GetInstance\n调用排行榜管理器
RM->RD:GetRankData\n根据战场和排行榜\n类型找到具体的排行\n榜数据对象
RD->RD:UpdateTopRank
RD->RH:通过排行榜排行类型\n找到对应的最小堆
RH->RH:GetTopRank
RH->RH:UpdateTopRank
RH->MRV:UpdateHeap\n更新最小堆
MRV->OP:封装排行榜的数据
OP->C:返回排行榜的数据

```
说明：
1. 客户端给服务器发送一个拉取排行榜首页数据的请求，包含sid、type、rank_type
2. 服务器调用排行榜管理器对象，排行榜管理器对象(RankMgr)通过用户数据中的战场id(sid)和排行榜类型(type)找到对应的排行榜数据对象(RankData)。
3. 排行榜数据对象(RankData),通过用户数据的排行榜类型(rank_type)来找到对应的排行榜对象(RankHeap)
4. 对当前最小堆进行堆排序，返回整个排行榜的数据当客户端。

- 清理排行榜数据
```sequence
title:清理排行榜数据

participant Client as C
participant Serve as S
participant RankMgr as RM



C->S:set_state_rank\n客户端发起请求
S->RM:GetInstance\n调用排行榜管理器
RM->RM:	Destory(sid)\n删除该战场的排行榜数据


```
说明：
1. 活动结束，客户端(其实是后台活动相关的服务)发一个清楚排行榜数据的请求
2. RankMgr通过sid找到对应的RankData,清楚RankData的所有数据。
