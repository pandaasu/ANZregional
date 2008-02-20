#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_inbound_vds.sh
# AUTHOR  : Steve Gregan
# DATE    : 21-February-2007
# PARAMS  : 1 - INTERFACE ID (interface identification)
#           2 - CONFIG ID (SAP configuration id)
#           3 - SAP USER 01 (SAP User ID 01)
#           4 - SAP PASSWORD 01 (SAP Password 01)
#           5 - SAP USER 02 (Timezone User ID 02)
#           6 - SAP PASSWORD 02 (Timezone Password 02)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# This script has been written specifically for the ANZ Interface Control
# System (ANZICS) used to interface between Atlas and local site applications.
# The script handles the pull of data from SAP directly into a file and then
# initiates the ICS/Oracle load process.
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
    
    OUT_FILE="${INBOUND_PATH}/${INTERFACE_ID}_${NOW}_${PRC_ID}.DAT"
    VDS_CFG="${CONFIG_PATH}/vds_interface_config.xml"
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
    elif [[ -z $CFG_ID ]] ; then
        error_exit "ERROR: [check_params] Configuration ID Parameter not specified"
    elif [[ -z $SAP_USER_01 ]] ; then
        error_exit "ERROR: [check_params] SAP User ID 01 Parameter not specified"
    elif [[ -z $SAP_PWD_01 ]] ; then
        error_exit "ERROR: [check_params] SAP Password 01 Parameter not specified"
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

INTERFACE_ID=${1}       # Variable: Interface name id - ie: SAPVDS01
CFG_ID=${2}             # Variable: Interface name id - ie: SAPVDS01_01
SAP_USER_01=${3}        # Variable: SAP User ID 01
SAP_PWD_01=${4}         # Variable: SAP Password 02
SAP_USER_02=${5}        # Variable: SAP User ID 02
SAP_PWD_02=${6}         # Variable: SAP Password 02
CMP_PARAM=${7}          # Variable: Set whether the file is compressed or not (optional)

setup_config $0         # Function: Setup script variables

log_file "INFO: [main] Initialized script for interface [${INTERFACE_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params            # Function: Check passed parameters have values
ora_connect             # Function: Set Oracle env variables
check_DB                # Function: Check database is available
process_inbound_vds     # Function: Get file from Queue
clean_up_local          # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for interface [${INTERFACE_ID}]" "HARMLESS"

exit 0                  # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     21-FEB-2007 S. Gregan     Original
# 3.0     06-JUL-2007 S. Gregan     Included ICS environment script
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# 3.2     10-JAN-2008 T. Keon       Added compression option
# ---------------------------------------------------------------------------

