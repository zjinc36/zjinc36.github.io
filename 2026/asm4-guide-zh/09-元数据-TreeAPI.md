# 目录

目录：[ASM4中文指南](2026/asm4-guide-zh/README.md)

# 9. 元数据

本章介绍用于已编译 Java 类元数据（例如注解）的 Tree API（树 API）。本章非常简短，因为这些元数据已经在第 4 章中介绍过，而且一旦了解了对应的 Core API（核心 API），Tree API 就很简单了。

> 笔记：
>
> 先看这一章为什么这么短：**元数据的处理方式在第 4 章已经全部讲完，本章只是把同一套概念搬上 Tree API。** 原文自己说了——一旦了解了对应的 Core API，树版几乎不用再解释。所以这章的读法是：把它当作第 4 章的「树版对照表」。
>
> 由此得出三条对应关系，先记住再往下看：**泛型 = 签名字符串**（树里没有 `SignatureNode`，签名还是塞在 `signature` 字段里）；**注解 = `AnnotationNode`**；**调试信息 = 几个专门的字段/节点**（9.3 节）。

## 9.1 泛型

Tree API 不提供任何对泛型的支持！的确，它和 Core API 一样用签名来表示泛型类型，但没有提供与 `SignatureVisitor` 对应的 `SignatureNode` 类，尽管这是可以做到的（事实上，至少用多个 Node 类来区分类型签名、方法签名和类签名会比较方便）。

> 笔记：
>
> 先看 9.1 的反常之处：Tree API 在泛型这里**没有新增节点类**。它仍然沿用 Core API 的做法，把泛型信息放在签名字符串里，只是没有提供对应的 `SignatureNode`。
>
> 由此得出读法：看到 Tree API 里的泛型，不要去找新的树节点；还是回到第 4 章那套签名规则，检查相关对象的 `signature` 字段。

## 9.2 注解

用于注解的 Tree API 基于 `AnnotationNode` 类，其公开 API 如下：

```java
public class AnnotationNode extends AnnotationVisitor {
    public String desc;
    public List<Object> values;
    public AnnotationNode(String desc);
    public AnnotationNode(int api, String desc);
    ... // AnnotationVisitor 接口的方法
    public void accept(AnnotationVisitor av);
}
```

`desc` 字段包含注解类型，而 `values` 字段包含名称-值对，其中每个名称后面都跟着与之关联的值（值的表示方式在 Javadoc 中有描述）。

如你所见，`AnnotationNode` 类继承自 `AnnotationVisitor` 类，还提供了一个 `accept` 方法，该方法以这种类型的对象作为参数，就像 `ClassNode` 和 `MethodNode` 类与类访问者和方法访问者类的关系一样。因此，我们之前针对类和方法看到的那些模式，同样可以用于组合注解的 Core API 与 Tree API 组件。例如，基于继承的模式（参见 7.2.2 节）的「匿名内部类」变体，适配到注解后就变成：

```java
public AnnotationVisitor visitAnnotation(String desc, boolean visible) {
    return new AnnotationNode(ASM4, desc) {
        @Override public void visitEnd() {
            // 在此处放入你的注解变换代码
            accept(cv.visitAnnotation(desc, visible));
        }
    };
}
```

> 笔记：
>
> 先看 9.2 的关键：`AnnotationNode` 的两个公开字段是**`desc` 存注解类型，`values` 存名称-值对**——一个名字后面紧跟一个值，成对交替。它继承自 `AnnotationVisitor`，所以像树里其他节点一样可以互相嵌套（注解的值里还能再放注解）。
>
> 再看它的复用套路：`AnnotationNode` 也提供 `accept(AnnotationVisitor)`，**与 `ClassNode.accept(ClassVisitor)`、`MethodNode.accept(MethodVisitor)` 是同一个「树 → 事件」出口模式**。示例里的匿名内部类就是 7.2.2 节那套继承变体：覆写 `visitEnd`，在 `accept(cv.visitAnnotation(desc, visible))` 之前插入你的变换。由此得出：**Core/Tree 组件的组合方式，在注解这里和类/方法那里完全一样。**

## 9.3 调试

编译某个类时所使用的源文件存储在 `ClassNode` 的 `sourceFile` 字段中。关于源代码行号的信息存储在 `LineNumberNode` 对象中，该类继承自 `AbstractInsnNode`。与 Core API 类似（在 Core API 中，行号信息与指令在同一时刻被访问），`LineNumberNode` 对象是指令列表的一部分。最后，源代码局部变量的名称和类型存储在 `MethodNode` 的 `localVariables` 字段中，该字段是一个 `LocalVariableNode` 对象列表。

> 笔记：
>
> 先看 9.3 分了三类调试信息：源文件名、行号、局部变量。源文件名放在 `ClassNode.sourceFile`；行号用 `LineNumberNode` 表示；局部变量名称和类型放在 `MethodNode.localVariables`。
>
> 再看行号为什么特殊：`LineNumberNode` 继承自 `AbstractInsnNode`，所以它不是单独挂在方法外面，而是和指令一起出现在指令列表中。由此得出：Tree API 里的调试信息也只是 Core API 事件的树形落点。
