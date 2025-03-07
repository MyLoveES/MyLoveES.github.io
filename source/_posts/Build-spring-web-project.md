title: Build spring web project
date: 2025-03-06
tags: [project]
categories: self-build-roject
toc: true
---

# 一、项目生成

## 1、Spring Boot CLI 

1. 首先，你需要安装 Spring Boot CLI。你可以参考 Spring Boot 官方文档中的安装指南：https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started.html#getting-started.installing.cli    
```
brew tap spring-io/tap
brew install spring-boot
```

2. 创建一个基于 Gradle 的 Spring Boot 项目：     
```
spring init --build gradle-project --groupId=com.weasley --artifactId=mrsix --name=mrsix --description="MrSix: Pipeline framework" mrsix
```

# 二、子模块

### 1) submodule-common
```
    1) mkdir submodule-common
    2) mkdir -p src/main/java/com/weasley/common
    3) mkdir -p src/main/resources
```


### 2) submodule-domain
```
    1) mkdir submodule-domain
    2) mkdir -p src/main/java/com/weasley/domain
    3) mkdir -p src/main/resources
```

### 3) submodule-application
```
    1) mkdir submodule-application
    2) mkdir -p src/main/java/com/weasley/application
    3) mkdir -p src/main/resources
```

### 4) submodule-interface
```
    1) mkdir submodule-interface
    2) mkdir -p src/main/java/com/weasley/interface
    3) mkdir -p src/main/resources
```

### 5) submodule-infrastructure
```
    1) mkdir submodule-infrastructure
    2) mkdir -p src/main/java/com/weasley/infrastructure
    3) mkdir -p src/main/resources
```

## 2.1 gradle 
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

## 2.2 maven

```
mvn archetype:generate -DgroupId=com.weasley -DartifactId=sdk-common -Dversion=1.0.0 -DinteractiveMode=false
```

# 三、增加通用依赖

## 1. spring-boot-devtools
```
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
```

## 2. lombok
```
	compileOnly 'org.projectlombok:lombok:1.18.20'
	annotationProcessor 'org.projectlombok:lombok:1.18.20'
```

## 3. spring-boot-configuration-processor
```
    annotationProcessor "org.springframework.boot:spring-boot-configuration-processor"
```

## 4. validation
```
    implementation group: 'org.springframework.boot', name: 'spring-boot-starter-validation', version: '3.0.4'
```

## 5. mapstruct
```
    implementation 'org.mapstruct:mapstruct:1.5.3.Final'
    annotationProcessor 'org.mapstruct:mapstruct-processor:1.5.3.Final'
```

## 6. knife4j
```
    implementation group: 'com.github.xiaoymin', name: 'knife4j-openapi3-jakarta-spring-boot-starter', version: '4.0.0'
```

## 7. mybatis plus
```
    implementation group: 'com.baomidou', name: 'mybatis-plus-boot-starter', version: '3.5.3.1'
    implementation group: 'com.baomidou', name: 'mybatis-plus-generator', version: '3.5.3.1'
    implementation group: 'org.freemarker', name: 'freemarker', version: '2.3.31'
    implementation group: 'mysql', name: 'mysql-connector-java', version: '8.0.32'
```

## 8. spock
```
    testImplementation group: 'org.spockframework', name: 'spock-core', version: '2.3-groovy-4.0'
	testImplementation group: 'org.spockframework', name: 'spock-spring', version: '2.3-groovy-4.0'
```

## 9. h2
```
    testImplementation group: 'com.h2database', name: 'h2', version: '2.1.214'
```

## 10. embedded-redis 
```
    testImplementation (group: 'it.ozimov', name: 'embedded-redis', version: '0.7.3') {
		exclude group: 'org.slf4j', module: 'slf4j-simple'
	}
```

## 11. actuator
```
    implementation group: 'org.springframework.boot', name: 'spring-boot-starter-actuator', version: '3.0.5'
```

## 12. redission
```
    implementation group: 'org.redisson', name: 'redisson-spring-boot-starter', version: '3.20.0'
```

## 13. caffeine
```
    implementation group: 'com.github.ben-manes.caffeine', name: 'caffeine', version: '3.1.5'
```

## 14. hutool-core
```
    implementation group: 'cn.hutool', name: 'hutool-core', version: '5.8.15'
    implementation group: 'cn.hutool', name: 'hutool-extra', version: '5.8.16'
```

## 15. minio
```
    implementation group: 'io.minio', name:'minio', version: '8.4.3'
```

## 16. vavr
```
    implementation group: 'io.vavr', name: 'vavr', version: '0.10.4'
```

## 17. apm
```
    implementation group: 'org.apache.skywalking', name: 'apm-toolkit-logback-1.x', version: '8.15.0'
```

## 18. json-path
```
    implementation group: 'com.jayway.jsonpath', name: 'json-path', version: '2.8.0'
```


# 添加数据库表
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
