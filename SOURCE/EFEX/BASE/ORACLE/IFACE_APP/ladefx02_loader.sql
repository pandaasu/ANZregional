/******************/
/* Package Header */
/******************/
create or replace package ladefx02_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx02_loader
    Owner   : iface_app

    Description
    -----------
    Efex - LADEFX02 - China Customer Loader

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ladefx02_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladefx02_loader as

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
   rcd_cad_customer_master cad_customer_master%rowtype;

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
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);      
      lics_inbound_utility.set_definition('HDR','SAP_CUSTOMER_CODE',10);
      lics_inbound_utility.set_definition('HDR','SAP_CUSTOMER_NAME',160);
      lics_inbound_utility.set_definition('HDR','SHIP_TO_CUST_CODE',10);
      lics_inbound_utility.set_definition('HDR','SHIP_TO_CUST_NAME',40);
      lics_inbound_utility.set_definition('HDR','BILL_TO_CUST_CODE',10);
      lics_inbound_utility.set_definition('HDR','BILL_TO_CUST_NAME',40);
      lics_inbound_utility.set_definition('HDR','SALESMAN_CODE',10);
      lics_inbound_utility.set_definition('HDR','SALESMAN_NAME',40);
      lics_inbound_utility.set_definition('HDR','CITY_CODE',10);
      lics_inbound_utility.set_definition('HDR','CITY_NAME',40);
      lics_inbound_utility.set_definition('HDR','HUB_CITY_CODE',10);
      lics_inbound_utility.set_definition('HDR','HUB_CITY_NAME',40);
      lics_inbound_utility.set_definition('HDR','ADDRESS_STREET_EN',60);
      lics_inbound_utility.set_definition('HDR','ADDRESS_SORT_EN',20);
      lics_inbound_utility.set_definition('HDR','REGION_CODE',3);
      lics_inbound_utility.set_definition('HDR','PLANT_CODE',4);
      lics_inbound_utility.set_definition('HDR','VAT_REGISTRATION_NUMBER',20);
      lics_inbound_utility.set_definition('HDR','CUSTOMER_STATUS',1);
      lics_inbound_utility.set_definition('HDR','INSURANCE_NUMBER',10);
      lics_inbound_utility.set_definition('HDR','BUYING_GRP_CODE',10);
      lics_inbound_utility.set_definition('HDR','BUYING_GRP_NAME',120);
      lics_inbound_utility.set_definition('HDR','KEY_ACCOUNT_CODE',10);
      lics_inbound_utility.set_definition('HDR','KEY_ACCOUNT_NAME',120);
      lics_inbound_utility.set_definition('HDR','CHANNEL_CODE',10);
      lics_inbound_utility.set_definition('HDR','CHANNEL_NAME',120);
      lics_inbound_utility.set_definition('HDR','CHANNEL_GRP_CODE',10);
      lics_inbound_utility.set_definition('HDR','CHANNEL_GRP_NAME',120);
      lics_inbound_utility.set_definition('HDR','SWB_STATUS',8);
      lics_inbound_utility.set_definition('HDR','LAST_UPDATE_DATE',14);


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
      /* Complete Previous Transaction */
      /*-------------------------------*/
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

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/      
      rcd_cad_customer_master.sap_customer_code := lics_inbound_utility.get_variable('SAP_CUSTOMER_CODE');
      rcd_cad_customer_master.sap_customer_name := lics_inbound_utility.get_variable('SAP_CUSTOMER_NAME');
      rcd_cad_customer_master.ship_to_cust_code := lics_inbound_utility.get_variable('SHIP_TO_CUST_CODE');
      rcd_cad_customer_master.ship_to_cust_name := lics_inbound_utility.get_variable('SHIP_TO_CUST_NAME');
      rcd_cad_customer_master.bill_to_cust_code := lics_inbound_utility.get_variable('BILL_TO_CUST_CODE');
      rcd_cad_customer_master.bill_to_cust_name := lics_inbound_utility.get_variable('BILL_TO_CUST_NAME');
      rcd_cad_customer_master.salesman_code := lics_inbound_utility.get_variable('SALESMAN_CODE');
      rcd_cad_customer_master.salesman_name := lics_inbound_utility.get_variable('SALESMAN_NAME');
      rcd_cad_customer_master.city_code := lics_inbound_utility.get_variable('CITY_CODE');
      rcd_cad_customer_master.city_name := lics_inbound_utility.get_variable('CITY_NAME');
      rcd_cad_customer_master.hub_city_code := lics_inbound_utility.get_variable('HUB_CITY_CODE');
      rcd_cad_customer_master.hub_city_name := lics_inbound_utility.get_variable('HUB_CITY_NAME');
      rcd_cad_customer_master.address_street_en := lics_inbound_utility.get_variable('ADDRESS_STREET_EN');
      rcd_cad_customer_master.address_sort_en := lics_inbound_utility.get_variable('ADDRESS_SORT_EN');
      rcd_cad_customer_master.region_code := lics_inbound_utility.get_variable('REGION_CODE');
      rcd_cad_customer_master.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
      rcd_cad_customer_master.vat_registration_number := lics_inbound_utility.get_variable('VAT_REGISTRATION_NUMBER');
      rcd_cad_customer_master.customer_status := lics_inbound_utility.get_variable('CUSTOMER_STATUS');
      rcd_cad_customer_master.insurance_number := lics_inbound_utility.get_variable('INSURANCE_NUMBER');
      rcd_cad_customer_master.buying_grp_code := lics_inbound_utility.get_variable('BUYING_GRP_CODE');
      rcd_cad_customer_master.buying_grp_name := lics_inbound_utility.get_variable('BUYING_GRP_NAME');
      rcd_cad_customer_master.key_account_code := lics_inbound_utility.get_variable('KEY_ACCOUNT_CODE');
      rcd_cad_customer_master.key_account_name := lics_inbound_utility.get_variable('KEY_ACCOUNT_NAME');
      rcd_cad_customer_master.channel_code := lics_inbound_utility.get_variable('CHANNEL_CODE');
      rcd_cad_customer_master.channel_name := lics_inbound_utility.get_variable('CHANNEL_NAME');
      rcd_cad_customer_master.channel_grp_code := lics_inbound_utility.get_variable('CHANNEL_GRP_CODE');
      rcd_cad_customer_master.channel_grp_name := lics_inbound_utility.get_variable('CHANNEL_GRP_NAME');
      rcd_cad_customer_master.last_update_date := lics_inbound_utility.get_variable('LAST_UPDATE_DATE');
      rcd_cad_customer_master.swb_status := lics_inbound_utility.get_variable('SWB_STATUS');
      rcd_cad_customer_master.cad_load_date := sysdate;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_cad_customer_master.sap_customer_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.SAP_CUSTOMER_CODE');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*-*/
      /* Delete Material master entry if it exists
      /*-*/
      delete cad_customer_master
       where sap_customer_code = rcd_cad_customer_master.sap_customer_code;

      insert into cad_customer_master
         (sap_customer_code,
          sap_customer_name,
          ship_to_cust_code,
          ship_to_cust_name,
          bill_to_cust_code,
          bill_to_cust_name,
          salesman_code,
          salesman_name,
          city_code,
          city_name,
          hub_city_code,
          hub_city_name,
          address_street_en,
          address_sort_en,
          region_code,
          plant_code,
          vat_registration_number,
          customer_status,
          insurance_number,
          buying_grp_code,
          buying_grp_name,
          key_account_code,
          key_account_name,
          channel_code,
          channel_name,
          channel_grp_code,
          channel_grp_name,
          swb_status,
          last_update_date,
          cad_load_date)
      values
         (rcd_cad_customer_master.sap_customer_code,
          rcd_cad_customer_master.sap_customer_name,
          rcd_cad_customer_master.ship_to_cust_code,
          rcd_cad_customer_master.ship_to_cust_name,
          rcd_cad_customer_master.bill_to_cust_code,
          rcd_cad_customer_master.bill_to_cust_name,
          rcd_cad_customer_master.salesman_code,
          rcd_cad_customer_master.salesman_name,
          rcd_cad_customer_master.city_code,
          rcd_cad_customer_master.city_name,
          rcd_cad_customer_master.hub_city_code,
          rcd_cad_customer_master.hub_city_name,
          rcd_cad_customer_master.address_street_en,
          rcd_cad_customer_master.address_sort_en,
          rcd_cad_customer_master.region_code,
          rcd_cad_customer_master.plant_code,
          rcd_cad_customer_master.vat_registration_number,
          rcd_cad_customer_master.customer_status,
          rcd_cad_customer_master.insurance_number,
          rcd_cad_customer_master.buying_grp_code,
          rcd_cad_customer_master.buying_grp_name,
          rcd_cad_customer_master.key_account_code,
          rcd_cad_customer_master.key_account_name,
          rcd_cad_customer_master.channel_code,
          rcd_cad_customer_master.channel_name,
          rcd_cad_customer_master.channel_grp_code,
          rcd_cad_customer_master.channel_grp_name,
          rcd_cad_customer_master.swb_status,
          rcd_cad_customer_master.last_update_date,
          rcd_cad_customer_master.cad_load_date);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ladefx02_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx02_loader for iface_app.ladefx02_loader;
grant execute on ladefx02_loader to lics_app;
