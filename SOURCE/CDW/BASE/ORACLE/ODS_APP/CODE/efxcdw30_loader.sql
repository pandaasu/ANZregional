/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw30_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw30_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Customer Note - EFEX to CDW

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

end efxcdw30_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw30_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_nte(par_record in varchar2);
   procedure process_record_end(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   rcd_efex_cust_note efex_cust_note%rowtype;

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
      lics_inbound_utility.set_definition('HDR','NTE_ID',10);
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','NTE_TITLE',50);
      lics_inbound_utility.set_definition('HDR','NTE_AUTHOR',10);
      lics_inbound_utility.set_definition('HDR','NTE_CREATED',50);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      /*-*/
      lics_inbound_utility.set_definition('NTE','RCD_ID',3);
      lics_inbound_utility.set_definition('NTE','NTE_TEXT',2000);
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
         when 'NTE' then process_record_nte(par_record);
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

      rcd_efex_cust_note.cust_note_id := lics_inbound_utility.get_number('NTE_ID',null);
      rcd_efex_cust_note.efex_cust_id := lics_inbound_utility.get_number('CUS_ID',null);
      rcd_efex_cust_note.sales_terr_id := lics_inbound_utility.get_number('STE_ID',null);
      rcd_efex_cust_note.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_cust_note.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_cust_note.cust_note_title := lics_inbound_utility.get_variable('NTE_TITLE');
      rcd_efex_cust_note.cust_note_body := null;
      rcd_efex_cust_note.cust_note_author := lics_inbound_utility.get_variable('NTE_AUTHOR');
      rcd_efex_cust_note.cust_note_created := lics_inbound_utility.get_variable('NTE_CREATED');
      rcd_efex_cust_note.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_cust_note.valdtn_status := ods_constants.valdtn_unchecked;

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
   /* This procedure performs the record NTE routine */
   /**************************************************/
   procedure process_record_nte(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('NTE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_cust_note.cust_note_body := rcd_efex_cust_note.cust_note_body || lics_inbound_utility.get_variable('NTE_TEXT');

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
   end process_record_nte;

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
         insert into efex_cust_note values rcd_efex_cust_note;
      exception
         when dup_val_on_index then
            update efex_cust_note
               set efex_cust_id = rcd_efex_cust_note.efex_cust_id,
                   sales_terr_id = rcd_efex_cust_note.sales_terr_id,
                   sgmnt_id = rcd_efex_cust_note.sgmnt_id,
                   bus_unit_id = rcd_efex_cust_note.bus_unit_id,
                   cust_note_title = rcd_efex_cust_note.cust_note_title,
                   cust_note_body = rcd_efex_cust_note.cust_note_body,
                   cust_note_author = rcd_efex_cust_note.cust_note_author,
                   cust_note_created = rcd_efex_cust_note.cust_note_created,
                   status = rcd_efex_cust_note.status,
                   valdtn_status = rcd_efex_cust_note.valdtn_status
             where cust_note_id = rcd_efex_cust_note.cust_note_id;
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

end efxcdw30_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw30_loader for ods_app.efxcdw30_loader;
grant execute on ods_app.efxcdw30_loader to lics_app;
