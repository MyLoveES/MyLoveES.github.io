title: Storing Hierarchical data by 【Mysql8】
date: 2021-08-23 18:51:00
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

## 实例

{% asset_img CASE.png CASE %}

## 转成树型

{% asset_img CASE_TREE.png CASE_TREE %}

## Mysql8  
