---
title: 嵌入式 IAP 升级功能（#04）技术细节
id: clnyhr2n4005410rqfyjmedv1
date: 2023-10-01 00:00:04
tags: [嵌入式软件开发, 在线升级]
categories: [开发笔记]
---

分散加载、中断向量表重定向

## 调整大小程序时要修改哪些配置？

➀ 修改 main.sct 分散加载文件。

➁ 修改 ConfigMCU 中大小程序的起始地址及空间大小。

➂ 修改 iap: system_mcumodel.c 中 VECT_TAB_OFFSET 的值（等于小程序的起始地址）。

➃ 修改 app: system_mcumodel.c 中 VECT_TAB_OFFSET 的值（等于大程序的起始地址）。
