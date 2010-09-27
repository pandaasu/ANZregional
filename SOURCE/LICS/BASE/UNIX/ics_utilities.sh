# ---------------------------------------------------------------------------
#
# Description:
# Utilities file for common functions.
#
# Note:
# No #!/bin/ksh needed in this file as it should not create a new shell to
# run the functions in.
#
# Date          Who         Change History
# ------------  -------     -------------------------
# 29-OCT-2007   T. Keon     Creation
# 18-JUN-2008   T. Keon     Added SHLIB_PATH variable
# 12-JUN-2009   T. Keon     Added USE_AMI variable
# 27-SEP-2010   B. Halicki  Added AMI_PATH variable for use with MQFT_LITE
#
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Function Locations (line numbers):
# ---------------------------------------------------------------------------
# archive_file -            87
# clean_up -                139
# clean_up_file -           161
# error_exit -              184
# initialise_ami_tier -     200
# initialise_utilities -    225
# load_current_os -         302
# log_file -                322
# log_file_temp -           365
# move_file -               385
# read_variable -           402
# set_date -                426
# set_ics_path -            459
# set_permissions -         485
# toggle_file_compression - 508
# validate_file -           568
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
#
# Global Variables:
# These should never be changed by other shell scripts, and should never be
# redefined externally.  If you could set variables as read only in unix
# scripting, then these would be set as such.  So treat them as read only!
#
# ---------------------------------------------------------------------------

DATE_FORMAT_FILE=0          # Format: 20071029_123305
DATE_FORMAT_FILE_SHORT=1    # Format: 200710291233
DATE_FORMAT_READABLE=2      # Format: 2007-10-29_12:33:05

INBOUND=0
OUTBOUND=1
PASSTHRU=2
ROUTE=3

# add any additional operating system to support here
HP_UNIX_OS="HP-UX"
LINUX_OS="Linux"

LOG_TO_MAIN=0
LOG_TO_TEMP=1

USE_AMI_YES="yes"
USE_AMI_NO="no"

IGNORE_LOG=0
LOG_TYPE=$LOG_TO_MAIN

COMPRESS_ZIP="*COMPRESS_ZIP"
COMPRESS_GZ="*COMPRESS_GZ"
COMPRESS_Z="*COMPRESS_Z"
COMPRESS="*COMPRESS"
NOCOMPRESS="*NOCOMPRESS"

IS_COMPRESSED=1

TEXT="*TXT"
BINARY="*BIN"
LITE="*LITE"
TRIG="*TRIG"
CMP="*CMP"

# ---------------------------------------------------------------------------
#
# archive_file Description:
# Archive the file provided.
#
# Parameters: 
# 1 - The file to archive
# 2 - Set whether to skip compression.  Defaults to 0 (false).
#
# ---------------------------------------------------------------------------
archive_file()
{
    SOURCE_FILE_INT=$1
    SKIP_CMP=${2:-0}
    
    if [[ $SKIP_CMP -eq 0 ]] ; then  
        # Processing Variables
        DESTINATION_FILE_BASE="${ARCHIVE_PATH}/${SOURCE_FILE_INT##*/}"      # archive file base
        DESTINATION_FILE="${DESTINATION_FILE_BASE}"                         # archive file 
        DESTINATION_ZIP="${DESTINATION_FILE}.gz"                            # zipped file name
    else
        DESTINATION_FILE_BASE="${ARCHIVE_PATH}/${SOURCE_FILE_INT##*/}"      # archive file base
        DESTINATION_FILE="${DESTINATION_FILE_BASE}"                         # archive file 
        DESTINATION_ZIP="${DESTINATION_FILE}"                               # zipped file name
    fi
    
    log_file "INFO: [archive_file] Moving file [${SOURCE_FILE_INT}] to [${DESTINATION_FILE}]" "HARMLESS"
    
    # pre process zip file if necessary
    if [[ -a $DESTINATION_ZIP ]] ; then
        log_file "INFO: [archive_file] The zipped archive [${DESTINATION_ZIP}] exists.  Remove for new zipped archive" "HARMLESS"
        
        rm -f $DESTINATION_FILE >> $TMP_OUT 2>&1
        if [[ $? -ne 0 ]] ; then
            log_file "WARNING: [archive_file] Unable to remove file ${DESTINATION_FILE}" "HARMLESS"
        fi
    fi

    # move the file to the archive directory.
    mv $SOURCE_FILE_INT $DESTINATION_FILE >> $TMP_OUT 2>&1
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [archive_file] Unable to copy file to archive directory"
    fi
    
    if [[ $SKIP_CMP -eq 0 ]] ; then
        gzip -f $DESTINATION_FILE >> $TMP_OUT 2>&1
        if [[ $? -ne 0 ]] ; then
            error_exit "ERROR: [archive_file] Compress of file failed"
        fi
        
        log_file "INFO: [archive_file] File archived and zipped to [${DESTINATION_ZIP}]" "HARMLESS"
    fi
}

# --------------------------------------------------------------------------
#
# clean_up Description:
# Cleanup the temporary files created during initialisation
#
# Parameters: <none>
# 
# --------------------------------------------------------------------------
clean_up()
{
    clean_up_file $SQL_FILE
    clean_up_file $SQL_OUT
    clean_up_file $TMP_OUT
    clean_up_file $COMPRESS_FILE_NAME
    clean_up_file $DECOMPRESS_FILE_NAME
    
    if [[ $DATA_FLOW_TYPE -ne $PASSTHRU ]] ; then
        clean_up_file $Q_FILE
    fi
}

# ---------------------------------------------------------------------------
#
# clean_up_file Description:
# Removes the provided file and logs any errors which occur during the remove.
#
# Parameters:
# 1 - The file to clean up (ie remove)
#
# ---------------------------------------------------------------------------
clean_up_file()
{
    FILE_INT=$1
    
    if [[ -a $FILE_INT ]] ; then
        log_file "INFO: [clean_up_file] Cleaning up temporary file: ${FILE_INT}" "HARMLESS"
            
        rm -f $FILE_INT
        if [[ $? -ne 0 ]] ; then
            log_file "WARNING: [clean_up_file] Unable to remove file ${FILE_INT} user:group [${UG}]" "HARMLESS"
        fi
    fi
}

# --------------------------------------------------------------------------
#
# error_exit Description:
# Exit after a critical error and ensure appropriate logging is created.
#
# Parameters:
# 1 - A message explaining what the error was
#
# --------------------------------------------------------------------------
error_exit()
{   
    ERR_MSG=`echo ${1} | sed -e "s/-/./g"`
    log_file "${ERR_MSG}. See log [${TMP_OUT}]" "CRITICAL"
    
    exit 1
}

# --------------------------------------------------------------------------
#
# initialise_ami_tier Description:
# Initialise the AMI tier and load the path and queue manager
#
# Parameters: <none>
# 
# --------------------------------------------------------------------------
initialise_ami_tier()
{
    eval ". ${ENV_VAR} ${AMI_TIER}" >> ${TMP_OUT} 2>&1
    if [[ ! -d "${AMI_PATH}" ]] ; then
        error_exit "ERROR: [initialise_ami_tier] The AMI Platform failed during [${ENV_VAR} ${AMI_TIER}]."
    fi
    
    AMI_QMGR=`readcfg qmgrname | awk -F, '{print$2}' 2>&1`
    if [[ $? -ne 0 ]] ; then
        echo ${AMI_QMGR} >> ${TMP_OUT}
        error_exit "ERROR: [initialise_ami_tier] Error seting queue manager."
    fi
}

# --------------------------------------------------------------------------
#
# initialise_utilities Description:
# Initialise the common and required variables for the utilities
# and scripts to run correctly.
#
# Parameters:
# 1 - The basename of the program as it was called (i.e. $0 from the calling
#   script.
#
# --------------------------------------------------------------------------
initialise_utilities()
{
    if [[ $# -eq 0 || -z $1 ]] ; then
        error_exit "ERROR: [initialise_utilities] Invalid base script name passed into function."
    fi
    
    set_ics_path $1
    
    # configuration file - specific per tier
    CONFIG_FILE="${CONFIG_PATH}/ics_loader.config"
    validate_file "${CONFIG_FILE}"
    
    PRC_ID=`echo ${$}`           # Process ID
    UG=`id`                      # User and group
    
    read_variable "LOGFILE"
    read_variable "INBOUND_PATH"
    read_variable "OUTBOUND_PATH"
    read_variable "WORK_PATH"
    read_variable "ARCHIVE_PATH"
    read_variable "WEBVIEW_PATH"
    read_variable "STATISTICS_PATH"
    read_variable "ICS_CLASS_PATH"
    read_variable "JAVA_PATH"
    read_variable "SHLIB_PATH"
    read_variable "BIN_PATH"
    read_variable "ENV_VAR"
    read_variable "DATABASE"
    read_variable "USERNAME"
    read_variable "PASSWORD"
    read_variable "AMI_TIER"
    read_variable "SYS_TIER"
    read_variable "SERVER"
    read_variable "TARG_PATH"
    read_variable "TARG_QMGR"
    read_variable "HK_TARG_PATH"
    read_variable "HK_TARG_QMGR"
    read_variable "USE_AMI"
    read_variable "AMI_PATH" 
    
    set_date "NOW" $DATE_FORMAT_FILE_SHORT     # Current date & time for filenames
    load_current_os
    
    MSG_SEQ=1
    
    # set script id for log file
    SCRIPT_ID=${1##*/}              # Get the name of the script
    SCRIPT_NAME=${SCRIPT_ID%%.*}    # Get the name of the script without the ".sh"
    
    SQL_FILE="${WORK_PATH}/${SCRIPT_NAME}_sqlfile_${NOW}_${PRC_ID}.sql"         # SQL FILE
    SQL_OUT="${WORK_PATH}/${SCRIPT_NAME}_sqlout_${NOW}_${PRC_ID}.out"           # SQL OUT FILE
    TMP_OUT="${WORK_PATH}/${SCRIPT_NAME}_${NOW}_${PRC_ID}.log"
    
    # set the Q_FILE only if it has not been specified already
    Q_FILE=${Q_FILE:-"${INBOUND_PATH}/${INTERFACE_ID}_${NOW}_${PRC_ID}_${MSG_SEQ}.DAT"}
    
    # set the compression option if it has not been specified already
    CMP_PARAM=${CMP_PARAM:-$NOCOMPRESS}
    
    # set the ami tier option if it has not been specified already
    USE_AMI=${USE_AMI:-$USE_AMI_YES}
    
    # set global is compressed value so we dont need to check if CMP_PARAM matches
    # any of the compress options.  ***NOTE: Use single [ to get correct result.
    if [ $NOCOMPRESS = $CMP_PARAM ] ; then
        IS_COMPRESSED=0
    fi
        
    echo "INFO: Creating working log file [${TMP_OUT}]" >> $TMP_OUT
    
    set_permissions $TMP_OUT
    
    log_file "INFO: [initialise_utilities] Use AMI environment [${USE_AMI}]" "HARMLESS"
    # only set the AMI environment if we are using their functionality.
    if [ $USE_AMI_YES = $USE_AMI ] ; then
        initialise_ami_tier
    fi
}

# --------------------------------------------------------------------------
#
# load_current_os Description:
# Load the current operating system name for any cases when specific 
# commands need to be run depending on the current operating system.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
load_current_os()
{
    if [[ -z $CURRENT_OS ]] ; then
        CURRENT_OS=`uname`
        if [[ $? -ne 0 ]] ; then
            log_file "WARNING: [load_current_os] Unable to load the current OS information." "HARMLESS"
        fi
    fi
}

# ---------------------------------------------------------------------------
#
# log_file Description:
# Writes a script failure to a log file which tivoli will monitor.
#
# Parameters:
# 1 - A message to display in the log file
# 2 - The severity of the message
#
# ---------------------------------------------------------------------------
log_file()
{
    if [[ $LOG_TYPE -eq $LOG_TO_TEMP ]] ; then
        log_file_temp "$1"
    else
        LOG_MSG="${1}"
        SEVERITY="${2}"
        
        if [[ $IGNORE_LOG -eq 1 ]] ; then
            echo "${LOG_MSG}"
            echo "Error occured logging message.  Exiting to avoid infinite log_file calls ..."
            
            exit 1
        fi
        
        IGNORE_LOG=1
        
        # force the script to exit with the log message printed to screen.  
        # If the log file is not set then it will not be possible to view the
        # error message even if run manually unless the following is executed
        if [[ -z ${LOGFILE} ]] ; then
            log_file "${LOG_MSG}" "${SEVERITY}"
        fi
        
        set_date "DATE_NOW" $DATE_FORMAT_READABLE
        
        echo "[${DATE_NOW}] INFO ${AMI_TIER} ${SERVER} ${SEVERITY} ${SCRIPT_ID}:[${PRC_ID}] ${INTERFACE_ID} ${LOG_MSG}" >> ${LOGFILE}
        echo "$LOG_MSG"
        
        IGNORE_LOG=0
    fi
}

# ---------------------------------------------------------------------------
#
# log_file Description:
# Writes a script failure to a log file.  Ensure the logging goes to the 
# TMP_OUT file not the LOGFILE
#
# Parameters:
# 1 - A message to display in the log file
#
# ---------------------------------------------------------------------------
log_file_temp()
{
   LOG_MSG="${1}"   
   set_date "DATE_NOW" $DATE_FORMAT_READABLE
   
   echo "[${DATE_NOW}] $LOG_MSG" >> ${TMP_OUT}
   echo "$LOG_MSG"
}

# ---------------------------------------------------------------------------
#
# move_file Description:
# Rename the provided file to the specified new name
#
# Parameters:
# 1 - The file name
# 2 - The new file name
#
# ---------------------------------------------------------------------------
move_file()
{
    mv $1 $2
    if [[ $? -ne 0 ]] ; then
        log_file "WARNING: [move_file] Unable to move file from [${1}] to [${2}]" "HARMLESS"
    fi
}

# --------------------------------------------------------------------------
#
# read_variable Description:
# Read a specified variable from the configuration file.
#
# Parameters:
# 1 - Variable to get from the configuration file
#
# --------------------------------------------------------------------------
read_variable()
{
    VARIABLE_INT=$1
    
    eval $VARIABLE_INT=`grep "^${VARIABLE_INT}" < ${CONFIG_FILE} | awk '{print $2}'`
    
    # Validate variables from config file
    if [[ -z $VARIABLE_INT ]] ; then
        error_exit "ERROR: [read_variable] ${VARIABLE_INT} entry not found in [${CONFIG_FILE}]"
    fi
}

# --------------------------------------------------------------------------
#
# set_date Description:
# Set the date into a specified variable in a specified format.  When adding
# a new format, remember to add a Global Variable for the new date format.
#
# Parameters:
# 1 - Variable to set date into
# 2 - Format to set the date to (use a DATE_FORMAT_... variable from Global
#   Variables)
#
# --------------------------------------------------------------------------
set_date()
{
    VARIABLE_INT=$1
    FORMAT_INT=$2
    
    case $FORMAT_INT in
        $DATE_FORMAT_FILE)
            eval $VARIABLE_INT=`date +%Y%m%d_%H%M%S`
            ;;
        $DATE_FORMAT_FILE_SHORT)
            eval $VARIABLE_INT=`date +%Y%m%d%H%M`
            ;;
        $DATE_FORMAT_READABLE)
            eval $VARIABLE_INT=`date +%Y-%m-%d_%H:%M:%S`
            ;;
        *)
            error_exit "ERROR: [set_date] ${FORMAT_INT} is not a known format type."
            ;;
    esac
}

# --------------------------------------------------------------------------
#
# set_ics_path Description:
# Set the ICS environment so the scripts will run correctly on the Oracle 10g
# databases.  This must be called by all scripts before they run any other
# function.
#
# Parameters:
# 1 - The basename of the program as it was called (i.e. $0 from the calling
#   script.
#
# --------------------------------------------------------------------------
set_ics_path()
{
    export PATH="/usr/local/bin:/usr/contrib/bin:/usr/bin:/bin:/etc"
    SCRIPT_PATH=`dirname ${1}`
    
    if [[ -z $SCRIPT_PATH ]] ; then
        error_exit "ERROR: [set_ics_path] Unable to extract directory name from [${1}]"
    fi
    
    if [[ ! -d $SCRIPT_PATH ]] ; then
        error_exit "ERROR: [set_ics_path] Provided path [${SCRIPT_PATH}] is not a valid directory"
    fi
    
    cd $SCRIPT_PATH
    CONFIG_PATH="${SCRIPT_PATH}/../config"
}

# --------------------------------------------------------------------------
#
# set_permissions Description:
# Set the permission to 777 for the provided file.
#
# Parameters:
# 1 - The file to set the permissions for.
#
# --------------------------------------------------------------------------
set_permissions()
{
    FILE_INT=$1
    
    chmod 777 $FILE_INT
    if [[ $? -ne 0 ]] ; then
        log_file "WARNING: [set_permissions] Unable to change permissions 777 on [${FILE_INT}] user:group [${UG}]" "HARMLESS"
    fi
}

# ---------------------------------------------------------------------------
#
# toggle_file_compression Description:
# Compresses or uncompresses the specified file.  Use the COMPRESS_FILE_NAME
# or DECOMPRESS_FILE_NAME variables to access the correct file names after
# compressing or decompressing respectively.
#
# Parameters:
# 1 - The name of the file to toggle compression on.
# 2 - Set whether to compress or uncompress the file.
#   (0 = compress, 1 = uncompress)
#
# ---------------------------------------------------------------------------
toggle_file_compression()
{
    FILE_INT=$1
    CMP_TYPE=$2
    
    if [[ $CMP_TYPE -eq 0 ]] ; then
        log_file "INFO: [toggle_file_compression] Compressing file [${FILE_INT}]" "HARMLESS"
        CMD="gzip -f $FILE_INT"
        
        COMPRESS_FILE_NAME="${FILE_INT}.gz"
    elif [[ $CMP_TYPE -eq 1 ]] ; then
        log_file "INFO: [toggle_file_compression] Uncompressing file [${FILE_INT}]" "HARMLESS"        
        
        # get the files extension so we can handle .zip or other different file extensions so gunzip can 
        # decompress the files successfully using the -S option
        FILE_EXT=".${FILE_INT##*.}"
        
        log_file "INFO: [toggle_file_compression] File extension [${FILE_EXT}]" "HARMLESS"  
        
        if [[ $FILE_EXT = . ]] ; then
            CMD="gunzip -N -v -f $FILE_INT"
        else
            if [[ $FILE_EXT = .zip || $FILE_EXT = .gz || $FILE_EXT = .Z ]] ; then
                CMD="gunzip -N -v -f -S ${FILE_EXT} ${FILE_INT}"
            else                
                if [ $COMPRESS_ZIP = $CMP_PARAM ] ; then
                    move_file ${FILE_INT} "${FILE_INT}.zip"
                    CMD="gunzip -N -v -f -S .zip ${FILE_INT}.zip"
                elif [ $COMPRESS_GZ = $CMP_PARAM ] ; then
                    move_file ${FILE_INT} "${FILE_INT}.gz"
                    CMD="gunzip -N -v -f -S .gz ${FILE_INT}.gz"
                elif [ $COMPRESS_Z = $CMP_PARAM ] ; then
                    move_file ${FILE_INT} "${FILE_INT}.Z"
                    CMD="gunzip -N -v -f -S .Z ${FILE_INT}.Z"
                else
                    error_exit "ERROR: [toggle_file_compression] Compress command [${CMP_PARAM}] is not valid."
                fi
            fi
        fi
    else
        error_exit "ERROR: [toggle_file_compression] Specified compression type [${CMP_TYPE}] is not valid."        
    fi
    
    log_file "INFO: [toggle_file_compression] Running command [${CMD}]" "HARMLESS"
    
    DECOMPRESS_FILE_NAME=`${CMD} 2>&1 | awk '{print $6}'`
    rc=$?
    
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: [toggle_file_compression] Failed to run compression.  Return code [${rc}]."            
    fi
}

# --------------------------------------------------------------------------
#
# validate_file Description:
# Ensure the provided file is valid.
#
# Parameters:
# 1 - The path of the file to validate
#
# --------------------------------------------------------------------------
validate_file()
{
    FILE_INT=$1
    
    if [[ ! -a $FILE_INT ]] ; then
        error_exit "ERROR: [validate_file] File not found [${FILE_INT}]"
    elif [[ ! -s $FILE_INT ]] ; then
        error_exit "ERROR: [validate_file] File empty [${FILE_INT}]"
    elif [[ ! -r $FILE_INT ]] ; then
        error_exit "ERROR: [validate_file] Cannot read from file [${FILE_INT}]"
    elif [[ ! -f $FILE_INT ]] ; then
        error_exit "ERROR: [validate_file] Path specified is not to a file [${FILE_INT}]"
    fi
}
