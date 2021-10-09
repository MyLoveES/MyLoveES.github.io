title: 【Mysql】Storing Hierarchical data by 【Path Enumerations】
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

## Path Enumerations 

每条记录存整个tree path经过的node枚举

|id    |name  |path      |
|------|------|----------|
|1     |DIR_A |/1        |
|2     |DIR_B |/1/2      |
|3     |DIR_C |/1/3      |
|4     |file_x|/1/4      |
|5     |file_y|/1/5      |
|6     |file_z|/1/6      |
|7     |DIR_D |/1/2/7    |
|8     |file_o|/1/2/8    |
|9     |file_p|/1/2/9    |
|10    |DIR_E |/1/3/10   |
|11    |file_j|/1/3/11   |
|12    |file_k|/1/3/12   |
|13    |file_l|/1/2/7/13 |
|14    |file_m|/1/3/10/14|
|15    |file_n|/1/3/10/15|

## 各种情况的处理带价

### 增

### 删

### 改

### 查

### 组织层级关系