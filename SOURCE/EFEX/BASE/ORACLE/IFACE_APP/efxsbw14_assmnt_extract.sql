/******************/
/* Package Header */
/******************/
create or replace package efxsbw14_assmnt_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxsbw14_assmnt_extract
    Owner   : iface_app

    Description
    -----------
    Price Extract - EFEX to SAP BW

    This package extracts the Efex assessment that have been modified within
    the last history number of days and sends the extract file to the SAP BW environment.
    The ICS interface EFXSBW14 has been created for this purpose.

    1. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/09   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_history in varchar2 default 0);

end efxsbw14_assmnt_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxsbw14_assmnt_extract as

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
         select to_char(t01.inactive_date,'yyyymmdd') as inactive_date,
                t01.comm_title as comm_title,
                substr(t01.comm_text,1,60) as comm_text,
                t03.answer_text as answer_text,
                t04.sales_territory_name as sales_territory_name,
                t05.sales_area_name as sales_area_name,
                t07.segment_name as segment_name,
                decode(t07.business_unit_id,con_snack_id,'51',con_pet_id,'56','51') as division_code
           from comm t01,
                comm_response t02,
                comm_answer t03,
                sales_territory t04,
                sales_area t05,
                sales_region t06,
                segment t07,
                users t08
          where t01.comm_id = t02.comm_id
            and t02.comm_answer_id = t03.comm_answer_id
            and t02.user_id = t04.user_id
            and t04.sales_area_id = t05.sales_area_id
            and t05.sales_region_id = t06.sales_region_id
            and t06.segment_id = t07.segment_id
            and t02.user_id = t08.user_id
            and t01.comm_id in (select comm_id from comm where trunc(due_date) >= trunc(sysdate) - var_history)
            and t01.comm_type = 'Assessment'
            and t04.status = 'A'
            and t05.status = 'A'
            and t06.status = 'A'
            and t07.status = 'A'
            and t08.market_id = con_market_id
         order by t01.comm_id asc;
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
      var_instance := lics_outbound_loader.create_interface('EFXSBW14',null,'EFEX_ASSMNT_EXTRACT.DAT.'||to_char(sysdate,'yyyymmddhh24miss'));
      lics_outbound_loader.append_data('EFEX_ASSMNT_EXTRACT');

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
                                          '"'||replace(rcd_extract.segment_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sales_area_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.sales_territory_name,'"','""')||'";'||
                                          '"'||replace(rcd_extract.inactive_date,'"','""')||'";'||
                                          '"'||replace(rcd_extract.comm_title,'"','""')||'";'||
                                          '"'||replace(rcd_extract.comm_text,'"','""')||'";'||
                                          '"'||replace(rcd_extract.answer_text,'"','""')||'"');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXSBW14 EFEX_ASSMNT_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxsbw14_assmnt_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxsbw14_assmnt_extract for iface_app.efxsbw14_assmnt_extract;
grant execute on efxsbw14_assmnt_extract to public;
