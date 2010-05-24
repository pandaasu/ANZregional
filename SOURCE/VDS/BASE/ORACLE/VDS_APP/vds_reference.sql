/******************/
/* Package Header */
/******************/
create or replace package vds_app.vds_reference as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_reference
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - VDS Reference Loader

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/05   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure clear;
   procedure load;

end vds_reference;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_app.vds_reference as

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
      delete from vds.refn_CABN;
      commit;
      delete from vds.refn_CABNT;
      commit;
      delete from vds.refn_CAWN;
      commit;
      delete from vds.refn_CAWNT;
      commit;
      delete from vds.refn_MARSMD_CHC001;
      commit;
      delete from vds.refn_MARSMD_CHC002;
      commit;
      delete from vds.refn_MARSMD_CHC003;
      commit;
      delete from vds.refn_MARSMD_CHC004;
      commit;
      delete from vds.refn_MARSMD_CHC005;
      commit;
      delete from vds.refn_MARSMD_CHC006;
      commit;
      delete from vds.refn_MARSMD_CHC007;
      commit;
      delete from vds.refn_MARSMD_CHC008;
      commit;
      delete from vds.refn_MARSMD_CHC009;
      commit;
      delete from vds.refn_MARSMD_CHC010;
      commit;
      delete from vds.refn_MARSMD_CHC011;
      commit;
      delete from vds.refn_MARSMD_CHC012;
      commit;
      delete from vds.refn_MARSMD_CHC013;
      commit;
      delete from vds.refn_MARSMD_CHC014;
      commit;
      delete from vds.refn_MARSMD_CHC016;
      commit;
      delete from vds.refn_MARSMD_CHC017;
      commit;
      delete from vds.refn_MARSMD_CHC018;
      commit;
      delete from vds.refn_MARSMD_CHC019;
      commit;
      delete from vds.refn_MARSMD_CHC020;
      commit;
      delete from vds.refn_MARSMD_CHC021;
      commit;
      delete from vds.refn_MARSMD_CHC022;
      commit;
      delete from vds.refn_MARSMD_CHC023;
      commit;
      delete from vds.refn_MARSMD_CHC024;
      commit;
      delete from vds.refn_MARSMD_CHC025;
      commit;
      delete from vds.refn_MARSMD_CHC028;
      commit;
      delete from vds.refn_MARSMD_CHC029;
      commit;
      delete from vds.refn_MARSMD_CHC038;
      commit;
      delete from vds.refn_MARSMD_CHC040;
      commit;
      delete from vds.refn_MARSMD_ROH01;
      commit;
      delete from vds.refn_MARSMD_ROH02;
      commit;
      delete from vds.refn_MARSMD_ROH03;
      commit;
      delete from vds.refn_MARSMD_ROH04;
      commit;
      delete from vds.refn_MARSMD_ROH05;
      commit;
      delete from vds.refn_MARSMD_VERP01;
      commit;
      delete from vds.refn_MARSMD_VERP02;
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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_REFERENCE - clear - ' || substr(SQLERRM, 1, 1024));

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
      insert into vds.refn_CABN select t01.* from vds_app.view_refn_CABN t01;
      commit;
      insert into vds.refn_CABNT select t01.* from vds_app.view_refn_CABNT t01;
      commit;
      insert into vds.refn_CAWN select t01.* from vds_app.view_refn_CAWN t01;
      commit;
      insert into vds.refn_CAWNT select t01.* from vds_app.view_refn_CAWNT t01;
      commit;
      insert into vds.refn_MARSMD_CHC001 select t01.* from vds_app.view_refn_MARSMD_CHC001 t01;
      commit;
      insert into vds.refn_MARSMD_CHC002 select t01.* from vds_app.view_refn_MARSMD_CHC002 t01;
      commit;
      insert into vds.refn_MARSMD_CHC003 select t01.* from vds_app.view_refn_MARSMD_CHC003 t01;
      commit;
      insert into vds.refn_MARSMD_CHC004 select t01.* from vds_app.view_refn_MARSMD_CHC004 t01;
      commit;
      insert into vds.refn_MARSMD_CHC005 select t01.* from vds_app.view_refn_MARSMD_CHC005 t01;
      commit;
      insert into vds.refn_MARSMD_CHC006 select t01.* from vds_app.view_refn_MARSMD_CHC006 t01;
      commit;
      insert into vds.refn_MARSMD_CHC007 select t01.* from vds_app.view_refn_MARSMD_CHC007 t01;
      commit;
      insert into vds.refn_MARSMD_CHC008 select t01.* from vds_app.view_refn_MARSMD_CHC008 t01;
      commit;
      insert into vds.refn_MARSMD_CHC009 select t01.* from vds_app.view_refn_MARSMD_CHC009 t01;
      commit;
      insert into vds.refn_MARSMD_CHC010 select t01.* from vds_app.view_refn_MARSMD_CHC010 t01;
      commit;
      insert into vds.refn_MARSMD_CHC011 select t01.* from vds_app.view_refn_MARSMD_CHC011 t01;
      commit;
      insert into vds.refn_MARSMD_CHC012 select t01.* from vds_app.view_refn_MARSMD_CHC012 t01;
      commit;
      insert into vds.refn_MARSMD_CHC013 select t01.* from vds_app.view_refn_MARSMD_CHC013 t01;
      commit;
      insert into vds.refn_MARSMD_CHC014 select t01.* from vds_app.view_refn_MARSMD_CHC014 t01;
      commit;
      insert into vds.refn_MARSMD_CHC016 select t01.* from vds_app.view_refn_MARSMD_CHC016 t01;
      commit;
      insert into vds.refn_MARSMD_CHC017 select t01.* from vds_app.view_refn_MARSMD_CHC017 t01;
      commit;
      insert into vds.refn_MARSMD_CHC018 select t01.* from vds_app.view_refn_MARSMD_CHC018 t01;
      commit;
      insert into vds.refn_MARSMD_CHC019 select t01.* from vds_app.view_refn_MARSMD_CHC019 t01;
      commit;
      insert into vds.refn_MARSMD_CHC020 select t01.* from vds_app.view_refn_MARSMD_CHC020 t01;
      commit;
      insert into vds.refn_MARSMD_CHC021 select t01.* from vds_app.view_refn_MARSMD_CHC021 t01;
      commit;
      insert into vds.refn_MARSMD_CHC022 select t01.* from vds_app.view_refn_MARSMD_CHC022 t01;
      commit;
      insert into vds.refn_MARSMD_CHC023 select t01.* from vds_app.view_refn_MARSMD_CHC023 t01;
      commit;
      insert into vds.refn_MARSMD_CHC024 select t01.* from vds_app.view_refn_MARSMD_CHC024 t01;
      commit;
      insert into vds.refn_MARSMD_CHC025 select t01.* from vds_app.view_refn_MARSMD_CHC025 t01;
      commit;
      insert into vds.refn_MARSMD_CHC028 select t01.* from vds_app.view_refn_MARSMD_CHC028 t01;
      commit;
      insert into vds.refn_MARSMD_CHC029 select t01.* from vds_app.view_refn_MARSMD_CHC029 t01;
      commit;
      insert into vds.refn_MARSMD_CHC038 select t01.* from vds_app.view_refn_MARSMD_CHC038 t01;
      commit;
      insert into vds.refn_MARSMD_CHC040 select t01.* from vds_app.view_refn_MARSMD_CHC040 t01;
      commit;
      insert into vds.refn_MARSMD_ROH01 select t01.* from vds_app.view_refn_MARSMD_ROH01 t01;
      commit;
      insert into vds.refn_MARSMD_ROH02 select t01.* from vds_app.view_refn_MARSMD_ROH02 t01;
      commit;
      insert into vds.refn_MARSMD_ROH03 select t01.* from vds_app.view_refn_MARSMD_ROH03 t01;
      commit;
      insert into vds.refn_MARSMD_ROH04 select t01.* from vds_app.view_refn_MARSMD_ROH04 t01;
      commit;
      insert into vds.refn_MARSMD_ROH05 select t01.* from vds_app.view_refn_MARSMD_ROH05 t01;
      commit;
      insert into vds.refn_MARSMD_VERP01 select t01.* from vds_app.view_refn_MARSMD_VERP01 t01;
      commit;
      insert into vds.refn_MARSMD_VERP02 select t01.* from vds_app.view_refn_MARSMD_VERP02 t01;
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
         raise_application_error(-20000, 'FATAL ERROR - Validation Data Store - VDS_REFERENCE - load - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load;

end vds_reference;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_reference for vds_app.vds_reference;
grant execute on vds_app.vds_reference to public;