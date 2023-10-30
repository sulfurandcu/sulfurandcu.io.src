---
title: 集成開發環境－GCC.ARM（#03）程序燒錄
id: clo2c1l6600ca1wrqbvuabt0b
date: 2023-06-15 00:00:03
tags: [嵌入式軟件開發, 集成開發環境, IDE]
categories: [開發筆記]
---

編程/下載/燒錄的方式有多種，本文重點介紹以下兩種燒錄方式：

- JLink
- OpenOCD + JLink 仿真器

其中 OpenOCD 可以搭配多種仿真器使用，這裏以 JLink 仿真器爲例進行說明。

<!-- more -->

## JLink

1\. 確認是否購買了 JLink 仿真器並且已經安裝了 JLink 程序。

2\. 在 makefile 中添加 write 選項：

![](make.write.JLinkLoad.png)

3\. 在工程目錄下新建 JLinkLoad.txt 文件並寫入以下內容：

![](make.write.JLinkLoad.code.png)

4\. 執行 mingw32-make write 指令：

![](make.write.JLinkLoad.succ.png)

{% note danger no-icon %}
再次提醒：需要使用 JLink 仿真器以及**默認驅動**
{% endnote %}

{% note danger no-icon %}
如果你的電腦中有不止一個 “JLink” 程序，確保在 makefile 中通過絕對路徑使用 JLink 命令。
{% endnote %}

下圖是我安裝了 JavaJDK 後系統中存在的 jlink 程序，只不過此 “jlink” 非彼 “JLink”！

![](make.write.JLink.JavaJDK.png)

## OpenOCD

1\. 確認是否購買了 JLink 仿真器並且已經安裝了 OpenOCD 程序。

2\. 在 makefile 中添加 write 選項：

![](make.write.OpenOCD.JLink.png)

3\. 在工程目錄下新建 openocd.cfg 文件並寫入以下內容：

![](make.write.OpenOCD.JLink.code.png)

> https://openocd.org/doc-release/html/OpenOCD-Project-Setup.html#Configuration-Basics

4\. 將 jlink.cfg 和 stm32f1x.cfg 拷貝至工程目錄下。

5\. 使用 zadig 或 USBDriverTool 將仿真器的驅動從 WinUSB 改爲 libusb 驅動。

6\. 執行 mingw32-make write 指令：

![](make.write.OpenOCD.JLink.succ.png)

## Q&A

### 問題一：未找到 JLink 仿真器

![](QA1.1.png)

OpenOCD 對仿真器的支持是通過底層的訪問控制實現的，不依賴仿真器自身的驅動，但是需要 libusb 驅動，因此我們需要使用 zadig 或 USBDriverTool 等工具將仿真器的默認驅動改爲 libusb 驅動。

需要注意的是，將驅動改成 libusb 之後，原有的調試軟件例如 JLink/Keil 將無法再識別到仿真器。

如果你還想繼續使用這些調試軟件，則需要卸載掉當前的驅動程序並插拔一下仿真器：

![](QA1.2.png)

### 問題二：SWD & JTAG

![](QA2.1.png)

OpenOCD 提供的 jlink.cfg 腳本默認使用 JTAG 模式，而我們實際使用的是 SWD 模式。

解決方法：在 openocd.cfg 文件中添加一條語句：

![](QA2.2.png)
