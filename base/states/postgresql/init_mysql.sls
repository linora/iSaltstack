################################################################################################
# Title           :init_mysql.sls
# Description     :The script will install & startup & setup mysql.
# Author	  :linora
# Date            :2018/01/10
# Version         :0.1
# Usage	          :salt 'none' state.sls mysql.init_mysql
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action			风险		    其他说明
# 安装MySQL                     低              
# 设置MySQL                 	中                  直接替换mysql.user表对应文件
# 启动MySQL                     无
# 验证安装                      无                  输出安装结果
################################################################################################
# 变量定义

{% set mysql_home     = grains['mysql_home'] %}
{% set mysql_version  = grains['mysql_version'] %}
{% set os_family      = grains['os_family'] %}

{% set mysql_pkgs_dir = '/tmp/mysql_db' %}

################################################################################################
# 程序主体
# 1. 安装MySQL

install_mysql:
  cmd.script:
    - name: /tmp/install.sh
    - source: salt://mysql/shell/install.sh
    - runas: root
    - shell: /bin/bash
    - env:
      - mysql_home: {{ mysql_home }}
      - mysql_pkgs_dir: {{ mysql_pkgs_dir }} 


# 2. 设置MySQL
{% if mysql_version == 6 %}
  {% set db_ver = '5.6.37' %}
{% else %}
  {% set db_ver = '5.7.20' %}
{% endif %}

{% for idx in ['frm','MYD','MYI']: %}
sync_user_table_{{ idx }}:
  file.managed:
    - name: {{ mysql_home }}/data_dir/mysql/user.{{ idx }}
    - source: 'salt://mysql/mysql_data/user.{{idx}}.{{db_ver}}'
    - user: mysql
    - group: mysql
    - mode: 640
{% endfor %}


# 3. 启动MySQL 
start_mysql:
  cmd.run:
    - name: "groupmod -g 1001 mysql;
             usermod  -u 1001 -g 1001 mysql;
             service  mysql restart || service mysqld restart;
             true     > {{ mysql_home }}/err.log;
             service  mysql restart || service mysqld restart;"
    - timeout: 10


# 4. 验证安装
{% if os_family == 'Debian' %}
install_strings4Debian:
  pkg.installed:
    - name: binutils
{% endif %}

verify_MySQL_install:
  cmd.run:
  - name: "strings {{ mysql_home }}/data_dir/mysql/user.MYD;
           service mysql status || service mysqld status;
           egrep   -i '(error|fatal|warning)' {{ mysql_home }}/err.log |\
           grep    -iv 'skip-name-resolve';"
