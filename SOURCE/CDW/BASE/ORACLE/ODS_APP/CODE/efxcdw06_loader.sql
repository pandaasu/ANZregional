/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw06_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw06_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Sales Territory Data - EFEX to CDW

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

end efxcdw06_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw06_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_trn_interface varchar2(32);
   var_trn_market number;
   var_trn_extract varchar2(14);
   rcd_efex_sales_terr efex_sales_terr%rowtype;

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
      var_trn_count := 0;
      var_trn_interface := null;
      var_trn_market := 0;
      var_trn_extract := null;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CTL','RCD_ID',3);
      lics_inbound_utility.set_definition('CTL','INT_ID',10);
      lics_inbound_utility.set_definition('CTL','MKT_ID',10);
      lics_inbound_utility.set_definition('CTL','EXT_ID',14);
      /*-*/
      lics_inbound_utility.set_definition('HDR','RCD_ID',3);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_NAME',50);
      lics_inbound_utility.set_definition('HDR','STE_STATUS',1);
      lics_inbound_utility.set_definition('HDR','STE_USR_ID',10);
      lics_inbound_utility.set_definition('HDR','SAR_ID',10);
      lics_inbound_utility.set_definition('HDR','SAR_NAME',50);
      lics_inbound_utility.set_definition('HDR','SAR_STATUS',1);
      lics_inbound_utility.set_definition('HDR','SAR_USR_ID',10);
      lics_inbound_utility.set_definition('HDR','SAR_USR_NAME',120);
      lics_inbound_utility.set_definition('HDR','SRE_ID',10);
      lics_inbound_utility.set_definition('HDR','SRE_NAME',50);
      lics_inbound_utility.set_definition('HDR','SRE_STATUS',1);
      lics_inbound_utility.set_definition('HDR','SRE_USR_ID',10);
      lics_inbound_utility.set_definition('HDR','SRE_USR_NAME',120);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_STATUS',1);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','EFX_DATE',14);

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
         efxcdw00_loader.update_interface(var_trn_interface, var_trn_market, var_trn_extract, var_trn_count);
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

      var_trn_interface := lics_inbound_utility.get_variable('INT_ID');
      var_trn_market := lics_inbound_utility.get_number('MKT_ID',null);
      var_trn_extract := lics_inbound_utility.get_variable('EXT_ID');

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

      rcd_efex_sales_terr.sales_terr_id := lics_inbound_utility.get_number('STE_ID',null);
      rcd_efex_sales_terr.sales_terr_name := lics_inbound_utility.get_variable('STE_NAME');
      rcd_efex_sales_terr.sales_terr_status := lics_inbound_utility.get_variable('STE_STATUS');
      rcd_efex_sales_terr.sales_terr_user_id := lics_inbound_utility.get_number('STE_USR_ID',null);
      rcd_efex_sales_terr.sales_area_id := lics_inbound_utility.get_number('SAR_ID',null);
      rcd_efex_sales_terr.sales_area_name := lics_inbound_utility.get_variable('SAR_NAME');
      rcd_efex_sales_terr.sales_area_status := lics_inbound_utility.get_variable('SAR_STATUS');
      rcd_efex_sales_terr.sales_area_user_id := lics_inbound_utility.get_number('SAR_USR_ID',null);
      rcd_efex_sales_terr.area_mgr_name := substr(lics_inbound_utility.get_variable('SAR_USR_NAME'),1,50);
      rcd_efex_sales_terr.sales_regn_id := lics_inbound_utility.get_number('SRE_ID',null);
      rcd_efex_sales_terr.sales_regn_name := lics_inbound_utility.get_variable('SRE_NAME');
      rcd_efex_sales_terr.sales_regn_status := lics_inbound_utility.get_variable('SRE_STATUS');
      rcd_efex_sales_terr.sales_regn_user_id := lics_inbound_utility.get_number('SRE_USR_ID',null);
      rcd_efex_sales_terr.regn_mgr_name := substr(lics_inbound_utility.get_variable('SRE_USR_NAME'),1,50);
      rcd_efex_sales_terr.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_sales_terr.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_sales_terr.sgmnt_status := lics_inbound_utility.get_variable('SEG_STATUS');
      rcd_efex_sales_terr.status := lics_inbound_utility.get_variable('STE_STATUS');
      rcd_efex_sales_terr.efex_lupdt := lics_inbound_utility.get_date('EFX_DATE','yyyymmddhh24miss');
      rcd_efex_sales_terr.valdtn_status := ods_constants.valdtn_unchecked;
      var_trn_count := var_trn_count + 1;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_sales_terr values rcd_efex_sales_terr;
      exception
         when dup_val_on_index then
            update efex_sales_terr
               set sales_terr_name = rcd_efex_sales_terr.sales_terr_name,
                   sales_terr_status = rcd_efex_sales_terr.sales_terr_status,
                   sales_terr_user_id = rcd_efex_sales_terr.sales_terr_user_id,
                   sales_area_id = rcd_efex_sales_terr.sales_area_id,
                   sales_area_name = rcd_efex_sales_terr.sales_area_name,
                   sales_area_status = rcd_efex_sales_terr.sales_area_status,
                   sales_area_user_id = rcd_efex_sales_terr.sales_area_user_id,
                   area_mgr_name = rcd_efex_sales_terr.area_mgr_name,
                   sales_regn_id = rcd_efex_sales_terr.sales_regn_id,
                   sales_regn_name = rcd_efex_sales_terr.sales_regn_name,
                   sales_regn_status = rcd_efex_sales_terr.sales_regn_status,
                   sales_regn_user_id = rcd_efex_sales_terr.sales_regn_user_id,
                   regn_mgr_name = rcd_efex_sales_terr.regn_mgr_name,
                   sgmnt_id = rcd_efex_sales_terr.sgmnt_id,
                   bus_unit_id = rcd_efex_sales_terr.bus_unit_id,
                   sgmnt_status = rcd_efex_sales_terr.sgmnt_status,
                   status = rcd_efex_sales_terr.status,
                   efex_lupdt = rcd_efex_sales_terr.efex_lupdt,
                   valdtn_status = rcd_efex_sales_terr.valdtn_status
             where sales_terr_id = rcd_efex_sales_terr.sales_terr_id;
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
   end process_record_hdr;

end efxcdw06_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw06_loader for ods_app.efxcdw06_loader;
grant execute on ods_app.efxcdw06_loader to lics_app;
