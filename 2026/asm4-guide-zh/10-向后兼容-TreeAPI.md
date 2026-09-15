# 10. 向后兼容

## 10.1 引言

与 Core API（核心 API）一样，ASM 4.0 在 Tree API（树 API）中引入了一种新机制，以便在未来的 ASM 版本中确保向后兼容性。然而，在这里这一特性同样无法仅由 ASM 自身来保证。它要求用户在编写自己的代码时遵循若干简单的指南。本章的目标就是介绍这些指南，并说明 ASM Tree API 内部用于确保向后兼容性的机制。

## 10.2 指南

本节介绍使用 ASM Tree API 时必须遵循的指南，以确保你的代码在未来任何 ASM 版本中都保持有效（有效性的含义依据 5.1.1 节中定义的契约）。

首先，如果你使用 Tree API 编写类生成器，那么没有需要遵循的指南（与 Core API 一样）。你可以用任意构造器创建 `ClassNode` 及其他元素，并使用这些类的任意方法。

另一方面，如果你使用 Tree API 编写类分析器或类适配器，即如果你使用通过 `ClassReader.accept()` 直接或间接填充的 `ClassNode` 或其他类似类，或者如果你覆写这些类之一，那么你必须遵循下面介绍的若干指南。

### 10.2.1 基本规则

**创建类节点**

这里我们考虑的情况是：你创建一个 `ClassNode`，通过 `ClassReader` 填充它，然后分析或变换它，最后可选地用 `ClassWriter` 写出结果（其他节点类的讨论和指南是相同的；分析或变换由他人创建的 `ClassNode` 将在下一节讨论）。在这种情况下只有一条指南：

**指南 3**：要用 ASM 版本 X 的 Tree API 编写类分析器或适配器，请使用以该确切版本为参数的构造器来创建 `ClassNode`（而不是使用不带参数的默认构造器）。

这条指南的目的是：当通过 `ClassReader` 填充 `ClassNode` 时，一旦遇到未知特性（如向后兼容契约中所定义），就立即抛出错误。如果你不遵循这条指南，你的分析或变换代码可能在稍后遇到未知元素时失败，也可能虽然成功但产生错误的结果，因为它本不应该忽略这些未知元素。换言之，如果不遵循这条指南，契约的最后一条款可能无法得到保证。

这是如何实现的？在内部，ASM 4.0 中 `ClassNode` 的实现如下（这里我们复用 5.1.2 节的示例）：

```java
public class ClassNode extends ClassVisitor {
    public ClassNode() {
        super(ASM4, null);
    }
    public ClassNode(int api) {
        super(api, null);
    }
    ...
    public void visitSource(String source, String debug) {
        // 将 source 和 debug 存入本地字段 ...
    }
}
```

在 ASM 5.0 中，这段代码变成：

```java
public class ClassNode extends ClassVisitor {
    ...
    public void visitSource(String source, String debug) {
        if (api < ASM5) {
            // 将 source 和 debug 存入本地字段 ...
        } else {
            visitSource(null, source, debug);
        }
    }
    public void visitSource(Sring author, String source, String debug) {
        if (api < ASM5) {
            if (author == null)
                visitSource(source, debug);
            else
                throw new RuntimeException();
        } else {
            // 将 author、source 和 debug 存入本地字段 ...
        }
    }
    public void visitLicense(String license) {
        if (api < ASM5) throw new RuntimeException();
        // 将 license 存入本地字段 ...
    }
}
```

如果你使用 ASM 4.0，创建 `ClassNode(ASM4)` 不会做任何特殊的事情。但如果你升级到 ASM 5.0 而不修改你的代码，你会得到一个 5.0 版的 `ClassNode`，其 `api` 字段为 `ASM4 < ASM5`。于是很容易看出，如果输入类包含非 null 的 `author` 或 `license` 属性，那么通过 `ClassReader` 填充该 `ClassNode` 将会失败，正如我们的契约所定义的那样。如果你同时也升级自己的代码，把 `api` 字段改为 `ASM5`，并更新其余代码以考虑这些新属性，那么在填充该节点时就不会抛出任何错误。

注意，5.0 版 `ClassNode` 的代码与 5.0 版 `ClassVisitor` 的代码非常相似。这样做是为了在你定义 `ClassNode` 的子类时保证正确的语义（与 `ClassVisitor` 的子类类似——参见 10.2.2 节）。

**使用已有的类节点**

如果你的类分析器或适配器接收到的是由他人创建的 `ClassNode`，那么你无法确定创建它时传给其构造器的是哪个 ASM 版本（如果有的话）。你可以自己检查 `api` 字段，但如果你发现该版本高于你所支持的版本，简单地拒绝这个类就过于保守了。的确，有可能这个类并不包含任何未知特性。另一方面，你又无法测试未知特性是否存在（在我们的示例场景中，在编写 ASM 4.0 的代码时，你如何测试未知的 `license` 字段不存在于你的 `ClassNode` 中呢？因为在此阶段你并不知道将来会添加这样一个字段）。`ClassNode.check()` 方法正是为解决这个问题而设计的。由此得到下面这条指南：

**指南 4**：要用 ASM 版本 X 的 Tree API 编写类分析器或适配器，并且使用的是由他人创建的 `ClassNode`，请在以任何方式使用该 `ClassNode` 之前，先以该确切版本为参数调用它的 `check()` 方法。

其目的与指南 3 相同：如果不遵循这条指南，契约的最后一条款可能无法得到保证。这是如何实现的？在内部，ASM 4.0 中 `check` 方法的实现如下：

```java
public class ClassNode extends ClassVisitor {
    ...
    public void check(int api) {
        // 无需做任何事
    }
}
```

在 ASM 5.0 中，这段代码变成：

```java
public class ClassNode extends ClassVisitor {
    ...
    public void check(int api) {
        if (api < ASM5 && (author != null || license != null)) {
            throw new RuntimeException();
        }
    }
}
```

如果你的代码是为 ASM 4.0 编写的，并且你拿到的是一个 4.0 版的 `ClassNode`，其 `api` 字段为 `ASM4`，那么不会有任何问题，`check` 什么也不做。但如果你拿到的是一个 5.0 版的 `ClassNode`，那么 `check(ASM4)` 方法将在此节点确实包含非 null 的 `author` 或 `license` 时失败，即当它包含在 ASM 4.0 中未知的新特性时失败。

> **注意**：这条指南在你自行创建 `ClassNode` 时也可以使用。此时你不需要遵循指南 3，即不需要在 `ClassNode` 的构造器中指定 ASM 版本。检查将改为在 `check` 方法中进行（但这可能比在填充 `ClassNode` 时更早地进行检查效率更低）。

### 10.2.2 继承规则

如果你想要提供 `ClassNode` 或其他类似节点类的子类，那么指南 1 和指南 2 适用。注意，在一种经常使用的特殊情况下，即覆写了 `visitEnd()` 方法的 `MethodNode` 匿名子类：

```java
class MyClassVisitor extends ClassVisitor {
    ...
    public MethodVisitor visitMethod(...) {
        final MethodVisitor mv = super.visitMethod(...);
        if (mv != null) {
            return new MethodNode(ASM4) {
                public void visitEnd() {
                    // 执行一次变换
                    accept(mv);
                }
            }
        }
        return mv;
    }
}
```

那么指南 2 会自动得到满足（这个匿名类虽然没有被显式声明为 `final`，但无法被覆写）。你只需遵循指南 3，即在 `MethodNode` 的构造器中指定一个 ASM 版本（或者遵循指南 4，即在执行变换之前调用 `check(ASM4)`）。

### 10.2.3 其他包

`asm.util` 和 `asm.commons` 中的类，每个构造器都有两个变体：一个带 ASM 版本参数，一个不带。

如果你只是想按原样实例化并使用 `asm.util` 中的 `ASMifier`、`Textifier` 或 `CheckXxxAdapter` 类，或 `asm.commons` 包中的任何类，那么你可以用不带 ASM 版本参数的构造器来实例化它们。你也可以使用带 ASM 版本参数的构造器，但这会不必要地把这些组件限制在指定的 ASM 版本上（而使用无参构造器等价于说「使用最新的 ASM 版本」）。这就是为什么使用 ASM 版本参数的构造器被声明为 `protected`。

另一方面，如果你想覆写 `asm.util` 中的 `ASMifier`、`TextifierVisitor` 或 `CheckXxxAdapter` 类，或 `asm.commons` 包中的任何类，那么指南 1 和指南 2 适用。特别地，你的构造器必须用你想使用的 ASM 版本作为参数调用 `super(...)`。

最后，如果你想使用 `asm.tree.analysis` 中的 `Interpreter` 类或其子类，还是想覆写它们，也必须做同样的区分。另请注意，在使用 analysis 包之前，你必须创建一个 `MethodNode` 或从他人那里获取一个，并且在这里必须遵循指南 3 和指南 4，然后才能把该节点传给 `Analyzer`。
