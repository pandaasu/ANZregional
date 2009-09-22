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
    2009/09   Steve Gregan       Modified to extend end date when less than 2000

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
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ';';
   con_qualifier constant varchar2(10) := '"';

   /*-*/
   /* Private definitions 
   /*-*/
   var_trn_start boolean;
   var_trn_error boolean;
   rcd_dmnd_sku_mapping dmnd_sku_mapping%rowtype;

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

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('MODEL',1);
      lics_inbound_utility.set_csv_definition('DMD_UNIT',2);
      lics_inbound_utility.set_csv_definition('DMD_GROUP',3);
      lics_inbound_utility.set_csv_definition('DFU_LOCN',4);
      lics_inbound_utility.set_csv_definition('ITEM',5);
      lics_inbound_utility.set_csv_definition('SKU_LOCN',6);
      lics_inbound_utility.set_csv_definition('STR_DATE',7);
      lics_inbound_utility.set_csv_definition('END_DATE',8);
      lics_inbound_utility.set_csv_definition('ALLOC_FACTOR',9);
      lics_inbound_utility.set_csv_definition('SUPERCEDE',10);
      lics_inbound_utility.set_csv_definition('CONV_FACTOR',11);

      /*-*/
      /* Delete the existing demand SKU mapping data
      /*-*/ 
      delete from dmnd_sku_mapping;

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
      /* Local definitions
      /*-*/
      var_end_date date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_csv_record(par_record, con_delimiter, con_qualifier);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
     
      /*-*/
      /* Retrieve field values
      /*-*/
      var_end_date := nvl(lics_inbound_utility.get_date('END_DATE','dd/mm/yyyy'),to_date('31/12/9999','dd/mm/yyyy'));
      if var_end_date < to_date('20000101','yyyymmdd') then
         var_end_date := to_date('31/12/9999','dd/mm/yyyy');
      end if;
      rcd_dmnd_sku_mapping.model_code := lics_inbound_utility.get_variable('MODEL');
      rcd_dmnd_sku_mapping.dmd_unit := lics_inbound_utility.get_variable('DMD_UNIT');
      rcd_dmnd_sku_mapping.dmd_group := lics_inbound_utility.get_variable('DMD_GROUP');
      rcd_dmnd_sku_mapping.dfu_locn := lics_inbound_utility.get_variable('DFU_LOCN');
      rcd_dmnd_sku_mapping.item := lics_inbound_utility.get_variable('ITEM');
      rcd_dmnd_sku_mapping.sku_locn := lics_inbound_utility.get_variable('SKU_LOCN');
      rcd_dmnd_sku_mapping.str_date := nvl(lics_inbound_utility.get_date('STR_DATE','dd/mm/yyyy'),to_date('01/01/0001','dd/mm/yyyy'));
      rcd_dmnd_sku_mapping.end_date := var_end_date;
      rcd_dmnd_sku_mapping.alloc_factor := nvl(lics_inbound_utility.get_number('ALLOC_FACTOR',null),1);
      rcd_dmnd_sku_mapping.conv_factor := nvl(lics_inbound_utility.get_number('CONV_FACTOR',null),1);

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

      /*-*/
      /* Insert the demand mapping data
      /*-*/
      insert into dmnd_sku_mapping values rcd_dmnd_sku_mapping;
      
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
      if var_trn_error = true then
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

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym apodfn07_loader for df_app.apodfn07_loader;
grant execute on df_app.apodfn07_loader to lics_app;