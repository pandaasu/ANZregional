/******************/
/* Package Header */
/******************/
create or replace package ods_app.ladods01_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladods01_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Factory BOM Data - LADS to ODS

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ladods01_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.ladods01_loader as

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
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_int_code varchar2(32);
   var_int_time varchar2(14);
   rcd_sap_bom_load sap_bom_load%rowtype;

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
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Attempt to lock the bom load table in exclusive mode
      /*-*/
      begin
         lock table sap_bom_load in exclusive mode nowait;
      exception
         when others then
            lics_inbound_utility.add_exception('Unable to lock the BOM load table (sap_bom_load) interface rejected');
            var_trn_ignore := true;
      end;
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CTL','RCD_CODE',3);
      lics_inbound_utility.set_definition('CTL','INT_CODE',32);
      lics_inbound_utility.set_definition('CTL','INT_TIME',14);
      /*-*/
      lics_inbound_utility.set_definition('DET','RCD_CODE',3);
      lics_inbound_utility.set_definition('DET','BOM_MATL_CODE',18);
      lics_inbound_utility.set_definition('DET','BOM_ALTN_CODE',2);
      lics_inbound_utility.set_definition('DET','BOM_PLNT_CODE',4);
      lics_inbound_utility.set_definition('DET','BOM_NUMB',8);
      lics_inbound_utility.set_definition('DET','BOM_USAG',1);
      lics_inbound_utility.set_definition('DET','BOM_EFFF_DATE',8);
      lics_inbound_utility.set_definition('DET','BOM_EFFT_DATE',8);
      lics_inbound_utility.set_definition('DET','BOM_BASE_QNTY',15);
      lics_inbound_utility.set_definition('DET','BOM_BASE_UOM',3);
      lics_inbound_utility.set_definition('DET','BOM_STAT',2);
      lics_inbound_utility.set_definition('DET','ITM_SEQN',15);
      lics_inbound_utility.set_definition('DET','ITM_NUMB',4);
      lics_inbound_utility.set_definition('DET','ITM_MATL_CODE',18);
      lics_inbound_utility.set_definition('DET','ITM_CATG_CODE',1);
      lics_inbound_utility.set_definition('DET','ITM_BASE_QNTY',15);
      lics_inbound_utility.set_definition('DET','ITM_BASE_UOM',3);
      lics_inbound_utility.set_definition('DET','ITM_EFFF_DATE',8);
      lics_inbound_utility.set_definition('DET','ITM_EFFT_DATE',8);

      /*-*/
      /* Truncate the load table
      /*-*/
      ods_table.truncate('sap_bom_load');

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
         var_trn_error := true;
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore the data row when required
      /*-*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('CTL', par_record);

      /*-*/
      /* Retrieve field values
      /*-*/
      var_int_code := lics_inbound_utility.get_variable('INT_CODE');
      var_int_time := lics_inbound_utility.get_variable('INT_TIME');

      /*-*/
      /* Exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
         return;
      end if;

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
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore the data row when required
      /*-*/
      if var_trn_ignore = true then
         return;
      end if;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('DET', par_record);

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_bom_load.bom_material_code := lics_inbound_utility.get_variable('BOM_MATL_CODE');
      rcd_sap_bom_load.bom_alternative := lics_inbound_utility.get_variable('BOM_ALTN_CODE');
      rcd_sap_bom_load.bom_plant := lics_inbound_utility.get_variable('BOM_PLNT_CODE');
      rcd_sap_bom_load.bom_number := lics_inbound_utility.get_variable('BOM_NUMB');
      rcd_sap_bom_load.bom_usage := lics_inbound_utility.get_variable('BOM_USAG');
      rcd_sap_bom_load.bom_eff_from_date := lics_inbound_utility.get_date('BOM_EFFF_DATE','yyyymmdd');
      rcd_sap_bom_load.bom_eff_to_date := lics_inbound_utility.get_date('BOM_EFFT_DATE','yyyymmdd');
      rcd_sap_bom_load.bom_base_qty := lics_inbound_utility.get_number('BOM_BASE_QNTY',null);
      rcd_sap_bom_load.bom_base_uom := lics_inbound_utility.get_variable('BOM_BASE_UOM');
      rcd_sap_bom_load.bom_status := lics_inbound_utility.get_variable('BOM_STAT');
      rcd_sap_bom_load.item_sequence := lics_inbound_utility.get_number('ITM_SEQN',null);
      rcd_sap_bom_load.item_number := lics_inbound_utility.get_variable('ITM_NUMB');
      rcd_sap_bom_load.item_material_code := lics_inbound_utility.get_variable('ITM_MATL_CODE');
      rcd_sap_bom_load.item_category := lics_inbound_utility.get_variable('ITM_CATG_CODE');
      rcd_sap_bom_load.item_base_qty := lics_inbound_utility.get_number('ITM_BASE_QNTY',null);
      rcd_sap_bom_load.item_base_uom := lics_inbound_utility.get_variable('ITM_BASE_UOM');
      rcd_sap_bom_load.item_eff_from_date := lics_inbound_utility.get_date('ITM_EFFF_DATE','yyyymmdd');
      rcd_sap_bom_load.item_eff_to_date := lics_inbound_utility.get_date('ITM_EFFT_DATE','yyyymmdd');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Insert the table row
      /*-*/
      insert into sap_bom_load values rcd_sap_bom_load;

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
   end process_record_det;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Commit/rollback the data as required
      /*
      /* **notes**
      /* 1. Truncate the data table
      /* 2. Copy the load table to the data table
      /* 3. Truncate the load table 
      /*-*/
      if var_trn_ignore = true or
         var_trn_error = true then
         rollback;
      else
         ods_table.truncate('sap_bom_data');
         insert into sap_bom_data (select * from sap_bom_load);
         ods_table.truncate('sap_bom_load');
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end ladods01_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladods01_loader for ods_app.ladods01_loader;
grant execute on ods_app.ladods01_loader to public;