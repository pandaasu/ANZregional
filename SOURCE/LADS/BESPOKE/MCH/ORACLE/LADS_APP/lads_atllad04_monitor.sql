/******************/
/* Package Header */
/******************/
create or replace package lads_atllad04_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_atllad04_monitor
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - atllad04 - Inbound Material Monitor

    **Notes** 1. This package must NOT issue commit/rollback statements.
              2. This package must raise an exception on failure to exclude database activity from parent commit.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2006/11   Linden Glen    Included LADS FLATTENING callout
    2008/03   Linden Glen    Added Duplicate Material check
    2008/05   Trevor Keon    Changed to use execute_before and execute_after

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_matnr in varchar2);
   procedure execute_after(par_matnr in varchar2);

end lads_atllad04_monitor;
/


CREATE OR REPLACE package body LADS_APP.lads_atllad04_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_matnr in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_email varchar2(256);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_mat_hdr is
         select *
           from lads_mat_hdr t01
          where t01.matnr = par_matnr;
      rcd_lads_mat_hdr csr_lads_mat_hdr%rowtype;

      cursor csr_lads_mat_chk is
         select count(*) as matl_chk
           from lads_mat_hdr t01
          where ltrim(t01.matnr,'0') = ltrim(par_matnr,'0');
      rcd_lads_mat_chk csr_lads_mat_chk%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the material header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_mat_hdr;
      fetch csr_lads_mat_hdr into rcd_lads_mat_hdr;
      if csr_lads_mat_hdr%notfound then
         raise_application_error(-20000, 'Material (' || par_matnr || ') not found');
      end if;
      close csr_lads_mat_hdr;

      /*---------------------------*/
      /* 1. LADS transaction logic */
      /*---------------------------*/
      /*-*/
      /* Transaction logic
      /* **note** - changes to the LADS data
      /*-*/

      /*-*/
      /* Validate for duplicate material code
      /*   note : a manual process exists within GRD that allows users to send
      /*          materials without leading zeros if used incorrectly.
      /*          e.g. 000000000010012345 would be received as 10012345
      /*          Any applications performing an ltrim of 0's from material codes
      /*          will return a duplicate entry for the material. 
      /*          This routine checks for the existence of duplicates and notifies
      /*-*/
      open csr_lads_mat_chk;
      fetch csr_lads_mat_chk into rcd_lads_mat_chk;
      if (rcd_lads_mat_chk.matl_chk > 1) then

         var_email := lics_setting_configuration.retrieve_setting('ATLLAD04_DUP_CHECK', 'EMAIL_GROUP');
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then

            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         'HK/CHINA DUPLICATE MATERIAL CHECKER',
                                         'LADS_ATLLAD04_MONITOR',
                                         var_email,
                                         'GRD Material Code ' || par_matnr || ' exists more than once with and without leading zeros' || chr(13) || 
                                         'Please notify DW_INFO_DELIVERY_AP via Magic Incident to have the duplicate records removed.');
         end if;

      end if;
      close csr_lads_mat_chk;


      /*---------------------------*/
      /* 2. LADS flattening logic  */
      /*---------------------------*/
      /*-*/
      /* Flattening logic
      /* **note** - delete and replace
      /*-*/
      bds_atllad04_flatten.execute('*DOCUMENT',par_matnr);

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
         raise_application_error(-20000, 'LADS_ATLLAD04_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_matnr in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. Triggered procedures   */
      /*---------------------------*/
      /*-*/
      /* Triggered procedures
      /* **note** - must be last (potentially use flattened data)
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
         raise_application_error(-20000, 'LADS_ATLLAD04_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad04_monitor;
/