/******************/
/* Package Header */
/******************/
create or replace package efxsbw14_price_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw14_price_extract
    Owner   : iface_app

    Description
    -----------
    Price Extract - EFEX to SAP BW

    This package extracts the Efex distribution price that have been modified within
    the last history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW14 has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/09   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxsbw14_price_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw14_price_extract as

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
   con_company_code constant varchar2(10) := '135';
   con_snack_id constant number := 5;
   con_pet_id constant number := 6;

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

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.customer_id) as customer_id,
                to_char(t01.call_date,'yyyymmdd') as call_date,
                to_char(nvl(t02.sell_price,0)) as sell_price,
                t03.item_code as item_code,
                to_char(nvl(t03.rsu_price,0)) as list_price,
                decode(t04.business_unit_id,con_snack_id,'51',con_pet_id,'56','51') as division_code
           from call t01,
                distribution t02,
                item t03,
                customer t04
          where t01.customer_id = t02.customer_id
            and t02.item_id = t03.item_id(+)
            and t01.customer_id = t04.customer_id
            and (t01.customer_id, t01.call_date) in (select customer_id, max(call_date) from call where trunc(modified_date) >= trunc(sysdate) - var_history group by customer_id)
            and t01.customer_id in (select t01.customer_id
                                      from customer t01,
                                           cust_type t02,
                                           cust_trade_channel t03,
                                           cust_channel t04,
                                           market t05
                                     where t01.cust_type_id = t02.cust_type_id(+)
                                       and t02.cust_trade_channel_id = t03.cust_trade_channel_id(+)
                                       and t03.cust_channel_id = t04.cust_channel_id(+)
                                       and t04.market_id = t05.market_id(+)
                                       and t05.market_id = con_market_id)
         order by t01.call_date asc,
                  t01.customer_id asc,
                  t03.item_code asc;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Define number of days to extract
      /*-*/
      if (par_history = 0) then
         var_history := 99999;
      else
         var_history := par_history;
      end if;

      /*-*/
      /* Create outbound interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('EFXSBW14',null,'EFEX_PRICE_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
      lics_outbound_loader.append_data('EFEX_PRICE_EXTRACT');

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
         /* Append data lines when required
         /*-*/
         lics_outbound_loader.append_data('"'||replace(con_sales_org_code,'"','""')||'";'||
                                          '"'||replace(con_dstbn_chnl_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.division_code,'"','""')||'";'||
                                          '"'||replace(con_company_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.call_date,'"','""')||'";'||
                                          '"'||replace(rcd_extract.customer_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.item_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sell_price,'"','""')||'";'||
                                          '"'||replace(rcd_extract.list_price,'"','""')||'"');

      end loop;
      close csr_extract;

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW14 EFEX_PRICE_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw14_price_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw14_price_extract for iface_app.efxsbw14_price_extract;
grant execute on efxsbw14_price_extract to public;
