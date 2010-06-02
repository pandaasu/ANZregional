/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw13_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw13_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Route Plan Data - EFEX to CDW

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end efxcdw13_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw13_loader as

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
   rcd_efex_route_plan efex_route_plan%rowtype;

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
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','RPL_DATE',14);
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','RPL_ORDER',15);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
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

      rcd_efex_route_plan.user_id := lics_inbound_utility.get_number('USR_ID');
      rcd_efex_route_plan.route_plan_date := lics_inbound_utility.get_date('RPL_DATE','yyyymmddhh24miss');
      rcd_efex_route_plan.efex_cust_id := lics_inbound_utility.get_number('CUS_ID');
      rcd_efex_route_plan.route_plan_order := lics_inbound_utility.get_number('RPL_ORDER');
      rcd_efex_route_plan.sales_terr_id := lics_inbound_utility.get_number('STE_ID');
      rcd_efex_route_plan.sgmnt_id := lics_inbound_utility.get_number('SEG_ID');
      rcd_efex_route_plan.bus_unit_id := lics_inbound_utility.get_number('BUS_ID');
      rcd_efex_route_plan.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_route_plan.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_route_plan values rcd_efex_route_plan;
      exception
         when dup_val_on_index then
            update efex_route_plan
               set route_plan_order = rcd_efex_route_plan.route_plan_order,
                   sales_terr_id = rcd_efex_route_plan.sales_terr_id,
                   sgmnt_id = rcd_efex_route_plan.sgmnt_id,
                   bus_unit_id = rcd_efex_route_plan.bus_unit_id,
                   status = rcd_efex_route_plan.status,
                   valdtn_status = rcd_efex_route_plan.valdtn_status
             where user_id = rcd_efex_route_plan.user_id
               and route_plan_date = rcd_efex_route_plan.route_plan_date
               and efex_cust_id = rcd_efex_route_plan.efex_cust_id;
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

end efxcdw13_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw13_loader for ods_app.efxcdw13_loader;
grant execute on ods_app.efxcdw13_loader to lics_app;
