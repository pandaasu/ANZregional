/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ics
 Package : ics_cispro01
 Owner   : ics_app
 Author  : Steve Gregan

 Description
 -----------
 Promax AR Promotional Claims Conversion

 YYYY/MM   Author          Description
 -------   ------          -----------
 2005/05   Steve Gregan    Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package ics_cispro01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_cispro01;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_cispro01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   type rcd_outbound is record(data_string varchar2(4000), data_amount number);
   type typ_outbound is table of rcd_outbound index by binary_integer;
   tbl_outbound typ_outbound;
   var_index number(5,0);

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_error := false;

      /*-*/
      /* Clear the outbound array
      /*-*/
      tbl_outbound.delete;

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
         when 'CTL' then process_record_ctl(par_record);
         when 'DET' then process_record_det(par_record);
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
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return when transaction error
      /*-*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Return when no outbound data exist
      /*-*/
      if tbl_outbound.count = 0 then
         return;
      end if;

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('CISPRO01');

      /*-*/
      /* Append the interface data
      /*-*/
      for idx in 1..tbl_outbound.count loop
         lics_outbound_loader.append_data(tbl_outbound(idx).data_string);
      end loop;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Output the CTL record unchanged
      /*-*/
      var_index := tbl_outbound.count + 1;
      tbl_outbound(var_index).data_string := par_record;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_record varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Alter the reason and tax code as required
      /*-*/
      if substr(par_record, 90, 2) = '40' then
         var_record := substr(par_record, 1, 89) || '08' || substr(par_record, 92, 30) || 'S3';
      elsif substr(par_record, 90, 2) = '41' then
         var_record := substr(par_record, 1, 89) || '08' || substr(par_record, 92, 30) || 'S1';
      else
         var_record := par_record;
      end if;

      /*-*/
      /* Output the altered DET record
      /*-*/
      var_index := tbl_outbound.count + 1;
      tbl_outbound(var_index).data_string := var_record;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end ics_cispro01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_cispro01 for ics_app.ics_cispro01;
grant execute on ics_cispro01 to public;