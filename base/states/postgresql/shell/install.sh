#!/bin/bash
################################################################################################
# Title           :install.sh
# Description     :The script will execute by init_mysql.sls in targe salt minion.
# Author          :linora
# Date            :2018/01/10
# Version         :0.1
# Usage	          :salt 'none' state.sls mysql.init_mysql
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action	    风险	    其他说明
# 安装MySQL依赖包   无              
# 卸载MySQL冲突包   无              
# 清除MySQL相关文件 无
# 安装MySQL包       无 
# 重新初始化MySQL   无              重新初始化为/etc/my.cnf文件中目录结构（最佳实践），参数最优化
# 停止MySQL         无
################################################################################################
# 禁用Debian系统交互式操作
export DEBIAN_FRONTEND=noninteractive
# mysql_home='/app/mysql'
# mysql_pkgs_dir='/tmp/mysql_db'


# 函数：居中显示信息
myPrint() {
        STR="$1"; 
        printf '||||%24s%-24s|||\n' \
        "$(echo $STR | cut -c 1-$((${#STR}/2)))" \
        "$(echo $STR | cut -c $((${#STR}/2+1))-${#STR})";
}


myPrint    'Install deps PKGs:'
apt-get install -y libaio1 libmecab2 ||\
yum     install -y libaio  libaio-devel

myPrint    'Uninstall MySQL conflit PKGs:'
rpm     -e     --nodeps   mariadb-libs mysql-libs ||\
apt-get remove --purge -y mysql-common mariadb-libs

myPrint    'Clean mysql files:'
rm -f  /var/lib/mysql/RPM_UPGRADE_MARKER
rm -rf /etc/mysql
rm -rf /etc/my.cnf*
rm -rf /usr/my.cnf*

myPrint    'Install MySQL PKGs:'
cd        $mysql_pkgs_dir
tar  -xvf mysql.tar
rm   -rf  mysql*minimal*5.7.20*.rpm
rm   -rf  mysql*minimal*5.7.20*.deb
rpm  -ivh *.rpm ||\
dpkg -i   *.deb

myPrint    'Stop mysql:'
service mysql  stop ||\
service mysqld stop

myPrint    'Create dirs for MySQL:'
test ! -z $mysql_home && test -d $mysql_home && rm -rf $mysql_home/*
mkdir -p $mysql_home/{binlog_dir,data_dir,innodb_data,tmp_dir,innodb_log,undo_dir,innodb_tmpdir}
chown -R mysql:mysql $mysql_home/

myPrint    'Reconfigure my.cnf:'
\cp -f /tmp/my.cnf /etc/my.cnf
sed -i '/innodb_buffer_pool_size/s/.0M/M/g' /etc/my.cnf

myPrint    'Init MySQL db:'
rm -rf /etc/mysql
mysql_install_db --defaults-file=/etc/my.cnf ||\
mysqld           --defaults-file=/etc/my.cnf --initialize

myPrint    'Init mysql database & stop mysql:'
service mysql  start ||\
service mysqld start
service mysql  stop ||\
service mysqld stop
