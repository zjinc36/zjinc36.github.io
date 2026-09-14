# Memory

- "把以后还会用到的信息留下来。" 文件存储 + 索引 + 相关性选择 + 按需召回。
- Harness 层：Memory 在会话之外保存可复用知识，并在相关任务中取回。

- Agent 开始新会话时，messages 里没有上一次的对话。用户之前说过的编码偏好、项目背景和排查线索，下次任务还可能用到。没有持久存储，这些信息只能由用户重新说一遍。
- 把完整 transcript 留下来适合归档，却不适合每次都发给模型。对话会越来越长，当前任务需要的信息很难定位，旧事实也可能已经过期。Memory 要解决的是两个问题：哪些信息值得跨会话保存，以及当前任务应该取回哪几条。


## memory和skill的区别和联系

本质上它们都是 **「文件/目录 + 索引」** 这套结构，运行机制一模一样
- 两者都是一个 Markdown 文件 = 一条知识，靠 frontmatter 描述它，靠索引文件选择它，用到时才读正文
- 唯一的本质差别在于 **"谁写入"**
  - Skill：人类手写、只读、稳定，是给 Agent 的"操作手册"
  - Memory：Agent 自己从对话里提取、会增删整理，是"自累积的笔记"

| 区别   | Skill                       | Memory                               |
| ------ | --------------------------- | ------------------------------------ |
| 正文   | skills/*.md（人写）         | .memory/*.md（AI 提取）              |
| 索引   | 简短清单                    | MEMORY.md 索引                       |
| 元数据 | frontmatter 字段            | frontmatter（name/description/type） |
| 用法   | 启动时加载索引 → 按需读正文 | 同样：选索引 → 按需读正文            |

## memory具体流程




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
    hookPreToolUse@{shape: diamond, label: "「triggerHooks」工具使用前"}
    hookPostToolUse@{shape: diamond, label: "「triggerHooks」工具使用后"}

    subgraph toolBox[「toolRun」拥有的工具集合]
        toolSkill@{shape: rect, label: "toolSkill"}
        toolOther@{shape: rect, label: "toolOther......"}
    end

    contextCompact@{shape: rect, label: "「contextCompact」上下文压缩"}

    subgraph memoryLoadSave[「memoryLoadSave记忆提取与存储]
        memoryStore@{shape: cyl, label: "「.memory/」记忆存储"}
        memoryRecall@{shape: rect, label: "「loadMemories」召回相关记忆"}
        memoryExtract@{shape: rect, label: "「extractMemories」提取持久记忆"}
        memoryConsolidate@{shape: rect, label: "「consolidateMemories」合并去重"}
        memoryThreshold@{shape: diamond, label: "「记录数≥阈值？」"}
    end


    userChat --> messageList
    messageList --> contextCompact
    contextCompact --> memoryRecall
    memoryRecall --> LLM
    LLM -.-> |异常，API返回promptTooLong| toolResultBudget
    LLM --> |是| hookPreToolUse
    hookPreToolUse --> |通过权限检查| toolRun
    hookPreToolUse -.->|未通过hook| toolResult
    LLM --> |否，不再调用工具| memoryExtract
    toolRun === |toolRun细节| toolSkill
    toolSkill -->|调用skill文档成为上下文| skillMeta
    skillMeta -->|根据元数据加载详细skill| skillDescription
    toolRun --> hookPostToolUse
    hookPostToolUse --> |通过hook| toolResult
    hookPostToolUse --> |未通过hook| toolResult
    toolResult -.-> |工具调用结果| messageList

    memoryExtract --> |写入记录| memoryStore
    memoryStore --> memoryThreshold
    memoryThreshold --> |是，合并去重| memoryConsolidate
    memoryThreshold --> |否，无需合并| finalResult
    memoryConsolidate --> |合并回写完成| finalResult

    style userChat stroke:#ff0000, stroke-width:2px
    style processStart stroke:#ff0000, stroke-width:2px
    style finalResult stroke:#00aa00, stroke-width:2px


    messageList:::blueStrokeColor
    memoryLoadSave:::dashedNode

    classDef dashedNode stroke-dasharray: 5 5
    classDef blueStrokeColor stroke:#0000ff
```

