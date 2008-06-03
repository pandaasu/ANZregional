/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad09_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad09 - Inbound Stock Transfer and Purchase Order Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/04   Linden Glen    Added Trident Global Triggering
 2008/05   Trevor Keon    Changed to use execute_before and execute_after

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad09_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_belnr in varchar2);
   procedure execute_after(par_belnr in varchar2);

end lads_atllad09_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad09_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_belnr in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_sto_po_hdr is
         select *
           from lads_sto_po_hdr t01
           where t01.belnr = par_belnr;
      rcd_lads_sto_po_hdr csr_lads_sto_po_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the stock transfer and purchase order header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_sto_po_hdr;
      fetch csr_lads_sto_po_hdr into rcd_lads_sto_po_hdr;
      if csr_lads_sto_po_hdr%notfound then
         raise_application_error(-20000, 'Stock Transfer and Purchase Order (' || par_belnr || ') not found');
      end if;
      close csr_lads_sto_po_hdr;

      /*---------------------------*/
      /* 1. LADS transaction logic */
      /*---------------------------*/

      /*-*/
      /* Transaction logic
      /* **note** - changes to the LADS data (eg. delivery deletion)
      /*-*/

      /*---------------------------*/
      /* 2. LADS flattening logic  */
      /*---------------------------*/

      /*-*/
      /* Flattening logic
      /* **note** - delete and replace
      /*-*/
      
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
         raise_application_error(-20000, 'LADS_ATLLAD09_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   procedure execute_after(par_belnr in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*----------------------*/
      /* Triggered procedures */
      /*----------------------*/                                  
      lics_trigger_loader.execute('TRIDENT Interface',
                                  'site_app.trident_extract_pkg.idoc_monitor(''ORD_PO'',''' || par_belnr || ''')',
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','TRIDENT_LADTRI01'),
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','TRIDENT_LADTRI01'),
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','TRIDENT_LADTRI01'));

--      /*-*/
--      /* Trigger the MFG/PRO interface
--      /*-*/
--      lics_trigger_loader.execute('MFGPRO Interface (LADMFG03)',
--                                  'ics_app.ics_ladmfg03.execute(''' || par_belnr || ''')',
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','MFGPRO_LADMFG03'),
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','MFGPRO_LADMFG03'),
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','MFGPRO_LADMFG03'));

--      /*-*/
--      /* Trigger the Tolas interface
--      /*-*/
--      lics_trigger_loader.execute('Tolas Interface (LADTOLA02)',
--                                  'ics_app.ics_ladtola02.execute(''' || par_belnr || ''')',
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','TOLAS_LADTOLA02'),
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','TOLAS_LADTOLA02'),
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','TOLAS_LADTOLA02'));                                  

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
         raise_application_error(-20000, 'LADS_ATLLAD09_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad09_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad09_monitor for lads_app.lads_atllad09_monitor;
grant execute on lads_atllad09_monitor to lics_app;
