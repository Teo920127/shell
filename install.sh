/usr/sbin/setenforce 0
sed -i 's/SELINUX\=enforcing/SELINUX\=disabled/g' /etc/selinux/config
file=`dirname "${0}"`

epel=`rpm -qa epel-release`
if [ -n "$epel" ];then
echo 'epel-release has installed'
else
echo 'epel-release will be install'
rpm -ivh "$file/../program/epel-release-6-8.noarch.rpm"
fi
remi=`rpm -qa remi-release`
if [ -n "$remi" ];then
echo 'remi-release has installed'
else
echo 'remi-release will be install'
rpm -ivh "$file/../program/remi-release-6.rpm"
fi

yum install -y MySQL-python
yum install -y python-inotify
yum install -y python-daemon
yum install -y python-configobj

xinetd=`rpm -qa xinetd`
if [ -n "$xinetd" ];then
echo 'xinetd already installed'
service xinetd restart
else
echo 'xinetd will be installed'
yum install xinetd rsync -y
sed -i 's/disable	\= yes/disable	\= no/g' /etc/xinetd.d/rsync
service xinetd restart
fi

if [ ! -d "/etc/rn" ]; then 
mkdir "/etc/rn" 
fi 
if [ ! -d "/etc/rn/inotify.d" ]; then 
mkdir "/etc/rn/inotify.d" 
fi 
if [ ! -d "/usr/local/rn" ]; then 
mkdir "/usr/local/rn" 
fi 
touch /etc/rn/autorun.sh
if [ ! -d "/usr/local/rn/inotify" ]; then 
mkdir "/usr/local/rn/inotify" 
fi 

cp -a $file/../ /usr/local/rn/wftools
echo -e "bash /etc/rn/autorun.sh" >> /etc/rc.d/rc.local
chmod +x /usr/local/rn/wftools/bin/rsync_master.py
chmod +x /usr/local/rn/wftools/bin/rsync_slave.py
