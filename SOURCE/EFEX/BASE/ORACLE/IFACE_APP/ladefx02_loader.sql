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
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_iface_customer iface_customer%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IFACE_CTL',3);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IFACE_HDR',3);
      lics_inbound_utility.set_definition('HDR','MARKET_ID',10);
      lics_inbound_utility.set_definition('HDR','CUSTOMER_CODE',50);
      lics_inbound_utility.set_definition('HDR','CUSTOMER_NAME',100);
      lics_inbound_utility.set_definition('HDR','ADDRESS_1',100);
      lics_inbound_utility.set_definition('HDR','CITY',50);
      lics_inbound_utility.set_definition('HDR','STATE',50);
      lics_inbound_utility.set_definition('HDR','POSTCODE',50);
      lics_inbound_utility.set_definition('HDR','PHONE_NUMBER',50);
      lics_inbound_utility.set_definition('HDR','FAX_NUMBER',50);
      lics_inbound_utility.set_definition('HDR','AFFILIATION',50);
      lics_inbound_utility.set_definition('HDR','CUST_TYPE',50);
      lics_inbound_utility.set_definition('HDR','CUST_STATUS',1);
      lics_inbound_utility.set_definition('HDR','CONTACT_NAME',50);
      lics_inbound_utility.set_definition('HDR','SALES_PERSON_CODE',20);
      lics_inbound_utility.set_definition('HDR','SALES_PERSON_NAME',50);
      lics_inbound_utility.set_definition('HDR','OUTLET_LOCATION',100);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL1_COD',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL2_CODE',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL3_CODE',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL4_CODE',10);
      lics_inbound_utility.set_definition('HDR','GEO_LEVEL5_CODE',10);
      lics_inbound_utility.set_definition('HDR','STD_LEVEL1_CODE',10);
      lics_inbound_utility.set_definition('HDR','STD_LEVEL2_CODE',10);
      lics_inbound_utility.set_definition('HDR','STD_LEVEL3_CODE',10);
      lics_inbound_utility.set_definition('HDR','STD_LEVEL4_CODE',10);

      /*-*/
      /* Clear the IFACE customer table for the China market
      /*-*/
      delete iface_customer
       where market_id = con_market_id;
      commit;

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
         rollback;
      elsif var_trn_error = true then
         rollback;
      else
         commit;
         efex_refresh.refresh_customer(con_market_id);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

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

      /*-*/
      /* Retrieve field values
      /*-*/      
      rcd_iface_customer.market_id := lics_inbound_utility.get_number('MARKET_ID',null);
      rcd_iface_customer.customer_code := lics_inbound_utility.get_variable('CUSTOMER_CODE');
      rcd_iface_customer.customer_name := lics_inbound_utility.get_variable('CUSTOMER_NAME');
      rcd_iface_customer.address_1 := lics_inbound_utility.get_variable('ADDRESS_1');
      rcd_iface_customer.city := lics_inbound_utility.get_variable('CITY');
      rcd_iface_customer.state := lics_inbound_utility.get_variable('STATE');
      rcd_iface_customer.postcode := lics_inbound_utility.get_variable('POSTCODE');
      rcd_iface_customer.phone_number := lics_inbound_utility.get_variable('PHONE_NUMBER');
      rcd_iface_customer.fax_number := lics_inbound_utility.get_variable('FAX_NUMBER');
      rcd_iface_customer.affiliation := lics_inbound_utility.get_variable('AFFILIATION');
      rcd_iface_customer.cust_type := lics_inbound_utility.get_variable('CUST_TYPE');
      rcd_iface_customer.cust_status := lics_inbound_utility.get_variable('CUST_STATUS');
      rcd_iface_customer.contact_name := lics_inbound_utility.get_variable('CONTACT_NAME');
      rcd_iface_customer.sales_person_code := lics_inbound_utility.get_variable('SALES_PERSON_CODE');
      rcd_iface_customer.sales_person_name := lics_inbound_utility.get_variable('SALES_PERSON_NAME');
      rcd_iface_customer.outlet_location := lics_inbound_utility.get_variable('OUTLET_LOCATION');
      rcd_iface_customer.geo_level1_code := lics_inbound_utility.get_variable('GEO_LEVEL1_CODE');
      rcd_iface_customer.geo_level2_code := lics_inbound_utility.get_variable('GEO_LEVEL2_CODE');
      rcd_iface_customer.geo_level3_code := lics_inbound_utility.get_variable('GEO_LEVEL3_CODE');
      rcd_iface_customer.geo_level4_code := lics_inbound_utility.get_variable('GEO_LEVEL4_CODE');
      rcd_iface_customer.geo_level5_code := lics_inbound_utility.get_variable('GEO_LEVEL5_CODE');
      rcd_iface_customer.std_level1_code := lics_inbound_utility.get_variable('STD_LEVEL1_CODE');
      rcd_iface_customer.std_level2_code := lics_inbound_utility.get_variable('STD_LEVEL2_CODE');
      rcd_iface_customer.std_level3_code := lics_inbound_utility.get_variable('STD_LEVEL3_CODE');
      rcd_iface_customer.std_level4_code := lics_inbound_utility.get_variable('STD_LEVEL4_CODE');

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
      if rcd_iface_customer.market_id != con_market_id then
         lics_inbound_utility.add_exception('Customer market id ('||rcd_iface_customer.market_id||') is not valid for the China market');
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

      insert into iface_customer
         (market_id,
          customer_code,
          customer_name,
          address_1,
          city,
          state,
          postcode,
          phone_number,
          fax_number,
          affiliation,
          cust_type,
          cust_status,
          contact_name,
          sales_person_code,
          sales_person_name,
          outlet_location,
          geo_level1_code,
          geo_level2_code,
          geo_level3_code,
          geo_level4_code,
          geo_level5_code,
          std_level1_code,
          std_level2_code,
          std_level3_code,
          std_level4_code)
      values
         (rcd_iface_customer.market_id,
          rcd_iface_customer.customer_code,
          rcd_iface_customer.customer_name,
          rcd_iface_customer.address_1,
          rcd_iface_customer.city,
          rcd_iface_customer.state,
          rcd_iface_customer.postcode,
          rcd_iface_customer.phone_number,
          rcd_iface_customer.fax_number,
          rcd_iface_customer.affiliation,
          rcd_iface_customer.cust_type,
          rcd_iface_customer.cust_status,
          rcd_iface_customer.contact_name,
          rcd_iface_customer.sales_person_code,
          rcd_iface_customer.sales_person_name,
          rcd_iface_customer.outlet_location,
          rcd_iface_customer.geo_level1_code,
          rcd_iface_customer.geo_level2_code,
          rcd_iface_customer.geo_level3_code,
          rcd_iface_customer.geo_level4_code,
          rcd_iface_customer.geo_level5_code,
          rcd_iface_customer.std_level1_code,
          rcd_iface_customer.std_level2_code,
          rcd_iface_customer.std_level3_code,
          rcd_iface_customer.std_level4_code);

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
