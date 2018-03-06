################################################################################################
# Title           :precheck4install.sls
# Description     :The script will pre check requirements before mariadb install.
# Author	      :linora
# Date            :2018/02/07
# Version         :0.1
# Usage	          :salt 'none' state.sls mariadb.precheck4install
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.3-1.el7
################################################################################################
# Action			            风险		    其他说明
# 操作系统检查			        无
# 是否存在运行中的mysqld进程	无
# 是否存在已安装的mariadb包	    无
# MariaDB安装目录是否挂载       无
################################################################################################
# 变量定义
{% set os_family        = grains['os_family'] %}
{% set osmajorrelease   = grains['osmajorrelease'] | int %}
{% set osarch           = grains['osarch'] %}

{% set mariadb_home       = grains['mariadb_home'] %}

################################################################################################
# 程序主体
if_postmaster_running:
  cmd.run:
    - name: "test $(ps -ef | grep -i postmaster | grep -v grep | wc -l) -eq 0 || \
             (echo 'postmaster runniung,please check the vm.hugetlb_shm_group setting!' ; false)"


# 1. 操作系统检查

os_support_check:
{% if os_family == 'RedHat' and osarch == 'x86_64' and osmajorrelease in(6,7) %}
  cmd.run:
    - name: test 1 -eq 1
    - require:
      - cmd: if_postmaster_running
{% else %}
  cmd.run:
    - name: test 1 -eq 0 
{% endif %}


# 2. 是否存在运行中的mysqld进程
if_mysqld_running:
  cmd.run:
    - name: test $(ps -ef | grep -i mysqld | grep -v grep | wc -l) -eq 0
    - require:
      - cmd: os_support_check


# 3. 是否存在已安装的MySQL包
if_installed_mysql:
  cmd.run:
    - name: test $(rpm -qa | egrep -i '^(mysql|mariadb)'     | wc -l) -eq 0
    - require:
      - cmd: if_mysqld_running


# 4. MySQL安装目录是否挂载
if_exists_mariadb_home:
  file.exists:
  - name: '{{mariadb_home}}'
  - require:
    - cmd: if_installed_mysql
