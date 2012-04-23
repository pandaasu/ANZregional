/******************************************************************/
/* System  : QVI                                                  */
/* Object  : _qvi_qvapp__build                                    */
/* Author  : Steve Gregan                                         */
/* Date    : March 2012                                           */
/*                                                                */
/******************************************************************/

/*----------------------------------*/
/* MUST BE CONNECTED AS USER QV_APP */
/*----------------------------------*/

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
define obj_path = C:\ISI_SVN\regional\SOURCE\QV\BASE\ORACLE\QV_APP
define spl_path = C:\ISI_SVN\regional\SOURCE\QV\BASE\ORACLE

/*-*/
/* Start the spool process
/*-*/
spool ^spl_path\_qvi_qvapp_build.log

/*-*/
/* Compile the tables
/*-*/
prompt CREATING QVI QV_APP OBJECTS ...

@^obj_path\qvi_dim_type.sql;
@^obj_path\qvi_fac_type.sql;
@^obj_path\qvi_src_type.sql;
@^obj_path\qvi_dim_function.sql;
@^obj_path\qvi_fac_function.sql;
@^obj_path\qvi_src_function.sql;
--@^obj_path\qvi_das_poller.sql;

/*-*/
/* Undefine the work variables
/*-*/
undefine obj_path
undefine spl_path

/*-*/
/* Stop the spool process
/*-*/
spool off;

/*-*/
/* Set the define character
/*-*/
set define &;