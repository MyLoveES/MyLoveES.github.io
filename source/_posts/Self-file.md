title: Self - file
date: 2023-03-18
tags: [project]
categories: self-build-roject
toc: true
---

# 字段

|字段|类型|说明|
|----|----|----|
|id|long, primary key|自增主键|
|file_id|varchar, business key|业务主键，文件Id|
|file_group_id|varchar|文件组|
|fs_key|varchar|文件存储key|
|file_name|varchar|文件名|
|file_type|varchar|文件类型|
|file_md5|varchar|文件md5|
|file_origin_path|varchar|原始文件路径|
|download_retry_times|integer|重试次数|
|status|integer|状态；0失效，1有效，2排队中，3上传中，4下载中，-3上传失败，-4下载失败|
|owner|varchar|拥有者Id|
|callback_required|integer|是否需要回调|
|callback_url|varchar|回调URL|
|callback_retry_time|integer|回调重试次数|
|callback_status|integer|回调状态；0等待回调，1回调成功，-1回调失败|
|callback_result|varchar|回调结果|
|create_time|datetime|创建时间|
|update_time|datetime|更新时间|

# 注意的点

1. 封装SDK    
2. 客户端登记文件，直传存储引擎，再次确认状态

# 流程图

1. 客户端上传   

{% asset_img self-file-1.png %}

2. 客户端提交

{% asset_img self-file-2.png %}
