#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_mailer.sh
# AUTHOR  : Linden Glen
# DATE    : 20-October-2005
# PARAMS  : 1 - MAIL FILE - File to mail (Email body)
#           2 - INTERFACE - ICS Interface ID
#           3 - TO_ADDR - To mail address
#           4 - SUBJECT - Mail Subject
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
#  Modification history at end of script
#
#  This script is written specifically for the ICS. It handles the mailing
#  of outbound interfaces
#
# ---------------------------------------------------------------------------

SCRIPT_PATH=${0%/*}

# Includes the utilities file so we can access its variables and functions
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
    set_ics_path $1
    
    # Declare Variables
    PRC_ID=`echo ${$}`           # Process ID
    UG=`id`                      # User and group                                                

    # configuration file - specific per tier
    CONFIG_FILE="${CONFIG_PATH}/ics_loader.config"
    validate_file "${CONFIG_FILE}"

    # read variables from config file
    read_variable "WORK_PATH"
    read_variable "ARCHIVE_PATH"
    read_variable "AMI_TIER"
    read_variable "SERVER"
    read_variable "LOGFILE"
    
    # set script id for log file
    SCRIPT_ID=${1##*/}              # Get the name of the script
    SCRIPT_NAME=${SCRIPT_ID%%.*}    # Get the name of the script without the ".sh"
    
    set_date "NOW" $DATE_FORMAT_FILE_SHORT     # Current date & time for filenames
    load_current_os

    # Declare Files & temp variables
    TMP_OUT="${WORK_PATH}/ics_mailer_${NOW}_${PRC_ID}.log"
    
    set_permissions $TMP_OUT
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
    if [[ -z $MAIL_FILE ]] ; then
        error_exit "ERROR: [check_params] Mail File Parameter not specified"
    elif [[ -z $INTERFACE_ID ]] ; then
        error_exit "ERROR: [check_params] Interface ID Parameter not specified"
    elif [[ -z $TO_ADDR ]] ; then
        error_exit "ERROR: [check_params] To Address Parameter not specified"
    elif [[ -z $SUBJECT ]] ; then
        error_exit "ERROR: [check_params] Subject Parameter not specified"
    else
        log_file "INFO: [check_params] Verified script input parameters" "HARMLESS"
    fi
}

# --------------------------------------------------------------------------
#
# exec_mail Description:
# Executes the mail function.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
exec_mail() 
{
    log_file "INFO: [exec_mail] Executing xmail TO: [${TO_ADDR}]" "HARMLESS"

    # Email using mailx
    mailx -s "${SUBJECT}" "${TO_ADDR}" < ${MAIL_FILE} > ${TMP_OUT} 2>&1
    rc=$?
    if [[ $rc -ne 0 ]] then
        error_exit "ERROR: [exec_mail] Unable to send mail : Return code [${rc}]"
    fi

    log_file "INFO: [exec_mail] Mail execution complete." "HARMLESS"
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

MAIL_FILE=${1}              # Variable: File to mail (mail body)
INTERFACE_ID=${2}           # Variable: Interface ID
TO_ADDR="${3}"              # Variable: To Address (email)
SUBJECT="${4}"              # Variable: Mail Subject

setup_config $0             # Function: Setup script variables

log_file "INFO: [main] Initialized script [${SCRIPT_ID}] for interface [${INTERFACE_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check passed parameters have values
exec_mail                   # Function: Execute mailer functionality
archive_file $MAIL_FILE     # Function: Archive Outbound File
clean_up_file $TMP_OUT      # Function: Remove Temporary File

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for interface [${INTERFACE_ID}]" "HARMLESS"

exit 0                      # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     20-OCT-2004 L. Glen       Original
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# ---------------------------------------------------------------------------
