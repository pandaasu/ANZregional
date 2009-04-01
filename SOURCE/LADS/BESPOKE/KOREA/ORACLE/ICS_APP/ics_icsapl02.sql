/******************/
/* Package Header */
/******************/
create or replace package ics_app.ics_icsapl02 as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ICS
 Package : ics_icsapl02
 Owner   : ICS_APP
 Author  : Steve Gregan

 Description
 -----------
    ICS -> KOREA APOLLO INTRANSIT EXTRACT

 YYYY/MM   Author               Description
 -------   ------               -----------
 2009/04   Steve Gregan         Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ics_icsapl02;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_app.ics_icsapl02 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local Variables
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_timestamp varchar2(256 char);
      var_output varchar2(2000 char);
      type typ_outbound is table of varchar2(2000 char) index by binary_integer;
      tbl_outbound typ_outbound;

      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_kor_inb_summary is
         select t01.*
         from kor_inb_summary t01
         order by t01.xxxx asc;
      rcd_kor_inb_summary csr_kor_inb_summary%rowtype;

      cursor csr_kor_shp_summary is
         select t01.*
         from kor_shp_summary t01
         order by t01.xxxx asc;
      rcd_kor_shp_summary csr_kor_shp_summary%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the outbound array
      /*-*/
      tbl_outbound.delete;

      /*-*/
      /* Retrieve the inbound summary data
      /*-*/
      open csr_kor_inb_summary;
      loop
         fetch csr_kor_inb_summary into rcd_kor_inb_summary;
         if csr_kor_inb_summary%notfound then
            exit;
         end if;

         /*-*/
         /* Output the intransit interface data when required
         /*-*/
         if not(rcd_kor_inb_summary.xxxx is null) then
            var_output := lics_inbound_utility.get_variable('PLANT')||',';
            var_output := var_output||lics_inbound_utility.get_variable('DELIVERY')||',';
            var_output := var_output||lics_inbound_utility.get_variable('SOURCE_PLANT')||',';
            var_output := var_output||lics_inbound_utility.get_variable('SHIP_DATE')||',';
            var_output := var_output||lics_inbound_utility.get_variable('DELVERY_DATE')||',';
            var_output := var_output||lics_inbound_utility.get_variable('EXPIRY_DATE')||',';
            var_output := var_output||lics_inbound_utility.get_variable('MATERIAL')||',';
            var_output := var_output||lics_inbound_utility.get_variable('QTY')||',';
            var_output := var_output||lics_inbound_utility.get_variable('ORDERTYPE')||',';
            var_output := var_output||to_char(tbl_outbound.count + 1)||',';
            tbl_outbound(tbl_outbound.count + 1) := var_output;
         end if;

      end loop;
      close csr_kor_inb_summary;

      /*-*/
      /* Retrieve the shipment summary data
      /*-*/
      open csr_kor_shp_summary;
      loop
         fetch csr_kor_shp_summary into rcd_kor_shp_summary;
         if csr_kor_shp_summary%notfound then
            exit;
         end if;

         /*-*/
         /* Output the intransit interface data when required
         /*-*/
         if not(rcd_kor_shp_summary.xxxx is null) then
            var_output := lics_inbound_utility.get_variable('PLANT')||',';
            var_output := var_output||lics_inbound_utility.get_variable('DELIVERY')||',';
            var_output := var_output||lics_inbound_utility.get_variable('SOURCE_PLANT')||',';
            var_output := var_output||lics_inbound_utility.get_variable('SHIP_DATE')||',';
            var_output := var_output||lics_inbound_utility.get_variable('DELVERY_DATE')||',';
            var_output := var_output||lics_inbound_utility.get_variable('EXPIRY_DATE')||',';
            var_output := var_output||lics_inbound_utility.get_variable('MATERIAL')||',';
            var_output := var_output||lics_inbound_utility.get_variable('QTY')||',';
            var_output := var_output||lics_inbound_utility.get_variable('ORDERTYPE')||',';
            var_output := var_output||to_char(tbl_outbound.count + 1)||',';
            tbl_outbound(tbl_outbound.count + 1) := var_output;
         end if;

      end loop;
      close csr_kor_shp_summary;

      /*-*/
      /* Create the outbound interface when required
      /*-*/
      if tbl_outbound.count != 0 then
         var_timestamp := to_char(sysdate,'yyyymmddhh24miss');
         var_instance := lics_outbound_loader.create_interface('ICSAPL02', null, 'IN_INTRANSIT_SUP_STG_LADASU03.3.dat');
         for idx in 1..tbl_outbound.count loop
            lics_outbound_loader.append_data(tbl_outbound(idx)||to_char(tbl_outbound.count)||','||var_timestamp);
         end loop;
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
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ics_icsapl02;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_icsapl02 for ics_app.ics_icsapl02;
grant execute on ics_app.ics_icsapl02 to lics_app;