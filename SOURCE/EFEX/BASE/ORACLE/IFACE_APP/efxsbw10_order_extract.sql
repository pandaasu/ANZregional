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

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_sales_org_code in varchar2,
                     par_dstbn_chnl_code in varchar2,
                     par_division_code in varchar2,
                     par_company_code in varchar2,
                     par_history in varchar2 default 0);

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

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_sales_org_code in varchar2,
                     par_dstbn_chnl_code in varchar2,
                     par_division_code in varchar2,
                     par_company_code in varchar2,
                     par_history in varchar2 default 0) is

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
         select to_char(t01.order_id) as order_id,
                to_char(t01.order_date,'yyyymmdd') as order_date,
                to_char(t01.customer_id) as customer_id,
                to_char(t01.user_id) as user_id,
                to_char(t02.order_qty) as order_qty,
                to_char(0,'fm999999990.00') as order_value,
                t03.distcust_code as distcust_code,
                t04.item_code as item_code
           from orders t01,
                order_item t02,
                distributor_cust t03,
                item t04
          where t01.order_id = t02.order_id
            and t01.customer_id = t03.customer_id(+)
            and t01.distributor_id = t03.distributor_id(+)
            and t02.item_id = t03.item_id(+)
            and t01.status = 'A'
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t02.modified_date) >= trunc(sysdate) - var_history);
      rcd_extract csr_extract%rowtype;




???????? how to get only market 4
???????? how to convert UOM to CASE
???????? how to get the value per item (value only stored at the ORDERS level)

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
            var_instance := lics_outbound_loader.create_interface('EFXSBW10',null,'EFEX_ORDER_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
            var_start := false;
         end if;

         /*-*/
         /* Append data lines when required
         /*-*/
         lics_outbound_loader.append_data('"'||replace(par_sales_org_code,'"','""')||'";'||
                                          '"'||replace(par_dstbn_chnl_code,'"','""')||'";'||
                                          '"'||replace(par_division_code,'"','""')||'";'||
                                          '"'||replace(par_company_code,'"','""')||'";'||
                                          '"'||replace(order_id,'"','""')||'";'||
                                          '"'||replace(order_date,'"','""')||'";'||
                                          '"'||replace(customer_id,'"','""')||'";'||
                                          '"'||replace(distcust_code,'"','""')||'";'||
                                          '"'||replace(item_code,'"','""')||'";'||
                                          '"'||replace(order_qty,'"','""')||'";'||
                                          '"'||replace(order_value,'"','""')||'";'||
                                          '"'||replace(user_id,'"','""')||'"');

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
