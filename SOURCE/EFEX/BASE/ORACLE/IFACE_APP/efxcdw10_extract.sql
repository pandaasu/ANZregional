/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw10_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw10_extract
    Owner   : iface_app

    Description
    -----------
    Efex Item Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX items that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw10_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw10_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   con_group constant number := 1000;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_market in number, par_history in number default 0) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_history number;
      var_instance number(15,0);
      var_start boolean;
      var_count integer;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.item_id) as item_id,
                t01.item_code as item_code,
                t01.item_name as item_name,
                t01.rank as rank,
                to_char(t01.cases_layer) as cases_layer,
                to_char(t01.layers_pallet) as layers_pallet,
                to_char(t01.units_case) as units_case,
                t01.unit_measure as unit_measure,
                to_char(t01.tdu_price) as tdu_price,
                to_char(t01.rrp_price) as rrp_price,
                to_char(t01.mcu_price) as mcu_price,
                to_char(t01.rsu_price) as rsu_price,
                to_char(t01.min_order_qty) as min_order_qty,
                to_char(t01.order_multiples) as order_multiples,
                t01.topseller_flg as topseller_flg,
                t01.import_flg as import_flg,
                to_char(t01.item_source_id) as item_source_id,
                t01.pos_item_flg as pos_item_flg,
                t01.status as status
           from item t01
          where t01.market_id = par_market
            and trunc(t01.modified_date) >= trunc(sysdate) - var_history;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;
      var_count := 0;

      /*-*/
      /* Define number of days to extract
      /*-*/
      if par_history = 0 then
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
         /* Create outbound interface when required
         /*-*/
         if var_start = true or var_count = con_group then
            if var_start = false and lics_outbound_loader.is_created = true then
               lics_outbound_loader.finalise_interface;
            end if;
            var_instance := lics_outbound_loader.create_interface('EFXCDW10',null,'EFXCDW10.DAT');
            var_start := false;
            var_count := 0;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         var_count := var_count + 1;
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.item_id,'0')||rpad(' ',10-length(nvl(rcd_extract.item_id,'0')),' ') ||
                                          nvl(rcd_extract.item_code,' ')||rpad(' ',50-length(nvl(rcd_extract.item_code,' ')),' ') ||
                                          nvl(rcd_extract.item_name,' ')||rpad(' ',50-length(nvl(rcd_extract.item_name,' ')),' ') ||
                                          nvl(rcd_extract.rank,' ')||rpad(' ',10-length(nvl(rcd_extract.rank,' ')),' ') ||
                                          nvl(rcd_extract.cases_layer,'0')||rpad(' ',15-length(nvl(rcd_extract.cases_layer,'0')),' ') ||
                                          nvl(rcd_extract.layers_pallet,'0')||rpad(' ',15-length(nvl(rcd_extract.layers_pallet,'0')),' ') ||
                                          nvl(rcd_extract.units_case,'0')||rpad(' ',15-length(nvl(rcd_extract.units_case,'0')),' ') ||
                                          nvl(rcd_extract.unit_measure,' ')||rpad(' ',50-length(nvl(rcd_extract.unit_measure,' ')),' ') ||
                                          nvl(rcd_extract.tdu_price,'0')||rpad(' ',15-length(nvl(rcd_extract.tdu_price,'0')),' ') ||
                                          nvl(rcd_extract.rrp_price,'0')||rpad(' ',15-length(nvl(rcd_extract.rrp_price,'0')),' ') ||
                                          nvl(rcd_extract.mcu_price,'0')||rpad(' ',15-length(nvl(rcd_extract.mcu_price,'0')),' ') ||
                                          nvl(rcd_extract.rsu_price,'0')||rpad(' ',15-length(nvl(rcd_extract.rsu_price,'0')),' ') ||
                                          nvl(rcd_extract.min_order_qty,'0')||rpad(' ',15-length(nvl(rcd_extract.min_order_qty,'0')),' ') ||
                                          nvl(rcd_extract.order_multiples,'0')||rpad(' ',15-length(nvl(rcd_extract.order_multiples,'0')),' ') ||
                                          nvl(rcd_extract.topseller_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.topseller_flg,' ')),' ') ||
                                          nvl(rcd_extract.import_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.import_flg,' ')),' ') ||
                                          nvl(rcd_extract.item_source_id,'0')||rpad(' ',10-length(nvl(rcd_extract.item_source_id,'0')),' ') ||
                                          nvl(rcd_extract.pos_item_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.pos_item_flg,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

      end loop;
      close csr_extract;

      /*-*/
      /* Finalise Interface
      /*-*/
      if var_start = false and lics_outbound_loader.is_created = true then
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
      if var_start = false and lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW10 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw10_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw10_extract for iface_app.efxcdw10_extract;
grant execute on efxcdw10_extract to public;
