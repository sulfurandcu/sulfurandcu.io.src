---
title: 集成開發環境－GCC.ARM（#05）程序調試
id: clo2c1l6600cb1wrqewhnb8ey
date: 2023-06-15 00:00:05
tags: [嵌入式軟件開發, 集成開發環境, IDE]
categories: [開發筆記]
---

---

- laugch.json

---

<!-- more -->

1\. 在工程目錄下的 .vscode 目錄中新建 laugch.json 文件並填入以下內容：

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug@JLinkGDBServerCL.exe",
            "type": "cortex-debug",
            "servertype": "jlink",
            "request": "attach",
            "cwd": "${workspaceRoot}/project/GCC",
            "executable": "./build/main.elf",

            "device": "STM32F103CB",
            "interface": "swd",
            "serverArgs": [
                // "-gui",
            ],
        },
        {
            "name": "Debug@OpenOCD.exe",
            "type": "cortex-debug",
            "servertype": "openocd",
            "request": "attach",
            "cwd":"${workspaceRoot}/project/GCC",
            "executable": "./build/main.elf",

            "showDevDebugOutput": "none",
            "configFiles": [
                "openocd/jlink-swd.cfg",
                "openocd/stm32f1x.cfg",
            ],
        },
        {
            "name": "Debug@RemoteServer(GDBServer/JLinkGDBServer)",
            "type": "cortex-debug",
            "servertype": "external",
            "request": "attach",
            "cwd":"${workspaceRoot}/project/GCC",
            "executable": "./build/main.elf",

            "gdbTarget": "192.168.1.1:2331",

            "gdbPath": "D:/develop.r.0/gcc-arm-none-eabi-10.3-2021.10/bin/arm-none-eabi-gdb.exe",
            "armToolchainPath": "D:/develop.r.0/gcc-arm-none-eabi-10.3-2021.10/bin",
        },
    ],
}
```

2\. 進入側邊欄中的 RunAndDebug 然後選擇

- Debug\@JLinkGDBServerCL.exe
- Debug\@OpenOCD.exe
- Debug\@RemoteServer(GDBServer/JLinkGDBServer)

![](launch.json.png)
