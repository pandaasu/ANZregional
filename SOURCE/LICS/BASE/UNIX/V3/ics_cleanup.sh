#!/bin/ksh
###########################################################################
#
# Description:
# Cleanup script for log files and outstanding working files
#
# Date          Who         Change History
# ------------  -------     -------------------------
# 29-JUL-2004   J. Eitel    Creation
# 09-NOV-2004   J. Eitel    Added oracle integration log files
# 11-NOV-2004   J. Eitel    Added webview directory to logCleanup
# 12-APR-2005   L. Glen     Added compression to archived integration log
# 06-JUL-2007   S. Gregan   Included ICS environment script
# 29-OCT-2007   T. Keon     Added calls to utility script files for 
#                           common functions and standardised the
#                           script code
############################################################################

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
    read_variable "WORK_PATH"
    
    # set script id for log file
    SCRIPT_ID=${1##*/}              # Get the name of the script
    SCRIPT_NAME=${SCRIPT_ID%%.*}    # Get the name of the script without the ".sh"

    TMP_OUT="${WORK_PATH}/${SCRIPT_NAME}_${NOW}_${PRC_ID}.log"
    
    echo "INFO: Creating working log file [${TMP_OUT}]" >> ${TMP_OUT}
    
    # set the file permissions (chmod 777)
    set_permissions $TMP_OUT    
}

# --------------------------------------------------------------------------
#
# archive_log Description:
# Moves the provided log file to the provided archive path.  It then
# compresses the moved file and creates a new file for future logging to 
# write to
#
# Parameters:
# 1 - Log file to archive
# 2 - Path to archive the file in
#
# --------------------------------------------------------------------------
archive_log()
{   
    LOG_FILE=$1
    LOG_ARCH_PATH=$2
    
    set_date "LOG_DATE" $DATE_FORMAT_FILE
    set_date "LOG_START_DATE" $DATE_FORMAT_READABLE
    
    ARCH_FILE="$LOG_ARCH_PATH/${LOG_FILE##*/}_$LOG_DATE.arc"
    CMP_FILE="${ARCH_FILE}.gz"
    
    CMD_MOVE="cp $LOG_FILE $ARCH_FILE"
    CMD_COMPRESS="gzip -f $ARCH_FILE"
        
    if [[ ! -a $LOG_FILE ]] ; then
        error_exit "ERROR: [archive_log] The log file does not exist: [$LOG_FILE]"
    elif [[ ! -r $LOG_FILE ]] ; then
        error_exit "ERROR: [archive_log] The log file cannot be read: [$LOG_FILE]"
    elif [[ ! -d $LOG_ARCH_PATH ]] ; then
        error_exit "ERROR: [archive_log] The directory to archive does not exist: [$LOG_ARCH_PATH]"
    fi
    
    run_command "$CMD_MOVE" "move" "$LOG_FILE"
    log_file "INFO: [archive_log] Moved log file [$LOG_FILE] to [$ARCH_FILE] successfully"
    
    run_command "$CMD_COMPRESS" "compress" "$ARCH_FILE"
    log_file "INFO: [archive_log] Archived log file [$ARCH_FILE] successfully"
    
    # set the file permissions (chmod 777)
    set_permissions $LOG_FILE
    set_permissions $CMP_FILE
    
    # make new log file with good permissions for all to write to (ie oracle/mqm)
    echo "$LOG_START_DATE [${SCRIPT_ID}] INFO: New log started" > $LOG_FILE
}

# --------------------------------------------------------------------------
#
# log_cleanup Description:
# Removes files which are older than a specified number of days 
#
# Parameters:
# 1 - The directory to check for old files in
# 2 - The number of days old the file should be if it is to be cleaned
# 3 - The type of files to cleanup
#
# --------------------------------------------------------------------------
log_cleanup()
{   
    CLEAN_DIR=$1
    CLEAN_DAY=$2
    CLEAN_FILE=$3
    
    CMD="find ${CLEAN_DIR} -type f -name '${CLEAN_FILE}' -mtime +${CLEAN_DAY} -exec ls {} \;"
    log_file "INFO: [log_cleanup] Executing command: [${CMD}]"
    
    for FILE in `eval "${CMD}"`
    do
        log_file "INFO: [log_cleanup] Removing file [${FILE}] : More than [${CLEAN_DAY}] days old"
        
        rm -f $FILE
        
        if [[ $? -ne 0 ]] ; then
            log_file "WARNING: [log_cleanup] Unable to remove file ${FILE}"
        fi
    done
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
# Main Process
# ---------------------------------------------------------------------------

setup_config $0

log_file "INFO: [main] Initialization of script [$SCRIPT_ID] date/time [${NOW}] process [${PRC_ID}]" 

# ---------------------------------------------------------------------------
# Logs for archiving
# Moves file to another directory, and adds T&D stamp & extension .arc
#
#
# usage:
# archive_log "LOG FILE NAME" "ARCHIVE DIRECTORY"

archive_log "${SCRIPT_PATH}/../log/ics_integration.log" "${SCRIPT_PATH}/../log/archive"

# ----------------------------------------------------------------------------
# Remove all archived logs > specified days
# Removes all files after they are certain number of days that the file
# has not been modified.  Should be used to clean out old Log files, and
# can be used to make sure working directory stays tidy.
#
# examples:
# log_cleanup "/ics/test/work"                    "1"  "*.log"
# 
#
# usage:
# log_cleanup  "DIRECTORY"                      "DAYS"  "FILE TYPE"

# temp files ...
log_cleanup "${SCRIPT_PATH}/../work"        "1"  "*.*"
log_cleanup "${SCRIPT_PATH}/../webview"     "1"  "*.*"

# archived log files ...
log_cleanup "${SCRIPT_PATH}/../log/archive" "21" "*.*"

# archived inbound and outbound files
log_cleanup "${SCRIPT_PATH}/../archive"     "21" "*.*"

# inbound and outbound files
log_cleanup "${SCRIPT_PATH}/../inbound"     "14" "*.*"
log_cleanup "${SCRIPT_PATH}/../outbound"    "14" "*.*"

log_file "INFO: [main] Completion of script [${SCRIPT_ID}]"

clean_up_file $TMP_OUT

exit 0
