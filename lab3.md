# lab3

## 练习1
### 调用的函数或宏：

- **`swap in`**: 页面从磁盘交换区读取并加载到内存。
  
- **`alloc_page`**: 在页面换入时，如果该页面在内存中没有对应的物理页，调用此函数为其分配一个新的物理页面。

- **`assert(result != NULL)`**: 在分配内存或其他资源时，确保操作成功，否则触发断言错误。

- **`get_pte`**: 在换入页面时，调用此函数获取该页面的页表项，如果没有，就创建新的页表项。

- **`local_intr_save`**: 在进行某些关键操作时（如更新页表或进行页面置换），调用此函数确保中断不干扰这些操作。

- **`local_intr_restore`**: 在禁用中断后，调用此函数恢复中断的处理，以避免长时间禁止中断。

- **`swap out`**: 将页面从内存保存到交换区（磁盘）。

- **`swapfs_read`**: 在 swap in 过程中，调用此函数将页面从交换区读取到内存中。

- **`ide_read_secs`**: 在 `swapfs_read` 中，这个函数将磁盘上的交换区数据读取到内存中。

- **`set_page_ref`**: 当页面被加载到内存时，调用此函数增加其引用计数，以管理页面的生命周期。

- **`pte_create`**: 在 `swap in` 过程中，当页面被加载到内存时，调用 `pte_create` 为该页面创建页表项。

- **`page2pa`**: 在 `swap out` 和 `swap in` 过程中，转换页面的虚拟地址为物理地址，便于访问页面数据。

- **`page2ppn`**: 在处理页表时，调用此函数获取页面的物理页号，更新页表。

- **`memset`**: 在页面被加载到内存时，清空页面的数据，确保内存内容的正确性。

- **`KADDR`**: 在 `swap in` 过程中，将从交换区读取的物理地址转换为内核虚拟地址，以便进行访问。

- **`assert(head != NULL)`**: 在链表操作中，确保链表头（FIFO 队列）指针有效，以避免空指针错误。

- **`assert(in_tick == 0)`**: 确保在页面置换过程中没有时钟中断干扰。

- **`list_prev`**: 在 FIFO 算法中，获取链表中最早到达的页面，以便选择要换出的页面。

- **`list_del`**: 在 `swap out` 过程中，删除链表中最早访问的页面，将其从 FIFO 队列中移除。

- **`le2page`**: 在 `list_prev` 返回链表项后，调用此宏将链表项转换为页面结构体，便于访问页面信息。

- **`_fifo_swap_out_victim`**: 用于获得需要换出的页面。查找队尾的页面，作为需要释放的页面。

- **`page_insert`**: 将物理页面映射到进程的虚拟地址空间中。它会更新页表，将虚拟地址与物理地址关联起来，使得程序可以通过虚拟地址访问该物理页面。

- **`_fifo_map_swappable`**: 将最近使用的页面添加到队头。在 `swap_out` 中调用，用于将队尾的页面移动到队头，防止下一次换出失败。

- **`list_add`**: 在 `_fifo_map_swappable()` 时，将页面插入到 FIFO 队列中。

- **`assert((*ptep & PTE_V) != 0)`**: 在访问页面时，确保该页面的页表项是有效的，避免访问无效页表项。

- **`swapfs_write`**: 在页面被换出时，调用此函数将页面的内容写入交换区（磁盘）。

- **`ide_write_secs`**: 在 `swapfs_write` 中，这个函数将数据写入硬盘的交换区扇区。

- **`free page`**: 在 `swap out` 完成后，释放该页面的物理内存。

- **`tlb_invalidate`**: 在页面换入换出后，调用此函数刷新 TLB，确保该页面的映射无效，不再被访问。

---

## 练习2

### 相似原因：
两段代码都是用于获取虚拟地址对应的页表项。第一段代码用于从 GiGa Page 中查找 PDX1 的地址，如果查得的地址不合法则为该页表项分配内存空间；第二段代码用于从 MeGa Page 中查找 PDX0 的地址，如果查得的地址不合法则为该页表项分配内存空间。逻辑相同，不同的只有查找的基地址与页表偏移量所在位数。由于三种页表机制（sv32、sv39、sv48）在虚拟地址位数和页表层级上有所不同，规定好偏移量即可按照同一规则找出对应的页表项。

这种写法好，因为大多数情况下我们只关心最后一级页表，并且只在页表项无效时才创建新的页表。合并操作减少了重复代码和函数调用开销，使代码简洁高效。

---

## 练习3

### 设计实现过程：

- **`swap_in(mm, addr, &page)`**：首先需要根据页表基地址和虚拟地址完成磁盘的读取，写入内存，返回内存中的物理页。

- **`page_insert(mm->pgdir, page, addr, perm)`**：然后完成虚拟地址和内存中物理页的映射。

- **`swap_map_swappable(mm, addr, page, 0)`**：最后设置该页面是可交换的。

### 潜在作用：

在页替换算法中，页目录项和页表项的有效性决定了页面是否在内存中。当页表项无效时，说明该页面未加载到内存中，操作系统会触发缺页异常并选择进行页面置换。页目录项和页表项的映射关系允许操作系统快速定位到对应的物理页面，从而执行页面替换或加载操作。

### 页访问异常：

`trap` --> `trap_dispatch` --> `pgfault_handler` --> `do_pgfault`

根据 stvec 寄存器的地址，控制转移到中断处理程序，即 trap.c 文件中的 `trap` 函数。

在 `trap_dispatch` 函数中，针对不同的异常类型，进一步跳转到相应的处理函数。对于页访问异常，会跳转到 `exception_handler` 函数，在这里，针对缺页异常（`CAUSE_LOAD_ACCESS`）进行处理。

接着，控制会转到 `pgfault_handler`，然后进入 `do_pgfault` 函数，具体处理页错误（page fault）。

如果页错误处理成功，系统会根据异常时的地址返回并继续执行发生异常的指令。如果无法成功处理缺页异常，则会输出 `unhandled page fault`，表示无法处理该异常。

### 对应关系：

Page 结构体数组的每一项与页表中的页表项（PTE）有对应关系。每个页表项存储一个物理地址，该地址指向实际的物理页面，而物理页面在内存中有对应的 Page 结构体项。操作系统通过页表项中的物理地址，间接访问 Page 数组中的对应项，从而管理物理内存。

页目录项（PDE）不直接对应 Page 结构体，它主要负责指向页表，页表项则通过物理地址间接映射到 Page 结构体。这样，操作系统通过页表项中的物理地址来访问和管理物理页面。

## 练习三
### 设计实现过程：

1. **初始化**：在初始化时，创建一个空的页面链表，并设置一个指针`curr_ptr`指向链表的头部。这个指针将用于追踪Clock算法中的当前位置。

2. **页面映射**：当一个新页面被映射到内存时，将其添加到链表的末尾，并设置其`visited`标志为1。

3. **页面替换**：当需要替换一个页面时，从链表头开始，即最早进入的物理页面，沿着链表查找。如果当前页面的`visited`标志为0，那么这个页面就是替换的候选页面。如果`visited`标志为1，则将其设置为0，并继续查找。如果遍历完整个链表都没有找到`visited`标志为0的页面，则重新从链表头部开始查找。

### Clock算法与FIFO算法的不同：

1. 页面选择策略：
FIFO算法简单地选择最早进入内存的页面进行替换，不考虑页面的使用情况。
而Clock算法则考虑了页面的访问情况，通过`visited`标志来决定是否替换一个页面。

2. 性能：
FIFO算法可能会导致频繁访问的页面被替换，从而降低性能。
Clock算法通过模拟LRU（最近最少使用）算法的行为，更倾向于保留最近被访问过的页面，从而可能提供更好的性能。

3. Belady's Anomaly：
FIFO算法可能会遭受Belady's Anomaly，即增加更多的内存页面反而可能导致更多的页面错误。
Clock算法由于其页面选择策略，不太可能遭受Belady's Anomaly。

## 练习五
### 采用“一个大页”的页表映射方式，相比分级页表的好处和优势

1. **减少页表数量**：大页内存使用更大的页面，减少了页表的数量，简化了内存管理结构。
2. **提高 TLB 效率**：大页内存可以显著提高TLB（Translation Lookaside Buffer）的命中率，减少了TLB缓存失效的次数，从而提高内存访问效率。
3. **降低内存管理开销**：由于减少了页表的数量，大页内存降低了内存管理的开销，这对于处理大内存需求的应用程序尤为重要。
4. **改善内存访问性能**：大页内存有助于提高内存访问性能，特别是在需要大量数据传输的场景下。

### 采用大页页表映射方式的坏处和风险

1. **内存内碎片**：操作系统申请内存时总是申请一大块内存，哪怕实际只需要很小的内存，导致大页内存得不到充分利用。
2. **内存浪费**：如果数据比较小，或小文件较多，使用大页单位来分配内存可能会造成内存的浪费。
3. **静态大页配置复杂**：静态大页需要预先分配并可能需要重启主机才能生效。
4. **系统性能风险**：如果大页分配不当，可能会造成严重问题，如大页未能使用导致的内存浪费，系统内存不足或者交换过多，以及极高的系统CPU使用率。
5. **对小内存需求不友好**：对于只需要小块内存的应用，大页可能会导致内存使用效率降低。

## Challenge：LRU页替换算法

### 1. 实验目的
通过实现LRU页面置换算法，进一步理解代码框架的同时，理解操作系统的设计思想和部分实现细节，
同时探索LRU算法在优化页面命中率和减少页面错误方面的优势。
实验旨在验证LRU算法如何结合全局和局部访问模式，智能选择页面进行置换，从而提升内存管理效率，并分析其适用场景和局限性。

### 2、LRU算法概述

LRU算法是页面置换的一种优化方法，它的核心思想是根据页面
是否被频繁访问来智能选择被替换的页面。与传统的页面置换算法如FIFO和CLOCK不同，
LRU算法通过对每个页面访问状态的精确跟踪，结合全局和局部的页面访问模式，动态调整页面替换策略，从而提升系统的页面访问命中率。

### 3、主要数据结构与思路来源

- **双向链表**：用于维护当前内存中已加载的页面。

按照FIFO算法的思路，我们通过_init_mm函数中进行初始化，在_map_swappable函数中将新换进的节点加入到列表的尾部，
在_swap_out_victim函数中将队列尾部的节点替换出去。其实我们要实现的LRU算法就是在替换节点的时候，先遍历我们的链表，
如果里面有当前加入的节点，我们就只需要将其从链表中删除即可，不需要再将尾部的剔除。
那么思路就已经明确了，我们重点关注的就是lru_swap_out_victim函数部分，在其中遍历好节点。

### 4、算法设计

首先就是与实验二类似的新建文件的过程，这里有特别需要注意的地方是加入extern时，要留出一个不加，实验二中default内有一个free_area所以其余的都加，
但是在实验三中default文件中没有pra_list_head，所以要注意留出来一个。

#### 4.1 初始化

初始化阶段，算法首先创建一个页面队列（双向链表）来存储所有内存中的页面，这里的基本思路与FIFO算法是一致的。

```c
static int
_lru_init_mm(struct mm_struct *mm) {
    list_init(&pra_list_head);
    curr_ptr = &pra_list_head;  // 当前指针初始化为链表头
    mm->sm_priv = &pra_list_head;  // 将链表头存储在 mm->sm_priv
    return 0;
}
```

#### 4.2 页面映射

在页面映射阶段，算法需要将新的页面标记为可交换，并加入到页面队列中。具体来说，当一个页面被映射为可交换时，
会被插入到页面队列的头部，表示该页面是最新被访问的。每当页面被访问时，它的`visited`标志会被更新为1，表示该页面已被访问。

具体实现如下，与FIFO算法的实现也是一致的：

```c
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    list_entry_t *entry = &(page->pra_page_link);

    assert(entry != NULL && head != NULL);
    // 插入到队列尾部，表示最近使用
    list_add(head, entry);
    // 将页面的visited标志置为1，表示该页面已被访问
    page->visited = 1;
    return 0;
}
```

#### 4.3 页面置换
这个是重点部分，我们分段细细解析：

4.3.1
```c
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) // 传递被选择作为被替换的页面的地址
```
函数参数：
- **mm**：指向内存管理结构体mm_struct的指针。该结构体包含了当前进程的内存管理信息。
- **ptr_page**：指向Page的指针，代表需要被替换的页面。通过这个参数，函数可以将被替换的页面返回给调用者这个是重点。
- **in_tick**：指示当前是否处于定时器中断事件的标志。这里我实际上按照FIFO文件的用法将其使用了，就只是用了assert检查。

4.3.2

```c
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
```

4.3.3

该部分遍历整个页面链表，查找是否存在当前需要替换的页面。通过`list_next`函数，逐个访问链表中的页面。
如果找到了目标页面，则通过`list_del`函数从链表中移除该页面，并将该页面的指针返回给调用者，表示无需换出该页面。

```c
    // 如果未找到该页面，选择尾部页面
    entry = list_prev(head); // 尾部页面（最久未使用）
    cprintf("curr_ptr %p",entry);
    if (entry != head) {
        *ptr_page = le2page(entry, pra_page_link); // 获取被替换的页面
        list_del(entry); // 从链表中移除尾部页面
        return 0;
    }
    return 0;
```
如果链表中没有找到目标页面，则选择链表尾部的页面进行替换。由于尾部页面是最久未使用的页面，符合LRU算法的要求。
通过`list_prev`获取链表尾部的元素，利用`le2page`宏获取对应的`Page`结构，接着使用`list_del`移除尾部页面。

#### 4.3 测试样例
对于新的算法，我们还要编写新的测试样例，具体如下：
```c
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
```

后续的内容就是按部就班将代码复制过来并且更改命名即可。

### 5、总结
#### 5.1 算法性能对比

- **FIFO**：由于其固定的页面替换规则，容易发生Belady's Anomaly，性能不稳定。
- **CLOCK**：改进了FIFO，使用环形指针选择页面，性能比FIFO略好，但依然无法避免某些不必要的页面替换。
- **LRU**：通过结合全局和局部策略，减少了页面替换的频率，适用于高负载和高局部性的场景。

通过本次实验，我们成功实现了LRU页面置换算法，包括页面初始化、页面映射、页面替换等核心环节，并通过实验测试验证了其在实际场景中的有效性。
LRU算法结合了全局和局部页面访问策略，能够在复杂的页面访问模式下有效减少页面错误率。

#### 5.2 优势分析

- **结合全局与局部策略**：LRU算法通过追踪每个页面的访问状态，动态调整替换策略，能够适应不同的页面访问模式。
- **高效页面利用**：通过标记和循环指针机制，LRU算法能有效区分高频访问页面和低频访问页面，优先替换低频页面，从而提高了内存利用率。
- **降低页面错误率**：LRU算法较FIFO算法更能避免Belady's Anomaly的发生，比CLOCK算法更加智能化，从而在实际场景中大幅度降低页面错误率。

#### 5.3 不足之处

- **算法复杂度较高**：LRU算法需要维护页面访问标志，并在页面队列中循环查找合适的替换页面，
  相较于FIFO和CLOCK算法，时间复杂度和实现复杂度均有所增加。
- **性能开销**：在处理大量页面时，频繁的链表操作和访问标志更新可能带来一定的性能开销，对系统资源占用较高。
- **适用性限制**：虽然LRU算法在局部性强的页面访问模式下表现优异，但在高度随机的访问模式下，其性能提升不明显。

通过本次实验，我们加深了对页面置换算法的理解，对操作系统课上学习的内容印象进一步加深，同时也对我们这一系列的实验也有了更为深刻的了解。

