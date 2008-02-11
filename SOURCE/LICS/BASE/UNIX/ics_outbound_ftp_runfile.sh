#!/bin/ksh
#
##############################################
# Simple script that runs ftp for ics_outbound_ftp.sh script
# when using MAESTRO to submit the job
##############################################   

# echo "FTP LOG [" ${FTP_LOG} "]"

ftp -ivn ${DEST_SERVER} >> ${FTP_LOG} 2>&1 << EOF
user ${DEST_USER} ${DEST_PWORD}
copylocal
put ${FILE} ${DEST_PATH}${DEST_NAME}
bye
EOF
