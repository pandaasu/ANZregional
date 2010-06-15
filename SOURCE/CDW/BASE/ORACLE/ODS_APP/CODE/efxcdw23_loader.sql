/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw23_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw23_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Distribution Total Data - EFEX to CDW

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

end efxcdw23_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw23_loader as

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
   rcd_efex_distbn_tot efex_distbn_tot%rowtype;

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
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','ITG_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','TOT_QTY',15);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
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

      rcd_efex_distbn_tot.efex_cust_id := lics_inbound_utility.get_number('CUS_ID',null);
      rcd_efex_distbn_tot.matl_grp_id := lics_inbound_utility.get_number('ITG_ID',null);
      rcd_efex_distbn_tot.sales_terr_id := lics_inbound_utility.get_number('STE_ID',null);
      rcd_efex_distbn_tot.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_distbn_tot.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_distbn_tot.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_distbn_tot.tot_qty := lics_inbound_utility.get_number('TOT_QTY',null);
      rcd_efex_distbn_tot.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_distbn_tot.efex_lupdt := lics_inbound_utility.get_date('EFX_DATE','yyyymmddhh24miss');
      rcd_efex_distbn_tot.valdtn_status := ods_constants.valdtn_unchecked;
      var_trn_count := var_trn_count + 1;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_distbn_tot values rcd_efex_distbn_tot;
      exception
         when dup_val_on_index then
            update efex_distbn_tot
               set sales_terr_id = rcd_efex_distbn_tot.sales_terr_id,
                   sgmnt_id = rcd_efex_distbn_tot.sgmnt_id,
                   bus_unit_id = rcd_efex_distbn_tot.bus_unit_id,
                   user_id = rcd_efex_distbn_tot.user_id,
                   tot_qty = rcd_efex_distbn_tot.tot_qty,
                   status = rcd_efex_distbn_tot.status,
                   efex_lupdt = rcd_efex_distbn_tot.efex_lupdt,
                   valdtn_status = rcd_efex_distbn_tot.valdtn_status
             where efex_cust_id = rcd_efex_distbn_tot.efex_cust_id
               and matl_grp_id = rcd_efex_distbn_tot.matl_grp_id;
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

end efxcdw23_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw23_loader for ods_app.efxcdw23_loader;
grant execute on ods_app.efxcdw23_loader to lics_app;
