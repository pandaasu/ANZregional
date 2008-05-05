create or replace package fpsreg01_load as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : AP Regional DBP
 Package : fpsreg01_load
 Owner   : regl_app
 Author  : Linden Glen

 Description
 -----------
 AP Regional DBP - FPPS Forecast Interface Loader

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end fpsreg01_load;
/

/****************/
/* Package Body */
/****************/
create or replace package body fpsreg01_load as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_ods_fpps_fcst_hdr ods_fpps_fcst_hdr%rowtype;
   rcd_ods_fpps_fcst_det ods_fpps_fcst_det%rowtype;

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
      var_trn_start := false;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','COMPANY_CODE',6);
      lics_inbound_utility.set_definition('HDR','FCST_TYPE',4);
      lics_inbound_utility.set_definition('HDR','FCST_YYYY',4);
      lics_inbound_utility.set_definition('HDR','FCST_CURRENCY',4);
      /*-*/
      lics_inbound_utility.set_definition('DET','FCST_VERSION',30);
      lics_inbound_utility.set_definition('DET','FCST_DESTINATION',30);
      lics_inbound_utility.set_definition('DET','FCST_SKIP1',1);
      lics_inbound_utility.set_definition('DET','FCST_PERIOD',2);
      lics_inbound_utility.set_definition('DET','FCST_SKIP2',27);
      lics_inbound_utility.set_definition('DET','FCST_MATL',30);
      lics_inbound_utility.set_definition('DET','FCST_MRKT_GSV',15);
      lics_inbound_utility.set_definition('DET','FCST_MRKT_TON',15);
      lics_inbound_utility.set_definition('DET','FCST_MRKT_QTY',15);
      lics_inbound_utility.set_definition('DET','FCST_FCTRY_GSV',15);
      lics_inbound_utility.set_definition('DET','FCST_FCTRY_TON',15);
      lics_inbound_utility.set_definition('DET','FCST_FCTRY_QTY',15);

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
         else process_record_det(par_record);
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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the transaction
      /*-*/
      complete_transaction;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   procedure complete_transaction is

      /*-*/
      /* Local definitions
      /*-*/
      var_accepted boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

      /*-*/
      /* Local cursors
      /*-*/

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HDR', par_record);

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_ods_fpps_fcst_hdr.company_code := lics_inbound_utility.get_variable('COMPANY_CODE');
      rcd_ods_fpps_fcst_hdr.fcst_type := lics_inbound_utility.get_variable('FCST_TYPE');
      rcd_ods_fpps_fcst_hdr.fcst_yyyy := lics_inbound_utility.get_variable('FCST_YYYY');
      rcd_ods_fpps_fcst_hdr.fcst_currency := lics_inbound_utility.get_variable('FCST_CURRENCY');
      rcd_ods_fpps_fcst_hdr.fcst_load_date := sysdate;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_ods_fpps_fcst_hdr.company_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.COMPANY_CODE');
         var_trn_error := true;
      end if;
      if rcd_ods_fpps_fcst_hdr.fcst_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.FCST_TYPE');
         var_trn_error := true;
      end if;
      if rcd_ods_fpps_fcst_hdr.fcst_yyyy is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.FCST_YYYY');
         var_trn_error := true;
      end if;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Clear tables
      /*-*/
      delete ods_fpps_fcst_det where company_code = rcd_ods_fpps_fcst_hdr.company_code
                                 and fcst_type = rcd_ods_fpps_fcst_hdr.fcst_type
                                 and fcst_yyyy = rcd_ods_fpps_fcst_hdr.fcst_yyyy;
      delete ods_fpps_fcst_hdr where company_code = rcd_ods_fpps_fcst_hdr.company_code
                                 and fcst_type = rcd_ods_fpps_fcst_hdr.fcst_type
                                 and fcst_yyyy = rcd_ods_fpps_fcst_hdr.fcst_yyyy;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      insert into ods_fpps_fcst_hdr
         (company_code,
          fcst_type,
          fcst_yyyy,
          fcst_currency,
          fcst_load_date)
        values
         (rcd_ods_fpps_fcst_hdr.company_code,
          rcd_ods_fpps_fcst_hdr.fcst_type,
          rcd_ods_fpps_fcst_hdr.fcst_yyyy,
          rcd_ods_fpps_fcst_hdr.fcst_currency,
          rcd_ods_fpps_fcst_hdr.fcst_load_date);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('DET', par_record);

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_ods_fpps_fcst_det.company_code := rcd_ods_fpps_fcst_hdr.company_code;
      rcd_ods_fpps_fcst_det.fcst_type := rcd_ods_fpps_fcst_hdr.fcst_type;
      rcd_ods_fpps_fcst_det.fcst_yyyy := rcd_ods_fpps_fcst_hdr.fcst_yyyy;
      rcd_ods_fpps_fcst_det.fcst_matl_code := lics_inbound_utility.get_variable('FCST_MATL');
      rcd_ods_fpps_fcst_det.fcst_period := lics_inbound_utility.get_variable('FCST_PERIOD');
      rcd_ods_fpps_fcst_det.fcst_destination := lics_inbound_utility.get_variable('FCST_DESTINATION');
      rcd_ods_fpps_fcst_det.fcst_mrkt_gsv := lics_inbound_utility.get_number('FCST_MRKT_GSV',null);
      rcd_ods_fpps_fcst_det.fcst_mrkt_ton := lics_inbound_utility.get_number('FCST_MRKT_TON',null);
      rcd_ods_fpps_fcst_det.fcst_mrkt_qty := lics_inbound_utility.get_number('FCST_MRKT_QTY',null);
      rcd_ods_fpps_fcst_det.fcst_fctry_gsv := lics_inbound_utility.get_number('FCST_FCTRY_GSV',null);
      rcd_ods_fpps_fcst_det.fcst_fctry_ton := lics_inbound_utility.get_number('FCST_FCTRY_TON',null);
      rcd_ods_fpps_fcst_det.fcst_fctry_qty := lics_inbound_utility.get_number('FCST_FCTRY_QTY',null);

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_ods_fpps_fcst_det.company_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.COMPANY_CODE');
         var_trn_error := true;
      end if;
      if rcd_ods_fpps_fcst_det.fcst_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FCST_TYPE');
         var_trn_error := true;
      end if;
      if rcd_ods_fpps_fcst_det.fcst_yyyy is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FCST_YYYY');
         var_trn_error := true;
      end if;
      if rcd_ods_fpps_fcst_det.fcst_matl_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FCST_MATL_CODE');
         var_trn_error := true;
      end if;
      if rcd_ods_fpps_fcst_det.fcst_period is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FCST_PERIOD');
         var_trn_error := true;
      end if;
      if rcd_ods_fpps_fcst_det.fcst_destination is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FCST_DESTINATION');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      insert into ods_fpps_fcst_det
         (company_code,
          fcst_type,
          fcst_yyyy,
          fcst_matl_code,
          fcst_period,
          fcst_destination,
          fcst_mrkt_gsv,
          fcst_mrkt_ton,
          fcst_mrkt_qty,
          fcst_fctry_gsv,
          fcst_fctry_ton,
          fcst_fctry_qty)
        values
         (rcd_ods_fpps_fcst_det.company_code,
          rcd_ods_fpps_fcst_det.fcst_type,
          rcd_ods_fpps_fcst_det.fcst_yyyy,
          rcd_ods_fpps_fcst_det.fcst_matl_code,
          rcd_ods_fpps_fcst_det.fcst_period,
          rcd_ods_fpps_fcst_det.fcst_destination,
          rcd_ods_fpps_fcst_det.fcst_mrkt_gsv,
          rcd_ods_fpps_fcst_det.fcst_mrkt_ton,
          rcd_ods_fpps_fcst_det.fcst_mrkt_qty,
          rcd_ods_fpps_fcst_det.fcst_fctry_gsv,
          rcd_ods_fpps_fcst_det.fcst_fctry_ton,
          rcd_ods_fpps_fcst_det.fcst_fctry_qty);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end fpsreg01_load;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym fpsreg01_load for ods_app.fpsreg01_load;
grant execute on fpsreg01_load to public;
