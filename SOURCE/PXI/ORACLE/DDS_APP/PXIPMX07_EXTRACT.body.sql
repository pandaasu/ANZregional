create or replace 
PACKAGE BODY          PXIPMX07_EXTRACT as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(i_datime in date default sysdate-1) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_data varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_input is
        select RPAD(xx,10,' ') ||
        RPAD(xx,10,' ') ||
        RPAD(xx,10,' ') ||
        RPAD(xx,10,' ') ||
          as data 
        from 


select 
  hdr_division_code,
  company_code,
  sold_to_cust_code,
  billing_doc_num, 
  billing_doc_line_num, 
  matl_entd,
  (select order_eff_date from dw_order_base t0 where t0.order_doc_num = t1.order_doc_num and t0.order_doc_line_num = t1.order_doc_line_num) as order_eff_date,
  billing_eff_date,
  billed_qty_base_uom, 
  billed_gsv,
  doc_currcy_code
from dw_sales_base t1 where company_code = 149 and creatn_date = to_date('31/12/2001','DD/MM/YYYY');


select 
  t1.hdr_division_code,
  t1.company_code,
  t1.sold_to_cust_code,
  t1.billing_doc_num, 
  t1.billing_doc_line_num, 
  t1.matl_entd,
  t2.order_eff_date,
  t1.billing_eff_date,
  t1.billed_qty_base_uom, 
  t1.billed_gsv,
  t1.doc_currcy_code
from dw_sales_base t1,
     dw_order_base t2
where 
  t1.company_code = 149 and t1.creatn_date = to_date('31/12/2001','DD/MM/YYYY') and
  t1.order_doc_num = t2.order_doc_num (+) and
  t1.order_doc_line_num = t2.order_doc_line_num (+)

select * from dw_order_base

select * from dw_sales_base

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Retrieve the rows
      /*-*/
      open csr_input;
      loop
         fetch csr_input into var_data;
         if csr_input%notfound then
            exit;
         end if;

         /*-*/
         /* Create the new interface when required
         /*-*/
         if lics_outbound_loader.is_created = false then
            var_instance := lics_outbound_loader.create_interface('PXIPMX07_EXTRACT');
         end if;

         /*-*/
         /* Append the interface data
         /*-*/
         lics_outbound_loader.append_data(var_data);

      end loop;
      close csr_input;

      /*-*/
      /* Finalise the interface when required
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
         rollback;
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end PXIPMX07_EXTRACT;