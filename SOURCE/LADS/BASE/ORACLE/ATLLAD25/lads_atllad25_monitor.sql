/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad25_monitor
 Owner   : lads_app
 Author  : Linden Glen

 Description
 -----------
 Local Atlas Data Store - atllad25 - Generic ICB Monitor

 Notes :
    Within SAP, users can move a shipment from one group to another. However,
    if they do not manually resend the original group then an idoc is not
    generated, therefore, LADS will show the shipment under both groups.

    Upon receiving a shipment group, this monitor will update all older,
    already existing shipments to an inactive status (LADS_EXP_HSH.SHPMNT_STATUS = 2)


 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Linden Glen    Created
 2008/05   Trevor Keon    Changed to use execute_before and execute_after

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad25_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_zzgrpnr in varchar2);
   procedure execute_after(par_zzgrpnr in varchar2);

end lads_atllad25_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad25_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_zzgrpnr in varchar2) is

   /*-*/
   /* Local variables
   /*-*/
   var_idoc_timestamp  varchar2(14);

   /*-*/
   /* Cursor definitions
   /*-*/
   cursor csr_timestamp is
      select a.idoc_timestamp,
             a.idoc_number,
             a.zzgrpnr
      from lads_exp_hdr a
      where a.zzgrpnr = par_zzgrpnr;
   rec_timestamp csr_timestamp%rowtype;

   cursor csr_shpmnt_grp is
      select a.tknum
      from lads_exp_hsh a
      where a.zzgrpnr = par_zzgrpnr;
   rec_shpmnt_grp csr_shpmnt_grp%rowtype;

   cursor csr_shpmnt(par_tknum varchar2) is
      select a.zzgrpnr,
             b.tknum, 
             a.idoc_timestamp
      from lads_exp_hdr a,
           lads_exp_hsh b
      where a.zzgrpnr = b.zzgrpnr
        and b.shpmnt_status != '2'
        and b.tknum = par_tknum;
   rec_shpmnt csr_shpmnt%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
   
      /*---------------------------*/
      /* 1. LADS transaction logic */
      /*---------------------------*/
      /*-*/
      /* Transaction logic
      /* **note** - changes to the LADS data
      /*-*/

      /*-*/
      /* Retrieve ZZGRPNR IDOC Timestamp
      /*-*/
      open csr_timestamp;
      fetch csr_timestamp into rec_timestamp;
      var_idoc_timestamp := rec_timestamp.idoc_timestamp;
      close csr_timestamp;

      /*-*/
      /* Retrieve Shipments (TKNUM) within Group (ZZGRPNR)
      /*-*/
      open csr_shpmnt_grp;
      loop
         fetch csr_shpmnt_grp into rec_shpmnt_grp;
         if (csr_shpmnt_grp%notfound) then
            exit;
         end if;

         /*-*/
         /* Retrieve all instances of a single shipment
         /*   notes : - exclude those already inactive
         /*-*/
         open csr_shpmnt(rec_shpmnt_grp.tknum);
         loop
            fetch csr_shpmnt into rec_shpmnt;
            if (csr_shpmnt%notfound) then
               exit;
            end if;

            /*-*/
            /* IF a shipment is older than the one just loaded,
            /* update status to inactive.
            /*-*/
            if (rec_shpmnt.idoc_timestamp < var_idoc_timestamp) then

               update lads_exp_hsh a
                  set a.shpmnt_status = '2'
                  where a.zzgrpnr = rec_shpmnt.zzgrpnr
                    and a.tknum = rec_shpmnt.tknum;

            /*-*/
            /* ELSE IF a shipment is newer than the one just loaded,
            /* update status of loaded shipment to inactive.
            /*   notes : - this scenario should only occur when idocs arrive
            /*             out of sequence from the hub
            /*-*/
            elsif (rec_shpmnt.idoc_timestamp > var_idoc_timestamp) then

               update lads_exp_hsh a
                  set a.shpmnt_status = '2'
                  where a.zzgrpnr = par_zzgrpnr
                    and a.tknum = rec_shpmnt_grp.tknum;

            end if;

         end loop;
         close csr_shpmnt;

      end loop;
      close csr_shpmnt_grp;

      /*---------------------------*/
      /* 2. LADS flattening logic  */
      /*---------------------------*/
      /*-*/
      /* Flattening logic
      /* **note** - delete and replace
      /*-*/

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
         raise_application_error(-20000, 'LADS_ATLLAD25_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_zzgrpnr in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. Triggered procedures   */
      /*---------------------------*/
      lics_trigger_loader.execute('TRIDENT Interface V2',
                                  'site_app.trident_export_idoc_pkg.run_extract(''' || par_zzgrpnr || ''')',
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','TRIDENT_LADTRI01'),
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','TRIDENT_LADTRI01'),
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','TRIDENT_LADTRI01'));
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
         raise_application_error(-20000, 'LADS_ATLLAD25_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad25_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad25_monitor for lads_app.lads_atllad25_monitor;
grant execute on lads_atllad25_monitor to lics_app;

