#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_inbound_mqft_reprocess.sh
# AUTHOR  : Trevor Keon
# DATE    : 16-May-2008
# PARAMS  : 1 - FILE NAME (file containing files to reprocess)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
#  Modification history at end of script
#
#  This script is used to reprocess failed MQFT loads.  It takes a file as a
#  parameter which contains a list of files stored in the archive folder.
#  It will reload each file from the archive directory and run the MQFT load
#  as normal.  Note that the files to be reprocessed must be in the following
#  format:
#
#  <interface id>_<transfer id>.gz
#  LADPDB03.3_WODU03T1A00121252.gz
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
    LOG_TYPE=$LOG_TO_TEMP
    
    # initialise the utlities script
    initialise_utilities $1
}

# --------------------------------------------------------------------------
#
# process_reprocess_file Description:
# Process the file to reprocess the files.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_reprocess_file()
{
    # assign file descriptor 3 to input file
    exec 3< $FILENAME

    # read til the end of the file
    until [ $EOF ]
    do
        read <&3 FILE_LINE
        if [ $? != 0 ]; then
            EOF=1
            continue
        fi
        
        if [[ ! -z $FILE_LINE ]] ; then
            INTERFACE_ID=${FILE_LINE%%_*}
        
            copy_to_temp $FILE_LINE
            toggle_file_compression $TARG_FILE 1
            
            process_inbound_mqft $DECOMPRESS_FILE_NAME
            clean_up_file $DECOMPRESS_FILE_NAME
            
            sleep 2
        fi
    done 
}

# --------------------------------------------------------------------------
#
# copy_to_temp Description:
# Copy the specified file from the archive directory to the temp directory.
#
# Parameters:
# 1 - The name of the file to copy.
#
# --------------------------------------------------------------------------
copy_to_temp()
{
    FILE_INT="${ARCHIVE_PATH}/$1"
    TARG_FILE="${INBOUND_PATH}/$1"
    
    validate_file $FILE_INT
    
    CMD="cp ${FILE_INT} ${TARG_FILE}"

    log_file "INFO: [copy_to_temp] Running command [${CMD}]" "HARMLESS"
    
    `$CMD >> ${TMP_OUT} 2>&1`
    rc=$?
    
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: [copy_to_temp] Failed to copy file.  Return code [${rc}]."            
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
    if [[ -z $FILENAME ]] ; then
        error_exit "ERROR: [check_params] Filename Parameter not specified"
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

FILENAME=${1}               # Variable: File containing file list to reprocess

setup_config $0             # Function: Setup script variables

log_file "INFO: Initialized script for interface [${INTERFACE_ID}]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check passed parameters have values
ora_connect                 # Function: Set Oracle env variables
check_DB                    # Function: Check database is available
process_reprocess_file      # Function: Process file
clean_up_local              # Function: Remove Temporary Files

log_file "INFO: Completion of script [${SCRIPT_ID}] for interface [${INTERFACE_ID}] " "HARMLESS"

exit 0                      # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     16-MAY-2008 T. Keon       Original
# ---------------------------------------------------------------------------
