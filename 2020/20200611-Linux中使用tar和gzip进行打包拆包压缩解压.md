#   Linux中使用tar和gzip进行打包拆包压缩解压

---

#   压缩格式
+ windows (zip、rar)
+ linux  (gz ，bzip，zip)

# 打包和压缩的区别

+ 打包后可以拆包，压缩后可以解压
+ 打包：目录可能有很多个文件，我先把它们打包成一个文件
+ 压缩：把打包后的那个文件压缩（先打包再压缩）

#	gzip压缩与解压(bzip2也可以)

## 压缩

1. 命令

```bash
gzip  要压缩的打包后的文件名即归档文件名.tar
```
2. 例子

```bash
gzip  news.tar
```

## 解压

1. 命令

```bash
 gzip  -d  要解压的文件名.tar.gz
```

2. 例子

```bash
gzip  -d  news.tar.gz
```

# tar打包与拆包

## 参数说明

- c ：打包，创建的一个归档文件，即打包文件夹
- x ：拆包
- z ：以gzip格式压缩，默认压缩倍数6倍（0-9）
- j ：以bzip2格式压缩
- v ：显示打包或者拆包的文件信息
- f ：后面紧接一个归档文件

##	打包

1. 命令
```bash
tar  -cvf  打包后的文件名即归档文件.tar  欲打包的文件夹名
```
2. 例子
```bash
 tar  -cvf  news.tar  ./java   把java文件夹打包成new.tar
```

##	拆包

1. 命令
```bash
tar  -xvf  打包后的文件名即归档文件名.tar
```

2. 例子
```bash
tar  -xvf  news.tar   可以把new.tar拆包，拆出来java文件夹
```

## 打包且压缩

1. 命令

```bash
tar  -czvf  打包并压缩后的文件名.tar.gz  欲打包及压缩的文件夹名
```

2. 例子

```bash
tar  -czvf  news.tar.gz  ./java
或
tar  -czvf  news.tar.gz  java/
或
tar  -czvf  news.tar.gz  java
```

## 解压及拆包

1. 命令

```bash
tar  -xzvf  打包及压缩后的文件名.tar.gz
```

- x：拆包
- z：解压
- v：显示打包或者拆包的文件信息
- f:后面紧接一个归档文件

2. 例子

```bash
tar  -xzvf  news.tar.gz
```
