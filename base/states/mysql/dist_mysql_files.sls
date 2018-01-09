################################################################################################
# Title           :dist_mysql_files.sls
# Description     :The script will distribution mysql install require files before mysql install.
# Author	  :linora
# Date            :2018/01/09
# Version         :0.1
# Usage	          :salt 'none' state.sls mysql.dist_mysql_files
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action			风险		    其他说明
# my.cnf分发                    无            
# mysql tar ball分发            无
################################################################################################
# 变量定义

{% set mysql_version = grains['mysql_version'] %}

################################################################################################
# 程序主体
# 1. my.cnf分发

{% if   mysql_version == 6 %}
dist_my_cnf:
  file.managed:
    - name: /tmp/my.cnf
    - source: salt://mysql/jinja2/my56_cnf.j2
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - replace: True
{% elif mysql_version == 7 %}
dist_my_cnf:
  file.managed:
    - name: /tmp/my.cnf
    - source: salt://mysql/jinja2/my56_cnf.j2
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - replace: True
{% else %}
not_support_version:
  cmd.run:
    - name: test 1 -eq 0
{% endif %}


# 2. mysql tar ball分发
rm_mysql_db_dir:
  cmd.run:
    - name: rm -rf /tmp/mysql_db
    - require:
      - file: dist_my_cnf

dist_my_tarball:
  module.run:
    - name: cp.get_file
    - path: 'salt://resources/mysql/pkgs/mysql-server_5.6.37-1ubuntu14.04_amd64.deb-bundle.tar'
    - dest: /tmp/mysql_db/mysql.tar 
    - makedirs: True
    - require:
      - cmd: rm_mysql_db_dir
