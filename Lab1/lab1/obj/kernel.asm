
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
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	00c60613          	addi	a2,a2,12 # 80204020 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	5f0000ef          	jal	ra,80200614 <memset>

    cons_init();  // init the console
    80200028:	150000ef          	jal	ra,80200178 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a4c58593          	addi	a1,a1,-1460 # 80200a78 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a6450513          	addi	a0,a0,-1436 # 80200a98 <etext+0x26>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>
    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	144000ef          	jal	ra,80200188 <idt_init>


    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	136000ef          	jal	ra,80200182 <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	120000ef          	jal	ra,8020017a <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end+0x8>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	5fe000ef          	jal	ra,80200692 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9fe50513          	addi	a0,a0,-1538 # 80200aa0 <etext+0x2e>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	a0850513          	addi	a0,a0,-1528 # 80200ac0 <etext+0x4e>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	9ae58593          	addi	a1,a1,-1618 # 80200a72 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	a1450513          	addi	a0,a0,-1516 # 80200ae0 <etext+0x6e>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	a2050513          	addi	a0,a0,-1504 # 80200b00 <etext+0x8e>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3458593          	addi	a1,a1,-204 # 80204020 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	a2c50513          	addi	a0,a0,-1492 # 80200b20 <etext+0xae>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	31f58593          	addi	a1,a1,799 # 8020441f <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	a1e50513          	addi	a0,a0,-1506 # 80200b40 <etext+0xce>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013c:	c0102573          	rdtime	a0
    cprintf("++ setup timer interrupts\n");
    //__asm__ volatile("mret");
    __asm__ volatile("ebreak");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	0f3000ef          	jal	ra,80200a3a <sbi_set_timer>
    cprintf("++ setup timer interrupts\n");
    8020014c:	00001517          	auipc	a0,0x1
    80200150:	a2450513          	addi	a0,a0,-1500 # 80200b70 <etext+0xfe>
    ticks = 0;
    80200154:	00004797          	auipc	a5,0x4
    80200158:	ec07b223          	sd	zero,-316(a5) # 80204018 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015c:	f11ff0ef          	jal	ra,8020006c <cprintf>
    __asm__ volatile("ebreak");
    80200160:	9002                	ebreak
}
    80200162:	60a2                	ld	ra,8(sp)
    80200164:	0141                	addi	sp,sp,16
    80200166:	8082                	ret

0000000080200168 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200168:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016c:	67e1                	lui	a5,0x18
    8020016e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200172:	953e                	add	a0,a0,a5
    80200174:	0c70006f          	j	80200a3a <sbi_set_timer>

0000000080200178 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200178:	8082                	ret

000000008020017a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017a:	0ff57513          	andi	a0,a0,255
    8020017e:	0a10006f          	j	80200a1e <sbi_console_putchar>

0000000080200182 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200182:	100167f3          	csrrsi	a5,sstatus,2
    80200186:	8082                	ret

0000000080200188 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200188:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018c:	00000797          	auipc	a5,0x0
    80200190:	3ac78793          	addi	a5,a5,940 # 80200538 <__alltraps>
    80200194:	10579073          	csrw	stvec,a5
}
    80200198:	8082                	ret

000000008020019a <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019c:	1141                	addi	sp,sp,-16
    8020019e:	e022                	sd	s0,0(sp)
    802001a0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a2:	00001517          	auipc	a0,0x1
    802001a6:	b7e50513          	addi	a0,a0,-1154 # 80200d20 <etext+0x2ae>
void print_regs(struct pushregs *gpr) {
    802001aa:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ac:	ec1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b0:	640c                	ld	a1,8(s0)
    802001b2:	00001517          	auipc	a0,0x1
    802001b6:	b8650513          	addi	a0,a0,-1146 # 80200d38 <etext+0x2c6>
    802001ba:	eb3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001be:	680c                	ld	a1,16(s0)
    802001c0:	00001517          	auipc	a0,0x1
    802001c4:	b9050513          	addi	a0,a0,-1136 # 80200d50 <etext+0x2de>
    802001c8:	ea5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001cc:	6c0c                	ld	a1,24(s0)
    802001ce:	00001517          	auipc	a0,0x1
    802001d2:	b9a50513          	addi	a0,a0,-1126 # 80200d68 <etext+0x2f6>
    802001d6:	e97ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001da:	700c                	ld	a1,32(s0)
    802001dc:	00001517          	auipc	a0,0x1
    802001e0:	ba450513          	addi	a0,a0,-1116 # 80200d80 <etext+0x30e>
    802001e4:	e89ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e8:	740c                	ld	a1,40(s0)
    802001ea:	00001517          	auipc	a0,0x1
    802001ee:	bae50513          	addi	a0,a0,-1106 # 80200d98 <etext+0x326>
    802001f2:	e7bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f6:	780c                	ld	a1,48(s0)
    802001f8:	00001517          	auipc	a0,0x1
    802001fc:	bb850513          	addi	a0,a0,-1096 # 80200db0 <etext+0x33e>
    80200200:	e6dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200204:	7c0c                	ld	a1,56(s0)
    80200206:	00001517          	auipc	a0,0x1
    8020020a:	bc250513          	addi	a0,a0,-1086 # 80200dc8 <etext+0x356>
    8020020e:	e5fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200212:	602c                	ld	a1,64(s0)
    80200214:	00001517          	auipc	a0,0x1
    80200218:	bcc50513          	addi	a0,a0,-1076 # 80200de0 <etext+0x36e>
    8020021c:	e51ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200220:	642c                	ld	a1,72(s0)
    80200222:	00001517          	auipc	a0,0x1
    80200226:	bd650513          	addi	a0,a0,-1066 # 80200df8 <etext+0x386>
    8020022a:	e43ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022e:	682c                	ld	a1,80(s0)
    80200230:	00001517          	auipc	a0,0x1
    80200234:	be050513          	addi	a0,a0,-1056 # 80200e10 <etext+0x39e>
    80200238:	e35ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023c:	6c2c                	ld	a1,88(s0)
    8020023e:	00001517          	auipc	a0,0x1
    80200242:	bea50513          	addi	a0,a0,-1046 # 80200e28 <etext+0x3b6>
    80200246:	e27ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024a:	702c                	ld	a1,96(s0)
    8020024c:	00001517          	auipc	a0,0x1
    80200250:	bf450513          	addi	a0,a0,-1036 # 80200e40 <etext+0x3ce>
    80200254:	e19ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200258:	742c                	ld	a1,104(s0)
    8020025a:	00001517          	auipc	a0,0x1
    8020025e:	bfe50513          	addi	a0,a0,-1026 # 80200e58 <etext+0x3e6>
    80200262:	e0bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200266:	782c                	ld	a1,112(s0)
    80200268:	00001517          	auipc	a0,0x1
    8020026c:	c0850513          	addi	a0,a0,-1016 # 80200e70 <etext+0x3fe>
    80200270:	dfdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200274:	7c2c                	ld	a1,120(s0)
    80200276:	00001517          	auipc	a0,0x1
    8020027a:	c1250513          	addi	a0,a0,-1006 # 80200e88 <etext+0x416>
    8020027e:	defff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200282:	604c                	ld	a1,128(s0)
    80200284:	00001517          	auipc	a0,0x1
    80200288:	c1c50513          	addi	a0,a0,-996 # 80200ea0 <etext+0x42e>
    8020028c:	de1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200290:	644c                	ld	a1,136(s0)
    80200292:	00001517          	auipc	a0,0x1
    80200296:	c2650513          	addi	a0,a0,-986 # 80200eb8 <etext+0x446>
    8020029a:	dd3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029e:	684c                	ld	a1,144(s0)
    802002a0:	00001517          	auipc	a0,0x1
    802002a4:	c3050513          	addi	a0,a0,-976 # 80200ed0 <etext+0x45e>
    802002a8:	dc5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ac:	6c4c                	ld	a1,152(s0)
    802002ae:	00001517          	auipc	a0,0x1
    802002b2:	c3a50513          	addi	a0,a0,-966 # 80200ee8 <etext+0x476>
    802002b6:	db7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002ba:	704c                	ld	a1,160(s0)
    802002bc:	00001517          	auipc	a0,0x1
    802002c0:	c4450513          	addi	a0,a0,-956 # 80200f00 <etext+0x48e>
    802002c4:	da9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c8:	744c                	ld	a1,168(s0)
    802002ca:	00001517          	auipc	a0,0x1
    802002ce:	c4e50513          	addi	a0,a0,-946 # 80200f18 <etext+0x4a6>
    802002d2:	d9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d6:	784c                	ld	a1,176(s0)
    802002d8:	00001517          	auipc	a0,0x1
    802002dc:	c5850513          	addi	a0,a0,-936 # 80200f30 <etext+0x4be>
    802002e0:	d8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e4:	7c4c                	ld	a1,184(s0)
    802002e6:	00001517          	auipc	a0,0x1
    802002ea:	c6250513          	addi	a0,a0,-926 # 80200f48 <etext+0x4d6>
    802002ee:	d7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f2:	606c                	ld	a1,192(s0)
    802002f4:	00001517          	auipc	a0,0x1
    802002f8:	c6c50513          	addi	a0,a0,-916 # 80200f60 <etext+0x4ee>
    802002fc:	d71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200300:	646c                	ld	a1,200(s0)
    80200302:	00001517          	auipc	a0,0x1
    80200306:	c7650513          	addi	a0,a0,-906 # 80200f78 <etext+0x506>
    8020030a:	d63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030e:	686c                	ld	a1,208(s0)
    80200310:	00001517          	auipc	a0,0x1
    80200314:	c8050513          	addi	a0,a0,-896 # 80200f90 <etext+0x51e>
    80200318:	d55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031c:	6c6c                	ld	a1,216(s0)
    8020031e:	00001517          	auipc	a0,0x1
    80200322:	c8a50513          	addi	a0,a0,-886 # 80200fa8 <etext+0x536>
    80200326:	d47ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032a:	706c                	ld	a1,224(s0)
    8020032c:	00001517          	auipc	a0,0x1
    80200330:	c9450513          	addi	a0,a0,-876 # 80200fc0 <etext+0x54e>
    80200334:	d39ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200338:	746c                	ld	a1,232(s0)
    8020033a:	00001517          	auipc	a0,0x1
    8020033e:	c9e50513          	addi	a0,a0,-866 # 80200fd8 <etext+0x566>
    80200342:	d2bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200346:	786c                	ld	a1,240(s0)
    80200348:	00001517          	auipc	a0,0x1
    8020034c:	ca850513          	addi	a0,a0,-856 # 80200ff0 <etext+0x57e>
    80200350:	d1dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200354:	7c6c                	ld	a1,248(s0)
}
    80200356:	6402                	ld	s0,0(sp)
    80200358:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035a:	00001517          	auipc	a0,0x1
    8020035e:	cae50513          	addi	a0,a0,-850 # 80201008 <etext+0x596>
}
    80200362:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200364:	d09ff06f          	j	8020006c <cprintf>

0000000080200368 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200368:	1141                	addi	sp,sp,-16
    8020036a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200370:	00001517          	auipc	a0,0x1
    80200374:	cb050513          	addi	a0,a0,-848 # 80201020 <etext+0x5ae>
void print_trapframe(struct trapframe *tf) {
    80200378:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037a:	cf3ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020037e:	8522                	mv	a0,s0
    80200380:	e1bff0ef          	jal	ra,8020019a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200384:	10043583          	ld	a1,256(s0)
    80200388:	00001517          	auipc	a0,0x1
    8020038c:	cb050513          	addi	a0,a0,-848 # 80201038 <etext+0x5c6>
    80200390:	cddff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200394:	10843583          	ld	a1,264(s0)
    80200398:	00001517          	auipc	a0,0x1
    8020039c:	cb850513          	addi	a0,a0,-840 # 80201050 <etext+0x5de>
    802003a0:	ccdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a4:	11043583          	ld	a1,272(s0)
    802003a8:	00001517          	auipc	a0,0x1
    802003ac:	cc050513          	addi	a0,a0,-832 # 80201068 <etext+0x5f6>
    802003b0:	cbdff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b4:	11843583          	ld	a1,280(s0)
}
    802003b8:	6402                	ld	s0,0(sp)
    802003ba:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	00001517          	auipc	a0,0x1
    802003c0:	cc450513          	addi	a0,a0,-828 # 80201080 <etext+0x60e>
}
    802003c4:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c6:	ca7ff06f          	j	8020006c <cprintf>

00000000802003ca <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003ca:	11853783          	ld	a5,280(a0)
    802003ce:	577d                	li	a4,-1
    802003d0:	8305                	srli	a4,a4,0x1
    802003d2:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d4:	472d                	li	a4,11
    802003d6:	0af76163          	bltu	a4,a5,80200478 <interrupt_handler+0xae>
    802003da:	00000717          	auipc	a4,0x0
    802003de:	7b270713          	addi	a4,a4,1970 # 80200b8c <etext+0x11a>
    802003e2:	078a                	slli	a5,a5,0x2
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	439c                	lw	a5,0(a5)
    802003e8:	97ba                	add	a5,a5,a4
    802003ea:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ec:	00001517          	auipc	a0,0x1
    802003f0:	8bc50513          	addi	a0,a0,-1860 # 80200ca8 <etext+0x236>
    802003f4:	c79ff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	89050513          	addi	a0,a0,-1904 # 80200c88 <etext+0x216>
    80200400:	c6dff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    80200404:	00001517          	auipc	a0,0x1
    80200408:	84450513          	addi	a0,a0,-1980 # 80200c48 <etext+0x1d6>
    8020040c:	c61ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200410:	00001517          	auipc	a0,0x1
    80200414:	85850513          	addi	a0,a0,-1960 # 80200c68 <etext+0x1f6>
    80200418:	c55ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020041c:	00001517          	auipc	a0,0x1
    80200420:	8e450513          	addi	a0,a0,-1820 # 80200d00 <etext+0x28e>
    80200424:	c49ff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200428:	1141                	addi	sp,sp,-16
    8020042a:	e022                	sd	s0,0(sp)
    8020042c:	e406                	sd	ra,8(sp)
            ticks++;
    8020042e:	00004417          	auipc	s0,0x4
    80200432:	bea40413          	addi	s0,s0,-1046 # 80204018 <ticks>
            clock_set_next_event();
    80200436:	d33ff0ef          	jal	ra,80200168 <clock_set_next_event>
            ticks++;
    8020043a:	601c                	ld	a5,0(s0)
    8020043c:	0785                	addi	a5,a5,1
    8020043e:	00004717          	auipc	a4,0x4
    80200442:	bcf73d23          	sd	a5,-1062(a4) # 80204018 <ticks>
            if(ticks%100==0&&ticks>0) print_ticks();
    80200446:	601c                	ld	a5,0(s0)
    80200448:	06400713          	li	a4,100
    8020044c:	02e7f7b3          	remu	a5,a5,a4
    80200450:	eb99                	bnez	a5,80200466 <interrupt_handler+0x9c>
    80200452:	601c                	ld	a5,0(s0)
    80200454:	cb89                	beqz	a5,80200466 <interrupt_handler+0x9c>
    cprintf("%d ticks\n", TICK_NUM);
    80200456:	06400593          	li	a1,100
    8020045a:	00001517          	auipc	a0,0x1
    8020045e:	86e50513          	addi	a0,a0,-1938 # 80200cc8 <etext+0x256>
    80200462:	c0bff0ef          	jal	ra,8020006c <cprintf>
                if(ticks==1000) {cprintf("The counters = 10,system will shutdown!");sbi_shutdown();}
    80200466:	6018                	ld	a4,0(s0)
    80200468:	3e800793          	li	a5,1000
    8020046c:	00f70863          	beq	a4,a5,8020047c <interrupt_handler+0xb2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200470:	60a2                	ld	ra,8(sp)
    80200472:	6402                	ld	s0,0(sp)
    80200474:	0141                	addi	sp,sp,16
    80200476:	8082                	ret
            print_trapframe(tf);
    80200478:	ef1ff06f          	j	80200368 <print_trapframe>
                if(ticks==1000) {cprintf("The counters = 10,system will shutdown!");sbi_shutdown();}
    8020047c:	00001517          	auipc	a0,0x1
    80200480:	85c50513          	addi	a0,a0,-1956 # 80200cd8 <etext+0x266>
    80200484:	be9ff0ef          	jal	ra,8020006c <cprintf>
}
    80200488:	6402                	ld	s0,0(sp)
    8020048a:	60a2                	ld	ra,8(sp)
    8020048c:	0141                	addi	sp,sp,16
                if(ticks==1000) {cprintf("The counters = 10,system will shutdown!");sbi_shutdown();}
    8020048e:	5c80006f          	j	80200a56 <sbi_shutdown>

0000000080200492 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200492:	11853783          	ld	a5,280(a0)
    80200496:	472d                	li	a4,11
    80200498:	02f76863          	bltu	a4,a5,802004c8 <exception_handler+0x36>
    8020049c:	4705                	li	a4,1
    8020049e:	00f71733          	sll	a4,a4,a5
    802004a2:	6785                	lui	a5,0x1
    802004a4:	17cd                	addi	a5,a5,-13
    802004a6:	8ff9                	and	a5,a5,a4
    802004a8:	ef99                	bnez	a5,802004c6 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004aa:	1141                	addi	sp,sp,-16
    802004ac:	e022                	sd	s0,0(sp)
    802004ae:	e406                	sd	ra,8(sp)
    802004b0:	00877793          	andi	a5,a4,8
    802004b4:	842a                	mv	s0,a0
    802004b6:	e3b1                	bnez	a5,802004fa <exception_handler+0x68>
    802004b8:	8b11                	andi	a4,a4,4
    802004ba:	eb09                	bnez	a4,802004cc <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004bc:	6402                	ld	s0,0(sp)
    802004be:	60a2                	ld	ra,8(sp)
    802004c0:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004c2:	ea7ff06f          	j	80200368 <print_trapframe>
    802004c6:	8082                	ret
    802004c8:	ea1ff06f          	j	80200368 <print_trapframe>
            cprintf("Illegal instruction\n");
    802004cc:	00000517          	auipc	a0,0x0
    802004d0:	6f450513          	addi	a0,a0,1780 # 80200bc0 <etext+0x14e>
    802004d4:	b99ff0ef          	jal	ra,8020006c <cprintf>
            cprintf("Illegal instruction caught at 0x: 0x%08x\n", tf->epc);
    802004d8:	10843583          	ld	a1,264(s0)
    802004dc:	00000517          	auipc	a0,0x0
    802004e0:	6fc50513          	addi	a0,a0,1788 # 80200bd8 <etext+0x166>
    802004e4:	b89ff0ef          	jal	ra,8020006c <cprintf>
            tf->epc+=4;
    802004e8:	10843783          	ld	a5,264(s0)
}
    802004ec:	60a2                	ld	ra,8(sp)
            tf->epc+=4;
    802004ee:	0791                	addi	a5,a5,4
    802004f0:	10f43423          	sd	a5,264(s0)
}
    802004f4:	6402                	ld	s0,0(sp)
    802004f6:	0141                	addi	sp,sp,16
    802004f8:	8082                	ret
            cprintf("Exception type: breakpoint\n");
    802004fa:	00000517          	auipc	a0,0x0
    802004fe:	70e50513          	addi	a0,a0,1806 # 80200c08 <etext+0x196>
    80200502:	b6bff0ef          	jal	ra,8020006c <cprintf>
            cprintf("ebreak caught at 0x: 0x%08x\n", tf->epc);
    80200506:	10843583          	ld	a1,264(s0)
    8020050a:	00000517          	auipc	a0,0x0
    8020050e:	71e50513          	addi	a0,a0,1822 # 80200c28 <etext+0x1b6>
    80200512:	b5bff0ef          	jal	ra,8020006c <cprintf>
            tf->epc+=4;             
    80200516:	10843783          	ld	a5,264(s0)
}
    8020051a:	60a2                	ld	ra,8(sp)
            tf->epc+=4;             
    8020051c:	0791                	addi	a5,a5,4
    8020051e:	10f43423          	sd	a5,264(s0)
}
    80200522:	6402                	ld	s0,0(sp)
    80200524:	0141                	addi	sp,sp,16
    80200526:	8082                	ret

0000000080200528 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200528:	11853783          	ld	a5,280(a0)
    8020052c:	0007c463          	bltz	a5,80200534 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200530:	f63ff06f          	j	80200492 <exception_handler>
        interrupt_handler(tf);
    80200534:	e97ff06f          	j	802003ca <interrupt_handler>

0000000080200538 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200538:	14011073          	csrw	sscratch,sp
    8020053c:	712d                	addi	sp,sp,-288
    8020053e:	e002                	sd	zero,0(sp)
    80200540:	e406                	sd	ra,8(sp)
    80200542:	ec0e                	sd	gp,24(sp)
    80200544:	f012                	sd	tp,32(sp)
    80200546:	f416                	sd	t0,40(sp)
    80200548:	f81a                	sd	t1,48(sp)
    8020054a:	fc1e                	sd	t2,56(sp)
    8020054c:	e0a2                	sd	s0,64(sp)
    8020054e:	e4a6                	sd	s1,72(sp)
    80200550:	e8aa                	sd	a0,80(sp)
    80200552:	ecae                	sd	a1,88(sp)
    80200554:	f0b2                	sd	a2,96(sp)
    80200556:	f4b6                	sd	a3,104(sp)
    80200558:	f8ba                	sd	a4,112(sp)
    8020055a:	fcbe                	sd	a5,120(sp)
    8020055c:	e142                	sd	a6,128(sp)
    8020055e:	e546                	sd	a7,136(sp)
    80200560:	e94a                	sd	s2,144(sp)
    80200562:	ed4e                	sd	s3,152(sp)
    80200564:	f152                	sd	s4,160(sp)
    80200566:	f556                	sd	s5,168(sp)
    80200568:	f95a                	sd	s6,176(sp)
    8020056a:	fd5e                	sd	s7,184(sp)
    8020056c:	e1e2                	sd	s8,192(sp)
    8020056e:	e5e6                	sd	s9,200(sp)
    80200570:	e9ea                	sd	s10,208(sp)
    80200572:	edee                	sd	s11,216(sp)
    80200574:	f1f2                	sd	t3,224(sp)
    80200576:	f5f6                	sd	t4,232(sp)
    80200578:	f9fa                	sd	t5,240(sp)
    8020057a:	fdfe                	sd	t6,248(sp)
    8020057c:	14001473          	csrrw	s0,sscratch,zero
    80200580:	100024f3          	csrr	s1,sstatus
    80200584:	14102973          	csrr	s2,sepc
    80200588:	143029f3          	csrr	s3,stval
    8020058c:	14202a73          	csrr	s4,scause
    80200590:	e822                	sd	s0,16(sp)
    80200592:	e226                	sd	s1,256(sp)
    80200594:	e64a                	sd	s2,264(sp)
    80200596:	ea4e                	sd	s3,272(sp)
    80200598:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020059a:	850a                	mv	a0,sp
    jal trap
    8020059c:	f8dff0ef          	jal	ra,80200528 <trap>

00000000802005a0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005a0:	6492                	ld	s1,256(sp)
    802005a2:	6932                	ld	s2,264(sp)
    802005a4:	10049073          	csrw	sstatus,s1
    802005a8:	14191073          	csrw	sepc,s2
    802005ac:	60a2                	ld	ra,8(sp)
    802005ae:	61e2                	ld	gp,24(sp)
    802005b0:	7202                	ld	tp,32(sp)
    802005b2:	72a2                	ld	t0,40(sp)
    802005b4:	7342                	ld	t1,48(sp)
    802005b6:	73e2                	ld	t2,56(sp)
    802005b8:	6406                	ld	s0,64(sp)
    802005ba:	64a6                	ld	s1,72(sp)
    802005bc:	6546                	ld	a0,80(sp)
    802005be:	65e6                	ld	a1,88(sp)
    802005c0:	7606                	ld	a2,96(sp)
    802005c2:	76a6                	ld	a3,104(sp)
    802005c4:	7746                	ld	a4,112(sp)
    802005c6:	77e6                	ld	a5,120(sp)
    802005c8:	680a                	ld	a6,128(sp)
    802005ca:	68aa                	ld	a7,136(sp)
    802005cc:	694a                	ld	s2,144(sp)
    802005ce:	69ea                	ld	s3,152(sp)
    802005d0:	7a0a                	ld	s4,160(sp)
    802005d2:	7aaa                	ld	s5,168(sp)
    802005d4:	7b4a                	ld	s6,176(sp)
    802005d6:	7bea                	ld	s7,184(sp)
    802005d8:	6c0e                	ld	s8,192(sp)
    802005da:	6cae                	ld	s9,200(sp)
    802005dc:	6d4e                	ld	s10,208(sp)
    802005de:	6dee                	ld	s11,216(sp)
    802005e0:	7e0e                	ld	t3,224(sp)
    802005e2:	7eae                	ld	t4,232(sp)
    802005e4:	7f4e                	ld	t5,240(sp)
    802005e6:	7fee                	ld	t6,248(sp)
    802005e8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005ea:	10200073          	sret

00000000802005ee <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802005ee:	c185                	beqz	a1,8020060e <strnlen+0x20>
    802005f0:	00054783          	lbu	a5,0(a0)
    802005f4:	cf89                	beqz	a5,8020060e <strnlen+0x20>
    size_t cnt = 0;
    802005f6:	4781                	li	a5,0
    802005f8:	a021                	j	80200600 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    802005fa:	00074703          	lbu	a4,0(a4)
    802005fe:	c711                	beqz	a4,8020060a <strnlen+0x1c>
        cnt ++;
    80200600:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200602:	00f50733          	add	a4,a0,a5
    80200606:	fef59ae3          	bne	a1,a5,802005fa <strnlen+0xc>
    }
    return cnt;
}
    8020060a:	853e                	mv	a0,a5
    8020060c:	8082                	ret
    size_t cnt = 0;
    8020060e:	4781                	li	a5,0
}
    80200610:	853e                	mv	a0,a5
    80200612:	8082                	ret

0000000080200614 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200614:	ca01                	beqz	a2,80200624 <memset+0x10>
    80200616:	962a                	add	a2,a2,a0
    char *p = s;
    80200618:	87aa                	mv	a5,a0
        *p ++ = c;
    8020061a:	0785                	addi	a5,a5,1
    8020061c:	feb78fa3          	sb	a1,-1(a5) # fff <BASE_ADDRESS-0x801ff001>
    while (n -- > 0) {
    80200620:	fec79de3          	bne	a5,a2,8020061a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200624:	8082                	ret

0000000080200626 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200626:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020062a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    8020062c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200630:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200632:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200636:	f022                	sd	s0,32(sp)
    80200638:	ec26                	sd	s1,24(sp)
    8020063a:	e84a                	sd	s2,16(sp)
    8020063c:	f406                	sd	ra,40(sp)
    8020063e:	e44e                	sd	s3,8(sp)
    80200640:	84aa                	mv	s1,a0
    80200642:	892e                	mv	s2,a1
    80200644:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200648:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020064a:	03067e63          	bleu	a6,a2,80200686 <printnum+0x60>
    8020064e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200650:	00805763          	blez	s0,8020065e <printnum+0x38>
    80200654:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200656:	85ca                	mv	a1,s2
    80200658:	854e                	mv	a0,s3
    8020065a:	9482                	jalr	s1
        while (-- width > 0)
    8020065c:	fc65                	bnez	s0,80200654 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020065e:	1a02                	slli	s4,s4,0x20
    80200660:	020a5a13          	srli	s4,s4,0x20
    80200664:	00001797          	auipc	a5,0x1
    80200668:	bc478793          	addi	a5,a5,-1084 # 80201228 <error_string+0x38>
    8020066c:	9a3e                	add	s4,s4,a5
}
    8020066e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200670:	000a4503          	lbu	a0,0(s4)
}
    80200674:	70a2                	ld	ra,40(sp)
    80200676:	69a2                	ld	s3,8(sp)
    80200678:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020067a:	85ca                	mv	a1,s2
    8020067c:	8326                	mv	t1,s1
}
    8020067e:	6942                	ld	s2,16(sp)
    80200680:	64e2                	ld	s1,24(sp)
    80200682:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200684:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    80200686:	03065633          	divu	a2,a2,a6
    8020068a:	8722                	mv	a4,s0
    8020068c:	f9bff0ef          	jal	ra,80200626 <printnum>
    80200690:	b7f9                	j	8020065e <printnum+0x38>

0000000080200692 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200692:	7119                	addi	sp,sp,-128
    80200694:	f4a6                	sd	s1,104(sp)
    80200696:	f0ca                	sd	s2,96(sp)
    80200698:	e8d2                	sd	s4,80(sp)
    8020069a:	e4d6                	sd	s5,72(sp)
    8020069c:	e0da                	sd	s6,64(sp)
    8020069e:	fc5e                	sd	s7,56(sp)
    802006a0:	f862                	sd	s8,48(sp)
    802006a2:	f06a                	sd	s10,32(sp)
    802006a4:	fc86                	sd	ra,120(sp)
    802006a6:	f8a2                	sd	s0,112(sp)
    802006a8:	ecce                	sd	s3,88(sp)
    802006aa:	f466                	sd	s9,40(sp)
    802006ac:	ec6e                	sd	s11,24(sp)
    802006ae:	892a                	mv	s2,a0
    802006b0:	84ae                	mv	s1,a1
    802006b2:	8d32                	mv	s10,a2
    802006b4:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802006b6:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802006b8:	00001a17          	auipc	s4,0x1
    802006bc:	9dca0a13          	addi	s4,s4,-1572 # 80201094 <etext+0x622>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802006c0:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006c4:	00001c17          	auipc	s8,0x1
    802006c8:	b2cc0c13          	addi	s8,s8,-1236 # 802011f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006cc:	000d4503          	lbu	a0,0(s10)
    802006d0:	02500793          	li	a5,37
    802006d4:	001d0413          	addi	s0,s10,1
    802006d8:	00f50e63          	beq	a0,a5,802006f4 <vprintfmt+0x62>
            if (ch == '\0') {
    802006dc:	c521                	beqz	a0,80200724 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006de:	02500993          	li	s3,37
    802006e2:	a011                	j	802006e6 <vprintfmt+0x54>
            if (ch == '\0') {
    802006e4:	c121                	beqz	a0,80200724 <vprintfmt+0x92>
            putch(ch, putdat);
    802006e6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006e8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006ea:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006ec:	fff44503          	lbu	a0,-1(s0)
    802006f0:	ff351ae3          	bne	a0,s3,802006e4 <vprintfmt+0x52>
    802006f4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006f8:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006fc:	4981                	li	s3,0
    802006fe:	4801                	li	a6,0
        width = precision = -1;
    80200700:	5cfd                	li	s9,-1
    80200702:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200704:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200708:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020070a:	fdd6069b          	addiw	a3,a2,-35
    8020070e:	0ff6f693          	andi	a3,a3,255
    80200712:	00140d13          	addi	s10,s0,1
    80200716:	20d5e563          	bltu	a1,a3,80200920 <vprintfmt+0x28e>
    8020071a:	068a                	slli	a3,a3,0x2
    8020071c:	96d2                	add	a3,a3,s4
    8020071e:	4294                	lw	a3,0(a3)
    80200720:	96d2                	add	a3,a3,s4
    80200722:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200724:	70e6                	ld	ra,120(sp)
    80200726:	7446                	ld	s0,112(sp)
    80200728:	74a6                	ld	s1,104(sp)
    8020072a:	7906                	ld	s2,96(sp)
    8020072c:	69e6                	ld	s3,88(sp)
    8020072e:	6a46                	ld	s4,80(sp)
    80200730:	6aa6                	ld	s5,72(sp)
    80200732:	6b06                	ld	s6,64(sp)
    80200734:	7be2                	ld	s7,56(sp)
    80200736:	7c42                	ld	s8,48(sp)
    80200738:	7ca2                	ld	s9,40(sp)
    8020073a:	7d02                	ld	s10,32(sp)
    8020073c:	6de2                	ld	s11,24(sp)
    8020073e:	6109                	addi	sp,sp,128
    80200740:	8082                	ret
    if (lflag >= 2) {
    80200742:	4705                	li	a4,1
    80200744:	008a8593          	addi	a1,s5,8
    80200748:	01074463          	blt	a4,a6,80200750 <vprintfmt+0xbe>
    else if (lflag) {
    8020074c:	26080363          	beqz	a6,802009b2 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200750:	000ab603          	ld	a2,0(s5)
    80200754:	46c1                	li	a3,16
    80200756:	8aae                	mv	s5,a1
    80200758:	a06d                	j	80200802 <vprintfmt+0x170>
            goto reswitch;
    8020075a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020075e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200760:	846a                	mv	s0,s10
            goto reswitch;
    80200762:	b765                	j	8020070a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200764:	000aa503          	lw	a0,0(s5)
    80200768:	85a6                	mv	a1,s1
    8020076a:	0aa1                	addi	s5,s5,8
    8020076c:	9902                	jalr	s2
            break;
    8020076e:	bfb9                	j	802006cc <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200770:	4705                	li	a4,1
    80200772:	008a8993          	addi	s3,s5,8
    80200776:	01074463          	blt	a4,a6,8020077e <vprintfmt+0xec>
    else if (lflag) {
    8020077a:	22080463          	beqz	a6,802009a2 <vprintfmt+0x310>
        return va_arg(*ap, long);
    8020077e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200782:	24044463          	bltz	s0,802009ca <vprintfmt+0x338>
            num = getint(&ap, lflag);
    80200786:	8622                	mv	a2,s0
    80200788:	8ace                	mv	s5,s3
    8020078a:	46a9                	li	a3,10
    8020078c:	a89d                	j	80200802 <vprintfmt+0x170>
            err = va_arg(ap, int);
    8020078e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200792:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200794:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    80200796:	41f7d69b          	sraiw	a3,a5,0x1f
    8020079a:	8fb5                	xor	a5,a5,a3
    8020079c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007a0:	1ad74363          	blt	a4,a3,80200946 <vprintfmt+0x2b4>
    802007a4:	00369793          	slli	a5,a3,0x3
    802007a8:	97e2                	add	a5,a5,s8
    802007aa:	639c                	ld	a5,0(a5)
    802007ac:	18078d63          	beqz	a5,80200946 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    802007b0:	86be                	mv	a3,a5
    802007b2:	00001617          	auipc	a2,0x1
    802007b6:	b2660613          	addi	a2,a2,-1242 # 802012d8 <error_string+0xe8>
    802007ba:	85a6                	mv	a1,s1
    802007bc:	854a                	mv	a0,s2
    802007be:	240000ef          	jal	ra,802009fe <printfmt>
    802007c2:	b729                	j	802006cc <vprintfmt+0x3a>
            lflag ++;
    802007c4:	00144603          	lbu	a2,1(s0)
    802007c8:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007ca:	846a                	mv	s0,s10
            goto reswitch;
    802007cc:	bf3d                	j	8020070a <vprintfmt+0x78>
    if (lflag >= 2) {
    802007ce:	4705                	li	a4,1
    802007d0:	008a8593          	addi	a1,s5,8
    802007d4:	01074463          	blt	a4,a6,802007dc <vprintfmt+0x14a>
    else if (lflag) {
    802007d8:	1e080263          	beqz	a6,802009bc <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007dc:	000ab603          	ld	a2,0(s5)
    802007e0:	46a1                	li	a3,8
    802007e2:	8aae                	mv	s5,a1
    802007e4:	a839                	j	80200802 <vprintfmt+0x170>
            putch('0', putdat);
    802007e6:	03000513          	li	a0,48
    802007ea:	85a6                	mv	a1,s1
    802007ec:	e03e                	sd	a5,0(sp)
    802007ee:	9902                	jalr	s2
            putch('x', putdat);
    802007f0:	85a6                	mv	a1,s1
    802007f2:	07800513          	li	a0,120
    802007f6:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007f8:	0aa1                	addi	s5,s5,8
    802007fa:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007fe:	6782                	ld	a5,0(sp)
    80200800:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    80200802:	876e                	mv	a4,s11
    80200804:	85a6                	mv	a1,s1
    80200806:	854a                	mv	a0,s2
    80200808:	e1fff0ef          	jal	ra,80200626 <printnum>
            break;
    8020080c:	b5c1                	j	802006cc <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020080e:	000ab603          	ld	a2,0(s5)
    80200812:	0aa1                	addi	s5,s5,8
    80200814:	1c060663          	beqz	a2,802009e0 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    80200818:	00160413          	addi	s0,a2,1
    8020081c:	17b05c63          	blez	s11,80200994 <vprintfmt+0x302>
    80200820:	02d00593          	li	a1,45
    80200824:	14b79263          	bne	a5,a1,80200968 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200828:	00064783          	lbu	a5,0(a2)
    8020082c:	0007851b          	sext.w	a0,a5
    80200830:	c905                	beqz	a0,80200860 <vprintfmt+0x1ce>
    80200832:	000cc563          	bltz	s9,8020083c <vprintfmt+0x1aa>
    80200836:	3cfd                	addiw	s9,s9,-1
    80200838:	036c8263          	beq	s9,s6,8020085c <vprintfmt+0x1ca>
                    putch('?', putdat);
    8020083c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020083e:	18098463          	beqz	s3,802009c6 <vprintfmt+0x334>
    80200842:	3781                	addiw	a5,a5,-32
    80200844:	18fbf163          	bleu	a5,s7,802009c6 <vprintfmt+0x334>
                    putch('?', putdat);
    80200848:	03f00513          	li	a0,63
    8020084c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020084e:	0405                	addi	s0,s0,1
    80200850:	fff44783          	lbu	a5,-1(s0)
    80200854:	3dfd                	addiw	s11,s11,-1
    80200856:	0007851b          	sext.w	a0,a5
    8020085a:	fd61                	bnez	a0,80200832 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    8020085c:	e7b058e3          	blez	s11,802006cc <vprintfmt+0x3a>
    80200860:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200862:	85a6                	mv	a1,s1
    80200864:	02000513          	li	a0,32
    80200868:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020086a:	e60d81e3          	beqz	s11,802006cc <vprintfmt+0x3a>
    8020086e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200870:	85a6                	mv	a1,s1
    80200872:	02000513          	li	a0,32
    80200876:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200878:	fe0d94e3          	bnez	s11,80200860 <vprintfmt+0x1ce>
    8020087c:	bd81                	j	802006cc <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020087e:	4705                	li	a4,1
    80200880:	008a8593          	addi	a1,s5,8
    80200884:	01074463          	blt	a4,a6,8020088c <vprintfmt+0x1fa>
    else if (lflag) {
    80200888:	12080063          	beqz	a6,802009a8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    8020088c:	000ab603          	ld	a2,0(s5)
    80200890:	46a9                	li	a3,10
    80200892:	8aae                	mv	s5,a1
    80200894:	b7bd                	j	80200802 <vprintfmt+0x170>
    80200896:	00144603          	lbu	a2,1(s0)
            padc = '-';
    8020089a:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    8020089e:	846a                	mv	s0,s10
    802008a0:	b5ad                	j	8020070a <vprintfmt+0x78>
            putch(ch, putdat);
    802008a2:	85a6                	mv	a1,s1
    802008a4:	02500513          	li	a0,37
    802008a8:	9902                	jalr	s2
            break;
    802008aa:	b50d                	j	802006cc <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    802008ac:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802008b0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802008b4:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802008b6:	846a                	mv	s0,s10
            if (width < 0)
    802008b8:	e40dd9e3          	bgez	s11,8020070a <vprintfmt+0x78>
                width = precision, precision = -1;
    802008bc:	8de6                	mv	s11,s9
    802008be:	5cfd                	li	s9,-1
    802008c0:	b5a9                	j	8020070a <vprintfmt+0x78>
            goto reswitch;
    802008c2:	00144603          	lbu	a2,1(s0)
            padc = '0';
    802008c6:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    802008ca:	846a                	mv	s0,s10
            goto reswitch;
    802008cc:	bd3d                	j	8020070a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    802008ce:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802008d2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802008d6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008d8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008dc:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008e0:	fcd56ce3          	bltu	a0,a3,802008b8 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008e4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008e6:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008ea:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008ee:	0196873b          	addw	a4,a3,s9
    802008f2:	0017171b          	slliw	a4,a4,0x1
    802008f6:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008fa:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008fe:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    80200902:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200906:	fcd57fe3          	bleu	a3,a0,802008e4 <vprintfmt+0x252>
    8020090a:	b77d                	j	802008b8 <vprintfmt+0x226>
            if (width < 0)
    8020090c:	fffdc693          	not	a3,s11
    80200910:	96fd                	srai	a3,a3,0x3f
    80200912:	00ddfdb3          	and	s11,s11,a3
    80200916:	00144603          	lbu	a2,1(s0)
    8020091a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    8020091c:	846a                	mv	s0,s10
    8020091e:	b3f5                	j	8020070a <vprintfmt+0x78>
            putch('%', putdat);
    80200920:	85a6                	mv	a1,s1
    80200922:	02500513          	li	a0,37
    80200926:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200928:	fff44703          	lbu	a4,-1(s0)
    8020092c:	02500793          	li	a5,37
    80200930:	8d22                	mv	s10,s0
    80200932:	d8f70de3          	beq	a4,a5,802006cc <vprintfmt+0x3a>
    80200936:	02500713          	li	a4,37
    8020093a:	1d7d                	addi	s10,s10,-1
    8020093c:	fffd4783          	lbu	a5,-1(s10)
    80200940:	fee79de3          	bne	a5,a4,8020093a <vprintfmt+0x2a8>
    80200944:	b361                	j	802006cc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200946:	00001617          	auipc	a2,0x1
    8020094a:	98260613          	addi	a2,a2,-1662 # 802012c8 <error_string+0xd8>
    8020094e:	85a6                	mv	a1,s1
    80200950:	854a                	mv	a0,s2
    80200952:	0ac000ef          	jal	ra,802009fe <printfmt>
    80200956:	bb9d                	j	802006cc <vprintfmt+0x3a>
                p = "(null)";
    80200958:	00001617          	auipc	a2,0x1
    8020095c:	96860613          	addi	a2,a2,-1688 # 802012c0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200960:	00001417          	auipc	s0,0x1
    80200964:	96140413          	addi	s0,s0,-1695 # 802012c1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200968:	8532                	mv	a0,a2
    8020096a:	85e6                	mv	a1,s9
    8020096c:	e032                	sd	a2,0(sp)
    8020096e:	e43e                	sd	a5,8(sp)
    80200970:	c7fff0ef          	jal	ra,802005ee <strnlen>
    80200974:	40ad8dbb          	subw	s11,s11,a0
    80200978:	6602                	ld	a2,0(sp)
    8020097a:	01b05d63          	blez	s11,80200994 <vprintfmt+0x302>
    8020097e:	67a2                	ld	a5,8(sp)
    80200980:	2781                	sext.w	a5,a5
    80200982:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200984:	6522                	ld	a0,8(sp)
    80200986:	85a6                	mv	a1,s1
    80200988:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020098a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020098c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020098e:	6602                	ld	a2,0(sp)
    80200990:	fe0d9ae3          	bnez	s11,80200984 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200994:	00064783          	lbu	a5,0(a2)
    80200998:	0007851b          	sext.w	a0,a5
    8020099c:	e8051be3          	bnez	a0,80200832 <vprintfmt+0x1a0>
    802009a0:	b335                	j	802006cc <vprintfmt+0x3a>
        return va_arg(*ap, int);
    802009a2:	000aa403          	lw	s0,0(s5)
    802009a6:	bbf1                	j	80200782 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    802009a8:	000ae603          	lwu	a2,0(s5)
    802009ac:	46a9                	li	a3,10
    802009ae:	8aae                	mv	s5,a1
    802009b0:	bd89                	j	80200802 <vprintfmt+0x170>
    802009b2:	000ae603          	lwu	a2,0(s5)
    802009b6:	46c1                	li	a3,16
    802009b8:	8aae                	mv	s5,a1
    802009ba:	b5a1                	j	80200802 <vprintfmt+0x170>
    802009bc:	000ae603          	lwu	a2,0(s5)
    802009c0:	46a1                	li	a3,8
    802009c2:	8aae                	mv	s5,a1
    802009c4:	bd3d                	j	80200802 <vprintfmt+0x170>
                    putch(ch, putdat);
    802009c6:	9902                	jalr	s2
    802009c8:	b559                	j	8020084e <vprintfmt+0x1bc>
                putch('-', putdat);
    802009ca:	85a6                	mv	a1,s1
    802009cc:	02d00513          	li	a0,45
    802009d0:	e03e                	sd	a5,0(sp)
    802009d2:	9902                	jalr	s2
                num = -(long long)num;
    802009d4:	8ace                	mv	s5,s3
    802009d6:	40800633          	neg	a2,s0
    802009da:	46a9                	li	a3,10
    802009dc:	6782                	ld	a5,0(sp)
    802009de:	b515                	j	80200802 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009e0:	01b05663          	blez	s11,802009ec <vprintfmt+0x35a>
    802009e4:	02d00693          	li	a3,45
    802009e8:	f6d798e3          	bne	a5,a3,80200958 <vprintfmt+0x2c6>
    802009ec:	00001417          	auipc	s0,0x1
    802009f0:	8d540413          	addi	s0,s0,-1835 # 802012c1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009f4:	02800513          	li	a0,40
    802009f8:	02800793          	li	a5,40
    802009fc:	bd1d                	j	80200832 <vprintfmt+0x1a0>

00000000802009fe <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009fe:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200a00:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a04:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a06:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a08:	ec06                	sd	ra,24(sp)
    80200a0a:	f83a                	sd	a4,48(sp)
    80200a0c:	fc3e                	sd	a5,56(sp)
    80200a0e:	e0c2                	sd	a6,64(sp)
    80200a10:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200a12:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a14:	c7fff0ef          	jal	ra,80200692 <vprintfmt>
}
    80200a18:	60e2                	ld	ra,24(sp)
    80200a1a:	6161                	addi	sp,sp,80
    80200a1c:	8082                	ret

0000000080200a1e <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200a1e:	00003797          	auipc	a5,0x3
    80200a22:	5e278793          	addi	a5,a5,1506 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200a26:	6398                	ld	a4,0(a5)
    80200a28:	4781                	li	a5,0
    80200a2a:	88ba                	mv	a7,a4
    80200a2c:	852a                	mv	a0,a0
    80200a2e:	85be                	mv	a1,a5
    80200a30:	863e                	mv	a2,a5
    80200a32:	00000073          	ecall
    80200a36:	87aa                	mv	a5,a0
}
    80200a38:	8082                	ret

0000000080200a3a <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a3a:	00003797          	auipc	a5,0x3
    80200a3e:	5d678793          	addi	a5,a5,1494 # 80204010 <edata>
    __asm__ volatile (
    80200a42:	6398                	ld	a4,0(a5)
    80200a44:	4781                	li	a5,0
    80200a46:	88ba                	mv	a7,a4
    80200a48:	852a                	mv	a0,a0
    80200a4a:	85be                	mv	a1,a5
    80200a4c:	863e                	mv	a2,a5
    80200a4e:	00000073          	ecall
    80200a52:	87aa                	mv	a5,a0
}
    80200a54:	8082                	ret

0000000080200a56 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a56:	00003797          	auipc	a5,0x3
    80200a5a:	5b278793          	addi	a5,a5,1458 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a5e:	6398                	ld	a4,0(a5)
    80200a60:	4781                	li	a5,0
    80200a62:	88ba                	mv	a7,a4
    80200a64:	853e                	mv	a0,a5
    80200a66:	85be                	mv	a1,a5
    80200a68:	863e                	mv	a2,a5
    80200a6a:	00000073          	ecall
    80200a6e:	87aa                	mv	a5,a0
    80200a70:	8082                	ret
