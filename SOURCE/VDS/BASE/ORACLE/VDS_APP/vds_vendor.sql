/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_vendor as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_vendor
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Vendor Loader

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/

   /**/
   /* Public declarations
   /**/
   procedure load;

end vds_vendor;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_vendor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************/
   /* This procedure performs the load routine */
   /********************************************/
   procedure load is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      var_query := upper(par_query);

      /*-*/
      /* Delete the existing data
      /*-*/
      delete from vds.vendor_lfa1 where (matnr) in (select lifnr from vds_app.view_vendor_lfa1);
      commit;
      delete from vds.vendor_lfb1 where (matnr) in (select lifnr from vds_app.view_vendor_lfa1);
      commit;
      delete from vds.vendor_lfbk where (matnr) in (select lifnr from vds_app.view_vendor_lfa1);
      commit;
      delete from vds.vendor_lfm1 where (matnr) in (select lifnr from vds_app.view_vendor_lfa1);
      commit;
      delete from vds.vendor_lfm2 where (matnr) in (select lifnr from vds_app.view_vendor_lfa1);
      commit;
      delete from vds.vendor_wyt3 where (matnr) in (select lifnr from vds_app.view_vendor_lfa1);
      commit;

      /*-*/
      /* Insert the replacement data
      /*-*/
      insert into vds.vendor_lfa1 select t01.* from vds_app.view_vendor_lfa1 t01;
      commit;
      insert into vds.vendor_lfb1 select t01.* from vds_app.view_vendor_lfb1 t01;
      commit;
      insert into vds.vendor_lfbk select t01.* from vds_app.view_vendor_lfbk t01;
      commit;
      insert into vds.vendor_lfm1 select t01.* from vds_app.view_vendor_lfm1 t01;
      commit;
      insert into vds.vendor_lfm2 select t01.* from vds_app.view_vendor_lfm2 t01;
      commit;
      insert into vds.vendor_wyt3 select t01.* from vds_app.view_vendor_wyt3 t01;
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_VENDOR - load - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load;

end vds_vendor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_vendor for vds_app.vds_vendor;
grant execute on vds_app.vds_vendor to public;