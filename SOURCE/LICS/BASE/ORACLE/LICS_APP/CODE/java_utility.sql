/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : java_utility
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Utility

 The package implements the local interface utilities.

 1. Execute external procedure will execute an operating system command and raise
    an exception with any generated standard error information.

 2. Execute external function will execute an operating system command and return
    any generated standard out information or raise an exception with any generated
    standard error information.

 3. The command string is parsed as a space delimted string. Double quotes can be
    used to define a parameter with embedded spaces. Any embedded double quotes
    within a quoted parameter must appear as a pair (eg. "xxxx""xxxx").

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2011/12   Ben Halicki	  Updated java class path for V2

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package java_utility as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_external_procedure(par_command in varchar2);
   function execute_external_function(par_command in varchar2) return varchar2;

end java_utility;
/

/****************/
/* Package Body */
/****************/
create or replace package body java_utility as

   /************************************************************/
   /* This procedure performs the external procedure execution */
   /************************************************************/
   procedure execute_external_procedure(par_command in varchar2)
      as language java name 'com.isi.ics.ExternalProcess.executeProcedure(java.lang.String)';

   /**********************************************************/
   /* This function performs the external function execution */
   /**********************************************************/
   function execute_external_function(par_command in varchar2) return varchar2
      as language java name 'com.isi.ics.ExternalProcess.executeFunction(java.lang.String) return java.lang.String';

end java_utility;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on java_utility to public;