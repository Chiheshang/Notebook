### AU

线程模型：zk线程，上下游网络线程，工作线程，延迟发送线程

命令字：CProcessMarchOccupy

命令流程：

1.CProcessMarchOccupy::PreSuidActionDataCustomized

1. 预拉取数据

​		如果是铁矿石头木头粮食银币资源地：清空action，生成action：GenProto_QueryActionByAid，生成数据拉取请求：

​			downnode=22，设置uid，sid，aid等，拉取数据

​	 	如果是超级王座-军备库：清空action，生成action：GenProto_QueryActionBySpTa，生成数据拉取请求：

​			downnode=22，设置uid，sid，aid等，拉取数据

2.CProcessActionMarch::ProcessMarchOccupy

数据:

​	db:pdbSUser,

​	tp:ptpSPlayer,ptpWildMap,TbMarch_action_Param

​	json：wild_res.json

流程：

1. 校验：

    

2. 占据：

   按照目的地是资源还是铁矿石头木头粮食银币资源地，

   是资源：更新ptpWildMap的Might，Force_kill，Uid等信息如果有联盟，设置Alname，Al_nick，并设置Set_Name_update_time，Bid并设置额外信息包括vip_level，al_nick，uname，etime

   是铁矿石头木头粮食银币资源地：设置sal**？？**，如果首次占领，设置ptpWildMap并设置时代

3. 计算buff，根据军队，英雄计算buff，

4. 计算消耗的时间  CMapLogic::ComputeLoadResTime

5. 按照时间计算每小时能装多少资源m_ddwLoadRate

6. 计算总共装置多少资源Load =（troopnum*troopbase）\*(10000 + troopbuff) / 10000;

7. 计算最后结果：min（资源总量，可装置数量）*1.0/资源比率\*3600

8. 增加tips

9. 强行设置不更新，只更新tips和report



#### 采集资源

hu命令字：`march_occupy`

1. `ProcessParam`:解析url的7个参数`CostTime，TargetPos，TroopList，DragonJoin，CardList，RssStage`等，设置到session中

2. `GetMapBlockInfo`：获取地块数据

3. `CheckNeedExtraInfo`：如果是失落之地，获取邻接地域

4. `CheckMarchTime`：从mapMap中找到主城的地块，计算主城到目标地块的耗时，看计算的时候和客户端传入的时间是否差值超过0.05

5. `ComputeMarchAction`：校验，判定当前行为是否合法，生成`CTpMarch_action`，判定时间和客户端的时间是否差值在0.05内，更新任务状态，埋点发加分请求

   生成action：`CTpMarch_action* CProcessMarch::GenMarchAction`

   ​	结构体：`SActionMarchParam stMarchParam`，填充：`source user，source city id，source alliance id，target user（这里看是不是野怪军队），target map，march time，dragon，需要消耗资源的，将string转为vector，再转为json然后计算消耗资源，troop（更新剩余军队），如果是侦察，设置侦察等级`

   ​	根据结构体`stMarchParam`生成`tuple ptbMarchAction`：`CActionBase::AddMarchAction` tuple填充数据

6. `GenMarchAfter`：获取生成的`ActionId`，然后根据`ActionId`获取`march ptpMarch`。根据`action`种类来判断是否要破坏和平状态

7. 在cmd生成action march后，在updatedata中完成生成action，并下发网络

   `CDbAction::GenUpdateRequests`

   

   

​	
