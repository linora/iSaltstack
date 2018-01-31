#!/usr/bin/env bash

# 设置目标主机
TARGET_HOST=$1
MYSQL_HOME=$2
BUFFER_POOL_RATIO=$3
CHUNK_COUNT=$4
MYSQL_VERSION=$5
SERVER_ID=$6
LARGE_PAGES=$7
HUGE_PAGES_NUMBER=$8

# 设置参数到grains items
salt "${TARGET_HOST}" grains.setvals "{
  'mysql_home':          '${MYSQL_HOME}',  # mysql安装目录
  'buffer_pool_ratio':   ${BUFFER_POOL_RATIO},         # InnoDB buffer pool 占用内存大小
  'chunk_count':         ${CHUNK_COUNT},             # InnoDB buffer pool chunck count(一个chunck大小为128M，适用于5.7+)
  'mysql_version':       ${MYSQL_VERSION},             # MySQL 版本选择（6: 5.6.37  7: 5.7.20）
  'server_id':           ${SERVER_ID},             # 服务器ID
  'large_pages':         ${LARGE_PAGES},             # 是否启用hugepage（1：启用  2： 禁用）
  'huge_pages_number':   ${HUGE_PAGES_NUMBER}            # hugepages分配页数（一个page大小为2MB）
}
"

# 执行安装
salt --timeout=1200 "${TARGET_HOST}" state.sls mysql.install
