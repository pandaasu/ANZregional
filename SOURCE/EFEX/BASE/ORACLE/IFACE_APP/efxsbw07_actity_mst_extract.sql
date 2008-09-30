/******************/
/* Package Header */
/******************/
create or replace package efxsbw07_actity_mst_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw07_actity_mst_extract
    Owner   : iface_app

    Description
    -----------
    Activity Master Extract - EFEX to SAP BW

    This package extracts the Efex activity master data and sends the extract file
    to the SAP BW environment.
    The ICS interface EFXSBW07 has been created for this purpose.

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
                     par_company_code in varchar2);

end efxsbw07_actity_mst_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw07_actity_mst_extract as

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
   procedure execute(par_sales_org_code in varchar2,
                     par_dstbn_chnl_code in varchar2,
                     par_division_code in varchar2,
                     par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_start boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.activity_item_id) as activity_item_id,
                t01.activity_item_name as activity_item_name,
                t01.activity_item_name_en as activity_item_name_en,
                to_char(t01.cust_trade_channel_id) as cust_trade_channel_id,
                t02.segment_name as segment_name,
                t03.cust_type_name as cust_type_name
           from activity_item t01,
                segment t02,
                cust_type t03
          where t01.segment_id = t02.segment_id(+)
            and t01.cust_type_id = t03.cust_type_id(+);
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
            var_instance := lics_outbound_loader.create_interface('EFXSBW07',null,'EFEX_ACTITY_MST_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
            var_start := false;
         end if;

         /*-*/
         /* Append data lines when required
         /*-*/
         lics_outbound_loader.append_data('"'||replace(par_sales_org_code,'"','""')||'";'||
                                          '"'||replace(par_dstbn_chnl_code,'"','""')||'";'||
                                          '"'||replace(par_division_code,'"','""')||'";'||
                                          '"'||replace(par_company_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.activity_item_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.activity_item_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.activity_item_name_en,'"','""')||'";'||
                                          '"'||replace(rcd_extract.segment_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.cust_trade_channel_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.cust_type_name,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW07 EFEX_ACTITY_MST_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw07_actity_mst_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw07_actity_mst_extract for iface_app.efxsbw07_actity_mst_extract;
grant execute on efxsbw07_actity_mst_extract to public;
