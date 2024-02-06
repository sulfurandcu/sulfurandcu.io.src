---
title: 嵌入式 IAP 升级功能（#01）基础概念
id: clnyhr2n2004x10rq71zl3lqj
date: 2023-10-01 00:00:01
tags: [嵌入式软件开发, 在线升级]
categories: [开发笔记]
---

<center>传统编程方式</center>

{% mermaid flowchart LR %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
A(先取下芯片)--->B(再烧录程序)--->C(后装回板卡)
{% endmermaid %}

<center>现代编程方式</center>

{% mermaid flowchart LR %}
%%{init: { "flowchart": { "curve": "basis" } } }%%
A("在电路编程<br>(ＩＣＰ)")--->B("在系统编程<br>(ＩＳＰ)")--->C("在应用编程<br>(ＩＡＰ)")
{% endmermaid %}

<!-- more -->

## 传统编程方式

传统编程方式是先将程序烧录至主控芯片中再焊接到电路板上。

**开发阶段**

- ➀ 从电路板上取下芯片
- ➁ 使用烧录器烧写程序
- ➂ 将芯片装回至电路板

**量产阶段**

- ➀ 从 tray 盘取出芯片
- ➁ 使用烧录器烧写程序
- ➂ 将芯片放回 tray 盘

**维护阶段**

- ➀ 从电路板上拆下芯片
- ➁ 使用烧录器烧写程序
- ➂ 将芯片焊回至电路板

## 现代编程方式

现代编程方式可以直接进行板上烧录，不用再取下芯片放到专用的烧录器上烧录，极大地提高了开发、生产以及维护效率。

现代编程方式又可分为：

- 在电路编程 ICP (Circuit)
- 在系统编程 ISP (System)
- 在应用编程 IAP (Application)

编程方式                                | 在电路编程                            | 在系统编程                                                                    | 在应用编程
:-:                                     | :-:                                   | :-:                                                                           | :-:
核心思想                                | 借助外部烧录器<br>通过JTAG/SWD接口<br>实现在电路编程 | 借助芯片内部<br>固化的引导程序和BOOT引脚<br>以及片上接口<br>实现在系统编程 | 借助用户自己<br>编写的引导程序、应用程序<br>以及片上接口、板上接口<br>实现在应用编程
引导程序                                | 不需要                                | 需要芯片厂家编写<br>并固化到某一地址空间                                      | 需要用户自己编写<br>并烧录至内部flash存储器
进入方式                                | 随时待命                              | 需要更改BOOT引脚的电平<br>然后硬件复位<br>进入内部固化的引导程序              | 随时待命
配套软件                                | 烧录软件                              | 芯片厂家提供的<br>上位机ISP编程软件                                           | 用户自己开发的数据传输软件
通信接口                                | JTAG/SWD                              | 取决于芯片中固化的引导程序<br>URT/SPI/IIC/CAN/USB                             | 理论上可以支持任意接口<br>URT/SPI/IIC<br>485/CAN/USB<br>WiFi/BLE/IrDA<br>PLC/ETH/4G/5G/NBIoT
程序升级<br>是否需要<br>拆装芯片        | 不需要<br>拆装芯片                    | 不需要<br>拆装芯片                                                            | 不需要<br>拆装芯片
程序升级<br>是否需要<br>拆装外壳        | 需要<br>拆开设备外壳                  | 通信接口完备的情况下<br>不需要<br>拆开设备外壳<br>485/CAN/USB                 | 通信接口完备的情况下<br>不需要<br>拆开设备外壳<br>485/CAN/USB/WiFi/BLE/IrDA
程序升级<br>是否需要<br>前往现场        | 需要<br>前往设备安装现场              | 需要<br>前往设备安装现场                                                      | 远程通信功能完备的情况下<br>不需要<br>前往设备安装现场<br>PLC/ETH/4G/5G/NBIoT

{% note info no-icon %}
ICP 主要是在开发阶段使用，其烧录速度是 ISP 和 IAP 所无法比拟的。
{% endnote %}

{% note info no-icon %}
IAP 与 ISP 类似，都有 bootloader 引导程序，因此无需使用烧录器。二者的区别在于，ISP 的引导程序由芯片厂家编写，比较简单，无法实现用户的定制化需求；而 IAP 的引导程序是由用户自己实现，可以根据需求自行修改。另外 ISP 进入 boot 程序的方式是通过更改 BOOT 引脚的电平；而 IAP 则是从用户程序中通过软件复位或者跳转的方式直接进入 bootloader 程序，因此相较于 ISP 来说会更加灵活。
{% endnote %}

{% note info no-icon %}
通过 WiFi/BLE/4G/5G/NBIoT 等无线通信技术实现 IAP 功能的方案也被称作 OTA 空中下载技术。
{% endnote %}

BOOT1 | BOOT0 | BOOT MODE
:-:   | :-:   | :-:
X     | 0     | boot from 0x08000000 : main memory
0     | 1     | boot from 0x1FFF0000 : boot memory
1     | 1     | boot from 0x20000000 : sram memory
