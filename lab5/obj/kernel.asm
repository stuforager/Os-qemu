
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	45a50513          	addi	a0,a0,1114 # ffffffffc02a1490 <edata>
ffffffffc020003e:	000ad617          	auipc	a2,0xad
ffffffffc0200042:	9da60613          	addi	a2,a2,-1574 # ffffffffc02aca18 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	660060ef          	jal	ra,ffffffffc02066ae <memset>
    cons_init();                // init the console
ffffffffc0200052:	530000ef          	jal	ra,ffffffffc0200582 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	68258593          	addi	a1,a1,1666 # ffffffffc02066d8 <etext>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	69a50513          	addi	a0,a0,1690 # ffffffffc02066f8 <etext+0x20>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1aa000ef          	jal	ra,ffffffffc0200214 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	58e020ef          	jal	ra,ffffffffc02025fc <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e6000ef          	jal	ra,ffffffffc0200658 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	426040ef          	jal	ra,ffffffffc02044a0 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	5cd050ef          	jal	ra,ffffffffc0205e4a <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	572000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	328030ef          	jal	ra,ffffffffc02033ae <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a4000ef          	jal	ra,ffffffffc020052e <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5be000ef          	jal	ra,ffffffffc020064c <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	705050ef          	jal	ra,ffffffffc0205f96 <cpu_idle>

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
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	65250513          	addi	a0,a0,1618 # ffffffffc0206700 <etext+0x28>
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
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	3ccb8b93          	addi	s7,s7,972 # ffffffffc02a1490 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	134000ef          	jal	ra,ffffffffc0200204 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	bge	s2,a0,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	bge	s4,s1,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	122000ef          	jal	ra,ffffffffc0200204 <getchar>
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
ffffffffc02000f6:	10e000ef          	jal	ra,ffffffffc0200204 <getchar>
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
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	36a50513          	addi	a0,a0,874 # ffffffffc02a1490 <edata>
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
ffffffffc020015c:	428000ef          	jal	ra,ffffffffc0200584 <cons_putc>
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
ffffffffc0200182:	10e060ef          	jal	ra,ffffffffc0206290 <vprintfmt>
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
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02001b6:	0da060ef          	jal	ra,ffffffffc0206290 <vprintfmt>
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
ffffffffc02001c2:	a6c9                	j	ffffffffc0200584 <cons_putc>

ffffffffc02001c4 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c4:	1101                	addi	sp,sp,-32
ffffffffc02001c6:	e822                	sd	s0,16(sp)
ffffffffc02001c8:	ec06                	sd	ra,24(sp)
ffffffffc02001ca:	e426                	sd	s1,8(sp)
ffffffffc02001cc:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001ce:	00054503          	lbu	a0,0(a0)
ffffffffc02001d2:	c51d                	beqz	a0,ffffffffc0200200 <cputs+0x3c>
ffffffffc02001d4:	0405                	addi	s0,s0,1
ffffffffc02001d6:	4485                	li	s1,1
ffffffffc02001d8:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001da:	3aa000ef          	jal	ra,ffffffffc0200584 <cons_putc>
    (*cnt) ++;
ffffffffc02001de:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e2:	0405                	addi	s0,s0,1
ffffffffc02001e4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001e8:	f96d                	bnez	a0,ffffffffc02001da <cputs+0x16>
ffffffffc02001ea:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ee:	4529                	li	a0,10
ffffffffc02001f0:	394000ef          	jal	ra,ffffffffc0200584 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f4:	8522                	mv	a0,s0
ffffffffc02001f6:	60e2                	ld	ra,24(sp)
ffffffffc02001f8:	6442                	ld	s0,16(sp)
ffffffffc02001fa:	64a2                	ld	s1,8(sp)
ffffffffc02001fc:	6105                	addi	sp,sp,32
ffffffffc02001fe:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200200:	4405                	li	s0,1
ffffffffc0200202:	b7f5                	j	ffffffffc02001ee <cputs+0x2a>

ffffffffc0200204 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200204:	1141                	addi	sp,sp,-16
ffffffffc0200206:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200208:	3b0000ef          	jal	ra,ffffffffc02005b8 <cons_getc>
ffffffffc020020c:	dd75                	beqz	a0,ffffffffc0200208 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
ffffffffc0200210:	0141                	addi	sp,sp,16
ffffffffc0200212:	8082                	ret

ffffffffc0200214 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200214:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200216:	00006517          	auipc	a0,0x6
ffffffffc020021a:	52250513          	addi	a0,a0,1314 # ffffffffc0206738 <etext+0x60>
void print_kerninfo(void) {
ffffffffc020021e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200220:	f6fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200224:	00000597          	auipc	a1,0x0
ffffffffc0200228:	e1258593          	addi	a1,a1,-494 # ffffffffc0200036 <kern_init>
ffffffffc020022c:	00006517          	auipc	a0,0x6
ffffffffc0200230:	52c50513          	addi	a0,a0,1324 # ffffffffc0206758 <etext+0x80>
ffffffffc0200234:	f5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200238:	00006597          	auipc	a1,0x6
ffffffffc020023c:	4a058593          	addi	a1,a1,1184 # ffffffffc02066d8 <etext>
ffffffffc0200240:	00006517          	auipc	a0,0x6
ffffffffc0200244:	53850513          	addi	a0,a0,1336 # ffffffffc0206778 <etext+0xa0>
ffffffffc0200248:	f47ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024c:	000a1597          	auipc	a1,0xa1
ffffffffc0200250:	24458593          	addi	a1,a1,580 # ffffffffc02a1490 <edata>
ffffffffc0200254:	00006517          	auipc	a0,0x6
ffffffffc0200258:	54450513          	addi	a0,a0,1348 # ffffffffc0206798 <etext+0xc0>
ffffffffc020025c:	f33ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200260:	000ac597          	auipc	a1,0xac
ffffffffc0200264:	7b858593          	addi	a1,a1,1976 # ffffffffc02aca18 <end>
ffffffffc0200268:	00006517          	auipc	a0,0x6
ffffffffc020026c:	55050513          	addi	a0,a0,1360 # ffffffffc02067b8 <etext+0xe0>
ffffffffc0200270:	f1fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200274:	000ad597          	auipc	a1,0xad
ffffffffc0200278:	ba358593          	addi	a1,a1,-1117 # ffffffffc02ace17 <end+0x3ff>
ffffffffc020027c:	00000797          	auipc	a5,0x0
ffffffffc0200280:	dba78793          	addi	a5,a5,-582 # ffffffffc0200036 <kern_init>
ffffffffc0200284:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200288:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200292:	95be                	add	a1,a1,a5
ffffffffc0200294:	85a9                	srai	a1,a1,0xa
ffffffffc0200296:	00006517          	auipc	a0,0x6
ffffffffc020029a:	54250513          	addi	a0,a0,1346 # ffffffffc02067d8 <etext+0x100>
}
ffffffffc020029e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a0:	b5fd                	j	ffffffffc020018e <cprintf>

ffffffffc02002a2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a4:	00006617          	auipc	a2,0x6
ffffffffc02002a8:	46460613          	addi	a2,a2,1124 # ffffffffc0206708 <etext+0x30>
ffffffffc02002ac:	04d00593          	li	a1,77
ffffffffc02002b0:	00006517          	auipc	a0,0x6
ffffffffc02002b4:	47050513          	addi	a0,a0,1136 # ffffffffc0206720 <etext+0x48>
void print_stackframe(void) {
ffffffffc02002b8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ba:	1c6000ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02002be <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002be:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c0:	00006617          	auipc	a2,0x6
ffffffffc02002c4:	62860613          	addi	a2,a2,1576 # ffffffffc02068e8 <commands+0xe0>
ffffffffc02002c8:	00006597          	auipc	a1,0x6
ffffffffc02002cc:	64058593          	addi	a1,a1,1600 # ffffffffc0206908 <commands+0x100>
ffffffffc02002d0:	00006517          	auipc	a0,0x6
ffffffffc02002d4:	64050513          	addi	a0,a0,1600 # ffffffffc0206910 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002da:	eb5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002de:	00006617          	auipc	a2,0x6
ffffffffc02002e2:	64260613          	addi	a2,a2,1602 # ffffffffc0206920 <commands+0x118>
ffffffffc02002e6:	00006597          	auipc	a1,0x6
ffffffffc02002ea:	66258593          	addi	a1,a1,1634 # ffffffffc0206948 <commands+0x140>
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	62250513          	addi	a0,a0,1570 # ffffffffc0206910 <commands+0x108>
ffffffffc02002f6:	e99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fa:	00006617          	auipc	a2,0x6
ffffffffc02002fe:	65e60613          	addi	a2,a2,1630 # ffffffffc0206958 <commands+0x150>
ffffffffc0200302:	00006597          	auipc	a1,0x6
ffffffffc0200306:	67658593          	addi	a1,a1,1654 # ffffffffc0206978 <commands+0x170>
ffffffffc020030a:	00006517          	auipc	a0,0x6
ffffffffc020030e:	60650513          	addi	a0,a0,1542 # ffffffffc0206910 <commands+0x108>
ffffffffc0200312:	e7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc0200316:	60a2                	ld	ra,8(sp)
ffffffffc0200318:	4501                	li	a0,0
ffffffffc020031a:	0141                	addi	sp,sp,16
ffffffffc020031c:	8082                	ret

ffffffffc020031e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020031e:	1141                	addi	sp,sp,-16
ffffffffc0200320:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200322:	ef3ff0ef          	jal	ra,ffffffffc0200214 <print_kerninfo>
    return 0;
}
ffffffffc0200326:	60a2                	ld	ra,8(sp)
ffffffffc0200328:	4501                	li	a0,0
ffffffffc020032a:	0141                	addi	sp,sp,16
ffffffffc020032c:	8082                	ret

ffffffffc020032e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032e:	1141                	addi	sp,sp,-16
ffffffffc0200330:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200332:	f71ff0ef          	jal	ra,ffffffffc02002a2 <print_stackframe>
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020033e:	7115                	addi	sp,sp,-224
ffffffffc0200340:	e962                	sd	s8,144(sp)
ffffffffc0200342:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200344:	00006517          	auipc	a0,0x6
ffffffffc0200348:	50c50513          	addi	a0,a0,1292 # ffffffffc0206850 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020034c:	ed86                	sd	ra,216(sp)
ffffffffc020034e:	e9a2                	sd	s0,208(sp)
ffffffffc0200350:	e5a6                	sd	s1,200(sp)
ffffffffc0200352:	e1ca                	sd	s2,192(sp)
ffffffffc0200354:	fd4e                	sd	s3,184(sp)
ffffffffc0200356:	f952                	sd	s4,176(sp)
ffffffffc0200358:	f556                	sd	s5,168(sp)
ffffffffc020035a:	f15a                	sd	s6,160(sp)
ffffffffc020035c:	ed5e                	sd	s7,152(sp)
ffffffffc020035e:	e566                	sd	s9,136(sp)
ffffffffc0200360:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200362:	e2dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200366:	00006517          	auipc	a0,0x6
ffffffffc020036a:	51250513          	addi	a0,a0,1298 # ffffffffc0206878 <commands+0x70>
ffffffffc020036e:	e21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200372:	000c0563          	beqz	s8,ffffffffc020037c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200376:	8562                	mv	a0,s8
ffffffffc0200378:	4c8000ef          	jal	ra,ffffffffc0200840 <print_trapframe>
ffffffffc020037c:	00006c97          	auipc	s9,0x6
ffffffffc0200380:	48cc8c93          	addi	s9,s9,1164 # ffffffffc0206808 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200384:	00006997          	auipc	s3,0x6
ffffffffc0200388:	51c98993          	addi	s3,s3,1308 # ffffffffc02068a0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038c:	00006917          	auipc	s2,0x6
ffffffffc0200390:	51c90913          	addi	s2,s2,1308 # ffffffffc02068a8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200394:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200396:	00006b17          	auipc	s6,0x6
ffffffffc020039a:	51ab0b13          	addi	s6,s6,1306 # ffffffffc02068b0 <commands+0xa8>
    if (argc == 0) {
ffffffffc020039e:	00006a97          	auipc	s5,0x6
ffffffffc02003a2:	56aa8a93          	addi	s5,s5,1386 # ffffffffc0206908 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a6:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a8:	854e                	mv	a0,s3
ffffffffc02003aa:	cedff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003ae:	842a                	mv	s0,a0
ffffffffc02003b0:	dd65                	beqz	a0,ffffffffc02003a8 <kmonitor+0x6a>
ffffffffc02003b2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003b6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	c999                	beqz	a1,ffffffffc02003ce <kmonitor+0x90>
ffffffffc02003ba:	854a                	mv	a0,s2
ffffffffc02003bc:	2d4060ef          	jal	ra,ffffffffc0206690 <strchr>
ffffffffc02003c0:	c925                	beqz	a0,ffffffffc0200430 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c2:	00144583          	lbu	a1,1(s0)
ffffffffc02003c6:	00040023          	sb	zero,0(s0)
ffffffffc02003ca:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003cc:	f5fd                	bnez	a1,ffffffffc02003ba <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003ce:	dce9                	beqz	s1,ffffffffc02003a8 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d0:	6582                	ld	a1,0(sp)
ffffffffc02003d2:	00006d17          	auipc	s10,0x6
ffffffffc02003d6:	436d0d13          	addi	s10,s10,1078 # ffffffffc0206808 <commands>
    if (argc == 0) {
ffffffffc02003da:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003dc:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003de:	0d61                	addi	s10,s10,24
ffffffffc02003e0:	286060ef          	jal	ra,ffffffffc0206666 <strcmp>
ffffffffc02003e4:	c919                	beqz	a0,ffffffffc02003fa <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	2405                	addiw	s0,s0,1
ffffffffc02003e8:	09740463          	beq	s0,s7,ffffffffc0200470 <kmonitor+0x132>
ffffffffc02003ec:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f0:	6582                	ld	a1,0(sp)
ffffffffc02003f2:	0d61                	addi	s10,s10,24
ffffffffc02003f4:	272060ef          	jal	ra,ffffffffc0206666 <strcmp>
ffffffffc02003f8:	f57d                	bnez	a0,ffffffffc02003e6 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fa:	00141793          	slli	a5,s0,0x1
ffffffffc02003fe:	97a2                	add	a5,a5,s0
ffffffffc0200400:	078e                	slli	a5,a5,0x3
ffffffffc0200402:	97e6                	add	a5,a5,s9
ffffffffc0200404:	6b9c                	ld	a5,16(a5)
ffffffffc0200406:	8662                	mv	a2,s8
ffffffffc0200408:	002c                	addi	a1,sp,8
ffffffffc020040a:	fff4851b          	addiw	a0,s1,-1
ffffffffc020040e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200410:	f8055ce3          	bgez	a0,ffffffffc02003a8 <kmonitor+0x6a>
}
ffffffffc0200414:	60ee                	ld	ra,216(sp)
ffffffffc0200416:	644e                	ld	s0,208(sp)
ffffffffc0200418:	64ae                	ld	s1,200(sp)
ffffffffc020041a:	690e                	ld	s2,192(sp)
ffffffffc020041c:	79ea                	ld	s3,184(sp)
ffffffffc020041e:	7a4a                	ld	s4,176(sp)
ffffffffc0200420:	7aaa                	ld	s5,168(sp)
ffffffffc0200422:	7b0a                	ld	s6,160(sp)
ffffffffc0200424:	6bea                	ld	s7,152(sp)
ffffffffc0200426:	6c4a                	ld	s8,144(sp)
ffffffffc0200428:	6caa                	ld	s9,136(sp)
ffffffffc020042a:	6d0a                	ld	s10,128(sp)
ffffffffc020042c:	612d                	addi	sp,sp,224
ffffffffc020042e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200430:	00044783          	lbu	a5,0(s0)
ffffffffc0200434:	dfc9                	beqz	a5,ffffffffc02003ce <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200436:	03448863          	beq	s1,s4,ffffffffc0200466 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043a:	00349793          	slli	a5,s1,0x3
ffffffffc020043e:	0118                	addi	a4,sp,128
ffffffffc0200440:	97ba                	add	a5,a5,a4
ffffffffc0200442:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200446:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044c:	e591                	bnez	a1,ffffffffc0200458 <kmonitor+0x11a>
ffffffffc020044e:	b749                	j	ffffffffc02003d0 <kmonitor+0x92>
            buf ++;
ffffffffc0200450:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200452:	00044583          	lbu	a1,0(s0)
ffffffffc0200456:	ddad                	beqz	a1,ffffffffc02003d0 <kmonitor+0x92>
ffffffffc0200458:	854a                	mv	a0,s2
ffffffffc020045a:	236060ef          	jal	ra,ffffffffc0206690 <strchr>
ffffffffc020045e:	d96d                	beqz	a0,ffffffffc0200450 <kmonitor+0x112>
ffffffffc0200460:	00044583          	lbu	a1,0(s0)
ffffffffc0200464:	bf91                	j	ffffffffc02003b8 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200466:	45c1                	li	a1,16
ffffffffc0200468:	855a                	mv	a0,s6
ffffffffc020046a:	d25ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020046e:	b7f1                	j	ffffffffc020043a <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200470:	6582                	ld	a1,0(sp)
ffffffffc0200472:	00006517          	auipc	a0,0x6
ffffffffc0200476:	45e50513          	addi	a0,a0,1118 # ffffffffc02068d0 <commands+0xc8>
ffffffffc020047a:	d15ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020047e:	b72d                	j	ffffffffc02003a8 <kmonitor+0x6a>

ffffffffc0200480 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200480:	000ac317          	auipc	t1,0xac
ffffffffc0200484:	41030313          	addi	t1,t1,1040 # ffffffffc02ac890 <is_panic>
ffffffffc0200488:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020048c:	715d                	addi	sp,sp,-80
ffffffffc020048e:	ec06                	sd	ra,24(sp)
ffffffffc0200490:	e822                	sd	s0,16(sp)
ffffffffc0200492:	f436                	sd	a3,40(sp)
ffffffffc0200494:	f83a                	sd	a4,48(sp)
ffffffffc0200496:	fc3e                	sd	a5,56(sp)
ffffffffc0200498:	e0c2                	sd	a6,64(sp)
ffffffffc020049a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020049c:	02031c63          	bnez	t1,ffffffffc02004d4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a0:	4785                	li	a5,1
ffffffffc02004a2:	8432                	mv	s0,a2
ffffffffc02004a4:	000ac717          	auipc	a4,0xac
ffffffffc02004a8:	3ef73623          	sd	a5,1004(a4) # ffffffffc02ac890 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004ac:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004ae:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	85aa                	mv	a1,a0
ffffffffc02004b2:	00006517          	auipc	a0,0x6
ffffffffc02004b6:	4d650513          	addi	a0,a0,1238 # ffffffffc0206988 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004ba:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004bc:	cd3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c0:	65a2                	ld	a1,8(sp)
ffffffffc02004c2:	8522                	mv	a0,s0
ffffffffc02004c4:	cabff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004c8:	00007517          	auipc	a0,0x7
ffffffffc02004cc:	48850513          	addi	a0,a0,1160 # ffffffffc0207950 <default_pmm_manager+0x540>
ffffffffc02004d0:	cbfff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d4:	4501                	li	a0,0
ffffffffc02004d6:	4581                	li	a1,0
ffffffffc02004d8:	4601                	li	a2,0
ffffffffc02004da:	48a1                	li	a7,8
ffffffffc02004dc:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e0:	172000ef          	jal	ra,ffffffffc0200652 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e4:	4501                	li	a0,0
ffffffffc02004e6:	e59ff0ef          	jal	ra,ffffffffc020033e <kmonitor>
ffffffffc02004ea:	bfed                	j	ffffffffc02004e4 <__panic+0x64>

ffffffffc02004ec <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ec:	715d                	addi	sp,sp,-80
ffffffffc02004ee:	e822                	sd	s0,16(sp)
ffffffffc02004f0:	fc3e                	sd	a5,56(sp)
ffffffffc02004f2:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f4:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f6:	862e                	mv	a2,a1
ffffffffc02004f8:	85aa                	mv	a1,a0
ffffffffc02004fa:	00006517          	auipc	a0,0x6
ffffffffc02004fe:	4ae50513          	addi	a0,a0,1198 # ffffffffc02069a8 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200502:	ec06                	sd	ra,24(sp)
ffffffffc0200504:	f436                	sd	a3,40(sp)
ffffffffc0200506:	f83a                	sd	a4,48(sp)
ffffffffc0200508:	e0c2                	sd	a6,64(sp)
ffffffffc020050a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020050c:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020050e:	c81ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200512:	65a2                	ld	a1,8(sp)
ffffffffc0200514:	8522                	mv	a0,s0
ffffffffc0200516:	c59ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051a:	00007517          	auipc	a0,0x7
ffffffffc020051e:	43650513          	addi	a0,a0,1078 # ffffffffc0207950 <default_pmm_manager+0x540>
ffffffffc0200522:	c6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc0200526:	60e2                	ld	ra,24(sp)
ffffffffc0200528:	6442                	ld	s0,16(sp)
ffffffffc020052a:	6161                	addi	sp,sp,80
ffffffffc020052c:	8082                	ret

ffffffffc020052e <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020052e:	67e1                	lui	a5,0x18
ffffffffc0200530:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdbc8>
ffffffffc0200534:	000ac717          	auipc	a4,0xac
ffffffffc0200538:	36f73223          	sd	a5,868(a4) # ffffffffc02ac898 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053c:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200540:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200542:	953e                	add	a0,a0,a5
ffffffffc0200544:	4601                	li	a2,0
ffffffffc0200546:	4881                	li	a7,0
ffffffffc0200548:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020054c:	02000793          	li	a5,32
ffffffffc0200550:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200554:	00006517          	auipc	a0,0x6
ffffffffc0200558:	47450513          	addi	a0,a0,1140 # ffffffffc02069c8 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000ac797          	auipc	a5,0xac
ffffffffc0200560:	3807b623          	sd	zero,908(a5) # ffffffffc02ac8e8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200564:	b12d                	j	ffffffffc020018e <cprintf>

ffffffffc0200566 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200566:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056a:	000ac797          	auipc	a5,0xac
ffffffffc020056e:	32e78793          	addi	a5,a5,814 # ffffffffc02ac898 <timebase>
ffffffffc0200572:	639c                	ld	a5,0(a5)
ffffffffc0200574:	4581                	li	a1,0
ffffffffc0200576:	4601                	li	a2,0
ffffffffc0200578:	953e                	add	a0,a0,a5
ffffffffc020057a:	4881                	li	a7,0
ffffffffc020057c:	00000073          	ecall
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200582:	8082                	ret

ffffffffc0200584 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200584:	100027f3          	csrr	a5,sstatus
ffffffffc0200588:	8b89                	andi	a5,a5,2
ffffffffc020058a:	0ff57513          	andi	a0,a0,255
ffffffffc020058e:	e799                	bnez	a5,ffffffffc020059c <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200590:	4581                	li	a1,0
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4885                	li	a7,1
ffffffffc0200596:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020059a:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020059c:	1101                	addi	sp,sp,-32
ffffffffc020059e:	ec06                	sd	ra,24(sp)
ffffffffc02005a0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a2:	0b0000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005a6:	6522                	ld	a0,8(sp)
ffffffffc02005a8:	4581                	li	a1,0
ffffffffc02005aa:	4601                	li	a2,0
ffffffffc02005ac:	4885                	li	a7,1
ffffffffc02005ae:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b2:	60e2                	ld	ra,24(sp)
ffffffffc02005b4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005b6:	a859                	j	ffffffffc020064c <intr_enable>

ffffffffc02005b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005b8:	100027f3          	csrr	a5,sstatus
ffffffffc02005bc:	8b89                	andi	a5,a5,2
ffffffffc02005be:	eb89                	bnez	a5,ffffffffc02005d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c0:	4501                	li	a0,0
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4889                	li	a7,2
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005ce:	8082                	ret
int cons_getc(void) {
ffffffffc02005d0:	1101                	addi	sp,sp,-32
ffffffffc02005d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005d4:	07e000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005d8:	4501                	li	a0,0
ffffffffc02005da:	4581                	li	a1,0
ffffffffc02005dc:	4601                	li	a2,0
ffffffffc02005de:	4889                	li	a7,2
ffffffffc02005e0:	00000073          	ecall
ffffffffc02005e4:	2501                	sext.w	a0,a0
ffffffffc02005e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005e8:	064000ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc02005ec:	60e2                	ld	ra,24(sp)
ffffffffc02005ee:	6522                	ld	a0,8(sp)
ffffffffc02005f0:	6105                	addi	sp,sp,32
ffffffffc02005f2:	8082                	ret

ffffffffc02005f4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005f4:	8082                	ret

ffffffffc02005f6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005f6:	00253513          	sltiu	a0,a0,2
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005fc:	03800513          	li	a0,56
ffffffffc0200600:	8082                	ret

ffffffffc0200602 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	000a1797          	auipc	a5,0xa1
ffffffffc0200606:	28e78793          	addi	a5,a5,654 # ffffffffc02a1890 <ide>
ffffffffc020060a:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020060e:	1141                	addi	sp,sp,-16
ffffffffc0200610:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200612:	95be                	add	a1,a1,a5
ffffffffc0200614:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200618:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	0a6060ef          	jal	ra,ffffffffc02066c0 <memcpy>
    return 0;
}
ffffffffc020061e:	60a2                	ld	ra,8(sp)
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	0141                	addi	sp,sp,16
ffffffffc0200624:	8082                	ret

ffffffffc0200626 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200626:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200628:	0095979b          	slliw	a5,a1,0x9
ffffffffc020062c:	000a1517          	auipc	a0,0xa1
ffffffffc0200630:	26450513          	addi	a0,a0,612 # ffffffffc02a1890 <ide>
                   size_t nsecs) {
ffffffffc0200634:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200636:	00969613          	slli	a2,a3,0x9
ffffffffc020063a:	85ba                	mv	a1,a4
ffffffffc020063c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020063e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200640:	080060ef          	jal	ra,ffffffffc02066c0 <memcpy>
    return 0;
}
ffffffffc0200644:	60a2                	ld	ra,8(sp)
ffffffffc0200646:	4501                	li	a0,0
ffffffffc0200648:	0141                	addi	sp,sp,16
ffffffffc020064a:	8082                	ret

ffffffffc020064c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020064c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200650:	8082                	ret

ffffffffc0200652 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200652:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200656:	8082                	ret

ffffffffc0200658 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200658:	8082                	ret

ffffffffc020065a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020065a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020065e:	00000797          	auipc	a5,0x0
ffffffffc0200662:	66a78793          	addi	a5,a5,1642 # ffffffffc0200cc8 <__alltraps>
ffffffffc0200666:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020066a:	000407b7          	lui	a5,0x40
ffffffffc020066e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200672:	8082                	ret

ffffffffc0200674 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200676:	1141                	addi	sp,sp,-16
ffffffffc0200678:	e022                	sd	s0,0(sp)
ffffffffc020067a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	00006517          	auipc	a0,0x6
ffffffffc0200680:	69450513          	addi	a0,a0,1684 # ffffffffc0206d10 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	b09ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00006517          	auipc	a0,0x6
ffffffffc0200690:	69c50513          	addi	a0,a0,1692 # ffffffffc0206d28 <commands+0x520>
ffffffffc0200694:	afbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00006517          	auipc	a0,0x6
ffffffffc020069e:	6a650513          	addi	a0,a0,1702 # ffffffffc0206d40 <commands+0x538>
ffffffffc02006a2:	aedff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00006517          	auipc	a0,0x6
ffffffffc02006ac:	6b050513          	addi	a0,a0,1712 # ffffffffc0206d58 <commands+0x550>
ffffffffc02006b0:	adfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00006517          	auipc	a0,0x6
ffffffffc02006ba:	6ba50513          	addi	a0,a0,1722 # ffffffffc0206d70 <commands+0x568>
ffffffffc02006be:	ad1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00006517          	auipc	a0,0x6
ffffffffc02006c8:	6c450513          	addi	a0,a0,1732 # ffffffffc0206d88 <commands+0x580>
ffffffffc02006cc:	ac3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00006517          	auipc	a0,0x6
ffffffffc02006d6:	6ce50513          	addi	a0,a0,1742 # ffffffffc0206da0 <commands+0x598>
ffffffffc02006da:	ab5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00006517          	auipc	a0,0x6
ffffffffc02006e4:	6d850513          	addi	a0,a0,1752 # ffffffffc0206db8 <commands+0x5b0>
ffffffffc02006e8:	aa7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00006517          	auipc	a0,0x6
ffffffffc02006f2:	6e250513          	addi	a0,a0,1762 # ffffffffc0206dd0 <commands+0x5c8>
ffffffffc02006f6:	a99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00006517          	auipc	a0,0x6
ffffffffc0200700:	6ec50513          	addi	a0,a0,1772 # ffffffffc0206de8 <commands+0x5e0>
ffffffffc0200704:	a8bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00006517          	auipc	a0,0x6
ffffffffc020070e:	6f650513          	addi	a0,a0,1782 # ffffffffc0206e00 <commands+0x5f8>
ffffffffc0200712:	a7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00006517          	auipc	a0,0x6
ffffffffc020071c:	70050513          	addi	a0,a0,1792 # ffffffffc0206e18 <commands+0x610>
ffffffffc0200720:	a6fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00006517          	auipc	a0,0x6
ffffffffc020072a:	70a50513          	addi	a0,a0,1802 # ffffffffc0206e30 <commands+0x628>
ffffffffc020072e:	a61ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00006517          	auipc	a0,0x6
ffffffffc0200738:	71450513          	addi	a0,a0,1812 # ffffffffc0206e48 <commands+0x640>
ffffffffc020073c:	a53ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00006517          	auipc	a0,0x6
ffffffffc0200746:	71e50513          	addi	a0,a0,1822 # ffffffffc0206e60 <commands+0x658>
ffffffffc020074a:	a45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00006517          	auipc	a0,0x6
ffffffffc0200754:	72850513          	addi	a0,a0,1832 # ffffffffc0206e78 <commands+0x670>
ffffffffc0200758:	a37ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00006517          	auipc	a0,0x6
ffffffffc0200762:	73250513          	addi	a0,a0,1842 # ffffffffc0206e90 <commands+0x688>
ffffffffc0200766:	a29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00006517          	auipc	a0,0x6
ffffffffc0200770:	73c50513          	addi	a0,a0,1852 # ffffffffc0206ea8 <commands+0x6a0>
ffffffffc0200774:	a1bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00006517          	auipc	a0,0x6
ffffffffc020077e:	74650513          	addi	a0,a0,1862 # ffffffffc0206ec0 <commands+0x6b8>
ffffffffc0200782:	a0dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00006517          	auipc	a0,0x6
ffffffffc020078c:	75050513          	addi	a0,a0,1872 # ffffffffc0206ed8 <commands+0x6d0>
ffffffffc0200790:	9ffff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00006517          	auipc	a0,0x6
ffffffffc020079a:	75a50513          	addi	a0,a0,1882 # ffffffffc0206ef0 <commands+0x6e8>
ffffffffc020079e:	9f1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00006517          	auipc	a0,0x6
ffffffffc02007a8:	76450513          	addi	a0,a0,1892 # ffffffffc0206f08 <commands+0x700>
ffffffffc02007ac:	9e3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00006517          	auipc	a0,0x6
ffffffffc02007b6:	76e50513          	addi	a0,a0,1902 # ffffffffc0206f20 <commands+0x718>
ffffffffc02007ba:	9d5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00006517          	auipc	a0,0x6
ffffffffc02007c4:	77850513          	addi	a0,a0,1912 # ffffffffc0206f38 <commands+0x730>
ffffffffc02007c8:	9c7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00006517          	auipc	a0,0x6
ffffffffc02007d2:	78250513          	addi	a0,a0,1922 # ffffffffc0206f50 <commands+0x748>
ffffffffc02007d6:	9b9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00006517          	auipc	a0,0x6
ffffffffc02007e0:	78c50513          	addi	a0,a0,1932 # ffffffffc0206f68 <commands+0x760>
ffffffffc02007e4:	9abff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00006517          	auipc	a0,0x6
ffffffffc02007ee:	79650513          	addi	a0,a0,1942 # ffffffffc0206f80 <commands+0x778>
ffffffffc02007f2:	99dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00006517          	auipc	a0,0x6
ffffffffc02007fc:	7a050513          	addi	a0,a0,1952 # ffffffffc0206f98 <commands+0x790>
ffffffffc0200800:	98fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00006517          	auipc	a0,0x6
ffffffffc020080a:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206fb0 <commands+0x7a8>
ffffffffc020080e:	981ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	7b450513          	addi	a0,a0,1972 # ffffffffc0206fc8 <commands+0x7c0>
ffffffffc020081c:	973ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00006517          	auipc	a0,0x6
ffffffffc0200826:	7be50513          	addi	a0,a0,1982 # ffffffffc0206fe0 <commands+0x7d8>
ffffffffc020082a:	965ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00006517          	auipc	a0,0x6
ffffffffc0200838:	7c450513          	addi	a0,a0,1988 # ffffffffc0206ff8 <commands+0x7f0>
}
ffffffffc020083c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083e:	ba81                	j	ffffffffc020018e <cprintf>

ffffffffc0200840 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	1141                	addi	sp,sp,-16
ffffffffc0200842:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200844:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	00006517          	auipc	a0,0x6
ffffffffc020084c:	7c850513          	addi	a0,a0,1992 # ffffffffc0207010 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	93dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200856:	8522                	mv	a0,s0
ffffffffc0200858:	e1dff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085c:	10043583          	ld	a1,256(s0)
ffffffffc0200860:	00006517          	auipc	a0,0x6
ffffffffc0200864:	7c850513          	addi	a0,a0,1992 # ffffffffc0207028 <commands+0x820>
ffffffffc0200868:	927ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086c:	10843583          	ld	a1,264(s0)
ffffffffc0200870:	00006517          	auipc	a0,0x6
ffffffffc0200874:	7d050513          	addi	a0,a0,2000 # ffffffffc0207040 <commands+0x838>
ffffffffc0200878:	917ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087c:	11043583          	ld	a1,272(s0)
ffffffffc0200880:	00006517          	auipc	a0,0x6
ffffffffc0200884:	7d850513          	addi	a0,a0,2008 # ffffffffc0207058 <commands+0x850>
ffffffffc0200888:	907ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200890:	6402                	ld	s0,0(sp)
ffffffffc0200892:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	00006517          	auipc	a0,0x6
ffffffffc0200898:	7d450513          	addi	a0,a0,2004 # ffffffffc0207068 <commands+0x860>
}
ffffffffc020089c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	8f1ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02008a2 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a2:	1101                	addi	sp,sp,-32
ffffffffc02008a4:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a6:	000ac497          	auipc	s1,0xac
ffffffffc02008aa:	15a48493          	addi	s1,s1,346 # ffffffffc02aca00 <check_mm_struct>
ffffffffc02008ae:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008b0:	e822                	sd	s0,16(sp)
ffffffffc02008b2:	ec06                	sd	ra,24(sp)
ffffffffc02008b4:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b6:	cbbd                	beqz	a5,ffffffffc020092c <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008bc:	11053583          	ld	a1,272(a0)
ffffffffc02008c0:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c4:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c8:	cba1                	beqz	a5,ffffffffc0200918 <pgfault_handler+0x76>
ffffffffc02008ca:	11843703          	ld	a4,280(s0)
ffffffffc02008ce:	47bd                	li	a5,15
ffffffffc02008d0:	05700693          	li	a3,87
ffffffffc02008d4:	00f70463          	beq	a4,a5,ffffffffc02008dc <pgfault_handler+0x3a>
ffffffffc02008d8:	05200693          	li	a3,82
ffffffffc02008dc:	00006517          	auipc	a0,0x6
ffffffffc02008e0:	3b450513          	addi	a0,a0,948 # ffffffffc0206c90 <commands+0x488>
ffffffffc02008e4:	8abff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008e8:	6088                	ld	a0,0(s1)
ffffffffc02008ea:	c129                	beqz	a0,ffffffffc020092c <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ec:	000ac797          	auipc	a5,0xac
ffffffffc02008f0:	fdc78793          	addi	a5,a5,-36 # ffffffffc02ac8c8 <current>
ffffffffc02008f4:	6398                	ld	a4,0(a5)
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	fda78793          	addi	a5,a5,-38 # ffffffffc02ac8d0 <idleproc>
ffffffffc02008fe:	639c                	ld	a5,0(a5)
ffffffffc0200900:	04f71763          	bne	a4,a5,ffffffffc020094e <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	11043603          	ld	a2,272(s0)
ffffffffc0200908:	11843583          	ld	a1,280(s0)
}
ffffffffc020090c:	6442                	ld	s0,16(sp)
ffffffffc020090e:	60e2                	ld	ra,24(sp)
ffffffffc0200910:	64a2                	ld	s1,8(sp)
ffffffffc0200912:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200914:	0be0406f          	j	ffffffffc02049d2 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200918:	11843703          	ld	a4,280(s0)
ffffffffc020091c:	47bd                	li	a5,15
ffffffffc020091e:	05500613          	li	a2,85
ffffffffc0200922:	05700693          	li	a3,87
ffffffffc0200926:	faf719e3          	bne	a4,a5,ffffffffc02008d8 <pgfault_handler+0x36>
ffffffffc020092a:	bf4d                	j	ffffffffc02008dc <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092c:	000ac797          	auipc	a5,0xac
ffffffffc0200930:	f9c78793          	addi	a5,a5,-100 # ffffffffc02ac8c8 <current>
ffffffffc0200934:	639c                	ld	a5,0(a5)
ffffffffc0200936:	cf85                	beqz	a5,ffffffffc020096e <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200938:	11043603          	ld	a2,272(s0)
ffffffffc020093c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200940:	6442                	ld	s0,16(sp)
ffffffffc0200942:	60e2                	ld	ra,24(sp)
ffffffffc0200944:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200946:	7788                	ld	a0,40(a5)
}
ffffffffc0200948:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020094a:	0880406f          	j	ffffffffc02049d2 <do_pgfault>
        assert(current == idleproc);
ffffffffc020094e:	00006697          	auipc	a3,0x6
ffffffffc0200952:	36268693          	addi	a3,a3,866 # ffffffffc0206cb0 <commands+0x4a8>
ffffffffc0200956:	00006617          	auipc	a2,0x6
ffffffffc020095a:	37260613          	addi	a2,a2,882 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020095e:	06b00593          	li	a1,107
ffffffffc0200962:	00006517          	auipc	a0,0x6
ffffffffc0200966:	37e50513          	addi	a0,a0,894 # ffffffffc0206ce0 <commands+0x4d8>
ffffffffc020096a:	b17ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            print_trapframe(tf);
ffffffffc020096e:	8522                	mv	a0,s0
ffffffffc0200970:	ed1ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200974:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200978:	11043583          	ld	a1,272(s0)
ffffffffc020097c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200980:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200984:	e399                	bnez	a5,ffffffffc020098a <pgfault_handler+0xe8>
ffffffffc0200986:	05500613          	li	a2,85
ffffffffc020098a:	11843703          	ld	a4,280(s0)
ffffffffc020098e:	47bd                	li	a5,15
ffffffffc0200990:	02f70663          	beq	a4,a5,ffffffffc02009bc <pgfault_handler+0x11a>
ffffffffc0200994:	05200693          	li	a3,82
ffffffffc0200998:	00006517          	auipc	a0,0x6
ffffffffc020099c:	2f850513          	addi	a0,a0,760 # ffffffffc0206c90 <commands+0x488>
ffffffffc02009a0:	feeff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a4:	00006617          	auipc	a2,0x6
ffffffffc02009a8:	35460613          	addi	a2,a2,852 # ffffffffc0206cf8 <commands+0x4f0>
ffffffffc02009ac:	07200593          	li	a1,114
ffffffffc02009b0:	00006517          	auipc	a0,0x6
ffffffffc02009b4:	33050513          	addi	a0,a0,816 # ffffffffc0206ce0 <commands+0x4d8>
ffffffffc02009b8:	ac9ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009bc:	05700693          	li	a3,87
ffffffffc02009c0:	bfe1                	j	ffffffffc0200998 <pgfault_handler+0xf6>

ffffffffc02009c2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c2:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02009c6:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c8:	0786                	slli	a5,a5,0x1
ffffffffc02009ca:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02009cc:	08f76763          	bltu	a4,a5,ffffffffc0200a5a <interrupt_handler+0x98>
ffffffffc02009d0:	00006717          	auipc	a4,0x6
ffffffffc02009d4:	01470713          	addi	a4,a4,20 # ffffffffc02069e4 <commands+0x1dc>
ffffffffc02009d8:	078a                	slli	a5,a5,0x2
ffffffffc02009da:	97ba                	add	a5,a5,a4
ffffffffc02009dc:	439c                	lw	a5,0(a5)
ffffffffc02009de:	97ba                	add	a5,a5,a4
ffffffffc02009e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009e2:	00006517          	auipc	a0,0x6
ffffffffc02009e6:	26e50513          	addi	a0,a0,622 # ffffffffc0206c50 <commands+0x448>
ffffffffc02009ea:	fa4ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	24250513          	addi	a0,a0,578 # ffffffffc0206c30 <commands+0x428>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	1f650513          	addi	a0,a0,502 # ffffffffc0206bf0 <commands+0x3e8>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	20a50513          	addi	a0,a0,522 # ffffffffc0206c10 <commands+0x408>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	25e50513          	addi	a0,a0,606 # ffffffffc0206c70 <commands+0x468>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a1e:	1141                	addi	sp,sp,-16
ffffffffc0200a20:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a22:	b45ff0ef          	jal	ra,ffffffffc0200566 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a26:	000ac797          	auipc	a5,0xac
ffffffffc0200a2a:	ec278793          	addi	a5,a5,-318 # ffffffffc02ac8e8 <ticks>
ffffffffc0200a2e:	639c                	ld	a5,0(a5)
ffffffffc0200a30:	06400713          	li	a4,100
ffffffffc0200a34:	0785                	addi	a5,a5,1
ffffffffc0200a36:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a3a:	000ac697          	auipc	a3,0xac
ffffffffc0200a3e:	eaf6b723          	sd	a5,-338(a3) # ffffffffc02ac8e8 <ticks>
ffffffffc0200a42:	eb09                	bnez	a4,ffffffffc0200a54 <interrupt_handler+0x92>
ffffffffc0200a44:	000ac797          	auipc	a5,0xac
ffffffffc0200a48:	e8478793          	addi	a5,a5,-380 # ffffffffc02ac8c8 <current>
ffffffffc0200a4c:	639c                	ld	a5,0(a5)
ffffffffc0200a4e:	c399                	beqz	a5,ffffffffc0200a54 <interrupt_handler+0x92>
                current->need_resched = 1;
ffffffffc0200a50:	4705                	li	a4,1
ffffffffc0200a52:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a54:	60a2                	ld	ra,8(sp)
ffffffffc0200a56:	0141                	addi	sp,sp,16
ffffffffc0200a58:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a5a:	b3dd                	j	ffffffffc0200840 <print_trapframe>

ffffffffc0200a5c <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a5c:	11853783          	ld	a5,280(a0)
ffffffffc0200a60:	473d                	li	a4,15
ffffffffc0200a62:	1af76c63          	bltu	a4,a5,ffffffffc0200c1a <exception_handler+0x1be>
ffffffffc0200a66:	00006717          	auipc	a4,0x6
ffffffffc0200a6a:	fae70713          	addi	a4,a4,-82 # ffffffffc0206a14 <commands+0x20c>
ffffffffc0200a6e:	078a                	slli	a5,a5,0x2
ffffffffc0200a70:	97ba                	add	a5,a5,a4
ffffffffc0200a72:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a74:	1101                	addi	sp,sp,-32
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	ec06                	sd	ra,24(sp)
ffffffffc0200a7a:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a7c:	97ba                	add	a5,a5,a4
ffffffffc0200a7e:	842a                	mv	s0,a0
ffffffffc0200a80:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a82:	00006517          	auipc	a0,0x6
ffffffffc0200a86:	0c650513          	addi	a0,a0,198 # ffffffffc0206b48 <commands+0x340>
ffffffffc0200a8a:	f04ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a8e:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a92:	60e2                	ld	ra,24(sp)
ffffffffc0200a94:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a96:	0791                	addi	a5,a5,4
ffffffffc0200a98:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a9c:	6442                	ld	s0,16(sp)
ffffffffc0200a9e:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aa0:	6ec0506f          	j	ffffffffc020618c <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa4:	00006517          	auipc	a0,0x6
ffffffffc0200aa8:	0c450513          	addi	a0,a0,196 # ffffffffc0206b68 <commands+0x360>
}
ffffffffc0200aac:	6442                	ld	s0,16(sp)
ffffffffc0200aae:	60e2                	ld	ra,24(sp)
ffffffffc0200ab0:	64a2                	ld	s1,8(sp)
ffffffffc0200ab2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ab4:	edaff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ab8:	00006517          	auipc	a0,0x6
ffffffffc0200abc:	0d050513          	addi	a0,a0,208 # ffffffffc0206b88 <commands+0x380>
ffffffffc0200ac0:	b7f5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac2:	00006517          	auipc	a0,0x6
ffffffffc0200ac6:	0e650513          	addi	a0,a0,230 # ffffffffc0206ba8 <commands+0x3a0>
ffffffffc0200aca:	b7cd                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200acc:	00006517          	auipc	a0,0x6
ffffffffc0200ad0:	0f450513          	addi	a0,a0,244 # ffffffffc0206bc0 <commands+0x3b8>
ffffffffc0200ad4:	ebaff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad8:	8522                	mv	a0,s0
ffffffffc0200ada:	dc9ff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200ade:	84aa                	mv	s1,a0
ffffffffc0200ae0:	12051e63          	bnez	a0,ffffffffc0200c1c <exception_handler+0x1c0>
}
ffffffffc0200ae4:	60e2                	ld	ra,24(sp)
ffffffffc0200ae6:	6442                	ld	s0,16(sp)
ffffffffc0200ae8:	64a2                	ld	s1,8(sp)
ffffffffc0200aea:	6105                	addi	sp,sp,32
ffffffffc0200aec:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200aee:	00006517          	auipc	a0,0x6
ffffffffc0200af2:	0ea50513          	addi	a0,a0,234 # ffffffffc0206bd8 <commands+0x3d0>
ffffffffc0200af6:	e98ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200afa:	8522                	mv	a0,s0
ffffffffc0200afc:	da7ff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200b00:	84aa                	mv	s1,a0
ffffffffc0200b02:	d16d                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b04:	8522                	mv	a0,s0
ffffffffc0200b06:	d3bff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0a:	86a6                	mv	a3,s1
ffffffffc0200b0c:	00006617          	auipc	a2,0x6
ffffffffc0200b10:	fec60613          	addi	a2,a2,-20 # ffffffffc0206af8 <commands+0x2f0>
ffffffffc0200b14:	0f800593          	li	a1,248
ffffffffc0200b18:	00006517          	auipc	a0,0x6
ffffffffc0200b1c:	1c850513          	addi	a0,a0,456 # ffffffffc0206ce0 <commands+0x4d8>
ffffffffc0200b20:	961ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b24:	00006517          	auipc	a0,0x6
ffffffffc0200b28:	f3450513          	addi	a0,a0,-204 # ffffffffc0206a58 <commands+0x250>
ffffffffc0200b2c:	b741                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b2e:	00006517          	auipc	a0,0x6
ffffffffc0200b32:	f4a50513          	addi	a0,a0,-182 # ffffffffc0206a78 <commands+0x270>
ffffffffc0200b36:	bf9d                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b38:	00006517          	auipc	a0,0x6
ffffffffc0200b3c:	f6050513          	addi	a0,a0,-160 # ffffffffc0206a98 <commands+0x290>
ffffffffc0200b40:	b7b5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b42:	00006517          	auipc	a0,0x6
ffffffffc0200b46:	f6e50513          	addi	a0,a0,-146 # ffffffffc0206ab0 <commands+0x2a8>
ffffffffc0200b4a:	e44ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b4e:	6458                	ld	a4,136(s0)
ffffffffc0200b50:	47a9                	li	a5,10
ffffffffc0200b52:	f8f719e3          	bne	a4,a5,ffffffffc0200ae4 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b56:	10843783          	ld	a5,264(s0)
ffffffffc0200b5a:	0791                	addi	a5,a5,4
ffffffffc0200b5c:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b60:	62c050ef          	jal	ra,ffffffffc020618c <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	000ac797          	auipc	a5,0xac
ffffffffc0200b68:	d6478793          	addi	a5,a5,-668 # ffffffffc02ac8c8 <current>
ffffffffc0200b6c:	639c                	ld	a5,0(a5)
ffffffffc0200b6e:	8522                	mv	a0,s0
}
ffffffffc0200b70:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b74:	60e2                	ld	ra,24(sp)
ffffffffc0200b76:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b78:	6589                	lui	a1,0x2
ffffffffc0200b7a:	95be                	add	a1,a1,a5
}
ffffffffc0200b7c:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7e:	ac21                	j	ffffffffc0200d96 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b80:	00006517          	auipc	a0,0x6
ffffffffc0200b84:	f4050513          	addi	a0,a0,-192 # ffffffffc0206ac0 <commands+0x2b8>
ffffffffc0200b88:	b715                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8a:	00006517          	auipc	a0,0x6
ffffffffc0200b8e:	f5650513          	addi	a0,a0,-170 # ffffffffc0206ae0 <commands+0x2d8>
ffffffffc0200b92:	dfcff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b96:	8522                	mv	a0,s0
ffffffffc0200b98:	d0bff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200b9c:	84aa                	mv	s1,a0
ffffffffc0200b9e:	d139                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ba0:	8522                	mv	a0,s0
ffffffffc0200ba2:	c9fff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba6:	86a6                	mv	a3,s1
ffffffffc0200ba8:	00006617          	auipc	a2,0x6
ffffffffc0200bac:	f5060613          	addi	a2,a2,-176 # ffffffffc0206af8 <commands+0x2f0>
ffffffffc0200bb0:	0cd00593          	li	a1,205
ffffffffc0200bb4:	00006517          	auipc	a0,0x6
ffffffffc0200bb8:	12c50513          	addi	a0,a0,300 # ffffffffc0206ce0 <commands+0x4d8>
ffffffffc0200bbc:	8c5ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc0:	00006517          	auipc	a0,0x6
ffffffffc0200bc4:	f7050513          	addi	a0,a0,-144 # ffffffffc0206b30 <commands+0x328>
ffffffffc0200bc8:	dc6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bcc:	8522                	mv	a0,s0
ffffffffc0200bce:	cd5ff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200bd2:	84aa                	mv	s1,a0
ffffffffc0200bd4:	f00508e3          	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bd8:	8522                	mv	a0,s0
ffffffffc0200bda:	c67ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bde:	86a6                	mv	a3,s1
ffffffffc0200be0:	00006617          	auipc	a2,0x6
ffffffffc0200be4:	f1860613          	addi	a2,a2,-232 # ffffffffc0206af8 <commands+0x2f0>
ffffffffc0200be8:	0d700593          	li	a1,215
ffffffffc0200bec:	00006517          	auipc	a0,0x6
ffffffffc0200bf0:	0f450513          	addi	a0,a0,244 # ffffffffc0206ce0 <commands+0x4d8>
ffffffffc0200bf4:	88dff0ef          	jal	ra,ffffffffc0200480 <__panic>
}
ffffffffc0200bf8:	6442                	ld	s0,16(sp)
ffffffffc0200bfa:	60e2                	ld	ra,24(sp)
ffffffffc0200bfc:	64a2                	ld	s1,8(sp)
ffffffffc0200bfe:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c00:	b181                	j	ffffffffc0200840 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c02:	00006617          	auipc	a2,0x6
ffffffffc0200c06:	f1660613          	addi	a2,a2,-234 # ffffffffc0206b18 <commands+0x310>
ffffffffc0200c0a:	0d100593          	li	a1,209
ffffffffc0200c0e:	00006517          	auipc	a0,0x6
ffffffffc0200c12:	0d250513          	addi	a0,a0,210 # ffffffffc0206ce0 <commands+0x4d8>
ffffffffc0200c16:	86bff0ef          	jal	ra,ffffffffc0200480 <__panic>
            print_trapframe(tf);
ffffffffc0200c1a:	b11d                	j	ffffffffc0200840 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c1c:	8522                	mv	a0,s0
ffffffffc0200c1e:	c23ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c22:	86a6                	mv	a3,s1
ffffffffc0200c24:	00006617          	auipc	a2,0x6
ffffffffc0200c28:	ed460613          	addi	a2,a2,-300 # ffffffffc0206af8 <commands+0x2f0>
ffffffffc0200c2c:	0f100593          	li	a1,241
ffffffffc0200c30:	00006517          	auipc	a0,0x6
ffffffffc0200c34:	0b050513          	addi	a0,a0,176 # ffffffffc0206ce0 <commands+0x4d8>
ffffffffc0200c38:	849ff0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0200c3c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c3c:	1101                	addi	sp,sp,-32
ffffffffc0200c3e:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c40:	000ac417          	auipc	s0,0xac
ffffffffc0200c44:	c8840413          	addi	s0,s0,-888 # ffffffffc02ac8c8 <current>
ffffffffc0200c48:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c4a:	ec06                	sd	ra,24(sp)
ffffffffc0200c4c:	e426                	sd	s1,8(sp)
ffffffffc0200c4e:	e04a                	sd	s2,0(sp)
ffffffffc0200c50:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c54:	cf1d                	beqz	a4,ffffffffc0200c92 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c56:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c5a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c5e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c60:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c64:	0206c463          	bltz	a3,ffffffffc0200c8c <trap+0x50>
        exception_handler(tf);
ffffffffc0200c68:	df5ff0ef          	jal	ra,ffffffffc0200a5c <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c6c:	601c                	ld	a5,0(s0)
ffffffffc0200c6e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c72:	e499                	bnez	s1,ffffffffc0200c80 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c74:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c78:	8b05                	andi	a4,a4,1
ffffffffc0200c7a:	e329                	bnez	a4,ffffffffc0200cbc <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c7c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c7e:	eb85                	bnez	a5,ffffffffc0200cae <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c80:	60e2                	ld	ra,24(sp)
ffffffffc0200c82:	6442                	ld	s0,16(sp)
ffffffffc0200c84:	64a2                	ld	s1,8(sp)
ffffffffc0200c86:	6902                	ld	s2,0(sp)
ffffffffc0200c88:	6105                	addi	sp,sp,32
ffffffffc0200c8a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c8c:	d37ff0ef          	jal	ra,ffffffffc02009c2 <interrupt_handler>
ffffffffc0200c90:	bff1                	j	ffffffffc0200c6c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c92:	0006c863          	bltz	a3,ffffffffc0200ca2 <trap+0x66>
}
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	60e2                	ld	ra,24(sp)
ffffffffc0200c9a:	64a2                	ld	s1,8(sp)
ffffffffc0200c9c:	6902                	ld	s2,0(sp)
ffffffffc0200c9e:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ca0:	bb75                	j	ffffffffc0200a5c <exception_handler>
}
ffffffffc0200ca2:	6442                	ld	s0,16(sp)
ffffffffc0200ca4:	60e2                	ld	ra,24(sp)
ffffffffc0200ca6:	64a2                	ld	s1,8(sp)
ffffffffc0200ca8:	6902                	ld	s2,0(sp)
ffffffffc0200caa:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cac:	bb19                	j	ffffffffc02009c2 <interrupt_handler>
}
ffffffffc0200cae:	6442                	ld	s0,16(sp)
ffffffffc0200cb0:	60e2                	ld	ra,24(sp)
ffffffffc0200cb2:	64a2                	ld	s1,8(sp)
ffffffffc0200cb4:	6902                	ld	s2,0(sp)
ffffffffc0200cb6:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cb8:	3de0506f          	j	ffffffffc0206096 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cbc:	555d                	li	a0,-9
ffffffffc0200cbe:	7f4040ef          	jal	ra,ffffffffc02054b2 <do_exit>
ffffffffc0200cc2:	601c                	ld	a5,0(s0)
ffffffffc0200cc4:	bf65                	j	ffffffffc0200c7c <trap+0x40>
	...

ffffffffc0200cc8 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cc8:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ccc:	00011463          	bnez	sp,ffffffffc0200cd4 <__alltraps+0xc>
ffffffffc0200cd0:	14002173          	csrr	sp,sscratch
ffffffffc0200cd4:	712d                	addi	sp,sp,-288
ffffffffc0200cd6:	e002                	sd	zero,0(sp)
ffffffffc0200cd8:	e406                	sd	ra,8(sp)
ffffffffc0200cda:	ec0e                	sd	gp,24(sp)
ffffffffc0200cdc:	f012                	sd	tp,32(sp)
ffffffffc0200cde:	f416                	sd	t0,40(sp)
ffffffffc0200ce0:	f81a                	sd	t1,48(sp)
ffffffffc0200ce2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ce4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ce6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ce8:	e8aa                	sd	a0,80(sp)
ffffffffc0200cea:	ecae                	sd	a1,88(sp)
ffffffffc0200cec:	f0b2                	sd	a2,96(sp)
ffffffffc0200cee:	f4b6                	sd	a3,104(sp)
ffffffffc0200cf0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cf2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cf4:	e142                	sd	a6,128(sp)
ffffffffc0200cf6:	e546                	sd	a7,136(sp)
ffffffffc0200cf8:	e94a                	sd	s2,144(sp)
ffffffffc0200cfa:	ed4e                	sd	s3,152(sp)
ffffffffc0200cfc:	f152                	sd	s4,160(sp)
ffffffffc0200cfe:	f556                	sd	s5,168(sp)
ffffffffc0200d00:	f95a                	sd	s6,176(sp)
ffffffffc0200d02:	fd5e                	sd	s7,184(sp)
ffffffffc0200d04:	e1e2                	sd	s8,192(sp)
ffffffffc0200d06:	e5e6                	sd	s9,200(sp)
ffffffffc0200d08:	e9ea                	sd	s10,208(sp)
ffffffffc0200d0a:	edee                	sd	s11,216(sp)
ffffffffc0200d0c:	f1f2                	sd	t3,224(sp)
ffffffffc0200d0e:	f5f6                	sd	t4,232(sp)
ffffffffc0200d10:	f9fa                	sd	t5,240(sp)
ffffffffc0200d12:	fdfe                	sd	t6,248(sp)
ffffffffc0200d14:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d18:	100024f3          	csrr	s1,sstatus
ffffffffc0200d1c:	14102973          	csrr	s2,sepc
ffffffffc0200d20:	143029f3          	csrr	s3,stval
ffffffffc0200d24:	14202a73          	csrr	s4,scause
ffffffffc0200d28:	e822                	sd	s0,16(sp)
ffffffffc0200d2a:	e226                	sd	s1,256(sp)
ffffffffc0200d2c:	e64a                	sd	s2,264(sp)
ffffffffc0200d2e:	ea4e                	sd	s3,272(sp)
ffffffffc0200d30:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d32:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d34:	f09ff0ef          	jal	ra,ffffffffc0200c3c <trap>

ffffffffc0200d38 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d38:	6492                	ld	s1,256(sp)
ffffffffc0200d3a:	6932                	ld	s2,264(sp)
ffffffffc0200d3c:	1004f413          	andi	s0,s1,256
ffffffffc0200d40:	e401                	bnez	s0,ffffffffc0200d48 <__trapret+0x10>
ffffffffc0200d42:	1200                	addi	s0,sp,288
ffffffffc0200d44:	14041073          	csrw	sscratch,s0
ffffffffc0200d48:	10049073          	csrw	sstatus,s1
ffffffffc0200d4c:	14191073          	csrw	sepc,s2
ffffffffc0200d50:	60a2                	ld	ra,8(sp)
ffffffffc0200d52:	61e2                	ld	gp,24(sp)
ffffffffc0200d54:	7202                	ld	tp,32(sp)
ffffffffc0200d56:	72a2                	ld	t0,40(sp)
ffffffffc0200d58:	7342                	ld	t1,48(sp)
ffffffffc0200d5a:	73e2                	ld	t2,56(sp)
ffffffffc0200d5c:	6406                	ld	s0,64(sp)
ffffffffc0200d5e:	64a6                	ld	s1,72(sp)
ffffffffc0200d60:	6546                	ld	a0,80(sp)
ffffffffc0200d62:	65e6                	ld	a1,88(sp)
ffffffffc0200d64:	7606                	ld	a2,96(sp)
ffffffffc0200d66:	76a6                	ld	a3,104(sp)
ffffffffc0200d68:	7746                	ld	a4,112(sp)
ffffffffc0200d6a:	77e6                	ld	a5,120(sp)
ffffffffc0200d6c:	680a                	ld	a6,128(sp)
ffffffffc0200d6e:	68aa                	ld	a7,136(sp)
ffffffffc0200d70:	694a                	ld	s2,144(sp)
ffffffffc0200d72:	69ea                	ld	s3,152(sp)
ffffffffc0200d74:	7a0a                	ld	s4,160(sp)
ffffffffc0200d76:	7aaa                	ld	s5,168(sp)
ffffffffc0200d78:	7b4a                	ld	s6,176(sp)
ffffffffc0200d7a:	7bea                	ld	s7,184(sp)
ffffffffc0200d7c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d7e:	6cae                	ld	s9,200(sp)
ffffffffc0200d80:	6d4e                	ld	s10,208(sp)
ffffffffc0200d82:	6dee                	ld	s11,216(sp)
ffffffffc0200d84:	7e0e                	ld	t3,224(sp)
ffffffffc0200d86:	7eae                	ld	t4,232(sp)
ffffffffc0200d88:	7f4e                	ld	t5,240(sp)
ffffffffc0200d8a:	7fee                	ld	t6,248(sp)
ffffffffc0200d8c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d8e:	10200073          	sret

ffffffffc0200d92 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d92:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d94:	b755                	j	ffffffffc0200d38 <__trapret>

ffffffffc0200d96 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d96:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76f0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d9a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d9e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200da2:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200da6:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200daa:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dae:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200db2:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200db6:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dba:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dbc:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dbe:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dc0:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dc2:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200dc4:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dc6:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dc8:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dca:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dcc:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dce:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dd0:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dd2:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dd4:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dd6:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dd8:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dda:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200ddc:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dde:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200de0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200de2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200de4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200de6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200de8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dea:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dec:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dee:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200df0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200df2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200df4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200df6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200df8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dfa:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dfc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dfe:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e00:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e02:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e04:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e06:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e08:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e0a:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e0c:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e0e:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e10:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e12:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e14:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e16:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e18:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e1a:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e1c:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e1e:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e20:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e22:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e24:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e26:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e28:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e2a:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e2c:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e2e:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e30:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e32:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e34:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e36:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e38:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e3a:	812e                	mv	sp,a1
ffffffffc0200e3c:	bdf5                	j	ffffffffc0200d38 <__trapret>

ffffffffc0200e3e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e3e:	000ac797          	auipc	a5,0xac
ffffffffc0200e42:	ab278793          	addi	a5,a5,-1358 # ffffffffc02ac8f0 <free_area>
ffffffffc0200e46:	e79c                	sd	a5,8(a5)
ffffffffc0200e48:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e4a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e4e:	8082                	ret

ffffffffc0200e50 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e50:	000ac517          	auipc	a0,0xac
ffffffffc0200e54:	ab056503          	lwu	a0,-1360(a0) # ffffffffc02ac900 <free_area+0x10>
ffffffffc0200e58:	8082                	ret

ffffffffc0200e5a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e5a:	715d                	addi	sp,sp,-80
ffffffffc0200e5c:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e5e:	000ac917          	auipc	s2,0xac
ffffffffc0200e62:	a9290913          	addi	s2,s2,-1390 # ffffffffc02ac8f0 <free_area>
ffffffffc0200e66:	00893783          	ld	a5,8(s2)
ffffffffc0200e6a:	e486                	sd	ra,72(sp)
ffffffffc0200e6c:	e0a2                	sd	s0,64(sp)
ffffffffc0200e6e:	fc26                	sd	s1,56(sp)
ffffffffc0200e70:	f44e                	sd	s3,40(sp)
ffffffffc0200e72:	f052                	sd	s4,32(sp)
ffffffffc0200e74:	ec56                	sd	s5,24(sp)
ffffffffc0200e76:	e85a                	sd	s6,16(sp)
ffffffffc0200e78:	e45e                	sd	s7,8(sp)
ffffffffc0200e7a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e7c:	31278463          	beq	a5,s2,ffffffffc0201184 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e80:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e84:	8305                	srli	a4,a4,0x1
ffffffffc0200e86:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e88:	30070263          	beqz	a4,ffffffffc020118c <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200e8c:	4401                	li	s0,0
ffffffffc0200e8e:	4481                	li	s1,0
ffffffffc0200e90:	a031                	j	ffffffffc0200e9c <default_check+0x42>
ffffffffc0200e92:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200e96:	8b09                	andi	a4,a4,2
ffffffffc0200e98:	2e070a63          	beqz	a4,ffffffffc020118c <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200e9c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ea0:	679c                	ld	a5,8(a5)
ffffffffc0200ea2:	2485                	addiw	s1,s1,1
ffffffffc0200ea4:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ea6:	ff2796e3          	bne	a5,s2,ffffffffc0200e92 <default_check+0x38>
ffffffffc0200eaa:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200eac:	046010ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc0200eb0:	73351e63          	bne	a0,s3,ffffffffc02015ec <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eb4:	4505                	li	a0,1
ffffffffc0200eb6:	76f000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200eba:	8a2a                	mv	s4,a0
ffffffffc0200ebc:	46050863          	beqz	a0,ffffffffc020132c <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ec0:	4505                	li	a0,1
ffffffffc0200ec2:	763000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200ec6:	89aa                	mv	s3,a0
ffffffffc0200ec8:	74050263          	beqz	a0,ffffffffc020160c <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ecc:	4505                	li	a0,1
ffffffffc0200ece:	757000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200ed2:	8aaa                	mv	s5,a0
ffffffffc0200ed4:	4c050c63          	beqz	a0,ffffffffc02013ac <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ed8:	2d3a0a63          	beq	s4,s3,ffffffffc02011ac <default_check+0x352>
ffffffffc0200edc:	2caa0863          	beq	s4,a0,ffffffffc02011ac <default_check+0x352>
ffffffffc0200ee0:	2ca98663          	beq	s3,a0,ffffffffc02011ac <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ee4:	000a2783          	lw	a5,0(s4)
ffffffffc0200ee8:	2e079263          	bnez	a5,ffffffffc02011cc <default_check+0x372>
ffffffffc0200eec:	0009a783          	lw	a5,0(s3)
ffffffffc0200ef0:	2c079e63          	bnez	a5,ffffffffc02011cc <default_check+0x372>
ffffffffc0200ef4:	411c                	lw	a5,0(a0)
ffffffffc0200ef6:	2c079b63          	bnez	a5,ffffffffc02011cc <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200efa:	000ac797          	auipc	a5,0xac
ffffffffc0200efe:	a2678793          	addi	a5,a5,-1498 # ffffffffc02ac920 <pages>
ffffffffc0200f02:	639c                	ld	a5,0(a5)
ffffffffc0200f04:	00008717          	auipc	a4,0x8
ffffffffc0200f08:	ea470713          	addi	a4,a4,-348 # ffffffffc0208da8 <nbase>
ffffffffc0200f0c:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f0e:	000ac717          	auipc	a4,0xac
ffffffffc0200f12:	9a270713          	addi	a4,a4,-1630 # ffffffffc02ac8b0 <npage>
ffffffffc0200f16:	6314                	ld	a3,0(a4)
ffffffffc0200f18:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f1c:	8719                	srai	a4,a4,0x6
ffffffffc0200f1e:	9732                	add	a4,a4,a2
ffffffffc0200f20:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f22:	0732                	slli	a4,a4,0xc
ffffffffc0200f24:	2cd77463          	bgeu	a4,a3,ffffffffc02011ec <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f28:	40f98733          	sub	a4,s3,a5
ffffffffc0200f2c:	8719                	srai	a4,a4,0x6
ffffffffc0200f2e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f30:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f32:	4ed77d63          	bgeu	a4,a3,ffffffffc020142c <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f36:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f3a:	8799                	srai	a5,a5,0x6
ffffffffc0200f3c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f3e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f40:	34d7f663          	bgeu	a5,a3,ffffffffc020128c <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f44:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f46:	00093c03          	ld	s8,0(s2)
ffffffffc0200f4a:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f4e:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f52:	000ac797          	auipc	a5,0xac
ffffffffc0200f56:	9b27b323          	sd	s2,-1626(a5) # ffffffffc02ac8f8 <free_area+0x8>
ffffffffc0200f5a:	000ac797          	auipc	a5,0xac
ffffffffc0200f5e:	9927bb23          	sd	s2,-1642(a5) # ffffffffc02ac8f0 <free_area>
    nr_free = 0;
ffffffffc0200f62:	000ac797          	auipc	a5,0xac
ffffffffc0200f66:	9807af23          	sw	zero,-1634(a5) # ffffffffc02ac900 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f6a:	6bb000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200f6e:	2e051f63          	bnez	a0,ffffffffc020126c <default_check+0x412>
    free_page(p0);
ffffffffc0200f72:	4585                	li	a1,1
ffffffffc0200f74:	8552                	mv	a0,s4
ffffffffc0200f76:	737000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p1);
ffffffffc0200f7a:	4585                	li	a1,1
ffffffffc0200f7c:	854e                	mv	a0,s3
ffffffffc0200f7e:	72f000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p2);
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	8556                	mv	a0,s5
ffffffffc0200f86:	727000ef          	jal	ra,ffffffffc0201eac <free_pages>
    assert(nr_free == 3);
ffffffffc0200f8a:	01092703          	lw	a4,16(s2)
ffffffffc0200f8e:	478d                	li	a5,3
ffffffffc0200f90:	2af71e63          	bne	a4,a5,ffffffffc020124c <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f94:	4505                	li	a0,1
ffffffffc0200f96:	68f000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200f9a:	89aa                	mv	s3,a0
ffffffffc0200f9c:	28050863          	beqz	a0,ffffffffc020122c <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fa0:	4505                	li	a0,1
ffffffffc0200fa2:	683000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fa6:	8aaa                	mv	s5,a0
ffffffffc0200fa8:	3e050263          	beqz	a0,ffffffffc020138c <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fac:	4505                	li	a0,1
ffffffffc0200fae:	677000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fb2:	8a2a                	mv	s4,a0
ffffffffc0200fb4:	3a050c63          	beqz	a0,ffffffffc020136c <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fb8:	4505                	li	a0,1
ffffffffc0200fba:	66b000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fbe:	38051763          	bnez	a0,ffffffffc020134c <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fc2:	4585                	li	a1,1
ffffffffc0200fc4:	854e                	mv	a0,s3
ffffffffc0200fc6:	6e7000ef          	jal	ra,ffffffffc0201eac <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fca:	00893783          	ld	a5,8(s2)
ffffffffc0200fce:	23278f63          	beq	a5,s2,ffffffffc020120c <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fd2:	4505                	li	a0,1
ffffffffc0200fd4:	651000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fd8:	32a99a63          	bne	s3,a0,ffffffffc020130c <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200fdc:	4505                	li	a0,1
ffffffffc0200fde:	647000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fe2:	30051563          	bnez	a0,ffffffffc02012ec <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200fe6:	01092783          	lw	a5,16(s2)
ffffffffc0200fea:	2e079163          	bnez	a5,ffffffffc02012cc <default_check+0x472>
    free_page(p);
ffffffffc0200fee:	854e                	mv	a0,s3
ffffffffc0200ff0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ff2:	000ac797          	auipc	a5,0xac
ffffffffc0200ff6:	8f87bf23          	sd	s8,-1794(a5) # ffffffffc02ac8f0 <free_area>
ffffffffc0200ffa:	000ac797          	auipc	a5,0xac
ffffffffc0200ffe:	8f77bf23          	sd	s7,-1794(a5) # ffffffffc02ac8f8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0201002:	000ac797          	auipc	a5,0xac
ffffffffc0201006:	8f67af23          	sw	s6,-1794(a5) # ffffffffc02ac900 <free_area+0x10>
    free_page(p);
ffffffffc020100a:	6a3000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p1);
ffffffffc020100e:	4585                	li	a1,1
ffffffffc0201010:	8556                	mv	a0,s5
ffffffffc0201012:	69b000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p2);
ffffffffc0201016:	4585                	li	a1,1
ffffffffc0201018:	8552                	mv	a0,s4
ffffffffc020101a:	693000ef          	jal	ra,ffffffffc0201eac <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020101e:	4515                	li	a0,5
ffffffffc0201020:	605000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201024:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201026:	28050363          	beqz	a0,ffffffffc02012ac <default_check+0x452>
ffffffffc020102a:	651c                	ld	a5,8(a0)
ffffffffc020102c:	8385                	srli	a5,a5,0x1
ffffffffc020102e:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201030:	54079e63          	bnez	a5,ffffffffc020158c <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201034:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201036:	00093b03          	ld	s6,0(s2)
ffffffffc020103a:	00893a83          	ld	s5,8(s2)
ffffffffc020103e:	000ac797          	auipc	a5,0xac
ffffffffc0201042:	8b27b923          	sd	s2,-1870(a5) # ffffffffc02ac8f0 <free_area>
ffffffffc0201046:	000ac797          	auipc	a5,0xac
ffffffffc020104a:	8b27b923          	sd	s2,-1870(a5) # ffffffffc02ac8f8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc020104e:	5d7000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201052:	50051d63          	bnez	a0,ffffffffc020156c <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201056:	08098a13          	addi	s4,s3,128
ffffffffc020105a:	8552                	mv	a0,s4
ffffffffc020105c:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020105e:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0201062:	000ac797          	auipc	a5,0xac
ffffffffc0201066:	8807af23          	sw	zero,-1890(a5) # ffffffffc02ac900 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020106a:	643000ef          	jal	ra,ffffffffc0201eac <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020106e:	4511                	li	a0,4
ffffffffc0201070:	5b5000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201074:	4c051c63          	bnez	a0,ffffffffc020154c <default_check+0x6f2>
ffffffffc0201078:	0889b783          	ld	a5,136(s3)
ffffffffc020107c:	8385                	srli	a5,a5,0x1
ffffffffc020107e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201080:	4a078663          	beqz	a5,ffffffffc020152c <default_check+0x6d2>
ffffffffc0201084:	0909a703          	lw	a4,144(s3)
ffffffffc0201088:	478d                	li	a5,3
ffffffffc020108a:	4af71163          	bne	a4,a5,ffffffffc020152c <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020108e:	450d                	li	a0,3
ffffffffc0201090:	595000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201094:	8c2a                	mv	s8,a0
ffffffffc0201096:	46050b63          	beqz	a0,ffffffffc020150c <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc020109a:	4505                	li	a0,1
ffffffffc020109c:	589000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02010a0:	44051663          	bnez	a0,ffffffffc02014ec <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010a4:	438a1463          	bne	s4,s8,ffffffffc02014cc <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010a8:	4585                	li	a1,1
ffffffffc02010aa:	854e                	mv	a0,s3
ffffffffc02010ac:	601000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_pages(p1, 3);
ffffffffc02010b0:	458d                	li	a1,3
ffffffffc02010b2:	8552                	mv	a0,s4
ffffffffc02010b4:	5f9000ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc02010b8:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010bc:	04098c13          	addi	s8,s3,64
ffffffffc02010c0:	8385                	srli	a5,a5,0x1
ffffffffc02010c2:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010c4:	3e078463          	beqz	a5,ffffffffc02014ac <default_check+0x652>
ffffffffc02010c8:	0109a703          	lw	a4,16(s3)
ffffffffc02010cc:	4785                	li	a5,1
ffffffffc02010ce:	3cf71f63          	bne	a4,a5,ffffffffc02014ac <default_check+0x652>
ffffffffc02010d2:	008a3783          	ld	a5,8(s4)
ffffffffc02010d6:	8385                	srli	a5,a5,0x1
ffffffffc02010d8:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010da:	3a078963          	beqz	a5,ffffffffc020148c <default_check+0x632>
ffffffffc02010de:	010a2703          	lw	a4,16(s4)
ffffffffc02010e2:	478d                	li	a5,3
ffffffffc02010e4:	3af71463          	bne	a4,a5,ffffffffc020148c <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010e8:	4505                	li	a0,1
ffffffffc02010ea:	53b000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02010ee:	36a99f63          	bne	s3,a0,ffffffffc020146c <default_check+0x612>
    free_page(p0);
ffffffffc02010f2:	4585                	li	a1,1
ffffffffc02010f4:	5b9000ef          	jal	ra,ffffffffc0201eac <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010f8:	4509                	li	a0,2
ffffffffc02010fa:	52b000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02010fe:	34aa1763          	bne	s4,a0,ffffffffc020144c <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0201102:	4589                	li	a1,2
ffffffffc0201104:	5a9000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p2);
ffffffffc0201108:	4585                	li	a1,1
ffffffffc020110a:	8562                	mv	a0,s8
ffffffffc020110c:	5a1000ef          	jal	ra,ffffffffc0201eac <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201110:	4515                	li	a0,5
ffffffffc0201112:	513000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201116:	89aa                	mv	s3,a0
ffffffffc0201118:	48050a63          	beqz	a0,ffffffffc02015ac <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc020111c:	4505                	li	a0,1
ffffffffc020111e:	507000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201122:	2e051563          	bnez	a0,ffffffffc020140c <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0201126:	01092783          	lw	a5,16(s2)
ffffffffc020112a:	2c079163          	bnez	a5,ffffffffc02013ec <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020112e:	4595                	li	a1,5
ffffffffc0201130:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201132:	000ab797          	auipc	a5,0xab
ffffffffc0201136:	7d77a723          	sw	s7,1998(a5) # ffffffffc02ac900 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020113a:	000ab797          	auipc	a5,0xab
ffffffffc020113e:	7b67bb23          	sd	s6,1974(a5) # ffffffffc02ac8f0 <free_area>
ffffffffc0201142:	000ab797          	auipc	a5,0xab
ffffffffc0201146:	7b57bb23          	sd	s5,1974(a5) # ffffffffc02ac8f8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020114a:	563000ef          	jal	ra,ffffffffc0201eac <free_pages>
    return listelm->next;
ffffffffc020114e:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201152:	01278963          	beq	a5,s2,ffffffffc0201164 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201156:	ff87a703          	lw	a4,-8(a5)
ffffffffc020115a:	679c                	ld	a5,8(a5)
ffffffffc020115c:	34fd                	addiw	s1,s1,-1
ffffffffc020115e:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201160:	ff279be3          	bne	a5,s2,ffffffffc0201156 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0201164:	26049463          	bnez	s1,ffffffffc02013cc <default_check+0x572>
    assert(total == 0);
ffffffffc0201168:	46041263          	bnez	s0,ffffffffc02015cc <default_check+0x772>
}
ffffffffc020116c:	60a6                	ld	ra,72(sp)
ffffffffc020116e:	6406                	ld	s0,64(sp)
ffffffffc0201170:	74e2                	ld	s1,56(sp)
ffffffffc0201172:	7942                	ld	s2,48(sp)
ffffffffc0201174:	79a2                	ld	s3,40(sp)
ffffffffc0201176:	7a02                	ld	s4,32(sp)
ffffffffc0201178:	6ae2                	ld	s5,24(sp)
ffffffffc020117a:	6b42                	ld	s6,16(sp)
ffffffffc020117c:	6ba2                	ld	s7,8(sp)
ffffffffc020117e:	6c02                	ld	s8,0(sp)
ffffffffc0201180:	6161                	addi	sp,sp,80
ffffffffc0201182:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201184:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201186:	4401                	li	s0,0
ffffffffc0201188:	4481                	li	s1,0
ffffffffc020118a:	b30d                	j	ffffffffc0200eac <default_check+0x52>
        assert(PageProperty(p));
ffffffffc020118c:	00006697          	auipc	a3,0x6
ffffffffc0201190:	ef468693          	addi	a3,a3,-268 # ffffffffc0207080 <commands+0x878>
ffffffffc0201194:	00006617          	auipc	a2,0x6
ffffffffc0201198:	b3460613          	addi	a2,a2,-1228 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020119c:	0f000593          	li	a1,240
ffffffffc02011a0:	00006517          	auipc	a0,0x6
ffffffffc02011a4:	ef050513          	addi	a0,a0,-272 # ffffffffc0207090 <commands+0x888>
ffffffffc02011a8:	ad8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011ac:	00006697          	auipc	a3,0x6
ffffffffc02011b0:	f7c68693          	addi	a3,a3,-132 # ffffffffc0207128 <commands+0x920>
ffffffffc02011b4:	00006617          	auipc	a2,0x6
ffffffffc02011b8:	b1460613          	addi	a2,a2,-1260 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02011bc:	0bd00593          	li	a1,189
ffffffffc02011c0:	00006517          	auipc	a0,0x6
ffffffffc02011c4:	ed050513          	addi	a0,a0,-304 # ffffffffc0207090 <commands+0x888>
ffffffffc02011c8:	ab8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011cc:	00006697          	auipc	a3,0x6
ffffffffc02011d0:	f8468693          	addi	a3,a3,-124 # ffffffffc0207150 <commands+0x948>
ffffffffc02011d4:	00006617          	auipc	a2,0x6
ffffffffc02011d8:	af460613          	addi	a2,a2,-1292 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02011dc:	0be00593          	li	a1,190
ffffffffc02011e0:	00006517          	auipc	a0,0x6
ffffffffc02011e4:	eb050513          	addi	a0,a0,-336 # ffffffffc0207090 <commands+0x888>
ffffffffc02011e8:	a98ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011ec:	00006697          	auipc	a3,0x6
ffffffffc02011f0:	fa468693          	addi	a3,a3,-92 # ffffffffc0207190 <commands+0x988>
ffffffffc02011f4:	00006617          	auipc	a2,0x6
ffffffffc02011f8:	ad460613          	addi	a2,a2,-1324 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02011fc:	0c000593          	li	a1,192
ffffffffc0201200:	00006517          	auipc	a0,0x6
ffffffffc0201204:	e9050513          	addi	a0,a0,-368 # ffffffffc0207090 <commands+0x888>
ffffffffc0201208:	a78ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020120c:	00006697          	auipc	a3,0x6
ffffffffc0201210:	00c68693          	addi	a3,a3,12 # ffffffffc0207218 <commands+0xa10>
ffffffffc0201214:	00006617          	auipc	a2,0x6
ffffffffc0201218:	ab460613          	addi	a2,a2,-1356 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020121c:	0d900593          	li	a1,217
ffffffffc0201220:	00006517          	auipc	a0,0x6
ffffffffc0201224:	e7050513          	addi	a0,a0,-400 # ffffffffc0207090 <commands+0x888>
ffffffffc0201228:	a58ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020122c:	00006697          	auipc	a3,0x6
ffffffffc0201230:	e9c68693          	addi	a3,a3,-356 # ffffffffc02070c8 <commands+0x8c0>
ffffffffc0201234:	00006617          	auipc	a2,0x6
ffffffffc0201238:	a9460613          	addi	a2,a2,-1388 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020123c:	0d200593          	li	a1,210
ffffffffc0201240:	00006517          	auipc	a0,0x6
ffffffffc0201244:	e5050513          	addi	a0,a0,-432 # ffffffffc0207090 <commands+0x888>
ffffffffc0201248:	a38ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 3);
ffffffffc020124c:	00006697          	auipc	a3,0x6
ffffffffc0201250:	fbc68693          	addi	a3,a3,-68 # ffffffffc0207208 <commands+0xa00>
ffffffffc0201254:	00006617          	auipc	a2,0x6
ffffffffc0201258:	a7460613          	addi	a2,a2,-1420 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020125c:	0d000593          	li	a1,208
ffffffffc0201260:	00006517          	auipc	a0,0x6
ffffffffc0201264:	e3050513          	addi	a0,a0,-464 # ffffffffc0207090 <commands+0x888>
ffffffffc0201268:	a18ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020126c:	00006697          	auipc	a3,0x6
ffffffffc0201270:	f8468693          	addi	a3,a3,-124 # ffffffffc02071f0 <commands+0x9e8>
ffffffffc0201274:	00006617          	auipc	a2,0x6
ffffffffc0201278:	a5460613          	addi	a2,a2,-1452 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020127c:	0cb00593          	li	a1,203
ffffffffc0201280:	00006517          	auipc	a0,0x6
ffffffffc0201284:	e1050513          	addi	a0,a0,-496 # ffffffffc0207090 <commands+0x888>
ffffffffc0201288:	9f8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020128c:	00006697          	auipc	a3,0x6
ffffffffc0201290:	f4468693          	addi	a3,a3,-188 # ffffffffc02071d0 <commands+0x9c8>
ffffffffc0201294:	00006617          	auipc	a2,0x6
ffffffffc0201298:	a3460613          	addi	a2,a2,-1484 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020129c:	0c200593          	li	a1,194
ffffffffc02012a0:	00006517          	auipc	a0,0x6
ffffffffc02012a4:	df050513          	addi	a0,a0,-528 # ffffffffc0207090 <commands+0x888>
ffffffffc02012a8:	9d8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 != NULL);
ffffffffc02012ac:	00006697          	auipc	a3,0x6
ffffffffc02012b0:	fb468693          	addi	a3,a3,-76 # ffffffffc0207260 <commands+0xa58>
ffffffffc02012b4:	00006617          	auipc	a2,0x6
ffffffffc02012b8:	a1460613          	addi	a2,a2,-1516 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02012bc:	0f800593          	li	a1,248
ffffffffc02012c0:	00006517          	auipc	a0,0x6
ffffffffc02012c4:	dd050513          	addi	a0,a0,-560 # ffffffffc0207090 <commands+0x888>
ffffffffc02012c8:	9b8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 0);
ffffffffc02012cc:	00006697          	auipc	a3,0x6
ffffffffc02012d0:	f8468693          	addi	a3,a3,-124 # ffffffffc0207250 <commands+0xa48>
ffffffffc02012d4:	00006617          	auipc	a2,0x6
ffffffffc02012d8:	9f460613          	addi	a2,a2,-1548 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02012dc:	0df00593          	li	a1,223
ffffffffc02012e0:	00006517          	auipc	a0,0x6
ffffffffc02012e4:	db050513          	addi	a0,a0,-592 # ffffffffc0207090 <commands+0x888>
ffffffffc02012e8:	998ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012ec:	00006697          	auipc	a3,0x6
ffffffffc02012f0:	f0468693          	addi	a3,a3,-252 # ffffffffc02071f0 <commands+0x9e8>
ffffffffc02012f4:	00006617          	auipc	a2,0x6
ffffffffc02012f8:	9d460613          	addi	a2,a2,-1580 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02012fc:	0dd00593          	li	a1,221
ffffffffc0201300:	00006517          	auipc	a0,0x6
ffffffffc0201304:	d9050513          	addi	a0,a0,-624 # ffffffffc0207090 <commands+0x888>
ffffffffc0201308:	978ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020130c:	00006697          	auipc	a3,0x6
ffffffffc0201310:	f2468693          	addi	a3,a3,-220 # ffffffffc0207230 <commands+0xa28>
ffffffffc0201314:	00006617          	auipc	a2,0x6
ffffffffc0201318:	9b460613          	addi	a2,a2,-1612 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020131c:	0dc00593          	li	a1,220
ffffffffc0201320:	00006517          	auipc	a0,0x6
ffffffffc0201324:	d7050513          	addi	a0,a0,-656 # ffffffffc0207090 <commands+0x888>
ffffffffc0201328:	958ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020132c:	00006697          	auipc	a3,0x6
ffffffffc0201330:	d9c68693          	addi	a3,a3,-612 # ffffffffc02070c8 <commands+0x8c0>
ffffffffc0201334:	00006617          	auipc	a2,0x6
ffffffffc0201338:	99460613          	addi	a2,a2,-1644 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020133c:	0b900593          	li	a1,185
ffffffffc0201340:	00006517          	auipc	a0,0x6
ffffffffc0201344:	d5050513          	addi	a0,a0,-688 # ffffffffc0207090 <commands+0x888>
ffffffffc0201348:	938ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020134c:	00006697          	auipc	a3,0x6
ffffffffc0201350:	ea468693          	addi	a3,a3,-348 # ffffffffc02071f0 <commands+0x9e8>
ffffffffc0201354:	00006617          	auipc	a2,0x6
ffffffffc0201358:	97460613          	addi	a2,a2,-1676 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020135c:	0d600593          	li	a1,214
ffffffffc0201360:	00006517          	auipc	a0,0x6
ffffffffc0201364:	d3050513          	addi	a0,a0,-720 # ffffffffc0207090 <commands+0x888>
ffffffffc0201368:	918ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020136c:	00006697          	auipc	a3,0x6
ffffffffc0201370:	d9c68693          	addi	a3,a3,-612 # ffffffffc0207108 <commands+0x900>
ffffffffc0201374:	00006617          	auipc	a2,0x6
ffffffffc0201378:	95460613          	addi	a2,a2,-1708 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020137c:	0d400593          	li	a1,212
ffffffffc0201380:	00006517          	auipc	a0,0x6
ffffffffc0201384:	d1050513          	addi	a0,a0,-752 # ffffffffc0207090 <commands+0x888>
ffffffffc0201388:	8f8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020138c:	00006697          	auipc	a3,0x6
ffffffffc0201390:	d5c68693          	addi	a3,a3,-676 # ffffffffc02070e8 <commands+0x8e0>
ffffffffc0201394:	00006617          	auipc	a2,0x6
ffffffffc0201398:	93460613          	addi	a2,a2,-1740 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020139c:	0d300593          	li	a1,211
ffffffffc02013a0:	00006517          	auipc	a0,0x6
ffffffffc02013a4:	cf050513          	addi	a0,a0,-784 # ffffffffc0207090 <commands+0x888>
ffffffffc02013a8:	8d8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013ac:	00006697          	auipc	a3,0x6
ffffffffc02013b0:	d5c68693          	addi	a3,a3,-676 # ffffffffc0207108 <commands+0x900>
ffffffffc02013b4:	00006617          	auipc	a2,0x6
ffffffffc02013b8:	91460613          	addi	a2,a2,-1772 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02013bc:	0bb00593          	li	a1,187
ffffffffc02013c0:	00006517          	auipc	a0,0x6
ffffffffc02013c4:	cd050513          	addi	a0,a0,-816 # ffffffffc0207090 <commands+0x888>
ffffffffc02013c8:	8b8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(count == 0);
ffffffffc02013cc:	00006697          	auipc	a3,0x6
ffffffffc02013d0:	fe468693          	addi	a3,a3,-28 # ffffffffc02073b0 <commands+0xba8>
ffffffffc02013d4:	00006617          	auipc	a2,0x6
ffffffffc02013d8:	8f460613          	addi	a2,a2,-1804 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02013dc:	12500593          	li	a1,293
ffffffffc02013e0:	00006517          	auipc	a0,0x6
ffffffffc02013e4:	cb050513          	addi	a0,a0,-848 # ffffffffc0207090 <commands+0x888>
ffffffffc02013e8:	898ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 0);
ffffffffc02013ec:	00006697          	auipc	a3,0x6
ffffffffc02013f0:	e6468693          	addi	a3,a3,-412 # ffffffffc0207250 <commands+0xa48>
ffffffffc02013f4:	00006617          	auipc	a2,0x6
ffffffffc02013f8:	8d460613          	addi	a2,a2,-1836 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02013fc:	11a00593          	li	a1,282
ffffffffc0201400:	00006517          	auipc	a0,0x6
ffffffffc0201404:	c9050513          	addi	a0,a0,-880 # ffffffffc0207090 <commands+0x888>
ffffffffc0201408:	878ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020140c:	00006697          	auipc	a3,0x6
ffffffffc0201410:	de468693          	addi	a3,a3,-540 # ffffffffc02071f0 <commands+0x9e8>
ffffffffc0201414:	00006617          	auipc	a2,0x6
ffffffffc0201418:	8b460613          	addi	a2,a2,-1868 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020141c:	11800593          	li	a1,280
ffffffffc0201420:	00006517          	auipc	a0,0x6
ffffffffc0201424:	c7050513          	addi	a0,a0,-912 # ffffffffc0207090 <commands+0x888>
ffffffffc0201428:	858ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020142c:	00006697          	auipc	a3,0x6
ffffffffc0201430:	d8468693          	addi	a3,a3,-636 # ffffffffc02071b0 <commands+0x9a8>
ffffffffc0201434:	00006617          	auipc	a2,0x6
ffffffffc0201438:	89460613          	addi	a2,a2,-1900 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020143c:	0c100593          	li	a1,193
ffffffffc0201440:	00006517          	auipc	a0,0x6
ffffffffc0201444:	c5050513          	addi	a0,a0,-944 # ffffffffc0207090 <commands+0x888>
ffffffffc0201448:	838ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020144c:	00006697          	auipc	a3,0x6
ffffffffc0201450:	f2468693          	addi	a3,a3,-220 # ffffffffc0207370 <commands+0xb68>
ffffffffc0201454:	00006617          	auipc	a2,0x6
ffffffffc0201458:	87460613          	addi	a2,a2,-1932 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020145c:	11200593          	li	a1,274
ffffffffc0201460:	00006517          	auipc	a0,0x6
ffffffffc0201464:	c3050513          	addi	a0,a0,-976 # ffffffffc0207090 <commands+0x888>
ffffffffc0201468:	818ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020146c:	00006697          	auipc	a3,0x6
ffffffffc0201470:	ee468693          	addi	a3,a3,-284 # ffffffffc0207350 <commands+0xb48>
ffffffffc0201474:	00006617          	auipc	a2,0x6
ffffffffc0201478:	85460613          	addi	a2,a2,-1964 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020147c:	11000593          	li	a1,272
ffffffffc0201480:	00006517          	auipc	a0,0x6
ffffffffc0201484:	c1050513          	addi	a0,a0,-1008 # ffffffffc0207090 <commands+0x888>
ffffffffc0201488:	ff9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020148c:	00006697          	auipc	a3,0x6
ffffffffc0201490:	e9c68693          	addi	a3,a3,-356 # ffffffffc0207328 <commands+0xb20>
ffffffffc0201494:	00006617          	auipc	a2,0x6
ffffffffc0201498:	83460613          	addi	a2,a2,-1996 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020149c:	10e00593          	li	a1,270
ffffffffc02014a0:	00006517          	auipc	a0,0x6
ffffffffc02014a4:	bf050513          	addi	a0,a0,-1040 # ffffffffc0207090 <commands+0x888>
ffffffffc02014a8:	fd9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014ac:	00006697          	auipc	a3,0x6
ffffffffc02014b0:	e5468693          	addi	a3,a3,-428 # ffffffffc0207300 <commands+0xaf8>
ffffffffc02014b4:	00006617          	auipc	a2,0x6
ffffffffc02014b8:	81460613          	addi	a2,a2,-2028 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02014bc:	10d00593          	li	a1,269
ffffffffc02014c0:	00006517          	auipc	a0,0x6
ffffffffc02014c4:	bd050513          	addi	a0,a0,-1072 # ffffffffc0207090 <commands+0x888>
ffffffffc02014c8:	fb9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014cc:	00006697          	auipc	a3,0x6
ffffffffc02014d0:	e2468693          	addi	a3,a3,-476 # ffffffffc02072f0 <commands+0xae8>
ffffffffc02014d4:	00005617          	auipc	a2,0x5
ffffffffc02014d8:	7f460613          	addi	a2,a2,2036 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02014dc:	10800593          	li	a1,264
ffffffffc02014e0:	00006517          	auipc	a0,0x6
ffffffffc02014e4:	bb050513          	addi	a0,a0,-1104 # ffffffffc0207090 <commands+0x888>
ffffffffc02014e8:	f99fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014ec:	00006697          	auipc	a3,0x6
ffffffffc02014f0:	d0468693          	addi	a3,a3,-764 # ffffffffc02071f0 <commands+0x9e8>
ffffffffc02014f4:	00005617          	auipc	a2,0x5
ffffffffc02014f8:	7d460613          	addi	a2,a2,2004 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02014fc:	10700593          	li	a1,263
ffffffffc0201500:	00006517          	auipc	a0,0x6
ffffffffc0201504:	b9050513          	addi	a0,a0,-1136 # ffffffffc0207090 <commands+0x888>
ffffffffc0201508:	f79fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020150c:	00006697          	auipc	a3,0x6
ffffffffc0201510:	dc468693          	addi	a3,a3,-572 # ffffffffc02072d0 <commands+0xac8>
ffffffffc0201514:	00005617          	auipc	a2,0x5
ffffffffc0201518:	7b460613          	addi	a2,a2,1972 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020151c:	10600593          	li	a1,262
ffffffffc0201520:	00006517          	auipc	a0,0x6
ffffffffc0201524:	b7050513          	addi	a0,a0,-1168 # ffffffffc0207090 <commands+0x888>
ffffffffc0201528:	f59fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020152c:	00006697          	auipc	a3,0x6
ffffffffc0201530:	d7468693          	addi	a3,a3,-652 # ffffffffc02072a0 <commands+0xa98>
ffffffffc0201534:	00005617          	auipc	a2,0x5
ffffffffc0201538:	79460613          	addi	a2,a2,1940 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020153c:	10500593          	li	a1,261
ffffffffc0201540:	00006517          	auipc	a0,0x6
ffffffffc0201544:	b5050513          	addi	a0,a0,-1200 # ffffffffc0207090 <commands+0x888>
ffffffffc0201548:	f39fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020154c:	00006697          	auipc	a3,0x6
ffffffffc0201550:	d3c68693          	addi	a3,a3,-708 # ffffffffc0207288 <commands+0xa80>
ffffffffc0201554:	00005617          	auipc	a2,0x5
ffffffffc0201558:	77460613          	addi	a2,a2,1908 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020155c:	10400593          	li	a1,260
ffffffffc0201560:	00006517          	auipc	a0,0x6
ffffffffc0201564:	b3050513          	addi	a0,a0,-1232 # ffffffffc0207090 <commands+0x888>
ffffffffc0201568:	f19fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020156c:	00006697          	auipc	a3,0x6
ffffffffc0201570:	c8468693          	addi	a3,a3,-892 # ffffffffc02071f0 <commands+0x9e8>
ffffffffc0201574:	00005617          	auipc	a2,0x5
ffffffffc0201578:	75460613          	addi	a2,a2,1876 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020157c:	0fe00593          	li	a1,254
ffffffffc0201580:	00006517          	auipc	a0,0x6
ffffffffc0201584:	b1050513          	addi	a0,a0,-1264 # ffffffffc0207090 <commands+0x888>
ffffffffc0201588:	ef9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(!PageProperty(p0));
ffffffffc020158c:	00006697          	auipc	a3,0x6
ffffffffc0201590:	ce468693          	addi	a3,a3,-796 # ffffffffc0207270 <commands+0xa68>
ffffffffc0201594:	00005617          	auipc	a2,0x5
ffffffffc0201598:	73460613          	addi	a2,a2,1844 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020159c:	0f900593          	li	a1,249
ffffffffc02015a0:	00006517          	auipc	a0,0x6
ffffffffc02015a4:	af050513          	addi	a0,a0,-1296 # ffffffffc0207090 <commands+0x888>
ffffffffc02015a8:	ed9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015ac:	00006697          	auipc	a3,0x6
ffffffffc02015b0:	de468693          	addi	a3,a3,-540 # ffffffffc0207390 <commands+0xb88>
ffffffffc02015b4:	00005617          	auipc	a2,0x5
ffffffffc02015b8:	71460613          	addi	a2,a2,1812 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02015bc:	11700593          	li	a1,279
ffffffffc02015c0:	00006517          	auipc	a0,0x6
ffffffffc02015c4:	ad050513          	addi	a0,a0,-1328 # ffffffffc0207090 <commands+0x888>
ffffffffc02015c8:	eb9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(total == 0);
ffffffffc02015cc:	00006697          	auipc	a3,0x6
ffffffffc02015d0:	df468693          	addi	a3,a3,-524 # ffffffffc02073c0 <commands+0xbb8>
ffffffffc02015d4:	00005617          	auipc	a2,0x5
ffffffffc02015d8:	6f460613          	addi	a2,a2,1780 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02015dc:	12600593          	li	a1,294
ffffffffc02015e0:	00006517          	auipc	a0,0x6
ffffffffc02015e4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0207090 <commands+0x888>
ffffffffc02015e8:	e99fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(total == nr_free_pages());
ffffffffc02015ec:	00006697          	auipc	a3,0x6
ffffffffc02015f0:	abc68693          	addi	a3,a3,-1348 # ffffffffc02070a8 <commands+0x8a0>
ffffffffc02015f4:	00005617          	auipc	a2,0x5
ffffffffc02015f8:	6d460613          	addi	a2,a2,1748 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02015fc:	0f300593          	li	a1,243
ffffffffc0201600:	00006517          	auipc	a0,0x6
ffffffffc0201604:	a9050513          	addi	a0,a0,-1392 # ffffffffc0207090 <commands+0x888>
ffffffffc0201608:	e79fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020160c:	00006697          	auipc	a3,0x6
ffffffffc0201610:	adc68693          	addi	a3,a3,-1316 # ffffffffc02070e8 <commands+0x8e0>
ffffffffc0201614:	00005617          	auipc	a2,0x5
ffffffffc0201618:	6b460613          	addi	a2,a2,1716 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020161c:	0ba00593          	li	a1,186
ffffffffc0201620:	00006517          	auipc	a0,0x6
ffffffffc0201624:	a7050513          	addi	a0,a0,-1424 # ffffffffc0207090 <commands+0x888>
ffffffffc0201628:	e59fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020162c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020162c:	1141                	addi	sp,sp,-16
ffffffffc020162e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201630:	16058e63          	beqz	a1,ffffffffc02017ac <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201634:	00659693          	slli	a3,a1,0x6
ffffffffc0201638:	96aa                	add	a3,a3,a0
ffffffffc020163a:	02d50d63          	beq	a0,a3,ffffffffc0201674 <default_free_pages+0x48>
ffffffffc020163e:	651c                	ld	a5,8(a0)
ffffffffc0201640:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201642:	14079563          	bnez	a5,ffffffffc020178c <default_free_pages+0x160>
ffffffffc0201646:	651c                	ld	a5,8(a0)
ffffffffc0201648:	8385                	srli	a5,a5,0x1
ffffffffc020164a:	8b85                	andi	a5,a5,1
ffffffffc020164c:	14079063          	bnez	a5,ffffffffc020178c <default_free_pages+0x160>
ffffffffc0201650:	87aa                	mv	a5,a0
ffffffffc0201652:	a809                	j	ffffffffc0201664 <default_free_pages+0x38>
ffffffffc0201654:	6798                	ld	a4,8(a5)
ffffffffc0201656:	8b05                	andi	a4,a4,1
ffffffffc0201658:	12071a63          	bnez	a4,ffffffffc020178c <default_free_pages+0x160>
ffffffffc020165c:	6798                	ld	a4,8(a5)
ffffffffc020165e:	8b09                	andi	a4,a4,2
ffffffffc0201660:	12071663          	bnez	a4,ffffffffc020178c <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0201664:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201668:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020166c:	04078793          	addi	a5,a5,64
ffffffffc0201670:	fed792e3          	bne	a5,a3,ffffffffc0201654 <default_free_pages+0x28>
    base->property = n;
ffffffffc0201674:	2581                	sext.w	a1,a1
ffffffffc0201676:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201678:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020167c:	4789                	li	a5,2
ffffffffc020167e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201682:	000ab697          	auipc	a3,0xab
ffffffffc0201686:	26e68693          	addi	a3,a3,622 # ffffffffc02ac8f0 <free_area>
ffffffffc020168a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020168c:	669c                	ld	a5,8(a3)
ffffffffc020168e:	9db9                	addw	a1,a1,a4
ffffffffc0201690:	000ab717          	auipc	a4,0xab
ffffffffc0201694:	26b72823          	sw	a1,624(a4) # ffffffffc02ac900 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201698:	0cd78163          	beq	a5,a3,ffffffffc020175a <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc020169c:	fe878713          	addi	a4,a5,-24
ffffffffc02016a0:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016a2:	4801                	li	a6,0
ffffffffc02016a4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016a8:	00e56a63          	bltu	a0,a4,ffffffffc02016bc <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016ac:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016ae:	04d70f63          	beq	a4,a3,ffffffffc020170c <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016b2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016b4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016b8:	fee57ae3          	bgeu	a0,a4,ffffffffc02016ac <default_free_pages+0x80>
ffffffffc02016bc:	00080663          	beqz	a6,ffffffffc02016c8 <default_free_pages+0x9c>
ffffffffc02016c0:	000ab817          	auipc	a6,0xab
ffffffffc02016c4:	22b83823          	sd	a1,560(a6) # ffffffffc02ac8f0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016c8:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016ca:	e390                	sd	a2,0(a5)
ffffffffc02016cc:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016ce:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016d0:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016d2:	06d58a63          	beq	a1,a3,ffffffffc0201746 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016d6:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016da:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016de:	02061793          	slli	a5,a2,0x20
ffffffffc02016e2:	83e9                	srli	a5,a5,0x1a
ffffffffc02016e4:	97ba                	add	a5,a5,a4
ffffffffc02016e6:	04f51b63          	bne	a0,a5,ffffffffc020173c <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02016ea:	491c                	lw	a5,16(a0)
ffffffffc02016ec:	9e3d                	addw	a2,a2,a5
ffffffffc02016ee:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016f2:	57f5                	li	a5,-3
ffffffffc02016f4:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016f8:	01853803          	ld	a6,24(a0)
ffffffffc02016fc:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02016fe:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201700:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201704:	659c                	ld	a5,8(a1)
ffffffffc0201706:	01063023          	sd	a6,0(a2)
ffffffffc020170a:	a815                	j	ffffffffc020173e <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020170c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020170e:	f114                	sd	a3,32(a0)
ffffffffc0201710:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201712:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201714:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201716:	00d70563          	beq	a4,a3,ffffffffc0201720 <default_free_pages+0xf4>
ffffffffc020171a:	4805                	li	a6,1
ffffffffc020171c:	87ba                	mv	a5,a4
ffffffffc020171e:	bf59                	j	ffffffffc02016b4 <default_free_pages+0x88>
ffffffffc0201720:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201722:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201724:	00d78d63          	beq	a5,a3,ffffffffc020173e <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201728:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020172c:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201730:	02061793          	slli	a5,a2,0x20
ffffffffc0201734:	83e9                	srli	a5,a5,0x1a
ffffffffc0201736:	97ba                	add	a5,a5,a4
ffffffffc0201738:	faf509e3          	beq	a0,a5,ffffffffc02016ea <default_free_pages+0xbe>
ffffffffc020173c:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020173e:	fe878713          	addi	a4,a5,-24
ffffffffc0201742:	00d78963          	beq	a5,a3,ffffffffc0201754 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0201746:	4910                	lw	a2,16(a0)
ffffffffc0201748:	02061693          	slli	a3,a2,0x20
ffffffffc020174c:	82e9                	srli	a3,a3,0x1a
ffffffffc020174e:	96aa                	add	a3,a3,a0
ffffffffc0201750:	00d70e63          	beq	a4,a3,ffffffffc020176c <default_free_pages+0x140>
}
ffffffffc0201754:	60a2                	ld	ra,8(sp)
ffffffffc0201756:	0141                	addi	sp,sp,16
ffffffffc0201758:	8082                	ret
ffffffffc020175a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020175c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201760:	e398                	sd	a4,0(a5)
ffffffffc0201762:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201764:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201766:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201768:	0141                	addi	sp,sp,16
ffffffffc020176a:	8082                	ret
            base->property += p->property;
ffffffffc020176c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201770:	ff078693          	addi	a3,a5,-16
ffffffffc0201774:	9e39                	addw	a2,a2,a4
ffffffffc0201776:	c910                	sw	a2,16(a0)
ffffffffc0201778:	5775                	li	a4,-3
ffffffffc020177a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020177e:	6398                	ld	a4,0(a5)
ffffffffc0201780:	679c                	ld	a5,8(a5)
}
ffffffffc0201782:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201784:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201786:	e398                	sd	a4,0(a5)
ffffffffc0201788:	0141                	addi	sp,sp,16
ffffffffc020178a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020178c:	00006697          	auipc	a3,0x6
ffffffffc0201790:	c4468693          	addi	a3,a3,-956 # ffffffffc02073d0 <commands+0xbc8>
ffffffffc0201794:	00005617          	auipc	a2,0x5
ffffffffc0201798:	53460613          	addi	a2,a2,1332 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020179c:	08300593          	li	a1,131
ffffffffc02017a0:	00006517          	auipc	a0,0x6
ffffffffc02017a4:	8f050513          	addi	a0,a0,-1808 # ffffffffc0207090 <commands+0x888>
ffffffffc02017a8:	cd9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(n > 0);
ffffffffc02017ac:	00006697          	auipc	a3,0x6
ffffffffc02017b0:	c4c68693          	addi	a3,a3,-948 # ffffffffc02073f8 <commands+0xbf0>
ffffffffc02017b4:	00005617          	auipc	a2,0x5
ffffffffc02017b8:	51460613          	addi	a2,a2,1300 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02017bc:	08000593          	li	a1,128
ffffffffc02017c0:	00006517          	auipc	a0,0x6
ffffffffc02017c4:	8d050513          	addi	a0,a0,-1840 # ffffffffc0207090 <commands+0x888>
ffffffffc02017c8:	cb9fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02017cc <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017cc:	c959                	beqz	a0,ffffffffc0201862 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017ce:	000ab597          	auipc	a1,0xab
ffffffffc02017d2:	12258593          	addi	a1,a1,290 # ffffffffc02ac8f0 <free_area>
ffffffffc02017d6:	0105a803          	lw	a6,16(a1)
ffffffffc02017da:	862a                	mv	a2,a0
ffffffffc02017dc:	02081793          	slli	a5,a6,0x20
ffffffffc02017e0:	9381                	srli	a5,a5,0x20
ffffffffc02017e2:	00a7ee63          	bltu	a5,a0,ffffffffc02017fe <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017e6:	87ae                	mv	a5,a1
ffffffffc02017e8:	a801                	j	ffffffffc02017f8 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02017ea:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017ee:	02071693          	slli	a3,a4,0x20
ffffffffc02017f2:	9281                	srli	a3,a3,0x20
ffffffffc02017f4:	00c6f763          	bgeu	a3,a2,ffffffffc0201802 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02017f8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02017fa:	feb798e3          	bne	a5,a1,ffffffffc02017ea <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02017fe:	4501                	li	a0,0
}
ffffffffc0201800:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201802:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201806:	dd6d                	beqz	a0,ffffffffc0201800 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201808:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020180c:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201810:	00060e1b          	sext.w	t3,a2
ffffffffc0201814:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201818:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020181c:	02d67863          	bgeu	a2,a3,ffffffffc020184c <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201820:	061a                	slli	a2,a2,0x6
ffffffffc0201822:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201824:	41c7073b          	subw	a4,a4,t3
ffffffffc0201828:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020182a:	00860693          	addi	a3,a2,8
ffffffffc020182e:	4709                	li	a4,2
ffffffffc0201830:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201834:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201838:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc020183c:	0105a803          	lw	a6,16(a1)
ffffffffc0201840:	e314                	sd	a3,0(a4)
ffffffffc0201842:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0201846:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201848:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc020184c:	41c8083b          	subw	a6,a6,t3
ffffffffc0201850:	000ab717          	auipc	a4,0xab
ffffffffc0201854:	0b072823          	sw	a6,176(a4) # ffffffffc02ac900 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201858:	5775                	li	a4,-3
ffffffffc020185a:	17c1                	addi	a5,a5,-16
ffffffffc020185c:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201860:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201862:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201864:	00006697          	auipc	a3,0x6
ffffffffc0201868:	b9468693          	addi	a3,a3,-1132 # ffffffffc02073f8 <commands+0xbf0>
ffffffffc020186c:	00005617          	auipc	a2,0x5
ffffffffc0201870:	45c60613          	addi	a2,a2,1116 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0201874:	06200593          	li	a1,98
ffffffffc0201878:	00006517          	auipc	a0,0x6
ffffffffc020187c:	81850513          	addi	a0,a0,-2024 # ffffffffc0207090 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201880:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201882:	bfffe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201886 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201886:	1141                	addi	sp,sp,-16
ffffffffc0201888:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020188a:	c1ed                	beqz	a1,ffffffffc020196c <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc020188c:	00659693          	slli	a3,a1,0x6
ffffffffc0201890:	96aa                	add	a3,a3,a0
ffffffffc0201892:	02d50463          	beq	a0,a3,ffffffffc02018ba <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201896:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201898:	87aa                	mv	a5,a0
ffffffffc020189a:	8b05                	andi	a4,a4,1
ffffffffc020189c:	e709                	bnez	a4,ffffffffc02018a6 <default_init_memmap+0x20>
ffffffffc020189e:	a07d                	j	ffffffffc020194c <default_init_memmap+0xc6>
ffffffffc02018a0:	6798                	ld	a4,8(a5)
ffffffffc02018a2:	8b05                	andi	a4,a4,1
ffffffffc02018a4:	c745                	beqz	a4,ffffffffc020194c <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018a6:	0007a823          	sw	zero,16(a5)
ffffffffc02018aa:	0007b423          	sd	zero,8(a5)
ffffffffc02018ae:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018b2:	04078793          	addi	a5,a5,64
ffffffffc02018b6:	fed795e3          	bne	a5,a3,ffffffffc02018a0 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018ba:	2581                	sext.w	a1,a1
ffffffffc02018bc:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018be:	4789                	li	a5,2
ffffffffc02018c0:	00850713          	addi	a4,a0,8
ffffffffc02018c4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018c8:	000ab697          	auipc	a3,0xab
ffffffffc02018cc:	02868693          	addi	a3,a3,40 # ffffffffc02ac8f0 <free_area>
ffffffffc02018d0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018d2:	669c                	ld	a5,8(a3)
ffffffffc02018d4:	9db9                	addw	a1,a1,a4
ffffffffc02018d6:	000ab717          	auipc	a4,0xab
ffffffffc02018da:	02b72523          	sw	a1,42(a4) # ffffffffc02ac900 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018de:	04d78a63          	beq	a5,a3,ffffffffc0201932 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018e2:	fe878713          	addi	a4,a5,-24
ffffffffc02018e6:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018e8:	4801                	li	a6,0
ffffffffc02018ea:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02018ee:	00e56a63          	bltu	a0,a4,ffffffffc0201902 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02018f2:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02018f4:	02d70563          	beq	a4,a3,ffffffffc020191e <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02018f8:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02018fa:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02018fe:	fee57ae3          	bgeu	a0,a4,ffffffffc02018f2 <default_init_memmap+0x6c>
ffffffffc0201902:	00080663          	beqz	a6,ffffffffc020190e <default_init_memmap+0x88>
ffffffffc0201906:	000ab717          	auipc	a4,0xab
ffffffffc020190a:	feb73523          	sd	a1,-22(a4) # ffffffffc02ac8f0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020190e:	6398                	ld	a4,0(a5)
}
ffffffffc0201910:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201912:	e390                	sd	a2,0(a5)
ffffffffc0201914:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201916:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201918:	ed18                	sd	a4,24(a0)
ffffffffc020191a:	0141                	addi	sp,sp,16
ffffffffc020191c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020191e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201920:	f114                	sd	a3,32(a0)
ffffffffc0201922:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201924:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201926:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201928:	00d70e63          	beq	a4,a3,ffffffffc0201944 <default_init_memmap+0xbe>
ffffffffc020192c:	4805                	li	a6,1
ffffffffc020192e:	87ba                	mv	a5,a4
ffffffffc0201930:	b7e9                	j	ffffffffc02018fa <default_init_memmap+0x74>
}
ffffffffc0201932:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201934:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201938:	e398                	sd	a4,0(a5)
ffffffffc020193a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020193c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020193e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201940:	0141                	addi	sp,sp,16
ffffffffc0201942:	8082                	ret
ffffffffc0201944:	60a2                	ld	ra,8(sp)
ffffffffc0201946:	e290                	sd	a2,0(a3)
ffffffffc0201948:	0141                	addi	sp,sp,16
ffffffffc020194a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020194c:	00006697          	auipc	a3,0x6
ffffffffc0201950:	ab468693          	addi	a3,a3,-1356 # ffffffffc0207400 <commands+0xbf8>
ffffffffc0201954:	00005617          	auipc	a2,0x5
ffffffffc0201958:	37460613          	addi	a2,a2,884 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020195c:	04900593          	li	a1,73
ffffffffc0201960:	00005517          	auipc	a0,0x5
ffffffffc0201964:	73050513          	addi	a0,a0,1840 # ffffffffc0207090 <commands+0x888>
ffffffffc0201968:	b19fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(n > 0);
ffffffffc020196c:	00006697          	auipc	a3,0x6
ffffffffc0201970:	a8c68693          	addi	a3,a3,-1396 # ffffffffc02073f8 <commands+0xbf0>
ffffffffc0201974:	00005617          	auipc	a2,0x5
ffffffffc0201978:	35460613          	addi	a2,a2,852 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020197c:	04600593          	li	a1,70
ffffffffc0201980:	00005517          	auipc	a0,0x5
ffffffffc0201984:	71050513          	addi	a0,a0,1808 # ffffffffc0207090 <commands+0x888>
ffffffffc0201988:	af9fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020198c <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020198c:	c125                	beqz	a0,ffffffffc02019ec <slob_free+0x60>
		return;

	if (size)
ffffffffc020198e:	e1a5                	bnez	a1,ffffffffc02019ee <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201990:	100027f3          	csrr	a5,sstatus
ffffffffc0201994:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201996:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201998:	e3bd                	bnez	a5,ffffffffc02019fe <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020199a:	000a0797          	auipc	a5,0xa0
ffffffffc020199e:	ae678793          	addi	a5,a5,-1306 # ffffffffc02a1480 <slobfree>
ffffffffc02019a2:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019a4:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019a6:	00a7fa63          	bgeu	a5,a0,ffffffffc02019ba <slob_free+0x2e>
ffffffffc02019aa:	00e56c63          	bltu	a0,a4,ffffffffc02019c2 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ae:	00e7fa63          	bgeu	a5,a4,ffffffffc02019c2 <slob_free+0x36>
    return 0;
ffffffffc02019b2:	87ba                	mv	a5,a4
ffffffffc02019b4:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019b6:	fea7eae3          	bltu	a5,a0,ffffffffc02019aa <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ba:	fee7ece3          	bltu	a5,a4,ffffffffc02019b2 <slob_free+0x26>
ffffffffc02019be:	fee57ae3          	bgeu	a0,a4,ffffffffc02019b2 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019c2:	4110                	lw	a2,0(a0)
ffffffffc02019c4:	00461693          	slli	a3,a2,0x4
ffffffffc02019c8:	96aa                	add	a3,a3,a0
ffffffffc02019ca:	08d70b63          	beq	a4,a3,ffffffffc0201a60 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019ce:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019d0:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019d2:	00469713          	slli	a4,a3,0x4
ffffffffc02019d6:	973e                	add	a4,a4,a5
ffffffffc02019d8:	08e50f63          	beq	a0,a4,ffffffffc0201a76 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019dc:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019de:	000a0717          	auipc	a4,0xa0
ffffffffc02019e2:	aaf73123          	sd	a5,-1374(a4) # ffffffffc02a1480 <slobfree>
    if (flag) {
ffffffffc02019e6:	c199                	beqz	a1,ffffffffc02019ec <slob_free+0x60>
        intr_enable();
ffffffffc02019e8:	c65fe06f          	j	ffffffffc020064c <intr_enable>
ffffffffc02019ec:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02019ee:	05bd                	addi	a1,a1,15
ffffffffc02019f0:	8191                	srli	a1,a1,0x4
ffffffffc02019f2:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019f4:	100027f3          	csrr	a5,sstatus
ffffffffc02019f8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019fa:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019fc:	dfd9                	beqz	a5,ffffffffc020199a <slob_free+0xe>
{
ffffffffc02019fe:	1101                	addi	sp,sp,-32
ffffffffc0201a00:	e42a                	sd	a0,8(sp)
ffffffffc0201a02:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a04:	c4ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a08:	000a0797          	auipc	a5,0xa0
ffffffffc0201a0c:	a7878793          	addi	a5,a5,-1416 # ffffffffc02a1480 <slobfree>
ffffffffc0201a10:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a12:	6522                	ld	a0,8(sp)
ffffffffc0201a14:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a16:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a18:	00a7fa63          	bgeu	a5,a0,ffffffffc0201a2c <slob_free+0xa0>
ffffffffc0201a1c:	00e56c63          	bltu	a0,a4,ffffffffc0201a34 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a20:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a34 <slob_free+0xa8>
    return 0;
ffffffffc0201a24:	87ba                	mv	a5,a4
ffffffffc0201a26:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a28:	fea7eae3          	bltu	a5,a0,ffffffffc0201a1c <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a2c:	fee7ece3          	bltu	a5,a4,ffffffffc0201a24 <slob_free+0x98>
ffffffffc0201a30:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a24 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a34:	4110                	lw	a2,0(a0)
ffffffffc0201a36:	00461693          	slli	a3,a2,0x4
ffffffffc0201a3a:	96aa                	add	a3,a3,a0
ffffffffc0201a3c:	04d70763          	beq	a4,a3,ffffffffc0201a8a <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a40:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a42:	4394                	lw	a3,0(a5)
ffffffffc0201a44:	00469713          	slli	a4,a3,0x4
ffffffffc0201a48:	973e                	add	a4,a4,a5
ffffffffc0201a4a:	04e50663          	beq	a0,a4,ffffffffc0201a96 <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a4e:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a50:	000a0717          	auipc	a4,0xa0
ffffffffc0201a54:	a2f73823          	sd	a5,-1488(a4) # ffffffffc02a1480 <slobfree>
    if (flag) {
ffffffffc0201a58:	e58d                	bnez	a1,ffffffffc0201a82 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a5a:	60e2                	ld	ra,24(sp)
ffffffffc0201a5c:	6105                	addi	sp,sp,32
ffffffffc0201a5e:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a60:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a62:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a64:	9e35                	addw	a2,a2,a3
ffffffffc0201a66:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a68:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a6a:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a6c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a70:	973e                	add	a4,a4,a5
ffffffffc0201a72:	f6e515e3          	bne	a0,a4,ffffffffc02019dc <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a76:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a78:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a7a:	9eb9                	addw	a3,a3,a4
ffffffffc0201a7c:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a7e:	e790                	sd	a2,8(a5)
ffffffffc0201a80:	bfb9                	j	ffffffffc02019de <slob_free+0x52>
}
ffffffffc0201a82:	60e2                	ld	ra,24(sp)
ffffffffc0201a84:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a86:	bc7fe06f          	j	ffffffffc020064c <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a8a:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a8c:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a8e:	9e35                	addw	a2,a2,a3
ffffffffc0201a90:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201a92:	e518                	sd	a4,8(a0)
ffffffffc0201a94:	b77d                	j	ffffffffc0201a42 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201a96:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a98:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a9a:	9eb9                	addw	a3,a3,a4
ffffffffc0201a9c:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a9e:	e790                	sd	a2,8(a5)
ffffffffc0201aa0:	bf45                	j	ffffffffc0201a50 <slob_free+0xc4>

ffffffffc0201aa2 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aa2:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201aa4:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aa6:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201aaa:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aac:	378000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
  if(!page)
ffffffffc0201ab0:	cd1d                	beqz	a0,ffffffffc0201aee <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc0201ab2:	000ab797          	auipc	a5,0xab
ffffffffc0201ab6:	e6e78793          	addi	a5,a5,-402 # ffffffffc02ac920 <pages>
ffffffffc0201aba:	6394                	ld	a3,0(a5)
ffffffffc0201abc:	00007797          	auipc	a5,0x7
ffffffffc0201ac0:	2ec78793          	addi	a5,a5,748 # ffffffffc0208da8 <nbase>
ffffffffc0201ac4:	8d15                	sub	a0,a0,a3
ffffffffc0201ac6:	6394                	ld	a3,0(a5)
ffffffffc0201ac8:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0201aca:	000ab797          	auipc	a5,0xab
ffffffffc0201ace:	de678793          	addi	a5,a5,-538 # ffffffffc02ac8b0 <npage>
    return page - pages + nbase;
ffffffffc0201ad2:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201ad4:	6398                	ld	a4,0(a5)
ffffffffc0201ad6:	00c51793          	slli	a5,a0,0xc
ffffffffc0201ada:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201adc:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201ade:	00e7fb63          	bgeu	a5,a4,ffffffffc0201af4 <__slob_get_free_pages.isra.0+0x52>
ffffffffc0201ae2:	000ab797          	auipc	a5,0xab
ffffffffc0201ae6:	e2e78793          	addi	a5,a5,-466 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0201aea:	6394                	ld	a3,0(a5)
ffffffffc0201aec:	9536                	add	a0,a0,a3
}
ffffffffc0201aee:	60a2                	ld	ra,8(sp)
ffffffffc0201af0:	0141                	addi	sp,sp,16
ffffffffc0201af2:	8082                	ret
ffffffffc0201af4:	86aa                	mv	a3,a0
ffffffffc0201af6:	00006617          	auipc	a2,0x6
ffffffffc0201afa:	96a60613          	addi	a2,a2,-1686 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0201afe:	06900593          	li	a1,105
ffffffffc0201b02:	00006517          	auipc	a0,0x6
ffffffffc0201b06:	98650513          	addi	a0,a0,-1658 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0201b0a:	977fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b0e:	1101                	addi	sp,sp,-32
ffffffffc0201b10:	ec06                	sd	ra,24(sp)
ffffffffc0201b12:	e822                	sd	s0,16(sp)
ffffffffc0201b14:	e426                	sd	s1,8(sp)
ffffffffc0201b16:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b18:	01050713          	addi	a4,a0,16
ffffffffc0201b1c:	6785                	lui	a5,0x1
ffffffffc0201b1e:	0cf77563          	bgeu	a4,a5,ffffffffc0201be8 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b22:	00f50493          	addi	s1,a0,15
ffffffffc0201b26:	8091                	srli	s1,s1,0x4
ffffffffc0201b28:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b2a:	10002673          	csrr	a2,sstatus
ffffffffc0201b2e:	8a09                	andi	a2,a2,2
ffffffffc0201b30:	e64d                	bnez	a2,ffffffffc0201bda <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0201b32:	000a0917          	auipc	s2,0xa0
ffffffffc0201b36:	94e90913          	addi	s2,s2,-1714 # ffffffffc02a1480 <slobfree>
ffffffffc0201b3a:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b3e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b40:	4398                	lw	a4,0(a5)
ffffffffc0201b42:	0a975063          	bge	a4,s1,ffffffffc0201be2 <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0201b46:	00d78b63          	beq	a5,a3,ffffffffc0201b5c <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b4a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b4c:	4018                	lw	a4,0(s0)
ffffffffc0201b4e:	02975a63          	bge	a4,s1,ffffffffc0201b82 <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0201b52:	00093683          	ld	a3,0(s2)
ffffffffc0201b56:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0201b58:	fed799e3          	bne	a5,a3,ffffffffc0201b4a <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0201b5c:	e225                	bnez	a2,ffffffffc0201bbc <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b5e:	4501                	li	a0,0
ffffffffc0201b60:	f43ff0ef          	jal	ra,ffffffffc0201aa2 <__slob_get_free_pages.isra.0>
ffffffffc0201b64:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201b66:	cd15                	beqz	a0,ffffffffc0201ba2 <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b68:	6585                	lui	a1,0x1
ffffffffc0201b6a:	e23ff0ef          	jal	ra,ffffffffc020198c <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b6e:	10002673          	csrr	a2,sstatus
ffffffffc0201b72:	8a09                	andi	a2,a2,2
ffffffffc0201b74:	ee15                	bnez	a2,ffffffffc0201bb0 <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0201b76:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b7a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b7c:	4018                	lw	a4,0(s0)
ffffffffc0201b7e:	fc974ae3          	blt	a4,s1,ffffffffc0201b52 <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b82:	04e48963          	beq	s1,a4,ffffffffc0201bd4 <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0201b86:	00449693          	slli	a3,s1,0x4
ffffffffc0201b8a:	96a2                	add	a3,a3,s0
ffffffffc0201b8c:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b8e:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201b90:	9f05                	subw	a4,a4,s1
ffffffffc0201b92:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b94:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b96:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201b98:	000a0717          	auipc	a4,0xa0
ffffffffc0201b9c:	8ef73423          	sd	a5,-1816(a4) # ffffffffc02a1480 <slobfree>
    if (flag) {
ffffffffc0201ba0:	e20d                	bnez	a2,ffffffffc0201bc2 <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc0201ba2:	8522                	mv	a0,s0
ffffffffc0201ba4:	60e2                	ld	ra,24(sp)
ffffffffc0201ba6:	6442                	ld	s0,16(sp)
ffffffffc0201ba8:	64a2                	ld	s1,8(sp)
ffffffffc0201baa:	6902                	ld	s2,0(sp)
ffffffffc0201bac:	6105                	addi	sp,sp,32
ffffffffc0201bae:	8082                	ret
        intr_disable();
ffffffffc0201bb0:	aa3fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bb4:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bb6:	00093783          	ld	a5,0(s2)
ffffffffc0201bba:	b7c1                	j	ffffffffc0201b7a <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0201bbc:	a91fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201bc0:	bf79                	j	ffffffffc0201b5e <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc0201bc2:	a8bfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0201bc6:	8522                	mv	a0,s0
ffffffffc0201bc8:	60e2                	ld	ra,24(sp)
ffffffffc0201bca:	6442                	ld	s0,16(sp)
ffffffffc0201bcc:	64a2                	ld	s1,8(sp)
ffffffffc0201bce:	6902                	ld	s2,0(sp)
ffffffffc0201bd0:	6105                	addi	sp,sp,32
ffffffffc0201bd2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bd4:	6418                	ld	a4,8(s0)
ffffffffc0201bd6:	e798                	sd	a4,8(a5)
ffffffffc0201bd8:	b7c1                	j	ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0201bda:	a79fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bde:	4605                	li	a2,1
ffffffffc0201be0:	bf89                	j	ffffffffc0201b32 <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201be2:	843e                	mv	s0,a5
ffffffffc0201be4:	87b6                	mv	a5,a3
ffffffffc0201be6:	bf71                	j	ffffffffc0201b82 <slob_alloc.isra.1.constprop.3+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201be8:	00006697          	auipc	a3,0x6
ffffffffc0201bec:	91868693          	addi	a3,a3,-1768 # ffffffffc0207500 <default_pmm_manager+0xf0>
ffffffffc0201bf0:	00005617          	auipc	a2,0x5
ffffffffc0201bf4:	0d860613          	addi	a2,a2,216 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0201bf8:	06400593          	li	a1,100
ffffffffc0201bfc:	00006517          	auipc	a0,0x6
ffffffffc0201c00:	92450513          	addi	a0,a0,-1756 # ffffffffc0207520 <default_pmm_manager+0x110>
ffffffffc0201c04:	87dfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201c08 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c08:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c0a:	00006517          	auipc	a0,0x6
ffffffffc0201c0e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0207538 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c12:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c14:	d7afe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c18:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c1a:	00006517          	auipc	a0,0x6
ffffffffc0201c1e:	8c650513          	addi	a0,a0,-1850 # ffffffffc02074e0 <default_pmm_manager+0xd0>
}
ffffffffc0201c22:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c24:	d6afe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c28 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c28:	4501                	li	a0,0
ffffffffc0201c2a:	8082                	ret

ffffffffc0201c2c <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c2c:	1101                	addi	sp,sp,-32
ffffffffc0201c2e:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c30:	6905                	lui	s2,0x1
{
ffffffffc0201c32:	e822                	sd	s0,16(sp)
ffffffffc0201c34:	ec06                	sd	ra,24(sp)
ffffffffc0201c36:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c38:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85e1>
{
ffffffffc0201c3c:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c3e:	04a7fc63          	bgeu	a5,a0,ffffffffc0201c96 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c42:	4561                	li	a0,24
ffffffffc0201c44:	ecbff0ef          	jal	ra,ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c48:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c4a:	cd21                	beqz	a0,ffffffffc0201ca2 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c4c:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c50:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c52:	00f95763          	bge	s2,a5,ffffffffc0201c60 <kmalloc+0x34>
ffffffffc0201c56:	6705                	lui	a4,0x1
ffffffffc0201c58:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c5a:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c5c:	fef74ee3          	blt	a4,a5,ffffffffc0201c58 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c60:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c62:	e41ff0ef          	jal	ra,ffffffffc0201aa2 <__slob_get_free_pages.isra.0>
ffffffffc0201c66:	e488                	sd	a0,8(s1)
ffffffffc0201c68:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c6a:	c935                	beqz	a0,ffffffffc0201cde <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c6c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c70:	8b89                	andi	a5,a5,2
ffffffffc0201c72:	e3a1                	bnez	a5,ffffffffc0201cb2 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c74:	000ab797          	auipc	a5,0xab
ffffffffc0201c78:	c2c78793          	addi	a5,a5,-980 # ffffffffc02ac8a0 <bigblocks>
ffffffffc0201c7c:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c7e:	000ab717          	auipc	a4,0xab
ffffffffc0201c82:	c2973123          	sd	s1,-990(a4) # ffffffffc02ac8a0 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201c86:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201c88:	8522                	mv	a0,s0
ffffffffc0201c8a:	60e2                	ld	ra,24(sp)
ffffffffc0201c8c:	6442                	ld	s0,16(sp)
ffffffffc0201c8e:	64a2                	ld	s1,8(sp)
ffffffffc0201c90:	6902                	ld	s2,0(sp)
ffffffffc0201c92:	6105                	addi	sp,sp,32
ffffffffc0201c94:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c96:	0541                	addi	a0,a0,16
ffffffffc0201c98:	e77ff0ef          	jal	ra,ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201c9c:	01050413          	addi	s0,a0,16
ffffffffc0201ca0:	f565                	bnez	a0,ffffffffc0201c88 <kmalloc+0x5c>
ffffffffc0201ca2:	4401                	li	s0,0
}
ffffffffc0201ca4:	8522                	mv	a0,s0
ffffffffc0201ca6:	60e2                	ld	ra,24(sp)
ffffffffc0201ca8:	6442                	ld	s0,16(sp)
ffffffffc0201caa:	64a2                	ld	s1,8(sp)
ffffffffc0201cac:	6902                	ld	s2,0(sp)
ffffffffc0201cae:	6105                	addi	sp,sp,32
ffffffffc0201cb0:	8082                	ret
        intr_disable();
ffffffffc0201cb2:	9a1fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cb6:	000ab797          	auipc	a5,0xab
ffffffffc0201cba:	bea78793          	addi	a5,a5,-1046 # ffffffffc02ac8a0 <bigblocks>
ffffffffc0201cbe:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cc0:	000ab717          	auipc	a4,0xab
ffffffffc0201cc4:	be973023          	sd	s1,-1056(a4) # ffffffffc02ac8a0 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cc8:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201cca:	983fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201cce:	6480                	ld	s0,8(s1)
}
ffffffffc0201cd0:	60e2                	ld	ra,24(sp)
ffffffffc0201cd2:	64a2                	ld	s1,8(sp)
ffffffffc0201cd4:	8522                	mv	a0,s0
ffffffffc0201cd6:	6442                	ld	s0,16(sp)
ffffffffc0201cd8:	6902                	ld	s2,0(sp)
ffffffffc0201cda:	6105                	addi	sp,sp,32
ffffffffc0201cdc:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cde:	45e1                	li	a1,24
ffffffffc0201ce0:	8526                	mv	a0,s1
ffffffffc0201ce2:	cabff0ef          	jal	ra,ffffffffc020198c <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201ce6:	b74d                	j	ffffffffc0201c88 <kmalloc+0x5c>

ffffffffc0201ce8 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201ce8:	c165                	beqz	a0,ffffffffc0201dc8 <kfree+0xe0>
{
ffffffffc0201cea:	1101                	addi	sp,sp,-32
ffffffffc0201cec:	e426                	sd	s1,8(sp)
ffffffffc0201cee:	ec06                	sd	ra,24(sp)
ffffffffc0201cf0:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201cf2:	03451793          	slli	a5,a0,0x34
ffffffffc0201cf6:	84aa                	mv	s1,a0
ffffffffc0201cf8:	eb8d                	bnez	a5,ffffffffc0201d2a <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cfa:	100027f3          	csrr	a5,sstatus
ffffffffc0201cfe:	8b89                	andi	a5,a5,2
ffffffffc0201d00:	ebd9                	bnez	a5,ffffffffc0201d96 <kfree+0xae>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d02:	000ab797          	auipc	a5,0xab
ffffffffc0201d06:	b9e78793          	addi	a5,a5,-1122 # ffffffffc02ac8a0 <bigblocks>
ffffffffc0201d0a:	6394                	ld	a3,0(a5)
ffffffffc0201d0c:	ce99                	beqz	a3,ffffffffc0201d2a <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d0e:	669c                	ld	a5,8(a3)
ffffffffc0201d10:	6a80                	ld	s0,16(a3)
ffffffffc0201d12:	0af50c63          	beq	a0,a5,ffffffffc0201dca <kfree+0xe2>
    return 0;
ffffffffc0201d16:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d18:	c801                	beqz	s0,ffffffffc0201d28 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d1a:	6418                	ld	a4,8(s0)
ffffffffc0201d1c:	681c                	ld	a5,16(s0)
ffffffffc0201d1e:	00970e63          	beq	a4,s1,ffffffffc0201d3a <kfree+0x52>
ffffffffc0201d22:	86a2                	mv	a3,s0
ffffffffc0201d24:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d26:	f875                	bnez	s0,ffffffffc0201d1a <kfree+0x32>
    if (flag) {
ffffffffc0201d28:	e649                	bnez	a2,ffffffffc0201db2 <kfree+0xca>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d2a:	6442                	ld	s0,16(sp)
ffffffffc0201d2c:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d2e:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d32:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d34:	4581                	li	a1,0
}
ffffffffc0201d36:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d38:	b991                	j	ffffffffc020198c <slob_free>
				*last = bb->next;
ffffffffc0201d3a:	ea9c                	sd	a5,16(a3)
ffffffffc0201d3c:	e259                	bnez	a2,ffffffffc0201dc2 <kfree+0xda>
    return pa2page(PADDR(kva));
ffffffffc0201d3e:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d42:	4018                	lw	a4,0(s0)
ffffffffc0201d44:	08f4e963          	bltu	s1,a5,ffffffffc0201dd6 <kfree+0xee>
ffffffffc0201d48:	000ab797          	auipc	a5,0xab
ffffffffc0201d4c:	bc878793          	addi	a5,a5,-1080 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0201d50:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d52:	000ab797          	auipc	a5,0xab
ffffffffc0201d56:	b5e78793          	addi	a5,a5,-1186 # ffffffffc02ac8b0 <npage>
ffffffffc0201d5a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d5c:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d5e:	80b1                	srli	s1,s1,0xc
ffffffffc0201d60:	08f4f863          	bgeu	s1,a5,ffffffffc0201df0 <kfree+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d64:	00007797          	auipc	a5,0x7
ffffffffc0201d68:	04478793          	addi	a5,a5,68 # ffffffffc0208da8 <nbase>
ffffffffc0201d6c:	639c                	ld	a5,0(a5)
ffffffffc0201d6e:	000ab697          	auipc	a3,0xab
ffffffffc0201d72:	bb268693          	addi	a3,a3,-1102 # ffffffffc02ac920 <pages>
ffffffffc0201d76:	6288                	ld	a0,0(a3)
ffffffffc0201d78:	8c9d                	sub	s1,s1,a5
ffffffffc0201d7a:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201d7c:	4585                	li	a1,1
ffffffffc0201d7e:	9526                	add	a0,a0,s1
ffffffffc0201d80:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201d84:	128000ef          	jal	ra,ffffffffc0201eac <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d88:	8522                	mv	a0,s0
}
ffffffffc0201d8a:	6442                	ld	s0,16(sp)
ffffffffc0201d8c:	60e2                	ld	ra,24(sp)
ffffffffc0201d8e:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d90:	45e1                	li	a1,24
}
ffffffffc0201d92:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d94:	bee5                	j	ffffffffc020198c <slob_free>
        intr_disable();
ffffffffc0201d96:	8bdfe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d9a:	000ab797          	auipc	a5,0xab
ffffffffc0201d9e:	b0678793          	addi	a5,a5,-1274 # ffffffffc02ac8a0 <bigblocks>
ffffffffc0201da2:	6394                	ld	a3,0(a5)
ffffffffc0201da4:	c699                	beqz	a3,ffffffffc0201db2 <kfree+0xca>
			if (bb->pages == block) {
ffffffffc0201da6:	669c                	ld	a5,8(a3)
ffffffffc0201da8:	6a80                	ld	s0,16(a3)
ffffffffc0201daa:	00f48763          	beq	s1,a5,ffffffffc0201db8 <kfree+0xd0>
        return 1;
ffffffffc0201dae:	4605                	li	a2,1
ffffffffc0201db0:	b7a5                	j	ffffffffc0201d18 <kfree+0x30>
        intr_enable();
ffffffffc0201db2:	89bfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201db6:	bf95                	j	ffffffffc0201d2a <kfree+0x42>
				*last = bb->next;
ffffffffc0201db8:	000ab797          	auipc	a5,0xab
ffffffffc0201dbc:	ae87b423          	sd	s0,-1304(a5) # ffffffffc02ac8a0 <bigblocks>
ffffffffc0201dc0:	8436                	mv	s0,a3
ffffffffc0201dc2:	88bfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201dc6:	bfa5                	j	ffffffffc0201d3e <kfree+0x56>
ffffffffc0201dc8:	8082                	ret
ffffffffc0201dca:	000ab797          	auipc	a5,0xab
ffffffffc0201dce:	ac87bb23          	sd	s0,-1322(a5) # ffffffffc02ac8a0 <bigblocks>
ffffffffc0201dd2:	8436                	mv	s0,a3
ffffffffc0201dd4:	b7ad                	j	ffffffffc0201d3e <kfree+0x56>
    return pa2page(PADDR(kva));
ffffffffc0201dd6:	86a6                	mv	a3,s1
ffffffffc0201dd8:	00005617          	auipc	a2,0x5
ffffffffc0201ddc:	6c060613          	addi	a2,a2,1728 # ffffffffc0207498 <default_pmm_manager+0x88>
ffffffffc0201de0:	06e00593          	li	a1,110
ffffffffc0201de4:	00005517          	auipc	a0,0x5
ffffffffc0201de8:	6a450513          	addi	a0,a0,1700 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0201dec:	e94fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201df0:	00005617          	auipc	a2,0x5
ffffffffc0201df4:	6d060613          	addi	a2,a2,1744 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc0201df8:	06200593          	li	a1,98
ffffffffc0201dfc:	00005517          	auipc	a0,0x5
ffffffffc0201e00:	68c50513          	addi	a0,a0,1676 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0201e04:	e7cfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201e08 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e08:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e0a:	00005617          	auipc	a2,0x5
ffffffffc0201e0e:	6b660613          	addi	a2,a2,1718 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc0201e12:	06200593          	li	a1,98
ffffffffc0201e16:	00005517          	auipc	a0,0x5
ffffffffc0201e1a:	67250513          	addi	a0,a0,1650 # ffffffffc0207488 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e1e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e20:	e60fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201e24 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e24:	715d                	addi	sp,sp,-80
ffffffffc0201e26:	e0a2                	sd	s0,64(sp)
ffffffffc0201e28:	fc26                	sd	s1,56(sp)
ffffffffc0201e2a:	f84a                	sd	s2,48(sp)
ffffffffc0201e2c:	f44e                	sd	s3,40(sp)
ffffffffc0201e2e:	f052                	sd	s4,32(sp)
ffffffffc0201e30:	ec56                	sd	s5,24(sp)
ffffffffc0201e32:	e486                	sd	ra,72(sp)
ffffffffc0201e34:	842a                	mv	s0,a0
ffffffffc0201e36:	000ab497          	auipc	s1,0xab
ffffffffc0201e3a:	ad248493          	addi	s1,s1,-1326 # ffffffffc02ac908 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e3e:	4985                	li	s3,1
ffffffffc0201e40:	000aba17          	auipc	s4,0xab
ffffffffc0201e44:	a80a0a13          	addi	s4,s4,-1408 # ffffffffc02ac8c0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e48:	0005091b          	sext.w	s2,a0
ffffffffc0201e4c:	000aba97          	auipc	s5,0xab
ffffffffc0201e50:	bb4a8a93          	addi	s5,s5,-1100 # ffffffffc02aca00 <check_mm_struct>
ffffffffc0201e54:	a00d                	j	ffffffffc0201e76 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e56:	609c                	ld	a5,0(s1)
ffffffffc0201e58:	6f9c                	ld	a5,24(a5)
ffffffffc0201e5a:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e5c:	4601                	li	a2,0
ffffffffc0201e5e:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e60:	ed0d                	bnez	a0,ffffffffc0201e9a <alloc_pages+0x76>
ffffffffc0201e62:	0289ec63          	bltu	s3,s0,ffffffffc0201e9a <alloc_pages+0x76>
ffffffffc0201e66:	000a2783          	lw	a5,0(s4)
ffffffffc0201e6a:	2781                	sext.w	a5,a5
ffffffffc0201e6c:	c79d                	beqz	a5,ffffffffc0201e9a <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e6e:	000ab503          	ld	a0,0(s5)
ffffffffc0201e72:	4dd010ef          	jal	ra,ffffffffc0203b4e <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e76:	100027f3          	csrr	a5,sstatus
ffffffffc0201e7a:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e7c:	8522                	mv	a0,s0
ffffffffc0201e7e:	dfe1                	beqz	a5,ffffffffc0201e56 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201e80:	fd2fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201e84:	609c                	ld	a5,0(s1)
ffffffffc0201e86:	8522                	mv	a0,s0
ffffffffc0201e88:	6f9c                	ld	a5,24(a5)
ffffffffc0201e8a:	9782                	jalr	a5
ffffffffc0201e8c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e8e:	fbefe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201e92:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e94:	4601                	li	a2,0
ffffffffc0201e96:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e98:	d569                	beqz	a0,ffffffffc0201e62 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201e9a:	60a6                	ld	ra,72(sp)
ffffffffc0201e9c:	6406                	ld	s0,64(sp)
ffffffffc0201e9e:	74e2                	ld	s1,56(sp)
ffffffffc0201ea0:	7942                	ld	s2,48(sp)
ffffffffc0201ea2:	79a2                	ld	s3,40(sp)
ffffffffc0201ea4:	7a02                	ld	s4,32(sp)
ffffffffc0201ea6:	6ae2                	ld	s5,24(sp)
ffffffffc0201ea8:	6161                	addi	sp,sp,80
ffffffffc0201eaa:	8082                	ret

ffffffffc0201eac <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eac:	100027f3          	csrr	a5,sstatus
ffffffffc0201eb0:	8b89                	andi	a5,a5,2
ffffffffc0201eb2:	eb89                	bnez	a5,ffffffffc0201ec4 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201eb4:	000ab797          	auipc	a5,0xab
ffffffffc0201eb8:	a5478793          	addi	a5,a5,-1452 # ffffffffc02ac908 <pmm_manager>
ffffffffc0201ebc:	639c                	ld	a5,0(a5)
ffffffffc0201ebe:	0207b303          	ld	t1,32(a5)
ffffffffc0201ec2:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ec4:	1101                	addi	sp,sp,-32
ffffffffc0201ec6:	ec06                	sd	ra,24(sp)
ffffffffc0201ec8:	e822                	sd	s0,16(sp)
ffffffffc0201eca:	e426                	sd	s1,8(sp)
ffffffffc0201ecc:	842a                	mv	s0,a0
ffffffffc0201ece:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201ed0:	f82fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ed4:	000ab797          	auipc	a5,0xab
ffffffffc0201ed8:	a3478793          	addi	a5,a5,-1484 # ffffffffc02ac908 <pmm_manager>
ffffffffc0201edc:	639c                	ld	a5,0(a5)
ffffffffc0201ede:	85a6                	mv	a1,s1
ffffffffc0201ee0:	8522                	mv	a0,s0
ffffffffc0201ee2:	739c                	ld	a5,32(a5)
ffffffffc0201ee4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201ee6:	6442                	ld	s0,16(sp)
ffffffffc0201ee8:	60e2                	ld	ra,24(sp)
ffffffffc0201eea:	64a2                	ld	s1,8(sp)
ffffffffc0201eec:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201eee:	f5efe06f          	j	ffffffffc020064c <intr_enable>

ffffffffc0201ef2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ef2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ef6:	8b89                	andi	a5,a5,2
ffffffffc0201ef8:	eb89                	bnez	a5,ffffffffc0201f0a <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201efa:	000ab797          	auipc	a5,0xab
ffffffffc0201efe:	a0e78793          	addi	a5,a5,-1522 # ffffffffc02ac908 <pmm_manager>
ffffffffc0201f02:	639c                	ld	a5,0(a5)
ffffffffc0201f04:	0287b303          	ld	t1,40(a5)
ffffffffc0201f08:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f0a:	1141                	addi	sp,sp,-16
ffffffffc0201f0c:	e406                	sd	ra,8(sp)
ffffffffc0201f0e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f10:	f42fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f14:	000ab797          	auipc	a5,0xab
ffffffffc0201f18:	9f478793          	addi	a5,a5,-1548 # ffffffffc02ac908 <pmm_manager>
ffffffffc0201f1c:	639c                	ld	a5,0(a5)
ffffffffc0201f1e:	779c                	ld	a5,40(a5)
ffffffffc0201f20:	9782                	jalr	a5
ffffffffc0201f22:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f24:	f28fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f28:	8522                	mv	a0,s0
ffffffffc0201f2a:	60a2                	ld	ra,8(sp)
ffffffffc0201f2c:	6402                	ld	s0,0(sp)
ffffffffc0201f2e:	0141                	addi	sp,sp,16
ffffffffc0201f30:	8082                	ret

ffffffffc0201f32 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f32:	7139                	addi	sp,sp,-64
ffffffffc0201f34:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f36:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f3a:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f3e:	048e                	slli	s1,s1,0x3
ffffffffc0201f40:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f42:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f44:	f04a                	sd	s2,32(sp)
ffffffffc0201f46:	ec4e                	sd	s3,24(sp)
ffffffffc0201f48:	e852                	sd	s4,16(sp)
ffffffffc0201f4a:	fc06                	sd	ra,56(sp)
ffffffffc0201f4c:	f822                	sd	s0,48(sp)
ffffffffc0201f4e:	e456                	sd	s5,8(sp)
ffffffffc0201f50:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f52:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f56:	892e                	mv	s2,a1
ffffffffc0201f58:	8a32                	mv	s4,a2
ffffffffc0201f5a:	000ab997          	auipc	s3,0xab
ffffffffc0201f5e:	95698993          	addi	s3,s3,-1706 # ffffffffc02ac8b0 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f62:	e7bd                	bnez	a5,ffffffffc0201fd0 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f64:	12060c63          	beqz	a2,ffffffffc020209c <get_pte+0x16a>
ffffffffc0201f68:	4505                	li	a0,1
ffffffffc0201f6a:	ebbff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201f6e:	842a                	mv	s0,a0
ffffffffc0201f70:	12050663          	beqz	a0,ffffffffc020209c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201f74:	000abb17          	auipc	s6,0xab
ffffffffc0201f78:	9acb0b13          	addi	s6,s6,-1620 # ffffffffc02ac920 <pages>
ffffffffc0201f7c:	000b3503          	ld	a0,0(s6)
ffffffffc0201f80:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f84:	000ab997          	auipc	s3,0xab
ffffffffc0201f88:	92c98993          	addi	s3,s3,-1748 # ffffffffc02ac8b0 <npage>
ffffffffc0201f8c:	40a40533          	sub	a0,s0,a0
ffffffffc0201f90:	8519                	srai	a0,a0,0x6
ffffffffc0201f92:	9556                	add	a0,a0,s5
ffffffffc0201f94:	0009b703          	ld	a4,0(s3)
ffffffffc0201f98:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201f9c:	4685                	li	a3,1
ffffffffc0201f9e:	c014                	sw	a3,0(s0)
ffffffffc0201fa0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fa2:	0532                	slli	a0,a0,0xc
ffffffffc0201fa4:	14e7f363          	bgeu	a5,a4,ffffffffc02020ea <get_pte+0x1b8>
ffffffffc0201fa8:	000ab797          	auipc	a5,0xab
ffffffffc0201fac:	96878793          	addi	a5,a5,-1688 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0201fb0:	639c                	ld	a5,0(a5)
ffffffffc0201fb2:	6605                	lui	a2,0x1
ffffffffc0201fb4:	4581                	li	a1,0
ffffffffc0201fb6:	953e                	add	a0,a0,a5
ffffffffc0201fb8:	6f6040ef          	jal	ra,ffffffffc02066ae <memset>
    return page - pages + nbase;
ffffffffc0201fbc:	000b3683          	ld	a3,0(s6)
ffffffffc0201fc0:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fc4:	8699                	srai	a3,a3,0x6
ffffffffc0201fc6:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fc8:	06aa                	slli	a3,a3,0xa
ffffffffc0201fca:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fce:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fd0:	77fd                	lui	a5,0xfffff
ffffffffc0201fd2:	068a                	slli	a3,a3,0x2
ffffffffc0201fd4:	0009b703          	ld	a4,0(s3)
ffffffffc0201fd8:	8efd                	and	a3,a3,a5
ffffffffc0201fda:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201fde:	0ce7f163          	bgeu	a5,a4,ffffffffc02020a0 <get_pte+0x16e>
ffffffffc0201fe2:	000aba97          	auipc	s5,0xab
ffffffffc0201fe6:	92ea8a93          	addi	s5,s5,-1746 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0201fea:	000ab403          	ld	s0,0(s5)
ffffffffc0201fee:	01595793          	srli	a5,s2,0x15
ffffffffc0201ff2:	1ff7f793          	andi	a5,a5,511
ffffffffc0201ff6:	96a2                	add	a3,a3,s0
ffffffffc0201ff8:	00379413          	slli	s0,a5,0x3
ffffffffc0201ffc:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201ffe:	6014                	ld	a3,0(s0)
ffffffffc0202000:	0016f793          	andi	a5,a3,1
ffffffffc0202004:	e3ad                	bnez	a5,ffffffffc0202066 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202006:	080a0b63          	beqz	s4,ffffffffc020209c <get_pte+0x16a>
ffffffffc020200a:	4505                	li	a0,1
ffffffffc020200c:	e19ff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0202010:	84aa                	mv	s1,a0
ffffffffc0202012:	c549                	beqz	a0,ffffffffc020209c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202014:	000abb17          	auipc	s6,0xab
ffffffffc0202018:	90cb0b13          	addi	s6,s6,-1780 # ffffffffc02ac920 <pages>
ffffffffc020201c:	000b3503          	ld	a0,0(s6)
ffffffffc0202020:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202024:	0009b703          	ld	a4,0(s3)
ffffffffc0202028:	40a48533          	sub	a0,s1,a0
ffffffffc020202c:	8519                	srai	a0,a0,0x6
ffffffffc020202e:	9552                	add	a0,a0,s4
ffffffffc0202030:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202034:	4685                	li	a3,1
ffffffffc0202036:	c094                	sw	a3,0(s1)
ffffffffc0202038:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020203a:	0532                	slli	a0,a0,0xc
ffffffffc020203c:	08e7fa63          	bgeu	a5,a4,ffffffffc02020d0 <get_pte+0x19e>
ffffffffc0202040:	000ab783          	ld	a5,0(s5)
ffffffffc0202044:	6605                	lui	a2,0x1
ffffffffc0202046:	4581                	li	a1,0
ffffffffc0202048:	953e                	add	a0,a0,a5
ffffffffc020204a:	664040ef          	jal	ra,ffffffffc02066ae <memset>
    return page - pages + nbase;
ffffffffc020204e:	000b3683          	ld	a3,0(s6)
ffffffffc0202052:	40d486b3          	sub	a3,s1,a3
ffffffffc0202056:	8699                	srai	a3,a3,0x6
ffffffffc0202058:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020205a:	06aa                	slli	a3,a3,0xa
ffffffffc020205c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202060:	e014                	sd	a3,0(s0)
ffffffffc0202062:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202066:	068a                	slli	a3,a3,0x2
ffffffffc0202068:	757d                	lui	a0,0xfffff
ffffffffc020206a:	8ee9                	and	a3,a3,a0
ffffffffc020206c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202070:	04e7f463          	bgeu	a5,a4,ffffffffc02020b8 <get_pte+0x186>
ffffffffc0202074:	000ab503          	ld	a0,0(s5)
ffffffffc0202078:	00c95913          	srli	s2,s2,0xc
ffffffffc020207c:	1ff97913          	andi	s2,s2,511
ffffffffc0202080:	96aa                	add	a3,a3,a0
ffffffffc0202082:	00391513          	slli	a0,s2,0x3
ffffffffc0202086:	9536                	add	a0,a0,a3
}
ffffffffc0202088:	70e2                	ld	ra,56(sp)
ffffffffc020208a:	7442                	ld	s0,48(sp)
ffffffffc020208c:	74a2                	ld	s1,40(sp)
ffffffffc020208e:	7902                	ld	s2,32(sp)
ffffffffc0202090:	69e2                	ld	s3,24(sp)
ffffffffc0202092:	6a42                	ld	s4,16(sp)
ffffffffc0202094:	6aa2                	ld	s5,8(sp)
ffffffffc0202096:	6b02                	ld	s6,0(sp)
ffffffffc0202098:	6121                	addi	sp,sp,64
ffffffffc020209a:	8082                	ret
            return NULL;
ffffffffc020209c:	4501                	li	a0,0
ffffffffc020209e:	b7ed                	j	ffffffffc0202088 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020a0:	00005617          	auipc	a2,0x5
ffffffffc02020a4:	3c060613          	addi	a2,a2,960 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc02020a8:	0e300593          	li	a1,227
ffffffffc02020ac:	00005517          	auipc	a0,0x5
ffffffffc02020b0:	4e450513          	addi	a0,a0,1252 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc02020b4:	bccfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020b8:	00005617          	auipc	a2,0x5
ffffffffc02020bc:	3a860613          	addi	a2,a2,936 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc02020c0:	0ee00593          	li	a1,238
ffffffffc02020c4:	00005517          	auipc	a0,0x5
ffffffffc02020c8:	4cc50513          	addi	a0,a0,1228 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc02020cc:	bb4fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020d0:	86aa                	mv	a3,a0
ffffffffc02020d2:	00005617          	auipc	a2,0x5
ffffffffc02020d6:	38e60613          	addi	a2,a2,910 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc02020da:	0eb00593          	li	a1,235
ffffffffc02020de:	00005517          	auipc	a0,0x5
ffffffffc02020e2:	4b250513          	addi	a0,a0,1202 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc02020e6:	b9afe0ef          	jal	ra,ffffffffc0200480 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020ea:	86aa                	mv	a3,a0
ffffffffc02020ec:	00005617          	auipc	a2,0x5
ffffffffc02020f0:	37460613          	addi	a2,a2,884 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc02020f4:	0df00593          	li	a1,223
ffffffffc02020f8:	00005517          	auipc	a0,0x5
ffffffffc02020fc:	49850513          	addi	a0,a0,1176 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202100:	b80fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0202104 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202104:	1141                	addi	sp,sp,-16
ffffffffc0202106:	e022                	sd	s0,0(sp)
ffffffffc0202108:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020210a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020210c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020210e:	e25ff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202112:	c011                	beqz	s0,ffffffffc0202116 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202114:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202116:	c511                	beqz	a0,ffffffffc0202122 <get_page+0x1e>
ffffffffc0202118:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020211a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020211c:	0017f713          	andi	a4,a5,1
ffffffffc0202120:	e709                	bnez	a4,ffffffffc020212a <get_page+0x26>
}
ffffffffc0202122:	60a2                	ld	ra,8(sp)
ffffffffc0202124:	6402                	ld	s0,0(sp)
ffffffffc0202126:	0141                	addi	sp,sp,16
ffffffffc0202128:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020212a:	000aa717          	auipc	a4,0xaa
ffffffffc020212e:	78670713          	addi	a4,a4,1926 # ffffffffc02ac8b0 <npage>
ffffffffc0202132:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202134:	078a                	slli	a5,a5,0x2
ffffffffc0202136:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202138:	02e7f063          	bgeu	a5,a4,ffffffffc0202158 <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc020213c:	000aa717          	auipc	a4,0xaa
ffffffffc0202140:	7e470713          	addi	a4,a4,2020 # ffffffffc02ac920 <pages>
ffffffffc0202144:	6308                	ld	a0,0(a4)
ffffffffc0202146:	60a2                	ld	ra,8(sp)
ffffffffc0202148:	6402                	ld	s0,0(sp)
ffffffffc020214a:	fff80737          	lui	a4,0xfff80
ffffffffc020214e:	97ba                	add	a5,a5,a4
ffffffffc0202150:	079a                	slli	a5,a5,0x6
ffffffffc0202152:	953e                	add	a0,a0,a5
ffffffffc0202154:	0141                	addi	sp,sp,16
ffffffffc0202156:	8082                	ret
ffffffffc0202158:	cb1ff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>

ffffffffc020215c <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020215c:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020215e:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202162:	ec86                	sd	ra,88(sp)
ffffffffc0202164:	e8a2                	sd	s0,80(sp)
ffffffffc0202166:	e4a6                	sd	s1,72(sp)
ffffffffc0202168:	e0ca                	sd	s2,64(sp)
ffffffffc020216a:	fc4e                	sd	s3,56(sp)
ffffffffc020216c:	f852                	sd	s4,48(sp)
ffffffffc020216e:	f456                	sd	s5,40(sp)
ffffffffc0202170:	f05a                	sd	s6,32(sp)
ffffffffc0202172:	ec5e                	sd	s7,24(sp)
ffffffffc0202174:	e862                	sd	s8,16(sp)
ffffffffc0202176:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202178:	03479713          	slli	a4,a5,0x34
ffffffffc020217c:	eb71                	bnez	a4,ffffffffc0202250 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc020217e:	002007b7          	lui	a5,0x200
ffffffffc0202182:	842e                	mv	s0,a1
ffffffffc0202184:	0af5e663          	bltu	a1,a5,ffffffffc0202230 <unmap_range+0xd4>
ffffffffc0202188:	8932                	mv	s2,a2
ffffffffc020218a:	0ac5f363          	bgeu	a1,a2,ffffffffc0202230 <unmap_range+0xd4>
ffffffffc020218e:	4785                	li	a5,1
ffffffffc0202190:	07fe                	slli	a5,a5,0x1f
ffffffffc0202192:	08c7ef63          	bltu	a5,a2,ffffffffc0202230 <unmap_range+0xd4>
ffffffffc0202196:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202198:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020219a:	000aac97          	auipc	s9,0xaa
ffffffffc020219e:	716c8c93          	addi	s9,s9,1814 # ffffffffc02ac8b0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021a2:	000aac17          	auipc	s8,0xaa
ffffffffc02021a6:	77ec0c13          	addi	s8,s8,1918 # ffffffffc02ac920 <pages>
ffffffffc02021aa:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021ae:	00200b37          	lui	s6,0x200
ffffffffc02021b2:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021b6:	4601                	li	a2,0
ffffffffc02021b8:	85a2                	mv	a1,s0
ffffffffc02021ba:	854e                	mv	a0,s3
ffffffffc02021bc:	d77ff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02021c0:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021c2:	cd21                	beqz	a0,ffffffffc020221a <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021c4:	611c                	ld	a5,0(a0)
ffffffffc02021c6:	e38d                	bnez	a5,ffffffffc02021e8 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021c8:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021ca:	ff2466e3          	bltu	s0,s2,ffffffffc02021b6 <unmap_range+0x5a>
}
ffffffffc02021ce:	60e6                	ld	ra,88(sp)
ffffffffc02021d0:	6446                	ld	s0,80(sp)
ffffffffc02021d2:	64a6                	ld	s1,72(sp)
ffffffffc02021d4:	6906                	ld	s2,64(sp)
ffffffffc02021d6:	79e2                	ld	s3,56(sp)
ffffffffc02021d8:	7a42                	ld	s4,48(sp)
ffffffffc02021da:	7aa2                	ld	s5,40(sp)
ffffffffc02021dc:	7b02                	ld	s6,32(sp)
ffffffffc02021de:	6be2                	ld	s7,24(sp)
ffffffffc02021e0:	6c42                	ld	s8,16(sp)
ffffffffc02021e2:	6ca2                	ld	s9,8(sp)
ffffffffc02021e4:	6125                	addi	sp,sp,96
ffffffffc02021e6:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02021e8:	0017f713          	andi	a4,a5,1
ffffffffc02021ec:	df71                	beqz	a4,ffffffffc02021c8 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc02021ee:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021f2:	078a                	slli	a5,a5,0x2
ffffffffc02021f4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021f6:	06e7fd63          	bgeu	a5,a4,ffffffffc0202270 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc02021fa:	000c3503          	ld	a0,0(s8)
ffffffffc02021fe:	97de                	add	a5,a5,s7
ffffffffc0202200:	079a                	slli	a5,a5,0x6
ffffffffc0202202:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202204:	411c                	lw	a5,0(a0)
ffffffffc0202206:	fff7871b          	addiw	a4,a5,-1
ffffffffc020220a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020220c:	cf11                	beqz	a4,ffffffffc0202228 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020220e:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202212:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202216:	9452                	add	s0,s0,s4
ffffffffc0202218:	bf4d                	j	ffffffffc02021ca <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020221a:	945a                	add	s0,s0,s6
ffffffffc020221c:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202220:	d45d                	beqz	s0,ffffffffc02021ce <unmap_range+0x72>
ffffffffc0202222:	f9246ae3          	bltu	s0,s2,ffffffffc02021b6 <unmap_range+0x5a>
ffffffffc0202226:	b765                	j	ffffffffc02021ce <unmap_range+0x72>
            free_page(page);
ffffffffc0202228:	4585                	li	a1,1
ffffffffc020222a:	c83ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc020222e:	b7c5                	j	ffffffffc020220e <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202230:	00006697          	auipc	a3,0x6
ffffffffc0202234:	90868693          	addi	a3,a3,-1784 # ffffffffc0207b38 <default_pmm_manager+0x728>
ffffffffc0202238:	00005617          	auipc	a2,0x5
ffffffffc020223c:	a9060613          	addi	a2,a2,-1392 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202240:	11000593          	li	a1,272
ffffffffc0202244:	00005517          	auipc	a0,0x5
ffffffffc0202248:	34c50513          	addi	a0,a0,844 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc020224c:	a34fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202250:	00006697          	auipc	a3,0x6
ffffffffc0202254:	8b868693          	addi	a3,a3,-1864 # ffffffffc0207b08 <default_pmm_manager+0x6f8>
ffffffffc0202258:	00005617          	auipc	a2,0x5
ffffffffc020225c:	a7060613          	addi	a2,a2,-1424 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202260:	10f00593          	li	a1,271
ffffffffc0202264:	00005517          	auipc	a0,0x5
ffffffffc0202268:	32c50513          	addi	a0,a0,812 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc020226c:	a14fe0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202270:	b99ff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>

ffffffffc0202274 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202274:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202276:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020227a:	fc86                	sd	ra,120(sp)
ffffffffc020227c:	f8a2                	sd	s0,112(sp)
ffffffffc020227e:	f4a6                	sd	s1,104(sp)
ffffffffc0202280:	f0ca                	sd	s2,96(sp)
ffffffffc0202282:	ecce                	sd	s3,88(sp)
ffffffffc0202284:	e8d2                	sd	s4,80(sp)
ffffffffc0202286:	e4d6                	sd	s5,72(sp)
ffffffffc0202288:	e0da                	sd	s6,64(sp)
ffffffffc020228a:	fc5e                	sd	s7,56(sp)
ffffffffc020228c:	f862                	sd	s8,48(sp)
ffffffffc020228e:	f466                	sd	s9,40(sp)
ffffffffc0202290:	f06a                	sd	s10,32(sp)
ffffffffc0202292:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202294:	03479713          	slli	a4,a5,0x34
ffffffffc0202298:	1c071163          	bnez	a4,ffffffffc020245a <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc020229c:	002007b7          	lui	a5,0x200
ffffffffc02022a0:	20f5e563          	bltu	a1,a5,ffffffffc02024aa <exit_range+0x236>
ffffffffc02022a4:	8b32                	mv	s6,a2
ffffffffc02022a6:	20c5f263          	bgeu	a1,a2,ffffffffc02024aa <exit_range+0x236>
ffffffffc02022aa:	4785                	li	a5,1
ffffffffc02022ac:	07fe                	slli	a5,a5,0x1f
ffffffffc02022ae:	1ec7ee63          	bltu	a5,a2,ffffffffc02024aa <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022b2:	c00009b7          	lui	s3,0xc0000
ffffffffc02022b6:	400007b7          	lui	a5,0x40000
ffffffffc02022ba:	0135f9b3          	and	s3,a1,s3
ffffffffc02022be:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022c0:	c0000337          	lui	t1,0xc0000
ffffffffc02022c4:	00698933          	add	s2,s3,t1
ffffffffc02022c8:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022cc:	1ff97913          	andi	s2,s2,511
ffffffffc02022d0:	8e2a                	mv	t3,a0
ffffffffc02022d2:	090e                	slli	s2,s2,0x3
ffffffffc02022d4:	9972                	add	s2,s2,t3
ffffffffc02022d6:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022da:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc02022de:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc02022e0:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022e4:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc02022e6:	000aad17          	auipc	s10,0xaa
ffffffffc02022ea:	5cad0d13          	addi	s10,s10,1482 # ffffffffc02ac8b0 <npage>
    return KADDR(page2pa(page));
ffffffffc02022ee:	00cddd93          	srli	s11,s11,0xc
ffffffffc02022f2:	000aa717          	auipc	a4,0xaa
ffffffffc02022f6:	61e70713          	addi	a4,a4,1566 # ffffffffc02ac910 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc02022fa:	000aae97          	auipc	t4,0xaa
ffffffffc02022fe:	626e8e93          	addi	t4,t4,1574 # ffffffffc02ac920 <pages>
        if (pde1&PTE_V){
ffffffffc0202302:	e79d                	bnez	a5,ffffffffc0202330 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0202304:	12098963          	beqz	s3,ffffffffc0202436 <exit_range+0x1c2>
ffffffffc0202308:	400007b7          	lui	a5,0x40000
ffffffffc020230c:	84ce                	mv	s1,s3
ffffffffc020230e:	97ce                	add	a5,a5,s3
ffffffffc0202310:	1369f363          	bgeu	s3,s6,ffffffffc0202436 <exit_range+0x1c2>
ffffffffc0202314:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202316:	00698933          	add	s2,s3,t1
ffffffffc020231a:	01e95913          	srli	s2,s2,0x1e
ffffffffc020231e:	1ff97913          	andi	s2,s2,511
ffffffffc0202322:	090e                	slli	s2,s2,0x3
ffffffffc0202324:	9972                	add	s2,s2,t3
ffffffffc0202326:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc020232a:	001bf793          	andi	a5,s7,1
ffffffffc020232e:	dbf9                	beqz	a5,ffffffffc0202304 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202330:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202334:	0b8a                	slli	s7,s7,0x2
ffffffffc0202336:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc020233a:	14fbfc63          	bgeu	s7,a5,ffffffffc0202492 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020233e:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202342:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0202344:	000806b7          	lui	a3,0x80
ffffffffc0202348:	96d6                	add	a3,a3,s5
ffffffffc020234a:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc020234e:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0202352:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202354:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202356:	12f67263          	bgeu	a2,a5,ffffffffc020247a <exit_range+0x206>
ffffffffc020235a:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc020235e:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202360:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202364:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc0202366:	00080837          	lui	a6,0x80
ffffffffc020236a:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc020236c:	00200c37          	lui	s8,0x200
ffffffffc0202370:	a801                	j	ffffffffc0202380 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc0202372:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0202374:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202376:	c0d9                	beqz	s1,ffffffffc02023fc <exit_range+0x188>
ffffffffc0202378:	0934f263          	bgeu	s1,s3,ffffffffc02023fc <exit_range+0x188>
ffffffffc020237c:	0d64fc63          	bgeu	s1,s6,ffffffffc0202454 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202380:	0154d413          	srli	s0,s1,0x15
ffffffffc0202384:	1ff47413          	andi	s0,s0,511
ffffffffc0202388:	040e                	slli	s0,s0,0x3
ffffffffc020238a:	9452                	add	s0,s0,s4
ffffffffc020238c:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc020238e:	0017f693          	andi	a3,a5,1
ffffffffc0202392:	d2e5                	beqz	a3,ffffffffc0202372 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc0202394:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202398:	00279513          	slli	a0,a5,0x2
ffffffffc020239c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020239e:	0eb57a63          	bgeu	a0,a1,ffffffffc0202492 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023a2:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023a4:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023a8:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023ac:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023ae:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023b0:	0cb7f563          	bgeu	a5,a1,ffffffffc020247a <exit_range+0x206>
ffffffffc02023b4:	631c                	ld	a5,0(a4)
ffffffffc02023b6:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023b8:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023bc:	629c                	ld	a5,0(a3)
ffffffffc02023be:	8b85                	andi	a5,a5,1
ffffffffc02023c0:	fbd5                	bnez	a5,ffffffffc0202374 <exit_range+0x100>
ffffffffc02023c2:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023c4:	fed59ce3          	bne	a1,a3,ffffffffc02023bc <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023c8:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023cc:	4585                	li	a1,1
ffffffffc02023ce:	e072                	sd	t3,0(sp)
ffffffffc02023d0:	953e                	add	a0,a0,a5
ffffffffc02023d2:	adbff0ef          	jal	ra,ffffffffc0201eac <free_pages>
                d0start += PTSIZE;
ffffffffc02023d6:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023d8:	00043023          	sd	zero,0(s0)
ffffffffc02023dc:	000aae97          	auipc	t4,0xaa
ffffffffc02023e0:	544e8e93          	addi	t4,t4,1348 # ffffffffc02ac920 <pages>
ffffffffc02023e4:	6e02                	ld	t3,0(sp)
ffffffffc02023e6:	c0000337          	lui	t1,0xc0000
ffffffffc02023ea:	fff808b7          	lui	a7,0xfff80
ffffffffc02023ee:	00080837          	lui	a6,0x80
ffffffffc02023f2:	000aa717          	auipc	a4,0xaa
ffffffffc02023f6:	51e70713          	addi	a4,a4,1310 # ffffffffc02ac910 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02023fa:	fcbd                	bnez	s1,ffffffffc0202378 <exit_range+0x104>
            if (free_pd0) {
ffffffffc02023fc:	f00c84e3          	beqz	s9,ffffffffc0202304 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202400:	000d3783          	ld	a5,0(s10)
ffffffffc0202404:	e072                	sd	t3,0(sp)
ffffffffc0202406:	08fbf663          	bgeu	s7,a5,ffffffffc0202492 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020240a:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc020240e:	67a2                	ld	a5,8(sp)
ffffffffc0202410:	4585                	li	a1,1
ffffffffc0202412:	953e                	add	a0,a0,a5
ffffffffc0202414:	a99ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202418:	00093023          	sd	zero,0(s2)
ffffffffc020241c:	000aa717          	auipc	a4,0xaa
ffffffffc0202420:	4f470713          	addi	a4,a4,1268 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0202424:	c0000337          	lui	t1,0xc0000
ffffffffc0202428:	6e02                	ld	t3,0(sp)
ffffffffc020242a:	000aae97          	auipc	t4,0xaa
ffffffffc020242e:	4f6e8e93          	addi	t4,t4,1270 # ffffffffc02ac920 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0202432:	ec099be3          	bnez	s3,ffffffffc0202308 <exit_range+0x94>
}
ffffffffc0202436:	70e6                	ld	ra,120(sp)
ffffffffc0202438:	7446                	ld	s0,112(sp)
ffffffffc020243a:	74a6                	ld	s1,104(sp)
ffffffffc020243c:	7906                	ld	s2,96(sp)
ffffffffc020243e:	69e6                	ld	s3,88(sp)
ffffffffc0202440:	6a46                	ld	s4,80(sp)
ffffffffc0202442:	6aa6                	ld	s5,72(sp)
ffffffffc0202444:	6b06                	ld	s6,64(sp)
ffffffffc0202446:	7be2                	ld	s7,56(sp)
ffffffffc0202448:	7c42                	ld	s8,48(sp)
ffffffffc020244a:	7ca2                	ld	s9,40(sp)
ffffffffc020244c:	7d02                	ld	s10,32(sp)
ffffffffc020244e:	6de2                	ld	s11,24(sp)
ffffffffc0202450:	6109                	addi	sp,sp,128
ffffffffc0202452:	8082                	ret
            if (free_pd0) {
ffffffffc0202454:	ea0c8ae3          	beqz	s9,ffffffffc0202308 <exit_range+0x94>
ffffffffc0202458:	b765                	j	ffffffffc0202400 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020245a:	00005697          	auipc	a3,0x5
ffffffffc020245e:	6ae68693          	addi	a3,a3,1710 # ffffffffc0207b08 <default_pmm_manager+0x6f8>
ffffffffc0202462:	00005617          	auipc	a2,0x5
ffffffffc0202466:	86660613          	addi	a2,a2,-1946 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020246a:	12000593          	li	a1,288
ffffffffc020246e:	00005517          	auipc	a0,0x5
ffffffffc0202472:	12250513          	addi	a0,a0,290 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202476:	80afe0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc020247a:	00005617          	auipc	a2,0x5
ffffffffc020247e:	fe660613          	addi	a2,a2,-26 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0202482:	06900593          	li	a1,105
ffffffffc0202486:	00005517          	auipc	a0,0x5
ffffffffc020248a:	00250513          	addi	a0,a0,2 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc020248e:	ff3fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202492:	00005617          	auipc	a2,0x5
ffffffffc0202496:	02e60613          	addi	a2,a2,46 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc020249a:	06200593          	li	a1,98
ffffffffc020249e:	00005517          	auipc	a0,0x5
ffffffffc02024a2:	fea50513          	addi	a0,a0,-22 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc02024a6:	fdbfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024aa:	00005697          	auipc	a3,0x5
ffffffffc02024ae:	68e68693          	addi	a3,a3,1678 # ffffffffc0207b38 <default_pmm_manager+0x728>
ffffffffc02024b2:	00005617          	auipc	a2,0x5
ffffffffc02024b6:	81660613          	addi	a2,a2,-2026 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02024ba:	12100593          	li	a1,289
ffffffffc02024be:	00005517          	auipc	a0,0x5
ffffffffc02024c2:	0d250513          	addi	a0,a0,210 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc02024c6:	fbbfd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02024ca <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024ca:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024cc:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024ce:	e426                	sd	s1,8(sp)
ffffffffc02024d0:	ec06                	sd	ra,24(sp)
ffffffffc02024d2:	e822                	sd	s0,16(sp)
ffffffffc02024d4:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024d6:	a5dff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
    if (ptep != NULL) {
ffffffffc02024da:	c511                	beqz	a0,ffffffffc02024e6 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02024dc:	611c                	ld	a5,0(a0)
ffffffffc02024de:	842a                	mv	s0,a0
ffffffffc02024e0:	0017f713          	andi	a4,a5,1
ffffffffc02024e4:	e711                	bnez	a4,ffffffffc02024f0 <page_remove+0x26>
}
ffffffffc02024e6:	60e2                	ld	ra,24(sp)
ffffffffc02024e8:	6442                	ld	s0,16(sp)
ffffffffc02024ea:	64a2                	ld	s1,8(sp)
ffffffffc02024ec:	6105                	addi	sp,sp,32
ffffffffc02024ee:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02024f0:	000aa717          	auipc	a4,0xaa
ffffffffc02024f4:	3c070713          	addi	a4,a4,960 # ffffffffc02ac8b0 <npage>
ffffffffc02024f8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02024fa:	078a                	slli	a5,a5,0x2
ffffffffc02024fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024fe:	02e7fe63          	bgeu	a5,a4,ffffffffc020253a <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0202502:	000aa717          	auipc	a4,0xaa
ffffffffc0202506:	41e70713          	addi	a4,a4,1054 # ffffffffc02ac920 <pages>
ffffffffc020250a:	6308                	ld	a0,0(a4)
ffffffffc020250c:	fff80737          	lui	a4,0xfff80
ffffffffc0202510:	97ba                	add	a5,a5,a4
ffffffffc0202512:	079a                	slli	a5,a5,0x6
ffffffffc0202514:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202516:	411c                	lw	a5,0(a0)
ffffffffc0202518:	fff7871b          	addiw	a4,a5,-1
ffffffffc020251c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020251e:	cb11                	beqz	a4,ffffffffc0202532 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202520:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202524:	12048073          	sfence.vma	s1
}
ffffffffc0202528:	60e2                	ld	ra,24(sp)
ffffffffc020252a:	6442                	ld	s0,16(sp)
ffffffffc020252c:	64a2                	ld	s1,8(sp)
ffffffffc020252e:	6105                	addi	sp,sp,32
ffffffffc0202530:	8082                	ret
            free_page(page);
ffffffffc0202532:	4585                	li	a1,1
ffffffffc0202534:	979ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc0202538:	b7e5                	j	ffffffffc0202520 <page_remove+0x56>
ffffffffc020253a:	8cfff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>

ffffffffc020253e <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020253e:	7179                	addi	sp,sp,-48
ffffffffc0202540:	e44e                	sd	s3,8(sp)
ffffffffc0202542:	89b2                	mv	s3,a2
ffffffffc0202544:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202546:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202548:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020254a:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020254c:	ec26                	sd	s1,24(sp)
ffffffffc020254e:	f406                	sd	ra,40(sp)
ffffffffc0202550:	e84a                	sd	s2,16(sp)
ffffffffc0202552:	e052                	sd	s4,0(sp)
ffffffffc0202554:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202556:	9ddff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
    if (ptep == NULL) {
ffffffffc020255a:	cd49                	beqz	a0,ffffffffc02025f4 <page_insert+0xb6>
    page->ref += 1;
ffffffffc020255c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020255e:	611c                	ld	a5,0(a0)
ffffffffc0202560:	892a                	mv	s2,a0
ffffffffc0202562:	0016871b          	addiw	a4,a3,1
ffffffffc0202566:	c018                	sw	a4,0(s0)
ffffffffc0202568:	0017f713          	andi	a4,a5,1
ffffffffc020256c:	ef05                	bnez	a4,ffffffffc02025a4 <page_insert+0x66>
ffffffffc020256e:	000aa797          	auipc	a5,0xaa
ffffffffc0202572:	3b278793          	addi	a5,a5,946 # ffffffffc02ac920 <pages>
ffffffffc0202576:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0202578:	8c19                	sub	s0,s0,a4
ffffffffc020257a:	000806b7          	lui	a3,0x80
ffffffffc020257e:	8419                	srai	s0,s0,0x6
ffffffffc0202580:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202582:	042a                	slli	s0,s0,0xa
ffffffffc0202584:	8c45                	or	s0,s0,s1
ffffffffc0202586:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020258a:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020258e:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0202592:	4501                	li	a0,0
}
ffffffffc0202594:	70a2                	ld	ra,40(sp)
ffffffffc0202596:	7402                	ld	s0,32(sp)
ffffffffc0202598:	64e2                	ld	s1,24(sp)
ffffffffc020259a:	6942                	ld	s2,16(sp)
ffffffffc020259c:	69a2                	ld	s3,8(sp)
ffffffffc020259e:	6a02                	ld	s4,0(sp)
ffffffffc02025a0:	6145                	addi	sp,sp,48
ffffffffc02025a2:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025a4:	000aa717          	auipc	a4,0xaa
ffffffffc02025a8:	30c70713          	addi	a4,a4,780 # ffffffffc02ac8b0 <npage>
ffffffffc02025ac:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025ae:	078a                	slli	a5,a5,0x2
ffffffffc02025b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025b2:	04e7f363          	bgeu	a5,a4,ffffffffc02025f8 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025b6:	000aaa17          	auipc	s4,0xaa
ffffffffc02025ba:	36aa0a13          	addi	s4,s4,874 # ffffffffc02ac920 <pages>
ffffffffc02025be:	000a3703          	ld	a4,0(s4)
ffffffffc02025c2:	fff80537          	lui	a0,0xfff80
ffffffffc02025c6:	953e                	add	a0,a0,a5
ffffffffc02025c8:	051a                	slli	a0,a0,0x6
ffffffffc02025ca:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02025cc:	00a40a63          	beq	s0,a0,ffffffffc02025e0 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025d0:	411c                	lw	a5,0(a0)
ffffffffc02025d2:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025d6:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02025d8:	c691                	beqz	a3,ffffffffc02025e4 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025da:	12098073          	sfence.vma	s3
ffffffffc02025de:	bf69                	j	ffffffffc0202578 <page_insert+0x3a>
ffffffffc02025e0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02025e2:	bf59                	j	ffffffffc0202578 <page_insert+0x3a>
            free_page(page);
ffffffffc02025e4:	4585                	li	a1,1
ffffffffc02025e6:	8c7ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc02025ea:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025ee:	12098073          	sfence.vma	s3
ffffffffc02025f2:	b759                	j	ffffffffc0202578 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02025f4:	5571                	li	a0,-4
ffffffffc02025f6:	bf79                	j	ffffffffc0202594 <page_insert+0x56>
ffffffffc02025f8:	811ff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>

ffffffffc02025fc <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02025fc:	00005797          	auipc	a5,0x5
ffffffffc0202600:	e1478793          	addi	a5,a5,-492 # ffffffffc0207410 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202604:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202606:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202608:	00005517          	auipc	a0,0x5
ffffffffc020260c:	fb050513          	addi	a0,a0,-80 # ffffffffc02075b8 <default_pmm_manager+0x1a8>
void pmm_init(void) {
ffffffffc0202610:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202612:	000aa717          	auipc	a4,0xaa
ffffffffc0202616:	2ef73b23          	sd	a5,758(a4) # ffffffffc02ac908 <pmm_manager>
void pmm_init(void) {
ffffffffc020261a:	e0a2                	sd	s0,64(sp)
ffffffffc020261c:	fc26                	sd	s1,56(sp)
ffffffffc020261e:	f84a                	sd	s2,48(sp)
ffffffffc0202620:	f44e                	sd	s3,40(sp)
ffffffffc0202622:	f052                	sd	s4,32(sp)
ffffffffc0202624:	ec56                	sd	s5,24(sp)
ffffffffc0202626:	e85a                	sd	s6,16(sp)
ffffffffc0202628:	e45e                	sd	s7,8(sp)
ffffffffc020262a:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020262c:	000aa417          	auipc	s0,0xaa
ffffffffc0202630:	2dc40413          	addi	s0,s0,732 # ffffffffc02ac908 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202634:	b5bfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202638:	601c                	ld	a5,0(s0)
ffffffffc020263a:	000aa497          	auipc	s1,0xaa
ffffffffc020263e:	27648493          	addi	s1,s1,630 # ffffffffc02ac8b0 <npage>
ffffffffc0202642:	000aa917          	auipc	s2,0xaa
ffffffffc0202646:	2de90913          	addi	s2,s2,734 # ffffffffc02ac920 <pages>
ffffffffc020264a:	679c                	ld	a5,8(a5)
ffffffffc020264c:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020264e:	57f5                	li	a5,-3
ffffffffc0202650:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202652:	00005517          	auipc	a0,0x5
ffffffffc0202656:	f7e50513          	addi	a0,a0,-130 # ffffffffc02075d0 <default_pmm_manager+0x1c0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020265a:	000aa717          	auipc	a4,0xaa
ffffffffc020265e:	2af73b23          	sd	a5,694(a4) # ffffffffc02ac910 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0202662:	b2dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202666:	46c5                	li	a3,17
ffffffffc0202668:	06ee                	slli	a3,a3,0x1b
ffffffffc020266a:	40100613          	li	a2,1025
ffffffffc020266e:	16fd                	addi	a3,a3,-1
ffffffffc0202670:	0656                	slli	a2,a2,0x15
ffffffffc0202672:	07e005b7          	lui	a1,0x7e00
ffffffffc0202676:	00005517          	auipc	a0,0x5
ffffffffc020267a:	f7250513          	addi	a0,a0,-142 # ffffffffc02075e8 <default_pmm_manager+0x1d8>
ffffffffc020267e:	b11fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202682:	777d                	lui	a4,0xfffff
ffffffffc0202684:	000ab797          	auipc	a5,0xab
ffffffffc0202688:	39378793          	addi	a5,a5,915 # ffffffffc02ada17 <end+0xfff>
ffffffffc020268c:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020268e:	00088737          	lui	a4,0x88
ffffffffc0202692:	000aa697          	auipc	a3,0xaa
ffffffffc0202696:	20e6bf23          	sd	a4,542(a3) # ffffffffc02ac8b0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020269a:	000aa717          	auipc	a4,0xaa
ffffffffc020269e:	28f73323          	sd	a5,646(a4) # ffffffffc02ac920 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026a2:	4701                	li	a4,0
ffffffffc02026a4:	4685                	li	a3,1
ffffffffc02026a6:	fff80837          	lui	a6,0xfff80
ffffffffc02026aa:	a019                	j	ffffffffc02026b0 <pmm_init+0xb4>
ffffffffc02026ac:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026b0:	00671613          	slli	a2,a4,0x6
ffffffffc02026b4:	97b2                	add	a5,a5,a2
ffffffffc02026b6:	07a1                	addi	a5,a5,8
ffffffffc02026b8:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026bc:	6090                	ld	a2,0(s1)
ffffffffc02026be:	0705                	addi	a4,a4,1
ffffffffc02026c0:	010607b3          	add	a5,a2,a6
ffffffffc02026c4:	fef764e3          	bltu	a4,a5,ffffffffc02026ac <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026c8:	00093503          	ld	a0,0(s2)
ffffffffc02026cc:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026d0:	00661693          	slli	a3,a2,0x6
ffffffffc02026d4:	97aa                	add	a5,a5,a0
ffffffffc02026d6:	96be                	add	a3,a3,a5
ffffffffc02026d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02026dc:	7af6eb63          	bltu	a3,a5,ffffffffc0202e92 <pmm_init+0x896>
ffffffffc02026e0:	000aa997          	auipc	s3,0xaa
ffffffffc02026e4:	23098993          	addi	s3,s3,560 # ffffffffc02ac910 <va_pa_offset>
ffffffffc02026e8:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02026ec:	47c5                	li	a5,17
ffffffffc02026ee:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026f0:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02026f2:	02f6f763          	bgeu	a3,a5,ffffffffc0202720 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02026f6:	6585                	lui	a1,0x1
ffffffffc02026f8:	15fd                	addi	a1,a1,-1
ffffffffc02026fa:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02026fc:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202700:	48c77863          	bgeu	a4,a2,ffffffffc0202b90 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc0202704:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202706:	75fd                	lui	a1,0xfffff
ffffffffc0202708:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020270a:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc020270c:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020270e:	40d786b3          	sub	a3,a5,a3
ffffffffc0202712:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202714:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202718:	953a                	add	a0,a0,a4
ffffffffc020271a:	9602                	jalr	a2
ffffffffc020271c:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202720:	00005517          	auipc	a0,0x5
ffffffffc0202724:	ef050513          	addi	a0,a0,-272 # ffffffffc0207610 <default_pmm_manager+0x200>
ffffffffc0202728:	a67fd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020272c:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020272e:	000aa417          	auipc	s0,0xaa
ffffffffc0202732:	17a40413          	addi	s0,s0,378 # ffffffffc02ac8a8 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202736:	7b9c                	ld	a5,48(a5)
ffffffffc0202738:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020273a:	00005517          	auipc	a0,0x5
ffffffffc020273e:	eee50513          	addi	a0,a0,-274 # ffffffffc0207628 <default_pmm_manager+0x218>
ffffffffc0202742:	a4dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202746:	00009697          	auipc	a3,0x9
ffffffffc020274a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020274e:	000aa797          	auipc	a5,0xaa
ffffffffc0202752:	14d7bd23          	sd	a3,346(a5) # ffffffffc02ac8a8 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202756:	c02007b7          	lui	a5,0xc0200
ffffffffc020275a:	10f6e8e3          	bltu	a3,a5,ffffffffc020306a <pmm_init+0xa6e>
ffffffffc020275e:	0009b783          	ld	a5,0(s3)
ffffffffc0202762:	8e9d                	sub	a3,a3,a5
ffffffffc0202764:	000aa797          	auipc	a5,0xaa
ffffffffc0202768:	1ad7ba23          	sd	a3,436(a5) # ffffffffc02ac918 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc020276c:	f86ff0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202770:	6098                	ld	a4,0(s1)
ffffffffc0202772:	c80007b7          	lui	a5,0xc8000
ffffffffc0202776:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202778:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020277a:	0ce7e8e3          	bltu	a5,a4,ffffffffc020304a <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020277e:	6008                	ld	a0,0(s0)
ffffffffc0202780:	44050263          	beqz	a0,ffffffffc0202bc4 <pmm_init+0x5c8>
ffffffffc0202784:	03451793          	slli	a5,a0,0x34
ffffffffc0202788:	42079e63          	bnez	a5,ffffffffc0202bc4 <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020278c:	4601                	li	a2,0
ffffffffc020278e:	4581                	li	a1,0
ffffffffc0202790:	975ff0ef          	jal	ra,ffffffffc0202104 <get_page>
ffffffffc0202794:	78051b63          	bnez	a0,ffffffffc0202f2a <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202798:	4505                	li	a0,1
ffffffffc020279a:	e8aff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc020279e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027a0:	6008                	ld	a0,0(s0)
ffffffffc02027a2:	4681                	li	a3,0
ffffffffc02027a4:	4601                	li	a2,0
ffffffffc02027a6:	85d6                	mv	a1,s5
ffffffffc02027a8:	d97ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc02027ac:	7a051f63          	bnez	a0,ffffffffc0202f6a <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027b0:	6008                	ld	a0,0(s0)
ffffffffc02027b2:	4601                	li	a2,0
ffffffffc02027b4:	4581                	li	a1,0
ffffffffc02027b6:	f7cff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02027ba:	78050863          	beqz	a0,ffffffffc0202f4a <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02027be:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027c0:	0017f713          	andi	a4,a5,1
ffffffffc02027c4:	3e070463          	beqz	a4,ffffffffc0202bac <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02027c8:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027ca:	078a                	slli	a5,a5,0x2
ffffffffc02027cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027ce:	3ce7f163          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02027d2:	00093683          	ld	a3,0(s2)
ffffffffc02027d6:	fff80637          	lui	a2,0xfff80
ffffffffc02027da:	97b2                	add	a5,a5,a2
ffffffffc02027dc:	079a                	slli	a5,a5,0x6
ffffffffc02027de:	97b6                	add	a5,a5,a3
ffffffffc02027e0:	72fa9563          	bne	s5,a5,ffffffffc0202f0a <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc02027e4:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85d0>
ffffffffc02027e8:	4785                	li	a5,1
ffffffffc02027ea:	70fb9063          	bne	s7,a5,ffffffffc0202eea <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02027ee:	6008                	ld	a0,0(s0)
ffffffffc02027f0:	76fd                	lui	a3,0xfffff
ffffffffc02027f2:	611c                	ld	a5,0(a0)
ffffffffc02027f4:	078a                	slli	a5,a5,0x2
ffffffffc02027f6:	8ff5                	and	a5,a5,a3
ffffffffc02027f8:	00c7d613          	srli	a2,a5,0xc
ffffffffc02027fc:	66e67e63          	bgeu	a2,a4,ffffffffc0202e78 <pmm_init+0x87c>
ffffffffc0202800:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202804:	97e2                	add	a5,a5,s8
ffffffffc0202806:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7d535e8>
ffffffffc020280a:	0b0a                	slli	s6,s6,0x2
ffffffffc020280c:	00db7b33          	and	s6,s6,a3
ffffffffc0202810:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202814:	56e7f863          	bgeu	a5,a4,ffffffffc0202d84 <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202818:	4601                	li	a2,0
ffffffffc020281a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020281c:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020281e:	f14ff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202822:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202824:	55651063          	bne	a0,s6,ffffffffc0202d64 <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc0202828:	4505                	li	a0,1
ffffffffc020282a:	dfaff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc020282e:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202830:	6008                	ld	a0,0(s0)
ffffffffc0202832:	46d1                	li	a3,20
ffffffffc0202834:	6605                	lui	a2,0x1
ffffffffc0202836:	85da                	mv	a1,s6
ffffffffc0202838:	d07ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc020283c:	50051463          	bnez	a0,ffffffffc0202d44 <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202840:	6008                	ld	a0,0(s0)
ffffffffc0202842:	4601                	li	a2,0
ffffffffc0202844:	6585                	lui	a1,0x1
ffffffffc0202846:	eecff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc020284a:	4c050d63          	beqz	a0,ffffffffc0202d24 <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc020284e:	611c                	ld	a5,0(a0)
ffffffffc0202850:	0107f713          	andi	a4,a5,16
ffffffffc0202854:	4a070863          	beqz	a4,ffffffffc0202d04 <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc0202858:	8b91                	andi	a5,a5,4
ffffffffc020285a:	48078563          	beqz	a5,ffffffffc0202ce4 <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020285e:	6008                	ld	a0,0(s0)
ffffffffc0202860:	611c                	ld	a5,0(a0)
ffffffffc0202862:	8bc1                	andi	a5,a5,16
ffffffffc0202864:	46078063          	beqz	a5,ffffffffc0202cc4 <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc0202868:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5528>
ffffffffc020286c:	43779c63          	bne	a5,s7,ffffffffc0202ca4 <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202870:	4681                	li	a3,0
ffffffffc0202872:	6605                	lui	a2,0x1
ffffffffc0202874:	85d6                	mv	a1,s5
ffffffffc0202876:	cc9ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc020287a:	40051563          	bnez	a0,ffffffffc0202c84 <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc020287e:	000aa703          	lw	a4,0(s5)
ffffffffc0202882:	4789                	li	a5,2
ffffffffc0202884:	3ef71063          	bne	a4,a5,ffffffffc0202c64 <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc0202888:	000b2783          	lw	a5,0(s6)
ffffffffc020288c:	3a079c63          	bnez	a5,ffffffffc0202c44 <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202890:	6008                	ld	a0,0(s0)
ffffffffc0202892:	4601                	li	a2,0
ffffffffc0202894:	6585                	lui	a1,0x1
ffffffffc0202896:	e9cff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc020289a:	38050563          	beqz	a0,ffffffffc0202c24 <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc020289e:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028a0:	00177793          	andi	a5,a4,1
ffffffffc02028a4:	30078463          	beqz	a5,ffffffffc0202bac <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02028a8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028aa:	00271793          	slli	a5,a4,0x2
ffffffffc02028ae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028b0:	2ed7f063          	bgeu	a5,a3,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02028b4:	00093683          	ld	a3,0(s2)
ffffffffc02028b8:	fff80637          	lui	a2,0xfff80
ffffffffc02028bc:	97b2                	add	a5,a5,a2
ffffffffc02028be:	079a                	slli	a5,a5,0x6
ffffffffc02028c0:	97b6                	add	a5,a5,a3
ffffffffc02028c2:	32fa9163          	bne	s5,a5,ffffffffc0202be4 <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028c6:	8b41                	andi	a4,a4,16
ffffffffc02028c8:	70071163          	bnez	a4,ffffffffc0202fca <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028cc:	6008                	ld	a0,0(s0)
ffffffffc02028ce:	4581                	li	a1,0
ffffffffc02028d0:	bfbff0ef          	jal	ra,ffffffffc02024ca <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02028d4:	000aa703          	lw	a4,0(s5)
ffffffffc02028d8:	4785                	li	a5,1
ffffffffc02028da:	6cf71863          	bne	a4,a5,ffffffffc0202faa <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc02028de:	000b2783          	lw	a5,0(s6)
ffffffffc02028e2:	6a079463          	bnez	a5,ffffffffc0202f8a <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02028e6:	6008                	ld	a0,0(s0)
ffffffffc02028e8:	6585                	lui	a1,0x1
ffffffffc02028ea:	be1ff0ef          	jal	ra,ffffffffc02024ca <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02028ee:	000aa783          	lw	a5,0(s5)
ffffffffc02028f2:	50079363          	bnez	a5,ffffffffc0202df8 <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc02028f6:	000b2783          	lw	a5,0(s6)
ffffffffc02028fa:	4c079f63          	bnez	a5,ffffffffc0202dd8 <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02028fe:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202902:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202904:	000b3783          	ld	a5,0(s6)
ffffffffc0202908:	078a                	slli	a5,a5,0x2
ffffffffc020290a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020290c:	28e7f263          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202910:	fff806b7          	lui	a3,0xfff80
ffffffffc0202914:	00093503          	ld	a0,0(s2)
ffffffffc0202918:	97b6                	add	a5,a5,a3
ffffffffc020291a:	079a                	slli	a5,a5,0x6
ffffffffc020291c:	00f506b3          	add	a3,a0,a5
ffffffffc0202920:	4290                	lw	a2,0(a3)
ffffffffc0202922:	4685                	li	a3,1
ffffffffc0202924:	48d61a63          	bne	a2,a3,ffffffffc0202db8 <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc0202928:	8799                	srai	a5,a5,0x6
ffffffffc020292a:	00080ab7          	lui	s5,0x80
ffffffffc020292e:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0202930:	00c79693          	slli	a3,a5,0xc
ffffffffc0202934:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202936:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202938:	46e6f363          	bgeu	a3,a4,ffffffffc0202d9e <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020293c:	0009b683          	ld	a3,0(s3)
ffffffffc0202940:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202942:	639c                	ld	a5,0(a5)
ffffffffc0202944:	078a                	slli	a5,a5,0x2
ffffffffc0202946:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202948:	24e7f463          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020294c:	415787b3          	sub	a5,a5,s5
ffffffffc0202950:	079a                	slli	a5,a5,0x6
ffffffffc0202952:	953e                	add	a0,a0,a5
ffffffffc0202954:	4585                	li	a1,1
ffffffffc0202956:	d56ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020295a:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020295e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202960:	078a                	slli	a5,a5,0x2
ffffffffc0202962:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202964:	22e7f663          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202968:	00093503          	ld	a0,0(s2)
ffffffffc020296c:	415787b3          	sub	a5,a5,s5
ffffffffc0202970:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202972:	953e                	add	a0,a0,a5
ffffffffc0202974:	4585                	li	a1,1
ffffffffc0202976:	d36ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020297a:	601c                	ld	a5,0(s0)
ffffffffc020297c:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202980:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202984:	d6eff0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc0202988:	68aa1163          	bne	s4,a0,ffffffffc020300a <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020298c:	00005517          	auipc	a0,0x5
ffffffffc0202990:	fac50513          	addi	a0,a0,-84 # ffffffffc0207938 <default_pmm_manager+0x528>
ffffffffc0202994:	ffafd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0202998:	d5aff0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020299c:	6098                	ld	a4,0(s1)
ffffffffc020299e:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029a2:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029a4:	00c71693          	slli	a3,a4,0xc
ffffffffc02029a8:	18d7f563          	bgeu	a5,a3,ffffffffc0202b32 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029ac:	83b1                	srli	a5,a5,0xc
ffffffffc02029ae:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029b0:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029b4:	1ae7f163          	bgeu	a5,a4,ffffffffc0202b56 <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029b8:	7bfd                	lui	s7,0xfffff
ffffffffc02029ba:	6b05                	lui	s6,0x1
ffffffffc02029bc:	a029                	j	ffffffffc02029c6 <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029be:	00cad713          	srli	a4,s5,0xc
ffffffffc02029c2:	18f77a63          	bgeu	a4,a5,ffffffffc0202b56 <pmm_init+0x55a>
ffffffffc02029c6:	0009b583          	ld	a1,0(s3)
ffffffffc02029ca:	4601                	li	a2,0
ffffffffc02029cc:	95d6                	add	a1,a1,s5
ffffffffc02029ce:	d64ff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02029d2:	16050263          	beqz	a0,ffffffffc0202b36 <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029d6:	611c                	ld	a5,0(a0)
ffffffffc02029d8:	078a                	slli	a5,a5,0x2
ffffffffc02029da:	0177f7b3          	and	a5,a5,s7
ffffffffc02029de:	19579963          	bne	a5,s5,ffffffffc0202b70 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029e2:	609c                	ld	a5,0(s1)
ffffffffc02029e4:	9ada                	add	s5,s5,s6
ffffffffc02029e6:	6008                	ld	a0,0(s0)
ffffffffc02029e8:	00c79713          	slli	a4,a5,0xc
ffffffffc02029ec:	fceae9e3          	bltu	s5,a4,ffffffffc02029be <pmm_init+0x3c2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02029f0:	611c                	ld	a5,0(a0)
ffffffffc02029f2:	62079c63          	bnez	a5,ffffffffc020302a <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc02029f6:	4505                	li	a0,1
ffffffffc02029f8:	c2cff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02029fc:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02029fe:	6008                	ld	a0,0(s0)
ffffffffc0202a00:	4699                	li	a3,6
ffffffffc0202a02:	10000613          	li	a2,256
ffffffffc0202a06:	85d6                	mv	a1,s5
ffffffffc0202a08:	b37ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc0202a0c:	1e051c63          	bnez	a0,ffffffffc0202c04 <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0202a10:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a14:	4785                	li	a5,1
ffffffffc0202a16:	44f71163          	bne	a4,a5,ffffffffc0202e58 <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a1a:	6008                	ld	a0,0(s0)
ffffffffc0202a1c:	6b05                	lui	s6,0x1
ffffffffc0202a1e:	4699                	li	a3,6
ffffffffc0202a20:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x84d0>
ffffffffc0202a24:	85d6                	mv	a1,s5
ffffffffc0202a26:	b19ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc0202a2a:	40051763          	bnez	a0,ffffffffc0202e38 <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0202a2e:	000aa703          	lw	a4,0(s5)
ffffffffc0202a32:	4789                	li	a5,2
ffffffffc0202a34:	3ef71263          	bne	a4,a5,ffffffffc0202e18 <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a38:	00005597          	auipc	a1,0x5
ffffffffc0202a3c:	03858593          	addi	a1,a1,56 # ffffffffc0207a70 <default_pmm_manager+0x660>
ffffffffc0202a40:	10000513          	li	a0,256
ffffffffc0202a44:	411030ef          	jal	ra,ffffffffc0206654 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a48:	100b0593          	addi	a1,s6,256
ffffffffc0202a4c:	10000513          	li	a0,256
ffffffffc0202a50:	417030ef          	jal	ra,ffffffffc0206666 <strcmp>
ffffffffc0202a54:	44051b63          	bnez	a0,ffffffffc0202eaa <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc0202a58:	00093683          	ld	a3,0(s2)
ffffffffc0202a5c:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a60:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a62:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a66:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a68:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a6a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a6c:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a70:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a76:	10f77f63          	bgeu	a4,a5,ffffffffc0202b94 <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a7a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a7e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a82:	96be                	add	a3,a3,a5
ffffffffc0202a84:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fcd36e8>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a88:	389030ef          	jal	ra,ffffffffc0206610 <strlen>
ffffffffc0202a8c:	54051f63          	bnez	a0,ffffffffc0202fea <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a90:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a94:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a96:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd525e8>
ffffffffc0202a9a:	068a                	slli	a3,a3,0x2
ffffffffc0202a9c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a9e:	0ef6f963          	bgeu	a3,a5,ffffffffc0202b90 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0202aa2:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aa6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aa8:	0efb7663          	bgeu	s6,a5,ffffffffc0202b94 <pmm_init+0x598>
ffffffffc0202aac:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202ab0:	4585                	li	a1,1
ffffffffc0202ab2:	8556                	mv	a0,s5
ffffffffc0202ab4:	99b6                	add	s3,s3,a3
ffffffffc0202ab6:	bf6ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202aba:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202abe:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ac0:	078a                	slli	a5,a5,0x2
ffffffffc0202ac2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ac4:	0ce7f663          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ac8:	00093503          	ld	a0,0(s2)
ffffffffc0202acc:	fff809b7          	lui	s3,0xfff80
ffffffffc0202ad0:	97ce                	add	a5,a5,s3
ffffffffc0202ad2:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202ad4:	953e                	add	a0,a0,a5
ffffffffc0202ad6:	4585                	li	a1,1
ffffffffc0202ad8:	bd4ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202adc:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202ae0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ae2:	078a                	slli	a5,a5,0x2
ffffffffc0202ae4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ae6:	0ae7f563          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202aea:	00093503          	ld	a0,0(s2)
ffffffffc0202aee:	97ce                	add	a5,a5,s3
ffffffffc0202af0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202af2:	953e                	add	a0,a0,a5
ffffffffc0202af4:	4585                	li	a1,1
ffffffffc0202af6:	bb6ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202afa:	601c                	ld	a5,0(s0)
ffffffffc0202afc:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b00:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b04:	beeff0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc0202b08:	3caa1163          	bne	s4,a0,ffffffffc0202eca <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b0c:	00005517          	auipc	a0,0x5
ffffffffc0202b10:	fdc50513          	addi	a0,a0,-36 # ffffffffc0207ae8 <default_pmm_manager+0x6d8>
ffffffffc0202b14:	e7afd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202b18:	6406                	ld	s0,64(sp)
ffffffffc0202b1a:	60a6                	ld	ra,72(sp)
ffffffffc0202b1c:	74e2                	ld	s1,56(sp)
ffffffffc0202b1e:	7942                	ld	s2,48(sp)
ffffffffc0202b20:	79a2                	ld	s3,40(sp)
ffffffffc0202b22:	7a02                	ld	s4,32(sp)
ffffffffc0202b24:	6ae2                	ld	s5,24(sp)
ffffffffc0202b26:	6b42                	ld	s6,16(sp)
ffffffffc0202b28:	6ba2                	ld	s7,8(sp)
ffffffffc0202b2a:	6c02                	ld	s8,0(sp)
ffffffffc0202b2c:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b2e:	8daff06f          	j	ffffffffc0201c08 <kmalloc_init>
ffffffffc0202b32:	6008                	ld	a0,0(s0)
ffffffffc0202b34:	bd75                	j	ffffffffc02029f0 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b36:	00005697          	auipc	a3,0x5
ffffffffc0202b3a:	e2268693          	addi	a3,a3,-478 # ffffffffc0207958 <default_pmm_manager+0x548>
ffffffffc0202b3e:	00004617          	auipc	a2,0x4
ffffffffc0202b42:	18a60613          	addi	a2,a2,394 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202b46:	22d00593          	li	a1,557
ffffffffc0202b4a:	00005517          	auipc	a0,0x5
ffffffffc0202b4e:	a4650513          	addi	a0,a0,-1466 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202b52:	92ffd0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202b56:	86d6                	mv	a3,s5
ffffffffc0202b58:	00005617          	auipc	a2,0x5
ffffffffc0202b5c:	90860613          	addi	a2,a2,-1784 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0202b60:	22d00593          	li	a1,557
ffffffffc0202b64:	00005517          	auipc	a0,0x5
ffffffffc0202b68:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202b6c:	915fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b70:	00005697          	auipc	a3,0x5
ffffffffc0202b74:	e2868693          	addi	a3,a3,-472 # ffffffffc0207998 <default_pmm_manager+0x588>
ffffffffc0202b78:	00004617          	auipc	a2,0x4
ffffffffc0202b7c:	15060613          	addi	a2,a2,336 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202b80:	22e00593          	li	a1,558
ffffffffc0202b84:	00005517          	auipc	a0,0x5
ffffffffc0202b88:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202b8c:	8f5fd0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202b90:	a78ff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202b94:	00005617          	auipc	a2,0x5
ffffffffc0202b98:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0202b9c:	06900593          	li	a1,105
ffffffffc0202ba0:	00005517          	auipc	a0,0x5
ffffffffc0202ba4:	8e850513          	addi	a0,a0,-1816 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0202ba8:	8d9fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bac:	00005617          	auipc	a2,0x5
ffffffffc0202bb0:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0207728 <default_pmm_manager+0x318>
ffffffffc0202bb4:	07400593          	li	a1,116
ffffffffc0202bb8:	00005517          	auipc	a0,0x5
ffffffffc0202bbc:	8d050513          	addi	a0,a0,-1840 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0202bc0:	8c1fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202bc4:	00005697          	auipc	a3,0x5
ffffffffc0202bc8:	aa468693          	addi	a3,a3,-1372 # ffffffffc0207668 <default_pmm_manager+0x258>
ffffffffc0202bcc:	00004617          	auipc	a2,0x4
ffffffffc0202bd0:	0fc60613          	addi	a2,a2,252 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202bd4:	1f100593          	li	a1,497
ffffffffc0202bd8:	00005517          	auipc	a0,0x5
ffffffffc0202bdc:	9b850513          	addi	a0,a0,-1608 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202be0:	8a1fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202be4:	00005697          	auipc	a3,0x5
ffffffffc0202be8:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0207750 <default_pmm_manager+0x340>
ffffffffc0202bec:	00004617          	auipc	a2,0x4
ffffffffc0202bf0:	0dc60613          	addi	a2,a2,220 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202bf4:	20d00593          	li	a1,525
ffffffffc0202bf8:	00005517          	auipc	a0,0x5
ffffffffc0202bfc:	99850513          	addi	a0,a0,-1640 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202c00:	881fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c04:	00005697          	auipc	a3,0x5
ffffffffc0202c08:	dc468693          	addi	a3,a3,-572 # ffffffffc02079c8 <default_pmm_manager+0x5b8>
ffffffffc0202c0c:	00004617          	auipc	a2,0x4
ffffffffc0202c10:	0bc60613          	addi	a2,a2,188 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202c14:	23600593          	li	a1,566
ffffffffc0202c18:	00005517          	auipc	a0,0x5
ffffffffc0202c1c:	97850513          	addi	a0,a0,-1672 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202c20:	861fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c24:	00005697          	auipc	a3,0x5
ffffffffc0202c28:	bbc68693          	addi	a3,a3,-1092 # ffffffffc02077e0 <default_pmm_manager+0x3d0>
ffffffffc0202c2c:	00004617          	auipc	a2,0x4
ffffffffc0202c30:	09c60613          	addi	a2,a2,156 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202c34:	20c00593          	li	a1,524
ffffffffc0202c38:	00005517          	auipc	a0,0x5
ffffffffc0202c3c:	95850513          	addi	a0,a0,-1704 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202c40:	841fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c44:	00005697          	auipc	a3,0x5
ffffffffc0202c48:	c6468693          	addi	a3,a3,-924 # ffffffffc02078a8 <default_pmm_manager+0x498>
ffffffffc0202c4c:	00004617          	auipc	a2,0x4
ffffffffc0202c50:	07c60613          	addi	a2,a2,124 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202c54:	20b00593          	li	a1,523
ffffffffc0202c58:	00005517          	auipc	a0,0x5
ffffffffc0202c5c:	93850513          	addi	a0,a0,-1736 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202c60:	821fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c64:	00005697          	auipc	a3,0x5
ffffffffc0202c68:	c2c68693          	addi	a3,a3,-980 # ffffffffc0207890 <default_pmm_manager+0x480>
ffffffffc0202c6c:	00004617          	auipc	a2,0x4
ffffffffc0202c70:	05c60613          	addi	a2,a2,92 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202c74:	20a00593          	li	a1,522
ffffffffc0202c78:	00005517          	auipc	a0,0x5
ffffffffc0202c7c:	91850513          	addi	a0,a0,-1768 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202c80:	801fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202c84:	00005697          	auipc	a3,0x5
ffffffffc0202c88:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0207860 <default_pmm_manager+0x450>
ffffffffc0202c8c:	00004617          	auipc	a2,0x4
ffffffffc0202c90:	03c60613          	addi	a2,a2,60 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202c94:	20900593          	li	a1,521
ffffffffc0202c98:	00005517          	auipc	a0,0x5
ffffffffc0202c9c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202ca0:	fe0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202ca4:	00005697          	auipc	a3,0x5
ffffffffc0202ca8:	ba468693          	addi	a3,a3,-1116 # ffffffffc0207848 <default_pmm_manager+0x438>
ffffffffc0202cac:	00004617          	auipc	a2,0x4
ffffffffc0202cb0:	01c60613          	addi	a2,a2,28 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202cb4:	20700593          	li	a1,519
ffffffffc0202cb8:	00005517          	auipc	a0,0x5
ffffffffc0202cbc:	8d850513          	addi	a0,a0,-1832 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202cc0:	fc0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202cc4:	00005697          	auipc	a3,0x5
ffffffffc0202cc8:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0207830 <default_pmm_manager+0x420>
ffffffffc0202ccc:	00004617          	auipc	a2,0x4
ffffffffc0202cd0:	ffc60613          	addi	a2,a2,-4 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202cd4:	20600593          	li	a1,518
ffffffffc0202cd8:	00005517          	auipc	a0,0x5
ffffffffc0202cdc:	8b850513          	addi	a0,a0,-1864 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202ce0:	fa0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202ce4:	00005697          	auipc	a3,0x5
ffffffffc0202ce8:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0207820 <default_pmm_manager+0x410>
ffffffffc0202cec:	00004617          	auipc	a2,0x4
ffffffffc0202cf0:	fdc60613          	addi	a2,a2,-36 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202cf4:	20500593          	li	a1,517
ffffffffc0202cf8:	00005517          	auipc	a0,0x5
ffffffffc0202cfc:	89850513          	addi	a0,a0,-1896 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202d00:	f80fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d04:	00005697          	auipc	a3,0x5
ffffffffc0202d08:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0207810 <default_pmm_manager+0x400>
ffffffffc0202d0c:	00004617          	auipc	a2,0x4
ffffffffc0202d10:	fbc60613          	addi	a2,a2,-68 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202d14:	20400593          	li	a1,516
ffffffffc0202d18:	00005517          	auipc	a0,0x5
ffffffffc0202d1c:	87850513          	addi	a0,a0,-1928 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202d20:	f60fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d24:	00005697          	auipc	a3,0x5
ffffffffc0202d28:	abc68693          	addi	a3,a3,-1348 # ffffffffc02077e0 <default_pmm_manager+0x3d0>
ffffffffc0202d2c:	00004617          	auipc	a2,0x4
ffffffffc0202d30:	f9c60613          	addi	a2,a2,-100 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202d34:	20300593          	li	a1,515
ffffffffc0202d38:	00005517          	auipc	a0,0x5
ffffffffc0202d3c:	85850513          	addi	a0,a0,-1960 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202d40:	f40fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d44:	00005697          	auipc	a3,0x5
ffffffffc0202d48:	a6468693          	addi	a3,a3,-1436 # ffffffffc02077a8 <default_pmm_manager+0x398>
ffffffffc0202d4c:	00004617          	auipc	a2,0x4
ffffffffc0202d50:	f7c60613          	addi	a2,a2,-132 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202d54:	20200593          	li	a1,514
ffffffffc0202d58:	00005517          	auipc	a0,0x5
ffffffffc0202d5c:	83850513          	addi	a0,a0,-1992 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202d60:	f20fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d64:	00005697          	auipc	a3,0x5
ffffffffc0202d68:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0207780 <default_pmm_manager+0x370>
ffffffffc0202d6c:	00004617          	auipc	a2,0x4
ffffffffc0202d70:	f5c60613          	addi	a2,a2,-164 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202d74:	1ff00593          	li	a1,511
ffffffffc0202d78:	00005517          	auipc	a0,0x5
ffffffffc0202d7c:	81850513          	addi	a0,a0,-2024 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202d80:	f00fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d84:	86da                	mv	a3,s6
ffffffffc0202d86:	00004617          	auipc	a2,0x4
ffffffffc0202d8a:	6da60613          	addi	a2,a2,1754 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0202d8e:	1fe00593          	li	a1,510
ffffffffc0202d92:	00004517          	auipc	a0,0x4
ffffffffc0202d96:	7fe50513          	addi	a0,a0,2046 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202d9a:	ee6fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202d9e:	86be                	mv	a3,a5
ffffffffc0202da0:	00004617          	auipc	a2,0x4
ffffffffc0202da4:	6c060613          	addi	a2,a2,1728 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0202da8:	06900593          	li	a1,105
ffffffffc0202dac:	00004517          	auipc	a0,0x4
ffffffffc0202db0:	6dc50513          	addi	a0,a0,1756 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0202db4:	eccfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202db8:	00005697          	auipc	a3,0x5
ffffffffc0202dbc:	b3868693          	addi	a3,a3,-1224 # ffffffffc02078f0 <default_pmm_manager+0x4e0>
ffffffffc0202dc0:	00004617          	auipc	a2,0x4
ffffffffc0202dc4:	f0860613          	addi	a2,a2,-248 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202dc8:	21800593          	li	a1,536
ffffffffc0202dcc:	00004517          	auipc	a0,0x4
ffffffffc0202dd0:	7c450513          	addi	a0,a0,1988 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202dd4:	eacfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202dd8:	00005697          	auipc	a3,0x5
ffffffffc0202ddc:	ad068693          	addi	a3,a3,-1328 # ffffffffc02078a8 <default_pmm_manager+0x498>
ffffffffc0202de0:	00004617          	auipc	a2,0x4
ffffffffc0202de4:	ee860613          	addi	a2,a2,-280 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202de8:	21600593          	li	a1,534
ffffffffc0202dec:	00004517          	auipc	a0,0x4
ffffffffc0202df0:	7a450513          	addi	a0,a0,1956 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202df4:	e8cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202df8:	00005697          	auipc	a3,0x5
ffffffffc0202dfc:	ae068693          	addi	a3,a3,-1312 # ffffffffc02078d8 <default_pmm_manager+0x4c8>
ffffffffc0202e00:	00004617          	auipc	a2,0x4
ffffffffc0202e04:	ec860613          	addi	a2,a2,-312 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202e08:	21500593          	li	a1,533
ffffffffc0202e0c:	00004517          	auipc	a0,0x4
ffffffffc0202e10:	78450513          	addi	a0,a0,1924 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202e14:	e6cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e18:	00005697          	auipc	a3,0x5
ffffffffc0202e1c:	c4068693          	addi	a3,a3,-960 # ffffffffc0207a58 <default_pmm_manager+0x648>
ffffffffc0202e20:	00004617          	auipc	a2,0x4
ffffffffc0202e24:	ea860613          	addi	a2,a2,-344 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202e28:	23900593          	li	a1,569
ffffffffc0202e2c:	00004517          	auipc	a0,0x4
ffffffffc0202e30:	76450513          	addi	a0,a0,1892 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202e34:	e4cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e38:	00005697          	auipc	a3,0x5
ffffffffc0202e3c:	be068693          	addi	a3,a3,-1056 # ffffffffc0207a18 <default_pmm_manager+0x608>
ffffffffc0202e40:	00004617          	auipc	a2,0x4
ffffffffc0202e44:	e8860613          	addi	a2,a2,-376 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202e48:	23800593          	li	a1,568
ffffffffc0202e4c:	00004517          	auipc	a0,0x4
ffffffffc0202e50:	74450513          	addi	a0,a0,1860 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202e54:	e2cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e58:	00005697          	auipc	a3,0x5
ffffffffc0202e5c:	ba868693          	addi	a3,a3,-1112 # ffffffffc0207a00 <default_pmm_manager+0x5f0>
ffffffffc0202e60:	00004617          	auipc	a2,0x4
ffffffffc0202e64:	e6860613          	addi	a2,a2,-408 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202e68:	23700593          	li	a1,567
ffffffffc0202e6c:	00004517          	auipc	a0,0x4
ffffffffc0202e70:	72450513          	addi	a0,a0,1828 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202e74:	e0cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202e78:	86be                	mv	a3,a5
ffffffffc0202e7a:	00004617          	auipc	a2,0x4
ffffffffc0202e7e:	5e660613          	addi	a2,a2,1510 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0202e82:	1fd00593          	li	a1,509
ffffffffc0202e86:	00004517          	auipc	a0,0x4
ffffffffc0202e8a:	70a50513          	addi	a0,a0,1802 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202e8e:	df2fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202e92:	00004617          	auipc	a2,0x4
ffffffffc0202e96:	60660613          	addi	a2,a2,1542 # ffffffffc0207498 <default_pmm_manager+0x88>
ffffffffc0202e9a:	07f00593          	li	a1,127
ffffffffc0202e9e:	00004517          	auipc	a0,0x4
ffffffffc0202ea2:	6f250513          	addi	a0,a0,1778 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202ea6:	ddafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202eaa:	00005697          	auipc	a3,0x5
ffffffffc0202eae:	bde68693          	addi	a3,a3,-1058 # ffffffffc0207a88 <default_pmm_manager+0x678>
ffffffffc0202eb2:	00004617          	auipc	a2,0x4
ffffffffc0202eb6:	e1660613          	addi	a2,a2,-490 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202eba:	23d00593          	li	a1,573
ffffffffc0202ebe:	00004517          	auipc	a0,0x4
ffffffffc0202ec2:	6d250513          	addi	a0,a0,1746 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202ec6:	dbafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202eca:	00005697          	auipc	a3,0x5
ffffffffc0202ece:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0207918 <default_pmm_manager+0x508>
ffffffffc0202ed2:	00004617          	auipc	a2,0x4
ffffffffc0202ed6:	df660613          	addi	a2,a2,-522 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202eda:	24900593          	li	a1,585
ffffffffc0202ede:	00004517          	auipc	a0,0x4
ffffffffc0202ee2:	6b250513          	addi	a0,a0,1714 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202ee6:	d9afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202eea:	00005697          	auipc	a3,0x5
ffffffffc0202eee:	87e68693          	addi	a3,a3,-1922 # ffffffffc0207768 <default_pmm_manager+0x358>
ffffffffc0202ef2:	00004617          	auipc	a2,0x4
ffffffffc0202ef6:	dd660613          	addi	a2,a2,-554 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202efa:	1fb00593          	li	a1,507
ffffffffc0202efe:	00004517          	auipc	a0,0x4
ffffffffc0202f02:	69250513          	addi	a0,a0,1682 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202f06:	d7afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f0a:	00005697          	auipc	a3,0x5
ffffffffc0202f0e:	84668693          	addi	a3,a3,-1978 # ffffffffc0207750 <default_pmm_manager+0x340>
ffffffffc0202f12:	00004617          	auipc	a2,0x4
ffffffffc0202f16:	db660613          	addi	a2,a2,-586 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202f1a:	1fa00593          	li	a1,506
ffffffffc0202f1e:	00004517          	auipc	a0,0x4
ffffffffc0202f22:	67250513          	addi	a0,a0,1650 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202f26:	d5afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f2a:	00004697          	auipc	a3,0x4
ffffffffc0202f2e:	77668693          	addi	a3,a3,1910 # ffffffffc02076a0 <default_pmm_manager+0x290>
ffffffffc0202f32:	00004617          	auipc	a2,0x4
ffffffffc0202f36:	d9660613          	addi	a2,a2,-618 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202f3a:	1f200593          	li	a1,498
ffffffffc0202f3e:	00004517          	auipc	a0,0x4
ffffffffc0202f42:	65250513          	addi	a0,a0,1618 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202f46:	d3afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f4a:	00004697          	auipc	a3,0x4
ffffffffc0202f4e:	7ae68693          	addi	a3,a3,1966 # ffffffffc02076f8 <default_pmm_manager+0x2e8>
ffffffffc0202f52:	00004617          	auipc	a2,0x4
ffffffffc0202f56:	d7660613          	addi	a2,a2,-650 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202f5a:	1f900593          	li	a1,505
ffffffffc0202f5e:	00004517          	auipc	a0,0x4
ffffffffc0202f62:	63250513          	addi	a0,a0,1586 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202f66:	d1afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f6a:	00004697          	auipc	a3,0x4
ffffffffc0202f6e:	75e68693          	addi	a3,a3,1886 # ffffffffc02076c8 <default_pmm_manager+0x2b8>
ffffffffc0202f72:	00004617          	auipc	a2,0x4
ffffffffc0202f76:	d5660613          	addi	a2,a2,-682 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202f7a:	1f600593          	li	a1,502
ffffffffc0202f7e:	00004517          	auipc	a0,0x4
ffffffffc0202f82:	61250513          	addi	a0,a0,1554 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202f86:	cfafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f8a:	00005697          	auipc	a3,0x5
ffffffffc0202f8e:	91e68693          	addi	a3,a3,-1762 # ffffffffc02078a8 <default_pmm_manager+0x498>
ffffffffc0202f92:	00004617          	auipc	a2,0x4
ffffffffc0202f96:	d3660613          	addi	a2,a2,-714 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202f9a:	21200593          	li	a1,530
ffffffffc0202f9e:	00004517          	auipc	a0,0x4
ffffffffc0202fa2:	5f250513          	addi	a0,a0,1522 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202fa6:	cdafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202faa:	00004697          	auipc	a3,0x4
ffffffffc0202fae:	7be68693          	addi	a3,a3,1982 # ffffffffc0207768 <default_pmm_manager+0x358>
ffffffffc0202fb2:	00004617          	auipc	a2,0x4
ffffffffc0202fb6:	d1660613          	addi	a2,a2,-746 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202fba:	21100593          	li	a1,529
ffffffffc0202fbe:	00004517          	auipc	a0,0x4
ffffffffc0202fc2:	5d250513          	addi	a0,a0,1490 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202fc6:	cbafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202fca:	00005697          	auipc	a3,0x5
ffffffffc0202fce:	8f668693          	addi	a3,a3,-1802 # ffffffffc02078c0 <default_pmm_manager+0x4b0>
ffffffffc0202fd2:	00004617          	auipc	a2,0x4
ffffffffc0202fd6:	cf660613          	addi	a2,a2,-778 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202fda:	20e00593          	li	a1,526
ffffffffc0202fde:	00004517          	auipc	a0,0x4
ffffffffc0202fe2:	5b250513          	addi	a0,a0,1458 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0202fe6:	c9afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202fea:	00005697          	auipc	a3,0x5
ffffffffc0202fee:	ad668693          	addi	a3,a3,-1322 # ffffffffc0207ac0 <default_pmm_manager+0x6b0>
ffffffffc0202ff2:	00004617          	auipc	a2,0x4
ffffffffc0202ff6:	cd660613          	addi	a2,a2,-810 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0202ffa:	24000593          	li	a1,576
ffffffffc0202ffe:	00004517          	auipc	a0,0x4
ffffffffc0203002:	59250513          	addi	a0,a0,1426 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0203006:	c7afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020300a:	00005697          	auipc	a3,0x5
ffffffffc020300e:	90e68693          	addi	a3,a3,-1778 # ffffffffc0207918 <default_pmm_manager+0x508>
ffffffffc0203012:	00004617          	auipc	a2,0x4
ffffffffc0203016:	cb660613          	addi	a2,a2,-842 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020301a:	22000593          	li	a1,544
ffffffffc020301e:	00004517          	auipc	a0,0x4
ffffffffc0203022:	57250513          	addi	a0,a0,1394 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0203026:	c5afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020302a:	00005697          	auipc	a3,0x5
ffffffffc020302e:	98668693          	addi	a3,a3,-1658 # ffffffffc02079b0 <default_pmm_manager+0x5a0>
ffffffffc0203032:	00004617          	auipc	a2,0x4
ffffffffc0203036:	c9660613          	addi	a2,a2,-874 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020303a:	23200593          	li	a1,562
ffffffffc020303e:	00004517          	auipc	a0,0x4
ffffffffc0203042:	55250513          	addi	a0,a0,1362 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0203046:	c3afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020304a:	00004697          	auipc	a3,0x4
ffffffffc020304e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0207648 <default_pmm_manager+0x238>
ffffffffc0203052:	00004617          	auipc	a2,0x4
ffffffffc0203056:	c7660613          	addi	a2,a2,-906 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020305a:	1f000593          	li	a1,496
ffffffffc020305e:	00004517          	auipc	a0,0x4
ffffffffc0203062:	53250513          	addi	a0,a0,1330 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0203066:	c1afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020306a:	00004617          	auipc	a2,0x4
ffffffffc020306e:	42e60613          	addi	a2,a2,1070 # ffffffffc0207498 <default_pmm_manager+0x88>
ffffffffc0203072:	0c100593          	li	a1,193
ffffffffc0203076:	00004517          	auipc	a0,0x4
ffffffffc020307a:	51a50513          	addi	a0,a0,1306 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc020307e:	c02fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203082 <copy_range>:
               bool share) {
ffffffffc0203082:	7119                	addi	sp,sp,-128
ffffffffc0203084:	f0ca                	sd	s2,96(sp)
ffffffffc0203086:	8936                	mv	s2,a3
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203088:	8ed1                	or	a3,a3,a2
               bool share) {
ffffffffc020308a:	fc86                	sd	ra,120(sp)
ffffffffc020308c:	f8a2                	sd	s0,112(sp)
ffffffffc020308e:	f4a6                	sd	s1,104(sp)
ffffffffc0203090:	ecce                	sd	s3,88(sp)
ffffffffc0203092:	e8d2                	sd	s4,80(sp)
ffffffffc0203094:	e4d6                	sd	s5,72(sp)
ffffffffc0203096:	e0da                	sd	s6,64(sp)
ffffffffc0203098:	fc5e                	sd	s7,56(sp)
ffffffffc020309a:	f862                	sd	s8,48(sp)
ffffffffc020309c:	f466                	sd	s9,40(sp)
ffffffffc020309e:	f06a                	sd	s10,32(sp)
ffffffffc02030a0:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030a2:	03469793          	slli	a5,a3,0x34
ffffffffc02030a6:	24079763          	bnez	a5,ffffffffc02032f4 <copy_range+0x272>
ffffffffc02030aa:	8dba                	mv	s11,a4
    assert(USER_ACCESS(start, end));
ffffffffc02030ac:	00200737          	lui	a4,0x200
ffffffffc02030b0:	8d32                	mv	s10,a2
ffffffffc02030b2:	22e66163          	bltu	a2,a4,ffffffffc02032d4 <copy_range+0x252>
ffffffffc02030b6:	21267f63          	bgeu	a2,s2,ffffffffc02032d4 <copy_range+0x252>
ffffffffc02030ba:	4705                	li	a4,1
ffffffffc02030bc:	077e                	slli	a4,a4,0x1f
ffffffffc02030be:	21276b63          	bltu	a4,s2,ffffffffc02032d4 <copy_range+0x252>
ffffffffc02030c2:	5c7d                	li	s8,-1
ffffffffc02030c4:	8aaa                	mv	s5,a0
ffffffffc02030c6:	84ae                	mv	s1,a1
        start += PGSIZE;
ffffffffc02030c8:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030ca:	000a9b97          	auipc	s7,0xa9
ffffffffc02030ce:	7e6b8b93          	addi	s7,s7,2022 # ffffffffc02ac8b0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030d2:	000aab17          	auipc	s6,0xaa
ffffffffc02030d6:	84eb0b13          	addi	s6,s6,-1970 # ffffffffc02ac920 <pages>
ffffffffc02030da:	fff80cb7          	lui	s9,0xfff80
    return KADDR(page2pa(page));
ffffffffc02030de:	00cc5c13          	srli	s8,s8,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02030e2:	4601                	li	a2,0
ffffffffc02030e4:	85ea                	mv	a1,s10
ffffffffc02030e6:	8526                	mv	a0,s1
ffffffffc02030e8:	e4bfe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02030ec:	842a                	mv	s0,a0
        if (ptep == NULL) {
ffffffffc02030ee:	c945                	beqz	a0,ffffffffc020319e <copy_range+0x11c>
        if (*ptep & PTE_V) {
ffffffffc02030f0:	6118                	ld	a4,0(a0)
ffffffffc02030f2:	8b05                	andi	a4,a4,1
ffffffffc02030f4:	e705                	bnez	a4,ffffffffc020311c <copy_range+0x9a>
        start += PGSIZE;
ffffffffc02030f6:	9d52                	add	s10,s10,s4
    } while (start != 0 && start < end);
ffffffffc02030f8:	ff2d65e3          	bltu	s10,s2,ffffffffc02030e2 <copy_range+0x60>
    return 0;
ffffffffc02030fc:	4501                	li	a0,0
}
ffffffffc02030fe:	70e6                	ld	ra,120(sp)
ffffffffc0203100:	7446                	ld	s0,112(sp)
ffffffffc0203102:	74a6                	ld	s1,104(sp)
ffffffffc0203104:	7906                	ld	s2,96(sp)
ffffffffc0203106:	69e6                	ld	s3,88(sp)
ffffffffc0203108:	6a46                	ld	s4,80(sp)
ffffffffc020310a:	6aa6                	ld	s5,72(sp)
ffffffffc020310c:	6b06                	ld	s6,64(sp)
ffffffffc020310e:	7be2                	ld	s7,56(sp)
ffffffffc0203110:	7c42                	ld	s8,48(sp)
ffffffffc0203112:	7ca2                	ld	s9,40(sp)
ffffffffc0203114:	7d02                	ld	s10,32(sp)
ffffffffc0203116:	6de2                	ld	s11,24(sp)
ffffffffc0203118:	6109                	addi	sp,sp,128
ffffffffc020311a:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc020311c:	4605                	li	a2,1
ffffffffc020311e:	85ea                	mv	a1,s10
ffffffffc0203120:	8556                	mv	a0,s5
ffffffffc0203122:	e11fe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc0203126:	10050063          	beqz	a0,ffffffffc0203226 <copy_range+0x1a4>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020312a:	6018                	ld	a4,0(s0)
    if (!(pte & PTE_V)) {
ffffffffc020312c:	00177693          	andi	a3,a4,1
ffffffffc0203130:	0007099b          	sext.w	s3,a4
ffffffffc0203134:	10068763          	beqz	a3,ffffffffc0203242 <copy_range+0x1c0>
    if (PPN(pa) >= npage) {
ffffffffc0203138:	000bb683          	ld	a3,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc020313c:	070a                	slli	a4,a4,0x2
ffffffffc020313e:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203140:	0ed77563          	bgeu	a4,a3,ffffffffc020322a <copy_range+0x1a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203144:	000b3403          	ld	s0,0(s6)
ffffffffc0203148:	9766                	add	a4,a4,s9
ffffffffc020314a:	071a                	slli	a4,a4,0x6
ffffffffc020314c:	943a                	add	s0,s0,a4
            struct Page *npage = alloc_page();
ffffffffc020314e:	4505                	li	a0,1
ffffffffc0203150:	cd5fe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
            assert(page != NULL);
ffffffffc0203154:	14040063          	beqz	s0,ffffffffc0203294 <copy_range+0x212>
            assert(npage != NULL);
ffffffffc0203158:	10050e63          	beqz	a0,ffffffffc0203274 <copy_range+0x1f2>
            if (share) {
ffffffffc020315c:	040d8e63          	beqz	s11,ffffffffc02031b8 <copy_range+0x136>
                page_insert(from,page,start,perm&(~PTE_W));
ffffffffc0203160:	01b9f993          	andi	s3,s3,27
ffffffffc0203164:	86ce                	mv	a3,s3
ffffffffc0203166:	866a                	mv	a2,s10
ffffffffc0203168:	85a2                	mv	a1,s0
ffffffffc020316a:	8526                	mv	a0,s1
ffffffffc020316c:	bd2ff0ef          	jal	ra,ffffffffc020253e <page_insert>
                ret = page_insert(to,page,start,perm&(~PTE_W));
ffffffffc0203170:	86ce                	mv	a3,s3
ffffffffc0203172:	866a                	mv	a2,s10
ffffffffc0203174:	85a2                	mv	a1,s0
ffffffffc0203176:	8556                	mv	a0,s5
ffffffffc0203178:	bc6ff0ef          	jal	ra,ffffffffc020253e <page_insert>
            assert(ret == 0);
ffffffffc020317c:	dd2d                	beqz	a0,ffffffffc02030f6 <copy_range+0x74>
ffffffffc020317e:	00004697          	auipc	a3,0x4
ffffffffc0203182:	40268693          	addi	a3,a3,1026 # ffffffffc0207580 <default_pmm_manager+0x170>
ffffffffc0203186:	00004617          	auipc	a2,0x4
ffffffffc020318a:	b4260613          	addi	a2,a2,-1214 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020318e:	19200593          	li	a1,402
ffffffffc0203192:	00004517          	auipc	a0,0x4
ffffffffc0203196:	3fe50513          	addi	a0,a0,1022 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc020319a:	ae6fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020319e:	00200737          	lui	a4,0x200
ffffffffc02031a2:	00ed07b3          	add	a5,s10,a4
ffffffffc02031a6:	ffe00737          	lui	a4,0xffe00
ffffffffc02031aa:	00e7fd33          	and	s10,a5,a4
    } while (start != 0 && start < end);
ffffffffc02031ae:	f40d07e3          	beqz	s10,ffffffffc02030fc <copy_range+0x7a>
ffffffffc02031b2:	f32d68e3          	bltu	s10,s2,ffffffffc02030e2 <copy_range+0x60>
ffffffffc02031b6:	b799                	j	ffffffffc02030fc <copy_range+0x7a>
                struct Page *npage=alloc_page();
ffffffffc02031b8:	4505                	li	a0,1
ffffffffc02031ba:	c6bfe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02031be:	882a                	mv	a6,a0
                assert(npage!=NULL);
ffffffffc02031c0:	0e050a63          	beqz	a0,ffffffffc02032b4 <copy_range+0x232>
    return page - pages + nbase;
ffffffffc02031c4:	000b3703          	ld	a4,0(s6)
ffffffffc02031c8:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc02031cc:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc02031d0:	40e406b3          	sub	a3,s0,a4
ffffffffc02031d4:	8699                	srai	a3,a3,0x6
ffffffffc02031d6:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02031d8:	0186f5b3          	and	a1,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc02031dc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031de:	06c5ff63          	bgeu	a1,a2,ffffffffc020325c <copy_range+0x1da>
    return page - pages + nbase;
ffffffffc02031e2:	40e50733          	sub	a4,a0,a4
    return KADDR(page2pa(page));
ffffffffc02031e6:	000a9797          	auipc	a5,0xa9
ffffffffc02031ea:	72a78793          	addi	a5,a5,1834 # ffffffffc02ac910 <va_pa_offset>
ffffffffc02031ee:	6388                	ld	a0,0(a5)
    return page - pages + nbase;
ffffffffc02031f0:	8719                	srai	a4,a4,0x6
ffffffffc02031f2:	000807b7          	lui	a5,0x80
ffffffffc02031f6:	973e                	add	a4,a4,a5
    return KADDR(page2pa(page));
ffffffffc02031f8:	018778b3          	and	a7,a4,s8
ffffffffc02031fc:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203200:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc0203202:	04c8fc63          	bgeu	a7,a2,ffffffffc020325a <copy_range+0x1d8>
                memcpy((void *)dst_kvaddr, (const void *)src_kvaddr, PGSIZE); // (3) memory copy
ffffffffc0203206:	6605                	lui	a2,0x1
ffffffffc0203208:	953a                	add	a0,a0,a4
ffffffffc020320a:	e442                	sd	a6,8(sp)
ffffffffc020320c:	4b4030ef          	jal	ra,ffffffffc02066c0 <memcpy>
                ret = page_insert(to, npage, start, perm); // (4) build the map
ffffffffc0203210:	6822                	ld	a6,8(sp)
ffffffffc0203212:	01f9f693          	andi	a3,s3,31
ffffffffc0203216:	866a                	mv	a2,s10
ffffffffc0203218:	85c2                	mv	a1,a6
ffffffffc020321a:	8556                	mv	a0,s5
ffffffffc020321c:	b22ff0ef          	jal	ra,ffffffffc020253e <page_insert>
            assert(ret == 0);
ffffffffc0203220:	ec050be3          	beqz	a0,ffffffffc02030f6 <copy_range+0x74>
ffffffffc0203224:	bfa9                	j	ffffffffc020317e <copy_range+0xfc>
                return -E_NO_MEM;
ffffffffc0203226:	5571                	li	a0,-4
ffffffffc0203228:	bdd9                	j	ffffffffc02030fe <copy_range+0x7c>
        panic("pa2page called with invalid pa");
ffffffffc020322a:	00004617          	auipc	a2,0x4
ffffffffc020322e:	29660613          	addi	a2,a2,662 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc0203232:	06200593          	li	a1,98
ffffffffc0203236:	00004517          	auipc	a0,0x4
ffffffffc020323a:	25250513          	addi	a0,a0,594 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc020323e:	a42fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203242:	00004617          	auipc	a2,0x4
ffffffffc0203246:	4e660613          	addi	a2,a2,1254 # ffffffffc0207728 <default_pmm_manager+0x318>
ffffffffc020324a:	07400593          	li	a1,116
ffffffffc020324e:	00004517          	auipc	a0,0x4
ffffffffc0203252:	23a50513          	addi	a0,a0,570 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0203256:	a2afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc020325a:	86ba                	mv	a3,a4
ffffffffc020325c:	00004617          	auipc	a2,0x4
ffffffffc0203260:	20460613          	addi	a2,a2,516 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0203264:	06900593          	li	a1,105
ffffffffc0203268:	00004517          	auipc	a0,0x4
ffffffffc020326c:	22050513          	addi	a0,a0,544 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0203270:	a10fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            assert(npage != NULL);
ffffffffc0203274:	00004697          	auipc	a3,0x4
ffffffffc0203278:	2ec68693          	addi	a3,a3,748 # ffffffffc0207560 <default_pmm_manager+0x150>
ffffffffc020327c:	00004617          	auipc	a2,0x4
ffffffffc0203280:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203284:	17300593          	li	a1,371
ffffffffc0203288:	00004517          	auipc	a0,0x4
ffffffffc020328c:	30850513          	addi	a0,a0,776 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0203290:	9f0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            assert(page != NULL);
ffffffffc0203294:	00004697          	auipc	a3,0x4
ffffffffc0203298:	2bc68693          	addi	a3,a3,700 # ffffffffc0207550 <default_pmm_manager+0x140>
ffffffffc020329c:	00004617          	auipc	a2,0x4
ffffffffc02032a0:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02032a4:	17200593          	li	a1,370
ffffffffc02032a8:	00004517          	auipc	a0,0x4
ffffffffc02032ac:	2e850513          	addi	a0,a0,744 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc02032b0:	9d0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
                assert(npage!=NULL);
ffffffffc02032b4:	00004697          	auipc	a3,0x4
ffffffffc02032b8:	2bc68693          	addi	a3,a3,700 # ffffffffc0207570 <default_pmm_manager+0x160>
ffffffffc02032bc:	00004617          	auipc	a2,0x4
ffffffffc02032c0:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02032c4:	18c00593          	li	a1,396
ffffffffc02032c8:	00004517          	auipc	a0,0x4
ffffffffc02032cc:	2c850513          	addi	a0,a0,712 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc02032d0:	9b0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02032d4:	00005697          	auipc	a3,0x5
ffffffffc02032d8:	86468693          	addi	a3,a3,-1948 # ffffffffc0207b38 <default_pmm_manager+0x728>
ffffffffc02032dc:	00004617          	auipc	a2,0x4
ffffffffc02032e0:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02032e4:	15e00593          	li	a1,350
ffffffffc02032e8:	00004517          	auipc	a0,0x4
ffffffffc02032ec:	2a850513          	addi	a0,a0,680 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc02032f0:	990fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032f4:	00005697          	auipc	a3,0x5
ffffffffc02032f8:	81468693          	addi	a3,a3,-2028 # ffffffffc0207b08 <default_pmm_manager+0x6f8>
ffffffffc02032fc:	00004617          	auipc	a2,0x4
ffffffffc0203300:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203304:	15d00593          	li	a1,349
ffffffffc0203308:	00004517          	auipc	a0,0x4
ffffffffc020330c:	28850513          	addi	a0,a0,648 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc0203310:	970fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203314 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203314:	12058073          	sfence.vma	a1
}
ffffffffc0203318:	8082                	ret

ffffffffc020331a <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020331a:	7179                	addi	sp,sp,-48
ffffffffc020331c:	e84a                	sd	s2,16(sp)
ffffffffc020331e:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203320:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203322:	f022                	sd	s0,32(sp)
ffffffffc0203324:	ec26                	sd	s1,24(sp)
ffffffffc0203326:	e44e                	sd	s3,8(sp)
ffffffffc0203328:	f406                	sd	ra,40(sp)
ffffffffc020332a:	84ae                	mv	s1,a1
ffffffffc020332c:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020332e:	af7fe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0203332:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203334:	cd1d                	beqz	a0,ffffffffc0203372 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203336:	85aa                	mv	a1,a0
ffffffffc0203338:	86ce                	mv	a3,s3
ffffffffc020333a:	8626                	mv	a2,s1
ffffffffc020333c:	854a                	mv	a0,s2
ffffffffc020333e:	a00ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc0203342:	e121                	bnez	a0,ffffffffc0203382 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0203344:	000a9797          	auipc	a5,0xa9
ffffffffc0203348:	57c78793          	addi	a5,a5,1404 # ffffffffc02ac8c0 <swap_init_ok>
ffffffffc020334c:	439c                	lw	a5,0(a5)
ffffffffc020334e:	2781                	sext.w	a5,a5
ffffffffc0203350:	c38d                	beqz	a5,ffffffffc0203372 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0203352:	000a9797          	auipc	a5,0xa9
ffffffffc0203356:	6ae78793          	addi	a5,a5,1710 # ffffffffc02aca00 <check_mm_struct>
ffffffffc020335a:	6388                	ld	a0,0(a5)
ffffffffc020335c:	c919                	beqz	a0,ffffffffc0203372 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020335e:	4681                	li	a3,0
ffffffffc0203360:	8622                	mv	a2,s0
ffffffffc0203362:	85a6                	mv	a1,s1
ffffffffc0203364:	7da000ef          	jal	ra,ffffffffc0203b3e <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203368:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc020336a:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020336c:	4785                	li	a5,1
ffffffffc020336e:	02f71063          	bne	a4,a5,ffffffffc020338e <pgdir_alloc_page+0x74>
}
ffffffffc0203372:	8522                	mv	a0,s0
ffffffffc0203374:	70a2                	ld	ra,40(sp)
ffffffffc0203376:	7402                	ld	s0,32(sp)
ffffffffc0203378:	64e2                	ld	s1,24(sp)
ffffffffc020337a:	6942                	ld	s2,16(sp)
ffffffffc020337c:	69a2                	ld	s3,8(sp)
ffffffffc020337e:	6145                	addi	sp,sp,48
ffffffffc0203380:	8082                	ret
            free_page(page);
ffffffffc0203382:	8522                	mv	a0,s0
ffffffffc0203384:	4585                	li	a1,1
ffffffffc0203386:	b27fe0ef          	jal	ra,ffffffffc0201eac <free_pages>
            return NULL;
ffffffffc020338a:	4401                	li	s0,0
ffffffffc020338c:	b7dd                	j	ffffffffc0203372 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020338e:	00004697          	auipc	a3,0x4
ffffffffc0203392:	21268693          	addi	a3,a3,530 # ffffffffc02075a0 <default_pmm_manager+0x190>
ffffffffc0203396:	00004617          	auipc	a2,0x4
ffffffffc020339a:	93260613          	addi	a2,a2,-1742 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020339e:	1d100593          	li	a1,465
ffffffffc02033a2:	00004517          	auipc	a0,0x4
ffffffffc02033a6:	1ee50513          	addi	a0,a0,494 # ffffffffc0207590 <default_pmm_manager+0x180>
ffffffffc02033aa:	8d6fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02033ae <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02033ae:	7135                	addi	sp,sp,-160
ffffffffc02033b0:	ed06                	sd	ra,152(sp)
ffffffffc02033b2:	e922                	sd	s0,144(sp)
ffffffffc02033b4:	e526                	sd	s1,136(sp)
ffffffffc02033b6:	e14a                	sd	s2,128(sp)
ffffffffc02033b8:	fcce                	sd	s3,120(sp)
ffffffffc02033ba:	f8d2                	sd	s4,112(sp)
ffffffffc02033bc:	f4d6                	sd	s5,104(sp)
ffffffffc02033be:	f0da                	sd	s6,96(sp)
ffffffffc02033c0:	ecde                	sd	s7,88(sp)
ffffffffc02033c2:	e8e2                	sd	s8,80(sp)
ffffffffc02033c4:	e4e6                	sd	s9,72(sp)
ffffffffc02033c6:	e0ea                	sd	s10,64(sp)
ffffffffc02033c8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02033ca:	05f010ef          	jal	ra,ffffffffc0204c28 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02033ce:	000a9797          	auipc	a5,0xa9
ffffffffc02033d2:	5e278793          	addi	a5,a5,1506 # ffffffffc02ac9b0 <max_swap_offset>
ffffffffc02033d6:	6394                	ld	a3,0(a5)
ffffffffc02033d8:	010007b7          	lui	a5,0x1000
ffffffffc02033dc:	17e1                	addi	a5,a5,-8
ffffffffc02033de:	ff968713          	addi	a4,a3,-7
ffffffffc02033e2:	4ae7ee63          	bltu	a5,a4,ffffffffc020389e <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033e6:	0009e797          	auipc	a5,0x9e
ffffffffc02033ea:	05a78793          	addi	a5,a5,90 # ffffffffc02a1440 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033ee:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033f0:	000a9697          	auipc	a3,0xa9
ffffffffc02033f4:	4cf6b423          	sd	a5,1224(a3) # ffffffffc02ac8b8 <sm>
     int r = sm->init();
ffffffffc02033f8:	9702                	jalr	a4
ffffffffc02033fa:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033fc:	c10d                	beqz	a0,ffffffffc020341e <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033fe:	60ea                	ld	ra,152(sp)
ffffffffc0203400:	644a                	ld	s0,144(sp)
ffffffffc0203402:	8556                	mv	a0,s5
ffffffffc0203404:	64aa                	ld	s1,136(sp)
ffffffffc0203406:	690a                	ld	s2,128(sp)
ffffffffc0203408:	79e6                	ld	s3,120(sp)
ffffffffc020340a:	7a46                	ld	s4,112(sp)
ffffffffc020340c:	7aa6                	ld	s5,104(sp)
ffffffffc020340e:	7b06                	ld	s6,96(sp)
ffffffffc0203410:	6be6                	ld	s7,88(sp)
ffffffffc0203412:	6c46                	ld	s8,80(sp)
ffffffffc0203414:	6ca6                	ld	s9,72(sp)
ffffffffc0203416:	6d06                	ld	s10,64(sp)
ffffffffc0203418:	7de2                	ld	s11,56(sp)
ffffffffc020341a:	610d                	addi	sp,sp,160
ffffffffc020341c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020341e:	000a9797          	auipc	a5,0xa9
ffffffffc0203422:	49a78793          	addi	a5,a5,1178 # ffffffffc02ac8b8 <sm>
ffffffffc0203426:	639c                	ld	a5,0(a5)
ffffffffc0203428:	00004517          	auipc	a0,0x4
ffffffffc020342c:	7a850513          	addi	a0,a0,1960 # ffffffffc0207bd0 <default_pmm_manager+0x7c0>
    return listelm->next;
ffffffffc0203430:	000a9417          	auipc	s0,0xa9
ffffffffc0203434:	4c040413          	addi	s0,s0,1216 # ffffffffc02ac8f0 <free_area>
ffffffffc0203438:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020343a:	4785                	li	a5,1
ffffffffc020343c:	000a9717          	auipc	a4,0xa9
ffffffffc0203440:	48f72223          	sw	a5,1156(a4) # ffffffffc02ac8c0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203444:	d4bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203448:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020344a:	36878e63          	beq	a5,s0,ffffffffc02037c6 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020344e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203452:	8305                	srli	a4,a4,0x1
ffffffffc0203454:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203456:	36070c63          	beqz	a4,ffffffffc02037ce <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc020345a:	4481                	li	s1,0
ffffffffc020345c:	4901                	li	s2,0
ffffffffc020345e:	a031                	j	ffffffffc020346a <swap_init+0xbc>
ffffffffc0203460:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203464:	8b09                	andi	a4,a4,2
ffffffffc0203466:	36070463          	beqz	a4,ffffffffc02037ce <swap_init+0x420>
        count ++, total += p->property;
ffffffffc020346a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020346e:	679c                	ld	a5,8(a5)
ffffffffc0203470:	2905                	addiw	s2,s2,1
ffffffffc0203472:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203474:	fe8796e3          	bne	a5,s0,ffffffffc0203460 <swap_init+0xb2>
ffffffffc0203478:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020347a:	a79fe0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc020347e:	69351863          	bne	a0,s3,ffffffffc0203b0e <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203482:	8626                	mv	a2,s1
ffffffffc0203484:	85ca                	mv	a1,s2
ffffffffc0203486:	00004517          	auipc	a0,0x4
ffffffffc020348a:	76250513          	addi	a0,a0,1890 # ffffffffc0207be8 <default_pmm_manager+0x7d8>
ffffffffc020348e:	d01fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203492:	473000ef          	jal	ra,ffffffffc0204104 <mm_create>
ffffffffc0203496:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203498:	60050b63          	beqz	a0,ffffffffc0203aae <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020349c:	000a9797          	auipc	a5,0xa9
ffffffffc02034a0:	56478793          	addi	a5,a5,1380 # ffffffffc02aca00 <check_mm_struct>
ffffffffc02034a4:	639c                	ld	a5,0(a5)
ffffffffc02034a6:	62079463          	bnez	a5,ffffffffc0203ace <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034aa:	000a9797          	auipc	a5,0xa9
ffffffffc02034ae:	3fe78793          	addi	a5,a5,1022 # ffffffffc02ac8a8 <boot_pgdir>
ffffffffc02034b2:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02034b6:	000a9797          	auipc	a5,0xa9
ffffffffc02034ba:	54a7b523          	sd	a0,1354(a5) # ffffffffc02aca00 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02034be:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034c2:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02034c6:	4e079863          	bnez	a5,ffffffffc02039b6 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02034ca:	6599                	lui	a1,0x6
ffffffffc02034cc:	460d                	li	a2,3
ffffffffc02034ce:	6505                	lui	a0,0x1
ffffffffc02034d0:	481000ef          	jal	ra,ffffffffc0204150 <vma_create>
ffffffffc02034d4:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034d6:	50050063          	beqz	a0,ffffffffc02039d6 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02034da:	855e                	mv	a0,s7
ffffffffc02034dc:	4e1000ef          	jal	ra,ffffffffc02041bc <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034e0:	00004517          	auipc	a0,0x4
ffffffffc02034e4:	77850513          	addi	a0,a0,1912 # ffffffffc0207c58 <default_pmm_manager+0x848>
ffffffffc02034e8:	ca7fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034ec:	018bb503          	ld	a0,24(s7)
ffffffffc02034f0:	4605                	li	a2,1
ffffffffc02034f2:	6585                	lui	a1,0x1
ffffffffc02034f4:	a3ffe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034f8:	4e050f63          	beqz	a0,ffffffffc02039f6 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034fc:	00004517          	auipc	a0,0x4
ffffffffc0203500:	7ac50513          	addi	a0,a0,1964 # ffffffffc0207ca8 <default_pmm_manager+0x898>
ffffffffc0203504:	000a9997          	auipc	s3,0xa9
ffffffffc0203508:	42498993          	addi	s3,s3,1060 # ffffffffc02ac928 <check_rp>
ffffffffc020350c:	c83fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203510:	000a9a17          	auipc	s4,0xa9
ffffffffc0203514:	438a0a13          	addi	s4,s4,1080 # ffffffffc02ac948 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203518:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc020351a:	4505                	li	a0,1
ffffffffc020351c:	909fe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0203520:	00ac3023          	sd	a0,0(s8) # 200000 <_binary_obj___user_exit_out_size+0x1f5528>
          assert(check_rp[i] != NULL );
ffffffffc0203524:	32050d63          	beqz	a0,ffffffffc020385e <swap_init+0x4b0>
ffffffffc0203528:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc020352a:	8b89                	andi	a5,a5,2
ffffffffc020352c:	30079963          	bnez	a5,ffffffffc020383e <swap_init+0x490>
ffffffffc0203530:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203532:	ff4c14e3          	bne	s8,s4,ffffffffc020351a <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203536:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203538:	000a9c17          	auipc	s8,0xa9
ffffffffc020353c:	3f0c0c13          	addi	s8,s8,1008 # ffffffffc02ac928 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0203540:	ec3e                	sd	a5,24(sp)
ffffffffc0203542:	641c                	ld	a5,8(s0)
ffffffffc0203544:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203546:	481c                	lw	a5,16(s0)
ffffffffc0203548:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc020354a:	000a9797          	auipc	a5,0xa9
ffffffffc020354e:	3a87b723          	sd	s0,942(a5) # ffffffffc02ac8f8 <free_area+0x8>
ffffffffc0203552:	000a9797          	auipc	a5,0xa9
ffffffffc0203556:	3887bf23          	sd	s0,926(a5) # ffffffffc02ac8f0 <free_area>
     nr_free = 0;
ffffffffc020355a:	000a9797          	auipc	a5,0xa9
ffffffffc020355e:	3a07a323          	sw	zero,934(a5) # ffffffffc02ac900 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203562:	000c3503          	ld	a0,0(s8)
ffffffffc0203566:	4585                	li	a1,1
ffffffffc0203568:	0c21                	addi	s8,s8,8
ffffffffc020356a:	943fe0ef          	jal	ra,ffffffffc0201eac <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020356e:	ff4c1ae3          	bne	s8,s4,ffffffffc0203562 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203572:	01042c03          	lw	s8,16(s0)
ffffffffc0203576:	4791                	li	a5,4
ffffffffc0203578:	50fc1b63          	bne	s8,a5,ffffffffc0203a8e <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020357c:	00004517          	auipc	a0,0x4
ffffffffc0203580:	7b450513          	addi	a0,a0,1972 # ffffffffc0207d30 <default_pmm_manager+0x920>
ffffffffc0203584:	c0bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203588:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020358a:	000a9797          	auipc	a5,0xa9
ffffffffc020358e:	3207ad23          	sw	zero,826(a5) # ffffffffc02ac8c4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203592:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203594:	000a9797          	auipc	a5,0xa9
ffffffffc0203598:	33078793          	addi	a5,a5,816 # ffffffffc02ac8c4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020359c:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x85d0>
     assert(pgfault_num==1);
ffffffffc02035a0:	4398                	lw	a4,0(a5)
ffffffffc02035a2:	4585                	li	a1,1
ffffffffc02035a4:	2701                	sext.w	a4,a4
ffffffffc02035a6:	38b71863          	bne	a4,a1,ffffffffc0203936 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02035aa:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02035ae:	4394                	lw	a3,0(a5)
ffffffffc02035b0:	2681                	sext.w	a3,a3
ffffffffc02035b2:	3ae69263          	bne	a3,a4,ffffffffc0203956 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02035b6:	6689                	lui	a3,0x2
ffffffffc02035b8:	462d                	li	a2,11
ffffffffc02035ba:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x75d0>
     assert(pgfault_num==2);
ffffffffc02035be:	4398                	lw	a4,0(a5)
ffffffffc02035c0:	4589                	li	a1,2
ffffffffc02035c2:	2701                	sext.w	a4,a4
ffffffffc02035c4:	2eb71963          	bne	a4,a1,ffffffffc02038b6 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02035c8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02035cc:	4394                	lw	a3,0(a5)
ffffffffc02035ce:	2681                	sext.w	a3,a3
ffffffffc02035d0:	30e69363          	bne	a3,a4,ffffffffc02038d6 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035d4:	668d                	lui	a3,0x3
ffffffffc02035d6:	4631                	li	a2,12
ffffffffc02035d8:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x65d0>
     assert(pgfault_num==3);
ffffffffc02035dc:	4398                	lw	a4,0(a5)
ffffffffc02035de:	458d                	li	a1,3
ffffffffc02035e0:	2701                	sext.w	a4,a4
ffffffffc02035e2:	30b71a63          	bne	a4,a1,ffffffffc02038f6 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035e6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035ea:	4394                	lw	a3,0(a5)
ffffffffc02035ec:	2681                	sext.w	a3,a3
ffffffffc02035ee:	32e69463          	bne	a3,a4,ffffffffc0203916 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035f2:	6691                	lui	a3,0x4
ffffffffc02035f4:	4635                	li	a2,13
ffffffffc02035f6:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x55d0>
     assert(pgfault_num==4);
ffffffffc02035fa:	4398                	lw	a4,0(a5)
ffffffffc02035fc:	2701                	sext.w	a4,a4
ffffffffc02035fe:	37871c63          	bne	a4,s8,ffffffffc0203976 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203602:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203606:	439c                	lw	a5,0(a5)
ffffffffc0203608:	2781                	sext.w	a5,a5
ffffffffc020360a:	38e79663          	bne	a5,a4,ffffffffc0203996 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020360e:	481c                	lw	a5,16(s0)
ffffffffc0203610:	40079363          	bnez	a5,ffffffffc0203a16 <swap_init+0x668>
ffffffffc0203614:	000a9797          	auipc	a5,0xa9
ffffffffc0203618:	33478793          	addi	a5,a5,820 # ffffffffc02ac948 <swap_in_seq_no>
ffffffffc020361c:	000a9717          	auipc	a4,0xa9
ffffffffc0203620:	35470713          	addi	a4,a4,852 # ffffffffc02ac970 <swap_out_seq_no>
ffffffffc0203624:	000a9617          	auipc	a2,0xa9
ffffffffc0203628:	34c60613          	addi	a2,a2,844 # ffffffffc02ac970 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020362c:	56fd                	li	a3,-1
ffffffffc020362e:	c394                	sw	a3,0(a5)
ffffffffc0203630:	c314                	sw	a3,0(a4)
ffffffffc0203632:	0791                	addi	a5,a5,4
ffffffffc0203634:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203636:	fef61ce3          	bne	a2,a5,ffffffffc020362e <swap_init+0x280>
ffffffffc020363a:	000a9697          	auipc	a3,0xa9
ffffffffc020363e:	39668693          	addi	a3,a3,918 # ffffffffc02ac9d0 <check_ptep>
ffffffffc0203642:	000a9817          	auipc	a6,0xa9
ffffffffc0203646:	2e680813          	addi	a6,a6,742 # ffffffffc02ac928 <check_rp>
ffffffffc020364a:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020364c:	000a9c97          	auipc	s9,0xa9
ffffffffc0203650:	264c8c93          	addi	s9,s9,612 # ffffffffc02ac8b0 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203654:	00005d97          	auipc	s11,0x5
ffffffffc0203658:	754d8d93          	addi	s11,s11,1876 # ffffffffc0208da8 <nbase>
ffffffffc020365c:	000a9c17          	auipc	s8,0xa9
ffffffffc0203660:	2c4c0c13          	addi	s8,s8,708 # ffffffffc02ac920 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203664:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203668:	4601                	li	a2,0
ffffffffc020366a:	85ea                	mv	a1,s10
ffffffffc020366c:	855a                	mv	a0,s6
ffffffffc020366e:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0203670:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203672:	8c1fe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc0203676:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203678:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020367a:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020367c:	20050163          	beqz	a0,ffffffffc020387e <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203680:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203682:	0017f613          	andi	a2,a5,1
ffffffffc0203686:	1a060063          	beqz	a2,ffffffffc0203826 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc020368a:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020368e:	078a                	slli	a5,a5,0x2
ffffffffc0203690:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203692:	14c7fe63          	bgeu	a5,a2,ffffffffc02037ee <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203696:	000db703          	ld	a4,0(s11)
ffffffffc020369a:	000c3603          	ld	a2,0(s8)
ffffffffc020369e:	00083583          	ld	a1,0(a6)
ffffffffc02036a2:	8f99                	sub	a5,a5,a4
ffffffffc02036a4:	079a                	slli	a5,a5,0x6
ffffffffc02036a6:	e43a                	sd	a4,8(sp)
ffffffffc02036a8:	97b2                	add	a5,a5,a2
ffffffffc02036aa:	14f59e63          	bne	a1,a5,ffffffffc0203806 <swap_init+0x458>
ffffffffc02036ae:	6785                	lui	a5,0x1
ffffffffc02036b0:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036b2:	6795                	lui	a5,0x5
ffffffffc02036b4:	06a1                	addi	a3,a3,8
ffffffffc02036b6:	0821                	addi	a6,a6,8
ffffffffc02036b8:	fafd16e3          	bne	s10,a5,ffffffffc0203664 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02036bc:	00004517          	auipc	a0,0x4
ffffffffc02036c0:	71c50513          	addi	a0,a0,1820 # ffffffffc0207dd8 <default_pmm_manager+0x9c8>
ffffffffc02036c4:	acbfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc02036c8:	000a9797          	auipc	a5,0xa9
ffffffffc02036cc:	1f078793          	addi	a5,a5,496 # ffffffffc02ac8b8 <sm>
ffffffffc02036d0:	639c                	ld	a5,0(a5)
ffffffffc02036d2:	7f9c                	ld	a5,56(a5)
ffffffffc02036d4:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036d6:	40051c63          	bnez	a0,ffffffffc0203aee <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02036da:	77a2                	ld	a5,40(sp)
ffffffffc02036dc:	000a9717          	auipc	a4,0xa9
ffffffffc02036e0:	22f72223          	sw	a5,548(a4) # ffffffffc02ac900 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036e4:	67e2                	ld	a5,24(sp)
ffffffffc02036e6:	000a9717          	auipc	a4,0xa9
ffffffffc02036ea:	20f73523          	sd	a5,522(a4) # ffffffffc02ac8f0 <free_area>
ffffffffc02036ee:	7782                	ld	a5,32(sp)
ffffffffc02036f0:	000a9717          	auipc	a4,0xa9
ffffffffc02036f4:	20f73423          	sd	a5,520(a4) # ffffffffc02ac8f8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036f8:	0009b503          	ld	a0,0(s3)
ffffffffc02036fc:	4585                	li	a1,1
ffffffffc02036fe:	09a1                	addi	s3,s3,8
ffffffffc0203700:	facfe0ef          	jal	ra,ffffffffc0201eac <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203704:	ff499ae3          	bne	s3,s4,ffffffffc02036f8 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203708:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc020370c:	855e                	mv	a0,s7
ffffffffc020370e:	37d000ef          	jal	ra,ffffffffc020428a <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203712:	000a9797          	auipc	a5,0xa9
ffffffffc0203716:	19678793          	addi	a5,a5,406 # ffffffffc02ac8a8 <boot_pgdir>
ffffffffc020371a:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc020371c:	000a9697          	auipc	a3,0xa9
ffffffffc0203720:	2e06b223          	sd	zero,740(a3) # ffffffffc02aca00 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0203724:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203728:	6394                	ld	a3,0(a5)
ffffffffc020372a:	068a                	slli	a3,a3,0x2
ffffffffc020372c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020372e:	0ce6f063          	bgeu	a3,a4,ffffffffc02037ee <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203732:	67a2                	ld	a5,8(sp)
ffffffffc0203734:	000c3503          	ld	a0,0(s8)
ffffffffc0203738:	8e9d                	sub	a3,a3,a5
ffffffffc020373a:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020373c:	8699                	srai	a3,a3,0x6
ffffffffc020373e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0203740:	00c69793          	slli	a5,a3,0xc
ffffffffc0203744:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203746:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203748:	2ee7f763          	bgeu	a5,a4,ffffffffc0203a36 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc020374c:	000a9797          	auipc	a5,0xa9
ffffffffc0203750:	1c478793          	addi	a5,a5,452 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0203754:	639c                	ld	a5,0(a5)
ffffffffc0203756:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203758:	629c                	ld	a5,0(a3)
ffffffffc020375a:	078a                	slli	a5,a5,0x2
ffffffffc020375c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020375e:	08e7f863          	bgeu	a5,a4,ffffffffc02037ee <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203762:	69a2                	ld	s3,8(sp)
ffffffffc0203764:	4585                	li	a1,1
ffffffffc0203766:	413787b3          	sub	a5,a5,s3
ffffffffc020376a:	079a                	slli	a5,a5,0x6
ffffffffc020376c:	953e                	add	a0,a0,a5
ffffffffc020376e:	f3efe0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203772:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203776:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020377a:	078a                	slli	a5,a5,0x2
ffffffffc020377c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020377e:	06e7f863          	bgeu	a5,a4,ffffffffc02037ee <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203782:	000c3503          	ld	a0,0(s8)
ffffffffc0203786:	413787b3          	sub	a5,a5,s3
ffffffffc020378a:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020378c:	4585                	li	a1,1
ffffffffc020378e:	953e                	add	a0,a0,a5
ffffffffc0203790:	f1cfe0ef          	jal	ra,ffffffffc0201eac <free_pages>
     pgdir[0] = 0;
ffffffffc0203794:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203798:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020379c:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020379e:	00878963          	beq	a5,s0,ffffffffc02037b0 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02037a2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02037a6:	679c                	ld	a5,8(a5)
ffffffffc02037a8:	397d                	addiw	s2,s2,-1
ffffffffc02037aa:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037ac:	fe879be3          	bne	a5,s0,ffffffffc02037a2 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc02037b0:	28091f63          	bnez	s2,ffffffffc0203a4e <swap_init+0x6a0>
     assert(total==0);
ffffffffc02037b4:	2a049d63          	bnez	s1,ffffffffc0203a6e <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc02037b8:	00004517          	auipc	a0,0x4
ffffffffc02037bc:	67050513          	addi	a0,a0,1648 # ffffffffc0207e28 <default_pmm_manager+0xa18>
ffffffffc02037c0:	9cffc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02037c4:	b92d                	j	ffffffffc02033fe <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc02037c6:	4481                	li	s1,0
ffffffffc02037c8:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037ca:	4981                	li	s3,0
ffffffffc02037cc:	b17d                	j	ffffffffc020347a <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02037ce:	00004697          	auipc	a3,0x4
ffffffffc02037d2:	8b268693          	addi	a3,a3,-1870 # ffffffffc0207080 <commands+0x878>
ffffffffc02037d6:	00003617          	auipc	a2,0x3
ffffffffc02037da:	4f260613          	addi	a2,a2,1266 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02037de:	0bc00593          	li	a1,188
ffffffffc02037e2:	00004517          	auipc	a0,0x4
ffffffffc02037e6:	3de50513          	addi	a0,a0,990 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc02037ea:	c97fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037ee:	00004617          	auipc	a2,0x4
ffffffffc02037f2:	cd260613          	addi	a2,a2,-814 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc02037f6:	06200593          	li	a1,98
ffffffffc02037fa:	00004517          	auipc	a0,0x4
ffffffffc02037fe:	c8e50513          	addi	a0,a0,-882 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0203802:	c7ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203806:	00004697          	auipc	a3,0x4
ffffffffc020380a:	5aa68693          	addi	a3,a3,1450 # ffffffffc0207db0 <default_pmm_manager+0x9a0>
ffffffffc020380e:	00003617          	auipc	a2,0x3
ffffffffc0203812:	4ba60613          	addi	a2,a2,1210 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203816:	0fc00593          	li	a1,252
ffffffffc020381a:	00004517          	auipc	a0,0x4
ffffffffc020381e:	3a650513          	addi	a0,a0,934 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203822:	c5ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203826:	00004617          	auipc	a2,0x4
ffffffffc020382a:	f0260613          	addi	a2,a2,-254 # ffffffffc0207728 <default_pmm_manager+0x318>
ffffffffc020382e:	07400593          	li	a1,116
ffffffffc0203832:	00004517          	auipc	a0,0x4
ffffffffc0203836:	c5650513          	addi	a0,a0,-938 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc020383a:	c47fc0ef          	jal	ra,ffffffffc0200480 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020383e:	00004697          	auipc	a3,0x4
ffffffffc0203842:	4aa68693          	addi	a3,a3,1194 # ffffffffc0207ce8 <default_pmm_manager+0x8d8>
ffffffffc0203846:	00003617          	auipc	a2,0x3
ffffffffc020384a:	48260613          	addi	a2,a2,1154 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020384e:	0dd00593          	li	a1,221
ffffffffc0203852:	00004517          	auipc	a0,0x4
ffffffffc0203856:	36e50513          	addi	a0,a0,878 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc020385a:	c27fc0ef          	jal	ra,ffffffffc0200480 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020385e:	00004697          	auipc	a3,0x4
ffffffffc0203862:	47268693          	addi	a3,a3,1138 # ffffffffc0207cd0 <default_pmm_manager+0x8c0>
ffffffffc0203866:	00003617          	auipc	a2,0x3
ffffffffc020386a:	46260613          	addi	a2,a2,1122 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020386e:	0dc00593          	li	a1,220
ffffffffc0203872:	00004517          	auipc	a0,0x4
ffffffffc0203876:	34e50513          	addi	a0,a0,846 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc020387a:	c07fc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020387e:	00004697          	auipc	a3,0x4
ffffffffc0203882:	51a68693          	addi	a3,a3,1306 # ffffffffc0207d98 <default_pmm_manager+0x988>
ffffffffc0203886:	00003617          	auipc	a2,0x3
ffffffffc020388a:	44260613          	addi	a2,a2,1090 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020388e:	0fb00593          	li	a1,251
ffffffffc0203892:	00004517          	auipc	a0,0x4
ffffffffc0203896:	32e50513          	addi	a0,a0,814 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc020389a:	be7fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020389e:	00004617          	auipc	a2,0x4
ffffffffc02038a2:	30260613          	addi	a2,a2,770 # ffffffffc0207ba0 <default_pmm_manager+0x790>
ffffffffc02038a6:	02800593          	li	a1,40
ffffffffc02038aa:	00004517          	auipc	a0,0x4
ffffffffc02038ae:	31650513          	addi	a0,a0,790 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc02038b2:	bcffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==2);
ffffffffc02038b6:	00004697          	auipc	a3,0x4
ffffffffc02038ba:	4b268693          	addi	a3,a3,1202 # ffffffffc0207d68 <default_pmm_manager+0x958>
ffffffffc02038be:	00003617          	auipc	a2,0x3
ffffffffc02038c2:	40a60613          	addi	a2,a2,1034 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02038c6:	09700593          	li	a1,151
ffffffffc02038ca:	00004517          	auipc	a0,0x4
ffffffffc02038ce:	2f650513          	addi	a0,a0,758 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc02038d2:	baffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==2);
ffffffffc02038d6:	00004697          	auipc	a3,0x4
ffffffffc02038da:	49268693          	addi	a3,a3,1170 # ffffffffc0207d68 <default_pmm_manager+0x958>
ffffffffc02038de:	00003617          	auipc	a2,0x3
ffffffffc02038e2:	3ea60613          	addi	a2,a2,1002 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02038e6:	09900593          	li	a1,153
ffffffffc02038ea:	00004517          	auipc	a0,0x4
ffffffffc02038ee:	2d650513          	addi	a0,a0,726 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc02038f2:	b8ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==3);
ffffffffc02038f6:	00004697          	auipc	a3,0x4
ffffffffc02038fa:	48268693          	addi	a3,a3,1154 # ffffffffc0207d78 <default_pmm_manager+0x968>
ffffffffc02038fe:	00003617          	auipc	a2,0x3
ffffffffc0203902:	3ca60613          	addi	a2,a2,970 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203906:	09b00593          	li	a1,155
ffffffffc020390a:	00004517          	auipc	a0,0x4
ffffffffc020390e:	2b650513          	addi	a0,a0,694 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203912:	b6ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==3);
ffffffffc0203916:	00004697          	auipc	a3,0x4
ffffffffc020391a:	46268693          	addi	a3,a3,1122 # ffffffffc0207d78 <default_pmm_manager+0x968>
ffffffffc020391e:	00003617          	auipc	a2,0x3
ffffffffc0203922:	3aa60613          	addi	a2,a2,938 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203926:	09d00593          	li	a1,157
ffffffffc020392a:	00004517          	auipc	a0,0x4
ffffffffc020392e:	29650513          	addi	a0,a0,662 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203932:	b4ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==1);
ffffffffc0203936:	00004697          	auipc	a3,0x4
ffffffffc020393a:	42268693          	addi	a3,a3,1058 # ffffffffc0207d58 <default_pmm_manager+0x948>
ffffffffc020393e:	00003617          	auipc	a2,0x3
ffffffffc0203942:	38a60613          	addi	a2,a2,906 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203946:	09300593          	li	a1,147
ffffffffc020394a:	00004517          	auipc	a0,0x4
ffffffffc020394e:	27650513          	addi	a0,a0,630 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203952:	b2ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==1);
ffffffffc0203956:	00004697          	auipc	a3,0x4
ffffffffc020395a:	40268693          	addi	a3,a3,1026 # ffffffffc0207d58 <default_pmm_manager+0x948>
ffffffffc020395e:	00003617          	auipc	a2,0x3
ffffffffc0203962:	36a60613          	addi	a2,a2,874 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203966:	09500593          	li	a1,149
ffffffffc020396a:	00004517          	auipc	a0,0x4
ffffffffc020396e:	25650513          	addi	a0,a0,598 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203972:	b0ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==4);
ffffffffc0203976:	00004697          	auipc	a3,0x4
ffffffffc020397a:	41268693          	addi	a3,a3,1042 # ffffffffc0207d88 <default_pmm_manager+0x978>
ffffffffc020397e:	00003617          	auipc	a2,0x3
ffffffffc0203982:	34a60613          	addi	a2,a2,842 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203986:	09f00593          	li	a1,159
ffffffffc020398a:	00004517          	auipc	a0,0x4
ffffffffc020398e:	23650513          	addi	a0,a0,566 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203992:	aeffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==4);
ffffffffc0203996:	00004697          	auipc	a3,0x4
ffffffffc020399a:	3f268693          	addi	a3,a3,1010 # ffffffffc0207d88 <default_pmm_manager+0x978>
ffffffffc020399e:	00003617          	auipc	a2,0x3
ffffffffc02039a2:	32a60613          	addi	a2,a2,810 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02039a6:	0a100593          	li	a1,161
ffffffffc02039aa:	00004517          	auipc	a0,0x4
ffffffffc02039ae:	21650513          	addi	a0,a0,534 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc02039b2:	acffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02039b6:	00004697          	auipc	a3,0x4
ffffffffc02039ba:	28268693          	addi	a3,a3,642 # ffffffffc0207c38 <default_pmm_manager+0x828>
ffffffffc02039be:	00003617          	auipc	a2,0x3
ffffffffc02039c2:	30a60613          	addi	a2,a2,778 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02039c6:	0cc00593          	li	a1,204
ffffffffc02039ca:	00004517          	auipc	a0,0x4
ffffffffc02039ce:	1f650513          	addi	a0,a0,502 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc02039d2:	aaffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(vma != NULL);
ffffffffc02039d6:	00004697          	auipc	a3,0x4
ffffffffc02039da:	27268693          	addi	a3,a3,626 # ffffffffc0207c48 <default_pmm_manager+0x838>
ffffffffc02039de:	00003617          	auipc	a2,0x3
ffffffffc02039e2:	2ea60613          	addi	a2,a2,746 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02039e6:	0cf00593          	li	a1,207
ffffffffc02039ea:	00004517          	auipc	a0,0x4
ffffffffc02039ee:	1d650513          	addi	a0,a0,470 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc02039f2:	a8ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039f6:	00004697          	auipc	a3,0x4
ffffffffc02039fa:	29a68693          	addi	a3,a3,666 # ffffffffc0207c90 <default_pmm_manager+0x880>
ffffffffc02039fe:	00003617          	auipc	a2,0x3
ffffffffc0203a02:	2ca60613          	addi	a2,a2,714 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203a06:	0d700593          	li	a1,215
ffffffffc0203a0a:	00004517          	auipc	a0,0x4
ffffffffc0203a0e:	1b650513          	addi	a0,a0,438 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203a12:	a6ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert( nr_free == 0);         
ffffffffc0203a16:	00004697          	auipc	a3,0x4
ffffffffc0203a1a:	83a68693          	addi	a3,a3,-1990 # ffffffffc0207250 <commands+0xa48>
ffffffffc0203a1e:	00003617          	auipc	a2,0x3
ffffffffc0203a22:	2aa60613          	addi	a2,a2,682 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203a26:	0f300593          	li	a1,243
ffffffffc0203a2a:	00004517          	auipc	a0,0x4
ffffffffc0203a2e:	19650513          	addi	a0,a0,406 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203a32:	a4ffc0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a36:	00004617          	auipc	a2,0x4
ffffffffc0203a3a:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0203a3e:	06900593          	li	a1,105
ffffffffc0203a42:	00004517          	auipc	a0,0x4
ffffffffc0203a46:	a4650513          	addi	a0,a0,-1466 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0203a4a:	a37fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(count==0);
ffffffffc0203a4e:	00004697          	auipc	a3,0x4
ffffffffc0203a52:	3ba68693          	addi	a3,a3,954 # ffffffffc0207e08 <default_pmm_manager+0x9f8>
ffffffffc0203a56:	00003617          	auipc	a2,0x3
ffffffffc0203a5a:	27260613          	addi	a2,a2,626 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203a5e:	11d00593          	li	a1,285
ffffffffc0203a62:	00004517          	auipc	a0,0x4
ffffffffc0203a66:	15e50513          	addi	a0,a0,350 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203a6a:	a17fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(total==0);
ffffffffc0203a6e:	00004697          	auipc	a3,0x4
ffffffffc0203a72:	3aa68693          	addi	a3,a3,938 # ffffffffc0207e18 <default_pmm_manager+0xa08>
ffffffffc0203a76:	00003617          	auipc	a2,0x3
ffffffffc0203a7a:	25260613          	addi	a2,a2,594 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203a7e:	11e00593          	li	a1,286
ffffffffc0203a82:	00004517          	auipc	a0,0x4
ffffffffc0203a86:	13e50513          	addi	a0,a0,318 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203a8a:	9f7fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a8e:	00004697          	auipc	a3,0x4
ffffffffc0203a92:	27a68693          	addi	a3,a3,634 # ffffffffc0207d08 <default_pmm_manager+0x8f8>
ffffffffc0203a96:	00003617          	auipc	a2,0x3
ffffffffc0203a9a:	23260613          	addi	a2,a2,562 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203a9e:	0ea00593          	li	a1,234
ffffffffc0203aa2:	00004517          	auipc	a0,0x4
ffffffffc0203aa6:	11e50513          	addi	a0,a0,286 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203aaa:	9d7fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(mm != NULL);
ffffffffc0203aae:	00004697          	auipc	a3,0x4
ffffffffc0203ab2:	16268693          	addi	a3,a3,354 # ffffffffc0207c10 <default_pmm_manager+0x800>
ffffffffc0203ab6:	00003617          	auipc	a2,0x3
ffffffffc0203aba:	21260613          	addi	a2,a2,530 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203abe:	0c400593          	li	a1,196
ffffffffc0203ac2:	00004517          	auipc	a0,0x4
ffffffffc0203ac6:	0fe50513          	addi	a0,a0,254 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203aca:	9b7fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203ace:	00004697          	auipc	a3,0x4
ffffffffc0203ad2:	15268693          	addi	a3,a3,338 # ffffffffc0207c20 <default_pmm_manager+0x810>
ffffffffc0203ad6:	00003617          	auipc	a2,0x3
ffffffffc0203ada:	1f260613          	addi	a2,a2,498 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203ade:	0c700593          	li	a1,199
ffffffffc0203ae2:	00004517          	auipc	a0,0x4
ffffffffc0203ae6:	0de50513          	addi	a0,a0,222 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203aea:	997fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(ret==0);
ffffffffc0203aee:	00004697          	auipc	a3,0x4
ffffffffc0203af2:	31268693          	addi	a3,a3,786 # ffffffffc0207e00 <default_pmm_manager+0x9f0>
ffffffffc0203af6:	00003617          	auipc	a2,0x3
ffffffffc0203afa:	1d260613          	addi	a2,a2,466 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203afe:	10200593          	li	a1,258
ffffffffc0203b02:	00004517          	auipc	a0,0x4
ffffffffc0203b06:	0be50513          	addi	a0,a0,190 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203b0a:	977fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203b0e:	00003697          	auipc	a3,0x3
ffffffffc0203b12:	59a68693          	addi	a3,a3,1434 # ffffffffc02070a8 <commands+0x8a0>
ffffffffc0203b16:	00003617          	auipc	a2,0x3
ffffffffc0203b1a:	1b260613          	addi	a2,a2,434 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203b1e:	0bf00593          	li	a1,191
ffffffffc0203b22:	00004517          	auipc	a0,0x4
ffffffffc0203b26:	09e50513          	addi	a0,a0,158 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203b2a:	957fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203b2e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b2e:	000a9797          	auipc	a5,0xa9
ffffffffc0203b32:	d8a78793          	addi	a5,a5,-630 # ffffffffc02ac8b8 <sm>
ffffffffc0203b36:	639c                	ld	a5,0(a5)
ffffffffc0203b38:	0107b303          	ld	t1,16(a5)
ffffffffc0203b3c:	8302                	jr	t1

ffffffffc0203b3e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b3e:	000a9797          	auipc	a5,0xa9
ffffffffc0203b42:	d7a78793          	addi	a5,a5,-646 # ffffffffc02ac8b8 <sm>
ffffffffc0203b46:	639c                	ld	a5,0(a5)
ffffffffc0203b48:	0207b303          	ld	t1,32(a5)
ffffffffc0203b4c:	8302                	jr	t1

ffffffffc0203b4e <swap_out>:
{
ffffffffc0203b4e:	711d                	addi	sp,sp,-96
ffffffffc0203b50:	ec86                	sd	ra,88(sp)
ffffffffc0203b52:	e8a2                	sd	s0,80(sp)
ffffffffc0203b54:	e4a6                	sd	s1,72(sp)
ffffffffc0203b56:	e0ca                	sd	s2,64(sp)
ffffffffc0203b58:	fc4e                	sd	s3,56(sp)
ffffffffc0203b5a:	f852                	sd	s4,48(sp)
ffffffffc0203b5c:	f456                	sd	s5,40(sp)
ffffffffc0203b5e:	f05a                	sd	s6,32(sp)
ffffffffc0203b60:	ec5e                	sd	s7,24(sp)
ffffffffc0203b62:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b64:	cde9                	beqz	a1,ffffffffc0203c3e <swap_out+0xf0>
ffffffffc0203b66:	8ab2                	mv	s5,a2
ffffffffc0203b68:	892a                	mv	s2,a0
ffffffffc0203b6a:	8a2e                	mv	s4,a1
ffffffffc0203b6c:	4401                	li	s0,0
ffffffffc0203b6e:	000a9997          	auipc	s3,0xa9
ffffffffc0203b72:	d4a98993          	addi	s3,s3,-694 # ffffffffc02ac8b8 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b76:	00004b17          	auipc	s6,0x4
ffffffffc0203b7a:	332b0b13          	addi	s6,s6,818 # ffffffffc0207ea8 <default_pmm_manager+0xa98>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b7e:	00004b97          	auipc	s7,0x4
ffffffffc0203b82:	312b8b93          	addi	s7,s7,786 # ffffffffc0207e90 <default_pmm_manager+0xa80>
ffffffffc0203b86:	a825                	j	ffffffffc0203bbe <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b88:	67a2                	ld	a5,8(sp)
ffffffffc0203b8a:	8626                	mv	a2,s1
ffffffffc0203b8c:	85a2                	mv	a1,s0
ffffffffc0203b8e:	7f94                	ld	a3,56(a5)
ffffffffc0203b90:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b92:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b94:	82b1                	srli	a3,a3,0xc
ffffffffc0203b96:	0685                	addi	a3,a3,1
ffffffffc0203b98:	df6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b9c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b9e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203ba0:	7d1c                	ld	a5,56(a0)
ffffffffc0203ba2:	83b1                	srli	a5,a5,0xc
ffffffffc0203ba4:	0785                	addi	a5,a5,1
ffffffffc0203ba6:	07a2                	slli	a5,a5,0x8
ffffffffc0203ba8:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203bac:	b00fe0ef          	jal	ra,ffffffffc0201eac <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203bb0:	01893503          	ld	a0,24(s2)
ffffffffc0203bb4:	85a6                	mv	a1,s1
ffffffffc0203bb6:	f5eff0ef          	jal	ra,ffffffffc0203314 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203bba:	048a0d63          	beq	s4,s0,ffffffffc0203c14 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203bbe:	0009b783          	ld	a5,0(s3)
ffffffffc0203bc2:	8656                	mv	a2,s5
ffffffffc0203bc4:	002c                	addi	a1,sp,8
ffffffffc0203bc6:	7b9c                	ld	a5,48(a5)
ffffffffc0203bc8:	854a                	mv	a0,s2
ffffffffc0203bca:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203bcc:	e12d                	bnez	a0,ffffffffc0203c2e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203bce:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bd0:	01893503          	ld	a0,24(s2)
ffffffffc0203bd4:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203bd6:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bd8:	85a6                	mv	a1,s1
ffffffffc0203bda:	b58fe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bde:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203be0:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203be2:	8b85                	andi	a5,a5,1
ffffffffc0203be4:	cfb9                	beqz	a5,ffffffffc0203c42 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203be6:	65a2                	ld	a1,8(sp)
ffffffffc0203be8:	7d9c                	ld	a5,56(a1)
ffffffffc0203bea:	83b1                	srli	a5,a5,0xc
ffffffffc0203bec:	00178513          	addi	a0,a5,1
ffffffffc0203bf0:	0522                	slli	a0,a0,0x8
ffffffffc0203bf2:	106010ef          	jal	ra,ffffffffc0204cf8 <swapfs_write>
ffffffffc0203bf6:	d949                	beqz	a0,ffffffffc0203b88 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bf8:	855e                	mv	a0,s7
ffffffffc0203bfa:	d94fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bfe:	0009b783          	ld	a5,0(s3)
ffffffffc0203c02:	6622                	ld	a2,8(sp)
ffffffffc0203c04:	4681                	li	a3,0
ffffffffc0203c06:	739c                	ld	a5,32(a5)
ffffffffc0203c08:	85a6                	mv	a1,s1
ffffffffc0203c0a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203c0c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c0e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203c10:	fa8a17e3          	bne	s4,s0,ffffffffc0203bbe <swap_out+0x70>
}
ffffffffc0203c14:	8522                	mv	a0,s0
ffffffffc0203c16:	60e6                	ld	ra,88(sp)
ffffffffc0203c18:	6446                	ld	s0,80(sp)
ffffffffc0203c1a:	64a6                	ld	s1,72(sp)
ffffffffc0203c1c:	6906                	ld	s2,64(sp)
ffffffffc0203c1e:	79e2                	ld	s3,56(sp)
ffffffffc0203c20:	7a42                	ld	s4,48(sp)
ffffffffc0203c22:	7aa2                	ld	s5,40(sp)
ffffffffc0203c24:	7b02                	ld	s6,32(sp)
ffffffffc0203c26:	6be2                	ld	s7,24(sp)
ffffffffc0203c28:	6c42                	ld	s8,16(sp)
ffffffffc0203c2a:	6125                	addi	sp,sp,96
ffffffffc0203c2c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203c2e:	85a2                	mv	a1,s0
ffffffffc0203c30:	00004517          	auipc	a0,0x4
ffffffffc0203c34:	21850513          	addi	a0,a0,536 # ffffffffc0207e48 <default_pmm_manager+0xa38>
ffffffffc0203c38:	d56fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203c3c:	bfe1                	j	ffffffffc0203c14 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c3e:	4401                	li	s0,0
ffffffffc0203c40:	bfd1                	j	ffffffffc0203c14 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c42:	00004697          	auipc	a3,0x4
ffffffffc0203c46:	23668693          	addi	a3,a3,566 # ffffffffc0207e78 <default_pmm_manager+0xa68>
ffffffffc0203c4a:	00003617          	auipc	a2,0x3
ffffffffc0203c4e:	07e60613          	addi	a2,a2,126 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203c52:	06800593          	li	a1,104
ffffffffc0203c56:	00004517          	auipc	a0,0x4
ffffffffc0203c5a:	f6a50513          	addi	a0,a0,-150 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203c5e:	823fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203c62 <swap_in>:
{
ffffffffc0203c62:	7179                	addi	sp,sp,-48
ffffffffc0203c64:	e84a                	sd	s2,16(sp)
ffffffffc0203c66:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c68:	4505                	li	a0,1
{
ffffffffc0203c6a:	ec26                	sd	s1,24(sp)
ffffffffc0203c6c:	e44e                	sd	s3,8(sp)
ffffffffc0203c6e:	f406                	sd	ra,40(sp)
ffffffffc0203c70:	f022                	sd	s0,32(sp)
ffffffffc0203c72:	84ae                	mv	s1,a1
ffffffffc0203c74:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c76:	9aefe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c7a:	c129                	beqz	a0,ffffffffc0203cbc <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c7c:	842a                	mv	s0,a0
ffffffffc0203c7e:	01893503          	ld	a0,24(s2)
ffffffffc0203c82:	4601                	li	a2,0
ffffffffc0203c84:	85a6                	mv	a1,s1
ffffffffc0203c86:	aacfe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc0203c8a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c8c:	6108                	ld	a0,0(a0)
ffffffffc0203c8e:	85a2                	mv	a1,s0
ffffffffc0203c90:	7d1000ef          	jal	ra,ffffffffc0204c60 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c94:	00093583          	ld	a1,0(s2)
ffffffffc0203c98:	8626                	mv	a2,s1
ffffffffc0203c9a:	00004517          	auipc	a0,0x4
ffffffffc0203c9e:	ec650513          	addi	a0,a0,-314 # ffffffffc0207b60 <default_pmm_manager+0x750>
ffffffffc0203ca2:	81a1                	srli	a1,a1,0x8
ffffffffc0203ca4:	ceafc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203ca8:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203caa:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203cae:	7402                	ld	s0,32(sp)
ffffffffc0203cb0:	64e2                	ld	s1,24(sp)
ffffffffc0203cb2:	6942                	ld	s2,16(sp)
ffffffffc0203cb4:	69a2                	ld	s3,8(sp)
ffffffffc0203cb6:	4501                	li	a0,0
ffffffffc0203cb8:	6145                	addi	sp,sp,48
ffffffffc0203cba:	8082                	ret
     assert(result!=NULL);
ffffffffc0203cbc:	00004697          	auipc	a3,0x4
ffffffffc0203cc0:	e9468693          	addi	a3,a3,-364 # ffffffffc0207b50 <default_pmm_manager+0x740>
ffffffffc0203cc4:	00003617          	auipc	a2,0x3
ffffffffc0203cc8:	00460613          	addi	a2,a2,4 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203ccc:	07e00593          	li	a1,126
ffffffffc0203cd0:	00004517          	auipc	a0,0x4
ffffffffc0203cd4:	ef050513          	addi	a0,a0,-272 # ffffffffc0207bc0 <default_pmm_manager+0x7b0>
ffffffffc0203cd8:	fa8fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203cdc <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203cdc:	000a9797          	auipc	a5,0xa9
ffffffffc0203ce0:	d1478793          	addi	a5,a5,-748 # ffffffffc02ac9f0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203ce4:	f51c                	sd	a5,40(a0)
ffffffffc0203ce6:	e79c                	sd	a5,8(a5)
ffffffffc0203ce8:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203cea:	4501                	li	a0,0
ffffffffc0203cec:	8082                	ret

ffffffffc0203cee <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203cee:	4501                	li	a0,0
ffffffffc0203cf0:	8082                	ret

ffffffffc0203cf2 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cf2:	4501                	li	a0,0
ffffffffc0203cf4:	8082                	ret

ffffffffc0203cf6 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203cf6:	4501                	li	a0,0
ffffffffc0203cf8:	8082                	ret

ffffffffc0203cfa <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203cfa:	711d                	addi	sp,sp,-96
ffffffffc0203cfc:	fc4e                	sd	s3,56(sp)
ffffffffc0203cfe:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d00:	00004517          	auipc	a0,0x4
ffffffffc0203d04:	1e850513          	addi	a0,a0,488 # ffffffffc0207ee8 <default_pmm_manager+0xad8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d08:	698d                	lui	s3,0x3
ffffffffc0203d0a:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203d0c:	e8a2                	sd	s0,80(sp)
ffffffffc0203d0e:	e4a6                	sd	s1,72(sp)
ffffffffc0203d10:	ec86                	sd	ra,88(sp)
ffffffffc0203d12:	e0ca                	sd	s2,64(sp)
ffffffffc0203d14:	f456                	sd	s5,40(sp)
ffffffffc0203d16:	f05a                	sd	s6,32(sp)
ffffffffc0203d18:	ec5e                	sd	s7,24(sp)
ffffffffc0203d1a:	e862                	sd	s8,16(sp)
ffffffffc0203d1c:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203d1e:	000a9417          	auipc	s0,0xa9
ffffffffc0203d22:	ba640413          	addi	s0,s0,-1114 # ffffffffc02ac8c4 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d26:	c68fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d2a:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x65d0>
    assert(pgfault_num==4);
ffffffffc0203d2e:	4004                	lw	s1,0(s0)
ffffffffc0203d30:	4791                	li	a5,4
ffffffffc0203d32:	2481                	sext.w	s1,s1
ffffffffc0203d34:	14f49963          	bne	s1,a5,ffffffffc0203e86 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d38:	00004517          	auipc	a0,0x4
ffffffffc0203d3c:	1f050513          	addi	a0,a0,496 # ffffffffc0207f28 <default_pmm_manager+0xb18>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d40:	6a85                	lui	s5,0x1
ffffffffc0203d42:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d44:	c4afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d48:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85d0>
    assert(pgfault_num==4);
ffffffffc0203d4c:	00042903          	lw	s2,0(s0)
ffffffffc0203d50:	2901                	sext.w	s2,s2
ffffffffc0203d52:	2a991a63          	bne	s2,s1,ffffffffc0204006 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d56:	00004517          	auipc	a0,0x4
ffffffffc0203d5a:	1fa50513          	addi	a0,a0,506 # ffffffffc0207f50 <default_pmm_manager+0xb40>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d5e:	6b91                	lui	s7,0x4
ffffffffc0203d60:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d62:	c2cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d66:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x55d0>
    assert(pgfault_num==4);
ffffffffc0203d6a:	4004                	lw	s1,0(s0)
ffffffffc0203d6c:	2481                	sext.w	s1,s1
ffffffffc0203d6e:	27249c63          	bne	s1,s2,ffffffffc0203fe6 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d72:	00004517          	auipc	a0,0x4
ffffffffc0203d76:	20650513          	addi	a0,a0,518 # ffffffffc0207f78 <default_pmm_manager+0xb68>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d7a:	6909                	lui	s2,0x2
ffffffffc0203d7c:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d7e:	c10fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d82:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x75d0>
    assert(pgfault_num==4);
ffffffffc0203d86:	401c                	lw	a5,0(s0)
ffffffffc0203d88:	2781                	sext.w	a5,a5
ffffffffc0203d8a:	22979e63          	bne	a5,s1,ffffffffc0203fc6 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d8e:	00004517          	auipc	a0,0x4
ffffffffc0203d92:	21250513          	addi	a0,a0,530 # ffffffffc0207fa0 <default_pmm_manager+0xb90>
ffffffffc0203d96:	bf8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d9a:	6795                	lui	a5,0x5
ffffffffc0203d9c:	4739                	li	a4,14
ffffffffc0203d9e:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45d0>
    assert(pgfault_num==5);
ffffffffc0203da2:	4004                	lw	s1,0(s0)
ffffffffc0203da4:	4795                	li	a5,5
ffffffffc0203da6:	2481                	sext.w	s1,s1
ffffffffc0203da8:	1ef49f63          	bne	s1,a5,ffffffffc0203fa6 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dac:	00004517          	auipc	a0,0x4
ffffffffc0203db0:	1cc50513          	addi	a0,a0,460 # ffffffffc0207f78 <default_pmm_manager+0xb68>
ffffffffc0203db4:	bdafc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203db8:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203dbc:	401c                	lw	a5,0(s0)
ffffffffc0203dbe:	2781                	sext.w	a5,a5
ffffffffc0203dc0:	1c979363          	bne	a5,s1,ffffffffc0203f86 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dc4:	00004517          	auipc	a0,0x4
ffffffffc0203dc8:	16450513          	addi	a0,a0,356 # ffffffffc0207f28 <default_pmm_manager+0xb18>
ffffffffc0203dcc:	bc2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203dd0:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203dd4:	401c                	lw	a5,0(s0)
ffffffffc0203dd6:	4719                	li	a4,6
ffffffffc0203dd8:	2781                	sext.w	a5,a5
ffffffffc0203dda:	18e79663          	bne	a5,a4,ffffffffc0203f66 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dde:	00004517          	auipc	a0,0x4
ffffffffc0203de2:	19a50513          	addi	a0,a0,410 # ffffffffc0207f78 <default_pmm_manager+0xb68>
ffffffffc0203de6:	ba8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dea:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203dee:	401c                	lw	a5,0(s0)
ffffffffc0203df0:	471d                	li	a4,7
ffffffffc0203df2:	2781                	sext.w	a5,a5
ffffffffc0203df4:	14e79963          	bne	a5,a4,ffffffffc0203f46 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203df8:	00004517          	auipc	a0,0x4
ffffffffc0203dfc:	0f050513          	addi	a0,a0,240 # ffffffffc0207ee8 <default_pmm_manager+0xad8>
ffffffffc0203e00:	b8efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203e04:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203e08:	401c                	lw	a5,0(s0)
ffffffffc0203e0a:	4721                	li	a4,8
ffffffffc0203e0c:	2781                	sext.w	a5,a5
ffffffffc0203e0e:	10e79c63          	bne	a5,a4,ffffffffc0203f26 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e12:	00004517          	auipc	a0,0x4
ffffffffc0203e16:	13e50513          	addi	a0,a0,318 # ffffffffc0207f50 <default_pmm_manager+0xb40>
ffffffffc0203e1a:	b74fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e1e:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203e22:	401c                	lw	a5,0(s0)
ffffffffc0203e24:	4725                	li	a4,9
ffffffffc0203e26:	2781                	sext.w	a5,a5
ffffffffc0203e28:	0ce79f63          	bne	a5,a4,ffffffffc0203f06 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e2c:	00004517          	auipc	a0,0x4
ffffffffc0203e30:	17450513          	addi	a0,a0,372 # ffffffffc0207fa0 <default_pmm_manager+0xb90>
ffffffffc0203e34:	b5afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e38:	6795                	lui	a5,0x5
ffffffffc0203e3a:	4739                	li	a4,14
ffffffffc0203e3c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45d0>
    assert(pgfault_num==10);
ffffffffc0203e40:	4004                	lw	s1,0(s0)
ffffffffc0203e42:	47a9                	li	a5,10
ffffffffc0203e44:	2481                	sext.w	s1,s1
ffffffffc0203e46:	0af49063          	bne	s1,a5,ffffffffc0203ee6 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e4a:	00004517          	auipc	a0,0x4
ffffffffc0203e4e:	0de50513          	addi	a0,a0,222 # ffffffffc0207f28 <default_pmm_manager+0xb18>
ffffffffc0203e52:	b3cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e56:	6785                	lui	a5,0x1
ffffffffc0203e58:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x85d0>
ffffffffc0203e5c:	06979563          	bne	a5,s1,ffffffffc0203ec6 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203e60:	401c                	lw	a5,0(s0)
ffffffffc0203e62:	472d                	li	a4,11
ffffffffc0203e64:	2781                	sext.w	a5,a5
ffffffffc0203e66:	04e79063          	bne	a5,a4,ffffffffc0203ea6 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e6a:	60e6                	ld	ra,88(sp)
ffffffffc0203e6c:	6446                	ld	s0,80(sp)
ffffffffc0203e6e:	64a6                	ld	s1,72(sp)
ffffffffc0203e70:	6906                	ld	s2,64(sp)
ffffffffc0203e72:	79e2                	ld	s3,56(sp)
ffffffffc0203e74:	7a42                	ld	s4,48(sp)
ffffffffc0203e76:	7aa2                	ld	s5,40(sp)
ffffffffc0203e78:	7b02                	ld	s6,32(sp)
ffffffffc0203e7a:	6be2                	ld	s7,24(sp)
ffffffffc0203e7c:	6c42                	ld	s8,16(sp)
ffffffffc0203e7e:	6ca2                	ld	s9,8(sp)
ffffffffc0203e80:	4501                	li	a0,0
ffffffffc0203e82:	6125                	addi	sp,sp,96
ffffffffc0203e84:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e86:	00004697          	auipc	a3,0x4
ffffffffc0203e8a:	f0268693          	addi	a3,a3,-254 # ffffffffc0207d88 <default_pmm_manager+0x978>
ffffffffc0203e8e:	00003617          	auipc	a2,0x3
ffffffffc0203e92:	e3a60613          	addi	a2,a2,-454 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203e96:	05100593          	li	a1,81
ffffffffc0203e9a:	00004517          	auipc	a0,0x4
ffffffffc0203e9e:	07650513          	addi	a0,a0,118 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203ea2:	ddefc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==11);
ffffffffc0203ea6:	00004697          	auipc	a3,0x4
ffffffffc0203eaa:	1aa68693          	addi	a3,a3,426 # ffffffffc0208050 <default_pmm_manager+0xc40>
ffffffffc0203eae:	00003617          	auipc	a2,0x3
ffffffffc0203eb2:	e1a60613          	addi	a2,a2,-486 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203eb6:	07300593          	li	a1,115
ffffffffc0203eba:	00004517          	auipc	a0,0x4
ffffffffc0203ebe:	05650513          	addi	a0,a0,86 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203ec2:	dbefc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203ec6:	00004697          	auipc	a3,0x4
ffffffffc0203eca:	16268693          	addi	a3,a3,354 # ffffffffc0208028 <default_pmm_manager+0xc18>
ffffffffc0203ece:	00003617          	auipc	a2,0x3
ffffffffc0203ed2:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203ed6:	07100593          	li	a1,113
ffffffffc0203eda:	00004517          	auipc	a0,0x4
ffffffffc0203ede:	03650513          	addi	a0,a0,54 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203ee2:	d9efc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==10);
ffffffffc0203ee6:	00004697          	auipc	a3,0x4
ffffffffc0203eea:	13268693          	addi	a3,a3,306 # ffffffffc0208018 <default_pmm_manager+0xc08>
ffffffffc0203eee:	00003617          	auipc	a2,0x3
ffffffffc0203ef2:	dda60613          	addi	a2,a2,-550 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203ef6:	06f00593          	li	a1,111
ffffffffc0203efa:	00004517          	auipc	a0,0x4
ffffffffc0203efe:	01650513          	addi	a0,a0,22 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203f02:	d7efc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==9);
ffffffffc0203f06:	00004697          	auipc	a3,0x4
ffffffffc0203f0a:	10268693          	addi	a3,a3,258 # ffffffffc0208008 <default_pmm_manager+0xbf8>
ffffffffc0203f0e:	00003617          	auipc	a2,0x3
ffffffffc0203f12:	dba60613          	addi	a2,a2,-582 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203f16:	06c00593          	li	a1,108
ffffffffc0203f1a:	00004517          	auipc	a0,0x4
ffffffffc0203f1e:	ff650513          	addi	a0,a0,-10 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203f22:	d5efc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==8);
ffffffffc0203f26:	00004697          	auipc	a3,0x4
ffffffffc0203f2a:	0d268693          	addi	a3,a3,210 # ffffffffc0207ff8 <default_pmm_manager+0xbe8>
ffffffffc0203f2e:	00003617          	auipc	a2,0x3
ffffffffc0203f32:	d9a60613          	addi	a2,a2,-614 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203f36:	06900593          	li	a1,105
ffffffffc0203f3a:	00004517          	auipc	a0,0x4
ffffffffc0203f3e:	fd650513          	addi	a0,a0,-42 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203f42:	d3efc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==7);
ffffffffc0203f46:	00004697          	auipc	a3,0x4
ffffffffc0203f4a:	0a268693          	addi	a3,a3,162 # ffffffffc0207fe8 <default_pmm_manager+0xbd8>
ffffffffc0203f4e:	00003617          	auipc	a2,0x3
ffffffffc0203f52:	d7a60613          	addi	a2,a2,-646 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203f56:	06600593          	li	a1,102
ffffffffc0203f5a:	00004517          	auipc	a0,0x4
ffffffffc0203f5e:	fb650513          	addi	a0,a0,-74 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203f62:	d1efc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==6);
ffffffffc0203f66:	00004697          	auipc	a3,0x4
ffffffffc0203f6a:	07268693          	addi	a3,a3,114 # ffffffffc0207fd8 <default_pmm_manager+0xbc8>
ffffffffc0203f6e:	00003617          	auipc	a2,0x3
ffffffffc0203f72:	d5a60613          	addi	a2,a2,-678 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203f76:	06300593          	li	a1,99
ffffffffc0203f7a:	00004517          	auipc	a0,0x4
ffffffffc0203f7e:	f9650513          	addi	a0,a0,-106 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203f82:	cfefc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f86:	00004697          	auipc	a3,0x4
ffffffffc0203f8a:	04268693          	addi	a3,a3,66 # ffffffffc0207fc8 <default_pmm_manager+0xbb8>
ffffffffc0203f8e:	00003617          	auipc	a2,0x3
ffffffffc0203f92:	d3a60613          	addi	a2,a2,-710 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203f96:	06000593          	li	a1,96
ffffffffc0203f9a:	00004517          	auipc	a0,0x4
ffffffffc0203f9e:	f7650513          	addi	a0,a0,-138 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203fa2:	cdefc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==5);
ffffffffc0203fa6:	00004697          	auipc	a3,0x4
ffffffffc0203faa:	02268693          	addi	a3,a3,34 # ffffffffc0207fc8 <default_pmm_manager+0xbb8>
ffffffffc0203fae:	00003617          	auipc	a2,0x3
ffffffffc0203fb2:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203fb6:	05d00593          	li	a1,93
ffffffffc0203fba:	00004517          	auipc	a0,0x4
ffffffffc0203fbe:	f5650513          	addi	a0,a0,-170 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203fc2:	cbefc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fc6:	00004697          	auipc	a3,0x4
ffffffffc0203fca:	dc268693          	addi	a3,a3,-574 # ffffffffc0207d88 <default_pmm_manager+0x978>
ffffffffc0203fce:	00003617          	auipc	a2,0x3
ffffffffc0203fd2:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203fd6:	05a00593          	li	a1,90
ffffffffc0203fda:	00004517          	auipc	a0,0x4
ffffffffc0203fde:	f3650513          	addi	a0,a0,-202 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0203fe2:	c9efc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fe6:	00004697          	auipc	a3,0x4
ffffffffc0203fea:	da268693          	addi	a3,a3,-606 # ffffffffc0207d88 <default_pmm_manager+0x978>
ffffffffc0203fee:	00003617          	auipc	a2,0x3
ffffffffc0203ff2:	cda60613          	addi	a2,a2,-806 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0203ff6:	05700593          	li	a1,87
ffffffffc0203ffa:	00004517          	auipc	a0,0x4
ffffffffc0203ffe:	f1650513          	addi	a0,a0,-234 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0204002:	c7efc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0204006:	00004697          	auipc	a3,0x4
ffffffffc020400a:	d8268693          	addi	a3,a3,-638 # ffffffffc0207d88 <default_pmm_manager+0x978>
ffffffffc020400e:	00003617          	auipc	a2,0x3
ffffffffc0204012:	cba60613          	addi	a2,a2,-838 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204016:	05400593          	li	a1,84
ffffffffc020401a:	00004517          	auipc	a0,0x4
ffffffffc020401e:	ef650513          	addi	a0,a0,-266 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0204022:	c5efc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204026 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204026:	751c                	ld	a5,40(a0)
{
ffffffffc0204028:	1141                	addi	sp,sp,-16
ffffffffc020402a:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020402c:	cf91                	beqz	a5,ffffffffc0204048 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc020402e:	ee0d                	bnez	a2,ffffffffc0204068 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0204030:	679c                	ld	a5,8(a5)
}
ffffffffc0204032:	60a2                	ld	ra,8(sp)
ffffffffc0204034:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204036:	6394                	ld	a3,0(a5)
ffffffffc0204038:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc020403a:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020403e:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204040:	e314                	sd	a3,0(a4)
ffffffffc0204042:	e19c                	sd	a5,0(a1)
}
ffffffffc0204044:	0141                	addi	sp,sp,16
ffffffffc0204046:	8082                	ret
         assert(head != NULL);
ffffffffc0204048:	00004697          	auipc	a3,0x4
ffffffffc020404c:	03868693          	addi	a3,a3,56 # ffffffffc0208080 <default_pmm_manager+0xc70>
ffffffffc0204050:	00003617          	auipc	a2,0x3
ffffffffc0204054:	c7860613          	addi	a2,a2,-904 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204058:	04100593          	li	a1,65
ffffffffc020405c:	00004517          	auipc	a0,0x4
ffffffffc0204060:	eb450513          	addi	a0,a0,-332 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0204064:	c1cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(in_tick==0);
ffffffffc0204068:	00004697          	auipc	a3,0x4
ffffffffc020406c:	02868693          	addi	a3,a3,40 # ffffffffc0208090 <default_pmm_manager+0xc80>
ffffffffc0204070:	00003617          	auipc	a2,0x3
ffffffffc0204074:	c5860613          	addi	a2,a2,-936 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204078:	04200593          	li	a1,66
ffffffffc020407c:	00004517          	auipc	a0,0x4
ffffffffc0204080:	e9450513          	addi	a0,a0,-364 # ffffffffc0207f10 <default_pmm_manager+0xb00>
ffffffffc0204084:	bfcfc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204088 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204088:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020408c:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020408e:	cb09                	beqz	a4,ffffffffc02040a0 <_fifo_map_swappable+0x18>
ffffffffc0204090:	cb81                	beqz	a5,ffffffffc02040a0 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204092:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204094:	e398                	sd	a4,0(a5)
}
ffffffffc0204096:	4501                	li	a0,0
ffffffffc0204098:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc020409a:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020409c:	f614                	sd	a3,40(a2)
ffffffffc020409e:	8082                	ret
{
ffffffffc02040a0:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02040a2:	00004697          	auipc	a3,0x4
ffffffffc02040a6:	fbe68693          	addi	a3,a3,-66 # ffffffffc0208060 <default_pmm_manager+0xc50>
ffffffffc02040aa:	00003617          	auipc	a2,0x3
ffffffffc02040ae:	c1e60613          	addi	a2,a2,-994 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02040b2:	03200593          	li	a1,50
ffffffffc02040b6:	00004517          	auipc	a0,0x4
ffffffffc02040ba:	e5a50513          	addi	a0,a0,-422 # ffffffffc0207f10 <default_pmm_manager+0xb00>
{
ffffffffc02040be:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02040c0:	bc0fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02040c4 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040c4:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02040c6:	00004697          	auipc	a3,0x4
ffffffffc02040ca:	ff268693          	addi	a3,a3,-14 # ffffffffc02080b8 <default_pmm_manager+0xca8>
ffffffffc02040ce:	00003617          	auipc	a2,0x3
ffffffffc02040d2:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02040d6:	06d00593          	li	a1,109
ffffffffc02040da:	00004517          	auipc	a0,0x4
ffffffffc02040de:	ffe50513          	addi	a0,a0,-2 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040e2:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040e4:	b9cfc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02040e8 <pa2page.part.2>:
pa2page(uintptr_t pa) {
ffffffffc02040e8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02040ea:	00003617          	auipc	a2,0x3
ffffffffc02040ee:	3d660613          	addi	a2,a2,982 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc02040f2:	06200593          	li	a1,98
ffffffffc02040f6:	00003517          	auipc	a0,0x3
ffffffffc02040fa:	39250513          	addi	a0,a0,914 # ffffffffc0207488 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc02040fe:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0204100:	b80fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204104 <mm_create>:
mm_create(void) {
ffffffffc0204104:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204106:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020410a:	e022                	sd	s0,0(sp)
ffffffffc020410c:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020410e:	b1ffd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc0204112:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204114:	c515                	beqz	a0,ffffffffc0204140 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204116:	000a8797          	auipc	a5,0xa8
ffffffffc020411a:	7aa78793          	addi	a5,a5,1962 # ffffffffc02ac8c0 <swap_init_ok>
ffffffffc020411e:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0204120:	e408                	sd	a0,8(s0)
ffffffffc0204122:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0204124:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204128:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020412c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204130:	2781                	sext.w	a5,a5
ffffffffc0204132:	ef81                	bnez	a5,ffffffffc020414a <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0204134:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0204138:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020413c:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204140:	8522                	mv	a0,s0
ffffffffc0204142:	60a2                	ld	ra,8(sp)
ffffffffc0204144:	6402                	ld	s0,0(sp)
ffffffffc0204146:	0141                	addi	sp,sp,16
ffffffffc0204148:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020414a:	9e5ff0ef          	jal	ra,ffffffffc0203b2e <swap_init_mm>
ffffffffc020414e:	b7ed                	j	ffffffffc0204138 <mm_create+0x34>

ffffffffc0204150 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204150:	1101                	addi	sp,sp,-32
ffffffffc0204152:	e04a                	sd	s2,0(sp)
ffffffffc0204154:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204156:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020415a:	e822                	sd	s0,16(sp)
ffffffffc020415c:	e426                	sd	s1,8(sp)
ffffffffc020415e:	ec06                	sd	ra,24(sp)
ffffffffc0204160:	84ae                	mv	s1,a1
ffffffffc0204162:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204164:	ac9fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
    if (vma != NULL) {
ffffffffc0204168:	c509                	beqz	a0,ffffffffc0204172 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020416a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020416e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204170:	cd00                	sw	s0,24(a0)
}
ffffffffc0204172:	60e2                	ld	ra,24(sp)
ffffffffc0204174:	6442                	ld	s0,16(sp)
ffffffffc0204176:	64a2                	ld	s1,8(sp)
ffffffffc0204178:	6902                	ld	s2,0(sp)
ffffffffc020417a:	6105                	addi	sp,sp,32
ffffffffc020417c:	8082                	ret

ffffffffc020417e <find_vma>:
    if (mm != NULL) {
ffffffffc020417e:	c51d                	beqz	a0,ffffffffc02041ac <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204180:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204182:	c781                	beqz	a5,ffffffffc020418a <find_vma+0xc>
ffffffffc0204184:	6798                	ld	a4,8(a5)
ffffffffc0204186:	02e5f663          	bgeu	a1,a4,ffffffffc02041b2 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020418a:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020418c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020418e:	00f50f63          	beq	a0,a5,ffffffffc02041ac <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204192:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204196:	fee5ebe3          	bltu	a1,a4,ffffffffc020418c <find_vma+0xe>
ffffffffc020419a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020419e:	fee5f7e3          	bgeu	a1,a4,ffffffffc020418c <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02041a2:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02041a4:	c781                	beqz	a5,ffffffffc02041ac <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02041a6:	e91c                	sd	a5,16(a0)
}
ffffffffc02041a8:	853e                	mv	a0,a5
ffffffffc02041aa:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02041ac:	4781                	li	a5,0
}
ffffffffc02041ae:	853e                	mv	a0,a5
ffffffffc02041b0:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02041b2:	6b98                	ld	a4,16(a5)
ffffffffc02041b4:	fce5fbe3          	bgeu	a1,a4,ffffffffc020418a <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02041b8:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02041ba:	b7fd                	j	ffffffffc02041a8 <find_vma+0x2a>

ffffffffc02041bc <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041bc:	6590                	ld	a2,8(a1)
ffffffffc02041be:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x85c0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02041c2:	1141                	addi	sp,sp,-16
ffffffffc02041c4:	e406                	sd	ra,8(sp)
ffffffffc02041c6:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041c8:	01066863          	bltu	a2,a6,ffffffffc02041d8 <insert_vma_struct+0x1c>
ffffffffc02041cc:	a8b9                	j	ffffffffc020422a <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02041ce:	fe87b683          	ld	a3,-24(a5)
ffffffffc02041d2:	04d66763          	bltu	a2,a3,ffffffffc0204220 <insert_vma_struct+0x64>
ffffffffc02041d6:	873e                	mv	a4,a5
ffffffffc02041d8:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02041da:	fef51ae3          	bne	a0,a5,ffffffffc02041ce <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02041de:	02a70463          	beq	a4,a0,ffffffffc0204206 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02041e2:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02041e6:	fe873883          	ld	a7,-24(a4)
ffffffffc02041ea:	08d8f063          	bgeu	a7,a3,ffffffffc020426a <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041ee:	04d66e63          	bltu	a2,a3,ffffffffc020424a <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02041f2:	00f50a63          	beq	a0,a5,ffffffffc0204206 <insert_vma_struct+0x4a>
ffffffffc02041f6:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041fa:	0506e863          	bltu	a3,a6,ffffffffc020424a <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041fe:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204202:	02c6f263          	bgeu	a3,a2,ffffffffc0204226 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0204206:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0204208:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020420a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020420e:	e390                	sd	a2,0(a5)
ffffffffc0204210:	e710                	sd	a2,8(a4)
}
ffffffffc0204212:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204214:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0204216:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0204218:	2685                	addiw	a3,a3,1
ffffffffc020421a:	d114                	sw	a3,32(a0)
}
ffffffffc020421c:	0141                	addi	sp,sp,16
ffffffffc020421e:	8082                	ret
    if (le_prev != list) {
ffffffffc0204220:	fca711e3          	bne	a4,a0,ffffffffc02041e2 <insert_vma_struct+0x26>
ffffffffc0204224:	bfd9                	j	ffffffffc02041fa <insert_vma_struct+0x3e>
ffffffffc0204226:	e9fff0ef          	jal	ra,ffffffffc02040c4 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020422a:	00004697          	auipc	a3,0x4
ffffffffc020422e:	fbe68693          	addi	a3,a3,-66 # ffffffffc02081e8 <default_pmm_manager+0xdd8>
ffffffffc0204232:	00003617          	auipc	a2,0x3
ffffffffc0204236:	a9660613          	addi	a2,a2,-1386 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020423a:	07400593          	li	a1,116
ffffffffc020423e:	00004517          	auipc	a0,0x4
ffffffffc0204242:	e9a50513          	addi	a0,a0,-358 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204246:	a3afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020424a:	00004697          	auipc	a3,0x4
ffffffffc020424e:	fde68693          	addi	a3,a3,-34 # ffffffffc0208228 <default_pmm_manager+0xe18>
ffffffffc0204252:	00003617          	auipc	a2,0x3
ffffffffc0204256:	a7660613          	addi	a2,a2,-1418 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020425a:	06c00593          	li	a1,108
ffffffffc020425e:	00004517          	auipc	a0,0x4
ffffffffc0204262:	e7a50513          	addi	a0,a0,-390 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204266:	a1afc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020426a:	00004697          	auipc	a3,0x4
ffffffffc020426e:	f9e68693          	addi	a3,a3,-98 # ffffffffc0208208 <default_pmm_manager+0xdf8>
ffffffffc0204272:	00003617          	auipc	a2,0x3
ffffffffc0204276:	a5660613          	addi	a2,a2,-1450 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020427a:	06b00593          	li	a1,107
ffffffffc020427e:	00004517          	auipc	a0,0x4
ffffffffc0204282:	e5a50513          	addi	a0,a0,-422 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204286:	9fafc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020428a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020428a:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020428c:	1141                	addi	sp,sp,-16
ffffffffc020428e:	e406                	sd	ra,8(sp)
ffffffffc0204290:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204292:	e78d                	bnez	a5,ffffffffc02042bc <mm_destroy+0x32>
ffffffffc0204294:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204296:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204298:	00a40c63          	beq	s0,a0,ffffffffc02042b0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020429c:	6118                	ld	a4,0(a0)
ffffffffc020429e:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02042a0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02042a2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02042a4:	e398                	sd	a4,0(a5)
ffffffffc02042a6:	a43fd0ef          	jal	ra,ffffffffc0201ce8 <kfree>
    return listelm->next;
ffffffffc02042aa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02042ac:	fea418e3          	bne	s0,a0,ffffffffc020429c <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02042b0:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02042b2:	6402                	ld	s0,0(sp)
ffffffffc02042b4:	60a2                	ld	ra,8(sp)
ffffffffc02042b6:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02042b8:	a31fd06f          	j	ffffffffc0201ce8 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02042bc:	00004697          	auipc	a3,0x4
ffffffffc02042c0:	f8c68693          	addi	a3,a3,-116 # ffffffffc0208248 <default_pmm_manager+0xe38>
ffffffffc02042c4:	00003617          	auipc	a2,0x3
ffffffffc02042c8:	a0460613          	addi	a2,a2,-1532 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02042cc:	09400593          	li	a1,148
ffffffffc02042d0:	00004517          	auipc	a0,0x4
ffffffffc02042d4:	e0850513          	addi	a0,a0,-504 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02042d8:	9a8fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02042dc <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042dc:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02042de:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042e0:	17fd                	addi	a5,a5,-1
ffffffffc02042e2:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02042e4:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042e6:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02042ea:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042ec:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02042ee:	fc06                	sd	ra,56(sp)
ffffffffc02042f0:	f04a                	sd	s2,32(sp)
ffffffffc02042f2:	ec4e                	sd	s3,24(sp)
ffffffffc02042f4:	e852                	sd	s4,16(sp)
ffffffffc02042f6:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042f8:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02042fc:	002007b7          	lui	a5,0x200
ffffffffc0204300:	01047433          	and	s0,s0,a6
ffffffffc0204304:	06f4e363          	bltu	s1,a5,ffffffffc020436a <mm_map+0x8e>
ffffffffc0204308:	0684f163          	bgeu	s1,s0,ffffffffc020436a <mm_map+0x8e>
ffffffffc020430c:	4785                	li	a5,1
ffffffffc020430e:	07fe                	slli	a5,a5,0x1f
ffffffffc0204310:	0487ed63          	bltu	a5,s0,ffffffffc020436a <mm_map+0x8e>
ffffffffc0204314:	89aa                	mv	s3,a0
ffffffffc0204316:	8a3a                	mv	s4,a4
ffffffffc0204318:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc020431a:	c931                	beqz	a0,ffffffffc020436e <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc020431c:	85a6                	mv	a1,s1
ffffffffc020431e:	e61ff0ef          	jal	ra,ffffffffc020417e <find_vma>
ffffffffc0204322:	c501                	beqz	a0,ffffffffc020432a <mm_map+0x4e>
ffffffffc0204324:	651c                	ld	a5,8(a0)
ffffffffc0204326:	0487e263          	bltu	a5,s0,ffffffffc020436a <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020432a:	03000513          	li	a0,48
ffffffffc020432e:	8fffd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc0204332:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204334:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204336:	02090163          	beqz	s2,ffffffffc0204358 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020433a:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020433c:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204340:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204344:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204348:	85ca                	mv	a1,s2
ffffffffc020434a:	e73ff0ef          	jal	ra,ffffffffc02041bc <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020434e:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204350:	000a0463          	beqz	s4,ffffffffc0204358 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204354:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204358:	70e2                	ld	ra,56(sp)
ffffffffc020435a:	7442                	ld	s0,48(sp)
ffffffffc020435c:	74a2                	ld	s1,40(sp)
ffffffffc020435e:	7902                	ld	s2,32(sp)
ffffffffc0204360:	69e2                	ld	s3,24(sp)
ffffffffc0204362:	6a42                	ld	s4,16(sp)
ffffffffc0204364:	6aa2                	ld	s5,8(sp)
ffffffffc0204366:	6121                	addi	sp,sp,64
ffffffffc0204368:	8082                	ret
        return -E_INVAL;
ffffffffc020436a:	5575                	li	a0,-3
ffffffffc020436c:	b7f5                	j	ffffffffc0204358 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc020436e:	00004697          	auipc	a3,0x4
ffffffffc0204372:	8a268693          	addi	a3,a3,-1886 # ffffffffc0207c10 <default_pmm_manager+0x800>
ffffffffc0204376:	00003617          	auipc	a2,0x3
ffffffffc020437a:	95260613          	addi	a2,a2,-1710 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020437e:	0a700593          	li	a1,167
ffffffffc0204382:	00004517          	auipc	a0,0x4
ffffffffc0204386:	d5650513          	addi	a0,a0,-682 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc020438a:	8f6fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020438e <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc020438e:	7139                	addi	sp,sp,-64
ffffffffc0204390:	fc06                	sd	ra,56(sp)
ffffffffc0204392:	f822                	sd	s0,48(sp)
ffffffffc0204394:	f426                	sd	s1,40(sp)
ffffffffc0204396:	f04a                	sd	s2,32(sp)
ffffffffc0204398:	ec4e                	sd	s3,24(sp)
ffffffffc020439a:	e852                	sd	s4,16(sp)
ffffffffc020439c:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020439e:	c535                	beqz	a0,ffffffffc020440a <dup_mmap+0x7c>
ffffffffc02043a0:	892a                	mv	s2,a0
ffffffffc02043a2:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02043a4:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02043a6:	e59d                	bnez	a1,ffffffffc02043d4 <dup_mmap+0x46>
ffffffffc02043a8:	a08d                	j	ffffffffc020440a <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02043aa:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02043ac:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5530>
        insert_vma_struct(to, nvma);
ffffffffc02043b0:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc02043b2:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc02043b6:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc02043ba:	e03ff0ef          	jal	ra,ffffffffc02041bc <insert_vma_struct>

        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02043be:	ff043683          	ld	a3,-16(s0)
ffffffffc02043c2:	fe843603          	ld	a2,-24(s0)
ffffffffc02043c6:	6c8c                	ld	a1,24(s1)
ffffffffc02043c8:	01893503          	ld	a0,24(s2)
ffffffffc02043cc:	4705                	li	a4,1
ffffffffc02043ce:	cb5fe0ef          	jal	ra,ffffffffc0203082 <copy_range>
ffffffffc02043d2:	e105                	bnez	a0,ffffffffc02043f2 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02043d4:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02043d6:	02848863          	beq	s1,s0,ffffffffc0204406 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043da:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02043de:	fe843a83          	ld	s5,-24(s0)
ffffffffc02043e2:	ff043a03          	ld	s4,-16(s0)
ffffffffc02043e6:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043ea:	843fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc02043ee:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02043f0:	fd4d                	bnez	a0,ffffffffc02043aa <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043f2:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043f4:	70e2                	ld	ra,56(sp)
ffffffffc02043f6:	7442                	ld	s0,48(sp)
ffffffffc02043f8:	74a2                	ld	s1,40(sp)
ffffffffc02043fa:	7902                	ld	s2,32(sp)
ffffffffc02043fc:	69e2                	ld	s3,24(sp)
ffffffffc02043fe:	6a42                	ld	s4,16(sp)
ffffffffc0204400:	6aa2                	ld	s5,8(sp)
ffffffffc0204402:	6121                	addi	sp,sp,64
ffffffffc0204404:	8082                	ret
    return 0;
ffffffffc0204406:	4501                	li	a0,0
ffffffffc0204408:	b7f5                	j	ffffffffc02043f4 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc020440a:	00004697          	auipc	a3,0x4
ffffffffc020440e:	d9e68693          	addi	a3,a3,-610 # ffffffffc02081a8 <default_pmm_manager+0xd98>
ffffffffc0204412:	00003617          	auipc	a2,0x3
ffffffffc0204416:	8b660613          	addi	a2,a2,-1866 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020441a:	0c000593          	li	a1,192
ffffffffc020441e:	00004517          	auipc	a0,0x4
ffffffffc0204422:	cba50513          	addi	a0,a0,-838 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204426:	85afc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020442a <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020442a:	1101                	addi	sp,sp,-32
ffffffffc020442c:	ec06                	sd	ra,24(sp)
ffffffffc020442e:	e822                	sd	s0,16(sp)
ffffffffc0204430:	e426                	sd	s1,8(sp)
ffffffffc0204432:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204434:	c531                	beqz	a0,ffffffffc0204480 <exit_mmap+0x56>
ffffffffc0204436:	591c                	lw	a5,48(a0)
ffffffffc0204438:	84aa                	mv	s1,a0
ffffffffc020443a:	e3b9                	bnez	a5,ffffffffc0204480 <exit_mmap+0x56>
    return listelm->next;
ffffffffc020443c:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020443e:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204442:	02850663          	beq	a0,s0,ffffffffc020446e <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204446:	ff043603          	ld	a2,-16(s0)
ffffffffc020444a:	fe843583          	ld	a1,-24(s0)
ffffffffc020444e:	854a                	mv	a0,s2
ffffffffc0204450:	d0dfd0ef          	jal	ra,ffffffffc020215c <unmap_range>
ffffffffc0204454:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204456:	fe8498e3          	bne	s1,s0,ffffffffc0204446 <exit_mmap+0x1c>
ffffffffc020445a:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020445c:	00848c63          	beq	s1,s0,ffffffffc0204474 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204460:	ff043603          	ld	a2,-16(s0)
ffffffffc0204464:	fe843583          	ld	a1,-24(s0)
ffffffffc0204468:	854a                	mv	a0,s2
ffffffffc020446a:	e0bfd0ef          	jal	ra,ffffffffc0202274 <exit_range>
ffffffffc020446e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204470:	fe8498e3          	bne	s1,s0,ffffffffc0204460 <exit_mmap+0x36>
    }
}
ffffffffc0204474:	60e2                	ld	ra,24(sp)
ffffffffc0204476:	6442                	ld	s0,16(sp)
ffffffffc0204478:	64a2                	ld	s1,8(sp)
ffffffffc020447a:	6902                	ld	s2,0(sp)
ffffffffc020447c:	6105                	addi	sp,sp,32
ffffffffc020447e:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204480:	00004697          	auipc	a3,0x4
ffffffffc0204484:	d4868693          	addi	a3,a3,-696 # ffffffffc02081c8 <default_pmm_manager+0xdb8>
ffffffffc0204488:	00003617          	auipc	a2,0x3
ffffffffc020448c:	84060613          	addi	a2,a2,-1984 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204490:	0d600593          	li	a1,214
ffffffffc0204494:	00004517          	auipc	a0,0x4
ffffffffc0204498:	c4450513          	addi	a0,a0,-956 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc020449c:	fe5fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02044a0 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02044a0:	7139                	addi	sp,sp,-64
ffffffffc02044a2:	f822                	sd	s0,48(sp)
ffffffffc02044a4:	f426                	sd	s1,40(sp)
ffffffffc02044a6:	fc06                	sd	ra,56(sp)
ffffffffc02044a8:	f04a                	sd	s2,32(sp)
ffffffffc02044aa:	ec4e                	sd	s3,24(sp)
ffffffffc02044ac:	e852                	sd	s4,16(sp)
ffffffffc02044ae:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02044b0:	c55ff0ef          	jal	ra,ffffffffc0204104 <mm_create>
    assert(mm != NULL);
ffffffffc02044b4:	842a                	mv	s0,a0
ffffffffc02044b6:	03200493          	li	s1,50
ffffffffc02044ba:	e919                	bnez	a0,ffffffffc02044d0 <vmm_init+0x30>
ffffffffc02044bc:	a93d                	j	ffffffffc02048fa <vmm_init+0x45a>
        vma->vm_start = vm_start;
ffffffffc02044be:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044c0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044c2:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044c6:	14ed                	addi	s1,s1,-5
ffffffffc02044c8:	8522                	mv	a0,s0
ffffffffc02044ca:	cf3ff0ef          	jal	ra,ffffffffc02041bc <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02044ce:	c88d                	beqz	s1,ffffffffc0204500 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044d0:	03000513          	li	a0,48
ffffffffc02044d4:	f58fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc02044d8:	85aa                	mv	a1,a0
ffffffffc02044da:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044de:	f165                	bnez	a0,ffffffffc02044be <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02044e0:	00003697          	auipc	a3,0x3
ffffffffc02044e4:	76868693          	addi	a3,a3,1896 # ffffffffc0207c48 <default_pmm_manager+0x838>
ffffffffc02044e8:	00002617          	auipc	a2,0x2
ffffffffc02044ec:	7e060613          	addi	a2,a2,2016 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02044f0:	11300593          	li	a1,275
ffffffffc02044f4:	00004517          	auipc	a0,0x4
ffffffffc02044f8:	be450513          	addi	a0,a0,-1052 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02044fc:	f85fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0204500:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204504:	1f900913          	li	s2,505
ffffffffc0204508:	a819                	j	ffffffffc020451e <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc020450a:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020450c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020450e:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204512:	0495                	addi	s1,s1,5
ffffffffc0204514:	8522                	mv	a0,s0
ffffffffc0204516:	ca7ff0ef          	jal	ra,ffffffffc02041bc <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020451a:	03248a63          	beq	s1,s2,ffffffffc020454e <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020451e:	03000513          	li	a0,48
ffffffffc0204522:	f0afd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc0204526:	85aa                	mv	a1,a0
ffffffffc0204528:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020452c:	fd79                	bnez	a0,ffffffffc020450a <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020452e:	00003697          	auipc	a3,0x3
ffffffffc0204532:	71a68693          	addi	a3,a3,1818 # ffffffffc0207c48 <default_pmm_manager+0x838>
ffffffffc0204536:	00002617          	auipc	a2,0x2
ffffffffc020453a:	79260613          	addi	a2,a2,1938 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020453e:	11900593          	li	a1,281
ffffffffc0204542:	00004517          	auipc	a0,0x4
ffffffffc0204546:	b9650513          	addi	a0,a0,-1130 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc020454a:	f37fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc020454e:	6418                	ld	a4,8(s0)
ffffffffc0204550:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204552:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204556:	2ee40063          	beq	s0,a4,ffffffffc0204836 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020455a:	fe873683          	ld	a3,-24(a4)
ffffffffc020455e:	ffe78613          	addi	a2,a5,-2
ffffffffc0204562:	24d61a63          	bne	a2,a3,ffffffffc02047b6 <vmm_init+0x316>
ffffffffc0204566:	ff073683          	ld	a3,-16(a4)
ffffffffc020456a:	24f69663          	bne	a3,a5,ffffffffc02047b6 <vmm_init+0x316>
ffffffffc020456e:	0795                	addi	a5,a5,5
ffffffffc0204570:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0204572:	feb792e3          	bne	a5,a1,ffffffffc0204556 <vmm_init+0xb6>
ffffffffc0204576:	491d                	li	s2,7
ffffffffc0204578:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020457a:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020457e:	85a6                	mv	a1,s1
ffffffffc0204580:	8522                	mv	a0,s0
ffffffffc0204582:	bfdff0ef          	jal	ra,ffffffffc020417e <find_vma>
ffffffffc0204586:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0204588:	30050763          	beqz	a0,ffffffffc0204896 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020458c:	00148593          	addi	a1,s1,1
ffffffffc0204590:	8522                	mv	a0,s0
ffffffffc0204592:	bedff0ef          	jal	ra,ffffffffc020417e <find_vma>
ffffffffc0204596:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204598:	2c050f63          	beqz	a0,ffffffffc0204876 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020459c:	85ca                	mv	a1,s2
ffffffffc020459e:	8522                	mv	a0,s0
ffffffffc02045a0:	bdfff0ef          	jal	ra,ffffffffc020417e <find_vma>
        assert(vma3 == NULL);
ffffffffc02045a4:	2a051963          	bnez	a0,ffffffffc0204856 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02045a8:	00348593          	addi	a1,s1,3
ffffffffc02045ac:	8522                	mv	a0,s0
ffffffffc02045ae:	bd1ff0ef          	jal	ra,ffffffffc020417e <find_vma>
        assert(vma4 == NULL);
ffffffffc02045b2:	32051263          	bnez	a0,ffffffffc02048d6 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02045b6:	00448593          	addi	a1,s1,4
ffffffffc02045ba:	8522                	mv	a0,s0
ffffffffc02045bc:	bc3ff0ef          	jal	ra,ffffffffc020417e <find_vma>
        assert(vma5 == NULL);
ffffffffc02045c0:	2e051b63          	bnez	a0,ffffffffc02048b6 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02045c4:	008a3783          	ld	a5,8(s4)
ffffffffc02045c8:	20979763          	bne	a5,s1,ffffffffc02047d6 <vmm_init+0x336>
ffffffffc02045cc:	010a3783          	ld	a5,16(s4)
ffffffffc02045d0:	21279363          	bne	a5,s2,ffffffffc02047d6 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02045d4:	0089b783          	ld	a5,8(s3)
ffffffffc02045d8:	20979f63          	bne	a5,s1,ffffffffc02047f6 <vmm_init+0x356>
ffffffffc02045dc:	0109b783          	ld	a5,16(s3)
ffffffffc02045e0:	21279b63          	bne	a5,s2,ffffffffc02047f6 <vmm_init+0x356>
ffffffffc02045e4:	0495                	addi	s1,s1,5
ffffffffc02045e6:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045e8:	f9549be3          	bne	s1,s5,ffffffffc020457e <vmm_init+0xde>
ffffffffc02045ec:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045ee:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045f0:	85a6                	mv	a1,s1
ffffffffc02045f2:	8522                	mv	a0,s0
ffffffffc02045f4:	b8bff0ef          	jal	ra,ffffffffc020417e <find_vma>
ffffffffc02045f8:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02045fc:	c90d                	beqz	a0,ffffffffc020462e <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045fe:	6914                	ld	a3,16(a0)
ffffffffc0204600:	6510                	ld	a2,8(a0)
ffffffffc0204602:	00004517          	auipc	a0,0x4
ffffffffc0204606:	d5e50513          	addi	a0,a0,-674 # ffffffffc0208360 <default_pmm_manager+0xf50>
ffffffffc020460a:	b85fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020460e:	00004697          	auipc	a3,0x4
ffffffffc0204612:	d7a68693          	addi	a3,a3,-646 # ffffffffc0208388 <default_pmm_manager+0xf78>
ffffffffc0204616:	00002617          	auipc	a2,0x2
ffffffffc020461a:	6b260613          	addi	a2,a2,1714 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020461e:	13b00593          	li	a1,315
ffffffffc0204622:	00004517          	auipc	a0,0x4
ffffffffc0204626:	ab650513          	addi	a0,a0,-1354 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc020462a:	e57fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc020462e:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0204630:	fd2490e3          	bne	s1,s2,ffffffffc02045f0 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204634:	8522                	mv	a0,s0
ffffffffc0204636:	c55ff0ef          	jal	ra,ffffffffc020428a <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020463a:	00004517          	auipc	a0,0x4
ffffffffc020463e:	d6650513          	addi	a0,a0,-666 # ffffffffc02083a0 <default_pmm_manager+0xf90>
ffffffffc0204642:	b4dfb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204646:	8adfd0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc020464a:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020464c:	ab9ff0ef          	jal	ra,ffffffffc0204104 <mm_create>
ffffffffc0204650:	000a8797          	auipc	a5,0xa8
ffffffffc0204654:	3aa7b823          	sd	a0,944(a5) # ffffffffc02aca00 <check_mm_struct>
ffffffffc0204658:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020465a:	34050c63          	beqz	a0,ffffffffc02049b2 <vmm_init+0x512>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020465e:	000a8797          	auipc	a5,0xa8
ffffffffc0204662:	24a78793          	addi	a5,a5,586 # ffffffffc02ac8a8 <boot_pgdir>
ffffffffc0204666:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020466a:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020466e:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204672:	2c079463          	bnez	a5,ffffffffc020493a <vmm_init+0x49a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204676:	03000513          	li	a0,48
ffffffffc020467a:	db2fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc020467e:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204680:	18050b63          	beqz	a0,ffffffffc0204816 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204684:	002007b7          	lui	a5,0x200
ffffffffc0204688:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020468a:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020468c:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020468e:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204690:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204692:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204696:	b27ff0ef          	jal	ra,ffffffffc02041bc <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020469a:	10000593          	li	a1,256
ffffffffc020469e:	8526                	mv	a0,s1
ffffffffc02046a0:	adfff0ef          	jal	ra,ffffffffc020417e <find_vma>
ffffffffc02046a4:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02046a8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02046ac:	2aa41763          	bne	s0,a0,ffffffffc020495a <vmm_init+0x4ba>
        *(char *)(addr + i) = i;
ffffffffc02046b0:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5528>
        sum += i;
ffffffffc02046b4:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02046b6:	fee79de3          	bne	a5,a4,ffffffffc02046b0 <vmm_init+0x210>
        sum += i;
ffffffffc02046ba:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02046bc:	10000793          	li	a5,256
        sum += i;
ffffffffc02046c0:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x827a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02046c4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02046c8:	0007c683          	lbu	a3,0(a5)
ffffffffc02046cc:	0785                	addi	a5,a5,1
ffffffffc02046ce:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02046d0:	fec79ce3          	bne	a5,a2,ffffffffc02046c8 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc02046d4:	2a071f63          	bnez	a4,ffffffffc0204992 <vmm_init+0x4f2>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046d8:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02046dc:	000a8a97          	auipc	s5,0xa8
ffffffffc02046e0:	1d4a8a93          	addi	s5,s5,468 # ffffffffc02ac8b0 <npage>
ffffffffc02046e4:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046e8:	078a                	slli	a5,a5,0x2
ffffffffc02046ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046ec:	20e7f563          	bgeu	a5,a4,ffffffffc02048f6 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046f0:	00004697          	auipc	a3,0x4
ffffffffc02046f4:	6b868693          	addi	a3,a3,1720 # ffffffffc0208da8 <nbase>
ffffffffc02046f8:	0006ba03          	ld	s4,0(a3)
ffffffffc02046fc:	414786b3          	sub	a3,a5,s4
ffffffffc0204700:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0204702:	8699                	srai	a3,a3,0x6
ffffffffc0204704:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0204706:	00c69793          	slli	a5,a3,0xc
ffffffffc020470a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020470c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020470e:	26e7f663          	bgeu	a5,a4,ffffffffc020497a <vmm_init+0x4da>
ffffffffc0204712:	000a8797          	auipc	a5,0xa8
ffffffffc0204716:	1fe78793          	addi	a5,a5,510 # ffffffffc02ac910 <va_pa_offset>
ffffffffc020471a:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020471c:	4581                	li	a1,0
ffffffffc020471e:	854a                	mv	a0,s2
ffffffffc0204720:	9436                	add	s0,s0,a3
ffffffffc0204722:	da9fd0ef          	jal	ra,ffffffffc02024ca <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204726:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204728:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020472c:	078a                	slli	a5,a5,0x2
ffffffffc020472e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204730:	1ce7f363          	bgeu	a5,a4,ffffffffc02048f6 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204734:	000a8417          	auipc	s0,0xa8
ffffffffc0204738:	1ec40413          	addi	s0,s0,492 # ffffffffc02ac920 <pages>
ffffffffc020473c:	6008                	ld	a0,0(s0)
ffffffffc020473e:	414787b3          	sub	a5,a5,s4
ffffffffc0204742:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204744:	953e                	add	a0,a0,a5
ffffffffc0204746:	4585                	li	a1,1
ffffffffc0204748:	f64fd0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020474c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204750:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204754:	078a                	slli	a5,a5,0x2
ffffffffc0204756:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204758:	18e7ff63          	bgeu	a5,a4,ffffffffc02048f6 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020475c:	6008                	ld	a0,0(s0)
ffffffffc020475e:	414787b3          	sub	a5,a5,s4
ffffffffc0204762:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204764:	4585                	li	a1,1
ffffffffc0204766:	953e                	add	a0,a0,a5
ffffffffc0204768:	f44fd0ef          	jal	ra,ffffffffc0201eac <free_pages>
    pgdir[0] = 0;
ffffffffc020476c:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204770:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204774:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0204778:	8526                	mv	a0,s1
ffffffffc020477a:	b11ff0ef          	jal	ra,ffffffffc020428a <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020477e:	000a8797          	auipc	a5,0xa8
ffffffffc0204782:	2807b123          	sd	zero,642(a5) # ffffffffc02aca00 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204786:	f6cfd0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc020478a:	18a99863          	bne	s3,a0,ffffffffc020491a <vmm_init+0x47a>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020478e:	00004517          	auipc	a0,0x4
ffffffffc0204792:	ca250513          	addi	a0,a0,-862 # ffffffffc0208430 <default_pmm_manager+0x1020>
ffffffffc0204796:	9f9fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020479a:	7442                	ld	s0,48(sp)
ffffffffc020479c:	70e2                	ld	ra,56(sp)
ffffffffc020479e:	74a2                	ld	s1,40(sp)
ffffffffc02047a0:	7902                	ld	s2,32(sp)
ffffffffc02047a2:	69e2                	ld	s3,24(sp)
ffffffffc02047a4:	6a42                	ld	s4,16(sp)
ffffffffc02047a6:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02047a8:	00004517          	auipc	a0,0x4
ffffffffc02047ac:	ca850513          	addi	a0,a0,-856 # ffffffffc0208450 <default_pmm_manager+0x1040>
}
ffffffffc02047b0:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02047b2:	9ddfb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02047b6:	00004697          	auipc	a3,0x4
ffffffffc02047ba:	ac268693          	addi	a3,a3,-1342 # ffffffffc0208278 <default_pmm_manager+0xe68>
ffffffffc02047be:	00002617          	auipc	a2,0x2
ffffffffc02047c2:	50a60613          	addi	a2,a2,1290 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02047c6:	12200593          	li	a1,290
ffffffffc02047ca:	00004517          	auipc	a0,0x4
ffffffffc02047ce:	90e50513          	addi	a0,a0,-1778 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02047d2:	caffb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02047d6:	00004697          	auipc	a3,0x4
ffffffffc02047da:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0208300 <default_pmm_manager+0xef0>
ffffffffc02047de:	00002617          	auipc	a2,0x2
ffffffffc02047e2:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02047e6:	13200593          	li	a1,306
ffffffffc02047ea:	00004517          	auipc	a0,0x4
ffffffffc02047ee:	8ee50513          	addi	a0,a0,-1810 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02047f2:	c8ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047f6:	00004697          	auipc	a3,0x4
ffffffffc02047fa:	b3a68693          	addi	a3,a3,-1222 # ffffffffc0208330 <default_pmm_manager+0xf20>
ffffffffc02047fe:	00002617          	auipc	a2,0x2
ffffffffc0204802:	4ca60613          	addi	a2,a2,1226 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204806:	13300593          	li	a1,307
ffffffffc020480a:	00004517          	auipc	a0,0x4
ffffffffc020480e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204812:	c6ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(vma != NULL);
ffffffffc0204816:	00003697          	auipc	a3,0x3
ffffffffc020481a:	43268693          	addi	a3,a3,1074 # ffffffffc0207c48 <default_pmm_manager+0x838>
ffffffffc020481e:	00002617          	auipc	a2,0x2
ffffffffc0204822:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204826:	15200593          	li	a1,338
ffffffffc020482a:	00004517          	auipc	a0,0x4
ffffffffc020482e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204832:	c4ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204836:	00004697          	auipc	a3,0x4
ffffffffc020483a:	a2a68693          	addi	a3,a3,-1494 # ffffffffc0208260 <default_pmm_manager+0xe50>
ffffffffc020483e:	00002617          	auipc	a2,0x2
ffffffffc0204842:	48a60613          	addi	a2,a2,1162 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204846:	12000593          	li	a1,288
ffffffffc020484a:	00004517          	auipc	a0,0x4
ffffffffc020484e:	88e50513          	addi	a0,a0,-1906 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204852:	c2ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma3 == NULL);
ffffffffc0204856:	00004697          	auipc	a3,0x4
ffffffffc020485a:	a7a68693          	addi	a3,a3,-1414 # ffffffffc02082d0 <default_pmm_manager+0xec0>
ffffffffc020485e:	00002617          	auipc	a2,0x2
ffffffffc0204862:	46a60613          	addi	a2,a2,1130 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204866:	12c00593          	li	a1,300
ffffffffc020486a:	00004517          	auipc	a0,0x4
ffffffffc020486e:	86e50513          	addi	a0,a0,-1938 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204872:	c0ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma2 != NULL);
ffffffffc0204876:	00004697          	auipc	a3,0x4
ffffffffc020487a:	a4a68693          	addi	a3,a3,-1462 # ffffffffc02082c0 <default_pmm_manager+0xeb0>
ffffffffc020487e:	00002617          	auipc	a2,0x2
ffffffffc0204882:	44a60613          	addi	a2,a2,1098 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0204886:	12a00593          	li	a1,298
ffffffffc020488a:	00004517          	auipc	a0,0x4
ffffffffc020488e:	84e50513          	addi	a0,a0,-1970 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204892:	beffb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma1 != NULL);
ffffffffc0204896:	00004697          	auipc	a3,0x4
ffffffffc020489a:	a1a68693          	addi	a3,a3,-1510 # ffffffffc02082b0 <default_pmm_manager+0xea0>
ffffffffc020489e:	00002617          	auipc	a2,0x2
ffffffffc02048a2:	42a60613          	addi	a2,a2,1066 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02048a6:	12800593          	li	a1,296
ffffffffc02048aa:	00004517          	auipc	a0,0x4
ffffffffc02048ae:	82e50513          	addi	a0,a0,-2002 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02048b2:	bcffb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma5 == NULL);
ffffffffc02048b6:	00004697          	auipc	a3,0x4
ffffffffc02048ba:	a3a68693          	addi	a3,a3,-1478 # ffffffffc02082f0 <default_pmm_manager+0xee0>
ffffffffc02048be:	00002617          	auipc	a2,0x2
ffffffffc02048c2:	40a60613          	addi	a2,a2,1034 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02048c6:	13000593          	li	a1,304
ffffffffc02048ca:	00004517          	auipc	a0,0x4
ffffffffc02048ce:	80e50513          	addi	a0,a0,-2034 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02048d2:	baffb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma4 == NULL);
ffffffffc02048d6:	00004697          	auipc	a3,0x4
ffffffffc02048da:	a0a68693          	addi	a3,a3,-1526 # ffffffffc02082e0 <default_pmm_manager+0xed0>
ffffffffc02048de:	00002617          	auipc	a2,0x2
ffffffffc02048e2:	3ea60613          	addi	a2,a2,1002 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02048e6:	12e00593          	li	a1,302
ffffffffc02048ea:	00003517          	auipc	a0,0x3
ffffffffc02048ee:	7ee50513          	addi	a0,a0,2030 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02048f2:	b8ffb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc02048f6:	ff2ff0ef          	jal	ra,ffffffffc02040e8 <pa2page.part.2>
    assert(mm != NULL);
ffffffffc02048fa:	00003697          	auipc	a3,0x3
ffffffffc02048fe:	31668693          	addi	a3,a3,790 # ffffffffc0207c10 <default_pmm_manager+0x800>
ffffffffc0204902:	00002617          	auipc	a2,0x2
ffffffffc0204906:	3c660613          	addi	a2,a2,966 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020490a:	10c00593          	li	a1,268
ffffffffc020490e:	00003517          	auipc	a0,0x3
ffffffffc0204912:	7ca50513          	addi	a0,a0,1994 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204916:	b6bfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020491a:	00004697          	auipc	a3,0x4
ffffffffc020491e:	aee68693          	addi	a3,a3,-1298 # ffffffffc0208408 <default_pmm_manager+0xff8>
ffffffffc0204922:	00002617          	auipc	a2,0x2
ffffffffc0204926:	3a660613          	addi	a2,a2,934 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020492a:	17000593          	li	a1,368
ffffffffc020492e:	00003517          	auipc	a0,0x3
ffffffffc0204932:	7aa50513          	addi	a0,a0,1962 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204936:	b4bfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir[0] == 0);
ffffffffc020493a:	00003697          	auipc	a3,0x3
ffffffffc020493e:	2fe68693          	addi	a3,a3,766 # ffffffffc0207c38 <default_pmm_manager+0x828>
ffffffffc0204942:	00002617          	auipc	a2,0x2
ffffffffc0204946:	38660613          	addi	a2,a2,902 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020494a:	14f00593          	li	a1,335
ffffffffc020494e:	00003517          	auipc	a0,0x3
ffffffffc0204952:	78a50513          	addi	a0,a0,1930 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204956:	b2bfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020495a:	00004697          	auipc	a3,0x4
ffffffffc020495e:	a7e68693          	addi	a3,a3,-1410 # ffffffffc02083d8 <default_pmm_manager+0xfc8>
ffffffffc0204962:	00002617          	auipc	a2,0x2
ffffffffc0204966:	36660613          	addi	a2,a2,870 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020496a:	15700593          	li	a1,343
ffffffffc020496e:	00003517          	auipc	a0,0x3
ffffffffc0204972:	76a50513          	addi	a0,a0,1898 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc0204976:	b0bfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc020497a:	00003617          	auipc	a2,0x3
ffffffffc020497e:	ae660613          	addi	a2,a2,-1306 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0204982:	06900593          	li	a1,105
ffffffffc0204986:	00003517          	auipc	a0,0x3
ffffffffc020498a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc020498e:	af3fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(sum == 0);
ffffffffc0204992:	00004697          	auipc	a3,0x4
ffffffffc0204996:	a6668693          	addi	a3,a3,-1434 # ffffffffc02083f8 <default_pmm_manager+0xfe8>
ffffffffc020499a:	00002617          	auipc	a2,0x2
ffffffffc020499e:	32e60613          	addi	a2,a2,814 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02049a2:	16300593          	li	a1,355
ffffffffc02049a6:	00003517          	auipc	a0,0x3
ffffffffc02049aa:	73250513          	addi	a0,a0,1842 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02049ae:	ad3fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02049b2:	00004697          	auipc	a3,0x4
ffffffffc02049b6:	a0e68693          	addi	a3,a3,-1522 # ffffffffc02083c0 <default_pmm_manager+0xfb0>
ffffffffc02049ba:	00002617          	auipc	a2,0x2
ffffffffc02049be:	30e60613          	addi	a2,a2,782 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02049c2:	14b00593          	li	a1,331
ffffffffc02049c6:	00003517          	auipc	a0,0x3
ffffffffc02049ca:	71250513          	addi	a0,a0,1810 # ffffffffc02080d8 <default_pmm_manager+0xcc8>
ffffffffc02049ce:	ab3fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02049d2 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049d2:	715d                	addi	sp,sp,-80
ffffffffc02049d4:	f44e                	sd	s3,40(sp)
ffffffffc02049d6:	89ae                	mv	s3,a1
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049d8:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049da:	e0a2                	sd	s0,64(sp)
ffffffffc02049dc:	fc26                	sd	s1,56(sp)
ffffffffc02049de:	e486                	sd	ra,72(sp)
ffffffffc02049e0:	f84a                	sd	s2,48(sp)
ffffffffc02049e2:	f052                	sd	s4,32(sp)
ffffffffc02049e4:	ec56                	sd	s5,24(sp)
ffffffffc02049e6:	8432                	mv	s0,a2
ffffffffc02049e8:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049ea:	f94ff0ef          	jal	ra,ffffffffc020417e <find_vma>

    pgfault_num++;
ffffffffc02049ee:	000a8797          	auipc	a5,0xa8
ffffffffc02049f2:	ed678793          	addi	a5,a5,-298 # ffffffffc02ac8c4 <pgfault_num>
ffffffffc02049f6:	439c                	lw	a5,0(a5)
ffffffffc02049f8:	2785                	addiw	a5,a5,1
ffffffffc02049fa:	000a8717          	auipc	a4,0xa8
ffffffffc02049fe:	ecf72523          	sw	a5,-310(a4) # ffffffffc02ac8c4 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204a02:	14050063          	beqz	a0,ffffffffc0204b42 <do_pgfault+0x170>
ffffffffc0204a06:	651c                	ld	a5,8(a0)
ffffffffc0204a08:	12f46d63          	bltu	s0,a5,ffffffffc0204b42 <do_pgfault+0x170>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a0c:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204a0e:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a10:	8b89                	andi	a5,a5,2
ffffffffc0204a12:	eba5                	bnez	a5,ffffffffc0204a82 <do_pgfault+0xb0>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a14:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a16:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a18:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a1a:	85a2                	mv	a1,s0
ffffffffc0204a1c:	4605                	li	a2,1
ffffffffc0204a1e:	d14fd0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc0204a22:	14050263          	beqz	a0,ffffffffc0204b66 <do_pgfault+0x194>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204a26:	611c                	ld	a5,0(a0)
ffffffffc0204a28:	0e078763          	beqz	a5,ffffffffc0204b16 <do_pgfault+0x144>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } 
    else if((*ptep&PTE_V)&&(error_code&3==3)){
ffffffffc0204a2c:	0017f713          	andi	a4,a5,1
ffffffffc0204a30:	eb39                	bnez	a4,ffffffffc0204a86 <do_pgfault+0xb4>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204a32:	000a8717          	auipc	a4,0xa8
ffffffffc0204a36:	e8e70713          	addi	a4,a4,-370 # ffffffffc02ac8c0 <swap_init_ok>
ffffffffc0204a3a:	4318                	lw	a4,0(a4)
ffffffffc0204a3c:	2701                	sext.w	a4,a4
ffffffffc0204a3e:	10070b63          	beqz	a4,ffffffffc0204b54 <do_pgfault+0x182>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            ret=swap_in(mm,addr,&page);
ffffffffc0204a42:	0030                	addi	a2,sp,8
ffffffffc0204a44:	85a2                	mv	a1,s0
ffffffffc0204a46:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204a48:	e402                	sd	zero,8(sp)
            ret=swap_in(mm,addr,&page);
ffffffffc0204a4a:	a18ff0ef          	jal	ra,ffffffffc0203c62 <swap_in>
ffffffffc0204a4e:	89aa                	mv	s3,a0
            if(ret!=0){
ffffffffc0204a50:	e175                	bnez	a0,ffffffffc0204b34 <do_pgfault+0x162>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0204a52:	65a2                	ld	a1,8(sp)
ffffffffc0204a54:	6c88                	ld	a0,24(s1)
ffffffffc0204a56:	86ca                	mv	a3,s2
ffffffffc0204a58:	8622                	mv	a2,s0
ffffffffc0204a5a:	ae5fd0ef          	jal	ra,ffffffffc020253e <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0204a5e:	6622                	ld	a2,8(sp)
ffffffffc0204a60:	4685                	li	a3,1
ffffffffc0204a62:	85a2                	mv	a1,s0
ffffffffc0204a64:	8526                	mv	a0,s1
ffffffffc0204a66:	8d8ff0ef          	jal	ra,ffffffffc0203b3e <swap_map_swappable>


            page->pra_vaddr = addr;
ffffffffc0204a6a:	67a2                	ld	a5,8(sp)
ffffffffc0204a6c:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204a6e:	60a6                	ld	ra,72(sp)
ffffffffc0204a70:	6406                	ld	s0,64(sp)
ffffffffc0204a72:	854e                	mv	a0,s3
ffffffffc0204a74:	74e2                	ld	s1,56(sp)
ffffffffc0204a76:	7942                	ld	s2,48(sp)
ffffffffc0204a78:	79a2                	ld	s3,40(sp)
ffffffffc0204a7a:	7a02                	ld	s4,32(sp)
ffffffffc0204a7c:	6ae2                	ld	s5,24(sp)
ffffffffc0204a7e:	6161                	addi	sp,sp,80
ffffffffc0204a80:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a82:	495d                	li	s2,23
ffffffffc0204a84:	bf41                	j	ffffffffc0204a14 <do_pgfault+0x42>
    else if((*ptep&PTE_V)&&(error_code&3==3)){
ffffffffc0204a86:	0019f993          	andi	s3,s3,1
ffffffffc0204a8a:	fa0984e3          	beqz	s3,ffffffffc0204a32 <do_pgfault+0x60>
    if (PPN(pa) >= npage) {
ffffffffc0204a8e:	000a8a17          	auipc	s4,0xa8
ffffffffc0204a92:	e22a0a13          	addi	s4,s4,-478 # ffffffffc02ac8b0 <npage>
ffffffffc0204a96:	000a3703          	ld	a4,0(s4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204a9a:	078a                	slli	a5,a5,0x2
ffffffffc0204a9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204a9e:	0ee7f963          	bgeu	a5,a4,ffffffffc0204b90 <do_pgfault+0x1be>
    return &pages[PPN(pa) - nbase];
ffffffffc0204aa2:	00004717          	auipc	a4,0x4
ffffffffc0204aa6:	30670713          	addi	a4,a4,774 # ffffffffc0208da8 <nbase>
ffffffffc0204aaa:	00073983          	ld	s3,0(a4)
ffffffffc0204aae:	000a8a97          	auipc	s5,0xa8
ffffffffc0204ab2:	e72a8a93          	addi	s5,s5,-398 # ffffffffc02ac920 <pages>
ffffffffc0204ab6:	000ab683          	ld	a3,0(s5)
        struct Page*npage=pgdir_alloc_page(mm->pgdir,addr,perm);
ffffffffc0204aba:	6c88                	ld	a0,24(s1)
ffffffffc0204abc:	413787b3          	sub	a5,a5,s3
ffffffffc0204ac0:	079a                	slli	a5,a5,0x6
ffffffffc0204ac2:	85a2                	mv	a1,s0
ffffffffc0204ac4:	864a                	mv	a2,s2
ffffffffc0204ac6:	00f68433          	add	s0,a3,a5
ffffffffc0204aca:	851fe0ef          	jal	ra,ffffffffc020331a <pgdir_alloc_page>
    return page - pages + nbase;
ffffffffc0204ace:	000ab783          	ld	a5,0(s5)
    return KADDR(page2pa(page));
ffffffffc0204ad2:	577d                	li	a4,-1
ffffffffc0204ad4:	000a3603          	ld	a2,0(s4)
    return page - pages + nbase;
ffffffffc0204ad8:	40f406b3          	sub	a3,s0,a5
ffffffffc0204adc:	8699                	srai	a3,a3,0x6
ffffffffc0204ade:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0204ae0:	8331                	srli	a4,a4,0xc
ffffffffc0204ae2:	00e6f5b3          	and	a1,a3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ae6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ae8:	08c5f863          	bgeu	a1,a2,ffffffffc0204b78 <do_pgfault+0x1a6>
    return page - pages + nbase;
ffffffffc0204aec:	40f507b3          	sub	a5,a0,a5
    return KADDR(page2pa(page));
ffffffffc0204af0:	000a8597          	auipc	a1,0xa8
ffffffffc0204af4:	e2058593          	addi	a1,a1,-480 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0204af8:	6188                	ld	a0,0(a1)
    return page - pages + nbase;
ffffffffc0204afa:	8799                	srai	a5,a5,0x6
ffffffffc0204afc:	97ce                	add	a5,a5,s3
    return KADDR(page2pa(page));
ffffffffc0204afe:	8f7d                	and	a4,a4,a5
ffffffffc0204b00:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b04:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204b06:	06c77863          	bgeu	a4,a2,ffffffffc0204b76 <do_pgfault+0x1a4>
        memcpy(dst_kvaddr,src_kvaddr,PGSIZE);
ffffffffc0204b0a:	6605                	lui	a2,0x1
ffffffffc0204b0c:	953e                	add	a0,a0,a5
ffffffffc0204b0e:	3b3010ef          	jal	ra,ffffffffc02066c0 <memcpy>
   ret = 0;
ffffffffc0204b12:	4981                	li	s3,0
    else if((*ptep&PTE_V)&&(error_code&3==3)){
ffffffffc0204b14:	bfa9                	j	ffffffffc0204a6e <do_pgfault+0x9c>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204b16:	6c88                	ld	a0,24(s1)
ffffffffc0204b18:	864a                	mv	a2,s2
ffffffffc0204b1a:	85a2                	mv	a1,s0
ffffffffc0204b1c:	ffefe0ef          	jal	ra,ffffffffc020331a <pgdir_alloc_page>
   ret = 0;
ffffffffc0204b20:	4981                	li	s3,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204b22:	f531                	bnez	a0,ffffffffc0204a6e <do_pgfault+0x9c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204b24:	00003517          	auipc	a0,0x3
ffffffffc0204b28:	61450513          	addi	a0,a0,1556 # ffffffffc0208138 <default_pmm_manager+0xd28>
ffffffffc0204b2c:	e62fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204b30:	59f1                	li	s3,-4
            goto failed;
ffffffffc0204b32:	bf35                	j	ffffffffc0204a6e <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0204b34:	00003517          	auipc	a0,0x3
ffffffffc0204b38:	62c50513          	addi	a0,a0,1580 # ffffffffc0208160 <default_pmm_manager+0xd50>
ffffffffc0204b3c:	e52fb0ef          	jal	ra,ffffffffc020018e <cprintf>
                goto failed;
ffffffffc0204b40:	b73d                	j	ffffffffc0204a6e <do_pgfault+0x9c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204b42:	85a2                	mv	a1,s0
ffffffffc0204b44:	00003517          	auipc	a0,0x3
ffffffffc0204b48:	5a450513          	addi	a0,a0,1444 # ffffffffc02080e8 <default_pmm_manager+0xcd8>
ffffffffc0204b4c:	e42fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204b50:	59f5                	li	s3,-3
        goto failed;
ffffffffc0204b52:	bf31                	j	ffffffffc0204a6e <do_pgfault+0x9c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204b54:	85be                	mv	a1,a5
ffffffffc0204b56:	00003517          	auipc	a0,0x3
ffffffffc0204b5a:	62a50513          	addi	a0,a0,1578 # ffffffffc0208180 <default_pmm_manager+0xd70>
ffffffffc0204b5e:	e30fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204b62:	59f1                	li	s3,-4
            goto failed;
ffffffffc0204b64:	b729                	j	ffffffffc0204a6e <do_pgfault+0x9c>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204b66:	00003517          	auipc	a0,0x3
ffffffffc0204b6a:	5b250513          	addi	a0,a0,1458 # ffffffffc0208118 <default_pmm_manager+0xd08>
ffffffffc0204b6e:	e20fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204b72:	59f1                	li	s3,-4
        goto failed;
ffffffffc0204b74:	bded                	j	ffffffffc0204a6e <do_pgfault+0x9c>
ffffffffc0204b76:	86be                	mv	a3,a5
ffffffffc0204b78:	00003617          	auipc	a2,0x3
ffffffffc0204b7c:	8e860613          	addi	a2,a2,-1816 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0204b80:	06900593          	li	a1,105
ffffffffc0204b84:	00003517          	auipc	a0,0x3
ffffffffc0204b88:	90450513          	addi	a0,a0,-1788 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0204b8c:	8f5fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204b90:	d58ff0ef          	jal	ra,ffffffffc02040e8 <pa2page.part.2>

ffffffffc0204b94 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204b94:	7179                	addi	sp,sp,-48
ffffffffc0204b96:	f022                	sd	s0,32(sp)
ffffffffc0204b98:	f406                	sd	ra,40(sp)
ffffffffc0204b9a:	ec26                	sd	s1,24(sp)
ffffffffc0204b9c:	e84a                	sd	s2,16(sp)
ffffffffc0204b9e:	e44e                	sd	s3,8(sp)
ffffffffc0204ba0:	e052                	sd	s4,0(sp)
ffffffffc0204ba2:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204ba4:	c135                	beqz	a0,ffffffffc0204c08 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204ba6:	002007b7          	lui	a5,0x200
ffffffffc0204baa:	04f5e663          	bltu	a1,a5,ffffffffc0204bf6 <user_mem_check+0x62>
ffffffffc0204bae:	00c584b3          	add	s1,a1,a2
ffffffffc0204bb2:	0495f263          	bgeu	a1,s1,ffffffffc0204bf6 <user_mem_check+0x62>
ffffffffc0204bb6:	4785                	li	a5,1
ffffffffc0204bb8:	07fe                	slli	a5,a5,0x1f
ffffffffc0204bba:	0297ee63          	bltu	a5,s1,ffffffffc0204bf6 <user_mem_check+0x62>
ffffffffc0204bbe:	892a                	mv	s2,a0
ffffffffc0204bc0:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204bc2:	6a05                	lui	s4,0x1
ffffffffc0204bc4:	a821                	j	ffffffffc0204bdc <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204bc6:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204bca:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204bcc:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204bce:	c685                	beqz	a3,ffffffffc0204bf6 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204bd0:	c399                	beqz	a5,ffffffffc0204bd6 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204bd2:	02e46263          	bltu	s0,a4,ffffffffc0204bf6 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204bd6:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204bd8:	04947663          	bgeu	s0,s1,ffffffffc0204c24 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204bdc:	85a2                	mv	a1,s0
ffffffffc0204bde:	854a                	mv	a0,s2
ffffffffc0204be0:	d9eff0ef          	jal	ra,ffffffffc020417e <find_vma>
ffffffffc0204be4:	c909                	beqz	a0,ffffffffc0204bf6 <user_mem_check+0x62>
ffffffffc0204be6:	6518                	ld	a4,8(a0)
ffffffffc0204be8:	00e46763          	bltu	s0,a4,ffffffffc0204bf6 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204bec:	4d1c                	lw	a5,24(a0)
ffffffffc0204bee:	fc099ce3          	bnez	s3,ffffffffc0204bc6 <user_mem_check+0x32>
ffffffffc0204bf2:	8b85                	andi	a5,a5,1
ffffffffc0204bf4:	f3ed                	bnez	a5,ffffffffc0204bd6 <user_mem_check+0x42>
            return 0;
ffffffffc0204bf6:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204bf8:	70a2                	ld	ra,40(sp)
ffffffffc0204bfa:	7402                	ld	s0,32(sp)
ffffffffc0204bfc:	64e2                	ld	s1,24(sp)
ffffffffc0204bfe:	6942                	ld	s2,16(sp)
ffffffffc0204c00:	69a2                	ld	s3,8(sp)
ffffffffc0204c02:	6a02                	ld	s4,0(sp)
ffffffffc0204c04:	6145                	addi	sp,sp,48
ffffffffc0204c06:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204c08:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c0c:	4501                	li	a0,0
ffffffffc0204c0e:	fef5e5e3          	bltu	a1,a5,ffffffffc0204bf8 <user_mem_check+0x64>
ffffffffc0204c12:	962e                	add	a2,a2,a1
ffffffffc0204c14:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204bf8 <user_mem_check+0x64>
ffffffffc0204c18:	c8000537          	lui	a0,0xc8000
ffffffffc0204c1c:	0505                	addi	a0,a0,1
ffffffffc0204c1e:	00a63533          	sltu	a0,a2,a0
ffffffffc0204c22:	bfd9                	j	ffffffffc0204bf8 <user_mem_check+0x64>
        return 1;
ffffffffc0204c24:	4505                	li	a0,1
ffffffffc0204c26:	bfc9                	j	ffffffffc0204bf8 <user_mem_check+0x64>

ffffffffc0204c28 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204c28:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204c2a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204c2c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204c2e:	9c9fb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc0204c32:	cd01                	beqz	a0,ffffffffc0204c4a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204c34:	4505                	li	a0,1
ffffffffc0204c36:	9c7fb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0204c3a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204c3c:	810d                	srli	a0,a0,0x3
ffffffffc0204c3e:	000a8797          	auipc	a5,0xa8
ffffffffc0204c42:	d6a7b923          	sd	a0,-654(a5) # ffffffffc02ac9b0 <max_swap_offset>
}
ffffffffc0204c46:	0141                	addi	sp,sp,16
ffffffffc0204c48:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204c4a:	00004617          	auipc	a2,0x4
ffffffffc0204c4e:	81e60613          	addi	a2,a2,-2018 # ffffffffc0208468 <default_pmm_manager+0x1058>
ffffffffc0204c52:	45b5                	li	a1,13
ffffffffc0204c54:	00004517          	auipc	a0,0x4
ffffffffc0204c58:	83450513          	addi	a0,a0,-1996 # ffffffffc0208488 <default_pmm_manager+0x1078>
ffffffffc0204c5c:	825fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204c60 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204c60:	1141                	addi	sp,sp,-16
ffffffffc0204c62:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c64:	00855793          	srli	a5,a0,0x8
ffffffffc0204c68:	cfb9                	beqz	a5,ffffffffc0204cc6 <swapfs_read+0x66>
ffffffffc0204c6a:	000a8717          	auipc	a4,0xa8
ffffffffc0204c6e:	d4670713          	addi	a4,a4,-698 # ffffffffc02ac9b0 <max_swap_offset>
ffffffffc0204c72:	6318                	ld	a4,0(a4)
ffffffffc0204c74:	04e7f963          	bgeu	a5,a4,ffffffffc0204cc6 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204c78:	000a8717          	auipc	a4,0xa8
ffffffffc0204c7c:	ca870713          	addi	a4,a4,-856 # ffffffffc02ac920 <pages>
ffffffffc0204c80:	6310                	ld	a2,0(a4)
ffffffffc0204c82:	00004717          	auipc	a4,0x4
ffffffffc0204c86:	12670713          	addi	a4,a4,294 # ffffffffc0208da8 <nbase>
ffffffffc0204c8a:	40c58633          	sub	a2,a1,a2
ffffffffc0204c8e:	630c                	ld	a1,0(a4)
ffffffffc0204c90:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c92:	000a8717          	auipc	a4,0xa8
ffffffffc0204c96:	c1e70713          	addi	a4,a4,-994 # ffffffffc02ac8b0 <npage>
    return page - pages + nbase;
ffffffffc0204c9a:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c9c:	6314                	ld	a3,0(a4)
ffffffffc0204c9e:	00c61713          	slli	a4,a2,0xc
ffffffffc0204ca2:	8331                	srli	a4,a4,0xc
ffffffffc0204ca4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ca8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204caa:	02d77a63          	bgeu	a4,a3,ffffffffc0204cde <swapfs_read+0x7e>
ffffffffc0204cae:	000a8797          	auipc	a5,0xa8
ffffffffc0204cb2:	c6278793          	addi	a5,a5,-926 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0204cb6:	639c                	ld	a5,0(a5)
}
ffffffffc0204cb8:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cba:	46a1                	li	a3,8
ffffffffc0204cbc:	963e                	add	a2,a2,a5
ffffffffc0204cbe:	4505                	li	a0,1
}
ffffffffc0204cc0:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cc2:	941fb06f          	j	ffffffffc0200602 <ide_read_secs>
ffffffffc0204cc6:	86aa                	mv	a3,a0
ffffffffc0204cc8:	00003617          	auipc	a2,0x3
ffffffffc0204ccc:	7d860613          	addi	a2,a2,2008 # ffffffffc02084a0 <default_pmm_manager+0x1090>
ffffffffc0204cd0:	45d1                	li	a1,20
ffffffffc0204cd2:	00003517          	auipc	a0,0x3
ffffffffc0204cd6:	7b650513          	addi	a0,a0,1974 # ffffffffc0208488 <default_pmm_manager+0x1078>
ffffffffc0204cda:	fa6fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204cde:	86b2                	mv	a3,a2
ffffffffc0204ce0:	06900593          	li	a1,105
ffffffffc0204ce4:	00002617          	auipc	a2,0x2
ffffffffc0204ce8:	77c60613          	addi	a2,a2,1916 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0204cec:	00002517          	auipc	a0,0x2
ffffffffc0204cf0:	79c50513          	addi	a0,a0,1948 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0204cf4:	f8cfb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204cf8 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204cf8:	1141                	addi	sp,sp,-16
ffffffffc0204cfa:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cfc:	00855793          	srli	a5,a0,0x8
ffffffffc0204d00:	cfb9                	beqz	a5,ffffffffc0204d5e <swapfs_write+0x66>
ffffffffc0204d02:	000a8717          	auipc	a4,0xa8
ffffffffc0204d06:	cae70713          	addi	a4,a4,-850 # ffffffffc02ac9b0 <max_swap_offset>
ffffffffc0204d0a:	6318                	ld	a4,0(a4)
ffffffffc0204d0c:	04e7f963          	bgeu	a5,a4,ffffffffc0204d5e <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204d10:	000a8717          	auipc	a4,0xa8
ffffffffc0204d14:	c1070713          	addi	a4,a4,-1008 # ffffffffc02ac920 <pages>
ffffffffc0204d18:	6310                	ld	a2,0(a4)
ffffffffc0204d1a:	00004717          	auipc	a4,0x4
ffffffffc0204d1e:	08e70713          	addi	a4,a4,142 # ffffffffc0208da8 <nbase>
ffffffffc0204d22:	40c58633          	sub	a2,a1,a2
ffffffffc0204d26:	630c                	ld	a1,0(a4)
ffffffffc0204d28:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204d2a:	000a8717          	auipc	a4,0xa8
ffffffffc0204d2e:	b8670713          	addi	a4,a4,-1146 # ffffffffc02ac8b0 <npage>
    return page - pages + nbase;
ffffffffc0204d32:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204d34:	6314                	ld	a3,0(a4)
ffffffffc0204d36:	00c61713          	slli	a4,a2,0xc
ffffffffc0204d3a:	8331                	srli	a4,a4,0xc
ffffffffc0204d3c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d40:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d42:	02d77a63          	bgeu	a4,a3,ffffffffc0204d76 <swapfs_write+0x7e>
ffffffffc0204d46:	000a8797          	auipc	a5,0xa8
ffffffffc0204d4a:	bca78793          	addi	a5,a5,-1078 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0204d4e:	639c                	ld	a5,0(a5)
}
ffffffffc0204d50:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d52:	46a1                	li	a3,8
ffffffffc0204d54:	963e                	add	a2,a2,a5
ffffffffc0204d56:	4505                	li	a0,1
}
ffffffffc0204d58:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d5a:	8cdfb06f          	j	ffffffffc0200626 <ide_write_secs>
ffffffffc0204d5e:	86aa                	mv	a3,a0
ffffffffc0204d60:	00003617          	auipc	a2,0x3
ffffffffc0204d64:	74060613          	addi	a2,a2,1856 # ffffffffc02084a0 <default_pmm_manager+0x1090>
ffffffffc0204d68:	45e5                	li	a1,25
ffffffffc0204d6a:	00003517          	auipc	a0,0x3
ffffffffc0204d6e:	71e50513          	addi	a0,a0,1822 # ffffffffc0208488 <default_pmm_manager+0x1078>
ffffffffc0204d72:	f0efb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204d76:	86b2                	mv	a3,a2
ffffffffc0204d78:	06900593          	li	a1,105
ffffffffc0204d7c:	00002617          	auipc	a2,0x2
ffffffffc0204d80:	6e460613          	addi	a2,a2,1764 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0204d84:	00002517          	auipc	a0,0x2
ffffffffc0204d88:	70450513          	addi	a0,a0,1796 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0204d8c:	ef4fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204d90 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204d90:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204d92:	9402                	jalr	s0

	jal do_exit
ffffffffc0204d94:	71e000ef          	jal	ra,ffffffffc02054b2 <do_exit>

ffffffffc0204d98 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204d98:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204d9a:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204d9e:	e022                	sd	s0,0(sp)
ffffffffc0204da0:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204da2:	e8bfc0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc0204da6:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204da8:	cd29                	beqz	a0,ffffffffc0204e02 <alloc_proc+0x6a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state=PROC_UNINIT;
ffffffffc0204daa:	57fd                	li	a5,-1
ffffffffc0204dac:	1782                	slli	a5,a5,0x20
ffffffffc0204dae:	e11c                	sd	a5,0(a0)
        proc->runs=0;
        proc->kstack=0;
        proc->need_resched=0;
        proc->parent=NULL;
        proc->mm=NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204db0:	07000613          	li	a2,112
ffffffffc0204db4:	4581                	li	a1,0
        proc->runs=0;
ffffffffc0204db6:	00052423          	sw	zero,8(a0)
        proc->kstack=0;
ffffffffc0204dba:	00053823          	sd	zero,16(a0)
        proc->need_resched=0;
ffffffffc0204dbe:	00053c23          	sd	zero,24(a0)
        proc->parent=NULL;
ffffffffc0204dc2:	02053023          	sd	zero,32(a0)
        proc->mm=NULL;
ffffffffc0204dc6:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204dca:	03050513          	addi	a0,a0,48
ffffffffc0204dce:	0e1010ef          	jal	ra,ffffffffc02066ae <memset>
        proc->tf=NULL;
        proc->cr3=boot_cr3;
ffffffffc0204dd2:	000a8797          	auipc	a5,0xa8
ffffffffc0204dd6:	b4678793          	addi	a5,a5,-1210 # ffffffffc02ac918 <boot_cr3>
ffffffffc0204dda:	639c                	ld	a5,0(a5)
        proc->tf=NULL;
ffffffffc0204ddc:	0a043023          	sd	zero,160(s0)
        proc->flags=0;
ffffffffc0204de0:	0a042823          	sw	zero,176(s0)
        proc->cr3=boot_cr3;
ffffffffc0204de4:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204de6:	463d                	li	a2,15
ffffffffc0204de8:	4581                	li	a1,0
ffffffffc0204dea:	0b440513          	addi	a0,s0,180
ffffffffc0204dee:	0c1010ef          	jal	ra,ffffffffc02066ae <memset>
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */

        // LAB5新增字段初始化
        proc->wait_state = 0; // 初始化等待状态为0
ffffffffc0204df2:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;    // 初始化子进程指针为NULL
ffffffffc0204df6:	0e043823          	sd	zero,240(s0)
        proc->yptr = NULL;    // 初始化年轻兄弟进程指针为NULL
ffffffffc0204dfa:	0e043c23          	sd	zero,248(s0)
        proc->optr = NULL;    // 初始化老兄弟进程指针为NULL
ffffffffc0204dfe:	10043023          	sd	zero,256(s0)
    }
    return proc;
}
ffffffffc0204e02:	8522                	mv	a0,s0
ffffffffc0204e04:	60a2                	ld	ra,8(sp)
ffffffffc0204e06:	6402                	ld	s0,0(sp)
ffffffffc0204e08:	0141                	addi	sp,sp,16
ffffffffc0204e0a:	8082                	ret

ffffffffc0204e0c <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204e0c:	000a8797          	auipc	a5,0xa8
ffffffffc0204e10:	abc78793          	addi	a5,a5,-1348 # ffffffffc02ac8c8 <current>
ffffffffc0204e14:	639c                	ld	a5,0(a5)
ffffffffc0204e16:	73c8                	ld	a0,160(a5)
ffffffffc0204e18:	f7bfb06f          	j	ffffffffc0200d92 <forkrets>

ffffffffc0204e1c <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc0204e1c:	000a8797          	auipc	a5,0xa8
ffffffffc0204e20:	aac78793          	addi	a5,a5,-1364 # ffffffffc02ac8c8 <current>
ffffffffc0204e24:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204e26:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc0204e28:	00004617          	auipc	a2,0x4
ffffffffc0204e2c:	a5860613          	addi	a2,a2,-1448 # ffffffffc0208880 <default_pmm_manager+0x1470>
ffffffffc0204e30:	43cc                	lw	a1,4(a5)
ffffffffc0204e32:	00004517          	auipc	a0,0x4
ffffffffc0204e36:	a5650513          	addi	a0,a0,-1450 # ffffffffc0208888 <default_pmm_manager+0x1478>
user_main(void *arg) {
ffffffffc0204e3a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204e3c:	b52fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204e40:	00004797          	auipc	a5,0x4
ffffffffc0204e44:	a4078793          	addi	a5,a5,-1472 # ffffffffc0208880 <default_pmm_manager+0x1470>
ffffffffc0204e48:	3fe06717          	auipc	a4,0x3fe06
ffffffffc0204e4c:	c9070713          	addi	a4,a4,-880 # aad8 <_binary_obj___user_exit_out_size>
ffffffffc0204e50:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204e52:	853e                	mv	a0,a5
ffffffffc0204e54:	00025717          	auipc	a4,0x25
ffffffffc0204e58:	41470713          	addi	a4,a4,1044 # ffffffffc022a268 <_binary_obj___user_exit_out_start>
ffffffffc0204e5c:	f03a                	sd	a4,32(sp)
ffffffffc0204e5e:	f43e                	sd	a5,40(sp)
ffffffffc0204e60:	e802                	sd	zero,16(sp)
ffffffffc0204e62:	7ae010ef          	jal	ra,ffffffffc0206610 <strlen>
ffffffffc0204e66:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204e68:	4511                	li	a0,4
ffffffffc0204e6a:	55a2                	lw	a1,40(sp)
ffffffffc0204e6c:	4662                	lw	a2,24(sp)
ffffffffc0204e6e:	5682                	lw	a3,32(sp)
ffffffffc0204e70:	4722                	lw	a4,8(sp)
ffffffffc0204e72:	48a9                	li	a7,10
ffffffffc0204e74:	9002                	ebreak
ffffffffc0204e76:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204e78:	65c2                	ld	a1,16(sp)
ffffffffc0204e7a:	00004517          	auipc	a0,0x4
ffffffffc0204e7e:	a3650513          	addi	a0,a0,-1482 # ffffffffc02088b0 <default_pmm_manager+0x14a0>
ffffffffc0204e82:	b0cfb0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204e86:	00004617          	auipc	a2,0x4
ffffffffc0204e8a:	a3a60613          	addi	a2,a2,-1478 # ffffffffc02088c0 <default_pmm_manager+0x14b0>
ffffffffc0204e8e:	3aa00593          	li	a1,938
ffffffffc0204e92:	00004517          	auipc	a0,0x4
ffffffffc0204e96:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0204e9a:	de6fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204e9e <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204e9e:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204ea0:	1141                	addi	sp,sp,-16
ffffffffc0204ea2:	e406                	sd	ra,8(sp)
ffffffffc0204ea4:	c02007b7          	lui	a5,0xc0200
ffffffffc0204ea8:	04f6e263          	bltu	a3,a5,ffffffffc0204eec <put_pgdir+0x4e>
ffffffffc0204eac:	000a8797          	auipc	a5,0xa8
ffffffffc0204eb0:	a6478793          	addi	a5,a5,-1436 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0204eb4:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204eb6:	000a8797          	auipc	a5,0xa8
ffffffffc0204eba:	9fa78793          	addi	a5,a5,-1542 # ffffffffc02ac8b0 <npage>
ffffffffc0204ebe:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204ec0:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204ec2:	82b1                	srli	a3,a3,0xc
ffffffffc0204ec4:	04f6f063          	bgeu	a3,a5,ffffffffc0204f04 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204ec8:	00004797          	auipc	a5,0x4
ffffffffc0204ecc:	ee078793          	addi	a5,a5,-288 # ffffffffc0208da8 <nbase>
ffffffffc0204ed0:	639c                	ld	a5,0(a5)
ffffffffc0204ed2:	000a8717          	auipc	a4,0xa8
ffffffffc0204ed6:	a4e70713          	addi	a4,a4,-1458 # ffffffffc02ac920 <pages>
ffffffffc0204eda:	6308                	ld	a0,0(a4)
}
ffffffffc0204edc:	60a2                	ld	ra,8(sp)
ffffffffc0204ede:	8e9d                	sub	a3,a3,a5
ffffffffc0204ee0:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204ee2:	4585                	li	a1,1
ffffffffc0204ee4:	9536                	add	a0,a0,a3
}
ffffffffc0204ee6:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204ee8:	fc5fc06f          	j	ffffffffc0201eac <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204eec:	00002617          	auipc	a2,0x2
ffffffffc0204ef0:	5ac60613          	addi	a2,a2,1452 # ffffffffc0207498 <default_pmm_manager+0x88>
ffffffffc0204ef4:	06e00593          	li	a1,110
ffffffffc0204ef8:	00002517          	auipc	a0,0x2
ffffffffc0204efc:	59050513          	addi	a0,a0,1424 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0204f00:	d80fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204f04:	00002617          	auipc	a2,0x2
ffffffffc0204f08:	5bc60613          	addi	a2,a2,1468 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc0204f0c:	06200593          	li	a1,98
ffffffffc0204f10:	00002517          	auipc	a0,0x2
ffffffffc0204f14:	57850513          	addi	a0,a0,1400 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0204f18:	d68fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204f1c <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204f1c:	1101                	addi	sp,sp,-32
ffffffffc0204f1e:	e426                	sd	s1,8(sp)
ffffffffc0204f20:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204f22:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204f24:	ec06                	sd	ra,24(sp)
ffffffffc0204f26:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204f28:	efdfc0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0204f2c:	c125                	beqz	a0,ffffffffc0204f8c <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204f2e:	000a8797          	auipc	a5,0xa8
ffffffffc0204f32:	9f278793          	addi	a5,a5,-1550 # ffffffffc02ac920 <pages>
ffffffffc0204f36:	6394                	ld	a3,0(a5)
ffffffffc0204f38:	00004797          	auipc	a5,0x4
ffffffffc0204f3c:	e7078793          	addi	a5,a5,-400 # ffffffffc0208da8 <nbase>
ffffffffc0204f40:	6380                	ld	s0,0(a5)
ffffffffc0204f42:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204f46:	000a8797          	auipc	a5,0xa8
ffffffffc0204f4a:	96a78793          	addi	a5,a5,-1686 # ffffffffc02ac8b0 <npage>
    return page - pages + nbase;
ffffffffc0204f4e:	8699                	srai	a3,a3,0x6
ffffffffc0204f50:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204f52:	6398                	ld	a4,0(a5)
ffffffffc0204f54:	00c69793          	slli	a5,a3,0xc
ffffffffc0204f58:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f5a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f5c:	02e7fa63          	bgeu	a5,a4,ffffffffc0204f90 <setup_pgdir+0x74>
ffffffffc0204f60:	000a8797          	auipc	a5,0xa8
ffffffffc0204f64:	9b078793          	addi	a5,a5,-1616 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0204f68:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204f6a:	000a8797          	auipc	a5,0xa8
ffffffffc0204f6e:	93e78793          	addi	a5,a5,-1730 # ffffffffc02ac8a8 <boot_pgdir>
ffffffffc0204f72:	638c                	ld	a1,0(a5)
ffffffffc0204f74:	9436                	add	s0,s0,a3
ffffffffc0204f76:	6605                	lui	a2,0x1
ffffffffc0204f78:	8522                	mv	a0,s0
ffffffffc0204f7a:	746010ef          	jal	ra,ffffffffc02066c0 <memcpy>
    return 0;
ffffffffc0204f7e:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204f80:	ec80                	sd	s0,24(s1)
}
ffffffffc0204f82:	60e2                	ld	ra,24(sp)
ffffffffc0204f84:	6442                	ld	s0,16(sp)
ffffffffc0204f86:	64a2                	ld	s1,8(sp)
ffffffffc0204f88:	6105                	addi	sp,sp,32
ffffffffc0204f8a:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204f8c:	5571                	li	a0,-4
ffffffffc0204f8e:	bfd5                	j	ffffffffc0204f82 <setup_pgdir+0x66>
ffffffffc0204f90:	00002617          	auipc	a2,0x2
ffffffffc0204f94:	4d060613          	addi	a2,a2,1232 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0204f98:	06900593          	li	a1,105
ffffffffc0204f9c:	00002517          	auipc	a0,0x2
ffffffffc0204fa0:	4ec50513          	addi	a0,a0,1260 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0204fa4:	cdcfb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204fa8 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204fa8:	1101                	addi	sp,sp,-32
ffffffffc0204faa:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fac:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204fb0:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fb2:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204fb4:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fb6:	8522                	mv	a0,s0
ffffffffc0204fb8:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204fba:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fbc:	6f2010ef          	jal	ra,ffffffffc02066ae <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204fc0:	8522                	mv	a0,s0
}
ffffffffc0204fc2:	6442                	ld	s0,16(sp)
ffffffffc0204fc4:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204fc6:	85a6                	mv	a1,s1
}
ffffffffc0204fc8:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204fca:	463d                	li	a2,15
}
ffffffffc0204fcc:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204fce:	6f20106f          	j	ffffffffc02066c0 <memcpy>

ffffffffc0204fd2 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204fd2:	1101                	addi	sp,sp,-32
ffffffffc0204fd4:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204fd6:	000a8497          	auipc	s1,0xa8
ffffffffc0204fda:	8f248493          	addi	s1,s1,-1806 # ffffffffc02ac8c8 <current>
ffffffffc0204fde:	6098                	ld	a4,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc0204fe0:	ec06                	sd	ra,24(sp)
ffffffffc0204fe2:	e822                	sd	s0,16(sp)
ffffffffc0204fe4:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204fe6:	02a70b63          	beq	a4,a0,ffffffffc020501c <proc_run+0x4a>
ffffffffc0204fea:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204fec:	100027f3          	csrr	a5,sstatus
ffffffffc0204ff0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204ff2:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ff4:	e3a9                	bnez	a5,ffffffffc0205036 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204ff6:	745c                	ld	a5,168(s0)
        current = proc;//切换到新进程
ffffffffc0204ff8:	000a8697          	auipc	a3,0xa8
ffffffffc0204ffc:	8c86b823          	sd	s0,-1840(a3) # ffffffffc02ac8c8 <current>
ffffffffc0205000:	56fd                	li	a3,-1
ffffffffc0205002:	16fe                	slli	a3,a3,0x3f
ffffffffc0205004:	83b1                	srli	a5,a5,0xc
ffffffffc0205006:	8fd5                	or	a5,a5,a3
ffffffffc0205008:	18079073          	csrw	satp,a5
        switch_to(&(temp->context),&(proc->context));
ffffffffc020500c:	03040593          	addi	a1,s0,48
ffffffffc0205010:	03070513          	addi	a0,a4,48
ffffffffc0205014:	79d000ef          	jal	ra,ffffffffc0205fb0 <switch_to>
    if (flag) {
ffffffffc0205018:	00091863          	bnez	s2,ffffffffc0205028 <proc_run+0x56>
}
ffffffffc020501c:	60e2                	ld	ra,24(sp)
ffffffffc020501e:	6442                	ld	s0,16(sp)
ffffffffc0205020:	64a2                	ld	s1,8(sp)
ffffffffc0205022:	6902                	ld	s2,0(sp)
ffffffffc0205024:	6105                	addi	sp,sp,32
ffffffffc0205026:	8082                	ret
ffffffffc0205028:	6442                	ld	s0,16(sp)
ffffffffc020502a:	60e2                	ld	ra,24(sp)
ffffffffc020502c:	64a2                	ld	s1,8(sp)
ffffffffc020502e:	6902                	ld	s2,0(sp)
ffffffffc0205030:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205032:	e1afb06f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0205036:	e1cfb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc020503a:	6098                	ld	a4,0(s1)
ffffffffc020503c:	4905                	li	s2,1
ffffffffc020503e:	bf65                	j	ffffffffc0204ff6 <proc_run+0x24>

ffffffffc0205040 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205040:	0005071b          	sext.w	a4,a0
ffffffffc0205044:	6789                	lui	a5,0x2
ffffffffc0205046:	fff7069b          	addiw	a3,a4,-1
ffffffffc020504a:	17f9                	addi	a5,a5,-2
ffffffffc020504c:	04d7e063          	bltu	a5,a3,ffffffffc020508c <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0205050:	1141                	addi	sp,sp,-16
ffffffffc0205052:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205054:	45a9                	li	a1,10
ffffffffc0205056:	842a                	mv	s0,a0
ffffffffc0205058:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc020505a:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020505c:	1b0010ef          	jal	ra,ffffffffc020620c <hash32>
ffffffffc0205060:	02051693          	slli	a3,a0,0x20
ffffffffc0205064:	82f1                	srli	a3,a3,0x1c
ffffffffc0205066:	000a4517          	auipc	a0,0xa4
ffffffffc020506a:	82a50513          	addi	a0,a0,-2006 # ffffffffc02a8890 <hash_list>
ffffffffc020506e:	96aa                	add	a3,a3,a0
ffffffffc0205070:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205072:	a029                	j	ffffffffc020507c <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0205074:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x76a4>
ffffffffc0205078:	00870c63          	beq	a4,s0,ffffffffc0205090 <find_proc+0x50>
ffffffffc020507c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020507e:	fef69be3          	bne	a3,a5,ffffffffc0205074 <find_proc+0x34>
}
ffffffffc0205082:	60a2                	ld	ra,8(sp)
ffffffffc0205084:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0205086:	4501                	li	a0,0
}
ffffffffc0205088:	0141                	addi	sp,sp,16
ffffffffc020508a:	8082                	ret
    return NULL;
ffffffffc020508c:	4501                	li	a0,0
}
ffffffffc020508e:	8082                	ret
ffffffffc0205090:	60a2                	ld	ra,8(sp)
ffffffffc0205092:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205094:	f2878513          	addi	a0,a5,-216
}
ffffffffc0205098:	0141                	addi	sp,sp,16
ffffffffc020509a:	8082                	ret

ffffffffc020509c <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020509c:	715d                	addi	sp,sp,-80
ffffffffc020509e:	f84a                	sd	s2,48(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02050a0:	000a8917          	auipc	s2,0xa8
ffffffffc02050a4:	84090913          	addi	s2,s2,-1984 # ffffffffc02ac8e0 <nr_process>
ffffffffc02050a8:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02050ac:	e486                	sd	ra,72(sp)
ffffffffc02050ae:	e0a2                	sd	s0,64(sp)
ffffffffc02050b0:	fc26                	sd	s1,56(sp)
ffffffffc02050b2:	f44e                	sd	s3,40(sp)
ffffffffc02050b4:	f052                	sd	s4,32(sp)
ffffffffc02050b6:	ec56                	sd	s5,24(sp)
ffffffffc02050b8:	e85a                	sd	s6,16(sp)
ffffffffc02050ba:	e45e                	sd	s7,8(sp)
ffffffffc02050bc:	e062                	sd	s8,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02050be:	6785                	lui	a5,0x1
ffffffffc02050c0:	32f75263          	bge	a4,a5,ffffffffc02053e4 <do_fork+0x348>
ffffffffc02050c4:	8aaa                	mv	s5,a0
ffffffffc02050c6:	89ae                	mv	s3,a1
ffffffffc02050c8:	84b2                	mv	s1,a2
if ((proc = alloc_proc()) == NULL)
ffffffffc02050ca:	ccfff0ef          	jal	ra,ffffffffc0204d98 <alloc_proc>
ffffffffc02050ce:	842a                	mv	s0,a0
ffffffffc02050d0:	2a050763          	beqz	a0,ffffffffc020537e <do_fork+0x2e2>
current -> wait_state = 0;
ffffffffc02050d4:	000a7a17          	auipc	s4,0xa7
ffffffffc02050d8:	7f4a0a13          	addi	s4,s4,2036 # ffffffffc02ac8c8 <current>
ffffffffc02050dc:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02050e0:	4509                	li	a0,2
current -> wait_state = 0;
ffffffffc02050e2:	0e07a623          	sw	zero,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x84e4>
proc -> parent = current; // 设置子进程的父进程为当前进程
ffffffffc02050e6:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02050e8:	d3dfc0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
    if (page != NULL) {
ffffffffc02050ec:	2a050763          	beqz	a0,ffffffffc020539a <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc02050f0:	000a8797          	auipc	a5,0xa8
ffffffffc02050f4:	83078793          	addi	a5,a5,-2000 # ffffffffc02ac920 <pages>
ffffffffc02050f8:	6394                	ld	a3,0(a5)
ffffffffc02050fa:	00004797          	auipc	a5,0x4
ffffffffc02050fe:	cae78793          	addi	a5,a5,-850 # ffffffffc0208da8 <nbase>
ffffffffc0205102:	40d506b3          	sub	a3,a0,a3
ffffffffc0205106:	6388                	ld	a0,0(a5)
ffffffffc0205108:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020510a:	000a7797          	auipc	a5,0xa7
ffffffffc020510e:	7a678793          	addi	a5,a5,1958 # ffffffffc02ac8b0 <npage>
    return page - pages + nbase;
ffffffffc0205112:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0205114:	6398                	ld	a4,0(a5)
ffffffffc0205116:	00c69793          	slli	a5,a3,0xc
ffffffffc020511a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020511c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020511e:	2ce7f563          	bgeu	a5,a4,ffffffffc02053e8 <do_fork+0x34c>
ffffffffc0205122:	000a7b17          	auipc	s6,0xa7
ffffffffc0205126:	7eeb0b13          	addi	s6,s6,2030 # ffffffffc02ac910 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020512a:	000a3703          	ld	a4,0(s4)
ffffffffc020512e:	000b3783          	ld	a5,0(s6)
ffffffffc0205132:	02873a03          	ld	s4,40(a4)
ffffffffc0205136:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205138:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc020513a:	020a0863          	beqz	s4,ffffffffc020516a <do_fork+0xce>
    if (clone_flags & CLONE_VM) {
ffffffffc020513e:	100afa93          	andi	s5,s5,256
ffffffffc0205142:	1e0a8163          	beqz	s5,ffffffffc0205324 <do_fork+0x288>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205146:	030a2703          	lw	a4,48(s4)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020514a:	018a3783          	ld	a5,24(s4)
ffffffffc020514e:	c02006b7          	lui	a3,0xc0200
ffffffffc0205152:	2705                	addiw	a4,a4,1
ffffffffc0205154:	02ea2823          	sw	a4,48(s4)
    proc->mm = mm;
ffffffffc0205158:	03443423          	sd	s4,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020515c:	2ad7e263          	bltu	a5,a3,ffffffffc0205400 <do_fork+0x364>
ffffffffc0205160:	000b3703          	ld	a4,0(s6)
ffffffffc0205164:	6814                	ld	a3,16(s0)
ffffffffc0205166:	8f99                	sub	a5,a5,a4
ffffffffc0205168:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020516a:	6789                	lui	a5,0x2
ffffffffc020516c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76f0>
ffffffffc0205170:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205172:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205174:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205176:	87b6                	mv	a5,a3
ffffffffc0205178:	12048893          	addi	a7,s1,288
ffffffffc020517c:	00063803          	ld	a6,0(a2)
ffffffffc0205180:	6608                	ld	a0,8(a2)
ffffffffc0205182:	6a0c                	ld	a1,16(a2)
ffffffffc0205184:	6e18                	ld	a4,24(a2)
ffffffffc0205186:	0107b023          	sd	a6,0(a5)
ffffffffc020518a:	e788                	sd	a0,8(a5)
ffffffffc020518c:	eb8c                	sd	a1,16(a5)
ffffffffc020518e:	ef98                	sd	a4,24(a5)
ffffffffc0205190:	02060613          	addi	a2,a2,32
ffffffffc0205194:	02078793          	addi	a5,a5,32
ffffffffc0205198:	ff1612e3          	bne	a2,a7,ffffffffc020517c <do_fork+0xe0>
    proc->tf->gpr.a0 = 0;
ffffffffc020519c:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051a0:	12098b63          	beqz	s3,ffffffffc02052d6 <do_fork+0x23a>
ffffffffc02051a4:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051a8:	00000797          	auipc	a5,0x0
ffffffffc02051ac:	c6478793          	addi	a5,a5,-924 # ffffffffc0204e0c <forkret>
ffffffffc02051b0:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02051b2:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051b4:	100027f3          	csrr	a5,sstatus
ffffffffc02051b8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02051ba:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051bc:	12079c63          	bnez	a5,ffffffffc02052f4 <do_fork+0x258>
    if (++ last_pid >= MAX_PID) {
ffffffffc02051c0:	0009c797          	auipc	a5,0x9c
ffffffffc02051c4:	2c878793          	addi	a5,a5,712 # ffffffffc02a1488 <last_pid.1691>
ffffffffc02051c8:	439c                	lw	a5,0(a5)
ffffffffc02051ca:	6709                	lui	a4,0x2
ffffffffc02051cc:	0017851b          	addiw	a0,a5,1
ffffffffc02051d0:	0009c697          	auipc	a3,0x9c
ffffffffc02051d4:	2aa6ac23          	sw	a0,696(a3) # ffffffffc02a1488 <last_pid.1691>
ffffffffc02051d8:	12e55f63          	bge	a0,a4,ffffffffc0205316 <do_fork+0x27a>
    if (last_pid >= next_safe) {
ffffffffc02051dc:	0009c797          	auipc	a5,0x9c
ffffffffc02051e0:	2b078793          	addi	a5,a5,688 # ffffffffc02a148c <next_safe.1690>
ffffffffc02051e4:	439c                	lw	a5,0(a5)
ffffffffc02051e6:	000a8497          	auipc	s1,0xa8
ffffffffc02051ea:	82248493          	addi	s1,s1,-2014 # ffffffffc02aca08 <proc_list>
ffffffffc02051ee:	06f54063          	blt	a0,a5,ffffffffc020524e <do_fork+0x1b2>
        next_safe = MAX_PID;
ffffffffc02051f2:	6789                	lui	a5,0x2
ffffffffc02051f4:	0009c717          	auipc	a4,0x9c
ffffffffc02051f8:	28f72c23          	sw	a5,664(a4) # ffffffffc02a148c <next_safe.1690>
ffffffffc02051fc:	4581                	li	a1,0
ffffffffc02051fe:	87aa                	mv	a5,a0
ffffffffc0205200:	000a8497          	auipc	s1,0xa8
ffffffffc0205204:	80848493          	addi	s1,s1,-2040 # ffffffffc02aca08 <proc_list>
    repeat:
ffffffffc0205208:	6889                	lui	a7,0x2
ffffffffc020520a:	882e                	mv	a6,a1
ffffffffc020520c:	6609                	lui	a2,0x2
        le = list;
ffffffffc020520e:	000a7697          	auipc	a3,0xa7
ffffffffc0205212:	7fa68693          	addi	a3,a3,2042 # ffffffffc02aca08 <proc_list>
ffffffffc0205216:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0205218:	00968f63          	beq	a3,s1,ffffffffc0205236 <do_fork+0x19a>
            if (proc->pid == last_pid) {
ffffffffc020521c:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205220:	0ae78663          	beq	a5,a4,ffffffffc02052cc <do_fork+0x230>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205224:	fee7d9e3          	bge	a5,a4,ffffffffc0205216 <do_fork+0x17a>
ffffffffc0205228:	fec757e3          	bge	a4,a2,ffffffffc0205216 <do_fork+0x17a>
ffffffffc020522c:	6694                	ld	a3,8(a3)
ffffffffc020522e:	863a                	mv	a2,a4
ffffffffc0205230:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205232:	fe9695e3          	bne	a3,s1,ffffffffc020521c <do_fork+0x180>
ffffffffc0205236:	c591                	beqz	a1,ffffffffc0205242 <do_fork+0x1a6>
ffffffffc0205238:	0009c717          	auipc	a4,0x9c
ffffffffc020523c:	24f72823          	sw	a5,592(a4) # ffffffffc02a1488 <last_pid.1691>
ffffffffc0205240:	853e                	mv	a0,a5
ffffffffc0205242:	00080663          	beqz	a6,ffffffffc020524e <do_fork+0x1b2>
ffffffffc0205246:	0009c797          	auipc	a5,0x9c
ffffffffc020524a:	24c7a323          	sw	a2,582(a5) # ffffffffc02a148c <next_safe.1690>
        proc -> pid = get_pid(); // 为子进程分配一个唯一的进程ID
ffffffffc020524e:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205250:	45a9                	li	a1,10
ffffffffc0205252:	2501                	sext.w	a0,a0
ffffffffc0205254:	7b9000ef          	jal	ra,ffffffffc020620c <hash32>
ffffffffc0205258:	1502                	slli	a0,a0,0x20
ffffffffc020525a:	000a3797          	auipc	a5,0xa3
ffffffffc020525e:	63678793          	addi	a5,a5,1590 # ffffffffc02a8890 <hash_list>
ffffffffc0205262:	8171                	srli	a0,a0,0x1c
ffffffffc0205264:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205266:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205268:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020526a:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020526e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205270:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205272:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205274:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205276:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc020527a:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020527c:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020527e:	e21c                	sd	a5,0(a2)
ffffffffc0205280:	000a7597          	auipc	a1,0xa7
ffffffffc0205284:	78f5b823          	sd	a5,1936(a1) # ffffffffc02aca10 <proc_list+0x8>
    elm->next = next;
ffffffffc0205288:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc020528a:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc020528c:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205290:	10e43023          	sd	a4,256(s0)
ffffffffc0205294:	c311                	beqz	a4,ffffffffc0205298 <do_fork+0x1fc>
        proc->optr->yptr = proc;
ffffffffc0205296:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0205298:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc020529c:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc020529e:	2785                	addiw	a5,a5,1
ffffffffc02052a0:	000a7717          	auipc	a4,0xa7
ffffffffc02052a4:	64f72023          	sw	a5,1600(a4) # ffffffffc02ac8e0 <nr_process>
    if (flag) {
ffffffffc02052a8:	0c099d63          	bnez	s3,ffffffffc0205382 <do_fork+0x2e6>
wakeup_proc(proc);
ffffffffc02052ac:	8522                	mv	a0,s0
ffffffffc02052ae:	56d000ef          	jal	ra,ffffffffc020601a <wakeup_proc>
ret = proc -> pid;
ffffffffc02052b2:	4048                	lw	a0,4(s0)
}
ffffffffc02052b4:	60a6                	ld	ra,72(sp)
ffffffffc02052b6:	6406                	ld	s0,64(sp)
ffffffffc02052b8:	74e2                	ld	s1,56(sp)
ffffffffc02052ba:	7942                	ld	s2,48(sp)
ffffffffc02052bc:	79a2                	ld	s3,40(sp)
ffffffffc02052be:	7a02                	ld	s4,32(sp)
ffffffffc02052c0:	6ae2                	ld	s5,24(sp)
ffffffffc02052c2:	6b42                	ld	s6,16(sp)
ffffffffc02052c4:	6ba2                	ld	s7,8(sp)
ffffffffc02052c6:	6c02                	ld	s8,0(sp)
ffffffffc02052c8:	6161                	addi	sp,sp,80
ffffffffc02052ca:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02052cc:	2785                	addiw	a5,a5,1
ffffffffc02052ce:	0ac7dd63          	bge	a5,a2,ffffffffc0205388 <do_fork+0x2ec>
ffffffffc02052d2:	4585                	li	a1,1
ffffffffc02052d4:	b789                	j	ffffffffc0205216 <do_fork+0x17a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02052d6:	89b6                	mv	s3,a3
ffffffffc02052d8:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02052dc:	00000797          	auipc	a5,0x0
ffffffffc02052e0:	b3078793          	addi	a5,a5,-1232 # ffffffffc0204e0c <forkret>
ffffffffc02052e4:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02052e6:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052e8:	100027f3          	csrr	a5,sstatus
ffffffffc02052ec:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052ee:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052f0:	ec0788e3          	beqz	a5,ffffffffc02051c0 <do_fork+0x124>
        intr_disable();
ffffffffc02052f4:	b5efb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc02052f8:	0009c797          	auipc	a5,0x9c
ffffffffc02052fc:	19078793          	addi	a5,a5,400 # ffffffffc02a1488 <last_pid.1691>
ffffffffc0205300:	439c                	lw	a5,0(a5)
ffffffffc0205302:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205304:	4985                	li	s3,1
ffffffffc0205306:	0017851b          	addiw	a0,a5,1
ffffffffc020530a:	0009c697          	auipc	a3,0x9c
ffffffffc020530e:	16a6af23          	sw	a0,382(a3) # ffffffffc02a1488 <last_pid.1691>
ffffffffc0205312:	ece545e3          	blt	a0,a4,ffffffffc02051dc <do_fork+0x140>
        last_pid = 1;
ffffffffc0205316:	4785                	li	a5,1
ffffffffc0205318:	0009c717          	auipc	a4,0x9c
ffffffffc020531c:	16f72823          	sw	a5,368(a4) # ffffffffc02a1488 <last_pid.1691>
ffffffffc0205320:	4505                	li	a0,1
ffffffffc0205322:	bdc1                	j	ffffffffc02051f2 <do_fork+0x156>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205324:	de1fe0ef          	jal	ra,ffffffffc0204104 <mm_create>
ffffffffc0205328:	8c2a                	mv	s8,a0
ffffffffc020532a:	c539                	beqz	a0,ffffffffc0205378 <do_fork+0x2dc>
    if (setup_pgdir(mm) != 0) {
ffffffffc020532c:	bf1ff0ef          	jal	ra,ffffffffc0204f1c <setup_pgdir>
ffffffffc0205330:	e12d                	bnez	a0,ffffffffc0205392 <do_fork+0x2f6>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205332:	038a0a93          	addi	s5,s4,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205336:	4785                	li	a5,1
ffffffffc0205338:	40fab7af          	amoor.d	a5,a5,(s5)
ffffffffc020533c:	8b85                	andi	a5,a5,1
ffffffffc020533e:	4b85                	li	s7,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205340:	c799                	beqz	a5,ffffffffc020534e <do_fork+0x2b2>
        schedule();
ffffffffc0205342:	555000ef          	jal	ra,ffffffffc0206096 <schedule>
ffffffffc0205346:	417ab7af          	amoor.d	a5,s7,(s5)
ffffffffc020534a:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc020534c:	fbfd                	bnez	a5,ffffffffc0205342 <do_fork+0x2a6>
        ret = dup_mmap(mm, oldmm);
ffffffffc020534e:	85d2                	mv	a1,s4
ffffffffc0205350:	8562                	mv	a0,s8
ffffffffc0205352:	83cff0ef          	jal	ra,ffffffffc020438e <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205356:	57f9                	li	a5,-2
ffffffffc0205358:	60fab7af          	amoand.d	a5,a5,(s5)
ffffffffc020535c:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc020535e:	cfd5                	beqz	a5,ffffffffc020541a <do_fork+0x37e>
    if (ret != 0) {
ffffffffc0205360:	8a62                	mv	s4,s8
ffffffffc0205362:	de0502e3          	beqz	a0,ffffffffc0205146 <do_fork+0xaa>
    exit_mmap(mm);
ffffffffc0205366:	8562                	mv	a0,s8
ffffffffc0205368:	8c2ff0ef          	jal	ra,ffffffffc020442a <exit_mmap>
    put_pgdir(mm);
ffffffffc020536c:	8562                	mv	a0,s8
ffffffffc020536e:	b31ff0ef          	jal	ra,ffffffffc0204e9e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205372:	8562                	mv	a0,s8
ffffffffc0205374:	f17fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
    kfree(proc);
ffffffffc0205378:	8522                	mv	a0,s0
ffffffffc020537a:	96ffc0ef          	jal	ra,ffffffffc0201ce8 <kfree>
    ret = -E_NO_MEM;
ffffffffc020537e:	5571                	li	a0,-4
    return ret;
ffffffffc0205380:	bf15                	j	ffffffffc02052b4 <do_fork+0x218>
        intr_enable();
ffffffffc0205382:	acafb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205386:	b71d                	j	ffffffffc02052ac <do_fork+0x210>
                    if (last_pid >= MAX_PID) {
ffffffffc0205388:	0117c363          	blt	a5,a7,ffffffffc020538e <do_fork+0x2f2>
                        last_pid = 1;
ffffffffc020538c:	4785                	li	a5,1
                    goto repeat;
ffffffffc020538e:	4585                	li	a1,1
ffffffffc0205390:	bdad                	j	ffffffffc020520a <do_fork+0x16e>
    mm_destroy(mm);
ffffffffc0205392:	8562                	mv	a0,s8
ffffffffc0205394:	ef7fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
ffffffffc0205398:	b7c5                	j	ffffffffc0205378 <do_fork+0x2dc>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020539a:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020539c:	c02007b7          	lui	a5,0xc0200
ffffffffc02053a0:	0af6e563          	bltu	a3,a5,ffffffffc020544a <do_fork+0x3ae>
ffffffffc02053a4:	000a7797          	auipc	a5,0xa7
ffffffffc02053a8:	56c78793          	addi	a5,a5,1388 # ffffffffc02ac910 <va_pa_offset>
ffffffffc02053ac:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02053ae:	000a7717          	auipc	a4,0xa7
ffffffffc02053b2:	50270713          	addi	a4,a4,1282 # ffffffffc02ac8b0 <npage>
ffffffffc02053b6:	6318                	ld	a4,0(a4)
    return pa2page(PADDR(kva));
ffffffffc02053b8:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02053bc:	83b1                	srli	a5,a5,0xc
ffffffffc02053be:	06e7fa63          	bgeu	a5,a4,ffffffffc0205432 <do_fork+0x396>
    return &pages[PPN(pa) - nbase];
ffffffffc02053c2:	00004717          	auipc	a4,0x4
ffffffffc02053c6:	9e670713          	addi	a4,a4,-1562 # ffffffffc0208da8 <nbase>
ffffffffc02053ca:	6318                	ld	a4,0(a4)
ffffffffc02053cc:	000a7697          	auipc	a3,0xa7
ffffffffc02053d0:	55468693          	addi	a3,a3,1364 # ffffffffc02ac920 <pages>
ffffffffc02053d4:	6288                	ld	a0,0(a3)
ffffffffc02053d6:	8f99                	sub	a5,a5,a4
ffffffffc02053d8:	079a                	slli	a5,a5,0x6
ffffffffc02053da:	4589                	li	a1,2
ffffffffc02053dc:	953e                	add	a0,a0,a5
ffffffffc02053de:	acffc0ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc02053e2:	bf59                	j	ffffffffc0205378 <do_fork+0x2dc>
    int ret = -E_NO_FREE_PROC;
ffffffffc02053e4:	556d                	li	a0,-5
ffffffffc02053e6:	b5f9                	j	ffffffffc02052b4 <do_fork+0x218>
    return KADDR(page2pa(page));
ffffffffc02053e8:	00002617          	auipc	a2,0x2
ffffffffc02053ec:	07860613          	addi	a2,a2,120 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc02053f0:	06900593          	li	a1,105
ffffffffc02053f4:	00002517          	auipc	a0,0x2
ffffffffc02053f8:	09450513          	addi	a0,a0,148 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc02053fc:	884fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205400:	86be                	mv	a3,a5
ffffffffc0205402:	00002617          	auipc	a2,0x2
ffffffffc0205406:	09660613          	addi	a2,a2,150 # ffffffffc0207498 <default_pmm_manager+0x88>
ffffffffc020540a:	16f00593          	li	a1,367
ffffffffc020540e:	00003517          	auipc	a0,0x3
ffffffffc0205412:	4d250513          	addi	a0,a0,1234 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205416:	86afb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("Unlock failed.\n");
ffffffffc020541a:	00003617          	auipc	a2,0x3
ffffffffc020541e:	25e60613          	addi	a2,a2,606 # ffffffffc0208678 <default_pmm_manager+0x1268>
ffffffffc0205422:	03100593          	li	a1,49
ffffffffc0205426:	00003517          	auipc	a0,0x3
ffffffffc020542a:	26250513          	addi	a0,a0,610 # ffffffffc0208688 <default_pmm_manager+0x1278>
ffffffffc020542e:	852fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205432:	00002617          	auipc	a2,0x2
ffffffffc0205436:	08e60613          	addi	a2,a2,142 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc020543a:	06200593          	li	a1,98
ffffffffc020543e:	00002517          	auipc	a0,0x2
ffffffffc0205442:	04a50513          	addi	a0,a0,74 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0205446:	83afb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020544a:	00002617          	auipc	a2,0x2
ffffffffc020544e:	04e60613          	addi	a2,a2,78 # ffffffffc0207498 <default_pmm_manager+0x88>
ffffffffc0205452:	06e00593          	li	a1,110
ffffffffc0205456:	00002517          	auipc	a0,0x2
ffffffffc020545a:	03250513          	addi	a0,a0,50 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc020545e:	822fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205462 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205462:	7129                	addi	sp,sp,-320
ffffffffc0205464:	fa22                	sd	s0,304(sp)
ffffffffc0205466:	f626                	sd	s1,296(sp)
ffffffffc0205468:	f24a                	sd	s2,288(sp)
ffffffffc020546a:	84ae                	mv	s1,a1
ffffffffc020546c:	892a                	mv	s2,a0
ffffffffc020546e:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205470:	4581                	li	a1,0
ffffffffc0205472:	12000613          	li	a2,288
ffffffffc0205476:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205478:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020547a:	234010ef          	jal	ra,ffffffffc02066ae <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020547e:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205480:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205482:	100027f3          	csrr	a5,sstatus
ffffffffc0205486:	edd7f793          	andi	a5,a5,-291
ffffffffc020548a:	1207e793          	ori	a5,a5,288
ffffffffc020548e:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205490:	860a                	mv	a2,sp
ffffffffc0205492:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205496:	00000797          	auipc	a5,0x0
ffffffffc020549a:	8fa78793          	addi	a5,a5,-1798 # ffffffffc0204d90 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020549e:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02054a0:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02054a2:	bfbff0ef          	jal	ra,ffffffffc020509c <do_fork>
}
ffffffffc02054a6:	70f2                	ld	ra,312(sp)
ffffffffc02054a8:	7452                	ld	s0,304(sp)
ffffffffc02054aa:	74b2                	ld	s1,296(sp)
ffffffffc02054ac:	7912                	ld	s2,288(sp)
ffffffffc02054ae:	6131                	addi	sp,sp,320
ffffffffc02054b0:	8082                	ret

ffffffffc02054b2 <do_exit>:
do_exit(int error_code) {
ffffffffc02054b2:	7179                	addi	sp,sp,-48
ffffffffc02054b4:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02054b6:	000a7717          	auipc	a4,0xa7
ffffffffc02054ba:	41a70713          	addi	a4,a4,1050 # ffffffffc02ac8d0 <idleproc>
ffffffffc02054be:	000a7917          	auipc	s2,0xa7
ffffffffc02054c2:	40a90913          	addi	s2,s2,1034 # ffffffffc02ac8c8 <current>
ffffffffc02054c6:	00093783          	ld	a5,0(s2)
ffffffffc02054ca:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc02054cc:	f406                	sd	ra,40(sp)
ffffffffc02054ce:	f022                	sd	s0,32(sp)
ffffffffc02054d0:	ec26                	sd	s1,24(sp)
ffffffffc02054d2:	e44e                	sd	s3,8(sp)
ffffffffc02054d4:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02054d6:	0ee78363          	beq	a5,a4,ffffffffc02055bc <do_exit+0x10a>
    struct mm_struct *mm = current->mm;
ffffffffc02054da:	7780                	ld	s0,40(a5)
ffffffffc02054dc:	84aa                	mv	s1,a0
    if (mm != NULL) {
ffffffffc02054de:	c40d                	beqz	s0,ffffffffc0205508 <do_exit+0x56>
        lcr3(boot_cr3);
ffffffffc02054e0:	000a7797          	auipc	a5,0xa7
ffffffffc02054e4:	43878793          	addi	a5,a5,1080 # ffffffffc02ac918 <boot_cr3>
ffffffffc02054e8:	639c                	ld	a5,0(a5)
ffffffffc02054ea:	577d                	li	a4,-1
ffffffffc02054ec:	177e                	slli	a4,a4,0x3f
ffffffffc02054ee:	83b1                	srli	a5,a5,0xc
ffffffffc02054f0:	8fd9                	or	a5,a5,a4
ffffffffc02054f2:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02054f6:	581c                	lw	a5,48(s0)
ffffffffc02054f8:	fff7871b          	addiw	a4,a5,-1
ffffffffc02054fc:	d818                	sw	a4,48(s0)
        if (mm_count_dec(mm) == 0) {
ffffffffc02054fe:	c74d                	beqz	a4,ffffffffc02055a8 <do_exit+0xf6>
        current->mm = NULL;
ffffffffc0205500:	00093783          	ld	a5,0(s2)
ffffffffc0205504:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205508:	00093783          	ld	a5,0(s2)
ffffffffc020550c:	470d                	li	a4,3
ffffffffc020550e:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205510:	0e97a423          	sw	s1,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205514:	100027f3          	csrr	a5,sstatus
ffffffffc0205518:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020551a:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020551c:	efc5                	bnez	a5,ffffffffc02055d4 <do_exit+0x122>
        proc = current->parent;
ffffffffc020551e:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205522:	800007b7          	lui	a5,0x80000
ffffffffc0205526:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205528:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020552a:	0ec52703          	lw	a4,236(a0)
ffffffffc020552e:	0af70763          	beq	a4,a5,ffffffffc02055dc <do_exit+0x12a>
ffffffffc0205532:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205536:	800009b7          	lui	s3,0x80000
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020553a:	000a7497          	auipc	s1,0xa7
ffffffffc020553e:	39e48493          	addi	s1,s1,926 # ffffffffc02ac8d8 <initproc>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205542:	440d                	li	s0,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205544:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205546:	7afc                	ld	a5,240(a3)
ffffffffc0205548:	cb95                	beqz	a5,ffffffffc020557c <do_exit+0xca>
            current->cptr = proc->optr;
ffffffffc020554a:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5628>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020554e:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0205550:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205552:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205554:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205558:	10e7b023          	sd	a4,256(a5)
ffffffffc020555c:	c311                	beqz	a4,ffffffffc0205560 <do_exit+0xae>
                initproc->cptr->yptr = proc;
ffffffffc020555e:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205560:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205562:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205564:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205566:	fe8710e3          	bne	a4,s0,ffffffffc0205546 <do_exit+0x94>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020556a:	0ec52783          	lw	a5,236(a0)
ffffffffc020556e:	fd379ce3          	bne	a5,s3,ffffffffc0205546 <do_exit+0x94>
                    wakeup_proc(initproc);
ffffffffc0205572:	2a9000ef          	jal	ra,ffffffffc020601a <wakeup_proc>
ffffffffc0205576:	00093683          	ld	a3,0(s2)
ffffffffc020557a:	b7f1                	j	ffffffffc0205546 <do_exit+0x94>
    if (flag) {
ffffffffc020557c:	020a1363          	bnez	s4,ffffffffc02055a2 <do_exit+0xf0>
    schedule();
ffffffffc0205580:	317000ef          	jal	ra,ffffffffc0206096 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205584:	00093783          	ld	a5,0(s2)
ffffffffc0205588:	00003617          	auipc	a2,0x3
ffffffffc020558c:	0d060613          	addi	a2,a2,208 # ffffffffc0208658 <default_pmm_manager+0x1248>
ffffffffc0205590:	25800593          	li	a1,600
ffffffffc0205594:	43d4                	lw	a3,4(a5)
ffffffffc0205596:	00003517          	auipc	a0,0x3
ffffffffc020559a:	34a50513          	addi	a0,a0,842 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc020559e:	ee3fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        intr_enable();
ffffffffc02055a2:	8aafb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02055a6:	bfe9                	j	ffffffffc0205580 <do_exit+0xce>
            exit_mmap(mm);
ffffffffc02055a8:	8522                	mv	a0,s0
ffffffffc02055aa:	e81fe0ef          	jal	ra,ffffffffc020442a <exit_mmap>
            put_pgdir(mm);
ffffffffc02055ae:	8522                	mv	a0,s0
ffffffffc02055b0:	8efff0ef          	jal	ra,ffffffffc0204e9e <put_pgdir>
            mm_destroy(mm);
ffffffffc02055b4:	8522                	mv	a0,s0
ffffffffc02055b6:	cd5fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
ffffffffc02055ba:	b799                	j	ffffffffc0205500 <do_exit+0x4e>
        panic("idleproc exit.\n");
ffffffffc02055bc:	00003617          	auipc	a2,0x3
ffffffffc02055c0:	08c60613          	addi	a2,a2,140 # ffffffffc0208648 <default_pmm_manager+0x1238>
ffffffffc02055c4:	22c00593          	li	a1,556
ffffffffc02055c8:	00003517          	auipc	a0,0x3
ffffffffc02055cc:	31850513          	addi	a0,a0,792 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc02055d0:	eb1fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        intr_disable();
ffffffffc02055d4:	87efb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc02055d8:	4a05                	li	s4,1
ffffffffc02055da:	b791                	j	ffffffffc020551e <do_exit+0x6c>
            wakeup_proc(proc);
ffffffffc02055dc:	23f000ef          	jal	ra,ffffffffc020601a <wakeup_proc>
ffffffffc02055e0:	bf89                	j	ffffffffc0205532 <do_exit+0x80>

ffffffffc02055e2 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc02055e2:	7139                	addi	sp,sp,-64
ffffffffc02055e4:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc02055e6:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc02055ea:	f426                	sd	s1,40(sp)
ffffffffc02055ec:	f04a                	sd	s2,32(sp)
ffffffffc02055ee:	ec4e                	sd	s3,24(sp)
ffffffffc02055f0:	e456                	sd	s5,8(sp)
ffffffffc02055f2:	e05a                	sd	s6,0(sp)
ffffffffc02055f4:	fc06                	sd	ra,56(sp)
ffffffffc02055f6:	f822                	sd	s0,48(sp)
ffffffffc02055f8:	89aa                	mv	s3,a0
ffffffffc02055fa:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc02055fc:	000a7917          	auipc	s2,0xa7
ffffffffc0205600:	2cc90913          	addi	s2,s2,716 # ffffffffc02ac8c8 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205604:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205606:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205608:	0a05                	addi	s4,s4,1
    if (pid != 0) {
ffffffffc020560a:	02098f63          	beqz	s3,ffffffffc0205648 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc020560e:	854e                	mv	a0,s3
ffffffffc0205610:	a31ff0ef          	jal	ra,ffffffffc0205040 <find_proc>
ffffffffc0205614:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205616:	12050063          	beqz	a0,ffffffffc0205736 <do_wait.part.1+0x154>
ffffffffc020561a:	00093703          	ld	a4,0(s2)
ffffffffc020561e:	711c                	ld	a5,32(a0)
ffffffffc0205620:	10e79b63          	bne	a5,a4,ffffffffc0205736 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205624:	411c                	lw	a5,0(a0)
ffffffffc0205626:	02978c63          	beq	a5,s1,ffffffffc020565e <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc020562a:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc020562e:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205632:	265000ef          	jal	ra,ffffffffc0206096 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205636:	00093783          	ld	a5,0(s2)
ffffffffc020563a:	0b07a783          	lw	a5,176(a5)
ffffffffc020563e:	8b85                	andi	a5,a5,1
ffffffffc0205640:	d7e9                	beqz	a5,ffffffffc020560a <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205642:	555d                	li	a0,-9
ffffffffc0205644:	e6fff0ef          	jal	ra,ffffffffc02054b2 <do_exit>
        proc = current->cptr;
ffffffffc0205648:	00093703          	ld	a4,0(s2)
ffffffffc020564c:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc020564e:	e409                	bnez	s0,ffffffffc0205658 <do_wait.part.1+0x76>
ffffffffc0205650:	a0dd                	j	ffffffffc0205736 <do_wait.part.1+0x154>
ffffffffc0205652:	10043403          	ld	s0,256(s0)
ffffffffc0205656:	d871                	beqz	s0,ffffffffc020562a <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205658:	401c                	lw	a5,0(s0)
ffffffffc020565a:	fe979ce3          	bne	a5,s1,ffffffffc0205652 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc020565e:	000a7797          	auipc	a5,0xa7
ffffffffc0205662:	27278793          	addi	a5,a5,626 # ffffffffc02ac8d0 <idleproc>
ffffffffc0205666:	639c                	ld	a5,0(a5)
ffffffffc0205668:	0c878d63          	beq	a5,s0,ffffffffc0205742 <do_wait.part.1+0x160>
ffffffffc020566c:	000a7797          	auipc	a5,0xa7
ffffffffc0205670:	26c78793          	addi	a5,a5,620 # ffffffffc02ac8d8 <initproc>
ffffffffc0205674:	639c                	ld	a5,0(a5)
ffffffffc0205676:	0cf40663          	beq	s0,a5,ffffffffc0205742 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc020567a:	000b0663          	beqz	s6,ffffffffc0205686 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc020567e:	0e842783          	lw	a5,232(s0)
ffffffffc0205682:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205686:	100027f3          	csrr	a5,sstatus
ffffffffc020568a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020568c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020568e:	e7d5                	bnez	a5,ffffffffc020573a <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205690:	6c70                	ld	a2,216(s0)
ffffffffc0205692:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205694:	10043703          	ld	a4,256(s0)
ffffffffc0205698:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020569a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020569c:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020569e:	6470                	ld	a2,200(s0)
ffffffffc02056a0:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02056a2:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02056a4:	e290                	sd	a2,0(a3)
ffffffffc02056a6:	c319                	beqz	a4,ffffffffc02056ac <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02056a8:	ff7c                	sd	a5,248(a4)
ffffffffc02056aa:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc02056ac:	c3d1                	beqz	a5,ffffffffc0205730 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc02056ae:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02056b2:	000a7797          	auipc	a5,0xa7
ffffffffc02056b6:	22e78793          	addi	a5,a5,558 # ffffffffc02ac8e0 <nr_process>
ffffffffc02056ba:	439c                	lw	a5,0(a5)
ffffffffc02056bc:	37fd                	addiw	a5,a5,-1
ffffffffc02056be:	000a7717          	auipc	a4,0xa7
ffffffffc02056c2:	22f72123          	sw	a5,546(a4) # ffffffffc02ac8e0 <nr_process>
    if (flag) {
ffffffffc02056c6:	e1b5                	bnez	a1,ffffffffc020572a <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02056c8:	6814                	ld	a3,16(s0)
ffffffffc02056ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02056ce:	0af6e263          	bltu	a3,a5,ffffffffc0205772 <do_wait.part.1+0x190>
ffffffffc02056d2:	000a7797          	auipc	a5,0xa7
ffffffffc02056d6:	23e78793          	addi	a5,a5,574 # ffffffffc02ac910 <va_pa_offset>
ffffffffc02056da:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02056dc:	000a7797          	auipc	a5,0xa7
ffffffffc02056e0:	1d478793          	addi	a5,a5,468 # ffffffffc02ac8b0 <npage>
ffffffffc02056e4:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02056e6:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02056e8:	82b1                	srli	a3,a3,0xc
ffffffffc02056ea:	06f6f863          	bgeu	a3,a5,ffffffffc020575a <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc02056ee:	00003797          	auipc	a5,0x3
ffffffffc02056f2:	6ba78793          	addi	a5,a5,1722 # ffffffffc0208da8 <nbase>
ffffffffc02056f6:	639c                	ld	a5,0(a5)
ffffffffc02056f8:	000a7717          	auipc	a4,0xa7
ffffffffc02056fc:	22870713          	addi	a4,a4,552 # ffffffffc02ac920 <pages>
ffffffffc0205700:	6308                	ld	a0,0(a4)
ffffffffc0205702:	8e9d                	sub	a3,a3,a5
ffffffffc0205704:	069a                	slli	a3,a3,0x6
ffffffffc0205706:	9536                	add	a0,a0,a3
ffffffffc0205708:	4589                	li	a1,2
ffffffffc020570a:	fa2fc0ef          	jal	ra,ffffffffc0201eac <free_pages>
    kfree(proc);
ffffffffc020570e:	8522                	mv	a0,s0
ffffffffc0205710:	dd8fc0ef          	jal	ra,ffffffffc0201ce8 <kfree>
    return 0;
ffffffffc0205714:	4501                	li	a0,0
}
ffffffffc0205716:	70e2                	ld	ra,56(sp)
ffffffffc0205718:	7442                	ld	s0,48(sp)
ffffffffc020571a:	74a2                	ld	s1,40(sp)
ffffffffc020571c:	7902                	ld	s2,32(sp)
ffffffffc020571e:	69e2                	ld	s3,24(sp)
ffffffffc0205720:	6a42                	ld	s4,16(sp)
ffffffffc0205722:	6aa2                	ld	s5,8(sp)
ffffffffc0205724:	6b02                	ld	s6,0(sp)
ffffffffc0205726:	6121                	addi	sp,sp,64
ffffffffc0205728:	8082                	ret
        intr_enable();
ffffffffc020572a:	f23fa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc020572e:	bf69                	j	ffffffffc02056c8 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205730:	701c                	ld	a5,32(s0)
ffffffffc0205732:	fbf8                	sd	a4,240(a5)
ffffffffc0205734:	bfbd                	j	ffffffffc02056b2 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205736:	5579                	li	a0,-2
ffffffffc0205738:	bff9                	j	ffffffffc0205716 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc020573a:	f19fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc020573e:	4585                	li	a1,1
ffffffffc0205740:	bf81                	j	ffffffffc0205690 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205742:	00003617          	auipc	a2,0x3
ffffffffc0205746:	f5e60613          	addi	a2,a2,-162 # ffffffffc02086a0 <default_pmm_manager+0x1290>
ffffffffc020574a:	35800593          	li	a1,856
ffffffffc020574e:	00003517          	auipc	a0,0x3
ffffffffc0205752:	19250513          	addi	a0,a0,402 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205756:	d2bfa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020575a:	00002617          	auipc	a2,0x2
ffffffffc020575e:	d6660613          	addi	a2,a2,-666 # ffffffffc02074c0 <default_pmm_manager+0xb0>
ffffffffc0205762:	06200593          	li	a1,98
ffffffffc0205766:	00002517          	auipc	a0,0x2
ffffffffc020576a:	d2250513          	addi	a0,a0,-734 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc020576e:	d13fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205772:	00002617          	auipc	a2,0x2
ffffffffc0205776:	d2660613          	addi	a2,a2,-730 # ffffffffc0207498 <default_pmm_manager+0x88>
ffffffffc020577a:	06e00593          	li	a1,110
ffffffffc020577e:	00002517          	auipc	a0,0x2
ffffffffc0205782:	d0a50513          	addi	a0,a0,-758 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0205786:	cfbfa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020578a <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020578a:	1141                	addi	sp,sp,-16
ffffffffc020578c:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020578e:	f64fc0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205792:	c96fc0ef          	jal	ra,ffffffffc0201c28 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205796:	4601                	li	a2,0
ffffffffc0205798:	4581                	li	a1,0
ffffffffc020579a:	fffff517          	auipc	a0,0xfffff
ffffffffc020579e:	68250513          	addi	a0,a0,1666 # ffffffffc0204e1c <user_main>
ffffffffc02057a2:	cc1ff0ef          	jal	ra,ffffffffc0205462 <kernel_thread>
    if (pid <= 0) {
ffffffffc02057a6:	00a04563          	bgtz	a0,ffffffffc02057b0 <init_main+0x26>
ffffffffc02057aa:	a841                	j	ffffffffc020583a <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02057ac:	0eb000ef          	jal	ra,ffffffffc0206096 <schedule>
    if (code_store != NULL) {
ffffffffc02057b0:	4581                	li	a1,0
ffffffffc02057b2:	4501                	li	a0,0
ffffffffc02057b4:	e2fff0ef          	jal	ra,ffffffffc02055e2 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc02057b8:	d975                	beqz	a0,ffffffffc02057ac <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02057ba:	00003517          	auipc	a0,0x3
ffffffffc02057be:	f2650513          	addi	a0,a0,-218 # ffffffffc02086e0 <default_pmm_manager+0x12d0>
ffffffffc02057c2:	9cdfa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02057c6:	000a7797          	auipc	a5,0xa7
ffffffffc02057ca:	11278793          	addi	a5,a5,274 # ffffffffc02ac8d8 <initproc>
ffffffffc02057ce:	639c                	ld	a5,0(a5)
ffffffffc02057d0:	7bf8                	ld	a4,240(a5)
ffffffffc02057d2:	e721                	bnez	a4,ffffffffc020581a <init_main+0x90>
ffffffffc02057d4:	7ff8                	ld	a4,248(a5)
ffffffffc02057d6:	e331                	bnez	a4,ffffffffc020581a <init_main+0x90>
ffffffffc02057d8:	1007b703          	ld	a4,256(a5)
ffffffffc02057dc:	ef1d                	bnez	a4,ffffffffc020581a <init_main+0x90>
    assert(nr_process == 2);
ffffffffc02057de:	000a7717          	auipc	a4,0xa7
ffffffffc02057e2:	10270713          	addi	a4,a4,258 # ffffffffc02ac8e0 <nr_process>
ffffffffc02057e6:	4314                	lw	a3,0(a4)
ffffffffc02057e8:	4709                	li	a4,2
ffffffffc02057ea:	0ae69463          	bne	a3,a4,ffffffffc0205892 <init_main+0x108>
    return listelm->next;
ffffffffc02057ee:	000a7697          	auipc	a3,0xa7
ffffffffc02057f2:	21a68693          	addi	a3,a3,538 # ffffffffc02aca08 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057f6:	6698                	ld	a4,8(a3)
ffffffffc02057f8:	0c878793          	addi	a5,a5,200
ffffffffc02057fc:	06f71b63          	bne	a4,a5,ffffffffc0205872 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205800:	629c                	ld	a5,0(a3)
ffffffffc0205802:	04f71863          	bne	a4,a5,ffffffffc0205852 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205806:	00003517          	auipc	a0,0x3
ffffffffc020580a:	fc250513          	addi	a0,a0,-62 # ffffffffc02087c8 <default_pmm_manager+0x13b8>
ffffffffc020580e:	981fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc0205812:	60a2                	ld	ra,8(sp)
ffffffffc0205814:	4501                	li	a0,0
ffffffffc0205816:	0141                	addi	sp,sp,16
ffffffffc0205818:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020581a:	00003697          	auipc	a3,0x3
ffffffffc020581e:	eee68693          	addi	a3,a3,-274 # ffffffffc0208708 <default_pmm_manager+0x12f8>
ffffffffc0205822:	00001617          	auipc	a2,0x1
ffffffffc0205826:	4a660613          	addi	a2,a2,1190 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc020582a:	3bd00593          	li	a1,957
ffffffffc020582e:	00003517          	auipc	a0,0x3
ffffffffc0205832:	0b250513          	addi	a0,a0,178 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205836:	c4bfa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("create user_main failed.\n");
ffffffffc020583a:	00003617          	auipc	a2,0x3
ffffffffc020583e:	e8660613          	addi	a2,a2,-378 # ffffffffc02086c0 <default_pmm_manager+0x12b0>
ffffffffc0205842:	3b500593          	li	a1,949
ffffffffc0205846:	00003517          	auipc	a0,0x3
ffffffffc020584a:	09a50513          	addi	a0,a0,154 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc020584e:	c33fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205852:	00003697          	auipc	a3,0x3
ffffffffc0205856:	f4668693          	addi	a3,a3,-186 # ffffffffc0208798 <default_pmm_manager+0x1388>
ffffffffc020585a:	00001617          	auipc	a2,0x1
ffffffffc020585e:	46e60613          	addi	a2,a2,1134 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205862:	3c000593          	li	a1,960
ffffffffc0205866:	00003517          	auipc	a0,0x3
ffffffffc020586a:	07a50513          	addi	a0,a0,122 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc020586e:	c13fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205872:	00003697          	auipc	a3,0x3
ffffffffc0205876:	ef668693          	addi	a3,a3,-266 # ffffffffc0208768 <default_pmm_manager+0x1358>
ffffffffc020587a:	00001617          	auipc	a2,0x1
ffffffffc020587e:	44e60613          	addi	a2,a2,1102 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205882:	3bf00593          	li	a1,959
ffffffffc0205886:	00003517          	auipc	a0,0x3
ffffffffc020588a:	05a50513          	addi	a0,a0,90 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc020588e:	bf3fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_process == 2);
ffffffffc0205892:	00003697          	auipc	a3,0x3
ffffffffc0205896:	ec668693          	addi	a3,a3,-314 # ffffffffc0208758 <default_pmm_manager+0x1348>
ffffffffc020589a:	00001617          	auipc	a2,0x1
ffffffffc020589e:	42e60613          	addi	a2,a2,1070 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc02058a2:	3be00593          	li	a1,958
ffffffffc02058a6:	00003517          	auipc	a0,0x3
ffffffffc02058aa:	03a50513          	addi	a0,a0,58 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc02058ae:	bd3fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02058b2 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058b2:	7135                	addi	sp,sp,-160
ffffffffc02058b4:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02058b6:	000a7a17          	auipc	s4,0xa7
ffffffffc02058ba:	012a0a13          	addi	s4,s4,18 # ffffffffc02ac8c8 <current>
ffffffffc02058be:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058c2:	e14a                	sd	s2,128(sp)
ffffffffc02058c4:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02058c6:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058ca:	fcce                	sd	s3,120(sp)
ffffffffc02058cc:	f0da                	sd	s6,96(sp)
ffffffffc02058ce:	89aa                	mv	s3,a0
ffffffffc02058d0:	842e                	mv	s0,a1
ffffffffc02058d2:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02058d4:	4681                	li	a3,0
ffffffffc02058d6:	862e                	mv	a2,a1
ffffffffc02058d8:	85aa                	mv	a1,a0
ffffffffc02058da:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02058dc:	ed06                	sd	ra,152(sp)
ffffffffc02058de:	e526                	sd	s1,136(sp)
ffffffffc02058e0:	f4d6                	sd	s5,104(sp)
ffffffffc02058e2:	ecde                	sd	s7,88(sp)
ffffffffc02058e4:	e8e2                	sd	s8,80(sp)
ffffffffc02058e6:	e4e6                	sd	s9,72(sp)
ffffffffc02058e8:	e0ea                	sd	s10,64(sp)
ffffffffc02058ea:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02058ec:	aa8ff0ef          	jal	ra,ffffffffc0204b94 <user_mem_check>
ffffffffc02058f0:	40050463          	beqz	a0,ffffffffc0205cf8 <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02058f4:	4641                	li	a2,16
ffffffffc02058f6:	4581                	li	a1,0
ffffffffc02058f8:	1008                	addi	a0,sp,32
ffffffffc02058fa:	5b5000ef          	jal	ra,ffffffffc02066ae <memset>
    memcpy(local_name, name, len);
ffffffffc02058fe:	47bd                	li	a5,15
ffffffffc0205900:	8622                	mv	a2,s0
ffffffffc0205902:	0687ee63          	bltu	a5,s0,ffffffffc020597e <do_execve+0xcc>
ffffffffc0205906:	85ce                	mv	a1,s3
ffffffffc0205908:	1008                	addi	a0,sp,32
ffffffffc020590a:	5b7000ef          	jal	ra,ffffffffc02066c0 <memcpy>
    if (mm != NULL) {  // 如果当前进程已经有内存管理结构 mm，则释放当前进程的内存并清空 mm。
ffffffffc020590e:	06090f63          	beqz	s2,ffffffffc020598c <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205912:	00002517          	auipc	a0,0x2
ffffffffc0205916:	2fe50513          	addi	a0,a0,766 # ffffffffc0207c10 <default_pmm_manager+0x800>
ffffffffc020591a:	8abfa0ef          	jal	ra,ffffffffc02001c4 <cputs>
        lcr3(boot_cr3);
ffffffffc020591e:	000a7797          	auipc	a5,0xa7
ffffffffc0205922:	ffa78793          	addi	a5,a5,-6 # ffffffffc02ac918 <boot_cr3>
ffffffffc0205926:	639c                	ld	a5,0(a5)
ffffffffc0205928:	577d                	li	a4,-1
ffffffffc020592a:	177e                	slli	a4,a4,0x3f
ffffffffc020592c:	83b1                	srli	a5,a5,0xc
ffffffffc020592e:	8fd9                	or	a5,a5,a4
ffffffffc0205930:	18079073          	csrw	satp,a5
ffffffffc0205934:	03092783          	lw	a5,48(s2)
ffffffffc0205938:	fff7871b          	addiw	a4,a5,-1
ffffffffc020593c:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205940:	28070e63          	beqz	a4,ffffffffc0205bdc <do_execve+0x32a>
        current->mm = NULL;
ffffffffc0205944:	000a3783          	ld	a5,0(s4)
ffffffffc0205948:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc020594c:	fb8fe0ef          	jal	ra,ffffffffc0204104 <mm_create>
ffffffffc0205950:	892a                	mv	s2,a0
ffffffffc0205952:	c135                	beqz	a0,ffffffffc02059b6 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205954:	dc8ff0ef          	jal	ra,ffffffffc0204f1c <setup_pgdir>
ffffffffc0205958:	e931                	bnez	a0,ffffffffc02059ac <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020595a:	000b2703          	lw	a4,0(s6)
ffffffffc020595e:	464c47b7          	lui	a5,0x464c4
ffffffffc0205962:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aa7>
ffffffffc0205966:	04f70a63          	beq	a4,a5,ffffffffc02059ba <do_execve+0x108>
    put_pgdir(mm);
ffffffffc020596a:	854a                	mv	a0,s2
ffffffffc020596c:	d32ff0ef          	jal	ra,ffffffffc0204e9e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205970:	854a                	mv	a0,s2
ffffffffc0205972:	919fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205976:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205978:	854e                	mv	a0,s3
ffffffffc020597a:	b39ff0ef          	jal	ra,ffffffffc02054b2 <do_exit>
    memcpy(local_name, name, len);
ffffffffc020597e:	463d                	li	a2,15
ffffffffc0205980:	85ce                	mv	a1,s3
ffffffffc0205982:	1008                	addi	a0,sp,32
ffffffffc0205984:	53d000ef          	jal	ra,ffffffffc02066c0 <memcpy>
    if (mm != NULL) {  // 如果当前进程已经有内存管理结构 mm，则释放当前进程的内存并清空 mm。
ffffffffc0205988:	f80915e3          	bnez	s2,ffffffffc0205912 <do_execve+0x60>
    if (current->mm != NULL) {  // current->mm 是指当前进程的内存管理结构。如果该值不为空，说明当前进程已经有内存空间分配，这时不能加载新的程序，因此会触发 panic。
ffffffffc020598c:	000a3783          	ld	a5,0(s4)
ffffffffc0205990:	779c                	ld	a5,40(a5)
ffffffffc0205992:	dfcd                	beqz	a5,ffffffffc020594c <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205994:	00003617          	auipc	a2,0x3
ffffffffc0205998:	b2c60613          	addi	a2,a2,-1236 # ffffffffc02084c0 <default_pmm_manager+0x10b0>
ffffffffc020599c:	26300593          	li	a1,611
ffffffffc02059a0:	00003517          	auipc	a0,0x3
ffffffffc02059a4:	f4050513          	addi	a0,a0,-192 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc02059a8:	ad9fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    mm_destroy(mm);
ffffffffc02059ac:	854a                	mv	a0,s2
ffffffffc02059ae:	8ddfe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc02059b2:	59f1                	li	s3,-4
ffffffffc02059b4:	b7d1                	j	ffffffffc0205978 <do_execve+0xc6>
ffffffffc02059b6:	59f1                	li	s3,-4
ffffffffc02059b8:	b7c1                	j	ffffffffc0205978 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059ba:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02059be:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059c2:	00371793          	slli	a5,a4,0x3
ffffffffc02059c6:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02059c8:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02059ca:	078e                	slli	a5,a5,0x3
ffffffffc02059cc:	97a2                	add	a5,a5,s0
ffffffffc02059ce:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {  // 遍历所有的程序头，只有类型为 ELF_PT_LOAD 的段才会被加载。
ffffffffc02059d0:	02f47b63          	bgeu	s0,a5,ffffffffc0205a06 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc02059d4:	5bfd                	li	s7,-1
ffffffffc02059d6:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc02059da:	000a7d97          	auipc	s11,0xa7
ffffffffc02059de:	f46d8d93          	addi	s11,s11,-186 # ffffffffc02ac920 <pages>
ffffffffc02059e2:	00003d17          	auipc	s10,0x3
ffffffffc02059e6:	3c6d0d13          	addi	s10,s10,966 # ffffffffc0208da8 <nbase>
    return KADDR(page2pa(page));
ffffffffc02059ea:	e43e                	sd	a5,8(sp)
ffffffffc02059ec:	000a7c97          	auipc	s9,0xa7
ffffffffc02059f0:	ec4c8c93          	addi	s9,s9,-316 # ffffffffc02ac8b0 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02059f4:	4018                	lw	a4,0(s0)
ffffffffc02059f6:	4785                	li	a5,1
ffffffffc02059f8:	0ef70f63          	beq	a4,a5,ffffffffc0205af6 <do_execve+0x244>
    for (; ph < ph_end; ph ++) {  // 遍历所有的程序头，只有类型为 ELF_PT_LOAD 的段才会被加载。
ffffffffc02059fc:	67e2                	ld	a5,24(sp)
ffffffffc02059fe:	03840413          	addi	s0,s0,56
ffffffffc0205a02:	fef469e3          	bltu	s0,a5,ffffffffc02059f4 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205a06:	4701                	li	a4,0
ffffffffc0205a08:	46ad                	li	a3,11
ffffffffc0205a0a:	00100637          	lui	a2,0x100
ffffffffc0205a0e:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205a12:	854a                	mv	a0,s2
ffffffffc0205a14:	8c9fe0ef          	jal	ra,ffffffffc02042dc <mm_map>
ffffffffc0205a18:	89aa                	mv	s3,a0
ffffffffc0205a1a:	1a051763          	bnez	a0,ffffffffc0205bc8 <do_execve+0x316>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205a1e:	01893503          	ld	a0,24(s2)
ffffffffc0205a22:	467d                	li	a2,31
ffffffffc0205a24:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205a28:	8f3fd0ef          	jal	ra,ffffffffc020331a <pgdir_alloc_page>
ffffffffc0205a2c:	36050263          	beqz	a0,ffffffffc0205d90 <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a30:	01893503          	ld	a0,24(s2)
ffffffffc0205a34:	467d                	li	a2,31
ffffffffc0205a36:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205a3a:	8e1fd0ef          	jal	ra,ffffffffc020331a <pgdir_alloc_page>
ffffffffc0205a3e:	32050963          	beqz	a0,ffffffffc0205d70 <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a42:	01893503          	ld	a0,24(s2)
ffffffffc0205a46:	467d                	li	a2,31
ffffffffc0205a48:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205a4c:	8cffd0ef          	jal	ra,ffffffffc020331a <pgdir_alloc_page>
ffffffffc0205a50:	30050063          	beqz	a0,ffffffffc0205d50 <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a54:	01893503          	ld	a0,24(s2)
ffffffffc0205a58:	467d                	li	a2,31
ffffffffc0205a5a:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205a5e:	8bdfd0ef          	jal	ra,ffffffffc020331a <pgdir_alloc_page>
ffffffffc0205a62:	2c050763          	beqz	a0,ffffffffc0205d30 <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc0205a66:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205a6a:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a6e:	01893683          	ld	a3,24(s2)
ffffffffc0205a72:	2785                	addiw	a5,a5,1
ffffffffc0205a74:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205a78:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5550>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a7c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a80:	28f6ec63          	bltu	a3,a5,ffffffffc0205d18 <do_execve+0x466>
ffffffffc0205a84:	000a7797          	auipc	a5,0xa7
ffffffffc0205a88:	e8c78793          	addi	a5,a5,-372 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0205a8c:	639c                	ld	a5,0(a5)
ffffffffc0205a8e:	577d                	li	a4,-1
ffffffffc0205a90:	177e                	slli	a4,a4,0x3f
ffffffffc0205a92:	8e9d                	sub	a3,a3,a5
ffffffffc0205a94:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a98:	f654                	sd	a3,168(a2)
ffffffffc0205a9a:	8fd9                	or	a5,a5,a4
ffffffffc0205a9c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205aa0:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205aa2:	4581                	li	a1,0
ffffffffc0205aa4:	12000613          	li	a2,288
    uintptr_t sstatus = tf->status;
ffffffffc0205aa8:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205aac:	8522                	mv	a0,s0
ffffffffc0205aae:	401000ef          	jal	ra,ffffffffc02066ae <memset>
    tf->epc = elf->e_entry;                // 设置为 ELF 文件中的入口点
ffffffffc0205ab2:	018b3783          	ld	a5,24(s6)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205ab6:	edf4f493          	andi	s1,s1,-289
    set_proc_name(current, local_name);
ffffffffc0205aba:	000a3503          	ld	a0,0(s4)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205abe:	0204e493          	ori	s1,s1,32
    tf->gpr.sp = USTACKTOP-4*PGSIZE;      // 用户栈的起始位置
ffffffffc0205ac2:	7fffc737          	lui	a4,0x7fffc
ffffffffc0205ac6:	e818                	sd	a4,16(s0)
    tf->epc = elf->e_entry;                // 设置为 ELF 文件中的入口点
ffffffffc0205ac8:	10f43423          	sd	a5,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205acc:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205ad0:	100c                	addi	a1,sp,32
ffffffffc0205ad2:	cd6ff0ef          	jal	ra,ffffffffc0204fa8 <set_proc_name>
}
ffffffffc0205ad6:	60ea                	ld	ra,152(sp)
ffffffffc0205ad8:	644a                	ld	s0,144(sp)
ffffffffc0205ada:	854e                	mv	a0,s3
ffffffffc0205adc:	64aa                	ld	s1,136(sp)
ffffffffc0205ade:	690a                	ld	s2,128(sp)
ffffffffc0205ae0:	79e6                	ld	s3,120(sp)
ffffffffc0205ae2:	7a46                	ld	s4,112(sp)
ffffffffc0205ae4:	7aa6                	ld	s5,104(sp)
ffffffffc0205ae6:	7b06                	ld	s6,96(sp)
ffffffffc0205ae8:	6be6                	ld	s7,88(sp)
ffffffffc0205aea:	6c46                	ld	s8,80(sp)
ffffffffc0205aec:	6ca6                	ld	s9,72(sp)
ffffffffc0205aee:	6d06                	ld	s10,64(sp)
ffffffffc0205af0:	7de2                	ld	s11,56(sp)
ffffffffc0205af2:	610d                	addi	sp,sp,160
ffffffffc0205af4:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205af6:	7410                	ld	a2,40(s0)
ffffffffc0205af8:	701c                	ld	a5,32(s0)
ffffffffc0205afa:	20f66163          	bltu	a2,a5,ffffffffc0205cfc <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205afe:	405c                	lw	a5,4(s0)
ffffffffc0205b00:	0017f693          	andi	a3,a5,1
ffffffffc0205b04:	c291                	beqz	a3,ffffffffc0205b08 <do_execve+0x256>
ffffffffc0205b06:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b08:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b0c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b0e:	0e071163          	bnez	a4,ffffffffc0205bf0 <do_execve+0x33e>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205b12:	4745                	li	a4,17
ffffffffc0205b14:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b16:	c789                	beqz	a5,ffffffffc0205b20 <do_execve+0x26e>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205b18:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b1a:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205b1e:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b20:	0026f793          	andi	a5,a3,2
ffffffffc0205b24:	ebe9                	bnez	a5,ffffffffc0205bf6 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205b26:	0046f793          	andi	a5,a3,4
ffffffffc0205b2a:	c789                	beqz	a5,ffffffffc0205b34 <do_execve+0x282>
ffffffffc0205b2c:	6782                	ld	a5,0(sp)
ffffffffc0205b2e:	0087e793          	ori	a5,a5,8
ffffffffc0205b32:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205b34:	680c                	ld	a1,16(s0)
ffffffffc0205b36:	4701                	li	a4,0
ffffffffc0205b38:	854a                	mv	a0,s2
ffffffffc0205b3a:	fa2fe0ef          	jal	ra,ffffffffc02042dc <mm_map>
ffffffffc0205b3e:	89aa                	mv	s3,a0
ffffffffc0205b40:	e541                	bnez	a0,ffffffffc0205bc8 <do_execve+0x316>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b42:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b46:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b4a:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b4e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b50:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b52:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205b54:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205b58:	053bef63          	bltu	s7,s3,ffffffffc0205bb6 <do_execve+0x304>
ffffffffc0205b5c:	aa61                	j	ffffffffc0205cf4 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b5e:	6785                	lui	a5,0x1
ffffffffc0205b60:	418b8533          	sub	a0,s7,s8
ffffffffc0205b64:	9c3e                	add	s8,s8,a5
ffffffffc0205b66:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205b6a:	0189f463          	bgeu	s3,s8,ffffffffc0205b72 <do_execve+0x2c0>
                size -= la - end;
ffffffffc0205b6e:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205b72:	000db683          	ld	a3,0(s11)
ffffffffc0205b76:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b7a:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b7c:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b80:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b82:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b86:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b88:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b8c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b8e:	16c5f963          	bgeu	a1,a2,ffffffffc0205d00 <do_execve+0x44e>
ffffffffc0205b92:	000a7797          	auipc	a5,0xa7
ffffffffc0205b96:	d7e78793          	addi	a5,a5,-642 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0205b9a:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b9e:	85d6                	mv	a1,s5
ffffffffc0205ba0:	8642                	mv	a2,a6
ffffffffc0205ba2:	96c6                	add	a3,a3,a7
ffffffffc0205ba4:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205ba6:	9bc2                	add	s7,s7,a6
ffffffffc0205ba8:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205baa:	317000ef          	jal	ra,ffffffffc02066c0 <memcpy>
            start += size, from += size;
ffffffffc0205bae:	6842                	ld	a6,16(sp)
ffffffffc0205bb0:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205bb2:	053bf563          	bgeu	s7,s3,ffffffffc0205bfc <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205bb6:	01893503          	ld	a0,24(s2)
ffffffffc0205bba:	6602                	ld	a2,0(sp)
ffffffffc0205bbc:	85e2                	mv	a1,s8
ffffffffc0205bbe:	f5cfd0ef          	jal	ra,ffffffffc020331a <pgdir_alloc_page>
ffffffffc0205bc2:	84aa                	mv	s1,a0
ffffffffc0205bc4:	fd49                	bnez	a0,ffffffffc0205b5e <do_execve+0x2ac>
        ret = -E_NO_MEM;
ffffffffc0205bc6:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205bc8:	854a                	mv	a0,s2
ffffffffc0205bca:	861fe0ef          	jal	ra,ffffffffc020442a <exit_mmap>
    put_pgdir(mm);
ffffffffc0205bce:	854a                	mv	a0,s2
ffffffffc0205bd0:	aceff0ef          	jal	ra,ffffffffc0204e9e <put_pgdir>
    mm_destroy(mm);
ffffffffc0205bd4:	854a                	mv	a0,s2
ffffffffc0205bd6:	eb4fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
    return ret;
ffffffffc0205bda:	bb79                	j	ffffffffc0205978 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205bdc:	854a                	mv	a0,s2
ffffffffc0205bde:	84dfe0ef          	jal	ra,ffffffffc020442a <exit_mmap>
            put_pgdir(mm);
ffffffffc0205be2:	854a                	mv	a0,s2
ffffffffc0205be4:	abaff0ef          	jal	ra,ffffffffc0204e9e <put_pgdir>
            mm_destroy(mm);
ffffffffc0205be8:	854a                	mv	a0,s2
ffffffffc0205bea:	ea0fe0ef          	jal	ra,ffffffffc020428a <mm_destroy>
ffffffffc0205bee:	bb99                	j	ffffffffc0205944 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bf0:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bf4:	f395                	bnez	a5,ffffffffc0205b18 <do_execve+0x266>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205bf6:	47dd                	li	a5,23
ffffffffc0205bf8:	e03e                	sd	a5,0(sp)
ffffffffc0205bfa:	b735                	j	ffffffffc0205b26 <do_execve+0x274>
ffffffffc0205bfc:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205c00:	7414                	ld	a3,40(s0)
ffffffffc0205c02:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205c04:	098bf163          	bgeu	s7,s8,ffffffffc0205c86 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205c08:	df798ae3          	beq	s3,s7,ffffffffc02059fc <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c0c:	6505                	lui	a0,0x1
ffffffffc0205c0e:	955e                	add	a0,a0,s7
ffffffffc0205c10:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205c14:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205c18:	0d89fb63          	bgeu	s3,s8,ffffffffc0205cee <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205c1c:	000db683          	ld	a3,0(s11)
ffffffffc0205c20:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c24:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c26:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c2a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c2c:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205c30:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205c32:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c36:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c38:	0cc5f463          	bgeu	a1,a2,ffffffffc0205d00 <do_execve+0x44e>
ffffffffc0205c3c:	000a7617          	auipc	a2,0xa7
ffffffffc0205c40:	cd460613          	addi	a2,a2,-812 # ffffffffc02ac910 <va_pa_offset>
ffffffffc0205c44:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c48:	4581                	li	a1,0
ffffffffc0205c4a:	8656                	mv	a2,s5
ffffffffc0205c4c:	96c2                	add	a3,a3,a6
ffffffffc0205c4e:	9536                	add	a0,a0,a3
ffffffffc0205c50:	25f000ef          	jal	ra,ffffffffc02066ae <memset>
            start += size;
ffffffffc0205c54:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205c58:	0389f463          	bgeu	s3,s8,ffffffffc0205c80 <do_execve+0x3ce>
ffffffffc0205c5c:	dae980e3          	beq	s3,a4,ffffffffc02059fc <do_execve+0x14a>
ffffffffc0205c60:	00003697          	auipc	a3,0x3
ffffffffc0205c64:	88868693          	addi	a3,a3,-1912 # ffffffffc02084e8 <default_pmm_manager+0x10d8>
ffffffffc0205c68:	00001617          	auipc	a2,0x1
ffffffffc0205c6c:	06060613          	addi	a2,a2,96 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205c70:	2bb00593          	li	a1,699
ffffffffc0205c74:	00003517          	auipc	a0,0x3
ffffffffc0205c78:	c6c50513          	addi	a0,a0,-916 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205c7c:	805fa0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0205c80:	ff8710e3          	bne	a4,s8,ffffffffc0205c60 <do_execve+0x3ae>
ffffffffc0205c84:	8be2                	mv	s7,s8
ffffffffc0205c86:	000a7a97          	auipc	s5,0xa7
ffffffffc0205c8a:	c8aa8a93          	addi	s5,s5,-886 # ffffffffc02ac910 <va_pa_offset>
        while (start < end) {
ffffffffc0205c8e:	053be763          	bltu	s7,s3,ffffffffc0205cdc <do_execve+0x42a>
ffffffffc0205c92:	b3ad                	j	ffffffffc02059fc <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c94:	6785                	lui	a5,0x1
ffffffffc0205c96:	418b8533          	sub	a0,s7,s8
ffffffffc0205c9a:	9c3e                	add	s8,s8,a5
ffffffffc0205c9c:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205ca0:	0189f463          	bgeu	s3,s8,ffffffffc0205ca8 <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205ca4:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205ca8:	000db683          	ld	a3,0(s11)
ffffffffc0205cac:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205cb0:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205cb2:	40d486b3          	sub	a3,s1,a3
ffffffffc0205cb6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205cb8:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205cbc:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205cbe:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205cc2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205cc4:	02b87e63          	bgeu	a6,a1,ffffffffc0205d00 <do_execve+0x44e>
ffffffffc0205cc8:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205ccc:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205cce:	4581                	li	a1,0
ffffffffc0205cd0:	96c2                	add	a3,a3,a6
ffffffffc0205cd2:	9536                	add	a0,a0,a3
ffffffffc0205cd4:	1db000ef          	jal	ra,ffffffffc02066ae <memset>
        while (start < end) {
ffffffffc0205cd8:	d33bf2e3          	bgeu	s7,s3,ffffffffc02059fc <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205cdc:	01893503          	ld	a0,24(s2)
ffffffffc0205ce0:	6602                	ld	a2,0(sp)
ffffffffc0205ce2:	85e2                	mv	a1,s8
ffffffffc0205ce4:	e36fd0ef          	jal	ra,ffffffffc020331a <pgdir_alloc_page>
ffffffffc0205ce8:	84aa                	mv	s1,a0
ffffffffc0205cea:	f54d                	bnez	a0,ffffffffc0205c94 <do_execve+0x3e2>
ffffffffc0205cec:	bde9                	j	ffffffffc0205bc6 <do_execve+0x314>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205cee:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205cf2:	b72d                	j	ffffffffc0205c1c <do_execve+0x36a>
        while (start < end) {
ffffffffc0205cf4:	89de                	mv	s3,s7
ffffffffc0205cf6:	b729                	j	ffffffffc0205c00 <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205cf8:	59f5                	li	s3,-3
ffffffffc0205cfa:	bbf1                	j	ffffffffc0205ad6 <do_execve+0x224>
            ret = -E_INVAL_ELF;
ffffffffc0205cfc:	59e1                	li	s3,-8
ffffffffc0205cfe:	b5e9                	j	ffffffffc0205bc8 <do_execve+0x316>
ffffffffc0205d00:	00001617          	auipc	a2,0x1
ffffffffc0205d04:	76060613          	addi	a2,a2,1888 # ffffffffc0207460 <default_pmm_manager+0x50>
ffffffffc0205d08:	06900593          	li	a1,105
ffffffffc0205d0c:	00001517          	auipc	a0,0x1
ffffffffc0205d10:	77c50513          	addi	a0,a0,1916 # ffffffffc0207488 <default_pmm_manager+0x78>
ffffffffc0205d14:	f6cfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205d18:	00001617          	auipc	a2,0x1
ffffffffc0205d1c:	78060613          	addi	a2,a2,1920 # ffffffffc0207498 <default_pmm_manager+0x88>
ffffffffc0205d20:	2d800593          	li	a1,728
ffffffffc0205d24:	00003517          	auipc	a0,0x3
ffffffffc0205d28:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205d2c:	f54fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d30:	00003697          	auipc	a3,0x3
ffffffffc0205d34:	8d068693          	addi	a3,a3,-1840 # ffffffffc0208600 <default_pmm_manager+0x11f0>
ffffffffc0205d38:	00001617          	auipc	a2,0x1
ffffffffc0205d3c:	f9060613          	addi	a2,a2,-112 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205d40:	2d200593          	li	a1,722
ffffffffc0205d44:	00003517          	auipc	a0,0x3
ffffffffc0205d48:	b9c50513          	addi	a0,a0,-1124 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205d4c:	f34fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d50:	00003697          	auipc	a3,0x3
ffffffffc0205d54:	86868693          	addi	a3,a3,-1944 # ffffffffc02085b8 <default_pmm_manager+0x11a8>
ffffffffc0205d58:	00001617          	auipc	a2,0x1
ffffffffc0205d5c:	f7060613          	addi	a2,a2,-144 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205d60:	2d100593          	li	a1,721
ffffffffc0205d64:	00003517          	auipc	a0,0x3
ffffffffc0205d68:	b7c50513          	addi	a0,a0,-1156 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205d6c:	f14fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205d70:	00003697          	auipc	a3,0x3
ffffffffc0205d74:	80068693          	addi	a3,a3,-2048 # ffffffffc0208570 <default_pmm_manager+0x1160>
ffffffffc0205d78:	00001617          	auipc	a2,0x1
ffffffffc0205d7c:	f5060613          	addi	a2,a2,-176 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205d80:	2d000593          	li	a1,720
ffffffffc0205d84:	00003517          	auipc	a0,0x3
ffffffffc0205d88:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205d8c:	ef4fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d90:	00002697          	auipc	a3,0x2
ffffffffc0205d94:	79868693          	addi	a3,a3,1944 # ffffffffc0208528 <default_pmm_manager+0x1118>
ffffffffc0205d98:	00001617          	auipc	a2,0x1
ffffffffc0205d9c:	f3060613          	addi	a2,a2,-208 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205da0:	2cf00593          	li	a1,719
ffffffffc0205da4:	00003517          	auipc	a0,0x3
ffffffffc0205da8:	b3c50513          	addi	a0,a0,-1220 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205dac:	ed4fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205db0 <do_yield>:
    current->need_resched = 1;
ffffffffc0205db0:	000a7797          	auipc	a5,0xa7
ffffffffc0205db4:	b1878793          	addi	a5,a5,-1256 # ffffffffc02ac8c8 <current>
ffffffffc0205db8:	639c                	ld	a5,0(a5)
ffffffffc0205dba:	4705                	li	a4,1
}
ffffffffc0205dbc:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205dbe:	ef98                	sd	a4,24(a5)
}
ffffffffc0205dc0:	8082                	ret

ffffffffc0205dc2 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205dc2:	1101                	addi	sp,sp,-32
ffffffffc0205dc4:	e822                	sd	s0,16(sp)
ffffffffc0205dc6:	e426                	sd	s1,8(sp)
ffffffffc0205dc8:	ec06                	sd	ra,24(sp)
ffffffffc0205dca:	842e                	mv	s0,a1
ffffffffc0205dcc:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205dce:	cd81                	beqz	a1,ffffffffc0205de6 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205dd0:	000a7797          	auipc	a5,0xa7
ffffffffc0205dd4:	af878793          	addi	a5,a5,-1288 # ffffffffc02ac8c8 <current>
ffffffffc0205dd8:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205dda:	4685                	li	a3,1
ffffffffc0205ddc:	4611                	li	a2,4
ffffffffc0205dde:	7788                	ld	a0,40(a5)
ffffffffc0205de0:	db5fe0ef          	jal	ra,ffffffffc0204b94 <user_mem_check>
ffffffffc0205de4:	c909                	beqz	a0,ffffffffc0205df6 <do_wait+0x34>
ffffffffc0205de6:	85a2                	mv	a1,s0
}
ffffffffc0205de8:	6442                	ld	s0,16(sp)
ffffffffc0205dea:	60e2                	ld	ra,24(sp)
ffffffffc0205dec:	8526                	mv	a0,s1
ffffffffc0205dee:	64a2                	ld	s1,8(sp)
ffffffffc0205df0:	6105                	addi	sp,sp,32
ffffffffc0205df2:	ff0ff06f          	j	ffffffffc02055e2 <do_wait.part.1>
ffffffffc0205df6:	60e2                	ld	ra,24(sp)
ffffffffc0205df8:	6442                	ld	s0,16(sp)
ffffffffc0205dfa:	64a2                	ld	s1,8(sp)
ffffffffc0205dfc:	5575                	li	a0,-3
ffffffffc0205dfe:	6105                	addi	sp,sp,32
ffffffffc0205e00:	8082                	ret

ffffffffc0205e02 <do_kill>:
do_kill(int pid) {
ffffffffc0205e02:	1141                	addi	sp,sp,-16
ffffffffc0205e04:	e406                	sd	ra,8(sp)
ffffffffc0205e06:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205e08:	a38ff0ef          	jal	ra,ffffffffc0205040 <find_proc>
ffffffffc0205e0c:	cd0d                	beqz	a0,ffffffffc0205e46 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205e0e:	0b052703          	lw	a4,176(a0)
ffffffffc0205e12:	00177693          	andi	a3,a4,1
ffffffffc0205e16:	e695                	bnez	a3,ffffffffc0205e42 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e18:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205e1c:	00176713          	ori	a4,a4,1
ffffffffc0205e20:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205e24:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205e26:	0006c763          	bltz	a3,ffffffffc0205e34 <do_kill+0x32>
}
ffffffffc0205e2a:	8522                	mv	a0,s0
ffffffffc0205e2c:	60a2                	ld	ra,8(sp)
ffffffffc0205e2e:	6402                	ld	s0,0(sp)
ffffffffc0205e30:	0141                	addi	sp,sp,16
ffffffffc0205e32:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205e34:	1e6000ef          	jal	ra,ffffffffc020601a <wakeup_proc>
}
ffffffffc0205e38:	8522                	mv	a0,s0
ffffffffc0205e3a:	60a2                	ld	ra,8(sp)
ffffffffc0205e3c:	6402                	ld	s0,0(sp)
ffffffffc0205e3e:	0141                	addi	sp,sp,16
ffffffffc0205e40:	8082                	ret
        return -E_KILLED;
ffffffffc0205e42:	545d                	li	s0,-9
ffffffffc0205e44:	b7dd                	j	ffffffffc0205e2a <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205e46:	5475                	li	s0,-3
ffffffffc0205e48:	b7cd                	j	ffffffffc0205e2a <do_kill+0x28>

ffffffffc0205e4a <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205e4a:	000a7797          	auipc	a5,0xa7
ffffffffc0205e4e:	bbe78793          	addi	a5,a5,-1090 # ffffffffc02aca08 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205e52:	1101                	addi	sp,sp,-32
ffffffffc0205e54:	000a7717          	auipc	a4,0xa7
ffffffffc0205e58:	baf73e23          	sd	a5,-1092(a4) # ffffffffc02aca10 <proc_list+0x8>
ffffffffc0205e5c:	000a7717          	auipc	a4,0xa7
ffffffffc0205e60:	baf73623          	sd	a5,-1108(a4) # ffffffffc02aca08 <proc_list>
ffffffffc0205e64:	ec06                	sd	ra,24(sp)
ffffffffc0205e66:	e822                	sd	s0,16(sp)
ffffffffc0205e68:	e426                	sd	s1,8(sp)
ffffffffc0205e6a:	000a3797          	auipc	a5,0xa3
ffffffffc0205e6e:	a2678793          	addi	a5,a5,-1498 # ffffffffc02a8890 <hash_list>
ffffffffc0205e72:	000a7717          	auipc	a4,0xa7
ffffffffc0205e76:	a1e70713          	addi	a4,a4,-1506 # ffffffffc02ac890 <is_panic>
ffffffffc0205e7a:	e79c                	sd	a5,8(a5)
ffffffffc0205e7c:	e39c                	sd	a5,0(a5)
ffffffffc0205e7e:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e80:	fee79de3          	bne	a5,a4,ffffffffc0205e7a <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205e84:	f15fe0ef          	jal	ra,ffffffffc0204d98 <alloc_proc>
ffffffffc0205e88:	000a7717          	auipc	a4,0xa7
ffffffffc0205e8c:	a4a73423          	sd	a0,-1464(a4) # ffffffffc02ac8d0 <idleproc>
ffffffffc0205e90:	000a7497          	auipc	s1,0xa7
ffffffffc0205e94:	a4048493          	addi	s1,s1,-1472 # ffffffffc02ac8d0 <idleproc>
ffffffffc0205e98:	c559                	beqz	a0,ffffffffc0205f26 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e9a:	4709                	li	a4,2
ffffffffc0205e9c:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205e9e:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205ea0:	00003717          	auipc	a4,0x3
ffffffffc0205ea4:	16070713          	addi	a4,a4,352 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205ea8:	00003597          	auipc	a1,0x3
ffffffffc0205eac:	95858593          	addi	a1,a1,-1704 # ffffffffc0208800 <default_pmm_manager+0x13f0>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205eb0:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205eb2:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205eb4:	8f4ff0ef          	jal	ra,ffffffffc0204fa8 <set_proc_name>
    nr_process ++;
ffffffffc0205eb8:	000a7797          	auipc	a5,0xa7
ffffffffc0205ebc:	a2878793          	addi	a5,a5,-1496 # ffffffffc02ac8e0 <nr_process>
ffffffffc0205ec0:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205ec2:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ec4:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205ec6:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ec8:	4581                	li	a1,0
ffffffffc0205eca:	00000517          	auipc	a0,0x0
ffffffffc0205ece:	8c050513          	addi	a0,a0,-1856 # ffffffffc020578a <init_main>
    nr_process ++;
ffffffffc0205ed2:	000a7697          	auipc	a3,0xa7
ffffffffc0205ed6:	a0f6a723          	sw	a5,-1522(a3) # ffffffffc02ac8e0 <nr_process>
    current = idleproc;
ffffffffc0205eda:	000a7797          	auipc	a5,0xa7
ffffffffc0205ede:	9ee7b723          	sd	a4,-1554(a5) # ffffffffc02ac8c8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ee2:	d80ff0ef          	jal	ra,ffffffffc0205462 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205ee6:	08a05c63          	blez	a0,ffffffffc0205f7e <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205eea:	956ff0ef          	jal	ra,ffffffffc0205040 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205eee:	00003597          	auipc	a1,0x3
ffffffffc0205ef2:	93a58593          	addi	a1,a1,-1734 # ffffffffc0208828 <default_pmm_manager+0x1418>
    initproc = find_proc(pid);
ffffffffc0205ef6:	000a7797          	auipc	a5,0xa7
ffffffffc0205efa:	9ea7b123          	sd	a0,-1566(a5) # ffffffffc02ac8d8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205efe:	8aaff0ef          	jal	ra,ffffffffc0204fa8 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f02:	609c                	ld	a5,0(s1)
ffffffffc0205f04:	cfa9                	beqz	a5,ffffffffc0205f5e <proc_init+0x114>
ffffffffc0205f06:	43dc                	lw	a5,4(a5)
ffffffffc0205f08:	ebb9                	bnez	a5,ffffffffc0205f5e <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f0a:	000a7797          	auipc	a5,0xa7
ffffffffc0205f0e:	9ce78793          	addi	a5,a5,-1586 # ffffffffc02ac8d8 <initproc>
ffffffffc0205f12:	639c                	ld	a5,0(a5)
ffffffffc0205f14:	c78d                	beqz	a5,ffffffffc0205f3e <proc_init+0xf4>
ffffffffc0205f16:	43dc                	lw	a5,4(a5)
ffffffffc0205f18:	02879363          	bne	a5,s0,ffffffffc0205f3e <proc_init+0xf4>
}
ffffffffc0205f1c:	60e2                	ld	ra,24(sp)
ffffffffc0205f1e:	6442                	ld	s0,16(sp)
ffffffffc0205f20:	64a2                	ld	s1,8(sp)
ffffffffc0205f22:	6105                	addi	sp,sp,32
ffffffffc0205f24:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205f26:	00003617          	auipc	a2,0x3
ffffffffc0205f2a:	8c260613          	addi	a2,a2,-1854 # ffffffffc02087e8 <default_pmm_manager+0x13d8>
ffffffffc0205f2e:	3d200593          	li	a1,978
ffffffffc0205f32:	00003517          	auipc	a0,0x3
ffffffffc0205f36:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205f3a:	d46fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f3e:	00003697          	auipc	a3,0x3
ffffffffc0205f42:	91a68693          	addi	a3,a3,-1766 # ffffffffc0208858 <default_pmm_manager+0x1448>
ffffffffc0205f46:	00001617          	auipc	a2,0x1
ffffffffc0205f4a:	d8260613          	addi	a2,a2,-638 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205f4e:	3e700593          	li	a1,999
ffffffffc0205f52:	00003517          	auipc	a0,0x3
ffffffffc0205f56:	98e50513          	addi	a0,a0,-1650 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205f5a:	d26fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f5e:	00003697          	auipc	a3,0x3
ffffffffc0205f62:	8d268693          	addi	a3,a3,-1838 # ffffffffc0208830 <default_pmm_manager+0x1420>
ffffffffc0205f66:	00001617          	auipc	a2,0x1
ffffffffc0205f6a:	d6260613          	addi	a2,a2,-670 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0205f6e:	3e600593          	li	a1,998
ffffffffc0205f72:	00003517          	auipc	a0,0x3
ffffffffc0205f76:	96e50513          	addi	a0,a0,-1682 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205f7a:	d06fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205f7e:	00003617          	auipc	a2,0x3
ffffffffc0205f82:	88a60613          	addi	a2,a2,-1910 # ffffffffc0208808 <default_pmm_manager+0x13f8>
ffffffffc0205f86:	3e000593          	li	a1,992
ffffffffc0205f8a:	00003517          	auipc	a0,0x3
ffffffffc0205f8e:	95650513          	addi	a0,a0,-1706 # ffffffffc02088e0 <default_pmm_manager+0x14d0>
ffffffffc0205f92:	ceefa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205f96 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f96:	1141                	addi	sp,sp,-16
ffffffffc0205f98:	e022                	sd	s0,0(sp)
ffffffffc0205f9a:	e406                	sd	ra,8(sp)
ffffffffc0205f9c:	000a7417          	auipc	s0,0xa7
ffffffffc0205fa0:	92c40413          	addi	s0,s0,-1748 # ffffffffc02ac8c8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205fa4:	6018                	ld	a4,0(s0)
ffffffffc0205fa6:	6f1c                	ld	a5,24(a4)
ffffffffc0205fa8:	dffd                	beqz	a5,ffffffffc0205fa6 <cpu_idle+0x10>
            schedule();
ffffffffc0205faa:	0ec000ef          	jal	ra,ffffffffc0206096 <schedule>
ffffffffc0205fae:	bfdd                	j	ffffffffc0205fa4 <cpu_idle+0xe>

ffffffffc0205fb0 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205fb0:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205fb4:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205fb8:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205fba:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205fbc:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205fc0:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205fc4:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205fc8:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205fcc:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205fd0:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205fd4:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205fd8:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205fdc:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205fe0:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205fe4:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205fe8:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205fec:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205fee:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205ff0:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205ff4:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205ff8:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205ffc:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0206000:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0206004:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0206008:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020600c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0206010:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0206014:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0206018:	8082                	ret

ffffffffc020601a <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020601a:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc020601c:	1101                	addi	sp,sp,-32
ffffffffc020601e:	ec06                	sd	ra,24(sp)
ffffffffc0206020:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206022:	478d                	li	a5,3
ffffffffc0206024:	04f70a63          	beq	a4,a5,ffffffffc0206078 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206028:	100027f3          	csrr	a5,sstatus
ffffffffc020602c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020602e:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206030:	ef8d                	bnez	a5,ffffffffc020606a <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206032:	4789                	li	a5,2
ffffffffc0206034:	00f70f63          	beq	a4,a5,ffffffffc0206052 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0206038:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc020603a:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc020603e:	e409                	bnez	s0,ffffffffc0206048 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206040:	60e2                	ld	ra,24(sp)
ffffffffc0206042:	6442                	ld	s0,16(sp)
ffffffffc0206044:	6105                	addi	sp,sp,32
ffffffffc0206046:	8082                	ret
ffffffffc0206048:	6442                	ld	s0,16(sp)
ffffffffc020604a:	60e2                	ld	ra,24(sp)
ffffffffc020604c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020604e:	dfefa06f          	j	ffffffffc020064c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206052:	00003617          	auipc	a2,0x3
ffffffffc0206056:	8de60613          	addi	a2,a2,-1826 # ffffffffc0208930 <default_pmm_manager+0x1520>
ffffffffc020605a:	45c9                	li	a1,18
ffffffffc020605c:	00003517          	auipc	a0,0x3
ffffffffc0206060:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0208918 <default_pmm_manager+0x1508>
ffffffffc0206064:	c88fa0ef          	jal	ra,ffffffffc02004ec <__warn>
ffffffffc0206068:	bfd9                	j	ffffffffc020603e <wakeup_proc+0x24>
ffffffffc020606a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020606c:	de6fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206070:	6522                	ld	a0,8(sp)
ffffffffc0206072:	4405                	li	s0,1
ffffffffc0206074:	4118                	lw	a4,0(a0)
ffffffffc0206076:	bf75                	j	ffffffffc0206032 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206078:	00003697          	auipc	a3,0x3
ffffffffc020607c:	88068693          	addi	a3,a3,-1920 # ffffffffc02088f8 <default_pmm_manager+0x14e8>
ffffffffc0206080:	00001617          	auipc	a2,0x1
ffffffffc0206084:	c4860613          	addi	a2,a2,-952 # ffffffffc0206cc8 <commands+0x4c0>
ffffffffc0206088:	45a5                	li	a1,9
ffffffffc020608a:	00003517          	auipc	a0,0x3
ffffffffc020608e:	88e50513          	addi	a0,a0,-1906 # ffffffffc0208918 <default_pmm_manager+0x1508>
ffffffffc0206092:	beefa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0206096 <schedule>:

void
schedule(void) {
ffffffffc0206096:	1141                	addi	sp,sp,-16
ffffffffc0206098:	e406                	sd	ra,8(sp)
ffffffffc020609a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020609c:	100027f3          	csrr	a5,sstatus
ffffffffc02060a0:	8b89                	andi	a5,a5,2
ffffffffc02060a2:	4401                	li	s0,0
ffffffffc02060a4:	e3d1                	bnez	a5,ffffffffc0206128 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02060a6:	000a7797          	auipc	a5,0xa7
ffffffffc02060aa:	82278793          	addi	a5,a5,-2014 # ffffffffc02ac8c8 <current>
ffffffffc02060ae:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02060b2:	000a7797          	auipc	a5,0xa7
ffffffffc02060b6:	81e78793          	addi	a5,a5,-2018 # ffffffffc02ac8d0 <idleproc>
ffffffffc02060ba:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02060bc:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x75b8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02060c0:	04a88e63          	beq	a7,a0,ffffffffc020611c <schedule+0x86>
ffffffffc02060c4:	0c888693          	addi	a3,a7,200
ffffffffc02060c8:	000a7617          	auipc	a2,0xa7
ffffffffc02060cc:	94060613          	addi	a2,a2,-1728 # ffffffffc02aca08 <proc_list>
        le = last;
ffffffffc02060d0:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02060d2:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02060d4:	4809                	li	a6,2
    return listelm->next;
ffffffffc02060d6:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02060d8:	00c78863          	beq	a5,a2,ffffffffc02060e8 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02060dc:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02060e0:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02060e4:	01070463          	beq	a4,a6,ffffffffc02060ec <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02060e8:	fef697e3          	bne	a3,a5,ffffffffc02060d6 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02060ec:	c589                	beqz	a1,ffffffffc02060f6 <schedule+0x60>
ffffffffc02060ee:	4198                	lw	a4,0(a1)
ffffffffc02060f0:	4789                	li	a5,2
ffffffffc02060f2:	00f70e63          	beq	a4,a5,ffffffffc020610e <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02060f6:	451c                	lw	a5,8(a0)
ffffffffc02060f8:	2785                	addiw	a5,a5,1
ffffffffc02060fa:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02060fc:	00a88463          	beq	a7,a0,ffffffffc0206104 <schedule+0x6e>
            proc_run(next);
ffffffffc0206100:	ed3fe0ef          	jal	ra,ffffffffc0204fd2 <proc_run>
    if (flag) {
ffffffffc0206104:	e419                	bnez	s0,ffffffffc0206112 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206106:	60a2                	ld	ra,8(sp)
ffffffffc0206108:	6402                	ld	s0,0(sp)
ffffffffc020610a:	0141                	addi	sp,sp,16
ffffffffc020610c:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020610e:	852e                	mv	a0,a1
ffffffffc0206110:	b7dd                	j	ffffffffc02060f6 <schedule+0x60>
}
ffffffffc0206112:	6402                	ld	s0,0(sp)
ffffffffc0206114:	60a2                	ld	ra,8(sp)
ffffffffc0206116:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206118:	d34fa06f          	j	ffffffffc020064c <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020611c:	000a7617          	auipc	a2,0xa7
ffffffffc0206120:	8ec60613          	addi	a2,a2,-1812 # ffffffffc02aca08 <proc_list>
ffffffffc0206124:	86b2                	mv	a3,a2
ffffffffc0206126:	b76d                	j	ffffffffc02060d0 <schedule+0x3a>
        intr_disable();
ffffffffc0206128:	d2afa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc020612c:	4405                	li	s0,1
ffffffffc020612e:	bfa5                	j	ffffffffc02060a6 <schedule+0x10>

ffffffffc0206130 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206130:	000a6797          	auipc	a5,0xa6
ffffffffc0206134:	79878793          	addi	a5,a5,1944 # ffffffffc02ac8c8 <current>
ffffffffc0206138:	639c                	ld	a5,0(a5)
}
ffffffffc020613a:	43c8                	lw	a0,4(a5)
ffffffffc020613c:	8082                	ret

ffffffffc020613e <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020613e:	4501                	li	a0,0
ffffffffc0206140:	8082                	ret

ffffffffc0206142 <sys_putc>:
    cputchar(c);
ffffffffc0206142:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206144:	1141                	addi	sp,sp,-16
ffffffffc0206146:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206148:	87afa0ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc020614c:	60a2                	ld	ra,8(sp)
ffffffffc020614e:	4501                	li	a0,0
ffffffffc0206150:	0141                	addi	sp,sp,16
ffffffffc0206152:	8082                	ret

ffffffffc0206154 <sys_kill>:
    return do_kill(pid);
ffffffffc0206154:	4108                	lw	a0,0(a0)
ffffffffc0206156:	cadff06f          	j	ffffffffc0205e02 <do_kill>

ffffffffc020615a <sys_yield>:
    return do_yield();
ffffffffc020615a:	c57ff06f          	j	ffffffffc0205db0 <do_yield>

ffffffffc020615e <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020615e:	6d14                	ld	a3,24(a0)
ffffffffc0206160:	6910                	ld	a2,16(a0)
ffffffffc0206162:	650c                	ld	a1,8(a0)
ffffffffc0206164:	6108                	ld	a0,0(a0)
ffffffffc0206166:	f4cff06f          	j	ffffffffc02058b2 <do_execve>

ffffffffc020616a <sys_wait>:
    return do_wait(pid, store);
ffffffffc020616a:	650c                	ld	a1,8(a0)
ffffffffc020616c:	4108                	lw	a0,0(a0)
ffffffffc020616e:	c55ff06f          	j	ffffffffc0205dc2 <do_wait>

ffffffffc0206172 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206172:	000a6797          	auipc	a5,0xa6
ffffffffc0206176:	75678793          	addi	a5,a5,1878 # ffffffffc02ac8c8 <current>
ffffffffc020617a:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc020617c:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc020617e:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206180:	6a0c                	ld	a1,16(a2)
ffffffffc0206182:	f1bfe06f          	j	ffffffffc020509c <do_fork>

ffffffffc0206186 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206186:	4108                	lw	a0,0(a0)
ffffffffc0206188:	b2aff06f          	j	ffffffffc02054b2 <do_exit>

ffffffffc020618c <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020618c:	715d                	addi	sp,sp,-80
ffffffffc020618e:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206190:	000a6497          	auipc	s1,0xa6
ffffffffc0206194:	73848493          	addi	s1,s1,1848 # ffffffffc02ac8c8 <current>
ffffffffc0206198:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020619a:	e0a2                	sd	s0,64(sp)
ffffffffc020619c:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc020619e:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02061a0:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061a2:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02061a4:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061a8:	0327ee63          	bltu	a5,s2,ffffffffc02061e4 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02061ac:	00391713          	slli	a4,s2,0x3
ffffffffc02061b0:	00002797          	auipc	a5,0x2
ffffffffc02061b4:	7e878793          	addi	a5,a5,2024 # ffffffffc0208998 <syscalls>
ffffffffc02061b8:	97ba                	add	a5,a5,a4
ffffffffc02061ba:	639c                	ld	a5,0(a5)
ffffffffc02061bc:	c785                	beqz	a5,ffffffffc02061e4 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02061be:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02061c0:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02061c2:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02061c4:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02061c6:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02061c8:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02061ca:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02061cc:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02061ce:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02061d0:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02061d2:	0028                	addi	a0,sp,8
ffffffffc02061d4:	9782                	jalr	a5
ffffffffc02061d6:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02061d8:	60a6                	ld	ra,72(sp)
ffffffffc02061da:	6406                	ld	s0,64(sp)
ffffffffc02061dc:	74e2                	ld	s1,56(sp)
ffffffffc02061de:	7942                	ld	s2,48(sp)
ffffffffc02061e0:	6161                	addi	sp,sp,80
ffffffffc02061e2:	8082                	ret
    print_trapframe(tf);
ffffffffc02061e4:	8522                	mv	a0,s0
ffffffffc02061e6:	e5afa0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02061ea:	609c                	ld	a5,0(s1)
ffffffffc02061ec:	86ca                	mv	a3,s2
ffffffffc02061ee:	00002617          	auipc	a2,0x2
ffffffffc02061f2:	76260613          	addi	a2,a2,1890 # ffffffffc0208950 <default_pmm_manager+0x1540>
ffffffffc02061f6:	43d8                	lw	a4,4(a5)
ffffffffc02061f8:	06300593          	li	a1,99
ffffffffc02061fc:	0b478793          	addi	a5,a5,180
ffffffffc0206200:	00002517          	auipc	a0,0x2
ffffffffc0206204:	78050513          	addi	a0,a0,1920 # ffffffffc0208980 <default_pmm_manager+0x1570>
ffffffffc0206208:	a78fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020620c <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020620c:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206210:	2785                	addiw	a5,a5,1
ffffffffc0206212:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0206216:	02000793          	li	a5,32
ffffffffc020621a:	40b785bb          	subw	a1,a5,a1
}
ffffffffc020621e:	00b5553b          	srlw	a0,a0,a1
ffffffffc0206222:	8082                	ret

ffffffffc0206224 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206224:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206228:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020622a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020622e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206230:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206234:	f022                	sd	s0,32(sp)
ffffffffc0206236:	ec26                	sd	s1,24(sp)
ffffffffc0206238:	e84a                	sd	s2,16(sp)
ffffffffc020623a:	f406                	sd	ra,40(sp)
ffffffffc020623c:	e44e                	sd	s3,8(sp)
ffffffffc020623e:	84aa                	mv	s1,a0
ffffffffc0206240:	892e                	mv	s2,a1
ffffffffc0206242:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206246:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0206248:	03067e63          	bgeu	a2,a6,ffffffffc0206284 <printnum+0x60>
ffffffffc020624c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020624e:	00805763          	blez	s0,ffffffffc020625c <printnum+0x38>
ffffffffc0206252:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206254:	85ca                	mv	a1,s2
ffffffffc0206256:	854e                	mv	a0,s3
ffffffffc0206258:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020625a:	fc65                	bnez	s0,ffffffffc0206252 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020625c:	1a02                	slli	s4,s4,0x20
ffffffffc020625e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206262:	00003797          	auipc	a5,0x3
ffffffffc0206266:	a5678793          	addi	a5,a5,-1450 # ffffffffc0208cb8 <error_string+0xc8>
ffffffffc020626a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020626c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020626e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206272:	70a2                	ld	ra,40(sp)
ffffffffc0206274:	69a2                	ld	s3,8(sp)
ffffffffc0206276:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206278:	85ca                	mv	a1,s2
ffffffffc020627a:	8326                	mv	t1,s1
}
ffffffffc020627c:	6942                	ld	s2,16(sp)
ffffffffc020627e:	64e2                	ld	s1,24(sp)
ffffffffc0206280:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206282:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206284:	03065633          	divu	a2,a2,a6
ffffffffc0206288:	8722                	mv	a4,s0
ffffffffc020628a:	f9bff0ef          	jal	ra,ffffffffc0206224 <printnum>
ffffffffc020628e:	b7f9                	j	ffffffffc020625c <printnum+0x38>

ffffffffc0206290 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206290:	7119                	addi	sp,sp,-128
ffffffffc0206292:	f4a6                	sd	s1,104(sp)
ffffffffc0206294:	f0ca                	sd	s2,96(sp)
ffffffffc0206296:	e8d2                	sd	s4,80(sp)
ffffffffc0206298:	e4d6                	sd	s5,72(sp)
ffffffffc020629a:	e0da                	sd	s6,64(sp)
ffffffffc020629c:	fc5e                	sd	s7,56(sp)
ffffffffc020629e:	f862                	sd	s8,48(sp)
ffffffffc02062a0:	f06a                	sd	s10,32(sp)
ffffffffc02062a2:	fc86                	sd	ra,120(sp)
ffffffffc02062a4:	f8a2                	sd	s0,112(sp)
ffffffffc02062a6:	ecce                	sd	s3,88(sp)
ffffffffc02062a8:	f466                	sd	s9,40(sp)
ffffffffc02062aa:	ec6e                	sd	s11,24(sp)
ffffffffc02062ac:	892a                	mv	s2,a0
ffffffffc02062ae:	84ae                	mv	s1,a1
ffffffffc02062b0:	8d32                	mv	s10,a2
ffffffffc02062b2:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02062b4:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062b6:	00002a17          	auipc	s4,0x2
ffffffffc02062ba:	7e2a0a13          	addi	s4,s4,2018 # ffffffffc0208a98 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02062be:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062c2:	00003c17          	auipc	s8,0x3
ffffffffc02062c6:	92ec0c13          	addi	s8,s8,-1746 # ffffffffc0208bf0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ca:	000d4503          	lbu	a0,0(s10)
ffffffffc02062ce:	02500793          	li	a5,37
ffffffffc02062d2:	001d0413          	addi	s0,s10,1
ffffffffc02062d6:	00f50e63          	beq	a0,a5,ffffffffc02062f2 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02062da:	c521                	beqz	a0,ffffffffc0206322 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062dc:	02500993          	li	s3,37
ffffffffc02062e0:	a011                	j	ffffffffc02062e4 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02062e2:	c121                	beqz	a0,ffffffffc0206322 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02062e4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062e6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02062e8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ea:	fff44503          	lbu	a0,-1(s0)
ffffffffc02062ee:	ff351ae3          	bne	a0,s3,ffffffffc02062e2 <vprintfmt+0x52>
ffffffffc02062f2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02062f6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02062fa:	4981                	li	s3,0
ffffffffc02062fc:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02062fe:	5cfd                	li	s9,-1
ffffffffc0206300:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206302:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0206306:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206308:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020630c:	0ff6f693          	andi	a3,a3,255
ffffffffc0206310:	00140d13          	addi	s10,s0,1
ffffffffc0206314:	1ed5ef63          	bltu	a1,a3,ffffffffc0206512 <vprintfmt+0x282>
ffffffffc0206318:	068a                	slli	a3,a3,0x2
ffffffffc020631a:	96d2                	add	a3,a3,s4
ffffffffc020631c:	4294                	lw	a3,0(a3)
ffffffffc020631e:	96d2                	add	a3,a3,s4
ffffffffc0206320:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206322:	70e6                	ld	ra,120(sp)
ffffffffc0206324:	7446                	ld	s0,112(sp)
ffffffffc0206326:	74a6                	ld	s1,104(sp)
ffffffffc0206328:	7906                	ld	s2,96(sp)
ffffffffc020632a:	69e6                	ld	s3,88(sp)
ffffffffc020632c:	6a46                	ld	s4,80(sp)
ffffffffc020632e:	6aa6                	ld	s5,72(sp)
ffffffffc0206330:	6b06                	ld	s6,64(sp)
ffffffffc0206332:	7be2                	ld	s7,56(sp)
ffffffffc0206334:	7c42                	ld	s8,48(sp)
ffffffffc0206336:	7ca2                	ld	s9,40(sp)
ffffffffc0206338:	7d02                	ld	s10,32(sp)
ffffffffc020633a:	6de2                	ld	s11,24(sp)
ffffffffc020633c:	6109                	addi	sp,sp,128
ffffffffc020633e:	8082                	ret
            padc = '-';
ffffffffc0206340:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206342:	00144603          	lbu	a2,1(s0)
ffffffffc0206346:	846a                	mv	s0,s10
ffffffffc0206348:	b7c1                	j	ffffffffc0206308 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc020634a:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020634e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206352:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206354:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206356:	fa0dd9e3          	bgez	s11,ffffffffc0206308 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020635a:	8de6                	mv	s11,s9
ffffffffc020635c:	5cfd                	li	s9,-1
ffffffffc020635e:	b76d                	j	ffffffffc0206308 <vprintfmt+0x78>
            if (width < 0)
ffffffffc0206360:	fffdc693          	not	a3,s11
ffffffffc0206364:	96fd                	srai	a3,a3,0x3f
ffffffffc0206366:	00ddfdb3          	and	s11,s11,a3
ffffffffc020636a:	00144603          	lbu	a2,1(s0)
ffffffffc020636e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206370:	846a                	mv	s0,s10
ffffffffc0206372:	bf59                	j	ffffffffc0206308 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206374:	4705                	li	a4,1
ffffffffc0206376:	008a8593          	addi	a1,s5,8
ffffffffc020637a:	01074463          	blt	a4,a6,ffffffffc0206382 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc020637e:	22080863          	beqz	a6,ffffffffc02065ae <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0206382:	000ab603          	ld	a2,0(s5)
ffffffffc0206386:	46c1                	li	a3,16
ffffffffc0206388:	8aae                	mv	s5,a1
ffffffffc020638a:	a291                	j	ffffffffc02064ce <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc020638c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206390:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206394:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206396:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020639a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020639e:	fad56ce3          	bltu	a0,a3,ffffffffc0206356 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc02063a2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02063a4:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02063a8:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02063ac:	0196873b          	addw	a4,a3,s9
ffffffffc02063b0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02063b4:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02063b8:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02063bc:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02063c0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02063c4:	fcd57fe3          	bgeu	a0,a3,ffffffffc02063a2 <vprintfmt+0x112>
ffffffffc02063c8:	b779                	j	ffffffffc0206356 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc02063ca:	000aa503          	lw	a0,0(s5)
ffffffffc02063ce:	85a6                	mv	a1,s1
ffffffffc02063d0:	0aa1                	addi	s5,s5,8
ffffffffc02063d2:	9902                	jalr	s2
            break;
ffffffffc02063d4:	bddd                	j	ffffffffc02062ca <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063d6:	4705                	li	a4,1
ffffffffc02063d8:	008a8993          	addi	s3,s5,8
ffffffffc02063dc:	01074463          	blt	a4,a6,ffffffffc02063e4 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc02063e0:	1c080463          	beqz	a6,ffffffffc02065a8 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02063e4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02063e8:	1c044a63          	bltz	s0,ffffffffc02065bc <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02063ec:	8622                	mv	a2,s0
ffffffffc02063ee:	8ace                	mv	s5,s3
ffffffffc02063f0:	46a9                	li	a3,10
ffffffffc02063f2:	a8f1                	j	ffffffffc02064ce <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02063f4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063f8:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02063fa:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02063fc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206400:	8fb5                	xor	a5,a5,a3
ffffffffc0206402:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206406:	12d74963          	blt	a4,a3,ffffffffc0206538 <vprintfmt+0x2a8>
ffffffffc020640a:	00369793          	slli	a5,a3,0x3
ffffffffc020640e:	97e2                	add	a5,a5,s8
ffffffffc0206410:	639c                	ld	a5,0(a5)
ffffffffc0206412:	12078363          	beqz	a5,ffffffffc0206538 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206416:	86be                	mv	a3,a5
ffffffffc0206418:	00000617          	auipc	a2,0x0
ffffffffc020641c:	2e860613          	addi	a2,a2,744 # ffffffffc0206700 <etext+0x28>
ffffffffc0206420:	85a6                	mv	a1,s1
ffffffffc0206422:	854a                	mv	a0,s2
ffffffffc0206424:	1cc000ef          	jal	ra,ffffffffc02065f0 <printfmt>
ffffffffc0206428:	b54d                	j	ffffffffc02062ca <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020642a:	000ab603          	ld	a2,0(s5)
ffffffffc020642e:	0aa1                	addi	s5,s5,8
ffffffffc0206430:	1a060163          	beqz	a2,ffffffffc02065d2 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0206434:	00160413          	addi	s0,a2,1
ffffffffc0206438:	15b05763          	blez	s11,ffffffffc0206586 <vprintfmt+0x2f6>
ffffffffc020643c:	02d00593          	li	a1,45
ffffffffc0206440:	10b79d63          	bne	a5,a1,ffffffffc020655a <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206444:	00064783          	lbu	a5,0(a2)
ffffffffc0206448:	0007851b          	sext.w	a0,a5
ffffffffc020644c:	c905                	beqz	a0,ffffffffc020647c <vprintfmt+0x1ec>
ffffffffc020644e:	000cc563          	bltz	s9,ffffffffc0206458 <vprintfmt+0x1c8>
ffffffffc0206452:	3cfd                	addiw	s9,s9,-1
ffffffffc0206454:	036c8263          	beq	s9,s6,ffffffffc0206478 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0206458:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020645a:	14098f63          	beqz	s3,ffffffffc02065b8 <vprintfmt+0x328>
ffffffffc020645e:	3781                	addiw	a5,a5,-32
ffffffffc0206460:	14fbfc63          	bgeu	s7,a5,ffffffffc02065b8 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0206464:	03f00513          	li	a0,63
ffffffffc0206468:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020646a:	0405                	addi	s0,s0,1
ffffffffc020646c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206470:	3dfd                	addiw	s11,s11,-1
ffffffffc0206472:	0007851b          	sext.w	a0,a5
ffffffffc0206476:	fd61                	bnez	a0,ffffffffc020644e <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0206478:	e5b059e3          	blez	s11,ffffffffc02062ca <vprintfmt+0x3a>
ffffffffc020647c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020647e:	85a6                	mv	a1,s1
ffffffffc0206480:	02000513          	li	a0,32
ffffffffc0206484:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206486:	e40d82e3          	beqz	s11,ffffffffc02062ca <vprintfmt+0x3a>
ffffffffc020648a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020648c:	85a6                	mv	a1,s1
ffffffffc020648e:	02000513          	li	a0,32
ffffffffc0206492:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206494:	fe0d94e3          	bnez	s11,ffffffffc020647c <vprintfmt+0x1ec>
ffffffffc0206498:	bd0d                	j	ffffffffc02062ca <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020649a:	4705                	li	a4,1
ffffffffc020649c:	008a8593          	addi	a1,s5,8
ffffffffc02064a0:	01074463          	blt	a4,a6,ffffffffc02064a8 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc02064a4:	0e080863          	beqz	a6,ffffffffc0206594 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc02064a8:	000ab603          	ld	a2,0(s5)
ffffffffc02064ac:	46a1                	li	a3,8
ffffffffc02064ae:	8aae                	mv	s5,a1
ffffffffc02064b0:	a839                	j	ffffffffc02064ce <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc02064b2:	03000513          	li	a0,48
ffffffffc02064b6:	85a6                	mv	a1,s1
ffffffffc02064b8:	e03e                	sd	a5,0(sp)
ffffffffc02064ba:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02064bc:	85a6                	mv	a1,s1
ffffffffc02064be:	07800513          	li	a0,120
ffffffffc02064c2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02064c4:	0aa1                	addi	s5,s5,8
ffffffffc02064c6:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02064ca:	6782                	ld	a5,0(sp)
ffffffffc02064cc:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02064ce:	2781                	sext.w	a5,a5
ffffffffc02064d0:	876e                	mv	a4,s11
ffffffffc02064d2:	85a6                	mv	a1,s1
ffffffffc02064d4:	854a                	mv	a0,s2
ffffffffc02064d6:	d4fff0ef          	jal	ra,ffffffffc0206224 <printnum>
            break;
ffffffffc02064da:	bbc5                	j	ffffffffc02062ca <vprintfmt+0x3a>
            lflag ++;
ffffffffc02064dc:	00144603          	lbu	a2,1(s0)
ffffffffc02064e0:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064e2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064e4:	b515                	j	ffffffffc0206308 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02064e6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02064ea:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064ec:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064ee:	bd29                	j	ffffffffc0206308 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02064f0:	85a6                	mv	a1,s1
ffffffffc02064f2:	02500513          	li	a0,37
ffffffffc02064f6:	9902                	jalr	s2
            break;
ffffffffc02064f8:	bbc9                	j	ffffffffc02062ca <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02064fa:	4705                	li	a4,1
ffffffffc02064fc:	008a8593          	addi	a1,s5,8
ffffffffc0206500:	01074463          	blt	a4,a6,ffffffffc0206508 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0206504:	08080d63          	beqz	a6,ffffffffc020659e <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0206508:	000ab603          	ld	a2,0(s5)
ffffffffc020650c:	46a9                	li	a3,10
ffffffffc020650e:	8aae                	mv	s5,a1
ffffffffc0206510:	bf7d                	j	ffffffffc02064ce <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0206512:	85a6                	mv	a1,s1
ffffffffc0206514:	02500513          	li	a0,37
ffffffffc0206518:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020651a:	fff44703          	lbu	a4,-1(s0)
ffffffffc020651e:	02500793          	li	a5,37
ffffffffc0206522:	8d22                	mv	s10,s0
ffffffffc0206524:	daf703e3          	beq	a4,a5,ffffffffc02062ca <vprintfmt+0x3a>
ffffffffc0206528:	02500713          	li	a4,37
ffffffffc020652c:	1d7d                	addi	s10,s10,-1
ffffffffc020652e:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206532:	fee79de3          	bne	a5,a4,ffffffffc020652c <vprintfmt+0x29c>
ffffffffc0206536:	bb51                	j	ffffffffc02062ca <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206538:	00003617          	auipc	a2,0x3
ffffffffc020653c:	86060613          	addi	a2,a2,-1952 # ffffffffc0208d98 <error_string+0x1a8>
ffffffffc0206540:	85a6                	mv	a1,s1
ffffffffc0206542:	854a                	mv	a0,s2
ffffffffc0206544:	0ac000ef          	jal	ra,ffffffffc02065f0 <printfmt>
ffffffffc0206548:	b349                	j	ffffffffc02062ca <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020654a:	00003617          	auipc	a2,0x3
ffffffffc020654e:	84660613          	addi	a2,a2,-1978 # ffffffffc0208d90 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206552:	00003417          	auipc	s0,0x3
ffffffffc0206556:	83f40413          	addi	s0,s0,-1985 # ffffffffc0208d91 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020655a:	8532                	mv	a0,a2
ffffffffc020655c:	85e6                	mv	a1,s9
ffffffffc020655e:	e032                	sd	a2,0(sp)
ffffffffc0206560:	e43e                	sd	a5,8(sp)
ffffffffc0206562:	0cc000ef          	jal	ra,ffffffffc020662e <strnlen>
ffffffffc0206566:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020656a:	6602                	ld	a2,0(sp)
ffffffffc020656c:	01b05d63          	blez	s11,ffffffffc0206586 <vprintfmt+0x2f6>
ffffffffc0206570:	67a2                	ld	a5,8(sp)
ffffffffc0206572:	2781                	sext.w	a5,a5
ffffffffc0206574:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206576:	6522                	ld	a0,8(sp)
ffffffffc0206578:	85a6                	mv	a1,s1
ffffffffc020657a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020657c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020657e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206580:	6602                	ld	a2,0(sp)
ffffffffc0206582:	fe0d9ae3          	bnez	s11,ffffffffc0206576 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206586:	00064783          	lbu	a5,0(a2)
ffffffffc020658a:	0007851b          	sext.w	a0,a5
ffffffffc020658e:	ec0510e3          	bnez	a0,ffffffffc020644e <vprintfmt+0x1be>
ffffffffc0206592:	bb25                	j	ffffffffc02062ca <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0206594:	000ae603          	lwu	a2,0(s5)
ffffffffc0206598:	46a1                	li	a3,8
ffffffffc020659a:	8aae                	mv	s5,a1
ffffffffc020659c:	bf0d                	j	ffffffffc02064ce <vprintfmt+0x23e>
ffffffffc020659e:	000ae603          	lwu	a2,0(s5)
ffffffffc02065a2:	46a9                	li	a3,10
ffffffffc02065a4:	8aae                	mv	s5,a1
ffffffffc02065a6:	b725                	j	ffffffffc02064ce <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc02065a8:	000aa403          	lw	s0,0(s5)
ffffffffc02065ac:	bd35                	j	ffffffffc02063e8 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc02065ae:	000ae603          	lwu	a2,0(s5)
ffffffffc02065b2:	46c1                	li	a3,16
ffffffffc02065b4:	8aae                	mv	s5,a1
ffffffffc02065b6:	bf21                	j	ffffffffc02064ce <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc02065b8:	9902                	jalr	s2
ffffffffc02065ba:	bd45                	j	ffffffffc020646a <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc02065bc:	85a6                	mv	a1,s1
ffffffffc02065be:	02d00513          	li	a0,45
ffffffffc02065c2:	e03e                	sd	a5,0(sp)
ffffffffc02065c4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02065c6:	8ace                	mv	s5,s3
ffffffffc02065c8:	40800633          	neg	a2,s0
ffffffffc02065cc:	46a9                	li	a3,10
ffffffffc02065ce:	6782                	ld	a5,0(sp)
ffffffffc02065d0:	bdfd                	j	ffffffffc02064ce <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc02065d2:	01b05663          	blez	s11,ffffffffc02065de <vprintfmt+0x34e>
ffffffffc02065d6:	02d00693          	li	a3,45
ffffffffc02065da:	f6d798e3          	bne	a5,a3,ffffffffc020654a <vprintfmt+0x2ba>
ffffffffc02065de:	00002417          	auipc	s0,0x2
ffffffffc02065e2:	7b340413          	addi	s0,s0,1971 # ffffffffc0208d91 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065e6:	02800513          	li	a0,40
ffffffffc02065ea:	02800793          	li	a5,40
ffffffffc02065ee:	b585                	j	ffffffffc020644e <vprintfmt+0x1be>

ffffffffc02065f0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065f0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065f2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065f6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065f8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065fa:	ec06                	sd	ra,24(sp)
ffffffffc02065fc:	f83a                	sd	a4,48(sp)
ffffffffc02065fe:	fc3e                	sd	a5,56(sp)
ffffffffc0206600:	e0c2                	sd	a6,64(sp)
ffffffffc0206602:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206604:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206606:	c8bff0ef          	jal	ra,ffffffffc0206290 <vprintfmt>
}
ffffffffc020660a:	60e2                	ld	ra,24(sp)
ffffffffc020660c:	6161                	addi	sp,sp,80
ffffffffc020660e:	8082                	ret

ffffffffc0206610 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206610:	00054783          	lbu	a5,0(a0)
ffffffffc0206614:	cb91                	beqz	a5,ffffffffc0206628 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206616:	4781                	li	a5,0
        cnt ++;
ffffffffc0206618:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020661a:	00f50733          	add	a4,a0,a5
ffffffffc020661e:	00074703          	lbu	a4,0(a4)
ffffffffc0206622:	fb7d                	bnez	a4,ffffffffc0206618 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206624:	853e                	mv	a0,a5
ffffffffc0206626:	8082                	ret
    size_t cnt = 0;
ffffffffc0206628:	4781                	li	a5,0
}
ffffffffc020662a:	853e                	mv	a0,a5
ffffffffc020662c:	8082                	ret

ffffffffc020662e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020662e:	c185                	beqz	a1,ffffffffc020664e <strnlen+0x20>
ffffffffc0206630:	00054783          	lbu	a5,0(a0)
ffffffffc0206634:	cf89                	beqz	a5,ffffffffc020664e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206636:	4781                	li	a5,0
ffffffffc0206638:	a021                	j	ffffffffc0206640 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020663a:	00074703          	lbu	a4,0(a4)
ffffffffc020663e:	c711                	beqz	a4,ffffffffc020664a <strnlen+0x1c>
        cnt ++;
ffffffffc0206640:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206642:	00f50733          	add	a4,a0,a5
ffffffffc0206646:	fef59ae3          	bne	a1,a5,ffffffffc020663a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020664a:	853e                	mv	a0,a5
ffffffffc020664c:	8082                	ret
    size_t cnt = 0;
ffffffffc020664e:	4781                	li	a5,0
}
ffffffffc0206650:	853e                	mv	a0,a5
ffffffffc0206652:	8082                	ret

ffffffffc0206654 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206654:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206656:	0585                	addi	a1,a1,1
ffffffffc0206658:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020665c:	0785                	addi	a5,a5,1
ffffffffc020665e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206662:	fb75                	bnez	a4,ffffffffc0206656 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206664:	8082                	ret

ffffffffc0206666 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206666:	00054783          	lbu	a5,0(a0)
ffffffffc020666a:	0005c703          	lbu	a4,0(a1)
ffffffffc020666e:	cb91                	beqz	a5,ffffffffc0206682 <strcmp+0x1c>
ffffffffc0206670:	00e79c63          	bne	a5,a4,ffffffffc0206688 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206674:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206676:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020667a:	0585                	addi	a1,a1,1
ffffffffc020667c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206680:	fbe5                	bnez	a5,ffffffffc0206670 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206682:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206684:	9d19                	subw	a0,a0,a4
ffffffffc0206686:	8082                	ret
ffffffffc0206688:	0007851b          	sext.w	a0,a5
ffffffffc020668c:	9d19                	subw	a0,a0,a4
ffffffffc020668e:	8082                	ret

ffffffffc0206690 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206690:	00054783          	lbu	a5,0(a0)
ffffffffc0206694:	cb91                	beqz	a5,ffffffffc02066a8 <strchr+0x18>
        if (*s == c) {
ffffffffc0206696:	00b79563          	bne	a5,a1,ffffffffc02066a0 <strchr+0x10>
ffffffffc020669a:	a809                	j	ffffffffc02066ac <strchr+0x1c>
ffffffffc020669c:	00b78763          	beq	a5,a1,ffffffffc02066aa <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02066a0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02066a2:	00054783          	lbu	a5,0(a0)
ffffffffc02066a6:	fbfd                	bnez	a5,ffffffffc020669c <strchr+0xc>
    }
    return NULL;
ffffffffc02066a8:	4501                	li	a0,0
}
ffffffffc02066aa:	8082                	ret
ffffffffc02066ac:	8082                	ret

ffffffffc02066ae <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02066ae:	ca01                	beqz	a2,ffffffffc02066be <memset+0x10>
ffffffffc02066b0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02066b2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02066b4:	0785                	addi	a5,a5,1
ffffffffc02066b6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02066ba:	fec79de3          	bne	a5,a2,ffffffffc02066b4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02066be:	8082                	ret

ffffffffc02066c0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02066c0:	ca19                	beqz	a2,ffffffffc02066d6 <memcpy+0x16>
ffffffffc02066c2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02066c4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02066c6:	0585                	addi	a1,a1,1
ffffffffc02066c8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02066cc:	0785                	addi	a5,a5,1
ffffffffc02066ce:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02066d2:	fec59ae3          	bne	a1,a2,ffffffffc02066c6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02066d6:	8082                	ret
