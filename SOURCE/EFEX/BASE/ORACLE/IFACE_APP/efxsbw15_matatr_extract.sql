/******************/
/* Package Header */
/******************/
create or replace package efxsbw15_matatr_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw15_matatr_extract
    Owner   : iface_app

    Description
    -----------
    Material Extract - EFEX to SAP BW

    This package extracts the Efex materials that have been modified within the last
    history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW15 has been created for this purpose.

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
   procedure execute(par_history in varchar2 default 0);

end efxsbw15_matatr_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw15_matatr_extract as

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
         select t01.item_code as item_code,
                t01.topseller_flg as topseller_flg,
                to_char(nvl(t01.tdu_price,0)) as tdu_price,
                to_char(nvl(t01.rsu_price,0)) as rsu_price,
                to_char(t01.modified_date,'yyyymmdd') as modified_date
           from item t01
          where t01.market_id = con_market_id
            and t01.item_id in (select distinct(item_id) from item where trunc(modified_date) >= trunc(sysdate) - var_history);
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
      var_instance := lics_outbound_loader.create_interface('EFXSBW15',null,'EFEX_MATATR_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
      lics_outbound_loader.append_data('EFEX_MATATR_EXTRACT');

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
                                          '"'||replace(rcd_extract.topseller_flg,'"','""')||'";'||
                                          '"'||replace(rcd_extract.tdu_price,'"','""')||'";'||
                                          '"'||replace(rcd_extract.rsu_price,'"','""')||'";'||
                                          '"'||replace(rcd_extract.modified_date,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW15 EFEX_MATATR_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw15_matatr_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw15_matatr_extract for iface_app.efxsbw15_matatr_extract;
grant execute on efxsbw15_matatr_extract to public;
