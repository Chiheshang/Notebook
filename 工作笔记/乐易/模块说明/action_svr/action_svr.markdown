# action_svr说明

## 服务概要
---
* 数据服
* 服务数据根据key分片,由多节点共同提供服务
* 数据按需拉取,重启无需恢复数据
* 负责存储用户数据缓存,提供用户action增删改查操作,加速数据存取
* 拆分为action_svr_uid,action_svr_aid,action_svr_bid
  * action_svr_uid负责处理etime,suid,tuid索引,以及对应action
  * action_svr_aid负责处理sal,tal索引,以及对应action
  * action_svr_bid负责处理sbid,tbid,以及对应action
  * 对于无法处理的index会转发到对应的svr处理(目前统一uid action处理)
  * 不同类型的action,索引拆分到不同action svr,根据索引类型,去对应的服务查询数据,uid action处理特定索引读和所有写操作,不支持的索引由uid action进行转发,其他svr对外部只读

## 主要流程
---
### 按索引查询action
![图片](images/data_query.png)

---
### 查询指定etime前未结算的action
![图片](images/get_by_etime.png)

---
### 创建新action
![图片](images/data_create.png)

---
### 更新action
![图片](images/data_update.png)

---