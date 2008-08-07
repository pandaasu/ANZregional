/******************/
/* Package Header */
/******************/
create or replace package efxcad01_customer as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcad01_customer
    Owner   : iface_app

    Description
    -----------
    Customer Master Data - EFEX to CAD

    This package extracts the Efex direct and indirect customers that have been modified within the last
    history number of days and sends the extract file to the CAD environment. The ICS interface EFXCAD01
    has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxcad01_customer;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxcad01_customer as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;

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
      cursor csr_customer is
         select t05.market_name as market_name,
                t11.business_unit_name as business_unit_name,
                t10.segment_name as segment_name,
                t03.cust_trade_channel_name as cust_trade_channel_name,
                t04.cust_channel_name as cust_channel_name,
                t02.cust_type_name as cust_type_name,
                t12.cust_grade_name as cust_grade_name,
                decode(t01.outlet_flg,'N',t01.customer_code,to_char(t01.customer_id)) as cust_code,
                t01.customer_name as cust_name,
                t01.city as cust_city,
                t01.postcode as cust_postcode,
                t01.postal_address as cust_postal_addr,
                t01.phone_number as cust_phone,
                t01.fax_number as cust_fax,
                t01.email_address as cust_email,
                t01.address_1 as cust_address,
                t01.distributor_flg as cust_distributor_flag,
                t01.outlet_flg as cust_outlet_flag,
                t01.active_flg as cust_active_flag,
                t01.status as cust_status,
                t01.mobile_number as cust_mp,
                t01.setup_date as cust_created_on,
                t01.setup_person as cust_created_by,
                t01.modified_date as cust_updated_on,
                t01.modified_user as cust_updated_by,
                t01.outlet_location as cust_otl_location,
                t01.geo_level1_code as cust_country_code,
                t14.geo_level1_name as cust_country_name,
                t01.geo_level2_code as cust_region_code,
                t14.geo_level2_name as cust_region_name,
                t01.geo_level3_code as cust_cluster_code,
                t14.geo_level3_name as cust_cluster_name,
                t01.geo_level4_code as cust_area_code,
                t14.geo_level4_name as cust_area_name,
                t01.geo_level5_code as cust_city_code,
                t01.std_level2_code as cust_account_type_code,
                t13.std_level2_name as cust_account_type_desc,
                to_char(nvl(t06.sales_territory_id,0)) as sales_territory_code,
                t07.sales_territory_name as sales_territory_name,
                t08.sales_area_name as sales_area,
                t09.sales_region_name as sales_region,
                t18.associate_code as sales_person_associate_code,
                t18.lastname as sales_person_last_name,
                t18.description as sales_person_title,
                t08.status as sales_person_status,
                t18.city as sales_city,
                t16.first_name as cust_contact_first_name,
                t16.last_name as cust_contact_last_name,
                t16.phone_number as cust_contact_phone,
                t16.email_address as cust_contact_email,
                t15.affiliation_name as cust_indirect_cust_banner,
                t01.std_level3_code as cust_parent_banner_code,
                t13.std_level3_name as cust_parent_banner_name,
                t01.std_level4_code as cust_direct_banner_code,
                t13.std_level4_name as cust_direct_banner_name,
                decode(t01.distributor_flg,'Y',t17.customer_code,null) as cust_belongs_to_ws_code,
                decode(t01.distributor_flg,'Y',t17.customer_name,null) as cust_belongs_to_ws_name
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
                affiliation t15,
                (select t01.*
                   from (select t01.*,
                                rank() over (partition by t01.customer_id
                                                 order by t01.cust_contact_id asc) as rnkseq
                           from cust_contact t01
                          where t01.status = 'A') t01
                  where t01.rnkseq = 1) t16,
                customer t17,
                users t18
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
            and t01.geo_level4_code = t14.geo_level4_code(+)
            and t01.affiliation_id = t15.affiliation_id(+)
            and t01.customer_id = t16.customer_id(+)
            and t01.distributor_id = t17.customer_id(+)
            and t07.user_id = t18.user_id(+)
            and t05.market_id = con_market_id
            and trunc(t01.modified_date) >= trunc(sysdate) - var_history;
      rcd_customer csr_customer%rowtype;

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
      open csr_customer;
      loop
         fetch csr_customer into rcd_customer;
         if csr_customer%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface if record(s) exist
         /*-*/
         if (var_start) then
            var_instance := lics_outbound_loader.create_interface('EFXCAD01',null,'EFXCAD01.dat');
            lics_outbound_loader.append_data('CTL');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines when required
         /*-*/
         if not(trim(rcd_customer.market_name) is null) and
            not(trim(rcd_customer.business_unit_name) is null) and
            not(trim(rcd_customer.segment_name) is null) and
            not(trim(rcd_customer.cust_type_name) is null) and
            not(trim(rcd_customer.cust_code) is null) and
            not(trim(rcd_customer.cust_name) is null) and
            not(rcd_customer.cust_created_on is null) and
            not(trim(rcd_customer.cust_created_by) is null) and
            not(rcd_customer.cust_updated_on is null) and
            not(trim(rcd_customer.cust_updated_by) is null) then

            lics_outbound_loader.append_data('HDR' ||
                                             nvl(rcd_customer.market_name,' ')||rpad(' ',50-length(nvl(rcd_customer.market_name,' ')),' ') ||
                                             nvl(rcd_customer.business_unit_name,' ')||rpad(' ',50-length(nvl(rcd_customer.business_unit_name,' ')),' ') ||
                                             nvl(rcd_customer.segment_name,' ')||rpad(' ',50-length(nvl(rcd_customer.segment_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_trade_channel_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_trade_channel_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_channel_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_channel_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_type_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_type_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_grade_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_grade_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_code,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_name,' ')||rpad(' ',100-length(nvl(rcd_customer.cust_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_city,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_city,' ')),' ') ||
                                             nvl(rcd_customer.cust_postcode,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_postcode,' ')),' ') ||
                                             nvl(rcd_customer.cust_postal_addr,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_postal_addr,' ')),' ') ||
                                             nvl(rcd_customer.cust_phone,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_phone,' ')),' ') ||
                                             nvl(rcd_customer.cust_fax,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_fax,' ')),' ') ||
                                             nvl(rcd_customer.cust_email,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_email,' ')),' ') ||
                                             nvl(rcd_customer.cust_address,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_address,' ')),' ') ||
                                             nvl(rcd_customer.cust_distributor_flag,' ')||rpad(' ',1-length(nvl(rcd_customer.cust_distributor_flag,' ')),' ') ||
                                             nvl(rcd_customer.cust_outlet_flag,' ')||rpad(' ',1-length(nvl(rcd_customer.cust_outlet_flag,' ')),' ') ||
                                             nvl(rcd_customer.cust_active_flag,' ')||rpad(' ',1-length(nvl(rcd_customer.cust_active_flag,' ')),' ') ||
                                             nvl(rcd_customer.cust_status,' ')||rpad(' ',1-length(nvl(rcd_customer.cust_status,' ')),' ') ||
                                             nvl(rcd_customer.cust_mp,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_mp,' ')),' ') ||
                                             nvl(to_char(rcd_customer.cust_created_on,'yyyymmdd'),' ')||rpad(' ',8-length(nvl(to_char(rcd_customer.cust_created_on,'yyyymmdd'),' ')),' ') ||
                                             nvl(rcd_customer.cust_created_by,' ')||rpad(' ',10-length(nvl(rcd_customer.cust_created_by,' ')),' ') ||
                                             nvl(to_char(rcd_customer.cust_updated_on,'yyyymmdd'),' ')||rpad(' ',8-length(nvl(to_char(rcd_customer.cust_updated_on,'yyyymmdd'),' ')),' ') ||
                                             nvl(rcd_customer.cust_updated_by,' ')||rpad(' ',10-length(nvl(rcd_customer.cust_updated_by,' ')),' ') ||
                                             nvl(rcd_customer.cust_otl_location,' ')||rpad(' ',100-length(nvl(rcd_customer.cust_otl_location,' ')),' ') ||
                                             nvl(rcd_customer.cust_country_code,' ')||rpad(' ',10-length(nvl(rcd_customer.cust_country_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_country_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_country_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_region_code,' ')||rpad(' ',10-length(nvl(rcd_customer.cust_region_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_region_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_region_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_cluster_code,' ')||rpad(' ',10-length(nvl(rcd_customer.cust_cluster_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_cluster_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_cluster_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_area_code,' ')||rpad(' ',10-length(nvl(rcd_customer.cust_area_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_area_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_area_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_city_code,' ')||rpad(' ',10-length(nvl(rcd_customer.cust_city_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_account_type_code,' ')||rpad(' ',10-length(nvl(rcd_customer.cust_account_type_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_account_type_desc,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_account_type_desc,' ')),' ') ||
                                             nvl(rcd_customer.sales_territory_code,' ')||rpad(' ',10-length(nvl(rcd_customer.sales_territory_code,' ')),' ') ||
                                             nvl(rcd_customer.sales_territory_name,' ')||rpad(' ',50-length(nvl(rcd_customer.sales_territory_name,' ')),' ') ||
                                             nvl(rcd_customer.sales_area,' ')||rpad(' ',50-length(nvl(rcd_customer.sales_area,' ')),' ') ||
                                             nvl(rcd_customer.sales_region,' ')||rpad(' ',50-length(nvl(rcd_customer.sales_region,' ')),' ') ||
                                             nvl(rcd_customer.sales_person_associate_code,' ')||rpad(' ',50-length(nvl(rcd_customer.sales_person_associate_code,' ')),' ') ||
                                             nvl(rcd_customer.sales_person_last_name,' ')||rpad(' ',50-length(nvl(rcd_customer.sales_person_last_name,' ')),' ') ||
                                             nvl(rcd_customer.sales_person_title,' ')||rpad(' ',50-length(nvl(rcd_customer.sales_person_title,' ')),' ') ||
                                             nvl(rcd_customer.sales_person_status,' ')||rpad(' ',1-length(nvl(rcd_customer.sales_person_status,' ')),' ') ||
                                             nvl(rcd_customer.sales_city,' ')||rpad(' ',50-length(nvl(rcd_customer.sales_city,' ')),' ') ||
                                             nvl(rcd_customer.cust_contact_first_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_contact_first_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_contact_last_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_contact_last_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_contact_phone,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_contact_phone,' ')),' ') ||
                                             nvl(rcd_customer.cust_contact_email,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_contact_email,' ')),' ') ||
                                             nvl(rcd_customer.cust_indirect_cust_banner,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_indirect_cust_banner,' ')),' ') ||
                                             nvl(rcd_customer.cust_parent_banner_code,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_parent_banner_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_parent_banner_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_parent_banner_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_direct_banner_code,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_direct_banner_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_direct_banner_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_direct_banner_name,' ')),' ') ||
                                             nvl(rcd_customer.cust_belongs_to_ws_code,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_belongs_to_ws_code,' ')),' ') ||
                                             nvl(rcd_customer.cust_belongs_to_ws_name,' ')||rpad(' ',50-length(nvl(rcd_customer.cust_belongs_to_ws_name,' ')),' '));

         end if;

      end loop;
      close csr_customer;

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCAD01 CUSTOMER - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcad01_customer;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcad01_customer for iface_app.efxcad01_customer;
grant execute on efxcad01_customer to public;
