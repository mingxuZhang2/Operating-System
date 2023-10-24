#ifndef __KERN_MM_SLUB_CACHE_H__
#define __KERN_MM_SLUB_CACHE_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>

typedef struct slub_cache {
    size_t obj_size;             // 对象大小
    struct list_entry free;      // 完全没有使用的页面
    struct list_entry full;      // 完全使用的页面
    struct list_entry partial;   // 部分使用的页面
} slub_cache_t;

void slub_cache_init(slub_cache_t *cache, size_t size);
void *slub_cache_alloc(slub_cache_t *cache);
void slub_cache_free(slub_cache_t *cache, void *obj);
void test_slub_cache();
#endif /* __KERN_MM_SLUB_CACHE_H__ */
