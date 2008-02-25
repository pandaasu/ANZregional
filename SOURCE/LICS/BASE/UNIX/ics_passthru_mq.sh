#!/bin/sh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_passthru_mq.sh
# AUTHOR  : Megan Henderson
# DATE    : 13-April-2004
# PARAMS  : 1 - QUEUE NAME (queue to receive file from)
#           2 - INTERFACE TYPE (interface type of file)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
#  Modification history at end of script
#
# This script has been written specifically for the ANZ Interface Control
# System (ANZICS) used to interface between Atlas and local site applications.
# The script is responsible for the passthru of files (iDOCS) from mqif into
# LADS. The file received is then loaded into the ANZICS by calling an
# Oracle stored procedure.
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
    if [[ -z $QUEUE ]] ; then
        error_exit "ERROR: [check_params] Queue Name Parameter not specified"
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

QUEUE=${1}                  # Variable: Queue to receive file from
INTERFACE_ID=${2}           # Variable: Interface type

setup_config $0             # Function: Setup script variables

log_file "INFO: Initialized script for queue [${QUEUE}] interface type [${INTERFACE_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check passed parameters have values
trigger_queue "NOTRIGGER"   # Function: Turn QUEUE trigger OFF
queue_depth "INIT" 1        # Function: Check the queue depth
ora_connect                 # Function: Set Oracle env variables
check_DB                    # Function: Check database is available
process_passthru_mq         # Function: Get file from Queue
trigger_queue "TRIGGER"     # Function: Turn QUEUE trigger ON
clean_up_local              # Function: Remove Temporary Files

log_file "INFO: Completion of script [${SCRIPT_ID}] for queue [${QUEUE}] " "HARMLESS"

exit 0                      # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     13-APR-2004 M. Henderson  Original
# 1.1     27-APR-2004 L. Glen       Changed mqgetFile to use -o
#                                   switch, instead of piping
#                                   to file.
# 1.2     11-MAY-2004 M. Henderson  Added loop through queue
# 1.3     03-JUN-2004 M. Henderson  Removed passthru-point at inbound
# 1.4     12-JUL-2004 M. Henderson  Added archiving
# 1.5     30-SEP-2004 J. Eitel      Added queueDepth function to evaluate 
#                                   depth before proceeding.  Moved 
#                                   trigger_queue function for setting 
#                                   queue to "notrigger" to the beginning 
#                                   of the script to ensure no tight loop.
#                                   Changed trigger_queue so if trigger 
#                                   doesnt work - exit CRITICAL
# 1.6     04-OCT-2004 J. Eitel      Added function validateDequeueFile to 
#                                   evaluate the file from DJ.  If file 
#                                   empty, send MINOR tivoli alarm, set 
#                                   queue trigger on, and exit 0.
# 1.7     26-OCT-2004 J. Eitel      Changed mqGetMsg function from getting 
#                                   full queue depth to looping though x 
#                                   number of times, to getting the queue 
#                                   depth and looping 1 time, and checking 
#                                   again
# 1.8     04-NOV-2004 J. Eitel      Changed validateDequeueFile to stop 
#                                   MINOR alerting
# 2.0     08-DEC-2004 J. Eitel      Tidy up
# 2.1     10-MAR-2005 L. Glen       MOD: error output from 2<&1 to 2>&1
# 2.2     08-JUL-2005 M. Henderson  Removed ' - ' from errorExit for Magic
# 3.0     06-JUL-2007 S. Gregan     Included ICS environment script
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# ---------------------------------------------------------------------------

