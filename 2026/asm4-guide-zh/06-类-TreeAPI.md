# 6. 类（Tree API）

本章介绍如何使用 ASM Tree API（树 API）生成和变换类。本章首先单独介绍 Tree API，然后说明如何把它与 Core API（核心 API）组合起来。用于方法内容、注解和泛型的 Tree API 将在后续各章中介绍。

## 6.1 接口与组件

### 6.1.1 展示

用于生成和变换已编译 Java 类的 ASM Tree API 基于 `ClassNode` 类（参见图 6.1）。

```java
public class ClassNode ... {
    public int version;
    public int access;
    public String name;
    public String signature;
    public String superName;
    public List<String> interfaces;
    public String sourceFile;
    public String sourceDebug;
    public String outerClass;
    public String outerMethod;
    public String outerMethodDesc;
    public List<AnnotationNode> visibleAnnotations;
    public List<AnnotationNode> invisibleAnnotations;
    public List<Attribute> attrs;
    public List<InnerClassNode> innerClasses;
    public List<FieldNode> fields;
    public List<MethodNode> methods;
}
```

**图 6.1：ClassNode 类（仅显示字段）**

![图 6.1](images/figure-6.1.png)

如你所见，该类的公开字段与图 2.1 中给出的类文件结构各节相对应。这些字段的内容与 Core API 中相同。例如 `name` 是内部名，`signature` 是类签名（参见 2.1.2 节和 4.1 节）。有些字段包含其他的 `XxxNode` 类：这些类将在后续各章中详细介绍，它们具有相似的结构，即拥有与类文件结构的各个子节相对应的字段。例如 `FieldNode` 类如下所示：

```java
public class FieldNode ... {
    public int access;
    public String name;
    public String desc;
    public String signature;
    public Object value;
    public FieldNode(int access, String name, String desc,
            String signature, Object value) {
        ...
    }
    ...
}
```

`MethodNode` 类与之类似：

```java
public class MethodNode ... {
    public int access;
    public String name;
    public String desc;
    public String signature;
    public List<String> exceptions;
    ...
    public MethodNode(int access, String name, String desc,
            String signature, String[] exceptions)
    {
        ...
    }
}
```

### 6.1.2 生成类

用 Tree API 生成一个类，仅仅就是创建一个 `ClassNode` 对象并初始化它的字段。例如，2.2.3 节中的 `Comparable` 接口可以按如下方式构建，其代码量与 2.2.3 节大致相同：

```java
ClassNode cn = new ClassNode();
cn.version = V1_5;
cn.access = ACC_PUBLIC + ACC_ABSTRACT + ACC_INTERFACE;
cn.name = "pkg/Comparable";
cn.superName = "java/lang/Object";
cn.interfaces.add("pkg/Mesurable");
cn.fields.add(new FieldNode(ACC_PUBLIC + ACC_FINAL + ACC_STATIC,
        "LESS", "I", null, new Integer(-1)));
cn.fields.add(new FieldNode(ACC_PUBLIC + ACC_FINAL + ACC_STATIC,
        "EQUAL", "I", null, new Integer(0)));
cn.fields.add(new FieldNode(ACC_PUBLIC + ACC_FINAL + ACC_STATIC,
        "GREATER", "I", null, new Integer(1)));
cn.methods.add(new MethodNode(ACC_PUBLIC + ACC_ABSTRACT,
        "compareTo", "(Ljava/lang/Object;)I", null, null));
```

与使用 Core API 相比，使用 Tree API 生成一个类大约多花 30% 的时间（参见附录 A.1），并且消耗更多内存。但它使得可以按任意顺序生成类的各个元素，这在某些情况下会很方便。

### 6.1.3 添加和删除类成员

添加和删除类成员，仅仅就是在 `ClassNode` 对象的 `fields` 或 `methods` 列表中增加或删除元素。例如，为了能够方便地组合类变换器，我们如下定义 `ClassTransformer` 类：

```java
public class ClassTransformer {
    protected ClassTransformer ct;
    public ClassTransformer(ClassTransformer ct) {
        this.ct = ct;
    }
    public void transform(ClassNode cn) {
        if (ct != null) {
            ct.transform(cn);
        }
    }
}
```

那么 2.2.5 节中的 `RemoveMethodAdapter` 就可以如下实现：

```java
public class RemoveMethodTransformer extends ClassTransformer {
    private String methodName;
    private String methodDesc;
    public RemoveMethodTransformer(ClassTransformer ct,
            String methodName, String methodDesc) {
        super(ct);
        this.methodName = methodName;
        this.methodDesc = methodDesc;
    }
    @Override public void transform(ClassNode cn) {
        Iterator<MethodNode> i = cn.methods.iterator();
        while (i.hasNext()) {
            MethodNode mn = i.next();
            if (methodName.equals(mn.name) && methodDesc.equals(mn.desc)) {
                i.remove();
            }
        }
        super.transform(cn);
    }
}
```

可以看出，与 Core API 的主要区别在于：你需要遍历所有方法，而使用 Core API 时则无需这样做（`ClassReader` 会替你完成）。事实上，这一区别对几乎所有基于树的变换都成立。例如，2.2.6 节中的 `AddFieldAdapter` 在用 Tree API 实现时同样需要一个迭代器：

```java
public class AddFieldTransformer extends ClassTransformer {
    private int fieldAccess;
    private String fieldName;
    private String fieldDesc;
    public AddFieldTransformer(ClassTransformer ct, int fieldAccess,
            String fieldName, String fieldDesc) {
        super(ct);
        this.fieldAccess = fieldAccess;
        this.fieldName = fieldName;
        this.fieldDesc = fieldDesc;
    }
    @Override public void transform(ClassNode cn) {
        boolean isPresent = false;
        for (FieldNode fn : cn.fields) {
            if (fieldName.equals(fn.name)) {
                isPresent = true;
                break;
            }
        }
        if (!isPresent) {
            cn.fields.add(new FieldNode(fieldAccess, fieldName, fieldDesc,
                    null, null));
        }
        super.transform(cn);
    }
}
```

与生成类时一样，使用 Tree API 变换类比使用 Core API 花费更多时间、消耗更多内存。但它使得某些变换更容易实现。例如，有一种变换会向类中添加一个注解，该注解包含类内容的数字签名。使用 Core API 时，只有访问完整个类之后才能计算数字签名，但此时再添加包含该签名的注解已经太晚，因为注解必须在类成员之前被访问。使用 Tree API 时这个问题就不存在了，因为在这种情况下没有这样的约束。

事实上，用 Core API 也可以实现 `AddDigitialSignature` 示例，但那样必须分两趟变换这个类。在第一趟中，用一个 `ClassReader`（不使用 `ClassWriter`）访问该类，以便根据类的内容计算数字签名。在第二趟中，复用同一个 `ClassReader` 对该类做第二次访问，这一次把 `AddAnnotationAdapter` 串接到一个 `ClassWriter` 上。把这个论证推广开来可以看出，事实上任何变换都可以仅用 Core API 实现，必要时分多趟进行。但这会增加变换代码的复杂度，需要在各趟之间保存状态（其复杂度可能与一棵完整的树表示相当！），而且多次解析类是有代价的，必须把这一代价与构造相应 `ClassNode` 的代价相比较。

结论是：Tree API 通常用于那些无法用 Core API 一趟完成的变换。但当然也有例外。例如，混淆器无法一趟实现，因为在原始名到混淆名的映射完全构建好之前，你无法变换类，而构建该映射需要解析所有的类。但 Tree API 也不是一个好的解决方案，因为它需要把所有待混淆类的对象表示都保存在内存中。在这种情况下，更好的做法是使用 Core API 并分两趟：一趟计算原始名与混淆名之间的映射（一张简单的哈希表，其内存需求远小于所有类的完整对象表示），另一趟则基于该映射来变换这些类。

## 6.2 组件组合

到目前为止，我们只看到了如何创建和变换 `ClassNode` 对象，但还没有看到如何从类的字节数组表示构造一个 `ClassNode`，或者反过来，如何从 `ClassNode` 构造该字节数组。事实上，这是通过组合 Core API 与 Tree API 的组件来完成的，本节将对此加以说明。

### 6.2.1 展示

除了图 6.1 中显示的字段之外，`ClassNode` 类还继承 `ClassVisitor` 类，并提供了一个以 `ClassVisitor` 作为参数的 `accept` 方法。`accept` 方法根据 `ClassNode` 的字段值生成事件，而 `ClassVisitor` 的各方法执行相反的操作，即根据收到的事件设置 `ClassNode` 的字段：

```java
public class ClassNode extends ClassVisitor {
    ...
    public void visit(int version, int access, String name,
            String signature, String superName, String[] interfaces[]) {
        this.version = version;
        this.access = access;
        this.name = name;
        this.signature = signature;
        ...
    }
    ...
    public void accept(ClassVisitor cv) {
        cv.visit(version, access, name, signature, ...);
        ...
    }
}
```

因此，从字节数组构造 `ClassNode` 可以通过把它与 `ClassReader` 组合来完成：`ClassReader` 生成的事件由 `ClassNode` 组件消费，从而完成其字段的初始化（从上面的代码可以看出这一点）：

```java
ClassNode cn = new ClassNode();
ClassReader cr = new ClassReader(...);
cr.accept(cn, 0);
```

对称地，把 `ClassNode` 与 `ClassWriter` 组合，即可将其转换为字节数组表示：由 `ClassNode` 的 `accept` 方法生成的事件由 `ClassWriter` 消费：

```java
ClassWriter cw = new ClassWriter(0);
cn.accept(cw);
byte[] b = cw.toByteArray();
```

### 6.2.2 模式

用 Tree API 变换一个类，可以把这些要素组合起来实现：

```java
ClassNode cn = new ClassNode(ASM4);
ClassReader cr = new ClassReader(...);
cr.accept(cn, 0);
... // 在此处按需变换 cn
ClassWriter cw = new ClassWriter(0);
cn.accept(cw);
byte[] b = cw.toByteArray();
```

也可以把基于树的类变换器当作 Core API 中的类适配器来使用。为此有两种常见模式。第一种使用继承：

```java
public class MyClassAdapter extends ClassNode {
    public MyClassAdapter(ClassVisitor cv) {
        super(ASM4);
        this.cv = cv;
    }
    @Override public void visitEnd() {
        // 在此处放入你的变换代码
        accept(cv);
    }
}
```

当这个类适配器用于经典的变换链中时：

```java
ClassWriter cw = new ClassWriter(0);
ClassVisitor ca = new MyClassAdapter(cw);
ClassReader cr = new ClassReader(...);
cr.accept(ca, 0);
byte[] b = cw.toByteArray();
```

由 `cr` 生成的事件由 `ClassNode` 类型的 `ca` 消费，从而完成该对象各字段的初始化。最后，当 `visitEnd` 事件被消费时，`ca` 执行变换，并通过调用其 `accept` 方法生成对应于变换后类的新事件，这些事件由 `cw` 消费。假设 `ca` 改变了类的版本，相应的时序图如图 6.2 所示。

**图 6.2：MyClassAdapter 的时序图**

![图 6.2](images/figure-6.2.png)

与图 2.7 中 `ChangeVersionAdapter` 的时序图相比可以看出，`ca` 与 `cw` 之间的事件发生在 `cr` 与 `ca` 之间的事件之后，而不是像普通类适配器那样同时发生。事实上，所有基于树的变换都是如此，这也解释了为什么它们比基于事件的变换受到更少的约束。

第二种模式可以达到相同的结果，其时序图也类似，它使用委托而不是继承：

```java
public class MyClassAdapter extends ClassVisitor {
    ClassVisitor next;
    public MyClassAdapter(ClassVisitor cv) {
        super(ASM4, new ClassNode());
        next = cv;
    }
    @Override public void visitEnd() {
        ClassNode cn = (ClassNode) cv;
        // 在此处放入你的变换代码
        cn.accept(next);
    }
}
```

这种模式使用两个对象而不是一个，但其工作方式与第一种模式完全相同：收到的事件被用来构造一个 `ClassNode`，当收到最后一个事件时，该对象被变换，并转换回基于事件的表示。

这两种模式都允许你把基于树的类适配器与基于事件的适配器组合起来。它们也可以用来把多个基于树的适配器组合在一起，但如果你只需要组合基于树的适配器，这并不是最佳方案：在这种情况下，使用 `ClassTransformer` 之类的类可以避免两种表示之间不必要的转换。
