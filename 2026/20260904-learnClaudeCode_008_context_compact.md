# context compact

- 上下文总会满，先整理，再总结
- 可以把上下文窗口看作模型当前使用的一张草稿纸（草稿纸的大小固定）。用户消息、模型回复、tool_use 和 tool_result 都会按顺序写在这张纸上。模型每次继续工作时，都要重新读取这些内容。

## 四个函数说明
- toolResultBudget  — 大件先存仓库。
  - 工具输出（读文件、跑命令的结果）可能巨大。一次调了多个工具，所有结果加起来超过 20 万字符时，从最大的开始，把超过 3 万字符的结果完整写到硬盘（ .task_outputs/tool-results/ ），上下文里只留“文件路径 + 前 2000 字预览”
  - 类比：快递箱太大塞不进抽屉 → 箱子存仓库，抽屉里只放一张取货单。内容没丢，要用随时取。
- snipCompact  — 聊天记录太长，剪中间
  - 消息超过 50 条时，先把完整历史存档到  .transcripts/ ，然后只留开头 3 条 + 最近 47 条，中间换成一行“[47 条消息已归档在 xxx]”
  - 类比：聊天记录太长，把中间部分打包存档，只留开头和结尾。
  - 细节：下剪刀时会避开“工具调用”和“工具结果”这对搭档，剪散了 API 会直接报错。
- microCompact  — 看过的旧结果，折叠成一行
  - 模型已经读过的工具结果里，只保留最近 3 条完整的；更早的、超过 120 字符的，正文换成一行占位符： `[Earlier tool result omitted.]`  或  `[已存到某文件]` 。刚产生、模型还没看过的结果绝不动——保证每条新结果至少被完整读一次。
  - 类比：旧聊天里的长文件内容，看过了就折叠成一行摘要。
- compactHistory  — 实在装不下，写备忘录
  - 前三步做完还超 5 万字符时的终极手段：全部历史存档 → 让模型把历史总结成一份简短的事实摘要（目标、决定、文件、剩余工作、用户约束）→ 用一条  `[Compacted]`  消息替换全部历史。
  - 类比：把整本日记浓缩成一页备忘录，原文存档备查。摘要里明确区分“当前用户请求”和“历史摘要”，防止模型把历史里的指令当成命令执行。

前三步是纯文本操作，不花一分钱（不调 API）；只有第四步才多花一次模型调用。所以顺序固定：能转存的先转存，能剪的先剪，能折叠的先折叠，最后才总结

## 流程图
```mermaid
flowchart TD
    processStart@{shape: rounded, label: "程序启动"}
    skillLoad@{shape: rect, label: "「skillLoad」加载skill到内存"}
    skillMeta@{shape: rect, label: "「skillMeta」skill的元数据（catalog + name + 摘要）"}
    skillDescription@{shape: rect, label: "「skillDescription」详细的skill内容"}

    processStart --> |加载skill文档| skillLoad
    skillLoad -.-|载入元数据| skillMeta

    userChat@{shape: rounded, label: "「userChat」用户提问"}
    LLM@{shape: diamond, label: "「LLM」需要使用工具？" }
    toolRun@{shape: rounded, label: "「toolRun」执行工具调用"}
    finalResult@{shape: rounded, label: "「finalResult」返回结果"}
    messageList@{shape: rect, label: "「messageList」累积消息列表"}
    toolResult@{shape: rect, label: "「toolResult」工具结果"}
    hookPreToolUse@{shape: rect, label: "「triggerHooks」工具使用前"}
    hookPostToolUse@{shape: rect, label: "「triggerHooks」工具使用后"}

    subgraph toolBox[「toolRun」拥有的工具集合]
        toolSkill@{shape: rect, label: "toolSkill"}
        toolOther@{shape: rect, label: "toolOther......"}
    end

    subgraph contextCompact[「contextCompact」上下文压缩]
        toolResultBudget@{shape: rect, label: "「toolResultBudget」工具输出压缩"}
        snipCompact@{shape: rect, label: "「snipCompact」聊天记录太长，剪中间"}
        microCompact@{shape: rect, label: "「microCompact」看过的旧结果，折叠成一行"}
        compactHistory@{shape: rect, label: "「compactHistory」实在装不下，写备忘录"}
        overLimit@{shape: diamond, label: "「overLimit」计算是否超过限制"}
    end

    userChat --> messageList
    messageList --> contextCompact
    toolResultBudget --> snipCompact
    snipCompact --> microCompact
    microCompact --> overLimit
    overLimit --> |是| compactHistory
    overLimit --> |否| LLM
    LLM -.-> |异常，API返回promptTooLong| toolResultBudget
    LLM --> |是| hookPreToolUse
    hookPreToolUse --> |通过权限检查| toolRun
    hookPreToolUse -.->|未通过hook| toolResult
    LLM --> |否| finalResult
    toolRun === |toolRun细节| toolSkill
    toolSkill -->|调用skill文档成为上下文| skillMeta
    skillMeta -->|根据元数据加载详细skill| skillDescription
    toolRun --> hookPostToolUse
    hookPostToolUse --> |通过hook| toolResult
    hookPostToolUse --> |未通过hook| toolResult
    toolResult -.-> |工具调用结果| messageList

    style userChat stroke:#ff0000, stroke-width:2px
    style processStart stroke:#ff0000, stroke-width:2px

    contextCompact:::dashedNode

    messageList:::blueStrokeColor

    classDef dashedNode stroke-dasharray: 5 5
    classDef blueStrokeColor stroke:#0000ff
```

