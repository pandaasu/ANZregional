#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_outbound_blank.sh
# AUTHOR  : Trevor Keon
# DATE    : 22-July-2008
# PARAMS  : 1 = File to move
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# This script is used to move a file into the ICS temp directory instead of
# sending it onto the target machine.  Allows a user to get a copy of the
# file that would have been sent.
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
    ICS_TEMP_DIR="${SCRIPT_PATH}/../temp"
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

# --------------------------------------------------------------------------
#
# move_file Description:
# Move provided file to the ICS temp directory.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
move_file()
{
    mv $FILE $ICS_TEMP_DIR
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

FILE=$1              # Variable: File to FTP (absolute)

setup_config $0             # Function: Setup script variables

log_file "INFO: [main] Initialized blank script for [${FILE}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check expected parameters are set
validate_file "${FILE}"     # Function: Check local file status
move_file                   # Function: Move the file to the ICS temp directory
clean_up_local              # Function: Remove Temporary Files

log_file "INFO: [main] Completion of blank script [${SCRIPT_ID}]" "HARMLESS"

exit 0

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- --------------------------
# 1.0     22-JUL-2008 T. Keon       Original
# ---------------------------------------------------------------------------
