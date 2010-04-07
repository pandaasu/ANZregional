/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_customer as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_customer
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Customer Loader

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

end vds_customer;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_customer as

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
      /* Delete the existing data
      /*-*/
      delete from vds.cust_kna1 where (kunnr) in (select kunnr from vds_app.view_cust_kna1);
      commit;
      delete from vds.cust_knb1 where (kunnr) in (select kunnr from vds_app.view_cust_kna1);
      commit;
      delete from vds.cust_knvi where (kunnr) in (select kunnr from vds_app.view_cust_kna1);
      commit;
      delete from vds.cust_knvv where (kunnr) in (select kunnr from vds_app.view_cust_kna1);
      commit;

      /*-*/
      /* Insert the replacement data
      /*-*/
      insert into vds.cust_kna1 select t01.* from vds_app.view_cust_kna1 t01;
      commit;
      insert into vds.cust_knb1 select t01.* from vds_app.view_cust_knb1 t01;
      commit;
      insert into vds.cust_knvi select t01.* from vds_app.view_cust_knvi t01;
      commit;
      insert into vds.cust_knvv select t01.* from vds_app.view_cust_knvv t01;
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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_CUSTOMER - load - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load;

end vds_customer;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_customer for vds_app.vds_customer;
grant execute on vds_app.vds_customer to public;