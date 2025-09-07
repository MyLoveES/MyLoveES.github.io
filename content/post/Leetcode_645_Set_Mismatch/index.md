---
title: Leetcode_645_Set_Mismatch
date: 2021-07-02 21:44:10
categories:
- "算法"
tags:
- "LeetCode"
- "哈希表"
- "简单"
toc: true
---
## 451. Sort Characters By Frequency

Given a string s, sort it in decreasing order based on the frequency of characters, and return the sorted string.

### 
```java
class Solution {
    public String frequencySort(String s) {
        Map<Character, Integer> cm = new HashMap();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            int count = cm.getOrDefault(c, 0) + 1;
            cm.put(c, count);
        }
        List<Character> keyList = new ArrayList(cm.keySet());
        Collections.sort(keyList, (a,b) -> cm.get(b) - cm.get(a));
        StringBuilder sb = new StringBuilder();
        for (Character c : keyList) {
            int freq = cm.get(c);
            for (int i = 0; i < freq; i++) {
                sb.append(c);
            }
        }
        return sb.toString();
    }
}
```