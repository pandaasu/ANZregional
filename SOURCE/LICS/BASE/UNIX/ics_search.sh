#!/bin/ksh
# ---------------------------------------------------------------------------
# SCRIPT  :     ics_search.sh
# AUTHOR  :     Linden Glen
# DATE    :     29-September-2005
# PARAMS  :     1 - FILE PATTERN - Pattern of file name to grep
#               2 - GREP PATTERN - Pattern to grep for in files
#               3 - TIME STR - Start time for file search (Optional)
#               4 - TIME END - End time for file search (Optional)
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
#  Modification history at end of script
#
#  This script is written specifically for the ICS. It is called from the ICS
#  website, and will search all files matching the file pattern passed for the
#  specified string pattern.
#
# ---------------------------------------------------------------------------

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
    # initialise the utlities script
    initialise_utilities $1
    
    # Declare Files & temp variables
    TMP_OUT="${WORK_PATH}/ics_search_${NOW}_${PRC_ID}.log"
    TMP_STR="${WORK_PATH}/ics_search_${NOW}_${PRC_ID}.str"
    TMP_END="${WORK_PATH}/ics_search_${NOW}_${PRC_ID}.end"
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
    if [[ ${FILE_PATTERN} = "" ]] ; then
        error_exit "ERROR: [check_params] File pattern Parameter not specified"
    elif [[ ${GREP_PATTERN} = "" ]] ; then
        error_exit "ERROR: [check_params] Grep pattern Parameter not specified"
    elif [[ ${TIME_STR} = "" ]] ; then
        error_exit "ERROR: [check_params] Time range start Parameter not specified"
    elif [[ ${TIME_END} = "" ]] ; then
        error_exit "ERROR: [check_params] Time range end Parameter not specified"
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
    
    clean_up_file $TMP_STR
    clean_up_file $TMP_END
}

# --------------------------------------------------------------------------
#
# exec_search Description:
# Execute the search for the file specified.
#
# Parameters: <none>
#
# --------------------------------------------------------------------------
exec_search()
{
    log_file "INFO: [exec_search] Executing search of files matching [${FILE_PATTERN}*] for pattern [${GREP_PATTERN}] for time range [${TIME_STR} to ${TIME_END}]" "HARMLESS"

    # Define variables
    typeset -i match_count=0
    SEARCH_RESULT=""
    MAX_RCDS="Maximum number of returnable results reached ...."
    typeset -i MAX_RCDS_BYTES=`echo ${MAX_RCDS} | wc -c`
    MAX_REACHED=FALSE

    # Create the time range files
    touch -t ${TIME_STR} ${TMP_STR}
    touch -t ${TIME_END} ${TMP_END}

    # Log the find command
    FIND_CMD="find ${ARCHIVE_PATH} -name ${FILE_PATTERN}* -newer ${TMP_STR} \! -newer ${TMP_END} -exec zgrep -q ${GREP_PATTERN} '{}' \; -print"
    log_file "INFO: [exec_search] Find Command [${FIND_CMD}]" "HARMLESS"

    # Retrieve any matching files
    find ${ARCHIVE_PATH} -name ${FILE_PATTERN}* -newer ${TMP_STR} \! -newer ${TMP_END} -exec zgrep -q ${GREP_PATTERN} '{}' \; -print | while read file
    do
       if [[ ${MAX_REACHED} = "TRUE" ]] ; then 
          break
       fi
       
       match_count=${match_count}+1
       RESULT=`ls -lrt ${file} | awk '{ print $9 " - TIME: " $6 " " $7", " $8 " SIZE(bytes): " $5}'`
       typeset -i SEARCH_RESULT_BYTES=`echo ${SEARCH_RESULT} | wc -c`
       typeset -i RESULT_BYTES=`echo ${RESULT} | wc -c`
       SEARCH_STAT="[${match_count}] matches found"
       typeset -i SEARCH_STAT_BYTES=`echo ${SEARCH_STAT} | wc -c`
       typeset -i BYTE_CHECK=${SEARCH_RESULT_BYTES}+${MAX_RCDS_BYTES}+${RESULT_BYTES}+${SEARCH_STAT_BYTES}
       
       if [[  ${BYTE_CHECK} -gt 3700 ]] ; then
          SEARCH_RESULT=`echo "${SEARCH_RESULT} \n ${MAX_RCDS}"`
          MAX_REACHED=TRUE
       else
          SEARCH_RESULT=`echo "${SEARCH_RESULT} \n ${RESULT}"`
       fi 
    done

    # Set the serach result
    if [[ ${match_count} = 0 ]] ; then
       SEARCH_RESULT="[${match_count}] matches found"
    else
       # Append Search statistics
       SEARCH_RESULT=`echo "${SEARCH_RESULT} \n\n ${SEARCH_STAT}"`
    fi

    # Echo output to standard out for website Java code to pickup
    echo "<DATA>"
    echo "${SEARCH_RESULT}"
    echo "</DATA>"

    log_file "INFO: [exec_search] Search Execution complete - ${match_count} matches found" "HARMLESS"
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

FILE_PATTERN=${1}              # Variable: File pattern to search in
GREP_PATTERN=${2}              # Variable: Pattern to search for
TIME_STR=${3}                  # Variable: Start time to search for
TIME_END=${4}                  # Variable: End time to search for

setup_config $0                # Function: Setup script variables

log_file "INFO: [main] Initialized script [${SCRIPT_ID}] for interface [SEARCH]" "HARMLESS"
log_file "INFO: [main] Log file location : [${TMP_OUT}]" "HARMLESS"

check_params                # Function: Check passed parameters have values
exec_search                 # Function: Execute search functionality
clean_up_local              # Function: Remove Temporary Files

log_file "INFO: [main] Completion of script [${SCRIPT_ID}] for interface [${FILE_PATTERN}]" "HARMLESS"

exit 0                     # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
# Version Date        Author        Modification
# ------- ----------- ------------- -----------------------------
# 1.0     29-SEP-2004 L. Glen       Original
# 2.0     24-JUL-2006 S. Gregan     Added search time range
# 2.1     03-MAR-2008 T. Keon       Added calls to utility script files for
#                                   common functions and standardised the
#                                   script code
# ---------------------------------------------------------------------------
