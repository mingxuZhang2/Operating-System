#ifndef __KERN_MM_BUDDY_SYSTEM_PMM_H__
#define __KERN_MM_BUDDY_SYSTEM_PMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>

#define MAX_ORDER       10

extern const struct pmm_manager buddy_pmm_manager;

typedef struct {
    list_entry_t free_list[MAX_ORDER + 1];
    unsigned int nr_free[MAX_ORDER + 1];
} BuddySystem;

void buddy_init(void);
void buddy_init_memmap(struct Page *base, size_t n);
struct Page *buddy_alloc_pages(size_t n);
void buddy_free_pages(struct Page *base, size_t n);
size_t buddy_nr_free_pages(void);
void buddy_check(void);

#endif /* !__KERN_MM_BUDDY_SYSTEM_PMM_H__ */
