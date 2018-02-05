################################################################################################
# Title           :install_pg10_repo.sls
# Description     :The script will install pg10 reposity.
# Author	  :linora
# Date            :2018/02/01
# Version         :0.1
# Usage	          :salt 'none' state.sls postgresql.install_pg10_repo
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action			风险		    其他说明
# postgresql.conf分发           无            
# pg_hba.conf分发               无
# pg10 yum reposity install     无
################################################################################################
# 变量定义

{% set osmajorrelease  = grains['osmajorrelease'] %}
{% set os_family       = grains['os_family'] %}

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
    - dest: /tmp/mysql_db/mysql.tar 
    {% if osmajorrelease == 7      and mysql_version == 7 %}
    - path: {{ pkg_home }}/mysql-5.7.20-1.el7.x86_64.rpm-bundle.tar
    {% elif osmajorrelease == 7    and mysql_version == 6 %}
    - path: {{ pkg_home }}/MySQL-5.6.37-1.el7.x86_64.rpm-bundle.tar
    {% elif os_family == 'Debian'  and mysql_version == 7 %}
    - path: {{ pkg_home }}/mysql-server_5.7.20-1ubuntu14.04_amd64.deb-bundle.tar
    {% elif os_family == 'Debian'  and mysql_version == 6 %}
    - path: {{ pkg_home }}/mysql-server_5.6.37-1ubuntu14.04_amd64.deb-bundle.tar
    {% elif osmajorrelease == 6    and mysql_version == 7 %}
    - path: {{ pkg_home }}/mysql-5.7.20-1.el6.x86_64.rpm-bundle.tar
    {% else %}
    - path: {{ pkg_home }}/MySQL-5.6.37-1.el6.x86_64.rpm-bundle.tar
    {% endif %}
    - makedirs: True
    - require:
      - cmd: rm_mysql_db_dir
