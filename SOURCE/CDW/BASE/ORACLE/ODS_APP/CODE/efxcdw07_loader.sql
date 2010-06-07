/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw07_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw07_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Customer Data - EFEX to CDW

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

end efxcdw07_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw07_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   rcd_efex_cust efex_cust%rowtype;

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
      lics_inbound_utility.set_definition('HDR','RCD_ID',3);
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','CUS_CODE',50);
      lics_inbound_utility.set_definition('HDR','CUS_NAME',100);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      lics_inbound_utility.set_definition('HDR','ADR_TEXT1',100);
      lics_inbound_utility.set_definition('HDR','ADR_TEXT2',100);
      lics_inbound_utility.set_definition('HDR','ADR_POST',50);
      lics_inbound_utility.set_definition('HDR','ADR_CITY',50);
      lics_inbound_utility.set_definition('HDR','ADR_STATE',50);
      lics_inbound_utility.set_definition('HDR','ADR_PCODE',50);
      lics_inbound_utility.set_definition('HDR','PHO_NUMB',50);
      lics_inbound_utility.set_definition('HDR','DIS_FLAG',1);
      lics_inbound_utility.set_definition('HDR','OUT_FLAG',1);
      lics_inbound_utility.set_definition('HDR','ACT_FLAG',1);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','RAN_ID',10);
      lics_inbound_utility.set_definition('HDR','CVF_ID',10);
      lics_inbound_utility.set_definition('HDR','RPT_MEASURE',15);
      lics_inbound_utility.set_definition('HDR','CTY_ID',10);
      lics_inbound_utility.set_definition('HDR','AFF_ID',10);
      lics_inbound_utility.set_definition('HDR','DIS_ID',10);
      lics_inbound_utility.set_definition('HDR','CGR_ID',10);
      lics_inbound_utility.set_definition('HDR','CGR_NAME',50);
      lics_inbound_utility.set_definition('HDR','PAY_NAME',50);
      lics_inbound_utility.set_definition('HDR','MCH_NAME',50);
      lics_inbound_utility.set_definition('HDR','MCH_CODE',50);
      lics_inbound_utility.set_definition('HDR','VEN_CODE',50);
      lics_inbound_utility.set_definition('HDR','VAT_NUMB',50);
      lics_inbound_utility.set_definition('HDR','DAY_MEAL',15);
      lics_inbound_utility.set_definition('HDR','LED_TIME',15);
      lics_inbound_utility.set_definition('HDR','DSC_PERCENT',15);
      lics_inbound_utility.set_definition('HDR','COR_FLAG',1);
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
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

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

      rcd_efex_cust.efex_cust_id := lics_inbound_utility.get_number('CUS_ID',null);
      rcd_efex_cust.cust_code := lics_inbound_utility.get_variable('CUS_CODE');
      rcd_efex_cust.cust_name := lics_inbound_utility.get_variable('CUS_NAME');
      rcd_efex_cust.addr_1 := lics_inbound_utility.get_variable('ADR_TEXT1');
      rcd_efex_cust.addr_2 := lics_inbound_utility.get_variable('ADR_TEXT2');
      rcd_efex_cust.postal_addr := lics_inbound_utility.get_variable('ADR_POST');
      rcd_efex_cust.city := lics_inbound_utility.get_variable('ADR_CITY');
      rcd_efex_cust.state := lics_inbound_utility.get_variable('ADR_STATE');
      rcd_efex_cust.postcode := lics_inbound_utility.get_variable('ADR_PCODE');
      rcd_efex_cust.phone := lics_inbound_utility.get_variable('PHO_NUMB');
      rcd_efex_cust.distbr_flg := lics_inbound_utility.get_variable('DIS_FLAG');
      rcd_efex_cust.outlet_flg := lics_inbound_utility.get_variable('OUT_FLAG');
      rcd_efex_cust.active_flg := lics_inbound_utility.get_variable('ACT_FLAG');
      rcd_efex_cust.sales_terr_id := lics_inbound_utility.get_number('STE_ID',null);
      rcd_efex_cust.range_id := lics_inbound_utility.get_number('RAN_ID',null);
      rcd_efex_cust.cust_visit_freq_id := lics_inbound_utility.get_number('CVF_ID',null);
      rcd_efex_cust.cust_visit_freq := lics_inbound_utility.get_variable('RPT_MEASURE');
      rcd_efex_cust.cust_type_id := lics_inbound_utility.get_number('CTY_ID',null);
      rcd_efex_cust.affltn_id := lics_inbound_utility.get_number('AFF_ID',null);
      rcd_efex_cust.distbr_id := lics_inbound_utility.get_number('DIS_ID',null);
      rcd_efex_cust.cust_grade_id := lics_inbound_utility.get_number('CGR_ID',null);
      rcd_efex_cust.cust_grade := lics_inbound_utility.get_variable('CGR_NAME');
      rcd_efex_cust.payee_name := lics_inbound_utility.get_variable('PAY_NAME');
      rcd_efex_cust.merch_name := lics_inbound_utility.get_variable('MCH_NAME');
      rcd_efex_cust.merch_code := lics_inbound_utility.get_variable('MCH_CODE');
      rcd_efex_cust.vendor_code := lics_inbound_utility.get_variable('VEN_CODE');
      rcd_efex_cust.abn := lics_inbound_utility.get_variable('VAT_NUMB');
      rcd_efex_cust.meals_day := lics_inbound_utility.get_number('DAY_MEAL',null);
      rcd_efex_cust.lead_time := lics_inbound_utility.get_number('LED_TIME',null);
      rcd_efex_cust.disc_pct := lics_inbound_utility.get_number('DSC_PERCENT',null);
      rcd_efex_cust.corporate_flg := lics_inbound_utility.get_variable('COR_FLAG');
      rcd_efex_cust.efex_lupdt := lics_inbound_utility.get_date('EFX_DATE','yyyymmddhh24miss');
      rcd_efex_cust.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_cust.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_cust values rcd_efex_cust;
      exception
         when dup_val_on_index then
            update efex_cust
               set cust_code = rcd_efex_cust.cust_code,
                   cust_name = rcd_efex_cust.cust_name,
                   addr_1 = rcd_efex_cust.addr_1,
                   addr_2 = rcd_efex_cust.addr_2,
                   postal_addr = rcd_efex_cust.postal_addr,
                   city = rcd_efex_cust.city,
                   state = rcd_efex_cust.state,
                   postcode = rcd_efex_cust.postcode,
                   phone = rcd_efex_cust.phone,
                   distbr_flg = rcd_efex_cust.distbr_flg,
                   outlet_flg = rcd_efex_cust.outlet_flg,
                   active_flg = rcd_efex_cust.active_flg,
                   sales_terr_id = rcd_efex_cust.sales_terr_id,
                   range_id = rcd_efex_cust.range_id,
                   cust_visit_freq_id = rcd_efex_cust.cust_visit_freq_id,
                   cust_visit_freq = rcd_efex_cust.cust_visit_freq,
                   cust_type_id = rcd_efex_cust.cust_type_id,
                   affltn_id = rcd_efex_cust.affltn_id,
                   distbr_id = rcd_efex_cust.distbr_id,
                   cust_grade_id = rcd_efex_cust.cust_grade_id,
                   cust_grade = rcd_efex_cust.cust_grade,
                   payee_name = rcd_efex_cust.payee_name,
                   merch_name = rcd_efex_cust.merch_name,
                   merch_code = rcd_efex_cust.merch_code,
                   vendor_code = rcd_efex_cust.vendor_code,
                   abn = rcd_efex_cust.abn,
                   meals_day = rcd_efex_cust.meals_day,
                   lead_time = rcd_efex_cust.lead_time,
                   disc_pct = rcd_efex_cust.disc_pct,
                   corporate_flg = rcd_efex_cust.corporate_flg,
                   efex_lupdt = rcd_efex_cust.efex_lupdt,
                   status = rcd_efex_cust.status,
                   valdtn_status = rcd_efex_cust.valdtn_status
             where efex_cust_id = rcd_efex_cust.efex_cust_id;
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

end efxcdw07_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw07_loader for ods_app.efxcdw07_loader;
grant execute on ods_app.efxcdw07_loader to lics_app;
