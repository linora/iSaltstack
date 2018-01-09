################################################################################################
# Title           :precheck4install.sls
# Description     :The script will pre check before mysql install.
# Author	  :linora
# Date            :2018/01/09
# Version         :0.1
# Usage	          :salt 'none' state.sls mysql.precheck4install
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action			风险		    其他说明
# 操作系统检查			无
# 是否存在运行中的mysqld进程	无
# 是否存在已安装的MySQL包	无
# MySQL安装目录是否挂载         无
################################################################################################
# 变量定义
{% set os_family        = grains['os_family'] %}
{% set osarch           = grains['osarch'] %}
{% set osmajorrelease   = grains['osmajorrelease'] %}

{% set mysql_home       = grains['mysql_home'] %}

################################################################################################
# 程序主体
# 1. 操作系统检查

{% if (os_family == 'RedHat' and osarch == 'x86_64' and osmajorrelease in(6,7)) or
      (os_family == 'Debian' and osarch == 'amd64'  and osmajorrelease in(14,))
      %}
os_support_check:
  cmd.run:
    - name: test 1 -eq 1
{% else %}
os_support_check:
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
    {% if os_family == 'Debian' %}
    - name: test $(dpkg -l | egrep -i '^ii +(mysql|mariadb)' | wc -l) -eq 0
    {% else %}
    - name: test $(rpm -qa | egrep -i '^(mysql|mariadb)'     | wc -l) -eq 0
    {% endif %}
    - require:
      - cmd: if_mysqld_running


# 4. MySQL安装目录是否挂载
if_exists_mysql_home:
  file.exists:
  - name: '{{mysql_home}}'
  - require:
    - cmd: if_installed_mysql 
