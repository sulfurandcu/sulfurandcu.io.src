---
title: 集成開發環境－GCC.ARM（#00）目錄索引
id: clo2c1l6m00de1wrqg1jcfbqd
date: 2023-06-15 00:00:00
tags: [嵌入式軟件開發, 集成開發環境, IDE]
categories: [開發筆記]
---

---

[集成開發環境－GCC.ARM（#01）環境搭建](/sulfurandcu.io/clo2c1l6o00dh1wrqd2o379jc.html)
[集成開發環境－GCC.ARM（#02）代碼編譯](/sulfurandcu.io/clo2c1l6400c71wrq3816hypq.html)
[集成開發環境－GCC.ARM（#03）程序燒錄](/sulfurandcu.io/clo2c1l6600ca1wrqbvuabt0b.html)
[集成開發環境－GCC.ARM（#04）快捷任務](/sulfurandcu.io/clo2c1l6700cd1wrqgjn53mgz.html)
[集成開發環境－GCC.ARM（#05）程序調試](/sulfurandcu.io/clo2c1l6600cb1wrqewhnb8ey.html)
[集成開發環境－DBG](/sulfurandcu.io/clockxig7001dj4rqc2n6542r.html)

---

傳統的集成開發環境（MDK、IAR）通常會提供包括編輯、編譯、燒錄、調試在內的一整套工具，開發者無需配置，簡單易用，但是 license 不是一般的貴。

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

> 倘若宿主機使用 Windows 操作系統並且購買了 JLinkDebugger 仿真器，則推薦使用 JLink 方案！

<!-- more -->

## 基本概念

一個基本的開發環境包含以下四個部分：

1. 編輯功能（vscode）
2. 編譯功能（arm-none-eabi-xxx）
3. 燒錄功能（OpenOCD/JLink）
4. 調試功能（OpenOCD/JLinkGDBServerCL + Cortex-Debug + arm-none-eabi-gdb）

- **vscode**
文本編輯器，其實是一個僞裝成文本編輯器的開發框架。

- **arm-none-eabi-xxx**
交叉編譯器，可以編譯出在 Cortex-R&M 平臺上運行的可執行程序。

- **OpenOCD/JLink**
程序燒錄器，負責將編譯好的程序燒錄到目標芯片中。

- **arm-none-eabi-gdb**
命令調試器，支持通過命令行的方式進行調試。

- **Cortex-Debug**
圖形調試器，提供一套圖形調試界面，需要與命令調試器搭配使用。

- **OpenOCD/JLinkGDBServerCL**
調試服務器，負責協助調試器識別並管理各種仿真設備和目標芯片。

- **makefile & task.json**
自動化工具，用來實現編譯和燒錄的自動化。

## 參考鏈接

[OpenOCD添加第三方設備支持:HT32F52352 Cortex-M0+](https://blog.csdn.net/weixin_41328027/article/details/122969985)

[用VS Code開發STM32（一）](https://zhuanlan.zhihu.com/p/61519415)
[用VS Code開發STM32（二）](https://zhuanlan.zhihu.com/p/61538230)
[用VS Code開發STM32（三）](https://zhuanlan.zhihu.com/p/61541590)
[用VS Code開發STM32（四）](https://zhuanlan.zhihu.com/p/163771273)

[矜辰所致 OpenOCD 不同仿真器使用操作總結記錄](https://blog.csdn.net/weixin_42328389/article/details/128511370)
[矜辰所致 在window下使用 VScode 搭建 ARM 開發環境—— 詳細版](https://blog.csdn.net/weixin_42328389/article/details/119823834)
[VsCode+OpenOCD 開發stm32系列](https://blog.csdn.net/pyt1234567890/article/details/122522700)
[vscode-armgcc-openocd搭建STM32開發調試環境](https://blog.csdn.net/qq_49295302/article/details/124628016)
[用 vscode 搭建stm32 開發環境（詳細）](https://blog.csdn.net/qq_45701067/article/details/121652228)
[VSCode搭建STM32開發調試環境（轉）](http://eda88.com/essay/firmware/vscode%E6%90%AD%E5%BB%BAstm32%E5%BC%80%E5%8F%91%E8%B0%83%E8%AF%95%E7%8E%AF%E5%A2%83%EF%BC%88%E8%BD%AC%EF%BC%89/)
[VSCode搭建STM32開發環境（極簡自我搭建&懶人直接使用插件）](https://blog.csdn.net/ben_black/article/details/109906781)
[Cortex-debug 調試器使用介紹](https://blog.csdn.net/qq_40833810/article/details/106713462)
[Visual Studio Code for C/C++ with ARM Cortex-M: Part 1 ](https://mcuoneclipse.com/2021/05/01/visual-studio-code-for-c-c-with-arm-cortex-m-part-1/)
