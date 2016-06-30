dir=`dirname "${0}"`
mysql=`rpm -qa mysql`
if [ -n "$mysql" ];then
echo $mysql
echo 'mysql already installed'
service mysqld restart
else
echo 'mysql will be installed'
echo "please enter your mysql password"
read password
yum install mysql mysql-server mysql-devel -y
service mysqld start
mysqladmin -u root password "$password"
echo -e "$password\nn\ny\ny\ny\ny"> /tmp/mysqlset
/usr/bin/mysql_secure_installation < /tmp/mysqlset 
rm -rf /tmp/mysqlset
fi
echo 'mysql finished'

apache=`rpm -qa httpd-devel`
if [ -n "$apache" ];then
echo $apache
echo 'already installed'
service httpd restart
else
echo 'apache will be installed'
yum install httpd httpd-devel httpd-manual -y
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
service httpd restart
fi
echo 'apache finished'
mkdir /etc/httpd/conf/extra
mkdir /etc/httpd/conf/sites
mkdir /websites
chmod 775 /websites
chown apache:apache /websites
sed -i '/Include conf\/extra\/httpd-phpmyadmin\.conf/d' /etc/httpd/conf/httpd.conf
sed -i '/Include conf\/extra\/\*\.conf/d' /etc/httpd/conf/httpd.conf¡¢
/Include conf\/extra\/\*\.conf/d 
sed -i '/Include conf\/sites\/\*/d' /etc/httpd/conf/httpd.conf
echo -e "Include conf/extra/*.conf" >> /etc/httpd/conf/httpd.conf
echo -e "Include conf/sites/*" >> /etc/httpd/conf/httpd.conf
cp $dir/../program/wfapache.conf /etc/httpd/conf/extra/wfapache.conf
if [ ! -f '/etc/httpd/conf/extra/defaultsite.conf' ];then
  python2 ${dir}/defaultsite.py 404
fi


php=`rpm -qa php`
if [ -n "$php" ];then
echo $php
echo 'already installed'
else
echo 'php will be installed'
yum install -y php 
yum install -y php-mbstring 
yum install -y php-mysql 
yum install -y php-gd 
yum install -y php-cli 
yum install -y php-common 
yum install -y php-imap 
yum install -y php-intl
yum install -y php-pdo
yum install -y php-pear 
yum install -y php-soap
yum install -y php-pecl
yum install -y php-xml
yum install -y php-xmlrpc
yum install -y uuid-php
yum install -y php-pecl-apc
sed -i 's/upload_max_filesize \= 2M/upload_max_filesize \= 20M/g' /etc/php.ini
service httpd restart
fi
echo 'php finished'

chkconfig --levels 2345 httpd on
chkconfig --levels 2345 mysqld on
