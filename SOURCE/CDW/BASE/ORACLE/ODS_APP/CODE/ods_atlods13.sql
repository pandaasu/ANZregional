/******************/
/* Package Header */
/******************/
create or replace package ods_atlods13 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_atlods13
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - atlods13 - Inbound Sales Order Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004      ISI            Created
    2007/10   Steve Gregan   Included SAP_SAL_ORD_TRACE table

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_atlods13;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_atlods13 as

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
   procedure process_record_org(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);
   procedure process_record_con(par_record in varchar2);
   procedure process_record_pnr(par_record in varchar2);
   procedure process_record_ref(par_record in varchar2);
   procedure process_record_gen(par_record in varchar2);
   procedure process_record_irf(par_record in varchar2);
   procedure process_record_idt(par_record in varchar2);
   procedure process_record_ico(par_record in varchar2);
   procedure process_record_isc(par_record in varchar2);
   procedure process_record_ipn(par_record in varchar2);
   procedure process_record_iid(par_record in varchar2);
   procedure process_record_smy(par_record in varchar2);
   procedure load_trace(par_belnr in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_ods_control ods_definition.idoc_control;
   rcd_sap_sal_ord_hdr sap_sal_ord_hdr%rowtype;
   rcd_sap_sal_ord_org sap_sal_ord_org%rowtype;
   rcd_sap_sal_ord_dat sap_sal_ord_dat%rowtype;
   rcd_sap_sal_ord_con sap_sal_ord_con%rowtype;
   rcd_sap_sal_ord_pnr sap_sal_ord_pnr%rowtype;
   rcd_sap_sal_ord_ref sap_sal_ord_ref%rowtype;
   rcd_sap_sal_ord_gen sap_sal_ord_gen%rowtype;
   rcd_sap_sal_ord_irf sap_sal_ord_irf%rowtype;
   rcd_sap_sal_ord_idt sap_sal_ord_idt%rowtype;
   rcd_sap_sal_ord_ico sap_sal_ord_ico%rowtype;
   rcd_sap_sal_ord_isc sap_sal_ord_isc%rowtype;
   rcd_sap_sal_ord_ipn sap_sal_ord_ipn%rowtype;
   rcd_sap_sal_ord_iid sap_sal_ord_iid%rowtype;
   rcd_sap_sal_ord_smy sap_sal_ord_smy%rowtype;

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
      lics_inbound_utility.set_definition('HDR','ACTION',3);
      lics_inbound_utility.set_definition('HDR','KZABS',1);
      lics_inbound_utility.set_definition('HDR','CURCY',3);
      lics_inbound_utility.set_definition('HDR','HWAER',3);
      lics_inbound_utility.set_definition('HDR','WKURS',12);
      lics_inbound_utility.set_definition('HDR','ZTERM',17);
      lics_inbound_utility.set_definition('HDR','KUNDEUINR',20);
      lics_inbound_utility.set_definition('HDR','EIGENUINR',20);
      lics_inbound_utility.set_definition('HDR','BSART',4);
      lics_inbound_utility.set_definition('HDR','BELNR',35);
      lics_inbound_utility.set_definition('HDR','NTGEW',18);
      lics_inbound_utility.set_definition('HDR','BRGEW',18);
      lics_inbound_utility.set_definition('HDR','GEWEI',3);
      lics_inbound_utility.set_definition('HDR','FKART_RL',4);
      lics_inbound_utility.set_definition('HDR','ABLAD',25);
      lics_inbound_utility.set_definition('HDR','BSTZD',4);
      lics_inbound_utility.set_definition('HDR','VSART',2);
      lics_inbound_utility.set_definition('HDR','VSART_BEZ',20);
      lics_inbound_utility.set_definition('HDR','RECIPNT_NO',10);
      lics_inbound_utility.set_definition('HDR','KZAZU',1);
      lics_inbound_utility.set_definition('HDR','AUTLF',1);
      lics_inbound_utility.set_definition('HDR','AUGRU',3);
      lics_inbound_utility.set_definition('HDR','AUGRU_BEZ',40);
      lics_inbound_utility.set_definition('HDR','ABRVW',3);
      lics_inbound_utility.set_definition('HDR','ABRVW_BEZ',20);
      lics_inbound_utility.set_definition('HDR','FKTYP',1);
      lics_inbound_utility.set_definition('HDR','LIFSK',2);
      lics_inbound_utility.set_definition('HDR','LIFSK_BEZ',20);
      lics_inbound_utility.set_definition('HDR','EMPST',25);
      lics_inbound_utility.set_definition('HDR','ABTNR',4);
      lics_inbound_utility.set_definition('HDR','DELCO',3);
      lics_inbound_utility.set_definition('HDR','WKURS_M',12);
      lics_inbound_utility.set_definition('HDR','ZZEXPECTPB',3);
      lics_inbound_utility.set_definition('HDR','ZZORBDPR',3);
      lics_inbound_utility.set_definition('HDR','ZZMANBPR',3);
      lics_inbound_utility.set_definition('HDR','ZZTARIF',3);
      lics_inbound_utility.set_definition('HDR','ZZNOCOMBI',1);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM01',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM02',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM03',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM04',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM05',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM06',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM07',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM08',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM09',4);
      lics_inbound_utility.set_definition('HDR','ZZPBUOM10',4);
      lics_inbound_utility.set_definition('HDR','ZZGROUPING',1);
      lics_inbound_utility.set_definition('HDR','ZZINCOMPLETED',1);
      lics_inbound_utility.set_definition('HDR','ZZSTATUS',2);
      lics_inbound_utility.set_definition('HDR','ZZLOGPOINT',15);
      lics_inbound_utility.set_definition('HDR','ZZHOMOPAL',13);
      lics_inbound_utility.set_definition('HDR','ZZHOMOLAY',13);
      lics_inbound_utility.set_definition('HDR','ZZLOOSECAS',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND05',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND06',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND07',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND08',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND09',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND10',13);
      lics_inbound_utility.set_definition('HDR','ZZPALSPACE',15);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS01',13);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS02',13);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS03',13);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS04',13);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS05',13);
      lics_inbound_utility.set_definition('HDR','ZZBRGEW',13);
      lics_inbound_utility.set_definition('HDR','ZZWEIGHTPAL',13);
      lics_inbound_utility.set_definition('HDR','ZZLOGPOINT_F',15);
      lics_inbound_utility.set_definition('HDR','ZZHOMOPAL_F',13);
      lics_inbound_utility.set_definition('HDR','ZZHOMOLAY_F',13);
      lics_inbound_utility.set_definition('HDR','ZZLOOSECAS_F',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND05_F',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND06F',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND07_F',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND08_F',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND09_F',13);
      lics_inbound_utility.set_definition('HDR','ZZCOND10_F',13);
      lics_inbound_utility.set_definition('HDR','ZZPALSPACE_F',15);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS01_F',13);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS02_F',13);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS03_F',13);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS04_F',13);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS05_F',13);
      lics_inbound_utility.set_definition('HDR','ZZBRGEW_F',13);
      lics_inbound_utility.set_definition('HDR','ZZWEIGHTPAL_F',13);
      lics_inbound_utility.set_definition('HDR','ZZMEINS01',3);
      lics_inbound_utility.set_definition('HDR','ZZMEINS02',3);
      lics_inbound_utility.set_definition('HDR','ZZMEINS03',3);
      lics_inbound_utility.set_definition('HDR','ZZMEINS04',3);
      lics_inbound_utility.set_definition('HDR','ZZMEINS05',3);
      lics_inbound_utility.set_definition('HDR','ZZWEIGHTUOM',3);
      lics_inbound_utility.set_definition('HDR','ZZERROR',1);
      lics_inbound_utility.set_definition('HDR','ZZVSART',2);
      lics_inbound_utility.set_definition('HDR','ZZSDABW',4);
      lics_inbound_utility.set_definition('HDR','ZZORDRSPSTATUS_H',2);
      lics_inbound_utility.set_definition('HDR','CMGST',1);
      lics_inbound_utility.set_definition('HDR','CMGST_BEZ',20);
      lics_inbound_utility.set_definition('HDR','SPSTG',1);
      lics_inbound_utility.set_definition('HDR','SPSTG_BEZ',20);
      /*-*/
      lics_inbound_utility.set_definition('ORG','IDOC_ORG',3);
      lics_inbound_utility.set_definition('ORG','QUALF',3);
      lics_inbound_utility.set_definition('ORG','ORGID',35);
      /*-*/
      lics_inbound_utility.set_definition('DAT','IDOC_DAT',3);
      lics_inbound_utility.set_definition('DAT','IDDAT',3);
      lics_inbound_utility.set_definition('DAT','DATUM',8);
      lics_inbound_utility.set_definition('DAT','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('CON','IDOC_CON',3);
      lics_inbound_utility.set_definition('CON','ALCKZ',3);
      lics_inbound_utility.set_definition('CON','KSCHL',4);
      lics_inbound_utility.set_definition('CON','KOTXT',80);
      lics_inbound_utility.set_definition('CON','BETRG',18);
      lics_inbound_utility.set_definition('CON','KPERC',8);
      lics_inbound_utility.set_definition('CON','KRATE',15);
      lics_inbound_utility.set_definition('CON','UPRBS',9);
      lics_inbound_utility.set_definition('CON','MEAUN',3);
      lics_inbound_utility.set_definition('CON','KOBTR',18);
      lics_inbound_utility.set_definition('CON','MWSKZ',7);
      lics_inbound_utility.set_definition('CON','MSATZ',17);
      lics_inbound_utility.set_definition('CON','KOEIN',3);
      /*-*/
      lics_inbound_utility.set_definition('PNR','IDOC_PNR',3);
      lics_inbound_utility.set_definition('PNR','PARVW',3);
      lics_inbound_utility.set_definition('PNR','PARTN',17);
      lics_inbound_utility.set_definition('PNR','LIFNR',17);
      lics_inbound_utility.set_definition('PNR','NAME1',35);
      lics_inbound_utility.set_definition('PNR','NAME2',35);
      lics_inbound_utility.set_definition('PNR','NAME3',35);
      lics_inbound_utility.set_definition('PNR','NAME4',35);
      lics_inbound_utility.set_definition('PNR','STRAS',35);
      lics_inbound_utility.set_definition('PNR','STRS2',35);
      lics_inbound_utility.set_definition('PNR','PFACH',35);
      lics_inbound_utility.set_definition('PNR','ORT01',35);
      lics_inbound_utility.set_definition('PNR','COUNC',9);
      lics_inbound_utility.set_definition('PNR','PSTLZ',9);
      lics_inbound_utility.set_definition('PNR','PSTL2',9);
      lics_inbound_utility.set_definition('PNR','LAND1',3);
      lics_inbound_utility.set_definition('PNR','ABLAD',35);
      lics_inbound_utility.set_definition('PNR','PERNR',30);
      lics_inbound_utility.set_definition('PNR','PARNR',30);
      lics_inbound_utility.set_definition('PNR','TELF1',25);
      lics_inbound_utility.set_definition('PNR','TELF2',25);
      lics_inbound_utility.set_definition('PNR','TELBX',25);
      lics_inbound_utility.set_definition('PNR','TELFX',25);
      lics_inbound_utility.set_definition('PNR','TELTX',25);
      lics_inbound_utility.set_definition('PNR','TELX1',25);
      lics_inbound_utility.set_definition('PNR','SPRAS',1);
      lics_inbound_utility.set_definition('PNR','ANRED',15);
      lics_inbound_utility.set_definition('PNR','ORT02',35);
      lics_inbound_utility.set_definition('PNR','HAUSN',6);
      lics_inbound_utility.set_definition('PNR','STOCK',6);
      lics_inbound_utility.set_definition('PNR','REGIO',3);
      lics_inbound_utility.set_definition('PNR','PARGE',1);
      lics_inbound_utility.set_definition('PNR','ISOAL',2);
      lics_inbound_utility.set_definition('PNR','ISONU',2);
      lics_inbound_utility.set_definition('PNR','FCODE',20);
      lics_inbound_utility.set_definition('PNR','IHREZ',30);
      lics_inbound_utility.set_definition('PNR','BNAME',35);
      lics_inbound_utility.set_definition('PNR','PAORG',30);
      lics_inbound_utility.set_definition('PNR','ORGTX',35);
      lics_inbound_utility.set_definition('PNR','PAGRU',30);
      lics_inbound_utility.set_definition('PNR','KNREF',30);
      lics_inbound_utility.set_definition('PNR','ILNNR',70);
      lics_inbound_utility.set_definition('PNR','PFORT',35);
      lics_inbound_utility.set_definition('PNR','SPRAS_ISO',2);
      lics_inbound_utility.set_definition('PNR','TITLE',15);
      /*-*/
      lics_inbound_utility.set_definition('REF','IDOC_REF',3);
      lics_inbound_utility.set_definition('REF','QUALF',3);
      lics_inbound_utility.set_definition('REF','REFNR',35);
      lics_inbound_utility.set_definition('REF','POSNR',6);
      lics_inbound_utility.set_definition('REF','DATUM',8);
      lics_inbound_utility.set_definition('REF','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('GEN','IDOC_GEN',3);
      lics_inbound_utility.set_definition('GEN','POSEX',6);
      lics_inbound_utility.set_definition('GEN','ACTION',3);
      lics_inbound_utility.set_definition('GEN','PSTYP',1);
      lics_inbound_utility.set_definition('GEN','KZABS',1);
      lics_inbound_utility.set_definition('GEN','MENGE',15);
      lics_inbound_utility.set_definition('GEN','MENEE',3);
      lics_inbound_utility.set_definition('GEN','BMNG2',15);
      lics_inbound_utility.set_definition('GEN','PMENE',3);
      lics_inbound_utility.set_definition('GEN','ABFTZ',7);
      lics_inbound_utility.set_definition('GEN','VPREI',15);
      lics_inbound_utility.set_definition('GEN','PEINH',9);
      lics_inbound_utility.set_definition('GEN','NETWR',18);
      lics_inbound_utility.set_definition('GEN','ANETW',18);
      lics_inbound_utility.set_definition('GEN','SKFBP',18);
      lics_inbound_utility.set_definition('GEN','NTGEW',18);
      lics_inbound_utility.set_definition('GEN','GEWEI',3);
      lics_inbound_utility.set_definition('GEN','EINKZ',1);
      lics_inbound_utility.set_definition('GEN','CURCY',3);
      lics_inbound_utility.set_definition('GEN','PREIS',18);
      lics_inbound_utility.set_definition('GEN','MATKL',9);
      lics_inbound_utility.set_definition('GEN','UEPOS',6);
      lics_inbound_utility.set_definition('GEN','GRKOR',3);
      lics_inbound_utility.set_definition('GEN','EVERS',7);
      lics_inbound_utility.set_definition('GEN','BPUMN',6);
      lics_inbound_utility.set_definition('GEN','BPUMZ',6);
      lics_inbound_utility.set_definition('GEN','ABGRU',2);
      lics_inbound_utility.set_definition('GEN','ABGRT',40);
      lics_inbound_utility.set_definition('GEN','ANTLF',1);
      lics_inbound_utility.set_definition('GEN','FIXMG',1);
      lics_inbound_utility.set_definition('GEN','KZAZU',1);
      lics_inbound_utility.set_definition('GEN','BRGEW',18);
      lics_inbound_utility.set_definition('GEN','PSTYV',4);
      lics_inbound_utility.set_definition('GEN','EMPST',25);
      lics_inbound_utility.set_definition('GEN','ABTNR',4);
      lics_inbound_utility.set_definition('GEN','ABRVW',3);
      lics_inbound_utility.set_definition('GEN','WERKS',4);
      lics_inbound_utility.set_definition('GEN','LPRIO',2);
      lics_inbound_utility.set_definition('GEN','LPRIO_BEZ',20);
      lics_inbound_utility.set_definition('GEN','ROUTE',6);
      lics_inbound_utility.set_definition('GEN','ROUTE_BEZ',40);
      lics_inbound_utility.set_definition('GEN','LGORT',4);
      lics_inbound_utility.set_definition('GEN','VSTEL',4);
      lics_inbound_utility.set_definition('GEN','DELCO',3);
      lics_inbound_utility.set_definition('GEN','MATNR',35);
      lics_inbound_utility.set_definition('GEN','VALTG',2);
      lics_inbound_utility.set_definition('GEN','HIPOS',6);
      lics_inbound_utility.set_definition('GEN','HIEVW',1);
      lics_inbound_utility.set_definition('GEN','POSGUID',22);
      lics_inbound_utility.set_definition('GEN','ZZLOGPOINT',15);
      lics_inbound_utility.set_definition('GEN','ZZHOMOPAL',13);
      lics_inbound_utility.set_definition('GEN','ZZHOMOLAY',13);
      lics_inbound_utility.set_definition('GEN','ZZLOOSECAS',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND05',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND06',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND07',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND08',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND09',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND10',13);
      lics_inbound_utility.set_definition('GEN','ZZPALSPACE',15);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS01',13);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS02',13);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS03',13);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS04',13);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS05',13);
      lics_inbound_utility.set_definition('GEN','ZZBRGEW',13);
      lics_inbound_utility.set_definition('GEN','ZZWEIGHTPAL',13);
      lics_inbound_utility.set_definition('GEN','ZZLOGPOINT_F',15);
      lics_inbound_utility.set_definition('GEN','ZZHOMOPAL_F',13);
      lics_inbound_utility.set_definition('GEN','ZZHOMOLAY_F',13);
      lics_inbound_utility.set_definition('GEN','ZZLOOSECAS_F',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND05_F',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND06F',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND07_F',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND08_F',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND09_F',13);
      lics_inbound_utility.set_definition('GEN','ZZCOND10_F',13);
      lics_inbound_utility.set_definition('GEN','ZZPALSPACE_F',15);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS01_F',13);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS02_F',13);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS03_F',13);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS04_F',13);
      lics_inbound_utility.set_definition('GEN','ZZPALBAS05_F',13);
      lics_inbound_utility.set_definition('GEN','ZZBRGEW_F',13);
      lics_inbound_utility.set_definition('GEN','ZZWEIGHTPAL_F',13);
      lics_inbound_utility.set_definition('GEN','ZZMEINS01',3);
      lics_inbound_utility.set_definition('GEN','ZZMEINS02',3);
      lics_inbound_utility.set_definition('GEN','ZZMEINS03',3);
      lics_inbound_utility.set_definition('GEN','ZZMEINS04',3);
      lics_inbound_utility.set_definition('GEN','ZZMEINS05',3);
      lics_inbound_utility.set_definition('GEN','ZZWEIGHTUOM',3);
      lics_inbound_utility.set_definition('GEN','ZZMVGR1',3);
      lics_inbound_utility.set_definition('GEN','ZZQTYPALUOM',13);
      lics_inbound_utility.set_definition('GEN','ZZPCBQTY',4);
      lics_inbound_utility.set_definition('GEN','ZZMATWA',18);
      lics_inbound_utility.set_definition('GEN','ZZORDRSPSTATUS_L',2);
      lics_inbound_utility.set_definition('GEN','ZZEAN_CU',18);
      lics_inbound_utility.set_definition('GEN','ZZMENGE_IN_PC',13);
      lics_inbound_utility.set_definition('GEN','POSEX_ID',6);
      lics_inbound_utility.set_definition('GEN','CONFIG_ID',6);
      lics_inbound_utility.set_definition('GEN','INST_ID',8);
      lics_inbound_utility.set_definition('GEN','QUALF',3);
      lics_inbound_utility.set_definition('GEN','ICC',2);
      lics_inbound_utility.set_definition('GEN','MOI',4);
      lics_inbound_utility.set_definition('GEN','PRI',3);
      lics_inbound_utility.set_definition('GEN','ACN',5);
      lics_inbound_utility.set_definition('GEN','FUNCTION',3);
      lics_inbound_utility.set_definition('GEN','TDOBJECT',10);
      lics_inbound_utility.set_definition('GEN','TDOBNAME',70);
      lics_inbound_utility.set_definition('GEN','TDID',4);
      lics_inbound_utility.set_definition('GEN','TDSPRAS',1);
      lics_inbound_utility.set_definition('GEN','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('GEN','LANGUA_ISO',2);
      /*-*/
      lics_inbound_utility.set_definition('IRF','IDOC_IRF',3);
      lics_inbound_utility.set_definition('IRF','QUALF',3);
      lics_inbound_utility.set_definition('IRF','REFNR',35);
      lics_inbound_utility.set_definition('IRF','ZEILE',6);
      lics_inbound_utility.set_definition('IRF','DATUM',8);
      lics_inbound_utility.set_definition('IRF','UZEIT',6);
      lics_inbound_utility.set_definition('IRF','BSARK',35);
      lics_inbound_utility.set_definition('IRF','IHREZ',30);
      /*-*/
      lics_inbound_utility.set_definition('IDT','IDOC_IDT',3);
      lics_inbound_utility.set_definition('IDT','IDDAT',3);
      lics_inbound_utility.set_definition('IDT','DATUM',8);
      lics_inbound_utility.set_definition('IDT','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('ICO','IDOC_ICO',3);
      lics_inbound_utility.set_definition('ICO','ALCKZ',3);
      lics_inbound_utility.set_definition('ICO','KSCHL',4);
      lics_inbound_utility.set_definition('ICO','KOTXT',80);
      lics_inbound_utility.set_definition('ICO','BETRG',18);
      lics_inbound_utility.set_definition('ICO','KPERC',8);
      lics_inbound_utility.set_definition('ICO','KRATE',15);
      lics_inbound_utility.set_definition('ICO','UPRBS',9);
      lics_inbound_utility.set_definition('ICO','MEAUN',3);
      lics_inbound_utility.set_definition('ICO','KOBTR',18);
      lics_inbound_utility.set_definition('ICO','MENGE',15);
      lics_inbound_utility.set_definition('ICO','PREIS',15);
      lics_inbound_utility.set_definition('ICO','MWSKZ',7);
      lics_inbound_utility.set_definition('ICO','MSATZ',17);
      lics_inbound_utility.set_definition('ICO','KOEIN',3);
      lics_inbound_utility.set_definition('ICO','CURTP',2);
      lics_inbound_utility.set_definition('ICO','KOBAS',18);
      /*-*/
      lics_inbound_utility.set_definition('ISC','IDOC_ISC',3);
      lics_inbound_utility.set_definition('ISC','WMENG',15);
      lics_inbound_utility.set_definition('ISC','AMENG',15);
      lics_inbound_utility.set_definition('ISC','EDATU',8);
      lics_inbound_utility.set_definition('ISC','EZEIT',6);
      lics_inbound_utility.set_definition('ISC','EDATU_OLD',8);
      lics_inbound_utility.set_definition('ISC','EZEIT_OLD',6);
      lics_inbound_utility.set_definition('ISC','ACTION',3);
      /*-*/
      lics_inbound_utility.set_definition('IPN','IDOC_IPN',3);
      lics_inbound_utility.set_definition('IPN','PARVW',3);
      lics_inbound_utility.set_definition('IPN','PARTN',17);
      lics_inbound_utility.set_definition('IPN','LIFNR',17);
      lics_inbound_utility.set_definition('IPN','NAME1',35);
      lics_inbound_utility.set_definition('IPN','NAME2',35);
      lics_inbound_utility.set_definition('IPN','NAME3',35);
      lics_inbound_utility.set_definition('IPN','NAME4',35);
      lics_inbound_utility.set_definition('IPN','STRAS',35);
      lics_inbound_utility.set_definition('IPN','STRS2',35);
      lics_inbound_utility.set_definition('IPN','PFACH',35);
      lics_inbound_utility.set_definition('IPN','ORT01',35);
      lics_inbound_utility.set_definition('IPN','COUNC',9);
      lics_inbound_utility.set_definition('IPN','PSTLZ',9);
      lics_inbound_utility.set_definition('IPN','PSTL2',9);
      lics_inbound_utility.set_definition('IPN','LAND1',3);
      lics_inbound_utility.set_definition('IPN','ABLAD',35);
      lics_inbound_utility.set_definition('IPN','PERNR',30);
      lics_inbound_utility.set_definition('IPN','PARNR',30);
      lics_inbound_utility.set_definition('IPN','TELF1',25);
      lics_inbound_utility.set_definition('IPN','TELF2',25);
      lics_inbound_utility.set_definition('IPN','TELBX',25);
      lics_inbound_utility.set_definition('IPN','TELFX',25);
      lics_inbound_utility.set_definition('IPN','TELTX',25);
      lics_inbound_utility.set_definition('IPN','TELX1',25);
      lics_inbound_utility.set_definition('IPN','SPRAS',1);
      lics_inbound_utility.set_definition('IPN','ANRED',15);
      lics_inbound_utility.set_definition('IPN','ORT02',35);
      lics_inbound_utility.set_definition('IPN','HAUSN',6);
      lics_inbound_utility.set_definition('IPN','STOCK',6);
      lics_inbound_utility.set_definition('IPN','REGIO',3);
      lics_inbound_utility.set_definition('IPN','PARGE',1);
      lics_inbound_utility.set_definition('IPN','ISOAL',2);
      lics_inbound_utility.set_definition('IPN','ISONU',2);
      lics_inbound_utility.set_definition('IPN','FCODE',20);
      lics_inbound_utility.set_definition('IPN','IHREZ',30);
      lics_inbound_utility.set_definition('IPN','BNAME',35);
      lics_inbound_utility.set_definition('IPN','PAORG',30);
      lics_inbound_utility.set_definition('IPN','ORGTX',35);
      lics_inbound_utility.set_definition('IPN','PAGRU',30);
      lics_inbound_utility.set_definition('IPN','KNREF',30);
      lics_inbound_utility.set_definition('IPN','ILNNR',70);
      lics_inbound_utility.set_definition('IPN','PFORT',35);
      lics_inbound_utility.set_definition('IPN','SPRAS_ISO',2);
      lics_inbound_utility.set_definition('IPN','TITLE',15);
      /*-*/
      lics_inbound_utility.set_definition('IID','IDOC_IID',3);
      lics_inbound_utility.set_definition('IID','QUALF',3);
      lics_inbound_utility.set_definition('IID','IDTNR',35);
      lics_inbound_utility.set_definition('IID','KTEXT',70);
      lics_inbound_utility.set_definition('IID','MFRPN',42);
      lics_inbound_utility.set_definition('IID','MFRNR',10);
      /*-*/
      lics_inbound_utility.set_definition('SMY','IDOC_SMY',3);
      lics_inbound_utility.set_definition('SMY','SUMID',3);
      lics_inbound_utility.set_definition('SMY','SUMME',18);
      lics_inbound_utility.set_definition('SMY','SUNIT',3);
      lics_inbound_utility.set_definition('SMY','WAERQ',3);

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
         when 'ORG' then process_record_org(par_record);
         when 'DAT' then process_record_dat(par_record);
         when 'TAX' then null; -- Ignore record
         when 'CON' then process_record_con(par_record);
         when 'PNR' then process_record_pnr(par_record);
         when 'PAD' then null; -- Ignore record
         when 'REF' then process_record_ref(par_record);
         when 'TOD' then null; -- Ignore record
         when 'TOP' then null; -- Ignore record
         when 'ADD' then null; -- Ignore record
         when 'PCD' then null; -- Ignore record
         when 'TXI' then null; -- Ignore record
         when 'TXT' then null; -- Ignore record
         when 'GEN' then process_record_gen(par_record);
         when 'SOG' then null; -- Ignore record
         when 'IRF' then process_record_irf(par_record);
         when 'IAD' then null; -- Ignore record
         when 'IDT' then process_record_idt(par_record);
         when 'ITA' then null; -- Ignore record
         when 'ICO' then process_record_ico(par_record);
         when 'IPS' then null; -- Ignore record
         when 'ISC' then process_record_isc(par_record);
         when 'IPN' then process_record_ipn(par_record);
         when 'IPD' then null; -- Ignore record
         when 'IID' then process_record_iid(par_record);
         when 'IGT' then null; -- Ignore record
         when 'ITD' then null; -- Ignore record
         when 'ITP' then null; -- Ignore record
         when 'IDD' then null; -- Ignore record
         when 'ITX' then null; -- Ignore record
         when 'ITT' then null; -- Ignore record
         when 'ISS' then null; -- Ignore record
         when 'ISR' then null; -- Ignore record
         when 'ISD' then null; -- Ignore record
         when 'IST' then null; -- Ignore record
         when 'ISN' then null; -- Ignore record
         when 'ISP' then null; -- Ignore record
         when 'ISO' then null; -- Ignore record
         when 'ISI' then null; -- Ignore record
         when 'ISJ' then null; -- Ignore record
         when 'ISX' then null; -- Ignore record
         when 'ISY' then null; -- Ignore record
         when 'SMY' then process_record_smy(par_record);
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
      /* Load the transaction trace when required
      /*-*/
      if var_trn_ignore = false and
         var_trn_error = false then
         begin
            load_trace(rcd_sap_sal_ord_hdr.belnr);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
               var_trn_error := true;
         end;
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
         /* Call the ODS_VALIDATION procedure.
         /*-*/
         begin
           lics_pipe.spray('*DAEMON','OV','*WAKE');
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;

         /*-*/
         /* Call the interface monitor procedure.
         /*-*/
         begin
            ods_atlods13_monitor.execute(rcd_sap_sal_ord_hdr.belnr);
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

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sap_sal_ord_hdr_01 is
         select
            t01.belnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from sap_sal_ord_hdr t01
         where t01.belnr = rcd_sap_sal_ord_hdr.belnr;
      rcd_sap_sal_ord_hdr_01 csr_sap_sal_ord_hdr_01%rowtype;

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
      rcd_sap_sal_ord_hdr.action := lics_inbound_utility.get_variable('ACTION');
      rcd_sap_sal_ord_hdr.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_sap_sal_ord_hdr.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_sap_sal_ord_hdr.hwaer := lics_inbound_utility.get_variable('HWAER');
      rcd_sap_sal_ord_hdr.wkurs := lics_inbound_utility.get_variable('WKURS');
      rcd_sap_sal_ord_hdr.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_sap_sal_ord_hdr.kundeuinr := lics_inbound_utility.get_variable('KUNDEUINR');
      rcd_sap_sal_ord_hdr.eigenuinr := lics_inbound_utility.get_variable('EIGENUINR');
      rcd_sap_sal_ord_hdr.bsart := lics_inbound_utility.get_variable('BSART');
      rcd_sap_sal_ord_hdr.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_sap_sal_ord_hdr.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_sap_sal_ord_hdr.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_sap_sal_ord_hdr.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_sap_sal_ord_hdr.fkart_rl := lics_inbound_utility.get_variable('FKART_RL');
      rcd_sap_sal_ord_hdr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_sap_sal_ord_hdr.bstzd := lics_inbound_utility.get_variable('BSTZD');
      rcd_sap_sal_ord_hdr.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_sap_sal_ord_hdr.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_sap_sal_ord_hdr.recipnt_no := lics_inbound_utility.get_variable('RECIPNT_NO');
      rcd_sap_sal_ord_hdr.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_sap_sal_ord_hdr.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_sap_sal_ord_hdr.augru := lics_inbound_utility.get_variable('AUGRU');
      rcd_sap_sal_ord_hdr.augru_bez := lics_inbound_utility.get_variable('AUGRU_BEZ');
      rcd_sap_sal_ord_hdr.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_sap_sal_ord_hdr.abrvw_bez := lics_inbound_utility.get_variable('ABRVW_BEZ');
      rcd_sap_sal_ord_hdr.fktyp := lics_inbound_utility.get_variable('FKTYP');
      rcd_sap_sal_ord_hdr.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_sap_sal_ord_hdr.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_sap_sal_ord_hdr.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_sap_sal_ord_hdr.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_sap_sal_ord_hdr.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_sap_sal_ord_hdr.wkurs_m := lics_inbound_utility.get_variable('WKURS_M');
      rcd_sap_sal_ord_hdr.zzexpectpb := lics_inbound_utility.get_variable('ZZEXPECTPB');
      rcd_sap_sal_ord_hdr.zzorbdpr := lics_inbound_utility.get_variable('ZZORBDPR');
      rcd_sap_sal_ord_hdr.zzmanbpr := lics_inbound_utility.get_variable('ZZMANBPR');
      rcd_sap_sal_ord_hdr.zztarif := lics_inbound_utility.get_variable('ZZTARIF');
      rcd_sap_sal_ord_hdr.zznocombi := lics_inbound_utility.get_variable('ZZNOCOMBI');
      rcd_sap_sal_ord_hdr.zzpbuom01 := lics_inbound_utility.get_variable('ZZPBUOM01');
      rcd_sap_sal_ord_hdr.zzpbuom02 := lics_inbound_utility.get_variable('ZZPBUOM02');
      rcd_sap_sal_ord_hdr.zzpbuom03 := lics_inbound_utility.get_variable('ZZPBUOM03');
      rcd_sap_sal_ord_hdr.zzpbuom04 := lics_inbound_utility.get_variable('ZZPBUOM04');
      rcd_sap_sal_ord_hdr.zzpbuom05 := lics_inbound_utility.get_variable('ZZPBUOM05');
      rcd_sap_sal_ord_hdr.zzpbuom06 := lics_inbound_utility.get_variable('ZZPBUOM06');
      rcd_sap_sal_ord_hdr.zzpbuom07 := lics_inbound_utility.get_variable('ZZPBUOM07');
      rcd_sap_sal_ord_hdr.zzpbuom08 := lics_inbound_utility.get_variable('ZZPBUOM08');
      rcd_sap_sal_ord_hdr.zzpbuom09 := lics_inbound_utility.get_variable('ZZPBUOM09');
      rcd_sap_sal_ord_hdr.zzpbuom10 := lics_inbound_utility.get_variable('ZZPBUOM10');
      rcd_sap_sal_ord_hdr.zzgrouping := lics_inbound_utility.get_variable('ZZGROUPING');
      rcd_sap_sal_ord_hdr.zzincompleted := lics_inbound_utility.get_variable('ZZINCOMPLETED');
      rcd_sap_sal_ord_hdr.zzstatus := lics_inbound_utility.get_variable('ZZSTATUS');
      rcd_sap_sal_ord_hdr.zzlogpoint := lics_inbound_utility.get_variable('ZZLOGPOINT');
      rcd_sap_sal_ord_hdr.zzhomopal := lics_inbound_utility.get_variable('ZZHOMOPAL');
      rcd_sap_sal_ord_hdr.zzhomolay := lics_inbound_utility.get_variable('ZZHOMOLAY');
      rcd_sap_sal_ord_hdr.zzloosecas := lics_inbound_utility.get_variable('ZZLOOSECAS');
      rcd_sap_sal_ord_hdr.zzcond05 := lics_inbound_utility.get_variable('ZZCOND05');
      rcd_sap_sal_ord_hdr.zzcond06 := lics_inbound_utility.get_variable('ZZCOND06');
      rcd_sap_sal_ord_hdr.zzcond07 := lics_inbound_utility.get_variable('ZZCOND07');
      rcd_sap_sal_ord_hdr.zzcond08 := lics_inbound_utility.get_variable('ZZCOND08');
      rcd_sap_sal_ord_hdr.zzcond09 := lics_inbound_utility.get_variable('ZZCOND09');
      rcd_sap_sal_ord_hdr.zzcond10 := lics_inbound_utility.get_variable('ZZCOND10');
      rcd_sap_sal_ord_hdr.zzpalspace := lics_inbound_utility.get_variable('ZZPALSPACE');
      rcd_sap_sal_ord_hdr.zzpalbas01 := lics_inbound_utility.get_variable('ZZPALBAS01');
      rcd_sap_sal_ord_hdr.zzpalbas02 := lics_inbound_utility.get_variable('ZZPALBAS02');
      rcd_sap_sal_ord_hdr.zzpalbas03 := lics_inbound_utility.get_variable('ZZPALBAS03');
      rcd_sap_sal_ord_hdr.zzpalbas04 := lics_inbound_utility.get_variable('ZZPALBAS04');
      rcd_sap_sal_ord_hdr.zzpalbas05 := lics_inbound_utility.get_variable('ZZPALBAS05');
      rcd_sap_sal_ord_hdr.zzbrgew := lics_inbound_utility.get_variable('ZZBRGEW');
      rcd_sap_sal_ord_hdr.zzweightpal := lics_inbound_utility.get_variable('ZZWEIGHTPAL');
      rcd_sap_sal_ord_hdr.zzlogpoint_f := lics_inbound_utility.get_variable('ZZLOGPOINT_F');
      rcd_sap_sal_ord_hdr.zzhomopal_f := lics_inbound_utility.get_variable('ZZHOMOPAL_F');
      rcd_sap_sal_ord_hdr.zzhomolay_f := lics_inbound_utility.get_variable('ZZHOMOLAY_F');
      rcd_sap_sal_ord_hdr.zzloosecas_f := lics_inbound_utility.get_variable('ZZLOOSECAS_F');
      rcd_sap_sal_ord_hdr.zzcond05_f := lics_inbound_utility.get_variable('ZZCOND05_F');
      rcd_sap_sal_ord_hdr.zzcond06f := lics_inbound_utility.get_variable('ZZCOND06F');
      rcd_sap_sal_ord_hdr.zzcond07_f := lics_inbound_utility.get_variable('ZZCOND07_F');
      rcd_sap_sal_ord_hdr.zzcond08_f := lics_inbound_utility.get_variable('ZZCOND08_F');
      rcd_sap_sal_ord_hdr.zzcond09_f := lics_inbound_utility.get_variable('ZZCOND09_F');
      rcd_sap_sal_ord_hdr.zzcond10_f := lics_inbound_utility.get_variable('ZZCOND10_F');
      rcd_sap_sal_ord_hdr.zzpalspace_f := lics_inbound_utility.get_variable('ZZPALSPACE_F');
      rcd_sap_sal_ord_hdr.zzpalbas01_f := lics_inbound_utility.get_variable('ZZPALBAS01_F');
      rcd_sap_sal_ord_hdr.zzpalbas02_f := lics_inbound_utility.get_variable('ZZPALBAS02_F');
      rcd_sap_sal_ord_hdr.zzpalbas03_f := lics_inbound_utility.get_variable('ZZPALBAS03_F');
      rcd_sap_sal_ord_hdr.zzpalbas04_f := lics_inbound_utility.get_variable('ZZPALBAS04_F');
      rcd_sap_sal_ord_hdr.zzpalbas05_f := lics_inbound_utility.get_variable('ZZPALBAS05_F');
      rcd_sap_sal_ord_hdr.zzbrgew_f := lics_inbound_utility.get_variable('ZZBRGEW_F');
      rcd_sap_sal_ord_hdr.zzweightpal_f := lics_inbound_utility.get_variable('ZZWEIGHTPAL_F');
      rcd_sap_sal_ord_hdr.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
      rcd_sap_sal_ord_hdr.zzmeins02 := lics_inbound_utility.get_variable('ZZMEINS02');
      rcd_sap_sal_ord_hdr.zzmeins03 := lics_inbound_utility.get_variable('ZZMEINS03');
      rcd_sap_sal_ord_hdr.zzmeins04 := lics_inbound_utility.get_variable('ZZMEINS04');
      rcd_sap_sal_ord_hdr.zzmeins05 := lics_inbound_utility.get_variable('ZZMEINS05');
      rcd_sap_sal_ord_hdr.zzweightuom := lics_inbound_utility.get_variable('ZZWEIGHTUOM');
      rcd_sap_sal_ord_hdr.zzerror := lics_inbound_utility.get_variable('ZZERROR');
      rcd_sap_sal_ord_hdr.zzvsart := lics_inbound_utility.get_variable('ZZVSART');
      rcd_sap_sal_ord_hdr.zzsdabw := lics_inbound_utility.get_variable('ZZSDABW');
      rcd_sap_sal_ord_hdr.zzordrspstatus_h := lics_inbound_utility.get_variable('ZZORDRSPSTATUS_H');
      rcd_sap_sal_ord_hdr.cmgst := lics_inbound_utility.get_variable('CMGST');
      rcd_sap_sal_ord_hdr.cmgst_bez := lics_inbound_utility.get_variable('CMGST_BEZ');
      rcd_sap_sal_ord_hdr.spstg := lics_inbound_utility.get_variable('SPSTG');
      rcd_sap_sal_ord_hdr.spstg_bez := lics_inbound_utility.get_variable('SPSTG_BEZ');
      rcd_sap_sal_ord_hdr.idoc_name := rcd_ods_control.idoc_name;
      rcd_sap_sal_ord_hdr.idoc_number := rcd_ods_control.idoc_number;
      rcd_sap_sal_ord_hdr.idoc_timestamp := rcd_ods_control.idoc_timestamp;
      rcd_sap_sal_ord_hdr.valdtn_status := ods_constants.valdtn_unchecked;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_sal_ord_org.orgseq := 0;
      rcd_sap_sal_ord_dat.datseq := 0;
      rcd_sap_sal_ord_con.conseq := 0;
      rcd_sap_sal_ord_pnr.pnrseq := 0;
      rcd_sap_sal_ord_ref.refseq := 0;
      rcd_sap_sal_ord_gen.genseq := 0;
      rcd_sap_sal_ord_smy.smyseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_sal_ord_hdr.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BELNR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_sap_sal_ord_hdr.belnr is null) then
         var_exists := true;
         open csr_sap_sal_ord_hdr_01;
         fetch csr_sap_sal_ord_hdr_01 into rcd_sap_sal_ord_hdr_01;
         if csr_sap_sal_ord_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_sap_sal_ord_hdr_01;
         if var_exists = true then
            if rcd_sap_sal_ord_hdr.idoc_timestamp > rcd_sap_sal_ord_hdr_01.idoc_timestamp then
               delete from sap_sal_ord_smy where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_iid where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_ipn where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_isc where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_ico where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_idt where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_irf where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_gen where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_ref where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_pnr where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_con where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_dat where belnr = rcd_sap_sal_ord_hdr.belnr;
               delete from sap_sal_ord_org where belnr = rcd_sap_sal_ord_hdr.belnr;
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

      update sap_sal_ord_hdr set
         action = rcd_sap_sal_ord_hdr.action,
         kzabs = rcd_sap_sal_ord_hdr.kzabs,
         curcy = rcd_sap_sal_ord_hdr.curcy,
         hwaer = rcd_sap_sal_ord_hdr.hwaer,
         wkurs = rcd_sap_sal_ord_hdr.wkurs,
         zterm = rcd_sap_sal_ord_hdr.zterm,
         kundeuinr = rcd_sap_sal_ord_hdr.kundeuinr,
         eigenuinr = rcd_sap_sal_ord_hdr.eigenuinr,
         bsart = rcd_sap_sal_ord_hdr.bsart,
         ntgew = rcd_sap_sal_ord_hdr.ntgew,
         brgew = rcd_sap_sal_ord_hdr.brgew,
         gewei = rcd_sap_sal_ord_hdr.gewei,
         fkart_rl = rcd_sap_sal_ord_hdr.fkart_rl,
         ablad = rcd_sap_sal_ord_hdr.ablad,
         bstzd = rcd_sap_sal_ord_hdr.bstzd,
         vsart = rcd_sap_sal_ord_hdr.vsart,
         vsart_bez = rcd_sap_sal_ord_hdr.vsart_bez,
         recipnt_no = rcd_sap_sal_ord_hdr.recipnt_no,
         kzazu = rcd_sap_sal_ord_hdr.kzazu,
         autlf = rcd_sap_sal_ord_hdr.autlf,
         augru = rcd_sap_sal_ord_hdr.augru,
         augru_bez = rcd_sap_sal_ord_hdr.augru_bez,
         abrvw = rcd_sap_sal_ord_hdr.abrvw,
         abrvw_bez = rcd_sap_sal_ord_hdr.abrvw_bez,
         fktyp = rcd_sap_sal_ord_hdr.fktyp,
         lifsk = rcd_sap_sal_ord_hdr.lifsk,
         lifsk_bez = rcd_sap_sal_ord_hdr.lifsk_bez,
         empst = rcd_sap_sal_ord_hdr.empst,
         abtnr = rcd_sap_sal_ord_hdr.abtnr,
         delco = rcd_sap_sal_ord_hdr.delco,
         wkurs_m = rcd_sap_sal_ord_hdr.wkurs_m,
         zzexpectpb = rcd_sap_sal_ord_hdr.zzexpectpb,
         zzorbdpr = rcd_sap_sal_ord_hdr.zzorbdpr,
         zzmanbpr = rcd_sap_sal_ord_hdr.zzmanbpr,
         zztarif = rcd_sap_sal_ord_hdr.zztarif,
         zznocombi = rcd_sap_sal_ord_hdr.zznocombi,
         zzpbuom01 = rcd_sap_sal_ord_hdr.zzpbuom01,
         zzpbuom02 = rcd_sap_sal_ord_hdr.zzpbuom02,
         zzpbuom03 = rcd_sap_sal_ord_hdr.zzpbuom03,
         zzpbuom04 = rcd_sap_sal_ord_hdr.zzpbuom04,
         zzpbuom05 = rcd_sap_sal_ord_hdr.zzpbuom05,
         zzpbuom06 = rcd_sap_sal_ord_hdr.zzpbuom06,
         zzpbuom07 = rcd_sap_sal_ord_hdr.zzpbuom07,
         zzpbuom08 = rcd_sap_sal_ord_hdr.zzpbuom08,
         zzpbuom09 = rcd_sap_sal_ord_hdr.zzpbuom09,
         zzpbuom10 = rcd_sap_sal_ord_hdr.zzpbuom10,
         zzgrouping = rcd_sap_sal_ord_hdr.zzgrouping,
         zzincompleted = rcd_sap_sal_ord_hdr.zzincompleted,
         zzstatus = rcd_sap_sal_ord_hdr.zzstatus,
         zzlogpoint = rcd_sap_sal_ord_hdr.zzlogpoint,
         zzhomopal = rcd_sap_sal_ord_hdr.zzhomopal,
         zzhomolay = rcd_sap_sal_ord_hdr.zzhomolay,
         zzloosecas = rcd_sap_sal_ord_hdr.zzloosecas,
         zzcond05 = rcd_sap_sal_ord_hdr.zzcond05,
         zzcond06 = rcd_sap_sal_ord_hdr.zzcond06,
         zzcond07 = rcd_sap_sal_ord_hdr.zzcond07,
         zzcond08 = rcd_sap_sal_ord_hdr.zzcond08,
         zzcond09 = rcd_sap_sal_ord_hdr.zzcond09,
         zzcond10 = rcd_sap_sal_ord_hdr.zzcond10,
         zzpalspace = rcd_sap_sal_ord_hdr.zzpalspace,
         zzpalbas01 = rcd_sap_sal_ord_hdr.zzpalbas01,
         zzpalbas02 = rcd_sap_sal_ord_hdr.zzpalbas02,
         zzpalbas03 = rcd_sap_sal_ord_hdr.zzpalbas03,
         zzpalbas04 = rcd_sap_sal_ord_hdr.zzpalbas04,
         zzpalbas05 = rcd_sap_sal_ord_hdr.zzpalbas05,
         zzbrgew = rcd_sap_sal_ord_hdr.zzbrgew,
         zzweightpal = rcd_sap_sal_ord_hdr.zzweightpal,
         zzlogpoint_f = rcd_sap_sal_ord_hdr.zzlogpoint_f,
         zzhomopal_f = rcd_sap_sal_ord_hdr.zzhomopal_f,
         zzhomolay_f = rcd_sap_sal_ord_hdr.zzhomolay_f,
         zzloosecas_f = rcd_sap_sal_ord_hdr.zzloosecas_f,
         zzcond05_f = rcd_sap_sal_ord_hdr.zzcond05_f,
         zzcond06f = rcd_sap_sal_ord_hdr.zzcond06f,
         zzcond07_f = rcd_sap_sal_ord_hdr.zzcond07_f,
         zzcond08_f = rcd_sap_sal_ord_hdr.zzcond08_f,
         zzcond09_f = rcd_sap_sal_ord_hdr.zzcond09_f,
         zzcond10_f = rcd_sap_sal_ord_hdr.zzcond10_f,
         zzpalspace_f = rcd_sap_sal_ord_hdr.zzpalspace_f,
         zzpalbas01_f = rcd_sap_sal_ord_hdr.zzpalbas01_f,
         zzpalbas02_f = rcd_sap_sal_ord_hdr.zzpalbas02_f,
         zzpalbas03_f = rcd_sap_sal_ord_hdr.zzpalbas03_f,
         zzpalbas04_f = rcd_sap_sal_ord_hdr.zzpalbas04_f,
         zzpalbas05_f = rcd_sap_sal_ord_hdr.zzpalbas05_f,
         zzbrgew_f = rcd_sap_sal_ord_hdr.zzbrgew_f,
         zzweightpal_f = rcd_sap_sal_ord_hdr.zzweightpal_f,
         zzmeins01 = rcd_sap_sal_ord_hdr.zzmeins01,
         zzmeins02 = rcd_sap_sal_ord_hdr.zzmeins02,
         zzmeins03 = rcd_sap_sal_ord_hdr.zzmeins03,
         zzmeins04 = rcd_sap_sal_ord_hdr.zzmeins04,
         zzmeins05 = rcd_sap_sal_ord_hdr.zzmeins05,
         zzweightuom = rcd_sap_sal_ord_hdr.zzweightuom,
         zzerror = rcd_sap_sal_ord_hdr.zzerror,
         zzvsart = rcd_sap_sal_ord_hdr.zzvsart,
         zzsdabw = rcd_sap_sal_ord_hdr.zzsdabw,
         zzordrspstatus_h = rcd_sap_sal_ord_hdr.zzordrspstatus_h,
         cmgst = rcd_sap_sal_ord_hdr.cmgst,
         cmgst_bez = rcd_sap_sal_ord_hdr.cmgst_bez,
         spstg = rcd_sap_sal_ord_hdr.spstg,
         spstg_bez = rcd_sap_sal_ord_hdr.spstg_bez,
         idoc_name = rcd_sap_sal_ord_hdr.idoc_name,
         idoc_number = rcd_sap_sal_ord_hdr.idoc_number,
         idoc_timestamp = rcd_sap_sal_ord_hdr.idoc_timestamp,
         valdtn_status = rcd_sap_sal_ord_hdr.valdtn_status
       where belnr = rcd_sap_sal_ord_hdr.belnr;
      if sql%notfound then
         insert into sap_sal_ord_hdr
            (action,
             kzabs,
             curcy,
             hwaer,
             wkurs,
             zterm,
             kundeuinr,
             eigenuinr,
             bsart,
             belnr,
             ntgew,
             brgew,
             gewei,
             fkart_rl,
             ablad,
             bstzd,
             vsart,
             vsart_bez,
             recipnt_no,
             kzazu,
             autlf,
             augru,
             augru_bez,
             abrvw,
             abrvw_bez,
             fktyp,
             lifsk,
             lifsk_bez,
             empst,
             abtnr,
             delco,
             wkurs_m,
             zzexpectpb,
             zzorbdpr,
             zzmanbpr,
             zztarif,
             zznocombi,
             zzpbuom01,
             zzpbuom02,
             zzpbuom03,
             zzpbuom04,
             zzpbuom05,
             zzpbuom06,
             zzpbuom07,
             zzpbuom08,
             zzpbuom09,
             zzpbuom10,
             zzgrouping,
             zzincompleted,
             zzstatus,
             zzlogpoint,
             zzhomopal,
             zzhomolay,
             zzloosecas,
             zzcond05,
             zzcond06,
             zzcond07,
             zzcond08,
             zzcond09,
             zzcond10,
             zzpalspace,
             zzpalbas01,
             zzpalbas02,
             zzpalbas03,
             zzpalbas04,
             zzpalbas05,
             zzbrgew,
             zzweightpal,
             zzlogpoint_f,
             zzhomopal_f,
             zzhomolay_f,
             zzloosecas_f,
             zzcond05_f,
             zzcond06f,
             zzcond07_f,
             zzcond08_f,
             zzcond09_f,
             zzcond10_f,
             zzpalspace_f,
             zzpalbas01_f,
             zzpalbas02_f,
             zzpalbas03_f,
             zzpalbas04_f,
             zzpalbas05_f,
             zzbrgew_f,
             zzweightpal_f,
             zzmeins01,
             zzmeins02,
             zzmeins03,
             zzmeins04,
             zzmeins05,
             zzweightuom,
             zzerror,
             zzvsart,
             zzsdabw,
             zzordrspstatus_h,
             cmgst,
             cmgst_bez,
             spstg,
             spstg_bez,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             valdtn_status)
         values
            (rcd_sap_sal_ord_hdr.action,
             rcd_sap_sal_ord_hdr.kzabs,
             rcd_sap_sal_ord_hdr.curcy,
             rcd_sap_sal_ord_hdr.hwaer,
             rcd_sap_sal_ord_hdr.wkurs,
             rcd_sap_sal_ord_hdr.zterm,
             rcd_sap_sal_ord_hdr.kundeuinr,
             rcd_sap_sal_ord_hdr.eigenuinr,
             rcd_sap_sal_ord_hdr.bsart,
             rcd_sap_sal_ord_hdr.belnr,
             rcd_sap_sal_ord_hdr.ntgew,
             rcd_sap_sal_ord_hdr.brgew,
             rcd_sap_sal_ord_hdr.gewei,
             rcd_sap_sal_ord_hdr.fkart_rl,
             rcd_sap_sal_ord_hdr.ablad,
             rcd_sap_sal_ord_hdr.bstzd,
             rcd_sap_sal_ord_hdr.vsart,
             rcd_sap_sal_ord_hdr.vsart_bez,
             rcd_sap_sal_ord_hdr.recipnt_no,
             rcd_sap_sal_ord_hdr.kzazu,
             rcd_sap_sal_ord_hdr.autlf,
             rcd_sap_sal_ord_hdr.augru,
             rcd_sap_sal_ord_hdr.augru_bez,
             rcd_sap_sal_ord_hdr.abrvw,
             rcd_sap_sal_ord_hdr.abrvw_bez,
             rcd_sap_sal_ord_hdr.fktyp,
             rcd_sap_sal_ord_hdr.lifsk,
             rcd_sap_sal_ord_hdr.lifsk_bez,
             rcd_sap_sal_ord_hdr.empst,
             rcd_sap_sal_ord_hdr.abtnr,
             rcd_sap_sal_ord_hdr.delco,
             rcd_sap_sal_ord_hdr.wkurs_m,
             rcd_sap_sal_ord_hdr.zzexpectpb,
             rcd_sap_sal_ord_hdr.zzorbdpr,
             rcd_sap_sal_ord_hdr.zzmanbpr,
             rcd_sap_sal_ord_hdr.zztarif,
             rcd_sap_sal_ord_hdr.zznocombi,
             rcd_sap_sal_ord_hdr.zzpbuom01,
             rcd_sap_sal_ord_hdr.zzpbuom02,
             rcd_sap_sal_ord_hdr.zzpbuom03,
             rcd_sap_sal_ord_hdr.zzpbuom04,
             rcd_sap_sal_ord_hdr.zzpbuom05,
             rcd_sap_sal_ord_hdr.zzpbuom06,
             rcd_sap_sal_ord_hdr.zzpbuom07,
             rcd_sap_sal_ord_hdr.zzpbuom08,
             rcd_sap_sal_ord_hdr.zzpbuom09,
             rcd_sap_sal_ord_hdr.zzpbuom10,
             rcd_sap_sal_ord_hdr.zzgrouping,
             rcd_sap_sal_ord_hdr.zzincompleted,
             rcd_sap_sal_ord_hdr.zzstatus,
             rcd_sap_sal_ord_hdr.zzlogpoint,
             rcd_sap_sal_ord_hdr.zzhomopal,
             rcd_sap_sal_ord_hdr.zzhomolay,
             rcd_sap_sal_ord_hdr.zzloosecas,
             rcd_sap_sal_ord_hdr.zzcond05,
             rcd_sap_sal_ord_hdr.zzcond06,
             rcd_sap_sal_ord_hdr.zzcond07,
             rcd_sap_sal_ord_hdr.zzcond08,
             rcd_sap_sal_ord_hdr.zzcond09,
             rcd_sap_sal_ord_hdr.zzcond10,
             rcd_sap_sal_ord_hdr.zzpalspace,
             rcd_sap_sal_ord_hdr.zzpalbas01,
             rcd_sap_sal_ord_hdr.zzpalbas02,
             rcd_sap_sal_ord_hdr.zzpalbas03,
             rcd_sap_sal_ord_hdr.zzpalbas04,
             rcd_sap_sal_ord_hdr.zzpalbas05,
             rcd_sap_sal_ord_hdr.zzbrgew,
             rcd_sap_sal_ord_hdr.zzweightpal,
             rcd_sap_sal_ord_hdr.zzlogpoint_f,
             rcd_sap_sal_ord_hdr.zzhomopal_f,
             rcd_sap_sal_ord_hdr.zzhomolay_f,
             rcd_sap_sal_ord_hdr.zzloosecas_f,
             rcd_sap_sal_ord_hdr.zzcond05_f,
             rcd_sap_sal_ord_hdr.zzcond06f,
             rcd_sap_sal_ord_hdr.zzcond07_f,
             rcd_sap_sal_ord_hdr.zzcond08_f,
             rcd_sap_sal_ord_hdr.zzcond09_f,
             rcd_sap_sal_ord_hdr.zzcond10_f,
             rcd_sap_sal_ord_hdr.zzpalspace_f,
             rcd_sap_sal_ord_hdr.zzpalbas01_f,
             rcd_sap_sal_ord_hdr.zzpalbas02_f,
             rcd_sap_sal_ord_hdr.zzpalbas03_f,
             rcd_sap_sal_ord_hdr.zzpalbas04_f,
             rcd_sap_sal_ord_hdr.zzpalbas05_f,
             rcd_sap_sal_ord_hdr.zzbrgew_f,
             rcd_sap_sal_ord_hdr.zzweightpal_f,
             rcd_sap_sal_ord_hdr.zzmeins01,
             rcd_sap_sal_ord_hdr.zzmeins02,
             rcd_sap_sal_ord_hdr.zzmeins03,
             rcd_sap_sal_ord_hdr.zzmeins04,
             rcd_sap_sal_ord_hdr.zzmeins05,
             rcd_sap_sal_ord_hdr.zzweightuom,
             rcd_sap_sal_ord_hdr.zzerror,
             rcd_sap_sal_ord_hdr.zzvsart,
             rcd_sap_sal_ord_hdr.zzsdabw,
             rcd_sap_sal_ord_hdr.zzordrspstatus_h,
             rcd_sap_sal_ord_hdr.cmgst,
             rcd_sap_sal_ord_hdr.cmgst_bez,
             rcd_sap_sal_ord_hdr.spstg,
             rcd_sap_sal_ord_hdr.spstg_bez,
             rcd_sap_sal_ord_hdr.idoc_name,
             rcd_sap_sal_ord_hdr.idoc_number,
             rcd_sap_sal_ord_hdr.idoc_timestamp,
             rcd_sap_sal_ord_hdr.valdtn_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record ORG routine */
   /**************************************************/
   procedure process_record_org(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ORG', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_org.belnr := rcd_sap_sal_ord_hdr.belnr;
      rcd_sap_sal_ord_org.orgseq := rcd_sap_sal_ord_org.orgseq + 1;
      rcd_sap_sal_ord_org.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_sal_ord_org.orgid := lics_inbound_utility.get_variable('ORGID');

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
      if rcd_sap_sal_ord_org.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ORG.BELNR');
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

      insert into sap_sal_ord_org
         (belnr,
          orgseq,
          qualf,
          orgid)
      values
         (rcd_sap_sal_ord_org.belnr,
          rcd_sap_sal_ord_org.orgseq,
          rcd_sap_sal_ord_org.qualf,
          rcd_sap_sal_ord_org.orgid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_org;

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
      rcd_sap_sal_ord_dat.belnr := rcd_sap_sal_ord_hdr.belnr;
      rcd_sap_sal_ord_dat.datseq := rcd_sap_sal_ord_dat.datseq + 1;
      rcd_sap_sal_ord_dat.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_sap_sal_ord_dat.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_sal_ord_dat.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_sap_sal_ord_dat.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAT.BELNR');
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

      insert into sap_sal_ord_dat
         (belnr,
          datseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_sap_sal_ord_dat.belnr,
          rcd_sap_sal_ord_dat.datseq,
          rcd_sap_sal_ord_dat.iddat,
          rcd_sap_sal_ord_dat.datum,
          rcd_sap_sal_ord_dat.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

   /**************************************************/
   /* This procedure performs the record CON routine */
   /**************************************************/
   procedure process_record_con(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CON', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_con.belnr := rcd_sap_sal_ord_hdr.belnr;
      rcd_sap_sal_ord_con.conseq := rcd_sap_sal_ord_con.conseq + 1;
      rcd_sap_sal_ord_con.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_sap_sal_ord_con.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_sap_sal_ord_con.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_sap_sal_ord_con.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_sap_sal_ord_con.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_sap_sal_ord_con.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_sap_sal_ord_con.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_sap_sal_ord_con.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_sap_sal_ord_con.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_sap_sal_ord_con.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_sap_sal_ord_con.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_sap_sal_ord_con.koein := lics_inbound_utility.get_variable('KOEIN');

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
      if rcd_sap_sal_ord_con.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CON.BELNR');
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

      insert into sap_sal_ord_con
         (belnr,
          conseq,
          alckz,
          kschl,
          kotxt,
          betrg,
          kperc,
          krate,
          uprbs,
          meaun,
          kobtr,
          mwskz,
          msatz,
          koein)
      values
         (rcd_sap_sal_ord_con.belnr,
          rcd_sap_sal_ord_con.conseq,
          rcd_sap_sal_ord_con.alckz,
          rcd_sap_sal_ord_con.kschl,
          rcd_sap_sal_ord_con.kotxt,
          rcd_sap_sal_ord_con.betrg,
          rcd_sap_sal_ord_con.kperc,
          rcd_sap_sal_ord_con.krate,
          rcd_sap_sal_ord_con.uprbs,
          rcd_sap_sal_ord_con.meaun,
          rcd_sap_sal_ord_con.kobtr,
          rcd_sap_sal_ord_con.mwskz,
          rcd_sap_sal_ord_con.msatz,
          rcd_sap_sal_ord_con.koein);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_con;

   /**************************************************/
   /* This procedure performs the record PNR routine */
   /**************************************************/
   procedure process_record_pnr(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PNR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_pnr.belnr := rcd_sap_sal_ord_hdr.belnr;
      rcd_sap_sal_ord_pnr.pnrseq := rcd_sap_sal_ord_pnr.pnrseq + 1;
      rcd_sap_sal_ord_pnr.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_sap_sal_ord_pnr.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_sap_sal_ord_pnr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_sap_sal_ord_pnr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_sap_sal_ord_pnr.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_sap_sal_ord_pnr.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_sap_sal_ord_pnr.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_sap_sal_ord_pnr.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_sap_sal_ord_pnr.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_sap_sal_ord_pnr.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_sap_sal_ord_pnr.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_sap_sal_ord_pnr.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_sap_sal_ord_pnr.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_sap_sal_ord_pnr.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_sap_sal_ord_pnr.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_sap_sal_ord_pnr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_sap_sal_ord_pnr.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_sap_sal_ord_pnr.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_sap_sal_ord_pnr.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_sap_sal_ord_pnr.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_sap_sal_ord_pnr.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_sap_sal_ord_pnr.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_sap_sal_ord_pnr.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_sap_sal_ord_pnr.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_sap_sal_ord_pnr.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_sap_sal_ord_pnr.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_sap_sal_ord_pnr.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_sap_sal_ord_pnr.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_sap_sal_ord_pnr.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_sap_sal_ord_pnr.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_sap_sal_ord_pnr.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_sap_sal_ord_pnr.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_sap_sal_ord_pnr.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_sap_sal_ord_pnr.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_sap_sal_ord_pnr.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_sap_sal_ord_pnr.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_sap_sal_ord_pnr.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_sap_sal_ord_pnr.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_sap_sal_ord_pnr.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_sap_sal_ord_pnr.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_sap_sal_ord_pnr.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_sap_sal_ord_pnr.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_sap_sal_ord_pnr.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_sap_sal_ord_pnr.title := lics_inbound_utility.get_variable('TITLE');

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
      if rcd_sap_sal_ord_pnr.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PNR.BELNR');
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

      insert into sap_sal_ord_pnr
         (belnr,
          pnrseq,
          parvw,
          partn,
          lifnr,
          name1,
          name2,
          name3,
          name4,
          stras,
          strs2,
          pfach,
          ort01,
          counc,
          pstlz,
          pstl2,
          land1,
          ablad,
          pernr,
          parnr,
          telf1,
          telf2,
          telbx,
          telfx,
          teltx,
          telx1,
          spras,
          anred,
          ort02,
          hausn,
          stock,
          regio,
          parge,
          isoal,
          isonu,
          fcode,
          ihrez,
          bname,
          paorg,
          orgtx,
          pagru,
          knref,
          ilnnr,
          pfort,
          spras_iso,
          title)
      values
         (rcd_sap_sal_ord_pnr.belnr,
          rcd_sap_sal_ord_pnr.pnrseq,
          rcd_sap_sal_ord_pnr.parvw,
          rcd_sap_sal_ord_pnr.partn,
          rcd_sap_sal_ord_pnr.lifnr,
          rcd_sap_sal_ord_pnr.name1,
          rcd_sap_sal_ord_pnr.name2,
          rcd_sap_sal_ord_pnr.name3,
          rcd_sap_sal_ord_pnr.name4,
          rcd_sap_sal_ord_pnr.stras,
          rcd_sap_sal_ord_pnr.strs2,
          rcd_sap_sal_ord_pnr.pfach,
          rcd_sap_sal_ord_pnr.ort01,
          rcd_sap_sal_ord_pnr.counc,
          rcd_sap_sal_ord_pnr.pstlz,
          rcd_sap_sal_ord_pnr.pstl2,
          rcd_sap_sal_ord_pnr.land1,
          rcd_sap_sal_ord_pnr.ablad,
          rcd_sap_sal_ord_pnr.pernr,
          rcd_sap_sal_ord_pnr.parnr,
          rcd_sap_sal_ord_pnr.telf1,
          rcd_sap_sal_ord_pnr.telf2,
          rcd_sap_sal_ord_pnr.telbx,
          rcd_sap_sal_ord_pnr.telfx,
          rcd_sap_sal_ord_pnr.teltx,
          rcd_sap_sal_ord_pnr.telx1,
          rcd_sap_sal_ord_pnr.spras,
          rcd_sap_sal_ord_pnr.anred,
          rcd_sap_sal_ord_pnr.ort02,
          rcd_sap_sal_ord_pnr.hausn,
          rcd_sap_sal_ord_pnr.stock,
          rcd_sap_sal_ord_pnr.regio,
          rcd_sap_sal_ord_pnr.parge,
          rcd_sap_sal_ord_pnr.isoal,
          rcd_sap_sal_ord_pnr.isonu,
          rcd_sap_sal_ord_pnr.fcode,
          rcd_sap_sal_ord_pnr.ihrez,
          rcd_sap_sal_ord_pnr.bname,
          rcd_sap_sal_ord_pnr.paorg,
          rcd_sap_sal_ord_pnr.orgtx,
          rcd_sap_sal_ord_pnr.pagru,
          rcd_sap_sal_ord_pnr.knref,
          rcd_sap_sal_ord_pnr.ilnnr,
          rcd_sap_sal_ord_pnr.pfort,
          rcd_sap_sal_ord_pnr.spras_iso,
          rcd_sap_sal_ord_pnr.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pnr;

   /**************************************************/
   /* This procedure performs the record REF routine */
   /**************************************************/
   procedure process_record_ref(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('REF', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_ref.belnr := rcd_sap_sal_ord_hdr.belnr;
      rcd_sap_sal_ord_ref.refseq := rcd_sap_sal_ord_ref.refseq + 1;
      rcd_sap_sal_ord_ref.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_sal_ord_ref.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_sap_sal_ord_ref.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_sap_sal_ord_ref.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_sal_ord_ref.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_sap_sal_ord_ref.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - REF.BELNR');
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

      insert into sap_sal_ord_ref
         (belnr,
          refseq,
          qualf,
          refnr,
          posnr,
          datum,
          uzeit)
      values
         (rcd_sap_sal_ord_ref.belnr,
          rcd_sap_sal_ord_ref.refseq,
          rcd_sap_sal_ord_ref.qualf,
          rcd_sap_sal_ord_ref.refnr,
          rcd_sap_sal_ord_ref.posnr,
          rcd_sap_sal_ord_ref.datum,
          rcd_sap_sal_ord_ref.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ref;

   /**************************************************/
   /* This procedure performs the record GEN routine */
   /**************************************************/
   procedure process_record_gen(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('GEN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_gen.belnr := rcd_sap_sal_ord_hdr.belnr;
      rcd_sap_sal_ord_gen.genseq := rcd_sap_sal_ord_gen.genseq + 1;
      rcd_sap_sal_ord_gen.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_sap_sal_ord_gen.action := lics_inbound_utility.get_variable('ACTION');
      rcd_sap_sal_ord_gen.pstyp := lics_inbound_utility.get_variable('PSTYP');
      rcd_sap_sal_ord_gen.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_sap_sal_ord_gen.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_sap_sal_ord_gen.menee := lics_inbound_utility.get_variable('MENEE');
      rcd_sap_sal_ord_gen.bmng2 := lics_inbound_utility.get_variable('BMNG2');
      rcd_sap_sal_ord_gen.pmene := lics_inbound_utility.get_variable('PMENE');
      rcd_sap_sal_ord_gen.abftz := lics_inbound_utility.get_variable('ABFTZ');
      rcd_sap_sal_ord_gen.vprei := lics_inbound_utility.get_variable('VPREI');
      rcd_sap_sal_ord_gen.peinh := lics_inbound_utility.get_variable('PEINH');
      rcd_sap_sal_ord_gen.netwr := lics_inbound_utility.get_variable('NETWR');
      rcd_sap_sal_ord_gen.anetw := lics_inbound_utility.get_variable('ANETW');
      rcd_sap_sal_ord_gen.skfbp := lics_inbound_utility.get_variable('SKFBP');
      rcd_sap_sal_ord_gen.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_sap_sal_ord_gen.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_sap_sal_ord_gen.einkz := lics_inbound_utility.get_variable('EINKZ');
      rcd_sap_sal_ord_gen.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_sap_sal_ord_gen.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_sap_sal_ord_gen.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_sap_sal_ord_gen.uepos := lics_inbound_utility.get_variable('UEPOS');
      rcd_sap_sal_ord_gen.grkor := lics_inbound_utility.get_variable('GRKOR');
      rcd_sap_sal_ord_gen.evers := lics_inbound_utility.get_variable('EVERS');
      rcd_sap_sal_ord_gen.bpumn := lics_inbound_utility.get_number('BPUMN',null);
      rcd_sap_sal_ord_gen.bpumz := lics_inbound_utility.get_number('BPUMZ',null);
      rcd_sap_sal_ord_gen.abgru := lics_inbound_utility.get_variable('ABGRU');
      rcd_sap_sal_ord_gen.abgrt := lics_inbound_utility.get_variable('ABGRT');
      rcd_sap_sal_ord_gen.antlf := lics_inbound_utility.get_variable('ANTLF');
      rcd_sap_sal_ord_gen.fixmg := lics_inbound_utility.get_variable('FIXMG');
      rcd_sap_sal_ord_gen.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_sap_sal_ord_gen.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_sap_sal_ord_gen.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_sap_sal_ord_gen.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_sap_sal_ord_gen.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_sap_sal_ord_gen.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_sap_sal_ord_gen.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_sap_sal_ord_gen.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_sap_sal_ord_gen.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_sap_sal_ord_gen.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_sap_sal_ord_gen.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_sap_sal_ord_gen.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_sap_sal_ord_gen.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_sap_sal_ord_gen.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_sap_sal_ord_gen.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_sap_sal_ord_gen.valtg := lics_inbound_utility.get_number('VALTG',null);
      rcd_sap_sal_ord_gen.hipos := lics_inbound_utility.get_number('HIPOS',null);
      rcd_sap_sal_ord_gen.hievw := lics_inbound_utility.get_variable('HIEVW');
      rcd_sap_sal_ord_gen.posguid := lics_inbound_utility.get_variable('POSGUID');
      rcd_sap_sal_ord_gen.zzlogpoint := lics_inbound_utility.get_variable('ZZLOGPOINT');
      rcd_sap_sal_ord_gen.zzhomopal := lics_inbound_utility.get_variable('ZZHOMOPAL');
      rcd_sap_sal_ord_gen.zzhomolay := lics_inbound_utility.get_variable('ZZHOMOLAY');
      rcd_sap_sal_ord_gen.zzloosecas := lics_inbound_utility.get_variable('ZZLOOSECAS');
      rcd_sap_sal_ord_gen.zzcond05 := lics_inbound_utility.get_variable('ZZCOND05');
      rcd_sap_sal_ord_gen.zzcond06 := lics_inbound_utility.get_variable('ZZCOND06');
      rcd_sap_sal_ord_gen.zzcond07 := lics_inbound_utility.get_variable('ZZCOND07');
      rcd_sap_sal_ord_gen.zzcond08 := lics_inbound_utility.get_variable('ZZCOND08');
      rcd_sap_sal_ord_gen.zzcond09 := lics_inbound_utility.get_variable('ZZCOND09');
      rcd_sap_sal_ord_gen.zzcond10 := lics_inbound_utility.get_variable('ZZCOND10');
      rcd_sap_sal_ord_gen.zzpalspace := lics_inbound_utility.get_variable('ZZPALSPACE');
      rcd_sap_sal_ord_gen.zzpalbas01 := lics_inbound_utility.get_variable('ZZPALBAS01');
      rcd_sap_sal_ord_gen.zzpalbas02 := lics_inbound_utility.get_variable('ZZPALBAS02');
      rcd_sap_sal_ord_gen.zzpalbas03 := lics_inbound_utility.get_variable('ZZPALBAS03');
      rcd_sap_sal_ord_gen.zzpalbas04 := lics_inbound_utility.get_variable('ZZPALBAS04');
      rcd_sap_sal_ord_gen.zzpalbas05 := lics_inbound_utility.get_variable('ZZPALBAS05');
      rcd_sap_sal_ord_gen.zzbrgew := lics_inbound_utility.get_variable('ZZBRGEW');
      rcd_sap_sal_ord_gen.zzweightpal := lics_inbound_utility.get_variable('ZZWEIGHTPAL');
      rcd_sap_sal_ord_gen.zzlogpoint_f := lics_inbound_utility.get_variable('ZZLOGPOINT_F');
      rcd_sap_sal_ord_gen.zzhomopal_f := lics_inbound_utility.get_variable('ZZHOMOPAL_F');
      rcd_sap_sal_ord_gen.zzhomolay_f := lics_inbound_utility.get_variable('ZZHOMOLAY_F');
      rcd_sap_sal_ord_gen.zzloosecas_f := lics_inbound_utility.get_variable('ZZLOOSECAS_F');
      rcd_sap_sal_ord_gen.zzcond05_f := lics_inbound_utility.get_variable('ZZCOND05_F');
      rcd_sap_sal_ord_gen.zzcond06f := lics_inbound_utility.get_variable('ZZCOND06F');
      rcd_sap_sal_ord_gen.zzcond07_f := lics_inbound_utility.get_variable('ZZCOND07_F');
      rcd_sap_sal_ord_gen.zzcond08_f := lics_inbound_utility.get_variable('ZZCOND08_F');
      rcd_sap_sal_ord_gen.zzcond09_f := lics_inbound_utility.get_variable('ZZCOND09_F');
      rcd_sap_sal_ord_gen.zzcond10_f := lics_inbound_utility.get_variable('ZZCOND10_F');
      rcd_sap_sal_ord_gen.zzpalspace_f := lics_inbound_utility.get_variable('ZZPALSPACE_F');
      rcd_sap_sal_ord_gen.zzpalbas01_f := lics_inbound_utility.get_variable('ZZPALBAS01_F');
      rcd_sap_sal_ord_gen.zzpalbas02_f := lics_inbound_utility.get_variable('ZZPALBAS02_F');
      rcd_sap_sal_ord_gen.zzpalbas03_f := lics_inbound_utility.get_variable('ZZPALBAS03_F');
      rcd_sap_sal_ord_gen.zzpalbas04_f := lics_inbound_utility.get_variable('ZZPALBAS04_F');
      rcd_sap_sal_ord_gen.zzpalbas05_f := lics_inbound_utility.get_variable('ZZPALBAS05_F');
      rcd_sap_sal_ord_gen.zzbrgew_f := lics_inbound_utility.get_variable('ZZBRGEW_F');
      rcd_sap_sal_ord_gen.zzweightpal_f := lics_inbound_utility.get_variable('ZZWEIGHTPAL_F');
      rcd_sap_sal_ord_gen.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
      rcd_sap_sal_ord_gen.zzmeins02 := lics_inbound_utility.get_variable('ZZMEINS02');
      rcd_sap_sal_ord_gen.zzmeins03 := lics_inbound_utility.get_variable('ZZMEINS03');
      rcd_sap_sal_ord_gen.zzmeins04 := lics_inbound_utility.get_variable('ZZMEINS04');
      rcd_sap_sal_ord_gen.zzmeins05 := lics_inbound_utility.get_variable('ZZMEINS05');
      rcd_sap_sal_ord_gen.zzweightuom := lics_inbound_utility.get_variable('ZZWEIGHTUOM');
      rcd_sap_sal_ord_gen.zzmvgr1 := lics_inbound_utility.get_variable('ZZMVGR1');
      rcd_sap_sal_ord_gen.zzqtypaluom := lics_inbound_utility.get_variable('ZZQTYPALUOM');
      rcd_sap_sal_ord_gen.zzpcbqty := lics_inbound_utility.get_variable('ZZPCBQTY');
      rcd_sap_sal_ord_gen.zzmatwa := lics_inbound_utility.get_variable('ZZMATWA');
      rcd_sap_sal_ord_gen.zzordrspstatus_l := lics_inbound_utility.get_variable('ZZORDRSPSTATUS_L');
      rcd_sap_sal_ord_gen.zzean_cu := lics_inbound_utility.get_variable('ZZEAN_CU');
      rcd_sap_sal_ord_gen.zzmenge_in_pc := lics_inbound_utility.get_variable('ZZMENGE_IN_PC');
      rcd_sap_sal_ord_gen.posex_id := lics_inbound_utility.get_variable('POSEX_ID');
      rcd_sap_sal_ord_gen.config_id := lics_inbound_utility.get_variable('CONFIG_ID');
      rcd_sap_sal_ord_gen.inst_id := lics_inbound_utility.get_variable('INST_ID');
      rcd_sap_sal_ord_gen.qualf := lics_inbound_utility.get_number('QUALF',null);
      rcd_sap_sal_ord_gen.icc := lics_inbound_utility.get_number('ICC',null);
      rcd_sap_sal_ord_gen.moi := lics_inbound_utility.get_variable('MOI');
      rcd_sap_sal_ord_gen.pri := lics_inbound_utility.get_variable('PRI');
      rcd_sap_sal_ord_gen.acn := lics_inbound_utility.get_variable('ACN');
      rcd_sap_sal_ord_gen.function := lics_inbound_utility.get_variable('FUNCTION');
      rcd_sap_sal_ord_gen.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_sap_sal_ord_gen.tdobname := lics_inbound_utility.get_variable('TDOBNAME');
      rcd_sap_sal_ord_gen.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_sap_sal_ord_gen.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_sap_sal_ord_gen.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_sap_sal_ord_gen.langua_iso := lics_inbound_utility.get_variable('LANGUA_ISO');
      rcd_sap_sal_ord_gen.order_line_status := ods_constants.sales_order_status_outstanding;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_sal_ord_irf.irfseq := 0;
      rcd_sap_sal_ord_idt.idtseq := 0;
      rcd_sap_sal_ord_ico.icoseq := 0;
      rcd_sap_sal_ord_isc.iscseq := 0;
      rcd_sap_sal_ord_ipn.ipnseq := 0;
      rcd_sap_sal_ord_iid.iidseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_sal_ord_gen.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - GEN.BELNR');
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

      insert into sap_sal_ord_gen
         (belnr,
          genseq,
          posex,
          action,
          pstyp,
          kzabs,
          menge,
          menee,
          bmng2,
          pmene,
          abftz,
          vprei,
          peinh,
          netwr,
          anetw,
          skfbp,
          ntgew,
          gewei,
          einkz,
          curcy,
          preis,
          matkl,
          uepos,
          grkor,
          evers,
          bpumn,
          bpumz,
          abgru,
          abgrt,
          antlf,
          fixmg,
          kzazu,
          brgew,
          pstyv,
          empst,
          abtnr,
          abrvw,
          werks,
          lprio,
          lprio_bez,
          route,
          route_bez,
          lgort,
          vstel,
          delco,
          matnr,
          valtg,
          hipos,
          hievw,
          posguid,
          zzlogpoint,
          zzhomopal,
          zzhomolay,
          zzloosecas,
          zzcond05,
          zzcond06,
          zzcond07,
          zzcond08,
          zzcond09,
          zzcond10,
          zzpalspace,
          zzpalbas01,
          zzpalbas02,
          zzpalbas03,
          zzpalbas04,
          zzpalbas05,
          zzbrgew,
          zzweightpal,
          zzlogpoint_f,
          zzhomopal_f,
          zzhomolay_f,
          zzloosecas_f,
          zzcond05_f,
          zzcond06f,
          zzcond07_f,
          zzcond08_f,
          zzcond09_f,
          zzcond10_f,
          zzpalspace_f,
          zzpalbas01_f,
          zzpalbas02_f,
          zzpalbas03_f,
          zzpalbas04_f,
          zzpalbas05_f,
          zzbrgew_f,
          zzweightpal_f,
          zzmeins01,
          zzmeins02,
          zzmeins03,
          zzmeins04,
          zzmeins05,
          zzweightuom,
          zzmvgr1,
          zzqtypaluom,
          zzpcbqty,
          zzmatwa,
          zzordrspstatus_l,
          zzean_cu,
          zzmenge_in_pc,
          posex_id,
          config_id,
          inst_id,
          qualf,
          icc,
          moi,
          pri,
          acn,
          function,
          tdobject,
          tdobname,
          tdid,
          tdspras,
          tdtexttype,
          langua_iso,
          order_line_status)
      values
         (rcd_sap_sal_ord_gen.belnr,
          rcd_sap_sal_ord_gen.genseq,
          rcd_sap_sal_ord_gen.posex,
          rcd_sap_sal_ord_gen.action,
          rcd_sap_sal_ord_gen.pstyp,
          rcd_sap_sal_ord_gen.kzabs,
          rcd_sap_sal_ord_gen.menge,
          rcd_sap_sal_ord_gen.menee,
          rcd_sap_sal_ord_gen.bmng2,
          rcd_sap_sal_ord_gen.pmene,
          rcd_sap_sal_ord_gen.abftz,
          rcd_sap_sal_ord_gen.vprei,
          rcd_sap_sal_ord_gen.peinh,
          rcd_sap_sal_ord_gen.netwr,
          rcd_sap_sal_ord_gen.anetw,
          rcd_sap_sal_ord_gen.skfbp,
          rcd_sap_sal_ord_gen.ntgew,
          rcd_sap_sal_ord_gen.gewei,
          rcd_sap_sal_ord_gen.einkz,
          rcd_sap_sal_ord_gen.curcy,
          rcd_sap_sal_ord_gen.preis,
          rcd_sap_sal_ord_gen.matkl,
          rcd_sap_sal_ord_gen.uepos,
          rcd_sap_sal_ord_gen.grkor,
          rcd_sap_sal_ord_gen.evers,
          rcd_sap_sal_ord_gen.bpumn,
          rcd_sap_sal_ord_gen.bpumz,
          rcd_sap_sal_ord_gen.abgru,
          rcd_sap_sal_ord_gen.abgrt,
          rcd_sap_sal_ord_gen.antlf,
          rcd_sap_sal_ord_gen.fixmg,
          rcd_sap_sal_ord_gen.kzazu,
          rcd_sap_sal_ord_gen.brgew,
          rcd_sap_sal_ord_gen.pstyv,
          rcd_sap_sal_ord_gen.empst,
          rcd_sap_sal_ord_gen.abtnr,
          rcd_sap_sal_ord_gen.abrvw,
          rcd_sap_sal_ord_gen.werks,
          rcd_sap_sal_ord_gen.lprio,
          rcd_sap_sal_ord_gen.lprio_bez,
          rcd_sap_sal_ord_gen.route,
          rcd_sap_sal_ord_gen.route_bez,
          rcd_sap_sal_ord_gen.lgort,
          rcd_sap_sal_ord_gen.vstel,
          rcd_sap_sal_ord_gen.delco,
          rcd_sap_sal_ord_gen.matnr,
          rcd_sap_sal_ord_gen.valtg,
          rcd_sap_sal_ord_gen.hipos,
          rcd_sap_sal_ord_gen.hievw,
          rcd_sap_sal_ord_gen.posguid,
          rcd_sap_sal_ord_gen.zzlogpoint,
          rcd_sap_sal_ord_gen.zzhomopal,
          rcd_sap_sal_ord_gen.zzhomolay,
          rcd_sap_sal_ord_gen.zzloosecas,
          rcd_sap_sal_ord_gen.zzcond05,
          rcd_sap_sal_ord_gen.zzcond06,
          rcd_sap_sal_ord_gen.zzcond07,
          rcd_sap_sal_ord_gen.zzcond08,
          rcd_sap_sal_ord_gen.zzcond09,
          rcd_sap_sal_ord_gen.zzcond10,
          rcd_sap_sal_ord_gen.zzpalspace,
          rcd_sap_sal_ord_gen.zzpalbas01,
          rcd_sap_sal_ord_gen.zzpalbas02,
          rcd_sap_sal_ord_gen.zzpalbas03,
          rcd_sap_sal_ord_gen.zzpalbas04,
          rcd_sap_sal_ord_gen.zzpalbas05,
          rcd_sap_sal_ord_gen.zzbrgew,
          rcd_sap_sal_ord_gen.zzweightpal,
          rcd_sap_sal_ord_gen.zzlogpoint_f,
          rcd_sap_sal_ord_gen.zzhomopal_f,
          rcd_sap_sal_ord_gen.zzhomolay_f,
          rcd_sap_sal_ord_gen.zzloosecas_f,
          rcd_sap_sal_ord_gen.zzcond05_f,
          rcd_sap_sal_ord_gen.zzcond06f,
          rcd_sap_sal_ord_gen.zzcond07_f,
          rcd_sap_sal_ord_gen.zzcond08_f,
          rcd_sap_sal_ord_gen.zzcond09_f,
          rcd_sap_sal_ord_gen.zzcond10_f,
          rcd_sap_sal_ord_gen.zzpalspace_f,
          rcd_sap_sal_ord_gen.zzpalbas01_f,
          rcd_sap_sal_ord_gen.zzpalbas02_f,
          rcd_sap_sal_ord_gen.zzpalbas03_f,
          rcd_sap_sal_ord_gen.zzpalbas04_f,
          rcd_sap_sal_ord_gen.zzpalbas05_f,
          rcd_sap_sal_ord_gen.zzbrgew_f,
          rcd_sap_sal_ord_gen.zzweightpal_f,
          rcd_sap_sal_ord_gen.zzmeins01,
          rcd_sap_sal_ord_gen.zzmeins02,
          rcd_sap_sal_ord_gen.zzmeins03,
          rcd_sap_sal_ord_gen.zzmeins04,
          rcd_sap_sal_ord_gen.zzmeins05,
          rcd_sap_sal_ord_gen.zzweightuom,
          rcd_sap_sal_ord_gen.zzmvgr1,
          rcd_sap_sal_ord_gen.zzqtypaluom,
          rcd_sap_sal_ord_gen.zzpcbqty,
          rcd_sap_sal_ord_gen.zzmatwa,
          rcd_sap_sal_ord_gen.zzordrspstatus_l,
          rcd_sap_sal_ord_gen.zzean_cu,
          rcd_sap_sal_ord_gen.zzmenge_in_pc,
          rcd_sap_sal_ord_gen.posex_id,
          rcd_sap_sal_ord_gen.config_id,
          rcd_sap_sal_ord_gen.inst_id,
          rcd_sap_sal_ord_gen.qualf,
          rcd_sap_sal_ord_gen.icc,
          rcd_sap_sal_ord_gen.moi,
          rcd_sap_sal_ord_gen.pri,
          rcd_sap_sal_ord_gen.acn,
          rcd_sap_sal_ord_gen.function,
          rcd_sap_sal_ord_gen.tdobject,
          rcd_sap_sal_ord_gen.tdobname,
          rcd_sap_sal_ord_gen.tdid,
          rcd_sap_sal_ord_gen.tdspras,
          rcd_sap_sal_ord_gen.tdtexttype,
          rcd_sap_sal_ord_gen.langua_iso,
          rcd_sap_sal_ord_gen.order_line_status);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_gen;

   /**************************************************/
   /* This procedure performs the record IRF routine */
   /**************************************************/
   procedure process_record_irf(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IRF', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_irf.belnr := rcd_sap_sal_ord_gen.belnr;
      rcd_sap_sal_ord_irf.genseq := rcd_sap_sal_ord_gen.genseq;
      rcd_sap_sal_ord_irf.irfseq := rcd_sap_sal_ord_irf.irfseq + 1;
      rcd_sap_sal_ord_irf.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_sal_ord_irf.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_sap_sal_ord_irf.zeile := lics_inbound_utility.get_variable('ZEILE');
      rcd_sap_sal_ord_irf.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_sal_ord_irf.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_sap_sal_ord_irf.bsark := lics_inbound_utility.get_variable('BSARK');
      rcd_sap_sal_ord_irf.ihrez := lics_inbound_utility.get_variable('IHREZ');

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
      if rcd_sap_sal_ord_irf.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IRF.BELNR');
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

      insert into sap_sal_ord_irf
         (belnr,
          genseq,
          irfseq,
          qualf,
          refnr,
          zeile,
          datum,
          uzeit,
          bsark,
          ihrez)
      values
         (rcd_sap_sal_ord_irf.belnr,
          rcd_sap_sal_ord_irf.genseq,
          rcd_sap_sal_ord_irf.irfseq,
          rcd_sap_sal_ord_irf.qualf,
          rcd_sap_sal_ord_irf.refnr,
          rcd_sap_sal_ord_irf.zeile,
          rcd_sap_sal_ord_irf.datum,
          rcd_sap_sal_ord_irf.uzeit,
          rcd_sap_sal_ord_irf.bsark,
          rcd_sap_sal_ord_irf.ihrez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_irf;

   /**************************************************/
   /* This procedure performs the record IDT routine */
   /**************************************************/
   procedure process_record_idt(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IDT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_idt.belnr := rcd_sap_sal_ord_gen.belnr;
      rcd_sap_sal_ord_idt.genseq := rcd_sap_sal_ord_gen.genseq;
      rcd_sap_sal_ord_idt.idtseq := rcd_sap_sal_ord_idt.idtseq + 1;
      rcd_sap_sal_ord_idt.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_sap_sal_ord_idt.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_sal_ord_idt.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_sap_sal_ord_idt.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IDT.BELNR');
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

      insert into sap_sal_ord_idt
         (belnr,
          genseq,
          idtseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_sap_sal_ord_idt.belnr,
          rcd_sap_sal_ord_idt.genseq,
          rcd_sap_sal_ord_idt.idtseq,
          rcd_sap_sal_ord_idt.iddat,
          rcd_sap_sal_ord_idt.datum,
          rcd_sap_sal_ord_idt.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_idt;

   /**************************************************/
   /* This procedure performs the record ICO routine */
   /**************************************************/
   procedure process_record_ico(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ICO', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_ico.belnr := rcd_sap_sal_ord_gen.belnr;
      rcd_sap_sal_ord_ico.genseq := rcd_sap_sal_ord_gen.genseq;
      rcd_sap_sal_ord_ico.icoseq := rcd_sap_sal_ord_ico.icoseq + 1;
      rcd_sap_sal_ord_ico.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_sap_sal_ord_ico.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_sap_sal_ord_ico.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_sap_sal_ord_ico.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_sap_sal_ord_ico.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_sap_sal_ord_ico.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_sap_sal_ord_ico.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_sap_sal_ord_ico.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_sap_sal_ord_ico.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_sap_sal_ord_ico.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_sap_sal_ord_ico.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_sap_sal_ord_ico.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_sap_sal_ord_ico.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_sap_sal_ord_ico.koein := lics_inbound_utility.get_variable('KOEIN');
      rcd_sap_sal_ord_ico.curtp := lics_inbound_utility.get_variable('CURTP');
      rcd_sap_sal_ord_ico.kobas := lics_inbound_utility.get_variable('KOBAS');

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
      if rcd_sap_sal_ord_ico.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ICO.BELNR');
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

      insert into sap_sal_ord_ico
         (belnr,
          genseq,
          icoseq,
          alckz,
          kschl,
          kotxt,
          betrg,
          kperc,
          krate,
          uprbs,
          meaun,
          kobtr,
          menge,
          preis,
          mwskz,
          msatz,
          koein,
          curtp,
          kobas)
      values
         (rcd_sap_sal_ord_ico.belnr,
          rcd_sap_sal_ord_ico.genseq,
          rcd_sap_sal_ord_ico.icoseq,
          rcd_sap_sal_ord_ico.alckz,
          rcd_sap_sal_ord_ico.kschl,
          rcd_sap_sal_ord_ico.kotxt,
          rcd_sap_sal_ord_ico.betrg,
          rcd_sap_sal_ord_ico.kperc,
          rcd_sap_sal_ord_ico.krate,
          rcd_sap_sal_ord_ico.uprbs,
          rcd_sap_sal_ord_ico.meaun,
          rcd_sap_sal_ord_ico.kobtr,
          rcd_sap_sal_ord_ico.menge,
          rcd_sap_sal_ord_ico.preis,
          rcd_sap_sal_ord_ico.mwskz,
          rcd_sap_sal_ord_ico.msatz,
          rcd_sap_sal_ord_ico.koein,
          rcd_sap_sal_ord_ico.curtp,
          rcd_sap_sal_ord_ico.kobas);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ico;

   /**************************************************/
   /* This procedure performs the record ISC routine */
   /**************************************************/
   procedure process_record_isc(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISC', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_isc.belnr := rcd_sap_sal_ord_gen.belnr;
      rcd_sap_sal_ord_isc.genseq := rcd_sap_sal_ord_gen.genseq;
      rcd_sap_sal_ord_isc.iscseq := rcd_sap_sal_ord_isc.iscseq + 1;
      rcd_sap_sal_ord_isc.wmeng := lics_inbound_utility.get_variable('WMENG');
      rcd_sap_sal_ord_isc.ameng := lics_inbound_utility.get_variable('AMENG');
      rcd_sap_sal_ord_isc.edatu := lics_inbound_utility.get_variable('EDATU');
      rcd_sap_sal_ord_isc.ezeit := lics_inbound_utility.get_variable('EZEIT');
      rcd_sap_sal_ord_isc.edatu_old := lics_inbound_utility.get_variable('EDATU_OLD');
      rcd_sap_sal_ord_isc.ezeit_old := lics_inbound_utility.get_variable('EZEIT_OLD');
      rcd_sap_sal_ord_isc.action := lics_inbound_utility.get_variable('ACTION');

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
      if rcd_sap_sal_ord_isc.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISC.BELNR');
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

      insert into sap_sal_ord_isc
         (belnr,
          genseq,
          iscseq,
          wmeng,
          ameng,
          edatu,
          ezeit,
          edatu_old,
          ezeit_old,
          action)
      values
         (rcd_sap_sal_ord_isc.belnr,
          rcd_sap_sal_ord_isc.genseq,
          rcd_sap_sal_ord_isc.iscseq,
          rcd_sap_sal_ord_isc.wmeng,
          rcd_sap_sal_ord_isc.ameng,
          rcd_sap_sal_ord_isc.edatu,
          rcd_sap_sal_ord_isc.ezeit,
          rcd_sap_sal_ord_isc.edatu_old,
          rcd_sap_sal_ord_isc.ezeit_old,
          rcd_sap_sal_ord_isc.action);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isc;

   /**************************************************/
   /* This procedure performs the record IPN routine */
   /**************************************************/
   procedure process_record_ipn(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IPN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_ipn.belnr := rcd_sap_sal_ord_gen.belnr;
      rcd_sap_sal_ord_ipn.genseq := rcd_sap_sal_ord_gen.genseq;
      rcd_sap_sal_ord_ipn.ipnseq := rcd_sap_sal_ord_ipn.ipnseq + 1;
      rcd_sap_sal_ord_ipn.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_sap_sal_ord_ipn.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_sap_sal_ord_ipn.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_sap_sal_ord_ipn.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_sap_sal_ord_ipn.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_sap_sal_ord_ipn.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_sap_sal_ord_ipn.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_sap_sal_ord_ipn.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_sap_sal_ord_ipn.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_sap_sal_ord_ipn.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_sap_sal_ord_ipn.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_sap_sal_ord_ipn.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_sap_sal_ord_ipn.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_sap_sal_ord_ipn.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_sap_sal_ord_ipn.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_sap_sal_ord_ipn.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_sap_sal_ord_ipn.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_sap_sal_ord_ipn.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_sap_sal_ord_ipn.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_sap_sal_ord_ipn.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_sap_sal_ord_ipn.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_sap_sal_ord_ipn.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_sap_sal_ord_ipn.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_sap_sal_ord_ipn.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_sap_sal_ord_ipn.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_sap_sal_ord_ipn.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_sap_sal_ord_ipn.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_sap_sal_ord_ipn.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_sap_sal_ord_ipn.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_sap_sal_ord_ipn.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_sap_sal_ord_ipn.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_sap_sal_ord_ipn.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_sap_sal_ord_ipn.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_sap_sal_ord_ipn.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_sap_sal_ord_ipn.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_sap_sal_ord_ipn.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_sap_sal_ord_ipn.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_sap_sal_ord_ipn.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_sap_sal_ord_ipn.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_sap_sal_ord_ipn.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_sap_sal_ord_ipn.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_sap_sal_ord_ipn.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_sap_sal_ord_ipn.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_sap_sal_ord_ipn.title := lics_inbound_utility.get_variable('TITLE');

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
      if rcd_sap_sal_ord_ipn.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IPN.BELNR');
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

      insert into sap_sal_ord_ipn
         (belnr,
          genseq,
          ipnseq,
          parvw,
          partn,
          lifnr,
          name1,
          name2,
          name3,
          name4,
          stras,
          strs2,
          pfach,
          ort01,
          counc,
          pstlz,
          pstl2,
          land1,
          ablad,
          pernr,
          parnr,
          telf1,
          telf2,
          telbx,
          telfx,
          teltx,
          telx1,
          spras,
          anred,
          ort02,
          hausn,
          stock,
          regio,
          parge,
          isoal,
          isonu,
          fcode,
          ihrez,
          bname,
          paorg,
          orgtx,
          pagru,
          knref,
          ilnnr,
          pfort,
          spras_iso,
          title)
      values
         (rcd_sap_sal_ord_ipn.belnr,
          rcd_sap_sal_ord_ipn.genseq,
          rcd_sap_sal_ord_ipn.ipnseq,
          rcd_sap_sal_ord_ipn.parvw,
          rcd_sap_sal_ord_ipn.partn,
          rcd_sap_sal_ord_ipn.lifnr,
          rcd_sap_sal_ord_ipn.name1,
          rcd_sap_sal_ord_ipn.name2,
          rcd_sap_sal_ord_ipn.name3,
          rcd_sap_sal_ord_ipn.name4,
          rcd_sap_sal_ord_ipn.stras,
          rcd_sap_sal_ord_ipn.strs2,
          rcd_sap_sal_ord_ipn.pfach,
          rcd_sap_sal_ord_ipn.ort01,
          rcd_sap_sal_ord_ipn.counc,
          rcd_sap_sal_ord_ipn.pstlz,
          rcd_sap_sal_ord_ipn.pstl2,
          rcd_sap_sal_ord_ipn.land1,
          rcd_sap_sal_ord_ipn.ablad,
          rcd_sap_sal_ord_ipn.pernr,
          rcd_sap_sal_ord_ipn.parnr,
          rcd_sap_sal_ord_ipn.telf1,
          rcd_sap_sal_ord_ipn.telf2,
          rcd_sap_sal_ord_ipn.telbx,
          rcd_sap_sal_ord_ipn.telfx,
          rcd_sap_sal_ord_ipn.teltx,
          rcd_sap_sal_ord_ipn.telx1,
          rcd_sap_sal_ord_ipn.spras,
          rcd_sap_sal_ord_ipn.anred,
          rcd_sap_sal_ord_ipn.ort02,
          rcd_sap_sal_ord_ipn.hausn,
          rcd_sap_sal_ord_ipn.stock,
          rcd_sap_sal_ord_ipn.regio,
          rcd_sap_sal_ord_ipn.parge,
          rcd_sap_sal_ord_ipn.isoal,
          rcd_sap_sal_ord_ipn.isonu,
          rcd_sap_sal_ord_ipn.fcode,
          rcd_sap_sal_ord_ipn.ihrez,
          rcd_sap_sal_ord_ipn.bname,
          rcd_sap_sal_ord_ipn.paorg,
          rcd_sap_sal_ord_ipn.orgtx,
          rcd_sap_sal_ord_ipn.pagru,
          rcd_sap_sal_ord_ipn.knref,
          rcd_sap_sal_ord_ipn.ilnnr,
          rcd_sap_sal_ord_ipn.pfort,
          rcd_sap_sal_ord_ipn.spras_iso,
          rcd_sap_sal_ord_ipn.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ipn;

   /**************************************************/
   /* This procedure performs the record IID routine */
   /**************************************************/
   procedure process_record_iid(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IID', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_iid.belnr := rcd_sap_sal_ord_gen.belnr;
      rcd_sap_sal_ord_iid.genseq := rcd_sap_sal_ord_gen.genseq;
      rcd_sap_sal_ord_iid.iidseq := rcd_sap_sal_ord_iid.iidseq + 1;
      rcd_sap_sal_ord_iid.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_sal_ord_iid.idtnr := lics_inbound_utility.get_variable('IDTNR');
      rcd_sap_sal_ord_iid.ktext := lics_inbound_utility.get_variable('KTEXT');
      rcd_sap_sal_ord_iid.mfrpn := lics_inbound_utility.get_variable('MFRPN');
      rcd_sap_sal_ord_iid.mfrnr := lics_inbound_utility.get_variable('MFRNR');

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
      if rcd_sap_sal_ord_iid.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IID.BELNR');
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

      insert into sap_sal_ord_iid
         (belnr,
          genseq,
          iidseq,
          qualf,
          idtnr,
          ktext,
          mfrpn,
          mfrnr)
      values
         (rcd_sap_sal_ord_iid.belnr,
          rcd_sap_sal_ord_iid.genseq,
          rcd_sap_sal_ord_iid.iidseq,
          rcd_sap_sal_ord_iid.qualf,
          rcd_sap_sal_ord_iid.idtnr,
          rcd_sap_sal_ord_iid.ktext,
          rcd_sap_sal_ord_iid.mfrpn,
          rcd_sap_sal_ord_iid.mfrnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_iid;

   /**************************************************/
   /* This procedure performs the record SMY routine */
   /**************************************************/
   procedure process_record_smy(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SMY', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_sal_ord_smy.belnr := rcd_sap_sal_ord_hdr.belnr;
      rcd_sap_sal_ord_smy.smyseq := rcd_sap_sal_ord_smy.smyseq + 1;
      rcd_sap_sal_ord_smy.sumid := lics_inbound_utility.get_variable('SUMID');
      rcd_sap_sal_ord_smy.summe := lics_inbound_utility.get_variable('SUMME');
      rcd_sap_sal_ord_smy.sunit := lics_inbound_utility.get_variable('SUNIT');
      rcd_sap_sal_ord_smy.waerq := lics_inbound_utility.get_variable('WAERQ');

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
      if rcd_sap_sal_ord_smy.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - SMY.BELNR');
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

      insert into sap_sal_ord_smy
         (belnr,
          smyseq,
          sumid,
          summe,
          sunit,
          waerq)
      values
         (rcd_sap_sal_ord_smy.belnr,
          rcd_sap_sal_ord_smy.smyseq,
          rcd_sap_sal_ord_smy.sumid,
          rcd_sap_sal_ord_smy.summe,
          rcd_sap_sal_ord_smy.sunit,
          rcd_sap_sal_ord_smy.waerq);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_smy;

   /**************************************************/
   /* This procedure performs the load trace routine */
   /**************************************************/
   procedure load_trace(par_belnr in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_sequence number;
      rcd_sap_sal_ord_trace sap_sal_ord_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_data is
         select t01.order_doc_num,
                t01.currcy_code,
                t01.exch_rate,
                t01.order_reasn_code,
                t02.creatn_date,
                t02.creatn_yyyyppdd,
                t02.creatn_yyyyppw,
                t02.creatn_yyyypp,
                t02.creatn_yyyymm,
                t02.order_eff_date,
                t02.order_eff_yyyyppdd,
                t02.order_eff_yyyyppw,
                t02.order_eff_yyyypp,
                t02.order_eff_yyyymm,
                t03.order_type_code,
                t03.sales_org_code,
                t03.distbn_chnl_code,
                t03.division_code,
                t04.hdr_sold_to_cust_code,
                t04.hdr_bill_to_cust_code,
                t04.hdr_payer_cust_code,
                t04.hdr_ship_to_cust_code,
                t05.order_doc_line_num,
                t05.order_uom_code,
                t05.plant_code,
                t05.storage_locn_code,
                t05.order_usage_code,
                t05.order_line_rejectn_code,
                t05.order_qty,
                t05.order_gross_weight,
                t05.order_net_weight,
                t05.order_weight_unit,
                t06.cust_order_doc_num,
                t06.cust_order_doc_line_num,
                t06.cust_order_due_date,
                t07.matl_code,
                t07.matl_entd,
                t08.confirmed_qty,
                t08.confirmed_date,
                t08.confirmed_yyyyppdd,
                t08.confirmed_yyyyppw,
                t08.confirmed_yyyypp,
                t08.confirmed_yyyymm,
                t09.gen_sold_to_cust_code,
                t09.gen_bill_to_cust_code,
                t09.gen_payer_cust_code,
                t09.gen_ship_to_cust_code,
                t10.order_gsv
          from --
               -- Sales order header information
               --
               (select t01.belnr,
                       t01.belnr as order_doc_num,
                       t01.curcy as currcy_code,
                       nvl(dw_to_number(t01.wkurs),1) as exch_rate,
                       t01.augru as order_reasn_code
                  from sap_sal_ord_hdr t01
                 where t01.belnr = par_belnr) t01,
               --
               -- Sales order date information
               --
               (select t01.belnr,
                       t01.order_eff_date as order_eff_date,
                       t01.creatn_date as creatn_date,
                       t02.mars_yyyyppdd as order_eff_yyyyppdd,
                       t02.mars_week as order_eff_yyyyppw,
                       t02.mars_period as order_eff_yyyypp,
                       (t02.year_num * 100) + t02.month_num as order_eff_yyyymm,
                       t03.mars_yyyyppdd as creatn_yyyyppdd,
                       t03.mars_week as creatn_yyyyppw,
                       t03.mars_period as creatn_yyyypp,
                       (t03.year_num * 100) + t03.month_num as creatn_yyyymm
                  from (select t01.belnr as belnr,
                               max(case when t01.iddat = '002' then dw_to_date(t01.datum,'yyyymmdd') end) as order_eff_date,
                               max(case when t01.iddat = '025' then trunc(dw_to_timezone(dw_to_date(t01.datum||t01.uzeit,'yyyymmddhh24miss'),'Australia/NSW','America/New_York')) end) as creatn_date
                          from sap_sal_ord_dat t01
                         where t01.belnr = par_belnr
                           and t01.iddat in ('002','025')
                         group by t01.belnr) t01,
                       mars_date t02,
                       mars_date t03
                 where t01.order_eff_date = t02.calendar_date(+)
                   and t01.creatn_date = t03.calendar_date(+)) t02,
               --
               -- Sales order organisation information
               --
               (select t01.belnr,
                       max(case when t01.qualf = '012' then t01.orgid end) as order_type_code,
                       max(case when t01.qualf = '008' then t01.orgid end) as sales_org_code,
                       max(case when t01.qualf = '007' then t01.orgid end) as distbn_chnl_code,
                       max(case when t01.qualf = '006' then t01.orgid end) as division_code
                  from sap_sal_ord_org t01
                 where t01.belnr = par_belnr
                   and t01.qualf in ('006','007','008','012')
                 group by t01.belnr) t03,
               --
               -- Sales order partner information
               --
               (select t01.belnr,
                       max(case when t01.parvw = 'AG' then t01.partn end) as hdr_sold_to_cust_code,
                       max(case when t01.parvw = 'RE' then t01.partn end) as hdr_bill_to_cust_code,
                       max(case when t01.parvw = 'RG' then t01.partn end) as hdr_payer_cust_code,
                       max(case when t01.parvw = 'WE' then t01.partn end) as hdr_ship_to_cust_code
                  from sap_sal_ord_pnr t01
                 where t01.belnr = par_belnr
                   and t01.parvw in ('AG','RE','RG','WE')
                 group by t01.belnr) t04,
               --
               -- Sales order line information
               --
               (select t01.belnr,
                       t01.genseq,
                       t01.posex as order_doc_line_num,
                       t01.menee as order_uom_code,
                       t01.werks as plant_code,
                       t01.lgort as storage_locn_code,
                       t01.abrvw as order_usage_code,
                       t01.abgru as order_line_rejectn_code,
                       nvl(dw_to_number(t01.menge),0) as order_qty,
                       nvl(dw_to_number(t01.brgew),0) as order_gross_weight,
                       nvl(dw_to_number(t01.ntgew),0) as order_net_weight,
                       t01.gewei as order_weight_unit
                  from sap_sal_ord_gen t01
                 where t01.belnr = par_belnr
                   and not(t01.pstyv in ('ZAPS','ZAPA'))
                   and nvl(dw_to_number(t01.menge),0) != 0) t05,
               --
               -- Sales order line reference information
               --
               (select t01.belnr,
                       t01.genseq,
                       max(case when t01.qualf = '001' then t01.refnr end) as cust_order_doc_num,
                       max(case when t01.qualf = '001' then t01.zeile end) as cust_order_doc_line_num,
                       max(case when t01.qualf = '001' then dw_to_date(t01.datum,'yyyymmdd') end) as cust_order_due_date
                  from sap_sal_ord_irf t01
                 where t01.belnr = par_belnr
                   and t01.qualf in ('001')
                 group by t01.belnr, t01.genseq) t06,
               --
               -- Sales order line identifier information
               --
               (select t01.belnr,
                       t01.genseq,
                       max(case when t01.qualf = '002' then t01.idtnr end) as matl_code,
                       max(case when t01.qualf = 'Z01' then t01.idtnr end) as matl_entd
                  from sap_sal_ord_iid t01
                 where t01.belnr = par_belnr
                   and t01.qualf in ('002','Z01')
                 group by t01.belnr, t01.genseq) t07,
               --
               -- Sales order line schedule information
               --
               (select t01.belnr,
                       t01.genseq,
                       t01.confirmed_qty as confirmed_qty,
                       t01.confirmed_date as confirmed_date,
                       t02.mars_yyyyppdd as confirmed_yyyyppdd,
                       t02.mars_week as confirmed_yyyyppw,
                       t02.mars_period as confirmed_yyyypp,
                       (t02.year_num * 100) + t02.month_num as confirmed_yyyymm
                  from (select t01.belnr as belnr,
                               t01.genseq as genseq,
                               sum(nvl(dw_to_number(t01.wmeng),0)) as confirmed_qty,
                               max(dw_to_date(t01.edatu,'yyyymmdd')) as confirmed_date
                          from sap_sal_ord_isc t01
                         where t01.belnr = par_belnr
                         group by t01.belnr, t01.genseq) t01,
                       mars_date t02
                 where t01.confirmed_date = t02.calendar_date(+)) t08,
               --
               -- Sales order line partner information
               --
               (select t01.belnr,
                       t01.genseq,
                       max(case when t01.parvw = 'AG' then t01.partn end) as gen_sold_to_cust_code,
                       max(case when t01.parvw = 'RE' then t01.partn end) as gen_bill_to_cust_code,
                       max(case when t01.parvw = 'RG' then t01.partn end) as gen_payer_cust_code,
                       max(case when t01.parvw = 'WE' then t01.partn end) as gen_ship_to_cust_code
                  from sap_sal_ord_ipn t01
                 where t01.belnr = par_belnr
                   and t01.parvw in ('AG','RE','RG','WE')
                 group by t01.belnr, t01.genseq) t09,
               --
               -- Sales order line value information
               --
               (select t01.belnr,
                       t01.genseq,
                       sum(order_gsv) as order_gsv
                  from (select t01.belnr,
                               t01.genseq,
                               decode(t01.alckz,'-',-1,1)*nvl(dw_to_number(t01.betrg),0) as order_gsv
                          from sap_sal_ord_ico t01
                         where t01.belnr = par_belnr
                           and (upper(t01.kschl) = 'ZV01' or
                                upper(t01.kotxt) = 'GSV')
                         union all
                        select t01.belnr,
                               t01.genseq,
                               decode(t01.alckz,'-',-1,1)*nvl(dw_to_number(t01.betrg),0) as order_gsv
                          from sap_sal_ord_ico t01,
                               (select t01.belnr,
                                       t01.genseq
                                  from sap_sal_ord_ico t01
                                 where t01.belnr = par_belnr
                                   and upper(t01.kschl) = 'ZZ01') t02
                         where t01.belnr = t02.belnr
                           and t01.genseq = t02.genseq
                           and t01.belnr = par_belnr
                           and upper(t01.kotxt) = 'GROSS VALUE') t01
                 group by t01.belnr, t01.genseq) t10
         --
         -- Joins
         --
         where t01.belnr = t02.belnr(+)
           and t01.belnr = t03.belnr(+)
           and t01.belnr = t04.belnr(+)
           and t01.belnr = t05.belnr(+)
           and t05.belnr = t06.belnr(+)
           and t05.genseq = t06.genseq(+)
           and t05.belnr = t07.belnr(+)
           and t05.genseq = t07.genseq(+)
           and t05.belnr = t08.belnr(+)
           and t05.genseq = t08.genseq(+)
           and t05.belnr = t09.belnr(+)
           and t05.genseq = t09.genseq(+)
           and t05.belnr = t10.belnr(+)
           and t05.genseq = t10.genseq(+);
      rcd_ods_data csr_ods_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the sequence for current stream action
      /*-*/
      select sap_trace_sequence.nextval into var_sequence from dual;

      /*-*/
      /* Initialise the sales order trace data
      /*-*/
      rcd_sap_sal_ord_trace.trace_seqn := var_sequence;
      rcd_sap_sal_ord_trace.trace_date := sysdate;
      rcd_sap_sal_ord_trace.trace_status := '*ACTIVE';

      /*-*/
      /* Retrieve the sales order trace detail
      /*-*/
      open csr_ods_data;
      loop
         fetch csr_ods_data into rcd_ods_data;
         if csr_ods_data%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the sales order trace row
         /*-*/
         rcd_sap_sal_ord_trace.company_code := rcd_ods_data.sales_org_code;
         rcd_sap_sal_ord_trace.order_doc_num := rcd_ods_data.order_doc_num;
         rcd_sap_sal_ord_trace.currcy_code := rcd_ods_data.currcy_code;
         rcd_sap_sal_ord_trace.exch_rate := rcd_ods_data.exch_rate;
         rcd_sap_sal_ord_trace.order_reasn_code := rcd_ods_data.order_reasn_code;
         rcd_sap_sal_ord_trace.creatn_date := rcd_ods_data.creatn_date;
         rcd_sap_sal_ord_trace.creatn_yyyyppdd := rcd_ods_data.creatn_yyyyppdd;
         rcd_sap_sal_ord_trace.creatn_yyyyppw := rcd_ods_data.creatn_yyyyppw;
         rcd_sap_sal_ord_trace.creatn_yyyypp := rcd_ods_data.creatn_yyyypp;
         rcd_sap_sal_ord_trace.creatn_yyyymm := rcd_ods_data.creatn_yyyymm;
         rcd_sap_sal_ord_trace.order_eff_date := rcd_ods_data.order_eff_date;
         rcd_sap_sal_ord_trace.order_eff_yyyyppdd := rcd_ods_data.order_eff_yyyyppdd;
         rcd_sap_sal_ord_trace.order_eff_yyyyppw := rcd_ods_data.order_eff_yyyyppw;
         rcd_sap_sal_ord_trace.order_eff_yyyypp := rcd_ods_data.order_eff_yyyypp;
         rcd_sap_sal_ord_trace.order_eff_yyyymm := rcd_ods_data.order_eff_yyyymm;
         rcd_sap_sal_ord_trace.order_type_code := rcd_ods_data.order_type_code;
         rcd_sap_sal_ord_trace.sales_org_code := rcd_ods_data.sales_org_code;
         rcd_sap_sal_ord_trace.distbn_chnl_code := rcd_ods_data.distbn_chnl_code;
         rcd_sap_sal_ord_trace.division_code := rcd_ods_data.division_code;
         rcd_sap_sal_ord_trace.hdr_sold_to_cust_code := rcd_ods_data.hdr_sold_to_cust_code;
         rcd_sap_sal_ord_trace.hdr_bill_to_cust_code := rcd_ods_data.hdr_bill_to_cust_code;
         rcd_sap_sal_ord_trace.hdr_payer_cust_code := rcd_ods_data.hdr_payer_cust_code;
         rcd_sap_sal_ord_trace.hdr_ship_to_cust_code := rcd_ods_data.hdr_ship_to_cust_code;
         rcd_sap_sal_ord_trace.order_doc_line_num := rcd_ods_data.order_doc_line_num;
         rcd_sap_sal_ord_trace.order_uom_code := rcd_ods_data.order_uom_code;
         rcd_sap_sal_ord_trace.plant_code := rcd_ods_data.plant_code;
         rcd_sap_sal_ord_trace.storage_locn_code := rcd_ods_data.storage_locn_code;
         rcd_sap_sal_ord_trace.order_usage_code := rcd_ods_data.order_usage_code;
         rcd_sap_sal_ord_trace.order_line_rejectn_code := rcd_ods_data.order_line_rejectn_code;
         rcd_sap_sal_ord_trace.order_qty := rcd_ods_data.order_qty;
         rcd_sap_sal_ord_trace.order_gross_weight := rcd_ods_data.order_gross_weight;
         rcd_sap_sal_ord_trace.order_net_weight := rcd_ods_data.order_net_weight;
         rcd_sap_sal_ord_trace.order_weight_unit := rcd_ods_data.order_weight_unit;
         rcd_sap_sal_ord_trace.cust_order_doc_num := rcd_ods_data.cust_order_doc_num;
         rcd_sap_sal_ord_trace.cust_order_doc_line_num := rcd_ods_data.cust_order_doc_line_num;
         rcd_sap_sal_ord_trace.cust_order_due_date := rcd_ods_data.cust_order_due_date;
         rcd_sap_sal_ord_trace.matl_code := rcd_ods_data.matl_code;
         rcd_sap_sal_ord_trace.matl_entd := rcd_ods_data.matl_entd;
         rcd_sap_sal_ord_trace.confirmed_qty := rcd_ods_data.confirmed_qty;
         rcd_sap_sal_ord_trace.confirmed_date := rcd_ods_data.confirmed_date;
         rcd_sap_sal_ord_trace.confirmed_yyyyppdd := rcd_ods_data.confirmed_yyyyppdd;
         rcd_sap_sal_ord_trace.confirmed_yyyyppw := rcd_ods_data.confirmed_yyyyppw;
         rcd_sap_sal_ord_trace.confirmed_yyyypp := rcd_ods_data.confirmed_yyyypp;
         rcd_sap_sal_ord_trace.confirmed_yyyymm := rcd_ods_data.confirmed_yyyymm;
         rcd_sap_sal_ord_trace.gen_sold_to_cust_code := rcd_ods_data.gen_sold_to_cust_code;
         rcd_sap_sal_ord_trace.gen_bill_to_cust_code := rcd_ods_data.gen_bill_to_cust_code;
         rcd_sap_sal_ord_trace.gen_payer_cust_code := rcd_ods_data.gen_payer_cust_code;
         rcd_sap_sal_ord_trace.gen_ship_to_cust_code := rcd_ods_data.gen_ship_to_cust_code;
         rcd_sap_sal_ord_trace.order_gsv := rcd_ods_data.order_gsv;

         /*-*/
         /* Insert the sales order trace row
         /*-*/
         insert into sap_sal_ord_trace values rcd_sap_sal_ord_trace;

      end loop;
      close csr_ods_data;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_trace;

end ods_atlods13;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_atlods13 for ods_app.ods_atlods13;
grant execute on ods_atlods13 to lics_app;