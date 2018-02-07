################################################################################################
# Title           :setup_os4install.sls
# Description     :The script will setup os before mariadb install.
# Author	      :linora
# Date            :2018/02/07
# Version         :0.1
# Usage	          :salt 'none' state.sls  mariadb.setup_os4install
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.3-1.el7
################################################################################################
# Action			        风险		        其他说明
# sysctl配置                低
# limits.conf配置        	无
# hugepages配置           	中                  配置hugepages时会预先抢占内存资源
################################################################################################
# 变量定义
{% set l_sysctl = [
  ['vm.swappiness',                 '10'],
  ['net.ipv4.tcp_max_syn_backlog',  '4096'],
  ['fs.file-max',                   '6815744'],
  ['fs.aio-max-nr',                 '1048576'],
  ['kernel.shmmax',                 '18446744073692774399'],
  ['kernel.shmall',                 '18446744073692774399'],
  ['kernel.sem',                    '250 32000 100 128'],
  ['net.ipv4.ip_local_port_range',  '1024 65000'],
  ['net.core.rmem_default',         '262144'],
  ['net.core.rmem_max',             '4194304'],
  ['net.core.wmem_default',         '26214'],
  ['net.core.wmem_max',             '1048576']
]
%}

{% set if_use_large_page  = grains['large_pages'] %}
{% set large_page_numbers = grains['huge_pages_number'] %}
{% if if_use_large_page == 1 %}
    {% set l_sysctl =  l_sysctl +
                       [
                         ['vm.nr_hugepages',       large_page_numbers],
                         ['vm.hugetlb_shm_group',  '1001']
		       ] 
    %}
{% endif %}

{% set l_limits_conf = [
  ['mysql  +soft +nproc +2047',                     'mysql              soft    nproc      2047'],
  ['mysql  +hard +nproc +16384',                    'mysql              hard    nproc      16384'],
  ['mysql  +soft +nofile +10240',                   'mysql              soft    nofile     10240'],
  ['mysql  +hard +nofile +65536',                   'mysql              hard    nofile     65536'],
  ['mysql  +soft +memlock +unlimited',              'mysql              soft    memlock    unlimited'],
  ['mysql  +hard +memlock +unlimited',              'mysql              hard    memlock    unlimited']
]
%}

################################################################################################
# 程序主体
# 1. sysctl配置 

{% for idx in l_sysctl: %}
{{idx[0]}}:
  sysctl.present:
    - value: {{idx[1]}}
{% endfor %}


# 2. limits.conf配置
{% for idx in l_limits_conf: %}
{{idx[1]}}:
  file.replace:
    - name: "/etc/security/limits.conf"
    - pattern: "{{idx[0]}}"
    - repl: "{{idx[1]}}"
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True
{% endfor%}


# 3. hugepages配置
{% if if_use_large_page == 1 %}
disable_transparent_hugepage:
  file.replace:
    - name: "/etc/rc.local"
    - pattern: "if.*test.*-f.*sys.*kernel.*mm.*transparent_hugepage.*enabled.*"
    - repl: "if test -f /sys/kernel/mm/transparent_hugepage/enabled; then echo never > /sys/kernel/mm/transparent_hugepage/enabled; fi"
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True
{% endif %}
