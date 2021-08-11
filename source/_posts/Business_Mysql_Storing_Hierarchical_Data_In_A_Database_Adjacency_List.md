title: 【Mysql】Storing Hierarchical data by 【Adjacency List】
date: 2021-08-07 23:38:00
tags: [Data structure, Mysql]
categories: [Data structure, Mysql]
toc: true
---
# 如何在数据库中存储层次结构

## 常见场景

1. 公司：公司 - 部门 - 子部门 
2. 人员：领导 - 员工 
3. 文件：根目录 - 文件夹 - 文件
4. 关系：group - child

## Adjacency List 邻接表

存储当前节点的父节点信息（parent_id）

## 各种情况的处理办法

### 1. 查询某目录的所有子文件&子目录

### 2. 查询某目录的下一级子文件&子目录