title: （业务）网关选型
date: 2022-03-10
tags: [Business, Gateway]
categories: Business
toc: true
---

## What & Why
- Single entry point for all clients (面向客户端的单一入口)  
- Common in microservice architectures （微服务需要业务聚合）  
- Client insulation from services （客户端和服务隔离）  
- Security（安全）  
- surgical routing（路由）  
- Load Shedding （负载均衡）  
- Rate Limit（限流）  
- Cache（缓存）  
- Fuse（熔断）  
- Retry（重试）  
- Auth（认证、鉴权）  
- Log（日志收集）  
- Monitor（监控）  
- Tracing Analysis（链路追踪）
{% asset_img apigateway.jpeg %}   
{% asset_img backendforfrontend.png %}   

## Aspects to be considered
- Develepment（Programming Language）  
- Community activity
- Performance
- Stability
- Update 

## SOME GATEWAYS

- Nginx+Lua：Open Resty、Kong、Orange、Abtesting Gateway等；  
- Java：Zuul/Zuul 2、Spring Cloud Gateway、Kaazing KWG、gravitee、Dromara soul等；  、
- Go：Janus、fagongzi、Grpc-Gateway；  
- .NET：Ocelot；  
- Node.js：Express Gateway、MicroGateway。  

使用范围、成熟度、活跃度等，主流有：Kong、Zuul/Zuul 2、Spring Cloud Gateway、apisix

### Nginx 
Nginx 更偏向于作为流量网关（第一级网关）。成熟，性能好，稳定，使用广，也便于维护，运维配置方便。
但致命弱点是，不便于定制开发（有一部分是开发语言的原因），需要 +Lua 

### OpenResty（Nginx + Lua）
OpenResty nginx + Lua动态扩展。目前已经有基于Open Resty产生的gateway，例如 Kong，APISIX等。

### APISIX（Nginx + etcd）
- Develepment（Programming Language）: N
- Community activity: Y
- Performance: Y
- Stability: ？
- Update: Y

从评价来看，APISIX的性能更好，功能也更加丰富。
但APISIX诞生两年多，很年轻，或许需要更多的“检验”，开发语言的差别也会增加问题排查、处理的代价。


### Kong（Nginx + postgres）
- Develepment（Programming Language）: Y
- Community activity: Y
- Performance: N (compared with apisix)
- Stability: Y
- Update: Y

Kong和APISIX比较像，但是相比较而言，劣势也很明显。从性能、功能丰富度方面 都处于下风（毕竟APISIX更新）。而且开发语言的劣势同样具有。

### Zuul (Java)
Zuul-动态路由、监控、弹性和安全。基于Servlet，属于上一代产品，同步I/O、多线程。性能不好，针对于Zuul的替代方案已经有 Zuul2 以及 Spring Gateway 两类。因此Zuul不予考虑。

{% asset_img zuul-lifecycle.png %}
> PreDecorationFilter  
> SendForwardFilter  
> RibbonRoutingFilter  
> SimpleHostRoutingFilter  
> SendResponseFilter  
> SendErrorFilter  
#### PROBLEMS?  
> Large coupled filters 
> Filter model/API is clunky

### Zuul2 (Java)
- Develepment（Programming Language）: N
- Community activity: Y
- Performance: Y
- Stability: ？
- Update: Y

服务发现、负载均衡、连接池、状态分类、重试、请求凭证、HTTP/2、TLS、代理协议、GZip、WebSocket  
基于 Netty，Zuul 2.x最大的改进就是基于Netty Server实现了异步I/O来接入请求，同时基于Netty Client实现了到后端业务服务API的请求。这样就可以实现更高的性能、更低的延迟。此外也调整了Filter类型，将原来的三个核心Filter显式命名为Inbound Filter、Endpoint Filter和Outbound Filter，如图7-8所示。  

{% asset_img Zuul2.jpeg %}
> Major rewrite  
> Not backwards compatible with Zuul 1  
> Non-blocking/Netty  
> Not released yet   
> HTTP/2 and Websockets in the future  
> Reinvents many things from Spring  

### Spring Cloud Gateway (Java)
- Develepment（Programming Language）: Y
- Community activity: Y
- Performance: Y
- Stability: Y
- Update: Y

Java 8、Spring 5.0、Spring Boot 2.0、Reactor -> Spring family
#### Spring Cloud紧密配合? 

> Java 8/Spring 5/Boot 2
> WebFlux/Reactor
> HTTP/2 and Websockets
> Finchley Release Train

Spring Cloud Gateway里明确地区分了Router和Filter，内置了非常多的开箱即用功能，并且都可以通过Spring Boot配置或手工编码链式调用来使用。  
内置了10种Router，直接配置就可以随心所欲地根据Header、Path、Host或Query来做路由。  

##### 核心特性：  
- 通过请求参数匹配路由；  
- 通过断言和过滤器实现路由；
- 与Hystrix熔断集成；
- 与Spring Cloud DiscoveryClient集成；
- 非常方便地实现断言和过滤器；
- 请求限流；
- 路径重写。

## Compare

### **Zuul vs Zuul2 (Difference between sync and async): Zuul2 Win!**
- **Zuul(block) disadvantages**
- *Zuul 1* was built on the Servlet framework 
- Blocking and mltithreaded, means they process requests by using one thread per connection.
- I/O oprations are done by choosing a worker threade from athread pool to execute the I/O, and the request thread is blocked until the worker thread completes, and the worker thread notifies the request thread when its work is complete.
```
This works well with modern multi-core AWS instances handling 100’s of concurrent connections each. But when things go wrong, like backend latency increases or device retries due to errors, the count of active connections and threads increases. When this happens, nodes get into trouble and can go into a death spiral where backed up threads spike server loads and overwhelm the cluster. To offset these risks, we built in throttling mechanisms and libraries (e.g., Hystrix) to help keep our blocking systems stable during these events.
```
{% asset_img Multithreaded_System_Architecture.png %}

- **Zuul2(async) advantages**
- *Zuul2* async.  
- One thread per CPU core handling all requests and responses. The lifecycle of the request and response is handled through events and callbacks. 
```
Because there is not a thread for each request, the cost of connections is cheap. This is the cost of a file descriptor, and the addition of a listener. Whereas the cost of a connection in the blocking model is a thread and with heavy memory and system overhead. There are some efficiency gains because data stays on the same CPU, making better use of CPU level caches and requiring fewer context switches. The fallout of backend latency and “retry storms” (customers and devices retrying requests when problems occur) is also less stressful on the system because connections and increased events in the queue are far less expensive than piling up threads.
```
{% asset_img Asynchronous_and_Non-blocking_System_Architecture.png %}

- **Zuul2(async) disadvantages & Zuul(block) advantages**
```
The advantages of async systems sound glorious, but the above benefits come at a cost to operations. Blocking systems are easy to grok and debug. A thread is always doing a single operation so the thread’s stack is an accurate snapshot of the progress of a request or spawned task; and a thread dump can be read to follow a request spanning multiple threads by following locks. An exception thrown just pops up the stack. A “catch-all” exception handler can cleanup everything that isn’t explicitly caught.

Async, by contrast, is callback based and driven by an event loop. The event loop’s stack trace is meaningless when trying to follow a request. It is difficult to follow a request as events and callbacks are processed, and the tools to help with debugging this are sorely lacking in this area. Edge cases, unhandled exceptions, and incorrectly handled state changes create dangling resources resulting in ByteBuf leaks, file descriptor leaks, lost responses, etc. These types of issues have proven to be quite difficult to debug because it is difficult to know which event wasn’t handled properly or cleaned up appropriately.
```

### **Kong vs APISIX**
{% asset_img Kong_vs_APISIX.png %}

### **Spring Cloud Gateway vs Zuul2 vs OpenResty vs Kong**
|网关|限流|鉴权|监控|易用性|可维护性|成熟度|
|---|---|----|----|-----|-------|-----|
|Spring Cloud Gateway|IP、用户、集群限流，提供相应接口扩展|普通鉴权、OAuth2.0|Gateway Metrics Filter|简单|Spring全家桶成员、扩展性强、易配置、易维护|成熟|
|Zuul2|配置文件，配置集群、单服务器限流、Filter扩展|Filter实现|Filter实现|-|-|-|
|OpenResty|Lua|Lua|需要开发|简单易用，但需要Lua开发|可维护性差|成熟|
|Kong|根据时间、用户限流。可在源码基础上开发|普通鉴权、OAuth2.0、Key Auth、HMAC|上报datadog，记录请求数量、数据量、应答数据量、接收发送时间间隔、状态码数量、Kong内耗时|简单易用，API转发通过管理接口配置。需要Lua开发|维护需要Lua|成熟|


### Ref
> ref: [The author of spring cloud gateway's PPT](https://spencergibb.netlify.app/preso/detroit-cf-api-gateway-2017-03/#/)   
> ref: [What is api gateway](https://microservices.io/patterns/apigateway.html)   
> ref: [Netflix blog: Zuul2](https://netflixtechblog.com/zuul-2-the-netflix-journey-to-asynchronous-non-blocking-systems-45947377fb5c)  
> ref: [Netflix blog: Optimizing the Netflix API](https://netflixtechblog.com/optimizing-the-netflix-api-5c9ac715cf19)  
> ref: [Microservice Architecture](https://microservices.io/patterns/microservices.html) 
> ref: [百亿流量微服务网关的设计与实现](http://blog.itpub.net/31562044/viewspace-2651041/) 
