#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_inbound_trigmqft.sh
# AUTHOR  : Linden Glen
# DATE    : 09-September-2005
# PARAMS  : 1 - INTERFACE ID (Interface ID to process file)
#           2 - INTERFACE FILE (File received from interface)
#           3 - SOURCE HOST (Source queue manager that initiated interface)
#           4 - MQFT XFER ID (MQFT Transfer ID)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# Handles the execution of ICS Inbound Loader from files/interfaces received
# via MQFT. MQFT configuration defines parameters passed based on interface.
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
    
    DATA_FLOW_TYPE=$INBOUND
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
    if [[ -z $INTERFACE_ID ]] ; then
        error_exit "ERROR: [check_params] Interface ID Parameter not specified"
    elif [[ -z $INTFC_FILE ]] ; then
        error_exit "ERROR: [check_params] Interface File Parameter not specified"
    elif [[ -z $SRC_QMNGR ]] ; then
        error_exit "ERROR: [check_params] Source Queue Manager Parameter not specified"
    elif [[ -z $MQFT_XFR_ID ]] ; then
        error_exit "ERROR: [check_params] MQFT Transfer ID Parameter not specified"
    else
        log_file "INFO: [check_params] Verified script input parameters" "HARMLESS"
    fi
}

# --------------------------------------------------------------------------
#
# clean_up_local Description:
# Remove temporary files created by this script.
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

INTERFACE_ID=${1}       # Variable : Interface type
INTFC_FILE=${2}         # Variable : Interface File
SRC_QMNGR=${3}          # Variable : Source Queue Manager
MQFT_XFR_ID=${4}        # Variable : MQFT Transfer ID
CMP_PARAM=${5}          # Variable: Set whether the file is compressed or not (optional)

setup_config $0         # Function: Setup script variables

log_file "INFO: [main] Initialized MQFT Trigger script for [${INTERFACE_ID}] from [${SRC_QMNGR}] - XFR ID [${MQFT_XFR_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params            # Function: Check passed parameters have values
ora_connect             # Function: Set Oracle env variables
check_DB                # Function: Check database is available
process_inbound_mqft "${INTFC_FILE}"    # Function: Handles processing of received file
clean_up_local          # Function: Remove Temporary Files

log_file "INFO: [main] Completion of MQFT Inbound Trigger script [${SCRIPT_ID}] for interface [${INTERFACE_ID}]" "HARMLESS"

exit 0                  # Exit: Exit script with successful flag (0)


# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     09-SEP-2005 L. Glen       Original
# 3.0     06-JUL-2007 S. Gregan     Included ICS environment script
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# 3.2     10-JAN-2008 T. Keon       Added compression option
# ---------------------------------------------------------------------------
