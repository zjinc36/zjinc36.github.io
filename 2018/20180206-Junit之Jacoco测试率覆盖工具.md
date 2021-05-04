#   Junit之Jacoco测试率覆盖工具
+ date: 2018-02-06 20:59:47
+ description: Junit之Jacoco测试率覆盖工具
+ categories:
  - Java
+ tags:
  - Junit
- Java
---
#	介绍JaCoCo
Java Code Coverage是一种分析单元测试覆盖率的工具，使用它运行单元测试后，可以给出代码中哪些部分被单元测试测到，哪些部分没有没测到，并且给出整个项目的单元测试覆盖情况百分比，看上去一目了然。

##	JaCoCo会生成以下指标的度量：
+	Instructions (C0 Coverage)主要是计算字节码文件的覆盖率。

+	Branches (C1 Coverage)JaCoCo也计算分支覆盖所有if和 switch语句。主要是计算分支的。
    -   没有覆盖：在该行没有分支机构已执行（红钻）
    -   部分覆盖：只有在该行分支机构的一部分已经被执行（黄钻）
    -   全覆盖：在该行各分支机构已执行（绿钻）

+	Cyclomatic Complexity
    -   圈复杂度(Cyclomatic Complexity)是一种代码复杂度的衡量标准。它可以用来衡量一个模块判定结构的复杂程度，数量上表现为独立现行路径条数，也可理解为覆盖所有的可能情况最少使用的测试用例数。圈复杂度大说明程序代码的判断逻辑复杂，可能质量低且难于测试和维护。程序的可能错误和高的圈复杂度有着很大关系。请注意，JaCoCo不考虑异常处理的分支机构try-catch块也不会增加复杂性。总体和分支正相关。实际上，过去几年的各种研究已经确定：一个方法的圈复杂度（或 CC）大于 10 的方法存在很大的出错风险。

+   Lines主要计算基于覆盖的实际源代码行类和源文件行覆盖。通常会标识三种状态。
    -	没有覆盖：在该行任何指令执行（红色背景）
    -	部分覆盖：只有在该行的指示的一部分已经被执行（黄色背景）
    -	全覆盖：在该行的所有指令已执行（绿色背景）

+   Methods每个非抽象方法包含至少一个指令。构造函数和静态初始化都算作方法。

#	单元测试

##	Eclipse插件EclEmma
### EclEmma的安装
1.	启动eclipse,点击Help菜单,Install New Software,在弹出的对话框中,点击Add
2.	输入Name,例如EclEmma.输入Location:update.eclemma.org/
3.	在Work With处选择刚刚输入的Location地址
4.	安装后重新启动eclipse,如果安装成功,工具栏上会出现一个新的按钮

### EclEmma的使用
1.  编写单元测试用例。现在支持以下测试：
```
+	Local Java application
+	Eclipse/RCP application
+	Equinox OSGi framework
+	JUnit test
+	TestNG test
+	JUnit plug-in test
+	JUnit RAP test
+	SWTBot test
+	Scala application
```
2.  以Junit为例,在测试用例文件上右键,选择`Coverage As` -> `Junit Test`
3.  会在测试的文件中显示出运行结果
```
+   绿色:完整执行
+   红色:没执行
+   黄色:部分执行
```
4.  通过点击调出Coverage窗口,它是用来统计程序的覆盖测试率
5.  点击红色矩形框的按钮能将多次测试的覆盖数据综合起来进行查看
6.  在Coverage视图主区域中点击右键,出现的快捷菜单中选择`Export Report...`
7.  出现Export界面,选项如下:
```
+   Available session:要导出的session
+   Format:选择报告的类型(HTML/XML/Text/EMMA session)
+   Destination:导出的session存放的位置
```

##  IDEA插件
无

#   运行时测试
JaCoCo支持程序运行中监控执行情况.下面介绍直接运行和tomcat服务器两种监控方式.

##  准备
在jacoco官网下载jacoco包,下载链接[www.jacoco.org/jacoco/](www.jacoco.org/jacoco/)
下载的包中包括三个jar,此处使用`jacocoagent.jar`和`jacococli.jar`

##  直接运行
1.  假如直接运行的是test.jar,运行以下命令:
`java -javaagent:jacoco\jacocoagent.jar=includes=*-jar test.jar`
    -   其中jacoco\jacocoagent.jar处指的是准备中的jar包,后面为参数
    -   相关参数参考[https://www.jacoco.org/jacoco/trunk/doc/agent.html](https://www.jacoco.org/jacoco/trunk/doc/agent.html)
2.  待程序运行结束后,会在test.jar统计目录生成jacoco.exec文件,此文件为jacoco获取的运行情况文件.

3.  获取需要分析的class文件,假设test.jar中的源代码生成的文件位于com文件夹中,将此文件夹放入和jacoco.exec同一文件夹下.

4.  执行命令即可生成报告
`java -jar jacoco\jacococli.jar report jacoco.exec --classfiles com --html report`
    -   此处`jacoco\jacococli.jar`为准备中的jar包
    -   `report`表明生成报告
    -   `jacoco.eexec`为运行监控文件
    -   `--classfiles`为生成报告正对的class文件
    -   `--html`为报告格式
    -   后一个`report`为报告文件夹
    -   详细参数请参考[https://www.jacoco.org/jacoco/trunk/doc/cli.html](https://www.jacoco.org/jacoco/trunk/doc/cli.html)

##  tomcat运行
tomcat运行与直接运行的方式基本相同,唯一不同的是指明`jacocoagent.jar`的方式
+   windows下,在`$TOMCAT_HOME/bin/catalina.bat`的前面
+   Linux下,在`$TOMCAT_HOME/bin/catalina.sh`的前面
增加如下设置
`set "JAVA_OPTS=-javaagent:=jacoco\jacocoagent.jar=includes=*"`
如果在参数中未指明exec文件的生成路径,那么会在`$TOMCAT_HOME/bin`文件夹下生成,其余操作与上述相同

