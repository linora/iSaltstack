【兼容性】

1. 数据库
  mariadb 10.2 

2. 操作系统
  CentOS/RedHat 6.x
  CentOS/RedHat 7.x

【文档结构说明】

说明文档目录：        Docs/
jinja2模板目录：      jinja2/
MySQL相关文件目录：   mariadb_data/
shell脚本目录：       shell/
配置文件目录：        config/
yum repo模板：        repo/
安装包分发：          dist_mariadb_files.sls
MySQL初始化：         init_mariadb.sls
top.sls：             init.sls
执行MySQL安装：       install.sls
执行预检查：          precheck4install.sls
操作系统配置：        setup_os4install.sls


【使用说明】

1. MariaDB安装

# 目标服务器（正则）
TARGET_HOST='none'

# 配置config/install.init参数

# 设置参数到grains items
salt "${TARGET_HOST}" grains.setvals "$(cat config/install.ini)"

# 执行安装
state "${TARGET_HOST}" state.sls mariadb.install

【其他说明】
# 其他sls文件都可以单独执行（init.sls除外，暂时示使用top.sls特性）
