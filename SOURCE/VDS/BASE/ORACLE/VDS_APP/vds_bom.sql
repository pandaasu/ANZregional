/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_bom as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_bom
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Factory BOM Loader

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
   procedure clear;
   procedure load;

end vds_bom;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_bom as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*********************************************/
   /* This procedure performs the clear routine */
   /*********************************************/
   procedure clear is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the existing data
      /*-*/
      delete from vds.fbom_mast;
      commit;
      delete from vds.fbom_stko;
      commit;
      delete from vds.fbom_stas;
      commit;
      delete from vds.fbom_stpo;
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_BOM - clear - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear;

   /********************************************/
   /* This procedure performs the load routine */
   /********************************************/
   procedure load is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the replacement data
      /*-*/
      insert into vds.fbom_mast select t01.* from vds_app.view_fbom_mast t01;
      commit;
      insert into vds.fbom_stko select t01.* from vds_app.view_fbom_stko t01;
      commit;
      insert into vds.fbom_stas select t01.* from vds_app.view_fbom_stas t01;
      commit;
      insert into vds.fbom_stpo select t01.* from vds_app.view_fbom_stpo t01;
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_BOM - load - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load;

end vds_bom;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_bom for vds_app.vds_bom;
grant execute on vds_app.vds_bom to public;