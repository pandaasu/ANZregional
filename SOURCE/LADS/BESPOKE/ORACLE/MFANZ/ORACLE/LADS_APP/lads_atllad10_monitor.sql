create or replace package lads_atllad10_monitor as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad10_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad10 - Inbound Reference Data Monitor

 **Notes** 1. This package must NOT issue commit/rollback statements.
           2. This package must raise an exception on failure to exclude database activity from parent commit.


 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/12   Linden Glen    Included LADS FLATTENING callout 
 2008/04   Trevor Keon    Added call to plant reference data extract 
 2008/05   Trevor Keon    Changed to use execute_before and execute_after

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_z_tabname in varchar2);
   procedure execute_after(par_z_tabname in varchar2);

end lads_atllad10_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad10_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_z_tabname in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_hdr is
         select *
           from lads_ref_hdr t01
          where t01.z_tabname = par_z_tabname;
      rcd_lads_ref_hdr csr_lads_ref_hdr%rowtype;
    
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the Reference header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_ref_hdr;
      fetch csr_lads_ref_hdr into rcd_lads_ref_hdr;
      if csr_lads_ref_hdr%notfound then
         raise_application_error(-20000, 'Reference Table (' || par_z_tabname || ') not found');
      end if;
      close csr_lads_ref_hdr;

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
      bds_atllad10_flatten.execute('*DOCUMENT',par_z_tabname);

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
         raise_application_error(-20000, 'LADS_ATLLAD10_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   procedure execute_after(par_z_tabname in varchar2) is
    
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
   
      /*---------------------------*/
      /* 1. Triggered procedures   */
      /*---------------------------*/
      lics_trigger_loader.execute('MFANZ Plant Reference Data Inteface',
                            'plant_reference_data_extract.execute(''' || par_z_tabname || ''',''*ALL'')',
                            lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PLANT_INTERFACE'),
                            lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PLANT_INTERFACE'),
                            lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PLANT_INTERFACE'));

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
         raise_application_error(-20000, 'LADS_ATLLAD10_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad10_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad10_monitor for lads_app.lads_atllad10_monitor;
grant execute on lads_atllad10_monitor to lics_app;
