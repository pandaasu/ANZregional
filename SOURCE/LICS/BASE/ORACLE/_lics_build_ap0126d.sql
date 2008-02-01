/******************************************************************/
/* System  : LICS                                                 */
/* Object  : _lics_build_ap0126d                                  */
/* Author  : Steve Gregan                                         */
/* Date    : August 2007                                          */
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
define tab_path = C:\ISI_REPOSITORY\SOURCE\ISI_LICS\BASE\ORACLE\LICS\TABLE
define pro_path = C:\ISI_REPOSITORY\SOURCE\ISI_LICS\BASE\ORACLE\LICS_APP\CODE
define spl_path = C:\ISI_REPOSITORY\SOURCE\ISI_LICS\BASE\ORACLE
define database = ap0126d.ap.mars
define datauser = lics
define data_password = licpop
define codeuser = lics_app
define code_password = licice

/**/
/* Start the spool process
/**/
spool ^spl_path\_lics_build_ap0126d.log

/**/
/* Compile the tables
/**/
prompt CONNECTING (LICS) ...

connect ^datauser/^data_password@^database

prompt CREATING LICS TABLES ...

@^tab_path\lics_das_code.sql;
@^tab_path\lics_das_group.sql;
@^tab_path\lics_das_system.sql;
@^tab_path\lics_das_value.sql;
@^tab_path\lics_data.sql;
@^tab_path\lics_dta_message.sql;
@^tab_path\lics_event.sql;
@^tab_path\lics_group.sql;
@^tab_path\lics_grp_interface.sql;
@^tab_path\lics_hdr_message.sql;
@^tab_path\lics_hdr_search.sql;
@^tab_path\lics_hdr_trace.sql;
@^tab_path\lics_header.sql;
@^tab_path\lics_interface.sql;
@^tab_path\lics_int_reference.sql;
@^tab_path\lics_int_sequence.sql;
@^tab_path\lics_job.sql;
@^tab_path\lics_job_trace.sql;
@^tab_path\lics_lock.sql;
@^tab_path\lics_log.sql;
@^tab_path\lics_pro_check.sql;
@^tab_path\lics_pro_group.sql;
@^tab_path\lics_pro_process.sql;
@^tab_path\lics_pro_trace.sql;
@^tab_path\lics_routing.sql;
@^tab_path\lics_rtg_detail.sql;
@^tab_path\lics_sec_link.sql;
@^tab_path\lics_sec_menu.sql;
@^tab_path\lics_sec_option.sql;
@^tab_path\lics_sec_user.sql;
@^tab_path\lics_sequence.sql;
@^tab_path\lics_setting.sql;
@^tab_path\lics_temp.sql;
@^tab_path\lics_triggered.sql;

prompt CREATING LICS CONSTRAINTS ...

@^tab_path\_create_constraints.sql;

prompt CREATING LICS INDEXES ...

@^tab_path\_create_indexes.sql;

/**/
/* Compile the stored procedures
/**/
prompt CONNECTING (LICS_APP) ...

connect ^codeuser/^code_password@^database

prompt CREATING LICS_APP PROCEDURES ...

@^pro_path\lics_constant.sql;
@^pro_path\lics_parameter_ap0126d.sql;
@^pro_path\lics_pipe.sql;
@^pro_path\lics_file.sql;
@^pro_path\lics_notification.sql;
@^pro_path\lics_locking.sql;
@^pro_path\lics_logging.sql;
@^pro_path\lics_outbound_loader.sql;
@^pro_path\lics_outbound_processor.sql;
@^pro_path\lics_passthru_loader.sql;
@^pro_path\lics_passthru_processor.sql;
@^pro_path\lics_inbound_loader.sql;
@^pro_path\lics_inbound_processor.sql;
@^pro_path\lics_inbound_utility.sql;
@^pro_path\lics_trigger_loader.sql;
@^pro_path\lics_trigger_processor.sql;
@^pro_path\lics_trigger_submitter.sql;
@^pro_path\lics_daemon_processor.sql;
@^pro_path\lics_poller_processor.sql;
@^pro_path\lics_job_control.sql;
@^pro_path\lics_job_processor.sql;
@^pro_path\lics_buffer.sql;
@^pro_path\lics_datastore.sql;
@^pro_path\lics_documentation.sql;
@^pro_path\lics_file_search.sql;
@^pro_path\lics_form.sql;
@^pro_path\lics_group_configuration.sql;
@^pro_path\lics_interface_configuration.sql;
@^pro_path\lics_interface_process.sql;
@^pro_path\lics_interface_search.sql;
@^pro_path\lics_interface_view.sql;
@^pro_path\lics_job_configuration.sql;
@^pro_path\lics_mailer.sql;
@^pro_path\lics_measure.sql;
@^pro_path\lics_processing.sql;
@^pro_path\lics_purging.sql;
@^pro_path\lics_remote_loader.sql;
@^pro_path\lics_router.sql;
@^pro_path\lics_routing_configuration.sql;
@^pro_path\lics_sap_processor.sql;
@^pro_path\lics_schedule_next.sql;
@^pro_path\lics_security_type.sql;
@^pro_path\lics_security.sql;
@^pro_path\lics_security_configuration.sql;
@^pro_path\lics_setting_configuration.sql;
@^pro_path\lics_spreadsheet.sql;
@^pro_path\lics_time.sql;

/**/
/* Undefine the work variables
/**/
undefine tab_path
undefine pro_path
undefine spl_path
undefine database
undefine datauser
undefine data_password
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