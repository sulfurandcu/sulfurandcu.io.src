---
title: 嵌入式 IAP 升級功能（#05）增量升級
date: 2023-10-01 00:00:05
tags: [嵌入式軟件開發, 在線升級]
categories: [開發筆記]
---

全量升級由於要傳輸新版程序的完整鏡像，因此升級時間通常較長，升級失敗的概率也更大。那麼能不能只傳送差異數據呢？答案是可以。這種技術被稱作增量升級/差量升級/差分升級。

常見的方案有：

- bsdiff/bspatch + quicklz
- hdifflite/hpatchlite + tinyuz

{% note info no-icon %}
不過 bsdiff + quicklz 方案的內存開銷太大，現已不建議使用。
{% endnote %}

<!-- more -->

## 全量升級 & 增量升級

增量升級確實降低了傳輸過程中的數據量，但也帶來了版本管理複雜的問題，所以說不能因爲有了增量升級，全量升級就不用了。

以往我們做全量升級的時候沒有引入壓縮技術，在移植 hdiff/hpatchlite 的時候我發現，hdiff 生成的差異文件不比原文件小多少，但是其可壓縮性非常高，這樣就得把解壓算法也移植進來。既然解壓算法都已經有了，不把增量升級也壓縮一下，那豈不是很浪費？

<table>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">全量升級</td>
    <td align="center">未經壓縮的新版程序</td>
    <td align="center">（✘）</td>
</tr>
<tr>
    <td align="center">經過壓縮的新版程序</td>
    <td align="center">（✔）</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">增量升級</td>
    <td align="center">未經壓縮的差異文件</td>
    <td align="center">（✘）</td>
</tr>
<tr>
    <td align="center">經過壓縮的差異文件</td>
    <td align="center">（✔）</td>
</tr>
</tbody>
</table>

## 升級包頭

在線升級無非就是把新程序或者更新補丁發送給設備，設備收到後進行升級的過程。

爲了保證升級能夠順利進行，除了新程序或者更新補丁外，我們還要向設備發送一些附加信息，這些附加信息通常被添加至升級文件的頭部。

![圖片加載失敗](update.head.png)

**變長包頭的優勢**

![圖片加載失敗](update.head.scalable.png)

{% note info no-icon %}
升級包頭我建議做成變長的，萬一哪天包頭長度不夠用了，擴展後也能兼容現場的老設備。
{% endnote %}

## 升級文件

### 未經壓縮的全量升級文件結構

![圖片加載失敗](update.file.1.raw.full.png)

### 經過壓縮的全量升級文件結構

![圖片加載失敗](update.file.2.zip.full.png)

### 經過壓縮的增量升級文件結構

![圖片加載失敗](update.file.4.zip.diff.png)

## 升級方案

### 未經壓縮的全量升級 + 經過壓縮的增量升級

![圖片加載失敗](update.plan.1.raw.full+zip.diff.png)

### 經過壓縮的全量升級 + 經過壓縮的增量升級

![圖片加載失敗](update.plan.2.zip.full+zip.diff.png)

## 升級流程

### 接收升級數據

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
Start(接收升級數據<br>開始)-->DoRecv[接收數據]-->IsHeadRecvDone{文件頭接收完畢}
IsHeadRecvDone--否/繼續接收-->DoRecv
IsHeadRecvDone--是-->IsHeadParsed{文件頭已被處理}
IsHeadParsed--是---->DoWrite[將接收到的數據寫入外存<br>如果爲「壓縮增量升級」則將數據寫入〈升級數據存儲區〉<br>如果爲「壓縮全量升級」則將數據寫入〈升級數據存儲區〉<br>如果爲「原版全量升級」則將數據寫入〈新版程序存儲區〉<br>（如果小程序爲舊版本則寫入時偏移75字節）]-->IsFileRecvOver{文件傳輸完畢}
IsFileRecvOver--否/繼續接收-->DoRecv2[繼續接收數據]
IsFileRecvOver--是-->DoCheck[校驗接收到的升級文件<br>如果爲「壓縮增量升級」則從〈升級數據存儲區〉中讀出數據並計算CRC值<br>如果爲「壓縮全量升級」則從〈升級數據存儲區〉中讀出數據並計算CRC值<br>如果爲「原版全量升級」則從〈新版程序存儲區〉中讀出數據並計算CRC值<br>（如果小程序爲舊版本則讀取時偏移75字節）]-->IsCheckOK{校驗是否通過}
IsCheckOK--否-->Over3(結束)
IsCheckOK--是-->DoWriteHead[將文件頭中的某些數據寫入外存的第一個扇區<br>（如果小程序爲舊版本則將“新程序大小”加75字節）]-->DoWriteHeadFlag[將該扇區中的升級標識從0xFFFFFFFF改成0xAABBFFFF]-->IsA{增量升級}
IsA--是-->DoSetA[發起增量升級任務]-->Over4(結束)
IsA--否-->IsB{有壓縮的<br>全量升級}
IsB--是-->DoSetB[發起全量升級任務]-->Over4(結束)
IsB--否-->IsC{無壓縮的<br>全量升級}
IsC--是-->DoSetC[發起全量升級任務]-->Over4(結束)
IsC--否-->Over5(結束)
IsHeadParsed--否-->IsHeadOK{文件頭格式正確}
IsHeadOK--否-->Over1(結束)
IsHeadOK--是-->IsDiffUpdate{是否爲增量升級}
IsDiffUpdate--否/繼續接收-->DoRecv
IsDiffUpdate--是-->IsCRCOK{文件頭中的舊程序CRC與<br>當前程序的CRC是否一致}
IsCRCOK--（當前程序中的可變字段以默認值進行處理）<br><br>不一致-->Over2(結束)
IsCRCOK--是/繼續接收-->DoRecv
{% endmermaid %}

### 執行升級任務

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
Start(執行升級任務<br>開始)-->IsUpdateFlag{文件頭接收完畢}
IsUpdateFlag--否-->IsUpdateFlag
IsUpdateFlag--是-->DoReadHead[從外存的第一個扇區中讀取升級信息]-->IsReadSucc{讀取成功}
IsReadSucc--否-->Over1(結束)
IsReadSucc--是-->IsUpdateFlagIsDownload{升級標識==0xAABBFFFF}
IsUpdateFlagIsDownload--否-->Over2(結束)
IsUpdateFlagIsDownload--是-->IsUpdateTypeIsZipDiff{是否爲壓縮增量升級}
IsUpdateTypeIsZipDiff--是-->DoUnDiff[執行差分還原操作]--如果小程序爲舊版本<br>則寫入時偏移75字節<br>當前程序中的可變字段以默認值進行處理--->DoCheckNewAppCRC
IsUpdateTypeIsZipDiff--否-->IsUpdateTypeIsZipFull{是否爲壓縮全量升級}
IsUpdateTypeIsZipFull--是-->DoUnZip[執行文件解壓操作]--如果小程序爲舊版本<br>則寫入時偏移75字節--->DoCheckNewAppCRC
IsUpdateTypeIsZipFull--否-->IsUpdateTypeIsRawFull{是否爲原版全量升級}
IsUpdateTypeIsRawFull--是-->DoNothing[無需執行任何操作]--->DoCheckNewAppCRC[校驗新程序<br>對比文件頭中的新程序CRC與<br>新程序存儲區中的數據的CRC]
IsUpdateTypeIsRawFull--否-->Over3(結束)
DoCheckNewAppCRC--如果小程序爲舊版本<br>則讀取時偏移75字節--->IsCRCCheckOK{CRC是否一致}
IsCRCCheckOK--否-->Over4(結束)
IsCRCCheckOK--是-->DoChangeUpdateFlag[將外存中的升級標識從0xAABBFFFF改爲0xAABBCCDD]-->IsChangeSucc{修改是否成功}
IsChangeSucc--否-->Over5(結束)
IsChangeSucc--是-->DoChangeInternalFlashUpdateFlag[將內部flash中的0xAABBCCDD改成0x0000CCDD]-->DoReset[一秒後重啓進入引導程序]-->OverX(結束)
{% endmermaid %}
