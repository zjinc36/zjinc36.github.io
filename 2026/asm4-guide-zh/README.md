# ASM 4.0 —— Java 字节码工程库（中文翻译）

本目录是 Eric Bruneton 所著 **[《ASM 4.0 — A Java bytecode engineering library》](https://asm.ow2.io/asm4-guide.pdf)**
（Version 2.0, September 2011，共 154 页）的完整中文翻译，按原书章节组织为Markdown 文件。

## 目录结构

| 原文                                                                  | 对应原书章节                               | 原书页码 | 「AI」教程                                                |
| --------------------------------------------------------------------- | ------------------------------------------ | -------- | --------------------------------------------------- |
| [`00-封面与版权.md`](2026/asm4-guide-zh/00-封面与版权.md)             | 封面、版权声明、免责声明、目录             | —        | —                                                   |
| [`01-引言.md`](2026/asm4-guide-zh/01-引言.md)                         | 1. Introduction                            | 1–6      | —                                                   |
| [`02-类.md`](2026/asm4-guide-zh/02-类.md)                             | 2. Classes                                 | 9–30     | [`02-类-教程.md`](2026/asm4-guide-zh/02-类-教程.md) |
| [`03-方法.md`](2026/asm4-guide-zh/03-方法.md)                         | 3. Methods                                 | 31–66    |                                                     |
| [`04-元数据.md`](2026/asm4-guide-zh/04-元数据.md)                     | 4. Metadata                                | 67–80    |                                                     |
| [`05-向后兼容.md`](2026/asm4-guide-zh/05-向后兼容.md)                 | 5. Backward compatibility                  | 81–88    |                                                     |
| [`06-类-TreeAPI.md`](2026/asm4-guide-zh/06-类-TreeAPI.md)             | 6. Tree Classes                            | 91–100   |                                                     |
| [`07-方法-TreeAPI.md`](2026/asm4-guide-zh/07-方法-TreeAPI.md)         | 7. Tree Methods                            | 101–114  |                                                     |
| [`08-方法分析.md`](2026/asm4-guide-zh/08-方法分析.md)                 | 8. Method Analysis                         | 115–126  |                                                     |
| [`09-元数据-TreeAPI.md`](2026/asm4-guide-zh/09-元数据-TreeAPI.md)     | 9. Tree Metadata                           | 127–128  |                                                     |
| [`10-向后兼容-TreeAPI.md`](2026/asm4-guide-zh/10-向后兼容-TreeAPI.md) | 10. Tree Backward compatibility            | 129–134  |                                                     |
| [`11-附录A.md`](2026/asm4-guide-zh/11-附录A.md)                       | Appendix A. Bytecode instruction reference | 135–146  |                                                     |

`images/` 目录保存了原书全部 23 幅插图的截图（20 幅编号插图 + 3 幅无编号插图），正文中编号插图以 `![图 x.y](images/figure-x.y.png)` 的形式引用，无编号插图以`![原书第 N 页插图](images/figure-pNN.png)` 的形式引用。原书末尾的索引（Index，第 147–148 页）为英文关键词索引，未作翻译。

## 翻译约定

- **章节层级**：原书章标题（如 `2. Classes`）译为一级标题 `# 2. 类`；
  `x.y` 节译为 `## x.y ...`；`x.y.z` 小节译为 `### x.y.z ...`。
- **代码**：所有 Java 代码、字节码指令表均保持原样（包括原书中的拼写错误），
  仅翻译代码中的注释。
- **术语**：统一使用业内通行译法，关键术语首次出现时以「中文（English）」
  形式给出，例如「操作数栈（operand stack）」「访问者（visitor）」。
- **图表**：图标题译为 `**图 x.y：……**`，并在其下方嵌入原图截图。
- **页码**：正文中出现的原书页码引用（如「第 42 页」）保留，便于与英文原版对照。

## 版权

原书版权归 Eric Bruneton 所有，其版权声明允许非商业性的复制与分发。
详见 [`00-封面与版权.md`](2026/asm4-guide-zh/00-封面与版权.md)。
