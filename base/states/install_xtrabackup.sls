{% import './jinja2/common.j2' as common %}


install_xtrabackup_deps_pkgs:
  pkg.installed:
{% if common.os_family == 'RedHat' and common.osarch == 'x86_64'   and common.osmajorrelease == 7 %}
    - pkgs:
      - perl-Digest-MD5
      - libev.x86_64
{% elif common.os_family == 'RedHat' and common.osarch == 'x86_64' and common.osmajorrelease == 6 %}
    - sources:
      - libev: salt://{{ common.pkg_home + '/' + 'libev-4.15-1.el6.rf.x86_64.rpm' }}
{% else %}
    - sources:
      - None
{% endif %}


install_xtrabackup_pkgs:
  pkg.installed:
    - sources:
{% if common.os_family == 'RedHat' and common.osarch == 'x86_64'   and common.osmajorrelease == 7 %}
      - percona-xtrabackup-24: salt://{{ common.pkg_home + '/' + 'percona-xtrabackup-24-2.4.8-1.el7.x86_64.rpm' }}
{% elif common.os_family == 'RedHat' and common.osarch == 'x86_64' and common.osmajorrelease == 6 %}
      - percona-xtrabackup-24: salt://{{ common.pkg_home + '/' + 'percona-xtrabackup-24-2.4.8-1.el6.x86_64.rpm' }}
{% else %}
      - None 
{% endif %} 
    - require:
      - pkg: install_xtrabackup_deps_pkgs 


{{ common.backup_home }}:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedires: True
    - require: 
      - pkg: install_xtrabackup_pkgs 


{{ common.script_home }}:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedires: True


{{ common.script_home + '/backup' }}:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedires: True 


{{ common.script_home + '/backup/mysql_backup_job.sh'}}:
  file.managed:
    - source: salt://jinja2/mysql_backup_job.j2
    - user: root
    - group: root
    - mode: 700
    - template: jinja


{{ common.script_home + '/backup/mysql_backup_monitor_db_lock.sh'}}:
  file.managed:
    - source: salt://jinja2/mysql_backup_monitor_db_lock.j2
    - user: root
    - group: root
    - mode: 700
    - template: jinja


{{ common.script_home + '/backup/mysql_backup_monitor_disk.sh'}}:
  file.managed:
    - source: salt://jinja2/mysql_backup_monitor_disk.j2
    - user: root
    - group: root
    - mode: 700
    - template: jinja


{{ common.script_home + '/backup/wechat_priv.py'}}:
  file.managed:
    - source: salt://python/wechat_priv.py
    - user: root
    - group: root
    - mode: 600 


{{ common.script_home + '/backup/mysql_backup_monitor_disk.sh 2>/dev/null' }}:
  cron.present:
    - user: root
    - minute: 50 
    - hour: 20


{{ common.script_home + '/backup/mysql_backup_monitor_db_lock.sh 2>/dev/null ' }}:
  cron.present:
    - user: root
    - minute: 50 
    - hour: 20


{{ common.script_home + '/backup/mysql_backup_job.sh 2>/dev/null' }}:
  cron.present:
    - user: root
    - minute: 0 
    - hour: 21