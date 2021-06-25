title: Leetcode_203_Remove_Linked_List_Elements
date: 2021-06-25 23:28:10
tags: [String]
categories: Leetcode
toc: true
---
## 191. 位1的个数

方法二：位运算优化
思路及解法

观察这个运算：n & (n−1)，其运算结果恰为把 n 的二进制位中的最低位的 1 变为 0 之后的结果。
​
 ，运算结果 4 即为把 6 的二进制位中的最低位的 1 变为 0 之后的结果。

这样我们可以利用这个位运算的性质加速我们的检查过程，在实际代码中，我们不断让当前的 n 与 n - 1 做与运算，直到 n 变为 0 即可。因为每次运算会使得 n 的最低位的 1 被翻转，因此运算次数就等于 n 的二进制位中 1 的个数。

```java
public class Solution {
    // you need to treat n as an unsigned value
    public int hammingWeight(int n) {
        int r = 0;
        while (n != 0) {
            n &= n - 1;
            r++;
        }
        return r;
    }
}
```