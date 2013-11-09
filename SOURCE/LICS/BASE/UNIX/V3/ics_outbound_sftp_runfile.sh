#!/bin/ksh
#
##############################################
# Simple script that runs sftp for ics_outbound_sftp.sh script
# when using MAESTRO to submit the job
# ics_outbound_sftp_runfile.sh
##############################################
#
# echo "SFTP LOG [" ${SFTP_LOG} "]"
#
sftp -v ${DEST_USER}@${DEST_SERVER} >> ${SFTP_LOG} 2>&1 << EOF
#user ${DEST_USER} ${DEST_PWORD}
#copylocal
put ${FILE} ${DEST_PATH}~${DEST_NAME}
mv ${DEST_PATH}~${DEST_NAME} ${DEST_PATH}${DEST_NAME}
bye
EOF

