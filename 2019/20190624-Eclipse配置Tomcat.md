#   Eclipse配置Tomcat
date: 2019-06-24 23:40:15
description: 不同环境下(windows和ubuntu)Eclipse配置Tomcat
tags:
- Tomcat
- Eclipse
categories:
- Java
---
#  配置Server
## Ubuntu环境
### 配置过程
1.  在`Servers`里面(一般在正下方面板),`右键->new->server->选择到apache分类->找到对应的tomcat版本`,接着一步一步配置即可
2.  配置完毕后,在server里面,右键刚才的服务器,然后open找到上面的`Server Location`,选择中间的`Use Tomcat installation...`

##  出现的问题
### tomcat文件分散在不同目录
#### 问题重现
>   1.在ubuntu中使用`sudo apt get`安装了`apache tomcat9`
>   2.使用`Windows> Preferences> Server> Runtime Environment`将apache tomcat 9添加到eclipse中
>   3.从服务器视图启动服务器时出现`Could not load the Tomcat server configuration at /Servers/Tomcat v9.0 Server at localhost-config. The configuration may be corrupt or incomplete.`(无法在localhost-config的/ Servers / Tomcat v9.0服务器上加载Tomcat服务器配置。配置可能已损坏或不完整)

#### 原因
1.  用apt-get安装的tomcat9,文件并不在同一个位置,而Eclipse期望tomcat配置文件等都在同一个位置
2.  文件需要具有必要的权限

#### 解决
```
cd /usr/share/tomcat9
sudo ln -s /var/lib/tomcat9/conf conf
sudo ln -s /var/log/tomcat9 logs
sudo ln -s /etc/tomcat9/policy.d/03catalina.policy conf/catalina.policy
sudo chmod -R a + rwx /usr/share/tomcat9/conf
```
#### 参考
[Could not load the Tomcat server configuration](https://stackoverflow.com/questions/30962932/could-not-load-the-tomcat-server-configuration)
[TOMCAT9 SERVER IN ECLIPSE WITH UBUNTU](http://adamish.com/blog/archives/355)

### tomcat缺少backup目录
#### 启动Server时,报如下错误
>   Publishing the configuration... Error copying file to /usr/share/tomcat9/backup/catalina.policy: /usr/share/tomcat7/backup/catalina.policy (No such file or directory) /usr/share/tomcat7/backup/catalina.policy (No such file or directory) Error copying file to /usr/share/tomcat7/backup/catalina.properties: /usr/share/tomcat7/backup/catalina.properties (No such file or directory) /usr/share/tomcat7/backup/catalina.properties (No such file or directory) Error copying file to /usr/share/tomcat7/backup/context.xml: /usr/share/tomcat7/backup/context.xml (No such file or directory) /usr/share/tomcat7/backup/context.xml (No such file or directory) Error copying file to /usr/share/tomcat7/backup/server.xml: /usr/share/tomcat7/backup/server.xml (No such file or directory) /usr/share/tomcat7/backup/server.xml (No such file or directory) Error copying file to /usr/share/tomcat7/backup/tomcat-users.xml: /usr/share/tomcat7/backup/tomcat-users.xml (No such file or directory) /usr/share/tomcat7/backup/tomcat-users.xml (No such file or directory) Error copying file to /usr/share/tomcat7/backup/web.xml: /usr/share/tomcat7/backup/web.xml (No such file or directory) /usr/share/tomcat7/backup/web.xml (No such file or directory)

#### 原因
1.  这个错误通常在linux下或者osx下
2.  而且tomcat目录不再当前user所属文件目录下
3.  这时eclipse并没有权限到系统中tomcat安装目录下创建这样一个backup目录

#### 解决
我们可以自己手动建一个这样目录,然后赋予读写权限即可
```
    cd /usr/share/tomcat9/
    sudo mkdir backup
    sudo chmod 777 backup

    注意:
        权限并非一定需要给到777
        由于用apt-get安装的tomcat9大致分散在root组和tomcat组
        所以,若能设置用户属于tomcat组,权限可以降低
```

### tomcat缺少其他目录
1.  如果在tomcat分散的目录有对应的目录就软链到`/usr/share/tomcat9/`目录
2.  如果没有对应的目录,处理方式和上述`tomcat缺少backup目录`处理的方式相同
