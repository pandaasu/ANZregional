/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad13
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad13 - Inbound Sales Order Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2008/05   Trevor Keon    Added calls to monitor before and after procedure

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad13 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad13;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad13 as

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
   procedure process_record_tax(par_record in varchar2);
   procedure process_record_con(par_record in varchar2);
   procedure process_record_pnr(par_record in varchar2);
   procedure process_record_pad(par_record in varchar2);
   procedure process_record_ref(par_record in varchar2);
   procedure process_record_tod(par_record in varchar2);
   procedure process_record_top(par_record in varchar2);
   procedure process_record_add(par_record in varchar2);
   procedure process_record_pcd(par_record in varchar2);
   procedure process_record_txi(par_record in varchar2);
   procedure process_record_txt(par_record in varchar2);
   procedure process_record_gen(par_record in varchar2);
   procedure process_record_sog(par_record in varchar2);
   procedure process_record_irf(par_record in varchar2);
   procedure process_record_iad(par_record in varchar2);
   procedure process_record_idt(par_record in varchar2);
   procedure process_record_ita(par_record in varchar2);
   procedure process_record_ico(par_record in varchar2);
   procedure process_record_ips(par_record in varchar2);
   procedure process_record_isc(par_record in varchar2);
   procedure process_record_ipn(par_record in varchar2);
   procedure process_record_ipd(par_record in varchar2);
   procedure process_record_iid(par_record in varchar2);
   procedure process_record_igt(par_record in varchar2);
   procedure process_record_itd(par_record in varchar2);
   procedure process_record_itp(par_record in varchar2);
   procedure process_record_idd(par_record in varchar2);
   procedure process_record_itx(par_record in varchar2);
   procedure process_record_itt(par_record in varchar2);
   procedure process_record_iss(par_record in varchar2);
   procedure process_record_isr(par_record in varchar2);
   procedure process_record_isd(par_record in varchar2);
   procedure process_record_ist(par_record in varchar2);
   procedure process_record_isn(par_record in varchar2);
   procedure process_record_isp(par_record in varchar2);
   procedure process_record_iso(par_record in varchar2);
   procedure process_record_isi(par_record in varchar2);
   procedure process_record_isj(par_record in varchar2);
   procedure process_record_isx(par_record in varchar2);
   procedure process_record_isy(par_record in varchar2);
   procedure process_record_smy(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_sal_ord_hdr lads_sal_ord_hdr%rowtype;
   rcd_lads_sal_ord_org lads_sal_ord_org%rowtype;
   rcd_lads_sal_ord_dat lads_sal_ord_dat%rowtype;
   rcd_lads_sal_ord_tax lads_sal_ord_tax%rowtype;
   rcd_lads_sal_ord_con lads_sal_ord_con%rowtype;
   rcd_lads_sal_ord_pnr lads_sal_ord_pnr%rowtype;
   rcd_lads_sal_ord_pad lads_sal_ord_pad%rowtype;
   rcd_lads_sal_ord_ref lads_sal_ord_ref%rowtype;
   rcd_lads_sal_ord_tod lads_sal_ord_tod%rowtype;
   rcd_lads_sal_ord_top lads_sal_ord_top%rowtype;
   rcd_lads_sal_ord_add lads_sal_ord_add%rowtype;
   rcd_lads_sal_ord_pcd lads_sal_ord_pcd%rowtype;
   rcd_lads_sal_ord_txi lads_sal_ord_txi%rowtype;
   rcd_lads_sal_ord_txt lads_sal_ord_txt%rowtype;
   rcd_lads_sal_ord_gen lads_sal_ord_gen%rowtype;
   rcd_lads_sal_ord_sog lads_sal_ord_sog%rowtype;
   rcd_lads_sal_ord_irf lads_sal_ord_irf%rowtype;
   rcd_lads_sal_ord_iad lads_sal_ord_iad%rowtype;
   rcd_lads_sal_ord_idt lads_sal_ord_idt%rowtype;
   rcd_lads_sal_ord_ita lads_sal_ord_ita%rowtype;
   rcd_lads_sal_ord_ico lads_sal_ord_ico%rowtype;
   rcd_lads_sal_ord_ips lads_sal_ord_ips%rowtype;
   rcd_lads_sal_ord_isc lads_sal_ord_isc%rowtype;
   rcd_lads_sal_ord_ipn lads_sal_ord_ipn%rowtype;
   rcd_lads_sal_ord_ipd lads_sal_ord_ipd%rowtype;
   rcd_lads_sal_ord_iid lads_sal_ord_iid%rowtype;
   rcd_lads_sal_ord_igt lads_sal_ord_igt%rowtype;
   rcd_lads_sal_ord_itd lads_sal_ord_itd%rowtype;
   rcd_lads_sal_ord_itp lads_sal_ord_itp%rowtype;
   rcd_lads_sal_ord_idd lads_sal_ord_idd%rowtype;
   rcd_lads_sal_ord_itx lads_sal_ord_itx%rowtype;
   rcd_lads_sal_ord_itt lads_sal_ord_itt%rowtype;
   rcd_lads_sal_ord_iss lads_sal_ord_iss%rowtype;
   rcd_lads_sal_ord_isr lads_sal_ord_isr%rowtype;
   rcd_lads_sal_ord_isd lads_sal_ord_isd%rowtype;
   rcd_lads_sal_ord_ist lads_sal_ord_ist%rowtype;
   rcd_lads_sal_ord_isn lads_sal_ord_isn%rowtype;
   rcd_lads_sal_ord_isp lads_sal_ord_isp%rowtype;
   rcd_lads_sal_ord_iso lads_sal_ord_iso%rowtype;
   rcd_lads_sal_ord_isi lads_sal_ord_isi%rowtype;
   rcd_lads_sal_ord_isj lads_sal_ord_isj%rowtype;
   rcd_lads_sal_ord_isx lads_sal_ord_isx%rowtype;
   rcd_lads_sal_ord_isy lads_sal_ord_isy%rowtype;
   rcd_lads_sal_ord_smy lads_sal_ord_smy%rowtype;

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
      lics_inbound_utility.set_definition('TAX','IDOC_TAX',3);
      lics_inbound_utility.set_definition('TAX','MWSKZ',7);
      lics_inbound_utility.set_definition('TAX','MSATZ',17);
      lics_inbound_utility.set_definition('TAX','MWSBT',18);
      lics_inbound_utility.set_definition('TAX','TXJCD',15);
      lics_inbound_utility.set_definition('TAX','KTEXT',50);
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
      lics_inbound_utility.set_definition('PAD','IDOC_PAD',3);
      lics_inbound_utility.set_definition('PAD','QUALP',3);
      lics_inbound_utility.set_definition('PAD','STDPN',70);
      /*-*/
      lics_inbound_utility.set_definition('REF','IDOC_REF',3);
      lics_inbound_utility.set_definition('REF','QUALF',3);
      lics_inbound_utility.set_definition('REF','REFNR',35);
      lics_inbound_utility.set_definition('REF','POSNR',6);
      lics_inbound_utility.set_definition('REF','DATUM',8);
      lics_inbound_utility.set_definition('REF','UZEIT',6);
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
      lics_inbound_utility.set_definition('ADD','IDOC_ADD',3);
      lics_inbound_utility.set_definition('ADD','QUALZ',3);
      lics_inbound_utility.set_definition('ADD','CUSADD',35);
      lics_inbound_utility.set_definition('ADD','CUSADD_BEZ',40);
      /*-*/
      lics_inbound_utility.set_definition('PCD','IDOC_PCD',3);
      lics_inbound_utility.set_definition('PCD','CCINS',4);
      lics_inbound_utility.set_definition('PCD','CCINS_BEZEI',20);
      lics_inbound_utility.set_definition('PCD','CCNUM',25);
      lics_inbound_utility.set_definition('PCD','EXDATBI',8);
      lics_inbound_utility.set_definition('PCD','CCNAME',40);
      lics_inbound_utility.set_definition('PCD','FAKWR',17);
      /*-*/
      lics_inbound_utility.set_definition('TXI','IDOC_TXI',3);
      lics_inbound_utility.set_definition('TXI','TDID',4);
      lics_inbound_utility.set_definition('TXI','TSSPRAS',3);
      lics_inbound_utility.set_definition('TXI','TSSPRAS_ISO',2);
      lics_inbound_utility.set_definition('TXI','TDOBJECT',10);
      lics_inbound_utility.set_definition('TXI','TDOBNAME',70);
      /*-*/
      lics_inbound_utility.set_definition('TXT','IDOC_TXT',3);
      lics_inbound_utility.set_definition('TXT','TDLINE',70);
      lics_inbound_utility.set_definition('TXT','TDFORMAT',2);
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
      lics_inbound_utility.set_definition('SOG','IDOC_SOG',3);
      lics_inbound_utility.set_definition('SOG','Z_LCDID',5);
      lics_inbound_utility.set_definition('SOG','Z_LCDNR',18);
      lics_inbound_utility.set_definition('SOG','Z_LCDDSC',16);
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
      lics_inbound_utility.set_definition('IAD','IDOC_IAD',3);
      lics_inbound_utility.set_definition('IAD','ADDIMATNR',18);
      lics_inbound_utility.set_definition('IAD','ADDINUMBER',17);
      lics_inbound_utility.set_definition('IAD','ADDIVKME',3);
      lics_inbound_utility.set_definition('IAD','ADDIFM',4);
      lics_inbound_utility.set_definition('IAD','ADDIFM_TXT',40);
      lics_inbound_utility.set_definition('IAD','ADDIKLART',3);
      lics_inbound_utility.set_definition('IAD','ADDIKLART_TXT',40);
      lics_inbound_utility.set_definition('IAD','ADDICLASS',18);
      lics_inbound_utility.set_definition('IAD','ADDICLASS_TXT',40);
      lics_inbound_utility.set_definition('IAD','ADDIIDOC',1);
      lics_inbound_utility.set_definition('IAD','ADDIMATNR_EXTERNAL',40);
      lics_inbound_utility.set_definition('IAD','ADDIMATNR_VERSION',10);
      lics_inbound_utility.set_definition('IAD','ADDIMATNR_GUID',32);
      /*-*/
      lics_inbound_utility.set_definition('IDT','IDOC_IDT',3);
      lics_inbound_utility.set_definition('IDT','IDDAT',3);
      lics_inbound_utility.set_definition('IDT','DATUM',8);
      lics_inbound_utility.set_definition('IDT','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('ITA','IDOC_ITA',3);
      lics_inbound_utility.set_definition('ITA','MWSKZ',7);
      lics_inbound_utility.set_definition('ITA','MSATZ',17);
      lics_inbound_utility.set_definition('ITA','MWSBT',18);
      lics_inbound_utility.set_definition('ITA','TXJCD',15);
      lics_inbound_utility.set_definition('ITA','KTEXT',50);
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
      lics_inbound_utility.set_definition('IPS','IDOC_IPS',3);
      lics_inbound_utility.set_definition('IPS','KSTBM',17);
      lics_inbound_utility.set_definition('IPS','KBETR',13);
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
      lics_inbound_utility.set_definition('IPD','IDOC_IPD',3);
      lics_inbound_utility.set_definition('IPD','QUALP',3);
      lics_inbound_utility.set_definition('IPD','STDPN',70);
      /*-*/
      lics_inbound_utility.set_definition('IID','IDOC_IID',3);
      lics_inbound_utility.set_definition('IID','QUALF',3);
      lics_inbound_utility.set_definition('IID','IDTNR',35);
      lics_inbound_utility.set_definition('IID','KTEXT',70);
      lics_inbound_utility.set_definition('IID','MFRPN',42);
      lics_inbound_utility.set_definition('IID','MFRNR',10);
      /*-*/
      lics_inbound_utility.set_definition('IGT','IDOC_IGT',3);
      lics_inbound_utility.set_definition('IGT','TDFORMAT',2);
      lics_inbound_utility.set_definition('IGT','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('ITD','IDOC_ITD',3);
      lics_inbound_utility.set_definition('ITD','QUALF',3);
      lics_inbound_utility.set_definition('ITD','LKOND',3);
      lics_inbound_utility.set_definition('ITD','LKTEXT',70);
      lics_inbound_utility.set_definition('ITD','LPRIO',2);
      /*-*/
      lics_inbound_utility.set_definition('ITP','IDOC_ITP',3);
      lics_inbound_utility.set_definition('ITP','QUALF',3);
      lics_inbound_utility.set_definition('ITP','TAGE',8);
      lics_inbound_utility.set_definition('ITP','PRZNT',8);
      lics_inbound_utility.set_definition('ITP','ZTERM_TXT',70);
      /*-*/
      lics_inbound_utility.set_definition('IDD','IDOC_IDD',3);
      lics_inbound_utility.set_definition('IDD','QUALZ',3);
      lics_inbound_utility.set_definition('IDD','CUSADD',35);
      lics_inbound_utility.set_definition('IDD','CUSADD_BEZ',40);
      /*-*/
      lics_inbound_utility.set_definition('ITX','IDOC_ITX',3);
      lics_inbound_utility.set_definition('ITX','TDID',4);
      lics_inbound_utility.set_definition('ITX','TSSPRAS',3);
      lics_inbound_utility.set_definition('ITX','TSSPRAS_ISO',2);
      /*-*/
      lics_inbound_utility.set_definition('ITT','IDOC_ITT',3);
      lics_inbound_utility.set_definition('ITT','TDLINE',70);
      lics_inbound_utility.set_definition('ITT','TDFORMAT',2);
      /*-*/
      lics_inbound_utility.set_definition('ISS','IDOC_ISS',3);
      lics_inbound_utility.set_definition('ISS','SGTYP',3);
      lics_inbound_utility.set_definition('ISS','ZLTYP',3);
      lics_inbound_utility.set_definition('ISS','LVALT',3);
      lics_inbound_utility.set_definition('ISS','ALTNO',2);
      lics_inbound_utility.set_definition('ISS','ALREF',5);
      lics_inbound_utility.set_definition('ISS','ZLART',3);
      lics_inbound_utility.set_definition('ISS','LINNO',10);
      lics_inbound_utility.set_definition('ISS','RANG',2);
      lics_inbound_utility.set_definition('ISS','EXGRP',8);
      lics_inbound_utility.set_definition('ISS','UEPOS',6);
      lics_inbound_utility.set_definition('ISS','MATKL',9);
      lics_inbound_utility.set_definition('ISS','MENGE',15);
      lics_inbound_utility.set_definition('ISS','MENEE',3);
      lics_inbound_utility.set_definition('ISS','BMNG2',15);
      lics_inbound_utility.set_definition('ISS','PMENE',3);
      lics_inbound_utility.set_definition('ISS','BPUMN',6);
      lics_inbound_utility.set_definition('ISS','BPUMZ',6);
      lics_inbound_utility.set_definition('ISS','VPREI',15);
      lics_inbound_utility.set_definition('ISS','PEINH',9);
      lics_inbound_utility.set_definition('ISS','NETWR',18);
      lics_inbound_utility.set_definition('ISS','ANETW',18);
      lics_inbound_utility.set_definition('ISS','SKFBP',18);
      lics_inbound_utility.set_definition('ISS','CURCY',3);
      lics_inbound_utility.set_definition('ISS','PREIS',18);
      lics_inbound_utility.set_definition('ISS','ACTION',3);
      lics_inbound_utility.set_definition('ISS','KZABS',1);
      lics_inbound_utility.set_definition('ISS','UEBTO',4);
      lics_inbound_utility.set_definition('ISS','UEBTK',1);
      lics_inbound_utility.set_definition('ISS','LBNUM',3);
      lics_inbound_utility.set_definition('ISS','AUSGB',4);
      lics_inbound_utility.set_definition('ISS','FRPOS',6);
      lics_inbound_utility.set_definition('ISS','TOPOS',6);
      lics_inbound_utility.set_definition('ISS','KTXT1',40);
      lics_inbound_utility.set_definition('ISS','KTXT2',40);
      lics_inbound_utility.set_definition('ISS','PERNR',8);
      lics_inbound_utility.set_definition('ISS','LGART',4);
      lics_inbound_utility.set_definition('ISS','STELL',8);
      lics_inbound_utility.set_definition('ISS','ZWERT',18);
      lics_inbound_utility.set_definition('ISS','FORMELNR',10);
      lics_inbound_utility.set_definition('ISS','FRMVAL1',15);
      lics_inbound_utility.set_definition('ISS','FRMVAL2',15);
      lics_inbound_utility.set_definition('ISS','FRMVAL3',15);
      lics_inbound_utility.set_definition('ISS','FRMVAL4',15);
      lics_inbound_utility.set_definition('ISS','FRMVAL5',15);
      lics_inbound_utility.set_definition('ISS','USERF1_NUM',10);
      lics_inbound_utility.set_definition('ISS','USERF2_NUM',15);
      lics_inbound_utility.set_definition('ISS','USERF1_TXT',40);
      lics_inbound_utility.set_definition('ISS','USERF2_TXT',10);
      /*-*/
      lics_inbound_utility.set_definition('ISR','IDOC_ISR',3);
      lics_inbound_utility.set_definition('ISR','QUALF',3);
      lics_inbound_utility.set_definition('ISR','REFNR',35);
      lics_inbound_utility.set_definition('ISR','XLINE',10);
      lics_inbound_utility.set_definition('ISR','DATUM',8);
      lics_inbound_utility.set_definition('ISR','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('ISD','IDOC_ISD',3);
      lics_inbound_utility.set_definition('ISD','IDDAT',3);
      lics_inbound_utility.set_definition('ISD','DATUM',8);
      lics_inbound_utility.set_definition('ISD','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('IST','IDOC_IST',3);
      lics_inbound_utility.set_definition('IST','MWSKZ',7);
      lics_inbound_utility.set_definition('IST','MSATZ',17);
      lics_inbound_utility.set_definition('IST','MWSBT',18);
      lics_inbound_utility.set_definition('IST','TXJCD',15);
      /*-*/
      lics_inbound_utility.set_definition('ISN','IDOC_ISN',3);
      lics_inbound_utility.set_definition('ISN','ALCKZ',3);
      lics_inbound_utility.set_definition('ISN','KSCHL',4);
      lics_inbound_utility.set_definition('ISN','KOTXT',80);
      lics_inbound_utility.set_definition('ISN','BETRG',18);
      lics_inbound_utility.set_definition('ISN','KPERC',8);
      lics_inbound_utility.set_definition('ISN','KRATE',15);
      lics_inbound_utility.set_definition('ISN','UPRBS',9);
      lics_inbound_utility.set_definition('ISN','MEAUN',3);
      lics_inbound_utility.set_definition('ISN','KOBTR',18);
      lics_inbound_utility.set_definition('ISN','MENGE',15);
      lics_inbound_utility.set_definition('ISN','PREIS',15);
      lics_inbound_utility.set_definition('ISN','MWSKZ',7);
      lics_inbound_utility.set_definition('ISN','MSATZ',17);
      /*-*/
      lics_inbound_utility.set_definition('ISP','IDOC_ISP',3);
      lics_inbound_utility.set_definition('ISP','PARVW',3);
      lics_inbound_utility.set_definition('ISP','PARTN',17);
      lics_inbound_utility.set_definition('ISP','LIFNR',17);
      lics_inbound_utility.set_definition('ISP','NAME1',35);
      lics_inbound_utility.set_definition('ISP','NAME2',35);
      lics_inbound_utility.set_definition('ISP','NAME3',35);
      lics_inbound_utility.set_definition('ISP','NAME4',35);
      lics_inbound_utility.set_definition('ISP','STRAS',35);
      lics_inbound_utility.set_definition('ISP','STRS2',35);
      lics_inbound_utility.set_definition('ISP','PFACH',35);
      lics_inbound_utility.set_definition('ISP','ORT01',35);
      lics_inbound_utility.set_definition('ISP','COUNC',9);
      lics_inbound_utility.set_definition('ISP','PSTLZ',9);
      lics_inbound_utility.set_definition('ISP','PSTL2',9);
      lics_inbound_utility.set_definition('ISP','LAND1',3);
      lics_inbound_utility.set_definition('ISP','ABLAD',35);
      lics_inbound_utility.set_definition('ISP','PERNR',30);
      lics_inbound_utility.set_definition('ISP','PARNR',30);
      lics_inbound_utility.set_definition('ISP','TELF1',25);
      lics_inbound_utility.set_definition('ISP','TELF2',25);
      lics_inbound_utility.set_definition('ISP','TELBX',25);
      lics_inbound_utility.set_definition('ISP','TELFX',25);
      lics_inbound_utility.set_definition('ISP','TELTX',25);
      lics_inbound_utility.set_definition('ISP','TELX1',25);
      lics_inbound_utility.set_definition('ISP','SPRAS',1);
      lics_inbound_utility.set_definition('ISP','ANRED',15);
      lics_inbound_utility.set_definition('ISP','ORT02',35);
      lics_inbound_utility.set_definition('ISP','HAUSN',6);
      lics_inbound_utility.set_definition('ISP','STOCK',6);
      lics_inbound_utility.set_definition('ISP','REGIO',3);
      lics_inbound_utility.set_definition('ISP','PARGE',1);
      lics_inbound_utility.set_definition('ISP','ISOAL',2);
      lics_inbound_utility.set_definition('ISP','ISONU',2);
      lics_inbound_utility.set_definition('ISP','FCODE',20);
      lics_inbound_utility.set_definition('ISP','IHREZ',30);
      lics_inbound_utility.set_definition('ISP','BNAME',35);
      lics_inbound_utility.set_definition('ISP','PAORG',30);
      lics_inbound_utility.set_definition('ISP','ORGTX',35);
      lics_inbound_utility.set_definition('ISP','PAGRU',30);
      /*-*/
      lics_inbound_utility.set_definition('ISO','IDOC_ISO',3);
      lics_inbound_utility.set_definition('ISO','QUALF',3);
      lics_inbound_utility.set_definition('ISO','IDTNR',35);
      lics_inbound_utility.set_definition('ISO','KTEXT',70);
      /*-*/
      lics_inbound_utility.set_definition('ISI','IDOC_ISI',3);
      lics_inbound_utility.set_definition('ISI','QUALF',3);
      lics_inbound_utility.set_definition('ISI','LKOND',3);
      lics_inbound_utility.set_definition('ISI','LKTEXT',70);
      /*-*/
      lics_inbound_utility.set_definition('ISJ','IDOC_ISJ',3);
      lics_inbound_utility.set_definition('ISJ','QUALF',3);
      lics_inbound_utility.set_definition('ISJ','TAGE',8);
      lics_inbound_utility.set_definition('ISJ','PRZNT',8);
      /*-*/
      lics_inbound_utility.set_definition('ISX','IDOC_ISX',3);
      lics_inbound_utility.set_definition('ISX','TDID',4);
      lics_inbound_utility.set_definition('ISX','TSSPRAS',3);
      /*-*/
      lics_inbound_utility.set_definition('ISY','IDOC_ISY',3);
      lics_inbound_utility.set_definition('ISY','TDLINE',70);
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
         when 'ORG' then process_record_org(par_record);
         when 'DAT' then process_record_dat(par_record);
         when 'TAX' then process_record_tax(par_record);
         when 'CON' then process_record_con(par_record);
         when 'PNR' then process_record_pnr(par_record);
         when 'PAD' then process_record_pad(par_record);
         when 'REF' then process_record_ref(par_record);
         when 'TOD' then process_record_tod(par_record);
         when 'TOP' then process_record_top(par_record);
         when 'ADD' then process_record_add(par_record);
         when 'PCD' then process_record_pcd(par_record);
         when 'TXI' then process_record_txi(par_record);
         when 'TXT' then process_record_txt(par_record);
         when 'GEN' then process_record_gen(par_record);
         when 'SOG' then process_record_sog(par_record);
         when 'IRF' then process_record_irf(par_record);
         when 'IAD' then process_record_iad(par_record);
         when 'IDT' then process_record_idt(par_record);
         when 'ITA' then process_record_ita(par_record);
         when 'ICO' then process_record_ico(par_record);
         when 'IPS' then process_record_ips(par_record);
         when 'ISC' then process_record_isc(par_record);
         when 'IPN' then process_record_ipn(par_record);
         when 'IPD' then process_record_ipd(par_record);
         when 'IID' then process_record_iid(par_record);
         when 'IGT' then process_record_igt(par_record);
         when 'ITD' then process_record_itd(par_record);
         when 'ITP' then process_record_itp(par_record);
         when 'IDD' then process_record_idd(par_record);
         when 'ITX' then process_record_itx(par_record);
         when 'ITT' then process_record_itt(par_record);
         when 'ISS' then process_record_iss(par_record);
         when 'ISR' then process_record_isr(par_record);
         when 'ISD' then process_record_isd(par_record);
         when 'IST' then process_record_ist(par_record);
         when 'ISN' then process_record_isn(par_record);
         when 'ISP' then process_record_isp(par_record);
         when 'ISO' then process_record_iso(par_record);
         when 'ISI' then process_record_isi(par_record);
         when 'ISJ' then process_record_isj(par_record);
         when 'ISX' then process_record_isx(par_record);
         when 'ISY' then process_record_isy(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD13';
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
         
         begin
            lads_atllad13_monitor.execute_before(rcd_lads_sal_ord_hdr.belnr);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
                  
         commit;
         
         begin
            lads_atllad13_monitor.execute_after(rcd_lads_sal_ord_hdr.belnr);
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
      cursor csr_lads_sal_ord_hdr_01 is
         select
            t01.belnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_sal_ord_hdr t01
         where t01.belnr = rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_hdr_01 csr_lads_sal_ord_hdr_01%rowtype;

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
      rcd_lads_sal_ord_hdr.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_sal_ord_hdr.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_sal_ord_hdr.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_sal_ord_hdr.hwaer := lics_inbound_utility.get_variable('HWAER');
      rcd_lads_sal_ord_hdr.wkurs := lics_inbound_utility.get_variable('WKURS');
      rcd_lads_sal_ord_hdr.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_sal_ord_hdr.kundeuinr := lics_inbound_utility.get_variable('KUNDEUINR');
      rcd_lads_sal_ord_hdr.eigenuinr := lics_inbound_utility.get_variable('EIGENUINR');
      rcd_lads_sal_ord_hdr.bsart := lics_inbound_utility.get_variable('BSART');
      rcd_lads_sal_ord_hdr.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_sal_ord_hdr.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_sal_ord_hdr.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_sal_ord_hdr.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_sal_ord_hdr.fkart_rl := lics_inbound_utility.get_variable('FKART_RL');
      rcd_lads_sal_ord_hdr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_sal_ord_hdr.bstzd := lics_inbound_utility.get_variable('BSTZD');
      rcd_lads_sal_ord_hdr.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_sal_ord_hdr.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_sal_ord_hdr.recipnt_no := lics_inbound_utility.get_variable('RECIPNT_NO');
      rcd_lads_sal_ord_hdr.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_sal_ord_hdr.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_lads_sal_ord_hdr.augru := lics_inbound_utility.get_variable('AUGRU');
      rcd_lads_sal_ord_hdr.augru_bez := lics_inbound_utility.get_variable('AUGRU_BEZ');
      rcd_lads_sal_ord_hdr.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_sal_ord_hdr.abrvw_bez := lics_inbound_utility.get_variable('ABRVW_BEZ');
      rcd_lads_sal_ord_hdr.fktyp := lics_inbound_utility.get_variable('FKTYP');
      rcd_lads_sal_ord_hdr.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_lads_sal_ord_hdr.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_lads_sal_ord_hdr.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_sal_ord_hdr.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_sal_ord_hdr.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_sal_ord_hdr.wkurs_m := lics_inbound_utility.get_variable('WKURS_M');
      rcd_lads_sal_ord_hdr.zzexpectpb := lics_inbound_utility.get_variable('ZZEXPECTPB');
      rcd_lads_sal_ord_hdr.zzorbdpr := lics_inbound_utility.get_variable('ZZORBDPR');
      rcd_lads_sal_ord_hdr.zzmanbpr := lics_inbound_utility.get_variable('ZZMANBPR');
      rcd_lads_sal_ord_hdr.zztarif := lics_inbound_utility.get_variable('ZZTARIF');
      rcd_lads_sal_ord_hdr.zznocombi := lics_inbound_utility.get_variable('ZZNOCOMBI');
      rcd_lads_sal_ord_hdr.zzpbuom01 := lics_inbound_utility.get_variable('ZZPBUOM01');
      rcd_lads_sal_ord_hdr.zzpbuom02 := lics_inbound_utility.get_variable('ZZPBUOM02');
      rcd_lads_sal_ord_hdr.zzpbuom03 := lics_inbound_utility.get_variable('ZZPBUOM03');
      rcd_lads_sal_ord_hdr.zzpbuom04 := lics_inbound_utility.get_variable('ZZPBUOM04');
      rcd_lads_sal_ord_hdr.zzpbuom05 := lics_inbound_utility.get_variable('ZZPBUOM05');
      rcd_lads_sal_ord_hdr.zzpbuom06 := lics_inbound_utility.get_variable('ZZPBUOM06');
      rcd_lads_sal_ord_hdr.zzpbuom07 := lics_inbound_utility.get_variable('ZZPBUOM07');
      rcd_lads_sal_ord_hdr.zzpbuom08 := lics_inbound_utility.get_variable('ZZPBUOM08');
      rcd_lads_sal_ord_hdr.zzpbuom09 := lics_inbound_utility.get_variable('ZZPBUOM09');
      rcd_lads_sal_ord_hdr.zzpbuom10 := lics_inbound_utility.get_variable('ZZPBUOM10');
      rcd_lads_sal_ord_hdr.zzgrouping := lics_inbound_utility.get_variable('ZZGROUPING');
      rcd_lads_sal_ord_hdr.zzincompleted := lics_inbound_utility.get_variable('ZZINCOMPLETED');
      rcd_lads_sal_ord_hdr.zzstatus := lics_inbound_utility.get_variable('ZZSTATUS');
      rcd_lads_sal_ord_hdr.zzlogpoint := lics_inbound_utility.get_variable('ZZLOGPOINT');
      rcd_lads_sal_ord_hdr.zzhomopal := lics_inbound_utility.get_variable('ZZHOMOPAL');
      rcd_lads_sal_ord_hdr.zzhomolay := lics_inbound_utility.get_variable('ZZHOMOLAY');
      rcd_lads_sal_ord_hdr.zzloosecas := lics_inbound_utility.get_variable('ZZLOOSECAS');
      rcd_lads_sal_ord_hdr.zzcond05 := lics_inbound_utility.get_variable('ZZCOND05');
      rcd_lads_sal_ord_hdr.zzcond06 := lics_inbound_utility.get_variable('ZZCOND06');
      rcd_lads_sal_ord_hdr.zzcond07 := lics_inbound_utility.get_variable('ZZCOND07');
      rcd_lads_sal_ord_hdr.zzcond08 := lics_inbound_utility.get_variable('ZZCOND08');
      rcd_lads_sal_ord_hdr.zzcond09 := lics_inbound_utility.get_variable('ZZCOND09');
      rcd_lads_sal_ord_hdr.zzcond10 := lics_inbound_utility.get_variable('ZZCOND10');
      rcd_lads_sal_ord_hdr.zzpalspace := lics_inbound_utility.get_variable('ZZPALSPACE');
      rcd_lads_sal_ord_hdr.zzpalbas01 := lics_inbound_utility.get_variable('ZZPALBAS01');
      rcd_lads_sal_ord_hdr.zzpalbas02 := lics_inbound_utility.get_variable('ZZPALBAS02');
      rcd_lads_sal_ord_hdr.zzpalbas03 := lics_inbound_utility.get_variable('ZZPALBAS03');
      rcd_lads_sal_ord_hdr.zzpalbas04 := lics_inbound_utility.get_variable('ZZPALBAS04');
      rcd_lads_sal_ord_hdr.zzpalbas05 := lics_inbound_utility.get_variable('ZZPALBAS05');
      rcd_lads_sal_ord_hdr.zzbrgew := lics_inbound_utility.get_variable('ZZBRGEW');
      rcd_lads_sal_ord_hdr.zzweightpal := lics_inbound_utility.get_variable('ZZWEIGHTPAL');
      rcd_lads_sal_ord_hdr.zzlogpoint_f := lics_inbound_utility.get_variable('ZZLOGPOINT_F');
      rcd_lads_sal_ord_hdr.zzhomopal_f := lics_inbound_utility.get_variable('ZZHOMOPAL_F');
      rcd_lads_sal_ord_hdr.zzhomolay_f := lics_inbound_utility.get_variable('ZZHOMOLAY_F');
      rcd_lads_sal_ord_hdr.zzloosecas_f := lics_inbound_utility.get_variable('ZZLOOSECAS_F');
      rcd_lads_sal_ord_hdr.zzcond05_f := lics_inbound_utility.get_variable('ZZCOND05_F');
      rcd_lads_sal_ord_hdr.zzcond06f := lics_inbound_utility.get_variable('ZZCOND06F');
      rcd_lads_sal_ord_hdr.zzcond07_f := lics_inbound_utility.get_variable('ZZCOND07_F');
      rcd_lads_sal_ord_hdr.zzcond08_f := lics_inbound_utility.get_variable('ZZCOND08_F');
      rcd_lads_sal_ord_hdr.zzcond09_f := lics_inbound_utility.get_variable('ZZCOND09_F');
      rcd_lads_sal_ord_hdr.zzcond10_f := lics_inbound_utility.get_variable('ZZCOND10_F');
      rcd_lads_sal_ord_hdr.zzpalspace_f := lics_inbound_utility.get_variable('ZZPALSPACE_F');
      rcd_lads_sal_ord_hdr.zzpalbas01_f := lics_inbound_utility.get_variable('ZZPALBAS01_F');
      rcd_lads_sal_ord_hdr.zzpalbas02_f := lics_inbound_utility.get_variable('ZZPALBAS02_F');
      rcd_lads_sal_ord_hdr.zzpalbas03_f := lics_inbound_utility.get_variable('ZZPALBAS03_F');
      rcd_lads_sal_ord_hdr.zzpalbas04_f := lics_inbound_utility.get_variable('ZZPALBAS04_F');
      rcd_lads_sal_ord_hdr.zzpalbas05_f := lics_inbound_utility.get_variable('ZZPALBAS05_F');
      rcd_lads_sal_ord_hdr.zzbrgew_f := lics_inbound_utility.get_variable('ZZBRGEW_F');
      rcd_lads_sal_ord_hdr.zzweightpal_f := lics_inbound_utility.get_variable('ZZWEIGHTPAL_F');
      rcd_lads_sal_ord_hdr.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
      rcd_lads_sal_ord_hdr.zzmeins02 := lics_inbound_utility.get_variable('ZZMEINS02');
      rcd_lads_sal_ord_hdr.zzmeins03 := lics_inbound_utility.get_variable('ZZMEINS03');
      rcd_lads_sal_ord_hdr.zzmeins04 := lics_inbound_utility.get_variable('ZZMEINS04');
      rcd_lads_sal_ord_hdr.zzmeins05 := lics_inbound_utility.get_variable('ZZMEINS05');
      rcd_lads_sal_ord_hdr.zzweightuom := lics_inbound_utility.get_variable('ZZWEIGHTUOM');
      rcd_lads_sal_ord_hdr.zzerror := lics_inbound_utility.get_variable('ZZERROR');
      rcd_lads_sal_ord_hdr.zzvsart := lics_inbound_utility.get_variable('ZZVSART');
      rcd_lads_sal_ord_hdr.zzsdabw := lics_inbound_utility.get_variable('ZZSDABW');
      rcd_lads_sal_ord_hdr.zzordrspstatus_h := lics_inbound_utility.get_variable('ZZORDRSPSTATUS_H');
      rcd_lads_sal_ord_hdr.cmgst := lics_inbound_utility.get_variable('CMGST');
      rcd_lads_sal_ord_hdr.cmgst_bez := lics_inbound_utility.get_variable('CMGST_BEZ');
      rcd_lads_sal_ord_hdr.spstg := lics_inbound_utility.get_variable('SPSTG');
      rcd_lads_sal_ord_hdr.spstg_bez := lics_inbound_utility.get_variable('SPSTG_BEZ');
      rcd_lads_sal_ord_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_sal_ord_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_sal_ord_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_sal_ord_hdr.lads_date := sysdate;
      rcd_lads_sal_ord_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_org.orgseq := 0;
      rcd_lads_sal_ord_dat.datseq := 0;
      rcd_lads_sal_ord_tax.taxseq := 0;
      rcd_lads_sal_ord_con.conseq := 0;
      rcd_lads_sal_ord_pnr.pnrseq := 0;
      rcd_lads_sal_ord_ref.refseq := 0;
      rcd_lads_sal_ord_tod.todseq := 0;
      rcd_lads_sal_ord_top.topseq := 0;
      rcd_lads_sal_ord_add.addseq := 0;
      rcd_lads_sal_ord_pcd.pcdseq := 0;
      rcd_lads_sal_ord_txi.txiseq := 0;
      rcd_lads_sal_ord_gen.genseq := 0;
      rcd_lads_sal_ord_smy.smyseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_hdr.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BELNR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_sal_ord_hdr.belnr is null) then
         var_exists := true;
         open csr_lads_sal_ord_hdr_01;
         fetch csr_lads_sal_ord_hdr_01 into rcd_lads_sal_ord_hdr_01;
         if csr_lads_sal_ord_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_sal_ord_hdr_01;
         if var_exists = true then
            if rcd_lads_sal_ord_hdr.idoc_timestamp > rcd_lads_sal_ord_hdr_01.idoc_timestamp then
               delete from lads_sal_ord_smy where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isy where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isx where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isj where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isi where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_iso where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isp where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isn where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_ist where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isd where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isr where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_iss where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_itt where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_itx where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_idd where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_itp where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_itd where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_igt where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_iid where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_ipd where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_ipn where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_isc where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_ips where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_ico where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_ita where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_idt where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_iad where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_irf where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_sog where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_gen where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_txt where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_txi where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_pcd where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_add where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_top where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_tod where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_ref where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_pad where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_pnr where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_con where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_tax where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_dat where belnr = rcd_lads_sal_ord_hdr.belnr;
               delete from lads_sal_ord_org where belnr = rcd_lads_sal_ord_hdr.belnr;
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

      update lads_sal_ord_hdr set
         action = rcd_lads_sal_ord_hdr.action,
         kzabs = rcd_lads_sal_ord_hdr.kzabs,
         curcy = rcd_lads_sal_ord_hdr.curcy,
         hwaer = rcd_lads_sal_ord_hdr.hwaer,
         wkurs = rcd_lads_sal_ord_hdr.wkurs,
         zterm = rcd_lads_sal_ord_hdr.zterm,
         kundeuinr = rcd_lads_sal_ord_hdr.kundeuinr,
         eigenuinr = rcd_lads_sal_ord_hdr.eigenuinr,
         bsart = rcd_lads_sal_ord_hdr.bsart,
         ntgew = rcd_lads_sal_ord_hdr.ntgew,
         brgew = rcd_lads_sal_ord_hdr.brgew,
         gewei = rcd_lads_sal_ord_hdr.gewei,
         fkart_rl = rcd_lads_sal_ord_hdr.fkart_rl,
         ablad = rcd_lads_sal_ord_hdr.ablad,
         bstzd = rcd_lads_sal_ord_hdr.bstzd,
         vsart = rcd_lads_sal_ord_hdr.vsart,
         vsart_bez = rcd_lads_sal_ord_hdr.vsart_bez,
         recipnt_no = rcd_lads_sal_ord_hdr.recipnt_no,
         kzazu = rcd_lads_sal_ord_hdr.kzazu,
         autlf = rcd_lads_sal_ord_hdr.autlf,
         augru = rcd_lads_sal_ord_hdr.augru,
         augru_bez = rcd_lads_sal_ord_hdr.augru_bez,
         abrvw = rcd_lads_sal_ord_hdr.abrvw,
         abrvw_bez = rcd_lads_sal_ord_hdr.abrvw_bez,
         fktyp = rcd_lads_sal_ord_hdr.fktyp,
         lifsk = rcd_lads_sal_ord_hdr.lifsk,
         lifsk_bez = rcd_lads_sal_ord_hdr.lifsk_bez,
         empst = rcd_lads_sal_ord_hdr.empst,
         abtnr = rcd_lads_sal_ord_hdr.abtnr,
         delco = rcd_lads_sal_ord_hdr.delco,
         wkurs_m = rcd_lads_sal_ord_hdr.wkurs_m,
         zzexpectpb = rcd_lads_sal_ord_hdr.zzexpectpb,
         zzorbdpr = rcd_lads_sal_ord_hdr.zzorbdpr,
         zzmanbpr = rcd_lads_sal_ord_hdr.zzmanbpr,
         zztarif = rcd_lads_sal_ord_hdr.zztarif,
         zznocombi = rcd_lads_sal_ord_hdr.zznocombi,
         zzpbuom01 = rcd_lads_sal_ord_hdr.zzpbuom01,
         zzpbuom02 = rcd_lads_sal_ord_hdr.zzpbuom02,
         zzpbuom03 = rcd_lads_sal_ord_hdr.zzpbuom03,
         zzpbuom04 = rcd_lads_sal_ord_hdr.zzpbuom04,
         zzpbuom05 = rcd_lads_sal_ord_hdr.zzpbuom05,
         zzpbuom06 = rcd_lads_sal_ord_hdr.zzpbuom06,
         zzpbuom07 = rcd_lads_sal_ord_hdr.zzpbuom07,
         zzpbuom08 = rcd_lads_sal_ord_hdr.zzpbuom08,
         zzpbuom09 = rcd_lads_sal_ord_hdr.zzpbuom09,
         zzpbuom10 = rcd_lads_sal_ord_hdr.zzpbuom10,
         zzgrouping = rcd_lads_sal_ord_hdr.zzgrouping,
         zzincompleted = rcd_lads_sal_ord_hdr.zzincompleted,
         zzstatus = rcd_lads_sal_ord_hdr.zzstatus,
         zzlogpoint = rcd_lads_sal_ord_hdr.zzlogpoint,
         zzhomopal = rcd_lads_sal_ord_hdr.zzhomopal,
         zzhomolay = rcd_lads_sal_ord_hdr.zzhomolay,
         zzloosecas = rcd_lads_sal_ord_hdr.zzloosecas,
         zzcond05 = rcd_lads_sal_ord_hdr.zzcond05,
         zzcond06 = rcd_lads_sal_ord_hdr.zzcond06,
         zzcond07 = rcd_lads_sal_ord_hdr.zzcond07,
         zzcond08 = rcd_lads_sal_ord_hdr.zzcond08,
         zzcond09 = rcd_lads_sal_ord_hdr.zzcond09,
         zzcond10 = rcd_lads_sal_ord_hdr.zzcond10,
         zzpalspace = rcd_lads_sal_ord_hdr.zzpalspace,
         zzpalbas01 = rcd_lads_sal_ord_hdr.zzpalbas01,
         zzpalbas02 = rcd_lads_sal_ord_hdr.zzpalbas02,
         zzpalbas03 = rcd_lads_sal_ord_hdr.zzpalbas03,
         zzpalbas04 = rcd_lads_sal_ord_hdr.zzpalbas04,
         zzpalbas05 = rcd_lads_sal_ord_hdr.zzpalbas05,
         zzbrgew = rcd_lads_sal_ord_hdr.zzbrgew,
         zzweightpal = rcd_lads_sal_ord_hdr.zzweightpal,
         zzlogpoint_f = rcd_lads_sal_ord_hdr.zzlogpoint_f,
         zzhomopal_f = rcd_lads_sal_ord_hdr.zzhomopal_f,
         zzhomolay_f = rcd_lads_sal_ord_hdr.zzhomolay_f,
         zzloosecas_f = rcd_lads_sal_ord_hdr.zzloosecas_f,
         zzcond05_f = rcd_lads_sal_ord_hdr.zzcond05_f,
         zzcond06f = rcd_lads_sal_ord_hdr.zzcond06f,
         zzcond07_f = rcd_lads_sal_ord_hdr.zzcond07_f,
         zzcond08_f = rcd_lads_sal_ord_hdr.zzcond08_f,
         zzcond09_f = rcd_lads_sal_ord_hdr.zzcond09_f,
         zzcond10_f = rcd_lads_sal_ord_hdr.zzcond10_f,
         zzpalspace_f = rcd_lads_sal_ord_hdr.zzpalspace_f,
         zzpalbas01_f = rcd_lads_sal_ord_hdr.zzpalbas01_f,
         zzpalbas02_f = rcd_lads_sal_ord_hdr.zzpalbas02_f,
         zzpalbas03_f = rcd_lads_sal_ord_hdr.zzpalbas03_f,
         zzpalbas04_f = rcd_lads_sal_ord_hdr.zzpalbas04_f,
         zzpalbas05_f = rcd_lads_sal_ord_hdr.zzpalbas05_f,
         zzbrgew_f = rcd_lads_sal_ord_hdr.zzbrgew_f,
         zzweightpal_f = rcd_lads_sal_ord_hdr.zzweightpal_f,
         zzmeins01 = rcd_lads_sal_ord_hdr.zzmeins01,
         zzmeins02 = rcd_lads_sal_ord_hdr.zzmeins02,
         zzmeins03 = rcd_lads_sal_ord_hdr.zzmeins03,
         zzmeins04 = rcd_lads_sal_ord_hdr.zzmeins04,
         zzmeins05 = rcd_lads_sal_ord_hdr.zzmeins05,
         zzweightuom = rcd_lads_sal_ord_hdr.zzweightuom,
         zzerror = rcd_lads_sal_ord_hdr.zzerror,
         zzvsart = rcd_lads_sal_ord_hdr.zzvsart,
         zzsdabw = rcd_lads_sal_ord_hdr.zzsdabw,
         zzordrspstatus_h = rcd_lads_sal_ord_hdr.zzordrspstatus_h,
         cmgst = rcd_lads_sal_ord_hdr.cmgst,
         cmgst_bez = rcd_lads_sal_ord_hdr.cmgst_bez,
         spstg = rcd_lads_sal_ord_hdr.spstg,
         spstg_bez = rcd_lads_sal_ord_hdr.spstg_bez,
         idoc_name = rcd_lads_sal_ord_hdr.idoc_name,
         idoc_number = rcd_lads_sal_ord_hdr.idoc_number,
         idoc_timestamp = rcd_lads_sal_ord_hdr.idoc_timestamp,
         lads_date = rcd_lads_sal_ord_hdr.lads_date,
         lads_status = rcd_lads_sal_ord_hdr.lads_status
      where belnr = rcd_lads_sal_ord_hdr.belnr;
      if sql%notfound then
         insert into lads_sal_ord_hdr
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
             lads_date,
             lads_status)
         values
            (rcd_lads_sal_ord_hdr.action,
             rcd_lads_sal_ord_hdr.kzabs,
             rcd_lads_sal_ord_hdr.curcy,
             rcd_lads_sal_ord_hdr.hwaer,
             rcd_lads_sal_ord_hdr.wkurs,
             rcd_lads_sal_ord_hdr.zterm,
             rcd_lads_sal_ord_hdr.kundeuinr,
             rcd_lads_sal_ord_hdr.eigenuinr,
             rcd_lads_sal_ord_hdr.bsart,
             rcd_lads_sal_ord_hdr.belnr,
             rcd_lads_sal_ord_hdr.ntgew,
             rcd_lads_sal_ord_hdr.brgew,
             rcd_lads_sal_ord_hdr.gewei,
             rcd_lads_sal_ord_hdr.fkart_rl,
             rcd_lads_sal_ord_hdr.ablad,
             rcd_lads_sal_ord_hdr.bstzd,
             rcd_lads_sal_ord_hdr.vsart,
             rcd_lads_sal_ord_hdr.vsart_bez,
             rcd_lads_sal_ord_hdr.recipnt_no,
             rcd_lads_sal_ord_hdr.kzazu,
             rcd_lads_sal_ord_hdr.autlf,
             rcd_lads_sal_ord_hdr.augru,
             rcd_lads_sal_ord_hdr.augru_bez,
             rcd_lads_sal_ord_hdr.abrvw,
             rcd_lads_sal_ord_hdr.abrvw_bez,
             rcd_lads_sal_ord_hdr.fktyp,
             rcd_lads_sal_ord_hdr.lifsk,
             rcd_lads_sal_ord_hdr.lifsk_bez,
             rcd_lads_sal_ord_hdr.empst,
             rcd_lads_sal_ord_hdr.abtnr,
             rcd_lads_sal_ord_hdr.delco,
             rcd_lads_sal_ord_hdr.wkurs_m,
             rcd_lads_sal_ord_hdr.zzexpectpb,
             rcd_lads_sal_ord_hdr.zzorbdpr,
             rcd_lads_sal_ord_hdr.zzmanbpr,
             rcd_lads_sal_ord_hdr.zztarif,
             rcd_lads_sal_ord_hdr.zznocombi,
             rcd_lads_sal_ord_hdr.zzpbuom01,
             rcd_lads_sal_ord_hdr.zzpbuom02,
             rcd_lads_sal_ord_hdr.zzpbuom03,
             rcd_lads_sal_ord_hdr.zzpbuom04,
             rcd_lads_sal_ord_hdr.zzpbuom05,
             rcd_lads_sal_ord_hdr.zzpbuom06,
             rcd_lads_sal_ord_hdr.zzpbuom07,
             rcd_lads_sal_ord_hdr.zzpbuom08,
             rcd_lads_sal_ord_hdr.zzpbuom09,
             rcd_lads_sal_ord_hdr.zzpbuom10,
             rcd_lads_sal_ord_hdr.zzgrouping,
             rcd_lads_sal_ord_hdr.zzincompleted,
             rcd_lads_sal_ord_hdr.zzstatus,
             rcd_lads_sal_ord_hdr.zzlogpoint,
             rcd_lads_sal_ord_hdr.zzhomopal,
             rcd_lads_sal_ord_hdr.zzhomolay,
             rcd_lads_sal_ord_hdr.zzloosecas,
             rcd_lads_sal_ord_hdr.zzcond05,
             rcd_lads_sal_ord_hdr.zzcond06,
             rcd_lads_sal_ord_hdr.zzcond07,
             rcd_lads_sal_ord_hdr.zzcond08,
             rcd_lads_sal_ord_hdr.zzcond09,
             rcd_lads_sal_ord_hdr.zzcond10,
             rcd_lads_sal_ord_hdr.zzpalspace,
             rcd_lads_sal_ord_hdr.zzpalbas01,
             rcd_lads_sal_ord_hdr.zzpalbas02,
             rcd_lads_sal_ord_hdr.zzpalbas03,
             rcd_lads_sal_ord_hdr.zzpalbas04,
             rcd_lads_sal_ord_hdr.zzpalbas05,
             rcd_lads_sal_ord_hdr.zzbrgew,
             rcd_lads_sal_ord_hdr.zzweightpal,
             rcd_lads_sal_ord_hdr.zzlogpoint_f,
             rcd_lads_sal_ord_hdr.zzhomopal_f,
             rcd_lads_sal_ord_hdr.zzhomolay_f,
             rcd_lads_sal_ord_hdr.zzloosecas_f,
             rcd_lads_sal_ord_hdr.zzcond05_f,
             rcd_lads_sal_ord_hdr.zzcond06f,
             rcd_lads_sal_ord_hdr.zzcond07_f,
             rcd_lads_sal_ord_hdr.zzcond08_f,
             rcd_lads_sal_ord_hdr.zzcond09_f,
             rcd_lads_sal_ord_hdr.zzcond10_f,
             rcd_lads_sal_ord_hdr.zzpalspace_f,
             rcd_lads_sal_ord_hdr.zzpalbas01_f,
             rcd_lads_sal_ord_hdr.zzpalbas02_f,
             rcd_lads_sal_ord_hdr.zzpalbas03_f,
             rcd_lads_sal_ord_hdr.zzpalbas04_f,
             rcd_lads_sal_ord_hdr.zzpalbas05_f,
             rcd_lads_sal_ord_hdr.zzbrgew_f,
             rcd_lads_sal_ord_hdr.zzweightpal_f,
             rcd_lads_sal_ord_hdr.zzmeins01,
             rcd_lads_sal_ord_hdr.zzmeins02,
             rcd_lads_sal_ord_hdr.zzmeins03,
             rcd_lads_sal_ord_hdr.zzmeins04,
             rcd_lads_sal_ord_hdr.zzmeins05,
             rcd_lads_sal_ord_hdr.zzweightuom,
             rcd_lads_sal_ord_hdr.zzerror,
             rcd_lads_sal_ord_hdr.zzvsart,
             rcd_lads_sal_ord_hdr.zzsdabw,
             rcd_lads_sal_ord_hdr.zzordrspstatus_h,
             rcd_lads_sal_ord_hdr.cmgst,
             rcd_lads_sal_ord_hdr.cmgst_bez,
             rcd_lads_sal_ord_hdr.spstg,
             rcd_lads_sal_ord_hdr.spstg_bez,
             rcd_lads_sal_ord_hdr.idoc_name,
             rcd_lads_sal_ord_hdr.idoc_number,
             rcd_lads_sal_ord_hdr.idoc_timestamp,
             rcd_lads_sal_ord_hdr.lads_date,
             rcd_lads_sal_ord_hdr.lads_status);
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
      rcd_lads_sal_ord_org.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_org.orgseq := rcd_lads_sal_ord_org.orgseq + 1;
      rcd_lads_sal_ord_org.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_org.orgid := lics_inbound_utility.get_variable('ORGID');

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
      if rcd_lads_sal_ord_org.belnr is null then
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

      insert into lads_sal_ord_org
         (belnr,
          orgseq,
          qualf,
          orgid)
      values
         (rcd_lads_sal_ord_org.belnr,
          rcd_lads_sal_ord_org.orgseq,
          rcd_lads_sal_ord_org.qualf,
          rcd_lads_sal_ord_org.orgid);

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
      rcd_lads_sal_ord_dat.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_dat.datseq := rcd_lads_sal_ord_dat.datseq + 1;
      rcd_lads_sal_ord_dat.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_lads_sal_ord_dat.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_sal_ord_dat.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_sal_ord_dat.belnr is null then
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

      insert into lads_sal_ord_dat
         (belnr,
          datseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_lads_sal_ord_dat.belnr,
          rcd_lads_sal_ord_dat.datseq,
          rcd_lads_sal_ord_dat.iddat,
          rcd_lads_sal_ord_dat.datum,
          rcd_lads_sal_ord_dat.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

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
      rcd_lads_sal_ord_tax.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_tax.taxseq := rcd_lads_sal_ord_tax.taxseq + 1;
      rcd_lads_sal_ord_tax.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_sal_ord_tax.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_sal_ord_tax.mwsbt := lics_inbound_utility.get_variable('MWSBT');
      rcd_lads_sal_ord_tax.txjcd := lics_inbound_utility.get_variable('TXJCD');
      rcd_lads_sal_ord_tax.ktext := lics_inbound_utility.get_variable('KTEXT');

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
      if rcd_lads_sal_ord_tax.belnr is null then
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

      insert into lads_sal_ord_tax
         (belnr,
          taxseq,
          mwskz,
          msatz,
          mwsbt,
          txjcd,
          ktext)
      values
         (rcd_lads_sal_ord_tax.belnr,
          rcd_lads_sal_ord_tax.taxseq,
          rcd_lads_sal_ord_tax.mwskz,
          rcd_lads_sal_ord_tax.msatz,
          rcd_lads_sal_ord_tax.mwsbt,
          rcd_lads_sal_ord_tax.txjcd,
          rcd_lads_sal_ord_tax.ktext);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tax;

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
      rcd_lads_sal_ord_con.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_con.conseq := rcd_lads_sal_ord_con.conseq + 1;
      rcd_lads_sal_ord_con.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_lads_sal_ord_con.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_sal_ord_con.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_lads_sal_ord_con.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_sal_ord_con.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_lads_sal_ord_con.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_lads_sal_ord_con.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_lads_sal_ord_con.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_lads_sal_ord_con.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_lads_sal_ord_con.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_sal_ord_con.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_sal_ord_con.koein := lics_inbound_utility.get_variable('KOEIN');

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
      if rcd_lads_sal_ord_con.belnr is null then
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

      insert into lads_sal_ord_con
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
         (rcd_lads_sal_ord_con.belnr,
          rcd_lads_sal_ord_con.conseq,
          rcd_lads_sal_ord_con.alckz,
          rcd_lads_sal_ord_con.kschl,
          rcd_lads_sal_ord_con.kotxt,
          rcd_lads_sal_ord_con.betrg,
          rcd_lads_sal_ord_con.kperc,
          rcd_lads_sal_ord_con.krate,
          rcd_lads_sal_ord_con.uprbs,
          rcd_lads_sal_ord_con.meaun,
          rcd_lads_sal_ord_con.kobtr,
          rcd_lads_sal_ord_con.mwskz,
          rcd_lads_sal_ord_con.msatz,
          rcd_lads_sal_ord_con.koein);

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
      rcd_lads_sal_ord_pnr.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_pnr.pnrseq := rcd_lads_sal_ord_pnr.pnrseq + 1;
      rcd_lads_sal_ord_pnr.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_sal_ord_pnr.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_lads_sal_ord_pnr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_sal_ord_pnr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_sal_ord_pnr.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_sal_ord_pnr.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_sal_ord_pnr.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_sal_ord_pnr.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_sal_ord_pnr.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_lads_sal_ord_pnr.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_lads_sal_ord_pnr.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_sal_ord_pnr.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_lads_sal_ord_pnr.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_lads_sal_ord_pnr.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_lads_sal_ord_pnr.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_sal_ord_pnr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_sal_ord_pnr.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_lads_sal_ord_pnr.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_lads_sal_ord_pnr.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_sal_ord_pnr.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_lads_sal_ord_pnr.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_lads_sal_ord_pnr.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_lads_sal_ord_pnr.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_lads_sal_ord_pnr.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_lads_sal_ord_pnr.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_sal_ord_pnr.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_sal_ord_pnr.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_sal_ord_pnr.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_lads_sal_ord_pnr.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_lads_sal_ord_pnr.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_lads_sal_ord_pnr.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_lads_sal_ord_pnr.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_lads_sal_ord_pnr.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_lads_sal_ord_pnr.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_lads_sal_ord_pnr.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_sal_ord_pnr.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_sal_ord_pnr.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_lads_sal_ord_pnr.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_lads_sal_ord_pnr.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_lads_sal_ord_pnr.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_sal_ord_pnr.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_lads_sal_ord_pnr.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_lads_sal_ord_pnr.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_lads_sal_ord_pnr.title := lics_inbound_utility.get_variable('TITLE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_pad.padseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_pnr.belnr is null then
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

      insert into lads_sal_ord_pnr
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
         (rcd_lads_sal_ord_pnr.belnr,
          rcd_lads_sal_ord_pnr.pnrseq,
          rcd_lads_sal_ord_pnr.parvw,
          rcd_lads_sal_ord_pnr.partn,
          rcd_lads_sal_ord_pnr.lifnr,
          rcd_lads_sal_ord_pnr.name1,
          rcd_lads_sal_ord_pnr.name2,
          rcd_lads_sal_ord_pnr.name3,
          rcd_lads_sal_ord_pnr.name4,
          rcd_lads_sal_ord_pnr.stras,
          rcd_lads_sal_ord_pnr.strs2,
          rcd_lads_sal_ord_pnr.pfach,
          rcd_lads_sal_ord_pnr.ort01,
          rcd_lads_sal_ord_pnr.counc,
          rcd_lads_sal_ord_pnr.pstlz,
          rcd_lads_sal_ord_pnr.pstl2,
          rcd_lads_sal_ord_pnr.land1,
          rcd_lads_sal_ord_pnr.ablad,
          rcd_lads_sal_ord_pnr.pernr,
          rcd_lads_sal_ord_pnr.parnr,
          rcd_lads_sal_ord_pnr.telf1,
          rcd_lads_sal_ord_pnr.telf2,
          rcd_lads_sal_ord_pnr.telbx,
          rcd_lads_sal_ord_pnr.telfx,
          rcd_lads_sal_ord_pnr.teltx,
          rcd_lads_sal_ord_pnr.telx1,
          rcd_lads_sal_ord_pnr.spras,
          rcd_lads_sal_ord_pnr.anred,
          rcd_lads_sal_ord_pnr.ort02,
          rcd_lads_sal_ord_pnr.hausn,
          rcd_lads_sal_ord_pnr.stock,
          rcd_lads_sal_ord_pnr.regio,
          rcd_lads_sal_ord_pnr.parge,
          rcd_lads_sal_ord_pnr.isoal,
          rcd_lads_sal_ord_pnr.isonu,
          rcd_lads_sal_ord_pnr.fcode,
          rcd_lads_sal_ord_pnr.ihrez,
          rcd_lads_sal_ord_pnr.bname,
          rcd_lads_sal_ord_pnr.paorg,
          rcd_lads_sal_ord_pnr.orgtx,
          rcd_lads_sal_ord_pnr.pagru,
          rcd_lads_sal_ord_pnr.knref,
          rcd_lads_sal_ord_pnr.ilnnr,
          rcd_lads_sal_ord_pnr.pfort,
          rcd_lads_sal_ord_pnr.spras_iso,
          rcd_lads_sal_ord_pnr.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pnr;

   /**************************************************/
   /* This procedure performs the record PAD routine */
   /**************************************************/
   procedure process_record_pad(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PAD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_pad.belnr := rcd_lads_sal_ord_pnr.belnr;
      rcd_lads_sal_ord_pad.pnrseq:= rcd_lads_sal_ord_pnr.pnrseq;
      rcd_lads_sal_ord_pad.padseq := rcd_lads_sal_ord_pad.padseq + 1;
      rcd_lads_sal_ord_pad.qualp := lics_inbound_utility.get_variable('QUALP');
      rcd_lads_sal_ord_pad.stdpn := lics_inbound_utility.get_variable('STDPN');

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
      if rcd_lads_sal_ord_pad.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PAD.BELNR');
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

      insert into lads_sal_ord_pad
         (belnr,
          pnrseq,
          padseq,
          qualp,
          stdpn)
      values
         (rcd_lads_sal_ord_pad.belnr,
          rcd_lads_sal_ord_pad.pnrseq,
          rcd_lads_sal_ord_pad.padseq,
          rcd_lads_sal_ord_pad.qualp,
          rcd_lads_sal_ord_pad.stdpn);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pad;

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
      rcd_lads_sal_ord_ref.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_ref.refseq := rcd_lads_sal_ord_ref.refseq + 1;
      rcd_lads_sal_ord_ref.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_ref.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_lads_sal_ord_ref.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_sal_ord_ref.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_sal_ord_ref.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_sal_ord_ref.belnr is null then
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

      insert into lads_sal_ord_ref
         (belnr,
          refseq,
          qualf,
          refnr,
          posnr,
          datum,
          uzeit)
      values
         (rcd_lads_sal_ord_ref.belnr,
          rcd_lads_sal_ord_ref.refseq,
          rcd_lads_sal_ord_ref.qualf,
          rcd_lads_sal_ord_ref.refnr,
          rcd_lads_sal_ord_ref.posnr,
          rcd_lads_sal_ord_ref.datum,
          rcd_lads_sal_ord_ref.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ref;

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
      rcd_lads_sal_ord_tod.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_tod.todseq := rcd_lads_sal_ord_tod.todseq + 1;
      rcd_lads_sal_ord_tod.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_tod.lkond := lics_inbound_utility.get_variable('LKOND');
      rcd_lads_sal_ord_tod.lktext := lics_inbound_utility.get_variable('LKTEXT');

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
      if rcd_lads_sal_ord_tod.belnr is null then
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

      insert into lads_sal_ord_tod
         (belnr,
          todseq,
          qualf,
          lkond,
          lktext)
      values
         (rcd_lads_sal_ord_tod.belnr,
          rcd_lads_sal_ord_tod.todseq,
          rcd_lads_sal_ord_tod.qualf,
          rcd_lads_sal_ord_tod.lkond,
          rcd_lads_sal_ord_tod.lktext);

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
      rcd_lads_sal_ord_top.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_top.topseq := rcd_lads_sal_ord_top.topseq + 1;
      rcd_lads_sal_ord_top.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_top.tage := lics_inbound_utility.get_variable('TAGE');
      rcd_lads_sal_ord_top.prznt := lics_inbound_utility.get_variable('PRZNT');
      rcd_lads_sal_ord_top.zterm_txt := lics_inbound_utility.get_variable('ZTERM_TXT');

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
      if rcd_lads_sal_ord_top.belnr is null then
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

      insert into lads_sal_ord_top
         (belnr,
          topseq,
          qualf,
          tage,
          prznt,
          zterm_txt)
      values
         (rcd_lads_sal_ord_top.belnr,
          rcd_lads_sal_ord_top.topseq,
          rcd_lads_sal_ord_top.qualf,
          rcd_lads_sal_ord_top.tage,
          rcd_lads_sal_ord_top.prznt,
          rcd_lads_sal_ord_top.zterm_txt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_top;

   /**************************************************/
   /* This procedure performs the record ADD routine */
   /**************************************************/
   procedure process_record_add(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ADD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_add.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_add.addseq := rcd_lads_sal_ord_add.addseq + 1;
      rcd_lads_sal_ord_add.qualz := lics_inbound_utility.get_variable('QUALZ');
      rcd_lads_sal_ord_add.cusadd := lics_inbound_utility.get_variable('CUSADD');
      rcd_lads_sal_ord_add.cusadd_bez := lics_inbound_utility.get_variable('CUSADD_BEZ');

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
      if rcd_lads_sal_ord_add.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ADD.BELNR');
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

      insert into lads_sal_ord_add
         (belnr,
          addseq,
          qualz,
          cusadd,
          cusadd_bez)
      values
         (rcd_lads_sal_ord_add.belnr,
          rcd_lads_sal_ord_add.addseq,
          rcd_lads_sal_ord_add.qualz,
          rcd_lads_sal_ord_add.cusadd,
          rcd_lads_sal_ord_add.cusadd_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_add;

   /**************************************************/
   /* This procedure performs the record PCD routine */
   /**************************************************/
   procedure process_record_pcd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PCD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_pcd.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_pcd.pcdseq := rcd_lads_sal_ord_pcd.pcdseq + 1;
      rcd_lads_sal_ord_pcd.ccins := lics_inbound_utility.get_variable('CCINS');
      rcd_lads_sal_ord_pcd.ccins_bezei := lics_inbound_utility.get_variable('CCINS_BEZEI');
      rcd_lads_sal_ord_pcd.ccnum := lics_inbound_utility.get_variable('CCNUM');
      rcd_lads_sal_ord_pcd.exdatbi := lics_inbound_utility.get_variable('EXDATBI');
      rcd_lads_sal_ord_pcd.ccname := lics_inbound_utility.get_variable('CCNAME');
      rcd_lads_sal_ord_pcd.fakwr := lics_inbound_utility.get_number('FAKWR',null);

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
      if rcd_lads_sal_ord_pcd.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PCD.BELNR');
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

      insert into lads_sal_ord_pcd
         (belnr,
          pcdseq,
          ccins,
          ccins_bezei,
          ccnum,
          exdatbi,
          ccname,
          fakwr)
      values
         (rcd_lads_sal_ord_pcd.belnr,
          rcd_lads_sal_ord_pcd.pcdseq,
          rcd_lads_sal_ord_pcd.ccins,
          rcd_lads_sal_ord_pcd.ccins_bezei,
          rcd_lads_sal_ord_pcd.ccnum,
          rcd_lads_sal_ord_pcd.exdatbi,
          rcd_lads_sal_ord_pcd.ccname,
          rcd_lads_sal_ord_pcd.fakwr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pcd;

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
      rcd_lads_sal_ord_txi.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_txi.txiseq := rcd_lads_sal_ord_txi.txiseq + 1;
      rcd_lads_sal_ord_txi.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_sal_ord_txi.tsspras := lics_inbound_utility.get_variable('TSSPRAS');
      rcd_lads_sal_ord_txi.tsspras_iso := lics_inbound_utility.get_variable('TSSPRAS_ISO');
      rcd_lads_sal_ord_txi.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_sal_ord_txi.tdobname := lics_inbound_utility.get_variable('TDOBNAME');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_txt.txtseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_txi.belnr is null then
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

      insert into lads_sal_ord_txi
         (belnr,
          txiseq,
          tdid,
          tsspras,
          tsspras_iso,
          tdobject,
          tdobname)
      values
         (rcd_lads_sal_ord_txi.belnr,
          rcd_lads_sal_ord_txi.txiseq,
          rcd_lads_sal_ord_txi.tdid,
          rcd_lads_sal_ord_txi.tsspras,
          rcd_lads_sal_ord_txi.tsspras_iso,
          rcd_lads_sal_ord_txi.tdobject,
          rcd_lads_sal_ord_txi.tdobname);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_txi;

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
      rcd_lads_sal_ord_txt.belnr := rcd_lads_sal_ord_txi.belnr;
      rcd_lads_sal_ord_txt.txiseq := rcd_lads_sal_ord_txi.txiseq;
      rcd_lads_sal_ord_txt.txtseq := rcd_lads_sal_ord_txt.txtseq + 1;
      rcd_lads_sal_ord_txt.tdline := lics_inbound_utility.get_variable('TDLINE');
      rcd_lads_sal_ord_txt.tdformat := lics_inbound_utility.get_variable('TDFORMAT');

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
      if rcd_lads_sal_ord_txt.belnr is null then
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

      insert into lads_sal_ord_txt
         (belnr,
          txiseq,
          txtseq,
          tdline,
          tdformat)
      values
         (rcd_lads_sal_ord_txt.belnr,
          rcd_lads_sal_ord_txt.txiseq,
          rcd_lads_sal_ord_txt.txtseq,
          rcd_lads_sal_ord_txt.tdline,
          rcd_lads_sal_ord_txt.tdformat);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_txt;

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
      rcd_lads_sal_ord_gen.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_gen.genseq := rcd_lads_sal_ord_gen.genseq + 1;
      rcd_lads_sal_ord_gen.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_lads_sal_ord_gen.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_sal_ord_gen.pstyp := lics_inbound_utility.get_variable('PSTYP');
      rcd_lads_sal_ord_gen.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_sal_ord_gen.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_sal_ord_gen.menee := lics_inbound_utility.get_variable('MENEE');
      rcd_lads_sal_ord_gen.bmng2 := lics_inbound_utility.get_variable('BMNG2');
      rcd_lads_sal_ord_gen.pmene := lics_inbound_utility.get_variable('PMENE');
      rcd_lads_sal_ord_gen.abftz := lics_inbound_utility.get_variable('ABFTZ');
      rcd_lads_sal_ord_gen.vprei := lics_inbound_utility.get_variable('VPREI');
      rcd_lads_sal_ord_gen.peinh := lics_inbound_utility.get_variable('PEINH');
      rcd_lads_sal_ord_gen.netwr := lics_inbound_utility.get_variable('NETWR');
      rcd_lads_sal_ord_gen.anetw := lics_inbound_utility.get_variable('ANETW');
      rcd_lads_sal_ord_gen.skfbp := lics_inbound_utility.get_variable('SKFBP');
      rcd_lads_sal_ord_gen.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_sal_ord_gen.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_sal_ord_gen.einkz := lics_inbound_utility.get_variable('EINKZ');
      rcd_lads_sal_ord_gen.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_sal_ord_gen.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_sal_ord_gen.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_sal_ord_gen.uepos := lics_inbound_utility.get_variable('UEPOS');
      rcd_lads_sal_ord_gen.grkor := lics_inbound_utility.get_variable('GRKOR');
      rcd_lads_sal_ord_gen.evers := lics_inbound_utility.get_variable('EVERS');
      rcd_lads_sal_ord_gen.bpumn := lics_inbound_utility.get_number('BPUMN',null);
      rcd_lads_sal_ord_gen.bpumz := lics_inbound_utility.get_number('BPUMZ',null);
      rcd_lads_sal_ord_gen.abgru := lics_inbound_utility.get_variable('ABGRU');
      rcd_lads_sal_ord_gen.abgrt := lics_inbound_utility.get_variable('ABGRT');
      rcd_lads_sal_ord_gen.antlf := lics_inbound_utility.get_variable('ANTLF');
      rcd_lads_sal_ord_gen.fixmg := lics_inbound_utility.get_variable('FIXMG');
      rcd_lads_sal_ord_gen.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_sal_ord_gen.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_sal_ord_gen.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_lads_sal_ord_gen.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_sal_ord_gen.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_sal_ord_gen.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_sal_ord_gen.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_sal_ord_gen.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_lads_sal_ord_gen.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_lads_sal_ord_gen.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_sal_ord_gen.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_sal_ord_gen.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_sal_ord_gen.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_sal_ord_gen.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_sal_ord_gen.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_sal_ord_gen.valtg := lics_inbound_utility.get_number('VALTG',null);
      rcd_lads_sal_ord_gen.hipos := lics_inbound_utility.get_number('HIPOS',null);
      rcd_lads_sal_ord_gen.hievw := lics_inbound_utility.get_variable('HIEVW');
      rcd_lads_sal_ord_gen.posguid := lics_inbound_utility.get_variable('POSGUID');
      rcd_lads_sal_ord_gen.zzlogpoint := lics_inbound_utility.get_variable('ZZLOGPOINT');
      rcd_lads_sal_ord_gen.zzhomopal := lics_inbound_utility.get_variable('ZZHOMOPAL');
      rcd_lads_sal_ord_gen.zzhomolay := lics_inbound_utility.get_variable('ZZHOMOLAY');
      rcd_lads_sal_ord_gen.zzloosecas := lics_inbound_utility.get_variable('ZZLOOSECAS');
      rcd_lads_sal_ord_gen.zzcond05 := lics_inbound_utility.get_variable('ZZCOND05');
      rcd_lads_sal_ord_gen.zzcond06 := lics_inbound_utility.get_variable('ZZCOND06');
      rcd_lads_sal_ord_gen.zzcond07 := lics_inbound_utility.get_variable('ZZCOND07');
      rcd_lads_sal_ord_gen.zzcond08 := lics_inbound_utility.get_variable('ZZCOND08');
      rcd_lads_sal_ord_gen.zzcond09 := lics_inbound_utility.get_variable('ZZCOND09');
      rcd_lads_sal_ord_gen.zzcond10 := lics_inbound_utility.get_variable('ZZCOND10');
      rcd_lads_sal_ord_gen.zzpalspace := lics_inbound_utility.get_variable('ZZPALSPACE');
      rcd_lads_sal_ord_gen.zzpalbas01 := lics_inbound_utility.get_variable('ZZPALBAS01');
      rcd_lads_sal_ord_gen.zzpalbas02 := lics_inbound_utility.get_variable('ZZPALBAS02');
      rcd_lads_sal_ord_gen.zzpalbas03 := lics_inbound_utility.get_variable('ZZPALBAS03');
      rcd_lads_sal_ord_gen.zzpalbas04 := lics_inbound_utility.get_variable('ZZPALBAS04');
      rcd_lads_sal_ord_gen.zzpalbas05 := lics_inbound_utility.get_variable('ZZPALBAS05');
      rcd_lads_sal_ord_gen.zzbrgew := lics_inbound_utility.get_variable('ZZBRGEW');
      rcd_lads_sal_ord_gen.zzweightpal := lics_inbound_utility.get_variable('ZZWEIGHTPAL');
      rcd_lads_sal_ord_gen.zzlogpoint_f := lics_inbound_utility.get_variable('ZZLOGPOINT_F');
      rcd_lads_sal_ord_gen.zzhomopal_f := lics_inbound_utility.get_variable('ZZHOMOPAL_F');
      rcd_lads_sal_ord_gen.zzhomolay_f := lics_inbound_utility.get_variable('ZZHOMOLAY_F');
      rcd_lads_sal_ord_gen.zzloosecas_f := lics_inbound_utility.get_variable('ZZLOOSECAS_F');
      rcd_lads_sal_ord_gen.zzcond05_f := lics_inbound_utility.get_variable('ZZCOND05_F');
      rcd_lads_sal_ord_gen.zzcond06f := lics_inbound_utility.get_variable('ZZCOND06F');
      rcd_lads_sal_ord_gen.zzcond07_f := lics_inbound_utility.get_variable('ZZCOND07_F');
      rcd_lads_sal_ord_gen.zzcond08_f := lics_inbound_utility.get_variable('ZZCOND08_F');
      rcd_lads_sal_ord_gen.zzcond09_f := lics_inbound_utility.get_variable('ZZCOND09_F');
      rcd_lads_sal_ord_gen.zzcond10_f := lics_inbound_utility.get_variable('ZZCOND10_F');
      rcd_lads_sal_ord_gen.zzpalspace_f := lics_inbound_utility.get_variable('ZZPALSPACE_F');
      rcd_lads_sal_ord_gen.zzpalbas01_f := lics_inbound_utility.get_variable('ZZPALBAS01_F');
      rcd_lads_sal_ord_gen.zzpalbas02_f := lics_inbound_utility.get_variable('ZZPALBAS02_F');
      rcd_lads_sal_ord_gen.zzpalbas03_f := lics_inbound_utility.get_variable('ZZPALBAS03_F');
      rcd_lads_sal_ord_gen.zzpalbas04_f := lics_inbound_utility.get_variable('ZZPALBAS04_F');
      rcd_lads_sal_ord_gen.zzpalbas05_f := lics_inbound_utility.get_variable('ZZPALBAS05_F');
      rcd_lads_sal_ord_gen.zzbrgew_f := lics_inbound_utility.get_variable('ZZBRGEW_F');
      rcd_lads_sal_ord_gen.zzweightpal_f := lics_inbound_utility.get_variable('ZZWEIGHTPAL_F');
      rcd_lads_sal_ord_gen.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
      rcd_lads_sal_ord_gen.zzmeins02 := lics_inbound_utility.get_variable('ZZMEINS02');
      rcd_lads_sal_ord_gen.zzmeins03 := lics_inbound_utility.get_variable('ZZMEINS03');
      rcd_lads_sal_ord_gen.zzmeins04 := lics_inbound_utility.get_variable('ZZMEINS04');
      rcd_lads_sal_ord_gen.zzmeins05 := lics_inbound_utility.get_variable('ZZMEINS05');
      rcd_lads_sal_ord_gen.zzweightuom := lics_inbound_utility.get_variable('ZZWEIGHTUOM');
      rcd_lads_sal_ord_gen.zzmvgr1 := lics_inbound_utility.get_variable('ZZMVGR1');
      rcd_lads_sal_ord_gen.zzqtypaluom := lics_inbound_utility.get_variable('ZZQTYPALUOM');
      rcd_lads_sal_ord_gen.zzpcbqty := lics_inbound_utility.get_variable('ZZPCBQTY');
      rcd_lads_sal_ord_gen.zzmatwa := lics_inbound_utility.get_variable('ZZMATWA');
      rcd_lads_sal_ord_gen.zzordrspstatus_l := lics_inbound_utility.get_variable('ZZORDRSPSTATUS_L');
      rcd_lads_sal_ord_gen.zzean_cu := lics_inbound_utility.get_variable('ZZEAN_CU');
      rcd_lads_sal_ord_gen.zzmenge_in_pc := lics_inbound_utility.get_variable('ZZMENGE_IN_PC');
      rcd_lads_sal_ord_gen.posex_id := lics_inbound_utility.get_variable('POSEX_ID');
      rcd_lads_sal_ord_gen.config_id := lics_inbound_utility.get_variable('CONFIG_ID');
      rcd_lads_sal_ord_gen.inst_id := lics_inbound_utility.get_variable('INST_ID');
      rcd_lads_sal_ord_gen.qualf := lics_inbound_utility.get_number('QUALF',null);
      rcd_lads_sal_ord_gen.icc := lics_inbound_utility.get_number('ICC',null);
      rcd_lads_sal_ord_gen.moi := lics_inbound_utility.get_variable('MOI');
      rcd_lads_sal_ord_gen.pri := lics_inbound_utility.get_variable('PRI');
      rcd_lads_sal_ord_gen.acn := lics_inbound_utility.get_variable('ACN');
      rcd_lads_sal_ord_gen.function := lics_inbound_utility.get_variable('FUNCTION');
      rcd_lads_sal_ord_gen.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_sal_ord_gen.tdobname := lics_inbound_utility.get_variable('TDOBNAME');
      rcd_lads_sal_ord_gen.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_sal_ord_gen.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_sal_ord_gen.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_sal_ord_gen.langua_iso := lics_inbound_utility.get_variable('LANGUA_ISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_sog.sogseq := 0;
      rcd_lads_sal_ord_irf.irfseq := 0;
      rcd_lads_sal_ord_iad.iadseq := 0;
      rcd_lads_sal_ord_idt.idtseq := 0;
      rcd_lads_sal_ord_ita.itaseq := 0;
      rcd_lads_sal_ord_ico.icoseq := 0;
      rcd_lads_sal_ord_isc.iscseq := 0;
      rcd_lads_sal_ord_ipn.ipnseq := 0;
      rcd_lads_sal_ord_iid.iidseq := 0;
      rcd_lads_sal_ord_igt.igtseq := 0;
      rcd_lads_sal_ord_itd.itdseq := 0;
      rcd_lads_sal_ord_itp.itpseq := 0;
      rcd_lads_sal_ord_idd.iddseq := 0;
      rcd_lads_sal_ord_itx.itxseq := 0;
      rcd_lads_sal_ord_iss.issseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_gen.belnr is null then
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

      insert into lads_sal_ord_gen
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
          langua_iso)
      values
         (rcd_lads_sal_ord_gen.belnr,
          rcd_lads_sal_ord_gen.genseq,
          rcd_lads_sal_ord_gen.posex,
          rcd_lads_sal_ord_gen.action,
          rcd_lads_sal_ord_gen.pstyp,
          rcd_lads_sal_ord_gen.kzabs,
          rcd_lads_sal_ord_gen.menge,
          rcd_lads_sal_ord_gen.menee,
          rcd_lads_sal_ord_gen.bmng2,
          rcd_lads_sal_ord_gen.pmene,
          rcd_lads_sal_ord_gen.abftz,
          rcd_lads_sal_ord_gen.vprei,
          rcd_lads_sal_ord_gen.peinh,
          rcd_lads_sal_ord_gen.netwr,
          rcd_lads_sal_ord_gen.anetw,
          rcd_lads_sal_ord_gen.skfbp,
          rcd_lads_sal_ord_gen.ntgew,
          rcd_lads_sal_ord_gen.gewei,
          rcd_lads_sal_ord_gen.einkz,
          rcd_lads_sal_ord_gen.curcy,
          rcd_lads_sal_ord_gen.preis,
          rcd_lads_sal_ord_gen.matkl,
          rcd_lads_sal_ord_gen.uepos,
          rcd_lads_sal_ord_gen.grkor,
          rcd_lads_sal_ord_gen.evers,
          rcd_lads_sal_ord_gen.bpumn,
          rcd_lads_sal_ord_gen.bpumz,
          rcd_lads_sal_ord_gen.abgru,
          rcd_lads_sal_ord_gen.abgrt,
          rcd_lads_sal_ord_gen.antlf,
          rcd_lads_sal_ord_gen.fixmg,
          rcd_lads_sal_ord_gen.kzazu,
          rcd_lads_sal_ord_gen.brgew,
          rcd_lads_sal_ord_gen.pstyv,
          rcd_lads_sal_ord_gen.empst,
          rcd_lads_sal_ord_gen.abtnr,
          rcd_lads_sal_ord_gen.abrvw,
          rcd_lads_sal_ord_gen.werks,
          rcd_lads_sal_ord_gen.lprio,
          rcd_lads_sal_ord_gen.lprio_bez,
          rcd_lads_sal_ord_gen.route,
          rcd_lads_sal_ord_gen.route_bez,
          rcd_lads_sal_ord_gen.lgort,
          rcd_lads_sal_ord_gen.vstel,
          rcd_lads_sal_ord_gen.delco,
          rcd_lads_sal_ord_gen.matnr,
          rcd_lads_sal_ord_gen.valtg,
          rcd_lads_sal_ord_gen.hipos,
          rcd_lads_sal_ord_gen.hievw,
          rcd_lads_sal_ord_gen.posguid,
          rcd_lads_sal_ord_gen.zzlogpoint,
          rcd_lads_sal_ord_gen.zzhomopal,
          rcd_lads_sal_ord_gen.zzhomolay,
          rcd_lads_sal_ord_gen.zzloosecas,
          rcd_lads_sal_ord_gen.zzcond05,
          rcd_lads_sal_ord_gen.zzcond06,
          rcd_lads_sal_ord_gen.zzcond07,
          rcd_lads_sal_ord_gen.zzcond08,
          rcd_lads_sal_ord_gen.zzcond09,
          rcd_lads_sal_ord_gen.zzcond10,
          rcd_lads_sal_ord_gen.zzpalspace,
          rcd_lads_sal_ord_gen.zzpalbas01,
          rcd_lads_sal_ord_gen.zzpalbas02,
          rcd_lads_sal_ord_gen.zzpalbas03,
          rcd_lads_sal_ord_gen.zzpalbas04,
          rcd_lads_sal_ord_gen.zzpalbas05,
          rcd_lads_sal_ord_gen.zzbrgew,
          rcd_lads_sal_ord_gen.zzweightpal,
          rcd_lads_sal_ord_gen.zzlogpoint_f,
          rcd_lads_sal_ord_gen.zzhomopal_f,
          rcd_lads_sal_ord_gen.zzhomolay_f,
          rcd_lads_sal_ord_gen.zzloosecas_f,
          rcd_lads_sal_ord_gen.zzcond05_f,
          rcd_lads_sal_ord_gen.zzcond06f,
          rcd_lads_sal_ord_gen.zzcond07_f,
          rcd_lads_sal_ord_gen.zzcond08_f,
          rcd_lads_sal_ord_gen.zzcond09_f,
          rcd_lads_sal_ord_gen.zzcond10_f,
          rcd_lads_sal_ord_gen.zzpalspace_f,
          rcd_lads_sal_ord_gen.zzpalbas01_f,
          rcd_lads_sal_ord_gen.zzpalbas02_f,
          rcd_lads_sal_ord_gen.zzpalbas03_f,
          rcd_lads_sal_ord_gen.zzpalbas04_f,
          rcd_lads_sal_ord_gen.zzpalbas05_f,
          rcd_lads_sal_ord_gen.zzbrgew_f,
          rcd_lads_sal_ord_gen.zzweightpal_f,
          rcd_lads_sal_ord_gen.zzmeins01,
          rcd_lads_sal_ord_gen.zzmeins02,
          rcd_lads_sal_ord_gen.zzmeins03,
          rcd_lads_sal_ord_gen.zzmeins04,
          rcd_lads_sal_ord_gen.zzmeins05,
          rcd_lads_sal_ord_gen.zzweightuom,
          rcd_lads_sal_ord_gen.zzmvgr1,
          rcd_lads_sal_ord_gen.zzqtypaluom,
          rcd_lads_sal_ord_gen.zzpcbqty,
          rcd_lads_sal_ord_gen.zzmatwa,
          rcd_lads_sal_ord_gen.zzordrspstatus_l,
          rcd_lads_sal_ord_gen.zzean_cu,
          rcd_lads_sal_ord_gen.zzmenge_in_pc,
          rcd_lads_sal_ord_gen.posex_id,
          rcd_lads_sal_ord_gen.config_id,
          rcd_lads_sal_ord_gen.inst_id,
          rcd_lads_sal_ord_gen.qualf,
          rcd_lads_sal_ord_gen.icc,
          rcd_lads_sal_ord_gen.moi,
          rcd_lads_sal_ord_gen.pri,
          rcd_lads_sal_ord_gen.acn,
          rcd_lads_sal_ord_gen.function,
          rcd_lads_sal_ord_gen.tdobject,
          rcd_lads_sal_ord_gen.tdobname,
          rcd_lads_sal_ord_gen.tdid,
          rcd_lads_sal_ord_gen.tdspras,
          rcd_lads_sal_ord_gen.tdtexttype,
          rcd_lads_sal_ord_gen.langua_iso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_gen;

   /**************************************************/
   /* This procedure performs the record SOG routine */
   /**************************************************/
   procedure process_record_sog(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SOG', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_sog.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_sog.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_sog.sogseq := rcd_lads_sal_ord_sog.sogseq + 1;
      rcd_lads_sal_ord_sog.z_lcdid := lics_inbound_utility.get_variable('Z_LCDID');
      rcd_lads_sal_ord_sog.z_lcdnr := lics_inbound_utility.get_variable('Z_LCDNR');
      rcd_lads_sal_ord_sog.z_lcddsc := lics_inbound_utility.get_variable('Z_LCDDSC');

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
      if rcd_lads_sal_ord_sog.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - SOG.BELNR');
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

      insert into lads_sal_ord_sog
         (belnr,
          genseq,
          sogseq,
          z_lcdid,
          z_lcdnr,
          z_lcddsc)
      values
         (rcd_lads_sal_ord_sog.belnr,
          rcd_lads_sal_ord_sog.genseq,
          rcd_lads_sal_ord_sog.sogseq,
          rcd_lads_sal_ord_sog.z_lcdid,
          rcd_lads_sal_ord_sog.z_lcdnr,
          rcd_lads_sal_ord_sog.z_lcddsc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_sog;

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
      rcd_lads_sal_ord_irf.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_irf.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_irf.irfseq := rcd_lads_sal_ord_irf.irfseq + 1;
      rcd_lads_sal_ord_irf.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_irf.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_lads_sal_ord_irf.zeile := lics_inbound_utility.get_variable('ZEILE');
      rcd_lads_sal_ord_irf.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_sal_ord_irf.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_lads_sal_ord_irf.bsark := lics_inbound_utility.get_variable('BSARK');
      rcd_lads_sal_ord_irf.ihrez := lics_inbound_utility.get_variable('IHREZ');

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
      if rcd_lads_sal_ord_irf.belnr is null then
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

      insert into lads_sal_ord_irf
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
         (rcd_lads_sal_ord_irf.belnr,
          rcd_lads_sal_ord_irf.genseq,
          rcd_lads_sal_ord_irf.irfseq,
          rcd_lads_sal_ord_irf.qualf,
          rcd_lads_sal_ord_irf.refnr,
          rcd_lads_sal_ord_irf.zeile,
          rcd_lads_sal_ord_irf.datum,
          rcd_lads_sal_ord_irf.uzeit,
          rcd_lads_sal_ord_irf.bsark,
          rcd_lads_sal_ord_irf.ihrez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_irf;

   /**************************************************/
   /* This procedure performs the record IAD routine */
   /**************************************************/
   procedure process_record_iad(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IAD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_iad.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_iad.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_iad.iadseq := rcd_lads_sal_ord_iad.iadseq + 1;
      rcd_lads_sal_ord_iad.addimatnr := lics_inbound_utility.get_variable('ADDIMATNR');
      rcd_lads_sal_ord_iad.addinumber := lics_inbound_utility.get_number('ADDINUMBER',null);
      rcd_lads_sal_ord_iad.addivkme := lics_inbound_utility.get_number('ADDIVKME',null);
      rcd_lads_sal_ord_iad.addifm := lics_inbound_utility.get_variable('ADDIFM');
      rcd_lads_sal_ord_iad.addifm_txt := lics_inbound_utility.get_variable('ADDIFM_TXT');
      rcd_lads_sal_ord_iad.addiklart := lics_inbound_utility.get_variable('ADDIKLART');
      rcd_lads_sal_ord_iad.addiklart_txt := lics_inbound_utility.get_variable('ADDIKLART_TXT');
      rcd_lads_sal_ord_iad.addiclass := lics_inbound_utility.get_variable('ADDICLASS');
      rcd_lads_sal_ord_iad.addiclass_txt := lics_inbound_utility.get_variable('ADDICLASS_TXT');
      rcd_lads_sal_ord_iad.addiidoc := lics_inbound_utility.get_variable('ADDIIDOC');
      rcd_lads_sal_ord_iad.addimatnr_external := lics_inbound_utility.get_variable('ADDIMATNR_EXTERNAL');
      rcd_lads_sal_ord_iad.addimatnr_version := lics_inbound_utility.get_variable('ADDIMATNR_VERSION');
      rcd_lads_sal_ord_iad.addimatnr_guid := lics_inbound_utility.get_variable('ADDIMATNR_GUID');

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
      if rcd_lads_sal_ord_iad.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IAD.BELNR');
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

      insert into lads_sal_ord_iad
         (belnr,
          genseq,
          iadseq,
          addimatnr,
          addinumber,
          addivkme,
          addifm,
          addifm_txt,
          addiklart,
          addiklart_txt,
          addiclass,
          addiclass_txt,
          addiidoc,
          addimatnr_external,
          addimatnr_version,
          addimatnr_guid)
      values
         (rcd_lads_sal_ord_iad.belnr,
          rcd_lads_sal_ord_iad.genseq,
          rcd_lads_sal_ord_iad.iadseq,
          rcd_lads_sal_ord_iad.addimatnr,
          rcd_lads_sal_ord_iad.addinumber,
          rcd_lads_sal_ord_iad.addivkme,
          rcd_lads_sal_ord_iad.addifm,
          rcd_lads_sal_ord_iad.addifm_txt,
          rcd_lads_sal_ord_iad.addiklart,
          rcd_lads_sal_ord_iad.addiklart_txt,
          rcd_lads_sal_ord_iad.addiclass,
          rcd_lads_sal_ord_iad.addiclass_txt,
          rcd_lads_sal_ord_iad.addiidoc,
          rcd_lads_sal_ord_iad.addimatnr_external,
          rcd_lads_sal_ord_iad.addimatnr_version,
          rcd_lads_sal_ord_iad.addimatnr_guid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_iad;

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
      rcd_lads_sal_ord_idt.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_idt.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_idt.idtseq := rcd_lads_sal_ord_idt.idtseq + 1;
      rcd_lads_sal_ord_idt.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_lads_sal_ord_idt.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_sal_ord_idt.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_sal_ord_idt.belnr is null then
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

      insert into lads_sal_ord_idt
         (belnr,
          genseq,
          idtseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_lads_sal_ord_idt.belnr,
          rcd_lads_sal_ord_idt.genseq,
          rcd_lads_sal_ord_idt.idtseq,
          rcd_lads_sal_ord_idt.iddat,
          rcd_lads_sal_ord_idt.datum,
          rcd_lads_sal_ord_idt.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_idt;

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
      rcd_lads_sal_ord_ita.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_ita.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_ita.itaseq:= rcd_lads_sal_ord_ita.itaseq + 1;
      rcd_lads_sal_ord_ita.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_sal_ord_ita.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_sal_ord_ita.mwsbt := lics_inbound_utility.get_variable('MWSBT');
      rcd_lads_sal_ord_ita.txjcd := lics_inbound_utility.get_variable('TXJCD');
      rcd_lads_sal_ord_ita.ktext := lics_inbound_utility.get_variable('KTEXT');

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
      if rcd_lads_sal_ord_ita.belnr is null then
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

      insert into lads_sal_ord_ita
         (belnr,
          genseq,
          itaseq,
          mwskz,
          msatz,
          mwsbt,
          txjcd,
          ktext)
      values
         (rcd_lads_sal_ord_ita.belnr,
          rcd_lads_sal_ord_ita.genseq,
          rcd_lads_sal_ord_ita.itaseq,
          rcd_lads_sal_ord_ita.mwskz,
          rcd_lads_sal_ord_ita.msatz,
          rcd_lads_sal_ord_ita.mwsbt,
          rcd_lads_sal_ord_ita.txjcd,
          rcd_lads_sal_ord_ita.ktext);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ita;

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
      rcd_lads_sal_ord_ico.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_ico.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_ico.icoseq := rcd_lads_sal_ord_ico.icoseq + 1;
      rcd_lads_sal_ord_ico.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_lads_sal_ord_ico.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_sal_ord_ico.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_lads_sal_ord_ico.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_sal_ord_ico.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_lads_sal_ord_ico.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_lads_sal_ord_ico.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_lads_sal_ord_ico.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_lads_sal_ord_ico.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_lads_sal_ord_ico.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_sal_ord_ico.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_sal_ord_ico.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_sal_ord_ico.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_sal_ord_ico.koein := lics_inbound_utility.get_variable('KOEIN');
      rcd_lads_sal_ord_ico.curtp := lics_inbound_utility.get_variable('CURTP');
      rcd_lads_sal_ord_ico.kobas := lics_inbound_utility.get_variable('KOBAS');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_ips.ipsseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_ico.belnr is null then
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

      insert into lads_sal_ord_ico
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
         (rcd_lads_sal_ord_ico.belnr,
          rcd_lads_sal_ord_ico.genseq,
          rcd_lads_sal_ord_ico.icoseq,
          rcd_lads_sal_ord_ico.alckz,
          rcd_lads_sal_ord_ico.kschl,
          rcd_lads_sal_ord_ico.kotxt,
          rcd_lads_sal_ord_ico.betrg,
          rcd_lads_sal_ord_ico.kperc,
          rcd_lads_sal_ord_ico.krate,
          rcd_lads_sal_ord_ico.uprbs,
          rcd_lads_sal_ord_ico.meaun,
          rcd_lads_sal_ord_ico.kobtr,
          rcd_lads_sal_ord_ico.menge,
          rcd_lads_sal_ord_ico.preis,
          rcd_lads_sal_ord_ico.mwskz,
          rcd_lads_sal_ord_ico.msatz,
          rcd_lads_sal_ord_ico.koein,
          rcd_lads_sal_ord_ico.curtp,
          rcd_lads_sal_ord_ico.kobas);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ico;

   /**************************************************/
   /* This procedure performs the record IPS routine */
   /**************************************************/
   procedure process_record_ips(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IPS', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_ips.belnr := rcd_lads_sal_ord_ico.belnr;
      rcd_lads_sal_ord_ips.genseq := rcd_lads_sal_ord_ico.genseq;
      rcd_lads_sal_ord_ips.icoseq := rcd_lads_sal_ord_ico.icoseq;
      rcd_lads_sal_ord_ips.ipsseq := rcd_lads_sal_ord_ips.ipsseq + 1;
      rcd_lads_sal_ord_ips.kstbm := lics_inbound_utility.get_number('KSTBM',null);
      rcd_lads_sal_ord_ips.kbetr := lics_inbound_utility.get_number('KBETR',null);

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
      if rcd_lads_sal_ord_ips.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IPS.BELNR');
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

      insert into lads_sal_ord_ips
         (belnr,
          genseq,
          icoseq,
          ipsseq,
          kstbm,
          kbetr)
      values
         (rcd_lads_sal_ord_ips.belnr,
          rcd_lads_sal_ord_ips.genseq,
          rcd_lads_sal_ord_ips.icoseq,
          rcd_lads_sal_ord_ips.ipsseq,
          rcd_lads_sal_ord_ips.kstbm,
          rcd_lads_sal_ord_ips.kbetr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ips;

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
      rcd_lads_sal_ord_isc.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_isc.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_isc.iscseq := rcd_lads_sal_ord_isc.iscseq + 1;
      rcd_lads_sal_ord_isc.wmeng := lics_inbound_utility.get_variable('WMENG');
      rcd_lads_sal_ord_isc.ameng := lics_inbound_utility.get_variable('AMENG');
      rcd_lads_sal_ord_isc.edatu := lics_inbound_utility.get_variable('EDATU');
      rcd_lads_sal_ord_isc.ezeit := lics_inbound_utility.get_variable('EZEIT');
      rcd_lads_sal_ord_isc.edatu_old := lics_inbound_utility.get_variable('EDATU_OLD');
      rcd_lads_sal_ord_isc.ezeit_old := lics_inbound_utility.get_variable('EZEIT_OLD');
      rcd_lads_sal_ord_isc.action := lics_inbound_utility.get_variable('ACTION');

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
      if rcd_lads_sal_ord_isc.belnr is null then
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

      insert into lads_sal_ord_isc
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
         (rcd_lads_sal_ord_isc.belnr,
          rcd_lads_sal_ord_isc.genseq,
          rcd_lads_sal_ord_isc.iscseq,
          rcd_lads_sal_ord_isc.wmeng,
          rcd_lads_sal_ord_isc.ameng,
          rcd_lads_sal_ord_isc.edatu,
          rcd_lads_sal_ord_isc.ezeit,
          rcd_lads_sal_ord_isc.edatu_old,
          rcd_lads_sal_ord_isc.ezeit_old,
          rcd_lads_sal_ord_isc.action);

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
      rcd_lads_sal_ord_ipn.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_ipn.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_ipn.ipnseq := rcd_lads_sal_ord_ipn.ipnseq + 1;
      rcd_lads_sal_ord_ipn.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_sal_ord_ipn.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_lads_sal_ord_ipn.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_sal_ord_ipn.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_sal_ord_ipn.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_sal_ord_ipn.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_sal_ord_ipn.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_sal_ord_ipn.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_sal_ord_ipn.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_lads_sal_ord_ipn.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_lads_sal_ord_ipn.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_sal_ord_ipn.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_lads_sal_ord_ipn.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_lads_sal_ord_ipn.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_lads_sal_ord_ipn.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_sal_ord_ipn.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_sal_ord_ipn.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_lads_sal_ord_ipn.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_lads_sal_ord_ipn.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_sal_ord_ipn.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_lads_sal_ord_ipn.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_lads_sal_ord_ipn.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_lads_sal_ord_ipn.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_lads_sal_ord_ipn.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_lads_sal_ord_ipn.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_sal_ord_ipn.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_sal_ord_ipn.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_sal_ord_ipn.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_lads_sal_ord_ipn.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_lads_sal_ord_ipn.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_lads_sal_ord_ipn.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_lads_sal_ord_ipn.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_lads_sal_ord_ipn.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_lads_sal_ord_ipn.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_lads_sal_ord_ipn.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_sal_ord_ipn.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_sal_ord_ipn.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_lads_sal_ord_ipn.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_lads_sal_ord_ipn.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_lads_sal_ord_ipn.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_sal_ord_ipn.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_lads_sal_ord_ipn.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_lads_sal_ord_ipn.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_lads_sal_ord_ipn.title := lics_inbound_utility.get_variable('TITLE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_ipd.ipdseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_ipn.belnr is null then
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

      insert into lads_sal_ord_ipn
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
         (rcd_lads_sal_ord_ipn.belnr,
          rcd_lads_sal_ord_ipn.genseq,
          rcd_lads_sal_ord_ipn.ipnseq,
          rcd_lads_sal_ord_ipn.parvw,
          rcd_lads_sal_ord_ipn.partn,
          rcd_lads_sal_ord_ipn.lifnr,
          rcd_lads_sal_ord_ipn.name1,
          rcd_lads_sal_ord_ipn.name2,
          rcd_lads_sal_ord_ipn.name3,
          rcd_lads_sal_ord_ipn.name4,
          rcd_lads_sal_ord_ipn.stras,
          rcd_lads_sal_ord_ipn.strs2,
          rcd_lads_sal_ord_ipn.pfach,
          rcd_lads_sal_ord_ipn.ort01,
          rcd_lads_sal_ord_ipn.counc,
          rcd_lads_sal_ord_ipn.pstlz,
          rcd_lads_sal_ord_ipn.pstl2,
          rcd_lads_sal_ord_ipn.land1,
          rcd_lads_sal_ord_ipn.ablad,
          rcd_lads_sal_ord_ipn.pernr,
          rcd_lads_sal_ord_ipn.parnr,
          rcd_lads_sal_ord_ipn.telf1,
          rcd_lads_sal_ord_ipn.telf2,
          rcd_lads_sal_ord_ipn.telbx,
          rcd_lads_sal_ord_ipn.telfx,
          rcd_lads_sal_ord_ipn.teltx,
          rcd_lads_sal_ord_ipn.telx1,
          rcd_lads_sal_ord_ipn.spras,
          rcd_lads_sal_ord_ipn.anred,
          rcd_lads_sal_ord_ipn.ort02,
          rcd_lads_sal_ord_ipn.hausn,
          rcd_lads_sal_ord_ipn.stock,
          rcd_lads_sal_ord_ipn.regio,
          rcd_lads_sal_ord_ipn.parge,
          rcd_lads_sal_ord_ipn.isoal,
          rcd_lads_sal_ord_ipn.isonu,
          rcd_lads_sal_ord_ipn.fcode,
          rcd_lads_sal_ord_ipn.ihrez,
          rcd_lads_sal_ord_ipn.bname,
          rcd_lads_sal_ord_ipn.paorg,
          rcd_lads_sal_ord_ipn.orgtx,
          rcd_lads_sal_ord_ipn.pagru,
          rcd_lads_sal_ord_ipn.knref,
          rcd_lads_sal_ord_ipn.ilnnr,
          rcd_lads_sal_ord_ipn.pfort,
          rcd_lads_sal_ord_ipn.spras_iso,
          rcd_lads_sal_ord_ipn.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ipn;

   /**************************************************/
   /* This procedure performs the record IPD routine */
   /**************************************************/
   procedure process_record_ipd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IPD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_ipd.belnr := rcd_lads_sal_ord_ipn.belnr;
      rcd_lads_sal_ord_ipd.genseq := rcd_lads_sal_ord_ipn.genseq;
      rcd_lads_sal_ord_ipd.ipnseq := rcd_lads_sal_ord_ipn.ipnseq;
      rcd_lads_sal_ord_ipd.ipdseq := rcd_lads_sal_ord_ipd.ipdseq + 1;
      rcd_lads_sal_ord_ipd.qualp := lics_inbound_utility.get_variable('QUALP');
      rcd_lads_sal_ord_ipd.stdpn := lics_inbound_utility.get_variable('STDPN');

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
      if rcd_lads_sal_ord_ipd.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IPD.BELNR');
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

      insert into lads_sal_ord_ipd
         (belnr,
          genseq,
          ipnseq,
          ipdseq,
          qualp,
          stdpn)
      values
         (rcd_lads_sal_ord_ipd.belnr,
          rcd_lads_sal_ord_ipd.genseq,
          rcd_lads_sal_ord_ipd.ipnseq,
          rcd_lads_sal_ord_ipd.ipdseq,
          rcd_lads_sal_ord_ipd.qualp,
          rcd_lads_sal_ord_ipd.stdpn);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ipd;

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
      rcd_lads_sal_ord_iid.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_iid.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_iid.iidseq := rcd_lads_sal_ord_iid.iidseq + 1;
      rcd_lads_sal_ord_iid.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_iid.idtnr := lics_inbound_utility.get_variable('IDTNR');
      rcd_lads_sal_ord_iid.ktext := lics_inbound_utility.get_variable('KTEXT');
      rcd_lads_sal_ord_iid.mfrpn := lics_inbound_utility.get_variable('MFRPN');
      rcd_lads_sal_ord_iid.mfrnr := lics_inbound_utility.get_variable('MFRNR');

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
      if rcd_lads_sal_ord_iid.belnr is null then
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

      insert into lads_sal_ord_iid
         (belnr,
          genseq,
          iidseq,
          qualf,
          idtnr,
          ktext,
          mfrpn,
          mfrnr)
      values
         (rcd_lads_sal_ord_iid.belnr,
          rcd_lads_sal_ord_iid.genseq,
          rcd_lads_sal_ord_iid.iidseq,
          rcd_lads_sal_ord_iid.qualf,
          rcd_lads_sal_ord_iid.idtnr,
          rcd_lads_sal_ord_iid.ktext,
          rcd_lads_sal_ord_iid.mfrpn,
          rcd_lads_sal_ord_iid.mfrnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_iid;

   /**************************************************/
   /* This procedure performs the record IGT routine */
   /**************************************************/
   procedure process_record_igt(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IGT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_igt.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_igt.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_igt.igtseq := rcd_lads_sal_ord_igt.igtseq + 1;
      rcd_lads_sal_ord_igt.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_sal_ord_igt.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_sal_ord_igt.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IGT.BELNR');
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

      insert into lads_sal_ord_igt
         (belnr,
          genseq,
          igtseq,
          tdformat,
          tdline)
      values
         (rcd_lads_sal_ord_igt.belnr,
          rcd_lads_sal_ord_igt.genseq,
          rcd_lads_sal_ord_igt.igtseq,
          rcd_lads_sal_ord_igt.tdformat,
          rcd_lads_sal_ord_igt.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_igt;

   /**************************************************/
   /* This procedure performs the record ITD routine */
   /**************************************************/
   procedure process_record_itd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ITD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_itd.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_itd.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_itd.itdseq := rcd_lads_sal_ord_itd.itdseq + 1;
      rcd_lads_sal_ord_itd.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_itd.lkond := lics_inbound_utility.get_variable('LKOND');
      rcd_lads_sal_ord_itd.lktext := lics_inbound_utility.get_variable('LKTEXT');
      rcd_lads_sal_ord_itd.lprio := lics_inbound_utility.get_number('LPRIO',null);

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
      if rcd_lads_sal_ord_itd.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ITD.BELNR');
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

      insert into lads_sal_ord_itd
         (belnr,
          genseq,
          itdseq,
          qualf,
          lkond,
          lktext,
          lprio)
      values
         (rcd_lads_sal_ord_itd.belnr,
          rcd_lads_sal_ord_itd.genseq,
          rcd_lads_sal_ord_itd.itdseq,
          rcd_lads_sal_ord_itd.qualf,
          rcd_lads_sal_ord_itd.lkond,
          rcd_lads_sal_ord_itd.lktext,
          rcd_lads_sal_ord_itd.lprio);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_itd;

   /**************************************************/
   /* This procedure performs the record ITP routine */
   /**************************************************/
   procedure process_record_itp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ITP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_itp.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_itp.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_itp.itpseq := rcd_lads_sal_ord_itp.itpseq + 1;
      rcd_lads_sal_ord_itp.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_itp.tage := lics_inbound_utility.get_variable('TAGE');
      rcd_lads_sal_ord_itp.prznt := lics_inbound_utility.get_variable('PRZNT');
      rcd_lads_sal_ord_itp.zterm_txt := lics_inbound_utility.get_variable('ZTERM_TXT');

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
      if rcd_lads_sal_ord_itp.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ITP.BELNR');
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

      insert into lads_sal_ord_itp
         (belnr,
          genseq,
          itpseq,
          qualf,
          tage,
          prznt,
          zterm_txt)
      values
         (rcd_lads_sal_ord_itp.belnr,
          rcd_lads_sal_ord_itp.genseq,
          rcd_lads_sal_ord_itp.itpseq,
          rcd_lads_sal_ord_itp.qualf,
          rcd_lads_sal_ord_itp.tage,
          rcd_lads_sal_ord_itp.prznt,
          rcd_lads_sal_ord_itp.zterm_txt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_itp;

   /**************************************************/
   /* This procedure performs the record IDD routine */
   /**************************************************/
   procedure process_record_idd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IDD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_idd.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_idd.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_idd.iddseq := rcd_lads_sal_ord_idd.iddseq + 1;
      rcd_lads_sal_ord_idd.qualz := lics_inbound_utility.get_variable('QUALZ');
      rcd_lads_sal_ord_idd.cusadd := lics_inbound_utility.get_variable('CUSADD');
      rcd_lads_sal_ord_idd.cusadd_bez := lics_inbound_utility.get_variable('CUSADD_BEZ');

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
      if rcd_lads_sal_ord_idd.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IDD.BELNR');
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

      insert into lads_sal_ord_idd
         (belnr,
          genseq,
          iddseq,
          qualz,
          cusadd,
          cusadd_bez)
      values
         (rcd_lads_sal_ord_idd.belnr,
          rcd_lads_sal_ord_idd.genseq,
          rcd_lads_sal_ord_idd.iddseq,
          rcd_lads_sal_ord_idd.qualz,
          rcd_lads_sal_ord_idd.cusadd,
          rcd_lads_sal_ord_idd.cusadd_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_idd;

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
      rcd_lads_sal_ord_itx.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_itx.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_itx.itxseq := rcd_lads_sal_ord_itx.itxseq + 1;
      rcd_lads_sal_ord_itx.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_sal_ord_itx.tsspras := lics_inbound_utility.get_variable('TSSPRAS');
      rcd_lads_sal_ord_itx.tsspras_iso := lics_inbound_utility.get_variable('TSSPRAS_ISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_itt.ittseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_itx.belnr is null then
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

      insert into lads_sal_ord_itx
         (belnr,
          genseq,
          itxseq,
          tdid,
          tsspras,
          tsspras_iso)
      values
         (rcd_lads_sal_ord_itx.belnr,
          rcd_lads_sal_ord_itx.genseq,
          rcd_lads_sal_ord_itx.itxseq,
          rcd_lads_sal_ord_itx.tdid,
          rcd_lads_sal_ord_itx.tsspras,
          rcd_lads_sal_ord_itx.tsspras_iso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_itx;

   /**************************************************/
   /* This procedure performs the record ITT routine */
   /**************************************************/
   procedure process_record_itt(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ITT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_itt.belnr := rcd_lads_sal_ord_itx.belnr;
      rcd_lads_sal_ord_itt.genseq := rcd_lads_sal_ord_itx.genseq;
      rcd_lads_sal_ord_itt.itxseq := rcd_lads_sal_ord_itx.itxseq;
      rcd_lads_sal_ord_itt.ittseq := rcd_lads_sal_ord_itt.ittseq + 1;
      rcd_lads_sal_ord_itt.tdline := lics_inbound_utility.get_variable('TDLINE');
      rcd_lads_sal_ord_itt.tdformat := lics_inbound_utility.get_variable('TDFORMAT');

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
      if rcd_lads_sal_ord_itt.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ITT.BELNR');
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

      insert into lads_sal_ord_itt
         (belnr,
          genseq,
          itxseq,
          ittseq,
          tdline,
          tdformat)
      values
         (rcd_lads_sal_ord_itt.belnr,
          rcd_lads_sal_ord_itt.genseq,
          rcd_lads_sal_ord_itt.itxseq,
          rcd_lads_sal_ord_itt.ittseq,
          rcd_lads_sal_ord_itt.tdline,
          rcd_lads_sal_ord_itt.tdformat);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_itt;

   /**************************************************/
   /* This procedure performs the record ISS routine */
   /**************************************************/
   procedure process_record_iss(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISS', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_iss.belnr := rcd_lads_sal_ord_gen.belnr;
      rcd_lads_sal_ord_iss.genseq := rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_iss.issseq := rcd_lads_sal_ord_iss.issseq + 1;
      rcd_lads_sal_ord_iss.sgtyp := lics_inbound_utility.get_variable('SGTYP');
      rcd_lads_sal_ord_iss.zltyp := lics_inbound_utility.get_variable('ZLTYP');
      rcd_lads_sal_ord_iss.lvalt := lics_inbound_utility.get_variable('LVALT');
      rcd_lads_sal_ord_iss.altno := lics_inbound_utility.get_variable('ALTNO');
      rcd_lads_sal_ord_iss.alref := lics_inbound_utility.get_variable('ALREF');
      rcd_lads_sal_ord_iss.zlart := lics_inbound_utility.get_variable('ZLART');
      rcd_lads_sal_ord_iss.linno := lics_inbound_utility.get_number('LINNO',null);
      rcd_lads_sal_ord_iss.rang := lics_inbound_utility.get_variable('RANG');
      rcd_lads_sal_ord_iss.exgrp := lics_inbound_utility.get_variable('EXGRP');
      rcd_lads_sal_ord_iss.uepos := lics_inbound_utility.get_variable('UEPOS');
      rcd_lads_sal_ord_iss.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_sal_ord_iss.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_sal_ord_iss.menee := lics_inbound_utility.get_variable('MENEE');
      rcd_lads_sal_ord_iss.bmng2 := lics_inbound_utility.get_variable('BMNG2');
      rcd_lads_sal_ord_iss.pmene := lics_inbound_utility.get_variable('PMENE');
      rcd_lads_sal_ord_iss.bpumn := lics_inbound_utility.get_number('BPUMN',null);
      rcd_lads_sal_ord_iss.bpumz := lics_inbound_utility.get_number('BPUMZ',null);
      rcd_lads_sal_ord_iss.vprei := lics_inbound_utility.get_variable('VPREI');
      rcd_lads_sal_ord_iss.peinh := lics_inbound_utility.get_variable('PEINH');
      rcd_lads_sal_ord_iss.netwr := lics_inbound_utility.get_variable('NETWR');
      rcd_lads_sal_ord_iss.anetw := lics_inbound_utility.get_variable('ANETW');
      rcd_lads_sal_ord_iss.skfbp := lics_inbound_utility.get_variable('SKFBP');
      rcd_lads_sal_ord_iss.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_sal_ord_iss.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_sal_ord_iss.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_sal_ord_iss.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_sal_ord_iss.uebto := lics_inbound_utility.get_variable('UEBTO');
      rcd_lads_sal_ord_iss.uebtk := lics_inbound_utility.get_variable('UEBTK');
      rcd_lads_sal_ord_iss.lbnum := lics_inbound_utility.get_variable('LBNUM');
      rcd_lads_sal_ord_iss.ausgb := lics_inbound_utility.get_number('AUSGB',null);
      rcd_lads_sal_ord_iss.frpos := lics_inbound_utility.get_variable('FRPOS');
      rcd_lads_sal_ord_iss.topos := lics_inbound_utility.get_variable('TOPOS');
      rcd_lads_sal_ord_iss.ktxt1 := lics_inbound_utility.get_variable('KTXT1');
      rcd_lads_sal_ord_iss.ktxt2 := lics_inbound_utility.get_variable('KTXT2');
      rcd_lads_sal_ord_iss.pernr := lics_inbound_utility.get_number('PERNR',null);
      rcd_lads_sal_ord_iss.lgart := lics_inbound_utility.get_variable('LGART');
      rcd_lads_sal_ord_iss.stell := lics_inbound_utility.get_number('STELL',null);
      rcd_lads_sal_ord_iss.zwert := lics_inbound_utility.get_variable('ZWERT');
      rcd_lads_sal_ord_iss.formelnr := lics_inbound_utility.get_variable('FORMELNR');
      rcd_lads_sal_ord_iss.frmval1 := lics_inbound_utility.get_number('FRMVAL1',null);
      rcd_lads_sal_ord_iss.frmval2 := lics_inbound_utility.get_number('FRMVAL2',null);
      rcd_lads_sal_ord_iss.frmval3 := lics_inbound_utility.get_number('FRMVAL3',null);
      rcd_lads_sal_ord_iss.frmval4 := lics_inbound_utility.get_number('FRMVAL4',null);
      rcd_lads_sal_ord_iss.frmval5 := lics_inbound_utility.get_number('FRMVAL5',null);
      rcd_lads_sal_ord_iss.userf1_num := lics_inbound_utility.get_number('USERF1_NUM',null);
      rcd_lads_sal_ord_iss.userf2_num := lics_inbound_utility.get_number('USERF2_NUM',null);
      rcd_lads_sal_ord_iss.userf1_txt := lics_inbound_utility.get_variable('USERF1_TXT');
      rcd_lads_sal_ord_iss.userf2_txt := lics_inbound_utility.get_variable('USERF2_TXT');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_isr.isrseq := 0;
      rcd_lads_sal_ord_isd.isdseq := 0;
      rcd_lads_sal_ord_ist.istseq := 0;
      rcd_lads_sal_ord_isn.isnseq := 0;
      rcd_lads_sal_ord_isp.ispseq := 0;
      rcd_lads_sal_ord_iso.isoseq := 0;
      rcd_lads_sal_ord_isi.isiseq := 0;
      rcd_lads_sal_ord_ist.istseq := 0;
      rcd_lads_sal_ord_isx.isxseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_iss.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISS.BELNR');
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

      insert into lads_sal_ord_iss
         (belnr,
          genseq,
          issseq,
          sgtyp,
          zltyp,
          lvalt,
          altno,
          alref,
          zlart,
          linno,
          rang,
          exgrp,
          uepos,
          matkl,
          menge,
          menee,
          bmng2,
          pmene,
          bpumn,
          bpumz,
          vprei,
          peinh,
          netwr,
          anetw,
          skfbp,
          curcy,
          preis,
          action,
          kzabs,
          uebto,
          uebtk,
          lbnum,
          ausgb,
          frpos,
          topos,
          ktxt1,
          ktxt2,
          pernr,
          lgart,
          stell,
          zwert,
          formelnr,
          frmval1,
          frmval2,
          frmval3,
          frmval4,
          frmval5,
          userf1_num,
          userf2_num,
          userf1_txt,
          userf2_txt)
      values
         (rcd_lads_sal_ord_iss.belnr,
          rcd_lads_sal_ord_iss.genseq,
          rcd_lads_sal_ord_iss.issseq,
          rcd_lads_sal_ord_iss.sgtyp,
          rcd_lads_sal_ord_iss.zltyp,
          rcd_lads_sal_ord_iss.lvalt,
          rcd_lads_sal_ord_iss.altno,
          rcd_lads_sal_ord_iss.alref,
          rcd_lads_sal_ord_iss.zlart,
          rcd_lads_sal_ord_iss.linno,
          rcd_lads_sal_ord_iss.rang,
          rcd_lads_sal_ord_iss.exgrp,
          rcd_lads_sal_ord_iss.uepos,
          rcd_lads_sal_ord_iss.matkl,
          rcd_lads_sal_ord_iss.menge,
          rcd_lads_sal_ord_iss.menee,
          rcd_lads_sal_ord_iss.bmng2,
          rcd_lads_sal_ord_iss.pmene,
          rcd_lads_sal_ord_iss.bpumn,
          rcd_lads_sal_ord_iss.bpumz,
          rcd_lads_sal_ord_iss.vprei,
          rcd_lads_sal_ord_iss.peinh,
          rcd_lads_sal_ord_iss.netwr,
          rcd_lads_sal_ord_iss.anetw,
          rcd_lads_sal_ord_iss.skfbp,
          rcd_lads_sal_ord_iss.curcy,
          rcd_lads_sal_ord_iss.preis,
          rcd_lads_sal_ord_iss.action,
          rcd_lads_sal_ord_iss.kzabs,
          rcd_lads_sal_ord_iss.uebto,
          rcd_lads_sal_ord_iss.uebtk,
          rcd_lads_sal_ord_iss.lbnum,
          rcd_lads_sal_ord_iss.ausgb,
          rcd_lads_sal_ord_iss.frpos,
          rcd_lads_sal_ord_iss.topos,
          rcd_lads_sal_ord_iss.ktxt1,
          rcd_lads_sal_ord_iss.ktxt2,
          rcd_lads_sal_ord_iss.pernr,
          rcd_lads_sal_ord_iss.lgart,
          rcd_lads_sal_ord_iss.stell,
          rcd_lads_sal_ord_iss.zwert,
          rcd_lads_sal_ord_iss.formelnr,
          rcd_lads_sal_ord_iss.frmval1,
          rcd_lads_sal_ord_iss.frmval2,
          rcd_lads_sal_ord_iss.frmval3,
          rcd_lads_sal_ord_iss.frmval4,
          rcd_lads_sal_ord_iss.frmval5,
          rcd_lads_sal_ord_iss.userf1_num,
          rcd_lads_sal_ord_iss.userf2_num,
          rcd_lads_sal_ord_iss.userf1_txt,
          rcd_lads_sal_ord_iss.userf2_txt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_iss;

   /**************************************************/
   /* This procedure performs the record ISR routine */
   /**************************************************/
   procedure process_record_isr(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_isr.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_isr.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_isr.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_isr.isrseq := rcd_lads_sal_ord_isr.isrseq + 1;
      rcd_lads_sal_ord_isr.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_isr.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_lads_sal_ord_isr.xline := lics_inbound_utility.get_number('XLINE',null);
      rcd_lads_sal_ord_isr.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_sal_ord_isr.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_sal_ord_isr.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISR.BELNR');
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

      insert into lads_sal_ord_isr
         (belnr,
          genseq,
          issseq,
          isrseq,
          qualf,
          refnr,
          xline,
          datum,
          uzeit)
      values
         (rcd_lads_sal_ord_isr.belnr,
          rcd_lads_sal_ord_isr.genseq,
          rcd_lads_sal_ord_isr.issseq,
          rcd_lads_sal_ord_isr.isrseq,
          rcd_lads_sal_ord_isr.qualf,
          rcd_lads_sal_ord_isr.refnr,
          rcd_lads_sal_ord_isr.xline,
          rcd_lads_sal_ord_isr.datum,
          rcd_lads_sal_ord_isr.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isr;

   /**************************************************/
   /* This procedure performs the record ISD routine */
   /**************************************************/
   procedure process_record_isd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_isd.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_isd.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_isd.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_isd.isdseq := rcd_lads_sal_ord_isd.isdseq + 1;
      rcd_lads_sal_ord_isd.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_lads_sal_ord_isd.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_sal_ord_isd.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_sal_ord_isd.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISD.BELNR');
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

      insert into lads_sal_ord_isd
         (belnr,
          genseq,
          issseq,
          isdseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_lads_sal_ord_isd.belnr,
          rcd_lads_sal_ord_isd.genseq,
          rcd_lads_sal_ord_isd.issseq,
          rcd_lads_sal_ord_isd.isdseq,
          rcd_lads_sal_ord_isd.iddat,
          rcd_lads_sal_ord_isd.datum,
          rcd_lads_sal_ord_isd.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isd;

   /**************************************************/
   /* This procedure performs the record IST routine */
   /**************************************************/
   procedure process_record_ist(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IST', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_ist.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_ist.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_ist.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_ist.istseq := rcd_lads_sal_ord_ist.istseq + 1;
      rcd_lads_sal_ord_ist.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_sal_ord_ist.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_sal_ord_ist.mwsbt := lics_inbound_utility.get_variable('MWSBT');
      rcd_lads_sal_ord_ist.txjcd := lics_inbound_utility.get_variable('TXJCD');

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
      if rcd_lads_sal_ord_ist.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IST.BELNR');
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

      insert into lads_sal_ord_ist
         (belnr,
          genseq,
          issseq,
          istseq,
          mwskz,
          msatz,
          mwsbt,
          txjcd)
      values
         (rcd_lads_sal_ord_ist.belnr,
          rcd_lads_sal_ord_ist.genseq,
          rcd_lads_sal_ord_ist.issseq,
          rcd_lads_sal_ord_ist.istseq,
          rcd_lads_sal_ord_ist.mwskz,
          rcd_lads_sal_ord_ist.msatz,
          rcd_lads_sal_ord_ist.mwsbt,
          rcd_lads_sal_ord_ist.txjcd);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ist;

   /**************************************************/
   /* This procedure performs the record ISN routine */
   /**************************************************/
   procedure process_record_isn(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_isn.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_isn.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_isn.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_isn.isnseq := rcd_lads_sal_ord_isn.isnseq + 1;
      rcd_lads_sal_ord_isn.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_lads_sal_ord_isn.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_sal_ord_isn.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_lads_sal_ord_isn.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_sal_ord_isn.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_lads_sal_ord_isn.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_lads_sal_ord_isn.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_lads_sal_ord_isn.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_lads_sal_ord_isn.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_lads_sal_ord_isn.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_sal_ord_isn.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_sal_ord_isn.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_sal_ord_isn.msatz := lics_inbound_utility.get_variable('MSATZ');

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
      if rcd_lads_sal_ord_isn.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISN.BELNR');
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

      insert into lads_sal_ord_isn
         (belnr,
          genseq,
          issseq,
          isnseq,
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
          msatz)
      values
         (rcd_lads_sal_ord_isn.belnr,
          rcd_lads_sal_ord_isn.genseq,
          rcd_lads_sal_ord_isn.issseq,
          rcd_lads_sal_ord_isn.isnseq,
          rcd_lads_sal_ord_isn.alckz,
          rcd_lads_sal_ord_isn.kschl,
          rcd_lads_sal_ord_isn.kotxt,
          rcd_lads_sal_ord_isn.betrg,
          rcd_lads_sal_ord_isn.kperc,
          rcd_lads_sal_ord_isn.krate,
          rcd_lads_sal_ord_isn.uprbs,
          rcd_lads_sal_ord_isn.meaun,
          rcd_lads_sal_ord_isn.kobtr,
          rcd_lads_sal_ord_isn.menge,
          rcd_lads_sal_ord_isn.preis,
          rcd_lads_sal_ord_isn.mwskz,
          rcd_lads_sal_ord_isn.msatz);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isn;

   /**************************************************/
   /* This procedure performs the record ISP routine */
   /**************************************************/
   procedure process_record_isp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_isp.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_isp.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_isp.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_isp.ispseq := rcd_lads_sal_ord_isp.ispseq + 1;
      rcd_lads_sal_ord_isp.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_sal_ord_isp.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_lads_sal_ord_isp.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_sal_ord_isp.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_sal_ord_isp.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_sal_ord_isp.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_sal_ord_isp.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_sal_ord_isp.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_sal_ord_isp.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_lads_sal_ord_isp.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_lads_sal_ord_isp.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_sal_ord_isp.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_lads_sal_ord_isp.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_lads_sal_ord_isp.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_lads_sal_ord_isp.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_sal_ord_isp.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_sal_ord_isp.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_lads_sal_ord_isp.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_lads_sal_ord_isp.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_sal_ord_isp.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_lads_sal_ord_isp.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_lads_sal_ord_isp.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_lads_sal_ord_isp.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_lads_sal_ord_isp.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_lads_sal_ord_isp.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_sal_ord_isp.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_sal_ord_isp.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_sal_ord_isp.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_lads_sal_ord_isp.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_lads_sal_ord_isp.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_lads_sal_ord_isp.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_lads_sal_ord_isp.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_lads_sal_ord_isp.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_lads_sal_ord_isp.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_lads_sal_ord_isp.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_sal_ord_isp.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_sal_ord_isp.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_lads_sal_ord_isp.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_lads_sal_ord_isp.pagru := lics_inbound_utility.get_variable('PAGRU');

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
      if rcd_lads_sal_ord_isp.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISP.BELNR');
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

      insert into lads_sal_ord_isp
         (belnr,
          genseq,
          issseq,
          ispseq,
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
          pagru)
      values
         (rcd_lads_sal_ord_isp.belnr,
          rcd_lads_sal_ord_isp.genseq,
          rcd_lads_sal_ord_isp.issseq,
          rcd_lads_sal_ord_isp.ispseq,
          rcd_lads_sal_ord_isp.parvw,
          rcd_lads_sal_ord_isp.partn,
          rcd_lads_sal_ord_isp.lifnr,
          rcd_lads_sal_ord_isp.name1,
          rcd_lads_sal_ord_isp.name2,
          rcd_lads_sal_ord_isp.name3,
          rcd_lads_sal_ord_isp.name4,
          rcd_lads_sal_ord_isp.stras,
          rcd_lads_sal_ord_isp.strs2,
          rcd_lads_sal_ord_isp.pfach,
          rcd_lads_sal_ord_isp.ort01,
          rcd_lads_sal_ord_isp.counc,
          rcd_lads_sal_ord_isp.pstlz,
          rcd_lads_sal_ord_isp.pstl2,
          rcd_lads_sal_ord_isp.land1,
          rcd_lads_sal_ord_isp.ablad,
          rcd_lads_sal_ord_isp.pernr,
          rcd_lads_sal_ord_isp.parnr,
          rcd_lads_sal_ord_isp.telf1,
          rcd_lads_sal_ord_isp.telf2,
          rcd_lads_sal_ord_isp.telbx,
          rcd_lads_sal_ord_isp.telfx,
          rcd_lads_sal_ord_isp.teltx,
          rcd_lads_sal_ord_isp.telx1,
          rcd_lads_sal_ord_isp.spras,
          rcd_lads_sal_ord_isp.anred,
          rcd_lads_sal_ord_isp.ort02,
          rcd_lads_sal_ord_isp.hausn,
          rcd_lads_sal_ord_isp.stock,
          rcd_lads_sal_ord_isp.regio,
          rcd_lads_sal_ord_isp.parge,
          rcd_lads_sal_ord_isp.isoal,
          rcd_lads_sal_ord_isp.isonu,
          rcd_lads_sal_ord_isp.fcode,
          rcd_lads_sal_ord_isp.ihrez,
          rcd_lads_sal_ord_isp.bname,
          rcd_lads_sal_ord_isp.paorg,
          rcd_lads_sal_ord_isp.orgtx,
          rcd_lads_sal_ord_isp.pagru);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isp;

   /**************************************************/
   /* This procedure performs the record ISO routine */
   /**************************************************/
   procedure process_record_iso(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISO', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_iso.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_iso.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_iso.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_iso.isoseq := rcd_lads_sal_ord_iso.isoseq + 1;
      rcd_lads_sal_ord_iso.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_iso.idtnr := lics_inbound_utility.get_variable('IDTNR');
      rcd_lads_sal_ord_iso.ktext := lics_inbound_utility.get_variable('KTEXT');

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
      if rcd_lads_sal_ord_iso.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISO.BELNR');
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

      insert into lads_sal_ord_iso
         (belnr,
          genseq,
          issseq,
          isoseq,
          qualf,
          idtnr,
          ktext)
      values
         (rcd_lads_sal_ord_iso.belnr,
          rcd_lads_sal_ord_iso.genseq,
          rcd_lads_sal_ord_iso.issseq,
          rcd_lads_sal_ord_iso.isoseq,
          rcd_lads_sal_ord_iso.qualf,
          rcd_lads_sal_ord_iso.idtnr,
          rcd_lads_sal_ord_iso.ktext);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_iso;

   /**************************************************/
   /* This procedure performs the record ISI routine */
   /**************************************************/
   procedure process_record_isi(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_isi.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_isi.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_isi.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_isi.isiseq := rcd_lads_sal_ord_isi.isiseq + 1;
      rcd_lads_sal_ord_isi.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_isi.lkond := lics_inbound_utility.get_variable('LKOND');
      rcd_lads_sal_ord_isi.lktext := lics_inbound_utility.get_variable('LKTEXT');

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
      if rcd_lads_sal_ord_isi.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISI.BELNR');
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

      insert into lads_sal_ord_isi
         (belnr,
          genseq,
          issseq,
          isiseq,
          qualf,
          lkond,
          lktext)
      values
         (rcd_lads_sal_ord_isi.belnr,
          rcd_lads_sal_ord_isi.genseq,
          rcd_lads_sal_ord_isi.issseq,
          rcd_lads_sal_ord_isi.isiseq,
          rcd_lads_sal_ord_isi.qualf,
          rcd_lads_sal_ord_isi.lkond,
          rcd_lads_sal_ord_isi.lktext);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isi;

   /**************************************************/
   /* This procedure performs the record ISJ routine */
   /**************************************************/
   procedure process_record_isj(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISJ', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_isj.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_isj.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_isj.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_isj.isjseq := rcd_lads_sal_ord_isj.isjseq + 1;
      rcd_lads_sal_ord_isj.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sal_ord_isj.tage := lics_inbound_utility.get_variable('TAGE');
      rcd_lads_sal_ord_isj.prznt := lics_inbound_utility.get_variable('PRZNT');

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
      if rcd_lads_sal_ord_isj.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISJ.BELNR');
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

      insert into lads_sal_ord_isj
         (belnr,
          genseq,
          issseq,
          isjseq,
          qualf,
          tage,
          prznt)
      values
         (rcd_lads_sal_ord_isj.belnr,
          rcd_lads_sal_ord_isj.genseq,
          rcd_lads_sal_ord_isj.issseq,
          rcd_lads_sal_ord_isj.isjseq,
          rcd_lads_sal_ord_isj.qualf,
          rcd_lads_sal_ord_isj.tage,
          rcd_lads_sal_ord_isj.prznt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isj;

   /**************************************************/
   /* This procedure performs the record ISX routine */
   /**************************************************/
   procedure process_record_isx(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_isx.belnr := rcd_lads_sal_ord_iss.belnr;
      rcd_lads_sal_ord_isx.genseq := rcd_lads_sal_ord_iss.genseq;
      rcd_lads_sal_ord_isx.issseq := rcd_lads_sal_ord_iss.issseq;
      rcd_lads_sal_ord_isx.isxseq := rcd_lads_sal_ord_isx.isxseq + 1;
      rcd_lads_sal_ord_isx.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_sal_ord_isx.tsspras := lics_inbound_utility.get_variable('TSSPRAS');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sal_ord_isy.isyseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sal_ord_isx.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISX.BELNR');
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

      insert into lads_sal_ord_isx
         (belnr,
          genseq,
          issseq,
          isxseq,
          tdid,
          tsspras)
      values
         (rcd_lads_sal_ord_isx.belnr,
          rcd_lads_sal_ord_isx.genseq,
          rcd_lads_sal_ord_isx.issseq,
          rcd_lads_sal_ord_isx.isxseq,
          rcd_lads_sal_ord_isx.tdid,
          rcd_lads_sal_ord_isx.tsspras);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isx;

   /**************************************************/
   /* This procedure performs the record ISY routine */
   /**************************************************/
   procedure process_record_isy(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ISY', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sal_ord_isy.belnr := rcd_lads_sal_ord_isx.belnr;
      rcd_lads_sal_ord_isy.genseq := rcd_lads_sal_ord_isx.genseq;
      rcd_lads_sal_ord_isy.issseq := rcd_lads_sal_ord_isx.issseq;
      rcd_lads_sal_ord_isy.isxseq := rcd_lads_sal_ord_isx.isxseq;
      rcd_lads_sal_ord_isy.isyseq := rcd_lads_sal_ord_isy.isyseq + 1;
      rcd_lads_sal_ord_isy.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_sal_ord_isy.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ISY.BELNR');
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

      insert into lads_sal_ord_isy
         (belnr,
          genseq,
          issseq,
          isxseq,
          isyseq,
          tdline)
      values
         (rcd_lads_sal_ord_isy.belnr,
          rcd_lads_sal_ord_isy.genseq,
          rcd_lads_sal_ord_isy.issseq,
          rcd_lads_sal_ord_isy.isxseq,
          rcd_lads_sal_ord_isy.isyseq,
          rcd_lads_sal_ord_isy.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_isy;

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
      rcd_lads_sal_ord_smy.belnr := rcd_lads_sal_ord_hdr.belnr;
      rcd_lads_sal_ord_smy.smyseq := rcd_lads_sal_ord_smy.smyseq + 1;
      rcd_lads_sal_ord_smy.sumid := lics_inbound_utility.get_variable('SUMID');
      rcd_lads_sal_ord_smy.summe := lics_inbound_utility.get_variable('SUMME');
      rcd_lads_sal_ord_smy.sunit := lics_inbound_utility.get_variable('SUNIT');
      rcd_lads_sal_ord_smy.waerq := lics_inbound_utility.get_variable('WAERQ');

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
      if rcd_lads_sal_ord_smy.belnr is null then
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

      insert into lads_sal_ord_smy
         (belnr,
          smyseq,
          sumid,
          summe,
          sunit,
          waerq)
      values
         (rcd_lads_sal_ord_smy.belnr,
          rcd_lads_sal_ord_smy.smyseq,
          rcd_lads_sal_ord_smy.sumid,
          rcd_lads_sal_ord_smy.summe,
          rcd_lads_sal_ord_smy.sunit,
          rcd_lads_sal_ord_smy.waerq);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_smy;

end lads_atllad13;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad13 for lads_app.lads_atllad13;
grant execute on lads_atllad13 to lics_app;
