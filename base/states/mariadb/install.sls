include:
  # 预检查
  - mariadb.precheck4install
  # 设置OS最优化
  - mariadb.setup_os4install
  # 分发MySQL安装文件
  - mariadb.dist_mariadb_files
  # 初始化MySQL
  - mariadb.init_mariadb

extend:
  #####################################################################
  # dist_mariadb_files
  dist_mariadb_repo:
    file.managed:
      - require:
        # precheck4install
        - file: if_exists_mariadb_home
  #####################################################################
  # init_mariadb
  install_mariadb:
    cmd.script:
      - require:
        # dist_mariadb_files
        - dist_mariadb_repo
  sync_user_table_frm:
    file.managed:
      - require:
        # precheck4install
        - file: if_exists_mariadb_home
  sync_user_table_MYI:
    file.managed:
      - require:
        # precheck4install
        - file: if_exists_mariadb_home
  sync_user_table_MYD:
    file.managed:
      - require:
        # precheck4install
        - file: if_exists_mariadb_home
  #####################################################################
