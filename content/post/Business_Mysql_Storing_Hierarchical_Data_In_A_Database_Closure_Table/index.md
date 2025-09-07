---
title: Storing Hierarchical data by 【Closure Table】
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

{% asset_img CASE_CUSTOM.png CASE_CUSTOM %}

{% asset_img CASE_TREE.png CASE_TREE %}

## Closure Table

维护一个表，所有的tree path作为记录进行保存。

|id         |name      |
|-----------|----------|
|1          |DIR_A     |
|2          |DIR_B     |
|3          |DIR_C     |
|4          |file_x    |
|5          |file_y    |
|6          |file_z    |
|7          |DIR_E     |
|8          |file_o    |
|9          |file_p    |
|10         |DIR_D     |
|11         |file_m    |
|12         |file_n    |
|13         |file_l    |
|14         |file_j    |
|15         |file_k    |

|current_id|ancestor_id|distance|
|----------|----------|--------|
|2         |1         |1       |
|7         |1         |2       |
|7         |2         |1       |
|13        |1         |3       |
|13        |2         |2       |
|13        |7         |1       |
|...       |...       |...     |

## 各种情况的处理代价

### 增
{% asset_img ADD.jpg ADD %}

> 代价：-> O(n)  如果层级非常深，代价 -> ∞  
> 输入：name, parent_id  
> 执行：添加到 DIR_D 下  
```sql
insert into node(name) values($name);
# 查所有父节点，建立关系
ids[] = {$parent_id}
ids[] += select id from node where current_id=$parent_id; 
distance = ids.length;
for (ancestor_id : ids) {
    insert into relation(current_id, ancestor_id, distance) values ($id, $ancestor_id, $distance);
    distance--;
}
```
|id     |name    |
|-------|--------|
|13     |file_l  |
|14     |file_j  |
|15     |file_k  |
|16(add)|file_ADD|

|current_id|ancestor_id|distance|
|-----------|----------|--------|
|16         |1         |4       |
|16         |3         |3       |
|16         |10        |2       |
|16         |13        |1       |

### 删
{% asset_img DEL.jpg DEL %}
> 代价：-> O(n)  
> 输入：id  
> 执行：  
```sql
ids[] = {$id}
ids += $(select id from relation where ancestor_id = ${id})
delete from relation where ancestor_id in ${ids} or current_id in ${ids}
delete from node where id in ${ids}
```

### 改
> 代价：-> O(1)  
> 输入：id, other info  
> 执行：  
```sql
update node set info where id = $id
```

### 查
#### 查自己
> 代价：-> O(1)  
> 输入：id  
> 执行：
```sql
select * from node where id = $id
```
#### 查下一级
{% asset_img SEARCH_NEXT.jpg SEARCH_NEXT %}
> 代价：-> O(n)  
> 输入：id  
> 执行：
```sql
select * from relation
left join node on node.id = relation.current_id
where relation.ancestor_id = $id and distance = 1
```
#### 查所有子集
{% asset_img SEARCH_ALL.jpg SEARCH_ALL %}
> 代价：-> O(n)  
> 输入：id  
> 执行：
```sql
select * from relation
left join node on node.id = relation.current_id
where relation.ancestor_id = $id
```
### 移动
{% asset_img MOVE.jpg MOVE %}
> 代价：-> O(n)
> 输入：id, new_parent_id
> 执行：
```sql
old_parent_id = select ancestor_id from relation where current_id = $id and distance = 1;
DEL # 执行上面的删除操作

objects = ${object(id)}
objects += $(select current_id, distance from relation where ancestor = $id)
for (object : $objects) {
    INSERT  # 执行上面的插入操作
}
```

<!-- ### 组织层级关系
> 代价：-> ∞  
```java
ids[] = {$id}
result[] = {}
for(cur_id : ids) {
    result add 
    $(select * from relation
    left join node on node.id = relation.current_id
    where relation.ancestor_id in $cur_id);

    ids add $(select current_id from relation where ancestor_id = $cur_id)
}
``` -->

## 总结
**优点** : 修改、查询简便，效率高；   
**缺点** : 空间换时间；进行删除、移动代价较大；层级深度很大的时候空间消耗巨大   
**适用** : 有固定的层级深度，并且层级不多的场景   