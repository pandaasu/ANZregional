/******************************************************************/
/* System  : LICS                                                 */
/* Object  : _lics_build                                          */
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
define tab_path = C:\<PATH>\LICS\TABLE
define spl_path = C:\<PATH>
define database = <DATABASE>.ap.mars
define datauser = lics
define data_password = <PASSWORD>

/**/
/* Start the spool process
/**/
spool ^spl_path\_lics_build.log

/**/
/* Compile the tables
/**/
prompt CONNECTING (LICS) ...

connect ^datauser/^data_password@^database

prompt CREATING LICS TABLES ...

@^tab_path\lics_alert.sql;
@^tab_path\lics_das_code.sql;
@^tab_path\lics_das_group.sql;
@^tab_path\lics_das_system.sql;
@^tab_path\lics_das_value.sql;
@^tab_path\lics_data.sql;
@^tab_path\lics_dta_message.sql;
@^tab_path\lics_event.sql;
@^tab_path\lics_event_sequence.sql;
@^tab_path\lics_execution_sequence.sql;
@^tab_path\lics_file.sql;
@^tab_path\lics_group.sql;
@^tab_path\lics_grp_interface.sql;
@^tab_path\lics_hdr_message.sql;
@^tab_path\lics_hdr_search.sql;
@^tab_path\lics_hdr_trace.sql;
@^tab_path\lics_header.sql;
@^tab_path\lics_header_sequence.sql;
@^tab_path\lics_int_reference.sql;
@^tab_path\lics_int_sequence.sql;
@^tab_path\lics_interface.sql;
@^tab_path\lics_job.sql;
@^tab_path\lics_job_trace.sql;
@^tab_path\lics_last_run.sql;
@^tab_path\lics_lock.sql;
@^tab_path\lics_log.sql;
@^tab_path\lics_log_sequence.sql;
@^tab_path\lics_pro_check.sql;
@^tab_path\lics_pro_group.sql;
@^tab_path\lics_pro_process.sql;
@^tab_path\lics_pro_trace.sql;
@^tab_path\lics_routing.sql;
@^tab_path\lics_rtg_detail.sql;
@^tab_path\lics_sec_interface.sql;
@^tab_path\lics_sec_link.sql;
@^tab_path\lics_sec_menu.sql;
@^tab_path\lics_sec_option.sql;
@^tab_path\lics_sec_user.sql;
@^tab_path\lics_setting.sql;
@^tab_path\lics_str_action.sql;
@^tab_path\lics_str_event.sql;
@^tab_path\lics_str_header.sql;
@^tab_path\lics_str_task.sql;
@^tab_path\lics_str_parameter.sql;
@^tab_path\lics_stream_sequence.sql;
@^tab_path\lics_temp.sql;
@^tab_path\lics_triggered.sql;
@^tab_path\lics_triggered_sequence.sql;

prompt CREATING LICS CONSTRAINTS ...

@^tab_path\_create_constraints.sql;

prompt CREATING LICS INDEXES ...

@^tab_path\_create_indexes.sql;

/**/
/* Undefine the work variables
/**/
undefine tab_path
undefine spl_path
undefine database
undefine datauser
undefine data_password

/**/
/* Stop the spool process
/**/
spool off;

/**/
/* Set the define character
/**/
set define &;