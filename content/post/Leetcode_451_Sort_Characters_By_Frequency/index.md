---
title: Leetcode_451_Sort_Characters_By_Frequency
date: 2021-07-02 10:52:10
categories:
- "算法"
tags:
- "LeetCode"
- "哈希表"
- "字符串"
- "中等"
toc: true
---
### Sort Characters By Frequency

Given a string s, sort it in decreasing order based on the frequency of characters, and return the sorted string.

#### 排序
```java
class Solution {
    public String frequencySort(String s) {
        Map<Character, Integer> cm = new HashMap<Character, Integer>();
        int maxFreq = 0;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            int freq = cm.getOrDefault(c, 0) + 1;
            cm.put(c, freq);
            maxFreq = Math.max(freq, maxFreq);
        }
        List<Character> list = new ArrayList<Character>(cm.keySet());
        Collections.sort(list, (a, b) -> cm.get(b) - cm.get(a));
        StringBuilder s = new StringBuilder();
        for (Character c : list) {
            int count = cm.get(c);
            for (int i = 0; i < count; i++) {
                s.append(c);
            }
        }
        return s.toString();
    }
}
``` 

#### 桶排序

```java
class Solution {
    public String frequencySort(String s) {
        Map<Character, Integer> cm = new HashMap<Character, Integer>();
        int maxFreq = 0;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            int freq = cm.getOrDefault(c, 0) + 1;
            cm.put(c, freq);
            maxFreq = Math.max(freq, maxFreq);
        }
        StringBuffer[] buckets = new StringBuffer[maxFreq + 1];
        for (int i = 0; i <= maxFreq; i++) {
            buckets[i] = new StringBuffer();
        }
        for (Map.Entry<Character, Integer> entry : cm.entrySet()) {
            buckets[entry.getValue()].append(entry.getKey());
        }
        StringBuilder sb = new StringBuilder();
        for (int i = maxFreq; i > 0 ; i--) {
            String str = buckets[i].toString();
            for (int j = 0; j < str.length(); j++) {
                for (int k = 0; k < i; k++) {
                    sb.append(str.charAt(j));
                }
            }
        }
        return sb.toString();
    }
}
```