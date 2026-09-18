# StackMapTable说明 -- 栈映射帧说明

## 1. 先拆一条字节码：iload_0

```text
iload_0
  i    -> int 类型
  load -> 加载
  _0   -> 局部变量表的第 0 号槽
```

意思：

> 把局部变量表第 0 号槽里的 int 值，压到操作数栈顶。

这里的 `0` 不是数字常量 0，而是“局部变量表的槽位编号”。

类似地：

```text
istore_1
  i     -> int 类型
  store -> 存储
  _1    -> 局部变量表的第 1 号槽
```

意思：

> 把操作数栈顶的 int 值，存到局部变量表第 1 号槽。

```text
ifeq 9
  if   -> 如果
  eq   -> 等于 0
  9    -> 跳转到字节码偏移 9
```

意思：

> 如果操作数栈顶的 int 等于 0，就跳到偏移 9 继续执行。

```text
goto 11
  goto -> 无条件跳转
  11   -> 跳转到字节码偏移 11
```

意思：

> 直接跳到偏移 11 继续执行。

---

## 2. 局部变量表和操作数栈

JVM 执行方法时，会给方法一个栈帧。栈帧里有两块重要区域：

### 局部变量表

```text
局部变量表
  局部 -> 方法内部的
  变量 -> 参数和局部变量
  表   -> 一排编号的槽位
```

编号从 0 开始：

```text
0 号槽、1 号槽、2 号槽……
```

实例方法的 0 号槽是 `this`，静态方法的 0 号槽是第一个参数。

### 操作数栈

```text
操作数栈
  操作数 -> 参与计算的值
  栈     -> 后进先出的临时存放区
```

很多字节码指令都在做这种事：

```text
从局部变量表加载值 -> 压到操作数栈 -> 计算 -> 存回局部变量表
```

---

## 3. 一个完整例子

Java 代码：

```java
public class Demo {
    static int f(boolean b) {
        int x;
        if (b) {
            x = 1;
        } else {
            x = 2;
        }
        return x;
    }
}
```

局部变量表：

```text
0 号槽：b   （boolean，在局部变量表里按 int 处理）
1 号槽：x   （int）
```

编译后用 `javap -v -c Demo` 查看，字节码长这样：

```text
public class com.sample.chap2.classvisitor.Demo
  minor version: 0
  major version: 61
  flags: (0x0021) ACC_PUBLIC, ACC_SUPER
  this_class: #7                          // com/sample/chap2/classvisitor/Demo
  super_class: #2                         // java/lang/Object
  interfaces: 0, fields: 0, methods: 2, attributes: 1
Constant pool:
   #1 = Methodref          #2.#3          // java/lang/Object."<init>":()V
   #2 = Class              #4             // java/lang/Object
   #3 = NameAndType        #5:#6          // "<init>":()V
   #4 = Utf8               java/lang/Object
   #5 = Utf8               <init>
   #6 = Utf8               ()V
   #7 = Class              #8             // com/sample/chap2/classvisitor/Demo
   #8 = Utf8               com/sample/chap2/classvisitor/Demo
   #9 = Utf8               Code
  #10 = Utf8               LineNumberTable
  #11 = Utf8               LocalVariableTable
  #12 = Utf8               this
  #13 = Utf8               Lcom/sample/chap2/classvisitor/Demo;
  #14 = Utf8               f
  #15 = Utf8               (Z)I
  #16 = Utf8               x
  #17 = Utf8               I
  #18 = Utf8               b
  #19 = Utf8               Z
  #20 = Utf8               StackMapTable
  #21 = Utf8               MethodParameters
  #22 = Utf8               SourceFile
  #23 = Utf8               Demo.java
{
  public com.sample.chap2.classvisitor.Demo();
    descriptor: ()V
    flags: (0x0001) ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 3: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   Lcom/sample/chap2/classvisitor/Demo;

  static int f(boolean);
    descriptor: (Z)I
    flags: (0x0008) ACC_STATIC
    Code:
      stack=1, locals=2, args_size=1
         0: iload_0                 // 加载 0 号槽的 int 值（b）到操作数栈
         1: ifeq          9         // 如果栈顶等于 0（false），跳到偏移 9
         4: iconst_1                // 把常量 1 压入操作数栈
         5: istore_1                // 把栈顶 int 存到 1 号槽（x）
         6: goto          11        // 无条件跳到偏移 11
         9: iconst_2                // 把常量 2 压入操作数栈
        10: istore_1                // 把栈顶 int 存到 1 号槽（x）
        11: iload_1                 // 加载 1 号槽的 int 值（x）到操作数栈
        12: ireturn                 // 返回栈顶 int
      LineNumberTable:
        line 6: 0
        line 7: 4
        line 9: 9
        line 11: 11
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            6       3     1     x   I
            0      13     0     b   Z
           11       2     1     x   I
      StackMapTable: number_of_entries = 2
        frame_type = 9 /* same */
        frame_type = 252 /* append */
          offset_delta = 1
          locals = [ int ]
    MethodParameters:
      Name                           Flags
      b
}
```

这些指令前面的 `0:`、`1:`、`9:`、`11:` 是字节码偏移，不是行号。  
跳转指令里的 `9`、`11` 就是跳到这些偏移位置。

---

## 4. JVM 的难题：它怎么知道类型？

`iload_1` 只说“加载 1 号槽的 int 值”，但它怎么知道 1 号槽真的是 int？

如果 1 号槽是 `String`，却执行 `iload_1`，就会类型不安全。**JVM 必须在运行前验证字节码**。

早期验证器要从方法开头开始，沿着所有分支推断每个位置的类型，比较慢。  
后来 Java 6 引入、Java 7 默认使用一种更快的方式：

> 编译器**提前把关键位置的类型状态写进 Class 文件**，JVM 直接查表验证。

这个“类型状态备注”，就是栈映射帧。

---

## 5. 栈映射帧是什么？

拆词：

```text
栈映射帧
  栈   -> 操作数栈
  映射 -> 对应关系
  帧   -> 某一时刻的快照
```

合起来：

> 在字节码某个位置，操作数栈和局部变量表里分别是什么类型的快照。

- 它不是字节码指令。
- 你不会在 `0: iload_0` 这种指令流里直接看到它。
- 它在 Class 文件的 `StackMapTable` 里。

```text
StackMapTable
  StackMap -> 栈映射
  Table    -> 表格
```

就是一张表，每行对应字节码的某个偏移，记录那个位置的局部变量和操作数栈类型。

---

## 6. 看字节码中的 StackMapTable

只需要关注这些：

```text
stack=1, locals=2, args_size=1
   0: iload_0                 // 加载 0 号槽的 int 值（b）到操作数栈
   1: ifeq          9         // 如果栈顶等于 0（false），跳到偏移 9
   4: iconst_1                // 把常量 1 压入操作数栈
   5: istore_1                // 把栈顶 int 存到 1 号槽（x）
   6: goto          11        // 无条件跳到偏移 11
   9: iconst_2                // 把常量 2 压入操作数栈
  10: istore_1                // 把栈顶 int 存到 1 号槽（x）
  11: iload_1                 // 加载 1 号槽的 int 值（x）到操作数栈
  12: ireturn                 // 返回栈顶 int


StackMapTable: number_of_entries = 2
  frame_type = 9 /* same */
  frame_type = 252 /* append */
    offset_delta = 1
    locals = [ int ]
```

### 计算帧偏移

`StackMapTable` 不会直接存每个帧的绝对偏移，而是存增量。

规则：

```text
第一个帧的偏移 = 自己的 offset_delta
后续帧的偏移 = 上一帧偏移 + 自己的 offset_delta + 1
```

`+1` 是规范固定的。为什么后面要 `+1`？因为 offset_delta 表示“相对上一帧之后又过了多少偏移”，规范为了不产生歧义，固定加 1。

---

### 逐行解释 StackMapTable

[frame_type类型表](#frame_type类型表)

例如之前例子：

```text
frame_type = 9 /* same */
frame_type = 252 /* append */
  offset_delta = 1
  locals = [ int ]
```

#### frame_type = 9

```text
frame_type = 9 /* same */
```

`9` 在 `0~63` 范围内，表示 `same_frame`。对于 `same_frame`，offset_delta 没有单独存，它就直接等于 frame_type 的值。

```text
offset_delta = frame_type = 9
```

所以这个帧对应字节码偏移 `9`。  
它表示：局部变量表和上一个帧相同，操作数栈为空。

在这个例子里，偏移 `9` 是 else 分支入口，局部变量表还是 `[int]`，也就是只有参数 `b`。

#### frame_type = 252

```text
frame_type = 252 /* append */
  offset_delta = 1
  locals = [ int ]
```

计算实际偏移：

```text
上一个帧偏移 = 9
offset_delta = 1
本帧偏移 = 9 + 1 + 1 = 11
```

所以第二个帧对应偏移 `11`。  
它表示：局部变量表在原来 `[int]` 的基础上追加一个 `int`，变成 `[int, int]`，操作数栈为空。

也就是说，执行到偏移 `11` 时：

```text
0 号槽：int（参数 b）
1 号槽：int（局部变量 x）
操作数栈：空
```

所以后面的 `iload_1` 可以合法加载 1 号槽里的 `int`。

---

## 7. 为什么需要栈映射帧？

```text
类型检查
  类型 -> int、float、String 等
  检查 -> 确认指令用的类型对不对
```

没有栈映射帧，JVM 要从方法开头沿所有分支推断类型，很慢。  
有栈映射帧，编译器提前把关键位置的类型写下来，JVM 直接查表验证，就快了。

如果栈映射帧缺失或错误，常见错误是：

```text
java.lang.VerifyError: Expecting a stackmap frame at branch target ...
```

或者：

```text
Bad type on operand stack
```

---

## 8. 和运行时栈帧的区别

|          | 运行时栈帧                               | 栈映射帧                 |
| -------- | ---------------------------------------- | ------------------------ |
| 存在位置 | JVM 运行时栈中                           | Class 文件里             |
| 何时存在 | 方法调用时创建                           | 编译后静态存在           |
| 内容     | 局部变量、操作数栈、动态链接、返回地址等 | 某个字节码位置的类型快照 |
| 作用     | 支持方法执行                             | 支持字节码验证           |

所以“栈映射帧”不是“运行时栈帧”。  
它是 Class 文件里的验证元数据。

---

## 9. 实际开发中的影响

- `javac` 编译 Java 6+ 代码时会自动生成栈映射帧。
- 用 ASM、Javassist、Byte Buddy 等**修改字节码时，如果增删了分支、局部变量或跳转目标，必须重新计算栈映射帧**。
- ASM 中常用 `ClassWriter.COMPUTE_FRAMES` 自动计算，否则可能运行时报 `VerifyError`。

---

## 10. 总结

```text
iload_0       -> 把局部变量表第 0 号槽的 int 值压到操作数栈
istore_1      -> 把操作数栈顶的 int 值存到局部变量表第 1 号槽
栈映射帧      -> 字节码关键位置的类型备注
StackMapTable -> 存放这些备注的表格
frame_type=252 -> append_frame，表示追加 1 个局部变量
```

一句话：

> **字节码是指令列表。栈映射帧是附在指令列表旁边的类型检查备注。它不直接混在指令里，而是在 `StackMapTable` 中，告诉 JVM：执行到某条指令时，变量和临时值的类型分别是什么。**

---

## 附加

### frame_type类型表

StackMapTable 用不同的 frame_type 编号区间表示不同帧类型：

| frame_type 编号 | 类型名                                    | 含义                                                    | 后面跟的数据                                                                                  |
| --------------- | ----------------------------------------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| 0 ~ 63          | `same_frame`                              | 局部变量表和上一帧相同，操作数栈为空                    | 无，`offset_delta = frame_type`                                                               |
| 64 ~ 127        | `same_locals_1_stack_item_frame`          | 局部变量表和上一帧相同，操作数栈有 1 个元素             | 1 个栈元素类型                                                                                |
| 128 ~ 246       | 保留                                      | 未使用                                                  | 无                                                                                            |
| 247             | `same_locals_1_stack_item_frame_extended` | 同上，但偏移增量用 2 字节表示                           | 2 字节 `offset_delta`，1 个栈元素类型                                                         |
| 248             | `chop_frame`                              | 删除 1 个局部变量，操作数栈为空                         | 2 字节 `offset_delta`                                                                         |
| 249             | `chop_frame`                              | 删除 2 个局部变量，操作数栈为空                         | 2 字节 `offset_delta`                                                                         |
| 250             | `chop_frame`                              | 删除 3 个局部变量，操作数栈为空                         | 2 字节 `offset_delta`                                                                         |
| 251             | `same_frame_extended`                     | 局部变量表和上一帧相同，操作数栈为空，偏移增量用 2 字节 | 2 字节 `offset_delta`                                                                         |
| 252             | `append_frame`                            | 追加 1 个局部变量，操作数栈为空                         | 2 字节 `offset_delta`，1 个局部变量类型                                                       |
| 253             | `append_frame`                            | 追加 2 个局部变量，操作数栈为空                         | 2 字节 `offset_delta`，2 个局部变量类型                                                       |
| 254             | `append_frame`                            | 追加 3 个局部变量，操作数栈为空                         | 2 字节 `offset_delta`，3 个局部变量类型                                                       |
| 255             | `full_frame`                              | 完整写出局部变量表和操作数栈                            | 2 字节 `offset_delta`，2 字节 locals 数量，locals 类型列表，2 字节 stack 数量，stack 类型列表 |
