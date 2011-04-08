/******************************************************************/
/* System  : LICS                                                 */
/* Object  : _sys_build                                           */
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
define pro_path = C:\ISI_SVN\ISI_REGIONAL\SOURCE\LICS\BASE\ORACLE\LICS_APP\CODE
define spl_path = C:\ISI_SVN\ISI_REGIONAL\SOURCE\LICS\BASE\ORACLE
define database = db1252t.ap.mars
define codeuser = sys
define code_password = xxxxxx

/**/
/* Start the spool process
/**/
spool ^spl_path\_sys_build.log

/**/
/* Compile the stored procedures
/**/
prompt CONNECTING SYS) ...

connect ^codeuser/^code_password@^database

prompt CREATING sys PROCEDURES ...

/**/
/* Compile the procedures
/**/
@^pro_path\lics_db_trigger.sql;
@^pro_path\lics_directory.sql;

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