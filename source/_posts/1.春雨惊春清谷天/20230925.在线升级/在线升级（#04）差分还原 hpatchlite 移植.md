---
title: 嵌入式 IAP 在线升级－差分还原 hpatchlite 移植
id: cloidefbf00hzv0rqa7zg722r
date: 2023-10-01 00:00:04
tags: [嵌入式软件开发, 在线升级, 差分还原算法, 增量升级]
categories: [开发笔记]
---

最近发现了一个优秀的差分还原算法：hdiff & hpatch，它通过数据流的思想把 O(n) 的空间复杂度转嫁给了硬盘，使得内存的开销极低，非常适合应用于嵌入式领域。

![](diff.tools.compare.png)

<!-- more -->

## 性能分析

### hpatchlite

时间复杂度：O(oldSize+newSize)
空间复杂度：O(1)
　　还原代码开销｜ROM = 876 字节 (compiled by armcc v5.06 update4 build 422)
　　还原内存开销｜RAM = 还原缓冲大小 + 解压内存开销

注：还原缓冲大小在还原时指定，至少3个字节，还原缓冲越小还原得越慢。

### tinyuz

时间复杂度：O(oldSize+newSize)
空间复杂度：O(1)
　　解压代码开销｜流模式｜ROM = 1142 字节 (compiled by armcc v5.06 update4 build 422)
　　解压内存开销｜流模式｜RAM = 压缩字典大小 + 解压缓冲大小

注：压缩字典大小在压缩时指定，至少1个字节，压缩字典越小压缩率越低。
注：解压缓冲大小在解压时指定，至少2个字节，解压缓冲越小解压缩越慢。

### appendix

```
Code (inc. data)   RO Data    RW Data    ZI Data      Debug   Object Name

 876          0          0          0          0      10783   hpatch_lite.o
1142          0          0          0          0      13541   tuz_dec.o

 626         80          0         12          0      12256   hpatch_user.o
```

```
244           0          0          0          0       2146   bspatch.o
586           6         64          0          0       6749   quicklz.o

102           4          8          0          0       2821   bspatch_user.o
 52           0          0          0          0       2096   quicklz_user.o
```

## 移植说明

将 hdiffpatch.hpatchlite & tinyuz 移植至单片机 bare metal 裸机系统（based on hdiffpatch v4）

### 拿来

将 tinyuz/decompress 目录拷贝至目标工程中。

将 HDiffPatch/libHDiffPatch/HPatch 目录拷贝至目标工程中。

将 HDiffPatch/libHDiffPatch/HPatchLite 目录拷贝至目标工程中。

将 HPatchLite/decompresser_demo.h 文件拷贝至目标工程中。

### 画瓢

依 HPatchLite/hpatchi.c/hpatchi() 函数画瓢：移植还原功能

依 tinyuz/tinyuz_demo.cpp/_tuz_decompress_stream() 函数画瓢：移植解压功能

done!

### 分析

拿来依葫芦画瓢，说得简单，做起来着实还是费了点功夫，这几年搞嵌入式搞得有些局限了，面对句(gōu)柄这种用法竟感觉无从下手。😅

作者提供了以下两个接口函数：

```c
hpatch_lite_open()

hpatch_lite_patch()
```

看着挺简单的吧，然而他实际上是这样的：

```c
// hpatch_lite by stream: hpatch_lite_open()+hpatch_lite_patch() compiled by Mbed Studio is 662 bytes
//   hdiffpatch v4.2.3, other patcher compiled by Mbed Studio:
//      patch_single_stream() 2356 bytes (hpatch_StreamPos_t=hpatch_uint32_t)
//      patch_decompress_with_cache() 2846 bytes (_IS_NEED_CACHE_OLD_BY_COVERS=0,hpatch_StreamPos_t=hpatch_uint32_t)

//diff_data must created by create_lite_diff()

typedef struct hpatchi_listener_t{
    hpi_TInputStreamHandle  diff_data;
    hpi_TInputStream_read   read_diff;
    //must read data_size data to out_data, from read_from_pos of stream; if read error return hpi_FALSE;
    hpi_BOOL (*read_old)(struct hpatchi_listener_t* listener,hpi_pos_t read_from_pos,hpi_byte* out_data,hpi_size_t data_size);
    //must write data_size data to sequence stream; if write error return hpi_FALSE;
    hpi_BOOL (*write_new)(struct hpatchi_listener_t* listener,const hpi_byte* data,hpi_size_t data_size);
} hpatchi_listener_t;

//hpatch_lite open
// read lite headinfo from diff_data
// if diff_data uncompress(*out_compress_type==hpi_compressType_no), *out_uncompressSize==0;
// if (*out_compress_type!=hpi_compressType_no), you need open compressed data by decompresser
//      (see https://github.com/sisong/HPatchLite/decompresser_demo.h & https://github.com/sisong/HPatchLite/hpatchi.c)
hpi_BOOL hpatch_lite_open(hpi_TInputStreamHandle diff_data,hpi_TInputStream_read read_diff,
                          hpi_compressType* out_compress_type,hpi_pos_t* out_newSize,hpi_pos_t* out_uncompressSize);
//hpatch_lite patch
//	used temp_cache_size memory + {decompress buffer*1}
//  note: temp_cache_size>=hpi_kMinCacheSize
hpi_BOOL hpatch_lite_patch(hpatchi_listener_t* listener,hpi_pos_t newSize,
                           hpi_byte* temp_cache,hpi_size_t temp_cache_size);
```

试着分析一下：

**差分包头信息读取接口**

```c
/** 差分包头信息读取接口
 *
 * @param hpi_TInputStreamHandle        diff_data           注意此处入参：差分数据流句柄（个人理解：如果不需要该句柄的话可以将其定义为空指针）
 * @param hpi_TInputStream_read         read_diff           注意此处入参：差分数据流读取函数（用户实现：以数据流的方式读取外部存储中差分数据分区的数据）
 * @param hpi_compressType             *out_compress_type   差分包头信息：差分包压缩类型
 * @param hpi_pos_t                    *out_newSize         差分包头信息：还原数据的长度
 * @param hpi_pos_t                    *out_uncompressSize  差分包头信息：解压之后的长度（如果差分包未被压缩则*out_uncompressSize输出0）
**/
hpi_BOOL hpatch_lite_open(hpi_TInputStreamHandle diff_data,hpi_TInputStream_read read_diff,hpi_compressType* out_compress_type,hpi_pos_t* out_newSize,hpi_pos_t* out_uncompressSize);
```

**差分包头定义**

```c
#define hpi_kHeadSize (2+1+1) //"hI" + hpi_compressType + (versionCode + newSize_Bytes + uncompressSize_Bytes) { + newSize + uncompressSize} { + dictSize}
差分包头[0] : 魔术数字 68 'h'
差分包头[1] : 魔术数字 49 'I'
差分包头[2] : 压缩类型
差分包头[3] : 版本代码[7:6]+解压数据长度所占的字节数u[5:3]+还原数据长度所占的字节数n[2:0]
差分包头[4 ~ 4+n] : 还原数据长度
差分包头[? ~ ?+u] : 解压数据长度

压缩包头[? ~ ?+4] : 压缩字典大小
```

**差分还原接口**

```c
/** 差分还原接口
 *
 * @param hpatchi_listener_t            listener            详见 hpatchi_listener_t 分析
 * @param hpi_pos_t                     newSize             还原数据的长度
 * @param hpi_byte                     *temp_cache          还原缓冲的地址
 * @param hpi_size_t                    temp_cache_size     还原缓冲的大小（>=2）
**/
hpi_BOOL hpatch_lite_patch(hpatchi_listener_t* listener,hpi_pos_t newSize,hpi_byte* temp_cache,hpi_size_t temp_cache_size);
```

**hpatchi_listener_t**

```c
typedef struct hpatchi_listener_t
{
    hpi_TInputStreamHandle  diff_data;
    hpi_TInputStream_read   read_diff;
    hpi_BOOL (*read_old)(struct hpatchi_listener_t* listener,hpi_pos_t read_from_pos,hpi_byte* out_data,hpi_size_t data_size);
    hpi_BOOL (*write_new)(struct hpatchi_listener_t* listener,const hpi_byte* data,hpi_size_t data_size);
} hpatchi_listener_t;
```

**hpatchi_listener_t 实例（差分包未经压缩）**

```c
hpatchi_listener_t listener =
{
    .diff_data = 差分数据流句柄,
    .read_diff = 差分数据流读取函数,    由用户去实现（从外部存储的差分数据分区读取）（函数一）

    .read_old  = 旧版数据流读取函数,    由用户去实现（从内部存储的旧版程序分区读取）（函数二）
    .write_new = 还原数据流写入函数,    由用户去实现（写入到外部存储的还原程序分区）（函数三）
};
```

**hpatchi_listener_t 实例（差分包经过压缩）**

```c
tuz_TStream _tuz_stream = /* 压缩数据流句柄 */
{
    .in_Stream = 差分数据流句柄,
    .read_code = 差分数据流读取函数,    由用户去实现（从外部存储的差分数据分区读取）（函数一）
}

hpatchi_listener_t listener =
{
    .diff_data = 压缩数据流句柄,        _tuz_stream
    .read_diff = 压缩数据流解压函数,    _tuz_TStream_decompress() // decompresser_demo.h

    .read_old  = 旧版数据流读取函数,    由用户去实现（从内部存储的旧版程序分区读取）（函数二）
    .write_new = 还原数据流写入函数,    由用户去实现（写入到外部存储的还原程序分区）（函数三）
};
```

最后需要特别注意的一点是：差分包必须由 create_lite_diff() 函数创建。宏观上来说就是差分包必须要通过 hdiffi.exe 程序生成，不能使用 hdiffz.exe 生成。

### 框架

```c
// 该回调函数由用户提供
hpi_BOOL 差分数据流读取函数()
{
    由用户实现
}

// 该回调函数由用户提供
hpi_BOOL 旧版数据流读取函数()
{
    由用户实现
}

// 该回调函数由用户提供
hpi_BOOL 还原数据流写入函数()
{
    由用户实现
}

// 根据 hpatch_lite_open() 和 hpatch_lite_patch() 编写的还原程序
hpi_patch_result_t hpi_patch(listener, “还原缓冲大小”, “解压缓冲大小”, “差分数据流读取函数”, “旧版数据流读取函数”, “还原数据流写入函数”)
{
    // 差分数据流句柄：如果不需要该句柄的话可以将其定义为空指针
    hpatch_lite_open(“差分数据流句柄”, “差分数据流读取函数”, 输出“差分包信息”);


    解压缓冲地址 = malloc();
    解压字典大小 = _tuz_TStream_getReservedMemSize(“差分数据流句柄”, “差分数据流读取函数”);
    tuz_TStream_open(_tuz_stream, “差分数据流句柄”, “差分数据流读取函数”, “解压缓冲地址”, “解压字典大小”, “解压缓冲大小”);


    patch_listener
        .diff_data = _tuz_stream
        .read_diff = _tuz_TStream_decompress() // decompresser_demo.h
        .read_old  = 旧版数据流读取函数()
        .write_new = 还原数据流写入函数()

    还原缓冲地址 = malloc();

    hpatch_lite_patch(“patch_listener”, “还原数据期望长度”, “还原缓冲地址”, “还原缓冲大小”);
}
```

### 源码

```c hpatch_conf.h
#ifndef __hpatch_conf_h__
#define __hpatch_conf_h__

#include "rtthread.h"

#define hpi_malloc(x) rt_malloc(x)
#define hpi_free(x)   rt_free(x)

#endif /* __hpatch_conf_h__ */
```

```c hpatch_impl.h
#ifndef __hpatch_impl_h__
#define __hpatch_impl_h__

#include "hpatch_lite.h"
#include "patch_types.h"
#include "decompresser_demo.h"

typedef enum hpi_patch_result_t
{
    HPATCHI_SUCCESS = 0,
    HPATCHI_OPTIONS_ERROR,
    HPATCHI_PATHTYPE_ERROR,
    HPATCHI_OPENREAD_ERROR,
    HPATCHI_OPENWRITE_ERROR,
    HPATCHI_FILEREAD_ERROR,
    HPATCHI_FILEWRITE_ERROR,
    HPATCHI_FILEDATA_ERROR,
    HPATCHI_FILECLOSE_ERROR,
    HPATCHI_MEM_ERROR,
    HPATCHI_COMPRESSTYPE_ERROR,
    HPATCHI_DECOMPRESSER_DICT_ERROR,
    HPATCHI_DECOMPRESSER_OPEN_ERROR,
    HPATCHI_DECOMPRESSER_CLOSE_ERROR,
    HPATCHI_PATCH_OPEN_ERROR = 20,
    HPATCHI_PATCH_ERROR,
} hpi_patch_result_t;

typedef hpi_BOOL (*read_old_t)(struct hpatchi_listener_t *listener, hpi_pos_t addr, hpi_byte *data, hpi_size_t size);
typedef hpi_BOOL (*write_new_t)(struct hpatchi_listener_t *listener, const hpi_byte *data, hpi_size_t size);

int hpi_patch(hpatchi_listener_t *listener, int patch_cache_size, int decompress_cache_size, hpi_TInputStream_read _do_read_diff, read_old_t _do_read_old, write_new_t _do_write_new);

#endif /* __hpatch_impl_h__ */
```

```c hpatch_impl.c
#include "hpatch_impl.h"
#include "hpatch_conf.h"

hpi_patch_result_t hpi_patch(hpatchi_listener_t *listener, int patch_cache_size, int decompress_cache_size, hpi_TInputStream_read _do_read_diff, read_old_t _do_read_old, write_new_t _do_write_new)
{
    hpi_patch_result_t result = HPATCHI_SUCCESS;
    hpi_byte *pmem            = 0;
    hpi_byte *patch_cache;

    hpi_compressType compress_type;
    hpi_pos_t new_size;
    hpi_pos_t uncompress_size;

    hpi_BOOL patch_result;
    patch_result = hpatch_lite_open(listener, _do_read_diff, &compress_type, &new_size, &uncompress_size);
    if (patch_result != hpi_TRUE)
    {
        result = HPATCHI_PATCH_OPEN_ERROR;
        goto clear;
    }

    listener->read_old  = _do_read_old;
    listener->write_new = _do_write_new;

    switch (compress_type)
    {
        case hpi_compressType_no: // memory size: patch_cache_size
        {
            pmem = (hpi_byte *)hpi_malloc(patch_cache_size);
            if (!pmem)
            {
                result = HPATCHI_MEM_ERROR;
                goto clear;
            }
            patch_cache = pmem;

            listener->diff_data = listener;
            listener->read_diff = _do_read_diff;
        }
        break;
#ifdef _CompressPlugin_tuz
        case hpi_compressType_tuz: // requirements memory size: patch_cache_size + decompress_cache_size + decompress_dict_size
        {
            tuz_TStream tuz_stream_handle;

            size_t decompress_dict_size = _tuz_TStream_getReservedMemSize(listener, _do_read_diff);
            if (decompress_dict_size <= 0)
            {
                result = HPATCHI_DECOMPRESSER_DICT_ERROR;
                goto clear;
            }

            pmem = (hpi_byte *)hpi_malloc(decompress_dict_size + decompress_cache_size + patch_cache_size);
            if (!pmem)
            {
                result = HPATCHI_MEM_ERROR;
                goto clear;
            }

            tuz_TResult tuz_result = tuz_TStream_open(&tuz_stream_handle, listener, _do_read_diff, pmem, (tuz_size_t)decompress_dict_size, (tuz_size_t)decompress_cache_size);
            if (tuz_result != tuz_OK)
            {
                result = HPATCHI_DECOMPRESSER_OPEN_ERROR;
                goto clear;
            }

            patch_cache = pmem + decompress_dict_size + decompress_cache_size;

            listener->diff_data = &tuz_stream_handle;
            listener->read_diff = _tuz_TStream_decompress;
        }
        break;
#endif
        default:
        {
            result = HPATCHI_COMPRESSTYPE_ERROR;
            goto clear;
        }
    }

    patch_result = hpatch_lite_patch(listener, new_size, patch_cache, (hpi_size_t)patch_cache_size);
    if (patch_result != hpi_TRUE)
    {
        result = HPATCHI_PATCH_ERROR;
        goto clear;
    }

clear:
    if (pmem)
    {
        hpi_free(pmem);
        pmem = 0;
    }
    return result;
}
```

```c hpatch_demo.c
#include "hpatch_impl.h"

typedef struct hpatchi_instance_t
{
    hpatchi_listener_t parent;
    int patch_file_offset;
    int patch_file_len;
    int patch_read_pos;
    int newer_file_len;
    int newer_write_pos;
} hpatchi_instance_t;

// 以数据流的形式读取空文件
hpi_BOOL _do_read_empty(struct hpatchi_listener_t *listener, hpi_pos_t addr, hpi_byte *data, hpi_size_t size)
{
    memset(data, 0, size);
    return hpi_TRUE;
}

// 以数据流的形式读取旧程序
hpi_BOOL _do_read_old(struct hpatchi_listener_t *listener, hpi_pos_t addr, hpi_byte *data, hpi_size_t size)
{
    int result = update_fetch_runapp(addr, data, size);
    if (result < 0) { return hpi_FALSE; }
    return hpi_TRUE;
}

// 以数据流的形式读取补丁包（由用户记录数据流的位置：读到哪儿了）
hpi_BOOL _do_read_patch(hpi_TInputStreamHandle input_stream, hpi_byte *data, hpi_size_t *size)
{
    hpatchi_instance_t *instance = (hpatchi_instance_t *)input_stream;

    // 数据流结束时需要将 *size 置为当前所读数据的实际长度（*size == decompress_cache_size）
    if ((instance->patch_read_pos + *size) > instance->patch_file_len)
    {
        *size = instance->patch_file_len - instance->patch_read_pos;
    }

    int result = update_fetch_backup(instance->patch_file_offset + instance->patch_read_pos, data, *size);
    if (result < 0) { return hpi_FALSE; }
    instance->patch_read_pos += *size;
    return hpi_TRUE;
}

// 以数据流的形式写入差分还原的数据（由用户记录数据流的位置：写到哪儿了）
hpi_BOOL _do_write_new(struct hpatchi_listener_t *listener, const hpi_byte *data, hpi_size_t size)
{
    hpatchi_instance_t *instance = (hpatchi_instance_t *)listener;

    int percent = instance->newer_write_pos * 100 / instance->newer_file_len;
    if (percent % 5 == 0 && percent < 100)
    {
        rt_kprintf("\b\b\b%02d%%", percent);
    }

    int result = update_write_decode(instance->newer_write_pos, (unsigned char *)data, size);
    if (result < 0) { return hpi_FALSE; }
    instance->newer_write_pos += size;
    return hpi_TRUE;
}

void demo(void)
{
    hpatchi_instance_t instance = {0};
    instance.patch_file_offset  = update_pack->header_size; // 从升级包的包头中获取差分数据的地址
    instance.patch_file_len     = update_pack->remain_size; // 从升级包的包头中获取差分数据的大小
    instance.newer_file_len     = update_pack->newapp_size; // 从升级包的包头中获取新版程序的大小

    // 差分全量升级
    {
        hpi_patch(&instance.parent, 128, 128, _do_read_patch, _do_read_empty, _do_write_new);
    }

    // 差分增量升级
    {
        hpi_patch(&instance.parent, 128, 128, _do_read_patch, _do_read_old, _do_write_new);
    }
}
```
