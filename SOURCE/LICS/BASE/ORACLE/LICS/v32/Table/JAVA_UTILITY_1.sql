--------------------------------------------------------
--  DDL for Package Body JAVA_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "LICS"."JAVA_UTILITY" as

   /************************************************************/
   /* This procedure performs the external procedure execution */
   /************************************************************/
   procedure execute_external_procedure(par_command in varchar2)
      as language java name 'com.isi.ics.cExternalProcess.executeProcedure(java.lang.String)';

   /**********************************************************/
   /* This function performs the external function execution */
   /**********************************************************/
   function execute_external_function(par_command in varchar2) return varchar2
      as language java name 'com.isi.ics.cExternalProcess.executeFunction(java.lang.String) return java.lang.String';

end java_utility;

/
