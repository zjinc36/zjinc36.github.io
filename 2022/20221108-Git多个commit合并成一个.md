# Git多个commit合并成一个

----

## 查看当前的提交信息

执行命令：git log，可以查看当前的一些提交信息，这些提交按照时间先后顺序为：msg A，msg B，msg C，msg D。

![](../images/2022/11/20221108161723.png)

## 合并多个commit

执行命令：git rebase -i commit_id，`这里的commit_id是待合并的多个commit之前的那个commit ID`，这里也就是msg A的commit ID。

在我这里也就是执行命令：git rebase -i d1089921b2714211d1b1652cf0864e2c3f7101a4，执行完命令后就进入到vi的编辑模式：

![](../images/2022/11/20221108161759.png)

![](../images/2022/11/20221108161808.png)

上图中，pick表示使用当前的commit，squash表示这个commit会被合并到前一个commit。

我们这里需要将msg C，msg D合并到msg B中，因为msg B是最靠近msg A的，因此这里选择将msg C，msg D合并到msg B中。

在键盘上敲i键进入insert模式，然后将msg C，msg D前面的pick修改成squash：

![](../images/2022/11/20221108161912.png)

修改完成后，按esc键，冒号，输入wq进行保存。之后会继续跳转到commit message 的编辑界面：

![](../images/2022/11/20221108161925.png)

将上图中画线的内容删掉或者注释，然后写一个新的commit信息作为这3个commit的log信息，我这里的新的信息为：msg B, msg C, msg D，如下图所示：

![](../images/2022/11/20221108161946.png)

然后保存退出，就会跳转到最初的命令界面：

![](../images/2022/11/20221108161959.png)

Successfully表示操作成功。

## 查看新的commit信息

执行命令：git log，查看当前的commit信息：

![](../images/2022/11/20221108162028.png)

从上图中，可以看到，我这里已经将msg B，msg C，msg D这3个commit合并成1个新的commit。

## 参考

+	[git 多个commit合并成一个commit](https://blog.csdn.net/jackailson/article/details/104571235)

