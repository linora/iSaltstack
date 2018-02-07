################################################################################################
# Title           :dist_mariadb_files.sls
# Description     :The script will distribution require files before mairadb install.
# Author	      :linora
# Date            :2018/02/07
# Version         :0.1
# Usage	          :salt 'none' state.sls mariadb.dist_mariadb_files
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.3-1.el7
################################################################################################
# Action			            风险		    其他说明
# my.cnf分发                    无            
# mariadb yum reposity分发            无
################################################################################################
# 变量定义

{% set os              = grains['os'] %}
{% set os_family       = grains['os_family'] %}
{% set osmajorrelease  = grains['osmajorrelease'] | int %}
{% set osarch          = grains['osarch'] %}

{% set pkg_home        = 'salt://resources/mysql/pkgs/' %}

################################################################################################
# 程序主体
# 1. my.cnf分发

dist_my_cnf:
  file.managed:
    - name: /tmp/my.cnf
    - source: salt://mariadb/jinja2/my.j2
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - replace: True


# 2. mariadb yum reposity分发

dist_mariadb_repo:
  file.managed:
    - name: /etc/yum.repos.d/mariadb.repo 
    {% if   os == 'RedHat' and os_family == 'RedHat' and osmajorrelease == 6 and osarch == 'x86_64' %}
    - source: salt://mariadb/repo/mariadb_rhel6.repo
    {% elif os == 'RedHat' and os_family == 'RedHat' and osmajorrelease == 7 and osarch == 'x86_64' %}
    - source: salt://mariadb/repo/mariadb_rhel7.repo
    {% elif os == 'CentOS' and os_family == 'RedHat' and osmajorrelease == 6 and osarch == 'x86_64' %}
    - source: salt://mariadb/repo/mariadb_centos6.repo
    {% elif os == 'CentOS' and os_family == 'RedHat' and osmajorrelease == 7 and osarch == 'x86_64' %}
    - source: salt://mariadb/repo/mariadb_centos7.repo
    {% else %}
    - source: none
    {% endif %}
    - user: root
    - group: root
    - mode: 640
    - replace: True
