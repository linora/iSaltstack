# coding=utf-8
'''
  常用操作系统命令集
'''

#############################################################################################################################
# lib包导入
from __future__ import absolute_import

# 导入原生 lib包

# 导入Saltstack lib包

#############################################################################################################################
# 通用变量定义

d_cmd_list={
################################################################
# 获取物理磁盘信息(排除/dev/mapper)
'disk_info':
r'''fdisk -l | grep '^Disk /' | grep -v '/dev/mapper/' | sort -d | column -t ''',
################################################################
# 获取物理磁盘信息
'all_disk_info':
r'''fdisk -l | grep '^Disk /' | sort -d | column -t ''',
################################################################
# 获取fstab信息
'fstab_info':
r'''grep -v '^#' /etc/fstab  | egrep -v '^ *$' | sort -d | column -t ''',
################################################################
# 获取mount信息
'mount_info':
r'''df -hP | grep -iv 'Use%' | sort -d | column -t ''',
################################################################
# 设置所有disk scheduler为deadline
'set_all_disk_scheduler_deadline':
r'''
# 备份
cp /etc/rc.local /etc/rc.local.$(date '+%s')

fdisk -l |\
grep '^Disk /' |\
grep -v 'mapper' |\
cut -d: -f1 |\
awk '{print $2}' |\
awk -F'/' '{print $3}' |\
sort -d |\
while read DISK
do
  sed  -i "/^echo deadline *> .*sys.*block.*${DISK}.*queue.*scheduler/s/.//g" /etc/rc.local
  CMD="echo 'deadline' > /sys/block/${DISK}/queue/scheduler"
  eval "echo '${CMD}' >> /etc/rc.local"
done

sed -i '/^ *$/d' /etc/rc.local
# 返回信息
echo '【/etc/rc.local】'
egrep -v '^#' /etc/rc.local | egrep -v '^ *$' | sort -d
''',
################################################################
# 禁用selinux
'disable_selinux':
r'''
# 备份
cp /etc/selinux/config /etc/selinux/config.$(date '+%s')

setenforce 0
sed -i '/^SELINUX=/s/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 返回信息
echo '【selinux】'
getenforce
grep -v '^#' /etc/selinux/config | egrep -v '^ *$' | sort -d
''',
################################################################
# MySQL 其他OS优化设置
'other_setup':
r'''
# 备份
cp /etc/sysctl.conf /etc/sysctl.conf.$(date '+%s')

sed -i '/^net.ipv4.tcp_max_syn_backlog *=/s/.//g;/^vm.swappiness *=/s/.//g' /etc/sysctl.conf
echo 'vm.swappiness=10'                  >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog=4096' >> /etc/sysctl.conf
sed -i '/^fs.file-max *=/s/.//g' /etc/sysctl.conf
echo 'fs.file-max=6815744'                  >> /etc/sysctl.conf
sed -i '/^fs.aio-max-nr *=/s/.//g' /etc/sysctl.conf
echo 'fs.aio-max-nr=1048576'                  >> /etc/sysctl.conf
sed -i '/^kernel.shmmax *=/s/.//g' /etc/sysctl.conf
echo 'kernel.shmmax=18446744073692774399'                  >> /etc/sysctl.conf
sed -i '/^kernel.shmall *=/s/.//g' /etc/sysctl.conf
echo 'kernel.shmall=18446744073692774399'                  >> /etc/sysctl.conf
sed -i '/^kernel.sem *=/s/.//g' /etc/sysctl.conf
echo 'kernel.sem=250 32000 100 128'                  >> /etc/sysctl.conf
sed -i '/^net.ipv4.ip_local_port_range *=/s/.//g' /etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range=1024 65000'                  >> /etc/sysctl.conf
sed -i '/^net.core.rmem_default *=/s/.//g' /etc/sysctl.conf
echo 'net.core.rmem_default=262144'                  >> /etc/sysctl.conf
sed -i '/^net.core.rmem_max *=/s/.//g' /etc/sysctl.conf
echo 'net.core.rmem_max=4194304'                  >> /etc/sysctl.conf
sed -i '/^net.core.wmem_default *=/s/.//g' /etc/sysctl.conf
echo 'net.core.wmem_default=26214'                  >> /etc/sysctl.conf
sed -i '/^net.core.wmem_max *=/s/.//g' /etc/sysctl.conf
echo 'net.core.wmem_max=1048576'                  >> /etc/sysctl.conf
sed -i '/^ *$/d' /etc/sysctl.conf

cp /etc/security/limits.conf /etc/security/limits.conf.$(date '+%s')
sed -i '/^mysql.*soft.*nproc.*/s/.//g' /etc/security/limits.conf
sed -i '/^mysql.*soft.*nofile.*/s/.//g' /etc/security/limits.conf
sed -i '/^mysql.*soft.*memlock.*/s/.//g' /etc/security/limits.conf
sed -i '/^mysql.*hard.*nproc.*/s/.//g' /etc/security/limits.conf
sed -i '/^mysql.*hard.*nofile.*/s/.//g' /etc/security/limits.conf
sed -i '/^mysql.*hard.*memlock.*/s/.//g' /etc/security/limits.conf

echo 'mysql              soft    nproc      2047'  >> /etc/security/limits.conf
echo 'mysql              hard    nproc      16384' >> /etc/security/limits.conf
echo 'mysql              soft    nofile     1024'  >> /etc/security/limits.conf
echo 'mysql              hard    nofile     65536' >> /etc/security/limits.conf
echo 'mysql              soft    memlock    unlimited' >> /etc/security/limits.conf
echo 'mysql              hard    memlock    unlimited' >> /etc/security/limits.conf

sed -i '/^ *$/d' /etc/security/limits.conf

echo '【/etc/security/limits.conf】'
egrep '^mysql.*(hard|soft).*(nproc|nofile|memlock)' /etc/security/limits.conf | sort -d | column -t

# 返回信息
echo '【/etc/sysctl.conf】'
sysctl -p | sort -d
''',
################################################################
# 启用hugepages
'setup_huge_pages':
r'''
cp /etc/sysctl.conf /etc/sysctl.conf.$(date '+%s')

sed -i '/^vm.nr_hugepages *=/s/.//g' /etc/sysctl.conf
echo 'vm.nr_hugepages={huge_pages_number}'                  >> /etc/sysctl.conf
sed -i '/^vm.hugetlb_shm_group *=/s/.//g' /etc/sysctl.conf
echo "vm.hugetlb_shm_group=$(id -g mysql)"                  >> /etc/sysctl.conf
sed -i '/^ *$/d' /etc/sysctl.conf

cp /etc/rc.local /etc/rc.local.$(date '+%s')
sed -i '/^if.*test.*-f.*sys.*kernel.*mm.*transparent_hugepage.*enabled.*/s/.//g' /etc/rc.local
echo 'if test -f /sys/kernel/mm/transparent_hugepage/enabled; then    echo never > /sys/kernel/mm/transparent_hugepage/enabled; fi' >> /etc/rc.local
sed -i '/^ *$/d' /etc/rc.local

echo '【hugepage info】'
sysctl -p >/dev/null 2>/dev/null
grep -i huge /proc/meminfo
''',
################################################################
# 初始化firewalld for MySQL
# firewalld设置相关参考：
#  1. https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-installing_firewalld#bh-Checking_If_firewalld_Is_Running
#  2. https://www.ibm.com/developerworks/cn/linux/1507_caojh/

'init_firewalld_for_mysql':
r'''
yum install -y firewalld >/dev/null 2>/dev/null

systemctl enable firewalld >/dev/null 2>/dev/null
systemctl start firewalld >/dev/null 2>/dev/null

firewall-cmd --remove-service=mysql --permanent >/dev/null 2>/dev/null
firewall-cmd --remove-port=3306/tcp --permanent >/dev/null 2>/dev/null
firewall-cmd --remove-port=3306/udp --permanent >/dev/null 2>/dev/null

firewall-cmd --reload >/dev/null 2>/dev/null

echo '【firewall】'
firewall-cmd --get-default-zone
firewall-cmd --list-all
''',
################################################################
# 添加firewalld 规则（对特定主机开通3306访问权限）
'add_rich_rule':
r'''
firewall-cmd --add-rich-rule='rule family="ipv4" source address="{ip}/{mask}" service name="mysql" accept' --permanent
firewall-cmd --reload
firewall-cmd --list-all
''',
################################################################
# 移除firewalld 规则（对特定主机禁用3306访问权限）
'remove_rich_rule':
r'''
firewall-cmd --remove-rich-rule='rule family="ipv4" source address="{ip}/{mask}" service name="mysql" accept' --permanent
firewall-cmd --reload
firewall-cmd --list-all
''',
################################################################
# 列出所有firewalld规则
'firewall_cmd_list_all':
r'''
firewall-cmd --list-all
''',
################################################################
# 初始化iptables for MySQL
'init_iptables_for_mysql':
r'''
# 备份
iptables-save > /etc/sysconfig/iptables-save.$(date '+%s') >/dev/null 2>&1
cp /etc/sysconfig/iptables-config /etc/sysconfig/iptables-config.$(date '+%s') >/dev/null 2>&1
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.$(date '+%s') >/dev/null 2>&1

# 安装并启动
yum install -y iptables >/dev/null 2>&1
chkconfig iptables on >/dev/null 2>/dev/null
service iptables start >/dev/null 2>/dev/null

# 将3306端口从iptables配置文件中移除
sed -i '/.*dport.* 3306 .*ACCEPT.*/s/.//g' /etc/sysconfig/iptables
service iptables restart >/dev/null 2>/dev/null

echo '【iptables】'
service iptables status
''',
################################################################
# 添加iptables 规则（对特定主机开通3306访问权限）
'add_iptables_rule':
r'''
iptables -A INPUT -s {ip}/{mask} -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
service iptables save
service iptables restart
service iptables status
''',
################################################################
# 添加iptables 规则（对特定minion开通4505,4506端口）
'add_iptables_rule4minion':
r'''
iptables -A INPUT -s {ip}/{mask} -p tcp -m state --state NEW -m tcp --dport 4505 -j ACCEPT
iptables -A INPUT -s {ip}/{mask} -p tcp -m state --state NEW -m tcp --dport 4505 -j ACCEPT
service iptables save
service iptables restart
service iptables status
''',
################################################################
# 移除iptables 规则（对特定主机禁用3306访问权限）
'remove_iptables_rule':
r'''
# 备份
iptables-save > /etc/sysconfig/iptables-save.$(date '+%s') >/dev/null 2>&1
cp /etc/sysconfig/iptables-config /etc/sysconfig/iptables-config.$(date '+%s') >/dev/null 2>&1
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.$(date '+%s') >/dev/null 2>&1

sed -i '/.*-s *{ip}.*{mask}.*dport.* 3306 .*ACCEPT.*/s/.//g' /etc/sysconfig/iptables
service iptables restart >/dev/null 2>/dev/null
service iptables status
''',
################################################################
# 列出所有iptables规则
'iptables_status':
r'''
service iptables status
''',
################################################################
# Mount MySQL用磁盘
'mount_mysql_disk':
r'''
# 备份
cp /etc/fstab /etc/fstab.$(date '+%s')

sed -i '/.*app.*mysql.*defaults,nobarrier,noatime,nodiratime/s/.//g' /etc/fstab
#VUUID=$(blkid {disk_label} | cut -d' ' -f2 | sed 's/"//g')
echo "{disk_label}	{mysql_home}	xfs 	defaults,nobarrier,noatime,nodiratime	0 0" >> /etc/fstab
mount {mysql_home}
sed -i '/^ *$/d' /etc/fstab

# 返回信息
echo '【mount_mysql_disk：fstab信息】'
grep -v '^#' /etc/fstab | egrep -v '^ *$' | sort -d | column -t
echo '【mount_mysql_disk：mount后信息】'
df -hP | grep -iv 'Use%' | sort -d | column -t
'''
}
