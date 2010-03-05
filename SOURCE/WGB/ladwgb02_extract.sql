/******************/
/* Package Header */
/******************/
create or replace package site_app.ladwgb02_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladwgb02_extract
    Owner   : site_app

    Description
    -----------
    China Customer Data - LADS to WGB



    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the LADS customer that have been modified within the last
    history number of days and sends the extract file to the Wrigleys Golden Bear environment.
    The ICS interface LADWGB02 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created
    2010/02   Steve Gregan   Added new interface fields

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end ladwgb02_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body site_app.ladwgb02_extract as

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
      var_exception varchar2(4000);

      var_history number;
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select decode(trim(t01.customer_code),null,';','"'||replace(trim(t01.customer_code),'"','""')||'";') as customer_code,
                decode(trim(decode(t03.customer_code,null,t02.customer_name,t03.customer_name)),null,';','"'||replace(trim(decode(t03.customer_code,null,t02.customer_name,t03.customer_name)),'"','""')||'";') as customer_name,
                decode(trim(t01.vendor_code),null,';','"'||replace(trim(t01.vendor_code),'"','""')||'";') as vendor_code,
                decode(trim(t04.sap_cn_sales_team_code),null,';','"'||replace(trim(t04.sap_cn_sales_team_code),'"','""')||'";') as sap_cn_sales_team_code,
                decode(trim(t04.sap_cn_sales_team_desc),null,';','"'||replace(trim(t04.sap_cn_sales_team_desc),'"','""')||'";') as sales_team_description,
                decode(trim(t05.order_block_flag),null,';','"'||replace(trim(t05.order_block_flag),'"','""')||'";') as order_block_flag,
                decode(trim(t01.account_group_code),null,';','"'||replace(trim(t01.account_group_code),'"','""')||'";') as account_group_code,
                decode(trim(t05.zt_cust_code),null,';','"'||replace(trim(t05.zt_cust_code),'"','""')||'";') as zt_cust_code,
                decode(trim(t05.sales_org_code),null,';','"'||replace(trim(t05.sales_org_code),'"','""')||'";') as sales_org_code,
                decode(trim(t05.distbn_chnl_code),null,';','"'||replace(trim(t05.distbn_chnl_code),'"','""')||'";') as distbn_chnl_code,
                decode(trim(t05.division_code),null,';','"'||replace(trim(t05.division_code),'"','""')||'";') as division_code,
                decode(trim(t05.za_cust_code),null,'','"'||replace(trim(t05.za_cust_code),'"','""')||'"') as za_cust_code
           from bds_cust_header t01,
                (select t01.customer_code,
                        max(ltrim(t01.name ||' '|| t01.name_02)) as customer_name
                   from bds_addr_customer t01
                  where t01.address_version = '*NONE'
                  group by t01.customer_code) t02,
                (select t01.customer_code,
                        max(ltrim(t01.name ||' '|| t01.name_02)) as customer_name
                   from bds_addr_customer t01
                  where t01.address_version = 'I'
                  group by t01.customer_code) t03,
                bds_customer_classfctn_en t04,
                (select t01.customer_code,
                        ltrim(t01.customer_code,'0') as hier_code,
                        t01.sales_org_code,
                        t01.distbn_chnl_code,
                        t01.division_code,
                        t01.order_block_flag,
                        t02.za_cust_code as za_cust_code,
                        t02.zt_cust_code as zt_cust_code
                   from (select t01.customer_code,
                                t01.sales_org_code,
                                t01.distbn_chnl_code,
                                t01.division_code,
                                max(t01.order_block_flag) as order_block_flag
                           from bds_cust_sales_area t01
                          where t01.sales_org_code = '135'
                            and t01.distbn_chnl_code = '10'
                          group by t01.customer_code, t01.sales_org_code, t01.distbn_chnl_code, t01.division_code) t01,
                        (select t01.customer_code,
                                t01.sales_org_code,
                                t01.distbn_chnl_code,
                                t01.division_code,
                                max(case when t01.partner_funcn_code = 'ZA' then t01.partner_cust_code end) as za_cust_code,
                                max(case when t01.partner_funcn_code = 'ZT' then t01.partner_cust_code end) as zt_cust_code
                           from bds_cust_sales_area_pnrfun t01
                          where t01.partner_funcn_code in ('ZA','ZT')
                          group by t01.customer_code, t01.sales_org_code, t01.distbn_chnl_code, t01.division_code) t02
                  where t01.customer_code = t02.customer_code(+)
                    and t01.sales_org_code = t02.sales_org_code(+)
                    and t01.distbn_chnl_code = t02.distbn_chnl_code(+)
                    and t01.division_code = t02.division_code(+)) t05
          where t01.customer_code = t02.customer_code(+)
            and t01.customer_code = t03.customer_code(+)
            and t01.customer_code = t04.sap_customer_code(+)
            and t01.customer_code = t05.customer_code
            and trunc(t01.bds_lads_date) >= trunc(sysdate) - var_history;
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
            var_instance := lics_outbound_loader.create_interface('LADWGB02',null,'MARS_GB_04_DICU.txt');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data(rcd_extract.customer_code ||
                                          rcd_extract.customer_name ||
                                          rcd_extract.vendor_code ||
                                          rcd_extract.sap_cn_sales_team_code ||
                                          rcd_extract.sales_team_description ||
                                          rcd_extract.order_block_flag ||
                                          rcd_extract.account_group_code ||
                                          rcd_extract.zt_cust_code ||
                                          rcd_extract.sales_org_code ||
                                          rcd_extract.distbn_chnl_code ||
                                          rcd_extract.division_code ||
                                          rcd_extract.za_cust_code);

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
         raise_application_error(-20000, 'FATAL ERROR - LADWGB02 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladwgb02_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladwgb02_extract for site_app.ladwgb02_extract;
grant execute on ladwgb02_extract to public;
