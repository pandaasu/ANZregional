/******************/
/* Package Header */
/******************/
create or replace package fcst_supply_load as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : fcst_supply_load
    Owner   : df_app
    Author  : Jonathan Girling

    Description
    -----------
    Integrated Planning Demand Financials - Forecast Supply Load 

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

end fcst_supply_load; 
/

/****************/
/* Package Body */
/****************/
create or replace package body fcst_supply_load as

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
   rcd_load_sply load_sply%rowtype;
   var_count number;
   var_result_msg varchar2(3900);

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

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
      lics_inbound_utility.set_definition('DET','ITEM',8);
      lics_inbound_utility.set_definition('DET','DEST',5);
      lics_inbound_utility.set_definition('DET','QTY',20);
      lics_inbound_utility.set_definition('DET','SHIPDATE',8);
      lics_inbound_utility.set_definition('DET','BLANKS1',48);
      lics_inbound_utility.set_definition('DET','CASTING_DATE',8);

      /*-*/
      /* Retrieve the file name and remove existing data
      /*-*/ 
      rcd_load_file.file_name := lics_inbound_processor.callback_file_name;
      open csr_loaded_file;
      fetch csr_loaded_file into rcd_loaded_file;
      if csr_loaded_file%found then
         delete from load_sply where file_id = rcd_loaded_file.file_id;
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
         rcd_load_file.moe_code := substr(rcd_load_file.file_name, 12, 4);
      elsif (upper(substr(rcd_load_file.file_name, 1, 6)) = 'SUPPLY') then
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
      rcd_load_sply.item := trim(lics_inbound_utility.get_variable('ITEM'));
      rcd_load_sply.dest := rtrim(lics_inbound_utility.get_variable('DEST'));
      rcd_load_sply.qty := lics_inbound_utility.get_number('QTY',null);
      rcd_load_sply.schedshipdate := lics_inbound_utility.get_date('SHIPDATE','yyyymmdd');
      rcd_load_sply.mars_week := demand_forecast.sql_get_mars_week (rcd_load_sply.schedshipdate);
      rcd_load_sply.casting_mars_week := demand_forecast.sql_get_mars_week(lics_inbound_utility.get_date('CASTING_DATE','yyyymmdd')-3);
      rcd_load_sply.file_id := rcd_load_file.file_id;
      rcd_load_sply.file_line := var_count;
      rcd_load_sply.status := common.gc_loaded;
      rcd_load_sply.error_msg := null;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
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

      insert into load_sply
         (item, 
          dest, 
          schedshipdate, 
          qty, 
          status,
          error_msg,
          casting_mars_week,
          mars_week,
          file_id,
          file_line)
      values 
         (rcd_load_sply.item, 
          rcd_load_sply.dest, 
          rcd_load_sply.schedshipdate,
          rcd_load_sply.qty, 
          rcd_load_sply.status,
          rcd_load_sply.error_msg,
          rcd_load_sply.casting_mars_week,
          rcd_load_sply.mars_week,
          rcd_load_sply.file_id,
          rcd_load_sply.file_line);
      
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
            lics_stream_loader.set_parameter('MOE',to_char(rcd_load_file.moe_code));
            lics_stream_loader.set_parameter('FILE_ID',to_char(rcd_load_file.file_id));
            lics_stream_loader.execute('DF_SUPPLY_DRAFT',null);
         elsif (upper(substr(rcd_load_file.file_name, 1, 6)) = 'SUPPLY') then
            lics_stream_loader.clear_parameters;
            lics_stream_loader.set_parameter('MOE',to_char(rcd_load_file.moe_code));
            lics_stream_loader.set_parameter('FILE_ID',to_char(rcd_load_file.file_id));
            lics_stream_loader.execute('DF_SUPPLY_FINAL',null);
         end if;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end fcst_supply_load; 
/
