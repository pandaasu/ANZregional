create or replace 
PACKAGE BODY          PXIPMX05_EXTRACT as

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

Mal, Suggest we move interface constants into the top formatting query.  


select '347001'
     ||rpad(vendor_code,10)
     ||rpad(company_code,4)
     ||rpad(sales_org_code,4)
     ||rpad(distribution_channel,2)
     ||rpad(division,2)
     ||PACSVendor
     ||rpad(substr(Longname,1,40),40)
     ||tax_exempt
     ||rpad(attribute,20)
     ||rpad(pxdivcode,10)
     ||rpad(pxcompanycode,10) as extract_line
from (
select a.vendor_code  AS vendor_code
     , b.company_code AS company_code
     , '149'          AS sales_org_code
     , ' '            AS distribution_channel
     , ' '            AS division
     , 'Y'            AS PACSVendor
     , a.vendor_name_01 ||' '|| a.vendor_name_02 AS Longname
     , '1'            AS tax_exempt
     , a.customer_code AS Attribute
     , '149'          AS pxdivcode
     , '149'          AS pxcompanycode
from bds_vend_header a, bds_vend_comp b
where a.vendor_code = b.vendor_code
and b.company_code = '149'
and group_key like 'PMX%'
and a.posting_block_flag is null
and A.PURCHASING_BLOCK_FLAG is null
)


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
            var_instance := lics_outbound_loader.create_interface('PXIPMX05');
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

end PXIPMX05_EXTRACT;