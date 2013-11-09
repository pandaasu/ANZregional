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
    typeset -i MATCH_COUNT=0
    typeset -i MAX_RCD_COUNT=20
    MAX_RCDS="Maximum number of returnable results reached ...."

    # Create the time range files
    touch -t ${TIME_STR} ${TMP_STR}
    touch -t ${TIME_END} ${TMP_END}

    # Log the find command
    FIND_CMD="find ${ARCHIVE_PATH} -name \"${FILE_PATTERN}*\" -newer ${TMP_STR} \! -newer ${TMP_END} -exec zgrep -q ${GREP_PATTERN} '{}' \; -print"
    log_file "INFO: [exec_search] Find Command [${FIND_CMD}]" "HARMLESS"

    # Retrieve any matching files
    for LINE in `eval "$FIND_CMD"`
    do          
        RESULT=`ls -lrt ${LINE} | awk '{ print $9 " - TIME: " $6 " " $7", " $8 " SIZE(bytes): " $5}'`

        if [[ ${MATCH_COUNT} -eq 0 ]] ; then
            SEARCH_RESULT=${RESULT}
        else        
            SEARCH_RESULT="${SEARCH_RESULT} \n${RESULT}"
        fi
        
        MATCH_COUNT=${MATCH_COUNT}+1

        if [[ ${MATCH_COUNT} -eq ${MAX_RCD_COUNT} ]] ; then
            SEARCH_RESULT="${SEARCH_RESULT} \n${MAX_RCDS}"
            break;
        fi
    done

    # Set the serach result
    if [[ ${MATCH_COUNT} = 0 ]] ; then
       SEARCH_RESULT="[${MATCH_COUNT}] matches found"
    else
       # Append Search statistics
       SEARCH_RESULT="${SEARCH_RESULT} \n\n[${MATCH_COUNT}] matches found"
    fi 

    # Echo output to standard out for website Java code to pickup
    echo "<DATA>"
    echo "${SEARCH_RESULT}"
    echo "</DATA>"

    log_file "INFO: [exec_search] Search Execution complete - ${MATCH_COUNT} matches found" "HARMLESS"
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
# 2.2     24-APR-2009 T. Keon       Added support for Linux environment
# ---------------------------------------------------------------------------
