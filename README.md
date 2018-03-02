# 一. ZenDevOPS 项目说明

**概述**

  个人项目，目前专注于DBA工作，对运维自动化有强烈的兴趣，此项目包含但不限于数据库相关内容；从业7+年，阅读书籍无数，深感知识杂乱琐碎，无意中发现saltstack这个平台，借此平台将知识归纳落地（SOP）；因为时刻谨记一句话：学而不用，是你没用；此项目最终目的是完成日常运维工作的标准化（SOP），由于本人非全栈工程师，所以暂时所有操作都为命令行中实现。

**约定**

  请注意每个工具介绍中的【操作风险】提示部分。

**项目wiki**

  - https://github.com/linora/iSaltstack/wiki

项目其他文档内容请移步上文wiki。

**其他**

![test](base/resources/images/aa.jpg)

Owner: linora

  - Oracle/MySQL/PostgreSQL DBA
  
HomePages：

  - https://github.com/linora

Mail: 984513956@qq.com

Wechat: 984513956

# 二. base/states 工具集介绍

关于saltstack states module:

Simplicity, Simplicity, Simplicity

Many of the most powerful and useful engineering solutions are founded on simple principles. Salt States strive to do just that: K.I.S.S. (Keep It Stupidly Simple)

The core of the Salt State system is the SLS, or SaLt State file. The SLS is a representation of the state in which a system should be in, and is set up to contain this data in a simple format. This is often called configuration management.

ref:
  - https://docs.saltstack.com/en/latest/topics/tutorials/starting_states.html

## 1. install_xtrabackup

**操作风险**

  - 较危险，由于备份任务为IO密集型操作，请根据实际业务负载调整crontab中脚本运行时段（默认21:00执行数据库备份）

**功能说明**
  
  - 安装percona xtrabackup
  - 部署每日备份crontab，在每天晚上21:00进行备份工作
  - 备份期间会对db lock及disk used space进行监控，如果备份期间发现数据库锁或磁盘空间告急，则立即中断备份任务，并触发微信报警

**使用示例**

```bash
# Define vars
TARGET_HOST='*'
MYSQL_HOME='/app/mysql'

# Setup grains item
salt "${TARGET_HOST}" grains.setvals "{'mysql_home':\"${MYSQL_HOME}\"}"

salt "${TARGET_HOST}" state.sls install_xtrabackup
```

**OS 支持情况**

  - CentOS 6.x/7.x
  - Redhat 6.x/7.x

**MySQL 支持情况**
 
  - mysql 5.6.x
  - mysql 5.7.x

**使用前准备**

  - 在base/states中创建resources目录，目录中包含必要的资源（rpm包）
  - 实现微信报警功能，即定制python/wechat_priv.py
  - 设置grains mysql_home item指向mysql 数据文件根目录
  - 在base/states/resources/mysql/sql中取得create_backup_user.sql文件，创建锁监控用函数及备份用用户名密码
  - 在jinja2/common.j2中添加备份用数据库用户名密码

**其他说明**

  涉及到安全隐私，其中wechat_priv.py脚本没有上传，此脚本可用来做微信实时报警，功能实现参考：https://www.cnblogs.com/hanyifeng/p/5368102.html

## 2. dist_my56/57_cnf

**操作风险**

  - 安全。

**功能说明**

  - 分发mysql配置文件到目标服务器的/tmp目录。

**使用示例**

  - MySQL 5.6
  
```bash
# Define vars
TARGET_HOST='*'
MYSQL_HOME='/app/mysql'
SERVER_ID=0
# mysql所占总内存百分比
BUFFER_POOL_RATIO=0.125
# mysql 是否启用large page特性：1启用，0禁用
LARGE_PAGES=0
# OS huge pages数量，一个pages为2MB大小
HUGE_PAGES_NUMBER=0

# Setup grains item
salt "${TARGET_HOST}" grains.setvals "{'mysql_home':\"${MYSQL_HOME}\",
                                       'server_id':\"${SERVER_ID}\",
                                       'buffer_pool_ratio':${BUFFER_POOL_RATIO},
                                       'large_pages':\"${LARGE_PAGES}\",
                                       'huge_pages_number':0                                       
                                       }"

salt "${TARGET_HOST}" state.sls dist_my56_cnf
```

  - MySQL 5.7
  
```bash
TARGET_HOST='*'
MYSQL_HOME='/app/mysql'
SERVER_ID=0
# mysql 是否启用large page特性：1启用，0禁用
LARGE_PAGES=0
# OS huge pages数量，一个pages为2MB大小
HUGE_PAGES_NUMBER=0
# mysql 5.7中一个chunk为128M
CHUNK_COUNT=2

# Setup grains item
salt "${TARGET_HOST}" grains.setvals "{'mysql_home':\"${MYSQL_HOME}\",
                                       'server_id':\"${SERVER_ID}\",
                                       'chunk_count':${CHUNK_COUNT},
                                       'large_pages':\"${LARGE_PAGES}\",
                                       'huge_pages_number':0,
                                       }"

salt "${TARGET_HOST}" state.sls dist_my57_cnf
```



**OS 支持情况**

  - CentOS 6.x/7.x
  - Redhat 6.x/7.x

**MySQL 支持情况**
 
  - mysql 5.6.x
  - mysql 5.7.x

## 3. setup_time_sync

**操作风险**

  - 安全。

**功能说明**

  - 添加时间同步任务到系统中，同步周期为五分钟。

**使用示例**

  - state 'xx' state.sls setup_time_sync

**OS 支持情况**

  - CentOS
  - Redhat
  
# 三. base/services 工具集介绍

## 1. 安装MySQL 5.6/7 On CentOS/Redhat 6/7

**操作风险**

  - 无

**功能说明**
  
  - MySQL 安装最佳实践（安装目录定制 及 参数文件最佳化）
  
**使用示例**

  - mysql 5.6

```bash
# Define vars
TARGET_HOST='*'
MYSQL_HOME='/app/mysql'
SERVER_ID=0
# mysql所占总内存百分比
BUFFER_POOL_RATIO=0.125
# mysql 是否启用large page特性：1启用，0禁用
LARGE_PAGES=0
# OS huge pages数量，一个pages为2MB大小
HUGE_PAGES_NUMBER=0
MYSQL_DISK_LABEL='/dev/mapper/centos-root'

# Setup grains item
salt "${TARGET_HOST}" grains.setvals "{'mysql_home':\"${MYSQL_HOME}\",
                                       'buffer_pool_ratio':${BUFFER_POOL_RATIO},
                                       'server_id':${SERVER_ID},
                                       'large_pages':${LARGE_PAGES},
                                       'huge_pages_number':${HUGE_PAGES_NUMBER},
                                       'mysql_disk_label':\"${MYSQL_DISK_LABEL}\"}"

# Distribute mysql tarball
salt --timeout=1200 "${TARGET_HOST}" cp.get_file \
"salt://resources/mysql/pkgs/MySQL-5.6.37-1.el{{grains.osmajorrelease}}.x86_64.rpm-bundle.tar" \
"/tmp/MySQL-5.6.37-1.el{{grains.osmajorrelease}}.x86_64.rpm-bundle.tar" \
template=jinja \
saltenv=base

# Distribute my.cnf file
salt "${TARGET_HOST}" state.sls dist_my56_cnf

#
salt "${TARGET_HOST}" --timeout=1200 install_mysql5dot67_on_redhat67.install_mysql56
# 可选步骤（初始化mysql root密码，并返回最新密码）
salt "${TARGET_HOST}" --timeout=1200 install_mysql5dot67_on_redhat67.setup_mysql56
```

  - MySQL 5.7

```bash
TARGET_HOST='*'
MYSQL_HOME='/app/mysql'
SERVER_ID=0
# mysql 是否启用large page特性：1启用，0禁用
LARGE_PAGES=0
# OS huge pages数量，一个pages为2MB大小
HUGE_PAGES_NUMBER=0
# mysql 5.7中一个chunk为128M
CHUNK_COUNT=2
MYSQL_DISK_LABEL='/dev/mapper/centos-root'

salt "${TARGET_HOST}" grains.setvals "{'mysql_home':\"${MYSQL_HOME}\",
                                       'chunk_count':${CHUNK_COUNT},
                                       'server_id':${SERVER_ID},
                                       'large_pages':${LARGE_PAGES},
                                       'huge_pages_number':${HUGE_PAGES},
                                       'mysql_disk_label':\"${MYSQL_DISK_LABEL}\"}"

# Distribute mysql tarball
salt --timeout=1200 "${TARGET_HOST}" cp.get_file \
"salt://resources/mysql/pkgs/mysql-5.7.20-1.el{{grains.osmajorrelease}}.x86_64.rpm-bundle.tar" \
"/tmp/mysql-5.7.20-1.el{{grains.osmajorrelease}}.x86_64.rpm-bundle.tar" \
template=jinja \
saltenv=base

salt "${TARGET_HOST}" state.sls dist_my57_cnf


salt "${TARGET_HOST}" --timeout=86400 install_mysql5dot67_on_redhat67.install_mysql57
# 可选步骤（初始化mysql root密码，并返回最新密码）
salt "${TARGET_HOST}" --timeout=86400 install_mysql5dot67_on_redhat67.setup_mysql57
```

**OS 支持情况**

  - CentOS 6.x/7.x
  - Redhat 6.x/7.x

**MySQL 支持情况**
 
  - mysql 5.6.x
  - mysql 5.7.x

**预检查项**

  - 目标环境中必须存在grains 中指定的mysql disk label
  - 目标环境操作系统版本必须符合预期
  - 目标环境中没有运行中的mysqld进程
  - 目标环境中没有安装除mysql-libs/mariadb-libs以外的其他mysql相关包
  - 目标环境中没有创建grains中指定的mysql_home目录

**安装步骤**

  说明：以下操作全部为标准化流程，即修改配置前进行备份，且修改全部为非重复。

  - 手动格式化目标环境中mysql所使用磁盘
  - 挂载目标环境mysql所使用磁盘，并添加相关条目到/etc/fstab中
  - 禁用selinux
  - 初始化防火墙（初始设置中，3306端口不对外开放）
  - 设置所有disk io scheduler为deadline
  - 其他设置（limits.conf及sysctl.conf）
  - 安装阶段1（安装mysql rpm包，并关闭mysql服务）
  - 设置large pages
  - 安装阶段2（定制my.cnf、按最佳实践定制mysql安装目录、重新初始化及启动mysql服务）
  
  
## 2. 防火墙：MySQL：添加/删除/查看 mysql 3306端口访问权限

**OS 支持情况**

  - CentOS 6.x/7.x
  - Redhat 6.x/7.x
  
**使用示例**

  - CentOS/RHEL 7.x

```bash
# 添加规则
salt '*' setup_os.add_rich_rule 192.168.168.2 32

# 移除规则
salt '*' setup_os.remove_rich_rule 192.168.168.2 32

# 查看规则
salt '*' setup_os.firewall_cmd_list_all
```

  - CentOS/RHEL 6.x

```bash
# 添加规则
salt '*' setup_os.add_iptables_rule 192.168.168.2 32

# 移除规则
salt '*' setup_os.remove_iptables_rule 192.168.168.2 32

# 查看规则
salt '*' setup_os.iptables_status
```

## 3. 防火墙：saltstack：添加 minion对应master端口访问权限

**OS 支持情况**

  - CentOS 6.x/7.x
  - Redhat 6.x/7.x
  
**使用示例**

```bash
salt '*' setup_os.add_iptables_rule4minion 192.168.168.2 32
```

## 四. saltstack mysql returner功能启用

returner 返回数据到mysql后，可供类似工单系统使用，或者公司内部cmdb使用。

**参照：**
  - https://github.com/linora/iSaltstack/wiki/3.-%E8%AE%BE%E7%BD%AESaltstack-retuner

