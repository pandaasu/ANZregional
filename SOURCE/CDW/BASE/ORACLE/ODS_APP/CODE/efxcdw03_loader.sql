/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw03_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw03_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex User Data - EFEX to CDW

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

end efxcdw03_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw03_loader as

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
   procedure process_record_seg(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_trn_interface varchar2(32);
   var_trn_market number;
   var_trn_extract varchar2(14);
   rcd_efex_user efex_user%rowtype;
   rcd_efex_user_sgmnt efex_user_sgmnt%rowtype;

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
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','FST_NAME',50);
      lics_inbound_utility.set_definition('HDR','LST_NAME',50);
      lics_inbound_utility.set_definition('HDR','EMA_ADDR',50);
      lics_inbound_utility.set_definition('HDR','PHO_NUMB',50);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      /*-*/
      lics_inbound_utility.set_definition('SEG','RCD_ID',3);
      lics_inbound_utility.set_definition('SEG','USR_ID',10);
      lics_inbound_utility.set_definition('SEG','SEG_ID',10);
      lics_inbound_utility.set_definition('SEG','BUS_ID',10);
      lics_inbound_utility.set_definition('SEG','STATUS',1);

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
         when 'SEG' then process_record_seg(par_record);
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

      rcd_efex_user.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_user.firstname := lics_inbound_utility.get_variable('FST_NAME');
      rcd_efex_user.lastname := lics_inbound_utility.get_variable('LST_NAME');
      rcd_efex_user.email_addr := lics_inbound_utility.get_variable('EMA_ADDR');
      rcd_efex_user.phone_num := lics_inbound_utility.get_variable('PHO_NUMB');
      rcd_efex_user.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_user.valdtn_status := ods_constants.valdtn_valid;
      var_trn_count := var_trn_count + 1;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_user values rcd_efex_user;
      exception
         when dup_val_on_index then
            update efex_user
               set firstname = rcd_efex_user.firstname,
                   lastname = rcd_efex_user.lastname,
                   email_addr = rcd_efex_user.email_addr,
                   phone_num = rcd_efex_user.phone_num,
                   status = rcd_efex_user.status,
                   valdtn_status = rcd_efex_user.valdtn_status
             where user_id = rcd_efex_user.user_id;
      end;

      /*--------------------------------*/
      /* DELETE - Delete any child rows */
      /*--------------------------------*/

      delete from efex_user_sgmnt where user_id = rcd_efex_user.user_id;

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
   /* This procedure performs the record SEG routine */
   /**************************************************/
   procedure process_record_seg(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('SEG', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_user_sgmnt.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_user_sgmnt.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_user_sgmnt.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_user_sgmnt.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_user_sgmnt.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      insert into efex_user_sgmnt values rcd_efex_user_sgmnt;

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
   end process_record_seg;

end efxcdw03_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw03_loader for ods_app.efxcdw03_loader;
grant execute on ods_app.efxcdw03_loader to lics_app;
