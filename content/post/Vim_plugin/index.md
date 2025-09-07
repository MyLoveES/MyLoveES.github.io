---
title: Vim 插件
date: 2022-04-16
categories:
- "技术"
tags:
- "Vim"
- "编辑器"
- "工具"
- "插件"
toc: true
---
*只列出了我常用的操作*

# surround
|操作|快捷键|效果|
|----|------|----|
|插入|ysiw'|abc -> 'abc'|
||ysiwt<dep>|abc -> <dep>abc</dep>|
||ys3w)|print a,b -> print (a,b)|
||ys$)|print a,b -> print (a,b)|
||vwwS"|print a,b -> print "a,b"|
|替换|cs"'|"abc" -> 'abc'|
||csw'|abc def! -> abc 'def'!|
||csW'|abc def! -> abc 'def!'|
||cs)]|(abc) -> [abc]|
||cs){|(abc) -> { abc }|
|删除|ds'|'abc' -> abc|
||ds(|(abc)def -> abcdef|
||dst|<div>abc<div> -> <div>abc</div>|

# commentary
|操作|快捷键|效果|
|----|------|----|
|注释|gcc|abc -> //abc|
||gcap|abc -> //abc|
|取消注释|gcu|//abc -> abc|

# argtextobj
|操作|快捷键|效果|
|----|------|----|
|删除|daa|function(arg1, arg2) -> function(arg1)|
|更改|cia|function(arg1, arg2) -> function(arg1, )|
||cia|function(arg1, arg2, arg3) -> function(arg1, arg2, arg3)|
||cia|function(arg1, func(a1, a2)) -> function(arg1, )|

# exchange
|操作|快捷键|效果|
|----|------|----|
|替换|cx{motion}|abcdef123 -> abc123def|
|替换line|cxx|abc -> 123|
|visual mode|X|cx|
|清除缓存|cxc||

# textobj-entire
|操作|快捷键|效果|
|----|------|----|
|删除|dae/die||

# easymotion
|操作|快捷键|效果|
|----|------|----|
|搜索|<leader><leader>f|搜索|
|搜索|<leader><leader>s|搜索|

# replace with register
|操作|快捷键|效果|
|----|------|----|
|粘贴|gr{motion}|abcdef -> abcabc|

# NERDTree
|操作|快捷键|效果|
|----|------|----|
|Tree打开关闭|ctrl+n||
|光标在目录树与文件间切换|ctrl+w+w||
|切换到前一个tab|g+T||
|切换到后一个tab|g+t||
|在新 Tab 中打开选中文件/书签，并跳到新 Tab|t||
|关闭当前的 tab|:tabc||
|关闭所有其他的 tab|:tabo||

# paragraph-motion
|操作|快捷键|效果|
|----|------|----|
|shift + {/}|段落移动|即使空格行也算|
