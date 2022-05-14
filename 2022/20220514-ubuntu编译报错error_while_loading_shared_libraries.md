#   ubuntu编译报错error while loading shared libraries:

----


1.  项目场景

ubuntu20.04编译报错

```
error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory
```

2.  原因分析：

缺少libncurses5文件

3.  解决方案：

安装libncurses5解决，命令如下

```shell
sudo apt install libncurses5
```
