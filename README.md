## 一. Saltstack 安装

**Redhat/CentOS 平台安装方法参照：**
  https://repo.saltstack.com/#rhel

## 二. 快速配置

**1. master 配置文件定制**
```bash
cat /etc/salt/master

file_roots:
  base:
    - /root/myProj/DB2s_cmmd/salt/base/services
    - /root/myProj/DB2s_cmmd/salt/base/states
  dev:
    - /srv/salt/dev/services
    - /srv/salt/dev/states
  prod:
    - /srv/salt/prod/services
    - /srv/salt/prod/states
```

**2. minion 配置文件定制**
```bash
cat /etc/salt/minion

id: c7
master: master-ip-address
```

**3. 配置服务为非手动启动**
```bash
# rhel 6.x
chkconfig salt-master/salt-minion off

# rhel 7.x
systemctl disable salt-master/salt-minion
```
**4. 启动salt服务**
```bash
service salt-master start
service salt-minion start
```
