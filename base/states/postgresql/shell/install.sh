#!/bin/bash
################################################################################################
# Title           :install.sh
# Description     :The script will execute by init_postgresql.sls in targe salt minion.
# Author          :linora
# Date            :2018/02/05
# Version         :0.1
# Usage	          :salt 'none' state.sls postgresql.init_postgresql
# Notes           :Install saltstack master to use this script. 
# Salt_version    :2017.7.2-1.el7
################################################################################################
# Action	        风险	        其他说明
# 卸载PG冲突包      无              
# 安装PG10          无 
# 初始化PG10        无              重新初始化为postgresql.conf文件中目录结构（最佳实践），参数最优化
################################################################################################
# 变量定义

export PG_DATA="/app/postgresql"


# 函数：居中显示信息
myPrint() {
        STR="$1"; 
        printf '||||%24s%-24s|||\n' \
        "$(echo $STR | cut -c 1-$((${#STR}/2)))" \
        "$(echo $STR | cut -c $((${#STR}/2+1))-${#STR})";
}


myPrint    'Uninstall PG conflit PKGs:'
rpm -qa    | grep -i ^postgresql | xargs rpm -e --nodeps


myPrint    'Install PG10 PKGs:'
yum        -y install postgresql10 \
                      postgresql10-server \
                      postgresql10-client \
                      postgresql10-contrib \
                      postgresql10-devel

myPrint    'Init PG to pg_data home:'
test ! -z ${PG_DATA} && test -d ${PG_DATA} && (
chown postgres:postgres ${PG_DATA}
su         - postgres -c "/usr/pgsql-10/bin/initdb -D ${PG_DATA}"

myPrint    'Start postgresql & setup AutoBoot on:'
sed        -i "s|PGDATA=/var/lib/pgsql/10/data/|PGDATA=${PG_DATA}/|" \
/usr/lib/systemd/system/postgresql-10.service ||
(
  sed -i s#PGDATA=/var/lib/pgsql/10/data#PGDATA=/app/postgresql#g /etc/init.d/postgresql-10;
  sed -i s#PGLOG=/var/lib/pgsql/10/pgstartup.log#PGLOG=/app/postgresql/pgstartup.log#g /etc/init.d/postgresql-10;
  sed -i s#PGUPLOG=/var/lib/pgsql/.*/pgupgrade.log#PGUPLOG=/app/postgresql/pgupgrade.log#g /etc/init.d/postgresql-10
)

systemctl daemon-reload
systemctl enable postgresql-10 ||\
chkconfig postgresql-10 on
mkdir ${PG_DATA}/archive_logs && \
chown postgres:postgres ${PG_DATA}
chown -R postgres:postgres /var/run/postgresql
service postgresql-10 restart
service postgresql-10 stop
)



