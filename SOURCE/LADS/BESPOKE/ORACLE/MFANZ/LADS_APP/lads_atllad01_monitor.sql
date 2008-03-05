/******************/
/* Package Header */
/******************/
create or replace package lads_atllad01_monitor as

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
    2007/04   Steve Gregan   Included LADS FLATTENING callout
    2007/06   Steve Gregan   Temporary removed BDS flattening call
    2007/08   Steve Gregan   Removed manu call
                             Added site plant interface execution
    2007/10   Steve Gregan   Permanently removed BDS flattening call

   *******************************************************************************/

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

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_hpi is
         select *
           from lads_ctl_rec_hpi t01
          where t01.cntl_rec_id = par_cntl_rec_id;
      rcd_lads_ctl_rec_hpi csr_lads_ctl_rec_hpi%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the control recipe header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_ctl_rec_hpi;
      fetch csr_lads_ctl_rec_hpi into rcd_lads_ctl_rec_hpi;
      if csr_lads_ctl_rec_hpi%notfound then
         raise_application_error(-20000, 'Control Recipe (' || par_cntl_rec_id || ') not found');
      end if;
      close csr_lads_ctl_rec_hpi;

      /*---------------------------*/
      /* 1. LADS transaction logic */
      /*---------------------------*/

      /*-*/
      /* Transaction logic
      /* **note** - changes to the LADS data
      /*-*/

      /*---------------------------*/
      /* 2. Triggered procedures   */
      /*---------------------------*/

      /*-*/
      /* Clear the exception
      /*-*/
      var_exception := null;

      /*-*/
      /* Execute the MANU interface
      /*-*/
      begin
         ics_ladsmanu01.execute(par_cntl_rec_id);
      exception
         when others then
            if var_exception is null then
               var_exception := 'Control Recipe (' || to_char(par_cntl_rec_id,'FM999999999999999990') || ')';
            end if;
            var_exception := var_exception || chr(13) || 'MANU Interface - ' || substr(SQLERRM, 1, 1024);
      end;

      /*-*/
      /* Execute the PLANT interface
      /*-*/
      begin
         plant_process_order_extract(par_cntl_rec_id);
      exception
         when others then
            if var_exception is null then
               var_exception := 'Control Recipe (' || to_char(par_cntl_rec_id,'FM999999999999999990') || ')';
            end if;
            var_exception := var_exception || chr(13) || 'PLANT Interface - ' || substr(SQLERRM, 1, 1024);
      end;

      /*-*/
      /* Process the exception when required
      /*-*/
      if not(var_exception is null) then
         raise_application_error(-20000, var_exception);
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

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
