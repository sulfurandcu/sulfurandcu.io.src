---
title: 集成開發環境－GCC.ARM（#01）環境搭建
id: clo2c1l6o00dh1wrqd2o379jc
date: 2023-06-15 00:00:01
tags: [嵌入式軟件開發, 集成開發環境, IDE]
categories: [開發筆記]
---

![](Download.VSC.png)

<!-- more -->

---

## 編輯器安裝

- **VSC**

![](Download.VSC.png)

<center><a href="https://code.visualstudio.com/Download">https://code.visualstudio.com/Download</a></center>

- **VS**

![](Download.VS.png)

<center><a href="https://visualstudio.microsoft.com/downloads/">https://visualstudio.microsoft.com/downloads/</a></center>

- **Eclipse.Embedded**

![](Download.EclipseEmbedded.png)

<center><a href="https://www.eclipse.org/downloads/packages/">https://www.eclipse.org/downloads/packages/</a></center>

## 編輯器插件

- **[vscode :: cortex-debug](https://github.com/Marus/cortex-debug/wiki)**
- **[vscode :: eide](https://em-ide.com/zh-cn/)**

## 編譯器安裝

- **[Arm GNU Toolchain (12.2.Rel1 based on GCC 12.2)](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)**
- **[Arm GNU Toolchain for the Cortex-A (10.3-2021.07 based on GCC 10.3)](https://developer.arm.com/downloads/-/gnu-a)**
- **[Arm GNU Toolchain for the Cortex-R & Cortex-M (10.3-2021.10 based on GCC 10.3)](https://developer.arm.com/downloads/-/gnu-rm)**
- **[xPack GNU Arm Embedded GCC toolchain](https://xpack.github.io/dev-tools/arm-none-eabi-gcc/releases/)**

{% note danger no-icon %}
記得將安裝目錄添加至系統環境變量
{% endnote %}

## 調試器安裝

- **[SEGGER JLink Installer](https://www.segger.com/downloads/jlink/#J-LinkSoftwareAndDocumentationPack)**
- **[OpenOCD prebuilt by xPackProject](https://xpack.github.io/dev-tools/openocd/releases/)**
- **[OpenOCD prebuilt by Sysprogs](https://gnutoolchains.com/arm-eabi/openocd/)**
- **[OpenOCD prebuilt by OpenOCD.org](https://github.com/openocd-org/openocd/releases)**

{% note danger no-icon %}
記得將安裝目錄添加至系統環境變量
{% endnote %}

## 構建器安裝

- **[make](https://gnutoolchains.com/arm-eabi/openocd/)**
- **[ninja](https://gnutoolchains.com/arm-eabi/openocd/)**
- **[cmake](https://gnutoolchains.com/arm-eabi/openocd/)**

{% note info no-icon %}
理論上安裝完編輯器、編譯器和調試器之後就能夠正常使用了，安裝上述工具是爲了提高開發效率。
{% endnote %}

## 建立新工程

- 略.

## 拷貝至工程

- *.h, *.c
  代碼文件：在 makefile 中引用進行編譯
- *.s
  啓動文件：在 makefile 中引用進行編譯
- *.ld
  鏈接文件：在 makefile 中引用進行鏈接
- *.svd
  描述文件：在 launch.json 中配置用於調試
