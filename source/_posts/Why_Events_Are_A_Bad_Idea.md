title: Why events are bad idea
date: 2022-03-21
tags: [Business]
categories: Business
toc: true
---
### Why Events Are A Bad Idea
- 论点：线程可以实现事件的所有优点，包括支持高并发性、低开销和简单的并发模型。此外，线程允许更简单和更自然的编程风格。
> Specifically, we believe that threads can achieve all of the strengths of events, including support for high concurrency, low overhead, and a simple concurrency model. Moreover, we argue that threads allow a simpler and more natural programming style.

过去的一段时间（论文发表前），人们热保温Event-oriented是高并发程序中实现高性能的最佳方法。主要原因有：
1. 由于协作多任务处理，同步成本低廉;
2. 管理状态的开销更低(没有栈);
3. 基于应用级的信息，更好的调度和局部性;
4. 更灵活的控制流(不仅仅是调用/返回);

但是作者认为：
1. 线程为高并发服务器提供了一个更自然的抽象;
2. 对编译器和线程运行时系统的小改进可以消除使用事件的历史原因;
3. **线程更易于接受基于编译器的增强;**
```
• Inexpensive synchronization due to cooperative multitasking;
• Lower overhead for managing state (no stacks);
• Better scheduling and locality, based on
application-level information; and
• More flexible control flow (not just call/return).

We believe that (1) threads provide a more natural abstraction for high-concurrency servers, and that (2) small improvements to compilers and thread runtime systems can eliminate the historical reasons to use events. Additionally, threads are more amenable to compiler-based enhancements; we believe the right paradigm for highly concurrent applications is a thread package with better compiler support.
```

### Why Threads Are A Bad Idea