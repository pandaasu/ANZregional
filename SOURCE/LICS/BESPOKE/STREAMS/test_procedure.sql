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
   procedure execute(par_error in varchar2);

end test_procedure;
/

/****************/
/* Package Body */
/****************/
create or replace package body test_procedure as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*******************************************************/
   /* This procedure performs the execute process routine */
   /*******************************************************/
   procedure execute(par_error in varchar2) is

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

      /*-*/
      /* Raise the error when requested to test error processing
      /*-*/
      if not(par_error is null) then
         raise_application_error(-20000, par_error);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end test_procedure;
/  