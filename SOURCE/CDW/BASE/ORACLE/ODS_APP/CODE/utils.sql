CREATE OR REPLACE PACKAGE ODS_APP.utils AS

  /*******************************************************************************
    NAME:      log
    PURPOSE:   Logs text messages to the ods.log table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.
	2.0   01/06/2006 Linden Glen 		  RE-Write of procedure to remove repetition
	                                      of slow running query. Overcome issue when
										  validation executes over a long period of time

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 The type of job that is invoking the i_job_type_code
                log procedure. Populate using the constants,
                ods_constants.job_type_*
    2    IN     VARCHAR2 The type of data being processed by  i_data_type
                job invoking this log procedure. Populte via
                ods_constants.data_type_*
    3    IN     VARCHAR2 A sort field which contains a data   i_sort_field
                item relevant to the log line. For example,
                a material code, a customer code, a date, etc.
    4    IN     NUMBER A numeric logging level, starting at   i_log_level
                zero and incrementing up. Can also be
                considered to be an indenting factor.
    5    IN     VARCHAR2 The text being logged.               i_log_text
                zero and incremented up.

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE ods_log(
    i_job_type_code IN ods.log.job_type_code%TYPE,
    i_data_type     IN ods.log.data_type%TYPE,
    i_sort_field    IN ods.log.sort_field%TYPE,
    i_log_level     IN ods.log.log_level%TYPE,
    i_log_text      IN ods.log.log_text%TYPE
  );



  /*******************************************************************************
    NAME:      get_log_session_id
    PURPOSE:   return the log session id..

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   24/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION get_log_session_id RETURN NUMBER;



  /*******************************************************************************
    NAME:      aprint_log
    PURPOSE:   Allows you to print the log up to the specificed log level.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     NUMBER   The sessions ID that the log has     i_session_id
                         been recorded under. Attained from
                         utils.get_log_session_id;
    2    IN      NUMBER   The Max log level you want displayed i_max_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE print_log(
    i_session_id    IN ods.log.SESSION_ID%TYPE,
    i_max_log_level IN ods.log.log_level%TYPE DEFAULT 10
    );



  /*******************************************************************************
    NAME:      unix_command_wrapper
    PURPOSE:   Calls java_utility.execute_external_function to execute the command.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 The unix command to execute          i_unix_command
    2    IN              The Log level that you want logging  i_log_level
                         to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION unix_command_wrapper(
    i_unix_command IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
  ) RETURN VARCHAR2;



  /*******************************************************************************
    NAME:      send_short_email
    PURPOSE:   Sends out an email using utl_smtp package with the message
               in i_message.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 The recipient address of the e-mail  i_recipient
    2    IN     VARCHAR2 The subject of the e-mail            i_subject
    3    IN     VARCHAR2 The message of the email             i_message
    4    IN              The Log level that you want logging  i_log_level
                         to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE send_short_email(
    i_recipient IN VARCHAR2,
    i_subject   IN VARCHAR2,
    i_message   IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
  );



  /*******************************************************************************
    NAME:      send_email_to_group
    PURPOSE:   Sends out an email using utl_smtp package with the message
               in i_message to a group from the email_list table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 The job type from which to get the   i_email_group
                         list of email address to send this
                         message to.
    2    IN     VARCHAR2 The subject of the e-mail            i_subject
    3    IN     VARCHAR2 The message of the email             i_message
    4    IN     VARCHAR2 The company that this email is       i_company_code
                         relevant for.
    5    IN              The Log level that you want logging  i_log_level
                         to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE send_email_to_group(
    i_email_group  IN email_list.job_type_code%TYPE,
    i_subject      IN VARCHAR2,
    i_message      IN VARCHAR2,
    i_company_code IN email_list.company_code%TYPE DEFAULT NULL,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
  );



  /*******************************************************************************
    NAME:      start_long_email
    PURPOSE:   Start the creation of an email that allows you to keep appending
             lines to it.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 The recipient address of the e-mail  i_recipient
    2    IN     VARCHAR2 The subject of the e-mail            i_subject
    3    IN              The Log level that you want logging  i_log_level
                         to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE start_long_email(
    i_recipient IN VARCHAR2,
    i_subject   IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
  );




  /*******************************************************************************
    NAME:      append_to_long_email
    PURPOSE:   Allows you to keep appending lines to your long email.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 The message of the email             i_message
    2    IN              The Log level that you want logging  i_log_level
                         to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES: This will throw an error if you have not called start_long_email first
  ********************************************************************************/
  PROCEDURE append_to_long_email(
    i_message IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    );



  /*******************************************************************************
    NAME:      append_log_to_long_email
    PURPOSE:   Allows you to append the log up to the specificed log level to your
               long email.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     NUMBER   The sessions ID that the log has     i_session_id
                         been recorded under. Attained from
                         utils.get_log_session_id;
    2    IN      NUMBER   The Max log level you want displayed i_max_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES: This will throw an error if you have not called start_long_email first
  ********************************************************************************/
  PROCEDURE append_log_to_long_email(
    i_session_id    IN ods.log.SESSION_ID%TYPE,
    i_max_log_level IN ods.log.log_level%TYPE DEFAULT 10
    );



  /*******************************************************************************
    NAME:      send_long_email
    PURPOSE:   sends the long e-mail.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN              The Log level that you want logging  i_log_level
                         to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES: This will throw an error if you have not called start_long_email first
  ********************************************************************************/
  PROCEDURE send_long_email(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    );



  /*******************************************************************************
    NAME:      send_tivoli_alert
    PURPOSE:   Sends an alert of varying priority to tivoli.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 The level of alert you want from     i_alert_level
                constants.tivoli_alert_level_*
    2    IN     VARCHAR2 The message that you want to add     i_message
                to the alert message. Can not be
                longer than
                constants.tivoli_max_message_length
    3    IN     The Job Type CODE that this alert is for      i_job_type_code
                  from JOB_TYPE.JOB_TYPE_CODE
    4    IN     The company code that the alert is for.       i_company_code
    5    IN     The Log level that you want logging           i_log_level
                  to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES: This will truncate the i_message variable if it is greater that
           constants.tivoli_max_message_length
  ********************************************************************************/
  PROCEDURE send_tivoli_alert(
    i_alert_level   IN VARCHAR2,
    i_message       IN VARCHAR2,
    i_job_type_code IN ods.log.job_type_code%TYPE,
    i_company_code  IN company.company_code%TYPE DEFAULT NULL,
    i_log_level     IN ods.log.log_level%TYPE DEFAULT 0
  );



  /*******************************************************************************
    NAME:      get_date_time_at_company
    PURPOSE:   Returns the current date and time for the given company code
               in company local time.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN              The Company Code that you want the   i_alert_level
                         company local date and time for.
                company.company_code%TYPE
    2    IN              The Log level that you want logging  i_log_level
                         to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION get_date_time_at_company(
    i_company_code IN company.company_code%TYPE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
  ) RETURN DATE;



  /*******************************************************************************
    NAME:      put_file_on_queue
    PURPOSE:   Places a file from the file system onto a queue.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   22/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 The entire path and filename of the  i_complete_filename
                         file to place on the queue.
    2    IN     VARCHAR2 The queue Tier from ods_constants.   i_queue_tier
    3    IN     VARCHAR2 The queue name to place the file on. i_queue_name
    4    IN              The Log level that you want logging  i_log_level
                         to start at. Defaults to zero.
                ods.log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE put_file_on_queue(
    i_source_filename      IN VARCHAR2,
    i_source_system        IN VARCHAR2,
    i_destination_filename IN VARCHAR2,
    i_destination_system   IN VARCHAR2,
    i_log_level            IN ods.log.log_level%TYPE DEFAULT 0
  );



  /*************************************************************************
    NAME:      clear_validation_reason
    PURPOSE:   Clear the valdtn_reasn_hdr and valdtn_reasn_dtl tables of
               information pertaining to a validation type and item codes.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   23/11/2004 Gerald Arnold        Created this function.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------
    1    IN     valdtn_reasn_hdr.valdtn_type_code
                         Validation Type that you are wanting
                         to clear.                               1
    2    IN     valdtn_reasn_hdr.item_code_1
                         The 1st part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    3    IN     valdtn_reasn_hdr.item_code_2
                         The 2nd part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    4    IN     valdtn_reasn_hdr.item_code_3
                         The 3rd part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    5    IN     valdtn_reasn_hdr.item_code_4
                         The 4th part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    6    IN     valdtn_reasn_hdr.item_code_5
                         The 5th part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    7    IN     valdtn_reasn_hdr.item_code_6
                         The 6th part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    8    IN     ods.log.log_level
                         Level of logging                     5

    RETURN VALUE: NUMBER
      [CONSTANTS.SUCCESS, CONSTANTS.FAILURE, CONSTANTS.ERROR]
    ASSUMPTIONS:
    NOTES:
  *************************************************************************/
  PROCEDURE clear_validation_reason (
    i_valdtn_type_code valdtn_reasn_hdr.valdtn_type_code%TYPE,
    i_item_code_1      valdtn_reasn_hdr.item_code_1%TYPE,
    i_item_code_2      valdtn_reasn_hdr.item_code_2%TYPE DEFAULT NULL,
    i_item_code_3      valdtn_reasn_hdr.item_code_3%TYPE DEFAULT NULL,
    i_item_code_4      valdtn_reasn_hdr.item_code_4%TYPE DEFAULT NULL,
    i_item_code_5      valdtn_reasn_hdr.item_code_5%TYPE DEFAULT NULL,
    i_item_code_6      valdtn_reasn_hdr.item_code_6%TYPE DEFAULT NULL,
    i_log_level        ods.log.log_level%TYPE DEFAULT 0);



  /*************************************************************************
    NAME:      clear_validation_reason
    PURPOSE:   Clear the valdtn_reasn_hdr and valdtn_reasn_dtl tables of
               information pertaining to a validation type and item codes.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   23/11/2004 Gerald Arnold        Created this function.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------
    1    IN     valdtn_reasn_hdr.valdtn_type_code
                         Validation Type that you are wanting  1
                         to clear.
    2    IN     valdtn_reasn_hdr.valdtn_reasn_dtl_msg
                         The message to explain why this item  Missing Unit of Measure
                         is invalid.
    3    IN     valdtn_reasn_hdr.valdtn_reasn_dtl_svrty
                         The severity level associated with    CRITICAL
                         the message that explain why this
                         item is invalid.
    4    IN     valdtn_reasn_hdr.item_code_1
                         The 1st part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    5    IN     valdtn_reasn_hdr.item_code_2
                         The 2nd part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    6    IN     valdtn_reasn_hdr.item_code_3
                         The 3rd part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    7    IN     valdtn_reasn_hdr.item_code_4
                         The 4th part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    8    IN     valdtn_reasn_hdr.item_code_5
                         The 5th part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    9    IN     valdtn_reasn_hdr.item_code_6
                         The 6th part of the primary key of    1111
                         the item who's messages you are
                         wanting to clear.
    10   IN     ods.log.log_level
                         Level to start logging at             5

    RETURN VALUE: NUMBER
      [CONSTANTS.SUCCESS, CONSTANTS.FAILURE, CONSTANTS.ERROR]
    ASSUMPTIONS:
    NOTES:
  *************************************************************************/
  PROCEDURE add_validation_reason (
    i_valdtn_type_code valdtn_reasn_hdr.valdtn_type_code%TYPE,
    i_message          valdtn_reasn_dtl.valdtn_reasn_dtl_msg%TYPE,
    i_severity         valdtn_reasn_dtl.valdtn_reasn_dtl_svrty%TYPE,
    i_item_code_1      valdtn_reasn_hdr.item_code_1%TYPE,
    i_item_code_2      valdtn_reasn_hdr.item_code_2%TYPE DEFAULT NULL,
    i_item_code_3      valdtn_reasn_hdr.item_code_3%TYPE DEFAULT NULL,
    i_item_code_4      valdtn_reasn_hdr.item_code_4%TYPE DEFAULT NULL,
    i_item_code_5      valdtn_reasn_hdr.item_code_5%TYPE DEFAULT NULL,
    i_item_code_6      valdtn_reasn_hdr.item_code_6%TYPE DEFAULT NULL,
    i_log_level        ods.log.log_level%TYPE DEFAULT 0);



  /*************************************************************************
    NAME:      TZ_CONV_DATE_TIME
    PURPOSE:   Time Zone conversion.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   17/12/2004 Gerald Arnold        Created this function.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------
    1    IN     DATE     The date to do the calculations from.
    2    IN     V$TIMEZONE_NAMES.TZNAME%TYPE
                          The From timezone.
    3    IN     V$TIMEZONE_NAMES.TZNAME%TYPE
                          The To timezone.

    RETURN VALUE: NUMBER
      [CONSTANTS.SUCCESS, CONSTANTS.FAILURE, CONSTANTS.ERROR]
    ASSUMPTIONS:
    NOTES:
  *************************************************************************/
  FUNCTION tz_conv_date_time (
    i_from_date     IN DATE,
    i_from_timezone IN V$TIMEZONE_NAMES.TZNAME%TYPE,
    i_to_timezone   IN V$TIMEZONE_NAMES.TZNAME%TYPE
    ) RETURN DATE;



 /*************************************************************************
    NAME:      GET_PERIOD_DIFF
    PURPOSE:   Returns the number of periods between two mars_periods 
               (<YYYYPP1> - <YYYYPP2>).The number of periods returned is negative  
               if the first period passed in occurs before the second period.  

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   29/05/2006 Paul Jacobs          Created this function.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------
    1    IN     NUMBER   The start YYYYPP.
    2    IN     NUMBER   The end YYYYPP.


    RETURN VALUE: NUMBER
      [CONSTANTS.SUCCESS, CONSTANTS.FAILURE, CONSTANTS.ERROR]
    ASSUMPTIONS:
    NOTES:
  *************************************************************************/
  FUNCTION get_period_diff (
    i_yyyypp1  IN NUMBER,
    i_yyyypp2  IN NUMBER    
    ) RETURN NUMBER;



  /*************************************************************************
    NAME:      REMOVE_CHARS
    PURPOSE:   Removes leading alpha characters from a string so that only
               numbers are returned.               

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   08/07/2006 Paul Jacobs          Created this function.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------
    1    IN     NUMBER   The material code beginning with characters.


    RETURN VALUE: NUMBER
      [CONSTANTS.SUCCESS, CONSTANTS.FAILURE, CONSTANTS.ERROR]
    ASSUMPTIONS:
    NOTES:
  *************************************************************************/
  FUNCTION remove_chars (
    i_matl_code IN VARCHAR2
    ) RETURN NUMBER;

END utils;
/

CREATE OR REPLACE PACKAGE BODY ODS_APP.utils AS

  -- Variable for the smtp connection used by the long e-mail procedures
  v_connection  utl_smtp.connection;
  v_session     NUMBER;

  -- Parameters for extracting to file.  Initialised at the bottom of the
  -- package body.
  v_extract_file_num  UTL_FILE.FILE_TYPE;

  -- Parameter for controlling generation of debugging information for this
  -- package
  v_log_debug  BOOLEAN;


  -- Global variables used in the clear and add validation reason proceedures
  v_valdtn_type_code      valdtn_type.valdtn_type_code%TYPE;
  v_valdtn_reasn_hdr_code valdtn_reasn_hdr.valdtn_reasn_hdr_code%TYPE;
  v_item_code_1           valdtn_reasn_hdr.item_code_1%TYPE;
  v_item_code_2           valdtn_reasn_hdr.item_code_2%TYPE;
  v_item_code_3           valdtn_reasn_hdr.item_code_3%TYPE;
  v_item_code_4           valdtn_reasn_hdr.item_code_4%TYPE;
  v_item_code_5           valdtn_reasn_hdr.item_code_5%TYPE;
  v_item_code_6           valdtn_reasn_hdr.item_code_6%TYPE;
  v_valdtn_reasn_dtl_seq  valdtn_reasn_dtl.valdtn_reasn_dtl_seq%TYPE;



  procedure ods_log(i_job_type_code in ods.log.job_type_code%type,
                    i_data_type     in ods.log.data_type%type,
                    i_sort_field    in ods.log.sort_field%type,
                    i_log_level     in ods.log.log_level%type,
                    i_log_text      in ods.log.log_text%type) is

    /*-*/
    /* Ensure commits are in the context of this procedure only!
    /*-*/
    pragma autonomous_transaction;

    /*-*/
    /* Private variables
    /*-*/
    rcd_log ods.log%rowtype;
    var_new_session boolean;


    /*-*/
    /* Initialise system variables
    /*-*/
    var_lics_job_name varchar2(40);
    var_lics_job_type varchar2(20);
    var_lics_int_group varchar2(20);
    var_lics_jot_procedure varchar2(256);
    var_lics_jot_user varchar2(40);


  begin

    /*-*/
    /* Initialise variables
    /*-*/
    var_new_session := false;

    /*-*/
    /* Initialise parameters to UNASSIGNED if null
    /*-*/
    rcd_log.job_type_code := nvl(i_job_type_code,ods_constants.job_type_unassigned);
    rcd_log.data_type := nvl(i_data_type,'UNASSIGNED');
    rcd_log.sort_field := nvl(i_sort_field,'UNASSIGNED');
    rcd_log.log_level := nvl(abs(i_log_level),0);
    rcd_log.log_text := nvl(i_log_text,'Blank log written at ' || to_char(sysdate,'YYYYMMDD HH24:MM:SS')
                                       || ' by ' || sys_context ('USERENV', 'SESSION_USER') 
                                       || '@' || upper(sys_context ('USERENV', 'DB_NAME')) 
                                       || '<<CLIENT INFO-' || nvl(sys_context ('USERENV', 'CLIENT_INFO'),'NULL') 
                                       || '>> <<OS USER-' || nvl(sys_context ('USERENV', 'OS_USER') ,'NULL')|| '>>');


    /*-*/
    /* Initialise session ID and log sequence variables
    /*-*/
    if (v_session is null) then

       select log_seq.nextval 
       into v_session 
       from dual;

       rcd_log.log_seq := 0;
       var_new_session := true;

    else

       select max(log_seq)
       into rcd_log.log_seq
       from log
       where session_id = v_session;

    end if;


    /*-*/
    /* At the beginning of a new session, 
    /* insert system information in the log
    /*-*/
    if (var_new_session) then

      /*-*/
      /* Increment Log Sequence
      /*-*/
      rcd_log.log_seq := rcd_log.log_seq+1;

      insert into log (session_id,
                       log_seq,
                       job_type_code,
                       data_type,
                       sort_field,
                       log_level,
                       log_text,
                       log_lupdp,
                       log_lupdt)
                values(v_session,
                       rcd_log.log_seq,
                       rcd_log.job_type_code,
                       'SYSTEM INFORMATION',
                       'N/A',
                       0,
                       'INFORMATION ABOUT CURRENT SESSION',
                       user,
                       sysdate);

      /*-*/
      /* Increment Log Sequence
      /*-*/
      rcd_log.log_seq := rcd_log.log_seq+1;


      insert into log (session_id,
                       log_seq,
                       job_type_code,
                       data_type,
                       sort_field,
                       log_level,
                       log_text,
                       log_lupdp,
                       log_lupdt)
                values(v_session,
                       rcd_log.log_seq,
                       rcd_log.job_type_code,
                       'SYSTEM INFORMATION',
                       'DETAILS',
                       2,
                       'DATABASE/HOST NAME : ' || upper(sys_context('USERENV','DB_NAME')) || '/' || ods_constants.hostname,
                       user,
                       sysdate);


      /*-*/
      /* Retrieve LICS job information
      /*-*/
      lics_app.get_lics_job_info(var_lics_job_name,
                                 var_lics_job_type,
                                 var_lics_int_group,
                                 var_lics_jot_procedure,
                                 var_lics_jot_user);




      /*-*/
      /* Log LICS Job information if available
      /*-*/
      if ((var_lics_job_name is not null) and
          (var_lics_job_type is not null) and
          (var_lics_jot_procedure is not null) and  
          (var_lics_jot_user is not null)) then

         if (var_lics_int_group is null) then
            var_lics_int_group := '<NONE>';
         end if;

         /*-*/
         /* Increment Log Sequence
         /*-*/
         rcd_log.log_seq := rcd_log.log_seq+1;

         insert into log (session_id,
                          log_seq,
                          job_type_code,
                          data_type,
                          sort_field,
                          log_level,
                          log_text,
                          log_lupdp,
                          log_lupdt)
                   values(v_session,
                          rcd_log.log_seq,
                          rcd_log.job_type_code,
                          'SYSTEM INFORMATION',
                          'LICS_APP DETAILS',
                          1,
                          'ICS JOB INFORMATION',
                          user,
                          sysdate);

         /*-*/
         /* Increment Log Sequence
         /*-*/
         rcd_log.log_seq := rcd_log.log_seq+1;

         insert into log (session_id,
                          log_seq,
                          job_type_code,
                          data_type,
                          sort_field,
                          log_level,
                          log_text,
                          log_lupdp,
                          log_lupdt)
                   values(v_session,
                          rcd_log.log_seq,
                          rcd_log.job_type_code,
                          'SYSTEM INFORMATION',
                          'LICS_APP DETAILS',
                          1,
                          'INTFC JOB NAME/JOB TYPE/PROC/USER/GROUP/CLIENT : ' || var_lics_job_name || '/' 
                                                                              || var_lics_job_type || '/'
                                                                              || var_lics_jot_procedure || '/'
                                                                              || var_lics_jot_user || '/'
                                                                              || var_lics_int_group || '/'
                                                                              || sys_context('USERENV', 'CLIENT_INFO'),
                          user,
                          sysdate);


      /*-*/
      /* Log User session details
      /*-*/
      else

         /*-*/
         /* Increment Log Sequence
         /*-*/
         rcd_log.log_seq := rcd_log.log_seq+1;

         insert into log (session_id,
                          log_seq,
                          job_type_code,
                          data_type,
                          sort_field,
                          log_level,
                          log_text,
                          log_lupdp,
                          log_lupdt)
                   values(v_session,
                          rcd_log.log_seq,
                          rcd_log.job_type_code,
                          'SYSTEM INFORMATION',
                          'JOB DETAILS',
                          1,
                          'User Initiated Session by ' || sys_context('userenv', 'os_user'),
                          user,
                          sysdate);  
    
      end if;                          
                                
    end if;

    /*-*/
    /* Insert LOG TEXT details
    /*-*/

    /*-*/
    /* Increment Log Sequence
    /*-*/
    rcd_log.log_seq := rcd_log.log_seq+1;


    insert into log (session_id,
                     log_seq,
                     job_type_code,
                     data_type,
                     sort_field,
                     log_level,
                     log_text,
                     log_lupdp,
                     log_lupdt)
              values(v_session,
                     rcd_log.log_seq,
                     rcd_log.job_type_code,
                     rcd_log.data_type,
                     rcd_log.sort_field,
                     rcd_log.log_level,
                     rcd_log.log_text,
                     user,
                     sysdate);

    /*-*/
    /* Commit the database
    /*-*/
    commit;


  exception

    /*-*/
    /* Rollback and raise error
    /*-*/
    when others then
       rollback;
       raise;
  end;


  FUNCTION get_log_session_id RETURN NUMBER IS
  BEGIN
    IF (v_session IS NOT NULL) THEN
      RETURN v_session;
    ELSE
      raise_application_error(-20000, 'No Session ID Set.');
    END IF;
  EXCEPTION
    WHEN others THEN
      raise_application_error(-20000, 'LOG ERROR - ' || SUBSTR(SQLERRM, 1, 512));
  END;



  PROCEDURE print_log(
    i_session_id    IN ods.log.session_id%TYPE,
    i_max_log_level IN ods.log.log_level%TYPE DEFAULT 10
    ) IS

    --VARIABLES
    v_spaces        VARCHAR2(2000);
    v_message       VARCHAR2(4000);
    v_max_log_level ods.log.log_level%TYPE;

    --CURSORS
    CURSOR csr_get_log IS
      SELECT
        B.job_type_desc,
        A.data_type,
        A.sort_field,
        A.log_level,
        A.log_text,
        A.log_lupdt
      FROM
        log      A,
        job_type B
      WHERE
        A.job_type_code = B.job_type_code
        AND session_id = i_session_id
        AND log_level <= v_max_log_level
      ORDER BY
        log_seq;
    rv_get_log csr_get_log%ROWTYPE;


  BEGIN
    -- Set the buffer nice and large
    dbms_output.enable(50000000);

    IF (i_max_log_level < 0) THEN
      v_max_log_level := 0;
    ELSE
      v_max_log_level := i_max_log_level;
    END IF;

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
          DBMS_OUTPUT.PUT_LINE(SUBSTR(v_message, (1 + (255 * i)), (255 + (255 * i))));
        END LOOP;
      ELSE
        DBMS_OUTPUT.PUT_LINE(v_message);
      END IF;

    END LOOP;
  END print_log;



  FUNCTION unix_command_wrapper(
    i_unix_command IN VARCHAR2,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN VARCHAR2 IS

   -- VARIABLES
    v_temp VARCHAR2(4000);
    v_log_level ods.log.log_level%TYPE := 0;
  BEGIN
    v_log_level := i_log_level;
    v_temp      := '';

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_unix_command,
                  ods_constants.data_type_unix_command,
                  v_log_level,
                  'Starting the unix command wrapper and checking' ||
                  ' that there is a command to execute.');
    -- Make sure that there is a command to execute
    IF (i_unix_command IS NULL OR LENGTH(i_unix_command) = 0) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_unix_command,
                    ods_constants.data_type_unix_command,
                    v_log_level,
                    'No command to execute, exiting.');
      RETURN v_temp;
    END IF;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_unix_command,
                  ods_constants.data_type_unix_command,
                  v_log_level,
                  'Execute command and returning results from shell.');
    BEGIN
		  IF (ods_constants.run_unix_commands) THEN
        v_temp := dbec.java_utility.execute_external_function('"' || ods_constants.base_unix_directory || '/bin/sh.sh" "-c" "' || i_unix_command || '"');
			ELSE
		    utils.ods_log(ods_constants.job_type_utils,
		                  ods_constants.data_type_unix_command,
		                  ods_constants.data_type_unix_command,
		                  v_log_level,
		                  'Not actually executing unix command due to constants paramter.');
			END IF;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(ods_constants.job_type_utils,
                      ods_constants.data_type_unix_command,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR UNIX_COMMAND_WRAPPER.' ||
                      ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
        raise_application_error(-20000, 'Unix Command Failed.');
    END;

    RETURN v_temp;

  EXCEPTION
    WHEN others THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_unix_command,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR UNIX_COMMAND_WRAPPER.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      RETURN ods_constants.error;
  END unix_command_wrapper;


  PROCEDURE send_short_email(
    i_recipient IN VARCHAR2,
    i_subject   IN VARCHAR2,
    i_message   IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- VARIABLES
    v_connection   utl_smtp.connection;
    v_mail_server  VARCHAR2(20)  := ods_constants.mail_server;
    v_sender       VARCHAR2(150) := ods_constants.email_sender;
    v_message      VARCHAR2(4000);
    v_db_name      VARCHAR2(256) := NULL;

    --v_reply        utl_smtp.reply;
    v_log_level    ods.log.log_level%TYPE := 0;

  BEGIN
    v_log_level := i_log_level;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_short_email,
                  ods_constants.data_type_short_email,
                  v_log_level,
                  'Starting Short e-mail and setting up all the basic information.');

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME'))
    INTO
      v_db_name
    FROM
      dual;
    -- Setting the sender address
    v_sender := 'MFANZ@' || v_db_name || v_sender;

    -- Setup the connection to the Mail Server
    v_connection := utl_smtp.open_connection(v_mail_server, 25);

    -- Initialize the basics for the connection
    utl_smtp.helo(v_connection, v_mail_server);

    utl_smtp.mail(v_connection, v_sender);

    -- Make sure that the recipient address is not to long
    IF (LENGTH(i_recipient) > 255) THEN
      raise_application_error(-20000, 'Length of recipient address to long.');
    END IF;
    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_short_email,
                  ods_constants.data_type_short_email,
                  v_log_level + 1,
                  'Setting the e-mail message recipient address.');
    utl_smtp.rcpt(v_connection, i_recipient);

    /*utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_short_email,
                  ods_constants.data_type_short_email,
                  v_log_level + 1,
                  'Checking the e-mail message recipient address.');
    v_reply := utl_smtp.vrfy(v_connection, i_recipient);
    IF (v_reply.code <> 250 AND v_reply.code <> 251) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_short_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Invalid e-mail address.');
      utl_smtp.quit(v_connection);
      raise_application_error(-20000, 'Invalid e-mail address.');
    END IF;*/

    -- Make sure that the subject is not to long
    IF (LENGTH(i_subject) > 400) THEN
      raise_application_error(-20000, 'Length of subject to long.');
    END IF;
    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_short_email,
                  ods_constants.data_type_short_email,
                  v_log_level + 1,
                  'Biulding the email message.');

    -- Build the message to include all the important stuff
    v_message := 'From: '     || v_sender    ||
                 utl_tcp.crlf || 'Subject: '  || i_subject   ||
                 utl_tcp.crlf || 'To: '       || i_recipient ||
                 utl_tcp.crlf || utl_tcp.crlf;
    -- Open the data connection
    utl_smtp.open_data(v_connection);

    -- Send the basic data to the server
    utl_smtp.write_data(v_connection, v_message);

    utils.ods_log(ods_constants.job_type_utils,
                 ods_constants.data_type_short_email,
                 ods_constants.data_type_short_email,
                 v_log_level + 1,
                 'Sending out the e-mail.');
    -- Add the message to the email and send
    utl_smtp.write_data(v_connection, i_message);

    -- Add the session id to the email tail
    utl_smtp.write_data(v_connection, utl_tcp.crlf || utl_tcp.crlf ||
                                      'Session ID: ' || utils.get_log_session_id);

    -- Now send the email out
    utl_smtp.close_data(v_connection);

    utl_smtp.quit(v_connection);
    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_short_email,
                  ods_constants.data_type_short_email,
                  v_log_level,
                  'Finished Short e-mail.');
  EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        utl_smtp.quit(v_connection);
      EXCEPTION WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        NULL;
        -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The quit call will raise an
        -- exception that we can ignore.
      END;
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_short_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
      raise_application_error(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);

    WHEN others THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_short_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR SEND_SHORT_EMAIL.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

  END send_short_email;



  PROCEDURE send_email_to_group(
    i_email_group  IN email_list.job_type_code%TYPE,
    i_subject      IN VARCHAR2,
    i_message      IN VARCHAR2,
    i_company_code IN email_list.company_code%TYPE DEFAULT NULL,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- VARIABLES
    v_connection   utl_smtp.connection;
    v_mail_server  VARCHAR2(20)  := ods_constants.mail_server;
    v_sender       VARCHAR2(150) := ods_constants.email_sender;
    v_message      VARCHAR2(4000);
    v_temp         PLS_INTEGER;

    v_recipient    email_list.email_address%TYPE;

    v_reply        utl_smtp.reply;
    v_log_level    ods.log.log_level%TYPE := 0;


   -- CURSORS
   CURSOR csr_company IS
     SELECT
       COUNT(*)
     FROM
       company
     WHERE
       company_code = i_company_code;

   CURSOR csr_addresses IS
     SELECT DISTINCT
       email_address
     FROM
       email_list
     WHERE
       job_type_code = i_email_group;


   CURSOR csr_company_addresses IS
     SELECT DISTINCT
       email_address
     FROM
       email_list
     WHERE
       job_type_code = i_email_group
       AND company_code = i_company_code;

  BEGIN
    v_log_level := i_log_level;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_short_email,
                  'E-MAIL TO GROUP',
                  v_log_level,
                  'Starting Send e-mail to group.');

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_short_email,
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

        utils.ods_log(ods_constants.job_type_utils,
                      ods_constants.data_type_short_email,
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

        utils.ods_log(ods_constants.job_type_utils,
                      ods_constants.data_type_short_email,
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

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_short_email,
                  'E-MAIL TO GROUP',
                  v_log_level,
                  'Finished e-mail to group.');
  EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        utl_smtp.quit(v_connection);
      EXCEPTION WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        NULL;
        -- When the SMTP server is down or unavailable, we don't have
        -- a connection to the server. The quit call will raise an
        -- exception that we can ignore.
      END;
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_short_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');

      IF (csr_addresses%ISOPEN) THEN
        CLOSE csr_addresses;
      END IF;

      IF (csr_company_addresses%ISOPEN) THEN
        CLOSE csr_company_addresses;
      END IF;

      raise_application_error(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);

    WHEN others THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_short_email,
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
    i_subject   IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- VARIABLES
    v_mail_server VARCHAR2(20)  := ods_constants.mail_server;
    v_sender      VARCHAR2(150) := ods_constants.email_sender;
    v_message     VARCHAR2(4000);
    v_db_name     VARCHAR2(256) := NULL;

    --v_reply       utl_smtp.reply;
    v_log_level   ods.log.log_level%TYPE := 0;

  BEGIN
    v_log_level := i_log_level;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_long_email,
                  ods_constants.data_type_long_email,
                  v_log_level,
                  'Starting Start Long e-mail and setting up all the basic information.');
    -- Setup the connection to the Mail Server
    v_connection := utl_smtp.open_connection(v_mail_server, 25);

    -- Initialize the basics for the connection
    utl_smtp.helo(v_connection, v_mail_server);

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME'))
    INTO
      v_db_name
    FROM
      dual;

    -- Setting the sender address
    v_sender := 'MFANZ@' || v_db_name || v_sender;

    utl_smtp.mail(v_connection, v_sender);

    utl_smtp.rcpt(v_connection, i_recipient);

    /*utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_long_email,
                  ods_constants.data_type_long_email,
                  v_log_level + 1,
                  'Checking the e-mail message recipient address.');
    v_reply := utl_smtp.vrfy(v_connection, i_recipient);
    IF (v_reply.code <> 250 AND v_reply.code <> 251) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Invalid e-mail address.');

      utl_smtp.quit(v_connection);
      raise_application_error(-20000, 'Invalid e-mail address.');
    END IF;*/

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_long_email,
                  ods_constants.data_type_long_email,
                  v_log_level + 1,
                  'Setting all the Date, From, To and Subject information.');
    -- Build the message to include all the important stuff
    v_message := 'From: '     || v_sender    ||
                 utl_tcp.crlf || 'Subject: ' || i_subject   ||
                 utl_tcp.crlf || 'To: '      || i_recipient ||
                 utl_tcp.crlf || utl_tcp.crlf;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_long_email,
                  ods_constants.data_type_long_email,
                  v_log_level + 1,
                 'Opening and writting to the smtp data connection.');
    -- Open the data connection
    utl_smtp.open_data(v_connection);


    -- Send the basic data to the server
    utl_smtp.write_data(v_connection, v_message);
    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_long_email,
                  ods_constants.data_type_long_email,
                  v_log_level,
                  'Finished Start Long e-mail.');

  EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        utl_smtp.quit(v_connection);
      EXCEPTION
        WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
          NULL;
          -- When the SMTP server is down or unavailable, we don't have
          -- a connection to the server. The quit call will raise an
          -- exception that we can ignore.
      END;
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
      RAISE_APPLICATION_ERROR(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);

    WHEN others THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR START_LONG_EMAIL.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
  END start_long_email;



  PROCEDURE append_to_long_email(
    i_message   IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- VARIABLES
    v_reply     utl_smtp.reply;
    v_log_level ods.log.log_level%TYPE := 0;

  BEGIN
    v_log_level := i_log_level;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_long_email,
                  ods_constants.data_type_long_email,
                  v_log_level,
                  'Appending a message line to a long e-mail.');
    -- Send the basic data to the server
    utl_smtp.write_data(v_connection, utl_tcp.crlf || i_message);

  EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        utl_smtp.quit(v_connection);
      EXCEPTION
        WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
          NULL;
          -- When the SMTP server is down or unavailable, we don't have
          -- a connection to the server. The quit call will raise an
          -- exception that we can ignore.
      END;
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
      RAISE_APPLICATION_ERROR(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);

    WHEN others THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR APPEND_TO_LONG_EMAIL.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
  END append_to_long_email;



  PROCEDURE append_log_to_long_email(
    i_session_id    IN ods.log.session_id%TYPE,
    i_max_log_level IN ods.log.log_level%TYPE DEFAULT 10
    ) IS

    --VARIABLES
    v_spaces        VARCHAR2(2000);
    v_max_log_level ods.log.log_level%TYPE;

    --CURSORS
    CURSOR csr_get_log IS
      SELECT
        B.job_type_desc,
        A.data_type,
        A.sort_field,
        A.log_level,
        A.log_text,
        A.log_lupdt
      FROM
        log      A,
        job_type B
      WHERE
        A.job_type_code = B.job_type_code
        AND session_id = i_session_id
        AND log_level <= v_max_log_level
      ORDER BY
        log_seq;
    rv_get_log csr_get_log%ROWTYPE;

  BEGIN

    IF (i_max_log_level < 0) THEN
      v_max_log_level := 0;
    ELSE
      v_max_log_level := i_max_log_level;
    END IF;

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
        utl_smtp.quit(v_connection);
      EXCEPTION
        WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
          NULL;
          -- When the SMTP server is down or unavailable, we don't have
          -- a connection to the server. The quit call will raise an
          -- exception that we can ignore.
      END;
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
      RAISE_APPLICATION_ERROR(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);

    WHEN others THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR APPEND_LOG_TO_LONG_EMAIL.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
  END append_log_to_long_email;



  PROCEDURE send_long_email(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- VARIABLES
    v_reply     utl_smtp.reply;
    v_log_level ods.log.log_level%TYPE := 0;

  BEGIN
    v_log_level := i_log_level;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_long_email,
                  ods_constants.data_type_long_email,
                  v_log_level,
                  'Finishing sending a Long e-mail.');

    -- Add the session id to the email tail
    utl_smtp.write_data(v_connection, utl_tcp.crlf || utl_tcp.crlf ||
                                      'Session ID: ' || utils.get_log_session_id);

    -- Now send the email out
    utl_smtp.close_data(v_connection);

    utl_smtp.quit(v_connection);

  EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
      BEGIN
        utl_smtp.quit(v_connection);
      EXCEPTION
        WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
          NULL;
          -- When the SMTP server is down or unavailable, we don't have
          -- a connection to the server. The quit call will raise an
          -- exception that we can ignore.
      END;
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - utl_smtp.transient_error OR utl_smtp.permanent_error occured.');
      RAISE_APPLICATION_ERROR(-20000,
                              'Failed to send mail due to the following error: ' ||
                              sqlerrm);

    WHEN OTHERS THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_long_email,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR SEND_LOG_EMAIL.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
  END send_long_email;



  PROCEDURE send_tivoli_alert(
    i_alert_level   IN VARCHAR2,
    i_message       IN VARCHAR2,
    i_job_type_code IN ods.log.job_type_code%TYPE,
    i_company_code  IN company.company_code%TYPE DEFAULT NULL,
    i_log_level     IN ods.log.log_level%TYPE DEFAULT 0
  ) IS

    -- VARIABLES
    v_reply     VARCHAR2(4000);
    v_message   VARCHAR2(4000);
    v_log_level ods.log.log_level%TYPE := 0;

    v_company_time      DATE;
    v_mars_period_day   PLS_INTEGER;
    v_temp_number       PLS_INTEGER;
    v_temp_char         VARCHAR2(1);
    v_send_alert_today  BOOLEAN;
    v_db_name           VARCHAR2(256) := NULL;


    -- CURSORS
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
        AND company_code = i_company_code
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

  BEGIN
    v_log_level := i_log_level;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_tivoli_alert,
                  ods_constants.data_type_tivoli_alert,
                  v_log_level,
                  'Starting Send Tivoli Alert and and checking message ' ||
                  'lengths and alert levels.');

    IF (i_message IS NULL OR LENGTH(i_message) = 0) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_tivoli_alert,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Invalid Tivoli Alert Message.');
      raise_application_error(-20000, 'Invalid Tivoli Alert Message.');
    END IF;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME'))
    INTO
      v_db_name
    FROM
      dual;
    -- Pre-append all basic info
    v_message := 'HOSTNAME: ' || ods_constants.hostname ||
                 ' DATABASE NAME: ' || v_db_name ||
                 '. ' ||
                 i_message;

    -- Make sure that the message is not to long
    v_message := substr(v_message, 1, ods_constants.tivoli_max_message_length);

    IF (i_alert_level   != ods_constants.tivoli_alert_level_fatal
      AND i_alert_level != ods_constants.tivoli_alert_level_critical
      AND i_alert_level != ods_constants.tivoli_alert_level_minor
      AND i_alert_level != ods_constants.tivoli_alert_level_warning
      AND i_alert_level != ods_constants.tivoli_alert_level_harmless
      AND i_alert_level != ods_constants.tivoli_alert_level_unknown) THEN
        utils.ods_log(ods_constants.job_type_utils,
                      ods_constants.data_type_tivoli_alert,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - Invalid Tivoli alert level.');
        raise_application_error(-20000, 'Invalid Tivoli Alert Level.');
    END IF;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_tivoli_alert,
                  ods_constants.data_type_tivoli_alert,
                  v_log_level + 1,
                  'Checking for a valid company.');
    SELECT
      COUNT(*)
    INTO
      v_temp_number
    FROM
      company
    WHERE
      company_code = i_company_code;

    -- So if this is a valid company code, do the rest of the checks
    IF (v_temp_number > 0) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_tivoli_alert,
                    ods_constants.data_type_tivoli_alert,
                    v_log_level + 1,
                    'Company Code valid, getting Timezone offset.');

      v_company_time := utils.get_date_time_at_company(i_company_code, v_log_level + 1);


      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_tivoli_alert,
                    ods_constants.data_type_tivoli_alert,
                    v_log_level + 1,
                    'Getting mars period day number.');
      SELECT
        period_day_num
      INTO
        v_mars_period_day
      FROM
        mars_date
      WHERE
        TRUNC(calendar_date) = TRUNC(v_company_time);


      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_tivoli_alert,
                    ods_constants.data_type_tivoli_alert,
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
        utils.ods_log(ods_constants.job_type_utils,
                      ods_constants.data_type_tivoli_alert,
                      ods_constants.data_type_tivoli_alert,
                      v_log_level + 1,
                      'Sending the alert to the Unix Command Wrapper.');
        v_reply := unix_command_wrapper('/usr/local/bin/isi_wpostemsg -r ' ||
                                        i_alert_level ||
                                        ' -m ""' || v_message ||
                                        '"" application=""MFANZ CDW""' ||
                                        ' interface=""CDW"" hostname='  ||
                                        ods_constants.hostname ||
                                        ' ' || ods_constants.tivoli_class ||
                                        ' ' || ods_constants.tivoli_log_file ||
                                        ' 1> /dev/null 2> /dev/null');

        IF (v_reply = ods_constants.error) THEN
          utils.ods_log(ods_constants.job_type_utils,
                        ods_constants.data_type_tivoli_alert,
                        'ERROR',
                        0,
                        '!!!ERROR!!! - Send Tivoli Alert FAILED.');
            raise_application_error(-20000, 'Send Tivoli Alert FAILED.');
        END IF;

      ELSE
        utils.ods_log(ods_constants.job_type_utils,
                      ods_constants.data_type_tivoli_alert,
                      ods_constants.data_type_tivoli_alert,
                      v_log_level + 1,
                      'No need to send alert today for this company and job type.');
      END IF;

    ELSE
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_tivoli_alert,
                    ods_constants.data_type_tivoli_alert,
                    v_log_level + 1,
                    'Invalid Company Code.');

    END IF;

    utils.ods_log(ods_constants.job_type_utils,
                  ods_constants.data_type_tivoli_alert,
                  ods_constants.data_type_tivoli_alert,
                  v_log_level,
                  'Finished Send Tivoli Alert.');

  EXCEPTION
    WHEN OTHERS THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_tivoli_alert,
                    'ERROR',
                    0,
                    '!!!ERROR111!!! - FATAL ERROR FOR SEND_TIVOLI_ALERT.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      RAISE_APPLICATION_ERROR(-20000, 'Failed to send Tivoli Alert.');
  END send_tivoli_alert;



  FUNCTION get_date_time_at_company(
    i_company_code  IN  company.company_code%TYPE,
    i_log_level     IN  ods.log.log_level%TYPE DEFAULT 0
    ) RETURN DATE IS

    -- LOCAL VARIABLES
    v_log_level              ods.log.log_level%TYPE := 0;
    v_count                  PLS_INTEGER := 0;
    v_company_timezone_code  company.company_timezone_code%TYPE;
    v_company_date_time      DATE;

    -- CURSORS
    CURSOR csr_company IS
      SELECT
        COUNT(company_code)
      FROM
        company
      WHERE
        company_code = i_company_code;

  BEGIN
    v_log_level := i_log_level;

    utils.ods_log(ods_constants.job_type_utils,
            ods_constants.data_type_comp_date_time,
            'N/A',
            v_log_level,
            'Starting Get Company Date and Time.');
    v_log_level := v_log_level + 1;


    utils.ods_log(ods_constants.job_type_utils,
            ods_constants.data_type_comp_date_time,
            'N/A',
            v_log_level,
            'Making sure that the Company exists.');
    OPEN csr_company;
    FETCH csr_company INTO v_count;
    CLOSE csr_company;

    -- Make sure that something was returned
    IF (v_count < 1) THEN
      utils.ods_log(ods_constants.job_type_utils,
              ods_constants.data_type_comp_date_time,
              'ERROR',
              0,
              '!!!ERROR!!! - Company Code does not exist.');
      RAISE_APPLICATION_ERROR(-20000, 'Invalid Company Code.');
    END IF;

    utils.ods_log(ods_constants.job_type_utils,
            ods_constants.data_type_comp_date_time,
            'N/A',
            v_log_level,
            'Getting the Company Local Date and Time.');
    SELECT
      company_timezone_code
    INTO
      v_company_timezone_code
    FROM
      company
    WHERE
      company_code = i_company_code;

    v_company_date_time := TZ_CONV_DATE_TIME(sysdate,
                                ods_constants.db_timezone,
                                v_company_timezone_code);

    v_log_level := v_log_level - 1;
    utils.ods_log(ods_constants.job_type_utils,
            ods_constants.data_type_comp_date_time,
            'N/A',
            v_log_level,
            'Finished Get Company Date and Time.');

    RETURN v_company_date_time;

  EXCEPTION
    WHEN OTHERS THEN
      utils.ods_log(ods_constants.job_type_utils,
              ods_constants.data_type_comp_date_time,
              'ERROR',
              0,
              '!!!ERROR!!! - FATAL GET_DATE_TIME_AT_COMPANY.' ||
              ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      IF (csr_company%ISOPEN) THEN
        CLOSE csr_company;
      END IF;

      RAISE_APPLICATION_ERROR(-20000, '!!!ERROR!!! - FATAL GET_DATE_TIME_AT_COMPANY.' ||
                             ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
  END get_date_time_at_company;




  PROCEDURE put_file_on_queue(
    i_source_filename      IN VARCHAR2,
    i_source_system        IN VARCHAR2,
    i_destination_filename IN VARCHAR2,
    i_destination_system   IN VARCHAR2,
    i_log_level            IN ods.log.log_level%TYPE DEFAULT 0
  ) IS

    -- VARIABLES
    v_log_level ods.log.log_level%TYPE;
    v_temp      VARCHAR2(4000);

  BEGIN
    v_log_level := i_log_level;

    utils.ods_log(ods_constants.job_type_utils,
                  'N/A',
                  'N/A',
                  v_log_level,
                  'Starting Put File On Queue.');
    v_Log_level := v_log_level + 1;

    utils.ods_log(ods_constants.job_type_utils,
                  'N/A',
                  'N/A',
                  v_log_level,
                  'Checking that Complete Filename and Path is valid.');
    IF (LENGTH(i_source_filename) = 0 OR i_source_filename IS NULL) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    'N/A',
                    'ERROR',
                    0,
                    '!!!ERROR!!! - INVALID SOURCE FILENAME AND/OR PATH.');
      RAISE_APPLICATION_ERROR(-20000, 'Invalid Source Filename.');
    END IF;
    IF (LENGTH(i_destination_filename) = 0 OR i_destination_filename IS NULL) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    'N/A',
                    'ERROR',
                    0,
                    '!!!ERROR!!! - INVALID DESTINATION FILENAME AND/OR PATH.');
      RAISE_APPLICATION_ERROR(-20000, 'Invalid Destination Filename.');
    END IF;

    utils.ods_log(ods_constants.job_type_utils,
                  'N/A',
                  'N/A',
                  v_log_level,
                  'Loading file onto queue: /opt/mqft/prod/bin/mqftssnd ' ||
                                         '-source ' || i_source_system ||
                                         ',' || i_source_filename ||
                                         ' -target ' || i_destination_system ||
                                         ',' || i_destination_filename);
    v_temp := utils.unix_command_wrapper('/opt/mqft/prod/bin/mqftssnd ' ||
                                         '-source ' || i_source_system ||
                                         ',' || i_source_filename ||
                                         ' -target ' || i_destination_system ||
                                         ',' || i_destination_filename,
                                         v_log_level + 1);
    IF (v_temp = ods_constants.error) THEN
      raise_application_error(-20000, 'mqftssnd command failed.');
    ELSE
      utils.ods_log(ods_constants.job_type_utils,
                  'N/A',
                  'N/A',
                  v_log_level,
                  'Return Text: ' || v_temp);
    END IF;

    v_log_level := v_log_level - 1;
    utils.ods_log(ods_constants.job_type_utils,
                  'N/A',
                  'N/A',
                  v_log_level,
                  'Finished Put File On Queue.');

  EXCEPTION
    WHEN OTHERS THEN
      utils.ods_log(ods_constants.job_type_utils,
                    'N/A',
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL PUT_FILE_ON_QUEUE.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
       raise_application_error(-20000, 'mqftssnd command failed.');
  END put_file_on_queue;



  PROCEDURE clear_validation_reason (
    i_valdtn_type_code valdtn_reasn_hdr.valdtn_type_code%TYPE,
    i_item_code_1      valdtn_reasn_hdr.item_code_1%TYPE,
    i_item_code_2      valdtn_reasn_hdr.item_code_2%TYPE DEFAULT NULL,
    i_item_code_3      valdtn_reasn_hdr.item_code_3%TYPE DEFAULT NULL,
    i_item_code_4      valdtn_reasn_hdr.item_code_4%TYPE DEFAULT NULL,
    i_item_code_5      valdtn_reasn_hdr.item_code_5%TYPE DEFAULT NULL,
    i_item_code_6      valdtn_reasn_hdr.item_code_6%TYPE DEFAULT NULL,
    i_log_level        ods.log.log_level%TYPE DEFAULT 0) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLES
    v_validation_reason_hdr_code  valdtn_reasn_hdr.valdtn_reasn_hdr_code%TYPE;

    v_temp_number PLS_INTEGER            := NULL;
    v_log_level   ods.log.log_level%TYPE := 0;

    -- CURSOR
    CURSOR csr_valdtn_reasn_hdr_code IS
      SELECT
        valdtn_reasn_hdr_code
      FROM
        valdtn_reasn_hdr
      WHERE
        valdtn_type_code = i_valdtn_type_code
        AND item_code_1 = i_item_code_1
        AND DECODE(item_code_2, i_item_code_2, 1, 0) = 1
        AND DECODE(item_code_3, i_item_code_3, 1, 0) = 1
        AND DECODE(item_code_4, i_item_code_4, 1, 0) = 1
        AND DECODE(item_code_5, i_item_code_5, 1, 0) = 1
        AND DECODE(item_code_6, i_item_code_6, 1, 0) = 1;

  BEGIN

    -- Initialising variables
    v_temp_number := NULL;

    -- Check to make sure that the item type code is a valid code.
    SELECT
      COUNT(*)
    INTO
      v_temp_number
    FROM
      valdtn_type
    WHERE
      valdtn_type_code = i_valdtn_type_code;

    IF (v_temp_number IS NULL) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_clear_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Validation Type Code: ' || i_valdtn_type_code ||
                    ' is not valid. Exiting.');

      RAISE_APPLICATION_ERROR(-20000,
                              'Validation Type Code: ' || i_valdtn_type_code ||
                              ' is not valid.');
    END IF;


    -- Make sure that i_item_code_1 is populated with a value (i.e. not null)
    IF (i_item_code_1 IS NULL OR LENGTH(i_item_code_1) < 1) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_clear_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Invalid Item Code 1: ' || i_item_code_1 || '. ' ||
                    'Item Code 1 must be populated. Exiting.');

      RAISE_APPLICATION_ERROR(-20000,
                              'Invalid Item Code 1: ' || i_item_code_1 || '. ' ||
                              'Item Code 1 must be populated.');
    END IF;


    -- Get the surrogate key from the Item Key table for the item type and it's code(s)
    OPEN csr_valdtn_reasn_hdr_code;
    FETCH csr_valdtn_reasn_hdr_code INTO v_validation_reason_hdr_code;
    CLOSE csr_valdtn_reasn_hdr_code;

    -- Make sure that there is actually something to do.
    IF (v_validation_reason_hdr_code IS NOT NULL) THEN

      -- Clear the reason table
      DELETE FROM
        valdtn_reasn_dtl
      WHERE
        valdtn_reasn_hdr_code = v_validation_reason_hdr_code;

      -- Clear the code table
      DELETE FROM
        valdtn_reasn_hdr
      WHERE
        valdtn_reasn_hdr_code = v_validation_reason_hdr_code;

      COMMIT;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_clear_valdtn_reasn,
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
    i_valdtn_type_code valdtn_reasn_hdr.valdtn_type_code%TYPE,
    i_message          valdtn_reasn_dtl.valdtn_reasn_dtl_msg%TYPE,
    i_severity         valdtn_reasn_dtl.valdtn_reasn_dtl_svrty%TYPE,
    i_item_code_1      valdtn_reasn_hdr.item_code_1%TYPE,
    i_item_code_2      valdtn_reasn_hdr.item_code_2%TYPE DEFAULT NULL,
    i_item_code_3      valdtn_reasn_hdr.item_code_3%TYPE DEFAULT NULL,
    i_item_code_4      valdtn_reasn_hdr.item_code_4%TYPE DEFAULT NULL,
    i_item_code_5      valdtn_reasn_hdr.item_code_5%TYPE DEFAULT NULL,
    i_item_code_6      valdtn_reasn_hdr.item_code_6%TYPE DEFAULT NULL,
    i_log_level        ods.log.log_level%TYPE DEFAULT 0) IS


    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLES
    v_get_new_id  BOOLEAN                := true;
    v_temp_number PLS_INTEGER            := NULL;
    v_log_level   ods.log.log_level%TYPE := 0;

    -- CURSOR
    CURSOR csr_valdtn_reasn_hdr_code IS
      SELECT
        valdtn_reasn_hdr_code
      FROM
        valdtn_reasn_hdr
      WHERE
        valdtn_type_code = i_valdtn_type_code
        AND item_code_1 = i_item_code_1
        AND DECODE(item_code_2, i_item_code_2, 1, 0) = 1
        AND DECODE(item_code_3, i_item_code_3, 1, 0) = 1
        AND DECODE(item_code_4, i_item_code_4, 1, 0) = 1
        AND DECODE(item_code_5, i_item_code_5, 1, 0) = 1
        AND DECODE(item_code_6, i_item_code_6, 1, 0) = 1;


  BEGIN

    -- Initialising variables
    v_temp_number := NULL;


    --Check to make sure that the item type code is a valid code.
    SELECT
      COUNT(*)
    INTO
      v_temp_number
    FROM
      valdtn_type
    WHERE
      valdtn_type_code = i_valdtn_type_code;

    IF (v_temp_number IS NULL) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_add_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Validation Type Code: ' || i_valdtn_type_code ||
                    ' is not valid. Exiting.');

      RAISE_APPLICATION_ERROR(-20000,
                              'Validation Type Code: ' || i_valdtn_type_code ||
                              ' is not valid.');
    END IF;


    --Make sure that the message is not null and is greater than 0 characters
    IF (i_message IS NULL OR LENGTH(i_message) < 1) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_add_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Invalid Message: ' || i_message || '. ' ||
                    'Message must be populated. Exiting.');

      RAISE_APPLICATION_ERROR(-20000,
                              'Invalid Message: ' || i_message || '. ' ||
                              'Message must be populated.');
    END IF;


    --Make sure that the severity is either WARNING or CRITICAL.
    IF (i_severity <> ods_constants.valdtn_severity_critical AND
        i_severity <> ods_constants.valdtn_severity_warning) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_add_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Invalid Severity: ' || i_severity || '. ' ||
                    'Exiting.');

      RAISE_APPLICATION_ERROR(-20000,
                              'Invalid Severity: ' || i_severity || '.');
    END IF;



    --Make sure that i_item_code_1 is populated with a value (i.e. not null)
    IF (i_item_code_1 IS NULL OR LENGTH(i_item_code_1) < 1) THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_add_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Invalid Item Code 1: ' || i_item_code_1 || '. ' ||
                    'Item Code 1 must be populated. Exiting.');

      RAISE_APPLICATION_ERROR(-20000,
                              'Invalid Item Code 1: ' || i_item_code_1 || '. ' ||
                              'Item Code 1 must be populated.');
    END IF;


    -- Check to see if the item type has changed
    IF (i_valdtn_type_code = v_valdtn_type_code) THEN

      IF (i_item_code_1 = v_item_code_1
      AND NVL(i_item_code_2, 0) = NVL(v_item_code_2, 0)
      AND NVL(i_item_code_3, 0) = NVL(v_item_code_3, 0)
      AND NVL(i_item_code_4, 0) = NVL(v_item_code_4, 0)
      AND NVL(i_item_code_5, 0) = NVL(v_item_code_5, 0)
      AND NVL(i_item_code_6, 0) = NVL(v_item_code_6, 0)) THEN
        v_get_new_id           := false;
        v_valdtn_reasn_dtl_seq := v_valdtn_reasn_dtl_seq + 1;
      END IF;
    END IF;

    IF (v_get_new_id) THEN

      -- If Item Type has changed, create a new entry in the ods.valdtn_reasn_hdr table and get it's surrogate key.
      -- Add this item to the Item Key table
      INSERT INTO
        valdtn_reasn_hdr
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

      -- Get the surrogate key from the Item Key table for the item type and it's code(s)
      OPEN csr_valdtn_reasn_hdr_code;
      FETCH csr_valdtn_reasn_hdr_code INTO v_valdtn_reasn_hdr_code;
      CLOSE csr_valdtn_reasn_hdr_code;


      -- Now set the global variables
      v_valdtn_type_code     := i_valdtn_type_code;
      v_item_code_1          := i_item_code_1;
      v_item_code_2          := i_item_code_2;
      v_item_code_3          := i_item_code_3;
      v_item_code_4          := i_item_code_4;
      v_item_code_5          := i_item_code_5;
      v_item_code_6          := i_item_code_6;
      v_valdtn_reasn_dtl_seq := 1;
    END IF;

    -- Check to make sure that the above went OK
    IF (v_valdtn_reasn_hdr_code IS NOT NULL) THEN

      BEGIN
        INSERT INTO
          valdtn_reasn_dtl
          (
           valdtn_reasn_hdr_code,
           valdtn_reasn_dtl_seq,
           valdtn_reasn_dtl_msg,
           valdtn_reasn_dtl_svrty
          )
        VALUES
          (
           v_valdtn_reasn_hdr_code,
           v_valdtn_reasn_dtl_seq,
           i_message,
           i_severity
          );

      EXCEPTION
        -- Report error and rollback
        WHEN OTHERS THEN
          utils.ods_log(ods_constants.job_type_utils,
                        ods_constants.data_type_add_valdtn_reasn,
                        'ERROR',
                        0,
                        '!!!ERROR!!! - Failed to insert validation reason. Exiting.');

          RAISE_APPLICATION_ERROR(-20000,
                                  'Failed to insert validation reason.');

      END;

    ELSE
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_add_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - Could not find Validtion Reason Header Code. Exiting.');

      RAISE_APPLICATION_ERROR(-20000,
                              'Could not find Validtion Reason Header Code.');
    END IF;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      utils.ods_log(ods_constants.job_type_utils,
                    ods_constants.data_type_add_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ADD_VALIDATION_REASON.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20000,
                              'Failed to add validation reason: ' ||
                              sqlerrm);

  END add_validation_reason;


  FUNCTION tz_conv_date_time (
    i_from_date     IN DATE,
    i_from_timezone IN V$TIMEZONE_NAMES.TZNAME%TYPE,
    i_to_timezone   IN V$TIMEZONE_NAMES.TZNAME%TYPE
    )
  RETURN DATE IS

    -- VARIABLES
    v_converted_date DATE;
    v_count          PLS_INTEGER := 0;

  BEGIN
    -- Now work out the time at the destination country

    SELECT
      i_from_date - numtodsinterval(DECODE(SUBSTR(TZ_OFFSET(i_from_timezone), 1, 1), '+', 1, -1) *
                                  ((TO_NUMBER(SUBSTR(TZ_OFFSET(i_from_timezone), 2, 2)) * 60) +
                                    TO_NUMBER(SUBSTR(TZ_OFFSET(i_from_timezone), 5, 2))), 'MINUTE')
                  + numtodsinterval(DECODE(SUBSTR(TZ_OFFSET(i_to_timezone), 1, 1), '+', 1, -1) *
                                  ((TO_NUMBER(SUBSTR(TZ_OFFSET(i_to_timezone), 2, 2)) * 60) +
                                    TO_NUMBER(SUBSTR(TZ_OFFSET(i_to_timezone), 5, 2))),'MINUTE')
    INTO
      v_converted_date
    FROM
      DUAL;

    RETURN v_converted_date;

  END tz_conv_date_time;


  FUNCTION get_period_diff (
    i_yyyypp1  IN NUMBER,
    i_yyyypp2  IN NUMBER    
    ) 
  RETURN NUMBER IS

    -- VARIABLES
    v_period_diff NUMBER := NULL;

  BEGIN
    v_period_diff := (trunc(i_yyyypp1 / 100 ) * 13 + mod(i_yyyypp1, 100 ) - 1 ) - ( trunc(i_yyyypp2 / 100 ) * 13 + mod(i_yyyypp2, 100 ) - 1);

    RETURN v_period_diff;

  END get_period_diff;


  FUNCTION remove_chars (
    i_matl_code IN VARCHAR2
    )
  RETURN NUMBER IS
 
  -- VARIABLE DECLARATIONS
  v_matl_code     VARCHAR2(18);
  v_matl_num_code VARCHAR2(18);
  v_matl_length   NUMBER;
  v_start_length  NUMBER;
  i NUMBER;   

  BEGIN
    v_matl_length := LENGTH(i_matl_code);
    v_matl_code := i_matl_code;
    v_start_length := 1;

    v_matl_num_code := SUBSTR(v_matl_code, v_start_length, v_matl_length);    
    -- Loop to strip off all char characters from the front of a string.
    FOR i IN v_start_length..v_matl_length LOOP     

      IF SIGN(INSTR('1234567890', SUBSTR(v_matl_num_code, 1,1))) = '1' THEN        
        EXIT;
      END IF;

      v_matl_num_code := SUBSTR(v_matl_num_code, 2, LENGTH(v_matl_num_code));          

    END LOOP;

    RETURN TO_NUMBER(v_matl_num_code);

  END remove_chars;

BEGIN
  -- Initialise the file ID Variable. It has to be performed in this block down
  -- the bottom to ensure that the there is not an open file when the session
  -- is first created.
  v_extract_file_num.ID   := NULL;
  v_log_debug             := FALSE;

  -- For validation globals
  v_valdtn_type_code      := NULL;
  v_valdtn_reasn_hdr_code := NULL;
  v_item_code_1           := NULL;
  v_item_code_2           := NULL;
  v_item_code_3           := NULL;
  v_item_code_4           := NULL;
  v_item_code_5           := NULL;
  v_item_code_6           := NULL;
  v_valdtn_reasn_dtl_seq  := NULL;

END utils; 
/

