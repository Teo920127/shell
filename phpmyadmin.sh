dir=`dirname "${0}"`
pma="/etc/httpd/conf/extra/httpd-phpmyadmin.conf"
if [ ! -d "$pma" ];then
mkdir /usr/local/webfoss
tar -xzvf $dir/../program/phpMyAdmin-4.1.12-all-languages.tar.gz -C /usr/local/webfoss
mv /usr/local/webfoss/phpMyAdmin-4.1.12-all-languages /usr/local/webfoss/phpmyadmin
cp $dir/../program/httpd-phpmyadmin.conf /etc/httpd/conf/extra/httpd-phpmyadmin.conf
service httpd restart
echo 'phpmyadmin  complete'
else
echo 'phpmyadmin  Installed'
fi
