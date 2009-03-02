/******************/
/* Package Header */
/******************/
create or replace package ics_app.ics_ladwms04 as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : ics_ladwms04
 Owner   : ICS_APP
 Author  : Steve Gregan

 Description
 -----------
    LADS -> KOREA WAREHOUSE CUSTOMER MASTER EXTRACT

    PARAMETERS:

      1. PAR_DAYS - number of days of changes to extract
            0 = full extract (extract all customers)
            n = number provided will extract changed customers for sysdate - n
            DEFAULT = no parameter specified, default is 0 (full extract)



 YYYY/MM   Author               Description
 -------   ------               -----------
 2009/02   Steve Gregan         Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_days in number default 0);

end ics_ladwms04;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_app.ics_ladwms04 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   function format_xml_str(par_string varchar2) return varchar2;

   /*-*/
   /* Constants
   /*-*/
   var_interface constant varchar2(8) := 'LADWMS04';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_days in number default 0) is

      /*-*/
      /* Local Variables
      /*-*/
      var_instance number(15,0);
      var_days number;

      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_cust_master is
         select a.customer_code as sap_customer_code,
                max(c.name || ' ' || c.name_02 ||  ' ' || c.name_03 ||  ' ' || c.name_04) as sap_customer_name,
                max(b.ship_to_cust_code) as ship_to_cust_code,
                max(b.ship_to_cust_name) as ship_to_cust_name,
                max(b.bill_to_cust_code) as bill_to_cust_code,
                max(b.bill_to_cust_name) as bill_to_cust_name,
                max(b.salesman_code) as salesman_code,
                max(b.salesman_name) as salesman_name,
                max(b.city_code) as city_code,
                max(b.city_name) as city_name,
                max(b.hub_city_code) as hub_city_code,
                max(b.hub_city_name) as hub_city_name,
                max(d.street) as address_street_en,
                max(d.search_term_01) as address_sort_en,
                max(d.region_code) as region_code,
                max(a.plant_code) as plant_code,
                max(e.vat_registration_number) as vat_registration_number,
                max(decode(nvl(a.deletion_flag,'-'),'X','I','A')) as customer_status,
                max(f.insurance_number) as insurance_number,
                max(g.sap_cust_code_level_3) as buying_grp_code,
                max(g.cust_name_en_level_3) as buying_grp_name,
                max(g.sap_cust_code_level_4) as key_account_code,
                max(g.cust_name_en_level_4) as key_account_name,
                max(h.sap_sub_channel_code) as channel_code,
                max(h.sap_sub_channel_desc) as channel_name,
                max(h.sap_channel_code) as channel_grp_code,
                max(h.sap_channel_desc) as channel_grp_name,
                case
                   when max(a.account_group_code) = '0001' 
                    and nvl(max(c.search_term_02),'x') not in ('SHIPTO','BILLTO') 
                    and max(a.order_block_flag) is null 
                    and max(i.order_block_flag) is null then 'ACTIVE'
                   else 'INACTIVE'
                end as swb_status,
                max(to_char(a.bds_lads_date,'yyyymmddhh24miss')) as bds_lads_date
         from bds_cust_header a,
              (select t01.customer_code,
                      max(case when t01.partner_funcn_code = 'WE' then t01.partner_cust_code end) as ship_to_cust_code,
                      max(case when t01.partner_funcn_code = 'WE' then t02.name end) as ship_to_cust_name,
                      max(case when t01.partner_funcn_code = 'RE' then t01.partner_cust_code end) as bill_to_cust_code,
                      max(case when t01.partner_funcn_code = 'RE' then t02.name end) as bill_to_cust_name,
                      max(case when t01.partner_funcn_code = 'ZB' then t01.partner_cust_code end) as salesman_code,
                      max(case when t01.partner_funcn_code = 'ZB' then t02.name end) as salesman_name,
                      max(case when t01.partner_funcn_code = 'ZA' then t01.partner_cust_code end) as city_code,
                      max(case when t01.partner_funcn_code = 'ZA' then t02.name end) as city_name,
                      max(case when t01.partner_funcn_code = 'ZT' then t01.partner_cust_code end) as hub_city_code,
                      max(case when t01.partner_funcn_code = 'ZT' then t02.name end) as hub_city_name
               from bds_cust_sales_area_pnrfun t01,
                    bds_addr_customer t02
               where t01.partner_cust_code = t02.customer_code(+)
                 and t01.partner_funcn_code in ('WE','RE','ZB','ZA','ZT')
               group by t01.customer_code) b,
              bds_addr_customer c,
              bds_addr_detail d,
              bds_cust_vat e,
              bds_cust_comp f,
              std_hier g,
              bds_customer_classfctn_en h,
              bds_cust_sales_area i
         where a.customer_code = b.customer_code(+)
           and a.customer_code = c.customer_code(+)
           and a.customer_code = d.address_code(+)
           and a.customer_code = e.customer_code(+)
           and a.customer_code = f.customer_code(+)
           and a.customer_code = h.sap_customer_code(+)
           and a.customer_code = i.customer_code
           and i.sales_org_code = '135'
           and i.distbn_chnl_code = '10'
           and i.division_code = '51'
           and e.country_code(+) = 'CN'
           and f.company_code(+) = '135'
           and ltrim(i.customer_code,'0') = ltrim(g.sap_hier_cust_code(+),'0')
           and i.sales_org_code = g.sap_sales_org_code(+)
           and i.distbn_chnl_code = g.sap_distbn_chnl_code(+)
           and i.division_code = g.sap_division_code(+)
           and trunc(a.bds_lads_date) >= trunc(sysdate) - var_history
         group by a.customer_code;
      rec_cust_master csr_cust_master%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Define number of days to extract
      /*-*/
      if (par_days = 0) then
         var_days := 99999;
      else
         var_days := par_days;
      end if;

      /*-*/
      /* Create Outbound Interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface(var_interface);

      /*-*/
      /* Write XML Header
      /*-*/
      lics_outbound_loader.append_data('<?xml version="1.0" encoding="UTF-8"?>');
      lics_outbound_loader.append_data('<CUSTOMER_MASTER>');

      /*-*/
      /* Write XML Control record
      /* ** notes** 1. CTL_NAME - security defined against this tag on gateway
      /*-*/
      lics_outbound_loader.append_data('<CTL>');
      lics_outbound_loader.append_data('<CTL_RECORD_ID>CTL</CTL_RECORD_ID>');
      lics_outbound_loader.append_data('<CTL_INTERFACE_NAME>' || var_interface || '</CTL_INTERFACE_NAME>');
      --TEST-- lics_outbound_loader.append_data('<CTL_NAME>MCHNDHLB2BT2</CTL_NAME>');
      lics_outbound_loader.append_data('<CTL_NAME>ACHNDHLP1</CTL_NAME>');
      lics_outbound_loader.append_data('</CTL>');

      /*-*/
      /* Open cursor for output
      /*-*/
      open csr_cust_master;
      loop
         fetch csr_cust_master into rec_cust_master;
         if csr_cust_master%notfound then
            exit;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('<HDR>');
         /*-*/
         lics_outbound_loader.append_data('<HDR_RECORD_ID>HDR</HDR_RECORD_ID>');
         lics_outbound_loader.append_data('<HDR_CUSTOMER_CODE>' || rec_cust_master.cust_code || '</HDR_CUSTOMER_CODE>');
         if not(rec_cust_master.matl_desc_zh is null) then
            lics_outbound_loader.append_data('<HDR_CUSTOMER_NAME>' || nvl(format_xml_str(rec_matl_master.matl_desc_zh),' ') || '</HDR_CUSTOMER_NAME>');
         else
            lics_outbound_loader.append_data('<HDR_CUSTOMER_NAME>' || nvl(format_xml_str(rec_matl_master.matl_desc_en),' ') || '</HDR_CUSTOMER_NAME>');
         end if;
         lics_outbound_loader.append_data('<HDR_BUS_REG_NUM>????</HDR_BUS_REG_NUM>');
         lics_outbound_loader.append_data('<HDR_BUS_TYPE' || nvl(rec_matl_master.hdr_snd_date,' ') || '</HDR_BUS_TYPE>');
         lics_outbound_loader.append_data('<HDR_BUS_CATEGORY>' || nvl(rec_matl_master.matl_type,' ') || '</HDR_BUS_CATEGORY>');
         lics_outbound_loader.append_data('<HDR_PRESIDENT_NAME> </HDR_PRESIDENT_NAME>');
         lics_outbound_loader.append_data('<HDR_POST_CODE>' || nvl(rec_matl_master.matl_gross_wgt,' ') || '</HDR_POST_CODE>');
         lics_outbound_loader.append_data('<HDR_ADDRESS>' || nvl(rec_matl_master.matl_wgt_uom,' ') || '</HDR_ADDRESS>');
         lics_outbound_loader.append_data('<HDR_TELEPHONE>' || nvl(rec_matl_master.matl_btch_mng_flag,' ') || '</HDR_TELEPHONE>');
         lics_outbound_loader.append_data('<HDR_FAX>' || nvl(rec_matl_master.matl_dhl_shelf_life,' ') || '</HDR_FAX>');
         lics_outbound_loader.append_data('<HDR_SALES_PERSON>' || nvl(rec_matl_master.matl_vol_per_base,' ') || '</HDR_FAX>');
         lics_outbound_loader.append_data('<HDR_SALES_TELEPHONE>' || nvl(rec_matl_master.matl_vol_uom,' ') || '</HDR_SALES_TELEPHONE>');
         /*-*/
         lics_outbound_loader.append_data('</HDR>');

      end loop;
      close csr_cust_master;

      /*-*/
      /* Write XML Footer details
      /*-*/
      lics_outbound_loader.append_data('</CUSTOMER_MASTER>');

      /*-*/
      /* Finalise Interface
      /*-*/
      lics_outbound_loader.finalise_interface;

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
         /* Close Interface
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /**************************************************/
   /* This function converts XML specific characters */
   /* to be XML compliant within a string            */
   /**************************************************/
   function format_xml_str(par_string varchar2) return varchar2 is

      /*-*/
      /* Local Variables
      /*-*/
      var_string varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      var_string := to_char(par_string);

      /*-*/
      /* Replace & with &amp;
      /*-*/
      var_string := replace(var_string,'&','&amp;');

      /*-*/
      /* Replace < with &lt;
      /*-*/
      var_string := replace(var_string,'<','&lt;');

      /*-*/
      /* Replace > with &gt;
      /*-*/
      var_string := replace(var_string,'>','&gt;');

      /*-*/
      /* Replace " with &quot;
      /*-*/
      var_string := replace(var_string,'"','&quot;');

      /*-*/
      /* Replace ' with null;
      /*-*/
      var_string := replace(var_string,'''','');

      /*-*/
      /* Return formatted string
      /*-*/
      return var_string;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise
         /*-*/
         raise_application_error(-20000,'ICS_LADWMS03 - FORMAT_XML_STR - Error formatting string ['||par_string||'] - ['||SQLERRM||']');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end format_xml_str;

end ics_ladwms04;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_ladwms04 for ics_app.ics_ladwms04;
grant execute on ics_app.ics_ladwms04 to lics_app;