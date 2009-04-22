/******************/
/* Package Header */
/******************/
create or replace package apodfn07_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : apodfn07_loader
    Owner   : df_app

    Description
    -----------
    Integrated Planning Demand Financials - Apollo DFU to SKU mapping loader

    YYYY/MM   Author             Description
    -------   ------             -----------
    2009/04   Steve Gregan       Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end apodfn07_loader; 
/

/****************/
/* Package Body */
/****************/
create or replace package body apodfn07_loader as

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



Model	*DmdUnit	*DmdGroup	*DFULoc	*Item	*SKULoc	*Eff	*Disc	AllocFactor	SupersedeSw	ConvFactor


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
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end apodfn07_loader; 
/
