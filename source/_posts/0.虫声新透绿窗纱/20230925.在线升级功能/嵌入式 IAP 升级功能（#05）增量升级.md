---
title: 嵌入式 IAP 升级功能（#05）增量升级
id: clnyhr2n4005710rqfv00ckub
date: 2023-10-01 00:00:05
tags: [嵌入式软件开发, 在线升级]
categories: [开发笔记]
---

全量升级由于要传输新版程序的完整镜像，因此升级时间通常较长，升级失败的概率也更大。那么能不能只传送差异数据呢？答案是可以。这种技术被称作增量升级/差量升级/差分升级。

常见的方案有：

- bsdiff/bspatch + quicklz
- hdifflite/hpatchlite + tinyuz

{% note info no-icon %}
不过 bsdiff + quicklz 方案的内存开销太大，因此不建议使用。
{% endnote %}

## 全量升级 & 增量升级

增量升级确实降低了传输过程中的数据量，但也带来了版本管理复杂的问题，所以说不能因为有了增量升级，全量升级就不用了。

以往我们做全量升级的时候没有引入压缩技术，在移植 hdiff/hpatchlite 的时候我发现，hdiff 生成的差异文件不比原文件小多少，但是其可压缩性非常高，这样就得把解压算法也移植进来。既然解压算法都已经有了，不把增量升级也压缩一下，那岂不是很浪费？

<table>
<tbody>
<tr>
    <td align="center" rowspan="2">全量升级</td>
    <td align="center">未经压缩的新版程序</td>
    <td align="center">（✘）</td>
</tr>
<tr>
    <td align="center">经过压缩的新版程序</td>
    <td align="center">（✔）</td>
</tr>
<tr>
    <td align="center" rowspan="2">增量升级</td>
    <td align="center">未经压缩的差异文件</td>
    <td align="center">（✘）</td>
</tr>
<tr>
    <td align="center">经过压缩的差异文件</td>
    <td align="center">（✔）</td>
</tr>
</tbody>
</table>

<!-- more -->

## 升级包头

在线升级无非就是把新程序或者更新补丁发送给设备，设备收到后进行升级的过程。

为了保证升级能够顺利进行，除了新程序或者更新补丁外，我们还要向设备发送一些附加信息，这些附加信息通常被添加至升级文件的头部。

<table>
<tbody>
<tr>
    <td align="center">魔术数字</td>
    <td align="center">04B</td>
    <td align="center">全量升级 ('Q','L','S','J')<br>增量升级 ('Z','L','S','J')</td>
</tr>
<tr>
    <td align="center">包头长度</td>
    <td align="center">04B</td>
    <td align="center">支持变长包头 *</td>
</tr>
<tr>
    <td align="center">文件摘要</td>
    <td align="center">04B</td>
    <td align="center">从「文件长度」之后开始计算</td>
</tr>
<tr>
    <td align="center">文件长度</td>
    <td align="center">04B</td>
    <td align="center">从「文件长度」之后开始计算</td>
</tr>
<tr>
    <td align="center">　</td>
    <td align="center"></td>
    <td align="center"></td>
</tr>
<tr>
    <td align="center">产品型号</td>
    <td align="center">08B</td>
    <td align="center">产品一型 ('P','N','-','A','0','0','0','1')<br>产品二型 ('P','N','-','A','0','0','0','2')</td>
</tr>
<tr>
    <td align="center">设备地址</td>
    <td align="center">08B</td>
    <td align="center">通配地址 (0xFFFFFFFFFFFFFFFF)<br>单点地址 (0x1111111111111111)</td>
</tr>
<tr>
    <td align="center">　</td>
    <td align="center"></td>
    <td align="center"></td>
</tr>
<tr>
    <td align="center">新程序 LEN 值</td>
    <td align="center">04B</td>
    <td align="center" rowspan="6">对旧程序进行摘要值校验<br>或者<br>对旧程序进行差分还原时<br><br>某些可变字段必须以默认值进行处理</td>
</tr>
<tr>
    <td align="center">旧程序 LEN 值</td>
    <td align="center">04B</td>
</tr>
<tr>
    <td align="center">新程序 CRC 值</td>
    <td align="center">04B</td>
</tr>
<tr>
    <td align="center">旧程序 CRC 值</td>
    <td align="center">04B</td>
</tr>
<tr>
    <td align="center">新程序 MD5 值</td>
    <td align="center">16B</td>
</tr>
<tr>
    <td align="center">旧程序 MD5 值</td>
    <td align="center">16B</td>
</tr>
<tr>
    <td align="center">......</td>
    <td align="center"></td>
    <td align="center"></td>
</tr>
<tr>
    <td align="center">可以按需增加</td>
    <td align="center"></td>
    <td align="center"></td>
</tr>
</tbody>
</table>

**变长包头的优势**

![](update.head.scalable.png)

{% note info no-icon %}
升级包头我建议做成变长的，万一哪天包头长度不够用了，扩展后也能兼容现场的老设备。
{% endnote %}

## 升级文件

{% grouppicture 3-3 %}
![未经压缩的全量升级文件结构](clnyhr2n4005710rqfv00ckub/update.file.1.raw.full.png)
![经过压缩的全量升级文件结构](clnyhr2n4005710rqfv00ckub/update.file.2.zip.full.png)
![经过压缩的增量升级文件结构](clnyhr2n4005710rqfv00ckub/update.file.4.zip.diff.png)
{% endgrouppicture %}

## 升级方案

### 未经压缩的全量升级 + 经过压缩的增量升级

![](update.plan.1.raw.full+zip.diff.png)

### 经过压缩的全量升级 + 经过压缩的增量升级

![](update.plan.2.zip.full+zip.diff.png)

## 升级流程

### 接收升级数据

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
Start(接收升级数据<br>开始)-->DoRecv[接收数据]-->IsHeadRecvDone{文件头接收完毕}
IsHeadRecvDone--否/继续接收-->DoRecv
IsHeadRecvDone--是-->IsHeadParsed{文件头已被处理}
IsHeadParsed--是---->DoWrite[将接收到的数据写入外存<br>如果为「压缩增量升级」则将数据写入〈升级数据存储区〉<br>如果为「压缩全量升级」则将数据写入〈升级数据存储区〉<br>如果为「原版全量升级」则将数据写入〈新版程序存储区〉<br>（如果小程序为旧版本则写入时偏移75字节）]-->IsFileRecvOver{文件传输完毕}
IsFileRecvOver--否/继续接收-->DoRecv2[继续接收数据]
IsFileRecvOver--是-->DoCheck[校验接收到的升级文件<br>如果为「压缩增量升级」则从〈升级数据存储区〉中读出数据并计算CRC值<br>如果为「压缩全量升级」则从〈升级数据存储区〉中读出数据并计算CRC值<br>如果为「原版全量升级」则从〈新版程序存储区〉中读出数据并计算CRC值<br>（如果小程序为旧版本则读取时偏移75字节）]-->IsCheckOK{校验是否通过}
IsCheckOK--否-->Over3(结束)
IsCheckOK--是-->DoWriteHead[将文件头中的某些数据写入外存的第一个扇区<br>（如果小程序为旧版本则将“新程序大小”加75字节）]-->DoWriteHeadFlag[将该扇区中的升级标识从0xFFFFFFFF改成0xAABBFFFF]-->IsA{增量升级}
IsA--是-->DoSetA[发起增量升级任务]-->Over4(结束)
IsA--否-->IsB{有压缩的<br>全量升级}
IsB--是-->DoSetB[发起全量升级任务]-->Over4(结束)
IsB--否-->IsC{无压缩的<br>全量升级}
IsC--是-->DoSetC[发起全量升级任务]-->Over4(结束)
IsC--否-->Over5(结束)
IsHeadParsed--否-->IsHeadOK{文件头格式正确}
IsHeadOK--否-->Over1(结束)
IsHeadOK--是-->IsDiffUpdate{是否为增量升级}
IsDiffUpdate--否/继续接收-->DoRecv
IsDiffUpdate--是-->IsCRCOK{文件头中的旧程序CRC与<br>当前程序的CRC是否一致}
IsCRCOK--（当前程序中的可变字段以默认值进行处理）<br><br>不一致-->Over2(结束)
IsCRCOK--是/继续接收-->DoRecv
{% endmermaid %}

### 执行升级任务

{% mermaid flowchart TB %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
Start(执行升级任务<br>开始)-->IsUpdateFlag{升级文件接收完毕}
IsUpdateFlag--否-->IsUpdateFlag
IsUpdateFlag--是-->DoReadHead[从外存的第一个扇区中读取升级信息]-->IsReadSucc{读取成功}
IsReadSucc--否-->Over1(结束)
IsReadSucc--是-->IsUpdateFlagIsDownload{升级标识==0xAABBFFFF}
IsUpdateFlagIsDownload--否-->Over2(结束)
IsUpdateFlagIsDownload--是-->IsUpdateTypeIsZipDiff{是否为压缩增量升级}
IsUpdateTypeIsZipDiff--是-->DoUnDiff[执行差分还原操作]--如果小程序为旧版本<br>则写入时偏移75字节<br>当前程序中的可变字段以默认值进行处理--->DoCheckNewAppCRC
IsUpdateTypeIsZipDiff--否-->IsUpdateTypeIsZipFull{是否为压缩全量升级}
IsUpdateTypeIsZipFull--是-->DoUnZip[执行文件解压操作]--如果小程序为旧版本<br>则写入时偏移75字节--->DoCheckNewAppCRC
IsUpdateTypeIsZipFull--否-->IsUpdateTypeIsRawFull{是否为原版全量升级}
IsUpdateTypeIsRawFull--是-->DoNothing[无需执行任何操作]--->DoCheckNewAppCRC[校验新程序<br>对比文件头中的新程序CRC与<br>新程序存储区中的数据的CRC]
IsUpdateTypeIsRawFull--否-->Over3(结束)
DoCheckNewAppCRC--如果小程序为旧版本<br>则读取时偏移75字节--->IsCRCCheckOK{CRC是否一致}
IsCRCCheckOK--否-->Over4(结束)
IsCRCCheckOK--是-->DoChangeUpdateFlag[将外存中的升级标识从0xAABBFFFF改为0xAABBCCDD]-->IsChangeSucc{修改是否成功}
IsChangeSucc--否-->Over5(结束)
IsChangeSucc--是-->DoChangeInternalFlashUpdateFlag[将内部flash中的0xAABBCCDD改成0x0000CCDD]-->DoReset[一秒后重启进入引导程序]-->OverX(结束)
{% endmermaid %}
