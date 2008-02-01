#!/bin/sh
# ---------------------------------------------------------------------------
# SCRIPT  :     boss_execution.sh
# AUTHOR  :     Steve Gregan
# DATE    :     10/08/2007
# PARAMS  :     1 - CONFIGURATION FILE
#               2 - EXECUTION FILE
#
# ---------------------------------------------------------------------------
#            F U N C T I O N A L     O V E R V I E W
# ---------------------------------------------------------------------------
#  Modification history at end of script
#
#  This script executes a requested BOSS execution to retrieve scorecard measures.
#
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# setupConfig - configure script variables
# ---------------------------------------------------------------------------

function setupConfig {

   # configuration file - specific per tier
   CONFIG_FILE="${CONFIG_PATH}/boss.config"
   validateFile "${CONFIG_FILE}"

   # read variables from configuration file
   readVariable "JAVA_PATH"
   readVariable "BOSS_CLASS_PATH"

}

# ---------------------------------------------------------------------------
# validateFile - checks that file exists, is readable and not null
# ---------------------------------------------------------------------------

function validateFile {

   file=${1}

   if [[ ! -e ${file} ]] then
      errorExit "ERROR: [validateFile] File not found [${file}]"
   elif [[ ! -s ${file} ]] then
      errorExit "ERROR: [validateFile] File empty [${file}]"
   elif [[ ! -r ${file} ]] then
      errorExit "ERROR: [validateFile] Cannot read from file [${file}]"
   fi

}

# ---------------------------------------------------------------------------
# readVariable   - read in variables from config file
# ---------------------------------------------------------------------------

function readVariable {

    variable=${1}

    /usr/bin/grep "^${variable}" < ${CONFIG_FILE} | read Tag ${variable} Filler

    # Validate variables from config file
    if [[ ${variable} = "" ]] then
      errorExit "ERROR: [readVariable] ${variable} entry not found in [${CONFIG_FILE}]"
    fi

}

# ---------------------------------------------------------------------------
# runExecution - Runs the BOSS execution
# ---------------------------------------------------------------------------

function runExecution {

   export SHLIB_PATH=/ics/lad/sapjco32 

   ${JAVA_PATH} -Xmx512m -cp /ics/lad/sapjco32:${BOSS_CLASS_PATH}:${BOSS_CLASS_PATH}/ISI_Boss.jar:/ics/lad/sapjco32/sapjco.jar:/ics/lad/sapjco32/classes12.jar com.isi.boss.cExecution -configuration ${CONFIG_PATH}/${CFG_FILE} -execution ${CONFIG_PATH}/${EXE_FILE}>&2
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      errorExit "ERROR: [runExecution] Call to ${JAVA_PATH} Failed. Return Code [${rc}]"
   fi

}

# ---------------------------------------------------------------------------
# checkParams - Ensure that passed parameters have values
# ---------------------------------------------------------------------------

function checkParams {

    if [[ ${CFG_FILE} = "" ]] then
        errorExit "ERROR: [checkParams] Configuration File Parameter not specified"
    elif [[ ${EXE_FILE} = "" ]] then
        errorExit "ERROR: [checkParams] Execution File Parameter not specified"
    fi

}

# ---------------------------------------------------------------------------
# errorExit - Handles a script failure
# ---------------------------------------------------------------------------

function errorExit {
    
    echo ${1}
    exit 1

}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

###########################
# Set the ICS environment #
###########################
export PATH="${PATH}:/usr/local/bin:/usr/bin"
SCRIPT_PATH=`/usr/bin/dirname $0`
/usr/bin/cd ${SCRIPT_PATH}
CONFIG_PATH=${SCRIPT_PATH}/../config
###########################

CFG_FILE=${1}              # Variable: Configuration file name
EXE_FILE=${2}              # Variable: Execution file name

setupConfig                # Function: Setup script variables
checkParams                # Function: Check passed parameters have values
runExecution               # Function: Runs the requested execution
exit 0                     # Exit: Exit script with successful flag (0)

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
#     Version     Date          Author          Modification
#     -------   -----------     -------------   -----------------------------
#       1.0     10/08/2007     S. Gregan       Original
# ---------------------------------------------------------------------------

