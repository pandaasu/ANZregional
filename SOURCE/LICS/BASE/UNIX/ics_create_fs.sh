#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : ics_create_fs.sh
# AUTHOR  : Trevor Keon
# DATE    : 13-November-2008
# PARAMS  : 1 - ROOT DIR (Root directory)
#           2 - SYSTEM (System)
#           3 - ENVIRONMENT (ICS environment - Test or Prod)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# This script has been written to create the directory structure for new ICS
# installations, and set the permissions.
#
# Example usage:
#   ./ics_create_fs.sh *NONE lad test
#
# Will create ICS directory structure in: /ics/lad/test/...
#
# ---------------------------------------------------------------------------

SCRIPT_PATH=${0%/*}

USE_DEFAULT="*NONE"
EXCLUDE="*EXCLUDE"

DEFAULT_ROOT="ics"
DEFAULT_SYS="lad"
DEFAULT_ENV="test"

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
    PRC_ID=`echo ${$}`           # Process ID
    UG=`id`                      # User and group
    
    # set script id for log file
    SCRIPT_ID=${1##*/}              # Get the name of the script
    SCRIPT_NAME=${SCRIPT_ID%%.*}    # Get the name of the script without the ".sh" 
    
    cd /
}

# ---------------------------------------------------------------------------
#
# print_message Description:
# Display logging message to screen.
#
# Parameters:
# 1 - A message to display in the log file
# 2 - The severity of the message
#
# ---------------------------------------------------------------------------
print_message()
{
    LOG_MSG="${1}"        
    SEVERITY="${2}"
    DATE_NOW=`date +%Y-%m-%d_%H:%M:%S`
    
    echo "[${DATE_NOW}] INFO ${SEVERITY} ${SCRIPT_ID}:[${PRC_ID}] ${LOG_MSG}"
}

# --------------------------------------------------------------------------
#
# create_ics_path Description:
# Create the path for ICS, for the given system.
#
# Parameters:
# 1 - The path the directory needs to be created under
# 2 - The name of the directory to create
#
# --------------------------------------------------------------------------
create_ics_path()
{
    CREATE_PATH=$1
    CREATE_DIR=$2
    DEFAULT_DIR=$3
    
    if [ $USE_DEFAULT = $CREATE_DIR ] ; then
        print_message "INFO: [create_ics_path] Using default directory [${DEFAULT_DIR}]" "HARMLESS" 
        CREATE_DIR=$DEFAULT_DIR
    elif [ $EXCLUDE = $CREATE_DIR ] ; then
        print_message "INFO: [create_ics_path] Excluding directory. [${DEFAULT_DIR}]" "HARMLESS"
        return
    fi
    
    LAST_PATH="${CREATE_PATH}/${CREATE_DIR}"
    
    print_message "INFO: [create_ics_path] Creating directory [${LAST_PATH}]" "HARMLESS"  
    create_dir "${LAST_PATH}"
}

# --------------------------------------------------------------------------
#
# create_dir_list Description:
# Create the child directories common across all ICS installations.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
create_dir_list()
{
    create_dir "${LAST_PATH}/archive"
    create_dir "${LAST_PATH}/bin"
    create_dir "${LAST_PATH}/config"
    create_dir "${LAST_PATH}/inbound"
    create_dir "${LAST_PATH}/java"
    create_dir "${LAST_PATH}/log"
    create_dir "${LAST_PATH}/log/archive"
    create_dir "${LAST_PATH}/outbound"
    create_dir "${LAST_PATH}/statistics"
    create_dir "${LAST_PATH}/temp"
    create_dir "${LAST_PATH}/webview"
    create_dir "${LAST_PATH}/work"
}

# --------------------------------------------------------------------------
#
# create_dir Description:
# Create the specified directory.  Ensure it does not exist before creating.
#
# Parameters:
# 1 - The directory to create.
#
# --------------------------------------------------------------------------
create_dir()
{
    DIR_TO_CREATE=$1
    
    if [[ -d $DIR_TO_CREATE ]] ; then
        print_message "INFO: [create_dir] Directory [${DIR_TO_CREATE}] already exists.  Skipping ..." "HARMLESS"
    else
        mkdir $DIR_TO_CREATE
        
        if [[ $? -ne 0 ]] ; then
            error_exit "ERROR: [create_dir] Failed to create directory [${DIR_TO_CREATE}]"
        else
            print_message "INFO: [create_dir] Directory [${DIR_TO_CREATE}] created successfully" "HARMLESS"
            set_permissions $DIR_TO_CREATE
        fi
    fi
}

# --------------------------------------------------------------------------
#
# create_dir Description:
# Create the specified directory.  Ensure it does not exist before creating.
#
# Parameters:
# 1 - The directory to create.
#
# --------------------------------------------------------------------------
create_log()
{
    LOG_FILE="${LAST_PATH}/log/ics_integration.log"
    
    print_message "INFO: [create_log] Creating log file [${LOG_FILE}]" "HARMLESS"
    
    if [[ ! -a $LOG_FILE ]] ; then
        touch "${LOG_FILE}"
        set_permissions $LOG_FILE
    fi
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
    chmod 777 $1
    if [[ $? -ne 0 ]] ; then
        print_message "WARNING: [set_permissions] Unable to change permissions 777 on [${1}] user:group [${UG}]" "HARMLESS"
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
    print_message "${ERR_MSG}." "CRITICAL"
    
    exit 1
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
    if [[ -z $ROOT_PATH ]] ; then
        error_exit "ERROR: [check_params] Root path not specified"
    elif [[ -z $SYSTEM ]] ; then
        error_exit "ERROR: [check_params] System not specified"        
    elif [[ -z $ENVIRONMENT ]] ; then
        error_exit "ERROR: [check_params] Environment not specified"            
    else
        print_message "INFO: [check_params] Verified script input parameters" "HARMLESS"
    fi
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

ROOT_PATH=${1}          # Variable: Root Path - ie: ics
SYSTEM=${2}             # Variable: System - ie: lad
ENVIRONMENT=${3}        # Variable: Environment - ie: test

setup_config $0         # Function: Setup script variables

print_message "INFO: [main] Initialized script [${SCRIPT_NAME}]" "HARMLESS"

check_params
create_ics_path "" "${ROOT_PATH}" "${DEFAULT_ROOT}"
create_ics_path "${LAST_PATH}" "${SYSTEM}" "${DEFAULT_SYS}"
create_ics_path "${LAST_PATH}" "${ENVIRONMENT}" "${DEFAULT_ENV}"
create_dir_list
create_log

print_message "INFO: [main] Completion of script [${SCRIPT_ID}]" "HARMLESS"

exit 0                  # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     13-NOV-2008 T. Keon       Original 
# 1.1     21-NOV-2008 T. Keon       Added option to exclude directories
# ---------------------------------------------------------------------------