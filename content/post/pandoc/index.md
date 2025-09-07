---
title: Pandoc mardown to pdf
date: 2022-05-06
categories:
- "技术"
tags:
- "工具"
- "Pandoc"
- "Markdown"
toc: true
---

```
pandoc --pdf-engine=xelatex --highlight-style zenburn --toc -V geometry:margin=1in -V urlcolor=NavyBlue -V CJKmainfont="STKaitiSC-Regular" ${input} ${output}
```
