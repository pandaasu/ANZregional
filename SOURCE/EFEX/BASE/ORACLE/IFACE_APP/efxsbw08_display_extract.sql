/******************/
/* Package Header */
/******************/
create or replace package efxsbw08_display_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw08_display_extract
    Owner   : iface_app

    Description
    -----------
    Display Extract - EFEX to SAP BW

    This package extracts the Efex displays that have been modified within the last
    history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW08 has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/10   Steve Gregan   Created
    2008/11   Steve Gregan   Modified interface to include name as first row
    2008/11   Steve Gregan   Modified to send empty file (just first row)
    2008/11   Steve Gregan   Modified to extract by period grouping
    2009/06   Steve Gregan   China sales dedication - included business unit id to division

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxsbw08_display_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw08_display_extract as

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
         select * from (
         select to_char(t01.customer_id) as customer_id,
                to_char(t01.display_item_id) as display_item_id,
                to_char(t01.user_id) as user_id,
                to_char(t01.call_date,'yyyymmdd') as call_date,
                t01.display_in_store as display_in_store,
                rank() over (partition by t01.customer_id,
                                          t01.display_item_id
                                 order by t01.call_date desc) as rnkseq
           from display_distribution t01
          where (t01.customer_id,
                 t01.display_item_id,
                 t01.user_id,
                 t01.call_date) in (select t01.customer_id,
                                           t01.display_item_id,
                                           t01.user_id,
                                           max(call_date) as call_date
                                      from display_distribution t01,
                                           mars_date t02
                                     where trunc(t01.call_date) = trunc(t02.calendar_date)
                                       and (t01.user_id, t01.call_date) in (select user_id, call_date
                                                                              from call
                                                                             where trunc(modified_date) >= trunc(sysdate) - var_history)
                                     group by t01.customer_id,
                                              t01.display_item_id,
                                              t01.user_id,
                                              t02.mars_period)
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
                                       and t05.market_id = con_market_id)) t01
          where t01.rnkseq = 1;
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
      var_instance := lics_outbound_loader.create_interface('EFXSBW08',null,'EFEX_DISPLAY_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
      lics_outbound_loader.append_data('EFEX_DISPLAY_EXTRACT');

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
                                          '"'||replace(rcd_extract.customer_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_item_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.call_date,'"','""')||'";'||
                                          '"'||replace(rcd_extract.user_id,'"','""')||'";'||
                                          '"'||replace(rcd_extract.display_in_store,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW08 EFEX_DISPLAY_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw08_display_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw08_display_extract for iface_app.efxsbw08_display_extract;
grant execute on efxsbw08_display_extract to public;
