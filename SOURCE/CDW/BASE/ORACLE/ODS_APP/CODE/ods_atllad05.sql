/******************/
/* Package Header */
/******************/
create or replace package ods_atlods05 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_atlods05
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - atlods05 - Inbound Price List Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/11   ISI            Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_atlods05;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_atlods05 as

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
   procedure process_record_qua(par_record in varchar2);
   procedure process_record_val(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_ods_control ods_definition.idoc_control;
   rcd_sap_prc_lst_hdr sap_prc_lst_hdr%rowtype;
   rcd_sap_prc_lst_det sap_prc_lst_det%rowtype;
   rcd_sap_prc_lst_qua sap_prc_lst_qua%rowtype;
   rcd_sap_prc_lst_val sap_prc_lst_val%rowtype;

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
      lics_inbound_utility.set_definition('HDR','VAKEY',50);
      lics_inbound_utility.set_definition('HDR','ANZSN',10);
      lics_inbound_utility.set_definition('HDR','VKORG',4);
      lics_inbound_utility.set_definition('HDR','EVRTP',5);
      lics_inbound_utility.set_definition('HDR','KAPPL',2);
      lics_inbound_utility.set_definition('HDR','KOTABNR',3);
      lics_inbound_utility.set_definition('HDR','KSCHL',4);
      lics_inbound_utility.set_definition('HDR','KVEWE',1);
      lics_inbound_utility.set_definition('HDR','MATNR',18);
      lics_inbound_utility.set_definition('HDR','POSNR',6);
      lics_inbound_utility.set_definition('HDR','VTWEG',2);
      lics_inbound_utility.set_definition('HDR','SPART',2);
      lics_inbound_utility.set_definition('HDR','KUNNR',10);
      lics_inbound_utility.set_definition('HDR','KDGRP',2);
      lics_inbound_utility.set_definition('HDR','PLTYP',2);
      lics_inbound_utility.set_definition('HDR','KONDA',2);
      lics_inbound_utility.set_definition('HDR','KONDM',2);
      lics_inbound_utility.set_definition('HDR','WAERK',5);
      lics_inbound_utility.set_definition('HDR','BWTAR',10);
      lics_inbound_utility.set_definition('HDR','CHARG',10);
      lics_inbound_utility.set_definition('HDR','PRODH',18);
      lics_inbound_utility.set_definition('HDR','MEINS',3);
      lics_inbound_utility.set_definition('HDR','BONUS',2);
      lics_inbound_utility.set_definition('HDR','EBONU',2);
      lics_inbound_utility.set_definition('HDR','PROVG',2);
      lics_inbound_utility.set_definition('HDR','ALAND',3);
      lics_inbound_utility.set_definition('HDR','WKREG',3);
      lics_inbound_utility.set_definition('HDR','WKCOU',3);
      lics_inbound_utility.set_definition('HDR','WKCTY',4);
      lics_inbound_utility.set_definition('HDR','LLAND',3);
      lics_inbound_utility.set_definition('HDR','REGIO',3);
      lics_inbound_utility.set_definition('HDR','COUNC',3);
      lics_inbound_utility.set_definition('HDR','CITYC',4);
      lics_inbound_utility.set_definition('HDR','TAXM1',1);
      lics_inbound_utility.set_definition('HDR','TAXM2',1);
      lics_inbound_utility.set_definition('HDR','TAXM3',1);
      lics_inbound_utility.set_definition('HDR','TAXM4',1);
      lics_inbound_utility.set_definition('HDR','TAXM5',1);
      lics_inbound_utility.set_definition('HDR','TAXM6',1);
      lics_inbound_utility.set_definition('HDR','TAXM7',1);
      lics_inbound_utility.set_definition('HDR','TAXM8',1);
      lics_inbound_utility.set_definition('HDR','TAXM9',1);
      lics_inbound_utility.set_definition('HDR','TAXK1',1);
      lics_inbound_utility.set_definition('HDR','TAXK2',1);
      lics_inbound_utility.set_definition('HDR','TAXK3',1);
      lics_inbound_utility.set_definition('HDR','TAXK4',1);
      lics_inbound_utility.set_definition('HDR','TAXK5',1);
      lics_inbound_utility.set_definition('HDR','TAXK6',1);
      lics_inbound_utility.set_definition('HDR','TAXK7',1);
      lics_inbound_utility.set_definition('HDR','TAXK8',1);
      lics_inbound_utility.set_definition('HDR','TAXK9',1);
      lics_inbound_utility.set_definition('HDR','LIFNR',10);
      lics_inbound_utility.set_definition('HDR','MATKL',9);
      lics_inbound_utility.set_definition('HDR','EKORG',4);
      lics_inbound_utility.set_definition('HDR','ESOKZ',1);
      lics_inbound_utility.set_definition('HDR','WERKS',4);
      lics_inbound_utility.set_definition('HDR','RESWK',4);
      lics_inbound_utility.set_definition('HDR','KOLIF',10);
      lics_inbound_utility.set_definition('HDR','LTSNR',6);
      lics_inbound_utility.set_definition('HDR','WGLIF',18);
      lics_inbound_utility.set_definition('HDR','MWSKZ',2);
      lics_inbound_utility.set_definition('HDR','WERKV',4);
      lics_inbound_utility.set_definition('HDR','WAGRP',9);
      lics_inbound_utility.set_definition('HDR','VRKME',3);
      lics_inbound_utility.set_definition('HDR','EAN11',18);
      lics_inbound_utility.set_definition('HDR','EANNR',13);
      lics_inbound_utility.set_definition('HDR','AUART',4);
      lics_inbound_utility.set_definition('HDR','MEEIN',3);
      lics_inbound_utility.set_definition('HDR','INFNR',10);
      lics_inbound_utility.set_definition('HDR','EVRTN',10);
      lics_inbound_utility.set_definition('HDR','INCO1',3);
      lics_inbound_utility.set_definition('HDR','INCO2',28);
      lics_inbound_utility.set_definition('HDR','BUKRS',4);
      lics_inbound_utility.set_definition('HDR','MTART',4);
      lics_inbound_utility.set_definition('HDR','LIFRE',10);
      lics_inbound_utility.set_definition('HDR','EKKOL',4);
      lics_inbound_utility.set_definition('HDR','EKKOA',4);
      lics_inbound_utility.set_definition('HDR','BSTME',3);
      lics_inbound_utility.set_definition('HDR','WGHIE',18);
      lics_inbound_utility.set_definition('HDR','TAXIM',1);
      lics_inbound_utility.set_definition('HDR','TAXIK',1);
      lics_inbound_utility.set_definition('HDR','TAXIW',1);
      lics_inbound_utility.set_definition('HDR','TAXIL',1);
      lics_inbound_utility.set_definition('HDR','TAXIR',1);
      lics_inbound_utility.set_definition('HDR','TXJCD',15);
      lics_inbound_utility.set_definition('HDR','FKART',4);
      lics_inbound_utility.set_definition('HDR','VKORGAU',4);
      lics_inbound_utility.set_definition('HDR','HIENR',10);
      lics_inbound_utility.set_definition('HDR','VARCOND',26);
      lics_inbound_utility.set_definition('HDR','LAND1',3);
      lics_inbound_utility.set_definition('HDR','ZTERM',4);
      lics_inbound_utility.set_definition('HDR','GZOLX',4);
      lics_inbound_utility.set_definition('HDR','VBELN',10);
      lics_inbound_utility.set_definition('HDR','UPMAT',18);
      lics_inbound_utility.set_definition('HDR','UKONM',2);
      lics_inbound_utility.set_definition('HDR','AUART_SD',4);
      lics_inbound_utility.set_definition('HDR','PRODH1',5);
      lics_inbound_utility.set_definition('HDR','PRODH2',5);
      lics_inbound_utility.set_definition('HDR','PRODH3',8);
      lics_inbound_utility.set_definition('HDR','BZIRK',6);
      lics_inbound_utility.set_definition('HDR','VKGRP',3);
      lics_inbound_utility.set_definition('HDR','BRSCH',4);
      lics_inbound_utility.set_definition('HDR','VKBUR',4);
      lics_inbound_utility.set_definition('HDR','PRCTR',10);
      lics_inbound_utility.set_definition('HDR','LHIENR',10);
      lics_inbound_utility.set_definition('HDR','KDKGR',2);
      lics_inbound_utility.set_definition('HDR','BSTYP',1);
      lics_inbound_utility.set_definition('HDR','BSART',4);
      lics_inbound_utility.set_definition('HDR','EKGRP',3);
      lics_inbound_utility.set_definition('HDR','AKTNR',10);
      lics_inbound_utility.set_definition('HDR','SRVPOS',18);
      lics_inbound_utility.set_definition('HDR','PSTYP',1);
      lics_inbound_utility.set_definition('HDR','HLAND',3);
      lics_inbound_utility.set_definition('HDR','AUSFU',10);
      lics_inbound_utility.set_definition('HDR','HERKL',3);
      lics_inbound_utility.set_definition('HDR','VERLD',3);
      lics_inbound_utility.set_definition('HDR','COIMP',17);
      lics_inbound_utility.set_definition('HDR','STAWN',17);
      lics_inbound_utility.set_definition('HDR','CASNR',15);
      lics_inbound_utility.set_definition('HDR','EXPRF',8);
      lics_inbound_utility.set_definition('HDR','COKON',6);
      lics_inbound_utility.set_definition('HDR','COPHA',6);
      lics_inbound_utility.set_definition('HDR','COADI',6);
      lics_inbound_utility.set_definition('HDR','HERSE',10);
      lics_inbound_utility.set_definition('HDR','KTNUM',10);
      lics_inbound_utility.set_definition('HDR','PLNUM',10);
      lics_inbound_utility.set_definition('HDR','PREFA',10);
      lics_inbound_utility.set_definition('HDR','EILGR',10);
      lics_inbound_utility.set_definition('HDR','UPSNAM',20);
      lics_inbound_utility.set_definition('HDR','ORGNAM',20);
      lics_inbound_utility.set_definition('HDR','MESTYP',30);
      lics_inbound_utility.set_definition('HDR','OBJID',120);
      lics_inbound_utility.set_definition('HDR','OBJVAL',20);
      lics_inbound_utility.set_definition('HDR','DATAB',8);
      lics_inbound_utility.set_definition('HDR','DATBI',8);
      lics_inbound_utility.set_definition('HDR','KNUMH',10);
      lics_inbound_utility.set_definition('HDR','KOSRT',10);
      lics_inbound_utility.set_definition('HDR','KZUST',3);
      lics_inbound_utility.set_definition('HDR','KNUMA_SD',10);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','ANZAUF',2);
      lics_inbound_utility.set_definition('DET','GKWRT',18);
      lics_inbound_utility.set_definition('DET','KBRUE',18);
      lics_inbound_utility.set_definition('DET','KLF_KAL',4);
      lics_inbound_utility.set_definition('DET','KLF_STG',4);
      lics_inbound_utility.set_definition('DET','KMEIN',3);
      lics_inbound_utility.set_definition('DET','KOMXWRT',20);
      lics_inbound_utility.set_definition('DET','KONWA',5);
      lics_inbound_utility.set_definition('DET','KRECH',1);
      lics_inbound_utility.set_definition('DET','KSCHL1',4);
      lics_inbound_utility.set_definition('DET','KSTBM',20);
      lics_inbound_utility.set_definition('DET','KSTBW',21);
      lics_inbound_utility.set_definition('DET','KUMNE',6);
      lics_inbound_utility.set_definition('DET','MEINS',3);
      lics_inbound_utility.set_definition('DET','KBETR',18);
      lics_inbound_utility.set_definition('DET','KPEIN',5);
      lics_inbound_utility.set_definition('DET','MIKBAS',20);
      lics_inbound_utility.set_definition('DET','MXKBAS',20);
      lics_inbound_utility.set_definition('DET','MXWRT',18);
      lics_inbound_utility.set_definition('DET','STFKZ',1);
      lics_inbound_utility.set_definition('DET','VALDT',8);
      lics_inbound_utility.set_definition('DET','VALTG',2);
      lics_inbound_utility.set_definition('DET','ZAEHK_IND',2);
      lics_inbound_utility.set_definition('DET','KWAEH',5);
      lics_inbound_utility.set_definition('DET','KNUMT',10);
      lics_inbound_utility.set_definition('DET','KZBZG',1);
      lics_inbound_utility.set_definition('DET','KONMS',3);
      lics_inbound_utility.set_definition('DET','KONWS',5);
      lics_inbound_utility.set_definition('DET','PRSCH',4);
      lics_inbound_utility.set_definition('DET','KUMZA',6);
      lics_inbound_utility.set_definition('DET','PKWRT',23);
      lics_inbound_utility.set_definition('DET','UKBAS',23);
      lics_inbound_utility.set_definition('DET','KZNEP',1);
      lics_inbound_utility.set_definition('DET','KUNNR',10);
      lics_inbound_utility.set_definition('DET','LIFNR',10);
      lics_inbound_utility.set_definition('DET','MWSK1',2);
      lics_inbound_utility.set_definition('DET','LOEVM_KO',1);
      lics_inbound_utility.set_definition('DET','BOMAT',18);
      lics_inbound_utility.set_definition('DET','KSPAE',1);
      lics_inbound_utility.set_definition('DET','BOSTA',1);
      lics_inbound_utility.set_definition('DET','KNUMA_PI',10);
      lics_inbound_utility.set_definition('DET','KNUMA_AG',10);
      lics_inbound_utility.set_definition('DET','KNUMA_SQ',10);
      lics_inbound_utility.set_definition('DET','VKKAL',1);
      lics_inbound_utility.set_definition('DET','AKTNR',10);
      lics_inbound_utility.set_definition('DET','KNUMA_BO',10);
      lics_inbound_utility.set_definition('DET','MDFLG',1);
      lics_inbound_utility.set_definition('DET','ZTERM',4);
      lics_inbound_utility.set_definition('DET','BOMAT_EXTERNAL',40);
      lics_inbound_utility.set_definition('DET','BOMAT_VERSION',10);
      lics_inbound_utility.set_definition('DET','BOMAT_GUID',32);
      /*-*/
      lics_inbound_utility.set_definition('QUA','IDOC_QUA',3);
      lics_inbound_utility.set_definition('QUA','KSTBM',20);
      lics_inbound_utility.set_definition('QUA','KBETR',18);
      /*-*/
      lics_inbound_utility.set_definition('VAL','IDOC_VAL',3);
      lics_inbound_utility.set_definition('VAL','KSTBW',21);
      lics_inbound_utility.set_definition('VAL','KBETR',18);

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
         when 'QUA' then process_record_qua(par_record);
         when 'VAL' then process_record_val(par_record);
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
      /*-*/
      if var_trn_ignore = true then

         /*-*/
         /* Rollback the IDOC transaction
         /* **note** - releases transaction lock
         /*-*/
         rollback;

      elsif var_trn_error = true then

         /*-*/
         /* Rollback the IDOC transaction
         /* **note** - releases transaction lock
         /*-*/
         rollback;

      else

         /*-*/
         /* Commit the IDOC transaction and trace
         /* **note** - releases transaction lock
         /*-*/
         commit;

         /*-*/
         /* Call the interface monitor procedure.
         /*-*/
         begin
            ods_atlods05_monitor.execute(rcd_sap_prc_lst_hdr.vakey, rcd_sap_prc_lst_hdr.kschl, rcd_sap_prc_lst_hdr.datab, rcd_sap_prc_lst_hdr.knumh);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;

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
      rcd_ods_control.idoc_name := lics_inbound_utility.get_variable('IDOC_NAME');
      if rcd_ods_control.idoc_name is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NAME - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC number
      /*-*/
      rcd_ods_control.idoc_number := lics_inbound_utility.get_number('IDOC_NUMBER','9999999999999999');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if rcd_ods_control.idoc_number is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NUMBER - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC timestamp
      /*-*/
      rcd_ods_control.idoc_timestamp := lics_inbound_utility.get_variable('IDOC_DATE') || lics_inbound_utility.get_variable('IDOC_TIME');
      if rcd_ods_control.idoc_timestamp is null then
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
      var_sap_prc_lst_knumh ods.sap_prc_lst_hdr.knumh%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sap_prc_lst_hdr_chk is
         select a.knumh,
                a.datab,
                a.idoc_timestamp
         from sap_prc_lst_hdr a
         where a.kschl = rcd_sap_prc_lst_hdr.kschl
           and a.vakey = rcd_sap_prc_lst_hdr.vakey
           and ((a.datab >= rcd_sap_prc_lst_hdr.datab and a.datab <= rcd_sap_prc_lst_hdr.datbi) 
                or (a.datbi >= rcd_sap_prc_lst_hdr.datab and a.datbi <= rcd_sap_prc_lst_hdr.datbi));
      rcd_sap_prc_lst_hdr_chk csr_sap_prc_lst_hdr_chk%rowtype;

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
      rcd_sap_prc_lst_hdr.vakey := lics_inbound_utility.get_variable('VAKEY');
      rcd_sap_prc_lst_hdr.anzsn := lics_inbound_utility.get_number('ANZSN',null);
      rcd_sap_prc_lst_hdr.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_sap_prc_lst_hdr.evrtp := lics_inbound_utility.get_number('EVRTP',null);
      rcd_sap_prc_lst_hdr.kappl := lics_inbound_utility.get_variable('KAPPL');
      rcd_sap_prc_lst_hdr.kotabnr := lics_inbound_utility.get_number('KOTABNR',null);
      rcd_sap_prc_lst_hdr.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_sap_prc_lst_hdr.kvewe := lics_inbound_utility.get_variable('KVEWE');
      rcd_sap_prc_lst_hdr.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_sap_prc_lst_hdr.posnr := lics_inbound_utility.get_number('POSNR',null);
      rcd_sap_prc_lst_hdr.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_sap_prc_lst_hdr.spart := lics_inbound_utility.get_variable('SPART');
      rcd_sap_prc_lst_hdr.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_sap_prc_lst_hdr.kdgrp := lics_inbound_utility.get_variable('KDGRP');
      rcd_sap_prc_lst_hdr.pltyp := lics_inbound_utility.get_variable('PLTYP');
      rcd_sap_prc_lst_hdr.konda := lics_inbound_utility.get_variable('KONDA');
      rcd_sap_prc_lst_hdr.kondm := lics_inbound_utility.get_variable('KONDM');
      rcd_sap_prc_lst_hdr.waerk := lics_inbound_utility.get_variable('WAERK');
      rcd_sap_prc_lst_hdr.bwtar := lics_inbound_utility.get_variable('BWTAR');
      rcd_sap_prc_lst_hdr.charg := lics_inbound_utility.get_variable('CHARG');
      rcd_sap_prc_lst_hdr.prodh := lics_inbound_utility.get_variable('PRODH');
      rcd_sap_prc_lst_hdr.meins := lics_inbound_utility.get_variable('MEINS');
      rcd_sap_prc_lst_hdr.bonus := lics_inbound_utility.get_variable('BONUS');
      rcd_sap_prc_lst_hdr.ebonu := lics_inbound_utility.get_variable('EBONU');
      rcd_sap_prc_lst_hdr.provg := lics_inbound_utility.get_variable('PROVG');
      rcd_sap_prc_lst_hdr.aland := lics_inbound_utility.get_variable('ALAND');
      rcd_sap_prc_lst_hdr.wkreg := lics_inbound_utility.get_variable('WKREG');
      rcd_sap_prc_lst_hdr.wkcou := lics_inbound_utility.get_variable('WKCOU');
      rcd_sap_prc_lst_hdr.wkcty := lics_inbound_utility.get_variable('WKCTY');
      rcd_sap_prc_lst_hdr.lland := lics_inbound_utility.get_variable('LLAND');
      rcd_sap_prc_lst_hdr.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_sap_prc_lst_hdr.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_sap_prc_lst_hdr.cityc := lics_inbound_utility.get_variable('CITYC');
      rcd_sap_prc_lst_hdr.taxm1 := lics_inbound_utility.get_variable('TAXM1');
      rcd_sap_prc_lst_hdr.taxm2 := lics_inbound_utility.get_variable('TAXM2');
      rcd_sap_prc_lst_hdr.taxm3 := lics_inbound_utility.get_variable('TAXM3');
      rcd_sap_prc_lst_hdr.taxm4 := lics_inbound_utility.get_variable('TAXM4');
      rcd_sap_prc_lst_hdr.taxm5 := lics_inbound_utility.get_variable('TAXM5');
      rcd_sap_prc_lst_hdr.taxm6 := lics_inbound_utility.get_variable('TAXM6');
      rcd_sap_prc_lst_hdr.taxm7 := lics_inbound_utility.get_variable('TAXM7');
      rcd_sap_prc_lst_hdr.taxm8 := lics_inbound_utility.get_variable('TAXM8');
      rcd_sap_prc_lst_hdr.taxm9 := lics_inbound_utility.get_variable('TAXM9');
      rcd_sap_prc_lst_hdr.taxk1 := lics_inbound_utility.get_variable('TAXK1');
      rcd_sap_prc_lst_hdr.taxk2 := lics_inbound_utility.get_variable('TAXK2');
      rcd_sap_prc_lst_hdr.taxk3 := lics_inbound_utility.get_variable('TAXK3');
      rcd_sap_prc_lst_hdr.taxk4 := lics_inbound_utility.get_variable('TAXK4');
      rcd_sap_prc_lst_hdr.taxk5 := lics_inbound_utility.get_variable('TAXK5');
      rcd_sap_prc_lst_hdr.taxk6 := lics_inbound_utility.get_variable('TAXK6');
      rcd_sap_prc_lst_hdr.taxk7 := lics_inbound_utility.get_variable('TAXK7');
      rcd_sap_prc_lst_hdr.taxk8 := lics_inbound_utility.get_variable('TAXK8');
      rcd_sap_prc_lst_hdr.taxk9 := lics_inbound_utility.get_variable('TAXK9');
      rcd_sap_prc_lst_hdr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_sap_prc_lst_hdr.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_sap_prc_lst_hdr.ekorg := lics_inbound_utility.get_variable('EKORG');
      rcd_sap_prc_lst_hdr.esokz := lics_inbound_utility.get_variable('ESOKZ');
      rcd_sap_prc_lst_hdr.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_sap_prc_lst_hdr.reswk := lics_inbound_utility.get_variable('RESWK');
      rcd_sap_prc_lst_hdr.kolif := lics_inbound_utility.get_variable('KOLIF');
      rcd_sap_prc_lst_hdr.ltsnr := lics_inbound_utility.get_variable('LTSNR');
      rcd_sap_prc_lst_hdr.wglif := lics_inbound_utility.get_variable('WGLIF');
      rcd_sap_prc_lst_hdr.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_sap_prc_lst_hdr.werkv := lics_inbound_utility.get_variable('WERKV');
      rcd_sap_prc_lst_hdr.wagrp := lics_inbound_utility.get_variable('WAGRP');
      rcd_sap_prc_lst_hdr.vrkme := lics_inbound_utility.get_variable('VRKME');
      rcd_sap_prc_lst_hdr.ean11 := lics_inbound_utility.get_variable('EAN11');
      rcd_sap_prc_lst_hdr.eannr := lics_inbound_utility.get_variable('EANNR');
      rcd_sap_prc_lst_hdr.auart := lics_inbound_utility.get_variable('AUART');
      rcd_sap_prc_lst_hdr.meein := lics_inbound_utility.get_variable('MEEIN');
      rcd_sap_prc_lst_hdr.infnr := lics_inbound_utility.get_variable('INFNR');
      rcd_sap_prc_lst_hdr.evrtn := lics_inbound_utility.get_variable('EVRTN');
      rcd_sap_prc_lst_hdr.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_sap_prc_lst_hdr.inco2 := lics_inbound_utility.get_variable('INCO2');
      rcd_sap_prc_lst_hdr.bukrs := lics_inbound_utility.get_variable('BUKRS');
      rcd_sap_prc_lst_hdr.mtart := lics_inbound_utility.get_variable('MTART');
      rcd_sap_prc_lst_hdr.lifre := lics_inbound_utility.get_variable('LIFRE');
      rcd_sap_prc_lst_hdr.ekkol := lics_inbound_utility.get_variable('EKKOL');
      rcd_sap_prc_lst_hdr.ekkoa := lics_inbound_utility.get_variable('EKKOA');
      rcd_sap_prc_lst_hdr.bstme := lics_inbound_utility.get_variable('BSTME');
      rcd_sap_prc_lst_hdr.wghie := lics_inbound_utility.get_variable('WGHIE');
      rcd_sap_prc_lst_hdr.taxim := lics_inbound_utility.get_variable('TAXIM');
      rcd_sap_prc_lst_hdr.taxik := lics_inbound_utility.get_variable('TAXIK');
      rcd_sap_prc_lst_hdr.taxiw := lics_inbound_utility.get_variable('TAXIW');
      rcd_sap_prc_lst_hdr.taxil := lics_inbound_utility.get_variable('TAXIL');
      rcd_sap_prc_lst_hdr.taxir := lics_inbound_utility.get_variable('TAXIR');
      rcd_sap_prc_lst_hdr.txjcd := lics_inbound_utility.get_variable('TXJCD');
      rcd_sap_prc_lst_hdr.fkart := lics_inbound_utility.get_variable('FKART');
      rcd_sap_prc_lst_hdr.vkorgau := lics_inbound_utility.get_variable('VKORGAU');
      rcd_sap_prc_lst_hdr.hienr := lics_inbound_utility.get_variable('HIENR');
      rcd_sap_prc_lst_hdr.varcond := lics_inbound_utility.get_variable('VARCOND');
      rcd_sap_prc_lst_hdr.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_sap_prc_lst_hdr.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_sap_prc_lst_hdr.gzolx := lics_inbound_utility.get_variable('GZOLX');
      rcd_sap_prc_lst_hdr.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_sap_prc_lst_hdr.upmat := lics_inbound_utility.get_variable('UPMAT');
      rcd_sap_prc_lst_hdr.ukonm := lics_inbound_utility.get_variable('UKONM');
      rcd_sap_prc_lst_hdr.auart_sd := lics_inbound_utility.get_variable('AUART_SD');
      rcd_sap_prc_lst_hdr.prodh1 := lics_inbound_utility.get_variable('PRODH1');
      rcd_sap_prc_lst_hdr.prodh2 := lics_inbound_utility.get_variable('PRODH2');
      rcd_sap_prc_lst_hdr.prodh3 := lics_inbound_utility.get_variable('PRODH3');
      rcd_sap_prc_lst_hdr.bzirk := lics_inbound_utility.get_variable('BZIRK');
      rcd_sap_prc_lst_hdr.vkgrp := lics_inbound_utility.get_variable('VKGRP');
      rcd_sap_prc_lst_hdr.brsch := lics_inbound_utility.get_variable('BRSCH');
      rcd_sap_prc_lst_hdr.vkbur := lics_inbound_utility.get_variable('VKBUR');
      rcd_sap_prc_lst_hdr.prctr := lics_inbound_utility.get_variable('PRCTR');
      rcd_sap_prc_lst_hdr.lhienr := lics_inbound_utility.get_variable('LHIENR');
      rcd_sap_prc_lst_hdr.kdkgr := lics_inbound_utility.get_variable('KDKGR');
      rcd_sap_prc_lst_hdr.bstyp := lics_inbound_utility.get_variable('BSTYP');
      rcd_sap_prc_lst_hdr.bsart := lics_inbound_utility.get_variable('BSART');
      rcd_sap_prc_lst_hdr.ekgrp := lics_inbound_utility.get_variable('EKGRP');
      rcd_sap_prc_lst_hdr.aktnr := lics_inbound_utility.get_variable('AKTNR');
      rcd_sap_prc_lst_hdr.srvpos := lics_inbound_utility.get_variable('SRVPOS');
      rcd_sap_prc_lst_hdr.pstyp := lics_inbound_utility.get_variable('PSTYP');
      rcd_sap_prc_lst_hdr.hland := lics_inbound_utility.get_variable('HLAND');
      rcd_sap_prc_lst_hdr.ausfu := lics_inbound_utility.get_variable('AUSFU');
      rcd_sap_prc_lst_hdr.herkl := lics_inbound_utility.get_variable('HERKL');
      rcd_sap_prc_lst_hdr.verld := lics_inbound_utility.get_variable('VERLD');
      rcd_sap_prc_lst_hdr.coimp := lics_inbound_utility.get_variable('COIMP');
      rcd_sap_prc_lst_hdr.stawn := lics_inbound_utility.get_variable('STAWN');
      rcd_sap_prc_lst_hdr.casnr := lics_inbound_utility.get_variable('CASNR');
      rcd_sap_prc_lst_hdr.exprf := lics_inbound_utility.get_variable('EXPRF');
      rcd_sap_prc_lst_hdr.cokon := lics_inbound_utility.get_variable('COKON');
      rcd_sap_prc_lst_hdr.copha := lics_inbound_utility.get_variable('COPHA');
      rcd_sap_prc_lst_hdr.coadi := lics_inbound_utility.get_variable('COADI');
      rcd_sap_prc_lst_hdr.herse := lics_inbound_utility.get_variable('HERSE');
      rcd_sap_prc_lst_hdr.ktnum := lics_inbound_utility.get_variable('KTNUM');
      rcd_sap_prc_lst_hdr.plnum := lics_inbound_utility.get_variable('PLNUM');
      rcd_sap_prc_lst_hdr.prefa := lics_inbound_utility.get_variable('PREFA');
      rcd_sap_prc_lst_hdr.eilgr := lics_inbound_utility.get_variable('EILGR');
      rcd_sap_prc_lst_hdr.upsnam := lics_inbound_utility.get_variable('UPSNAM');
      rcd_sap_prc_lst_hdr.orgnam := lics_inbound_utility.get_variable('ORGNAM');
      rcd_sap_prc_lst_hdr.mestyp := lics_inbound_utility.get_variable('MESTYP');
      rcd_sap_prc_lst_hdr.objid := lics_inbound_utility.get_variable('OBJID');
      rcd_sap_prc_lst_hdr.objval := lics_inbound_utility.get_variable('OBJVAL');
      rcd_sap_prc_lst_hdr.datab := lics_inbound_utility.get_variable('DATAB');
      rcd_sap_prc_lst_hdr.datbi := lics_inbound_utility.get_variable('DATBI');
      rcd_sap_prc_lst_hdr.knumh := lics_inbound_utility.get_variable('KNUMH');
      rcd_sap_prc_lst_hdr.kosrt := lics_inbound_utility.get_variable('KOSRT');
      rcd_sap_prc_lst_hdr.kzust := lics_inbound_utility.get_variable('KZUST');
      rcd_sap_prc_lst_hdr.knuma_sd := lics_inbound_utility.get_variable('KNUMA_SD');
      rcd_sap_prc_lst_hdr.idoc_name := rcd_ods_control.idoc_name;
      rcd_sap_prc_lst_hdr.idoc_number := rcd_ods_control.idoc_number;
      rcd_sap_prc_lst_hdr.idoc_timestamp := rcd_ods_control.idoc_timestamp;
      rcd_sap_prc_lst_hdr.valdtn_status := ods_constants.valdtn_valid;
      rcd_sap_prc_lst_hdr.sap_prc_lst_hdr_lupdp := user;
      rcd_sap_prc_lst_hdr.sap_prc_lst_hdr_lupdt := sysdate;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_prc_lst_det.detseq := 0;

      /*-*/
      /* Intialise temporary KNUMH variable
      /*-*/
      var_sap_prc_lst_knumh := null;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_prc_lst_hdr.vakey is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.VAKEY');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_hdr.kschl is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.KSCHL');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_hdr.datab is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.DATAB');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_hdr.knumh is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.KNUMH');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_sap_prc_lst_hdr.vakey is null) and
         not(rcd_sap_prc_lst_hdr.kschl is null) and
         not(rcd_sap_prc_lst_hdr.datab is null) and
         not(rcd_sap_prc_lst_hdr.knumh is null) then

         open csr_sap_prc_lst_hdr_chk;
         loop
            fetch csr_sap_prc_lst_hdr_chk into rcd_sap_prc_lst_hdr_chk;
            if (csr_sap_prc_lst_hdr_chk%notfound) then
               exit;
            end if;

            /*-*/
            /* Delete all date ranges older than idoc range and commit
            /*   NOTE : commit is necessary, as the ignore flag executes a rollback,
            /*          which is not appropriate after deletion in some cases.
            /* Else - if any existing range is found to be newer than idoc range, then ignore.
            /*-*/
            if (rcd_sap_prc_lst_hdr.idoc_timestamp > rcd_sap_prc_lst_hdr_chk.idoc_timestamp) then
               delete from sap_prc_lst_val where vakey = rcd_sap_prc_lst_hdr.vakey
                                              and kschl = rcd_sap_prc_lst_hdr.kschl
                                              and knumh = rcd_sap_prc_lst_hdr_chk.knumh
                                              and datab = rcd_sap_prc_lst_hdr_chk.datab;
               delete from sap_prc_lst_qua where vakey = rcd_sap_prc_lst_hdr.vakey
                                              and kschl = rcd_sap_prc_lst_hdr.kschl
                                              and knumh = rcd_sap_prc_lst_hdr_chk.knumh
                                              and datab = rcd_sap_prc_lst_hdr_chk.datab;
               delete from sap_prc_lst_det where vakey = rcd_sap_prc_lst_hdr.vakey
                                              and kschl = rcd_sap_prc_lst_hdr.kschl
                                              and knumh = rcd_sap_prc_lst_hdr_chk.knumh
                                              and datab = rcd_sap_prc_lst_hdr_chk.datab;
               delete from sap_prc_lst_hdr where vakey = rcd_sap_prc_lst_hdr.vakey
                                              and kschl = rcd_sap_prc_lst_hdr.kschl
                                              and knumh = rcd_sap_prc_lst_hdr_chk.knumh
                                              and datab = rcd_sap_prc_lst_hdr_chk.datab;
               commit;
            else
               var_trn_ignore := true;
            end if;                  

         end loop;

         close csr_sap_prc_lst_hdr_chk;

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

      update sap_prc_lst_hdr set
         anzsn = rcd_sap_prc_lst_hdr.anzsn,
         vkorg = rcd_sap_prc_lst_hdr.vkorg,
         evrtp = rcd_sap_prc_lst_hdr.evrtp,
         kappl = rcd_sap_prc_lst_hdr.kappl,
         kotabnr = rcd_sap_prc_lst_hdr.kotabnr,
         kvewe = rcd_sap_prc_lst_hdr.kvewe,
         matnr = rcd_sap_prc_lst_hdr.matnr,
         posnr = rcd_sap_prc_lst_hdr.posnr,
         vtweg = rcd_sap_prc_lst_hdr.vtweg,
         spart = rcd_sap_prc_lst_hdr.spart,
         kunnr = rcd_sap_prc_lst_hdr.kunnr,
         kdgrp = rcd_sap_prc_lst_hdr.kdgrp,
         pltyp = rcd_sap_prc_lst_hdr.pltyp,
         konda = rcd_sap_prc_lst_hdr.konda,
         kondm = rcd_sap_prc_lst_hdr.kondm,
         waerk = rcd_sap_prc_lst_hdr.waerk,
         bwtar = rcd_sap_prc_lst_hdr.bwtar,
         charg = rcd_sap_prc_lst_hdr.charg,
         prodh = rcd_sap_prc_lst_hdr.prodh,
         meins = rcd_sap_prc_lst_hdr.meins,
         bonus = rcd_sap_prc_lst_hdr.bonus,
         ebonu = rcd_sap_prc_lst_hdr.ebonu,
         provg = rcd_sap_prc_lst_hdr.provg,
         aland = rcd_sap_prc_lst_hdr.aland,
         wkreg = rcd_sap_prc_lst_hdr.wkreg,
         wkcou = rcd_sap_prc_lst_hdr.wkcou,
         wkcty = rcd_sap_prc_lst_hdr.wkcty,
         lland = rcd_sap_prc_lst_hdr.lland,
         regio = rcd_sap_prc_lst_hdr.regio,
         counc = rcd_sap_prc_lst_hdr.counc,
         cityc = rcd_sap_prc_lst_hdr.cityc,
         taxm1 = rcd_sap_prc_lst_hdr.taxm1,
         taxm2 = rcd_sap_prc_lst_hdr.taxm2,
         taxm3 = rcd_sap_prc_lst_hdr.taxm3,
         taxm4 = rcd_sap_prc_lst_hdr.taxm4,
         taxm5 = rcd_sap_prc_lst_hdr.taxm5,
         taxm6 = rcd_sap_prc_lst_hdr.taxm6,
         taxm7 = rcd_sap_prc_lst_hdr.taxm7,
         taxm8 = rcd_sap_prc_lst_hdr.taxm8,
         taxm9 = rcd_sap_prc_lst_hdr.taxm9,
         taxk1 = rcd_sap_prc_lst_hdr.taxk1,
         taxk2 = rcd_sap_prc_lst_hdr.taxk2,
         taxk3 = rcd_sap_prc_lst_hdr.taxk3,
         taxk4 = rcd_sap_prc_lst_hdr.taxk4,
         taxk5 = rcd_sap_prc_lst_hdr.taxk5,
         taxk6 = rcd_sap_prc_lst_hdr.taxk6,
         taxk7 = rcd_sap_prc_lst_hdr.taxk7,
         taxk8 = rcd_sap_prc_lst_hdr.taxk8,
         taxk9 = rcd_sap_prc_lst_hdr.taxk9,
         lifnr = rcd_sap_prc_lst_hdr.lifnr,
         matkl = rcd_sap_prc_lst_hdr.matkl,
         ekorg = rcd_sap_prc_lst_hdr.ekorg,
         esokz = rcd_sap_prc_lst_hdr.esokz,
         werks = rcd_sap_prc_lst_hdr.werks,
         reswk = rcd_sap_prc_lst_hdr.reswk,
         kolif = rcd_sap_prc_lst_hdr.kolif,
         ltsnr = rcd_sap_prc_lst_hdr.ltsnr,
         wglif = rcd_sap_prc_lst_hdr.wglif,
         mwskz = rcd_sap_prc_lst_hdr.mwskz,
         werkv = rcd_sap_prc_lst_hdr.werkv,
         wagrp = rcd_sap_prc_lst_hdr.wagrp,
         vrkme = rcd_sap_prc_lst_hdr.vrkme,
         ean11 = rcd_sap_prc_lst_hdr.ean11,
         eannr = rcd_sap_prc_lst_hdr.eannr,
         auart = rcd_sap_prc_lst_hdr.auart,
         meein = rcd_sap_prc_lst_hdr.meein,
         infnr = rcd_sap_prc_lst_hdr.infnr,
         evrtn = rcd_sap_prc_lst_hdr.evrtn,
         inco1 = rcd_sap_prc_lst_hdr.inco1,
         inco2 = rcd_sap_prc_lst_hdr.inco2,
         bukrs = rcd_sap_prc_lst_hdr.bukrs,
         mtart = rcd_sap_prc_lst_hdr.mtart,
         lifre = rcd_sap_prc_lst_hdr.lifre,
         ekkol = rcd_sap_prc_lst_hdr.ekkol,
         ekkoa = rcd_sap_prc_lst_hdr.ekkoa,
         bstme = rcd_sap_prc_lst_hdr.bstme,
         wghie = rcd_sap_prc_lst_hdr.wghie,
         taxim = rcd_sap_prc_lst_hdr.taxim,
         taxik = rcd_sap_prc_lst_hdr.taxik,
         taxiw = rcd_sap_prc_lst_hdr.taxiw,
         taxil = rcd_sap_prc_lst_hdr.taxil,
         taxir = rcd_sap_prc_lst_hdr.taxir,
         txjcd = rcd_sap_prc_lst_hdr.txjcd,
         fkart = rcd_sap_prc_lst_hdr.fkart,
         vkorgau = rcd_sap_prc_lst_hdr.vkorgau,
         hienr = rcd_sap_prc_lst_hdr.hienr,
         varcond = rcd_sap_prc_lst_hdr.varcond,
         land1 = rcd_sap_prc_lst_hdr.land1,
         zterm = rcd_sap_prc_lst_hdr.zterm,
         gzolx = rcd_sap_prc_lst_hdr.gzolx,
         vbeln = rcd_sap_prc_lst_hdr.vbeln,
         upmat = rcd_sap_prc_lst_hdr.upmat,
         ukonm = rcd_sap_prc_lst_hdr.ukonm,
         auart_sd = rcd_sap_prc_lst_hdr.auart_sd,
         prodh1 = rcd_sap_prc_lst_hdr.prodh1,
         prodh2 = rcd_sap_prc_lst_hdr.prodh2,
         prodh3 = rcd_sap_prc_lst_hdr.prodh3,
         bzirk = rcd_sap_prc_lst_hdr.bzirk,
         vkgrp = rcd_sap_prc_lst_hdr.vkgrp,
         brsch = rcd_sap_prc_lst_hdr.brsch,
         vkbur = rcd_sap_prc_lst_hdr.vkbur,
         prctr = rcd_sap_prc_lst_hdr.prctr,
         lhienr = rcd_sap_prc_lst_hdr.lhienr,
         kdkgr = rcd_sap_prc_lst_hdr.kdkgr,
         bstyp = rcd_sap_prc_lst_hdr.bstyp,
         bsart = rcd_sap_prc_lst_hdr.bsart,
         ekgrp = rcd_sap_prc_lst_hdr.ekgrp,
         aktnr = rcd_sap_prc_lst_hdr.aktnr,
         srvpos = rcd_sap_prc_lst_hdr.srvpos,
         pstyp = rcd_sap_prc_lst_hdr.pstyp,
         hland = rcd_sap_prc_lst_hdr.hland,
         ausfu = rcd_sap_prc_lst_hdr.ausfu,
         herkl = rcd_sap_prc_lst_hdr.herkl,
         verld = rcd_sap_prc_lst_hdr.verld,
         coimp = rcd_sap_prc_lst_hdr.coimp,
         stawn = rcd_sap_prc_lst_hdr.stawn,
         casnr = rcd_sap_prc_lst_hdr.casnr,
         exprf = rcd_sap_prc_lst_hdr.exprf,
         cokon = rcd_sap_prc_lst_hdr.cokon,
         copha = rcd_sap_prc_lst_hdr.copha,
         coadi = rcd_sap_prc_lst_hdr.coadi,
         herse = rcd_sap_prc_lst_hdr.herse,
         ktnum = rcd_sap_prc_lst_hdr.ktnum,
         plnum = rcd_sap_prc_lst_hdr.plnum,
         prefa = rcd_sap_prc_lst_hdr.prefa,
         eilgr = rcd_sap_prc_lst_hdr.eilgr,
         upsnam = rcd_sap_prc_lst_hdr.upsnam,
         orgnam = rcd_sap_prc_lst_hdr.orgnam,
         mestyp = rcd_sap_prc_lst_hdr.mestyp,
         objid = rcd_sap_prc_lst_hdr.objid,
         objval = rcd_sap_prc_lst_hdr.objval,
         datab = rcd_sap_prc_lst_hdr.datab,
         datbi = rcd_sap_prc_lst_hdr.datbi,
         kosrt = rcd_sap_prc_lst_hdr.kosrt,
         kzust = rcd_sap_prc_lst_hdr.kzust,
         knuma_sd  = rcd_sap_prc_lst_hdr.knuma_sd,
         idoc_name = rcd_sap_prc_lst_hdr.idoc_name,
         idoc_number = rcd_sap_prc_lst_hdr.idoc_number,
         idoc_timestamp = rcd_sap_prc_lst_hdr.idoc_timestamp,
         valdtn_status = rcd_sap_prc_lst_hdr.valdtn_status,
         sap_prc_lst_hdr_lupdp = rcd_sap_prc_lst_hdr.sap_prc_lst_hdr_lupdp,
         sap_prc_lst_hdr_lupdt = rcd_sap_prc_lst_hdr.sap_prc_lst_hdr_lupdt
      where vakey = rcd_sap_prc_lst_hdr.vakey
        and kschl = rcd_sap_prc_lst_hdr.kschl
        and knumh = rcd_sap_prc_lst_hdr_chk.knumh
        and datab = rcd_sap_prc_lst_hdr_chk.datab;
      if sql%notfound then
         insert into sap_prc_lst_hdr
            (vakey,
             anzsn,
             vkorg,
             evrtp,
             kappl,
             kotabnr,
             kschl,
             kvewe,
             matnr,
             posnr,
             vtweg,
             spart,
             kunnr,
             kdgrp,
             pltyp,
             konda,
             kondm,
             waerk,
             bwtar,
             charg,
             prodh,
             meins,
             bonus,
             ebonu,
             provg,
             aland,
             wkreg,
             wkcou,
             wkcty,
             lland,
             regio,
             counc,
             cityc,
             taxm1,
             taxm2,
             taxm3,
             taxm4,
             taxm5,
             taxm6,
             taxm7,
             taxm8,
             taxm9,
             taxk1,
             taxk2,
             taxk3,
             taxk4,
             taxk5,
             taxk6,
             taxk7,
             taxk8,
             taxk9,
             lifnr,
             matkl,
             ekorg,
             esokz,
             werks,
             reswk,
             kolif,
             ltsnr,
             wglif,
             mwskz,
             werkv,
             wagrp,
             vrkme,
             ean11,
             eannr,
             auart,
             meein,
             infnr,
             evrtn,
             inco1,
             inco2,
             bukrs,
             mtart,
             lifre,
             ekkol,
             ekkoa,
             bstme,
             wghie,
             taxim,
             taxik,
             taxiw,
             taxil,
             taxir,
             txjcd,
             fkart,
             vkorgau,
             hienr,
             varcond,
             land1,
             zterm,
             gzolx,
             vbeln,
             upmat,
             ukonm,
             auart_sd,
             prodh1,
             prodh2,
             prodh3,
             bzirk,
             vkgrp,
             brsch,
             vkbur,
             prctr,
             lhienr,
             kdkgr,
             bstyp,
             bsart,
             ekgrp,
             aktnr,
             srvpos,
             pstyp,
             hland,
             ausfu,
             herkl,
             verld,
             coimp,
             stawn,
             casnr,
             exprf,
             cokon,
             copha,
             coadi,
             herse,
             ktnum,
             plnum,
             prefa,
             eilgr,
             upsnam,
             orgnam,
             mestyp,
             objid,
             objval,
             datab,
             datbi,
             knumh,
             kosrt,
             kzust,
             knuma_sd,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             valdtn_status,
             sap_prc_lst_hdr_lupdp,
             sap_prc_lst_hdr_lupdt)
         values
            (rcd_sap_prc_lst_hdr.vakey,
             rcd_sap_prc_lst_hdr.anzsn,
             rcd_sap_prc_lst_hdr.vkorg,
             rcd_sap_prc_lst_hdr.evrtp,
             rcd_sap_prc_lst_hdr.kappl,
             rcd_sap_prc_lst_hdr.kotabnr,
             rcd_sap_prc_lst_hdr.kschl,
             rcd_sap_prc_lst_hdr.kvewe,
             rcd_sap_prc_lst_hdr.matnr,
             rcd_sap_prc_lst_hdr.posnr,
             rcd_sap_prc_lst_hdr.vtweg,
             rcd_sap_prc_lst_hdr.spart,
             rcd_sap_prc_lst_hdr.kunnr,
             rcd_sap_prc_lst_hdr.kdgrp,
             rcd_sap_prc_lst_hdr.pltyp,
             rcd_sap_prc_lst_hdr.konda,
             rcd_sap_prc_lst_hdr.kondm,
             rcd_sap_prc_lst_hdr.waerk,
             rcd_sap_prc_lst_hdr.bwtar,
             rcd_sap_prc_lst_hdr.charg,
             rcd_sap_prc_lst_hdr.prodh,
             rcd_sap_prc_lst_hdr.meins,
             rcd_sap_prc_lst_hdr.bonus,
             rcd_sap_prc_lst_hdr.ebonu,
             rcd_sap_prc_lst_hdr.provg,
             rcd_sap_prc_lst_hdr.aland,
             rcd_sap_prc_lst_hdr.wkreg,
             rcd_sap_prc_lst_hdr.wkcou,
             rcd_sap_prc_lst_hdr.wkcty,
             rcd_sap_prc_lst_hdr.lland,
             rcd_sap_prc_lst_hdr.regio,
             rcd_sap_prc_lst_hdr.counc,
             rcd_sap_prc_lst_hdr.cityc,
             rcd_sap_prc_lst_hdr.taxm1,
             rcd_sap_prc_lst_hdr.taxm2,
             rcd_sap_prc_lst_hdr.taxm3,
             rcd_sap_prc_lst_hdr.taxm4,
             rcd_sap_prc_lst_hdr.taxm5,
             rcd_sap_prc_lst_hdr.taxm6,
             rcd_sap_prc_lst_hdr.taxm7,
             rcd_sap_prc_lst_hdr.taxm8,
             rcd_sap_prc_lst_hdr.taxm9,
             rcd_sap_prc_lst_hdr.taxk1,
             rcd_sap_prc_lst_hdr.taxk2,
             rcd_sap_prc_lst_hdr.taxk3,
             rcd_sap_prc_lst_hdr.taxk4,
             rcd_sap_prc_lst_hdr.taxk5,
             rcd_sap_prc_lst_hdr.taxk6,
             rcd_sap_prc_lst_hdr.taxk7,
             rcd_sap_prc_lst_hdr.taxk8,
             rcd_sap_prc_lst_hdr.taxk9,
             rcd_sap_prc_lst_hdr.lifnr,
             rcd_sap_prc_lst_hdr.matkl,
             rcd_sap_prc_lst_hdr.ekorg,
             rcd_sap_prc_lst_hdr.esokz,
             rcd_sap_prc_lst_hdr.werks,
             rcd_sap_prc_lst_hdr.reswk,
             rcd_sap_prc_lst_hdr.kolif,
             rcd_sap_prc_lst_hdr.ltsnr,
             rcd_sap_prc_lst_hdr.wglif,
             rcd_sap_prc_lst_hdr.mwskz,
             rcd_sap_prc_lst_hdr.werkv,
             rcd_sap_prc_lst_hdr.wagrp,
             rcd_sap_prc_lst_hdr.vrkme,
             rcd_sap_prc_lst_hdr.ean11,
             rcd_sap_prc_lst_hdr.eannr,
             rcd_sap_prc_lst_hdr.auart,
             rcd_sap_prc_lst_hdr.meein,
             rcd_sap_prc_lst_hdr.infnr,
             rcd_sap_prc_lst_hdr.evrtn,
             rcd_sap_prc_lst_hdr.inco1,
             rcd_sap_prc_lst_hdr.inco2,
             rcd_sap_prc_lst_hdr.bukrs,
             rcd_sap_prc_lst_hdr.mtart,
             rcd_sap_prc_lst_hdr.lifre,
             rcd_sap_prc_lst_hdr.ekkol,
             rcd_sap_prc_lst_hdr.ekkoa,
             rcd_sap_prc_lst_hdr.bstme,
             rcd_sap_prc_lst_hdr.wghie,
             rcd_sap_prc_lst_hdr.taxim,
             rcd_sap_prc_lst_hdr.taxik,
             rcd_sap_prc_lst_hdr.taxiw,
             rcd_sap_prc_lst_hdr.taxil,
             rcd_sap_prc_lst_hdr.taxir,
             rcd_sap_prc_lst_hdr.txjcd,
             rcd_sap_prc_lst_hdr.fkart,
             rcd_sap_prc_lst_hdr.vkorgau,
             rcd_sap_prc_lst_hdr.hienr,
             rcd_sap_prc_lst_hdr.varcond,
             rcd_sap_prc_lst_hdr.land1,
             rcd_sap_prc_lst_hdr.zterm,
             rcd_sap_prc_lst_hdr.gzolx,
             rcd_sap_prc_lst_hdr.vbeln,
             rcd_sap_prc_lst_hdr.upmat,
             rcd_sap_prc_lst_hdr.ukonm,
             rcd_sap_prc_lst_hdr.auart_sd,
             rcd_sap_prc_lst_hdr.prodh1,
             rcd_sap_prc_lst_hdr.prodh2,
             rcd_sap_prc_lst_hdr.prodh3,
             rcd_sap_prc_lst_hdr.bzirk,
             rcd_sap_prc_lst_hdr.vkgrp,
             rcd_sap_prc_lst_hdr.brsch,
             rcd_sap_prc_lst_hdr.vkbur,
             rcd_sap_prc_lst_hdr.prctr,
             rcd_sap_prc_lst_hdr.lhienr,
             rcd_sap_prc_lst_hdr.kdkgr,
             rcd_sap_prc_lst_hdr.bstyp,
             rcd_sap_prc_lst_hdr.bsart,
             rcd_sap_prc_lst_hdr.ekgrp,
             rcd_sap_prc_lst_hdr.aktnr,
             rcd_sap_prc_lst_hdr.srvpos,
             rcd_sap_prc_lst_hdr.pstyp,
             rcd_sap_prc_lst_hdr.hland,
             rcd_sap_prc_lst_hdr.ausfu,
             rcd_sap_prc_lst_hdr.herkl,
             rcd_sap_prc_lst_hdr.verld,
             rcd_sap_prc_lst_hdr.coimp,
             rcd_sap_prc_lst_hdr.stawn,
             rcd_sap_prc_lst_hdr.casnr,
             rcd_sap_prc_lst_hdr.exprf,
             rcd_sap_prc_lst_hdr.cokon,
             rcd_sap_prc_lst_hdr.copha,
             rcd_sap_prc_lst_hdr.coadi,
             rcd_sap_prc_lst_hdr.herse,
             rcd_sap_prc_lst_hdr.ktnum,
             rcd_sap_prc_lst_hdr.plnum,
             rcd_sap_prc_lst_hdr.prefa,
             rcd_sap_prc_lst_hdr.eilgr,
             rcd_sap_prc_lst_hdr.upsnam,
             rcd_sap_prc_lst_hdr.orgnam,
             rcd_sap_prc_lst_hdr.mestyp,
             rcd_sap_prc_lst_hdr.objid,
             rcd_sap_prc_lst_hdr.objval,
             rcd_sap_prc_lst_hdr.datab,
             rcd_sap_prc_lst_hdr.datbi,
             rcd_sap_prc_lst_hdr.knumh,
             rcd_sap_prc_lst_hdr.kosrt,
             rcd_sap_prc_lst_hdr.kzust,
             rcd_sap_prc_lst_hdr.knuma_sd,
             rcd_sap_prc_lst_hdr.idoc_name,
             rcd_sap_prc_lst_hdr.idoc_number,
             rcd_sap_prc_lst_hdr.idoc_timestamp,
             rcd_sap_prc_lst_hdr.valdtn_status,
             rcd_sap_prc_lst_hdr.sap_prc_lst_hdr_lupdp,
             rcd_sap_prc_lst_hdr.sap_prc_lst_hdr_lupdt);
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
      rcd_sap_prc_lst_det.vakey := rcd_sap_prc_lst_hdr.vakey;
      rcd_sap_prc_lst_det.kschl := rcd_sap_prc_lst_hdr.kschl;
      rcd_sap_prc_lst_det.knumh := rcd_sap_prc_lst_hdr.knumh;
      rcd_sap_prc_lst_det.datab := rcd_sap_prc_lst_hdr.datab;
      rcd_sap_prc_lst_det.detseq := rcd_sap_prc_lst_det.detseq + 1;
      rcd_sap_prc_lst_det.anzauf := lics_inbound_utility.get_number('ANZAUF',null);
      rcd_sap_prc_lst_det.gkwrt := lics_inbound_utility.get_number('GKWRT',null);
      rcd_sap_prc_lst_det.kbrue := lics_inbound_utility.get_number('KBRUE',null);
      rcd_sap_prc_lst_det.klf_kal := lics_inbound_utility.get_number('KLF_KAL',null);
      rcd_sap_prc_lst_det.klf_stg := lics_inbound_utility.get_number('KLF_STG',null);
      rcd_sap_prc_lst_det.kmein := lics_inbound_utility.get_variable('KMEIN');
      rcd_sap_prc_lst_det.komxwrt := lics_inbound_utility.get_number('KOMXWRT',null);
      rcd_sap_prc_lst_det.konwa := lics_inbound_utility.get_variable('KONWA');
      rcd_sap_prc_lst_det.krech := lics_inbound_utility.get_variable('KRECH');
      rcd_sap_prc_lst_det.kschl1 := lics_inbound_utility.get_variable('KSCHL1');
      rcd_sap_prc_lst_det.kstbm := lics_inbound_utility.get_number('KSTBM',null);
      rcd_sap_prc_lst_det.kstbw := lics_inbound_utility.get_number('KSTBW',null);
      rcd_sap_prc_lst_det.kumne := lics_inbound_utility.get_number('KUMNE',null);
      rcd_sap_prc_lst_det.meins := lics_inbound_utility.get_variable('MEINS');
      rcd_sap_prc_lst_det.kbetr := lics_inbound_utility.get_number('KBETR',null);
      rcd_sap_prc_lst_det.kpein := lics_inbound_utility.get_number('KPEIN',null);
      rcd_sap_prc_lst_det.mikbas := lics_inbound_utility.get_number('MIKBAS',null);
      rcd_sap_prc_lst_det.mxkbas := lics_inbound_utility.get_number('MXKBAS',null);
      rcd_sap_prc_lst_det.mxwrt := lics_inbound_utility.get_number('MXWRT',null);
      rcd_sap_prc_lst_det.stfkz := lics_inbound_utility.get_variable('STFKZ');
      rcd_sap_prc_lst_det.valdt := lics_inbound_utility.get_variable('VALDT');
      rcd_sap_prc_lst_det.valtg := lics_inbound_utility.get_number('VALTG',null);
      rcd_sap_prc_lst_det.zaehk_ind := lics_inbound_utility.get_number('ZAEHK_IND',null);
      rcd_sap_prc_lst_det.kwaeh := lics_inbound_utility.get_variable('KWAEH');
      rcd_sap_prc_lst_det.knumt := lics_inbound_utility.get_variable('KNUMT');
      rcd_sap_prc_lst_det.kzbzg := lics_inbound_utility.get_variable('KZBZG');
      rcd_sap_prc_lst_det.konms := lics_inbound_utility.get_variable('KONMS');
      rcd_sap_prc_lst_det.konws := lics_inbound_utility.get_variable('KONWS');
      rcd_sap_prc_lst_det.prsch := lics_inbound_utility.get_variable('PRSCH');
      rcd_sap_prc_lst_det.kumza := lics_inbound_utility.get_number('KUMZA',null);
      rcd_sap_prc_lst_det.pkwrt := lics_inbound_utility.get_number('PKWRT',null);
      rcd_sap_prc_lst_det.ukbas := lics_inbound_utility.get_number('UKBAS',null);
      rcd_sap_prc_lst_det.kznep := lics_inbound_utility.get_variable('KZNEP');
      rcd_sap_prc_lst_det.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_sap_prc_lst_det.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_sap_prc_lst_det.mwsk1 := lics_inbound_utility.get_variable('MWSK1');
      rcd_sap_prc_lst_det.loevm_ko := lics_inbound_utility.get_variable('LOEVM_KO');
      rcd_sap_prc_lst_det.bomat := lics_inbound_utility.get_variable('BOMAT');
      rcd_sap_prc_lst_det.kspae := lics_inbound_utility.get_variable('KSPAE');
      rcd_sap_prc_lst_det.bosta := lics_inbound_utility.get_variable('BOSTA');
      rcd_sap_prc_lst_det.knuma_pi := lics_inbound_utility.get_variable('KNUMA_PI');
      rcd_sap_prc_lst_det.knuma_ag := lics_inbound_utility.get_variable('KNUMA_AG');
      rcd_sap_prc_lst_det.knuma_sq := lics_inbound_utility.get_variable('KNUMA_SQ');
      rcd_sap_prc_lst_det.vkkal := lics_inbound_utility.get_variable('VKKAL');
      rcd_sap_prc_lst_det.aktnr := lics_inbound_utility.get_variable('AKTNR');
      rcd_sap_prc_lst_det.knuma_bo := lics_inbound_utility.get_variable('KNUMA_BO');
      rcd_sap_prc_lst_det.mdflg := lics_inbound_utility.get_variable('MDFLG');
      rcd_sap_prc_lst_det.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_sap_prc_lst_det.bomat_external := lics_inbound_utility.get_variable('BOMAT_EXTERNAL');
      rcd_sap_prc_lst_det.bomat_version := lics_inbound_utility.get_variable('BOMAT_VERSION');
      rcd_sap_prc_lst_det.bomat_guid := lics_inbound_utility.get_variable('BOMAT_GUID');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_prc_lst_qua.quaseq := 0;
      rcd_sap_prc_lst_val.valseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_prc_lst_det.vakey is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.VAKEY');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_det.kschl is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.KSCHL');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_det.knumh is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.KNUMH');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_det.datab is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.DATAB');
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

      insert into sap_prc_lst_det
         (vakey,
          kschl,
          knumh,
          datab,
          detseq,
          anzauf,
          gkwrt,
          kbrue,
          klf_kal,
          klf_stg,
          kmein,
          komxwrt,
          konwa,
          krech,
          kschl1,
          kstbm,
          kstbw,
          kumne,
          meins,
          kbetr,
          kpein,
          mikbas,
          mxkbas,
          mxwrt,
          stfkz,
          valdt,
          valtg,
          zaehk_ind,
          kwaeh,
          knumt,
          kzbzg,
          konms,
          konws,
          prsch,
          kumza,
          pkwrt,
          ukbas,
          kznep,
          kunnr,
          lifnr,
          mwsk1,
          loevm_ko,
          bomat,
          kspae,
          bosta,
          knuma_pi,
          knuma_ag,
          knuma_sq,
          vkkal,
          aktnr,
          knuma_bo,
          mdflg,
          zterm,
          bomat_external,
          bomat_version,
          bomat_guid)
      values
         (rcd_sap_prc_lst_det.vakey,
          rcd_sap_prc_lst_det.kschl,
          rcd_sap_prc_lst_det.knumh,
          rcd_sap_prc_lst_det.datab,
          rcd_sap_prc_lst_det.detseq,
          rcd_sap_prc_lst_det.anzauf,
          rcd_sap_prc_lst_det.gkwrt,
          rcd_sap_prc_lst_det.kbrue,
          rcd_sap_prc_lst_det.klf_kal,
          rcd_sap_prc_lst_det.klf_stg,
          rcd_sap_prc_lst_det.kmein,
          rcd_sap_prc_lst_det.komxwrt,
          rcd_sap_prc_lst_det.konwa,
          rcd_sap_prc_lst_det.krech,
          rcd_sap_prc_lst_det.kschl1,
          rcd_sap_prc_lst_det.kstbm,
          rcd_sap_prc_lst_det.kstbw,
          rcd_sap_prc_lst_det.kumne,
          rcd_sap_prc_lst_det.meins,
          rcd_sap_prc_lst_det.kbetr,
          rcd_sap_prc_lst_det.kpein,
          rcd_sap_prc_lst_det.mikbas,
          rcd_sap_prc_lst_det.mxkbas,
          rcd_sap_prc_lst_det.mxwrt,
          rcd_sap_prc_lst_det.stfkz,
          rcd_sap_prc_lst_det.valdt,
          rcd_sap_prc_lst_det.valtg,
          rcd_sap_prc_lst_det.zaehk_ind,
          rcd_sap_prc_lst_det.kwaeh,
          rcd_sap_prc_lst_det.knumt,
          rcd_sap_prc_lst_det.kzbzg,
          rcd_sap_prc_lst_det.konms,
          rcd_sap_prc_lst_det.konws,
          rcd_sap_prc_lst_det.prsch,
          rcd_sap_prc_lst_det.kumza,
          rcd_sap_prc_lst_det.pkwrt,
          rcd_sap_prc_lst_det.ukbas,
          rcd_sap_prc_lst_det.kznep,
          rcd_sap_prc_lst_det.kunnr,
          rcd_sap_prc_lst_det.lifnr,
          rcd_sap_prc_lst_det.mwsk1,
          rcd_sap_prc_lst_det.loevm_ko,
          rcd_sap_prc_lst_det.bomat,
          rcd_sap_prc_lst_det.kspae,
          rcd_sap_prc_lst_det.bosta,
          rcd_sap_prc_lst_det.knuma_pi,
          rcd_sap_prc_lst_det.knuma_ag,
          rcd_sap_prc_lst_det.knuma_sq,
          rcd_sap_prc_lst_det.vkkal,
          rcd_sap_prc_lst_det.aktnr,
          rcd_sap_prc_lst_det.knuma_bo,
          rcd_sap_prc_lst_det.mdflg,
          rcd_sap_prc_lst_det.zterm,
          rcd_sap_prc_lst_det.bomat_external,
          rcd_sap_prc_lst_det.bomat_version,
          rcd_sap_prc_lst_det.bomat_guid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record QUA routine */
   /**************************************************/
   procedure process_record_qua(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('QUA', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_prc_lst_qua.vakey := rcd_sap_prc_lst_det.vakey;
      rcd_sap_prc_lst_qua.kschl := rcd_sap_prc_lst_det.kschl;
      rcd_sap_prc_lst_qua.knumh := rcd_sap_prc_lst_det.knumh;
      rcd_sap_prc_lst_qua.datab := rcd_sap_prc_lst_det.datab;
      rcd_sap_prc_lst_qua.detseq := rcd_sap_prc_lst_det.detseq;
      rcd_sap_prc_lst_qua.quaseq := rcd_sap_prc_lst_qua.quaseq + 1;
      rcd_sap_prc_lst_qua.kstbm := lics_inbound_utility.get_number('KSTBM',null);
      rcd_sap_prc_lst_qua.kbetr := lics_inbound_utility.get_number('KBETR',null);

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
      if rcd_sap_prc_lst_qua.vakey is null then
         lics_inbound_utility.add_exception('Missing Primary Key - QUA.VAKEY');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_qua.kschl is null then
         lics_inbound_utility.add_exception('Missing Primary Key - QUA.KSCHL');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_qua.datab is null then
         lics_inbound_utility.add_exception('Missing Primary Key - QUA.DATAB');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_qua.knumh is null then
         lics_inbound_utility.add_exception('Missing Primary Key - QUA.KNUMH');
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

      insert into sap_prc_lst_qua
         (vakey,
          kschl,
          knumh,
          datab,
          detseq,
          quaseq,
          kstbm,
          kbetr)
      values
         (rcd_sap_prc_lst_qua.vakey,
          rcd_sap_prc_lst_qua.kschl,
          rcd_sap_prc_lst_qua.knumh,
          rcd_sap_prc_lst_qua.datab,
          rcd_sap_prc_lst_qua.detseq,
          rcd_sap_prc_lst_qua.quaseq,
          rcd_sap_prc_lst_qua.kstbm,
          rcd_sap_prc_lst_qua.kbetr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_qua;

   /**************************************************/
   /* This procedure performs the record VAL routine */
   /**************************************************/
   procedure process_record_val(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('VAL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_prc_lst_val.vakey := rcd_sap_prc_lst_det.vakey;
      rcd_sap_prc_lst_val.kschl := rcd_sap_prc_lst_det.kschl;
      rcd_sap_prc_lst_val.knumh := rcd_sap_prc_lst_det.knumh;
      rcd_sap_prc_lst_val.datab := rcd_sap_prc_lst_det.datab;
      rcd_sap_prc_lst_val.detseq := rcd_sap_prc_lst_det.detseq;
      rcd_sap_prc_lst_val.valseq := rcd_sap_prc_lst_val.valseq + 1;
      rcd_sap_prc_lst_val.kstbw := lics_inbound_utility.get_number('KSTBW',null);
      rcd_sap_prc_lst_val.kbetr := lics_inbound_utility.get_number('KBETR',null);

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
      if rcd_sap_prc_lst_val.vakey is null then
         lics_inbound_utility.add_exception('Missing Primary Key - VAL.VAKEY');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_val.kschl is null then
         lics_inbound_utility.add_exception('Missing Primary Key - VAL.KSCHL');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_val.datab is null then
         lics_inbound_utility.add_exception('Missing Primary Key - VAL.DATAB');
         var_trn_error := true;
      end if;
      if rcd_sap_prc_lst_val.knumh is null then
         lics_inbound_utility.add_exception('Missing Primary Key - VAL.KNUMH');
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

      insert into sap_prc_lst_val
         (vakey,
          kschl,
          knumh,
          datab,
          detseq,
          valseq,
          kstbw,
          kbetr)
      values
         (rcd_sap_prc_lst_val.vakey,
          rcd_sap_prc_lst_val.kschl,
          rcd_sap_prc_lst_val.knumh,
          rcd_sap_prc_lst_val.datab,
          rcd_sap_prc_lst_val.detseq,
          rcd_sap_prc_lst_val.valseq,
          rcd_sap_prc_lst_val.kstbw,
          rcd_sap_prc_lst_val.kbetr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_val;

end ods_atlods05;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_atlods05 for sap_app.ods_atlods05;
grant execute on ods_atlods05 to lics_app;
