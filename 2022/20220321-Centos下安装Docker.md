# Centos�°�װDocker

----

����ϵͳ���������ĵ� https://docs.docker.com/engine/install/centos/

1.  �Ƴ���ǰdocker��ذ�

```bash
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

2.  ����yumԴ

```bash
sudo yum install -y yum-utils
sudo yum-config-manager \
--add-repo \
http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

3.  ��װdocker

```bash
# Ҫע��汾
# kubernetes��docker�汾Ҫ��Ӧ,��Ȼ�������ܶ���ֵ�����,����װ����
sudo yum install -y docker-ce docker-ce-cli containerd.io

#�������ڰ�װk8s��ʱ��ʹ��
yum install -y docker-ce-20.10.7 docker-ce-cli-20.10.7  containerd.io-1.4.6
```

4.  ����

```bash
systemctl enable docker --now
```

5.  ���ü���

������������docker������������������cgroup

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://82m9ar63.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```