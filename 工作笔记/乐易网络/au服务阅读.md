## AU

线程模型：zk线程，上下游网络线程，工作线程，延迟发送线程,action线程（actionget）,推送线程，

配置文件：`serv_info.conf`,`module.conf`,`game.json`,`equip.json`,`function_switch.json`……



通用流程：

1. CProcedureAction::InitProcess

   0au通过4个关键参数：dwTableType、mainclass、secondclass、status来凭借一个64位的long类型数字，从而取出对应的cmdinfo。

2. CDataProcedure::GetData

   从action_get线程中每隔50ms从虚拟节点node_type=2/7/59中拉数据。取出stActionTable，封装到session进行处理

3. CProcedureAction::HandleBefore

   原user和targetuser都要走`AuCommonHandleBefore`，计算buff，tips，狂化等

4. CProcedureBase::ProcessCmd，重载
5. CDataProcedure::UpdateData，下游节点node_type=22/17/56

#### 采集资源

#### **hu**:命令字：`march_occupy`

1. `ProcessParam`:解析url的7个参数`CostTime，TargetPos，TroopList，DragonJoin，CardList，RssStage`等，设置到session中

2. `GetMapBlockInfo`：获取地块数据

3. `CheckNeedExtraInfo`：如果是失落之地，获取邻接地域

4. `CheckMarchTime`：从mapMap中找到主城的地块，计算主城到目标地块的耗时，客户端的时间要大于等于后端计算的时间的0.95倍

5. `ComputeMarchAction`：校验，判定当前行为是否合法，生成`CTpMarch_action`，判定时间和客户端的时间是否差值在0.05内，更新任务状态，埋点发加分请求

   生成action：`CTpMarch_action* CProcessMarch::GenMarchAction`

   `action_id=(ddwUid << 32) + udwSeq`

   ​	结构体：`SActionMarchParam stMarchParam`，填充：`source user，source city id，source alliance id，target user（这里看是不是野怪军队），target map，march time，dragon`，需要消耗资源的，将string转为vector，再转为json然后计算消耗资源，troop（更新剩余军队），如果是侦察，设置侦察等级

   ​	根据结构体`stMarchParam`生成`tuple ptbMarchAction`：`CActionBase::AddMarchAction` tuple填充数据

6. `GenMarchAfter`：获取生成的`ActionId`，然后根据`ActionId`获取`march ptpMarch`。根据`action`种类来判断是否要破坏和平状态

7. 在cmd生成action march后，在updatedata中完成生成action，并下发网络

   `CDataBase::UpdateActionData`:判断是否原始cmd是否为`guide_finish`(新手指引);

   `CDbAction::GenUpdateRequests`:

   ```c++
   class CDbBaseAction : public CDbBase
   {
   public:
       map<TINT64, CTpBuff_action*> m_mapBuff_action;
       map<TINT64, CTpAl_action*> m_mapAl_action;
       map<TINT64, CTpMarch_action*> m_mapActive_march_action;
       map<TINT64, CTpMarch_action*> m_mapPassive_march_action;
       map<TINT64, CTpMarch_action*> m_mapMap_march_action;
       map<TINT64, CTpBuff_action*> m_mapEtime_buff_action;
       map<TINT64, CTpAl_action*> m_mapEtime_al_action;
       map<TINT64, CTpMarch_action*> m_mapEtime_march_action;
   public:
       ...
   }
   ```
   
   
   
   如果类型为update:
   
   1. 拼接json请求头`header`
   
   2. action_id=0的跳过。
   
   3. 遍历buff，al_action,march_action等
   
      更新数据，按照tuple改变状态update，create，delete，来决定具体请求类型。更新：MarchTroopShow，MarchBisShow，GenAlPCacheData。
   
   4. 如果生成成功，将jsnReq放入`pstSession->m_vecNetReq`中。
   
   如果类型为create:
   
   1.  不跳过action_id=0，其他同上。
   
   将jsnReq放入`pstSession->m_vecNetReq`中。
   
   `CNetProcedure::DoNetOperation`将m_vecNetReq中的请求下发网络。

#### **AU**:

ActionGet线程：

每隔50ms，拉取当前stActionTable。actionlist类型设置为EN_UID_ACTION。

zk线程填充m_setNewNode虚拟节点列表。

遍历m_setNewNode

 1.  获取action list

     拼接json请求,从redis缓存拉取dbAction的数据

     1. 清空`stSession.m_jReqParam["db_param"]`

     2. 拉取endtime为当前时间的acitonlist：

        cmd=get_by_etime

        node_type=22 suid,23 aid,24 bid

     打包组装请求

     发送请求`CCgiSocket::Send`

     接受回包

     从回包中解析action info`ParseActionSvrResponse(m_pucBuf, m_udwBufLen, &m_stRspInfo);`到m_stRspInfo：cmd=`get_by_etime`;

     从`m_stRspInfo`中通过`CDbAction::OnResponse`解析出数据action info

 2.  处理请求，则其需要的压入工作队列

     ```c++
     ProcessBuffActionList(stActionTable, udwEndTime);
     ProcessAlActionList(stActionTable, udwEndTime);
     ProcessMarchActionList(stActionTable, udwEndTime);
     ```

     对应hu中dbaction的数据

     session状态设置为`EN_TIME_CONSUMING_STATISTICS_SESSION_QUEUE`

     设置session，压入流程栈`CTaskProcess::InitCommand`

     

##### 命令字：`CProcessMarchOccupy`

命令流程：

1. `CProcessMarchOccupy::PreSuidActionDataCustomized`
   
   预拉取数据

​		如果是铁矿石头木头粮食银币资源地：清空action，生成action：`GenProto_QueryActionByAid`，生成数据拉取请求：downnode=22，设置uid，sid，aid等，拉取数据

​		如果是超级王座-军备库：清空action，生成action：GenProto_QueryActionBySpTa，生成数据拉取请求：downnode=22，设置uid，sid，aid等，拉取数据

2. `CProcessActionMarch::ProcessMarchOccupy`

数据:

​	db:pdbSUser,

​	tp:ptpSPlayer,ptpWildMap,TbMarch_action_Param

​	json配置：wild_res.json

流程：

1. 校验
2. 占据：

按照目的地是资源还是铁矿石头木头粮食银币资源地，

是资源：更新ptpWildMap的Might，Force_kill，Uid等信息如果有联盟，设置Alname，Al_nick，并设置Set_Name_update_time，Bid并设置额外信息包括vip_level，al_nick，uname，etime

是铁矿石头木头粮食银币资源地：设置sal**？？**，如果首次占领，设置ptpWildMap并设置时代

1. 计算buff，根据军队，英雄计算buff，

2. 计算消耗的时间  CMapLogic::ComputeLoadResTime

3. 按照时间计算每小时能装多少资源m_ddwLoadRate

4. 计算总共装置多少资源Load =（troopnum*troopbase）\*(10000 + troopbuff) / 10000;

5. 计算最后结果：min（资源总量，可装置数量）*1.0/资源比率\*3600

6. 增加tips

7. `CPushDataBase::PushDataUid_KeyRefresh`推送消息

占据资源：

hu命令字：

​	get_all_march、map_get_new、get_all_title_info、task_operate、get_all_al_fortress_info、**march_occupy**、item_buy_and_use、msg_get、map_get_new、action_recall

au命令字：

main=2,sec_raw=13,sec_res=13,status_raw=0：CProcessMarchOccupy

main=2,sec_raw=13,sec_res=13,status_raw=4：CProcessMarchLoadingRes

main=2,sec_raw=13,sec_res=13,status_raw=2：CProcessMarchReturn
