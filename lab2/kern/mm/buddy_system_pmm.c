#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <defs.h>
#include <error.h>
#include <pmm.h>
#include <buddy_system_pmm.h>

#define MAX_ORDER       10
#define BUDDY_END(addr, order) ((addr) + (1 << (order)))


BuddySystem buddy_system;

// Helper functions
static inline int order2index(unsigned int order) {
    return MAX_ORDER - order;
}

static inline unsigned int index2order(int index) {
    return MAX_ORDER - index;
}

static inline struct Page *addr2page(uintptr_t addr) {
    return pa2page(addr);
}

static inline uintptr_t page2addr(struct Page *page) {
    return page2pa(page);
}

void
buddy_init_memmap(struct Page *base, size_t n) {
    uintptr_t begin_addr = page2addr(base);
    while (n) {
        int order = 0;
        size_t order_size;

        while ((order < MAX_ORDER) && (1U << (order + 1)) <= n) {
            order++;
        }
        order_size = 1U << order;

        struct Page* p = addr2page(begin_addr);
        p->property = order;
        SetPageProperty(p);

        list_add(&buddy_system.free_list[order2index(order)], &(p->page_link));
        buddy_system.nr_free[order2index(order)]++;

        begin_addr += order_size * PGSIZE;
        n -= order_size;
    }
}

void
buddy_init(void) {
    int i;
    for (i = 0; i <= MAX_ORDER; i++) {
        list_init(&buddy_system.free_list[i]);
        buddy_system.nr_free[i] = 0;
    }
}

size_t
buddy_nr_free_pages(void) {
    int i;
    size_t ret = 0;
    for (i = 0; i <= MAX_ORDER; i++) {
        ret += buddy_system.nr_free[i] * (1U << index2order(i));
    }
    return ret;
}


struct Page *
buddy_alloc_pages(size_t n) {
    cprintf("There is before!\n");
    for (int i = 0; i <= MAX_ORDER; i++) {
        cprintf("Order %d: %d free blocks\n", index2order(i), buddy_system.nr_free[i]);
    }
    int order = 0;  //order=i 时 一块儿大小是2^i
    while ((1U << order) < n) {
        order++;
    }
    int index = order2index(order);
    cprintf("index:%d\n",index);
    for (; index >= 0; index--) {
        cprintf("Order %d: %u free blocks\n", index2order(index), buddy_system.nr_free[index]);
        if (buddy_system.nr_free[index]>0) {
            cprintf("The start is :%d\n",index2order(index));
            list_entry_t *le = list_next(&buddy_system.free_list[index]);
            list_del(le);
            buddy_system.nr_free[index]--;
            
            struct Page *page = le2page(le, page_link);
            unsigned int i;
            
            for (i = index2order(index); i > order; i--) {
                list_entry_t *next_list = &buddy_system.free_list[order2index(i - 1)];
                struct Page *buddy = addr2page(page2addr(page) ^ (1U << (i - 1)));
                list_add(next_list, &(buddy->page_link));
                buddy_system.nr_free[order2index(i - 1)]++;
                buddy->property=i-1;
               // cprintf("alloc:buddy->property: and i is:%d %d\n",buddy->property,i);
            }
            cprintf("There is after!\n");
            for (int i = 0; i <= MAX_ORDER; i++) {
                cprintf("Order %d: %d free blocks\n", index2order(i), buddy_system.nr_free[i]);
            }
            return page;
        }
    }
    return NULL;
}

void
buddy_free_pages(struct Page *base, size_t n) {
    cprintf("There is before Free!\n");
    for (int i = 0; i <= MAX_ORDER; i++) {
        cprintf("Order %d: %d free blocks\n", index2order(i), buddy_system.nr_free[i]);
    }
    int order = 0;
    while ((1U << order) < n) order++;
    struct Page *p = base;
    while (order <= MAX_ORDER) {
        struct Page *buddy = addr2page(page2addr(p) ^ (1U << order));
        cprintf("Before free ,the nr_free is:%d\n",buddy_system.nr_free[order2index(order)]);
        cprintf("Buddy:%d\n",buddy->property);
        if (PageProperty(buddy) && buddy->property == order && buddy_system.nr_free[order2index(order)]) {
            cprintf("merge!\n");
            list_del(&(buddy->page_link));
            buddy_system.nr_free[order2index(order)]--;
            p = (p < buddy) ? p : buddy;
            order++;
        } else {
            cprintf("just add!\n");
            p->property = order;
            SetPageProperty(p);
            list_add(&buddy_system.free_list[order2index(order)], &(p->page_link));
            buddy_system.nr_free[order2index(order)]++;
            break;
        }
    }
    cprintf("There is after free!\n");
    for (int i = 0; i <= MAX_ORDER; i++) {
        cprintf("Order %d: %d free blocks\n", index2order(i), buddy_system.nr_free[i]);
    }

}
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

void buddy_check(void) {
    cprintf("Buddy system initialized.\n");
    struct Page *p0, *p1, *p2;

    p0 = buddy_alloc_pages(1);
    if(p0 != NULL) {
        cprintf("p0 allocated successfully.\n");
    } else {
        cprintf("p0 allocation failed.\n");
    }
    assert(p0 != NULL);
    
    p1 = buddy_alloc_pages(2);
    if(p1 != NULL) {
        cprintf("p1 allocated 2 pages successfully.\n");
    } else {
        cprintf("p1 allocation of 2 pages failed.\n");
    }
    if(1){getchar();}
    assert(p1 != NULL);

    p2 = buddy_alloc_pages(3);
    if(p2 != NULL) {
        cprintf("p2 allocated 3 pages successfully.\n");
    } else {
        cprintf("p2 allocation of 3 pages failed.\n");
    }
    assert(p2 != NULL);
    
    buddy_free_pages(p0, 1);
    cprintf("p0 freed.\n");

    buddy_free_pages(p1, 2);
    cprintf("p1's 2 pages freed.\n");

    p1 = buddy_alloc_pages(3);
    if(p1 != NULL) {
        cprintf("p1 allocated 3 pages successfully after previous free.\n");
    } else {
        cprintf("p1 allocation of 3 pages failed after previous free.\n");
    }
    //assert(p1 != NULL);
    
    buddy_free_pages(p1, 3);
    cprintf("p1's 3 pages freed.\n");

    buddy_free_pages(p2, 3);
    cprintf("p2's 3 pages freed.\n");

    size_t free_pages = buddy_nr_free_pages();
    cprintf("Total free pages: %zu\n", free_pages);
    //assert(free_pages == 9);*/
}
