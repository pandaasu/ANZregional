/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ics
 Package : ics_cisatl16
 Owner   : ics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Interface Control System - cisatl16 - Generic IDOC Acknowledgement

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/02   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_cisatl16 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure start_acknowledgement;
   procedure add_document(par_idoc_number in varchar2,
                          par_status_date in varchar2,
                          par_status_time in varchar2,
                          par_status_value in varchar2);
   procedure end_acknowledgement;

end ics_cisatl16;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_cisatl16 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);
   type rcd_acknowledgement is record(idoc_number varchar2(16),
                                      status_date varchar2(8),
                                      status_time varchar2(6),
                                      status_value varchar2(2));
   type typ_acknowledgement is table of rcd_acknowledgement index by binary_integer;
   tbl_acknowledgement typ_acknowledgement;

   /*************************************************************/
   /* This procedure performs the start acknowledgement routine */
   /*************************************************************/
   procedure start_acknowledgement is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Clear the acknowledgement array
      /*-*/
      tbl_acknowledgement.delete;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_acknowledgement;

   /****************************************************/
   /* This procedure performs the add document routine */
   /****************************************************/
   procedure add_document(par_idoc_number in varchar2,
                          par_status_date in varchar2,
                          par_status_time in varchar2,
                          par_status_value in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(5,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the acknowledgement index
      /*-*/
      var_index := tbl_acknowledgement.count + 1;

      /*-*/
      /* Set the acknowledgement properties
      /*-*/
      tbl_acknowledgement(var_index).idoc_number := par_idoc_number;
      tbl_acknowledgement(var_index).status_date := par_status_date;
      tbl_acknowledgement(var_index).status_time := par_status_time;
      tbl_acknowledgement(var_index).status_value := par_status_value;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_document;

   /***********************************************************/
   /* This procedure performs the end acknowledgement routine */
   /***********************************************************/
   procedure end_acknowledgement is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return when no acknowledgement documents exist
      /*-*/
      if tbl_acknowledgement.count = 0 then
         return;
      end if;

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('CISATL16');

      /*-*/
      /* Append the interface data
      /*-*/
      for idx in 1..tbl_acknowledgement.count loop
         lics_outbound_loader.append_data('HDR' ||
                                          lpad(tbl_acknowledgement(idx).idoc_number,16,'0') ||
                                          lpad(tbl_acknowledgement(idx).status_date,8,'0') ||
                                          lpad(tbl_acknowledgement(idx).status_time,6,'0') ||
                                          lpad(tbl_acknowledgement(idx).status_value,2,'0'));
      end loop;

      /*-*/
      /* Finalise the interface
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
         rollback;
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end end_acknowledgement;

end ics_cisatl16;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_cisatl16 for ics_app.ics_cisatl16;
grant execute on ics_cisatl16 to public;