################################################################################################
# Title           :init_mariadb.sls
# Description     :The script will install & startup & setup mariadb.
# Author	      :linora
# Date            :2018/02/07
# Version         :0.1
# Usage	          :salt 'none' state.sls mariadb.init_mariadb
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.3-1.el7
################################################################################################
# Action			            风险		        其他说明
# 安装mariadb                     低              
# 设置mariadb                 	中                  直接替换mysql.user表对应文件
# 启动mariadb                     无
# 验证安装                      无                  输出安装结果
################################################################################################
# 变量定义

{% set os_family      = grains['os_family'] %}
{% set mysql_home     = grains['mariadb_home'] %}

################################################################################################
# 程序主体
# 1. 安装mariadb

install_mariadb:
  cmd.script:
    - name: /tmp/install.sh
    - source: salt://mariadb/shell/install.sh
    - runas: root
    - shell: /bin/bash
    - env:
      - mariadb_home: {{ mysql_home }}


# 2. 设置mariadb

{% for idx in ['frm','MYD','MYI']: %}
sync_user_table_{{ idx }}:
  file.managed:
    - name: {{ mysql_home }}/data_dir/mysql/user.{{ idx }}
    - source: 'salt://mariadb/mysql_data/user.{{idx}}'
    - user: mysql
    - group: mysql
    - mode: 640
{% endfor %}


# 3. 启动MySQL 
start_mariadb:
  cmd.run:
    - name: "groupmod -g 1001 mysql;
             usermod  -u 1001 -g 1001 mysql;
             service  mysql restart || service mysqld restart;
             true     > {{ mysql_home }}/err.log;
             service  mysql restart || service mysqld restart;"
    - timeout: 10


# 4. 验证安装
verify_MySQL_install:
  cmd.run:
  - name: "strings {{ mysql_home }}/data_dir/mysql/user.MYD;
           service mysql status || service mysqld status;
           egrep   -i '(error|fatal|warning)' {{ mysql_home }}/err.log |\
           grep    -iv 'skip-name-resolve';"
