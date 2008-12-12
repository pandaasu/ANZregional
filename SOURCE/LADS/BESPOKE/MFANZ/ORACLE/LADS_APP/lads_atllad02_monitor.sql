/******************/
/* Package Header */
/******************/
create or replace package lads_atllad02_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_atllad02_monitor
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - atllad02 - Inbound Stock Balance Monitor

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2007/03   Steve Gregan   Included LADS FLATTENING callout
    2008/05   Trevor Keon    Changed to use execute_before and execute_after
    2008/10   Trevor Keon       Removed triggered job for send to plant DBs    

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_bukrs in varchar2,
                     par_werks in varchar2,
                     par_lgort in varchar2,
                     par_budat in varchar2,
                     par_timlo in varchar2);
                     
   procedure execute_after(par_bukrs in varchar2,
                     par_werks in varchar2,
                     par_lgort in varchar2,
                     par_budat in varchar2,
                     par_timlo in varchar2);                     

end lads_atllad02_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad02_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_bukrs in varchar2,
                     par_werks in varchar2,
                     par_lgort in varchar2,
                     par_budat in varchar2,
                     par_timlo in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_stk_bal_hdr is
         select *
           from lads_stk_bal_hdr t01
          where t01.bukrs = par_bukrs
            and t01.werks = par_werks
            and t01.lgort = par_lgort
            and t01.budat = par_budat
            and t01.timlo = par_timlo;
      rcd_lads_stk_bal_hdr csr_lads_stk_bal_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the stock balance header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_stk_bal_hdr;
      fetch csr_lads_stk_bal_hdr into rcd_lads_stk_bal_hdr;
      if csr_lads_stk_bal_hdr%notfound then
         raise_application_error(-20000, 'Stock Balance (' || par_bukrs || ' : ' || par_werks || ' : ' || par_lgort || ' : ' || par_budat || ' : ' || par_timlo || ') not found');
      end if;
      close csr_lads_stk_bal_hdr;

      /*---------------------------*/
      /* 1. LADS transaction logic */
      /*---------------------------*/
      /*-*/
      /* Transaction logic
      /* **note** - changes to the LADS data
      /*-*/

      /*---------------------------*/
      /* 2. LADS flattening logic  */
      /*---------------------------*/
      /*-*/
      /* Flattening logic
      /* **note** - delete and replace
      /*-*/
      bds_atllad02_flatten.execute('*DOCUMENT',par_bukrs,par_werks,par_lgort,par_budat,par_timlo);                       

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
         raise_application_error(-20000, 'LADS_ATLLAD02_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_bukrs in varchar2,
                     par_werks in varchar2,
                     par_lgort in varchar2,
                     par_budat in varchar2,
                     par_timlo in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. Triggered procedures   */
      /*---------------------------*/
      return;                      

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
         raise_application_error(-20000, 'LADS_ATLLAD02_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad02_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad02_monitor for lads_app.lads_atllad02_monitor;
grant execute on lads_atllad02_monitor to lics_app;
