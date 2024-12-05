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

## 练习2

### 设计实现过程

#### 1. 分配进程控制块（proc_struct）

首先，通过调用`alloc_proc`函数分配一个新的进程控制块（`proc_struct`）。这个结构体记录了进程的所有必要信息，包括状态、PID、内核栈、内存管理信息等。

#### 2. 分配内核栈

使用`setup_kstack`函数为新进程分配内核栈。内核栈是进程执行时用于保存中断帧和上下文切换帧的内存区域。

#### 3. 复制内存管理信息

如果`clone_flags`不包含`CLONE_VM`，则调用`copy_mm`函数复制父进程的内存管理信息，否则新进程将共享父进程的内存空间。

#### 4. 设置trapframe和上下文

通过`copy_thread`函数设置新进程的trapframe和上下文，这是进程执行的起点。

#### 5. 插入进程列表和哈希表

新进程的`proc_struct`被插入到进程列表和哈希表中，以便通过PID快速查找。

#### 6. 设置进程状态

调用`wakeup_proc`函数将新进程的状态设置为`PROC_RUNNABLE`，使其成为可调度的。

#### 7. 返回新进程的PID

最后，返回新进程的PID，完成fork操作。

### 分析：uCore是否给每个新fork的线程一个唯一的ID

uCore确实为每个新fork的线程分配了一个唯一的ID。以下是分析和理由：

 **PID生成机制**：uCore通过`get_pid`函数生成一个唯一的PID。这个函数使用了一个循环，从`MAX_PID`开始递减，直到找到一个未被使用的PID。这种方法确保了PID的唯一性，因为每个PID只被分配一次，并且在进程退出后不会被立即重用。

 **哈希表和进程列表**：uCore使用哈希表和进程列表来管理所有进程。哈希表基于PID进行索引，这使得通过PID查找进程变得非常快速。由于每个进程都有一个唯一的PID，因此哈希表中不会有冲突。

 **进程状态管理**：uCore中的进程状态管理也依赖于每个进程有一个唯一的PID。例如，当一个进程退出时，它的状态会被设置为`PROC_ZOMBIE`，父进程需要通过PID来回收资源。
 ## 练习3

### 实验要求
根据提示完成`proc_run`函数的编写部分。

### 实验过程
`proc_run`函数用于切换进程。调用时判断如果当前进程不是即将前往的进程，就执行切换过程。特别需要注意的就是在切换过程中，我们要确保进程不受到正在运行程序的干扰，所以要对中断状态进行管理，所幸实验已经封装好了local_intr_save与local_intr_restore函数。所以我们先用下面的框架对进程进行保存：

```
c
    unsigned long intr_flag;
    local_intr_save(intr_flag);
    // 在这里切换进程
    local_intr_restore(intr_flag);
```

切换进程过程中，框架为我们准备好了switch_to函数，它能够将前一个进程的数据保存到中断帧中，这样进程切换回来时信息就得到了保存。只是需要特别注意的是，这个函数的传参是引用类型，所以为了保护current，我们引入了temp来予以保存。按照这一思路实现的代码就是：

```
c
    struct proc_struct * temp = current;
    current = proc;
    lcr3(current->cr3);
    switch_to(&(temp->context),&(proc->context));
```

综合起来，整个函数为：

```
c
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        unsigned long intr_flag;  // 保存中断状态
        bool intr_flag;
        local_intr_save(intr_flag);
        //保存当前进程的上下文，并切换到新进程
        struct proc_struct * temp = current;//将当前进程保存到临时变量 temp，以便之后恢复其上下文
        current = proc;
        lcr3(current->cr3);
        switch_to(&(temp->context),&(proc->context));
        local_intr_restore(intr_flag);
    }
}
```   

### 问题回答
本次实验总共创建了两个线程，暂且将其标记为0号与1号进程，0号进程实际上是“如运行”，由于其need_resched参数被置为了1,所以一运行就匆忙地切换到了1号进程。



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
