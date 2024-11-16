#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

// 页面链表，管理所有页面
extern list_entry_t pra_list_head, *curr_ptr;

// 初始化LRU算法
static int
_lru_init_mm(struct mm_struct *mm) {
    list_init(&pra_list_head);
    curr_ptr = &pra_list_head;  // 当前指针初始化为链表头
    mm->sm_priv = &pra_list_head;  // 将链表头存储在 mm->sm_priv
    return 0;
}

// 将页面标记为可交换
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    list_entry_t *entry = &(page->pra_page_link);

    assert(entry != NULL && head != NULL);
    // 插入到队列尾部，表示最近使用
    list_add(head, entry);
    return 0;
}

// 选择换出的页面
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) {  // 传递被选择作为被替换的页面的地址
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);
    list_entry_t *entry = list_next(head);
    // 遍历链表查找页面是否已存在
    while (entry != head) {
        struct Page *page = le2page(entry, pra_page_link);  // 当前页面
        // 如果找到当前需要的页面，删除并返回
        cprintf("curr_ptr %p",entry);
        if (page == *ptr_page) {
            list_del(entry);  // 从链表中移除该页面
            return 0;  // 然后不需要作任何事
        }
        entry = list_next(entry); // 移动到下一个页面
    }
    // 如果未找到该页面，选择尾部页面
    entry = list_prev(head); // 尾部页面（最久未使用）
    cprintf("curr_ptr %p",entry);
    if (entry != head) {
        *ptr_page = le2page(entry, pra_page_link); // 获取被替换的页面
        list_del(entry); // 从链表中移除尾部页面
        return 0;
    }
    return 0;
}

// 测试 LRU 算法的正确性
static int
_lru_check_swap(void) {
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 4);  // 第一次访问页面 c，产生缺页中断

    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 4);  // 页面 a 已在内存，无缺页中断

    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 4);  // 页面 d 已在内存，无缺页中断

    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 4);  // 页面 b 已在内存，无缺页中断

    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 5);  // 页面 e 替换最久未使用的页面，产生缺页中断

    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 5);  // 页面 b 被访问，无缺页中断

    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 6);  // 页面 a 已被替换，再次访问产生缺页中断

    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 7);  // 页面 b 被替换，再次访问产生缺页中断

    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 8);  // 页面 c 被替换，再次访问产生缺页中断

    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 9);  // 页面 d 被替换，再次访问产生缺页中断

    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 10); // 页面 e 被替换，再次访问产生缺页中断

    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a); // 页面 a 被正确加载到内存
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 11); // 页面 a 替换后，再次访问产生缺页中断

    return 0;
}


// LRU算法初始化
static int
_lru_init(void) {
    return 0;
}

// 标记页面不可交换
static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr) {
    return 0;
}

// 处理定时器事件
static int
_lru_tick_event(struct mm_struct *mm) {
    return 0;
}

// 定义LRU换页算法的swap_manager结构
struct swap_manager swap_manager_lru = {
    .name            = "lru swap manager",
    .init            = &_lru_init,
    .init_mm         = &_lru_init_mm,
    .tick_event      = &_lru_tick_event,
    .map_swappable   = &_lru_map_swappable,
    .set_unswappable = &_lru_set_unswappable,
    .swap_out_victim = &_lru_swap_out_victim,
    .check_swap      = &_lru_check_swap,
};