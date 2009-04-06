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
      var_tot_order number;
      var_fut_spply number;

      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_kor_inb_summary is
         select t01.*
           from kor_inb_summary t01
          order by t01.plant asc,
                   t01.material asc,
                   t01.ship_period asc;
      rcd_kor_inb_summary csr_kor_inb_summary%rowtype;

      cursor csr_kor_shp_summary is
         select t01.*,
                t02.shipped_qty,
                t03.ship_date,
                rank() over (partition by t01.warehouse,
                                          t01.material,
                                          t01.ship_period
                                 order by t01.expt_avail_date asc) as rnkseq
           from kor_shp_summary t01,
                (select t01.plant,
                        t01.material,
                        t01.ship_period,
                        sum(to_number(nvl(t01.qty,0))) as shipped_qty
                   from kor_inb_summary t01
                  group by t01.plant,
                           t01.material,
                           t01.ship_period) t02,
                (select to_char(t01.mars_period) as ship_period,
                        to_char(max(t01.calendar_date),'yyyymmdd') as ship_date
                   from mars_date t01
                  group by to_char(t01.mars_period)) t03
          where t01.warehouse = t02.plant(+)
            and t01.material = t02.material(+)
            and t01.ship_period = t02.ship_period(+)
            and t01.ship_period = t03.ship_period(+)
          order by t01.warehouse asc,
                   t01.material asc,
                   t01.ship_period asc,
                   t01.expt_avail_date asc;
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
         if rcd_kor_inb_summary.rsmn_date is null then
            var_output := rcd_kor_inb_summary.plant||',';
            var_output := var_output||rcd_kor_inb_summary.delivery||',';
            var_output := var_output||rcd_kor_inb_summary.source_plant||',';
            var_output := var_output||rcd_kor_inb_summary.ship_date||',';
            var_output := var_output||rcd_kor_inb_summary.delivery_date||',';
            var_output := var_output||rcd_kor_inb_summary.expiry_date||',';
            var_output := var_output||rcd_kor_inb_summary.material||',';
            var_output := var_output||rcd_kor_inb_summary.qty||',';
            var_output := var_output||'F'||',';
            var_output := var_output||rcd_kor_inb_summary.ordertype||',';
            var_output := var_output||'ON_WATER'||',';
            var_output := var_output||'3'||',';
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
         /* Calculate the values
         /*-*/
         var_tot_order := nvl(rcd_kor_shp_summary.forecast_qty,0) + nvl(rcd_kor_shp_summary.outstand_qty,0);
         if rcd_kor_shp_summary.rnkseq = 1 then
            var_fut_spply := var_tot_order - nvl(rcd_kor_shp_summary.shipped_qty,0);
         else
            var_fut_spply := var_tot_order;
         end if;

         /*-*/
         /* Output the intransit interface data when required
         /*-*/
         if var_tot_order > 0 and var_fut_spply > 0 then
            var_output := rcd_kor_shp_summary.warehouse||',';
            var_output := var_output||rcd_kor_shp_summary.ship_period||',';
            var_output := var_output||''||',';
            var_output := var_output||rcd_kor_shp_summary.ship_date||',';
            var_output := var_output||rcd_kor_shp_summary.expt_avail_date||',';
            var_output := var_output||''||',';
            var_output := var_output||rcd_kor_shp_summary.material||',';
            var_output := var_output||to_char(var_fut_spply)||',';
            var_output := var_output||'F'||',';
            var_output := var_output||''||',';
            var_output := var_output||'TOTAL_FUTURE_SUPPLY'||',';
            var_output := var_output||'3'||',';
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

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'ICS_ICSAPL02 - EXECUTE - FATAL ERROR - ' || var_exception);

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
grant execute on ics_app.ics_icsapl02 to site_app;