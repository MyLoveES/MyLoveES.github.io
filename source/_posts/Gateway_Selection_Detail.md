title: 网关选型细节
date: 2022-03-10
tags: [Business, Gateway]
categories: Business
toc: true
---

## 1.  海选
### Nginx，Openresty、Apisix、Kong、Zuul、Zuul2、Spring Cloud Gateway

- Nginx（淘汰）：功能不够丰富，且开发不便（需求自定义组件开发时, 需要+Lua）。应作为流量网关，而非API网关。
- OpenResty（淘汰）：Nginx + Lua。是一种从Nginx扩展各种功能、插件的思路，Kong、Apisix皆基于此，我们没必要从它开始手动实现。
- Kong（淘汰）：OpenResty + Lua，同样存在开发不便的问题。存储采用postgresql。对比来看，apisix其实是更优选（国产友好，性能更好，功能也更丰富）。
- Zuul（淘汰）：上一代产品，基于BIO，性能不好。已有替代产物 - Zuul2、Spring Cloud Gateway。

## 2. 决赛圈：Spring Cloud Gateway、Zuul2、APISIX
我们的需求：
1. 与当前技术栈的适配（Spring Cloud、Nacos 等）
2. 协议转换（http → rpc 等）
3. 路由
4. 限流
5. 负载均衡
6. 熔断
7. 监控
8. auth
9. 安全
10. 服务发现
11. 插件开发
12. 动态路由
13. 性能：Apisix > Zuul2 ≈ Spring Cloud Gateway

## 3. 结论 

首先从成熟度来看，Zuul2的资料较少，很多还是停留在Zuul1阶段。在Zuul2和Spring Cloud Gateway同属Java开发的情况下，更倾向于Spring。因此之后的比较主要发生在Spring Cloud Gateway和APISIX之间。  
比较来看，apisix优势是性能更好，功能更丰富。劣势是开发语言不匹配，之后开发维护学习成本比较高。而且对于nacos目前也只是实验性，并不完全成熟稳定。除此之外，需要etcd支持。  
Spring Cloud Gateway虽性能稍劣，但技术栈匹配，后期开发难度较小。并且与当前使用的基础设施更契合，能够省却维护新的基础设施组件的成本。因此最终选择Spring Cloud Gateway作为API网关。  

### Spring Cloud Gateway(Java)
https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/
```
1. Spring 全家桶成员：✓
2. http > rpc: x
3. 路由
    提供 Route Predicate: 包含 Time、Cookie、Header、Host、Method、Path、Query、RemoteAddr、XForwarded Remote Addr
    https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#gateway-request-predicates-factories
   
    Filters：request、response、oauth2、cache request
    https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#gatewayfilter-factories
4. 限流 
    redis - 令牌桶 https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#the-requestratelimiter-gatewayfilter-factory    
5. 负载均衡
    weight route: https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#the-weight-route-predicate-factory
6. 熔断(By status code / )
    circuit breaker: https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#spring-cloud-circuitbreaker-filter-factory
    可以将错误信息回调
7. 监控 Prometheus
    https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/#the-gateway-metrics-filter
8. auth / security / 插件开发 等通过各类Filter可以实现
11. 服务发现：nacos / eureka
13. 动态路由：可通过监听nacos & 代码更新
```

### Zuul2(Java)
https://github.com/Netflix/zuul/wiki/Getting-Started-2.0  
{% asset_img Zuul2_DES.png %}
sample: https://github.com/dashprateek/zuul2-sample  
        https://github.com/csh0711/zuul-2-sample  

```
1.SpringCloud 不兼容Zuul2
2.http 转 rpc: x
3.路由: ✓
4.限流: ✓
   https://github.com/Netflix/zuul/wiki/Core-Features#origin-concurrency-protection
   整体限流：max-requests 
   Per server：MaxConnectionsPerHost
   If an origin exceeds overall concurrency or per-host concurrency, Zuul will return a 503 to the client.
5.负载均衡: ✓
    roundrobin(轮询) https://github.com/Netflix/ribbon/wiki/Working-with-load-balancers#roundrobinrule
    AvailabilityFilteringRule(可用性过滤) https://github.com/Netflix/ribbon/wiki/Working-with-load-balancers#availabilityfilteringrule
    WeightedResponseTimeRule(根据响应时间加权重) https://github.com/Netflix/ribbon/wiki/Working-with-load-balancers#weightedresponsetimerule
6. 熔断（自定义）: ✓
     https://www.javadoc.io/doc/org.springframework.cloud/spring-cloud-netflix-zuul/2.0.3.RELEASE/org/springframework/cloud/netflix/zuul/filters/route/FallbackProvider.html
     https://www.baeldung.com/spring-zuul-fallback-route
7.监控:
      prometheus、Statsd https://zuul-ci.org/docs/zuul/latest/monitoring.html
8.auth、安全: ✓
11. 服务发现: ✓
      静态配置 / eureka
12.插件开发: Java
13.数据存储: JPA / redis
```

### APISIX(OpenResty + Lua)
https://apisix.apache.org/docs/apisix/getting-started  
{% asset_img APISIX_DES.png %}
```
1.Nginx + Lua: x
2.支持rpc: ✓
   grpc: https://apisix.apache.org/zh/docs/apisix/plugins/grpc-transcode
   dubbo: https://apisix.apache.org/zh/docs/apisix/plugins/dubbo-proxy
3.路由: ✓
4.限流: ✓
   limit-req: 限制请求速度的插件，使用的是漏桶算法。https://apisix.apache.org/zh/docs/apisix/plugins/limit-req
   limit-conn: 限制并发请求（或并发连接）插件。https://apisix.apache.org/zh/docs/apisix/plugins/limit-conn
   limit-count: 在指定的时间范围内，限制总的请求个数。并且在 HTTP 响应头中返回剩余可以请求的个数。https://apisix.apache.org/zh/docs/apisix/plugins/limit-count
5.负载均衡: ✓
    策略：chash(一致性hash)，roundrobin(轮询)，priority，least_conn(最少连接数)，ewma(指数加权移动平均法)
    https://github.com/apache/apisix/tree/master/apisix/balancer
6.熔断（backoff）:✓  https://apisix.apache.org/zh/docs/apisix/plugins/api-breaker/
7.监控: ✓
    prometheus: https://apisix.apache.org/zh/docs/apisix/plugins/prometheus/
    zipkin: https://apisix.apache.org/zh/docs/apisix/plugins/zipkin
    skywalking: https://apisix.apache.org/zh/docs/apisix/plugins/skywalking
    node-status: https://apisix.apache.org/zh/docs/apisix/plugins/node-status
    datadog: https://apisix.apache.org/zh/docs/apisix/plugins/datadog
8.auth: ✓
    key-auth(k-v): https://apisix.apache.org/zh/docs/apisix/plugins/key-auth
    jwt-auth: https://apisix.apache.org/zh/docs/apisix/plugins/jwt-auth
    basic-auth: https://apisix.apache.org/zh/docs/apisix/plugins/basic-auth
    authz-keycloak: https://apisix.apache.org/zh/docs/apisix/plugins/authz-keycloak
    wolf-rbac:  https://apisix.apache.org/zh/docs/apisix/plugins/wolf-rbac
    openid-connect: https://apisix.apache.org/zh/docs/apisix/plugins/openid-connect
    hmac-auth: https://apisix.apache.org/zh/docs/apisix/plugins/hmac-auth
    authz-casbin: https://apisix.apache.org/zh/docs/apisix/plugins/authz-casbin
    ldap-auth: https://apisix.apache.org/zh/docs/apisix/plugins/ldap-auth
    opa: https://apisix.apache.org/zh/docs/apisix/plugins/opa
    forward-auth: https://apisix.apache.org/zh/docs/apisix/plugins/forward-auth
9.安全: ✓
    cors: https://apisix.apache.org/zh/docs/apisix/plugins/cors
    uri-blocker: 指定block_rules，拦截请求 https://apisix.apache.org/zh/docs/apisix/plugins/uri-blocker
    ip-restriction: ip 黑白名单 https://apisix.apache.org/zh/docs/apisix/plugins/ip-restriction
    ua-restriction: User-Agent 黑白名单 https://apisix.apache.org/zh/docs/apisix/plugins/ua-restriction
    referer-restriction: referer 黑白名单 https://apisix.apache.org/zh/docs/apisix/plugins/referer-restriction
    consumer-restriction: 自定义 https://apisix.apache.org/zh/docs/apisix/plugins/consumer-restriction
10.log: ✓
    http / skywalking / tcp / kafka / rocketmq / udp / Syslog / log-rotate / error-log-logger / sls-logger / google-cloud / splunk-hec
11.服务发现: ✓
    DNS
    consul_kv
    nacos(实验性)
    eureka
12.插件开发: ✓
    lua: https://apisix.apache.org/zh/docs/apisix/plugin-develop
    external plugin:  
        java: https://apisix.apache.org/zh/docs/apisix/external-plugin
        go:  https://apisix.apache.org/docs/go-plugin-runner/getting-started/
        python: https://apisix.apache.org/docs/python-plugin-runner/getting-started/
13.数据存储/动态路由：etcd


```

## 番外
### 对dubbo集成
#### APISIX
https://apisix.apache.org/zh/docs/apisix/plugins/dubbo-proxy/  
https://apisix.apache.org/zh/blog/2022/01/13/how-to-proxy-dubbo-in-apache-apisix/
{% asset_img dubbo-02.png %}
> dubbo-proxy 插件允许将 HTTP 请求代理到 dubbo，但是有所限制：参数和返回值都必须要是 Map<String, Object>
```
curl http://127.0.0.1:9080/apisix/admin/upstreams/1  -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "nodes": {
        "127.0.0.1:20880": 1
    },
    "type": "roundrobin"
}'
 
curl http://127.0.0.1:9080/apisix/admin/routes/1  -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
    "uris": [
        "/hello"
    ],
    "plugins": {
        "dubbo-proxy": {
            "service_name": "org.apache.dubbo.sample.tengine.DemoService",
            "service_version": "0.0.0",
            "method": "tengineDubbo"
        }
    },
    "upstream_id": 1
}'
```
如果要满足复杂场景，需要在服务中额外增加一个HTTP TO DUBBO的service进行处理。通过 HTTP Request Body 描述要调用的 Service 和 Method 以及对应参数，再利用 Java 的反射机制实现目标方法的调用。最后将返回值序列化为 JSON，并写入到 HTTP Response Body 中.
```

public class DubboInvocationParameter {
    private String type;
    private String value;
}
 
public class DubboInvocation {
    private String service;
    private String method;
    private DubboInvocationParameter[] parameters;
}
 
public interface HTTP2DubboService {
    Map<String, Object> invoke(Map<String, Object> context)  throws Exception;
}
 
 
@Component
public class HTTP2DubboServiceImpl implements HTTP2DubboService {
 
    @Autowired
    private ApplicationContext appContext;
 
    @Override
    public Map<String, Object> invoke(Map<String, Object> context) throws Exception {
        DubboInvocation invocation = JSONObject.parseObject((byte[]) context.get("body"), DubboInvocation.class);
        Object[] args = new Object[invocation.getParameters().size()];
        for (int i = 0; i < args.length; i++) {
            DubboInvocationParameter parameter = invocation.getParameters().get(i);
            args[i] = JSONObject.parseObject(parameter.getValue(), Class.forName(parameter.getType()));
        }
 
        Object svc = appContext.getBean(Class.forName(invocation.getService()));
        Object result = svc.getClass().getMethod(invocation.getMethod()).invoke(args);
        Map<String, Object> httpResponse = new HashMap<>();
        httpResponse.put("status", 200);
        httpResponse.put("body", JSONObject.toJSONString(result));
        return httpResponse;
    }
 
}
```
#### Spring Cloud Gateway
https://www.cnblogs.com/zlt2000/p/13201326.html  
{% asset_img dubbo-3.png %}
> 由于SpringCloudGateway不支持Http到RPC协议的转换，因此需要引入"web"层来作http→rpc。有两种实现方式
- 1. 通过web层来转换http → rpc
- 2. 通过dubbo rest承接http

