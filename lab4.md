#  lab4

##  练习1

按照指导书和注释的提示，将`state`设为`PROC_UNINIT`，`pid`设为-1，`cr3`设置为`boot_cr3`，其余需要初始化的变量中，指针设为`NULL`，变量设置为0，具体实现方式如下：
```c
proc->state = PROC_UNINIT;
proc->pid = -1;
proc->runs = 0;
proc->kstack = 0;
proc->need_resched = 0;
proc->parent = NULL;
proc->mm = NULL;
memset(&(proc->context), 0, sizeof(struct context));
proc->tf = NULL;
proc->cr3 = boot_cr3;
proc->flags = 0;
memset(proc->name, 0, PROC_NAME_LEN + 1);
```

`struct context context`:

**成员变量含义**：context中保存了进程执行的上下文，也就是几个关键的寄存器的值，这些寄存器的值用于在进程切换中还原之前进程的运行状态。

**在本实验的作用**：在通过`proc_run`切换到CPU上运行时，需要调用`switch_to`将原进程的寄存器保存，以便下次切换回去时读出，保持之前的状态。

`struct trapframe *tf`:


**成员变量含义**：`trapframe` 是一个用于保存中断/异常发生时 CPU 状态的结构体，它保存了中断时的寄存器值、错误码、中断号以及进程的堆栈等信息.

**在本实验的作用**：`tf`里保存了进程的中断帧。当进程从用户空间跳进内核空间的时候，进程的执行状态被保存在了中断帧中。系统调用可能会改变用户寄存器的值，我们可以通过调整中断帧来使得系统调用返回特定的值。比如可以利用s0和s1传递线程执行的函数和参数；在创建子线程时，会将中断帧中的a0赋值为s1。

## 扩展练习challenge

相关定义如下：
```c
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);
```

`local_intr_save(intr_flag)` 的核心功能是保存当前中断状态并关闭中断。它调用 `__intr_save() `函数，首先通过读取控制状态寄存器 `sstatus `来检查中断使能位（`SSTATUS_SIE`）是否被设置。如果中断开启，则调用 `intr_disable() `函数关闭中断，同时返回 1 表示中断原先是启用的状态；如果中断未开启，则直接返回 0，表示中断原先是关闭的状态。结果会保存在 `intr_flag`中，用于后续恢复。

`local_intr_restore(intr_flag)` 的作用是根据之前保存的中断状态恢复中断。它调用 `__intr_restore(intr_flag)`，判断传入的标志 `intr_flag `的值。如果标志为 1，表示之前中断是开启的，则调用 `intr_enable()` 恢复中断；如果标志为 0，则不做任何操作，保持中断关闭状态。