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

9. 强行设置不更新，只更新tips和



