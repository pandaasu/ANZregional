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


MARKET_ID		NUMBER(10,0)	O	
CUSTOMER_CODE		VARCHAR2(50)	O	
CUSTOMER_NAME		VARCHAR2(100)	O	
ADDRESS_1		VARCHAR2(100)	O	
ADDRESS_2		VARCHAR2(100)	O	
POSTAL_ADDRESS		VARCHAR2(50)	O	
CITY		VARCHAR2(50)	O	
STATE		VARCHAR2(50)	O	
POSTCODE		VARCHAR2(50)	O	
PHONE_NUMBER		VARCHAR2(50)	O	
FAX_NUMBER		VARCHAR2(50)	O	
EMAIL_ADDRESS		VARCHAR2(50)	O	
WEB_ADDRESS		VARCHAR2(50)	O	
AFFILIATION		VARCHAR2(50)	O	STD LEVEL 4
CUST_TYPE		VARCHAR2(50)	O	sub_channel_code
IFACE_STATUS		VARCHAR2(50)	O
IFACE_DATE		DATE	O
CUST_STATUS	used for Customer Status	VARCHAR2(3)	O


MARKET_ID                               NUMBER(10)                                                                                                                                                                                    
CUSTOMER_CODE                           VARCHAR2(50)                                                                                                                                                                                  
CUSTOMER_NAME                           VARCHAR2(100)                                                                                                                                                                                 
ADDRESS_1                               VARCHAR2(100)                                                                                                                                                                                 
ADDRESS_2                               VARCHAR2(100)                                                                                                                                                                                 
POSTAL_ADDRESS                          VARCHAR2(50)                                                                                                                                                                                  
CITY                                    VARCHAR2(50)                                                                                                                                                                                  
STATE                                   VARCHAR2(50)                                                                                                                                                                                  
POSTCODE                                VARCHAR2(50)                                                                                                                                                                                  
PHONE_NUMBER                            VARCHAR2(50)                                                                                                                                                                                  
FAX_NUMBER                              VARCHAR2(50)                                                                                                                                                                                  
EMAIL_ADDRESS                           VARCHAR2(50)                                                                                                                                                                                  
WEB_ADDRESS                             VARCHAR2(50)                                                                                                                                                                                  
AFFILIATION                             VARCHAR2(50)                                                                                                                                                                                  
CUST_TYPE                               VARCHAR2(50)                                                                                                                                                                                  
IFACE_STATUS                            VARCHAR2(50)                                                                                                                                                                                  
IFACE_DATE                              DATE                                                                                                                                                                                          
CUST_STATUS                             VARCHAR2(1 CHAR)                                                                                                                                                                              
CONTACT_NAME                            VARCHAR2(50 CHAR)                                                                                                                                                                             
SALES_PERSON_CODE                       VARCHAR2(20 CHAR)                                                                                                                                                                             
SALES_PERSON_NAME                       VARCHAR2(50 CHAR)                                                                                                                                                                             
OUTLET_LOCATION                         VARCHAR2(100 CHAR)                                                                                                                                                                            
GEO_LEVEL1_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
GEO_LEVEL2_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
GEO_LEVEL3_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
GEO_LEVEL4_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
GEO_LEVEL5_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
STD_LEVEL1_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
STD_LEVEL2_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
STD_LEVEL3_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
STD_LEVEL4_CODE                         VARCHAR2(10 CHAR)                                                                                                                                                                             
BUSINESS_UNIT_ID                        NUMBER(10)   





      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_cust_master is
         select t01.cust_code,
                t01.name,
                t01.address_1,
                t01.city,
                t01.state,
                t01.post_code, 
                t01.phone_number,
                t01.fax_number,
                t01.affiliation,
                t01.cust_type,
                t01.status
         from efex_cnh_cust_view t01;
      rcd_cust_master csr_cust_master%rowtype;


      cursor csr_cust_master is
         select t01.customer_code as sap_customer_code,
                max(c.name || ' ' || c.name_02 ||  ' ' || c.name_03 ||  ' ' || c.name_04) as sap_customer_name,
                ltrim(c.name ||' '||c.name_02) as name,
                ltrim(c.house_no||' '||c.street) as address_1,
                c.city as city,
                c.region as state,
                c.postl_cod1 as post_code,
                c.telephone as phone_number,
                c.fax as fax_number,
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
                max(t01.plant_code) as plant_code,
                max(e.vat_registration_number) as vat_registration_number,
                max(decode(nvl(t01.deletion_flag,'-'),'X','I','A')) as customer_status,
                max(f.insurance_number) as insurance_number,
                max(g.sap_cust_code_level_3) as buying_grp_code,
                max(g.cust_name_en_level_3) as buying_grp_name,
                max(g.sap_cust_code_level_4) as key_account_code,
                max(g.cust_name_en_level_4) as key_account_name,
                max(h.sap_sub_channel_code) as channel_code,
                max(h.sap_sub_channel_desc) as channel_name,
                max(h.sap_channel_code) as channel_grp_code,
                max(h.sap_channel_desc) as channel_grp_name,
                max(g.sap_cust_code_level_1),
                max(g.sap_cust_code_level_2),
                max(g.sap_cust_code_level_3),
                max(g.sap_cust_code_level_4),
                max(x.sap_cust_code_level_1),
                max(x.sap_cust_code_level_2),
                max(x.sap_cust_code_level_3),
                max(x.sap_cust_code_level_4),
                max(x.sap_cust_code_level_5)
                case
                   when max(t01.account_group_code) = '0001' 
                    and nvl(max(c.search_term_02),'x') not in ('SHIPTO','BILLTO') 
                    and max(t01.order_block_flag) is null 
                    and max(i.order_block_flag) is null then 'ACTIVE'
                   else 'INACTIVE'
                end as swb_status,
                max(to_char(t01.bds_lads_date,'yyyymmddhh24miss')) as bds_lads_date
         from bds_cust_header t01,
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
              std_hier g,
              bds_customer_classfctn_en h,
              bds_cust_sales_area i
              sales_force_geo_hier x
         where t01.customer_code = b.customer_code(+)
           and t01.customer_code = c.customer_code(+)
           and t01.customer_code = d.address_code(+)
           and t01.customer_code = e.customer_code(+)
           and t01.customer_code = f.customer_code(+)
           and t01.customer_code = h.sap_customer_code(+)
           and t01.customer_code = i.customer_code
           and i.sales_org_code = '135'
           and i.distbn_chnl_code = '10'
           and i.division_code = '51'
           and ltrim(i.customer_code,'0') = ltrim(g.sap_hier_cust_code(+),'0')
           and i.sales_org_code = g.sap_sales_org_code(+)
           and i.distbn_chnl_code = g.sap_distbn_chnl_code(+)
           and i.division_code = g.sap_division_code(+)
           and ltrim(b.city_code,'0') = x.sap_hier_cust_code(+)
           and trunc(t01.bds_lads_date) >= trunc(sysdate) - var_history
         group by t01.customer_code;
      rcd_cust_master  csr_cust_master%rowtype;





select ltrim(cust.kunnr, '0') as cust_code,
          ltrim(addr.name ||' '|| addr.name_2) as name,
          ltrim(addr.house_no||' '||addr.street) as address_1,
          addr.city,
          addr.region as state,
          addr.postl_cod1 as post_code,
          addr.telephone as phone_number,
          addr.fax as fax_number,
          std_hier.cust_name_en_level_3 as affiliation,
          std_hier.cust_name_en_level_2 as cust_type,
          cust.loevm as status
     from lads_cus_hdr cust,
          std_hier,
          (select a1.obj_id, a1.obj_type, a2.name, a2.name_2, a2.sort1, a2.house_no,
                  a2.street, a2.city, a2.region, a2.postl_cod1, a2.countryiso,
                  a3.telephone, a3.extension, a3.tel_no, a4.fax, a4.fax_no
             from lads_adr_hdr a1,
                  lads_adr_det a2,
                  lads_adr_tel a3,
                  lads_adr_fax a4
            where a1.obj_type = 'KNA1'
              and a1.context = 1
              and a2.addr_vers(+) is null -- null for local address details (can be 'k' for kanji etc.)
              and a2.to_date(+) >= to_char(sysdate, 'yyyymmdd')
              and a3.std_no(+) = 'X'
              and a4.std_no(+) = 'X'
              and a1.obj_id = a2.obj_id(+)
              and a1.obj_type = a2.obj_type(+)
              and a1.context = a2.context(+)
              and a1.obj_id = a3.obj_id(+)
              and a1.obj_type = a3.obj_type(+)
              and a1.context = a3.context(+)
              and a1.obj_id = a4.obj_id(+)
              and a1.obj_type = a4.obj_type(+)
              and a1.context = a4.context(+)) addr,
          (select distinct g.vkorg, g.kunnr
             from lads_cus_sad g
            where g.vkorg in ('135')) org,
          (select c1.objek, c1.obtab,
                  max (case when atnam = 'CLFFERT103' then atwrt end) as pos_place_code,
                  max (case when atnam = 'CLFFERT101' then atwrt end) as pos_frmt_code,
                  max (case when atnam = 'CLFFERT108' then atwrt end) as op_bus_model_code,
                  max (case when atnam = 'CLFFERT107' then atwrt end) as prmry_route_code,
                  max (case when atnam = 'CLFFERT104' then atwrt end) as banner_code,
                  max (case when atnam = 'CLFFERT105' then atwrt end) as prnt_accnt_code,
                  max (case when atnam = 'CLFFERT106' then atwrt end) as dstrbtn_route_code,
                  max (case when atnam = 'CLFFERT36' then atwrt end) as cust_buying_group_code,
                  max (case when atnam = 'CLFFERT37' then atwrt end) as multi_mrkt_accnt_code,
                  max (case when atnam = 'CLFFERT41' then atwrt end) as pos_frmt_grpng_code
             from lads_cla_hdr c1, lads_cla_chr c2
            where c1.obtab = 'KNA1'
              and c1.klart = '011'
              and c1.obtab = c2.obtab(+)
              and c1.objek = c2.objek(+)
              and c1.klart = c2.klart(+)
            group by c1.objek, c1.obtab) classn
    where (cust.ktokd = '0001' or cust.ktokd = '0002') --Sold To and Ship To Customers
      and ltrim(cust.kunnr, '0') = std_hier.sap_hier_cust_code(+)
      and cust.kunnr = org.kunnr
      and cust.kunnr = addr.obj_id(+)
      and cust.kunnr = classn.objek(+);




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
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          to_char(nvl(con_market_id,0))||rpad(' ',10-length(to_char(nvl(con_market_id,0))),' ') ||
                                          nvl(rcd_cust_master.item_code,' ')||rpad(' ',18-length(nvl(rcd_cust_master.item_code,' ')),' ') ||
                                          nvl(rcd_cust_master.item_name,' ')||rpad(' ',40-length(nvl(rcd_cust_master.item_name,' ')),' ') ||
                                          nvl(rcd_cust_master.item_zrep_code,' ')||rpad(' ',18-length(nvl(rcd_cust_master.item_zrep_code,' ')),' ') ||
                                          nvl(rcd_cust_master.rsu_ean_code,' ')||rpad(' ',18-length(nvl(rcd_cust_master.rsu_ean_code,' ')),' ') ||
                                          to_char(nvl(rcd_cust_master.cases_layer,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.cases_layer,0))),' ') ||
                                          to_char(nvl(rcd_cust_master.layers_pallet,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.layers_pallet,0))),' ') ||
                                          to_char(nvl(rcd_cust_master.units_case,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.units_case,0))),' ') ||
                                          nvl(rcd_cust_master.unit_measure,' ')||rpad(' ',3-length(nvl(rcd_cust_master.unit_measure,' ')),' ') ||
                                          to_char(nvl(rcd_cust_master.price1,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.price1,0))),' ') ||
                                          to_char(nvl(rcd_cust_master.price2,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.price2,0))),' ') ||
                                          to_char(nvl(rcd_cust_master.price3,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.price3,0))),' ') ||
                                          to_char(nvl(rcd_cust_master.price4,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.price4,0))),' ') ||
                                          to_char(nvl(rcd_cust_master.min_ord_qty,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.min_ord_qty,0))),' ') ||
                                          to_char(nvl(rcd_cust_master.order_multiples,0))||rpad(' ',20-length(to_char(nvl(rcd_cust_master.order_multiples,0))),' ') ||
                                          nvl(rcd_cust_master.brand,' ')||rpad(' ',30-length(nvl(rcd_cust_master.brand,' ')),' ') ||
                                          nvl(rcd_cust_master.sub_brand,' ')||rpad(' ',30-length(nvl(rcd_cust_master.sub_brand,' ')),' ') || 
                                          nvl(rcd_cust_master.pack_size,' ')||rpad(' ',30-length(nvl(rcd_cust_master.pack_size,' ')),' ') ||
                                          nvl(rcd_cust_master.pack_type,' ')||rpad(' ',30-length(nvl(rcd_cust_master.pack_type,' ')),' ') ||
                                          nvl(rcd_cust_master.item_category,' ')||rpad(' ',30-length(nvl(rcd_cust_master.item_category,' ')),' ') ||
                                          nvl(rcd_cust_master.item_status,' ')||rpad(' ',1-length(nvl(rcd_cust_master.item_status,' ')),' '));

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
