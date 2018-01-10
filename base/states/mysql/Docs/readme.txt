【兼容性】

mysql 5.6.37
mysql 5.7.20

Ubuntu 14.04
CentOS 6.x
CentOS 7.x

【文档结构说明】

安装包分发：      dist_mysql_files.sls
说明文档目录：    Docs
MySQL安装：       init_mysql.sls
top.sls：         init.sls
MySQL安装：       install.sls
jinja2模板目录：  jinja2
MySQL相关文件：   mysql_data
执行预检查：      precheck4install.sls
操作系统设置：    setup_os4install.sls
shell脚本目录：   shell

【使用说明】

# 执行MySQL安装
state 'none' state.sls mysql.install

# 其他sls文件都可以单独执行（init.sls除外，暂时示使用top.sls特性）
