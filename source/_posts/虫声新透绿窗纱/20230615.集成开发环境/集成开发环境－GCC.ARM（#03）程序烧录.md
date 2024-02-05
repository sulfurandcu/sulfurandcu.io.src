---
title: 集成开发环境－GCC.ARM（#03）程序烧录
id: clo2c1l6600ca1wrqbvuabt0b
date: 2023-06-15 00:00:03
tags: [嵌入式软件开发, 集成开发环境, IDE]
categories: [开发笔记]
---

编程/下载/烧录的方式有多种，本文重点介绍以下两种烧录方式：

- JLink
- OpenOCD + JLink 仿真器

其中 OpenOCD 可以搭配多种仿真器使用，这里以 JLink 仿真器为例进行说明。

<!-- more -->

## JLink

1\. 确认是否购买了 JLink 仿真器并且已经安装了 JLink 程序。

2\. 在 makefile 中添加 write 选项：

![](make.write.JLinkLoad.png)

3\. 在工程目录下新建 JLinkLoad.txt 文件并写入以下内容：

![](make.write.JLinkLoad.code.png)

4\. 执行 mingw32-make write 指令：

![](make.write.JLinkLoad.succ.png)

{% note danger no-icon %}
再次提醒：需要使用 JLink 仿真器以及**默认驱动**
{% endnote %}

{% note danger no-icon %}
如果你的电脑中有不止一个 “JLink” 程序，确保在 makefile 中通过绝对路径使用 JLink 命令。
{% endnote %}

下图是我安装了 JavaJDK 后系统中存在的 jlink 程序，只不过此 “jlink” 非彼 “JLink”！

![](make.write.JLink.JavaJDK.png)

## OpenOCD

1\. 确认是否购买了 JLink 仿真器并且已经安装了 OpenOCD 程序。

2\. 在 makefile 中添加 write 选项：

![](make.write.OpenOCD.JLink.png)

3\. 在工程目录下新建 openocd.cfg 文件并写入以下内容：

![](make.write.OpenOCD.JLink.code.png)

> https://openocd.org/doc-release/html/OpenOCD-Project-Setup.html#Configuration-Basics

4\. 将 jlink.cfg 和 stm32f1x.cfg 拷贝至工程目录下。

5\. 使用 zadig 或 USBDriverTool 将仿真器的驱动从 WinUSB 改为 libusb 驱动。

6\. 执行 mingw32-make write 指令：

![](make.write.OpenOCD.JLink.succ.png)

## Q&A

### 问题一：未找到 JLink 仿真器

![](QA1.1.png)

OpenOCD 对仿真器的支持是通过底层的访问控制实现的，不依赖仿真器自身的驱动，但是需要 libusb 驱动，因此我们需要使用 zadig 或 USBDriverTool 等工具将仿真器的默认驱动改为 libusb 驱动。

需要注意的是，将驱动改成 libusb 之后，原有的调试软件例如 JLink/Keil 将无法再识别到仿真器。

如果你还想继续使用这些调试软件，则需要卸载掉当前的驱动程序并插拔一下仿真器：

![](QA1.2.png)

### 问题二：SWD & JTAG

![](QA2.1.png)

OpenOCD 提供的 jlink.cfg 脚本默认使用 JTAG 模式，而我们实际使用的是 SWD 模式。

解决方法：在 openocd.cfg 文件中添加一条语句：

![](QA2.2.png)
