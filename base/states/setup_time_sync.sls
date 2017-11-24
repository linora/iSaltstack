{% set time_server = 'time.nist.gov' %}

install_ntpd:
  pkg.installed:
    - name: install_ntpd
    - pkgs:
      - ntpdate 



/usr/sbin/ntpdate {{ time_server }};hwclock --systohc:
  cron.present:
    - user: root
    - minute: '*/5'
    - require:
      - pkg: install_ntpd
