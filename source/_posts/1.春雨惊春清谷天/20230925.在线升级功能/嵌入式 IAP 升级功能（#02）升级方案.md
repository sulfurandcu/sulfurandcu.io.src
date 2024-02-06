---
title: 嵌入式 IAP 升级功能（#02）升级方案
id: clnyhr2n3004y10rq322c66uu
date: 2023-10-01 00:00:02
tags: [嵌入式软件开发, 在线升级]
categories: [开发笔记]
---

<center>which one is better?</center>
<br>

{% mermaid flowchart LR %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
A(在引导程序中集成通信协议栈与解压还原算法)~~~B(在应用程序中集成通信协议栈与解压还原算法)
{% endmermaid %}

<!-- more -->

## 思路（#1）：引导程序主导

<table>
<thead>
<tr>
<th align="center">具体分工</th>
<th align="center">引导程序</th>
<th align="center">应用程序</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">编程操作</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
<tr>
<td align="center">通信协议</td>
<td align="center">完备的通信协议栈</td>
<td align="center">　　　　　　　　</td>
</tr>
<tr>
<td align="center">文件解压</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
<tr>
<td align="center">差分还原</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
</tbody>
</table>

{% note success no-icon %}
**优点**：设备中没有应用程序或应用程序异常时也可以进行 IAP 升级。
{% endnote %}

{% note danger no-icon %}
**缺点**：在引导程序中集成通信协议栈、文件解压、差分还原等功能，会导致其代码量较大。
{% endnote %}

## 思路（#2）：应用程序主导

<table>
<thead>
<tr>
<th align="center">具体分工</th>
<th align="center">引导程序</th>
<th align="center">应用程序</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">编程操作</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
<tr>
<td align="center">通信协议</td>
<td align="center">　　　　　　　　</td>
<td align="center">完备的通信协议栈</td>
</tr>
<tr>
<td align="center">文件解压</td>
<td align="center"></td>
<td align="center">✔</td>
</tr>
<tr>
<td align="center">差分还原</td>
<td align="center"></td>
<td align="center">✔</td>
</tr>
</tbody>
</table>

{% note success no-icon %}
**优点**：引导程序比较简单，占用空间小，方便维护。
{% endnote %}

{% note danger no-icon %}
**缺点**：设备中没有应用程序或应用程序异常时无法进行 IAP 升级。
{% endnote %}

## 思路（#3）：两者各取所长

<table>
<thead>
<tr>
<th align="center">具体分工</th>
<th align="center">引导程序</th>
<th align="center">应用程序</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">编程操作</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
<tr>
<td align="center">通信协议</td>
<td align="center">基础的通信协议栈</td>
<td align="center">完备的通信协议栈</td>
</tr>
<tr>
<td align="center">文件解压</td>
<td align="center"></td>
<td align="center">✔</td>
</tr>
<tr>
<td align="center">差分还原</td>
<td align="center"></td>
<td align="center">✔</td>
</tr>
</tbody>
</table>

{% note success no-icon %}
**特点**：在引导程序中集成基础的通信协议栈，代码量能接受，应用程序异常时也能在线升级。
{% endnote %}

{% note success no-icon %}
**特点**：在应用程序中集成完整的通信协议栈、文件解压、差分还原等功能，功能完备。
{% endnote %}

## 方案（#0）

<table>
<thead>
<tr>
<th align="center">内部flash存储空间划分</th>
<th align="center">内部flash存储空间细分</th>
</tr>
</thead>
<tbody>
<tr>
    <td align="center" rowspan="2">引导程序存储区<br>bootloader</td>
    <td align="center">中断向量表</td>
</tr>
<tr>
    <td align="center">引导程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center">参数数据存储区</td>
    <td align="center">掉电不丢失的系统参数</td>
</tr>
</tbody>
</table>

设备收到升级指令后，重启进入或跳转进入引导程序。进入引导程序后首先擦除应用程序存储区，然后等待接收新版应用程序（直接写入到升级文件存储区），等接收完毕且校验无误后跳转至应用程序，至此升级完成。

## 方案（#1）

<table>
<thead>
<tr>
<th align="center">内部flash存储空间划分</th>
<th align="center">内部flash存储空间细分</th>
</tr>
</thead>
<tbody>
<tr>
    <td align="center" rowspan="2">引导程序存储区<br>bootloader</td>
    <td align="center">中断向量表</td>
</tr>
<tr>
    <td align="center">引导程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">升级数据存储区</td>
    <td align="center">解压后的新版程序</td>
</tr>
<tr>
    <td align="center">接收到的压缩文件</td>
</tr>
<tr>
    <td align="center">参数数据存储区</td>
    <td align="center">掉电不丢失的系统参数</td>
</tr>
</tbody>
</table>

或

<table>
<thead>
<tr>
<th align="center">内部flash存储空间划分</th>
<th align="center">内部flash存储空间细分</th>
</tr>
</thead>
<tbody>
<tr>
    <td align="center" rowspan="2">引导程序存储区<br>bootloader</td>
    <td align="center">中断向量表</td>
</tr>
<tr>
    <td align="center">引导程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center">参数数据存储区</td>
    <td align="center">掉电不丢失的系统参数</td>
</tr>
</tbody>
<thead>
<tr>
<th align="center">外部flash存储空间划分</th>
<th align="center">外部flash存储空间细分</th>
</tr>
</thead>
<tbody>
<tr>
    <td align="center" rowspan="2">升级数据存储区</td>
    <td align="center">解压后的新版程序</td>
</tr>
<tr>
    <td align="center">接收到的压缩文件</td>
</tr>
</tbody>
</table>

### 思路（#1）

设备收到升级指令后，重启进入或跳转进入引导程序。进入引导程序后首先擦除升级文件存储区，然后等待接收新版应用程序（暂时存放至升级文件存储区），等接收完毕且校验无误后，擦除旧版应用程序，然后将升级文件存储区中的新版应用程序拷贝/解压/差分还原至应用程序存储区，最后跳转至应用程序，至此升级完成。

### 思路（#2）

设备收到升级指令后，首先擦除升级文件存储区，然后等待接收新版应用程序（暂时存放至升级文件存储区），等接收完毕且校验无误后，将升级文件存储区中的新版应用程序拷贝/解压/差分还原至新版程序存储区，重启进入或跳转进入引导程序。进入引导程序后对新版程序进行二次校验，校验通过后擦除旧版应用程序，然后将新版程序存储区中的新版应用程序拷贝至应用程序存储区，最后跳转至应用程序，至此升级完成。

### 思路（#3）

设备收到升级指令后，首先擦除升级文件存储区，然后等待接收新版应用程序（暂时存放至升级文件存储区），等接收完毕且校验无误后，将升级文件存储区中的新版应用程序拷贝/解压/差分还原至新版程序存储区，重启进入或跳转进入引导程序。进入引导程序后对新版程序进行二次校验，校验通过后擦除旧版应用程序，然后将新版程序存储区中的新版应用程序拷贝至应用程序存储区，最后跳转至应用程序，至此升级完成。

抹除应用程序有效标识后，重启进入或跳转进入引导程序。进入引导程序后等待通信，若收到升级指令，首先擦除升级文件存储区，然后等待接收新版应用程序（暂时存放至升级文件存储区），等接收完毕且校验无误后，擦除旧版应用程序，然后将升级文件存储区中的新版应用程序拷贝（不支持解压和差分还原）至应用程序存储区，最后跳转至应用程序，至此升级完成。

## 方案（#2）

<table>
<thead>
<tr>
<th align="center">内部flash存储空间划分</th>
<th align="center">内部flash存储空间细分</th>
</tr>
</thead>
<tbody>
<tr>
    <td align="center" rowspan="2">引导程序存储区<br>bootloader</td>
    <td align="center">中断向量表</td>
</tr>
<tr>
    <td align="center">引导程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区<br>（1）</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区<br>（2）</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center">参数数据存储区</td>
    <td align="center">掉电不丢失的系统参数</td>
</tr>
</tbody>
</table>

### 思路（#1）

设备收到升级指令后，重启进入或跳转进入引导程序。进入引导程序后首先擦除备份应用存储区，然后等待接收新版应用程序（直接写入到备份应用存储区），等接收完毕且校验无误后，翻转APP1与APP2的有效标识，并根据标识跳转至正确的应用程序，至此升级完成。

### 思路（#2）

设备收到升级指令后，首先擦除备份应用存储区，然后等待接收新版应用程序（直接写入到备份应用存储区），等接收完毕且校验无误后，翻转APP1与APP2的有效标识，重启进入或跳转进入引导程序，在引导程序中根据标识跳转至正确的应用程序，至此升级完成。

### 思路（#3）

设备收到升级指令后，首先擦除备份应用存储区，然后等待接收新版应用程序（直接写入到备份应用存储区），等接收完毕且校验无误后，翻转APP1与APP2的有效标识，重启进入或跳转进入引导程序，在引导程序中根据标识跳转至正确的应用程序，至此升级完成。

抹除应用程序有效标识后，重启进入或跳转进入引导程序。进入引导程序后等待通信，若收到升级指令，首先擦除备份应用存储区，然后等待接收新版应用程序（直接写入到备份应用存储区），等接收完毕且校验无误后，翻转APP1与APP2的有效标识，并根据标识跳转至正确的应用程序，至此升级完成。

## 方案（#3）

<table>
<thead>
<tr>
<th align="center">内部flash存储空间划分</th>
<th align="center">内部flash存储空间细分</th>
</tr>
</thead>
<tbody>
<tr>
    <td align="center" rowspan="2">引导程序存储区<br>bootloader</td>
    <td align="center">中断向量表</td>
</tr>
<tr>
    <td align="center">引导程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区<br>（1）</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区<br>（2）</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">升级数据存储区</td>
    <td align="center">解压后的新版程序</td>
</tr>
<tr>
    <td align="center">接收到的压缩文件</td>
</tr>
<tr>
    <td align="center">参数数据存储区</td>
    <td align="center">掉电不丢失的系统参数</td>
</tr>
</tbody>
</table>

或

<table>
<thead>
<tr>
<th align="center">内部flash存储空间划分</th>
<th align="center">内部flash存储空间细分</th>
</tr>
</thead>
<tbody>
<tr>
    <td align="center" rowspan="2">引导程序存储区<br>bootloader</td>
    <td align="center">中断向量表</td>
</tr>
<tr>
    <td align="center">引导程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区<br>（1）</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center" rowspan="2">应用程序存储区<br>（2）</td>
    <td align="center">重定向的中断向量表</td>
</tr>
<tr>
    <td align="center">应用程序</td>
</tr>
<tr>
    <td align="center">参数数据存储区</td>
    <td align="center">掉电不丢失的系统参数</td>
</tr>
</tbody>
<thead>
<tr>
<th align="center">外部flash存储空间划分</th>
<th align="center">外部flash存储空间细分</th>
</tr>
</thead>
<tbody>
<tr>
    <td align="center" rowspan="2">升级数据存储区</td>
    <td align="center">解压后的新版程序</td>
</tr>
<tr>
    <td align="center">接收到的压缩文件</td>
</tr>
</tbody>
</table>

### 思路（#1）

设备收到升级指令后，重启进入或跳转进入引导程序。进入引导程序后首先擦除升级文件存储区，然后等待接收新版应用程序（暂时存放至升级文件存储区），等接收完毕且校验无误后，擦除备份应用存储区，然后将升级文件存储区中的新版应用程序拷贝/解压/差分还原至备份应用存储区，最后翻转APP1与APP2的有效标识，并根据标识跳转至正确的应用程序，至此升级完成。

### 思路（#2）

设备收到升级指令后，首先擦除升级文件存储区，然后等待接收新版应用程序（暂时存放至升级文件存储区），等接收完毕且校验无误后，擦除备份应用存储区，然后将升级文件存储区中的新版应用程序拷贝/解压/差分还原至备份应用存储区，翻转APP1与APP2的有效标识，重启进入或跳转进入引导程序，在引导程序中根据标识跳转至正确的应用程序，至此升级完成。

### 思路（#3）

设备收到升级指令后，首先擦除升级文件存储区，然后等待接收新版应用程序（暂时存放至升级文件存储区），等接收完毕且校验无误后，擦除备份应用存储区，然后将升级文件存储区中的新版应用程序拷贝/解压/差分还原至备份应用存储区，翻转APP1与APP2的有效标识，重启进入或跳转进入引导程序，在引导程序中根据标识跳转至正确的应用程序，至此升级完成。

抹除应用程序有效标识后，重启进入或跳转进入引导程序。进入引导程序后等待通信，若收到升级指令，首先擦除升级文件存储区，然后等待接收新版应用程序（暂时存放至升级文件存储区），等接收完毕且校验无误后，擦除备份应用存储区，然后将升级文件存储区中的新版应用程序拷贝（不支持解压和差分还原）至备份应用存储区，最后翻转APP1与APP2的有效标识，并根据标识跳转至正确的应用程序，至此升级完成。
