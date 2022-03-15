title:网关选型细节
date: 2022-03-14
tags: [Business, Gateway]
categories: Business
toc: true
---

上一篇中选出来几个候选人：Spring Cloud Gateway, Zuul2, APISIX. 下面从几个比较关注的方面，比较几个网关的优劣

## 关注点
1. 开发语言
2. 架构
3. 性能
4. 与 Spring Cloud 的搭配
5. 服务发现
6. 数据存储
7. 是否支持协议转换（http -> rpc 等）
8. 配置方案
9. 限流
10. 路由
11. 负载均衡
12. 缓存
13. 熔断
14. 重试
15. 认证鉴权
16. 日志收集
17. 监控
18. 链路追踪

## 比较

### APISIX

架构：
{% asset_img flow-software-architecture.png %}
插件流程：
{% asset_img apisix-flow-load-plugin.png %}
插件内部结构:
{% asset_img apisix-flow-plugin-internal.png%}

1. 开发语言: Nginx+Lua
3. 性能: best
4. 与 Spring Cloud 的整合: 无
5. 服务发现: 
6. 数据存储
7. 是否支持协议转换（http -> rpc 等）
8. 配置方案
9. 限流
10. 路由
11. 负载均衡
12. 缓存
13. 熔断
14. 重试
15. 认证鉴权
16. 日志收集
17. 监控
18. 链路追踪
1. 

### Spring Cloud Gateway
1. 开发语言
2. 架构
3. 性能
4. 与 Spring Cloud 的搭配
5. 服务发现
6. 数据存储
7. 是否支持协议转换（http -> rpc 等）
8. 配置方案
9. 限流
10. 路由
11. 负载均衡
12. 缓存
13. 熔断
14. 重试
15. 认证鉴权
16. 日志收集
17. 监控
18. 链路追踪

### Zuul2
1. 开发语言
2. 架构
3. 性能
4. 与 Spring Cloud 的搭配
5. 服务发现
6. 数据存储
7. 是否支持协议转换（http -> rpc 等）
8. 配置方案
9. 限流
10. 路由
11. 负载均衡
12. 缓存
13. 熔断
14. 重试
15. 认证鉴权
16. 日志收集
17. 监控
18. 链路追踪

## 总结