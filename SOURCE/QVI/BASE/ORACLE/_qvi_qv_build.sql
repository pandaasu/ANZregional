/******************************************************************/
/* System  : QVI                                                  */
/* Object  : _qvi_qv_build                                        */
/* Author  : Steve Gregan                                         */
/* Date    : March 2012                                           */
/*                                                                */
/* Modified: April 2012, Mal Chambeyron                           */
/*           Added fact time part (qvi_fac_tpar.sql)              */
/*           and update sequence (qvi_update_sequence.sql)        */
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
define tab_path = D:\DATA\SVN\repository\regional\SOURCE\QVI\BASE\ORACLE\QV
define spl_path = D:\DATA\SVN\repository\regional\SOURCE\QVI\BASE\ORACLE

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
@^tab_path\qvi_fac_tpar.sql;
@^tab_path\qvi_fac_hedr.sql;
@^tab_path\qvi_fac_data.sql;
@^tab_path\qvi_src_hedr.sql;
@^tab_path\qvi_src_data.sql;
@^tab_path\qvi_dim_defn.sql;
@^tab_path\qvi_dim_data.sql;

/*-*/
/* Compile the tables
/*-*/
prompt CREATING QVI UPDATE SEQUENCE ...

@^tab_path\qvi_update_sequence.sql;

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