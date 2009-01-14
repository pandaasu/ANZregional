/******************/
/* Package Header */
/******************/
create or replace package fcst_demand_load as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : fcst_demand_load
    Owner   : df_app
    Author  : Jonathan Girling

    Description
    -----------
    Integrated Planning Demand Financials - Forecast Demand Load 

    YYYY/MM   Author             Description
    -------   ------             -----------
    2008/08   Jonathan Girling   Created
    2008/12   Steve Gregan       Modified for parallel processing

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end fcst_demand_load; 
/

/****************/
/* Package Body */
/****************/
create or replace package body fcst_demand_load as

   /*-*/
   /* Private exceptions 
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions 
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_load_file load_file%rowtype;
   rcd_load_dmnd load_dmnd%rowtype;
   var_count number;
   var_result_msg varchar2(3900);

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_loaded_file is
         select file_id
           from load_file
          where upper(file_name) = upper(rcd_load_file.file_name);
      rcd_loaded_file csr_loaded_file%rowtype;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;
      var_count := 0;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('DET','DMDUNIT',16);
      lics_inbound_utility.set_definition('DET','DMDGROUP',7);
      lics_inbound_utility.set_definition('DET','LOC',5);
      lics_inbound_utility.set_definition('DET','LOAD_DATE',8);
      lics_inbound_utility.set_definition('DET','BLANKS1',6);
      lics_inbound_utility.set_definition('DET','START_DATE',8);
      lics_inbound_utility.set_definition('DET','BLANKS2',6);
      lics_inbound_utility.set_definition('DET','DUR',5);
      lics_inbound_utility.set_definition('DET','TYPE',1);
      lics_inbound_utility.set_definition('DET','QTY',20);
      lics_inbound_utility.set_definition('DET','FCST_TEXT',50);
      lics_inbound_utility.set_definition('DET','PROMO_TYPE',255);

      /*-*/
      /* Retrieve the file name and remove existing data
      /*-*/ 
      rcd_load_file.file_name := lics_inbound_processor.callback_file_name;
      open csr_loaded_file;
      fetch csr_loaded_file into rcd_loaded_file;
      if csr_loaded_file%found then
         delete from load_dmnd where file_id = rcd_loaded_file.file_id;
         delete from load_file where file_id = rcd_loaded_file.file_id;
      end if;
      close csr_loaded_file;
      
      /*-*/
      /* Retrieve the unique run and file identifiers
      /*-*/ 
      if demand_object_tracking.get_new_id ('LOAD_FILE', 'RUN_ID', rcd_load_file.run_id, var_result_msg) != common.gc_success then
         raise_application_error(-20000, 'Error getting run id');
      end if;
      if demand_object_tracking.get_new_id ('LOAD_FILE', 'FILE_ID', rcd_load_file.file_id, var_result_msg) != common.gc_success then
         raise_application_error(-20000, 'Error getting file id');
      end if;

      /*-*/
      /* Retrieve the wildcard and moe code from the file name
      /*-*/
      if (upper(substr(rcd_load_file.file_name, 1, 5)) = 'DRAFT') then
         rcd_load_file.wildcard := demand_forecast.gc_wildcard_dmnd_draft;
         rcd_load_file.moe_code := substr(rcd_load_file.file_name, 11, 4);
      elsif (upper(substr(rcd_load_file.file_name, 1, 6)) = 'DEMAND') then
         rcd_load_file.wildcard := demand_forecast.gc_wildcard_demand;
         rcd_load_file.moe_code := substr(rcd_load_file.file_name, 8, 4);
      else
         raise_application_error(-20000, 'File type not recognised');
      end if;
     
      /*-*/
      /* Insert the new load file record
      /*-*/
      insert into load_file
         (file_id, 
          file_name, 
          status, 
          loaded_date, 
          run_id, 
          wildcard, 
          moe_code)
      values 
         (rcd_load_file.file_id, 
          rcd_load_file.file_name, 
          common.gc_loaded,
          sysdate,
          rcd_load_file.run_id,
          rcd_load_file.wildcard,
          rcd_load_file.moe_code);

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
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_matl_code is
         select matl_code
           from matl
          where matl_type = 'ZREP'
            and trdd_unit = 'X'
            and matl_code = reference_functions.full_matl_code(rcd_load_dmnd.zrep_code);
      rcd_matl_code csr_matl_code%rowtype;

      cursor csr_bus_sgmnt_code is
         select bus_sgmnt_code
           from matl_fg_clssfctn
          where matl_code = reference_functions.full_matl_code(rcd_load_dmnd.zrep_code);
      rcd_bus_sgmnt_code csr_bus_sgmnt_code%rowtype;
      
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

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
     
      /*-*/
      /* Retrieve field values
      /*-*/
      var_count := var_count + 1;
      rcd_load_dmnd.dmdunit := lics_inbound_utility.get_variable('DMDUNIT');
      rcd_load_dmnd.dmdgroup := lics_inbound_utility.get_variable('DMDGROUP');
      rcd_load_dmnd.loc := lics_inbound_utility.get_variable('LOC');
      rcd_load_dmnd.startdate := lics_inbound_utility.get_date('START_DATE','yyyymmdd');
      rcd_load_dmnd.dur := lics_inbound_utility.get_number('DUR',null);
      rcd_load_dmnd.type := lics_inbound_utility.get_number('TYPE',null);
      rcd_load_dmnd.qty := lics_inbound_utility.get_number('QTY',null);
      rcd_load_dmnd.fcst_text := lics_inbound_utility.get_variable('FCST_TEXT');
      rcd_load_dmnd.promo_type := lics_inbound_utility.get_variable('PROMO_TYPE');
      rcd_load_dmnd.mars_week := demand_forecast.sql_get_mars_week(rcd_load_dmnd.startdate);       
      rcd_load_dmnd.casting_mars_week := demand_forecast.sql_get_mars_week(lics_inbound_utility.get_date('LOAD_DATE','yyyymmdd')-3);
      rcd_load_dmnd.file_id := rcd_load_file.file_id;
      rcd_load_dmnd.file_line := var_count;
      rcd_load_dmnd.zrep_code := substr(rcd_load_dmnd.dmdunit,1,6);
      rcd_load_dmnd.source_code := demand_forecast.get_source_code(rcd_load_dmnd.zrep_code);
      rcd_load_dmnd.zrep_valid := null;
      rcd_load_dmnd.bus_sgmnt_code := null;
      rcd_load_dmnd.status := common.gc_loaded;
      rcd_load_dmnd.error_msg := null;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      open csr_matl_code;
      fetch csr_matl_code into rcd_matl_code;
      if csr_matl_code%found then
         rcd_load_dmnd.zrep_valid := common.gc_valid;
      end if;
      close csr_matl_code;

      open csr_bus_sgmnt_code;
      fetch csr_bus_sgmnt_code into rcd_bus_sgmnt_code;
      if csr_bus_sgmnt_code%found then
         rcd_load_dmnd.bus_sgmnt_code := rcd_bus_sgmnt_code.bus_sgmnt_code;
      end if;
      close csr_bus_sgmnt_code;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/

      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      insert into load_dmnd
         (dmdunit, 
          dmdgroup, 
          loc, 
          casting_mars_week, 
          startdate, 
          dur, 
          type, 
          qty, 
          file_id,
          file_line, 
          fcst_text, 
          promo_type,
          zrep_code,
          source_code,
          zrep_valid,
          bus_sgmnt_code,
          status,
          mars_week,
          error_msg)
      values 
         (rcd_load_dmnd.dmdunit, 
          rcd_load_dmnd.dmdgroup, 
          rcd_load_dmnd.loc, 
          rcd_load_dmnd.casting_mars_week, 
          rcd_load_dmnd.startdate, 
          rcd_load_dmnd.dur, 
          rcd_load_dmnd.type, 
          rcd_load_dmnd.qty, 
          rcd_load_dmnd.file_id,
          rcd_load_dmnd.file_line, 
          rcd_load_dmnd.fcst_text, 
          rcd_load_dmnd.promo_type,
          rcd_load_dmnd.zrep_code,
          rcd_load_dmnd.source_code,
          rcd_load_dmnd.zrep_valid,
          rcd_load_dmnd.bus_sgmnt_code,
          rcd_load_dmnd.status,
          rcd_load_dmnd.mars_week,
          rcd_load_dmnd.error_msg);
      
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
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the interface as required
      /*-*/
      if var_trn_ignore = true then
         rollback;
      elsif var_trn_error = true then
         rollback;
      else
         commit;
         if (upper(substr(rcd_load_file.file_name, 1, 5)) = 'DRAFT') then
            lics_stream_loader.clear_parameters;
            lics_stream_loader.set_parameter('MOE',rcd_load_file.moe_code);
            lics_stream_loader.set_parameter('FILE_ID',to_char(rcd_load_file.file_id));
            lics_stream_loader.execute('DF_DEMAND_DRAFT',null);
         elsif (upper(substr(rcd_load_file.file_name, 1, 6)) = 'DEMAND') then
            lics_stream_loader.clear_parameters;
            lics_stream_loader.set_parameter('MOE',rcd_load_file.moe_code);
            lics_stream_loader.set_parameter('FILE_ID',to_char(rcd_load_file.file_id));
            lics_stream_loader.execute('DF_DEMAND_FINAL',null);
         end if;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end fcst_demand_load; 
/
