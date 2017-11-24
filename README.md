# 一. iSaltstack 项目说明

**概述**

  个人项目，目前专注于DBA工作，对运维自动化有强烈的兴趣，此项目包含但不限于数据库相关内容；从业7+年，阅读书籍无数，深感知识杂乱琐碎，无意中发现saltstack这个平台，借此平台将知识归纳落地（SOP）；因为时刻谨记一句话：学而不用，是你没用；此项目最终目的是完成日常运维工作的标准化（SOP），由于本人非全栈工程师，所以暂时所有操作都为命令行中实现。
  
**约定**

  请注意每个工具介绍中的【操作风险】提示部分。

**关于我**

Home：

  - https://github.com/linora

Owner: linora

  - Oracle/MySQL/PostgreSQL DBA

Mail: 984513956@qq.com

Wechat: 984513956


# 二. base/states 工具介绍

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

  - state 'xx' state.sls install_xtrabackup

**OS 支持情况**

  - CentOS 6.x/7.x
  - Redhat 6.x/7.x

**MySQL 支持情况**
 
  - mysql 5.6.x
  - mysql 5.7.x

**使用前准备**

  - 在base/states中创建resources目录，目录中包含必要的资源（rpm包）
  - 实现微信报警功能，即定制wechat.py
  - 设置grains mysql_home item指向mysql 数据文件根目录
  - 设置grains server_desc item，格式为"ipaddr_业务简短描述"
  - 在base/states/resources/mysql/sql中取得create_backup_user.sql文件，创建锁监控用函数及备份用用户名密码
  - 修改jinja2文件中mysql_backup_job.j2、mysql_backup_monitor_db_lock.j2及mysql_backup_monitor_disk.j2中DBUSR及DBPWD变量为实际备份用户名及密码

**其他说明**

  涉及到安全隐私，其中wechat.py脚本没有上传，此脚本可用来做微信实时报警，功能实现参考：https://www.cnblogs.com/hanyifeng/p/5368102.html

## 2. dist_my56/57_cnf

**操作风险**

  - 安全。

**功能说明**

  - 分发mysql配置文件到目标服务器的/tmp目录。

**使用示例**

  - state 'xx' state.sls dist_my56_cnf

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

  - 添加时间同步任务到系统中。

**使用示例**

  - state 'xx' state.sls setup_time_sync

**OS 支持情况**

  - CentOS
  - Redhat

