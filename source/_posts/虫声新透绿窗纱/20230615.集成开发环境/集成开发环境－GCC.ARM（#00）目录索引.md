---
title: 集成开发环境－GCC.ARM（#00）目录索引
id: clo2c1l6m00de1wrqg1jcfbqd
date: 2023-06-15 00:00:00
tags: [嵌入式软件开发, 集成开发环境, IDE]
categories: [开发笔记]
---

---

[集成开发环境－GCC.ARM（#01）环境搭建](/sulfurandcu.io/clo2c1l6o00dh1wrqd2o379jc.html)
[集成开发环境－GCC.ARM（#02）程序构建](/sulfurandcu.io/clo2c1l6400c71wrq3816hypq.html)
[集成开发环境－GCC.ARM（#03）程序烧录](/sulfurandcu.io/clo2c1l6600ca1wrqbvuabt0b.html)
[集成开发环境－GCC.ARM（#04）快捷任务](/sulfurandcu.io/clo2c1l6700cd1wrqgjn53mgz.html)
[集成开发环境－GCC.ARM（#05）程序调试](/sulfurandcu.io/clo2c1l6600cb1wrqewhnb8ey.html)
[集成开发环境－DBG](/sulfurandcu.io/clockxig7001dj4rqc2n6542r.html)

---

传统的集成开发环境（MDK、IAR）通常会提供包括编辑、编译、烧录、调试在内的一整套工具，开发者无需配置，简单易用，但 license 也不是一般的贵。

替代方案：

- **VSC**
  - [Microsoft Embedded Tools](https://devblogs.microsoft.com/cppblog/vscode-embedded-development/)
  - [Cortex Debug](https://github.com/Marus/cortex-debug/wiki)
  - [Embedded IDE](https://em-ide.com/zh-cn/)
  - [vscode for espidf](https://docs.espressif.com/projects/esp-idf/zh_CN/v4.3.1/esp32/index.html)
  - [vscode for essemi](https://www.essemi.com/index/article/plist?cid=141)
- **VS**
  - [Microsoft Embedded Software Development in Visual Studio](https://devblogs.microsoft.com/cppblog/visual-studio-embedded-development/)
  - [VisualGDB by SysPROGS](https://visualgdb.com/)
- **Eclipse**
- **Eclipse Based**
  - [EclipseBased: RT-Thread Studio](https://www.rt-thread.io/studio.html) (RV5 ARM JLink STLink DAP-Link QEMU)
  - [EclipseBased: MounRiver Studio](http://www.mounriver.com/) (RV5 ARM)
  - [EclipseBased: NucleiIDE Studio](https://www.rvmcu.com/nucleistudio.html) (RV5)

<!-- more -->

## 基本概念

1. 编辑（vscode）
2. 编译（arm-none-eabi-xxx）
3. 烧录（JLink）
4. 调试（vscode-debug + cortex-debug + arm-none-eabi-gdb + JLinkGDBServerCL + JLinkDevice）

- **vscode (task.json)**
文本编辑器，其实是一个伪装成文本编辑器的开发框架。

- **arm-none-eabi-xxx**
交叉编译器，可以编译出在 Cortex-R&M 平台上运行的可执行程序。

- **JLink/OpenOCD**
程序烧录器，负责将编译好的程序烧录到目标芯片中。

- **vscode-debug (launch.json)**
图形调试器，内部集成的图形调试组件，提供一套图形调试界面，与调试适配器打交道。

- **cortex-debug**
调试适配器，将图形调试器的操作翻译成命令调试器能够看得懂的命令。

- **arm-none-eabi-gdb**
命令调试器，支持通过命令行的方式进行调试。

- **JLinkGDBServerCL/OpenOCD**
调试服务器，负责协助调试器识别并管理各种仿真设备和目标芯片。

- **JLinkDriver**
仿真器驱动，负责驱动仿真器设备。

- **JLinkDongle**
仿真器设备，通过 JTAG 或 SWD 协议与芯片打交道。

> 倘若宿主机使用 Windows 操作系统并且购买了 JLinkDongle 仿真器，则推荐使用 JLink 方案！

## 参考链接

[OpenOCD添加第三方设备支持:HT32F52352 Cortex-M0+](https://blog.csdn.net/weixin_41328027/article/details/122969985)

[用VS Code开发STM32（一）](https://zhuanlan.zhihu.com/p/61519415)
[用VS Code开发STM32（二）](https://zhuanlan.zhihu.com/p/61538230)
[用VS Code开发STM32（三）](https://zhuanlan.zhihu.com/p/61541590)
[用VS Code开发STM32（四）](https://zhuanlan.zhihu.com/p/163771273)

[矜辰所致 OpenOCD 不同仿真器使用操作总结记录](https://blog.csdn.net/weixin_42328389/article/details/128511370)
[矜辰所致 在window下使用 VScode 搭建 ARM 开发环境—— 详细版](https://blog.csdn.net/weixin_42328389/article/details/119823834)
[VsCode+OpenOCD 开发stm32系列](https://blog.csdn.net/pyt1234567890/article/details/122522700)
[vscode-armgcc-openocd搭建STM32开发调试环境](https://blog.csdn.net/qq_49295302/article/details/124628016)
[用 vscode 搭建stm32 开发环境（详细）](https://blog.csdn.net/qq_45701067/article/details/121652228)
[VSCode搭建STM32开发调试环境（转）](http://eda88.com/essay/firmware/vscode%E6%90%AD%E5%BB%BAstm32%E5%BC%80%E5%8F%91%E8%B0%83%E8%AF%95%E7%8E%AF%E5%A2%83%EF%BC%88%E8%BD%AC%EF%BC%89/)
[VSCode搭建STM32开发环境（极简自我搭建&懒人直接使用插件）](https://blog.csdn.net/ben_black/article/details/109906781)
[Cortex-debug 调试器使用介绍](https://blog.csdn.net/qq_40833810/article/details/106713462)
[Visual Studio Code for C/C++ with ARM Cortex-M: Part 1 ](https://mcuoneclipse.com/2021/05/01/visual-studio-code-for-c-c-with-arm-cortex-m-part-1/)
