/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw26_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw26_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex MRQ Data - EFEX to CDW

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

end efxcdw26_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw26_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_com(par_record in varchar2);
   procedure process_record_end(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   rcd_efex_mrq efex_mrq%rowtype;

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
      lics_inbound_utility.set_definition('HDR','MRQ_ID',10);
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','CRT_DATE',14);
      lics_inbound_utility.set_definition('HDR','MRQ_DATE',14);
      lics_inbound_utility.set_definition('HDR','ALT_DATE',14);
      lics_inbound_utility.set_definition('HDR','CON_ID',10);
      lics_inbound_utility.set_definition('HDR','CON_NAME',101);
      lics_inbound_utility.set_definition('HDR','MCH_NAME',50);
      lics_inbound_utility.set_definition('HDR','MCH_TRVMINS',15);
      lics_inbound_utility.set_definition('HDR','MCH_TRVKLMS',15);
      lics_inbound_utility.set_definition('HDR','COM_DATE',14);
      lics_inbound_utility.set_definition('HDR','COM_FLAG',1);
      lics_inbound_utility.set_definition('HDR','SAT_FLAG',1);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      /*-*/
      lics_inbound_utility.set_definition('COM','RCD_ID',3);
      lics_inbound_utility.set_definition('COM','COM_TEXT',2000);
      /*-*/
      lics_inbound_utility.set_definition('END','RCD_ID',3);

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
         when 'COM' then process_record_com(par_record);
         when 'END' then process_record_end(par_record);
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

      rcd_efex_mrq.mrq_id := lics_inbound_utility.get_number('MRQ_ID');
      rcd_efex_mrq.efex_cust_id := lics_inbound_utility.get_number('CUS_ID');
      rcd_efex_mrq.sales_terr_id := lics_inbound_utility.get_number('STE_ID');
      rcd_efex_mrq.sgmnt_id := lics_inbound_utility.get_number('SEG_ID');
      rcd_efex_mrq.bus_unit_id := lics_inbound_utility.get_number('BUS_ID');
      rcd_efex_mrq.user_id := lics_inbound_utility.get_number('USR_ID');
      rcd_efex_mrq.creatn_date := lics_inbound_utility.get_date('CRT_DATE','yyyymmddhh24miss');
      rcd_efex_mrq.mrq_date := lics_inbound_utility.get_date('MRQ_DATE','yyyymmddhh24miss');
      rcd_efex_mrq.alt_date := lics_inbound_utility.get_date('ALT_DATE','yyyymmddhh24miss');
      rcd_efex_mrq.cust_contact_id := lics_inbound_utility.get_number('CON_ID');
      rcd_efex_mrq.cust_contact_name := substr(lics_inbound_utility.get_variable('CON_NAME'),1,100);
      rcd_efex_mrq.merch_name := lics_inbound_utility.get_variable('MCH_NAME');
      rcd_efex_mrq.merch_comnt := null;
      rcd_efex_mrq.merch_travel_time := lics_inbound_utility.get_number('MCH_TRVMINS');
      rcd_efex_mrq.merch_travel_kms := lics_inbound_utility.get_number('MCH_TRVKLMS');
      rcd_efex_mrq.date_completed := lics_inbound_utility.get_date('COM_DATE','yyyymmddhh24miss');
      rcd_efex_mrq.completed_flg := lics_inbound_utility.get_variable('COM_FLAG');
      rcd_efex_mrq.satisfactory_flg := lics_inbound_utility.get_variable('SAT_FLAG');
      rcd_efex_mrq.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_mrq.valdtn_status := ods_constants.valdtn_unchecked;

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

   /**************************************************/
   /* This procedure performs the record COM routine */
   /**************************************************/
   procedure process_record_com(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('COM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_mrq.merch_comnt := rcd_efex_mrq.merch_comnt || lics_inbound_utility.get_variable('COM_TEXT');

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
   end process_record_com;

   /**************************************************/
   /* This procedure performs the record END routine */
   /**************************************************/
   procedure process_record_end(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('END', par_record);

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_mrq values rcd_efex_mrq;
      exception
         when dup_val_on_index then
            update efex_mrq
               set efex_cust_id = rcd_efex_mrq.efex_cust_id,
                   sales_terr_id = rcd_efex_mrq.sales_terr_id,
                   sgmnt_id = rcd_efex_mrq.sgmnt_id,
                   bus_unit_id = rcd_efex_mrq.bus_unit_id,
                   user_id = rcd_efex_mrq.user_id,
                   creatn_date = rcd_efex_mrq.creatn_date,
                   mrq_date = rcd_efex_mrq.mrq_date,
                   alt_date = rcd_efex_mrq.alt_date,
                   cust_contact_id = rcd_efex_mrq.cust_contact_id,
                   cust_contact_name = rcd_efex_mrq.cust_contact_name,
                   merch_name = rcd_efex_mrq.merch_name,
                   merch_comnt = rcd_efex_mrq.merch_comnt,
                   merch_travel_time = rcd_efex_mrq.merch_travel_time,
                   merch_travel_kms = rcd_efex_mrq.merch_travel_kms,
                   date_completed = rcd_efex_mrq.date_completed,
                   completed_flg = rcd_efex_mrq.completed_flg,
                   satisfactory_flg = rcd_efex_mrq.satisfactory_flg,
                   status = rcd_efex_mrq.status,
                   valdtn_status = rcd_efex_mrq.valdtn_status
             where mrq_id = rcd_efex_mrq.mrq_id;
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
   end process_record_end;

end efxcdw26_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw26_loader for ods_app.efxcdw26_loader;
grant execute on ods_app.efxcdw26_loader to lics_app;
