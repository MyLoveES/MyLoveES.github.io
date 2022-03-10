title: 网关选型
date: 2022-03-10
tags: [Business, Gateway]
categories: Business
toc: true
---

## What & Why
- Single entry point for all clients
- Common in microservice architectures
- Client insulation from services
- Security, surgical routing, Load Shedding, etc...
{% asset_img apigateway.jpeg %}
{% asset_img backendforfrontend.png %}

## SOME GATEWAYS
### Nginx 
### Kong
### APISIX
### Zuul (Java)
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
> Major rewrite  
> Not backwards compatible with Zuul 1  
> Non-blocking/Netty  
> Not released yet   
> HTTP/2 and Websockets in the future  
> Reinvents many things from Spring  
### Spring Cloud Gateway (Java)
> Java 8/Spring 5/Boot 2
> WebFlux/Reactor
> HTTP/2 and Websockets
> Finchley Release Train

### Soul (Java)
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




## Selection

> ref: [The author of spring cloud gateway's PPT](https://spencergibb.netlify.app/preso/detroit-cf-api-asset_imggateway-2017-03/#/3)   
> ref: [What is api gateway](https://microservices.io/patterns/apigateway.html)   
> ref: [Netflix blog: Zuul2](https://netflixtechblog.com/zuul-2-the-netflix-journey-to-asynchronous-non-blocking-systems-45947377fb5c)  
> ref: [Netflix blog: Optimizing the Netflix API](https://netflixtechblog.com/optimizing-the-netflix-api-5c9ac715cf19)  
> ref: [Microservice Architecture](https://microservices.io/patterns/microservices.html)  