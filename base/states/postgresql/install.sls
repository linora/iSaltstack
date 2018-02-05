include:
  # 预检查
  - postgresql.precheck4install
  # 设置OS最优化
  - postgresql.setup_os4install
  # 安装postgresql 10 yum reposity
  - postgresql.install_pg10_repo
  # 初始化MySQL
  - postgresql.init_postgresql

extend:
  #####################################################################
  # setup_os4install
  {% if grains['large_pages'] == 1 %}
  vm.hugetlb_shm_group:
    sysctl.present:
      - require:
        - cmd: if_mysqld_running
  {% endif %}
  #####################################################################
  # init_postgresql
  install_postgresql:
    cmd.script:
      - require:
        # precheck4install
        - if_exists_postgresql_data_home
  sync_pg_hba_conf:
    file.managed:
      - require:
        # precheck4install
        - if_exists_postgresql_data_home
  sync_postgresql_conf:
    file.managed:
      - require:
        # precheck4install
        - if_exists_postgresql_data_home
  start_postgresql:
    cmd.run:
      - require:
        # precheck4install
        - if_exists_postgresql_data_home
  #####################################################################
