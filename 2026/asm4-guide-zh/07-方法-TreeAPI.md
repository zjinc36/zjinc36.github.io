# 7. 方法（Tree API）

本章说明如何使用 ASM 的 Tree API（树 API）生成和变换方法。本章首先单独介绍 Tree API，并给出若干说明性示例，然后介绍如何将其与 Core API（核心 API）组合使用。用于泛型和注解的 Tree API 将在下一章介绍。

## 7.1 接口与组件

### 7.1.1 展示

用于生成和变换方法的 ASM Tree API 基于 `MethodNode` 类（见图 7.1）。

```java
public class MethodNode ... {
    public int access;
    public String name;
    public String desc;
    public String signature;
    public List<String> exceptions;
    public List<AnnotationNode> visibleAnnotations;
    public List<AnnotationNode> invisibleAnnotations;
    public List<Attribute> attrs;
    public Object annotationDefault;
    public List<AnnotationNode>[] visibleParameterAnnotations;
    public List<AnnotationNode>[] invisibleParameterAnnotations;
    public InsnList instructions;
    public List<TryCatchBlockNode> tryCatchBlocks;
    public List<LocalVariableNode> localVariables;
    public int maxStack;
    public int maxLocals;
}
```

**图 7.1：`MethodNode` 类（仅显示字段）**

![图 7.1](images/figure-7.1.png)

该类的大部分字段与 `ClassNode` 中对应的字段类似。最重要的字段是最后几个，从 `instructions` 字段开始。该字段是一个指令列表，由一个 `InsnList` 对象管理，其公开 API 如下：

```java
public class InsnList { // 省略了公开的访问器
    int size();
    AbstractInsnNode getFirst();
    AbstractInsnNode getLast();
    AbstractInsnNode get(int index);
    boolean contains(AbstractInsnNode insn);
    int indexOf(AbstractInsnNode insn);
    void accept(MethodVisitor mv);
    ListIterator iterator();
    ListIterator iterator(int index);
    AbstractInsnNode[] toArray();
    void set(AbstractInsnNode location, AbstractInsnNode insn);
    void add(AbstractInsnNode insn);
    void add(InsnList insns);
    void insert(AbstractInsnNode insn);
    void insert(InsnList insns);
    void insert(AbstractInsnNode location, AbstractInsnNode insn);
    void insert(AbstractInsnNode location, InsnList insns);
    void insertBefore(AbstractInsnNode location, AbstractInsnNode insn);
    void insertBefore(AbstractInsnNode location, InsnList insns);
    void remove(AbstractInsnNode insn);
    void clear();
}
```

`InsnList` 是指令的双向链表，其链接存储在 `AbstractInsnNode` 对象自身中。这一点极其重要，因为它对指令对象和指令列表的使用方式有许多影响：

- 一个 `AbstractInsnNode` 对象在一个指令列表中不能出现多次。
- 一个 `AbstractInsnNode` 对象不能同时属于多个指令列表。
- 因此，把一个 `AbstractInsnNode` 添加到某个列表时，必须先把它从原先所属的列表中移除（如果有的话）。
- 另一个结果是，把一个列表的所有元素添加到另一个列表会清空第一个列表。

`AbstractInsnNode` 类是表示字节码指令的那些类的超类。其公开 API 如下：

```java
public abstract class AbstractInsnNode {
    public int getOpcode();
    public int getType();
    public AbstractInsnNode getPrevious();
    public AbstractInsnNode getNext();
    public void accept(MethodVisitor cv);
    public AbstractInsnNode clone(Map labels);
}
```

它的子类是与 `MethodVisitor` 接口的 `visitXxxInsn` 方法相对应的 `XxxInsnNode` 类，它们都以相同的方式构建。例如，`VarInsnNode` 类对应于 `visitVarInsn` 方法，其结构如下：

```java
public class VarInsnNode extends AbstractInsnNode {
    public int var;
    public VarInsnNode(int opcode, int var) {
        super(opcode);
        this.var = var;
    }
    ...
}
```

标签和帧以及行号虽然不是指令，但也由 `AbstractInsnNode` 类的子类表示，即 `LabelNode`、`FrameNode` 和 `LineNumberNode` 类。这使得它们可以像在 Core API 中那样被插入到列表中相应真实指令之前（在 Core API 中，标签和帧正好在其对应的指令之前被访问）。因此，借助 `AbstractInsnNode` 类提供的 `getNext` 方法，很容易找到跳转指令的目标：它就是目标标签之后的第一个真实指令 `AbstractInsnNode`。另一个结果是，与 Core API 一样，只要标签保持不变，删除一条指令并不会破坏跳转指令。

### 7.1.2 生成方法

用 Tree API 生成一个方法，就是创建一个 `MethodNode` 并初始化其字段。最有趣的部分是方法代码的生成。例如，3.1.5 节中的 `checkAndSetF` 方法可以按如下方式生成：

```java
MethodNode mn = new MethodNode(...);
InsnList il = mn.instructions;
il.add(new VarInsnNode(ILOAD, 1));
LabelNode label = new LabelNode();
il.add(new JumpInsnNode(IFLT, label));
il.add(new VarInsnNode(ALOAD, 0));
il.add(new VarInsnNode(ILOAD, 1));
il.add(new FieldInsnNode(PUTFIELD, "pkg/Bean", "f", "I"));
LabelNode end = new LabelNode();
il.add(new JumpInsnNode(GOTO, end));
il.add(label);
il.add(new FrameNode(F_SAME, 0, null, 0, null));
il.add(new TypeInsnNode(NEW, "java/lang/IllegalArgumentException"));
il.add(new InsnNode(DUP));
il.add(new MethodInsnNode(INVOKESPECIAL,
    "java/lang/IllegalArgumentException", "<init>", "()V"));
il.add(new InsnNode(ATHROW));
il.add(end);
il.add(new FrameNode(F_SAME, 0, null, 0, null));
il.add(new InsnNode(RETURN));
mn.maxStack = 2;
mn.maxLocals = 2;
```

与类的情况一样，使用 Tree API 生成方法比使用 Core API 更耗时、更耗内存。但它使得可以按任意顺序生成方法的内容。特别是指令可以按不同于顺序次序的次序生成，这在某些情况下可能很有用。

例如，考虑一个表达式编译器。通常，表达式 `e1 + e2` 的编译方式是：先为 `e1` 生成代码，再为 `e2` 生成代码，然后生成把两个值相加的代码。但如果 `e1` 和 `e2` 不是同一种基本类型，就必须在 `e1` 的代码之后插入一次强制转换，并在 `e2` 的代码之后再插入一次强制转换。然而，需要生成的确切强制转换取决于 `e1` 和 `e2` 的类型。

现在，如果表达式的类型由生成编译后代码的方法返回，那么在使用 Core API 时就会遇到问题：必须在 `e1` 之后插入的强制转换，只有在 `e2` 编译完成之后才能知道，但那时已经太晚了，因为我们无法在先前已访问的指令之间插入指令[^1]。使用 Tree API 则不存在这个问题。例如，一种可行的做法是使用如下 `compile` 方法：

```java
public Type compile(InsnList output) {
    InsnList il1 = new InsnList();
    InsnList il2 = new InsnList();
    Type t1 = e1.compile(il1);
    Type t2 = e2.compile(il2);
    Type t = ...; // 计算 t1 和 t2 的公共超类型
    output.addAll(il1); // 在常数时间内完成
    output.add(...); // 从 t1 到 t 的强制转换指令
    output.addAll(il2); // 在常数时间内完成
    output.add(...); // 从 t2 到 t 的强制转换指令
    output.add(new InsnNode(t.getOpcode(IADD)));
    return t;
}
```

### 7.1.3 变换方法

用 Tree API 变换一个方法，只是修改一个 `MethodNode` 对象的字段，特别是指令列表。虽然该列表可以按任意方式修改，但一种常见模式是在遍历它的同时修改它。事实上，与通用的 `ListIterator` 契约不同，`InsnList` 返回的 `ListIterator` 支持许多并发[^2]的列表修改。实际上，你可以使用 `InsnList` 的方法删除当前元素之前（含当前元素）的一个或多个元素，删除下一个元素之后（即不只是紧跟在当前元素之后，而是紧跟在其后继之后）的一个或多个元素，或者在当前元素之前或其后继之后插入一个或多个元素。这些修改会反映到迭代器中，即插入（相应地删除）到下一个元素之后的元素在迭代器中会被看到（相应地不会被看到）。

另一种常见模式是：当需要在一个列表中的指令 `i` 之后插入若干条指令时，把这些新指令添加到一个临时指令列表中，然后一次性把该临时列表插入主列表：

```java
InsnList il = new InsnList();
il.add(...);
...
il.add(...);
mn.instructions.insert(i, il);
```

逐条插入指令也是可以的，但更麻烦，因为每次插入之后都必须更新插入点。

### 7.1.4 无状态变换与有状态变换

我们举几个例子来具体看看如何用 Tree API 变换方法。为了看清 Core API 与 Tree API 之间的差异，重新实现 3.2.4 节的 `AddTimerAdapter` 示例和 3.2.5 节的 `RemoveGetFieldPutFieldAdapter` 是很有意思的。计时器示例可以实现如下：

```java
public class AddTimerTransformer extends ClassTransformer {
    public AddTimerTransformer(ClassTransformer ct) {
        super(ct);
    }
    @Override public void transform(ClassNode cn) {
        for (MethodNode mn : (List<MethodNode>) cn.methods) {
            if ("<init>".equals(mn.name) || "<clinit>".equals(mn.name)) {
                continue;
            }
            InsnList insns = mn.instructions;
            if (insns.size() == 0) {
                continue;
            }
            Iterator<AbstractInsnNode> j = insns.iterator();
            while (j.hasNext()) {
                AbstractInsnNode in = j.next();
                int op = in.getOpcode();
                if ((op >= IRETURN && op <= RETURN) || op == ATHROW) {
                    InsnList il = new InsnList();
                    il.add(new FieldInsnNode(GETSTATIC, cn.name, "timer", "J"));
                    il.add(new MethodInsnNode(INVOKESTATIC, "java/lang/System",
                        "currentTimeMillis", "()J"));
                    il.add(new InsnNode(LADD));
                    il.add(new FieldInsnNode(PUTSTATIC, cn.name, "timer", "J"));
                    insns.insert(in.getPrevious(), il);
                }
            }
            InsnList il = new InsnList();
            il.add(new FieldInsnNode(GETSTATIC, cn.name, "timer", "J"));
            il.add(new MethodInsnNode(INVOKESTATIC, "java/lang/System",
                "currentTimeMillis", "()J"));
            il.add(new InsnNode(LSUB));
            il.add(new FieldInsnNode(PUTSTATIC, cn.name, "timer", "J"));
            insns.insert(il);
            mn.maxStack += 4;
        }
        int acc = ACC_PUBLIC + ACC_STATIC;
        cn.fields.add(new FieldNode(acc, "timer", "J", null, null));
        super.transform(cn);
    }
}
```

你可以在这里看到上一节讨论的、用于在指令列表中插入若干条指令的模式，即使用一个临时指令列表。这个例子还表明，在遍历指令列表的同时，可以在当前指令之前插入指令。注意，实现这个适配器所需的代码量在 Core API 和 Tree API 中大致相同。

删除字段自赋值的方法适配器（见 3.2.5 节）可以实现如下（假设 `MethodTransformer` 与上一章的 `ClassTransformer` 类类似）：

```java
public class RemoveGetFieldPutFieldTransformer extends
    MethodTransformer {
    public RemoveGetFieldPutFieldTransformer(MethodTransformer mt) {
        super(mt);
    }
    @Override public void transform(MethodNode mn) {
        InsnList insns = mn.instructions;
        Iterator<AbstractInsnNode> i = insns.iterator();
        while (i.hasNext()) {
            AbstractInsnNode i1 = i.next();
            if (isALOAD0(i1)) {
                AbstractInsnNode i2 = getNext(i1);
                if (i2 != null && isALOAD0(i2)) {
                    AbstractInsnNode i3 = getNext(i2);
                    if (i3 != null && i3.getOpcode() == GETFIELD) {
                        AbstractInsnNode i4 = getNext(i3);
                        if (i4 != null && i4.getOpcode() == PUTFIELD) {
                            if (sameField(i3, i4)) {
                                while (i.next() != i4) {
                                }
                                insns.remove(i1);
                                insns.remove(i2);
                                insns.remove(i3);
                                insns.remove(i4);
                            }
                        }
                    }
                }
            }
        }
        super.transform(mn);
    }
    private static AbstractInsnNode getNext(AbstractInsnNode insn) {
        do {
            insn = insn.getNext();
            if (insn != null && !(insn instanceof LineNumberNode)) {
                break;
            }
        } while (insn != null);
        return insn;
    }
    private static boolean isALOAD0(AbstractInsnNode i) {
        return i.getOpcode() == ALOAD && ((VarInsnNode) i).var == 0;
    }
    private static boolean sameField(AbstractInsnNode i,
        AbstractInsnNode j) {
        return ((FieldInsnNode) i).name.equals(((FieldInsnNode) j).name);
    }
}
```

这里同样可以看到，在遍历指令列表的同时可以删除其中的指令。但请注意 `while (i.next() != i4)` 循环：这是必要的，以便把迭代器定位到必须删除的那些指令之后（因为无法删除紧跟在当前元素之后的指令）。基于访问者和基于树这两种实现都能检测出待检测序列中间的标签和帧，并在这种情况下不删除它们。但要忽略序列内部的行号，基于树 API 的实现（见 `getNext` 方法）比 Core API 需要更多代码。不过，这两种实现的主要区别在于，使用 Tree API 不需要状态机。特别地，连续三条或更多条 `ALOAD 0` 指令这一容易被忽略的特殊情况不再成为问题。

使用上述实现时，某条给定指令可能会被检查多次，因为在 `while` 循环的每一步中，将在后续迭代中被检查的 `i2`、`i3` 和 `i4` 也可能在本次迭代中被检查。事实上可以使用一种更高效的实现，其中每条指令至多被检查一次：

```java
public class RemoveGetFieldPutFieldTransformer2 extends
    MethodTransformer {
    ...
    @Override public void transform(MethodNode mn) {
        InsnList insns = mn.instructions;
        Iterator i = insns.iterator();
        while (i.hasNext()) {
            AbstractInsnNode i1 = (AbstractInsnNode) i.next();
            if (isALOAD0(i1)) {
                AbstractInsnNode i2 = getNext(i);
                if (i2 != null && isALOAD0(i2)) {
                    AbstractInsnNode i3 = getNext(i);
                    while (i3 != null && isALOAD0(i3)) {
                        i1 = i2;
                        i2 = i3;
                        i3 = getNext(i);
                    }
                    if (i3 != null && i3.getOpcode() == GETFIELD) {
                        AbstractInsnNode i4 = getNext(i);
                        if (i4 != null && i4.getOpcode() == PUTFIELD) {
                            if (sameField(i3, i4)) {
                                insns.remove(i1);
                                insns.remove(i2);
                                insns.remove(i3);
                                insns.remove(i4);
                            }
                        }
                    }
                }
            }
        }
        super.transform(mn);
    }

    private static AbstractInsnNode getNext(Iterator i) {
        while (i.hasNext()) {
            AbstractInsnNode in = (AbstractInsnNode) i.next();
            if (!(in instanceof LineNumberNode)) {
                return in;
            }
        }
        return null;
    }
    ...
}
```

与前一实现的不同之处在于 `getNext` 方法，它现在作用于列表迭代器。当序列被识别出来时，迭代器正好位于该序列之后，因此不再需要 `while (i.next() != i4)` 循环。但这里又出现了三条或更多连续 `ALOAD 0` 指令这种特殊情况（参见 `while (i3 != null)` 循环）。

### 7.1.5 全局变换

到目前为止我们看到的所有方法变换都是局部的，即使是有状态的变换也是如此，其含义是：对指令 i 的变换只依赖于与 i 距离固定的那些指令。然而还存在全局变换，在这种变换中，对指令 i 的变换可能依赖于与 i 距离任意的指令。对于这些变换，Tree API（树 API）确实很有帮助，也就是说，用 Core API（核心 API）来实现它们会非常复杂。

一个例子是这样一个变换：它把跳到 `GOTO` 标签指令的跳转替换为跳到 `label l` 的跳转，并把指向 `RETURN` 指令的 `GOTO` 替换为这条 `RETURN` 指令。确实，跳转指令的目标可以位于这条指令之前或之后的任意距离处。这样的变换可以实现如下：

```java
public class OptimizeJumpTransformer extends MethodTransformer {
    public OptimizeJumpTransformer(MethodTransformer mt) {
        super(mt);
    }

    @Override public void transform(MethodNode mn) {
        InsnList insns = mn.instructions;
        Iterator<AbstractInsnNode> i = insns.iterator();
        while (i.hasNext()) {
            AbstractInsnNode in = i.next();
            if (in instanceof JumpInsnNode) {
                LabelNode label = ((JumpInsnNode) in).label;
                AbstractInsnNode target;
                // 当 target == goto l 时，用 l 替换 label
                while (true) {
                    target = label;
                    while (target != null && target.getOpcode() < 0) {
                        target = target.getNext();
                    }
                    if (target != null && target.getOpcode() == GOTO) {
                        label = ((JumpInsnNode) target).label;
                    } else {
                        break;
                    }
                }
                // 更新目标
                ((JumpInsnNode) in).label = label;
                // 如果可能，用目标指令替换跳转
                if (in.getOpcode() == GOTO && target != null) {
                    int op = target.getOpcode();
                    if ((op >= IRETURN && op <= RETURN) || op == ATHROW) {
                        // 用 'target' 的副本替换 'in'
                        insns.set(in, target.clone(null));
                    }
                }
            }
        }
        super.transform(mn);
    }
}
```

这段代码的工作方式如下：当找到一条跳转指令 `in` 时，把它的目标存放在 `label` 中。然后用最内层的 `while` 循环查找紧跟在 `label` 之后的那条指令（不表示真实指令的 `AbstractInsnNode` 对象，例如 `FrameNode` 或 `LabelNode`，其“操作码”为负数）。只要这条指令是 `GOTO`，就用这条指令的目标替换 `label`，并重复上述步骤。最后，把 `in` 的目标标签替换为更新后的 `label` 值；并且如果 `in` 本身是一条 `GOTO`，而它更新后的目标是一条 `RETURN` 指令，就用这条返回指令的副本替换 `in`（回想一下，一个指令对象在指令列表中不能出现多次）。

这一变换对 3.1.5 节中定义的 `checkAndSetF` 方法的效果如下所示：

```text
// 变换前                     // 变换后
  ILOAD 1                     ILOAD 1
  IFLT label                  IFLT label
  ALOAD 0                     ALOAD 0
  ILOAD 1                     ILOAD 1
  PUTFIELD ...                PUTFIELD ...
  GOTO end                    RETURN
label:                      label:
F_SAME                      F_SAME
  NEW ...                     NEW ...
  DUP                         DUP
  INVOKESPECIAL ...           INVOKESPECIAL ...
  ATHROW                      ATHROW
end:                        end:
F_SAME                      F_SAME
  RETURN                      RETURN
```

注意，尽管这一变换改变了跳转指令（更正式地说，改变了控制流图），但它不需要更新方法的帧。确实，执行帧的状态在每条指令处都保持不变，而且由于没有引入新的跳转目标，也就没有新的帧必须被访问。不过，有可能某个帧不再需要了。例如在上面的例子中，变换之后 `end` 标签不再被使用，其后的 `F_SAME` 帧以及 `RETURN` 指令也不再被使用。所幸的是，访问比严格需要的更多的帧是完全合法的，在方法中包含未被使用的代码——称为死代码或不可达代码——也完全合法。因此，上面的方法适配器是正确的，尽管它可以改进以删除死代码和帧。

## 7.2 组件组合

到目前为止，我们只看到了如何创建和变换 `MethodNode` 对象，但还没有看到它与类的字节数组表示之间的联系。与类的情况一样，这种联系是通过组合 Core API（核心 API）和 Tree API（树 API）组件来实现的，本节将对此进行说明。

### 7.2.1 展示

除了图 7.1 中所示的字段之外，`MethodNode` 类还继承自 `MethodVisitor` 类，并且提供了两个 `accept` 方法，它们分别以 `MethodVisitor` 或 `ClassVisitor` 作为参数。`accept` 方法根据 `MethodNode` 的字段值生成事件，而 `MethodVisitor` 的方法则执行相反的操作，即根据收到的事件设置 `MethodNode` 的字段。

### 7.2.2 模式

与类的情况一样，可以把基于树的方法变换器当作 Core API 的方法适配器来使用。可以用于类的两种模式对方法同样有效，而且工作方式完全相同。基于继承的模式如下：

```java
public class MyMethodAdapter extends MethodNode {
    public MyMethodAdapter(int access, String name, String desc,
        String signature, String[] exceptions, MethodVisitor mv) {
        super(ASM4, access, name, desc, signature, exceptions);
        this.mv = mv;
    }

    @Override public void visitEnd() {
        // 在此处放入你的变换代码
        accept(mv);
    }
}
```

而基于委托的模式是：

```java
public class MyMethodAdapter extends MethodVisitor {
    MethodVisitor next;

    public MyMethodAdapter(int access, String name, String desc,
        String signature, String[] exceptions, MethodVisitor mv) {
        super(ASM4,
            new MethodNode(access, name, desc, signature, exceptions));
        next = mv;
    }

    @Override public void visitEnd() {
        MethodNode mn = (MethodNode) mv;
        // 在此处放入你的变换代码
        mn.accept(next);
    }
}
```

第一种模式的一个变体是：直接在 `ClassAdapter` 的 `visitMethod` 中使用匿名内部类：

```java
public MethodVisitor visitMethod(int access, String name,
    String desc, String signature, String[] exceptions) {
    return new MethodNode(ASM4, access, name, desc, signature, exceptions) {
        @Override public void visitEnd() {
            // 在此处放入你的变换代码
            accept(cv);
        }
    };
}
```

这些模式表明，可以只对方法使用 Tree API（树 API），而对类使用 Core API（核心 API）。实践中经常使用这一策略。

[^1]: 解决办法是分两趟编译表达式：一趟计算表达式类型以及必须插入的强制转换，另一趟生成编译后的代码。

[^2]: 即与 `Iterator.next` 的调用交错进行的修改。当然，不支持多线程的并发修改。
