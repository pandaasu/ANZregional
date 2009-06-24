# ---------------------------------------------------------------------------
#
# Description:
# Utilities file for oracle database access and validation.
#
# Note:
# No #!/bin/ksh needed in this file as it should not create a new shell to
# run the functions in.
#
# Date          Who         Change History
# ------------  -------     -------------------------
# 29-OCT-2007   T. Keon     Creation
# 03-MAR-2008   L. Glen     Modified function call for ROUTER_MQFT
# 05-JUN-2009   T. Keon     Added retry to check_DB
#
# ---------------------------------------------------------------------------

# Include the utilities script file for common functionality
. ${SCRIPT_PATH}/ics_utilities.sh

# ---------------------------------------------------------------------------
# Function Locations (line numbers):
# ---------------------------------------------------------------------------
# check_DB -                48
# load_file -               71
# ora_connect -             123
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
#
# Global Variables:
# These should never be changed by other shell scripts, and should never be
# redefined externally.  If you could set variables as read only in unix
# scripting, then these would be set as such.  So treat them as read only!
#
# ---------------------------------------------------------------------------

LOAD_FILE_INBOUND=0
LOAD_FILE_PASSTHRU=1
LOAD_FILE_ROUTER=2
LOAD_FILE_RESTART=3

# ---------------------------------------------------------------------------
#
# check_DB Description:
# Check the availability of the DB specified in the config file
#
# Parameters: <none>
#
# ---------------------------------------------------------------------------
check_DB()
{
    log_file "INFO: [check_DB] Checking database : [${DATABASE}]" "HARMLESS"
    
    orawait "${DATABASE}" 1 60
    if [[ $? -ne 0 ]] ; then   
        # Retry database check before giving up
        if [[ -z $DB_RETRY ]] ; then
            DB_RETRY="YES"
            log_file "INFO: [check_DB] Retrying database check in 5 seconds [${DATABASE}]" "HARMLESS"
            sleep 5
            check_DB
        else        
            error_exit "ERROR: [check_DB] Database [${DATABASE}] is unavailable for 60 mins"
        fi
    fi
}

# --------------------------------------------------------------------------
#
# load_file Description:
# Creates the SQL file to run via the sqlplus command for a specified 
# command type.
#
# Parameters:
# 1 - The type of command to run (use a LOAD_FILE_... variable from Global
#   Variables)
# 2 - The id value to pass into the command 
# 3 - The file to include in the command 
#
# --------------------------------------------------------------------------
load_file()
{
    TYPE_INT=$1
    ID_INT=$2
    LOAD_FILE=${3##*/}
    
    log_file "INFO: [load_file] Executing oracle procedure to load file." "HARMLESS"
    log_file "INFO: [load_file] Type [${TYPE_INT}] | ID [${ID_INT}] | File [${LOAD_FILE}]" "HARMLESS"
    
    if [[ -z $SQL_FILE ]] ; then
        error_exit "ERROR: [load_file] SQL file not specified"
    fi
    
    # Create the sqlplus command file
    case $TYPE_INT in
        $LOAD_FILE_INBOUND)
            print "execute lics_inbound_loader.execute('${ID_INT}','${LOAD_FILE}');" > $SQL_FILE
            print "exit;" >> $SQL_FILE
            ;;
        $LOAD_FILE_PASSTHRU)
            print "execute lics_passthru_loader.execute('${ID_INT}','${LOAD_FILE}');" > $SQL_FILE
            print "exit;" >> $SQL_FILE
            ;;
        $LOAD_FILE_ROUTER)
            print "var return_var varchar2(4000)" > $SQL_FILE
            print "execute :return_var := lics_router.execute('${ID_INT}','${LOAD_FILE}');" >> $SQL_FILE
            print "print return_var;" >> $SQL_FILE 
            print "exit;" >> $SQL_FILE
            ;;
        $LOAD_FILE_RESTART)
            print "execute lics_job_control.restart_jobs;" > $SQL_FILE
            print "exit;" >> $SQL_FILE
            ;;
        *)
            error_exit "ERROR: [load_file] ${TYPE_INT} is not a known command type."
            ;;
    esac
    
    # Execute procedure
    sqlplus -L ${USERNAME}/${PASSWORD}@${DATABASE} @${SQL_FILE} > ${SQL_OUT} 2>&1
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [load_file] SQLPlus Call Failed: See Oracle error file [${SQL_OUT}]"
    fi
    
    grep -q "^PL/SQL procedure successfully completed." < $SQL_OUT
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [load_file] Stored procedure failed: See Oracle error file [${SQL_OUT}]"
    fi
}

# ---------------------------------------------------------------------------
#
# ora_connect Description:
# Sets the oracle environment variables for scripts operation.
#
# Parameters: <none>
#
# ---------------------------------------------------------------------------
ora_connect()
{    
    log_file "INFO: [ora_connect] Connecting to database : [${DATABASE}]" "HARMLESS"
    
    # set the database name to be in lower case
    typeset -l lower_db="${DATABASE}"
    
    # connect to the oracle db ... NOTE the "." in the command is required so the environment settings
    # loaded in oraconnect are available in this script
    . oraconnect "${lower_db}"
    if [[ $? -ne 0 ]] ; then
        error_exit "ERROR: [ora_connect] oraconnect to [${lower_db}] failed"
    fi
}
