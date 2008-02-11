#!/bin/ksh
#############################################################################
# SCRIPT  :     restart_jobs.sh
# AUTHOR  :     Megan Henderson
# DATE    :     03-May-2004
# PARAMS  :     n/a
#
#############################################################################
#            F U N C T I O N A L     O V E R V I E W
#############################################################################
#
#  This script has been written specifically for the ANZ Interface Control
#  System (ANZICS) used to interface between Atlas and local site applications.
#  The script is responsible for a restart jobs and connect to Oracle.
#
#############################################################################
#            M O D I F I C A T I O N   H I S T O R Y
#############################################################################
#     Version     Date          Author          Modification
#     -------   -----------     -------------   --------------------------
#       1.0     03-MAY-2004     M. Henderson    Original
#       1.1     06-MAY-2004     M. Henderson    Added sleep before call
#       1.2     23-SEP-2004     M. Henderson    Removed orawait and 
#                                               @DB in sql call
#       1.3     07-FEB-2005     Linden Glen     Script tidy up
#                                               Added integration logging
#       1.4     11-FEB-2008     T. Keon         Updated script for 10g
#############################################################################

SCRIPT_PATH=${0%/*}

# Includes the utility files so we can access their variables and functions
. ${SCRIPT_PATH}/ics_utilities.sh
. ${SCRIPT_PATH}/ics_utils_oracle.sh

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

#############################################################################
#       MAIN
#############################################################################
x="-x"                  # Trace: Turn tracing on
set $x

setup_config $0         # Function: Setup script variables

log_file "INFO: [main] Initialized script [restart_jobs.sh]" "HARMLESS"

ora_connect                     # Function: Set Oracle env variables
load_file $LOAD_FILE_RESTART    # Funcrion: Calls sql to restart jobs 
clean_up_local                  # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [restart_jobs.sh]" "HARMLESS"

exit 0                  # Exit: Exit script with successful flag (0)
