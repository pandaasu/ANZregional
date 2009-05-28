/******************/
/* Package Header */
/******************/
create or replace package bp_app.bpip_ipsrad01 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : bpip_ipsrad01
    Owner   : bp_app

    Description
    -----------
    Integrated Planning System - BPIP to Radar Forecast Price Interface 

    YYYY/MM   Author             Description
    -------   ------             -----------
    2009/05   Steve Gregan       Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end bpip_ipsrad01;
/

/****************/
/* Package Body */
/****************/
create or replace package body bp_app.bpip_ipsrad01 as

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



Business Segment (ie 01, 02, 05)
Plant Code (ie AU30)
Material Code (ie 1006518)
Material Description, English Only (ie VEGE MIX MFS Dip Guac FSD)
Local Currency (ie AUD)
Alternate Currency (if available) (ie EUR)
Period (YYYYPP ie 200805)
Forecast Cost



      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_xxxx is
         select t01.*
           from kor_inb_summary t01
          order by t01.plant asc,
                   t01.material asc,
                   t01.ship_period asc;
      rcd_xxxx csr_xxxx%rowtype;

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
      open csr_xxxx;
      loop
         fetch csr_xxxx into rcd_xxxx;
         if csr_xxxx%notfound then
            exit;
         end if;

         /*-*/
         /* Output the intransit interface data when required
         /*-*/
         if rcd_xxxx.rsmn_date is null then
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
      close csr_xxxx;

      /*-*/
      /* Create the outbound interface when required
      /*-*/
      if tbl_outbound.count != 0 then
         var_timestamp := to_char(sysdate,'yyyymmddhh24miss');
         var_instance := lics_outbound_loader.create_interface('IPSRAD01', null, 'xxxxxx.dat');
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
         raise_application_error(-20000, 'BPIP_IPSRAD01 - EXECUTE - FATAL ERROR - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end bpip_ipsrad01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bpip_ipsrad01 for bp_app.bpip_ipsrad01;
grant execute on bp_app.bpip_ipsrad01 to lics_app;