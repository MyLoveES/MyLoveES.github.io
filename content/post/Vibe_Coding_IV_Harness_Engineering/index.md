---
title: " Vibe Coding IV - Harness Engineering"
date: 2026-03-24
categories:
  - 技术
  - 教程
tags:
  - vibecoding
toc: true
image: Vibe_Coding_header.png
---
# 一、安装 Plugins / MCP

- superpowers

```
claude plugin install superpowers@claude-plugins-official
```

- context7

```
npx ctx7 setup --claude --api-key YOUR_API_KEY
```

- frontend-design

```
claude plugin install frontend-design@claude-plugins-official
```

- ui-ux-pro-max-skill

```
claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill
```

- figma

```
claude plugin install figma@claude-plugins-official

claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp
```

- stitch
```
# 添加 MCP
claude mcp add stitch --transport http https://stitch.googleapis.com/mcp --header "X-Goog-Api-Key: api-key" -s user

# 或者 安装 skills
npx skills add google-labs-code/stitch-skills --list

npx skills add google-labs-code/stitch-skills --skill react:components --global
```

# 二、Start a new idea!

1. 头脑风暴

```
使用 superpowers brainstorming skill。

我的想法：xxxx
```

在这个过程中，会对你的想法进行细化和澄清，并且会在网页中展示示例样式。

![Harness_02](Harness_02.png)
![Harness_01](Harness_01.png)

2. 编写计划

```
使用 superpowers writing-plans skill。基于 @spec.doc 编写执行计划
```

3. 执行计划

```
使用 superpowers executing-plans skill。执行计划。
```
## Reference

- Documents
	- [Effective harnesses for long running agents - Anthropic](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
	- [Harness engineering - OpenAI](https://openai.com/zh-Hans-CN/index/harness-engineering/)
	- [Improving Deep Agents with harness engineering - LangChain](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/)
	- [Lessons from Building Claude Code: Seeing like an Agent](https://x.com/trq212/status/2027463795355095314)
	- [How To Be A World-Class Agentic Engineer](https://x.com/systematicls/article/2028814227004395561)
- Open Source repos
	- [superpowers: agentic skills framework](https://github.com/obra/superpowers)
	- [Trellis: agent harness](https://github.com/mindfold-ai/Trellis)
	- [baoyu-skills: agents skills](https://github.com/JimLiu/baoyu-skills)
	- [opensec: Spec-driven development (SDD) for AI coding assistants](https://github.com/Fission-AI/OpenSpec)
	- [gstack: a developer's claude code setup](https://github.com/garrytan/gstack)
	- [gsd: spec-driven development system](https://github.com/gsd-build/get-shit-done)
	- [everything-claude-code: agent harness performance optimization system](https://github.com/affaan-m/everything-claude-code)
- Agent teams plugins （非官方）
	- [oh-my-claudecode](https://github.com/yeachan-heo/oh-my-claudecode)
	- [oh-my-codex](https://github.com/Yeachan-Heo/oh-my-codex)
	- [oh-my-opencode](https://github.com/code-yeongyu/oh-my-openagent)
	- [ccg-workflow](https://github.com/fengshao1227/ccg-workflow)
	- [ccw-workflow](https://github.com/catlog22/Claude-Code-Workflow)
- Other shares
	- [宝玉：Agent Skills 设计哲学和实战进化](https://www.bilibili.com/video/BV1HTXFBAEpF/?spm_id_from=333.337.search-card.all.click)
	- [GLM-5 一战封神，如何用他构建全自动开发系统？](https://www.bilibili.com/video/BV1zZcYz1EMy/)
	- [Harness_Engineering_全景解读与程序员心理认知准备.pdf](https://linux.do/uploads/short-url/hDuUfDPNDUv6Jdch3qqcqMyopod.pdf)
	- [Vibe Coding AReaL：零手打代码开发分布式 RL 训练框架](https://zhuanlan.zhihu.com/p/2003269671630165191)
- LinuxDo shares
	- [新年来分享我的oh-my-opencode配置和学习心得](https://linux.do/t/topic/1624433)
	- [OpenAI 提出 “Harness Engineering”：完全使用 Agent 进行编程的实践](https://linux.do/t/topic/1677645)
	- [最近 harness，自主进化很火，大家有什么经验和用法吗？](https://linux.do/t/topic/1789013)
	- [经过 8 个月 Claude Code 高强度实战，我们决定开源内部的最佳实践](https://linux.do/t/topic/1539636)
	- [都在聊AI-Native Engineering，分享几个（几十个？）AI coding workflow，有站内大佬的哦:>](https://linux.do/t/topic/1778922)
	- [Codex 增强版：对标 Claude Code 新增 Agent Teams、Hooks、anthropic api Agent 、WebUI](https://linux.do/t/topic/1664790)
	- [Vibecoding 进阶教程总集篇——从能用到可控](https://linux.do/t/topic/1776917)
	- [推荐一些关于最近爆火的Harness Engineering概念的资源](https://linux.do/t/topic/1805683)