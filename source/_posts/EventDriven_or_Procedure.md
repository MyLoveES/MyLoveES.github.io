title: 事件驱动 or 面向过程
date: 2022-03-21
tags: [Business]
categories: Business
toc: true
---

# EventDriven-oriented or Procedure-oriented

两类常见的系统设计：事件驱动、面向过程。  
本文意图解释两类系统设计之间的关系，孰优孰劣？

## Who are they

### Event Driven

{% asset_img EventDriven-workers.png %}

**相对**较小的进程数量，进程之间进行显式消息通信。针对于事件驱动，有多种实现形式，例如观察者模式或者发布订阅模式等。  
```
1. Small number of (relatively static) big processes
2. Explicit set of message channels
3. Limited amount of direct sharing of data in memory
```

- 观察者模式  
{% asset_img Observer.png %}

- 发布订阅模式
{% asset_img Publisher-Subscriber.png %}

它的特点是事件的产生者并不关心具体的处理逻辑，每个环节的workers都能够专注于自己的工作
```
事件驱动的优点：
1. 解耦：事件发布者、订阅者解耦，其中一个环节的变化，不会影响其他环境的进行
2. 异步：各个环节通过事件关联，所以服务间不会block。带来执行的可调度性，资源分配的动态性
3. 灵活：在服务间增加一些适配器（如日志、认证、版本、限流、降级、熔断等）相当容易
4. 独立：服务间的吞吐也被解开了，各个服务可以专注于自己的实现，按照自己的处理速度处理
5. 缓冲：利用 Broker 或队列的方式还可以达到把抖动的吞吐量变成均匀的吞吐量，这就是所谓的“削峰”，这对后端系统是个不错的保护
```

### Procedure-oriented

{% asset_img Procedure.png %}

大量快速变化的小进程和基于共享数据的进程同步机制  
它的特点是一次请求从一而终，由单一的线程（进程）执行  
```
1. Large number of very small processes
2. Rapid creation and deletion of processes
3. Communication by means of direct sharing of
data in memory
```
```
面向过程的优点：
1. 架构简单明了，易于实现
2. 各环节在在同一线程/进程内完成，易于追踪(debug)
3. 实时性强，任务从一而终
```

## The Duality Mapping

{% asset_img MessageEqualsThread.png %}

```
<On the Duality of Operating System Structures>
1. The two models are duals of each other. That is, a program or subsystem constructed strictly according to the primitives defined by one model can be mapped directly into a dual program or subsystem which fits the other model.
2. The dual programs or subsystems are logically identical to each other. They can also be made textually very similar, differing only in non-essential details.
3. The performance of a program or subsystem from one model, as reflected by its queue lengths, waiting times, service rates, etc. is identical to that of its dual system, given identical scheduling strategies. Furthermore, the primitive operations provided by the operating system of one model can be made as efficient as their duals of the other model.

1. 两类模型互为对偶，两者可以互相转换。
2. 逻辑上两者彼此相似，甚至可以在文本上表现得非常相似，除了非必要的细节上。
3. 在相同的调度策略下，两类模型的性能可以一样高（根据队列长度、等待时间、处理速度等方面观测）。除此之外，一个模型提供的基本操作可以使其效率和另一个模型一样高。
```

### Event Driven: simpler concurrency model
<details>
<summary>原文</summary>

```
Messages and message identifiers. A message is a data structure meant for sending information from one process to another; it typically contains a small, fixed area for data which is passed by value and space for a pointer to larger data structures which must be passed by reference. A message identifier is a handle by which a particular message can be identified.
Message channels and message ports. A message channel is an abstract structure which identifies the destination of a message. A message port is queue capable of holding messages of a certain class or type which might be received by a particular process. Each message channel must be bound to a particular message port before is can be used. A message port, however, may have more than one message channel bound to it.
Four message transmission operations:
    1. SendMessage[messageChannel, messageBody] returns [messageId] 
       This operation simply queues a new message on the port bound to the the messageChannel named as parameter. 
       The messageld returned is used as parameter to the following operation.
    2. AwaitReply(messageId] returns [messageBody] 
       The operation causes the process to wait for a reply to a specific message previously sent via SendMessage.
    3. WaitForMessage[set of messagePort] returns [messageBody, messageld, messagePort] 
       This operation allows a process to wait for a new (unsolicited) message on any one of the message ports named in the 'parameter. 
       The message which is first on the queue is returned, along with a message identifier for future reference and an indication of the port from which that message came.
    4. SendReply[messageId, messageBody]
       This operation sends a reply to the particular message identified by the message identifier.


SKIP FIGURE

In this process, the kind of service requested is a function of which port the requesting message arrives on. It may or may not involve making requests of still other processes and/or sending a reply back to the requestor. It may also result in some circumstance, such as the exhaustion of a resource, which prevents further requests from being considered. These remain queued on their port until later, when the process is willing to listen on that port again.
Note that if a whole system is built according to this style, then the sole means of interaction among the components of that system is by means of the message facility. Each process can operate in its own address space without interference from the others. Because of the serial way in which requests are handled, there is never any need to protect the state information of a process from multiple, simultaneous access and updating.
``` 
</details>  

#### 一些概念的定义：  
> Messages: 数据结构，用于进程之间传递信息。  
> Message identifiers: 消息 id  
> Message channels: 消息目的地  
> Message ports: 接收端口  

> SendMessage [messageChannel, messageBody] returns [messageId]  
> AwaitReply [messageId] returns [messageBody]
> WaitForMessage [set of messagePort] returns [messageBody, messageld, messagePort]
> SendReply [messageId, messageBody]

{% asset_img MessageDefinition.png %}

#### 运行公式
```
begin m: messageBody; 
    i: messageld;
    p: portid;
    s: set of portid;
    ... -local data and state information for this process
    initialize;
    do forever;
        [m, i, p] <- WaitForMessage[s];
        case p of
            port1 =>...; -algorithm for port1
            port2 =>... 
                    if resourceExhausted then 
                        s <- s - port2; 
                    SendReply[i, reply];
                    ...; -algorithm for port2
            portk =>...
                    s <- s + port2
                    ...; -algorithm for portk
        endcase; 
    endloop;
end.
```

### Procedure-oriented: simpler & natural programming style

<details>
<summary>原文</summary>

```
1. Procedures. A procedure is a piece of Mesa text containing algorithms, local data, parameters, and results. It always operates in the scope of a Mesa module and may access any global data declared in that module (as well as in any containing procedures).

2. Procedure call facilities, synchronous and asynchronous. The synchronous procedure call mechanism is just the ordinary Mesa procedure call statement, which may return results. This is very much like procedure or function calls in Algol, Pascal, etc. The asynchronous procedure call mechanism is represented by the FORK and JOIN statements, which are defmed as follows:
    1) processld <- FORK procedureName[parameterList] - This statement starts the procedure executing as a new process with its own parameters. The procedure operates in the context of its declaration, just as if it had been called synchronously, but the process has its own call stack and state. The calling process continues executing from the statement following the FORK. The process identifier returned from FORK is used in the next statement
    2) [resultList] <- JOIN processld - This statement causes the process executing it to synchronize itself with the termination of the process named by the process identifier. The results are retrieved from that process and returned to the calling process as if they had been returned from an ordinary procedure call. The JOlNed process is then destroyed and execution continues in the JOlNing process from the statement following the JOIN.

3. Modules and monitors. A module is the primitive Mesa unit of compilation and consists of a collection of procedures and data. The scope rules of the language determine which of these. procedures and data are accessible or callable from outside the module. A monitor is a special kind of Mesa module which has associated with it a lock to prevent more than one process from executing inside of it at any one time. It is based on and very similar to the monitor mechanism described by Hoare[6].

4. Module instantiation. Modules (including monitor modules) may be instantiated in Mesa by means of the NEW and START statements. These cause a new context to be created for holding the module data, provide the binding from external procedure references within the module to procedures declared in other modules, and activate the initialization code of the module.

5. Condition variables. Condition variables are part of Hoare's monitor mechanism an provide more flexible synchronization among events than mutual exclusion facility of the monitor lock or the process termination facility of the JOIN statement. In our model, a condition variable, must be contained within a monitor, has associated with it a queue of processes, and has two operations defined on it:
    1) WAIT conditionVariable - This causes the process executing it to release the monitor lock, suspend execution, and join the queue associated with that condition variable.
    2) SIGNAL condition Variable -- This causes a process which has previously WAITed on the condition variable to resume execution from its next statement when it is able to reclaim the monitor lock.

Note that because the FORK and JOIN operations apply to procedures which are already declared and bound to the right context, these operations take the same order of magnitude of time to execute as do simple procedure calls and returns. Thus processes are very lightweight, and can be created and destroyed very frequently. Module and monitor instantiation, on the other hand, is more cumbersome and is usually done statically before the system is started. Note that this canonical model has no module deletion facility.

SKIP FIGURE

The attribute ENTRY is used to distinguish procedures which are called from outside the monitor, thus seizing the monitor lock, from those which are declared purely internal to the monitor. Any of the procedures in this module may, of course, call procedures declared in other modules for other system services before returning. Within the monitor, condition variables are used to control waiting for circumstances such as the availability of resources. These are used in this standard resource manager ,tp control the access of a process the procedure representing a particular kind of service.

If a whole system is built in this style, then the sole means of interaction among its components is procedural. Processes move from one context to another by means of the procedure call facility across module boundaries, and they use asynchronous calls to stimulate concurrent activity. They depend upon monitor locks and condition variables to keep out of the way of each other. Thus no process can be associated with a single address space unless that space be the whole system.
``` 
</details>  

#### 一些概念的定义
> Procedure  
> Procedure call facilities, synchronous and asynchronous   
  -- (asynchronous):   
  ---- processld <- FORK procedureName[parameterList]  
  ---- [resultList] <- JOIN processld  
> Modules: consists of a collection of procedures and data  
> Monitors: 监控锁防止多进程在其中执行  
> Module instantiation: 实例化  
> Condition variables:   
  -- WAIT condition Variable  
  -- SIGNAL condition Variable  
  

#### 运行公式
```
ResourceManager: MONITOR =
    C: CONDITION;
    resourceExhausted: BOOLEAN;
    ... -global data and state information for this process

    proc1: ENTRY PROCEDURE[...] =
           ...; -algorithm for prod
    proc2: ENTRY PROCEDURE[...] RETURNS[...] = 
           BEGIN
                IF resourceExhausted THEN WAIT c;
                •••;
                RETURN[results]; 
                •••;
                END; -algorithm for proc2
    procL: ENTRY PROCEDURE[...] = 
           BEGIN
                resourceExhausted <- FALSE; 
                SIGNAL C;
                ...;
           END; -algorithm for procL endloop;
    endloop;
    initialize;
END
```

### The Duality Mapping

|          |          |
|----------|----------|
|Processes, CreateProcess|Monitors, NEW/START|
|Message Channels|External Procedure identifiers|
|Message Ports|ENTRY procedure identifier|
|SendMessage; AwaitReply (immediate) |simple procedure call|
|SendMessage; AwaitReply (delayed) |fork;join|
|SendReply|RETURN (from procedure)|
|main loop of standard resource manager, WaitForMessage statement, case statement|monitor lock, ENTRY attribute|
|arms of the case statement|ENTRY procedure declaration|
|selective waiting for messages|condition variables, WAIT, SIGNAL|

{% asset_img DualityMappingServers.png %}
{% asset_img DualityMappingClients.png %}
{% asset_img DualityMappingCodes.png% }


#### 番外
在之后的另一篇文章，Why Events Are A Bad Idea 里面，作者的解释性对比
|        |        |
|--------|--------|
|event handlers|monitors|
|events accepted by a handler|functions exported by a module|
|SendMessage / AwaitReply|procedure call, or fork/join|
|SendReply|return from procedure|
|waiting for messages|waiting on condition variables|


### 性能

1. 程序本身执行时间
{% asset_img DualityMappingCodes.png %}
2. 调用系统操作开销（可以理解为调用第三方开销？）
{% asset_img SystemCall.png %}
3. 队列等待时间（反映的是阻塞、资源竞争、调度策略）

二元性变换使构成系统的程序主体不受影响。因此，所有的算法将以相同的速度计算，并且在每个数据结构中存储相同数量的信息。在每个系统中执行的代码数量相同。将执行相同数量的加法、乘法、比较和字符串操作。因此，如果基本的处理器特性没有改变，那么这些特性将需要相同数量的计算能力，并且系统性能的这个组件将保持不变。同样，对于系统调用开销和队列阻塞等待，两者会付出同样的代价。
<details>
    <summary>原文</summary>

```
The duality transformation leaves the main bodies of the programs comprising the system untouched. Thus the algorithms will all compute at the same speed, and the same amount of information will be stored in each data structure. The same amount of client code will be executed in each of the dual systems. The same number of additions, multiplications, comparisons, -and string operations will be performed. Therefore if basic processor characteristics are unchanged, then these will take precisely the same amount of computing power, and this component of the system performance will remain unchanged.
The other component affecting the speed of execution of a single program is the time it takes to execute each of the primitive system operations it calls. We assert without proof that the facilities of each of our two canonical models can be made to execute as efficiently as the corresponding facilities of the other model. I.e.,
Sending a message, with its inherent need to allocate a message block and manipulate a queue and its possibility of forcing a context (process) switch, is a computation of the same complexity as that of calling or FOR King to an ENTRY procedure, which involves the same need to allocate, queue, and force a context switch.
Leaving a monitor, with the possibility of having to unqueue a waiting process and re-enter it, is an operation of the same complexity as that of waiting for new messages.
Process switching can be made equally fast in either system, and for similar machine architectures this means saving the same amount of state information. The same is true for the scheduling and dispatching of processes at the 'microscopic' level.
14
ON THE DUALITY OF OPERATING SYSTEM STRUCTURES
Virtual memory and paging or swapping can even be used with equal effectiveness in either model.
```
</details>

## But, who is better ?

> ref: (On the Duality of Operating System Structures)[https://courses.cs.vt.edu/~cs5204/fall07-gback/papers/p3-lauer.pdf]
