---
title: 集成开发环境－GCC.ARM（#01）环境搭建
id: clo2c1l6o00dh1wrqd2o379jc
date: 2023-06-15 00:00:01
tags: [嵌入式软件开发, 集成开发环境, IDE]
categories: [开发笔记]
---

![](Download.VSC.png)

<!-- more -->

---

## 编辑器安装

- **VSC**

![](Download.VSC.png)

<center><a href="https://code.visualstudio.com/Download">https://code.visualstudio.com/Download</a></center>

- **VS**

![](Download.VS.png)

<center><a href="https://visualstudio.microsoft.com/downloads/">https://visualstudio.microsoft.com/downloads/</a></center>

- **Eclipse.Embedded**

![](Download.EclipseEmbedded.png)

<center><a href="https://www.eclipse.org/downloads/packages/">https://www.eclipse.org/downloads/packages/</a></center>

## 编辑器插件

- **[vscode :: cortex-debug](https://github.com/Marus/cortex-debug/wiki)**
- **[vscode :: eide](https://em-ide.com/zh-cn/)**

## 编译器安装

- **[Arm GNU Toolchain on MSYS2](https://packages.msys2.org/base/mingw-w64-arm-none-eabi-gcc) (pacman -S mingw-w64-x86_64-arm-none-eabi-gcc)**
- **[Arm GNU Toolchain (12.2.Rel1 based on GCC 12.2)](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)**
- **[Arm GNU Toolchain for the Cortex-A (10.3-2021.07 based on GCC 10.3)](https://developer.arm.com/downloads/-/gnu-a)**
- **[Arm GNU Toolchain for the Cortex-R & Cortex-M (10.3-2021.10 based on GCC 10.3)](https://developer.arm.com/downloads/-/gnu-rm)**
- **[xPack GNU Arm Embedded GCC toolchain](https://xpack.github.io/dev-tools/arm-none-eabi-gcc/releases/)**

{% note danger no-icon %}
记得将安装目录添加至系统环境变量
{% endnote %}

## 调试器安装

- **[JLink Installer](https://www.segger.com/downloads/jlink/#J-LinkSoftwareAndDocumentationPack)**
- **[OpenOCD on MSYS2](https://packages.msys2.org/base/mingw-w64-openocd) (pacman -S mingw-w64-x86_64-openocd)**
- **[OpenOCD prebuilt by OpenOCD.org](https://github.com/openocd-org/openocd/releases)**
- **[OpenOCD prebuilt by Sysprogs](https://gnutoolchains.com/arm-eabi/openocd/)**
- **[OpenOCD prebuilt by xPackProject](https://xpack.github.io/dev-tools/openocd/releases/)**

{% note danger no-icon %}
记得将安装目录添加至系统环境变量
{% endnote %}

## 构建器安装

- **[mingw-make in msys2](https://www.msys2.org/)**
- **cmake [download](https://cmake.org/) (python -m pip install cmake) (winget install cmake)**
- **ninja [download](https://ninja-build.org/) (python -m pip install ninja) (winget install ninja)**
- **scons [download](https://scons.org/) (python -m pip install scons==3.1.2)**

{% note info no-icon %}
理论上安装完编辑器、编译器和调试器之后就能够进行开发了，安装上述工具是为了提高开发效率。
{% endnote %}

## 必要的文件

- **\*.h, \*.c**
  代码文件：在 makefile 中引用进行编译
- **\*.s**
  启动文件：在 makefile 中引用进行编译
- **\*.ld**
  链接文件：在 makefile 中引用进行链接
- **\*.svd**
  描述文件：在 launch.json 中配置用于调试
