/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxwgb01_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxwgb01_extract
    Owner   : iface_app

    Description
    -----------
    China Customer Data - EFEX to WGB

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)


    This package extracts the EFEX customer that have been modified within the last
    history number of days and sends the extract file to the Wrigleys Golden Bear environment.
    The ICS interface EFXWGB01 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxwgb01_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxwgb01_extract as

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
         select decode(trim(t01.customer_code),null,';','"'||replace(trim(t01.customer_code),'"','""')||'";') as customer_code,
                decode(trim(t01.customer_name),null,';','"'||replace(trim(t01.customer_name),'"','""')||'";') as customer_name,
                decode(trim(t02.cust_type_name),null,';','"'||replace(trim(t02.cust_type_name),'"','""')||'";') as cust_type_name,
                decode(trim(t01.geo_level5_code),null,';','"'||replace(trim(t01.geo_level5_code),'"','""')||'";') as geo_level5_code,
                decode(trim(t09.distcust_code),null,';','"'||replace(trim(t09.distcust_code),'"','""')||'";') as distcust_code,
                decode(trim(t07.segment_name),null,';','"'||replace(trim(t07.segment_name),'"','""')||'";') as segment_name,
                decode(trim(t01.active_flg),null,';','"'||replace(trim(t01.active_flg),'"','""')||'"') as active_flg
           from customer t01,
                cust_type t02,
                (select t01.customer_id,
                        t01.sales_territory_id,
                        t01.modified_date
                   from (select t01.customer_id,
                                t01.sales_territory_id,
                                t01.modified_date,
                                rank() over (partition by t01.customer_id
                                                 order by t01.sales_territory_id asc) as rnkseq
                           from cust_sales_territory t01
                          where t01.status = 'A'
                            and t01.primary_flg = 'Y') t01
                  where t01.rnkseq = 1) t03,
                sales_territory t04,
                sales_area t05,
                sales_region t06,
                segment t07,
                geo_hierarchy t08,
                distributor_cust t09
          where t01.cust_type_id = t02.cust_type_id(+)
            and t01.customer_id = t03.customer_id(+)
            and t03.sales_territory_id = t04.sales_territory_id(+)
            and t04.sales_area_id = t05.sales_area_id(+)
            and t05.sales_region_id = t06.sales_region_id(+)
            and t06.segment_id = t07.segment_id(+)
            and t01.geo_level1_code = t08.geo_level1_code(+)
            and t01.geo_level2_code = t08.geo_level2_code(+)
            and t01.geo_level3_code = t08.geo_level3_code(+)
            and t01.geo_level4_code = t08.geo_level4_code(+)
            and t01.geo_level5_code = t08.geo_level5_code(+)
            and t01.business_unit_id = t08.business_unit_id(+)
            and t01.customer_id = t09.customer_id(+)
            and t01.distributor_id = t09.distributor_id(+)
            and t01.market_id = con_market_id
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t02.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t03.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t04.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t05.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t06.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t07.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t09.modified_date) >= trunc(sysdate) - var_history);
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
            var_instance := lics_outbound_loader.create_interface('EFXWGB01',null,'MARS_GB_06_OTLS.txt');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data(rcd_customer.customer_code ||
                                          rcd_customer.customer_name ||
                                          rcd_customer.cust_type_name ||
                                          rcd_customer.geo_level5_code ||
                                          rcd_customer.distcust_code ||
                                          rcd_customer.segment_name ||
                                          rcd_customer.active_flg);

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
         raise_application_error(-20000, 'FATAL ERROR - EFXWGB02 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxwgb01_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxwgb01_extract for iface_app.efxwgb01_extract;
grant execute on efxwgb01_extract to public;
