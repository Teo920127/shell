#!/bin/bash
#2015-12-23
#use to suning
RN(){
	echo "$MID|$TID|$TID|1|0|3111111111111|||||||000000|||||0|||1||||" >> bk_pos_info_admin.unl
	echo "$TID|$MIS|" >> sn_tid_mis_admin.unl
	}
echo "pls input your mid"
echo -en "***************\n"
read MID
if [ ${#MID} -ne 15 ]
	then
		echo "MID must equal 15"
		exit 0
	else
		echo "pls input your first tid"
		echo -en "********\n"
		read FTID
		echo "pls input your end tid"
		echo -en "********\n"
		read ETID
		echo "mis pos or no mis pos(1,0)"
		echo -en "*\n"
		read MIS
fi

if [ ${#FTID} != 8  -a  ${#ETID} != 8 ]
	then
		echo "TID must equal 8"
		exit 0
	elif [ $FTID = $ETID ]
	then
		TID=$FTID
		RN
	elif [ ! -n "`echo $FTID | sed 's#[0-9]##g'`" ] 
	then
		FORNUM=`expr $ETID-$FTID|bc`
		TID=$FTID
		RN
		for((i=0;i<$FORNUM;i++))
			do
			TID=$(($TID+1))
			RN
			done
	else
		FTIDNUM=`echo $FTID|sed 's#.*[a-zA-Z]##g'`
		FTIDNUMBAK=$FTIDNUM
		ETIDNUM=`echo $ETID|sed 's#.*[a-zA-Z]##g'`
		FORNUM=`expr $ETIDNUM-$FTIDNUM|bc`
		TID=$FTID
		RN
		for((i=0;i<$FORNUM;i++))
			do
			FTIDNUM=`expr $FTIDNUM+1|bc`
			TIDFINAL=`printf "%.${#FTIDNUMBAK}d\n" $FTIDNUM`
			TID=`echo $FTID | sed "s#$FTIDNUMBAK\>#$TIDFINAL#g"`
			RN
			done	
fi

/home/informix/bin/dbaccess - - <<!
database emv;
begin work;
load from bk_pos_info_admin.unl insert into bk_pos_info;
load from sn_tid_mis_admin.unl insert into sn_tid_mis;
commit;
close database;
!

rm -rf bk_pos_info_admin.unl
rm -rf sn_tid_mis_admin.unl

