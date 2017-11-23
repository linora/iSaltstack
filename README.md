## saltstack 初始化

**Redhat/CentOS 平台安装方法参照：**
  https://repo.saltstack.com/#rhel

**master简单配置**

```bash
# cat /etc/salt/master
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


