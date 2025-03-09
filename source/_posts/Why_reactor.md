title: Why Reactor
date: 2025-03-09
tags: [Architecture]
categories: Architecture
toc: true
---

# 响应式编程 vs 传统同步模型

---

## 一、传统模型的性能困境

### 1.1 现实中的例子
```plaintext
假设一个银行有10个柜台（线程池大小为10）：
- 每个客户（请求）需要占用柜台5分钟（包含等待IO的时间）
- 当同时有100个客户时，90个客户必须排队等待
- 即使柜员实际工作时间只有1分钟（CPU计算），其他4分钟都在等待（IO阻塞）
```
### 1.2 传统模型的瓶颈

```
  ┌───────────┐       ┌───────────┐
请求队列 → │ 线程池    │ → 1:1 → │ 阻塞IO    │
  │ (200线程) │       │ (DB/HTTP) │
  └───────────┘       └───────────┘

关键问题：
- 假设CPU处理本身需要10ms，而下游响应延迟从10ms升至500ms时：
  吞吐量从 200/(0.01+0.01)=10,000 QPS 
  暴跌至 200/(0.5+0.01)=392 QPS
```

- 线程资源浪费：大量时间浪费在等待IO（数据库、网络调用）
- 高并发场景下：线程池爆满，请求排队，响应延迟飙升

> 例如：Tomcat默认200线程池，下游ASR响应慢时，线程池耗尽，新的请求无法接受，触发Pod重启。

## 二、WebFlux：事件驱动
### 2.1 架构对比
#### 2.1.1 传统Servlet模型
```
[工作流程]
1. 接受请求 → 分配线程
2. 线程执行 → 阻塞等待
3. 获取结果 → 返回响应
4. 释放线程

[资源时间线示例]
线程1：█░░░░░░░░░（80%时间在等待）
线程2：███░░░░░░░
线程3：░░░░░░░░░░
```

#### 2.1.2 WebFlux响应式模型
```
[工作流程]
1. 接受请求 → 注册回调
2. 立即释放线程 → 处理其他请求
3. 下游响应就绪 → 事件循环调度处理
4. 生成响应 → 无需等待

[资源时间线示例]
线程1：██████████（持续处理事件）
线程2：██████████
（仅需2-4个核心线程）
```

### 2.1.3 传统模型 vs WebFlux模型对比

| 维度       | 传统模型（Servlet）    | WebFlux（Reactive）           |
| ---------- | ---------------------- | ----------------------------- |
| 线程模型   | 1请求1线程（阻塞）     | 少量线程 + 事件循环（非阻塞） |
| 资源消耗   | 高（线程数≈并发数）    | 低（线程数≈CPU核心数）        |
| 编程范式   | 同步阻塞（Imperative） | 异步非阻塞（Declarative）     |
| 吞吐量瓶颈 | 线程池大小             | CPU/网络带宽                  |

## 2.2 响应式的形象化解释
```java
// 传统模型：同步等待结果（线程被阻塞）
String data = database.query(); // <- 线程在这里卡住！
response.send(data);

// WebFlux：订阅数据流（线程立即释放）
Mono<String> mono = database.reactiveQuery();
mono.subscribe(data -> response.send(data));
```
*关键机制：*
1. 事件循环（Event Loop）
- 少数线程轮询事件队列
- 当IO就绪时触发回调，不空等

2. 背压（Backpressure）
- 生产者（Publisher）根据消费者（Subscriber）的处理能力动态调整数据流速

3. 数据流操作符
- 使用Flux（0-N个元素）和Mono（0-1个元素）组合异步操作
```java
webClient.get()
    .uri("/api/users")
    .retrieve()
    .bodyToFlux(User.class)
    .filter(user -> user.age > 18)
    .take(10)
    .subscribe(System.out::println);
```

## 三、WebFlux的优势与代价

### 3.1 优势：何时选择WebFlux

| 场景                     | 传统模型 | WebFlux | 原因                  |
| ------------------------ | -------- | ------- | --------------------- |
| 流式数据传输（日志推送） | ❌        | ✅       | 天然支持SSE/WebSocket |
| CPU密集型任务            | ✅        | ❌       | 非阻塞模型无优势      |
| 微服务网关（聚合请求）   | ⚠️        | ✅       | 异步组合多个服务响应  |

### 3.2 代价：使用WebFlux的挑战

#### 3.2.1 编程习惯
- 从"按步骤执行"到"定义数据流管道"
- 调试困难：堆栈跟踪包含大量反应式操作符
- 不方便的“上下文传递”（需要使用Reactor的Context，以及自定义WebFilter等）
```
Mono<String> data = webClient.get()
    .uri("/api")
    .retrieve()
    .bodyToMono(String.class)
    .flatMap(response -> 
        Mono.deferContextual(ctx -> {
            String requestId = ctx.get("requestId"); // 从上下文中获取
            return processResponse(response, requestId);
        })
    )
    .contextWrite(Context.of("requestId", "12345")); // 写入上下文
```

#### 3.2.2 生态限制
| 支持响应式的组件 | 传统阻塞组件 |
| ---------------- | ------------ |
| R2DBC            | JDBC         |
| WebClient        | RestTemplate |

- 达梦数据库R2DBC大坑：
https://note.youdao.com/s/K3VE8Se9

#### 3.2.3 代码示例
  
https://gitlab.corp.youdao.com/zhiyun/privatization_centre/doc_trans_task

## 四、性能测试
  
代码地址：https://gitlab.corp.youdao.com/ruili/mrsix


## 五、总结：WebFlux不是银弹
### 5.1 结论
- 适合：IO密集型、高并发、延迟敏感型系统
- 不适合：简单CRUD应用、强依赖阻塞生态的场景
- 核心价值：资源利用率提升，而非绝对性能

### 5.2 决策 Checklist
- 是否“真的”有高并发需求
- 能否使用响应式数据库驱动
- 是否承担调试和维护成本