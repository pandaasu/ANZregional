/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : icss
 Package : ics_wmscisatl16
 Owner   : ics_app
 Author  : Steve Gregan

 Description
 -----------
 Interface Control System - wmscisatl16 - WMS IDOC Status Acknowledgement

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_wmscisatl16 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_wmscisatl16;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_wmscisatl16 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','INT_HDR',3);
      lics_inbound_utility.set_definition('HDR','IDOC_NUMBER',16);
      lics_inbound_utility.set_definition('HDR','DOCO_NUMBER',10);
      lics_inbound_utility.set_definition('HDR','STATUS_DATE',8);
      lics_inbound_utility.set_definition('HDR','STATUS_TIME',6);
      lics_inbound_utility.set_definition('HDR','REASON_CODE',8);
      lics_inbound_utility.set_definition('HDR','MESSAGE',30);

      /*-*/
      /* Start the generic acknowledgement
      /*-*/
      ics_cisatl16.start_acknowledgement;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'HDR' then process_record_hdr(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* End the generic acknowledgement
      /*-*/
      ics_cisatl16.end_acknowledgement;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_status varchar2(2);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Add the document to the generic IDOC acknowledgement
      /*-*/
      if lics_inbound_utility.get_variable('REASON_CODE') = 'VA' then
         var_status := '41';
      else
         var_status := '40';
      end if;
      ics_cisatl16.add_document(lics_inbound_utility.get_variable('IDOC_NUMBER'),
                                lics_inbound_utility.get_variable('STATUS_DATE'),
                                lics_inbound_utility.get_variable('STATUS_TIME'),
                                var_status);
      /*-*/
      /* Send the notification when required
      /*-*/
      if var_status = '40' then
         lics_inbound_utility.add_exception('Interface IO-02 (Delivery Request Acknowledgement) failed on ' ||
                                            lics_inbound_utility.get_variable('STATUS_DATE') || ' ' ||
                                            lics_inbound_utility.get_variable('STATUS_TIME') || ' for IDOC ' ||
                                            lics_inbound_utility.get_variable('IDOC_NUMBER') || ' due to ' ||
                                            lics_inbound_utility.get_variable('MESSAGE'));
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ics_wmscisatl16;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
drop public synonym ics_wmscisatl16;
create public synonym ics_wmscisatl16 for ics_app.ics_wmscisatl16;
grant execute on ics_wmscisatl16 to public;
