#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
TIMESTAMP=`/bin/date "+%y%m%d_%H%M%S"`
LOCAL_DUMP_PATH=/backup/files/

FTP_HOST=HOSTNAME
FTP_USER=srv-admin
FTP_PASS=*************
FTP_DIR=srv-admin

backup_dir()
{
	db=$1
	arc=$2
	echo backing up directory \"$db\"...
	tar -cJf - $db > ${LOCAL_DUMP_PATH}${arc}_${TIMESTAMP}.txz
}

ftp_upload_db()
{
	db=$1
	echo uploading backup of \"$db\" to ftp server...
	file=${LOCAL_DUMP_PATH}${db}_${TIMESTAMP}.txz
	if [ -f ${file} ]
	then
		cd `dirname ${file}`
		ftp -n ${FTP_HOST} > /dev/null << EOT
user ${FTP_USER} ${FTP_PASS}
mkdir ${FTP_DIR}
cd ${FTP_DIR}
put `basename ${file}`
bye
EOT
	fi
}
	
if [ $# -eq 0 ]
then
	echo "no directory name given"
	exit
fi

while [ $# -gt 0 ]
do
	arc=`echo $1 | sed "s/\//_/g"`
	backup_dir $1 $arc
	ftp_upload_db $arc
	shift
done
