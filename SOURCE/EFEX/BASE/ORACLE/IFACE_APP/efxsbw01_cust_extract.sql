/******************/
/* Package Header */
/******************/
create or replace package efxsbw01_cust_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw01_cust_extract
    Owner   : iface_app

    Description
    -----------
    Customer Extract - EFEX to SAP BW

    This package extracts the Efex customers that have been modified within the last
    history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW01 has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/10   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxsbw01_cust_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw01_cust_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;
   con_sales_org_code constant varchar2(10) := '135';
   con_dstbn_chnl_code constant varchar2(10) := '10';
   con_division_code constant varchar2(10) := '51';
   con_company_code constant varchar2(10) := '135';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_history in varchar2 default 0) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_history number;
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.customer_id )as customer_id,
                t01.customer_code as customer_code,
                t01.customer_name as customer_name,
                t01.customer_name_en as customer_name_en,
                t01.outlet_location as outlet_location,
                t01.distributor_flg as distributor_flg,
                t01.outlet_flg as outlet_flg,
                t01.active_flg as active_flg,
                to_char(t01.range_id) as range_id,
                t02.cust_type_name as cust_type_name,
                to_char(t03.cust_trade_channel_id) as cust_trade_channel_id,
                to_char(t04.cust_channel_id) as cust_channel_id,
                t07.sales_territory_name as sales_territory_name,
                to_char(t07.user_id) as sales_territory_user_id,
                t08.sales_area_name as sales_area_name,
                to_char(t08.user_id) as sales_area_user_id,
                t09.sales_region_name as sales_region_name,
                to_char(t09.user_id) as sales_region_user_id,
                t10.segment_name as segment_name,
                t12.cust_grade_name as cust_grade_name,
                t13.std_level1_name as std_level1_name,
                t13.std_level2_name as std_level2_name,
                t13.std_level3_name as std_level3_name,
                t13.std_level4_name as std_level4_name,
                t14.geo_level1_name as geo_level1_name,
                t14.geo_level2_name as geo_level2_name,
                t14.geo_level3_name as geo_level3_name,
                t14.geo_level4_name as geo_level4_name,
                t14.geo_level5_name as geo_level5_name,
                t15.distcust_code as distcust_code,
                t16.list_value_text as list_value_text
           from customer t01,
                cust_type t02,
                cust_trade_channel t03,
                cust_channel t04,
                market t05,
                (select t01.customer_id,
                        t01.sales_territory_id
                   from (select t01.customer_id,
                                t01.sales_territory_id,
                                rank() over (partition by t01.customer_id
                                                 order by t01.sales_territory_id asc) as rnkseq
                           from cust_sales_territory t01
                          where t01.status = 'A'
                            and t01.primary_flg = 'Y') t01
                  where t01.rnkseq = 1) t06,
                sales_territory t07,
                sales_area t08,
                sales_region t09,
                segment t10,
                business_unit t11,
                cust_grade t12,
                standard_hierarchy t13,
                geo_hierarchy t14,
                distributor_cust t15,
                (select t01.business_unit_id,
                        t01.list_value_name,
                        max(t01.list_value_text) as list_value_text
                   from list_values t01
                  where t01.list_type = 'CHN_CUST_LOCATION'
                    and t01.market_id = con_market_id
                  group by t01.business_unit_id,
                           t01.list_value_name) t16
          where t01.cust_type_id = t02.cust_type_id(+)
            and t02.cust_trade_channel_id = t03.cust_trade_channel_id(+)
            and t03.cust_channel_id = t04.cust_channel_id(+)
            and t04.market_id = t05.market_id(+)
            and t01.customer_id = t06.customer_id(+)
            and t06.sales_territory_id = t07.sales_territory_id(+)
            and t07.sales_area_id = t08.sales_area_id(+)
            and t08.sales_region_id = t09.sales_region_id(+)
            and t09.segment_id = t10.segment_id(+)
            and t01.business_unit_id = t11.business_unit_id(+)
            and t01.cust_grade_id = t12.cust_grade_id(+)
            and t01.std_level1_code = t13.std_level1_code(+)
            and t01.std_level2_code = t13.std_level2_code(+)
            and t01.std_level3_code = t13.std_level3_code(+)
            and t01.std_level4_code = t13.std_level4_code(+)
            and t01.geo_level1_code = t14.geo_level1_code(+)
            and t01.geo_level2_code = t14.geo_level2_code(+)
            and t01.geo_level3_code = t14.geo_level3_code(+)
            and t01.geo_level4_code = t14.geo_level4_code(+)
            and t01.geo_level5_code = t14.geo_level5_code(+)
            and t01.customer_id = t15.customer_id(+)
            and t01.distributor_id = t15.distributor_id(+)
            and t01.business_unit_id = t16.business_unit_id(+)
            and t01.outlet_location = t16.list_value_name(+)
            and t05.market_id = con_market_id
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t02.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t03.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t04.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t07.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t08.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t09.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t10.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t12.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t15.modified_date) >= trunc(sysdate) - var_history);
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Define number of days to extract
      /*-*/
      if (par_history = 0) then
         var_history := 99999;
      else
         var_history := par_history;
      end if;

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_extract;
      loop
         fetch csr_extract into rcd_extract;
         if csr_extract%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('EFXSBW01',null,'EFEX_CUST_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
            var_start := false;
         end if;

         /*-*/
         /* Append data lines when required
         /*-*/
         lics_outbound_loader.append_data('"'||replace(con_sales_org_code,'"','""')||'";'||
                                          '"'||replace(con_dstbn_chnl_code,'"','""')||'";'||
                                          '"'||replace(con_division_code,'"','""')||'";'||
                                          '"'||replace(con_company_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.customer_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.customer_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.customer_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.customer_name_en,'"','""')||'";'||
                                          '"'||replace(rcd_extract.geo_level1_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.geo_level2_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.geo_level3_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.geo_level4_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.geo_level5_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.std_level1_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.std_level2_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.std_level3_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.std_level4_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.segment_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sales_area_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sales_territory_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sales_region_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sales_area_user_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sales_territory_user_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sales_region_user_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.cust_channel_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.cust_trade_channel_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.cust_type_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.outlet_location,'"','""')||'";'||
                                          '"'||replace(rcd_extract.list_value_text,'"','""')||'";'||
                                          '"'||replace(rcd_extract.distributor_flg,'"','""')||'";'||
                                          '"'||replace(rcd_extract.outlet_flg,'"','""')||'";'||
                                          '"'||replace(rcd_extract.active_flg,'"','""')||'";'||
                                          '"'||replace(rcd_extract.cust_grade_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.distcust_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.range_id,'"','""')||'"');

      end loop;
      close csr_extract;

      /*-*/
      /* Finalise Interface
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;


         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW01 EFEX_CUST_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw01_cust_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw01_cust_extract for iface_app.efxsbw01_cust_extract;
grant execute on efxsbw01_cust_extract to public;
