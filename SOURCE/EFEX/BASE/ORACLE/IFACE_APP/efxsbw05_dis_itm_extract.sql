/******************/
/* Package Header */
/******************/
create or replace package efxsbw05_dis_itm_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw05_dis_itm_extract
    Owner   : iface_app

    Description
    -----------
    Display Item Extract - EFEX to SAP BW

    This package extracts the Efex display items and sends the extract file
    to the SAP BW environment.
    The ICS interface EFXSBW05 has been created for this purpose.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/10   Steve Gregan   Created
    2008/11   Steve Gregan   Modified interface to include name as first row
    2008/11   Steve Gregan   Modified to send empty file (just first row)

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end efxsbw05_dis_itm_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw05_dis_itm_extract as

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
   con_division_code constant varchar2(10) := '51';
   con_company_code constant varchar2(10) := '135';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.display_item_id) as display_item_id,
                t01.display_item_name as display_item_name,
                t01.display_item_name_en as display_item_name_en,
                t02.segment_name as segment_name,
                t03.cust_type_name as cust_type_name,
                t04.cust_trade_channel_name as cust_trade_channel_name
           from display_item t01,
                segment t02,
                cust_type t03,
                cust_trade_channel t04
          where t01.segment_id = t02.segment_id(+)
            and t01.cust_type_id = t03.cust_type_id(+)
            and t01.cust_trade_channel_id = t04.cust_trade_channel_id(+);
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create outbound interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('EFXSBW05',null,'EFEX_DIS_ITM_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
      lics_outbound_loader.append_data('EFEX_DIS_ITM_EXTRACT');

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
                                          '"'||replace(con_division_code,'"','""')||'";'||
                                          '"'||replace(con_company_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_item_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_item_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_item_name_en,'"','""')||'";'||
                                          '"'||replace(rcd_extract.segment_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.cust_trade_channel_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.cust_type_name,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW05 EFEX_DIS_ITM_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw05_dis_itm_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw05_dis_itm_extract for iface_app.efxsbw05_dis_itm_extract;
grant execute on efxsbw05_dis_itm_extract to public;
