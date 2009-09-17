/******************/
/* Package Header */
/******************/
create or replace package efxsbw02_coremat_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw02_coremat_extract
    Owner   : iface_app

    Description
    -----------
    Core Material Extract - EFEX to SAP BW

    This package extracts the Efex core materials that have been modified within the last
    history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW02 has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/10   Steve Gregan   Created
    2008/11   Steve Gregan   Modified interface to include name as first row
    2008/11   Steve Gregan   Modified to send empty file (just first row)
    2009/09   Steve Gregan   Modified to add hero sku to the extract

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxsbw02_coremat_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw02_coremat_extract as

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
         select to_char(t01.range_id) as range_id,
                t03.item_code as item_code
           from range t01,
                range_item t02,
                item t03
          where t01.range_id = t02.range_id
            and t02.item_id = t03.item_id(+)
            and t01.market_id = con_market_id
            and (t02.required_flg = 'Y' or (t02.required_flg = 'N' and t03.topseller_flg = 'Y'))
            and (t01.range_id in (select range_id from range where trunc(modified_date) >= trunc(sysdate) - var_history) or
                 t01.range_id in (select distinct(range_id) from range_item where trunc(modified_date) >= trunc(sysdate) - var_history) or
                 t02.item_id in (select distinct(item_id) from item where trunc(modified_date) >= trunc(sysdate) - var_history));
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
      var_instance := lics_outbound_loader.create_interface('EFXSBW02',null,'EFEX_COREMAT_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
      lics_outbound_loader.append_data('EFEX_COREMAT_EXTRACT');

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
         lics_outbound_loader.append_data('"'||replace(rcd_extract.item_code,'"','""')||'";'||
                                          '"'||replace(rcd_extract.range_id,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW02 EFEX_COREMAT_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw02_coremat_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw02_coremat_extract for iface_app.efxsbw02_coremat_extract;
grant execute on efxsbw02_coremat_extract to public;
