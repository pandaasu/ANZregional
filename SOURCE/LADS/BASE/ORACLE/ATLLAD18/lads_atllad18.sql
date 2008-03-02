/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads 
 Package : lads_atllad18 
 Owner   : lads_app 
 Author  : Steve Gregan 

 Description
 -----------
 Local Atlas Data Store - atllad18 - Inbound Invoice Interface 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2004/01   Steve Gregan   Created 
 2008/02   Trevor Keon    Added update to GEN lines for ZRK invoices 

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad18 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad18;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad18 as

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
   procedure process_record_cus(par_record in varchar2);
   procedure process_record_con(par_record in varchar2);
   procedure process_record_pnr(par_record in varchar2);
   procedure process_record_adj(par_record in varchar2);
   procedure process_record_ref(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);
   procedure process_record_dcn(par_record in varchar2);
   procedure process_record_tax(par_record in varchar2);
   procedure process_record_tod(par_record in varchar2);
   procedure process_record_top(par_record in varchar2);
   procedure process_record_cur(par_record in varchar2);
   procedure process_record_bnk(par_record in varchar2);
   procedure process_record_ftd(par_record in varchar2);
   procedure process_record_txt(par_record in varchar2);
   procedure process_record_txi(par_record in varchar2);
   procedure process_record_org(par_record in varchar2);
   procedure process_record_sal(par_record in varchar2);
   procedure process_record_gen(par_record in varchar2);
   procedure process_record_gez(par_record in varchar2);
   procedure process_record_mat(par_record in varchar2);
   procedure process_record_grd(par_record in varchar2);
   procedure process_record_irf(par_record in varchar2);
   procedure process_record_idt(par_record in varchar2);
   procedure process_record_iob(par_record in varchar2);
   procedure process_record_ias(par_record in varchar2);
   procedure process_record_ipn(par_record in varchar2);
   procedure process_record_iaj(par_record in varchar2);
   procedure process_record_icn(par_record in varchar2);
   procedure process_record_icp(par_record in varchar2);
   procedure process_record_ita(par_record in varchar2);
   procedure process_record_ift(par_record in varchar2);
   procedure process_record_icb(par_record in varchar2);
   procedure process_record_itx(par_record in varchar2);
   procedure process_record_iti(par_record in varchar2);
   procedure process_record_smy(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_ctl_mescod varchar2(3);
   var_ctl_mesfct varchar2(3);
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_inv_hdr lads_inv_hdr%rowtype;
   rcd_lads_inv_cus lads_inv_cus%rowtype;
   rcd_lads_inv_con lads_inv_con%rowtype;
   rcd_lads_inv_pnr lads_inv_pnr%rowtype;
   rcd_lads_inv_adj lads_inv_adj%rowtype;
   rcd_lads_inv_ref lads_inv_ref%rowtype;
   rcd_lads_inv_dat lads_inv_dat%rowtype;
   rcd_lads_inv_dcn lads_inv_dcn%rowtype;
   rcd_lads_inv_tax lads_inv_tax%rowtype;
   rcd_lads_inv_tod lads_inv_tod%rowtype;
   rcd_lads_inv_top lads_inv_top%rowtype;
   rcd_lads_inv_cur lads_inv_cur%rowtype;
   rcd_lads_inv_bnk lads_inv_bnk%rowtype;
   rcd_lads_inv_ftd lads_inv_ftd%rowtype;
   rcd_lads_inv_txt lads_inv_txt%rowtype;
   rcd_lads_inv_txi lads_inv_txi%rowtype;
   rcd_lads_inv_org lads_inv_org%rowtype;
   rcd_lads_inv_sal lads_inv_sal%rowtype;
   rcd_lads_inv_gen lads_inv_gen%rowtype;
   rcd_lads_inv_mat lads_inv_mat%rowtype;
   rcd_lads_inv_grd lads_inv_grd%rowtype;
   rcd_lads_inv_irf lads_inv_irf%rowtype;
   rcd_lads_inv_idt lads_inv_idt%rowtype;
   rcd_lads_inv_iob lads_inv_iob%rowtype;
   rcd_lads_inv_ias lads_inv_ias%rowtype;
   rcd_lads_inv_ipn lads_inv_ipn%rowtype;
   rcd_lads_inv_iaj lads_inv_iaj%rowtype;
   rcd_lads_inv_icn lads_inv_icn%rowtype;
   rcd_lads_inv_icp lads_inv_icp%rowtype;
   rcd_lads_inv_ita lads_inv_ita%rowtype;
   rcd_lads_inv_ift lads_inv_ift%rowtype;
   rcd_lads_inv_icb lads_inv_icb%rowtype;
   rcd_lads_inv_itx lads_inv_itx%rowtype;
   rcd_lads_inv_iti lads_inv_iti%rowtype;
   rcd_lads_inv_smy lads_inv_smy%rowtype;

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
      lics_inbound_utility.set_definition('CUS','IDOC_CUS',3);
      lics_inbound_utility.set_definition('CUS','CUSTOMER',10);
      lics_inbound_utility.set_definition('CUS','ATNAM',30);
      lics_inbound_utility.set_definition('CUS','ATWRT',30);
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
      lics_inbound_utility.set_definition('ADJ','IDOC_ADJ',3);
      lics_inbound_utility.set_definition('ADJ','LANGU',2);
      lics_inbound_utility.set_definition('ADJ','NATION',1);
      lics_inbound_utility.set_definition('ADJ','NAME1',40);
      lics_inbound_utility.set_definition('ADJ','NAME2',40);
      lics_inbound_utility.set_definition('ADJ','NAME3',40);
      lics_inbound_utility.set_definition('ADJ','STREET',60);
      lics_inbound_utility.set_definition('ADJ','STR_SUPPL1',40);
      lics_inbound_utility.set_definition('ADJ','STR_SUPPL2',40);
      lics_inbound_utility.set_definition('ADJ','CITY1',40);
      lics_inbound_utility.set_definition('ADJ','CITY2',40);
      lics_inbound_utility.set_definition('ADJ','PO_BOX',10);
      lics_inbound_utility.set_definition('ADJ','COUNTRY',3);
      lics_inbound_utility.set_definition('ADJ','FAX_NUMBER',30);
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
      lics_inbound_utility.set_definition('DCN','IDOC_DCN',3);
      lics_inbound_utility.set_definition('DCN','ALCKZ',3);
      lics_inbound_utility.set_definition('DCN','KSCHL',4);
      lics_inbound_utility.set_definition('DCN','KOTXT',80);
      lics_inbound_utility.set_definition('DCN','BETRG',18);
      lics_inbound_utility.set_definition('DCN','KPERC',8);
      lics_inbound_utility.set_definition('DCN','KRATE',15);
      lics_inbound_utility.set_definition('DCN','UPRBS',9);
      lics_inbound_utility.set_definition('DCN','MEAUN',3);
      lics_inbound_utility.set_definition('DCN','KOBTR',18);
      lics_inbound_utility.set_definition('DCN','MWSKZ',7);
      lics_inbound_utility.set_definition('DCN','MSATZ',17);
      lics_inbound_utility.set_definition('DCN','KOEIN',3);
      /*-*/
      lics_inbound_utility.set_definition('TAX','IDOC_TAX',3);
      lics_inbound_utility.set_definition('TAX','MWSKZ',7);
      lics_inbound_utility.set_definition('TAX','MSATZ',17);
      lics_inbound_utility.set_definition('TAX','MWSBT',18);
      lics_inbound_utility.set_definition('TAX','TXJCD',15);
      lics_inbound_utility.set_definition('TAX','KTEXT',50);
      lics_inbound_utility.set_definition('TAX','ZNTVAT',18);
      lics_inbound_utility.set_definition('TAX','ZGRAMOUNT',18);
      lics_inbound_utility.set_definition('TAX','VATDESC',50);
      /*-*/
      lics_inbound_utility.set_definition('TOD','IDOC_TOD',3);
      lics_inbound_utility.set_definition('TOD','QUALF',3);
      lics_inbound_utility.set_definition('TOD','LKOND',3);
      lics_inbound_utility.set_definition('TOD','LKTEXT',70);
      /*-*/
      lics_inbound_utility.set_definition('TOP','IDOC_TOP',3);
      lics_inbound_utility.set_definition('TOP','QUALF',3);
      lics_inbound_utility.set_definition('TOP','TAGE',8);
      lics_inbound_utility.set_definition('TOP','PRZNT',8);
      lics_inbound_utility.set_definition('TOP','ZTERM_TXT',70);
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
      lics_inbound_utility.set_definition('BNK','IDOC_BNK',3);
      lics_inbound_utility.set_definition('BNK','BCOUN',3);
      lics_inbound_utility.set_definition('BNK','BRNUM',17);
      lics_inbound_utility.set_definition('BNK','BNAME',70);
      lics_inbound_utility.set_definition('BNK','BALOC',70);
      lics_inbound_utility.set_definition('BNK','ACNUM',30);
      lics_inbound_utility.set_definition('BNK','ACNAM',35);
      /*-*/
      lics_inbound_utility.set_definition('FTD','IDOC_FTD',3);
      lics_inbound_utility.set_definition('FTD','EXNUM',10);
      lics_inbound_utility.set_definition('FTD','ALAND',3);
      lics_inbound_utility.set_definition('FTD','EXPVZ',1);
      lics_inbound_utility.set_definition('FTD','ZOLLA',6);
      lics_inbound_utility.set_definition('FTD','ZOLLB',6);
      lics_inbound_utility.set_definition('FTD','ZOLL1',6);
      lics_inbound_utility.set_definition('FTD','ZOLL2',6);
      lics_inbound_utility.set_definition('FTD','ZOLL3',6);
      lics_inbound_utility.set_definition('FTD','ZOLL4',6);
      lics_inbound_utility.set_definition('FTD','ZOLL5',6);
      lics_inbound_utility.set_definition('FTD','ZOLL6',6);
      lics_inbound_utility.set_definition('FTD','KZGBE',30);
      lics_inbound_utility.set_definition('FTD','KZABE',30);
      lics_inbound_utility.set_definition('FTD','STGBE',3);
      lics_inbound_utility.set_definition('FTD','STABE',3);
      lics_inbound_utility.set_definition('FTD','CONTA',1);
      lics_inbound_utility.set_definition('FTD','GRWCU',5);
      lics_inbound_utility.set_definition('FTD','GRWRT',18);
      lics_inbound_utility.set_definition('FTD','LAND1',3);
      lics_inbound_utility.set_definition('FTD','LANDX',15);
      lics_inbound_utility.set_definition('FTD','LANDA',3);
      lics_inbound_utility.set_definition('FTD','XEGLD',1);
      lics_inbound_utility.set_definition('FTD','FREIH',1);
      lics_inbound_utility.set_definition('FTD','EWRCO',1);
      lics_inbound_utility.set_definition('FTD','USC05',5);
      lics_inbound_utility.set_definition('FTD','JAP05',5);
      lics_inbound_utility.set_definition('FTD','ALANX',15);
      lics_inbound_utility.set_definition('FTD','ALANA',3);
      lics_inbound_utility.set_definition('FTD','LASTA',3);
      lics_inbound_utility.set_definition('FTD','LASTG',3);
      lics_inbound_utility.set_definition('FTD','ALSCH',3);
      lics_inbound_utility.set_definition('FTD','ALSRE',5);
      lics_inbound_utility.set_definition('FTD','LADEO',15);
      lics_inbound_utility.set_definition('FTD','IEVER',1);
      lics_inbound_utility.set_definition('FTD','BANR01',16);
      lics_inbound_utility.set_definition('FTD','BANR02',3);
      lics_inbound_utility.set_definition('FTD','BANR03',7);
      lics_inbound_utility.set_definition('FTD','BANR04',7);
      lics_inbound_utility.set_definition('FTD','BANR05',7);
      lics_inbound_utility.set_definition('FTD','BANR06',7);
      lics_inbound_utility.set_definition('FTD','BANR07',7);
      lics_inbound_utility.set_definition('FTD','BANR08',7);
      lics_inbound_utility.set_definition('FTD','BANR09',3);
      lics_inbound_utility.set_definition('FTD','BANR10',8);
      lics_inbound_utility.set_definition('FTD','WZOCU',5);
      lics_inbound_utility.set_definition('FTD','EXPVZTX',20);
      lics_inbound_utility.set_definition('FTD','ZOLLATX',30);
      lics_inbound_utility.set_definition('FTD','ZOLLBTX',30);
      lics_inbound_utility.set_definition('FTD','STGBETX',15);
      lics_inbound_utility.set_definition('FTD','STABETX',15);
      lics_inbound_utility.set_definition('FTD','FREIHTX',20);
      lics_inbound_utility.set_definition('FTD','LADEL',40);
      lics_inbound_utility.set_definition('FTD','TEXT1',40);
      lics_inbound_utility.set_definition('FTD','TEXT2',40);
      lics_inbound_utility.set_definition('FTD','TEXT3',40);
      lics_inbound_utility.set_definition('FTD','GBNUM',20);
      lics_inbound_utility.set_definition('FTD','REGNR',20);
      lics_inbound_utility.set_definition('FTD','AUSFU',10);
      lics_inbound_utility.set_definition('FTD','IEVER_TX',20);
      lics_inbound_utility.set_definition('FTD','LAZL1',3);
      lics_inbound_utility.set_definition('FTD','LAZL2',3);
      lics_inbound_utility.set_definition('FTD','LAZL3',3);
      lics_inbound_utility.set_definition('FTD','LAZL4',3);
      lics_inbound_utility.set_definition('FTD','LAZL5',3);
      lics_inbound_utility.set_definition('FTD','LAZL6',3);
      lics_inbound_utility.set_definition('FTD','AZOLL',6);
      lics_inbound_utility.set_definition('FTD','AZOLLTX',30);
      lics_inbound_utility.set_definition('FTD','BFMAR',6);
      lics_inbound_utility.set_definition('FTD','FTVBD',1);
      lics_inbound_utility.set_definition('FTD','CUDCL',3);
      lics_inbound_utility.set_definition('FTD','FTUPD',1);
      /*-*/
      lics_inbound_utility.set_definition('TXT','IDOC_TXT',3);
      lics_inbound_utility.set_definition('TXT','TDID',4);
      lics_inbound_utility.set_definition('TXT','TSSPRAS',3);
      lics_inbound_utility.set_definition('TXT','TSSPRAS_ISO',2);
      lics_inbound_utility.set_definition('TXT','TDOBJECT',10);
      lics_inbound_utility.set_definition('TXT','TDOBNAME',70);
      /*-*/
      lics_inbound_utility.set_definition('TXI','IDOC_TXI',3);
      lics_inbound_utility.set_definition('TXI','TDLINE',70);
      lics_inbound_utility.set_definition('TXI','TDFORMAT',2);
      /*-*/
      lics_inbound_utility.set_definition('ORG','IDOC_ORG',3);
      lics_inbound_utility.set_definition('ORG','QUALF',3);
      lics_inbound_utility.set_definition('ORG','ORGID',35);
      /*-*/
      lics_inbound_utility.set_definition('SAL','IDOC_SAL',3);
      lics_inbound_utility.set_definition('SAL','VKGRP',3);
      lics_inbound_utility.set_definition('SAL','BEZEI',20);
      lics_inbound_utility.set_definition('SAL','CSCFN',40);
      lics_inbound_utility.set_definition('SAL','CSCLN',40);
      lics_inbound_utility.set_definition('SAL','CSCTEL',16);
      lics_inbound_utility.set_definition('SAL','ADDL1',20);
      lics_inbound_utility.set_definition('SAL','ADDL2',20);
      lics_inbound_utility.set_definition('SAL','ADDL3',20);
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
      lics_inbound_utility.set_definition('GRD','IDOC_GRD',3);
      lics_inbound_utility.set_definition('GRD','Z_LCDID',5);
      lics_inbound_utility.set_definition('GRD','Z_LCDNR',18);
      lics_inbound_utility.set_definition('GRD','Z_LCDDSC',16);
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
      lics_inbound_utility.set_definition('IAJ','IDOC_IAJ',3);
      lics_inbound_utility.set_definition('IAJ','LANGU',2);
      lics_inbound_utility.set_definition('IAJ','NATION',1);
      lics_inbound_utility.set_definition('IAJ','NAME1',40);
      lics_inbound_utility.set_definition('IAJ','NAME2',40);
      lics_inbound_utility.set_definition('IAJ','NAME3',40);
      lics_inbound_utility.set_definition('IAJ','STREET',60);
      lics_inbound_utility.set_definition('IAJ','STR_SUPPL1',40);
      lics_inbound_utility.set_definition('IAJ','STR_SUPPL2',40);
      lics_inbound_utility.set_definition('IAJ','CITY1',40);
      lics_inbound_utility.set_definition('IAJ','CITY2',40);
      lics_inbound_utility.set_definition('IAJ','PO_BOX',10);
      lics_inbound_utility.set_definition('IAJ','COUNTRY',3);
      lics_inbound_utility.set_definition('IAJ','FAX_NUMBER',30);
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
      lics_inbound_utility.set_definition('ICP','IDOC_ICP',3);
      lics_inbound_utility.set_definition('ICP','KOSRT',10);
      /*-*/
      lics_inbound_utility.set_definition('ITA','IDOC_ITA',3);
      lics_inbound_utility.set_definition('ITA','MWSKZ',7);
      lics_inbound_utility.set_definition('ITA','MSATZ',17);
      lics_inbound_utility.set_definition('ITA','MWSBT',18);
      lics_inbound_utility.set_definition('ITA','TXJCD',15);
      lics_inbound_utility.set_definition('ITA','KTEXT',50);
      lics_inbound_utility.set_definition('ITA','LTX01',72);
      lics_inbound_utility.set_definition('ITA','LTX02',72);
      lics_inbound_utility.set_definition('ITA','LTX03',72);
      lics_inbound_utility.set_definition('ITA','LTX04',72);
      /*-*/
      lics_inbound_utility.set_definition('IFT','IDOC_IFT',3);
      lics_inbound_utility.set_definition('IFT','EXNUM',10);
      lics_inbound_utility.set_definition('IFT','EXPOS',6);
      lics_inbound_utility.set_definition('IFT','STAWN',17);
      lics_inbound_utility.set_definition('IFT','EXPRF',5);
      lics_inbound_utility.set_definition('IFT','EXART',2);
      lics_inbound_utility.set_definition('IFT','HERKL',3);
      lics_inbound_utility.set_definition('IFT','HERKR',3);
      lics_inbound_utility.set_definition('IFT','HERTA',3);
      lics_inbound_utility.set_definition('IFT','HERTI',15);
      lics_inbound_utility.set_definition('IFT','STXT1',40);
      lics_inbound_utility.set_definition('IFT','STXT2',40);
      lics_inbound_utility.set_definition('IFT','STXT3',40);
      lics_inbound_utility.set_definition('IFT','STXT4',40);
      lics_inbound_utility.set_definition('IFT','STXT5',40);
      lics_inbound_utility.set_definition('IFT','STXT6',40);
      lics_inbound_utility.set_definition('IFT','STXT7',40);
      lics_inbound_utility.set_definition('IFT','BEMAS',5);
      lics_inbound_utility.set_definition('IFT','PREFE',1);
      lics_inbound_utility.set_definition('IFT','BOLNR',35);
      lics_inbound_utility.set_definition('IFT','TRATY',4);
      lics_inbound_utility.set_definition('IFT','TRAID',20);
      lics_inbound_utility.set_definition('IFT','BRULO',18);
      lics_inbound_utility.set_definition('IFT','NETLO',18);
      lics_inbound_utility.set_definition('IFT','VEMEH',3);
      lics_inbound_utility.set_definition('IFT','HERBL',2);
      lics_inbound_utility.set_definition('IFT','BMGEW',18);
      lics_inbound_utility.set_definition('IFT','TEXT1',40);
      lics_inbound_utility.set_definition('IFT','TEXT2',40);
      lics_inbound_utility.set_definition('IFT','TEXT3',40);
      lics_inbound_utility.set_definition('IFT','COIMP',17);
      lics_inbound_utility.set_definition('IFT','COADI',6);
      lics_inbound_utility.set_definition('IFT','COKON',6);
      lics_inbound_utility.set_definition('IFT','COPHA',6);
      lics_inbound_utility.set_definition('IFT','CASNR',15);
      lics_inbound_utility.set_definition('IFT','VERLD',3);
      lics_inbound_utility.set_definition('IFT','VERLD_TX',15);
      lics_inbound_utility.set_definition('IFT','HANLD',3);
      lics_inbound_utility.set_definition('IFT','HANLD_TX',15);
      lics_inbound_utility.set_definition('IFT','EXPRF_TX',30);
      lics_inbound_utility.set_definition('IFT','EXART_TX',30);
      lics_inbound_utility.set_definition('IFT','GBNUM',20);
      lics_inbound_utility.set_definition('IFT','REGNR',20);
      lics_inbound_utility.set_definition('IFT','HERSE',10);
      lics_inbound_utility.set_definition('IFT','HERKR_TX',20);
      lics_inbound_utility.set_definition('IFT','COBLD',17);
      lics_inbound_utility.set_definition('IFT','EIOKA',1);
      lics_inbound_utility.set_definition('IFT','VERFA',8);
      lics_inbound_utility.set_definition('IFT','PRENC',1);
      lics_inbound_utility.set_definition('IFT','PRENO',8);
      lics_inbound_utility.set_definition('IFT','PREND',8);
      lics_inbound_utility.set_definition('IFT','BESMA',3);
      lics_inbound_utility.set_definition('IFT','IMPMA',3);
      lics_inbound_utility.set_definition('IFT','KTNUM',10);
      lics_inbound_utility.set_definition('IFT','PLNUM',10);
      lics_inbound_utility.set_definition('IFT','WKREG',3);
      lics_inbound_utility.set_definition('IFT','IMGEW',18);
      /*-*/
      lics_inbound_utility.set_definition('ICB','IDOC_ICB',3);
      lics_inbound_utility.set_definition('ICB','QUALF',3);
      lics_inbound_utility.set_definition('ICB','IVKON',30);
      /*-*/
      lics_inbound_utility.set_definition('ITX','IDOC_ITX',3);
      lics_inbound_utility.set_definition('ITX','TDID',4);
      lics_inbound_utility.set_definition('ITX','TSSPRAS',3);
      lics_inbound_utility.set_definition('ITX','TSSPRAS_ISO',2);
      /*-*/
      lics_inbound_utility.set_definition('ITI','IDOC_ITI',3);
      lics_inbound_utility.set_definition('ITI','TDLINE',70);
      lics_inbound_utility.set_definition('ITI','TDFORMAT',2);
      /*-*/
      lics_inbound_utility.set_definition('SMY','IDOC_SMY',3);
      lics_inbound_utility.set_definition('SMY','SUMID',3);
      lics_inbound_utility.set_definition('SMY','SUMME',18);
      lics_inbound_utility.set_definition('SMY','SUNIT',3);
      lics_inbound_utility.set_definition('SMY','WAERQ',3);

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
         when 'CUS' then process_record_cus(par_record);
         when 'CON' then process_record_con(par_record);
         when 'PNR' then process_record_pnr(par_record);
         when 'ADJ' then process_record_adj(par_record);
         when 'REF' then process_record_ref(par_record);
         when 'DAT' then process_record_dat(par_record);
         when 'DCN' then process_record_dcn(par_record);
         when 'TAX' then process_record_tax(par_record);
         when 'TOD' then process_record_tod(par_record);
         when 'TOP' then process_record_top(par_record);
         when 'CUR' then process_record_cur(par_record);
         when 'BNK' then process_record_bnk(par_record);
         when 'FTD' then process_record_ftd(par_record);
         when 'TXT' then process_record_txt(par_record);
         when 'TXI' then process_record_txi(par_record);
         when 'ORG' then process_record_org(par_record);
         when 'SAL' then process_record_sal(par_record);
         when 'GEN' then process_record_gen(par_record);
         when 'GEZ' then process_record_gez(par_record);
         when 'MAT' then process_record_mat(par_record);
         when 'GRD' then process_record_grd(par_record);
         when 'IRF' then process_record_irf(par_record);
         when 'IDT' then process_record_idt(par_record);
         when 'IOB' then process_record_iob(par_record);
         when 'IAS' then process_record_ias(par_record);
         when 'IPN' then process_record_ipn(par_record);
         when 'IAJ' then process_record_iaj(par_record);
         when 'ICN' then process_record_icn(par_record);
         when 'ICP' then process_record_icp(par_record);
         when 'ITA' then process_record_ita(par_record);
         when 'IFT' then process_record_ift(par_record);
         when 'ICB' then process_record_icb(par_record);
         when 'ITX' then process_record_itx(par_record);
         when 'ITI' then process_record_iti(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD18';
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
      /* Update GEN lines for ZRK invoice when required
      /*-*/
      if var_trn_ignore = false and
        var_trn_error = false then
        if (rcd_lads_inv_hdr.auart = 'ZRK') then
          update lads_inv_gen
          set menge = nvl(menge,0)*-1,
            ntgew = nvl(ntgew,0)*-1,
            brgew = nvl(brgew,0)*-1,
            volum = nvl(volum,0)*-1,
            fklmg = nvl(fklmg,0)*-1,
            kwmeng = nvl(kwmeng,0)*-1
          where belnr = rcd_lads_inv_hdr.belnr
            and pstyv = 'ZCR2';
        end if;
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
            lads_atllad18_monitor.execute(rcd_lads_inv_hdr.belnr);
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
      cursor csr_lads_inv_hdr_01 is
         select
            t01.belnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_inv_hdr t01
         where t01.belnr = rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_hdr_01 csr_lads_inv_hdr_01%rowtype;

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
      rcd_lads_inv_hdr.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_inv_hdr.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_inv_hdr.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_inv_hdr.hwaer := lics_inbound_utility.get_variable('HWAER');
      rcd_lads_inv_hdr.wkurs := lics_inbound_utility.get_variable('WKURS');
      rcd_lads_inv_hdr.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_inv_hdr.kundeuinr := lics_inbound_utility.get_variable('KUNDEUINR');
      rcd_lads_inv_hdr.eigenuinr := lics_inbound_utility.get_variable('EIGENUINR');
      rcd_lads_inv_hdr.bsart := lics_inbound_utility.get_variable('BSART');
      rcd_lads_inv_hdr.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_inv_hdr.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_inv_hdr.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_inv_hdr.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_inv_hdr.fkart_rl := lics_inbound_utility.get_variable('FKART_RL');
      rcd_lads_inv_hdr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_inv_hdr.bstzd := lics_inbound_utility.get_variable('BSTZD');
      rcd_lads_inv_hdr.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_inv_hdr.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_inv_hdr.recipnt_no := lics_inbound_utility.get_variable('RECIPNT_NO');
      rcd_lads_inv_hdr.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_inv_hdr.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_lads_inv_hdr.augru := lics_inbound_utility.get_variable('AUGRU');
      rcd_lads_inv_hdr.augru_bez := lics_inbound_utility.get_variable('AUGRU_BEZ');
      rcd_lads_inv_hdr.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_inv_hdr.abrvw_bez := lics_inbound_utility.get_variable('ABRVW_BEZ');
      rcd_lads_inv_hdr.fktyp := lics_inbound_utility.get_variable('FKTYP');
      rcd_lads_inv_hdr.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_lads_inv_hdr.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_lads_inv_hdr.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_inv_hdr.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_inv_hdr.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_inv_hdr.wkurs_m := lics_inbound_utility.get_variable('WKURS_M');
      rcd_lads_inv_hdr.z_edi_relevant := lics_inbound_utility.get_variable('Z_EDI_RELEVANT');
      rcd_lads_inv_hdr.zlsch := lics_inbound_utility.get_variable('ZLSCH');
      rcd_lads_inv_hdr.text1 := lics_inbound_utility.get_variable('TEXT1');
      rcd_lads_inv_hdr.vbtyp := lics_inbound_utility.get_variable('VBTYP');
      rcd_lads_inv_hdr.expnr := lics_inbound_utility.get_variable('EXPNR');
      rcd_lads_inv_hdr.reprint := lics_inbound_utility.get_variable('REPRINT');
      rcd_lads_inv_hdr.crpc_version := lics_inbound_utility.get_variable('CRPC_VERSION');
      rcd_lads_inv_hdr.zzsplitinvlines := lics_inbound_utility.get_variable('ZZSPLITINVLINES');
      rcd_lads_inv_hdr.bbbnr := lics_inbound_utility.get_number('BBBNR',null);
      rcd_lads_inv_hdr.bbsnr := lics_inbound_utility.get_number('BBSNR',null);
      rcd_lads_inv_hdr.abrvw2 := lics_inbound_utility.get_variable('ABRVW2');
      rcd_lads_inv_hdr.auart := lics_inbound_utility.get_variable('AUART');
      rcd_lads_inv_hdr.zzinternal_doc := lics_inbound_utility.get_variable('ZZINTERNAL_DOC');
      rcd_lads_inv_hdr.mescod := var_ctl_mescod;
      rcd_lads_inv_hdr.mesfct := var_ctl_mesfct;
      rcd_lads_inv_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_inv_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_inv_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_inv_hdr.lads_date := sysdate;
      rcd_lads_inv_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_cus.cusseq := 0;
      rcd_lads_inv_con.conseq := 0;
      rcd_lads_inv_pnr.pnrseq := 0;
      rcd_lads_inv_ref.refseq := 0;
      rcd_lads_inv_dat.datseq := 0;
      rcd_lads_inv_dcn.dcnseq := 0;
      rcd_lads_inv_tax.taxseq := 0;
      rcd_lads_inv_tod.todseq := 0;
      rcd_lads_inv_top.topseq := 0;
      rcd_lads_inv_cur.curseq := 0;
      rcd_lads_inv_bnk.bnkseq := 0;
      rcd_lads_inv_ftd.ftdseq := 0;
      rcd_lads_inv_txt.txtseq := 0;
      rcd_lads_inv_org.orgseq := 0;
      rcd_lads_inv_gen.genseq := 0;
      rcd_lads_inv_smy.smyseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_hdr.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BELNR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_inv_hdr.belnr is null) then
         var_exists := true;
         open csr_lads_inv_hdr_01;
         fetch csr_lads_inv_hdr_01 into rcd_lads_inv_hdr_01;
         if csr_lads_inv_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_inv_hdr_01;
         if var_exists = true then
            if rcd_lads_inv_hdr.idoc_timestamp > rcd_lads_inv_hdr_01.idoc_timestamp then
               delete from lads_inv_smy where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_iti where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_itx where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_icb where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_ift where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_ita where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_icp where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_icn where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_iaj where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_ipn where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_ias where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_iob where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_idt where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_irf where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_grd where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_mat where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_gen where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_sal where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_org where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_txi where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_txt where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_ftd where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_bnk where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_cur where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_top where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_tod where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_tax where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_dcn where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_dat where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_ref where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_adj where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_pnr where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_con where belnr = rcd_lads_inv_hdr.belnr;
               delete from lads_inv_cus where belnr = rcd_lads_inv_hdr.belnr;
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

      update lads_inv_hdr set
         action = rcd_lads_inv_hdr.action,
         kzabs = rcd_lads_inv_hdr.kzabs,
         curcy = rcd_lads_inv_hdr.curcy,
         hwaer = rcd_lads_inv_hdr.hwaer,
         wkurs = rcd_lads_inv_hdr.wkurs,
         zterm = rcd_lads_inv_hdr.zterm,
         kundeuinr = rcd_lads_inv_hdr.kundeuinr,
         eigenuinr = rcd_lads_inv_hdr.eigenuinr,
         bsart = rcd_lads_inv_hdr.bsart,
         ntgew = rcd_lads_inv_hdr.ntgew,
         brgew = rcd_lads_inv_hdr.brgew,
         gewei = rcd_lads_inv_hdr.gewei,
         fkart_rl = rcd_lads_inv_hdr.fkart_rl,
         ablad = rcd_lads_inv_hdr.ablad,
         bstzd = rcd_lads_inv_hdr.bstzd,
         vsart = rcd_lads_inv_hdr.vsart,
         vsart_bez = rcd_lads_inv_hdr.vsart_bez,
         recipnt_no = rcd_lads_inv_hdr.recipnt_no,
         kzazu = rcd_lads_inv_hdr.kzazu,
         autlf = rcd_lads_inv_hdr.autlf,
         augru = rcd_lads_inv_hdr.augru,
         augru_bez = rcd_lads_inv_hdr.augru_bez,
         abrvw = rcd_lads_inv_hdr.abrvw,
         abrvw_bez = rcd_lads_inv_hdr.abrvw_bez,
         fktyp = rcd_lads_inv_hdr.fktyp,
         lifsk = rcd_lads_inv_hdr.lifsk,
         lifsk_bez = rcd_lads_inv_hdr.lifsk_bez,
         empst = rcd_lads_inv_hdr.empst,
         abtnr = rcd_lads_inv_hdr.abtnr,
         delco = rcd_lads_inv_hdr.delco,
         wkurs_m = rcd_lads_inv_hdr.wkurs_m,
         z_edi_relevant = rcd_lads_inv_hdr.z_edi_relevant,
         zlsch = rcd_lads_inv_hdr.zlsch,
         text1 = rcd_lads_inv_hdr.text1,
         vbtyp = rcd_lads_inv_hdr.vbtyp,
         expnr = rcd_lads_inv_hdr.expnr,
         reprint = rcd_lads_inv_hdr.reprint,
         crpc_version = rcd_lads_inv_hdr.crpc_version,
         zzsplitinvlines = rcd_lads_inv_hdr.zzsplitinvlines,
         bbbnr = rcd_lads_inv_hdr.bbbnr,
         bbsnr = rcd_lads_inv_hdr.bbsnr,
         abrvw2 = rcd_lads_inv_hdr.abrvw2,
         auart = rcd_lads_inv_hdr.auart,
         zzinternal_doc = rcd_lads_inv_hdr.zzinternal_doc,
         mescod = rcd_lads_inv_hdr.mescod,
         mesfct = rcd_lads_inv_hdr.mesfct,
         idoc_name = rcd_lads_inv_hdr.idoc_name,
         idoc_number = rcd_lads_inv_hdr.idoc_number,
         idoc_timestamp = rcd_lads_inv_hdr.idoc_timestamp,
         lads_date = rcd_lads_inv_hdr.lads_date,
         lads_status = rcd_lads_inv_hdr.lads_status
      where belnr = rcd_lads_inv_hdr.belnr;
      if sql%notfound then
         insert into lads_inv_hdr
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
             lads_date,
             lads_status)
         values
            (rcd_lads_inv_hdr.action,
             rcd_lads_inv_hdr.kzabs,
             rcd_lads_inv_hdr.curcy,
             rcd_lads_inv_hdr.hwaer,
             rcd_lads_inv_hdr.wkurs,
             rcd_lads_inv_hdr.zterm,
             rcd_lads_inv_hdr.kundeuinr,
             rcd_lads_inv_hdr.eigenuinr,
             rcd_lads_inv_hdr.bsart,
             rcd_lads_inv_hdr.belnr,
             rcd_lads_inv_hdr.ntgew,
             rcd_lads_inv_hdr.brgew,
             rcd_lads_inv_hdr.gewei,
             rcd_lads_inv_hdr.fkart_rl,
             rcd_lads_inv_hdr.ablad,
             rcd_lads_inv_hdr.bstzd,
             rcd_lads_inv_hdr.vsart,
             rcd_lads_inv_hdr.vsart_bez,
             rcd_lads_inv_hdr.recipnt_no,
             rcd_lads_inv_hdr.kzazu,
             rcd_lads_inv_hdr.autlf,
             rcd_lads_inv_hdr.augru,
             rcd_lads_inv_hdr.augru_bez,
             rcd_lads_inv_hdr.abrvw,
             rcd_lads_inv_hdr.abrvw_bez,
             rcd_lads_inv_hdr.fktyp,
             rcd_lads_inv_hdr.lifsk,
             rcd_lads_inv_hdr.lifsk_bez,
             rcd_lads_inv_hdr.empst,
             rcd_lads_inv_hdr.abtnr,
             rcd_lads_inv_hdr.delco,
             rcd_lads_inv_hdr.wkurs_m,
             rcd_lads_inv_hdr.z_edi_relevant,
             rcd_lads_inv_hdr.zlsch,
             rcd_lads_inv_hdr.text1,
             rcd_lads_inv_hdr.vbtyp,
             rcd_lads_inv_hdr.expnr,
             rcd_lads_inv_hdr.reprint,
             rcd_lads_inv_hdr.crpc_version,
             rcd_lads_inv_hdr.zzsplitinvlines,
             rcd_lads_inv_hdr.bbbnr,
             rcd_lads_inv_hdr.bbsnr,
             rcd_lads_inv_hdr.abrvw2,
             rcd_lads_inv_hdr.auart,
             rcd_lads_inv_hdr.zzinternal_doc,
             rcd_lads_inv_hdr.mescod,
             rcd_lads_inv_hdr.mesfct,
             rcd_lads_inv_hdr.idoc_name,
             rcd_lads_inv_hdr.idoc_number,
             rcd_lads_inv_hdr.idoc_timestamp,
             rcd_lads_inv_hdr.lads_date,
             rcd_lads_inv_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record CUS routine */
   /**************************************************/
   procedure process_record_cus(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CUS', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_cus.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_cus.cusseq := rcd_lads_inv_cus.cusseq + 1;
      rcd_lads_inv_cus.customer := lics_inbound_utility.get_variable('CUSTOMER');
      rcd_lads_inv_cus.atnam := lics_inbound_utility.get_variable('ATNAM');
      rcd_lads_inv_cus.atwrt := lics_inbound_utility.get_variable('ATWRT');

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
      if rcd_lads_inv_cus.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CUS.BELNR');
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

      insert into lads_inv_cus
         (belnr,
          cusseq,
          customer,
          atnam,
          atwrt)
      values
         (rcd_lads_inv_cus.belnr,
          rcd_lads_inv_cus.cusseq,
          rcd_lads_inv_cus.customer,
          rcd_lads_inv_cus.atnam,
          rcd_lads_inv_cus.atwrt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_cus;

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
      rcd_lads_inv_con.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_con.conseq := rcd_lads_inv_con.conseq + 1;
      rcd_lads_inv_con.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_inv_con.krech := lics_inbound_utility.get_variable('KRECH');
      rcd_lads_inv_con.kawrt := lics_inbound_utility.get_number('KAWRT',null);
      rcd_lads_inv_con.awein := lics_inbound_utility.get_variable('AWEIN');
      rcd_lads_inv_con.awei1 := lics_inbound_utility.get_variable('AWEI1');
      rcd_lads_inv_con.kbetr := lics_inbound_utility.get_number('KBETR',null);
      rcd_lads_inv_con.koein := lics_inbound_utility.get_variable('KOEIN');
      rcd_lads_inv_con.koei1 := lics_inbound_utility.get_variable('KOEI1');
      rcd_lads_inv_con.kkurs := lics_inbound_utility.get_number('KKURS',null);
      rcd_lads_inv_con.kpein := lics_inbound_utility.get_number('KPEIN',null);
      rcd_lads_inv_con.kmein := lics_inbound_utility.get_variable('KMEIN');
      rcd_lads_inv_con.kumza := lics_inbound_utility.get_number('KUMZA',null);
      rcd_lads_inv_con.kumne := lics_inbound_utility.get_number('KUMNE',null);
      rcd_lads_inv_con.kntyp := lics_inbound_utility.get_variable('KNTYP');
      rcd_lads_inv_con.kstat := lics_inbound_utility.get_variable('KSTAT');
      rcd_lads_inv_con.kherk := lics_inbound_utility.get_variable('KHERK');
      rcd_lads_inv_con.kwert := lics_inbound_utility.get_number('KWERT',null);
      rcd_lads_inv_con.ksteu := lics_inbound_utility.get_variable('KSTEU');
      rcd_lads_inv_con.kinak := lics_inbound_utility.get_variable('KINAK');
      rcd_lads_inv_con.koaid := lics_inbound_utility.get_variable('KOAID');
      rcd_lads_inv_con.knumt := lics_inbound_utility.get_variable('KNUMT');
      rcd_lads_inv_con.drukz := lics_inbound_utility.get_variable('DRUKZ');
      rcd_lads_inv_con.vtext := lics_inbound_utility.get_variable('VTEXT');
      rcd_lads_inv_con.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_inv_con.stufe := lics_inbound_utility.get_number('STUFE',null);
      rcd_lads_inv_con.wegxx := lics_inbound_utility.get_number('WEGXX',null);
      rcd_lads_inv_con.kfaktor := lics_inbound_utility.get_number('KFAKTOR',null);
      rcd_lads_inv_con.nrmng := lics_inbound_utility.get_number('NRMNG',null);
      rcd_lads_inv_con.mdflg := lics_inbound_utility.get_variable('MDFLG');
      rcd_lads_inv_con.kwert_euro := lics_inbound_utility.get_number('KWERT_EURO',null);

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
      if rcd_lads_inv_con.belnr is null then
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

      insert into lads_inv_con
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
         (rcd_lads_inv_con.belnr,
          rcd_lads_inv_con.conseq,
          rcd_lads_inv_con.kschl,
          rcd_lads_inv_con.krech,
          rcd_lads_inv_con.kawrt,
          rcd_lads_inv_con.awein,
          rcd_lads_inv_con.awei1,
          rcd_lads_inv_con.kbetr,
          rcd_lads_inv_con.koein,
          rcd_lads_inv_con.koei1,
          rcd_lads_inv_con.kkurs,
          rcd_lads_inv_con.kpein,
          rcd_lads_inv_con.kmein,
          rcd_lads_inv_con.kumza,
          rcd_lads_inv_con.kumne,
          rcd_lads_inv_con.kntyp,
          rcd_lads_inv_con.kstat,
          rcd_lads_inv_con.kherk,
          rcd_lads_inv_con.kwert,
          rcd_lads_inv_con.ksteu,
          rcd_lads_inv_con.kinak,
          rcd_lads_inv_con.koaid,
          rcd_lads_inv_con.knumt,
          rcd_lads_inv_con.drukz,
          rcd_lads_inv_con.vtext,
          rcd_lads_inv_con.mwskz,
          rcd_lads_inv_con.stufe,
          rcd_lads_inv_con.wegxx,
          rcd_lads_inv_con.kfaktor,
          rcd_lads_inv_con.nrmng,
          rcd_lads_inv_con.mdflg,
          rcd_lads_inv_con.kwert_euro);

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
      rcd_lads_inv_pnr.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_pnr.pnrseq := rcd_lads_inv_pnr.pnrseq + 1;
      rcd_lads_inv_pnr.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_inv_pnr.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_lads_inv_pnr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_inv_pnr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_inv_pnr.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_inv_pnr.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_inv_pnr.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_inv_pnr.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_inv_pnr.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_lads_inv_pnr.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_lads_inv_pnr.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_inv_pnr.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_lads_inv_pnr.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_lads_inv_pnr.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_lads_inv_pnr.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_inv_pnr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_inv_pnr.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_lads_inv_pnr.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_lads_inv_pnr.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_inv_pnr.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_lads_inv_pnr.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_lads_inv_pnr.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_lads_inv_pnr.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_lads_inv_pnr.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_lads_inv_pnr.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_inv_pnr.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_inv_pnr.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_inv_pnr.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_lads_inv_pnr.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_lads_inv_pnr.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_lads_inv_pnr.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_lads_inv_pnr.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_lads_inv_pnr.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_lads_inv_pnr.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_lads_inv_pnr.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_inv_pnr.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_inv_pnr.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_lads_inv_pnr.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_lads_inv_pnr.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_lads_inv_pnr.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_inv_pnr.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_lads_inv_pnr.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_lads_inv_pnr.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_lads_inv_pnr.title := lics_inbound_utility.get_variable('TITLE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_adj.adjseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_pnr.belnr is null then
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

      insert into lads_inv_pnr
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
         (rcd_lads_inv_pnr.belnr,
          rcd_lads_inv_pnr.pnrseq,
          rcd_lads_inv_pnr.parvw,
          rcd_lads_inv_pnr.partn,
          rcd_lads_inv_pnr.lifnr,
          rcd_lads_inv_pnr.name1,
          rcd_lads_inv_pnr.name2,
          rcd_lads_inv_pnr.name3,
          rcd_lads_inv_pnr.name4,
          rcd_lads_inv_pnr.stras,
          rcd_lads_inv_pnr.strs2,
          rcd_lads_inv_pnr.pfach,
          rcd_lads_inv_pnr.ort01,
          rcd_lads_inv_pnr.counc,
          rcd_lads_inv_pnr.pstlz,
          rcd_lads_inv_pnr.pstl2,
          rcd_lads_inv_pnr.land1,
          rcd_lads_inv_pnr.ablad,
          rcd_lads_inv_pnr.pernr,
          rcd_lads_inv_pnr.parnr,
          rcd_lads_inv_pnr.telf1,
          rcd_lads_inv_pnr.telf2,
          rcd_lads_inv_pnr.telbx,
          rcd_lads_inv_pnr.telfx,
          rcd_lads_inv_pnr.teltx,
          rcd_lads_inv_pnr.telx1,
          rcd_lads_inv_pnr.spras,
          rcd_lads_inv_pnr.anred,
          rcd_lads_inv_pnr.ort02,
          rcd_lads_inv_pnr.hausn,
          rcd_lads_inv_pnr.stock,
          rcd_lads_inv_pnr.regio,
          rcd_lads_inv_pnr.parge,
          rcd_lads_inv_pnr.isoal,
          rcd_lads_inv_pnr.isonu,
          rcd_lads_inv_pnr.fcode,
          rcd_lads_inv_pnr.ihrez,
          rcd_lads_inv_pnr.bname,
          rcd_lads_inv_pnr.paorg,
          rcd_lads_inv_pnr.orgtx,
          rcd_lads_inv_pnr.pagru,
          rcd_lads_inv_pnr.knref,
          rcd_lads_inv_pnr.ilnnr,
          rcd_lads_inv_pnr.pfort,
          rcd_lads_inv_pnr.spras_iso,
          rcd_lads_inv_pnr.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pnr;

   /**************************************************/
   /* This procedure performs the record ADJ routine */
   /**************************************************/
   procedure process_record_adj(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ADJ', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_adj.belnr := rcd_lads_inv_pnr.belnr;
      rcd_lads_inv_adj.pnrseq := rcd_lads_inv_pnr.pnrseq;
      rcd_lads_inv_adj.adjseq := rcd_lads_inv_adj.adjseq + 1;
      rcd_lads_inv_adj.langu := lics_inbound_utility.get_variable('LANGU');
      rcd_lads_inv_adj.nation := lics_inbound_utility.get_variable('NATION');
      rcd_lads_inv_adj.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_inv_adj.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_inv_adj.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_inv_adj.street := lics_inbound_utility.get_variable('STREET');
      rcd_lads_inv_adj.str_suppl1 := lics_inbound_utility.get_variable('STR_SUPPL1');
      rcd_lads_inv_adj.str_suppl2 := lics_inbound_utility.get_variable('STR_SUPPL2');
      rcd_lads_inv_adj.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_inv_adj.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_inv_adj.po_box := lics_inbound_utility.get_variable('PO_BOX');
      rcd_lads_inv_adj.country := lics_inbound_utility.get_variable('COUNTRY');
      rcd_lads_inv_adj.fax_number := lics_inbound_utility.get_variable('FAX_NUMBER');

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
      if rcd_lads_inv_adj.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ADJ.BELNR');
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

      insert into lads_inv_adj
         (belnr,
          pnrseq,
          adjseq,
          langu,
          nation,
          name1,
          name2,
          name3,
          street,
          str_suppl1,
          str_suppl2,
          city1,
          city2,
          po_box,
          country,
          fax_number)
      values
         (rcd_lads_inv_adj.belnr,
          rcd_lads_inv_adj.pnrseq,
          rcd_lads_inv_adj.adjseq,
          rcd_lads_inv_adj.langu,
          rcd_lads_inv_adj.nation,
          rcd_lads_inv_adj.name1,
          rcd_lads_inv_adj.name2,
          rcd_lads_inv_adj.name3,
          rcd_lads_inv_adj.street,
          rcd_lads_inv_adj.str_suppl1,
          rcd_lads_inv_adj.str_suppl2,
          rcd_lads_inv_adj.city1,
          rcd_lads_inv_adj.city2,
          rcd_lads_inv_adj.po_box,
          rcd_lads_inv_adj.country,
          rcd_lads_inv_adj.fax_number);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_adj;

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
      rcd_lads_inv_ref.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_ref.refseq := rcd_lads_inv_ref.refseq + 1;
      rcd_lads_inv_ref.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_ref.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_lads_inv_ref.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_inv_ref.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_inv_ref.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_inv_ref.belnr is null then
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

      insert into lads_inv_ref
         (belnr,
          refseq,
          qualf,
          refnr,
          posnr,
          datum,
          uzeit)
      values
         (rcd_lads_inv_ref.belnr,
          rcd_lads_inv_ref.refseq,
          rcd_lads_inv_ref.qualf,
          rcd_lads_inv_ref.refnr,
          rcd_lads_inv_ref.posnr,
          rcd_lads_inv_ref.datum,
          rcd_lads_inv_ref.uzeit);

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
      rcd_lads_inv_dat.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_dat.datseq := rcd_lads_inv_dat.datseq + 1;
      rcd_lads_inv_dat.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_lads_inv_dat.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_inv_dat.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_inv_dat.belnr is null then
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

      insert into lads_inv_dat
         (belnr,
          datseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_lads_inv_dat.belnr,
          rcd_lads_inv_dat.datseq,
          rcd_lads_inv_dat.iddat,
          rcd_lads_inv_dat.datum,
          rcd_lads_inv_dat.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

   /**************************************************/
   /* This procedure performs the record DCN routine */
   /**************************************************/
   procedure process_record_dcn(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DCN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_dcn.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_dcn.dcnseq := rcd_lads_inv_dcn.dcnseq + 1;
      rcd_lads_inv_dcn.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_lads_inv_dcn.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_inv_dcn.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_lads_inv_dcn.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_inv_dcn.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_lads_inv_dcn.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_lads_inv_dcn.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_lads_inv_dcn.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_lads_inv_dcn.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_lads_inv_dcn.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_inv_dcn.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_inv_dcn.koein := lics_inbound_utility.get_variable('KOEIN');

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
      if rcd_lads_inv_dcn.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DCN.BELNR');
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

      insert into lads_inv_dcn
         (belnr,
          dcnseq,
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
         (rcd_lads_inv_dcn.belnr,
          rcd_lads_inv_dcn.dcnseq,
          rcd_lads_inv_dcn.alckz,
          rcd_lads_inv_dcn.kschl,
          rcd_lads_inv_dcn.kotxt,
          rcd_lads_inv_dcn.betrg,
          rcd_lads_inv_dcn.kperc,
          rcd_lads_inv_dcn.krate,
          rcd_lads_inv_dcn.uprbs,
          rcd_lads_inv_dcn.meaun,
          rcd_lads_inv_dcn.kobtr,
          rcd_lads_inv_dcn.mwskz,
          rcd_lads_inv_dcn.msatz,
          rcd_lads_inv_dcn.koein);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dcn;

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
      rcd_lads_inv_tax.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_tax.taxseq := rcd_lads_inv_tax.taxseq + 1;
      rcd_lads_inv_tax.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_inv_tax.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_inv_tax.mwsbt := lics_inbound_utility.get_variable('MWSBT');
      rcd_lads_inv_tax.txjcd := lics_inbound_utility.get_variable('TXJCD');
      rcd_lads_inv_tax.ktext := lics_inbound_utility.get_variable('KTEXT');
      rcd_lads_inv_tax.zntvat := lics_inbound_utility.get_variable('ZNTVAT');
      rcd_lads_inv_tax.zgramount := lics_inbound_utility.get_number('ZGRAMOUNT',null);
      rcd_lads_inv_tax.vatdesc := lics_inbound_utility.get_variable('VATDESC');

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
      if rcd_lads_inv_tax.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TAX.BELNR');
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

      insert into lads_inv_tax
         (belnr,
          taxseq,
          mwskz,
          msatz,
          mwsbt,
          txjcd,
          ktext,
          zntvat,
          zgramount,
          vatdesc)
      values
         (rcd_lads_inv_tax.belnr,
          rcd_lads_inv_tax.taxseq,
          rcd_lads_inv_tax.mwskz,
          rcd_lads_inv_tax.msatz,
          rcd_lads_inv_tax.mwsbt,
          rcd_lads_inv_tax.txjcd,
          rcd_lads_inv_tax.ktext,
          rcd_lads_inv_tax.zntvat,
          rcd_lads_inv_tax.zgramount,
          rcd_lads_inv_tax.vatdesc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tax;

   /**************************************************/
   /* This procedure performs the record TOD routine */
   /**************************************************/
   procedure process_record_tod(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TOD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_tod.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_tod.todseq := rcd_lads_inv_tod.todseq + 1;
      rcd_lads_inv_tod.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_tod.lkond := lics_inbound_utility.get_variable('LKOND');
      rcd_lads_inv_tod.lktext := lics_inbound_utility.get_variable('LKTEXT');

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
      if rcd_lads_inv_tod.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TOD.BELNR');
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

      insert into lads_inv_tod
         (belnr,
          todseq,
          qualf,
          lkond,
          lktext)
      values
         (rcd_lads_inv_tod.belnr,
          rcd_lads_inv_tod.todseq,
          rcd_lads_inv_tod.qualf,
          rcd_lads_inv_tod.lkond,
          rcd_lads_inv_tod.lktext);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tod;

   /**************************************************/
   /* This procedure performs the record TOP routine */
   /**************************************************/
   procedure process_record_top(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TOP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_top.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_top.topseq := rcd_lads_inv_top.topseq + 1;
      rcd_lads_inv_top.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_top.tage := lics_inbound_utility.get_variable('TAGE');
      rcd_lads_inv_top.prznt := lics_inbound_utility.get_variable('PRZNT');
      rcd_lads_inv_top.zterm_txt := lics_inbound_utility.get_variable('ZTERM_TXT');

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
      if rcd_lads_inv_top.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TOP.BELNR');
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

      insert into lads_inv_top
         (belnr,
          topseq,
          qualf,
          tage,
          prznt,
          zterm_txt)
      values
         (rcd_lads_inv_top.belnr,
          rcd_lads_inv_top.topseq,
          rcd_lads_inv_top.qualf,
          rcd_lads_inv_top.tage,
          rcd_lads_inv_top.prznt,
          rcd_lads_inv_top.zterm_txt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_top;

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
      rcd_lads_inv_cur.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_cur.curseq := rcd_lads_inv_cur.curseq + 1;
      rcd_lads_inv_cur.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_cur.waerz := lics_inbound_utility.get_variable('WAERZ');
      rcd_lads_inv_cur.waerq := lics_inbound_utility.get_variable('WAERQ');
      rcd_lads_inv_cur.kurs := lics_inbound_utility.get_variable('KURS');
      rcd_lads_inv_cur.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_inv_cur.zeit := lics_inbound_utility.get_variable('ZEIT');
      rcd_lads_inv_cur.kurs_m := lics_inbound_utility.get_variable('KURS_M');

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
      if rcd_lads_inv_cur.belnr is null then
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

      insert into lads_inv_cur
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
         (rcd_lads_inv_cur.belnr,
          rcd_lads_inv_cur.curseq,
          rcd_lads_inv_cur.qualf,
          rcd_lads_inv_cur.waerz,
          rcd_lads_inv_cur.waerq,
          rcd_lads_inv_cur.kurs,
          rcd_lads_inv_cur.datum,
          rcd_lads_inv_cur.zeit,
          rcd_lads_inv_cur.kurs_m);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_cur;

   /**************************************************/
   /* This procedure performs the record BNK routine */
   /**************************************************/
   procedure process_record_bnk(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('BNK', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_bnk.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_bnk.bnkseq := rcd_lads_inv_bnk.bnkseq + 1;
      rcd_lads_inv_bnk.bcoun := lics_inbound_utility.get_variable('BCOUN');
      rcd_lads_inv_bnk.brnum := lics_inbound_utility.get_variable('BRNUM');
      rcd_lads_inv_bnk.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_inv_bnk.baloc := lics_inbound_utility.get_variable('BALOC');
      rcd_lads_inv_bnk.acnum := lics_inbound_utility.get_variable('ACNUM');
      rcd_lads_inv_bnk.acnam := lics_inbound_utility.get_variable('ACNAM');

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
      if rcd_lads_inv_bnk.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - BNK.BELNR');
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

      insert into lads_inv_bnk
         (belnr,
          bnkseq,
          bcoun,
          brnum,
          bname,
          baloc,
          acnum,
          acnam)
      values
         (rcd_lads_inv_bnk.belnr,
          rcd_lads_inv_bnk.bnkseq,
          rcd_lads_inv_bnk.bcoun,
          rcd_lads_inv_bnk.brnum,
          rcd_lads_inv_bnk.bname,
          rcd_lads_inv_bnk.baloc,
          rcd_lads_inv_bnk.acnum,
          rcd_lads_inv_bnk.acnam);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_bnk;

   /**************************************************/
   /* This procedure performs the record FTD routine */
   /**************************************************/
   procedure process_record_ftd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('FTD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_ftd.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_ftd.ftdseq := rcd_lads_inv_ftd.ftdseq + 1;
      rcd_lads_inv_ftd.exnum := lics_inbound_utility.get_variable('EXNUM');
      rcd_lads_inv_ftd.aland := lics_inbound_utility.get_variable('ALAND');
      rcd_lads_inv_ftd.expvz := lics_inbound_utility.get_variable('EXPVZ');
      rcd_lads_inv_ftd.zolla := lics_inbound_utility.get_variable('ZOLLA');
      rcd_lads_inv_ftd.zollb := lics_inbound_utility.get_variable('ZOLLB');
      rcd_lads_inv_ftd.zoll1 := lics_inbound_utility.get_variable('ZOLL1');
      rcd_lads_inv_ftd.zoll2 := lics_inbound_utility.get_variable('ZOLL2');
      rcd_lads_inv_ftd.zoll3 := lics_inbound_utility.get_variable('ZOLL3');
      rcd_lads_inv_ftd.zoll4 := lics_inbound_utility.get_variable('ZOLL4');
      rcd_lads_inv_ftd.zoll5 := lics_inbound_utility.get_variable('ZOLL5');
      rcd_lads_inv_ftd.zoll6 := lics_inbound_utility.get_variable('ZOLL6');
      rcd_lads_inv_ftd.kzgbe := lics_inbound_utility.get_variable('KZGBE');
      rcd_lads_inv_ftd.kzabe := lics_inbound_utility.get_variable('KZABE');
      rcd_lads_inv_ftd.stgbe := lics_inbound_utility.get_variable('STGBE');
      rcd_lads_inv_ftd.stabe := lics_inbound_utility.get_variable('STABE');
      rcd_lads_inv_ftd.conta := lics_inbound_utility.get_variable('CONTA');
      rcd_lads_inv_ftd.grwcu := lics_inbound_utility.get_variable('GRWCU');
      rcd_lads_inv_ftd.grwrt := lics_inbound_utility.get_variable('GRWRT');
      rcd_lads_inv_ftd.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_inv_ftd.landx := lics_inbound_utility.get_variable('LANDX');
      rcd_lads_inv_ftd.landa := lics_inbound_utility.get_variable('LANDA');
      rcd_lads_inv_ftd.xegld := lics_inbound_utility.get_variable('XEGLD');
      rcd_lads_inv_ftd.freih := lics_inbound_utility.get_variable('FREIH');
      rcd_lads_inv_ftd.ewrco := lics_inbound_utility.get_variable('EWRCO');
      rcd_lads_inv_ftd.usc05 := lics_inbound_utility.get_variable('USC05');
      rcd_lads_inv_ftd.jap05 := lics_inbound_utility.get_variable('JAP05');
      rcd_lads_inv_ftd.alanx := lics_inbound_utility.get_variable('ALANX');
      rcd_lads_inv_ftd.alana := lics_inbound_utility.get_variable('ALANA');
      rcd_lads_inv_ftd.lasta := lics_inbound_utility.get_variable('LASTA');
      rcd_lads_inv_ftd.lastg := lics_inbound_utility.get_variable('LASTG');
      rcd_lads_inv_ftd.alsch := lics_inbound_utility.get_variable('ALSCH');
      rcd_lads_inv_ftd.alsre := lics_inbound_utility.get_variable('ALSRE');
      rcd_lads_inv_ftd.ladeo := lics_inbound_utility.get_variable('LADEO');
      rcd_lads_inv_ftd.iever := lics_inbound_utility.get_variable('IEVER');
      rcd_lads_inv_ftd.banr01 := lics_inbound_utility.get_variable('BANR01');
      rcd_lads_inv_ftd.banr02 := lics_inbound_utility.get_variable('BANR02');
      rcd_lads_inv_ftd.banr03 := lics_inbound_utility.get_variable('BANR03');
      rcd_lads_inv_ftd.banr04 := lics_inbound_utility.get_variable('BANR04');
      rcd_lads_inv_ftd.banr05 := lics_inbound_utility.get_variable('BANR05');
      rcd_lads_inv_ftd.banr06 := lics_inbound_utility.get_variable('BANR06');
      rcd_lads_inv_ftd.banr07 := lics_inbound_utility.get_variable('BANR07');
      rcd_lads_inv_ftd.banr08 := lics_inbound_utility.get_variable('BANR08');
      rcd_lads_inv_ftd.banr09 := lics_inbound_utility.get_variable('BANR09');
      rcd_lads_inv_ftd.banr10 := lics_inbound_utility.get_variable('BANR10');
      rcd_lads_inv_ftd.wzocu := lics_inbound_utility.get_variable('WZOCU');
      rcd_lads_inv_ftd.expvztx := lics_inbound_utility.get_variable('EXPVZTX');
      rcd_lads_inv_ftd.zollatx := lics_inbound_utility.get_variable('ZOLLATX');
      rcd_lads_inv_ftd.zollbtx := lics_inbound_utility.get_variable('ZOLLBTX');
      rcd_lads_inv_ftd.stgbetx := lics_inbound_utility.get_variable('STGBETX');
      rcd_lads_inv_ftd.stabetx := lics_inbound_utility.get_variable('STABETX');
      rcd_lads_inv_ftd.freihtx := lics_inbound_utility.get_variable('FREIHTX');
      rcd_lads_inv_ftd.ladel := lics_inbound_utility.get_variable('LADEL');
      rcd_lads_inv_ftd.text1 := lics_inbound_utility.get_variable('TEXT1');
      rcd_lads_inv_ftd.text2 := lics_inbound_utility.get_variable('TEXT2');
      rcd_lads_inv_ftd.text3 := lics_inbound_utility.get_variable('TEXT3');
      rcd_lads_inv_ftd.gbnum := lics_inbound_utility.get_variable('GBNUM');
      rcd_lads_inv_ftd.regnr := lics_inbound_utility.get_variable('REGNR');
      rcd_lads_inv_ftd.ausfu := lics_inbound_utility.get_variable('AUSFU');
      rcd_lads_inv_ftd.iever_tx := lics_inbound_utility.get_variable('IEVER_TX');
      rcd_lads_inv_ftd.lazl1 := lics_inbound_utility.get_variable('LAZL1');
      rcd_lads_inv_ftd.lazl2 := lics_inbound_utility.get_variable('LAZL2');
      rcd_lads_inv_ftd.lazl3 := lics_inbound_utility.get_variable('LAZL3');
      rcd_lads_inv_ftd.lazl4 := lics_inbound_utility.get_variable('LAZL4');
      rcd_lads_inv_ftd.lazl5 := lics_inbound_utility.get_variable('LAZL5');
      rcd_lads_inv_ftd.lazl6 := lics_inbound_utility.get_variable('LAZL6');
      rcd_lads_inv_ftd.azoll := lics_inbound_utility.get_variable('AZOLL');
      rcd_lads_inv_ftd.azolltx := lics_inbound_utility.get_variable('AZOLLTX');
      rcd_lads_inv_ftd.bfmar := lics_inbound_utility.get_variable('BFMAR');
      rcd_lads_inv_ftd.ftvbd := lics_inbound_utility.get_variable('FTVBD');
      rcd_lads_inv_ftd.cudcl := lics_inbound_utility.get_variable('CUDCL');
      rcd_lads_inv_ftd.ftupd := lics_inbound_utility.get_variable('FTUPD');

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
      if rcd_lads_inv_ftd.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - FTD.BELNR');
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

      insert into lads_inv_ftd
         (belnr,
          ftdseq,
          exnum,
          aland,
          expvz,
          zolla,
          zollb,
          zoll1,
          zoll2,
          zoll3,
          zoll4,
          zoll5,
          zoll6,
          kzgbe,
          kzabe,
          stgbe,
          stabe,
          conta,
          grwcu,
          grwrt,
          land1,
          landx,
          landa,
          xegld,
          freih,
          ewrco,
          usc05,
          jap05,
          alanx,
          alana,
          lasta,
          lastg,
          alsch,
          alsre,
          ladeo,
          iever,
          banr01,
          banr02,
          banr03,
          banr04,
          banr05,
          banr06,
          banr07,
          banr08,
          banr09,
          banr10,
          wzocu,
          expvztx,
          zollatx,
          zollbtx,
          stgbetx,
          stabetx,
          freihtx,
          ladel,
          text1,
          text2,
          text3,
          gbnum,
          regnr,
          ausfu,
          iever_tx,
          lazl1,
          lazl2,
          lazl3,
          lazl4,
          lazl5,
          lazl6,
          azoll,
          azolltx,
          bfmar,
          ftvbd,
          cudcl,
          ftupd)
      values
         (rcd_lads_inv_ftd.belnr,
          rcd_lads_inv_ftd.ftdseq,
          rcd_lads_inv_ftd.exnum,
          rcd_lads_inv_ftd.aland,
          rcd_lads_inv_ftd.expvz,
          rcd_lads_inv_ftd.zolla,
          rcd_lads_inv_ftd.zollb,
          rcd_lads_inv_ftd.zoll1,
          rcd_lads_inv_ftd.zoll2,
          rcd_lads_inv_ftd.zoll3,
          rcd_lads_inv_ftd.zoll4,
          rcd_lads_inv_ftd.zoll5,
          rcd_lads_inv_ftd.zoll6,
          rcd_lads_inv_ftd.kzgbe,
          rcd_lads_inv_ftd.kzabe,
          rcd_lads_inv_ftd.stgbe,
          rcd_lads_inv_ftd.stabe,
          rcd_lads_inv_ftd.conta,
          rcd_lads_inv_ftd.grwcu,
          rcd_lads_inv_ftd.grwrt,
          rcd_lads_inv_ftd.land1,
          rcd_lads_inv_ftd.landx,
          rcd_lads_inv_ftd.landa,
          rcd_lads_inv_ftd.xegld,
          rcd_lads_inv_ftd.freih,
          rcd_lads_inv_ftd.ewrco,
          rcd_lads_inv_ftd.usc05,
          rcd_lads_inv_ftd.jap05,
          rcd_lads_inv_ftd.alanx,
          rcd_lads_inv_ftd.alana,
          rcd_lads_inv_ftd.lasta,
          rcd_lads_inv_ftd.lastg,
          rcd_lads_inv_ftd.alsch,
          rcd_lads_inv_ftd.alsre,
          rcd_lads_inv_ftd.ladeo,
          rcd_lads_inv_ftd.iever,
          rcd_lads_inv_ftd.banr01,
          rcd_lads_inv_ftd.banr02,
          rcd_lads_inv_ftd.banr03,
          rcd_lads_inv_ftd.banr04,
          rcd_lads_inv_ftd.banr05,
          rcd_lads_inv_ftd.banr06,
          rcd_lads_inv_ftd.banr07,
          rcd_lads_inv_ftd.banr08,
          rcd_lads_inv_ftd.banr09,
          rcd_lads_inv_ftd.banr10,
          rcd_lads_inv_ftd.wzocu,
          rcd_lads_inv_ftd.expvztx,
          rcd_lads_inv_ftd.zollatx,
          rcd_lads_inv_ftd.zollbtx,
          rcd_lads_inv_ftd.stgbetx,
          rcd_lads_inv_ftd.stabetx,
          rcd_lads_inv_ftd.freihtx,
          rcd_lads_inv_ftd.ladel,
          rcd_lads_inv_ftd.text1,
          rcd_lads_inv_ftd.text2,
          rcd_lads_inv_ftd.text3,
          rcd_lads_inv_ftd.gbnum,
          rcd_lads_inv_ftd.regnr,
          rcd_lads_inv_ftd.ausfu,
          rcd_lads_inv_ftd.iever_tx,
          rcd_lads_inv_ftd.lazl1,
          rcd_lads_inv_ftd.lazl2,
          rcd_lads_inv_ftd.lazl3,
          rcd_lads_inv_ftd.lazl4,
          rcd_lads_inv_ftd.lazl5,
          rcd_lads_inv_ftd.lazl6,
          rcd_lads_inv_ftd.azoll,
          rcd_lads_inv_ftd.azolltx,
          rcd_lads_inv_ftd.bfmar,
          rcd_lads_inv_ftd.ftvbd,
          rcd_lads_inv_ftd.cudcl,
          rcd_lads_inv_ftd.ftupd);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ftd;

   /**************************************************/
   /* This procedure performs the record TXT routine */
   /**************************************************/
   procedure process_record_txt(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TXT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_txt.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_txt.txtseq := rcd_lads_inv_txt.txtseq + 1;
      rcd_lads_inv_txt.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_inv_txt.tsspras := lics_inbound_utility.get_variable('TSSPRAS');
      rcd_lads_inv_txt.tsspras_iso := lics_inbound_utility.get_variable('TSSPRAS_ISO');
      rcd_lads_inv_txt.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_inv_txt.tdobname := lics_inbound_utility.get_variable('TDOBNAME');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_txi.txiseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_txt.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXT.BELNR');
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

      insert into lads_inv_txt
         (belnr,
          txtseq,
          tdid,
          tsspras,
          tsspras_iso,
          tdobject,
          tdobname)
      values
         (rcd_lads_inv_txt.belnr,
          rcd_lads_inv_txt.txtseq,
          rcd_lads_inv_txt.tdid,
          rcd_lads_inv_txt.tsspras,
          rcd_lads_inv_txt.tsspras_iso,
          rcd_lads_inv_txt.tdobject,
          rcd_lads_inv_txt.tdobname);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_txt;

   /**************************************************/
   /* This procedure performs the record TXI routine */
   /**************************************************/
   procedure process_record_txi(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TXI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_txi.belnr := rcd_lads_inv_txt.belnr;
      rcd_lads_inv_txi.txtseq := rcd_lads_inv_txt.txtseq;
      rcd_lads_inv_txi.txiseq := rcd_lads_inv_txi.txiseq + 1;
      rcd_lads_inv_txi.tdline := lics_inbound_utility.get_variable('TDLINE');
      rcd_lads_inv_txi.tdformat := lics_inbound_utility.get_variable('TDFORMAT');

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
      if rcd_lads_inv_txi.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXI.BELNR');
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

      insert into lads_inv_txi
         (belnr,
          txtseq,
          txiseq,
          tdline,
          tdformat)
      values
         (rcd_lads_inv_txi.belnr,
          rcd_lads_inv_txi.txtseq,
          rcd_lads_inv_txi.txiseq,
          rcd_lads_inv_txi.tdline,
          rcd_lads_inv_txi.tdformat);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_txi;

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
      rcd_lads_inv_org.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_org.orgseq := rcd_lads_inv_org.orgseq + 1;
      rcd_lads_inv_org.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_org.orgid := lics_inbound_utility.get_variable('ORGID');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_sal.salseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_org.belnr is null then
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

      insert into lads_inv_org
         (belnr,
          orgseq,
          qualf,
          orgid)
      values
         (rcd_lads_inv_org.belnr,
          rcd_lads_inv_org.orgseq,
          rcd_lads_inv_org.qualf,
          rcd_lads_inv_org.orgid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_org;

   /**************************************************/
   /* This procedure performs the record SAL routine */
   /**************************************************/
   procedure process_record_sal(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SAL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_sal.belnr := rcd_lads_inv_org.belnr;
      rcd_lads_inv_sal.orgseq := rcd_lads_inv_org.orgseq;
      rcd_lads_inv_sal.salseq := rcd_lads_inv_sal.salseq + 1;
      rcd_lads_inv_sal.vkgrp := lics_inbound_utility.get_variable('VKGRP');
      rcd_lads_inv_sal.bezei := lics_inbound_utility.get_variable('BEZEI');
      rcd_lads_inv_sal.cscfn := lics_inbound_utility.get_variable('CSCFN');
      rcd_lads_inv_sal.cscln := lics_inbound_utility.get_variable('CSCLN');
      rcd_lads_inv_sal.csctel := lics_inbound_utility.get_variable('CSCTEL');
      rcd_lads_inv_sal.addl1 := lics_inbound_utility.get_variable('ADDL1');
      rcd_lads_inv_sal.addl2 := lics_inbound_utility.get_variable('ADDL2');
      rcd_lads_inv_sal.addl3 := lics_inbound_utility.get_variable('ADDL3');

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
      if rcd_lads_inv_sal.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - SAL.BELNR');
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

      insert into lads_inv_sal
         (belnr,
          orgseq,
          salseq,
          vkgrp,
          bezei,
          cscfn,
          cscln,
          csctel,
          addl1,
          addl2,
          addl3)
      values
         (rcd_lads_inv_sal.belnr,
          rcd_lads_inv_sal.orgseq,
          rcd_lads_inv_sal.salseq,
          rcd_lads_inv_sal.vkgrp,
          rcd_lads_inv_sal.bezei,
          rcd_lads_inv_sal.cscfn,
          rcd_lads_inv_sal.cscln,
          rcd_lads_inv_sal.csctel,
          rcd_lads_inv_sal.addl1,
          rcd_lads_inv_sal.addl2,
          rcd_lads_inv_sal.addl3);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_sal;

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
      rcd_lads_inv_gen.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_gen.genseq := rcd_lads_inv_gen.genseq + 1;
      rcd_lads_inv_gen.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_lads_inv_gen.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_inv_gen.pstyp := lics_inbound_utility.get_variable('PSTYP');
      rcd_lads_inv_gen.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_inv_gen.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_inv_gen.menee := lics_inbound_utility.get_variable('MENEE');
      rcd_lads_inv_gen.bmng2 := lics_inbound_utility.get_variable('BMNG2');
      rcd_lads_inv_gen.pmene := lics_inbound_utility.get_variable('PMENE');
      rcd_lads_inv_gen.abftz := lics_inbound_utility.get_variable('ABFTZ');
      rcd_lads_inv_gen.vprei := lics_inbound_utility.get_variable('VPREI');
      rcd_lads_inv_gen.peinh := lics_inbound_utility.get_variable('PEINH');
      rcd_lads_inv_gen.netwr := lics_inbound_utility.get_variable('NETWR');
      rcd_lads_inv_gen.anetw := lics_inbound_utility.get_variable('ANETW');
      rcd_lads_inv_gen.skfbp := lics_inbound_utility.get_variable('SKFBP');
      rcd_lads_inv_gen.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_inv_gen.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_inv_gen.einkz := lics_inbound_utility.get_variable('EINKZ');
      rcd_lads_inv_gen.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_inv_gen.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_inv_gen.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_inv_gen.uepos := lics_inbound_utility.get_variable('UEPOS');
      rcd_lads_inv_gen.grkor := lics_inbound_utility.get_variable('GRKOR');
      rcd_lads_inv_gen.evers := lics_inbound_utility.get_variable('EVERS');
      rcd_lads_inv_gen.bpumn := lics_inbound_utility.get_number('BPUMN',null);
      rcd_lads_inv_gen.bpumz := lics_inbound_utility.get_number('BPUMZ',null);
      rcd_lads_inv_gen.abgru := lics_inbound_utility.get_variable('ABGRU');
      rcd_lads_inv_gen.abgrt := lics_inbound_utility.get_variable('ABGRT');
      rcd_lads_inv_gen.antlf := lics_inbound_utility.get_variable('ANTLF');
      rcd_lads_inv_gen.fixmg := lics_inbound_utility.get_variable('FIXMG');
      rcd_lads_inv_gen.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_inv_gen.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_inv_gen.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_lads_inv_gen.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_inv_gen.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_inv_gen.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_inv_gen.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_inv_gen.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_lads_inv_gen.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_lads_inv_gen.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_inv_gen.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_inv_gen.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_inv_gen.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_inv_gen.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_inv_gen.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_inv_gen.valtg := lics_inbound_utility.get_number('VALTG',null);
      rcd_lads_inv_gen.hipos := lics_inbound_utility.get_number('HIPOS',null);
      rcd_lads_inv_gen.hievw := lics_inbound_utility.get_variable('HIEVW');
      rcd_lads_inv_gen.posguid := lics_inbound_utility.get_variable('POSGUID');
      rcd_lads_inv_gen.vkorg := null;
      rcd_lads_inv_gen.vtweg := null;
      rcd_lads_inv_gen.spart := null;
      rcd_lads_inv_gen.volum := null;
      rcd_lads_inv_gen.voleh := null;
      rcd_lads_inv_gen.pcb := null;
      rcd_lads_inv_gen.spcb := null;
      rcd_lads_inv_gen.zztarif := null;
      rcd_lads_inv_gen.fklmg := null;
      rcd_lads_inv_gen.meins := null;
      rcd_lads_inv_gen.zzistdu := null;
      rcd_lads_inv_gen.zzisrsu := null;
      rcd_lads_inv_gen.prod_spart := null;
      rcd_lads_inv_gen.pmatn_ean := null;
      rcd_lads_inv_gen.tdumatn_ean := null;
      rcd_lads_inv_gen.mtpos := null;
      rcd_lads_inv_gen.org_dlvnr := null;
      rcd_lads_inv_gen.org_dlvdt := null;
      rcd_lads_inv_gen.mat_legacy := null;
      rcd_lads_inv_gen.rsu_per_mcu := null;
      rcd_lads_inv_gen.mcu_per_tdu := null;
      rcd_lads_inv_gen.rsu_per_tdu := null;
      rcd_lads_inv_gen.number_of_rsu := null;
      rcd_lads_inv_gen.vsart := null;
      rcd_lads_inv_gen.knref := null;
      rcd_lads_inv_gen.zzaggno := null;
      rcd_lads_inv_gen.zzagtcd := null;
      rcd_lads_inv_gen.kwmeng := null;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_mat.matseq := 0;
      rcd_lads_inv_grd.grdseq := 0;
      rcd_lads_inv_irf.irfseq := 0;
      rcd_lads_inv_idt.idtseq := 0;
      rcd_lads_inv_iob.iobseq := 0;
      rcd_lads_inv_ias.iasseq := 0;
      rcd_lads_inv_ipn.ipnseq := 0;
      rcd_lads_inv_icn.icnseq := 0;
      rcd_lads_inv_ita.itaseq := 0;
      rcd_lads_inv_ift.iftseq := 0;
      rcd_lads_inv_icb.icbseq := 0;
      rcd_lads_inv_itx.itxseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_gen.belnr is null then
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
      rcd_lads_inv_gen.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_inv_gen.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_lads_inv_gen.spart := lics_inbound_utility.get_variable('SPART');
      rcd_lads_inv_gen.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_lads_inv_gen.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_lads_inv_gen.pcb := lics_inbound_utility.get_number('PCB',null);
      rcd_lads_inv_gen.spcb := lics_inbound_utility.get_number('SPCB',null);
      rcd_lads_inv_gen.zztarif := lics_inbound_utility.get_variable('ZZTARIF');
      rcd_lads_inv_gen.fklmg := lics_inbound_utility.get_variable('FKLMG');
      rcd_lads_inv_gen.meins := lics_inbound_utility.get_variable('MEINS');
      rcd_lads_inv_gen.zzistdu := lics_inbound_utility.get_variable('ZZISTDU');
      rcd_lads_inv_gen.zzisrsu := lics_inbound_utility.get_variable('ZZISRSU');
      rcd_lads_inv_gen.prod_spart := lics_inbound_utility.get_variable('PROD_SPART');
      rcd_lads_inv_gen.pmatn_ean := lics_inbound_utility.get_variable('PMATN_EAN');
      rcd_lads_inv_gen.tdumatn_ean := lics_inbound_utility.get_variable('TDUMATN_EAN');
      rcd_lads_inv_gen.mtpos := lics_inbound_utility.get_variable('MTPOS');
      rcd_lads_inv_gen.org_dlvnr := lics_inbound_utility.get_variable('ORG_DLVNR');
      rcd_lads_inv_gen.org_dlvdt := lics_inbound_utility.get_variable('ORG_DLVDT');
      rcd_lads_inv_gen.mat_legacy := lics_inbound_utility.get_variable('MAT_LEGACY');
      rcd_lads_inv_gen.rsu_per_mcu := lics_inbound_utility.get_variable('RSU_PER_MCU');
      rcd_lads_inv_gen.mcu_per_tdu := lics_inbound_utility.get_variable('MCU_PER_TDU');
      rcd_lads_inv_gen.rsu_per_tdu := lics_inbound_utility.get_variable('RSU_PER_TDU');
      rcd_lads_inv_gen.number_of_rsu := lics_inbound_utility.get_variable('NUMBER_OF_RSU');
      rcd_lads_inv_gen.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_inv_gen.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_inv_gen.zzaggno := lics_inbound_utility.get_variable('ZZAGGNO');
      rcd_lads_inv_gen.zzagtcd := lics_inbound_utility.get_variable('ZZAGTCD');
      rcd_lads_inv_gen.kwmeng := lics_inbound_utility.get_number('KWMENG',null);

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

      insert into lads_inv_gen
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
         (rcd_lads_inv_gen.belnr,
          rcd_lads_inv_gen.genseq,
          rcd_lads_inv_gen.posex,
          rcd_lads_inv_gen.action,
          rcd_lads_inv_gen.pstyp,
          rcd_lads_inv_gen.kzabs,
          rcd_lads_inv_gen.menge,
          rcd_lads_inv_gen.menee,
          rcd_lads_inv_gen.bmng2,
          rcd_lads_inv_gen.pmene,
          rcd_lads_inv_gen.abftz,
          rcd_lads_inv_gen.vprei,
          rcd_lads_inv_gen.peinh,
          rcd_lads_inv_gen.netwr,
          rcd_lads_inv_gen.anetw,
          rcd_lads_inv_gen.skfbp,
          rcd_lads_inv_gen.ntgew,
          rcd_lads_inv_gen.gewei,
          rcd_lads_inv_gen.einkz,
          rcd_lads_inv_gen.curcy,
          rcd_lads_inv_gen.preis,
          rcd_lads_inv_gen.matkl,
          rcd_lads_inv_gen.uepos,
          rcd_lads_inv_gen.grkor,
          rcd_lads_inv_gen.evers,
          rcd_lads_inv_gen.bpumn,
          rcd_lads_inv_gen.bpumz,
          rcd_lads_inv_gen.abgru,
          rcd_lads_inv_gen.abgrt,
          rcd_lads_inv_gen.antlf,
          rcd_lads_inv_gen.fixmg,
          rcd_lads_inv_gen.kzazu,
          rcd_lads_inv_gen.brgew,
          rcd_lads_inv_gen.pstyv,
          rcd_lads_inv_gen.empst,
          rcd_lads_inv_gen.abtnr,
          rcd_lads_inv_gen.abrvw,
          rcd_lads_inv_gen.werks,
          rcd_lads_inv_gen.lprio,
          rcd_lads_inv_gen.lprio_bez,
          rcd_lads_inv_gen.route,
          rcd_lads_inv_gen.route_bez,
          rcd_lads_inv_gen.lgort,
          rcd_lads_inv_gen.vstel,
          rcd_lads_inv_gen.delco,
          rcd_lads_inv_gen.matnr,
          rcd_lads_inv_gen.valtg,
          rcd_lads_inv_gen.hipos,
          rcd_lads_inv_gen.hievw,
          rcd_lads_inv_gen.posguid,
          rcd_lads_inv_gen.vkorg,
          rcd_lads_inv_gen.vtweg,
          rcd_lads_inv_gen.spart,
          rcd_lads_inv_gen.volum,
          rcd_lads_inv_gen.voleh,
          rcd_lads_inv_gen.pcb,
          rcd_lads_inv_gen.spcb,
          rcd_lads_inv_gen.zztarif,
          rcd_lads_inv_gen.fklmg,
          rcd_lads_inv_gen.meins,
          rcd_lads_inv_gen.zzistdu,
          rcd_lads_inv_gen.zzisrsu,
          rcd_lads_inv_gen.prod_spart,
          rcd_lads_inv_gen.pmatn_ean,
          rcd_lads_inv_gen.tdumatn_ean,
          rcd_lads_inv_gen.mtpos,
          rcd_lads_inv_gen.org_dlvnr,
          rcd_lads_inv_gen.org_dlvdt,
          rcd_lads_inv_gen.mat_legacy,
          rcd_lads_inv_gen.rsu_per_mcu,
          rcd_lads_inv_gen.mcu_per_tdu,
          rcd_lads_inv_gen.rsu_per_tdu,
          rcd_lads_inv_gen.number_of_rsu,
          rcd_lads_inv_gen.vsart,
          rcd_lads_inv_gen.knref,
          rcd_lads_inv_gen.zzaggno,
          rcd_lads_inv_gen.zzagtcd,
          rcd_lads_inv_gen.kwmeng);

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
      rcd_lads_inv_mat.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_mat.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_mat.matseq := rcd_lads_inv_mat.matseq + 1;
      rcd_lads_inv_mat.langu := lics_inbound_utility.get_variable('LANGU');
      rcd_lads_inv_mat.maktx := lics_inbound_utility.get_variable('MAKTX');

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
      if rcd_lads_inv_mat.belnr is null then
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

      insert into lads_inv_mat
         (belnr,
          genseq,
          matseq,
          langu,
          maktx)
      values
         (rcd_lads_inv_mat.belnr,
          rcd_lads_inv_mat.genseq,
          rcd_lads_inv_mat.matseq,
          rcd_lads_inv_mat.langu,
          rcd_lads_inv_mat.maktx);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mat;

   /**************************************************/
   /* This procedure performs the record GRD routine */
   /**************************************************/
   procedure process_record_grd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('GRD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_grd.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_grd.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_grd.grdseq := rcd_lads_inv_grd.grdseq + 1;
      rcd_lads_inv_grd.z_lcdid := lics_inbound_utility.get_variable('Z_LCDID');
      rcd_lads_inv_grd.z_lcdnr := lics_inbound_utility.get_variable('Z_LCDNR');
      rcd_lads_inv_grd.z_lcddsc := lics_inbound_utility.get_variable('Z_LCDDSC');

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
      if rcd_lads_inv_grd.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - GRD.BELNR');
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

      insert into lads_inv_grd
         (belnr,
          genseq,
          grdseq,
          z_lcdid,
          z_lcdnr,
          z_lcddsc)
      values
         (rcd_lads_inv_grd.belnr,
          rcd_lads_inv_grd.genseq,
          rcd_lads_inv_grd.grdseq,
          rcd_lads_inv_grd.z_lcdid,
          rcd_lads_inv_grd.z_lcdnr,
          rcd_lads_inv_grd.z_lcddsc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_grd;

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
      rcd_lads_inv_irf.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_irf.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_irf.irfseq := rcd_lads_inv_irf.irfseq + 1;
      rcd_lads_inv_irf.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_irf.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_lads_inv_irf.zeile := lics_inbound_utility.get_variable('ZEILE');
      rcd_lads_inv_irf.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_inv_irf.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_lads_inv_irf.bsark := lics_inbound_utility.get_variable('BSARK');
      rcd_lads_inv_irf.ihrez := lics_inbound_utility.get_variable('IHREZ');

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
      if rcd_lads_inv_irf.belnr is null then
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

      insert into lads_inv_irf
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
         (rcd_lads_inv_irf.belnr,
          rcd_lads_inv_irf.genseq,
          rcd_lads_inv_irf.irfseq,
          rcd_lads_inv_irf.qualf,
          rcd_lads_inv_irf.refnr,
          rcd_lads_inv_irf.zeile,
          rcd_lads_inv_irf.datum,
          rcd_lads_inv_irf.uzeit,
          rcd_lads_inv_irf.bsark,
          rcd_lads_inv_irf.ihrez);

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
      rcd_lads_inv_idt.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_idt.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_idt.idtseq := rcd_lads_inv_idt.idtseq + 1;
      rcd_lads_inv_idt.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_lads_inv_idt.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_inv_idt.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_inv_idt.belnr is null then
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

      insert into lads_inv_idt
         (belnr,
          genseq,
          idtseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_lads_inv_idt.belnr,
          rcd_lads_inv_idt.genseq,
          rcd_lads_inv_idt.idtseq,
          rcd_lads_inv_idt.iddat,
          rcd_lads_inv_idt.datum,
          rcd_lads_inv_idt.uzeit);

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
      rcd_lads_inv_iob.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_iob.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_iob.iobseq := rcd_lads_inv_iob.iobseq + 1;
      rcd_lads_inv_iob.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_iob.idtnr := lics_inbound_utility.get_variable('IDTNR');
      rcd_lads_inv_iob.ktext := lics_inbound_utility.get_variable('KTEXT');
      rcd_lads_inv_iob.mfrpn := lics_inbound_utility.get_variable('MFRPN');
      rcd_lads_inv_iob.mfrnr := lics_inbound_utility.get_variable('MFRNR');

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
      if rcd_lads_inv_iob.belnr is null then
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

      insert into lads_inv_iob
         (belnr,
          genseq,
          iobseq,
          qualf,
          idtnr,
          ktext,
          mfrpn,
          mfrnr)
      values
         (rcd_lads_inv_iob.belnr,
          rcd_lads_inv_iob.genseq,
          rcd_lads_inv_iob.iobseq,
          rcd_lads_inv_iob.qualf,
          rcd_lads_inv_iob.idtnr,
          rcd_lads_inv_iob.ktext,
          rcd_lads_inv_iob.mfrpn,
          rcd_lads_inv_iob.mfrnr);

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
      rcd_lads_inv_ias.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_ias.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_ias.iasseq := rcd_lads_inv_ias.iasseq + 1;
      rcd_lads_inv_ias.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_ias.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_inv_ias.krate := lics_inbound_utility.get_variable('KRATE');

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
      if rcd_lads_inv_ias.belnr is null then
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

      insert into lads_inv_ias
         (belnr,
          genseq,
          iasseq,
          qualf,
          betrg,
          krate)
      values
         (rcd_lads_inv_ias.belnr,
          rcd_lads_inv_ias.genseq,
          rcd_lads_inv_ias.iasseq,
          rcd_lads_inv_ias.qualf,
          rcd_lads_inv_ias.betrg,
          rcd_lads_inv_ias.krate);

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
      rcd_lads_inv_ipn.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_ipn.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_ipn.ipnseq := rcd_lads_inv_ipn.ipnseq + 1;
      rcd_lads_inv_ipn.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_inv_ipn.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_lads_inv_ipn.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_inv_ipn.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_inv_ipn.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_inv_ipn.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_inv_ipn.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_inv_ipn.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_inv_ipn.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_lads_inv_ipn.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_lads_inv_ipn.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_inv_ipn.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_lads_inv_ipn.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_lads_inv_ipn.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_lads_inv_ipn.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_inv_ipn.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_inv_ipn.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_lads_inv_ipn.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_lads_inv_ipn.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_inv_ipn.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_lads_inv_ipn.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_lads_inv_ipn.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_lads_inv_ipn.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_lads_inv_ipn.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_lads_inv_ipn.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_inv_ipn.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_inv_ipn.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_inv_ipn.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_lads_inv_ipn.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_lads_inv_ipn.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_lads_inv_ipn.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_lads_inv_ipn.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_lads_inv_ipn.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_lads_inv_ipn.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_lads_inv_ipn.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_inv_ipn.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_inv_ipn.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_lads_inv_ipn.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_lads_inv_ipn.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_lads_inv_ipn.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_inv_ipn.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_lads_inv_ipn.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_lads_inv_ipn.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_lads_inv_ipn.title := lics_inbound_utility.get_variable('TITLE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_iaj.iajseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_ipn.belnr is null then
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

      insert into lads_inv_ipn
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
         (rcd_lads_inv_ipn.belnr,
          rcd_lads_inv_ipn.genseq,
          rcd_lads_inv_ipn.ipnseq,
          rcd_lads_inv_ipn.parvw,
          rcd_lads_inv_ipn.partn,
          rcd_lads_inv_ipn.lifnr,
          rcd_lads_inv_ipn.name1,
          rcd_lads_inv_ipn.name2,
          rcd_lads_inv_ipn.name3,
          rcd_lads_inv_ipn.name4,
          rcd_lads_inv_ipn.stras,
          rcd_lads_inv_ipn.strs2,
          rcd_lads_inv_ipn.pfach,
          rcd_lads_inv_ipn.ort01,
          rcd_lads_inv_ipn.counc,
          rcd_lads_inv_ipn.pstlz,
          rcd_lads_inv_ipn.pstl2,
          rcd_lads_inv_ipn.land1,
          rcd_lads_inv_ipn.ablad,
          rcd_lads_inv_ipn.pernr,
          rcd_lads_inv_ipn.parnr,
          rcd_lads_inv_ipn.telf1,
          rcd_lads_inv_ipn.telf2,
          rcd_lads_inv_ipn.telbx,
          rcd_lads_inv_ipn.telfx,
          rcd_lads_inv_ipn.teltx,
          rcd_lads_inv_ipn.telx1,
          rcd_lads_inv_ipn.spras,
          rcd_lads_inv_ipn.anred,
          rcd_lads_inv_ipn.ort02,
          rcd_lads_inv_ipn.hausn,
          rcd_lads_inv_ipn.stock,
          rcd_lads_inv_ipn.regio,
          rcd_lads_inv_ipn.parge,
          rcd_lads_inv_ipn.isoal,
          rcd_lads_inv_ipn.isonu,
          rcd_lads_inv_ipn.fcode,
          rcd_lads_inv_ipn.ihrez,
          rcd_lads_inv_ipn.bname,
          rcd_lads_inv_ipn.paorg,
          rcd_lads_inv_ipn.orgtx,
          rcd_lads_inv_ipn.pagru,
          rcd_lads_inv_ipn.knref,
          rcd_lads_inv_ipn.ilnnr,
          rcd_lads_inv_ipn.pfort,
          rcd_lads_inv_ipn.spras_iso,
          rcd_lads_inv_ipn.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ipn;

   /**************************************************/
   /* This procedure performs the record IAJ routine */
   /**************************************************/
   procedure process_record_iaj(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IAJ', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_iaj.belnr := rcd_lads_inv_ipn.belnr;
      rcd_lads_inv_iaj.genseq := rcd_lads_inv_ipn.genseq;
      rcd_lads_inv_iaj.ipnseq := rcd_lads_inv_ipn.ipnseq;
      rcd_lads_inv_iaj.iajseq := rcd_lads_inv_iaj.iajseq + 1;
      rcd_lads_inv_iaj.langu := lics_inbound_utility.get_variable('LANGU');
      rcd_lads_inv_iaj.nation := lics_inbound_utility.get_variable('NATION');
      rcd_lads_inv_iaj.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_inv_iaj.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_inv_iaj.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_inv_iaj.street := lics_inbound_utility.get_variable('STREET');
      rcd_lads_inv_iaj.str_suppl1 := lics_inbound_utility.get_variable('STR_SUPPL1');
      rcd_lads_inv_iaj.str_suppl2 := lics_inbound_utility.get_variable('STR_SUPPL2');
      rcd_lads_inv_iaj.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_inv_iaj.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_inv_iaj.po_box := lics_inbound_utility.get_variable('PO_BOX');
      rcd_lads_inv_iaj.country := lics_inbound_utility.get_variable('COUNTRY');
      rcd_lads_inv_iaj.fax_number := lics_inbound_utility.get_variable('FAX_NUMBER');

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
      if rcd_lads_inv_iaj.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IAJ.BELNR');
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

      insert into lads_inv_iaj
         (belnr,
          genseq,
          ipnseq,
          iajseq,
          langu,
          nation,
          name1,
          name2,
          name3,
          street,
          str_suppl1,
          str_suppl2,
          city1,
          city2,
          po_box,
          country,
          fax_number)
      values
         (rcd_lads_inv_iaj.belnr,
          rcd_lads_inv_iaj.genseq,
          rcd_lads_inv_iaj.ipnseq,
          rcd_lads_inv_iaj.iajseq,
          rcd_lads_inv_iaj.langu,
          rcd_lads_inv_iaj.nation,
          rcd_lads_inv_iaj.name1,
          rcd_lads_inv_iaj.name2,
          rcd_lads_inv_iaj.name3,
          rcd_lads_inv_iaj.street,
          rcd_lads_inv_iaj.str_suppl1,
          rcd_lads_inv_iaj.str_suppl2,
          rcd_lads_inv_iaj.city1,
          rcd_lads_inv_iaj.city2,
          rcd_lads_inv_iaj.po_box,
          rcd_lads_inv_iaj.country,
          rcd_lads_inv_iaj.fax_number);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_iaj;

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
      rcd_lads_inv_icn.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_icn.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_icn.icnseq := rcd_lads_inv_icn.icnseq + 1;
      rcd_lads_inv_icn.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_lads_inv_icn.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_inv_icn.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_lads_inv_icn.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_inv_icn.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_lads_inv_icn.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_lads_inv_icn.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_lads_inv_icn.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_lads_inv_icn.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_lads_inv_icn.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_inv_icn.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_inv_icn.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_inv_icn.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_inv_icn.koein := lics_inbound_utility.get_variable('KOEIN');
      rcd_lads_inv_icn.curtp := lics_inbound_utility.get_variable('CURTP');
      rcd_lads_inv_icn.kobas := lics_inbound_utility.get_variable('KOBAS');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_icp.icpseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_icn.belnr is null then
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

      insert into lads_inv_icn
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
         (rcd_lads_inv_icn.belnr,
          rcd_lads_inv_icn.genseq,
          rcd_lads_inv_icn.icnseq,
          rcd_lads_inv_icn.alckz,
          rcd_lads_inv_icn.kschl,
          rcd_lads_inv_icn.kotxt,
          rcd_lads_inv_icn.betrg,
          rcd_lads_inv_icn.kperc,
          rcd_lads_inv_icn.krate,
          rcd_lads_inv_icn.uprbs,
          rcd_lads_inv_icn.meaun,
          rcd_lads_inv_icn.kobtr,
          rcd_lads_inv_icn.menge,
          rcd_lads_inv_icn.preis,
          rcd_lads_inv_icn.mwskz,
          rcd_lads_inv_icn.msatz,
          rcd_lads_inv_icn.koein,
          rcd_lads_inv_icn.curtp,
          rcd_lads_inv_icn.kobas);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_icn;

   /**************************************************/
   /* This procedure performs the record ICP routine */
   /**************************************************/
   procedure process_record_icp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ICP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_icp.belnr := rcd_lads_inv_icn.belnr;
      rcd_lads_inv_icp.genseq := rcd_lads_inv_icn.genseq;
      rcd_lads_inv_icp.icnseq := rcd_lads_inv_icn.icnseq;
      rcd_lads_inv_icp.icpseq := rcd_lads_inv_icp.icpseq + 1;
      rcd_lads_inv_icp.kosrt := lics_inbound_utility.get_variable('KOSRT');

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
      if rcd_lads_inv_icp.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ICP.BELNR');
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

      insert into lads_inv_icp
         (belnr,
          genseq,
          icnseq,
          icpseq,
          kosrt)
      values
         (rcd_lads_inv_icp.belnr,
          rcd_lads_inv_icp.genseq,
          rcd_lads_inv_icp.icnseq,
          rcd_lads_inv_icp.icpseq,
          rcd_lads_inv_icp.kosrt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_icp;

   /**************************************************/
   /* This procedure performs the record ITA routine */
   /**************************************************/
   procedure process_record_ita(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ITA', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_ita.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_ita.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_ita.itaseq := rcd_lads_inv_ita.itaseq + 1;
      rcd_lads_inv_ita.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_inv_ita.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_inv_ita.mwsbt := lics_inbound_utility.get_variable('MWSBT');
      rcd_lads_inv_ita.txjcd := lics_inbound_utility.get_variable('TXJCD');
      rcd_lads_inv_ita.ktext := lics_inbound_utility.get_variable('KTEXT');
      rcd_lads_inv_ita.ltx01 := lics_inbound_utility.get_variable('LTX01');
      rcd_lads_inv_ita.ltx02 := lics_inbound_utility.get_variable('LTX02');
      rcd_lads_inv_ita.ltx03 := lics_inbound_utility.get_variable('LTX03');
      rcd_lads_inv_ita.ltx04 := lics_inbound_utility.get_variable('LTX04');

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
      if rcd_lads_inv_ita.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ITA.BELNR');
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

      insert into lads_inv_ita
         (belnr,
          genseq,
          itaseq,
          mwskz,
          msatz,
          mwsbt,
          txjcd,
          ktext,
          ltx01,
          ltx02,
          ltx03,
          ltx04)
      values
         (rcd_lads_inv_ita.belnr,
          rcd_lads_inv_ita.genseq,
          rcd_lads_inv_ita.itaseq,
          rcd_lads_inv_ita.mwskz,
          rcd_lads_inv_ita.msatz,
          rcd_lads_inv_ita.mwsbt,
          rcd_lads_inv_ita.txjcd,
          rcd_lads_inv_ita.ktext,
          rcd_lads_inv_ita.ltx01,
          rcd_lads_inv_ita.ltx02,
          rcd_lads_inv_ita.ltx03,
          rcd_lads_inv_ita.ltx04);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ita;

   /**************************************************/
   /* This procedure performs the record IFT routine */
   /**************************************************/
   procedure process_record_ift(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IFT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_ift.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_ift.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_ift.iftseq := rcd_lads_inv_ift.iftseq + 1;
      rcd_lads_inv_ift.exnum := lics_inbound_utility.get_variable('EXNUM');
      rcd_lads_inv_ift.expos := lics_inbound_utility.get_number('EXPOS',null);
      rcd_lads_inv_ift.stawn := lics_inbound_utility.get_variable('STAWN');
      rcd_lads_inv_ift.exprf := lics_inbound_utility.get_variable('EXPRF');
      rcd_lads_inv_ift.exart := lics_inbound_utility.get_variable('EXART');
      rcd_lads_inv_ift.herkl := lics_inbound_utility.get_variable('HERKL');
      rcd_lads_inv_ift.herkr := lics_inbound_utility.get_variable('HERKR');
      rcd_lads_inv_ift.herta := lics_inbound_utility.get_variable('HERTA');
      rcd_lads_inv_ift.herti := lics_inbound_utility.get_variable('HERTI');
      rcd_lads_inv_ift.stxt1 := lics_inbound_utility.get_variable('STXT1');
      rcd_lads_inv_ift.stxt2 := lics_inbound_utility.get_variable('STXT2');
      rcd_lads_inv_ift.stxt3 := lics_inbound_utility.get_variable('STXT3');
      rcd_lads_inv_ift.stxt4 := lics_inbound_utility.get_variable('STXT4');
      rcd_lads_inv_ift.stxt5 := lics_inbound_utility.get_variable('STXT5');
      rcd_lads_inv_ift.stxt6 := lics_inbound_utility.get_variable('STXT6');
      rcd_lads_inv_ift.stxt7 := lics_inbound_utility.get_variable('STXT7');
      rcd_lads_inv_ift.bemas := lics_inbound_utility.get_variable('BEMAS');
      rcd_lads_inv_ift.prefe := lics_inbound_utility.get_variable('PREFE');
      rcd_lads_inv_ift.bolnr := lics_inbound_utility.get_variable('BOLNR');
      rcd_lads_inv_ift.traty := lics_inbound_utility.get_variable('TRATY');
      rcd_lads_inv_ift.traid := lics_inbound_utility.get_variable('TRAID');
      rcd_lads_inv_ift.brulo := lics_inbound_utility.get_variable('BRULO');
      rcd_lads_inv_ift.netlo := lics_inbound_utility.get_variable('NETLO');
      rcd_lads_inv_ift.vemeh := lics_inbound_utility.get_variable('VEMEH');
      rcd_lads_inv_ift.herbl := lics_inbound_utility.get_variable('HERBL');
      rcd_lads_inv_ift.bmgew := lics_inbound_utility.get_variable('BMGEW');
      rcd_lads_inv_ift.text1 := lics_inbound_utility.get_variable('TEXT1');
      rcd_lads_inv_ift.text2 := lics_inbound_utility.get_variable('TEXT2');
      rcd_lads_inv_ift.text3 := lics_inbound_utility.get_variable('TEXT3');
      rcd_lads_inv_ift.coimp := lics_inbound_utility.get_variable('COIMP');
      rcd_lads_inv_ift.coadi := lics_inbound_utility.get_variable('COADI');
      rcd_lads_inv_ift.cokon := lics_inbound_utility.get_variable('COKON');
      rcd_lads_inv_ift.copha := lics_inbound_utility.get_variable('COPHA');
      rcd_lads_inv_ift.casnr := lics_inbound_utility.get_variable('CASNR');
      rcd_lads_inv_ift.verld := lics_inbound_utility.get_variable('VERLD');
      rcd_lads_inv_ift.verld_tx := lics_inbound_utility.get_variable('VERLD_TX');
      rcd_lads_inv_ift.hanld := lics_inbound_utility.get_variable('HANLD');
      rcd_lads_inv_ift.hanld_tx := lics_inbound_utility.get_variable('HANLD_TX');
      rcd_lads_inv_ift.exprf_tx := lics_inbound_utility.get_variable('EXPRF_TX');
      rcd_lads_inv_ift.exart_tx := lics_inbound_utility.get_variable('EXART_TX');
      rcd_lads_inv_ift.gbnum := lics_inbound_utility.get_variable('GBNUM');
      rcd_lads_inv_ift.regnr := lics_inbound_utility.get_variable('REGNR');
      rcd_lads_inv_ift.herse := lics_inbound_utility.get_variable('HERSE');
      rcd_lads_inv_ift.herkr_tx := lics_inbound_utility.get_variable('HERKR_TX');
      rcd_lads_inv_ift.cobld := lics_inbound_utility.get_variable('COBLD');
      rcd_lads_inv_ift.eioka := lics_inbound_utility.get_variable('EIOKA');
      rcd_lads_inv_ift.verfa := lics_inbound_utility.get_variable('VERFA');
      rcd_lads_inv_ift.prenc := lics_inbound_utility.get_variable('PRENC');
      rcd_lads_inv_ift.preno := lics_inbound_utility.get_variable('PRENO');
      rcd_lads_inv_ift.prend := lics_inbound_utility.get_variable('PREND');
      rcd_lads_inv_ift.besma := lics_inbound_utility.get_variable('BESMA');
      rcd_lads_inv_ift.impma := lics_inbound_utility.get_variable('IMPMA');
      rcd_lads_inv_ift.ktnum := lics_inbound_utility.get_variable('KTNUM');
      rcd_lads_inv_ift.plnum := lics_inbound_utility.get_variable('PLNUM');
      rcd_lads_inv_ift.wkreg := lics_inbound_utility.get_variable('WKREG');
      rcd_lads_inv_ift.imgew := lics_inbound_utility.get_variable('IMGEW');

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
      if rcd_lads_inv_ift.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IFT.BELNR');
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

      insert into lads_inv_ift
         (belnr,
          genseq,
          iftseq,
          exnum,
          expos,
          stawn,
          exprf,
          exart,
          herkl,
          herkr,
          herta,
          herti,
          stxt1,
          stxt2,
          stxt3,
          stxt4,
          stxt5,
          stxt6,
          stxt7,
          bemas,
          prefe,
          bolnr,
          traty,
          traid,
          brulo,
          netlo,
          vemeh,
          herbl,
          bmgew,
          text1,
          text2,
          text3,
          coimp,
          coadi,
          cokon,
          copha,
          casnr,
          verld,
          verld_tx,
          hanld,
          hanld_tx,
          exprf_tx,
          exart_tx,
          gbnum,
          regnr,
          herse,
          herkr_tx,
          cobld,
          eioka,
          verfa,
          prenc,
          preno,
          prend,
          besma,
          impma,
          ktnum,
          plnum,
          wkreg,
          imgew)
      values
         (rcd_lads_inv_ift.belnr,
          rcd_lads_inv_ift.genseq,
          rcd_lads_inv_ift.iftseq,
          rcd_lads_inv_ift.exnum,
          rcd_lads_inv_ift.expos,
          rcd_lads_inv_ift.stawn,
          rcd_lads_inv_ift.exprf,
          rcd_lads_inv_ift.exart,
          rcd_lads_inv_ift.herkl,
          rcd_lads_inv_ift.herkr,
          rcd_lads_inv_ift.herta,
          rcd_lads_inv_ift.herti,
          rcd_lads_inv_ift.stxt1,
          rcd_lads_inv_ift.stxt2,
          rcd_lads_inv_ift.stxt3,
          rcd_lads_inv_ift.stxt4,
          rcd_lads_inv_ift.stxt5,
          rcd_lads_inv_ift.stxt6,
          rcd_lads_inv_ift.stxt7,
          rcd_lads_inv_ift.bemas,
          rcd_lads_inv_ift.prefe,
          rcd_lads_inv_ift.bolnr,
          rcd_lads_inv_ift.traty,
          rcd_lads_inv_ift.traid,
          rcd_lads_inv_ift.brulo,
          rcd_lads_inv_ift.netlo,
          rcd_lads_inv_ift.vemeh,
          rcd_lads_inv_ift.herbl,
          rcd_lads_inv_ift.bmgew,
          rcd_lads_inv_ift.text1,
          rcd_lads_inv_ift.text2,
          rcd_lads_inv_ift.text3,
          rcd_lads_inv_ift.coimp,
          rcd_lads_inv_ift.coadi,
          rcd_lads_inv_ift.cokon,
          rcd_lads_inv_ift.copha,
          rcd_lads_inv_ift.casnr,
          rcd_lads_inv_ift.verld,
          rcd_lads_inv_ift.verld_tx,
          rcd_lads_inv_ift.hanld,
          rcd_lads_inv_ift.hanld_tx,
          rcd_lads_inv_ift.exprf_tx,
          rcd_lads_inv_ift.exart_tx,
          rcd_lads_inv_ift.gbnum,
          rcd_lads_inv_ift.regnr,
          rcd_lads_inv_ift.herse,
          rcd_lads_inv_ift.herkr_tx,
          rcd_lads_inv_ift.cobld,
          rcd_lads_inv_ift.eioka,
          rcd_lads_inv_ift.verfa,
          rcd_lads_inv_ift.prenc,
          rcd_lads_inv_ift.preno,
          rcd_lads_inv_ift.prend,
          rcd_lads_inv_ift.besma,
          rcd_lads_inv_ift.impma,
          rcd_lads_inv_ift.ktnum,
          rcd_lads_inv_ift.plnum,
          rcd_lads_inv_ift.wkreg,
          rcd_lads_inv_ift.imgew);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ift;

   /**************************************************/
   /* This procedure performs the record ICB routine */
   /**************************************************/
   procedure process_record_icb(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ICB', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_icb.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_icb.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_icb.icbseq := rcd_lads_inv_icb.icbseq + 1;
      rcd_lads_inv_icb.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_inv_icb.ivkon := lics_inbound_utility.get_variable('IVKON');

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
      if rcd_lads_inv_icb.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ICB.BELNR');
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

      insert into lads_inv_icb
         (belnr,
          genseq,
          icbseq,
          qualf,
          ivkon)
      values
         (rcd_lads_inv_icb.belnr,
          rcd_lads_inv_icb.genseq,
          rcd_lads_inv_icb.icbseq,
          rcd_lads_inv_icb.qualf,
          rcd_lads_inv_icb.ivkon);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_icb;

   /**************************************************/
   /* This procedure performs the record ITX routine */
   /**************************************************/
   procedure process_record_itx(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ITX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_itx.belnr := rcd_lads_inv_gen.belnr;
      rcd_lads_inv_itx.genseq := rcd_lads_inv_gen.genseq;
      rcd_lads_inv_itx.itxseq := rcd_lads_inv_itx.itxseq + 1;
      rcd_lads_inv_itx.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_inv_itx.tsspras := lics_inbound_utility.get_variable('TSSPRAS');
      rcd_lads_inv_itx.tsspras_iso := lics_inbound_utility.get_variable('TSSPRAS_ISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_iti.itiseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_itx.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ITX.BELNR');
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

      insert into lads_inv_itx
         (belnr,
          genseq,
          itxseq,
          tdid,
          tsspras,
          tsspras_iso)
      values
         (rcd_lads_inv_itx.belnr,
          rcd_lads_inv_itx.genseq,
          rcd_lads_inv_itx.itxseq,
          rcd_lads_inv_itx.tdid,
          rcd_lads_inv_itx.tsspras,
          rcd_lads_inv_itx.tsspras_iso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_itx;

   /**************************************************/
   /* This procedure performs the record ITI routine */
   /**************************************************/
   procedure process_record_iti(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ITI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_inv_iti.belnr := rcd_lads_inv_itx.belnr;
      rcd_lads_inv_iti.genseq := rcd_lads_inv_itx.genseq;
      rcd_lads_inv_iti.itxseq := rcd_lads_inv_itx.itxseq;
      rcd_lads_inv_iti.itiseq := rcd_lads_inv_iti.itiseq + 1;
      rcd_lads_inv_iti.tdline := lics_inbound_utility.get_variable('TDLINE');
      rcd_lads_inv_iti.tdformat := lics_inbound_utility.get_variable('TDFORMAT');

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
      if rcd_lads_inv_iti.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ITI.BELNR');
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

      insert into lads_inv_iti
         (belnr,
          genseq,
          itxseq,
          itiseq,
          tdline,
          tdformat)
      values
         (rcd_lads_inv_iti.belnr,
          rcd_lads_inv_iti.genseq,
          rcd_lads_inv_iti.itxseq,
          rcd_lads_inv_iti.itiseq,
          rcd_lads_inv_iti.tdline,
          rcd_lads_inv_iti.tdformat);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_iti;

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
      rcd_lads_inv_smy.belnr := rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_smy.smyseq := rcd_lads_inv_smy.smyseq + 1;
      rcd_lads_inv_smy.sumid := lics_inbound_utility.get_variable('SUMID');
      rcd_lads_inv_smy.summe := lics_inbound_utility.get_variable('SUMME');
      rcd_lads_inv_smy.sunit := lics_inbound_utility.get_variable('SUNIT');
      rcd_lads_inv_smy.waerq := lics_inbound_utility.get_variable('WAERQ');

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
      if rcd_lads_inv_smy.belnr is null then
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

      insert into lads_inv_smy
         (belnr,
          smyseq,
          sumid,
          summe,
          sunit,
          waerq)
      values
         (rcd_lads_inv_smy.belnr,
          rcd_lads_inv_smy.smyseq,
          rcd_lads_inv_smy.sumid,
          rcd_lads_inv_smy.summe,
          rcd_lads_inv_smy.sunit,
          rcd_lads_inv_smy.waerq);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_smy;

end lads_atllad18;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad18 for lads_app.lads_atllad18;
grant execute on lads_atllad18 to lics_app;
