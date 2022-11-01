title: Maven related
date: 2022-11-01
tags: [maven]
categories: maven
toc: true
---

# maven add module

1. 根目录pom添加
```
<packaging>pom</packaging>
```
2. maven 添加module
```
mvn archetype:generate -DgroupId=com.sweet7 -DartifactId=sweet7-domain -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
```
