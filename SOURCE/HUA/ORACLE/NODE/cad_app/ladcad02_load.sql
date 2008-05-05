create or replace package ladcad02_price_list as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : CAD
 Package : ladcad02_price_list
 Owner   : CAD_APP
 Author  : Linden Glen

 Description
 -----------
 China Applications Data - CADLAD02 - Price List

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

end ladcad02_price_list;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladcad02_price_list as

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

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_cad_list_price cad_list_price%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','PRICE_LIST_TYPE',4);
      lics_inbound_utility.set_definition('HDR','SAP_COMPANY_CODE',4);
      lics_inbound_utility.set_definition('HDR','SAP_MATERIAL_CODE',18);
      lics_inbound_utility.set_definition('HDR','PRICE_LIST_CURRCY',5);
      lics_inbound_utility.set_definition('HDR','UOM',3);
      lics_inbound_utility.set_definition('HDR','EFF_START_DATE',8);
      lics_inbound_utility.set_definition('HDR','EFF_END_DATE',8);
      lics_inbound_utility.set_definition('HDR','LIST_PRICE',11);

      /*-*/
      /* Delete Price master entries
      /*-*/
      delete cad_list_price;

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

      /*-*/
      /* Local cursors
      /*-*/

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

      /*-*/
      /* Retrieve field values
      /*-*/      
      rcd_cad_list_price.price_list_type := lics_inbound_utility.get_variable('PRICE_LIST_TYPE');
      rcd_cad_list_price.sap_company_code := lics_inbound_utility.get_variable('SAP_COMPANY_CODE');
      rcd_cad_list_price.sap_material_code := lics_inbound_utility.get_variable('SAP_MATERIAL_CODE');
      rcd_cad_list_price.price_list_currcy := lics_inbound_utility.get_variable('PRICE_LIST_CURRCY');
      rcd_cad_list_price.uom := lics_inbound_utility.get_variable('UOM');
      rcd_cad_list_price.eff_start_date := lics_inbound_utility.get_variable('EFF_START_DATE');
      rcd_cad_list_price.eff_end_date := lics_inbound_utility.get_variable('EFF_END_DATE');
      rcd_cad_list_price.list_price := lics_inbound_utility.get_variable('LIST_PRICE');
      rcd_cad_list_price.cad_load_date := sysdate;

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

      insert into cad_list_price
         (price_list_type,
          sap_company_code,
          sap_material_code,
          price_list_currcy,
          uom,
          eff_start_date,
          eff_end_date,
          list_price,
          cad_load_date)
      values
         (rcd_cad_list_price.price_list_type,
          rcd_cad_list_price.sap_company_code,
          rcd_cad_list_price.sap_material_code,
          rcd_cad_list_price.price_list_currcy,
          rcd_cad_list_price.uom,
          rcd_cad_list_price.eff_start_date,
          rcd_cad_list_price.eff_end_date,
          rcd_cad_list_price.list_price,
          rcd_cad_list_price.cad_load_date);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ladcad02_price_list;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladcad02_price_list for cad_app.ladcad02_price_list;
grant execute on ladcad02_price_list to lics_app;
