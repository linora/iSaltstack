# coding=utf-8
'''
  存储工具包
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

# 导入Saltstack lib包
import salt
import salt.utils
import salt.version
import salt.loader
import salt.ext.six as six
from salt.utils.decorators import depends

# 导入私有 lib包

from os_cmd import d_cmd_list

#############################################################################################################################
# 通用变量定义

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
# 通用函数定义

def _salt_cmd_run_stdout(cmd, python_shell=True):
    return __salt__['cmd.run_stdout'](cmd, python_shell=python_shell)


#############################################################################################################################
# 功能函数定义
def disk_info():
    '''
      CLI Example:

      .. code-block:: bash

          salt '*' storage_tools.disk_info
    '''
    v_disk_info = _salt_cmd_run_stdout(d_cmd_list['disk_info'])
    return v_disk_info


def all_disk_info():
    '''
      CLI Example:

      .. code-block:: bash

          salt '*' storage_tools.all_disk_info
    '''
    v_disk_info = _salt_cmd_run_stdout(d_cmd_list['all_disk_info'])
    return v_disk_info


def fstab_info():
    '''
      CLI Example:

      .. code-block:: bash

          salt '*' storage_tools.fstab_info
    '''
    v_fstab_info = _salt_cmd_run_stdout(d_cmd_list['fstab_info'])
    return v_fstab_info


def mount_info():
    '''
      CLI Example:

      .. code-block:: bash

          salt '*' storage_tools.mount_info
    '''
    v_mount_info = _salt_cmd_run_stdout(d_cmd_list['mount_info'])
    return v_mount_info


def set_all_disk_scheduler_deadline():
    '''
      CLI Example:

      .. code-block:: bash

          salt '*' storage_tools.set_all_disk_scheduler_deadline
    '''
    v_cmd_stdout = _salt_cmd_run_stdout(d_cmd_list['set_all_disk_scheduler_deadline'])
    return v_cmd_stdout
