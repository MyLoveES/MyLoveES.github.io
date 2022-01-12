title: MQ - Consume messages with Priority
date: 2021-11-20 18:38:00
tags: [MQ]
categories: [MQ]
toc: true
---
# 根据优先级消费MQ消息

## 背景

> MQ作为处理任务的消息中间件。由于任务来自于不同的场景，带有不同的优先级属性，因此消费者需要根据呀优先级对任务进行处理。

## 方案

### 带有优先级的MQ：以 RabbitMQ 为例
#### 1. 为什么 Kafka/Pulsar 不带有优先级概念

#### 2. 两者的差别

### Topic 优先级顺序消费
#### 1. 通过单一任务队列限流（当前实现方案）
#### 2. 为每个Topic分配队列，容量整体调控