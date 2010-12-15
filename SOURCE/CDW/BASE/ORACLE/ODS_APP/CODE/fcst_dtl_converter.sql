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
      var_hdr_code number(8);
      type rcd_fcst_dtl is table of fcst_dtl%rowtype index by binary_integer;
      tab_fcst_dtl rcd_fcst_dtl;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is 
         select t01.*
           from fcst_hdr t01
          where t01.fcst_hdr_code in (471521, 471522)
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