---
title: Leetcode_1818_Minimum_Absolute_Sum_Difference
date: 2021-07-15 22:04:20
categories:
- "算法"
tags:
- "LeetCode"
- "中等"
- "数组"
toc: true
---
## 1818. 绝对差值和

排序 & 二分查找，找到差距最大的那一项  
改变前后的差值为： |nums1[i] - nums2[i]| - |nums1[j] - nums2[i]|

```java
class Solution {
    public int minAbsoluteSumDiff(int[] nums1, int[] nums2) {
        final int MOD = 1000000007;
        int n = nums1.length;
        int[] rec = new int[n];
        System.arraycopy(nums1, 0, rec, 0, n);
        Arrays.sort(rec);
        int sum = 0, maxGap = 0;
        for (int i = 0; i < n; i++) {
            int gap = Math.abs(nums1[i] - nums2[i]);
            sum = (gap + sum) % MOD;
            int nearOne = getHigherPos(rec, nums2[i]);
            if (nearOne < n) {
                maxGap = Math.max(maxGap, gap - (rec[nearOne] - nums2[i]));
            }
            if (nearOne > 0) {
                maxGap = Math.max(maxGap, gap - (nums2[i] - rec[nearOne - 1]));
            }
        }
        return (sum - maxGap + MOD) % MOD;
    }

    
    private int getHigherPos(int[] arr, int target) {
        int low = 0, high = arr.length - 1;
        if (arr[high] < target) {
            return high + 1;
        } else {
            while (low < high) {
                int mid = (high - low) / 2 + low;
                if (arr[mid] > target) {
                    high = mid;
                } else {
                    low = mid + 1;
                }
            }
        }
        return low;
    } 
}
```