/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw18_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw18_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Assessment Assignment Data - EFEX to CDW

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

end efxcdw18_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw18_loader as

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
   rcd_efex_assmnt_assgnmnt efex_assmnt_assgnmnt%rowtype;

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
      lics_inbound_utility.set_definition('HDR','COM_ID',10);
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','CTY_ID',10);
      lics_inbound_utility.set_definition('HDR','AFF_ID',10);
      lics_inbound_utility.set_definition('HDR','SRE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','STATUS',1);

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

      rcd_efex_assmnt_assgnmnt.assmnt_id := lics_inbound_utility.get_number('COM_ID');
      rcd_efex_assmnt_assgnmnt.efex_cust_id := lics_inbound_utility.get_number('CUS_ID');
      rcd_efex_assmnt_assgnmnt.cust_type_id := lics_inbound_utility.get_number('CTY_ID');
      rcd_efex_assmnt_assgnmnt.affltn_id := lics_inbound_utility.get_number('AFF_ID');
      rcd_efex_assmnt_assgnmnt.sales_regn_id := lics_inbound_utility.get_number('SRE_ID');
      rcd_efex_assmnt_assgnmnt.sgmnt_id := lics_inbound_utility.get_number('SEG_ID');
      rcd_efex_assmnt_assgnmnt.sales_terr_id := lics_inbound_utility.get_number('STE_ID');
      rcd_efex_assmnt_assgnmnt.bus_unit_id := lics_inbound_utility.get_number('BUS_ID');
      rcd_efex_assmnt_assgnmnt.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_assmnt_assgnmnt.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_assmnt_assgnmnt values rcd_efex_assmnt_assgnmnt;
      exception
         when dup_val_on_index then
            update efex_assmnt_assgnmnt
               set cust_type_id = rcd_efex_assmnt_assgnmnt.cust_type_id,
                   affltn_id = rcd_efex_assmnt_assgnmnt.affltn_id,
                   sales_regn_id = rcd_efex_assmnt_assgnmnt.sales_regn_id,
                   sgmnt_id = rcd_efex_assmnt_assgnmnt.sgmnt_id,
                   sales_terr_id = rcd_efex_assmnt_assgnmnt.sales_terr_id,
                   bus_unit_id = rcd_efex_assmnt_assgnmnt.bus_unit_id,
                   status = rcd_efex_assmnt_assgnmnt.status,
                   valdtn_status = rcd_efex_assmnt_assgnmnt.valdtn_status
             where assmnt_id = rcd_efex_assmnt_assgnmnt.assmnt_id
               and efex_cust_id = rcd_efex_assmnt_assgnmnt.efex_cust_id;
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

end efxcdw18_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw18_loader for ods_app.efxcdw18_loader;
grant execute on ods_app.efxcdw18_loader to lics_app;
