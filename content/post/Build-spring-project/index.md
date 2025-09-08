---
title: Build spring project
date: 2023-03-18
categories:
- "技术"
tags:
- "Java"
- "Spring"
- "项目构建"
toc: true
---

## 一、项目生成

### Spring Initializr 

1. 访问 Spring Initializr 的网站：https://start.spring.io/  
2. 选择语言和 Spring Boot 版本。默认是 Java 和最新版本的 Spring Boot。  
3. 选择项目元数据，包括 Group、Artifact、Name、Description、Package Name 等信息。  
4. 选择项目依赖，比如 Web、JPA、Security 等。根据具体需求选择所需依赖，可以使用搜索框进行搜索。   
5. 确认上面的信息都填写正确后，点击 Generate 按钮，即可生成一个基于 Maven 的 Spring Boot 项目的压缩包。       
6. 下载该压缩包，并解压到本地磁盘上。  

### 2、Spring Boot CLI 

1. 首先，你需要安装 Spring Boot CLI。你可以参考 Spring Boot 官方文档中的安装指南：https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started.html#getting-started.installing.cli    
2. 打开命令行终端，输入以下命令，创建一个基于 Maven 的 Spring Boot 项目：     
```
spring init --build maven --groupId=com.weasley --artifactId=file-center --name=file-center --description="file-center" file-center   
```

#### 意外情况
1. Java - Gradle - Springboot 版本   
```
https://stackoverflow.com/questions/74931848/spring-boot-3-x-upgrade-could-not-resolve-org-springframework-bootspring-boot

Go to the settings --> Build, Execution, Deployment --> Build Tools --> Gradle. Click on your gradle project under 'Gradle Projects'. Choose your Gradle JVM for the project
```

## 二、子模块

#### submodule-common
```
    1) mkdir submodule-common
    2) mkdir -p src/main/java/com/weasley/common
    3) mkdir -p src/main/resources
```


#### submodule-domain
```
    1) mkdir submodule-domain
    2) mkdir -p src/main/java/com/weasley/domain
    3) mkdir -p src/main/resources
```

#### submodule-application
```
    1) mkdir submodule-application
    2) mkdir -p src/main/java/com/weasley/application
    3) mkdir -p src/main/resources
```

#### submodule-interface
```
    1) mkdir submodule-interface
    2) mkdir -p src/main/java/com/weasley/interface
    3) mkdir -p src/main/resources
```

#### submodule-infrastructure
```
    1) mkdir submodule-infrastructure
    2) mkdir -p src/main/java/com/weasley/infrastructure
    3) mkdir -p src/main/resources
```

### gradle 
根目录 setting.gradle
```
    include 'submodule-common'
    include 'submodule-domain'
    include 'submodule-application'
    include 'submodule-interface'
    include 'submodule-infrastructure'
```

根目录 build.gradle
```
// 定义项目构建所需的仓库和依赖项
// 定义项目构建所需的仓库和依赖项
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

    dependencyManagement {
        imports {
            mavenBom 'org.springframework.boot:spring-boot-dependencies:3.0.4'
        }
    }
}

subprojects {

    apply plugin: 'java'
    apply plugin: 'java-library'
    apply plugin: 'groovy'
    apply plugin: 'org.springframework.boot'
    apply plugin: 'io.spring.dependency-management'

    dependencies {}

    tasks.named('test') {
        useJUnitPlatform()
    }
}
```

### maven

```
mvn archetype:generate -DgroupId=com.weasley -DartifactId=sdk-common -Dversion=1.0.0 -DinteractiveMode=false
```

## 三、增加通用依赖

### spring-boot-devtools
```
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
```

### lombok
```
	compileOnly 'org.projectlombok:lombok:1.18.20'
	annotationProcessor 'org.projectlombok:lombok:1.18.20'
```

### spring-boot-configuration-processor
```
    annotationProcessor "org.springframework.boot:spring-boot-configuration-processor"
```

### validation
```
    implementation group: 'org.springframework.boot', name: 'spring-boot-starter-validation', version: '3.0.4'
```

### mapstruct
```
    implementation 'org.mapstruct:mapstruct:1.5.3.Final'
    annotationProcessor 'org.mapstruct:mapstruct-processor:1.5.3.Final'
```

### knife4j
```
    implementation group: 'com.github.xiaoymin', name: 'knife4j-openapi3-jakarta-spring-boot-starter', version: '4.0.0'
```

### mybatis plus
```
    implementation group: 'com.baomidou', name: 'mybatis-plus-boot-starter', version: '3.5.3.1'
    implementation group: 'com.baomidou', name: 'mybatis-plus-generator', version: '3.5.3.1'
    implementation group: 'org.freemarker', name: 'freemarker', version: '2.3.31'
    implementation group: 'mysql', name: 'mysql-connector-java', version: '8.0.32'
```

### spock
```
    testImplementation group: 'org.spockframework', name: 'spock-core', version: '2.3-groovy-4.0'
	testImplementation group: 'org.spockframework', name: 'spock-spring', version: '2.3-groovy-4.0'
```

### h2
```
    testImplementation group: 'com.h2database', name: 'h2', version: '2.1.214'
```

### embedded-redis 
```
    testImplementation (group: 'it.ozimov', name: 'embedded-redis', version: '0.7.3') {
		exclude group: 'org.slf4j', module: 'slf4j-simple'
	}
```

### actuator
```
    implementation group: 'org.springframework.boot', name: 'spring-boot-starter-actuator', version: '3.0.5'
```

### redission
```
    implementation group: 'org.redisson', name: 'redisson-spring-boot-starter', version: '3.20.0'
```

### caffeine
```
    implementation group: 'com.github.ben-manes.caffeine', name: 'caffeine', version: '3.1.5'
```

### hutool-core
```
    implementation group: 'cn.hutool', name: 'hutool-core', version: '5.8.15'
    implementation group: 'cn.hutool', name: 'hutool-extra', version: '5.8.16'
```

### minio
```
    implementation group: 'io.minio', name:'minio', version: '8.4.3'
```

### vavr
```
    implementation group: 'io.vavr', name: 'vavr', version: '0.10.4'
```

### apm
```
    implementation group: 'org.apache.skywalking', name: 'apm-toolkit-logback-1.x', version: '8.15.0'
```

### json-path
```
    implementation group: 'com.jayway.jsonpath', name: 'json-path', version: '2.8.0'
```


## 添加数据库表
```
import com.baomidou.mybatisplus.generator.FastAutoGenerator;
import com.baomidou.mybatisplus.generator.config.OutputFile;
import com.baomidou.mybatisplus.generator.engine.FreemarkerTemplateEngine;
import org.junit.jupiter.api.Test;

import java.util.Collections;

public class CodeGenerator {

    @Test
    public void generator() {
        FastAutoGenerator.create("jdbc:mysql://localhost:3306/file_center?serverTimezone=Asia/Shanghai", "", "")
                .globalConfig(builder -> {
                    builder.author("baomidou") // 设置作者
                            .enableSwagger() // 开启 swagger 模式
                            .fileOverride() // 覆盖已生成文件
                            .outputDir("/Users/disco/Downloads/outputFileCenter"); // 指定输出目录
                })
                .packageConfig(builder -> {
                    builder.parent("com.baomidou.mybatisplus.samples.generator") // 设置父包名
                            .moduleName("system") // 设置父包模块名
                            .pathInfo(Collections.singletonMap(OutputFile.xml, "/Users/disco/Downloads/outputFileCenter")); // 设置mapperXml生成路径
                })
                .strategyConfig(builder -> {
                    builder.addInclude(Collections.emptyList()); // 设置需要生成的表名
//                            .addTablePrefix("t_", "c_"); // 设置过滤表前缀
                })
                .templateEngine(new FreemarkerTemplateEngine()) // 使用Freemarker引擎模板，默认的是Velocity引擎模板
                .execute();
    }
}
```
