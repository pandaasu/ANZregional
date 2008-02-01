/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : icss
 Package : ics_wmscis01
 Owner   : ics_app
 Author  : Steve Gregan

 Description
 -----------
 Interface Control System - wmscis01 - WMS Material Acknowledgement

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_wmscis01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_wmscis01;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_wmscis01 as

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
      lics_inbound_utility.set_definition('HDR','INT_NUMBER',15);
      lics_inbound_utility.set_definition('HDR','ACK_DATE',8);
      lics_inbound_utility.set_definition('HDR','ACK_TIME',6);
      lics_inbound_utility.set_definition('HDR','ACK_STATUS',1);
      lics_inbound_utility.set_definition('HDR','MESSAGE',50);

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
      /* No logic
      /*-*/
      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

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
      /* Send the notification when required
      /*-*/
      if lics_inbound_utility.get_variable('ACK_STATUS') = '2' then
         lics_inbound_utility.add_exception('Interface (Material Acknowledgement) data rejected on ' ||
                                            lics_inbound_utility.get_variable('ACK_DATE') || ' ' ||
                                            lics_inbound_utility.get_variable('ACK_TIME') || ' for interface ' ||
                                            lics_inbound_utility.get_variable('INT_NUMBER') || ' due to ' ||
                                            lics_inbound_utility.get_variable('MESSAGE'));
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ics_wmscis01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
drop public synonym ics_wmscis01;
create public synonym ics_wmscis01 for ics_app.ics_wmscis01;
grant execute on ics_wmscis01 to public;
