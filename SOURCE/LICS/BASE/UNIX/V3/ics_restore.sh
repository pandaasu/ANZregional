#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  :     ics_restore.sh                                              #
#                                                                           #
# Takes file from archive directory and puts it to user specified target    #
# directory, and un-compresses the file                                     #
#                                                                           #
# Modification History                                                      #
#                                                                           #
# 07-OCT-2004   J. Eitel        Initial release                             #
# 11-OCT-2004   J. Eitel        Allowed for non-full path to be passed in   #
# 13-OCT-2004   J. Eitel        Allowed for non-compressed file to be       #
#                               passed in.                                  #
# 09-NOV-2004   J. Eitel        Allow for scan inbound/outbound dirs if not #
#                               in archive directory                        #
# 06-JUL-2007   S. Gregan       Included ICS environment script             #
# 20-NOV-2007   T. Keon         Added calls to utility script files for     #
#                               common functions and standardised the       #
#                               script code                                 #
# ---------------------------------------------------------------------------

SCRIPT_PATH=${0%/*}

# Includes the utility files so we can access their variables and functions
. ${SCRIPT_PATH}/ics_utilities.sh

# ---------------------------------------------------------------------------
#
# Global Variables:
# These should never be changed by other shell scripts, and should never be
# redefined externally.  If you could set variables as read only in unix
# scripting, then these would be set as such.  So treat them as read only!
#
# ---------------------------------------------------------------------------

INBOUND="INBOUND"
OUTBOUND="OUTBOUND"
VIEW="VIEW"

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
    
    set_ics_path $1

    # set up temp variables                                       
    PRC_ID=`echo ${$}`
    UG=`id`

    set_date "NOW" $DATE_FORMAT_FILE_SHORT     # Current date & time for filenames

    CONFIG_FILE="${CONFIG_PATH}/ics_loader.config"
    validate_file "${CONFIG_FILE}"

    # read variables from config file
    read_variable "INBOUND_PATH"
    read_variable "OUTBOUND_PATH"
    read_variable "WORK_PATH"
    read_variable "WEBVIEW_PATH"
    read_variable "ARCHIVE_PATH"

    # set script id for log file
    SCRIPT_ID=${1##*/}              # Get the name of the script
    SCRIPT_NAME=${SCRIPT_ID%%.*}    # Get the name of the script without the ".sh"

    TMP_OUT="${WORK_PATH}/${SCRIPT_NAME}_${NOW}_${PRC_ID}.log"
    
    # set the file permissions (chmod 777)
    set_permissions $TMP_OUT
    
    echo "INFO: Creating working log file [${TMP_OUT}]" >> ${TMP_OUT}
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
    if [[ -z $MV_FILE_NAME ]] ; then
        print_usage
        error_exit "ERROR: [check_params] File name not entered as parameter"
    elif [[ -z $TARGET_DIR ]] ; then
        print_usage
        error_exit "ERROR: [check_params] Target directory not entered as parameter"
    else
        log_file "INFO: [check_params] Verified script input parameters"
    fi
}

# --------------------------------------------------------------------------
#
# print_usage Description:
# print to stdout if invalid parameters.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
print_usage()
{
    echo "Usage: $SCRIPT_ID [MV_FILE_NAME] [TARGET_DIR]"
    echo "          MV_FILE_NAME  :  name of the file to reprocess [ATLLAD01.txt]"
    echo "          TARGET_DIR    :  name of the directory to move the file [INBOUND/OUTBOUND/VIEW]"
}

# --------------------------------------------------------------------------
#
# process_file Description:
# Copy the file to the appropriate target directory and unzip.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
process_file()
{
    log_file "INFO: [process_file] Input parameter: filename - [${MV_FILE_NAME}]"
    log_file "INFO: [process_file] Input parameter: directory - [${TARGET_DIR}]"

    case $TARGET_DIR in
        $INBOUND)
            SET_TARGET_DIR=${INBOUND_PATH}
            ;;
        $OUTBOUND)
            SET_TARGET_DIR=${OUTBOUND_PATH}
            ;;
        $VIEW)
            SET_TARGET_DIR=${WEBVIEW_PATH}
            ;;
        *)
            error_exit "ERROR: [process_file] Target directory is not valid [${TARGET_DIR}]"
            ;;
    esac
    
    log_file "INFO: [process_file] Target path set to [${SET_TARGET_DIR}]"

    # build full path filename from input param
    # if the file is unzipped in archive directory, then copy to target and dont unzip

    # 1. if a directory was passed in; strip it.
    # 2. if .gz exists in passed filename - strip it off 
    MV_SOURCE_FILE=`basename $MV_FILE_NAME`
    MV_SOURCE_FILE_NZ="${MV_SOURCE_FILE%.gz}"
    MV_SOURCE_FULL_FILE_NZ=${ARCHIVE_PATH}/${MV_SOURCE_FILE_NZ}

    log_file "INFO: [process_file] Basename file to move: [${MV_SOURCE_FILE}]"
    log_file "INFO: [process_file] Full uncompressed source path and filename: [${MV_SOURCE_FULL_FILE_NZ}]"

    # set directories for non-archived files, if necessary
    MV_INBOUND_FULL_FILE_NZ=${INBOUND_PATH}/${MV_SOURCE_FILE_NZ}
    MV_OUTBOUND_FULL_FILE_NZ=${OUTBOUND_PATH}/${MV_SOURCE_FILE_NZ}

    # set the full path for the target file, with no .gz
    # if the file exists in the target, not necessary to progress: exit
    MV_TARGET_FULL_FILE=${SET_TARGET_DIR}/${MV_SOURCE_FILE_NZ}
    if [[ -a ${MV_TARGET_FULL_FILE} ]] ; then
        log_file "WARNING: [process_file] Target file already exists, exiting: [${MV_TARGET_FULL_FILE}]"
    exit 0
    else
        log_file "INFO: [process_file] Target file does not exist, continuing: [${MV_TARGET_FULL_FILE}]"
    fi

    # 1. if non-zipped source file exists, then copy to target directory
    # 2. if zipped source file exists, copy to target directory and unzip
    if [[ -a ${MV_SOURCE_FULL_FILE_NZ} ]] ; then
        log_file "INFO: [process_file] Non-zipped source file exists - copying to target"
        copy_file "${MV_SOURCE_FULL_FILE_NZ}" "${MV_TARGET_FULL_FILE}"
    elif [[ -a "${MV_SOURCE_FULL_FILE_NZ}.gz" ]] ; then
        log_file "INFO: [process_file] Zipped source file exists - copying to target and unzipping"
        
        MV_SOURCE_FULL_FILE_Z="${MV_SOURCE_FULL_FILE_NZ}.gz"
        MV_TARGET_FULL_FILE_Z="${MV_TARGET_FULL_FILE}.gz"
        
        copy_file "${MV_SOURCE_FULL_FILE_Z}" "${MV_TARGET_FULL_FILE_Z}"
        toggle_file_compression "${MV_TARGET_FULL_FILE_Z}" 1
    elif [[ -a "${MV_SOURCE_FULL_FILE_NZ}.Z" ]] ; then
        log_file "INFO: [process_file] Zipped source file exists - copying to target and unzipping"
        
        MV_SOURCE_FULL_FILE_Z="${MV_SOURCE_FULL_FILE_NZ}.Z"
        MV_TARGET_FULL_FILE_Z="${MV_TARGET_FULL_FILE}.Z"
        
        copy_file "${MV_SOURCE_FULL_FILE_Z}" "${MV_TARGET_FULL_FILE_Z}"
        toggle_file_compression "${MV_TARGET_FULL_FILE_Z}" 1     
    elif [[ -a ${MV_INBOUND_FULL_FILE_NZ} ]] ; then
        log_file "INFO: [process_file] File exists in directory [${INBOUND_PATH}] - copying to target"
        copy_file "${MV_INBOUND_FULL_FILE_NZ}" "${MV_TARGET_FULL_FILE}"
    elif [[ -a ${MV_OUTBOUND_FULL_FILE_NZ} ]] ; then
        log_file "INFO: [process_file] File exists in directory [${OUTBOUND_PATH}] - copying to target"
        copy_file "${MV_OUTBOUND_FULL_FILE_NZ}" "${MV_TARGET_FULL_FILE}"      
    else
        log_file "WARNING: [process_file] Uncompressed file does not exist: [${MV_SOURCE_FULL_FILE_NZ}]"
        log_file "WARNING: [process_file] Compressed file does not exist: [${MV_SOURCE_FULL_FILE_NZ}.gz]"
        log_file "WARNING: [process_file] Uncompressed file does not exist: [${MV_INBOUND_FULL_FILE_NZ}]"
        log_file "WARNING: [process_file] Uncompressed file does not exist: [${MV_OUTBOUND_FULL_FILE_NZ}]"
    fi     
}

# --------------------------------------------------------------------------
#
# copy_file Description:
# Copy the specified file to the target file.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
copy_file()
{
    SOURCE_FULL_FILE=${1}
    TARGET_FULL_FILE=${2}

    CP_CMD="cp -p ${SOURCE_FULL_FILE} ${TARGET_FULL_FILE}"    
    run_command "$CP_CMD" "copy" "$SOURCE_FULL_FILE"

    log_file "INFO: [copy_file] Copy file successful"
}

# --------------------------------------------------------------------------
#
# run_command Description:
# Run the provided command and check for successful execution.
#
# Parameters:
# 1 - The command to run
# 2 - A description of what the command is running.  Will appear in the log 
#   file if something goes wrong.
# 3 - The file the command is being run against
#
# --------------------------------------------------------------------------
run_command()
{
    COMMAND=$1
    DESC=$2
    FILE=$3
    
    log_file "INFO: [run_command] Execute command: [$COMMAND]"
    
    ${COMMAND} >> ${TMP_OUT} 2<&1
    if [[ $? -ne 0 ]] ; then  
        error_exit "ERROR: [run_command] Unable to ${DESC} [$FILE]"
    fi
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

MV_FILE_NAME=${1}                           # Variable: File name to move to target directory
typeset -u TARGET_DIR="$2"                  # Variable: Target Directory = INBOUND / OUTBOUND / VIEW

setup_config $0

log_file "INFO: [main] Initialization of script [$SCRIPT_ID] date/time [${NOW}] process [${PRC_ID}]"    

check_params
process_file
clean_up_file $TMP_OUT

log_file "INFO: [main] Completion of script [${SCRIPT_ID}]"

exit 0
