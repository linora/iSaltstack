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

# 目标服务器（正则）
TARGET_HOST='master'

# 指定将安装MySQL 版本：6 - mysql 5.6.37
#                     7 - mysql 5.7.20
MYSQL_VERSION='7'

# MySQL 安装目标目录（不能指定为/var/lib/mysql，否则会触发MySQL bug）
MYSQL_HOME='your_data_home'

# MySQL server_id 定义
SERVER_ID=0
###################################################################
# 二选一

# 指定 MySQL buffer pool 占总内存大小百分比
BUFFER_POOL_RATIO=0.125

# mysql 5.7中一个chunk为128M，Buffer pool大小为CHUNCK_COUNT * 128M
CHUNK_COUNT=2

###################################################################

# 指定MySQL是否使用large page特性(内存大于64GB时建设开启)：1 - 启用
#                                                     0 - 禁用
LARGE_PAGES=0

# 指定OS huge pages分配数量，默认一个page size为2MB
HUGE_PAGES_NUMBER=512

# 设置grains
salt "${TARGET_HOST}" grains.setvals "{'mysql_home':\"${MYSQL_HOME}\",
                                       'buffer_pool_ratio':${BUFFER_POOL_RATIO},
                                       'chunk_count': ${CHUNK_COUNT},
                                       'mysql_version':${MYSQL_VERSION},
                                       'server_id':${SERVER_ID},
                                       'large_pages':${LARGE_PAGES},
                                       'huge_pages_number':${HUGE_PAGES_NUMBER}}"

state 'none' state.sls mysql.install

【其他说明】
# 其他sls文件都可以单独执行（init.sls除外，暂时示使用top.sls特性）
