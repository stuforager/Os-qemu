
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <edata>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	177000ef          	jal	ra,80200998 <memset>

    cons_init();  // init the console
    80200026:	148000ef          	jal	ra,8020016e <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	98658593          	addi	a1,a1,-1658 # 802009b0 <etext+0x6>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	99e50513          	addi	a0,a0,-1634 # 802009d0 <etext+0x26>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	060000ef          	jal	ra,8020009e <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13c000ef          	jal	ra,8020017e <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e6000ef          	jal	ra,8020012c <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	12e000ef          	jal	ra,80200178 <intr_enable>
    
    while (1)
        ;
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	118000ef          	jal	ra,80200170 <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200070:	f42e                	sd	a1,40(sp)
    80200072:	f832                	sd	a2,48(sp)
    80200074:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200076:	862a                	mv	a2,a0
    80200078:	004c                	addi	a1,sp,4
    8020007a:	00000517          	auipc	a0,0x0
    8020007e:	fd650513          	addi	a0,a0,-42 # 80200050 <cputch>
    80200082:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200084:	ec06                	sd	ra,24(sp)
    80200086:	e0ba                	sd	a4,64(sp)
    80200088:	e4be                	sd	a5,72(sp)
    8020008a:	e8c2                	sd	a6,80(sp)
    8020008c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020008e:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200090:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200092:	50c000ef          	jal	ra,8020059e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200096:	60e2                	ld	ra,24(sp)
    80200098:	4512                	lw	a0,4(sp)
    8020009a:	6125                	addi	sp,sp,96
    8020009c:	8082                	ret

000000008020009e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    8020009e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a0:	00001517          	auipc	a0,0x1
    802000a4:	93850513          	addi	a0,a0,-1736 # 802009d8 <etext+0x2e>
void print_kerninfo(void) {
    802000a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000aa:	fc1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ae:	00000597          	auipc	a1,0x0
    802000b2:	f5c58593          	addi	a1,a1,-164 # 8020000a <kern_init>
    802000b6:	00001517          	auipc	a0,0x1
    802000ba:	94250513          	addi	a0,a0,-1726 # 802009f8 <etext+0x4e>
    802000be:	fadff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c2:	00001597          	auipc	a1,0x1
    802000c6:	8e858593          	addi	a1,a1,-1816 # 802009aa <etext>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	94e50513          	addi	a0,a0,-1714 # 80200a18 <etext+0x6e>
    802000d2:	f99ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d6:	00004597          	auipc	a1,0x4
    802000da:	f3a58593          	addi	a1,a1,-198 # 80204010 <edata>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	95a50513          	addi	a0,a0,-1702 # 80200a38 <etext+0x8e>
    802000e6:	f85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f3e58593          	addi	a1,a1,-194 # 80204028 <end>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	96650513          	addi	a0,a0,-1690 # 80200a58 <etext+0xae>
    802000fa:	f71ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    802000fe:	00004597          	auipc	a1,0x4
    80200102:	32958593          	addi	a1,a1,809 # 80204427 <end+0x3ff>
    80200106:	00000797          	auipc	a5,0x0
    8020010a:	f0478793          	addi	a5,a5,-252 # 8020000a <kern_init>
    8020010e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200112:	43f7d593          	srai	a1,a5,0x3f
}
    80200116:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200118:	3ff5f593          	andi	a1,a1,1023
    8020011c:	95be                	add	a1,a1,a5
    8020011e:	85a9                	srai	a1,a1,0xa
    80200120:	00001517          	auipc	a0,0x1
    80200124:	95850513          	addi	a0,a0,-1704 # 80200a78 <etext+0xce>
}
    80200128:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012a:	b781                	j	8020006a <cprintf>

000000008020012c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012c:	1141                	addi	sp,sp,-16
    8020012e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200130:	02000793          	li	a5,32
    80200134:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200138:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013c:	67e1                	lui	a5,0x18
    8020013e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200142:	953e                	add	a0,a0,a5
    80200144:	7f6000ef          	jal	ra,8020093a <sbi_set_timer>
}
    80200148:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014a:	00004797          	auipc	a5,0x4
    8020014e:	ec07bb23          	sd	zero,-298(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200152:	00001517          	auipc	a0,0x1
    80200156:	95650513          	addi	a0,a0,-1706 # 80200aa8 <etext+0xfe>
}
    8020015a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015c:	b739                	j	8020006a <cprintf>

000000008020015e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020015e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200162:	67e1                	lui	a5,0x18
    80200164:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200168:	953e                	add	a0,a0,a5
    8020016a:	7d00006f          	j	8020093a <sbi_set_timer>

000000008020016e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020016e:	8082                	ret

0000000080200170 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200170:	0ff57513          	andi	a0,a0,255
    80200174:	7aa0006f          	j	8020091e <sbi_console_putchar>

0000000080200178 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200178:	100167f3          	csrrsi	a5,sstatus,2
    8020017c:	8082                	ret

000000008020017e <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020017e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200182:	00000797          	auipc	a5,0x0
    80200186:	2fa78793          	addi	a5,a5,762 # 8020047c <__alltraps>
    8020018a:	10579073          	csrw	stvec,a5
}
    8020018e:	8082                	ret

0000000080200190 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200190:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200192:	1141                	addi	sp,sp,-16
    80200194:	e022                	sd	s0,0(sp)
    80200196:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	00001517          	auipc	a0,0x1
    8020019c:	a1050513          	addi	a0,a0,-1520 # 80200ba8 <etext+0x1fe>
void print_regs(struct pushregs *gpr) {
    802001a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a2:	ec9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a6:	640c                	ld	a1,8(s0)
    802001a8:	00001517          	auipc	a0,0x1
    802001ac:	a1850513          	addi	a0,a0,-1512 # 80200bc0 <etext+0x216>
    802001b0:	ebbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b4:	680c                	ld	a1,16(s0)
    802001b6:	00001517          	auipc	a0,0x1
    802001ba:	a2250513          	addi	a0,a0,-1502 # 80200bd8 <etext+0x22e>
    802001be:	eadff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c2:	6c0c                	ld	a1,24(s0)
    802001c4:	00001517          	auipc	a0,0x1
    802001c8:	a2c50513          	addi	a0,a0,-1492 # 80200bf0 <etext+0x246>
    802001cc:	e9fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d0:	700c                	ld	a1,32(s0)
    802001d2:	00001517          	auipc	a0,0x1
    802001d6:	a3650513          	addi	a0,a0,-1482 # 80200c08 <etext+0x25e>
    802001da:	e91ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001de:	740c                	ld	a1,40(s0)
    802001e0:	00001517          	auipc	a0,0x1
    802001e4:	a4050513          	addi	a0,a0,-1472 # 80200c20 <etext+0x276>
    802001e8:	e83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ec:	780c                	ld	a1,48(s0)
    802001ee:	00001517          	auipc	a0,0x1
    802001f2:	a4a50513          	addi	a0,a0,-1462 # 80200c38 <etext+0x28e>
    802001f6:	e75ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fa:	7c0c                	ld	a1,56(s0)
    802001fc:	00001517          	auipc	a0,0x1
    80200200:	a5450513          	addi	a0,a0,-1452 # 80200c50 <etext+0x2a6>
    80200204:	e67ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200208:	602c                	ld	a1,64(s0)
    8020020a:	00001517          	auipc	a0,0x1
    8020020e:	a5e50513          	addi	a0,a0,-1442 # 80200c68 <etext+0x2be>
    80200212:	e59ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200216:	642c                	ld	a1,72(s0)
    80200218:	00001517          	auipc	a0,0x1
    8020021c:	a6850513          	addi	a0,a0,-1432 # 80200c80 <etext+0x2d6>
    80200220:	e4bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200224:	682c                	ld	a1,80(s0)
    80200226:	00001517          	auipc	a0,0x1
    8020022a:	a7250513          	addi	a0,a0,-1422 # 80200c98 <etext+0x2ee>
    8020022e:	e3dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200232:	6c2c                	ld	a1,88(s0)
    80200234:	00001517          	auipc	a0,0x1
    80200238:	a7c50513          	addi	a0,a0,-1412 # 80200cb0 <etext+0x306>
    8020023c:	e2fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200240:	702c                	ld	a1,96(s0)
    80200242:	00001517          	auipc	a0,0x1
    80200246:	a8650513          	addi	a0,a0,-1402 # 80200cc8 <etext+0x31e>
    8020024a:	e21ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024e:	742c                	ld	a1,104(s0)
    80200250:	00001517          	auipc	a0,0x1
    80200254:	a9050513          	addi	a0,a0,-1392 # 80200ce0 <etext+0x336>
    80200258:	e13ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025c:	782c                	ld	a1,112(s0)
    8020025e:	00001517          	auipc	a0,0x1
    80200262:	a9a50513          	addi	a0,a0,-1382 # 80200cf8 <etext+0x34e>
    80200266:	e05ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026a:	7c2c                	ld	a1,120(s0)
    8020026c:	00001517          	auipc	a0,0x1
    80200270:	aa450513          	addi	a0,a0,-1372 # 80200d10 <etext+0x366>
    80200274:	df7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200278:	604c                	ld	a1,128(s0)
    8020027a:	00001517          	auipc	a0,0x1
    8020027e:	aae50513          	addi	a0,a0,-1362 # 80200d28 <etext+0x37e>
    80200282:	de9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200286:	644c                	ld	a1,136(s0)
    80200288:	00001517          	auipc	a0,0x1
    8020028c:	ab850513          	addi	a0,a0,-1352 # 80200d40 <etext+0x396>
    80200290:	ddbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200294:	684c                	ld	a1,144(s0)
    80200296:	00001517          	auipc	a0,0x1
    8020029a:	ac250513          	addi	a0,a0,-1342 # 80200d58 <etext+0x3ae>
    8020029e:	dcdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a2:	6c4c                	ld	a1,152(s0)
    802002a4:	00001517          	auipc	a0,0x1
    802002a8:	acc50513          	addi	a0,a0,-1332 # 80200d70 <etext+0x3c6>
    802002ac:	dbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b0:	704c                	ld	a1,160(s0)
    802002b2:	00001517          	auipc	a0,0x1
    802002b6:	ad650513          	addi	a0,a0,-1322 # 80200d88 <etext+0x3de>
    802002ba:	db1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002be:	744c                	ld	a1,168(s0)
    802002c0:	00001517          	auipc	a0,0x1
    802002c4:	ae050513          	addi	a0,a0,-1312 # 80200da0 <etext+0x3f6>
    802002c8:	da3ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002cc:	784c                	ld	a1,176(s0)
    802002ce:	00001517          	auipc	a0,0x1
    802002d2:	aea50513          	addi	a0,a0,-1302 # 80200db8 <etext+0x40e>
    802002d6:	d95ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002da:	7c4c                	ld	a1,184(s0)
    802002dc:	00001517          	auipc	a0,0x1
    802002e0:	af450513          	addi	a0,a0,-1292 # 80200dd0 <etext+0x426>
    802002e4:	d87ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e8:	606c                	ld	a1,192(s0)
    802002ea:	00001517          	auipc	a0,0x1
    802002ee:	afe50513          	addi	a0,a0,-1282 # 80200de8 <etext+0x43e>
    802002f2:	d79ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f6:	646c                	ld	a1,200(s0)
    802002f8:	00001517          	auipc	a0,0x1
    802002fc:	b0850513          	addi	a0,a0,-1272 # 80200e00 <etext+0x456>
    80200300:	d6bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200304:	686c                	ld	a1,208(s0)
    80200306:	00001517          	auipc	a0,0x1
    8020030a:	b1250513          	addi	a0,a0,-1262 # 80200e18 <etext+0x46e>
    8020030e:	d5dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200312:	6c6c                	ld	a1,216(s0)
    80200314:	00001517          	auipc	a0,0x1
    80200318:	b1c50513          	addi	a0,a0,-1252 # 80200e30 <etext+0x486>
    8020031c:	d4fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200320:	706c                	ld	a1,224(s0)
    80200322:	00001517          	auipc	a0,0x1
    80200326:	b2650513          	addi	a0,a0,-1242 # 80200e48 <etext+0x49e>
    8020032a:	d41ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032e:	746c                	ld	a1,232(s0)
    80200330:	00001517          	auipc	a0,0x1
    80200334:	b3050513          	addi	a0,a0,-1232 # 80200e60 <etext+0x4b6>
    80200338:	d33ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033c:	786c                	ld	a1,240(s0)
    8020033e:	00001517          	auipc	a0,0x1
    80200342:	b3a50513          	addi	a0,a0,-1222 # 80200e78 <etext+0x4ce>
    80200346:	d25ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034a:	7c6c                	ld	a1,248(s0)
}
    8020034c:	6402                	ld	s0,0(sp)
    8020034e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	00001517          	auipc	a0,0x1
    80200354:	b4050513          	addi	a0,a0,-1216 # 80200e90 <etext+0x4e6>
}
    80200358:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035a:	bb01                	j	8020006a <cprintf>

000000008020035c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035c:	1141                	addi	sp,sp,-16
    8020035e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200360:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200362:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200364:	00001517          	auipc	a0,0x1
    80200368:	b4450513          	addi	a0,a0,-1212 # 80200ea8 <etext+0x4fe>
void print_trapframe(struct trapframe *tf) {
    8020036c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020036e:	cfdff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200372:	8522                	mv	a0,s0
    80200374:	e1dff0ef          	jal	ra,80200190 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200378:	10043583          	ld	a1,256(s0)
    8020037c:	00001517          	auipc	a0,0x1
    80200380:	b4450513          	addi	a0,a0,-1212 # 80200ec0 <etext+0x516>
    80200384:	ce7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200388:	10843583          	ld	a1,264(s0)
    8020038c:	00001517          	auipc	a0,0x1
    80200390:	b4c50513          	addi	a0,a0,-1204 # 80200ed8 <etext+0x52e>
    80200394:	cd7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200398:	11043583          	ld	a1,272(s0)
    8020039c:	00001517          	auipc	a0,0x1
    802003a0:	b5450513          	addi	a0,a0,-1196 # 80200ef0 <etext+0x546>
    802003a4:	cc7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a8:	11843583          	ld	a1,280(s0)
}
    802003ac:	6402                	ld	s0,0(sp)
    802003ae:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	00001517          	auipc	a0,0x1
    802003b4:	b5850513          	addi	a0,a0,-1192 # 80200f08 <etext+0x55e>
}
    802003b8:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ba:	b945                	j	8020006a <cprintf>

00000000802003bc <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003bc:	11853783          	ld	a5,280(a0)
    switch (cause) {
    802003c0:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c2:	0786                	slli	a5,a5,0x1
    802003c4:	8385                	srli	a5,a5,0x1
    switch (cause) {
    802003c6:	08f76263          	bltu	a4,a5,8020044a <interrupt_handler+0x8e>
    802003ca:	00000717          	auipc	a4,0x0
    802003ce:	6fa70713          	addi	a4,a4,1786 # 80200ac4 <etext+0x11a>
    802003d2:	078a                	slli	a5,a5,0x2
    802003d4:	97ba                	add	a5,a5,a4
    802003d6:	439c                	lw	a5,0(a5)
    802003d8:	97ba                	add	a5,a5,a4
    802003da:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003dc:	00000517          	auipc	a0,0x0
    802003e0:	77c50513          	addi	a0,a0,1916 # 80200b58 <etext+0x1ae>
    802003e4:	b159                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e6:	00000517          	auipc	a0,0x0
    802003ea:	75250513          	addi	a0,a0,1874 # 80200b38 <etext+0x18e>
    802003ee:	b9b5                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f0:	00000517          	auipc	a0,0x0
    802003f4:	70850513          	addi	a0,a0,1800 # 80200af8 <etext+0x14e>
    802003f8:	b98d                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fa:	00000517          	auipc	a0,0x0
    802003fe:	71e50513          	addi	a0,a0,1822 # 80200b18 <etext+0x16e>
    80200402:	b1a5                	j	8020006a <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200404:	00000517          	auipc	a0,0x0
    80200408:	78450513          	addi	a0,a0,1924 # 80200b88 <etext+0x1de>
    8020040c:	b9b9                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040e:	1141                	addi	sp,sp,-16
    80200410:	e022                	sd	s0,0(sp)
    80200412:	e406                	sd	ra,8(sp)
	    num++;
    80200414:	00004417          	auipc	s0,0x4
    80200418:	bfc40413          	addi	s0,s0,-1028 # 80204010 <edata>
            clock_set_next_event();
    8020041c:	d43ff0ef          	jal	ra,8020015e <clock_set_next_event>
	    num++;
    80200420:	601c                	ld	a5,0(s0)
    80200422:	0785                	addi	a5,a5,1
    80200424:	00004717          	auipc	a4,0x4
    80200428:	bef73623          	sd	a5,-1044(a4) # 80204010 <edata>
	    if(num%100==0){
    8020042c:	601c                	ld	a5,0(s0)
    8020042e:	06400713          	li	a4,100
    80200432:	02e7f7b3          	remu	a5,a5,a4
    80200436:	cb99                	beqz	a5,8020044c <interrupt_handler+0x90>
	    if(num/100>=10){
    80200438:	6018                	ld	a4,0(s0)
    8020043a:	3e700793          	li	a5,999
    8020043e:	02e7e063          	bltu	a5,a4,8020045e <interrupt_handler+0xa2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200442:	60a2                	ld	ra,8(sp)
    80200444:	6402                	ld	s0,0(sp)
    80200446:	0141                	addi	sp,sp,16
    80200448:	8082                	ret
            print_trapframe(tf);
    8020044a:	bf09                	j	8020035c <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020044c:	06400593          	li	a1,100
    80200450:	00000517          	auipc	a0,0x0
    80200454:	72850513          	addi	a0,a0,1832 # 80200b78 <etext+0x1ce>
    80200458:	c13ff0ef          	jal	ra,8020006a <cprintf>
    8020045c:	bff1                	j	80200438 <interrupt_handler+0x7c>
}
    8020045e:	6402                	ld	s0,0(sp)
    80200460:	60a2                	ld	ra,8(sp)
    80200462:	0141                	addi	sp,sp,16
	    sbi_shutdown();
    80200464:	a9cd                	j	80200956 <sbi_shutdown>

0000000080200466 <trap>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200466:	11853783          	ld	a5,280(a0)
    8020046a:	0007c763          	bltz	a5,80200478 <trap+0x12>
    switch (tf->cause) {
    8020046e:	472d                	li	a4,11
    80200470:	00f76363          	bltu	a4,a5,80200476 <trap+0x10>
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { 
	trap_dispatch(tf); 
}
    80200474:	8082                	ret
            print_trapframe(tf);
    80200476:	b5dd                	j	8020035c <print_trapframe>
        interrupt_handler(tf);
    80200478:	b791                	j	802003bc <interrupt_handler>
	...

000000008020047c <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    8020047c:	14011073          	csrw	sscratch,sp
    80200480:	712d                	addi	sp,sp,-288
    80200482:	e002                	sd	zero,0(sp)
    80200484:	e406                	sd	ra,8(sp)
    80200486:	ec0e                	sd	gp,24(sp)
    80200488:	f012                	sd	tp,32(sp)
    8020048a:	f416                	sd	t0,40(sp)
    8020048c:	f81a                	sd	t1,48(sp)
    8020048e:	fc1e                	sd	t2,56(sp)
    80200490:	e0a2                	sd	s0,64(sp)
    80200492:	e4a6                	sd	s1,72(sp)
    80200494:	e8aa                	sd	a0,80(sp)
    80200496:	ecae                	sd	a1,88(sp)
    80200498:	f0b2                	sd	a2,96(sp)
    8020049a:	f4b6                	sd	a3,104(sp)
    8020049c:	f8ba                	sd	a4,112(sp)
    8020049e:	fcbe                	sd	a5,120(sp)
    802004a0:	e142                	sd	a6,128(sp)
    802004a2:	e546                	sd	a7,136(sp)
    802004a4:	e94a                	sd	s2,144(sp)
    802004a6:	ed4e                	sd	s3,152(sp)
    802004a8:	f152                	sd	s4,160(sp)
    802004aa:	f556                	sd	s5,168(sp)
    802004ac:	f95a                	sd	s6,176(sp)
    802004ae:	fd5e                	sd	s7,184(sp)
    802004b0:	e1e2                	sd	s8,192(sp)
    802004b2:	e5e6                	sd	s9,200(sp)
    802004b4:	e9ea                	sd	s10,208(sp)
    802004b6:	edee                	sd	s11,216(sp)
    802004b8:	f1f2                	sd	t3,224(sp)
    802004ba:	f5f6                	sd	t4,232(sp)
    802004bc:	f9fa                	sd	t5,240(sp)
    802004be:	fdfe                	sd	t6,248(sp)
    802004c0:	14001473          	csrrw	s0,sscratch,zero
    802004c4:	100024f3          	csrr	s1,sstatus
    802004c8:	14102973          	csrr	s2,sepc
    802004cc:	143029f3          	csrr	s3,stval
    802004d0:	14202a73          	csrr	s4,scause
    802004d4:	e822                	sd	s0,16(sp)
    802004d6:	e226                	sd	s1,256(sp)
    802004d8:	e64a                	sd	s2,264(sp)
    802004da:	ea4e                	sd	s3,272(sp)
    802004dc:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802004de:	850a                	mv	a0,sp
    jal trap
    802004e0:	f87ff0ef          	jal	ra,80200466 <trap>

00000000802004e4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802004e4:	6492                	ld	s1,256(sp)
    802004e6:	6932                	ld	s2,264(sp)
    802004e8:	10049073          	csrw	sstatus,s1
    802004ec:	14191073          	csrw	sepc,s2
    802004f0:	60a2                	ld	ra,8(sp)
    802004f2:	61e2                	ld	gp,24(sp)
    802004f4:	7202                	ld	tp,32(sp)
    802004f6:	72a2                	ld	t0,40(sp)
    802004f8:	7342                	ld	t1,48(sp)
    802004fa:	73e2                	ld	t2,56(sp)
    802004fc:	6406                	ld	s0,64(sp)
    802004fe:	64a6                	ld	s1,72(sp)
    80200500:	6546                	ld	a0,80(sp)
    80200502:	65e6                	ld	a1,88(sp)
    80200504:	7606                	ld	a2,96(sp)
    80200506:	76a6                	ld	a3,104(sp)
    80200508:	7746                	ld	a4,112(sp)
    8020050a:	77e6                	ld	a5,120(sp)
    8020050c:	680a                	ld	a6,128(sp)
    8020050e:	68aa                	ld	a7,136(sp)
    80200510:	694a                	ld	s2,144(sp)
    80200512:	69ea                	ld	s3,152(sp)
    80200514:	7a0a                	ld	s4,160(sp)
    80200516:	7aaa                	ld	s5,168(sp)
    80200518:	7b4a                	ld	s6,176(sp)
    8020051a:	7bea                	ld	s7,184(sp)
    8020051c:	6c0e                	ld	s8,192(sp)
    8020051e:	6cae                	ld	s9,200(sp)
    80200520:	6d4e                	ld	s10,208(sp)
    80200522:	6dee                	ld	s11,216(sp)
    80200524:	7e0e                	ld	t3,224(sp)
    80200526:	7eae                	ld	t4,232(sp)
    80200528:	7f4e                	ld	t5,240(sp)
    8020052a:	7fee                	ld	t6,248(sp)
    8020052c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020052e:	10200073          	sret

0000000080200532 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200532:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200536:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200538:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020053c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020053e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200542:	f022                	sd	s0,32(sp)
    80200544:	ec26                	sd	s1,24(sp)
    80200546:	e84a                	sd	s2,16(sp)
    80200548:	f406                	sd	ra,40(sp)
    8020054a:	e44e                	sd	s3,8(sp)
    8020054c:	84aa                	mv	s1,a0
    8020054e:	892e                	mv	s2,a1
    80200550:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200554:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    80200556:	03067e63          	bgeu	a2,a6,80200592 <printnum+0x60>
    8020055a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    8020055c:	00805763          	blez	s0,8020056a <printnum+0x38>
    80200560:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200562:	85ca                	mv	a1,s2
    80200564:	854e                	mv	a0,s3
    80200566:	9482                	jalr	s1
        while (-- width > 0)
    80200568:	fc65                	bnez	s0,80200560 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020056a:	1a02                	slli	s4,s4,0x20
    8020056c:	020a5a13          	srli	s4,s4,0x20
    80200570:	00001797          	auipc	a5,0x1
    80200574:	b4078793          	addi	a5,a5,-1216 # 802010b0 <error_string+0x38>
    80200578:	9a3e                	add	s4,s4,a5
}
    8020057a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020057c:	000a4503          	lbu	a0,0(s4)
}
    80200580:	70a2                	ld	ra,40(sp)
    80200582:	69a2                	ld	s3,8(sp)
    80200584:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200586:	85ca                	mv	a1,s2
    80200588:	8326                	mv	t1,s1
}
    8020058a:	6942                	ld	s2,16(sp)
    8020058c:	64e2                	ld	s1,24(sp)
    8020058e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200590:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    80200592:	03065633          	divu	a2,a2,a6
    80200596:	8722                	mv	a4,s0
    80200598:	f9bff0ef          	jal	ra,80200532 <printnum>
    8020059c:	b7f9                	j	8020056a <printnum+0x38>

000000008020059e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020059e:	7119                	addi	sp,sp,-128
    802005a0:	f4a6                	sd	s1,104(sp)
    802005a2:	f0ca                	sd	s2,96(sp)
    802005a4:	e8d2                	sd	s4,80(sp)
    802005a6:	e4d6                	sd	s5,72(sp)
    802005a8:	e0da                	sd	s6,64(sp)
    802005aa:	fc5e                	sd	s7,56(sp)
    802005ac:	f862                	sd	s8,48(sp)
    802005ae:	f06a                	sd	s10,32(sp)
    802005b0:	fc86                	sd	ra,120(sp)
    802005b2:	f8a2                	sd	s0,112(sp)
    802005b4:	ecce                	sd	s3,88(sp)
    802005b6:	f466                	sd	s9,40(sp)
    802005b8:	ec6e                	sd	s11,24(sp)
    802005ba:	892a                	mv	s2,a0
    802005bc:	84ae                	mv	s1,a1
    802005be:	8d32                	mv	s10,a2
    802005c0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802005c2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802005c4:	00001a17          	auipc	s4,0x1
    802005c8:	958a0a13          	addi	s4,s4,-1704 # 80200f1c <etext+0x572>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802005cc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802005d0:	00001c17          	auipc	s8,0x1
    802005d4:	aa8c0c13          	addi	s8,s8,-1368 # 80201078 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005d8:	000d4503          	lbu	a0,0(s10)
    802005dc:	02500793          	li	a5,37
    802005e0:	001d0413          	addi	s0,s10,1
    802005e4:	00f50e63          	beq	a0,a5,80200600 <vprintfmt+0x62>
            if (ch == '\0') {
    802005e8:	c521                	beqz	a0,80200630 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005ea:	02500993          	li	s3,37
    802005ee:	a011                	j	802005f2 <vprintfmt+0x54>
            if (ch == '\0') {
    802005f0:	c121                	beqz	a0,80200630 <vprintfmt+0x92>
            putch(ch, putdat);
    802005f2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005f4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802005f6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005f8:	fff44503          	lbu	a0,-1(s0)
    802005fc:	ff351ae3          	bne	a0,s3,802005f0 <vprintfmt+0x52>
    80200600:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200604:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200608:	4981                	li	s3,0
    8020060a:	4801                	li	a6,0
        width = precision = -1;
    8020060c:	5cfd                	li	s9,-1
    8020060e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200610:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200614:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200616:	fdd6069b          	addiw	a3,a2,-35
    8020061a:	0ff6f693          	andi	a3,a3,255
    8020061e:	00140d13          	addi	s10,s0,1
    80200622:	1ed5ef63          	bltu	a1,a3,80200820 <vprintfmt+0x282>
    80200626:	068a                	slli	a3,a3,0x2
    80200628:	96d2                	add	a3,a3,s4
    8020062a:	4294                	lw	a3,0(a3)
    8020062c:	96d2                	add	a3,a3,s4
    8020062e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200630:	70e6                	ld	ra,120(sp)
    80200632:	7446                	ld	s0,112(sp)
    80200634:	74a6                	ld	s1,104(sp)
    80200636:	7906                	ld	s2,96(sp)
    80200638:	69e6                	ld	s3,88(sp)
    8020063a:	6a46                	ld	s4,80(sp)
    8020063c:	6aa6                	ld	s5,72(sp)
    8020063e:	6b06                	ld	s6,64(sp)
    80200640:	7be2                	ld	s7,56(sp)
    80200642:	7c42                	ld	s8,48(sp)
    80200644:	7ca2                	ld	s9,40(sp)
    80200646:	7d02                	ld	s10,32(sp)
    80200648:	6de2                	ld	s11,24(sp)
    8020064a:	6109                	addi	sp,sp,128
    8020064c:	8082                	ret
            padc = '-';
    8020064e:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
    80200650:	00144603          	lbu	a2,1(s0)
    80200654:	846a                	mv	s0,s10
    80200656:	b7c1                	j	80200616 <vprintfmt+0x78>
            precision = va_arg(ap, int);
    80200658:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    8020065c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200660:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200662:	846a                	mv	s0,s10
            if (width < 0)
    80200664:	fa0dd9e3          	bgez	s11,80200616 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200668:	8de6                	mv	s11,s9
    8020066a:	5cfd                	li	s9,-1
    8020066c:	b76d                	j	80200616 <vprintfmt+0x78>
            if (width < 0)
    8020066e:	fffdc693          	not	a3,s11
    80200672:	96fd                	srai	a3,a3,0x3f
    80200674:	00ddfdb3          	and	s11,s11,a3
    80200678:	00144603          	lbu	a2,1(s0)
    8020067c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    8020067e:	846a                	mv	s0,s10
    80200680:	bf59                	j	80200616 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200682:	4705                	li	a4,1
    80200684:	008a8593          	addi	a1,s5,8
    80200688:	01074463          	blt	a4,a6,80200690 <vprintfmt+0xf2>
    else if (lflag) {
    8020068c:	22080863          	beqz	a6,802008bc <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
    80200690:	000ab603          	ld	a2,0(s5)
    80200694:	46c1                	li	a3,16
    80200696:	8aae                	mv	s5,a1
    80200698:	a291                	j	802007dc <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
    8020069a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020069e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006a2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802006a4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802006a8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802006ac:	fad56ce3          	bltu	a0,a3,80200664 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
    802006b0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802006b2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802006b6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802006ba:	0196873b          	addw	a4,a3,s9
    802006be:	0017171b          	slliw	a4,a4,0x1
    802006c2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802006c6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802006ca:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802006ce:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802006d2:	fcd57fe3          	bgeu	a0,a3,802006b0 <vprintfmt+0x112>
    802006d6:	b779                	j	80200664 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
    802006d8:	000aa503          	lw	a0,0(s5)
    802006dc:	85a6                	mv	a1,s1
    802006de:	0aa1                	addi	s5,s5,8
    802006e0:	9902                	jalr	s2
            break;
    802006e2:	bddd                	j	802005d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802006e4:	4705                	li	a4,1
    802006e6:	008a8993          	addi	s3,s5,8
    802006ea:	01074463          	blt	a4,a6,802006f2 <vprintfmt+0x154>
    else if (lflag) {
    802006ee:	1c080463          	beqz	a6,802008b6 <vprintfmt+0x318>
        return va_arg(*ap, long);
    802006f2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    802006f6:	1c044a63          	bltz	s0,802008ca <vprintfmt+0x32c>
            num = getint(&ap, lflag);
    802006fa:	8622                	mv	a2,s0
    802006fc:	8ace                	mv	s5,s3
    802006fe:	46a9                	li	a3,10
    80200700:	a8f1                	j	802007dc <vprintfmt+0x23e>
            err = va_arg(ap, int);
    80200702:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200706:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200708:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020070a:	41f7d69b          	sraiw	a3,a5,0x1f
    8020070e:	8fb5                	xor	a5,a5,a3
    80200710:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200714:	12d74963          	blt	a4,a3,80200846 <vprintfmt+0x2a8>
    80200718:	00369793          	slli	a5,a3,0x3
    8020071c:	97e2                	add	a5,a5,s8
    8020071e:	639c                	ld	a5,0(a5)
    80200720:	12078363          	beqz	a5,80200846 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
    80200724:	86be                	mv	a3,a5
    80200726:	00001617          	auipc	a2,0x1
    8020072a:	a3a60613          	addi	a2,a2,-1478 # 80201160 <error_string+0xe8>
    8020072e:	85a6                	mv	a1,s1
    80200730:	854a                	mv	a0,s2
    80200732:	1cc000ef          	jal	ra,802008fe <printfmt>
    80200736:	b54d                	j	802005d8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200738:	000ab603          	ld	a2,0(s5)
    8020073c:	0aa1                	addi	s5,s5,8
    8020073e:	1a060163          	beqz	a2,802008e0 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
    80200742:	00160413          	addi	s0,a2,1
    80200746:	15b05763          	blez	s11,80200894 <vprintfmt+0x2f6>
    8020074a:	02d00593          	li	a1,45
    8020074e:	10b79d63          	bne	a5,a1,80200868 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200752:	00064783          	lbu	a5,0(a2)
    80200756:	0007851b          	sext.w	a0,a5
    8020075a:	c905                	beqz	a0,8020078a <vprintfmt+0x1ec>
    8020075c:	000cc563          	bltz	s9,80200766 <vprintfmt+0x1c8>
    80200760:	3cfd                	addiw	s9,s9,-1
    80200762:	036c8263          	beq	s9,s6,80200786 <vprintfmt+0x1e8>
                    putch('?', putdat);
    80200766:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200768:	14098f63          	beqz	s3,802008c6 <vprintfmt+0x328>
    8020076c:	3781                	addiw	a5,a5,-32
    8020076e:	14fbfc63          	bgeu	s7,a5,802008c6 <vprintfmt+0x328>
                    putch('?', putdat);
    80200772:	03f00513          	li	a0,63
    80200776:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200778:	0405                	addi	s0,s0,1
    8020077a:	fff44783          	lbu	a5,-1(s0)
    8020077e:	3dfd                	addiw	s11,s11,-1
    80200780:	0007851b          	sext.w	a0,a5
    80200784:	fd61                	bnez	a0,8020075c <vprintfmt+0x1be>
            for (; width > 0; width --) {
    80200786:	e5b059e3          	blez	s11,802005d8 <vprintfmt+0x3a>
    8020078a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020078c:	85a6                	mv	a1,s1
    8020078e:	02000513          	li	a0,32
    80200792:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200794:	e40d82e3          	beqz	s11,802005d8 <vprintfmt+0x3a>
    80200798:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020079a:	85a6                	mv	a1,s1
    8020079c:	02000513          	li	a0,32
    802007a0:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007a2:	fe0d94e3          	bnez	s11,8020078a <vprintfmt+0x1ec>
    802007a6:	bd0d                	j	802005d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007a8:	4705                	li	a4,1
    802007aa:	008a8593          	addi	a1,s5,8
    802007ae:	01074463          	blt	a4,a6,802007b6 <vprintfmt+0x218>
    else if (lflag) {
    802007b2:	0e080863          	beqz	a6,802008a2 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
    802007b6:	000ab603          	ld	a2,0(s5)
    802007ba:	46a1                	li	a3,8
    802007bc:	8aae                	mv	s5,a1
    802007be:	a839                	j	802007dc <vprintfmt+0x23e>
            putch('0', putdat);
    802007c0:	03000513          	li	a0,48
    802007c4:	85a6                	mv	a1,s1
    802007c6:	e03e                	sd	a5,0(sp)
    802007c8:	9902                	jalr	s2
            putch('x', putdat);
    802007ca:	85a6                	mv	a1,s1
    802007cc:	07800513          	li	a0,120
    802007d0:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007d2:	0aa1                	addi	s5,s5,8
    802007d4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007d8:	6782                	ld	a5,0(sp)
    802007da:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007dc:	2781                	sext.w	a5,a5
    802007de:	876e                	mv	a4,s11
    802007e0:	85a6                	mv	a1,s1
    802007e2:	854a                	mv	a0,s2
    802007e4:	d4fff0ef          	jal	ra,80200532 <printnum>
            break;
    802007e8:	bbc5                	j	802005d8 <vprintfmt+0x3a>
            lflag ++;
    802007ea:	00144603          	lbu	a2,1(s0)
    802007ee:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007f0:	846a                	mv	s0,s10
            goto reswitch;
    802007f2:	b515                	j	80200616 <vprintfmt+0x78>
            goto reswitch;
    802007f4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802007f8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007fa:	846a                	mv	s0,s10
            goto reswitch;
    802007fc:	bd29                	j	80200616 <vprintfmt+0x78>
            putch(ch, putdat);
    802007fe:	85a6                	mv	a1,s1
    80200800:	02500513          	li	a0,37
    80200804:	9902                	jalr	s2
            break;
    80200806:	bbc9                	j	802005d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200808:	4705                	li	a4,1
    8020080a:	008a8593          	addi	a1,s5,8
    8020080e:	01074463          	blt	a4,a6,80200816 <vprintfmt+0x278>
    else if (lflag) {
    80200812:	08080d63          	beqz	a6,802008ac <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
    80200816:	000ab603          	ld	a2,0(s5)
    8020081a:	46a9                	li	a3,10
    8020081c:	8aae                	mv	s5,a1
    8020081e:	bf7d                	j	802007dc <vprintfmt+0x23e>
            putch('%', putdat);
    80200820:	85a6                	mv	a1,s1
    80200822:	02500513          	li	a0,37
    80200826:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200828:	fff44703          	lbu	a4,-1(s0)
    8020082c:	02500793          	li	a5,37
    80200830:	8d22                	mv	s10,s0
    80200832:	daf703e3          	beq	a4,a5,802005d8 <vprintfmt+0x3a>
    80200836:	02500713          	li	a4,37
    8020083a:	1d7d                	addi	s10,s10,-1
    8020083c:	fffd4783          	lbu	a5,-1(s10)
    80200840:	fee79de3          	bne	a5,a4,8020083a <vprintfmt+0x29c>
    80200844:	bb51                	j	802005d8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200846:	00001617          	auipc	a2,0x1
    8020084a:	90a60613          	addi	a2,a2,-1782 # 80201150 <error_string+0xd8>
    8020084e:	85a6                	mv	a1,s1
    80200850:	854a                	mv	a0,s2
    80200852:	0ac000ef          	jal	ra,802008fe <printfmt>
    80200856:	b349                	j	802005d8 <vprintfmt+0x3a>
                p = "(null)";
    80200858:	00001617          	auipc	a2,0x1
    8020085c:	8f060613          	addi	a2,a2,-1808 # 80201148 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200860:	00001417          	auipc	s0,0x1
    80200864:	8e940413          	addi	s0,s0,-1815 # 80201149 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200868:	8532                	mv	a0,a2
    8020086a:	85e6                	mv	a1,s9
    8020086c:	e032                	sd	a2,0(sp)
    8020086e:	e43e                	sd	a5,8(sp)
    80200870:	102000ef          	jal	ra,80200972 <strnlen>
    80200874:	40ad8dbb          	subw	s11,s11,a0
    80200878:	6602                	ld	a2,0(sp)
    8020087a:	01b05d63          	blez	s11,80200894 <vprintfmt+0x2f6>
    8020087e:	67a2                	ld	a5,8(sp)
    80200880:	2781                	sext.w	a5,a5
    80200882:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200884:	6522                	ld	a0,8(sp)
    80200886:	85a6                	mv	a1,s1
    80200888:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020088a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020088c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020088e:	6602                	ld	a2,0(sp)
    80200890:	fe0d9ae3          	bnez	s11,80200884 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200894:	00064783          	lbu	a5,0(a2)
    80200898:	0007851b          	sext.w	a0,a5
    8020089c:	ec0510e3          	bnez	a0,8020075c <vprintfmt+0x1be>
    802008a0:	bb25                	j	802005d8 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
    802008a2:	000ae603          	lwu	a2,0(s5)
    802008a6:	46a1                	li	a3,8
    802008a8:	8aae                	mv	s5,a1
    802008aa:	bf0d                	j	802007dc <vprintfmt+0x23e>
    802008ac:	000ae603          	lwu	a2,0(s5)
    802008b0:	46a9                	li	a3,10
    802008b2:	8aae                	mv	s5,a1
    802008b4:	b725                	j	802007dc <vprintfmt+0x23e>
        return va_arg(*ap, int);
    802008b6:	000aa403          	lw	s0,0(s5)
    802008ba:	bd35                	j	802006f6 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
    802008bc:	000ae603          	lwu	a2,0(s5)
    802008c0:	46c1                	li	a3,16
    802008c2:	8aae                	mv	s5,a1
    802008c4:	bf21                	j	802007dc <vprintfmt+0x23e>
                    putch(ch, putdat);
    802008c6:	9902                	jalr	s2
    802008c8:	bd45                	j	80200778 <vprintfmt+0x1da>
                putch('-', putdat);
    802008ca:	85a6                	mv	a1,s1
    802008cc:	02d00513          	li	a0,45
    802008d0:	e03e                	sd	a5,0(sp)
    802008d2:	9902                	jalr	s2
                num = -(long long)num;
    802008d4:	8ace                	mv	s5,s3
    802008d6:	40800633          	neg	a2,s0
    802008da:	46a9                	li	a3,10
    802008dc:	6782                	ld	a5,0(sp)
    802008de:	bdfd                	j	802007dc <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
    802008e0:	01b05663          	blez	s11,802008ec <vprintfmt+0x34e>
    802008e4:	02d00693          	li	a3,45
    802008e8:	f6d798e3          	bne	a5,a3,80200858 <vprintfmt+0x2ba>
    802008ec:	00001417          	auipc	s0,0x1
    802008f0:	85d40413          	addi	s0,s0,-1955 # 80201149 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008f4:	02800513          	li	a0,40
    802008f8:	02800793          	li	a5,40
    802008fc:	b585                	j	8020075c <vprintfmt+0x1be>

00000000802008fe <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802008fe:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200900:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200904:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200906:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200908:	ec06                	sd	ra,24(sp)
    8020090a:	f83a                	sd	a4,48(sp)
    8020090c:	fc3e                	sd	a5,56(sp)
    8020090e:	e0c2                	sd	a6,64(sp)
    80200910:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200912:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200914:	c8bff0ef          	jal	ra,8020059e <vprintfmt>
}
    80200918:	60e2                	ld	ra,24(sp)
    8020091a:	6161                	addi	sp,sp,80
    8020091c:	8082                	ret

000000008020091e <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    8020091e:	00003797          	auipc	a5,0x3
    80200922:	6e278793          	addi	a5,a5,1762 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200926:	6398                	ld	a4,0(a5)
    80200928:	4781                	li	a5,0
    8020092a:	88ba                	mv	a7,a4
    8020092c:	852a                	mv	a0,a0
    8020092e:	85be                	mv	a1,a5
    80200930:	863e                	mv	a2,a5
    80200932:	00000073          	ecall
    80200936:	87aa                	mv	a5,a0
}
    80200938:	8082                	ret

000000008020093a <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    8020093a:	00003797          	auipc	a5,0x3
    8020093e:	6de78793          	addi	a5,a5,1758 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200942:	6398                	ld	a4,0(a5)
    80200944:	4781                	li	a5,0
    80200946:	88ba                	mv	a7,a4
    80200948:	852a                	mv	a0,a0
    8020094a:	85be                	mv	a1,a5
    8020094c:	863e                	mv	a2,a5
    8020094e:	00000073          	ecall
    80200952:	87aa                	mv	a5,a0
}
    80200954:	8082                	ret

0000000080200956 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200956:	00003797          	auipc	a5,0x3
    8020095a:	6b278793          	addi	a5,a5,1714 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    8020095e:	6398                	ld	a4,0(a5)
    80200960:	4781                	li	a5,0
    80200962:	88ba                	mv	a7,a4
    80200964:	853e                	mv	a0,a5
    80200966:	85be                	mv	a1,a5
    80200968:	863e                	mv	a2,a5
    8020096a:	00000073          	ecall
    8020096e:	87aa                	mv	a5,a0
    80200970:	8082                	ret

0000000080200972 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200972:	c185                	beqz	a1,80200992 <strnlen+0x20>
    80200974:	00054783          	lbu	a5,0(a0)
    80200978:	cf89                	beqz	a5,80200992 <strnlen+0x20>
    size_t cnt = 0;
    8020097a:	4781                	li	a5,0
    8020097c:	a021                	j	80200984 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    8020097e:	00074703          	lbu	a4,0(a4)
    80200982:	c711                	beqz	a4,8020098e <strnlen+0x1c>
        cnt ++;
    80200984:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200986:	00f50733          	add	a4,a0,a5
    8020098a:	fef59ae3          	bne	a1,a5,8020097e <strnlen+0xc>
    }
    return cnt;
}
    8020098e:	853e                	mv	a0,a5
    80200990:	8082                	ret
    size_t cnt = 0;
    80200992:	4781                	li	a5,0
}
    80200994:	853e                	mv	a0,a5
    80200996:	8082                	ret

0000000080200998 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200998:	ca01                	beqz	a2,802009a8 <memset+0x10>
    8020099a:	962a                	add	a2,a2,a0
    char *p = s;
    8020099c:	87aa                	mv	a5,a0
        *p ++ = c;
    8020099e:	0785                	addi	a5,a5,1
    802009a0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802009a4:	fec79de3          	bne	a5,a2,8020099e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802009a8:	8082                	ret
