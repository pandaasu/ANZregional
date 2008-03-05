#!/bin/ksh
#############################################################################
# SCRIPT  :     ics_alert_tivoli.sh
# AUTHOR  :     Megan Henderson
# DATE    :     13-May-2004
# PARAMS  :     ERRMSG=Error Message
#
#############################################################################
#            F U N C T I O N A L     O V E R V I E W
#############################################################################
#
#  This script has been written specifically for the ANZ Interface Control
#  System (ANZICS) used to interface between Atlas and local site applications.
#  The script is responsible for a sending alerts to MAGIC via the logFile Adapter
#
#############################################################################
#            M O D I F I C A T I O N   H I S T O R Y
#############################################################################
#     Version     Date          Author          Modification
#     -------   -----------     -------------   --------------------------
#       1.0     13-MAY-2004     M. Henderson    Original
#       1.1     03-FEB-2005     M. Henderson    Added functionality
#       1.2     19-JUL-2005     L. Glen         MOD: Use ics_integration.log
#       3.0     06-JUL-2007     S. Gregan       Included ICS environment script
#       3.1     05-MAR-2008     T. Keon         Standardised script to use new
#                                               base scripts and structure
#
#############################################################################

SCRIPT_PATH=${0%/*}

# Includes the utility files so we can access their variables and functions
. ${SCRIPT_PATH}/ics_utilities.sh

# --------------------------------------------------------------------------
#
# setup_config Description:
# Configure the scripts variables
#
# Parameters:
# 1 - The basename of the program as it was called (i.e. $0 from the calling
#   script.
# --------------------------------------------------------------------------
setup_config()
{
    # initialise the utlities script
    initialise_utilities $1
}

# ---------------------------------------------------------------------------
# tivoli_alert Description:
# Sends the alert to file with tivoli lfa
#
# Parameters: <none>
#
# ---------------------------------------------------------------------------
tivoli_alert() 
{    
    print `date +"%Y-%m-%d %H:%M:%S"` INFO ${SYS_TIER} ${SERVER} ${MSG_ERRMSG} >> ${LOGFILE}
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
    if  [[ -z $MSG_ERRMSG ]] ; then
        error_exit "ERROR: [check_params] Error message not specified"
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
# main
# ---------------------------------------------------------------------------

MSG_ERRMSG=${1}         # Variable: Error Message - comes from ICS Interface config

setup_config $0         # Function: Setup script variables

log_file "INFO: [main] Initialized [${SCRIPT_ID}] script" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params            # Function: checks that params passed have values
tivoli_alert            # Function: Send alert to Tivoli opcom
clean_up_local          # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}]" "HARMLESS"

exit 0                     # Exit: Exit script with successful flag (0)
