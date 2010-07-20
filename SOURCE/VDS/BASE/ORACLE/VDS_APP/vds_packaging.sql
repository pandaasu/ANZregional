/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_packaging as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_packaging
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Packaging Instruction Loader

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

end vds_packaging;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_packaging as

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
      delete from vds.mpkg_kotp505;
      commit;
      delete from vds.mpkg_kondp;
      commit;
      delete from vds.mpkg_packpo;
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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_PACKAGING - clear - ' || substr(SQLERRM, 1, 1024));

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
      insert into vds.mpkg_kotp505 select t01.* from vds_app.view_mpkg_kotp505 t01;
      commit;
      insert into vds.mpkg_kondp select t01.* from vds_app.view_mpkg_kondp t01;
      commit;
      insert into vds.mpkg_packpo select t01.* from vds_app.view_mpkg_packpo t01;
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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_PACKAGING - load - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load;

end vds_packaging;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_packaging for vds_app.vds_packaging;
grant execute on vds_app.vds_packaging to public;