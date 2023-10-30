---
title: 集成開發環境－GCC.ARM（#04）快捷任務
id: clo2c1l6700cd1wrqgjn53mgz
date: 2023-06-15 00:00:04
tags: [嵌入式軟件開發, 集成開發環境, IDE]
categories: [開發筆記]
---

---

- tasks.json

---

<!-- more -->

通過 makefile 我們將海量的指令精簡至一條 make+ 指令，但是我比較懶，一條指令都不想敲。😎

1\. 在工程目錄下的 .vscode 目錄中新建 tasks.json 文件並填入以下內容：

```
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "編譯（build）",
            "type": "shell",
            "command": "cd project/GCC | mingw32-make",
            "args": [

            ],
            "problemMatcher": [],
        },
        {
            "label": "清除（clean）",
            "type": "shell",
            "command": "cd project/GCC | mingw32-make clean",
            "args": [

            ],
            "problemMatcher": [],
        },
        {
            "label": "燒錄（write）",
            "type": "shell",
            "command": "cd project/GCC | mingw32-make write",
            "args": [

            ],
            "problemMatcher": [],
        },
        {
            "label": "燒錄（write.openocd）",
            "type": "shell",
            "command": "cd project/GCC | mingw32-make write.openocd",
            "args": [

            ],
            "problemMatcher": [],
        },
    ],
}
```

{% note info no-icon %}
在 cmd 中使用 “|” 連接兩條指令，在 powershell 中使用 “;” 連接兩條指令。
{% endnote %}

2\. 找到菜單欄依次點擊 Terminal -> RunTask 然後選擇：

- 編譯（build）
- 清除（clean）
- 燒錄（write）
- 燒錄（write.openocd）

![](task.json.png)
