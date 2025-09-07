---
title: Leetcode_274_H_Index
date: 2021-07-11 21:41:00
categories:
- "算法"
tags:
- "LeetCode"
- "排序"
- "中等"
toc: true
---
## 274. H-Index

Given an array of integers citations where citations[i] is the number of citations a researcher received for their ith paper, return compute the researcher's h-index.

According to the definition of h-index on Wikipedia: A scientist has an index h if h of their n papers have at least h citations each, and the other n − h papers have no more than h citations each.

If there are several possible values for h, the maximum one is taken as the h-index.

### 
```java
class Solution {
    public int hIndex(int[] citations) {
        int pageCount = citations.length;
        int[] pageRef = new int[pageCount + 1];
        for (int i = 0; i < pageCount; i++) {
            if (citations[i] > pageCount) {
                pageRef[pageCount]++;
            } else {
                pageRef[citations[i]]++;
            }
        }
        int totlePage = 0;
        for (int i = pageCount; i >= 0; i--) {
            totlePage += pageRef[i];
            if (totlePage >= i) {
                return i;
            }
        }
        return 0;
    }
}
```