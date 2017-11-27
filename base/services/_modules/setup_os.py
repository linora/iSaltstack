# coding=utf-8
'''
  操作系统定制工具包

  敏感资源：

    1. 函数gen_pwd使用的密钥源，即字符串变量pwd_source
'''
#############################################################################################################################
# lib 包导入

from __future__ import absolute_import


# 导入原生 lib包
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

# 导入三方 lib包

# 导入私有 lib包
from os_cmd import d_cmd_list
from common import pwd_source

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

#############################################################################################################################
# 通用函数定义

def _salt_cmd_run_stdout(cmd,python_shell=True):
  return __salt__['cmd.run_stdout'](cmd,python_shell=python_shell)


#############################################################################################################################
# 功能函数定义

def disable_selinux():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.disable_selinux
  '''     
  v_cmd_stdout = _salt_cmd_run_stdout(d_cmd_list['disable_selinux'])
  return v_cmd_stdout


def other_setup():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.other_setup
  '''       
  v_cmd_stdout = _salt_cmd_run_stdout(d_cmd_list['other_setup'])
  return v_cmd_stdout


def setup_huge_pages():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.setup_huge_pages
  '''
  v_huge_pages_number = __grains__['huge_pages_number']
  v_cmd_stdout = _salt_cmd_run_stdout(d_cmd_list['setup_huge_pages'].format(huge_pages_number=v_huge_pages_number))
  return v_cmd_stdout


def init_firewalld_for_mysql():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.init_firewalld_for_mysql
  '''         
  v_cmd_stdout = _salt_cmd_run_stdout(d_cmd_list['init_firewalld_for_mysql'])
  return v_cmd_stdout
  

def add_rich_rule(ip,mask):
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.add_rich_rule 192.168.168.2 32
  '''           
  cmd = d_cmd_list['add_rich_rule'].format(ip=ip,mask=mask)
  v_cmd_stdout = _salt_cmd_run_stdout(cmd)
  return v_cmd_stdout


def remove_rich_rule(ip,mask):
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.remove_rich_rule 192.168.168.2 32
  '''             
  cmd = d_cmd_list['remove_rich_rule'].format(ip=ip,mask=mask) 
  v_cmd_stdout = _salt_cmd_run_stdout(cmd)
  return v_cmd_stdout


def firewall_cmd_list_all():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.firewall_cmd_list_all
  '''
  v_cmd_stdout = _salt_cmd_run_stdout(d_cmd_list['firewall_cmd_list_all'])
  return v_cmd_stdout


def init_iptables_for_mysql():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.init_iptables_for_mysql
  '''
  v_cmd_stdout = _salt_cmd_run_stdout(d_cmd_list['init_iptables_for_mysql'])
  return v_cmd_stdout


def add_iptables_rule(ip,mask):
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.add_iptables_rule 192.168.168.2 32
  '''    
  cmd = d_cmd_list['add_iptables_rule'].format(ip=ip,mask=mask)
  v_cmd_stdout = _salt_cmd_run_stdout(cmd)
  return v_cmd_stdout


def remove_iptables_rule(ip,mask):
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.remove_iptables_rule 192.168.168.2 32
  '''    
  cmd = d_cmd_list['remove_iptables_rule'].format(ip=ip,mask=mask)
  v_cmd_stdout = _salt_cmd_run_stdout(cmd)
  return v_cmd_stdout


def iptables_status():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.iptables_status
  '''
  v_cmd_stdout = _salt_cmd_run_stdout(d_cmd_list['iptables_status'])
  return v_cmd_stdout


def add_iptables_rule4minion(ip,mask):
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.add_iptables_rule4minion 192.168.168.2 32
  '''
  cmd = d_cmd_list['add_iptables_rule4minion'].format(ip=ip,mask=mask)
  v_cmd_stdout = _salt_cmd_run_stdout(cmd)
  return v_cmd_stdout


def gen_pwd():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.gen_pwd
  '''
  # 特殊符号放在seed最后，如果较少或者增加符号数量，则对应idx变量赋值部分也需要修改
  # 注意：不要加入$符号
  seed = pwd_source
  sa = []

  idx = random.choice(range(-6,0))

  for i in range(16):
    if i == -idx:
      sa.append(seed[idx])
    else:
      sa.append(random.choice(seed))

  salt = ''.join(sa)
  return salt


def mount_mysql_disk():
  '''
  CLI Example:

  .. code-block:: bash

      salt '*' setup_os.mount_mysql_disk
  '''
  disk_label = __grains__['mysql_disk_label']
  mysql_home = __grains__['mysql_home']

  v_fstab_info = _salt_cmd_run_stdout(d_cmd_list['fstab_info'])
  v_mount_info = _salt_cmd_run_stdout(d_cmd_list['mount_info'])
  current_storage_info = v_fstab_info + v_mount_info
  
  try:
    v_flag = current_storage_info.index(disk_label)
    return '错误：fstab或mount中已经存储磁盘{disk}信息！'.format(disk=disk_label)
  except Exception,e:
    cmd = d_cmd_list['mount_mysql_disk'].format(disk_label=disk_label,mysql_home=mysql_home) 
    v_cmd_stdout = _salt_cmd_run_stdout(cmd)

    v_fstab_info = _salt_cmd_run_stdout(d_cmd_list['fstab_info'])
    current_storage_info = '【fstab】：\n' + v_fstab_info

    return current_storage_info

