/******************/
/* Package Header */
/******************/
create or replace package vds_sapvds01 as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_sapvds01
 Owner   : vds_app
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - sapvds01 - Inbound SAP Validation Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Steve Gregan   Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end vds_sapvds01;
/

/****************/
/* Package Body */
/****************/
create or replace package body vds_sapvds01 as

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
   procedure process_record_tab(par_record in varchar2);
   procedure process_record_fld(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_interface vds_interface.vin_interface%type;
   var_timestamp vds_query.vqu_meta_time%type;
   rcd_vds_query vds_query%rowtype;
   rcd_vds_meta vds_meta%rowtype;
   rcd_vds_data vds_data%rowtype;

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
      lics_inbound_utility.set_definition('CTL','VDS_CTL',3);
      lics_inbound_utility.set_definition('CTL','VDS_INTERFACE',30);
      lics_inbound_utility.set_definition('CTL','VDS_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','VDS_DATE',8);
      lics_inbound_utility.set_definition('CTL','VDS_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('TAB','VDS_TAB',3);
      lics_inbound_utility.set_definition('TAB','VDS_QUERY',30);
      /*-*/
      lics_inbound_utility.set_definition('FLD','VDS_FLD',3);
      lics_inbound_utility.set_definition('FLD','VDS_TABLE',30);
      lics_inbound_utility.set_definition('FLD','VDS_COLUMN',30);
      lics_inbound_utility.set_definition('FLD','VDS_TYPE',10);
      lics_inbound_utility.set_definition('FLD','VDS_OFFSET',9);
      lics_inbound_utility.set_definition('FLD','VDS_LENGTH',9);
      /*-*/
      lics_inbound_utility.set_definition('DAT','VDS_DAT',3);
      lics_inbound_utility.set_definition('DAT','VDS_TABLE',30);
      lics_inbound_utility.set_definition('DAT','VDS_DATA',2048);

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
         when 'TAB' then process_record_tab(par_record);
         when 'FLD' then process_record_fld(par_record);
         when 'DAT' then process_record_dat(par_record);
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

      /*-*/
      /* Local definitions
      /*-*/
      var_accepted boolean;

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
      /* Execute the interface monitor/flattening when required
      /*-*/
      if var_trn_ignore = true then

         /*-*/
         /* Set the transaction accepted indicator and rollback the transaction
         /* **note** - releases transaction lock
         /*-*/
         var_accepted := true;
         rollback;

      elsif var_trn_error = true then

         /*-*/
         /* Set the transaction accepted indicator and rollback the transaction
         /* **note** - releases transaction lock
         /*-*/
         var_accepted := false;
         rollback;

      else

         /*-*/
         /* Set the transaction accepted indicator
         /*-*/
         var_accepted := true;

         /*-*/
         /* Commit the transaction and successful object code
         /* **note** - releases transaction lock
         /*-*/
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

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('CTL', par_record);

      /*-*/
      /* Extract and validate the control name
      /*-*/
      var_interface := lics_inbound_utility.get_variable('VDS_INTERFACE');
      if var_interface is null then
         lics_inbound_utility.add_exception('Field - CTL.INTERFACE - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control timestamp
      /*-*/
      var_timestamp := lics_inbound_utility.get_variable('VDS_DATE') || lics_inbound_utility.get_variable('VDS_TIME');
      if var_timestamp is null then
         lics_inbound_utility.add_exception('Field - CTL.VDS_TIMESTAMP - Must not be null');
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record TAB routine */
   /**************************************************/
   procedure process_record_tab(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_meta_time vds_query.vqu_meta_time%type;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('TAB', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_vds_query.vqu_query := upper(lics_inbound_utility.get_variable('VDS_QUERY'));
      rcd_vds_query.vqu_meta_ifac := var_interface;
      rcd_vds_query.vqu_meta_time := var_timestamp;
      rcd_vds_query.vqu_meta_date := sysdate;
      rcd_vds_query.vqu_data_ifac := var_interface;
      rcd_vds_query.vqu_data_time := var_timestamp;
      rcd_vds_query.vqu_data_date := sysdate;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_vds_meta.vme_row := 0;
      rcd_vds_data.vda_row := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_vds_query.vqu_query is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TAB.QUERY');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/

      if var_trn_error = true then
         return;
      end if;

      /*----------------------------------------*/
      /* LOCK- Lock the interface transaction   */
      /*----------------------------------------*/

      /*-*/
      /* Lock the transaction
      /* **note** - attempt to lock the transaction header row (oracle default wait behaviour)
      /*              - insert/insert (not exists) - first holds lock and second fails on first commit with duplicate index
      /*              - update/update (exists) - logic goes to update and default wait behaviour
      /*          - validate the transaction sequence when locking row exists
      /*          - lock and commit cycle encompasses transaction child procedure execution
      /*-*/
      begin
         insert into vds_query
            (vqu_query,
             vqu_meta_ifac,
             vqu_meta_time,
             vqu_meta_date,
             vqu_data_ifac,
             vqu_data_time,
             vqu_data_date)
         values
            (rcd_vds_query.vqu_query,
             rcd_vds_query.vqu_meta_ifac,
             rcd_vds_query.vqu_meta_time,
             rcd_vds_query.vqu_meta_date,
             rcd_vds_query.vqu_data_ifac,
             rcd_vds_query.vqu_data_time,
             rcd_vds_query.vqu_data_date);
      exception
         when dup_val_on_index then
            update vds_query
               set vqu_meta_ifac = vqu_meta_ifac
             where vqu_query = rcd_vds_query.vqu_query;
            if sql%notfound then
               var_trn_ignore := true;
            end if;
      end;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      update vds_query set
         vqu_meta_ifac = rcd_vds_query.vqu_meta_ifac,
         vqu_meta_time = rcd_vds_query.vqu_meta_time,
         vqu_meta_date = rcd_vds_query.vqu_meta_date,
         vqu_data_ifac = rcd_vds_query.vqu_data_ifac,
         vqu_data_time = rcd_vds_query.vqu_data_time,
         vqu_data_date = rcd_vds_query.vqu_data_date
      where vqu_query = rcd_vds_query.vqu_query;

      delete from vds_meta
       where vme_query = rcd_vds_query.vqu_query;

      delete from vds_data
       where vda_query = rcd_vds_query.vqu_query;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tab;

   /**************************************************/
   /* This procedure performs the record FLD routine */
   /**************************************************/
   procedure process_record_fld(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('FLD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_vds_meta.vme_query := rcd_vds_query.vqu_query;
      rcd_vds_meta.vme_row := rcd_vds_meta.vme_row + 1;
      rcd_vds_meta.vme_table := upper(lics_inbound_utility.get_variable('VDS_TABLE'));
      rcd_vds_meta.vme_column := upper(lics_inbound_utility.get_variable('VDS_COLUMN'));
      rcd_vds_meta.vme_type := lics_inbound_utility.get_variable('VDS_TYPE');
      rcd_vds_meta.vme_offset := lics_inbound_utility.get_number('VDS_OFFSET',null);
      rcd_vds_meta.vme_length := lics_inbound_utility.get_number('VDS_LENGTH',null);

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
      if rcd_vds_meta.vme_query is null then
         lics_inbound_utility.add_exception('Missing Primary Key - FLD.QUERY');
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

      insert into vds_meta
         (vme_query,
          vme_row,
          vme_table,
          vme_column,
          vme_type,
          vme_offset,
          vme_length)
      values
         (rcd_vds_meta.vme_query,
          rcd_vds_meta.vme_row,
          rcd_vds_meta.vme_table,
          rcd_vds_meta.vme_column,
          rcd_vds_meta.vme_type,
          rcd_vds_meta.vme_offset,
          rcd_vds_meta.vme_length);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_fld;

   /**************************************************/
   /* This procedure performs the record DAT routine */
   /**************************************************/
   procedure process_record_dat(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DAT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_vds_data.vda_query := rcd_vds_query.vqu_query;
      rcd_vds_data.vda_row := rcd_vds_data.vda_row + 1;
      rcd_vds_data.vda_table := upper(lics_inbound_utility.get_variable('VDS_TABLE'));
      rcd_vds_data.vda_data := lics_inbound_utility.get_variable('VDS_DATA');

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
      if rcd_vds_data.vda_query is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAT.QUERY');
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

      insert into vds_data
         (vda_query,
          vda_row,
          vda_table,
          vda_data)
      values
         (rcd_vds_data.vda_query,
          rcd_vds_data.vda_row,
          rcd_vds_data.vda_table,
          rcd_vds_data.vda_data);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

end vds_sapvds01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym vds_sapvds01 for vds_app.vds_sapvds01;
grant execute on vds_sapvds01 to public;
