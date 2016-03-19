##################################################################

##   rman.sh     ##

##   created by Guogong Zhou   ##

##   2011-06-01     ##

##################################################################
#!/bin/bash
#set env

#按照实际情况修改以下内容--start----#
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:
export NLS_LANG=American_america.ZHS16GBK
export PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_SID=SWSJZX
echo "------------------------------start------------------------------"
DATE=$(date +%Y%m%d)
BACKUP_PATH=/u01/app/backup/${DATE}
mkdir -p ${BACKUP_PATH}
LEVEL=$@
LogFile=${BACKUP_PATH}/${DATE}_${LEVEL}.log
echo $LEVEL

#按照实际情况修改内容－－－－end---#
rman target / nocatalog log=${LogFile}<<EOF
list backup summary;
list backupset;
run{
allocate channel ch01 device type  disk;
allocate channel ch02 device type  disk;
allocate channel ch03 device type  disk;
allocate channel ch04 device type  disk;
allocate channel ch05 device type  disk;
backup AS COMPRESSED BACKUPSET incremental level ${LEVEL} filesperset=2  format ='${BACKUP_PATH}/full_level${LEVEL}_${DATE}_%U' tag level${LEVEL}_db_${DATE} (database);
backup format='${BACKUP_PATH}/controlfile_${DATE}_%U'  tag cfile_${DATE} (current controlfile);
crosscheck backupset;
release channel ch05;
release channel ch04;
release channel ch03;
release channel ch02;
release channel ch01;
allocate channel ch06 device type  disk;
backup archivelog all tag='archivelog_${DATE}' format='${BACKUP_PATH}/archivelog_${DATE}_%U' skip inaccessible  filesperset 5  delete input;
release channel ch06;
}

crosscheck backup;
delete noprompt expired backup;
report obsolete;
delete noprompt obsolete;

exit;
EOF
echo "------------------------------end------------------------------"

