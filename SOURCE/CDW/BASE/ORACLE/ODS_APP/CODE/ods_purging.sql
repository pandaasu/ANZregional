/******************/
/* Package Header */
/******************/
create or replace package ods_purging as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_purging
    Owner   : lads_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Operational Data Store - Purging

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ods_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_forecast;

   /*-*/
   /* Private constants
   /*-*/
   con_purging_group constant varchar2(32) := 'ODS_PURGING';
   cnt_process_count constant number(5,0) := 10;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the forecast data
      /*-*/
      purge_forecast;

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
         raise_application_error(-20000, 'FATAL ERROR - Operational Data Store - Purging - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /******************************************************/
   /* This procedure performs the purge forecast routine */
   /******************************************************/
   procedure purge_forecast is

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
         select t01.fcst_hdr_code
           from fcst_hdr t01
          where ((t01.casting_year*100)+t01.casting_period) < (select case when (substr(to_char((mars_period-var_history),'fm000000'),5,6) >= '01' and
                                                                                  substr(to_char((mars_period-var_history),'fm000000'),5,6) <= '13')
                                                                            then mars_period-var_history
                                                                            else (mars_period-var_history-87)
                                                                             end
                                                                  from mars_date
                                                                 where trunc(calendar_date) = trunc(sysdate));

      rcd_header csr_header%rowtype;

      cursor csr_lock is
         select t01.fcst_hdr_code
           from fcst_hdr t01
          where t01.fcst_hdr_code = rcd_header.fcst_hdr_code
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history periods
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_purging_group, 'FCST_HDR'));

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
            delete from fcst_dtl where fcst_hdr_code = rcd_lock.fcst_hdr_code;
            delete from fcst_hdr where fcst_hdr_code = rcd_lock.fcst_hdr_code;
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
   end purge_forecast;

end ods_purging;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_purging for ods_app.ods_purging;
grant execute on ods_purging to public;