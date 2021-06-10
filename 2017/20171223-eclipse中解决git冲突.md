#   eclipse中解决git冲突
+ date: 2017-12-23 22:13:42
+ description: eclipse中git解决冲突
+ categories:
  - Java
+ tags:
  - Eclipse
---
#   0、来源
[eclipse 中git解决冲突](https://blog.csdn.net/rosten/article/details/17068285)
#   1、工程->Team->同步：

![](../images/2019/12/20191223001.png)

#   2、从远程pull至本地，就会出现如下内容：

![](../images/2019/12/20191223002.png)

#   3、使用Merge Tool，执行第二项

![](../images/2019/12/20191223003.png)


![](../images/2019/12/20191223004.png)

使用HEAD合并后的效果：

![](../images/2019/12/20191223005.png)

#   4、再手动修改

![](../images/2019/12/20191223006.png)

#   5、修改后的文件需要添加到git index中去：

![](../images/2019/12/20191223007.png)

#   6、冲突文件变为修改图标样式，再提交至本地，此时的提交便是merge合并：

![](../images/2019/12/20191223008.png)


![](../images/2019/12/20191223009.png)

#   7、此时需要pull的向下箭头和数量没了，注意图标的变化：

![](../images/2019/12/20191223010.png)


![](../images/2019/12/20191223011.png)

#   8、现在可以直接push到远程了：

![](../images/2019/12/20191223012.png)

此时`configure -> save and push`一步步执行冲突就搞定了。
