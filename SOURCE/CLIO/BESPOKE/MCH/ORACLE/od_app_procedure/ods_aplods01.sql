/******************/
/* Package Header */
/******************/
create or replace package ods_aplods01 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : od_app
    Package : ods_aplods01
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - aplods01 - Inbound Apollo Demand Forecast Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_aplods01;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_aplods01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_error boolean;
   var_rcd_count number;
   var_rcd_total number;
   var_work_yyyymmdd varchar2(8 char);
   var_cast_yyyymmdd varchar2(8 char);
   rcd_fcst_data fcst_data%rowtype;

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
      var_trn_error := false;
      var_rcd_count := 0;
      var_rcd_total := 0;
      var_cast_yyyymmdd := '00000000';

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('CAST_DATE',1);
      lics_inbound_utility.set_csv_definition('FCST_LOCN',2);
      lics_inbound_utility.set_csv_definition('MATL_CODE',3);
      lics_inbound_utility.set_csv_definition('DMND_GROUP',4);
      lics_inbound_utility.set_csv_definition('ATLAS_LOCN',5);
      lics_inbound_utility.set_csv_definition('FCST_DATE',6);
      lics_inbound_utility.set_csv_definition('FCST_COVER',7);
      lics_inbound_utility.set_csv_definition('FCST_QTY',8);
      lics_inbound_utility.set_csv_definition('TRUNC_DMND_GROUP',9);
      lics_inbound_utility.set_csv_definition('RCD_NUMBER',10);
      lics_inbound_utility.set_csv_definition('RCD_TOTAL',11);
      lics_inbound_utility.set_csv_definition('EXTRACT_DATE',12);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_csv_record(par_record,',','"');

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      var_work_yyyymmdd := to_char(lics_inbound_utility.get_date('CAST_DATE','dd/mm/yyyy'),'yyyymmdd');
      rcd_fcst_data.material_code := lics_inbound_utility.get_variable('MATL_CODE');
      rcd_fcst_data.dmnd_group := lics_inbound_utility.get_variable('DMND_GROUP');
      rcd_fcst_data.plant_code := lics_inbound_utility.get_variable('ATLAS_LOCN');
      rcd_fcst_data.fcst_yyyymmdd := lics_inbound_utility.get_variable('FCST_DATE');
      rcd_fcst_data.fcst_yyyyppw := 0;
      rcd_fcst_data.fcst_yyyypp := 0;
      rcd_fcst_data.fcst_cover := lics_inbound_utility.get_number('FCST_COVER',null);
      rcd_fcst_data.fcst_qty := lics_inbound_utility.get_number('FCST_QTY',null);
      rcd_fcst_data.fcst_prc := 0;
      rcd_fcst_data.fcst_gsv := 0;
      var_rcd_total := lics_inbound_utility.get_number('RCD_TOTAL',null);
      var_rcd_count := var_rcd_count + 1;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Clear the forecast data (global temporary table)
      /*-*/
      if var_trn_start = false then
         delete from fcst_data;
         var_cast_yyyymmdd := var_work_yyyymmdd;
      end if;
      var_trn_start := true;

      /*-*/
      /* Validate the interface data
      /*-*/
      if var_work_yyyymmdd != var_cast_yyyymmdd then
         lics_inbound_utility.add_exception('Multiple casting dates found in interface file');
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

      /*-*/
      /* Insert the forecast data
      /*-*/
      insert into fcst_data
         (material_code,
          dmnd_group,
          plant_code,
          fcst_yyyymmdd,
          fcst_yyyyppw,
          fcst_yyyypp,
          fcst_cover,
          fcst_qty,
          fcst_prc,
          fcst_gsv)
         values(rcd_fcst_data.material_code,
                rcd_fcst_data.dmnd_group,
                rcd_fcst_data.plant_code,
                rcd_fcst_data.fcst_yyyymmdd,
                rcd_fcst_data.fcst_yyyyppw,
                rcd_fcst_data.fcst_yyyypp,
                rcd_fcst_data.fcst_cover,
                rcd_fcst_data.fcst_qty,
                rcd_fcst_data.fcst_prc,
                rcd_fcst_data.fcst_gsv);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(sqlerrm, 1, 512));
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
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Check the record count when no errors
      /*-*/
      if var_trn_error = false then
         if var_rcd_count != var_rcd_total then
            lics_inbound_utility.add_exception('Total record count (' || to_char(var_rcd_total) || ') does not match the received records (' || to_char(var_rcd_count) || ')');
            var_trn_error := true;
         end if;
      end if;

      /*-*/
      /* Create the forecast apollo load information when no errors
      /*-*/
      if var_trn_error = false then
         begin
            dw_fcst_maintenance.create_apollo_load(var_cast_yyyymmdd);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(sqlerrm, 1, 512));
               var_trn_error := true;
         end;
      end if;

      /*-*/
      /* Commit/rollback the transaction as required
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

end ods_aplods01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_aplods01 for od_app.ods_aplods01;
grant execute on ods_aplods01 to lics_app;
