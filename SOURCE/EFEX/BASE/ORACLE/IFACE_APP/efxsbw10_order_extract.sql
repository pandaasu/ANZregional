/******************/
/* Package Header */
/******************/
create or replace package efxsbw10_order_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw10_order_extract
    Owner   : iface_app

    Description
    -----------
    Order Extract - EFEX to SAP BW

    This package extracts the Efex order items that have been modified within the last
    history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW10 has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/10   Steve Gregan   Created
    2008/10   Steve Gregan   Added order line status check (only active orders and order lines)
    2008/10   Steve Gregan   Changed order value calculation
    2008/11   Steve Gregan   Modified interface to include name as first row
    2008/11   Steve Gregan   Modified to send empty file (just first row)
    2009/06   Steve Gregan   China sales dedication - included business unit id to division

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxsbw10_order_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw10_order_extract as

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
         select to_char(t01.order_id) as order_id,
                to_char(t01.order_date,'yyyymmdd') as order_date,
                to_char(t01.customer_id) as customer_id,
                to_char(t01.distributor_id) as distributor_id,
                to_char(t01.user_id) as user_id,
                decode(t02.uom,'TDU',to_char(t02.order_qty),
                               'MCU',to_char(round(t02.order_qty/nvl(t03.mcu_per_tdu,1),2)),
                               'RSU',to_char(round(t02.order_qty/nvl(t03.units_case,1),2)),
                               to_char(t02.order_qty)) as order_qty,
                to_char(round(decode(t02.uom,'TDU',t02.order_qty,
                                             'MCU',t02.order_qty/nvl(t03.mcu_per_tdu,1),
                                             'RSU',t02.order_qty/nvl(t03.units_case,1),
                                             t02.order_qty)*nvl(t03.tdu_price,0),2),'fm999999990.00') as order_value,
                t03.item_code as item_code,
                decode(t04.business_unit_id,con_snack_id,'51',con_pet_id,'56','51') as division_code
           from orders t01,
                order_item t02,
                item t03,
                customer t04
          where t01.order_id = t02.order_id
            and t02.item_id = t03.item_id(+)
            and t01.customer_id = t04.customer_id
            and t01.status = 'A'
            and t02.status = 'A'
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
            and (t01.order_id in (select order_id from orders where trunc(modified_date) >= trunc(sysdate) - var_history) or
                 t01.order_id in (select distinct(order_id) from order_item where trunc(modified_date) >= trunc(sysdate) - var_history));
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
      var_instance := lics_outbound_loader.create_interface('EFXSBW10',null,'EFEX_ORDER_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
      lics_outbound_loader.append_data('EFEX_ORDER_EXTRACT');

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
                                          '"'||replace(rcd_extract.order_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.order_date,'"','""')||'";'||
                                          '"'||replace(rcd_extract.customer_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.distributor_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.item_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.order_qty,'"','""')||'";'||
                                          '"'||replace(rcd_extract.order_value,'"','""')||'";'||
                                          '"'||replace(rcd_extract.user_id,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW10 EFEX_ORDER_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw10_order_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw10_order_extract for iface_app.efxsbw10_order_extract;
grant execute on efxsbw10_order_extract to public;
