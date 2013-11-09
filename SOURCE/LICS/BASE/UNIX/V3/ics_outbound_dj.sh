#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_outbound_dj.sh
# AUTHOR  : Linden Glen
# DATE    : 25-March-2004
# PARAMS  : 1 - QUEUE NAME (queue to place file on)
#           2 - INTERFACE TYPE (interface type of file)
#           3 - Q_FILE (file to be placed on queue)
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# This script has been written specifically for the ANZ Interface Control
# System (ANZICS) used to interface between and local site applications.
# The script handles the loading of files generated by the ICS to a queue
# on Maestro (which then handles its processing to Atlas)
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
# Parameters:
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
    if [[ -z $QUEUE ]] ; then
        error_exit "ERROR: [check_params] Queue Name Parameter not specified"
    elif [[ -z $INTERFACE_ID ]] ; then
        error_exit "ERROR: [check_params] Interface Id Parameter not specified"
    elif [[ -z $Q_FILE ]] ; then
        error_exit "ERROR: [check_params] File to load Parameter not specified"
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

QUEUE=${1}          # Variable: Queue to place file on
INTERFACE_ID=${2}   # Variable: Interface id
Q_FILE=${3}         # Variable: File to place on queue (full path)
CMP_PARAM=${4}      # Variable: Set whether to compress the file or not (optional)

setup_config $0     # Function: Setup script variables

log_file "INFO: [main] Initialized script [${SCRIPT_ID}] for queue [${QUEUE}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params        # Function: Check passed parameters have values
process_outbound "${Q_FILE}" $DJ # Function: Handle file processing
clean_up_local      # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for queue [${QUEUE}]" "HARMLESS"

exit 0              # Exit: Exit script with successful flag (0)


# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- --------------------------
# 1.0     25-MAR-2004 L. Glen       Original
# 1.1     28-MAY-2004 M. Henderson  Removed -nocopy from the file2ms
#                                   call
# 1.2     12-JUL-2004 M. Henderson  Added archiving
# 1.3     21-JUL-2004 J. Eitel      Added logic for Maestro flag
#                     R. Poole      Addition flags for AMI Platform
#                                   Added processes logging 
# 1.4     28-OCT-2004 J. Eitel      Added validateOutboundFile function
# 2.0     08-DEC-2004 J. Eitel      Tidy up
# 2.1     10-MAR-2005 L. Glen       MOD: error output from 2<&1 to 2>&1
# 2.2     03-JUN-2005 M. Henderson  Removed ' - ' from errors for Magic
# 3.0     06-JUL-2007 S. Gregan     Included ICS environment script
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# 3.2     10-JAN-2008 T. Keon       Added compression option
# ---------------------------------------------------------------------------
