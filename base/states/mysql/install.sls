include:
  # 预检查
  - mysql.precheck4install
  # 设置OS最优化
  - mysql.setup_os4install
  # 分发MySQL安装文件
  - mysql.dist_mysql_files
  # 初始化MySQL
  - mysql.init_mysql

extend:
  #####################################################################
  # dist_mysql_files
  dist_my_tarball:
    module.run:
      - require:
        - cmd: rm_mysql_db_dir
        # precheck4install
        - file: if_exists_mysql_home 
  #####################################################################
  # init_mysql
  install_mysql:
    cmd.script:
      - require:
        # dist_mysql_files
        - dist_my_tarball
  sync_user_table_frm:
    file.managed:
      - require:
        # precheck4install
        - file: if_exists_mysql_home
  sync_user_table_MYI:
    file.managed:
      - require:
        # precheck4install
        - file: if_exists_mysql_home
  sync_user_table_MYD:
    file.managed:
      - require:
        # precheck4install
        - file: if_exists_mysql_home
  #####################################################################
