
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <buf>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43e60613          	addi	a2,a2,1086 # ffffffffc0206478 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	650010ef          	jal	ra,ffffffffc020169a <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	65e50513          	addi	a0,a0,1630 # ffffffffc02016b0 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	75f000ef          	jal	ra,ffffffffc0200fc4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	11e010ef          	jal	ra,ffffffffc02011c4 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	0e8010ef          	jal	ra,ffffffffc02011c4 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	59450513          	addi	a0,a0,1428 # ffffffffc02016d0 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	59e50513          	addi	a0,a0,1438 # ffffffffc02016f0 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	54e58593          	addi	a1,a1,1358 # ffffffffc02016ac <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0201710 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <buf>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	5b650513          	addi	a0,a0,1462 # ffffffffc0201730 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2f258593          	addi	a1,a1,754 # ffffffffc0206478 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	5c250513          	addi	a0,a0,1474 # ffffffffc0201750 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6dd58593          	addi	a1,a1,1757 # ffffffffc0206877 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	5b450513          	addi	a0,a0,1460 # ffffffffc0201770 <etext+0xc4>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	5d660613          	addi	a2,a2,1494 # ffffffffc02017a0 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	5e250513          	addi	a0,a0,1506 # ffffffffc02017b8 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	5ea60613          	addi	a2,a2,1514 # ffffffffc02017d0 <etext+0x124>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	60258593          	addi	a1,a1,1538 # ffffffffc02017f0 <etext+0x144>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	60250513          	addi	a0,a0,1538 # ffffffffc02017f8 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	60460613          	addi	a2,a2,1540 # ffffffffc0201808 <etext+0x15c>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	62458593          	addi	a1,a1,1572 # ffffffffc0201830 <etext+0x184>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	5e450513          	addi	a0,a0,1508 # ffffffffc02017f8 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	62060613          	addi	a2,a2,1568 # ffffffffc0201840 <etext+0x194>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	63858593          	addi	a1,a1,1592 # ffffffffc0201860 <etext+0x1b4>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	5c850513          	addi	a0,a0,1480 # ffffffffc02017f8 <etext+0x14c>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	60650513          	addi	a0,a0,1542 # ffffffffc0201870 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	60c50513          	addi	a0,a0,1548 # ffffffffc0201898 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	666c0c13          	addi	s8,s8,1638 # ffffffffc0201908 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	61690913          	addi	s2,s2,1558 # ffffffffc02018c0 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	61648493          	addi	s1,s1,1558 # ffffffffc02018c8 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	614b0b13          	addi	s6,s6,1556 # ffffffffc02018d0 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	52ca0a13          	addi	s4,s4,1324 # ffffffffc02017f0 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	276010ef          	jal	ra,ffffffffc0201546 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	622d0d13          	addi	s10,s10,1570 # ffffffffc0201908 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	372010ef          	jal	ra,ffffffffc0201666 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	35e010ef          	jal	ra,ffffffffc0201666 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	33e010ef          	jal	ra,ffffffffc0201684 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	300010ef          	jal	ra,ffffffffc0201684 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	55250513          	addi	a0,a0,1362 # ffffffffc02018f0 <etext+0x244>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	57650513          	addi	a0,a0,1398 # ffffffffc0201950 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	3a850513          	addi	a0,a0,936 # ffffffffc0201798 <etext+0xec>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	1f4010ef          	jal	ra,ffffffffc0201614 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	fe07b923          	sd	zero,-14(a5) # ffffffffc0206418 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	54250513          	addi	a0,a0,1346 # ffffffffc0201970 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	1ce0106f          	j	ffffffffc0201614 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	1aa0106f          	j	ffffffffc02015fa <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	1da0106f          	j	ffffffffc020162e <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	51250513          	addi	a0,a0,1298 # ffffffffc0201990 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	51a50513          	addi	a0,a0,1306 # ffffffffc02019a8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	52450513          	addi	a0,a0,1316 # ffffffffc02019c0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	52e50513          	addi	a0,a0,1326 # ffffffffc02019d8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	53850513          	addi	a0,a0,1336 # ffffffffc02019f0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	54250513          	addi	a0,a0,1346 # ffffffffc0201a08 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	54c50513          	addi	a0,a0,1356 # ffffffffc0201a20 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	55650513          	addi	a0,a0,1366 # ffffffffc0201a38 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	56050513          	addi	a0,a0,1376 # ffffffffc0201a50 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	56a50513          	addi	a0,a0,1386 # ffffffffc0201a68 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	57450513          	addi	a0,a0,1396 # ffffffffc0201a80 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	57e50513          	addi	a0,a0,1406 # ffffffffc0201a98 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	58850513          	addi	a0,a0,1416 # ffffffffc0201ab0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	59250513          	addi	a0,a0,1426 # ffffffffc0201ac8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	59c50513          	addi	a0,a0,1436 # ffffffffc0201ae0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	5a650513          	addi	a0,a0,1446 # ffffffffc0201af8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	5b050513          	addi	a0,a0,1456 # ffffffffc0201b10 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	5ba50513          	addi	a0,a0,1466 # ffffffffc0201b28 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	5c450513          	addi	a0,a0,1476 # ffffffffc0201b40 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	5ce50513          	addi	a0,a0,1486 # ffffffffc0201b58 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	5d850513          	addi	a0,a0,1496 # ffffffffc0201b70 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	5e250513          	addi	a0,a0,1506 # ffffffffc0201b88 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	5ec50513          	addi	a0,a0,1516 # ffffffffc0201ba0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	5f650513          	addi	a0,a0,1526 # ffffffffc0201bb8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	60050513          	addi	a0,a0,1536 # ffffffffc0201bd0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	60a50513          	addi	a0,a0,1546 # ffffffffc0201be8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	61450513          	addi	a0,a0,1556 # ffffffffc0201c00 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	61e50513          	addi	a0,a0,1566 # ffffffffc0201c18 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	62850513          	addi	a0,a0,1576 # ffffffffc0201c30 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	63250513          	addi	a0,a0,1586 # ffffffffc0201c48 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	63c50513          	addi	a0,a0,1596 # ffffffffc0201c60 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	64250513          	addi	a0,a0,1602 # ffffffffc0201c78 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	64650513          	addi	a0,a0,1606 # ffffffffc0201c90 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	64650513          	addi	a0,a0,1606 # ffffffffc0201ca8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	64e50513          	addi	a0,a0,1614 # ffffffffc0201cc0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	65650513          	addi	a0,a0,1622 # ffffffffc0201cd8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	65a50513          	addi	a0,a0,1626 # ffffffffc0201cf0 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	72070713          	addi	a4,a4,1824 # ffffffffc0201dd0 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	6a650513          	addi	a0,a0,1702 # ffffffffc0201d68 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	67c50513          	addi	a0,a0,1660 # ffffffffc0201d48 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	63250513          	addi	a0,a0,1586 # ffffffffc0201d08 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	6a850513          	addi	a0,a0,1704 # ffffffffc0201d88 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d2668693          	addi	a3,a3,-730 # ffffffffc0206418 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	6a050513          	addi	a0,a0,1696 # ffffffffc0201db0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	60e50513          	addi	a0,a0,1550 # ffffffffc0201d28 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	67450513          	addi	a0,a0,1652 # ffffffffc0201da0 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_init>:
static struct Page* useable_page_base;

static void
buddy_init(void) {

}
ffffffffc0200802:	8082                	ret

ffffffffc0200804 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return buddy_page[1];
}
ffffffffc0200804:	00006797          	auipc	a5,0x6
ffffffffc0200808:	c1c7b783          	ld	a5,-996(a5) # ffffffffc0206420 <buddy_page>

ffffffffc020080c:	0047e503          	lwu	a0,4(a5)
ffffffffc0200810:	8082                	ret

ffffffffc0200812 <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200812:	c575                	beqz	a0,ffffffffc02008fe <buddy_alloc_pages+0xec>
    if (n > buddy_page[1]){
ffffffffc0200814:	00006817          	auipc	a6,0x6
ffffffffc0200818:	c0c80813          	addi	a6,a6,-1012 # ffffffffc0206420 <buddy_page>
ffffffffc020081c:	00083583          	ld	a1,0(a6)
ffffffffc0200820:	0045e783          	lwu	a5,4(a1)
ffffffffc0200824:	0ca7eb63          	bltu	a5,a0,ffffffffc02008fa <buddy_alloc_pages+0xe8>
    unsigned int index = 1;
ffffffffc0200828:	4705                	li	a4,1
        if (buddy_page[LEFT_CHILD(index)] >= n){
ffffffffc020082a:	0017169b          	slliw	a3,a4,0x1
ffffffffc020082e:	02069793          	slli	a5,a3,0x20
ffffffffc0200832:	83f9                	srli	a5,a5,0x1e
ffffffffc0200834:	97ae                	add	a5,a5,a1
ffffffffc0200836:	0007e783          	lwu	a5,0(a5)
ffffffffc020083a:	0007061b          	sext.w	a2,a4
ffffffffc020083e:	0006871b          	sext.w	a4,a3
ffffffffc0200842:	fea7f4e3          	bgeu	a5,a0,ffffffffc020082a <buddy_alloc_pages+0x18>
        else if (buddy_page[RIGHT_CHILD(index)] >= n){
ffffffffc0200846:	2705                	addiw	a4,a4,1
ffffffffc0200848:	02071693          	slli	a3,a4,0x20
ffffffffc020084c:	01e6d793          	srli	a5,a3,0x1e
ffffffffc0200850:	97ae                	add	a5,a5,a1
ffffffffc0200852:	0007e783          	lwu	a5,0(a5)
ffffffffc0200856:	fca7fae3          	bgeu	a5,a0,ffffffffc020082a <buddy_alloc_pages+0x18>
    unsigned int size = buddy_page[index];
ffffffffc020085a:	02061713          	slli	a4,a2,0x20
ffffffffc020085e:	01e75793          	srli	a5,a4,0x1e
ffffffffc0200862:	95be                	add	a1,a1,a5
ffffffffc0200864:	4198                	lw	a4,0(a1)
    struct Page* new_page = &useable_page_base[index * size - useable_page_num];
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	bca53503          	ld	a0,-1078(a0) # ffffffffc0206430 <useable_page_base>
    buddy_page[index] = 0;
ffffffffc020086e:	0005a023          	sw	zero,0(a1)
    struct Page* new_page = &useable_page_base[index * size - useable_page_num];
ffffffffc0200872:	02e607bb          	mulw	a5,a2,a4
    for (struct Page* p = new_page; p != new_page + size; p++){
ffffffffc0200876:	02071693          	slli	a3,a4,0x20
ffffffffc020087a:	9281                	srli	a3,a3,0x20
ffffffffc020087c:	00269713          	slli	a4,a3,0x2
ffffffffc0200880:	9736                	add	a4,a4,a3
    struct Page* new_page = &useable_page_base[index * size - useable_page_num];
ffffffffc0200882:	00006697          	auipc	a3,0x6
ffffffffc0200886:	bb66a683          	lw	a3,-1098(a3) # ffffffffc0206438 <useable_page_num>
    for (struct Page* p = new_page; p != new_page + size; p++){
ffffffffc020088a:	070e                	slli	a4,a4,0x3
    struct Page* new_page = &useable_page_base[index * size - useable_page_num];
ffffffffc020088c:	9f95                	subw	a5,a5,a3
ffffffffc020088e:	1782                	slli	a5,a5,0x20
ffffffffc0200890:	9381                	srli	a5,a5,0x20
ffffffffc0200892:	00279693          	slli	a3,a5,0x2
ffffffffc0200896:	97b6                	add	a5,a5,a3
ffffffffc0200898:	078e                	slli	a5,a5,0x3
ffffffffc020089a:	953e                	add	a0,a0,a5
    for (struct Page* p = new_page; p != new_page + size; p++){
ffffffffc020089c:	972a                	add	a4,a4,a0
ffffffffc020089e:	00e50c63          	beq	a0,a4,ffffffffc02008b6 <buddy_alloc_pages+0xa4>
ffffffffc02008a2:	87aa                	mv	a5,a0
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008a4:	56f5                	li	a3,-3
ffffffffc02008a6:	00878593          	addi	a1,a5,8
ffffffffc02008aa:	60d5b02f          	amoand.d	zero,a3,(a1)
ffffffffc02008ae:	02878793          	addi	a5,a5,40
ffffffffc02008b2:	fee79ae3          	bne	a5,a4,ffffffffc02008a6 <buddy_alloc_pages+0x94>
    while(index > 0){
ffffffffc02008b6:	0016561b          	srliw	a2,a2,0x1
        buddy_page[index] = MAX(buddy_page[LEFT_CHILD(index)], buddy_page[RIGHT_CHILD(index)]);
ffffffffc02008ba:	c229                	beqz	a2,ffffffffc02008fc <buddy_alloc_pages+0xea>
        index = PARENT(index);
ffffffffc02008bc:	00083683          	ld	a3,0(a6)
ffffffffc02008c0:	0016179b          	slliw	a5,a2,0x1
ffffffffc02008c4:	0017871b          	addiw	a4,a5,1
ffffffffc02008c8:	1782                	slli	a5,a5,0x20
ffffffffc02008ca:	02071593          	slli	a1,a4,0x20
ffffffffc02008ce:	9381                	srli	a5,a5,0x20
ffffffffc02008d0:	01e5d713          	srli	a4,a1,0x1e
ffffffffc02008d4:	078a                	slli	a5,a5,0x2
ffffffffc02008d6:	97b6                	add	a5,a5,a3
ffffffffc02008d8:	9736                	add	a4,a4,a3
ffffffffc02008da:	438c                	lw	a1,0(a5)
ffffffffc02008dc:	4318                	lw	a4,0(a4)
ffffffffc02008de:	00261793          	slli	a5,a2,0x2
ffffffffc02008e2:	0005881b          	sext.w	a6,a1
ffffffffc02008e6:	0007089b          	sext.w	a7,a4
ffffffffc02008ea:	97b6                	add	a5,a5,a3
ffffffffc02008ec:	0108f363          	bgeu	a7,a6,ffffffffc02008f2 <buddy_alloc_pages+0xe0>
ffffffffc02008f0:	872e                	mv	a4,a1
ffffffffc02008f2:	c398                	sw	a4,0(a5)
    }
ffffffffc02008f4:	8205                	srli	a2,a2,0x1
        buddy_page[index] = MAX(buddy_page[LEFT_CHILD(index)], buddy_page[RIGHT_CHILD(index)]);
ffffffffc02008f6:	f669                	bnez	a2,ffffffffc02008c0 <buddy_alloc_pages+0xae>
ffffffffc02008f8:	8082                	ret
        return NULL;
ffffffffc02008fa:	4501                	li	a0,0

ffffffffc02008fc:	8082                	ret
Page* buddy_alloc_pages(size_t n) {
ffffffffc02008fe:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200900:	00001697          	auipc	a3,0x1
ffffffffc0200904:	50068693          	addi	a3,a3,1280 # ffffffffc0201e00 <commands+0x4f8>
ffffffffc0200908:	00001617          	auipc	a2,0x1
ffffffffc020090c:	50060613          	addi	a2,a2,1280 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200910:	04200593          	li	a1,66
ffffffffc0200914:	00001517          	auipc	a0,0x1
ffffffffc0200918:	50c50513          	addi	a0,a0,1292 # ffffffffc0201e20 <commands+0x518>
Page* buddy_alloc_pages(size_t n) {
ffffffffc020091c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020091e:	a8fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200922 <buddy_check>:
static void
buddy_check(void) {
    int all_pages = nr_free_pages();
ffffffffc0200922:	7179                	addi	sp,sp,-48
ffffffffc0200924:	e44e                	sd	s3,8(sp)
ffffffffc0200926:	f406                	sd	ra,40(sp)
ffffffffc0200928:	f022                	sd	s0,32(sp)
ffffffffc020092a:	ec26                	sd	s1,24(sp)
ffffffffc020092c:	e84a                	sd	s2,16(sp)
ffffffffc020092e:	e052                	sd	s4,0(sp)
    struct Page* p0, *p1, *p2, *p3;
ffffffffc0200930:	65a000ef          	jal	ra,ffffffffc0200f8a <nr_free_pages>
ffffffffc0200934:	89aa                	mv	s3,a0
    // 分配过大的页数
    assert(alloc_pages(all_pages + 1) == NULL);
    // 分配两个组页
ffffffffc0200936:	2505                	addiw	a0,a0,1
ffffffffc0200938:	5d4000ef          	jal	ra,ffffffffc0200f0c <alloc_pages>
ffffffffc020093c:	28051263          	bnez	a0,ffffffffc0200bc0 <buddy_check+0x29e>
    p0 = alloc_pages(1);
    assert(p0 != NULL);
ffffffffc0200940:	4505                	li	a0,1
ffffffffc0200942:	5ca000ef          	jal	ra,ffffffffc0200f0c <alloc_pages>
ffffffffc0200946:	842a                	mv	s0,a0
    p1 = alloc_pages(2);
ffffffffc0200948:	24050c63          	beqz	a0,ffffffffc0200ba0 <buddy_check+0x27e>
    cprintf("p0: %p, p1: %p\n", (void *)p0, (void *)p1);
ffffffffc020094c:	4509                	li	a0,2
ffffffffc020094e:	5be000ef          	jal	ra,ffffffffc0200f0c <alloc_pages>
    size_t page_size = sizeof(struct Page);
ffffffffc0200952:	862a                	mv	a2,a0
ffffffffc0200954:	85a2                	mv	a1,s0
    cprintf("p0: %p, p1: %p\n", (void *)p0, (void *)p1);
ffffffffc0200956:	84aa                	mv	s1,a0
    size_t page_size = sizeof(struct Page);
ffffffffc0200958:	00001517          	auipc	a0,0x1
ffffffffc020095c:	51850513          	addi	a0,a0,1304 # ffffffffc0201e70 <commands+0x568>
ffffffffc0200960:	f52ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Size of struct Page: %u bytes\n", page_size);
    assert(p1 == p0 + 2);
ffffffffc0200964:	02800593          	li	a1,40
ffffffffc0200968:	00001517          	auipc	a0,0x1
ffffffffc020096c:	51850513          	addi	a0,a0,1304 # ffffffffc0201e80 <commands+0x578>
ffffffffc0200970:	f42ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200974:	05040793          	addi	a5,s0,80
ffffffffc0200978:	1af49463          	bne	s1,a5,ffffffffc0200b20 <buddy_check+0x1fe>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020097c:	641c                	ld	a5,8(s0)
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc020097e:	8b85                	andi	a5,a5,1
ffffffffc0200980:	12079063          	bnez	a5,ffffffffc0200aa0 <buddy_check+0x17e>
ffffffffc0200984:	641c                	ld	a5,8(s0)
ffffffffc0200986:	8385                	srli	a5,a5,0x1
ffffffffc0200988:	8b85                	andi	a5,a5,1
ffffffffc020098a:	10079b63          	bnez	a5,ffffffffc0200aa0 <buddy_check+0x17e>
ffffffffc020098e:	649c                	ld	a5,8(s1)
    // 再分配两个组页
ffffffffc0200990:	8b85                	andi	a5,a5,1
ffffffffc0200992:	0e079763          	bnez	a5,ffffffffc0200a80 <buddy_check+0x15e>
ffffffffc0200996:	649c                	ld	a5,8(s1)
ffffffffc0200998:	8385                	srli	a5,a5,0x1
ffffffffc020099a:	8b85                	andi	a5,a5,1
ffffffffc020099c:	0e079263          	bnez	a5,ffffffffc0200a80 <buddy_check+0x15e>
    p2 = alloc_pages(1);
    assert(p2 == p0 + 1);
ffffffffc02009a0:	4505                	li	a0,1
ffffffffc02009a2:	56a000ef          	jal	ra,ffffffffc0200f0c <alloc_pages>
    p3 = alloc_pages(8);
ffffffffc02009a6:	02840793          	addi	a5,s0,40
    assert(p2 == p0 + 1);
ffffffffc02009aa:	8a2a                	mv	s4,a0
    p3 = alloc_pages(8);
ffffffffc02009ac:	12f51a63          	bne	a0,a5,ffffffffc0200ae0 <buddy_check+0x1be>
    assert(p3 == p0 + 8);
ffffffffc02009b0:	4521                	li	a0,8
ffffffffc02009b2:	55a000ef          	jal	ra,ffffffffc0200f0c <alloc_pages>
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc02009b6:	14040793          	addi	a5,s0,320
    assert(p3 == p0 + 8);
ffffffffc02009ba:	892a                	mv	s2,a0
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc02009bc:	24f51263          	bne	a0,a5,ffffffffc0200c00 <buddy_check+0x2de>
ffffffffc02009c0:	651c                	ld	a5,8(a0)
ffffffffc02009c2:	8385                	srli	a5,a5,0x1
    // 回收页
ffffffffc02009c4:	8b85                	andi	a5,a5,1
ffffffffc02009c6:	efc9                	bnez	a5,ffffffffc0200a60 <buddy_check+0x13e>
ffffffffc02009c8:	12053783          	ld	a5,288(a0)
ffffffffc02009cc:	8385                	srli	a5,a5,0x1
ffffffffc02009ce:	8b85                	andi	a5,a5,1
ffffffffc02009d0:	ebc1                	bnez	a5,ffffffffc0200a60 <buddy_check+0x13e>
ffffffffc02009d2:	14853783          	ld	a5,328(a0)
ffffffffc02009d6:	8385                	srli	a5,a5,0x1
ffffffffc02009d8:	8b85                	andi	a5,a5,1
ffffffffc02009da:	c3d9                	beqz	a5,ffffffffc0200a60 <buddy_check+0x13e>
    free_pages(p1, 2);
    assert(PageProperty(p1) && PageProperty(p1 + 1));
ffffffffc02009dc:	4589                	li	a1,2
ffffffffc02009de:	8526                	mv	a0,s1
ffffffffc02009e0:	56a000ef          	jal	ra,ffffffffc0200f4a <free_pages>
ffffffffc02009e4:	649c                	ld	a5,8(s1)
ffffffffc02009e6:	8385                	srli	a5,a5,0x1
    assert(p1->ref == 0);
ffffffffc02009e8:	8b85                	andi	a5,a5,1
ffffffffc02009ea:	0c078b63          	beqz	a5,ffffffffc0200ac0 <buddy_check+0x19e>
ffffffffc02009ee:	789c                	ld	a5,48(s1)
ffffffffc02009f0:	8385                	srli	a5,a5,0x1
ffffffffc02009f2:	8b85                	andi	a5,a5,1
ffffffffc02009f4:	c7f1                	beqz	a5,ffffffffc0200ac0 <buddy_check+0x19e>
    free_pages(p0, 1);
ffffffffc02009f6:	409c                	lw	a5,0(s1)
ffffffffc02009f8:	14079463          	bnez	a5,ffffffffc0200b40 <buddy_check+0x21e>
    free_pages(p2, 1);
ffffffffc02009fc:	4585                	li	a1,1
ffffffffc02009fe:	8522                	mv	a0,s0
ffffffffc0200a00:	54a000ef          	jal	ra,ffffffffc0200f4a <free_pages>
    // 回收后再分配
ffffffffc0200a04:	8552                	mv	a0,s4
ffffffffc0200a06:	4585                	li	a1,1
ffffffffc0200a08:	542000ef          	jal	ra,ffffffffc0200f4a <free_pages>
    p2 = alloc_pages(3);
    assert(p2 == p0);
ffffffffc0200a0c:	450d                	li	a0,3
ffffffffc0200a0e:	4fe000ef          	jal	ra,ffffffffc0200f0c <alloc_pages>
    free_pages(p2, 3);
ffffffffc0200a12:	16a41763          	bne	s0,a0,ffffffffc0200b80 <buddy_check+0x25e>
    assert((p2 + 2)->ref == 0);
ffffffffc0200a16:	458d                	li	a1,3
ffffffffc0200a18:	532000ef          	jal	ra,ffffffffc0200f4a <free_pages>
    assert(nr_free_pages() == all_pages >> 1);
ffffffffc0200a1c:	483c                	lw	a5,80(s0)
ffffffffc0200a1e:	14079163          	bnez	a5,ffffffffc0200b60 <buddy_check+0x23e>

ffffffffc0200a22:	2981                	sext.w	s3,s3
ffffffffc0200a24:	566000ef          	jal	ra,ffffffffc0200f8a <nr_free_pages>
ffffffffc0200a28:	4019d993          	srai	s3,s3,0x1
ffffffffc0200a2c:	0d351a63          	bne	a0,s3,ffffffffc0200b00 <buddy_check+0x1de>
    p1 = alloc_pages(129);
    assert(p1 == p0 + 256);
ffffffffc0200a30:	08100513          	li	a0,129
ffffffffc0200a34:	4d8000ef          	jal	ra,ffffffffc0200f0c <alloc_pages>
    free_pages(p1, 256);
ffffffffc0200a38:	678d                	lui	a5,0x3
ffffffffc0200a3a:	80078793          	addi	a5,a5,-2048 # 2800 <kern_entry-0xffffffffc01fd800>
ffffffffc0200a3e:	943e                	add	s0,s0,a5
ffffffffc0200a40:	1a851063          	bne	a0,s0,ffffffffc0200be0 <buddy_check+0x2be>
    free_pages(p3, 8);
ffffffffc0200a44:	10000593          	li	a1,256
ffffffffc0200a48:	502000ef          	jal	ra,ffffffffc0200f4a <free_pages>
}

ffffffffc0200a4c:	7402                	ld	s0,32(sp)
ffffffffc0200a4e:	70a2                	ld	ra,40(sp)
ffffffffc0200a50:	64e2                	ld	s1,24(sp)
ffffffffc0200a52:	69a2                	ld	s3,8(sp)
ffffffffc0200a54:	6a02                	ld	s4,0(sp)
}
ffffffffc0200a56:	854a                	mv	a0,s2

ffffffffc0200a58:	6942                	ld	s2,16(sp)
}
ffffffffc0200a5a:	45a1                	li	a1,8

ffffffffc0200a5c:	6145                	addi	sp,sp,48
}
ffffffffc0200a5e:	a1f5                	j	ffffffffc0200f4a <free_pages>
    // 回收页
ffffffffc0200a60:	00001697          	auipc	a3,0x1
ffffffffc0200a64:	4c068693          	addi	a3,a3,1216 # ffffffffc0201f20 <commands+0x618>
ffffffffc0200a68:	00001617          	auipc	a2,0x1
ffffffffc0200a6c:	3a060613          	addi	a2,a2,928 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200a70:	09c00593          	li	a1,156
ffffffffc0200a74:	00001517          	auipc	a0,0x1
ffffffffc0200a78:	3ac50513          	addi	a0,a0,940 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200a7c:	931ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    // 再分配两个组页
ffffffffc0200a80:	00001697          	auipc	a3,0x1
ffffffffc0200a84:	45868693          	addi	a3,a3,1112 # ffffffffc0201ed8 <commands+0x5d0>
ffffffffc0200a88:	00001617          	auipc	a2,0x1
ffffffffc0200a8c:	38060613          	addi	a2,a2,896 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200a90:	09600593          	li	a1,150
ffffffffc0200a94:	00001517          	auipc	a0,0x1
ffffffffc0200a98:	38c50513          	addi	a0,a0,908 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200a9c:	911ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200aa0:	00001697          	auipc	a3,0x1
ffffffffc0200aa4:	41068693          	addi	a3,a3,1040 # ffffffffc0201eb0 <commands+0x5a8>
ffffffffc0200aa8:	00001617          	auipc	a2,0x1
ffffffffc0200aac:	36060613          	addi	a2,a2,864 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200ab0:	09500593          	li	a1,149
ffffffffc0200ab4:	00001517          	auipc	a0,0x1
ffffffffc0200ab8:	36c50513          	addi	a0,a0,876 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200abc:	8f1ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1->ref == 0);
ffffffffc0200ac0:	00001697          	auipc	a3,0x1
ffffffffc0200ac4:	4a868693          	addi	a3,a3,1192 # ffffffffc0201f68 <commands+0x660>
ffffffffc0200ac8:	00001617          	auipc	a2,0x1
ffffffffc0200acc:	34060613          	addi	a2,a2,832 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200ad0:	09f00593          	li	a1,159
ffffffffc0200ad4:	00001517          	auipc	a0,0x1
ffffffffc0200ad8:	34c50513          	addi	a0,a0,844 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200adc:	8d1ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    p3 = alloc_pages(8);
ffffffffc0200ae0:	00001697          	auipc	a3,0x1
ffffffffc0200ae4:	42068693          	addi	a3,a3,1056 # ffffffffc0201f00 <commands+0x5f8>
ffffffffc0200ae8:	00001617          	auipc	a2,0x1
ffffffffc0200aec:	32060613          	addi	a2,a2,800 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200af0:	09900593          	li	a1,153
ffffffffc0200af4:	00001517          	auipc	a0,0x1
ffffffffc0200af8:	32c50513          	addi	a0,a0,812 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200afc:	8b1ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b00:	00001697          	auipc	a3,0x1
ffffffffc0200b04:	4d068693          	addi	a3,a3,1232 # ffffffffc0201fd0 <commands+0x6c8>
ffffffffc0200b08:	00001617          	auipc	a2,0x1
ffffffffc0200b0c:	30060613          	addi	a2,a2,768 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200b10:	0a800593          	li	a1,168
ffffffffc0200b14:	00001517          	auipc	a0,0x1
ffffffffc0200b18:	30c50513          	addi	a0,a0,780 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200b1c:	891ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageReserved(p0) && !PageProperty(p0));
ffffffffc0200b20:	00001697          	auipc	a3,0x1
ffffffffc0200b24:	38068693          	addi	a3,a3,896 # ffffffffc0201ea0 <commands+0x598>
ffffffffc0200b28:	00001617          	auipc	a2,0x1
ffffffffc0200b2c:	2e060613          	addi	a2,a2,736 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200b30:	09400593          	li	a1,148
ffffffffc0200b34:	00001517          	auipc	a0,0x1
ffffffffc0200b38:	2ec50513          	addi	a0,a0,748 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200b3c:	871ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    free_pages(p0, 1);
ffffffffc0200b40:	00001697          	auipc	a3,0x1
ffffffffc0200b44:	45868693          	addi	a3,a3,1112 # ffffffffc0201f98 <commands+0x690>
ffffffffc0200b48:	00001617          	auipc	a2,0x1
ffffffffc0200b4c:	2c060613          	addi	a2,a2,704 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200b50:	0a000593          	li	a1,160
ffffffffc0200b54:	00001517          	auipc	a0,0x1
ffffffffc0200b58:	2cc50513          	addi	a0,a0,716 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200b5c:	851ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free_pages() == all_pages >> 1);
ffffffffc0200b60:	00001697          	auipc	a3,0x1
ffffffffc0200b64:	45868693          	addi	a3,a3,1112 # ffffffffc0201fb8 <commands+0x6b0>
ffffffffc0200b68:	00001617          	auipc	a2,0x1
ffffffffc0200b6c:	2a060613          	addi	a2,a2,672 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200b70:	0a700593          	li	a1,167
ffffffffc0200b74:	00001517          	auipc	a0,0x1
ffffffffc0200b78:	2ac50513          	addi	a0,a0,684 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200b7c:	831ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    free_pages(p2, 3);
ffffffffc0200b80:	00001697          	auipc	a3,0x1
ffffffffc0200b84:	42868693          	addi	a3,a3,1064 # ffffffffc0201fa8 <commands+0x6a0>
ffffffffc0200b88:	00001617          	auipc	a2,0x1
ffffffffc0200b8c:	28060613          	addi	a2,a2,640 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200b90:	0a500593          	li	a1,165
ffffffffc0200b94:	00001517          	auipc	a0,0x1
ffffffffc0200b98:	28c50513          	addi	a0,a0,652 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200b9c:	811ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    p1 = alloc_pages(2);
ffffffffc0200ba0:	00001697          	auipc	a3,0x1
ffffffffc0200ba4:	2c068693          	addi	a3,a3,704 # ffffffffc0201e60 <commands+0x558>
ffffffffc0200ba8:	00001617          	auipc	a2,0x1
ffffffffc0200bac:	26060613          	addi	a2,a2,608 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200bb0:	08f00593          	li	a1,143
ffffffffc0200bb4:	00001517          	auipc	a0,0x1
ffffffffc0200bb8:	26c50513          	addi	a0,a0,620 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200bbc:	ff0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    // 分配两个组页
ffffffffc0200bc0:	00001697          	auipc	a3,0x1
ffffffffc0200bc4:	27868693          	addi	a3,a3,632 # ffffffffc0201e38 <commands+0x530>
ffffffffc0200bc8:	00001617          	auipc	a2,0x1
ffffffffc0200bcc:	24060613          	addi	a2,a2,576 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200bd0:	08c00593          	li	a1,140
ffffffffc0200bd4:	00001517          	auipc	a0,0x1
ffffffffc0200bd8:	24c50513          	addi	a0,a0,588 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200bdc:	fd0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    free_pages(p1, 256);
ffffffffc0200be0:	00001697          	auipc	a3,0x1
ffffffffc0200be4:	41868693          	addi	a3,a3,1048 # ffffffffc0201ff8 <commands+0x6f0>
ffffffffc0200be8:	00001617          	auipc	a2,0x1
ffffffffc0200bec:	22060613          	addi	a2,a2,544 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200bf0:	0ab00593          	li	a1,171
ffffffffc0200bf4:	00001517          	auipc	a0,0x1
ffffffffc0200bf8:	22c50513          	addi	a0,a0,556 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200bfc:	fb0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200c00:	00001697          	auipc	a3,0x1
ffffffffc0200c04:	31068693          	addi	a3,a3,784 # ffffffffc0201f10 <commands+0x608>
ffffffffc0200c08:	00001617          	auipc	a2,0x1
ffffffffc0200c0c:	20060613          	addi	a2,a2,512 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200c10:	09b00593          	li	a1,155
ffffffffc0200c14:	00001517          	auipc	a0,0x1
ffffffffc0200c18:	20c50513          	addi	a0,a0,524 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200c1c:	f90ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c20 <buddy_free_pages>:
    // 检查参数
ffffffffc0200c20:	1141                	addi	sp,sp,-16
ffffffffc0200c22:	e406                	sd	ra,8(sp)
    // 释放
ffffffffc0200c24:	10058263          	beqz	a1,ffffffffc0200d28 <buddy_free_pages+0x108>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200c28:	00259693          	slli	a3,a1,0x2
ffffffffc0200c2c:	96ae                	add	a3,a3,a1
ffffffffc0200c2e:	068e                	slli	a3,a3,0x3
ffffffffc0200c30:	96aa                	add	a3,a3,a0
ffffffffc0200c32:	87aa                	mv	a5,a0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c34:	4609                	li	a2,2
ffffffffc0200c36:	02d50263          	beq	a0,a3,ffffffffc0200c5a <buddy_free_pages+0x3a>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c3a:	6798                	ld	a4,8(a5)
        SetPageProperty(p);
ffffffffc0200c3c:	8b05                	andi	a4,a4,1
ffffffffc0200c3e:	e769                	bnez	a4,ffffffffc0200d08 <buddy_free_pages+0xe8>
ffffffffc0200c40:	6798                	ld	a4,8(a5)
ffffffffc0200c42:	8b09                	andi	a4,a4,2
ffffffffc0200c44:	e371                	bnez	a4,ffffffffc0200d08 <buddy_free_pages+0xe8>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c46:	00878713          	addi	a4,a5,8
ffffffffc0200c4a:	40c7302f          	amoor.d	zero,a2,(a4)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c4e:	0007a023          	sw	zero,0(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200c52:	02878793          	addi	a5,a5,40
ffffffffc0200c56:	fed792e3          	bne	a5,a3,ffffffffc0200c3a <buddy_free_pages+0x1a>
    while(buddy_page[index] > 0){
ffffffffc0200c5a:	00005797          	auipc	a5,0x5
ffffffffc0200c5e:	7d67b783          	ld	a5,2006(a5) # ffffffffc0206430 <useable_page_base>
ffffffffc0200c62:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c66:	878d                	srai	a5,a5,0x3
ffffffffc0200c68:	00001697          	auipc	a3,0x1
ffffffffc0200c6c:	7e86b683          	ld	a3,2024(a3) # ffffffffc0202450 <error_string+0x38>
ffffffffc0200c70:	02d786b3          	mul	a3,a5,a3
ffffffffc0200c74:	00005797          	auipc	a5,0x5
ffffffffc0200c78:	7c47a783          	lw	a5,1988(a5) # ffffffffc0206438 <useable_page_num>
        index=PARENT(index);
ffffffffc0200c7c:	00005617          	auipc	a2,0x5
ffffffffc0200c80:	7a463603          	ld	a2,1956(a2) # ffffffffc0206420 <buddy_page>
    while(buddy_page[index] > 0){
ffffffffc0200c84:	4705                	li	a4,1
ffffffffc0200c86:	9fb5                	addw	a5,a5,a3
        index=PARENT(index);
ffffffffc0200c88:	02079593          	slli	a1,a5,0x20
ffffffffc0200c8c:	01e5d693          	srli	a3,a1,0x1e
ffffffffc0200c90:	96b2                	add	a3,a3,a2
ffffffffc0200c92:	428c                	lw	a1,0(a3)
ffffffffc0200c94:	c999                	beqz	a1,ffffffffc0200caa <buddy_free_pages+0x8a>
        size <<= 1;
ffffffffc0200c96:	0017d79b          	srliw	a5,a5,0x1
        index=PARENT(index);
ffffffffc0200c9a:	02079693          	slli	a3,a5,0x20
ffffffffc0200c9e:	82f9                	srli	a3,a3,0x1e
ffffffffc0200ca0:	96b2                	add	a3,a3,a2
ffffffffc0200ca2:	428c                	lw	a1,0(a3)
    }
ffffffffc0200ca4:	0017171b          	slliw	a4,a4,0x1
        index=PARENT(index);
ffffffffc0200ca8:	f5fd                	bnez	a1,ffffffffc0200c96 <buddy_free_pages+0x76>
    while((index = PARENT(index)) > 0){
ffffffffc0200caa:	c298                	sw	a4,0(a3)
        size <<= 1;
ffffffffc0200cac:	0017d59b          	srliw	a1,a5,0x1
ffffffffc0200cb0:	e199                	bnez	a1,ffffffffc0200cb6 <buddy_free_pages+0x96>
ffffffffc0200cb2:	a881                	j	ffffffffc0200d02 <buddy_free_pages+0xe2>
ffffffffc0200cb4:	85b6                	mv	a1,a3
            buddy_page[index] = size;
ffffffffc0200cb6:	9bf9                	andi	a5,a5,-2
ffffffffc0200cb8:	02079693          	slli	a3,a5,0x20
ffffffffc0200cbc:	2785                	addiw	a5,a5,1
ffffffffc0200cbe:	02079513          	slli	a0,a5,0x20
ffffffffc0200cc2:	9281                	srli	a3,a3,0x20
ffffffffc0200cc4:	01e55793          	srli	a5,a0,0x1e
ffffffffc0200cc8:	068a                	slli	a3,a3,0x2
ffffffffc0200cca:	97b2                	add	a5,a5,a2
ffffffffc0200ccc:	96b2                	add	a3,a3,a2
ffffffffc0200cce:	4388                	lw	a0,0(a5)
ffffffffc0200cd0:	4294                	lw	a3,0(a3)
        if(buddy_page[LEFT_CHILD(index)] + buddy_page[RIGHT_CHILD(index)] == size){
ffffffffc0200cd2:	0017181b          	slliw	a6,a4,0x1
        }
ffffffffc0200cd6:	02059713          	slli	a4,a1,0x20
ffffffffc0200cda:	01e75793          	srli	a5,a4,0x1e
            buddy_page[index] = size;
ffffffffc0200cde:	00a688bb          	addw	a7,a3,a0
        if(buddy_page[LEFT_CHILD(index)] + buddy_page[RIGHT_CHILD(index)] == size){
ffffffffc0200ce2:	0008071b          	sext.w	a4,a6
        }
ffffffffc0200ce6:	97b2                	add	a5,a5,a2
            buddy_page[index] = size;
ffffffffc0200ce8:	00e88663          	beq	a7,a4,ffffffffc0200cf4 <buddy_free_pages+0xd4>
        }
ffffffffc0200cec:	8836                	mv	a6,a3
ffffffffc0200cee:	00a6f363          	bgeu	a3,a0,ffffffffc0200cf4 <buddy_free_pages+0xd4>
ffffffffc0200cf2:	882a                	mv	a6,a0
ffffffffc0200cf4:	0107a023          	sw	a6,0(a5)
        size <<= 1;
ffffffffc0200cf8:	0015d69b          	srliw	a3,a1,0x1
ffffffffc0200cfc:	0005879b          	sext.w	a5,a1
ffffffffc0200d00:	fad5                	bnez	a3,ffffffffc0200cb4 <buddy_free_pages+0x94>

ffffffffc0200d02:	60a2                	ld	ra,8(sp)
ffffffffc0200d04:	0141                	addi	sp,sp,16
ffffffffc0200d06:	8082                	ret
        SetPageProperty(p);
ffffffffc0200d08:	00001697          	auipc	a3,0x1
ffffffffc0200d0c:	30068693          	addi	a3,a3,768 # ffffffffc0202008 <commands+0x700>
ffffffffc0200d10:	00001617          	auipc	a2,0x1
ffffffffc0200d14:	0f860613          	addi	a2,a2,248 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200d18:	06c00593          	li	a1,108
ffffffffc0200d1c:	00001517          	auipc	a0,0x1
ffffffffc0200d20:	10450513          	addi	a0,a0,260 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200d24:	e88ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    // 释放
ffffffffc0200d28:	00001697          	auipc	a3,0x1
ffffffffc0200d2c:	0d868693          	addi	a3,a3,216 # ffffffffc0201e00 <commands+0x4f8>
ffffffffc0200d30:	00001617          	auipc	a2,0x1
ffffffffc0200d34:	0d860613          	addi	a2,a2,216 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200d38:	06900593          	li	a1,105
ffffffffc0200d3c:	00001517          	auipc	a0,0x1
ffffffffc0200d40:	0e450513          	addi	a0,a0,228 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200d44:	e68ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d48 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200d48:	1141                	addi	sp,sp,-16
ffffffffc0200d4a:	e406                	sd	ra,8(sp)
    assert((n > 0));// && IS_POWER_OF_2(n)
ffffffffc0200d4c:	1a058163          	beqz	a1,ffffffffc0200eee <buddy_init_memmap+0x1a6>
ffffffffc0200d50:	46f5                	li	a3,29
ffffffffc0200d52:	4601                	li	a2,0
ffffffffc0200d54:	4705                	li	a4,1
ffffffffc0200d56:	a801                	j	ffffffffc0200d66 <buddy_init_memmap+0x1e>
    for (int i = 1;
ffffffffc0200d58:	36fd                	addiw	a3,a3,-1
         i++, useable_page_num <<= 1)
ffffffffc0200d5a:	0017179b          	slliw	a5,a4,0x1
ffffffffc0200d5e:	4605                	li	a2,1
    for (int i = 1;
ffffffffc0200d60:	14068d63          	beqz	a3,ffffffffc0200eba <buddy_init_memmap+0x172>
         i++, useable_page_num <<= 1)
ffffffffc0200d64:	873e                	mv	a4,a5
         (i < BUDDY_MAX_DEPTH) && (useable_page_num + (useable_page_num >> 9) < n);
ffffffffc0200d66:	0097579b          	srliw	a5,a4,0x9
ffffffffc0200d6a:	9fb9                	addw	a5,a5,a4
ffffffffc0200d6c:	1782                	slli	a5,a5,0x20
ffffffffc0200d6e:	9381                	srli	a5,a5,0x20
ffffffffc0200d70:	feb7e4e3          	bltu	a5,a1,ffffffffc0200d58 <buddy_init_memmap+0x10>
ffffffffc0200d74:	12060e63          	beqz	a2,ffffffffc0200eb0 <buddy_init_memmap+0x168>
    buddy_page_num = (useable_page_num >> 9) + 1;
ffffffffc0200d78:	00a7579b          	srliw	a5,a4,0xa
ffffffffc0200d7c:	2785                	addiw	a5,a5,1
    useable_page_base = base + buddy_page_num;
ffffffffc0200d7e:	02079613          	slli	a2,a5,0x20
ffffffffc0200d82:	9201                	srli	a2,a2,0x20
ffffffffc0200d84:	00261693          	slli	a3,a2,0x2
ffffffffc0200d88:	96b2                	add	a3,a3,a2
    useable_page_num >>= 1;
ffffffffc0200d8a:	0017571b          	srliw	a4,a4,0x1
    useable_page_base = base + buddy_page_num;
ffffffffc0200d8e:	068e                	slli	a3,a3,0x3
    buddy_page_num = (useable_page_num >> 9) + 1;
ffffffffc0200d90:	00005817          	auipc	a6,0x5
ffffffffc0200d94:	69880813          	addi	a6,a6,1688 # ffffffffc0206428 <buddy_page_num>
    useable_page_base = base + buddy_page_num;
ffffffffc0200d98:	96aa                	add	a3,a3,a0
    buddy_page_num = (useable_page_num >> 9) + 1;
ffffffffc0200d9a:	00f82023          	sw	a5,0(a6)
    useable_page_num >>= 1;
ffffffffc0200d9e:	00005897          	auipc	a7,0x5
ffffffffc0200da2:	69a88893          	addi	a7,a7,1690 # ffffffffc0206438 <useable_page_num>
    useable_page_base = base + buddy_page_num;
ffffffffc0200da6:	00005797          	auipc	a5,0x5
ffffffffc0200daa:	68d7b523          	sd	a3,1674(a5) # ffffffffc0206430 <useable_page_base>
    useable_page_num >>= 1;
ffffffffc0200dae:	00e8a023          	sw	a4,0(a7)
    for (int i = 0; i != buddy_page_num; i++){
ffffffffc0200db2:	00850793          	addi	a5,a0,8
ffffffffc0200db6:	4701                	li	a4,0
ffffffffc0200db8:	4605                	li	a2,1
ffffffffc0200dba:	40c7b02f          	amoor.d	zero,a2,(a5)
ffffffffc0200dbe:	00082683          	lw	a3,0(a6)
ffffffffc0200dc2:	2705                	addiw	a4,a4,1
ffffffffc0200dc4:	02878793          	addi	a5,a5,40
ffffffffc0200dc8:	fee699e3          	bne	a3,a4,ffffffffc0200dba <buddy_init_memmap+0x72>
    for (int i = buddy_page_num; i != n; i++){
ffffffffc0200dcc:	1702                	slli	a4,a4,0x20
ffffffffc0200dce:	9301                	srli	a4,a4,0x20
ffffffffc0200dd0:	02e58563          	beq	a1,a4,ffffffffc0200dfa <buddy_init_memmap+0xb2>
ffffffffc0200dd4:	00271793          	slli	a5,a4,0x2
ffffffffc0200dd8:	97ba                	add	a5,a5,a4
ffffffffc0200dda:	078e                	slli	a5,a5,0x3
ffffffffc0200ddc:	07a1                	addi	a5,a5,8
ffffffffc0200dde:	97aa                	add	a5,a5,a0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200de0:	5679                	li	a2,-2
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200de2:	4689                	li	a3,2
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200de4:	60c7b02f          	amoand.d	zero,a2,(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200de8:	40d7b02f          	amoor.d	zero,a3,(a5)
ffffffffc0200dec:	fe07ac23          	sw	zero,-8(a5)
ffffffffc0200df0:	0705                	addi	a4,a4,1
ffffffffc0200df2:	02878793          	addi	a5,a5,40
ffffffffc0200df6:	fee597e3          	bne	a1,a4,ffffffffc0200de4 <buddy_init_memmap+0x9c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200dfa:	00005697          	auipc	a3,0x5
ffffffffc0200dfe:	64e6b683          	ld	a3,1614(a3) # ffffffffc0206448 <pages>
ffffffffc0200e02:	40d506b3          	sub	a3,a0,a3
ffffffffc0200e06:	868d                	srai	a3,a3,0x3
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	64853503          	ld	a0,1608(a0) # ffffffffc0202450 <error_string+0x38>
ffffffffc0200e10:	02a686b3          	mul	a3,a3,a0
ffffffffc0200e14:	00001517          	auipc	a0,0x1
ffffffffc0200e18:	64453503          	ld	a0,1604(a0) # ffffffffc0202458 <nbase>
    buddy_page = (unsigned int*)KADDR(page2pa(base));
ffffffffc0200e1c:	00005717          	auipc	a4,0x5
ffffffffc0200e20:	62473703          	ld	a4,1572(a4) # ffffffffc0206440 <npage>
ffffffffc0200e24:	96aa                	add	a3,a3,a0
ffffffffc0200e26:	00c69793          	slli	a5,a3,0xc
ffffffffc0200e2a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e2c:	00c69513          	slli	a0,a3,0xc
ffffffffc0200e30:	0ae7f263          	bgeu	a5,a4,ffffffffc0200ed4 <buddy_init_memmap+0x18c>
    for (int i = useable_page_num; i < useable_page_num << 1; i++){
ffffffffc0200e34:	0008a683          	lw	a3,0(a7)
    buddy_page = (unsigned int*)KADDR(page2pa(base));
ffffffffc0200e38:	00005797          	auipc	a5,0x5
ffffffffc0200e3c:	6307b783          	ld	a5,1584(a5) # ffffffffc0206468 <va_pa_offset>
ffffffffc0200e40:	953e                	add	a0,a0,a5
ffffffffc0200e42:	00005797          	auipc	a5,0x5
ffffffffc0200e46:	5ca7bf23          	sd	a0,1502(a5) # ffffffffc0206420 <buddy_page>
    for (int i = useable_page_num; i < useable_page_num << 1; i++){
ffffffffc0200e4a:	0016961b          	slliw	a2,a3,0x1
ffffffffc0200e4e:	0006879b          	sext.w	a5,a3
ffffffffc0200e52:	02c6f263          	bgeu	a3,a2,ffffffffc0200e76 <buddy_init_memmap+0x12e>
ffffffffc0200e56:	40d6073b          	subw	a4,a2,a3
ffffffffc0200e5a:	377d                	addiw	a4,a4,-1
ffffffffc0200e5c:	1702                	slli	a4,a4,0x20
ffffffffc0200e5e:	9301                	srli	a4,a4,0x20
ffffffffc0200e60:	973e                	add	a4,a4,a5
ffffffffc0200e62:	0705                	addi	a4,a4,1
ffffffffc0200e64:	078a                	slli	a5,a5,0x2
ffffffffc0200e66:	070a                	slli	a4,a4,0x2
ffffffffc0200e68:	97aa                	add	a5,a5,a0
ffffffffc0200e6a:	972a                	add	a4,a4,a0
        buddy_page[i] = 1;
ffffffffc0200e6c:	4605                	li	a2,1
ffffffffc0200e6e:	c390                	sw	a2,0(a5)
    for (int i = useable_page_num; i < useable_page_num << 1; i++){
ffffffffc0200e70:	0791                	addi	a5,a5,4
ffffffffc0200e72:	fef71ee3          	bne	a4,a5,ffffffffc0200e6e <buddy_init_memmap+0x126>
    for (int i = useable_page_num - 1; i > 0; i--){
ffffffffc0200e76:	fff6861b          	addiw	a2,a3,-1
ffffffffc0200e7a:	87b2                	mv	a5,a2
ffffffffc0200e7c:	02c05063          	blez	a2,ffffffffc0200e9c <buddy_init_memmap+0x154>
ffffffffc0200e80:	060a                	slli	a2,a2,0x2
ffffffffc0200e82:	0017979b          	slliw	a5,a5,0x1
ffffffffc0200e86:	962a                	add	a2,a2,a0
        buddy_page[i] = buddy_page[i << 1] << 1;
ffffffffc0200e88:	00279713          	slli	a4,a5,0x2
ffffffffc0200e8c:	972a                	add	a4,a4,a0
ffffffffc0200e8e:	4318                	lw	a4,0(a4)
    for (int i = useable_page_num - 1; i > 0; i--){
ffffffffc0200e90:	1671                	addi	a2,a2,-4
ffffffffc0200e92:	37f9                	addiw	a5,a5,-2
        buddy_page[i] = buddy_page[i << 1] << 1;
ffffffffc0200e94:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200e98:	c258                	sw	a4,4(a2)
    for (int i = useable_page_num - 1; i > 0; i--){
ffffffffc0200e9a:	f7fd                	bnez	a5,ffffffffc0200e88 <buddy_init_memmap+0x140>
}
ffffffffc0200e9c:	60a2                	ld	ra,8(sp)
    cprintf("buddy init: Total %d, Buddy %d, Useable %d\n",
ffffffffc0200e9e:	00082603          	lw	a2,0(a6)
ffffffffc0200ea2:	00001517          	auipc	a0,0x1
ffffffffc0200ea6:	1be50513          	addi	a0,a0,446 # ffffffffc0202060 <commands+0x758>
}
ffffffffc0200eaa:	0141                	addi	sp,sp,16
    cprintf("buddy init: Total %d, Buddy %d, Useable %d\n",
ffffffffc0200eac:	a06ff06f          	j	ffffffffc02000b2 <cprintf>
         (i < BUDDY_MAX_DEPTH) && (useable_page_num + (useable_page_num >> 9) < n);
ffffffffc0200eb0:	02800693          	li	a3,40
ffffffffc0200eb4:	4785                	li	a5,1
ffffffffc0200eb6:	4701                	li	a4,0
ffffffffc0200eb8:	bde1                	j	ffffffffc0200d90 <buddy_init_memmap+0x48>
    buddy_page_num = (useable_page_num >> 9) + 1;
ffffffffc0200eba:	00a7d79b          	srliw	a5,a5,0xa
ffffffffc0200ebe:	2785                	addiw	a5,a5,1
    useable_page_base = base + buddy_page_num;
ffffffffc0200ec0:	02079613          	slli	a2,a5,0x20
ffffffffc0200ec4:	9201                	srli	a2,a2,0x20
ffffffffc0200ec6:	00261693          	slli	a3,a2,0x2
    useable_page_num >>= 1;
ffffffffc0200eca:	1706                	slli	a4,a4,0x21
    useable_page_base = base + buddy_page_num;
ffffffffc0200ecc:	96b2                	add	a3,a3,a2
    useable_page_num >>= 1;
ffffffffc0200ece:	9305                	srli	a4,a4,0x21
    useable_page_base = base + buddy_page_num;
ffffffffc0200ed0:	068e                	slli	a3,a3,0x3
ffffffffc0200ed2:	bd7d                	j	ffffffffc0200d90 <buddy_init_memmap+0x48>
    buddy_page = (unsigned int*)KADDR(page2pa(base));
ffffffffc0200ed4:	86aa                	mv	a3,a0
ffffffffc0200ed6:	00001617          	auipc	a2,0x1
ffffffffc0200eda:	16260613          	addi	a2,a2,354 # ffffffffc0202038 <commands+0x730>
ffffffffc0200ede:	03300593          	li	a1,51
ffffffffc0200ee2:	00001517          	auipc	a0,0x1
ffffffffc0200ee6:	f3e50513          	addi	a0,a0,-194 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200eea:	cc2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((n > 0));// && IS_POWER_OF_2(n)
ffffffffc0200eee:	00001697          	auipc	a3,0x1
ffffffffc0200ef2:	14268693          	addi	a3,a3,322 # ffffffffc0202030 <commands+0x728>
ffffffffc0200ef6:	00001617          	auipc	a2,0x1
ffffffffc0200efa:	f1260613          	addi	a2,a2,-238 # ffffffffc0201e08 <commands+0x500>
ffffffffc0200efe:	45f5                	li	a1,29
ffffffffc0200f00:	00001517          	auipc	a0,0x1
ffffffffc0200f04:	f2050513          	addi	a0,a0,-224 # ffffffffc0201e20 <commands+0x518>
ffffffffc0200f08:	ca4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f0c <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f0c:	100027f3          	csrr	a5,sstatus
ffffffffc0200f10:	8b89                	andi	a5,a5,2
ffffffffc0200f12:	e799                	bnez	a5,ffffffffc0200f20 <alloc_pages+0x14>
    struct Page *page = NULL;
    bool intr_flag;

    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f14:	00005797          	auipc	a5,0x5
ffffffffc0200f18:	53c7b783          	ld	a5,1340(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f1c:	6f9c                	ld	a5,24(a5)
ffffffffc0200f1e:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200f20:	1141                	addi	sp,sp,-16
ffffffffc0200f22:	e406                	sd	ra,8(sp)
ffffffffc0200f24:	e022                	sd	s0,0(sp)
ffffffffc0200f26:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200f28:	d36ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f2c:	00005797          	auipc	a5,0x5
ffffffffc0200f30:	5247b783          	ld	a5,1316(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f34:	6f9c                	ld	a5,24(a5)
ffffffffc0200f36:	8522                	mv	a0,s0
ffffffffc0200f38:	9782                	jalr	a5
ffffffffc0200f3a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200f3c:	d1cff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200f40:	60a2                	ld	ra,8(sp)
ffffffffc0200f42:	8522                	mv	a0,s0
ffffffffc0200f44:	6402                	ld	s0,0(sp)
ffffffffc0200f46:	0141                	addi	sp,sp,16
ffffffffc0200f48:	8082                	ret

ffffffffc0200f4a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f4a:	100027f3          	csrr	a5,sstatus
ffffffffc0200f4e:	8b89                	andi	a5,a5,2
ffffffffc0200f50:	e799                	bnez	a5,ffffffffc0200f5e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f52:	00005797          	auipc	a5,0x5
ffffffffc0200f56:	4fe7b783          	ld	a5,1278(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f5a:	739c                	ld	a5,32(a5)
ffffffffc0200f5c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f5e:	1101                	addi	sp,sp,-32
ffffffffc0200f60:	ec06                	sd	ra,24(sp)
ffffffffc0200f62:	e822                	sd	s0,16(sp)
ffffffffc0200f64:	e426                	sd	s1,8(sp)
ffffffffc0200f66:	842a                	mv	s0,a0
ffffffffc0200f68:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f6a:	cf4ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f6e:	00005797          	auipc	a5,0x5
ffffffffc0200f72:	4e27b783          	ld	a5,1250(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f76:	739c                	ld	a5,32(a5)
ffffffffc0200f78:	85a6                	mv	a1,s1
ffffffffc0200f7a:	8522                	mv	a0,s0
ffffffffc0200f7c:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f7e:	6442                	ld	s0,16(sp)
ffffffffc0200f80:	60e2                	ld	ra,24(sp)
ffffffffc0200f82:	64a2                	ld	s1,8(sp)
ffffffffc0200f84:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f86:	cd2ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0200f8a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f8a:	100027f3          	csrr	a5,sstatus
ffffffffc0200f8e:	8b89                	andi	a5,a5,2
ffffffffc0200f90:	e799                	bnez	a5,ffffffffc0200f9e <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f92:	00005797          	auipc	a5,0x5
ffffffffc0200f96:	4be7b783          	ld	a5,1214(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f9a:	779c                	ld	a5,40(a5)
ffffffffc0200f9c:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200f9e:	1141                	addi	sp,sp,-16
ffffffffc0200fa0:	e406                	sd	ra,8(sp)
ffffffffc0200fa2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200fa4:	cbaff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200fa8:	00005797          	auipc	a5,0x5
ffffffffc0200fac:	4a87b783          	ld	a5,1192(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200fb0:	779c                	ld	a5,40(a5)
ffffffffc0200fb2:	9782                	jalr	a5
ffffffffc0200fb4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200fb6:	ca2ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200fba:	60a2                	ld	ra,8(sp)
ffffffffc0200fbc:	8522                	mv	a0,s0
ffffffffc0200fbe:	6402                	ld	s0,0(sp)
ffffffffc0200fc0:	0141                	addi	sp,sp,16
ffffffffc0200fc2:	8082                	ret

ffffffffc0200fc4 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fc4:	00001797          	auipc	a5,0x1
ffffffffc0200fc8:	0e478793          	addi	a5,a5,228 # ffffffffc02020a8 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fcc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200fce:	1101                	addi	sp,sp,-32
ffffffffc0200fd0:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fd2:	00001517          	auipc	a0,0x1
ffffffffc0200fd6:	10e50513          	addi	a0,a0,270 # ffffffffc02020e0 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fda:	00005497          	auipc	s1,0x5
ffffffffc0200fde:	47648493          	addi	s1,s1,1142 # ffffffffc0206450 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fe2:	ec06                	sd	ra,24(sp)
ffffffffc0200fe4:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fe6:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fe8:	8caff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200fec:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fee:	00005417          	auipc	s0,0x5
ffffffffc0200ff2:	47a40413          	addi	s0,s0,1146 # ffffffffc0206468 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200ff6:	679c                	ld	a5,8(a5)
ffffffffc0200ff8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ffa:	57f5                	li	a5,-3
ffffffffc0200ffc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200ffe:	00001517          	auipc	a0,0x1
ffffffffc0201002:	0fa50513          	addi	a0,a0,250 # ffffffffc02020f8 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201006:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201008:	8aaff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020100c:	46c5                	li	a3,17
ffffffffc020100e:	06ee                	slli	a3,a3,0x1b
ffffffffc0201010:	40100613          	li	a2,1025
ffffffffc0201014:	16fd                	addi	a3,a3,-1
ffffffffc0201016:	07e005b7          	lui	a1,0x7e00
ffffffffc020101a:	0656                	slli	a2,a2,0x15
ffffffffc020101c:	00001517          	auipc	a0,0x1
ffffffffc0201020:	0f450513          	addi	a0,a0,244 # ffffffffc0202110 <buddy_pmm_manager+0x68>
ffffffffc0201024:	88eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201028:	777d                	lui	a4,0xfffff
ffffffffc020102a:	00006797          	auipc	a5,0x6
ffffffffc020102e:	44d78793          	addi	a5,a5,1101 # ffffffffc0207477 <end+0xfff>
ffffffffc0201032:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201034:	00005517          	auipc	a0,0x5
ffffffffc0201038:	40c50513          	addi	a0,a0,1036 # ffffffffc0206440 <npage>
ffffffffc020103c:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201040:	00005597          	auipc	a1,0x5
ffffffffc0201044:	40858593          	addi	a1,a1,1032 # ffffffffc0206448 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201048:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020104a:	e19c                	sd	a5,0(a1)
ffffffffc020104c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020104e:	4701                	li	a4,0
ffffffffc0201050:	4885                	li	a7,1
ffffffffc0201052:	fff80837          	lui	a6,0xfff80
ffffffffc0201056:	a011                	j	ffffffffc020105a <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201058:	619c                	ld	a5,0(a1)
ffffffffc020105a:	97b6                	add	a5,a5,a3
ffffffffc020105c:	07a1                	addi	a5,a5,8
ffffffffc020105e:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201062:	611c                	ld	a5,0(a0)
ffffffffc0201064:	0705                	addi	a4,a4,1
ffffffffc0201066:	02868693          	addi	a3,a3,40
ffffffffc020106a:	01078633          	add	a2,a5,a6
ffffffffc020106e:	fec765e3          	bltu	a4,a2,ffffffffc0201058 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201072:	6190                	ld	a2,0(a1)
ffffffffc0201074:	00279713          	slli	a4,a5,0x2
ffffffffc0201078:	973e                	add	a4,a4,a5
ffffffffc020107a:	fec006b7          	lui	a3,0xfec00
ffffffffc020107e:	070e                	slli	a4,a4,0x3
ffffffffc0201080:	96b2                	add	a3,a3,a2
ffffffffc0201082:	96ba                	add	a3,a3,a4
ffffffffc0201084:	c0200737          	lui	a4,0xc0200
ffffffffc0201088:	08e6ef63          	bltu	a3,a4,ffffffffc0201126 <pmm_init+0x162>
ffffffffc020108c:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020108e:	45c5                	li	a1,17
ffffffffc0201090:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201092:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201094:	04b6e863          	bltu	a3,a1,ffffffffc02010e4 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201098:	609c                	ld	a5,0(s1)
ffffffffc020109a:	7b9c                	ld	a5,48(a5)
ffffffffc020109c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020109e:	00001517          	auipc	a0,0x1
ffffffffc02010a2:	10a50513          	addi	a0,a0,266 # ffffffffc02021a8 <buddy_pmm_manager+0x100>
ffffffffc02010a6:	80cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02010aa:	00004597          	auipc	a1,0x4
ffffffffc02010ae:	f5658593          	addi	a1,a1,-170 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02010b2:	00005797          	auipc	a5,0x5
ffffffffc02010b6:	3ab7b723          	sd	a1,942(a5) # ffffffffc0206460 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02010ba:	c02007b7          	lui	a5,0xc0200
ffffffffc02010be:	08f5e063          	bltu	a1,a5,ffffffffc020113e <pmm_init+0x17a>
ffffffffc02010c2:	6010                	ld	a2,0(s0)
}
ffffffffc02010c4:	6442                	ld	s0,16(sp)
ffffffffc02010c6:	60e2                	ld	ra,24(sp)
ffffffffc02010c8:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02010ca:	40c58633          	sub	a2,a1,a2
ffffffffc02010ce:	00005797          	auipc	a5,0x5
ffffffffc02010d2:	38c7b523          	sd	a2,906(a5) # ffffffffc0206458 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010d6:	00001517          	auipc	a0,0x1
ffffffffc02010da:	0f250513          	addi	a0,a0,242 # ffffffffc02021c8 <buddy_pmm_manager+0x120>
}
ffffffffc02010de:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010e0:	fd3fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010e4:	6705                	lui	a4,0x1
ffffffffc02010e6:	177d                	addi	a4,a4,-1
ffffffffc02010e8:	96ba                	add	a3,a3,a4
ffffffffc02010ea:	777d                	lui	a4,0xfffff
ffffffffc02010ec:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02010ee:	00c6d513          	srli	a0,a3,0xc
ffffffffc02010f2:	00f57e63          	bgeu	a0,a5,ffffffffc020110e <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02010f6:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02010f8:	982a                	add	a6,a6,a0
ffffffffc02010fa:	00281513          	slli	a0,a6,0x2
ffffffffc02010fe:	9542                	add	a0,a0,a6
ffffffffc0201100:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201102:	8d95                	sub	a1,a1,a3
ffffffffc0201104:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201106:	81b1                	srli	a1,a1,0xc
ffffffffc0201108:	9532                	add	a0,a0,a2
ffffffffc020110a:	9782                	jalr	a5
}
ffffffffc020110c:	b771                	j	ffffffffc0201098 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020110e:	00001617          	auipc	a2,0x1
ffffffffc0201112:	06a60613          	addi	a2,a2,106 # ffffffffc0202178 <buddy_pmm_manager+0xd0>
ffffffffc0201116:	06b00593          	li	a1,107
ffffffffc020111a:	00001517          	auipc	a0,0x1
ffffffffc020111e:	07e50513          	addi	a0,a0,126 # ffffffffc0202198 <buddy_pmm_manager+0xf0>
ffffffffc0201122:	a8aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201126:	00001617          	auipc	a2,0x1
ffffffffc020112a:	01a60613          	addi	a2,a2,26 # ffffffffc0202140 <buddy_pmm_manager+0x98>
ffffffffc020112e:	07000593          	li	a1,112
ffffffffc0201132:	00001517          	auipc	a0,0x1
ffffffffc0201136:	03650513          	addi	a0,a0,54 # ffffffffc0202168 <buddy_pmm_manager+0xc0>
ffffffffc020113a:	a72ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020113e:	86ae                	mv	a3,a1
ffffffffc0201140:	00001617          	auipc	a2,0x1
ffffffffc0201144:	00060613          	mv	a2,a2
ffffffffc0201148:	08b00593          	li	a1,139
ffffffffc020114c:	00001517          	auipc	a0,0x1
ffffffffc0201150:	01c50513          	addi	a0,a0,28 # ffffffffc0202168 <buddy_pmm_manager+0xc0>
ffffffffc0201154:	a58ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201158 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201158:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020115c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020115e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201162:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201164:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201168:	f022                	sd	s0,32(sp)
ffffffffc020116a:	ec26                	sd	s1,24(sp)
ffffffffc020116c:	e84a                	sd	s2,16(sp)
ffffffffc020116e:	f406                	sd	ra,40(sp)
ffffffffc0201170:	e44e                	sd	s3,8(sp)
ffffffffc0201172:	84aa                	mv	s1,a0
ffffffffc0201174:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201176:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020117a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020117c:	03067e63          	bgeu	a2,a6,ffffffffc02011b8 <printnum+0x60>
ffffffffc0201180:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201182:	00805763          	blez	s0,ffffffffc0201190 <printnum+0x38>
ffffffffc0201186:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201188:	85ca                	mv	a1,s2
ffffffffc020118a:	854e                	mv	a0,s3
ffffffffc020118c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020118e:	fc65                	bnez	s0,ffffffffc0201186 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201190:	1a02                	slli	s4,s4,0x20
ffffffffc0201192:	00001797          	auipc	a5,0x1
ffffffffc0201196:	07678793          	addi	a5,a5,118 # ffffffffc0202208 <buddy_pmm_manager+0x160>
ffffffffc020119a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020119e:	9a3e                	add	s4,s4,a5
}
ffffffffc02011a0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02011a2:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02011a6:	70a2                	ld	ra,40(sp)
ffffffffc02011a8:	69a2                	ld	s3,8(sp)
ffffffffc02011aa:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02011ac:	85ca                	mv	a1,s2
ffffffffc02011ae:	87a6                	mv	a5,s1
}
ffffffffc02011b0:	6942                	ld	s2,16(sp)
ffffffffc02011b2:	64e2                	ld	s1,24(sp)
ffffffffc02011b4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02011b6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02011b8:	03065633          	divu	a2,a2,a6
ffffffffc02011bc:	8722                	mv	a4,s0
ffffffffc02011be:	f9bff0ef          	jal	ra,ffffffffc0201158 <printnum>
ffffffffc02011c2:	b7f9                	j	ffffffffc0201190 <printnum+0x38>

ffffffffc02011c4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02011c4:	7119                	addi	sp,sp,-128
ffffffffc02011c6:	f4a6                	sd	s1,104(sp)
ffffffffc02011c8:	f0ca                	sd	s2,96(sp)
ffffffffc02011ca:	ecce                	sd	s3,88(sp)
ffffffffc02011cc:	e8d2                	sd	s4,80(sp)
ffffffffc02011ce:	e4d6                	sd	s5,72(sp)
ffffffffc02011d0:	e0da                	sd	s6,64(sp)
ffffffffc02011d2:	fc5e                	sd	s7,56(sp)
ffffffffc02011d4:	f06a                	sd	s10,32(sp)
ffffffffc02011d6:	fc86                	sd	ra,120(sp)
ffffffffc02011d8:	f8a2                	sd	s0,112(sp)
ffffffffc02011da:	f862                	sd	s8,48(sp)
ffffffffc02011dc:	f466                	sd	s9,40(sp)
ffffffffc02011de:	ec6e                	sd	s11,24(sp)
ffffffffc02011e0:	892a                	mv	s2,a0
ffffffffc02011e2:	84ae                	mv	s1,a1
ffffffffc02011e4:	8d32                	mv	s10,a2
ffffffffc02011e6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011e8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02011ec:	5b7d                	li	s6,-1
ffffffffc02011ee:	00001a97          	auipc	s5,0x1
ffffffffc02011f2:	04ea8a93          	addi	s5,s5,78 # ffffffffc020223c <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011f6:	00001b97          	auipc	s7,0x1
ffffffffc02011fa:	222b8b93          	addi	s7,s7,546 # ffffffffc0202418 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011fe:	000d4503          	lbu	a0,0(s10)
ffffffffc0201202:	001d0413          	addi	s0,s10,1
ffffffffc0201206:	01350a63          	beq	a0,s3,ffffffffc020121a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020120a:	c121                	beqz	a0,ffffffffc020124a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020120c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020120e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201210:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201212:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201216:	ff351ae3          	bne	a0,s3,ffffffffc020120a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020121a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020121e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201222:	4c81                	li	s9,0
ffffffffc0201224:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201226:	5c7d                	li	s8,-1
ffffffffc0201228:	5dfd                	li	s11,-1
ffffffffc020122a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020122e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201230:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201234:	0ff5f593          	zext.b	a1,a1
ffffffffc0201238:	00140d13          	addi	s10,s0,1
ffffffffc020123c:	04b56263          	bltu	a0,a1,ffffffffc0201280 <vprintfmt+0xbc>
ffffffffc0201240:	058a                	slli	a1,a1,0x2
ffffffffc0201242:	95d6                	add	a1,a1,s5
ffffffffc0201244:	4194                	lw	a3,0(a1)
ffffffffc0201246:	96d6                	add	a3,a3,s5
ffffffffc0201248:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020124a:	70e6                	ld	ra,120(sp)
ffffffffc020124c:	7446                	ld	s0,112(sp)
ffffffffc020124e:	74a6                	ld	s1,104(sp)
ffffffffc0201250:	7906                	ld	s2,96(sp)
ffffffffc0201252:	69e6                	ld	s3,88(sp)
ffffffffc0201254:	6a46                	ld	s4,80(sp)
ffffffffc0201256:	6aa6                	ld	s5,72(sp)
ffffffffc0201258:	6b06                	ld	s6,64(sp)
ffffffffc020125a:	7be2                	ld	s7,56(sp)
ffffffffc020125c:	7c42                	ld	s8,48(sp)
ffffffffc020125e:	7ca2                	ld	s9,40(sp)
ffffffffc0201260:	7d02                	ld	s10,32(sp)
ffffffffc0201262:	6de2                	ld	s11,24(sp)
ffffffffc0201264:	6109                	addi	sp,sp,128
ffffffffc0201266:	8082                	ret
            padc = '0';
ffffffffc0201268:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020126a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020126e:	846a                	mv	s0,s10
ffffffffc0201270:	00140d13          	addi	s10,s0,1
ffffffffc0201274:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201278:	0ff5f593          	zext.b	a1,a1
ffffffffc020127c:	fcb572e3          	bgeu	a0,a1,ffffffffc0201240 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201280:	85a6                	mv	a1,s1
ffffffffc0201282:	02500513          	li	a0,37
ffffffffc0201286:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201288:	fff44783          	lbu	a5,-1(s0)
ffffffffc020128c:	8d22                	mv	s10,s0
ffffffffc020128e:	f73788e3          	beq	a5,s3,ffffffffc02011fe <vprintfmt+0x3a>
ffffffffc0201292:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201296:	1d7d                	addi	s10,s10,-1
ffffffffc0201298:	ff379de3          	bne	a5,s3,ffffffffc0201292 <vprintfmt+0xce>
ffffffffc020129c:	b78d                	j	ffffffffc02011fe <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020129e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02012a2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012a6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02012a8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02012ac:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02012b0:	02d86463          	bltu	a6,a3,ffffffffc02012d8 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02012b4:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02012b8:	002c169b          	slliw	a3,s8,0x2
ffffffffc02012bc:	0186873b          	addw	a4,a3,s8
ffffffffc02012c0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02012c4:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02012c6:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02012ca:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02012cc:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02012d0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02012d4:	fed870e3          	bgeu	a6,a3,ffffffffc02012b4 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02012d8:	f40ddce3          	bgez	s11,ffffffffc0201230 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02012dc:	8de2                	mv	s11,s8
ffffffffc02012de:	5c7d                	li	s8,-1
ffffffffc02012e0:	bf81                	j	ffffffffc0201230 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02012e2:	fffdc693          	not	a3,s11
ffffffffc02012e6:	96fd                	srai	a3,a3,0x3f
ffffffffc02012e8:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012ec:	00144603          	lbu	a2,1(s0)
ffffffffc02012f0:	2d81                	sext.w	s11,s11
ffffffffc02012f2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012f4:	bf35                	j	ffffffffc0201230 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02012f6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012fa:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02012fe:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201300:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201302:	bfd9                	j	ffffffffc02012d8 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201304:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201306:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020130a:	01174463          	blt	a4,a7,ffffffffc0201312 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020130e:	1a088e63          	beqz	a7,ffffffffc02014ca <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201312:	000a3603          	ld	a2,0(s4)
ffffffffc0201316:	46c1                	li	a3,16
ffffffffc0201318:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020131a:	2781                	sext.w	a5,a5
ffffffffc020131c:	876e                	mv	a4,s11
ffffffffc020131e:	85a6                	mv	a1,s1
ffffffffc0201320:	854a                	mv	a0,s2
ffffffffc0201322:	e37ff0ef          	jal	ra,ffffffffc0201158 <printnum>
            break;
ffffffffc0201326:	bde1                	j	ffffffffc02011fe <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201328:	000a2503          	lw	a0,0(s4)
ffffffffc020132c:	85a6                	mv	a1,s1
ffffffffc020132e:	0a21                	addi	s4,s4,8
ffffffffc0201330:	9902                	jalr	s2
            break;
ffffffffc0201332:	b5f1                	j	ffffffffc02011fe <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201334:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201336:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020133a:	01174463          	blt	a4,a7,ffffffffc0201342 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020133e:	18088163          	beqz	a7,ffffffffc02014c0 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201342:	000a3603          	ld	a2,0(s4)
ffffffffc0201346:	46a9                	li	a3,10
ffffffffc0201348:	8a2e                	mv	s4,a1
ffffffffc020134a:	bfc1                	j	ffffffffc020131a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020134c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201350:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201352:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201354:	bdf1                	j	ffffffffc0201230 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201356:	85a6                	mv	a1,s1
ffffffffc0201358:	02500513          	li	a0,37
ffffffffc020135c:	9902                	jalr	s2
            break;
ffffffffc020135e:	b545                	j	ffffffffc02011fe <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201360:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201364:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201366:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201368:	b5e1                	j	ffffffffc0201230 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020136a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020136c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201370:	01174463          	blt	a4,a7,ffffffffc0201378 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201374:	14088163          	beqz	a7,ffffffffc02014b6 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201378:	000a3603          	ld	a2,0(s4)
ffffffffc020137c:	46a1                	li	a3,8
ffffffffc020137e:	8a2e                	mv	s4,a1
ffffffffc0201380:	bf69                	j	ffffffffc020131a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201382:	03000513          	li	a0,48
ffffffffc0201386:	85a6                	mv	a1,s1
ffffffffc0201388:	e03e                	sd	a5,0(sp)
ffffffffc020138a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020138c:	85a6                	mv	a1,s1
ffffffffc020138e:	07800513          	li	a0,120
ffffffffc0201392:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201394:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201396:	6782                	ld	a5,0(sp)
ffffffffc0201398:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020139a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020139e:	bfb5                	j	ffffffffc020131a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02013a0:	000a3403          	ld	s0,0(s4)
ffffffffc02013a4:	008a0713          	addi	a4,s4,8
ffffffffc02013a8:	e03a                	sd	a4,0(sp)
ffffffffc02013aa:	14040263          	beqz	s0,ffffffffc02014ee <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02013ae:	0fb05763          	blez	s11,ffffffffc020149c <vprintfmt+0x2d8>
ffffffffc02013b2:	02d00693          	li	a3,45
ffffffffc02013b6:	0cd79163          	bne	a5,a3,ffffffffc0201478 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013ba:	00044783          	lbu	a5,0(s0)
ffffffffc02013be:	0007851b          	sext.w	a0,a5
ffffffffc02013c2:	cf85                	beqz	a5,ffffffffc02013fa <vprintfmt+0x236>
ffffffffc02013c4:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013c8:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013cc:	000c4563          	bltz	s8,ffffffffc02013d6 <vprintfmt+0x212>
ffffffffc02013d0:	3c7d                	addiw	s8,s8,-1
ffffffffc02013d2:	036c0263          	beq	s8,s6,ffffffffc02013f6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02013d6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013d8:	0e0c8e63          	beqz	s9,ffffffffc02014d4 <vprintfmt+0x310>
ffffffffc02013dc:	3781                	addiw	a5,a5,-32
ffffffffc02013de:	0ef47b63          	bgeu	s0,a5,ffffffffc02014d4 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02013e2:	03f00513          	li	a0,63
ffffffffc02013e6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013e8:	000a4783          	lbu	a5,0(s4)
ffffffffc02013ec:	3dfd                	addiw	s11,s11,-1
ffffffffc02013ee:	0a05                	addi	s4,s4,1
ffffffffc02013f0:	0007851b          	sext.w	a0,a5
ffffffffc02013f4:	ffe1                	bnez	a5,ffffffffc02013cc <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02013f6:	01b05963          	blez	s11,ffffffffc0201408 <vprintfmt+0x244>
ffffffffc02013fa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02013fc:	85a6                	mv	a1,s1
ffffffffc02013fe:	02000513          	li	a0,32
ffffffffc0201402:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201404:	fe0d9be3          	bnez	s11,ffffffffc02013fa <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201408:	6a02                	ld	s4,0(sp)
ffffffffc020140a:	bbd5                	j	ffffffffc02011fe <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020140c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020140e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201412:	01174463          	blt	a4,a7,ffffffffc020141a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201416:	08088d63          	beqz	a7,ffffffffc02014b0 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020141a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020141e:	0a044d63          	bltz	s0,ffffffffc02014d8 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201422:	8622                	mv	a2,s0
ffffffffc0201424:	8a66                	mv	s4,s9
ffffffffc0201426:	46a9                	li	a3,10
ffffffffc0201428:	bdcd                	j	ffffffffc020131a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020142a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020142e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201430:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201432:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201436:	8fb5                	xor	a5,a5,a3
ffffffffc0201438:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020143c:	02d74163          	blt	a4,a3,ffffffffc020145e <vprintfmt+0x29a>
ffffffffc0201440:	00369793          	slli	a5,a3,0x3
ffffffffc0201444:	97de                	add	a5,a5,s7
ffffffffc0201446:	639c                	ld	a5,0(a5)
ffffffffc0201448:	cb99                	beqz	a5,ffffffffc020145e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020144a:	86be                	mv	a3,a5
ffffffffc020144c:	00001617          	auipc	a2,0x1
ffffffffc0201450:	dec60613          	addi	a2,a2,-532 # ffffffffc0202238 <buddy_pmm_manager+0x190>
ffffffffc0201454:	85a6                	mv	a1,s1
ffffffffc0201456:	854a                	mv	a0,s2
ffffffffc0201458:	0ce000ef          	jal	ra,ffffffffc0201526 <printfmt>
ffffffffc020145c:	b34d                	j	ffffffffc02011fe <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020145e:	00001617          	auipc	a2,0x1
ffffffffc0201462:	dca60613          	addi	a2,a2,-566 # ffffffffc0202228 <buddy_pmm_manager+0x180>
ffffffffc0201466:	85a6                	mv	a1,s1
ffffffffc0201468:	854a                	mv	a0,s2
ffffffffc020146a:	0bc000ef          	jal	ra,ffffffffc0201526 <printfmt>
ffffffffc020146e:	bb41                	j	ffffffffc02011fe <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201470:	00001417          	auipc	s0,0x1
ffffffffc0201474:	db040413          	addi	s0,s0,-592 # ffffffffc0202220 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201478:	85e2                	mv	a1,s8
ffffffffc020147a:	8522                	mv	a0,s0
ffffffffc020147c:	e43e                	sd	a5,8(sp)
ffffffffc020147e:	1cc000ef          	jal	ra,ffffffffc020164a <strnlen>
ffffffffc0201482:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201486:	01b05b63          	blez	s11,ffffffffc020149c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020148a:	67a2                	ld	a5,8(sp)
ffffffffc020148c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201490:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201492:	85a6                	mv	a1,s1
ffffffffc0201494:	8552                	mv	a0,s4
ffffffffc0201496:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201498:	fe0d9ce3          	bnez	s11,ffffffffc0201490 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020149c:	00044783          	lbu	a5,0(s0)
ffffffffc02014a0:	00140a13          	addi	s4,s0,1
ffffffffc02014a4:	0007851b          	sext.w	a0,a5
ffffffffc02014a8:	d3a5                	beqz	a5,ffffffffc0201408 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014aa:	05e00413          	li	s0,94
ffffffffc02014ae:	bf39                	j	ffffffffc02013cc <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02014b0:	000a2403          	lw	s0,0(s4)
ffffffffc02014b4:	b7ad                	j	ffffffffc020141e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02014b6:	000a6603          	lwu	a2,0(s4)
ffffffffc02014ba:	46a1                	li	a3,8
ffffffffc02014bc:	8a2e                	mv	s4,a1
ffffffffc02014be:	bdb1                	j	ffffffffc020131a <vprintfmt+0x156>
ffffffffc02014c0:	000a6603          	lwu	a2,0(s4)
ffffffffc02014c4:	46a9                	li	a3,10
ffffffffc02014c6:	8a2e                	mv	s4,a1
ffffffffc02014c8:	bd89                	j	ffffffffc020131a <vprintfmt+0x156>
ffffffffc02014ca:	000a6603          	lwu	a2,0(s4)
ffffffffc02014ce:	46c1                	li	a3,16
ffffffffc02014d0:	8a2e                	mv	s4,a1
ffffffffc02014d2:	b5a1                	j	ffffffffc020131a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02014d4:	9902                	jalr	s2
ffffffffc02014d6:	bf09                	j	ffffffffc02013e8 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02014d8:	85a6                	mv	a1,s1
ffffffffc02014da:	02d00513          	li	a0,45
ffffffffc02014de:	e03e                	sd	a5,0(sp)
ffffffffc02014e0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02014e2:	6782                	ld	a5,0(sp)
ffffffffc02014e4:	8a66                	mv	s4,s9
ffffffffc02014e6:	40800633          	neg	a2,s0
ffffffffc02014ea:	46a9                	li	a3,10
ffffffffc02014ec:	b53d                	j	ffffffffc020131a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02014ee:	03b05163          	blez	s11,ffffffffc0201510 <vprintfmt+0x34c>
ffffffffc02014f2:	02d00693          	li	a3,45
ffffffffc02014f6:	f6d79de3          	bne	a5,a3,ffffffffc0201470 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02014fa:	00001417          	auipc	s0,0x1
ffffffffc02014fe:	d2640413          	addi	s0,s0,-730 # ffffffffc0202220 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201502:	02800793          	li	a5,40
ffffffffc0201506:	02800513          	li	a0,40
ffffffffc020150a:	00140a13          	addi	s4,s0,1
ffffffffc020150e:	bd6d                	j	ffffffffc02013c8 <vprintfmt+0x204>
ffffffffc0201510:	00001a17          	auipc	s4,0x1
ffffffffc0201514:	d11a0a13          	addi	s4,s4,-751 # ffffffffc0202221 <buddy_pmm_manager+0x179>
ffffffffc0201518:	02800513          	li	a0,40
ffffffffc020151c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201520:	05e00413          	li	s0,94
ffffffffc0201524:	b565                	j	ffffffffc02013cc <vprintfmt+0x208>

ffffffffc0201526 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201526:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201528:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020152c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020152e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201530:	ec06                	sd	ra,24(sp)
ffffffffc0201532:	f83a                	sd	a4,48(sp)
ffffffffc0201534:	fc3e                	sd	a5,56(sp)
ffffffffc0201536:	e0c2                	sd	a6,64(sp)
ffffffffc0201538:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020153a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020153c:	c89ff0ef          	jal	ra,ffffffffc02011c4 <vprintfmt>
}
ffffffffc0201540:	60e2                	ld	ra,24(sp)
ffffffffc0201542:	6161                	addi	sp,sp,80
ffffffffc0201544:	8082                	ret

ffffffffc0201546 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201546:	715d                	addi	sp,sp,-80
ffffffffc0201548:	e486                	sd	ra,72(sp)
ffffffffc020154a:	e0a6                	sd	s1,64(sp)
ffffffffc020154c:	fc4a                	sd	s2,56(sp)
ffffffffc020154e:	f84e                	sd	s3,48(sp)
ffffffffc0201550:	f452                	sd	s4,40(sp)
ffffffffc0201552:	f056                	sd	s5,32(sp)
ffffffffc0201554:	ec5a                	sd	s6,24(sp)
ffffffffc0201556:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201558:	c901                	beqz	a0,ffffffffc0201568 <readline+0x22>
ffffffffc020155a:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020155c:	00001517          	auipc	a0,0x1
ffffffffc0201560:	cdc50513          	addi	a0,a0,-804 # ffffffffc0202238 <buddy_pmm_manager+0x190>
ffffffffc0201564:	b4ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201568:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020156a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020156c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020156e:	4aa9                	li	s5,10
ffffffffc0201570:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201572:	00005b97          	auipc	s7,0x5
ffffffffc0201576:	a9eb8b93          	addi	s7,s7,-1378 # ffffffffc0206010 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020157a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020157e:	badfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201582:	00054a63          	bltz	a0,ffffffffc0201596 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201586:	00a95a63          	bge	s2,a0,ffffffffc020159a <readline+0x54>
ffffffffc020158a:	029a5263          	bge	s4,s1,ffffffffc02015ae <readline+0x68>
        c = getchar();
ffffffffc020158e:	b9dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201592:	fe055ae3          	bgez	a0,ffffffffc0201586 <readline+0x40>
            return NULL;
ffffffffc0201596:	4501                	li	a0,0
ffffffffc0201598:	a091                	j	ffffffffc02015dc <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020159a:	03351463          	bne	a0,s3,ffffffffc02015c2 <readline+0x7c>
ffffffffc020159e:	e8a9                	bnez	s1,ffffffffc02015f0 <readline+0xaa>
        c = getchar();
ffffffffc02015a0:	b8bfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02015a4:	fe0549e3          	bltz	a0,ffffffffc0201596 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02015a8:	fea959e3          	bge	s2,a0,ffffffffc020159a <readline+0x54>
ffffffffc02015ac:	4481                	li	s1,0
            cputchar(c);
ffffffffc02015ae:	e42a                	sd	a0,8(sp)
ffffffffc02015b0:	b39fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02015b4:	6522                	ld	a0,8(sp)
ffffffffc02015b6:	009b87b3          	add	a5,s7,s1
ffffffffc02015ba:	2485                	addiw	s1,s1,1
ffffffffc02015bc:	00a78023          	sb	a0,0(a5)
ffffffffc02015c0:	bf7d                	j	ffffffffc020157e <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02015c2:	01550463          	beq	a0,s5,ffffffffc02015ca <readline+0x84>
ffffffffc02015c6:	fb651ce3          	bne	a0,s6,ffffffffc020157e <readline+0x38>
            cputchar(c);
ffffffffc02015ca:	b1ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02015ce:	00005517          	auipc	a0,0x5
ffffffffc02015d2:	a4250513          	addi	a0,a0,-1470 # ffffffffc0206010 <buf>
ffffffffc02015d6:	94aa                	add	s1,s1,a0
ffffffffc02015d8:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02015dc:	60a6                	ld	ra,72(sp)
ffffffffc02015de:	6486                	ld	s1,64(sp)
ffffffffc02015e0:	7962                	ld	s2,56(sp)
ffffffffc02015e2:	79c2                	ld	s3,48(sp)
ffffffffc02015e4:	7a22                	ld	s4,40(sp)
ffffffffc02015e6:	7a82                	ld	s5,32(sp)
ffffffffc02015e8:	6b62                	ld	s6,24(sp)
ffffffffc02015ea:	6bc2                	ld	s7,16(sp)
ffffffffc02015ec:	6161                	addi	sp,sp,80
ffffffffc02015ee:	8082                	ret
            cputchar(c);
ffffffffc02015f0:	4521                	li	a0,8
ffffffffc02015f2:	af7fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02015f6:	34fd                	addiw	s1,s1,-1
ffffffffc02015f8:	b759                	j	ffffffffc020157e <readline+0x38>

ffffffffc02015fa <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02015fa:	4781                	li	a5,0
ffffffffc02015fc:	00005717          	auipc	a4,0x5
ffffffffc0201600:	a0c73703          	ld	a4,-1524(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201604:	88ba                	mv	a7,a4
ffffffffc0201606:	852a                	mv	a0,a0
ffffffffc0201608:	85be                	mv	a1,a5
ffffffffc020160a:	863e                	mv	a2,a5
ffffffffc020160c:	00000073          	ecall
ffffffffc0201610:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201612:	8082                	ret

ffffffffc0201614 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201614:	4781                	li	a5,0
ffffffffc0201616:	00005717          	auipc	a4,0x5
ffffffffc020161a:	e5a73703          	ld	a4,-422(a4) # ffffffffc0206470 <SBI_SET_TIMER>
ffffffffc020161e:	88ba                	mv	a7,a4
ffffffffc0201620:	852a                	mv	a0,a0
ffffffffc0201622:	85be                	mv	a1,a5
ffffffffc0201624:	863e                	mv	a2,a5
ffffffffc0201626:	00000073          	ecall
ffffffffc020162a:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020162c:	8082                	ret

ffffffffc020162e <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020162e:	4501                	li	a0,0
ffffffffc0201630:	00005797          	auipc	a5,0x5
ffffffffc0201634:	9d07b783          	ld	a5,-1584(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201638:	88be                	mv	a7,a5
ffffffffc020163a:	852a                	mv	a0,a0
ffffffffc020163c:	85aa                	mv	a1,a0
ffffffffc020163e:	862a                	mv	a2,a0
ffffffffc0201640:	00000073          	ecall
ffffffffc0201644:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201646:	2501                	sext.w	a0,a0
ffffffffc0201648:	8082                	ret

ffffffffc020164a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020164a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020164c:	e589                	bnez	a1,ffffffffc0201656 <strnlen+0xc>
ffffffffc020164e:	a811                	j	ffffffffc0201662 <strnlen+0x18>
        cnt ++;
ffffffffc0201650:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201652:	00f58863          	beq	a1,a5,ffffffffc0201662 <strnlen+0x18>
ffffffffc0201656:	00f50733          	add	a4,a0,a5
ffffffffc020165a:	00074703          	lbu	a4,0(a4)
ffffffffc020165e:	fb6d                	bnez	a4,ffffffffc0201650 <strnlen+0x6>
ffffffffc0201660:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201662:	852e                	mv	a0,a1
ffffffffc0201664:	8082                	ret

ffffffffc0201666 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201666:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020166a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020166e:	cb89                	beqz	a5,ffffffffc0201680 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201670:	0505                	addi	a0,a0,1
ffffffffc0201672:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201674:	fee789e3          	beq	a5,a4,ffffffffc0201666 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201678:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020167c:	9d19                	subw	a0,a0,a4
ffffffffc020167e:	8082                	ret
ffffffffc0201680:	4501                	li	a0,0
ffffffffc0201682:	bfed                	j	ffffffffc020167c <strcmp+0x16>

ffffffffc0201684 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201684:	00054783          	lbu	a5,0(a0)
ffffffffc0201688:	c799                	beqz	a5,ffffffffc0201696 <strchr+0x12>
        if (*s == c) {
ffffffffc020168a:	00f58763          	beq	a1,a5,ffffffffc0201698 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020168e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201692:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201694:	fbfd                	bnez	a5,ffffffffc020168a <strchr+0x6>
    }
    return NULL;
ffffffffc0201696:	4501                	li	a0,0
}
ffffffffc0201698:	8082                	ret

ffffffffc020169a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020169a:	ca01                	beqz	a2,ffffffffc02016aa <memset+0x10>
ffffffffc020169c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020169e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02016a0:	0785                	addi	a5,a5,1
ffffffffc02016a2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02016a6:	fec79de3          	bne	a5,a2,ffffffffc02016a0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02016aa:	8082                	ret
