/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad01_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad01 - Inbound Control Recipe Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad01_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_cntl_rec_id in number);

end lads_atllad01_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad01_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_cntl_rec_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------*/
      /* External procedures */
      /*---------------------*/

      /*-*/
      /* Execute the MANU interface
      /*-*/
      begin
         ics_ladsmanu01.execute(par_cntl_rec_id);
      exception
         when others then
            raise_application_error(-20000, 'Control Recipe (' || to_char(par_cntl_rec_id,'FM999999999999999990') || ')' || chr(13) || substr(SQLERRM, 1, 1024));
      end;

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
         raise_application_error(-20000, 'LADS_ATLLAD01_MONITOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad01_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad01_monitor for lads_app.lads_atllad01_monitor;
grant execute on lads_atllad01_monitor to lics_app;
