---
title: 嵌入式 IAP 升級功能（#02）升級方案
id: clnyhr2n3004y10rq322c66uu
date: 2023-10-01 00:00:02
tags: [嵌入式軟件開發, 在線升級]
categories: [開發筆記]
---

<center>引導程序主導｜應用程序主導</center>
<center>which one is better?</center>
<br>

![圖片加載失敗](/images/cover.png)

<!-- more -->

## 思路（#1）：引導程序主導

<table>
<thead>
<tr>
<th align="center">具體分工</th>
<th align="center">引導程序</th>
<th align="center">應用程序</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">編程操作</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
<tr>
<td align="center">通信協議</td>
<td align="center">完備的通信協議棧</td>
<td align="center">　　　　　　　　</td>
</tr>
<tr>
<td align="center">文件解壓</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
<tr>
<td align="center">差分還原</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
</tbody>
</table>

{% note success no-icon %}
**優點**：設備中沒有應用程序或應用程序異常時也可以進行 IAP 升級。
{% endnote %}

{% note danger no-icon %}
**缺點**：在引導程序中集成通信協議棧、文件解壓、差分還原等功能，會導致其代碼量較大。
{% endnote %}

## 思路（#2）：應用程序主導

<table>
<thead>
<tr>
<th align="center">具體分工</th>
<th align="center">引導程序</th>
<th align="center">應用程序</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">編程操作</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
<tr>
<td align="center">通信協議</td>
<td align="center">　　　　　　　　</td>
<td align="center">完備的通信協議棧</td>
</tr>
<tr>
<td align="center">文件解壓</td>
<td align="center"></td>
<td align="center">✔</td>
</tr>
<tr>
<td align="center">差分還原</td>
<td align="center"></td>
<td align="center">✔</td>
</tr>
</tbody>
</table>

{% note success no-icon %}
**優點**：引導程序比較簡單，佔用空間小，方便維護。
{% endnote %}

{% note danger no-icon %}
**缺點**：設備中沒有應用程序或應用程序異常時無法進行 IAP 升級。
{% endnote %}

## 思路（#3）：兩者各取所長

<table>
<thead>
<tr>
<th align="center">具體分工</th>
<th align="center">引導程序</th>
<th align="center">應用程序</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">編程操作</td>
<td align="center">✔</td>
<td align="center"></td>
</tr>
<tr>
<td align="center">通信協議</td>
<td align="center">基礎的通信協議棧</td>
<td align="center">完備的通信協議棧</td>
</tr>
<tr>
<td align="center">文件解壓</td>
<td align="center"></td>
<td align="center">✔</td>
</tr>
<tr>
<td align="center">差分還原</td>
<td align="center"></td>
<td align="center">✔</td>
</tr>
</tbody>
</table>

{% note success no-icon %}
**特點**：在引導程序中集成基礎的通信協議棧，代碼量能接受，應用程序異常時也能在線升級。
{% endnote %}

{% note success no-icon %}
**特點**：在應用程序中集成完整的通信協議棧、文件解壓、差分還原等功能，功能完備。
{% endnote %}

## 方案（#0）

<table>
<thead>
<tr>
<th align="center">內部flash存儲空間劃分</th>
<th align="center">內部flash存儲空間細分</th>
</tr>
</thead>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">引導程序存儲區<br>bootloader</td>
    <td align="center">中斷向量表</td>
</tr>
<tr>
    <td align="center">引導程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center">參數數據存儲區</td>
    <td align="center">掉電不丟失的系統參數</td>
</tr>
</tbody>
</table>

設備收到升級指令後，重啓進入或跳轉進入引導程序。進入引導程序後首先擦除應用程序存儲區，然後等待接收新版應用程序（直接寫入到升級文件存儲區），等接收完畢且校驗無誤後跳轉至應用程序，至此升級完成。

## 方案（#1）

<table>
<thead>
<tr>
<th align="center">內部flash存儲空間劃分</th>
<th align="center">內部flash存儲空間細分</th>
</tr>
</thead>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">引導程序存儲區<br>bootloader</td>
    <td align="center">中斷向量表</td>
</tr>
<tr>
    <td align="center">引導程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">升級數據存儲區</td>
    <td align="center">解壓後的新版程序</td>
</tr>
<tr>
    <td align="center">接收到的壓縮文件</td>
</tr>
<!--  -->
<tr>
    <td align="center">參數數據存儲區</td>
    <td align="center">掉電不丟失的系統參數</td>
</tr>
</tbody>
</table>

或

<table>
<thead>
<tr>
<th align="center">內部flash存儲空間劃分</th>
<th align="center">內部flash存儲空間細分</th>
</tr>
</thead>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">引導程序存儲區<br>bootloader</td>
    <td align="center">中斷向量表</td>
</tr>
<tr>
    <td align="center">引導程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center">參數數據存儲區</td>
    <td align="center">掉電不丟失的系統參數</td>
</tr>
</tbody>
<thead>
<tr>
<th align="center">外部flash存儲空間劃分</th>
<th align="center">外部flash存儲空間細分</th>
</tr>
</thead>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">升級數據存儲區</td>
    <td align="center">解壓後的新版程序</td>
</tr>
<tr>
    <td align="center">接收到的壓縮文件</td>
</tr>
</tbody>
</table>

### 思路（#1）

設備收到升級指令後，重啓進入或跳轉進入引導程序。進入引導程序後首先擦除升級文件存儲區，然後等待接收新版應用程序（暫時存放至升級文件存儲區），等接收完畢且校驗無誤後，擦除舊版應用程序，然後將升級文件存儲區中的新版應用程序拷貝/解壓/差分還原至應用程序存儲區，最後跳轉至應用程序，至此升級完成。

### 思路（#2）

設備收到升級指令後，首先擦除升級文件存儲區，然後等待接收新版應用程序（暫時存放至升級文件存儲區），等接收完畢且校驗無誤後，將升級文件存儲區中的新版應用程序拷貝/解壓/差分還原至新版程序存儲區，重啓進入或跳轉進入引導程序。進入引導程序後對新版程序進行二次校驗，校驗通過後擦除舊版應用程序，然後將新版程序存儲區中的新版應用程序拷貝至應用程序存儲區，最後跳轉至應用程序，至此升級完成。

### 思路（#3）

設備收到升級指令後，首先擦除升級文件存儲區，然後等待接收新版應用程序（暫時存放至升級文件存儲區），等接收完畢且校驗無誤後，將升級文件存儲區中的新版應用程序拷貝/解壓/差分還原至新版程序存儲區，重啓進入或跳轉進入引導程序。進入引導程序後對新版程序進行二次校驗，校驗通過後擦除舊版應用程序，然後將新版程序存儲區中的新版應用程序拷貝至應用程序存儲區，最後跳轉至應用程序，至此升級完成。

抹除應用程序有效標識後，重啓進入或跳轉進入引導程序。進入引導程序後等待通信，若收到升級指令，首先擦除升級文件存儲區，然後等待接收新版應用程序（暫時存放至升級文件存儲區），等接收完畢且校驗無誤後，擦除舊版應用程序，然後將升級文件存儲區中的新版應用程序拷貝（不支持解壓和差分還原）至應用程序存儲區，最後跳轉至應用程序，至此升級完成。

## 方案（#2）

<table>
<thead>
<tr>
<th align="center">內部flash存儲空間劃分</th>
<th align="center">內部flash存儲空間細分</th>
</tr>
</thead>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">引導程序存儲區<br>bootloader</td>
    <td align="center">中斷向量表</td>
</tr>
<tr>
    <td align="center">引導程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區<br>（1）</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區<br>（2）</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center">參數數據存儲區</td>
    <td align="center">掉電不丟失的系統參數</td>
</tr>
</tbody>
</table>

### 思路（#1）

設備收到升級指令後，重啓進入或跳轉進入引導程序。進入引導程序後首先擦除備份應用存儲區，然後等待接收新版應用程序（直接寫入到備份應用存儲區），等接收完畢且校驗無誤後，翻轉APP1與APP2的有效標識，並根據標識跳轉至正確的應用程序，至此升級完成。

### 思路（#2）

設備收到升級指令後，首先擦除備份應用存儲區，然後等待接收新版應用程序（直接寫入到備份應用存儲區），等接收完畢且校驗無誤後，翻轉APP1與APP2的有效標識，重啓進入或跳轉進入引導程序，在引導程序中根據標識跳轉至正確的應用程序，至此升級完成。

### 思路（#3）

設備收到升級指令後，首先擦除備份應用存儲區，然後等待接收新版應用程序（直接寫入到備份應用存儲區），等接收完畢且校驗無誤後，翻轉APP1與APP2的有效標識，重啓進入或跳轉進入引導程序，在引導程序中根據標識跳轉至正確的應用程序，至此升級完成。

抹除應用程序有效標識後，重啓進入或跳轉進入引導程序。進入引導程序後等待通信，若收到升級指令，首先擦除備份應用存儲區，然後等待接收新版應用程序（直接寫入到備份應用存儲區），等接收完畢且校驗無誤後，翻轉APP1與APP2的有效標識，並根據標識跳轉至正確的應用程序，至此升級完成。

## 方案（#3）

<table>
<thead>
<tr>
<th align="center">內部flash存儲空間劃分</th>
<th align="center">內部flash存儲空間細分</th>
</tr>
</thead>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">引導程序存儲區<br>bootloader</td>
    <td align="center">中斷向量表</td>
</tr>
<tr>
    <td align="center">引導程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區<br>（1）</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區<br>（2）</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">升級數據存儲區</td>
    <td align="center">解壓後的新版程序</td>
</tr>
<tr>
    <td align="center">接收到的壓縮文件</td>
</tr>
<!--  -->
<tr>
    <td align="center">參數數據存儲區</td>
    <td align="center">掉電不丟失的系統參數</td>
</tr>
</tbody>
</table>

或

<table>
<thead>
<tr>
<th align="center">內部flash存儲空間劃分</th>
<th align="center">內部flash存儲空間細分</th>
</tr>
</thead>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">引導程序存儲區<br>bootloader</td>
    <td align="center">中斷向量表</td>
</tr>
<tr>
    <td align="center">引導程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區<br>（1）</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center" rowspan="2">應用程序存儲區<br>（2）</td>
    <td align="center">重定向的中斷向量表</td>
</tr>
<tr>
    <td align="center">應用程序</td>
</tr>
<!--  -->
<tr>
    <td align="center">參數數據存儲區</td>
    <td align="center">掉電不丟失的系統參數</td>
</tr>
</tbody>
<thead>
<tr>
<th align="center">外部flash存儲空間劃分</th>
<th align="center">外部flash存儲空間細分</th>
</tr>
</thead>
<tbody>
<!--  -->
<tr>
    <td align="center" rowspan="2">升級數據存儲區</td>
    <td align="center">解壓後的新版程序</td>
</tr>
<tr>
    <td align="center">接收到的壓縮文件</td>
</tr>
</tbody>
</table>

### 思路（#1）

設備收到升級指令後，重啓進入或跳轉進入引導程序。進入引導程序後首先擦除升級文件存儲區，然後等待接收新版應用程序（暫時存放至升級文件存儲區），等接收完畢且校驗無誤後，擦除備份應用存儲區，然後將升級文件存儲區中的新版應用程序拷貝/解壓/差分還原至備份應用存儲區，最後翻轉APP1與APP2的有效標識，並根據標識跳轉至正確的應用程序，至此升級完成。

### 思路（#2）

設備收到升級指令後，首先擦除升級文件存儲區，然後等待接收新版應用程序（暫時存放至升級文件存儲區），等接收完畢且校驗無誤後，擦除備份應用存儲區，然後將升級文件存儲區中的新版應用程序拷貝/解壓/差分還原至備份應用存儲區，翻轉APP1與APP2的有效標識，重啓進入或跳轉進入引導程序，在引導程序中根據標識跳轉至正確的應用程序，至此升級完成。

### 思路（#3）

設備收到升級指令後，首先擦除升級文件存儲區，然後等待接收新版應用程序（暫時存放至升級文件存儲區），等接收完畢且校驗無誤後，擦除備份應用存儲區，然後將升級文件存儲區中的新版應用程序拷貝/解壓/差分還原至備份應用存儲區，翻轉APP1與APP2的有效標識，重啓進入或跳轉進入引導程序，在引導程序中根據標識跳轉至正確的應用程序，至此升級完成。

抹除應用程序有效標識後，重啓進入或跳轉進入引導程序。進入引導程序後等待通信，若收到升級指令，首先擦除升級文件存儲區，然後等待接收新版應用程序（暫時存放至升級文件存儲區），等接收完畢且校驗無誤後，擦除備份應用存儲區，然後將升級文件存儲區中的新版應用程序拷貝（不支持解壓和差分還原）至備份應用存儲區，最後翻轉APP1與APP2的有效標識，並根據標識跳轉至正確的應用程序，至此升級完成。
