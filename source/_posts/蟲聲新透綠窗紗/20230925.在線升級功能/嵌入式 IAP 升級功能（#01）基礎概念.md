---
title: 嵌入式 IAP 升級功能（#01）基礎概念
date: 2023-10-01 00:00:01
tags: [嵌入式軟件開發, 在線升級]
categories: [開發筆記]
---

<center>傳統編程方式</center>

{% mermaid flowchart LR %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
A(先取下芯片)--->B(再燒錄程序)--->C(後裝回板卡)
{% endmermaid %}

<center>現代編程方式</center>

{% mermaid flowchart LR %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
A("在電路編程<br>(ＩＣＰ)")--->B("在系統編程<br>(ＩＳＰ)")--->C("在應用編程<br>(ＩＡＰ)")
{% endmermaid %}

<!-- more -->

## 傳統編程方式

傳統編程方式是先將程序燒錄至主控芯片中再焊接到電路板上。

**開發階段**

- ➀ 從電路板上取下芯片
- ➁ 使用燒錄器燒寫程序
- ➂ 將芯片裝回至電路板

**量產階段**

- ➀ 從 tray 盤取出芯片
- ➁ 使用燒錄器燒寫程序
- ➂ 將芯片放回 tray 盤

**維護階段**

- ➀ 從電路板上拆下芯片
- ➁ 使用燒錄器燒寫程序
- ➂ 將芯片焊回至電路板

## 現代編程方式

現代編程方式可以直接進行板上燒錄，不用再取下芯片放到專用的燒錄器上燒錄，極大地提高了開發、生產以及維護效率。

現代編程方式又可分爲：

- 在電路編程 ICP (Circuit)
- 在系統編程 ISP (System)
- 在應用編程 IAP (Application)

編程方式                                | 在電路編程                            | 在系統編程                                                                    | 在應用編程
:-:                                     | :-:                                   | :-:                                                                           | :-:
核心思想                                | 藉助外部燒錄器<br>通過JTAG/SWD接口<br>實現在電路編程 | 藉助芯片內部<br>固化的引導程序和BOOT引腳<br>以及片上接口<br>實現在系統編程 | 藉助用戶自己<br>編寫的引導程序、應用程序<br>以及片上接口、板上接口<br>實現在應用編程
引導程序                                | 不需要                                | 需要芯片廠家編寫<br>並固化到某一地址空間                                      | 需要用戶自己編寫<br>並燒錄至內部flash存儲器
進入方式                                | 隨時待命                              | 需要更改BOOT引腳的電平<br>然後硬件復位<br>進入內部固化的引導程序              | 隨時待命
配套軟件                                | 燒錄軟件                              | 芯片廠家提供的<br>上位機ISP編程軟件                                           | 用戶自己開發的數據傳輸軟件
通信接口                                | JTAG/SWD                              | 取決於芯片中固化的引導程序<br>URT/SPI/IIC/CAN/USB                             | 理論上可以支持任意接口<br>URT/SPI/IIC<br>485/CAN/USB<br>WiFi/BLE/IrDA<br>PLC/ETH/4G/5G/NBIoT
程序升級<br>是否需要<br>拆裝芯片        | 不需要<br>拆裝芯片                    | 不需要<br>拆裝芯片                                                            | 不需要<br>拆裝芯片
程序升級<br>是否需要<br>拆裝外殼        | 需要<br>拆開設備外殼                  | 通信接口完備的情況下<br>不需要<br>拆開設備外殼<br>485/CAN/USB                 | 通信接口完備的情況下<br>不需要<br>拆開設備外殼<br>485/CAN/USB/WiFi/BLE/IrDA
程序升級<br>是否需要<br>前往現場        | 需要<br>前往設備安裝現場              | 需要<br>前往設備安裝現場                                                      | 遠程通信功能完備的情況下<br>不需要<br>前往設備安裝現場<br>PLC/ETH/4G/5G/NBIoT

{% note info no-icon %}
ICP 主要是在開發階段使用，其燒錄速度是 ISP 和 IAP 所無法比擬的。
{% endnote %}

{% note info no-icon %}
IAP 與 ISP 類似，都有 bootloader 引導程序，因此無需使用燒錄器。二者的區別在於，ISP 的引導程序由芯片廠家編寫，比較簡單，無法實現用戶的定製化需求；而 IAP 的引導程序是由用戶自己實現，可以根據需求自行修改。另外 ISP 進入 boot 程序的方式是通過更改 BOOT 引腳的電平；而 IAP 則是從用戶程序中通過軟件復位或者跳轉的方式直接進入 bootloader 程序，因此相較於 ISP 來說會更加靈活。
{% endnote %}

{% note info no-icon %}
通過 WiFi/BLE/4G/5G/NBIoT 等無線通信技術實現 IAP 功能的方案也被稱作 OTA 空中下載技術。
{% endnote %}

BOOT1 | BOOT0 | BOOT MODE
:-:   | :-:   | :-:
X     | 0     | boot from 0x08000000 : main memory
0     | 1     | boot from 0x1FFF0000 : boot memory
1     | 1     | boot from 0x20000000 : sram memory
