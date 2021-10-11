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
|1         |1         |0       |
|2         |1         |1       |
|2         |2         |0       |
|7         |1         |2       |
|7         |2         |1       |
|7         |7         |0       |
|13        |1         |3       |
|13        |2         |2       |
|13        |7         |1       |
|13        |13        |0       |
|...       |...       |...     |

## 各种情况的处理代价

### 增
> 代价：-> O(n)  如果层级非常深，代价 -> ∞  
> 输入：name, parent_id  
> 执行：添加到 DIR_D 下  
```sql
insert into node(name) values($name);
ids[] = select id from node where current_id=$parent_id; 
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
|16         |1         |3       |
|16         |3         |2       |
|16         |10        |1       |
|16         |13        |0       |

### 删
#### 删干净
> 代价：-> ∞  
> 输入：id  
> 执行：  
```sql
ids[] = {$id}
while (ids is not empty) {
    delete from node where id in $ids;
    delete from relation where current_id in $ids or ancestor_id in $ids;
    select id from relation where ancestor_id in $ids;
}
```

#### 不删干净（网上很多这么干的，不清楚这么搞真的ok吗）
> 代价：-> O(n)  
> 输入：id  
> 执行：  
```sql
delete from node where id = $id;
delete from relation where current_id = $id  or ancestor_id = $ids;
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
> 代价：-> O(n)  
> 输入：id  
> 执行：
```sql
select * from relation
left join node on node.id = relation.current_id
where relation.ancestor_id = $id and distance = 1
```
#### 查所有子集
> 代价：-> O(n)  
> 输入：id  
> 执行：
```sql
select * from relation
left join node on node.id = relation.current_id
where relation.ancestor_id = $id
```
### 移动
> 代价：-> O(n)  
> 输入：id, new_parent_id
> 执行：
```sql
old_parent_id = select ancestor_id from relation where current_id = $id and distance = 1;
delete from relation where current_id = $id and distance = 1;
objects[] = $(select current_id, distance from relation where ancestor = $id)
for (object : $objects) {
    delete from relation where current_id = $object.current_id and ancestor_id = $old_parent_id;
    insert into relation(current_id, ancestor_id, distance) values($object.current_id, $new_parent_id, $distance + 1);
}
```

### 组织层级关系
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
```

## 总结
**优点** : 直接查询上下级非常方便；修改方便  
**缺点** : 空间换时间；进行删除、移动时代价较大；层级深度很大的时候空间消耗巨大