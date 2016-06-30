#!/bin/bash
#Ver:1.1

#crontab: * * 5,15,25 * * $HOME/sysbackup.sh Merchant_Name > /root/wholeback/sysbackup.log

if [ "$1" = "" ]
then
	echo "Usage:$0 Merchant_Name"
	exit 0
fi

MERCHANTNAME=$1
#export MERCHANTNAME
MYDATE=`date +%Y%m%d`
export MERCHANTNAME MYDATE
ARCHIVE_NAME=backup-$MYDATE-$MERCHANTNAME.tar

#echo "$ARCHIVE_NAME"

SYSBACKUPDIR=$HOME/wholeback
mkdir -p $SYSBACKUPDIR
cd $SYSBACKUPDIR

rm -f $SYSBACKUPDIR/*

/bin/netstat -rn > $SYSBACKUPDIR/RouteTable-$MYDATE-$MERCHANTNAME.log
/bin/df -h > $SYSBACKUPDIR/DiskUse-$MYDATE-$MERCHANTNAME.log

echo "*******��ʼ���ݲ���ϵͳ�ļ�*******"
	tar cvPf Sys_$ARCHIVE_NAME /etc/sysconfig/network-scripts/ifcfg-eth*
	tar rvPf Sys_$ARCHIVE_NAME /etc/sysconfig/network
	tar rvPf Sys_$ARCHIVE_NAME /etc/hosts
	tar rvPf Sys_$ARCHIVE_NAME /etc/sysctl.conf
	tar rvPf Sys_$ARCHIVE_NAME /etc/rc3.d/S9[1-6]*
	tar rvPf Sys_$ARCHIVE_NAME /etc/rc6.d/K98*
	tar rvPf Sys_$ARCHIVE_NAME /etc/rc0.d/K98*
	tar rvPf Sys_$ARCHIVE_NAME /var/spool/cron/*

	tar rvPf Sys_$ARCHIVE_NAME $SYSBACKUPDIR/RouteTable-$MYDATE-$MERCHANTNAME.log
echo "******���ݲ���ϵͳ�ļ����********"

if `id informix > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ�������ݿ��ļ�*******"
	tar cvPf Informix_$ARCHIVE_NAME /home/informix/etc/onconfig
	tar rvPf Informix_$ARCHIVE_NAME /home/informix/etc/sqlhosts
	su - informix -c "/home/informix/bin/onstat -d" > $SYSBACKUPDIR/DBspaceUse-$MYDATE-$MERCHANTNAME.log
	echo "*******�������ݿ��ļ����*******"
fi

if `id emv > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����EMV�û��ļ������ݿ��*******"
	tar cvPf Emv_$ARCHIVE_NAME /home/emv/etc/*
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/*
	
		su - emv -c "dbaccess - -<<! >/dev/null 2>&1
		database emv;
		begin work;
		unload to bk_mid_info_$MYDATE-$MERCHANTNAME.unl select * from bk_mid_info;
		unload to bk_pos_info_$MYDATE-$MERCHANTNAME.unl select * from bk_pos_info;
		unload to bk_sys_oper_$MYDATE-$MERCHANTNAME.unl select * from bk_sys_oper;
--LianHua		
		unload to bk_oper_mid_$MYDATE-$MERCHANTNAME.unl select * from bk_oper_mid;
--SportLottery
		unload to tcpos_info_$MYDATE-$MERCHANTNAME.unl select * from tcpos_info;
--Lotus	
		unload to specialtid_$MYDATE-$MERCHANTNAME.unl select * from specialtid;
--SuNing		
		unload to sn_account_info_$MYDATE-$MERCHANTNAME.unl select * from sn_account_info;
		unload to sn_card_name_$MYDATE-$MERCHANTNAME.unl select * from sn_card_name;
		unload to sn_tid_mis_$MYDATE-$MERCHANTNAME.unl select * from sn_tid_mis;
--ZengFu
		unload to avp_info_$MYDATE-$MERCHANTNAME.unl select * from avp_info;
		unload to card_info_$MYDATE-$MERCHANTNAME.unl select * from card_info;
		unload to v_pos_info_$MYDATE-$MERCHANTNAME.unl select * from v_pos_info;
		commit;
		close database;
		!"
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bk_mid_info_$MYDATE-$MERCHANTNAME.unl
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bk_pos_info_$MYDATE-$MERCHANTNAME.unl
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bk_sys_oper_$MYDATE-$MERCHANTNAME.unl

#LianHua
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bk_oper_mid_$MYDATE-$MERCHANTNAME.unl >/dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/backup/unload_data_4L.sh >/dev/null 2>&1
#Lotus
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/specialtid_$MYDATE-$MERCHANTNAME.unl >/dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/Activates/Activates >/dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/Activates.sh >/dev/null 2>&1
#SportLottery
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/tcpos_info_$MYDATE-$MERCHANTNAME.unl >/dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/sportsend* >/dev/null 2>&1
#SuNing
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/sn_account_info_$MYDATE-$MERCHANTNAME.unl >/dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/sn_card_name_$MYDATE-$MERCHANTNAME.unl >/dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/sn_tid_mis_$MYDATE-$MERCHANTNAME.unl >/dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/etc/snconfig > /dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/switchDDN.sh > /dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/SNAccount.sh > /dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/uptobak.sh > /dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/startappBAK > /dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/accftp.sh > /dev/null 2>&1
#ZengFu
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/avp_info_$MYDATE-$MERCHANTNAME.unl > /dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/card_info_$MYDATE-$MERCHANTNAME.unl > /dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/v_pos_info_$MYDATE-$MERCHANTNAME.unl > /dev/null 2>&1
	tar rvPf Emv_$ARCHIVE_NAME /home/emv/bin/avpsend > /dev/null 2>&1

	rm -f /home/emv/*$MYDATE-$MERCHANTNAME.unl
	echo "*******����EMV�û��ļ������ݿ�����*******"
fi

if `id tomcat > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����tomcat�ļ�*******"
	tar cvPf Tomcat_$ARCHIVE_NAME /home/tomcat/conf/Catalina/localhost/posCheckAcc.xml
	echo -e "*******����tomcat�ļ����*******"
fi

if `id smtfront > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����˹����ǰ���ļ������ݿ��*******"
	
		su - smtfront -c "dbaccess <<! > /dev/null 2>&1
		database smtfront;
		begin work;
		unload to tposinfo_$MYDATE-$MERCHANTNAME.unl select * from tposinfo;
		unload to tshopinfo_$MYDATE-$MERCHANTNAME.unl select * from tshopinfo;
		commit;
		close database;
		!"
	tar cvPf Smtfront_$ARCHIVE_NAME /home/smtfront/tposinfo_$MYDATE-$MERCHANTNAME.unl
	tar rvPf Smtfront_$ARCHIVE_NAME /home/smtfront/tshopinfo_$MYDATE-$MERCHANTNAME.unl
	tar rvPf Smtfront_$ARCHIVE_NAME /home/smtfront/front/etc/module.cfg
	tar rvPf Smtfront_$ARCHIVE_NAME /home/smtfront/front/etc/opercode.cfg
	tar rvPf Smtfront_$ARCHIVE_NAME /home/smtfront/front/sbin/smtftp.sh >/dev/null 2>&1
	tar rvPf Smtfront_$ARCHIVE_NAME /home/smtfront/front/sbin/backup.sh

	rm -f /home/smtfront/*$MYDATE-$MERCHANTNAME.unl
	echo -e "*******����˹����ǰ���ļ������ݿ�����*******"
fi

	
if `id wkfront > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����Ρ��ǰ���ļ������ݿ��*******"
	
		su - wkfront -c "dbaccess <<! > /dev/null 2>&1
		database wkfront;
		begin work;
		unload to tposinfo_$MYDATE-$MERCHANTNAME.unl select * from tposinfo;
		unload to tshopinfo_$MYDATE-$MERCHANTNAME.unl select * from tshopinfo;
		commit;
		close database;
		!"
	tar cvPf Wkfront_$ARCHIVE_NAME /home/wkfront/tposinfo_$MYDATE-$MERCHANTNAME.unl
	tar rvPf Wkfront_$ARCHIVE_NAME /home/wkfront/tshopinfo_$MYDATE-$MERCHANTNAME.unl
	tar rvPf Wkfront_$ARCHIVE_NAME /home/wkfront/front/etc/module.cfg
	tar rvPf Wkfront_$ARCHIVE_NAME /home/wkfront/front/etc/opercode.cfg
	tar rvPf Wkfront_$ARCHIVE_NAME /home/wkfront/front/sbin/wkftp.sh >/dev/null 2>&1
	tar rvPf Wkfront_$ARCHIVE_NAME /home/wkfront/front/sbin/backup.sh
		rm -f /home/wkfront/*$MYDATE-$MERCHANTNAME.unl
	echo -e "*******����Ρ��ǰ���ļ������ݿ�����*******"
fi

if `id ytjifs > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ�����ۺ�ǰ���ļ������ݿ��*******"
		su - ytjifs -c "dbaccess <<! > /dev/null 2>&1
		database ytjifs;
		begin work;
		unload to mch_arch_$MYDATE-$MERCHANTNAME.unl select * from mch_arch;
		unload to term_info_$MYDATE-$MERCHANTNAME.unl select * from term_info;
		commit;
		close database;
		!"
		tar cvPf Ytjifs_$ARCHIVE_NAME /home/ytjifs/front/sbin/ytjjnl_ftp.sh
		tar rvPf Ytjifs_$ARCHIVE_NAME /home/ytjifs/front/sbin/ytjjnl_unload.sh
		tar rvPf Ytjifs_$ARCHIVE_NAME /home/ytjifs/front/etc/*
		
		rm -f /home/ytjifs/*$MYDATE-$MERCHANTNAME.unl
		echo -e "*******�����ۺ�ǰ���ļ������ݿ�����********"
fi

if `id softdes > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����softdes�ļ�*********"
	tar cvPf Softdes_$ARCHIVE_NAME /home/softdes/start_softdes.sh
	tar rvPf Softdes_$ARCHIVE_NAME /home/softdes/etc/sysconfig
	tar rvPf Softdes_$ARCHIVE_NAME /home/softdes/bin/softdes_reboot.sh
	echo -e "*******����softdes�ļ����*********"
fi

if `id switch > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����switch�ļ�*********"
	tar cvPf Switch_$ARCHIVE_NAME /home/switch/etc/sysconfig
	tar rvPf Switch_$ARCHIVE_NAME /home/switch/bin/switch.sh
	echo -e "*******����switch�ļ����*********"
fi

if `id lianhua2 > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����lianhua2�ļ�*********"
	tar cvPf Lianhua2_$ARCHIVE_NAME /home/lianhua2/etc/sysconfig
	tar rvPf Lianhua2_$ARCHIVE_NAME /home/lianhua2/bin/magproc
	tar rvPf Lianhua2_$ARCHIVE_NAME /home/lianhua2/bin/CheckApp.sh
	echo -e "*******����lianhua2�ļ����*********"
fi

if `id pccard > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����pccard�ļ�*********"
	tar cvPf Pccard_$ARCHIVE_NAME /home/pccard/*
	echo -e "*******����pccard�ļ����*********"
fi

if `id bankswitch > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����bankswitch�ļ�*********"
	tar cvPf Bankswitch_$ARCHIVE_NAME /home/bankswitch/etc/sysconfig
	tar rvPf Bankswitch_$ARCHIVE_NAME /home/bankswitch/bin/switch.sh
	tar rvPf Bankswitch_$ARCHIVE_NAME /home/bankswitch/bin/BANKswitch
	tar rvPf Bankswitch_$ARCHIVE_NAME /home/bankswitch/bin/reboot.sh
	echo "*******����bankswitch�ļ����*********"
fi

if `id yclhtest > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����yclhtest�ļ�*********"
	tar cvPf Yclhtest_$ARCHIVE_NAME /home/yclhtest/etc/sysconfig
	tar rvPf Yclhtest_$ARCHIVE_NAME /home/yclhtest/bin/test11
	echo "*******����yclhtest�ļ����*********"
fi

if `id tmserver > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����tmserver�ļ�*********"
	tar cvPf Tmserver_$ARCHIVE_NAME /home/tmserver/etc/system.cfg
	tar rvPf Tmserver_$ARCHIVE_NAME /home/tmserver/etc/sysconfig
	tar rvPf Tmserver_$ARCHIVE_NAME /home/tmserver/bin/TMServer
	tar rvPf Tmserver_$ARCHIVE_NAME /home/tmserver/bin/TMServer.sh
	tar rvPf Tmserver_$ARCHIVE_NAME /home/tmserver/bin/TMSwitch
	tar rvPf Tmserver_$ARCHIVE_NAME /home/tmserver/bin/reboot.sh
	echo "*******����tmserver�ļ����*********"
fi

if `id ytjifsdes > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����ytjdes�ļ�*********"
	tar cvPf Ytjifsdes_$ARCHIVE_NAME /home/ytjifsdes/etc/sysconfig
	tar rvPf Ytjifsdes_$ARCHIVE_NAME /home/ytjifsdes/bin/ytjdes
	tar rvPf Ytjifsdes_$ARCHIVE_NAME /home/ytjifsdes/start_softdes.sh
	echo "*******����ytjdes�ļ����*********"
fi

if `id newdesjm > /dev/null 2>&1`
then
	echo -e "\n\n*******��ʼ����newdesjm�ļ�*********"
	tar cvPf Newdesjm_$ARCHIVE_NAME /home/newdesjm/bin/*
	tar rvPf Newdesjm_$ARCHIVE_NAME /home/newdesjm/etc/*
	echo "*******����newdesjm�ļ����*********"
fi

echo -e "\n\n*******��ʼѹ���ļ�*********"
tar czvf Whole_$ARCHIVE_NAME.gz *_$ARCHIVE_NAME *.log
echo "*******ѹ���ļ����*********"
rm -f *_$ARCHIVE_NAME
rm -f *.log