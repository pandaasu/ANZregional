CREATE OR REPLACE PACKAGE         pds_utils AS

/*******************************************************************************
  NAME:      log
  PURPOSE:   This procedure logs text messages to the PDS_LOG table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).
  3.0   06/02/2009 Anna Every		Removed count(*) from Log
  4.0   03/03/2009 Anna Every           Added clean pds log procedure.
  5.0   10/06/2009 Steve Gregan         Modified to use package level sequence.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     PDS_LOG.JOB_TYPE_CODE                         1
                       The job type that is invoking the
                       log procedure. Populate using
                       job_type constant.
  2    IN     PDS_LOG.DATA_TYPE                             VENDOR
                       The data type being processed by
                       the job invoking the log procedure.
                       Populate using data_type constant.
  3    IN     PDS_LOG.SORT_FIELD                            10001
                       A sort field which contains a data
                       item relevant to the log line. For
                       example; Material code, Customer
                       Code, etc.
  4    IN     PDS_LOG.LOG_LEVEL                             1
                       A numeric logging level, starting at
                       zero and incrementing up. Can also be
                       considered to be an indenting factor.
  5    IN     PDS_LOG.LOG_TEXT                              Opening Cursor
                       The text message being logged.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE log (
  i_job_type_code IN pds_log.job_type_code%TYPE,
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE);

/*******************************************************************************
  NAME:      get_log_session_id
  PURPOSE:   Return the log session id.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   24/06/2004 Gerald Arnold        Created this function.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION get_log_session_id RETURN NUMBER;

/*******************************************************************************
  NAME:      print_log
  PURPOSE:   Prints the log to the specified log level.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     PDS_LOG.SESSION_ID
                       The session id that the log is       805415
                       recorded. Attained from
                       pds_utils.get_log_session_id.
  2    IN     PDS_LOG.LOG_LEVEL                             10
                       The maximum log level displayed.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE print_log (
  i_session_id IN pds_log.session_id%TYPE,
  i_max_log_level IN pds_log.log_level%TYPE DEFAULT 10);

/*******************************************************************************
  NAME:      unix_command_wrapper
  PURPOSE:   Calls java_utility.execute_external_function to execute the command.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this function.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 The unix command to execute.         ls -l
  2    IN     NUMBER   Log Level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION unix_command_wrapper(
  i_unix_command IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) RETURN VARCHAR2;

/*******************************************************************************
  NAME:      send_short_email
  PURPOSE:   Sends out an email using utl_smtp package with the message in
             i_message.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 The recipient address of the e-mail. i_recipient
  2    IN     VARCHAR2 The subject of the e-mail.           i_subject
  3    IN     VARCHAR2 The message of the email.            i_message
  4    IN     NUMBER   Log Level.                           i_log_level

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE send_short_email(
  i_recipient IN VARCHAR2,
  i_subject IN VARCHAR2,
  i_message IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      send_email_to_group
  PURPOSE:   Sends out an email using utl_smtp package with the message
             in i_message to an email group from the email_list table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     NUMBER   The job type from which to get the   1
                       list of email address to send this
                       message.
  2    IN     VARCHAR2 The subject of the e-mail.           MFANZ Promax Customer Process 01
  3    IN     VARCHAR2 The message of the email.            Message
  4    IN     VARCHAR2 The company that this email is       147
                       relevant.
  5    IN     VARCHAR2 The divisiom that this email is      1
                       relevant.
  6    IN     NUMBER   Log level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE send_email_to_group (
  i_email_group IN pds_email_list.job_type_code%TYPE,
  i_subject IN VARCHAR2,
  i_message IN VARCHAR2,
  i_cmpny_code IN pds_email_list.cmpny_code%TYPE DEFAULT NULL,
  i_div_code IN pds_email_list.div_code%TYPE DEFAULT NULL,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      start_long_email
  PURPOSE:   Start the creation of an email that allows you to keep appending
             lines.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 The recipient address of the e-mail.  MFANZ.PROMAX.SUPPORT
  2    IN     VARCHAR2 The subject of the e-mail.            MFANZ Promax Customer Process 01
  3    IN     NUMBER   log level.                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE start_long_email(
  i_recipient IN VARCHAR2,
  i_subject IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      append_to_long_email
  PURPOSE:   Allows you to keep appending lines to long email.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 The message of the email.            Message
  2    IN     NUMBER   Log level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES: An error will result if you have not first called start_long_email.
********************************************************************************/
PROCEDURE append_to_long_email (
  i_message IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      append_log_to_long_email
  PURPOSE:   Allows you to append the log to the specified log level to the long
             email.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     NUMBER   The sessions id that the log has     805415
                       been recorded. Attained from
                       utils.get_log_session_id.
  2    IN     NUMBER   The maximum log level displayed      10

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES: An error will result if you have not first called start_long_email.
********************************************************************************/
PROCEDURE append_log_to_long_email (
  i_session_id IN pds_log.session_id%TYPE,
  i_max_log_level IN pds_log.log_level%TYPE DEFAULT 10);

/*******************************************************************************
  NAME:      send_long_email
  PURPOSE:   Sends the long e-mail.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     NUMBER   Log level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES: An error will result if you have not first called start_long_email.
********************************************************************************/
PROCEDURE send_long_email (
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      send_tivoli_alert
  PURPOSE:   Sends an alert of varying priority to tivoli.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   21/06/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 The level of alert using alert_level critical
                       constant.
  2    IN     VARCHAR2 The message that you want to add     Message
                       to the alert message. Cannot be
                       longer than max_message_length
                       constant.
  3    IN     NUMBER   The job type for the alert using     1
                       the job_type constant.
  4    IN     VARCHAR2 Company Code.                        147
  5    IN     VARCHAR2 Division Code.                       1
  6    IN     NUMBER   Log level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES: This will truncate the i_message variable if it is greater that
         max_message_length.
********************************************************************************/
PROCEDURE send_tivoli_alert (
  i_alert_level IN VARCHAR2,
  i_message IN VARCHAR2,
  i_job_type_code IN pds_log.job_type_code%TYPE,
  i_cmpny_code IN pds_div.cmpny_code%TYPE DEFAULT NULL,
  i_div_code IN pds_div.div_code%TYPE DEFAULT NULL,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      put_file_on_queue
  PURPOSE:   Places a file from the file system onto a queue.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   22/07/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 The entire path and filename of the  /tmp/filename.txt
                       file to place on the Queue.
  2    IN     VARCHAR2 The Queue tier,                       PROD
  3    IN     VARCHAR2 The Queue name.                       MQ.TEST.QUEUE
  4    IN     NUMBER   Log level.                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE put_file_on_queue (
  i_source_filename IN VARCHAR2,
  i_source_system IN VARCHAR2,
  i_destination_filename IN VARCHAR2,
  i_destination_system IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*************************************************************************
  NAME:      clear_validation_reason
  PURPOSE:   Clear the pds_valdtn_reasn_hdr and pds_valdtn_reasn_dtl tables
             of information pertaining to a validation type and item codes.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   23/11/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).
  2.1   24/08/2006 Craig Ford           Reset package variables to prevent integrity
                                        constraint errors when creating validation
                                        reason records.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------
  1    IN     PDS_VALDTN_REASN_HDR.VALDTN_TYPE_CODE
                       Validation Type that you are wanting  1
                       to clear.
  2    IN     PDS_VALDTN_REASN_HDR.ITEM_CODE_1
                       The 1st part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  3    IN     PDS_VALDTN_REASN_HDR.ITEM_CODE_2
                       The 2nd part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  4    IN     PDS_VALDTN_REASN_HDR.ITEM_CODE_3
                       The 3rd part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  5    IN     PDS_VALDTN_REASN_HDR.ITEM_CODE_4
                       The 4th part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  6    IN     PDS_VALDTN_REASN_HDR.ITEM_CODE_5
                       The 5th part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  7    IN     PDS_VALDTN_REASN_HDR.ITEM_CODE_6
                       The 6th part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  8    IN     PDS_LOG.LOG_LEVEL
                       Level of logging                     5

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
*************************************************************************/
PROCEDURE clear_validation_reason (
  i_valdtn_type_code pds_valdtn_reasn_hdr.valdtn_type_code%TYPE,
  i_item_code_1 pds_valdtn_reasn_hdr.item_code_1%TYPE DEFAULT NULL,
  i_item_code_2 pds_valdtn_reasn_hdr.item_code_2%TYPE DEFAULT NULL,
  i_item_code_3 pds_valdtn_reasn_hdr.item_code_3%TYPE DEFAULT NULL,
  i_item_code_4 pds_valdtn_reasn_hdr.item_code_4%TYPE DEFAULT NULL,
  i_item_code_5 pds_valdtn_reasn_hdr.item_code_5%TYPE DEFAULT NULL,
  i_item_code_6 pds_valdtn_reasn_hdr.item_code_6%TYPE DEFAULT NULL,
  i_log_level pds_log.log_level%TYPE DEFAULT 0);

/*************************************************************************
  NAME:      add_validation_reason
  PURPOSE:   Clear the pds_valdtn_reasn_hdr and pds_valdtn_reasn_dtl tables
             of information pertaining to a validation type and item codes.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   23/11/2004 Gerald Arnold        Created this procedure.
  2.0   10/08/2005 Paul Berude          Modified for Promax Data Store (PDS).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------
  1    IN     VALDTN_REASN_HDR.VALDTN_TYPE_CODE
                       Validation Type that you are wanting  1
                       to clear.
  2    IN     VALDTN_REASN_HDR.VALDTN_REASN_DTL_MSG
                       The message to explain why this item  Missing Unit of Measure
                       is invalid.
  3    IN     VALDTN_REASN_HDR.VALDTN_REASN_DTL_SVRTY
                       The severity level associated with    CRITICAL
                       the message that explain why this
                       item is invalid.
  4    IN     VALDTN_REASN_HDR.ITEM_CODE_1
                       The 1st part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  5    IN     VALDTN_REASN_HDR.ITEM_CODE_2
                       The 2nd part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  6    IN     VALDTN_REASN_HDR.ITEM_CODE_3
                       The 3rd part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  7    IN     VALDTN_REASN_HDR.ITEM_CODE_4
                       The 4th part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  8    IN     VALDTN_REASN_HDR.ITEM_CODE_5
                       The 5th part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  9    IN     VALDTN_REASN_HDR.ITEM_CODE_6
                       The 6th part of the primary key of    1111
                       the item who's messages you are
                       wanting to clear.
  10   IN     PDS_LOG.LOG_LEVEL
                       Level to start logging at             5

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
*************************************************************************/
PROCEDURE add_validation_reason (
  i_valdtn_type_code pds_valdtn_reasn_hdr.valdtn_type_code%TYPE,
  i_message pds_valdtn_reasn_dtl.valdtn_reasn_dtl_msg%TYPE,
  i_severity pds_valdtn_reasn_dtl.valdtn_reasn_dtl_svrty%TYPE,
  i_item_code_1 pds_valdtn_reasn_hdr.item_code_1%TYPE DEFAULT NULL,
  i_item_code_2 pds_valdtn_reasn_hdr.item_code_2%TYPE DEFAULT NULL,
  i_item_code_3 pds_valdtn_reasn_hdr.item_code_3%TYPE DEFAULT NULL,
  i_item_code_4 pds_valdtn_reasn_hdr.item_code_4%TYPE DEFAULT NULL,
  i_item_code_5 pds_valdtn_reasn_hdr.item_code_5%TYPE DEFAULT NULL,
  i_item_code_6 pds_valdtn_reasn_hdr.item_code_6%TYPE DEFAULT NULL,
  i_log_level pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      create_promax_job_control
  PURPOSE:   This procedure creates a Promax Job Control record in the PDS_PMX_JOB_CNTL
             table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Promax Job Configuration ID.         3
  2    IN     NUMBER   log level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE create_promax_job_control (
  i_pmx_job_cnfgn_id IN pds_pmx_job_cnfgn.pmx_job_cnfgn_id%TYPE,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      set_users_read_only
  PURPOSE:   This procedure sets all promax users to read only mode.  This is achieved
             by backing up the PROMAX.USERS table to the PDS.PDS_PMX_USER table.
             All users in the PROMAX.USERS table are then set to read only mode.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   07/10/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     NUMBER   log level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE set_users_read_only (
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      unset_users_read_only
  PURPOSE:   This procedure resets all promax users from read only mode back to
             their original settings.  This is achieved by using the user acoount
             settings contained in the PDS.PDS_PMX_USER backup table. On completion,
             data is removed from the PDS.PDS_PMX_USER backup table, which is a
             requirement for the set_users_read_only procedure to run. This removes
             the possibility of user account setting being lost by the re-running of
             the set_users_read_only procedure.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   07/10/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     NUMBER   log level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE unset_users_read_only (
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      clean_pds_log
  PURPOSE:   This procedure removes the history from the pds_log table based
             on the number of days in the pds_job_type table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   06/01/2009 Anna Every          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     NUMBER   log level.                           1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE clean_pds_log (
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0);

/*******************************************************************************
  NAME:      create_log
  PURPOSE:   This procedure create a new log (session id).

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/06/2009 Steve Gregan         Created this procedure.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE create_log;

END pds_utils;
/


CREATE OR REPLACE PACKAGE BODY         pds_utils AS

  -- PACKAGE VARIABLE DECLARATIONS.
  pv_processing_msg constants.message_string;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_job_type_utils           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('utils','JOB_TYPE');
  pc_data_type_short_email    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('short_email','DATA_TYPE');
  pc_data_type_long_email     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('long_email','DATA_TYPE');
  pc_data_type_cmpny_date     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cmpny_date','DATA_TYPE');
  pc_data_type_alert          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('alert','DATA_TYPE');
  pc_data_type_unix_command   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('unix_command','DATA_TYPE');
  pc_data_type_not_applicable CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('not_applicable','DATA_TYPE');
  pc_job_status_submitted     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('submitted','JOB_STATUS');
  pc_system_host_name         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('host_name','SYSTEM');
  pc_system_timezone          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('timezone','SYSTEM');
  pc_email_server             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('server','EMAIL');
  pc_email_sender             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('sender','EMAIL');
  pc_alert_max_message_length CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('max_message_length','ALERT');
  pc_alert_level_fatal        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_fatal','ALERT');
  pc_alert_level_critical     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_critical','ALERT');
  pc_alert_level_minor        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_alert_level_warning      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_warning','ALERT');
  pc_alert_level_harmless     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_harmless','ALERT');
  pc_alert_level_unknown      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_unknown','ALERT');
  pc_alert_class              CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('class','ALERT');
  pc_alert_log_file           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('log_file','ALERT');
  pc_valdtn_severity_critical CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('critical','VALDTN_SEVERITY');
  pc_valdtn_severity_warning  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('warning','VALDTN_SEVERITY');
  pc_unix_run_commands        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('run_commands','UNIX');
  pc_unix_base_directory      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('base_directory','UNIX');

  -- PACKAGE VARIABLE DECLARATIONS
  -- Variable for the SMTP connection used by the long e-mail procedures.
  pv_connection utl_smtp.connection;
  pv_session    NUMBER;
  pv_sequence   NUMBER;

  -- Parameters for extracting to file.  Initialised at the bottom of the package body.
  pv_extract_file_num utl_file.file_type;

  -- Parameter for controlling generation of debugging information for this package.
  v_log_debug BOOLEAN;

  -- Variables used in the clear and add validation reason proceedures.
  pv_valdtn_type_code          pds_valdtn_type.valdtn_type_code%TYPE;
  pv_valdtn_reasn_hdr_code     pds_valdtn_reasn_hdr.valdtn_reasn_hdr_code%TYPE;
  pv_item_code_1               pds_valdtn_reasn_hdr.item_code_1%TYPE;
  pv_item_code_2               pds_valdtn_reasn_hdr.item_code_2%TYPE;
  pv_item_code_3               pds_valdtn_reasn_hdr.item_code_3%TYPE;
  pv_item_code_4               pds_valdtn_reasn_hdr.item_code_4%TYPE;
  pv_item_code_5               pds_valdtn_reasn_hdr.item_code_5%TYPE;
  pv_item_code_6               pds_valdtn_reasn_hdr.item_code_6%TYPE;
  pv_valdtn_reasn_dtl_seq      pds_valdtn_reasn_dtl.valdtn_reasn_dtl_seq%TYPE;

PROCEDURE log (
  i_job_type_code IN pds_log.job_type_code%TYPE,
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE
  ) IS

  -- Ensure that all commits are in the context of this procedure only.
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- VARIABLE DECLARATIONS
  v_job_type_code pds_log.job_type_code%TYPE;
  v_data_type     pds_log.data_type%TYPE;
  v_sort_field    pds_log.sort_field%TYPE;
  v_log_level     pds_log.log_level%TYPE;
  v_log_seq       pds_log.log_seq%TYPE;
  v_log_text      pds_log.log_text%TYPE;
  v_count         NUMBER;

  -- System information variables.
  v_lics_int_job_name VARCHAR2(40) := NULL;
  v_job_type          VARCHAR2(20) := NULL;
  v_interface_group   VARCHAR2(20) := NULL;
  v_jot_procedure     VARCHAR2(256) := NULL;
  v_jot_user          VARCHAR2(40) := NULL;
  v_os_user           VARCHAR2(256) := NULL;
  v_client_info       VARCHAR2(256) := NULL;
  v_db_name           VARCHAR2(256) := NULL;

  -- CURSOR DECLARATIONS
  CURSOR csr_os_user IS
    SELECT
      sys_context('userenv', 'os_user')
    FROM
      dual;

  CURSOR csr_client_info IS
    SELECT
      sys_context('USERENV', 'CLIENT_INFO')
    FROM
      dual;

BEGIN
  -- JOB TYPE: If NULL then default to UNASSIGNED.
  IF i_job_type_code IS NULL OR i_job_type_code = '' THEN
    v_job_type_code := 'UNASSIGNED';
  ELSE
    v_job_type_code := i_job_type_code;
  END IF;

  -- DATA TYPE: if NULL then default to UNASSIGNED.
  IF i_data_type IS NULL OR i_data_type = '' THEN
    v_data_type := 'UNASSIGNED';
  ELSE
    v_data_type := i_data_type;
  END IF;

  -- SORT FIELD: if NULL then default to UNASSIGNED.
  IF i_sort_field IS NULL OR i_sort_field = '' THEN
    v_sort_field := 'UNASSIGNED';
  ELSE
    v_sort_field := i_sort_field;
  END IF;

  -- LOG LEVEL: if NULL then default to UNASSIGNED.
  IF i_log_level IS NULL THEN
    v_log_level := 0;
  ELSE
    v_log_level := ABS(i_log_level);
  END IF;

  -- LOG TEXT: if NULL then default to UNASSIGNED.
  IF i_sort_field IS NULL OR i_sort_field = '' THEN
    SELECT
      'Blank log written at ' || to_char(sysdate,'YYYYMMDD HH24:MM:SS') ||
      ' by ' || SYS_CONTEXT ('USERENV', 'SESSION_USER') || '@' || UPPER(SYS_CONTEXT ('USERENV', 'DB_NAME')) ||
      '<<CLIENT INFO-' || NVL(SYS_CONTEXT ('USERENV', 'CLIENT_INFO'),'NULL') ||
      '>> <<OS USER-' || NVL(SYS_CONTEXT ('USERENV', 'OS_USER') ,'NULL')|| '>>' INTO v_log_text
    FROM
      DUAL;
  ELSE
    v_log_text := i_log_text;
  END IF;

  -- If no session reference has been generated for this invocation, then create.
  IF pv_session IS NULL OR pv_session = 0 THEN

    SELECT pds_log_seq.nextval INTO pv_session FROM dual;

    -- Set log sequence for this session.
    pv_sequence := 1;
    v_log_seq := pv_sequence;

    -- Now insert some basic information at the beginning of the log.
    INSERT INTO pds_log (
      session_id,
      log_seq,
      job_type_code,
      data_type,
      sort_field,
      log_level,
      log_text,
      log_lupdp,
      log_lupdt)
    VALUES (
      pv_session,
      v_log_seq,
      v_job_type_code,
      'SYSTEM INFORMATION',
      'N/A',
      0,
      'INFORMATION ABOUT CURRENT SESSION',
      user,
      sysdate);

    -- Get the latest (i.e. maximum) log sequence for this session.
    pv_sequence := pv_sequence + 1;
    v_log_seq := pv_sequence;

    -- Get the Database name.
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    INSERT INTO pds_log (
      session_id,
      log_seq,
      job_type_code,
      data_type,
      sort_field,
      log_level,
      log_text,
      log_lupdp,
      log_lupdt)
    VALUES(
      pv_session,
      v_log_seq,
      v_job_type_code,
      'SYSTEM INFORMATION',
      'DETAILS',
      2,
      'DATABASE NAME: ' || v_db_name,
      user,
      sysdate);

    -- Get the latest (i.e. maximum) log sequence for this session.
    pv_sequence := pv_sequence + 1;
    v_log_seq := pv_sequence;

    INSERT INTO pds_log (
      session_id,
      log_seq,
      job_type_code,
      data_type,
      sort_field,
      log_level,
      log_text,
      log_lupdp,
      log_lupdt)
    VALUES(
      pv_session,
      v_log_seq,
      v_job_type_code,
      'SYSTEM INFORMATION',
      'DETAILS',
      2,
      'HOSTNAME: ' || pc_system_host_name,
      user,
      sysdate);

    -- Now insert basic system information.
    lics_app.get_lics_job_info(v_lics_int_job_name,
                               v_job_type,
                               v_interface_group,
                               v_jot_procedure,
                               v_jot_user);

    -- Now check that it was a LICS job that started this session.
    IF ((v_lics_int_job_name IS NOT NULL)
      AND (v_job_type IS NOT NULL)
      AND (v_jot_procedure IS NOT NULL)
      AND (v_jot_user IS NOT NULL)) THEN

      IF (v_interface_group IS NULL) THEN
        v_interface_group := '<NONE>';
      END IF;

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      -- Write the LICS job information into the log.
      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'LICS_APP DETAILS',
        1,
        'ICS JOB INFORMATION',
        user,
        sysdate);

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'LICS_APP DETAILS',
        2,
        'ICS INTERFACE JOB NAME: ' || v_lics_int_job_name,
        user,
        sysdate);

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'LICS_APP DETAILS',
        2,
        'JOB TYPE: ' || v_job_type,
        user,
        sysdate);

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'LICS_APP DETAILS',
        2,
        'INTERFACE GROUP: ' || v_interface_group,
        user,
        sysdate);

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'LICS_APP DETAILS',
        2,
        'PROCEDURE CALLED: ' || v_jot_procedure,
        user,
        sysdate);

      OPEN csr_client_info;
      FETCH csr_client_info INTO v_client_info;
      CLOSE csr_client_info;

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'LICS_APP DETAILS',
        2,
        'CLIENT INFO: ' || v_client_info,
        user,
        sysdate);

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'LICS_APP DETAILS',
        2,
        'LICS JOB USER: ' || v_jot_user,
        user,
        sysdate);

    ELSE

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'JOB DETAILS',
        1,
        'Procedure started in user session and is not a LICS job.',
        user,
        sysdate);

      -- Get the latest (i.e. maximum) log sequence for this session.
      pv_sequence := pv_sequence + 1;
      v_log_seq := pv_sequence;

      OPEN csr_os_user;
      FETCH csr_os_user into v_os_user;
      CLOSE csr_os_user;
      INSERT INTO pds_log (
        session_id,
        log_seq,
        job_type_code,
        data_type,
        sort_field,
        log_level,
        log_text,
        log_lupdp,
        log_lupdt)
      VALUES(
        pv_session,
        v_log_seq,
        v_job_type_code,
        'SYSTEM INFORMATION',
        'DETAILS',
        2,
        'OS USERNAME: ' || v_os_user,
        user,
        sysdate);

    END IF;

  END IF;

  -- Get the latest (i.e. maximum) log sequence for this session.
  pv_sequence := pv_sequence + 1;
  v_log_seq := pv_sequence;

  -- Write the log text into the PDS_LOG table.
  INSERT INTO pds_log (
    session_id,
    log_seq,
    job_type_code,
    data_type,
    sort_field,
    log_level,
    log_text,
    log_lupdp,
    log_lupdt)
  VALUES(
    pv_session,
    v_log_seq,
    v_job_type_code,
    v_data_type,
    v_sort_field,
    v_log_level,
    v_log_text,
    user,
    sysdate);

  -- Commit the record.
  COMMIT;

EXCEPTION
  -- Rollback and pass on the error.
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;


FUNCTION get_log_session_id RETURN NUMBER IS
BEGIN
  IF (pv_session IS NOT NULL) THEN
    RETURN pv_session;
  ELSE
    RAISE_APPLICATION_ERROR(-20000, 'No Session ID set.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'LOG ERROR - ' || SUBSTR(SQLERRM, 1, 512));
END;


PROCEDURE print_log(
  i_session_id IN pds_log.session_id%TYPE,
  i_max_log_level IN pds_log.log_level%TYPE DEFAULT 10
  ) IS

  -- VARIABLE DECLARATIONS
  v_spaces        VARCHAR2(2000);
  v_message       VARCHAR2(4000);
  v_max_log_level pds_log.log_level%TYPE;

  -- CURSOR DECLARATIONS
  CURSOR csr_get_log IS
    SELECT
      t2.job_type_desc,
      t1.data_type,
      t1.sort_field,
      t1.log_level,
      t1.log_text,
      t1.log_lupdt
    FROM
      pds_log t1,
      pds_job_type t2
    WHERE
      t1.job_type_code = t2.job_type_code
      AND t1.session_id = i_session_id
      AND t1.log_level <= v_max_log_level
    ORDER BY
      log_seq;
  rv_get_log csr_get_log%ROWTYPE;

BEGIN
  -- Set a large buffer size.
  dbms_output.enable(50000000);

  IF (i_max_log_level < 0) THEN
    v_max_log_level := 0;
  ELSE
    v_max_log_level := i_max_log_level;
  END IF;

  -- Open csr_get_log cursor.
  OPEN csr_get_log;
  LOOP
    FETCH csr_get_log INTO rv_get_log;
    EXIT WHEN csr_get_log%NOTFOUND;

    v_spaces := '';

    FOR i IN 0 ..rv_get_log.log_level LOOP
      v_spaces := v_spaces || ' ';
    END LOOP;

    v_message := TO_CHAR(rv_get_log.log_lupdt, 'DD-MON-YYYY HH24:MI:SS') ||
                 ': '  || v_spaces ||
                 rv_get_log.job_type_desc || '|'   ||
                 rv_get_log.data_type  || '|'   ||
                 rv_get_log.sort_field || ' - ' ||
                 rv_get_log.log_text;
    IF (LENGTH(v_message) > 255) THEN
      FOR i in 0 ..((LENGTH(v_message)/255) - 1) LOOP
        dbms_output.put_line(SUBSTR(v_message, (1 + (255 * i)), (255 + (255 * i))));
      END LOOP;
    ELSE
      dbms_output.put_line(v_message);
    END IF;
  END LOOP;
END print_log;


FUNCTION unix_command_wrapper(
  i_unix_command IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) RETURN VARCHAR2 IS

  -- VARIABLE DECLARATIONS
  v_temp      VARCHAR2(4000);
  v_log_level pds_log.log_level%TYPE := 0;

BEGIN
  v_log_level := i_log_level;
  v_temp := '';

  pds_utils.log(pc_job_type_utils,
                pc_data_type_unix_command,
                pc_data_type_unix_command,
                v_log_level,
                'Starting the unix command wrapper and checking ' ||
                'that there is a command to execute.');

  -- Make sure that there is a command to execute
  IF (i_unix_command IS NULL OR LENGTH(i_unix_command) = 0) THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_unix_command,
                  pc_data_type_unix_command,
                  v_log_level,
                  'No command to execute, exiting.');
    RETURN v_temp;
  END IF;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_unix_command,
                pc_data_type_unix_command,
                v_log_level,
                'Execute command and returning results from shell.');
  BEGIN
  IF pc_unix_run_commands = 'TRUE' THEN
      v_temp := iu_app.java_utility.execute_external_function('"' || pc_unix_base_directory || '/bin/sh.sh" "-c" "' || i_unix_command || '"');
    ELSE
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_unix_command,
                  pc_data_type_unix_command,
                  v_log_level,
                  'Not actually executing unix command due to constants parameter.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pds_utils.log(pc_job_type_utils,
                    pc_data_type_unix_command,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR UNIX_COMMAND_WRAPPER.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      RAISE_APPLICATION_ERROR(-20000, 'Unix Command Failed.');
  END;

  RETURN v_temp;

EXCEPTION
  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_unix_command,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR UNIX_COMMAND_WRAPPER.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
    RETURN constants.error_str;
END unix_command_wrapper;


PROCEDURE send_short_email(
  i_recipient IN VARCHAR2,
  i_subject IN VARCHAR2,
  i_message IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  pv_connection utl_smtp.connection;
  v_mail_server VARCHAR2(20) := pc_email_server;
  v_sender      VARCHAR2(150) := pc_email_sender;
  v_message     VARCHAR2(4000);
  v_db_name     VARCHAR2(256) := NULL;
  v_log_level   pds_log.log_level%TYPE := 0;

BEGIN
  v_log_level := i_log_level;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_short_email,
                pc_data_type_short_email,
                v_log_level,
               'Starting short e-mail and setting up all the basic information.');

  -- Get the Database name.
  SELECT
    UPPER(sys_context('USERENV', 'DB_NAME'))
  INTO
    v_db_name
  FROM
    dual;

  -- Setting the sender address.
  v_sender := 'MFANZ@' || v_db_name || v_sender;

  -- Setup the connection to the mail server.
  pv_connection := utl_smtp.open_connection(v_mail_server, 25);

  -- Initialize connection.
  utl_smtp.helo(pv_connection, v_mail_server);
  utl_smtp.mail(pv_connection, v_sender);

  -- Make sure that the recipient address is not to long.
  IF (LENGTH(i_recipient) > 255) THEN
    RAISE_APPLICATION_ERROR(-20000, 'Length of recipient address to long.');
  END IF;
  pds_utils.log(pc_job_type_utils,
                pc_data_type_short_email,
                pc_data_type_short_email,
                v_log_level + 1,
                'Setting the e-mail message recipient address.');
  utl_smtp.rcpt(pv_connection, i_recipient);

  -- Make sure that the subject is not to long.
  IF (LENGTH(i_subject) > 400) THEN
    RAISE_APPLICATION_ERROR(-20000, 'Length of subject to long.');
  END IF;
  pds_utils.log(pc_job_type_utils,
                pc_data_type_short_email,
                pc_data_type_short_email,
                v_log_level + 1,
                'Building the email message.');

  -- Build the message to include all the important information.
  v_message := 'From: '     || v_sender    ||
               utl_tcp.crlf || 'Subject: '  || i_subject   ||
               utl_tcp.crlf || 'To: '       || i_recipient ||
               utl_tcp.crlf || utl_tcp.crlf;

  -- Open the data connection.
  utl_smtp.open_data(pv_connection);

  -- Send the basic information to the server.
  utl_smtp.write_data(pv_connection, v_message);

  pds_utils.log(pc_job_type_utils,
               pc_data_type_short_email,
               pc_data_type_short_email,
               v_log_level + 1,
               'Sending out the e-mail.');

  -- Add the message to the email and send.
  utl_smtp.write_data(pv_connection, i_message);

  -- Add the session id to the email tail.
  utl_smtp.write_data(pv_connection, utl_tcp.crlf || utl_tcp.crlf ||
                                    'Session ID: ' || pds_utils.get_log_session_id);

  -- Now send the email.
  utl_smtp.close_data(pv_connection);

  utl_smtp.quit(pv_connection);
  pds_utils.log(pc_job_type_utils,
                pc_data_type_short_email,
                pc_data_type_short_email,
                v_log_level,
                'Finished short e-mail.');
EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(pv_connection);
    EXCEPTION WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      NULL;
      -- When the SMTP server is down or unavailable, we don't have
      -- a connection to the server. The quit call will raise an
      -- exception that we can ignore.
    END;
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_short_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
    RAISE_APPLICATION_ERROR(-20000,
                            'Failed to send mail due to the following error: ' ||
                            SQLERRM);

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_short_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR SEND_SHORT_EMAIL.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END send_short_email;


PROCEDURE send_email_to_group(
  i_email_group IN pds_email_list.job_type_code%TYPE,
  i_subject IN VARCHAR2,
  i_message IN VARCHAR2,
  i_cmpny_code IN pds_email_list.cmpny_code%TYPE DEFAULT NULL,
  i_div_code IN pds_email_list.div_code%TYPE DEFAULT NULL,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  v_mail_server VARCHAR2(20) := pc_email_server;
  v_sender      VARCHAR2(150) := pc_email_sender;
  v_message     VARCHAR2(4000);
  v_temp        PLS_INTEGER;
  v_recipient   pds_email_list.email_address%TYPE;
  v_reply       utl_smtp.reply;
  v_log_level   pds_log.log_level%TYPE := 0;

  -- CURSOR DECLARATIONS
 CURSOR csr_company IS
   SELECT
     COUNT(*)
   FROM
     pds_div
   WHERE
     cmpny_code = i_cmpny_code
     AND div_code = i_div_code;

 CURSOR csr_addresses IS
   SELECT DISTINCT
     email_address
   FROM
     pds_email_list
   WHERE
     job_type_code = i_email_group;

 CURSOR csr_company_addresses IS
   SELECT DISTINCT
     email_address
   FROM
     pds_email_list
   WHERE
     job_type_code = i_email_group
     AND cmpny_code = i_cmpny_code
     AND div_code = i_div_code;

BEGIN
  v_log_level := i_log_level;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_short_email,
                'E-MAIL TO GROUP',
                v_log_level,
                'Starting Send Email to Group.');

  pds_utils.log(pc_job_type_utils,
                pc_data_type_short_email,
                'E-MAIL TO GROUP',
                v_log_level,
                'Getting all of the email addresses for the group.');

  OPEN csr_company;
  FETCH csr_company INTO v_temp;
  CLOSE csr_company;
  IF (v_temp = 0) THEN
    OPEN csr_addresses;
    LOOP
      FETCH csr_addresses INTO v_recipient;
      EXIT WHEN csr_addresses%NOTFOUND;
      pds_utils.log(pc_job_type_utils,
                    pc_data_type_short_email,
                    'E-MAIL TO GROUP',
                    v_log_level + 1,
                    'Calling Send Short e-mail for this address.');
      send_short_email(v_recipient,
                       i_subject,
                       i_message,
                       v_log_level + 2);
    END LOOP;
    CLOSE csr_addresses;

  ELSE
    OPEN csr_company_addresses;
    LOOP
      FETCH csr_company_addresses INTO v_recipient;
      EXIT WHEN csr_company_addresses%NOTFOUND;

      pds_utils.log(pc_job_type_utils,
                    pc_data_type_short_email,
                    'E-MAIL TO GROUP',
                    v_log_level + 1,
                    'Calling Send Short e-mail for this address.');
      send_short_email(v_recipient,
                       i_subject,
                       i_message,
                       v_log_level + 2);
    END LOOP;
    CLOSE csr_company_addresses;
  END IF;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_short_email,
                'E-MAIL TO GROUP',
                v_log_level,
                'Finished e-mail to group.');
EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(pv_connection);
    EXCEPTION WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      NULL;
      -- When the SMTP server is down or unavailable, we don't have
      -- a connection to the server. The quit call will raise an
      -- exception that we can ignore.
    END;
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_short_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');

    IF (csr_addresses%ISOPEN) THEN
      CLOSE csr_addresses;
    END IF;

    IF (csr_company_addresses%ISOPEN) THEN
      CLOSE csr_company_addresses;
    END IF;

    RAISE_APPLICATION_ERROR(-20000,
                            'Failed to send mail due to the following error: ' ||
                            SQLERRM);

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_short_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR SEND_EMAIL_TO_GROUP.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

    IF (csr_addresses%ISOPEN) THEN
      CLOSE csr_addresses;
    END IF;

    IF (csr_company_addresses%ISOPEN) THEN
      CLOSE csr_company_addresses;
    END IF;
END send_email_to_group;


PROCEDURE start_long_email(
  i_recipient IN VARCHAR2,
  i_subject IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  v_mail_server VARCHAR2(20)  := pc_email_server;
  v_sender      VARCHAR2(150) := pc_email_sender;
  v_message     VARCHAR2(4000);
  v_db_name     VARCHAR2(256) := NULL;
  v_log_level   pds_log.log_level%TYPE := 0;

BEGIN
  v_log_level := i_log_level;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_long_email,
                pc_data_type_long_email,
                v_log_level,
                'Starting Start Long Email and setting up basic information.');

  -- Setup the connection to the Mail Server.
  pv_connection := utl_smtp.open_connection(v_mail_server, 25);

  -- Initialize connection.
  utl_smtp.helo(pv_connection, v_mail_server);

  -- Get the Database name.
  SELECT
    UPPER(sys_context('USERENV', 'DB_NAME'))
  INTO
    v_db_name
  FROM
    dual;

  -- Setting the sender address.
  v_sender := 'MFANZ@' || v_db_name || v_sender;

  utl_smtp.mail(pv_connection, v_sender);
  utl_smtp.rcpt(pv_connection, i_recipient);

  pds_utils.log(pc_job_type_utils,
                pc_data_type_long_email,
                pc_data_type_long_email,
                v_log_level + 1,
                'Setting all the Date, From, To and Subject information.');

  -- Build the message to include all the important information.
  v_message := 'From: '     || v_sender    ||
               utl_tcp.crlf || 'Subject: ' || i_subject   ||
               utl_tcp.crlf || 'To: '      || i_recipient ||
               utl_tcp.crlf || utl_tcp.crlf;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_long_email,
                pc_data_type_long_email,
                v_log_level + 1,
               'Opening and writting to the smtp data connection.');

  -- Open the data connection.
  utl_smtp.open_data(pv_connection);


  -- Send the basic data to the server.
  utl_smtp.write_data(pv_connection, v_message);
  pds_utils.log(pc_job_type_utils,
                pc_data_type_long_email,
                pc_data_type_long_email,
                v_log_level,
                'Finished Start Long Email.');

EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(pv_connection);
    EXCEPTION
      WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        NULL;
        -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The quit call will raise an
        -- exception that we can ignore.
    END;
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_long_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
    RAISE_APPLICATION_ERROR(-20000,
                            'Failed to send mail due to the following error: ' ||
                            SQLERRM);

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_long_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR START_LONG_EMAIL.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END start_long_email;


PROCEDURE append_to_long_email(
  i_message IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  v_reply     utl_smtp.reply;
  v_log_level pds_log.log_level%TYPE := 0;

BEGIN
  v_log_level := i_log_level;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_long_email,
                pc_data_type_long_email,
                v_log_level,
                'Appending a message line to a long e-mail.');

  -- Send the basic data to the server.
  utl_smtp.write_data(pv_connection, utl_tcp.crlf || i_message);

EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(pv_connection);
    EXCEPTION
      WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        NULL;
        -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The quit call will raise an
        -- exception that we can ignore.
    END;
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_long_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
    RAISE_APPLICATION_ERROR(-20000,
                            'Failed to send mail due to the following error: ' ||
                            SQLERRM);

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_long_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR APPEND_TO_LONG_EMAIL.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END append_to_long_email;


PROCEDURE append_log_to_long_email(
  i_session_id IN pds_log.session_id%TYPE,
  i_max_log_level IN pds_log.log_level%TYPE DEFAULT 10
  ) IS

  -- VARIABLE DECLARATIONS
  v_spaces        VARCHAR2(2000);
  v_max_log_level pds_log.log_level%TYPE;

  -- CURSOR DECLARATIONS
  CURSOR csr_get_log IS
    SELECT
      t2.job_type_desc,
      t1.data_type,
      t1.sort_field,
      t1.log_level,
      t1.log_text,
      t1.log_lupdt
    FROM
      pds_log t1,
      pds_job_type t2
    WHERE
      t1.job_type_code = t2.job_type_code
      AND t1.session_id = i_session_id
      AND t1.log_level <= v_max_log_level
    ORDER BY
      t1.log_seq;
  rv_get_log csr_get_log%ROWTYPE;

BEGIN
  IF (i_max_log_level < 0) THEN
    v_max_log_level := 0;
  ELSE
    v_max_log_level := i_max_log_level;
  END IF;

  -- Open csr_get_log cursor.
  OPEN csr_get_log;
  LOOP
    FETCH csr_get_log INTO rv_get_log;
    EXIT WHEN csr_get_log%NOTFOUND;

    v_spaces := '';

    FOR i IN 0 ..rv_get_log.log_level LOOP
      v_spaces := v_spaces || ' ';
    END LOOP;

    append_to_long_email(TO_CHAR(rv_get_log.log_lupdt, 'DD-MON-YYYY HH24:MI:SS') ||
                         ': '  || v_spaces ||
                         rv_get_log.job_type_desc || '|'   ||
                         rv_get_log.data_type  || '|'   ||
                         rv_get_log.sort_field || ' - ' ||
                         rv_get_log.log_text);

  END LOOP;

EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(pv_connection);
    EXCEPTION
      WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        NULL;
        -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The quit call will raise an
        -- exception that we can ignore.
    END;
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_long_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
    RAISE_APPLICATION_ERROR(-20000,
                            'Failed to send mail due to the following error: ' ||
                            SQLERRM);

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_long_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR APPEND_LOG_TO_LONG_EMAIL.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END append_log_to_long_email;


PROCEDURE send_long_email(
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  v_reply     utl_smtp.reply;
  v_log_level pds_log.log_level%TYPE := 0;

BEGIN
  v_log_level := i_log_level;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_long_email,
                pc_data_type_long_email,
                v_log_level,
                'Finishing sending a long email.');

  -- Add the session id to the email tail.
  utl_smtp.write_data(pv_connection, utl_tcp.crlf || utl_tcp.crlf ||
                                    'Session ID: ' || pds_utils.get_log_session_id);

  -- Now send the email.
  utl_smtp.close_data(pv_connection);

  utl_smtp.quit(pv_connection);

EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(pv_connection);
    EXCEPTION
      WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        NULL;
        -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The quit call will raise an
        -- exception that we can ignore.
    END;
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_long_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
    RAISE_APPLICATION_ERROR(-20000,
                            'Failed to send mail due to the following error: ' ||
                            SQLERRM);

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_long_email,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR SEND_LOG_EMAIL.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END send_long_email;


PROCEDURE send_tivoli_alert(
  i_alert_level IN VARCHAR2,
  i_message IN VARCHAR2,
  i_job_type_code IN pds_log.job_type_code%TYPE,
  i_cmpny_code IN pds_div.cmpny_code%TYPE DEFAULT NULL,
  i_div_code IN pds_div.div_code%TYPE DEFAULT NULL,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  v_log_level    pds_log.log_level%TYPE := 0;
  v_reply        VARCHAR2(4000);
  v_message      VARCHAR2(4000);
  v_company_time DATE;
  v_temp_number  PLS_INTEGER;
  v_temp_char    VARCHAR2(1);
  v_db_name      VARCHAR2(256) := NULL;

/*
  Note: The below source code has been commented out of the procedure.  This code
        can be used to specific what days are to be sent.  There is no requirement
        to-date for this logic, however the source code has not been deleted as
        there may be a future requirement.

  -- VARIABLE DECLARATIONS
  v_send_alert_today  BOOLEAN;
  v_mars_period_day   PLS_INTEGER;

  -- CURSOR DECLARATIONS
  CURSOR csr_send_tivoli_alert1 IS
    SELECT
      DECODE(v_mars_period_day, 1, period_day_01,
                                2, period_day_02,
                                3, period_day_03,
                                4, period_day_04,
                                5, period_day_05,
                                6, period_day_06,
                                7, period_day_07,
                                8, period_day_08,
                                9, period_day_09,
                               10, period_day_10,
                               11, period_day_11,
                               12, period_day_12,
                               13, period_day_13,
                               14, period_day_14,
                               15, period_day_15,
                               16, period_day_16,
                               17, period_day_17,
                               18, period_day_18,
                               19, period_day_19,
                               20, period_day_20,
                               21, period_day_21,
                               22, period_day_22,
                               23, period_day_23,
                               24, period_day_24,
                               25, period_day_25,
                               26, period_day_26,
                               27, period_day_27,
                               28, period_day_28,
                               period_day_28) AS answer
    FROM
      tivoli_alert_schedule
    WHERE
      job_type_code = i_job_type_code
      AND cmpny_code = i_cmpny_code
      AND div_code = i_div_code
    ORDER BY
      ANSWER DESC;

  CURSOR csr_send_tivoli_alert2 IS
    SELECT
      DECODE(v_mars_period_day, 1, period_day_01,
                                2, period_day_02,
                                3, period_day_03,
                                4, period_day_04,
                                5, period_day_05,
                                6, period_day_06,
                                7, period_day_07,
                                8, period_day_08,
                                9, period_day_09,
                               10, period_day_10,
                               11, period_day_11,
                               12, period_day_12,
                               13, period_day_13,
                               14, period_day_14,
                               15, period_day_15,
                               16, period_day_16,
                               17, period_day_17,
                               18, period_day_18,
                               19, period_day_19,
                               20, period_day_20,
                               21, period_day_21,
                               22, period_day_22,
                               23, period_day_23,
                               24, period_day_24,
                               25, period_day_25,
                               26, period_day_26,
                               27, period_day_27,
                               28, period_day_28,
                               period_day_28) AS answer
    FROM
      tivoli_alert_schedule
    WHERE
      job_type_code = i_job_type_code
    ORDER BY
      ANSWER DESC;
*/

BEGIN
  v_log_level := i_log_level;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_alert,
                pc_data_type_alert,
                v_log_level,
                'Starting Send Tivoli Alert and and checking message ' ||
                'lengths and alert levels.');

  IF (i_message IS NULL OR LENGTH(i_message) = 0) THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_alert,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - Invalid Tivoli Alert Message.');
    RAISE_APPLICATION_ERROR(-20000, 'Invalid Tivoli Alert Message.');
  END IF;

  -- Get the Database name.
  SELECT
    UPPER(sys_context('USERENV', 'DB_NAME'))
  INTO
    v_db_name
  FROM
    dual;

  -- Pre-append all basic information.
  v_message := 'HOSTNAME: ' || pc_system_host_name ||
               ' DATABASE NAME: ' || v_db_name ||
               '. ' ||
               i_message;

  -- Make sure that the message is not to long.
  v_message := substr(v_message, 1, pc_alert_max_message_length);

  IF (i_alert_level   != pc_alert_level_fatal
    AND i_alert_level != pc_alert_level_critical
    AND i_alert_level != pc_alert_level_minor
    AND i_alert_level != pc_alert_level_warning
    AND i_alert_level != pc_alert_level_harmless
    AND i_alert_level != pc_alert_level_unknown) THEN
      pds_utils.log(pc_job_type_utils,
                    pc_data_type_alert,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Invalid Tivoli alert level.');
      RAISE_APPLICATION_ERROR(-20000, 'Invalid Tivoli Alert Level.');
  END IF;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_alert,
                pc_data_type_alert,
                v_log_level + 1,
                'Checking for a valid Company and Division Code.');
  SELECT
    COUNT(*)
  INTO
    v_temp_number
  FROM
    pds_div
  WHERE
    cmpny_code = i_cmpny_code
    AND div_code = i_div_code;

  -- So if this is a valid company and division code, do the rest of the checks.
  IF (v_temp_number > 0) THEN
/*
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_alert,
                  pc_data_type_alert,
                  v_log_level + 1,
                  'Getting mars period day number.');
    SELECT
      period_day_num
    INTO
      v_mars_period_day
    FROM
      mars_date
    WHERE
      TRUNC(calendar_date) = TRUNC(sysdate);


    pds_utils.log(pc_job_type_utils,
                  pc_data_type_alert,
                  pc_data_type_alert,
                  v_log_level + 1,
                  'Check to see if a Tivoli alert should be sent out.');

    OPEN csr_send_tivoli_alert1;
    FETCH csr_send_tivoli_alert1 INTO v_temp_char;
    IF (csr_send_tivoli_alert1%NOTFOUND) THEN
      v_send_alert_today := FALSE;

    ELSE
      IF (v_temp_char = 'N') THEN
        v_send_alert_today := FALSE;
      ELSE
        v_send_alert_today := TRUE;
      END IF;
    END IF;
    CLOSE csr_send_tivoli_alert1;

    -- If we found a Y in the period day then do this
    IF (v_send_alert_today) THEN
*/
      pds_utils.log(pc_job_type_utils,
                    pc_data_type_alert,
                    pc_data_type_alert,
                    v_log_level + 1,
                    'Sending the alert to the Unix Command Wrapper.');
      v_reply := unix_command_wrapper('/usr/local/bin/isi_wpostemsg -r ' ||
                                      i_alert_level ||
                                      ' -m ""' || v_message ||
                                      '"" application=""MFANZ PROMAX""' ||
                                      ' interface=""PMX"" hostname='  ||
                                      pc_system_host_name ||
                                      ' ' || pc_alert_class ||
                                      ' ' || pc_alert_log_file ||
                                      ' 1> /dev/null 2> /dev/null');

      IF (v_reply = constants.error_str) THEN
        pds_utils.log(pc_job_type_utils,
                      pc_data_type_alert,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - Send Tivoli Alert FAILED.');
          RAISE_APPLICATION_ERROR(-20000, 'Send Tivoli Alert FAILED.');
      END IF;
/*
    ELSE
      pds_utils.log(pc_job_type_utils,
                    pc_data_type_alert,
                    pc_data_type_alert,
                    v_log_level + 1,
                    'No need to send alert today for this company, division and job type.');
    END IF;
*/
  ELSE
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_alert,
                  pc_data_type_alert,
                  v_log_level + 1,
                  'Invalid Company Code or Division Code.');

  END IF;

  pds_utils.log(pc_job_type_utils,
                pc_data_type_alert,
                pc_data_type_alert,
                v_log_level,
                'Finished Send Tivoli Alert.');

EXCEPTION
  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_alert,
                  'ERROR',
                  0,
                  '!!!ERROR111!!! - FATAL ERROR FOR SEND_TIVOLI_ALERT.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
    RAISE_APPLICATION_ERROR(-20000, 'Failed to send Tivoli Alert.');
END send_tivoli_alert;


PROCEDURE put_file_on_queue(
  i_source_filename IN VARCHAR2,
  i_source_system IN VARCHAR2,
  i_destination_filename IN VARCHAR2,
  i_destination_system IN VARCHAR2,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  v_log_level pds_log.log_level%TYPE;
  v_temp      VARCHAR2(4000);

BEGIN
  v_log_level := i_log_level;

  pds_utils.log(pc_job_type_utils,
                'N/A',
                'N/A',
                v_log_level,
                'Starting Put File On Queue.');
  v_Log_level := v_log_level + 1;

  pds_utils.log(pc_job_type_utils,
                'N/A',
                'N/A',
                v_log_level,
                'Checking that Complete Filename and Path is valid.');

  IF (LENGTH(i_source_filename) = 0 OR i_source_filename IS NULL) THEN
    pds_utils.log(pc_job_type_utils,
                  'N/A',
                  'ERROR',
                  0,
                  '!!!ERROR!!! - INVALID SOURCE FILENAME AND/OR PATH.');
    RAISE_APPLICATION_ERROR(-20000, 'Invalid Source Filename.');
  END IF;
  IF (LENGTH(i_destination_filename) = 0 OR i_destination_filename IS NULL) THEN
    pds_utils.log(pc_job_type_utils,
                  'N/A',
                  'ERROR',
                  0,
                  '!!!ERROR!!! - INVALID DESTINATION FILENAME AND/OR PATH.');
    RAISE_APPLICATION_ERROR(-20000, 'Invalid Destination Filename.');
  END IF;

  pds_utils.log(pc_job_type_utils,
                'N/A',
                'N/A',
                v_log_level,
                'Loading file onto queue: /opt/mqft/prod/bin/mqftssnd ' ||
                                       '-source ' || i_source_system ||
                                       ',' || i_source_filename ||
                                       ' -target ' || i_destination_system ||
                                       ',' || i_destination_filename);

  v_temp := pds_utils.unix_command_wrapper('/opt/mqft/prod/bin/mqftssnd ' ||
                                       '-source ' || i_source_system ||
                                       ',' || i_source_filename ||
                                       ' -target ' || i_destination_system ||
                                       ',' || i_destination_filename,
                                       v_log_level + 1);
  IF (v_temp = constants.error_str) THEN
    RAISE_APPLICATION_ERROR(-20000, 'mqftssnd command failed.');
  ELSE
    pds_utils.log(pc_job_type_utils,
                'N/A',
                'N/A',
                v_log_level,
                'Return Text: ' || v_temp);
  END IF;

  v_log_level := v_log_level - 1;
  pds_utils.log(pc_job_type_utils,
                'N/A',
                'N/A',
                v_log_level,
                'Finished Put File On Queue.');

EXCEPTION
  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  'N/A',
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL PUT_FILE_ON_QUEUE.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
     RAISE_APPLICATION_ERROR(-20000, 'mqftssnd command failed.');
END put_file_on_queue;


PROCEDURE clear_validation_reason (
  i_valdtn_type_code pds_valdtn_reasn_hdr.valdtn_type_code%TYPE,
  i_item_code_1 pds_valdtn_reasn_hdr.item_code_1%TYPE DEFAULT NULL,
  i_item_code_2 pds_valdtn_reasn_hdr.item_code_2%TYPE DEFAULT NULL,
  i_item_code_3 pds_valdtn_reasn_hdr.item_code_3%TYPE DEFAULT NULL,
  i_item_code_4 pds_valdtn_reasn_hdr.item_code_4%TYPE DEFAULT NULL,
  i_item_code_5 pds_valdtn_reasn_hdr.item_code_5%TYPE DEFAULT NULL,
  i_item_code_6 pds_valdtn_reasn_hdr.item_code_6%TYPE DEFAULT NULL,
  i_log_level pds_log.log_level%TYPE DEFAULT 0) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- VARIABLE DECLARATIONS
  v_temp_number PLS_INTEGER := NULL;
  v_log_level   pds_log.log_level%TYPE := 0;

  -- CURSOR DECLARATIONS
  CURSOR csr_valdtn_reasn_hdr_code IS
    SELECT
      valdtn_reasn_hdr_code
    FROM
      pds_valdtn_reasn_hdr
    WHERE
      valdtn_type_code = i_valdtn_type_code
      AND DECODE(item_code_1, NVL(i_item_code_1, item_code_1), 1, 0) = 1
      AND DECODE(item_code_2, NVL(i_item_code_2, item_code_2), 1, 0) = 1
      AND DECODE(item_code_3, NVL(i_item_code_3, item_code_3), 1, 0) = 1
      AND DECODE(item_code_4, NVL(i_item_code_4, item_code_4), 1, 0) = 1
      AND DECODE(item_code_5, NVL(i_item_code_5, item_code_5), 1, 0) = 1
      AND DECODE(item_code_6, NVL(i_item_code_6, item_code_6), 1, 0) = 1;
  rv_valdtn_reasn_hdr_code csr_valdtn_reasn_hdr_code%ROWTYPE;

BEGIN
  -- Initialising variables
  v_temp_number             := NULL;

  -- Reset public variables to ensure a Valdtn Reasn HDR record is created when the
  -- same interface is re-run. This prevents valdtn reasn integrity constraint errors.
  pv_valdtn_type_code       := NULL;
  pv_valdtn_reasn_hdr_code  := NULL;
  pv_item_code_1            := NULL;
  pv_item_code_2            := NULL;
  pv_item_code_3            := NULL;
  pv_item_code_4            := NULL;
  pv_item_code_5            := NULL;
  pv_item_code_6            := NULL;
  pv_valdtn_reasn_dtl_seq   := NULL;

  -- Check to make sure that the item type code is a valid code.
  SELECT
    COUNT(*)
  INTO
    v_temp_number
  FROM
    pds_valdtn_type
  WHERE
    valdtn_type_code = i_valdtn_type_code;

  IF (v_temp_number IS NULL) THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - Validation Type Code: ' || i_valdtn_type_code ||
                  ' is not valid. Exiting.');

    RAISE_APPLICATION_ERROR(-20000,
                            'Validation Type Code: ' || i_valdtn_type_code ||
                            ' is not valid.');
  END IF;

  -- Get the surrogate key from the Item Key table for the item type and it's code(s).
  OPEN csr_valdtn_reasn_hdr_code;
  LOOP
    FETCH csr_valdtn_reasn_hdr_code INTO rv_valdtn_reasn_hdr_code.valdtn_reasn_hdr_code;
    EXIT WHEN csr_valdtn_reasn_hdr_code%NOTFOUND;

    -- Clear the validation reason detail table.
    DELETE FROM
      pds_valdtn_reasn_dtl
    WHERE
      valdtn_reasn_hdr_code = rv_valdtn_reasn_hdr_code.valdtn_reasn_hdr_code;

    -- Clear the validation reason header table.
    DELETE FROM
      pds_valdtn_reasn_hdr
    WHERE
      valdtn_reasn_hdr_code = rv_valdtn_reasn_hdr_code.valdtn_reasn_hdr_code;
  END LOOP;

  -- Commit the deletions.
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR CLEAR_VALIDATION_REASON.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
    ROLLBACK;

    IF (csr_valdtn_reasn_hdr_code%ISOPEN) THEN
      CLOSE csr_valdtn_reasn_hdr_code;
    END IF;

    RAISE_APPLICATION_ERROR(-20000,
                            'Failed to clear validation reason(s): ' ||
                            sqlerrm);

END clear_validation_reason;


PROCEDURE add_validation_reason (
  i_valdtn_type_code pds_valdtn_reasn_hdr.valdtn_type_code%TYPE,
  i_message pds_valdtn_reasn_dtl.valdtn_reasn_dtl_msg%TYPE,
  i_severity pds_valdtn_reasn_dtl.valdtn_reasn_dtl_svrty%TYPE,
  i_item_code_1 pds_valdtn_reasn_hdr.item_code_1%TYPE DEFAULT NULL,
  i_item_code_2 pds_valdtn_reasn_hdr.item_code_2%TYPE DEFAULT NULL,
  i_item_code_3 pds_valdtn_reasn_hdr.item_code_3%TYPE DEFAULT NULL,
  i_item_code_4 pds_valdtn_reasn_hdr.item_code_4%TYPE DEFAULT NULL,
  i_item_code_5 pds_valdtn_reasn_hdr.item_code_5%TYPE DEFAULT NULL,
  i_item_code_6 pds_valdtn_reasn_hdr.item_code_6%TYPE DEFAULT NULL,
  i_log_level pds_log.log_level%TYPE DEFAULT 0) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- VARIABLE DECLARATIONS
  v_get_new_id  BOOLEAN := true;
  v_temp_number PLS_INTEGER := NULL;
  v_log_level   pds_log.log_level%TYPE := 0;

  -- CURSOR DECLARATIONS
  CURSOR csr_valdtn_reasn_hdr_code IS
    SELECT
      valdtn_reasn_hdr_code
    FROM
      pds_valdtn_reasn_hdr
    WHERE
      valdtn_type_code = i_valdtn_type_code
      AND DECODE(item_code_1, i_item_code_1, 1, 0) = 1
      AND DECODE(item_code_2, i_item_code_2, 1, 0) = 1
      AND DECODE(item_code_3, i_item_code_3, 1, 0) = 1
      AND DECODE(item_code_4, i_item_code_4, 1, 0) = 1
      AND DECODE(item_code_5, i_item_code_5, 1, 0) = 1
      AND DECODE(item_code_6, i_item_code_6, 1, 0) = 1;

BEGIN
  -- Initialising variables.
  v_temp_number := NULL;

  --Check to make sure that the item type code is a valid code.
  SELECT
    COUNT(*)
  INTO
    v_temp_number
  FROM
    pds_valdtn_type
  WHERE
    valdtn_type_code = i_valdtn_type_code;

  IF (v_temp_number IS NULL) THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - Validation Type Code: ' || i_valdtn_type_code ||
                  ' is not valid. Exiting.');

    RAISE_APPLICATION_ERROR(-20000,
                            'Validation Type Code: ' || i_valdtn_type_code ||
                            ' is not valid.');
  END IF;

  --Make sure that the message is not null and is greater than 0 characters.
  IF (i_message IS NULL OR LENGTH(i_message) < 1) THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - Invalid Message: ' || i_message || '. ' ||
                  'Message must be populated. Exiting.');

    RAISE_APPLICATION_ERROR(-20000,
                            'Invalid Message: ' || i_message || '. ' ||
                            'Message must be populated.');
  END IF;

  --Make sure that the severity is either WARNING or CRITICAL.
  IF (i_severity <> pc_valdtn_severity_critical AND
      i_severity <> pc_valdtn_severity_warning) THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - Invalid Severity: ' || i_severity || '. ' ||
                  'Exiting.');

    RAISE_APPLICATION_ERROR(-20000,
                            'Invalid Severity: ' || i_severity || '.');
  END IF;

  -- Check to see if the item type has changed.
  IF (i_valdtn_type_code = pv_valdtn_type_code) THEN

    IF (NVL(i_item_code_1, 0) = NVL(pv_item_code_1, 0)
    AND NVL(i_item_code_2, 0) = NVL(pv_item_code_2, 0)
    AND NVL(i_item_code_3, 0) = NVL(pv_item_code_3, 0)
    AND NVL(i_item_code_4, 0) = NVL(pv_item_code_4, 0)
    AND NVL(i_item_code_5, 0) = NVL(pv_item_code_5, 0)
    AND NVL(i_item_code_6, 0) = NVL(pv_item_code_6, 0)) THEN
      v_get_new_id           := false;
      pv_valdtn_reasn_dtl_seq := pv_valdtn_reasn_dtl_seq + 1;

    END IF;
  END IF;


  IF (v_get_new_id) THEN

    -- If item type has changed, create a new entry in the ods.pds_valdtn_reasn_hdr table and get
    -- it's surrogate key. Add this item to the item key table.
    INSERT INTO
      pds_valdtn_reasn_hdr
      (valdtn_type_code,
       item_code_1,
       item_code_2,
       item_code_3,
       item_code_4,
       item_code_5,
       item_code_6)
    VALUES
      (i_valdtn_type_code,
       i_item_code_1,
       i_item_code_2,
       i_item_code_3,
       i_item_code_4,
       i_item_code_5,
       i_item_code_6);

    -- Get the surrogate key from the item key table for the item type and it's code(s).
    OPEN csr_valdtn_reasn_hdr_code;
    FETCH csr_valdtn_reasn_hdr_code INTO pv_valdtn_reasn_hdr_code;
    CLOSE csr_valdtn_reasn_hdr_code;

    -- Now set the global variables
    pv_valdtn_type_code := i_valdtn_type_code;
    pv_item_code_1 := i_item_code_1;
    pv_item_code_2 := i_item_code_2;
    pv_item_code_3 := i_item_code_3;
    pv_item_code_4 := i_item_code_4;
    pv_item_code_5 := i_item_code_5;
    pv_item_code_6 := i_item_code_6;
    pv_valdtn_reasn_dtl_seq := 1;
  END IF;

  -- Check to make sure that the above went OK
  IF (pv_valdtn_reasn_hdr_code IS NOT NULL) THEN

    BEGIN
      INSERT INTO pds_valdtn_reasn_dtl
        (
         valdtn_reasn_hdr_code,
         valdtn_reasn_dtl_seq,
         valdtn_reasn_dtl_msg,
         valdtn_reasn_dtl_svrty
        )
      VALUES
        (
         pv_valdtn_reasn_hdr_code,
         pv_valdtn_reasn_dtl_seq,
         i_message,
         i_severity
        );

    EXCEPTION
      WHEN OTHERS THEN
        pds_utils.log(pc_job_type_utils,
                      pc_data_type_not_applicable,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - Failed to insert validation reason. Exiting.'||utils.create_sql_err_msg());

        RAISE_APPLICATION_ERROR(-20000,
                                'Failed to insert validation reason.');
    END;

  ELSE
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - Could not find Validation Reason Header Code. Exiting.');

    RAISE_APPLICATION_ERROR(-20000,
                            'Could not find Validation Reason Header Code.');
  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR ADD_VALIDATION_REASON.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Failed to add validation reason: ' ||
                            SQLERRM);

END add_validation_reason;


PROCEDURE create_promax_job_control (
  i_pmx_job_cnfgn_id IN pds_pmx_job_cnfgn.pmx_job_cnfgn_id%TYPE,
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  v_log_level   pds_log.log_level%TYPE := 0;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;

  -- CURSOR DECLARATIONS
  CURSOR csr_pmx_job_cnfgn IS
    SELECT
      t1.*
    FROM
      pds_pmx_job_cnfgn t1
    WHERE
      t1.pmx_job_cnfgn_id = i_pmx_job_cnfgn_id
      AND t1.job_status = 'ACTIVE';
    rv_pmx_job_cnfgn csr_pmx_job_cnfgn%ROWTYPE;

BEGIN
  -- Start create_promax_job_control procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'create_promax_job_control - Start.');

  -- Set log level variable.
  v_log_level := i_log_level;

  -- Open cursor.
  OPEN csr_pmx_job_cnfgn;

  -- Fetch the record from the cursor.
  FETCH csr_pmx_job_cnfgn INTO rv_pmx_job_cnfgn;
  IF csr_pmx_job_cnfgn%NOTFOUND THEN
    pv_processing_msg := 'Promax Job Configuration record not found in PDS_PMX_JOB_CNTL table.';
    RAISE e_processing_failure;
  END IF;

  -- Insert into the PDS_PMX_JOB_CNTL table.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Insert into PDS_PMX_JOB_CNTL table.');
  INSERT INTO pds_pmx_job_cntl
    (
    pmx_job_cnfgn_id,
    pstbx_short_name,
    pstbx_job,
    job_type_code,
    creatn_date,
    job_status,
    max_run_time,
    email_group,
    alert_group,
    job_prty
    )
  VALUES
    (
    rv_pmx_job_cnfgn.pmx_job_cnfgn_id,
    rv_pmx_job_cnfgn.pstbx_short_name,
    rv_pmx_job_cnfgn.pstbx_job,
    rv_pmx_job_cnfgn.job_type_code,
    SYSDATE,
    pc_job_status_submitted,
    rv_pmx_job_cnfgn.max_run_time,
    rv_pmx_job_cnfgn.email_group,
    rv_pmx_job_cnfgn.alert_group,
    rv_pmx_job_cnfgn.job_prty
    );

  -- Commit record.
  COMMIT;

  -- Close cursor.
  CLOSE csr_pmx_job_cnfgn;

  -- End create_promax_job_control procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'create_promax_job_control - End.');

EXCEPTION
  WHEN e_processing_failure THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'FAILURE',
                  0,
                  '!!!FAILURE!!! - FAILURE FOR CREATE_PROMAX_JOB_CONTOL.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(pv_processing_msg, 1, 512));

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR CREATE_PROMAX_JOB_CONTOL.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END create_promax_job_control;


PROCEDURE set_users_read_only (
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- VARIABLE DECLARATIONS
  v_log_level   pds_log.log_level%TYPE := 0;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether backup table is empty.
  CURSOR csr_pds_pmx_users IS
    SELECT
      t1.*
    FROM
      pds_pmx_users t1;
    rv_pds_pmx_users csr_pds_pmx_users%ROWTYPE;

  -- Retrieve all user accounts.
  CURSOR csr_users IS
    SELECT
      t1.*
    FROM
      users t1;
    rv_users csr_users%ROWTYPE;

BEGIN
  -- Start set_users_read_only procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'set_users_read_only - Start.');

  -- Set log level variable.
  v_log_level := i_log_level;

  -- Check that the backup table PDS_PMX_USERS is empty. If not, do not proceed as
  -- user account settings will be lost.  The procedure UNSET_USERS_READ_ONLY needs
  -- to be run before re-running this procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Checking that the backup table PDS_PMX_USERS is empty.');

  -- Open cursor.
  OPEN csr_pds_pmx_users;

  -- Fetch the record from the cursor.
  FETCH csr_pds_pmx_users INTO rv_pds_pmx_users;
  IF csr_pds_pmx_users%FOUND THEN
    pv_processing_msg := 'Promax User Account data exists in the PDS_PMX_USERS table, therefore cannot proceed.';
    RAISE e_processing_failure;
  END IF;

  -- Close cursor.
  CLOSE csr_pds_pmx_users;

  -- Open and loop through cursor.
  OPEN csr_users;
  LOOP
    FETCH csr_users INTO rv_users;
    EXIT WHEN csr_users%NOTFOUND;

    -- Insert into the PDS_PMX_USERS table.
    pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Insert into PDS_PMX_USERS table.');
    INSERT INTO pds_pmx_users
      (
      cmpny_code,
      div_code,
      userkey,
      loginid,
      lastlogin,
      logincount,
      uclasskey,
      crntcodiv,
      authkey,
      levelkey,
      managerkey,
      accmgrkey,
      auth2key
      )
    VALUES
      (
      rv_users.cocode,
      rv_users.divcode,
      rv_users.userkey,
      rv_users.loginid,
      rv_users.lastlogin,
      rv_users.logincount,
      rv_users.uclasskey,
      rv_users.crntcodiv,
      rv_users.authkey,
      rv_users.levelkey,
      rv_users.managerkey,
      rv_users.accmgrkey,
      rv_users.auth2key
      );

  END LOOP;

  -- Set all Promax User Accounts to read-only mode.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Setting all Promax User Accounts to read-only mode.');
  UPDATE users
  SET uclasskey = 'R'
  WHERE uclasskey IN ('U','L');

  -- Update the DIVPARAM table to force the first menu to be visible but with all optional selections turned off.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Updating the DIVPARAM table to force the first menu to be visible but with all optional selections turned off.');
  UPDATE divparam
  SET divvalue = 'M1, 1'
  WHERE setting = 'OPTIONS SELECTED';

  -- Commit transaction.
  COMMIT;

  -- Close cursor.
  CLOSE csr_users;

  -- End set_users_read_only procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'set_users_read_only - End.');

EXCEPTION
  WHEN e_processing_failure THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'FAILURE',
                  0,
                  '!!!FAILURE!!! - FAILURE FOR SET_USERS_READ_ONLY.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(pv_processing_msg, 1, 512));

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR SET_USERS_READ_ONLY.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END set_users_read_only;


PROCEDURE unset_users_read_only (
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS

  -- VARIABLE DECLARATIONS
  v_log_level   pds_log.log_level%TYPE := 0;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;




BEGIN
  -- Start unset_users_read_only procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'unset_users_read_only - Start.');

  -- Set log level variable.
  v_log_level := i_log_level;

  -- Reset appropriate Promax User Accounts to 'Limited Normal User' mode.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Resetting appropriate Promax User Accounts to ''Limited Normal User'' mode.');
  UPDATE users t1
  SET t1.uclasskey = 'L'
  WHERE t1.loginid IN
    (SELECT t2.loginid
     FROM pds_pmx_users t2
     WHERE t2.uclasskey = 'L'
       AND t1.loginid = t2.loginid
       AND t1.cocode = t2.cmpny_code
       AND t1.divcode = t2.div_code);

  -- Reset appropriate Promax User Accounts to 'Normal User' mode.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Resetting appropriate Promax User Accounts to ''Normal User'' mode.');
  UPDATE users t1
  SET t1.uclasskey = 'U'
  WHERE t1.loginid IN
    (SELECT t2.loginid
     FROM  pds_pmx_users t2
     WHERE t2.uclasskey = 'U'
       AND t1.loginid = t2.loginid
       AND t1.cocode = t2.cmpny_code
       AND t1.divcode = t2.div_code);


  -- Update the DIVPARAM table to force the first menu to be visible but with all optional selections turned on.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Updating the DIVPARAM table to force the first menu to be visible but with all optional selections turned on.');
  UPDATE divparam
  SET divvalue = ' '
  WHERE setting = 'OPTIONS SELECTED';

  -- Delete all data from the PDS_PMX_USERS table.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Deleting all data from the PDS_PMX_USERS table.');
  DELETE FROM pds_pmx_users;

  -- Commit transaction.
  COMMIT;

  -- End unset_users_read_only procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'unset_users_read_only - End.');

EXCEPTION
  WHEN e_processing_failure THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'FAILURE',
                  0,
                  '!!!FAILURE!!! - FAILURE FOR UNSET_USERS_READ_ONLY.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(pv_processing_msg, 1, 512));

  WHEN OTHERS THEN
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR UNSET_USERS_READ_ONLY.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END unset_users_read_only;

PROCEDURE clean_pds_log (
  i_log_level IN pds_log.log_level%TYPE DEFAULT 0
  ) IS
-- VARIABLE DECLARATIONS
  v_log_level   pds_log.log_level%TYPE := 0;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;

CURSOR csr_pds_job_type IS
    SELECT
      t2.*
    FROM
      pds_job_type t2;

    rv_csr_pds_job_type csr_pds_job_type%ROWTYPE;


BEGIN
  -- Start clean_pds_log procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'clean_pds_log - Start.');

  -- Set log level variable.
  v_log_level := i_log_level;

  -- Open cursor.
  OPEN csr_pds_job_type;

  -- Fetch the record from the cursor.


  LOOP
    FETCH csr_pds_job_type INTO rv_csr_pds_job_type;
    EXIT WHEN csr_pds_job_type%NOTFOUND;

    pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'Deleting records from pds_log TYPE:'||rv_csr_pds_job_type.job_type_code||' DATE: '||(sysdate - rv_csr_pds_job_type.job_type_hist));

    -- Delete records
    delete from pds_log
    where
        pds_log.job_type_code = rv_csr_pds_job_type.job_type_code and
        pds_log.LOG_LUPDT < (sysdate - rv_csr_pds_job_type.job_type_hist) and
        pds_log.LOG_LEVEL >= decode(rv_csr_pds_job_type.job_type_keep_level,null,0,rv_csr_pds_job_type.job_type_keep_level+1);

  END LOOP;

  -- Commit transaction.
  COMMIT;

  -- Start clean_pds_log procedure.
  pds_utils.log(pc_job_type_utils, pc_data_type_not_applicable, 'N/A', v_log_level, 'clean_pds_log - End.');

EXCEPTION
  WHEN e_processing_failure THEN
    ROLLBACK;
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'FAILURE',
                  0,
                  '!!!FAILURE!!! - FAILURE FOR CLEAN_PDS_LOG.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(pv_processing_msg, 1, 512));

  WHEN OTHERS THEN
    ROLLBACK;
    pds_utils.log(pc_job_type_utils,
                  pc_data_type_not_applicable,
                  'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR CLEAN_PDS_LOG.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
END clean_pds_log;

PROCEDURE create_log  IS
BEGIN
  pv_session := NULL;
  pv_sequence := 0;
END create_log;

BEGIN

  -- Initialise the file ID variable. It has to be performed in this block down
  -- the bottom to ensure that the there is not an open file when the session
  -- is first created.
  pv_extract_file_num.ID  := NULL;
  v_log_debug             := FALSE;
  pv_session               := NULL;
  pv_sequence              := 0;
  pv_valdtn_type_code          := NULL;
  pv_valdtn_reasn_hdr_code     := NULL;
  pv_item_code_1               := NULL;
  pv_item_code_2               := NULL;
  pv_item_code_3               := NULL;
  pv_item_code_4               := NULL;
  pv_item_code_5               := NULL;
  pv_item_code_6               := NULL;
  pv_valdtn_reasn_dtl_seq      := NULL;

END pds_utils;
/
