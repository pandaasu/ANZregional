/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw05_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw05_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Customer Channel Data - EFEX to CDW

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

end efxcdw05_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw05_loader as

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
   rcd_efex_cust_chnl efex_cust_chnl%rowtype;

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
      lics_inbound_utility.set_definition('HDR','CTY_ID',10);
      lics_inbound_utility.set_definition('HDR','CTY_NAME',50);
      lics_inbound_utility.set_definition('HDR','CTY_STATUS',1);
      lics_inbound_utility.set_definition('HDR','CTC_ID',10);
      lics_inbound_utility.set_definition('HDR','CTC_NAME',50);
      lics_inbound_utility.set_definition('HDR','CTC_STATUS',1);
      lics_inbound_utility.set_definition('HDR','CCH_ID',10);
      lics_inbound_utility.set_definition('HDR','CCH_NAME',50);
      lics_inbound_utility.set_definition('HDR','CCH_STATUS',1);
      lics_inbound_utility.set_definition('HDR','MKT_ID',10);

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

      rcd_efex_cust_chnl.cust_type_id := lics_inbound_utility.get_number('CTY_ID');
      rcd_efex_cust_chnl.cust_type_name := lics_inbound_utility.get_variable('CTY_NAME');
      rcd_efex_cust_chnl.cust_type_status := lics_inbound_utility.get_variable('CTY_STATUS');
      rcd_efex_cust_chnl.cust_trad_chnl_id := lics_inbound_utility.get_number('CTC_ID');
      rcd_efex_cust_chnl.cust_trad_chnl_name := lics_inbound_utility.get_variable('CTC_NAME');
      rcd_efex_cust_chnl.trad_chnl_status := lics_inbound_utility.get_variable('CTC_STATUS');
      rcd_efex_cust_chnl.cust_chnl_id := lics_inbound_utility.get_number('CCH_ID');
      rcd_efex_cust_chnl.cust_chnl_name := lics_inbound_utility.get_variable('CCH_NAME');
      rcd_efex_cust_chnl.cust_chnl_status := lics_inbound_utility.get_variable('CCH_STATUS');
      rcd_efex_cust_chnl.market_id := lics_inbound_utility.get_number('MKT_ID');
      rcd_efex_cust_chnl.valdtn_status := ods_constants.valdtn_valid;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_cust_chnl values rcd_efex_cust_chnl;
      exception
         when dup_val_on_index then
            update efex_cust_chnl
               set cust_type_name = rcd_efex_cust_chnl.cust_type_name,
                   cust_type_status = rcd_efex_cust_chnl.cust_type_status,
                   cust_trad_chnl_id = rcd_efex_cust_chnl.cust_trad_chnl_id,
                   cust_trad_chnl_name = rcd_efex_cust_chnl.cust_trad_chnl_name,
                   trad_chnl_status = rcd_efex_cust_chnl.trad_chnl_status,
                   cust_chnl_id = rcd_efex_cust_chnl.cust_chnl_id,
                   cust_chnl_name = rcd_efex_cust_chnl.cust_chnl_name,
                   cust_chnl_status = rcd_efex_cust_chnl.cust_chnl_status,
                   market_id = rcd_efex_cust_chnl.market_id,
                   valdtn_status = rcd_efex_cust_chnl.valdtn_status
             where cust_type_id = rcd_efex_cust_chnl.cust_type_id;
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

end efxcdw05_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw05_loader for ods_app.efxcdw05_loader;
grant execute on ods_app.efxcdw05_loader to lics_app;
