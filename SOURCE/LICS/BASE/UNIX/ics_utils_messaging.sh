# ---------------------------------------------------------------------------
#
# Description:
# Utilities file for processing interface files for MQIF, MQFT, DJ, FTP, etc.
#
# Note:
# No #!/bin/ksh needed in this file as it should not create a new shell to
# run the functions in.
#
# Date          Who         Change History
# ------------  -------     -------------------------
# 29-OCT-2007   T. Keon     Creation
# 07-MAR-2008   L. Glen     Added set_permission call within process_passthru_mqft
# 13-MAY-2008   S. Gregan   Added pipe to TMP_OUT for java calls within get_file_from_sap
# 13-MAY-2008   S. Gregan   Added oracle classes12.jar to java calls within get_file_from_sap
# 18-JUN-2008   T. Keon     Added SHLIB_PATH variable
#
# ---------------------------------------------------------------------------

# Include the utilities script file for common functionality
. ${SCRIPT_PATH}/ics_utilities.sh

# ---------------------------------------------------------------------------
# Function Locations (line numbers):
# ---------------------------------------------------------------------------
# check_FTP_log -               71
# get_file_from_dj -            111
# get_file_from_sap -           148
# get_mq_message -              194
# process_inbound -             229
# process_inbound_dj -          275
# process_inbound_mqft -        302
# process_inbound_sap -         339
# process_inbound_vds -         371
# process_outbound -            391
# process_outbound_ftp -        460
# process_passthru_dj -         503
# process_passthru_mq -         517
# process_passthru_mqft -       530
# queue_depth -                 550
# send_file_via_mqft_to_CDW -   585
# send_file_via_mqft_to_HK -    605
# trigger_queue -               627
# validate_dequeue_file -       653
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
#
# Global Variables:
# These should never be changed by other shell scripts, and should never be
# redefined externally.  If you could set variables as read only in unix
# scripting, then these would be set as such.  So treat them as read only!
#
# ---------------------------------------------------------------------------

ASN=0
DJ=1
MQIF=2
MQFT=3
MQIF_PASSTHRU=7
MQFT_ROUTE=8

# --------------------------------------------------------------------------
#
# check_FTP_log Description:
# Checks the status message of the FTP log
#
# Parameters:
# 1 - The file to extract the status message from
#
# --------------------------------------------------------------------------
check_FTP_log()
{
    FILE_INT=${1}
    
    grep -i "Transfer complete" ${FILE_INT} > /dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
        grep -i "Login incorrect" ${FILE_INT} > /dev/null 2>&1
        if [[ $? -eq 0 ]] ; then
            error_exit "ERROR: [check_log] Username/Password incorrect"
        fi
        
        grep -i "Unknown host" ${FILE_INT} > /dev/null 2>&1
        if [[ $? -eq 0 ]] ; then
            error_exit "ERROR: [check_log] Unknown Destination Host [${DEST_SERVER}]"
        fi
        
        grep -i "path name does not exist" ${FILE_INT} > /dev/null 2>&1
        if [[ $? -eq 0 ]] ; then
            error_exit "ERROR: [check_log] Path name does not exist [${DEST_PATH}]"
        fi
        
        grep -i "file access permissions" ${FILE_INT} > /dev/null 2>&1
        if [[ $? -eq 0 ]] ; then
            error_exit "ERROR: [check_log] Invalid File Access Permissions [${DEST_PATH}]"
        fi
        
        error_exit "ERROR: [check_log] An unknown error has occured during FTP"
    fi
    
    log_file "INFO: [check_log] Verified FTP transaction successful" "HARMLESS"
}

# ---------------------------------------------------------------------------
#
# get_file_from_dj Description:
# Get the file from the data junction queue.
#
# Parameters: <none>
#
# ---------------------------------------------------------------------------
get_file_from_dj()
{
    log_file "INFO: [get_file_from_dj] Getting file from queue : [${QUEUE}]" "HARMLESS" 
    log_file "INFO: [get_file_from_dj] Executing command [${AMI_PATH}/bin/dj/msg2file.sh -queue ${QUEUE} -interface ${INTERFACE_ID} -file ${Q_FILE} ${DJ_PARAM}]" "HARMLESS"
    
    # Call generic script to get file from queue
    ${AMI_PATH}/bin/dj/msg2file.sh -queue ${QUEUE} -interface ${INTERFACE_ID} -file ${Q_FILE} ${DJ_PARAM} >> ${TMP_OUT} 2>&1
    rc=$?
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: [get_file_from_dj] Call to msg2file.sh Failed. Return Code [${rc}]"
    else
        log_file "INFO: [get_file_from_dj] Processing msg2file successful" "HARMLESS"
    fi
    
    if [[ $IS_COMPRESSED -eq 1 ]] ; then
        toggle_file_compression ${Q_FILE} 1 
        
        # set the file to the correct name after decompressing
        Q_FILE=$DECOMPRESS_FILE_NAME
    fi
    
    log_file "INFO: [get_file_from_dj] Processing file [${Q_FILE}]" "HARMLESS"
    set_permissions $Q_FILE
    
    # validate dequeued file and call oracle proc to load file
    validate_dequeue_file "${Q_FILE}" 1 1
}

# ---------------------------------------------------------------------------
#
# get_file_from_sap Description:
# Get the file from SAP.
#
# Parameters:
# 1 - Set as 0 if for SAP, 1 if for VDS
# 
# ---------------------------------------------------------------------------
get_file_from_sap()
{
    TYPE_INT=$1    
    log_file "INFO: [get_file_from_sap] Getting file from SAP : [${INTERFACE_ID}]" "HARMLESS"

    export SHLIB_PATH=${SHLIB_PATH} 

    if [[ $TYPE_INT -eq 0 ]] ; then
        log_file "INFO: [get_file_from_sap] Executing command [${JAVA_PATH} -Xmx512m -cp ${SHLIB_PATH}:${ICS_CLASS_PATH}:${SHLIB_PATH}/marsap.jar:${SHLIB_PATH}/classes12.jar:${SHLIB_PATH}/sapjco.jar com.isi.sap.cSapInterface -identifier ${CFG_ID} -configuration ${SAP_CFG} -output ${OUT_FILE} -user ${SAP_USER} -password xxx >> ${TMP_OUT} 2>&1]" "HARMLESS"
        ${JAVA_PATH} -Xmx512m -cp ${SHLIB_PATH}:${ICS_CLASS_PATH}:${SHLIB_PATH}/marsap.jar:${SHLIB_PATH}/classes12.jar:${SHLIB_PATH}/sapjco.jar com.isi.sap.cSapInterface -identifier ${CFG_ID} -configuration ${SAP_CFG} -output ${OUT_FILE} -user ${SAP_USER} -password ${SAP_PWD} >> ${TMP_OUT} 2>&1
    else
        log_file "INFO: [get_file_from_sap] Executing command [${JAVA_PATH} -Xmx512m -cp ${SHLIB_PATH}:${ICS_CLASS_PATH}:${SHLIB_PATH}/marsap.jar:${SHLIB_PATH}/classes12.jar:${SHLIB_PATH}/sapjco.jar com.isi.sap.cSapDualInterface -identifier ${CFG_ID} -configuration ${VDS_CFG} -output ${OUT_FILE} -user01 ${SAP_USER_01} -password01 xxx -user02 ${SAP_USER_02} -password02 xxx >> ${TMP_OUT} 2>&1]" "HARMLESS"
        ${JAVA_PATH} -Xmx512m -cp ${SHLIB_PATH}:${ICS_CLASS_PATH}:${SHLIB_PATH}/marsap.jar:${SHLIB_PATH}/classes12.jar:${SHLIB_PATH}/sapjco.jar com.isi.sap.cSapDualInterface -identifier ${CFG_ID} -configuration ${VDS_CFG} -output ${OUT_FILE} -user01 ${SAP_USER_01} -password01 ${SAP_PWD_01} -user02 ${SAP_USER_02} -password02 ${SAP_PWD_02} >> ${TMP_OUT} 2>&1
    fi
    
    rc=$?
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: [get_file_from_sap] Call to ${JAVA_PATH} Failed - Return Code [${rc}]"
    else
        log_file "INFO: [get_file_from_sap] Processing ${JAVA_PATH} successful" "HARMLESS"
    fi

    if [[ $IS_COMPRESSED -eq 1 ]] ; then
        toggle_file_compression ${OUT_FILE} 1 
        
        # set the file to the correct name after decompressing
        OUT_FILE=$DECOMPRESS_FILE_NAME
    fi
    
    log_file "INFO: [get_file_from_sap] Processing file [${OUT_FILE}]" "HARMLESS"

    # validate Sap file
    validate_dequeue_file "${OUT_FILE}" 0 1
    set_permissions $OUT_FILE
}

# ---------------------------------------------------------------------------
#
# get_mq_message Description:
# Get the MQ message.
#
# Parameters: 
# 1 - Set whether to ignore compression or not
# 
# ---------------------------------------------------------------------------
get_mq_message()
{
    log_file "INFO: [get_mq_message] Executing MQIF command [${AMI_PATH}/bin/mq/mqif.pl -g -h -q ${QUEUE} -o ${Q_FILE}]" "HARMLESS"   

    # get the mq message
    MQIF_RC=`${AMI_PATH}/bin/mq/mqif.pl -g -h -q ${QUEUE} -o ${Q_FILE} 2>&1`
    rc=$?
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: [get_mq_message] MQIF return non-zero. MQIF rc [${rc}]"
    fi
    
    echo "MQIF sequence [${MSG_SEQ}] return [${MQIF_RC}]" >> $TMP_OUT
    echo $MQIF_RC | grep "ERR" >> $TMP_OUT 2>&1
    if [[ $? -eq 0 ]] ; then
        error_exit "ERROR: [get_mq_message] MQIF command failed. MQIF returned: [${MQIF_RC}]."
    fi
    
    if [[ $1 -eq 0 && $IS_COMPRESSED -eq 1 ]] ; then
        toggle_file_compression ${Q_FILE} 1 
        
        # set the file to the correct name after decompressing
        Q_FILE=$DECOMPRESS_FILE_NAME
    fi
}

# --------------------------------------------------------------------------
#
# process_inbound Description:
# Process an inbound advanced shipping notice (ASN) or MQ interface.
#
# Parameters:
# 1 - The type of inbound interface being processed
# 2 - Set whether to ignore compression or not
#
# --------------------------------------------------------------------------
process_inbound()
{
    queue_depth "GET_MSG" 1

    while [[ $Q_DEPTH -gt 0 ]]
    do      
        Q_FILE="${INBOUND_PATH}/${INTERFACE_ID}_${NOW}_${PRC_ID}_${MSG_SEQ}.DAT"
        
        get_mq_message $2
        
        # load file to oracle
        log_file "INFO: [process_inbound] Processing file [${Q_FILE}]" "HARMLESS"
        
        # validate dequeued file
        validate_dequeue_file "${Q_FILE}" 1 1
        set_permissions $Q_FILE
        
        # call oracle proc to load file
        if [[ $1 -eq $ASN ]] ; then
            load_file $LOAD_FILE_INBOUND "TOLASN01" "${Q_FILE}"
            load_file $LOAD_FILE_INBOUND "TOLASN01.1" "${Q_FILE}"     
        elif [[ $1 -eq $MQIF ]] ; then
            load_file $LOAD_FILE_INBOUND "${INTERFACE_ID}" "${Q_FILE}"
        elif [[ $1 -eq $MQIF_PASSTHRU ]] ; then
            load_file $LOAD_FILE_PASSTHRU "${INTERFACE_ID}" "${Q_FILE}"
        else
            error_exit "ERROR: [process_inbound] Provided type is not valid [$1]"
        fi
        
        if [[ $1 -ne $MQIF_PASSTHRU ]] ; then
            archive_file "${Q_FILE}"
        fi
        
        MSG_SEQ=`expr $MSG_SEQ + 1`
        queue_depth "GET_MSG" 1
    done
}

# --------------------------------------------------------------------------
#
# process_inbound_dj Description:
# Process an inbound data junction interface.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_inbound_dj()
{
    get_file_from_dj
    load_file $LOAD_FILE_INBOUND "${DJ_MAP}" "${Q_FILE}"
    
    # Send files via MQFT to CDW if param is not equal to *NONE
    if [[ ! -z $FORWARD_Q && $FORWARD_Q != *NONE ]] ; then
        send_file_via_mqft_to_CDW
    fi

    # Send files via MQFT to HK if param is not equal to *NO
    if [[ ! -z $FORWARD_HK && $FORWARD_HK != *NO ]] ; then
        send_file_via_mqft_to_HK
    fi
        
    archive_file "${Q_FILE}"
}

# --------------------------------------------------------------------------
#
# process_inbound_mqft Description:
# Process an inbound MQFT interface.
#
# Parameters:
# 1 - The file to process
# 
# --------------------------------------------------------------------------
process_inbound_mqft()
{
    FILE_INT=$1
    log_file "INFO: [process_inbound_mqft] Processing file [${FILE_INT}]" "HARMLESS"

    if [[ $IS_COMPRESSED -eq 1 ]] ; then
        toggle_file_compression ${FILE_INT} 1 
        
        # set the file to the correct name after decompressing
        FILE_INT=$DECOMPRESS_FILE_NAME
    fi
    
    # validate file
    validate_file "${FILE_INT}"
    set_permissions "${FILE_INT}"

    # Call oracle proc to load file
    if [[ $DATA_FLOW_TYPE -eq $INBOUND ]] ; then
        load_file $LOAD_FILE_INBOUND "${INTERFACE_ID}" "${FILE_INT}"
    elif [[ $DATA_FLOW_TYPE -eq $ROUTE ]] ; then
        load_file $LOAD_FILE_ROUTER "${INTERFACE_ID}" "${FILE_INT}"
    else
        error_exit "ERROR: [process_inbound_mqft] DATA_FLOW_TYPE invalid. [${DATA_FLOW_TYPE}]."
    fi
    
    # Archive received file
    archive_file "${FILE_INT}"
}

# --------------------------------------------------------------------------
#
# process_inbound_sap Description:
# Process an inbound SAP interface.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_inbound_sap()
{
    get_file_from_sap 0

    # call oracle proc to load file
    load_file $LOAD_FILE_INBOUND "${INTERFACE_ID}" "${OUT_FILE}"

    # Load file onto queue for CDW if param is not equal to *NONE
    if [[ ${FORWARD_Q} != *NONE ]] ; then
        log_file "INFO: [process_inbound_sap] Executing command [cat ${OUT_FILE} | ${MQIF} -p -q ${FORWARD_Q} -r 0 -o ${OUT_FILE}]" "HARMLESS"      
        MQIFRC=`cat ${OUT_FILE} | ${MQIF} -p -q ${FORWARD_Q} -r 0 -o ${OUT_FILE} 2>&1`
        rc=$?
        
        echo "MQIF return [${MQIFRC}]" >> ${TMP_OUT} 2>&1      
        if [[ $rc -ne 0 ]] ; then
            error_exit "ERROR: [process_inbound_sap] MQIF command failed, see [${TMP_OUT}]"
        else
            log_file "INFO: [process_inbound_sap] MQIF command processed" "HARMLESS"
        fi
    fi

    archive_file "${OUT_FILE}"
}

# --------------------------------------------------------------------------
#
# process_inbound_vds Description:
# Process an inbound VDS interface.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_inbound_vds()
{
    get_file_from_sap 1

    # call oracle proc to load file
    load_file $LOAD_FILE_INBOUND "${INTERFACE_ID}" "${OUT_FILE}"   

    archive_file"${OUT_FILE}"
}

# --------------------------------------------------------------------------
#
# process_outbound Description:
# Process the specified outbound interface.
#
# Parameters:
# 1 - The file to process
# 2 - The type of outbound interface being processed
#
# --------------------------------------------------------------------------
process_outbound()
{
    FILE_INT=$1
    OUTBOUND_TYPE=$2
    
    log_file "INFO: [process_outbound] IS_COMPRESSED = ${IS_COMPRESSED}" "HARMLESS"
    
    if [[ $IS_COMPRESSED -eq 1 ]] ; then
        toggle_file_compression $FILE_INT 0
        FILE_INT=$COMPRESS_FILE_NAME       # set the correct filename to process
        
        if [[ ! -z $T_FILE_NAME ]] ; then
            T_FILE_NAME="${T_FILE_NAME}.gz"
        fi
    fi
    
    log_file "INFO: [process_outbound] Processing file [${FILE_INT}] for type [${OUTBOUND_TYPE}]" "HARMLESS"
    validate_file "${FILE_INT}"

    case $OUTBOUND_TYPE in
        $DJ)
            log_file "INFO: [process_outbound] Executing command [${AMI_PATH}/bin/dj/file2msg.sh -queue ${QUEUE} -interface ${INTERFACE_ID} -file ${FILE_INT}]" "HARMLESS"
            ${AMI_PATH}/bin/dj/file2msg.sh -queue ${QUEUE} -interface ${INTERFACE_ID} -file ${FILE_INT} >> ${TMP_OUT} 2>&1
            ;;
        $MQIF)
            log_file "INFO: [process_outbound] Executing command [cat ${FILE_INT} | ${AMI_PATH}/bin/mq/mqif.pl -p -q ${QUEUE} -r 0 -o ${T_FILE_NAME}]" "HARMLESS"
            cat ${FILE_INT} | ${AMI_PATH}/bin/mq/mqif.pl -p -q ${QUEUE} -r 0 -o ${T_FILE_NAME} >> ${TMP_OUT} 2>&1
            ;;
        $MQFT)
            log_file "INFO: [process_outbound] Executing command [${MQFT_SEND_PATH} -source ${S_QMGR},${FILE_INT} -target ${T_QMGR},${DEST_DIR}/${T_FILE_NAME} ${MQFT_SEND_PARAM}]" "HARMLESS"
            ${MQFT_SEND_PATH} -source ${S_QMGR},${FILE_INT} -target ${T_QMGR},${DEST_DIR}/${T_FILE_NAME} ${MQFT_SEND_PARAM} >> ${TMP_OUT} 2>&1
            ;;
        *)
            error_exit "ERROR: [process_outbound] Outbound type is not valid [${OUTBOUND_TYPE}]"
            ;;
    esac   

    rc=$?
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: [process_outbound] Process command failed. Return Code [${rc}]"
    fi
    
    log_file "INFO: [process_outbound] Processing file2msg successful" "HARMLESS" 
    
    if [[ $IS_COMPRESSED -eq 1 ]] ; then
        archive_file "${FILE_INT}" 1
    else
        archive_file "${FILE_INT}" 0
    fi
}

# --------------------------------------------------------------------------
#
# process_outbound_ftp Description:
# Process the outbound FTP interface.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_outbound_ftp()
{    
    if [[ ! -z ${DEST_PATH##*/} || ! -z ${DEST_PATH%%/*} ]] ; then
        error_exit "ERROR: [process_outbound_ftp] Destination path must start and end with /"
    fi

    log_file "INFO: [process_outbound_ftp] Verified destination path valid [${DEST_PATH}]" "HARMLESS"
    
    # Ping destination server 3 times using the correct ping command for the operating system
    if [ $CURRENT_OS = $HP_UNIX_OS ] ; then    
        ping $DEST_SERVER -n 3 >> /dev/null 2>&1
    elif [ $CURRENT_OS = $LINUX_OS ] ; then
        ping $DEST_SERVER -c 3 >> /dev/null 2>&1
    else
        error_exit "ERROR: [process_outbound_ftp] Specified O/S [${CURRENT_OS}] is not supported"
    fi
    
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [process_outbound_ftp] Destination Server [${DEST_SERVER}] unreachable"
    fi

    log_file "INFO: [process_outbound_ftp] Verified destination server [${DEST_SERVER}] reachable" "HARMLESS"
    log_file "INFO: [process_outbound_ftp] Executing command [${BIN_PATH}/ics_outbound_ftp_runfile.sh] " "HARMLESS"

    eval "${BIN_PATH}/ics_outbound_ftp_runfile.sh" >> $TMP_OUT 2>&1
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [process_outbound_ftp] FTP job failed."
    fi

    log_file "INFO: [process_outbound_ftp] FTP job ran successfully " "HARMLESS"
    
    check_FTP_log "${TMP_OUT}"
    archive_file "${FILE}"
}

# --------------------------------------------------------------------------
#
# process_passthru_dj Description:
# Process the passthru data junction interface.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_passthru_dj()
{
    get_file_from_dj
    load_file $LOAD_FILE_PASSTHRU "${DJ_MAP}" "${Q_FILE}"
}

# --------------------------------------------------------------------------
#
# process_passthru_mq Description:
# Process the passthru MQIF interface.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_passthru_mq()
{
    process_inbound $MQIF_PASSTHRU 1
}

# --------------------------------------------------------------------------
#
# process_passthru_mqft Description:
# Process the passthru MQFT interface.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_passthru_mqft()
{
    log_file "INFO: [process_inbound_mqft] Processing file [${FILENAME}]" "HARMLESS"

    set_permissions "${FILENAME}"
    load_file $LOAD_FILE_PASSTHRU "${INTERFACE_ID}" "${FILENAME}"
}

# ---------------------------------------------------------------------------
#
# queue_depth Description:
# Checks the depth of the queue.  If the queue is empty and the mode
# is not set, or set to "INIT" then return 1 so the calling function can
# exit gracefully (after a clean_up).
#
# Parameters:
# 1 - The mode to use when viewing the queue (GET_MSG or INIT). Set to "NIL" if not
# applicable
# 2 - Set whether to exit in this function or return a flag indicating whether
# to exit or not.  Allows for unique files to be cleaned up which are not included
# in the clean_up function in the utilities script
# 
# ---------------------------------------------------------------------------
queue_depth()
{
    DEPTH_MODE_INT=$1
    
    eval Q_DEPTH=`echo "DISPLAY QUEUE(${QUEUE}) CURDEPTH" | runmqsc ${AMI_QMGR} | perl -lne 'print if s/^.*CURDEPTH\((\d+)\).*$/$1/' | awk '{print $1}'`
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [queue_depth] Error checking qdepth for queue [${QUEUE}]"
    fi
    
    if [[ $Q_DEPTH -eq 0 && $DEPTH_MODE_INT != GET_MSG ]] ; then
        log_file "WARNING: [queue_depth]:[${DEPTH_MODE_INT}] Queue [${QUEUE}] has [${Q_DEPTH}] messages - not necessary to run MQIF: Exiting ..." "HARMLESS"
        
        trigger_queue "TRIGGER"     # turn the trigger back on
        clean_up                    # cleanup 
        
        if [[ $2 -eq 0 ]] ; then
            return 1                # return 1 so the calling function can cleanup unique files and exit gracefully 
        else
            exit 0
        fi
    else
        log_file "INFO: [queue_depth]:[${DEPTH_MODE_INT}] Current queue depth [${QUEUE}]:[${Q_DEPTH}]" "HARMLESS"
    fi
    
    return 0
}

# --------------------------------------------------------------------------
#
# send_file_via_mqft_to_CDW Description:
# Send files via MQFT to CDW.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
send_file_via_mqft_to_CDW()
{
    log_file "INFO: [send_file_via_mqft_to_CDW] Executing command [${AMI_PATH}/bin/mqft/mqftssnd -source ${AMI_QMGR},${Q_FILE} -target ${TARG_QMGR},${TARG_PATH}/${TARG_FILE}]" "HARMLESS"      
    
    ${AMI_PATH}/bin/mqft/mqftssnd -source ${AMI_QMGR},${Q_FILE} -target ${TARG_QMGR},${TARG_PATH}/${TARG_FILE} >> ${TMP_OUT} 2>&1
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [send_file_via_mqft_to_CDW] MQFT command failed, see [${TMP_OUT}]"
    else
        log_file "INFO: [send_file_via_mqft_to_CDW] MQFT command processed" "HARMLESS"
    fi
}

# --------------------------------------------------------------------------
#
# send_file_via_mqft_to_CDW Description:
# Send files via MQFT to HK.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
send_file_via_mqft_to_HK()
{
    log_file "INFO: [send_file_via_mqft_to_HK] Executing command [${AMI_PATH}/bin/mqft/mqftssnd -source ${AMI_QMGR},${Q_FILE} -target ${HK_TARG_QMGR},${HK_TARG_PATH}/${DJ_MAP}]" "HARMLESS"
    
    ${AMI_PATH}/bin/mqft/mqftssnd -source ${AMI_QMGR},${Q_FILE} -target ${HK_TARG_QMGR},${HK_TARG_PATH}/${DJ_MAP} >> ${TMP_OUT} 2>&1
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [send_file_via_mqft_to_HK] MQFT command failed, see [${TMP_OUT}]"
    else
        log_file "INFO: [send_file_via_mqft_to_HK] MQFT command processed" "HARMLESS"
    fi
}

# ---------------------------------------------------------------------------
#
# trigger_queue Description:
# Trigger the status of the queue.
#
# Parameters:
# 1 - The trigger action to perform (TRIGGER or NOTRIGGER)
#
# ---------------------------------------------------------------------------
trigger_queue()
{
    ACTION_INT=$1
    
    log_file "INFO: [trigger_queue] Action to run [${ACTION_INT}]" "HARMLESS"
    
    echo "ALTER QLOCAL (${QUEUE}) ${ACTION_INT} " | runmqsc $AMI_QMGR >> $TMP_OUT 2>&1
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [trigger_queue] ALTER Trigger on Q [${QUEUE}] Failed"
    else
        log_file "INFO: [trigger_queue] Queue/Qmgr [${QUEUE}]/[${AMI_QMGR}] altered to [${ACTION_INT}]" "HARMLESS"
    fi
}

# ---------------------------------------------------------------------------
#
# validate_dequeue_file Description:
# Checks the file and if the file is empty then exit gracefully.
#
# Parameters: 
# 1 - The file to validate
# 2 - Set whether to turn the queue trigger back on (0 = false, 1 = true)
# 3 - Set whether to exit in this function or return a flag indicating whether
#   to exit or not.  Allows for unique files to be cleaned up which are not included
#   in the clean_up function in the utilities script
#
# ---------------------------------------------------------------------------
validate_dequeue_file()
{
    FILE_INT=$1

    log_file "INFO: [validate_dequeue_file] Validating file from queue [${QUEUE}]:[${FILE_INT}]" "HARMLESS"

    if [[ ! -a $FILE_INT ]] ; then
        error_exit "ERROR: [validate_dequeue_file] File not found [${FILE_INT}]"
    elif [[ ! -r $FILE_INT ]] ; then
        error_exit "ERROR: [validate_dequeue_file] Cannot read from file [${FILE_INT}]"
    fi

    # DJ produced a 0B file - issue minor alarm, turn queue trigger back on, and exit.
    if [[ ! -s $FILE_INT ]] ; then
        log_file "INFO: [validate_dequeue_file] Dequeue File empty [${FILE_INT}]" "HARMLESS"
        
        if [[ $2 -eq 1 ]] ; then
            trigger_queue "TRIGGER"
        fi
        
        log_file "INFO: [validate_dequeue_file] Completion of script [${SCRIPT_ID}] for queue [${QUEUE}]" "HARMLESS"
        clean_up
        
        if [[ $3 -eq 0 ]] ; then
            return 1    # return 1 so the calling function can cleanup unique files and exit gracefully 
        else
            exit 0
        fi
    fi
    
    return 0
}
