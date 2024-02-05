---
title: 嵌入式 IAP 升级功能（#03）流程设计
id: clnyhr2n3005010rqf3gcgp39
date: 2023-10-01 00:00:03
tags: [嵌入式软件开发, 在线升级]
categories: [开发笔记]
---

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
A1(引导程序之流程)-->B1(......)-->C1(跳转至应用程序)
A2(应用程序之流程)-->B2(......)-->C2(跳转至引导程序)
{% endmermaid %}

<!-- more -->

## 引导程序流程

引导程序的设计方案我知道有两种：

- 立即跳转方案
- 延时跳转方案

立即跳转方案在判断出应用程序有效之后会立即执行跳转操作，该方案适用于对启动时间要求比较高的产品。延时跳转方案则是先在引导程序中等待一段时间，在这段时间内如果没有任何请求则时间到了之后会自动跳转至应用程序，否则将停留在引导程序中。

### 立即跳转方案

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
PowerReset(设备上电复位)-->IapStart(引导程序开始)-->IapCheckApp[检查应用程序有效标识]-->IapIsAppValid{是否有效}
IapIsAppValid--是-->IapJumpToApp[跳转进入应用程序]-->IapOver(引导程序结束)
IapIsAppValid--否-->IapRemap[重定向中断向量表]-->IapInit[配置相关外设]-->IapIsHaveUpdateData{是否存在<br>升级数据}
IapIsHaveUpdateData--否-->IapBeforeJump
IapIsHaveUpdateData--是-->IapDoUpdate[执行升级操作]--->IapEraseUpdateData[擦除升级数据]-->IapIsUpdateSucc{升级成功}
IapIsUpdateSucc--是--->IapSetAppValid[修改应用程序有效标识：有效]-->IapBeforeJump[关闭外设和中断]-->IapJumpToApp
IapIsUpdateSucc--否-->IapIsAppErased{应用程序已损毁}
IapIsAppErased--否-->IapBeforeJump
IapIsAppErased--是<br>留在引导程序中-->IapComm[执行通信任务]-->IapIsRecvDone{收到升级数据}
IapIsRecvDone--否-->IapComm
IapIsRecvDone--是-->IapDoUpdate
{% endmermaid %}

### 延时跳转方案

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
PowerReset(设备上电复位)-->IapStart(引导程序开始)-->IapCheckApp[检查应用程序有效标识]-->IapIsAppValid{是否有效}
IapIsAppValid--是-->IapWait{计数超时<br>（延时跳转）}
IapWait--否-->IapWait
IapWait--是---------->IapJumpToApp[跳转进入应用程序]-->IapOver(引导程序结束)
IapIsAppValid--否-->IapRemap[重定向中断向量表]-->IapInit[配置相关外设]-->IapIsHaveUpdateData{是否存在<br>升级数据}
IapIsHaveUpdateData--否-->IapBeforeJump
IapIsHaveUpdateData--是-->IapDoUpdate[执行升级操作]--->IapEraseUpdateData[擦除升级数据]-->IapIsUpdateSucc{升级成功}
IapIsUpdateSucc--是--->IapSetAppValid[修改应用程序有效标识：有效]-->IapBeforeJump[关闭外设和中断]-->IapJumpToApp
IapIsUpdateSucc--否-->IapIsAppErased{应用程序已损毁}
IapIsAppErased--否-->IapBeforeJump
IapIsAppErased--是<br>留在引导程序中-->IapComm[执行通信任务]-->IapIsRecvDone{收到升级数据}
IapIsRecvDone--否-->IapComm
IapIsRecvDone--是-->IapDoUpdate
{% endmermaid %}

## 应用程序流程

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
AppStart(应用程序开始)-->AppRemap[重定向中断向量表]-->AppInit[配置相关外设]-->AppTask[执行应用功能]-->AppComm[执行通信任务]-->AppIsRecvDone{收到升级数据}
AppIsRecvDone--否-->AppTask
AppIsRecvDone--是-->AppSetAppInvalid[修改应用程序有效标识：无效]-->AppBeforeJump[关闭外设和中断]-->AppJumpToIap[重启进入引导程序｜跳转进入引导程序]-->AppOver(应用程序结束)
{% endmermaid %}
