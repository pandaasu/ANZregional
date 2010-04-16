/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_material as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_material
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Material Loader

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear;
   procedure load;

end vds_material;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_material as

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
      delete from vds.matl_mara;
      commit;
      delete from vds.matl_marm;
      commit;
      delete from vds.matl_makt;
      commit;
      delete from vds.matl_marc;
      commit;
      delete from vds.matl_mvke;
      commit;
      delete from vds.matl_mmoe;
      commit;
      delete from vds.matl_mbew;
      commit;
      delete from vds.matl_mard;
      commit;
      delete from vds.matl_inob;
      commit;
      delete from vds.matl_ausp;
      commit;
      delete from vds.matl_mlgn;
      commit;
      delete from vds.matl_mlan;
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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_MATERIAL - clear - ' || substr(SQLERRM, 1, 1024));

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
      /* Delete the existing data
      /*-*/
      delete from vds.matl_mara where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_marm where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_makt where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_marc where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_mvke where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_mmoe where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_mbew where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_mard where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_inob where (objek) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_ausp where (to_number(objek)) in (select cuobj from vds_app.view_matl_inob where (objek) in (select matnr from vds_app.view_matl_mara));
      commit;
      delete from vds.matl_mlgn where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;
      delete from vds.matl_mlan where (matnr) in (select matnr from vds_app.view_matl_mara);
      commit;

      /*-*/
      /* Insert the replacement data
      /*-*/
      insert into vds.matl_mara select t01.* from vds_app.view_matl_mara t01;
      commit;
      insert into vds.matl_marm select t01.* from vds_app.view_matl_marm t01;
      commit;
      insert into vds.matl_makt select t01.* from vds_app.view_matl_makt t01;
      commit;
      insert into vds.matl_marc select t01.* from vds_app.view_matl_marc t01;
      commit;
      insert into vds.matl_mvke select t01.* from vds_app.view_matl_mvke t01;
      commit;
      insert into vds.matl_mmoe select t01.* from vds_app.view_matl_mmoe t01;
      commit;
      insert into vds.matl_mbew select t01.* from vds_app.view_matl_mbew t01;
      commit;
      insert into vds.matl_mard select t01.* from vds_app.view_matl_mard t01;
      commit;
      insert into vds.matl_inob select t01.* from vds_app.view_matl_inob t01;
      commit;
      insert into vds.matl_ausp select t01.* from vds_app.view_matl_ausp t01;
      commit;
      insert into vds.matl_mlgn select t01.* from vds_app.view_matl_mlgn t01;
      commit;
      insert into vds.matl_mlan select t01.* from vds_app.view_matl_mlan t01;
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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_MATERIAL - load - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load;

end vds_material;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_material for vds_app.vds_material;
grant execute on vds_app.vds_material to public;