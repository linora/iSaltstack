################################################################################################
# Title           :init_postgresql.sls
# Description     :The script will install & startup & setup postgresql.
# Author	  :linora
# Date            :2018/02/05
# Version         :0.1
# Usage	          :salt 'none' state.sls postgresql.init_postgresql
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action			风险		    其他说明
# 安装postgresql                低              
# 设置postgresql                中                  直接替换postgresql.conf及pg_hba.conf文件
# 启动postgresql                无
# 验证安装                      无                  输出安装结果
################################################################################################
# 变量定义

{% set pg_data        = grains['pg_data'] %}
{% set os_family      = grains['os_family'] %}

################################################################################################
# 程序主体
# 1. 安装postgresql
install_postgresql:
  cmd.script:
    - name: /tmp/install.sh
    - source: salt://postgresql/shell/install.sh
    - runas: root
    - shell: /bin/bash
    - env:
      - PG_DATA: {{ pg_data }}


# 2. 设置postgresql
sync_pg_hba_conf:
  file.managed:
    - name: {{ pg_data }}/pg_hba.conf
    - source: 'salt://postgresql/jinja2/pg_hba.j2'
    - user: postgres 
    - group: postgres
    - mode: 640
    - template: jinja


sync_postgresql_conf:
  file.managed:
    - name: {{ pg_data }}/postgresql.conf
    - source: 'salt://postgresql/jinja2/postgresql.j2'
    - user: postgres
    - group: postgres
    - mode: 640
    - template: jinja


# 3. 启动postgresql
start_postgresql:
  cmd.run:
    - name: "groupmod -g 1003 postgres;
             usermod  -u 1003 -g 1003 postgres;
             chown -R postgres:postgres /app/postgresql/*;
             service  postgresql-10 restart"
    - timeout: 10


# 4. 验证安装
verify_PostgreSQL_install:
  cmd.run:
  - name: "service postgresql-10 status;
           egrep -i '(error|warn|fatal|criti)' {{ pg_data }}/pg_log/*.csv"
