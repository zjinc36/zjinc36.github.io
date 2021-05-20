#   HDFS的Shell操作(开发重点)

----

##  基本语法
+   bin/hadoop fs 具体命令   OR  bin/hdfs dfs 具体命令
+   dfs是fs的实现类。

##  命令大全
```
[root@linux191 hadoop]$ bin/hadoop fs

[-appendToFile <localsrc> ... <dst>]
        [-cat [-ignoreCrc] <src> ...]
        [-checksum <src> ...]
        [-chgrp [-R] GROUP PATH...]
        [-chmod [-R] <MODE[,MODE]... | OCTALMODE> PATH...]
        [-chown [-R] [OWNER][:[GROUP]] PATH...]
        [-copyFromLocal [-f] [-p] <localsrc> ... <dst>]
        [-copyToLocal [-p] [-ignoreCrc] [-crc] <src> ... <localdst>]
        [-count [-q] <path> ...]
        [-cp [-f] [-p] <src> ... <dst>]
        [-createSnapshot <snapshotDir> [<snapshotName>]]
        [-deleteSnapshot <snapshotDir> <snapshotName>]
        [-df [-h] [<path> ...]]
        [-du [-s] [-h] <path> ...]
        [-expunge]
        [-get [-p] [-ignoreCrc] [-crc] <src> ... <localdst>]
        [-getfacl [-R] <path>]
        [-getmerge [-nl] <src> <localdst>]
        [-help [cmd ...]]
        [-ls [-d] [-h] [-R] [<path> ...]]
        [-mkdir [-p] <path> ...]
        [-moveFromLocal <localsrc> ... <dst>]
        [-moveToLocal <src> <localdst>]
        [-mv <src> ... <dst>]
        [-put [-f] [-p] <localsrc> ... <dst>]
        [-renameSnapshot <snapshotDir> <oldName> <newName>]
        [-rm [-f] [-r|-R] [-skipTrash] <src> ...]
        [-rmdir [--ignore-fail-on-non-empty] <dir> ...]
        [-setfacl [-R] [{-b|-k} {-m|-x <acl_spec>} <path>]|[--set <acl_spec> <path>]]
        [-setrep [-R] [-w] <rep> <path> ...]
        [-stat [format] <path> ...]
        [-tail [-f] <file>]
        [-test -[defsz] <path>]
        [-text [-ignoreCrc] <src> ...]
        [-touchz <path> ...]
        [-usage [cmd ...]]
```

##  常用命令实操
启动Hadoop集群（方便后续的测试）
```
[root@linux191 hadoop]$ sbin/start-dfs.sh
[atguigu@hadoop103 hadoop-2.7.2]$ sbin/start-yarn.sh
```

##  -help：输出这个命令参数
```
[root@linux191 hadoop]$ hadoop fs -help rm
```

##  -ls: 显示目录信息
```
[root@linux191 hadoop] hadoop fs -ls  /
列出hdfs文件系统根目录下的目录和文件
[root@linux191 hadoop] hadoop fs -ls -R /
列出hdfs文件系统所有的目录和文件
```

##  -mkdir：在HDFS上创建目录
```
[root@linux191 hadoop]$ hadoop fs -mkdir -p /sanguo/shuguo\
```

详细说明

```
hadoop fs -mkdir < hdfs path>
```

只能一级一级的建目录，父目录不存在的话使用这个命令会报错

```
hadoop fs -mkdir -p < hdfs path> 
```

所创建的目录如果父目录不存在就创建该父目录

##  -moveFromLocal：从本地剪切粘贴到HDFS
```
[root@linux191 hadoop]$ touch kongming.txt
[root@linux191 hadoop]$ hadoop fs  -moveFromLocal  ./kongming.txt  /sanguo/shuguo
```

##  -appendToFile：追加一个文件到已经存在的文件末尾
```
[root@linux191 hadoop]$ touch liubei.txt
[root@linux191 hadoop]$ vi liubei.txt

输入

san gu mao lu

[root@linux191 hadoop]$ hadoop fs -appendToFile liubei.txt /sanguo/shuguo/kongming.txt
```

##  -cat：显示文件内容
```
[root@linux191 hadoop]$ hadoop fs -cat /sanguo/shuguo/kongming.txt
```

##  -chgrp 、-chmod、-chown：Linux文件系统中的用法一样，修改文件所属权限
```
[root@linux191 hadoop]$ hadoop fs  -chmod  666  /sanguo/shuguo/kongming.txt
[root@linux191 hadoop]$ hadoop fs  -chown  atguigu:atguigu   /sanguo/shuguo/kongming.txt
```

##  -copyFromLocal：从本地文件系统中拷贝文件到HDFS路径去
```
[root@linux191 hadoop]$ hadoop fs -copyFromLocal README.txt /
```

##  -copyToLocal：从HDFS拷贝到本地
```
[root@linux191 hadoop]$ hadoop fs -copyToLocal /sanguo/shuguo/kongming.txt ./
```

##  -cp ：从HDFS的一个路径拷贝到HDFS的另一个路径
```
[root@linux191 hadoop]$ hadoop fs -cp /sanguo/shuguo/kongming.txt /zhuge.txt
```
说明
```
hadoop fs -cp  < hdfs file >  < hdfs file >
```
目标文件不能存在，否则命令不能执行，相当于给文件重命名并保存，源文件还存在
```
hadoop fs -cp < hdfs file or dir >... < hdfs dir >
```
目标文件夹要存在，否则命令不能执行

##  -mv：在HDFS目录中移动文件
```
[root@linux191 hadoop]$ hadoop fs -mv /zhuge.txt /sanguo/shuguo/
```
说明
```
hadoop fs -mv < hdfs file >  < hdfs file >
```
目标文件不能存在，否则命令不能执行，相当于给文件重命名并保存，源文件不存在
```
hadoop fs -mv  < hdfs file or dir >...  < hdfs dir >
```
源路径有多个时，目标路径必须为目录，且必须存在。
注意：跨文件系统的移动（local到hdfs或者反过来）都是不允许的

##  -get：等同于copyToLocal，就是从HDFS下载文件到本地
```
[root@linux191 hadoop]$ hadoop fs -get /sanguo/shuguo/kongming.txt ./

[root@linux191 hadoop]$ hadoop fs -get < hdfs file > < local file or dir>
```
local file不能和 hdfs file名字不能相同，否则会提示文件已存在，没有重名的文件会复制到本地
```
hadoop fs -get < hdfs file or dir > ... < local  dir >
```
拷贝多个文件或目录到本地时，本地要为文件夹路径
注意：如果用户不是root， local 路径要为用户文件夹下的路径，否则会出现权限问题

+   moveToLocal

当前版本中还未实现此命令

+   copyToLocal

```
hadoop fs -copyToLocal < local src > ... < hdfs dst >
```
与get相类似

##  -getmerge：合并下载多个文件，比如HDFS的目录 /user/atguigu/test下有多个文件:log.1, log.2,log.3,...
```
[root@linux191 hadoop]$ hadoop fs -getmerge /user/atguigu/test/* ./zaiyiqi.txt
```
说明
```
hadoop fs -getmerge < hdfs dir >  < local file >
```
将hdfs指定目录下所有文件排序后合并到local指定的文件中，文件不存在时会自动创建，文件存在时会覆盖里面的内容
```
hadoop fs -getmerge -nl  < hdfs dir >  < local file >
```
加上nl后，合并到local file中的hdfs文件之间会空出一行

##  -put：等同于copyFromLocal
```
[root@linux191 hadoop]$ hadoop fs -put ./zaiyiqi.txt /user/atguigu/test/
```

说明
```
[root@linux191 hadoop]$hadoop fs -put < local file > < hdfs file >
```
hdfs file的父目录一定要存在，否则命令不会执行
```
[root@linux191 hadoop]$hadoop fs -put  < local file or dir >...< hdfs dir >
```
hdfs dir 一定要存在，否则命令不会执行
```
[root@linux191 hadoop]$hadoop fs -put - < hdsf  file>
```
从键盘读取输入到hdfs file中，按Ctrl+D结束输入，hdfs file不能存在，否则命令不会执行

+   moveFromLocal

```
[root@linux191 hadoop]$hadoop fs -moveFromLocal  < local src > ... < hdfs dst >
```
与put相类似，命令执行后源文件 local src 被删除，也可以从从键盘读取输入到hdfs file中

+   copyFromLocal

```
[root@linux191 hadoop]$hadoop fs -copyFromLocal  < local src > ... < hdfs dst >
```
与put相类似，也可以从从键盘读取输入到hdfs file中

##  -tail：显示一个文件的末尾
```
[root@linux191 hadoop]$ hadoop fs -tail /sanguo/shuguo/kongming.txt
```
说明
```
hadoop fs -tail < hdfs file >
```
在标准输出中显示文件末尾的1KB数据

##  -rm：删除文件或文件夹
```
[root@linux191 hadoop]$ hadoop fs -rm /user/atguigu/test/jinlian2.txt
```
参数说明
```
hadoop fs -rm < hdfs file > ...
```

```
hadoop fs -rm -r < hdfs dir>...
```
每次可以删除多个文件或目录

##  -rmdir：删除空目录
```
[root@linux191 hadoop]$ hadoop fs -mkdir /test
[root@linux191 hadoop]$ hadoop fs -rmdir /test
```

##  -du统计文件夹的大小信息
```
[root@linux191 hadoop]$ hadoop fs -du -s -h /user/atguigu/test
2.7 K  /user/atguigu/test

[root@linux191 hadoop]$ hadoop fs -du  -h /user/atguigu/test
1.3 K  /user/atguigu/test/README.txt
15     /user/atguigu/test/jinlian.txt
1.4 K  /user/atguigu/test/zaiyiqi.txt
```

说明
```
hadoop fs -du < hdsf path> 
```
显示hdfs对应路径下每个文件夹和文件的大小
```
hadoop fs -du -s < hdsf path> 
```
显示hdfs对应路径下所有文件和的大小
```
hadoop fs -du - h < hdsf path> 
```
显示hdfs对应路径下每个文件夹和文件的大小,文件的大小用方便阅读的形式表示，例如用64M代替67108864

##  -setrep：设置HDFS中文件的副本数量
```
[root@linux191 hadoop]$ hadoop fs -setrep 10 /sanguo/shuguo/kongming.txt
```

![](../images/2021/05/20210520105429.png)

这里设置的副本数只是记录在NameNode的元数据中，是否真的会有这么多副本，还得看DataNode的数量。因为目前只有3台设备，最多也就3个副本，只有节点数的增加到10台时，副本数才能达到10。

##  -count:统计对应路径下的目录个数，文件个数，文件总计大小
```
hadoop fs -count < hdfs path >
```
统计hdfs对应路径下的目录个数，文件个数，文件总计大小
显示为目录个数，文件个数，文件总计大小，输入路径

##  -text:将文本文件或某些格式的非文本文件通过文本格式输出
```
hadoop fs -text < hdsf file>
```
将文本文件或某些格式的非文本文件通过文本格式输出

##  -setrep:改变一个文件在hdfs中的副本个数
```
hadoop fs -setrep -R 3 < hdfs path >
```
改变一个文件在hdfs中的副本个数，上述命令中数字3为所设置的副本个数，-R选项可以对一个人目录下的所有目录+文件递归执行改变副本个数的操作

##  -stat:返回对应路径的状态信息
```
hdoop fs -stat [format] < hdfs path >
```
返回对应路径的状态信息
```
[format]可选参数有：%b（文件大小），%o（Block大小），%n（文件名），%r（副本个数），%y（最后一次修改日期和时间）
```
可以这样书写hadoop fs -stat %b%o%n < hdfs path >，不过不建议，这样每个字符输出的结果不是太容易分清楚

##  -archive:压缩文件
```
hadoop archive -archiveName name.har -p < hdfs parent dir > < src >* < hdfs dst >
```
+   命令中参数name：压缩文件名，自己任意取；< hdfs parent dir > ：压缩文件所在的父目录；< src >：要压缩的文件名；< hdfs dst >：压缩文件存放路径
+   示例：hadoop archive -archiveName hadoop.har -p /user 1.txt 2.txt /des
+   示例中将hdfs中/user目录下的文件1.txt，2.txt压缩成一个名叫hadoop.har的文件存放在hdfs中/des目录下，如果1.txt，2.txt不写就是将/user目录下所有的目录和文件压缩成一个名叫hadoop.har的文件存放在hdfs中/des目录下
+   显示har的内容可以用如下命令：

```
hadoop fs -ls /des/hadoop.jar
```
显示har压缩的是那些文件可以用如下命令
```
hadoop fs -ls -R har:///des/hadoop.har
```
注意：har文件不能进行二次压缩。如果想给.har加文件，只能找到原来的文件，重新创建一个。har文件中原来文件的数据并没有变化，har文件真正的作用是减少NameNode和DataNode过多的空间浪费。

##  -balancer:启动DataNode内部的均衡
```
hdfs balancer
```
如果管理员发现某些DataNode保存数据过多，某些DataNode保存数据相对较少，可以使用上述命令手动启动内部的均衡过程

##  -dfsadmin:用以管理HDFS
```
hdfs dfsadmin -help
```
管理员可以通过dfsadmin管理HDFS，用法可以通过上述命令查看
```
hdfs dfsadmin -report
```
显示文件系统的基本数据

+   hdfs dfsadmin -safemode < enter | leave | get | wait >
+   enter：进入安全模式；leave：离开安全模式；get：获知是否开启安全模式；
+   wait：等待离开安全模式

##  -distcp:在两个HDFS之间拷贝数据
用来在两个HDFS之间拷贝数据
