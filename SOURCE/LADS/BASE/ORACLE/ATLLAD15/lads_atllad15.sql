/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad15
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad15 - Inbound Address Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad15 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad15;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad15 as

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
   procedure process_record_det(par_record in varchar2);
   procedure process_record_tel(par_record in varchar2);
   procedure process_record_fax(par_record in varchar2);
   procedure process_record_ema(par_record in varchar2);
   procedure process_record_url(par_record in varchar2);
   procedure process_record_com(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_adr_hdr lads_adr_hdr%rowtype;
   rcd_lads_adr_det lads_adr_det%rowtype;
   rcd_lads_adr_tel lads_adr_tel%rowtype;
   rcd_lads_adr_fax lads_adr_fax%rowtype;
   rcd_lads_adr_ema lads_adr_ema%rowtype;
   rcd_lads_adr_url lads_adr_url%rowtype;
   rcd_lads_adr_com lads_adr_com%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IDOC_CTL',3);
      lics_inbound_utility.set_definition('CTL','IDOC_NAME',30);
      lics_inbound_utility.set_definition('CTL','IDOC_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      lics_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','OBJ_TYPE',10);
      lics_inbound_utility.set_definition('HDR','OBJ_ID',70);
      lics_inbound_utility.set_definition('HDR','OBJ_ID_EXT',70);
      lics_inbound_utility.set_definition('HDR','CONTEXT',4);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','ADDR_VERS',1);
      lics_inbound_utility.set_definition('DET','FROM_DATE',8);
      lics_inbound_utility.set_definition('DET','TO_DATE',8);
      lics_inbound_utility.set_definition('DET','TITLE',4);
      lics_inbound_utility.set_definition('DET','NAME',40);
      lics_inbound_utility.set_definition('DET','NAME_2',40);
      lics_inbound_utility.set_definition('DET','NAME_3',40);
      lics_inbound_utility.set_definition('DET','NAME_4',40);
      lics_inbound_utility.set_definition('DET','CONV_NAME',50);
      lics_inbound_utility.set_definition('DET','C_O_NAME',40);
      lics_inbound_utility.set_definition('DET','CITY',40);
      lics_inbound_utility.set_definition('DET','DISTRICT',40);
      lics_inbound_utility.set_definition('DET','CITY_NO',12);
      lics_inbound_utility.set_definition('DET','DISTRCT_NO',8);
      lics_inbound_utility.set_definition('DET','CHCKSTATUS',1);
      lics_inbound_utility.set_definition('DET','REGIOGROUP',8);
      lics_inbound_utility.set_definition('DET','POSTL_COD1',10);
      lics_inbound_utility.set_definition('DET','POSTL_COD2',10);
      lics_inbound_utility.set_definition('DET','POSTL_COD3',10);
      lics_inbound_utility.set_definition('DET','PCODE1_EXT',10);
      lics_inbound_utility.set_definition('DET','PCODE2_EXT',10);
      lics_inbound_utility.set_definition('DET','PCODE3_EXT',10);
      lics_inbound_utility.set_definition('DET','PO_BOX',10);
      lics_inbound_utility.set_definition('DET','PO_W_O_NO',1);
      lics_inbound_utility.set_definition('DET','PO_BOX_CIT',40);
      lics_inbound_utility.set_definition('DET','PBOXCIT_NO',12);
      lics_inbound_utility.set_definition('DET','PO_BOX_REG',3);
      lics_inbound_utility.set_definition('DET','POBOX_CTRY',3);
      lics_inbound_utility.set_definition('DET','PO_CTRYISO',2);
      lics_inbound_utility.set_definition('DET','DELIV_DIS',15);
      lics_inbound_utility.set_definition('DET','TRANSPZONE',10);
      lics_inbound_utility.set_definition('DET','STREET',60);
      lics_inbound_utility.set_definition('DET','STREET_NO',12);
      lics_inbound_utility.set_definition('DET','STR_ABBR',2);
      lics_inbound_utility.set_definition('DET','HOUSE_NO',10);
      lics_inbound_utility.set_definition('DET','HOUSE_NO2',10);
      lics_inbound_utility.set_definition('DET','HOUSE_NO3',10);
      lics_inbound_utility.set_definition('DET','STR_SUPPL1',40);
      lics_inbound_utility.set_definition('DET','STR_SUPPL2',40);
      lics_inbound_utility.set_definition('DET','STR_SUPPL3',40);
      lics_inbound_utility.set_definition('DET','LOCATION',40);
      lics_inbound_utility.set_definition('DET','BUILDING',20);
      lics_inbound_utility.set_definition('DET','FLOOR',10);
      lics_inbound_utility.set_definition('DET','ROOM_NO',10);
      lics_inbound_utility.set_definition('DET','COUNTRY',3);
      lics_inbound_utility.set_definition('DET','COUNTRYISO',2);
      lics_inbound_utility.set_definition('DET','LANGU',1);
      lics_inbound_utility.set_definition('DET','LANGU_ISO',2);
      lics_inbound_utility.set_definition('DET','REGION',3);
      lics_inbound_utility.set_definition('DET','SORT1',20);
      lics_inbound_utility.set_definition('DET','SORT2',20);
      lics_inbound_utility.set_definition('DET','EXTENS_1',40);
      lics_inbound_utility.set_definition('DET','EXTENS_2',40);
      lics_inbound_utility.set_definition('DET','TIME_ZONE',6);
      lics_inbound_utility.set_definition('DET','TAXJURCODE',15);
      lics_inbound_utility.set_definition('DET','ADDRESS_ID',10);
      lics_inbound_utility.set_definition('DET','LANGU_CR',1);
      lics_inbound_utility.set_definition('DET','LANGUCRISO',2);
      lics_inbound_utility.set_definition('DET','COMM_TYPE',3);
      lics_inbound_utility.set_definition('DET','ADDR_GROUP',4);
      lics_inbound_utility.set_definition('DET','HOME_CITY',40);
      lics_inbound_utility.set_definition('DET','HOMECITYNO',12);
      lics_inbound_utility.set_definition('DET','DONT_USE_S',4);
      lics_inbound_utility.set_definition('DET','DONT_USE_P',4);
      /*-*/
      lics_inbound_utility.set_definition('TEL','IDOC_TEL',3);
      lics_inbound_utility.set_definition('TEL','COUNTRY',3);
      lics_inbound_utility.set_definition('TEL','COUNTRYISO',2);
      lics_inbound_utility.set_definition('TEL','STD_NO',1);
      lics_inbound_utility.set_definition('TEL','TELEPHONE',30);
      lics_inbound_utility.set_definition('TEL','EXTENSION',10);
      lics_inbound_utility.set_definition('TEL','TEL_NO',30);
      lics_inbound_utility.set_definition('TEL','CALLER_NO',30);
      lics_inbound_utility.set_definition('TEL','STD_RECIP',1);
      lics_inbound_utility.set_definition('TEL','R_3_USER',1);
      lics_inbound_utility.set_definition('TEL','HOME_FLAG',1);
      lics_inbound_utility.set_definition('TEL','CONSNUMBER',3);
      lics_inbound_utility.set_definition('TEL','ERRORFLAG',1);
      lics_inbound_utility.set_definition('TEL','FLG_NOUSE',1);
      /*-*/
      lics_inbound_utility.set_definition('FAX','IDOC_FAX',3);
      lics_inbound_utility.set_definition('FAX','COUNTRY',3);
      lics_inbound_utility.set_definition('FAX','COUNTRYISO',2);
      lics_inbound_utility.set_definition('FAX','STD_NO',1);
      lics_inbound_utility.set_definition('FAX','FAX',30);
      lics_inbound_utility.set_definition('FAX','EXTENSION',10);
      lics_inbound_utility.set_definition('FAX','FAX_NO',30);
      lics_inbound_utility.set_definition('FAX','SENDER_NO',30);
      lics_inbound_utility.set_definition('FAX','FAX_GROUP',1);
      lics_inbound_utility.set_definition('FAX','STD_RECIP',1);
      lics_inbound_utility.set_definition('FAX','R_3_USER',1);
      lics_inbound_utility.set_definition('FAX','HOME_FLAG',1);
      lics_inbound_utility.set_definition('FAX','CONSNUMBER',3);
      lics_inbound_utility.set_definition('FAX','ERRORFLAG',1);
      lics_inbound_utility.set_definition('FAX','FLG_NOUSE',1);
      /*-*/
      lics_inbound_utility.set_definition('EMA','IDOC_EMA',3);
      lics_inbound_utility.set_definition('EMA','STD_NO',1);
      lics_inbound_utility.set_definition('EMA','E_MAIL',241);
      lics_inbound_utility.set_definition('EMA','EMAIL_SRCH',20);
      lics_inbound_utility.set_definition('EMA','STD_RECIP',1);
      lics_inbound_utility.set_definition('EMA','R_3_USER',1);
      lics_inbound_utility.set_definition('EMA','ENCODE',1);
      lics_inbound_utility.set_definition('EMA','TNEF',1);
      lics_inbound_utility.set_definition('EMA','HOME_FLAG',1);
      lics_inbound_utility.set_definition('EMA','CONSNUMBER',3);
      lics_inbound_utility.set_definition('EMA','ERRORFLAG',1);
      lics_inbound_utility.set_definition('EMA','FLG_NOUSE',1);
      /*-*/
      lics_inbound_utility.set_definition('URL','IDOC_URL',3);
      lics_inbound_utility.set_definition('URL','STD_NO',1);
      lics_inbound_utility.set_definition('URL','URI_TYPE',3);
      lics_inbound_utility.set_definition('URL','URI',132);
      lics_inbound_utility.set_definition('URL','STD_RECIP',1);
      lics_inbound_utility.set_definition('URL','HOME_FLAG',1);
      lics_inbound_utility.set_definition('URL','CONSNUMBER',3);
      lics_inbound_utility.set_definition('URL','URI_PART1',250);
      lics_inbound_utility.set_definition('URL','URI_PART2',250);
      lics_inbound_utility.set_definition('URL','URI_PART3',250);
      lics_inbound_utility.set_definition('URL','URI_PART4',250);
      lics_inbound_utility.set_definition('URL','URI_PART5',250);
      lics_inbound_utility.set_definition('URL','URI_PART6',250);
      lics_inbound_utility.set_definition('URL','URI_PART7',250);
      lics_inbound_utility.set_definition('URL','URI_PART8',250);
      lics_inbound_utility.set_definition('URL','URI_PART9',48);
      lics_inbound_utility.set_definition('URL','ERRORFLAG',1);
      lics_inbound_utility.set_definition('URL','FLG_NOUSE',1);
      /*-*/
      lics_inbound_utility.set_definition('COM','IDOC_COM',3);
      lics_inbound_utility.set_definition('COM','ADDR_VERS',1);
      lics_inbound_utility.set_definition('COM','LANGU',1);
      lics_inbound_utility.set_definition('COM','LANGU_ISO',2);
      lics_inbound_utility.set_definition('COM','ADR_NOTES',50);
      lics_inbound_utility.set_definition('COM','ERRORFLAG',1);

      /*-*/
      /* Start the IDOC acknowledgement
      /*-*/
      ics_cisatl16.start_acknowledgement;

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
         when 'DET' then process_record_det(par_record);
         when 'TEL' then process_record_tel(par_record);
         when 'FAX' then process_record_fax(par_record);
         when 'EMA' then process_record_ema(par_record);
         when 'URL' then process_record_url(par_record);
         when 'COM' then process_record_com(par_record);
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

      /*-*/
      /* End the IDOC acknowledgement
      /*-*/
      ics_cisatl16.end_acknowledgement;

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
      con_ack_group constant varchar2(32) := 'LADS_IDOC_ACK';
      con_ack_code constant varchar2(32) := 'ATLLAD15';
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
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
         commit;
         begin
            lads_atllad15_monitor.execute(rcd_lads_adr_hdr.obj_type, rcd_lads_adr_hdr.obj_id, rcd_lads_adr_hdr.context);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
      end if;

      /*-*/
      /* Add the IDOC acknowledgement
      /*-*/
      if upper(lics_setting_configuration.retrieve_setting(con_ack_group, con_ack_code)) = 'Y' then
         if var_accepted = false then
            ics_cisatl16.add_document(to_char(rcd_lads_control.idoc_number,'FM0000000000000000'),
                                      to_char(sysdate,'YYYYMMDD'),
                                      to_char(sysdate,'HH24MISS'),
                                      '40');
         else
            ics_cisatl16.add_document(to_char(rcd_lads_control.idoc_number,'FM0000000000000000'),
                                      to_char(sysdate,'YYYYMMDD'),
                                      to_char(sysdate,'HH24MISS'),
                                      '41');
         end if;
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
      /* Extract and validate the control IDOC name
      /*-*/
      rcd_lads_control.idoc_name := lics_inbound_utility.get_variable('IDOC_NAME');
      if rcd_lads_control.idoc_name is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NAME - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC number
      /*-*/
      rcd_lads_control.idoc_number := lics_inbound_utility.get_number('IDOC_NUMBER','9999999999999999');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if rcd_lads_control.idoc_number is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NUMBER - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC timestamp
      /*-*/
      rcd_lads_control.idoc_timestamp := lics_inbound_utility.get_variable('IDOC_DATE') || lics_inbound_utility.get_variable('IDOC_TIME');
      if rcd_lads_control.idoc_timestamp is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_TIMESTAMP - Must not be null');
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_adr_hdr_01 is
         select
            t01.obj_type,
            t01.obj_id,
            t01.context,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_adr_hdr t01
         where t01.obj_type = rcd_lads_adr_hdr.obj_type
           and t01.obj_id = rcd_lads_adr_hdr.obj_id
           and t01.context = rcd_lads_adr_hdr.context;
      rcd_lads_adr_hdr_01 csr_lads_adr_hdr_01%rowtype;

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
      rcd_lads_adr_hdr.obj_type := lics_inbound_utility.get_variable('OBJ_TYPE');
      rcd_lads_adr_hdr.obj_id := lics_inbound_utility.get_variable('OBJ_ID');
      rcd_lads_adr_hdr.obj_id_ext := lics_inbound_utility.get_variable('OBJ_ID_EXT');
      rcd_lads_adr_hdr.context := lics_inbound_utility.get_number('CONTEXT',null);
      rcd_lads_adr_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_adr_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_adr_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_adr_hdr.lads_date := sysdate;
      rcd_lads_adr_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_adr_det.detseq := 0;
      rcd_lads_adr_tel.telseq := 0;
      rcd_lads_adr_fax.faxseq := 0;
      rcd_lads_adr_ema.emaseq := 0;
      rcd_lads_adr_url.urlseq := 0;
      rcd_lads_adr_com.comseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_adr_hdr.obj_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.OBJ_TYPE');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_hdr.obj_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.OBJ_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_hdr.context is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.CONTEXT');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_adr_hdr.obj_type is null) and
         not(rcd_lads_adr_hdr.obj_id is null) and
         not(rcd_lads_adr_hdr.context is null) then
         var_exists := true;
         open csr_lads_adr_hdr_01;
         fetch csr_lads_adr_hdr_01 into rcd_lads_adr_hdr_01;
         if csr_lads_adr_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_adr_hdr_01;
         if var_exists = true then
            if rcd_lads_adr_hdr.idoc_timestamp > rcd_lads_adr_hdr_01.idoc_timestamp then
               delete from lads_adr_com where obj_type = rcd_lads_adr_hdr.obj_type
                                          and obj_id = rcd_lads_adr_hdr.obj_id
                                          and context = rcd_lads_adr_hdr.context;
               delete from lads_adr_url where obj_type = rcd_lads_adr_hdr.obj_type
                                          and obj_id = rcd_lads_adr_hdr.obj_id
                                          and context = rcd_lads_adr_hdr.context;
               delete from lads_adr_ema where obj_type = rcd_lads_adr_hdr.obj_type
                                          and obj_id = rcd_lads_adr_hdr.obj_id
                                          and context = rcd_lads_adr_hdr.context;
               delete from lads_adr_fax where obj_type = rcd_lads_adr_hdr.obj_type
                                          and obj_id = rcd_lads_adr_hdr.obj_id
                                          and context = rcd_lads_adr_hdr.context;
               delete from lads_adr_tel where obj_type = rcd_lads_adr_hdr.obj_type
                                          and obj_id = rcd_lads_adr_hdr.obj_id
                                          and context = rcd_lads_adr_hdr.context;
               delete from lads_adr_det where obj_type = rcd_lads_adr_hdr.obj_type
                                          and obj_id = rcd_lads_adr_hdr.obj_id
                                          and context = rcd_lads_adr_hdr.context;
            else
               var_trn_ignore := true;
            end if;
         end if;
      end if;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
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

      update lads_adr_hdr set
         obj_id_ext = rcd_lads_adr_hdr.obj_id_ext,
         idoc_name = rcd_lads_adr_hdr.idoc_name,
         idoc_number = rcd_lads_adr_hdr.idoc_number,
         idoc_timestamp = rcd_lads_adr_hdr.idoc_timestamp,
         lads_date = rcd_lads_adr_hdr.lads_date,
         lads_status = rcd_lads_adr_hdr.lads_status
      where obj_type = rcd_lads_adr_hdr.obj_type
        and obj_id = rcd_lads_adr_hdr.obj_id
        and context = rcd_lads_adr_hdr.context;
      if sql%notfound then
         insert into lads_adr_hdr
            (obj_type,
             obj_id,
             obj_id_ext,
             context,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_adr_hdr.obj_type,
             rcd_lads_adr_hdr.obj_id,
             rcd_lads_adr_hdr.obj_id_ext,
             rcd_lads_adr_hdr.context,
             rcd_lads_adr_hdr.idoc_name,
             rcd_lads_adr_hdr.idoc_number,
             rcd_lads_adr_hdr.idoc_timestamp,
             rcd_lads_adr_hdr.lads_date,
             rcd_lads_adr_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DET', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_adr_det.obj_type := rcd_lads_adr_hdr.obj_type;
      rcd_lads_adr_det.obj_id := rcd_lads_adr_hdr.obj_id;
      rcd_lads_adr_det.context := rcd_lads_adr_hdr.context;
      rcd_lads_adr_det.detseq := rcd_lads_adr_det.detseq + 1;
      rcd_lads_adr_det.addr_vers := lics_inbound_utility.get_variable('ADDR_VERS');
      rcd_lads_adr_det.from_date := lics_inbound_utility.get_variable('FROM_DATE');
      rcd_lads_adr_det.to_date := lics_inbound_utility.get_variable('TO_DATE');
      rcd_lads_adr_det.title := lics_inbound_utility.get_variable('TITLE');
      rcd_lads_adr_det.name := lics_inbound_utility.get_variable('NAME');
      rcd_lads_adr_det.name_2 := lics_inbound_utility.get_variable('NAME_2');
      rcd_lads_adr_det.name_3 := lics_inbound_utility.get_variable('NAME_3');
      rcd_lads_adr_det.name_4 := lics_inbound_utility.get_variable('NAME_4');
      rcd_lads_adr_det.conv_name := lics_inbound_utility.get_variable('CONV_NAME');
      rcd_lads_adr_det.c_o_name := lics_inbound_utility.get_variable('C_O_NAME');
      rcd_lads_adr_det.city := lics_inbound_utility.get_variable('CITY');
      rcd_lads_adr_det.district := lics_inbound_utility.get_variable('DISTRICT');
      rcd_lads_adr_det.city_no := lics_inbound_utility.get_variable('CITY_NO');
      rcd_lads_adr_det.distrct_no := lics_inbound_utility.get_variable('DISTRCT_NO');
      rcd_lads_adr_det.chckstatus := lics_inbound_utility.get_variable('CHCKSTATUS');
      rcd_lads_adr_det.regiogroup := lics_inbound_utility.get_variable('REGIOGROUP');
      rcd_lads_adr_det.postl_cod1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_lads_adr_det.postl_cod2 := lics_inbound_utility.get_variable('POSTL_COD2');
      rcd_lads_adr_det.postl_cod3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_lads_adr_det.pcode1_ext := lics_inbound_utility.get_variable('PCODE1_EXT');
      rcd_lads_adr_det.pcode2_ext := lics_inbound_utility.get_variable('PCODE2_EXT');
      rcd_lads_adr_det.pcode3_ext := lics_inbound_utility.get_variable('PCODE3_EXT');
      rcd_lads_adr_det.po_box := lics_inbound_utility.get_variable('PO_BOX');
      rcd_lads_adr_det.po_w_o_no := lics_inbound_utility.get_variable('PO_W_O_NO');
      rcd_lads_adr_det.po_box_cit := lics_inbound_utility.get_variable('PO_BOX_CIT');
      rcd_lads_adr_det.pboxcit_no := lics_inbound_utility.get_variable('PBOXCIT_NO');
      rcd_lads_adr_det.po_box_reg := lics_inbound_utility.get_variable('PO_BOX_REG');
      rcd_lads_adr_det.pobox_ctry := lics_inbound_utility.get_variable('POBOX_CTRY');
      rcd_lads_adr_det.po_ctryiso := lics_inbound_utility.get_variable('PO_CTRYISO');
      rcd_lads_adr_det.deliv_dis := lics_inbound_utility.get_variable('DELIV_DIS');
      rcd_lads_adr_det.transpzone := lics_inbound_utility.get_variable('TRANSPZONE');
      rcd_lads_adr_det.street := lics_inbound_utility.get_variable('STREET');
      rcd_lads_adr_det.street_no := lics_inbound_utility.get_variable('STREET_NO');
      rcd_lads_adr_det.str_abbr := lics_inbound_utility.get_variable('STR_ABBR');
      rcd_lads_adr_det.house_no := lics_inbound_utility.get_variable('HOUSE_NO');
      rcd_lads_adr_det.house_no2 := lics_inbound_utility.get_variable('HOUSE_NO2');
      rcd_lads_adr_det.house_no3 := lics_inbound_utility.get_variable('HOUSE_NO3');
      rcd_lads_adr_det.str_suppl1 := lics_inbound_utility.get_variable('STR_SUPPL1');
      rcd_lads_adr_det.str_suppl2 := lics_inbound_utility.get_variable('STR_SUPPL2');
      rcd_lads_adr_det.str_suppl3 := lics_inbound_utility.get_variable('STR_SUPPL3');
      rcd_lads_adr_det.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_adr_det.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_adr_det.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_adr_det.room_no := lics_inbound_utility.get_variable('ROOM_NO');
      rcd_lads_adr_det.country := lics_inbound_utility.get_variable('COUNTRY');
      rcd_lads_adr_det.countryiso := lics_inbound_utility.get_variable('COUNTRYISO');
      rcd_lads_adr_det.langu := lics_inbound_utility.get_variable('LANGU');
      rcd_lads_adr_det.langu_iso := lics_inbound_utility.get_variable('LANGU_ISO');
      rcd_lads_adr_det.region := lics_inbound_utility.get_variable('REGION');
      rcd_lads_adr_det.sort1 := lics_inbound_utility.get_variable('SORT1');
      rcd_lads_adr_det.sort2 := lics_inbound_utility.get_variable('SORT2');
      rcd_lads_adr_det.extens_1 := lics_inbound_utility.get_variable('EXTENS_1');
      rcd_lads_adr_det.extens_2 := lics_inbound_utility.get_variable('EXTENS_2');
      rcd_lads_adr_det.time_zone := lics_inbound_utility.get_variable('TIME_ZONE');
      rcd_lads_adr_det.taxjurcode := lics_inbound_utility.get_variable('TAXJURCODE');
      rcd_lads_adr_det.address_id := lics_inbound_utility.get_variable('ADDRESS_ID');
      rcd_lads_adr_det.langu_cr := lics_inbound_utility.get_variable('LANGU_CR');
      rcd_lads_adr_det.langucriso := lics_inbound_utility.get_variable('LANGUCRISO');
      rcd_lads_adr_det.comm_type := lics_inbound_utility.get_variable('COMM_TYPE');
      rcd_lads_adr_det.addr_group := lics_inbound_utility.get_variable('ADDR_GROUP');
      rcd_lads_adr_det.home_city := lics_inbound_utility.get_variable('HOME_CITY');
      rcd_lads_adr_det.homecityno := lics_inbound_utility.get_variable('HOMECITYNO');
      rcd_lads_adr_det.dont_use_s := lics_inbound_utility.get_variable('DONT_USE_S');
      rcd_lads_adr_det.dont_use_p := lics_inbound_utility.get_variable('DONT_USE_P');

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
      if rcd_lads_adr_det.obj_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.OBJ_TYPE');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_det.obj_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.OBJ_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_det.context is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.CONTEXT');
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

      insert into lads_adr_det
         (obj_type,
          obj_id,
          context,
          detseq,
          addr_vers,
          from_date,
          to_date,
          title,
          name,
          name_2,
          name_3,
          name_4,
          conv_name,
          c_o_name,
          city,
          district,
          city_no,
          distrct_no,
          chckstatus,
          regiogroup,
          postl_cod1,
          postl_cod2,
          postl_cod3,
          pcode1_ext,
          pcode2_ext,
          pcode3_ext,
          po_box,
          po_w_o_no,
          po_box_cit,
          pboxcit_no,
          po_box_reg,
          pobox_ctry,
          po_ctryiso,
          deliv_dis,
          transpzone,
          street,
          street_no,
          str_abbr,
          house_no,
          house_no2,
          house_no3,
          str_suppl1,
          str_suppl2,
          str_suppl3,
          location,
          building,
          floor,
          room_no,
          country,
          countryiso,
          langu,
          langu_iso,
          region,
          sort1,
          sort2,
          extens_1,
          extens_2,
          time_zone,
          taxjurcode,
          address_id,
          langu_cr,
          langucriso,
          comm_type,
          addr_group,
          home_city,
          homecityno,
          dont_use_s,
          dont_use_p)
      values
         (rcd_lads_adr_det.obj_type,
          rcd_lads_adr_det.obj_id,
          rcd_lads_adr_det.context,
          rcd_lads_adr_det.detseq,
          rcd_lads_adr_det.addr_vers,
          rcd_lads_adr_det.from_date,
          rcd_lads_adr_det.to_date,
          rcd_lads_adr_det.title,
          rcd_lads_adr_det.name,
          rcd_lads_adr_det.name_2,
          rcd_lads_adr_det.name_3,
          rcd_lads_adr_det.name_4,
          rcd_lads_adr_det.conv_name,
          rcd_lads_adr_det.c_o_name,
          rcd_lads_adr_det.city,
          rcd_lads_adr_det.district,
          rcd_lads_adr_det.city_no,
          rcd_lads_adr_det.distrct_no,
          rcd_lads_adr_det.chckstatus,
          rcd_lads_adr_det.regiogroup,
          rcd_lads_adr_det.postl_cod1,
          rcd_lads_adr_det.postl_cod2,
          rcd_lads_adr_det.postl_cod3,
          rcd_lads_adr_det.pcode1_ext,
          rcd_lads_adr_det.pcode2_ext,
          rcd_lads_adr_det.pcode3_ext,
          rcd_lads_adr_det.po_box,
          rcd_lads_adr_det.po_w_o_no,
          rcd_lads_adr_det.po_box_cit,
          rcd_lads_adr_det.pboxcit_no,
          rcd_lads_adr_det.po_box_reg,
          rcd_lads_adr_det.pobox_ctry,
          rcd_lads_adr_det.po_ctryiso,
          rcd_lads_adr_det.deliv_dis,
          rcd_lads_adr_det.transpzone,
          rcd_lads_adr_det.street,
          rcd_lads_adr_det.street_no,
          rcd_lads_adr_det.str_abbr,
          rcd_lads_adr_det.house_no,
          rcd_lads_adr_det.house_no2,
          rcd_lads_adr_det.house_no3,
          rcd_lads_adr_det.str_suppl1,
          rcd_lads_adr_det.str_suppl2,
          rcd_lads_adr_det.str_suppl3,
          rcd_lads_adr_det.location,
          rcd_lads_adr_det.building,
          rcd_lads_adr_det.floor,
          rcd_lads_adr_det.room_no,
          rcd_lads_adr_det.country,
          rcd_lads_adr_det.countryiso,
          rcd_lads_adr_det.langu,
          rcd_lads_adr_det.langu_iso,
          rcd_lads_adr_det.region,
          rcd_lads_adr_det.sort1,
          rcd_lads_adr_det.sort2,
          rcd_lads_adr_det.extens_1,
          rcd_lads_adr_det.extens_2,
          rcd_lads_adr_det.time_zone,
          rcd_lads_adr_det.taxjurcode,
          rcd_lads_adr_det.address_id,
          rcd_lads_adr_det.langu_cr,
          rcd_lads_adr_det.langucriso,
          rcd_lads_adr_det.comm_type,
          rcd_lads_adr_det.addr_group,
          rcd_lads_adr_det.home_city,
          rcd_lads_adr_det.homecityno,
          rcd_lads_adr_det.dont_use_s,
          rcd_lads_adr_det.dont_use_p);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record TEL routine */
   /**************************************************/
   procedure process_record_tel(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TEL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_adr_tel.obj_type := rcd_lads_adr_hdr.obj_type;
      rcd_lads_adr_tel.obj_id := rcd_lads_adr_hdr.obj_id;
      rcd_lads_adr_tel.context := rcd_lads_adr_hdr.context;
      rcd_lads_adr_tel.telseq := rcd_lads_adr_tel.telseq + 1;
      rcd_lads_adr_tel.country := lics_inbound_utility.get_variable('COUNTRY');
      rcd_lads_adr_tel.countryiso := lics_inbound_utility.get_variable('COUNTRYISO');
      rcd_lads_adr_tel.std_no := lics_inbound_utility.get_variable('STD_NO');
      rcd_lads_adr_tel.telephone := lics_inbound_utility.get_variable('TELEPHONE');
      rcd_lads_adr_tel.extension := lics_inbound_utility.get_variable('EXTENSION');
      rcd_lads_adr_tel.tel_no := lics_inbound_utility.get_variable('TEL_NO');
      rcd_lads_adr_tel.caller_no := lics_inbound_utility.get_variable('CALLER_NO');
      rcd_lads_adr_tel.std_recip := lics_inbound_utility.get_variable('STD_RECIP');
      rcd_lads_adr_tel.r_3_user := lics_inbound_utility.get_variable('R_3_USER');
      rcd_lads_adr_tel.home_flag := lics_inbound_utility.get_variable('HOME_FLAG');
      rcd_lads_adr_tel.consnumber := lics_inbound_utility.get_number('CONSNUMBER',null);
      rcd_lads_adr_tel.errorflag := lics_inbound_utility.get_variable('ERRORFLAG');
      rcd_lads_adr_tel.flg_nouse := lics_inbound_utility.get_variable('FLG_NOUSE');

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
      if rcd_lads_adr_tel.obj_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TEL.OBJ_TYPE');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_tel.obj_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TEL.OBJ_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_tel.context is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TEL.CONTEXT');
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

      insert into lads_adr_tel
         (obj_type,
          obj_id,
          context,
          telseq,
          country,
          countryiso,
          std_no,
          telephone,
          extension,
          tel_no,
          caller_no,
          std_recip,
          r_3_user,
          home_flag,
          consnumber,
          errorflag,
          flg_nouse)
      values
         (rcd_lads_adr_tel.obj_type,
          rcd_lads_adr_tel.obj_id,
          rcd_lads_adr_tel.context,
          rcd_lads_adr_tel.telseq,
          rcd_lads_adr_tel.country,
          rcd_lads_adr_tel.countryiso,
          rcd_lads_adr_tel.std_no,
          rcd_lads_adr_tel.telephone,
          rcd_lads_adr_tel.extension,
          rcd_lads_adr_tel.tel_no,
          rcd_lads_adr_tel.caller_no,
          rcd_lads_adr_tel.std_recip,
          rcd_lads_adr_tel.r_3_user,
          rcd_lads_adr_tel.home_flag,
          rcd_lads_adr_tel.consnumber,
          rcd_lads_adr_tel.errorflag,
          rcd_lads_adr_tel.flg_nouse);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tel;

   /**************************************************/
   /* This procedure performs the record FAX routine */
   /**************************************************/
   procedure process_record_fax(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('FAX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_adr_fax.obj_type := rcd_lads_adr_hdr.obj_type;
      rcd_lads_adr_fax.obj_id := rcd_lads_adr_hdr.obj_id;
      rcd_lads_adr_fax.context := rcd_lads_adr_hdr.context;
      rcd_lads_adr_fax.faxseq := rcd_lads_adr_fax.faxseq + 1;
      rcd_lads_adr_fax.country := lics_inbound_utility.get_variable('COUNTRY');
      rcd_lads_adr_fax.countryiso := lics_inbound_utility.get_variable('COUNTRYISO');
      rcd_lads_adr_fax.std_no := lics_inbound_utility.get_variable('STD_NO');
      rcd_lads_adr_fax.fax := lics_inbound_utility.get_variable('FAX');
      rcd_lads_adr_fax.extension := lics_inbound_utility.get_variable('EXTENSION');
      rcd_lads_adr_fax.fax_no := lics_inbound_utility.get_variable('FAX_NO');
      rcd_lads_adr_fax.sender_no := lics_inbound_utility.get_variable('SENDER_NO');
      rcd_lads_adr_fax.fax_group := lics_inbound_utility.get_variable('FAX_GROUP');
      rcd_lads_adr_fax.std_recip := lics_inbound_utility.get_variable('STD_RECIP');
      rcd_lads_adr_fax.r_3_user := lics_inbound_utility.get_variable('R_3_USER');
      rcd_lads_adr_fax.home_flag := lics_inbound_utility.get_variable('HOME_FLAG');
      rcd_lads_adr_fax.consnumber := lics_inbound_utility.get_number('CONSNUMBER',null);
      rcd_lads_adr_fax.errorflag := lics_inbound_utility.get_variable('ERRORFLAG');
      rcd_lads_adr_fax.flg_nouse := lics_inbound_utility.get_variable('FLG_NOUSE');

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
      if rcd_lads_adr_fax.obj_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - FAX.OBJ_TYPE');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_fax.obj_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - FAX.OBJ_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_fax.context is null then
         lics_inbound_utility.add_exception('Missing Primary Key - FAX.CONTEXT');
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

      insert into lads_adr_fax
         (obj_type,
          obj_id,
          context,
          faxseq,
          country,
          countryiso,
          std_no,
          fax,
          extension,
          fax_no,
          sender_no,
          fax_group,
          std_recip,
          r_3_user,
          home_flag,
          consnumber,
          errorflag,
          flg_nouse)
      values
         (rcd_lads_adr_fax.obj_type,
          rcd_lads_adr_fax.obj_id,
          rcd_lads_adr_fax.context,
          rcd_lads_adr_fax.faxseq,
          rcd_lads_adr_fax.country,
          rcd_lads_adr_fax.countryiso,
          rcd_lads_adr_fax.std_no,
          rcd_lads_adr_fax.fax,
          rcd_lads_adr_fax.extension,
          rcd_lads_adr_fax.fax_no,
          rcd_lads_adr_fax.sender_no,
          rcd_lads_adr_fax.fax_group,
          rcd_lads_adr_fax.std_recip,
          rcd_lads_adr_fax.r_3_user,
          rcd_lads_adr_fax.home_flag,
          rcd_lads_adr_fax.consnumber,
          rcd_lads_adr_fax.errorflag,
          rcd_lads_adr_fax.flg_nouse);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_fax;

   /**************************************************/
   /* This procedure performs the record EMA routine */
   /**************************************************/
   procedure process_record_ema(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('EMA', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_adr_ema.obj_type := rcd_lads_adr_hdr.obj_type;
      rcd_lads_adr_ema.obj_id := rcd_lads_adr_hdr.obj_id;
      rcd_lads_adr_ema.context := rcd_lads_adr_hdr.context;
      rcd_lads_adr_ema.emaseq := rcd_lads_adr_ema.emaseq + 1;
      rcd_lads_adr_ema.std_no := lics_inbound_utility.get_variable('STD_NO');
      rcd_lads_adr_ema.e_mail := lics_inbound_utility.get_variable('E_MAIL');
      rcd_lads_adr_ema.email_srch := lics_inbound_utility.get_variable('EMAIL_SRCH');
      rcd_lads_adr_ema.std_recip := lics_inbound_utility.get_variable('STD_RECIP');
      rcd_lads_adr_ema.r_3_user := lics_inbound_utility.get_variable('R_3_USER');
      rcd_lads_adr_ema.encode := lics_inbound_utility.get_variable('ENCODE');
      rcd_lads_adr_ema.tnef := lics_inbound_utility.get_variable('TNEF');
      rcd_lads_adr_ema.home_flag := lics_inbound_utility.get_variable('HOME_FLAG');
      rcd_lads_adr_ema.consnumber := lics_inbound_utility.get_number('CONSNUMBER',null);
      rcd_lads_adr_ema.errorflag := lics_inbound_utility.get_variable('ERRORFLAG');
      rcd_lads_adr_ema.flg_nouse := lics_inbound_utility.get_variable('FLG_NOUSE');

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
      if rcd_lads_adr_ema.obj_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - EMA.OBJ_TYPE');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_ema.obj_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - EMA.OBJ_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_ema.context is null then
         lics_inbound_utility.add_exception('Missing Primary Key - EMA.CONTEXT');
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

      insert into lads_adr_ema
         (obj_type,
          obj_id,
          context,
          emaseq,
          std_no,
          e_mail,
          email_srch,
          std_recip,
          r_3_user,
          encode,
          tnef,
          home_flag,
          consnumber,
          errorflag,
          flg_nouse)
      values
         (rcd_lads_adr_ema.obj_type,
          rcd_lads_adr_ema.obj_id,
          rcd_lads_adr_ema.context,
          rcd_lads_adr_ema.emaseq,
          rcd_lads_adr_ema.std_no,
          rcd_lads_adr_ema.e_mail,
          rcd_lads_adr_ema.email_srch,
          rcd_lads_adr_ema.std_recip,
          rcd_lads_adr_ema.r_3_user,
          rcd_lads_adr_ema.encode,
          rcd_lads_adr_ema.tnef,
          rcd_lads_adr_ema.home_flag,
          rcd_lads_adr_ema.consnumber,
          rcd_lads_adr_ema.errorflag,
          rcd_lads_adr_ema.flg_nouse);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ema;

   /**************************************************/
   /* This procedure performs the record URL routine */
   /**************************************************/
   procedure process_record_url(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('URL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_adr_url.obj_type := rcd_lads_adr_hdr.obj_type;
      rcd_lads_adr_url.obj_id := rcd_lads_adr_hdr.obj_id;
      rcd_lads_adr_url.context := rcd_lads_adr_hdr.context;
      rcd_lads_adr_url.urlseq := rcd_lads_adr_url.urlseq + 1;
      rcd_lads_adr_url.std_no := lics_inbound_utility.get_variable('STD_NO');
      rcd_lads_adr_url.uri_type := lics_inbound_utility.get_variable('URI_TYPE');
      rcd_lads_adr_url.uri := lics_inbound_utility.get_variable('URI');
      rcd_lads_adr_url.std_recip := lics_inbound_utility.get_variable('STD_RECIP');
      rcd_lads_adr_url.home_flag := lics_inbound_utility.get_variable('HOME_FLAG');
      rcd_lads_adr_url.consnumber := lics_inbound_utility.get_number('CONSNUMBER',null);
      rcd_lads_adr_url.uri_part1 := lics_inbound_utility.get_variable('URI_PART1');
      rcd_lads_adr_url.uri_part2 := lics_inbound_utility.get_variable('URI_PART2');
      rcd_lads_adr_url.uri_part3 := lics_inbound_utility.get_variable('URI_PART3');
      rcd_lads_adr_url.uri_part4 := lics_inbound_utility.get_variable('URI_PART4');
      rcd_lads_adr_url.uri_part5 := lics_inbound_utility.get_variable('URI_PART5');
      rcd_lads_adr_url.uri_part6 := lics_inbound_utility.get_variable('URI_PART6');
      rcd_lads_adr_url.uri_part7 := lics_inbound_utility.get_variable('URI_PART7');
      rcd_lads_adr_url.uri_part8 := lics_inbound_utility.get_variable('URI_PART8');
      rcd_lads_adr_url.uri_part9 := lics_inbound_utility.get_variable('URI_PART9');
      rcd_lads_adr_url.errorflag := lics_inbound_utility.get_variable('ERRORFLAG');
      rcd_lads_adr_url.flg_nouse := lics_inbound_utility.get_variable('FLG_NOUSE');

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
      if rcd_lads_adr_url.obj_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - URL.OBJ_TYPE');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_url.obj_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - URL.OBJ_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_url.context is null then
         lics_inbound_utility.add_exception('Missing Primary Key - URL.CONTEXT');
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

      insert into lads_adr_url
         (obj_type,
          obj_id,
          context,
          urlseq,
          std_no,
          uri_type,
          uri,
          std_recip,
          home_flag,
          consnumber,
          uri_part1,
          uri_part2,
          uri_part3,
          uri_part4,
          uri_part5,
          uri_part6,
          uri_part7,
          uri_part8,
          uri_part9,
          errorflag,
          flg_nouse)
      values
         (rcd_lads_adr_url.obj_type,
          rcd_lads_adr_url.obj_id,
          rcd_lads_adr_url.context,
          rcd_lads_adr_url.urlseq,
          rcd_lads_adr_url.std_no,
          rcd_lads_adr_url.uri_type,
          rcd_lads_adr_url.uri,
          rcd_lads_adr_url.std_recip,
          rcd_lads_adr_url.home_flag,
          rcd_lads_adr_url.consnumber,
          rcd_lads_adr_url.uri_part1,
          rcd_lads_adr_url.uri_part2,
          rcd_lads_adr_url.uri_part3,
          rcd_lads_adr_url.uri_part4,
          rcd_lads_adr_url.uri_part5,
          rcd_lads_adr_url.uri_part6,
          rcd_lads_adr_url.uri_part7,
          rcd_lads_adr_url.uri_part8,
          rcd_lads_adr_url.uri_part9,
          rcd_lads_adr_url.errorflag,
          rcd_lads_adr_url.flg_nouse);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_url;

   /**************************************************/
   /* This procedure performs the record COM routine */
   /**************************************************/
   procedure process_record_com(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('COM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_adr_com.obj_type := rcd_lads_adr_hdr.obj_type;
      rcd_lads_adr_com.obj_id := rcd_lads_adr_hdr.obj_id;
      rcd_lads_adr_com.context := rcd_lads_adr_hdr.context;
      rcd_lads_adr_com.comseq := rcd_lads_adr_com.comseq + 1;
      rcd_lads_adr_com.addr_vers := lics_inbound_utility.get_variable('ADDR_VERS');
      rcd_lads_adr_com.langu := lics_inbound_utility.get_variable('LANGU');
      rcd_lads_adr_com.langu_iso := lics_inbound_utility.get_variable('LANGU_ISO');
      rcd_lads_adr_com.adr_notes := lics_inbound_utility.get_variable('ADR_NOTES');
      rcd_lads_adr_com.errorflag := lics_inbound_utility.get_variable('ERRORFLAG');

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
      if rcd_lads_adr_com.obj_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - COM.OBJ_TYPE');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_com.obj_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - COM.OBJ_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_adr_com.context is null then
         lics_inbound_utility.add_exception('Missing Primary Key - COM.CONTEXT');
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

      insert into lads_adr_com
         (obj_type,
          obj_id,
          context,
          comseq,
          addr_vers,
          langu,
          langu_iso,
          adr_notes,
          errorflag)
      values
         (rcd_lads_adr_com.obj_type,
          rcd_lads_adr_com.obj_id,
          rcd_lads_adr_com.context,
          rcd_lads_adr_com.comseq,
          rcd_lads_adr_com.addr_vers,
          rcd_lads_adr_com.langu,
          rcd_lads_adr_com.langu_iso,
          rcd_lads_adr_com.adr_notes,
          rcd_lads_adr_com.errorflag);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_com;

end lads_atllad15;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad15 for lads_app.lads_atllad15;
grant execute on lads_atllad15 to lics_app;
