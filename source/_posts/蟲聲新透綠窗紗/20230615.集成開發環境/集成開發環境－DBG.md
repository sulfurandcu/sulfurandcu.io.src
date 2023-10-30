---
title: 集成開發環境－DBG
id: clockxig7001dj4rqc2n6542r
date: 2023-07-04 17:23:25
tags: [嵌入式軟件開發, 集成開發環境, IDE]
categories: [開發筆記]
---

![](DebugAdapterProtocol(DAP).png)

<!-- more -->

## 專用的調試模塊

常見的 IDE 內部都集成了一個專用的 GUI 調試器，且不能拎出來單獨使用。

- ADS
- IAR
- MDK
- Visual Studio

## 獨立的調試工具

當然也有一些可以獨立使用的調試器，例如：

- CLI: GDB, LLDB
- GUI: x64dbg, WinDBG, OllyDBG

## 通用的調試協議（DebugAdapterProtocol）

![](Arch.DebugAdapterProtocol.png)

不論是專用的調試模塊還是獨立的調試工具，如果想支持調試多種語言，就必須要爲每一種語言開發一套對應的調試程序，並且每個工具廠商都要獨自去完成這些工作。爲了減少不必要的重複勞動，微軟制定了一套通用的調試協議，藉助該協議各工具廠商只需要開發一套調試程序，向下再借助各種調試適配工具即可具備調試所有語言的能力。

![](DebugAdapterProtocol(DAP).png)
<center><a href="https://microsoft.github.io/debug-adapter-protocol/">Debug Adapter Protocol (DAP)</a></center><br>

目前實現該調試協議的開發工具有（常用的）：

- VSC
- VS
- vim
- emacs
- EclipseIDE

btw, 微軟還制定了一套通用的語言服務器協議 [Language Server Protocol (LSP)](https://microsoft.github.io/language-server-protocol/)

![](LanguageServerProtocol(LSP).png)
<center><a href="https://microsoft.github.io/language-server-protocol/">Language Server Protocol (LSP)</a></center>

## 調試器適配工具（DebugAdapter）

![](Arch.DebugAdapter.png)

調試適配器是對各類調試器的封裝，遵循 DAP 協議對上提供統一的接口，以簡化上層開發工具。常用的調試適配器有：

- [cpptools (C/C++ Debug Adapter)](https://github.com/Microsoft/vscode-cpptools)
- [cortex-debug (Embedded C/C++ Debug Adapter)](https://github.com/Marus/cortex-debug)

## 調試器軟件本體（Debugger）

- [GDB: The GNU Project Debugger](https://sourceware.org/gdb/)
  - [↑ GDB/MI](https://sourceware.org/gdb/onlinedocs/gdb/Remote-Protocol.html)
  - [↓ GDB Remote Serial Protocol](https://sourceware.org/gdb/onlinedocs/gdb/GDB_002fMI.html)
- [arm-none-eabi-gdb: GNU Arm Embedded GDB](https://developer.arm.com/downloads/-/gnu-rm)

![](Arch.Debugger.png)

## 調試器服務程序（DebugServer）

- OpenOCD
- PyOCD
- JLinkGDBServer
- ……

![](Arch.DebugServer.png)

## 仿真器驅動程序（DongleDriver）

- SEGGER JLink USB Driver
- SEGGER WinUSB USB Device Driver

## 仿真器設備本體（Dongle）

- CMSIS-DAP
- SEGGER JLink

![](Arch.Dongle.png)

## 仿真器傳輸協議（DongleTransportProtocol）

- JTAG https://www.corelis.com/education/tutorials/jtag-tutorial/
- SWD

## 目標板目標芯片（TargetBoard）

- STM32F103CB
- STM32F407VE

![](Arch.Target.png)

## 本地與遠程調試

遠程調試方案也有很多，這裏只對以下幾種方式作一簡要介紹：

- OpenOCD
- VSCode + JLinkGDBServer
- JLink + JLinkRemoteServer
- KeilMDK + JLinkRemoteServer

### OpenOCD

略.

### VSCode + JLinkGDBServer

1\. 在服務主機上配置開啓 JLink 調試服務器（該服務器會監聽 2331 端口）

![](JLinkGDBServer.LAN.Server.0.png)

{% note danger no-icon %}
不要勾選 Localhost Only 選項！
{% endnote %}

2\. 等待連接

![](JLinkGDBServer.LAN.Server.1.png)

3\. 在本地主機上配置 launch.json 文件並啓動調試

```
{
    "name": "Debug@RemoteServer(GDBServer/JLinkGDBServer)",
    "type": "cortex-debug",
    "servertype": "external",
    "request": "attach",
    "cwd":"${workspaceRoot}",
    "executable": "./build/main.elf",

    "gdbTarget": "192.168.1.1:2331",
},
```

[cortex-debug-issues#244 : remote debugging](https://github.com/Marus/cortex-debug/issues/244)
[cortex-debug-wiki : external gdb server configuration](https://github.com/Marus/cortex-debug/wiki/External-gdb-server-configuration)

{% note info no-icon %}
點擊啓動調試後 cortex-debug 便會幫助我們通過本地 xGDB 客戶端連接遠程 GDB 服務器。
{% endnote %}

4\. 建立連接

![](JLinkGDBServer.LAN.Server.2.png)

5\. 遠程調試

```
此處省略一張在 vscode 中調試的圖片
```

6\. 斷開連接

![](JLinkGDBServer.LAN.Server.3.png)

### JLink + JLinkRemoteServer

#### 內網連接

1\. 在服務主機上配置開啓 JLink 遠程服務器

![](JLinkRMTServer.LAN.Server.0.png)

2\. 等待連接

![](JLinkRMTServer.LAN.Server.1.png)

3\. 在本地主機上配置連接 JLink 遠程服務器

![](JLinkRMTServer.LAN.Client.0.png)

4\. 建立連接

![](JLinkRMTServer.LAN.Server.2.png)

5\. 遠程調試

![](JLinkRMTServer.LAN.Client.1.png)

6\. 斷開連接

![](JLinkRMTServer.LAN.Server.3.png)

#### 隧道連接

1\. 在服務主機上配置開啓 JLink 遠程服務器（隧道方式）

![](JLinkRMTServer.Tunnel.Server.0.png)

2\. 等待連接

![](JLinkRMTServer.Tunnel.Server.1.png)

3\. 在本地主機上配置連接 JLink 遠程服務器（隧道方式）

![](JLinkRMTServer.Tunnel.Client.0.png)

4\. 建立連接

![](JLinkRMTServer.Tunnel.Server.2.png)

5\. 遠程調試

![](JLinkRMTServer.Tunnel.Client.1.png)

6\. 斷開連接

![](JLinkRMTServer.Tunnel.Server.3.png)

### KeilMDK + JLinkRemoteServer

#### 內網連接

1\. 在服務主機上配置開啓 JLink 遠程服務器

![](JLinkRMTServer.LAN.Server.0.png)

2\. 等待連接

![](JLinkRMTServer.LAN.Server.1.png)

3\. 在本地主機上配置連接 JLink 遠程服務器

![](JLinkRMTServer.LAN.Client.0.Keil.MDK.png)

4\. 建立連接

![](JLinkRMTServer.LAN.Server.2.png)

5\. 遠程調試

```
此處省略一張在 Keil MDK 中調試的圖片
```

6\. 斷開連接

![](JLinkRMTServer.LAN.Server.3.png)
