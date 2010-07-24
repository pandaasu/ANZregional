/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_extract_execution as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_extract_execution
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Extract Execution

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/07   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end vds_extract_execution;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_extract_execution as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*********************************************/
   /* This procedure performs the clear routine */
   /*********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_procedure varchar2(256);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Run the VDS material extract (data changes only)
      /*-*/
      var_procedure := lics_parameter.script_directory||'vds_extract.sh SAPVDSEXT#22 *DATA1000';
      java_utility.execute_external_procedure(var_procedure);

      /*-*/
      /* Run the VDS customer extract (full extract)
      /*-*/
      var_procedure := lics_parameter.script_directory||'vds_extract.sh SAPVDSEXT#23 *FULL1000';
      java_utility.execute_external_procedure(var_procedure);

      /*-*/
      /* Run the VDS vendor extract (full extract)
      /*-*/
      var_procedure := lics_parameter.script_directory||'vds_extract.sh SAPVDSEXT#24 *FULL1000';
      java_utility.execute_external_procedure(var_procedure);

      /*-*/
      /* Run the VDS BOM and Packaging extracts after the material extract (full extracts)
      /*-*/
      var_procedure := lics_parameter.script_directory||'vds_extract.sh SAPVDSEXT#25 *FULL1000';
      java_utility.execute_external_procedure(var_procedure);
      var_procedure := lics_parameter.script_directory||'vds_extract.sh SAPVDSEXT#26 *FULL1000';
      java_utility.execute_external_procedure(var_procedure);

      /*-*/
      /* Run the VDS reference extract (full extract)
      /*-*/
      var_procedure := lics_parameter.script_directory||'vds_extract.sh SAPVDSEXT#21 *FULL1000';
      java_utility.execute_external_procedure(var_procedure);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_EXTRACT_EXECUTION - execute - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end vds_extract_execution;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_extract_execution for vds_app.vds_extract_execution;
grant execute on vds_app.vds_extract_execution to public;