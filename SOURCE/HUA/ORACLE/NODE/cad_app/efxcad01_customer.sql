/******************/
/* Package Header */
/******************/
create or replace package efxcad01_customer as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcad01_customer
    Owner   : cad_app

    Description
    -----------
    China Applications Data - EFXCAD01 - Customer Data

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

end efxcad01_customer;
/

/****************/
/* Package Body */
/****************/
create or replace package body efxcad01_customer as

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
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_cad_efex_cust_master cad_efex_cust_master%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IDOC_CTL',3);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','MARKET',50);
      lics_inbound_utility.set_definition('HDR','BUSINES_UNIT',50);
      lics_inbound_utility.set_definition('HDR','SEGMENT',50);
      lics_inbound_utility.set_definition('HDR','CUST_TRADE_CHANNEL',50);
      lics_inbound_utility.set_definition('HDR','CUST_CHANNE',50);
      lics_inbound_utility.set_definition('HDR','CUST_TYPE',50);
      lics_inbound_utility.set_definition('HDR','CUST_GRADE',50);
      lics_inbound_utility.set_definition('HDR','CUST_CODE',50);
      lics_inbound_utility.set_definition('HDR','CUST_NAME',100);
      lics_inbound_utility.set_definition('HDR','CUST_CITY',50);
      lics_inbound_utility.set_definition('HDR','CUST_POSTCODE',50);
      lics_inbound_utility.set_definition('HDR','CUST_POSTAL_ADDR',50);
      lics_inbound_utility.set_definition('HDR','CUST_PHONE',50);
      lics_inbound_utility.set_definition('HDR','CUST_FAX',50);
      lics_inbound_utility.set_definition('HDR','CUST_EMAIL',50);
      lics_inbound_utility.set_definition('HDR','CUST_ADDRESS',50);
      lics_inbound_utility.set_definition('HDR','CUST_DISTRIBUTOR_FLAG',1);
      lics_inbound_utility.set_definition('HDR','CUST_OUTLET_FLAG',1);
      lics_inbound_utility.set_definition('HDR','CUST_ACTIVE_FLAG',1);
      lics_inbound_utility.set_definition('HDR','CUST_STATUS',1);
      lics_inbound_utility.set_definition('HDR','CUST_MP',50);
      lics_inbound_utility.set_definition('HDR','CUST_CREATED_ON',8);
      lics_inbound_utility.set_definition('HDR','CUST_CREATED_BY',10);
      lics_inbound_utility.set_definition('HDR','CUST_UPDATED_ON',8);
      lics_inbound_utility.set_definition('HDR','CUST_UPDATED_BY',10);
      lics_inbound_utility.set_definition('HDR','CUST_OTL_LOCATION',100);
      lics_inbound_utility.set_definition('HDR','CUST_COUNTRY_CODE',10);
      lics_inbound_utility.set_definition('HDR','CUST_COUNTRY_NAME',50);
      lics_inbound_utility.set_definition('HDR','CUST_REGION_CODE',10);
      lics_inbound_utility.set_definition('HDR','CUST_REGION_NAME',50);
      lics_inbound_utility.set_definition('HDR','CUST_CLUSTER_CODE',10);
      lics_inbound_utility.set_definition('HDR','CUST_CLUSTER_NAME',50);
      lics_inbound_utility.set_definition('HDR','CUST_AREA_CODE',10);
      lics_inbound_utility.set_definition('HDR','CUST_AREA_NAME',50);
      lics_inbound_utility.set_definition('HDR','CUST_CITY_CODE',10);
      lics_inbound_utility.set_definition('HDR','CUST_ACCOUNT_TYPE_CODE',10);
      lics_inbound_utility.set_definition('HDR','CUST_ACCOUNT_TYPE_DESC',50);
      lics_inbound_utility.set_definition('HDR','SALES_TERRITORY_CODE',10);
      lics_inbound_utility.set_definition('HDR','SALES_TERRITORY_NAME',50);
      lics_inbound_utility.set_definition('HDR','SALES_AREA',50);
      lics_inbound_utility.set_definition('HDR','SALES_REGION',50);
      lics_inbound_utility.set_definition('HDR','SALES_PERSON_ASSOCIATE_CODE',50);
      lics_inbound_utility.set_definition('HDR','SALES_PERSON_LAST_NAME',50);
      lics_inbound_utility.set_definition('HDR','SALES_PERSON_TITLE',50);
      lics_inbound_utility.set_definition('HDR','SALES_PERSON_STATUS',1);
      lics_inbound_utility.set_definition('HDR','SALES_CITY',50);
      lics_inbound_utility.set_definition('HDR','CUST_CONTACT_FIRST_NAME',50);
      lics_inbound_utility.set_definition('HDR','CUST_CONTACT_LAST_NAME',50);
      lics_inbound_utility.set_definition('HDR','CUST_CONTACT_PHONE',50);
      lics_inbound_utility.set_definition('HDR','CUST_CONTACT_EMAIL',50);
      lics_inbound_utility.set_definition('HDR','CUST_INDIRECT_CUST_BANNER',50);
      lics_inbound_utility.set_definition('HDR','CUST_PARENT_BANNER_CODE',50);
      lics_inbound_utility.set_definition('HDR','CUST_PARENT_BANNER_NAME',50);
      lics_inbound_utility.set_definition('HDR','CUST_DIRECT_BANNER_CODE',50);
      lics_inbound_utility.set_definition('HDR','CUST_DIRECT_BANNER_NAME',50);
      lics_inbound_utility.set_definition('HDR','CUST_BELONGS_TO_WS_CODE',50);
      lics_inbound_utility.set_definition('HDR','CUST_BELONGS_TO_WS_NAME',50);

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
      rcd_cad_efex_cust_master.market := lics_inbound_utility.get_variable('MARKET');
      rcd_cad_efex_cust_master.busines_unit := lics_inbound_utility.get_variable('BUSINES_UNIT');
      rcd_cad_efex_cust_master.segment := lics_inbound_utility.get_variable('SEGMENT');
      rcd_cad_efex_cust_master.cust_trade_channel := lics_inbound_utility.get_variable('CUST_TRADE_CHANNEL');
      rcd_cad_efex_cust_master.cust_channel := lics_inbound_utility.get_variable('CUST_CHANNEL');                         
      rcd_cad_efex_cust_master.cust_type := lics_inbound_utility.get_variable('CUST_TYPE');
      rcd_cad_efex_cust_master.cust_grade := lics_inbound_utility.get_variable('CUST_GRADE');                         
      rcd_cad_efex_cust_master.cust_code := lics_inbound_utility.get_variable('CUST_CODE');
      rcd_cad_efex_cust_master.cust_name := lics_inbound_utility.get_variable('CUST_NAME');
      rcd_cad_efex_cust_master.cust_city := lics_inbound_utility.get_variable('CUST_CITY');                         
      rcd_cad_efex_cust_master.cust_postcode := lics_inbound_utility.get_variable('CUST_POSTCODE');
      rcd_cad_efex_cust_master.cust_postal_addr := lics_inbound_utility.get_variable('CUST_POSTAL_ADDR');                         
      rcd_cad_efex_cust_master.cust_phone := lics_inbound_utility.get_variable('CUST_PHONE');
      rcd_cad_efex_cust_master.cust_fax := lics_inbound_utility.get_variable('CUST_FAX');
      rcd_cad_efex_cust_master.cust_email := lics_inbound_utility.get_variable('CUST_EMAIL');
      rcd_cad_efex_cust_master.cust_address := lics_inbound_utility.get_variable('CUST_ADDRESS');
      rcd_cad_efex_cust_master.cust_distributor_flag := lics_inbound_utility.get_variable('CUST_DISTRIBUTOR_FLAG');
      rcd_cad_efex_cust_master.cust_outlet_flag := lics_inbound_utility.get_variable('CUST_OUTLET_FLAG');
      rcd_cad_efex_cust_master.cust_active_flag := lics_inbound_utility.get_variable('CUST_ACTIVE_FLAG');
      rcd_cad_efex_cust_master.cust_status := lics_inbound_utility.get_variable('CUST_STATUS');
      rcd_cad_efex_cust_master.cust_mp := lics_inbound_utility.get_variable('CUST_MP');
      rcd_cad_efex_cust_master.cust_created_on := lics_inbound_utility.get_date('CUST_CREATED_ON','yyyymmdd');
      rcd_cad_efex_cust_master.cust_created_by := lics_inbound_utility.get_variable('CUST_CREATED_BY');
      rcd_cad_efex_cust_master.cust_updated_on := lics_inbound_utility.get_date('CUST_UPDATED_ON','yyyymmdd');
      rcd_cad_efex_cust_master.cust_updated_by := lics_inbound_utility.get_variable('CUST_UPDATED_BY');
      rcd_cad_efex_cust_master.cust_otl_location := lics_inbound_utility.get_variable('CUST_OTL_LOCATION');
      rcd_cad_efex_cust_master.cust_country_code := lics_inbound_utility.get_variable('CUST_COUNTRY_CODE');
      rcd_cad_efex_cust_master.cust_country_name := lics_inbound_utility.get_variable('CUST_COUNTRY_NAME');
      rcd_cad_efex_cust_master.cust_region_code := lics_inbound_utility.get_variable('CUST_REGION_CODE');
      rcd_cad_efex_cust_master.cust_region_name := lics_inbound_utility.get_variable('CUST_REGION_NAME');
      rcd_cad_efex_cust_master.cust_cluster_code := lics_inbound_utility.get_variable('CUST_CLUSTER_CODE');
      rcd_cad_efex_cust_master.cust_cluster_name := lics_inbound_utility.get_variable('CUST_CLUSTER_NAME');
      rcd_cad_efex_cust_master.cust_area_code := lics_inbound_utility.get_variable('CUST_AREA_CODE');                         
      rcd_cad_efex_cust_master.cust_area_name := lics_inbound_utility.get_variable('CUST_AREA_NAME');
      rcd_cad_efex_cust_master.cust_city_code := lics_inbound_utility.get_variable('CUST_CITY_CODE');
      rcd_cad_efex_cust_master.cust_account_type_code := lics_inbound_utility.get_variable('CUST_ACCOUNT_TYPE_CODE');
      rcd_cad_efex_cust_master.cust_account_type_desc := lics_inbound_utility.get_variable('CUST_ACCOUNT_TYPE_DESC');                        
      rcd_cad_efex_cust_master.sales_territory_code := lics_inbound_utility.get_variable('SALES_TERRITORY_CODE');
      rcd_cad_efex_cust_master.sales_territory_name := lics_inbound_utility.get_variable('SALES_TERRITORY_NAME');
      rcd_cad_efex_cust_master.sales_area := lics_inbound_utility.get_variable('SALES_AREA');
      rcd_cad_efex_cust_master.sales_region := lics_inbound_utility.get_variable('SALES_REGION');
      rcd_cad_efex_cust_master.sales_person_associate_code := lics_inbound_utility.get_variable('SALES_PERSON_ASSOCIATE_CODE');
      rcd_cad_efex_cust_master.sales_person_last_name := lics_inbound_utility.get_variable('SALES_PERSON_LAST_NAME');
      rcd_cad_efex_cust_master.sales_person_title := lics_inbound_utility.get_variable('SALES_PERSON_TITLE');
      rcd_cad_efex_cust_master.sales_person_status := lics_inbound_utility.get_variable('SALES_PERSON_STATUS');
      rcd_cad_efex_cust_master.sales_city := lics_inbound_utility.get_variable('SALES_CITY');
      rcd_cad_efex_cust_master.cust_contact_first_name := lics_inbound_utility.get_variable('CUST_CONTACT_FIRST_NAME');
      rcd_cad_efex_cust_master.cust_contact_last_name := lics_inbound_utility.get_variable('CUST_CONTACT_LAST_NAME');
      rcd_cad_efex_cust_master.cust_contact_phone := lics_inbound_utility.get_variable('CUST_CONTACT_PHONE');
      rcd_cad_efex_cust_master.cust_contact_email := lics_inbound_utility.get_variable('CUST_CONTACT_EMAIL');
      rcd_cad_efex_cust_master.cust_indirect_cust_banner := lics_inbound_utility.get_variable('CUST_INDIRECT_CUST_BANNER');
      rcd_cad_efex_cust_master.cust_parent_banner_code := lics_inbound_utility.get_variable('CUST_PARENT_BANNER_CODE');
      rcd_cad_efex_cust_master.cust_parent_banner_name := lics_inbound_utility.get_variable('CUST_PARENT_BANNER_NAME');
      rcd_cad_efex_cust_master.cust_direct_banner_code := lics_inbound_utility.get_variable('CUST_DIRECT_BANNER_CODE');
      rcd_cad_efex_cust_master.cust_direct_banner_name := lics_inbound_utility.get_variable('CUST_DIRECT_BANNER_NAME');
      rcd_cad_efex_cust_master.cust_belongs_to_ws_code := lics_inbound_utility.get_variable('CUST_BELONGS_TO_WS_CODE');
      rcd_cad_efex_cust_master.cust_belongs_to_ws_name := lics_inbound_utility.get_variable('CUST_BELONGS_TO_WS_NAME');

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
      if rcd_cad_efex_cust_master.cust_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.CUST_CODE');
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
      /* Delete existing row
      /*-*/
      delete cad_efex_cust_master
       where cust_code = rcd_cad_efex_cust_master.cust_code;

      /*-*/
      /* Insert the new row
      /*-*/
      insert into cad_efex_cust_master values rcd_cad_efex_cust_master;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end efxcad01_customer;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcad01_customer for cad_app.efxcad01_customer;
grant execute on efxcad01_customer to lics_app;
