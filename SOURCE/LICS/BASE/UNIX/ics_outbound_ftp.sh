#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_outbound_ftp.sh
# AUTHOR  : Linden Glen
# DATE    : 05-February-2004
# PARAMS  : 1 = File to FTP (absolute)
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
# The script offers generic ftp functionality that can be called from an
# Oracle stored procedure or from the command line.
# This script only provides "put" functionality.
# Log files are not kept as all error handling is captured by the Java
# environment running the script.
#
# ---------------------------------------------------------------------------

SCRIPT_PATH=${0%/*}

# Includes the utility files so we can access their variables and functions
. ${SCRIPT_PATH}/ics_utilities.sh
. ${SCRIPT_PATH}/ics_utils_messaging.sh

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

export FILE=$1              # Variable: File to FTP (absolute)
export DEST_SERVER=$2       # Variable: Destination Server
export DEST_USER=$3         # Variable: Destination Login User
export DEST_PWORD=$4        # Variable: Destination Password
export DEST_PATH=$5         # Variable: Destination Path (absolute)
export DEST_NAME=$6         # Variable: Destination Name

setup_config $0             # Function: Setup script variables

log_file "INFO: [main] Initialized script for FTP of [${FILE}] to [${DEST_SERVER}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check expected parameters are set
validate_file "${FILE}"     # Function: Check local file status
process_outbound_ftp        # Function: Process the file via FTP
clean_up_local              # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for FTP to [${DEST_SERVER}]" "HARMLESS"

exit 0

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- --------------------------
# 1.0     05-FEB-2004 L. Glen       Original
# 1.1     08-FEB-2004 L. Glen       ADD: checkLog Function
# 1.2     10-FEB-2004 L. Glen       ADD: Timestamp to log file
#                                   Allows multiple instances of
#                                   script to run.
# 1.3     01-JUN-2004 M. Henderson  6th Param as dest file name
# 1.4     23-JUN-2004 M. Henderson  Added -i to grep for NT diff
# 1.5     16-JUL-2004 R. Poole      Added logging and options to handle maestro
#                                   readVariable, validateFile, logFile procedures
#                                   Modified errorExit to use logFile procedure
# 2.0     08-DEC-2004 J. Eitel      Tidy up
# 2.1     20-JAN-2005 J. Eitel      Change the Maestro Alias 4pfx to ICSL
# 2.2     10-MAR-2005 L. Glen       MOD: error output from 2<&1 to 2>&1
# 2.3     04-JUL-2005 M. Henderson  Removed ' - ' from errorExit for Magic
# 3.0     06-JUL-2007 S. Gregan     Included ICS environment script
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# ---------------------------------------------------------------------------
