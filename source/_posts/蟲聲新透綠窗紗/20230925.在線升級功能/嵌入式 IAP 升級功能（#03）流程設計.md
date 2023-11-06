---
title: 嵌入式 IAP 升級功能（#03）流程設計
id: clnyhr2n3005010rqf3gcgp39
date: 2023-10-01 00:00:03
tags: [嵌入式軟件開發, 在線升級]
categories: [開發筆記]
---

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
A1(引導程序之流程)-->B1(......)-->C1(跳轉至應用程序)
A2(應用程序之流程)-->B2(......)-->C2(跳轉至引導程序)
{% endmermaid %}

<!-- more -->

## 引導程序流程

引導程序的設計方案我知道有兩種：

- 立即跳轉方案
- 延時跳轉方案

立即跳轉方案在判斷出應用程序有效之後會立即執行跳轉操作，該方案適用於對啓動時間要求比較高的產品。延時跳轉方案則是先在引導程序中等待一段時間，在這段時間內如果沒有任何請求則時間到了之後會自動跳轉至應用程序，否則將停留在引導程序中。

### 立即跳轉方案

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
PowerReset(設備上電覆位)-->IapStart(引導程序開始)-->IapCheckApp[檢查應用程序有效標識]-->IapIsAppValid{是否有效}
IapIsAppValid--是-->IapJumpToApp[跳轉進入應用程序]-->IapOver(引導程序結束)
IapIsAppValid--否-->IapRemap[重定向中斷向量表]-->IapInit[配置相關外設]-->IapIsHaveUpdateData{是否存在<br>升級數據}
IapIsHaveUpdateData--否-->IapBeforeJump
IapIsHaveUpdateData--是-->IapDoUpdate[執行升級操作]--->IapEraseUpdateData[擦除升級數據]-->IapIsUpdateSucc{升級成功}
IapIsUpdateSucc--是--->IapSetAppValid[修改應用程序有效標識：有效]-->IapBeforeJump[關閉外設和中斷]-->IapJumpToApp
IapIsUpdateSucc--否-->IapIsAppErased{應用程序已損毀}
IapIsAppErased--否-->IapBeforeJump
IapIsAppErased--是<br>留在引導程序中-->IapComm[執行通信任務]-->IapIsRecvDone{收到升級數據}
IapIsRecvDone--否-->IapComm
IapIsRecvDone--是-->IapDoUpdate
{% endmermaid %}

### 延時跳轉方案

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
PowerReset(設備上電覆位)-->IapStart(引導程序開始)-->IapCheckApp[檢查應用程序有效標識]-->IapIsAppValid{是否有效}
IapIsAppValid--是-->IapWait{計數超時<br>（延時跳轉）}
IapWait--否-->IapWait
IapWait--是---------->IapJumpToApp[跳轉進入應用程序]-->IapOver(引導程序結束)
IapIsAppValid--否-->IapRemap[重定向中斷向量表]-->IapInit[配置相關外設]-->IapIsHaveUpdateData{是否存在<br>升級數據}
IapIsHaveUpdateData--否-->IapBeforeJump
IapIsHaveUpdateData--是-->IapDoUpdate[執行升級操作]--->IapEraseUpdateData[擦除升級數據]-->IapIsUpdateSucc{升級成功}
IapIsUpdateSucc--是--->IapSetAppValid[修改應用程序有效標識：有效]-->IapBeforeJump[關閉外設和中斷]-->IapJumpToApp
IapIsUpdateSucc--否-->IapIsAppErased{應用程序已損毀}
IapIsAppErased--否-->IapBeforeJump
IapIsAppErased--是<br>留在引導程序中-->IapComm[執行通信任務]-->IapIsRecvDone{收到升級數據}
IapIsRecvDone--否-->IapComm
IapIsRecvDone--是-->IapDoUpdate
{% endmermaid %}

## 應用程序流程

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
AppStart(應用程序開始)-->AppRemap[重定向中斷向量表]-->AppInit[配置相關外設]-->AppTask[執行應用功能]-->AppComm[執行通信任務]-->AppIsRecvDone{收到升級數據}
AppIsRecvDone--否-->AppTask
AppIsRecvDone--是-->AppSetAppInvalid[修改應用程序有效標識：無效]-->AppBeforeJump[關閉外設和中斷]-->AppJumpToIap[重啓進入引導程序｜跳轉進入引導程序]-->AppOver(應用程序結束)
{% endmermaid %}
