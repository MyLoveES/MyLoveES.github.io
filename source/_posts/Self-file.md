title: Self - file
date: 2023-03-18
tags: [project]
categories: self-build-roject
toc: true
---

# 表

## file
|字段|类型|说明|
|----|----|----|
|id|long, primary key|自增主键|
|file_id|varchar, business key|业务主键，文件Id|
|fs_key|varchar|文件存储key|
|file_md5|varchar|文件md5|
|create_time|datetime|创建时间|
|update_time|datetime|更新时间|

## file_owner
|字段|类型|说明|
|----|----|----|
|id|long, primary key|自增主键|
|file_id|varchar, business key|业务主键，文件Id|
|file_name|varchar|文件名|
|file_type|varchar|文件类型|
|status|integer|状态；0失效，1有效，2排队中，3上传中，4下载中，-3上传失败，-4下载失败|
|owner_id|varchar|拥有者Id|
|create_time|datetime|创建时间|
|update_time|datetime|更新时间|

## file_download
|字段|类型|说明|
|----|----|----|
|id|long, primary key|自增主键|
|file_download_id|varchar, business key|业务主键，文件下载Id|
|file_id|varchar, business key|业务主键，文件Id|
|file_origin_path|varchar|原始文件路径|
|download_retry_times|integer|重试次数|
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

# 新建项目

## 1. init
```
    spring init --groupId=com.weasley --artifactId=file-center --name=file-center --description="file-center" file-center
```

## 2. module
根目录 setting.gradle
```
    include 'file-center-common'
    include 'file-center-domain'
    include 'file-center-application'
    include 'file-center-interface'
```

根目录 build.gradle
```
buildscript {
	repositories {
		mavenCentral()
	}

	dependencies {
		classpath('org.springframework.boot:spring-boot-gradle-plugin:3.0.4')
	}
}

plugins {
	id 'java'
	id 'groovy'
	id 'java-library'
	id 'org.springframework.boot' version '3.0.4'
	id 'io.spring.dependency-management' version '1.1.0'
}

allprojects{
	group = 'com.weasley'
	version = '0.0.1-SNAPSHOT'
	sourceCompatibility = '17'

	repositories {
		mavenCentral()
	}
}

subprojects {

	apply plugin: 'java'
	apply plugin: 'java-library'
	apply plugin: 'groovy'

	dependencies {
		implementation 'org.springframework.boot:spring-boot-starter'
		testImplementation 'org.springframework.boot:spring-boot-starter-test:3.0.4'

		// devtools
		compileOnly 'org.springframework.boot:spring-boot-devtools:3.0.4'

		// lombok
		compileOnly 'org.projectlombok:lombok:1.18.26'
		annotationProcessor 'org.projectlombok:lombok:1.18.26'

		// spring-boot-configuration-processor
		annotationProcessor "org.springframework.boot:spring-boot-configuration-processor:3.0.4"

		// mapstruct
		implementation 'org.mapstruct:mapstruct:1.5.3.Final'
		annotationProcessor 'org.mapstruct:mapstruct-processor:1.5.3.Final'

		// knife4j
		implementation group: 'com.github.xiaoymin', name: 'knife4j-openapi3-jakarta-spring-boot-starter', version: '4.0.0'

		// mybatis plus
		implementation group: 'com.baomidou', name: 'mybatis-plus-boot-starter', version: '3.5.2'
		implementation group: 'com.baomidou', name: 'mybatis-plus-generator', version: '3.5.2'

		// spock
		testImplementation group: 'org.spockframework', name: 'spock-core', version: '2.3-groovy-4.0'
		testImplementation group: 'org.spockframework', name: 'spock-spring', version: '2.3-groovy-4.0'

		// h2
		testImplementation group: 'com.h2database', name: 'h2', version: '2.1.214'

		// embedded-redis
		testImplementation (group: 'it.ozimov', name: 'embedded-redis', version: '0.7.3' ) {
			exclude group: 'org.slf4j', module: 'slf4j-simple'
		}
	}
}

tasks.named('test') {
	useJUnitPlatform()
}
```

### 1) file-center-common
```
    1) mkdir file-center-common
    2) mkdir -p src/main/java/com/weasley/common
    3) mkdir -p src/main/resources 
```


### 2) file-center-domain
```
    1) mkdir file-center-domain
    2) mkdir -p src/main/java/com/weasley/domain
    3) mkdir -p src/main/resources 
```

### 3) file-center-application
```
    1) mkdir file-center-application
    2) mkdir -p src/main/java/com/weasley/application
    3) mkdir -p src/main/resources 
```

### 4) file-center-interface
```
    1) mkdir file-center-interface
    2) mkdir -p src/main/java/com/weasley/interface
    3) mkdir -p src/main/resources 
```

## 3. boot scripts

## 4. logback

## 5. docs

## 6. SQL generate



## 7. file-center-common

### 1) ErrorCode

### 2) Response

### 3) Global Exception

### 4) Response advice
