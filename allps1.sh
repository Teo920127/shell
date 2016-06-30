#!/bin/bash
### crontab : * * * * * sh allps.sh startxxx.sh chengxuname 
#V2
#2016-05-18
#by tang jie
################softdes and switch#######################
switch(){
if [ "$#" -ne "2" ];then
        echo "Usage: sh $0 startXXX.sh CXname "
        exit 1
fi

PSNAME=`cat $1 |grep $2 |grep -v "#" |grep -v killname|sed -n "{s#^.*/bin/##p}" > sandtmp.txt`
cat sandtmp.txt | while read line
do
	PS=`ps -ef | grep "${line}"|grep -v grep|wc -l`
	if [ "$PS" -eq "0" ];then
		$HOME/bin/$line
		echo "`date "+%Y%m%d %H:%M:%S"` -- $line is down , now restart" >> $HOME/log/cronlog.log
	fi
done
rm -rf sandtmp.txt
}

##################EMV##########################
emv(){
if [ "$#" -ne "2" ];then
        echo "Usage: sh $0 startXXX.sh CXname "
        exit 1
fi

PSNAME=`cat $1 |grep $2 |grep -v "#" |grep -v killbyname > sandtmp.txt`
cat sandtmp.txt | while read line
do
	PS=`ps -ef | grep "${line}"|grep -v grep|wc -l`
	if [ "$PS" -eq "1" ];then
		continue
	else
		$HOME/bin/$line
		echo "`date "+%Y%m%d %H:%M:%S"` -- $line is down , now restart" >> $HOME/log/cronlog.log
	fi
done
rm -rf sandtmp.txt
}

####################tomcat################
tomcat(){
PS=`ps -ef |grep java|grep -v grep|wc -l`
PSPORT=`netstat -lnt |grep 8080 | wc -l`
if [ "$PS" -eq 1 -a "$PSPORT" -eq 1];then
	continue
else
	sh /home/tomcat/bin startup.sh
	echo "`date "+%Y%m%d %H:%M:%S"` -- $USER is down , now restart" >> $HOME/logs/cronlog.log
fi
}
#############################################
case "$USER" in
emv)
	emv $1 $2
;;
tomcat)
	tomcat
;;
switch)
	switch $1 $2
;;
softdes)
	switch $1 $2
;;
Pnewswitch)
	switch $1 $2
;;
*)
	switch $1 $2
;;
esac
