#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_passthru_mqft.sh
# AUTHOR  : Linden Glen
# DATE    : 09-January-2006
# PARAMS  : 1 - FILE NAME (file to passthru)
#           2 - INTERFACE TYPE (interface type of file)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
#  Modification history at end of script
#
#  This script has been written specifically for the ANZ Interface Control
#  System (ANZICS) used to interface between Atlas and local site applications.
#  The script is responsible for the passthru of files (iDOCS) from mqif into
#  LADS. The file received is then loaded into the ANZICS by calling an
#  Oracle stored procedure.
#
# ---------------------------------------------------------------------------

SCRIPT_PATH=${0%/*}

# Includes the utility files so we can access their variables and functions
. ${SCRIPT_PATH}/ics_utilities.sh
. ${SCRIPT_PATH}/ics_utils_oracle.sh
. ${SCRIPT_PATH}/ics_utils_messaging.sh

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
    # initialise the utlities script
    initialise_utilities $1
    
    DATA_FLOW_TYPE=$PASSTHRU
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

FILENAME=${1}               # Variable: File to receive passthru
INTERFACE_ID=${2}           # Variable: Interface type

setup_config $0             # Function: Setup script variables

log_file "INFO: Initialized script for interface [${INTERFACE_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check passed parameters have values
ora_connect                 # Function: Set Oracle env variables
check_DB                    # Function: Check database is available
process_passthru_mqft       # Function: Process file
clean_up_local              # Function: Remove Temporary Files

log_file "INFO: Completion of script [${SCRIPT_ID}] for interface [${INTERFACE_ID}] " "HARMLESS"

exit 0                      # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     09-JAN-2006 L. Glen       Original
# 3.0     06-JUL-2007 S. Gregan     Included ICS environment script
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# ---------------------------------------------------------------------------

