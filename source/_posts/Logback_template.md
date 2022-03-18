title: logback 模版
date: 2022-03-18
tags: [Business]
categories: Business
toc: false
---
```
<configuration scan="true" scanPeriod="60 seconds" debug="false">
    <contextName>custom_service</contextName>

    <springProperty scope="context" name="log.name" source="spring.application.name"/>
    <springProperty scope="context" name="log.path" source="logging.path" />

    <property key="FILE_LOG_PATTERN" value="${FILE_LOG_PATTERN:-%d{yyyy-MM-dd HH:mm:ss.SSS} ${LOG_LEVEL_PATTERN:-%5p} ${PID:- } --- [%t][%X{MainAccountId}][%X{ClientIp}] %-40.40logger{39} : %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%wEx}}" />
    <property key="CONSOLE_LOG_PATTERN" value="${CONSOLE_LOG_PATTERN:-%clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} %clr(${LOG_LEVEL_PATTERN:-%5p}) %clr(${PID:- }){magenta} %clr(---){faint} %clr([%15.15t]){faint} %clr([%15.15X{MainAccountId}]){faint}%clr([%15.15X{ClientIp}]){faint} %clr(%-40.40logger{39}){cyan} %clr(:){faint} %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%wEx}}" />
    <property name="LOG_ENCODING" value="UTF-8" />
    <conversionRule conversionWord="clr" converterClass="org.springframework.boot.logging.logback.ColorConverter" />
    <conversionRule conversionWord="wex" converterClass="org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter" />
    <conversionRule conversionWord="wEx" converterClass="org.springframework.boot.logging.logback.ExtendedWhitespaceThrowableProxyConverter" />

    <appender name="console" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>${CONSOLE_LOG_PATTERN}</pattern>
            <charset>${LOG_ENCODING}</charset>
        </encoder>
    </appender>

    <appender name="file" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
            <fileNamePattern>${log.path}/${log.name}.%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <maxFileSize>10MB</maxFileSize>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>${FILE_LOG_PATTERN}</pattern>
            <charset>${LOG_ENCODING}</charset>
            <outputPatternAsHeader>true</outputPatternAsHeader>
        </encoder>
    </appender>

    <appender name="async" class="ch.qos.logback.classic.AsyncAppender">
        <discardingThreshold>0</discardingThreshold>
        <queueSize>512</queueSize>
        <appender-ref ref="file" />
    </appender>


    <springProfile name="local">
        <logger name="org.springframework.web.filter.CommonsRequestLoggingFilter" level="DEBUG" additivity="false">
            <appender-ref ref="console" />
            <appender-ref ref="async" />
        </logger>
        <root level="INFO">
            <appender-ref ref="console" />
        </root>
    </springProfile>

    <springProfile name="dev,test">
        <logger name="org.springframework.web.filter.CommonsRequestLoggingFilter" level="DEBUG" additivity="false">
            <appender-ref ref="console" />
            <appender-ref ref="async" />
        </logger>
        <root level="INFO">
            <appender-ref ref="console" />
            <appender-ref ref="async" />
        </root>
    </springProfile>

    <springProfile name="release">
        <root level="ERROR">
            <appender-ref ref="async" />
        </root>
    </springProfile>

</configuration>
```