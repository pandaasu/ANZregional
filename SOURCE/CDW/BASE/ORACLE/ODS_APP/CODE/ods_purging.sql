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
    2010/12   Steve Gregan   Modified for FCST_DTL partitioning

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
      var_work varchar2(64);
      var_history_default number;
      var_history_br number;
      var_history_rob number;
      var_history_op number;
      var_history_fcst number;
      var_history_drft number;
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is
         select t01.fcst_hdr_code
           from fcst_hdr t01
          where (t01.fcst_type_code = 'BR' and
                 ((t01.casting_year*100)+t01.casting_period) < (select case when substr(to_char(mars_period-var_history_br,'fm000000'),5,2) < 1 then mars_period-var_history_br-(87*ceil(var_history_br/13))
                                                                            when substr(to_char(mars_period-var_history_br,'fm000000'),5,2) > 13 then mars_period-var_history_br-(87*ceil(var_history_br/13))
                                                                            else mars_period-var_history_br end
                                                                  from mars_date
                                                                 where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'ROB' and
                 ((t01.casting_year*100)+t01.casting_period) < (select case when substr(to_char(mars_period-var_history_rob,'fm000000'),5,2) < 1 then mars_period-var_history_rob-(87*ceil(var_history_rob/13))
                                                                            when substr(to_char(mars_period-var_history_rob,'fm000000'),5,2) > 13 then mars_period-var_history_rob-(87*ceil(var_history_rob/13))
                                                                            else mars_period-var_history_rob end
                                                                  from mars_date
                                                                 where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'OP' and
                 ((t01.casting_year*100)+t01.casting_period) < (select case when substr(to_char(mars_period-var_history_op,'fm000000'),5,2) < 1 then mars_period-var_history_op-(87*ceil(var_history_op/13))
                                                                            when substr(to_char(mars_period-var_history_op,'fm000000'),5,2) > 13 then mars_period-var_history_op-(87*ceil(var_history_op/13))
                                                                            else mars_period-var_history_op end
                                                                  from mars_date
                                                                 where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'FCST' and
                 ((t01.casting_year*100)+t01.casting_period) < (select case when substr(to_char(mars_period-var_history_fcst,'fm000000'),5,2) < 1 then mars_period-var_history_fcst-(87*ceil(var_history_fcst/13))
                                                                            when substr(to_char(mars_period-var_history_fcst,'fm000000'),5,2) > 13 then mars_period-var_history_fcst-(87*ceil(var_history_fcst/13))
                                                                            else mars_period-var_history_fcst end
                                                                  from mars_date
                                                                 where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'DRFT' and
                 ((t01.casting_year*100)+t01.casting_period) < (select case when substr(to_char(mars_period-var_history_drft,'fm000000'),5,2) < 1 then mars_period-var_history_drft-(87*ceil(var_history_drft/13))
                                                                            when substr(to_char(mars_period-var_history_drft,'fm000000'),5,2) > 13 then mars_period-var_history_drft-(87*ceil(var_history_drft/13))
                                                                            else mars_period-var_history_drft end
                                                                  from mars_date
                                                                 where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code not in('BR','ROB','OP','FCST','DRFT') and
                 ((t01.casting_year*100)+t01.casting_period) < (select case when substr(to_char(mars_period-var_history_default,'fm000000'),5,2) < 1 then mars_period-var_history_default-(87*ceil(var_history_default/13))
                                                                            when substr(to_char(mars_period-var_history_default,'fm000000'),5,2) > 13 then mars_period-var_history_default-(87*ceil(var_history_default/13))
                                                                            else mars_period-var_history_default end
                                                                  from mars_date
                                                                 where trunc(calendar_date) = trunc(sysdate)));
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
      select dsv_value into var_work from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','*DEFAULT'));
      begin
         var_history_default := to_number(var_work);
      exception
         when others then
            var_history_default := 36;
      end;

      select dsv_value into var_work from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','BR'));
      begin
         var_history_br := to_number(var_work);
      exception
         when others then
            var_history_br := var_history_default;
      end;

      select dsv_value into var_work from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','ROB'));
      begin
         var_history_rob := to_number(var_work);
      exception
         when others then
            var_history_rob := var_history_default;
      end;

      select dsv_value into var_work from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','OP'));
      begin
         var_history_op := to_number(var_work);
      exception
         when others then
            var_history_op := var_history_default;
      end;

      select dsv_value into var_work from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','FCST'));
      begin
         var_history_fcst := to_number(var_work);
      exception
         when others then
            var_history_fcst := var_history_default;
      end;

      select dsv_value into var_work from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','DRFT'));
      begin
         var_history_drft := to_number(var_work);
      exception
         when others then
            var_history_fcst := var_history_default;
      end;

      /*-*/
      /* Retrieve the headers
      /* **note** the header cursor is reopened after each delete
      /*-*/
      loop
         open csr_header;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;
         close csr_header;

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
            ods_partition.drop_list('fcst_dtl','F'||to_char(rcd_lock.fcst_hdr_code));
            delete from fcst_hdr where fcst_hdr_code = rcd_lock.fcst_hdr_code;
         end if;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_header;

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