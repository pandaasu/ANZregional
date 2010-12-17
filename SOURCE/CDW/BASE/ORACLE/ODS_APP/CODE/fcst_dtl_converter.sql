/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : fcst_dtl_converter
 Owner   : ods

 Description
 -----------
 FCST_DTL - Converter

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/12   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package fcst_dtl_converter as

   /**/
   /* Public declarations
   /**/
   procedure execute;

end fcst_dtl_converter;
/

/****************/
/* Package Body */
/****************/
create or replace package body fcst_dtl_converter as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_purging_group constant varchar2(32) := 'ODS_PURGING';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_size number(5,0);
      var_work number(5,0);
      var_exit boolean;
      var_value varchar2(64);
      var_history_default number;
      var_history_br number;
      var_history_rob number;
      var_history_op number;
      var_history_fcst number;
      var_history_drft number;
      var_history_draf number;
      type rcd_fcst_dtl is table of fcst_dtl%rowtype index by binary_integer;
      tab_fcst_dtl rcd_fcst_dtl;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is 
         select t01.*
           from fcst_hdr t01
          where (t01.fcst_type_code = 'BR' and
                 ((t01.casting_year*100)+t01.casting_period) >= (select case when substr(to_char(mars_period-var_history_br,'fm000000'),5,2) < 1 then mars_period-var_history_br-(87*ceil(var_history_br/13))
                                                                             when substr(to_char(mars_period-var_history_br,'fm000000'),5,2) > 13 then mars_period-var_history_br-(87*ceil(var_history_br/13))
                                                                             else mars_period-var_history_br end
                                                                   from mars_date
                                                                  where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'ROB' and
                 ((t01.casting_year*100)+t01.casting_period) >= (select case when substr(to_char(mars_period-var_history_rob,'fm000000'),5,2) < 1 then mars_period-var_history_rob-(87*ceil(var_history_rob/13))
                                                                             when substr(to_char(mars_period-var_history_rob,'fm000000'),5,2) > 13 then mars_period-var_history_rob-(87*ceil(var_history_rob/13))
                                                                             else mars_period-var_history_rob end
                                                                   from mars_date
                                                                  where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'OP' and
                 ((t01.casting_year*100)+t01.casting_period) >= (select case when substr(to_char(mars_period-var_history_op,'fm000000'),5,2) < 1 then mars_period-var_history_op-(87*ceil(var_history_op/13))
                                                                             when substr(to_char(mars_period-var_history_op,'fm000000'),5,2) > 13 then mars_period-var_history_op-(87*ceil(var_history_op/13))
                                                                             else mars_period-var_history_op end
                                                                   from mars_date
                                                                  where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'FCST' and
                 ((t01.casting_year*100)+t01.casting_period) >= (select case when substr(to_char(mars_period-var_history_fcst,'fm000000'),5,2) < 1 then mars_period-var_history_fcst-(87*ceil(var_history_fcst/13))
                                                                             when substr(to_char(mars_period-var_history_fcst,'fm000000'),5,2) > 13 then mars_period-var_history_fcst-(87*ceil(var_history_fcst/13))
                                                                             else mars_period-var_history_fcst end
                                                                   from mars_date
                                                                  where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'DRFT' and
                 ((t01.casting_year*100)+t01.casting_period) >= (select case when substr(to_char(mars_period-var_history_drft,'fm000000'),5,2) < 1 then mars_period-var_history_drft-(87*ceil(var_history_drft/13))
                                                                             when substr(to_char(mars_period-var_history_drft,'fm000000'),5,2) > 13 then mars_period-var_history_drft-(87*ceil(var_history_drft/13))
                                                                             else mars_period-var_history_drft end
                                                                   from mars_date
                                                                  where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code = 'DRAF' and
                 ((t01.casting_year*100)+t01.casting_period) >= (select case when substr(to_char(mars_period-var_history_draf,'fm000000'),5,2) < 1 then mars_period-var_history_draf-(87*ceil(var_history_draf/13))
                                                                             when substr(to_char(mars_period-var_history_draf,'fm000000'),5,2) > 13 then mars_period-var_history_draf-(87*ceil(var_history_draf/13))
                                                                             else mars_period-var_history_draf end
                                                                   from mars_date
                                                                  where trunc(calendar_date) = trunc(sysdate)))
             or (t01.fcst_type_code not in ('BR','ROB','OP','FCST','DRFT','DRAF') and
                 ((t01.casting_year*100)+t01.casting_period) >= (select case when substr(to_char(mars_period-var_history_default,'fm000000'),5,2) < 1 then mars_period-var_history_default-(87*ceil(var_history_default/13))
                                                                             when substr(to_char(mars_period-var_history_default,'fm000000'),5,2) > 13 then mars_period-var_history_default-(87*ceil(var_history_default/13))
                                                                             else mars_period-var_history_default end
                                                                   from mars_date
                                                                  where trunc(calendar_date) = trunc(sysdate)))
          order by t01.fcst_hdr_code asc;
      rcd_header csr_header%rowtype;

      cursor csr_detail is 
         select t01.*
           from fcst_dtl t01
          where t01.fcst_hdr_code = rcd_header.fcst_hdr_code
          order by t01.fcst_dtl_code asc;
      rcd_detail csr_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the history periods
      /*-*/
      select dsv_value into var_value from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','*DEFAULT'));
      begin
         var_history_default := to_number(var_value);
      exception
         when others then
            var_history_default := 36;
      end;

      select dsv_value into var_value from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','BR'));
      begin
         var_history_br := to_number(var_value);
      exception
         when others then
            var_history_br := var_history_default;
      end;

      select dsv_value into var_value from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','ROB'));
      begin
         var_history_rob := to_number(var_value);
      exception
         when others then
            var_history_rob := var_history_default;
      end;

      select dsv_value into var_value from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','OP'));
      begin
         var_history_op := to_number(var_value);
      exception
         when others then
            var_history_op := var_history_default;
      end;

      select dsv_value into var_value from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','FCST'));
      begin
         var_history_fcst := to_number(var_value);
      exception
         when others then
            var_history_fcst := var_history_default;
      end;

      select dsv_value into var_value from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','DRFT'));
      begin
         var_history_drft := to_number(var_value);
      exception
         when others then
            var_history_drft := var_history_default;
      end;

      select dsv_value into var_value from table(lics_datastore.retrieve_value('ODS','ODS_FCST_PURGING','DRAF'));
      begin
         var_history_draf := to_number(var_value);
      exception
         when others then
            var_history_draf := var_history_default;
      end;

      /*-*/
      /* Retrieve rows from the source
      /*-*/
      open csr_header;
      loop
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Create and truncate the detail partition
         /*-*/
         ods_partition.check_create_list('fcst_dtl_new','F'||to_char(rcd_header.fcst_hdr_code),to_char(rcd_header.fcst_hdr_code));
         ods_partition.truncate_list('fcst_dtl_new','F'||to_char(rcd_header.fcst_hdr_code));

         /*-*/
         /* Retrieve and load the bulk detail array
         /*-*/
         var_size := 10000;
         var_work := 0;
         var_exit := false;
         open csr_detail;
         loop
            fetch csr_detail into rcd_detail;
            if csr_detail%notfound then
               var_exit := true;
            end if;

            /*-*/
            /* Load the bulk arrays when required
            /*-*/
            if var_exit = false then
               var_work := var_work + 1;
               tab_fcst_dtl(var_work).fcst_hdr_code := rcd_detail.fcst_hdr_code;
               tab_fcst_dtl(var_work).fcst_dtl_code := rcd_detail.fcst_dtl_code;
               tab_fcst_dtl(var_work).fcst_year := rcd_detail.fcst_year;
               tab_fcst_dtl(var_work).fcst_period := rcd_detail.fcst_period;
               tab_fcst_dtl(var_work).fcst_week := rcd_detail.fcst_week;
               tab_fcst_dtl(var_work).demand_plng_grp_code := rcd_detail.demand_plng_grp_code;
               tab_fcst_dtl(var_work).cntry_code := rcd_detail.cntry_code;
               tab_fcst_dtl(var_work).region_code := rcd_detail.region_code;
               tab_fcst_dtl(var_work).multi_mkt_acct_code := rcd_detail.multi_mkt_acct_code;
               tab_fcst_dtl(var_work).banner_code := rcd_detail.banner_code;
               tab_fcst_dtl(var_work).cust_buying_grp_code := rcd_detail.cust_buying_grp_code;
               tab_fcst_dtl(var_work).acct_assgnmnt_grp_code := rcd_detail.acct_assgnmnt_grp_code;
               tab_fcst_dtl(var_work).pos_format_grpg_code := rcd_detail.pos_format_grpg_code;
               tab_fcst_dtl(var_work).distbn_route_code := rcd_detail.distbn_route_code;
               tab_fcst_dtl(var_work).cust_code := rcd_detail.cust_code;
               tab_fcst_dtl(var_work).matl_zrep_code := rcd_detail.matl_zrep_code;
               tab_fcst_dtl(var_work).currcy_code := rcd_detail.currcy_code;
               tab_fcst_dtl(var_work).fcst_value := rcd_detail.fcst_value;
               tab_fcst_dtl(var_work).fcst_qty := rcd_detail.fcst_qty;
               tab_fcst_dtl(var_work).fcst_dtl_lupdp := rcd_detail.fcst_dtl_lupdp;
               tab_fcst_dtl(var_work).fcst_dtl_lupdt := rcd_detail.fcst_dtl_lupdt;
               tab_fcst_dtl(var_work).batch_code := rcd_detail.batch_code;
               tab_fcst_dtl(var_work).matl_tdu_code := rcd_detail.matl_tdu_code;
               tab_fcst_dtl(var_work).fcst_dtl_type_code := rcd_detail.fcst_dtl_type_code;
            end if;

            /*-*/
            /* Insert the bulk target data when required
            /*-*/
            if (var_exit = false and var_work = var_size) or
               (var_exit = true and var_work > 0) then
               forall idx in 1..var_work
                  insert into ods.fcst_dtl_new values tab_fcst_dtl(idx);
               commit;
               var_work := 0;
            end if;

            /*-*/
            /* Exit the loop when required
            /*-*/
            if var_exit = true then
               -- delete from fcst_dtl where fcst_hdr_code = rcd_header.fcst_hdr_code;
               -- commit;
               exit;
            end if;

         end loop;
         close csr_detail;

      end loop;
      close csr_header;

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
         raise_application_error(-20000, 'FATAL ERROR - FCST_DTL - CONVERTER - EXECUTE Procedure -' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end fcst_dtl_converter;
/  