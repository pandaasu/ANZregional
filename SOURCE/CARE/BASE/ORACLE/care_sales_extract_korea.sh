#!/bin/ksh
# ---------------------------------------------------------------------
# Script: care_sales_extract_korea.sh
# 13-Dec-2006, ISI.  Modification history at end of script
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------------
# printUsage - Prints the script usage
# ---------------------------------------------------------------------------

function printUsage {

   # Print the script usage
   echo .
   echo "Usage: care_sales_extract_korea.sh EXT_PERIOD]"
   echo "          EXT_PERIOD : Sales extract period [*LAST or YYYYPP]"
   echo .
   
}

# ---------------------------------------------------------------------------
# checkParameters - Checks the script parameters
# ---------------------------------------------------------------------------

function checkParameters {

   # Check the input parameters
   if [[ ${EXT_PERIOD} = "" ]] then
      printUsage
      abendExit "[ERROR]:[checkParameters] Extract period not found as input parameter."
   fi

}

# ---------------------------------------------------------------------------
# setEnvironment - Sets the script environment
# ---------------------------------------------------------------------------

function setEnvironment {

   # Set the environment variables
   AMITIER="APQM003P"
   QUENAME="QR.SALCAR01"
   TMPPATH="/tmp"
   DTAPATH="/mfkdw/care/data"
   ARCPATH="/mfkdw/care/archive" 
   LOGPATH="/mfkdw/care/log"
   SQLPATH="/mfkdw/care/work"
   ORAUSER="dw_app/dwapppw"
   ORANAME="seo007"
   EXT_SOURCE="0199"
   EXT_ATLAS="N"

   # Set variable values
   LOGFULL="${LOGPATH}/${SCRIDEN}_${TIMSTMP}_${PRCIDEN}.log"
   LOGFILE=`basename ${LOGFULL}`
   prepareFile "${LOGFULL}"
   DTAFULL="${DTAPATH}/SALCAR01_${TIMSTMP}_${PRCIDEN}.TXT"
   DTAFILE=`basename ${DTAFULL}`
   DTAMESG="SALCAR01.TXT"
   prepareFile "${TMPPATH}/${DTAFILE}"
   SQLOUTP="${SQLPATH}/${SCRIDEN}_${TIMSTMP}_${PRCIDEN}.sqlout"
   prepareFile "${SQLOUTP}"
   SQLEXEC="${SQLPATH}/${SCRIDEN}_${TIMSTMP}_${PRCIDEN}.sqlexec"
   prepareFile "${SQLEXEC}"

   # Start the log
   writeLog "[INFO]:[setEnvironment] Start of script [${SCRNAME}]: `date` : process id [${PRCIDEN}]"

}

# ---------------------------------------------------------------------------
# validateFile - Validates a specified file
# ---------------------------------------------------------------------------

function validateFile {

   # Validate the file
   file=${1}
   if [[ ! -f ${file} ]] then
      abendExit "[ERROR]:[validateFile] File not found [${file}]"
   elif [[ ! -s ${file} ]] then
      abendExit "[ERROR]:[validateFile] File empty [${file}]"
   elif [[ ! -r ${file} ]] then
      abendExit "[ERROR]:[validateFile] User/group `id` cannot read from file [${file}]"
   fi

}

# ---------------------------------------------------------------------------
# prepareFile - Prepares a file for later use
# ---------------------------------------------------------------------------

function prepareFile {

   # Prepare the file
   file=${1}
   /usr/bin/touch ${file}
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      abendExit "[ERROR]:[prepareFile] File ${file} cannot be touched, return [${rc}]"
   fi
   /usr/bin/chmod 666 ${file}
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      abendExit "[ERROR]:[prepareFile] File ${file} cannot be chmod, return [${rc}]"
   fi

}

# ---------------------------------------------------------------------------
# checkDatabase - Checks the database availablity
# ---------------------------------------------------------------------------

function checkDatabase {

   # Check the database availablity
   typeset -l lower_db="${ORANAME}"
   writeLog "[INFO]:[checkDatabaset] Connecting to database : [${lower_db}]"
   . /usr/local/bin/oraconnect "${lower_db}"
   rc=${?}
   if [[ ${?} -ne 0 ]] then
      errorExit "[ERROR]:[checkDatabase] oraconnect to [${lower_db}] failed"
   fi

}

# ---------------------------------------------------------------------------
# execProcedure - Executes the oracle procedure and sends the data file
# ---------------------------------------------------------------------------

function execProcedure {

   # Write the log
   writeLog "[INFO]:[execProcedure] Executing procedure [sqlplus ${ORAUSER}@${ORANAME} @${SQLEXEC}]"

   # Create the sqlplus command file
   print "execute care_sales_extract_korea.extract_sales('${TMPPATH}','${DTAFILE}','${EXT_SOURCE}','${EXT_PERIOD}','${EXT_ATLAS}');" > ${SQLEXEC}
   print "exit;" >> ${SQLEXEC}

   # Execute oracle procedure
   sqlplus ${ORAUSER}@${ORANAME} @${SQLEXEC} > ${SQLOUTP} 2>&1
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      errorExit "[ERROR]:[execProcedure] SQLPlus Call Failed: See Oracle error file [${SQLOUTP}]"
   fi
   grep -q "^PL/SQL procedure successfully completed." < ${SQLOUTP}
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      errorExit "[ERROR]:[execProcedure] Stored procedure failed: See Oracle error file [${SQLOUTP}]"
   fi

   # Move data file to data directory from temporary directory
   writeLog "[INFO]:[execProcedure] Moving file - ${TMPPATH}/${DTAFILE} to ${DTAFULL}]"
   /usr/bin/mv ${TMPPATH}/${DTAFILE} ${DTAFULL}
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      errorExit "[ERROR]:[execProcedure] Error moving file - ${TMPPATH}/${DTAFILE} to ${DTAFULL}, return [${rc}]]"
   fi

   # Send data file
   if [[ -s ${DTAFULL} ]] then
      writeLog "[INFO]:[execProcedure] Executing command [. /usr/local/bin/ami_settier ${AMITIER}]"
      . /usr/local/bin/ami_settier ${AMITIER}
      writeLog "[INFO]:[execProcedure] Executing command [cat ${DTAFULL} | ${AMI_PERL} ${AMI_PATH}/bin/mq/mqif.pl -p -Q ${QUENAME} -r 0 -o ${DTAFULL}]"
      cat ${DTAFULL} | ${AMI_PERL} ${AMI_PATH}/bin/mq/mqif.pl -p -Q ${QUENAME} -r 0 -o ${DTAFULL}
      rc=${?}
      if [[ ${rc} -ne 0 ]] then
        errorExit "[ERROR]:[execProcedure] MQSeries command failed"
      else
        writeLog "[INFO]:[execProcedure] MQSeries command processed"
      fi
   else
      errorExit "[ERROR]:[execProcedure] Empty extract file - no data to send"
   fi

   # Write the log
   writeLog "[INFO]:[execProcedure] Completed successfully"

}

# ---------------------------------------------------------------------------
# finalise - Finalises the script
# ---------------------------------------------------------------------------

function finalise {

   # Archive datafile
   /usr/bin/mv ${DTAFULL} ${ARCPATH}/${DTAFILE}
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      abendExit "[ERROR]:[archiveFile] Error moving file - ${DTAFULL}, return [${rc}]]"
   else
      /usr/bin/compress -f ${ARCPATH}/${DTAFILE}
      if [[ ${?} -ne 0 ]] then
         abendExit "ERROR: [archiveFile] Compress of file - ${ARCPATH}/${DTAFILE}, Failed"
       fi
   fi

   # Remove the work files
   /usr/bin/rm -f ${SQLEXEC}
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      abendExit "[ERROR]:[cleanUp] Error removing file - ${SQLEXEC}, return [${rc}]]"
   fi
   /usr/bin/rm -f ${SQLOUTP}
   rc=${?}
   if [[ ${rc} -ne 0 ]] then
      abendExit "[ERROR]:[cleanUp] Error removing file - ${SQLOUTP}, return [${rc}]]"
   fi

}

# ---------------------------------------------------------------------------
# errorExit - Error and exits
# ---------------------------------------------------------------------------

function errorExit {

   # Log the error and exit
   errMsg="${1}"
   writeLog "${errMsg}"
   echo "${errMsg}"
   exit 1

}

# ---------------------------------------------------------------------------
# abendExit - Abort and exits
# ---------------------------------------------------------------------------

function abendExit {

   # Abend and exit
   errMsg="${1}"
   echo "${errMsg}"
   exit 1

}

# ---------------------------------------------------------------------------
# writeLog - Writes the log message
# ---------------------------------------------------------------------------

function writeLog {
   
   # Write the log message
   logMsg="${1}"
   print `date +"%Y-%m-%d %H:%M:%S"` ${logMsg} >> ${LOGFULL}

}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

   # Input parameters
   EXT_PERIOD=${1}

   # Check the parameters
   checkParameters

   # Set the global variables
   SCRNAME=${0##*/}
   SCRIDEN=${SCRNAME%.*}
   PRCIDEN=${$}
   USRIDEN=`whoami`
   TIMSTMP=`date +"%Y%m%d%H%M%S"`

   # Set the processing flag
   PRC_FLAG="Y"
   if [[ ${EXT_PERIOD} = "*LAST" ]] then
      PRC_FLAG="N"
      PPDD28=`marsdate -oD28`
      DAYNO=`echo ${PPDD28} | cut -c 7-`
      if [[ ${DAYNO} = 02 ]] then
         PRC_FLAG="Y"
      fi
   fi

   # Process when required
   if [[ ${PRC_FLAG} = "Y" ]] then
      setEnvironment
      checkDatabase
      execProcedure
      finalise
   fi

   # Exit success
   exit 0

# ---------------------------------------------------------------------------
#            M O D I F I C A T I O N   H I S T O R Y
# ---------------------------------------------------------------------------
#     Version     Date          Author          Modification
#     -------   -----------     -------------   -----------------------------
#       1.0     13-DEC-2006     S. Gregan       Original
# ---------------------------------------------------------------------------