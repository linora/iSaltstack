【兼容性】

PostgreSQL 10.1

CentOS/RedHat 6.x
CentOS/RedHat 7.x

【文档结构说明】

yum reposity安装：install_pg10_repo.sls
说明文档目录：    Docs
postgresql安装：  init_postgresql.sls
top.sls：         init.sls
postgresql安装：  install.sls
jinja2模板目录：  jinja2
执行预检查：      precheck4install.sls
操作系统设置：    setup_os4install.sls
shell脚本目录：   shell
配置文件目录：    config

【使用说明】

# 目标服务器（正则）
TARGET_HOST='*'

# 配置config/install.init参数

# 设置参数到grains items
salt "${TARGET_HOST}" grains.setvals "$(cat config/install.ini)"

# 执行安装
state "${TARGET_HOST}" state.sls postgresql.install

【其他说明】
# 其他sls文件都可以单独执行（init.sls除外，暂时示使用top.sls特性）
