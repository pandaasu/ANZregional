/******************/
/* Package Header */
/******************/
create or replace package ods_atlods18 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_atlods18
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - atlods18 - Inbound Invoice Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004      ISI            Created
    2007/10   Steve Gregan   Included SAP_INV_TRACE table

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_atlods18;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_atlods18 as

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
   procedure process_record_con(par_record in varchar2);
   procedure process_record_pnr(par_record in varchar2);
   procedure process_record_ref(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);
   procedure process_record_cur(par_record in varchar2);
   procedure process_record_org(par_record in varchar2);
   procedure process_record_gen(par_record in varchar2);
   procedure process_record_gez(par_record in varchar2);
   procedure process_record_mat(par_record in varchar2);
   procedure process_record_irf(par_record in varchar2);
   procedure process_record_idt(par_record in varchar2);
   procedure process_record_iob(par_record in varchar2);
   procedure process_record_ias(par_record in varchar2);
   procedure process_record_ipn(par_record in varchar2);
   procedure process_record_icn(par_record in varchar2);
   procedure process_record_smy(par_record in varchar2);
   procedure load_trace(par_belnr in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_ctl_mescod varchar2(3);
   var_ctl_mesfct varchar2(3);
   rcd_ods_control ods_definition.idoc_control;
   rcd_sap_inv_hdr sap_inv_hdr%rowtype;
   rcd_sap_inv_con sap_inv_con%rowtype;
   rcd_sap_inv_pnr sap_inv_pnr%rowtype;
   rcd_sap_inv_ref sap_inv_ref%rowtype;
   rcd_sap_inv_dat sap_inv_dat%rowtype;
   rcd_sap_inv_cur sap_inv_cur%rowtype;
   rcd_sap_inv_org sap_inv_org%rowtype;
   rcd_sap_inv_gen sap_inv_gen%rowtype;
   rcd_sap_inv_mat sap_inv_mat%rowtype;
   rcd_sap_inv_irf sap_inv_irf%rowtype;
   rcd_sap_inv_idt sap_inv_idt%rowtype;
   rcd_sap_inv_iob sap_inv_iob%rowtype;
   rcd_sap_inv_ias sap_inv_ias%rowtype;
   rcd_sap_inv_ipn sap_inv_ipn%rowtype;
   rcd_sap_inv_icn sap_inv_icn%rowtype;
   rcd_sap_inv_smy sap_inv_smy%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IDOC_MESCOD',3);
      lics_inbound_utility.set_definition('CTL','IDOC_MESFCT',3);
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
      lics_inbound_utility.set_definition('HDR','Z_EDI_RELEVANT',3);
      lics_inbound_utility.set_definition('HDR','ZLSCH',1);
      lics_inbound_utility.set_definition('HDR','TEXT1',30);
      lics_inbound_utility.set_definition('HDR','VBTYP',1);
      lics_inbound_utility.set_definition('HDR','EXPNR',20);
      lics_inbound_utility.set_definition('HDR','REPRINT',1);
      lics_inbound_utility.set_definition('HDR','CRPC_VERSION',2);
      lics_inbound_utility.set_definition('HDR','ZZSPLITINVLINES',1);
      lics_inbound_utility.set_definition('HDR','BBBNR',7);
      lics_inbound_utility.set_definition('HDR','BBSNR',5);
      lics_inbound_utility.set_definition('HDR','ABRVW2',3);
      lics_inbound_utility.set_definition('HDR','AUART',4);
      lics_inbound_utility.set_definition('HDR','ZZINTERNAL_DOC',1);
      /*-*/
      lics_inbound_utility.set_definition('CON','IDOC_CON',3);
      lics_inbound_utility.set_definition('CON','KSCHL',4);
      lics_inbound_utility.set_definition('CON','KRECH',1);
      lics_inbound_utility.set_definition('CON','KAWRT',18);
      lics_inbound_utility.set_definition('CON','AWEIN',5);
      lics_inbound_utility.set_definition('CON','AWEI1',5);
      lics_inbound_utility.set_definition('CON','KBETR',14);
      lics_inbound_utility.set_definition('CON','KOEIN',5);
      lics_inbound_utility.set_definition('CON','KOEI1',5);
      lics_inbound_utility.set_definition('CON','KKURS',12);
      lics_inbound_utility.set_definition('CON','KPEIN',6);
      lics_inbound_utility.set_definition('CON','KMEIN',3);
      lics_inbound_utility.set_definition('CON','KUMZA',6);
      lics_inbound_utility.set_definition('CON','KUMNE',6);
      lics_inbound_utility.set_definition('CON','KNTYP',1);
      lics_inbound_utility.set_definition('CON','KSTAT',1);
      lics_inbound_utility.set_definition('CON','KHERK',1);
      lics_inbound_utility.set_definition('CON','KWERT',16);
      lics_inbound_utility.set_definition('CON','KSTEU',1);
      lics_inbound_utility.set_definition('CON','KINAK',1);
      lics_inbound_utility.set_definition('CON','KOAID',1);
      lics_inbound_utility.set_definition('CON','KNUMT',10);
      lics_inbound_utility.set_definition('CON','DRUKZ',1);
      lics_inbound_utility.set_definition('CON','VTEXT',40);
      lics_inbound_utility.set_definition('CON','MWSKZ',2);
      lics_inbound_utility.set_definition('CON','STUFE',4);
      lics_inbound_utility.set_definition('CON','WEGXX',6);
      lics_inbound_utility.set_definition('CON','KFAKTOR',25);
      lics_inbound_utility.set_definition('CON','NRMNG',16);
      lics_inbound_utility.set_definition('CON','MDFLG',1);
      lics_inbound_utility.set_definition('CON','KWERT_EURO',16);
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
      lics_inbound_utility.set_definition('DAT','IDOC_DAT',3);
      lics_inbound_utility.set_definition('DAT','IDDAT',3);
      lics_inbound_utility.set_definition('DAT','DATUM',8);
      lics_inbound_utility.set_definition('DAT','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('CUR','IDOC_CUR',3);
      lics_inbound_utility.set_definition('CUR','QUALF',3);
      lics_inbound_utility.set_definition('CUR','WAERZ',3);
      lics_inbound_utility.set_definition('CUR','WAERQ',3);
      lics_inbound_utility.set_definition('CUR','KURS',12);
      lics_inbound_utility.set_definition('CUR','DATUM',8);
      lics_inbound_utility.set_definition('CUR','ZEIT',6);
      lics_inbound_utility.set_definition('CUR','KURS_M',12);
      /*-*/
      lics_inbound_utility.set_definition('ORG','IDOC_ORG',3);
      lics_inbound_utility.set_definition('ORG','QUALF',3);
      lics_inbound_utility.set_definition('ORG','ORGID',35);
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
      lics_inbound_utility.set_definition('GEN','VKORG',4);
      lics_inbound_utility.set_definition('GEN','VTWEG',2);
      lics_inbound_utility.set_definition('GEN','SPART',2);
      lics_inbound_utility.set_definition('GEN','VOLUM',16);
      lics_inbound_utility.set_definition('GEN','VOLEH',3);
      lics_inbound_utility.set_definition('GEN','PCB',18);
      lics_inbound_utility.set_definition('GEN','SPCB',18);
      lics_inbound_utility.set_definition('GEN','ZZTARIF',3);
      lics_inbound_utility.set_definition('GEN','FKLMG',15);
      lics_inbound_utility.set_definition('GEN','MEINS',3);
      lics_inbound_utility.set_definition('GEN','ZZISTDU',1);
      lics_inbound_utility.set_definition('GEN','ZZISRSU',1);
      lics_inbound_utility.set_definition('GEN','PROD_SPART',2);
      lics_inbound_utility.set_definition('GEN','PMATN_EAN',18);
      lics_inbound_utility.set_definition('GEN','TDUMATN_EAN',18);
      lics_inbound_utility.set_definition('GEN','MTPOS',4);
      lics_inbound_utility.set_definition('GEN','ORG_DLVNR',10);
      lics_inbound_utility.set_definition('GEN','ORG_DLVDT',8);
      lics_inbound_utility.set_definition('GEN','MAT_LEGACY',5);
      lics_inbound_utility.set_definition('GEN','RSU_PER_MCU',5);
      lics_inbound_utility.set_definition('GEN','MCU_PER_TDU',5);
      lics_inbound_utility.set_definition('GEN','RSU_PER_TDU',5);
      lics_inbound_utility.set_definition('GEN','NUMBER_OF_RSU',5);
      lics_inbound_utility.set_definition('GEN','VSART',2);
      lics_inbound_utility.set_definition('GEN','KNREF',30);
      lics_inbound_utility.set_definition('GEN','ZZAGGNO',4);
      lics_inbound_utility.set_definition('GEN','ZZAGTCD',2);
      lics_inbound_utility.set_definition('GEN','KWMENG',18);
      /*-*/
      lics_inbound_utility.set_definition('GEZ','IDOC_GEZ',3);
      lics_inbound_utility.set_definition('GEZ','VKORG',4);
      lics_inbound_utility.set_definition('GEZ','VTWEG',2);
      lics_inbound_utility.set_definition('GEZ','SPART',2);
      lics_inbound_utility.set_definition('GEZ','VOLUM',16);
      lics_inbound_utility.set_definition('GEZ','VOLEH',3);
      lics_inbound_utility.set_definition('GEZ','PCB',18);
      lics_inbound_utility.set_definition('GEZ','SPCB',18);
      lics_inbound_utility.set_definition('GEZ','ZZTARIF',3);
      lics_inbound_utility.set_definition('GEZ','FKLMG',15);
      lics_inbound_utility.set_definition('GEZ','MEINS',3);
      lics_inbound_utility.set_definition('GEZ','ZZISTDU',1);
      lics_inbound_utility.set_definition('GEZ','ZZISRSU',1);
      lics_inbound_utility.set_definition('GEZ','PROD_SPART',2);
      lics_inbound_utility.set_definition('GEZ','PMATN_EAN',18);
      lics_inbound_utility.set_definition('GEZ','TDUMATN_EAN',18);
      lics_inbound_utility.set_definition('GEZ','MTPOS',4);
      lics_inbound_utility.set_definition('GEZ','ORG_DLVNR',10);
      lics_inbound_utility.set_definition('GEZ','ORG_DLVDT',8);
      lics_inbound_utility.set_definition('GEZ','MAT_LEGACY',5);
      lics_inbound_utility.set_definition('GEZ','RSU_PER_MCU',5);
      lics_inbound_utility.set_definition('GEZ','MCU_PER_TDU',5);
      lics_inbound_utility.set_definition('GEZ','RSU_PER_TDU',5);
      lics_inbound_utility.set_definition('GEZ','NUMBER_OF_RSU',5);
      lics_inbound_utility.set_definition('GEZ','VSART',2);
      lics_inbound_utility.set_definition('GEZ','KNREF',30);
      lics_inbound_utility.set_definition('GEZ','ZZAGGNO',4);
      lics_inbound_utility.set_definition('GEZ','ZZAGTCD',2);
      lics_inbound_utility.set_definition('GEZ','KWMENG',18);
      /*-*/
      lics_inbound_utility.set_definition('MAT','IDOC_MAT',3);
      lics_inbound_utility.set_definition('MAT','LANGU',2);
      lics_inbound_utility.set_definition('MAT','MAKTX',40);
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
      lics_inbound_utility.set_definition('IOB','IDOC_IOB',3);
      lics_inbound_utility.set_definition('IOB','QUALF',3);
      lics_inbound_utility.set_definition('IOB','IDTNR',35);
      lics_inbound_utility.set_definition('IOB','KTEXT',70);
      lics_inbound_utility.set_definition('IOB','MFRPN',42);
      lics_inbound_utility.set_definition('IOB','MFRNR',10);
      /*-*/
      lics_inbound_utility.set_definition('IAS','IDOC_IAS',3);
      lics_inbound_utility.set_definition('IAS','QUALF',3);
      lics_inbound_utility.set_definition('IAS','BETRG',18);
      lics_inbound_utility.set_definition('IAS','KRATE',15);
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
      lics_inbound_utility.set_definition('ICN','IDOC_ICN',3);
      lics_inbound_utility.set_definition('ICN','ALCKZ',3);
      lics_inbound_utility.set_definition('ICN','KSCHL',4);
      lics_inbound_utility.set_definition('ICN','KOTXT',80);
      lics_inbound_utility.set_definition('ICN','BETRG',18);
      lics_inbound_utility.set_definition('ICN','KPERC',8);
      lics_inbound_utility.set_definition('ICN','KRATE',15);
      lics_inbound_utility.set_definition('ICN','UPRBS',9);
      lics_inbound_utility.set_definition('ICN','MEAUN',3);
      lics_inbound_utility.set_definition('ICN','KOBTR',18);
      lics_inbound_utility.set_definition('ICN','MENGE',15);
      lics_inbound_utility.set_definition('ICN','PREIS',15);
      lics_inbound_utility.set_definition('ICN','MWSKZ',7);
      lics_inbound_utility.set_definition('ICN','MSATZ',17);
      lics_inbound_utility.set_definition('ICN','KOEIN',3);
      lics_inbound_utility.set_definition('ICN','CURTP',2);
      lics_inbound_utility.set_definition('ICN','KOBAS',18);
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
         when 'CUS' then null; -- Ignore record
         when 'CON' then process_record_con(par_record);
         when 'PNR' then process_record_pnr(par_record);
         when 'ADJ' then null; -- Ignore record
         when 'REF' then process_record_ref(par_record);
         when 'DAT' then process_record_dat(par_record);
         when 'DCN' then null; -- Ignore record
         when 'TAX' then null; -- Ignore record
         when 'TOD' then null; -- Ignore record
         when 'TOP' then null; -- Ignore record
         when 'CUR' then process_record_cur(par_record);
         when 'BNK' then null; -- Ignore record
         when 'FTD' then null; -- Ignore record
         when 'TXT' then null; -- Ignore record
         when 'TXI' then null; -- Ignore record
         when 'ORG' then process_record_org(par_record);
         when 'SAL' then null; -- Ignore record
         when 'GEN' then process_record_gen(par_record);
         when 'GEZ' then process_record_gez(par_record);
         when 'MAT' then process_record_mat(par_record);
         when 'GRD' then null; -- Ignore record
         when 'IRF' then process_record_irf(par_record);
         when 'IDT' then process_record_idt(par_record);
         when 'IOB' then process_record_iob(par_record);
         when 'IAS' then process_record_ias(par_record);
         when 'IPN' then process_record_ipn(par_record);
         when 'IAJ' then null; -- Ignore record
         when 'ICN' then process_record_icn(par_record);
         when 'ICP' then null; -- Ignore record - PROMOTION SEGMENT
         when 'ITA' then null; -- Ignore record
         when 'IFT' then null; -- Ignore record
         when 'ICB' then null; -- Ignore record
         when 'ITX' then null; -- Ignore record
         when 'ITI' then null; -- Ignore record
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
      /* Update GEN lines for ZRK invoice when required
      /*-*/
      if var_trn_ignore = false and
         var_trn_error = false then
         if (rcd_sap_inv_hdr.auart = 'ZRK') then
            update sap_inv_gen
               set menge = nvl(menge,0)*-1,
                   ntgew = nvl(ntgew,0)*-1,
                   brgew = nvl(brgew,0)*-1,
                   volum = nvl(volum,0)*-1,
                   fklmg = nvl(fklmg,0)*-1,
                   kwmeng = nvl(kwmeng,0)*-1
             where belnr = rcd_sap_inv_hdr.belnr
               and pstyv = 'ZCR2';
         end if;
      end if;

      /*-*/
      /* Load the transaction trace when required
      /*-*/
      if var_trn_ignore = false and
         var_trn_error = false then
         begin
            load_trace(rcd_sap_inv_hdr.belnr);
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
            ods_atlods18_monitor.execute(rcd_sap_inv_hdr.belnr);
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

      /*-*/
      /* Extract control IDOC message data
      /*-*/
      var_ctl_mescod := lics_inbound_utility.get_variable('IDOC_MESCOD');
      var_ctl_mesfct := lics_inbound_utility.get_variable('IDOC_MESFCT');

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
      cursor csr_sap_inv_hdr_01 is
         select
            t01.belnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from sap_inv_hdr t01
         where t01.belnr = rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_hdr_01 csr_sap_inv_hdr_01%rowtype;

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
      rcd_sap_inv_hdr.action := lics_inbound_utility.get_variable('ACTION');
      rcd_sap_inv_hdr.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_sap_inv_hdr.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_sap_inv_hdr.hwaer := lics_inbound_utility.get_variable('HWAER');
      rcd_sap_inv_hdr.wkurs := lics_inbound_utility.get_variable('WKURS');
      rcd_sap_inv_hdr.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_sap_inv_hdr.kundeuinr := lics_inbound_utility.get_variable('KUNDEUINR');
      rcd_sap_inv_hdr.eigenuinr := lics_inbound_utility.get_variable('EIGENUINR');
      rcd_sap_inv_hdr.bsart := lics_inbound_utility.get_variable('BSART');
      rcd_sap_inv_hdr.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_sap_inv_hdr.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_sap_inv_hdr.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_sap_inv_hdr.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_sap_inv_hdr.fkart_rl := lics_inbound_utility.get_variable('FKART_RL');
      rcd_sap_inv_hdr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_sap_inv_hdr.bstzd := lics_inbound_utility.get_variable('BSTZD');
      rcd_sap_inv_hdr.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_sap_inv_hdr.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_sap_inv_hdr.recipnt_no := lics_inbound_utility.get_variable('RECIPNT_NO');
      rcd_sap_inv_hdr.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_sap_inv_hdr.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_sap_inv_hdr.augru := lics_inbound_utility.get_variable('AUGRU');
      rcd_sap_inv_hdr.augru_bez := lics_inbound_utility.get_variable('AUGRU_BEZ');
      rcd_sap_inv_hdr.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_sap_inv_hdr.abrvw_bez := lics_inbound_utility.get_variable('ABRVW_BEZ');
      rcd_sap_inv_hdr.fktyp := lics_inbound_utility.get_variable('FKTYP');
      rcd_sap_inv_hdr.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_sap_inv_hdr.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_sap_inv_hdr.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_sap_inv_hdr.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_sap_inv_hdr.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_sap_inv_hdr.wkurs_m := lics_inbound_utility.get_variable('WKURS_M');
      rcd_sap_inv_hdr.z_edi_relevant := lics_inbound_utility.get_variable('Z_EDI_RELEVANT');
      rcd_sap_inv_hdr.zlsch := lics_inbound_utility.get_variable('ZLSCH');
      rcd_sap_inv_hdr.text1 := lics_inbound_utility.get_variable('TEXT1');
      rcd_sap_inv_hdr.vbtyp := lics_inbound_utility.get_variable('VBTYP');
      rcd_sap_inv_hdr.expnr := lics_inbound_utility.get_variable('EXPNR');
      rcd_sap_inv_hdr.reprint := lics_inbound_utility.get_variable('REPRINT');
      rcd_sap_inv_hdr.crpc_version := lics_inbound_utility.get_variable('CRPC_VERSION');
      rcd_sap_inv_hdr.zzsplitinvlines := lics_inbound_utility.get_variable('ZZSPLITINVLINES');
      rcd_sap_inv_hdr.bbbnr := lics_inbound_utility.get_number('BBBNR',null);
      rcd_sap_inv_hdr.bbsnr := lics_inbound_utility.get_number('BBSNR',null);
      rcd_sap_inv_hdr.abrvw2 := lics_inbound_utility.get_variable('ABRVW2');
      rcd_sap_inv_hdr.auart := lics_inbound_utility.get_variable('AUART');
      rcd_sap_inv_hdr.zzinternal_doc := lics_inbound_utility.get_variable('ZZINTERNAL_DOC');
      rcd_sap_inv_hdr.mescod := var_ctl_mescod;
      rcd_sap_inv_hdr.mesfct := var_ctl_mesfct;
      rcd_sap_inv_hdr.idoc_name := rcd_ods_control.idoc_name;
      rcd_sap_inv_hdr.idoc_number := rcd_ods_control.idoc_number;
      rcd_sap_inv_hdr.idoc_timestamp := rcd_ods_control.idoc_timestamp;
      rcd_sap_inv_hdr.valdtn_status := ods_constants.valdtn_unchecked;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_inv_con.conseq := 0;
      rcd_sap_inv_pnr.pnrseq := 0;
      rcd_sap_inv_ref.refseq := 0;
      rcd_sap_inv_dat.datseq := 0;
      rcd_sap_inv_cur.curseq := 0;
      rcd_sap_inv_org.orgseq := 0;
      rcd_sap_inv_gen.genseq := 0;
      rcd_sap_inv_smy.smyseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_inv_hdr.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BELNR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_sap_inv_hdr.belnr is null) then
         var_exists := true;
         open csr_sap_inv_hdr_01;
         fetch csr_sap_inv_hdr_01 into rcd_sap_inv_hdr_01;
         if csr_sap_inv_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_sap_inv_hdr_01;
         if var_exists = true then
            if rcd_sap_inv_hdr.idoc_timestamp > rcd_sap_inv_hdr_01.idoc_timestamp then
               delete from sap_inv_smy where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_icn where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_ipn where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_ias where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_iob where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_idt where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_irf where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_mat where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_gen where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_org where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_cur where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_dat where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_ref where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_pnr where belnr = rcd_sap_inv_hdr.belnr;
               delete from sap_inv_con where belnr = rcd_sap_inv_hdr.belnr;
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

      update sap_inv_hdr set
         action = rcd_sap_inv_hdr.action,
         kzabs = rcd_sap_inv_hdr.kzabs,
         curcy = rcd_sap_inv_hdr.curcy,
         hwaer = rcd_sap_inv_hdr.hwaer,
         wkurs = rcd_sap_inv_hdr.wkurs,
         zterm = rcd_sap_inv_hdr.zterm,
         kundeuinr = rcd_sap_inv_hdr.kundeuinr,
         eigenuinr = rcd_sap_inv_hdr.eigenuinr,
         bsart = rcd_sap_inv_hdr.bsart,
         ntgew = rcd_sap_inv_hdr.ntgew,
         brgew = rcd_sap_inv_hdr.brgew,
         gewei = rcd_sap_inv_hdr.gewei,
         fkart_rl = rcd_sap_inv_hdr.fkart_rl,
         ablad = rcd_sap_inv_hdr.ablad,
         bstzd = rcd_sap_inv_hdr.bstzd,
         vsart = rcd_sap_inv_hdr.vsart,
         vsart_bez = rcd_sap_inv_hdr.vsart_bez,
         recipnt_no = rcd_sap_inv_hdr.recipnt_no,
         kzazu = rcd_sap_inv_hdr.kzazu,
         autlf = rcd_sap_inv_hdr.autlf,
         augru = rcd_sap_inv_hdr.augru,
         augru_bez = rcd_sap_inv_hdr.augru_bez,
         abrvw = rcd_sap_inv_hdr.abrvw,
         abrvw_bez = rcd_sap_inv_hdr.abrvw_bez,
         fktyp = rcd_sap_inv_hdr.fktyp,
         lifsk = rcd_sap_inv_hdr.lifsk,
         lifsk_bez = rcd_sap_inv_hdr.lifsk_bez,
         empst = rcd_sap_inv_hdr.empst,
         abtnr = rcd_sap_inv_hdr.abtnr,
         delco = rcd_sap_inv_hdr.delco,
         wkurs_m = rcd_sap_inv_hdr.wkurs_m,
         z_edi_relevant = rcd_sap_inv_hdr.z_edi_relevant,
         zlsch = rcd_sap_inv_hdr.zlsch,
         text1 = rcd_sap_inv_hdr.text1,
         vbtyp = rcd_sap_inv_hdr.vbtyp,
         expnr = rcd_sap_inv_hdr.expnr,
         reprint = rcd_sap_inv_hdr.reprint,
         crpc_version = rcd_sap_inv_hdr.crpc_version,
         zzsplitinvlines = rcd_sap_inv_hdr.zzsplitinvlines,
         bbbnr = rcd_sap_inv_hdr.bbbnr,
         bbsnr = rcd_sap_inv_hdr.bbsnr,
         abrvw2 = rcd_sap_inv_hdr.abrvw2,
         auart = rcd_sap_inv_hdr.auart,
         zzinternal_doc = rcd_sap_inv_hdr.zzinternal_doc,
         mescod = rcd_sap_inv_hdr.mescod,
         mesfct = rcd_sap_inv_hdr.mesfct,
         idoc_name = rcd_sap_inv_hdr.idoc_name,
         idoc_number = rcd_sap_inv_hdr.idoc_number,
         idoc_timestamp = rcd_sap_inv_hdr.idoc_timestamp,
         valdtn_status = rcd_sap_inv_hdr.valdtn_status
      where belnr = rcd_sap_inv_hdr.belnr;
      if sql%notfound then
         insert into sap_inv_hdr
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
             z_edi_relevant,
             zlsch,
             text1,
             vbtyp,
             expnr,
             reprint,
             crpc_version,
             zzsplitinvlines,
             bbbnr,
             bbsnr,
             abrvw2,
             auart,
             zzinternal_doc,
             mescod,
             mesfct,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             valdtn_status)
         values
            (rcd_sap_inv_hdr.action,
             rcd_sap_inv_hdr.kzabs,
             rcd_sap_inv_hdr.curcy,
             rcd_sap_inv_hdr.hwaer,
             rcd_sap_inv_hdr.wkurs,
             rcd_sap_inv_hdr.zterm,
             rcd_sap_inv_hdr.kundeuinr,
             rcd_sap_inv_hdr.eigenuinr,
             rcd_sap_inv_hdr.bsart,
             rcd_sap_inv_hdr.belnr,
             rcd_sap_inv_hdr.ntgew,
             rcd_sap_inv_hdr.brgew,
             rcd_sap_inv_hdr.gewei,
             rcd_sap_inv_hdr.fkart_rl,
             rcd_sap_inv_hdr.ablad,
             rcd_sap_inv_hdr.bstzd,
             rcd_sap_inv_hdr.vsart,
             rcd_sap_inv_hdr.vsart_bez,
             rcd_sap_inv_hdr.recipnt_no,
             rcd_sap_inv_hdr.kzazu,
             rcd_sap_inv_hdr.autlf,
             rcd_sap_inv_hdr.augru,
             rcd_sap_inv_hdr.augru_bez,
             rcd_sap_inv_hdr.abrvw,
             rcd_sap_inv_hdr.abrvw_bez,
             rcd_sap_inv_hdr.fktyp,
             rcd_sap_inv_hdr.lifsk,
             rcd_sap_inv_hdr.lifsk_bez,
             rcd_sap_inv_hdr.empst,
             rcd_sap_inv_hdr.abtnr,
             rcd_sap_inv_hdr.delco,
             rcd_sap_inv_hdr.wkurs_m,
             rcd_sap_inv_hdr.z_edi_relevant,
             rcd_sap_inv_hdr.zlsch,
             rcd_sap_inv_hdr.text1,
             rcd_sap_inv_hdr.vbtyp,
             rcd_sap_inv_hdr.expnr,
             rcd_sap_inv_hdr.reprint,
             rcd_sap_inv_hdr.crpc_version,
             rcd_sap_inv_hdr.zzsplitinvlines,
             rcd_sap_inv_hdr.bbbnr,
             rcd_sap_inv_hdr.bbsnr,
             rcd_sap_inv_hdr.abrvw2,
             rcd_sap_inv_hdr.auart,
             rcd_sap_inv_hdr.zzinternal_doc,
             rcd_sap_inv_hdr.mescod,
             rcd_sap_inv_hdr.mesfct,
             rcd_sap_inv_hdr.idoc_name,
             rcd_sap_inv_hdr.idoc_number,
             rcd_sap_inv_hdr.idoc_timestamp,
             rcd_sap_inv_hdr.valdtn_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

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
      rcd_sap_inv_con.belnr := rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_con.conseq := rcd_sap_inv_con.conseq + 1;
      rcd_sap_inv_con.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_sap_inv_con.krech := lics_inbound_utility.get_variable('KRECH');
      rcd_sap_inv_con.kawrt := lics_inbound_utility.get_number('KAWRT',null);
      rcd_sap_inv_con.awein := lics_inbound_utility.get_variable('AWEIN');
      rcd_sap_inv_con.awei1 := lics_inbound_utility.get_variable('AWEI1');
      rcd_sap_inv_con.kbetr := lics_inbound_utility.get_number('KBETR',null);
      rcd_sap_inv_con.koein := lics_inbound_utility.get_variable('KOEIN');
      rcd_sap_inv_con.koei1 := lics_inbound_utility.get_variable('KOEI1');
      rcd_sap_inv_con.kkurs := lics_inbound_utility.get_number('KKURS',null);
      rcd_sap_inv_con.kpein := lics_inbound_utility.get_number('KPEIN',null);
      rcd_sap_inv_con.kmein := lics_inbound_utility.get_variable('KMEIN');
      rcd_sap_inv_con.kumza := lics_inbound_utility.get_number('KUMZA',null);
      rcd_sap_inv_con.kumne := lics_inbound_utility.get_number('KUMNE',null);
      rcd_sap_inv_con.kntyp := lics_inbound_utility.get_variable('KNTYP');
      rcd_sap_inv_con.kstat := lics_inbound_utility.get_variable('KSTAT');
      rcd_sap_inv_con.kherk := lics_inbound_utility.get_variable('KHERK');
      rcd_sap_inv_con.kwert := lics_inbound_utility.get_number('KWERT',null);
      rcd_sap_inv_con.ksteu := lics_inbound_utility.get_variable('KSTEU');
      rcd_sap_inv_con.kinak := lics_inbound_utility.get_variable('KINAK');
      rcd_sap_inv_con.koaid := lics_inbound_utility.get_variable('KOAID');
      rcd_sap_inv_con.knumt := lics_inbound_utility.get_variable('KNUMT');
      rcd_sap_inv_con.drukz := lics_inbound_utility.get_variable('DRUKZ');
      rcd_sap_inv_con.vtext := lics_inbound_utility.get_variable('VTEXT');
      rcd_sap_inv_con.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_sap_inv_con.stufe := lics_inbound_utility.get_number('STUFE',null);
      rcd_sap_inv_con.wegxx := lics_inbound_utility.get_number('WEGXX',null);
      rcd_sap_inv_con.kfaktor := lics_inbound_utility.get_number('KFAKTOR',null);
      rcd_sap_inv_con.nrmng := lics_inbound_utility.get_number('NRMNG',null);
      rcd_sap_inv_con.mdflg := lics_inbound_utility.get_variable('MDFLG');
      rcd_sap_inv_con.kwert_euro := lics_inbound_utility.get_number('KWERT_EURO',null);

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
      if rcd_sap_inv_con.belnr is null then
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

      insert into sap_inv_con
         (belnr,
          conseq,
          kschl,
          krech,
          kawrt,
          awein,
          awei1,
          kbetr,
          koein,
          koei1,
          kkurs,
          kpein,
          kmein,
          kumza,
          kumne,
          kntyp,
          kstat,
          kherk,
          kwert,
          ksteu,
          kinak,
          koaid,
          knumt,
          drukz,
          vtext,
          mwskz,
          stufe,
          wegxx,
          kfaktor,
          nrmng,
          mdflg,
          kwert_euro)
      values
         (rcd_sap_inv_con.belnr,
          rcd_sap_inv_con.conseq,
          rcd_sap_inv_con.kschl,
          rcd_sap_inv_con.krech,
          rcd_sap_inv_con.kawrt,
          rcd_sap_inv_con.awein,
          rcd_sap_inv_con.awei1,
          rcd_sap_inv_con.kbetr,
          rcd_sap_inv_con.koein,
          rcd_sap_inv_con.koei1,
          rcd_sap_inv_con.kkurs,
          rcd_sap_inv_con.kpein,
          rcd_sap_inv_con.kmein,
          rcd_sap_inv_con.kumza,
          rcd_sap_inv_con.kumne,
          rcd_sap_inv_con.kntyp,
          rcd_sap_inv_con.kstat,
          rcd_sap_inv_con.kherk,
          rcd_sap_inv_con.kwert,
          rcd_sap_inv_con.ksteu,
          rcd_sap_inv_con.kinak,
          rcd_sap_inv_con.koaid,
          rcd_sap_inv_con.knumt,
          rcd_sap_inv_con.drukz,
          rcd_sap_inv_con.vtext,
          rcd_sap_inv_con.mwskz,
          rcd_sap_inv_con.stufe,
          rcd_sap_inv_con.wegxx,
          rcd_sap_inv_con.kfaktor,
          rcd_sap_inv_con.nrmng,
          rcd_sap_inv_con.mdflg,
          rcd_sap_inv_con.kwert_euro);

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
      rcd_sap_inv_pnr.belnr := rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_pnr.pnrseq := rcd_sap_inv_pnr.pnrseq + 1;
      rcd_sap_inv_pnr.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_sap_inv_pnr.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_sap_inv_pnr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_sap_inv_pnr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_sap_inv_pnr.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_sap_inv_pnr.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_sap_inv_pnr.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_sap_inv_pnr.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_sap_inv_pnr.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_sap_inv_pnr.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_sap_inv_pnr.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_sap_inv_pnr.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_sap_inv_pnr.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_sap_inv_pnr.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_sap_inv_pnr.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_sap_inv_pnr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_sap_inv_pnr.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_sap_inv_pnr.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_sap_inv_pnr.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_sap_inv_pnr.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_sap_inv_pnr.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_sap_inv_pnr.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_sap_inv_pnr.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_sap_inv_pnr.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_sap_inv_pnr.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_sap_inv_pnr.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_sap_inv_pnr.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_sap_inv_pnr.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_sap_inv_pnr.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_sap_inv_pnr.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_sap_inv_pnr.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_sap_inv_pnr.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_sap_inv_pnr.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_sap_inv_pnr.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_sap_inv_pnr.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_sap_inv_pnr.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_sap_inv_pnr.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_sap_inv_pnr.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_sap_inv_pnr.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_sap_inv_pnr.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_sap_inv_pnr.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_sap_inv_pnr.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_sap_inv_pnr.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_sap_inv_pnr.title := lics_inbound_utility.get_variable('TITLE');

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
      if rcd_sap_inv_pnr.belnr is null then
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

      insert into sap_inv_pnr
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
         (rcd_sap_inv_pnr.belnr,
          rcd_sap_inv_pnr.pnrseq,
          rcd_sap_inv_pnr.parvw,
          rcd_sap_inv_pnr.partn,
          rcd_sap_inv_pnr.lifnr,
          rcd_sap_inv_pnr.name1,
          rcd_sap_inv_pnr.name2,
          rcd_sap_inv_pnr.name3,
          rcd_sap_inv_pnr.name4,
          rcd_sap_inv_pnr.stras,
          rcd_sap_inv_pnr.strs2,
          rcd_sap_inv_pnr.pfach,
          rcd_sap_inv_pnr.ort01,
          rcd_sap_inv_pnr.counc,
          rcd_sap_inv_pnr.pstlz,
          rcd_sap_inv_pnr.pstl2,
          rcd_sap_inv_pnr.land1,
          rcd_sap_inv_pnr.ablad,
          rcd_sap_inv_pnr.pernr,
          rcd_sap_inv_pnr.parnr,
          rcd_sap_inv_pnr.telf1,
          rcd_sap_inv_pnr.telf2,
          rcd_sap_inv_pnr.telbx,
          rcd_sap_inv_pnr.telfx,
          rcd_sap_inv_pnr.teltx,
          rcd_sap_inv_pnr.telx1,
          rcd_sap_inv_pnr.spras,
          rcd_sap_inv_pnr.anred,
          rcd_sap_inv_pnr.ort02,
          rcd_sap_inv_pnr.hausn,
          rcd_sap_inv_pnr.stock,
          rcd_sap_inv_pnr.regio,
          rcd_sap_inv_pnr.parge,
          rcd_sap_inv_pnr.isoal,
          rcd_sap_inv_pnr.isonu,
          rcd_sap_inv_pnr.fcode,
          rcd_sap_inv_pnr.ihrez,
          rcd_sap_inv_pnr.bname,
          rcd_sap_inv_pnr.paorg,
          rcd_sap_inv_pnr.orgtx,
          rcd_sap_inv_pnr.pagru,
          rcd_sap_inv_pnr.knref,
          rcd_sap_inv_pnr.ilnnr,
          rcd_sap_inv_pnr.pfort,
          rcd_sap_inv_pnr.spras_iso,
          rcd_sap_inv_pnr.title);

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
      rcd_sap_inv_ref.belnr := rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_ref.refseq := rcd_sap_inv_ref.refseq + 1;
      rcd_sap_inv_ref.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_inv_ref.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_sap_inv_ref.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_sap_inv_ref.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_inv_ref.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_sap_inv_ref.belnr is null then
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

      insert into sap_inv_ref
         (belnr,
          refseq,
          qualf,
          refnr,
          posnr,
          datum,
          uzeit)
      values
         (rcd_sap_inv_ref.belnr,
          rcd_sap_inv_ref.refseq,
          rcd_sap_inv_ref.qualf,
          rcd_sap_inv_ref.refnr,
          rcd_sap_inv_ref.posnr,
          rcd_sap_inv_ref.datum,
          rcd_sap_inv_ref.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ref;

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
      rcd_sap_inv_dat.belnr := rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_dat.datseq := rcd_sap_inv_dat.datseq + 1;
      rcd_sap_inv_dat.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_sap_inv_dat.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_inv_dat.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_sap_inv_dat.belnr is null then
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

      insert into sap_inv_dat
         (belnr,
          datseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_sap_inv_dat.belnr,
          rcd_sap_inv_dat.datseq,
          rcd_sap_inv_dat.iddat,
          rcd_sap_inv_dat.datum,
          rcd_sap_inv_dat.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

   /**************************************************/
   /* This procedure performs the record CUR routine */
   /**************************************************/
   procedure process_record_cur(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CUR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_inv_cur.belnr := rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_cur.curseq := rcd_sap_inv_cur.curseq + 1;
      rcd_sap_inv_cur.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_inv_cur.waerz := lics_inbound_utility.get_variable('WAERZ');
      rcd_sap_inv_cur.waerq := lics_inbound_utility.get_variable('WAERQ');
      rcd_sap_inv_cur.kurs := lics_inbound_utility.get_variable('KURS');
      rcd_sap_inv_cur.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_inv_cur.zeit := lics_inbound_utility.get_variable('ZEIT');
      rcd_sap_inv_cur.kurs_m := lics_inbound_utility.get_variable('KURS_M');

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
      if rcd_sap_inv_cur.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CUR.BELNR');
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

      insert into sap_inv_cur
         (belnr,
          curseq,
          qualf,
          waerz,
          waerq,
          kurs,
          datum,
          zeit,
          kurs_m)
      values
         (rcd_sap_inv_cur.belnr,
          rcd_sap_inv_cur.curseq,
          rcd_sap_inv_cur.qualf,
          rcd_sap_inv_cur.waerz,
          rcd_sap_inv_cur.waerq,
          rcd_sap_inv_cur.kurs,
          rcd_sap_inv_cur.datum,
          rcd_sap_inv_cur.zeit,
          rcd_sap_inv_cur.kurs_m);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_cur;

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
      rcd_sap_inv_org.belnr := rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_org.orgseq := rcd_sap_inv_org.orgseq + 1;
      rcd_sap_inv_org.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_inv_org.orgid := lics_inbound_utility.get_variable('ORGID');

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
      if rcd_sap_inv_org.belnr is null then
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

      insert into sap_inv_org
         (belnr,
          orgseq,
          qualf,
          orgid)
      values
         (rcd_sap_inv_org.belnr,
          rcd_sap_inv_org.orgseq,
          rcd_sap_inv_org.qualf,
          rcd_sap_inv_org.orgid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_org;

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
      rcd_sap_inv_gen.belnr := rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_gen.genseq := rcd_sap_inv_gen.genseq + 1;
      rcd_sap_inv_gen.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_sap_inv_gen.action := lics_inbound_utility.get_variable('ACTION');
      rcd_sap_inv_gen.pstyp := lics_inbound_utility.get_variable('PSTYP');
      rcd_sap_inv_gen.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_sap_inv_gen.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_sap_inv_gen.menee := lics_inbound_utility.get_variable('MENEE');
      rcd_sap_inv_gen.bmng2 := lics_inbound_utility.get_variable('BMNG2');
      rcd_sap_inv_gen.pmene := lics_inbound_utility.get_variable('PMENE');
      rcd_sap_inv_gen.abftz := lics_inbound_utility.get_variable('ABFTZ');
      rcd_sap_inv_gen.vprei := lics_inbound_utility.get_variable('VPREI');
      rcd_sap_inv_gen.peinh := lics_inbound_utility.get_variable('PEINH');
      rcd_sap_inv_gen.netwr := lics_inbound_utility.get_variable('NETWR');
      rcd_sap_inv_gen.anetw := lics_inbound_utility.get_variable('ANETW');
      rcd_sap_inv_gen.skfbp := lics_inbound_utility.get_variable('SKFBP');
      rcd_sap_inv_gen.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_sap_inv_gen.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_sap_inv_gen.einkz := lics_inbound_utility.get_variable('EINKZ');
      rcd_sap_inv_gen.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_sap_inv_gen.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_sap_inv_gen.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_sap_inv_gen.uepos := lics_inbound_utility.get_variable('UEPOS');
      rcd_sap_inv_gen.grkor := lics_inbound_utility.get_variable('GRKOR');
      rcd_sap_inv_gen.evers := lics_inbound_utility.get_variable('EVERS');
      rcd_sap_inv_gen.bpumn := lics_inbound_utility.get_number('BPUMN',null);
      rcd_sap_inv_gen.bpumz := lics_inbound_utility.get_number('BPUMZ',null);
      rcd_sap_inv_gen.abgru := lics_inbound_utility.get_variable('ABGRU');
      rcd_sap_inv_gen.abgrt := lics_inbound_utility.get_variable('ABGRT');
      rcd_sap_inv_gen.antlf := lics_inbound_utility.get_variable('ANTLF');
      rcd_sap_inv_gen.fixmg := lics_inbound_utility.get_variable('FIXMG');
      rcd_sap_inv_gen.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_sap_inv_gen.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_sap_inv_gen.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_sap_inv_gen.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_sap_inv_gen.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_sap_inv_gen.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_sap_inv_gen.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_sap_inv_gen.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_sap_inv_gen.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_sap_inv_gen.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_sap_inv_gen.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_sap_inv_gen.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_sap_inv_gen.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_sap_inv_gen.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_sap_inv_gen.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_sap_inv_gen.valtg := lics_inbound_utility.get_number('VALTG',null);
      rcd_sap_inv_gen.hipos := lics_inbound_utility.get_number('HIPOS',null);
      rcd_sap_inv_gen.hievw := lics_inbound_utility.get_variable('HIEVW');
      rcd_sap_inv_gen.posguid := lics_inbound_utility.get_variable('POSGUID');
      rcd_sap_inv_gen.vkorg := null;
      rcd_sap_inv_gen.vtweg := null;
      rcd_sap_inv_gen.spart := null;
      rcd_sap_inv_gen.volum := null;
      rcd_sap_inv_gen.voleh := null;
      rcd_sap_inv_gen.pcb := null;
      rcd_sap_inv_gen.spcb := null;
      rcd_sap_inv_gen.zztarif := null;
      rcd_sap_inv_gen.fklmg := null;
      rcd_sap_inv_gen.meins := null;
      rcd_sap_inv_gen.zzistdu := null;
      rcd_sap_inv_gen.zzisrsu := null;
      rcd_sap_inv_gen.prod_spart := null;
      rcd_sap_inv_gen.pmatn_ean := null;
      rcd_sap_inv_gen.tdumatn_ean := null;
      rcd_sap_inv_gen.mtpos := null;
      rcd_sap_inv_gen.org_dlvnr := null;
      rcd_sap_inv_gen.org_dlvdt := null;
      rcd_sap_inv_gen.mat_legacy := null;
      rcd_sap_inv_gen.rsu_per_mcu := null;
      rcd_sap_inv_gen.mcu_per_tdu := null;
      rcd_sap_inv_gen.rsu_per_tdu := null;
      rcd_sap_inv_gen.number_of_rsu := null;
      rcd_sap_inv_gen.vsart := null;
      rcd_sap_inv_gen.knref := null;
      rcd_sap_inv_gen.zzaggno := null;
      rcd_sap_inv_gen.zzagtcd := null;
      rcd_sap_inv_gen.kwmeng := null;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_inv_mat.matseq := 0;
      rcd_sap_inv_irf.irfseq := 0;
      rcd_sap_inv_idt.idtseq := 0;
      rcd_sap_inv_iob.iobseq := 0;
      rcd_sap_inv_ias.iasseq := 0;
      rcd_sap_inv_ipn.ipnseq := 0;
      rcd_sap_inv_icn.icnseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_inv_gen.belnr is null then
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

      /*-*/
      /* Update is done when the GEZ row is received - temporary fix for HUB bug
      /*-*/

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_gen;

   /**************************************************/
   /* This procedure performs the record GEZ routine */
   /**************************************************/
   procedure process_record_gez(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('GEZ', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_inv_gen.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_sap_inv_gen.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_sap_inv_gen.spart := lics_inbound_utility.get_variable('SPART');
      rcd_sap_inv_gen.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_sap_inv_gen.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_sap_inv_gen.pcb := lics_inbound_utility.get_number('PCB',null);
      rcd_sap_inv_gen.spcb := lics_inbound_utility.get_number('SPCB',null);
      rcd_sap_inv_gen.zztarif := lics_inbound_utility.get_variable('ZZTARIF');
      rcd_sap_inv_gen.fklmg := lics_inbound_utility.get_variable('FKLMG');
      rcd_sap_inv_gen.meins := lics_inbound_utility.get_variable('MEINS');
      rcd_sap_inv_gen.zzistdu := lics_inbound_utility.get_variable('ZZISTDU');
      rcd_sap_inv_gen.zzisrsu := lics_inbound_utility.get_variable('ZZISRSU');
      rcd_sap_inv_gen.prod_spart := lics_inbound_utility.get_variable('PROD_SPART');
      rcd_sap_inv_gen.pmatn_ean := lics_inbound_utility.get_variable('PMATN_EAN');
      rcd_sap_inv_gen.tdumatn_ean := lics_inbound_utility.get_variable('TDUMATN_EAN');
      rcd_sap_inv_gen.mtpos := lics_inbound_utility.get_variable('MTPOS');
      rcd_sap_inv_gen.org_dlvnr := lics_inbound_utility.get_variable('ORG_DLVNR');
      rcd_sap_inv_gen.org_dlvdt := lics_inbound_utility.get_variable('ORG_DLVDT');
      rcd_sap_inv_gen.mat_legacy := lics_inbound_utility.get_variable('MAT_LEGACY');
      rcd_sap_inv_gen.rsu_per_mcu := lics_inbound_utility.get_variable('RSU_PER_MCU');
      rcd_sap_inv_gen.mcu_per_tdu := lics_inbound_utility.get_variable('MCU_PER_TDU');
      rcd_sap_inv_gen.rsu_per_tdu := lics_inbound_utility.get_variable('RSU_PER_TDU');
      rcd_sap_inv_gen.number_of_rsu := lics_inbound_utility.get_variable('NUMBER_OF_RSU');
      rcd_sap_inv_gen.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_sap_inv_gen.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_sap_inv_gen.zzaggno := lics_inbound_utility.get_variable('ZZAGGNO');
      rcd_sap_inv_gen.zzagtcd := lics_inbound_utility.get_variable('ZZAGTCD');
      rcd_sap_inv_gen.kwmeng := lics_inbound_utility.get_number('KWMENG',null);

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
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

      insert into sap_inv_gen
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
          vkorg,
          vtweg,
          spart,
          volum,
          voleh,
          pcb,
          spcb,
          zztarif,
          fklmg,
          meins,
          zzistdu,
          zzisrsu,
          prod_spart,
          pmatn_ean,
          tdumatn_ean,
          mtpos,
          org_dlvnr,
          org_dlvdt,
          mat_legacy,
          rsu_per_mcu,
          mcu_per_tdu,
          rsu_per_tdu,
          number_of_rsu,
          vsart,
          knref,
          zzaggno,
          zzagtcd,
          kwmeng)
      values
         (rcd_sap_inv_gen.belnr,
          rcd_sap_inv_gen.genseq,
          rcd_sap_inv_gen.posex,
          rcd_sap_inv_gen.action,
          rcd_sap_inv_gen.pstyp,
          rcd_sap_inv_gen.kzabs,
          rcd_sap_inv_gen.menge,
          rcd_sap_inv_gen.menee,
          rcd_sap_inv_gen.bmng2,
          rcd_sap_inv_gen.pmene,
          rcd_sap_inv_gen.abftz,
          rcd_sap_inv_gen.vprei,
          rcd_sap_inv_gen.peinh,
          rcd_sap_inv_gen.netwr,
          rcd_sap_inv_gen.anetw,
          rcd_sap_inv_gen.skfbp,
          rcd_sap_inv_gen.ntgew,
          rcd_sap_inv_gen.gewei,
          rcd_sap_inv_gen.einkz,
          rcd_sap_inv_gen.curcy,
          rcd_sap_inv_gen.preis,
          rcd_sap_inv_gen.matkl,
          rcd_sap_inv_gen.uepos,
          rcd_sap_inv_gen.grkor,
          rcd_sap_inv_gen.evers,
          rcd_sap_inv_gen.bpumn,
          rcd_sap_inv_gen.bpumz,
          rcd_sap_inv_gen.abgru,
          rcd_sap_inv_gen.abgrt,
          rcd_sap_inv_gen.antlf,
          rcd_sap_inv_gen.fixmg,
          rcd_sap_inv_gen.kzazu,
          rcd_sap_inv_gen.brgew,
          rcd_sap_inv_gen.pstyv,
          rcd_sap_inv_gen.empst,
          rcd_sap_inv_gen.abtnr,
          rcd_sap_inv_gen.abrvw,
          rcd_sap_inv_gen.werks,
          rcd_sap_inv_gen.lprio,
          rcd_sap_inv_gen.lprio_bez,
          rcd_sap_inv_gen.route,
          rcd_sap_inv_gen.route_bez,
          rcd_sap_inv_gen.lgort,
          rcd_sap_inv_gen.vstel,
          rcd_sap_inv_gen.delco,
          rcd_sap_inv_gen.matnr,
          rcd_sap_inv_gen.valtg,
          rcd_sap_inv_gen.hipos,
          rcd_sap_inv_gen.hievw,
          rcd_sap_inv_gen.posguid,
          rcd_sap_inv_gen.vkorg,
          rcd_sap_inv_gen.vtweg,
          rcd_sap_inv_gen.spart,
          rcd_sap_inv_gen.volum,
          rcd_sap_inv_gen.voleh,
          rcd_sap_inv_gen.pcb,
          rcd_sap_inv_gen.spcb,
          rcd_sap_inv_gen.zztarif,
          rcd_sap_inv_gen.fklmg,
          rcd_sap_inv_gen.meins,
          rcd_sap_inv_gen.zzistdu,
          rcd_sap_inv_gen.zzisrsu,
          rcd_sap_inv_gen.prod_spart,
          rcd_sap_inv_gen.pmatn_ean,
          rcd_sap_inv_gen.tdumatn_ean,
          rcd_sap_inv_gen.mtpos,
          rcd_sap_inv_gen.org_dlvnr,
          rcd_sap_inv_gen.org_dlvdt,
          rcd_sap_inv_gen.mat_legacy,
          rcd_sap_inv_gen.rsu_per_mcu,
          rcd_sap_inv_gen.mcu_per_tdu,
          rcd_sap_inv_gen.rsu_per_tdu,
          rcd_sap_inv_gen.number_of_rsu,
          rcd_sap_inv_gen.vsart,
          rcd_sap_inv_gen.knref,
          rcd_sap_inv_gen.zzaggno,
          rcd_sap_inv_gen.zzagtcd,
          rcd_sap_inv_gen.kwmeng);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_gez;

   /**************************************************/
   /* This procedure performs the record MAT routine */
   /**************************************************/
   procedure process_record_mat(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MAT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_inv_mat.belnr := rcd_sap_inv_gen.belnr;
      rcd_sap_inv_mat.genseq := rcd_sap_inv_gen.genseq;
      rcd_sap_inv_mat.matseq := rcd_sap_inv_mat.matseq + 1;
      rcd_sap_inv_mat.langu := lics_inbound_utility.get_variable('LANGU');
      rcd_sap_inv_mat.maktx := lics_inbound_utility.get_variable('MAKTX');

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
      if rcd_sap_inv_mat.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MAT.BELNR');
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

      insert into sap_inv_mat
         (belnr,
          genseq,
          matseq,
          langu,
          maktx)
      values
         (rcd_sap_inv_mat.belnr,
          rcd_sap_inv_mat.genseq,
          rcd_sap_inv_mat.matseq,
          rcd_sap_inv_mat.langu,
          rcd_sap_inv_mat.maktx);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mat;

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
      rcd_sap_inv_irf.belnr := rcd_sap_inv_gen.belnr;
      rcd_sap_inv_irf.genseq := rcd_sap_inv_gen.genseq;
      rcd_sap_inv_irf.irfseq := rcd_sap_inv_irf.irfseq + 1;
      rcd_sap_inv_irf.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_inv_irf.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_sap_inv_irf.zeile := lics_inbound_utility.get_variable('ZEILE');
      rcd_sap_inv_irf.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_inv_irf.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_sap_inv_irf.bsark := lics_inbound_utility.get_variable('BSARK');
      rcd_sap_inv_irf.ihrez := lics_inbound_utility.get_variable('IHREZ');

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
      if rcd_sap_inv_irf.belnr is null then
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

      insert into sap_inv_irf
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
         (rcd_sap_inv_irf.belnr,
          rcd_sap_inv_irf.genseq,
          rcd_sap_inv_irf.irfseq,
          rcd_sap_inv_irf.qualf,
          rcd_sap_inv_irf.refnr,
          rcd_sap_inv_irf.zeile,
          rcd_sap_inv_irf.datum,
          rcd_sap_inv_irf.uzeit,
          rcd_sap_inv_irf.bsark,
          rcd_sap_inv_irf.ihrez);

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
      rcd_sap_inv_idt.belnr := rcd_sap_inv_gen.belnr;
      rcd_sap_inv_idt.genseq := rcd_sap_inv_gen.genseq;
      rcd_sap_inv_idt.idtseq := rcd_sap_inv_idt.idtseq + 1;
      rcd_sap_inv_idt.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_sap_inv_idt.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_inv_idt.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_sap_inv_idt.belnr is null then
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

      insert into sap_inv_idt
         (belnr,
          genseq,
          idtseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_sap_inv_idt.belnr,
          rcd_sap_inv_idt.genseq,
          rcd_sap_inv_idt.idtseq,
          rcd_sap_inv_idt.iddat,
          rcd_sap_inv_idt.datum,
          rcd_sap_inv_idt.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_idt;

   /**************************************************/
   /* This procedure performs the record IOB routine */
   /**************************************************/
   procedure process_record_iob(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IOB', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_inv_iob.belnr := rcd_sap_inv_gen.belnr;
      rcd_sap_inv_iob.genseq := rcd_sap_inv_gen.genseq;
      rcd_sap_inv_iob.iobseq := rcd_sap_inv_iob.iobseq + 1;
      rcd_sap_inv_iob.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_inv_iob.idtnr := lics_inbound_utility.get_variable('IDTNR');
      rcd_sap_inv_iob.ktext := lics_inbound_utility.get_variable('KTEXT');
      rcd_sap_inv_iob.mfrpn := lics_inbound_utility.get_variable('MFRPN');
      rcd_sap_inv_iob.mfrnr := lics_inbound_utility.get_variable('MFRNR');

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
      if rcd_sap_inv_iob.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IOB.BELNR');
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

      insert into sap_inv_iob
         (belnr,
          genseq,
          iobseq,
          qualf,
          idtnr,
          ktext,
          mfrpn,
          mfrnr)
      values
         (rcd_sap_inv_iob.belnr,
          rcd_sap_inv_iob.genseq,
          rcd_sap_inv_iob.iobseq,
          rcd_sap_inv_iob.qualf,
          rcd_sap_inv_iob.idtnr,
          rcd_sap_inv_iob.ktext,
          rcd_sap_inv_iob.mfrpn,
          rcd_sap_inv_iob.mfrnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_iob;

   /**************************************************/
   /* This procedure performs the record IAS routine */
   /**************************************************/
   procedure process_record_ias(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IAS', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_inv_ias.belnr := rcd_sap_inv_gen.belnr;
      rcd_sap_inv_ias.genseq := rcd_sap_inv_gen.genseq;
      rcd_sap_inv_ias.iasseq := rcd_sap_inv_ias.iasseq + 1;
      rcd_sap_inv_ias.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_inv_ias.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_sap_inv_ias.krate := lics_inbound_utility.get_variable('KRATE');

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
      if rcd_sap_inv_ias.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IAS.BELNR');
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

      insert into sap_inv_ias
         (belnr,
          genseq,
          iasseq,
          qualf,
          betrg,
          krate)
      values
         (rcd_sap_inv_ias.belnr,
          rcd_sap_inv_ias.genseq,
          rcd_sap_inv_ias.iasseq,
          rcd_sap_inv_ias.qualf,
          rcd_sap_inv_ias.betrg,
          rcd_sap_inv_ias.krate);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ias;

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
      rcd_sap_inv_ipn.belnr := rcd_sap_inv_gen.belnr;
      rcd_sap_inv_ipn.genseq := rcd_sap_inv_gen.genseq;
      rcd_sap_inv_ipn.ipnseq := rcd_sap_inv_ipn.ipnseq + 1;
      rcd_sap_inv_ipn.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_sap_inv_ipn.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_sap_inv_ipn.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_sap_inv_ipn.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_sap_inv_ipn.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_sap_inv_ipn.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_sap_inv_ipn.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_sap_inv_ipn.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_sap_inv_ipn.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_sap_inv_ipn.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_sap_inv_ipn.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_sap_inv_ipn.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_sap_inv_ipn.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_sap_inv_ipn.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_sap_inv_ipn.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_sap_inv_ipn.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_sap_inv_ipn.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_sap_inv_ipn.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_sap_inv_ipn.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_sap_inv_ipn.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_sap_inv_ipn.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_sap_inv_ipn.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_sap_inv_ipn.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_sap_inv_ipn.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_sap_inv_ipn.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_sap_inv_ipn.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_sap_inv_ipn.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_sap_inv_ipn.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_sap_inv_ipn.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_sap_inv_ipn.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_sap_inv_ipn.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_sap_inv_ipn.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_sap_inv_ipn.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_sap_inv_ipn.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_sap_inv_ipn.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_sap_inv_ipn.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_sap_inv_ipn.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_sap_inv_ipn.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_sap_inv_ipn.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_sap_inv_ipn.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_sap_inv_ipn.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_sap_inv_ipn.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_sap_inv_ipn.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_sap_inv_ipn.title := lics_inbound_utility.get_variable('TITLE');

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
      if rcd_sap_inv_ipn.belnr is null then
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

      insert into sap_inv_ipn
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
         (rcd_sap_inv_ipn.belnr,
          rcd_sap_inv_ipn.genseq,
          rcd_sap_inv_ipn.ipnseq,
          rcd_sap_inv_ipn.parvw,
          rcd_sap_inv_ipn.partn,
          rcd_sap_inv_ipn.lifnr,
          rcd_sap_inv_ipn.name1,
          rcd_sap_inv_ipn.name2,
          rcd_sap_inv_ipn.name3,
          rcd_sap_inv_ipn.name4,
          rcd_sap_inv_ipn.stras,
          rcd_sap_inv_ipn.strs2,
          rcd_sap_inv_ipn.pfach,
          rcd_sap_inv_ipn.ort01,
          rcd_sap_inv_ipn.counc,
          rcd_sap_inv_ipn.pstlz,
          rcd_sap_inv_ipn.pstl2,
          rcd_sap_inv_ipn.land1,
          rcd_sap_inv_ipn.ablad,
          rcd_sap_inv_ipn.pernr,
          rcd_sap_inv_ipn.parnr,
          rcd_sap_inv_ipn.telf1,
          rcd_sap_inv_ipn.telf2,
          rcd_sap_inv_ipn.telbx,
          rcd_sap_inv_ipn.telfx,
          rcd_sap_inv_ipn.teltx,
          rcd_sap_inv_ipn.telx1,
          rcd_sap_inv_ipn.spras,
          rcd_sap_inv_ipn.anred,
          rcd_sap_inv_ipn.ort02,
          rcd_sap_inv_ipn.hausn,
          rcd_sap_inv_ipn.stock,
          rcd_sap_inv_ipn.regio,
          rcd_sap_inv_ipn.parge,
          rcd_sap_inv_ipn.isoal,
          rcd_sap_inv_ipn.isonu,
          rcd_sap_inv_ipn.fcode,
          rcd_sap_inv_ipn.ihrez,
          rcd_sap_inv_ipn.bname,
          rcd_sap_inv_ipn.paorg,
          rcd_sap_inv_ipn.orgtx,
          rcd_sap_inv_ipn.pagru,
          rcd_sap_inv_ipn.knref,
          rcd_sap_inv_ipn.ilnnr,
          rcd_sap_inv_ipn.pfort,
          rcd_sap_inv_ipn.spras_iso,
          rcd_sap_inv_ipn.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ipn;

   /**************************************************/
   /* This procedure performs the record ICN routine */
   /**************************************************/
   procedure process_record_icn(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ICN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sap_inv_icn.belnr := rcd_sap_inv_gen.belnr;
      rcd_sap_inv_icn.genseq := rcd_sap_inv_gen.genseq;
      rcd_sap_inv_icn.icnseq := rcd_sap_inv_icn.icnseq + 1;
      rcd_sap_inv_icn.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_sap_inv_icn.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_sap_inv_icn.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_sap_inv_icn.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_sap_inv_icn.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_sap_inv_icn.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_sap_inv_icn.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_sap_inv_icn.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_sap_inv_icn.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_sap_inv_icn.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_sap_inv_icn.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_sap_inv_icn.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_sap_inv_icn.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_sap_inv_icn.koein := lics_inbound_utility.get_variable('KOEIN');
      rcd_sap_inv_icn.curtp := lics_inbound_utility.get_variable('CURTP');
      rcd_sap_inv_icn.kobas := lics_inbound_utility.get_variable('KOBAS');

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
      if rcd_sap_inv_icn.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ICN.BELNR');
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

      insert into sap_inv_icn
         (belnr,
          genseq,
          icnseq,
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
         (rcd_sap_inv_icn.belnr,
          rcd_sap_inv_icn.genseq,
          rcd_sap_inv_icn.icnseq,
          rcd_sap_inv_icn.alckz,
          rcd_sap_inv_icn.kschl,
          rcd_sap_inv_icn.kotxt,
          rcd_sap_inv_icn.betrg,
          rcd_sap_inv_icn.kperc,
          rcd_sap_inv_icn.krate,
          rcd_sap_inv_icn.uprbs,
          rcd_sap_inv_icn.meaun,
          rcd_sap_inv_icn.kobtr,
          rcd_sap_inv_icn.menge,
          rcd_sap_inv_icn.preis,
          rcd_sap_inv_icn.mwskz,
          rcd_sap_inv_icn.msatz,
          rcd_sap_inv_icn.koein,
          rcd_sap_inv_icn.curtp,
          rcd_sap_inv_icn.kobas);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_icn;

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
      rcd_sap_inv_smy.belnr := rcd_sap_inv_hdr.belnr;
      rcd_sap_inv_smy.smyseq := rcd_sap_inv_smy.smyseq + 1;
      rcd_sap_inv_smy.sumid := lics_inbound_utility.get_variable('SUMID');
      rcd_sap_inv_smy.summe := lics_inbound_utility.get_variable('SUMME');
      rcd_sap_inv_smy.sunit := lics_inbound_utility.get_variable('SUNIT');
      rcd_sap_inv_smy.waerq := lics_inbound_utility.get_variable('WAERQ');

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
      if rcd_sap_inv_smy.belnr is null then
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

      insert into sap_inv_smy
         (belnr,
          smyseq,
          sumid,
          summe,
          sunit,
          waerq)
      values
         (rcd_sap_inv_smy.belnr,
          rcd_sap_inv_smy.smyseq,
          rcd_sap_inv_smy.sumid,
          rcd_sap_inv_smy.summe,
          rcd_sap_inv_smy.sunit,
          rcd_sap_inv_smy.waerq);

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
      rcd_sap_inv_trace sap_inv_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_data is
         select t01.billing_doc_num,
                t01.doc_currcy_code,
                t01.exch_rate,
                t01.order_reasn_code,
                t02.creatn_date,
                t02.creatn_yyyyppdd,
                t02.creatn_yyyyppw,
                t02.creatn_yyyypp,
                t02.creatn_yyyymm,
                t02.billing_eff_date,
                t02.billing_eff_yyyyppdd,
                t02.billing_eff_yyyyppw,
                t02.billing_eff_yyyypp,
                t02.billing_eff_yyyymm,
                t03.order_type_code,
                t03.invc_type_code,
                t03.company_code,
                t03.hdr_sales_org_code,
                t03.hdr_distbn_chnl_code,
                t03.hdr_division_code,
                t04.hdr_sold_to_cust_code,
                t04.hdr_bill_to_cust_code,
                t04.hdr_payer_cust_code,
                t04.hdr_ship_to_cust_code,
                t05.billing_doc_line_num,
                t05.billed_uom_code,
                t05.billed_base_uom_code,
                t05.plant_code,
                t05.storage_locn_code,
                t05.gen_sales_org_code,
                t05.gen_distbn_chnl_code,
                t05.gen_division_code,
                t05.order_usage_code,
                t05.order_qty,
                t05.billed_qty,
                t05.billed_qty_base_uom,
                t05.billed_gross_weight,
                t05.billed_net_weight,
                t05.billed_weight_unit,
                t06.matl_code,
                t06.matl_entd,
                t07.gen_sold_to_cust_code,
                t07.gen_bill_to_cust_code,
                t07.gen_payer_cust_code,
                t07.gen_ship_to_cust_code,
                t08.order_doc_num,
                t08.order_doc_line_num,
                t08.dlvry_doc_num,
                t08.dlvry_doc_line_num,
                t09.billed_gsv
           from --
                -- Invoice header information
                --
                (select t01.belnr,
                        t01.belnr as billing_doc_num,
                        t01.curcy as doc_currcy_code,
                        nvl(dw_to_number(t01.wkurs),1) as exch_rate,
                        t01.augru as order_reasn_code
                   from sap_inv_hdr t01
                  where t01.belnr = par_belnr) t01,
                --
                -- Invoice date information
                --
               (select t01.belnr,
                       t01.creatn_date as creatn_date,
                       t01.billing_eff_date as billing_eff_date,
                       t02.mars_yyyyppdd as creatn_yyyyppdd,
                       t02.mars_week as creatn_yyyyppw,
                       t02.mars_period as creatn_yyyypp,
                       (t02.year_num * 100) + t02.month_num as creatn_yyyymm,
                       t03.mars_yyyyppdd as billing_eff_yyyyppdd,
                       t03.mars_week as billing_eff_yyyyppw,
                       t03.mars_period as billing_eff_yyyypp,
                       (t03.year_num * 100) + t03.month_num as billing_eff_yyyymm
                  from (select t01.belnr as belnr,
                               max(case when t01.iddat = '015' then dw_to_date(t01.datum,'yyyymmdd') end) as creatn_date,
                               max(case when t01.iddat = '026' then dw_to_date(t01.datum,'yyyymmdd') end) as billing_eff_date
                          from sap_inv_dat t01
                         where t01.belnr = par_belnr
                           and t01.iddat in ('015','026')
                         group by t01.belnr) t01,
                       mars_date t02,
                       mars_date t03
                 where t01.creatn_date = t02.calendar_date(+)
                   and t01.billing_eff_date = t03.calendar_date(+)) t02,
                --
                -- Invoice organisation information
                --
                (select t01.belnr,
                        max(case when t01.qualf = '012' then t01.orgid end) as order_type_code,
                        max(case when t01.qualf = '015' then t01.orgid end) as invc_type_code,
                        max(case when t01.qualf = '003' then t01.orgid end) as company_code,
                        max(case when t01.qualf = '008' then t01.orgid end) as hdr_sales_org_code,
                        max(case when t01.qualf = '007' then t01.orgid end) as hdr_distbn_chnl_code,
                        max(case when t01.qualf = '006' then t01.orgid end) as hdr_division_code
                   from sap_inv_org t01
                  where t01.belnr = par_belnr
                    and t01.qualf in ('003','006','007','008','012','015')
                  group by t01.belnr) t03,
                --
                -- Invoice partner information
                --
                (select t01.belnr,
                        max(case when t01.parvw = 'AG' then t01.partn end) as hdr_sold_to_cust_code,
                        max(case when t01.parvw = 'RE' then t01.partn end) as hdr_bill_to_cust_code,
                        max(case when t01.parvw = 'RG' then t01.partn end) as hdr_payer_cust_code,
                        max(case when t01.parvw = 'WE' then t01.partn end) as hdr_ship_to_cust_code
                   from sap_inv_pnr t01
                  where t01.belnr = par_belnr
                    and t01.parvw in ('AG','RE','RG','WE')
                  group by t01.belnr) t04,
                --
                -- Invoice line information
                --
                (select t01.belnr,
                        t01.genseq,
                        t01.posex as billing_doc_line_num,
                        t01.menee as billed_uom_code,
                        t01.meins as billed_base_uom_code,
                        t01.werks as plant_code,
                        t01.lgort as storage_locn_code,
                        t01.vkorg as gen_sales_org_code,
                        t01.vtweg as gen_distbn_chnl_code,
                        t01.spart as gen_division_code,
                        t01.abrvw as order_usage_code,
                        nvl(t01.kwmeng,0) as order_qty,
                        nvl(dw_to_number(t01.menge),0) as billed_qty,
                        nvl(dw_to_number(t01.fklmg),0) as billed_qty_base_uom,
                        nvl(dw_to_number(t01.brgew),0) as billed_gross_weight,
                        nvl(dw_to_number(t01.ntgew),0) as billed_net_weight,
                        t01.gewei as billed_weight_unit
                   from sap_inv_gen t01
                  where t01.belnr = par_belnr) t05,
                --
                -- Invoice line material information
                --
                (select t01.belnr,
                        t01.genseq,
                        max(case when t01.qualf = '002' then t01.idtnr end) as matl_code,
                        max(case when t01.qualf = 'Z01' then t01.idtnr end) as matl_entd
                   from sap_inv_iob t01
                  where t01.belnr = par_belnr
                    and t01.qualf in ('002','Z01')
                  group by t01.belnr,
                           t01.genseq) t06,
                --
                -- Invoice line partner information
                --
                (select t01.belnr,
                        t01.genseq,
                        max(case when t01.parvw = 'AG' then t01.partn end) as gen_sold_to_cust_code,
                        max(case when t01.parvw = 'RE' then t01.partn end) as gen_bill_to_cust_code,
                        max(case when t01.parvw = 'RG' then t01.partn end) as gen_payer_cust_code,
                        max(case when t01.parvw = 'WE' then t01.partn end) as gen_ship_to_cust_code
                   from sap_inv_ipn t01
                  where t01.belnr = par_belnr
                    and t01.parvw in ('AG','RE','RG','WE')
                  group by t01.belnr,
                           t01.genseq) t07,
                --
                -- Invoice line reference information
                --
                (select t01.belnr,
                        t01.genseq,
                        max(case when t01.qualf = '002' then t01.refnr end) as order_doc_num,
                        max(case when t01.qualf = '002' then t01.zeile end) as order_doc_line_num,
                        max(case when t01.qualf = '016' then t01.refnr end) as dlvry_doc_num,
                        max(case when t01.qualf = '016' then t01.zeile end) as dlvry_doc_line_num
                   from sap_inv_irf t01
                  where t01.belnr = par_belnr
                    and t01.qualf in ('002','016')
                  group by t01.belnr,
                        t01.genseq) t08,
                --
                -- Invoice line value information
                --
               (select t01.belnr,
                       t01.genseq,
                       sum(billed_gsv) as billed_gsv
                  from (select t01.belnr,
                               t01.genseq,
                               decode(t01.alckz,'-',-1,1)*nvl(dw_to_number(t01.betrg),0) as billed_gsv
                          from sap_inv_icn t01
                         where t01.belnr = par_belnr
                           and (upper(t01.kschl) = 'ZV01' or
                                upper(t01.kschl) = 'ZR03' or
                                upper(t01.kschl) = 'ZR04' or
                                upper(t01.kotxt) = 'GSV')
                         union all
                        select t01.belnr,
                               t01.genseq,
                               decode(t01.alckz,'-',-1,1)*nvl(dw_to_number(t01.betrg),0) as billed_gsv
                          from sap_inv_icn t01,
                               (select t01.belnr,
                                       t01.genseq
                                  from sap_inv_icn t01
                                 where t01.belnr = par_belnr
                                   and upper(t01.kschl) = 'ZZ01') t02
                         where t01.belnr = t02.belnr
                           and t01.genseq = t02.genseq
                           and t01.belnr = par_belnr
                           and upper(t01.kotxt) = 'GROSS VALUE') t01
                 group by t01.belnr, t01.genseq) t09
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
            and t05.genseq = t07.genseq(+)
            and t05.belnr = t09.belnr(+)
            and t05.genseq = t09.genseq(+);
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
      /* Initialise the invoice trace data
      /*-*/
      rcd_sap_inv_trace.trace_seqn := var_sequence;
      rcd_sap_inv_trace.trace_date := sysdate;
      rcd_sap_inv_trace.trace_status := '*ACTIVE';

      /*-*/
      /* Retrieve the invoice trace detail
      /*-*/
      open csr_ods_data;
      loop
         fetch csr_ods_data into rcd_ods_data;
         if csr_ods_data%notfound then
            exit;
         end if;

         /*-*/
         /* Set the trace status
         /*-*/
         rcd_sap_inv_trace.trace_status := '*ACTIVE';

         /*-*/
         /* Deleted invoice line
         /* **notes** no invoice lines found
         /*-*/
         if rcd_ods_data.billing_doc_num is null then
            rcd_sap_inv_trace.trace_status := '*DELETED';
         end if;

         /*-*/
         /* Unposted invoice line
         /* **notes** creation date is null
         /*-*/
         if rcd_ods_data.creatn_date is null then
            rcd_sap_inv_trace.trace_status := '*UNPOSTED';
         end if;

         /*-*/
         /* Initialise the invoice trace row
         /*-*/
         rcd_sap_inv_trace.company_code := rcd_ods_data.company_code;
         rcd_sap_inv_trace.billing_doc_num := rcd_ods_data.billing_doc_num;
         rcd_sap_inv_trace.doc_currcy_code := rcd_ods_data.doc_currcy_code;
         rcd_sap_inv_trace.exch_rate := rcd_ods_data.exch_rate;
         rcd_sap_inv_trace.order_reasn_code := rcd_ods_data.order_reasn_code;
         rcd_sap_inv_trace.creatn_date := rcd_ods_data.creatn_date;
         rcd_sap_inv_trace.creatn_yyyyppdd := rcd_ods_data.creatn_yyyyppdd;
         rcd_sap_inv_trace.creatn_yyyyppw := rcd_ods_data.creatn_yyyyppw;
         rcd_sap_inv_trace.creatn_yyyypp := rcd_ods_data.creatn_yyyypp;
         rcd_sap_inv_trace.creatn_yyyymm := rcd_ods_data.creatn_yyyymm;
         rcd_sap_inv_trace.billing_eff_date := rcd_ods_data.billing_eff_date;
         rcd_sap_inv_trace.billing_eff_yyyyppdd := rcd_ods_data.billing_eff_yyyyppdd;
         rcd_sap_inv_trace.billing_eff_yyyyppw := rcd_ods_data.billing_eff_yyyyppw;
         rcd_sap_inv_trace.billing_eff_yyyypp := rcd_ods_data.billing_eff_yyyypp;
         rcd_sap_inv_trace.billing_eff_yyyymm := rcd_ods_data.billing_eff_yyyymm;
         rcd_sap_inv_trace.order_type_code := rcd_ods_data.order_type_code;
         rcd_sap_inv_trace.invc_type_code := rcd_ods_data.invc_type_code;
         rcd_sap_inv_trace.hdr_sales_org_code := rcd_ods_data.hdr_sales_org_code;
         rcd_sap_inv_trace.hdr_distbn_chnl_code := rcd_ods_data.hdr_distbn_chnl_code;
         rcd_sap_inv_trace.hdr_division_code := rcd_ods_data.hdr_division_code;
         rcd_sap_inv_trace.hdr_sold_to_cust_code := rcd_ods_data.hdr_sold_to_cust_code;
         rcd_sap_inv_trace.hdr_bill_to_cust_code := rcd_ods_data.hdr_bill_to_cust_code;
         rcd_sap_inv_trace.hdr_payer_cust_code := rcd_ods_data.hdr_payer_cust_code;
         rcd_sap_inv_trace.hdr_ship_to_cust_code := rcd_ods_data.hdr_ship_to_cust_code;
         rcd_sap_inv_trace.billing_doc_line_num := rcd_ods_data.billing_doc_line_num;
         rcd_sap_inv_trace.billed_uom_code := rcd_ods_data.billed_uom_code;
         rcd_sap_inv_trace.billed_base_uom_code := rcd_ods_data.billed_base_uom_code;
         rcd_sap_inv_trace.plant_code := rcd_ods_data.plant_code;
         rcd_sap_inv_trace.storage_locn_code := rcd_ods_data.storage_locn_code;
         rcd_sap_inv_trace.gen_sales_org_code := rcd_ods_data.gen_sales_org_code;
         rcd_sap_inv_trace.gen_distbn_chnl_code := rcd_ods_data.gen_distbn_chnl_code;
         rcd_sap_inv_trace.gen_division_code := rcd_ods_data.gen_division_code;
         rcd_sap_inv_trace.order_usage_code := rcd_ods_data.order_usage_code;
         rcd_sap_inv_trace.order_qty := rcd_ods_data.order_qty;
         rcd_sap_inv_trace.billed_qty := rcd_ods_data.billed_qty;
         rcd_sap_inv_trace.billed_qty_base_uom := rcd_ods_data.billed_qty_base_uom;
         rcd_sap_inv_trace.billed_gross_weight := rcd_ods_data.billed_gross_weight;
         rcd_sap_inv_trace.billed_net_weight := rcd_ods_data.billed_net_weight;
         rcd_sap_inv_trace.billed_weight_unit := rcd_ods_data.billed_weight_unit;
         rcd_sap_inv_trace.matl_code := rcd_ods_data.matl_code;
         rcd_sap_inv_trace.matl_entd := rcd_ods_data.matl_entd;
         rcd_sap_inv_trace.gen_sold_to_cust_code := rcd_ods_data.gen_sold_to_cust_code;
         rcd_sap_inv_trace.gen_bill_to_cust_code := rcd_ods_data.gen_bill_to_cust_code;
         rcd_sap_inv_trace.gen_payer_cust_code := rcd_ods_data.gen_payer_cust_code;
         rcd_sap_inv_trace.gen_ship_to_cust_code := rcd_ods_data.gen_ship_to_cust_code;
         rcd_sap_inv_trace.purch_order_doc_num := null;
         rcd_sap_inv_trace.purch_order_doc_line_num := null;
         rcd_sap_inv_trace.order_doc_num := null;
         rcd_sap_inv_trace.order_doc_line_num := null;
         rcd_sap_inv_trace.dlvry_doc_num := rcd_ods_data.dlvry_doc_num;
         rcd_sap_inv_trace.dlvry_doc_line_num := rcd_ods_data.dlvry_doc_line_num;
         rcd_sap_inv_trace.billed_gsv := nvl(rcd_ods_data.billed_gsv,0);
         if rcd_sap_inv_trace.invc_type_code in ('ZIV','ZIVR','ZIVS') then
            rcd_sap_inv_trace.purch_order_doc_num := rcd_ods_data.order_doc_num;
            rcd_sap_inv_trace.purch_order_doc_line_num := lpad(ltrim(rcd_ods_data.order_doc_line_num,'0'),5,'0');
         else
            rcd_sap_inv_trace.order_doc_num := rcd_ods_data.order_doc_num;
            rcd_sap_inv_trace.order_doc_line_num := rcd_ods_data.order_doc_line_num;
         end if;

         /*-*/
         /* Insert the invoice trace row
         /*-*/
         insert into sap_inv_trace values rcd_sap_inv_trace;

      end loop;
      close csr_ods_data;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_trace;

end ods_atlods18;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_atlods18 for ods_app.ods_atlods18;
grant execute on ods_atlods18 to lics_app;