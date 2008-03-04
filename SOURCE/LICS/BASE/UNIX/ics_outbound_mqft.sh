#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_outbound_mqft.sh
# AUTHOR  : Megan Henderson
# DATE    : 15-JUNE-2004
# PARAMS  : 1 - S_FILE_NAME     # Source file name (full path)
#           2 - T_FILE_NAME     # Target file name
#           3 - QMGR_S          # Source Queue Manager for MQFT
#           4 - QMGR_T          # Target Queue Manager for MQFT
#           5 - DEST_DIR        # Destination file directory on target machine
#           6 - CMP_PARAM       # Set whether the file is compressed or not (default *NOCOMPRESS)
#           7 - TRNSFR_TYPE     # The type of transfer (default *TXT)
#           8 - T_PROCESS       # Process to execute at target
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# This script has been written specifically for the ANZ Interface Control
# System (ANZICS) used to interface between and local site applications.
# The script handles the loading of files generated by the ICS to a queue
# on Maestro (which then handles its processing to Atlas) using mqft
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
# --------------------------------------------------------------------------
setup_config()
{
    INTERFACE_ID="MQFT"
    TRNSFR_TYPE=${TRNSFR_TYPE:-$TEXT}
   
    # initialise the utlities script
    initialise_utilities $1
    
    # set the file permissions (chmod 777)
    set_permissions $S_FILE_NAME
    DATA_FLOW_TYPE=$OUTBOUND
    MQFT_SEND_PATH="${AMI_PATH}/bin/mqft/mqftssnd"
    
    case $TRNSFR_TYPE in
        $TEXT)
            MQFT_SEND_PARAM=""
            ;;
        $BINARY)
            MQFT_SEND_PARAM="-bin"
            ;;
        $LITE)
            MQFT_SEND_PARAM=""
            MQFT_SEND_PATH="${AMI_PATH}/bin/mqft/mqftssndc"
            ;;
        $TRIG)
            MQFT_SEND_PARAM="-trigger ${T_PROCESS}"
            ;;
        *)
            error_exit "ERROR: [setup_config] MQFT send type is not valid [${TRNSFR_TYPE}]"
            ;;
    esac
    
    if [[ $COMPRESS = $CMP_PARAM && $BINARY != $TRNSFR_TYPE ]] ; then
        MQFT_SEND_PARAM="${MQFT_SEND_PARAM} -bin"
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
    if  [[ -z $S_FILE_NAME ]] ; then
        error_exit "ERROR: [check_params] File to load Parameter not specified"
    elif [[ -z $T_FILE_NAME ]] ; then
        error_exit "ERROR: [check_params] Name of File to load Parameter not specified"
    elif [[ -z $S_QMGR ]] ; then
        error_exit "ERROR: [check_params] Name of Source Queue Manager Parameter not specified"
    elif [[ -z $T_QMGR ]] ; then
        error_exit "ERROR: [check_params] Name of Target Queue Manager Parameter not specified"
    elif [[ -z $DEST_DIR ]] ; then
        error_exit "ERROR: [check_params] Destination directory on Target Server Parameter not specified"
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

S_FILE_NAME=${1}    # Variable: Source file name (full path)
T_FILE_NAME=${2}    # Variable: Target file name
S_QMGR=${3}         # Variable: Source Queue Manager for MQFT
T_QMGR=${4}         # Variable: Target Queue Manager for MQFT
DEST_DIR=${5}       # Variable: Destination file dir on target machine
CMP_PARAM=${6}      # Variable: Set whether the file is compressed or not (default *NOCOMPRESS)
TRNSFR_TYPE=${7}    # Variable: Set the transfer type (default *TXT)
T_PROCESS=${8}      # Variable: Process to trigger at target

setup_config $0     # Function: Setup script variables

log_file "INFO: [main] Initialized [${SCRIPT_ID}] script for mqft to [${T_QMGR}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params        # Function: Check passed parameters have values
process_outbound "${S_FILE_NAME}" $MQFT # Function: Handle file processing
clean_up_local      # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for mqft to to [${T_QMGR}]" "HARMLESS"

exit 0              # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- --------------------------
# 1.0     15-JUN-2004 M. Henderson  Original
# 2.0     20-JAN-2005 J. Eitel      Tidy-up 
# 2.1     10-MAR-2005 L. Glen       MOD: error output from 2<&1 to 2>&1
# 2.2     03-JUN-2005 M. Henderson  Removed '-' from errors for Magic
# 3.0     06-JUL-2007 S. Gregan     Included ICS environment script
# 3.1     30-OCT-2007 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# 3.2     10-JAN-2008 T. Keon       Added compression option
# 3.3     04-MAR-2008 T. Keon       Merged all outbound MQFT files into a
#                                   single script
# ---------------------------------------------------------------------------
