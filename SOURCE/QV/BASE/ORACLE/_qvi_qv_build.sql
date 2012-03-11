/******************************************************************/
/* System  : QVI                                                  */
/* Object  : _qvi_qv_build                                        */
/* Author  : Steve Gregan                                         */
/* Date    : March 2012                                           */
/*                                                                */
/******************************************************************/

/*------------------------------*/
/* MUST BE CONNECTED AS USER QV */
/*------------------------------*/

/*-*/
/* Set the echo off
/*-*/
set echo off;

/*-*/
/* Set the define character
/*-*/
set define ^;

/*-*/
/* Define the work variables
/*-*/
define tab_path = C:\ISI_SVN\regional\SOURCE\QV\BASE\ORACLE\QV
define spl_path = C:\ISI_SVN\regional\SOURCE\QV\BASE\ORACLE

/*-*/
/* Start the spool process
/*-*/
spool ^spl_path\_qvi_qv_build.log

/*-*/
/* Compile the tables
/*-*/
prompt CREATING QVI QV TABLES ...

@^tab_path\qvi_das_defn.sql;
@^tab_path\qvi_fac_defn.sql;
@^tab_path\qvi_fac_time.sql;
@^tab_path\qvi_fac_part.sql;
@^tab_path\qvi_fac_hedr.sql;
@^tab_path\qvi_fac_data.sql;
@^tab_path\qvi_src_hedr.sql;
@^tab_path\qvi_src_data.sql;
@^tab_path\qvi_dim_defn.sql;
@^tab_path\qvi_dim_data.sql;

/*-*/
/* Undefine the work variables
/*-*/
undefine tab_path
undefine spl_path

/*-*/
/* Stop the spool process
/*-*/
spool off;

/*-*/
/* Set the define character
/*-*/
set define &;