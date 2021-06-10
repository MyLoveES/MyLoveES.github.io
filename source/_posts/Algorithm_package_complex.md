title: Algorithm-背包问题_完全背包
date: 2021-06-08 17:52:13
tags: [Dynamic programming]
categories: Algorithm
toc: true
---
# 完全 背包问题

## 1. 完全背包

> 有N种物品和一个容量为T的背包，每种物品都就可以选择任意多个，第i种物品的价值为P[i]，体积为V[i]，求解：选哪些物品放入背包，可卡因使得这些物品的价值最大，并且体积总和不超过背包容量。  

> 跟01背包一样，完全背包也是一个很经典的动态规划问题，不同的地方在于01背包问题中，每件物品最多选择一件，而在完全背包问题中，只要背包装得下，每件物品可以选择任意多件。从每件物品的角度来说，与之相关的策略已经不再是选或者不选了，而是有取0件、取1件、取2件...直到取⌊T/Vi⌋（向下取整）件。

## 2. 分析

### a. 贪心？

根据性价比排序，性价比从高到底取。  
结论：不可行  
反例：如果一个背包的容量为10，有三件物品可供选择，分别是

|物品|价值|体积|
|---|---|---|
|A|5|5|
|B|8|7|
按照性价比，必然取一个B。但是取两个A明显收益更高。因此贪心不可行。

## 3. 解决

### 分治

和之前相似，直接递归即可

```java
public int solution(int[] w, int[] v, int c) {
  return cal(w, v, w.length, c);
}

public int cal(int w[], int v[], int i, int j) {
  if (i < 0 || j <= 0) {
    return 0;
  }
  int result = 0;
  if (w[i] > j) {
    result = cal(w, v, i - 1, j);
  } else if (i < 0) {
    result = v[i] * Math.floor(j / w[i]);
  } else {
    for (int k = 0; k * w[i] < j; k++) {
      int tmp = cal(w, v, i - 1, j - k * w[i]) + k * v[i];
      result = Math.max(result, tmp);
    }
  }
  return result;
}
```

### 动态规划

#### **递归**

```java
public int solution(int w[], int v[], int c) {
  int[][] result = new int[][];
  return cal();
}

public int cal(int w[], int v[], int[][] result, int i, int j) {
  if (result[i][j] != null) {
    return result[i][j];
  }
  if (i < 0 || j <= 0) {
    return 0;
  } else {
    if (w[i] > j) {
      result[i][j] = cal(w, v, result, i - 1, j);
    } else {
      for (int k = 0; k * w[i] <= j; k++) {
        int tmp = cal(w, v, result, i, j - k * w[i]);
        result[i][j] = Math.max(result[i][j], tmp);
      }
    }
  }
}
```

#### **迭代**

```java
public int solution(int w[], int v[], int c) {
  // 初始化为 r = 0 / r[i][0] = 0
  int[][] result = new int[][];
  for (int i = 1; i < w.length; i++) {
    for (int j = 0; j <= c; j++) {
      for (int k = 0; k * w[i] <= j; k++) {
        result[i][j] = Math.max(result[i][j], result[i - 1][j - k * w[i]] + k * v[i]);
      }
    }
  }
  return result[w.length][c];
}
```

#### **空间优化**
```java
public int solution(int w[], int v[], int c) {
  // 初始化为 r = 0 / r[0] = 0
  int[] result = new int[];
  for (int i = 0; i < w.length; i++) {
    for (int j = w[i]; j <= c; j++) {
      result[j] = Math.max(result[j], result[j - w[i]] + v[i]);
    }
  }
  return result[c];
}
```


> 原文作者：[弗兰克的猫](https://home.cnblogs.com/u/mfrank/)  
  原文链接：https://www.cnblogs.com/mfrank/p/10533701.html