/******************/
/* Package Header */
/******************/
create or replace package iface_app.ladefx92_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx92_loader
    Owner   : iface_app

    Description
    -----------
    Efex - LADEFX92 - New Zealand Customer Loader

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ladefx92_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.ladefx92_loader as

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
   con_market_id constant number := 5;

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

      /*-*/
      /* Clear the IFACE customer table for the New Zealand market
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
         efex_refresh.refresh_nz_customer(con_market_id);
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
         lics_inbound_utility.add_exception('Customer market id ('||rcd_iface_customer.market_id||') is not valid for the New Zealand market');
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
          cust_type)
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
          rcd_iface_customer.cust_type);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ladefx92_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx92_loader for iface_app.ladefx92_loader;
grant execute on ladefx92_loader to lics_app;
