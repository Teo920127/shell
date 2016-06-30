#!/bin/bash
ROOTCHUNK=`onstat -d | grep "/home/ifxdata/rootchunk" |awk '{ print $5 }'`
DATACHUNK=`onstat -d | grep "/home/ifxdata/datachunk" |awk '{ print $5 }'`
ROOTCHUNKFREE=`onstat -d | grep "/home/ifxdata/rootchunk" |awk '{ print $6 }'`
DATACHUNKFREE=`onstat -d | grep "/home/ifxdata/datachunk" |awk '{ print $6 }'`
MAGVER=`magproc -all|sed -n '2p'`
DISKALL=`df -h | sed -n '3p' | awk '{print $1}'`
DISKFREE=`df -h | sed -n '3p' | awk '{print $2}'`
NOWTIME=`date +%H:%M:%S`

for DATAALL in $DATACHUNK
do
	sun=$(($sun+$DATAALL))
done

for DATAALLFREE in $DATACHUNKFREE
do
	moon=$(($moon+$DATAALLFREE))
done

echo " magproc   : $MAGVER "
echo " rootchunk : $ROOTCHUNK/$ROOTCHUNKFREE "
echo " datachunk : $sun/$moon "
echo " diskspace : $DISKALL ; diskfree : $DISKFREE "
echo " Now time is $NOWTIME "
