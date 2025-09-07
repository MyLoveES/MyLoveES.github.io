---
title: Why events are a bad idea
date: 2022-03-23 18:00:00
categories:
- "技术"
tags:
- "架构"
- "事件驱动"
- "理论"
toc: true
---
# Why Events Are A Bad Idea
- 论点：线程可以实现事件的所有优点，包括支持高并发性、低开销和简单的并发模型。此外，线程允许更简单和更自然的编程风格。

<details>
    <summary>原文</summary>

> Specifically, we believe that threads can achieve all of the strengths of events, including support for high concurrency, low overhead, and a simple concurrency model. Moreover, we argue that threads allow a simpler and more natural programming style.
</details>

过去的一段时间（论文发表前），人们认为Event-oriented是高并发程序中实现高性能的最佳方法。
主要原因有：
1. 由于协作多任务处理，同步的成本很低;
2. 管理状态的开销更低(没有栈);
3. 基于应用级的信息，更好的调度和局部性;
4. 更灵活的控制流(不仅仅是调用/返回);

但是作者认为：
1. 线程为高并发服务器提供了一个更自然的抽象;
2. 对编译器和线程运行时系统的小改进可以消除使用事件的历史原因;
3. **线程更易于接受基于编译器的增强;**

<details>
    <summary>原文</summary>

```
• Inexpensive synchronization due to cooperative multitasking;
• Lower overhead for managing state (no stacks);
• Better scheduling and locality, based on
application-level information; and
• More flexible control flow (not just call/return).

We believe that (1) threads provide a more natural abstraction for high-concurrency servers, and that (2) small improvements to compilers and thread runtime systems can eliminate the historical reasons to use events. Additionally, threads are more amenable to compiler-based enhancements; we believe the right paradigm for highly concurrent applications is a thread package with better compiler support.
```
</details>

## Duality Revisited
|        |        |
|--------|--------|
|event handlers|monitors|
|events accepted by a handler|functions exported by a module|
|SendMessage / AwaitReply|procedure call, or fork/join|
|SendReply|return from procedure|
|waiting for messages|waiting on condition variables|

- First, Lauer and Needham ignore the cooperative scheduling used by events for synchronization. 
- Second, most event systems use shared memory and global data structures, which are described as atypical for Lauer and Needham’s message- passing systems.

## “Problems” with Threads

![](ConcurrentTasks.png)

### Performance
> Criticism: 许多尝试使用线程实现的高并发模型并不是很棒  
> 开销的主要来源是，存在和线程数相关的O(n)的操作的存在；并且上下文切换开销大（由于需要保存寄存器和其他状态，以及kernel crossings）。但这些是线程工具包实现的问题，而非线程自身的问题。 // TODO: 什么是上下文切换，并且为什么开销大
### Control flow
> Criticism: 线程是有限制性的控制流。它鼓励程序员对控制流进行过于线性的思考，可能会排除使用更有效的控制流模式。  
> 复杂的控制流模式在实践中是很少见的，并且在不同类型的系统中都需要得到处理。
### Synchronization
> Criticism: 线程同步机制很重 // TODO: 什么是线程同步？我的理解应该是说，加锁保证同步  
> 事件系统认为合作多任务模式"免费"地为它们提供了同步机制，运行时系统无需处理互斥、等待队列等等。但是仅仅是在单处理器上实现，而现在大多是多处理器。
### State Management 
> Criticism: 线程堆栈不是管理实时状态的一种有效方式。线程系统通常面临着堆栈溢出的风险和在大堆栈上浪费虚拟地址空间之间的权衡  
> 作者手动解决

### Scheduling
> Criticism: 线程提供的虚拟处理器模型使运行时系统过于泛化，使其无法做出最佳调度决策 // TODO: 啥意思？  
> 事件系统能够在应用层面上调度事件的交付。因此，应用程序可以执行最短的剩余完成时间调度，有利于某些请求流，或执行其他优化。也有一些证据表明，通过连续运行几个相同类型的事件，事件允许更好的代码定位[9]。然而，Lauer-Needham二元性表明，我们可以将同样的调度技巧应用于合作调度的线程。

### Conclusion
上述论点表明，在高并发性方面，线程的性能至少与事件一样好，而且事件在质量上没有实质性的优势。  
可扩展的用户级线程的缺失为事件风格提供了最大的推动力，但我们已经表明，这一缺陷是现有实现的一个伪命题，而不是线程抽象的一个基本属性。  
（作者认为，上面列举的问题都不是线程本身的锅！都是实现方式造成的！EventDriven和Threads能达到同样的效果！）

## The Case for Threads
对于高并发服务器，线程是更合理的抽象。原因有二：  
1. 并发请求之间，很大程度上是彼此独立的。
2. 处理请求的代码是顺序的。
### Control flow
基于事件的系统，往往会混淆应用程序的事件流，因为不同环节之间实际是通过“事件”连接的。Coder需要记住并且匹配event和环节，并且不便于调试。  
而线程模型表达控制流的方式更自然（线性处理）了，并且线程堆栈封装了足够的信息来进行调试。  

### Exception Handling and State Lifetime
在线程系统中，在异常和正常终止后清理任务状态更简单，因为线程堆栈自然会跟踪该任务的活动状态。  
在事件系统中，任务状态通常是堆分配的。在正确的时间释放这个状态是非常困难的，因为应用程序控制流中的分支(特别是在错误条件下)可能会导致错过释放步骤。 // ?

## Compiler Support for Threads  
编译器和系统紧密结合, 实现更好的安全性和性能!  

### 动态堆栈增长   
运行时调整堆栈大小，避免固定大小堆带来的溢出风险和内存浪费。通过编译器分析来得到所需堆栈空间的上限及增长点。

### 实时状态管理    
清除不必要的状态(state)，检测阻塞调用中持有大量实例的情况等等。

### 同步    
编译器警告数据竞争处来减少错误的发生。

## Conclusion  
线程模型能够达到和事件驱动几乎一样的性能效果，并且模型更简单，更易于编译器分析，因此 Threads 是一个更好的编程模型。

# Ref
> ref: [Why events are a bad idea](http://capriccio.cs.berkeley.edu/pubs/threads-hotos-2003.pdf)