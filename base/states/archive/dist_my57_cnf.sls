/tmp/my.cnf:
  file.managed:
    - source: 
      - salt://jinja2/my57_cnf.j2
    - name: /tmp/my.cnf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
