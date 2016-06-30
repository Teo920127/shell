#!/bin/bash
#Ver:1.4

#script name:���п��ն��Զ�����״̬�������ɽű�
#brief:ÿ��1����20�ŵ��賿3��30�����У�ͳ������20�������µ��ն˼������

#�жϽű������Ƿ���ȫ
if [ "$1" = "" ]
then
	echo "Usage:$0 �̻����ŵ�����"
	exit 0
fi

#��~/.bash_profile���뻷������
. ~/.bash_profile

#�̻����ŵ����ƣ����ű���һ���������ɲ������״�ִ��ʱ�ֹ�ָ��
MERCHANTNAME=$1

#�������ڵ�ǰһ��
CURDATE=`date +%Y%m%d "-d -1 day"`
CURDAY=`date +%d "-d -1 day"`

#�Զ��������ڿ�ʼ����(����20��),��������(����19��)
START_DATE=`date +%Y%m20 "-d -1 month"`
END_DATE=`date +%Y%m19`
export MERCHANTNAME CURDATE START_DATE END_DATE

#������ļ���
ARCHIVE_NAME=$MERCHANTNAME-$CURDATE.txt

#Զ��FTP������ַ
FTP_HOST_IP=20.20.20.2

#crontab�Զ���ӹ���
CRONTAB=`crontab -l|grep "$0"|wc -l`
if [ "$CRONTAB" -eq "1" ]
then
	echo "********crontab�Ѿ���ӣ��޲���***********"
else
	#���cron�Զ�����(ÿ��1-20���賿3��30��ִ�нű�)
	crontab -l > crontab.unl
	echo "30 04 1-20 * * $0 $MERCHANTNAME > $HOME/log/`basename $0`.log 2>&1" >> crontab.unl
	crontab crontab.unl
	echo "********���crontab�ɹ�***********"
fi

#������ż�����ļ��Ĺ���Ŀ¼��������ù���Ŀ¼
mkdir $HOME/Activa_Report >/dev/null 2>&1
WORK_DIR=$HOME/Activa_Report
cd $WORK_DIR

#��ʼ�Ա����ļ���д������

#д�ļ�ͷ���ŵ���̻����ƣ�ͳ������
echo -e "++++++++++++ $MERCHANTNAME ����� ++++++++++++" > $WORK_DIR/$ARCHIVE_NAME
echo -e "\n+++++++++ ͳ������:$START_DATE �� $CURDATE +++++++++" >> $WORK_DIR/$ARCHIVE_NAME

#��ʼ�������ݿ⣬��ѯ����
		dbaccess - - << !
		database emv;
		begin work;
		
--����1��ͳ�Ʋ����Զ�������ն���ϸ:
		unload to 1.unl
		select mid,tid,pos_id from bk_pos_info where tid not in (select tid from specialtid)
		order by mid,tid;

--����2��ͳ�Ʋ������Զ�������ն���ϸ:		
		unload to 3.unl
		select mid,tid,posid,name from specialtid order by mid,tid;
		
--����3:ͳ�ƻ�δ������ն˺���ϸ:
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

--����4:ͳ�ƽ�������С���ն�(С��5000):
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

#����5��ÿ��20��ͳ����Ȼ�����ն���������ͳ���������������ڽ��׶����㼤��������POS_ID����(ÿ��ֻ20��ͳ��һ��)
#ʵ��:�ж������Ƿ�Ϊ20�գ�����ͳ�Ƴ�POS_ID��ϸ������ʱ���У���ͳ����ʱ����������ó�������

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
	echo -e "\n+++++++++++++++++++++++++++++++++++++����ѯ�ն�����ͳ��+++++++++++++++++++++++++++++++++++++" >> $WORK_DIR/$ARCHIVE_NAME
	echo -e "\n��Ȼ�����ն�����(POS_ID):" >> $WORK_DIR/$ARCHIVE_NAME
	cat 6.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME
fi

echo -e "\n�����Զ�������ն�����:" >> $WORK_DIR/$ARCHIVE_NAME
cat 1.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n�������Զ�������ն�����(specialtid):" >> $WORK_DIR/$ARCHIVE_NAME
cat 3.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n��δ������ն�����:" >> $WORK_DIR/$ARCHIVE_NAME
cat 5.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n��������С���ն�(С��5000):" >> $WORK_DIR/$ARCHIVE_NAME
cat 7.unl|wc -l >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n+++++++++++++++++++++++++++++++++++++����ѯ�ն���ϸͳ��+++++++++++++++++++++++++++++++++++++" >> $WORK_DIR/$ARCHIVE_NAME
echo -e "\n��δ������ն���ϸ(MID|TID):" >> $WORK_DIR/$ARCHIVE_NAME
cat -n 5.unl >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n��������С���ն�(С��5000)(TID|���ױ���|���׽��):" >> $WORK_DIR/$ARCHIVE_NAME
cat -n 7.unl >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n�����Զ�������ն���ϸ(MID|TID|POS_ID):" >> $WORK_DIR/$ARCHIVE_NAME
cat -n 1.unl >> $WORK_DIR/$ARCHIVE_NAME

echo -e "\n�������Զ�������ն���ϸ(specialtid����MID|TID|POSID|NAME):" >> $WORK_DIR/$ARCHIVE_NAME
cat -n 3.unl >> $WORK_DIR/$ARCHIVE_NAME

#����7:��ChangeTid��־д��
echo -e "\n++++++++++++++++++++++++++++++++++ChangeTid.log����++++++++++++++++++++++++++++++++++++++++\n" >> $WORK_DIR/$ARCHIVE_NAME
cat $HOME/log/ChangeTid.log >> $WORK_DIR/$ARCHIVE_NAME

#����6:FTP��ָ������

echo -e "*********����FTP�����ļ�������**********"
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
echo -e "*********FTP�����ļ����������**********"

rm *.unl

echo -e "***********ɾ����ʱ�ļ����************"
