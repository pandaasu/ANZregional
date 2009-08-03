/******************/
/* Package Header */
/******************/
create or replace package ladefx02_chn_customer as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx02_chn_customer
    Owner   : site_app

    Description
    -----------
    China Customer Master Data - LADS to EFEX

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created
    2009/06   Steve Gregan   China sales dedication - included business unit id

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladefx02_chn_customer;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladefx02_chn_customer as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;
   con_snack_id constant number := 5;
   con_pet_id constant number := 6;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

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
      cursor csr_cust_master is
         select ltrim(t01.customer_code, '0') as customer_code,
                decode(t03.customer_code,null,t02.customer_name,t03.customer_name) as customer_name,
                decode(t03.address_1,null,t02.address_1,t03.address_1) as address_1,
                decode(t03.city,null,t02.city,t03.city) as city,
                decode(t03.state,null,t02.state,t03.state) as state,
                decode(t03.postcode,null,t02.postcode,t03.postcode) as postcode,
                decode(t03.phone_number,null,t02.phone_number,t03.phone_number) as phone_number,
                decode(t03.fax_number,null,t02.fax_number,t03.fax_number) as fax_number,
                t08.cust_name_en_level_4 as affiliation,
                t09.sub_channel_desc as cust_type,
                decode(nvl(t01.deletion_flag,' '),' ','A','X','X') as cust_status,
                t05.contact_name as contact_name,
                t04.salesman_code as sales_person_code,
                t04.salesman_name as sales_person_name,
                null as outlet_location,
                t07.sap_cust_code_level_1 as geo_level1_code,
                t07.sap_cust_code_level_2 as geo_level2_code,
                t07.sap_cust_code_level_3 as geo_level3_code,
                t07.sap_cust_code_level_4 as geo_level4_code,
                t07.sap_cust_code_level_5 as geo_level5_code,
                t07.cust_name_en_level_1 as geo_level1_name,
                t07.cust_name_en_level_2 as geo_level2_name,
                t07.cust_name_en_level_3 as geo_level3_name,
                t07.cust_name_en_level_4 as geo_level4_name,
                t07.cust_name_en_level_5 as geo_level5_name,
                t08.sap_cust_code_level_1 as std_level1_code,
                t08.sap_cust_code_level_2 as std_level2_code,
                t08.sap_cust_code_level_3 as std_level3_code,
                t08.sap_cust_code_level_4 as std_level4_code,
                t08.cust_name_en_level_1 as std_level1_name,
                t08.cust_name_en_level_2 as std_level2_name,
                t08.cust_name_en_level_3 as std_level3_name,
                t08.cust_name_en_level_4 as std_level4_name,
                decode(t06.division_code,'51',con_snack_id,'56',con_pet_id,con_snack_id) as business_unit_id
           from bds_cust_header t01,
                (select t01.customer_code,
                        max(ltrim(t01.name ||' '|| t01.name_02)) as customer_name,
                        max(ltrim(t01.house_number||' '||t01.street)) as address_1,
                        max(t01.city) as city,
                        max(t01.region_code) as state,
                        max(t01.city_post_code) as postcode,
                        max(t01.phone_number) as phone_number,
                        max(t01.fax_number) as fax_number
                   from bds_addr_customer t01
                  where t01.address_version = '*NONE'
                  group by t01.customer_code) t02,
                (select t01.customer_code,
                        max(ltrim(t01.name ||' '|| t01.name_02)) as customer_name,
                        max(ltrim(t01.house_number||' '||t01.street)) as address_1,
                        max(t01.city) as city,
                        max(t01.region_code) as state,
                        max(t01.city_post_code) as postcode,
                        max(t01.phone_number) as phone_number,
                        max(t01.fax_number) as fax_number
                   from bds_addr_customer t01
                  where t01.address_version = 'I'
                  group by t01.customer_code) t03,
                (select t01.customer_code,
                        max(case when t01.partner_funcn_code = 'ZB' then t01.partner_cust_code end) as salesman_code,
                        max(case when t01.partner_funcn_code = 'ZB' then t02.name end) as salesman_name
                 from bds_cust_sales_area_pnrfun t01,
                      bds_addr_customer t02
                where t01.partner_cust_code = t02.customer_code(+)
                  and t01.partner_funcn_code = 'ZB'
                group by t01.customer_code) t04,
                (select t01.customer_code,
                        t01.contact_name
                   from (select t01.customer_code,
                                ltrim(t01.first_name ||' '|| t01.last_name) as contact_name,
                                rank() over (partition by t01.customer_code order by t01.contact_number asc) as rnkseq
                           from bds_cust_contact t01) t01
                  where t01.rnkseq = 1) t05,
                (select t01.customer_code,
                        ltrim(t01.customer_code,'0') as hier_code,
                        t01.sales_org_code,
                        t01.distbn_chnl_code,
                        t01.division_code,
                        ltrim(t02.city_code,'0') as city_code
                   from (select t01.customer_code,
                                max(t01.sales_org_code) as sales_org_code,
                                max(t01.distbn_chnl_code) as distbn_chnl_code,
                                max(t01.division_code) as division_code
                           from bds_cust_sales_area t01
                          where t01.sales_org_code = '135'
                            and t01.distbn_chnl_code = '10'
                          group by t01.customer_code) t01,
                        (select t01.customer_code,
                                max(case when t01.partner_funcn_code = 'ZA' then t01.partner_cust_code end) as city_code
                           from bds_cust_sales_area_pnrfun t01,
                                bds_addr_customer t02
                          where t01.partner_cust_code = t02.customer_code(+)
                            and t01.partner_funcn_code = 'ZA'
                          group by t01.customer_code) t02
                  where t01.customer_code = t02.customer_code(+)) t06,
                sales_force_geo_hier t07,
                std_hier t08,
                (select sap_customer_code as customer_code,
                        t02.sap_charistic_value_desc as sub_channel_desc
                   from bds_customer_classfctn t01,
                        (select t01.sap_charistic_value_code,
                                t01.sap_charistic_value_desc
                           from bds_charistic_value_en t01
                          where t01.sap_charistic_code = 'ZZCNCUST05') t02
                  where t01.sap_sub_channel_code = t02.sap_charistic_value_code(+)) t09
          where t01.customer_code = t02.customer_code(+)
            and t01.customer_code = t03.customer_code(+)
            and t01.customer_code = t04.customer_code(+)
            and t01.customer_code = t05.customer_code(+)
            and t01.customer_code = t06.customer_code
            and t06.city_code = t07.sap_hier_cust_code(+)
            and t06.sales_org_code = t07.sap_sales_org_code(+)
            and t06.distbn_chnl_code = t07.sap_distbn_chnl_code(+)
            and t06.division_code = t07.sap_division_code(+)
            and t06.hier_code = t08.sap_hier_cust_code(+)
            and t06.sales_org_code = t08.sap_sales_org_code(+)
            and t06.distbn_chnl_code = t08.sap_distbn_chnl_code(+)
            and t06.division_code = t08.sap_division_code(+)
            and t01.customer_code = t09.customer_code(+)
            and t01.account_group_code in ('0001','0002');
      rcd_cust_master csr_cust_master%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_cust_master;
      loop
         fetch csr_cust_master into rcd_cust_master;
         if csr_cust_master%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('LADEFX02',null,'LADEFX02.dat');
            lics_outbound_loader.append_data('CTL');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          to_char(nvl(con_market_id,0))||rpad(' ',10-length(to_char(nvl(con_market_id,0))),' ') ||
                                          nvl(rcd_cust_master.customer_code,' ')||rpad(' ',50-length(nvl(rcd_cust_master.customer_code,' ')),' ') ||
                                          nvl(rcd_cust_master.customer_name,' ')||rpad(' ',100-length(nvl(rcd_cust_master.customer_name,' ')),' ') ||
                                          nvl(rcd_cust_master.address_1,' ')||rpad(' ',100-length(nvl(rcd_cust_master.address_1,' ')),' ') ||
                                          nvl(rcd_cust_master.city,' ')||rpad(' ',50-length(nvl(rcd_cust_master.city,' ')),' ') ||
                                          nvl(rcd_cust_master.state,' ')||rpad(' ',50-length(nvl(rcd_cust_master.state,' ')),' ') ||
                                          nvl(rcd_cust_master.postcode,' ')||rpad(' ',50-length(nvl(rcd_cust_master.postcode,' ')),' ') ||
                                          nvl(rcd_cust_master.phone_number,' ')||rpad(' ',50-length(nvl(rcd_cust_master.phone_number,' ')),' ') || 
                                          nvl(rcd_cust_master.fax_number,' ')||rpad(' ',50-length(nvl(rcd_cust_master.fax_number,' ')),' ') ||
                                          nvl(rcd_cust_master.affiliation,' ')||rpad(' ',50-length(nvl(rcd_cust_master.affiliation,' ')),' ') ||
                                          nvl(rcd_cust_master.cust_type,' ')||rpad(' ',50-length(nvl(rcd_cust_master.cust_type,' ')),' ') ||
                                          nvl(rcd_cust_master.cust_status,' ')||rpad(' ',1-length(nvl(rcd_cust_master.cust_status,' ')),' ') ||
                                          nvl(rcd_cust_master.contact_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.contact_name,' ')),' ') ||
                                          nvl(rcd_cust_master.sales_person_code,' ')||rpad(' ',20-length(nvl(rcd_cust_master.sales_person_code,' ')),' ') ||
                                          nvl(rcd_cust_master.sales_person_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.sales_person_name,' ')),' ') ||
                                          nvl(rcd_cust_master.outlet_location,' ')||rpad(' ',100-length(nvl(rcd_cust_master.outlet_location,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level1_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.geo_level1_code,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level2_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.geo_level2_code,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level3_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.geo_level3_code,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level4_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.geo_level4_code,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level5_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.geo_level5_code,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level1_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.geo_level1_name,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level2_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.geo_level2_name,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level3_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.geo_level3_name,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level4_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.geo_level4_name,' ')),' ') ||
                                          nvl(rcd_cust_master.geo_level5_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.geo_level5_name,' ')),' ') ||
                                          nvl(rcd_cust_master.std_level1_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.std_level1_code,' ')),' ') ||
                                          nvl(rcd_cust_master.std_level2_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.std_level2_code,' ')),' ') ||
                                          nvl(rcd_cust_master.std_level3_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.std_level3_code,' ')),' ') ||
                                          nvl(rcd_cust_master.std_level4_code,' ')||rpad(' ',10-length(nvl(rcd_cust_master.std_level4_code,' ')),' ') ||
                                          nvl(rcd_cust_master.std_level1_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.std_level1_name,' ')),' ') ||
                                          nvl(rcd_cust_master.std_level2_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.std_level2_name,' ')),' ') ||
                                          nvl(rcd_cust_master.std_level3_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.std_level3_name,' ')),' ') ||
                                          nvl(rcd_cust_master.std_level4_name,' ')||rpad(' ',50-length(nvl(rcd_cust_master.std_level4_name,' ')),' ') ||
                                          to_char(nvl(rcd_cust_master.business_unit_id,0))||rpad(' ',10-length(to_char(nvl(rcd_cust_master.business_unit_id,0))),' '));

      end loop;
      close csr_cust_master;

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
         raise_application_error(-20000, 'FATAL ERROR - LADEFX02 CHINA CUSTOMER - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladefx02_chn_customer;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx02_chn_customer for site_app.ladefx02_chn_customer;
grant execute on ladefx02_chn_customer to public;
