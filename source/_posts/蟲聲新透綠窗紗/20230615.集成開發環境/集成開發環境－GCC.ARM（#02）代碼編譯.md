---
title: 集成開發環境－GCC.ARM（#02）代碼編譯
id: clo2c1l6400c71wrq3816hypq
date: 2023-06-15 00:00:02
tags: [嵌入式軟件開發, 集成開發環境, IDE]
categories: [開發筆記]
---

廣義的編譯包括預處理、編譯、彙編、鏈接這四個基本流程，編譯期間需要執行若干指令。

倘若只有 main.h 和 main.c 兩個文件，那麼只需要執行少量的指令即可完成編譯工作。但是實際上一個工程通常包含幾十上百個文件，意味着要執行大量的編譯指令才能得到目標文件，這是我們所無法接受的。因此需要藉助 make、ninja 等構建工具實現編譯自動化。

<!-- more -->

## 生成腳本（makefile）

相較於頭開始寫 makefile 腳本，先通過 STM32CubeMX 生成然後加以改造則要容易得多。

![](GenerateMakefileByCubeMX.0.png)

![](GenerateMakefileByCubeMX.1.png)

![](GenerateMakefileByCubeMX.2.png)

## 修改腳本（makefile）

1. 修改文件列表（*.c & *.s）
   ```
   C_SOURCES = \
   ../../../code/Application/src/main.c \
   ...
   ```
   ```
   ASM_SOURCES = \
   startup_stm32f103xb.s \
   ...
   ```
2. 修改包含路徑（*.h）
   ```
   C_INCLUDES = \
   -I../../../code/Application \
   ...
   ```
3. 修改全局定義（#define）
   ```
   C_DEFS = \
   -DUSE_HAL_DRIVER \
   -DSTM32F103xB \
   ...
   ```
4. 修改鏈接腳本（.ld）
   ```
   LDSCRIPT = STM32F103C8Tx_FLASH.ld
   ```

## 執行編譯

在 makefile 所在的路徑下執行 make 指令開始編譯

![](make.build.png)

![](make.where.png)

{% note danger no-icon %}
在 windows 系統中請使用 ./mingw32-make 命令而非 ./make 命令！
{% endnote %}

## 清除編譯

若要清除剛纔編譯的中間文件，則需要修改 makefile 文件，然後執行 mingw32-make clean 指令。

```
clean:
#   -rm -fR $(BUILD_DIR)
    -del /q $(BUILD_DIR)
```

這時你大概率會遇到以下問題：

![](make.clean.fail1.png)

有人說將 clean 下的 -rm -fR $(BUILD_DIR) 改成 -del /q $(BUILD_DIR) 就好了，實測並不管用。

![](make.clean.fail2.png)

只有顯式地將 SHELL 指定爲 cmd 纔行（在 makefile 中添加一條語句）：

![](make.clean.shell.png)
