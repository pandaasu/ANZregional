#!/bin/ksh
#############################################################################
# SCRIPT  :     ics_router_mq.sh
# AUTHOR  :     Megan Henderson
# DATE    :     13-April-2004
# PARAMS  :     1 - QUEUE NAME (queue to receive file from)
#               2 - INTERFACE TYPE (interface type of file)
#
#############################################################################
#            F U N C T I O N A L     O V E R V I E W
#############################################################################
#
#  This script has been written specifically for the ANZ Interface Control
#  System (ANZICS) used to interface between Atlas and local site applications.
#  The script is responsible for the passthru of files (iDOCS) from mqif into
#  LADS. The file received is then loaded into the ANZICS by calling an
#  Oracle stored procedure.
#
#############################################################################
#            M O D I F I C A T I O N   H I S T O R Y
#############################################################################
#     Version     Date          Author          Modification
#     -------   -----------     -------------   --------------------------
#       1.0     13-APR-2004     M. Henderson    Original
#       1.1     27-APR-2004     L. Glen         Changed mqgetFile to use -o
#                                               switch, instead of piping
#                                               to file.
#       1.2     11-MAY-2004     M. Henderson    Added loop through queue
#       1.3     08-JUN-2004     G. Arnold       Changed the queue unload script
#       2.0     04-MAR-2008     T. Keon         Changed to support compression
#                                               and MQFT transfers
#############################################################################

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
# Parameters: <none>
#
# --------------------------------------------------------------------------
setup_config()
{   
    # initialise the utlities script
    initialise_utilities $1
    
    DATA_FLOW_TYPE=$ROUTE
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
INTFC_FILE=${1}         # Variable : Interface File
INTERFACE_ID=${2}       # Variable : Interface type
CMP_PARAM=${3}          # Variable: Set whether the file is compressed or not (optional)

setup_config $0         # Function: Setup script variables

log_file "INFO: [main] Initialized script [${SCRIPT_ID}] for interface [${INTERFACE_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                        # Function: Check passed parameters have values
ora_connect                         # Function: Set Oracle env variables
check_DB                            # Function: Check database is available
process_inbound_mqft "${INTFC_FILE}"    # Function: Process File
clean_up_local                      # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for interface [${INTERFACE_ID}]" "HARMLESS"

exit 0                  # Exit: Exit script with successful flag (0)
