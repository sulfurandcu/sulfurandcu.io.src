---
title: 嵌入式 IAP 升级功能（#07）压缩解压 tinyuz 移植
id: cloidh8k000ijv0rq8b5hbdpe
date: 2023-10-01 00:00:07
tags: [嵌入式软件开发, 在线升级, 压缩解压算法]
categories: [开发笔记]
---

与上文类似，对 tinyuz 也进行二次封装以便上层调用：

```c tinyuz_port.h
#ifndef __tinyuz_port_h__
#define __tinyuz_port_h__

#include <stddef.h>
#include "malloc.h"

#define TUZ_DECOMPRESS_SPACE_SIZE       512*1024            // 外部存储中〈差分文件区〉的空间大小

#define tuz_malloc(x)                   mymalloc(x)
#define tuz_free(x)                     myfree(x)

typedef enum TTinyuzResult
{
    TINYUZ_SUCCESS=0,
    TINYUZ_OPTIONS_ERROR,
    TINYUZ_OPENREAD_ERROR,
    TINYUZ_OPENWRITE_ERROR,
    TINYUZ_FILEREAD_ERROR,
    TINYUZ_FILEWRITE_ERROR,
    TINYUZ_FILECLOSE_ERROR,
    TINYUZ_MEM_ERROR,
    TINYUZ_COMPRESS_ERROR,
    TINYUZ_DECOMPRESS_ERROR,
} TTinyuzResult;

size_t tuz_decompress(size_t compressed_file_size, size_t cache_size);

#endif /* __tinyuz_port_h__ */
```

<!-- more -->

```c tinyuz_port.c
#include "tinyuz_port.h"
#include "fal.h"
#include "tuz_dec.h"
#include "patch_types.h"

typedef struct TTuzListener
{
    const hpatch_TStreamInput*  input_file_stream_handle;
    hpatch_StreamPos_t          readPos;
    tuz_TInputStream_read       _do_read_encompress_file;
}TTuzListener;

// 从外部flash中以数据流的形式读取压缩数据
hpatch_BOOL _do_read_encompress_file(const hpatch_TStreamInput* stream, hpatch_StreamPos_t readFromPos, unsigned char* out_data, unsigned char* out_data_end)
{
    size_t readLen = (size_t)(out_data_end - out_data);
    if (readLen == 0) return hpatch_TRUE;

    size_t compressed_stream_size = stream->streamSize;

    if ((readLen > compressed_stream_size) || (readFromPos > compressed_stream_size - readLen)) return hpatch_FALSE;

    // TODO 由用户实现
    const struct fal_partition *partition = fal_partition_find("app_ziped");
    int result = fal_partition_read(partition, readFromPos, out_data, readLen);

    return hpatch_TRUE;
}

// 将解压数据以数据流的形式写入外部flash中
hpatch_BOOL _do_write_decompress_file(const hpatch_TStreamOutput* stream, hpatch_StreamPos_t writeToPos, const unsigned char* data, const unsigned char* data_end)
{
    unsigned int offset = 0;

    size_t writeLen = (size_t)(data_end - data);
    if (writeLen == 0) return hpatch_TRUE;

    size_t write_max_space = stream->streamSize;

    if ((writeLen > write_max_space)||(writeToPos > write_max_space - writeLen)) return hpatch_FALSE;

    // TODO 由用户实现
    const struct fal_partition *partition = fal_partition_find("app_newer");
    int result = fal_partition_write(partition, offset+writeToPos, data, writeLen);

    return hpatch_TRUE;
}

static tuz_BOOL input_file_stream_read_function(void *listener, tuz_byte *decompressed_file_stream, tuz_size_t *code_size)
{
    TTuzListener *self = (TTuzListener*)listener;
    tuz_size_t r_len = *code_size;
    hpatch_StreamPos_t curReadPos = self->readPos;
    hpatch_StreamPos_t s_size = self->input_file_stream_handle->streamSize - curReadPos;

    if (r_len > s_size){
        r_len = (tuz_size_t)s_size;
        *code_size = r_len;
    }

    self->readPos += r_len;
    return self->input_file_stream_handle->read(self->input_file_stream_handle, curReadPos, decompressed_file_stream, decompressed_file_stream + r_len);
}

size_t tuz_decompress(size_t compressed_file_size, size_t cache_size)
{
    hpatch_TStreamOutput decompressed_file_stream_handle = {
        .streamImport = &decompressed_file_stream_handle,
        .streamSize = TUZ_DECOMPRESS_SPACE_SIZE, // 外部存储中〈差分文件区〉的空间大小
        .write = _do_write_decompress_file, // stream write
        .read_writed = NULL,
    };

    hpatch_TStreamInput input_file_stream_handle = {
        .streamImport = &input_file_stream_handle,
        .streamSize = compressed_file_size, // 压缩文件的实际大小
        .read = _do_read_encompress_file, // stream read
    };

    TTuzListener listener = {&input_file_stream_handle, 0, input_file_stream_read_function};
    tuz_TStream tuz;
    tuz_TResult result = tuz_OK;

    // 压缩的时候会以指定的字典大小进行压缩｜因此解压的时候要从压缩包头中读取字典大小
    tuz_size_t dictSize = tuz_TStream_read_dict_size(&listener, listener._do_read_encompress_file);

    tuz_byte* decompress_buf = 0;
    cache_size >>= 1; // 除二操作
    decompress_buf = (tuz_byte*)tuz_malloc(dictSize + cache_size*2); // 解压过程中要用到的临时空间大小 = 字典大小 + 解压缓冲区大小

    if (decompress_buf == 0) return TINYUZ_MEM_ERROR;

    // tuz_TStream_open 仅仅是用来初始化 tuz 这个勾柄的（tuz后面的参数都是给tuz赋值用的）
    result = tuz_TStream_open(&tuz, &listener, listener._do_read_encompress_file, decompress_buf + cache_size, (tuz_size_t)dictSize, (tuz_size_t)cache_size);

    hpatch_StreamPos_t stream_index = 0;

    while (result == tuz_OK)
    {
        tuz_size_t decompress_len = (tuz_size_t)cache_size; // 给decompress_len赋一个初始值

        // 解压一包数据到 decompress_buf 中｜并得到该包长度 decompress_len
        result = tuz_TStream_decompress_partial(&tuz, decompress_buf, &decompress_len);

        if (result <= tuz_STREAM_END)
        {
            // 将当前解压的 decompress_buf 中的数据写到 decompressed_file_stream_handle 数据流中
            if (decompressed_file_stream_handle.write(&decompressed_file_stream_handle, stream_index, decompress_buf, decompress_buf + decompress_len))
            {
                stream_index += decompress_len;
            }
            else
            {
                tuz_free(decompress_buf);
                return TINYUZ_OPENWRITE_ERROR;
            }
        }
    }

    tuz_free(decompress_buf);

    return stream_index;
}
```
