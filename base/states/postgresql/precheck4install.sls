################################################################################################
# Title           :precheck4install.sls
# Description     :The script will pre check before postgresql install.
# Author	  :linora
# Date            :2018/02/05
# Version         :0.1
# Usage	          :salt 'none' state.sls postgresql.precheck4install
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action			    风险		    其他说明
# 操作系统检查			    无
# 是否存在运行中的postgresql进程    无
# 是否存在已安装的postgresql包	    无
# postgresql安装目录是否挂载        无
################################################################################################
# 变量定义
{% set os_family        = grains['os_family'] %}
{% set osmajorrelease   = grains['osmajorrelease'] | int %}
{% set osarch           = grains['osarch'] %}

{% set pg_data          = grains['pg_data'] %}

################################################################################################
# 程序主体
if_mysqld_running:
  cmd.run:
    - name: "test $(ps -ef | grep -i mysqld | grep -v grep | wc -l) -eq 0 || \
             (echo '存在运行中的mysqld进程，请手动检查vm.hugetlb_shm_group设置！' ; false)"


# 1. 操作系统检查

{% if os_family == 'RedHat' and osmajorrelease in(6,7) and osarch == 'x86_64' %}
os_support_check:
  cmd.run:
    - name: test 1 -eq 1
    - require:
      - cmd: if_mysqld_running
{% else %}
os_support_check:
  cmd.run:
    - name: test 1 -eq 0 
{% endif %}


# 2. 是否存在运行中的postgresql进程
if_postmaster_running: 
  cmd.run:
    - name: "test $(ps -ef | grep -i postmaster | grep -v grep | wc -l) -eq 0" 
    - require:
      - cmd: os_support_check


# 3. 是否存在已安装的postgresql包
if_installed_postgresql:
  cmd.run:
    - name: test $(rpm -qa | egrep -i '^postgresql' | wc -l) -eq 0
    - require:
      - cmd: if_postmaster_running


# 4. postgresql安装目录是否挂载
if_exists_postgresql_data_home:
  file.exists:
  - name: '{{pg_data}}'
  - require:
    - cmd: if_installed_postgresql
