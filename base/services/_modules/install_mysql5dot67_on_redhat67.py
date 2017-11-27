# coding=utf-8
'''
  MySQL 部署
'''

#############################################################################################################################
# lib 包导入

from __future__ import absolute_import

# 导入Python lib包
import logging
import os
import sys
import time
import traceback
import random
import string

# 导入Saltstack lib包
import salt
import salt.utils
import salt.version
import salt.loader
import salt.ext.six as six
from salt.utils.decorators import depends

# 导入私有 lib包
from os_cmd import d_cmd_list as g_cmd_list

#############################################################################################################################
# Saltstack 通用设置

__proxyenabled__ = ['*']

# Don't shadow built-in's.
__func_alias__ = {
    'true_': 'true',
    'false_': 'false'
}

log = logging.getLogger(__name__)

@depends('non_existantmodulename')
def missing_func():
  return 'foo'

#############################################################################################################################
# 通用变量定义

d_cmd_list = {
################################################################
# 显示mysqld进程数
'mysqld_processes':
r'''
ps aux | grep -i mysqld | grep -v grep | wc -l
''',
################################################################
# mysql rpm包安装计数（排除mysql-libs包）
'installed_mysql_pkgs_count':
r'''
rpm -qa | grep -i '^mysql' | grep -iv 'mysql-libs' | wc -l
''',
################################################################
# 安装与初始化MySQL（命令部分1）
'install_mysql56_part1':
r'''
rm -f /var/lib/mysql/RPM_UPGRADE_MARKER

cd /tmp
tar -xvf MySQL*5.6.37*.tar >/dev/null 2>/dev/null
rpm -ivh MySQL*5.6.37*.rpm >/dev/null 2>/dev/null
service mysql stop >/dev/null 2>/dev/null

echo '【MySQL PKGS】'
rpm -qa | grep -i ^mysql | sort -d
''',
################################################################
# 安装与初始化MySQL（命令部分2）
'install_mysql56_part2':
r'''
# 备份
cp -f /usr/my.cnf /usr/my.cnf.$(date '+%s');rm -f /usr/my.cnf >/dev/null 2>/dev/null
cp -f /etc/my.cnf /etc/my.cnf.$(date '+%s');rm -f /etc/my.cnf >/dev/null 2>/dev/null
# 覆盖
cp /tmp/my.cnf /etc/my.cnf  >/dev/null 2>/dev/null
sed -i '/innodb_buffer_pool_size/s/.0M/M/g' /etc/my.cnf
# 创建mysql_home目录
mkdir -p {mysql_home}
mount {mysql_home}
mkdir {mysql_home}/binlog_dir
mkdir {mysql_home}/data_dir
mkdir {mysql_home}/innodb_data
mkdir {mysql_home}/tmp_dir
mkdir {mysql_home}/innodb_log
mkdir {mysql_home}/undo_dir
chown -R mysql:mysql {mysql_home}/
# 按定制后my.cnf内容初始化库
mysql_install_db --defaults-file=/etc/my.cnf  >/dev/null 2>/dev/null
service mysql start >/dev/null 2>/dev/null

echo '【MySQL Home Size】'
du -sh {mysql_home}
''',
################################################################
# mysql 初始设置
'setup_mysql56':
r'''
mysql -s -e "update mysql.user set password=password('{mysql_password}')
where (user, host) in (('root', 'localhost'),
                       ('root', '127.0.0.1'),
                       ('root', '$(hostname)'),
                       ('root', '::1'));
delete from mysql.user
where (user, host) not in (('root', 'localhost'),
                           ('root', '127.0.0.1'),
                           ('root', '$(hostname)'),
                           ('root', '::1'));
flush privileges;
drop database test;"

echo '【MySQL安装：errlog内容——仅显示warning、error及fatal内容】'
egrep -i 'warn|erro|fata' {mysql_home}/err.log
echo '【MySQL：服务运行状态】'
service mysql status

true > ~/.mysql_history 
history -c
''',
################################################################
# 安装与初始化MySQL（命令部分1）
'install_mysql57_part1':
r'''
rm -f /var/lib/mysql/RPM_UPGRADE_MARKER

cd /tmp
tar -xvf mysql*5.7.20*.tar >/dev/null 2>/dev/null
rm -rf mysql*minimal*5.7.20*.rpm
yum install -y perl*JSON perl*Time*HiRes >/dev/null 2>/dev/null
rpm -ivh mysql*5.7.20*.rpm >/dev/null 2>/dev/null
service mysql stop >/dev/null 2>/dev/null
service mysqld stop >/dev/null 2>/dev/null

echo '【MySQL PKGS】'
rpm -qa | grep -i ^mysql | sort -d
''',
################################################################
# 安装与初始化MySQL（命令部分2）
'install_mysql57_part2':
r'''
# 备份
cp -f /usr/my.cnf /usr/my.cnf.$(date '+%s');rm -f /usr/my.cnf >/dev/null 2>/dev/null
cp -f /etc/my.cnf /etc/my.cnf.$(date '+%s');rm -f /etc/my.cnf >/dev/null 2>/dev/null
# 覆盖
cp /tmp/my.cnf /etc/my.cnf  >/dev/null 2>/dev/null
sed -i '/innodb_buffer_pool_size/s/.0M/M/g' /etc/my.cnf
# 创建mysql_home目录
mkdir -p {mysql_home}
mount {mysql_home}
mkdir {mysql_home}/innodb_tmpdir
mkdir {mysql_home}/binlog_dir
mkdir {mysql_home}/data_dir
mkdir {mysql_home}/innodb_data
mkdir {mysql_home}/tmp_dir
mkdir {mysql_home}/innodb_log
mkdir {mysql_home}/undo_dir
chown -R mysql:mysql {mysql_home}/
# 按定制后my.cnf内容初始化库
mysqld --initialize >/dev/null 2>/dev/null
service mysqld start >/dev/null 2>/dev/null

echo '【MySQL Home Size】'
du -sh {mysql_home}
''',
################################################################
# mysql 初始设置
'setup_mysql57':
r'''
TEMP_PWD=$(egrep -i 'temporary password' {mysql_home}/err.log |\
awk '{{print }}' |\
sed -n '$p'|\
awk '{{print $NF}}' |\
awk -F '.' '{{print $1}}' |\
awk -F '_' '{{print $NF}}')

mysql --connect-expired-password -uroot -p${{TEMP_PWD}} -e "
ALTER USER 'root'@'localhost'   IDENTIFIED BY '{mysql_password}' PASSWORD EXPIRE NEVER;
"

echo '【MySQL安装：errlog内容——仅显示warning、error及fatal内容】'
egrep -i 'warn|erro|fata' {mysql_home}/err.log
echo '【MySQL：服务运行状态】'
service mysqld status

true > ~/.mysql_history 
history -c
'''
}

#############################################################################################################################
# 通用函数定义

def _salt_cmd_run_stdout(cmd,python_shell=True):
  return __salt__['cmd.run_stdout'](cmd,python_shell=python_shell)

#############################################################################################################################
# 功能函数定义

def pre_check():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' install_mysql5dot67_on_redhat67.pre_check
  '''       

  v_os_family = __grains__['os_family']
  v_osarch = __grains__['osarch']
  v_osmajorrelease = __grains__['osmajorrelease']

  v_mysqld_processes = _salt_cmd_run_stdout(d_cmd_list['mysqld_processes'])
  v_installed_mysql_pkgs_count = _salt_cmd_run_stdout(d_cmd_list['installed_mysql_pkgs_count']) 

  v_mysql_home = __grains__['mysql_home']
  v_if_mysql_home_exists = __salt__['file.directory_exists'](v_mysql_home)

  v_disk_label = __grains__['mysql_disk_label'].rstrip(string.digits)
  v_disk_info = __salt__['storage_tools.all_disk_info']()

  try:
    v_flag = v_disk_info.index(v_disk_label)
    v_if_exists_disk = 1
  except Exception,e:
    v_if_exists_disk = 0

  if v_if_exists_disk == 0:
    return '错误：{disk_label}不存在。'.format(disk_label=v_disk_label)
  elif not( v_os_family == 'RedHat' and v_osarch == 'x86_64' and v_osmajorrelease in(6,7) ):
    return '错误：不支持的操作系统。'
  elif int(v_mysqld_processes) != 0:
    return '错误：目标服务器已经有MySQL运行中。'
  elif int(v_installed_mysql_pkgs_count) != 0:
    return '错误：目标服务器已经安装ySQL。'
  elif v_if_mysql_home_exists:
    return '错误：{mysql_home}目录已经存在。' .format(mysql_home=v_mysql_home)
  else:
    return '信息：可正常进行安装。'



def install_mysql56():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' install_mysql5dot67_on_redhat67.install_mysql56
  '''         
  v_retval = ''

  v_check_out = pre_check()
  v_retval += v_check_out + '\n'

  if v_check_out.startswith('错误：'):
    return v_retval
  else:
    v_mount_out = __salt__['setup_os.mount_mysql_disk']()
    v_retval += v_mount_out + '\n'

    v_osmajorrelease = __grains__['osmajorrelease']
    v_cmd_out = __salt__['setup_os.disable_selinux']()
    v_retval += v_cmd_out + '\n'
    
    if v_osmajorrelease == 6:
      v_cmd_out = __salt__['setup_os.init_iptables_for_mysql']()
      v_retval += v_cmd_out + '\n'
    else:
      v_cmd_out = __salt__['setup_os.init_firewalld_for_mysql']()
      v_retval += v_cmd_out + '\n'

    v_cmd_out = __salt__['storage_tools.set_all_disk_scheduler_deadline']()
    v_retval += v_cmd_out + '\n'

    v_cmd_out = __salt__['setup_os.other_setup']()
    v_retval += v_cmd_out + '\n'    
    
    v_mysql_home = __grains__['mysql_home']

    v_cmd = d_cmd_list['install_mysql56_part1'].format(mysql_home=v_mysql_home)
    v_part1_stdout = _salt_cmd_run_stdout(v_cmd)
    v_retval += v_part1_stdout + '\n'

    v_have_huge_pages = __grains__['large_pages']
    if v_have_huge_pages == 1:
      v_cmd_out = __salt__['setup_os.setup_huge_pages']()
      v_retval += v_cmd_out + '\n'

    v_cmd = d_cmd_list['install_mysql56_part2'].format(mysql_home=v_mysql_home)
    v_part2_stdout = _salt_cmd_run_stdout(v_cmd)
    v_retval += v_part2_stdout + '\n'

    v_mount_info = _salt_cmd_run_stdout(g_cmd_list['mount_info'])
    v_retval += '【mount】\n' + v_mount_info + '\n'

    return v_retval 



def install_mysql57():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' install_mysql5dot67_on_redhat67.install_mysql56
  '''         
  v_retval = ''

  v_check_out = pre_check()
  v_retval += v_check_out + '\n'

  if v_check_out.startswith('错误：'):
    return v_retval
  else:
    v_mount_out = __salt__['setup_os.mount_mysql_disk']()
    v_retval += v_mount_out + '\n'

    v_osmajorrelease = __grains__['osmajorrelease']
    v_cmd_out = __salt__['setup_os.disable_selinux']()
    v_retval += v_cmd_out + '\n'
    
    if v_osmajorrelease == 6:
      v_cmd_out = __salt__['setup_os.init_iptables_for_mysql']()
      v_retval += v_cmd_out + '\n'
    else:
      v_cmd_out = __salt__['setup_os.init_firewalld_for_mysql']()
      v_retval += v_cmd_out + '\n'

    v_cmd_out = __salt__['storage_tools.set_all_disk_scheduler_deadline']()
    v_retval += v_cmd_out + '\n'

    v_cmd_out = __salt__['setup_os.other_setup']()
    v_retval += v_cmd_out + '\n'    
    
    v_mysql_home = __grains__['mysql_home']

    v_cmd = d_cmd_list['install_mysql57_part1'].format(mysql_home=v_mysql_home)
    v_part1_stdout = _salt_cmd_run_stdout(v_cmd)
    v_retval += v_part1_stdout + '\n'

    v_have_huge_pages = __grains__['large_pages']
    if v_have_huge_pages == 1:
      v_cmd_out = __salt__['setup_os.setup_huge_pages']()
      v_retval += v_cmd_out + '\n'

    v_cmd = d_cmd_list['install_mysql57_part2'].format(mysql_home=v_mysql_home)
    v_part2_stdout = _salt_cmd_run_stdout(v_cmd)
    v_retval += v_part2_stdout + '\n'

    v_mount_info = _salt_cmd_run_stdout(g_cmd_list['mount_info'])
    v_retval += '【mount】\n' + v_mount_info + '\n'

    return v_retval 



def setup_mysql56():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' install_mysql5dot67_on_redhat67.setup_mysql56
  '''

  v_retval = ''
  v_mysql_home = __grains__['mysql_home']  

  v_mysql_password = __salt__['setup_os.gen_pwd']()
  v_retval += 'mysql password:' + v_mysql_password + '\n'

  v_cmd = d_cmd_list['setup_mysql56'].format(mysql_home=v_mysql_home,mysql_password=v_mysql_password)
  v_cmd_out = _salt_cmd_run_stdout(v_cmd)
  v_retval += v_cmd_out + '\n'

  return v_retval



def setup_mysql57():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' install_mysql5dot67_on_redhat67.setup_mysql57
  '''

  v_retval = ''
  v_mysql_home = __grains__['mysql_home']

  v_mysql_password = __salt__['setup_os.gen_pwd']()
  v_retval += 'mysql password:' + v_mysql_password + '\n'

  v_cmd = d_cmd_list['setup_mysql57'].format(mysql_home=v_mysql_home,mysql_password=v_mysql_password)
  v_cmd_out = _salt_cmd_run_stdout(v_cmd)
  v_retval += v_cmd_out + '\n'

  return v_retval
