/******************/
/* Package Header */
/******************/
create or replace package asn_purging as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : asn
    Package : asn_purging
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Advanced Shipping Notice - Purging

    YYYY/MM   Author          Description
    -------   ------          -----------
    2005/11   Steve Gregan    Created
    2007/11   Steve Gregan    Removed DTS and Logistics purging (redundant)

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end asn_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body asn_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_dcs;

   /*-*/
   /* Private constants
   /*-*/
   cnt_process_count constant number(5,0) := 100;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the DCS data
      /*-*/
      purge_dcs;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Advanced Shipping Notice - Purging - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*************************************************/
   /* This procedure performs the purge DCS routine */
   /*************************************************/
   procedure purge_dcs is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.dch_mars_cde,
                t01.dch_pick_nbr
           from asn_dcs_hdr t01
          where t01.dch_crtn_tim < sysdate - var_history;
      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.dch_mars_cde,
                t01.dch_pick_nbr
           from asn_dcs_hdr t01
          where t01.dch_mars_cde = rcd_header.dch_mars_cde
            and t01.dch_pick_nbr = rcd_header.dch_pick_nbr
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history days
      /*-*/
      var_history := 180;
      begin
         var_history := to_number(asn_parameter.retrieve_value('ASN_PURGE', 'ASN_DCS'));
      exception
         when others then
            null;
      end;

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
         /*-*/
         var_available := true;
         begin
            open csr_lock;
            fetch csr_lock into rcd_lock;
            if csr_lock%notfound then
               var_available := false;
            end if;
         exception
            when others then
               var_available := false;
         end;
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from asn_dcs_det where dcd_mars_cde = rcd_lock.dch_mars_cde
                                      and dcd_pick_nbr = rcd_lock.dch_pick_nbr;
            delete from asn_dcs_hdr where dch_mars_cde = rcd_lock.dch_mars_cde
                                      and dch_pick_nbr = rcd_lock.dch_pick_nbr;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_dcs;

end asn_purging;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym asn_purging for ics_app.asn_purging;
grant execute on asn_purging to public;