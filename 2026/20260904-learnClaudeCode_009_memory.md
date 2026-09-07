# Memory

- "把以后还会用到的信息留下来。" 文件存储 + 索引 + 相关性选择 + 按需召回。
- Harness 层：Memory 在会话之外保存可复用知识，并在相关任务中取回。

- Agent 开始新会话时，messages 里没有上一次的对话。用户之前说过的编码偏好、项目背景和排查线索，下次任务还可能用到。没有持久存储，这些信息只能由用户重新说一遍。
- 把完整 transcript 留下来适合归档，却不适合每次都发给模型。对话会越来越长，当前任务需要的信息很难定位，旧事实也可能已经过期。Memory 要解决的是两个问题：哪些信息值得跨会话保存，以及当前任务应该取回哪几条。



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

    contextCompact@{shape: rect, label: "「contextCompact」上下文压缩"}

    userChat --> messageList
    messageList --> contextCompact
    contextCompact --> LLM
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


    messageList:::blueStrokeColor

    classDef dashedNode stroke-dasharray: 5 5
    classDef blueStrokeColor stroke:#0000ff
```

