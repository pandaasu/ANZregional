/******************************************************************/
/* System  : LICS                                                 */
/* Object  : _lics_app_build                                      */
/* Author  : Steve Gregan                                         */
/* Date    : August 2011                                          */
/*                                                                */
/******************************************************************/

/**/
/* Set the echo off
/**/
set echo off;

/**/
/* Set the define character
/**/
set define ^;

/**/
/* Define the work variables
/**/
define pro_path = ...local path to repository...\SOURCE\LICS\BASE\ORACLE\LICS_APP\CODE
define spl_path = ...local path to repository...\SOURCE\LICS\BASE\ORACLE\INSTALL\...Installation....\...Environment... (eg. NORTH_ASIA\TEST)
define database = db9999x.ap.mars
define codeuser = lics_app
define code_password = xxxxxx

/**/
/* Start the spool process
/**/
spool ^spl_path\_lics_app_build.log

/**/
/* Compile the stored procedures
/**/
prompt CONNECTING (LICS_APP) ...

connect ^codeuser/^code_password@^database

prompt CREATING LICS_APP PROCEDURES ...

/**/
/* Ensure correct lics_parameter.sql file is used
/**/
@...local path to repository...\SOURCE\LICS\BASE\ORACLE\INSTALL\...Installation....\...Environment...\lics_parameter.sql;
@^pro_path\lics_datastore_configuration_type.sql;
@^pro_path\lics_datastore_type.sql;
@^pro_path\lics_security_type.sql;
@^pro_path\lics_spreadsheet_type.sql;
@^pro_path\lics_stream_type.sql;
@^pro_path\lics_constant.sql;
@^pro_path\lics_documentation.sql;
@^pro_path\lics_buffer.sql;
@^pro_path\lics_file_name.sql;
@^pro_path\lics_file_search.sql;
@^pro_path\lics_form.sql;
@^pro_path\lics_job_configuration.sql;
@^pro_path\lics_group_configuration.sql;
@^pro_path\lics_interface_configuration.sql;
@^pro_path\lics_datastore_configuration.sql;
@^pro_path\lics_routing_configuration.sql;
@^pro_path\lics_security_configuration.sql;
@^pro_path\lics_setting_configuration.sql;
@^pro_path\lics_stream_configuration.sql;
@^pro_path\lics_notification.sql;
@^pro_path\lics_pipe.sql;
@^pro_path\lics_locking.sql;
@^pro_path\lics_logging.sql;
@^pro_path\lics_mailer.sql;
@^pro_path\lics_last_run_control.sql;
@^pro_path\lics_datastore.sql;
@^pro_path\lics_spreadsheet.sql;
@^pro_path\lics_schedule_next.sql;
@^pro_path\lics_schedule_tz.sql;
@^pro_path\lics_time.sql;
@^pro_path\lics_purging.sql;
@^pro_path\lics_security.sql;
@^pro_path\lics_remote_loader.sql;
@^pro_path\lics_interface_search.sql;
@^pro_path\lics_inbound_loader.sql;
@^pro_path\lics_passthru_loader.sql;
@^pro_path\lics_outbound_loader.sql;
@^pro_path\lics_stream_loader.sql;
@^pro_path\lics_trigger_loader.sql;
@^pro_path\lics_trigger_submitter.sql;
@^pro_path\lics_file_processor.sql;
@^pro_path\lics_inbound_processor.sql;
@^pro_path\lics_passthru_processor.sql;
@^pro_path\lics_outbound_processor.sql;
@^pro_path\lics_daemon_processor.sql;
@^pro_path\lics_poller_processor.sql;
@^pro_path\lics_stream_processor.sql;
@^pro_path\lics_trigger_processor.sql;
@^pro_path\lics_sap_processor.sql;
@^pro_path\lics_job_processor.sql;
@^pro_path\lics_file_poller.sql;
@^pro_path\lics_stream_poller.sql;
@^pro_path\lics_inbound_utility.sql;
@^pro_path\lics_processing.sql;
@^pro_path\lics_job_control.sql;
@^pro_path\lics_interface_loader.sql;
@^pro_path\lics_interface_process.sql;
@^pro_path\lics_interface_view.sql;
@^pro_path\lics_file_monitor.sql;
@^pro_path\lics_router.sql;

/**/
/* Undefine the work variables
/**/
undefine pro_path
undefine spl_path
undefine database
undefine codeuser
undefine code_password

/**/
/* Stop the spool process
/**/
spool off;

/**/
/* Set the define character
/**/
set define &;