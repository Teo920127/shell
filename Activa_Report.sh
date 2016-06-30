#!/bin/bash
#Ver:1.4

#script name:银行卡终端自动激活状态报告生成脚本
#brief:每月1号至20号的凌晨3点30分运行，统计上月20日至当下的终端激活情况

#判断脚本参数是否齐全
if [ "$1" = "" ]
then
	echo "Usage:$0 商户或门店名称"
	exit 0
fi

#从~/.bash_profile导入环境变量
. ~/.bash_profile

#商户或门店名称，本脚本第一个参数，由操作人首次执行时手工指定
MERCHANTNAME=$1

#当下日期的前一天
CURDATE=`date +%Y%m%d "-d -1 day"`
CURDAY=`date +%d "-d -1 day"`

#自动激活周期开始日期(上月20日),结束日期(本月19日)
START_DATE=`date +%Y%m20 "-d -1 month"`
END_DATE=`date +%Y%m19`
export MERCHANTNAME CURDATE START_DATE END_DATE

#激活报告文件名
ARCHIVE_NAME=$MERCHANTNAME-$CURDATE.txt

#远程FTP主机地址
FTP_HOST_IP=20.20.20.2

#crontab自动添加功能
CRONTAB=`crontab -l|grep "$0"|wc -l`
if [ "$CRONTAB" -eq "1" ]
then
	echo "********crontab已经添加，无操作***********"
else
	#添加cron自动运行(每月1-20号凌晨3点30分执行脚本)
	crontab -l > crontab.unl
	echo "30 04 1-20 * * $0 $MERCHANTNAME > $HOME/log/`basename $0`.log 2>&1" >> crontab.unl
	crontab crontab.unl
	echo "********添加crontab成功***********"
fi

#创建存放激活报告文件的工作目录，并进入该工作目录
mkdir $HOME/Activa_Report >/dev/null 2>&1
WORK_DIR=$HOME/Activa_Report
cd $WORK_DIR

#开始对报告文件中写入内容

#写文件头：门店或商户名称，统计周期
echo -e "++++++++++++ $MERCHANTNAME 激活报告 ++++++++++++" > $WORK_DIR/$ARCHIVE_NAME
echo -e "\n+++++++++ 统计周期:$START_DATE 至 $CURDATE +++++++++" >> $WORK_DIR/$ARCHIVE_NAME

#开始操作数据库，查询数据
		dbaccess - - << !
		database emv;
		begin work;
		
--功能1：统计参与自动激活的终端明细:
		unload to 1.unl
		select mid,tid,pos_id from bk_pos_info where tid not in (select tid from specialtid)
		order by mid,tid;

--功能2：统计不参与自动激活的终端明细:		
		unload to 3.unl
		select mid,tid,posid,name from specialtid order by mid,tid;
		
--功能3:统计还未激活的终端号明细:
		unload to 5.unl
		SELECT mid,tid FROM bk_pos_info
		where tid not in
		(
		SELECT DISTINCT tid FROM bk_trans_his 
		where
		host_date between $START_DATE and $CURDATE
    and trans_type in(1,5,8,48) and result_flag='0'
    )
		and tid not in (select tid from specialtid)
		order by tid;

--功能4:统计交易量较小的终端(小于5000):
		unload to 7.unl
		SELECT tid,count(*),sum(amount) FROM bk_trans_his
		where host_date between $START_DATE and $CURDATE
		and trans_type in(1,5,8,9) and result_flag='0'
		and tid not in (SELECT DISTINCT tid FROM specialtid)
		and tid in (SELECT DISTINCT tid FROM bk_pos_info)
		group by tid
		having sum(amount) < 5000;
		
		commit;
		close database;
!

#功能5：每月20日统计自然激活终端数量，即统计整个激活周期内交易额满足激活条件的POS_ID个数(每月只20号统计一次)
#实现:判断日期是否为20日，是则统计出POS_ID明细插入临时表中，再统计临时表的行数，得出个数。

DATE=`date +%d`
if [ "$DATE" = 20 ]
then
		dbaccess - -<<!
		database emv;
		begin work;
		
		select distinct pos_id from bk_trans_his where
		host_date between $START_DATE and $CURDATE
		and trans_type=1 and retcode='0000' and result_flag=0
		and pos_id not in (select posid from specialtid)
		group by pos_id
		having sum(amount) > 5000
		into temp tmp_pos_id;
		
		unload to 6.unl
		select * from tmp_pos_id;
		commit;
		close database;
!
	echo -e "\n+++++++++++++++++++++++++++++++++++++各查询终端数量统计+++++++++++++++++++++++++++++++++++++" >> $WORK_DIR/$ARCHIVE_NAME
	echo -e "\n自然激活终端数量(POS_ID):" >> $WORK_DIR/$ARCHIVE_NAME
	cat 6.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME
fi

echo -e "\n参与自动激活的终端数量:" >> $WORK_DIR/$ARCHIVE_NAME
cat 1.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n不参与自动激活的终端数量(specialtid):" >> $WORK_DIR/$ARCHIVE_NAME
cat 3.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n还未激活的终端数量:" >> $WORK_DIR/$ARCHIVE_NAME
cat 5.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n交易量较小的终端(小于5000):" >> $WORK_DIR/$ARCHIVE_NAME
cat 7.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n+++++++++++++++++++++++++++++++++++++各查询终端明细统计+++++++++++++++++++++++++++++++++++++" >> $WORK_DIR/$ARCHIVE_NAME
echo -e "\n还未激活的终端明细(MID|TID):" >> $WORK_DIR/$ARCHIVE_NAME
cat -n 5.unl >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n交易量较小的终端(小于5000)(TID|交易笔数|交易金额):" >> $WORK_DIR/$ARCHIVE_NAME
cat -n 7.unl >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n参与自动激活的终端明细(MID|TID|POS_ID):" >> $WORK_DIR/$ARCHIVE_NAME
cat -n 1.unl >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n不参与自动激活的终端明细(specialtid表中MID|TID|POSID|NAME):" >> $WORK_DIR/$ARCHIVE_NAME
cat -n 3.unl >> $WORK_DIR/$ARCHIVE_NAME

#功能7:将ChangeTid日志写入
echo -e "\n++++++++++++++++++++++++++++++++++ChangeTid.log内容++++++++++++++++++++++++++++++++++++++++\n" >> $WORK_DIR/$ARCHIVE_NAME
cat $HOME/log/ChangeTid.log >> $WORK_DIR/$ARCHIVE_NAME

#功能6:FTP至指定主机

echo -e "*********正在FTP报告文件至主机**********"
ftp -i -n $FTP_HOST_IP << FTPFILE
user emv !sdemv98$
bin
mkdir Activa_Report
cd Activa_Report
mkdir $CURDATE
cd $CURDATE
put $ARCHIVE_NAME
bye
FTPFILE
echo -e "*********FTP报告文件至主机完成**********"

rm *.unl

echo -e "***********删除临时文件完成************"
