---
title: 集成开发环境－GCC.ARM（#04）快捷任务
id: clo2c1l6700cd1wrqgjn53mgz
date: 2023-06-15 00:00:04
tags: [嵌入式软件开发, 集成开发环境, IDE]
categories: [开发笔记]
---

---

- tasks.json

---

<!-- more -->

通过 makefile 我们将海量的指令精简至一条 make+ 指令，但是我比较懒，一条指令都不想敲。😎

1\. 在工程目录下的 .vscode 目录中新建 tasks.json 文件并填入以下内容：

```
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "编译（build）",
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
            "label": "烧录（write）",
            "type": "shell",
            "command": "cd project/GCC | mingw32-make write",
            "args": [

            ],
            "problemMatcher": [],
        },
        {
            "label": "烧录（write.openocd）",
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
在 cmd 中使用 “|” 连接两条指令，在 powershell 中使用 “;” 连接两条指令。
{% endnote %}

2\. 找到菜单栏依次点击 Terminal -> RunTask 然后选择：

- 编译（build）
- 清除（clean）
- 烧录（write）
- 烧录（write.openocd）

![](task.json.png)
