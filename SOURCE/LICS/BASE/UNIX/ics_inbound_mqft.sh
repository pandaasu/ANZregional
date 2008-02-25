#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_inbound_mqft.ksh
# AUTHOR  : Linden Glen 
# DATE    : 20-December-2005
# PARAMS  : 1 - FILE NAME (file to load)
#           2 - INTERFACE ID (name of interface)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# This script has been written for the Interface Control System.
# It handles the loading of messages sent via MQFT. 
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
# Parameters: <none>
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
# mqft_get_file Description:
# Get the file(s) to process and processes them.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
mqft_get_file() 
{
    # check if the file to process was passed in as a paramter.  If not then we need to search for it.
    if [[ -z $INTFC_FILE ]] ; then
        CMD="find ${INBOUND_PATH} -type f -name '${INTERFACE_ID}*' -exec ls {} \;"
        log_file "INFO: [mqft_get_file] Executing FIND command [${CMD}]" "HARMLESS"
        
        for FILE in `eval "$CMD"`
        do
            file_time_1=$(perl -e '$fileModTime=(stat("'$FILE'"))[9]; print "$fileModTime" ;' )
            sleep 10 
            file_time_2=$(perl -e '$fileModTime=(stat("'$FILE'"))[9]; print "$fileModTime" ;' )
            
            if [[ file_time_1 -eq file_time_2 ]] ; then
                process_inbound_mqft "${FILE}"            
            else
                error_exit "ERROR: [mqft_get_file] File still being written after 10 second wait"
            fi
        done
    else
        process_inbound_mqft "${INTFC_FILE}"
    fi
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

if [[ $# -eq 1 ]] ; then
    sleep 2
    INTERFACE_ID=${1}       # Variable : Interface type
    CMP_PARAM=${2}          # Variable: Set whether the file is compressed or not (optional)
else
    INTFC_FILE=${1}         # Variable : Interface File
    INTERFACE_ID=${2}       # Variable : Interface type
    CMP_PARAM=${3}          # Variable: Set whether the file is compressed or not (optional)
fi

setup_config $0         # Function: Setup script variables

log_file "INFO: [main] Initialized script [${SCRIPT_ID}] for interface [${INTERFACE_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params            # Function: Check passed parameters have values
ora_connect             # Function: Set Oracle env variables
check_DB                # Function: Check database is available
mqft_get_file           # Function: Process File
clean_up_local          # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for interface [${INTERFACE_ID}]" "HARMLESS"

exit 0                  # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     20-DEC-2005 L. Glen       Original
# 3.0     06-JUL-2007 S. Gregan     Included ICS environment script
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# 3.2     19-DEC-2007 T. Keon       Added support for Venus differences
# 3.2     10-JAN-2008 T. Keon       Added compression option
# ---------------------------------------------------------------------------
