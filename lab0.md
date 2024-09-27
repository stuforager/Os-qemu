### lab0.5:练习1

#### 通过x/10i $pc指令，可以查看当前pc的后面十条指令的内容，发现从0x1000处开始，执行了一系列的复位（初始化）操作，主要功能有：

1、初始化寄存器：设置一些必要的寄存器状态，例如栈指针（sp）和全局指针（gp），还有一些通用寄存器的值，通过info register指令，可以查看当前寄存器的值，全都被初始化成0。

2、配置中断：准备中断控制器，设置中断向量等。

3、调用 Bootloader：通常，这段代码会初始化硬件后，跳转到 bootloader 的入口点（如 0x80000000）以加载内核。

4、设置内存：可能会进行内存的基本检查和设置，确保运行环境正常。

#### 刚才在复位结束后，跳转到了0x80000000处。可以通过x/10i 0x80000000指令，可以查看0x80000000地址的后十条指令的内容，从这里的代码开始，是bootloader（本次实验的固件是OpenSBI）内容，主要功能有：
1、初始化硬件和设置环境：执行一些指令以获取处理器的状态信息（如 hart ID），并配置必要的硬件资源。

2、加载内核镜像：从存储设备（如闪存或其他存储介质）读取内核镜像，并将其加载到内存中的 0x80200000 地址。

3、地址计算和数据准备：通过地址计算（如 auipc 和 addi）确定内存位置，确保内核镜像能够正确地放置在预定位置。

4、验证和条件跳转：在加载内核前，执行一些验证操作，确保所有条件都满足，然后决定是否继续加载或跳转到特定的执行路径。

5、跳转到内核入口点：最终，通过跳转指令（jr）转移控制权到内核的入口点（0x80200000），以开始执行内核。

### lab1
