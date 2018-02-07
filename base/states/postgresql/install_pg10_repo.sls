################################################################################################
# Title           :install_pg10_repo.sls
# Description     :The script will install pg10 reposity.
# Author	      :linora
# Date            :2018/02/01
# Version         :0.1
# Usage	          :salt 'none' state.sls postgresql.install_pg10_repo
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.3-1.el7
################################################################################################
# Action			            风险		        其他说明
# postgresql.conf分发           无                  debug 用 
# pg10 yum reposity install     无
# pg_hba.conf分发               无                  debug 用
################################################################################################
# 变量定义
{% set os              = grains['os'] %}
{% set os_family       = grains['os_family'] %}
{% set osmajorrelease  = grains['osmajorrelease'] | int %}
{% set osarch          = grains['osarch'] %}
################################################################################################
# 程序主体
# 1. postgresql.conf分发

{% if os_family == 'RedHat' and osmajorrelease in(6,7) and osarch == 'x86_64' %}
dist_postgresql_conf:
  file.managed:
    - name: /tmp/postgresql.conf
    - source: salt://postgresql/jinja2/postgresql.j2
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


# 2. postgresql 10 yum reposity安装
install_postgresql10_yum_reposity:
  cmd.run:
    {% if   os == 'CentOS' and osmajorrelease == 7 %}
    - name: "yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-1.noarch.rpm"
    {% elif os == 'CentOS' and osmajorrelease == 6 %}
    - name: "yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-6-x86_64/pgdg-centos10-10-1.noarch.rpm"
    {% elif os == 'RedHat' and osmajorrelease == 7 %}
    - name: "yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-redhat10-10-1.noarch.rpm"
    {% else %}
    - name: "yum install -y https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-6-x86_64/pgdg-redhat10-10-1.noarch.rpm"
    {% endif %}
    - require:
      - file: dist_postgresql_conf


# 3. pg_hba.conf分发
dist_pg_hba_conf:
  file.managed:
    - name: /tmp/pg_hba.conf
    - source: salt://postgresql/jinja2/pg_hba.j2
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - replace: True
    - require:
      - file: dist_postgresql_conf
