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
 2009/05   Trevor Keon          Added street to the address field

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
         select ltrim(t01.customer_code,'0') as customer_code,
                trim(t03.name || ' ' || t03.name_02 || ' ' || t03.name_03 || ' ' || t03.name_04) as customer_name,
                t01.tax_number_02 as bus_reg_num,
                t01.business_type as bus_type,
                t01.industry_type as bus_category,
                t01.representative_name as president_name,
                t03.city_post_code as post_code,
                trim(t03.street || ' ' || t03.street_supplement_01 || ' ' || t03.street_supplement_02) as address,
                t04.phone_number as telephone,
                t05.fax_number as fax,
                trim(t06.name || ' ' || t06.name_02 || ' ' || t06.name_03 || ' ' || t06.name_04) as sales_person,
                t07.phone_number as sales_telephone
         from bds_cust_header t01,
              (select t01.customer_code,
                      max(case when t01.partner_funcn_code = 'ZB' then t01.partner_cust_code end) as salesman_code
               from bds_cust_sales_area_pnrfun t01
               where t01.partner_funcn_code in ('ZB')
               group by t01.customer_code) t02,
              (select *
                 from (select t01.*,
                              rank() over (partition by t01.address_code
                                               order by t01.address_version) as rnkseq
                         from bds_addr_detail t01
                        where t01.address_type = 'KNA1'
                          and t01.address_context = 1)
                where rnkseq = 1) t03,
              (select *
                 from (select t01.*,
                              rank() over (partition by t01.address_code
                                               order by t01.address_sequence) as rnkseq
                         from bds_addr_phone t01
                        where t01.address_type = 'KNA1'
                          and t01.address_context = 1)
                where rnkseq = 1) t04,
              (select *
                 from (select t01.*,
                              rank() over (partition by t01.address_code
                                               order by t01.address_sequence) as rnkseq
                         from bds_addr_fax t01
                        where t01.address_type = 'KNA1'
                          and t01.address_context = 1)
                where rnkseq = 1) t05,
              (select *
                 from (select t01.*,
                              rank() over (partition by t01.address_code
                                               order by t01.address_version) as rnkseq
                         from bds_addr_detail t01
                        where t01.address_type = 'KNA1'
                          and t01.address_context = 1)
                where rnkseq = 1) t06,
              (select *
                 from (select t01.*,
                              rank() over (partition by t01.address_code
                                               order by t01.address_sequence) as rnkseq
                         from bds_addr_phone t01
                        where t01.address_type = 'KNA1'
                          and t01.address_context = 1)
                where rnkseq = 1) t07,
              bds_cust_sales_area t08
         where t01.customer_code = t02.customer_code(+)
           and t01.customer_code = t03.address_code(+)
           and t01.customer_code = t04.address_code(+)
           and t01.customer_code = t05.address_code(+)
           and t02.salesman_code = t06.address_code(+)
           and t02.salesman_code = t07.address_code(+)
           and t01.customer_code = t08.customer_code
           and t08.sales_org_code = '157'
           and t08.distbn_chnl_code = '10'
           and t08.division_code = '51'
           and trunc(t01.bds_lads_date) >= trunc(sysdate) - var_days
         order by t01.customer_code;
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
--      lics_outbound_loader.append_data('<CTL_NAME>APB002CTKR</CTL_NAME>');
      lics_outbound_loader.append_data('<CTL_NAME>APP002CPKR</CTL_NAME>');
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
         lics_outbound_loader.append_data('<HDR_CUSTOMER_CODE>' || format_xml_str(rec_cust_master.customer_code) || '</HDR_CUSTOMER_CODE>');
         lics_outbound_loader.append_data('<HDR_CUSTOMER_NAME>' || nvl(format_xml_str(rec_cust_master.customer_name),' ') || '</HDR_CUSTOMER_NAME>');
         lics_outbound_loader.append_data('<HDR_BUS_REG_NUM>' || nvl(format_xml_str(rec_cust_master.bus_reg_num),' ') || '</HDR_BUS_REG_NUM>');
         lics_outbound_loader.append_data('<HDR_BUS_TYPE>' || nvl(format_xml_str(rec_cust_master.bus_type),' ') || '</HDR_BUS_TYPE>');
         lics_outbound_loader.append_data('<HDR_BUS_CATEGORY>' || nvl(format_xml_str(rec_cust_master.bus_category),' ') || '</HDR_BUS_CATEGORY>');
         lics_outbound_loader.append_data('<HDR_PRESIDENT_NAME>' || nvl(format_xml_str(rec_cust_master.president_name),' ') || '</HDR_PRESIDENT_NAME>');
         lics_outbound_loader.append_data('<HDR_POST_CODE>' || nvl(format_xml_str(rec_cust_master.post_code),' ') || '</HDR_POST_CODE>');
         lics_outbound_loader.append_data('<HDR_ADDRESS>' || nvl(format_xml_str(rec_cust_master.address),' ') || '</HDR_ADDRESS>');
         lics_outbound_loader.append_data('<HDR_TELEPHONE>' || nvl(format_xml_str(rec_cust_master.telephone),' ') || '</HDR_TELEPHONE>');
         lics_outbound_loader.append_data('<HDR_FAX>' || nvl(format_xml_str(rec_cust_master.fax),' ') || '</HDR_FAX>');
         lics_outbound_loader.append_data('<HDR_SALES_PERSON>' || nvl(format_xml_str(rec_cust_master.sales_person),' ') || '</HDR_SALES_PERSON>');
         lics_outbound_loader.append_data('<HDR_SALES_TELEPHONE>' || nvl(format_xml_str(rec_cust_master.sales_telephone),' ') || '</HDR_SALES_TELEPHONE>');
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
         raise_application_error(-20000,'ICS_LADWMS04 - FORMAT_XML_STR - Error formatting string ['||par_string||'] - ['||SQLERRM||']');

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