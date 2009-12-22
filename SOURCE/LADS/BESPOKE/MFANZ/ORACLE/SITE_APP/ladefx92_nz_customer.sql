/******************/
/* Package Header */
/******************/
create or replace package site_app.ladefx92_nz_customer as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx92_nz_customer
    Owner   : site_app

    Description
    -----------
    New Zealand Customer Master Data - LADS to EFEX

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ladefx92_nz_customer;
/

/****************/
/* Package Body */
/****************/
create or replace package body site_app.ladefx92_nz_customer as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 5;

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
         select ltrim(t01.cust_code, '0') as customer_code,
                t01.name as customer_name,
                ltrim(t01.house_no||' '||t01.street) as address_1,
                t01.city as city,
                t01.region as state,
                t01.postl_cod1 as postcode,
                t01.telephone as phone_number,
                t01.fax as fax_number,
                t02.banner_desc as affiliation,
                t03.pos_frmt_desc as cust_type
           from mfanz_cust t01,
                banner t02,
                pos_frmt t03
          where t01.cust_accnt_group = '0001'
            and t01.banner_code = t02.banner_code
            and t01.pos_format_code = t03.pos_frmt_code;
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
            var_instance := lics_outbound_loader.create_interface('LADEFX92',null,'LADEFX92.dat');
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
                                          nvl(rcd_cust_master.cust_type,' ')||rpad(' ',50-length(nvl(rcd_cust_master.cust_type,' ')),' '));

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
         raise_application_error(-20000, 'FATAL ERROR - LADEFX92 NEW ZEALAND CUSTOMER - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ladefx92_nz_customer;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx92_nz_customer for site_app.ladefx92_nz_customer;
grant execute on ladefx92_nz_customer to public;
