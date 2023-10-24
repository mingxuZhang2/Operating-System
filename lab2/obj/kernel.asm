
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43a60613          	addi	a2,a2,1082 # ffffffffc0206478 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	195010ef          	jal	ra,ffffffffc02019e2 <memset>
    cons_init();  // init the console
ffffffffc0200052:	40e000ef          	jal	ra,ffffffffc0200460 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	eca50513          	addi	a0,a0,-310 # ffffffffc0201f20 <etext+0x4>
ffffffffc020005e:	0a0000ef          	jal	ra,ffffffffc02000fe <cputs>

    print_kerninfo();
ffffffffc0200062:	14c000ef          	jal	ra,ffffffffc02001ae <print_kerninfo>

    cprintf("It will run Buddy_system!\n");
ffffffffc0200066:	00002517          	auipc	a0,0x2
ffffffffc020006a:	eda50513          	addi	a0,a0,-294 # ffffffffc0201f40 <etext+0x24>
ffffffffc020006e:	058000ef          	jal	ra,ffffffffc02000c6 <cprintf>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200072:	408000ef          	jal	ra,ffffffffc020047a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200076:	48b000ef          	jal	ra,ffffffffc0200d00 <pmm_init>

    test_slub_cache();
ffffffffc020007a:	235000ef          	jal	ra,ffffffffc0200aae <test_slub_cache>

    idt_init();  // init interrupt descriptor table
ffffffffc020007e:	3fc000ef          	jal	ra,ffffffffc020047a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200082:	39a000ef          	jal	ra,ffffffffc020041c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200086:	3e8000ef          	jal	ra,ffffffffc020046e <intr_enable>


    /* do nothing */
    while (1)
        ;
ffffffffc020008a:	a001                	j	ffffffffc020008a <kern_init+0x54>

ffffffffc020008c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020008c:	1141                	addi	sp,sp,-16
ffffffffc020008e:	e022                	sd	s0,0(sp)
ffffffffc0200090:	e406                	sd	ra,8(sp)
ffffffffc0200092:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200094:	3ce000ef          	jal	ra,ffffffffc0200462 <cons_putc>
    (*cnt) ++;
ffffffffc0200098:	401c                	lw	a5,0(s0)
}
ffffffffc020009a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020009c:	2785                	addiw	a5,a5,1
ffffffffc020009e:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a0:	6402                	ld	s0,0(sp)
ffffffffc02000a2:	0141                	addi	sp,sp,16
ffffffffc02000a4:	8082                	ret

ffffffffc02000a6 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a8:	86ae                	mv	a3,a1
ffffffffc02000aa:	862a                	mv	a2,a0
ffffffffc02000ac:	006c                	addi	a1,sp,12
ffffffffc02000ae:	00000517          	auipc	a0,0x0
ffffffffc02000b2:	fde50513          	addi	a0,a0,-34 # ffffffffc020008c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ba:	1a7010ef          	jal	ra,ffffffffc0201a60 <vprintfmt>
    return cnt;
}
ffffffffc02000be:	60e2                	ld	ra,24(sp)
ffffffffc02000c0:	4532                	lw	a0,12(sp)
ffffffffc02000c2:	6105                	addi	sp,sp,32
ffffffffc02000c4:	8082                	ret

ffffffffc02000c6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000c6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	f42e                	sd	a1,40(sp)
ffffffffc02000ce:	f832                	sd	a2,48(sp)
ffffffffc02000d0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000d2:	862a                	mv	a2,a0
ffffffffc02000d4:	004c                	addi	a1,sp,4
ffffffffc02000d6:	00000517          	auipc	a0,0x0
ffffffffc02000da:	fb650513          	addi	a0,a0,-74 # ffffffffc020008c <cputch>
ffffffffc02000de:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000e0:	ec06                	sd	ra,24(sp)
ffffffffc02000e2:	e0ba                	sd	a4,64(sp)
ffffffffc02000e4:	e4be                	sd	a5,72(sp)
ffffffffc02000e6:	e8c2                	sd	a6,80(sp)
ffffffffc02000e8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000ea:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000ec:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ee:	173010ef          	jal	ra,ffffffffc0201a60 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000f2:	60e2                	ld	ra,24(sp)
ffffffffc02000f4:	4512                	lw	a0,4(sp)
ffffffffc02000f6:	6125                	addi	sp,sp,96
ffffffffc02000f8:	8082                	ret

ffffffffc02000fa <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000fa:	3680006f          	j	ffffffffc0200462 <cons_putc>

ffffffffc02000fe <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000fe:	1101                	addi	sp,sp,-32
ffffffffc0200100:	e822                	sd	s0,16(sp)
ffffffffc0200102:	ec06                	sd	ra,24(sp)
ffffffffc0200104:	e426                	sd	s1,8(sp)
ffffffffc0200106:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200108:	00054503          	lbu	a0,0(a0)
ffffffffc020010c:	c51d                	beqz	a0,ffffffffc020013a <cputs+0x3c>
ffffffffc020010e:	0405                	addi	s0,s0,1
ffffffffc0200110:	4485                	li	s1,1
ffffffffc0200112:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200114:	34e000ef          	jal	ra,ffffffffc0200462 <cons_putc>
    (*cnt) ++;
ffffffffc0200118:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020011c:	0405                	addi	s0,s0,1
ffffffffc020011e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200122:	f96d                	bnez	a0,ffffffffc0200114 <cputs+0x16>
ffffffffc0200124:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200128:	4529                	li	a0,10
ffffffffc020012a:	338000ef          	jal	ra,ffffffffc0200462 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020012e:	8522                	mv	a0,s0
ffffffffc0200130:	60e2                	ld	ra,24(sp)
ffffffffc0200132:	6442                	ld	s0,16(sp)
ffffffffc0200134:	64a2                	ld	s1,8(sp)
ffffffffc0200136:	6105                	addi	sp,sp,32
ffffffffc0200138:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020013a:	4405                	li	s0,1
ffffffffc020013c:	b7f5                	j	ffffffffc0200128 <cputs+0x2a>

ffffffffc020013e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
ffffffffc0200140:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200142:	328000ef          	jal	ra,ffffffffc020046a <cons_getc>
ffffffffc0200146:	dd75                	beqz	a0,ffffffffc0200142 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200148:	60a2                	ld	ra,8(sp)
ffffffffc020014a:	0141                	addi	sp,sp,16
ffffffffc020014c:	8082                	ret

ffffffffc020014e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020014e:	00006317          	auipc	t1,0x6
ffffffffc0200152:	2ca30313          	addi	t1,t1,714 # ffffffffc0206418 <is_panic>
ffffffffc0200156:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020015a:	715d                	addi	sp,sp,-80
ffffffffc020015c:	ec06                	sd	ra,24(sp)
ffffffffc020015e:	e822                	sd	s0,16(sp)
ffffffffc0200160:	f436                	sd	a3,40(sp)
ffffffffc0200162:	f83a                	sd	a4,48(sp)
ffffffffc0200164:	fc3e                	sd	a5,56(sp)
ffffffffc0200166:	e0c2                	sd	a6,64(sp)
ffffffffc0200168:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020016a:	02031c63          	bnez	t1,ffffffffc02001a2 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020016e:	4785                	li	a5,1
ffffffffc0200170:	8432                	mv	s0,a2
ffffffffc0200172:	00006717          	auipc	a4,0x6
ffffffffc0200176:	2af72323          	sw	a5,678(a4) # ffffffffc0206418 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020017c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017e:	85aa                	mv	a1,a0
ffffffffc0200180:	00002517          	auipc	a0,0x2
ffffffffc0200184:	de050513          	addi	a0,a0,-544 # ffffffffc0201f60 <etext+0x44>
    va_start(ap, fmt);
ffffffffc0200188:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020018a:	f3dff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020018e:	65a2                	ld	a1,8(sp)
ffffffffc0200190:	8522                	mv	a0,s0
ffffffffc0200192:	f15ff0ef          	jal	ra,ffffffffc02000a6 <vcprintf>
    cprintf("\n");
ffffffffc0200196:	00002517          	auipc	a0,0x2
ffffffffc020019a:	ee250513          	addi	a0,a0,-286 # ffffffffc0202078 <etext+0x15c>
ffffffffc020019e:	f29ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02001a2:	2d2000ef          	jal	ra,ffffffffc0200474 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02001a6:	4501                	li	a0,0
ffffffffc02001a8:	132000ef          	jal	ra,ffffffffc02002da <kmonitor>
ffffffffc02001ac:	bfed                	j	ffffffffc02001a6 <__panic+0x58>

ffffffffc02001ae <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001ae:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001b0:	00002517          	auipc	a0,0x2
ffffffffc02001b4:	e0050513          	addi	a0,a0,-512 # ffffffffc0201fb0 <etext+0x94>
void print_kerninfo(void) {
ffffffffc02001b8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001ba:	f0dff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001be:	00000597          	auipc	a1,0x0
ffffffffc02001c2:	e7858593          	addi	a1,a1,-392 # ffffffffc0200036 <kern_init>
ffffffffc02001c6:	00002517          	auipc	a0,0x2
ffffffffc02001ca:	e0a50513          	addi	a0,a0,-502 # ffffffffc0201fd0 <etext+0xb4>
ffffffffc02001ce:	ef9ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001d2:	00002597          	auipc	a1,0x2
ffffffffc02001d6:	d4a58593          	addi	a1,a1,-694 # ffffffffc0201f1c <etext>
ffffffffc02001da:	00002517          	auipc	a0,0x2
ffffffffc02001de:	e1650513          	addi	a0,a0,-490 # ffffffffc0201ff0 <etext+0xd4>
ffffffffc02001e2:	ee5ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001e6:	00006597          	auipc	a1,0x6
ffffffffc02001ea:	e3258593          	addi	a1,a1,-462 # ffffffffc0206018 <edata>
ffffffffc02001ee:	00002517          	auipc	a0,0x2
ffffffffc02001f2:	e2250513          	addi	a0,a0,-478 # ffffffffc0202010 <etext+0xf4>
ffffffffc02001f6:	ed1ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001fa:	00006597          	auipc	a1,0x6
ffffffffc02001fe:	27e58593          	addi	a1,a1,638 # ffffffffc0206478 <end>
ffffffffc0200202:	00002517          	auipc	a0,0x2
ffffffffc0200206:	e2e50513          	addi	a0,a0,-466 # ffffffffc0202030 <etext+0x114>
ffffffffc020020a:	ebdff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020020e:	00006597          	auipc	a1,0x6
ffffffffc0200212:	66958593          	addi	a1,a1,1641 # ffffffffc0206877 <end+0x3ff>
ffffffffc0200216:	00000797          	auipc	a5,0x0
ffffffffc020021a:	e2078793          	addi	a5,a5,-480 # ffffffffc0200036 <kern_init>
ffffffffc020021e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200222:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200226:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200228:	3ff5f593          	andi	a1,a1,1023
ffffffffc020022c:	95be                	add	a1,a1,a5
ffffffffc020022e:	85a9                	srai	a1,a1,0xa
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	e2050513          	addi	a0,a0,-480 # ffffffffc0202050 <etext+0x134>
}
ffffffffc0200238:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023a:	e8dff06f          	j	ffffffffc02000c6 <cprintf>

ffffffffc020023e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020023e:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200240:	00002617          	auipc	a2,0x2
ffffffffc0200244:	d4060613          	addi	a2,a2,-704 # ffffffffc0201f80 <etext+0x64>
ffffffffc0200248:	04e00593          	li	a1,78
ffffffffc020024c:	00002517          	auipc	a0,0x2
ffffffffc0200250:	d4c50513          	addi	a0,a0,-692 # ffffffffc0201f98 <etext+0x7c>
void print_stackframe(void) {
ffffffffc0200254:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200256:	ef9ff0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc020025a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025c:	00002617          	auipc	a2,0x2
ffffffffc0200260:	f0460613          	addi	a2,a2,-252 # ffffffffc0202160 <commands+0xe0>
ffffffffc0200264:	00002597          	auipc	a1,0x2
ffffffffc0200268:	f1c58593          	addi	a1,a1,-228 # ffffffffc0202180 <commands+0x100>
ffffffffc020026c:	00002517          	auipc	a0,0x2
ffffffffc0200270:	f1c50513          	addi	a0,a0,-228 # ffffffffc0202188 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200274:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200276:	e51ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
ffffffffc020027a:	00002617          	auipc	a2,0x2
ffffffffc020027e:	f1e60613          	addi	a2,a2,-226 # ffffffffc0202198 <commands+0x118>
ffffffffc0200282:	00002597          	auipc	a1,0x2
ffffffffc0200286:	f3e58593          	addi	a1,a1,-194 # ffffffffc02021c0 <commands+0x140>
ffffffffc020028a:	00002517          	auipc	a0,0x2
ffffffffc020028e:	efe50513          	addi	a0,a0,-258 # ffffffffc0202188 <commands+0x108>
ffffffffc0200292:	e35ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
ffffffffc0200296:	00002617          	auipc	a2,0x2
ffffffffc020029a:	f3a60613          	addi	a2,a2,-198 # ffffffffc02021d0 <commands+0x150>
ffffffffc020029e:	00002597          	auipc	a1,0x2
ffffffffc02002a2:	f5258593          	addi	a1,a1,-174 # ffffffffc02021f0 <commands+0x170>
ffffffffc02002a6:	00002517          	auipc	a0,0x2
ffffffffc02002aa:	ee250513          	addi	a0,a0,-286 # ffffffffc0202188 <commands+0x108>
ffffffffc02002ae:	e19ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    }
    return 0;
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
ffffffffc02002b4:	4501                	li	a0,0
ffffffffc02002b6:	0141                	addi	sp,sp,16
ffffffffc02002b8:	8082                	ret

ffffffffc02002ba <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ba:	1141                	addi	sp,sp,-16
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002be:	ef1ff0ef          	jal	ra,ffffffffc02001ae <print_kerninfo>
    return 0;
}
ffffffffc02002c2:	60a2                	ld	ra,8(sp)
ffffffffc02002c4:	4501                	li	a0,0
ffffffffc02002c6:	0141                	addi	sp,sp,16
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ca:	1141                	addi	sp,sp,-16
ffffffffc02002cc:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002ce:	f71ff0ef          	jal	ra,ffffffffc020023e <print_stackframe>
    return 0;
}
ffffffffc02002d2:	60a2                	ld	ra,8(sp)
ffffffffc02002d4:	4501                	li	a0,0
ffffffffc02002d6:	0141                	addi	sp,sp,16
ffffffffc02002d8:	8082                	ret

ffffffffc02002da <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002da:	7115                	addi	sp,sp,-224
ffffffffc02002dc:	e962                	sd	s8,144(sp)
ffffffffc02002de:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002e0:	00002517          	auipc	a0,0x2
ffffffffc02002e4:	de850513          	addi	a0,a0,-536 # ffffffffc02020c8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002e8:	ed86                	sd	ra,216(sp)
ffffffffc02002ea:	e9a2                	sd	s0,208(sp)
ffffffffc02002ec:	e5a6                	sd	s1,200(sp)
ffffffffc02002ee:	e1ca                	sd	s2,192(sp)
ffffffffc02002f0:	fd4e                	sd	s3,184(sp)
ffffffffc02002f2:	f952                	sd	s4,176(sp)
ffffffffc02002f4:	f556                	sd	s5,168(sp)
ffffffffc02002f6:	f15a                	sd	s6,160(sp)
ffffffffc02002f8:	ed5e                	sd	s7,152(sp)
ffffffffc02002fa:	e566                	sd	s9,136(sp)
ffffffffc02002fc:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002fe:	dc9ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200302:	00002517          	auipc	a0,0x2
ffffffffc0200306:	dee50513          	addi	a0,a0,-530 # ffffffffc02020f0 <commands+0x70>
ffffffffc020030a:	dbdff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    if (tf != NULL) {
ffffffffc020030e:	000c0563          	beqz	s8,ffffffffc0200318 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200312:	8562                	mv	a0,s8
ffffffffc0200314:	346000ef          	jal	ra,ffffffffc020065a <print_trapframe>
ffffffffc0200318:	00002c97          	auipc	s9,0x2
ffffffffc020031c:	d68c8c93          	addi	s9,s9,-664 # ffffffffc0202080 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200320:	00002997          	auipc	s3,0x2
ffffffffc0200324:	df898993          	addi	s3,s3,-520 # ffffffffc0202118 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200328:	00002917          	auipc	s2,0x2
ffffffffc020032c:	df890913          	addi	s2,s2,-520 # ffffffffc0202120 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200330:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200332:	00002b17          	auipc	s6,0x2
ffffffffc0200336:	df6b0b13          	addi	s6,s6,-522 # ffffffffc0202128 <commands+0xa8>
    if (argc == 0) {
ffffffffc020033a:	00002a97          	auipc	s5,0x2
ffffffffc020033e:	e46a8a93          	addi	s5,s5,-442 # ffffffffc0202180 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200342:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200344:	854e                	mv	a0,s3
ffffffffc0200346:	319010ef          	jal	ra,ffffffffc0201e5e <readline>
ffffffffc020034a:	842a                	mv	s0,a0
ffffffffc020034c:	dd65                	beqz	a0,ffffffffc0200344 <kmonitor+0x6a>
ffffffffc020034e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200352:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200354:	c999                	beqz	a1,ffffffffc020036a <kmonitor+0x90>
ffffffffc0200356:	854a                	mv	a0,s2
ffffffffc0200358:	66c010ef          	jal	ra,ffffffffc02019c4 <strchr>
ffffffffc020035c:	c925                	beqz	a0,ffffffffc02003cc <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020035e:	00144583          	lbu	a1,1(s0)
ffffffffc0200362:	00040023          	sb	zero,0(s0)
ffffffffc0200366:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200368:	f5fd                	bnez	a1,ffffffffc0200356 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020036a:	dce9                	beqz	s1,ffffffffc0200344 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036c:	6582                	ld	a1,0(sp)
ffffffffc020036e:	00002d17          	auipc	s10,0x2
ffffffffc0200372:	d12d0d13          	addi	s10,s10,-750 # ffffffffc0202080 <commands>
    if (argc == 0) {
ffffffffc0200376:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200378:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037a:	0d61                	addi	s10,s10,24
ffffffffc020037c:	61e010ef          	jal	ra,ffffffffc020199a <strcmp>
ffffffffc0200380:	c919                	beqz	a0,ffffffffc0200396 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200382:	2405                	addiw	s0,s0,1
ffffffffc0200384:	09740463          	beq	s0,s7,ffffffffc020040c <kmonitor+0x132>
ffffffffc0200388:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020038c:	6582                	ld	a1,0(sp)
ffffffffc020038e:	0d61                	addi	s10,s10,24
ffffffffc0200390:	60a010ef          	jal	ra,ffffffffc020199a <strcmp>
ffffffffc0200394:	f57d                	bnez	a0,ffffffffc0200382 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200396:	00141793          	slli	a5,s0,0x1
ffffffffc020039a:	97a2                	add	a5,a5,s0
ffffffffc020039c:	078e                	slli	a5,a5,0x3
ffffffffc020039e:	97e6                	add	a5,a5,s9
ffffffffc02003a0:	6b9c                	ld	a5,16(a5)
ffffffffc02003a2:	8662                	mv	a2,s8
ffffffffc02003a4:	002c                	addi	a1,sp,8
ffffffffc02003a6:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003aa:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003ac:	f8055ce3          	bgez	a0,ffffffffc0200344 <kmonitor+0x6a>
}
ffffffffc02003b0:	60ee                	ld	ra,216(sp)
ffffffffc02003b2:	644e                	ld	s0,208(sp)
ffffffffc02003b4:	64ae                	ld	s1,200(sp)
ffffffffc02003b6:	690e                	ld	s2,192(sp)
ffffffffc02003b8:	79ea                	ld	s3,184(sp)
ffffffffc02003ba:	7a4a                	ld	s4,176(sp)
ffffffffc02003bc:	7aaa                	ld	s5,168(sp)
ffffffffc02003be:	7b0a                	ld	s6,160(sp)
ffffffffc02003c0:	6bea                	ld	s7,152(sp)
ffffffffc02003c2:	6c4a                	ld	s8,144(sp)
ffffffffc02003c4:	6caa                	ld	s9,136(sp)
ffffffffc02003c6:	6d0a                	ld	s10,128(sp)
ffffffffc02003c8:	612d                	addi	sp,sp,224
ffffffffc02003ca:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003cc:	00044783          	lbu	a5,0(s0)
ffffffffc02003d0:	dfc9                	beqz	a5,ffffffffc020036a <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02003d2:	03448863          	beq	s1,s4,ffffffffc0200402 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02003d6:	00349793          	slli	a5,s1,0x3
ffffffffc02003da:	0118                	addi	a4,sp,128
ffffffffc02003dc:	97ba                	add	a5,a5,a4
ffffffffc02003de:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003e2:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003e6:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003e8:	e591                	bnez	a1,ffffffffc02003f4 <kmonitor+0x11a>
ffffffffc02003ea:	b749                	j	ffffffffc020036c <kmonitor+0x92>
            buf ++;
ffffffffc02003ec:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003ee:	00044583          	lbu	a1,0(s0)
ffffffffc02003f2:	ddad                	beqz	a1,ffffffffc020036c <kmonitor+0x92>
ffffffffc02003f4:	854a                	mv	a0,s2
ffffffffc02003f6:	5ce010ef          	jal	ra,ffffffffc02019c4 <strchr>
ffffffffc02003fa:	d96d                	beqz	a0,ffffffffc02003ec <kmonitor+0x112>
ffffffffc02003fc:	00044583          	lbu	a1,0(s0)
ffffffffc0200400:	bf91                	j	ffffffffc0200354 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200402:	45c1                	li	a1,16
ffffffffc0200404:	855a                	mv	a0,s6
ffffffffc0200406:	cc1ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
ffffffffc020040a:	b7f1                	j	ffffffffc02003d6 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020040c:	6582                	ld	a1,0(sp)
ffffffffc020040e:	00002517          	auipc	a0,0x2
ffffffffc0200412:	d3a50513          	addi	a0,a0,-710 # ffffffffc0202148 <commands+0xc8>
ffffffffc0200416:	cb1ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    return 0;
ffffffffc020041a:	b72d                	j	ffffffffc0200344 <kmonitor+0x6a>

ffffffffc020041c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020041c:	1141                	addi	sp,sp,-16
ffffffffc020041e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200420:	02000793          	li	a5,32
ffffffffc0200424:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200428:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200432:	953e                	add	a0,a0,a5
ffffffffc0200434:	1d5010ef          	jal	ra,ffffffffc0201e08 <sbi_set_timer>
}
ffffffffc0200438:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020043a:	00006797          	auipc	a5,0x6
ffffffffc020043e:	fe07bf23          	sd	zero,-2(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200442:	00002517          	auipc	a0,0x2
ffffffffc0200446:	dbe50513          	addi	a0,a0,-578 # ffffffffc0202200 <commands+0x180>
}
ffffffffc020044a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020044c:	c7bff06f          	j	ffffffffc02000c6 <cprintf>

ffffffffc0200450 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200450:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200454:	67e1                	lui	a5,0x18
ffffffffc0200456:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020045a:	953e                	add	a0,a0,a5
ffffffffc020045c:	1ad0106f          	j	ffffffffc0201e08 <sbi_set_timer>

ffffffffc0200460 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200460:	8082                	ret

ffffffffc0200462 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200462:	0ff57513          	andi	a0,a0,255
ffffffffc0200466:	1870106f          	j	ffffffffc0201dec <sbi_console_putchar>

ffffffffc020046a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020046a:	1bb0106f          	j	ffffffffc0201e24 <sbi_console_getchar>

ffffffffc020046e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020046e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200472:	8082                	ret

ffffffffc0200474 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200474:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200478:	8082                	ret

ffffffffc020047a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020047a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020047e:	00000797          	auipc	a5,0x0
ffffffffc0200482:	3ae78793          	addi	a5,a5,942 # ffffffffc020082c <__alltraps>
ffffffffc0200486:	10579073          	csrw	stvec,a5
}
ffffffffc020048a:	8082                	ret

ffffffffc020048c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020048e:	1141                	addi	sp,sp,-16
ffffffffc0200490:	e022                	sd	s0,0(sp)
ffffffffc0200492:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	f1c50513          	addi	a0,a0,-228 # ffffffffc02023b0 <commands+0x330>
void print_regs(struct pushregs *gpr) {
ffffffffc020049c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020049e:	c29ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02004a2:	640c                	ld	a1,8(s0)
ffffffffc02004a4:	00002517          	auipc	a0,0x2
ffffffffc02004a8:	f2450513          	addi	a0,a0,-220 # ffffffffc02023c8 <commands+0x348>
ffffffffc02004ac:	c1bff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004b0:	680c                	ld	a1,16(s0)
ffffffffc02004b2:	00002517          	auipc	a0,0x2
ffffffffc02004b6:	f2e50513          	addi	a0,a0,-210 # ffffffffc02023e0 <commands+0x360>
ffffffffc02004ba:	c0dff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004be:	6c0c                	ld	a1,24(s0)
ffffffffc02004c0:	00002517          	auipc	a0,0x2
ffffffffc02004c4:	f3850513          	addi	a0,a0,-200 # ffffffffc02023f8 <commands+0x378>
ffffffffc02004c8:	bffff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004cc:	700c                	ld	a1,32(s0)
ffffffffc02004ce:	00002517          	auipc	a0,0x2
ffffffffc02004d2:	f4250513          	addi	a0,a0,-190 # ffffffffc0202410 <commands+0x390>
ffffffffc02004d6:	bf1ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004da:	740c                	ld	a1,40(s0)
ffffffffc02004dc:	00002517          	auipc	a0,0x2
ffffffffc02004e0:	f4c50513          	addi	a0,a0,-180 # ffffffffc0202428 <commands+0x3a8>
ffffffffc02004e4:	be3ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004e8:	780c                	ld	a1,48(s0)
ffffffffc02004ea:	00002517          	auipc	a0,0x2
ffffffffc02004ee:	f5650513          	addi	a0,a0,-170 # ffffffffc0202440 <commands+0x3c0>
ffffffffc02004f2:	bd5ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004f6:	7c0c                	ld	a1,56(s0)
ffffffffc02004f8:	00002517          	auipc	a0,0x2
ffffffffc02004fc:	f6050513          	addi	a0,a0,-160 # ffffffffc0202458 <commands+0x3d8>
ffffffffc0200500:	bc7ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200504:	602c                	ld	a1,64(s0)
ffffffffc0200506:	00002517          	auipc	a0,0x2
ffffffffc020050a:	f6a50513          	addi	a0,a0,-150 # ffffffffc0202470 <commands+0x3f0>
ffffffffc020050e:	bb9ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200512:	642c                	ld	a1,72(s0)
ffffffffc0200514:	00002517          	auipc	a0,0x2
ffffffffc0200518:	f7450513          	addi	a0,a0,-140 # ffffffffc0202488 <commands+0x408>
ffffffffc020051c:	babff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200520:	682c                	ld	a1,80(s0)
ffffffffc0200522:	00002517          	auipc	a0,0x2
ffffffffc0200526:	f7e50513          	addi	a0,a0,-130 # ffffffffc02024a0 <commands+0x420>
ffffffffc020052a:	b9dff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020052e:	6c2c                	ld	a1,88(s0)
ffffffffc0200530:	00002517          	auipc	a0,0x2
ffffffffc0200534:	f8850513          	addi	a0,a0,-120 # ffffffffc02024b8 <commands+0x438>
ffffffffc0200538:	b8fff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020053c:	702c                	ld	a1,96(s0)
ffffffffc020053e:	00002517          	auipc	a0,0x2
ffffffffc0200542:	f9250513          	addi	a0,a0,-110 # ffffffffc02024d0 <commands+0x450>
ffffffffc0200546:	b81ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020054a:	742c                	ld	a1,104(s0)
ffffffffc020054c:	00002517          	auipc	a0,0x2
ffffffffc0200550:	f9c50513          	addi	a0,a0,-100 # ffffffffc02024e8 <commands+0x468>
ffffffffc0200554:	b73ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200558:	782c                	ld	a1,112(s0)
ffffffffc020055a:	00002517          	auipc	a0,0x2
ffffffffc020055e:	fa650513          	addi	a0,a0,-90 # ffffffffc0202500 <commands+0x480>
ffffffffc0200562:	b65ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200566:	7c2c                	ld	a1,120(s0)
ffffffffc0200568:	00002517          	auipc	a0,0x2
ffffffffc020056c:	fb050513          	addi	a0,a0,-80 # ffffffffc0202518 <commands+0x498>
ffffffffc0200570:	b57ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200574:	604c                	ld	a1,128(s0)
ffffffffc0200576:	00002517          	auipc	a0,0x2
ffffffffc020057a:	fba50513          	addi	a0,a0,-70 # ffffffffc0202530 <commands+0x4b0>
ffffffffc020057e:	b49ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200582:	644c                	ld	a1,136(s0)
ffffffffc0200584:	00002517          	auipc	a0,0x2
ffffffffc0200588:	fc450513          	addi	a0,a0,-60 # ffffffffc0202548 <commands+0x4c8>
ffffffffc020058c:	b3bff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200590:	684c                	ld	a1,144(s0)
ffffffffc0200592:	00002517          	auipc	a0,0x2
ffffffffc0200596:	fce50513          	addi	a0,a0,-50 # ffffffffc0202560 <commands+0x4e0>
ffffffffc020059a:	b2dff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020059e:	6c4c                	ld	a1,152(s0)
ffffffffc02005a0:	00002517          	auipc	a0,0x2
ffffffffc02005a4:	fd850513          	addi	a0,a0,-40 # ffffffffc0202578 <commands+0x4f8>
ffffffffc02005a8:	b1fff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02005ac:	704c                	ld	a1,160(s0)
ffffffffc02005ae:	00002517          	auipc	a0,0x2
ffffffffc02005b2:	fe250513          	addi	a0,a0,-30 # ffffffffc0202590 <commands+0x510>
ffffffffc02005b6:	b11ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005ba:	744c                	ld	a1,168(s0)
ffffffffc02005bc:	00002517          	auipc	a0,0x2
ffffffffc02005c0:	fec50513          	addi	a0,a0,-20 # ffffffffc02025a8 <commands+0x528>
ffffffffc02005c4:	b03ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005c8:	784c                	ld	a1,176(s0)
ffffffffc02005ca:	00002517          	auipc	a0,0x2
ffffffffc02005ce:	ff650513          	addi	a0,a0,-10 # ffffffffc02025c0 <commands+0x540>
ffffffffc02005d2:	af5ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005d6:	7c4c                	ld	a1,184(s0)
ffffffffc02005d8:	00002517          	auipc	a0,0x2
ffffffffc02005dc:	00050513          	mv	a0,a0
ffffffffc02005e0:	ae7ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005e4:	606c                	ld	a1,192(s0)
ffffffffc02005e6:	00002517          	auipc	a0,0x2
ffffffffc02005ea:	00a50513          	addi	a0,a0,10 # ffffffffc02025f0 <commands+0x570>
ffffffffc02005ee:	ad9ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005f2:	646c                	ld	a1,200(s0)
ffffffffc02005f4:	00002517          	auipc	a0,0x2
ffffffffc02005f8:	01450513          	addi	a0,a0,20 # ffffffffc0202608 <commands+0x588>
ffffffffc02005fc:	acbff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200600:	686c                	ld	a1,208(s0)
ffffffffc0200602:	00002517          	auipc	a0,0x2
ffffffffc0200606:	01e50513          	addi	a0,a0,30 # ffffffffc0202620 <commands+0x5a0>
ffffffffc020060a:	abdff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc020060e:	6c6c                	ld	a1,216(s0)
ffffffffc0200610:	00002517          	auipc	a0,0x2
ffffffffc0200614:	02850513          	addi	a0,a0,40 # ffffffffc0202638 <commands+0x5b8>
ffffffffc0200618:	aafff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020061c:	706c                	ld	a1,224(s0)
ffffffffc020061e:	00002517          	auipc	a0,0x2
ffffffffc0200622:	03250513          	addi	a0,a0,50 # ffffffffc0202650 <commands+0x5d0>
ffffffffc0200626:	aa1ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020062a:	746c                	ld	a1,232(s0)
ffffffffc020062c:	00002517          	auipc	a0,0x2
ffffffffc0200630:	03c50513          	addi	a0,a0,60 # ffffffffc0202668 <commands+0x5e8>
ffffffffc0200634:	a93ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200638:	786c                	ld	a1,240(s0)
ffffffffc020063a:	00002517          	auipc	a0,0x2
ffffffffc020063e:	04650513          	addi	a0,a0,70 # ffffffffc0202680 <commands+0x600>
ffffffffc0200642:	a85ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200648:	6402                	ld	s0,0(sp)
ffffffffc020064a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020064c:	00002517          	auipc	a0,0x2
ffffffffc0200650:	04c50513          	addi	a0,a0,76 # ffffffffc0202698 <commands+0x618>
}
ffffffffc0200654:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200656:	a71ff06f          	j	ffffffffc02000c6 <cprintf>

ffffffffc020065a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	1141                	addi	sp,sp,-16
ffffffffc020065c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200660:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	04e50513          	addi	a0,a0,78 # ffffffffc02026b0 <commands+0x630>
void print_trapframe(struct trapframe *tf) {
ffffffffc020066a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020066c:	a5bff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200670:	8522                	mv	a0,s0
ffffffffc0200672:	e1bff0ef          	jal	ra,ffffffffc020048c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200676:	10043583          	ld	a1,256(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	04e50513          	addi	a0,a0,78 # ffffffffc02026c8 <commands+0x648>
ffffffffc0200682:	a45ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200686:	10843583          	ld	a1,264(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	05650513          	addi	a0,a0,86 # ffffffffc02026e0 <commands+0x660>
ffffffffc0200692:	a35ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200696:	11043583          	ld	a1,272(s0)
ffffffffc020069a:	00002517          	auipc	a0,0x2
ffffffffc020069e:	05e50513          	addi	a0,a0,94 # ffffffffc02026f8 <commands+0x678>
ffffffffc02006a2:	a25ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a6:	11843583          	ld	a1,280(s0)
}
ffffffffc02006aa:	6402                	ld	s0,0(sp)
ffffffffc02006ac:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006ae:	00002517          	auipc	a0,0x2
ffffffffc02006b2:	06250513          	addi	a0,a0,98 # ffffffffc0202710 <commands+0x690>
}
ffffffffc02006b6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006b8:	a0fff06f          	j	ffffffffc02000c6 <cprintf>

ffffffffc02006bc <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006bc:	11853783          	ld	a5,280(a0)
ffffffffc02006c0:	577d                	li	a4,-1
ffffffffc02006c2:	8305                	srli	a4,a4,0x1
ffffffffc02006c4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006c6:	472d                	li	a4,11
ffffffffc02006c8:	0af76163          	bltu	a4,a5,ffffffffc020076a <interrupt_handler+0xae>
ffffffffc02006cc:	00002717          	auipc	a4,0x2
ffffffffc02006d0:	b5070713          	addi	a4,a4,-1200 # ffffffffc020221c <commands+0x19c>
ffffffffc02006d4:	078a                	slli	a5,a5,0x2
ffffffffc02006d6:	97ba                	add	a5,a5,a4
ffffffffc02006d8:	439c                	lw	a5,0(a5)
ffffffffc02006da:	97ba                	add	a5,a5,a4
ffffffffc02006dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006de:	00002517          	auipc	a0,0x2
ffffffffc02006e2:	c5a50513          	addi	a0,a0,-934 # ffffffffc0202338 <commands+0x2b8>
ffffffffc02006e6:	9e1ff06f          	j	ffffffffc02000c6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006ea:	00002517          	auipc	a0,0x2
ffffffffc02006ee:	c2e50513          	addi	a0,a0,-978 # ffffffffc0202318 <commands+0x298>
ffffffffc02006f2:	9d5ff06f          	j	ffffffffc02000c6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006f6:	00002517          	auipc	a0,0x2
ffffffffc02006fa:	be250513          	addi	a0,a0,-1054 # ffffffffc02022d8 <commands+0x258>
ffffffffc02006fe:	9c9ff06f          	j	ffffffffc02000c6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200702:	00002517          	auipc	a0,0x2
ffffffffc0200706:	bf650513          	addi	a0,a0,-1034 # ffffffffc02022f8 <commands+0x278>
ffffffffc020070a:	9bdff06f          	j	ffffffffc02000c6 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc020070e:	00002517          	auipc	a0,0x2
ffffffffc0200712:	c8250513          	addi	a0,a0,-894 # ffffffffc0202390 <commands+0x310>
ffffffffc0200716:	9b1ff06f          	j	ffffffffc02000c6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020071a:	1141                	addi	sp,sp,-16
ffffffffc020071c:	e022                	sd	s0,0(sp)
ffffffffc020071e:	e406                	sd	ra,8(sp)
            ticks++;
ffffffffc0200720:	00006417          	auipc	s0,0x6
ffffffffc0200724:	d1840413          	addi	s0,s0,-744 # ffffffffc0206438 <ticks>
            clock_set_next_event();
ffffffffc0200728:	d29ff0ef          	jal	ra,ffffffffc0200450 <clock_set_next_event>
            ticks++;
ffffffffc020072c:	601c                	ld	a5,0(s0)
ffffffffc020072e:	0785                	addi	a5,a5,1
ffffffffc0200730:	00006717          	auipc	a4,0x6
ffffffffc0200734:	d0f73423          	sd	a5,-760(a4) # ffffffffc0206438 <ticks>
            if(ticks%100==0&&ticks>0) print_ticks();
ffffffffc0200738:	601c                	ld	a5,0(s0)
ffffffffc020073a:	06400713          	li	a4,100
ffffffffc020073e:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200742:	eb99                	bnez	a5,ffffffffc0200758 <interrupt_handler+0x9c>
ffffffffc0200744:	601c                	ld	a5,0(s0)
ffffffffc0200746:	cb89                	beqz	a5,ffffffffc0200758 <interrupt_handler+0x9c>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00002517          	auipc	a0,0x2
ffffffffc0200750:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0202358 <commands+0x2d8>
ffffffffc0200754:	973ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
                if(ticks==1000) {cprintf("The counters = 10,system will shutdown!");sbi_shutdown();}
ffffffffc0200758:	6018                	ld	a4,0(s0)
ffffffffc020075a:	3e800793          	li	a5,1000
ffffffffc020075e:	00f70863          	beq	a4,a5,ffffffffc020076e <interrupt_handler+0xb2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200762:	60a2                	ld	ra,8(sp)
ffffffffc0200764:	6402                	ld	s0,0(sp)
ffffffffc0200766:	0141                	addi	sp,sp,16
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ef1ff06f          	j	ffffffffc020065a <print_trapframe>
                if(ticks==1000) {cprintf("The counters = 10,system will shutdown!");sbi_shutdown();}
ffffffffc020076e:	00002517          	auipc	a0,0x2
ffffffffc0200772:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0202368 <commands+0x2e8>
ffffffffc0200776:	951ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
}
ffffffffc020077a:	6402                	ld	s0,0(sp)
ffffffffc020077c:	60a2                	ld	ra,8(sp)
ffffffffc020077e:	0141                	addi	sp,sp,16
                if(ticks==1000) {cprintf("The counters = 10,system will shutdown!");sbi_shutdown();}
ffffffffc0200780:	6c20106f          	j	ffffffffc0201e42 <sbi_shutdown>

ffffffffc0200784 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200784:	11853783          	ld	a5,280(a0)
ffffffffc0200788:	472d                	li	a4,11
ffffffffc020078a:	02f76863          	bltu	a4,a5,ffffffffc02007ba <exception_handler+0x36>
ffffffffc020078e:	4705                	li	a4,1
ffffffffc0200790:	00f71733          	sll	a4,a4,a5
ffffffffc0200794:	6785                	lui	a5,0x1
ffffffffc0200796:	17cd                	addi	a5,a5,-13
ffffffffc0200798:	8ff9                	and	a5,a5,a4
ffffffffc020079a:	ef99                	bnez	a5,ffffffffc02007b8 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
ffffffffc020079c:	1141                	addi	sp,sp,-16
ffffffffc020079e:	e022                	sd	s0,0(sp)
ffffffffc02007a0:	e406                	sd	ra,8(sp)
ffffffffc02007a2:	00877793          	andi	a5,a4,8
ffffffffc02007a6:	842a                	mv	s0,a0
ffffffffc02007a8:	e3b1                	bnez	a5,ffffffffc02007ec <exception_handler+0x68>
ffffffffc02007aa:	8b11                	andi	a4,a4,4
ffffffffc02007ac:	eb09                	bnez	a4,ffffffffc02007be <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
ffffffffc02007b2:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc02007b4:	ea7ff06f          	j	ffffffffc020065a <print_trapframe>
ffffffffc02007b8:	8082                	ret
ffffffffc02007ba:	ea1ff06f          	j	ffffffffc020065a <print_trapframe>
            cprintf("Illegal instruction\n");
ffffffffc02007be:	00002517          	auipc	a0,0x2
ffffffffc02007c2:	a9250513          	addi	a0,a0,-1390 # ffffffffc0202250 <commands+0x1d0>
ffffffffc02007c6:	901ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
            cprintf("Illegal instruction caught at 0x: 0x%08x\n", tf->epc);
ffffffffc02007ca:	10843583          	ld	a1,264(s0)
ffffffffc02007ce:	00002517          	auipc	a0,0x2
ffffffffc02007d2:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0202268 <commands+0x1e8>
ffffffffc02007d6:	8f1ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
            tf->epc+=4;
ffffffffc02007da:	10843783          	ld	a5,264(s0)
}
ffffffffc02007de:	60a2                	ld	ra,8(sp)
            tf->epc+=4;
ffffffffc02007e0:	0791                	addi	a5,a5,4
ffffffffc02007e2:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007e6:	6402                	ld	s0,0(sp)
ffffffffc02007e8:	0141                	addi	sp,sp,16
ffffffffc02007ea:	8082                	ret
            cprintf("Exception type: breakpoint\n");
ffffffffc02007ec:	00002517          	auipc	a0,0x2
ffffffffc02007f0:	aac50513          	addi	a0,a0,-1364 # ffffffffc0202298 <commands+0x218>
ffffffffc02007f4:	8d3ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
            cprintf("ebreak caught at 0x: 0x%08x\n", tf->epc);
ffffffffc02007f8:	10843583          	ld	a1,264(s0)
ffffffffc02007fc:	00002517          	auipc	a0,0x2
ffffffffc0200800:	abc50513          	addi	a0,a0,-1348 # ffffffffc02022b8 <commands+0x238>
ffffffffc0200804:	8c3ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
            tf->epc+=4;             
ffffffffc0200808:	10843783          	ld	a5,264(s0)
}
ffffffffc020080c:	60a2                	ld	ra,8(sp)
            tf->epc+=4;             
ffffffffc020080e:	0791                	addi	a5,a5,4
ffffffffc0200810:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200814:	6402                	ld	s0,0(sp)
ffffffffc0200816:	0141                	addi	sp,sp,16
ffffffffc0200818:	8082                	ret

ffffffffc020081a <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020081a:	11853783          	ld	a5,280(a0)
ffffffffc020081e:	0007c463          	bltz	a5,ffffffffc0200826 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200822:	f63ff06f          	j	ffffffffc0200784 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200826:	e97ff06f          	j	ffffffffc02006bc <interrupt_handler>
	...

ffffffffc020082c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020082c:	14011073          	csrw	sscratch,sp
ffffffffc0200830:	712d                	addi	sp,sp,-288
ffffffffc0200832:	e002                	sd	zero,0(sp)
ffffffffc0200834:	e406                	sd	ra,8(sp)
ffffffffc0200836:	ec0e                	sd	gp,24(sp)
ffffffffc0200838:	f012                	sd	tp,32(sp)
ffffffffc020083a:	f416                	sd	t0,40(sp)
ffffffffc020083c:	f81a                	sd	t1,48(sp)
ffffffffc020083e:	fc1e                	sd	t2,56(sp)
ffffffffc0200840:	e0a2                	sd	s0,64(sp)
ffffffffc0200842:	e4a6                	sd	s1,72(sp)
ffffffffc0200844:	e8aa                	sd	a0,80(sp)
ffffffffc0200846:	ecae                	sd	a1,88(sp)
ffffffffc0200848:	f0b2                	sd	a2,96(sp)
ffffffffc020084a:	f4b6                	sd	a3,104(sp)
ffffffffc020084c:	f8ba                	sd	a4,112(sp)
ffffffffc020084e:	fcbe                	sd	a5,120(sp)
ffffffffc0200850:	e142                	sd	a6,128(sp)
ffffffffc0200852:	e546                	sd	a7,136(sp)
ffffffffc0200854:	e94a                	sd	s2,144(sp)
ffffffffc0200856:	ed4e                	sd	s3,152(sp)
ffffffffc0200858:	f152                	sd	s4,160(sp)
ffffffffc020085a:	f556                	sd	s5,168(sp)
ffffffffc020085c:	f95a                	sd	s6,176(sp)
ffffffffc020085e:	fd5e                	sd	s7,184(sp)
ffffffffc0200860:	e1e2                	sd	s8,192(sp)
ffffffffc0200862:	e5e6                	sd	s9,200(sp)
ffffffffc0200864:	e9ea                	sd	s10,208(sp)
ffffffffc0200866:	edee                	sd	s11,216(sp)
ffffffffc0200868:	f1f2                	sd	t3,224(sp)
ffffffffc020086a:	f5f6                	sd	t4,232(sp)
ffffffffc020086c:	f9fa                	sd	t5,240(sp)
ffffffffc020086e:	fdfe                	sd	t6,248(sp)
ffffffffc0200870:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200874:	100024f3          	csrr	s1,sstatus
ffffffffc0200878:	14102973          	csrr	s2,sepc
ffffffffc020087c:	143029f3          	csrr	s3,stval
ffffffffc0200880:	14202a73          	csrr	s4,scause
ffffffffc0200884:	e822                	sd	s0,16(sp)
ffffffffc0200886:	e226                	sd	s1,256(sp)
ffffffffc0200888:	e64a                	sd	s2,264(sp)
ffffffffc020088a:	ea4e                	sd	s3,272(sp)
ffffffffc020088c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc020088e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200890:	f8bff0ef          	jal	ra,ffffffffc020081a <trap>

ffffffffc0200894 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200894:	6492                	ld	s1,256(sp)
ffffffffc0200896:	6932                	ld	s2,264(sp)
ffffffffc0200898:	10049073          	csrw	sstatus,s1
ffffffffc020089c:	14191073          	csrw	sepc,s2
ffffffffc02008a0:	60a2                	ld	ra,8(sp)
ffffffffc02008a2:	61e2                	ld	gp,24(sp)
ffffffffc02008a4:	7202                	ld	tp,32(sp)
ffffffffc02008a6:	72a2                	ld	t0,40(sp)
ffffffffc02008a8:	7342                	ld	t1,48(sp)
ffffffffc02008aa:	73e2                	ld	t2,56(sp)
ffffffffc02008ac:	6406                	ld	s0,64(sp)
ffffffffc02008ae:	64a6                	ld	s1,72(sp)
ffffffffc02008b0:	6546                	ld	a0,80(sp)
ffffffffc02008b2:	65e6                	ld	a1,88(sp)
ffffffffc02008b4:	7606                	ld	a2,96(sp)
ffffffffc02008b6:	76a6                	ld	a3,104(sp)
ffffffffc02008b8:	7746                	ld	a4,112(sp)
ffffffffc02008ba:	77e6                	ld	a5,120(sp)
ffffffffc02008bc:	680a                	ld	a6,128(sp)
ffffffffc02008be:	68aa                	ld	a7,136(sp)
ffffffffc02008c0:	694a                	ld	s2,144(sp)
ffffffffc02008c2:	69ea                	ld	s3,152(sp)
ffffffffc02008c4:	7a0a                	ld	s4,160(sp)
ffffffffc02008c6:	7aaa                	ld	s5,168(sp)
ffffffffc02008c8:	7b4a                	ld	s6,176(sp)
ffffffffc02008ca:	7bea                	ld	s7,184(sp)
ffffffffc02008cc:	6c0e                	ld	s8,192(sp)
ffffffffc02008ce:	6cae                	ld	s9,200(sp)
ffffffffc02008d0:	6d4e                	ld	s10,208(sp)
ffffffffc02008d2:	6dee                	ld	s11,216(sp)
ffffffffc02008d4:	7e0e                	ld	t3,224(sp)
ffffffffc02008d6:	7eae                	ld	t4,232(sp)
ffffffffc02008d8:	7f4e                	ld	t5,240(sp)
ffffffffc02008da:	7fee                	ld	t6,248(sp)
ffffffffc02008dc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02008de:	10200073          	sret

ffffffffc02008e2 <slub_cache_alloc>:
    list_init(&(cache->full));
    list_init(&(cache->partial));
    list_init(&(cache->free));
}

void *slub_cache_alloc(slub_cache_t *cache) {
ffffffffc02008e2:	1101                	addi	sp,sp,-32
ffffffffc02008e4:	e822                	sd	s0,16(sp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc02008e6:	7900                	ld	s0,48(a0)
ffffffffc02008e8:	e426                	sd	s1,8(sp)
ffffffffc02008ea:	ec06                	sd	ra,24(sp)
    if (list_empty(&(cache->partial))) {
ffffffffc02008ec:	02850793          	addi	a5,a0,40
void *slub_cache_alloc(slub_cache_t *cache) {
ffffffffc02008f0:	84aa                	mv	s1,a0
    if (list_empty(&(cache->partial))) {
ffffffffc02008f2:	08f40e63          	beq	s0,a5,ffffffffc020098e <slub_cache_alloc+0xac>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008f6:	00006797          	auipc	a5,0x6
ffffffffc02008fa:	b6278793          	addi	a5,a5,-1182 # ffffffffc0206458 <pages>
ffffffffc02008fe:	639c                	ld	a5,0(a5)
        }
        new_page->property = 0; // 初始时没有对象使用
        list_add(&(cache->partial), &(new_page->page_link));
    }

    struct Page *page = le2page(list_next(&(cache->partial)), page_link);
ffffffffc0200900:	fe840693          	addi	a3,s0,-24
    void *obj = (void *)(KADDR(page2pa(page)) + cache->obj_size * page->property);
ffffffffc0200904:	00006717          	auipc	a4,0x6
ffffffffc0200908:	b1c70713          	addi	a4,a4,-1252 # ffffffffc0206420 <npage>
ffffffffc020090c:	8e9d                	sub	a3,a3,a5
ffffffffc020090e:	00002797          	auipc	a5,0x2
ffffffffc0200912:	e1a78793          	addi	a5,a5,-486 # ffffffffc0202728 <commands+0x6a8>
ffffffffc0200916:	639c                	ld	a5,0(a5)
ffffffffc0200918:	868d                	srai	a3,a3,0x3
ffffffffc020091a:	6318                	ld	a4,0(a4)
ffffffffc020091c:	02f686b3          	mul	a3,a3,a5
ffffffffc0200920:	00002797          	auipc	a5,0x2
ffffffffc0200924:	64078793          	addi	a5,a5,1600 # ffffffffc0202f60 <nbase>
ffffffffc0200928:	6388                	ld	a0,0(a5)
ffffffffc020092a:	57fd                	li	a5,-1
ffffffffc020092c:	83b1                	srli	a5,a5,0xc
ffffffffc020092e:	96aa                	add	a3,a3,a0
ffffffffc0200930:	8ff5                	and	a5,a5,a3

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200932:	06b2                	slli	a3,a3,0xc
ffffffffc0200934:	06e7fe63          	bleu	a4,a5,ffffffffc02009b0 <slub_cache_alloc+0xce>
ffffffffc0200938:	ff842503          	lw	a0,-8(s0)
ffffffffc020093c:	6098                	ld	a4,0(s1)
ffffffffc020093e:	00006597          	auipc	a1,0x6
ffffffffc0200942:	b1258593          	addi	a1,a1,-1262 # ffffffffc0206450 <va_pa_offset>

    page->property++;
ffffffffc0200946:	0015061b          	addiw	a2,a0,1
    if (page->property * cache->obj_size >= PGSIZE) {
ffffffffc020094a:	02061793          	slli	a5,a2,0x20
    void *obj = (void *)(KADDR(page2pa(page)) + cache->obj_size * page->property);
ffffffffc020094e:	1502                	slli	a0,a0,0x20
ffffffffc0200950:	9101                	srli	a0,a0,0x20
    if (page->property * cache->obj_size >= PGSIZE) {
ffffffffc0200952:	9381                	srli	a5,a5,0x20
    void *obj = (void *)(KADDR(page2pa(page)) + cache->obj_size * page->property);
ffffffffc0200954:	02e50533          	mul	a0,a0,a4
ffffffffc0200958:	0005b803          	ld	a6,0(a1)
    if (page->property * cache->obj_size >= PGSIZE) {
ffffffffc020095c:	6585                	lui	a1,0x1
    page->property++;
ffffffffc020095e:	fec42c23          	sw	a2,-8(s0)
    void *obj = (void *)(KADDR(page2pa(page)) + cache->obj_size * page->property);
ffffffffc0200962:	96c2                	add	a3,a3,a6
    if (page->property * cache->obj_size >= PGSIZE) {
ffffffffc0200964:	02e787b3          	mul	a5,a5,a4
    void *obj = (void *)(KADDR(page2pa(page)) + cache->obj_size * page->property);
ffffffffc0200968:	9536                	add	a0,a0,a3
    if (page->property * cache->obj_size >= PGSIZE) {
ffffffffc020096a:	00b7ed63          	bltu	a5,a1,ffffffffc0200984 <slub_cache_alloc+0xa2>
    __list_del(listelm->prev, listelm->next);
ffffffffc020096e:	6014                	ld	a3,0(s0)
ffffffffc0200970:	6418                	ld	a4,8(s0)
        list_del(&(page->page_link));
        list_add(&(cache->full), &(page->page_link));
ffffffffc0200972:	01848613          	addi	a2,s1,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200976:	e698                	sd	a4,8(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200978:	709c                	ld	a5,32(s1)
    next->prev = prev;
ffffffffc020097a:	e314                	sd	a3,0(a4)
    prev->next = next->prev = elm;
ffffffffc020097c:	e380                	sd	s0,0(a5)
ffffffffc020097e:	f080                	sd	s0,32(s1)
    elm->next = next;
ffffffffc0200980:	e41c                	sd	a5,8(s0)
    elm->prev = prev;
ffffffffc0200982:	e010                	sd	a2,0(s0)
    }
    return obj;
}
ffffffffc0200984:	60e2                	ld	ra,24(sp)
ffffffffc0200986:	6442                	ld	s0,16(sp)
ffffffffc0200988:	64a2                	ld	s1,8(sp)
ffffffffc020098a:	6105                	addi	sp,sp,32
ffffffffc020098c:	8082                	ret
        struct Page *new_page = alloc_pages(1); // 从物理内存管理器中分配一页
ffffffffc020098e:	4505                	li	a0,1
ffffffffc0200990:	2a6000ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
        if (!new_page) {
ffffffffc0200994:	cd01                	beqz	a0,ffffffffc02009ac <slub_cache_alloc+0xca>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200996:	789c                	ld	a5,48(s1)
        list_add(&(cache->partial), &(new_page->page_link));
ffffffffc0200998:	01850713          	addi	a4,a0,24
        new_page->property = 0; // 初始时没有对象使用
ffffffffc020099c:	00052823          	sw	zero,16(a0)
    prev->next = next->prev = elm;
ffffffffc02009a0:	e398                	sd	a4,0(a5)
ffffffffc02009a2:	f898                	sd	a4,48(s1)
    elm->next = next;
ffffffffc02009a4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02009a6:	ed00                	sd	s0,24(a0)
ffffffffc02009a8:	7880                	ld	s0,48(s1)
ffffffffc02009aa:	b7b1                	j	ffffffffc02008f6 <slub_cache_alloc+0x14>
            return NULL; // 内存不足
ffffffffc02009ac:	4501                	li	a0,0
ffffffffc02009ae:	bfd9                	j	ffffffffc0200984 <slub_cache_alloc+0xa2>
    void *obj = (void *)(KADDR(page2pa(page)) + cache->obj_size * page->property);
ffffffffc02009b0:	00002617          	auipc	a2,0x2
ffffffffc02009b4:	d8060613          	addi	a2,a2,-640 # ffffffffc0202730 <commands+0x6b0>
ffffffffc02009b8:	45f1                	li	a1,28
ffffffffc02009ba:	00002517          	auipc	a0,0x2
ffffffffc02009be:	d9e50513          	addi	a0,a0,-610 # ffffffffc0202758 <commands+0x6d8>
ffffffffc02009c2:	f8cff0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc02009c6 <slub_cache_free>:

void slub_cache_free(slub_cache_t *cache, void *obj) {
ffffffffc02009c6:	1141                	addi	sp,sp,-16
ffffffffc02009c8:	e406                	sd	ra,8(sp)
    struct Page *page = pa2page(PADDR((uintptr_t)obj));
ffffffffc02009ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02009ce:	0af5e763          	bltu	a1,a5,ffffffffc0200a7c <slub_cache_free+0xb6>
ffffffffc02009d2:	00006797          	auipc	a5,0x6
ffffffffc02009d6:	a7e78793          	addi	a5,a5,-1410 # ffffffffc0206450 <va_pa_offset>
ffffffffc02009da:	6394                	ld	a3,0(a5)
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009dc:	00006797          	auipc	a5,0x6
ffffffffc02009e0:	a4478793          	addi	a5,a5,-1468 # ffffffffc0206420 <npage>
ffffffffc02009e4:	639c                	ld	a5,0(a5)
ffffffffc02009e6:	8d95                	sub	a1,a1,a3
ffffffffc02009e8:	81b1                	srli	a1,a1,0xc
ffffffffc02009ea:	0af5f663          	bleu	a5,a1,ffffffffc0200a96 <slub_cache_free+0xd0>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02009ee:	00002717          	auipc	a4,0x2
ffffffffc02009f2:	57270713          	addi	a4,a4,1394 # ffffffffc0202f60 <nbase>
ffffffffc02009f6:	6318                	ld	a4,0(a4)
ffffffffc02009f8:	00006797          	auipc	a5,0x6
ffffffffc02009fc:	a6078793          	addi	a5,a5,-1440 # ffffffffc0206458 <pages>
ffffffffc0200a00:	639c                	ld	a5,0(a5)
ffffffffc0200a02:	8d99                	sub	a1,a1,a4
ffffffffc0200a04:	00259713          	slli	a4,a1,0x2
ffffffffc0200a08:	95ba                	add	a1,a1,a4
ffffffffc0200a0a:	058e                	slli	a1,a1,0x3
ffffffffc0200a0c:	97ae                	add	a5,a5,a1
    if (!page) {
ffffffffc0200a0e:	cf99                	beqz	a5,ffffffffc0200a2c <slub_cache_free+0x66>
        return; // 无效的对象
    }

    page->property--;
ffffffffc0200a10:	4b98                	lw	a4,16(a5)
    if (page->property * cache->obj_size == PGSIZE - cache->obj_size) {
ffffffffc0200a12:	610c                	ld	a1,0(a0)
ffffffffc0200a14:	6685                	lui	a3,0x1
    page->property--;
ffffffffc0200a16:	377d                	addiw	a4,a4,-1
    if (page->property * cache->obj_size == PGSIZE - cache->obj_size) {
ffffffffc0200a18:	02071613          	slli	a2,a4,0x20
ffffffffc0200a1c:	9201                	srli	a2,a2,0x20
ffffffffc0200a1e:	02b60633          	mul	a2,a2,a1
    page->property--;
ffffffffc0200a22:	cb98                	sw	a4,16(a5)
    if (page->property * cache->obj_size == PGSIZE - cache->obj_size) {
ffffffffc0200a24:	8e8d                	sub	a3,a3,a1
ffffffffc0200a26:	00d60663          	beq	a2,a3,ffffffffc0200a32 <slub_cache_free+0x6c>
        list_del(&(page->page_link));
        list_add(&(cache->partial), &(page->page_link));
    } else if (page->property == 0) {
ffffffffc0200a2a:	c70d                	beqz	a4,ffffffffc0200a54 <slub_cache_free+0x8e>
        list_del(&(page->page_link));
        list_add(&(cache->free), &(page->page_link));
        free_pages(page, 1);
    }
}
ffffffffc0200a2c:	60a2                	ld	ra,8(sp)
ffffffffc0200a2e:	0141                	addi	sp,sp,16
ffffffffc0200a30:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a32:	6f8c                	ld	a1,24(a5)
ffffffffc0200a34:	7390                	ld	a2,32(a5)
        list_add(&(cache->partial), &(page->page_link));
ffffffffc0200a36:	01878693          	addi	a3,a5,24
}
ffffffffc0200a3a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0200a3c:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a3e:	7918                	ld	a4,48(a0)
    next->prev = prev;
ffffffffc0200a40:	e20c                	sd	a1,0(a2)
        list_add(&(cache->partial), &(page->page_link));
ffffffffc0200a42:	02850813          	addi	a6,a0,40
    prev->next = next->prev = elm;
ffffffffc0200a46:	e314                	sd	a3,0(a4)
ffffffffc0200a48:	f914                	sd	a3,48(a0)
    elm->next = next;
ffffffffc0200a4a:	f398                	sd	a4,32(a5)
    elm->prev = prev;
ffffffffc0200a4c:	0107bc23          	sd	a6,24(a5)
}
ffffffffc0200a50:	0141                	addi	sp,sp,16
ffffffffc0200a52:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a54:	6f8c                	ld	a1,24(a5)
ffffffffc0200a56:	7390                	ld	a2,32(a5)
        list_add(&(cache->free), &(page->page_link));
ffffffffc0200a58:	01878693          	addi	a3,a5,24
ffffffffc0200a5c:	00850813          	addi	a6,a0,8
    prev->next = next;
ffffffffc0200a60:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a62:	6918                	ld	a4,16(a0)
    next->prev = prev;
ffffffffc0200a64:	e20c                	sd	a1,0(a2)
}
ffffffffc0200a66:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200a68:	e314                	sd	a3,0(a4)
ffffffffc0200a6a:	e914                	sd	a3,16(a0)
    elm->next = next;
ffffffffc0200a6c:	f398                	sd	a4,32(a5)
    elm->prev = prev;
ffffffffc0200a6e:	0107bc23          	sd	a6,24(a5)
        free_pages(page, 1);
ffffffffc0200a72:	4585                	li	a1,1
ffffffffc0200a74:	853e                	mv	a0,a5
}
ffffffffc0200a76:	0141                	addi	sp,sp,16
        free_pages(page, 1);
ffffffffc0200a78:	2020006f          	j	ffffffffc0200c7a <free_pages>
    struct Page *page = pa2page(PADDR((uintptr_t)obj));
ffffffffc0200a7c:	86ae                	mv	a3,a1
ffffffffc0200a7e:	00002617          	auipc	a2,0x2
ffffffffc0200a82:	cf260613          	addi	a2,a2,-782 # ffffffffc0202770 <commands+0x6f0>
ffffffffc0200a86:	02700593          	li	a1,39
ffffffffc0200a8a:	00002517          	auipc	a0,0x2
ffffffffc0200a8e:	cce50513          	addi	a0,a0,-818 # ffffffffc0202758 <commands+0x6d8>
ffffffffc0200a92:	ebcff0ef          	jal	ra,ffffffffc020014e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200a96:	00002617          	auipc	a2,0x2
ffffffffc0200a9a:	d0260613          	addi	a2,a2,-766 # ffffffffc0202798 <commands+0x718>
ffffffffc0200a9e:	06b00593          	li	a1,107
ffffffffc0200aa2:	00002517          	auipc	a0,0x2
ffffffffc0200aa6:	d1650513          	addi	a0,a0,-746 # ffffffffc02027b8 <commands+0x738>
ffffffffc0200aaa:	ea4ff0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc0200aae <test_slub_cache>:
void test_slub_cache() {
ffffffffc0200aae:	c7010113          	addi	sp,sp,-912
    cprintf("Testing SLUB cache...\n");
ffffffffc0200ab2:	00002517          	auipc	a0,0x2
ffffffffc0200ab6:	d1650513          	addi	a0,a0,-746 # ffffffffc02027c8 <commands+0x748>
void test_slub_cache() {
ffffffffc0200aba:	38813023          	sd	s0,896(sp)
ffffffffc0200abe:	36913c23          	sd	s1,888(sp)
ffffffffc0200ac2:	37213823          	sd	s2,880(sp)
ffffffffc0200ac6:	38113423          	sd	ra,904(sp)
ffffffffc0200aca:	37313423          	sd	s3,872(sp)
ffffffffc0200ace:	37413023          	sd	s4,864(sp)
    cprintf("Testing SLUB cache...\n");
ffffffffc0200ad2:	df4ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cache->obj_size = size;
ffffffffc0200ad6:	4791                	li	a5,4
ffffffffc0200ad8:	e43e                	sd	a5,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0200ada:	101c                	addi	a5,sp,32
ffffffffc0200adc:	f43e                	sd	a5,40(sp)
ffffffffc0200ade:	f03e                	sd	a5,32(sp)
ffffffffc0200ae0:	181c                	addi	a5,sp,48
ffffffffc0200ae2:	0084                	addi	s1,sp,64
ffffffffc0200ae4:	fc3e                	sd	a5,56(sp)
ffffffffc0200ae6:	f83e                	sd	a5,48(sp)
ffffffffc0200ae8:	081c                	addi	a5,sp,16
ffffffffc0200aea:	ec3e                	sd	a5,24(sp)
ffffffffc0200aec:	e83e                	sd	a5,16(sp)
    slub_cache_t cache;
    slub_cache_init(&cache, sizeof(int));

    // 1. 分配100个对象
    void *objs[100];
    for (int i = 0; i < 100; i++) {
ffffffffc0200aee:	36010913          	addi	s2,sp,864
ffffffffc0200af2:	8426                	mv	s0,s1
        objs[i] = slub_cache_alloc(&cache);
ffffffffc0200af4:	0028                	addi	a0,sp,8
ffffffffc0200af6:	dedff0ef          	jal	ra,ffffffffc02008e2 <slub_cache_alloc>
ffffffffc0200afa:	e008                	sd	a0,0(s0)
        assert(objs[i] != NULL);  // 确保对象不为NULL
ffffffffc0200afc:	0e050d63          	beqz	a0,ffffffffc0200bf6 <test_slub_cache+0x148>
ffffffffc0200b00:	0421                	addi	s0,s0,8
    for (int i = 0; i < 100; i++) {
ffffffffc0200b02:	ff2419e3          	bne	s0,s2,ffffffffc0200af4 <test_slub_cache+0x46>
    }
    cprintf("100个对象分配成功\n");
ffffffffc0200b06:	00002517          	auipc	a0,0x2
ffffffffc0200b0a:	d0250513          	addi	a0,a0,-766 # ffffffffc0202808 <commands+0x788>
ffffffffc0200b0e:	db8ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    // 2. 检查地址是否不重叠
    for (int i = 0; i < 100; i++) {
        for (int j = i + 1; j < 100; j++) {
ffffffffc0200b12:	6686                	ld	a3,64(sp)
ffffffffc0200b14:	04810993          	addi	s3,sp,72
    cprintf("100个对象分配成功\n");
ffffffffc0200b18:	85ce                	mv	a1,s3
ffffffffc0200b1a:	4505                	li	a0,1
ffffffffc0200b1c:	31848613          	addi	a2,s1,792
        for (int j = i + 1; j < 100; j++) {
ffffffffc0200b20:	06400893          	li	a7,100
            assert(objs[i] != objs[j]);
ffffffffc0200b24:	0005b803          	ld	a6,0(a1) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0200b28:	01068963          	beq	a3,a6,ffffffffc0200b3a <test_slub_cache+0x8c>
ffffffffc0200b2c:	87ae                	mv	a5,a1
        for (int j = i + 1; j < 100; j++) {
ffffffffc0200b2e:	02c78663          	beq	a5,a2,ffffffffc0200b5a <test_slub_cache+0xac>
            assert(objs[i] != objs[j]);
ffffffffc0200b32:	07a1                	addi	a5,a5,8
ffffffffc0200b34:	6398                	ld	a4,0(a5)
ffffffffc0200b36:	fed71ce3          	bne	a4,a3,ffffffffc0200b2e <test_slub_cache+0x80>
ffffffffc0200b3a:	00002697          	auipc	a3,0x2
ffffffffc0200b3e:	cee68693          	addi	a3,a3,-786 # ffffffffc0202828 <commands+0x7a8>
ffffffffc0200b42:	00002617          	auipc	a2,0x2
ffffffffc0200b46:	cae60613          	addi	a2,a2,-850 # ffffffffc02027f0 <commands+0x770>
ffffffffc0200b4a:	04600593          	li	a1,70
ffffffffc0200b4e:	00002517          	auipc	a0,0x2
ffffffffc0200b52:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0202758 <commands+0x6d8>
ffffffffc0200b56:	df8ff0ef          	jal	ra,ffffffffc020014e <__panic>
        for (int j = i + 1; j < 100; j++) {
ffffffffc0200b5a:	0505                	addi	a0,a0,1
ffffffffc0200b5c:	05a1                	addi	a1,a1,8
ffffffffc0200b5e:	86c2                	mv	a3,a6
ffffffffc0200b60:	fd1512e3          	bne	a0,a7,ffffffffc0200b24 <test_slub_cache+0x76>
        }
    }
    cprintf("位置不重叠成功\n");
ffffffffc0200b64:	00002517          	auipc	a0,0x2
ffffffffc0200b68:	cdc50513          	addi	a0,a0,-804 # ffffffffc0202840 <commands+0x7c0>
ffffffffc0200b6c:	d5aff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    // 3. 释放奇数索引的对象
    for (int i = 1; i < 100; i += 2) {
ffffffffc0200b70:	32848a13          	addi	s4,s1,808
    cprintf("位置不重叠成功\n");
ffffffffc0200b74:	844e                	mv	s0,s3
        slub_cache_free(&cache, objs[i]);
ffffffffc0200b76:	600c                	ld	a1,0(s0)
ffffffffc0200b78:	0028                	addi	a0,sp,8
ffffffffc0200b7a:	0441                	addi	s0,s0,16
ffffffffc0200b7c:	e4bff0ef          	jal	ra,ffffffffc02009c6 <slub_cache_free>
        objs[i] = NULL;
ffffffffc0200b80:	fe043823          	sd	zero,-16(s0)
    for (int i = 1; i < 100; i += 2) {
ffffffffc0200b84:	ff4419e3          	bne	s0,s4,ffffffffc0200b76 <test_slub_cache+0xc8>
    }
    cprintf("释放奇数索引成功\n");
ffffffffc0200b88:	00002517          	auipc	a0,0x2
ffffffffc0200b8c:	cd050513          	addi	a0,a0,-816 # ffffffffc0202858 <commands+0x7d8>
ffffffffc0200b90:	d36ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    // 4. 重新分配50个对象，这应该会利用先前释放的对象的空间
    for (int i = 1; i < 100; i += 2) {
        objs[i] = slub_cache_alloc(&cache);
ffffffffc0200b94:	0028                	addi	a0,sp,8
ffffffffc0200b96:	d4dff0ef          	jal	ra,ffffffffc02008e2 <slub_cache_alloc>
ffffffffc0200b9a:	00a9b023          	sd	a0,0(s3)
        assert(objs[i] != NULL);
ffffffffc0200b9e:	cd25                	beqz	a0,ffffffffc0200c16 <test_slub_cache+0x168>
ffffffffc0200ba0:	09c1                	addi	s3,s3,16
    for (int i = 1; i < 100; i += 2) {
ffffffffc0200ba2:	ff4999e3          	bne	s3,s4,ffffffffc0200b94 <test_slub_cache+0xe6>
    }
    cprintf("重新分配成功\n");
ffffffffc0200ba6:	00002517          	auipc	a0,0x2
ffffffffc0200baa:	cd250513          	addi	a0,a0,-814 # ffffffffc0202878 <commands+0x7f8>
ffffffffc0200bae:	d18ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    // 5. 释放所有对象
    for (int i = 0; i < 100; i++) {
        slub_cache_free(&cache, objs[i]);
ffffffffc0200bb2:	608c                	ld	a1,0(s1)
ffffffffc0200bb4:	0028                	addi	a0,sp,8
ffffffffc0200bb6:	04a1                	addi	s1,s1,8
ffffffffc0200bb8:	e0fff0ef          	jal	ra,ffffffffc02009c6 <slub_cache_free>
    for (int i = 0; i < 100; i++) {
ffffffffc0200bbc:	ff249be3          	bne	s1,s2,ffffffffc0200bb2 <test_slub_cache+0x104>
    }
    cprintf("释放成功\n");
ffffffffc0200bc0:	00002517          	auipc	a0,0x2
ffffffffc0200bc4:	cd050513          	addi	a0,a0,-816 # ffffffffc0202890 <commands+0x810>
ffffffffc0200bc8:	cfeff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("SLUB cache test passed!\n");
ffffffffc0200bcc:	00002517          	auipc	a0,0x2
ffffffffc0200bd0:	cd450513          	addi	a0,a0,-812 # ffffffffc02028a0 <commands+0x820>
ffffffffc0200bd4:	cf2ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
}
ffffffffc0200bd8:	38813083          	ld	ra,904(sp)
ffffffffc0200bdc:	38013403          	ld	s0,896(sp)
ffffffffc0200be0:	37813483          	ld	s1,888(sp)
ffffffffc0200be4:	37013903          	ld	s2,880(sp)
ffffffffc0200be8:	36813983          	ld	s3,872(sp)
ffffffffc0200bec:	36013a03          	ld	s4,864(sp)
ffffffffc0200bf0:	39010113          	addi	sp,sp,912
ffffffffc0200bf4:	8082                	ret
        assert(objs[i] != NULL);  // 确保对象不为NULL
ffffffffc0200bf6:	00002697          	auipc	a3,0x2
ffffffffc0200bfa:	bea68693          	addi	a3,a3,-1046 # ffffffffc02027e0 <commands+0x760>
ffffffffc0200bfe:	00002617          	auipc	a2,0x2
ffffffffc0200c02:	bf260613          	addi	a2,a2,-1038 # ffffffffc02027f0 <commands+0x770>
ffffffffc0200c06:	04000593          	li	a1,64
ffffffffc0200c0a:	00002517          	auipc	a0,0x2
ffffffffc0200c0e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0202758 <commands+0x6d8>
ffffffffc0200c12:	d3cff0ef          	jal	ra,ffffffffc020014e <__panic>
        assert(objs[i] != NULL);
ffffffffc0200c16:	00002697          	auipc	a3,0x2
ffffffffc0200c1a:	bca68693          	addi	a3,a3,-1078 # ffffffffc02027e0 <commands+0x760>
ffffffffc0200c1e:	00002617          	auipc	a2,0x2
ffffffffc0200c22:	bd260613          	addi	a2,a2,-1070 # ffffffffc02027f0 <commands+0x770>
ffffffffc0200c26:	05300593          	li	a1,83
ffffffffc0200c2a:	00002517          	auipc	a0,0x2
ffffffffc0200c2e:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0202758 <commands+0x6d8>
ffffffffc0200c32:	d1cff0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc0200c36 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c36:	100027f3          	csrr	a5,sstatus
ffffffffc0200c3a:	8b89                	andi	a5,a5,2
ffffffffc0200c3c:	eb89                	bnez	a5,ffffffffc0200c4e <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200c3e:	00006797          	auipc	a5,0x6
ffffffffc0200c42:	80a78793          	addi	a5,a5,-2038 # ffffffffc0206448 <pmm_manager>
ffffffffc0200c46:	639c                	ld	a5,0(a5)
ffffffffc0200c48:	0187b303          	ld	t1,24(a5)
ffffffffc0200c4c:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200c4e:	1141                	addi	sp,sp,-16
ffffffffc0200c50:	e406                	sd	ra,8(sp)
ffffffffc0200c52:	e022                	sd	s0,0(sp)
ffffffffc0200c54:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200c56:	81fff0ef          	jal	ra,ffffffffc0200474 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200c5a:	00005797          	auipc	a5,0x5
ffffffffc0200c5e:	7ee78793          	addi	a5,a5,2030 # ffffffffc0206448 <pmm_manager>
ffffffffc0200c62:	639c                	ld	a5,0(a5)
ffffffffc0200c64:	8522                	mv	a0,s0
ffffffffc0200c66:	6f9c                	ld	a5,24(a5)
ffffffffc0200c68:	9782                	jalr	a5
ffffffffc0200c6a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200c6c:	803ff0ef          	jal	ra,ffffffffc020046e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200c70:	8522                	mv	a0,s0
ffffffffc0200c72:	60a2                	ld	ra,8(sp)
ffffffffc0200c74:	6402                	ld	s0,0(sp)
ffffffffc0200c76:	0141                	addi	sp,sp,16
ffffffffc0200c78:	8082                	ret

ffffffffc0200c7a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c7a:	100027f3          	csrr	a5,sstatus
ffffffffc0200c7e:	8b89                	andi	a5,a5,2
ffffffffc0200c80:	eb89                	bnez	a5,ffffffffc0200c92 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200c82:	00005797          	auipc	a5,0x5
ffffffffc0200c86:	7c678793          	addi	a5,a5,1990 # ffffffffc0206448 <pmm_manager>
ffffffffc0200c8a:	639c                	ld	a5,0(a5)
ffffffffc0200c8c:	0207b303          	ld	t1,32(a5)
ffffffffc0200c90:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200c92:	1101                	addi	sp,sp,-32
ffffffffc0200c94:	ec06                	sd	ra,24(sp)
ffffffffc0200c96:	e822                	sd	s0,16(sp)
ffffffffc0200c98:	e426                	sd	s1,8(sp)
ffffffffc0200c9a:	842a                	mv	s0,a0
ffffffffc0200c9c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200c9e:	fd6ff0ef          	jal	ra,ffffffffc0200474 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200ca2:	00005797          	auipc	a5,0x5
ffffffffc0200ca6:	7a678793          	addi	a5,a5,1958 # ffffffffc0206448 <pmm_manager>
ffffffffc0200caa:	639c                	ld	a5,0(a5)
ffffffffc0200cac:	85a6                	mv	a1,s1
ffffffffc0200cae:	8522                	mv	a0,s0
ffffffffc0200cb0:	739c                	ld	a5,32(a5)
ffffffffc0200cb2:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200cb4:	6442                	ld	s0,16(sp)
ffffffffc0200cb6:	60e2                	ld	ra,24(sp)
ffffffffc0200cb8:	64a2                	ld	s1,8(sp)
ffffffffc0200cba:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200cbc:	fb2ff06f          	j	ffffffffc020046e <intr_enable>

ffffffffc0200cc0 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200cc0:	100027f3          	csrr	a5,sstatus
ffffffffc0200cc4:	8b89                	andi	a5,a5,2
ffffffffc0200cc6:	eb89                	bnez	a5,ffffffffc0200cd8 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200cc8:	00005797          	auipc	a5,0x5
ffffffffc0200ccc:	78078793          	addi	a5,a5,1920 # ffffffffc0206448 <pmm_manager>
ffffffffc0200cd0:	639c                	ld	a5,0(a5)
ffffffffc0200cd2:	0287b303          	ld	t1,40(a5)
ffffffffc0200cd6:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200cd8:	1141                	addi	sp,sp,-16
ffffffffc0200cda:	e406                	sd	ra,8(sp)
ffffffffc0200cdc:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200cde:	f96ff0ef          	jal	ra,ffffffffc0200474 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200ce2:	00005797          	auipc	a5,0x5
ffffffffc0200ce6:	76678793          	addi	a5,a5,1894 # ffffffffc0206448 <pmm_manager>
ffffffffc0200cea:	639c                	ld	a5,0(a5)
ffffffffc0200cec:	779c                	ld	a5,40(a5)
ffffffffc0200cee:	9782                	jalr	a5
ffffffffc0200cf0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200cf2:	f7cff0ef          	jal	ra,ffffffffc020046e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200cf6:	8522                	mv	a0,s0
ffffffffc0200cf8:	60a2                	ld	ra,8(sp)
ffffffffc0200cfa:	6402                	ld	s0,0(sp)
ffffffffc0200cfc:	0141                	addi	sp,sp,16
ffffffffc0200cfe:	8082                	ret

ffffffffc0200d00 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200d00:	00002797          	auipc	a5,0x2
ffffffffc0200d04:	fc878793          	addi	a5,a5,-56 # ffffffffc0202cc8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d08:	638c                	ld	a1,0(a5)
        cprintf("The total pages is : %d\n", (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200d0a:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d0c:	00002517          	auipc	a0,0x2
ffffffffc0200d10:	bb450513          	addi	a0,a0,-1100 # ffffffffc02028c0 <commands+0x840>
void pmm_init(void) {
ffffffffc0200d14:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200d16:	00005717          	auipc	a4,0x5
ffffffffc0200d1a:	72f73923          	sd	a5,1842(a4) # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc0200d1e:	e822                	sd	s0,16(sp)
ffffffffc0200d20:	e426                	sd	s1,8(sp)
ffffffffc0200d22:	e04a                	sd	s2,0(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200d24:	00005417          	auipc	s0,0x5
ffffffffc0200d28:	72440413          	addi	s0,s0,1828 # ffffffffc0206448 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d2c:	b9aff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    pmm_manager->init();
ffffffffc0200d30:	601c                	ld	a5,0(s0)
ffffffffc0200d32:	679c                	ld	a5,8(a5)
ffffffffc0200d34:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200d36:	57f5                	li	a5,-3
ffffffffc0200d38:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200d3a:	00002517          	auipc	a0,0x2
ffffffffc0200d3e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02028d8 <commands+0x858>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200d42:	00005717          	auipc	a4,0x5
ffffffffc0200d46:	70f73723          	sd	a5,1806(a4) # ffffffffc0206450 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200d4a:	b7cff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200d4e:	46c5                	li	a3,17
ffffffffc0200d50:	06ee                	slli	a3,a3,0x1b
ffffffffc0200d52:	40100613          	li	a2,1025
ffffffffc0200d56:	16fd                	addi	a3,a3,-1
ffffffffc0200d58:	0656                	slli	a2,a2,0x15
ffffffffc0200d5a:	07e005b7          	lui	a1,0x7e00
ffffffffc0200d5e:	00002517          	auipc	a0,0x2
ffffffffc0200d62:	b9250513          	addi	a0,a0,-1134 # ffffffffc02028f0 <commands+0x870>
ffffffffc0200d66:	b60ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200d6a:	777d                	lui	a4,0xfffff
ffffffffc0200d6c:	00006797          	auipc	a5,0x6
ffffffffc0200d70:	70b78793          	addi	a5,a5,1803 # ffffffffc0207477 <end+0xfff>
ffffffffc0200d74:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200d76:	00088737          	lui	a4,0x88
ffffffffc0200d7a:	00005697          	auipc	a3,0x5
ffffffffc0200d7e:	6ae6b323          	sd	a4,1702(a3) # ffffffffc0206420 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200d82:	4601                	li	a2,0
ffffffffc0200d84:	00005717          	auipc	a4,0x5
ffffffffc0200d88:	6cf73a23          	sd	a5,1748(a4) # ffffffffc0206458 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200d8c:	4681                	li	a3,0
ffffffffc0200d8e:	00005897          	auipc	a7,0x5
ffffffffc0200d92:	69288893          	addi	a7,a7,1682 # ffffffffc0206420 <npage>
ffffffffc0200d96:	00005597          	auipc	a1,0x5
ffffffffc0200d9a:	6c258593          	addi	a1,a1,1730 # ffffffffc0206458 <pages>
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d9e:	4805                	li	a6,1
ffffffffc0200da0:	fff80537          	lui	a0,0xfff80
ffffffffc0200da4:	a011                	j	ffffffffc0200da8 <pmm_init+0xa8>
ffffffffc0200da6:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200da8:	97b2                	add	a5,a5,a2
ffffffffc0200daa:	07a1                	addi	a5,a5,8
ffffffffc0200dac:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200db0:	0008b703          	ld	a4,0(a7)
ffffffffc0200db4:	0685                	addi	a3,a3,1
ffffffffc0200db6:	02860613          	addi	a2,a2,40
ffffffffc0200dba:	00a707b3          	add	a5,a4,a0
ffffffffc0200dbe:	fef6e4e3          	bltu	a3,a5,ffffffffc0200da6 <pmm_init+0xa6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200dc2:	6190                	ld	a2,0(a1)
ffffffffc0200dc4:	00271793          	slli	a5,a4,0x2
ffffffffc0200dc8:	97ba                	add	a5,a5,a4
ffffffffc0200dca:	fec006b7          	lui	a3,0xfec00
ffffffffc0200dce:	078e                	slli	a5,a5,0x3
ffffffffc0200dd0:	96b2                	add	a3,a3,a2
ffffffffc0200dd2:	96be                	add	a3,a3,a5
ffffffffc0200dd4:	c02007b7          	lui	a5,0xc0200
ffffffffc0200dd8:	0af6e863          	bltu	a3,a5,ffffffffc0200e88 <pmm_init+0x188>
ffffffffc0200ddc:	00005917          	auipc	s2,0x5
ffffffffc0200de0:	67490913          	addi	s2,s2,1652 # ffffffffc0206450 <va_pa_offset>
ffffffffc0200de4:	00093583          	ld	a1,0(s2)
    if (freemem < mem_end) {
ffffffffc0200de8:	47c5                	li	a5,17
ffffffffc0200dea:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200dec:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0200dee:	04f6eb63          	bltu	a3,a5,ffffffffc0200e44 <pmm_init+0x144>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200df2:	601c                	ld	a5,0(s0)
ffffffffc0200df4:	7b9c                	ld	a5,48(a5)
ffffffffc0200df6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200df8:	00002517          	auipc	a0,0x2
ffffffffc0200dfc:	b5850513          	addi	a0,a0,-1192 # ffffffffc0202950 <commands+0x8d0>
ffffffffc0200e00:	ac6ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200e04:	00004697          	auipc	a3,0x4
ffffffffc0200e08:	1fc68693          	addi	a3,a3,508 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200e0c:	00005797          	auipc	a5,0x5
ffffffffc0200e10:	60d7be23          	sd	a3,1564(a5) # ffffffffc0206428 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200e14:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e18:	08f6e463          	bltu	a3,a5,ffffffffc0200ea0 <pmm_init+0x1a0>
ffffffffc0200e1c:	00093783          	ld	a5,0(s2)
}
ffffffffc0200e20:	6442                	ld	s0,16(sp)
ffffffffc0200e22:	60e2                	ld	ra,24(sp)
ffffffffc0200e24:	64a2                	ld	s1,8(sp)
ffffffffc0200e26:	6902                	ld	s2,0(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200e28:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200e2a:	8e9d                	sub	a3,a3,a5
ffffffffc0200e2c:	00005797          	auipc	a5,0x5
ffffffffc0200e30:	60d7ba23          	sd	a3,1556(a5) # ffffffffc0206440 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200e34:	00002517          	auipc	a0,0x2
ffffffffc0200e38:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0202970 <commands+0x8f0>
ffffffffc0200e3c:	8636                	mv	a2,a3
}
ffffffffc0200e3e:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200e40:	a86ff06f          	j	ffffffffc02000c6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200e44:	6585                	lui	a1,0x1
ffffffffc0200e46:	15fd                	addi	a1,a1,-1
ffffffffc0200e48:	96ae                	add	a3,a3,a1
ffffffffc0200e4a:	75fd                	lui	a1,0xfffff
ffffffffc0200e4c:	8eed                	and	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0200e4e:	00c6d593          	srli	a1,a3,0xc
ffffffffc0200e52:	06e5f363          	bleu	a4,a1,ffffffffc0200eb8 <pmm_init+0x1b8>
    pmm_manager->init_memmap(base, n);
ffffffffc0200e56:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0200e5a:	00a58733          	add	a4,a1,a0
ffffffffc0200e5e:	00271513          	slli	a0,a4,0x2
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200e62:	40d786b3          	sub	a3,a5,a3
ffffffffc0200e66:	953a                	add	a0,a0,a4
    pmm_manager->init_memmap(base, n);
ffffffffc0200e68:	01083783          	ld	a5,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200e6c:	00c6d493          	srli	s1,a3,0xc
ffffffffc0200e70:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200e72:	9532                	add	a0,a0,a2
ffffffffc0200e74:	85a6                	mv	a1,s1
ffffffffc0200e76:	9782                	jalr	a5
        cprintf("The total pages is : %d\n", (mem_end - mem_begin) / PGSIZE);
ffffffffc0200e78:	85a6                	mv	a1,s1
ffffffffc0200e7a:	00002517          	auipc	a0,0x2
ffffffffc0200e7e:	ab650513          	addi	a0,a0,-1354 # ffffffffc0202930 <commands+0x8b0>
ffffffffc0200e82:	a44ff0ef          	jal	ra,ffffffffc02000c6 <cprintf>
ffffffffc0200e86:	b7b5                	j	ffffffffc0200df2 <pmm_init+0xf2>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e88:	00002617          	auipc	a2,0x2
ffffffffc0200e8c:	8e860613          	addi	a2,a2,-1816 # ffffffffc0202770 <commands+0x6f0>
ffffffffc0200e90:	06f00593          	li	a1,111
ffffffffc0200e94:	00002517          	auipc	a0,0x2
ffffffffc0200e98:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0202920 <commands+0x8a0>
ffffffffc0200e9c:	ab2ff0ef          	jal	ra,ffffffffc020014e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ea0:	00002617          	auipc	a2,0x2
ffffffffc0200ea4:	8d060613          	addi	a2,a2,-1840 # ffffffffc0202770 <commands+0x6f0>
ffffffffc0200ea8:	08b00593          	li	a1,139
ffffffffc0200eac:	00002517          	auipc	a0,0x2
ffffffffc0200eb0:	a7450513          	addi	a0,a0,-1420 # ffffffffc0202920 <commands+0x8a0>
ffffffffc0200eb4:	a9aff0ef          	jal	ra,ffffffffc020014e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200eb8:	00002617          	auipc	a2,0x2
ffffffffc0200ebc:	8e060613          	addi	a2,a2,-1824 # ffffffffc0202798 <commands+0x718>
ffffffffc0200ec0:	06b00593          	li	a1,107
ffffffffc0200ec4:	00002517          	auipc	a0,0x2
ffffffffc0200ec8:	8f450513          	addi	a0,a0,-1804 # ffffffffc02027b8 <commands+0x738>
ffffffffc0200ecc:	a82ff0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc0200ed0 <best_fit_init>:
ffffffffc0200ed0:	00005797          	auipc	a5,0x5
ffffffffc0200ed4:	59078793          	addi	a5,a5,1424 # ffffffffc0206460 <free_area>
ffffffffc0200ed8:	e79c                	sd	a5,8(a5)
ffffffffc0200eda:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200edc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ee0:	8082                	ret

ffffffffc0200ee2 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ee2:	00005517          	auipc	a0,0x5
ffffffffc0200ee6:	58e56503          	lwu	a0,1422(a0) # ffffffffc0206470 <free_area+0x10>
ffffffffc0200eea:	8082                	ret

ffffffffc0200eec <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200eec:	c15d                	beqz	a0,ffffffffc0200f92 <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc0200eee:	00005617          	auipc	a2,0x5
ffffffffc0200ef2:	57260613          	addi	a2,a2,1394 # ffffffffc0206460 <free_area>
ffffffffc0200ef6:	01062803          	lw	a6,16(a2)
ffffffffc0200efa:	86aa                	mv	a3,a0
ffffffffc0200efc:	02081793          	slli	a5,a6,0x20
ffffffffc0200f00:	9381                	srli	a5,a5,0x20
ffffffffc0200f02:	08a7e663          	bltu	a5,a0,ffffffffc0200f8e <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc0200f06:	0018059b          	addiw	a1,a6,1
ffffffffc0200f0a:	1582                	slli	a1,a1,0x20
ffffffffc0200f0c:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc0200f0e:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc0200f10:	4501                	li	a0,0
    return listelm->next;
ffffffffc0200f12:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f14:	00c78e63          	beq	a5,a2,ffffffffc0200f30 <best_fit_alloc_pages+0x44>
        if (p->property >= n) {
ffffffffc0200f18:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200f1c:	fed76be3          	bltu	a4,a3,ffffffffc0200f12 <best_fit_alloc_pages+0x26>
            if(min_size > p->property){
ffffffffc0200f20:	feb779e3          	bleu	a1,a4,ffffffffc0200f12 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc0200f24:	fe878513          	addi	a0,a5,-24
ffffffffc0200f28:	679c                	ld	a5,8(a5)
ffffffffc0200f2a:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f2c:	fec796e3          	bne	a5,a2,ffffffffc0200f18 <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc0200f30:	c125                	beqz	a0,ffffffffc0200f90 <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f32:	7118                	ld	a4,32(a0)
    return listelm->prev;
ffffffffc0200f34:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200f36:	490c                	lw	a1,16(a0)
ffffffffc0200f38:	0006889b          	sext.w	a7,a3
    prev->next = next;
ffffffffc0200f3c:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0200f3e:	e310                	sd	a2,0(a4)
ffffffffc0200f40:	02059713          	slli	a4,a1,0x20
ffffffffc0200f44:	9301                	srli	a4,a4,0x20
ffffffffc0200f46:	02e6f863          	bleu	a4,a3,ffffffffc0200f76 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc0200f4a:	00269713          	slli	a4,a3,0x2
ffffffffc0200f4e:	9736                	add	a4,a4,a3
ffffffffc0200f50:	070e                	slli	a4,a4,0x3
ffffffffc0200f52:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0200f54:	411585bb          	subw	a1,a1,a7
ffffffffc0200f58:	cb0c                	sw	a1,16(a4)
ffffffffc0200f5a:	4689                	li	a3,2
ffffffffc0200f5c:	00870593          	addi	a1,a4,8
ffffffffc0200f60:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f64:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc0200f66:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc0200f6a:	0107a803          	lw	a6,16(a5)
ffffffffc0200f6e:	e28c                	sd	a1,0(a3)
ffffffffc0200f70:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc0200f72:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0200f74:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc0200f76:	4118083b          	subw	a6,a6,a7
ffffffffc0200f7a:	00005797          	auipc	a5,0x5
ffffffffc0200f7e:	4f07ab23          	sw	a6,1270(a5) # ffffffffc0206470 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200f82:	57f5                	li	a5,-3
ffffffffc0200f84:	00850713          	addi	a4,a0,8
ffffffffc0200f88:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc0200f8c:	8082                	ret
        return NULL;
ffffffffc0200f8e:	4501                	li	a0,0
}
ffffffffc0200f90:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200f92:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200f94:	00002697          	auipc	a3,0x2
ffffffffc0200f98:	a1c68693          	addi	a3,a3,-1508 # ffffffffc02029b0 <commands+0x930>
ffffffffc0200f9c:	00002617          	auipc	a2,0x2
ffffffffc0200fa0:	85460613          	addi	a2,a2,-1964 # ffffffffc02027f0 <commands+0x770>
ffffffffc0200fa4:	06a00593          	li	a1,106
ffffffffc0200fa8:	00002517          	auipc	a0,0x2
ffffffffc0200fac:	a1050513          	addi	a0,a0,-1520 # ffffffffc02029b8 <commands+0x938>
best_fit_alloc_pages(size_t n) {
ffffffffc0200fb0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fb2:	99cff0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc0200fb6 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200fb6:	715d                	addi	sp,sp,-80
ffffffffc0200fb8:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0200fba:	00005917          	auipc	s2,0x5
ffffffffc0200fbe:	4a690913          	addi	s2,s2,1190 # ffffffffc0206460 <free_area>
ffffffffc0200fc2:	00893783          	ld	a5,8(s2)
ffffffffc0200fc6:	e486                	sd	ra,72(sp)
ffffffffc0200fc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200fca:	fc26                	sd	s1,56(sp)
ffffffffc0200fcc:	f44e                	sd	s3,40(sp)
ffffffffc0200fce:	f052                	sd	s4,32(sp)
ffffffffc0200fd0:	ec56                	sd	s5,24(sp)
ffffffffc0200fd2:	e85a                	sd	s6,16(sp)
ffffffffc0200fd4:	e45e                	sd	s7,8(sp)
ffffffffc0200fd6:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200fd8:	2d278363          	beq	a5,s2,ffffffffc020129e <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200fdc:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200fe0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200fe2:	8b05                	andi	a4,a4,1
ffffffffc0200fe4:	2c070163          	beqz	a4,ffffffffc02012a6 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200fe8:	4401                	li	s0,0
ffffffffc0200fea:	4481                	li	s1,0
ffffffffc0200fec:	a031                	j	ffffffffc0200ff8 <best_fit_check+0x42>
ffffffffc0200fee:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200ff2:	8b09                	andi	a4,a4,2
ffffffffc0200ff4:	2a070963          	beqz	a4,ffffffffc02012a6 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200ff8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ffc:	679c                	ld	a5,8(a5)
ffffffffc0200ffe:	2485                	addiw	s1,s1,1
ffffffffc0201000:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201002:	ff2796e3          	bne	a5,s2,ffffffffc0200fee <best_fit_check+0x38>
ffffffffc0201006:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0201008:	cb9ff0ef          	jal	ra,ffffffffc0200cc0 <nr_free_pages>
ffffffffc020100c:	37351d63          	bne	a0,s3,ffffffffc0201386 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201010:	4505                	li	a0,1
ffffffffc0201012:	c25ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201016:	8a2a                	mv	s4,a0
ffffffffc0201018:	3a050763          	beqz	a0,ffffffffc02013c6 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020101c:	4505                	li	a0,1
ffffffffc020101e:	c19ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201022:	89aa                	mv	s3,a0
ffffffffc0201024:	38050163          	beqz	a0,ffffffffc02013a6 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201028:	4505                	li	a0,1
ffffffffc020102a:	c0dff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc020102e:	8aaa                	mv	s5,a0
ffffffffc0201030:	30050b63          	beqz	a0,ffffffffc0201346 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201034:	293a0963          	beq	s4,s3,ffffffffc02012c6 <best_fit_check+0x310>
ffffffffc0201038:	28aa0763          	beq	s4,a0,ffffffffc02012c6 <best_fit_check+0x310>
ffffffffc020103c:	28a98563          	beq	s3,a0,ffffffffc02012c6 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201040:	000a2783          	lw	a5,0(s4)
ffffffffc0201044:	2a079163          	bnez	a5,ffffffffc02012e6 <best_fit_check+0x330>
ffffffffc0201048:	0009a783          	lw	a5,0(s3)
ffffffffc020104c:	28079d63          	bnez	a5,ffffffffc02012e6 <best_fit_check+0x330>
ffffffffc0201050:	411c                	lw	a5,0(a0)
ffffffffc0201052:	28079a63          	bnez	a5,ffffffffc02012e6 <best_fit_check+0x330>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201056:	00005797          	auipc	a5,0x5
ffffffffc020105a:	40278793          	addi	a5,a5,1026 # ffffffffc0206458 <pages>
ffffffffc020105e:	639c                	ld	a5,0(a5)
ffffffffc0201060:	00001717          	auipc	a4,0x1
ffffffffc0201064:	6c870713          	addi	a4,a4,1736 # ffffffffc0202728 <commands+0x6a8>
ffffffffc0201068:	630c                	ld	a1,0(a4)
ffffffffc020106a:	40fa0733          	sub	a4,s4,a5
ffffffffc020106e:	870d                	srai	a4,a4,0x3
ffffffffc0201070:	02b70733          	mul	a4,a4,a1
ffffffffc0201074:	00002697          	auipc	a3,0x2
ffffffffc0201078:	eec68693          	addi	a3,a3,-276 # ffffffffc0202f60 <nbase>
ffffffffc020107c:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020107e:	00005697          	auipc	a3,0x5
ffffffffc0201082:	3a268693          	addi	a3,a3,930 # ffffffffc0206420 <npage>
ffffffffc0201086:	6294                	ld	a3,0(a3)
ffffffffc0201088:	06b2                	slli	a3,a3,0xc
ffffffffc020108a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020108c:	0732                	slli	a4,a4,0xc
ffffffffc020108e:	26d77c63          	bleu	a3,a4,ffffffffc0201306 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201092:	40f98733          	sub	a4,s3,a5
ffffffffc0201096:	870d                	srai	a4,a4,0x3
ffffffffc0201098:	02b70733          	mul	a4,a4,a1
ffffffffc020109c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020109e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010a0:	42d77363          	bleu	a3,a4,ffffffffc02014c6 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010a4:	40f507b3          	sub	a5,a0,a5
ffffffffc02010a8:	878d                	srai	a5,a5,0x3
ffffffffc02010aa:	02b787b3          	mul	a5,a5,a1
ffffffffc02010ae:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010b0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02010b2:	3ed7fa63          	bleu	a3,a5,ffffffffc02014a6 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc02010b6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010b8:	00093c03          	ld	s8,0(s2)
ffffffffc02010bc:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02010c0:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02010c4:	00005797          	auipc	a5,0x5
ffffffffc02010c8:	3b27b223          	sd	s2,932(a5) # ffffffffc0206468 <free_area+0x8>
ffffffffc02010cc:	00005797          	auipc	a5,0x5
ffffffffc02010d0:	3927ba23          	sd	s2,916(a5) # ffffffffc0206460 <free_area>
    nr_free = 0;
ffffffffc02010d4:	00005797          	auipc	a5,0x5
ffffffffc02010d8:	3807ae23          	sw	zero,924(a5) # ffffffffc0206470 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02010dc:	b5bff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc02010e0:	3a051363          	bnez	a0,ffffffffc0201486 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc02010e4:	4585                	li	a1,1
ffffffffc02010e6:	8552                	mv	a0,s4
ffffffffc02010e8:	b93ff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    free_page(p1);
ffffffffc02010ec:	4585                	li	a1,1
ffffffffc02010ee:	854e                	mv	a0,s3
ffffffffc02010f0:	b8bff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    free_page(p2);
ffffffffc02010f4:	4585                	li	a1,1
ffffffffc02010f6:	8556                	mv	a0,s5
ffffffffc02010f8:	b83ff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    assert(nr_free == 3);
ffffffffc02010fc:	01092703          	lw	a4,16(s2)
ffffffffc0201100:	478d                	li	a5,3
ffffffffc0201102:	36f71263          	bne	a4,a5,ffffffffc0201466 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201106:	4505                	li	a0,1
ffffffffc0201108:	b2fff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc020110c:	89aa                	mv	s3,a0
ffffffffc020110e:	32050c63          	beqz	a0,ffffffffc0201446 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201112:	4505                	li	a0,1
ffffffffc0201114:	b23ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201118:	8aaa                	mv	s5,a0
ffffffffc020111a:	30050663          	beqz	a0,ffffffffc0201426 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020111e:	4505                	li	a0,1
ffffffffc0201120:	b17ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201124:	8a2a                	mv	s4,a0
ffffffffc0201126:	2e050063          	beqz	a0,ffffffffc0201406 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc020112a:	4505                	li	a0,1
ffffffffc020112c:	b0bff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201130:	2a051b63          	bnez	a0,ffffffffc02013e6 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0201134:	4585                	li	a1,1
ffffffffc0201136:	854e                	mv	a0,s3
ffffffffc0201138:	b43ff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020113c:	00893783          	ld	a5,8(s2)
ffffffffc0201140:	1f278363          	beq	a5,s2,ffffffffc0201326 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0201144:	4505                	li	a0,1
ffffffffc0201146:	af1ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc020114a:	54a99e63          	bne	s3,a0,ffffffffc02016a6 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc020114e:	4505                	li	a0,1
ffffffffc0201150:	ae7ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201154:	52051963          	bnez	a0,ffffffffc0201686 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0201158:	01092783          	lw	a5,16(s2)
ffffffffc020115c:	50079563          	bnez	a5,ffffffffc0201666 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0201160:	854e                	mv	a0,s3
ffffffffc0201162:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201164:	00005797          	auipc	a5,0x5
ffffffffc0201168:	2f87be23          	sd	s8,764(a5) # ffffffffc0206460 <free_area>
ffffffffc020116c:	00005797          	auipc	a5,0x5
ffffffffc0201170:	2f77be23          	sd	s7,764(a5) # ffffffffc0206468 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0201174:	00005797          	auipc	a5,0x5
ffffffffc0201178:	2f67ae23          	sw	s6,764(a5) # ffffffffc0206470 <free_area+0x10>
    free_page(p);
ffffffffc020117c:	affff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    free_page(p1);
ffffffffc0201180:	4585                	li	a1,1
ffffffffc0201182:	8556                	mv	a0,s5
ffffffffc0201184:	af7ff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    free_page(p2);
ffffffffc0201188:	4585                	li	a1,1
ffffffffc020118a:	8552                	mv	a0,s4
ffffffffc020118c:	aefff0ef          	jal	ra,ffffffffc0200c7a <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201190:	4515                	li	a0,5
ffffffffc0201192:	aa5ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201196:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201198:	4a050763          	beqz	a0,ffffffffc0201646 <best_fit_check+0x690>
ffffffffc020119c:	651c                	ld	a5,8(a0)
ffffffffc020119e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02011a0:	8b85                	andi	a5,a5,1
ffffffffc02011a2:	48079263          	bnez	a5,ffffffffc0201626 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02011a6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02011a8:	00093b03          	ld	s6,0(s2)
ffffffffc02011ac:	00893a83          	ld	s5,8(s2)
ffffffffc02011b0:	00005797          	auipc	a5,0x5
ffffffffc02011b4:	2b27b823          	sd	s2,688(a5) # ffffffffc0206460 <free_area>
ffffffffc02011b8:	00005797          	auipc	a5,0x5
ffffffffc02011bc:	2b27b823          	sd	s2,688(a5) # ffffffffc0206468 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02011c0:	a77ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc02011c4:	44051163          	bnez	a0,ffffffffc0201606 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc02011c8:	4589                	li	a1,2
ffffffffc02011ca:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc02011ce:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc02011d2:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc02011d6:	00005797          	auipc	a5,0x5
ffffffffc02011da:	2807ad23          	sw	zero,666(a5) # ffffffffc0206470 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc02011de:	a9dff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc02011e2:	8562                	mv	a0,s8
ffffffffc02011e4:	4585                	li	a1,1
ffffffffc02011e6:	a95ff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02011ea:	4511                	li	a0,4
ffffffffc02011ec:	a4bff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc02011f0:	3e051b63          	bnez	a0,ffffffffc02015e6 <best_fit_check+0x630>
ffffffffc02011f4:	0309b783          	ld	a5,48(s3)
ffffffffc02011f8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02011fa:	8b85                	andi	a5,a5,1
ffffffffc02011fc:	3c078563          	beqz	a5,ffffffffc02015c6 <best_fit_check+0x610>
ffffffffc0201200:	0389a703          	lw	a4,56(s3)
ffffffffc0201204:	4789                	li	a5,2
ffffffffc0201206:	3cf71063          	bne	a4,a5,ffffffffc02015c6 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020120a:	4505                	li	a0,1
ffffffffc020120c:	a2bff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201210:	8a2a                	mv	s4,a0
ffffffffc0201212:	38050a63          	beqz	a0,ffffffffc02015a6 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0201216:	4509                	li	a0,2
ffffffffc0201218:	a1fff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc020121c:	36050563          	beqz	a0,ffffffffc0201586 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0201220:	354c1363          	bne	s8,s4,ffffffffc0201566 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0201224:	854e                	mv	a0,s3
ffffffffc0201226:	4595                	li	a1,5
ffffffffc0201228:	a53ff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020122c:	4515                	li	a0,5
ffffffffc020122e:	a09ff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc0201232:	89aa                	mv	s3,a0
ffffffffc0201234:	30050963          	beqz	a0,ffffffffc0201546 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0201238:	4505                	li	a0,1
ffffffffc020123a:	9fdff0ef          	jal	ra,ffffffffc0200c36 <alloc_pages>
ffffffffc020123e:	2e051463          	bnez	a0,ffffffffc0201526 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0201242:	01092783          	lw	a5,16(s2)
ffffffffc0201246:	2c079063          	bnez	a5,ffffffffc0201506 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020124a:	4595                	li	a1,5
ffffffffc020124c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020124e:	00005797          	auipc	a5,0x5
ffffffffc0201252:	2377a123          	sw	s7,546(a5) # ffffffffc0206470 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201256:	00005797          	auipc	a5,0x5
ffffffffc020125a:	2167b523          	sd	s6,522(a5) # ffffffffc0206460 <free_area>
ffffffffc020125e:	00005797          	auipc	a5,0x5
ffffffffc0201262:	2157b523          	sd	s5,522(a5) # ffffffffc0206468 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201266:	a15ff0ef          	jal	ra,ffffffffc0200c7a <free_pages>
    return listelm->next;
ffffffffc020126a:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020126e:	01278963          	beq	a5,s2,ffffffffc0201280 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201272:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201276:	679c                	ld	a5,8(a5)
ffffffffc0201278:	34fd                	addiw	s1,s1,-1
ffffffffc020127a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020127c:	ff279be3          	bne	a5,s2,ffffffffc0201272 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0201280:	26049363          	bnez	s1,ffffffffc02014e6 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0201284:	e06d                	bnez	s0,ffffffffc0201366 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0201286:	60a6                	ld	ra,72(sp)
ffffffffc0201288:	6406                	ld	s0,64(sp)
ffffffffc020128a:	74e2                	ld	s1,56(sp)
ffffffffc020128c:	7942                	ld	s2,48(sp)
ffffffffc020128e:	79a2                	ld	s3,40(sp)
ffffffffc0201290:	7a02                	ld	s4,32(sp)
ffffffffc0201292:	6ae2                	ld	s5,24(sp)
ffffffffc0201294:	6b42                	ld	s6,16(sp)
ffffffffc0201296:	6ba2                	ld	s7,8(sp)
ffffffffc0201298:	6c02                	ld	s8,0(sp)
ffffffffc020129a:	6161                	addi	sp,sp,80
ffffffffc020129c:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020129e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02012a0:	4401                	li	s0,0
ffffffffc02012a2:	4481                	li	s1,0
ffffffffc02012a4:	b395                	j	ffffffffc0201008 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc02012a6:	00001697          	auipc	a3,0x1
ffffffffc02012aa:	72a68693          	addi	a3,a3,1834 # ffffffffc02029d0 <commands+0x950>
ffffffffc02012ae:	00001617          	auipc	a2,0x1
ffffffffc02012b2:	54260613          	addi	a2,a2,1346 # ffffffffc02027f0 <commands+0x770>
ffffffffc02012b6:	10b00593          	li	a1,267
ffffffffc02012ba:	00001517          	auipc	a0,0x1
ffffffffc02012be:	6fe50513          	addi	a0,a0,1790 # ffffffffc02029b8 <commands+0x938>
ffffffffc02012c2:	e8dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02012c6:	00001697          	auipc	a3,0x1
ffffffffc02012ca:	79a68693          	addi	a3,a3,1946 # ffffffffc0202a60 <commands+0x9e0>
ffffffffc02012ce:	00001617          	auipc	a2,0x1
ffffffffc02012d2:	52260613          	addi	a2,a2,1314 # ffffffffc02027f0 <commands+0x770>
ffffffffc02012d6:	0d700593          	li	a1,215
ffffffffc02012da:	00001517          	auipc	a0,0x1
ffffffffc02012de:	6de50513          	addi	a0,a0,1758 # ffffffffc02029b8 <commands+0x938>
ffffffffc02012e2:	e6dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02012e6:	00001697          	auipc	a3,0x1
ffffffffc02012ea:	7a268693          	addi	a3,a3,1954 # ffffffffc0202a88 <commands+0xa08>
ffffffffc02012ee:	00001617          	auipc	a2,0x1
ffffffffc02012f2:	50260613          	addi	a2,a2,1282 # ffffffffc02027f0 <commands+0x770>
ffffffffc02012f6:	0d800593          	li	a1,216
ffffffffc02012fa:	00001517          	auipc	a0,0x1
ffffffffc02012fe:	6be50513          	addi	a0,a0,1726 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201302:	e4dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201306:	00001697          	auipc	a3,0x1
ffffffffc020130a:	7c268693          	addi	a3,a3,1986 # ffffffffc0202ac8 <commands+0xa48>
ffffffffc020130e:	00001617          	auipc	a2,0x1
ffffffffc0201312:	4e260613          	addi	a2,a2,1250 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201316:	0da00593          	li	a1,218
ffffffffc020131a:	00001517          	auipc	a0,0x1
ffffffffc020131e:	69e50513          	addi	a0,a0,1694 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201322:	e2dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201326:	00002697          	auipc	a3,0x2
ffffffffc020132a:	82a68693          	addi	a3,a3,-2006 # ffffffffc0202b50 <commands+0xad0>
ffffffffc020132e:	00001617          	auipc	a2,0x1
ffffffffc0201332:	4c260613          	addi	a2,a2,1218 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201336:	0f300593          	li	a1,243
ffffffffc020133a:	00001517          	auipc	a0,0x1
ffffffffc020133e:	67e50513          	addi	a0,a0,1662 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201342:	e0dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201346:	00001697          	auipc	a3,0x1
ffffffffc020134a:	6fa68693          	addi	a3,a3,1786 # ffffffffc0202a40 <commands+0x9c0>
ffffffffc020134e:	00001617          	auipc	a2,0x1
ffffffffc0201352:	4a260613          	addi	a2,a2,1186 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201356:	0d500593          	li	a1,213
ffffffffc020135a:	00001517          	auipc	a0,0x1
ffffffffc020135e:	65e50513          	addi	a0,a0,1630 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201362:	dedfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(total == 0);
ffffffffc0201366:	00002697          	auipc	a3,0x2
ffffffffc020136a:	91a68693          	addi	a3,a3,-1766 # ffffffffc0202c80 <commands+0xc00>
ffffffffc020136e:	00001617          	auipc	a2,0x1
ffffffffc0201372:	48260613          	addi	a2,a2,1154 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201376:	14d00593          	li	a1,333
ffffffffc020137a:	00001517          	auipc	a0,0x1
ffffffffc020137e:	63e50513          	addi	a0,a0,1598 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201382:	dcdfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(total == nr_free_pages());
ffffffffc0201386:	00001697          	auipc	a3,0x1
ffffffffc020138a:	65a68693          	addi	a3,a3,1626 # ffffffffc02029e0 <commands+0x960>
ffffffffc020138e:	00001617          	auipc	a2,0x1
ffffffffc0201392:	46260613          	addi	a2,a2,1122 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201396:	10e00593          	li	a1,270
ffffffffc020139a:	00001517          	auipc	a0,0x1
ffffffffc020139e:	61e50513          	addi	a0,a0,1566 # ffffffffc02029b8 <commands+0x938>
ffffffffc02013a2:	dadfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013a6:	00001697          	auipc	a3,0x1
ffffffffc02013aa:	67a68693          	addi	a3,a3,1658 # ffffffffc0202a20 <commands+0x9a0>
ffffffffc02013ae:	00001617          	auipc	a2,0x1
ffffffffc02013b2:	44260613          	addi	a2,a2,1090 # ffffffffc02027f0 <commands+0x770>
ffffffffc02013b6:	0d400593          	li	a1,212
ffffffffc02013ba:	00001517          	auipc	a0,0x1
ffffffffc02013be:	5fe50513          	addi	a0,a0,1534 # ffffffffc02029b8 <commands+0x938>
ffffffffc02013c2:	d8dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013c6:	00001697          	auipc	a3,0x1
ffffffffc02013ca:	63a68693          	addi	a3,a3,1594 # ffffffffc0202a00 <commands+0x980>
ffffffffc02013ce:	00001617          	auipc	a2,0x1
ffffffffc02013d2:	42260613          	addi	a2,a2,1058 # ffffffffc02027f0 <commands+0x770>
ffffffffc02013d6:	0d300593          	li	a1,211
ffffffffc02013da:	00001517          	auipc	a0,0x1
ffffffffc02013de:	5de50513          	addi	a0,a0,1502 # ffffffffc02029b8 <commands+0x938>
ffffffffc02013e2:	d6dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013e6:	00001697          	auipc	a3,0x1
ffffffffc02013ea:	74268693          	addi	a3,a3,1858 # ffffffffc0202b28 <commands+0xaa8>
ffffffffc02013ee:	00001617          	auipc	a2,0x1
ffffffffc02013f2:	40260613          	addi	a2,a2,1026 # ffffffffc02027f0 <commands+0x770>
ffffffffc02013f6:	0f000593          	li	a1,240
ffffffffc02013fa:	00001517          	auipc	a0,0x1
ffffffffc02013fe:	5be50513          	addi	a0,a0,1470 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201402:	d4dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201406:	00001697          	auipc	a3,0x1
ffffffffc020140a:	63a68693          	addi	a3,a3,1594 # ffffffffc0202a40 <commands+0x9c0>
ffffffffc020140e:	00001617          	auipc	a2,0x1
ffffffffc0201412:	3e260613          	addi	a2,a2,994 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201416:	0ee00593          	li	a1,238
ffffffffc020141a:	00001517          	auipc	a0,0x1
ffffffffc020141e:	59e50513          	addi	a0,a0,1438 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201422:	d2dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201426:	00001697          	auipc	a3,0x1
ffffffffc020142a:	5fa68693          	addi	a3,a3,1530 # ffffffffc0202a20 <commands+0x9a0>
ffffffffc020142e:	00001617          	auipc	a2,0x1
ffffffffc0201432:	3c260613          	addi	a2,a2,962 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201436:	0ed00593          	li	a1,237
ffffffffc020143a:	00001517          	auipc	a0,0x1
ffffffffc020143e:	57e50513          	addi	a0,a0,1406 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201442:	d0dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201446:	00001697          	auipc	a3,0x1
ffffffffc020144a:	5ba68693          	addi	a3,a3,1466 # ffffffffc0202a00 <commands+0x980>
ffffffffc020144e:	00001617          	auipc	a2,0x1
ffffffffc0201452:	3a260613          	addi	a2,a2,930 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201456:	0ec00593          	li	a1,236
ffffffffc020145a:	00001517          	auipc	a0,0x1
ffffffffc020145e:	55e50513          	addi	a0,a0,1374 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201462:	cedfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(nr_free == 3);
ffffffffc0201466:	00001697          	auipc	a3,0x1
ffffffffc020146a:	6da68693          	addi	a3,a3,1754 # ffffffffc0202b40 <commands+0xac0>
ffffffffc020146e:	00001617          	auipc	a2,0x1
ffffffffc0201472:	38260613          	addi	a2,a2,898 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201476:	0ea00593          	li	a1,234
ffffffffc020147a:	00001517          	auipc	a0,0x1
ffffffffc020147e:	53e50513          	addi	a0,a0,1342 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201482:	ccdfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201486:	00001697          	auipc	a3,0x1
ffffffffc020148a:	6a268693          	addi	a3,a3,1698 # ffffffffc0202b28 <commands+0xaa8>
ffffffffc020148e:	00001617          	auipc	a2,0x1
ffffffffc0201492:	36260613          	addi	a2,a2,866 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201496:	0e500593          	li	a1,229
ffffffffc020149a:	00001517          	auipc	a0,0x1
ffffffffc020149e:	51e50513          	addi	a0,a0,1310 # ffffffffc02029b8 <commands+0x938>
ffffffffc02014a2:	cadfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02014a6:	00001697          	auipc	a3,0x1
ffffffffc02014aa:	66268693          	addi	a3,a3,1634 # ffffffffc0202b08 <commands+0xa88>
ffffffffc02014ae:	00001617          	auipc	a2,0x1
ffffffffc02014b2:	34260613          	addi	a2,a2,834 # ffffffffc02027f0 <commands+0x770>
ffffffffc02014b6:	0dc00593          	li	a1,220
ffffffffc02014ba:	00001517          	auipc	a0,0x1
ffffffffc02014be:	4fe50513          	addi	a0,a0,1278 # ffffffffc02029b8 <commands+0x938>
ffffffffc02014c2:	c8dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02014c6:	00001697          	auipc	a3,0x1
ffffffffc02014ca:	62268693          	addi	a3,a3,1570 # ffffffffc0202ae8 <commands+0xa68>
ffffffffc02014ce:	00001617          	auipc	a2,0x1
ffffffffc02014d2:	32260613          	addi	a2,a2,802 # ffffffffc02027f0 <commands+0x770>
ffffffffc02014d6:	0db00593          	li	a1,219
ffffffffc02014da:	00001517          	auipc	a0,0x1
ffffffffc02014de:	4de50513          	addi	a0,a0,1246 # ffffffffc02029b8 <commands+0x938>
ffffffffc02014e2:	c6dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(count == 0);
ffffffffc02014e6:	00001697          	auipc	a3,0x1
ffffffffc02014ea:	78a68693          	addi	a3,a3,1930 # ffffffffc0202c70 <commands+0xbf0>
ffffffffc02014ee:	00001617          	auipc	a2,0x1
ffffffffc02014f2:	30260613          	addi	a2,a2,770 # ffffffffc02027f0 <commands+0x770>
ffffffffc02014f6:	14c00593          	li	a1,332
ffffffffc02014fa:	00001517          	auipc	a0,0x1
ffffffffc02014fe:	4be50513          	addi	a0,a0,1214 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201502:	c4dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(nr_free == 0);
ffffffffc0201506:	00001697          	auipc	a3,0x1
ffffffffc020150a:	68268693          	addi	a3,a3,1666 # ffffffffc0202b88 <commands+0xb08>
ffffffffc020150e:	00001617          	auipc	a2,0x1
ffffffffc0201512:	2e260613          	addi	a2,a2,738 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201516:	14100593          	li	a1,321
ffffffffc020151a:	00001517          	auipc	a0,0x1
ffffffffc020151e:	49e50513          	addi	a0,a0,1182 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201522:	c2dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201526:	00001697          	auipc	a3,0x1
ffffffffc020152a:	60268693          	addi	a3,a3,1538 # ffffffffc0202b28 <commands+0xaa8>
ffffffffc020152e:	00001617          	auipc	a2,0x1
ffffffffc0201532:	2c260613          	addi	a2,a2,706 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201536:	13b00593          	li	a1,315
ffffffffc020153a:	00001517          	auipc	a0,0x1
ffffffffc020153e:	47e50513          	addi	a0,a0,1150 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201542:	c0dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201546:	00001697          	auipc	a3,0x1
ffffffffc020154a:	70a68693          	addi	a3,a3,1802 # ffffffffc0202c50 <commands+0xbd0>
ffffffffc020154e:	00001617          	auipc	a2,0x1
ffffffffc0201552:	2a260613          	addi	a2,a2,674 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201556:	13a00593          	li	a1,314
ffffffffc020155a:	00001517          	auipc	a0,0x1
ffffffffc020155e:	45e50513          	addi	a0,a0,1118 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201562:	bedfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(p0 + 4 == p1);
ffffffffc0201566:	00001697          	auipc	a3,0x1
ffffffffc020156a:	6da68693          	addi	a3,a3,1754 # ffffffffc0202c40 <commands+0xbc0>
ffffffffc020156e:	00001617          	auipc	a2,0x1
ffffffffc0201572:	28260613          	addi	a2,a2,642 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201576:	13200593          	li	a1,306
ffffffffc020157a:	00001517          	auipc	a0,0x1
ffffffffc020157e:	43e50513          	addi	a0,a0,1086 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201582:	bcdfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0201586:	00001697          	auipc	a3,0x1
ffffffffc020158a:	6a268693          	addi	a3,a3,1698 # ffffffffc0202c28 <commands+0xba8>
ffffffffc020158e:	00001617          	auipc	a2,0x1
ffffffffc0201592:	26260613          	addi	a2,a2,610 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201596:	13100593          	li	a1,305
ffffffffc020159a:	00001517          	auipc	a0,0x1
ffffffffc020159e:	41e50513          	addi	a0,a0,1054 # ffffffffc02029b8 <commands+0x938>
ffffffffc02015a2:	badfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc02015a6:	00001697          	auipc	a3,0x1
ffffffffc02015aa:	66268693          	addi	a3,a3,1634 # ffffffffc0202c08 <commands+0xb88>
ffffffffc02015ae:	00001617          	auipc	a2,0x1
ffffffffc02015b2:	24260613          	addi	a2,a2,578 # ffffffffc02027f0 <commands+0x770>
ffffffffc02015b6:	13000593          	li	a1,304
ffffffffc02015ba:	00001517          	auipc	a0,0x1
ffffffffc02015be:	3fe50513          	addi	a0,a0,1022 # ffffffffc02029b8 <commands+0x938>
ffffffffc02015c2:	b8dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02015c6:	00001697          	auipc	a3,0x1
ffffffffc02015ca:	61268693          	addi	a3,a3,1554 # ffffffffc0202bd8 <commands+0xb58>
ffffffffc02015ce:	00001617          	auipc	a2,0x1
ffffffffc02015d2:	22260613          	addi	a2,a2,546 # ffffffffc02027f0 <commands+0x770>
ffffffffc02015d6:	12e00593          	li	a1,302
ffffffffc02015da:	00001517          	auipc	a0,0x1
ffffffffc02015de:	3de50513          	addi	a0,a0,990 # ffffffffc02029b8 <commands+0x938>
ffffffffc02015e2:	b6dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02015e6:	00001697          	auipc	a3,0x1
ffffffffc02015ea:	5da68693          	addi	a3,a3,1498 # ffffffffc0202bc0 <commands+0xb40>
ffffffffc02015ee:	00001617          	auipc	a2,0x1
ffffffffc02015f2:	20260613          	addi	a2,a2,514 # ffffffffc02027f0 <commands+0x770>
ffffffffc02015f6:	12d00593          	li	a1,301
ffffffffc02015fa:	00001517          	auipc	a0,0x1
ffffffffc02015fe:	3be50513          	addi	a0,a0,958 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201602:	b4dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201606:	00001697          	auipc	a3,0x1
ffffffffc020160a:	52268693          	addi	a3,a3,1314 # ffffffffc0202b28 <commands+0xaa8>
ffffffffc020160e:	00001617          	auipc	a2,0x1
ffffffffc0201612:	1e260613          	addi	a2,a2,482 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201616:	12100593          	li	a1,289
ffffffffc020161a:	00001517          	auipc	a0,0x1
ffffffffc020161e:	39e50513          	addi	a0,a0,926 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201622:	b2dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(!PageProperty(p0));
ffffffffc0201626:	00001697          	auipc	a3,0x1
ffffffffc020162a:	58268693          	addi	a3,a3,1410 # ffffffffc0202ba8 <commands+0xb28>
ffffffffc020162e:	00001617          	auipc	a2,0x1
ffffffffc0201632:	1c260613          	addi	a2,a2,450 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201636:	11800593          	li	a1,280
ffffffffc020163a:	00001517          	auipc	a0,0x1
ffffffffc020163e:	37e50513          	addi	a0,a0,894 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201642:	b0dfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(p0 != NULL);
ffffffffc0201646:	00001697          	auipc	a3,0x1
ffffffffc020164a:	55268693          	addi	a3,a3,1362 # ffffffffc0202b98 <commands+0xb18>
ffffffffc020164e:	00001617          	auipc	a2,0x1
ffffffffc0201652:	1a260613          	addi	a2,a2,418 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201656:	11700593          	li	a1,279
ffffffffc020165a:	00001517          	auipc	a0,0x1
ffffffffc020165e:	35e50513          	addi	a0,a0,862 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201662:	aedfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(nr_free == 0);
ffffffffc0201666:	00001697          	auipc	a3,0x1
ffffffffc020166a:	52268693          	addi	a3,a3,1314 # ffffffffc0202b88 <commands+0xb08>
ffffffffc020166e:	00001617          	auipc	a2,0x1
ffffffffc0201672:	18260613          	addi	a2,a2,386 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201676:	0f900593          	li	a1,249
ffffffffc020167a:	00001517          	auipc	a0,0x1
ffffffffc020167e:	33e50513          	addi	a0,a0,830 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201682:	acdfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201686:	00001697          	auipc	a3,0x1
ffffffffc020168a:	4a268693          	addi	a3,a3,1186 # ffffffffc0202b28 <commands+0xaa8>
ffffffffc020168e:	00001617          	auipc	a2,0x1
ffffffffc0201692:	16260613          	addi	a2,a2,354 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201696:	0f700593          	li	a1,247
ffffffffc020169a:	00001517          	auipc	a0,0x1
ffffffffc020169e:	31e50513          	addi	a0,a0,798 # ffffffffc02029b8 <commands+0x938>
ffffffffc02016a2:	aadfe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02016a6:	00001697          	auipc	a3,0x1
ffffffffc02016aa:	4c268693          	addi	a3,a3,1218 # ffffffffc0202b68 <commands+0xae8>
ffffffffc02016ae:	00001617          	auipc	a2,0x1
ffffffffc02016b2:	14260613          	addi	a2,a2,322 # ffffffffc02027f0 <commands+0x770>
ffffffffc02016b6:	0f600593          	li	a1,246
ffffffffc02016ba:	00001517          	auipc	a0,0x1
ffffffffc02016be:	2fe50513          	addi	a0,a0,766 # ffffffffc02029b8 <commands+0x938>
ffffffffc02016c2:	a8dfe0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc02016c6 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02016c6:	1141                	addi	sp,sp,-16
ffffffffc02016c8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016ca:	18058063          	beqz	a1,ffffffffc020184a <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02016ce:	00259693          	slli	a3,a1,0x2
ffffffffc02016d2:	96ae                	add	a3,a3,a1
ffffffffc02016d4:	068e                	slli	a3,a3,0x3
ffffffffc02016d6:	96aa                	add	a3,a3,a0
ffffffffc02016d8:	02d50d63          	beq	a0,a3,ffffffffc0201712 <best_fit_free_pages+0x4c>
ffffffffc02016dc:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016de:	8b85                	andi	a5,a5,1
ffffffffc02016e0:	14079563          	bnez	a5,ffffffffc020182a <best_fit_free_pages+0x164>
ffffffffc02016e4:	651c                	ld	a5,8(a0)
ffffffffc02016e6:	8385                	srli	a5,a5,0x1
ffffffffc02016e8:	8b85                	andi	a5,a5,1
ffffffffc02016ea:	14079063          	bnez	a5,ffffffffc020182a <best_fit_free_pages+0x164>
ffffffffc02016ee:	87aa                	mv	a5,a0
ffffffffc02016f0:	a809                	j	ffffffffc0201702 <best_fit_free_pages+0x3c>
ffffffffc02016f2:	6798                	ld	a4,8(a5)
ffffffffc02016f4:	8b05                	andi	a4,a4,1
ffffffffc02016f6:	12071a63          	bnez	a4,ffffffffc020182a <best_fit_free_pages+0x164>
ffffffffc02016fa:	6798                	ld	a4,8(a5)
ffffffffc02016fc:	8b09                	andi	a4,a4,2
ffffffffc02016fe:	12071663          	bnez	a4,ffffffffc020182a <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc0201702:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201706:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020170a:	02878793          	addi	a5,a5,40
ffffffffc020170e:	fed792e3          	bne	a5,a3,ffffffffc02016f2 <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc0201712:	2581                	sext.w	a1,a1
ffffffffc0201714:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201716:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020171a:	4789                	li	a5,2
ffffffffc020171c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201720:	00005697          	auipc	a3,0x5
ffffffffc0201724:	d4068693          	addi	a3,a3,-704 # ffffffffc0206460 <free_area>
ffffffffc0201728:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020172a:	669c                	ld	a5,8(a3)
ffffffffc020172c:	9db9                	addw	a1,a1,a4
ffffffffc020172e:	00005717          	auipc	a4,0x5
ffffffffc0201732:	d4b72123          	sw	a1,-702(a4) # ffffffffc0206470 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201736:	08d78f63          	beq	a5,a3,ffffffffc02017d4 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc020173a:	fe878713          	addi	a4,a5,-24
ffffffffc020173e:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201740:	4801                	li	a6,0
ffffffffc0201742:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201746:	00e56a63          	bltu	a0,a4,ffffffffc020175a <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc020174a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020174c:	02d70563          	beq	a4,a3,ffffffffc0201776 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201750:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201752:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201756:	fee57ae3          	bleu	a4,a0,ffffffffc020174a <best_fit_free_pages+0x84>
ffffffffc020175a:	00080663          	beqz	a6,ffffffffc0201766 <best_fit_free_pages+0xa0>
ffffffffc020175e:	00005817          	auipc	a6,0x5
ffffffffc0201762:	d0b83123          	sd	a1,-766(a6) # ffffffffc0206460 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201766:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201768:	e390                	sd	a2,0(a5)
ffffffffc020176a:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020176c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020176e:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201770:	02d59163          	bne	a1,a3,ffffffffc0201792 <best_fit_free_pages+0xcc>
ffffffffc0201774:	a091                	j	ffffffffc02017b8 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201776:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201778:	f114                	sd	a3,32(a0)
ffffffffc020177a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020177c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020177e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201780:	00d70563          	beq	a4,a3,ffffffffc020178a <best_fit_free_pages+0xc4>
ffffffffc0201784:	4805                	li	a6,1
ffffffffc0201786:	87ba                	mv	a5,a4
ffffffffc0201788:	b7e9                	j	ffffffffc0201752 <best_fit_free_pages+0x8c>
ffffffffc020178a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020178c:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020178e:	02d78163          	beq	a5,a3,ffffffffc02017b0 <best_fit_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201792:	ff85a803          	lw	a6,-8(a1) # ffffffffffffeff8 <end+0x3fdf8b80>
        p = le2page(le, page_link);
ffffffffc0201796:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {
ffffffffc020179a:	02081713          	slli	a4,a6,0x20
ffffffffc020179e:	9301                	srli	a4,a4,0x20
ffffffffc02017a0:	00271793          	slli	a5,a4,0x2
ffffffffc02017a4:	97ba                	add	a5,a5,a4
ffffffffc02017a6:	078e                	slli	a5,a5,0x3
ffffffffc02017a8:	97b2                	add	a5,a5,a2
ffffffffc02017aa:	02f50e63          	beq	a0,a5,ffffffffc02017e6 <best_fit_free_pages+0x120>
ffffffffc02017ae:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02017b0:	fe878713          	addi	a4,a5,-24
ffffffffc02017b4:	00d78d63          	beq	a5,a3,ffffffffc02017ce <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02017b8:	490c                	lw	a1,16(a0)
ffffffffc02017ba:	02059613          	slli	a2,a1,0x20
ffffffffc02017be:	9201                	srli	a2,a2,0x20
ffffffffc02017c0:	00261693          	slli	a3,a2,0x2
ffffffffc02017c4:	96b2                	add	a3,a3,a2
ffffffffc02017c6:	068e                	slli	a3,a3,0x3
ffffffffc02017c8:	96aa                	add	a3,a3,a0
ffffffffc02017ca:	04d70063          	beq	a4,a3,ffffffffc020180a <best_fit_free_pages+0x144>
}
ffffffffc02017ce:	60a2                	ld	ra,8(sp)
ffffffffc02017d0:	0141                	addi	sp,sp,16
ffffffffc02017d2:	8082                	ret
ffffffffc02017d4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02017d6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02017da:	e398                	sd	a4,0(a5)
ffffffffc02017dc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02017de:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017e0:	ed1c                	sd	a5,24(a0)
}
ffffffffc02017e2:	0141                	addi	sp,sp,16
ffffffffc02017e4:	8082                	ret
            p->property += base->property;
ffffffffc02017e6:	491c                	lw	a5,16(a0)
ffffffffc02017e8:	0107883b          	addw	a6,a5,a6
ffffffffc02017ec:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017f0:	57f5                	li	a5,-3
ffffffffc02017f2:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017f6:	01853803          	ld	a6,24(a0)
ffffffffc02017fa:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc02017fc:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02017fe:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201802:	659c                	ld	a5,8(a1)
ffffffffc0201804:	01073023          	sd	a6,0(a4)
ffffffffc0201808:	b765                	j	ffffffffc02017b0 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc020180a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020180e:	ff078693          	addi	a3,a5,-16
ffffffffc0201812:	9db9                	addw	a1,a1,a4
ffffffffc0201814:	c90c                	sw	a1,16(a0)
ffffffffc0201816:	5775                	li	a4,-3
ffffffffc0201818:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020181c:	6398                	ld	a4,0(a5)
ffffffffc020181e:	679c                	ld	a5,8(a5)
}
ffffffffc0201820:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201822:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201824:	e398                	sd	a4,0(a5)
ffffffffc0201826:	0141                	addi	sp,sp,16
ffffffffc0201828:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020182a:	00001697          	auipc	a3,0x1
ffffffffc020182e:	46668693          	addi	a3,a3,1126 # ffffffffc0202c90 <commands+0xc10>
ffffffffc0201832:	00001617          	auipc	a2,0x1
ffffffffc0201836:	fbe60613          	addi	a2,a2,-66 # ffffffffc02027f0 <commands+0x770>
ffffffffc020183a:	09300593          	li	a1,147
ffffffffc020183e:	00001517          	auipc	a0,0x1
ffffffffc0201842:	17a50513          	addi	a0,a0,378 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201846:	909fe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(n > 0);
ffffffffc020184a:	00001697          	auipc	a3,0x1
ffffffffc020184e:	16668693          	addi	a3,a3,358 # ffffffffc02029b0 <commands+0x930>
ffffffffc0201852:	00001617          	auipc	a2,0x1
ffffffffc0201856:	f9e60613          	addi	a2,a2,-98 # ffffffffc02027f0 <commands+0x770>
ffffffffc020185a:	09000593          	li	a1,144
ffffffffc020185e:	00001517          	auipc	a0,0x1
ffffffffc0201862:	15a50513          	addi	a0,a0,346 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201866:	8e9fe0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc020186a <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020186a:	1141                	addi	sp,sp,-16
ffffffffc020186c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020186e:	c1fd                	beqz	a1,ffffffffc0201954 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc0201870:	00259693          	slli	a3,a1,0x2
ffffffffc0201874:	96ae                	add	a3,a3,a1
ffffffffc0201876:	068e                	slli	a3,a3,0x3
ffffffffc0201878:	96aa                	add	a3,a3,a0
ffffffffc020187a:	02d50463          	beq	a0,a3,ffffffffc02018a2 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020187e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201880:	87aa                	mv	a5,a0
ffffffffc0201882:	8b05                	andi	a4,a4,1
ffffffffc0201884:	e709                	bnez	a4,ffffffffc020188e <best_fit_init_memmap+0x24>
ffffffffc0201886:	a07d                	j	ffffffffc0201934 <best_fit_init_memmap+0xca>
ffffffffc0201888:	6798                	ld	a4,8(a5)
ffffffffc020188a:	8b05                	andi	a4,a4,1
ffffffffc020188c:	c745                	beqz	a4,ffffffffc0201934 <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020188e:	0007a823          	sw	zero,16(a5)
ffffffffc0201892:	0007b423          	sd	zero,8(a5)
ffffffffc0201896:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020189a:	02878793          	addi	a5,a5,40
ffffffffc020189e:	fed795e3          	bne	a5,a3,ffffffffc0201888 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc02018a2:	2581                	sext.w	a1,a1
ffffffffc02018a4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018a6:	4789                	li	a5,2
ffffffffc02018a8:	00850713          	addi	a4,a0,8
ffffffffc02018ac:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018b0:	00005697          	auipc	a3,0x5
ffffffffc02018b4:	bb068693          	addi	a3,a3,-1104 # ffffffffc0206460 <free_area>
ffffffffc02018b8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018ba:	669c                	ld	a5,8(a3)
ffffffffc02018bc:	9db9                	addw	a1,a1,a4
ffffffffc02018be:	00005717          	auipc	a4,0x5
ffffffffc02018c2:	bab72923          	sw	a1,-1102(a4) # ffffffffc0206470 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018c6:	04d78a63          	beq	a5,a3,ffffffffc020191a <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02018ca:	fe878713          	addi	a4,a5,-24
ffffffffc02018ce:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018d0:	4801                	li	a6,0
ffffffffc02018d2:	01850613          	addi	a2,a0,24
            if(base < page){
ffffffffc02018d6:	00e56a63          	bltu	a0,a4,ffffffffc02018ea <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc02018da:	6798                	ld	a4,8(a5)
            if(list_next(le) == &free_list) {
ffffffffc02018dc:	02d70563          	beq	a4,a3,ffffffffc0201906 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02018e0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02018e2:	fe878713          	addi	a4,a5,-24
            if(base < page){
ffffffffc02018e6:	fee57ae3          	bleu	a4,a0,ffffffffc02018da <best_fit_init_memmap+0x70>
ffffffffc02018ea:	00080663          	beqz	a6,ffffffffc02018f6 <best_fit_init_memmap+0x8c>
ffffffffc02018ee:	00005717          	auipc	a4,0x5
ffffffffc02018f2:	b6b73923          	sd	a1,-1166(a4) # ffffffffc0206460 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02018f6:	6398                	ld	a4,0(a5)
}
ffffffffc02018f8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02018fa:	e390                	sd	a2,0(a5)
ffffffffc02018fc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02018fe:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201900:	ed18                	sd	a4,24(a0)
ffffffffc0201902:	0141                	addi	sp,sp,16
ffffffffc0201904:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201906:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201908:	f114                	sd	a3,32(a0)
ffffffffc020190a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020190c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020190e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201910:	00d70e63          	beq	a4,a3,ffffffffc020192c <best_fit_init_memmap+0xc2>
ffffffffc0201914:	4805                	li	a6,1
ffffffffc0201916:	87ba                	mv	a5,a4
ffffffffc0201918:	b7e9                	j	ffffffffc02018e2 <best_fit_init_memmap+0x78>
}
ffffffffc020191a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020191c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201920:	e398                	sd	a4,0(a5)
ffffffffc0201922:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201924:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201926:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201928:	0141                	addi	sp,sp,16
ffffffffc020192a:	8082                	ret
ffffffffc020192c:	60a2                	ld	ra,8(sp)
ffffffffc020192e:	e290                	sd	a2,0(a3)
ffffffffc0201930:	0141                	addi	sp,sp,16
ffffffffc0201932:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201934:	00001697          	auipc	a3,0x1
ffffffffc0201938:	38468693          	addi	a3,a3,900 # ffffffffc0202cb8 <commands+0xc38>
ffffffffc020193c:	00001617          	auipc	a2,0x1
ffffffffc0201940:	eb460613          	addi	a2,a2,-332 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201944:	04a00593          	li	a1,74
ffffffffc0201948:	00001517          	auipc	a0,0x1
ffffffffc020194c:	07050513          	addi	a0,a0,112 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201950:	ffefe0ef          	jal	ra,ffffffffc020014e <__panic>
    assert(n > 0);
ffffffffc0201954:	00001697          	auipc	a3,0x1
ffffffffc0201958:	05c68693          	addi	a3,a3,92 # ffffffffc02029b0 <commands+0x930>
ffffffffc020195c:	00001617          	auipc	a2,0x1
ffffffffc0201960:	e9460613          	addi	a2,a2,-364 # ffffffffc02027f0 <commands+0x770>
ffffffffc0201964:	04700593          	li	a1,71
ffffffffc0201968:	00001517          	auipc	a0,0x1
ffffffffc020196c:	05050513          	addi	a0,a0,80 # ffffffffc02029b8 <commands+0x938>
ffffffffc0201970:	fdefe0ef          	jal	ra,ffffffffc020014e <__panic>

ffffffffc0201974 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201974:	c185                	beqz	a1,ffffffffc0201994 <strnlen+0x20>
ffffffffc0201976:	00054783          	lbu	a5,0(a0)
ffffffffc020197a:	cf89                	beqz	a5,ffffffffc0201994 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020197c:	4781                	li	a5,0
ffffffffc020197e:	a021                	j	ffffffffc0201986 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201980:	00074703          	lbu	a4,0(a4)
ffffffffc0201984:	c711                	beqz	a4,ffffffffc0201990 <strnlen+0x1c>
        cnt ++;
ffffffffc0201986:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201988:	00f50733          	add	a4,a0,a5
ffffffffc020198c:	fef59ae3          	bne	a1,a5,ffffffffc0201980 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201990:	853e                	mv	a0,a5
ffffffffc0201992:	8082                	ret
    size_t cnt = 0;
ffffffffc0201994:	4781                	li	a5,0
}
ffffffffc0201996:	853e                	mv	a0,a5
ffffffffc0201998:	8082                	ret

ffffffffc020199a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020199a:	00054783          	lbu	a5,0(a0)
ffffffffc020199e:	0005c703          	lbu	a4,0(a1)
ffffffffc02019a2:	cb91                	beqz	a5,ffffffffc02019b6 <strcmp+0x1c>
ffffffffc02019a4:	00e79c63          	bne	a5,a4,ffffffffc02019bc <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02019a8:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019aa:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02019ae:	0585                	addi	a1,a1,1
ffffffffc02019b0:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019b4:	fbe5                	bnez	a5,ffffffffc02019a4 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019b6:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02019b8:	9d19                	subw	a0,a0,a4
ffffffffc02019ba:	8082                	ret
ffffffffc02019bc:	0007851b          	sext.w	a0,a5
ffffffffc02019c0:	9d19                	subw	a0,a0,a4
ffffffffc02019c2:	8082                	ret

ffffffffc02019c4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019c4:	00054783          	lbu	a5,0(a0)
ffffffffc02019c8:	cb91                	beqz	a5,ffffffffc02019dc <strchr+0x18>
        if (*s == c) {
ffffffffc02019ca:	00b79563          	bne	a5,a1,ffffffffc02019d4 <strchr+0x10>
ffffffffc02019ce:	a809                	j	ffffffffc02019e0 <strchr+0x1c>
ffffffffc02019d0:	00b78763          	beq	a5,a1,ffffffffc02019de <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02019d4:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019d6:	00054783          	lbu	a5,0(a0)
ffffffffc02019da:	fbfd                	bnez	a5,ffffffffc02019d0 <strchr+0xc>
    }
    return NULL;
ffffffffc02019dc:	4501                	li	a0,0
}
ffffffffc02019de:	8082                	ret
ffffffffc02019e0:	8082                	ret

ffffffffc02019e2 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019e2:	ca01                	beqz	a2,ffffffffc02019f2 <memset+0x10>
ffffffffc02019e4:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019e6:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019e8:	0785                	addi	a5,a5,1
ffffffffc02019ea:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019ee:	fec79de3          	bne	a5,a2,ffffffffc02019e8 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019f2:	8082                	ret

ffffffffc02019f4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02019f4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02019f8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02019fa:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02019fe:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201a00:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a04:	f022                	sd	s0,32(sp)
ffffffffc0201a06:	ec26                	sd	s1,24(sp)
ffffffffc0201a08:	e84a                	sd	s2,16(sp)
ffffffffc0201a0a:	f406                	sd	ra,40(sp)
ffffffffc0201a0c:	e44e                	sd	s3,8(sp)
ffffffffc0201a0e:	84aa                	mv	s1,a0
ffffffffc0201a10:	892e                	mv	s2,a1
ffffffffc0201a12:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201a16:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201a18:	03067e63          	bleu	a6,a2,ffffffffc0201a54 <printnum+0x60>
ffffffffc0201a1c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201a1e:	00805763          	blez	s0,ffffffffc0201a2c <printnum+0x38>
ffffffffc0201a22:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201a24:	85ca                	mv	a1,s2
ffffffffc0201a26:	854e                	mv	a0,s3
ffffffffc0201a28:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201a2a:	fc65                	bnez	s0,ffffffffc0201a22 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a2c:	1a02                	slli	s4,s4,0x20
ffffffffc0201a2e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201a32:	00001797          	auipc	a5,0x1
ffffffffc0201a36:	47678793          	addi	a5,a5,1142 # ffffffffc0202ea8 <error_string+0x38>
ffffffffc0201a3a:	9a3e                	add	s4,s4,a5
}
ffffffffc0201a3c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a3e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201a42:	70a2                	ld	ra,40(sp)
ffffffffc0201a44:	69a2                	ld	s3,8(sp)
ffffffffc0201a46:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a48:	85ca                	mv	a1,s2
ffffffffc0201a4a:	8326                	mv	t1,s1
}
ffffffffc0201a4c:	6942                	ld	s2,16(sp)
ffffffffc0201a4e:	64e2                	ld	s1,24(sp)
ffffffffc0201a50:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a52:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201a54:	03065633          	divu	a2,a2,a6
ffffffffc0201a58:	8722                	mv	a4,s0
ffffffffc0201a5a:	f9bff0ef          	jal	ra,ffffffffc02019f4 <printnum>
ffffffffc0201a5e:	b7f9                	j	ffffffffc0201a2c <printnum+0x38>

ffffffffc0201a60 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201a60:	7119                	addi	sp,sp,-128
ffffffffc0201a62:	f4a6                	sd	s1,104(sp)
ffffffffc0201a64:	f0ca                	sd	s2,96(sp)
ffffffffc0201a66:	e8d2                	sd	s4,80(sp)
ffffffffc0201a68:	e4d6                	sd	s5,72(sp)
ffffffffc0201a6a:	e0da                	sd	s6,64(sp)
ffffffffc0201a6c:	fc5e                	sd	s7,56(sp)
ffffffffc0201a6e:	f862                	sd	s8,48(sp)
ffffffffc0201a70:	f06a                	sd	s10,32(sp)
ffffffffc0201a72:	fc86                	sd	ra,120(sp)
ffffffffc0201a74:	f8a2                	sd	s0,112(sp)
ffffffffc0201a76:	ecce                	sd	s3,88(sp)
ffffffffc0201a78:	f466                	sd	s9,40(sp)
ffffffffc0201a7a:	ec6e                	sd	s11,24(sp)
ffffffffc0201a7c:	892a                	mv	s2,a0
ffffffffc0201a7e:	84ae                	mv	s1,a1
ffffffffc0201a80:	8d32                	mv	s10,a2
ffffffffc0201a82:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201a84:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a86:	00001a17          	auipc	s4,0x1
ffffffffc0201a8a:	292a0a13          	addi	s4,s4,658 # ffffffffc0202d18 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a8e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a92:	00001c17          	auipc	s8,0x1
ffffffffc0201a96:	3dec0c13          	addi	s8,s8,990 # ffffffffc0202e70 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a9a:	000d4503          	lbu	a0,0(s10)
ffffffffc0201a9e:	02500793          	li	a5,37
ffffffffc0201aa2:	001d0413          	addi	s0,s10,1
ffffffffc0201aa6:	00f50e63          	beq	a0,a5,ffffffffc0201ac2 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201aaa:	c521                	beqz	a0,ffffffffc0201af2 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201aac:	02500993          	li	s3,37
ffffffffc0201ab0:	a011                	j	ffffffffc0201ab4 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201ab2:	c121                	beqz	a0,ffffffffc0201af2 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201ab4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201ab6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201ab8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201aba:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201abe:	ff351ae3          	bne	a0,s3,ffffffffc0201ab2 <vprintfmt+0x52>
ffffffffc0201ac2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201ac6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201aca:	4981                	li	s3,0
ffffffffc0201acc:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201ace:	5cfd                	li	s9,-1
ffffffffc0201ad0:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ad2:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201ad6:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ad8:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201adc:	0ff6f693          	andi	a3,a3,255
ffffffffc0201ae0:	00140d13          	addi	s10,s0,1
ffffffffc0201ae4:	20d5e563          	bltu	a1,a3,ffffffffc0201cee <vprintfmt+0x28e>
ffffffffc0201ae8:	068a                	slli	a3,a3,0x2
ffffffffc0201aea:	96d2                	add	a3,a3,s4
ffffffffc0201aec:	4294                	lw	a3,0(a3)
ffffffffc0201aee:	96d2                	add	a3,a3,s4
ffffffffc0201af0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201af2:	70e6                	ld	ra,120(sp)
ffffffffc0201af4:	7446                	ld	s0,112(sp)
ffffffffc0201af6:	74a6                	ld	s1,104(sp)
ffffffffc0201af8:	7906                	ld	s2,96(sp)
ffffffffc0201afa:	69e6                	ld	s3,88(sp)
ffffffffc0201afc:	6a46                	ld	s4,80(sp)
ffffffffc0201afe:	6aa6                	ld	s5,72(sp)
ffffffffc0201b00:	6b06                	ld	s6,64(sp)
ffffffffc0201b02:	7be2                	ld	s7,56(sp)
ffffffffc0201b04:	7c42                	ld	s8,48(sp)
ffffffffc0201b06:	7ca2                	ld	s9,40(sp)
ffffffffc0201b08:	7d02                	ld	s10,32(sp)
ffffffffc0201b0a:	6de2                	ld	s11,24(sp)
ffffffffc0201b0c:	6109                	addi	sp,sp,128
ffffffffc0201b0e:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201b10:	4705                	li	a4,1
ffffffffc0201b12:	008a8593          	addi	a1,s5,8
ffffffffc0201b16:	01074463          	blt	a4,a6,ffffffffc0201b1e <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201b1a:	26080363          	beqz	a6,ffffffffc0201d80 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201b1e:	000ab603          	ld	a2,0(s5)
ffffffffc0201b22:	46c1                	li	a3,16
ffffffffc0201b24:	8aae                	mv	s5,a1
ffffffffc0201b26:	a06d                	j	ffffffffc0201bd0 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201b28:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201b2c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b2e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b30:	b765                	j	ffffffffc0201ad8 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201b32:	000aa503          	lw	a0,0(s5)
ffffffffc0201b36:	85a6                	mv	a1,s1
ffffffffc0201b38:	0aa1                	addi	s5,s5,8
ffffffffc0201b3a:	9902                	jalr	s2
            break;
ffffffffc0201b3c:	bfb9                	j	ffffffffc0201a9a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201b3e:	4705                	li	a4,1
ffffffffc0201b40:	008a8993          	addi	s3,s5,8
ffffffffc0201b44:	01074463          	blt	a4,a6,ffffffffc0201b4c <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201b48:	22080463          	beqz	a6,ffffffffc0201d70 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201b4c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201b50:	24044463          	bltz	s0,ffffffffc0201d98 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201b54:	8622                	mv	a2,s0
ffffffffc0201b56:	8ace                	mv	s5,s3
ffffffffc0201b58:	46a9                	li	a3,10
ffffffffc0201b5a:	a89d                	j	ffffffffc0201bd0 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201b5c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201b60:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201b62:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201b64:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201b68:	8fb5                	xor	a5,a5,a3
ffffffffc0201b6a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201b6e:	1ad74363          	blt	a4,a3,ffffffffc0201d14 <vprintfmt+0x2b4>
ffffffffc0201b72:	00369793          	slli	a5,a3,0x3
ffffffffc0201b76:	97e2                	add	a5,a5,s8
ffffffffc0201b78:	639c                	ld	a5,0(a5)
ffffffffc0201b7a:	18078d63          	beqz	a5,ffffffffc0201d14 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201b7e:	86be                	mv	a3,a5
ffffffffc0201b80:	00001617          	auipc	a2,0x1
ffffffffc0201b84:	3d860613          	addi	a2,a2,984 # ffffffffc0202f58 <error_string+0xe8>
ffffffffc0201b88:	85a6                	mv	a1,s1
ffffffffc0201b8a:	854a                	mv	a0,s2
ffffffffc0201b8c:	240000ef          	jal	ra,ffffffffc0201dcc <printfmt>
ffffffffc0201b90:	b729                	j	ffffffffc0201a9a <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201b92:	00144603          	lbu	a2,1(s0)
ffffffffc0201b96:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b98:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b9a:	bf3d                	j	ffffffffc0201ad8 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201b9c:	4705                	li	a4,1
ffffffffc0201b9e:	008a8593          	addi	a1,s5,8
ffffffffc0201ba2:	01074463          	blt	a4,a6,ffffffffc0201baa <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201ba6:	1e080263          	beqz	a6,ffffffffc0201d8a <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201baa:	000ab603          	ld	a2,0(s5)
ffffffffc0201bae:	46a1                	li	a3,8
ffffffffc0201bb0:	8aae                	mv	s5,a1
ffffffffc0201bb2:	a839                	j	ffffffffc0201bd0 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201bb4:	03000513          	li	a0,48
ffffffffc0201bb8:	85a6                	mv	a1,s1
ffffffffc0201bba:	e03e                	sd	a5,0(sp)
ffffffffc0201bbc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201bbe:	85a6                	mv	a1,s1
ffffffffc0201bc0:	07800513          	li	a0,120
ffffffffc0201bc4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201bc6:	0aa1                	addi	s5,s5,8
ffffffffc0201bc8:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201bcc:	6782                	ld	a5,0(sp)
ffffffffc0201bce:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201bd0:	876e                	mv	a4,s11
ffffffffc0201bd2:	85a6                	mv	a1,s1
ffffffffc0201bd4:	854a                	mv	a0,s2
ffffffffc0201bd6:	e1fff0ef          	jal	ra,ffffffffc02019f4 <printnum>
            break;
ffffffffc0201bda:	b5c1                	j	ffffffffc0201a9a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201bdc:	000ab603          	ld	a2,0(s5)
ffffffffc0201be0:	0aa1                	addi	s5,s5,8
ffffffffc0201be2:	1c060663          	beqz	a2,ffffffffc0201dae <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201be6:	00160413          	addi	s0,a2,1
ffffffffc0201bea:	17b05c63          	blez	s11,ffffffffc0201d62 <vprintfmt+0x302>
ffffffffc0201bee:	02d00593          	li	a1,45
ffffffffc0201bf2:	14b79263          	bne	a5,a1,ffffffffc0201d36 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bf6:	00064783          	lbu	a5,0(a2)
ffffffffc0201bfa:	0007851b          	sext.w	a0,a5
ffffffffc0201bfe:	c905                	beqz	a0,ffffffffc0201c2e <vprintfmt+0x1ce>
ffffffffc0201c00:	000cc563          	bltz	s9,ffffffffc0201c0a <vprintfmt+0x1aa>
ffffffffc0201c04:	3cfd                	addiw	s9,s9,-1
ffffffffc0201c06:	036c8263          	beq	s9,s6,ffffffffc0201c2a <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201c0a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c0c:	18098463          	beqz	s3,ffffffffc0201d94 <vprintfmt+0x334>
ffffffffc0201c10:	3781                	addiw	a5,a5,-32
ffffffffc0201c12:	18fbf163          	bleu	a5,s7,ffffffffc0201d94 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201c16:	03f00513          	li	a0,63
ffffffffc0201c1a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c1c:	0405                	addi	s0,s0,1
ffffffffc0201c1e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201c22:	3dfd                	addiw	s11,s11,-1
ffffffffc0201c24:	0007851b          	sext.w	a0,a5
ffffffffc0201c28:	fd61                	bnez	a0,ffffffffc0201c00 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201c2a:	e7b058e3          	blez	s11,ffffffffc0201a9a <vprintfmt+0x3a>
ffffffffc0201c2e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201c30:	85a6                	mv	a1,s1
ffffffffc0201c32:	02000513          	li	a0,32
ffffffffc0201c36:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201c38:	e60d81e3          	beqz	s11,ffffffffc0201a9a <vprintfmt+0x3a>
ffffffffc0201c3c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201c3e:	85a6                	mv	a1,s1
ffffffffc0201c40:	02000513          	li	a0,32
ffffffffc0201c44:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201c46:	fe0d94e3          	bnez	s11,ffffffffc0201c2e <vprintfmt+0x1ce>
ffffffffc0201c4a:	bd81                	j	ffffffffc0201a9a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201c4c:	4705                	li	a4,1
ffffffffc0201c4e:	008a8593          	addi	a1,s5,8
ffffffffc0201c52:	01074463          	blt	a4,a6,ffffffffc0201c5a <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201c56:	12080063          	beqz	a6,ffffffffc0201d76 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201c5a:	000ab603          	ld	a2,0(s5)
ffffffffc0201c5e:	46a9                	li	a3,10
ffffffffc0201c60:	8aae                	mv	s5,a1
ffffffffc0201c62:	b7bd                	j	ffffffffc0201bd0 <vprintfmt+0x170>
ffffffffc0201c64:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201c68:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c6c:	846a                	mv	s0,s10
ffffffffc0201c6e:	b5ad                	j	ffffffffc0201ad8 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201c70:	85a6                	mv	a1,s1
ffffffffc0201c72:	02500513          	li	a0,37
ffffffffc0201c76:	9902                	jalr	s2
            break;
ffffffffc0201c78:	b50d                	j	ffffffffc0201a9a <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201c7a:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201c7e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201c82:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c84:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201c86:	e40dd9e3          	bgez	s11,ffffffffc0201ad8 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201c8a:	8de6                	mv	s11,s9
ffffffffc0201c8c:	5cfd                	li	s9,-1
ffffffffc0201c8e:	b5a9                	j	ffffffffc0201ad8 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201c90:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201c94:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c98:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201c9a:	bd3d                	j	ffffffffc0201ad8 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201c9c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201ca0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ca4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201ca6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201caa:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201cae:	fcd56ce3          	bltu	a0,a3,ffffffffc0201c86 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201cb2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201cb4:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201cb8:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201cbc:	0196873b          	addw	a4,a3,s9
ffffffffc0201cc0:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201cc4:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201cc8:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201ccc:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201cd0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201cd4:	fcd57fe3          	bleu	a3,a0,ffffffffc0201cb2 <vprintfmt+0x252>
ffffffffc0201cd8:	b77d                	j	ffffffffc0201c86 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201cda:	fffdc693          	not	a3,s11
ffffffffc0201cde:	96fd                	srai	a3,a3,0x3f
ffffffffc0201ce0:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201ce4:	00144603          	lbu	a2,1(s0)
ffffffffc0201ce8:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201cea:	846a                	mv	s0,s10
ffffffffc0201cec:	b3f5                	j	ffffffffc0201ad8 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201cee:	85a6                	mv	a1,s1
ffffffffc0201cf0:	02500513          	li	a0,37
ffffffffc0201cf4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201cf6:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201cfa:	02500793          	li	a5,37
ffffffffc0201cfe:	8d22                	mv	s10,s0
ffffffffc0201d00:	d8f70de3          	beq	a4,a5,ffffffffc0201a9a <vprintfmt+0x3a>
ffffffffc0201d04:	02500713          	li	a4,37
ffffffffc0201d08:	1d7d                	addi	s10,s10,-1
ffffffffc0201d0a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201d0e:	fee79de3          	bne	a5,a4,ffffffffc0201d08 <vprintfmt+0x2a8>
ffffffffc0201d12:	b361                	j	ffffffffc0201a9a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201d14:	00001617          	auipc	a2,0x1
ffffffffc0201d18:	23460613          	addi	a2,a2,564 # ffffffffc0202f48 <error_string+0xd8>
ffffffffc0201d1c:	85a6                	mv	a1,s1
ffffffffc0201d1e:	854a                	mv	a0,s2
ffffffffc0201d20:	0ac000ef          	jal	ra,ffffffffc0201dcc <printfmt>
ffffffffc0201d24:	bb9d                	j	ffffffffc0201a9a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201d26:	00001617          	auipc	a2,0x1
ffffffffc0201d2a:	21a60613          	addi	a2,a2,538 # ffffffffc0202f40 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201d2e:	00001417          	auipc	s0,0x1
ffffffffc0201d32:	21340413          	addi	s0,s0,531 # ffffffffc0202f41 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201d36:	8532                	mv	a0,a2
ffffffffc0201d38:	85e6                	mv	a1,s9
ffffffffc0201d3a:	e032                	sd	a2,0(sp)
ffffffffc0201d3c:	e43e                	sd	a5,8(sp)
ffffffffc0201d3e:	c37ff0ef          	jal	ra,ffffffffc0201974 <strnlen>
ffffffffc0201d42:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201d46:	6602                	ld	a2,0(sp)
ffffffffc0201d48:	01b05d63          	blez	s11,ffffffffc0201d62 <vprintfmt+0x302>
ffffffffc0201d4c:	67a2                	ld	a5,8(sp)
ffffffffc0201d4e:	2781                	sext.w	a5,a5
ffffffffc0201d50:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201d52:	6522                	ld	a0,8(sp)
ffffffffc0201d54:	85a6                	mv	a1,s1
ffffffffc0201d56:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201d58:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201d5a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201d5c:	6602                	ld	a2,0(sp)
ffffffffc0201d5e:	fe0d9ae3          	bnez	s11,ffffffffc0201d52 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d62:	00064783          	lbu	a5,0(a2)
ffffffffc0201d66:	0007851b          	sext.w	a0,a5
ffffffffc0201d6a:	e8051be3          	bnez	a0,ffffffffc0201c00 <vprintfmt+0x1a0>
ffffffffc0201d6e:	b335                	j	ffffffffc0201a9a <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201d70:	000aa403          	lw	s0,0(s5)
ffffffffc0201d74:	bbf1                	j	ffffffffc0201b50 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201d76:	000ae603          	lwu	a2,0(s5)
ffffffffc0201d7a:	46a9                	li	a3,10
ffffffffc0201d7c:	8aae                	mv	s5,a1
ffffffffc0201d7e:	bd89                	j	ffffffffc0201bd0 <vprintfmt+0x170>
ffffffffc0201d80:	000ae603          	lwu	a2,0(s5)
ffffffffc0201d84:	46c1                	li	a3,16
ffffffffc0201d86:	8aae                	mv	s5,a1
ffffffffc0201d88:	b5a1                	j	ffffffffc0201bd0 <vprintfmt+0x170>
ffffffffc0201d8a:	000ae603          	lwu	a2,0(s5)
ffffffffc0201d8e:	46a1                	li	a3,8
ffffffffc0201d90:	8aae                	mv	s5,a1
ffffffffc0201d92:	bd3d                	j	ffffffffc0201bd0 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201d94:	9902                	jalr	s2
ffffffffc0201d96:	b559                	j	ffffffffc0201c1c <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201d98:	85a6                	mv	a1,s1
ffffffffc0201d9a:	02d00513          	li	a0,45
ffffffffc0201d9e:	e03e                	sd	a5,0(sp)
ffffffffc0201da0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201da2:	8ace                	mv	s5,s3
ffffffffc0201da4:	40800633          	neg	a2,s0
ffffffffc0201da8:	46a9                	li	a3,10
ffffffffc0201daa:	6782                	ld	a5,0(sp)
ffffffffc0201dac:	b515                	j	ffffffffc0201bd0 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201dae:	01b05663          	blez	s11,ffffffffc0201dba <vprintfmt+0x35a>
ffffffffc0201db2:	02d00693          	li	a3,45
ffffffffc0201db6:	f6d798e3          	bne	a5,a3,ffffffffc0201d26 <vprintfmt+0x2c6>
ffffffffc0201dba:	00001417          	auipc	s0,0x1
ffffffffc0201dbe:	18740413          	addi	s0,s0,391 # ffffffffc0202f41 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201dc2:	02800513          	li	a0,40
ffffffffc0201dc6:	02800793          	li	a5,40
ffffffffc0201dca:	bd1d                	j	ffffffffc0201c00 <vprintfmt+0x1a0>

ffffffffc0201dcc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201dcc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201dce:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201dd2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201dd4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201dd6:	ec06                	sd	ra,24(sp)
ffffffffc0201dd8:	f83a                	sd	a4,48(sp)
ffffffffc0201dda:	fc3e                	sd	a5,56(sp)
ffffffffc0201ddc:	e0c2                	sd	a6,64(sp)
ffffffffc0201dde:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201de0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201de2:	c7fff0ef          	jal	ra,ffffffffc0201a60 <vprintfmt>
}
ffffffffc0201de6:	60e2                	ld	ra,24(sp)
ffffffffc0201de8:	6161                	addi	sp,sp,80
ffffffffc0201dea:	8082                	ret

ffffffffc0201dec <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201dec:	00004797          	auipc	a5,0x4
ffffffffc0201df0:	21c78793          	addi	a5,a5,540 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201df4:	6398                	ld	a4,0(a5)
ffffffffc0201df6:	4781                	li	a5,0
ffffffffc0201df8:	88ba                	mv	a7,a4
ffffffffc0201dfa:	852a                	mv	a0,a0
ffffffffc0201dfc:	85be                	mv	a1,a5
ffffffffc0201dfe:	863e                	mv	a2,a5
ffffffffc0201e00:	00000073          	ecall
ffffffffc0201e04:	87aa                	mv	a5,a0
}
ffffffffc0201e06:	8082                	ret

ffffffffc0201e08 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201e08:	00004797          	auipc	a5,0x4
ffffffffc0201e0c:	62878793          	addi	a5,a5,1576 # ffffffffc0206430 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201e10:	6398                	ld	a4,0(a5)
ffffffffc0201e12:	4781                	li	a5,0
ffffffffc0201e14:	88ba                	mv	a7,a4
ffffffffc0201e16:	852a                	mv	a0,a0
ffffffffc0201e18:	85be                	mv	a1,a5
ffffffffc0201e1a:	863e                	mv	a2,a5
ffffffffc0201e1c:	00000073          	ecall
ffffffffc0201e20:	87aa                	mv	a5,a0
}
ffffffffc0201e22:	8082                	ret

ffffffffc0201e24 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201e24:	00004797          	auipc	a5,0x4
ffffffffc0201e28:	1dc78793          	addi	a5,a5,476 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201e2c:	639c                	ld	a5,0(a5)
ffffffffc0201e2e:	4501                	li	a0,0
ffffffffc0201e30:	88be                	mv	a7,a5
ffffffffc0201e32:	852a                	mv	a0,a0
ffffffffc0201e34:	85aa                	mv	a1,a0
ffffffffc0201e36:	862a                	mv	a2,a0
ffffffffc0201e38:	00000073          	ecall
ffffffffc0201e3c:	852a                	mv	a0,a0
}
ffffffffc0201e3e:	2501                	sext.w	a0,a0
ffffffffc0201e40:	8082                	ret

ffffffffc0201e42 <sbi_shutdown>:
void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201e42:	00004797          	auipc	a5,0x4
ffffffffc0201e46:	1ce78793          	addi	a5,a5,462 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201e4a:	6398                	ld	a4,0(a5)
ffffffffc0201e4c:	4781                	li	a5,0
ffffffffc0201e4e:	88ba                	mv	a7,a4
ffffffffc0201e50:	853e                	mv	a0,a5
ffffffffc0201e52:	85be                	mv	a1,a5
ffffffffc0201e54:	863e                	mv	a2,a5
ffffffffc0201e56:	00000073          	ecall
ffffffffc0201e5a:	87aa                	mv	a5,a0
ffffffffc0201e5c:	8082                	ret

ffffffffc0201e5e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201e5e:	715d                	addi	sp,sp,-80
ffffffffc0201e60:	e486                	sd	ra,72(sp)
ffffffffc0201e62:	e0a2                	sd	s0,64(sp)
ffffffffc0201e64:	fc26                	sd	s1,56(sp)
ffffffffc0201e66:	f84a                	sd	s2,48(sp)
ffffffffc0201e68:	f44e                	sd	s3,40(sp)
ffffffffc0201e6a:	f052                	sd	s4,32(sp)
ffffffffc0201e6c:	ec56                	sd	s5,24(sp)
ffffffffc0201e6e:	e85a                	sd	s6,16(sp)
ffffffffc0201e70:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201e72:	c901                	beqz	a0,ffffffffc0201e82 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201e74:	85aa                	mv	a1,a0
ffffffffc0201e76:	00001517          	auipc	a0,0x1
ffffffffc0201e7a:	0e250513          	addi	a0,a0,226 # ffffffffc0202f58 <error_string+0xe8>
ffffffffc0201e7e:	a48fe0ef          	jal	ra,ffffffffc02000c6 <cprintf>
readline(const char *prompt) {
ffffffffc0201e82:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e84:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201e86:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201e88:	4aa9                	li	s5,10
ffffffffc0201e8a:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201e8c:	00004b97          	auipc	s7,0x4
ffffffffc0201e90:	18cb8b93          	addi	s7,s7,396 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e94:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201e98:	aa6fe0ef          	jal	ra,ffffffffc020013e <getchar>
ffffffffc0201e9c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201e9e:	00054b63          	bltz	a0,ffffffffc0201eb4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ea2:	00a95b63          	ble	a0,s2,ffffffffc0201eb8 <readline+0x5a>
ffffffffc0201ea6:	029a5463          	ble	s1,s4,ffffffffc0201ece <readline+0x70>
        c = getchar();
ffffffffc0201eaa:	a94fe0ef          	jal	ra,ffffffffc020013e <getchar>
ffffffffc0201eae:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201eb0:	fe0559e3          	bgez	a0,ffffffffc0201ea2 <readline+0x44>
            return NULL;
ffffffffc0201eb4:	4501                	li	a0,0
ffffffffc0201eb6:	a099                	j	ffffffffc0201efc <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201eb8:	03341463          	bne	s0,s3,ffffffffc0201ee0 <readline+0x82>
ffffffffc0201ebc:	e8b9                	bnez	s1,ffffffffc0201f12 <readline+0xb4>
        c = getchar();
ffffffffc0201ebe:	a80fe0ef          	jal	ra,ffffffffc020013e <getchar>
ffffffffc0201ec2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201ec4:	fe0548e3          	bltz	a0,ffffffffc0201eb4 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ec8:	fea958e3          	ble	a0,s2,ffffffffc0201eb8 <readline+0x5a>
ffffffffc0201ecc:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201ece:	8522                	mv	a0,s0
ffffffffc0201ed0:	a2afe0ef          	jal	ra,ffffffffc02000fa <cputchar>
            buf[i ++] = c;
ffffffffc0201ed4:	009b87b3          	add	a5,s7,s1
ffffffffc0201ed8:	00878023          	sb	s0,0(a5)
ffffffffc0201edc:	2485                	addiw	s1,s1,1
ffffffffc0201ede:	bf6d                	j	ffffffffc0201e98 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201ee0:	01540463          	beq	s0,s5,ffffffffc0201ee8 <readline+0x8a>
ffffffffc0201ee4:	fb641ae3          	bne	s0,s6,ffffffffc0201e98 <readline+0x3a>
            cputchar(c);
ffffffffc0201ee8:	8522                	mv	a0,s0
ffffffffc0201eea:	a10fe0ef          	jal	ra,ffffffffc02000fa <cputchar>
            buf[i] = '\0';
ffffffffc0201eee:	00004517          	auipc	a0,0x4
ffffffffc0201ef2:	12a50513          	addi	a0,a0,298 # ffffffffc0206018 <edata>
ffffffffc0201ef6:	94aa                	add	s1,s1,a0
ffffffffc0201ef8:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201efc:	60a6                	ld	ra,72(sp)
ffffffffc0201efe:	6406                	ld	s0,64(sp)
ffffffffc0201f00:	74e2                	ld	s1,56(sp)
ffffffffc0201f02:	7942                	ld	s2,48(sp)
ffffffffc0201f04:	79a2                	ld	s3,40(sp)
ffffffffc0201f06:	7a02                	ld	s4,32(sp)
ffffffffc0201f08:	6ae2                	ld	s5,24(sp)
ffffffffc0201f0a:	6b42                	ld	s6,16(sp)
ffffffffc0201f0c:	6ba2                	ld	s7,8(sp)
ffffffffc0201f0e:	6161                	addi	sp,sp,80
ffffffffc0201f10:	8082                	ret
            cputchar(c);
ffffffffc0201f12:	4521                	li	a0,8
ffffffffc0201f14:	9e6fe0ef          	jal	ra,ffffffffc02000fa <cputchar>
            i --;
ffffffffc0201f18:	34fd                	addiw	s1,s1,-1
ffffffffc0201f1a:	bfbd                	j	ffffffffc0201e98 <readline+0x3a>
