---
title: 集成开发环境－DBG
id: clockxig7001dj4rqc2n6542r
date: 2023-07-04 17:23:25
tags: [嵌入式软件开发, 集成开发环境, IDE]
categories: [开发笔记]
---

![](DebugAdapterProtocol(DAP).png)

<!-- more -->

## 专用的调试模块

常见的 IDE 内部都集成了一个专用的 GUI 调试器，且不能拎出来单独使用。

- ADS
- IAR
- MDK
- Visual Studio

## 独立的调试工具

当然也有一些可以独立使用的调试器，例如：

- CLI: GDB, LLDB
- GUI: x64dbg, WinDBG, OllyDBG

## 图形调试器

## 适配器协议（DebugAdapterProtocol）

![](Arch.DebugAdapterProtocol.png)

不论是专用的调试模块还是独立的调试工具，如果想支持调试多种语言，就必须要为每一种语言开发一套对应的调试程序，并且每个工具厂商都要独自去完成这些工作。为了减少不必要的重复劳动，微软制定了一套通用的调试协议，借助该协议各工具厂商只需要开发一套调试程序，向下再借助各种调试适配工具即可具备调试所有语言的能力。

![](DebugAdapterProtocol(DAP).png)
<center><a href="https://microsoft.github.io/debug-adapter-protocol/">Debug Adapter Protocol (DAP)</a></center><br>

目前实现该调试协议的开发工具有（常用的）：

- VSC
- VS
- vim
- emacs
- EclipseIDE

btw, 微软还制定了一套通用的语言服务器协议 [Language Server Protocol (LSP)](https://microsoft.github.io/language-server-protocol/)

![](LanguageServerProtocol(LSP).png)
<center><a href="https://microsoft.github.io/language-server-protocol/">Language Server Protocol (LSP)</a></center>

## 调试适配器（DebugAdapter）

![](Arch.DebugAdapter.png)

调试适配器是对各类调试器的封装，遵循 DAP 协议对上提供统一的接口，以简化上层开发工具。常用的调试适配器有：

- [cpptools (C/C++ Debug Adapter)](https://github.com/Microsoft/vscode-cpptools)
- [cortex-debug (Embedded C/C++ Debug Adapter)](https://github.com/Marus/cortex-debug)

## 命令调试器（Debugger）

- [GDB: The GNU Project Debugger](https://sourceware.org/gdb/)
  - [↑ GDB/MI](https://sourceware.org/gdb/onlinedocs/gdb/Remote-Protocol.html)
  - [↓ GDB Remote Serial Protocol](https://sourceware.org/gdb/onlinedocs/gdb/GDB_002fMI.html)
- [arm-none-eabi-gdb: GNU Arm Embedded GDB](https://developer.arm.com/downloads/-/gnu-rm)

![](Arch.Debugger.png)

## 调试服务器（DebugServer）

- OpenOCD
- PyOCD
- JLinkGDBServer
- ……

![](Arch.DebugServer.png)

## 仿真器驱动（DongleDriver）

- SEGGER JLink USB Driver
- SEGGER WinUSB USB Device Driver

## 仿真器设备（Dongle）

- CMSIS-DAP
- SEGGER JLink

![](Arch.Dongle.png)

## 仿真器协议（DongleTransportProtocol）

- JTAG https://www.corelis.com/education/tutorials/jtag-tutorial/
- SWD

## 目标板芯片（TargetBoard）

- STM32F103CB
- STM32F407VE

![](Arch.Target.png)

## 本地与远程调试

远程调试方案也有很多，这里只对以下几种方式作一简要介绍：

- OpenOCD
- VSCode + JLinkGDBServer
- JLink + JLinkRemoteServer
- KeilMDK + JLinkRemoteServer

### OpenOCD

略.

### VSCode + JLinkGDBServer

1\. 在服务主机上配置开启 JLink 调试服务器（该服务器会监听 2331 端口）

![](JLinkGDBServer.LAN.Server.0.png)

{% note danger no-icon %}
不要勾选 Localhost Only 选项！
{% endnote %}

2\. 等待连接

![](JLinkGDBServer.LAN.Server.1.png)

3\. 在本地主机上配置 launch.json 文件并启动调试

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
点击启动调试后 cortex-debug 便会帮助我们通过本地 xGDB 客户端连接远程 GDB 服务器。
{% endnote %}

4\. 建立连接

![](JLinkGDBServer.LAN.Server.2.png)

5\. 远程调试

```
此处省略一张在 vscode 中调试的图片
```

6\. 断开连接

![](JLinkGDBServer.LAN.Server.3.png)

### JLink + JLinkRemoteServer

#### 内网连接

1\. 在服务主机上配置开启 JLink 远程服务器

![](JLinkRMTServer.LAN.Server.0.png)

2\. 等待连接

![](JLinkRMTServer.LAN.Server.1.png)

3\. 在本地主机上配置连接 JLink 远程服务器

![](JLinkRMTServer.LAN.Client.0.png)

4\. 建立连接

![](JLinkRMTServer.LAN.Server.2.png)

5\. 远程调试

![](JLinkRMTServer.LAN.Client.1.png)

6\. 断开连接

![](JLinkRMTServer.LAN.Server.3.png)

#### 隧道连接

1\. 在服务主机上配置开启 JLink 远程服务器（隧道方式）

![](JLinkRMTServer.Tunnel.Server.0.png)

2\. 等待连接

![](JLinkRMTServer.Tunnel.Server.1.png)

3\. 在本地主机上配置连接 JLink 远程服务器（隧道方式）

![](JLinkRMTServer.Tunnel.Client.0.png)

4\. 建立连接

![](JLinkRMTServer.Tunnel.Server.2.png)

5\. 远程调试

![](JLinkRMTServer.Tunnel.Client.1.png)

6\. 断开连接

![](JLinkRMTServer.Tunnel.Server.3.png)

### KeilMDK + JLinkRemoteServer

#### 内网连接

1\. 在服务主机上配置开启 JLink 远程服务器

![](JLinkRMTServer.LAN.Server.0.png)

2\. 等待连接

![](JLinkRMTServer.LAN.Server.1.png)

3\. 在本地主机上配置连接 JLink 远程服务器

![](JLinkRMTServer.LAN.Client.0.Keil.MDK.png)

4\. 建立连接

![](JLinkRMTServer.LAN.Server.2.png)

5\. 远程调试

```
此处省略一张在 Keil MDK 中调试的图片
```

6\. 断开连接

![](JLinkRMTServer.LAN.Server.3.png)
