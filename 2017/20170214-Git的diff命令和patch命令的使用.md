# Git的diff命令和patch命令的使用

---

# diff命令的使用方法

## diff命令的作用

1.	diff命令是linux上非常重要的工具，用于比较文件的内容，特别是比较两个版本不同的文件以找到改动的地方。
2.	diff在命令行中打印每一个行的改动。
3.	最新版本的diff还支持二进制文件。
4.	**diff程序的输出被称为补丁 (patch)，因为Linux系统中还有一个patch程序，可以根据diff的输出将a.c的文件内容更新为b.c。**
5.	diff是svn、cvs、git等版本控制工具不可或缺的一部分。

## diff命令的使用

一般使用方法
diff命令的格式一般为：

```
diff [参数][文件或者目录1][文件或者目录2]
```

## 经常使用举例

### 不使用参数直接比较

1.	例如，有文件test1和test2
2.	进行比较

```
diff test1 test2
```

3.	输出(注意代码中的注释)

```
2,3c2                       # "c"表示冲突(change),即第一个文件的第2到第3行和第二个文件的第2行开始有冲突
< asfdasfdasdfasdf          # "<"表示删除的行,即删去了两行
< creverververver
---
> qwefqwefqwef              # ">"表示添加的行,即添加了这行
5,9c4                       # 第一个文件第五行到第九行和第二个文件第四行有冲突
< aaaaaaaaaaaa              # 删去了了五行
< aaaa
< a
< a
< a
---
> qsdqwefqwefqwef           # 添加了一行
11d5                        # 第一个文件第11行与第二个文件第五行相比有删除
< bbbbbbbbb                 # 删除了这一行
```

4.	提示说明

注释中已经写到,`c`表示冲突,以下是diff的normal显示格式的提示总结

+	`a` - add - 添加
+	`c` - change - 改变
+	`d` - delete - 删除
+	`<` - 表示删除的行
+	`>` - 表示添加的行

### 增加参数比较两文件

参数如下

+	-a或--text 　diff预设只会逐行比较文本文件。
+	-b或--ignore-space-change 　不检查空格字符的不同。
+	-B或--ignore-blank-lines 　不检查空白行。
+	-c 　显示全部内文，并标出不同之处。

使用过程

1.	使用

```
diff -c test1 test2
```

2.	将会得到

```
*** test1 2016-04-21 14:46:55.000000000 +0800
--- test2 2016-04-21 14:44:55.000000000 +0800
***************
*** 1,11 ****
  utils
! asfdasfdasdfasdf
! creverververver
  util
! aaaaaaaaaaaa
! aaaa
! a
! a
! a
  qwerqwerqwe
- bbbbbbbbb
--- 1,5 ----
  utils
! qwefqwefqwef
  util
! qsdqwefqwefqwef
  qwerqwerqwe
```

3.	说明

+	“＋” 比较的文件的后者比前着多一行
+	“－” 比较的文件的后者比前着少一行
+	“！” 比较的文件两者有差别的行

### 以并列的方式显示文件的异同之处。

1.	使用

```
diff test1 test2 -y
```

2.	输出

```
utils                                       utils
asfdasfdasdfasdf                          | qwefqwefqwef
creverververver                           <
util                                        util
aaaaaaaaaaaa                              | qsdqwefqwefqwef
aaaa                                      <
a                                         <
a                                         <
a                                         <
qwerqwerqwe                                 qwerqwerqwe
bbbbbbbbb                                 <
```

3.	说明

+	`|`:表示前后2个文件内容有不同
+	`<`:表示后面文件比前面文件少了1行内容
+	`>`:表示后面文件比前面文件多了1行内容

### 以合并的方式显示两个文件的不同(可以用于使用patch命令进行打补丁包)

1.	**这种输出方式输出的内容可以用于使用patch命令进行打补丁包**
2.	例如，有文件test1和test2
3.	进行比较

```
diff -ruN test1 test2
```

4.	输出

```
--- test1   2016-04-21 14:46:55.000000000 +0800 # 第一个文件的信息
+++ test2   2016-04-21 14:44:55.000000000 +0800 # 第二个文件的信息
@@ -1,11 +1,5 @@                                # 第一个文件1到11行和第二个文件1到5行
 utils
-asfdasfdasdfasdf                               # 前面带减号的是删除的行
-creverververver
+qwefqwefqwef                                   # 带加号的是增加的行
 util
-aaaaaaaaaaaa
-aaaa
-a
-a
-a
+qsdqwefqwefqwef
 qwerqwerqwe
-bbbbbbbbb
```

5.	提示说明

+	“＋” 比较的文件的后者比前着多一行
+	“－” 比较的文件的后者比前着少一行
+	“！” 比较的文件两者有差别的行

### 比较两个文件夹的不同

1.	例如有两个文件夹testa和test，将test1和test2放进去
2.	进行比较

```
diff testa testb
```

3.	得到

```
diff testa/test1 testb/test1    # 对比两个文件夹下面文件名相同的文件
2,3c2                           # 以下是正常的文件对比格式
< asfdasfdasdfasdf
< creverververver
---
> qwefqwefqwef
5,9c4
< aaaaaaaaaaaa
< aaaa
< a
< a
< a
---
> qsdqwefqwefqwef
11d5
< bbbbbbbbb
Only in testa: test2            # testa里面有而testb里面没有的test2
Only in testb: test3            # testa里面没有而testb有的test3
```

## diff的参数说明

+	-C或--context 　与执行"-c-"指令相同。
+	-d或--minimal 　使用不同的演算法，以较小的单位来做比较。
+	-D或ifdef 　此参数的输出格式可用于前置处理器巨集。
+	-e或--ed 　此参数的输出格式可用于ed的script文件。
+	-f或-forward-ed 　输出的格式类似ed的script文件，但按照原来文件的顺序来显示不同处。
+	-H或--speed-large-files 　比较大文件时，可加快速度。
+	-l或--ignore-matching-lines 　若两个文件在某几行有所不同，而这几行同时都包含了选项中指定的字符或字符串，则不显示这两个文件的差异。
+	-i或--ignore-case 　不检查大小写的不同。
+	-l或--paginate 　将结果交由pr程序来分页。
+	-n或--rcs 　将比较结果以RCS的格式来显示。
+	-N或--new-file 　在比较目录时，若文件A仅出现在某个目录中，预设会显示：Only in目录：文件A若使用-N参数，则diff会将文件A与一个空白的文件比较。
+	-p 　若比较的文件为C语言的程序码文件时，显示差异所在的函数名称。
+	-P或--unidirectional-new-file 　与-N类似，但只有当第二个目录包含了一个第一个目录所没有的文件时，才会将这个文件与空白的文件做比较。
+	-q或--brief 　仅显示有无差异，不显示详细的信息。
+	-r或--recursive 　比较子目录中的文件。
+	-s或--report-identical-files 　若没有发现任何差异，仍然显示信息。
+	-S或--starting-file 　在比较目录时，从指定的文件开始比较。
+	-t或--expand-tabs 　在输出时，将tab字符展开。
+	-T或--initial-tab 　在每行前面加上tab字符以便对齐。
+	-u,-U或--unified= 　以合并的方式来显示文件内容的不同。即统一格式的输出。在合并中也使用的是这种模式。
+	v或--version 　显示版本信息。
+	-w或--ignore-all-space 　忽略全部的空格字符。
+	-W或--width 　在使用-y参数时，指定栏宽。
+	-x或--exclude 　不比较选项中所指定的文件或目录。
+	-X或--exclude-from 　您可以将文件或目录类型存成文本文件，然后在=中指定此文本文件。
+	-y或--side-by-side 　以并列的方式显示文件的异同之处。
+	--help 　显示帮助。
+	--left-column 　在使用-y参数时，若两个文件某一行内容相同，则仅在左侧的栏位显示该行内容。
+	--suppress-common-lines 　在使用-y参数时，仅显示不同之处。

# patch命令的使用方法

## patch命令的作用

打补丁

## patch命令的格式

```
patch [option] [origfile] [patchfile]
```

## patch命令的使用

我们可以先用diff命令生成patch文件。然后使用patch命令将第二个文件内容修改成第一个文件的内容。例如上述的test1和test2

1.	生成patch文件

```
diff -ruN test1 test2 > patch.log   # 生成patch文件
```

2.	利用patch文件和patch命令打补丁

```
patch test2 patch.log               # 利用patch文件和patch命令打补丁
```

之后test2的内容就会和test1内容一致了。

## patch说明

+	patch 命令（默认）使用从标准输入读入的源文件 `<` PATCHFILE ，但是使用 -i PATCHFILE 设置。
+	源文件包含由 diff 命令产生的差别列表（或者 diff 列表）。差异列表是比较两个文件和构建关于如何纠正差别的指示信息的结果。
+	差异列表有三种格式：正常、上下文或者是 ed 编辑器风格。patch 命令确定差异列表格式，除非被 -c、-e 或 -n 标志否决。
+	默认，ORIGFILE 被PATCHFILE 替换。若ORIGFILE（原始文件）不存在时，PATCHFILE（补丁文件）根据差别列表，创建 ORIGFILE 文件。
+	指定 -b 标志时，ORIGFILE（原始文件）会备份在自身的文件中，只是在文件名后附加了后缀 .orig。使用 -o 标志也可以指定输出的目的地。

## patch命令的参数

1.	输入选项

|输入选项|								|															   |
|----|----|----|
|-p 	|NUM	--strip=NUM				|去除相对路径层次的数目                                        |
|-F 	|LINES	--fuzz LINES			|设置监别列数                                                  |
|-l		|--ignore-whitespace			|忽略修补数据与输入数据的跳格，空格字符                        |
|-c		|--context						|把修补数据解译成关联性的差异                                  |
|-e		|--ed							|把修补数据解译成ed指令可用的叙述文件                          |
|-n		|--normal						|把修补数据解译成一般性的差异                                  |
|-u		|--unified						|把修补数据解译成一致化的差异                                  |
|-N		|--forward						|忽略修补的数据较原始文件的版本更旧，或该版本的修补数据已使用过|
|-R		|--reverse						|假设修补数据是由新旧文件交换位置而产生                        |
|-i 	|PATCHFILE	--input=PATCHFILE	|读取指定的修补文件                                            |

2.	输出选项

|输出选项				|						|																			|
|----|----|----|
|-o FILE				|--output=FILE			|设置输出文件的名称，修补过的文件会以该名称存放                             |
|-r FILE				|--reject-file=FILE		|Output rejects to FILE                                                     |
|-D NAME				|--ifdef=NAME			|用指定的符号把改变的地方标示出来                                           |
|-m						|--merge					|Merge using conflict markers instead of creating reject files          |
|-E						|--remove-empty-files	|若修补过后输出的文件其内容是一片空白，则移除该文件                         |
|-Z						|--set-utc				|把修补过的文件更改，存取时间设为UTC                                        |
|-T						|--set-time				|此参数的效果和指定"-Z"参数类似，但以本地时间为主                           |
|						|--quoting-style=WORD	|使用WORD引述类型显示项目名称,可设定值有literal,shell,shell-always,c,escape |

3.	备份和版本控制选项

|备份和版本控制选项|					|																																								 |
|----|----|----|
|-b			|--backup					|备份每一个原始文件                                                                                                                                              |
|			|--backup-if-mismatch		|在修补数据不完全吻合，且没有刻意指定要备份文件时，才备份文件                                                                                                    |
|			|--no-backup-if-mismatch	|在修补数据不完全吻合，且没有刻意指定要备份文件时，不要备份文件                                                                                                  |
|-V STYLE	|--version-control=STYLE	|用"-b"参数备份目标文件后，备份文件的字尾会被加上一个备份字符串，这个字符串不仅可用"-z"参数变更，当使用"-V"参数指定不同备份方式时，也会产生不同字尾的备份字符串  |
|-B PREFIX	|--prefix=PREFIX			|设置文件备份时，附加在文件名称前面的字首字符串，该字符串可以是路径名称                                                                                          |
|-Y PREFIX	|--basename-prefix=PREFIX	|设置文件备份时，附加在文件基本名称开头的字首字符串                                                                                                              |
|-z SUFFIX	|--suffix=SUFFIX			|此参数的效果和指定"-B"参数类似，差别在于修补作业使用的路径与文件名若为src/linux/fs/super.c，加上"backup/"字符串后，文件super.c会备份于/src/linux/fs/backup目录里|

4.	其他选项

|其他选项|					|																																								 |
|----|----|----|
|-t				|--batch						|自动略过错误，不询问任何问题                                               |
|-f				|--force						|此参数的效果和指定"-t"参数类似，但会假设修补数据的版本为新版本             |
|-s				|--quiet或--silent				|不显示指令执行过程，除非发生错误                                           |
|				|--verbose						|显示详细的过程信息                                                         |
|				|--dry-run						|实际上不改变任何文件；演示讲会发生什么                                     |
|				|--posix						|符合POSIX标准                                                              |
|-d DIR			|--directory=DIR				|先改变工作目录到指定的目录                                                 |
|				|--reject-format=FORMAT			|Create 'context' or 'unified' rejects                                      |
|				|--binary						|以二进制方式读写数据                                                       |
|				|--read-only=BEHAVIOR			|如何处理只读输入文件：“忽视”，他们是只读的，“警告”（默认），或“失败” |
