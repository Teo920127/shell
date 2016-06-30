ftp=`rpm -qa vsftpd`
if [ -z "$1" ];then
  home=/var/www/html

else
  home=$1
fi
if [ -n "$ftp" ];then
echo $ftp
echo 'already installed'
else
echo 'ftp will be installed'
yum install vsftpd -y
sed -i 's/\#chroot_local_user\=YES/chroot_local_user\=YES/g' /etc/vsftpd/vsftpd.conf
sed -i 's/anonymous_enable\=YES/anonymous_enable\=NO/g' /etc/vsftpd/vsftpd.conf
service vsftpd start
fi
echo "please enter your ftp username.if you want exit,please enter 'exit'!"
read username
if [ $username != "exit" ];then
useradd -G apache -d "$home" -M "$username" -s /sbin/nologin
echo "please enter your ftp password"
read password
echo "$password" |passwd "$username" --stdin 
fi
echo 'ftp finished'

chkconfig --levels 2345 vsftpd on