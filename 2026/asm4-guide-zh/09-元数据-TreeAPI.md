# 9. 元数据

本章介绍用于已编译 Java 类元数据（例如注解）的 Tree API（树 API）。本章非常简短，因为这些元数据已经在第 4 章中介绍过，而且一旦了解了对应的 Core API（核心 API），Tree API 就很简单了。

## 9.1 泛型

Tree API 不提供任何对泛型的支持！的确，它和 Core API 一样用签名来表示泛型类型，但没有提供与 `SignatureVisitor` 对应的 `SignatureNode` 类，尽管这是可以做到的（事实上，至少用多个 Node 类来区分类型签名、方法签名和类签名会比较方便）。

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

## 9.3 调试

编译某个类时所使用的源文件存储在 `ClassNode` 的 `sourceFile` 字段中。关于源代码行号的信息存储在 `LineNumberNode` 对象中，该类继承自 `AbstractInsnNode`。与 Core API 类似（在 Core API 中，行号信息与指令在同一时刻被访问），`LineNumberNode` 对象是指令列表的一部分。最后，源代码局部变量的名称和类型存储在 `MethodNode` 的 `localVariables` 字段中，该字段是一个 `LocalVariableNode` 对象列表。
