#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_cdw_resend.sh
# AUTHOR  : Trevor Keon
# DATE    : 10-May-2008
# PARAMS  : 1 - FILE NAME (file containing files to resend)
#           2 - INTERFACE ID (interface id of files being resent)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
#  Modification history at end of script
#
#  This script is used to resend files from LADS to CDW.  To use this script
#  you need to add the filenames which need to be resent to a file.  This will
#  only send for a single interface.
#  Use the following command to get a list of filenames from the archive dir:
#
#   ls -al ATLLAD10* | awk '{print $9}'
#
# ---------------------------------------------------------------------------

SCRIPT_PATH=${0%/*}

# Includes the utility files so we can access their variables and functions
. ${SCRIPT_PATH}/ics_utilities.sh

# --------------------------------------------------------------------------
#
# setup_config Description:
# Configure the scripts variables
#
# Parameters:
# 1 - The basename of the program as it was called (i.e. $0 from the calling
#   script.
#
# --------------------------------------------------------------------------
setup_config() 
{   
    LOG_TYPE=$LOG_TO_TEMP
    
    # initialise the utlities script
    initialise_utilities $1
    read_variable "TEMP_PATH"
    
    CDW_FILE="${INTERFACE_ID}.DAT"
}

# --------------------------------------------------------------------------
#
# process_resend_file Description:
# Process the file to resend the files to CDW.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_resend_file()
{
    # assign file descriptor 3 to input file
    exec 3< $FILENAME

    # read til the end of the file
    until [ $EOF ]
    do
        read <&3 FILE_LINE
        if [ $? != 0 ]; then
            EOF=1
            continue
        fi
        
        if [[ ! -z $FILE_LINE ]] ; then
            copy_to_temp $FILE_LINE
            toggle_file_compression $TARG_FILE 1
            
            send_file $DECOMPRESS_FILE_NAME
            clean_up_file $DECOMPRESS_FILE_NAME
            
            sleep 2
        fi
    done 
}

# --------------------------------------------------------------------------
#
# copy_to_temp Description:
# Copy the specified file from the archive directory to the temp directory.
#
# Parameters:
# 1 - The name of the file to copy.
#
# --------------------------------------------------------------------------
copy_to_temp()
{
    FILE_INT="${ARCHIVE_PATH}/$1"
    TARG_FILE="${TEMP_PATH}/$1"
    
    validate_file $FILE_INT
    
    CMD="cp ${FILE_INT} ${TARG_FILE}"

    log_file "INFO: [copy_to_temp] Running command [${CMD}]" "HARMLESS"
    
    `$CMD >> ${TMP_OUT} 2>&1`
    rc=$?
    
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: [copy_to_temp] Failed to copy file.  Return code [${rc}]."            
    fi    
}

# --------------------------------------------------------------------------
#
# copy_to_temp Description:
# Copy the specified file from the archive directory to the temp directory.
#
# Parameters:
# 1 - The name of the file to copy.
#
# --------------------------------------------------------------------------
send_file()
{
    FILE_INT="$1"
    CMD="${AMI_PATH}/bin/mqft/mqftssnd -source ${AMI_QMGR},${FILE_INT} -target ${TARG_QMGR},${TARG_PATH}/${CDW_FILE}"
    
    log_file "INFO: [send_file] Running command [${CMD}]" "HARMLESS"
    
    `$CMD >> ${TMP_OUT} 2>&1`
    rc=$?
    
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: [send_file] MQFT send failed to CDW.  Return code [${rc}]."            
    fi
    
    log_file "INFO: [send_file] File [${FILE_INT}] has been sent successfully." "HARMLESS"
}

# --------------------------------------------------------------------------
#
# check_params Description:
# Ensure that passed parameters have values.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
check_params()
{
    if [[ -z $FILENAME ]] ; then
        error_exit "ERROR: [check_params] Filename Parameter not specified"
    elif [[ -z $INTERFACE_ID ]] ; then
        error_exit "ERROR: [check_params] Interface Type Parameter not specified"
    else
        log_file "INFO: [check_params] Verified script input parameters" "HARMLESS"
    fi
}

# --------------------------------------------------------------------------
#
# clean_up_local Description:
# Cleanup any temporary files created by this script.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
clean_up_local()
{
    clean_up
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

FILENAME=${1}               # Variable: File containing files to send
INTERFACE_ID=${2}           # Variable: Interface type

setup_config $0             # Function: Setup script variables

log_file "INFO: Initialized script for interface [${INTERFACE_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check passed parameters have values
process_resend_file         # Function: Process file
clean_up_local              # Function: Remove Temporary Files

log_file "INFO: Completion of script [${SCRIPT_ID}] for interface [${INTERFACE_ID}] " "HARMLESS"

exit 0                      # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     10-MAY-2008 T. Keon       Original
# ---------------------------------------------------------------------------
