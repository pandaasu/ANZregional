#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  : vds_extract.sh
# AUTHOR  : Steve Gregan
# DATE    : 31-Mar-2010
# PARAMS  : 1 - CONFIG ID (VDS configuration id)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
# Modification history at end of script
#
# This script has been written specifically for the VDS system extract from
# SAP directly into the VDS database
#
# ---------------------------------------------------------------------------

SCRIPT_PATH=${0%/*}
HP_UNIX_OS="HP-UX"
LINUX_OS="Linux"

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

    export PATH="/usr/local/bin:/usr/contrib/bin:/usr/bin:/bin:/etc"
    SCRIPT_PATH=`dirname ${1}`
    if [[ -z $SCRIPT_PATH ]] ; then
        error_exit "ERROR: Unable to extract directory name from [${1}]"
    fi
    if [[ ! -d $SCRIPT_PATH ]] ; then
        error_exit "ERROR: Provided path [${SCRIPT_PATH}] is not a valid directory"
    fi
    
    cd $SCRIPT_PATH
    CONFIG_PATH="${SCRIPT_PATH}/../config"
    
    CONFIG_FILE="${CONFIG_PATH}/ics_loader.config"
    validate_file "${CONFIG_FILE}"
    
    VDS_CFG="${CONFIG_PATH}/vds_interface_config.xml"
    validate_file "${VDS_CFG}"
    
    read_variable "ICS_CLASS_PATH"
    read_variable "JAVA_PATH"
    read_variable "SHLIB_PATH"

    if [[ -z $CURRENT_OS ]] ; then
        CURRENT_OS=`uname`
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
        error_exit "ERROR: ${VARIABLE_INT} entry not found in [${CONFIG_FILE}]"
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
        error_exit "ERROR: File not found [${FILE_INT}]"
    elif [[ ! -s $FILE_INT ]] ; then
        error_exit "ERROR: File empty [${FILE_INT}]"
    elif [[ ! -r $FILE_INT ]] ; then
        error_exit "ERROR: Cannot read from file [${FILE_INT}]"
    elif [[ ! -f $FILE_INT ]] ; then
        error_exit "ERROR: Path specified is not to a file [${FILE_INT}]"
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
    if [[ -z $INT_ID ]] ; then
        error_exit "ERROR: Interface ID Parameter not specified"
    fi
    if [[ -z $CFG_ID ]] ; then
        error_exit "ERROR: Configuration ID Parameter not specified"
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
    exit 1
}

# ---------------------------------------------------------------------------
#
# get_file_from_sap Description:
# Get the file from SAP.
#
# ---------------------------------------------------------------------------
do_extract()
{
    if [ $CURRENT_OS = $HP_UNIX_OS ] ; then    
        export SHLIB_PATH=${SHLIB_PATH} 
    elif [ $CURRENT_OS = $LINUX_OS ] ; then
        export LD_LIBRARY_PATH=${SHLIB_PATH} 
    else
        error_exit "ERROR: Specified O/S [${CURRENT_OS}] is not supported"
    fi
    
    ${JAVA_PATH} -Xmx512m -cp ${SHLIB_PATH}:${ICS_CLASS_PATH}:${SHLIB_PATH}/marsap.jar:${SHLIB_PATH}/classes12.jar:${SHLIB_PATH}/sapjco.jar com.isi.vds.cSapVdsExtract -identifier ${INT_ID} -configuration ${CFG_ID}
    rc=$?
    if [[ $rc -ne 0 ]] ; then
        error_exit "ERROR: Call to ${JAVA_PATH} - com.isi.vds.cSapVdsExtract Failed - Return Code [${rc}]"
    fi
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

INT_ID=${1}
CFG_ID=${2}
setup_config $0
check_params
do_extract
exit 0

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     31-MAR-2010 S. Gregan     Original
# ---------------------------------------------------------------------------

