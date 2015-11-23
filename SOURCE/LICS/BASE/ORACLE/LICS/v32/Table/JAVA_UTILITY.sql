--------------------------------------------------------
--  DDL for Package JAVA_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "LICS"."JAVA_UTILITY" as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_external_procedure(par_command in varchar2);
   function execute_external_function(par_command in varchar2) return varchar2;

end java_utility;

/
