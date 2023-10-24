#include<pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>

#include <slub_cache.h>



void slub_cache_init(slub_cache_t *cache, size_t size) {
    cache->obj_size = size;
    list_init(&(cache->full));
    list_init(&(cache->partial));
    list_init(&(cache->free));
}

void *slub_cache_alloc(slub_cache_t *cache) {
    if (list_empty(&(cache->partial))) {
        struct Page *new_page = alloc_pages(1); // 从物理内存管理器中分配一页
        if (!new_page) {
            return NULL; // 内存不足
        }
        new_page->property = 0; // 初始时没有对象使用
        list_add(&(cache->partial), &(new_page->page_link));
    }

    struct Page *page = le2page(list_next(&(cache->partial)), page_link);
    void *obj = (void *)(KADDR(page2pa(page)) + cache->obj_size * page->property);

    page->property++;
    if (page->property * cache->obj_size >= PGSIZE) {
        list_del(&(page->page_link));
        list_add(&(cache->full), &(page->page_link));
    }
    return obj;
}

void slub_cache_free(slub_cache_t *cache, void *obj) {
    struct Page *page = pa2page(PADDR((uintptr_t)obj));
    if (!page) {
        return; // 无效的对象
    }

    page->property--;
    if (page->property * cache->obj_size == PGSIZE - cache->obj_size) {
        list_del(&(page->page_link));
        list_add(&(cache->partial), &(page->page_link));
    } else if (page->property == 0) {
        list_del(&(page->page_link));
        list_add(&(cache->free), &(page->page_link));
        free_pages(page, 1);
    }
}
void test_slub_cache() {
    cprintf("Testing SLUB cache...\n");

    slub_cache_t cache;
    slub_cache_init(&cache, sizeof(int));

    // 1. 分配100个对象
    void *objs[100];
    for (int i = 0; i < 100; i++) {
        objs[i] = slub_cache_alloc(&cache);
        assert(objs[i] != NULL);  // 确保对象不为NULL
    }
    cprintf("100个对象分配成功\n");
    // 2. 检查地址是否不重叠
    for (int i = 0; i < 100; i++) {
        for (int j = i + 1; j < 100; j++) {
            assert(objs[i] != objs[j]);
        }
    }
    cprintf("位置不重叠成功\n");
    // 3. 释放奇数索引的对象
    for (int i = 1; i < 100; i += 2) {
        slub_cache_free(&cache, objs[i]);
        objs[i] = NULL;
    }
    cprintf("释放奇数索引成功\n");
    // 4. 重新分配50个对象，这应该会利用先前释放的对象的空间
    for (int i = 1; i < 100; i += 2) {
        objs[i] = slub_cache_alloc(&cache);
        assert(objs[i] != NULL);
    }
    cprintf("重新分配成功\n");
    // 5. 释放所有对象
    for (int i = 0; i < 100; i++) {
        slub_cache_free(&cache, objs[i]);
    }
    cprintf("释放成功\n");
    cprintf("SLUB cache test passed!\n");
}
