/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw00_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw00_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Control Data - EFEX to CDW

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;
   procedure update_interface(par_interface in varchar2, par_market in number, par_extract in varchar2, par_count in number);

end efxcdw00_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw00_loader as

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
   rcd_efex_cntl_hdr efex_cntl_hdr%rowtype;
   rcd_efex_cntl_det efex_cntl_det%rowtype;

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
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CTL','RCD_ID',3);
      lics_inbound_utility.set_definition('CTL','INT_ID',32);
      lics_inbound_utility.set_definition('CTL','MKT_ID',10);
      lics_inbound_utility.set_definition('CTL','EXT_ID',14);
      /*-*/
      lics_inbound_utility.set_definition('DET','RCD_ID',3);
      lics_inbound_utility.set_definition('DET','INT_CODE',32);
      lics_inbound_utility.set_definition('DET','INT_COUNT',10);

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
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));

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
      /* Commit/rollback as required
      /*-*/
      if var_trn_error = true then
         rollback;
      else
         commit;
      end if;

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

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('CTL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_cntl_hdr.market_id := lics_inbound_utility.get_number('MKT_ID',null);
      rcd_efex_cntl_hdr.extract_time := lics_inbound_utility.get_variable('EXT_ID');
      rcd_efex_cntl_hdr.extract_status := '*CONTROL';

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_cntl_hdr values rcd_efex_cntl_hdr;
      exception
         when dup_val_on_index then
            update efex_cntl_hdr
               set extract_status = rcd_efex_cntl_hdr.extract_status
             where market_id = rcd_efex_cntl_hdr.market_id
               and extract_time = rcd_efex_cntl_hdr.extract_time;
      end;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DET', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_cntl_det.market_id := rcd_efex_cntl_hdr.market_id;
      rcd_efex_cntl_det.extract_time := rcd_efex_cntl_hdr.extract_time;
      rcd_efex_cntl_det.iface_code := lics_inbound_utility.get_variable('INT_CODE');
      rcd_efex_cntl_det.iface_count := lics_inbound_utility.get_number('INT_COUNT',null);
      rcd_efex_cntl_det.iface_recvd := 0;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_cntl_det values rcd_efex_cntl_det;
      exception
         when dup_val_on_index then
            update efex_cntl_det
               set iface_count = rcd_efex_cntl_det.iface_count
             where market_id = rcd_efex_cntl_det.market_id
               and extract_time = rcd_efex_cntl_det.extract_time
               and iface_code = rcd_efex_cntl_det.iface_code;
      end;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /********************************************************/
   /* This procedure performs the update interface routine */
   /********************************************************/
   procedure update_interface(par_interface in varchar2, par_market in number, par_extract in varchar2, par_count in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Insert the control header
      /*-*/
      rcd_efex_cntl_hdr.market_id := par_market;
      rcd_efex_cntl_hdr.extract_time := par_extract;
      rcd_efex_cntl_hdr.extract_status := '*INTERFACE';
      begin
         insert into efex_cntl_hdr values rcd_efex_cntl_hdr;
      exception
         when dup_val_on_index then
            null;
      end;

      /*-*/
      /* Insert/Update the control detail
      /*-*/
      rcd_efex_cntl_det.market_id := par_market;
      rcd_efex_cntl_det.extract_time := par_extract;
      rcd_efex_cntl_det.iface_code := par_interface;
      rcd_efex_cntl_det.iface_count := 0;
      rcd_efex_cntl_det.iface_recvd := par_count;
      begin
         insert into efex_cntl_det values rcd_efex_cntl_det;
      exception
         when dup_val_on_index then
            update efex_cntl_det
               set iface_recvd = iface_recvd + par_count
             where market_id = rcd_efex_cntl_det.market_id
               and extract_time = rcd_efex_cntl_det.extract_time
               and iface_code = rcd_efex_cntl_det.iface_code;
      end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end update_interface;

end efxcdw00_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw00_loader for ods_app.efxcdw00_loader;
grant execute on ods_app.efxcdw00_loader to lics_app;
