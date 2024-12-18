#  lab5
## 扩展练习1
### 实现源码
在vmm.c中将dup_mmap中的share变量的值改为1，启用共享。
```c
int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    ...
    bool share = 1;
}
```
在pmm.c中为copy_range添加对共享的处理，如果share为1，那么将子进程的页面映射到父进程的页面。由于两个进程共享一个页面之后，无论任何一个进程修改页面，都会影响另外一个页面，所以需要子进程和父进程对于这个共享页面都保持只读。
```c
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,
               bool share) {
                if (*ptep & PTE_V) {
                    ...
                    if (share) {
                page_insert(from,page,start,perm&(~PTE_W));
                ret = page_insert(to,page,start,perm&(~PTE_W));
            } else {
                struct Page *npage=alloc_page();
                assert(npage!=NULL);
                uintptr_t src_kvaddr = page2kva(page);
                uintptr_t dst_kvaddr = page2kva(npage);
                memcpy((void *)dst_kvaddr, (const void *)src_kvaddr, PGSIZE); // (3) memory copy
                ret = page_insert(to, npage, start, perm); // (4) build the map
            }
                }
               }

```

当程序尝试修改只读的内存页面的时候，将触发Page Fault中断，在错误代码中P=1,、W/R=1。因此，当错误代码最低两位都为1的时候，说明进程访问了共享的页面，内核需要重新分配页面、拷贝页面内容、建立映射关系。

```c
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
if (*ptep == 0) { 
    ...
}else if((*ptep&PTE_V)&&(error_code&3==3)){
        struct Page*page=pte2page(*ptep);
        struct Page*npage=pgdir_alloc_page(mm->pgdir,addr,perm);
        uintptr_t src_kvaddr=page2kva(page);
        uintptr_t dst_kvaddr=page2kva(npage);
        memcpy(dst_kvaddr,src_kvaddr,PGSIZE);
    }else{
        ...
    }
}
```
### 执行结果

可以看到Copy on Write正确执行。

![alt text](image-5.png)

## 扩展练习2
在本次实验中，用户程序在编译时被静态链接到内核中，并在链接过程中就已确定了程序的起始位置和大小。当执行 user_main() 函数时，通过宏 KERNEL_EXECVE 调用 kernel_execve() 函数，从而触发加载程序的操作，进而调用 load_icode() 函数将用户程序加载到内存中。这种方式实现了通过一个内核进程将整个用户程序直接加载到内存。

而在我们常见的操作系统中，用户程序通常存储在外部存储设备上，作为独立的文件存在。当需要执行某个程序时，操作系统会从磁盘等外部存储介质动态地加载该程序到内存中。

我们之所以采用这种加载方式，是因为 ucore 操作系统并未实现硬盘支持和文件系统。出于简化设计和教学的考虑，将用户程序直接编译到内核中可以有效减少实现的复杂度。
