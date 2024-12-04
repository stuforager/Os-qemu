
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020a060 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5ba60613          	addi	a2,a2,1466 # ffffffffc02155f8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	5f9040ef          	jal	ra,ffffffffc0204e46 <memset>

    cons_init();                // init the console
ffffffffc0200052:	4ae000ef          	jal	ra,ffffffffc0200500 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	e4a58593          	addi	a1,a1,-438 # ffffffffc0204ea0 <etext>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	e6250513          	addi	a0,a0,-414 # ffffffffc0204ec0 <etext+0x20>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	16a000ef          	jal	ra,ffffffffc02001d4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	765010ef          	jal	ra,ffffffffc0201fd2 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	564000ef          	jal	ra,ffffffffc02005d6 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5d4000ef          	jal	ra,ffffffffc020064a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	169030ef          	jal	ra,ffffffffc02039e2 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	5bc040ef          	jal	ra,ffffffffc020463a <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4f0000ef          	jal	ra,ffffffffc0200572 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	26b020ef          	jal	ra,ffffffffc0202af0 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	422000ef          	jal	ra,ffffffffc02004ac <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	53c000ef          	jal	ra,ffffffffc02005ca <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	7c0040ef          	jal	ra,ffffffffc0204852 <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00005517          	auipc	a0,0x5
ffffffffc02000b2:	e1a50513          	addi	a0,a0,-486 # ffffffffc0204ec8 <etext+0x28>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	0000ab97          	auipc	s7,0xa
ffffffffc02000c8:	f9cb8b93          	addi	s7,s7,-100 # ffffffffc020a060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	0f4000ef          	jal	ra,ffffffffc02001c4 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	bge	s2,a0,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	bge	s4,s1,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	0e2000ef          	jal	ra,ffffffffc02001c4 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	0ce000ef          	jal	ra,ffffffffc02001c4 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	bge	s2,a0,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	0000a517          	auipc	a0,0xa
ffffffffc020012a:	f3a50513          	addi	a0,a0,-198 # ffffffffc020a060 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	3a6000ef          	jal	ra,ffffffffc0200502 <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	0a7040ef          	jal	ra,ffffffffc0204a28 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	073040ef          	jal	ra,ffffffffc0204a28 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	a681                	j	ffffffffc0200502 <cons_putc>

ffffffffc02001c4 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001c4:	1141                	addi	sp,sp,-16
ffffffffc02001c6:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001c8:	36e000ef          	jal	ra,ffffffffc0200536 <cons_getc>
ffffffffc02001cc:	dd75                	beqz	a0,ffffffffc02001c8 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001ce:	60a2                	ld	ra,8(sp)
ffffffffc02001d0:	0141                	addi	sp,sp,16
ffffffffc02001d2:	8082                	ret

ffffffffc02001d4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001d4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001d6:	00005517          	auipc	a0,0x5
ffffffffc02001da:	d2a50513          	addi	a0,a0,-726 # ffffffffc0204f00 <etext+0x60>
void print_kerninfo(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e0:	fafff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001e4:	00000597          	auipc	a1,0x0
ffffffffc02001e8:	e5258593          	addi	a1,a1,-430 # ffffffffc0200036 <kern_init>
ffffffffc02001ec:	00005517          	auipc	a0,0x5
ffffffffc02001f0:	d3450513          	addi	a0,a0,-716 # ffffffffc0204f20 <etext+0x80>
ffffffffc02001f4:	f9bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001f8:	00005597          	auipc	a1,0x5
ffffffffc02001fc:	ca858593          	addi	a1,a1,-856 # ffffffffc0204ea0 <etext>
ffffffffc0200200:	00005517          	auipc	a0,0x5
ffffffffc0200204:	d4050513          	addi	a0,a0,-704 # ffffffffc0204f40 <etext+0xa0>
ffffffffc0200208:	f87ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020020c:	0000a597          	auipc	a1,0xa
ffffffffc0200210:	e5458593          	addi	a1,a1,-428 # ffffffffc020a060 <edata>
ffffffffc0200214:	00005517          	auipc	a0,0x5
ffffffffc0200218:	d4c50513          	addi	a0,a0,-692 # ffffffffc0204f60 <etext+0xc0>
ffffffffc020021c:	f73ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200220:	00015597          	auipc	a1,0x15
ffffffffc0200224:	3d858593          	addi	a1,a1,984 # ffffffffc02155f8 <end>
ffffffffc0200228:	00005517          	auipc	a0,0x5
ffffffffc020022c:	d5850513          	addi	a0,a0,-680 # ffffffffc0204f80 <etext+0xe0>
ffffffffc0200230:	f5fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200234:	00015597          	auipc	a1,0x15
ffffffffc0200238:	7c358593          	addi	a1,a1,1987 # ffffffffc02159f7 <end+0x3ff>
ffffffffc020023c:	00000797          	auipc	a5,0x0
ffffffffc0200240:	dfa78793          	addi	a5,a5,-518 # ffffffffc0200036 <kern_init>
ffffffffc0200244:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200248:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200252:	95be                	add	a1,a1,a5
ffffffffc0200254:	85a9                	srai	a1,a1,0xa
ffffffffc0200256:	00005517          	auipc	a0,0x5
ffffffffc020025a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0204fa0 <etext+0x100>
}
ffffffffc020025e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200260:	b73d                	j	ffffffffc020018e <cprintf>

ffffffffc0200262 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200262:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200264:	00005617          	auipc	a2,0x5
ffffffffc0200268:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204ed0 <etext+0x30>
ffffffffc020026c:	04d00593          	li	a1,77
ffffffffc0200270:	00005517          	auipc	a0,0x5
ffffffffc0200274:	c7850513          	addi	a0,a0,-904 # ffffffffc0204ee8 <etext+0x48>
void print_stackframe(void) {
ffffffffc0200278:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027a:	1d2000ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020027e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020027e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200280:	00005617          	auipc	a2,0x5
ffffffffc0200284:	e3060613          	addi	a2,a2,-464 # ffffffffc02050b0 <commands+0xe0>
ffffffffc0200288:	00005597          	auipc	a1,0x5
ffffffffc020028c:	e4858593          	addi	a1,a1,-440 # ffffffffc02050d0 <commands+0x100>
ffffffffc0200290:	00005517          	auipc	a0,0x5
ffffffffc0200294:	e4850513          	addi	a0,a0,-440 # ffffffffc02050d8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200298:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029a:	ef5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020029e:	00005617          	auipc	a2,0x5
ffffffffc02002a2:	e4a60613          	addi	a2,a2,-438 # ffffffffc02050e8 <commands+0x118>
ffffffffc02002a6:	00005597          	auipc	a1,0x5
ffffffffc02002aa:	e6a58593          	addi	a1,a1,-406 # ffffffffc0205110 <commands+0x140>
ffffffffc02002ae:	00005517          	auipc	a0,0x5
ffffffffc02002b2:	e2a50513          	addi	a0,a0,-470 # ffffffffc02050d8 <commands+0x108>
ffffffffc02002b6:	ed9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002ba:	00005617          	auipc	a2,0x5
ffffffffc02002be:	e6660613          	addi	a2,a2,-410 # ffffffffc0205120 <commands+0x150>
ffffffffc02002c2:	00005597          	auipc	a1,0x5
ffffffffc02002c6:	e7e58593          	addi	a1,a1,-386 # ffffffffc0205140 <commands+0x170>
ffffffffc02002ca:	00005517          	auipc	a0,0x5
ffffffffc02002ce:	e0e50513          	addi	a0,a0,-498 # ffffffffc02050d8 <commands+0x108>
ffffffffc02002d2:	ebdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc02002d6:	60a2                	ld	ra,8(sp)
ffffffffc02002d8:	4501                	li	a0,0
ffffffffc02002da:	0141                	addi	sp,sp,16
ffffffffc02002dc:	8082                	ret

ffffffffc02002de <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002de:	1141                	addi	sp,sp,-16
ffffffffc02002e0:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002e2:	ef3ff0ef          	jal	ra,ffffffffc02001d4 <print_kerninfo>
    return 0;
}
ffffffffc02002e6:	60a2                	ld	ra,8(sp)
ffffffffc02002e8:	4501                	li	a0,0
ffffffffc02002ea:	0141                	addi	sp,sp,16
ffffffffc02002ec:	8082                	ret

ffffffffc02002ee <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ee:	1141                	addi	sp,sp,-16
ffffffffc02002f0:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002f2:	f71ff0ef          	jal	ra,ffffffffc0200262 <print_stackframe>
    return 0;
}
ffffffffc02002f6:	60a2                	ld	ra,8(sp)
ffffffffc02002f8:	4501                	li	a0,0
ffffffffc02002fa:	0141                	addi	sp,sp,16
ffffffffc02002fc:	8082                	ret

ffffffffc02002fe <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002fe:	7115                	addi	sp,sp,-224
ffffffffc0200300:	e962                	sd	s8,144(sp)
ffffffffc0200302:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200304:	00005517          	auipc	a0,0x5
ffffffffc0200308:	d1450513          	addi	a0,a0,-748 # ffffffffc0205018 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020030c:	ed86                	sd	ra,216(sp)
ffffffffc020030e:	e9a2                	sd	s0,208(sp)
ffffffffc0200310:	e5a6                	sd	s1,200(sp)
ffffffffc0200312:	e1ca                	sd	s2,192(sp)
ffffffffc0200314:	fd4e                	sd	s3,184(sp)
ffffffffc0200316:	f952                	sd	s4,176(sp)
ffffffffc0200318:	f556                	sd	s5,168(sp)
ffffffffc020031a:	f15a                	sd	s6,160(sp)
ffffffffc020031c:	ed5e                	sd	s7,152(sp)
ffffffffc020031e:	e566                	sd	s9,136(sp)
ffffffffc0200320:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200322:	e6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200326:	00005517          	auipc	a0,0x5
ffffffffc020032a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0205040 <commands+0x70>
ffffffffc020032e:	e61ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200332:	000c0563          	beqz	s8,ffffffffc020033c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200336:	8562                	mv	a0,s8
ffffffffc0200338:	4f8000ef          	jal	ra,ffffffffc0200830 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	4581                	li	a1,0
ffffffffc0200340:	4601                	li	a2,0
ffffffffc0200342:	48a1                	li	a7,8
ffffffffc0200344:	00000073          	ecall
ffffffffc0200348:	00005c97          	auipc	s9,0x5
ffffffffc020034c:	c88c8c93          	addi	s9,s9,-888 # ffffffffc0204fd0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200350:	00005997          	auipc	s3,0x5
ffffffffc0200354:	d1898993          	addi	s3,s3,-744 # ffffffffc0205068 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200358:	00005917          	auipc	s2,0x5
ffffffffc020035c:	d1890913          	addi	s2,s2,-744 # ffffffffc0205070 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200362:	00005b17          	auipc	s6,0x5
ffffffffc0200366:	d16b0b13          	addi	s6,s6,-746 # ffffffffc0205078 <commands+0xa8>
    if (argc == 0) {
ffffffffc020036a:	00005a97          	auipc	s5,0x5
ffffffffc020036e:	d66a8a93          	addi	s5,s5,-666 # ffffffffc02050d0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200374:	854e                	mv	a0,s3
ffffffffc0200376:	d21ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc020037a:	842a                	mv	s0,a0
ffffffffc020037c:	dd65                	beqz	a0,ffffffffc0200374 <kmonitor+0x76>
ffffffffc020037e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200382:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200384:	c999                	beqz	a1,ffffffffc020039a <kmonitor+0x9c>
ffffffffc0200386:	854a                	mv	a0,s2
ffffffffc0200388:	2a1040ef          	jal	ra,ffffffffc0204e28 <strchr>
ffffffffc020038c:	c925                	beqz	a0,ffffffffc02003fc <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc020038e:	00144583          	lbu	a1,1(s0)
ffffffffc0200392:	00040023          	sb	zero,0(s0)
ffffffffc0200396:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200398:	f5fd                	bnez	a1,ffffffffc0200386 <kmonitor+0x88>
    if (argc == 0) {
ffffffffc020039a:	dce9                	beqz	s1,ffffffffc0200374 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00005d17          	auipc	s10,0x5
ffffffffc02003a2:	c32d0d13          	addi	s10,s10,-974 # ffffffffc0204fd0 <commands>
    if (argc == 0) {
ffffffffc02003a6:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a8:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003aa:	0d61                	addi	s10,s10,24
ffffffffc02003ac:	253040ef          	jal	ra,ffffffffc0204dfe <strcmp>
ffffffffc02003b0:	c919                	beqz	a0,ffffffffc02003c6 <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b2:	2405                	addiw	s0,s0,1
ffffffffc02003b4:	09740463          	beq	s0,s7,ffffffffc020043c <kmonitor+0x13e>
ffffffffc02003b8:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003bc:	6582                	ld	a1,0(sp)
ffffffffc02003be:	0d61                	addi	s10,s10,24
ffffffffc02003c0:	23f040ef          	jal	ra,ffffffffc0204dfe <strcmp>
ffffffffc02003c4:	f57d                	bnez	a0,ffffffffc02003b2 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003c6:	00141793          	slli	a5,s0,0x1
ffffffffc02003ca:	97a2                	add	a5,a5,s0
ffffffffc02003cc:	078e                	slli	a5,a5,0x3
ffffffffc02003ce:	97e6                	add	a5,a5,s9
ffffffffc02003d0:	6b9c                	ld	a5,16(a5)
ffffffffc02003d2:	8662                	mv	a2,s8
ffffffffc02003d4:	002c                	addi	a1,sp,8
ffffffffc02003d6:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003da:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003dc:	f8055ce3          	bgez	a0,ffffffffc0200374 <kmonitor+0x76>
}
ffffffffc02003e0:	60ee                	ld	ra,216(sp)
ffffffffc02003e2:	644e                	ld	s0,208(sp)
ffffffffc02003e4:	64ae                	ld	s1,200(sp)
ffffffffc02003e6:	690e                	ld	s2,192(sp)
ffffffffc02003e8:	79ea                	ld	s3,184(sp)
ffffffffc02003ea:	7a4a                	ld	s4,176(sp)
ffffffffc02003ec:	7aaa                	ld	s5,168(sp)
ffffffffc02003ee:	7b0a                	ld	s6,160(sp)
ffffffffc02003f0:	6bea                	ld	s7,152(sp)
ffffffffc02003f2:	6c4a                	ld	s8,144(sp)
ffffffffc02003f4:	6caa                	ld	s9,136(sp)
ffffffffc02003f6:	6d0a                	ld	s10,128(sp)
ffffffffc02003f8:	612d                	addi	sp,sp,224
ffffffffc02003fa:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003fc:	00044783          	lbu	a5,0(s0)
ffffffffc0200400:	dfc9                	beqz	a5,ffffffffc020039a <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200402:	03448863          	beq	s1,s4,ffffffffc0200432 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc0200406:	00349793          	slli	a5,s1,0x3
ffffffffc020040a:	0118                	addi	a4,sp,128
ffffffffc020040c:	97ba                	add	a5,a5,a4
ffffffffc020040e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200412:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200416:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200418:	e591                	bnez	a1,ffffffffc0200424 <kmonitor+0x126>
ffffffffc020041a:	b749                	j	ffffffffc020039c <kmonitor+0x9e>
            buf ++;
ffffffffc020041c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041e:	00044583          	lbu	a1,0(s0)
ffffffffc0200422:	ddad                	beqz	a1,ffffffffc020039c <kmonitor+0x9e>
ffffffffc0200424:	854a                	mv	a0,s2
ffffffffc0200426:	203040ef          	jal	ra,ffffffffc0204e28 <strchr>
ffffffffc020042a:	d96d                	beqz	a0,ffffffffc020041c <kmonitor+0x11e>
ffffffffc020042c:	00044583          	lbu	a1,0(s0)
ffffffffc0200430:	bf91                	j	ffffffffc0200384 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200432:	45c1                	li	a1,16
ffffffffc0200434:	855a                	mv	a0,s6
ffffffffc0200436:	d59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020043a:	b7f1                	j	ffffffffc0200406 <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020043c:	6582                	ld	a1,0(sp)
ffffffffc020043e:	00005517          	auipc	a0,0x5
ffffffffc0200442:	c5a50513          	addi	a0,a0,-934 # ffffffffc0205098 <commands+0xc8>
ffffffffc0200446:	d49ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020044a:	b72d                	j	ffffffffc0200374 <kmonitor+0x76>

ffffffffc020044c <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020044c:	00015317          	auipc	t1,0x15
ffffffffc0200450:	02430313          	addi	t1,t1,36 # ffffffffc0215470 <is_panic>
ffffffffc0200454:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200458:	715d                	addi	sp,sp,-80
ffffffffc020045a:	ec06                	sd	ra,24(sp)
ffffffffc020045c:	e822                	sd	s0,16(sp)
ffffffffc020045e:	f436                	sd	a3,40(sp)
ffffffffc0200460:	f83a                	sd	a4,48(sp)
ffffffffc0200462:	fc3e                	sd	a5,56(sp)
ffffffffc0200464:	e0c2                	sd	a6,64(sp)
ffffffffc0200466:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200468:	02031c63          	bnez	t1,ffffffffc02004a0 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020046c:	4785                	li	a5,1
ffffffffc020046e:	8432                	mv	s0,a2
ffffffffc0200470:	00015717          	auipc	a4,0x15
ffffffffc0200474:	00f72023          	sw	a5,0(a4) # ffffffffc0215470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200478:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020047a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047c:	85aa                	mv	a1,a0
ffffffffc020047e:	00005517          	auipc	a0,0x5
ffffffffc0200482:	cd250513          	addi	a0,a0,-814 # ffffffffc0205150 <commands+0x180>
    va_start(ap, fmt);
ffffffffc0200486:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200488:	d07ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc020048c:	65a2                	ld	a1,8(sp)
ffffffffc020048e:	8522                	mv	a0,s0
ffffffffc0200490:	cdfff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc0200494:	00006517          	auipc	a0,0x6
ffffffffc0200498:	c4450513          	addi	a0,a0,-956 # ffffffffc02060d8 <default_pmm_manager+0x500>
ffffffffc020049c:	cf3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004a0:	130000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004a4:	4501                	li	a0,0
ffffffffc02004a6:	e59ff0ef          	jal	ra,ffffffffc02002fe <kmonitor>
ffffffffc02004aa:	bfed                	j	ffffffffc02004a4 <__panic+0x58>

ffffffffc02004ac <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004ac:	67e1                	lui	a5,0x18
ffffffffc02004ae:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004b2:	00015717          	auipc	a4,0x15
ffffffffc02004b6:	fcf73323          	sd	a5,-58(a4) # ffffffffc0215478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ba:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004be:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004c0:	953e                	add	a0,a0,a5
ffffffffc02004c2:	4601                	li	a2,0
ffffffffc02004c4:	4881                	li	a7,0
ffffffffc02004c6:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004ca:	02000793          	li	a5,32
ffffffffc02004ce:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d2:	00005517          	auipc	a0,0x5
ffffffffc02004d6:	c9e50513          	addi	a0,a0,-866 # ffffffffc0205170 <commands+0x1a0>
    ticks = 0;
ffffffffc02004da:	00015797          	auipc	a5,0x15
ffffffffc02004de:	fe07b723          	sd	zero,-18(a5) # ffffffffc02154c8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004e2:	b175                	j	ffffffffc020018e <cprintf>

ffffffffc02004e4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004e4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004e8:	00015797          	auipc	a5,0x15
ffffffffc02004ec:	f9078793          	addi	a5,a5,-112 # ffffffffc0215478 <timebase>
ffffffffc02004f0:	639c                	ld	a5,0(a5)
ffffffffc02004f2:	4581                	li	a1,0
ffffffffc02004f4:	4601                	li	a2,0
ffffffffc02004f6:	953e                	add	a0,a0,a5
ffffffffc02004f8:	4881                	li	a7,0
ffffffffc02004fa:	00000073          	ecall
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200500:	8082                	ret

ffffffffc0200502 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200502:	100027f3          	csrr	a5,sstatus
ffffffffc0200506:	8b89                	andi	a5,a5,2
ffffffffc0200508:	0ff57513          	andi	a0,a0,255
ffffffffc020050c:	e799                	bnez	a5,ffffffffc020051a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020050e:	4581                	li	a1,0
ffffffffc0200510:	4601                	li	a2,0
ffffffffc0200512:	4885                	li	a7,1
ffffffffc0200514:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200518:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020051a:	1101                	addi	sp,sp,-32
ffffffffc020051c:	ec06                	sd	ra,24(sp)
ffffffffc020051e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200520:	0b0000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0200524:	6522                	ld	a0,8(sp)
ffffffffc0200526:	4581                	li	a1,0
ffffffffc0200528:	4601                	li	a2,0
ffffffffc020052a:	4885                	li	a7,1
ffffffffc020052c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200530:	60e2                	ld	ra,24(sp)
ffffffffc0200532:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200534:	a859                	j	ffffffffc02005ca <intr_enable>

ffffffffc0200536 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200536:	100027f3          	csrr	a5,sstatus
ffffffffc020053a:	8b89                	andi	a5,a5,2
ffffffffc020053c:	eb89                	bnez	a5,ffffffffc020054e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020053e:	4501                	li	a0,0
ffffffffc0200540:	4581                	li	a1,0
ffffffffc0200542:	4601                	li	a2,0
ffffffffc0200544:	4889                	li	a7,2
ffffffffc0200546:	00000073          	ecall
ffffffffc020054a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020054c:	8082                	ret
int cons_getc(void) {
ffffffffc020054e:	1101                	addi	sp,sp,-32
ffffffffc0200550:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200552:	07e000ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0200556:	4501                	li	a0,0
ffffffffc0200558:	4581                	li	a1,0
ffffffffc020055a:	4601                	li	a2,0
ffffffffc020055c:	4889                	li	a7,2
ffffffffc020055e:	00000073          	ecall
ffffffffc0200562:	2501                	sext.w	a0,a0
ffffffffc0200564:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200566:	064000ef          	jal	ra,ffffffffc02005ca <intr_enable>
}
ffffffffc020056a:	60e2                	ld	ra,24(sp)
ffffffffc020056c:	6522                	ld	a0,8(sp)
ffffffffc020056e:	6105                	addi	sp,sp,32
ffffffffc0200570:	8082                	ret

ffffffffc0200572 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200574:	00253513          	sltiu	a0,a0,2
ffffffffc0200578:	8082                	ret

ffffffffc020057a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020057a:	03800513          	li	a0,56
ffffffffc020057e:	8082                	ret

ffffffffc0200580 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200580:	0000a797          	auipc	a5,0xa
ffffffffc0200584:	ee078793          	addi	a5,a5,-288 # ffffffffc020a460 <ide>
ffffffffc0200588:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020058c:	1141                	addi	sp,sp,-16
ffffffffc020058e:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200590:	95be                	add	a1,a1,a5
ffffffffc0200592:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200596:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200598:	0c1040ef          	jal	ra,ffffffffc0204e58 <memcpy>
    return 0;
}
ffffffffc020059c:	60a2                	ld	ra,8(sp)
ffffffffc020059e:	4501                	li	a0,0
ffffffffc02005a0:	0141                	addi	sp,sp,16
ffffffffc02005a2:	8082                	ret

ffffffffc02005a4 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02005a4:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005a6:	0095979b          	slliw	a5,a1,0x9
ffffffffc02005aa:	0000a517          	auipc	a0,0xa
ffffffffc02005ae:	eb650513          	addi	a0,a0,-330 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02005b2:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005b4:	00969613          	slli	a2,a3,0x9
ffffffffc02005b8:	85ba                	mv	a1,a4
ffffffffc02005ba:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02005bc:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005be:	09b040ef          	jal	ra,ffffffffc0204e58 <memcpy>
    return 0;
}
ffffffffc02005c2:	60a2                	ld	ra,8(sp)
ffffffffc02005c4:	4501                	li	a0,0
ffffffffc02005c6:	0141                	addi	sp,sp,16
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005ca:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005ce:	8082                	ret

ffffffffc02005d0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d0:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005d4:	8082                	ret

ffffffffc02005d6 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005d6:	8082                	ret

ffffffffc02005d8 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d8:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	1141                	addi	sp,sp,-16
ffffffffc02005de:	e022                	sd	s0,0(sp)
ffffffffc02005e0:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e2:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e6:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005e8:	11053583          	ld	a1,272(a0)
ffffffffc02005ec:	05500613          	li	a2,85
ffffffffc02005f0:	c399                	beqz	a5,ffffffffc02005f6 <pgfault_handler+0x1e>
ffffffffc02005f2:	04b00613          	li	a2,75
ffffffffc02005f6:	11843703          	ld	a4,280(s0)
ffffffffc02005fa:	47bd                	li	a5,15
ffffffffc02005fc:	05700693          	li	a3,87
ffffffffc0200600:	00f70463          	beq	a4,a5,ffffffffc0200608 <pgfault_handler+0x30>
ffffffffc0200604:	05200693          	li	a3,82
ffffffffc0200608:	00005517          	auipc	a0,0x5
ffffffffc020060c:	e6050513          	addi	a0,a0,-416 # ffffffffc0205468 <commands+0x498>
ffffffffc0200610:	b7fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200614:	00015797          	auipc	a5,0x15
ffffffffc0200618:	fcc78793          	addi	a5,a5,-52 # ffffffffc02155e0 <check_mm_struct>
ffffffffc020061c:	6388                	ld	a0,0(a5)
ffffffffc020061e:	c911                	beqz	a0,ffffffffc0200632 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200620:	11043603          	ld	a2,272(s0)
ffffffffc0200624:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200628:	6402                	ld	s0,0(sp)
ffffffffc020062a:	60a2                	ld	ra,8(sp)
ffffffffc020062c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020062e:	0fb0306f          	j	ffffffffc0203f28 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200632:	00005617          	auipc	a2,0x5
ffffffffc0200636:	e5660613          	addi	a2,a2,-426 # ffffffffc0205488 <commands+0x4b8>
ffffffffc020063a:	06200593          	li	a1,98
ffffffffc020063e:	00005517          	auipc	a0,0x5
ffffffffc0200642:	e6250513          	addi	a0,a0,-414 # ffffffffc02054a0 <commands+0x4d0>
ffffffffc0200646:	e07ff0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020064a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020064a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020064e:	00000797          	auipc	a5,0x0
ffffffffc0200652:	47e78793          	addi	a5,a5,1150 # ffffffffc0200acc <__alltraps>
ffffffffc0200656:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065a:	000407b7          	lui	a5,0x40
ffffffffc020065e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200662:	8082                	ret

ffffffffc0200664 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200664:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200666:	1141                	addi	sp,sp,-16
ffffffffc0200668:	e022                	sd	s0,0(sp)
ffffffffc020066a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	e4c50513          	addi	a0,a0,-436 # ffffffffc02054b8 <commands+0x4e8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200674:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200676:	b19ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067a:	640c                	ld	a1,8(s0)
ffffffffc020067c:	00005517          	auipc	a0,0x5
ffffffffc0200680:	e5450513          	addi	a0,a0,-428 # ffffffffc02054d0 <commands+0x500>
ffffffffc0200684:	b0bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200688:	680c                	ld	a1,16(s0)
ffffffffc020068a:	00005517          	auipc	a0,0x5
ffffffffc020068e:	e5e50513          	addi	a0,a0,-418 # ffffffffc02054e8 <commands+0x518>
ffffffffc0200692:	afdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200696:	6c0c                	ld	a1,24(s0)
ffffffffc0200698:	00005517          	auipc	a0,0x5
ffffffffc020069c:	e6850513          	addi	a0,a0,-408 # ffffffffc0205500 <commands+0x530>
ffffffffc02006a0:	aefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a4:	700c                	ld	a1,32(s0)
ffffffffc02006a6:	00005517          	auipc	a0,0x5
ffffffffc02006aa:	e7250513          	addi	a0,a0,-398 # ffffffffc0205518 <commands+0x548>
ffffffffc02006ae:	ae1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b2:	740c                	ld	a1,40(s0)
ffffffffc02006b4:	00005517          	auipc	a0,0x5
ffffffffc02006b8:	e7c50513          	addi	a0,a0,-388 # ffffffffc0205530 <commands+0x560>
ffffffffc02006bc:	ad3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c0:	780c                	ld	a1,48(s0)
ffffffffc02006c2:	00005517          	auipc	a0,0x5
ffffffffc02006c6:	e8650513          	addi	a0,a0,-378 # ffffffffc0205548 <commands+0x578>
ffffffffc02006ca:	ac5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ce:	7c0c                	ld	a1,56(s0)
ffffffffc02006d0:	00005517          	auipc	a0,0x5
ffffffffc02006d4:	e9050513          	addi	a0,a0,-368 # ffffffffc0205560 <commands+0x590>
ffffffffc02006d8:	ab7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006dc:	602c                	ld	a1,64(s0)
ffffffffc02006de:	00005517          	auipc	a0,0x5
ffffffffc02006e2:	e9a50513          	addi	a0,a0,-358 # ffffffffc0205578 <commands+0x5a8>
ffffffffc02006e6:	aa9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ea:	642c                	ld	a1,72(s0)
ffffffffc02006ec:	00005517          	auipc	a0,0x5
ffffffffc02006f0:	ea450513          	addi	a0,a0,-348 # ffffffffc0205590 <commands+0x5c0>
ffffffffc02006f4:	a9bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f8:	682c                	ld	a1,80(s0)
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	eae50513          	addi	a0,a0,-338 # ffffffffc02055a8 <commands+0x5d8>
ffffffffc0200702:	a8dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200706:	6c2c                	ld	a1,88(s0)
ffffffffc0200708:	00005517          	auipc	a0,0x5
ffffffffc020070c:	eb850513          	addi	a0,a0,-328 # ffffffffc02055c0 <commands+0x5f0>
ffffffffc0200710:	a7fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200714:	702c                	ld	a1,96(s0)
ffffffffc0200716:	00005517          	auipc	a0,0x5
ffffffffc020071a:	ec250513          	addi	a0,a0,-318 # ffffffffc02055d8 <commands+0x608>
ffffffffc020071e:	a71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200722:	742c                	ld	a1,104(s0)
ffffffffc0200724:	00005517          	auipc	a0,0x5
ffffffffc0200728:	ecc50513          	addi	a0,a0,-308 # ffffffffc02055f0 <commands+0x620>
ffffffffc020072c:	a63ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200730:	782c                	ld	a1,112(s0)
ffffffffc0200732:	00005517          	auipc	a0,0x5
ffffffffc0200736:	ed650513          	addi	a0,a0,-298 # ffffffffc0205608 <commands+0x638>
ffffffffc020073a:	a55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073e:	7c2c                	ld	a1,120(s0)
ffffffffc0200740:	00005517          	auipc	a0,0x5
ffffffffc0200744:	ee050513          	addi	a0,a0,-288 # ffffffffc0205620 <commands+0x650>
ffffffffc0200748:	a47ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020074c:	604c                	ld	a1,128(s0)
ffffffffc020074e:	00005517          	auipc	a0,0x5
ffffffffc0200752:	eea50513          	addi	a0,a0,-278 # ffffffffc0205638 <commands+0x668>
ffffffffc0200756:	a39ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075a:	644c                	ld	a1,136(s0)
ffffffffc020075c:	00005517          	auipc	a0,0x5
ffffffffc0200760:	ef450513          	addi	a0,a0,-268 # ffffffffc0205650 <commands+0x680>
ffffffffc0200764:	a2bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200768:	684c                	ld	a1,144(s0)
ffffffffc020076a:	00005517          	auipc	a0,0x5
ffffffffc020076e:	efe50513          	addi	a0,a0,-258 # ffffffffc0205668 <commands+0x698>
ffffffffc0200772:	a1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200776:	6c4c                	ld	a1,152(s0)
ffffffffc0200778:	00005517          	auipc	a0,0x5
ffffffffc020077c:	f0850513          	addi	a0,a0,-248 # ffffffffc0205680 <commands+0x6b0>
ffffffffc0200780:	a0fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200784:	704c                	ld	a1,160(s0)
ffffffffc0200786:	00005517          	auipc	a0,0x5
ffffffffc020078a:	f1250513          	addi	a0,a0,-238 # ffffffffc0205698 <commands+0x6c8>
ffffffffc020078e:	a01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200792:	744c                	ld	a1,168(s0)
ffffffffc0200794:	00005517          	auipc	a0,0x5
ffffffffc0200798:	f1c50513          	addi	a0,a0,-228 # ffffffffc02056b0 <commands+0x6e0>
ffffffffc020079c:	9f3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a0:	784c                	ld	a1,176(s0)
ffffffffc02007a2:	00005517          	auipc	a0,0x5
ffffffffc02007a6:	f2650513          	addi	a0,a0,-218 # ffffffffc02056c8 <commands+0x6f8>
ffffffffc02007aa:	9e5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007ae:	7c4c                	ld	a1,184(s0)
ffffffffc02007b0:	00005517          	auipc	a0,0x5
ffffffffc02007b4:	f3050513          	addi	a0,a0,-208 # ffffffffc02056e0 <commands+0x710>
ffffffffc02007b8:	9d7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007bc:	606c                	ld	a1,192(s0)
ffffffffc02007be:	00005517          	auipc	a0,0x5
ffffffffc02007c2:	f3a50513          	addi	a0,a0,-198 # ffffffffc02056f8 <commands+0x728>
ffffffffc02007c6:	9c9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ca:	646c                	ld	a1,200(s0)
ffffffffc02007cc:	00005517          	auipc	a0,0x5
ffffffffc02007d0:	f4450513          	addi	a0,a0,-188 # ffffffffc0205710 <commands+0x740>
ffffffffc02007d4:	9bbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d8:	686c                	ld	a1,208(s0)
ffffffffc02007da:	00005517          	auipc	a0,0x5
ffffffffc02007de:	f4e50513          	addi	a0,a0,-178 # ffffffffc0205728 <commands+0x758>
ffffffffc02007e2:	9adff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e6:	6c6c                	ld	a1,216(s0)
ffffffffc02007e8:	00005517          	auipc	a0,0x5
ffffffffc02007ec:	f5850513          	addi	a0,a0,-168 # ffffffffc0205740 <commands+0x770>
ffffffffc02007f0:	99fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f4:	706c                	ld	a1,224(s0)
ffffffffc02007f6:	00005517          	auipc	a0,0x5
ffffffffc02007fa:	f6250513          	addi	a0,a0,-158 # ffffffffc0205758 <commands+0x788>
ffffffffc02007fe:	991ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200802:	746c                	ld	a1,232(s0)
ffffffffc0200804:	00005517          	auipc	a0,0x5
ffffffffc0200808:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205770 <commands+0x7a0>
ffffffffc020080c:	983ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200810:	786c                	ld	a1,240(s0)
ffffffffc0200812:	00005517          	auipc	a0,0x5
ffffffffc0200816:	f7650513          	addi	a0,a0,-138 # ffffffffc0205788 <commands+0x7b8>
ffffffffc020081a:	975ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200820:	6402                	ld	s0,0(sp)
ffffffffc0200822:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200824:	00005517          	auipc	a0,0x5
ffffffffc0200828:	f7c50513          	addi	a0,a0,-132 # ffffffffc02057a0 <commands+0x7d0>
}
ffffffffc020082c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	b285                	j	ffffffffc020018e <cprintf>

ffffffffc0200830 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	1141                	addi	sp,sp,-16
ffffffffc0200832:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200834:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	00005517          	auipc	a0,0x5
ffffffffc020083c:	f8050513          	addi	a0,a0,-128 # ffffffffc02057b8 <commands+0x7e8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	94dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200846:	8522                	mv	a0,s0
ffffffffc0200848:	e1dff0ef          	jal	ra,ffffffffc0200664 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084c:	10043583          	ld	a1,256(s0)
ffffffffc0200850:	00005517          	auipc	a0,0x5
ffffffffc0200854:	f8050513          	addi	a0,a0,-128 # ffffffffc02057d0 <commands+0x800>
ffffffffc0200858:	937ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085c:	10843583          	ld	a1,264(s0)
ffffffffc0200860:	00005517          	auipc	a0,0x5
ffffffffc0200864:	f8850513          	addi	a0,a0,-120 # ffffffffc02057e8 <commands+0x818>
ffffffffc0200868:	927ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020086c:	11043583          	ld	a1,272(s0)
ffffffffc0200870:	00005517          	auipc	a0,0x5
ffffffffc0200874:	f9050513          	addi	a0,a0,-112 # ffffffffc0205800 <commands+0x830>
ffffffffc0200878:	917ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200880:	6402                	ld	s0,0(sp)
ffffffffc0200882:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200884:	00005517          	auipc	a0,0x5
ffffffffc0200888:	f9450513          	addi	a0,a0,-108 # ffffffffc0205818 <commands+0x848>
}
ffffffffc020088c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	901ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200892 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200892:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc0200896:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200898:	0786                	slli	a5,a5,0x1
ffffffffc020089a:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc020089c:	06f76f63          	bltu	a4,a5,ffffffffc020091a <interrupt_handler+0x88>
ffffffffc02008a0:	00005717          	auipc	a4,0x5
ffffffffc02008a4:	8ec70713          	addi	a4,a4,-1812 # ffffffffc020518c <commands+0x1bc>
ffffffffc02008a8:	078a                	slli	a5,a5,0x2
ffffffffc02008aa:	97ba                	add	a5,a5,a4
ffffffffc02008ac:	439c                	lw	a5,0(a5)
ffffffffc02008ae:	97ba                	add	a5,a5,a4
ffffffffc02008b0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	b6650513          	addi	a0,a0,-1178 # ffffffffc0205418 <commands+0x448>
ffffffffc02008ba:	8d5ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	b3a50513          	addi	a0,a0,-1222 # ffffffffc02053f8 <commands+0x428>
ffffffffc02008c6:	8c9ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	aee50513          	addi	a0,a0,-1298 # ffffffffc02053b8 <commands+0x3e8>
ffffffffc02008d2:	8bdff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008d6:	00005517          	auipc	a0,0x5
ffffffffc02008da:	b0250513          	addi	a0,a0,-1278 # ffffffffc02053d8 <commands+0x408>
ffffffffc02008de:	8b1ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008e2:	00005517          	auipc	a0,0x5
ffffffffc02008e6:	b6650513          	addi	a0,a0,-1178 # ffffffffc0205448 <commands+0x478>
ffffffffc02008ea:	8a5ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008ee:	1141                	addi	sp,sp,-16
ffffffffc02008f0:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008f2:	bf3ff0ef          	jal	ra,ffffffffc02004e4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008f6:	00015797          	auipc	a5,0x15
ffffffffc02008fa:	bd278793          	addi	a5,a5,-1070 # ffffffffc02154c8 <ticks>
ffffffffc02008fe:	639c                	ld	a5,0(a5)
ffffffffc0200900:	06400713          	li	a4,100
ffffffffc0200904:	0785                	addi	a5,a5,1
ffffffffc0200906:	02e7f733          	remu	a4,a5,a4
ffffffffc020090a:	00015697          	auipc	a3,0x15
ffffffffc020090e:	baf6bf23          	sd	a5,-1090(a3) # ffffffffc02154c8 <ticks>
ffffffffc0200912:	c709                	beqz	a4,ffffffffc020091c <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200914:	60a2                	ld	ra,8(sp)
ffffffffc0200916:	0141                	addi	sp,sp,16
ffffffffc0200918:	8082                	ret
            print_trapframe(tf);
ffffffffc020091a:	bf19                	j	ffffffffc0200830 <print_trapframe>
}
ffffffffc020091c:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020091e:	06400593          	li	a1,100
ffffffffc0200922:	00005517          	auipc	a0,0x5
ffffffffc0200926:	b1650513          	addi	a0,a0,-1258 # ffffffffc0205438 <commands+0x468>
}
ffffffffc020092a:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020092c:	863ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200930 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200930:	11853783          	ld	a5,280(a0)
ffffffffc0200934:	473d                	li	a4,15
ffffffffc0200936:	16f76463          	bltu	a4,a5,ffffffffc0200a9e <exception_handler+0x16e>
ffffffffc020093a:	00005717          	auipc	a4,0x5
ffffffffc020093e:	88270713          	addi	a4,a4,-1918 # ffffffffc02051bc <commands+0x1ec>
ffffffffc0200942:	078a                	slli	a5,a5,0x2
ffffffffc0200944:	97ba                	add	a5,a5,a4
ffffffffc0200946:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200948:	1101                	addi	sp,sp,-32
ffffffffc020094a:	e822                	sd	s0,16(sp)
ffffffffc020094c:	ec06                	sd	ra,24(sp)
ffffffffc020094e:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200950:	97ba                	add	a5,a5,a4
ffffffffc0200952:	842a                	mv	s0,a0
ffffffffc0200954:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200956:	00005517          	auipc	a0,0x5
ffffffffc020095a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02053a0 <commands+0x3d0>
ffffffffc020095e:	831ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200962:	8522                	mv	a0,s0
ffffffffc0200964:	c75ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200968:	84aa                	mv	s1,a0
ffffffffc020096a:	12051b63          	bnez	a0,ffffffffc0200aa0 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020096e:	60e2                	ld	ra,24(sp)
ffffffffc0200970:	6442                	ld	s0,16(sp)
ffffffffc0200972:	64a2                	ld	s1,8(sp)
ffffffffc0200974:	6105                	addi	sp,sp,32
ffffffffc0200976:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200978:	00005517          	auipc	a0,0x5
ffffffffc020097c:	88850513          	addi	a0,a0,-1912 # ffffffffc0205200 <commands+0x230>
}
ffffffffc0200980:	6442                	ld	s0,16(sp)
ffffffffc0200982:	60e2                	ld	ra,24(sp)
ffffffffc0200984:	64a2                	ld	s1,8(sp)
ffffffffc0200986:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200988:	807ff06f          	j	ffffffffc020018e <cprintf>
ffffffffc020098c:	00005517          	auipc	a0,0x5
ffffffffc0200990:	89450513          	addi	a0,a0,-1900 # ffffffffc0205220 <commands+0x250>
ffffffffc0200994:	b7f5                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200996:	00005517          	auipc	a0,0x5
ffffffffc020099a:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0205240 <commands+0x270>
ffffffffc020099e:	b7cd                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02009a0:	00005517          	auipc	a0,0x5
ffffffffc02009a4:	8b850513          	addi	a0,a0,-1864 # ffffffffc0205258 <commands+0x288>
ffffffffc02009a8:	bfe1                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02009aa:	00005517          	auipc	a0,0x5
ffffffffc02009ae:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205268 <commands+0x298>
ffffffffc02009b2:	b7f9                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009b4:	00005517          	auipc	a0,0x5
ffffffffc02009b8:	8d450513          	addi	a0,a0,-1836 # ffffffffc0205288 <commands+0x2b8>
ffffffffc02009bc:	fd2ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009c0:	8522                	mv	a0,s0
ffffffffc02009c2:	c17ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc02009c6:	84aa                	mv	s1,a0
ffffffffc02009c8:	d15d                	beqz	a0,ffffffffc020096e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009ca:	8522                	mv	a0,s0
ffffffffc02009cc:	e65ff0ef          	jal	ra,ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d0:	86a6                	mv	a3,s1
ffffffffc02009d2:	00005617          	auipc	a2,0x5
ffffffffc02009d6:	8ce60613          	addi	a2,a2,-1842 # ffffffffc02052a0 <commands+0x2d0>
ffffffffc02009da:	0b300593          	li	a1,179
ffffffffc02009de:	00005517          	auipc	a0,0x5
ffffffffc02009e2:	ac250513          	addi	a0,a0,-1342 # ffffffffc02054a0 <commands+0x4d0>
ffffffffc02009e6:	a67ff0ef          	jal	ra,ffffffffc020044c <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009ea:	00005517          	auipc	a0,0x5
ffffffffc02009ee:	8d650513          	addi	a0,a0,-1834 # ffffffffc02052c0 <commands+0x2f0>
ffffffffc02009f2:	b779                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009f4:	00005517          	auipc	a0,0x5
ffffffffc02009f8:	8e450513          	addi	a0,a0,-1820 # ffffffffc02052d8 <commands+0x308>
ffffffffc02009fc:	f92ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a00:	8522                	mv	a0,s0
ffffffffc0200a02:	bd7ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200a06:	84aa                	mv	s1,a0
ffffffffc0200a08:	d13d                	beqz	a0,ffffffffc020096e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a0a:	8522                	mv	a0,s0
ffffffffc0200a0c:	e25ff0ef          	jal	ra,ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a10:	86a6                	mv	a3,s1
ffffffffc0200a12:	00005617          	auipc	a2,0x5
ffffffffc0200a16:	88e60613          	addi	a2,a2,-1906 # ffffffffc02052a0 <commands+0x2d0>
ffffffffc0200a1a:	0bd00593          	li	a1,189
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	a8250513          	addi	a0,a0,-1406 # ffffffffc02054a0 <commands+0x4d0>
ffffffffc0200a26:	a27ff0ef          	jal	ra,ffffffffc020044c <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	8c650513          	addi	a0,a0,-1850 # ffffffffc02052f0 <commands+0x320>
ffffffffc0200a32:	b7b9                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0205310 <commands+0x340>
ffffffffc0200a3c:	b791                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a3e:	00005517          	auipc	a0,0x5
ffffffffc0200a42:	8f250513          	addi	a0,a0,-1806 # ffffffffc0205330 <commands+0x360>
ffffffffc0200a46:	bf2d                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	90850513          	addi	a0,a0,-1784 # ffffffffc0205350 <commands+0x380>
ffffffffc0200a50:	bf05                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a52:	00005517          	auipc	a0,0x5
ffffffffc0200a56:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205370 <commands+0x3a0>
ffffffffc0200a5a:	b71d                	j	ffffffffc0200980 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a5c:	00005517          	auipc	a0,0x5
ffffffffc0200a60:	92c50513          	addi	a0,a0,-1748 # ffffffffc0205388 <commands+0x3b8>
ffffffffc0200a64:	f2aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a68:	8522                	mv	a0,s0
ffffffffc0200a6a:	b6fff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200a6e:	84aa                	mv	s1,a0
ffffffffc0200a70:	ee050fe3          	beqz	a0,ffffffffc020096e <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a74:	8522                	mv	a0,s0
ffffffffc0200a76:	dbbff0ef          	jal	ra,ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a7a:	86a6                	mv	a3,s1
ffffffffc0200a7c:	00005617          	auipc	a2,0x5
ffffffffc0200a80:	82460613          	addi	a2,a2,-2012 # ffffffffc02052a0 <commands+0x2d0>
ffffffffc0200a84:	0d300593          	li	a1,211
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	a1850513          	addi	a0,a0,-1512 # ffffffffc02054a0 <commands+0x4d0>
ffffffffc0200a90:	9bdff0ef          	jal	ra,ffffffffc020044c <__panic>
}
ffffffffc0200a94:	6442                	ld	s0,16(sp)
ffffffffc0200a96:	60e2                	ld	ra,24(sp)
ffffffffc0200a98:	64a2                	ld	s1,8(sp)
ffffffffc0200a9a:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a9c:	bb51                	j	ffffffffc0200830 <print_trapframe>
ffffffffc0200a9e:	bb49                	j	ffffffffc0200830 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200aa0:	8522                	mv	a0,s0
ffffffffc0200aa2:	d8fff0ef          	jal	ra,ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200aa6:	86a6                	mv	a3,s1
ffffffffc0200aa8:	00004617          	auipc	a2,0x4
ffffffffc0200aac:	7f860613          	addi	a2,a2,2040 # ffffffffc02052a0 <commands+0x2d0>
ffffffffc0200ab0:	0da00593          	li	a1,218
ffffffffc0200ab4:	00005517          	auipc	a0,0x5
ffffffffc0200ab8:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02054a0 <commands+0x4d0>
ffffffffc0200abc:	991ff0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0200ac0 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ac0:	11853783          	ld	a5,280(a0)
ffffffffc0200ac4:	0007c363          	bltz	a5,ffffffffc0200aca <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ac8:	b5a5                	j	ffffffffc0200930 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200aca:	b3e1                	j	ffffffffc0200892 <interrupt_handler>

ffffffffc0200acc <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200acc:	14011073          	csrw	sscratch,sp
ffffffffc0200ad0:	712d                	addi	sp,sp,-288
ffffffffc0200ad2:	e406                	sd	ra,8(sp)
ffffffffc0200ad4:	ec0e                	sd	gp,24(sp)
ffffffffc0200ad6:	f012                	sd	tp,32(sp)
ffffffffc0200ad8:	f416                	sd	t0,40(sp)
ffffffffc0200ada:	f81a                	sd	t1,48(sp)
ffffffffc0200adc:	fc1e                	sd	t2,56(sp)
ffffffffc0200ade:	e0a2                	sd	s0,64(sp)
ffffffffc0200ae0:	e4a6                	sd	s1,72(sp)
ffffffffc0200ae2:	e8aa                	sd	a0,80(sp)
ffffffffc0200ae4:	ecae                	sd	a1,88(sp)
ffffffffc0200ae6:	f0b2                	sd	a2,96(sp)
ffffffffc0200ae8:	f4b6                	sd	a3,104(sp)
ffffffffc0200aea:	f8ba                	sd	a4,112(sp)
ffffffffc0200aec:	fcbe                	sd	a5,120(sp)
ffffffffc0200aee:	e142                	sd	a6,128(sp)
ffffffffc0200af0:	e546                	sd	a7,136(sp)
ffffffffc0200af2:	e94a                	sd	s2,144(sp)
ffffffffc0200af4:	ed4e                	sd	s3,152(sp)
ffffffffc0200af6:	f152                	sd	s4,160(sp)
ffffffffc0200af8:	f556                	sd	s5,168(sp)
ffffffffc0200afa:	f95a                	sd	s6,176(sp)
ffffffffc0200afc:	fd5e                	sd	s7,184(sp)
ffffffffc0200afe:	e1e2                	sd	s8,192(sp)
ffffffffc0200b00:	e5e6                	sd	s9,200(sp)
ffffffffc0200b02:	e9ea                	sd	s10,208(sp)
ffffffffc0200b04:	edee                	sd	s11,216(sp)
ffffffffc0200b06:	f1f2                	sd	t3,224(sp)
ffffffffc0200b08:	f5f6                	sd	t4,232(sp)
ffffffffc0200b0a:	f9fa                	sd	t5,240(sp)
ffffffffc0200b0c:	fdfe                	sd	t6,248(sp)
ffffffffc0200b0e:	14002473          	csrr	s0,sscratch
ffffffffc0200b12:	100024f3          	csrr	s1,sstatus
ffffffffc0200b16:	14102973          	csrr	s2,sepc
ffffffffc0200b1a:	143029f3          	csrr	s3,stval
ffffffffc0200b1e:	14202a73          	csrr	s4,scause
ffffffffc0200b22:	e822                	sd	s0,16(sp)
ffffffffc0200b24:	e226                	sd	s1,256(sp)
ffffffffc0200b26:	e64a                	sd	s2,264(sp)
ffffffffc0200b28:	ea4e                	sd	s3,272(sp)
ffffffffc0200b2a:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b2c:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b2e:	f93ff0ef          	jal	ra,ffffffffc0200ac0 <trap>

ffffffffc0200b32 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b32:	6492                	ld	s1,256(sp)
ffffffffc0200b34:	6932                	ld	s2,264(sp)
ffffffffc0200b36:	10049073          	csrw	sstatus,s1
ffffffffc0200b3a:	14191073          	csrw	sepc,s2
ffffffffc0200b3e:	60a2                	ld	ra,8(sp)
ffffffffc0200b40:	61e2                	ld	gp,24(sp)
ffffffffc0200b42:	7202                	ld	tp,32(sp)
ffffffffc0200b44:	72a2                	ld	t0,40(sp)
ffffffffc0200b46:	7342                	ld	t1,48(sp)
ffffffffc0200b48:	73e2                	ld	t2,56(sp)
ffffffffc0200b4a:	6406                	ld	s0,64(sp)
ffffffffc0200b4c:	64a6                	ld	s1,72(sp)
ffffffffc0200b4e:	6546                	ld	a0,80(sp)
ffffffffc0200b50:	65e6                	ld	a1,88(sp)
ffffffffc0200b52:	7606                	ld	a2,96(sp)
ffffffffc0200b54:	76a6                	ld	a3,104(sp)
ffffffffc0200b56:	7746                	ld	a4,112(sp)
ffffffffc0200b58:	77e6                	ld	a5,120(sp)
ffffffffc0200b5a:	680a                	ld	a6,128(sp)
ffffffffc0200b5c:	68aa                	ld	a7,136(sp)
ffffffffc0200b5e:	694a                	ld	s2,144(sp)
ffffffffc0200b60:	69ea                	ld	s3,152(sp)
ffffffffc0200b62:	7a0a                	ld	s4,160(sp)
ffffffffc0200b64:	7aaa                	ld	s5,168(sp)
ffffffffc0200b66:	7b4a                	ld	s6,176(sp)
ffffffffc0200b68:	7bea                	ld	s7,184(sp)
ffffffffc0200b6a:	6c0e                	ld	s8,192(sp)
ffffffffc0200b6c:	6cae                	ld	s9,200(sp)
ffffffffc0200b6e:	6d4e                	ld	s10,208(sp)
ffffffffc0200b70:	6dee                	ld	s11,216(sp)
ffffffffc0200b72:	7e0e                	ld	t3,224(sp)
ffffffffc0200b74:	7eae                	ld	t4,232(sp)
ffffffffc0200b76:	7f4e                	ld	t5,240(sp)
ffffffffc0200b78:	7fee                	ld	t6,248(sp)
ffffffffc0200b7a:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b7c:	10200073          	sret

ffffffffc0200b80 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b80:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b82:	bf45                	j	ffffffffc0200b32 <__trapret>
	...

ffffffffc0200b86 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b86:	00015797          	auipc	a5,0x15
ffffffffc0200b8a:	94a78793          	addi	a5,a5,-1718 # ffffffffc02154d0 <free_area>
ffffffffc0200b8e:	e79c                	sd	a5,8(a5)
ffffffffc0200b90:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b92:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b96:	8082                	ret

ffffffffc0200b98 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b98:	00015517          	auipc	a0,0x15
ffffffffc0200b9c:	94856503          	lwu	a0,-1720(a0) # ffffffffc02154e0 <free_area+0x10>
ffffffffc0200ba0:	8082                	ret

ffffffffc0200ba2 <default_check>:


// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200ba2:	715d                	addi	sp,sp,-80
ffffffffc0200ba4:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ba6:	00015917          	auipc	s2,0x15
ffffffffc0200baa:	92a90913          	addi	s2,s2,-1750 # ffffffffc02154d0 <free_area>
ffffffffc0200bae:	00893783          	ld	a5,8(s2)
ffffffffc0200bb2:	e486                	sd	ra,72(sp)
ffffffffc0200bb4:	e0a2                	sd	s0,64(sp)
ffffffffc0200bb6:	fc26                	sd	s1,56(sp)
ffffffffc0200bb8:	f44e                	sd	s3,40(sp)
ffffffffc0200bba:	f052                	sd	s4,32(sp)
ffffffffc0200bbc:	ec56                	sd	s5,24(sp)
ffffffffc0200bbe:	e85a                	sd	s6,16(sp)
ffffffffc0200bc0:	e45e                	sd	s7,8(sp)
ffffffffc0200bc2:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bc4:	31278463          	beq	a5,s2,ffffffffc0200ecc <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bc8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200bcc:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bce:	8b05                	andi	a4,a4,1
ffffffffc0200bd0:	30070263          	beqz	a4,ffffffffc0200ed4 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200bd4:	4401                	li	s0,0
ffffffffc0200bd6:	4481                	li	s1,0
ffffffffc0200bd8:	a031                	j	ffffffffc0200be4 <default_check+0x42>
ffffffffc0200bda:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200bde:	8b09                	andi	a4,a4,2
ffffffffc0200be0:	2e070a63          	beqz	a4,ffffffffc0200ed4 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200be4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200be8:	679c                	ld	a5,8(a5)
ffffffffc0200bea:	2485                	addiw	s1,s1,1
ffffffffc0200bec:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bee:	ff2796e3          	bne	a5,s2,ffffffffc0200bda <default_check+0x38>
ffffffffc0200bf2:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200bf4:	042010ef          	jal	ra,ffffffffc0201c36 <nr_free_pages>
ffffffffc0200bf8:	73351e63          	bne	a0,s3,ffffffffc0201334 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bfc:	4505                	li	a0,1
ffffffffc0200bfe:	76b000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200c02:	8a2a                	mv	s4,a0
ffffffffc0200c04:	46050863          	beqz	a0,ffffffffc0201074 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c08:	4505                	li	a0,1
ffffffffc0200c0a:	75f000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200c0e:	89aa                	mv	s3,a0
ffffffffc0200c10:	74050263          	beqz	a0,ffffffffc0201354 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c14:	4505                	li	a0,1
ffffffffc0200c16:	753000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200c1a:	8aaa                	mv	s5,a0
ffffffffc0200c1c:	4c050c63          	beqz	a0,ffffffffc02010f4 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c20:	2d3a0a63          	beq	s4,s3,ffffffffc0200ef4 <default_check+0x352>
ffffffffc0200c24:	2caa0863          	beq	s4,a0,ffffffffc0200ef4 <default_check+0x352>
ffffffffc0200c28:	2ca98663          	beq	s3,a0,ffffffffc0200ef4 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c2c:	000a2783          	lw	a5,0(s4)
ffffffffc0200c30:	2e079263          	bnez	a5,ffffffffc0200f14 <default_check+0x372>
ffffffffc0200c34:	0009a783          	lw	a5,0(s3)
ffffffffc0200c38:	2c079e63          	bnez	a5,ffffffffc0200f14 <default_check+0x372>
ffffffffc0200c3c:	411c                	lw	a5,0(a0)
ffffffffc0200c3e:	2c079b63          	bnez	a5,ffffffffc0200f14 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c42:	00015797          	auipc	a5,0x15
ffffffffc0200c46:	8be78793          	addi	a5,a5,-1858 # ffffffffc0215500 <pages>
ffffffffc0200c4a:	639c                	ld	a5,0(a5)
ffffffffc0200c4c:	00006717          	auipc	a4,0x6
ffffffffc0200c50:	39470713          	addi	a4,a4,916 # ffffffffc0206fe0 <nbase>
ffffffffc0200c54:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c56:	00015717          	auipc	a4,0x15
ffffffffc0200c5a:	83a70713          	addi	a4,a4,-1990 # ffffffffc0215490 <npage>
ffffffffc0200c5e:	6314                	ld	a3,0(a4)
ffffffffc0200c60:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c64:	8719                	srai	a4,a4,0x6
ffffffffc0200c66:	9732                	add	a4,a4,a2
ffffffffc0200c68:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c6a:	0732                	slli	a4,a4,0xc
ffffffffc0200c6c:	2cd77463          	bgeu	a4,a3,ffffffffc0200f34 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200c70:	40f98733          	sub	a4,s3,a5
ffffffffc0200c74:	8719                	srai	a4,a4,0x6
ffffffffc0200c76:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c78:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c7a:	4ed77d63          	bgeu	a4,a3,ffffffffc0201174 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200c7e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c82:	8799                	srai	a5,a5,0x6
ffffffffc0200c84:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c86:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c88:	34d7f663          	bgeu	a5,a3,ffffffffc0200fd4 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200c8c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c8e:	00093c03          	ld	s8,0(s2)
ffffffffc0200c92:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c96:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c9a:	00015797          	auipc	a5,0x15
ffffffffc0200c9e:	8327bf23          	sd	s2,-1986(a5) # ffffffffc02154d8 <free_area+0x8>
ffffffffc0200ca2:	00015797          	auipc	a5,0x15
ffffffffc0200ca6:	8327b723          	sd	s2,-2002(a5) # ffffffffc02154d0 <free_area>
    nr_free = 0;
ffffffffc0200caa:	00015797          	auipc	a5,0x15
ffffffffc0200cae:	8207ab23          	sw	zero,-1994(a5) # ffffffffc02154e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200cb2:	6b7000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200cb6:	2e051f63          	bnez	a0,ffffffffc0200fb4 <default_check+0x412>
    free_page(p0);
ffffffffc0200cba:	4585                	li	a1,1
ffffffffc0200cbc:	8552                	mv	a0,s4
ffffffffc0200cbe:	733000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    free_page(p1);
ffffffffc0200cc2:	4585                	li	a1,1
ffffffffc0200cc4:	854e                	mv	a0,s3
ffffffffc0200cc6:	72b000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    free_page(p2);
ffffffffc0200cca:	4585                	li	a1,1
ffffffffc0200ccc:	8556                	mv	a0,s5
ffffffffc0200cce:	723000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    assert(nr_free == 3);
ffffffffc0200cd2:	01092703          	lw	a4,16(s2)
ffffffffc0200cd6:	478d                	li	a5,3
ffffffffc0200cd8:	2af71e63          	bne	a4,a5,ffffffffc0200f94 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cdc:	4505                	li	a0,1
ffffffffc0200cde:	68b000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200ce2:	89aa                	mv	s3,a0
ffffffffc0200ce4:	28050863          	beqz	a0,ffffffffc0200f74 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ce8:	4505                	li	a0,1
ffffffffc0200cea:	67f000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200cee:	8aaa                	mv	s5,a0
ffffffffc0200cf0:	3e050263          	beqz	a0,ffffffffc02010d4 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cf4:	4505                	li	a0,1
ffffffffc0200cf6:	673000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200cfa:	8a2a                	mv	s4,a0
ffffffffc0200cfc:	3a050c63          	beqz	a0,ffffffffc02010b4 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200d00:	4505                	li	a0,1
ffffffffc0200d02:	667000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200d06:	38051763          	bnez	a0,ffffffffc0201094 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200d0a:	4585                	li	a1,1
ffffffffc0200d0c:	854e                	mv	a0,s3
ffffffffc0200d0e:	6e3000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d12:	00893783          	ld	a5,8(s2)
ffffffffc0200d16:	23278f63          	beq	a5,s2,ffffffffc0200f54 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200d1a:	4505                	li	a0,1
ffffffffc0200d1c:	64d000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200d20:	32a99a63          	bne	s3,a0,ffffffffc0201054 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200d24:	4505                	li	a0,1
ffffffffc0200d26:	643000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200d2a:	30051563          	bnez	a0,ffffffffc0201034 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200d2e:	01092783          	lw	a5,16(s2)
ffffffffc0200d32:	2e079163          	bnez	a5,ffffffffc0201014 <default_check+0x472>
    free_page(p);
ffffffffc0200d36:	854e                	mv	a0,s3
ffffffffc0200d38:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d3a:	00014797          	auipc	a5,0x14
ffffffffc0200d3e:	7987bb23          	sd	s8,1942(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200d42:	00014797          	auipc	a5,0x14
ffffffffc0200d46:	7977bb23          	sd	s7,1942(a5) # ffffffffc02154d8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d4a:	00014797          	auipc	a5,0x14
ffffffffc0200d4e:	7967ab23          	sw	s6,1942(a5) # ffffffffc02154e0 <free_area+0x10>
    free_page(p);
ffffffffc0200d52:	69f000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    free_page(p1);
ffffffffc0200d56:	4585                	li	a1,1
ffffffffc0200d58:	8556                	mv	a0,s5
ffffffffc0200d5a:	697000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    free_page(p2);
ffffffffc0200d5e:	4585                	li	a1,1
ffffffffc0200d60:	8552                	mv	a0,s4
ffffffffc0200d62:	68f000ef          	jal	ra,ffffffffc0201bf0 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d66:	4515                	li	a0,5
ffffffffc0200d68:	601000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200d6c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d6e:	28050363          	beqz	a0,ffffffffc0200ff4 <default_check+0x452>
ffffffffc0200d72:	651c                	ld	a5,8(a0)
ffffffffc0200d74:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d76:	8b85                	andi	a5,a5,1
ffffffffc0200d78:	54079e63          	bnez	a5,ffffffffc02012d4 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d7c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d7e:	00093b03          	ld	s6,0(s2)
ffffffffc0200d82:	00893a83          	ld	s5,8(s2)
ffffffffc0200d86:	00014797          	auipc	a5,0x14
ffffffffc0200d8a:	7527b523          	sd	s2,1866(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200d8e:	00014797          	auipc	a5,0x14
ffffffffc0200d92:	7527b523          	sd	s2,1866(a5) # ffffffffc02154d8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d96:	5d3000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200d9a:	50051d63          	bnez	a0,ffffffffc02012b4 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d9e:	08098a13          	addi	s4,s3,128
ffffffffc0200da2:	8552                	mv	a0,s4
ffffffffc0200da4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200da6:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200daa:	00014797          	auipc	a5,0x14
ffffffffc0200dae:	7207ab23          	sw	zero,1846(a5) # ffffffffc02154e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200db2:	63f000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200db6:	4511                	li	a0,4
ffffffffc0200db8:	5b1000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200dbc:	4c051c63          	bnez	a0,ffffffffc0201294 <default_check+0x6f2>
ffffffffc0200dc0:	0889b783          	ld	a5,136(s3)
ffffffffc0200dc4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200dc6:	8b85                	andi	a5,a5,1
ffffffffc0200dc8:	4a078663          	beqz	a5,ffffffffc0201274 <default_check+0x6d2>
ffffffffc0200dcc:	0909a703          	lw	a4,144(s3)
ffffffffc0200dd0:	478d                	li	a5,3
ffffffffc0200dd2:	4af71163          	bne	a4,a5,ffffffffc0201274 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200dd6:	450d                	li	a0,3
ffffffffc0200dd8:	591000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200ddc:	8c2a                	mv	s8,a0
ffffffffc0200dde:	46050b63          	beqz	a0,ffffffffc0201254 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0200de2:	4505                	li	a0,1
ffffffffc0200de4:	585000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200de8:	44051663          	bnez	a0,ffffffffc0201234 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0200dec:	438a1463          	bne	s4,s8,ffffffffc0201214 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200df0:	4585                	li	a1,1
ffffffffc0200df2:	854e                	mv	a0,s3
ffffffffc0200df4:	5fd000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    free_pages(p1, 3);
ffffffffc0200df8:	458d                	li	a1,3
ffffffffc0200dfa:	8552                	mv	a0,s4
ffffffffc0200dfc:	5f5000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
ffffffffc0200e00:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200e04:	04098c13          	addi	s8,s3,64
ffffffffc0200e08:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200e0a:	8b85                	andi	a5,a5,1
ffffffffc0200e0c:	3e078463          	beqz	a5,ffffffffc02011f4 <default_check+0x652>
ffffffffc0200e10:	0109a703          	lw	a4,16(s3)
ffffffffc0200e14:	4785                	li	a5,1
ffffffffc0200e16:	3cf71f63          	bne	a4,a5,ffffffffc02011f4 <default_check+0x652>
ffffffffc0200e1a:	008a3783          	ld	a5,8(s4)
ffffffffc0200e1e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e20:	8b85                	andi	a5,a5,1
ffffffffc0200e22:	3a078963          	beqz	a5,ffffffffc02011d4 <default_check+0x632>
ffffffffc0200e26:	010a2703          	lw	a4,16(s4)
ffffffffc0200e2a:	478d                	li	a5,3
ffffffffc0200e2c:	3af71463          	bne	a4,a5,ffffffffc02011d4 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e30:	4505                	li	a0,1
ffffffffc0200e32:	537000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200e36:	36a99f63          	bne	s3,a0,ffffffffc02011b4 <default_check+0x612>
    free_page(p0);
ffffffffc0200e3a:	4585                	li	a1,1
ffffffffc0200e3c:	5b5000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e40:	4509                	li	a0,2
ffffffffc0200e42:	527000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200e46:	34aa1763          	bne	s4,a0,ffffffffc0201194 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0200e4a:	4589                	li	a1,2
ffffffffc0200e4c:	5a5000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    free_page(p2);
ffffffffc0200e50:	4585                	li	a1,1
ffffffffc0200e52:	8562                	mv	a0,s8
ffffffffc0200e54:	59d000ef          	jal	ra,ffffffffc0201bf0 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e58:	4515                	li	a0,5
ffffffffc0200e5a:	50f000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200e5e:	89aa                	mv	s3,a0
ffffffffc0200e60:	48050a63          	beqz	a0,ffffffffc02012f4 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0200e64:	4505                	li	a0,1
ffffffffc0200e66:	503000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0200e6a:	2e051563          	bnez	a0,ffffffffc0201154 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0200e6e:	01092783          	lw	a5,16(s2)
ffffffffc0200e72:	2c079163          	bnez	a5,ffffffffc0201134 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e76:	4595                	li	a1,5
ffffffffc0200e78:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e7a:	00014797          	auipc	a5,0x14
ffffffffc0200e7e:	6777a323          	sw	s7,1638(a5) # ffffffffc02154e0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e82:	00014797          	auipc	a5,0x14
ffffffffc0200e86:	6567b723          	sd	s6,1614(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200e8a:	00014797          	auipc	a5,0x14
ffffffffc0200e8e:	6557b723          	sd	s5,1614(a5) # ffffffffc02154d8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e92:	55f000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    return listelm->next;
ffffffffc0200e96:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e9a:	01278963          	beq	a5,s2,ffffffffc0200eac <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e9e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ea2:	679c                	ld	a5,8(a5)
ffffffffc0200ea4:	34fd                	addiw	s1,s1,-1
ffffffffc0200ea6:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ea8:	ff279be3          	bne	a5,s2,ffffffffc0200e9e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0200eac:	26049463          	bnez	s1,ffffffffc0201114 <default_check+0x572>
    assert(total == 0);
ffffffffc0200eb0:	46041263          	bnez	s0,ffffffffc0201314 <default_check+0x772>
}
ffffffffc0200eb4:	60a6                	ld	ra,72(sp)
ffffffffc0200eb6:	6406                	ld	s0,64(sp)
ffffffffc0200eb8:	74e2                	ld	s1,56(sp)
ffffffffc0200eba:	7942                	ld	s2,48(sp)
ffffffffc0200ebc:	79a2                	ld	s3,40(sp)
ffffffffc0200ebe:	7a02                	ld	s4,32(sp)
ffffffffc0200ec0:	6ae2                	ld	s5,24(sp)
ffffffffc0200ec2:	6b42                	ld	s6,16(sp)
ffffffffc0200ec4:	6ba2                	ld	s7,8(sp)
ffffffffc0200ec6:	6c02                	ld	s8,0(sp)
ffffffffc0200ec8:	6161                	addi	sp,sp,80
ffffffffc0200eca:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ecc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ece:	4401                	li	s0,0
ffffffffc0200ed0:	4481                	li	s1,0
ffffffffc0200ed2:	b30d                	j	ffffffffc0200bf4 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200ed4:	00005697          	auipc	a3,0x5
ffffffffc0200ed8:	95c68693          	addi	a3,a3,-1700 # ffffffffc0205830 <commands+0x860>
ffffffffc0200edc:	00005617          	auipc	a2,0x5
ffffffffc0200ee0:	96460613          	addi	a2,a2,-1692 # ffffffffc0205840 <commands+0x870>
ffffffffc0200ee4:	0f400593          	li	a1,244
ffffffffc0200ee8:	00005517          	auipc	a0,0x5
ffffffffc0200eec:	97050513          	addi	a0,a0,-1680 # ffffffffc0205858 <commands+0x888>
ffffffffc0200ef0:	d5cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ef4:	00005697          	auipc	a3,0x5
ffffffffc0200ef8:	9fc68693          	addi	a3,a3,-1540 # ffffffffc02058f0 <commands+0x920>
ffffffffc0200efc:	00005617          	auipc	a2,0x5
ffffffffc0200f00:	94460613          	addi	a2,a2,-1724 # ffffffffc0205840 <commands+0x870>
ffffffffc0200f04:	08700593          	li	a1,135
ffffffffc0200f08:	00005517          	auipc	a0,0x5
ffffffffc0200f0c:	95050513          	addi	a0,a0,-1712 # ffffffffc0205858 <commands+0x888>
ffffffffc0200f10:	d3cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f14:	00005697          	auipc	a3,0x5
ffffffffc0200f18:	a0468693          	addi	a3,a3,-1532 # ffffffffc0205918 <commands+0x948>
ffffffffc0200f1c:	00005617          	auipc	a2,0x5
ffffffffc0200f20:	92460613          	addi	a2,a2,-1756 # ffffffffc0205840 <commands+0x870>
ffffffffc0200f24:	08800593          	li	a1,136
ffffffffc0200f28:	00005517          	auipc	a0,0x5
ffffffffc0200f2c:	93050513          	addi	a0,a0,-1744 # ffffffffc0205858 <commands+0x888>
ffffffffc0200f30:	d1cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f34:	00005697          	auipc	a3,0x5
ffffffffc0200f38:	a2468693          	addi	a3,a3,-1500 # ffffffffc0205958 <commands+0x988>
ffffffffc0200f3c:	00005617          	auipc	a2,0x5
ffffffffc0200f40:	90460613          	addi	a2,a2,-1788 # ffffffffc0205840 <commands+0x870>
ffffffffc0200f44:	08a00593          	li	a1,138
ffffffffc0200f48:	00005517          	auipc	a0,0x5
ffffffffc0200f4c:	91050513          	addi	a0,a0,-1776 # ffffffffc0205858 <commands+0x888>
ffffffffc0200f50:	cfcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f54:	00005697          	auipc	a3,0x5
ffffffffc0200f58:	a8c68693          	addi	a3,a3,-1396 # ffffffffc02059e0 <commands+0xa10>
ffffffffc0200f5c:	00005617          	auipc	a2,0x5
ffffffffc0200f60:	8e460613          	addi	a2,a2,-1820 # ffffffffc0205840 <commands+0x870>
ffffffffc0200f64:	0a300593          	li	a1,163
ffffffffc0200f68:	00005517          	auipc	a0,0x5
ffffffffc0200f6c:	8f050513          	addi	a0,a0,-1808 # ffffffffc0205858 <commands+0x888>
ffffffffc0200f70:	cdcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f74:	00005697          	auipc	a3,0x5
ffffffffc0200f78:	91c68693          	addi	a3,a3,-1764 # ffffffffc0205890 <commands+0x8c0>
ffffffffc0200f7c:	00005617          	auipc	a2,0x5
ffffffffc0200f80:	8c460613          	addi	a2,a2,-1852 # ffffffffc0205840 <commands+0x870>
ffffffffc0200f84:	09c00593          	li	a1,156
ffffffffc0200f88:	00005517          	auipc	a0,0x5
ffffffffc0200f8c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205858 <commands+0x888>
ffffffffc0200f90:	cbcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free == 3);
ffffffffc0200f94:	00005697          	auipc	a3,0x5
ffffffffc0200f98:	a3c68693          	addi	a3,a3,-1476 # ffffffffc02059d0 <commands+0xa00>
ffffffffc0200f9c:	00005617          	auipc	a2,0x5
ffffffffc0200fa0:	8a460613          	addi	a2,a2,-1884 # ffffffffc0205840 <commands+0x870>
ffffffffc0200fa4:	09a00593          	li	a1,154
ffffffffc0200fa8:	00005517          	auipc	a0,0x5
ffffffffc0200fac:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205858 <commands+0x888>
ffffffffc0200fb0:	c9cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fb4:	00005697          	auipc	a3,0x5
ffffffffc0200fb8:	a0468693          	addi	a3,a3,-1532 # ffffffffc02059b8 <commands+0x9e8>
ffffffffc0200fbc:	00005617          	auipc	a2,0x5
ffffffffc0200fc0:	88460613          	addi	a2,a2,-1916 # ffffffffc0205840 <commands+0x870>
ffffffffc0200fc4:	09500593          	li	a1,149
ffffffffc0200fc8:	00005517          	auipc	a0,0x5
ffffffffc0200fcc:	89050513          	addi	a0,a0,-1904 # ffffffffc0205858 <commands+0x888>
ffffffffc0200fd0:	c7cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fd4:	00005697          	auipc	a3,0x5
ffffffffc0200fd8:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205998 <commands+0x9c8>
ffffffffc0200fdc:	00005617          	auipc	a2,0x5
ffffffffc0200fe0:	86460613          	addi	a2,a2,-1948 # ffffffffc0205840 <commands+0x870>
ffffffffc0200fe4:	08c00593          	li	a1,140
ffffffffc0200fe8:	00005517          	auipc	a0,0x5
ffffffffc0200fec:	87050513          	addi	a0,a0,-1936 # ffffffffc0205858 <commands+0x888>
ffffffffc0200ff0:	c5cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(p0 != NULL);
ffffffffc0200ff4:	00005697          	auipc	a3,0x5
ffffffffc0200ff8:	a3468693          	addi	a3,a3,-1484 # ffffffffc0205a28 <commands+0xa58>
ffffffffc0200ffc:	00005617          	auipc	a2,0x5
ffffffffc0201000:	84460613          	addi	a2,a2,-1980 # ffffffffc0205840 <commands+0x870>
ffffffffc0201004:	0fc00593          	li	a1,252
ffffffffc0201008:	00005517          	auipc	a0,0x5
ffffffffc020100c:	85050513          	addi	a0,a0,-1968 # ffffffffc0205858 <commands+0x888>
ffffffffc0201010:	c3cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free == 0);
ffffffffc0201014:	00005697          	auipc	a3,0x5
ffffffffc0201018:	a0468693          	addi	a3,a3,-1532 # ffffffffc0205a18 <commands+0xa48>
ffffffffc020101c:	00005617          	auipc	a2,0x5
ffffffffc0201020:	82460613          	addi	a2,a2,-2012 # ffffffffc0205840 <commands+0x870>
ffffffffc0201024:	0a900593          	li	a1,169
ffffffffc0201028:	00005517          	auipc	a0,0x5
ffffffffc020102c:	83050513          	addi	a0,a0,-2000 # ffffffffc0205858 <commands+0x888>
ffffffffc0201030:	c1cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201034:	00005697          	auipc	a3,0x5
ffffffffc0201038:	98468693          	addi	a3,a3,-1660 # ffffffffc02059b8 <commands+0x9e8>
ffffffffc020103c:	00005617          	auipc	a2,0x5
ffffffffc0201040:	80460613          	addi	a2,a2,-2044 # ffffffffc0205840 <commands+0x870>
ffffffffc0201044:	0a700593          	li	a1,167
ffffffffc0201048:	00005517          	auipc	a0,0x5
ffffffffc020104c:	81050513          	addi	a0,a0,-2032 # ffffffffc0205858 <commands+0x888>
ffffffffc0201050:	bfcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201054:	00005697          	auipc	a3,0x5
ffffffffc0201058:	9a468693          	addi	a3,a3,-1628 # ffffffffc02059f8 <commands+0xa28>
ffffffffc020105c:	00004617          	auipc	a2,0x4
ffffffffc0201060:	7e460613          	addi	a2,a2,2020 # ffffffffc0205840 <commands+0x870>
ffffffffc0201064:	0a600593          	li	a1,166
ffffffffc0201068:	00004517          	auipc	a0,0x4
ffffffffc020106c:	7f050513          	addi	a0,a0,2032 # ffffffffc0205858 <commands+0x888>
ffffffffc0201070:	bdcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201074:	00005697          	auipc	a3,0x5
ffffffffc0201078:	81c68693          	addi	a3,a3,-2020 # ffffffffc0205890 <commands+0x8c0>
ffffffffc020107c:	00004617          	auipc	a2,0x4
ffffffffc0201080:	7c460613          	addi	a2,a2,1988 # ffffffffc0205840 <commands+0x870>
ffffffffc0201084:	08300593          	li	a1,131
ffffffffc0201088:	00004517          	auipc	a0,0x4
ffffffffc020108c:	7d050513          	addi	a0,a0,2000 # ffffffffc0205858 <commands+0x888>
ffffffffc0201090:	bbcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201094:	00005697          	auipc	a3,0x5
ffffffffc0201098:	92468693          	addi	a3,a3,-1756 # ffffffffc02059b8 <commands+0x9e8>
ffffffffc020109c:	00004617          	auipc	a2,0x4
ffffffffc02010a0:	7a460613          	addi	a2,a2,1956 # ffffffffc0205840 <commands+0x870>
ffffffffc02010a4:	0a000593          	li	a1,160
ffffffffc02010a8:	00004517          	auipc	a0,0x4
ffffffffc02010ac:	7b050513          	addi	a0,a0,1968 # ffffffffc0205858 <commands+0x888>
ffffffffc02010b0:	b9cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010b4:	00005697          	auipc	a3,0x5
ffffffffc02010b8:	81c68693          	addi	a3,a3,-2020 # ffffffffc02058d0 <commands+0x900>
ffffffffc02010bc:	00004617          	auipc	a2,0x4
ffffffffc02010c0:	78460613          	addi	a2,a2,1924 # ffffffffc0205840 <commands+0x870>
ffffffffc02010c4:	09e00593          	li	a1,158
ffffffffc02010c8:	00004517          	auipc	a0,0x4
ffffffffc02010cc:	79050513          	addi	a0,a0,1936 # ffffffffc0205858 <commands+0x888>
ffffffffc02010d0:	b7cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010d4:	00004697          	auipc	a3,0x4
ffffffffc02010d8:	7dc68693          	addi	a3,a3,2012 # ffffffffc02058b0 <commands+0x8e0>
ffffffffc02010dc:	00004617          	auipc	a2,0x4
ffffffffc02010e0:	76460613          	addi	a2,a2,1892 # ffffffffc0205840 <commands+0x870>
ffffffffc02010e4:	09d00593          	li	a1,157
ffffffffc02010e8:	00004517          	auipc	a0,0x4
ffffffffc02010ec:	77050513          	addi	a0,a0,1904 # ffffffffc0205858 <commands+0x888>
ffffffffc02010f0:	b5cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010f4:	00004697          	auipc	a3,0x4
ffffffffc02010f8:	7dc68693          	addi	a3,a3,2012 # ffffffffc02058d0 <commands+0x900>
ffffffffc02010fc:	00004617          	auipc	a2,0x4
ffffffffc0201100:	74460613          	addi	a2,a2,1860 # ffffffffc0205840 <commands+0x870>
ffffffffc0201104:	08500593          	li	a1,133
ffffffffc0201108:	00004517          	auipc	a0,0x4
ffffffffc020110c:	75050513          	addi	a0,a0,1872 # ffffffffc0205858 <commands+0x888>
ffffffffc0201110:	b3cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(count == 0);
ffffffffc0201114:	00005697          	auipc	a3,0x5
ffffffffc0201118:	a6468693          	addi	a3,a3,-1436 # ffffffffc0205b78 <commands+0xba8>
ffffffffc020111c:	00004617          	auipc	a2,0x4
ffffffffc0201120:	72460613          	addi	a2,a2,1828 # ffffffffc0205840 <commands+0x870>
ffffffffc0201124:	12900593          	li	a1,297
ffffffffc0201128:	00004517          	auipc	a0,0x4
ffffffffc020112c:	73050513          	addi	a0,a0,1840 # ffffffffc0205858 <commands+0x888>
ffffffffc0201130:	b1cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free == 0);
ffffffffc0201134:	00005697          	auipc	a3,0x5
ffffffffc0201138:	8e468693          	addi	a3,a3,-1820 # ffffffffc0205a18 <commands+0xa48>
ffffffffc020113c:	00004617          	auipc	a2,0x4
ffffffffc0201140:	70460613          	addi	a2,a2,1796 # ffffffffc0205840 <commands+0x870>
ffffffffc0201144:	11e00593          	li	a1,286
ffffffffc0201148:	00004517          	auipc	a0,0x4
ffffffffc020114c:	71050513          	addi	a0,a0,1808 # ffffffffc0205858 <commands+0x888>
ffffffffc0201150:	afcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201154:	00005697          	auipc	a3,0x5
ffffffffc0201158:	86468693          	addi	a3,a3,-1948 # ffffffffc02059b8 <commands+0x9e8>
ffffffffc020115c:	00004617          	auipc	a2,0x4
ffffffffc0201160:	6e460613          	addi	a2,a2,1764 # ffffffffc0205840 <commands+0x870>
ffffffffc0201164:	11c00593          	li	a1,284
ffffffffc0201168:	00004517          	auipc	a0,0x4
ffffffffc020116c:	6f050513          	addi	a0,a0,1776 # ffffffffc0205858 <commands+0x888>
ffffffffc0201170:	adcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201174:	00005697          	auipc	a3,0x5
ffffffffc0201178:	80468693          	addi	a3,a3,-2044 # ffffffffc0205978 <commands+0x9a8>
ffffffffc020117c:	00004617          	auipc	a2,0x4
ffffffffc0201180:	6c460613          	addi	a2,a2,1732 # ffffffffc0205840 <commands+0x870>
ffffffffc0201184:	08b00593          	li	a1,139
ffffffffc0201188:	00004517          	auipc	a0,0x4
ffffffffc020118c:	6d050513          	addi	a0,a0,1744 # ffffffffc0205858 <commands+0x888>
ffffffffc0201190:	abcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201194:	00005697          	auipc	a3,0x5
ffffffffc0201198:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205b38 <commands+0xb68>
ffffffffc020119c:	00004617          	auipc	a2,0x4
ffffffffc02011a0:	6a460613          	addi	a2,a2,1700 # ffffffffc0205840 <commands+0x870>
ffffffffc02011a4:	11600593          	li	a1,278
ffffffffc02011a8:	00004517          	auipc	a0,0x4
ffffffffc02011ac:	6b050513          	addi	a0,a0,1712 # ffffffffc0205858 <commands+0x888>
ffffffffc02011b0:	a9cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011b4:	00005697          	auipc	a3,0x5
ffffffffc02011b8:	96468693          	addi	a3,a3,-1692 # ffffffffc0205b18 <commands+0xb48>
ffffffffc02011bc:	00004617          	auipc	a2,0x4
ffffffffc02011c0:	68460613          	addi	a2,a2,1668 # ffffffffc0205840 <commands+0x870>
ffffffffc02011c4:	11400593          	li	a1,276
ffffffffc02011c8:	00004517          	auipc	a0,0x4
ffffffffc02011cc:	69050513          	addi	a0,a0,1680 # ffffffffc0205858 <commands+0x888>
ffffffffc02011d0:	a7cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011d4:	00005697          	auipc	a3,0x5
ffffffffc02011d8:	91c68693          	addi	a3,a3,-1764 # ffffffffc0205af0 <commands+0xb20>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	66460613          	addi	a2,a2,1636 # ffffffffc0205840 <commands+0x870>
ffffffffc02011e4:	11200593          	li	a1,274
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	67050513          	addi	a0,a0,1648 # ffffffffc0205858 <commands+0x888>
ffffffffc02011f0:	a5cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011f4:	00005697          	auipc	a3,0x5
ffffffffc02011f8:	8d468693          	addi	a3,a3,-1836 # ffffffffc0205ac8 <commands+0xaf8>
ffffffffc02011fc:	00004617          	auipc	a2,0x4
ffffffffc0201200:	64460613          	addi	a2,a2,1604 # ffffffffc0205840 <commands+0x870>
ffffffffc0201204:	11100593          	li	a1,273
ffffffffc0201208:	00004517          	auipc	a0,0x4
ffffffffc020120c:	65050513          	addi	a0,a0,1616 # ffffffffc0205858 <commands+0x888>
ffffffffc0201210:	a3cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201214:	00005697          	auipc	a3,0x5
ffffffffc0201218:	8a468693          	addi	a3,a3,-1884 # ffffffffc0205ab8 <commands+0xae8>
ffffffffc020121c:	00004617          	auipc	a2,0x4
ffffffffc0201220:	62460613          	addi	a2,a2,1572 # ffffffffc0205840 <commands+0x870>
ffffffffc0201224:	10c00593          	li	a1,268
ffffffffc0201228:	00004517          	auipc	a0,0x4
ffffffffc020122c:	63050513          	addi	a0,a0,1584 # ffffffffc0205858 <commands+0x888>
ffffffffc0201230:	a1cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201234:	00004697          	auipc	a3,0x4
ffffffffc0201238:	78468693          	addi	a3,a3,1924 # ffffffffc02059b8 <commands+0x9e8>
ffffffffc020123c:	00004617          	auipc	a2,0x4
ffffffffc0201240:	60460613          	addi	a2,a2,1540 # ffffffffc0205840 <commands+0x870>
ffffffffc0201244:	10b00593          	li	a1,267
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	61050513          	addi	a0,a0,1552 # ffffffffc0205858 <commands+0x888>
ffffffffc0201250:	9fcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201254:	00005697          	auipc	a3,0x5
ffffffffc0201258:	84468693          	addi	a3,a3,-1980 # ffffffffc0205a98 <commands+0xac8>
ffffffffc020125c:	00004617          	auipc	a2,0x4
ffffffffc0201260:	5e460613          	addi	a2,a2,1508 # ffffffffc0205840 <commands+0x870>
ffffffffc0201264:	10a00593          	li	a1,266
ffffffffc0201268:	00004517          	auipc	a0,0x4
ffffffffc020126c:	5f050513          	addi	a0,a0,1520 # ffffffffc0205858 <commands+0x888>
ffffffffc0201270:	9dcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201274:	00004697          	auipc	a3,0x4
ffffffffc0201278:	7f468693          	addi	a3,a3,2036 # ffffffffc0205a68 <commands+0xa98>
ffffffffc020127c:	00004617          	auipc	a2,0x4
ffffffffc0201280:	5c460613          	addi	a2,a2,1476 # ffffffffc0205840 <commands+0x870>
ffffffffc0201284:	10900593          	li	a1,265
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	5d050513          	addi	a0,a0,1488 # ffffffffc0205858 <commands+0x888>
ffffffffc0201290:	9bcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201294:	00004697          	auipc	a3,0x4
ffffffffc0201298:	7bc68693          	addi	a3,a3,1980 # ffffffffc0205a50 <commands+0xa80>
ffffffffc020129c:	00004617          	auipc	a2,0x4
ffffffffc02012a0:	5a460613          	addi	a2,a2,1444 # ffffffffc0205840 <commands+0x870>
ffffffffc02012a4:	10800593          	li	a1,264
ffffffffc02012a8:	00004517          	auipc	a0,0x4
ffffffffc02012ac:	5b050513          	addi	a0,a0,1456 # ffffffffc0205858 <commands+0x888>
ffffffffc02012b0:	99cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012b4:	00004697          	auipc	a3,0x4
ffffffffc02012b8:	70468693          	addi	a3,a3,1796 # ffffffffc02059b8 <commands+0x9e8>
ffffffffc02012bc:	00004617          	auipc	a2,0x4
ffffffffc02012c0:	58460613          	addi	a2,a2,1412 # ffffffffc0205840 <commands+0x870>
ffffffffc02012c4:	10200593          	li	a1,258
ffffffffc02012c8:	00004517          	auipc	a0,0x4
ffffffffc02012cc:	59050513          	addi	a0,a0,1424 # ffffffffc0205858 <commands+0x888>
ffffffffc02012d0:	97cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(!PageProperty(p0));
ffffffffc02012d4:	00004697          	auipc	a3,0x4
ffffffffc02012d8:	76468693          	addi	a3,a3,1892 # ffffffffc0205a38 <commands+0xa68>
ffffffffc02012dc:	00004617          	auipc	a2,0x4
ffffffffc02012e0:	56460613          	addi	a2,a2,1380 # ffffffffc0205840 <commands+0x870>
ffffffffc02012e4:	0fd00593          	li	a1,253
ffffffffc02012e8:	00004517          	auipc	a0,0x4
ffffffffc02012ec:	57050513          	addi	a0,a0,1392 # ffffffffc0205858 <commands+0x888>
ffffffffc02012f0:	95cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012f4:	00005697          	auipc	a3,0x5
ffffffffc02012f8:	86468693          	addi	a3,a3,-1948 # ffffffffc0205b58 <commands+0xb88>
ffffffffc02012fc:	00004617          	auipc	a2,0x4
ffffffffc0201300:	54460613          	addi	a2,a2,1348 # ffffffffc0205840 <commands+0x870>
ffffffffc0201304:	11b00593          	li	a1,283
ffffffffc0201308:	00004517          	auipc	a0,0x4
ffffffffc020130c:	55050513          	addi	a0,a0,1360 # ffffffffc0205858 <commands+0x888>
ffffffffc0201310:	93cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(total == 0);
ffffffffc0201314:	00005697          	auipc	a3,0x5
ffffffffc0201318:	87468693          	addi	a3,a3,-1932 # ffffffffc0205b88 <commands+0xbb8>
ffffffffc020131c:	00004617          	auipc	a2,0x4
ffffffffc0201320:	52460613          	addi	a2,a2,1316 # ffffffffc0205840 <commands+0x870>
ffffffffc0201324:	12a00593          	li	a1,298
ffffffffc0201328:	00004517          	auipc	a0,0x4
ffffffffc020132c:	53050513          	addi	a0,a0,1328 # ffffffffc0205858 <commands+0x888>
ffffffffc0201330:	91cff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(total == nr_free_pages());
ffffffffc0201334:	00004697          	auipc	a3,0x4
ffffffffc0201338:	53c68693          	addi	a3,a3,1340 # ffffffffc0205870 <commands+0x8a0>
ffffffffc020133c:	00004617          	auipc	a2,0x4
ffffffffc0201340:	50460613          	addi	a2,a2,1284 # ffffffffc0205840 <commands+0x870>
ffffffffc0201344:	0f700593          	li	a1,247
ffffffffc0201348:	00004517          	auipc	a0,0x4
ffffffffc020134c:	51050513          	addi	a0,a0,1296 # ffffffffc0205858 <commands+0x888>
ffffffffc0201350:	8fcff0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201354:	00004697          	auipc	a3,0x4
ffffffffc0201358:	55c68693          	addi	a3,a3,1372 # ffffffffc02058b0 <commands+0x8e0>
ffffffffc020135c:	00004617          	auipc	a2,0x4
ffffffffc0201360:	4e460613          	addi	a2,a2,1252 # ffffffffc0205840 <commands+0x870>
ffffffffc0201364:	08400593          	li	a1,132
ffffffffc0201368:	00004517          	auipc	a0,0x4
ffffffffc020136c:	4f050513          	addi	a0,a0,1264 # ffffffffc0205858 <commands+0x888>
ffffffffc0201370:	8dcff0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201374 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201374:	1141                	addi	sp,sp,-16
ffffffffc0201376:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201378:	16058e63          	beqz	a1,ffffffffc02014f4 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020137c:	00659693          	slli	a3,a1,0x6
ffffffffc0201380:	96aa                	add	a3,a3,a0
ffffffffc0201382:	02d50d63          	beq	a0,a3,ffffffffc02013bc <default_free_pages+0x48>
ffffffffc0201386:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201388:	8b85                	andi	a5,a5,1
ffffffffc020138a:	14079563          	bnez	a5,ffffffffc02014d4 <default_free_pages+0x160>
ffffffffc020138e:	651c                	ld	a5,8(a0)
ffffffffc0201390:	8385                	srli	a5,a5,0x1
ffffffffc0201392:	8b85                	andi	a5,a5,1
ffffffffc0201394:	14079063          	bnez	a5,ffffffffc02014d4 <default_free_pages+0x160>
ffffffffc0201398:	87aa                	mv	a5,a0
ffffffffc020139a:	a809                	j	ffffffffc02013ac <default_free_pages+0x38>
ffffffffc020139c:	6798                	ld	a4,8(a5)
ffffffffc020139e:	8b05                	andi	a4,a4,1
ffffffffc02013a0:	12071a63          	bnez	a4,ffffffffc02014d4 <default_free_pages+0x160>
ffffffffc02013a4:	6798                	ld	a4,8(a5)
ffffffffc02013a6:	8b09                	andi	a4,a4,2
ffffffffc02013a8:	12071663          	bnez	a4,ffffffffc02014d4 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02013ac:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02013b0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02013b4:	04078793          	addi	a5,a5,64
ffffffffc02013b8:	fed792e3          	bne	a5,a3,ffffffffc020139c <default_free_pages+0x28>
    base->property = n;
ffffffffc02013bc:	2581                	sext.w	a1,a1
ffffffffc02013be:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02013c0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013c4:	4789                	li	a5,2
ffffffffc02013c6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02013ca:	00014697          	auipc	a3,0x14
ffffffffc02013ce:	10668693          	addi	a3,a3,262 # ffffffffc02154d0 <free_area>
ffffffffc02013d2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02013d4:	669c                	ld	a5,8(a3)
ffffffffc02013d6:	9db9                	addw	a1,a1,a4
ffffffffc02013d8:	00014717          	auipc	a4,0x14
ffffffffc02013dc:	10b72423          	sw	a1,264(a4) # ffffffffc02154e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02013e0:	0cd78163          	beq	a5,a3,ffffffffc02014a2 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02013e4:	fe878713          	addi	a4,a5,-24
ffffffffc02013e8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013ea:	4801                	li	a6,0
ffffffffc02013ec:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02013f0:	00e56a63          	bltu	a0,a4,ffffffffc0201404 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02013f4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013f6:	04d70f63          	beq	a4,a3,ffffffffc0201454 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013fa:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013fc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201400:	fee57ae3          	bgeu	a0,a4,ffffffffc02013f4 <default_free_pages+0x80>
ffffffffc0201404:	00080663          	beqz	a6,ffffffffc0201410 <default_free_pages+0x9c>
ffffffffc0201408:	00014817          	auipc	a6,0x14
ffffffffc020140c:	0cb83423          	sd	a1,200(a6) # ffffffffc02154d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201410:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201412:	e390                	sd	a2,0(a5)
ffffffffc0201414:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201416:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201418:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020141a:	06d58a63          	beq	a1,a3,ffffffffc020148e <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc020141e:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201422:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201426:	02061793          	slli	a5,a2,0x20
ffffffffc020142a:	83e9                	srli	a5,a5,0x1a
ffffffffc020142c:	97ba                	add	a5,a5,a4
ffffffffc020142e:	04f51b63          	bne	a0,a5,ffffffffc0201484 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201432:	491c                	lw	a5,16(a0)
ffffffffc0201434:	9e3d                	addw	a2,a2,a5
ffffffffc0201436:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020143a:	57f5                	li	a5,-3
ffffffffc020143c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201440:	01853803          	ld	a6,24(a0)
ffffffffc0201444:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201446:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201448:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020144c:	659c                	ld	a5,8(a1)
ffffffffc020144e:	01063023          	sd	a6,0(a2)
ffffffffc0201452:	a815                	j	ffffffffc0201486 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201454:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201456:	f114                	sd	a3,32(a0)
ffffffffc0201458:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020145a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020145c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020145e:	00d70563          	beq	a4,a3,ffffffffc0201468 <default_free_pages+0xf4>
ffffffffc0201462:	4805                	li	a6,1
ffffffffc0201464:	87ba                	mv	a5,a4
ffffffffc0201466:	bf59                	j	ffffffffc02013fc <default_free_pages+0x88>
ffffffffc0201468:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020146a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020146c:	00d78d63          	beq	a5,a3,ffffffffc0201486 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201470:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201474:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201478:	02061793          	slli	a5,a2,0x20
ffffffffc020147c:	83e9                	srli	a5,a5,0x1a
ffffffffc020147e:	97ba                	add	a5,a5,a4
ffffffffc0201480:	faf509e3          	beq	a0,a5,ffffffffc0201432 <default_free_pages+0xbe>
ffffffffc0201484:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201486:	fe878713          	addi	a4,a5,-24
ffffffffc020148a:	00d78963          	beq	a5,a3,ffffffffc020149c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020148e:	4910                	lw	a2,16(a0)
ffffffffc0201490:	02061693          	slli	a3,a2,0x20
ffffffffc0201494:	82e9                	srli	a3,a3,0x1a
ffffffffc0201496:	96aa                	add	a3,a3,a0
ffffffffc0201498:	00d70e63          	beq	a4,a3,ffffffffc02014b4 <default_free_pages+0x140>
}
ffffffffc020149c:	60a2                	ld	ra,8(sp)
ffffffffc020149e:	0141                	addi	sp,sp,16
ffffffffc02014a0:	8082                	ret
ffffffffc02014a2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02014a4:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02014a8:	e398                	sd	a4,0(a5)
ffffffffc02014aa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014ac:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014ae:	ed1c                	sd	a5,24(a0)
}
ffffffffc02014b0:	0141                	addi	sp,sp,16
ffffffffc02014b2:	8082                	ret
            base->property += p->property;
ffffffffc02014b4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014b8:	ff078693          	addi	a3,a5,-16
ffffffffc02014bc:	9e39                	addw	a2,a2,a4
ffffffffc02014be:	c910                	sw	a2,16(a0)
ffffffffc02014c0:	5775                	li	a4,-3
ffffffffc02014c2:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014c6:	6398                	ld	a4,0(a5)
ffffffffc02014c8:	679c                	ld	a5,8(a5)
}
ffffffffc02014ca:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02014cc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02014ce:	e398                	sd	a4,0(a5)
ffffffffc02014d0:	0141                	addi	sp,sp,16
ffffffffc02014d2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014d4:	00004697          	auipc	a3,0x4
ffffffffc02014d8:	6c468693          	addi	a3,a3,1732 # ffffffffc0205b98 <commands+0xbc8>
ffffffffc02014dc:	00004617          	auipc	a2,0x4
ffffffffc02014e0:	36460613          	addi	a2,a2,868 # ffffffffc0205840 <commands+0x870>
ffffffffc02014e4:	0b900593          	li	a1,185
ffffffffc02014e8:	00004517          	auipc	a0,0x4
ffffffffc02014ec:	37050513          	addi	a0,a0,880 # ffffffffc0205858 <commands+0x888>
ffffffffc02014f0:	f5dfe0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(n > 0);
ffffffffc02014f4:	00004697          	auipc	a3,0x4
ffffffffc02014f8:	6cc68693          	addi	a3,a3,1740 # ffffffffc0205bc0 <commands+0xbf0>
ffffffffc02014fc:	00004617          	auipc	a2,0x4
ffffffffc0201500:	34460613          	addi	a2,a2,836 # ffffffffc0205840 <commands+0x870>
ffffffffc0201504:	0b600593          	li	a1,182
ffffffffc0201508:	00004517          	auipc	a0,0x4
ffffffffc020150c:	35050513          	addi	a0,a0,848 # ffffffffc0205858 <commands+0x888>
ffffffffc0201510:	f3dfe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201514 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201514:	c959                	beqz	a0,ffffffffc02015aa <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0201516:	00014597          	auipc	a1,0x14
ffffffffc020151a:	fba58593          	addi	a1,a1,-70 # ffffffffc02154d0 <free_area>
ffffffffc020151e:	0105a803          	lw	a6,16(a1)
ffffffffc0201522:	862a                	mv	a2,a0
ffffffffc0201524:	02081793          	slli	a5,a6,0x20
ffffffffc0201528:	9381                	srli	a5,a5,0x20
ffffffffc020152a:	00a7ee63          	bltu	a5,a0,ffffffffc0201546 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020152e:	87ae                	mv	a5,a1
ffffffffc0201530:	a801                	j	ffffffffc0201540 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201532:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201536:	02071693          	slli	a3,a4,0x20
ffffffffc020153a:	9281                	srli	a3,a3,0x20
ffffffffc020153c:	00c6f763          	bgeu	a3,a2,ffffffffc020154a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201540:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201542:	feb798e3          	bne	a5,a1,ffffffffc0201532 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201546:	4501                	li	a0,0
}
ffffffffc0201548:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020154a:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020154e:	dd6d                	beqz	a0,ffffffffc0201548 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201550:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201554:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201558:	00060e1b          	sext.w	t3,a2
ffffffffc020155c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201560:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201564:	02d67863          	bgeu	a2,a3,ffffffffc0201594 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201568:	061a                	slli	a2,a2,0x6
ffffffffc020156a:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020156c:	41c7073b          	subw	a4,a4,t3
ffffffffc0201570:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201572:	00860693          	addi	a3,a2,8
ffffffffc0201576:	4709                	li	a4,2
ffffffffc0201578:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020157c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201580:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201584:	0105a803          	lw	a6,16(a1)
ffffffffc0201588:	e314                	sd	a3,0(a4)
ffffffffc020158a:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020158e:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201590:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201594:	41c8083b          	subw	a6,a6,t3
ffffffffc0201598:	00014717          	auipc	a4,0x14
ffffffffc020159c:	f5072423          	sw	a6,-184(a4) # ffffffffc02154e0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02015a0:	5775                	li	a4,-3
ffffffffc02015a2:	17c1                	addi	a5,a5,-16
ffffffffc02015a4:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02015a8:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02015aa:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02015ac:	00004697          	auipc	a3,0x4
ffffffffc02015b0:	61468693          	addi	a3,a3,1556 # ffffffffc0205bc0 <commands+0xbf0>
ffffffffc02015b4:	00004617          	auipc	a2,0x4
ffffffffc02015b8:	28c60613          	addi	a2,a2,652 # ffffffffc0205840 <commands+0x870>
ffffffffc02015bc:	06200593          	li	a1,98
ffffffffc02015c0:	00004517          	auipc	a0,0x4
ffffffffc02015c4:	29850513          	addi	a0,a0,664 # ffffffffc0205858 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc02015c8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015ca:	e83fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02015ce <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02015ce:	1141                	addi	sp,sp,-16
ffffffffc02015d0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015d2:	c1ed                	beqz	a1,ffffffffc02016b4 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02015d4:	00659693          	slli	a3,a1,0x6
ffffffffc02015d8:	96aa                	add	a3,a3,a0
ffffffffc02015da:	02d50463          	beq	a0,a3,ffffffffc0201602 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015de:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02015e0:	87aa                	mv	a5,a0
ffffffffc02015e2:	8b05                	andi	a4,a4,1
ffffffffc02015e4:	e709                	bnez	a4,ffffffffc02015ee <default_init_memmap+0x20>
ffffffffc02015e6:	a07d                	j	ffffffffc0201694 <default_init_memmap+0xc6>
ffffffffc02015e8:	6798                	ld	a4,8(a5)
ffffffffc02015ea:	8b05                	andi	a4,a4,1
ffffffffc02015ec:	c745                	beqz	a4,ffffffffc0201694 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02015ee:	0007a823          	sw	zero,16(a5)
ffffffffc02015f2:	0007b423          	sd	zero,8(a5)
ffffffffc02015f6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015fa:	04078793          	addi	a5,a5,64
ffffffffc02015fe:	fed795e3          	bne	a5,a3,ffffffffc02015e8 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0201602:	2581                	sext.w	a1,a1
ffffffffc0201604:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201606:	4789                	li	a5,2
ffffffffc0201608:	00850713          	addi	a4,a0,8
ffffffffc020160c:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201610:	00014697          	auipc	a3,0x14
ffffffffc0201614:	ec068693          	addi	a3,a3,-320 # ffffffffc02154d0 <free_area>
ffffffffc0201618:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020161a:	669c                	ld	a5,8(a3)
ffffffffc020161c:	9db9                	addw	a1,a1,a4
ffffffffc020161e:	00014717          	auipc	a4,0x14
ffffffffc0201622:	ecb72123          	sw	a1,-318(a4) # ffffffffc02154e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201626:	04d78a63          	beq	a5,a3,ffffffffc020167a <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc020162a:	fe878713          	addi	a4,a5,-24
ffffffffc020162e:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201630:	4801                	li	a6,0
ffffffffc0201632:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201636:	00e56a63          	bltu	a0,a4,ffffffffc020164a <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020163a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020163c:	02d70563          	beq	a4,a3,ffffffffc0201666 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201640:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201642:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201646:	fee57ae3          	bgeu	a0,a4,ffffffffc020163a <default_init_memmap+0x6c>
ffffffffc020164a:	00080663          	beqz	a6,ffffffffc0201656 <default_init_memmap+0x88>
ffffffffc020164e:	00014717          	auipc	a4,0x14
ffffffffc0201652:	e8b73123          	sd	a1,-382(a4) # ffffffffc02154d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201656:	6398                	ld	a4,0(a5)
}
ffffffffc0201658:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020165a:	e390                	sd	a2,0(a5)
ffffffffc020165c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020165e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201660:	ed18                	sd	a4,24(a0)
ffffffffc0201662:	0141                	addi	sp,sp,16
ffffffffc0201664:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201666:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201668:	f114                	sd	a3,32(a0)
ffffffffc020166a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020166c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020166e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201670:	00d70e63          	beq	a4,a3,ffffffffc020168c <default_init_memmap+0xbe>
ffffffffc0201674:	4805                	li	a6,1
ffffffffc0201676:	87ba                	mv	a5,a4
ffffffffc0201678:	b7e9                	j	ffffffffc0201642 <default_init_memmap+0x74>
}
ffffffffc020167a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020167c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201680:	e398                	sd	a4,0(a5)
ffffffffc0201682:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201684:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201686:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201688:	0141                	addi	sp,sp,16
ffffffffc020168a:	8082                	ret
ffffffffc020168c:	60a2                	ld	ra,8(sp)
ffffffffc020168e:	e290                	sd	a2,0(a3)
ffffffffc0201690:	0141                	addi	sp,sp,16
ffffffffc0201692:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201694:	00004697          	auipc	a3,0x4
ffffffffc0201698:	53468693          	addi	a3,a3,1332 # ffffffffc0205bc8 <commands+0xbf8>
ffffffffc020169c:	00004617          	auipc	a2,0x4
ffffffffc02016a0:	1a460613          	addi	a2,a2,420 # ffffffffc0205840 <commands+0x870>
ffffffffc02016a4:	04900593          	li	a1,73
ffffffffc02016a8:	00004517          	auipc	a0,0x4
ffffffffc02016ac:	1b050513          	addi	a0,a0,432 # ffffffffc0205858 <commands+0x888>
ffffffffc02016b0:	d9dfe0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(n > 0);
ffffffffc02016b4:	00004697          	auipc	a3,0x4
ffffffffc02016b8:	50c68693          	addi	a3,a3,1292 # ffffffffc0205bc0 <commands+0xbf0>
ffffffffc02016bc:	00004617          	auipc	a2,0x4
ffffffffc02016c0:	18460613          	addi	a2,a2,388 # ffffffffc0205840 <commands+0x870>
ffffffffc02016c4:	04600593          	li	a1,70
ffffffffc02016c8:	00004517          	auipc	a0,0x4
ffffffffc02016cc:	19050513          	addi	a0,a0,400 # ffffffffc0205858 <commands+0x888>
ffffffffc02016d0:	d7dfe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02016d4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02016d4:	c125                	beqz	a0,ffffffffc0201734 <slob_free+0x60>
		return;

	if (size)
ffffffffc02016d6:	e1a5                	bnez	a1,ffffffffc0201736 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016d8:	100027f3          	csrr	a5,sstatus
ffffffffc02016dc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02016de:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016e0:	e3bd                	bnez	a5,ffffffffc0201746 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016e2:	00009797          	auipc	a5,0x9
ffffffffc02016e6:	96e78793          	addi	a5,a5,-1682 # ffffffffc020a050 <slobfree>
ffffffffc02016ea:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016ec:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016ee:	00a7fa63          	bgeu	a5,a0,ffffffffc0201702 <slob_free+0x2e>
ffffffffc02016f2:	00e56c63          	bltu	a0,a4,ffffffffc020170a <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016f6:	00e7fa63          	bgeu	a5,a4,ffffffffc020170a <slob_free+0x36>
    return 0;
ffffffffc02016fa:	87ba                	mv	a5,a4
ffffffffc02016fc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016fe:	fea7eae3          	bltu	a5,a0,ffffffffc02016f2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201702:	fee7ece3          	bltu	a5,a4,ffffffffc02016fa <slob_free+0x26>
ffffffffc0201706:	fee57ae3          	bgeu	a0,a4,ffffffffc02016fa <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc020170a:	4110                	lw	a2,0(a0)
ffffffffc020170c:	00461693          	slli	a3,a2,0x4
ffffffffc0201710:	96aa                	add	a3,a3,a0
ffffffffc0201712:	08d70b63          	beq	a4,a3,ffffffffc02017a8 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201716:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0201718:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020171a:	00469713          	slli	a4,a3,0x4
ffffffffc020171e:	973e                	add	a4,a4,a5
ffffffffc0201720:	08e50f63          	beq	a0,a4,ffffffffc02017be <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201724:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201726:	00009717          	auipc	a4,0x9
ffffffffc020172a:	92f73523          	sd	a5,-1750(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc020172e:	c199                	beqz	a1,ffffffffc0201734 <slob_free+0x60>
        intr_enable();
ffffffffc0201730:	e9bfe06f          	j	ffffffffc02005ca <intr_enable>
ffffffffc0201734:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201736:	05bd                	addi	a1,a1,15
ffffffffc0201738:	8191                	srli	a1,a1,0x4
ffffffffc020173a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020173c:	100027f3          	csrr	a5,sstatus
ffffffffc0201740:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201742:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201744:	dfd9                	beqz	a5,ffffffffc02016e2 <slob_free+0xe>
{
ffffffffc0201746:	1101                	addi	sp,sp,-32
ffffffffc0201748:	e42a                	sd	a0,8(sp)
ffffffffc020174a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020174c:	e85fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201750:	00009797          	auipc	a5,0x9
ffffffffc0201754:	90078793          	addi	a5,a5,-1792 # ffffffffc020a050 <slobfree>
ffffffffc0201758:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc020175a:	6522                	ld	a0,8(sp)
ffffffffc020175c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020175e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201760:	00a7fa63          	bgeu	a5,a0,ffffffffc0201774 <slob_free+0xa0>
ffffffffc0201764:	00e56c63          	bltu	a0,a4,ffffffffc020177c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201768:	00e7fa63          	bgeu	a5,a4,ffffffffc020177c <slob_free+0xa8>
    return 0;
ffffffffc020176c:	87ba                	mv	a5,a4
ffffffffc020176e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201770:	fea7eae3          	bltu	a5,a0,ffffffffc0201764 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201774:	fee7ece3          	bltu	a5,a4,ffffffffc020176c <slob_free+0x98>
ffffffffc0201778:	fee57ae3          	bgeu	a0,a4,ffffffffc020176c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc020177c:	4110                	lw	a2,0(a0)
ffffffffc020177e:	00461693          	slli	a3,a2,0x4
ffffffffc0201782:	96aa                	add	a3,a3,a0
ffffffffc0201784:	04d70763          	beq	a4,a3,ffffffffc02017d2 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201788:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020178a:	4394                	lw	a3,0(a5)
ffffffffc020178c:	00469713          	slli	a4,a3,0x4
ffffffffc0201790:	973e                	add	a4,a4,a5
ffffffffc0201792:	04e50663          	beq	a0,a4,ffffffffc02017de <slob_free+0x10a>
		cur->next = b;
ffffffffc0201796:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201798:	00009717          	auipc	a4,0x9
ffffffffc020179c:	8af73c23          	sd	a5,-1864(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02017a0:	e58d                	bnez	a1,ffffffffc02017ca <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02017a2:	60e2                	ld	ra,24(sp)
ffffffffc02017a4:	6105                	addi	sp,sp,32
ffffffffc02017a6:	8082                	ret
		b->units += cur->next->units;
ffffffffc02017a8:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02017aa:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017ac:	9e35                	addw	a2,a2,a3
ffffffffc02017ae:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc02017b0:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02017b2:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017b4:	00469713          	slli	a4,a3,0x4
ffffffffc02017b8:	973e                	add	a4,a4,a5
ffffffffc02017ba:	f6e515e3          	bne	a0,a4,ffffffffc0201724 <slob_free+0x50>
		cur->units += b->units;
ffffffffc02017be:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017c0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017c2:	9eb9                	addw	a3,a3,a4
ffffffffc02017c4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02017c6:	e790                	sd	a2,8(a5)
ffffffffc02017c8:	bfb9                	j	ffffffffc0201726 <slob_free+0x52>
}
ffffffffc02017ca:	60e2                	ld	ra,24(sp)
ffffffffc02017cc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02017ce:	dfdfe06f          	j	ffffffffc02005ca <intr_enable>
		b->units += cur->next->units;
ffffffffc02017d2:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02017d4:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017d6:	9e35                	addw	a2,a2,a3
ffffffffc02017d8:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc02017da:	e518                	sd	a4,8(a0)
ffffffffc02017dc:	b77d                	j	ffffffffc020178a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc02017de:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017e0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017e2:	9eb9                	addw	a3,a3,a4
ffffffffc02017e4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02017e6:	e790                	sd	a2,8(a5)
ffffffffc02017e8:	bf45                	j	ffffffffc0201798 <slob_free+0xc4>

ffffffffc02017ea <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017ea:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02017ec:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017ee:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02017f2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017f4:	374000ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
  if(!page)
ffffffffc02017f8:	cd1d                	beqz	a0,ffffffffc0201836 <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc02017fa:	00014797          	auipc	a5,0x14
ffffffffc02017fe:	d0678793          	addi	a5,a5,-762 # ffffffffc0215500 <pages>
ffffffffc0201802:	6394                	ld	a3,0(a5)
ffffffffc0201804:	00005797          	auipc	a5,0x5
ffffffffc0201808:	7dc78793          	addi	a5,a5,2012 # ffffffffc0206fe0 <nbase>
ffffffffc020180c:	8d15                	sub	a0,a0,a3
ffffffffc020180e:	6394                	ld	a3,0(a5)
ffffffffc0201810:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0201812:	00014797          	auipc	a5,0x14
ffffffffc0201816:	c7e78793          	addi	a5,a5,-898 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc020181a:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020181c:	6398                	ld	a4,0(a5)
ffffffffc020181e:	00c51793          	slli	a5,a0,0xc
ffffffffc0201822:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201824:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201826:	00e7fb63          	bgeu	a5,a4,ffffffffc020183c <__slob_get_free_pages.isra.0+0x52>
ffffffffc020182a:	00014797          	auipc	a5,0x14
ffffffffc020182e:	cc678793          	addi	a5,a5,-826 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201832:	6394                	ld	a3,0(a5)
ffffffffc0201834:	9536                	add	a0,a0,a3
}
ffffffffc0201836:	60a2                	ld	ra,8(sp)
ffffffffc0201838:	0141                	addi	sp,sp,16
ffffffffc020183a:	8082                	ret
ffffffffc020183c:	86aa                	mv	a3,a0
ffffffffc020183e:	00004617          	auipc	a2,0x4
ffffffffc0201842:	3ea60613          	addi	a2,a2,1002 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0201846:	06900593          	li	a1,105
ffffffffc020184a:	00004517          	auipc	a0,0x4
ffffffffc020184e:	40650513          	addi	a0,a0,1030 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0201852:	bfbfe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201856 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201856:	1101                	addi	sp,sp,-32
ffffffffc0201858:	ec06                	sd	ra,24(sp)
ffffffffc020185a:	e822                	sd	s0,16(sp)
ffffffffc020185c:	e426                	sd	s1,8(sp)
ffffffffc020185e:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201860:	01050713          	addi	a4,a0,16
ffffffffc0201864:	6785                	lui	a5,0x1
ffffffffc0201866:	0cf77563          	bgeu	a4,a5,ffffffffc0201930 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc020186a:	00f50493          	addi	s1,a0,15
ffffffffc020186e:	8091                	srli	s1,s1,0x4
ffffffffc0201870:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201872:	10002673          	csrr	a2,sstatus
ffffffffc0201876:	8a09                	andi	a2,a2,2
ffffffffc0201878:	e64d                	bnez	a2,ffffffffc0201922 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc020187a:	00008917          	auipc	s2,0x8
ffffffffc020187e:	7d690913          	addi	s2,s2,2006 # ffffffffc020a050 <slobfree>
ffffffffc0201882:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201886:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201888:	4398                	lw	a4,0(a5)
ffffffffc020188a:	0a975063          	bge	a4,s1,ffffffffc020192a <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc020188e:	00d78b63          	beq	a5,a3,ffffffffc02018a4 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201892:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201894:	4018                	lw	a4,0(s0)
ffffffffc0201896:	02975a63          	bge	a4,s1,ffffffffc02018ca <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc020189a:	00093683          	ld	a3,0(s2)
ffffffffc020189e:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc02018a0:	fed799e3          	bne	a5,a3,ffffffffc0201892 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc02018a4:	e225                	bnez	a2,ffffffffc0201904 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02018a6:	4501                	li	a0,0
ffffffffc02018a8:	f43ff0ef          	jal	ra,ffffffffc02017ea <__slob_get_free_pages.isra.0>
ffffffffc02018ac:	842a                	mv	s0,a0
			if (!cur)
ffffffffc02018ae:	cd15                	beqz	a0,ffffffffc02018ea <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc02018b0:	6585                	lui	a1,0x1
ffffffffc02018b2:	e23ff0ef          	jal	ra,ffffffffc02016d4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018b6:	10002673          	csrr	a2,sstatus
ffffffffc02018ba:	8a09                	andi	a2,a2,2
ffffffffc02018bc:	ee15                	bnez	a2,ffffffffc02018f8 <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc02018be:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018c2:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018c4:	4018                	lw	a4,0(s0)
ffffffffc02018c6:	fc974ae3          	blt	a4,s1,ffffffffc020189a <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc02018ca:	04e48963          	beq	s1,a4,ffffffffc020191c <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc02018ce:	00449693          	slli	a3,s1,0x4
ffffffffc02018d2:	96a2                	add	a3,a3,s0
ffffffffc02018d4:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02018d6:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc02018d8:	9f05                	subw	a4,a4,s1
ffffffffc02018da:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02018dc:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02018de:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc02018e0:	00008717          	auipc	a4,0x8
ffffffffc02018e4:	76f73823          	sd	a5,1904(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02018e8:	e20d                	bnez	a2,ffffffffc020190a <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc02018ea:	8522                	mv	a0,s0
ffffffffc02018ec:	60e2                	ld	ra,24(sp)
ffffffffc02018ee:	6442                	ld	s0,16(sp)
ffffffffc02018f0:	64a2                	ld	s1,8(sp)
ffffffffc02018f2:	6902                	ld	s2,0(sp)
ffffffffc02018f4:	6105                	addi	sp,sp,32
ffffffffc02018f6:	8082                	ret
        intr_disable();
ffffffffc02018f8:	cd9fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc02018fc:	4605                	li	a2,1
			cur = slobfree;
ffffffffc02018fe:	00093783          	ld	a5,0(s2)
ffffffffc0201902:	b7c1                	j	ffffffffc02018c2 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0201904:	cc7fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201908:	bf79                	j	ffffffffc02018a6 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc020190a:	cc1fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
}
ffffffffc020190e:	8522                	mv	a0,s0
ffffffffc0201910:	60e2                	ld	ra,24(sp)
ffffffffc0201912:	6442                	ld	s0,16(sp)
ffffffffc0201914:	64a2                	ld	s1,8(sp)
ffffffffc0201916:	6902                	ld	s2,0(sp)
ffffffffc0201918:	6105                	addi	sp,sp,32
ffffffffc020191a:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020191c:	6418                	ld	a4,8(s0)
ffffffffc020191e:	e798                	sd	a4,8(a5)
ffffffffc0201920:	b7c1                	j	ffffffffc02018e0 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0201922:	caffe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0201926:	4605                	li	a2,1
ffffffffc0201928:	bf89                	j	ffffffffc020187a <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020192a:	843e                	mv	s0,a5
ffffffffc020192c:	87b6                	mv	a5,a3
ffffffffc020192e:	bf71                	j	ffffffffc02018ca <slob_alloc.isra.1.constprop.3+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201930:	00004697          	auipc	a3,0x4
ffffffffc0201934:	39868693          	addi	a3,a3,920 # ffffffffc0205cc8 <default_pmm_manager+0xf0>
ffffffffc0201938:	00004617          	auipc	a2,0x4
ffffffffc020193c:	f0860613          	addi	a2,a2,-248 # ffffffffc0205840 <commands+0x870>
ffffffffc0201940:	06300593          	li	a1,99
ffffffffc0201944:	00004517          	auipc	a0,0x4
ffffffffc0201948:	3a450513          	addi	a0,a0,932 # ffffffffc0205ce8 <default_pmm_manager+0x110>
ffffffffc020194c:	b01fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201950 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201950:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201952:	00004517          	auipc	a0,0x4
ffffffffc0201956:	3ae50513          	addi	a0,a0,942 # ffffffffc0205d00 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc020195a:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc020195c:	833fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201960:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201962:	00004517          	auipc	a0,0x4
ffffffffc0201966:	34650513          	addi	a0,a0,838 # ffffffffc0205ca8 <default_pmm_manager+0xd0>
}
ffffffffc020196a:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020196c:	823fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201970 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201970:	1101                	addi	sp,sp,-32
ffffffffc0201972:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201974:	6905                	lui	s2,0x1
{
ffffffffc0201976:	e822                	sd	s0,16(sp)
ffffffffc0201978:	ec06                	sd	ra,24(sp)
ffffffffc020197a:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020197c:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0201980:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201982:	04a7fc63          	bgeu	a5,a0,ffffffffc02019da <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201986:	4561                	li	a0,24
ffffffffc0201988:	ecfff0ef          	jal	ra,ffffffffc0201856 <slob_alloc.isra.1.constprop.3>
ffffffffc020198c:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc020198e:	cd21                	beqz	a0,ffffffffc02019e6 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201990:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201994:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201996:	00f95763          	bge	s2,a5,ffffffffc02019a4 <kmalloc+0x34>
ffffffffc020199a:	6705                	lui	a4,0x1
ffffffffc020199c:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc020199e:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019a0:	fef74ee3          	blt	a4,a5,ffffffffc020199c <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02019a4:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02019a6:	e45ff0ef          	jal	ra,ffffffffc02017ea <__slob_get_free_pages.isra.0>
ffffffffc02019aa:	e488                	sd	a0,8(s1)
ffffffffc02019ac:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02019ae:	c935                	beqz	a0,ffffffffc0201a22 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b0:	100027f3          	csrr	a5,sstatus
ffffffffc02019b4:	8b89                	andi	a5,a5,2
ffffffffc02019b6:	e3a1                	bnez	a5,ffffffffc02019f6 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02019b8:	00014797          	auipc	a5,0x14
ffffffffc02019bc:	ac878793          	addi	a5,a5,-1336 # ffffffffc0215480 <bigblocks>
ffffffffc02019c0:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02019c2:	00014717          	auipc	a4,0x14
ffffffffc02019c6:	aa973f23          	sd	s1,-1346(a4) # ffffffffc0215480 <bigblocks>
		bb->next = bigblocks;
ffffffffc02019ca:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02019cc:	8522                	mv	a0,s0
ffffffffc02019ce:	60e2                	ld	ra,24(sp)
ffffffffc02019d0:	6442                	ld	s0,16(sp)
ffffffffc02019d2:	64a2                	ld	s1,8(sp)
ffffffffc02019d4:	6902                	ld	s2,0(sp)
ffffffffc02019d6:	6105                	addi	sp,sp,32
ffffffffc02019d8:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02019da:	0541                	addi	a0,a0,16
ffffffffc02019dc:	e7bff0ef          	jal	ra,ffffffffc0201856 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc02019e0:	01050413          	addi	s0,a0,16
ffffffffc02019e4:	f565                	bnez	a0,ffffffffc02019cc <kmalloc+0x5c>
ffffffffc02019e6:	4401                	li	s0,0
}
ffffffffc02019e8:	8522                	mv	a0,s0
ffffffffc02019ea:	60e2                	ld	ra,24(sp)
ffffffffc02019ec:	6442                	ld	s0,16(sp)
ffffffffc02019ee:	64a2                	ld	s1,8(sp)
ffffffffc02019f0:	6902                	ld	s2,0(sp)
ffffffffc02019f2:	6105                	addi	sp,sp,32
ffffffffc02019f4:	8082                	ret
        intr_disable();
ffffffffc02019f6:	bdbfe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
		bb->next = bigblocks;
ffffffffc02019fa:	00014797          	auipc	a5,0x14
ffffffffc02019fe:	a8678793          	addi	a5,a5,-1402 # ffffffffc0215480 <bigblocks>
ffffffffc0201a02:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a04:	00014717          	auipc	a4,0x14
ffffffffc0201a08:	a6973e23          	sd	s1,-1412(a4) # ffffffffc0215480 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a0c:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201a0e:	bbdfe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201a12:	6480                	ld	s0,8(s1)
}
ffffffffc0201a14:	60e2                	ld	ra,24(sp)
ffffffffc0201a16:	64a2                	ld	s1,8(sp)
ffffffffc0201a18:	8522                	mv	a0,s0
ffffffffc0201a1a:	6442                	ld	s0,16(sp)
ffffffffc0201a1c:	6902                	ld	s2,0(sp)
ffffffffc0201a1e:	6105                	addi	sp,sp,32
ffffffffc0201a20:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201a22:	45e1                	li	a1,24
ffffffffc0201a24:	8526                	mv	a0,s1
ffffffffc0201a26:	cafff0ef          	jal	ra,ffffffffc02016d4 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201a2a:	b74d                	j	ffffffffc02019cc <kmalloc+0x5c>

ffffffffc0201a2c <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201a2c:	c165                	beqz	a0,ffffffffc0201b0c <kfree+0xe0>
{
ffffffffc0201a2e:	1101                	addi	sp,sp,-32
ffffffffc0201a30:	e426                	sd	s1,8(sp)
ffffffffc0201a32:	ec06                	sd	ra,24(sp)
ffffffffc0201a34:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201a36:	03451793          	slli	a5,a0,0x34
ffffffffc0201a3a:	84aa                	mv	s1,a0
ffffffffc0201a3c:	eb8d                	bnez	a5,ffffffffc0201a6e <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a3e:	100027f3          	csrr	a5,sstatus
ffffffffc0201a42:	8b89                	andi	a5,a5,2
ffffffffc0201a44:	ebd9                	bnez	a5,ffffffffc0201ada <kfree+0xae>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a46:	00014797          	auipc	a5,0x14
ffffffffc0201a4a:	a3a78793          	addi	a5,a5,-1478 # ffffffffc0215480 <bigblocks>
ffffffffc0201a4e:	6394                	ld	a3,0(a5)
ffffffffc0201a50:	ce99                	beqz	a3,ffffffffc0201a6e <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201a52:	669c                	ld	a5,8(a3)
ffffffffc0201a54:	6a80                	ld	s0,16(a3)
ffffffffc0201a56:	0af50c63          	beq	a0,a5,ffffffffc0201b0e <kfree+0xe2>
    return 0;
ffffffffc0201a5a:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a5c:	c801                	beqz	s0,ffffffffc0201a6c <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201a5e:	6418                	ld	a4,8(s0)
ffffffffc0201a60:	681c                	ld	a5,16(s0)
ffffffffc0201a62:	00970e63          	beq	a4,s1,ffffffffc0201a7e <kfree+0x52>
ffffffffc0201a66:	86a2                	mv	a3,s0
ffffffffc0201a68:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a6a:	f875                	bnez	s0,ffffffffc0201a5e <kfree+0x32>
    if (flag) {
ffffffffc0201a6c:	e649                	bnez	a2,ffffffffc0201af6 <kfree+0xca>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201a6e:	6442                	ld	s0,16(sp)
ffffffffc0201a70:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a72:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201a76:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a78:	4581                	li	a1,0
}
ffffffffc0201a7a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a7c:	b9a1                	j	ffffffffc02016d4 <slob_free>
				*last = bb->next;
ffffffffc0201a7e:	ea9c                	sd	a5,16(a3)
ffffffffc0201a80:	e259                	bnez	a2,ffffffffc0201b06 <kfree+0xda>
    return pa2page(PADDR(kva));
ffffffffc0201a82:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201a86:	4018                	lw	a4,0(s0)
ffffffffc0201a88:	08f4e963          	bltu	s1,a5,ffffffffc0201b1a <kfree+0xee>
ffffffffc0201a8c:	00014797          	auipc	a5,0x14
ffffffffc0201a90:	a6478793          	addi	a5,a5,-1436 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201a94:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201a96:	00014797          	auipc	a5,0x14
ffffffffc0201a9a:	9fa78793          	addi	a5,a5,-1542 # ffffffffc0215490 <npage>
ffffffffc0201a9e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201aa0:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201aa2:	80b1                	srli	s1,s1,0xc
ffffffffc0201aa4:	08f4f863          	bgeu	s1,a5,ffffffffc0201b34 <kfree+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc0201aa8:	00005797          	auipc	a5,0x5
ffffffffc0201aac:	53878793          	addi	a5,a5,1336 # ffffffffc0206fe0 <nbase>
ffffffffc0201ab0:	639c                	ld	a5,0(a5)
ffffffffc0201ab2:	00014697          	auipc	a3,0x14
ffffffffc0201ab6:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0215500 <pages>
ffffffffc0201aba:	6288                	ld	a0,0(a3)
ffffffffc0201abc:	8c9d                	sub	s1,s1,a5
ffffffffc0201abe:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201ac0:	4585                	li	a1,1
ffffffffc0201ac2:	9526                	add	a0,a0,s1
ffffffffc0201ac4:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201ac8:	128000ef          	jal	ra,ffffffffc0201bf0 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201acc:	8522                	mv	a0,s0
}
ffffffffc0201ace:	6442                	ld	s0,16(sp)
ffffffffc0201ad0:	60e2                	ld	ra,24(sp)
ffffffffc0201ad2:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ad4:	45e1                	li	a1,24
}
ffffffffc0201ad6:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ad8:	bef5                	j	ffffffffc02016d4 <slob_free>
        intr_disable();
ffffffffc0201ada:	af7fe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ade:	00014797          	auipc	a5,0x14
ffffffffc0201ae2:	9a278793          	addi	a5,a5,-1630 # ffffffffc0215480 <bigblocks>
ffffffffc0201ae6:	6394                	ld	a3,0(a5)
ffffffffc0201ae8:	c699                	beqz	a3,ffffffffc0201af6 <kfree+0xca>
			if (bb->pages == block) {
ffffffffc0201aea:	669c                	ld	a5,8(a3)
ffffffffc0201aec:	6a80                	ld	s0,16(a3)
ffffffffc0201aee:	00f48763          	beq	s1,a5,ffffffffc0201afc <kfree+0xd0>
        return 1;
ffffffffc0201af2:	4605                	li	a2,1
ffffffffc0201af4:	b7a5                	j	ffffffffc0201a5c <kfree+0x30>
        intr_enable();
ffffffffc0201af6:	ad5fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201afa:	bf95                	j	ffffffffc0201a6e <kfree+0x42>
				*last = bb->next;
ffffffffc0201afc:	00014797          	auipc	a5,0x14
ffffffffc0201b00:	9887b223          	sd	s0,-1660(a5) # ffffffffc0215480 <bigblocks>
ffffffffc0201b04:	8436                	mv	s0,a3
ffffffffc0201b06:	ac5fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201b0a:	bfa5                	j	ffffffffc0201a82 <kfree+0x56>
ffffffffc0201b0c:	8082                	ret
ffffffffc0201b0e:	00014797          	auipc	a5,0x14
ffffffffc0201b12:	9687b923          	sd	s0,-1678(a5) # ffffffffc0215480 <bigblocks>
ffffffffc0201b16:	8436                	mv	s0,a3
ffffffffc0201b18:	b7ad                	j	ffffffffc0201a82 <kfree+0x56>
    return pa2page(PADDR(kva));
ffffffffc0201b1a:	86a6                	mv	a3,s1
ffffffffc0201b1c:	00004617          	auipc	a2,0x4
ffffffffc0201b20:	14460613          	addi	a2,a2,324 # ffffffffc0205c60 <default_pmm_manager+0x88>
ffffffffc0201b24:	06e00593          	li	a1,110
ffffffffc0201b28:	00004517          	auipc	a0,0x4
ffffffffc0201b2c:	12850513          	addi	a0,a0,296 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0201b30:	91dfe0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201b34:	00004617          	auipc	a2,0x4
ffffffffc0201b38:	15460613          	addi	a2,a2,340 # ffffffffc0205c88 <default_pmm_manager+0xb0>
ffffffffc0201b3c:	06200593          	li	a1,98
ffffffffc0201b40:	00004517          	auipc	a0,0x4
ffffffffc0201b44:	11050513          	addi	a0,a0,272 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0201b48:	905fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201b4c <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201b4c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201b4e:	00004617          	auipc	a2,0x4
ffffffffc0201b52:	13a60613          	addi	a2,a2,314 # ffffffffc0205c88 <default_pmm_manager+0xb0>
ffffffffc0201b56:	06200593          	li	a1,98
ffffffffc0201b5a:	00004517          	auipc	a0,0x4
ffffffffc0201b5e:	0f650513          	addi	a0,a0,246 # ffffffffc0205c50 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201b62:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201b64:	8e9fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201b68 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201b68:	715d                	addi	sp,sp,-80
ffffffffc0201b6a:	e0a2                	sd	s0,64(sp)
ffffffffc0201b6c:	fc26                	sd	s1,56(sp)
ffffffffc0201b6e:	f84a                	sd	s2,48(sp)
ffffffffc0201b70:	f44e                	sd	s3,40(sp)
ffffffffc0201b72:	f052                	sd	s4,32(sp)
ffffffffc0201b74:	ec56                	sd	s5,24(sp)
ffffffffc0201b76:	e486                	sd	ra,72(sp)
ffffffffc0201b78:	842a                	mv	s0,a0
ffffffffc0201b7a:	00014497          	auipc	s1,0x14
ffffffffc0201b7e:	96e48493          	addi	s1,s1,-1682 # ffffffffc02154e8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201b82:	4985                	li	s3,1
ffffffffc0201b84:	00014a17          	auipc	s4,0x14
ffffffffc0201b88:	91ca0a13          	addi	s4,s4,-1764 # ffffffffc02154a0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201b8c:	0005091b          	sext.w	s2,a0
ffffffffc0201b90:	00014a97          	auipc	s5,0x14
ffffffffc0201b94:	a50a8a93          	addi	s5,s5,-1456 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0201b98:	a00d                	j	ffffffffc0201bba <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201b9a:	609c                	ld	a5,0(s1)
ffffffffc0201b9c:	6f9c                	ld	a5,24(a5)
ffffffffc0201b9e:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ba0:	4601                	li	a2,0
ffffffffc0201ba2:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ba4:	ed0d                	bnez	a0,ffffffffc0201bde <alloc_pages+0x76>
ffffffffc0201ba6:	0289ec63          	bltu	s3,s0,ffffffffc0201bde <alloc_pages+0x76>
ffffffffc0201baa:	000a2783          	lw	a5,0(s4)
ffffffffc0201bae:	2781                	sext.w	a5,a5
ffffffffc0201bb0:	c79d                	beqz	a5,ffffffffc0201bde <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bb2:	000ab503          	ld	a0,0(s5)
ffffffffc0201bb6:	6ce010ef          	jal	ra,ffffffffc0203284 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bba:	100027f3          	csrr	a5,sstatus
ffffffffc0201bbe:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201bc0:	8522                	mv	a0,s0
ffffffffc0201bc2:	dfe1                	beqz	a5,ffffffffc0201b9a <alloc_pages+0x32>
        intr_disable();
ffffffffc0201bc4:	a0dfe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
ffffffffc0201bc8:	609c                	ld	a5,0(s1)
ffffffffc0201bca:	8522                	mv	a0,s0
ffffffffc0201bcc:	6f9c                	ld	a5,24(a5)
ffffffffc0201bce:	9782                	jalr	a5
ffffffffc0201bd0:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bd2:	9f9fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc0201bd6:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bd8:	4601                	li	a2,0
ffffffffc0201bda:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bdc:	d569                	beqz	a0,ffffffffc0201ba6 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201bde:	60a6                	ld	ra,72(sp)
ffffffffc0201be0:	6406                	ld	s0,64(sp)
ffffffffc0201be2:	74e2                	ld	s1,56(sp)
ffffffffc0201be4:	7942                	ld	s2,48(sp)
ffffffffc0201be6:	79a2                	ld	s3,40(sp)
ffffffffc0201be8:	7a02                	ld	s4,32(sp)
ffffffffc0201bea:	6ae2                	ld	s5,24(sp)
ffffffffc0201bec:	6161                	addi	sp,sp,80
ffffffffc0201bee:	8082                	ret

ffffffffc0201bf0 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bf0:	100027f3          	csrr	a5,sstatus
ffffffffc0201bf4:	8b89                	andi	a5,a5,2
ffffffffc0201bf6:	eb89                	bnez	a5,ffffffffc0201c08 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201bf8:	00014797          	auipc	a5,0x14
ffffffffc0201bfc:	8f078793          	addi	a5,a5,-1808 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c00:	639c                	ld	a5,0(a5)
ffffffffc0201c02:	0207b303          	ld	t1,32(a5)
ffffffffc0201c06:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201c08:	1101                	addi	sp,sp,-32
ffffffffc0201c0a:	ec06                	sd	ra,24(sp)
ffffffffc0201c0c:	e822                	sd	s0,16(sp)
ffffffffc0201c0e:	e426                	sd	s1,8(sp)
ffffffffc0201c10:	842a                	mv	s0,a0
ffffffffc0201c12:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201c14:	9bdfe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201c18:	00014797          	auipc	a5,0x14
ffffffffc0201c1c:	8d078793          	addi	a5,a5,-1840 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c20:	639c                	ld	a5,0(a5)
ffffffffc0201c22:	85a6                	mv	a1,s1
ffffffffc0201c24:	8522                	mv	a0,s0
ffffffffc0201c26:	739c                	ld	a5,32(a5)
ffffffffc0201c28:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201c2a:	6442                	ld	s0,16(sp)
ffffffffc0201c2c:	60e2                	ld	ra,24(sp)
ffffffffc0201c2e:	64a2                	ld	s1,8(sp)
ffffffffc0201c30:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c32:	999fe06f          	j	ffffffffc02005ca <intr_enable>

ffffffffc0201c36 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c36:	100027f3          	csrr	a5,sstatus
ffffffffc0201c3a:	8b89                	andi	a5,a5,2
ffffffffc0201c3c:	eb89                	bnez	a5,ffffffffc0201c4e <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c3e:	00014797          	auipc	a5,0x14
ffffffffc0201c42:	8aa78793          	addi	a5,a5,-1878 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c46:	639c                	ld	a5,0(a5)
ffffffffc0201c48:	0287b303          	ld	t1,40(a5)
ffffffffc0201c4c:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201c4e:	1141                	addi	sp,sp,-16
ffffffffc0201c50:	e406                	sd	ra,8(sp)
ffffffffc0201c52:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201c54:	97dfe0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c58:	00014797          	auipc	a5,0x14
ffffffffc0201c5c:	89078793          	addi	a5,a5,-1904 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c60:	639c                	ld	a5,0(a5)
ffffffffc0201c62:	779c                	ld	a5,40(a5)
ffffffffc0201c64:	9782                	jalr	a5
ffffffffc0201c66:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201c68:	963fe0ef          	jal	ra,ffffffffc02005ca <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201c6c:	8522                	mv	a0,s0
ffffffffc0201c6e:	60a2                	ld	ra,8(sp)
ffffffffc0201c70:	6402                	ld	s0,0(sp)
ffffffffc0201c72:	0141                	addi	sp,sp,16
ffffffffc0201c74:	8082                	ret

ffffffffc0201c76 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201c76:	7139                	addi	sp,sp,-64
ffffffffc0201c78:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201c7a:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201c7e:	1ff4f493          	andi	s1,s1,511
ffffffffc0201c82:	048e                	slli	s1,s1,0x3
ffffffffc0201c84:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201c86:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201c88:	f04a                	sd	s2,32(sp)
ffffffffc0201c8a:	ec4e                	sd	s3,24(sp)
ffffffffc0201c8c:	e852                	sd	s4,16(sp)
ffffffffc0201c8e:	fc06                	sd	ra,56(sp)
ffffffffc0201c90:	f822                	sd	s0,48(sp)
ffffffffc0201c92:	e456                	sd	s5,8(sp)
ffffffffc0201c94:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201c96:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201c9a:	892e                	mv	s2,a1
ffffffffc0201c9c:	8a32                	mv	s4,a2
ffffffffc0201c9e:	00013997          	auipc	s3,0x13
ffffffffc0201ca2:	7f298993          	addi	s3,s3,2034 # ffffffffc0215490 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201ca6:	e7bd                	bnez	a5,ffffffffc0201d14 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201ca8:	12060c63          	beqz	a2,ffffffffc0201de0 <get_pte+0x16a>
ffffffffc0201cac:	4505                	li	a0,1
ffffffffc0201cae:	ebbff0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0201cb2:	842a                	mv	s0,a0
ffffffffc0201cb4:	12050663          	beqz	a0,ffffffffc0201de0 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201cb8:	00014b17          	auipc	s6,0x14
ffffffffc0201cbc:	848b0b13          	addi	s6,s6,-1976 # ffffffffc0215500 <pages>
ffffffffc0201cc0:	000b3503          	ld	a0,0(s6)
ffffffffc0201cc4:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201cc8:	00013997          	auipc	s3,0x13
ffffffffc0201ccc:	7c898993          	addi	s3,s3,1992 # ffffffffc0215490 <npage>
ffffffffc0201cd0:	40a40533          	sub	a0,s0,a0
ffffffffc0201cd4:	8519                	srai	a0,a0,0x6
ffffffffc0201cd6:	9556                	add	a0,a0,s5
ffffffffc0201cd8:	0009b703          	ld	a4,0(s3)
ffffffffc0201cdc:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201ce0:	4685                	li	a3,1
ffffffffc0201ce2:	c014                	sw	a3,0(s0)
ffffffffc0201ce4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ce6:	0532                	slli	a0,a0,0xc
ffffffffc0201ce8:	14e7f363          	bgeu	a5,a4,ffffffffc0201e2e <get_pte+0x1b8>
ffffffffc0201cec:	00014797          	auipc	a5,0x14
ffffffffc0201cf0:	80478793          	addi	a5,a5,-2044 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201cf4:	639c                	ld	a5,0(a5)
ffffffffc0201cf6:	6605                	lui	a2,0x1
ffffffffc0201cf8:	4581                	li	a1,0
ffffffffc0201cfa:	953e                	add	a0,a0,a5
ffffffffc0201cfc:	14a030ef          	jal	ra,ffffffffc0204e46 <memset>
    return page - pages + nbase;
ffffffffc0201d00:	000b3683          	ld	a3,0(s6)
ffffffffc0201d04:	40d406b3          	sub	a3,s0,a3
ffffffffc0201d08:	8699                	srai	a3,a3,0x6
ffffffffc0201d0a:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201d0c:	06aa                	slli	a3,a3,0xa
ffffffffc0201d0e:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201d12:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d14:	77fd                	lui	a5,0xfffff
ffffffffc0201d16:	068a                	slli	a3,a3,0x2
ffffffffc0201d18:	0009b703          	ld	a4,0(s3)
ffffffffc0201d1c:	8efd                	and	a3,a3,a5
ffffffffc0201d1e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201d22:	0ce7f163          	bgeu	a5,a4,ffffffffc0201de4 <get_pte+0x16e>
ffffffffc0201d26:	00013a97          	auipc	s5,0x13
ffffffffc0201d2a:	7caa8a93          	addi	s5,s5,1994 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201d2e:	000ab403          	ld	s0,0(s5)
ffffffffc0201d32:	01595793          	srli	a5,s2,0x15
ffffffffc0201d36:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d3a:	96a2                	add	a3,a3,s0
ffffffffc0201d3c:	00379413          	slli	s0,a5,0x3
ffffffffc0201d40:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201d42:	6014                	ld	a3,0(s0)
ffffffffc0201d44:	0016f793          	andi	a5,a3,1
ffffffffc0201d48:	e3ad                	bnez	a5,ffffffffc0201daa <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201d4a:	080a0b63          	beqz	s4,ffffffffc0201de0 <get_pte+0x16a>
ffffffffc0201d4e:	4505                	li	a0,1
ffffffffc0201d50:	e19ff0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0201d54:	84aa                	mv	s1,a0
ffffffffc0201d56:	c549                	beqz	a0,ffffffffc0201de0 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201d58:	00013b17          	auipc	s6,0x13
ffffffffc0201d5c:	7a8b0b13          	addi	s6,s6,1960 # ffffffffc0215500 <pages>
ffffffffc0201d60:	000b3503          	ld	a0,0(s6)
ffffffffc0201d64:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d68:	0009b703          	ld	a4,0(s3)
ffffffffc0201d6c:	40a48533          	sub	a0,s1,a0
ffffffffc0201d70:	8519                	srai	a0,a0,0x6
ffffffffc0201d72:	9552                	add	a0,a0,s4
ffffffffc0201d74:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201d78:	4685                	li	a3,1
ffffffffc0201d7a:	c094                	sw	a3,0(s1)
ffffffffc0201d7c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d7e:	0532                	slli	a0,a0,0xc
ffffffffc0201d80:	08e7fa63          	bgeu	a5,a4,ffffffffc0201e14 <get_pte+0x19e>
ffffffffc0201d84:	000ab783          	ld	a5,0(s5)
ffffffffc0201d88:	6605                	lui	a2,0x1
ffffffffc0201d8a:	4581                	li	a1,0
ffffffffc0201d8c:	953e                	add	a0,a0,a5
ffffffffc0201d8e:	0b8030ef          	jal	ra,ffffffffc0204e46 <memset>
    return page - pages + nbase;
ffffffffc0201d92:	000b3683          	ld	a3,0(s6)
ffffffffc0201d96:	40d486b3          	sub	a3,s1,a3
ffffffffc0201d9a:	8699                	srai	a3,a3,0x6
ffffffffc0201d9c:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201d9e:	06aa                	slli	a3,a3,0xa
ffffffffc0201da0:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201da4:	e014                	sd	a3,0(s0)
ffffffffc0201da6:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201daa:	068a                	slli	a3,a3,0x2
ffffffffc0201dac:	757d                	lui	a0,0xfffff
ffffffffc0201dae:	8ee9                	and	a3,a3,a0
ffffffffc0201db0:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201db4:	04e7f463          	bgeu	a5,a4,ffffffffc0201dfc <get_pte+0x186>
ffffffffc0201db8:	000ab503          	ld	a0,0(s5)
ffffffffc0201dbc:	00c95913          	srli	s2,s2,0xc
ffffffffc0201dc0:	1ff97913          	andi	s2,s2,511
ffffffffc0201dc4:	96aa                	add	a3,a3,a0
ffffffffc0201dc6:	00391513          	slli	a0,s2,0x3
ffffffffc0201dca:	9536                	add	a0,a0,a3
}
ffffffffc0201dcc:	70e2                	ld	ra,56(sp)
ffffffffc0201dce:	7442                	ld	s0,48(sp)
ffffffffc0201dd0:	74a2                	ld	s1,40(sp)
ffffffffc0201dd2:	7902                	ld	s2,32(sp)
ffffffffc0201dd4:	69e2                	ld	s3,24(sp)
ffffffffc0201dd6:	6a42                	ld	s4,16(sp)
ffffffffc0201dd8:	6aa2                	ld	s5,8(sp)
ffffffffc0201dda:	6b02                	ld	s6,0(sp)
ffffffffc0201ddc:	6121                	addi	sp,sp,64
ffffffffc0201dde:	8082                	ret
            return NULL;
ffffffffc0201de0:	4501                	li	a0,0
ffffffffc0201de2:	b7ed                	j	ffffffffc0201dcc <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201de4:	00004617          	auipc	a2,0x4
ffffffffc0201de8:	e4460613          	addi	a2,a2,-444 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0201dec:	0e400593          	li	a1,228
ffffffffc0201df0:	00004517          	auipc	a0,0x4
ffffffffc0201df4:	f2850513          	addi	a0,a0,-216 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0201df8:	e54fe0ef          	jal	ra,ffffffffc020044c <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201dfc:	00004617          	auipc	a2,0x4
ffffffffc0201e00:	e2c60613          	addi	a2,a2,-468 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0201e04:	0ef00593          	li	a1,239
ffffffffc0201e08:	00004517          	auipc	a0,0x4
ffffffffc0201e0c:	f1050513          	addi	a0,a0,-240 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0201e10:	e3cfe0ef          	jal	ra,ffffffffc020044c <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e14:	86aa                	mv	a3,a0
ffffffffc0201e16:	00004617          	auipc	a2,0x4
ffffffffc0201e1a:	e1260613          	addi	a2,a2,-494 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0201e1e:	0ec00593          	li	a1,236
ffffffffc0201e22:	00004517          	auipc	a0,0x4
ffffffffc0201e26:	ef650513          	addi	a0,a0,-266 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0201e2a:	e22fe0ef          	jal	ra,ffffffffc020044c <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e2e:	86aa                	mv	a3,a0
ffffffffc0201e30:	00004617          	auipc	a2,0x4
ffffffffc0201e34:	df860613          	addi	a2,a2,-520 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0201e38:	0e100593          	li	a1,225
ffffffffc0201e3c:	00004517          	auipc	a0,0x4
ffffffffc0201e40:	edc50513          	addi	a0,a0,-292 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0201e44:	e08fe0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0201e48 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e48:	1141                	addi	sp,sp,-16
ffffffffc0201e4a:	e022                	sd	s0,0(sp)
ffffffffc0201e4c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201e4e:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e50:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201e52:	e25ff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201e56:	c011                	beqz	s0,ffffffffc0201e5a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201e58:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201e5a:	c511                	beqz	a0,ffffffffc0201e66 <get_page+0x1e>
ffffffffc0201e5c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201e5e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201e60:	0017f713          	andi	a4,a5,1
ffffffffc0201e64:	e709                	bnez	a4,ffffffffc0201e6e <get_page+0x26>
}
ffffffffc0201e66:	60a2                	ld	ra,8(sp)
ffffffffc0201e68:	6402                	ld	s0,0(sp)
ffffffffc0201e6a:	0141                	addi	sp,sp,16
ffffffffc0201e6c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201e6e:	00013717          	auipc	a4,0x13
ffffffffc0201e72:	62270713          	addi	a4,a4,1570 # ffffffffc0215490 <npage>
ffffffffc0201e76:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e78:	078a                	slli	a5,a5,0x2
ffffffffc0201e7a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e7c:	02e7f063          	bgeu	a5,a4,ffffffffc0201e9c <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e80:	00013717          	auipc	a4,0x13
ffffffffc0201e84:	68070713          	addi	a4,a4,1664 # ffffffffc0215500 <pages>
ffffffffc0201e88:	6308                	ld	a0,0(a4)
ffffffffc0201e8a:	60a2                	ld	ra,8(sp)
ffffffffc0201e8c:	6402                	ld	s0,0(sp)
ffffffffc0201e8e:	fff80737          	lui	a4,0xfff80
ffffffffc0201e92:	97ba                	add	a5,a5,a4
ffffffffc0201e94:	079a                	slli	a5,a5,0x6
ffffffffc0201e96:	953e                	add	a0,a0,a5
ffffffffc0201e98:	0141                	addi	sp,sp,16
ffffffffc0201e9a:	8082                	ret
ffffffffc0201e9c:	cb1ff0ef          	jal	ra,ffffffffc0201b4c <pa2page.part.4>

ffffffffc0201ea0 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201ea0:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ea2:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201ea4:	e426                	sd	s1,8(sp)
ffffffffc0201ea6:	ec06                	sd	ra,24(sp)
ffffffffc0201ea8:	e822                	sd	s0,16(sp)
ffffffffc0201eaa:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201eac:	dcbff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
    if (ptep != NULL) {
ffffffffc0201eb0:	c511                	beqz	a0,ffffffffc0201ebc <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201eb2:	611c                	ld	a5,0(a0)
ffffffffc0201eb4:	842a                	mv	s0,a0
ffffffffc0201eb6:	0017f713          	andi	a4,a5,1
ffffffffc0201eba:	e711                	bnez	a4,ffffffffc0201ec6 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201ebc:	60e2                	ld	ra,24(sp)
ffffffffc0201ebe:	6442                	ld	s0,16(sp)
ffffffffc0201ec0:	64a2                	ld	s1,8(sp)
ffffffffc0201ec2:	6105                	addi	sp,sp,32
ffffffffc0201ec4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201ec6:	00013717          	auipc	a4,0x13
ffffffffc0201eca:	5ca70713          	addi	a4,a4,1482 # ffffffffc0215490 <npage>
ffffffffc0201ece:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ed0:	078a                	slli	a5,a5,0x2
ffffffffc0201ed2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ed4:	02e7fe63          	bgeu	a5,a4,ffffffffc0201f10 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ed8:	00013717          	auipc	a4,0x13
ffffffffc0201edc:	62870713          	addi	a4,a4,1576 # ffffffffc0215500 <pages>
ffffffffc0201ee0:	6308                	ld	a0,0(a4)
ffffffffc0201ee2:	fff80737          	lui	a4,0xfff80
ffffffffc0201ee6:	97ba                	add	a5,a5,a4
ffffffffc0201ee8:	079a                	slli	a5,a5,0x6
ffffffffc0201eea:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201eec:	411c                	lw	a5,0(a0)
ffffffffc0201eee:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201ef2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201ef4:	cb11                	beqz	a4,ffffffffc0201f08 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201ef6:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201efa:	12048073          	sfence.vma	s1
}
ffffffffc0201efe:	60e2                	ld	ra,24(sp)
ffffffffc0201f00:	6442                	ld	s0,16(sp)
ffffffffc0201f02:	64a2                	ld	s1,8(sp)
ffffffffc0201f04:	6105                	addi	sp,sp,32
ffffffffc0201f06:	8082                	ret
            free_page(page);
ffffffffc0201f08:	4585                	li	a1,1
ffffffffc0201f0a:	ce7ff0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
ffffffffc0201f0e:	b7e5                	j	ffffffffc0201ef6 <page_remove+0x56>
ffffffffc0201f10:	c3dff0ef          	jal	ra,ffffffffc0201b4c <pa2page.part.4>

ffffffffc0201f14 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f14:	7179                	addi	sp,sp,-48
ffffffffc0201f16:	e44e                	sd	s3,8(sp)
ffffffffc0201f18:	89b2                	mv	s3,a2
ffffffffc0201f1a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f1c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f1e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f20:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f22:	ec26                	sd	s1,24(sp)
ffffffffc0201f24:	f406                	sd	ra,40(sp)
ffffffffc0201f26:	e84a                	sd	s2,16(sp)
ffffffffc0201f28:	e052                	sd	s4,0(sp)
ffffffffc0201f2a:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f2c:	d4bff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
    if (ptep == NULL) {
ffffffffc0201f30:	cd49                	beqz	a0,ffffffffc0201fca <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201f32:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201f34:	611c                	ld	a5,0(a0)
ffffffffc0201f36:	892a                	mv	s2,a0
ffffffffc0201f38:	0016871b          	addiw	a4,a3,1
ffffffffc0201f3c:	c018                	sw	a4,0(s0)
ffffffffc0201f3e:	0017f713          	andi	a4,a5,1
ffffffffc0201f42:	ef05                	bnez	a4,ffffffffc0201f7a <page_insert+0x66>
ffffffffc0201f44:	00013797          	auipc	a5,0x13
ffffffffc0201f48:	5bc78793          	addi	a5,a5,1468 # ffffffffc0215500 <pages>
ffffffffc0201f4c:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0201f4e:	8c19                	sub	s0,s0,a4
ffffffffc0201f50:	000806b7          	lui	a3,0x80
ffffffffc0201f54:	8419                	srai	s0,s0,0x6
ffffffffc0201f56:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f58:	042a                	slli	s0,s0,0xa
ffffffffc0201f5a:	8c45                	or	s0,s0,s1
ffffffffc0201f5c:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201f60:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f64:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201f68:	4501                	li	a0,0
}
ffffffffc0201f6a:	70a2                	ld	ra,40(sp)
ffffffffc0201f6c:	7402                	ld	s0,32(sp)
ffffffffc0201f6e:	64e2                	ld	s1,24(sp)
ffffffffc0201f70:	6942                	ld	s2,16(sp)
ffffffffc0201f72:	69a2                	ld	s3,8(sp)
ffffffffc0201f74:	6a02                	ld	s4,0(sp)
ffffffffc0201f76:	6145                	addi	sp,sp,48
ffffffffc0201f78:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f7a:	00013717          	auipc	a4,0x13
ffffffffc0201f7e:	51670713          	addi	a4,a4,1302 # ffffffffc0215490 <npage>
ffffffffc0201f82:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f84:	078a                	slli	a5,a5,0x2
ffffffffc0201f86:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f88:	04e7f363          	bgeu	a5,a4,ffffffffc0201fce <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f8c:	00013a17          	auipc	s4,0x13
ffffffffc0201f90:	574a0a13          	addi	s4,s4,1396 # ffffffffc0215500 <pages>
ffffffffc0201f94:	000a3703          	ld	a4,0(s4)
ffffffffc0201f98:	fff80537          	lui	a0,0xfff80
ffffffffc0201f9c:	953e                	add	a0,a0,a5
ffffffffc0201f9e:	051a                	slli	a0,a0,0x6
ffffffffc0201fa0:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201fa2:	00a40a63          	beq	s0,a0,ffffffffc0201fb6 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201fa6:	411c                	lw	a5,0(a0)
ffffffffc0201fa8:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201fac:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0201fae:	c691                	beqz	a3,ffffffffc0201fba <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fb0:	12098073          	sfence.vma	s3
ffffffffc0201fb4:	bf69                	j	ffffffffc0201f4e <page_insert+0x3a>
ffffffffc0201fb6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201fb8:	bf59                	j	ffffffffc0201f4e <page_insert+0x3a>
            free_page(page);
ffffffffc0201fba:	4585                	li	a1,1
ffffffffc0201fbc:	c35ff0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
ffffffffc0201fc0:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fc4:	12098073          	sfence.vma	s3
ffffffffc0201fc8:	b759                	j	ffffffffc0201f4e <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201fca:	5571                	li	a0,-4
ffffffffc0201fcc:	bf79                	j	ffffffffc0201f6a <page_insert+0x56>
ffffffffc0201fce:	b7fff0ef          	jal	ra,ffffffffc0201b4c <pa2page.part.4>

ffffffffc0201fd2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201fd2:	00004797          	auipc	a5,0x4
ffffffffc0201fd6:	c0678793          	addi	a5,a5,-1018 # ffffffffc0205bd8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201fda:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201fdc:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201fde:	00004517          	auipc	a0,0x4
ffffffffc0201fe2:	d6250513          	addi	a0,a0,-670 # ffffffffc0205d40 <default_pmm_manager+0x168>
void pmm_init(void) {
ffffffffc0201fe6:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201fe8:	00013717          	auipc	a4,0x13
ffffffffc0201fec:	50f73023          	sd	a5,1280(a4) # ffffffffc02154e8 <pmm_manager>
void pmm_init(void) {
ffffffffc0201ff0:	e0a2                	sd	s0,64(sp)
ffffffffc0201ff2:	fc26                	sd	s1,56(sp)
ffffffffc0201ff4:	f84a                	sd	s2,48(sp)
ffffffffc0201ff6:	f44e                	sd	s3,40(sp)
ffffffffc0201ff8:	f052                	sd	s4,32(sp)
ffffffffc0201ffa:	ec56                	sd	s5,24(sp)
ffffffffc0201ffc:	e85a                	sd	s6,16(sp)
ffffffffc0201ffe:	e45e                	sd	s7,8(sp)
ffffffffc0202000:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202002:	00013417          	auipc	s0,0x13
ffffffffc0202006:	4e640413          	addi	s0,s0,1254 # ffffffffc02154e8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020200a:	984fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc020200e:	601c                	ld	a5,0(s0)
ffffffffc0202010:	00013497          	auipc	s1,0x13
ffffffffc0202014:	48048493          	addi	s1,s1,1152 # ffffffffc0215490 <npage>
ffffffffc0202018:	00013917          	auipc	s2,0x13
ffffffffc020201c:	4e890913          	addi	s2,s2,1256 # ffffffffc0215500 <pages>
ffffffffc0202020:	679c                	ld	a5,8(a5)
ffffffffc0202022:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202024:	57f5                	li	a5,-3
ffffffffc0202026:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202028:	00004517          	auipc	a0,0x4
ffffffffc020202c:	d3050513          	addi	a0,a0,-720 # ffffffffc0205d58 <default_pmm_manager+0x180>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202030:	00013717          	auipc	a4,0x13
ffffffffc0202034:	4cf73023          	sd	a5,1216(a4) # ffffffffc02154f0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0202038:	956fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020203c:	46c5                	li	a3,17
ffffffffc020203e:	06ee                	slli	a3,a3,0x1b
ffffffffc0202040:	40100613          	li	a2,1025
ffffffffc0202044:	16fd                	addi	a3,a3,-1
ffffffffc0202046:	0656                	slli	a2,a2,0x15
ffffffffc0202048:	07e005b7          	lui	a1,0x7e00
ffffffffc020204c:	00004517          	auipc	a0,0x4
ffffffffc0202050:	d2450513          	addi	a0,a0,-732 # ffffffffc0205d70 <default_pmm_manager+0x198>
ffffffffc0202054:	93afe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202058:	777d                	lui	a4,0xfffff
ffffffffc020205a:	00014797          	auipc	a5,0x14
ffffffffc020205e:	59d78793          	addi	a5,a5,1437 # ffffffffc02165f7 <end+0xfff>
ffffffffc0202062:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202064:	00088737          	lui	a4,0x88
ffffffffc0202068:	00013697          	auipc	a3,0x13
ffffffffc020206c:	42e6b423          	sd	a4,1064(a3) # ffffffffc0215490 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202070:	00013717          	auipc	a4,0x13
ffffffffc0202074:	48f73823          	sd	a5,1168(a4) # ffffffffc0215500 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202078:	4701                	li	a4,0
ffffffffc020207a:	4685                	li	a3,1
ffffffffc020207c:	fff80837          	lui	a6,0xfff80
ffffffffc0202080:	a019                	j	ffffffffc0202086 <pmm_init+0xb4>
ffffffffc0202082:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0202086:	00671613          	slli	a2,a4,0x6
ffffffffc020208a:	97b2                	add	a5,a5,a2
ffffffffc020208c:	07a1                	addi	a5,a5,8
ffffffffc020208e:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202092:	6090                	ld	a2,0(s1)
ffffffffc0202094:	0705                	addi	a4,a4,1
ffffffffc0202096:	010607b3          	add	a5,a2,a6
ffffffffc020209a:	fef764e3          	bltu	a4,a5,ffffffffc0202082 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020209e:	00093503          	ld	a0,0(s2)
ffffffffc02020a2:	fe0007b7          	lui	a5,0xfe000
ffffffffc02020a6:	00661693          	slli	a3,a2,0x6
ffffffffc02020aa:	97aa                	add	a5,a5,a0
ffffffffc02020ac:	96be                	add	a3,a3,a5
ffffffffc02020ae:	c02007b7          	lui	a5,0xc0200
ffffffffc02020b2:	7af6eb63          	bltu	a3,a5,ffffffffc0202868 <pmm_init+0x896>
ffffffffc02020b6:	00013997          	auipc	s3,0x13
ffffffffc02020ba:	43a98993          	addi	s3,s3,1082 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02020be:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02020c2:	47c5                	li	a5,17
ffffffffc02020c4:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02020c6:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02020c8:	02f6f763          	bgeu	a3,a5,ffffffffc02020f6 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020cc:	6585                	lui	a1,0x1
ffffffffc02020ce:	15fd                	addi	a1,a1,-1
ffffffffc02020d0:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02020d2:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020d6:	48c77863          	bgeu	a4,a2,ffffffffc0202566 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc02020da:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020dc:	75fd                	lui	a1,0xfffff
ffffffffc02020de:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc02020e0:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc02020e2:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020e4:	40d786b3          	sub	a3,a5,a3
ffffffffc02020e8:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02020ea:	00c6d593          	srli	a1,a3,0xc
ffffffffc02020ee:	953a                	add	a0,a0,a4
ffffffffc02020f0:	9602                	jalr	a2
ffffffffc02020f2:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02020f6:	00004517          	auipc	a0,0x4
ffffffffc02020fa:	ca250513          	addi	a0,a0,-862 # ffffffffc0205d98 <default_pmm_manager+0x1c0>
ffffffffc02020fe:	890fe0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202102:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202104:	00013417          	auipc	s0,0x13
ffffffffc0202108:	38440413          	addi	s0,s0,900 # ffffffffc0215488 <boot_pgdir>
    pmm_manager->check();
ffffffffc020210c:	7b9c                	ld	a5,48(a5)
ffffffffc020210e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202110:	00004517          	auipc	a0,0x4
ffffffffc0202114:	ca050513          	addi	a0,a0,-864 # ffffffffc0205db0 <default_pmm_manager+0x1d8>
ffffffffc0202118:	876fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020211c:	00007697          	auipc	a3,0x7
ffffffffc0202120:	ee468693          	addi	a3,a3,-284 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0202124:	00013797          	auipc	a5,0x13
ffffffffc0202128:	36d7b223          	sd	a3,868(a5) # ffffffffc0215488 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020212c:	c02007b7          	lui	a5,0xc0200
ffffffffc0202130:	10f6e8e3          	bltu	a3,a5,ffffffffc0202a40 <pmm_init+0xa6e>
ffffffffc0202134:	0009b783          	ld	a5,0(s3)
ffffffffc0202138:	8e9d                	sub	a3,a3,a5
ffffffffc020213a:	00013797          	auipc	a5,0x13
ffffffffc020213e:	3ad7bf23          	sd	a3,958(a5) # ffffffffc02154f8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202142:	af5ff0ef          	jal	ra,ffffffffc0201c36 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202146:	6098                	ld	a4,0(s1)
ffffffffc0202148:	c80007b7          	lui	a5,0xc8000
ffffffffc020214c:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020214e:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202150:	0ce7e8e3          	bltu	a5,a4,ffffffffc0202a20 <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202154:	6008                	ld	a0,0(s0)
ffffffffc0202156:	44050263          	beqz	a0,ffffffffc020259a <pmm_init+0x5c8>
ffffffffc020215a:	03451793          	slli	a5,a0,0x34
ffffffffc020215e:	42079e63          	bnez	a5,ffffffffc020259a <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202162:	4601                	li	a2,0
ffffffffc0202164:	4581                	li	a1,0
ffffffffc0202166:	ce3ff0ef          	jal	ra,ffffffffc0201e48 <get_page>
ffffffffc020216a:	78051b63          	bnez	a0,ffffffffc0202900 <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020216e:	4505                	li	a0,1
ffffffffc0202170:	9f9ff0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0202174:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202176:	6008                	ld	a0,0(s0)
ffffffffc0202178:	4681                	li	a3,0
ffffffffc020217a:	4601                	li	a2,0
ffffffffc020217c:	85d6                	mv	a1,s5
ffffffffc020217e:	d97ff0ef          	jal	ra,ffffffffc0201f14 <page_insert>
ffffffffc0202182:	7a051f63          	bnez	a0,ffffffffc0202940 <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202186:	6008                	ld	a0,0(s0)
ffffffffc0202188:	4601                	li	a2,0
ffffffffc020218a:	4581                	li	a1,0
ffffffffc020218c:	aebff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
ffffffffc0202190:	78050863          	beqz	a0,ffffffffc0202920 <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc0202194:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202196:	0017f713          	andi	a4,a5,1
ffffffffc020219a:	3e070463          	beqz	a4,ffffffffc0202582 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc020219e:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021a0:	078a                	slli	a5,a5,0x2
ffffffffc02021a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021a4:	3ce7f163          	bgeu	a5,a4,ffffffffc0202566 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02021a8:	00093683          	ld	a3,0(s2)
ffffffffc02021ac:	fff80637          	lui	a2,0xfff80
ffffffffc02021b0:	97b2                	add	a5,a5,a2
ffffffffc02021b2:	079a                	slli	a5,a5,0x6
ffffffffc02021b4:	97b6                	add	a5,a5,a3
ffffffffc02021b6:	72fa9563          	bne	s5,a5,ffffffffc02028e0 <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc02021ba:	000aab83          	lw	s7,0(s5)
ffffffffc02021be:	4785                	li	a5,1
ffffffffc02021c0:	70fb9063          	bne	s7,a5,ffffffffc02028c0 <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02021c4:	6008                	ld	a0,0(s0)
ffffffffc02021c6:	76fd                	lui	a3,0xfffff
ffffffffc02021c8:	611c                	ld	a5,0(a0)
ffffffffc02021ca:	078a                	slli	a5,a5,0x2
ffffffffc02021cc:	8ff5                	and	a5,a5,a3
ffffffffc02021ce:	00c7d613          	srli	a2,a5,0xc
ffffffffc02021d2:	66e67e63          	bgeu	a2,a4,ffffffffc020284e <pmm_init+0x87c>
ffffffffc02021d6:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02021da:	97e2                	add	a5,a5,s8
ffffffffc02021dc:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7deaa08>
ffffffffc02021e0:	0b0a                	slli	s6,s6,0x2
ffffffffc02021e2:	00db7b33          	and	s6,s6,a3
ffffffffc02021e6:	00cb5793          	srli	a5,s6,0xc
ffffffffc02021ea:	56e7f863          	bgeu	a5,a4,ffffffffc020275a <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02021ee:	4601                	li	a2,0
ffffffffc02021f0:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02021f2:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02021f4:	a83ff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02021f8:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02021fa:	55651063          	bne	a0,s6,ffffffffc020273a <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc02021fe:	4505                	li	a0,1
ffffffffc0202200:	969ff0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0202204:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202206:	6008                	ld	a0,0(s0)
ffffffffc0202208:	46d1                	li	a3,20
ffffffffc020220a:	6605                	lui	a2,0x1
ffffffffc020220c:	85da                	mv	a1,s6
ffffffffc020220e:	d07ff0ef          	jal	ra,ffffffffc0201f14 <page_insert>
ffffffffc0202212:	50051463          	bnez	a0,ffffffffc020271a <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202216:	6008                	ld	a0,0(s0)
ffffffffc0202218:	4601                	li	a2,0
ffffffffc020221a:	6585                	lui	a1,0x1
ffffffffc020221c:	a5bff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
ffffffffc0202220:	4c050d63          	beqz	a0,ffffffffc02026fa <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc0202224:	611c                	ld	a5,0(a0)
ffffffffc0202226:	0107f713          	andi	a4,a5,16
ffffffffc020222a:	4a070863          	beqz	a4,ffffffffc02026da <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc020222e:	8b91                	andi	a5,a5,4
ffffffffc0202230:	48078563          	beqz	a5,ffffffffc02026ba <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202234:	6008                	ld	a0,0(s0)
ffffffffc0202236:	611c                	ld	a5,0(a0)
ffffffffc0202238:	8bc1                	andi	a5,a5,16
ffffffffc020223a:	46078063          	beqz	a5,ffffffffc020269a <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc020223e:	000b2783          	lw	a5,0(s6)
ffffffffc0202242:	43779c63          	bne	a5,s7,ffffffffc020267a <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202246:	4681                	li	a3,0
ffffffffc0202248:	6605                	lui	a2,0x1
ffffffffc020224a:	85d6                	mv	a1,s5
ffffffffc020224c:	cc9ff0ef          	jal	ra,ffffffffc0201f14 <page_insert>
ffffffffc0202250:	40051563          	bnez	a0,ffffffffc020265a <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc0202254:	000aa703          	lw	a4,0(s5)
ffffffffc0202258:	4789                	li	a5,2
ffffffffc020225a:	3ef71063          	bne	a4,a5,ffffffffc020263a <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc020225e:	000b2783          	lw	a5,0(s6)
ffffffffc0202262:	3a079c63          	bnez	a5,ffffffffc020261a <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202266:	6008                	ld	a0,0(s0)
ffffffffc0202268:	4601                	li	a2,0
ffffffffc020226a:	6585                	lui	a1,0x1
ffffffffc020226c:	a0bff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
ffffffffc0202270:	38050563          	beqz	a0,ffffffffc02025fa <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc0202274:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202276:	00177793          	andi	a5,a4,1
ffffffffc020227a:	30078463          	beqz	a5,ffffffffc0202582 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc020227e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202280:	00271793          	slli	a5,a4,0x2
ffffffffc0202284:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202286:	2ed7f063          	bgeu	a5,a3,ffffffffc0202566 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020228a:	00093683          	ld	a3,0(s2)
ffffffffc020228e:	fff80637          	lui	a2,0xfff80
ffffffffc0202292:	97b2                	add	a5,a5,a2
ffffffffc0202294:	079a                	slli	a5,a5,0x6
ffffffffc0202296:	97b6                	add	a5,a5,a3
ffffffffc0202298:	32fa9163          	bne	s5,a5,ffffffffc02025ba <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc020229c:	8b41                	andi	a4,a4,16
ffffffffc020229e:	70071163          	bnez	a4,ffffffffc02029a0 <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02022a2:	6008                	ld	a0,0(s0)
ffffffffc02022a4:	4581                	li	a1,0
ffffffffc02022a6:	bfbff0ef          	jal	ra,ffffffffc0201ea0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02022aa:	000aa703          	lw	a4,0(s5)
ffffffffc02022ae:	4785                	li	a5,1
ffffffffc02022b0:	6cf71863          	bne	a4,a5,ffffffffc0202980 <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc02022b4:	000b2783          	lw	a5,0(s6)
ffffffffc02022b8:	6a079463          	bnez	a5,ffffffffc0202960 <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02022bc:	6008                	ld	a0,0(s0)
ffffffffc02022be:	6585                	lui	a1,0x1
ffffffffc02022c0:	be1ff0ef          	jal	ra,ffffffffc0201ea0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02022c4:	000aa783          	lw	a5,0(s5)
ffffffffc02022c8:	50079363          	bnez	a5,ffffffffc02027ce <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc02022cc:	000b2783          	lw	a5,0(s6)
ffffffffc02022d0:	4c079f63          	bnez	a5,ffffffffc02027ae <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02022d4:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02022d8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02022da:	000b3783          	ld	a5,0(s6)
ffffffffc02022de:	078a                	slli	a5,a5,0x2
ffffffffc02022e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022e2:	28e7f263          	bgeu	a5,a4,ffffffffc0202566 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02022e6:	fff806b7          	lui	a3,0xfff80
ffffffffc02022ea:	00093503          	ld	a0,0(s2)
ffffffffc02022ee:	97b6                	add	a5,a5,a3
ffffffffc02022f0:	079a                	slli	a5,a5,0x6
ffffffffc02022f2:	00f506b3          	add	a3,a0,a5
ffffffffc02022f6:	4290                	lw	a2,0(a3)
ffffffffc02022f8:	4685                	li	a3,1
ffffffffc02022fa:	48d61a63          	bne	a2,a3,ffffffffc020278e <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc02022fe:	8799                	srai	a5,a5,0x6
ffffffffc0202300:	00080ab7          	lui	s5,0x80
ffffffffc0202304:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0202306:	00c79693          	slli	a3,a5,0xc
ffffffffc020230a:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020230c:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020230e:	46e6f363          	bgeu	a3,a4,ffffffffc0202774 <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202312:	0009b683          	ld	a3,0(s3)
ffffffffc0202316:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202318:	639c                	ld	a5,0(a5)
ffffffffc020231a:	078a                	slli	a5,a5,0x2
ffffffffc020231c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020231e:	24e7f463          	bgeu	a5,a4,ffffffffc0202566 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202322:	415787b3          	sub	a5,a5,s5
ffffffffc0202326:	079a                	slli	a5,a5,0x6
ffffffffc0202328:	953e                	add	a0,a0,a5
ffffffffc020232a:	4585                	li	a1,1
ffffffffc020232c:	8c5ff0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202330:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202334:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202336:	078a                	slli	a5,a5,0x2
ffffffffc0202338:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020233a:	22e7f663          	bgeu	a5,a4,ffffffffc0202566 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020233e:	00093503          	ld	a0,0(s2)
ffffffffc0202342:	415787b3          	sub	a5,a5,s5
ffffffffc0202346:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202348:	953e                	add	a0,a0,a5
ffffffffc020234a:	4585                	li	a1,1
ffffffffc020234c:	8a5ff0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202350:	601c                	ld	a5,0(s0)
ffffffffc0202352:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202356:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020235a:	8ddff0ef          	jal	ra,ffffffffc0201c36 <nr_free_pages>
ffffffffc020235e:	68aa1163          	bne	s4,a0,ffffffffc02029e0 <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202362:	00004517          	auipc	a0,0x4
ffffffffc0202366:	d5e50513          	addi	a0,a0,-674 # ffffffffc02060c0 <default_pmm_manager+0x4e8>
ffffffffc020236a:	e25fd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc020236e:	8c9ff0ef          	jal	ra,ffffffffc0201c36 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202372:	6098                	ld	a4,0(s1)
ffffffffc0202374:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0202378:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020237a:	00c71693          	slli	a3,a4,0xc
ffffffffc020237e:	18d7f563          	bgeu	a5,a3,ffffffffc0202508 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202382:	83b1                	srli	a5,a5,0xc
ffffffffc0202384:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202386:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020238a:	1ae7f163          	bgeu	a5,a4,ffffffffc020252c <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020238e:	7bfd                	lui	s7,0xfffff
ffffffffc0202390:	6b05                	lui	s6,0x1
ffffffffc0202392:	a029                	j	ffffffffc020239c <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202394:	00cad713          	srli	a4,s5,0xc
ffffffffc0202398:	18f77a63          	bgeu	a4,a5,ffffffffc020252c <pmm_init+0x55a>
ffffffffc020239c:	0009b583          	ld	a1,0(s3)
ffffffffc02023a0:	4601                	li	a2,0
ffffffffc02023a2:	95d6                	add	a1,a1,s5
ffffffffc02023a4:	8d3ff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
ffffffffc02023a8:	16050263          	beqz	a0,ffffffffc020250c <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023ac:	611c                	ld	a5,0(a0)
ffffffffc02023ae:	078a                	slli	a5,a5,0x2
ffffffffc02023b0:	0177f7b3          	and	a5,a5,s7
ffffffffc02023b4:	19579963          	bne	a5,s5,ffffffffc0202546 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023b8:	609c                	ld	a5,0(s1)
ffffffffc02023ba:	9ada                	add	s5,s5,s6
ffffffffc02023bc:	6008                	ld	a0,0(s0)
ffffffffc02023be:	00c79713          	slli	a4,a5,0xc
ffffffffc02023c2:	fceae9e3          	bltu	s5,a4,ffffffffc0202394 <pmm_init+0x3c2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02023c6:	611c                	ld	a5,0(a0)
ffffffffc02023c8:	62079c63          	bnez	a5,ffffffffc0202a00 <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc02023cc:	4505                	li	a0,1
ffffffffc02023ce:	f9aff0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc02023d2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02023d4:	6008                	ld	a0,0(s0)
ffffffffc02023d6:	4699                	li	a3,6
ffffffffc02023d8:	10000613          	li	a2,256
ffffffffc02023dc:	85d6                	mv	a1,s5
ffffffffc02023de:	b37ff0ef          	jal	ra,ffffffffc0201f14 <page_insert>
ffffffffc02023e2:	1e051c63          	bnez	a0,ffffffffc02025da <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc02023e6:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc02023ea:	4785                	li	a5,1
ffffffffc02023ec:	44f71163          	bne	a4,a5,ffffffffc020282e <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02023f0:	6008                	ld	a0,0(s0)
ffffffffc02023f2:	6b05                	lui	s6,0x1
ffffffffc02023f4:	4699                	li	a3,6
ffffffffc02023f6:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc02023fa:	85d6                	mv	a1,s5
ffffffffc02023fc:	b19ff0ef          	jal	ra,ffffffffc0201f14 <page_insert>
ffffffffc0202400:	40051763          	bnez	a0,ffffffffc020280e <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0202404:	000aa703          	lw	a4,0(s5)
ffffffffc0202408:	4789                	li	a5,2
ffffffffc020240a:	3ef71263          	bne	a4,a5,ffffffffc02027ee <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020240e:	00004597          	auipc	a1,0x4
ffffffffc0202412:	dea58593          	addi	a1,a1,-534 # ffffffffc02061f8 <default_pmm_manager+0x620>
ffffffffc0202416:	10000513          	li	a0,256
ffffffffc020241a:	1d3020ef          	jal	ra,ffffffffc0204dec <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020241e:	100b0593          	addi	a1,s6,256
ffffffffc0202422:	10000513          	li	a0,256
ffffffffc0202426:	1d9020ef          	jal	ra,ffffffffc0204dfe <strcmp>
ffffffffc020242a:	44051b63          	bnez	a0,ffffffffc0202880 <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc020242e:	00093683          	ld	a3,0(s2)
ffffffffc0202432:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202436:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202438:	40da86b3          	sub	a3,s5,a3
ffffffffc020243c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020243e:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202440:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202442:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202446:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc020244a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020244c:	10f77f63          	bgeu	a4,a5,ffffffffc020256a <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202450:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202454:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202458:	96be                	add	a3,a3,a5
ffffffffc020245a:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6ab08>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020245e:	14b020ef          	jal	ra,ffffffffc0204da8 <strlen>
ffffffffc0202462:	54051f63          	bnez	a0,ffffffffc02029c0 <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202466:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020246a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020246c:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a08>
ffffffffc0202470:	068a                	slli	a3,a3,0x2
ffffffffc0202472:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202474:	0ef6f963          	bgeu	a3,a5,ffffffffc0202566 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0202478:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc020247c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020247e:	0efb7663          	bgeu	s6,a5,ffffffffc020256a <pmm_init+0x598>
ffffffffc0202482:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202486:	4585                	li	a1,1
ffffffffc0202488:	8556                	mv	a0,s5
ffffffffc020248a:	99b6                	add	s3,s3,a3
ffffffffc020248c:	f64ff0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202490:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202494:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202496:	078a                	slli	a5,a5,0x2
ffffffffc0202498:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020249a:	0ce7f663          	bgeu	a5,a4,ffffffffc0202566 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020249e:	00093503          	ld	a0,0(s2)
ffffffffc02024a2:	fff809b7          	lui	s3,0xfff80
ffffffffc02024a6:	97ce                	add	a5,a5,s3
ffffffffc02024a8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02024aa:	953e                	add	a0,a0,a5
ffffffffc02024ac:	4585                	li	a1,1
ffffffffc02024ae:	f42ff0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024b2:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02024b6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024b8:	078a                	slli	a5,a5,0x2
ffffffffc02024ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024bc:	0ae7f563          	bgeu	a5,a4,ffffffffc0202566 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02024c0:	00093503          	ld	a0,0(s2)
ffffffffc02024c4:	97ce                	add	a5,a5,s3
ffffffffc02024c6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02024c8:	953e                	add	a0,a0,a5
ffffffffc02024ca:	4585                	li	a1,1
ffffffffc02024cc:	f24ff0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02024d0:	601c                	ld	a5,0(s0)
ffffffffc02024d2:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc02024d6:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02024da:	f5cff0ef          	jal	ra,ffffffffc0201c36 <nr_free_pages>
ffffffffc02024de:	3caa1163          	bne	s4,a0,ffffffffc02028a0 <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02024e2:	00004517          	auipc	a0,0x4
ffffffffc02024e6:	d8e50513          	addi	a0,a0,-626 # ffffffffc0206270 <default_pmm_manager+0x698>
ffffffffc02024ea:	ca5fd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc02024ee:	6406                	ld	s0,64(sp)
ffffffffc02024f0:	60a6                	ld	ra,72(sp)
ffffffffc02024f2:	74e2                	ld	s1,56(sp)
ffffffffc02024f4:	7942                	ld	s2,48(sp)
ffffffffc02024f6:	79a2                	ld	s3,40(sp)
ffffffffc02024f8:	7a02                	ld	s4,32(sp)
ffffffffc02024fa:	6ae2                	ld	s5,24(sp)
ffffffffc02024fc:	6b42                	ld	s6,16(sp)
ffffffffc02024fe:	6ba2                	ld	s7,8(sp)
ffffffffc0202500:	6c02                	ld	s8,0(sp)
ffffffffc0202502:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202504:	c4cff06f          	j	ffffffffc0201950 <kmalloc_init>
ffffffffc0202508:	6008                	ld	a0,0(s0)
ffffffffc020250a:	bd75                	j	ffffffffc02023c6 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020250c:	00004697          	auipc	a3,0x4
ffffffffc0202510:	bd468693          	addi	a3,a3,-1068 # ffffffffc02060e0 <default_pmm_manager+0x508>
ffffffffc0202514:	00003617          	auipc	a2,0x3
ffffffffc0202518:	32c60613          	addi	a2,a2,812 # ffffffffc0205840 <commands+0x870>
ffffffffc020251c:	19d00593          	li	a1,413
ffffffffc0202520:	00003517          	auipc	a0,0x3
ffffffffc0202524:	7f850513          	addi	a0,a0,2040 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202528:	f25fd0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc020252c:	86d6                	mv	a3,s5
ffffffffc020252e:	00003617          	auipc	a2,0x3
ffffffffc0202532:	6fa60613          	addi	a2,a2,1786 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0202536:	19d00593          	li	a1,413
ffffffffc020253a:	00003517          	auipc	a0,0x3
ffffffffc020253e:	7de50513          	addi	a0,a0,2014 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202542:	f0bfd0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202546:	00004697          	auipc	a3,0x4
ffffffffc020254a:	bda68693          	addi	a3,a3,-1062 # ffffffffc0206120 <default_pmm_manager+0x548>
ffffffffc020254e:	00003617          	auipc	a2,0x3
ffffffffc0202552:	2f260613          	addi	a2,a2,754 # ffffffffc0205840 <commands+0x870>
ffffffffc0202556:	19e00593          	li	a1,414
ffffffffc020255a:	00003517          	auipc	a0,0x3
ffffffffc020255e:	7be50513          	addi	a0,a0,1982 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202562:	eebfd0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc0202566:	de6ff0ef          	jal	ra,ffffffffc0201b4c <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	6be60613          	addi	a2,a2,1726 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0202572:	06900593          	li	a1,105
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	6da50513          	addi	a0,a0,1754 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc020257e:	ecffd0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202582:	00004617          	auipc	a2,0x4
ffffffffc0202586:	92e60613          	addi	a2,a2,-1746 # ffffffffc0205eb0 <default_pmm_manager+0x2d8>
ffffffffc020258a:	07400593          	li	a1,116
ffffffffc020258e:	00003517          	auipc	a0,0x3
ffffffffc0202592:	6c250513          	addi	a0,a0,1730 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0202596:	eb7fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020259a:	00004697          	auipc	a3,0x4
ffffffffc020259e:	85668693          	addi	a3,a3,-1962 # ffffffffc0205df0 <default_pmm_manager+0x218>
ffffffffc02025a2:	00003617          	auipc	a2,0x3
ffffffffc02025a6:	29e60613          	addi	a2,a2,670 # ffffffffc0205840 <commands+0x870>
ffffffffc02025aa:	16100593          	li	a1,353
ffffffffc02025ae:	00003517          	auipc	a0,0x3
ffffffffc02025b2:	76a50513          	addi	a0,a0,1898 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02025b6:	e97fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025ba:	00004697          	auipc	a3,0x4
ffffffffc02025be:	91e68693          	addi	a3,a3,-1762 # ffffffffc0205ed8 <default_pmm_manager+0x300>
ffffffffc02025c2:	00003617          	auipc	a2,0x3
ffffffffc02025c6:	27e60613          	addi	a2,a2,638 # ffffffffc0205840 <commands+0x870>
ffffffffc02025ca:	17d00593          	li	a1,381
ffffffffc02025ce:	00003517          	auipc	a0,0x3
ffffffffc02025d2:	74a50513          	addi	a0,a0,1866 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02025d6:	e77fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025da:	00004697          	auipc	a3,0x4
ffffffffc02025de:	b7668693          	addi	a3,a3,-1162 # ffffffffc0206150 <default_pmm_manager+0x578>
ffffffffc02025e2:	00003617          	auipc	a2,0x3
ffffffffc02025e6:	25e60613          	addi	a2,a2,606 # ffffffffc0205840 <commands+0x870>
ffffffffc02025ea:	1a500593          	li	a1,421
ffffffffc02025ee:	00003517          	auipc	a0,0x3
ffffffffc02025f2:	72a50513          	addi	a0,a0,1834 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02025f6:	e57fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02025fa:	00004697          	auipc	a3,0x4
ffffffffc02025fe:	96e68693          	addi	a3,a3,-1682 # ffffffffc0205f68 <default_pmm_manager+0x390>
ffffffffc0202602:	00003617          	auipc	a2,0x3
ffffffffc0202606:	23e60613          	addi	a2,a2,574 # ffffffffc0205840 <commands+0x870>
ffffffffc020260a:	17c00593          	li	a1,380
ffffffffc020260e:	00003517          	auipc	a0,0x3
ffffffffc0202612:	70a50513          	addi	a0,a0,1802 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202616:	e37fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020261a:	00004697          	auipc	a3,0x4
ffffffffc020261e:	a1668693          	addi	a3,a3,-1514 # ffffffffc0206030 <default_pmm_manager+0x458>
ffffffffc0202622:	00003617          	auipc	a2,0x3
ffffffffc0202626:	21e60613          	addi	a2,a2,542 # ffffffffc0205840 <commands+0x870>
ffffffffc020262a:	17b00593          	li	a1,379
ffffffffc020262e:	00003517          	auipc	a0,0x3
ffffffffc0202632:	6ea50513          	addi	a0,a0,1770 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202636:	e17fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020263a:	00004697          	auipc	a3,0x4
ffffffffc020263e:	9de68693          	addi	a3,a3,-1570 # ffffffffc0206018 <default_pmm_manager+0x440>
ffffffffc0202642:	00003617          	auipc	a2,0x3
ffffffffc0202646:	1fe60613          	addi	a2,a2,510 # ffffffffc0205840 <commands+0x870>
ffffffffc020264a:	17a00593          	li	a1,378
ffffffffc020264e:	00003517          	auipc	a0,0x3
ffffffffc0202652:	6ca50513          	addi	a0,a0,1738 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202656:	df7fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020265a:	00004697          	auipc	a3,0x4
ffffffffc020265e:	98e68693          	addi	a3,a3,-1650 # ffffffffc0205fe8 <default_pmm_manager+0x410>
ffffffffc0202662:	00003617          	auipc	a2,0x3
ffffffffc0202666:	1de60613          	addi	a2,a2,478 # ffffffffc0205840 <commands+0x870>
ffffffffc020266a:	17900593          	li	a1,377
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	6aa50513          	addi	a0,a0,1706 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202676:	dd7fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020267a:	00004697          	auipc	a3,0x4
ffffffffc020267e:	95668693          	addi	a3,a3,-1706 # ffffffffc0205fd0 <default_pmm_manager+0x3f8>
ffffffffc0202682:	00003617          	auipc	a2,0x3
ffffffffc0202686:	1be60613          	addi	a2,a2,446 # ffffffffc0205840 <commands+0x870>
ffffffffc020268a:	17700593          	li	a1,375
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	68a50513          	addi	a0,a0,1674 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202696:	db7fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020269a:	00004697          	auipc	a3,0x4
ffffffffc020269e:	91e68693          	addi	a3,a3,-1762 # ffffffffc0205fb8 <default_pmm_manager+0x3e0>
ffffffffc02026a2:	00003617          	auipc	a2,0x3
ffffffffc02026a6:	19e60613          	addi	a2,a2,414 # ffffffffc0205840 <commands+0x870>
ffffffffc02026aa:	17600593          	li	a1,374
ffffffffc02026ae:	00003517          	auipc	a0,0x3
ffffffffc02026b2:	66a50513          	addi	a0,a0,1642 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02026b6:	d97fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(*ptep & PTE_W);
ffffffffc02026ba:	00004697          	auipc	a3,0x4
ffffffffc02026be:	8ee68693          	addi	a3,a3,-1810 # ffffffffc0205fa8 <default_pmm_manager+0x3d0>
ffffffffc02026c2:	00003617          	auipc	a2,0x3
ffffffffc02026c6:	17e60613          	addi	a2,a2,382 # ffffffffc0205840 <commands+0x870>
ffffffffc02026ca:	17500593          	li	a1,373
ffffffffc02026ce:	00003517          	auipc	a0,0x3
ffffffffc02026d2:	64a50513          	addi	a0,a0,1610 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02026d6:	d77fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(*ptep & PTE_U);
ffffffffc02026da:	00004697          	auipc	a3,0x4
ffffffffc02026de:	8be68693          	addi	a3,a3,-1858 # ffffffffc0205f98 <default_pmm_manager+0x3c0>
ffffffffc02026e2:	00003617          	auipc	a2,0x3
ffffffffc02026e6:	15e60613          	addi	a2,a2,350 # ffffffffc0205840 <commands+0x870>
ffffffffc02026ea:	17400593          	li	a1,372
ffffffffc02026ee:	00003517          	auipc	a0,0x3
ffffffffc02026f2:	62a50513          	addi	a0,a0,1578 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02026f6:	d57fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02026fa:	00004697          	auipc	a3,0x4
ffffffffc02026fe:	86e68693          	addi	a3,a3,-1938 # ffffffffc0205f68 <default_pmm_manager+0x390>
ffffffffc0202702:	00003617          	auipc	a2,0x3
ffffffffc0202706:	13e60613          	addi	a2,a2,318 # ffffffffc0205840 <commands+0x870>
ffffffffc020270a:	17300593          	li	a1,371
ffffffffc020270e:	00003517          	auipc	a0,0x3
ffffffffc0202712:	60a50513          	addi	a0,a0,1546 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202716:	d37fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020271a:	00004697          	auipc	a3,0x4
ffffffffc020271e:	81668693          	addi	a3,a3,-2026 # ffffffffc0205f30 <default_pmm_manager+0x358>
ffffffffc0202722:	00003617          	auipc	a2,0x3
ffffffffc0202726:	11e60613          	addi	a2,a2,286 # ffffffffc0205840 <commands+0x870>
ffffffffc020272a:	17200593          	li	a1,370
ffffffffc020272e:	00003517          	auipc	a0,0x3
ffffffffc0202732:	5ea50513          	addi	a0,a0,1514 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202736:	d17fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020273a:	00003697          	auipc	a3,0x3
ffffffffc020273e:	7ce68693          	addi	a3,a3,1998 # ffffffffc0205f08 <default_pmm_manager+0x330>
ffffffffc0202742:	00003617          	auipc	a2,0x3
ffffffffc0202746:	0fe60613          	addi	a2,a2,254 # ffffffffc0205840 <commands+0x870>
ffffffffc020274a:	16f00593          	li	a1,367
ffffffffc020274e:	00003517          	auipc	a0,0x3
ffffffffc0202752:	5ca50513          	addi	a0,a0,1482 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202756:	cf7fd0ef          	jal	ra,ffffffffc020044c <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020275a:	86da                	mv	a3,s6
ffffffffc020275c:	00003617          	auipc	a2,0x3
ffffffffc0202760:	4cc60613          	addi	a2,a2,1228 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0202764:	16e00593          	li	a1,366
ffffffffc0202768:	00003517          	auipc	a0,0x3
ffffffffc020276c:	5b050513          	addi	a0,a0,1456 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202770:	cddfd0ef          	jal	ra,ffffffffc020044c <__panic>
    return KADDR(page2pa(page));
ffffffffc0202774:	86be                	mv	a3,a5
ffffffffc0202776:	00003617          	auipc	a2,0x3
ffffffffc020277a:	4b260613          	addi	a2,a2,1202 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc020277e:	06900593          	li	a1,105
ffffffffc0202782:	00003517          	auipc	a0,0x3
ffffffffc0202786:	4ce50513          	addi	a0,a0,1230 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc020278a:	cc3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020278e:	00004697          	auipc	a3,0x4
ffffffffc0202792:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0206078 <default_pmm_manager+0x4a0>
ffffffffc0202796:	00003617          	auipc	a2,0x3
ffffffffc020279a:	0aa60613          	addi	a2,a2,170 # ffffffffc0205840 <commands+0x870>
ffffffffc020279e:	18800593          	li	a1,392
ffffffffc02027a2:	00003517          	auipc	a0,0x3
ffffffffc02027a6:	57650513          	addi	a0,a0,1398 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02027aa:	ca3fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02027ae:	00004697          	auipc	a3,0x4
ffffffffc02027b2:	88268693          	addi	a3,a3,-1918 # ffffffffc0206030 <default_pmm_manager+0x458>
ffffffffc02027b6:	00003617          	auipc	a2,0x3
ffffffffc02027ba:	08a60613          	addi	a2,a2,138 # ffffffffc0205840 <commands+0x870>
ffffffffc02027be:	18600593          	li	a1,390
ffffffffc02027c2:	00003517          	auipc	a0,0x3
ffffffffc02027c6:	55650513          	addi	a0,a0,1366 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02027ca:	c83fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02027ce:	00004697          	auipc	a3,0x4
ffffffffc02027d2:	89268693          	addi	a3,a3,-1902 # ffffffffc0206060 <default_pmm_manager+0x488>
ffffffffc02027d6:	00003617          	auipc	a2,0x3
ffffffffc02027da:	06a60613          	addi	a2,a2,106 # ffffffffc0205840 <commands+0x870>
ffffffffc02027de:	18500593          	li	a1,389
ffffffffc02027e2:	00003517          	auipc	a0,0x3
ffffffffc02027e6:	53650513          	addi	a0,a0,1334 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02027ea:	c63fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p) == 2);
ffffffffc02027ee:	00004697          	auipc	a3,0x4
ffffffffc02027f2:	9f268693          	addi	a3,a3,-1550 # ffffffffc02061e0 <default_pmm_manager+0x608>
ffffffffc02027f6:	00003617          	auipc	a2,0x3
ffffffffc02027fa:	04a60613          	addi	a2,a2,74 # ffffffffc0205840 <commands+0x870>
ffffffffc02027fe:	1a800593          	li	a1,424
ffffffffc0202802:	00003517          	auipc	a0,0x3
ffffffffc0202806:	51650513          	addi	a0,a0,1302 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020280a:	c43fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020280e:	00004697          	auipc	a3,0x4
ffffffffc0202812:	99268693          	addi	a3,a3,-1646 # ffffffffc02061a0 <default_pmm_manager+0x5c8>
ffffffffc0202816:	00003617          	auipc	a2,0x3
ffffffffc020281a:	02a60613          	addi	a2,a2,42 # ffffffffc0205840 <commands+0x870>
ffffffffc020281e:	1a700593          	li	a1,423
ffffffffc0202822:	00003517          	auipc	a0,0x3
ffffffffc0202826:	4f650513          	addi	a0,a0,1270 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020282a:	c23fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p) == 1);
ffffffffc020282e:	00004697          	auipc	a3,0x4
ffffffffc0202832:	95a68693          	addi	a3,a3,-1702 # ffffffffc0206188 <default_pmm_manager+0x5b0>
ffffffffc0202836:	00003617          	auipc	a2,0x3
ffffffffc020283a:	00a60613          	addi	a2,a2,10 # ffffffffc0205840 <commands+0x870>
ffffffffc020283e:	1a600593          	li	a1,422
ffffffffc0202842:	00003517          	auipc	a0,0x3
ffffffffc0202846:	4d650513          	addi	a0,a0,1238 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020284a:	c03fd0ef          	jal	ra,ffffffffc020044c <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020284e:	86be                	mv	a3,a5
ffffffffc0202850:	00003617          	auipc	a2,0x3
ffffffffc0202854:	3d860613          	addi	a2,a2,984 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0202858:	16d00593          	li	a1,365
ffffffffc020285c:	00003517          	auipc	a0,0x3
ffffffffc0202860:	4bc50513          	addi	a0,a0,1212 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202864:	be9fd0ef          	jal	ra,ffffffffc020044c <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202868:	00003617          	auipc	a2,0x3
ffffffffc020286c:	3f860613          	addi	a2,a2,1016 # ffffffffc0205c60 <default_pmm_manager+0x88>
ffffffffc0202870:	07f00593          	li	a1,127
ffffffffc0202874:	00003517          	auipc	a0,0x3
ffffffffc0202878:	4a450513          	addi	a0,a0,1188 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020287c:	bd1fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202880:	00004697          	auipc	a3,0x4
ffffffffc0202884:	99068693          	addi	a3,a3,-1648 # ffffffffc0206210 <default_pmm_manager+0x638>
ffffffffc0202888:	00003617          	auipc	a2,0x3
ffffffffc020288c:	fb860613          	addi	a2,a2,-72 # ffffffffc0205840 <commands+0x870>
ffffffffc0202890:	1ac00593          	li	a1,428
ffffffffc0202894:	00003517          	auipc	a0,0x3
ffffffffc0202898:	48450513          	addi	a0,a0,1156 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020289c:	bb1fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02028a0:	00004697          	auipc	a3,0x4
ffffffffc02028a4:	80068693          	addi	a3,a3,-2048 # ffffffffc02060a0 <default_pmm_manager+0x4c8>
ffffffffc02028a8:	00003617          	auipc	a2,0x3
ffffffffc02028ac:	f9860613          	addi	a2,a2,-104 # ffffffffc0205840 <commands+0x870>
ffffffffc02028b0:	1b800593          	li	a1,440
ffffffffc02028b4:	00003517          	auipc	a0,0x3
ffffffffc02028b8:	46450513          	addi	a0,a0,1124 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02028bc:	b91fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02028c0:	00003697          	auipc	a3,0x3
ffffffffc02028c4:	63068693          	addi	a3,a3,1584 # ffffffffc0205ef0 <default_pmm_manager+0x318>
ffffffffc02028c8:	00003617          	auipc	a2,0x3
ffffffffc02028cc:	f7860613          	addi	a2,a2,-136 # ffffffffc0205840 <commands+0x870>
ffffffffc02028d0:	16b00593          	li	a1,363
ffffffffc02028d4:	00003517          	auipc	a0,0x3
ffffffffc02028d8:	44450513          	addi	a0,a0,1092 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02028dc:	b71fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02028e0:	00003697          	auipc	a3,0x3
ffffffffc02028e4:	5f868693          	addi	a3,a3,1528 # ffffffffc0205ed8 <default_pmm_manager+0x300>
ffffffffc02028e8:	00003617          	auipc	a2,0x3
ffffffffc02028ec:	f5860613          	addi	a2,a2,-168 # ffffffffc0205840 <commands+0x870>
ffffffffc02028f0:	16a00593          	li	a1,362
ffffffffc02028f4:	00003517          	auipc	a0,0x3
ffffffffc02028f8:	42450513          	addi	a0,a0,1060 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02028fc:	b51fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202900:	00003697          	auipc	a3,0x3
ffffffffc0202904:	52868693          	addi	a3,a3,1320 # ffffffffc0205e28 <default_pmm_manager+0x250>
ffffffffc0202908:	00003617          	auipc	a2,0x3
ffffffffc020290c:	f3860613          	addi	a2,a2,-200 # ffffffffc0205840 <commands+0x870>
ffffffffc0202910:	16200593          	li	a1,354
ffffffffc0202914:	00003517          	auipc	a0,0x3
ffffffffc0202918:	40450513          	addi	a0,a0,1028 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020291c:	b31fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202920:	00003697          	auipc	a3,0x3
ffffffffc0202924:	56068693          	addi	a3,a3,1376 # ffffffffc0205e80 <default_pmm_manager+0x2a8>
ffffffffc0202928:	00003617          	auipc	a2,0x3
ffffffffc020292c:	f1860613          	addi	a2,a2,-232 # ffffffffc0205840 <commands+0x870>
ffffffffc0202930:	16900593          	li	a1,361
ffffffffc0202934:	00003517          	auipc	a0,0x3
ffffffffc0202938:	3e450513          	addi	a0,a0,996 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020293c:	b11fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202940:	00003697          	auipc	a3,0x3
ffffffffc0202944:	51068693          	addi	a3,a3,1296 # ffffffffc0205e50 <default_pmm_manager+0x278>
ffffffffc0202948:	00003617          	auipc	a2,0x3
ffffffffc020294c:	ef860613          	addi	a2,a2,-264 # ffffffffc0205840 <commands+0x870>
ffffffffc0202950:	16600593          	li	a1,358
ffffffffc0202954:	00003517          	auipc	a0,0x3
ffffffffc0202958:	3c450513          	addi	a0,a0,964 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020295c:	af1fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202960:	00003697          	auipc	a3,0x3
ffffffffc0202964:	6d068693          	addi	a3,a3,1744 # ffffffffc0206030 <default_pmm_manager+0x458>
ffffffffc0202968:	00003617          	auipc	a2,0x3
ffffffffc020296c:	ed860613          	addi	a2,a2,-296 # ffffffffc0205840 <commands+0x870>
ffffffffc0202970:	18200593          	li	a1,386
ffffffffc0202974:	00003517          	auipc	a0,0x3
ffffffffc0202978:	3a450513          	addi	a0,a0,932 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020297c:	ad1fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202980:	00003697          	auipc	a3,0x3
ffffffffc0202984:	57068693          	addi	a3,a3,1392 # ffffffffc0205ef0 <default_pmm_manager+0x318>
ffffffffc0202988:	00003617          	auipc	a2,0x3
ffffffffc020298c:	eb860613          	addi	a2,a2,-328 # ffffffffc0205840 <commands+0x870>
ffffffffc0202990:	18100593          	li	a1,385
ffffffffc0202994:	00003517          	auipc	a0,0x3
ffffffffc0202998:	38450513          	addi	a0,a0,900 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc020299c:	ab1fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02029a0:	00003697          	auipc	a3,0x3
ffffffffc02029a4:	6a868693          	addi	a3,a3,1704 # ffffffffc0206048 <default_pmm_manager+0x470>
ffffffffc02029a8:	00003617          	auipc	a2,0x3
ffffffffc02029ac:	e9860613          	addi	a2,a2,-360 # ffffffffc0205840 <commands+0x870>
ffffffffc02029b0:	17e00593          	li	a1,382
ffffffffc02029b4:	00003517          	auipc	a0,0x3
ffffffffc02029b8:	36450513          	addi	a0,a0,868 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02029bc:	a91fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02029c0:	00004697          	auipc	a3,0x4
ffffffffc02029c4:	88868693          	addi	a3,a3,-1912 # ffffffffc0206248 <default_pmm_manager+0x670>
ffffffffc02029c8:	00003617          	auipc	a2,0x3
ffffffffc02029cc:	e7860613          	addi	a2,a2,-392 # ffffffffc0205840 <commands+0x870>
ffffffffc02029d0:	1af00593          	li	a1,431
ffffffffc02029d4:	00003517          	auipc	a0,0x3
ffffffffc02029d8:	34450513          	addi	a0,a0,836 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02029dc:	a71fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02029e0:	00003697          	auipc	a3,0x3
ffffffffc02029e4:	6c068693          	addi	a3,a3,1728 # ffffffffc02060a0 <default_pmm_manager+0x4c8>
ffffffffc02029e8:	00003617          	auipc	a2,0x3
ffffffffc02029ec:	e5860613          	addi	a2,a2,-424 # ffffffffc0205840 <commands+0x870>
ffffffffc02029f0:	19000593          	li	a1,400
ffffffffc02029f4:	00003517          	auipc	a0,0x3
ffffffffc02029f8:	32450513          	addi	a0,a0,804 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc02029fc:	a51fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202a00:	00003697          	auipc	a3,0x3
ffffffffc0202a04:	73868693          	addi	a3,a3,1848 # ffffffffc0206138 <default_pmm_manager+0x560>
ffffffffc0202a08:	00003617          	auipc	a2,0x3
ffffffffc0202a0c:	e3860613          	addi	a2,a2,-456 # ffffffffc0205840 <commands+0x870>
ffffffffc0202a10:	1a100593          	li	a1,417
ffffffffc0202a14:	00003517          	auipc	a0,0x3
ffffffffc0202a18:	30450513          	addi	a0,a0,772 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202a1c:	a31fd0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202a20:	00003697          	auipc	a3,0x3
ffffffffc0202a24:	3b068693          	addi	a3,a3,944 # ffffffffc0205dd0 <default_pmm_manager+0x1f8>
ffffffffc0202a28:	00003617          	auipc	a2,0x3
ffffffffc0202a2c:	e1860613          	addi	a2,a2,-488 # ffffffffc0205840 <commands+0x870>
ffffffffc0202a30:	16000593          	li	a1,352
ffffffffc0202a34:	00003517          	auipc	a0,0x3
ffffffffc0202a38:	2e450513          	addi	a0,a0,740 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202a3c:	a11fd0ef          	jal	ra,ffffffffc020044c <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202a40:	00003617          	auipc	a2,0x3
ffffffffc0202a44:	22060613          	addi	a2,a2,544 # ffffffffc0205c60 <default_pmm_manager+0x88>
ffffffffc0202a48:	0c300593          	li	a1,195
ffffffffc0202a4c:	00003517          	auipc	a0,0x3
ffffffffc0202a50:	2cc50513          	addi	a0,a0,716 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202a54:	9f9fd0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0202a58 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202a58:	12058073          	sfence.vma	a1
}
ffffffffc0202a5c:	8082                	ret

ffffffffc0202a5e <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a5e:	7179                	addi	sp,sp,-48
ffffffffc0202a60:	e84a                	sd	s2,16(sp)
ffffffffc0202a62:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202a64:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a66:	f022                	sd	s0,32(sp)
ffffffffc0202a68:	ec26                	sd	s1,24(sp)
ffffffffc0202a6a:	e44e                	sd	s3,8(sp)
ffffffffc0202a6c:	f406                	sd	ra,40(sp)
ffffffffc0202a6e:	84ae                	mv	s1,a1
ffffffffc0202a70:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202a72:	8f6ff0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0202a76:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202a78:	cd19                	beqz	a0,ffffffffc0202a96 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202a7a:	85aa                	mv	a1,a0
ffffffffc0202a7c:	86ce                	mv	a3,s3
ffffffffc0202a7e:	8626                	mv	a2,s1
ffffffffc0202a80:	854a                	mv	a0,s2
ffffffffc0202a82:	c92ff0ef          	jal	ra,ffffffffc0201f14 <page_insert>
ffffffffc0202a86:	ed39                	bnez	a0,ffffffffc0202ae4 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202a88:	00013797          	auipc	a5,0x13
ffffffffc0202a8c:	a1878793          	addi	a5,a5,-1512 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0202a90:	439c                	lw	a5,0(a5)
ffffffffc0202a92:	2781                	sext.w	a5,a5
ffffffffc0202a94:	eb89                	bnez	a5,ffffffffc0202aa6 <pgdir_alloc_page+0x48>
}
ffffffffc0202a96:	8522                	mv	a0,s0
ffffffffc0202a98:	70a2                	ld	ra,40(sp)
ffffffffc0202a9a:	7402                	ld	s0,32(sp)
ffffffffc0202a9c:	64e2                	ld	s1,24(sp)
ffffffffc0202a9e:	6942                	ld	s2,16(sp)
ffffffffc0202aa0:	69a2                	ld	s3,8(sp)
ffffffffc0202aa2:	6145                	addi	sp,sp,48
ffffffffc0202aa4:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202aa6:	00013797          	auipc	a5,0x13
ffffffffc0202aaa:	b3a78793          	addi	a5,a5,-1222 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0202aae:	6388                	ld	a0,0(a5)
ffffffffc0202ab0:	4681                	li	a3,0
ffffffffc0202ab2:	8622                	mv	a2,s0
ffffffffc0202ab4:	85a6                	mv	a1,s1
ffffffffc0202ab6:	7be000ef          	jal	ra,ffffffffc0203274 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202aba:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202abc:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202abe:	4785                	li	a5,1
ffffffffc0202ac0:	fcf70be3          	beq	a4,a5,ffffffffc0202a96 <pgdir_alloc_page+0x38>
ffffffffc0202ac4:	00003697          	auipc	a3,0x3
ffffffffc0202ac8:	26468693          	addi	a3,a3,612 # ffffffffc0205d28 <default_pmm_manager+0x150>
ffffffffc0202acc:	00003617          	auipc	a2,0x3
ffffffffc0202ad0:	d7460613          	addi	a2,a2,-652 # ffffffffc0205840 <commands+0x870>
ffffffffc0202ad4:	14800593          	li	a1,328
ffffffffc0202ad8:	00003517          	auipc	a0,0x3
ffffffffc0202adc:	24050513          	addi	a0,a0,576 # ffffffffc0205d18 <default_pmm_manager+0x140>
ffffffffc0202ae0:	96dfd0ef          	jal	ra,ffffffffc020044c <__panic>
            free_page(page);
ffffffffc0202ae4:	8522                	mv	a0,s0
ffffffffc0202ae6:	4585                	li	a1,1
ffffffffc0202ae8:	908ff0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
            return NULL;
ffffffffc0202aec:	4401                	li	s0,0
ffffffffc0202aee:	b765                	j	ffffffffc0202a96 <pgdir_alloc_page+0x38>

ffffffffc0202af0 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202af0:	7135                	addi	sp,sp,-160
ffffffffc0202af2:	ed06                	sd	ra,152(sp)
ffffffffc0202af4:	e922                	sd	s0,144(sp)
ffffffffc0202af6:	e526                	sd	s1,136(sp)
ffffffffc0202af8:	e14a                	sd	s2,128(sp)
ffffffffc0202afa:	fcce                	sd	s3,120(sp)
ffffffffc0202afc:	f8d2                	sd	s4,112(sp)
ffffffffc0202afe:	f4d6                	sd	s5,104(sp)
ffffffffc0202b00:	f0da                	sd	s6,96(sp)
ffffffffc0202b02:	ecde                	sd	s7,88(sp)
ffffffffc0202b04:	e8e2                	sd	s8,80(sp)
ffffffffc0202b06:	e4e6                	sd	s9,72(sp)
ffffffffc0202b08:	e0ea                	sd	s10,64(sp)
ffffffffc0202b0a:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b0c:	524010ef          	jal	ra,ffffffffc0204030 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202b10:	00013797          	auipc	a5,0x13
ffffffffc0202b14:	a8078793          	addi	a5,a5,-1408 # ffffffffc0215590 <max_swap_offset>
ffffffffc0202b18:	6394                	ld	a3,0(a5)
ffffffffc0202b1a:	010007b7          	lui	a5,0x1000
ffffffffc0202b1e:	17e1                	addi	a5,a5,-8
ffffffffc0202b20:	ff968713          	addi	a4,a3,-7
ffffffffc0202b24:	4ae7e863          	bltu	a5,a4,ffffffffc0202fd4 <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202b28:	00007797          	auipc	a5,0x7
ffffffffc0202b2c:	4e878793          	addi	a5,a5,1256 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202b30:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202b32:	00013697          	auipc	a3,0x13
ffffffffc0202b36:	96f6b323          	sd	a5,-1690(a3) # ffffffffc0215498 <sm>
     int r = sm->init();
ffffffffc0202b3a:	9702                	jalr	a4
ffffffffc0202b3c:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202b3e:	c10d                	beqz	a0,ffffffffc0202b60 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202b40:	60ea                	ld	ra,152(sp)
ffffffffc0202b42:	644a                	ld	s0,144(sp)
ffffffffc0202b44:	8556                	mv	a0,s5
ffffffffc0202b46:	64aa                	ld	s1,136(sp)
ffffffffc0202b48:	690a                	ld	s2,128(sp)
ffffffffc0202b4a:	79e6                	ld	s3,120(sp)
ffffffffc0202b4c:	7a46                	ld	s4,112(sp)
ffffffffc0202b4e:	7aa6                	ld	s5,104(sp)
ffffffffc0202b50:	7b06                	ld	s6,96(sp)
ffffffffc0202b52:	6be6                	ld	s7,88(sp)
ffffffffc0202b54:	6c46                	ld	s8,80(sp)
ffffffffc0202b56:	6ca6                	ld	s9,72(sp)
ffffffffc0202b58:	6d06                	ld	s10,64(sp)
ffffffffc0202b5a:	7de2                	ld	s11,56(sp)
ffffffffc0202b5c:	610d                	addi	sp,sp,160
ffffffffc0202b5e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b60:	00013797          	auipc	a5,0x13
ffffffffc0202b64:	93878793          	addi	a5,a5,-1736 # ffffffffc0215498 <sm>
ffffffffc0202b68:	639c                	ld	a5,0(a5)
ffffffffc0202b6a:	00003517          	auipc	a0,0x3
ffffffffc0202b6e:	7a650513          	addi	a0,a0,1958 # ffffffffc0206310 <default_pmm_manager+0x738>
    return listelm->next;
ffffffffc0202b72:	00013417          	auipc	s0,0x13
ffffffffc0202b76:	95e40413          	addi	s0,s0,-1698 # ffffffffc02154d0 <free_area>
ffffffffc0202b7a:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202b7c:	4785                	li	a5,1
ffffffffc0202b7e:	00013717          	auipc	a4,0x13
ffffffffc0202b82:	92f72123          	sw	a5,-1758(a4) # ffffffffc02154a0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b86:	e08fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202b8a:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b8c:	36878863          	beq	a5,s0,ffffffffc0202efc <swap_init+0x40c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202b90:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202b94:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202b96:	8b05                	andi	a4,a4,1
ffffffffc0202b98:	36070663          	beqz	a4,ffffffffc0202f04 <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202b9c:	4481                	li	s1,0
ffffffffc0202b9e:	4901                	li	s2,0
ffffffffc0202ba0:	a031                	j	ffffffffc0202bac <swap_init+0xbc>
ffffffffc0202ba2:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202ba6:	8b09                	andi	a4,a4,2
ffffffffc0202ba8:	34070e63          	beqz	a4,ffffffffc0202f04 <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0202bac:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bb0:	679c                	ld	a5,8(a5)
ffffffffc0202bb2:	2905                	addiw	s2,s2,1
ffffffffc0202bb4:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bb6:	fe8796e3          	bne	a5,s0,ffffffffc0202ba2 <swap_init+0xb2>
ffffffffc0202bba:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202bbc:	87aff0ef          	jal	ra,ffffffffc0201c36 <nr_free_pages>
ffffffffc0202bc0:	69351263          	bne	a0,s3,ffffffffc0203244 <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202bc4:	8626                	mv	a2,s1
ffffffffc0202bc6:	85ca                	mv	a1,s2
ffffffffc0202bc8:	00003517          	auipc	a0,0x3
ffffffffc0202bcc:	76050513          	addi	a0,a0,1888 # ffffffffc0206328 <default_pmm_manager+0x750>
ffffffffc0202bd0:	dbefd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202bd4:	45b000ef          	jal	ra,ffffffffc020382e <mm_create>
ffffffffc0202bd8:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202bda:	60050563          	beqz	a0,ffffffffc02031e4 <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202bde:	00013797          	auipc	a5,0x13
ffffffffc0202be2:	a0278793          	addi	a5,a5,-1534 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0202be6:	639c                	ld	a5,0(a5)
ffffffffc0202be8:	60079e63          	bnez	a5,ffffffffc0203204 <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202bec:	00013797          	auipc	a5,0x13
ffffffffc0202bf0:	89c78793          	addi	a5,a5,-1892 # ffffffffc0215488 <boot_pgdir>
ffffffffc0202bf4:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202bf8:	00013797          	auipc	a5,0x13
ffffffffc0202bfc:	9ea7b423          	sd	a0,-1560(a5) # ffffffffc02155e0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202c00:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c04:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c08:	4e079263          	bnez	a5,ffffffffc02030ec <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c0c:	6599                	lui	a1,0x6
ffffffffc0202c0e:	460d                	li	a2,3
ffffffffc0202c10:	6505                	lui	a0,0x1
ffffffffc0202c12:	469000ef          	jal	ra,ffffffffc020387a <vma_create>
ffffffffc0202c16:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c18:	4e050a63          	beqz	a0,ffffffffc020310c <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0202c1c:	855e                	mv	a0,s7
ffffffffc0202c1e:	4c9000ef          	jal	ra,ffffffffc02038e6 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c22:	00003517          	auipc	a0,0x3
ffffffffc0202c26:	77650513          	addi	a0,a0,1910 # ffffffffc0206398 <default_pmm_manager+0x7c0>
ffffffffc0202c2a:	d64fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c2e:	018bb503          	ld	a0,24(s7)
ffffffffc0202c32:	4605                	li	a2,1
ffffffffc0202c34:	6585                	lui	a1,0x1
ffffffffc0202c36:	840ff0ef          	jal	ra,ffffffffc0201c76 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c3a:	4e050963          	beqz	a0,ffffffffc020312c <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c3e:	00003517          	auipc	a0,0x3
ffffffffc0202c42:	7aa50513          	addi	a0,a0,1962 # ffffffffc02063e8 <default_pmm_manager+0x810>
ffffffffc0202c46:	00013997          	auipc	s3,0x13
ffffffffc0202c4a:	8c298993          	addi	s3,s3,-1854 # ffffffffc0215508 <check_rp>
ffffffffc0202c4e:	d40fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c52:	00013a17          	auipc	s4,0x13
ffffffffc0202c56:	8d6a0a13          	addi	s4,s4,-1834 # ffffffffc0215528 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c5a:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202c5c:	4505                	li	a0,1
ffffffffc0202c5e:	f0bfe0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
ffffffffc0202c62:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202c66:	32050763          	beqz	a0,ffffffffc0202f94 <swap_init+0x4a4>
ffffffffc0202c6a:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c6c:	8b89                	andi	a5,a5,2
ffffffffc0202c6e:	30079363          	bnez	a5,ffffffffc0202f74 <swap_init+0x484>
ffffffffc0202c72:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c74:	ff4c14e3          	bne	s8,s4,ffffffffc0202c5c <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202c78:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202c7a:	00013c17          	auipc	s8,0x13
ffffffffc0202c7e:	88ec0c13          	addi	s8,s8,-1906 # ffffffffc0215508 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202c82:	ec3e                	sd	a5,24(sp)
ffffffffc0202c84:	641c                	ld	a5,8(s0)
ffffffffc0202c86:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202c88:	481c                	lw	a5,16(s0)
ffffffffc0202c8a:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202c8c:	00013797          	auipc	a5,0x13
ffffffffc0202c90:	8487b623          	sd	s0,-1972(a5) # ffffffffc02154d8 <free_area+0x8>
ffffffffc0202c94:	00013797          	auipc	a5,0x13
ffffffffc0202c98:	8287be23          	sd	s0,-1988(a5) # ffffffffc02154d0 <free_area>
     nr_free = 0;
ffffffffc0202c9c:	00013797          	auipc	a5,0x13
ffffffffc0202ca0:	8407a223          	sw	zero,-1980(a5) # ffffffffc02154e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202ca4:	000c3503          	ld	a0,0(s8)
ffffffffc0202ca8:	4585                	li	a1,1
ffffffffc0202caa:	0c21                	addi	s8,s8,8
ffffffffc0202cac:	f45fe0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cb0:	ff4c1ae3          	bne	s8,s4,ffffffffc0202ca4 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202cb4:	01042c03          	lw	s8,16(s0)
ffffffffc0202cb8:	4791                	li	a5,4
ffffffffc0202cba:	50fc1563          	bne	s8,a5,ffffffffc02031c4 <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202cbe:	00003517          	auipc	a0,0x3
ffffffffc0202cc2:	7b250513          	addi	a0,a0,1970 # ffffffffc0206470 <default_pmm_manager+0x898>
ffffffffc0202cc6:	cc8fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cca:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202ccc:	00012797          	auipc	a5,0x12
ffffffffc0202cd0:	7c07ac23          	sw	zero,2008(a5) # ffffffffc02154a4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cd4:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202cd6:	00012797          	auipc	a5,0x12
ffffffffc0202cda:	7ce78793          	addi	a5,a5,1998 # ffffffffc02154a4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cde:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202ce2:	4398                	lw	a4,0(a5)
ffffffffc0202ce4:	4585                	li	a1,1
ffffffffc0202ce6:	2701                	sext.w	a4,a4
ffffffffc0202ce8:	38b71263          	bne	a4,a1,ffffffffc020306c <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202cec:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202cf0:	4394                	lw	a3,0(a5)
ffffffffc0202cf2:	2681                	sext.w	a3,a3
ffffffffc0202cf4:	38e69c63          	bne	a3,a4,ffffffffc020308c <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202cf8:	6689                	lui	a3,0x2
ffffffffc0202cfa:	462d                	li	a2,11
ffffffffc0202cfc:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d00:	4398                	lw	a4,0(a5)
ffffffffc0202d02:	4589                	li	a1,2
ffffffffc0202d04:	2701                	sext.w	a4,a4
ffffffffc0202d06:	2eb71363          	bne	a4,a1,ffffffffc0202fec <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d0a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d0e:	4394                	lw	a3,0(a5)
ffffffffc0202d10:	2681                	sext.w	a3,a3
ffffffffc0202d12:	2ee69d63          	bne	a3,a4,ffffffffc020300c <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d16:	668d                	lui	a3,0x3
ffffffffc0202d18:	4631                	li	a2,12
ffffffffc0202d1a:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d1e:	4398                	lw	a4,0(a5)
ffffffffc0202d20:	458d                	li	a1,3
ffffffffc0202d22:	2701                	sext.w	a4,a4
ffffffffc0202d24:	30b71463          	bne	a4,a1,ffffffffc020302c <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d28:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d2c:	4394                	lw	a3,0(a5)
ffffffffc0202d2e:	2681                	sext.w	a3,a3
ffffffffc0202d30:	30e69e63          	bne	a3,a4,ffffffffc020304c <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d34:	6691                	lui	a3,0x4
ffffffffc0202d36:	4635                	li	a2,13
ffffffffc0202d38:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202d3c:	4398                	lw	a4,0(a5)
ffffffffc0202d3e:	2701                	sext.w	a4,a4
ffffffffc0202d40:	37871663          	bne	a4,s8,ffffffffc02030ac <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202d44:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202d48:	439c                	lw	a5,0(a5)
ffffffffc0202d4a:	2781                	sext.w	a5,a5
ffffffffc0202d4c:	38e79063          	bne	a5,a4,ffffffffc02030cc <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202d50:	481c                	lw	a5,16(s0)
ffffffffc0202d52:	3e079d63          	bnez	a5,ffffffffc020314c <swap_init+0x65c>
ffffffffc0202d56:	00012797          	auipc	a5,0x12
ffffffffc0202d5a:	7d278793          	addi	a5,a5,2002 # ffffffffc0215528 <swap_in_seq_no>
ffffffffc0202d5e:	00012717          	auipc	a4,0x12
ffffffffc0202d62:	7f270713          	addi	a4,a4,2034 # ffffffffc0215550 <swap_out_seq_no>
ffffffffc0202d66:	00012617          	auipc	a2,0x12
ffffffffc0202d6a:	7ea60613          	addi	a2,a2,2026 # ffffffffc0215550 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202d6e:	56fd                	li	a3,-1
ffffffffc0202d70:	c394                	sw	a3,0(a5)
ffffffffc0202d72:	c314                	sw	a3,0(a4)
ffffffffc0202d74:	0791                	addi	a5,a5,4
ffffffffc0202d76:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202d78:	fef61ce3          	bne	a2,a5,ffffffffc0202d70 <swap_init+0x280>
ffffffffc0202d7c:	00013697          	auipc	a3,0x13
ffffffffc0202d80:	83468693          	addi	a3,a3,-1996 # ffffffffc02155b0 <check_ptep>
ffffffffc0202d84:	00012817          	auipc	a6,0x12
ffffffffc0202d88:	78480813          	addi	a6,a6,1924 # ffffffffc0215508 <check_rp>
ffffffffc0202d8c:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202d8e:	00012c97          	auipc	s9,0x12
ffffffffc0202d92:	702c8c93          	addi	s9,s9,1794 # ffffffffc0215490 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d96:	00004d97          	auipc	s11,0x4
ffffffffc0202d9a:	24ad8d93          	addi	s11,s11,586 # ffffffffc0206fe0 <nbase>
ffffffffc0202d9e:	00012c17          	auipc	s8,0x12
ffffffffc0202da2:	762c0c13          	addi	s8,s8,1890 # ffffffffc0215500 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202da6:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202daa:	4601                	li	a2,0
ffffffffc0202dac:	85ea                	mv	a1,s10
ffffffffc0202dae:	855a                	mv	a0,s6
ffffffffc0202db0:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202db2:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202db4:	ec3fe0ef          	jal	ra,ffffffffc0201c76 <get_pte>
ffffffffc0202db8:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202dba:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dbc:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202dbe:	1e050b63          	beqz	a0,ffffffffc0202fb4 <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202dc2:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202dc4:	0017f613          	andi	a2,a5,1
ffffffffc0202dc8:	18060a63          	beqz	a2,ffffffffc0202f5c <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202dcc:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202dd0:	078a                	slli	a5,a5,0x2
ffffffffc0202dd2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dd4:	14c7f863          	bgeu	a5,a2,ffffffffc0202f24 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dd8:	000db703          	ld	a4,0(s11)
ffffffffc0202ddc:	000c3603          	ld	a2,0(s8)
ffffffffc0202de0:	00083583          	ld	a1,0(a6)
ffffffffc0202de4:	8f99                	sub	a5,a5,a4
ffffffffc0202de6:	079a                	slli	a5,a5,0x6
ffffffffc0202de8:	e43a                	sd	a4,8(sp)
ffffffffc0202dea:	97b2                	add	a5,a5,a2
ffffffffc0202dec:	14f59863          	bne	a1,a5,ffffffffc0202f3c <swap_init+0x44c>
ffffffffc0202df0:	6785                	lui	a5,0x1
ffffffffc0202df2:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202df4:	6795                	lui	a5,0x5
ffffffffc0202df6:	06a1                	addi	a3,a3,8
ffffffffc0202df8:	0821                	addi	a6,a6,8
ffffffffc0202dfa:	fafd16e3          	bne	s10,a5,ffffffffc0202da6 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202dfe:	00003517          	auipc	a0,0x3
ffffffffc0202e02:	71a50513          	addi	a0,a0,1818 # ffffffffc0206518 <default_pmm_manager+0x940>
ffffffffc0202e06:	b88fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e0a:	00012797          	auipc	a5,0x12
ffffffffc0202e0e:	68e78793          	addi	a5,a5,1678 # ffffffffc0215498 <sm>
ffffffffc0202e12:	639c                	ld	a5,0(a5)
ffffffffc0202e14:	7f9c                	ld	a5,56(a5)
ffffffffc0202e16:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202e18:	40051663          	bnez	a0,ffffffffc0203224 <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202e1c:	77a2                	ld	a5,40(sp)
ffffffffc0202e1e:	00012717          	auipc	a4,0x12
ffffffffc0202e22:	6cf72123          	sw	a5,1730(a4) # ffffffffc02154e0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202e26:	67e2                	ld	a5,24(sp)
ffffffffc0202e28:	00012717          	auipc	a4,0x12
ffffffffc0202e2c:	6af73423          	sd	a5,1704(a4) # ffffffffc02154d0 <free_area>
ffffffffc0202e30:	7782                	ld	a5,32(sp)
ffffffffc0202e32:	00012717          	auipc	a4,0x12
ffffffffc0202e36:	6af73323          	sd	a5,1702(a4) # ffffffffc02154d8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202e3a:	0009b503          	ld	a0,0(s3)
ffffffffc0202e3e:	4585                	li	a1,1
ffffffffc0202e40:	09a1                	addi	s3,s3,8
ffffffffc0202e42:	daffe0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e46:	ff499ae3          	bne	s3,s4,ffffffffc0202e3a <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202e4a:	855e                	mv	a0,s7
ffffffffc0202e4c:	369000ef          	jal	ra,ffffffffc02039b4 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202e50:	00012797          	auipc	a5,0x12
ffffffffc0202e54:	63878793          	addi	a5,a5,1592 # ffffffffc0215488 <boot_pgdir>
ffffffffc0202e58:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202e5a:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e5e:	6394                	ld	a3,0(a5)
ffffffffc0202e60:	068a                	slli	a3,a3,0x2
ffffffffc0202e62:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e64:	0ce6f063          	bgeu	a3,a4,ffffffffc0202f24 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e68:	67a2                	ld	a5,8(sp)
ffffffffc0202e6a:	000c3503          	ld	a0,0(s8)
ffffffffc0202e6e:	8e9d                	sub	a3,a3,a5
ffffffffc0202e70:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202e72:	8699                	srai	a3,a3,0x6
ffffffffc0202e74:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202e76:	00c69793          	slli	a5,a3,0xc
ffffffffc0202e7a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e7c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e7e:	2ee7f763          	bgeu	a5,a4,ffffffffc020316c <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0202e82:	00012797          	auipc	a5,0x12
ffffffffc0202e86:	66e78793          	addi	a5,a5,1646 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0202e8a:	639c                	ld	a5,0(a5)
ffffffffc0202e8c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e8e:	629c                	ld	a5,0(a3)
ffffffffc0202e90:	078a                	slli	a5,a5,0x2
ffffffffc0202e92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e94:	08e7f863          	bgeu	a5,a4,ffffffffc0202f24 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e98:	69a2                	ld	s3,8(sp)
ffffffffc0202e9a:	4585                	li	a1,1
ffffffffc0202e9c:	413787b3          	sub	a5,a5,s3
ffffffffc0202ea0:	079a                	slli	a5,a5,0x6
ffffffffc0202ea2:	953e                	add	a0,a0,a5
ffffffffc0202ea4:	d4dfe0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ea8:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202eac:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eb0:	078a                	slli	a5,a5,0x2
ffffffffc0202eb2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202eb4:	06e7f863          	bgeu	a5,a4,ffffffffc0202f24 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202eb8:	000c3503          	ld	a0,0(s8)
ffffffffc0202ebc:	413787b3          	sub	a5,a5,s3
ffffffffc0202ec0:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202ec2:	4585                	li	a1,1
ffffffffc0202ec4:	953e                	add	a0,a0,a5
ffffffffc0202ec6:	d2bfe0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
     pgdir[0] = 0;
ffffffffc0202eca:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202ece:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202ed2:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ed4:	00878963          	beq	a5,s0,ffffffffc0202ee6 <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202ed8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202edc:	679c                	ld	a5,8(a5)
ffffffffc0202ede:	397d                	addiw	s2,s2,-1
ffffffffc0202ee0:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ee2:	fe879be3          	bne	a5,s0,ffffffffc0202ed8 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0202ee6:	28091f63          	bnez	s2,ffffffffc0203184 <swap_init+0x694>
     assert(total==0);
ffffffffc0202eea:	2a049d63          	bnez	s1,ffffffffc02031a4 <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202eee:	00003517          	auipc	a0,0x3
ffffffffc0202ef2:	67a50513          	addi	a0,a0,1658 # ffffffffc0206568 <default_pmm_manager+0x990>
ffffffffc0202ef6:	a98fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202efa:	b199                	j	ffffffffc0202b40 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202efc:	4481                	li	s1,0
ffffffffc0202efe:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f00:	4981                	li	s3,0
ffffffffc0202f02:	b96d                	j	ffffffffc0202bbc <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202f04:	00003697          	auipc	a3,0x3
ffffffffc0202f08:	92c68693          	addi	a3,a3,-1748 # ffffffffc0205830 <commands+0x860>
ffffffffc0202f0c:	00003617          	auipc	a2,0x3
ffffffffc0202f10:	93460613          	addi	a2,a2,-1740 # ffffffffc0205840 <commands+0x870>
ffffffffc0202f14:	0bd00593          	li	a1,189
ffffffffc0202f18:	00003517          	auipc	a0,0x3
ffffffffc0202f1c:	3e850513          	addi	a0,a0,1000 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0202f20:	d2cfd0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202f24:	00003617          	auipc	a2,0x3
ffffffffc0202f28:	d6460613          	addi	a2,a2,-668 # ffffffffc0205c88 <default_pmm_manager+0xb0>
ffffffffc0202f2c:	06200593          	li	a1,98
ffffffffc0202f30:	00003517          	auipc	a0,0x3
ffffffffc0202f34:	d2050513          	addi	a0,a0,-736 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0202f38:	d14fd0ef          	jal	ra,ffffffffc020044c <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f3c:	00003697          	auipc	a3,0x3
ffffffffc0202f40:	5b468693          	addi	a3,a3,1460 # ffffffffc02064f0 <default_pmm_manager+0x918>
ffffffffc0202f44:	00003617          	auipc	a2,0x3
ffffffffc0202f48:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0205840 <commands+0x870>
ffffffffc0202f4c:	0fd00593          	li	a1,253
ffffffffc0202f50:	00003517          	auipc	a0,0x3
ffffffffc0202f54:	3b050513          	addi	a0,a0,944 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0202f58:	cf4fd0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202f5c:	00003617          	auipc	a2,0x3
ffffffffc0202f60:	f5460613          	addi	a2,a2,-172 # ffffffffc0205eb0 <default_pmm_manager+0x2d8>
ffffffffc0202f64:	07400593          	li	a1,116
ffffffffc0202f68:	00003517          	auipc	a0,0x3
ffffffffc0202f6c:	ce850513          	addi	a0,a0,-792 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0202f70:	cdcfd0ef          	jal	ra,ffffffffc020044c <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202f74:	00003697          	auipc	a3,0x3
ffffffffc0202f78:	4b468693          	addi	a3,a3,1204 # ffffffffc0206428 <default_pmm_manager+0x850>
ffffffffc0202f7c:	00003617          	auipc	a2,0x3
ffffffffc0202f80:	8c460613          	addi	a2,a2,-1852 # ffffffffc0205840 <commands+0x870>
ffffffffc0202f84:	0de00593          	li	a1,222
ffffffffc0202f88:	00003517          	auipc	a0,0x3
ffffffffc0202f8c:	37850513          	addi	a0,a0,888 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0202f90:	cbcfd0ef          	jal	ra,ffffffffc020044c <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202f94:	00003697          	auipc	a3,0x3
ffffffffc0202f98:	47c68693          	addi	a3,a3,1148 # ffffffffc0206410 <default_pmm_manager+0x838>
ffffffffc0202f9c:	00003617          	auipc	a2,0x3
ffffffffc0202fa0:	8a460613          	addi	a2,a2,-1884 # ffffffffc0205840 <commands+0x870>
ffffffffc0202fa4:	0dd00593          	li	a1,221
ffffffffc0202fa8:	00003517          	auipc	a0,0x3
ffffffffc0202fac:	35850513          	addi	a0,a0,856 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0202fb0:	c9cfd0ef          	jal	ra,ffffffffc020044c <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202fb4:	00003697          	auipc	a3,0x3
ffffffffc0202fb8:	52468693          	addi	a3,a3,1316 # ffffffffc02064d8 <default_pmm_manager+0x900>
ffffffffc0202fbc:	00003617          	auipc	a2,0x3
ffffffffc0202fc0:	88460613          	addi	a2,a2,-1916 # ffffffffc0205840 <commands+0x870>
ffffffffc0202fc4:	0fc00593          	li	a1,252
ffffffffc0202fc8:	00003517          	auipc	a0,0x3
ffffffffc0202fcc:	33850513          	addi	a0,a0,824 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0202fd0:	c7cfd0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202fd4:	00003617          	auipc	a2,0x3
ffffffffc0202fd8:	30c60613          	addi	a2,a2,780 # ffffffffc02062e0 <default_pmm_manager+0x708>
ffffffffc0202fdc:	02a00593          	li	a1,42
ffffffffc0202fe0:	00003517          	auipc	a0,0x3
ffffffffc0202fe4:	32050513          	addi	a0,a0,800 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0202fe8:	c64fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==2);
ffffffffc0202fec:	00003697          	auipc	a3,0x3
ffffffffc0202ff0:	4bc68693          	addi	a3,a3,1212 # ffffffffc02064a8 <default_pmm_manager+0x8d0>
ffffffffc0202ff4:	00003617          	auipc	a2,0x3
ffffffffc0202ff8:	84c60613          	addi	a2,a2,-1972 # ffffffffc0205840 <commands+0x870>
ffffffffc0202ffc:	09800593          	li	a1,152
ffffffffc0203000:	00003517          	auipc	a0,0x3
ffffffffc0203004:	30050513          	addi	a0,a0,768 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203008:	c44fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==2);
ffffffffc020300c:	00003697          	auipc	a3,0x3
ffffffffc0203010:	49c68693          	addi	a3,a3,1180 # ffffffffc02064a8 <default_pmm_manager+0x8d0>
ffffffffc0203014:	00003617          	auipc	a2,0x3
ffffffffc0203018:	82c60613          	addi	a2,a2,-2004 # ffffffffc0205840 <commands+0x870>
ffffffffc020301c:	09a00593          	li	a1,154
ffffffffc0203020:	00003517          	auipc	a0,0x3
ffffffffc0203024:	2e050513          	addi	a0,a0,736 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203028:	c24fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==3);
ffffffffc020302c:	00003697          	auipc	a3,0x3
ffffffffc0203030:	48c68693          	addi	a3,a3,1164 # ffffffffc02064b8 <default_pmm_manager+0x8e0>
ffffffffc0203034:	00003617          	auipc	a2,0x3
ffffffffc0203038:	80c60613          	addi	a2,a2,-2036 # ffffffffc0205840 <commands+0x870>
ffffffffc020303c:	09c00593          	li	a1,156
ffffffffc0203040:	00003517          	auipc	a0,0x3
ffffffffc0203044:	2c050513          	addi	a0,a0,704 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203048:	c04fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==3);
ffffffffc020304c:	00003697          	auipc	a3,0x3
ffffffffc0203050:	46c68693          	addi	a3,a3,1132 # ffffffffc02064b8 <default_pmm_manager+0x8e0>
ffffffffc0203054:	00002617          	auipc	a2,0x2
ffffffffc0203058:	7ec60613          	addi	a2,a2,2028 # ffffffffc0205840 <commands+0x870>
ffffffffc020305c:	09e00593          	li	a1,158
ffffffffc0203060:	00003517          	auipc	a0,0x3
ffffffffc0203064:	2a050513          	addi	a0,a0,672 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203068:	be4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==1);
ffffffffc020306c:	00003697          	auipc	a3,0x3
ffffffffc0203070:	42c68693          	addi	a3,a3,1068 # ffffffffc0206498 <default_pmm_manager+0x8c0>
ffffffffc0203074:	00002617          	auipc	a2,0x2
ffffffffc0203078:	7cc60613          	addi	a2,a2,1996 # ffffffffc0205840 <commands+0x870>
ffffffffc020307c:	09400593          	li	a1,148
ffffffffc0203080:	00003517          	auipc	a0,0x3
ffffffffc0203084:	28050513          	addi	a0,a0,640 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203088:	bc4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==1);
ffffffffc020308c:	00003697          	auipc	a3,0x3
ffffffffc0203090:	40c68693          	addi	a3,a3,1036 # ffffffffc0206498 <default_pmm_manager+0x8c0>
ffffffffc0203094:	00002617          	auipc	a2,0x2
ffffffffc0203098:	7ac60613          	addi	a2,a2,1964 # ffffffffc0205840 <commands+0x870>
ffffffffc020309c:	09600593          	li	a1,150
ffffffffc02030a0:	00003517          	auipc	a0,0x3
ffffffffc02030a4:	26050513          	addi	a0,a0,608 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc02030a8:	ba4fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==4);
ffffffffc02030ac:	00003697          	auipc	a3,0x3
ffffffffc02030b0:	41c68693          	addi	a3,a3,1052 # ffffffffc02064c8 <default_pmm_manager+0x8f0>
ffffffffc02030b4:	00002617          	auipc	a2,0x2
ffffffffc02030b8:	78c60613          	addi	a2,a2,1932 # ffffffffc0205840 <commands+0x870>
ffffffffc02030bc:	0a000593          	li	a1,160
ffffffffc02030c0:	00003517          	auipc	a0,0x3
ffffffffc02030c4:	24050513          	addi	a0,a0,576 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc02030c8:	b84fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgfault_num==4);
ffffffffc02030cc:	00003697          	auipc	a3,0x3
ffffffffc02030d0:	3fc68693          	addi	a3,a3,1020 # ffffffffc02064c8 <default_pmm_manager+0x8f0>
ffffffffc02030d4:	00002617          	auipc	a2,0x2
ffffffffc02030d8:	76c60613          	addi	a2,a2,1900 # ffffffffc0205840 <commands+0x870>
ffffffffc02030dc:	0a200593          	li	a1,162
ffffffffc02030e0:	00003517          	auipc	a0,0x3
ffffffffc02030e4:	22050513          	addi	a0,a0,544 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc02030e8:	b64fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(pgdir[0] == 0);
ffffffffc02030ec:	00003697          	auipc	a3,0x3
ffffffffc02030f0:	28c68693          	addi	a3,a3,652 # ffffffffc0206378 <default_pmm_manager+0x7a0>
ffffffffc02030f4:	00002617          	auipc	a2,0x2
ffffffffc02030f8:	74c60613          	addi	a2,a2,1868 # ffffffffc0205840 <commands+0x870>
ffffffffc02030fc:	0cd00593          	li	a1,205
ffffffffc0203100:	00003517          	auipc	a0,0x3
ffffffffc0203104:	20050513          	addi	a0,a0,512 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203108:	b44fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(vma != NULL);
ffffffffc020310c:	00003697          	auipc	a3,0x3
ffffffffc0203110:	27c68693          	addi	a3,a3,636 # ffffffffc0206388 <default_pmm_manager+0x7b0>
ffffffffc0203114:	00002617          	auipc	a2,0x2
ffffffffc0203118:	72c60613          	addi	a2,a2,1836 # ffffffffc0205840 <commands+0x870>
ffffffffc020311c:	0d000593          	li	a1,208
ffffffffc0203120:	00003517          	auipc	a0,0x3
ffffffffc0203124:	1e050513          	addi	a0,a0,480 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203128:	b24fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020312c:	00003697          	auipc	a3,0x3
ffffffffc0203130:	2a468693          	addi	a3,a3,676 # ffffffffc02063d0 <default_pmm_manager+0x7f8>
ffffffffc0203134:	00002617          	auipc	a2,0x2
ffffffffc0203138:	70c60613          	addi	a2,a2,1804 # ffffffffc0205840 <commands+0x870>
ffffffffc020313c:	0d800593          	li	a1,216
ffffffffc0203140:	00003517          	auipc	a0,0x3
ffffffffc0203144:	1c050513          	addi	a0,a0,448 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203148:	b04fd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert( nr_free == 0);         
ffffffffc020314c:	00003697          	auipc	a3,0x3
ffffffffc0203150:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0205a18 <commands+0xa48>
ffffffffc0203154:	00002617          	auipc	a2,0x2
ffffffffc0203158:	6ec60613          	addi	a2,a2,1772 # ffffffffc0205840 <commands+0x870>
ffffffffc020315c:	0f400593          	li	a1,244
ffffffffc0203160:	00003517          	auipc	a0,0x3
ffffffffc0203164:	1a050513          	addi	a0,a0,416 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203168:	ae4fd0ef          	jal	ra,ffffffffc020044c <__panic>
    return KADDR(page2pa(page));
ffffffffc020316c:	00003617          	auipc	a2,0x3
ffffffffc0203170:	abc60613          	addi	a2,a2,-1348 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0203174:	06900593          	li	a1,105
ffffffffc0203178:	00003517          	auipc	a0,0x3
ffffffffc020317c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0203180:	accfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(count==0);
ffffffffc0203184:	00003697          	auipc	a3,0x3
ffffffffc0203188:	3c468693          	addi	a3,a3,964 # ffffffffc0206548 <default_pmm_manager+0x970>
ffffffffc020318c:	00002617          	auipc	a2,0x2
ffffffffc0203190:	6b460613          	addi	a2,a2,1716 # ffffffffc0205840 <commands+0x870>
ffffffffc0203194:	11c00593          	li	a1,284
ffffffffc0203198:	00003517          	auipc	a0,0x3
ffffffffc020319c:	16850513          	addi	a0,a0,360 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc02031a0:	aacfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(total==0);
ffffffffc02031a4:	00003697          	auipc	a3,0x3
ffffffffc02031a8:	3b468693          	addi	a3,a3,948 # ffffffffc0206558 <default_pmm_manager+0x980>
ffffffffc02031ac:	00002617          	auipc	a2,0x2
ffffffffc02031b0:	69460613          	addi	a2,a2,1684 # ffffffffc0205840 <commands+0x870>
ffffffffc02031b4:	11d00593          	li	a1,285
ffffffffc02031b8:	00003517          	auipc	a0,0x3
ffffffffc02031bc:	14850513          	addi	a0,a0,328 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc02031c0:	a8cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02031c4:	00003697          	auipc	a3,0x3
ffffffffc02031c8:	28468693          	addi	a3,a3,644 # ffffffffc0206448 <default_pmm_manager+0x870>
ffffffffc02031cc:	00002617          	auipc	a2,0x2
ffffffffc02031d0:	67460613          	addi	a2,a2,1652 # ffffffffc0205840 <commands+0x870>
ffffffffc02031d4:	0eb00593          	li	a1,235
ffffffffc02031d8:	00003517          	auipc	a0,0x3
ffffffffc02031dc:	12850513          	addi	a0,a0,296 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc02031e0:	a6cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(mm != NULL);
ffffffffc02031e4:	00003697          	auipc	a3,0x3
ffffffffc02031e8:	16c68693          	addi	a3,a3,364 # ffffffffc0206350 <default_pmm_manager+0x778>
ffffffffc02031ec:	00002617          	auipc	a2,0x2
ffffffffc02031f0:	65460613          	addi	a2,a2,1620 # ffffffffc0205840 <commands+0x870>
ffffffffc02031f4:	0c500593          	li	a1,197
ffffffffc02031f8:	00003517          	auipc	a0,0x3
ffffffffc02031fc:	10850513          	addi	a0,a0,264 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203200:	a4cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203204:	00003697          	auipc	a3,0x3
ffffffffc0203208:	15c68693          	addi	a3,a3,348 # ffffffffc0206360 <default_pmm_manager+0x788>
ffffffffc020320c:	00002617          	auipc	a2,0x2
ffffffffc0203210:	63460613          	addi	a2,a2,1588 # ffffffffc0205840 <commands+0x870>
ffffffffc0203214:	0c800593          	li	a1,200
ffffffffc0203218:	00003517          	auipc	a0,0x3
ffffffffc020321c:	0e850513          	addi	a0,a0,232 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203220:	a2cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(ret==0);
ffffffffc0203224:	00003697          	auipc	a3,0x3
ffffffffc0203228:	31c68693          	addi	a3,a3,796 # ffffffffc0206540 <default_pmm_manager+0x968>
ffffffffc020322c:	00002617          	auipc	a2,0x2
ffffffffc0203230:	61460613          	addi	a2,a2,1556 # ffffffffc0205840 <commands+0x870>
ffffffffc0203234:	10300593          	li	a1,259
ffffffffc0203238:	00003517          	auipc	a0,0x3
ffffffffc020323c:	0c850513          	addi	a0,a0,200 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203240:	a0cfd0ef          	jal	ra,ffffffffc020044c <__panic>
     assert(total == nr_free_pages());
ffffffffc0203244:	00002697          	auipc	a3,0x2
ffffffffc0203248:	62c68693          	addi	a3,a3,1580 # ffffffffc0205870 <commands+0x8a0>
ffffffffc020324c:	00002617          	auipc	a2,0x2
ffffffffc0203250:	5f460613          	addi	a2,a2,1524 # ffffffffc0205840 <commands+0x870>
ffffffffc0203254:	0c000593          	li	a1,192
ffffffffc0203258:	00003517          	auipc	a0,0x3
ffffffffc020325c:	0a850513          	addi	a0,a0,168 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203260:	9ecfd0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0203264 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203264:	00012797          	auipc	a5,0x12
ffffffffc0203268:	23478793          	addi	a5,a5,564 # ffffffffc0215498 <sm>
ffffffffc020326c:	639c                	ld	a5,0(a5)
ffffffffc020326e:	0107b303          	ld	t1,16(a5)
ffffffffc0203272:	8302                	jr	t1

ffffffffc0203274 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203274:	00012797          	auipc	a5,0x12
ffffffffc0203278:	22478793          	addi	a5,a5,548 # ffffffffc0215498 <sm>
ffffffffc020327c:	639c                	ld	a5,0(a5)
ffffffffc020327e:	0207b303          	ld	t1,32(a5)
ffffffffc0203282:	8302                	jr	t1

ffffffffc0203284 <swap_out>:
{
ffffffffc0203284:	711d                	addi	sp,sp,-96
ffffffffc0203286:	ec86                	sd	ra,88(sp)
ffffffffc0203288:	e8a2                	sd	s0,80(sp)
ffffffffc020328a:	e4a6                	sd	s1,72(sp)
ffffffffc020328c:	e0ca                	sd	s2,64(sp)
ffffffffc020328e:	fc4e                	sd	s3,56(sp)
ffffffffc0203290:	f852                	sd	s4,48(sp)
ffffffffc0203292:	f456                	sd	s5,40(sp)
ffffffffc0203294:	f05a                	sd	s6,32(sp)
ffffffffc0203296:	ec5e                	sd	s7,24(sp)
ffffffffc0203298:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc020329a:	cde9                	beqz	a1,ffffffffc0203374 <swap_out+0xf0>
ffffffffc020329c:	8ab2                	mv	s5,a2
ffffffffc020329e:	892a                	mv	s2,a0
ffffffffc02032a0:	8a2e                	mv	s4,a1
ffffffffc02032a2:	4401                	li	s0,0
ffffffffc02032a4:	00012997          	auipc	s3,0x12
ffffffffc02032a8:	1f498993          	addi	s3,s3,500 # ffffffffc0215498 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032ac:	00003b17          	auipc	s6,0x3
ffffffffc02032b0:	33cb0b13          	addi	s6,s6,828 # ffffffffc02065e8 <default_pmm_manager+0xa10>
                    cprintf("SWAP: failed to save\n");
ffffffffc02032b4:	00003b97          	auipc	s7,0x3
ffffffffc02032b8:	31cb8b93          	addi	s7,s7,796 # ffffffffc02065d0 <default_pmm_manager+0x9f8>
ffffffffc02032bc:	a825                	j	ffffffffc02032f4 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032be:	67a2                	ld	a5,8(sp)
ffffffffc02032c0:	8626                	mv	a2,s1
ffffffffc02032c2:	85a2                	mv	a1,s0
ffffffffc02032c4:	7f94                	ld	a3,56(a5)
ffffffffc02032c6:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02032c8:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032ca:	82b1                	srli	a3,a3,0xc
ffffffffc02032cc:	0685                	addi	a3,a3,1
ffffffffc02032ce:	ec1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032d2:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02032d4:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032d6:	7d1c                	ld	a5,56(a0)
ffffffffc02032d8:	83b1                	srli	a5,a5,0xc
ffffffffc02032da:	0785                	addi	a5,a5,1
ffffffffc02032dc:	07a2                	slli	a5,a5,0x8
ffffffffc02032de:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02032e2:	90ffe0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02032e6:	01893503          	ld	a0,24(s2)
ffffffffc02032ea:	85a6                	mv	a1,s1
ffffffffc02032ec:	f6cff0ef          	jal	ra,ffffffffc0202a58 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02032f0:	048a0d63          	beq	s4,s0,ffffffffc020334a <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02032f4:	0009b783          	ld	a5,0(s3)
ffffffffc02032f8:	8656                	mv	a2,s5
ffffffffc02032fa:	002c                	addi	a1,sp,8
ffffffffc02032fc:	7b9c                	ld	a5,48(a5)
ffffffffc02032fe:	854a                	mv	a0,s2
ffffffffc0203300:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203302:	e12d                	bnez	a0,ffffffffc0203364 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203304:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203306:	01893503          	ld	a0,24(s2)
ffffffffc020330a:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020330c:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020330e:	85a6                	mv	a1,s1
ffffffffc0203310:	967fe0ef          	jal	ra,ffffffffc0201c76 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203314:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203316:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203318:	8b85                	andi	a5,a5,1
ffffffffc020331a:	cfb9                	beqz	a5,ffffffffc0203378 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020331c:	65a2                	ld	a1,8(sp)
ffffffffc020331e:	7d9c                	ld	a5,56(a1)
ffffffffc0203320:	83b1                	srli	a5,a5,0xc
ffffffffc0203322:	00178513          	addi	a0,a5,1
ffffffffc0203326:	0522                	slli	a0,a0,0x8
ffffffffc0203328:	5d9000ef          	jal	ra,ffffffffc0204100 <swapfs_write>
ffffffffc020332c:	d949                	beqz	a0,ffffffffc02032be <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020332e:	855e                	mv	a0,s7
ffffffffc0203330:	e5ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203334:	0009b783          	ld	a5,0(s3)
ffffffffc0203338:	6622                	ld	a2,8(sp)
ffffffffc020333a:	4681                	li	a3,0
ffffffffc020333c:	739c                	ld	a5,32(a5)
ffffffffc020333e:	85a6                	mv	a1,s1
ffffffffc0203340:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203342:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203344:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203346:	fa8a17e3          	bne	s4,s0,ffffffffc02032f4 <swap_out+0x70>
}
ffffffffc020334a:	8522                	mv	a0,s0
ffffffffc020334c:	60e6                	ld	ra,88(sp)
ffffffffc020334e:	6446                	ld	s0,80(sp)
ffffffffc0203350:	64a6                	ld	s1,72(sp)
ffffffffc0203352:	6906                	ld	s2,64(sp)
ffffffffc0203354:	79e2                	ld	s3,56(sp)
ffffffffc0203356:	7a42                	ld	s4,48(sp)
ffffffffc0203358:	7aa2                	ld	s5,40(sp)
ffffffffc020335a:	7b02                	ld	s6,32(sp)
ffffffffc020335c:	6be2                	ld	s7,24(sp)
ffffffffc020335e:	6c42                	ld	s8,16(sp)
ffffffffc0203360:	6125                	addi	sp,sp,96
ffffffffc0203362:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203364:	85a2                	mv	a1,s0
ffffffffc0203366:	00003517          	auipc	a0,0x3
ffffffffc020336a:	22250513          	addi	a0,a0,546 # ffffffffc0206588 <default_pmm_manager+0x9b0>
ffffffffc020336e:	e21fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203372:	bfe1                	j	ffffffffc020334a <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203374:	4401                	li	s0,0
ffffffffc0203376:	bfd1                	j	ffffffffc020334a <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203378:	00003697          	auipc	a3,0x3
ffffffffc020337c:	24068693          	addi	a3,a3,576 # ffffffffc02065b8 <default_pmm_manager+0x9e0>
ffffffffc0203380:	00002617          	auipc	a2,0x2
ffffffffc0203384:	4c060613          	addi	a2,a2,1216 # ffffffffc0205840 <commands+0x870>
ffffffffc0203388:	06900593          	li	a1,105
ffffffffc020338c:	00003517          	auipc	a0,0x3
ffffffffc0203390:	f7450513          	addi	a0,a0,-140 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc0203394:	8b8fd0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0203398 <swap_in>:
{
ffffffffc0203398:	7179                	addi	sp,sp,-48
ffffffffc020339a:	e84a                	sd	s2,16(sp)
ffffffffc020339c:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020339e:	4505                	li	a0,1
{
ffffffffc02033a0:	ec26                	sd	s1,24(sp)
ffffffffc02033a2:	e44e                	sd	s3,8(sp)
ffffffffc02033a4:	f406                	sd	ra,40(sp)
ffffffffc02033a6:	f022                	sd	s0,32(sp)
ffffffffc02033a8:	84ae                	mv	s1,a1
ffffffffc02033aa:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02033ac:	fbcfe0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
     assert(result!=NULL);
ffffffffc02033b0:	c129                	beqz	a0,ffffffffc02033f2 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02033b2:	842a                	mv	s0,a0
ffffffffc02033b4:	01893503          	ld	a0,24(s2)
ffffffffc02033b8:	4601                	li	a2,0
ffffffffc02033ba:	85a6                	mv	a1,s1
ffffffffc02033bc:	8bbfe0ef          	jal	ra,ffffffffc0201c76 <get_pte>
ffffffffc02033c0:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02033c2:	6108                	ld	a0,0(a0)
ffffffffc02033c4:	85a2                	mv	a1,s0
ffffffffc02033c6:	4a3000ef          	jal	ra,ffffffffc0204068 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02033ca:	00093583          	ld	a1,0(s2)
ffffffffc02033ce:	8626                	mv	a2,s1
ffffffffc02033d0:	00003517          	auipc	a0,0x3
ffffffffc02033d4:	ed050513          	addi	a0,a0,-304 # ffffffffc02062a0 <default_pmm_manager+0x6c8>
ffffffffc02033d8:	81a1                	srli	a1,a1,0x8
ffffffffc02033da:	db5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc02033de:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc02033e0:	0089b023          	sd	s0,0(s3)
}
ffffffffc02033e4:	7402                	ld	s0,32(sp)
ffffffffc02033e6:	64e2                	ld	s1,24(sp)
ffffffffc02033e8:	6942                	ld	s2,16(sp)
ffffffffc02033ea:	69a2                	ld	s3,8(sp)
ffffffffc02033ec:	4501                	li	a0,0
ffffffffc02033ee:	6145                	addi	sp,sp,48
ffffffffc02033f0:	8082                	ret
     assert(result!=NULL);
ffffffffc02033f2:	00003697          	auipc	a3,0x3
ffffffffc02033f6:	e9e68693          	addi	a3,a3,-354 # ffffffffc0206290 <default_pmm_manager+0x6b8>
ffffffffc02033fa:	00002617          	auipc	a2,0x2
ffffffffc02033fe:	44660613          	addi	a2,a2,1094 # ffffffffc0205840 <commands+0x870>
ffffffffc0203402:	07f00593          	li	a1,127
ffffffffc0203406:	00003517          	auipc	a0,0x3
ffffffffc020340a:	efa50513          	addi	a0,a0,-262 # ffffffffc0206300 <default_pmm_manager+0x728>
ffffffffc020340e:	83efd0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0203412 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203412:	00012797          	auipc	a5,0x12
ffffffffc0203416:	1be78793          	addi	a5,a5,446 # ffffffffc02155d0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020341a:	f51c                	sd	a5,40(a0)
ffffffffc020341c:	e79c                	sd	a5,8(a5)
ffffffffc020341e:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203420:	4501                	li	a0,0
ffffffffc0203422:	8082                	ret

ffffffffc0203424 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203424:	4501                	li	a0,0
ffffffffc0203426:	8082                	ret

ffffffffc0203428 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203428:	4501                	li	a0,0
ffffffffc020342a:	8082                	ret

ffffffffc020342c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020342c:	4501                	li	a0,0
ffffffffc020342e:	8082                	ret

ffffffffc0203430 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203430:	711d                	addi	sp,sp,-96
ffffffffc0203432:	fc4e                	sd	s3,56(sp)
ffffffffc0203434:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203436:	00003517          	auipc	a0,0x3
ffffffffc020343a:	1f250513          	addi	a0,a0,498 # ffffffffc0206628 <default_pmm_manager+0xa50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020343e:	698d                	lui	s3,0x3
ffffffffc0203440:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203442:	e8a2                	sd	s0,80(sp)
ffffffffc0203444:	e4a6                	sd	s1,72(sp)
ffffffffc0203446:	ec86                	sd	ra,88(sp)
ffffffffc0203448:	e0ca                	sd	s2,64(sp)
ffffffffc020344a:	f456                	sd	s5,40(sp)
ffffffffc020344c:	f05a                	sd	s6,32(sp)
ffffffffc020344e:	ec5e                	sd	s7,24(sp)
ffffffffc0203450:	e862                	sd	s8,16(sp)
ffffffffc0203452:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203454:	00012417          	auipc	s0,0x12
ffffffffc0203458:	05040413          	addi	s0,s0,80 # ffffffffc02154a4 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020345c:	d33fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203460:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203464:	4004                	lw	s1,0(s0)
ffffffffc0203466:	4791                	li	a5,4
ffffffffc0203468:	2481                	sext.w	s1,s1
ffffffffc020346a:	14f49963          	bne	s1,a5,ffffffffc02035bc <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020346e:	00003517          	auipc	a0,0x3
ffffffffc0203472:	1fa50513          	addi	a0,a0,506 # ffffffffc0206668 <default_pmm_manager+0xa90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203476:	6a85                	lui	s5,0x1
ffffffffc0203478:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020347a:	d15fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020347e:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203482:	00042903          	lw	s2,0(s0)
ffffffffc0203486:	2901                	sext.w	s2,s2
ffffffffc0203488:	2a991a63          	bne	s2,s1,ffffffffc020373c <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020348c:	00003517          	auipc	a0,0x3
ffffffffc0203490:	20450513          	addi	a0,a0,516 # ffffffffc0206690 <default_pmm_manager+0xab8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203494:	6b91                	lui	s7,0x4
ffffffffc0203496:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203498:	cf7fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020349c:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02034a0:	4004                	lw	s1,0(s0)
ffffffffc02034a2:	2481                	sext.w	s1,s1
ffffffffc02034a4:	27249c63          	bne	s1,s2,ffffffffc020371c <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034a8:	00003517          	auipc	a0,0x3
ffffffffc02034ac:	21050513          	addi	a0,a0,528 # ffffffffc02066b8 <default_pmm_manager+0xae0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034b0:	6909                	lui	s2,0x2
ffffffffc02034b2:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034b4:	cdbfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034b8:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02034bc:	401c                	lw	a5,0(s0)
ffffffffc02034be:	2781                	sext.w	a5,a5
ffffffffc02034c0:	22979e63          	bne	a5,s1,ffffffffc02036fc <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02034c4:	00003517          	auipc	a0,0x3
ffffffffc02034c8:	21c50513          	addi	a0,a0,540 # ffffffffc02066e0 <default_pmm_manager+0xb08>
ffffffffc02034cc:	cc3fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02034d0:	6795                	lui	a5,0x5
ffffffffc02034d2:	4739                	li	a4,14
ffffffffc02034d4:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02034d8:	4004                	lw	s1,0(s0)
ffffffffc02034da:	4795                	li	a5,5
ffffffffc02034dc:	2481                	sext.w	s1,s1
ffffffffc02034de:	1ef49f63          	bne	s1,a5,ffffffffc02036dc <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034e2:	00003517          	auipc	a0,0x3
ffffffffc02034e6:	1d650513          	addi	a0,a0,470 # ffffffffc02066b8 <default_pmm_manager+0xae0>
ffffffffc02034ea:	ca5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034ee:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc02034f2:	401c                	lw	a5,0(s0)
ffffffffc02034f4:	2781                	sext.w	a5,a5
ffffffffc02034f6:	1c979363          	bne	a5,s1,ffffffffc02036bc <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02034fa:	00003517          	auipc	a0,0x3
ffffffffc02034fe:	16e50513          	addi	a0,a0,366 # ffffffffc0206668 <default_pmm_manager+0xa90>
ffffffffc0203502:	c8dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203506:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020350a:	401c                	lw	a5,0(s0)
ffffffffc020350c:	4719                	li	a4,6
ffffffffc020350e:	2781                	sext.w	a5,a5
ffffffffc0203510:	18e79663          	bne	a5,a4,ffffffffc020369c <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203514:	00003517          	auipc	a0,0x3
ffffffffc0203518:	1a450513          	addi	a0,a0,420 # ffffffffc02066b8 <default_pmm_manager+0xae0>
ffffffffc020351c:	c73fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203520:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203524:	401c                	lw	a5,0(s0)
ffffffffc0203526:	471d                	li	a4,7
ffffffffc0203528:	2781                	sext.w	a5,a5
ffffffffc020352a:	14e79963          	bne	a5,a4,ffffffffc020367c <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020352e:	00003517          	auipc	a0,0x3
ffffffffc0203532:	0fa50513          	addi	a0,a0,250 # ffffffffc0206628 <default_pmm_manager+0xa50>
ffffffffc0203536:	c59fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020353a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020353e:	401c                	lw	a5,0(s0)
ffffffffc0203540:	4721                	li	a4,8
ffffffffc0203542:	2781                	sext.w	a5,a5
ffffffffc0203544:	10e79c63          	bne	a5,a4,ffffffffc020365c <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203548:	00003517          	auipc	a0,0x3
ffffffffc020354c:	14850513          	addi	a0,a0,328 # ffffffffc0206690 <default_pmm_manager+0xab8>
ffffffffc0203550:	c3ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203554:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203558:	401c                	lw	a5,0(s0)
ffffffffc020355a:	4725                	li	a4,9
ffffffffc020355c:	2781                	sext.w	a5,a5
ffffffffc020355e:	0ce79f63          	bne	a5,a4,ffffffffc020363c <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203562:	00003517          	auipc	a0,0x3
ffffffffc0203566:	17e50513          	addi	a0,a0,382 # ffffffffc02066e0 <default_pmm_manager+0xb08>
ffffffffc020356a:	c25fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020356e:	6795                	lui	a5,0x5
ffffffffc0203570:	4739                	li	a4,14
ffffffffc0203572:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203576:	4004                	lw	s1,0(s0)
ffffffffc0203578:	47a9                	li	a5,10
ffffffffc020357a:	2481                	sext.w	s1,s1
ffffffffc020357c:	0af49063          	bne	s1,a5,ffffffffc020361c <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203580:	00003517          	auipc	a0,0x3
ffffffffc0203584:	0e850513          	addi	a0,a0,232 # ffffffffc0206668 <default_pmm_manager+0xa90>
ffffffffc0203588:	c07fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020358c:	6785                	lui	a5,0x1
ffffffffc020358e:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203592:	06979563          	bne	a5,s1,ffffffffc02035fc <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203596:	401c                	lw	a5,0(s0)
ffffffffc0203598:	472d                	li	a4,11
ffffffffc020359a:	2781                	sext.w	a5,a5
ffffffffc020359c:	04e79063          	bne	a5,a4,ffffffffc02035dc <_fifo_check_swap+0x1ac>
}
ffffffffc02035a0:	60e6                	ld	ra,88(sp)
ffffffffc02035a2:	6446                	ld	s0,80(sp)
ffffffffc02035a4:	64a6                	ld	s1,72(sp)
ffffffffc02035a6:	6906                	ld	s2,64(sp)
ffffffffc02035a8:	79e2                	ld	s3,56(sp)
ffffffffc02035aa:	7a42                	ld	s4,48(sp)
ffffffffc02035ac:	7aa2                	ld	s5,40(sp)
ffffffffc02035ae:	7b02                	ld	s6,32(sp)
ffffffffc02035b0:	6be2                	ld	s7,24(sp)
ffffffffc02035b2:	6c42                	ld	s8,16(sp)
ffffffffc02035b4:	6ca2                	ld	s9,8(sp)
ffffffffc02035b6:	4501                	li	a0,0
ffffffffc02035b8:	6125                	addi	sp,sp,96
ffffffffc02035ba:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02035bc:	00003697          	auipc	a3,0x3
ffffffffc02035c0:	f0c68693          	addi	a3,a3,-244 # ffffffffc02064c8 <default_pmm_manager+0x8f0>
ffffffffc02035c4:	00002617          	auipc	a2,0x2
ffffffffc02035c8:	27c60613          	addi	a2,a2,636 # ffffffffc0205840 <commands+0x870>
ffffffffc02035cc:	05500593          	li	a1,85
ffffffffc02035d0:	00003517          	auipc	a0,0x3
ffffffffc02035d4:	08050513          	addi	a0,a0,128 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc02035d8:	e75fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==11);
ffffffffc02035dc:	00003697          	auipc	a3,0x3
ffffffffc02035e0:	1b468693          	addi	a3,a3,436 # ffffffffc0206790 <default_pmm_manager+0xbb8>
ffffffffc02035e4:	00002617          	auipc	a2,0x2
ffffffffc02035e8:	25c60613          	addi	a2,a2,604 # ffffffffc0205840 <commands+0x870>
ffffffffc02035ec:	07700593          	li	a1,119
ffffffffc02035f0:	00003517          	auipc	a0,0x3
ffffffffc02035f4:	06050513          	addi	a0,a0,96 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc02035f8:	e55fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02035fc:	00003697          	auipc	a3,0x3
ffffffffc0203600:	16c68693          	addi	a3,a3,364 # ffffffffc0206768 <default_pmm_manager+0xb90>
ffffffffc0203604:	00002617          	auipc	a2,0x2
ffffffffc0203608:	23c60613          	addi	a2,a2,572 # ffffffffc0205840 <commands+0x870>
ffffffffc020360c:	07500593          	li	a1,117
ffffffffc0203610:	00003517          	auipc	a0,0x3
ffffffffc0203614:	04050513          	addi	a0,a0,64 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc0203618:	e35fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==10);
ffffffffc020361c:	00003697          	auipc	a3,0x3
ffffffffc0203620:	13c68693          	addi	a3,a3,316 # ffffffffc0206758 <default_pmm_manager+0xb80>
ffffffffc0203624:	00002617          	auipc	a2,0x2
ffffffffc0203628:	21c60613          	addi	a2,a2,540 # ffffffffc0205840 <commands+0x870>
ffffffffc020362c:	07300593          	li	a1,115
ffffffffc0203630:	00003517          	auipc	a0,0x3
ffffffffc0203634:	02050513          	addi	a0,a0,32 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc0203638:	e15fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==9);
ffffffffc020363c:	00003697          	auipc	a3,0x3
ffffffffc0203640:	10c68693          	addi	a3,a3,268 # ffffffffc0206748 <default_pmm_manager+0xb70>
ffffffffc0203644:	00002617          	auipc	a2,0x2
ffffffffc0203648:	1fc60613          	addi	a2,a2,508 # ffffffffc0205840 <commands+0x870>
ffffffffc020364c:	07000593          	li	a1,112
ffffffffc0203650:	00003517          	auipc	a0,0x3
ffffffffc0203654:	00050513          	mv	a0,a0
ffffffffc0203658:	df5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==8);
ffffffffc020365c:	00003697          	auipc	a3,0x3
ffffffffc0203660:	0dc68693          	addi	a3,a3,220 # ffffffffc0206738 <default_pmm_manager+0xb60>
ffffffffc0203664:	00002617          	auipc	a2,0x2
ffffffffc0203668:	1dc60613          	addi	a2,a2,476 # ffffffffc0205840 <commands+0x870>
ffffffffc020366c:	06d00593          	li	a1,109
ffffffffc0203670:	00003517          	auipc	a0,0x3
ffffffffc0203674:	fe050513          	addi	a0,a0,-32 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc0203678:	dd5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==7);
ffffffffc020367c:	00003697          	auipc	a3,0x3
ffffffffc0203680:	0ac68693          	addi	a3,a3,172 # ffffffffc0206728 <default_pmm_manager+0xb50>
ffffffffc0203684:	00002617          	auipc	a2,0x2
ffffffffc0203688:	1bc60613          	addi	a2,a2,444 # ffffffffc0205840 <commands+0x870>
ffffffffc020368c:	06a00593          	li	a1,106
ffffffffc0203690:	00003517          	auipc	a0,0x3
ffffffffc0203694:	fc050513          	addi	a0,a0,-64 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc0203698:	db5fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==6);
ffffffffc020369c:	00003697          	auipc	a3,0x3
ffffffffc02036a0:	07c68693          	addi	a3,a3,124 # ffffffffc0206718 <default_pmm_manager+0xb40>
ffffffffc02036a4:	00002617          	auipc	a2,0x2
ffffffffc02036a8:	19c60613          	addi	a2,a2,412 # ffffffffc0205840 <commands+0x870>
ffffffffc02036ac:	06700593          	li	a1,103
ffffffffc02036b0:	00003517          	auipc	a0,0x3
ffffffffc02036b4:	fa050513          	addi	a0,a0,-96 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc02036b8:	d95fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==5);
ffffffffc02036bc:	00003697          	auipc	a3,0x3
ffffffffc02036c0:	04c68693          	addi	a3,a3,76 # ffffffffc0206708 <default_pmm_manager+0xb30>
ffffffffc02036c4:	00002617          	auipc	a2,0x2
ffffffffc02036c8:	17c60613          	addi	a2,a2,380 # ffffffffc0205840 <commands+0x870>
ffffffffc02036cc:	06400593          	li	a1,100
ffffffffc02036d0:	00003517          	auipc	a0,0x3
ffffffffc02036d4:	f8050513          	addi	a0,a0,-128 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc02036d8:	d75fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==5);
ffffffffc02036dc:	00003697          	auipc	a3,0x3
ffffffffc02036e0:	02c68693          	addi	a3,a3,44 # ffffffffc0206708 <default_pmm_manager+0xb30>
ffffffffc02036e4:	00002617          	auipc	a2,0x2
ffffffffc02036e8:	15c60613          	addi	a2,a2,348 # ffffffffc0205840 <commands+0x870>
ffffffffc02036ec:	06100593          	li	a1,97
ffffffffc02036f0:	00003517          	auipc	a0,0x3
ffffffffc02036f4:	f6050513          	addi	a0,a0,-160 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc02036f8:	d55fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==4);
ffffffffc02036fc:	00003697          	auipc	a3,0x3
ffffffffc0203700:	dcc68693          	addi	a3,a3,-564 # ffffffffc02064c8 <default_pmm_manager+0x8f0>
ffffffffc0203704:	00002617          	auipc	a2,0x2
ffffffffc0203708:	13c60613          	addi	a2,a2,316 # ffffffffc0205840 <commands+0x870>
ffffffffc020370c:	05e00593          	li	a1,94
ffffffffc0203710:	00003517          	auipc	a0,0x3
ffffffffc0203714:	f4050513          	addi	a0,a0,-192 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc0203718:	d35fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==4);
ffffffffc020371c:	00003697          	auipc	a3,0x3
ffffffffc0203720:	dac68693          	addi	a3,a3,-596 # ffffffffc02064c8 <default_pmm_manager+0x8f0>
ffffffffc0203724:	00002617          	auipc	a2,0x2
ffffffffc0203728:	11c60613          	addi	a2,a2,284 # ffffffffc0205840 <commands+0x870>
ffffffffc020372c:	05b00593          	li	a1,91
ffffffffc0203730:	00003517          	auipc	a0,0x3
ffffffffc0203734:	f2050513          	addi	a0,a0,-224 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc0203738:	d15fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgfault_num==4);
ffffffffc020373c:	00003697          	auipc	a3,0x3
ffffffffc0203740:	d8c68693          	addi	a3,a3,-628 # ffffffffc02064c8 <default_pmm_manager+0x8f0>
ffffffffc0203744:	00002617          	auipc	a2,0x2
ffffffffc0203748:	0fc60613          	addi	a2,a2,252 # ffffffffc0205840 <commands+0x870>
ffffffffc020374c:	05800593          	li	a1,88
ffffffffc0203750:	00003517          	auipc	a0,0x3
ffffffffc0203754:	f0050513          	addi	a0,a0,-256 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc0203758:	cf5fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020375c <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020375c:	7518                	ld	a4,40(a0)
{
ffffffffc020375e:	1141                	addi	sp,sp,-16
ffffffffc0203760:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203762:	c731                	beqz	a4,ffffffffc02037ae <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc0203764:	e60d                	bnez	a2,ffffffffc020378e <_fifo_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc0203766:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0203768:	00f70d63          	beq	a4,a5,ffffffffc0203782 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020376c:	6394                	ld	a3,0(a5)
ffffffffc020376e:	6798                	ld	a4,8(a5)
}
ffffffffc0203770:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203772:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203776:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203778:	e314                	sd	a3,0(a4)
ffffffffc020377a:	e19c                	sd	a5,0(a1)
}
ffffffffc020377c:	4501                	li	a0,0
ffffffffc020377e:	0141                	addi	sp,sp,16
ffffffffc0203780:	8082                	ret
ffffffffc0203782:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0203784:	0005b023          	sd	zero,0(a1) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
}
ffffffffc0203788:	4501                	li	a0,0
ffffffffc020378a:	0141                	addi	sp,sp,16
ffffffffc020378c:	8082                	ret
     assert(in_tick==0);
ffffffffc020378e:	00003697          	auipc	a3,0x3
ffffffffc0203792:	04268693          	addi	a3,a3,66 # ffffffffc02067d0 <default_pmm_manager+0xbf8>
ffffffffc0203796:	00002617          	auipc	a2,0x2
ffffffffc020379a:	0aa60613          	addi	a2,a2,170 # ffffffffc0205840 <commands+0x870>
ffffffffc020379e:	04200593          	li	a1,66
ffffffffc02037a2:	00003517          	auipc	a0,0x3
ffffffffc02037a6:	eae50513          	addi	a0,a0,-338 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc02037aa:	ca3fc0ef          	jal	ra,ffffffffc020044c <__panic>
         assert(head != NULL);
ffffffffc02037ae:	00003697          	auipc	a3,0x3
ffffffffc02037b2:	01268693          	addi	a3,a3,18 # ffffffffc02067c0 <default_pmm_manager+0xbe8>
ffffffffc02037b6:	00002617          	auipc	a2,0x2
ffffffffc02037ba:	08a60613          	addi	a2,a2,138 # ffffffffc0205840 <commands+0x870>
ffffffffc02037be:	04100593          	li	a1,65
ffffffffc02037c2:	00003517          	auipc	a0,0x3
ffffffffc02037c6:	e8e50513          	addi	a0,a0,-370 # ffffffffc0206650 <default_pmm_manager+0xa78>
ffffffffc02037ca:	c83fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02037ce <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02037ce:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02037d2:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02037d4:	cb09                	beqz	a4,ffffffffc02037e6 <_fifo_map_swappable+0x18>
ffffffffc02037d6:	cb81                	beqz	a5,ffffffffc02037e6 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm, listelm->next);
ffffffffc02037d8:	6794                	ld	a3,8(a5)
}
ffffffffc02037da:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc02037dc:	e298                	sd	a4,0(a3)
ffffffffc02037de:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02037e0:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc02037e2:	f61c                	sd	a5,40(a2)
ffffffffc02037e4:	8082                	ret
{
ffffffffc02037e6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02037e8:	00003697          	auipc	a3,0x3
ffffffffc02037ec:	fb868693          	addi	a3,a3,-72 # ffffffffc02067a0 <default_pmm_manager+0xbc8>
ffffffffc02037f0:	00002617          	auipc	a2,0x2
ffffffffc02037f4:	05060613          	addi	a2,a2,80 # ffffffffc0205840 <commands+0x870>
ffffffffc02037f8:	03200593          	li	a1,50
ffffffffc02037fc:	00003517          	auipc	a0,0x3
ffffffffc0203800:	e5450513          	addi	a0,a0,-428 # ffffffffc0206650 <default_pmm_manager+0xa78>
{
ffffffffc0203804:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203806:	c47fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020380a <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020380a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020380c:	00003697          	auipc	a3,0x3
ffffffffc0203810:	fec68693          	addi	a3,a3,-20 # ffffffffc02067f8 <default_pmm_manager+0xc20>
ffffffffc0203814:	00002617          	auipc	a2,0x2
ffffffffc0203818:	02c60613          	addi	a2,a2,44 # ffffffffc0205840 <commands+0x870>
ffffffffc020381c:	07e00593          	li	a1,126
ffffffffc0203820:	00003517          	auipc	a0,0x3
ffffffffc0203824:	ff850513          	addi	a0,a0,-8 # ffffffffc0206818 <default_pmm_manager+0xc40>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203828:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020382a:	c23fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020382e <mm_create>:
mm_create(void) {
ffffffffc020382e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203830:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203834:	e022                	sd	s0,0(sp)
ffffffffc0203836:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203838:	938fe0ef          	jal	ra,ffffffffc0201970 <kmalloc>
ffffffffc020383c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020383e:	c115                	beqz	a0,ffffffffc0203862 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203840:	00012797          	auipc	a5,0x12
ffffffffc0203844:	c6078793          	addi	a5,a5,-928 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0203848:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020384a:	e408                	sd	a0,8(s0)
ffffffffc020384c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020384e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203852:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203856:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020385a:	2781                	sext.w	a5,a5
ffffffffc020385c:	eb81                	bnez	a5,ffffffffc020386c <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc020385e:	02053423          	sd	zero,40(a0)
}
ffffffffc0203862:	8522                	mv	a0,s0
ffffffffc0203864:	60a2                	ld	ra,8(sp)
ffffffffc0203866:	6402                	ld	s0,0(sp)
ffffffffc0203868:	0141                	addi	sp,sp,16
ffffffffc020386a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020386c:	9f9ff0ef          	jal	ra,ffffffffc0203264 <swap_init_mm>
}
ffffffffc0203870:	8522                	mv	a0,s0
ffffffffc0203872:	60a2                	ld	ra,8(sp)
ffffffffc0203874:	6402                	ld	s0,0(sp)
ffffffffc0203876:	0141                	addi	sp,sp,16
ffffffffc0203878:	8082                	ret

ffffffffc020387a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020387a:	1101                	addi	sp,sp,-32
ffffffffc020387c:	e04a                	sd	s2,0(sp)
ffffffffc020387e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203880:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203884:	e822                	sd	s0,16(sp)
ffffffffc0203886:	e426                	sd	s1,8(sp)
ffffffffc0203888:	ec06                	sd	ra,24(sp)
ffffffffc020388a:	84ae                	mv	s1,a1
ffffffffc020388c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020388e:	8e2fe0ef          	jal	ra,ffffffffc0201970 <kmalloc>
    if (vma != NULL) {
ffffffffc0203892:	c509                	beqz	a0,ffffffffc020389c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203894:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203898:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020389a:	cd00                	sw	s0,24(a0)
}
ffffffffc020389c:	60e2                	ld	ra,24(sp)
ffffffffc020389e:	6442                	ld	s0,16(sp)
ffffffffc02038a0:	64a2                	ld	s1,8(sp)
ffffffffc02038a2:	6902                	ld	s2,0(sp)
ffffffffc02038a4:	6105                	addi	sp,sp,32
ffffffffc02038a6:	8082                	ret

ffffffffc02038a8 <find_vma>:
    if (mm != NULL) {
ffffffffc02038a8:	c51d                	beqz	a0,ffffffffc02038d6 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02038aa:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02038ac:	c781                	beqz	a5,ffffffffc02038b4 <find_vma+0xc>
ffffffffc02038ae:	6798                	ld	a4,8(a5)
ffffffffc02038b0:	02e5f663          	bgeu	a1,a4,ffffffffc02038dc <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02038b4:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02038b6:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02038b8:	00f50f63          	beq	a0,a5,ffffffffc02038d6 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02038bc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02038c0:	fee5ebe3          	bltu	a1,a4,ffffffffc02038b6 <find_vma+0xe>
ffffffffc02038c4:	ff07b703          	ld	a4,-16(a5)
ffffffffc02038c8:	fee5f7e3          	bgeu	a1,a4,ffffffffc02038b6 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02038cc:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02038ce:	c781                	beqz	a5,ffffffffc02038d6 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02038d0:	e91c                	sd	a5,16(a0)
}
ffffffffc02038d2:	853e                	mv	a0,a5
ffffffffc02038d4:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02038d6:	4781                	li	a5,0
}
ffffffffc02038d8:	853e                	mv	a0,a5
ffffffffc02038da:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02038dc:	6b98                	ld	a4,16(a5)
ffffffffc02038de:	fce5fbe3          	bgeu	a1,a4,ffffffffc02038b4 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02038e2:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02038e4:	b7fd                	j	ffffffffc02038d2 <find_vma+0x2a>

ffffffffc02038e6 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038e6:	6590                	ld	a2,8(a1)
ffffffffc02038e8:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02038ec:	1141                	addi	sp,sp,-16
ffffffffc02038ee:	e406                	sd	ra,8(sp)
ffffffffc02038f0:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038f2:	01066863          	bltu	a2,a6,ffffffffc0203902 <insert_vma_struct+0x1c>
ffffffffc02038f6:	a8b9                	j	ffffffffc0203954 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02038f8:	fe87b683          	ld	a3,-24(a5)
ffffffffc02038fc:	04d66763          	bltu	a2,a3,ffffffffc020394a <insert_vma_struct+0x64>
ffffffffc0203900:	873e                	mv	a4,a5
ffffffffc0203902:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203904:	fef51ae3          	bne	a0,a5,ffffffffc02038f8 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203908:	02a70463          	beq	a4,a0,ffffffffc0203930 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020390c:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203910:	fe873883          	ld	a7,-24(a4)
ffffffffc0203914:	08d8f063          	bgeu	a7,a3,ffffffffc0203994 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203918:	04d66e63          	bltu	a2,a3,ffffffffc0203974 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc020391c:	00f50a63          	beq	a0,a5,ffffffffc0203930 <insert_vma_struct+0x4a>
ffffffffc0203920:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203924:	0506e863          	bltu	a3,a6,ffffffffc0203974 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203928:	ff07b603          	ld	a2,-16(a5)
ffffffffc020392c:	02c6f263          	bgeu	a3,a2,ffffffffc0203950 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0203930:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203932:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203934:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203938:	e390                	sd	a2,0(a5)
ffffffffc020393a:	e710                	sd	a2,8(a4)
}
ffffffffc020393c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020393e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203940:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203942:	2685                	addiw	a3,a3,1
ffffffffc0203944:	d114                	sw	a3,32(a0)
}
ffffffffc0203946:	0141                	addi	sp,sp,16
ffffffffc0203948:	8082                	ret
    if (le_prev != list) {
ffffffffc020394a:	fca711e3          	bne	a4,a0,ffffffffc020390c <insert_vma_struct+0x26>
ffffffffc020394e:	bfd9                	j	ffffffffc0203924 <insert_vma_struct+0x3e>
ffffffffc0203950:	ebbff0ef          	jal	ra,ffffffffc020380a <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203954:	00003697          	auipc	a3,0x3
ffffffffc0203958:	f9468693          	addi	a3,a3,-108 # ffffffffc02068e8 <default_pmm_manager+0xd10>
ffffffffc020395c:	00002617          	auipc	a2,0x2
ffffffffc0203960:	ee460613          	addi	a2,a2,-284 # ffffffffc0205840 <commands+0x870>
ffffffffc0203964:	08500593          	li	a1,133
ffffffffc0203968:	00003517          	auipc	a0,0x3
ffffffffc020396c:	eb050513          	addi	a0,a0,-336 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203970:	addfc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203974:	00003697          	auipc	a3,0x3
ffffffffc0203978:	fb468693          	addi	a3,a3,-76 # ffffffffc0206928 <default_pmm_manager+0xd50>
ffffffffc020397c:	00002617          	auipc	a2,0x2
ffffffffc0203980:	ec460613          	addi	a2,a2,-316 # ffffffffc0205840 <commands+0x870>
ffffffffc0203984:	07d00593          	li	a1,125
ffffffffc0203988:	00003517          	auipc	a0,0x3
ffffffffc020398c:	e9050513          	addi	a0,a0,-368 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203990:	abdfc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203994:	00003697          	auipc	a3,0x3
ffffffffc0203998:	f7468693          	addi	a3,a3,-140 # ffffffffc0206908 <default_pmm_manager+0xd30>
ffffffffc020399c:	00002617          	auipc	a2,0x2
ffffffffc02039a0:	ea460613          	addi	a2,a2,-348 # ffffffffc0205840 <commands+0x870>
ffffffffc02039a4:	07c00593          	li	a1,124
ffffffffc02039a8:	00003517          	auipc	a0,0x3
ffffffffc02039ac:	e7050513          	addi	a0,a0,-400 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc02039b0:	a9dfc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02039b4 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02039b4:	1141                	addi	sp,sp,-16
ffffffffc02039b6:	e022                	sd	s0,0(sp)
ffffffffc02039b8:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02039ba:	6508                	ld	a0,8(a0)
ffffffffc02039bc:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02039be:	00a40c63          	beq	s0,a0,ffffffffc02039d6 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc02039c2:	6118                	ld	a4,0(a0)
ffffffffc02039c4:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02039c6:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02039c8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02039ca:	e398                	sd	a4,0(a5)
ffffffffc02039cc:	860fe0ef          	jal	ra,ffffffffc0201a2c <kfree>
    return listelm->next;
ffffffffc02039d0:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02039d2:	fea418e3          	bne	s0,a0,ffffffffc02039c2 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc02039d6:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02039d8:	6402                	ld	s0,0(sp)
ffffffffc02039da:	60a2                	ld	ra,8(sp)
ffffffffc02039dc:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02039de:	84efe06f          	j	ffffffffc0201a2c <kfree>

ffffffffc02039e2 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02039e2:	7139                	addi	sp,sp,-64
ffffffffc02039e4:	f822                	sd	s0,48(sp)
ffffffffc02039e6:	f426                	sd	s1,40(sp)
ffffffffc02039e8:	fc06                	sd	ra,56(sp)
ffffffffc02039ea:	f04a                	sd	s2,32(sp)
ffffffffc02039ec:	ec4e                	sd	s3,24(sp)
ffffffffc02039ee:	e852                	sd	s4,16(sp)
ffffffffc02039f0:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc02039f2:	e3dff0ef          	jal	ra,ffffffffc020382e <mm_create>
    assert(mm != NULL);
ffffffffc02039f6:	842a                	mv	s0,a0
ffffffffc02039f8:	03200493          	li	s1,50
ffffffffc02039fc:	e919                	bnez	a0,ffffffffc0203a12 <vmm_init+0x30>
ffffffffc02039fe:	a989                	j	ffffffffc0203e50 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0203a00:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a02:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a04:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a08:	14ed                	addi	s1,s1,-5
ffffffffc0203a0a:	8522                	mv	a0,s0
ffffffffc0203a0c:	edbff0ef          	jal	ra,ffffffffc02038e6 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a10:	c88d                	beqz	s1,ffffffffc0203a42 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a12:	03000513          	li	a0,48
ffffffffc0203a16:	f5bfd0ef          	jal	ra,ffffffffc0201970 <kmalloc>
ffffffffc0203a1a:	85aa                	mv	a1,a0
ffffffffc0203a1c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203a20:	f165                	bnez	a0,ffffffffc0203a00 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0203a22:	00003697          	auipc	a3,0x3
ffffffffc0203a26:	96668693          	addi	a3,a3,-1690 # ffffffffc0206388 <default_pmm_manager+0x7b0>
ffffffffc0203a2a:	00002617          	auipc	a2,0x2
ffffffffc0203a2e:	e1660613          	addi	a2,a2,-490 # ffffffffc0205840 <commands+0x870>
ffffffffc0203a32:	0c900593          	li	a1,201
ffffffffc0203a36:	00003517          	auipc	a0,0x3
ffffffffc0203a3a:	de250513          	addi	a0,a0,-542 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203a3e:	a0ffc0ef          	jal	ra,ffffffffc020044c <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a42:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a46:	1f900913          	li	s2,505
ffffffffc0203a4a:	a819                	j	ffffffffc0203a60 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0203a4c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a4e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a50:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a54:	0495                	addi	s1,s1,5
ffffffffc0203a56:	8522                	mv	a0,s0
ffffffffc0203a58:	e8fff0ef          	jal	ra,ffffffffc02038e6 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a5c:	03248a63          	beq	s1,s2,ffffffffc0203a90 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a60:	03000513          	li	a0,48
ffffffffc0203a64:	f0dfd0ef          	jal	ra,ffffffffc0201970 <kmalloc>
ffffffffc0203a68:	85aa                	mv	a1,a0
ffffffffc0203a6a:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203a6e:	fd79                	bnez	a0,ffffffffc0203a4c <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0203a70:	00003697          	auipc	a3,0x3
ffffffffc0203a74:	91868693          	addi	a3,a3,-1768 # ffffffffc0206388 <default_pmm_manager+0x7b0>
ffffffffc0203a78:	00002617          	auipc	a2,0x2
ffffffffc0203a7c:	dc860613          	addi	a2,a2,-568 # ffffffffc0205840 <commands+0x870>
ffffffffc0203a80:	0cf00593          	li	a1,207
ffffffffc0203a84:	00003517          	auipc	a0,0x3
ffffffffc0203a88:	d9450513          	addi	a0,a0,-620 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203a8c:	9c1fc0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc0203a90:	6418                	ld	a4,8(s0)
ffffffffc0203a92:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203a94:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203a98:	2ee40063          	beq	s0,a4,ffffffffc0203d78 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a9c:	fe873603          	ld	a2,-24(a4)
ffffffffc0203aa0:	ffe78693          	addi	a3,a5,-2
ffffffffc0203aa4:	24d61a63          	bne	a2,a3,ffffffffc0203cf8 <vmm_init+0x316>
ffffffffc0203aa8:	ff073683          	ld	a3,-16(a4)
ffffffffc0203aac:	24f69663          	bne	a3,a5,ffffffffc0203cf8 <vmm_init+0x316>
ffffffffc0203ab0:	0795                	addi	a5,a5,5
ffffffffc0203ab2:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203ab4:	feb792e3          	bne	a5,a1,ffffffffc0203a98 <vmm_init+0xb6>
ffffffffc0203ab8:	491d                	li	s2,7
ffffffffc0203aba:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203abc:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203ac0:	85a6                	mv	a1,s1
ffffffffc0203ac2:	8522                	mv	a0,s0
ffffffffc0203ac4:	de5ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203ac8:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203aca:	30050763          	beqz	a0,ffffffffc0203dd8 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203ace:	00148593          	addi	a1,s1,1
ffffffffc0203ad2:	8522                	mv	a0,s0
ffffffffc0203ad4:	dd5ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203ad8:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203ada:	2c050f63          	beqz	a0,ffffffffc0203db8 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203ade:	85ca                	mv	a1,s2
ffffffffc0203ae0:	8522                	mv	a0,s0
ffffffffc0203ae2:	dc7ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203ae6:	2a051963          	bnez	a0,ffffffffc0203d98 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203aea:	00348593          	addi	a1,s1,3
ffffffffc0203aee:	8522                	mv	a0,s0
ffffffffc0203af0:	db9ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203af4:	32051263          	bnez	a0,ffffffffc0203e18 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203af8:	00448593          	addi	a1,s1,4
ffffffffc0203afc:	8522                	mv	a0,s0
ffffffffc0203afe:	dabff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203b02:	2e051b63          	bnez	a0,ffffffffc0203df8 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b06:	008a3783          	ld	a5,8(s4)
ffffffffc0203b0a:	20979763          	bne	a5,s1,ffffffffc0203d18 <vmm_init+0x336>
ffffffffc0203b0e:	010a3783          	ld	a5,16(s4)
ffffffffc0203b12:	21279363          	bne	a5,s2,ffffffffc0203d18 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b16:	0089b783          	ld	a5,8(s3)
ffffffffc0203b1a:	20979f63          	bne	a5,s1,ffffffffc0203d38 <vmm_init+0x356>
ffffffffc0203b1e:	0109b783          	ld	a5,16(s3)
ffffffffc0203b22:	21279b63          	bne	a5,s2,ffffffffc0203d38 <vmm_init+0x356>
ffffffffc0203b26:	0495                	addi	s1,s1,5
ffffffffc0203b28:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b2a:	f9549be3          	bne	s1,s5,ffffffffc0203ac0 <vmm_init+0xde>
ffffffffc0203b2e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203b30:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203b32:	85a6                	mv	a1,s1
ffffffffc0203b34:	8522                	mv	a0,s0
ffffffffc0203b36:	d73ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203b3a:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203b3e:	c90d                	beqz	a0,ffffffffc0203b70 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203b40:	6914                	ld	a3,16(a0)
ffffffffc0203b42:	6510                	ld	a2,8(a0)
ffffffffc0203b44:	00003517          	auipc	a0,0x3
ffffffffc0203b48:	f0450513          	addi	a0,a0,-252 # ffffffffc0206a48 <default_pmm_manager+0xe70>
ffffffffc0203b4c:	e42fc0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203b50:	00003697          	auipc	a3,0x3
ffffffffc0203b54:	f2068693          	addi	a3,a3,-224 # ffffffffc0206a70 <default_pmm_manager+0xe98>
ffffffffc0203b58:	00002617          	auipc	a2,0x2
ffffffffc0203b5c:	ce860613          	addi	a2,a2,-792 # ffffffffc0205840 <commands+0x870>
ffffffffc0203b60:	0f100593          	li	a1,241
ffffffffc0203b64:	00003517          	auipc	a0,0x3
ffffffffc0203b68:	cb450513          	addi	a0,a0,-844 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203b6c:	8e1fc0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc0203b70:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203b72:	fd2490e3          	bne	s1,s2,ffffffffc0203b32 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0203b76:	8522                	mv	a0,s0
ffffffffc0203b78:	e3dff0ef          	jal	ra,ffffffffc02039b4 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203b7c:	00003517          	auipc	a0,0x3
ffffffffc0203b80:	f0c50513          	addi	a0,a0,-244 # ffffffffc0206a88 <default_pmm_manager+0xeb0>
ffffffffc0203b84:	e0afc0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203b88:	8aefe0ef          	jal	ra,ffffffffc0201c36 <nr_free_pages>
ffffffffc0203b8c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203b8e:	ca1ff0ef          	jal	ra,ffffffffc020382e <mm_create>
ffffffffc0203b92:	00012797          	auipc	a5,0x12
ffffffffc0203b96:	a4a7b723          	sd	a0,-1458(a5) # ffffffffc02155e0 <check_mm_struct>
ffffffffc0203b9a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0203b9c:	36050663          	beqz	a0,ffffffffc0203f08 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203ba0:	00012797          	auipc	a5,0x12
ffffffffc0203ba4:	8e878793          	addi	a5,a5,-1816 # ffffffffc0215488 <boot_pgdir>
ffffffffc0203ba8:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203bac:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203bb0:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203bb4:	2c079e63          	bnez	a5,ffffffffc0203e90 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203bb8:	03000513          	li	a0,48
ffffffffc0203bbc:	db5fd0ef          	jal	ra,ffffffffc0201970 <kmalloc>
ffffffffc0203bc0:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0203bc2:	18050b63          	beqz	a0,ffffffffc0203d58 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0203bc6:	002007b7          	lui	a5,0x200
ffffffffc0203bca:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0203bcc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203bce:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203bd0:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203bd2:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0203bd4:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203bd8:	d0fff0ef          	jal	ra,ffffffffc02038e6 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203bdc:	10000593          	li	a1,256
ffffffffc0203be0:	8526                	mv	a0,s1
ffffffffc0203be2:	cc7ff0ef          	jal	ra,ffffffffc02038a8 <find_vma>
ffffffffc0203be6:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203bea:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203bee:	2ca41163          	bne	s0,a0,ffffffffc0203eb0 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0203bf2:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203bf6:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203bf8:	fee79de3          	bne	a5,a4,ffffffffc0203bf2 <vmm_init+0x210>
        sum += i;
ffffffffc0203bfc:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203bfe:	10000793          	li	a5,256
        sum += i;
ffffffffc0203c02:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203c06:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203c0a:	0007c683          	lbu	a3,0(a5)
ffffffffc0203c0e:	0785                	addi	a5,a5,1
ffffffffc0203c10:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203c12:	fec79ce3          	bne	a5,a2,ffffffffc0203c0a <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0203c16:	2c071963          	bnez	a4,ffffffffc0203ee8 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c1a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c1e:	00012a97          	auipc	s5,0x12
ffffffffc0203c22:	872a8a93          	addi	s5,s5,-1934 # ffffffffc0215490 <npage>
ffffffffc0203c26:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c2a:	078a                	slli	a5,a5,0x2
ffffffffc0203c2c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c2e:	20e7f563          	bgeu	a5,a4,ffffffffc0203e38 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c32:	00003697          	auipc	a3,0x3
ffffffffc0203c36:	3ae68693          	addi	a3,a3,942 # ffffffffc0206fe0 <nbase>
ffffffffc0203c3a:	0006ba03          	ld	s4,0(a3)
ffffffffc0203c3e:	414786b3          	sub	a3,a5,s4
ffffffffc0203c42:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203c44:	8699                	srai	a3,a3,0x6
ffffffffc0203c46:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203c48:	00c69793          	slli	a5,a3,0xc
ffffffffc0203c4c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c4e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203c50:	28e7f063          	bgeu	a5,a4,ffffffffc0203ed0 <vmm_init+0x4ee>
ffffffffc0203c54:	00012797          	auipc	a5,0x12
ffffffffc0203c58:	89c78793          	addi	a5,a5,-1892 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0203c5c:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203c5e:	4581                	li	a1,0
ffffffffc0203c60:	854a                	mv	a0,s2
ffffffffc0203c62:	9436                	add	s0,s0,a3
ffffffffc0203c64:	a3cfe0ef          	jal	ra,ffffffffc0201ea0 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c68:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203c6a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c6e:	078a                	slli	a5,a5,0x2
ffffffffc0203c70:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c72:	1ce7f363          	bgeu	a5,a4,ffffffffc0203e38 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c76:	00012417          	auipc	s0,0x12
ffffffffc0203c7a:	88a40413          	addi	s0,s0,-1910 # ffffffffc0215500 <pages>
ffffffffc0203c7e:	6008                	ld	a0,0(s0)
ffffffffc0203c80:	414787b3          	sub	a5,a5,s4
ffffffffc0203c84:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203c86:	953e                	add	a0,a0,a5
ffffffffc0203c88:	4585                	li	a1,1
ffffffffc0203c8a:	f67fd0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c8e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c92:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c96:	078a                	slli	a5,a5,0x2
ffffffffc0203c98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c9a:	18e7ff63          	bgeu	a5,a4,ffffffffc0203e38 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c9e:	6008                	ld	a0,0(s0)
ffffffffc0203ca0:	414787b3          	sub	a5,a5,s4
ffffffffc0203ca4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203ca6:	4585                	li	a1,1
ffffffffc0203ca8:	953e                	add	a0,a0,a5
ffffffffc0203caa:	f47fd0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    pgdir[0] = 0;
ffffffffc0203cae:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203cb2:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203cb6:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0203cba:	8526                	mv	a0,s1
ffffffffc0203cbc:	cf9ff0ef          	jal	ra,ffffffffc02039b4 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203cc0:	00012797          	auipc	a5,0x12
ffffffffc0203cc4:	9207b023          	sd	zero,-1760(a5) # ffffffffc02155e0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cc8:	f6ffd0ef          	jal	ra,ffffffffc0201c36 <nr_free_pages>
ffffffffc0203ccc:	1aa99263          	bne	s3,a0,ffffffffc0203e70 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203cd0:	00003517          	auipc	a0,0x3
ffffffffc0203cd4:	e4850513          	addi	a0,a0,-440 # ffffffffc0206b18 <default_pmm_manager+0xf40>
ffffffffc0203cd8:	cb6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203cdc:	7442                	ld	s0,48(sp)
ffffffffc0203cde:	70e2                	ld	ra,56(sp)
ffffffffc0203ce0:	74a2                	ld	s1,40(sp)
ffffffffc0203ce2:	7902                	ld	s2,32(sp)
ffffffffc0203ce4:	69e2                	ld	s3,24(sp)
ffffffffc0203ce6:	6a42                	ld	s4,16(sp)
ffffffffc0203ce8:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203cea:	00003517          	auipc	a0,0x3
ffffffffc0203cee:	e4e50513          	addi	a0,a0,-434 # ffffffffc0206b38 <default_pmm_manager+0xf60>
}
ffffffffc0203cf2:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203cf4:	c9afc06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203cf8:	00003697          	auipc	a3,0x3
ffffffffc0203cfc:	c6868693          	addi	a3,a3,-920 # ffffffffc0206960 <default_pmm_manager+0xd88>
ffffffffc0203d00:	00002617          	auipc	a2,0x2
ffffffffc0203d04:	b4060613          	addi	a2,a2,-1216 # ffffffffc0205840 <commands+0x870>
ffffffffc0203d08:	0d800593          	li	a1,216
ffffffffc0203d0c:	00003517          	auipc	a0,0x3
ffffffffc0203d10:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203d14:	f38fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203d18:	00003697          	auipc	a3,0x3
ffffffffc0203d1c:	cd068693          	addi	a3,a3,-816 # ffffffffc02069e8 <default_pmm_manager+0xe10>
ffffffffc0203d20:	00002617          	auipc	a2,0x2
ffffffffc0203d24:	b2060613          	addi	a2,a2,-1248 # ffffffffc0205840 <commands+0x870>
ffffffffc0203d28:	0e800593          	li	a1,232
ffffffffc0203d2c:	00003517          	auipc	a0,0x3
ffffffffc0203d30:	aec50513          	addi	a0,a0,-1300 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203d34:	f18fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203d38:	00003697          	auipc	a3,0x3
ffffffffc0203d3c:	ce068693          	addi	a3,a3,-800 # ffffffffc0206a18 <default_pmm_manager+0xe40>
ffffffffc0203d40:	00002617          	auipc	a2,0x2
ffffffffc0203d44:	b0060613          	addi	a2,a2,-1280 # ffffffffc0205840 <commands+0x870>
ffffffffc0203d48:	0e900593          	li	a1,233
ffffffffc0203d4c:	00003517          	auipc	a0,0x3
ffffffffc0203d50:	acc50513          	addi	a0,a0,-1332 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203d54:	ef8fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(vma != NULL);
ffffffffc0203d58:	00002697          	auipc	a3,0x2
ffffffffc0203d5c:	63068693          	addi	a3,a3,1584 # ffffffffc0206388 <default_pmm_manager+0x7b0>
ffffffffc0203d60:	00002617          	auipc	a2,0x2
ffffffffc0203d64:	ae060613          	addi	a2,a2,-1312 # ffffffffc0205840 <commands+0x870>
ffffffffc0203d68:	10800593          	li	a1,264
ffffffffc0203d6c:	00003517          	auipc	a0,0x3
ffffffffc0203d70:	aac50513          	addi	a0,a0,-1364 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203d74:	ed8fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203d78:	00003697          	auipc	a3,0x3
ffffffffc0203d7c:	bd068693          	addi	a3,a3,-1072 # ffffffffc0206948 <default_pmm_manager+0xd70>
ffffffffc0203d80:	00002617          	auipc	a2,0x2
ffffffffc0203d84:	ac060613          	addi	a2,a2,-1344 # ffffffffc0205840 <commands+0x870>
ffffffffc0203d88:	0d600593          	li	a1,214
ffffffffc0203d8c:	00003517          	auipc	a0,0x3
ffffffffc0203d90:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203d94:	eb8fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma3 == NULL);
ffffffffc0203d98:	00003697          	auipc	a3,0x3
ffffffffc0203d9c:	c2068693          	addi	a3,a3,-992 # ffffffffc02069b8 <default_pmm_manager+0xde0>
ffffffffc0203da0:	00002617          	auipc	a2,0x2
ffffffffc0203da4:	aa060613          	addi	a2,a2,-1376 # ffffffffc0205840 <commands+0x870>
ffffffffc0203da8:	0e200593          	li	a1,226
ffffffffc0203dac:	00003517          	auipc	a0,0x3
ffffffffc0203db0:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203db4:	e98fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma2 != NULL);
ffffffffc0203db8:	00003697          	auipc	a3,0x3
ffffffffc0203dbc:	bf068693          	addi	a3,a3,-1040 # ffffffffc02069a8 <default_pmm_manager+0xdd0>
ffffffffc0203dc0:	00002617          	auipc	a2,0x2
ffffffffc0203dc4:	a8060613          	addi	a2,a2,-1408 # ffffffffc0205840 <commands+0x870>
ffffffffc0203dc8:	0e000593          	li	a1,224
ffffffffc0203dcc:	00003517          	auipc	a0,0x3
ffffffffc0203dd0:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203dd4:	e78fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma1 != NULL);
ffffffffc0203dd8:	00003697          	auipc	a3,0x3
ffffffffc0203ddc:	bc068693          	addi	a3,a3,-1088 # ffffffffc0206998 <default_pmm_manager+0xdc0>
ffffffffc0203de0:	00002617          	auipc	a2,0x2
ffffffffc0203de4:	a6060613          	addi	a2,a2,-1440 # ffffffffc0205840 <commands+0x870>
ffffffffc0203de8:	0de00593          	li	a1,222
ffffffffc0203dec:	00003517          	auipc	a0,0x3
ffffffffc0203df0:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203df4:	e58fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma5 == NULL);
ffffffffc0203df8:	00003697          	auipc	a3,0x3
ffffffffc0203dfc:	be068693          	addi	a3,a3,-1056 # ffffffffc02069d8 <default_pmm_manager+0xe00>
ffffffffc0203e00:	00002617          	auipc	a2,0x2
ffffffffc0203e04:	a4060613          	addi	a2,a2,-1472 # ffffffffc0205840 <commands+0x870>
ffffffffc0203e08:	0e600593          	li	a1,230
ffffffffc0203e0c:	00003517          	auipc	a0,0x3
ffffffffc0203e10:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203e14:	e38fc0ef          	jal	ra,ffffffffc020044c <__panic>
        assert(vma4 == NULL);
ffffffffc0203e18:	00003697          	auipc	a3,0x3
ffffffffc0203e1c:	bb068693          	addi	a3,a3,-1104 # ffffffffc02069c8 <default_pmm_manager+0xdf0>
ffffffffc0203e20:	00002617          	auipc	a2,0x2
ffffffffc0203e24:	a2060613          	addi	a2,a2,-1504 # ffffffffc0205840 <commands+0x870>
ffffffffc0203e28:	0e400593          	li	a1,228
ffffffffc0203e2c:	00003517          	auipc	a0,0x3
ffffffffc0203e30:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203e34:	e18fc0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203e38:	00002617          	auipc	a2,0x2
ffffffffc0203e3c:	e5060613          	addi	a2,a2,-432 # ffffffffc0205c88 <default_pmm_manager+0xb0>
ffffffffc0203e40:	06200593          	li	a1,98
ffffffffc0203e44:	00002517          	auipc	a0,0x2
ffffffffc0203e48:	e0c50513          	addi	a0,a0,-500 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0203e4c:	e00fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(mm != NULL);
ffffffffc0203e50:	00002697          	auipc	a3,0x2
ffffffffc0203e54:	50068693          	addi	a3,a3,1280 # ffffffffc0206350 <default_pmm_manager+0x778>
ffffffffc0203e58:	00002617          	auipc	a2,0x2
ffffffffc0203e5c:	9e860613          	addi	a2,a2,-1560 # ffffffffc0205840 <commands+0x870>
ffffffffc0203e60:	0c200593          	li	a1,194
ffffffffc0203e64:	00003517          	auipc	a0,0x3
ffffffffc0203e68:	9b450513          	addi	a0,a0,-1612 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203e6c:	de0fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203e70:	00003697          	auipc	a3,0x3
ffffffffc0203e74:	c8068693          	addi	a3,a3,-896 # ffffffffc0206af0 <default_pmm_manager+0xf18>
ffffffffc0203e78:	00002617          	auipc	a2,0x2
ffffffffc0203e7c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0205840 <commands+0x870>
ffffffffc0203e80:	12400593          	li	a1,292
ffffffffc0203e84:	00003517          	auipc	a0,0x3
ffffffffc0203e88:	99450513          	addi	a0,a0,-1644 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203e8c:	dc0fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203e90:	00002697          	auipc	a3,0x2
ffffffffc0203e94:	4e868693          	addi	a3,a3,1256 # ffffffffc0206378 <default_pmm_manager+0x7a0>
ffffffffc0203e98:	00002617          	auipc	a2,0x2
ffffffffc0203e9c:	9a860613          	addi	a2,a2,-1624 # ffffffffc0205840 <commands+0x870>
ffffffffc0203ea0:	10500593          	li	a1,261
ffffffffc0203ea4:	00003517          	auipc	a0,0x3
ffffffffc0203ea8:	97450513          	addi	a0,a0,-1676 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203eac:	da0fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203eb0:	00003697          	auipc	a3,0x3
ffffffffc0203eb4:	c1068693          	addi	a3,a3,-1008 # ffffffffc0206ac0 <default_pmm_manager+0xee8>
ffffffffc0203eb8:	00002617          	auipc	a2,0x2
ffffffffc0203ebc:	98860613          	addi	a2,a2,-1656 # ffffffffc0205840 <commands+0x870>
ffffffffc0203ec0:	10d00593          	li	a1,269
ffffffffc0203ec4:	00003517          	auipc	a0,0x3
ffffffffc0203ec8:	95450513          	addi	a0,a0,-1708 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203ecc:	d80fc0ef          	jal	ra,ffffffffc020044c <__panic>
    return KADDR(page2pa(page));
ffffffffc0203ed0:	00002617          	auipc	a2,0x2
ffffffffc0203ed4:	d5860613          	addi	a2,a2,-680 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc0203ed8:	06900593          	li	a1,105
ffffffffc0203edc:	00002517          	auipc	a0,0x2
ffffffffc0203ee0:	d7450513          	addi	a0,a0,-652 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0203ee4:	d68fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(sum == 0);
ffffffffc0203ee8:	00003697          	auipc	a3,0x3
ffffffffc0203eec:	bf868693          	addi	a3,a3,-1032 # ffffffffc0206ae0 <default_pmm_manager+0xf08>
ffffffffc0203ef0:	00002617          	auipc	a2,0x2
ffffffffc0203ef4:	95060613          	addi	a2,a2,-1712 # ffffffffc0205840 <commands+0x870>
ffffffffc0203ef8:	11700593          	li	a1,279
ffffffffc0203efc:	00003517          	auipc	a0,0x3
ffffffffc0203f00:	91c50513          	addi	a0,a0,-1764 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203f04:	d48fc0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203f08:	00003697          	auipc	a3,0x3
ffffffffc0203f0c:	ba068693          	addi	a3,a3,-1120 # ffffffffc0206aa8 <default_pmm_manager+0xed0>
ffffffffc0203f10:	00002617          	auipc	a2,0x2
ffffffffc0203f14:	93060613          	addi	a2,a2,-1744 # ffffffffc0205840 <commands+0x870>
ffffffffc0203f18:	10100593          	li	a1,257
ffffffffc0203f1c:	00003517          	auipc	a0,0x3
ffffffffc0203f20:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0206818 <default_pmm_manager+0xc40>
ffffffffc0203f24:	d28fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0203f28 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f28:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f2a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f2c:	f822                	sd	s0,48(sp)
ffffffffc0203f2e:	f426                	sd	s1,40(sp)
ffffffffc0203f30:	fc06                	sd	ra,56(sp)
ffffffffc0203f32:	f04a                	sd	s2,32(sp)
ffffffffc0203f34:	ec4e                	sd	s3,24(sp)
ffffffffc0203f36:	8432                	mv	s0,a2
ffffffffc0203f38:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f3a:	96fff0ef          	jal	ra,ffffffffc02038a8 <find_vma>

    pgfault_num++;
ffffffffc0203f3e:	00011797          	auipc	a5,0x11
ffffffffc0203f42:	56678793          	addi	a5,a5,1382 # ffffffffc02154a4 <pgfault_num>
ffffffffc0203f46:	439c                	lw	a5,0(a5)
ffffffffc0203f48:	2785                	addiw	a5,a5,1
ffffffffc0203f4a:	00011717          	auipc	a4,0x11
ffffffffc0203f4e:	54f72d23          	sw	a5,1370(a4) # ffffffffc02154a4 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203f52:	c555                	beqz	a0,ffffffffc0203ffe <do_pgfault+0xd6>
ffffffffc0203f54:	651c                	ld	a5,8(a0)
ffffffffc0203f56:	0af46463          	bltu	s0,a5,ffffffffc0203ffe <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f5a:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203f5c:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f5e:	8b89                	andi	a5,a5,2
ffffffffc0203f60:	e3a5                	bnez	a5,ffffffffc0203fc0 <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f62:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f64:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f66:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f68:	85a2                	mv	a1,s0
ffffffffc0203f6a:	4605                	li	a2,1
ffffffffc0203f6c:	d0bfd0ef          	jal	ra,ffffffffc0201c76 <get_pte>
ffffffffc0203f70:	c945                	beqz	a0,ffffffffc0204020 <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0203f72:	610c                	ld	a1,0(a0)
ffffffffc0203f74:	c5b5                	beqz	a1,ffffffffc0203fe0 <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203f76:	00011797          	auipc	a5,0x11
ffffffffc0203f7a:	52a78793          	addi	a5,a5,1322 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0203f7e:	439c                	lw	a5,0(a5)
ffffffffc0203f80:	2781                	sext.w	a5,a5
ffffffffc0203f82:	c7d9                	beqz	a5,ffffffffc0204010 <do_pgfault+0xe8>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            ret=swap_in(mm,addr,&page);
ffffffffc0203f84:	0030                	addi	a2,sp,8
ffffffffc0203f86:	85a2                	mv	a1,s0
ffffffffc0203f88:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203f8a:	e402                	sd	zero,8(sp)
            ret=swap_in(mm,addr,&page);
ffffffffc0203f8c:	c0cff0ef          	jal	ra,ffffffffc0203398 <swap_in>
ffffffffc0203f90:	892a                	mv	s2,a0
            if(ret!=0){
ffffffffc0203f92:	e90d                	bnez	a0,ffffffffc0203fc4 <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0203f94:	65a2                	ld	a1,8(sp)
ffffffffc0203f96:	6c88                	ld	a0,24(s1)
ffffffffc0203f98:	86ce                	mv	a3,s3
ffffffffc0203f9a:	8622                	mv	a2,s0
ffffffffc0203f9c:	f79fd0ef          	jal	ra,ffffffffc0201f14 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0203fa0:	6622                	ld	a2,8(sp)
ffffffffc0203fa2:	4685                	li	a3,1
ffffffffc0203fa4:	85a2                	mv	a1,s0
ffffffffc0203fa6:	8526                	mv	a0,s1
ffffffffc0203fa8:	accff0ef          	jal	ra,ffffffffc0203274 <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc0203fac:	67a2                	ld	a5,8(sp)
ffffffffc0203fae:	ff80                	sd	s0,56(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc0203fb0:	70e2                	ld	ra,56(sp)
ffffffffc0203fb2:	7442                	ld	s0,48(sp)
ffffffffc0203fb4:	854a                	mv	a0,s2
ffffffffc0203fb6:	74a2                	ld	s1,40(sp)
ffffffffc0203fb8:	7902                	ld	s2,32(sp)
ffffffffc0203fba:	69e2                	ld	s3,24(sp)
ffffffffc0203fbc:	6121                	addi	sp,sp,64
ffffffffc0203fbe:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0203fc0:	49dd                	li	s3,23
ffffffffc0203fc2:	b745                	j	ffffffffc0203f62 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0203fc4:	00003517          	auipc	a0,0x3
ffffffffc0203fc8:	8dc50513          	addi	a0,a0,-1828 # ffffffffc02068a0 <default_pmm_manager+0xcc8>
ffffffffc0203fcc:	9c2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203fd0:	70e2                	ld	ra,56(sp)
ffffffffc0203fd2:	7442                	ld	s0,48(sp)
ffffffffc0203fd4:	854a                	mv	a0,s2
ffffffffc0203fd6:	74a2                	ld	s1,40(sp)
ffffffffc0203fd8:	7902                	ld	s2,32(sp)
ffffffffc0203fda:	69e2                	ld	s3,24(sp)
ffffffffc0203fdc:	6121                	addi	sp,sp,64
ffffffffc0203fde:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203fe0:	6c88                	ld	a0,24(s1)
ffffffffc0203fe2:	864e                	mv	a2,s3
ffffffffc0203fe4:	85a2                	mv	a1,s0
ffffffffc0203fe6:	a79fe0ef          	jal	ra,ffffffffc0202a5e <pgdir_alloc_page>
   ret = 0;
ffffffffc0203fea:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203fec:	f171                	bnez	a0,ffffffffc0203fb0 <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203fee:	00003517          	auipc	a0,0x3
ffffffffc0203ff2:	88a50513          	addi	a0,a0,-1910 # ffffffffc0206878 <default_pmm_manager+0xca0>
ffffffffc0203ff6:	998fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ffa:	5971                	li	s2,-4
            goto failed;
ffffffffc0203ffc:	bf55                	j	ffffffffc0203fb0 <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203ffe:	85a2                	mv	a1,s0
ffffffffc0204000:	00003517          	auipc	a0,0x3
ffffffffc0204004:	82850513          	addi	a0,a0,-2008 # ffffffffc0206828 <default_pmm_manager+0xc50>
ffffffffc0204008:	986fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc020400c:	5975                	li	s2,-3
        goto failed;
ffffffffc020400e:	b74d                	j	ffffffffc0203fb0 <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204010:	00003517          	auipc	a0,0x3
ffffffffc0204014:	8b050513          	addi	a0,a0,-1872 # ffffffffc02068c0 <default_pmm_manager+0xce8>
ffffffffc0204018:	976fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020401c:	5971                	li	s2,-4
            goto failed;
ffffffffc020401e:	bf49                	j	ffffffffc0203fb0 <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204020:	00003517          	auipc	a0,0x3
ffffffffc0204024:	83850513          	addi	a0,a0,-1992 # ffffffffc0206858 <default_pmm_manager+0xc80>
ffffffffc0204028:	966fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc020402c:	5971                	li	s2,-4
        goto failed;
ffffffffc020402e:	b749                	j	ffffffffc0203fb0 <do_pgfault+0x88>

ffffffffc0204030 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204030:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204032:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204034:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204036:	d3efc0ef          	jal	ra,ffffffffc0200574 <ide_device_valid>
ffffffffc020403a:	cd01                	beqz	a0,ffffffffc0204052 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020403c:	4505                	li	a0,1
ffffffffc020403e:	d3cfc0ef          	jal	ra,ffffffffc020057a <ide_device_size>
}
ffffffffc0204042:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204044:	810d                	srli	a0,a0,0x3
ffffffffc0204046:	00011797          	auipc	a5,0x11
ffffffffc020404a:	54a7b523          	sd	a0,1354(a5) # ffffffffc0215590 <max_swap_offset>
}
ffffffffc020404e:	0141                	addi	sp,sp,16
ffffffffc0204050:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204052:	00003617          	auipc	a2,0x3
ffffffffc0204056:	afe60613          	addi	a2,a2,-1282 # ffffffffc0206b50 <default_pmm_manager+0xf78>
ffffffffc020405a:	45b5                	li	a1,13
ffffffffc020405c:	00003517          	auipc	a0,0x3
ffffffffc0204060:	b1450513          	addi	a0,a0,-1260 # ffffffffc0206b70 <default_pmm_manager+0xf98>
ffffffffc0204064:	be8fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204068 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204068:	1141                	addi	sp,sp,-16
ffffffffc020406a:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020406c:	00855793          	srli	a5,a0,0x8
ffffffffc0204070:	cfb9                	beqz	a5,ffffffffc02040ce <swapfs_read+0x66>
ffffffffc0204072:	00011717          	auipc	a4,0x11
ffffffffc0204076:	51e70713          	addi	a4,a4,1310 # ffffffffc0215590 <max_swap_offset>
ffffffffc020407a:	6318                	ld	a4,0(a4)
ffffffffc020407c:	04e7f963          	bgeu	a5,a4,ffffffffc02040ce <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204080:	00011717          	auipc	a4,0x11
ffffffffc0204084:	48070713          	addi	a4,a4,1152 # ffffffffc0215500 <pages>
ffffffffc0204088:	6310                	ld	a2,0(a4)
ffffffffc020408a:	00003717          	auipc	a4,0x3
ffffffffc020408e:	f5670713          	addi	a4,a4,-170 # ffffffffc0206fe0 <nbase>
ffffffffc0204092:	40c58633          	sub	a2,a1,a2
ffffffffc0204096:	630c                	ld	a1,0(a4)
ffffffffc0204098:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc020409a:	00011717          	auipc	a4,0x11
ffffffffc020409e:	3f670713          	addi	a4,a4,1014 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc02040a2:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc02040a4:	6314                	ld	a3,0(a4)
ffffffffc02040a6:	00c61713          	slli	a4,a2,0xc
ffffffffc02040aa:	8331                	srli	a4,a4,0xc
ffffffffc02040ac:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02040b0:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02040b2:	02d77a63          	bgeu	a4,a3,ffffffffc02040e6 <swapfs_read+0x7e>
ffffffffc02040b6:	00011797          	auipc	a5,0x11
ffffffffc02040ba:	43a78793          	addi	a5,a5,1082 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02040be:	639c                	ld	a5,0(a5)
}
ffffffffc02040c0:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040c2:	46a1                	li	a3,8
ffffffffc02040c4:	963e                	add	a2,a2,a5
ffffffffc02040c6:	4505                	li	a0,1
}
ffffffffc02040c8:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040ca:	cb6fc06f          	j	ffffffffc0200580 <ide_read_secs>
ffffffffc02040ce:	86aa                	mv	a3,a0
ffffffffc02040d0:	00003617          	auipc	a2,0x3
ffffffffc02040d4:	ab860613          	addi	a2,a2,-1352 # ffffffffc0206b88 <default_pmm_manager+0xfb0>
ffffffffc02040d8:	45d1                	li	a1,20
ffffffffc02040da:	00003517          	auipc	a0,0x3
ffffffffc02040de:	a9650513          	addi	a0,a0,-1386 # ffffffffc0206b70 <default_pmm_manager+0xf98>
ffffffffc02040e2:	b6afc0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc02040e6:	86b2                	mv	a3,a2
ffffffffc02040e8:	06900593          	li	a1,105
ffffffffc02040ec:	00002617          	auipc	a2,0x2
ffffffffc02040f0:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc02040f4:	00002517          	auipc	a0,0x2
ffffffffc02040f8:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc02040fc:	b50fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204100 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204100:	1141                	addi	sp,sp,-16
ffffffffc0204102:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204104:	00855793          	srli	a5,a0,0x8
ffffffffc0204108:	cfb9                	beqz	a5,ffffffffc0204166 <swapfs_write+0x66>
ffffffffc020410a:	00011717          	auipc	a4,0x11
ffffffffc020410e:	48670713          	addi	a4,a4,1158 # ffffffffc0215590 <max_swap_offset>
ffffffffc0204112:	6318                	ld	a4,0(a4)
ffffffffc0204114:	04e7f963          	bgeu	a5,a4,ffffffffc0204166 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204118:	00011717          	auipc	a4,0x11
ffffffffc020411c:	3e870713          	addi	a4,a4,1000 # ffffffffc0215500 <pages>
ffffffffc0204120:	6310                	ld	a2,0(a4)
ffffffffc0204122:	00003717          	auipc	a4,0x3
ffffffffc0204126:	ebe70713          	addi	a4,a4,-322 # ffffffffc0206fe0 <nbase>
ffffffffc020412a:	40c58633          	sub	a2,a1,a2
ffffffffc020412e:	630c                	ld	a1,0(a4)
ffffffffc0204130:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204132:	00011717          	auipc	a4,0x11
ffffffffc0204136:	35e70713          	addi	a4,a4,862 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc020413a:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc020413c:	6314                	ld	a3,0(a4)
ffffffffc020413e:	00c61713          	slli	a4,a2,0xc
ffffffffc0204142:	8331                	srli	a4,a4,0xc
ffffffffc0204144:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204148:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020414a:	02d77a63          	bgeu	a4,a3,ffffffffc020417e <swapfs_write+0x7e>
ffffffffc020414e:	00011797          	auipc	a5,0x11
ffffffffc0204152:	3a278793          	addi	a5,a5,930 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0204156:	639c                	ld	a5,0(a5)
}
ffffffffc0204158:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020415a:	46a1                	li	a3,8
ffffffffc020415c:	963e                	add	a2,a2,a5
ffffffffc020415e:	4505                	li	a0,1
}
ffffffffc0204160:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204162:	c42fc06f          	j	ffffffffc02005a4 <ide_write_secs>
ffffffffc0204166:	86aa                	mv	a3,a0
ffffffffc0204168:	00003617          	auipc	a2,0x3
ffffffffc020416c:	a2060613          	addi	a2,a2,-1504 # ffffffffc0206b88 <default_pmm_manager+0xfb0>
ffffffffc0204170:	45e5                	li	a1,25
ffffffffc0204172:	00003517          	auipc	a0,0x3
ffffffffc0204176:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0206b70 <default_pmm_manager+0xf98>
ffffffffc020417a:	ad2fc0ef          	jal	ra,ffffffffc020044c <__panic>
ffffffffc020417e:	86b2                	mv	a3,a2
ffffffffc0204180:	06900593          	li	a1,105
ffffffffc0204184:	00002617          	auipc	a2,0x2
ffffffffc0204188:	aa460613          	addi	a2,a2,-1372 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc020418c:	00002517          	auipc	a0,0x2
ffffffffc0204190:	ac450513          	addi	a0,a0,-1340 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc0204194:	ab8fc0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204198 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204198:	8526                	mv	a0,s1
	jalr s0
ffffffffc020419a:	9402                	jalr	s0

	jal do_exit
ffffffffc020419c:	482000ef          	jal	ra,ffffffffc020461e <do_exit>

ffffffffc02041a0 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc02041a0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02041a2:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc02041a6:	e022                	sd	s0,0(sp)
ffffffffc02041a8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02041aa:	fc6fd0ef          	jal	ra,ffffffffc0201970 <kmalloc>
ffffffffc02041ae:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02041b0:	c529                	beqz	a0,ffffffffc02041fa <alloc_proc+0x5a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state=PROC_UNINIT;
ffffffffc02041b2:	57fd                	li	a5,-1
ffffffffc02041b4:	1782                	slli	a5,a5,0x20
ffffffffc02041b6:	e11c                	sd	a5,0(a0)
    proc->runs=0;
    proc->kstack=0;
    proc->need_resched=0;
    proc->parent=NULL;
    proc->mm=NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02041b8:	07000613          	li	a2,112
ffffffffc02041bc:	4581                	li	a1,0
    proc->runs=0;
ffffffffc02041be:	00052423          	sw	zero,8(a0)
    proc->kstack=0;
ffffffffc02041c2:	00053823          	sd	zero,16(a0)
    proc->need_resched=0;
ffffffffc02041c6:	00052c23          	sw	zero,24(a0)
    proc->parent=NULL;
ffffffffc02041ca:	02053023          	sd	zero,32(a0)
    proc->mm=NULL;
ffffffffc02041ce:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02041d2:	03050513          	addi	a0,a0,48
ffffffffc02041d6:	471000ef          	jal	ra,ffffffffc0204e46 <memset>
    proc->tf=NULL;
    proc->cr3=boot_cr3;
ffffffffc02041da:	00011797          	auipc	a5,0x11
ffffffffc02041de:	31e78793          	addi	a5,a5,798 # ffffffffc02154f8 <boot_cr3>
ffffffffc02041e2:	639c                	ld	a5,0(a5)
    proc->tf=NULL;
ffffffffc02041e4:	0a043023          	sd	zero,160(s0)
    proc->flags=0;
ffffffffc02041e8:	0a042823          	sw	zero,176(s0)
    proc->cr3=boot_cr3;
ffffffffc02041ec:	f45c                	sd	a5,168(s0)
    memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc02041ee:	463d                	li	a2,15
ffffffffc02041f0:	4581                	li	a1,0
ffffffffc02041f2:	0b440513          	addi	a0,s0,180
ffffffffc02041f6:	451000ef          	jal	ra,ffffffffc0204e46 <memset>
    }
    return proc;
}
ffffffffc02041fa:	8522                	mv	a0,s0
ffffffffc02041fc:	60a2                	ld	ra,8(sp)
ffffffffc02041fe:	6402                	ld	s0,0(sp)
ffffffffc0204200:	0141                	addi	sp,sp,16
ffffffffc0204202:	8082                	ret

ffffffffc0204204 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204204:	00011797          	auipc	a5,0x11
ffffffffc0204208:	2a478793          	addi	a5,a5,676 # ffffffffc02154a8 <current>
ffffffffc020420c:	639c                	ld	a5,0(a5)
ffffffffc020420e:	73c8                	ld	a0,160(a5)
ffffffffc0204210:	971fc06f          	j	ffffffffc0200b80 <forkrets>

ffffffffc0204214 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204214:	1101                	addi	sp,sp,-32
ffffffffc0204216:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204218:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020421c:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020421e:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204220:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204222:	8522                	mv	a0,s0
ffffffffc0204224:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204226:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204228:	41f000ef          	jal	ra,ffffffffc0204e46 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020422c:	8522                	mv	a0,s0
}
ffffffffc020422e:	6442                	ld	s0,16(sp)
ffffffffc0204230:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204232:	85a6                	mv	a1,s1
}
ffffffffc0204234:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204236:	463d                	li	a2,15
}
ffffffffc0204238:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020423a:	41f0006f          	j	ffffffffc0204e58 <memcpy>

ffffffffc020423e <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc020423e:	1101                	addi	sp,sp,-32
ffffffffc0204240:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204242:	00011417          	auipc	s0,0x11
ffffffffc0204246:	21e40413          	addi	s0,s0,542 # ffffffffc0215460 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc020424a:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc020424c:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc020424e:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc0204250:	4581                	li	a1,0
ffffffffc0204252:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc0204254:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204256:	3f1000ef          	jal	ra,ffffffffc0204e46 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020425a:	8522                	mv	a0,s0
}
ffffffffc020425c:	6442                	ld	s0,16(sp)
ffffffffc020425e:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204260:	0b448593          	addi	a1,s1,180
}
ffffffffc0204264:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204266:	463d                	li	a2,15
}
ffffffffc0204268:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020426a:	3ef0006f          	j	ffffffffc0204e58 <memcpy>

ffffffffc020426e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020426e:	00011797          	auipc	a5,0x11
ffffffffc0204272:	23a78793          	addi	a5,a5,570 # ffffffffc02154a8 <current>
ffffffffc0204276:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc0204278:	1101                	addi	sp,sp,-32
ffffffffc020427a:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020427c:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc020427e:	e822                	sd	s0,16(sp)
ffffffffc0204280:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204282:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc0204284:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204286:	fb9ff0ef          	jal	ra,ffffffffc020423e <get_proc_name>
ffffffffc020428a:	862a                	mv	a2,a0
ffffffffc020428c:	85a6                	mv	a1,s1
ffffffffc020428e:	00003517          	auipc	a0,0x3
ffffffffc0204292:	96250513          	addi	a0,a0,-1694 # ffffffffc0206bf0 <default_pmm_manager+0x1018>
ffffffffc0204296:	ef9fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020429a:	85a2                	mv	a1,s0
ffffffffc020429c:	00003517          	auipc	a0,0x3
ffffffffc02042a0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0206c18 <default_pmm_manager+0x1040>
ffffffffc02042a4:	eebfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02042a8:	00003517          	auipc	a0,0x3
ffffffffc02042ac:	98050513          	addi	a0,a0,-1664 # ffffffffc0206c28 <default_pmm_manager+0x1050>
ffffffffc02042b0:	edffb0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc02042b4:	60e2                	ld	ra,24(sp)
ffffffffc02042b6:	6442                	ld	s0,16(sp)
ffffffffc02042b8:	64a2                	ld	s1,8(sp)
ffffffffc02042ba:	4501                	li	a0,0
ffffffffc02042bc:	6105                	addi	sp,sp,32
ffffffffc02042be:	8082                	ret

ffffffffc02042c0 <proc_run>:
    if (proc != current) {
ffffffffc02042c0:	00011797          	auipc	a5,0x11
ffffffffc02042c4:	1e878793          	addi	a5,a5,488 # ffffffffc02154a8 <current>
ffffffffc02042c8:	639c                	ld	a5,0(a5)
ffffffffc02042ca:	02a78d63          	beq	a5,a0,ffffffffc0204304 <proc_run+0x44>
proc_run(struct proc_struct *proc) {
ffffffffc02042ce:	1141                	addi	sp,sp,-16
ffffffffc02042d0:	e022                	sd	s0,0(sp)
ffffffffc02042d2:	e406                	sd	ra,8(sp)
ffffffffc02042d4:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02042d6:	100027f3          	csrr	a5,sstatus
ffffffffc02042da:	8b89                	andi	a5,a5,2
ffffffffc02042dc:	e78d                	bnez	a5,ffffffffc0204306 <proc_run+0x46>
        lcr3(proc->cr3);  // 切换到目标进程的页表 (CR3寄存器)
ffffffffc02042de:	745c                	ld	a5,168(s0)
        current = proc;  // 更新当前进程为要切换的目标进程
ffffffffc02042e0:	00011717          	auipc	a4,0x11
ffffffffc02042e4:	1c873423          	sd	s0,456(a4) # ffffffffc02154a8 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc02042e8:	80000737          	lui	a4,0x80000
ffffffffc02042ec:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc02042f0:	8fd9                	or	a5,a5,a4
ffffffffc02042f2:	18079073          	csrw	satp,a5
        switch_to(&current->context, &proc->context);  // 执行上下文切换
ffffffffc02042f6:	03040593          	addi	a1,s0,48
}
ffffffffc02042fa:	6402                	ld	s0,0(sp)
ffffffffc02042fc:	60a2                	ld	ra,8(sp)
        switch_to(&current->context, &proc->context);  // 执行上下文切换
ffffffffc02042fe:	852e                	mv	a0,a1
}
ffffffffc0204300:	0141                	addi	sp,sp,16
        switch_to(&current->context, &proc->context);  // 执行上下文切换
ffffffffc0204302:	a3b5                	j	ffffffffc020486e <switch_to>
ffffffffc0204304:	8082                	ret
        intr_disable();
ffffffffc0204306:	acafc0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        intr_enable();
ffffffffc020430a:	ac0fc0ef          	jal	ra,ffffffffc02005ca <intr_enable>
ffffffffc020430e:	bfc1                	j	ffffffffc02042de <proc_run+0x1e>

ffffffffc0204310 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204310:	0005071b          	sext.w	a4,a0
ffffffffc0204314:	6789                	lui	a5,0x2
ffffffffc0204316:	fff7069b          	addiw	a3,a4,-1
ffffffffc020431a:	17f9                	addi	a5,a5,-2
ffffffffc020431c:	04d7e063          	bltu	a5,a3,ffffffffc020435c <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204320:	1141                	addi	sp,sp,-16
ffffffffc0204322:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204324:	45a9                	li	a1,10
ffffffffc0204326:	842a                	mv	s0,a0
ffffffffc0204328:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc020432a:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020432c:	678000ef          	jal	ra,ffffffffc02049a4 <hash32>
ffffffffc0204330:	02051693          	slli	a3,a0,0x20
ffffffffc0204334:	82f1                	srli	a3,a3,0x1c
ffffffffc0204336:	0000d517          	auipc	a0,0xd
ffffffffc020433a:	12a50513          	addi	a0,a0,298 # ffffffffc0211460 <hash_list>
ffffffffc020433e:	96aa                	add	a3,a3,a0
ffffffffc0204340:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204342:	a029                	j	ffffffffc020434c <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204344:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc0204348:	00870c63          	beq	a4,s0,ffffffffc0204360 <find_proc+0x50>
ffffffffc020434c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020434e:	fef69be3          	bne	a3,a5,ffffffffc0204344 <find_proc+0x34>
}
ffffffffc0204352:	60a2                	ld	ra,8(sp)
ffffffffc0204354:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204356:	4501                	li	a0,0
}
ffffffffc0204358:	0141                	addi	sp,sp,16
ffffffffc020435a:	8082                	ret
    return NULL;
ffffffffc020435c:	4501                	li	a0,0
}
ffffffffc020435e:	8082                	ret
ffffffffc0204360:	60a2                	ld	ra,8(sp)
ffffffffc0204362:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204364:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204368:	0141                	addi	sp,sp,16
ffffffffc020436a:	8082                	ret

ffffffffc020436c <do_fork>:
    if (nr_process >= MAX_PROCESS) {
ffffffffc020436c:	00011797          	auipc	a5,0x11
ffffffffc0204370:	15478793          	addi	a5,a5,340 # ffffffffc02154c0 <nr_process>
ffffffffc0204374:	4398                	lw	a4,0(a5)
ffffffffc0204376:	6785                	lui	a5,0x1
ffffffffc0204378:	22f75163          	bge	a4,a5,ffffffffc020459a <do_fork+0x22e>
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020437c:	7179                	addi	sp,sp,-48
ffffffffc020437e:	f022                	sd	s0,32(sp)
ffffffffc0204380:	ec26                	sd	s1,24(sp)
ffffffffc0204382:	e84a                	sd	s2,16(sp)
ffffffffc0204384:	e44e                	sd	s3,8(sp)
ffffffffc0204386:	f406                	sd	ra,40(sp)
ffffffffc0204388:	89aa                	mv	s3,a0
ffffffffc020438a:	892e                	mv	s2,a1
ffffffffc020438c:	84b2                	mv	s1,a2
    proc = alloc_proc();
ffffffffc020438e:	e13ff0ef          	jal	ra,ffffffffc02041a0 <alloc_proc>
ffffffffc0204392:	842a                	mv	s0,a0
    if (proc == NULL) {
ffffffffc0204394:	20050163          	beqz	a0,ffffffffc0204596 <do_fork+0x22a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204398:	4509                	li	a0,2
ffffffffc020439a:	fcefd0ef          	jal	ra,ffffffffc0201b68 <alloc_pages>
    if (page != NULL) {
ffffffffc020439e:	1e050963          	beqz	a0,ffffffffc0204590 <do_fork+0x224>
    return page - pages + nbase;
ffffffffc02043a2:	00011797          	auipc	a5,0x11
ffffffffc02043a6:	15e78793          	addi	a5,a5,350 # ffffffffc0215500 <pages>
ffffffffc02043aa:	0007b883          	ld	a7,0(a5)
ffffffffc02043ae:	00003797          	auipc	a5,0x3
ffffffffc02043b2:	c3278793          	addi	a5,a5,-974 # ffffffffc0206fe0 <nbase>
ffffffffc02043b6:	0007be83          	ld	t4,0(a5)
ffffffffc02043ba:	411506b3          	sub	a3,a0,a7
ffffffffc02043be:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02043c0:	00011797          	auipc	a5,0x11
ffffffffc02043c4:	0d078793          	addi	a5,a5,208 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc02043c8:	96f6                	add	a3,a3,t4
    return KADDR(page2pa(page));
ffffffffc02043ca:	639c                	ld	a5,0(a5)
ffffffffc02043cc:	00c69813          	slli	a6,a3,0xc
ffffffffc02043d0:	00c85813          	srli	a6,a6,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02043d4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043d6:	1cf87463          	bgeu	a6,a5,ffffffffc020459e <do_fork+0x232>
ffffffffc02043da:	00011797          	auipc	a5,0x11
ffffffffc02043de:	11678793          	addi	a5,a5,278 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02043e2:	639c                	ld	a5,0(a5)
    if (!(clone_flags & CLONE_VM)) {
ffffffffc02043e4:	1009f993          	andi	s3,s3,256
ffffffffc02043e8:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02043ea:	e814                	sd	a3,16(s0)
    if (!(clone_flags & CLONE_VM)) {
ffffffffc02043ec:	14098263          	beqz	s3,ffffffffc0204530 <do_fork+0x1c4>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02043f0:	6789                	lui	a5,0x2
ffffffffc02043f2:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc02043f6:	97b6                	add	a5,a5,a3
    *(proc->tf) = *tf;
ffffffffc02043f8:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02043fa:	f05c                	sd	a5,160(s0)
    *(proc->tf) = *tf;
ffffffffc02043fc:	873e                	mv	a4,a5
ffffffffc02043fe:	12048f13          	addi	t5,s1,288
ffffffffc0204402:	00063e03          	ld	t3,0(a2)
ffffffffc0204406:	00863303          	ld	t1,8(a2)
ffffffffc020440a:	6a08                	ld	a0,16(a2)
ffffffffc020440c:	6e0c                	ld	a1,24(a2)
ffffffffc020440e:	01c73023          	sd	t3,0(a4) # ffffffff80000000 <BASE_ADDRESS-0x40200000>
ffffffffc0204412:	00673423          	sd	t1,8(a4)
ffffffffc0204416:	eb08                	sd	a0,16(a4)
ffffffffc0204418:	ef0c                	sd	a1,24(a4)
ffffffffc020441a:	02060613          	addi	a2,a2,32
ffffffffc020441e:	02070713          	addi	a4,a4,32
ffffffffc0204422:	ffe610e3          	bne	a2,t5,ffffffffc0204402 <do_fork+0x96>
    proc->tf->gpr.a0 = 0;
ffffffffc0204426:	0407b823          	sd	zero,80(a5)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020442a:	10090163          	beqz	s2,ffffffffc020452c <do_fork+0x1c0>
    if (++ last_pid >= MAX_PID) {
ffffffffc020442e:	00006717          	auipc	a4,0x6
ffffffffc0204432:	c2a70713          	addi	a4,a4,-982 # ffffffffc020a058 <last_pid.1575>
ffffffffc0204436:	4318                	lw	a4,0(a4)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204438:	0127b823          	sd	s2,16(a5)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020443c:	fc1c                	sd	a5,56(s0)
    if (++ last_pid >= MAX_PID) {
ffffffffc020443e:	0017051b          	addiw	a0,a4,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204442:	00000617          	auipc	a2,0x0
ffffffffc0204446:	dc260613          	addi	a2,a2,-574 # ffffffffc0204204 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc020444a:	00006797          	auipc	a5,0x6
ffffffffc020444e:	c0a7a723          	sw	a0,-1010(a5) # ffffffffc020a058 <last_pid.1575>
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204452:	f810                	sd	a2,48(s0)
    if (++ last_pid >= MAX_PID) {
ffffffffc0204454:	6789                	lui	a5,0x2
ffffffffc0204456:	10f55563          	bge	a0,a5,ffffffffc0204560 <do_fork+0x1f4>
    if (last_pid >= next_safe) {
ffffffffc020445a:	00006797          	auipc	a5,0x6
ffffffffc020445e:	c0278793          	addi	a5,a5,-1022 # ffffffffc020a05c <next_safe.1574>
ffffffffc0204462:	439c                	lw	a5,0(a5)
ffffffffc0204464:	06f54163          	blt	a0,a5,ffffffffc02044c6 <do_fork+0x15a>
        next_safe = MAX_PID;
ffffffffc0204468:	6789                	lui	a5,0x2
ffffffffc020446a:	00006717          	auipc	a4,0x6
ffffffffc020446e:	bef72923          	sw	a5,-1038(a4) # ffffffffc020a05c <next_safe.1574>
ffffffffc0204472:	4301                	li	t1,0
ffffffffc0204474:	87aa                	mv	a5,a0
ffffffffc0204476:	00011f17          	auipc	t5,0x11
ffffffffc020447a:	172f0f13          	addi	t5,t5,370 # ffffffffc02155e8 <proc_list>
    repeat:
ffffffffc020447e:	6f89                	lui	t6,0x2
ffffffffc0204480:	8e1a                	mv	t3,t1
ffffffffc0204482:	6589                	lui	a1,0x2
        le = list;
ffffffffc0204484:	00011617          	auipc	a2,0x11
ffffffffc0204488:	16460613          	addi	a2,a2,356 # ffffffffc02155e8 <proc_list>
ffffffffc020448c:	6610                	ld	a2,8(a2)
        while ((le = list_next(le)) != list) {
ffffffffc020448e:	01e60f63          	beq	a2,t5,ffffffffc02044ac <do_fork+0x140>
            if (proc->pid == last_pid) {
ffffffffc0204492:	f3c62703          	lw	a4,-196(a2)
ffffffffc0204496:	08f70663          	beq	a4,a5,ffffffffc0204522 <do_fork+0x1b6>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020449a:	fee7d9e3          	bge	a5,a4,ffffffffc020448c <do_fork+0x120>
ffffffffc020449e:	feb757e3          	bge	a4,a1,ffffffffc020448c <do_fork+0x120>
ffffffffc02044a2:	6610                	ld	a2,8(a2)
ffffffffc02044a4:	85ba                	mv	a1,a4
ffffffffc02044a6:	4e05                	li	t3,1
        while ((le = list_next(le)) != list) {
ffffffffc02044a8:	ffe615e3          	bne	a2,t5,ffffffffc0204492 <do_fork+0x126>
ffffffffc02044ac:	00030763          	beqz	t1,ffffffffc02044ba <do_fork+0x14e>
ffffffffc02044b0:	00006717          	auipc	a4,0x6
ffffffffc02044b4:	baf72423          	sw	a5,-1112(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc02044b8:	853e                	mv	a0,a5
ffffffffc02044ba:	000e0663          	beqz	t3,ffffffffc02044c6 <do_fork+0x15a>
ffffffffc02044be:	00006797          	auipc	a5,0x6
ffffffffc02044c2:	b8b7af23          	sw	a1,-1122(a5) # ffffffffc020a05c <next_safe.1574>
    proc->pid = get_pid();
ffffffffc02044c6:	c048                	sw	a0,4(s0)
    if (proc->pid <= 0) {
ffffffffc02044c8:	0aa05863          	blez	a0,ffffffffc0204578 <do_fork+0x20c>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044cc:	45a9                	li	a1,10
ffffffffc02044ce:	2501                	sext.w	a0,a0
ffffffffc02044d0:	4d4000ef          	jal	ra,ffffffffc02049a4 <hash32>
ffffffffc02044d4:	1502                	slli	a0,a0,0x20
ffffffffc02044d6:	0000d797          	auipc	a5,0xd
ffffffffc02044da:	f8a78793          	addi	a5,a5,-118 # ffffffffc0211460 <hash_list>
ffffffffc02044de:	8171                	srli	a0,a0,0x1c
ffffffffc02044e0:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02044e2:	651c                	ld	a5,8(a0)
ffffffffc02044e4:	00011717          	auipc	a4,0x11
ffffffffc02044e8:	10470713          	addi	a4,a4,260 # ffffffffc02155e8 <proc_list>
ffffffffc02044ec:	0d840613          	addi	a2,s0,216
    prev->next = next->prev = elm;
ffffffffc02044f0:	e390                	sd	a2,0(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc02044f2:	6714                	ld	a3,8(a4)
    prev->next = next->prev = elm;
ffffffffc02044f4:	e510                	sd	a2,8(a0)
    elm->next = next;
ffffffffc02044f6:	f07c                	sd	a5,224(s0)
    elm->prev = prev;
ffffffffc02044f8:	ec68                	sd	a0,216(s0)
    list_add(&proc_list, &(proc->list_link)); // 将进程加入进程列表
ffffffffc02044fa:	0c840793          	addi	a5,s0,200
    prev->next = next->prev = elm;
ffffffffc02044fe:	e29c                	sd	a5,0(a3)
    elm->prev = prev;
ffffffffc0204500:	e478                	sd	a4,200(s0)
    wakeup_proc(proc);
ffffffffc0204502:	8522                	mv	a0,s0
    elm->next = next;
ffffffffc0204504:	e874                	sd	a3,208(s0)
    prev->next = next->prev = elm;
ffffffffc0204506:	00011717          	auipc	a4,0x11
ffffffffc020450a:	0ef73523          	sd	a5,234(a4) # ffffffffc02155f0 <proc_list+0x8>
ffffffffc020450e:	3ca000ef          	jal	ra,ffffffffc02048d8 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204512:	4048                	lw	a0,4(s0)
}
ffffffffc0204514:	70a2                	ld	ra,40(sp)
ffffffffc0204516:	7402                	ld	s0,32(sp)
ffffffffc0204518:	64e2                	ld	s1,24(sp)
ffffffffc020451a:	6942                	ld	s2,16(sp)
ffffffffc020451c:	69a2                	ld	s3,8(sp)
ffffffffc020451e:	6145                	addi	sp,sp,48
ffffffffc0204520:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0204522:	2785                	addiw	a5,a5,1
ffffffffc0204524:	04b7d563          	bge	a5,a1,ffffffffc020456e <do_fork+0x202>
ffffffffc0204528:	4305                	li	t1,1
ffffffffc020452a:	b78d                	j	ffffffffc020448c <do_fork+0x120>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020452c:	893e                	mv	s2,a5
ffffffffc020452e:	b701                	j	ffffffffc020442e <do_fork+0xc2>
    assert(current->mm == NULL);
ffffffffc0204530:	00011797          	auipc	a5,0x11
ffffffffc0204534:	f7878793          	addi	a5,a5,-136 # ffffffffc02154a8 <current>
ffffffffc0204538:	639c                	ld	a5,0(a5)
ffffffffc020453a:	779c                	ld	a5,40(a5)
ffffffffc020453c:	ea078ae3          	beqz	a5,ffffffffc02043f0 <do_fork+0x84>
ffffffffc0204540:	00002697          	auipc	a3,0x2
ffffffffc0204544:	68068693          	addi	a3,a3,1664 # ffffffffc0206bc0 <default_pmm_manager+0xfe8>
ffffffffc0204548:	00001617          	auipc	a2,0x1
ffffffffc020454c:	2f860613          	addi	a2,a2,760 # ffffffffc0205840 <commands+0x870>
ffffffffc0204550:	10200593          	li	a1,258
ffffffffc0204554:	00002517          	auipc	a0,0x2
ffffffffc0204558:	68450513          	addi	a0,a0,1668 # ffffffffc0206bd8 <default_pmm_manager+0x1000>
ffffffffc020455c:	ef1fb0ef          	jal	ra,ffffffffc020044c <__panic>
        last_pid = 1;
ffffffffc0204560:	4785                	li	a5,1
ffffffffc0204562:	00006717          	auipc	a4,0x6
ffffffffc0204566:	aef72b23          	sw	a5,-1290(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc020456a:	4505                	li	a0,1
ffffffffc020456c:	bdf5                	j	ffffffffc0204468 <do_fork+0xfc>
                    if (last_pid >= MAX_PID) {
ffffffffc020456e:	01f7c363          	blt	a5,t6,ffffffffc0204574 <do_fork+0x208>
                        last_pid = 1;
ffffffffc0204572:	4785                	li	a5,1
                    goto repeat;
ffffffffc0204574:	4305                	li	t1,1
ffffffffc0204576:	b729                	j	ffffffffc0204480 <do_fork+0x114>
    return pa2page(PADDR(kva));
ffffffffc0204578:	c02007b7          	lui	a5,0xc0200
ffffffffc020457c:	02f6ed63          	bltu	a3,a5,ffffffffc02045b6 <do_fork+0x24a>
    return &pages[PPN(pa) - nbase];
ffffffffc0204580:	41d807b3          	sub	a5,a6,t4
ffffffffc0204584:	079a                	slli	a5,a5,0x6
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204586:	4589                	li	a1,2
ffffffffc0204588:	00f88533          	add	a0,a7,a5
ffffffffc020458c:	e64fd0ef          	jal	ra,ffffffffc0201bf0 <free_pages>
    kfree(proc);
ffffffffc0204590:	8522                	mv	a0,s0
ffffffffc0204592:	c9afd0ef          	jal	ra,ffffffffc0201a2c <kfree>
    ret = -E_NO_MEM;
ffffffffc0204596:	5571                	li	a0,-4
    return ret;
ffffffffc0204598:	bfb5                	j	ffffffffc0204514 <do_fork+0x1a8>
    int ret = -E_NO_FREE_PROC;
ffffffffc020459a:	556d                	li	a0,-5
}
ffffffffc020459c:	8082                	ret
    return KADDR(page2pa(page));
ffffffffc020459e:	00001617          	auipc	a2,0x1
ffffffffc02045a2:	68a60613          	addi	a2,a2,1674 # ffffffffc0205c28 <default_pmm_manager+0x50>
ffffffffc02045a6:	06900593          	li	a1,105
ffffffffc02045aa:	00001517          	auipc	a0,0x1
ffffffffc02045ae:	6a650513          	addi	a0,a0,1702 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc02045b2:	e9bfb0ef          	jal	ra,ffffffffc020044c <__panic>
    return pa2page(PADDR(kva));
ffffffffc02045b6:	00001617          	auipc	a2,0x1
ffffffffc02045ba:	6aa60613          	addi	a2,a2,1706 # ffffffffc0205c60 <default_pmm_manager+0x88>
ffffffffc02045be:	06e00593          	li	a1,110
ffffffffc02045c2:	00001517          	auipc	a0,0x1
ffffffffc02045c6:	68e50513          	addi	a0,a0,1678 # ffffffffc0205c50 <default_pmm_manager+0x78>
ffffffffc02045ca:	e83fb0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc02045ce <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02045ce:	7129                	addi	sp,sp,-320
ffffffffc02045d0:	fa22                	sd	s0,304(sp)
ffffffffc02045d2:	f626                	sd	s1,296(sp)
ffffffffc02045d4:	f24a                	sd	s2,288(sp)
ffffffffc02045d6:	84ae                	mv	s1,a1
ffffffffc02045d8:	892a                	mv	s2,a0
ffffffffc02045da:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02045dc:	4581                	li	a1,0
ffffffffc02045de:	12000613          	li	a2,288
ffffffffc02045e2:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02045e4:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02045e6:	061000ef          	jal	ra,ffffffffc0204e46 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02045ea:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02045ec:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02045ee:	100027f3          	csrr	a5,sstatus
ffffffffc02045f2:	edd7f793          	andi	a5,a5,-291
ffffffffc02045f6:	1207e793          	ori	a5,a5,288
ffffffffc02045fa:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045fc:	860a                	mv	a2,sp
ffffffffc02045fe:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204602:	00000797          	auipc	a5,0x0
ffffffffc0204606:	b9678793          	addi	a5,a5,-1130 # ffffffffc0204198 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020460a:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020460c:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020460e:	d5fff0ef          	jal	ra,ffffffffc020436c <do_fork>
}
ffffffffc0204612:	70f2                	ld	ra,312(sp)
ffffffffc0204614:	7452                	ld	s0,304(sp)
ffffffffc0204616:	74b2                	ld	s1,296(sp)
ffffffffc0204618:	7912                	ld	s2,288(sp)
ffffffffc020461a:	6131                	addi	sp,sp,320
ffffffffc020461c:	8082                	ret

ffffffffc020461e <do_exit>:
do_exit(int error_code) {
ffffffffc020461e:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204620:	00002617          	auipc	a2,0x2
ffffffffc0204624:	58860613          	addi	a2,a2,1416 # ffffffffc0206ba8 <default_pmm_manager+0xfd0>
ffffffffc0204628:	17000593          	li	a1,368
ffffffffc020462c:	00002517          	auipc	a0,0x2
ffffffffc0204630:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206bd8 <default_pmm_manager+0x1000>
do_exit(int error_code) {
ffffffffc0204634:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204636:	e17fb0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020463a <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc020463a:	00011797          	auipc	a5,0x11
ffffffffc020463e:	fae78793          	addi	a5,a5,-82 # ffffffffc02155e8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204642:	1101                	addi	sp,sp,-32
ffffffffc0204644:	00011717          	auipc	a4,0x11
ffffffffc0204648:	faf73623          	sd	a5,-84(a4) # ffffffffc02155f0 <proc_list+0x8>
ffffffffc020464c:	00011717          	auipc	a4,0x11
ffffffffc0204650:	f8f73e23          	sd	a5,-100(a4) # ffffffffc02155e8 <proc_list>
ffffffffc0204654:	ec06                	sd	ra,24(sp)
ffffffffc0204656:	e822                	sd	s0,16(sp)
ffffffffc0204658:	e426                	sd	s1,8(sp)
ffffffffc020465a:	e04a                	sd	s2,0(sp)
ffffffffc020465c:	0000d797          	auipc	a5,0xd
ffffffffc0204660:	e0478793          	addi	a5,a5,-508 # ffffffffc0211460 <hash_list>
ffffffffc0204664:	00011717          	auipc	a4,0x11
ffffffffc0204668:	dfc70713          	addi	a4,a4,-516 # ffffffffc0215460 <name.1565>
ffffffffc020466c:	e79c                	sd	a5,8(a5)
ffffffffc020466e:	e39c                	sd	a5,0(a5)
ffffffffc0204670:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204672:	fee79de3          	bne	a5,a4,ffffffffc020466c <proc_init+0x32>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204676:	b2bff0ef          	jal	ra,ffffffffc02041a0 <alloc_proc>
ffffffffc020467a:	00011797          	auipc	a5,0x11
ffffffffc020467e:	e2a7bb23          	sd	a0,-458(a5) # ffffffffc02154b0 <idleproc>
ffffffffc0204682:	00011417          	auipc	s0,0x11
ffffffffc0204686:	e2e40413          	addi	s0,s0,-466 # ffffffffc02154b0 <idleproc>
ffffffffc020468a:	14050c63          	beqz	a0,ffffffffc02047e2 <proc_init+0x1a8>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020468e:	07000513          	li	a0,112
ffffffffc0204692:	adefd0ef          	jal	ra,ffffffffc0201970 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204696:	07000613          	li	a2,112
ffffffffc020469a:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020469c:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020469e:	7a8000ef          	jal	ra,ffffffffc0204e46 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02046a2:	6008                	ld	a0,0(s0)
ffffffffc02046a4:	85a6                	mv	a1,s1
ffffffffc02046a6:	07000613          	li	a2,112
ffffffffc02046aa:	03050513          	addi	a0,a0,48
ffffffffc02046ae:	7c2000ef          	jal	ra,ffffffffc0204e70 <memcmp>
ffffffffc02046b2:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02046b4:	453d                	li	a0,15
ffffffffc02046b6:	abafd0ef          	jal	ra,ffffffffc0201970 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02046ba:	463d                	li	a2,15
ffffffffc02046bc:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02046be:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02046c0:	786000ef          	jal	ra,ffffffffc0204e46 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02046c4:	6008                	ld	a0,0(s0)
ffffffffc02046c6:	463d                	li	a2,15
ffffffffc02046c8:	85a6                	mv	a1,s1
ffffffffc02046ca:	0b450513          	addi	a0,a0,180
ffffffffc02046ce:	7a2000ef          	jal	ra,ffffffffc0204e70 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02046d2:	601c                	ld	a5,0(s0)
ffffffffc02046d4:	00011717          	auipc	a4,0x11
ffffffffc02046d8:	e2470713          	addi	a4,a4,-476 # ffffffffc02154f8 <boot_cr3>
ffffffffc02046dc:	6318                	ld	a4,0(a4)
ffffffffc02046de:	77d4                	ld	a3,168(a5)
ffffffffc02046e0:	0ae68f63          	beq	a3,a4,ffffffffc020479e <proc_init+0x164>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02046e4:	4709                	li	a4,2
ffffffffc02046e6:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc02046e8:	4485                	li	s1,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02046ea:	00003717          	auipc	a4,0x3
ffffffffc02046ee:	91670713          	addi	a4,a4,-1770 # ffffffffc0207000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc02046f2:	00002597          	auipc	a1,0x2
ffffffffc02046f6:	58658593          	addi	a1,a1,1414 # ffffffffc0206c78 <default_pmm_manager+0x10a0>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02046fa:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc02046fc:	cf84                	sw	s1,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02046fe:	853e                	mv	a0,a5
ffffffffc0204700:	b15ff0ef          	jal	ra,ffffffffc0204214 <set_proc_name>
    nr_process ++;
ffffffffc0204704:	00011797          	auipc	a5,0x11
ffffffffc0204708:	dbc78793          	addi	a5,a5,-580 # ffffffffc02154c0 <nr_process>
ffffffffc020470c:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc020470e:	6018                	ld	a4,0(s0)
    cprintf("this initproc, pid = 1, name = \"init\"\n");
ffffffffc0204710:	00002517          	auipc	a0,0x2
ffffffffc0204714:	57050513          	addi	a0,a0,1392 # ffffffffc0206c80 <default_pmm_manager+0x10a8>
    nr_process ++;
ffffffffc0204718:	2785                	addiw	a5,a5,1
ffffffffc020471a:	00011697          	auipc	a3,0x11
ffffffffc020471e:	daf6a323          	sw	a5,-602(a3) # ffffffffc02154c0 <nr_process>
    current = idleproc;
ffffffffc0204722:	00011797          	auipc	a5,0x11
ffffffffc0204726:	d8e7b323          	sd	a4,-634(a5) # ffffffffc02154a8 <current>
    cprintf("this initproc, pid = 1, name = \"init\"\n");
ffffffffc020472a:	a65fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"Hello world!!\".\n");
ffffffffc020472e:	00002517          	auipc	a0,0x2
ffffffffc0204732:	57a50513          	addi	a0,a0,1402 # ffffffffc0206ca8 <default_pmm_manager+0x10d0>
ffffffffc0204736:	a59fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc020473a:	00002517          	auipc	a0,0x2
ffffffffc020473e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206c28 <default_pmm_manager+0x1050>
ffffffffc0204742:	a4dfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204746:	4601                	li	a2,0
ffffffffc0204748:	00002597          	auipc	a1,0x2
ffffffffc020474c:	57858593          	addi	a1,a1,1400 # ffffffffc0206cc0 <default_pmm_manager+0x10e8>
ffffffffc0204750:	00000517          	auipc	a0,0x0
ffffffffc0204754:	b1e50513          	addi	a0,a0,-1250 # ffffffffc020426e <init_main>
ffffffffc0204758:	e77ff0ef          	jal	ra,ffffffffc02045ce <kernel_thread>
    if (pid <= 0) {
ffffffffc020475c:	0ca05f63          	blez	a0,ffffffffc020483a <proc_init+0x200>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204760:	bb1ff0ef          	jal	ra,ffffffffc0204310 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0204764:	00002597          	auipc	a1,0x2
ffffffffc0204768:	58c58593          	addi	a1,a1,1420 # ffffffffc0206cf0 <default_pmm_manager+0x1118>
    initproc = find_proc(pid);
ffffffffc020476c:	00011797          	auipc	a5,0x11
ffffffffc0204770:	d4a7b623          	sd	a0,-692(a5) # ffffffffc02154b8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204774:	aa1ff0ef          	jal	ra,ffffffffc0204214 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204778:	601c                	ld	a5,0(s0)
ffffffffc020477a:	c3c5                	beqz	a5,ffffffffc020481a <proc_init+0x1e0>
ffffffffc020477c:	43dc                	lw	a5,4(a5)
ffffffffc020477e:	efd1                	bnez	a5,ffffffffc020481a <proc_init+0x1e0>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204780:	00011797          	auipc	a5,0x11
ffffffffc0204784:	d3878793          	addi	a5,a5,-712 # ffffffffc02154b8 <initproc>
ffffffffc0204788:	639c                	ld	a5,0(a5)
ffffffffc020478a:	cba5                	beqz	a5,ffffffffc02047fa <proc_init+0x1c0>
ffffffffc020478c:	43dc                	lw	a5,4(a5)
ffffffffc020478e:	06979663          	bne	a5,s1,ffffffffc02047fa <proc_init+0x1c0>
}
ffffffffc0204792:	60e2                	ld	ra,24(sp)
ffffffffc0204794:	6442                	ld	s0,16(sp)
ffffffffc0204796:	64a2                	ld	s1,8(sp)
ffffffffc0204798:	6902                	ld	s2,0(sp)
ffffffffc020479a:	6105                	addi	sp,sp,32
ffffffffc020479c:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020479e:	73d8                	ld	a4,160(a5)
ffffffffc02047a0:	f331                	bnez	a4,ffffffffc02046e4 <proc_init+0xaa>
ffffffffc02047a2:	f40911e3          	bnez	s2,ffffffffc02046e4 <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02047a6:	6394                	ld	a3,0(a5)
ffffffffc02047a8:	577d                	li	a4,-1
ffffffffc02047aa:	1702                	slli	a4,a4,0x20
ffffffffc02047ac:	f2e69ce3          	bne	a3,a4,ffffffffc02046e4 <proc_init+0xaa>
ffffffffc02047b0:	4798                	lw	a4,8(a5)
ffffffffc02047b2:	fb0d                	bnez	a4,ffffffffc02046e4 <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02047b4:	6b98                	ld	a4,16(a5)
ffffffffc02047b6:	f71d                	bnez	a4,ffffffffc02046e4 <proc_init+0xaa>
ffffffffc02047b8:	4f98                	lw	a4,24(a5)
ffffffffc02047ba:	2701                	sext.w	a4,a4
ffffffffc02047bc:	f705                	bnez	a4,ffffffffc02046e4 <proc_init+0xaa>
ffffffffc02047be:	7398                	ld	a4,32(a5)
ffffffffc02047c0:	f315                	bnez	a4,ffffffffc02046e4 <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02047c2:	7798                	ld	a4,40(a5)
ffffffffc02047c4:	f305                	bnez	a4,ffffffffc02046e4 <proc_init+0xaa>
ffffffffc02047c6:	0b07a703          	lw	a4,176(a5)
ffffffffc02047ca:	8f49                	or	a4,a4,a0
ffffffffc02047cc:	2701                	sext.w	a4,a4
ffffffffc02047ce:	f0071be3          	bnez	a4,ffffffffc02046e4 <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc02047d2:	00002517          	auipc	a0,0x2
ffffffffc02047d6:	48e50513          	addi	a0,a0,1166 # ffffffffc0206c60 <default_pmm_manager+0x1088>
ffffffffc02047da:	9b5fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02047de:	601c                	ld	a5,0(s0)
ffffffffc02047e0:	b711                	j	ffffffffc02046e4 <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc02047e2:	00002617          	auipc	a2,0x2
ffffffffc02047e6:	46660613          	addi	a2,a2,1126 # ffffffffc0206c48 <default_pmm_manager+0x1070>
ffffffffc02047ea:	18800593          	li	a1,392
ffffffffc02047ee:	00002517          	auipc	a0,0x2
ffffffffc02047f2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206bd8 <default_pmm_manager+0x1000>
ffffffffc02047f6:	c57fb0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02047fa:	00002697          	auipc	a3,0x2
ffffffffc02047fe:	52668693          	addi	a3,a3,1318 # ffffffffc0206d20 <default_pmm_manager+0x1148>
ffffffffc0204802:	00001617          	auipc	a2,0x1
ffffffffc0204806:	03e60613          	addi	a2,a2,62 # ffffffffc0205840 <commands+0x870>
ffffffffc020480a:	1b100593          	li	a1,433
ffffffffc020480e:	00002517          	auipc	a0,0x2
ffffffffc0204812:	3ca50513          	addi	a0,a0,970 # ffffffffc0206bd8 <default_pmm_manager+0x1000>
ffffffffc0204816:	c37fb0ef          	jal	ra,ffffffffc020044c <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020481a:	00002697          	auipc	a3,0x2
ffffffffc020481e:	4de68693          	addi	a3,a3,1246 # ffffffffc0206cf8 <default_pmm_manager+0x1120>
ffffffffc0204822:	00001617          	auipc	a2,0x1
ffffffffc0204826:	01e60613          	addi	a2,a2,30 # ffffffffc0205840 <commands+0x870>
ffffffffc020482a:	1b000593          	li	a1,432
ffffffffc020482e:	00002517          	auipc	a0,0x2
ffffffffc0204832:	3aa50513          	addi	a0,a0,938 # ffffffffc0206bd8 <default_pmm_manager+0x1000>
ffffffffc0204836:	c17fb0ef          	jal	ra,ffffffffc020044c <__panic>
        panic("create init_main failed.\n");
ffffffffc020483a:	00002617          	auipc	a2,0x2
ffffffffc020483e:	49660613          	addi	a2,a2,1174 # ffffffffc0206cd0 <default_pmm_manager+0x10f8>
ffffffffc0204842:	1aa00593          	li	a1,426
ffffffffc0204846:	00002517          	auipc	a0,0x2
ffffffffc020484a:	39250513          	addi	a0,a0,914 # ffffffffc0206bd8 <default_pmm_manager+0x1000>
ffffffffc020484e:	bfffb0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc0204852 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204852:	1141                	addi	sp,sp,-16
ffffffffc0204854:	e022                	sd	s0,0(sp)
ffffffffc0204856:	e406                	sd	ra,8(sp)
ffffffffc0204858:	00011417          	auipc	s0,0x11
ffffffffc020485c:	c5040413          	addi	s0,s0,-944 # ffffffffc02154a8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204860:	6018                	ld	a4,0(s0)
ffffffffc0204862:	4f1c                	lw	a5,24(a4)
ffffffffc0204864:	2781                	sext.w	a5,a5
ffffffffc0204866:	dff5                	beqz	a5,ffffffffc0204862 <cpu_idle+0x10>
            schedule();
ffffffffc0204868:	0a2000ef          	jal	ra,ffffffffc020490a <schedule>
ffffffffc020486c:	bfd5                	j	ffffffffc0204860 <cpu_idle+0xe>

ffffffffc020486e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020486e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204872:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204876:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204878:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020487a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020487e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204882:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204886:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020488a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020488e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204892:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204896:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020489a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020489e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02048a2:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02048a6:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02048aa:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02048ac:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02048ae:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02048b2:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02048b6:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02048ba:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02048be:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02048c2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02048c6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02048ca:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02048ce:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02048d2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02048d6:	8082                	ret

ffffffffc02048d8 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048d8:	411c                	lw	a5,0(a0)
ffffffffc02048da:	4705                	li	a4,1
ffffffffc02048dc:	37f9                	addiw	a5,a5,-2
ffffffffc02048de:	00f77563          	bgeu	a4,a5,ffffffffc02048e8 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc02048e2:	4789                	li	a5,2
ffffffffc02048e4:	c11c                	sw	a5,0(a0)
ffffffffc02048e6:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc02048e8:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02048ea:	00002697          	auipc	a3,0x2
ffffffffc02048ee:	45e68693          	addi	a3,a3,1118 # ffffffffc0206d48 <default_pmm_manager+0x1170>
ffffffffc02048f2:	00001617          	auipc	a2,0x1
ffffffffc02048f6:	f4e60613          	addi	a2,a2,-178 # ffffffffc0205840 <commands+0x870>
ffffffffc02048fa:	45a5                	li	a1,9
ffffffffc02048fc:	00002517          	auipc	a0,0x2
ffffffffc0204900:	48c50513          	addi	a0,a0,1164 # ffffffffc0206d88 <default_pmm_manager+0x11b0>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204904:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204906:	b47fb0ef          	jal	ra,ffffffffc020044c <__panic>

ffffffffc020490a <schedule>:
}

void
schedule(void) {
ffffffffc020490a:	1141                	addi	sp,sp,-16
ffffffffc020490c:	e406                	sd	ra,8(sp)
ffffffffc020490e:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204910:	100027f3          	csrr	a5,sstatus
ffffffffc0204914:	8b89                	andi	a5,a5,2
ffffffffc0204916:	4401                	li	s0,0
ffffffffc0204918:	e3d1                	bnez	a5,ffffffffc020499c <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020491a:	00011797          	auipc	a5,0x11
ffffffffc020491e:	b8e78793          	addi	a5,a5,-1138 # ffffffffc02154a8 <current>
ffffffffc0204922:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204926:	00011797          	auipc	a5,0x11
ffffffffc020492a:	b8a78793          	addi	a5,a5,-1142 # ffffffffc02154b0 <idleproc>
ffffffffc020492e:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0204930:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204934:	04a88e63          	beq	a7,a0,ffffffffc0204990 <schedule+0x86>
ffffffffc0204938:	0c888693          	addi	a3,a7,200
ffffffffc020493c:	00011617          	auipc	a2,0x11
ffffffffc0204940:	cac60613          	addi	a2,a2,-852 # ffffffffc02155e8 <proc_list>
        le = last;
ffffffffc0204944:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204946:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204948:	4809                	li	a6,2
    return listelm->next;
ffffffffc020494a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020494c:	00c78863          	beq	a5,a2,ffffffffc020495c <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204950:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204954:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204958:	01070463          	beq	a4,a6,ffffffffc0204960 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc020495c:	fef697e3          	bne	a3,a5,ffffffffc020494a <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204960:	c589                	beqz	a1,ffffffffc020496a <schedule+0x60>
ffffffffc0204962:	4198                	lw	a4,0(a1)
ffffffffc0204964:	4789                	li	a5,2
ffffffffc0204966:	00f70e63          	beq	a4,a5,ffffffffc0204982 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020496a:	451c                	lw	a5,8(a0)
ffffffffc020496c:	2785                	addiw	a5,a5,1
ffffffffc020496e:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0204970:	00a88463          	beq	a7,a0,ffffffffc0204978 <schedule+0x6e>
            proc_run(next);
ffffffffc0204974:	94dff0ef          	jal	ra,ffffffffc02042c0 <proc_run>
    if (flag) {
ffffffffc0204978:	e419                	bnez	s0,ffffffffc0204986 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020497a:	60a2                	ld	ra,8(sp)
ffffffffc020497c:	6402                	ld	s0,0(sp)
ffffffffc020497e:	0141                	addi	sp,sp,16
ffffffffc0204980:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204982:	852e                	mv	a0,a1
ffffffffc0204984:	b7dd                	j	ffffffffc020496a <schedule+0x60>
}
ffffffffc0204986:	6402                	ld	s0,0(sp)
ffffffffc0204988:	60a2                	ld	ra,8(sp)
ffffffffc020498a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020498c:	c3ffb06f          	j	ffffffffc02005ca <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204990:	00011617          	auipc	a2,0x11
ffffffffc0204994:	c5860613          	addi	a2,a2,-936 # ffffffffc02155e8 <proc_list>
ffffffffc0204998:	86b2                	mv	a3,a2
ffffffffc020499a:	b76d                	j	ffffffffc0204944 <schedule+0x3a>
        intr_disable();
ffffffffc020499c:	c35fb0ef          	jal	ra,ffffffffc02005d0 <intr_disable>
        return 1;
ffffffffc02049a0:	4405                	li	s0,1
ffffffffc02049a2:	bfa5                	j	ffffffffc020491a <schedule+0x10>

ffffffffc02049a4 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02049a4:	9e3707b7          	lui	a5,0x9e370
ffffffffc02049a8:	2785                	addiw	a5,a5,1
ffffffffc02049aa:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02049ae:	02000793          	li	a5,32
ffffffffc02049b2:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02049b6:	00b5553b          	srlw	a0,a0,a1
ffffffffc02049ba:	8082                	ret

ffffffffc02049bc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02049bc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02049c0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02049c2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02049c6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02049c8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02049cc:	f022                	sd	s0,32(sp)
ffffffffc02049ce:	ec26                	sd	s1,24(sp)
ffffffffc02049d0:	e84a                	sd	s2,16(sp)
ffffffffc02049d2:	f406                	sd	ra,40(sp)
ffffffffc02049d4:	e44e                	sd	s3,8(sp)
ffffffffc02049d6:	84aa                	mv	s1,a0
ffffffffc02049d8:	892e                	mv	s2,a1
ffffffffc02049da:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02049de:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02049e0:	03067e63          	bgeu	a2,a6,ffffffffc0204a1c <printnum+0x60>
ffffffffc02049e4:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02049e6:	00805763          	blez	s0,ffffffffc02049f4 <printnum+0x38>
ffffffffc02049ea:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02049ec:	85ca                	mv	a1,s2
ffffffffc02049ee:	854e                	mv	a0,s3
ffffffffc02049f0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02049f2:	fc65                	bnez	s0,ffffffffc02049ea <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02049f4:	1a02                	slli	s4,s4,0x20
ffffffffc02049f6:	020a5a13          	srli	s4,s4,0x20
ffffffffc02049fa:	00002797          	auipc	a5,0x2
ffffffffc02049fe:	53678793          	addi	a5,a5,1334 # ffffffffc0206f30 <error_string+0x38>
ffffffffc0204a02:	9a3e                	add	s4,s4,a5
}
ffffffffc0204a04:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a06:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204a0a:	70a2                	ld	ra,40(sp)
ffffffffc0204a0c:	69a2                	ld	s3,8(sp)
ffffffffc0204a0e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a10:	85ca                	mv	a1,s2
ffffffffc0204a12:	8326                	mv	t1,s1
}
ffffffffc0204a14:	6942                	ld	s2,16(sp)
ffffffffc0204a16:	64e2                	ld	s1,24(sp)
ffffffffc0204a18:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a1a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204a1c:	03065633          	divu	a2,a2,a6
ffffffffc0204a20:	8722                	mv	a4,s0
ffffffffc0204a22:	f9bff0ef          	jal	ra,ffffffffc02049bc <printnum>
ffffffffc0204a26:	b7f9                	j	ffffffffc02049f4 <printnum+0x38>

ffffffffc0204a28 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204a28:	7119                	addi	sp,sp,-128
ffffffffc0204a2a:	f4a6                	sd	s1,104(sp)
ffffffffc0204a2c:	f0ca                	sd	s2,96(sp)
ffffffffc0204a2e:	e8d2                	sd	s4,80(sp)
ffffffffc0204a30:	e4d6                	sd	s5,72(sp)
ffffffffc0204a32:	e0da                	sd	s6,64(sp)
ffffffffc0204a34:	fc5e                	sd	s7,56(sp)
ffffffffc0204a36:	f862                	sd	s8,48(sp)
ffffffffc0204a38:	f06a                	sd	s10,32(sp)
ffffffffc0204a3a:	fc86                	sd	ra,120(sp)
ffffffffc0204a3c:	f8a2                	sd	s0,112(sp)
ffffffffc0204a3e:	ecce                	sd	s3,88(sp)
ffffffffc0204a40:	f466                	sd	s9,40(sp)
ffffffffc0204a42:	ec6e                	sd	s11,24(sp)
ffffffffc0204a44:	892a                	mv	s2,a0
ffffffffc0204a46:	84ae                	mv	s1,a1
ffffffffc0204a48:	8d32                	mv	s10,a2
ffffffffc0204a4a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204a4c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a4e:	00002a17          	auipc	s4,0x2
ffffffffc0204a52:	352a0a13          	addi	s4,s4,850 # ffffffffc0206da0 <default_pmm_manager+0x11c8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204a56:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204a5a:	00002c17          	auipc	s8,0x2
ffffffffc0204a5e:	49ec0c13          	addi	s8,s8,1182 # ffffffffc0206ef8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204a62:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204a66:	02500793          	li	a5,37
ffffffffc0204a6a:	001d0413          	addi	s0,s10,1
ffffffffc0204a6e:	00f50e63          	beq	a0,a5,ffffffffc0204a8a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204a72:	c521                	beqz	a0,ffffffffc0204aba <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204a74:	02500993          	li	s3,37
ffffffffc0204a78:	a011                	j	ffffffffc0204a7c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204a7a:	c121                	beqz	a0,ffffffffc0204aba <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204a7c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204a7e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204a80:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204a82:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204a86:	ff351ae3          	bne	a0,s3,ffffffffc0204a7a <vprintfmt+0x52>
ffffffffc0204a8a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204a8e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204a92:	4981                	li	s3,0
ffffffffc0204a94:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204a96:	5cfd                	li	s9,-1
ffffffffc0204a98:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a9a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204a9e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204aa0:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204aa4:	0ff6f693          	andi	a3,a3,255
ffffffffc0204aa8:	00140d13          	addi	s10,s0,1
ffffffffc0204aac:	1ed5ef63          	bltu	a1,a3,ffffffffc0204caa <vprintfmt+0x282>
ffffffffc0204ab0:	068a                	slli	a3,a3,0x2
ffffffffc0204ab2:	96d2                	add	a3,a3,s4
ffffffffc0204ab4:	4294                	lw	a3,0(a3)
ffffffffc0204ab6:	96d2                	add	a3,a3,s4
ffffffffc0204ab8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204aba:	70e6                	ld	ra,120(sp)
ffffffffc0204abc:	7446                	ld	s0,112(sp)
ffffffffc0204abe:	74a6                	ld	s1,104(sp)
ffffffffc0204ac0:	7906                	ld	s2,96(sp)
ffffffffc0204ac2:	69e6                	ld	s3,88(sp)
ffffffffc0204ac4:	6a46                	ld	s4,80(sp)
ffffffffc0204ac6:	6aa6                	ld	s5,72(sp)
ffffffffc0204ac8:	6b06                	ld	s6,64(sp)
ffffffffc0204aca:	7be2                	ld	s7,56(sp)
ffffffffc0204acc:	7c42                	ld	s8,48(sp)
ffffffffc0204ace:	7ca2                	ld	s9,40(sp)
ffffffffc0204ad0:	7d02                	ld	s10,32(sp)
ffffffffc0204ad2:	6de2                	ld	s11,24(sp)
ffffffffc0204ad4:	6109                	addi	sp,sp,128
ffffffffc0204ad6:	8082                	ret
            padc = '-';
ffffffffc0204ad8:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ada:	00144603          	lbu	a2,1(s0)
ffffffffc0204ade:	846a                	mv	s0,s10
ffffffffc0204ae0:	b7c1                	j	ffffffffc0204aa0 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0204ae2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204ae6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204aea:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204aec:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204aee:	fa0dd9e3          	bgez	s11,ffffffffc0204aa0 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204af2:	8de6                	mv	s11,s9
ffffffffc0204af4:	5cfd                	li	s9,-1
ffffffffc0204af6:	b76d                	j	ffffffffc0204aa0 <vprintfmt+0x78>
            if (width < 0)
ffffffffc0204af8:	fffdc693          	not	a3,s11
ffffffffc0204afc:	96fd                	srai	a3,a3,0x3f
ffffffffc0204afe:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204b02:	00144603          	lbu	a2,1(s0)
ffffffffc0204b06:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b08:	846a                	mv	s0,s10
ffffffffc0204b0a:	bf59                	j	ffffffffc0204aa0 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204b0c:	4705                	li	a4,1
ffffffffc0204b0e:	008a8593          	addi	a1,s5,8
ffffffffc0204b12:	01074463          	blt	a4,a6,ffffffffc0204b1a <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0204b16:	22080863          	beqz	a6,ffffffffc0204d46 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0204b1a:	000ab603          	ld	a2,0(s5)
ffffffffc0204b1e:	46c1                	li	a3,16
ffffffffc0204b20:	8aae                	mv	s5,a1
ffffffffc0204b22:	a291                	j	ffffffffc0204c66 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0204b24:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204b28:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b2c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204b2e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204b32:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204b36:	fad56ce3          	bltu	a0,a3,ffffffffc0204aee <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204b3a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204b3c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204b40:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204b44:	0196873b          	addw	a4,a3,s9
ffffffffc0204b48:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204b4c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204b50:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204b54:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204b58:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204b5c:	fcd57fe3          	bgeu	a0,a3,ffffffffc0204b3a <vprintfmt+0x112>
ffffffffc0204b60:	b779                	j	ffffffffc0204aee <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0204b62:	000aa503          	lw	a0,0(s5)
ffffffffc0204b66:	85a6                	mv	a1,s1
ffffffffc0204b68:	0aa1                	addi	s5,s5,8
ffffffffc0204b6a:	9902                	jalr	s2
            break;
ffffffffc0204b6c:	bddd                	j	ffffffffc0204a62 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204b6e:	4705                	li	a4,1
ffffffffc0204b70:	008a8993          	addi	s3,s5,8
ffffffffc0204b74:	01074463          	blt	a4,a6,ffffffffc0204b7c <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0204b78:	1c080463          	beqz	a6,ffffffffc0204d40 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0204b7c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204b80:	1c044a63          	bltz	s0,ffffffffc0204d54 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0204b84:	8622                	mv	a2,s0
ffffffffc0204b86:	8ace                	mv	s5,s3
ffffffffc0204b88:	46a9                	li	a3,10
ffffffffc0204b8a:	a8f1                	j	ffffffffc0204c66 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0204b8c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b90:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204b92:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204b94:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204b98:	8fb5                	xor	a5,a5,a3
ffffffffc0204b9a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b9e:	12d74963          	blt	a4,a3,ffffffffc0204cd0 <vprintfmt+0x2a8>
ffffffffc0204ba2:	00369793          	slli	a5,a3,0x3
ffffffffc0204ba6:	97e2                	add	a5,a5,s8
ffffffffc0204ba8:	639c                	ld	a5,0(a5)
ffffffffc0204baa:	12078363          	beqz	a5,ffffffffc0204cd0 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204bae:	86be                	mv	a3,a5
ffffffffc0204bb0:	00000617          	auipc	a2,0x0
ffffffffc0204bb4:	31860613          	addi	a2,a2,792 # ffffffffc0204ec8 <etext+0x28>
ffffffffc0204bb8:	85a6                	mv	a1,s1
ffffffffc0204bba:	854a                	mv	a0,s2
ffffffffc0204bbc:	1cc000ef          	jal	ra,ffffffffc0204d88 <printfmt>
ffffffffc0204bc0:	b54d                	j	ffffffffc0204a62 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204bc2:	000ab603          	ld	a2,0(s5)
ffffffffc0204bc6:	0aa1                	addi	s5,s5,8
ffffffffc0204bc8:	1a060163          	beqz	a2,ffffffffc0204d6a <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0204bcc:	00160413          	addi	s0,a2,1
ffffffffc0204bd0:	15b05763          	blez	s11,ffffffffc0204d1e <vprintfmt+0x2f6>
ffffffffc0204bd4:	02d00593          	li	a1,45
ffffffffc0204bd8:	10b79d63          	bne	a5,a1,ffffffffc0204cf2 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204bdc:	00064783          	lbu	a5,0(a2)
ffffffffc0204be0:	0007851b          	sext.w	a0,a5
ffffffffc0204be4:	c905                	beqz	a0,ffffffffc0204c14 <vprintfmt+0x1ec>
ffffffffc0204be6:	000cc563          	bltz	s9,ffffffffc0204bf0 <vprintfmt+0x1c8>
ffffffffc0204bea:	3cfd                	addiw	s9,s9,-1
ffffffffc0204bec:	036c8263          	beq	s9,s6,ffffffffc0204c10 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0204bf0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204bf2:	14098f63          	beqz	s3,ffffffffc0204d50 <vprintfmt+0x328>
ffffffffc0204bf6:	3781                	addiw	a5,a5,-32
ffffffffc0204bf8:	14fbfc63          	bgeu	s7,a5,ffffffffc0204d50 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0204bfc:	03f00513          	li	a0,63
ffffffffc0204c00:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c02:	0405                	addi	s0,s0,1
ffffffffc0204c04:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204c08:	3dfd                	addiw	s11,s11,-1
ffffffffc0204c0a:	0007851b          	sext.w	a0,a5
ffffffffc0204c0e:	fd61                	bnez	a0,ffffffffc0204be6 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0204c10:	e5b059e3          	blez	s11,ffffffffc0204a62 <vprintfmt+0x3a>
ffffffffc0204c14:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204c16:	85a6                	mv	a1,s1
ffffffffc0204c18:	02000513          	li	a0,32
ffffffffc0204c1c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204c1e:	e40d82e3          	beqz	s11,ffffffffc0204a62 <vprintfmt+0x3a>
ffffffffc0204c22:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204c24:	85a6                	mv	a1,s1
ffffffffc0204c26:	02000513          	li	a0,32
ffffffffc0204c2a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204c2c:	fe0d94e3          	bnez	s11,ffffffffc0204c14 <vprintfmt+0x1ec>
ffffffffc0204c30:	bd0d                	j	ffffffffc0204a62 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204c32:	4705                	li	a4,1
ffffffffc0204c34:	008a8593          	addi	a1,s5,8
ffffffffc0204c38:	01074463          	blt	a4,a6,ffffffffc0204c40 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0204c3c:	0e080863          	beqz	a6,ffffffffc0204d2c <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0204c40:	000ab603          	ld	a2,0(s5)
ffffffffc0204c44:	46a1                	li	a3,8
ffffffffc0204c46:	8aae                	mv	s5,a1
ffffffffc0204c48:	a839                	j	ffffffffc0204c66 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0204c4a:	03000513          	li	a0,48
ffffffffc0204c4e:	85a6                	mv	a1,s1
ffffffffc0204c50:	e03e                	sd	a5,0(sp)
ffffffffc0204c52:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204c54:	85a6                	mv	a1,s1
ffffffffc0204c56:	07800513          	li	a0,120
ffffffffc0204c5a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204c5c:	0aa1                	addi	s5,s5,8
ffffffffc0204c5e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204c62:	6782                	ld	a5,0(sp)
ffffffffc0204c64:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204c66:	2781                	sext.w	a5,a5
ffffffffc0204c68:	876e                	mv	a4,s11
ffffffffc0204c6a:	85a6                	mv	a1,s1
ffffffffc0204c6c:	854a                	mv	a0,s2
ffffffffc0204c6e:	d4fff0ef          	jal	ra,ffffffffc02049bc <printnum>
            break;
ffffffffc0204c72:	bbc5                	j	ffffffffc0204a62 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204c74:	00144603          	lbu	a2,1(s0)
ffffffffc0204c78:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c7a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c7c:	b515                	j	ffffffffc0204aa0 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204c7e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204c82:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c84:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c86:	bd29                	j	ffffffffc0204aa0 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204c88:	85a6                	mv	a1,s1
ffffffffc0204c8a:	02500513          	li	a0,37
ffffffffc0204c8e:	9902                	jalr	s2
            break;
ffffffffc0204c90:	bbc9                	j	ffffffffc0204a62 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204c92:	4705                	li	a4,1
ffffffffc0204c94:	008a8593          	addi	a1,s5,8
ffffffffc0204c98:	01074463          	blt	a4,a6,ffffffffc0204ca0 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0204c9c:	08080d63          	beqz	a6,ffffffffc0204d36 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0204ca0:	000ab603          	ld	a2,0(s5)
ffffffffc0204ca4:	46a9                	li	a3,10
ffffffffc0204ca6:	8aae                	mv	s5,a1
ffffffffc0204ca8:	bf7d                	j	ffffffffc0204c66 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0204caa:	85a6                	mv	a1,s1
ffffffffc0204cac:	02500513          	li	a0,37
ffffffffc0204cb0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204cb2:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204cb6:	02500793          	li	a5,37
ffffffffc0204cba:	8d22                	mv	s10,s0
ffffffffc0204cbc:	daf703e3          	beq	a4,a5,ffffffffc0204a62 <vprintfmt+0x3a>
ffffffffc0204cc0:	02500713          	li	a4,37
ffffffffc0204cc4:	1d7d                	addi	s10,s10,-1
ffffffffc0204cc6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204cca:	fee79de3          	bne	a5,a4,ffffffffc0204cc4 <vprintfmt+0x29c>
ffffffffc0204cce:	bb51                	j	ffffffffc0204a62 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204cd0:	00002617          	auipc	a2,0x2
ffffffffc0204cd4:	30060613          	addi	a2,a2,768 # ffffffffc0206fd0 <error_string+0xd8>
ffffffffc0204cd8:	85a6                	mv	a1,s1
ffffffffc0204cda:	854a                	mv	a0,s2
ffffffffc0204cdc:	0ac000ef          	jal	ra,ffffffffc0204d88 <printfmt>
ffffffffc0204ce0:	b349                	j	ffffffffc0204a62 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204ce2:	00002617          	auipc	a2,0x2
ffffffffc0204ce6:	2e660613          	addi	a2,a2,742 # ffffffffc0206fc8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204cea:	00002417          	auipc	s0,0x2
ffffffffc0204cee:	2df40413          	addi	s0,s0,735 # ffffffffc0206fc9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204cf2:	8532                	mv	a0,a2
ffffffffc0204cf4:	85e6                	mv	a1,s9
ffffffffc0204cf6:	e032                	sd	a2,0(sp)
ffffffffc0204cf8:	e43e                	sd	a5,8(sp)
ffffffffc0204cfa:	0cc000ef          	jal	ra,ffffffffc0204dc6 <strnlen>
ffffffffc0204cfe:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204d02:	6602                	ld	a2,0(sp)
ffffffffc0204d04:	01b05d63          	blez	s11,ffffffffc0204d1e <vprintfmt+0x2f6>
ffffffffc0204d08:	67a2                	ld	a5,8(sp)
ffffffffc0204d0a:	2781                	sext.w	a5,a5
ffffffffc0204d0c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204d0e:	6522                	ld	a0,8(sp)
ffffffffc0204d10:	85a6                	mv	a1,s1
ffffffffc0204d12:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d14:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204d16:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d18:	6602                	ld	a2,0(sp)
ffffffffc0204d1a:	fe0d9ae3          	bnez	s11,ffffffffc0204d0e <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d1e:	00064783          	lbu	a5,0(a2)
ffffffffc0204d22:	0007851b          	sext.w	a0,a5
ffffffffc0204d26:	ec0510e3          	bnez	a0,ffffffffc0204be6 <vprintfmt+0x1be>
ffffffffc0204d2a:	bb25                	j	ffffffffc0204a62 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0204d2c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204d30:	46a1                	li	a3,8
ffffffffc0204d32:	8aae                	mv	s5,a1
ffffffffc0204d34:	bf0d                	j	ffffffffc0204c66 <vprintfmt+0x23e>
ffffffffc0204d36:	000ae603          	lwu	a2,0(s5)
ffffffffc0204d3a:	46a9                	li	a3,10
ffffffffc0204d3c:	8aae                	mv	s5,a1
ffffffffc0204d3e:	b725                	j	ffffffffc0204c66 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0204d40:	000aa403          	lw	s0,0(s5)
ffffffffc0204d44:	bd35                	j	ffffffffc0204b80 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0204d46:	000ae603          	lwu	a2,0(s5)
ffffffffc0204d4a:	46c1                	li	a3,16
ffffffffc0204d4c:	8aae                	mv	s5,a1
ffffffffc0204d4e:	bf21                	j	ffffffffc0204c66 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0204d50:	9902                	jalr	s2
ffffffffc0204d52:	bd45                	j	ffffffffc0204c02 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0204d54:	85a6                	mv	a1,s1
ffffffffc0204d56:	02d00513          	li	a0,45
ffffffffc0204d5a:	e03e                	sd	a5,0(sp)
ffffffffc0204d5c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204d5e:	8ace                	mv	s5,s3
ffffffffc0204d60:	40800633          	neg	a2,s0
ffffffffc0204d64:	46a9                	li	a3,10
ffffffffc0204d66:	6782                	ld	a5,0(sp)
ffffffffc0204d68:	bdfd                	j	ffffffffc0204c66 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0204d6a:	01b05663          	blez	s11,ffffffffc0204d76 <vprintfmt+0x34e>
ffffffffc0204d6e:	02d00693          	li	a3,45
ffffffffc0204d72:	f6d798e3          	bne	a5,a3,ffffffffc0204ce2 <vprintfmt+0x2ba>
ffffffffc0204d76:	00002417          	auipc	s0,0x2
ffffffffc0204d7a:	25340413          	addi	s0,s0,595 # ffffffffc0206fc9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d7e:	02800513          	li	a0,40
ffffffffc0204d82:	02800793          	li	a5,40
ffffffffc0204d86:	b585                	j	ffffffffc0204be6 <vprintfmt+0x1be>

ffffffffc0204d88 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204d88:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204d8a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204d8e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204d90:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204d92:	ec06                	sd	ra,24(sp)
ffffffffc0204d94:	f83a                	sd	a4,48(sp)
ffffffffc0204d96:	fc3e                	sd	a5,56(sp)
ffffffffc0204d98:	e0c2                	sd	a6,64(sp)
ffffffffc0204d9a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204d9c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204d9e:	c8bff0ef          	jal	ra,ffffffffc0204a28 <vprintfmt>
}
ffffffffc0204da2:	60e2                	ld	ra,24(sp)
ffffffffc0204da4:	6161                	addi	sp,sp,80
ffffffffc0204da6:	8082                	ret

ffffffffc0204da8 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204da8:	00054783          	lbu	a5,0(a0)
ffffffffc0204dac:	cb91                	beqz	a5,ffffffffc0204dc0 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204dae:	4781                	li	a5,0
        cnt ++;
ffffffffc0204db0:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204db2:	00f50733          	add	a4,a0,a5
ffffffffc0204db6:	00074703          	lbu	a4,0(a4)
ffffffffc0204dba:	fb7d                	bnez	a4,ffffffffc0204db0 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204dbc:	853e                	mv	a0,a5
ffffffffc0204dbe:	8082                	ret
    size_t cnt = 0;
ffffffffc0204dc0:	4781                	li	a5,0
}
ffffffffc0204dc2:	853e                	mv	a0,a5
ffffffffc0204dc4:	8082                	ret

ffffffffc0204dc6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204dc6:	c185                	beqz	a1,ffffffffc0204de6 <strnlen+0x20>
ffffffffc0204dc8:	00054783          	lbu	a5,0(a0)
ffffffffc0204dcc:	cf89                	beqz	a5,ffffffffc0204de6 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204dce:	4781                	li	a5,0
ffffffffc0204dd0:	a021                	j	ffffffffc0204dd8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204dd2:	00074703          	lbu	a4,0(a4)
ffffffffc0204dd6:	c711                	beqz	a4,ffffffffc0204de2 <strnlen+0x1c>
        cnt ++;
ffffffffc0204dd8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204dda:	00f50733          	add	a4,a0,a5
ffffffffc0204dde:	fef59ae3          	bne	a1,a5,ffffffffc0204dd2 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204de2:	853e                	mv	a0,a5
ffffffffc0204de4:	8082                	ret
    size_t cnt = 0;
ffffffffc0204de6:	4781                	li	a5,0
}
ffffffffc0204de8:	853e                	mv	a0,a5
ffffffffc0204dea:	8082                	ret

ffffffffc0204dec <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204dec:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204dee:	0585                	addi	a1,a1,1
ffffffffc0204df0:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204df4:	0785                	addi	a5,a5,1
ffffffffc0204df6:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204dfa:	fb75                	bnez	a4,ffffffffc0204dee <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204dfc:	8082                	ret

ffffffffc0204dfe <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204dfe:	00054783          	lbu	a5,0(a0)
ffffffffc0204e02:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e06:	cb91                	beqz	a5,ffffffffc0204e1a <strcmp+0x1c>
ffffffffc0204e08:	00e79c63          	bne	a5,a4,ffffffffc0204e20 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204e0c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e0e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204e12:	0585                	addi	a1,a1,1
ffffffffc0204e14:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e18:	fbe5                	bnez	a5,ffffffffc0204e08 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204e1a:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204e1c:	9d19                	subw	a0,a0,a4
ffffffffc0204e1e:	8082                	ret
ffffffffc0204e20:	0007851b          	sext.w	a0,a5
ffffffffc0204e24:	9d19                	subw	a0,a0,a4
ffffffffc0204e26:	8082                	ret

ffffffffc0204e28 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204e28:	00054783          	lbu	a5,0(a0)
ffffffffc0204e2c:	cb91                	beqz	a5,ffffffffc0204e40 <strchr+0x18>
        if (*s == c) {
ffffffffc0204e2e:	00b79563          	bne	a5,a1,ffffffffc0204e38 <strchr+0x10>
ffffffffc0204e32:	a809                	j	ffffffffc0204e44 <strchr+0x1c>
ffffffffc0204e34:	00b78763          	beq	a5,a1,ffffffffc0204e42 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204e38:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204e3a:	00054783          	lbu	a5,0(a0)
ffffffffc0204e3e:	fbfd                	bnez	a5,ffffffffc0204e34 <strchr+0xc>
    }
    return NULL;
ffffffffc0204e40:	4501                	li	a0,0
}
ffffffffc0204e42:	8082                	ret
ffffffffc0204e44:	8082                	ret

ffffffffc0204e46 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204e46:	ca01                	beqz	a2,ffffffffc0204e56 <memset+0x10>
ffffffffc0204e48:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204e4a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204e4c:	0785                	addi	a5,a5,1
ffffffffc0204e4e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204e52:	fec79de3          	bne	a5,a2,ffffffffc0204e4c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204e56:	8082                	ret

ffffffffc0204e58 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204e58:	ca19                	beqz	a2,ffffffffc0204e6e <memcpy+0x16>
ffffffffc0204e5a:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204e5c:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204e5e:	0585                	addi	a1,a1,1
ffffffffc0204e60:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204e64:	0785                	addi	a5,a5,1
ffffffffc0204e66:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204e6a:	fec59ae3          	bne	a1,a2,ffffffffc0204e5e <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204e6e:	8082                	ret

ffffffffc0204e70 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204e70:	c21d                	beqz	a2,ffffffffc0204e96 <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204e72:	00054783          	lbu	a5,0(a0)
ffffffffc0204e76:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e7a:	962a                	add	a2,a2,a0
ffffffffc0204e7c:	00f70963          	beq	a4,a5,ffffffffc0204e8e <memcmp+0x1e>
ffffffffc0204e80:	a829                	j	ffffffffc0204e9a <memcmp+0x2a>
ffffffffc0204e82:	00054783          	lbu	a5,0(a0)
ffffffffc0204e86:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e8a:	00e79863          	bne	a5,a4,ffffffffc0204e9a <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204e8e:	0505                	addi	a0,a0,1
ffffffffc0204e90:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204e92:	fea618e3          	bne	a2,a0,ffffffffc0204e82 <memcmp+0x12>
    }
    return 0;
ffffffffc0204e96:	4501                	li	a0,0
}
ffffffffc0204e98:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204e9a:	40e7853b          	subw	a0,a5,a4
ffffffffc0204e9e:	8082                	ret
