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

   /**/
   /* Public declarations
   /**/
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
      delete from vds.material_mara where (matnr) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_marm where (matnr) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_makt where (matnr) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_marc where (matnr) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_mvke where (matnr) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_mmoe where (matnr) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_mbew where (matnr) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_mard where (matnr) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_inob where (objek) in (select matnr from vds_app.view_material_mara);
      commit;
      delete from vds.material_ausp where (to_number(objek)) in (select cuobj from vds_app.view_material_inob where (objek) in (select matnr from vds_app.view_material_mara));
      commit;

      /*-*/
      /* Insert the replacement data
      /*-*/
      insert into vds.material_mara select t01.* from vds_app.view_material_mara t01;
      commit;
      insert into vds.material_marm select t01.* from vds_app.view_material_marm t01;
      commit;
      insert into vds.material_makt select t01.* from vds_app.view_material_makt t01;
      commit;
      insert into vds.material_marc select t01.* from vds_app.view_material_marc t01;
      commit;
      insert into vds.material_mvke select t01.* from vds_app.view_material_mvke t01;
      commit;
      insert into vds.material_mmoe select t01.* from vds_app.view_material_mmoe t01;
      commit;
      insert into vds.material_mbew select t01.* from vds_app.view_material_mbew t01;
      commit;
      insert into vds.material_mard select t01.* from vds_app.view_material_mard t01;
      commit;
      insert into vds.material_inob select t01.* from vds_app.view_material_inob t01;
      commit;
      insert into vds.material_ausp select t01.* from vds_app.view_material_ausp t01;
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