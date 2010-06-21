CREATE OR REPLACE PACKAGE SITE_APP.ladcad03_customer as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ladcad03_customer
 Owner   : site_app

 Description
 -----------
 Customer Master Data

 1. PAR_HISTORY (OPTIONAL)

    ## - Number of days changes to extract
    0 - Full extract (default)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created
 2008/01   Linden Glen    Added data check to stop empty interfaces
 2008/05   Linden Glen    Added swb_status
 2009/03   Trevor Keon    Added sales_org_code, distbn_chnl_code and division_code
 2009/07   Trevor Keon    Added division 56 to query
 2010/05   Ben Halicki    Added cn_sales_team_code and cn_sales_team_name

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end ladcad03_customer;
/


/****************/
/* Package Body */
/****************/
CREATE OR REPLACE PACKAGE BODY SITE_APP.ladcad03_customer as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);


   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_history in varchar2 default 0) is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
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
                max(h.sap_cn_sales_team_code) as cn_sales_team_code,
                max(h.sap_cn_sales_team_desc) as cn_sales_team_name,
                case
                   when max(a.account_group_code) = '0001' 
                    and nvl(max(c.search_term_02),'x') not in ('SHIPTO','BILLTO') 
                    and max(a.order_block_flag) is null 
                    and max(i.order_block_flag) is null then 'ACTIVE'
                   else 'INACTIVE'
                end as swb_status,
                max(to_char(a.bds_lads_date,'yyyymmddhh24miss')) as bds_lads_date,
                max(i.sales_org_code) as sales_org_code,
                max(i.distbn_chnl_code) as distbn_chnl_code,
                i.division_code as division_code
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
           and i.division_code in ('51','56')
           and e.country_code(+) = 'CN'
           and f.company_code(+) = '135'
           and ltrim(i.customer_code,'0') = ltrim(g.sap_hier_cust_code(+),'0')
           and i.sales_org_code = g.sap_sales_org_code(+)
           and i.distbn_chnl_code = g.sap_distbn_chnl_code(+)
           and i.division_code = g.sap_division_code(+)
           and trunc(a.bds_lads_date) >= trunc(sysdate) - var_history
         group by a.customer_code, i.division_code;
   rec_cust_master  csr_cust_master%rowtype;

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
      /* Open Cursor for output
      /*-*/
      open csr_cust_master;
      loop
         fetch csr_cust_master into rec_cust_master;
         if (csr_cust_master%notfound) then
            exit;
         end if;

         /*-*/
         /* Create Outbound Interface if record(s) exist
         /*-*/
         if (var_start) then

            var_instance := lics_outbound_loader.create_interface('LADCAD03',null,'LADCAD03.dat');

            var_start := false;

         end if;

         /*-*/
         /* Append Data Lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          rpad(to_char(nvl(rec_cust_master.sap_customer_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.sap_customer_name,' ')||rpad(' ',160-length(nvl(rec_cust_master.sap_customer_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.ship_to_cust_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.ship_to_cust_name,' ')||rpad(' ',40-length(nvl(rec_cust_master.ship_to_cust_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.bill_to_cust_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.bill_to_cust_name,' ')||rpad(' ',40-length(nvl(rec_cust_master.bill_to_cust_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.salesman_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.salesman_name,' ')||rpad(' ',40-length(nvl(rec_cust_master.salesman_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.city_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.city_name,' ')||rpad(' ',40-length(nvl(rec_cust_master.city_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.hub_city_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.hub_city_name,' ')||rpad(' ',40-length(nvl(rec_cust_master.hub_city_name,' ')),' ') ||
                                          nvl(rec_cust_master.address_street_en,' ')||rpad(' ',60-length(nvl(rec_cust_master.address_street_en,' ')),' ') ||
                                          nvl(rec_cust_master.address_sort_en,' ')||rpad(' ',20-length(nvl(rec_cust_master.address_sort_en,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.region_code,' ')),3, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.plant_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.vat_registration_number,' ')),20, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.customer_status,' ')),1, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.insurance_number,' ')),10, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.buying_grp_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.buying_grp_name,' ')||rpad(' ',120-length(nvl(rec_cust_master.buying_grp_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.key_account_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.key_account_name,' ')||rpad(' ',120-length(nvl(rec_cust_master.key_account_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.channel_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.channel_name,' ')||rpad(' ',120-length(nvl(rec_cust_master.channel_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.channel_grp_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.channel_grp_name,' ')||rpad(' ',120-length(nvl(rec_cust_master.channel_grp_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.cn_sales_team_code,' ')),10, ' ') ||
                                          nvl(rec_cust_master.cn_sales_team_name,' ')||rpad(' ',120-length(nvl(rec_cust_master.cn_sales_team_name,' ')),' ') ||
                                          rpad(to_char(nvl(rec_cust_master.swb_status,' ')),8, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.bds_lads_date,' ')),14, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.sales_org_code,' ')),4, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.distbn_chnl_code,' ')),2, ' ') ||
                                          rpad(to_char(nvl(rec_cust_master.division_code,' ')),2, ' '));

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
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;


         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - LADCAD03 CUSTOMER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladcad03_customer;
/


/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladcad03_customer for site_app.ladcad03_customer;
grant execute on ladcad03_customer to public;
