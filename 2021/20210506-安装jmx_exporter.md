#   安装jmx_exporter

---

##  使用ansible安装
去仓库翻

##  手动安装

就是一个jar包

### 下载安装jmx_exporter
1.  新建一个目录专门安装各种exporter

```
mkdir -p /opt/module/jmx_exporter
```

2.  下载(已经下好了)

```
cd /opt/module/jmx_exporter
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.13.0/jmx_prometheus_javaagent-0.13.0.jar
```
