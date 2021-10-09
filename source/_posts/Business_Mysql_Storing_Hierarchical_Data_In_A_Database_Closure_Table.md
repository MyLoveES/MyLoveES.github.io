title: 【Mysql】Storing Hierarchical data by 【Closure Table】
date: 2021-08-23 18:50:00
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

## Closure Table

维护一个表，所有的tree path作为记录进行保存。

|id    |name  |parent_id|
|------|------|---------|
|1     |DIR_A |root     |
|2     |DIR_B |1        |
|3     |DIR_C |1        |
|4     |file_x|1        |
|5     |file_y|1        |
|6     |file_z|1        |
|7     |DIR_D |2        |
|8     |file_o|2        |
|9     |file_p|2        |
|10    |DIR_E |2        |
|11    |file_j|2        |
|12    |file_k|2        |
|13    |file_l|7        |
|14    |file_m|10       |
|15    |file_n|10       |

## 各种情况的处理办法

### 增

### 删

### 改

### 查

### 组织层级关系