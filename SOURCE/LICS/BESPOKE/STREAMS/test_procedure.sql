/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : test_procedure
 Owner   : lics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Interface Control System - Test Procedure

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/12   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package test_procedure as

   /**/
   /* Public declarations
   /**/
   procedure execute;

end test_procedure;
/

/****************/
/* Package Body */
/****************/
create or replace package body test_procedure as

   /*******************************************************/
   /* This procedure performs the execute process routine */
   /*******************************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_sleep number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Sleep to simulate procedure executing
      /*-*/
      var_sleep := 60;
      for idx in 1..trunc(var_sleep/60) loop
         dbms_lock.sleep(60);
      end loop;
      dbms_lock.sleep(var_sleep-(trunc(var_sleep/60)*60));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end test_procedure;
/  