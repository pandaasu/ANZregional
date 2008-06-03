/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad30
 Owner   : lads_app
 Author  : Sunil Mandalika

 Description
 -----------
 Local Atlas Data Store - atllad30 - Financial Accounts Receivable

 YYYY/MM   Author               Description
 -------   ------               -----------
 2007/07   Sunil Mandalika      Created
 2008/05   Trevor Keon          Added calls to monitor before and after procedure                                        

*******************************************************************************/

/******************/
/* Package Header */
/******************/

CREATE OR REPLACE package lads_atllad30 as

   /*-*/
   /* Public defarrations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad30;
/

/******************/
/* Package Body */
/******************/

CREATE OR REPLACE package body lads_atllad30 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private defarrations
   /*-*/
   procedure complete_transaction;
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);
   procedure process_record_led(par_record in varchar2);
   procedure process_record_tax(par_record in varchar2);


   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;


   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_far_hdr lads_far_hdr%rowtype;
   rcd_lads_far_det lads_far_det%rowtype;
   rcd_lads_far_led lads_far_led%rowtype;
   rcd_lads_far_tax lads_far_tax%rowtype;

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
      lics_inbound_utility.set_definition('HDR','BUKRS',6);
      lics_inbound_utility.set_definition('HDR','BELNR',10);
      lics_inbound_utility.set_definition('HDR','GJAHR',4);
      lics_inbound_utility.set_definition('HDR','BLART',2);
      lics_inbound_utility.set_definition('HDR','BLDAT',8);
      lics_inbound_utility.set_definition('HDR','BUDAT',8);
      lics_inbound_utility.set_definition('HDR','MONAT',2);
      lics_inbound_utility.set_definition('HDR','WWERT',8);
      lics_inbound_utility.set_definition('HDR','USNAM',12);
      lics_inbound_utility.set_definition('HDR','TCODE',4);
      lics_inbound_utility.set_definition('HDR','BVORG',16);
      lics_inbound_utility.set_definition('HDR','XBLNR',16);
      lics_inbound_utility.set_definition('HDR','BKTXT',25);
      lics_inbound_utility.set_definition('HDR','WAERS',5);
      lics_inbound_utility.set_definition('HDR','KURSF',11);
      lics_inbound_utility.set_definition('HDR','GLVOR',4);
      lics_inbound_utility.set_definition('HDR','AWTYP',5);
      lics_inbound_utility.set_definition('HDR','AWREF',10);
      lics_inbound_utility.set_definition('HDR','AWORG',10);
      lics_inbound_utility.set_definition('HDR','FIKRS',4);
      lics_inbound_utility.set_definition('HDR','HWAER',5);
      lics_inbound_utility.set_definition('HDR','HWAE2',5);
      lics_inbound_utility.set_definition('HDR','HWAE3',5);
      lics_inbound_utility.set_definition('HDR','KURS2',11);
      lics_inbound_utility.set_definition('HDR','KURS3',11);
      lics_inbound_utility.set_definition('HDR','BASW2',1);
      lics_inbound_utility.set_definition('HDR','BASW3',1);
      lics_inbound_utility.set_definition('HDR','UMRD2',1);
      lics_inbound_utility.set_definition('HDR','UMRD3',1);
      lics_inbound_utility.set_definition('HDR','CURT2',2);
      lics_inbound_utility.set_definition('HDR','CURT3',2);
      lics_inbound_utility.set_definition('HDR','AUSBK',4);
      lics_inbound_utility.set_definition('HDR','AWSYS',10);
      lics_inbound_utility.set_definition('HDR','LOTKZ',10);
      lics_inbound_utility.set_definition('HDR','BUKRS_SND',4);
      lics_inbound_utility.set_definition('HDR','FILTER',1);
      lics_inbound_utility.set_definition('HDR','KURSF_M',12);
      lics_inbound_utility.set_definition('HDR','KURS2_M',12);
      lics_inbound_utility.set_definition('HDR','KURS3_M',12);
      lics_inbound_utility.set_definition('HDR','BSTAT',1);
      lics_inbound_utility.set_definition('HDR','BRNCH',4);
      lics_inbound_utility.set_definition('HDR','NUMPG',3);
      lics_inbound_utility.set_definition('HDR','ADISC',1);
      lics_inbound_utility.set_definition('HDR','STBLG',10);
      lics_inbound_utility.set_definition('HDR','STJAH',4);
      lics_inbound_utility.set_definition('HDR','AWTYP_REV',5);
      lics_inbound_utility.set_definition('HDR','AWREF_REV',10);
      lics_inbound_utility.set_definition('HDR','AWORG_REV',10);
      lics_inbound_utility.set_definition('HDR','RESERVE',50);
      lics_inbound_utility.set_definition('HDR','XREF1_HD',20);
      lics_inbound_utility.set_definition('HDR','XREF2_HD',20);
      lics_inbound_utility.set_definition('HDR','XBLNR_LONG',35);
     /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_HDR',3);
      lics_inbound_utility.set_definition('DET','BUZEI',3);
      lics_inbound_utility.set_definition('DET','BUZID',1);
      lics_inbound_utility.set_definition('DET','AUGDT',8);
      lics_inbound_utility.set_definition('DET','AUGCP',8);
      lics_inbound_utility.set_definition('DET','AUGBL',10);
      lics_inbound_utility.set_definition('DET','BSCHL',2);
      lics_inbound_utility.set_definition('DET','KOART',1);
      lics_inbound_utility.set_definition('DET','SHKZG',1);
      lics_inbound_utility.set_definition('DET','GSBER',4);
      lics_inbound_utility.set_definition('DET','PARGB',4);
      lics_inbound_utility.set_definition('DET','MWSKZ',2);
      lics_inbound_utility.set_definition('DET','DMBTR',15);
      lics_inbound_utility.set_definition('DET','DMBE2',15);
      lics_inbound_utility.set_definition('DET','DMBE3',15);
      lics_inbound_utility.set_definition('DET','WRBTR',15);
      lics_inbound_utility.set_definition('DET','KZBTR',15);
      lics_inbound_utility.set_definition('DET','PSWBT',15);
      lics_inbound_utility.set_definition('DET','PSWSL',5);
      lics_inbound_utility.set_definition('DET','HWBAS',15);
      lics_inbound_utility.set_definition('DET','FWBAS',15);
      lics_inbound_utility.set_definition('DET','MWART',1);
      lics_inbound_utility.set_definition('DET','KTOSL',3);
      lics_inbound_utility.set_definition('DET','VALUT',8);
      lics_inbound_utility.set_definition('DET','ZUONR',18);
      lics_inbound_utility.set_definition('DET','SGTXT',50);
      lics_inbound_utility.set_definition('DET','VBUND',6);
      lics_inbound_utility.set_definition('DET','BEWAR',3);
      lics_inbound_utility.set_definition('DET','VORGN',4);
      lics_inbound_utility.set_definition('DET','FDLEV',2);
      lics_inbound_utility.set_definition('DET','FDGRP',10);
      lics_inbound_utility.set_definition('DET','FDTAG',8);
      lics_inbound_utility.set_definition('DET','KOKRS',4);
      lics_inbound_utility.set_definition('DET','TXGRP',3);
      lics_inbound_utility.set_definition('DET','KOSTL',10);
      lics_inbound_utility.set_definition('DET','AUFNR',12);
      lics_inbound_utility.set_definition('DET','VBELN',10);
      lics_inbound_utility.set_definition('DET','VBEL2',10);
      lics_inbound_utility.set_definition('DET','POSN2',6);
      lics_inbound_utility.set_definition('DET','ANLN1',12);
      lics_inbound_utility.set_definition('DET','ANLN2',4);
      lics_inbound_utility.set_definition('DET','ANBWA',3);
      lics_inbound_utility.set_definition('DET','BZDAT',8);
      lics_inbound_utility.set_definition('DET','PERNR',8);
      lics_inbound_utility.set_definition('DET','XUMSW',1);
      lics_inbound_utility.set_definition('DET','XSKRL',1);
      lics_inbound_utility.set_definition('DET','XAUTO',1);
      lics_inbound_utility.set_definition('DET','SAKNR',10);
      lics_inbound_utility.set_definition('DET','HKONT',10);
      lics_inbound_utility.set_definition('DET','ABPER',6);
      lics_inbound_utility.set_definition('DET','MATNR',18);
      lics_inbound_utility.set_definition('DET','WERKS',4);
      lics_inbound_utility.set_definition('DET','MENGE',15);
      lics_inbound_utility.set_definition('DET','MEINS',3);
      lics_inbound_utility.set_definition('DET','ERFMG',15);
      lics_inbound_utility.set_definition('DET','ERFME',3);
      lics_inbound_utility.set_definition('DET','BPMNG',15);
      lics_inbound_utility.set_definition('DET','BPRME',3);
      lics_inbound_utility.set_definition('DET','EBELN',10);
      lics_inbound_utility.set_definition('DET','EBELP',5);
      lics_inbound_utility.set_definition('DET','ZEKKN',2);
      lics_inbound_utility.set_definition('DET','BWKEY',4);
      lics_inbound_utility.set_definition('DET','BWTAR',10);
      lics_inbound_utility.set_definition('DET','BUSTW',4);
      lics_inbound_utility.set_definition('DET','BUALT',15);
      lics_inbound_utility.set_definition('DET','TBTKZ',1);
      lics_inbound_utility.set_definition('DET','STCEG',20);
      lics_inbound_utility.set_definition('DET','RSTGR',3);
      lics_inbound_utility.set_definition('DET','PRCTR',10);
      lics_inbound_utility.set_definition('DET','VNAME',6);
      lics_inbound_utility.set_definition('DET','RECID',2);
      lics_inbound_utility.set_definition('DET','EGRUP',3);
      lics_inbound_utility.set_definition('DET','VPTNR',10);
      lics_inbound_utility.set_definition('DET','VERTT',1);
      lics_inbound_utility.set_definition('DET','VERTN',13);
      lics_inbound_utility.set_definition('DET','VBEWA',4);
      lics_inbound_utility.set_definition('DET','TXJCD',15);
      lics_inbound_utility.set_definition('DET','IMKEY',8);
      lics_inbound_utility.set_definition('DET','DABRZ',8);
      lics_inbound_utility.set_definition('DET','FIPOS',14);
      lics_inbound_utility.set_definition('DET','KSTRG',12);
      lics_inbound_utility.set_definition('DET','NPLNR',12);
      lics_inbound_utility.set_definition('DET','AUFPL',10);
      lics_inbound_utility.set_definition('DET','APLZL',8);
      lics_inbound_utility.set_definition('DET','PROJK',8);
      lics_inbound_utility.set_definition('DET','PAOBJNR',10);
      lics_inbound_utility.set_definition('DET','BTYPE',2);
      lics_inbound_utility.set_definition('DET','ETYPE',3);
      lics_inbound_utility.set_definition('DET','XEGDR',1);
      lics_inbound_utility.set_definition('DET','HRKFT',4);
      lics_inbound_utility.set_definition('DET','LOKKT',10);
      lics_inbound_utility.set_definition('DET','FISTL',16);
      lics_inbound_utility.set_definition('DET','GEBER',10);
      lics_inbound_utility.set_definition('DET','STBUK',4);
      lics_inbound_utility.set_definition('DET','ALTKT',10);
      lics_inbound_utility.set_definition('DET','PPRCT',10);
      lics_inbound_utility.set_definition('DET','XREF1',12);
      lics_inbound_utility.set_definition('DET','XREF2',12);
      lics_inbound_utility.set_definition('DET','KBLNR',10);
      lics_inbound_utility.set_definition('DET','KBLPOS',3);
      lics_inbound_utility.set_definition('DET','FKBER',4);
      lics_inbound_utility.set_definition('DET','OBZEI',3);
      lics_inbound_utility.set_definition('DET','XNEGP',1);
      lics_inbound_utility.set_definition('DET','CACCT',10);
      lics_inbound_utility.set_definition('DET','XREF3',20);
      lics_inbound_utility.set_definition('DET','TXDAT',8);
      lics_inbound_utility.set_definition('DET','BUPLA',4);
      lics_inbound_utility.set_definition('DET','SECCO',4);
      lics_inbound_utility.set_definition('DET','LSTAR',6);
      lics_inbound_utility.set_definition('DET','PRZNR',12);
      lics_inbound_utility.set_definition('DET','KURSR',11);
      lics_inbound_utility.set_definition('DET','KURSR_M',11);
      lics_inbound_utility.set_definition('DET','GBETR',15);
      lics_inbound_utility.set_definition('DET','RESERVE',50);
      lics_inbound_utility.set_definition('DET','XCPDD',1);

      /*-*/
      lics_inbound_utility.set_definition('LED','IDOC_HDR',3);
      lics_inbound_utility.set_definition('LED','UMSKZ',1);
      lics_inbound_utility.set_definition('LED','MWSTS',15);
      lics_inbound_utility.set_definition('LED','WMWST',15);
      lics_inbound_utility.set_definition('LED','KUNNR',10);
      lics_inbound_utility.set_definition('LED','FILKD',10);
      lics_inbound_utility.set_definition('LED','ZFBDT',8);
      lics_inbound_utility.set_definition('LED','ZTERM',4);
      lics_inbound_utility.set_definition('LED','ZBD1T',5);
      lics_inbound_utility.set_definition('LED','ZBD2T',5);
      lics_inbound_utility.set_definition('LED','ZBD3T',5);
      lics_inbound_utility.set_definition('LED','ZBD1P',7);
      lics_inbound_utility.set_definition('LED','ZBD2P',7);
      lics_inbound_utility.set_definition('LED','SKFBT',15);
      lics_inbound_utility.set_definition('LED','SKNTO',15);
      lics_inbound_utility.set_definition('LED','WSKTO',15);
      lics_inbound_utility.set_definition('LED','ZLSCH',1);
      lics_inbound_utility.set_definition('LED','ZLSPR',1);
      lics_inbound_utility.set_definition('LED','UZAWE',2);
      lics_inbound_utility.set_definition('LED','HBKID',5);
      lics_inbound_utility.set_definition('LED','BVTYP',4);
      lics_inbound_utility.set_definition('LED','REBZG',10);
      lics_inbound_utility.set_definition('LED','REBZJ',4);
      lics_inbound_utility.set_definition('LED','REBZZ',3);
      lics_inbound_utility.set_definition('LED','REBZT',1);
      lics_inbound_utility.set_definition('LED','LZBKZ',3);
      lics_inbound_utility.set_definition('LED','LANDL',3);
      lics_inbound_utility.set_definition('LED','DIEKZ',1);
      lics_inbound_utility.set_definition('LED','VRSKZ',1);
      lics_inbound_utility.set_definition('LED','VRSDT',8);
      lics_inbound_utility.set_definition('LED','MSCHL',1);
      lics_inbound_utility.set_definition('LED','MANSP',1);
      lics_inbound_utility.set_definition('LED','MABER',2);
      lics_inbound_utility.set_definition('LED','MADAT',8);
      lics_inbound_utility.set_definition('LED','MANST',1);
      lics_inbound_utility.set_definition('LED','QSSKZ',2);
      lics_inbound_utility.set_definition('LED','QSSHB',15);
      lics_inbound_utility.set_definition('LED','QSFBT',15);
      lics_inbound_utility.set_definition('LED','LIFNR',10);
      lics_inbound_utility.set_definition('LED','ESRNR',11);
      lics_inbound_utility.set_definition('LED','ESRRE',27);
      lics_inbound_utility.set_definition('LED','ESRPZ',2);
      lics_inbound_utility.set_definition('LED','ZBFIX',1);
      lics_inbound_utility.set_definition('LED','KIDNO',30);
      lics_inbound_utility.set_definition('LED','EMPFB',10);
      lics_inbound_utility.set_definition('LED','SKNT2',15);
      lics_inbound_utility.set_definition('LED','SKNT3',15);
      lics_inbound_utility.set_definition('LED','PYCUR',5);
      lics_inbound_utility.set_definition('LED','PYAMT',15);
      lics_inbound_utility.set_definition('LED','KKBER',4);
      lics_inbound_utility.set_definition('LED','ABSBT',15);
      lics_inbound_utility.set_definition('LED','ZUMSK',1);
      lics_inbound_utility.set_definition('LED','CESSION_KZ',2);
      lics_inbound_utility.set_definition('LED','DTWS1',2);
      lics_inbound_utility.set_definition('LED','DTWS2',2);
      lics_inbound_utility.set_definition('LED','DTWS3',2);
      lics_inbound_utility.set_definition('LED','DTWS4',2);
      lics_inbound_utility.set_definition('LED','AWTYP_REB',5);
      lics_inbound_utility.set_definition('LED','AWREF_REB',10);
      lics_inbound_utility.set_definition('LED','AWORG_REB',10);
      lics_inbound_utility.set_definition('LED','RESERVE',50);

      /*-*/
      lics_inbound_utility.set_definition('TAX','IDOC_HDR',3);
      lics_inbound_utility.set_definition('TAX','BUZEI',3);
      lics_inbound_utility.set_definition('TAX','MWSKZ',2);
      lics_inbound_utility.set_definition('TAX','HKONT',10);
      lics_inbound_utility.set_definition('TAX','TXGRP',3);
      lics_inbound_utility.set_definition('TAX','SHKZG',1);
      lics_inbound_utility.set_definition('TAX','HWBAS',17);
      lics_inbound_utility.set_definition('TAX','FWBAS',17);
      lics_inbound_utility.set_definition('TAX','HWSTE',15);
      lics_inbound_utility.set_definition('TAX','FWSTE',15);
      lics_inbound_utility.set_definition('TAX','KTOSL',3);
      lics_inbound_utility.set_definition('TAX','KNUMH',10);
      lics_inbound_utility.set_definition('TAX','STCEG',20);
      lics_inbound_utility.set_definition('TAX','EGBLD',3);
      lics_inbound_utility.set_definition('TAX','EGLLD',3);
      lics_inbound_utility.set_definition('TAX','TXJCD',15);
      lics_inbound_utility.set_definition('TAX','H2STE',15);
      lics_inbound_utility.set_definition('TAX','H3STE',15);
      lics_inbound_utility.set_definition('TAX','H2BAS',17);
      lics_inbound_utility.set_definition('TAX','H3BAS',17);
      lics_inbound_utility.set_definition('TAX','KSCHL',4);
      lics_inbound_utility.set_definition('TAX','STMDT',8);
      lics_inbound_utility.set_definition('TAX','STMTI',6);
      lics_inbound_utility.set_definition('TAX','MLDDT',8);
      lics_inbound_utility.set_definition('TAX','KBETR',13);
      lics_inbound_utility.set_definition('TAX','STBKZ',1);
      lics_inbound_utility.set_definition('TAX','LSTML',3);
      lics_inbound_utility.set_definition('TAX','LWSTE',15);
      lics_inbound_utility.set_definition('TAX','LWBAS',17);
      lics_inbound_utility.set_definition('TAX','TXDAT',8);
      lics_inbound_utility.set_definition('TAX','BUPLA',4);
      lics_inbound_utility.set_definition('TAX','TXJDP',15);
      lics_inbound_utility.set_definition('TAX','TXJLV',1);
      lics_inbound_utility.set_definition('TAX','RESERVE',50);
      lics_inbound_utility.set_definition('TAX','TAXPS',6);
      lics_inbound_utility.set_definition('TAX','TXMOD',3);
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
         when 'LED' then process_record_led(par_record);
         when 'TAX' then process_record_tax(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD30';
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
         /* Set the transaction accepted indicator and rollback the IDOC transaction
         /* **note** - releases transaction lock
         /*-*/
         var_accepted := true;
         rollback;

      elsif var_trn_error = true then

         /*-*/
         /* Set the transaction accepted indicator and rollback the IDOC transaction
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
         /* Execute the interface monitor/flattening
         /* **note** - savepoint is established to ensure IDOC transaction commit
         /*          - child procedure can see IDOC transaction data as part of same commit cycle
         /*          - child procedure must NOT issue commit/rollback
         /*          - child procedure must raise an exception on failure
         /*          - update the LADS flattened flag on success
         /*          - savepoint is used for child procedure failure
         /*-*/
         savepoint transaction_savepoint;
         begin
            lads_atllad30_monitor.execute_before(rcd_lads_far_hdr.BELNR);
         exception
            when others then
               rollback to transaction_savepoint;
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;

         /*-*/
         /* Commit the IDOC transaction and successful monitor code
         /* **note** - releases transaction lock
         /*-*/
         commit;
         
         begin
            lads_atllad30_monitor.execute_after(rcd_lads_far_hdr.BELNR);
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
      var_idoc_timestamp lads_far_hdr.idoc_timestamp%type;

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
     rcd_lads_far_hdr.belnr := lics_inbound_utility.get_variable('BELNR');
     rcd_lads_far_hdr.bukrs := lics_inbound_utility.get_variable('BUKRS');
     rcd_lads_far_hdr.gjahr := lics_inbound_utility.get_number('GJAHR', null );
     rcd_lads_far_hdr.blart := lics_inbound_utility.get_variable('BLART');
     rcd_lads_far_hdr.bldat := lics_inbound_utility.get_variable('BLDAT');
     rcd_lads_far_hdr.budat := lics_inbound_utility.get_variable('BUDAT');
     rcd_lads_far_hdr.monat := lics_inbound_utility.get_number('MONAT',null);
     rcd_lads_far_hdr.wwert := lics_inbound_utility.get_variable('WWERT');
     rcd_lads_far_hdr.usnam := lics_inbound_utility.get_variable('USNAM');
     rcd_lads_far_hdr.tcode := lics_inbound_utility.get_variable('TCODE');
     rcd_lads_far_hdr.bvorg := lics_inbound_utility.get_variable('BVORG');
     rcd_lads_far_hdr.xblnr := lics_inbound_utility.get_variable('XBLNR');
     rcd_lads_far_hdr.bktxt := lics_inbound_utility.get_variable('BKTXT');
     rcd_lads_far_hdr.waers := lics_inbound_utility.get_variable('WAERS');
     rcd_lads_far_hdr.kursf := lics_inbound_utility.get_number('KURSF',null);
     rcd_lads_far_hdr.glvor := lics_inbound_utility.get_variable('GLVOR');
     rcd_lads_far_hdr.awtyp := lics_inbound_utility.get_variable('AWTYP');
     rcd_lads_far_hdr.awref := lics_inbound_utility.get_variable('AWREF');
     rcd_lads_far_hdr.aworg := lics_inbound_utility.get_variable('AWORG');
     rcd_lads_far_hdr.fikrs := lics_inbound_utility.get_variable('FIKRS');
     rcd_lads_far_hdr.hwaer := lics_inbound_utility.get_variable('HWAER');
     rcd_lads_far_hdr.hwae2 := lics_inbound_utility.get_variable('HWAE2');
     rcd_lads_far_hdr.hwae3 := lics_inbound_utility.get_variable('HWAE3');
     rcd_lads_far_hdr.kurs2 := lics_inbound_utility.get_number('KURS2',null);
     rcd_lads_far_hdr.kurs3 := lics_inbound_utility.get_number('KURS3',null);
     rcd_lads_far_hdr.basw2 := lics_inbound_utility.get_variable('BASW2');
     rcd_lads_far_hdr.basw3 := lics_inbound_utility.get_variable('BASW3');
     rcd_lads_far_hdr.umrd2 := lics_inbound_utility.get_variable('UMRD2');
     rcd_lads_far_hdr.umrd3 := lics_inbound_utility.get_variable('UMRD3');
     rcd_lads_far_hdr.curt2 := lics_inbound_utility.get_variable('CURT2');
     rcd_lads_far_hdr.curt3 := lics_inbound_utility.get_variable('CURT3');
     rcd_lads_far_hdr.ausbk := lics_inbound_utility.get_variable('AUSBK');
     rcd_lads_far_hdr.awsys := lics_inbound_utility.get_variable('AWSYS');
     rcd_lads_far_hdr.lotkz := lics_inbound_utility.get_variable('LOTKZ');
     rcd_lads_far_hdr.bukrs_snd := lics_inbound_utility.get_variable('BUKRS_SND');
     rcd_lads_far_hdr.filter := lics_inbound_utility.get_variable('FILTER');
     rcd_lads_far_hdr.kursf_m := lics_inbound_utility.get_variable('KURSF_M');
     rcd_lads_far_hdr.kurs2_m := lics_inbound_utility.get_variable('KURS2_M');
     rcd_lads_far_hdr.kurs3_m := lics_inbound_utility.get_variable('KURS3_M');
     rcd_lads_far_hdr.bstat := lics_inbound_utility.get_variable('BSTAT');
     rcd_lads_far_hdr.brnch := lics_inbound_utility.get_variable('BRNCH');
     rcd_lads_far_hdr.numpg := lics_inbound_utility.get_number('NUMPG',null);
     rcd_lads_far_hdr.adisc := lics_inbound_utility.get_variable('ADISC');
     rcd_lads_far_hdr.stblg := lics_inbound_utility.get_variable('STBLG');
     rcd_lads_far_hdr.stjah := lics_inbound_utility.get_number('STJAH',null);
     rcd_lads_far_hdr.awtyp_rev := lics_inbound_utility.get_variable('AWTYP_REV');
     rcd_lads_far_hdr.idoc_name := rcd_lads_control.idoc_name;
     rcd_lads_far_hdr.idoc_number := rcd_lads_control.idoc_number;
     rcd_lads_far_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
     rcd_lads_far_hdr.lads_date := sysdate;
     rcd_lads_far_hdr.lads_status := '1';
     rcd_lads_far_hdr.lads_flattened := '0';

       /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_far_det.detseq := 0;
      rcd_lads_far_tax.taxseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_far_hdr.BELNR is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BELNR');
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
      /* Lock the IDOC transaction
      /* **note** - attempt to lock the transaction header row (oracle default wait behaviour)
      /*              - insert/insert (not exists) - first holds lock and second fails on first commit with duplicate index
      /*              - update/update (exists) - logic goes to update and default wait behaviour
      /*          - validate the IDOC sequence when locking row exists
      /*          - lock and commit cycle encompasses transaction child procedure execution
      /*-*/
      begin
       insert into lads_far_hdr
       (belnr,
       bukrs,
       gjahr,
       blart,
       bldat,
       budat,
       monat,
       wwert,
       usnam,
       tcode,
       bvorg,
       xblnr,
       bktxt,
       waers,
       kursf,
       glvor,
       awtyp,
       awref,
       aworg,
       fikrs,
       hwaer,
       hwae2,
       hwae3,
       kurs2,
       kurs3,
       basw2,
       basw3,
       umrd2,
       umrd3,
       curt2,
       curt3,
       ausbk,
       awsys,
       lotkz,
       bukrs_snd,
       filter,
       kursf_m,
       kurs2_m,
       kurs3_m,
       bstat,
       brnch,
       numpg,
       adisc,
       stblg,
       stjah,
       awtyp_rev,
       awref_rev,
       aworg_rev,
       reserve,
       xref1_hd,
       xref2_hd,
       xblnr_long,
       lads_status,
       lads_flattened,
       idoc_name,
       idoc_number,
       lads_date,
       idoc_timestamp)
      values
       (rcd_lads_far_hdr.belnr,
        rcd_lads_far_hdr.bukrs,
        rcd_lads_far_hdr.gjahr,
        rcd_lads_far_hdr.blart,
        rcd_lads_far_hdr.bldat,
        rcd_lads_far_hdr.budat,
        rcd_lads_far_hdr.monat,
        rcd_lads_far_hdr.wwert,
        rcd_lads_far_hdr.usnam,
        rcd_lads_far_hdr.tcode,
        rcd_lads_far_hdr.bvorg,
        rcd_lads_far_hdr.xblnr,
        rcd_lads_far_hdr.bktxt,
        rcd_lads_far_hdr.waers,
        rcd_lads_far_hdr.kursf,
        rcd_lads_far_hdr.glvor,
        rcd_lads_far_hdr.awtyp,
        rcd_lads_far_hdr.awref,
        rcd_lads_far_hdr.aworg,
        rcd_lads_far_hdr.fikrs,
        rcd_lads_far_hdr.hwaer,
        rcd_lads_far_hdr.hwae2,
        rcd_lads_far_hdr.hwae3,
        rcd_lads_far_hdr.kurs2,
        rcd_lads_far_hdr.kurs3,
        rcd_lads_far_hdr.basw2,
        rcd_lads_far_hdr.basw3,
        rcd_lads_far_hdr.umrd2,
        rcd_lads_far_hdr.umrd3,
        rcd_lads_far_hdr.curt2,
        rcd_lads_far_hdr.curt3,
        rcd_lads_far_hdr.ausbk,
        rcd_lads_far_hdr.awsys,
        rcd_lads_far_hdr.lotkz,
        rcd_lads_far_hdr.bukrs_snd,
        rcd_lads_far_hdr.filter,
        rcd_lads_far_hdr.kursf_m,
        rcd_lads_far_hdr.kurs2_m,
        rcd_lads_far_hdr.kurs3_m,
        rcd_lads_far_hdr.bstat,
        rcd_lads_far_hdr.brnch,
        rcd_lads_far_hdr.numpg,
        rcd_lads_far_hdr.adisc,
        rcd_lads_far_hdr.stblg,
        rcd_lads_far_hdr.stjah,
        rcd_lads_far_hdr.awtyp_rev,
        rcd_lads_far_hdr.awref_rev,
        rcd_lads_far_hdr.aworg_rev,
        rcd_lads_far_hdr.reserve,
        rcd_lads_far_hdr.xref1_hd,
        rcd_lads_far_hdr.xref2_hd,
        rcd_lads_far_hdr.xblnr_long,
        rcd_lads_far_hdr.lads_status,
        rcd_lads_far_hdr.lads_flattened,
        rcd_lads_far_hdr.idoc_name,
        rcd_lads_far_hdr.idoc_number,
        rcd_lads_far_hdr.lads_date,
        rcd_lads_far_hdr.idoc_timestamp);
      exception
         when dup_val_on_index then
            update lads_far_hdr
               set lads_status = lads_status
             where belnr = rcd_lads_far_hdr.belnr
             returning idoc_timestamp into var_idoc_timestamp;
            if sql%found and var_idoc_timestamp <= rcd_lads_far_hdr.idoc_timestamp then
                 delete from lads_far_led where belnr = rcd_lads_far_hdr.belnr;
		 delete from lads_far_tax where belnr = rcd_lads_far_hdr.belnr;
                 delete from lads_far_det where belnr = rcd_lads_far_hdr.belnr;
               
               
               
            else
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
      update lads_far_hdr set
         idoc_name = rcd_lads_far_hdr.idoc_name,
         idoc_number = rcd_lads_far_hdr.idoc_number,
         idoc_timestamp = rcd_lads_far_hdr.idoc_timestamp,
         lads_date = rcd_lads_far_hdr.lads_date,
         lads_status = rcd_lads_far_hdr.lads_status,
         lads_flattened = rcd_lads_far_hdr.lads_flattened
      where belnr = rcd_lads_far_hdr.belnr;

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
      rcd_lads_far_det.belnr:= rcd_lads_far_hdr.belnr;
      rcd_lads_far_det.buzei:= lics_inbound_utility.get_variable('BUZEI');
      rcd_lads_far_det.buzid:= lics_inbound_utility.get_variable('BUZID');
      rcd_lads_far_det.augdt:= lics_inbound_utility.get_variable('AUGDT');
      rcd_lads_far_det.augcp:= lics_inbound_utility.get_variable('AUGCP');
      rcd_lads_far_det.augbl:= lics_inbound_utility.get_variable('AUGBL');
      rcd_lads_far_det.bschl:= lics_inbound_utility.get_variable('BSCHL');
      rcd_lads_far_det.koart:= lics_inbound_utility.get_variable('KOART');
      rcd_lads_far_det.shkzg:= lics_inbound_utility.get_variable('SHKZG');
      rcd_lads_far_det.gsber:= lics_inbound_utility.get_variable('GSBER');
      rcd_lads_far_det.pargb:= lics_inbound_utility.get_variable('PARGB');
      rcd_lads_far_det.mwskz:= lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_far_det.dmbtr:= lics_inbound_utility.get_variable('DMBTR');
      rcd_lads_far_det.dmbe2:= lics_inbound_utility.get_variable('DMBE2');
      rcd_lads_far_det.dmbe3:= lics_inbound_utility.get_variable('DMBE3');
      rcd_lads_far_det.wrbtr:= lics_inbound_utility.get_variable('WRBTR');
      rcd_lads_far_det.kzbtr:= lics_inbound_utility.get_variable('KZBTR');
      rcd_lads_far_det.pswbt:= lics_inbound_utility.get_variable('PSWBT');
      rcd_lads_far_det.pswsl:= lics_inbound_utility.get_variable('PSWSL');
      rcd_lads_far_det.hwbas:= lics_inbound_utility.get_variable('HWBAS');
      rcd_lads_far_det.fwbas:= lics_inbound_utility.get_variable('FWBAS');
      rcd_lads_far_det.mwart:= lics_inbound_utility.get_variable('MWART');
      rcd_lads_far_det.ktosl:= lics_inbound_utility.get_variable('KTOSL');
      rcd_lads_far_det.valut:= lics_inbound_utility.get_variable('VALUT');
      rcd_lads_far_det.zuonr:= lics_inbound_utility.get_variable('ZUONR');
      rcd_lads_far_det.sgtxt:= lics_inbound_utility.get_variable('SGTXT');
      rcd_lads_far_det.vbund:= lics_inbound_utility.get_variable('VBUND');
      rcd_lads_far_det.bewar:= lics_inbound_utility.get_variable('BEWAR');
      rcd_lads_far_det.vorgn:= lics_inbound_utility.get_variable('VORGN');
      rcd_lads_far_det.fdlev:= lics_inbound_utility.get_variable('FDLEV');
      rcd_lads_far_det.fdgrp:= lics_inbound_utility.get_variable('FDGRP');
      rcd_lads_far_det.fdtag:= lics_inbound_utility.get_variable('FDTAG');
      rcd_lads_far_det.kokrs:= lics_inbound_utility.get_variable('KOKRS');
      rcd_lads_far_det.txgrp:= lics_inbound_utility.get_number('TXGRP',null);
      rcd_lads_far_det.kostl:= lics_inbound_utility.get_variable('KOSTL');
      rcd_lads_far_det.aufnr:= lics_inbound_utility.get_variable('AUFNR');
      rcd_lads_far_det.vbeln:= lics_inbound_utility.get_variable('VBELN');
      rcd_lads_far_det.vbel2:= lics_inbound_utility.get_variable('VBEL2');
      rcd_lads_far_det.posn2:= lics_inbound_utility.get_number('POSN2',null);
      rcd_lads_far_det.anln1:= lics_inbound_utility.get_variable('ANLN1');
      rcd_lads_far_det.anln2:= lics_inbound_utility.get_variable('ANLN2');
      rcd_lads_far_det.anbwa:= lics_inbound_utility.get_variable('ANBWA');
      rcd_lads_far_det.bzdat:= lics_inbound_utility.get_variable('BZDAT');
      rcd_lads_far_det.pernr:= lics_inbound_utility.get_number('PERNR',null);
      rcd_lads_far_det.xumsw:= lics_inbound_utility.get_variable('XUMSW');
      rcd_lads_far_det.xskrl:= lics_inbound_utility.get_variable('XSKRL');
      rcd_lads_far_det.xauto:= lics_inbound_utility.get_variable('XAUTO');
      rcd_lads_far_det.saknr:= lics_inbound_utility.get_variable('SAKNR');
      rcd_lads_far_det.hkont:= lics_inbound_utility.get_variable('HKONT');
      rcd_lads_far_det.abper:= lics_inbound_utility.get_variable('ABPER');
      rcd_lads_far_det.matnr:= lics_inbound_utility.get_variable('MATNR');
      rcd_lads_far_det.werks:= lics_inbound_utility.get_variable('WERKS');
      rcd_lads_far_det.menge:= lics_inbound_utility.get_number('MENGE',null);
      rcd_lads_far_det.meins:= lics_inbound_utility.get_variable('MEINS');
      rcd_lads_far_det.erfmg:= lics_inbound_utility.get_number('ERFMG',null);
      rcd_lads_far_det.erfme:= lics_inbound_utility.get_number('ERFME',null);
      rcd_lads_far_det.bpmng:= lics_inbound_utility.get_number('BPMNG',null);
      rcd_lads_far_det.bprme:= lics_inbound_utility.get_number('BPRME',null);
      rcd_lads_far_det.ebeln:= lics_inbound_utility.get_variable('EBELN');
      rcd_lads_far_det.ebelp:= lics_inbound_utility.get_number('EBELP',null);
      rcd_lads_far_det.zekkn:= lics_inbound_utility.get_number('ZEKKN',null);
      rcd_lads_far_det.bwkey:= lics_inbound_utility.get_variable('BWKEY');
      rcd_lads_far_det.bwtar:= lics_inbound_utility.get_variable('BWTAR');
      rcd_lads_far_det.bustw:= lics_inbound_utility.get_variable('BUSTW');
      rcd_lads_far_det.bualt:= lics_inbound_utility.get_variable('BUALT');
      rcd_lads_far_det.tbtkz:= lics_inbound_utility.get_variable('TBTKZ');
      rcd_lads_far_det.stceg:= lics_inbound_utility.get_variable('STCEG');
      rcd_lads_far_det.rstgr:= lics_inbound_utility.get_variable('RSTGR');
      rcd_lads_far_det.prctr:= lics_inbound_utility.get_variable('PRCTR');
      rcd_lads_far_det.vname:= lics_inbound_utility.get_variable('VNAME');
      rcd_lads_far_det.recid:= lics_inbound_utility.get_variable('RECID');
      rcd_lads_far_det.egrup:= lics_inbound_utility.get_variable('EGRUP');
      rcd_lads_far_det.vptnr:= lics_inbound_utility.get_variable('VPTNR');
      rcd_lads_far_det.vertt:= lics_inbound_utility.get_variable('VERTT');
      rcd_lads_far_det.vertn:= lics_inbound_utility.get_variable('VERTN');
      rcd_lads_far_det.vbewa:= lics_inbound_utility.get_variable('VBEWA');
      rcd_lads_far_det.txjcd:= lics_inbound_utility.get_variable('TXJCD');
      rcd_lads_far_det.imkey:= lics_inbound_utility.get_variable('IMKEY');
      rcd_lads_far_det.dabrz:= lics_inbound_utility.get_variable('DABRZ');
      rcd_lads_far_det.fipos:= lics_inbound_utility.get_variable('FIPOS');
      rcd_lads_far_det.kstrg:= lics_inbound_utility.get_variable('KSTRG');
      rcd_lads_far_det.nplnr:= lics_inbound_utility.get_variable('NPLNR');
      rcd_lads_far_det.aufpl:= lics_inbound_utility.get_number('AUFPL',null);
      rcd_lads_far_det.aplzl:= lics_inbound_utility.get_number('APLZL',null);
      rcd_lads_far_det.projk:= lics_inbound_utility.get_number('PROJK',null);
      rcd_lads_far_det.paobjnr:= lics_inbound_utility.get_number('PAOBJNR',null);
      rcd_lads_far_det.btype:= lics_inbound_utility.get_variable('BTYPE');
      rcd_lads_far_det.etype:= lics_inbound_utility.get_variable('ETYPE');
      rcd_lads_far_det.xegdr:= lics_inbound_utility.get_variable('XEGDR');
      rcd_lads_far_det.hrkft:= lics_inbound_utility.get_variable('HRKFT');
      rcd_lads_far_det.lokkt:= lics_inbound_utility.get_variable('LOKKT');
      rcd_lads_far_det.fistl:= lics_inbound_utility.get_variable('FISTL');
      rcd_lads_far_det.geber:= lics_inbound_utility.get_variable('GEBER');
      rcd_lads_far_det.stbuk:= lics_inbound_utility.get_variable('STBUK');
      rcd_lads_far_det.altkt:= lics_inbound_utility.get_variable('ALTKT');
      rcd_lads_far_det.pprct:= lics_inbound_utility.get_variable('PPRCT');
      rcd_lads_far_det.xref1:= lics_inbound_utility.get_variable('XREF1');
      rcd_lads_far_det.xref2:= lics_inbound_utility.get_variable('XREF2');
      rcd_lads_far_det.kblnr:= lics_inbound_utility.get_variable('KBLNR');
      rcd_lads_far_det.kblpos:= lics_inbound_utility.get_number('KBLPOS',null);
      rcd_lads_far_det.fkber:= lics_inbound_utility.get_variable('FKBER');
      rcd_lads_far_det.obzei:= lics_inbound_utility.get_number('OBZEI',null);
      rcd_lads_far_det.xnegp:= lics_inbound_utility.get_variable('XNEGP');
      rcd_lads_far_det.cacct:= lics_inbound_utility.get_variable('CACCT');
      rcd_lads_far_det.xref3:= lics_inbound_utility.get_variable('XREF3');
      rcd_lads_far_det.txdat:= lics_inbound_utility.get_variable('TXDAT');
      rcd_lads_far_det.bupla:= lics_inbound_utility.get_variable('BUPLA');
      rcd_lads_far_det.secco:= lics_inbound_utility.get_variable('SECCO');
      rcd_lads_far_det.lstar:= lics_inbound_utility.get_variable('LSTAR');
      rcd_lads_far_det.prznr:= lics_inbound_utility.get_variable('PRZNR');
      rcd_lads_far_det.kursr:= lics_inbound_utility.get_variable('KURSR');
      rcd_lads_far_det.kursr_m:= lics_inbound_utility.get_variable('KURSR_M');
      rcd_lads_far_det.gbetr:= lics_inbound_utility.get_variable('GBETR');
      rcd_lads_far_det.reserve:= lics_inbound_utility.get_variable('RESERVE');
      rcd_lads_far_det.xcpdd:= lics_inbound_utility.get_variable('XCPDD');
      rcd_lads_far_det.detseq := rcd_lads_far_det.detseq + 1;

      /*-*/
      /* retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
     
      
       /*-*/
       /* Reset child sequences
       /*-*/
       rcd_lads_far_led.ledseq := 0;


      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_far_det.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.BELNR');
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
      insert into lads_far_det      
      (belnr,
       detseq,
       buzei,
       buzid,
       augdt,
       augcp,
       augbl,
       bschl,
       koart,
       shkzg,
       gsber,
       pargb,
       mwskz,
       dmbtr,
       dmbe2,
       dmbe3,
       wrbtr,
       kzbtr,
       pswbt,
       pswsl,
       hwbas,
       fwbas,
       mwart,
       ktosl,
       valut,
       zuonr,
       sgtxt,
       vbund,
       bewar,
       vorgn,
       fdlev,
       fdgrp,
       fdtag,
       kokrs,
       txgrp,
       kostl,
       aufnr,
       vbeln,
       vbel2,
       posn2,
       anln1,
       anln2,
       anbwa,
       bzdat,
       pernr,
       xumsw,
       xskrl,
       xauto,
       saknr,
       hkont,
       abper,
       matnr,
       werks,
       menge,
       meins,
       erfmg,
       erfme,
       bpmng,
       bprme,
       ebeln,
       ebelp,
       zekkn,
       bwkey,
       bwtar,
       bustw,
       bualt,
       tbtkz,
       stceg,
       rstgr,
       prctr,
       vname,
       recid,
       egrup,
       vptnr,
       vertt,
       vertn,
       vbewa,
       txjcd,
       imkey,
       dabrz,
       fipos,
       kstrg,
       nplnr,
       aufpl,
       aplzl,
       projk,
       paobjnr,
       btype,
       etype,
       xegdr,
       hrkft,
       lokkt,
       fistl,
       geber,
       stbuk,
       altkt,
       pprct,
       xref1,
       xref2,
       kblnr,
       kblpos,
       fkber,
       obzei,
       xnegp,
       cacct,
       xref3,
       txdat,
       bupla,
       secco,
       lstar,
       prznr,
       kursr,
       kursr_m,
       gbetr,
       reserve,
       xcpdd)
      values
      (rcd_lads_far_det.belnr,
        rcd_lads_far_det.detseq,
        rcd_lads_far_det.buzei,
        rcd_lads_far_det.buzid,
        rcd_lads_far_det.augdt,
        rcd_lads_far_det.augcp,
        rcd_lads_far_det.augbl,
        rcd_lads_far_det.bschl,
        rcd_lads_far_det.koart,
        rcd_lads_far_det.shkzg,
        rcd_lads_far_det.gsber,
        rcd_lads_far_det.pargb,
        rcd_lads_far_det.mwskz,
        rcd_lads_far_det.dmbtr,
        rcd_lads_far_det.dmbe2,
        rcd_lads_far_det.dmbe3,
        rcd_lads_far_det.wrbtr,
        rcd_lads_far_det.kzbtr,
        rcd_lads_far_det.pswbt,
        rcd_lads_far_det.pswsl,
        rcd_lads_far_det.hwbas,
        rcd_lads_far_det.fwbas,
        rcd_lads_far_det.mwart,
        rcd_lads_far_det.ktosl,
        rcd_lads_far_det.valut,
        rcd_lads_far_det.zuonr,
        rcd_lads_far_det.sgtxt,
        rcd_lads_far_det.vbund,
        rcd_lads_far_det.bewar,
        rcd_lads_far_det.vorgn,
        rcd_lads_far_det.fdlev,
        rcd_lads_far_det.fdgrp,
        rcd_lads_far_det.fdtag,
        rcd_lads_far_det.kokrs,
        rcd_lads_far_det.txgrp,
        rcd_lads_far_det.kostl,
        rcd_lads_far_det.aufnr,
        rcd_lads_far_det.vbeln,
        rcd_lads_far_det.vbel2,
        rcd_lads_far_det.posn2,
        rcd_lads_far_det.anln1,
        rcd_lads_far_det.anln2,
        rcd_lads_far_det.anbwa,
        rcd_lads_far_det.bzdat,
        rcd_lads_far_det.pernr,
        rcd_lads_far_det.xumsw,
        rcd_lads_far_det.xskrl,
        rcd_lads_far_det.xauto,
        rcd_lads_far_det.saknr,
        rcd_lads_far_det.hkont,
        rcd_lads_far_det.abper,
        rcd_lads_far_det.matnr,
        rcd_lads_far_det.werks,
        rcd_lads_far_det.menge,
        rcd_lads_far_det.meins,
        rcd_lads_far_det.erfmg,
        rcd_lads_far_det.erfme,
        rcd_lads_far_det.bpmng,
        rcd_lads_far_det.bprme,
        rcd_lads_far_det.ebeln,
        rcd_lads_far_det.ebelp,
        rcd_lads_far_det.zekkn,
        rcd_lads_far_det.bwkey,
        rcd_lads_far_det.bwtar,
        rcd_lads_far_det.bustw,
        rcd_lads_far_det.bualt,
        rcd_lads_far_det.tbtkz,
        rcd_lads_far_det.stceg,
        rcd_lads_far_det.rstgr,
        rcd_lads_far_det.prctr,
        rcd_lads_far_det.vname,
        rcd_lads_far_det.recid,
        rcd_lads_far_det.egrup,
        rcd_lads_far_det.vptnr,
        rcd_lads_far_det.vertt,
        rcd_lads_far_det.vertn,
        rcd_lads_far_det.vbewa,
        rcd_lads_far_det.txjcd,
        rcd_lads_far_det.imkey,
        rcd_lads_far_det.dabrz,
        rcd_lads_far_det.fipos,
        rcd_lads_far_det.kstrg,
        rcd_lads_far_det.nplnr,
        rcd_lads_far_det.aufpl,
        rcd_lads_far_det.aplzl,
        rcd_lads_far_det.projk,
        rcd_lads_far_det.paobjnr,
        rcd_lads_far_det.btype,
        rcd_lads_far_det.etype,
        rcd_lads_far_det.xegdr,
        rcd_lads_far_det.hrkft,
        rcd_lads_far_det.lokkt,
        rcd_lads_far_det.fistl,
        rcd_lads_far_det.geber,
        rcd_lads_far_det.stbuk,
        rcd_lads_far_det.altkt,
        rcd_lads_far_det.pprct,
        rcd_lads_far_det.xref1,
        rcd_lads_far_det.xref2,
        rcd_lads_far_det.kblnr,
        rcd_lads_far_det.kblpos,
        rcd_lads_far_det.fkber,
        rcd_lads_far_det.obzei,
        rcd_lads_far_det.xnegp,
        rcd_lads_far_det.cacct,
        rcd_lads_far_det.xref3,
        rcd_lads_far_det.txdat,
        rcd_lads_far_det.bupla,
        rcd_lads_far_det.secco,
        rcd_lads_far_det.lstar,
        rcd_lads_far_det.prznr,
        rcd_lads_far_det.kursr,
        rcd_lads_far_det.kursr_m,
        rcd_lads_far_det.gbetr,
        rcd_lads_far_det.reserve,
        rcd_lads_far_det.xcpdd);
   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record LED routine */
   /**************************************************/
   procedure process_record_led(par_record  in varchar2) is
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

      lics_inbound_utility.parse_record('LED', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_far_led.belnr:= rcd_lads_far_det.belnr;
      rcd_lads_far_led.detseq:= rcd_lads_far_det.detseq;
      rcd_lads_far_led.umskz:= lics_inbound_utility.get_variable('UMSKZ');
      rcd_lads_far_led.mwsts:= lics_inbound_utility.get_variable('MWSTS');
      rcd_lads_far_led.wmwst:= lics_inbound_utility.get_variable('WMWST');
      rcd_lads_far_led.kunnr:= lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_far_led.filkd:= lics_inbound_utility.get_variable('FILKD');
      rcd_lads_far_led.zfbdt:= lics_inbound_utility.get_variable('ZFBDT');
      rcd_lads_far_led.zterm:= lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_far_led.zbd1t:= lics_inbound_utility.get_variable('ZBD1T');
      rcd_lads_far_led.zbd2t:= lics_inbound_utility.get_variable('ZBD2T');
      rcd_lads_far_led.zbd3t:= lics_inbound_utility.get_variable('ZBD3T');
      rcd_lads_far_led.zbd1p:= lics_inbound_utility.get_variable('ZBD1P');
      rcd_lads_far_led.zbd2p:= lics_inbound_utility.get_variable('ZBD2P');
      rcd_lads_far_led.skfbt:= lics_inbound_utility.get_variable('SKFBT');
      rcd_lads_far_led.sknto:= lics_inbound_utility.get_variable('SKNTO');
      rcd_lads_far_led.wskto:= lics_inbound_utility.get_variable('WSKTO');
      rcd_lads_far_led.zlsch:= lics_inbound_utility.get_variable('ZLSCH');
      rcd_lads_far_led.zlspr:= lics_inbound_utility.get_variable('ZLSPR');
      rcd_lads_far_led.uzawe:= lics_inbound_utility.get_variable('UZAWE');
      rcd_lads_far_led.hbkid:= lics_inbound_utility.get_variable('HBKID');
      rcd_lads_far_led.bvtyp:= lics_inbound_utility.get_variable('BVTYP');
      rcd_lads_far_led.rebzg:= lics_inbound_utility.get_variable('REBZG');
      rcd_lads_far_led.rebzj:= lics_inbound_utility.get_number('REBZJ',null);
      rcd_lads_far_led.rebzz:= lics_inbound_utility.get_number('REBZZ',null);
      rcd_lads_far_led.rebzt:= lics_inbound_utility.get_variable('REBZT');
      rcd_lads_far_led.lzbkz:= lics_inbound_utility.get_variable('LZBKZ');
      rcd_lads_far_led.landl:= lics_inbound_utility.get_variable('LANDL');
      rcd_lads_far_led.diekz:= lics_inbound_utility.get_variable('DIEKZ');
      rcd_lads_far_led.vrskz:= lics_inbound_utility.get_variable('VRSKZ');
      rcd_lads_far_led.vrsdt:= lics_inbound_utility.get_variable('VRSDT');
      rcd_lads_far_led.mschl:= lics_inbound_utility.get_variable('MSCHL');
      rcd_lads_far_led.mansp:= lics_inbound_utility.get_variable('MANSP');
      rcd_lads_far_led.maber:= lics_inbound_utility.get_variable('MABER');
      rcd_lads_far_led.madat:= lics_inbound_utility.get_variable('MADAT');
      rcd_lads_far_led.manst:= lics_inbound_utility.get_variable('MANST');
      rcd_lads_far_led.qsskz:= lics_inbound_utility.get_variable('QSSKZ');
      rcd_lads_far_led.qsshb:= lics_inbound_utility.get_variable('QSSHB');
      rcd_lads_far_led.qsfbt:= lics_inbound_utility.get_variable('QSFBT');
      rcd_lads_far_led.lifnr:= lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_far_led.esrnr:= lics_inbound_utility.get_variable('ESRNR');
      rcd_lads_far_led.esrre:= lics_inbound_utility.get_variable('ESRRE');
      rcd_lads_far_led.esrpz:= lics_inbound_utility.get_variable('ESRPZ');
      rcd_lads_far_led.zbfix:= lics_inbound_utility.get_variable('ZBFIX');
      rcd_lads_far_led.kidno:= lics_inbound_utility.get_variable('KIDNO');
      rcd_lads_far_led.empfb:= lics_inbound_utility.get_variable('EMPFB');
      rcd_lads_far_led.sknt2:= lics_inbound_utility.get_variable('SKNT2');
      rcd_lads_far_led.sknt3:= lics_inbound_utility.get_variable('SKNT3');
      rcd_lads_far_led.pycur:= lics_inbound_utility.get_variable('PYCUR');
      rcd_lads_far_led.pyamt:= lics_inbound_utility.get_variable('PYAMT');
      rcd_lads_far_led.kkber:= lics_inbound_utility.get_variable('KKBER');
      rcd_lads_far_led.absbt:= lics_inbound_utility.get_variable('ABSBT');
      rcd_lads_far_led.zumsk:= lics_inbound_utility.get_variable('ZUMSK');
      rcd_lads_far_led.cession_kz:= lics_inbound_utility.get_variable('CESSION_KZ');
      rcd_lads_far_led.dtws1:= lics_inbound_utility.get_number('DTWS1',null);
      rcd_lads_far_led.dtws2:= lics_inbound_utility.get_number('DTWS2',null);
      rcd_lads_far_led.dtws3:= lics_inbound_utility.get_number('DTWS3',null);
      rcd_lads_far_led.dtws4:= lics_inbound_utility.get_number('DTWS4',null);
      rcd_lads_far_led.awtyp_reb:= lics_inbound_utility.get_variable('AWTYP_REB');
      rcd_lads_far_led.awref_reb:= lics_inbound_utility.get_variable('AWREF_REB');
      rcd_lads_far_led.aworg_reb:= lics_inbound_utility.get_variable('AWORG_REB');
      rcd_lads_far_led.reserve:= lics_inbound_utility.get_variable('RESERVE');
      rcd_lads_far_led.ledseq := rcd_lads_far_led.ledseq + 1;   
   
 
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
      if rcd_lads_far_led.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LED.BELNR');
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
       insert into lads_far_led
        (belnr,
        detseq,
        ledseq,
        umskz,
        mwsts,
        wmwst,
        kunnr,
        filkd,
        zfbdt,
        zterm,
        zbd1t,
        zbd2t,
        zbd3t,
        zbd1p,
        zbd2p,
        skfbt,
        sknto,
        wskto,
        zlsch,
        zlspr,
        uzawe,
        hbkid,
        bvtyp,
        rebzg,
        rebzj,
        rebzz,
        rebzt,
        lzbkz,
        landl,
        diekz,
        vrskz,
        vrsdt,
        mschl,
        mansp,
        maber,
        madat,
        qsskz,
        qsshb,
        qsfbt,
        lifnr,
        esrnr,
        esrre,
        esrpz,
        zbfix,
        kidno,
        empfb,
        sknt2,
        sknt3,
        pycur,
        pyamt,
        kkber,
        absbt,
        zumsk,
        cession_kz,
        dtws1,
        dtws2,
        dtws3,
        dtws4,
        awtyp_reb,
        awref_reb,
        aworg_reb,
        reserve)
       values
        (rcd_lads_far_led.belnr,
        rcd_lads_far_led.detseq,
        rcd_lads_far_led.ledseq,
        rcd_lads_far_led.umskz,
        rcd_lads_far_led.mwsts,
        rcd_lads_far_led.wmwst,
        rcd_lads_far_led.kunnr,
        rcd_lads_far_led.filkd,
        rcd_lads_far_led.zfbdt,
        rcd_lads_far_led.zterm,
        rcd_lads_far_led.zbd1t,
        rcd_lads_far_led.zbd2t,
        rcd_lads_far_led.zbd3t,
        rcd_lads_far_led.zbd1p,
        rcd_lads_far_led.zbd2p,
        rcd_lads_far_led.skfbt,
        rcd_lads_far_led.sknto,
        rcd_lads_far_led.wskto,
        rcd_lads_far_led.zlsch,
        rcd_lads_far_led.zlspr,
        rcd_lads_far_led.uzawe,
        rcd_lads_far_led.hbkid,
        rcd_lads_far_led.bvtyp,
        rcd_lads_far_led.rebzg,
        rcd_lads_far_led.rebzj,
        rcd_lads_far_led.rebzz,
        rcd_lads_far_led.rebzt,
        rcd_lads_far_led.lzbkz,
        rcd_lads_far_led.landl,
        rcd_lads_far_led.diekz,
        rcd_lads_far_led.vrskz,
        rcd_lads_far_led.vrsdt,
        rcd_lads_far_led.mschl,
        rcd_lads_far_led.mansp,
        rcd_lads_far_led.maber,
        rcd_lads_far_led.madat,
        rcd_lads_far_led.qsskz,
        rcd_lads_far_led.qsshb,
        rcd_lads_far_led.qsfbt,
        rcd_lads_far_led.lifnr,
        rcd_lads_far_led.esrnr,
        rcd_lads_far_led.esrre,
        rcd_lads_far_led.esrpz,
        rcd_lads_far_led.zbfix,
        rcd_lads_far_led.kidno,
        rcd_lads_far_led.empfb,
        rcd_lads_far_led.sknt2,
        rcd_lads_far_led.sknt3,
        rcd_lads_far_led.pycur,
        rcd_lads_far_led.pyamt,
        rcd_lads_far_led.kkber,
        rcd_lads_far_led.absbt,
        rcd_lads_far_led.zumsk,
        rcd_lads_far_led.cession_kz,
        rcd_lads_far_led.dtws1,
        rcd_lads_far_led.dtws2,
        rcd_lads_far_led.dtws3,
        rcd_lads_far_led.dtws4,
        rcd_lads_far_led.awtyp_reb,
        rcd_lads_far_led.awref_reb,
        rcd_lads_far_led.aworg_reb,
        rcd_lads_far_led.reserve);
   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_led;
   
   /**************************************************/
   /* This procedure performs the record TAX routine */
   /**************************************************/
   procedure process_record_tax(par_record in varchar2) is

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
      lics_inbound_utility.parse_record('TAX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_far_tax.belnr:= rcd_lads_far_hdr.belnr;
      rcd_lads_far_tax.buzei:= lics_inbound_utility.get_variable('BUZEI');
      rcd_lads_far_tax.mwskz:= lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_far_tax.hkont:= lics_inbound_utility.get_variable('HKONT');
      rcd_lads_far_tax.txgrp:= lics_inbound_utility.get_variable('TXGRP');
      rcd_lads_far_tax.shkzg:= lics_inbound_utility.get_variable('SHKZG');
      rcd_lads_far_tax.hwbas:= lics_inbound_utility.get_variable('HWBAS');
      rcd_lads_far_tax.fwbas:= lics_inbound_utility.get_variable('FWBAS');
      rcd_lads_far_tax.hwste:= lics_inbound_utility.get_variable('HWSTE');
      rcd_lads_far_tax.fwste:= lics_inbound_utility.get_variable('FWSTE');
      rcd_lads_far_tax.ktosl:= lics_inbound_utility.get_variable('KTOSL');
      rcd_lads_far_tax.knumh:= lics_inbound_utility.get_variable('KNUMH');
      rcd_lads_far_tax.stceg:= lics_inbound_utility.get_variable('STCEG');
      rcd_lads_far_tax.egbld:= lics_inbound_utility.get_variable('EGBLD');
      rcd_lads_far_tax.eglld:= lics_inbound_utility.get_variable('EGLLD');
      rcd_lads_far_tax.txjcd:= lics_inbound_utility.get_variable('TXJCD');
      rcd_lads_far_tax.h2ste:= lics_inbound_utility.get_variable('H2STE');
      rcd_lads_far_tax.h3ste:= lics_inbound_utility.get_variable('H3STE');
      rcd_lads_far_tax.h2bas:= lics_inbound_utility.get_variable('H2BAS');
      rcd_lads_far_tax.h3bas:= lics_inbound_utility.get_variable('H3BAS');
      rcd_lads_far_tax.kschl:= lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_far_tax.stmdt:= lics_inbound_utility.get_variable('STMDT');
      rcd_lads_far_tax.stmti:= lics_inbound_utility.get_variable('STMTI');
      rcd_lads_far_tax.mlddt:= lics_inbound_utility.get_variable('MLDDT');
      rcd_lads_far_tax.kbetr:= lics_inbound_utility.get_variable('KBETR');
      rcd_lads_far_tax.stbkz:= lics_inbound_utility.get_variable('STBKZ');
      rcd_lads_far_tax.lstml:= lics_inbound_utility.get_variable('LSTML');
      rcd_lads_far_tax.lwste:= lics_inbound_utility.get_variable('LWSTE');
      rcd_lads_far_tax.lwbas:= lics_inbound_utility.get_variable('LWBAS');
      rcd_lads_far_tax.txdat:= lics_inbound_utility.get_variable('TXDAT');
      rcd_lads_far_tax.bupla:= lics_inbound_utility.get_variable('BUPLA');
      rcd_lads_far_tax.txjdp:= lics_inbound_utility.get_variable('TXJDP');
      rcd_lads_far_tax.txjlv:= lics_inbound_utility.get_variable('TXJLV');
      rcd_lads_far_tax.reserve := lics_inbound_utility.get_variable('RESERVE');
      rcd_lads_far_tax.taxps:= lics_inbound_utility.get_variable('TAXPS');
      rcd_lads_far_tax.txmod:= lics_inbound_utility.get_variable('TXMOD');
      rcd_lads_far_tax.taxseq := rcd_lads_far_tax.taxseq + 1;

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
      if rcd_lads_far_tax.TAXSEQ is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TAX.TAXSEQ');
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

       insert into lads_far_tax     
         (belnr,
          taxseq,
          buzei,
          mwskz,
          hkont,
          txgrp,
          shkzg,
          hwbas,
          fwbas,
          hwste,
          fwste,
          ktosl,
          knumh,
          stceg,
          egbld,
          eglld,
          txjcd,
          h2ste,
          h3ste,
          h2bas,
          h3bas,
          kschl,
          stmdt,
          stmti,
          mlddt,
          kbetr,
          stbkz,
          lstml,
          lwste,
          lwbas,
          txdat,
          bupla,
          txjdp,
          txjlv,
          reserve,
          taxps,
          txmod)           
        values
         (rcd_lads_far_tax.belnr,
          rcd_lads_far_tax.taxseq,
          rcd_lads_far_tax.buzei,
          rcd_lads_far_tax.mwskz,
          rcd_lads_far_tax.hkont,
          rcd_lads_far_tax.txgrp,
          rcd_lads_far_tax.shkzg,
          rcd_lads_far_tax.hwbas,
          rcd_lads_far_tax.fwbas,
          rcd_lads_far_tax.hwste,
          rcd_lads_far_tax.fwste,
          rcd_lads_far_tax.ktosl,
          rcd_lads_far_tax.knumh,
          rcd_lads_far_tax.stceg,
          rcd_lads_far_tax.egbld,
          rcd_lads_far_tax.eglld,
          rcd_lads_far_tax.txjcd,
          rcd_lads_far_tax.h2ste,
          rcd_lads_far_tax.h3ste,
          rcd_lads_far_tax.h2bas,
          rcd_lads_far_tax.h3bas,
          rcd_lads_far_tax.kschl,
          rcd_lads_far_tax.stmdt,
          rcd_lads_far_tax.stmti,
          rcd_lads_far_tax.mlddt,
          rcd_lads_far_tax.kbetr,
          rcd_lads_far_tax.stbkz,
          rcd_lads_far_tax.lstml,
          rcd_lads_far_tax.lwste,
          rcd_lads_far_tax.lwbas,
          rcd_lads_far_tax.txdat,
          rcd_lads_far_tax.bupla,
          rcd_lads_far_tax.txjdp,
          rcd_lads_far_tax.txjlv,
          rcd_lads_far_tax.reserve,
          rcd_lads_far_tax.taxps,
          rcd_lads_far_tax.txmod);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tax;

end lads_atllad30;
/
create or replace public synonym lads_atllad30 for lads_app.lads_atllad30;
grant execute on lads_atllad30 to lics_app;
