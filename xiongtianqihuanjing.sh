!/bin/sh



if id |grep "^uid=0(root)">/dev/null ;then 
echo is root 
echo 登陆的用户是 Root 安装将继续...请确保/data具有20GB空间!
else 
echo not root user
echo 你当前登录用户不是 root 安装无法继续.请用root账户登录系统!或者用su root 命令切换到root账户.
sleep 8s
exit 0
fi 


echo "初始化...安装环境"
sleep 6s
echo "本套件包在Ubuntu14.04/12.04/以及centos7.0 root身份登陆测试通过.其他系统请谨慎使用."
echo "安装即将开始..请耐心等待...."
sleep 8s

##Debian
apt-get update
yum -y install redhat-lsb
dpkg --add-architecture i386
aptitude update
apt-get -y install ia32-libs*
apt-get -y install screen
##Debian

sudo yum -y install redhat-lsb

#centos
if lsb_release -i | grep CentOS; then
echo "系统是CentOS"
sudo yum -y update

ldconfig
if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; 
then
 echo "Centos-64bit"
 echo "Centos-检测到系统是64位将安装32位运行库 技术支持-xiongtianqi.cn"
 sleep 5s
sudo yum -y install xulrunner.i686
else
   echo "SYSTEM == 32bit"
   echo "系统是32位将跳过安装32位运行库"
fi

sudo yum -y install screen
cd /data
chmod -R 777 *
sleep 5s
screen -S xiongtianqi  /data/xiongtianqi.sh
sleep 5s
fi


#ubuntu
ldconfig
if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; 
then
 echo "64bit Install ia32-lib"
 echo "检测到系统是64位将安装32位运行库 技术支持-xiongtianqi.cn"
 sleep 5s
 sudo apt-get update
 sudo apt-get -y install ia32-libs 
 sudo apt-get -y install lib32stdc++-4.8-dev
 sudo apt-get -y install lib32z1 lib32z1-dev
 sudo apt-get -y install libc6-dev-i386 libc6-i386
else
   echo "SYSTEM == 32bit"
   echo "系统是32位将跳过安装32位运行库"
fi
#ubuntu


sleep 6s
sudo apt-get install screen

echo "install screen [CSGO-Auto]"
echo "正在准备启动CSGO服务端下载 [CSGO-Auto]"
cd /data
chmod -R 777 *
sleep 5s
screen -S xiongtianqi  /data/xiongtianqi.sh


