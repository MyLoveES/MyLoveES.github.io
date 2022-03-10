title: Linux - AVX512 造成程序 crash
date: 2022-03-07
tags: [Linux]
categories: Linux
toc: true
---

## 背景
服务运行不起来，ps aux查看state始终处在 Dl+ 状态  
查看dmesg或者cat /var/log/messages，发现 **trap invalid opcode** 和 **segfault at**.  查过后，可能是指令集问题。  
{% asset_img trap_invalid_opcode %}
{% asset_img segment_at %}

## 解释
 
ip:c14490 sp:7f975324f790 error:0 in xxxx[400000+53a3d000]  
其中，  
- ip: 指令(内存)指针
- sp: 堆栈指针地址（栈顶指针）
- [xxxx+yyyy] : 虚拟内存起始地址、大小
- error number: 4 -> 100
> bit2: 值为1表示是用户态程序内存访问越界，值为0表示是内核态程序内存访问越界  
> bit1: 值为1表示是写操作导致内存访问越界，值为0表示是读操作导致内存访问越界  
> bit0: 值为1表示没有足够的权限访问非法地址的内容，值为0表示访问的非法地址根本没有对应的页面，也就是无效地址  

出错地址： 0xc14490 - 0x400000 = 0x814490   

反汇编，执行(很不幸，我反编译失败了)
```
objdump -D xxxx > obj
```

检索 0814490 
尝试在老CPU上重新编译，运行无错。  

> ref: https://blog.csdn.net/wangtingting_100/article/details/83749504  
> ref: https://stackoverflow.com/questions/2549214/interpreting-segfault-messages  
> ref: https://utcc.utoronto.ca/~cks/space/blog/linux/KernelSegfaultMessageMeaning


## 贴一下 starkoverflow 上的操作

### **If this were a program, not a shared library**
Run `addr2line -e yourSegfaultingProgram c14490` (and repeat for the other instruction pointer valUes given) to see where the error is happening. Better, get a debug-instrumented build, and reproduce the problem under a debugger such as gdb.

### **Since it's a shared library**
You're hosed, unfortunately; it's not possible to know where the libraries were placed in memory by the dynamic linker after-the-fact. Reproduce the problem under gdb.

### What the error means
Here's the breakdown of the fields:  
- address (after the at) - the location in memory the code is trying to access (it's likely that c14490 are offsets from a pointer we expect to be set to a valid value but which is instead pointing to 0)
- ip - instruction pointer, ie. where the code which is trying to do this lives (指令指针，即尝试执行此操作的代码所在的位置)
- sp - stack pointer (堆栈指针)
- error - An error code for page faults; see below for what this means on x86 [link](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/include/asm/trap_pf.h?h=v5.16#n5).

```
/*
 * Page fault error code bits:
 *
 *   bit 0 ==    0: no page found       1: protection fault
 *   bit 1 ==    0: read access         1: write access
 *   bit 2 ==    0: kernel-mode access  1: user-mode access
 *   bit 3 ==                           1: use of reserved bit detected
 *   bit 4 ==                           1: fault was an instruction fetch
 *   bit 5 ==                           1: protection keys block access
 *   bit 15 ==                          1: SGX MMU page-fault
 */
```

## 贴另一个blog，更详尽的解释
### What the Linux kernel's messages about segfaulting programs mean on 64-bit x86

For quite a while the Linux kernel has had an option to log a kernel message about every faulting user program, and it probably defaults to on in your Linux distribution. I've seen these messages fly by for years, but for reasons beyond the scope of this entry I've recently wanted to understand what they mean in some moderate amount of detail.  

很长一段时间以来，Linux 内核都有一个选项来记录有关每个错误用户程序的内核消息，并且它可能在您的 Linux 发行版中默认为开启。多年来，我一直看到这些消息飞来飞去，但由于超出本文范围的原因，我最近想以适度的细节了解它们的含义。     

I'll start with a straightforward and typical example, one that I see every time I build and test Go (as this is a test case that is supposed to crash):  
我将从一个简单而典型的示例开始，我每次构建和测试 Go 时都会看到这个示例（因为这是一个应该崩溃的测试用例）：  
```
testp[19288]: segfault at 0 ip 0000000000401271 sp 00007fff2ce4d210 error 4 in testp[400000+98000]
```

The meaning of this is:   
- 'testp[19288]' is the faulting program and its PID
- 'segfault at 0' tells us the memory address (in hex) that caused the segfault when the program tried to access it. Here the address is 0, so we have a null dereference of some sort.(告诉我们当程序试图访问它时导致段错误的内存地址（十六进制）。这里的地址是 0，所以我们有某种类型的空解引用。)
- 'ip 0000000000401271' is the value of the instruction pointer at the time of the fault. This should be the instruction that attempted to do the invalid memory access. In 64-bit x86, this will be register %rip (useful for inspecting things in GDB and elsewhere).(是故障时指令指针的值。这应该是试图进行无效内存访问的指令。在 64 位 x86 中，这将是寄存器 %rip（用于检查 GDB 和其他地方的内容）)
- 'sp 00007fff2ce4d210' is the value of the stack pointer. In 64-bit x86, this will be %rsp.(是堆栈指针的值。在 64 位 x86 中，这将是 %rsp。)(是来自traps.herror 4的十六进制页面错误代码位 ，和往常一样，几乎总是至少为 4（这意味着“用户模式访问”）。值 4 表示读取未映射区域，例如地址 0，而值 6 (4+2) 表示写入未映射区域)
- 'error 4' is the page fault error code bits from traps.h in hex, as usual, and will almost always be at least 4 (which means 'user-mode access'). A value of 4 means it was a read of an unmapped area, such as address 0, while a value of 6 (4+2) means it was a write of an unmapped area.
- 'in testp[400000+98000]' tells us the specific virtual memory area that the instruction pointer is in, specifying which file it is (here it's the executable), the starting address that VMA is mapped at (0x400000), and the size of the mapping (0x98000).(告诉我们指令指针所在的特定虚拟内存区域，指定它是哪个文件（这里是可执行文件），VMA 映射的起始地址（0x400000），以及映射的大小（0x98000）)

With a faulting address of 0 and an error code of 4, we know this particular segfault is a read of a null pointer.  
错误地址为 0，错误代码为 4，我们知道这个特定的段错误是对空指针的读取。  
Here's two more error messages:

```
bash[12235]: segfault at 1054808 ip 000000000041d989 sp 00007ffec1f1cbd8 error 6 in bash[400000+f4000]
```

'Error 6' means a write to an unmapped user address, here 0x1054808.    
“错误 6”表示写入未映射的用户地址，此处为 0x1054808。  
```
bash[11909]: segfault at 0 ip 00007f83c03db746 sp 00007ffccbeda010 error 4 in libc-2.23.so[7f83c0350000+1c0000]
```

Error 4 and address 0 is a null pointer read but this time it's in some libc function, not in bash's own code, since it's reported as 'in libc-2.23.so[...]'. Since I looked at the core dump, I can tell you that this was in strlen().  
错误 4 和地址 0 是读取的空指针，但这次是在某个 libc 函数中，而不是在 bash 自己的代码中，因为它被报告为“在 libc-2.23.so[...]”中。由于我查看了核心转储，我可以告诉你这是在strlen().  
On 64-bit x86 Linux, you'll get a somewhat different message if the problem is actually with the instruction being executed, not the address it's referencing. For example:
在 64 位 x86 Linux 上，如果问题实际上出在正在执行的指令上，而不是它所引用的地址上，那么您将收到一条稍微不同的消息。例如：  
```
bash[2848] trap invalid opcode ip:48db90 sp:7ffddc8879e8 error:0 in bash[400000+f4000]
```

There are a number of such trap types set up in traps.c. Two notable additional ones are 'divide error', which you get if you do an integer division by zero, and 'general protection', which you can get for certain extremely wild pointers (one case I know of is when your 64-bit x86 address is not in 'canonical form'). Although these fields are formatted slightly differently, most of them mean the same thing as in segfaults. The exception is 'error:0', which is not a page fault error code. I don't understand the relevant kernel code enough to know what it means, but if I'm reading between the lines correctly in entry_64.txt, then it's either 0 (the usual case) or an error code from the CPU. Here is one possible list of exceptions that get error codes.
在traps.c中设置了许多此类陷阱类型。两个值得注意的附加错误是“除法错误”，如果你将整数除以零，你会得到它，以及“一般保护”，你可以得到某些非常狂野的指针（我知道的一种情况是当你的 64 位 x86地址不是“规范形式”）。尽管这些字段的格式略有不同，但它们中的大多数与段错误中的含义相同。例外是“ error:0”，它不是页面错误错误代码。我对相关内核代码的理解不足以知道它的含义，但是如果我在entry_64.txt中的行之间正确读取，那么它要么是 0（通常情况），要么是来自 CPU 的错误代码。这里是获取错误代码的一个可能的异常列表。  

Sometimes these messages can be a little bit unusual and surprising. Here is a silly sample program and the error it produces when run. The code:
有时这些消息可能有点不寻常和令人惊讶。这是一个愚蠢的示例程序以及它在运行时产生的错误。代码：  
```
#include <stdio.h>
int main(int argc, char **argv) {
   int (*p)();
   p = 0x0;
   return printf("%d\n", (*p)());
}
```

If compiled (without optimization is best) and run, this generates the kernel message:
如果编译（最好没有优化）并运行，这会生成内核消息：  
```
a.out[3714]: segfault at 0 ip           (null) sp 00007ffe872aa418 error 14 in a.out[400000+1000]
```

The '(null)' bit turns out to be expected; it's what the general kernel printf() function generates when asked to print something as a pointer and it's null (as seen here). In our case the instruction pointer is 0 (null) because we've made a subroutine call through a null pointer and thus we're trying to execute code at address 0. I don't know why the 'in ...' portion says that we're in the executable (although in this case the call actually was there).  

The error code of 14 is in hex, which means that as bits it's 010100. This is a user mode read of an unmapped area (our usual '4' case), but it's an instruction fetch, not a normal data read or write. Any error 14s are a sign of some form of mangled function call or a return to a mangled address because the stack has been mashed.   

' (null)' 位是预期的；这是一般内核 printf() 函数在被要求将某些内容作为指针打印并且它为 null 时生成的内容（如此处所示）。在我们的例子中，指令指针为 0（空），因为我们通过空指针进行了子程序调用，因此我们试图在地址 0 处执行代码。我不知道为什么“in ...”部分表示我们在可执行文件中（尽管在这种情况下调用实际上在那里）。  

错误代码 14 是十六进制的，这意味着它的位是 010100。这是对未映射区域的用户模式读取（我们通常的“4”情况），但它是指令获取，而不是正常的数据读取或写入。任何错误 14s 都是某种形式的函数调用错误或返回到错误地址的标志，因为堆栈已被混合。  

(These bits turn out to come straight from the CPU's page fault IDT.) . 

For 64-bit x86 Linux kernels (and possibly for 32-bit x86 ones as well), the code you want to look at is show_signal_msg in fault.c, which prints the general 'segfault at ..' message, do_trap and do_general_protection in traps.c, which print the 'trap ...' messages, and print_vma_addr in memory.c, which prints the 'in ...' portion for all of these messages.  

#### Sidebar: The various error code bits as numbers

|       |       |
|-------|-------|
|+1|protection fault in a mapped area (eg writing to a read-only mapping) 映射区域中的保护故障（例如写入只读映射）|
|+2|write (instead of a read)|
|+4|user mode access (instead of kernel mode access)|
|+8|use of reserved bits in the page table entry detected (the kernel will panic if this happens) use of reserved bits in the page table entry detected (the kernel will panic if this happens)|
|+16 (+0x10)|fault was an instruction fetch, not data read or write|
|+32 (+0x20)|'protection keys block access' (don't ask me)|

Hex 0x14 is 0x10 + 4; (hex) 6 is 4 + 2. Error code 7 (0x7) is 4 + 2 + 1, a user-mode write to a read-only mapping, and is what you get if you attempt to write to a string constant in C:  
```
char *ex = "example";
int main(int argc, char **argv) {
   *ex = 'E';
}
```
Compile and run this and you will get:
```
a.out[8832]: segfault at 400540 ip 0000000000400499 sp 00007ffce6831490 error 7 in a.out[400000+1000]
```
It appears that the program code always gets loaded at 0x400000 for ordinary programs, although I believe that shared libraries can have their location randomized.  

PS: Per a comment in the kernel source, all accesses to addresses above the end of user space will be labeled as 'protection fault in a mapped area' whether or not there are actual page table entries there. The kernel does this so you can't work out where its memory pages are by looking at the error code.  
   
(I believe that user space normally ends around 0x07fffffffffff, per mm.txt, although see the comments about TASK_SIZE_MAX in processor.h and also page_64_types.h.) . 