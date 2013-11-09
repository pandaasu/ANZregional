#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_outbound_sftp.sh
# AUTHOR  : Scott R. Harding
# DATE    : 24-Jul-2013
# PARAMS  : 1 = File to SFTP (absolute)
#           2 = Destination Server
#           3 = Destination User
#           4 = Destination Password
#           5 = Destination Path (absolute)
#           6 = Destination File name
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# This script has been written specifically for the Central Interface
# system (CIS) used to interface between Atlas and local site applications.
# The script offers generic sftp functionality that can be called from an
# Oracle stored procedure or from the command line.
# This script only provides "put" functionality.
# Log files are not kept as all error handling is captured by the Java
# environment running the script.
#
# ---------------------------------------------------------------------------

SCRIPT_PATH=${0%/*}

# Includes the utility files so we can access their variables and functions
. ${SCRIPT_PATH}/ics_utilities.sh
. ${SCRIPT_PATH}/ics_utils_messaging_sftp.sh

# --------------------------------------------------------------------------
#
# setup_config Description:
# Configure the scripts variables
#
# Parameters: <none>
# 1 - The basename of the program as it was called (i.e. $0 from the calling
#   script.
#
# --------------------------------------------------------------------------
setup_config()
{
    # initialise the utlities script
    initialise_utilities $1

    DATA_FLOW_TYPE=$OUTBOUND
    export SFTP_LOG=$TMP_OUT
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
    if [[ -z $FILE ]] ; then
        error_exit "ERROR: [check_params] Local file path not specified"
    elif [[ -z $DEST_SERVER ]] ; then
        error_exit "ERROR: [check_params] Destination Server not specified"
    elif [[ -z $DEST_USER ]] ; then
        error_exit "ERROR: [check_params] Destination User not specified"
    elif [[ -z $DEST_PWORD ]] ; then
        error_exit "ERROR: [check_params] Destination Password not specified"
    elif [[ -z $DEST_PATH ]] ; then
        error_exit "ERROR: [check_params] Destination Path not specified"
    elif [[ -z $DEST_NAME ]] ; then
        error_exit "ERROR: [check_params] Destination File Name not specified"
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

export FILE=$1              # Variable: File to SFTP (absolute)
export DEST_SERVER=$2       # Variable: Destination Server
export DEST_USER=$3         # Variable: Destination Login User
export DEST_PWORD=$4        # Variable: Destination Password
export DEST_PATH=$5         # Variable: Destination Path (absolute)
export DEST_NAME=$6         # Variable: Destination Name

setup_config $0             # Function: Setup script variables

log_file "INFO: [main] Initialized script for SFTP of [${FILE}] to [${DEST_SERVER}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check expected parameters are set
validate_file "${FILE}"     # Function: Check local file status
process_outbound_sftp        # Function: Process the file via SFTP
clean_up_local              # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for SFTP to [${DEST_SERVER}]" "HARMLESS"

exit 0

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- --------------------------
# 1.0     24-Jul-2013 S. Harding    Copied from ics_outbound_ftp.sh
# ---------------------------------------------------------------------------

