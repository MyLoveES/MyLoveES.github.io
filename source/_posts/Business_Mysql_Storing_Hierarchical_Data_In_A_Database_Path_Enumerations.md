title: Storing Hierarchical data by 【Path Enumerations】
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

|id    |name  |path                      |
|------|------|--------------------------|
|1     |DIR_A |/DIR_A                    |
|2     |DIR_B |/DIR_A/DIR_B              |
|3     |DIR_C |/DIR_A/DIR_C              |
|4     |file_x|/DIR_A/file_x             |
|5     |file_y|/DIR_A/file_y             |
|6     |file_z|/DIR_A/file_z             |
|7     |DIR_D |/DIR_A/DIR_B/DIR_D        |
|8     |file_o|/DIR_A/DIR_B/file_o       |
|9     |file_p|/DIR_A/DIR_B/file_p       |
|10    |DIR_E |/DIR_A/DIR_C/DIR_E        |
|11    |file_m|/DIR_A/DIR_C/file_m       |
|12    |file_n|/DIR_A/DIR_C/file_n       |
|13    |file_l|/DIR_A/DIR_B/DIR_D/file_l |
|14    |file_j|/DIR_A/DIR_C/DIR_E/file_j |
|15    |file_k|/DIR_A/DIR_C/DIR_E/file_k |

## 各种情况的处理代价

### 增
> 输入：name, path  
> 执行：
```sql
insert into table(name, path) values($name, $path);
```
|id     |name    |path|
|-------|--------|---------|
|13     |file_l  |/DIR_A/DIR_B/DIR_D/file_l  |
|14     |file_j  |/DIR_A/DIR_C/DIR_E/file_j  |
|15     |file_k  |/DIR_A/DIR_C/DIR_E/file_k  |
|16(add)|file_ADD|/DIR_A/DIR_C/DIR_E/file_ADD|

### 删
> 输入：path  
> 执行：  
```sql
delete from table where path like CONCAT($path, '%') ;
```

### 改
#### 无子集
> 输入：path, other info
> 执行：  
```sql
update table set info where path = $path
```
#### 有子集
> 输入：path, other info
> 执行：  
```sql
pre: 
需要分割、拼接拿到old_path和new_path
mysql 5.7:
update table set info where path = $old_path
update table set path = REPLACE(
    CONCAT('^', $old_path), 
    CONCAT('^', $new_path), 
    $new_path) 
where path like CONCAT($old_path, '%')
```

### 查
#### 查自己
> 输入：path  
> 执行：
```sql
select * from table where path = $path
```
#### 查下一级
> 输入：id  
> 执行：
```sql
select * from table where path regexp CONCAT('^', $path, '/.+', '((?!/).)')
```
#### 查所有子集
> 输入：path  
> 执行：
```sql
select * from table where path like CONCAT($path, '/%')
```
### 移动
> 输入：path, new_path  
> 执行：
```sql
pre: 
old_path和new_path
mysql 5.7: (同有子集改)
update table set path = REPLACE(
    CONCAT('^', $old_path), 
    CONCAT('^', $new_path), 
    $new_path) 
where path like CONCAT($old_path, '%')
```

### 组织层级关系
> 代价：-> ∞
```java
object:
{
    path, 
    sub_objects
}
data: 
List<object> list;

do:

list
.groupToMap(key -> {
    int index = path.lastIndexOf('/');
    index = index == -1 ? path.length() : index;
    return path.substring(0, index);
}, value -> o)
.foreach(map -> {
    list.get(map.key).setSubObjects(map.value);
});
```

## 总结
**优点** : 查询、修改方便
**缺点** : 需要大量用到模糊匹配；需要控制层级深度

