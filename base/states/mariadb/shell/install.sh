#!/bin/bash
################################################################################################
# Title           :install.sh
# Description     :The script will execute by init_mariadb.sls in target servers.
# Author          :linora
# Date            :2018/02/07
# Version         :0.1
# Usage	          :salt 'none' state.sls mariadb.init_mariadb
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action	        风险	        其他说明
# 安装mariadb依赖包    无
# 卸载mariadb冲突包    无
# 清除mariadb相关文件  无
# 安装mariadb包        无
# 重新初始化mariadbv   无              重新初始化为/etc/my.cnf文件中目录结构（最佳实践），参数最优化
# 停止mariadb          无
################################################################################################

mysql_home="${mysql_home}"


# 函数：居中显示信息
myPrint() {
        STR="$1"; 
        printf '||||%24s%-24s|||\n' \
        "$(echo $STR | cut -c 1-$((${#STR}/2)))" \
        "$(echo $STR | cut -c $((${#STR}/2+1))-${#STR})";
}


myPrint    'Install deps PKGs:'
yum     install -y libaio  libaio-devel

myPrint    'Uninstall mariadb conflit PKGs:'
rpm     -e     --nodeps   mariadb-libs mysql-libs

myPrint    'Clean mysql files:'
rm -f  /var/lib/mysql/RPM_UPGRADE_MARKER
rm -rf /etc/mysql
rm -rf /etc/my.cnf*
rm -rf /usr/my.cnf*

myPrint    'Install mariadb PKGs:'
yum install --enablerepo=mariadb -y mariadb-server mariadb-client

myPrint    'Stop mysql:'
service mysql  stop ||\
service mysqld stop

myPrint    'Create dirs for MySQL:'
test ! -z $mysql_home && test -d $mysql_home && (
mkdir -p $mysql_home/{binlog_dir,data_dir,innodb_data,tmp_dir,innodb_log,undo_dir,innodb_tmpdir}
chown -R mysql:mysql $mysql_home/

myPrint    'Reconfigure my.cnf:'
\cp -f /tmp/my.cnf /etc/my.cnf
# sed -i '/innodb_buffer_pool_size/s/.0M/M/g' /etc/my.cnf

myPrint    'Init MySQL db:'
rm -rf /etc/mysql
mysql_install_db --defaults-file=/etc/my.cnf ||\
mysqld           --defaults-file=/etc/my.cnf --initialize

myPrint    'Init mysql database & stop mysql:'
service mysql  start ||\
service mysqld start
service mysql  stop ||\
service mysqld stop
)