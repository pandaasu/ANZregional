/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw17_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw17_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Assessment Question Data - EFEX to CDW

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

end efxcdw17_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw17_loader as

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
   procedure process_record_txt(par_record in varchar2);
   procedure process_record_end(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_trn_interface varchar2(32);
   var_trn_market number;
   var_trn_extract varchar2(14);
   rcd_efex_assmnt_questn efex_assmnt_questn%rowtype;

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
      lics_inbound_utility.set_definition('HDR','COM_ID',10);
      lics_inbound_utility.set_definition('HDR','COM_TYPE',50);
      lics_inbound_utility.set_definition('HDR','CGR_ID',10);
      lics_inbound_utility.set_definition('HDR','CGR_NAME',50);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','ACT_DATE',14);
      lics_inbound_utility.set_definition('HDR','INA_DATE',14);
      lics_inbound_utility.set_definition('HDR','DUE_DATE',14);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      /*-*/
      lics_inbound_utility.set_definition('TXT','RCD_ID',3);
      lics_inbound_utility.set_definition('TXT','COM_TEXT',2000);
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
         when 'CTL' then process_record_ctl(par_record);
         when 'HDR' then process_record_hdr(par_record);
         when 'TXT' then process_record_txt(par_record);
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

      rcd_efex_assmnt_questn.assmnt_id := lics_inbound_utility.get_number('COM_ID',null);
      rcd_efex_assmnt_questn.assmnt_questn := null;
      rcd_efex_assmnt_questn.questn_type := lics_inbound_utility.get_variable('COM_TYPE');
      rcd_efex_assmnt_questn.efex_grp_id := lics_inbound_utility.get_number('CGR_ID',null);
      rcd_efex_assmnt_questn.questn_grp := lics_inbound_utility.get_variable('CGR_NAME');
      rcd_efex_assmnt_questn.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_assmnt_questn.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_assmnt_questn.active_date := lics_inbound_utility.get_date('ACT_DATE','yyyymmddhh24miss');
      rcd_efex_assmnt_questn.inactive_date := lics_inbound_utility.get_date('INA_DATE','yyyymmddhh24miss');
      rcd_efex_assmnt_questn.due_date := lics_inbound_utility.get_date('DUE_DATE','yyyymmddhh24miss');
      rcd_efex_assmnt_questn.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_assmnt_questn.valdtn_status := ods_constants.valdtn_unchecked;
      var_trn_count := var_trn_count + 1;

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
   /* This procedure performs the record TXT routine */
   /**************************************************/
   procedure process_record_txt(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('TXT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_assmnt_questn.assmnt_questn := rcd_efex_assmnt_questn.assmnt_questn || lics_inbound_utility.get_variable('COM_TEXT');

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
   end process_record_txt;

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
         insert into efex_assmnt_questn values rcd_efex_assmnt_questn;
      exception
         when dup_val_on_index then
            update efex_assmnt_questn
               set assmnt_questn = rcd_efex_assmnt_questn.assmnt_questn,
                   questn_type = rcd_efex_assmnt_questn.questn_type,
                   efex_grp_id = rcd_efex_assmnt_questn.efex_grp_id,
                   questn_grp = rcd_efex_assmnt_questn.questn_grp,
                   sgmnt_id = rcd_efex_assmnt_questn.sgmnt_id,
                   bus_unit_id = rcd_efex_assmnt_questn.bus_unit_id,
                   active_date = rcd_efex_assmnt_questn.active_date,
                   inactive_date = rcd_efex_assmnt_questn.inactive_date,
                   due_date = rcd_efex_assmnt_questn.due_date,
                   status = rcd_efex_assmnt_questn.status,
                   valdtn_status = rcd_efex_assmnt_questn.valdtn_status
             where assmnt_id = rcd_efex_assmnt_questn.assmnt_id;
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

end efxcdw17_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw17_loader for ods_app.efxcdw17_loader;
grant execute on ods_app.efxcdw17_loader to lics_app;
