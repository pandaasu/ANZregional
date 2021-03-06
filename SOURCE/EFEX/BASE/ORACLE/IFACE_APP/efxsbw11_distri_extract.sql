/******************/
/* Package Header */
/******************/
create or replace package efxsbw11_distri_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw11_distri_extract
    Owner   : iface_app

    Description
    -----------
    Distribution Extract - EFEX to SAP BW

    This package extracts the Efex distribution that have been modified within the last
    history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW11 has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/10   Steve Gregan   Created
    2008/10   Steve Gregan   Modified the distibution total quantity logic
    2008/11   Steve Gregan   Modified interface to include name as first row
    2008/11   Steve Gregan   Modified to send empty file (just first row)
    2009/06   Steve Gregan   China sales dedication - included business unit id to division
    2009/09   Steve Gregan   Modified to add facing quantity to extract
    2009/10   Steve Gregan   Modified to add sell_price to extract

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxsbw11_distri_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw11_distri_extract as

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
      var_save_id number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.customer_id) as customer_id,
                to_char(nvl(t02.inventory_qty,0)) as inventory_qty,
                to_char(nvl(t02.facing_qty,0)) as facing_qty,
                to_char(nvl(t02.sell_price,0)) as sell_price,
                to_char(t01.call_date,'yyyymmdd') as call_date,
                to_char(nvl(t04.total_qty,0)) as total_qty,
                to_char(t01.user_id) as user_id,
                t03.item_code as item_code,
                decode(t05.business_unit_id,con_snack_id,'51',con_pet_id,'56','51') as division_code
           from call t01,
                distribution t02,
                item t03,
                distribution_total t04,
                customer t05
          where t01.customer_id = t02.customer_id
            and t02.item_id = t03.item_id(+)
            and t02.customer_id = t04.customer_id(+)
            and 0 = t04.item_group_id(+)
            and t01.customer_id = t05.customer_id
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
         order by t01.customer_id asc,
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
      var_instance := lics_outbound_loader.create_interface('EFXSBW11',null,'EFEX_DISTRI_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
      lics_outbound_loader.append_data('EFEX_DISTRI_EXTRACT');

      /*-*/
      /* Open cursor for output
      /*-*/
      var_save_id := -1;
      open csr_extract;
      loop
         fetch csr_extract into rcd_extract;
         if csr_extract%notfound then
            exit;
         end if;

         /*-*/
         /* Change in customer
         /*-*/
         if rcd_extract.customer_id != var_save_id then
            var_save_id := rcd_extract.customer_id;
         else
            rcd_extract.total_qty := 0;
         end if;

         /*-*/
         /* Append data lines when required
         /*-*/
         lics_outbound_loader.append_data('"'||replace(con_sales_org_code,'"','""')||'";'||
                                          '"'||replace(con_dstbn_chnl_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.division_code,'"','""')||'";'||
                                          '"'||replace(con_company_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.customer_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.item_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.inventory_qty,'"','""')||'";'||
                                          '"'||replace(rcd_extract.call_date,'"','""')||'";'||
                                          '"'||replace(rcd_extract.total_qty,'"','""')||'";'||
                                          '"'||replace(rcd_extract.user_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.facing_qty,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sell_price,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW11 EFEX_DISTRI_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw11_distri_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw11_distri_extract for iface_app.efxsbw11_distri_extract;
grant execute on efxsbw11_distri_extract to public;
