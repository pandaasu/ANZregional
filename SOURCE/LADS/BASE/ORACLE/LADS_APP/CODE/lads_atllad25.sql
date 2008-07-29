/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad25
 Owner   : lads_app
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_atllad25 - Generic ICB Document

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created
 2006/01   Linden Glen    ADD: shpmnt_status field
 2008/05   Trevor Keon    Added calls to monitor before and after procedure

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad25 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad25;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad25 as

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
   procedure process_record_ord(par_record in varchar2);
   procedure process_record_hor(par_record in varchar2);
   procedure process_record_org(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);
   procedure process_record_pnr(par_record in varchar2);
   procedure process_record_gen(par_record in varchar2);
   procedure process_record_ico(par_record in varchar2);
   procedure process_record_sor(par_record in varchar2);
   procedure process_record_del(par_record in varchar2);
   procedure process_record_hde(par_record in varchar2);
   procedure process_record_add(par_record in varchar2);
   procedure process_record_tim(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);
   procedure process_record_int(par_record in varchar2);
   procedure process_record_irf(par_record in varchar2);
   procedure process_record_erf(par_record in varchar2);
   procedure process_record_huh(par_record in varchar2);
   procedure process_record_huc(par_record in varchar2);
   procedure process_record_shp(par_record in varchar2);
   procedure process_record_hsh(par_record in varchar2);
   procedure process_record_hda(par_record in varchar2);
   procedure process_record_har(par_record in varchar2);
   procedure process_record_hst(par_record in varchar2);
   procedure process_record_hsp(par_record in varchar2);
   procedure process_record_hsd(par_record in varchar2);
   procedure process_record_hsi(par_record in varchar2);
   procedure process_record_hag(par_record in varchar2);
   procedure process_record_inv(par_record in varchar2);
   procedure process_record_hin(par_record in varchar2);
   procedure process_record_ign(par_record in varchar2);
   procedure process_record_ire(par_record in varchar2);
   procedure process_record_icn(par_record in varchar2);
   procedure process_record_sin(par_record in varchar2);
   procedure process_record_idt(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_exp_hdr lads_exp_hdr%rowtype;
   rcd_lads_exp_ord lads_exp_ord%rowtype;
   rcd_lads_exp_hor lads_exp_hor%rowtype;
   rcd_lads_exp_org lads_exp_org%rowtype;
   rcd_lads_exp_dat lads_exp_dat%rowtype;
   rcd_lads_exp_pnr lads_exp_pnr%rowtype;
   rcd_lads_exp_gen lads_exp_gen%rowtype;
   rcd_lads_exp_ico lads_exp_ico%rowtype;
   rcd_lads_exp_sor lads_exp_sor%rowtype;
   rcd_lads_exp_del lads_exp_del%rowtype;
   rcd_lads_exp_hde lads_exp_hde%rowtype;
   rcd_lads_exp_add lads_exp_add%rowtype;
   rcd_lads_exp_tim lads_exp_tim%rowtype;
   rcd_lads_exp_det lads_exp_det%rowtype;
   rcd_lads_exp_int lads_exp_int%rowtype;
   rcd_lads_exp_irf lads_exp_irf%rowtype;
   rcd_lads_exp_erf lads_exp_erf%rowtype;
   rcd_lads_exp_huh lads_exp_huh%rowtype;
   rcd_lads_exp_huc lads_exp_huc%rowtype;
   rcd_lads_exp_shp lads_exp_shp%rowtype;
   rcd_lads_exp_hsh lads_exp_hsh%rowtype;
   rcd_lads_exp_hda lads_exp_hda%rowtype;
   rcd_lads_exp_har lads_exp_har%rowtype;
   rcd_lads_exp_hst lads_exp_hst%rowtype;
   rcd_lads_exp_hsp lads_exp_hsp%rowtype;
   rcd_lads_exp_hsd lads_exp_hsd%rowtype;
   rcd_lads_exp_hsi lads_exp_hsi%rowtype;
   rcd_lads_exp_hag lads_exp_hag%rowtype;
   rcd_lads_exp_inv lads_exp_inv%rowtype;
   rcd_lads_exp_hin lads_exp_hin%rowtype;
   rcd_lads_exp_ign lads_exp_ign%rowtype;
   rcd_lads_exp_ire lads_exp_ire%rowtype;
   rcd_lads_exp_icn lads_exp_icn%rowtype;
   rcd_lads_exp_sin lads_exp_sin%rowtype;
   rcd_lads_exp_idt lads_exp_idt%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IDENTIFIER',3);
      lics_inbound_utility.set_definition('CTL','IDOCTYP',30);
      lics_inbound_utility.set_definition('CTL','DOCNUM',16);
      lics_inbound_utility.set_definition('CTL','CREDAT',8);
      lics_inbound_utility.set_definition('CTL','CRETIM',6);
      lics_inbound_utility.set_definition('CTL','MESCOD',3);
      lics_inbound_utility.set_definition('CTL','MESFCT',3);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HDR','ZZGRPNR',40);
      /*-*/
      lics_inbound_utility.set_definition('ORD','IDENTIFIER',3);
      lics_inbound_utility.set_definition('ORD','ZNBORDERS',10);
      lics_inbound_utility.set_definition('ORD','ZTYPORD',2);
      /*-*/
      lics_inbound_utility.set_definition('HOR','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HOR','ACTION',3);
      lics_inbound_utility.set_definition('HOR','KZABS',1);
      lics_inbound_utility.set_definition('HOR','CURCY',3);
      lics_inbound_utility.set_definition('HOR','HWAER',3);
      lics_inbound_utility.set_definition('HOR','WKURS',12);
      lics_inbound_utility.set_definition('HOR','ZTERM',17);
      lics_inbound_utility.set_definition('HOR','KUNDEUINR',20);
      lics_inbound_utility.set_definition('HOR','EIGENUINR',20);
      lics_inbound_utility.set_definition('HOR','BSART',4);
      lics_inbound_utility.set_definition('HOR','BELNR',35);
      lics_inbound_utility.set_definition('HOR','NTGEW',18);
      lics_inbound_utility.set_definition('HOR','BRGEW',18);
      lics_inbound_utility.set_definition('HOR','GEWEI',3);
      lics_inbound_utility.set_definition('HOR','FKART_RL',4);
      lics_inbound_utility.set_definition('HOR','ABLAD',25);
      lics_inbound_utility.set_definition('HOR','BSTZD',4);
      lics_inbound_utility.set_definition('HOR','VSART',2);
      lics_inbound_utility.set_definition('HOR','VSART_BEZ',20);
      lics_inbound_utility.set_definition('HOR','RECIPNT_NO',10);
      lics_inbound_utility.set_definition('HOR','KZAZU',1);
      lics_inbound_utility.set_definition('HOR','AUTLF',1);
      lics_inbound_utility.set_definition('HOR','AUGRU',3);
      lics_inbound_utility.set_definition('HOR','AUGRU_BEZ',40);
      lics_inbound_utility.set_definition('HOR','ABRVW',3);
      lics_inbound_utility.set_definition('HOR','ABRVW_BEZ',20);
      lics_inbound_utility.set_definition('HOR','FKTYP',1);
      lics_inbound_utility.set_definition('HOR','LIFSK',2);
      lics_inbound_utility.set_definition('HOR','LIFSK_BEZ',20);
      lics_inbound_utility.set_definition('HOR','EMPST',25);
      lics_inbound_utility.set_definition('HOR','ABTNR',4);
      lics_inbound_utility.set_definition('HOR','DELCO',3);
      lics_inbound_utility.set_definition('HOR','WKURS_M',12);
      lics_inbound_utility.set_definition('HOR','ZZSHIPTO',10);
      lics_inbound_utility.set_definition('HOR','ZZSOLDTO',10);
      /*-*/
      lics_inbound_utility.set_definition('ORG','IDENTIFIER',3);
      lics_inbound_utility.set_definition('ORG','QUALF',3);
      lics_inbound_utility.set_definition('ORG','ORGID',35);
      /*-*/
      lics_inbound_utility.set_definition('DAT','IDENTIFIER',3);
      lics_inbound_utility.set_definition('DAT','IDDAT',3);
      lics_inbound_utility.set_definition('DAT','DATUM',8);
      lics_inbound_utility.set_definition('DAT','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('PNR','IDENTIFIER',3);
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
      lics_inbound_utility.set_definition('GEN','IDENTIFIER',3);
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
      lics_inbound_utility.set_definition('GEN','ZZACT_QTY',0);
      lics_inbound_utility.set_definition('GEN','ZZDELUOM',0);
      /*-*/
      lics_inbound_utility.set_definition('ICO','IDENTIFIER',3);
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
      lics_inbound_utility.set_definition('SOR','IDENTIFIER',3);
      lics_inbound_utility.set_definition('SOR','SUMID',3);
      lics_inbound_utility.set_definition('SOR','SUMME',18);
      lics_inbound_utility.set_definition('SOR','SUNIT',3);
      lics_inbound_utility.set_definition('SOR','WAERQ',3);
      /*-*/
      lics_inbound_utility.set_definition('DEL','HEADER CODE',3);
      lics_inbound_utility.set_definition('DEL','ZNBDELVRY',10);
      /*-*/
      lics_inbound_utility.set_definition('HDE','HEADER CODE',3);
      lics_inbound_utility.set_definition('HDE','VBELN',10);
      lics_inbound_utility.set_definition('HDE','VSTEL',4);
      lics_inbound_utility.set_definition('HDE','VKORG',4);
      lics_inbound_utility.set_definition('HDE','LSTEL',2);
      lics_inbound_utility.set_definition('HDE','VKBUR',4);
      lics_inbound_utility.set_definition('HDE','LGNUM',3);
      lics_inbound_utility.set_definition('HDE','ABLAD',25);
      lics_inbound_utility.set_definition('HDE','INCO1',3);
      lics_inbound_utility.set_definition('HDE','INCO2',28);
      lics_inbound_utility.set_definition('HDE','ROUTE',6);
      lics_inbound_utility.set_definition('HDE','VSBED',2);
      lics_inbound_utility.set_definition('HDE','BTGEW',17);
      lics_inbound_utility.set_definition('HDE','NTGEW',15);
      lics_inbound_utility.set_definition('HDE','GEWEI',3);
      lics_inbound_utility.set_definition('HDE','VOLUM',15);
      lics_inbound_utility.set_definition('HDE','VOLEH',3);
      lics_inbound_utility.set_definition('HDE','ANZPK',5);
      lics_inbound_utility.set_definition('HDE','BOLNR',35);
      lics_inbound_utility.set_definition('HDE','TRATY',4);
      lics_inbound_utility.set_definition('HDE','TRAID',20);
      lics_inbound_utility.set_definition('HDE','XABLN',10);
      lics_inbound_utility.set_definition('HDE','LIFEX',35);
      lics_inbound_utility.set_definition('HDE','PARID',35);
      lics_inbound_utility.set_definition('HDE','PODAT',8);
      lics_inbound_utility.set_definition('HDE','POTIM',6);
      lics_inbound_utility.set_definition('HDE','VSTEL_BEZ',30);
      lics_inbound_utility.set_definition('HDE','VKORG_BEZ',20);
      lics_inbound_utility.set_definition('HDE','LSTEL_BEZ',20);
      lics_inbound_utility.set_definition('HDE','VKBUR_BEZ',20);
      lics_inbound_utility.set_definition('HDE','LGNUM_BEZ',25);
      lics_inbound_utility.set_definition('HDE','INCO1_BEZ',30);
      lics_inbound_utility.set_definition('HDE','ROUTE_BEZ',40);
      lics_inbound_utility.set_definition('HDE','VSBED_BEZ',20);
      lics_inbound_utility.set_definition('HDE','TRATY_BEZ',20);
      lics_inbound_utility.set_definition('HDE','LFART',4);
      lics_inbound_utility.set_definition('HDE','BZIRK',6);
      lics_inbound_utility.set_definition('HDE','AUTLF',1);
      lics_inbound_utility.set_definition('HDE','LIFSK',2);
      lics_inbound_utility.set_definition('HDE','LPRIO',2);
      lics_inbound_utility.set_definition('HDE','KDGRP',2);
      lics_inbound_utility.set_definition('HDE','BEROT',20);
      lics_inbound_utility.set_definition('HDE','TRAGR',4);
      lics_inbound_utility.set_definition('HDE','TRSPG',2);
      lics_inbound_utility.set_definition('HDE','AULWE',10);
      lics_inbound_utility.set_definition('HDE','LFART_BEZ',20);
      lics_inbound_utility.set_definition('HDE','LPRIO_BEZ',20);
      lics_inbound_utility.set_definition('HDE','BZIRK_BEZ',20);
      lics_inbound_utility.set_definition('HDE','LIFSK_BEZ',20);
      lics_inbound_utility.set_definition('HDE','KDGRP_BEZ',20);
      lics_inbound_utility.set_definition('HDE','TRAGR_BEZ',20);
      lics_inbound_utility.set_definition('HDE','TRSPG_BEZ',20);
      lics_inbound_utility.set_definition('HDE','AULWE_BEZ',40);
      lics_inbound_utility.set_definition('HDE','ZZCONTSEAL',40);
      lics_inbound_utility.set_definition('HDE','ZZTARIF',3);
      lics_inbound_utility.set_definition('HDE','ZZTOTPIKQTY',17);
      lics_inbound_utility.set_definition('HDE','BELNR',35);
      /*-*/
      lics_inbound_utility.set_definition('ADD','HEADER CODE',3);
      lics_inbound_utility.set_definition('ADD','PARTNER_Q',3);
      lics_inbound_utility.set_definition('ADD','ADDRESS_T',1);
      lics_inbound_utility.set_definition('ADD','PARTNER_ID',17);
      lics_inbound_utility.set_definition('ADD','JURISDIC',15);
      lics_inbound_utility.set_definition('ADD','LANGUAGE',2);
      lics_inbound_utility.set_definition('ADD','FORMOFADDR',15);
      lics_inbound_utility.set_definition('ADD','NAME1',40);
      lics_inbound_utility.set_definition('ADD','NAME2',40);
      lics_inbound_utility.set_definition('ADD','NAME3',40);
      lics_inbound_utility.set_definition('ADD','NAME4',40);
      lics_inbound_utility.set_definition('ADD','NAME_TEXT',50);
      lics_inbound_utility.set_definition('ADD','NAME_CO',40);
      lics_inbound_utility.set_definition('ADD','LOCATION',40);
      lics_inbound_utility.set_definition('ADD','BUILDING',10);
      lics_inbound_utility.set_definition('ADD','FLOOR',10);
      lics_inbound_utility.set_definition('ADD','ROOM',10);
      lics_inbound_utility.set_definition('ADD','STREET1',40);
      lics_inbound_utility.set_definition('ADD','STREET2',40);
      lics_inbound_utility.set_definition('ADD','STREET3',40);
      lics_inbound_utility.set_definition('ADD','HOUSE_SUPL',4);
      lics_inbound_utility.set_definition('ADD','HOUSE_RANG',10);
      lics_inbound_utility.set_definition('ADD','POSTL_COD1',10);
      lics_inbound_utility.set_definition('ADD','POSTL_COD3',10);
      lics_inbound_utility.set_definition('ADD','POSTL_AREA',15);
      lics_inbound_utility.set_definition('ADD','CITY1',40);
      lics_inbound_utility.set_definition('ADD','CITY2',40);
      lics_inbound_utility.set_definition('ADD','POSTL_PBOX',10);
      lics_inbound_utility.set_definition('ADD','POSTL_COD2',10);
      lics_inbound_utility.set_definition('ADD','POSTL_CITY',40);
      lics_inbound_utility.set_definition('ADD','TELEPHONE1',30);
      lics_inbound_utility.set_definition('ADD','TELEPHONE2',30);
      lics_inbound_utility.set_definition('ADD','TELEFAX',30);
      lics_inbound_utility.set_definition('ADD','TELEX',30);
      lics_inbound_utility.set_definition('ADD','E_MAIL',70);
      lics_inbound_utility.set_definition('ADD','COUNTRY1',3);
      lics_inbound_utility.set_definition('ADD','COUNTRY2',3);
      lics_inbound_utility.set_definition('ADD','REGION',3);
      lics_inbound_utility.set_definition('ADD','COUNTY_COD',3);
      lics_inbound_utility.set_definition('ADD','COUNTY_TXT',25);
      lics_inbound_utility.set_definition('ADD','TZCODE',6);
      lics_inbound_utility.set_definition('ADD','TZDESC',35);
      /*-*/
      lics_inbound_utility.set_definition('TIM','HEADER CODE',3);
      lics_inbound_utility.set_definition('TIM','QUALF',3);
      lics_inbound_utility.set_definition('TIM','VSTZW',4);
      lics_inbound_utility.set_definition('TIM','VSTZW_BEZ',20);
      lics_inbound_utility.set_definition('TIM','NTANF',8);
      lics_inbound_utility.set_definition('TIM','NTANZ',6);
      lics_inbound_utility.set_definition('TIM','NTEND',8);
      lics_inbound_utility.set_definition('TIM','NTENZ',6);
      lics_inbound_utility.set_definition('TIM','TZONE_BEG',6);
      lics_inbound_utility.set_definition('TIM','ISDD',8);
      lics_inbound_utility.set_definition('TIM','ISDZ',6);
      lics_inbound_utility.set_definition('TIM','IEDD',8);
      lics_inbound_utility.set_definition('TIM','IEDz',6);
      lics_inbound_utility.set_definition('TIM','TZONE_END',6);
      lics_inbound_utility.set_definition('TIM','VORNR',4);
      lics_inbound_utility.set_definition('TIM','VSTGA',4);
      lics_inbound_utility.set_definition('TIM','VSTGA_BEZ',20);
      lics_inbound_utility.set_definition('TIM','EVENT',10);
      lics_inbound_utility.set_definition('TIM','EVENT_ALI',20);
      /*-*/
      lics_inbound_utility.set_definition('DET','HEADER CODE',3);
      lics_inbound_utility.set_definition('DET','POSNR',6);
      lics_inbound_utility.set_definition('DET','MATNR',18);
      lics_inbound_utility.set_definition('DET','MATWA',18);
      lics_inbound_utility.set_definition('DET','ARKTX',40);
      lics_inbound_utility.set_definition('DET','ORKTX',40);
      lics_inbound_utility.set_definition('DET','SUGRD',4);
      lics_inbound_utility.set_definition('DET','SUDRU',1);
      lics_inbound_utility.set_definition('DET','MATKL',9);
      lics_inbound_utility.set_definition('DET','WERKS',4);
      lics_inbound_utility.set_definition('DET','LGORT',4);
      lics_inbound_utility.set_definition('DET','CHARG',10);
      lics_inbound_utility.set_definition('DET','KDMAT',22);
      lics_inbound_utility.set_definition('DET','LFIMG',15);
      lics_inbound_utility.set_definition('DET','VRKME',3);
      lics_inbound_utility.set_definition('DET','LGMNG',15);
      lics_inbound_utility.set_definition('DET','MEINS',3);
      lics_inbound_utility.set_definition('DET','NTGEW',15);
      lics_inbound_utility.set_definition('DET','BRGEW',15);
      lics_inbound_utility.set_definition('DET','GEWEI',3);
      lics_inbound_utility.set_definition('DET','VOLUM',15);
      lics_inbound_utility.set_definition('DET','VOLEH',3);
      lics_inbound_utility.set_definition('DET','LGPBE',10);
      lics_inbound_utility.set_definition('DET','HIPOS',6);
      lics_inbound_utility.set_definition('DET','HIEVW',1);
      lics_inbound_utility.set_definition('DET','LADGR',4);
      lics_inbound_utility.set_definition('DET','TRAGR',4);
      lics_inbound_utility.set_definition('DET','VKBUR',4);
      lics_inbound_utility.set_definition('DET','VKGRP',3);
      lics_inbound_utility.set_definition('DET','VTWEG',2);
      lics_inbound_utility.set_definition('DET','SPART',2);
      lics_inbound_utility.set_definition('DET','GRKOR',3);
      lics_inbound_utility.set_definition('DET','EAN11',18);
      lics_inbound_utility.set_definition('DET','SERNR',8);
      lics_inbound_utility.set_definition('DET','AESKD',17);
      lics_inbound_utility.set_definition('DET','EMPST',25);
      lics_inbound_utility.set_definition('DET','MFRGR',8);
      lics_inbound_utility.set_definition('DET','VBRST',14);
      lics_inbound_utility.set_definition('DET','LABNK',17);
      lics_inbound_utility.set_definition('DET','ABRDT',8);
      lics_inbound_utility.set_definition('DET','MFRPN',40);
      lics_inbound_utility.set_definition('DET','MFRNR',10);
      lics_inbound_utility.set_definition('DET','ABRVW',3);
      lics_inbound_utility.set_definition('DET','KDMAT35',35);
      lics_inbound_utility.set_definition('DET','KANNR',35);
      lics_inbound_utility.set_definition('DET','POSEX',6);
      lics_inbound_utility.set_definition('DET','LIEFFZ',17);
      lics_inbound_utility.set_definition('DET','USR01',35);
      lics_inbound_utility.set_definition('DET','USR02',35);
      lics_inbound_utility.set_definition('DET','USR03',35);
      lics_inbound_utility.set_definition('DET','USR04',10);
      lics_inbound_utility.set_definition('DET','USR05',10);
      lics_inbound_utility.set_definition('DET','MATNR_EXTERNAL',40);
      lics_inbound_utility.set_definition('DET','MATNR_VERSION',10);
      lics_inbound_utility.set_definition('DET','MATNR_GUID',32);
      lics_inbound_utility.set_definition('DET','MATWA_EXTERNAL',40);
      lics_inbound_utility.set_definition('DET','MATWA_VERSION',10);
      lics_inbound_utility.set_definition('DET','MATWA_GUID',32);
      lics_inbound_utility.set_definition('DET','ZUDAT',20);
      lics_inbound_utility.set_definition('DET','VFDAT',8);
      /*-*/
      lics_inbound_utility.set_definition('INT','HEADER CODE',3);
      lics_inbound_utility.set_definition('INT','ATINN',10);
      lics_inbound_utility.set_definition('INT','ATNAM',30);
      lics_inbound_utility.set_definition('INT','ATBEZ',30);
      lics_inbound_utility.set_definition('INT','ATWRT',30);
      lics_inbound_utility.set_definition('INT','ATWTB',30);
      lics_inbound_utility.set_definition('INT','EWAHR',24);
      /*-*/
      lics_inbound_utility.set_definition('IRF','HEADER CODE',3);
      lics_inbound_utility.set_definition('IRF','QUALF',1);
      lics_inbound_utility.set_definition('IRF','BELNR',35);
      lics_inbound_utility.set_definition('IRF','POSNR',6);
      lics_inbound_utility.set_definition('IRF','DATUM',8);
      lics_inbound_utility.set_definition('IRF','DOCTYPE',4);
      lics_inbound_utility.set_definition('IRF','REASON',3);
      /*-*/
      lics_inbound_utility.set_definition('ERF','HEADER CODE',3);
      lics_inbound_utility.set_definition('ERF','QUALI',3);
      lics_inbound_utility.set_definition('ERF','BSTNR',35);
      lics_inbound_utility.set_definition('ERF','BSTDT',8);
      lics_inbound_utility.set_definition('ERF','BSARK',4);
      lics_inbound_utility.set_definition('ERF','IHREZ',12);
      lics_inbound_utility.set_definition('ERF','POSEX',6);
      /*-*/
      lics_inbound_utility.set_definition('HUH','HEADER CODE',3);
      lics_inbound_utility.set_definition('HUH','EXIDV',20);
      lics_inbound_utility.set_definition('HUH','TARAG',17);
      lics_inbound_utility.set_definition('HUH','GWEIT',3);
      lics_inbound_utility.set_definition('HUH','BRGEW',17);
      lics_inbound_utility.set_definition('HUH','NTGEW',17);
      lics_inbound_utility.set_definition('HUH','MAGEW',17);
      lics_inbound_utility.set_definition('HUH','GWEIM',3);
      lics_inbound_utility.set_definition('HUH','BTVOL',17);
      lics_inbound_utility.set_definition('HUH','NTVOL',17);
      lics_inbound_utility.set_definition('HUH','MAVOL',17);
      lics_inbound_utility.set_definition('HUH','VOLEM',3);
      lics_inbound_utility.set_definition('HUH','TAVOL',17);
      lics_inbound_utility.set_definition('HUH','VOLET',3);
      lics_inbound_utility.set_definition('HUH','VEGR2',5);
      lics_inbound_utility.set_definition('HUH','VEGR1',5);
      lics_inbound_utility.set_definition('HUH','VEGR3',5);
      lics_inbound_utility.set_definition('HUH','VHILM',18);
      lics_inbound_utility.set_definition('HUH','VEGR4',5);
      lics_inbound_utility.set_definition('HUH','LAENG',15);
      lics_inbound_utility.set_definition('HUH','VEGR5',5);
      lics_inbound_utility.set_definition('HUH','BREIT',15);
      lics_inbound_utility.set_definition('HUH','HOEHE',15);
      lics_inbound_utility.set_definition('HUH','MEABM',3);
      lics_inbound_utility.set_definition('HUH','INHALT',40);
      lics_inbound_utility.set_definition('HUH','VHART',4);
      lics_inbound_utility.set_definition('HUH','MAGRV',4);
      lics_inbound_utility.set_definition('HUH','LADLG',8);
      lics_inbound_utility.set_definition('HUH','LADEH',3);
      lics_inbound_utility.set_definition('HUH','FARZT',4);
      lics_inbound_utility.set_definition('HUH','FAREH',3);
      lics_inbound_utility.set_definition('HUH','ENTFE',8);
      lics_inbound_utility.set_definition('HUH','EHENT',3);
      lics_inbound_utility.set_definition('HUH','VELTP',1);
      lics_inbound_utility.set_definition('HUH','EXIDV2',20);
      lics_inbound_utility.set_definition('HUH','LANDT',3);
      lics_inbound_utility.set_definition('HUH','LANDF',3);
      lics_inbound_utility.set_definition('HUH','NAMEF',35);
      lics_inbound_utility.set_definition('HUH','NAMBE',35);
      lics_inbound_utility.set_definition('HUH','VHILM_KU',22);
      lics_inbound_utility.set_definition('HUH','VEBEZ',40);
      lics_inbound_utility.set_definition('HUH','SMGKN',1);
      lics_inbound_utility.set_definition('HUH','KDMAT35',35);
      lics_inbound_utility.set_definition('HUH','SORTL',10);
      lics_inbound_utility.set_definition('HUH','ERNAM',12);
      lics_inbound_utility.set_definition('HUH','GEWFX',1);
      lics_inbound_utility.set_definition('HUH','ERLKZ',1);
      lics_inbound_utility.set_definition('HUH','EXIDA',1);
      lics_inbound_utility.set_definition('HUH','MOVE_STATUS',4);
      lics_inbound_utility.set_definition('HUH','PACKVORSCHR',22);
      lics_inbound_utility.set_definition('HUH','PACKVORSCHR_ST',1);
      lics_inbound_utility.set_definition('HUH','LABELTYP',1);
      lics_inbound_utility.set_definition('HUH','ZUL_AUFL',17);
      lics_inbound_utility.set_definition('HUH','VHILM_EXTERNAL',40);
      lics_inbound_utility.set_definition('HUH','VHILM_VERSION',10);
      lics_inbound_utility.set_definition('HUH','VHILM_GUID',32);
      lics_inbound_utility.set_definition('HUH','VEGR1_BEZ',20);
      lics_inbound_utility.set_definition('HUH','VEGR2_BEZ',20);
      lics_inbound_utility.set_definition('HUH','VEGR3_BEZ',20);
      lics_inbound_utility.set_definition('HUH','VEGR4_BEZ',20);
      lics_inbound_utility.set_definition('HUH','VEGR5_BEZ',20);
      lics_inbound_utility.set_definition('HUH','VHART_BEZ',20);
      lics_inbound_utility.set_definition('HUH','MAGRV_BEZ',20);
      lics_inbound_utility.set_definition('HUH','VEBEZ1',40);
      /*-*/
      lics_inbound_utility.set_definition('HUC','HEADER CODE',3);
      lics_inbound_utility.set_definition('HUC','VELIN',1);
      lics_inbound_utility.set_definition('HUC','VBELN',10);
      lics_inbound_utility.set_definition('HUC','POSNR',6);
      lics_inbound_utility.set_definition('HUC','EXIDV',20);
      lics_inbound_utility.set_definition('HUC','VEMNG',17);
      lics_inbound_utility.set_definition('HUC','VEMEH',3);
      lics_inbound_utility.set_definition('HUC','MATNR',18);
      lics_inbound_utility.set_definition('HUC','KDMAT',35);
      lics_inbound_utility.set_definition('HUC','CHARG',10);
      lics_inbound_utility.set_definition('HUC','WERKS',4);
      lics_inbound_utility.set_definition('HUC','LGORT',4);
      lics_inbound_utility.set_definition('HUC','CUOBJ',18);
      lics_inbound_utility.set_definition('HUC','BESTQ',1);
      lics_inbound_utility.set_definition('HUC','SOBKZ',1);
      lics_inbound_utility.set_definition('HUC','SONUM',16);
      lics_inbound_utility.set_definition('HUC','ANZSN',11);
      lics_inbound_utility.set_definition('HUC','WDATU',8);
      lics_inbound_utility.set_definition('HUC','PARID',35);
      lics_inbound_utility.set_definition('HUC','MATNR_EXTERNAL',40);
      lics_inbound_utility.set_definition('HUC','MATNR_VERSION',10);
      lics_inbound_utility.set_definition('HUC','MATNR_GUID',32);
      /*-*/
      lics_inbound_utility.set_definition('SHP','IDENTIFIER',3);
      lics_inbound_utility.set_definition('SHP','ZNBSHPMNT',10);
      /*-*/
      lics_inbound_utility.set_definition('HSH','HEADER CODE',3);
      lics_inbound_utility.set_definition('HSH','TKNUM',10);
      lics_inbound_utility.set_definition('HSH','SHTYP',4);
      lics_inbound_utility.set_definition('HSH','ABFER',1);
      lics_inbound_utility.set_definition('HSH','ABWST',1);
      lics_inbound_utility.set_definition('HSH','BFART',1);
      lics_inbound_utility.set_definition('HSH','VSART',2);
      lics_inbound_utility.set_definition('HSH','LAUFK',1);
      lics_inbound_utility.set_definition('HSH','VSBED',2);
      lics_inbound_utility.set_definition('HSH','ROUTE',6);
      lics_inbound_utility.set_definition('HSH','SIGNI',20);
      lics_inbound_utility.set_definition('HSH','EXTI1',20);
      lics_inbound_utility.set_definition('HSH','EXTI2',20);
      lics_inbound_utility.set_definition('HSH','TPBEZ',20);
      lics_inbound_utility.set_definition('HSH','STTRG',1);
      lics_inbound_utility.set_definition('HSH','PKSTK',1);
      lics_inbound_utility.set_definition('HSH','DTMEG',3);
      lics_inbound_utility.set_definition('HSH','DTMEV',3);
      lics_inbound_utility.set_definition('HSH','DISTZ',16);
      lics_inbound_utility.set_definition('HSH','MEDST',3);
      lics_inbound_utility.set_definition('HSH','FAHZT',8);
      lics_inbound_utility.set_definition('HSH','GESZT',8);
      lics_inbound_utility.set_definition('HSH','MEIZT',3);
      lics_inbound_utility.set_definition('HSH','FBSTA',1);
      lics_inbound_utility.set_definition('HSH','FBGST',1);
      lics_inbound_utility.set_definition('HSH','ARSTA',1);
      lics_inbound_utility.set_definition('HSH','ARGST',1);
      lics_inbound_utility.set_definition('HSH','STERM_DONE',1);
      lics_inbound_utility.set_definition('HSH','VSE_FRK',1);
      lics_inbound_utility.set_definition('HSH','KKALSM',6);
      lics_inbound_utility.set_definition('HSH','SDABW',4);
      lics_inbound_utility.set_definition('HSH','FRKRL',1);
      lics_inbound_utility.set_definition('HSH','GESZTD',12);
      lics_inbound_utility.set_definition('HSH','FAHZTD',12);
      lics_inbound_utility.set_definition('HSH','GESZTDA',12);
      lics_inbound_utility.set_definition('HSH','FAHZTDA',12);
      lics_inbound_utility.set_definition('HSH','WARZTD',12);
      lics_inbound_utility.set_definition('HSH','WARZTDA',12);
      lics_inbound_utility.set_definition('HSH','SHTYP_BEZ',20);
      lics_inbound_utility.set_definition('HSH','BFART_BEZ',20);
      lics_inbound_utility.set_definition('HSH','VSART_BEZ',20);
      lics_inbound_utility.set_definition('HSH','LAUFK_BEZ',20);
      lics_inbound_utility.set_definition('HSH','VSBED_BEZ',20);
      lics_inbound_utility.set_definition('HSH','ROUTE_BEZ',40);
      lics_inbound_utility.set_definition('HSH','STTRG_BEZ',20);
      lics_inbound_utility.set_definition('HSH','FBSTA_BEZ',25);
      lics_inbound_utility.set_definition('HSH','FBGST_BEZ',25);
      lics_inbound_utility.set_definition('HSH','ARSTA_BEZ',25);
      lics_inbound_utility.set_definition('HSH','ARGST_BEZ',25);
      lics_inbound_utility.set_definition('HSH','TNDRST',2);
      lics_inbound_utility.set_definition('HSH','TNDRRC',2);
      lics_inbound_utility.set_definition('HSH','TNDR_TEXT',80);
      lics_inbound_utility.set_definition('HSH','TNDRDAT',8);
      lics_inbound_utility.set_definition('HSH','TNDRZET',6);
      lics_inbound_utility.set_definition('HSH','TNDR_MAXP',18);
      lics_inbound_utility.set_definition('HSH','TNDR_MAXC',5);
      lics_inbound_utility.set_definition('HSH','TNDR_ACTP',18);
      lics_inbound_utility.set_definition('HSH','TNDR_ACTC',5);
      lics_inbound_utility.set_definition('HSH','TNDR_CARR',10);
      lics_inbound_utility.set_definition('HSH','TNDR_CRNM',35);
      lics_inbound_utility.set_definition('HSH','TNDR_TRKID',35);
      lics_inbound_utility.set_definition('HSH','TNDR_EXPD',8);
      lics_inbound_utility.set_definition('HSH','TNDR_EXPT',6);
      lics_inbound_utility.set_definition('HSH','TNDR_ERPD',8);
      lics_inbound_utility.set_definition('HSH','TNDR_ERPT',6);
      lics_inbound_utility.set_definition('HSH','TNDR_LTPD',8);
      lics_inbound_utility.set_definition('HSH','TNDR_LTPT',6);
      lics_inbound_utility.set_definition('HSH','TNDR_ERDD',8);
      lics_inbound_utility.set_definition('HSH','TNDR_ERDT',6);
      lics_inbound_utility.set_definition('HSH','TNDR_LTDD',8);
      lics_inbound_utility.set_definition('HSH','TNDR_LTDT',6);
      lics_inbound_utility.set_definition('HSH','TNDR_LDLG',16);
      lics_inbound_utility.set_definition('HSH','TNDR_LDLU',3);
      lics_inbound_utility.set_definition('HSH','TNDRST_BEZ',60);
      lics_inbound_utility.set_definition('HSH','TNDRRC_BEZ',60);
      lics_inbound_utility.set_definition('HSH','VBELN',10);
      /*-*/
      lics_inbound_utility.set_definition('HAR','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HAR','PARTNER_Q',3);
      lics_inbound_utility.set_definition('HAR','ADDRESS_T',1);
      lics_inbound_utility.set_definition('HAR','PARTNER_ID',17);
      lics_inbound_utility.set_definition('HAR','JURISDIC',17);
      lics_inbound_utility.set_definition('HAR','LANGUAGE',2);
      lics_inbound_utility.set_definition('HAR','FORMOFADDR',15);
      lics_inbound_utility.set_definition('HAR','NAME1',40);
      lics_inbound_utility.set_definition('HAR','NAME2',40);
      lics_inbound_utility.set_definition('HAR','NAME3',40);
      lics_inbound_utility.set_definition('HAR','NAME4',40);
      lics_inbound_utility.set_definition('HAR','NAME_TEXT',50);
      lics_inbound_utility.set_definition('HAR','NAME_CO',40);
      lics_inbound_utility.set_definition('HAR','LOCATION',40);
      lics_inbound_utility.set_definition('HAR','BUILDING',10);
      lics_inbound_utility.set_definition('HAR','FLOOR',10);
      lics_inbound_utility.set_definition('HAR','ROOM',10);
      lics_inbound_utility.set_definition('HAR','STREET1',40);
      lics_inbound_utility.set_definition('HAR','STREET2',40);
      lics_inbound_utility.set_definition('HAR','STREET3',40);
      lics_inbound_utility.set_definition('HAR','HOUSE_SUPL',4);
      lics_inbound_utility.set_definition('HAR','HOUSE_RANG',10);
      lics_inbound_utility.set_definition('HAR','POSTL_COD1',10);
      lics_inbound_utility.set_definition('HAR','POSTL_COD3',10);
      lics_inbound_utility.set_definition('HAR','POSTL_AREA',15);
      lics_inbound_utility.set_definition('HAR','CITY1',40);
      lics_inbound_utility.set_definition('HAR','CITY2',40);
      lics_inbound_utility.set_definition('HAR','POSTL_PBOX',10);
      lics_inbound_utility.set_definition('HAR','POSTL_COD2',10);
      lics_inbound_utility.set_definition('HAR','POSTL_CITY',40);
      lics_inbound_utility.set_definition('HAR','TELEPHONE1',30);
      lics_inbound_utility.set_definition('HAR','TELEPHONE2',30);
      lics_inbound_utility.set_definition('HAR','TELEFAX',30);
      lics_inbound_utility.set_definition('HAR','TELEX',30);
      lics_inbound_utility.set_definition('HAR','E_MAIL',70);
      lics_inbound_utility.set_definition('HAR','COUNTRY1',3);
      lics_inbound_utility.set_definition('HAR','COUNTRY2',3);
      lics_inbound_utility.set_definition('HAR','REGION',3);
      lics_inbound_utility.set_definition('HAR','COUNTY_COD',3);
      lics_inbound_utility.set_definition('HAR','COUNTY_TXT',25);
      lics_inbound_utility.set_definition('HAR','TZCODE',6);
      lics_inbound_utility.set_definition('HAR','TZDESC',35);
      /*-*/
      lics_inbound_utility.set_definition('HDA','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HDA','QUALF',3);
      lics_inbound_utility.set_definition('HDA','VSTZW',4);
      lics_inbound_utility.set_definition('HDA','VSTZW_BEZ',20);
      lics_inbound_utility.set_definition('HDA','NTANF',8);
      lics_inbound_utility.set_definition('HDA','NTANZ',6);
      lics_inbound_utility.set_definition('HDA','NTEND',8);
      lics_inbound_utility.set_definition('HDA','NTENZ',6);
      lics_inbound_utility.set_definition('HDA','TZONE_BEG',6);
      lics_inbound_utility.set_definition('HDA','ISDD',8);
      lics_inbound_utility.set_definition('HDA','ISDZ',6);
      lics_inbound_utility.set_definition('HDA','IEDD',8);
      lics_inbound_utility.set_definition('HDA','IEDZ',6);
      lics_inbound_utility.set_definition('HDA','TZONE_END',6);
      lics_inbound_utility.set_definition('HDA','VORNR',4);
      lics_inbound_utility.set_definition('HDA','VSTGA',4);
      lics_inbound_utility.set_definition('HDA','VSTGA_BEZ',20);
      lics_inbound_utility.set_definition('HDA','EVENT',10);
      lics_inbound_utility.set_definition('HDA','EVENT_ALI',20);
      /*-*/
      lics_inbound_utility.set_definition('HST','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HST','TSNUM',4);
      lics_inbound_utility.set_definition('HST','TSRFO',4);
      lics_inbound_utility.set_definition('HST','TSTYP',1);
      lics_inbound_utility.set_definition('HST','VSART',2);
      lics_inbound_utility.set_definition('HST','INCO1',3);
      lics_inbound_utility.set_definition('HST','LAUFK',1);
      lics_inbound_utility.set_definition('HST','DISTZ',16);
      lics_inbound_utility.set_definition('HST','MEDST',3);
      lics_inbound_utility.set_definition('HST','FAHZT',8);
      lics_inbound_utility.set_definition('HST','GESZT',8);
      lics_inbound_utility.set_definition('HST','MEIZT',3);
      lics_inbound_utility.set_definition('HST','GESZTD',12);
      lics_inbound_utility.set_definition('HST','FAHZTD',12);
      lics_inbound_utility.set_definition('HST','GESZTDA',12);
      lics_inbound_utility.set_definition('HST','FAHZTDA',12);
      lics_inbound_utility.set_definition('HST','SDABW',4);
      lics_inbound_utility.set_definition('HST','FRKRL',1);
      lics_inbound_utility.set_definition('HST','SKALSM',6);
      lics_inbound_utility.set_definition('HST','FBSTA',1);
      lics_inbound_utility.set_definition('HST','ARSTA',1);
      lics_inbound_utility.set_definition('HST','WARZTD',12);
      lics_inbound_utility.set_definition('HST','WARZTDA',12);
      lics_inbound_utility.set_definition('HST','CONT_DG',1);
      lics_inbound_utility.set_definition('HST','TSTYP_BEZ',20);
      lics_inbound_utility.set_definition('HST','VSART_BEZ',20);
      lics_inbound_utility.set_definition('HST','INCO1_BEZ',30);
      lics_inbound_utility.set_definition('HST','LAUFK_BEZ',20);
      lics_inbound_utility.set_definition('HST','FBSTA_BEZ',25);
      lics_inbound_utility.set_definition('HST','ARSTA_BEZ',25);
      /*-*/
      lics_inbound_utility.set_definition('HSP','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HSP','QUALI',3);
      lics_inbound_utility.set_definition('HSP','KNOTE',10);
      lics_inbound_utility.set_definition('HSP','ADRNR',10);
      lics_inbound_utility.set_definition('HSP','VSTEL',4);
      lics_inbound_utility.set_definition('HSP','LSTEL',2);
      lics_inbound_utility.set_definition('HSP','WERKS',4);
      lics_inbound_utility.set_definition('HSP','LGORT',4);
      lics_inbound_utility.set_definition('HSP','KUNNR',10);
      lics_inbound_utility.set_definition('HSP','LIFNR',10);
      lics_inbound_utility.set_definition('HSP','ABLAD',25);
      lics_inbound_utility.set_definition('HSP','LGNUM',3);
      lics_inbound_utility.set_definition('HSP','LGTOR',3);
      lics_inbound_utility.set_definition('HSP','BAHNRA',10);
      lics_inbound_utility.set_definition('HSP','PARTNER_Q',3);
      lics_inbound_utility.set_definition('HSP','ADDRESS_T',1);
      lics_inbound_utility.set_definition('HSP','PARTNER_ID',17);
      lics_inbound_utility.set_definition('HSP','JURISDIC',17);
      lics_inbound_utility.set_definition('HSP','KNOTE_BEZ',30);
      lics_inbound_utility.set_definition('HSP','VSTEL_BEZ',30);
      lics_inbound_utility.set_definition('HSP','LSTEL_BEZ',20);
      lics_inbound_utility.set_definition('HSP','WERKS_BEZ',30);
      lics_inbound_utility.set_definition('HSP','LGORT_BEZ',16);
      lics_inbound_utility.set_definition('HSP','LGNUM_BEZ',25);
      lics_inbound_utility.set_definition('HSP','LGTOR_BEZ',25);
      /*-*/
      lics_inbound_utility.set_definition('HSD','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HSD','QUALF',3);
      lics_inbound_utility.set_definition('HSD','NTANF',8);
      lics_inbound_utility.set_definition('HSD','NTANZ',6);
      lics_inbound_utility.set_definition('HSD','NTEND',8);
      lics_inbound_utility.set_definition('HSD','NTENZ',6);
      lics_inbound_utility.set_definition('HSD','ISDD',8);
      lics_inbound_utility.set_definition('HSD','ISDZ',6);
      lics_inbound_utility.set_definition('HSD','IEDD',8);
      lics_inbound_utility.set_definition('HSD','IEDZ',6);
      lics_inbound_utility.set_definition('HSD','VORNR',4);
      lics_inbound_utility.set_definition('HSD','VSTGA',4);
      /*-*/
      lics_inbound_utility.set_definition('HSI','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HSI','VBELN',10);
      lics_inbound_utility.set_definition('HSI','PARID',35);
      /*-*/
      lics_inbound_utility.set_definition('HAG','HEADER CODE',3);
      lics_inbound_utility.set_definition('HAG','PARTNER_Q',3);
      lics_inbound_utility.set_definition('HAG','ADDRESS_T',1);
      lics_inbound_utility.set_definition('HAG','PARTNER_ID',17);
      lics_inbound_utility.set_definition('HAG','JURISDIC',17);
      /*-*/
      lics_inbound_utility.set_definition('INV','HEADER CODE',3);
      lics_inbound_utility.set_definition('INV','ZNBINVOIC',10);
      /*-*/
      lics_inbound_utility.set_definition('HIN','HEADER CODE',3);
      lics_inbound_utility.set_definition('HIN','ACTION',3);
      lics_inbound_utility.set_definition('HIN','KZABS',1);
      lics_inbound_utility.set_definition('HIN','CURCY',3);
      lics_inbound_utility.set_definition('HIN','HWAER',3);
      lics_inbound_utility.set_definition('HIN','WKURS',12);
      lics_inbound_utility.set_definition('HIN','ZTERM',17);
      lics_inbound_utility.set_definition('HIN','KUNDEUINR',20);
      lics_inbound_utility.set_definition('HIN','EIGENUINR',20);
      lics_inbound_utility.set_definition('HIN','BSART',4);
      lics_inbound_utility.set_definition('HIN','BELNR',35);
      lics_inbound_utility.set_definition('HIN','NTGEW',18);
      lics_inbound_utility.set_definition('HIN','BRGEW',18);
      lics_inbound_utility.set_definition('HIN','GEWEI',3);
      lics_inbound_utility.set_definition('HIN','FKART_RL',4);
      lics_inbound_utility.set_definition('HIN','ABLAD',25);
      lics_inbound_utility.set_definition('HIN','BSTZD',4);
      lics_inbound_utility.set_definition('HIN','VSART',2);
      lics_inbound_utility.set_definition('HIN','VSART_BEZ',20);
      lics_inbound_utility.set_definition('HIN','RECIPNT_NO',10);
      lics_inbound_utility.set_definition('HIN','KZAZU',1);
      lics_inbound_utility.set_definition('HIN','AUTLF',1);
      lics_inbound_utility.set_definition('HIN','AUGRU',3);
      lics_inbound_utility.set_definition('HIN','AUGRU_BEZ',40);
      lics_inbound_utility.set_definition('HIN','ABRVW',3);
      lics_inbound_utility.set_definition('HIN','ABRVW_BEZ',20);
      lics_inbound_utility.set_definition('HIN','FKTYP',1);
      lics_inbound_utility.set_definition('HIN','LIFSK',2);
      lics_inbound_utility.set_definition('HIN','LIFSK_BEZ',20);
      lics_inbound_utility.set_definition('HIN','EMPST',25);
      lics_inbound_utility.set_definition('HIN','ABTNR',4);
      lics_inbound_utility.set_definition('HIN','DELCO',3);
      lics_inbound_utility.set_definition('HIN','WKURS_M',12);
      lics_inbound_utility.set_definition('HIN','DEL_BELNR',35);
      /*-*/
      lics_inbound_utility.set_definition('IGN','HEADER CODE',3);
      lics_inbound_utility.set_definition('IGN','POSEX',6);
      lics_inbound_utility.set_definition('IGN','MENGE',15);
      lics_inbound_utility.set_definition('IGN','MENEE',3);
      lics_inbound_utility.set_definition('IGN','NTGEW',18);
      lics_inbound_utility.set_definition('IGN','GEWEI',3);
      lics_inbound_utility.set_definition('IGN','BRGEW',18);
      lics_inbound_utility.set_definition('IGN','PSTYV',4);
      lics_inbound_utility.set_definition('IGN','WERKS',4);
      /*-*/
      lics_inbound_utility.set_definition('IRE','HEADER CODE',3);
      lics_inbound_utility.set_definition('IRE','QUALF',3);
      lics_inbound_utility.set_definition('IRE','BELNR',35);
      lics_inbound_utility.set_definition('IRE','ZEILE',6);
      lics_inbound_utility.set_definition('IRE','DATUM',8);
      lics_inbound_utility.set_definition('IRE','UZEIT',6);
      lics_inbound_utility.set_definition('IRE','BSARK',35);
      lics_inbound_utility.set_definition('IRE','IHREZ',30);
      /*-*/
      lics_inbound_utility.set_definition('ICN','HEADER CODE',3);
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
      lics_inbound_utility.set_definition('SIN','HEADER CODE',3);
      lics_inbound_utility.set_definition('SIN','SUMID',3);
      lics_inbound_utility.set_definition('SIN','SUMME',18);
      lics_inbound_utility.set_definition('SIN','SUNIT',3);
      lics_inbound_utility.set_definition('SIN','WAERQ',3);
      /*-*/
      lics_inbound_utility.set_definition('IDT','HEADER CODE',3);
      lics_inbound_utility.set_definition('IDT','IDDAT',3);
      lics_inbound_utility.set_definition('IDT','DATUM',8);
      lics_inbound_utility.set_definition('IDT','UZEIT',6);


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
         when 'ORD' then process_record_ord(par_record);
         when 'HOR' then process_record_hor(par_record);
         when 'ORG' then process_record_org(par_record);
         when 'DAT' then process_record_dat(par_record);
         when 'PNR' then process_record_pnr(par_record);
         when 'GEN' then process_record_gen(par_record);
         when 'ICO' then process_record_ico(par_record);
         when 'SOR' then process_record_sor(par_record);
         when 'DEL' then process_record_del(par_record);
         when 'HDE' then process_record_hde(par_record);
         when 'ADD' then process_record_add(par_record);
         when 'TIM' then process_record_tim(par_record);
         when 'DET' then process_record_det(par_record);
         when 'INT' then process_record_int(par_record);
         when 'IRF' then process_record_irf(par_record);
         when 'ERF' then process_record_erf(par_record);
         when 'HUH' then process_record_huh(par_record);
         when 'HUC' then process_record_huc(par_record);
         when 'SHP' then process_record_shp(par_record);
         when 'HSH' then process_record_hsh(par_record);
         when 'HAR' then process_record_har(par_record);
         when 'HDA' then process_record_hda(par_record);
         when 'HST' then process_record_hst(par_record);
         when 'HSP' then process_record_hsp(par_record);
         when 'HSD' then process_record_hsd(par_record);
         when 'HSI' then process_record_hsi(par_record);
         when 'HAG' then process_record_hag(par_record);
         when 'INV' then process_record_inv(par_record);
         when 'HIN' then process_record_hin(par_record);
         when 'IGN' then process_record_ign(par_record);
         when 'IRE' then process_record_ire(par_record);
         when 'ICN' then process_record_icn(par_record);
         when 'SIN' then process_record_sin(par_record);
         when 'IDT' then process_record_idt(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD25';
      var_accepted boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false Then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true Then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
         
         begin
            lads_atllad25_monitor.execute_before(rcd_lads_exp_hdr.zzgrpnr);
         exception
            when others then
                lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
         
         commit;
         
         begin
            lads_atllad25_monitor.execute_after(rcd_lads_exp_hdr.zzgrpnr);
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
      rcd_lads_control.idoc_name := lics_inbound_utility.get_variable('IDOCTYP');
      if rcd_lads_control.idoc_name is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOCTYP - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC number
      /*-*/
      rcd_lads_control.idoc_number := lics_inbound_utility.get_number('DOCNUM','9999999999999999');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if rcd_lads_control.idoc_number is null then
         lics_inbound_utility.add_exception('Field - CTL.DOCNUM - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC timestamp
      /*-*/
      rcd_lads_control.idoc_timestamp := lics_inbound_utility.get_variable('CREDAT') || lics_inbound_utility.get_variable('CRETIM');
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
      cursor csr_lads_exp_hdr_01 is
         select
            t01.zzgrpnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_exp_hdr t01
         where t01.zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
      rcd_lads_exp_hdr_01 csr_lads_exp_hdr_01%rowtype;

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
      rcd_lads_exp_hdr.zzgrpnr := lics_inbound_utility.get_variable('ZZGRPNR');
      rcd_lads_exp_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_exp_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_exp_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_exp_hdr.lads_date := sysdate;
      rcd_lads_exp_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_ord.ordseq := 0;
      rcd_lads_exp_del.delseq := 0;
      rcd_lads_exp_shp.shpseq := 0;
      rcd_lads_exp_inv.invseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_hdr.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HDR - ZZGRPNR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_exp_hdr.zzgrpnr is null) then
         var_exists := true;
         open csr_lads_exp_hdr_01;
         fetch csr_lads_exp_hdr_01 into rcd_lads_exp_hdr_01;
         if csr_lads_exp_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_exp_hdr_01;
         if var_exists = true then
            if rcd_lads_exp_hdr.idoc_timestamp > rcd_lads_exp_hdr_01.idoc_timestamp then
               delete from lads_exp_idt where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_sin where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_icn where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_ire where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_ign where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hin where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_inv where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hag where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hsi where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hsd where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hsp where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hst where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_har where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hda where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hsh where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_shp where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_huc where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_huh where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_erf where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_irf where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_int where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_det where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_add where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_tim where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hde where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_del where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_sor where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_ico where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_gen where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_pnr where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_dat where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_org where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_hor where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
               delete from lads_exp_ord where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
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

      update lads_exp_hdr set
         zzgrpnr = rcd_lads_exp_hdr.zzgrpnr,
         idoc_name = rcd_lads_exp_hdr.idoc_name,
         idoc_number = rcd_lads_exp_hdr.idoc_number,
         idoc_timestamp = rcd_lads_exp_hdr.idoc_timestamp,
         lads_date = rcd_lads_exp_hdr.lads_date,
         lads_status = rcd_lads_exp_hdr.lads_status
      where zzgrpnr = rcd_lads_exp_hdr.zzgrpnr;
      if sql%notfound then
         insert into lads_exp_hdr
            (zzgrpnr,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_exp_hdr.zzgrpnr,
             rcd_lads_exp_hdr.idoc_name,
             rcd_lads_exp_hdr.idoc_number,
             rcd_lads_exp_hdr.idoc_timestamp,
             rcd_lads_exp_hdr.lads_date,
             rcd_lads_exp_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record ORD routine */
   /**************************************************/
   procedure process_record_ord(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ORD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_ord.zzgrpnr := rcd_lads_exp_hdr.zzgrpnr;
      rcd_lads_exp_ord.ordseq := rcd_lads_exp_ord.ordseq + 1;
      rcd_lads_exp_ord.znborders := lics_inbound_utility.get_variable('ZNBORDERS');
      rcd_lads_exp_ord.ztypord := lics_inbound_utility.get_variable('ZTYPORD');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_hor.horseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_ord.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_ORD - ZZGRPNR');
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

      insert into lads_exp_ord
         (zzgrpnr,
          ordseq,
          znborders,
          ztypord)
      values
         (rcd_lads_exp_ord.zzgrpnr,
          rcd_lads_exp_ord.ordseq,
          rcd_lads_exp_ord.znborders,
          rcd_lads_exp_ord.ztypord);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ord;

   /**************************************************/
   /* This procedure performs the record HOR routine */
   /**************************************************/
   procedure process_record_hor(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HOR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hor.zzgrpnr := rcd_lads_exp_ord.zzgrpnr;
      rcd_lads_exp_hor.ordseq := rcd_lads_exp_ord.ordseq;
      rcd_lads_exp_hor.horseq := rcd_lads_exp_hor.horseq + 1;
      rcd_lads_exp_hor.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_exp_hor.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_exp_hor.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_exp_hor.hwaer := lics_inbound_utility.get_variable('HWAER');
      rcd_lads_exp_hor.wkurs := lics_inbound_utility.get_variable('WKURS');
      rcd_lads_exp_hor.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_exp_hor.kundeuinr := lics_inbound_utility.get_variable('KUNDEUINR');
      rcd_lads_exp_hor.eigenuinr := lics_inbound_utility.get_variable('EIGENUINR');
      rcd_lads_exp_hor.bsart := lics_inbound_utility.get_variable('BSART');
      rcd_lads_exp_hor.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_exp_hor.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_exp_hor.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_exp_hor.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_exp_hor.fkart_rl := lics_inbound_utility.get_variable('FKART_RL');
      rcd_lads_exp_hor.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_exp_hor.bstzd := lics_inbound_utility.get_variable('BSTZD');
      rcd_lads_exp_hor.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_exp_hor.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_exp_hor.recipnt_no := lics_inbound_utility.get_variable('RECIPNT_NO');
      rcd_lads_exp_hor.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_exp_hor.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_lads_exp_hor.augru := lics_inbound_utility.get_variable('AUGRU');
      rcd_lads_exp_hor.augru_bez := lics_inbound_utility.get_variable('AUGRU_BEZ');
      rcd_lads_exp_hor.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_exp_hor.abrvw_bez := lics_inbound_utility.get_variable('ABRVW_BEZ');
      rcd_lads_exp_hor.fktyp := lics_inbound_utility.get_variable('FKTYP');
      rcd_lads_exp_hor.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_lads_exp_hor.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_lads_exp_hor.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_exp_hor.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_exp_hor.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_exp_hor.wkurs_m := lics_inbound_utility.get_variable('WKURS_M');
      rcd_lads_exp_hor.zzshipto := lics_inbound_utility.get_variable('ZZSHIPTO');
      rcd_lads_exp_hor.zzsoldto := lics_inbound_utility.get_variable('ZZSOLDTO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_org.orgseq := 0;
      rcd_lads_exp_dat.datseq := 0;
      rcd_lads_exp_pnr.pnrseq := 0;
      rcd_lads_exp_gen.genseq := 0;
      rcd_lads_exp_sor.sorseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_hor.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HOR - ZZGRPNR');
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

      insert into lads_exp_hor
         (zzgrpnr,
          ordseq,
          horseq,
          action,
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
          zzshipto,
          zzsoldto)
      values
         (rcd_lads_exp_hor.zzgrpnr,
          rcd_lads_exp_hor.ordseq,
          rcd_lads_exp_hor.horseq,
          rcd_lads_exp_hor.action,
          rcd_lads_exp_hor.kzabs,
          rcd_lads_exp_hor.curcy,
          rcd_lads_exp_hor.hwaer,
          rcd_lads_exp_hor.wkurs,
          rcd_lads_exp_hor.zterm,
          rcd_lads_exp_hor.kundeuinr,
          rcd_lads_exp_hor.eigenuinr,
          rcd_lads_exp_hor.bsart,
          rcd_lads_exp_hor.belnr,
          rcd_lads_exp_hor.ntgew,
          rcd_lads_exp_hor.brgew,
          rcd_lads_exp_hor.gewei,
          rcd_lads_exp_hor.fkart_rl,
          rcd_lads_exp_hor.ablad,
          rcd_lads_exp_hor.bstzd,
          rcd_lads_exp_hor.vsart,
          rcd_lads_exp_hor.vsart_bez,
          rcd_lads_exp_hor.recipnt_no,
          rcd_lads_exp_hor.kzazu,
          rcd_lads_exp_hor.autlf,
          rcd_lads_exp_hor.augru,
          rcd_lads_exp_hor.augru_bez,
          rcd_lads_exp_hor.abrvw,
          rcd_lads_exp_hor.abrvw_bez,
          rcd_lads_exp_hor.fktyp,
          rcd_lads_exp_hor.lifsk,
          rcd_lads_exp_hor.lifsk_bez,
          rcd_lads_exp_hor.empst,
          rcd_lads_exp_hor.abtnr,
          rcd_lads_exp_hor.delco,
          rcd_lads_exp_hor.wkurs_m,
          rcd_lads_exp_hor.zzshipto,
          rcd_lads_exp_hor.zzsoldto);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hor;

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
      rcd_lads_exp_org.zzgrpnr := rcd_lads_exp_hor.zzgrpnr;
      rcd_lads_exp_org.ordseq := rcd_lads_exp_hor.ordseq;
      rcd_lads_exp_org.horseq := rcd_lads_exp_hor.horseq;
      rcd_lads_exp_org.orgseq := rcd_lads_exp_org.orgseq + 1;
      rcd_lads_exp_org.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_exp_org.orgid := lics_inbound_utility.get_variable('ORGID');

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
      if rcd_lads_exp_org.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_ORG - ZZGRPNR');
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

      insert into lads_exp_org
         (zzgrpnr,
          ordseq,
          horseq,
          orgseq,
          qualf,
          orgid)
      values
         (rcd_lads_exp_org.zzgrpnr,
          rcd_lads_exp_org.ordseq,
          rcd_lads_exp_org.horseq,
          rcd_lads_exp_org.orgseq,
          rcd_lads_exp_org.qualf,
          rcd_lads_exp_org.orgid);

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
      rcd_lads_exp_dat.zzgrpnr := rcd_lads_exp_hor.zzgrpnr;
      rcd_lads_exp_dat.ordseq := rcd_lads_exp_hor.ordseq;
      rcd_lads_exp_dat.horseq := rcd_lads_exp_hor.horseq;
      rcd_lads_exp_dat.datseq := rcd_lads_exp_dat.datseq + 1;
      rcd_lads_exp_dat.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_lads_exp_dat.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_exp_dat.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_exp_dat.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_DAT - ZZGRPNR');
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

      insert into lads_exp_dat
         (zzgrpnr,
          ordseq,
          horseq,
          datseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_lads_exp_dat.zzgrpnr,
          rcd_lads_exp_dat.ordseq,
          rcd_lads_exp_dat.horseq,
          rcd_lads_exp_dat.datseq,
          rcd_lads_exp_dat.iddat,
          rcd_lads_exp_dat.datum,
          rcd_lads_exp_dat.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

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
      rcd_lads_exp_pnr.zzgrpnr := rcd_lads_exp_hor.zzgrpnr;
      rcd_lads_exp_pnr.ordseq := rcd_lads_exp_hor.ordseq;
      rcd_lads_exp_pnr.horseq := rcd_lads_exp_hor.horseq;
      rcd_lads_exp_pnr.pnrseq := rcd_lads_exp_pnr.pnrseq + 1;
      rcd_lads_exp_pnr.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_exp_pnr.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_lads_exp_pnr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_exp_pnr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_exp_pnr.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_exp_pnr.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_exp_pnr.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_exp_pnr.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_exp_pnr.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_lads_exp_pnr.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_lads_exp_pnr.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_exp_pnr.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_lads_exp_pnr.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_lads_exp_pnr.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_lads_exp_pnr.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_exp_pnr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_exp_pnr.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_lads_exp_pnr.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_lads_exp_pnr.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_exp_pnr.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_lads_exp_pnr.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_lads_exp_pnr.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_lads_exp_pnr.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_lads_exp_pnr.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_lads_exp_pnr.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_exp_pnr.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_exp_pnr.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_exp_pnr.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_lads_exp_pnr.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_lads_exp_pnr.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_lads_exp_pnr.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_lads_exp_pnr.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_lads_exp_pnr.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_lads_exp_pnr.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_lads_exp_pnr.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_exp_pnr.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_exp_pnr.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_lads_exp_pnr.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_lads_exp_pnr.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_lads_exp_pnr.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_exp_pnr.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_lads_exp_pnr.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_lads_exp_pnr.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_lads_exp_pnr.title := lics_inbound_utility.get_variable('TITLE');

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
      if rcd_lads_exp_pnr.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_PNR - ZZGRPNR');
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

      insert into lads_exp_pnr
         (zzgrpnr,
          ordseq,
          horseq,
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
         (rcd_lads_exp_pnr.zzgrpnr,
          rcd_lads_exp_pnr.ordseq,
          rcd_lads_exp_pnr.horseq,
          rcd_lads_exp_pnr.pnrseq,
          rcd_lads_exp_pnr.parvw,
          rcd_lads_exp_pnr.partn,
          rcd_lads_exp_pnr.lifnr,
          rcd_lads_exp_pnr.name1,
          rcd_lads_exp_pnr.name2,
          rcd_lads_exp_pnr.name3,
          rcd_lads_exp_pnr.name4,
          rcd_lads_exp_pnr.stras,
          rcd_lads_exp_pnr.strs2,
          rcd_lads_exp_pnr.pfach,
          rcd_lads_exp_pnr.ort01,
          rcd_lads_exp_pnr.counc,
          rcd_lads_exp_pnr.pstlz,
          rcd_lads_exp_pnr.pstl2,
          rcd_lads_exp_pnr.land1,
          rcd_lads_exp_pnr.ablad,
          rcd_lads_exp_pnr.pernr,
          rcd_lads_exp_pnr.parnr,
          rcd_lads_exp_pnr.telf1,
          rcd_lads_exp_pnr.telf2,
          rcd_lads_exp_pnr.telbx,
          rcd_lads_exp_pnr.telfx,
          rcd_lads_exp_pnr.teltx,
          rcd_lads_exp_pnr.telx1,
          rcd_lads_exp_pnr.spras,
          rcd_lads_exp_pnr.anred,
          rcd_lads_exp_pnr.ort02,
          rcd_lads_exp_pnr.hausn,
          rcd_lads_exp_pnr.stock,
          rcd_lads_exp_pnr.regio,
          rcd_lads_exp_pnr.parge,
          rcd_lads_exp_pnr.isoal,
          rcd_lads_exp_pnr.isonu,
          rcd_lads_exp_pnr.fcode,
          rcd_lads_exp_pnr.ihrez,
          rcd_lads_exp_pnr.bname,
          rcd_lads_exp_pnr.paorg,
          rcd_lads_exp_pnr.orgtx,
          rcd_lads_exp_pnr.pagru,
          rcd_lads_exp_pnr.knref,
          rcd_lads_exp_pnr.ilnnr,
          rcd_lads_exp_pnr.pfort,
          rcd_lads_exp_pnr.spras_iso,
          rcd_lads_exp_pnr.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pnr;

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
      rcd_lads_exp_gen.zzgrpnr := rcd_lads_exp_hor.zzgrpnr;
      rcd_lads_exp_gen.ordseq := rcd_lads_exp_hor.ordseq;
      rcd_lads_exp_gen.horseq := rcd_lads_exp_hor.horseq;
      rcd_lads_exp_gen.genseq := rcd_lads_exp_gen.genseq + 1;
      rcd_lads_exp_gen.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_lads_exp_gen.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_exp_gen.pstyp := lics_inbound_utility.get_variable('PSTYP');
      rcd_lads_exp_gen.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_exp_gen.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_exp_gen.menee := lics_inbound_utility.get_variable('MENEE');
      rcd_lads_exp_gen.bmng2 := lics_inbound_utility.get_variable('BMNG2');
      rcd_lads_exp_gen.pmene := lics_inbound_utility.get_variable('PMENE');
      rcd_lads_exp_gen.abftz := lics_inbound_utility.get_variable('ABFTZ');
      rcd_lads_exp_gen.vprei := lics_inbound_utility.get_variable('VPREI');
      rcd_lads_exp_gen.peinh := lics_inbound_utility.get_variable('PEINH');
      rcd_lads_exp_gen.netwr := lics_inbound_utility.get_variable('NETWR');
      rcd_lads_exp_gen.anetw := lics_inbound_utility.get_variable('ANETW');
      rcd_lads_exp_gen.skfbp := lics_inbound_utility.get_variable('SKFBP');
      rcd_lads_exp_gen.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_exp_gen.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_exp_gen.einkz := lics_inbound_utility.get_variable('EINKZ');
      rcd_lads_exp_gen.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_exp_gen.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_exp_gen.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_exp_gen.uepos := lics_inbound_utility.get_variable('UEPOS');
      rcd_lads_exp_gen.grkor := lics_inbound_utility.get_variable('GRKOR');
      rcd_lads_exp_gen.evers := lics_inbound_utility.get_variable('EVERS');
      rcd_lads_exp_gen.bpumn := lics_inbound_utility.get_number('BPUMN',null);
      rcd_lads_exp_gen.bpumz := lics_inbound_utility.get_number('BPUMZ',null);
      rcd_lads_exp_gen.abgru := lics_inbound_utility.get_variable('ABGRU');
      rcd_lads_exp_gen.abgrt := lics_inbound_utility.get_variable('ABGRT');
      rcd_lads_exp_gen.antlf := lics_inbound_utility.get_variable('ANTLF');
      rcd_lads_exp_gen.fixmg := lics_inbound_utility.get_variable('FIXMG');
      rcd_lads_exp_gen.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_exp_gen.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_exp_gen.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_lads_exp_gen.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_exp_gen.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_exp_gen.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_exp_gen.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_exp_gen.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_lads_exp_gen.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_lads_exp_gen.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_exp_gen.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_exp_gen.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_exp_gen.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_exp_gen.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_exp_gen.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_exp_gen.valtg := lics_inbound_utility.get_number('VALTG',null);
      rcd_lads_exp_gen.hipos := lics_inbound_utility.get_number('HIPOS',null);
      rcd_lads_exp_gen.hievw := lics_inbound_utility.get_variable('HIEVW');
      rcd_lads_exp_gen.posguid := lics_inbound_utility.get_variable('POSGUID');
      rcd_lads_exp_gen.zzact_qty := lics_inbound_utility.get_number('ZZACT_QTY',null);
      rcd_lads_exp_gen.zzdeluom := lics_inbound_utility.get_variable('ZZDELUOM');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_ico.icoseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_gen.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_GEN - ZZGRPNR');
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

      insert into lads_exp_gen
         (zzgrpnr,
          ordseq,
          horseq,
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
          zzact_qty,
          zzdeluom)
      values
         (rcd_lads_exp_gen.zzgrpnr,
          rcd_lads_exp_gen.ordseq,
          rcd_lads_exp_gen.horseq,
          rcd_lads_exp_gen.genseq,
          rcd_lads_exp_gen.posex,
          rcd_lads_exp_gen.action,
          rcd_lads_exp_gen.pstyp,
          rcd_lads_exp_gen.kzabs,
          rcd_lads_exp_gen.menge,
          rcd_lads_exp_gen.menee,
          rcd_lads_exp_gen.bmng2,
          rcd_lads_exp_gen.pmene,
          rcd_lads_exp_gen.abftz,
          rcd_lads_exp_gen.vprei,
          rcd_lads_exp_gen.peinh,
          rcd_lads_exp_gen.netwr,
          rcd_lads_exp_gen.anetw,
          rcd_lads_exp_gen.skfbp,
          rcd_lads_exp_gen.ntgew,
          rcd_lads_exp_gen.gewei,
          rcd_lads_exp_gen.einkz,
          rcd_lads_exp_gen.curcy,
          rcd_lads_exp_gen.preis,
          rcd_lads_exp_gen.matkl,
          rcd_lads_exp_gen.uepos,
          rcd_lads_exp_gen.grkor,
          rcd_lads_exp_gen.evers,
          rcd_lads_exp_gen.bpumn,
          rcd_lads_exp_gen.bpumz,
          rcd_lads_exp_gen.abgru,
          rcd_lads_exp_gen.abgrt,
          rcd_lads_exp_gen.antlf,
          rcd_lads_exp_gen.fixmg,
          rcd_lads_exp_gen.kzazu,
          rcd_lads_exp_gen.brgew,
          rcd_lads_exp_gen.pstyv,
          rcd_lads_exp_gen.empst,
          rcd_lads_exp_gen.abtnr,
          rcd_lads_exp_gen.abrvw,
          rcd_lads_exp_gen.werks,
          rcd_lads_exp_gen.lprio,
          rcd_lads_exp_gen.lprio_bez,
          rcd_lads_exp_gen.route,
          rcd_lads_exp_gen.route_bez,
          rcd_lads_exp_gen.lgort,
          rcd_lads_exp_gen.vstel,
          rcd_lads_exp_gen.delco,
          rcd_lads_exp_gen.matnr,
          rcd_lads_exp_gen.valtg,
          rcd_lads_exp_gen.hipos,
          rcd_lads_exp_gen.hievw,
          rcd_lads_exp_gen.posguid,
          rcd_lads_exp_gen.zzact_qty,
          rcd_lads_exp_gen.zzdeluom);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_gen;

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
      rcd_lads_exp_ico.zzgrpnr := rcd_lads_exp_gen.zzgrpnr;
      rcd_lads_exp_ico.ordseq := rcd_lads_exp_gen.ordseq;
      rcd_lads_exp_ico.horseq := rcd_lads_exp_gen.horseq;
      rcd_lads_exp_ico.genseq := rcd_lads_exp_gen.genseq;
      rcd_lads_exp_ico.icoseq := rcd_lads_exp_ico.icoseq + 1;
      rcd_lads_exp_ico.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_lads_exp_ico.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_exp_ico.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_lads_exp_ico.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_exp_ico.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_lads_exp_ico.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_lads_exp_ico.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_lads_exp_ico.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_lads_exp_ico.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_lads_exp_ico.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_exp_ico.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_exp_ico.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_exp_ico.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_exp_ico.koein := lics_inbound_utility.get_variable('KOEIN');
      rcd_lads_exp_ico.curtp := lics_inbound_utility.get_variable('CURTP');
      rcd_lads_exp_ico.kobas := lics_inbound_utility.get_variable('KOBAS');

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
      if rcd_lads_exp_ico.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_ICO - ZZGRPNR');
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

      insert into lads_exp_ico
         (zzgrpnr,
          ordseq,
          horseq,
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
         (rcd_lads_exp_ico.zzgrpnr,
          rcd_lads_exp_ico.ordseq,
          rcd_lads_exp_ico.horseq,
          rcd_lads_exp_ico.genseq,
          rcd_lads_exp_ico.icoseq,
          rcd_lads_exp_ico.alckz,
          rcd_lads_exp_ico.kschl,
          rcd_lads_exp_ico.kotxt,
          rcd_lads_exp_ico.betrg,
          rcd_lads_exp_ico.kperc,
          rcd_lads_exp_ico.krate,
          rcd_lads_exp_ico.uprbs,
          rcd_lads_exp_ico.meaun,
          rcd_lads_exp_ico.kobtr,
          rcd_lads_exp_ico.menge,
          rcd_lads_exp_ico.preis,
          rcd_lads_exp_ico.mwskz,
          rcd_lads_exp_ico.msatz,
          rcd_lads_exp_ico.koein,
          rcd_lads_exp_ico.curtp,
          rcd_lads_exp_ico.kobas);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ico;

   /**************************************************/
   /* This procedure performs the record SOR routine */
   /**************************************************/
   procedure process_record_sor(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SOR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_sor.zzgrpnr := rcd_lads_exp_hor.zzgrpnr;
      rcd_lads_exp_sor.ordseq := rcd_lads_exp_hor.ordseq;
      rcd_lads_exp_sor.horseq := rcd_lads_exp_hor.horseq;
      rcd_lads_exp_sor.sorseq := rcd_lads_exp_sor.sorseq + 1;
      rcd_lads_exp_sor.sumid := lics_inbound_utility.get_variable('SUMID');
      rcd_lads_exp_sor.summe := lics_inbound_utility.get_variable('SUMME');
      rcd_lads_exp_sor.sunit := lics_inbound_utility.get_variable('SUNIT');
      rcd_lads_exp_sor.waerq := lics_inbound_utility.get_variable('WAERQ');

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
      if rcd_lads_exp_sor.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_SOR - ZZGRPNR');
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

      insert into lads_exp_sor
         (zzgrpnr,
          ordseq,
          horseq,
          sorseq,
          sumid,
          summe,
          sunit,
          waerq)
      values
         (rcd_lads_exp_sor.zzgrpnr,
          rcd_lads_exp_sor.ordseq,
          rcd_lads_exp_sor.horseq,
          rcd_lads_exp_sor.sorseq,
          rcd_lads_exp_sor.sumid,
          rcd_lads_exp_sor.summe,
          rcd_lads_exp_sor.sunit,
          rcd_lads_exp_sor.waerq);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_sor;

   /**************************************************/
   /* This procedure performs the record DEL routine */
   /**************************************************/
   procedure process_record_del(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DEL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_del.zzgrpnr := rcd_lads_exp_hdr.zzgrpnr;
      rcd_lads_exp_del.delseq := rcd_lads_exp_del.delseq + 1;
      rcd_lads_exp_del.znbdelvry := lics_inbound_utility.get_variable('ZNBDELVRY');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_hde.hdeseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_del.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_DEL - ZZGRPNR');
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

      insert into lads_exp_del
         (zzgrpnr,
          delseq,
          znbdelvry)
      values
         (rcd_lads_exp_del.zzgrpnr,
          rcd_lads_exp_del.delseq,
          rcd_lads_exp_del.znbdelvry);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_del;

   /**************************************************/
   /* This procedure performs the record HDE routine */
   /**************************************************/
   procedure process_record_hde(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HDE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hde.zzgrpnr := rcd_lads_exp_del.zzgrpnr;
      rcd_lads_exp_hde.delseq := rcd_lads_exp_del.delseq;
      rcd_lads_exp_hde.hdeseq := rcd_lads_exp_hde.hdeseq + 1;
      rcd_lads_exp_hde.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_lads_exp_hde.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_exp_hde.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_exp_hde.lstel := lics_inbound_utility.get_variable('LSTEL');
      rcd_lads_exp_hde.vkbur := lics_inbound_utility.get_variable('VKBUR');
      rcd_lads_exp_hde.lgnum := lics_inbound_utility.get_variable('LGNUM');
      rcd_lads_exp_hde.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_exp_hde.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_lads_exp_hde.inco2 := lics_inbound_utility.get_variable('INCO2');
      rcd_lads_exp_hde.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_exp_hde.vsbed := lics_inbound_utility.get_variable('VSBED');
      rcd_lads_exp_hde.btgew := lics_inbound_utility.get_number('BTGEW',null);
      rcd_lads_exp_hde.ntgew := lics_inbound_utility.get_number('NTGEW',null);
      rcd_lads_exp_hde.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_exp_hde.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_lads_exp_hde.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_lads_exp_hde.anzpk := lics_inbound_utility.get_number('ANZPK',null);
      rcd_lads_exp_hde.bolnr := lics_inbound_utility.get_variable('BOLNR');
      rcd_lads_exp_hde.traty := lics_inbound_utility.get_variable('TRATY');
      rcd_lads_exp_hde.traid := lics_inbound_utility.get_variable('TRAID');
      rcd_lads_exp_hde.xabln := lics_inbound_utility.get_variable('XABLN');
      rcd_lads_exp_hde.lifex := lics_inbound_utility.get_variable('LIFEX');
      rcd_lads_exp_hde.parid := lics_inbound_utility.get_variable('PARID');
      rcd_lads_exp_hde.podat := lics_inbound_utility.get_variable('PODAT');
      rcd_lads_exp_hde.potim := lics_inbound_utility.get_variable('POTIM');
      rcd_lads_exp_hde.vstel_bez := lics_inbound_utility.get_variable('VSTEL_BEZ');
      rcd_lads_exp_hde.vkorg_bez := lics_inbound_utility.get_variable('VKORG_BEZ');
      rcd_lads_exp_hde.lstel_bez := lics_inbound_utility.get_variable('LSTEL_BEZ');
      rcd_lads_exp_hde.vkbur_bez := lics_inbound_utility.get_variable('VKBUR_BEZ');
      rcd_lads_exp_hde.lgnum_bez := lics_inbound_utility.get_variable('LGNUM_BEZ');
      rcd_lads_exp_hde.inco1_bez := lics_inbound_utility.get_variable('INCO1_BEZ');
      rcd_lads_exp_hde.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_exp_hde.vsbed_bez := lics_inbound_utility.get_variable('VSBED_BEZ');
      rcd_lads_exp_hde.traty_bez := lics_inbound_utility.get_variable('TRATY_BEZ');
      rcd_lads_exp_hde.lfart := lics_inbound_utility.get_variable('LFART');
      rcd_lads_exp_hde.bzirk := lics_inbound_utility.get_variable('BZIRK');
      rcd_lads_exp_hde.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_lads_exp_hde.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_lads_exp_hde.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_lads_exp_hde.kdgrp := lics_inbound_utility.get_variable('KDGRP');
      rcd_lads_exp_hde.berot := lics_inbound_utility.get_variable('BEROT');
      rcd_lads_exp_hde.tragr := lics_inbound_utility.get_variable('TRAGR');
      rcd_lads_exp_hde.trspg := lics_inbound_utility.get_variable('TRSPG');
      rcd_lads_exp_hde.aulwe := lics_inbound_utility.get_variable('AULWE');
      rcd_lads_exp_hde.lfart_bez := lics_inbound_utility.get_variable('LFART_BEZ');
      rcd_lads_exp_hde.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_lads_exp_hde.bzirk_bez := lics_inbound_utility.get_variable('BZIRK_BEZ');
      rcd_lads_exp_hde.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_lads_exp_hde.kdgrp_bez := lics_inbound_utility.get_variable('KDGRP_BEZ');
      rcd_lads_exp_hde.tragr_bez := lics_inbound_utility.get_variable('TRAGR_BEZ');
      rcd_lads_exp_hde.trspg_bez := lics_inbound_utility.get_variable('TRSPG_BEZ');
      rcd_lads_exp_hde.aulwe_bez := lics_inbound_utility.get_variable('AULWE_BEZ');
      rcd_lads_exp_hde.zzcontseal := lics_inbound_utility.get_variable('ZZCONTSEAL');
      rcd_lads_exp_hde.zztarif := lics_inbound_utility.get_variable('ZZTARIF');
      rcd_lads_exp_hde.zztotpikqty := lics_inbound_utility.get_number('ZZTOTPIKQTY',null);
      rcd_lads_exp_hde.belnr := lics_inbound_utility.get_variable('BELNR');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_add.addseq := 0;
      rcd_lads_exp_tim.timseq := 0;
      rcd_lads_exp_det.detseq := 0;
      rcd_lads_exp_huh.huhseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_hde.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HDE - ZZGRPNR');
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

      insert into lads_exp_hde
         (zzgrpnr,
          delseq,
          hdeseq,
          vbeln,
          vstel,
          vkorg,
          lstel,
          vkbur,
          lgnum,
          ablad,
          inco1,
          inco2,
          route,
          vsbed,
          btgew,
          ntgew,
          gewei,
          volum,
          voleh,
          anzpk,
          bolnr,
          traty,
          traid,
          xabln,
          lifex,
          parid,
          podat,
          potim,
          vstel_bez,
          vkorg_bez,
          lstel_bez,
          vkbur_bez,
          lgnum_bez,
          inco1_bez,
          route_bez,
          vsbed_bez,
          traty_bez,
          lfart,
          bzirk,
          autlf,
          lifsk,
          lprio,
          kdgrp,
          berot,
          tragr,
          trspg,
          aulwe,
          lfart_bez,
          lprio_bez,
          bzirk_bez,
          lifsk_bez,
          kdgrp_bez,
          tragr_bez,
          trspg_bez,
          aulwe_bez,
          zzcontseal,
          zztarif,
          zztotpikqty,
          belnr)
      values
         (rcd_lads_exp_hde.zzgrpnr,
          rcd_lads_exp_hde.delseq,
          rcd_lads_exp_hde.hdeseq,
          rcd_lads_exp_hde.vbeln,
          rcd_lads_exp_hde.vstel,
          rcd_lads_exp_hde.vkorg,
          rcd_lads_exp_hde.lstel,
          rcd_lads_exp_hde.vkbur,
          rcd_lads_exp_hde.lgnum,
          rcd_lads_exp_hde.ablad,
          rcd_lads_exp_hde.inco1,
          rcd_lads_exp_hde.inco2,
          rcd_lads_exp_hde.route,
          rcd_lads_exp_hde.vsbed,
          rcd_lads_exp_hde.btgew,
          rcd_lads_exp_hde.ntgew,
          rcd_lads_exp_hde.gewei,
          rcd_lads_exp_hde.volum,
          rcd_lads_exp_hde.voleh,
          rcd_lads_exp_hde.anzpk,
          rcd_lads_exp_hde.bolnr,
          rcd_lads_exp_hde.traty,
          rcd_lads_exp_hde.traid,
          rcd_lads_exp_hde.xabln,
          rcd_lads_exp_hde.lifex,
          rcd_lads_exp_hde.parid,
          rcd_lads_exp_hde.podat,
          rcd_lads_exp_hde.potim,
          rcd_lads_exp_hde.vstel_bez,
          rcd_lads_exp_hde.vkorg_bez,
          rcd_lads_exp_hde.lstel_bez,
          rcd_lads_exp_hde.vkbur_bez,
          rcd_lads_exp_hde.lgnum_bez,
          rcd_lads_exp_hde.inco1_bez,
          rcd_lads_exp_hde.route_bez,
          rcd_lads_exp_hde.vsbed_bez,
          rcd_lads_exp_hde.traty_bez,
          rcd_lads_exp_hde.lfart,
          rcd_lads_exp_hde.bzirk,
          rcd_lads_exp_hde.autlf,
          rcd_lads_exp_hde.lifsk,
          rcd_lads_exp_hde.lprio,
          rcd_lads_exp_hde.kdgrp,
          rcd_lads_exp_hde.berot,
          rcd_lads_exp_hde.tragr,
          rcd_lads_exp_hde.trspg,
          rcd_lads_exp_hde.aulwe,
          rcd_lads_exp_hde.lfart_bez,
          rcd_lads_exp_hde.lprio_bez,
          rcd_lads_exp_hde.bzirk_bez,
          rcd_lads_exp_hde.lifsk_bez,
          rcd_lads_exp_hde.kdgrp_bez,
          rcd_lads_exp_hde.tragr_bez,
          rcd_lads_exp_hde.trspg_bez,
          rcd_lads_exp_hde.aulwe_bez,
          rcd_lads_exp_hde.zzcontseal,
          rcd_lads_exp_hde.zztarif,
          rcd_lads_exp_hde.zztotpikqty,
          rcd_lads_exp_hde.belnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hde;

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
      rcd_lads_exp_add.zzgrpnr := rcd_lads_exp_hde.zzgrpnr;
      rcd_lads_exp_add.delseq := rcd_lads_exp_hde.delseq;
      rcd_lads_exp_add.hdeseq := rcd_lads_exp_hde.hdeseq;
      rcd_lads_exp_add.addseq := rcd_lads_exp_add.addseq + 1;
      rcd_lads_exp_add.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_exp_add.address_t := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_lads_exp_add.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_exp_add.jurisdic := lics_inbound_utility.get_variable('JURISDIC');
      rcd_lads_exp_add.language := lics_inbound_utility.get_variable('LANGUAGE');
      rcd_lads_exp_add.formofaddr := lics_inbound_utility.get_variable('FORMOFADDR');
      rcd_lads_exp_add.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_exp_add.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_exp_add.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_exp_add.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_exp_add.name_text := lics_inbound_utility.get_variable('NAME_TEXT');
      rcd_lads_exp_add.name_co := lics_inbound_utility.get_variable('NAME_CO');
      rcd_lads_exp_add.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_exp_add.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_exp_add.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_exp_add.room := lics_inbound_utility.get_variable('ROOM');
      rcd_lads_exp_add.street1 := lics_inbound_utility.get_variable('STREET1');
      rcd_lads_exp_add.street2 := lics_inbound_utility.get_variable('STREET2');
      rcd_lads_exp_add.street3 := lics_inbound_utility.get_variable('STREET3');
      rcd_lads_exp_add.house_supl := lics_inbound_utility.get_variable('HOUSE_SUPL');
      rcd_lads_exp_add.house_rang := lics_inbound_utility.get_variable('HOUSE_RANG');
      rcd_lads_exp_add.postl_cod1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_lads_exp_add.postl_cod3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_lads_exp_add.postl_area := lics_inbound_utility.get_variable('POSTL_AREA');
      rcd_lads_exp_add.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_exp_add.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_exp_add.postl_pbox := lics_inbound_utility.get_variable('POSTL_PBOX');
      rcd_lads_exp_add.postl_cod2 := lics_inbound_utility.get_variable('POSTL_COD2');
      rcd_lads_exp_add.postl_city := lics_inbound_utility.get_variable('POSTL_CITY');
      rcd_lads_exp_add.telephone1 := lics_inbound_utility.get_variable('TELEPHONE1');
      rcd_lads_exp_add.telephone2 := lics_inbound_utility.get_variable('TELEPHONE2');
      rcd_lads_exp_add.telefax := lics_inbound_utility.get_variable('TELEFAX');
      rcd_lads_exp_add.telex := lics_inbound_utility.get_variable('TELEX');
      rcd_lads_exp_add.e_mail := lics_inbound_utility.get_variable('E_MAIL');
      rcd_lads_exp_add.country1 := lics_inbound_utility.get_variable('COUNTRY1');
      rcd_lads_exp_add.country2 := lics_inbound_utility.get_variable('COUNTRY2');
      rcd_lads_exp_add.region := lics_inbound_utility.get_variable('REGION');
      rcd_lads_exp_add.county_cod := lics_inbound_utility.get_variable('COUNTY_COD');
      rcd_lads_exp_add.county_txt := lics_inbound_utility.get_variable('COUNTY_TXT');
      rcd_lads_exp_add.tzcode := lics_inbound_utility.get_variable('TZCODE');
      rcd_lads_exp_add.tzdesc := lics_inbound_utility.get_variable('TZDESC');

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
      if rcd_lads_exp_add.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_ADD - ZZGRPNR');
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

      insert into lads_exp_add
         (zzgrpnr,
          delseq,
          hdeseq,
          addseq,
          partner_q,
          address_t,
          partner_id,
          jurisdic,
          language,
          formofaddr,
          name1,
          name2,
          name3,
          name4,
          name_text,
          name_co,
          location,
          building,
          floor,
          room,
          street1,
          street2,
          street3,
          house_supl,
          house_rang,
          postl_cod1,
          postl_cod3,
          postl_area,
          city1,
          city2,
          postl_pbox,
          postl_cod2,
          postl_city,
          telephone1,
          telephone2,
          telefax,
          telex,
          e_mail,
          country1,
          country2,
          region,
          county_cod,
          county_txt,
          tzcode,
          tzdesc)
      values
         (rcd_lads_exp_add.zzgrpnr,
          rcd_lads_exp_add.delseq,
          rcd_lads_exp_add.hdeseq,
          rcd_lads_exp_add.addseq,
          rcd_lads_exp_add.partner_q,
          rcd_lads_exp_add.address_t,
          rcd_lads_exp_add.partner_id,
          rcd_lads_exp_add.jurisdic,
          rcd_lads_exp_add.language,
          rcd_lads_exp_add.formofaddr,
          rcd_lads_exp_add.name1,
          rcd_lads_exp_add.name2,
          rcd_lads_exp_add.name3,
          rcd_lads_exp_add.name4,
          rcd_lads_exp_add.name_text,
          rcd_lads_exp_add.name_co,
          rcd_lads_exp_add.location,
          rcd_lads_exp_add.building,
          rcd_lads_exp_add.floor,
          rcd_lads_exp_add.room,
          rcd_lads_exp_add.street1,
          rcd_lads_exp_add.street2,
          rcd_lads_exp_add.street3,
          rcd_lads_exp_add.house_supl,
          rcd_lads_exp_add.house_rang,
          rcd_lads_exp_add.postl_cod1,
          rcd_lads_exp_add.postl_cod3,
          rcd_lads_exp_add.postl_area,
          rcd_lads_exp_add.city1,
          rcd_lads_exp_add.city2,
          rcd_lads_exp_add.postl_pbox,
          rcd_lads_exp_add.postl_cod2,
          rcd_lads_exp_add.postl_city,
          rcd_lads_exp_add.telephone1,
          rcd_lads_exp_add.telephone2,
          rcd_lads_exp_add.telefax,
          rcd_lads_exp_add.telex,
          rcd_lads_exp_add.e_mail,
          rcd_lads_exp_add.country1,
          rcd_lads_exp_add.country2,
          rcd_lads_exp_add.region,
          rcd_lads_exp_add.county_cod,
          rcd_lads_exp_add.county_txt,
          rcd_lads_exp_add.tzcode,
          rcd_lads_exp_add.tzdesc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_add;


   /**************************************************/
   /* This procedure performs the record ADD routine */
   /**************************************************/
   procedure process_record_tim(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TIM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_tim.zzgrpnr := rcd_lads_exp_hde.zzgrpnr;
      rcd_lads_exp_tim.delseq := rcd_lads_exp_hde.delseq;
      rcd_lads_exp_tim.hdeseq := rcd_lads_exp_hde.hdeseq;
      rcd_lads_exp_tim.timseq := rcd_lads_exp_tim.timseq + 1;
      rcd_lads_exp_tim.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_exp_tim.VSTZW := lics_inbound_utility.get_variable('VSTZW');
      rcd_lads_exp_tim.VSTZW_BEZ := lics_inbound_utility.get_variable('VSTZW_BEZ');
      rcd_lads_exp_tim.NTANF := lics_inbound_utility.get_variable('NTANF');
      rcd_lads_exp_tim.NTANZ := lics_inbound_utility.get_variable('NTANZ');
      rcd_lads_exp_tim.NTEND := lics_inbound_utility.get_variable('NTEND');
      rcd_lads_exp_tim.NTENZ := lics_inbound_utility.get_variable('NTENZ');
      rcd_lads_exp_tim.TZONE_BEG := lics_inbound_utility.get_variable('TZONE_BEG');
      rcd_lads_exp_tim.ISDD := lics_inbound_utility.get_variable('ISDD');
      rcd_lads_exp_tim.ISDZ := lics_inbound_utility.get_variable('ISDZ');
      rcd_lads_exp_tim.IEDD := lics_inbound_utility.get_variable('IEDD');
      rcd_lads_exp_tim.IEDz := lics_inbound_utility.get_variable('IEDZ');
      rcd_lads_exp_tim.TZONE_END := lics_inbound_utility.get_variable('TZONE_END');
      rcd_lads_exp_tim.VORNR := lics_inbound_utility.get_variable('VORNR');
      rcd_lads_exp_tim.VSTGA := lics_inbound_utility.get_variable('VSTGA');
      rcd_lads_exp_tim.VSTGA_BEZ := lics_inbound_utility.get_variable('VSTGA_BEZ');
      rcd_lads_exp_tim.EVENT := lics_inbound_utility.get_variable('EVENT');
      rcd_lads_exp_tim.EVENT_ALI := lics_inbound_utility.get_variable('EVENT_ALI');


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
      if rcd_lads_exp_tim.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_TIM - ZZGRPNR');
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

      insert into lads_exp_tim
         (zzgrpnr,
          delseq,
          hdeseq,
          timseq,
          qualf,
          VSTZW,
          VSTZW_BEZ,
          NTANF,
          NTANZ,
          NTEND,
          NTENZ,
          TZONE_BEG,
          ISDD,
          ISDZ,
          IEDD,
          IEDz,
          TZONE_END,
          VORNR,
          VSTGA,
          VSTGA_BEZ,
          EVENT,
          EVENT_ALI)
      values
         (rcd_lads_exp_tim.zzgrpnr,
          rcd_lads_exp_tim.delseq,
          rcd_lads_exp_tim.hdeseq,
          rcd_lads_exp_tim.timseq,
          rcd_lads_exp_tim.qualf,
          rcd_lads_exp_tim.VSTZW,
          rcd_lads_exp_tim.VSTZW_BEZ,
          rcd_lads_exp_tim.NTANF,
          rcd_lads_exp_tim.NTANZ,
          rcd_lads_exp_tim.NTEND,
          rcd_lads_exp_tim.NTENZ,
          rcd_lads_exp_tim.TZONE_BEG,
          rcd_lads_exp_tim.ISDD,
          rcd_lads_exp_tim.ISDZ,
          rcd_lads_exp_tim.IEDD,
          rcd_lads_exp_tim.IEDz,
          rcd_lads_exp_tim.TZONE_END,
          rcd_lads_exp_tim.VORNR,
          rcd_lads_exp_tim.VSTGA,
          rcd_lads_exp_tim.VSTGA_BEZ,
          rcd_lads_exp_tim.EVENT,
          rcd_lads_exp_tim.EVENT_ALI);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tim;



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
      rcd_lads_exp_det.zzgrpnr := rcd_lads_exp_hde.zzgrpnr;
      rcd_lads_exp_det.delseq := rcd_lads_exp_hde.delseq;
      rcd_lads_exp_det.hdeseq := rcd_lads_exp_hde.hdeseq;
      rcd_lads_exp_det.detseq := rcd_lads_exp_det.detseq + 1;
      rcd_lads_exp_det.posnr := lics_inbound_utility.get_number('POSNR',null);
      rcd_lads_exp_det.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_exp_det.matwa := lics_inbound_utility.get_variable('MATWA');
      rcd_lads_exp_det.arktx := lics_inbound_utility.get_variable('ARKTX');
      rcd_lads_exp_det.orktx := lics_inbound_utility.get_variable('ORKTX');
      rcd_lads_exp_det.sugrd := lics_inbound_utility.get_variable('SUGRD');
      rcd_lads_exp_det.sudru := lics_inbound_utility.get_variable('SUDRU');
      rcd_lads_exp_det.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_exp_det.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_exp_det.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_exp_det.charg := lics_inbound_utility.get_variable('CHARG');
      rcd_lads_exp_det.kdmat := lics_inbound_utility.get_variable('KDMAT');
      rcd_lads_exp_det.lfimg := lics_inbound_utility.get_number('LFIMG',null);
      rcd_lads_exp_det.vrkme := lics_inbound_utility.get_variable('VRKME');
      rcd_lads_exp_det.lgmng := lics_inbound_utility.get_number('LGMNG',null);
      rcd_lads_exp_det.meins := lics_inbound_utility.get_variable('MEINS');
      rcd_lads_exp_det.ntgew := lics_inbound_utility.get_number('NTGEW',null);
      rcd_lads_exp_det.brgew := lics_inbound_utility.get_number('BRGEW',null);
      rcd_lads_exp_det.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_exp_det.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_lads_exp_det.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_lads_exp_det.lgpbe := lics_inbound_utility.get_variable('LGPBE');
      rcd_lads_exp_det.hipos := lics_inbound_utility.get_variable('HIPOS');
      rcd_lads_exp_det.hievw := lics_inbound_utility.get_variable('HIEVW');
      rcd_lads_exp_det.ladgr := lics_inbound_utility.get_variable('LADGR');
      rcd_lads_exp_det.tragr := lics_inbound_utility.get_variable('TRAGR');
      rcd_lads_exp_det.vkbur := lics_inbound_utility.get_variable('VKBUR');
      rcd_lads_exp_det.vkgrp := lics_inbound_utility.get_variable('VKGRP');
      rcd_lads_exp_det.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_lads_exp_det.spart := lics_inbound_utility.get_variable('SPART');
      rcd_lads_exp_det.grkor := lics_inbound_utility.get_variable('GRKOR');
      rcd_lads_exp_det.ean11 := lics_inbound_utility.get_variable('EAN11');
      rcd_lads_exp_det.sernr := lics_inbound_utility.get_variable('SERNR');
      rcd_lads_exp_det.aeskd := lics_inbound_utility.get_variable('AESKD');
      rcd_lads_exp_det.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_exp_det.mfrgr := lics_inbound_utility.get_variable('MFRGR');
      rcd_lads_exp_det.vbrst := lics_inbound_utility.get_variable('VBRST');
      rcd_lads_exp_det.labnk := lics_inbound_utility.get_variable('LABNK');
      rcd_lads_exp_det.abrdt := lics_inbound_utility.get_variable('ABRDT');
      rcd_lads_exp_det.mfrpn := lics_inbound_utility.get_variable('MFRPN');
      rcd_lads_exp_det.mfrnr := lics_inbound_utility.get_variable('MFRNR');
      rcd_lads_exp_det.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_exp_det.kdmat35 := lics_inbound_utility.get_variable('KDMAT35');
      rcd_lads_exp_det.kannr := lics_inbound_utility.get_variable('KANNR');
      rcd_lads_exp_det.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_lads_exp_det.lieffz := lics_inbound_utility.get_number('LIEFFZ',null);
      rcd_lads_exp_det.usr01 := lics_inbound_utility.get_variable('USR01');
      rcd_lads_exp_det.usr02 := lics_inbound_utility.get_variable('USR02');
      rcd_lads_exp_det.usr03 := lics_inbound_utility.get_variable('USR03');
      rcd_lads_exp_det.usr04 := lics_inbound_utility.get_variable('USR04');
      rcd_lads_exp_det.usr05 := lics_inbound_utility.get_variable('USR05');
      rcd_lads_exp_det.matnr_external := lics_inbound_utility.get_variable('MATNR_EXTERNAL');
      rcd_lads_exp_det.matnr_version := lics_inbound_utility.get_variable('MATNR_VERSION');
      rcd_lads_exp_det.matnr_guid := lics_inbound_utility.get_variable('MATNR_GUID');
      rcd_lads_exp_det.matwa_external := lics_inbound_utility.get_variable('MATWA_EXTERNAL');
      rcd_lads_exp_det.matwa_version := lics_inbound_utility.get_variable('MATWA_VERSION');
      rcd_lads_exp_det.matwa_guid := lics_inbound_utility.get_variable('MATWA_GUID');
      rcd_lads_exp_det.zudat := lics_inbound_utility.get_variable('ZUDAT');
      rcd_lads_exp_det.vfdat := lics_inbound_utility.get_number('VFDAT',null);

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_int.intseq := 0;
      rcd_lads_exp_irf.irfseq := 0;
      rcd_lads_exp_erf.erfseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_det.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_DET - ZZGRPNR');
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

      insert into lads_exp_det
         (zzgrpnr,
          delseq,
          hdeseq,
          detseq,
          posnr,
          matnr,
          matwa,
          arktx,
          orktx,
          sugrd,
          sudru,
          matkl,
          werks,
          lgort,
          charg,
          kdmat,
          lfimg,
          vrkme,
          lgmng,
          meins,
          ntgew,
          brgew,
          gewei,
          volum,
          voleh,
          lgpbe,
          hipos,
          hievw,
          ladgr,
          tragr,
          vkbur,
          vkgrp,
          vtweg,
          spart,
          grkor,
          ean11,
          sernr,
          aeskd,
          empst,
          mfrgr,
          vbrst,
          labnk,
          abrdt,
          mfrpn,
          mfrnr,
          abrvw,
          kdmat35,
          kannr,
          posex,
          lieffz,
          usr01,
          usr02,
          usr03,
          usr04,
          usr05,
          matnr_external,
          matnr_version,
          matnr_guid,
          matwa_external,
          matwa_version,
          matwa_guid,
          zudat,
          vfdat)
      values
         (rcd_lads_exp_det.zzgrpnr,
          rcd_lads_exp_det.delseq,
          rcd_lads_exp_det.hdeseq,
          rcd_lads_exp_det.detseq,
          rcd_lads_exp_det.posnr,
          rcd_lads_exp_det.matnr,
          rcd_lads_exp_det.matwa,
          rcd_lads_exp_det.arktx,
          rcd_lads_exp_det.orktx,
          rcd_lads_exp_det.sugrd,
          rcd_lads_exp_det.sudru,
          rcd_lads_exp_det.matkl,
          rcd_lads_exp_det.werks,
          rcd_lads_exp_det.lgort,
          rcd_lads_exp_det.charg,
          rcd_lads_exp_det.kdmat,
          rcd_lads_exp_det.lfimg,
          rcd_lads_exp_det.vrkme,
          rcd_lads_exp_det.lgmng,
          rcd_lads_exp_det.meins,
          rcd_lads_exp_det.ntgew,
          rcd_lads_exp_det.brgew,
          rcd_lads_exp_det.gewei,
          rcd_lads_exp_det.volum,
          rcd_lads_exp_det.voleh,
          rcd_lads_exp_det.lgpbe,
          rcd_lads_exp_det.hipos,
          rcd_lads_exp_det.hievw,
          rcd_lads_exp_det.ladgr,
          rcd_lads_exp_det.tragr,
          rcd_lads_exp_det.vkbur,
          rcd_lads_exp_det.vkgrp,
          rcd_lads_exp_det.vtweg,
          rcd_lads_exp_det.spart,
          rcd_lads_exp_det.grkor,
          rcd_lads_exp_det.ean11,
          rcd_lads_exp_det.sernr,
          rcd_lads_exp_det.aeskd,
          rcd_lads_exp_det.empst,
          rcd_lads_exp_det.mfrgr,
          rcd_lads_exp_det.vbrst,
          rcd_lads_exp_det.labnk,
          rcd_lads_exp_det.abrdt,
          rcd_lads_exp_det.mfrpn,
          rcd_lads_exp_det.mfrnr,
          rcd_lads_exp_det.abrvw,
          rcd_lads_exp_det.kdmat35,
          rcd_lads_exp_det.kannr,
          rcd_lads_exp_det.posex,
          rcd_lads_exp_det.lieffz,
          rcd_lads_exp_det.usr01,
          rcd_lads_exp_det.usr02,
          rcd_lads_exp_det.usr03,
          rcd_lads_exp_det.usr04,
          rcd_lads_exp_det.usr05,
          rcd_lads_exp_det.matnr_external,
          rcd_lads_exp_det.matnr_version,
          rcd_lads_exp_det.matnr_guid,
          rcd_lads_exp_det.matwa_external,
          rcd_lads_exp_det.matwa_version,
          rcd_lads_exp_det.matwa_guid,
          rcd_lads_exp_det.zudat,
          rcd_lads_exp_det.vfdat);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record INT routine */
   /**************************************************/
   procedure process_record_int(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('INT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_int.zzgrpnr := rcd_lads_exp_det.zzgrpnr;
      rcd_lads_exp_int.delseq := rcd_lads_exp_det.delseq;
      rcd_lads_exp_int.hdeseq := rcd_lads_exp_det.hdeseq;
      rcd_lads_exp_int.detseq := rcd_lads_exp_det.detseq;
      rcd_lads_exp_int.intseq := rcd_lads_exp_int.intseq + 1;
      rcd_lads_exp_int.atinn := lics_inbound_utility.get_number('ATINN',null);
      rcd_lads_exp_int.atnam := lics_inbound_utility.get_variable('ATNAM');
      rcd_lads_exp_int.atbez := lics_inbound_utility.get_variable('ATBEZ');
      rcd_lads_exp_int.atwrt := lics_inbound_utility.get_variable('ATWRT');
      rcd_lads_exp_int.atwtb := lics_inbound_utility.get_variable('ATWTB');
      rcd_lads_exp_int.ewahr := lics_inbound_utility.get_number('EWAHR',null);

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
      if rcd_lads_exp_int.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_INT - ZZGRPNR');
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

      insert into lads_exp_int
         (zzgrpnr,
          delseq,
          hdeseq,
          detseq,
          intseq,
          atinn,
          atnam,
          atbez,
          atwrt,
          atwtb,
          ewahr)
      values
         (rcd_lads_exp_int.zzgrpnr,
          rcd_lads_exp_int.delseq,
          rcd_lads_exp_int.hdeseq,
          rcd_lads_exp_int.detseq,
          rcd_lads_exp_int.intseq,
          rcd_lads_exp_int.atinn,
          rcd_lads_exp_int.atnam,
          rcd_lads_exp_int.atbez,
          rcd_lads_exp_int.atwrt,
          rcd_lads_exp_int.atwtb,
          rcd_lads_exp_int.ewahr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_int;

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
      rcd_lads_exp_irf.zzgrpnr := rcd_lads_exp_det.zzgrpnr;
      rcd_lads_exp_irf.delseq := rcd_lads_exp_det.delseq;
      rcd_lads_exp_irf.hdeseq := rcd_lads_exp_det.hdeseq;
      rcd_lads_exp_irf.detseq := rcd_lads_exp_det.detseq;
      rcd_lads_exp_irf.irfseq := rcd_lads_exp_irf.irfseq + 1;
      rcd_lads_exp_irf.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_exp_irf.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_exp_irf.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_exp_irf.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_exp_irf.doctype := lics_inbound_utility.get_variable('DOCTYPE');
      rcd_lads_exp_irf.reason := lics_inbound_utility.get_variable('REASON');

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
      if rcd_lads_exp_irf.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_IRF - ZZGRPNR');
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

      insert into lads_exp_irf
         (zzgrpnr,
          delseq,
          hdeseq,
          detseq,
          irfseq,
          qualf,
          belnr,
          posnr,
          datum,
          doctype,
          reason)
      values
         (rcd_lads_exp_irf.zzgrpnr,
          rcd_lads_exp_irf.delseq,
          rcd_lads_exp_irf.hdeseq,
          rcd_lads_exp_irf.detseq,
          rcd_lads_exp_irf.irfseq,
          rcd_lads_exp_irf.qualf,
          rcd_lads_exp_irf.belnr,
          rcd_lads_exp_irf.posnr,
          rcd_lads_exp_irf.datum,
          rcd_lads_exp_irf.doctype,
          rcd_lads_exp_irf.reason);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_irf;

   /**************************************************/
   /* This procedure performs the record ERF routine */
   /**************************************************/
   procedure process_record_erf(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ERF', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_erf.zzgrpnr := rcd_lads_exp_det.zzgrpnr;
      rcd_lads_exp_erf.delseq := rcd_lads_exp_det.delseq;
      rcd_lads_exp_erf.hdeseq := rcd_lads_exp_det.hdeseq;
      rcd_lads_exp_erf.detseq := rcd_lads_exp_det.detseq;
      rcd_lads_exp_erf.erfseq := rcd_lads_exp_erf.erfseq + 1;
      rcd_lads_exp_erf.quali := lics_inbound_utility.get_variable('QUALI');
      rcd_lads_exp_erf.bstnr := lics_inbound_utility.get_variable('BSTNR');
      rcd_lads_exp_erf.bstdt := lics_inbound_utility.get_variable('BSTDT');
      rcd_lads_exp_erf.bsark := lics_inbound_utility.get_variable('BSARK');
      rcd_lads_exp_erf.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_exp_erf.posex := lics_inbound_utility.get_variable('POSEX');

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
      if rcd_lads_exp_erf.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_ERF - ZZGRPNR');
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

      insert into lads_exp_erf
         (zzgrpnr,
          delseq,
          hdeseq,
          detseq,
          erfseq,
          quali,
          bstnr,
          bstdt,
          bsark,
          ihrez,
          posex)
      values
         (rcd_lads_exp_erf.zzgrpnr,
          rcd_lads_exp_erf.delseq,
          rcd_lads_exp_erf.hdeseq,
          rcd_lads_exp_erf.detseq,
          rcd_lads_exp_erf.erfseq,
          rcd_lads_exp_erf.quali,
          rcd_lads_exp_erf.bstnr,
          rcd_lads_exp_erf.bstdt,
          rcd_lads_exp_erf.bsark,
          rcd_lads_exp_erf.ihrez,
          rcd_lads_exp_erf.posex);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_erf;

   /**************************************************/
   /* This procedure performs the record HUH routine */
   /**************************************************/
   procedure process_record_huh(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HUH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_huh.zzgrpnr := rcd_lads_exp_hde.zzgrpnr;
      rcd_lads_exp_huh.delseq := rcd_lads_exp_hde.delseq;
      rcd_lads_exp_huh.hdeseq := rcd_lads_exp_hde.hdeseq;
      rcd_lads_exp_huh.huhseq := rcd_lads_exp_huh.huhseq + 1;
      rcd_lads_exp_huh.exidv := lics_inbound_utility.get_variable('EXIDV');
      rcd_lads_exp_huh.tarag := lics_inbound_utility.get_number('TARAG',null);
      rcd_lads_exp_huh.gweit := lics_inbound_utility.get_variable('GWEIT');
      rcd_lads_exp_huh.brgew := lics_inbound_utility.get_number('BRGEW',null);
      rcd_lads_exp_huh.ntgew := lics_inbound_utility.get_number('NTGEW',null);
      rcd_lads_exp_huh.magew := lics_inbound_utility.get_number('MAGEW',null);
      rcd_lads_exp_huh.gweim := lics_inbound_utility.get_variable('GWEIM');
      rcd_lads_exp_huh.btvol := lics_inbound_utility.get_number('BTVOL',null);
      rcd_lads_exp_huh.ntvol := lics_inbound_utility.get_number('NTVOL',null);
      rcd_lads_exp_huh.mavol := lics_inbound_utility.get_number('MAVOL',null);
      rcd_lads_exp_huh.volem := lics_inbound_utility.get_variable('VOLEM');
      rcd_lads_exp_huh.tavol := lics_inbound_utility.get_number('TAVOL',null);
      rcd_lads_exp_huh.volet := lics_inbound_utility.get_variable('VOLET');
      rcd_lads_exp_huh.vegr2 := lics_inbound_utility.get_variable('VEGR2');
      rcd_lads_exp_huh.vegr1 := lics_inbound_utility.get_variable('VEGR1');
      rcd_lads_exp_huh.vegr3 := lics_inbound_utility.get_variable('VEGR3');
      rcd_lads_exp_huh.vhilm := lics_inbound_utility.get_variable('VHILM');
      rcd_lads_exp_huh.vegr4 := lics_inbound_utility.get_variable('VEGR4');
      rcd_lads_exp_huh.laeng := lics_inbound_utility.get_number('LAENG',null);
      rcd_lads_exp_huh.vegr5 := lics_inbound_utility.get_variable('VEGR5');
      rcd_lads_exp_huh.breit := lics_inbound_utility.get_number('BREIT',null);
      rcd_lads_exp_huh.hoehe := lics_inbound_utility.get_number('HOEHE',null);
      rcd_lads_exp_huh.meabm := lics_inbound_utility.get_variable('MEABM');
      rcd_lads_exp_huh.inhalt := lics_inbound_utility.get_variable('INHALT');
      rcd_lads_exp_huh.vhart := lics_inbound_utility.get_variable('VHART');
      rcd_lads_exp_huh.magrv := lics_inbound_utility.get_variable('MAGRV');
      rcd_lads_exp_huh.ladlg := lics_inbound_utility.get_number('LADLG',null);
      rcd_lads_exp_huh.ladeh := lics_inbound_utility.get_variable('LADEH');
      rcd_lads_exp_huh.farzt := lics_inbound_utility.get_number('FARZT',null);
      rcd_lads_exp_huh.fareh := lics_inbound_utility.get_variable('FAREH');
      rcd_lads_exp_huh.entfe := lics_inbound_utility.get_number('ENTFE',null);
      rcd_lads_exp_huh.ehent := lics_inbound_utility.get_variable('EHENT');
      rcd_lads_exp_huh.veltp := lics_inbound_utility.get_variable('VELTP');
      rcd_lads_exp_huh.exidv2 := lics_inbound_utility.get_variable('EXIDV2');
      rcd_lads_exp_huh.landt := lics_inbound_utility.get_variable('LANDT');
      rcd_lads_exp_huh.landf := lics_inbound_utility.get_variable('LANDF');
      rcd_lads_exp_huh.namef := lics_inbound_utility.get_variable('NAMEF');
      rcd_lads_exp_huh.nambe := lics_inbound_utility.get_variable('NAMBE');
      rcd_lads_exp_huh.vhilm_ku := lics_inbound_utility.get_variable('VHILM_KU');
      rcd_lads_exp_huh.vebez := lics_inbound_utility.get_variable('VEBEZ');
      rcd_lads_exp_huh.smgkn := lics_inbound_utility.get_variable('SMGKN');
      rcd_lads_exp_huh.kdmat35 := lics_inbound_utility.get_variable('KDMAT35');
      rcd_lads_exp_huh.sortl := lics_inbound_utility.get_variable('SORTL');
      rcd_lads_exp_huh.ernam := lics_inbound_utility.get_variable('ERNAM');
      rcd_lads_exp_huh.gewfx := lics_inbound_utility.get_variable('GEWFX');
      rcd_lads_exp_huh.erlkz := lics_inbound_utility.get_variable('ERLKZ');
      rcd_lads_exp_huh.exida := lics_inbound_utility.get_variable('EXIDA');
      rcd_lads_exp_huh.move_status := lics_inbound_utility.get_variable('MOVE_STATUS');
      rcd_lads_exp_huh.packvorschr := lics_inbound_utility.get_variable('PACKVORSCHR');
      rcd_lads_exp_huh.packvorschr_st := lics_inbound_utility.get_variable('PACKVORSCHR_ST');
      rcd_lads_exp_huh.labeltyp := lics_inbound_utility.get_variable('LABELTYP');
      rcd_lads_exp_huh.zul_aufl := lics_inbound_utility.get_variable('ZUL_AUFL');
      rcd_lads_exp_huh.vhilm_external := lics_inbound_utility.get_variable('VHILM_EXTERNAL');
      rcd_lads_exp_huh.vhilm_version := lics_inbound_utility.get_variable('VHILM_VERSION');
      rcd_lads_exp_huh.vhilm_guid := lics_inbound_utility.get_variable('VHILM_GUID');
      rcd_lads_exp_huh.vegr1_bez := lics_inbound_utility.get_variable('VEGR1_BEZ');
      rcd_lads_exp_huh.vegr2_bez := lics_inbound_utility.get_variable('VEGR2_BEZ');
      rcd_lads_exp_huh.vegr3_bez := lics_inbound_utility.get_variable('VEGR3_BEZ');
      rcd_lads_exp_huh.vegr4_bez := lics_inbound_utility.get_variable('VEGR4_BEZ');
      rcd_lads_exp_huh.vegr5_bez := lics_inbound_utility.get_variable('VEGR5_BEZ');
      rcd_lads_exp_huh.vhart_bez := lics_inbound_utility.get_variable('VHART_BEZ');
      rcd_lads_exp_huh.magrv_bez := lics_inbound_utility.get_variable('MAGRV_BEZ');
      rcd_lads_exp_huh.vebez1 := lics_inbound_utility.get_variable('VEBEZ1');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_huc.hucseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_huh.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HUH - ZZGRPNR');
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

      insert into lads_exp_huh
         (zzgrpnr,
          delseq,
          hdeseq,
          huhseq,
          exidv,
          tarag,
          gweit,
          brgew,
          ntgew,
          magew,
          gweim,
          btvol,
          ntvol,
          mavol,
          volem,
          tavol,
          volet,
          vegr2,
          vegr1,
          vegr3,
          vhilm,
          vegr4,
          laeng,
          vegr5,
          breit,
          hoehe,
          meabm,
          inhalt,
          vhart,
          magrv,
          ladlg,
          ladeh,
          farzt,
          fareh,
          entfe,
          ehent,
          veltp,
          exidv2,
          landt,
          landf,
          namef,
          nambe,
          vhilm_ku,
          vebez,
          smgkn,
          kdmat35,
          sortl,
          ernam,
          gewfx,
          erlkz,
          exida,
          move_status,
          packvorschr,
          packvorschr_st,
          labeltyp,
          zul_aufl,
          vhilm_external,
          vhilm_version,
          vhilm_guid,
          vegr1_bez,
          vegr2_bez,
          vegr3_bez,
          vegr4_bez,
          vegr5_bez,
          vhart_bez,
          magrv_bez,
          vebez1)
      values
         (rcd_lads_exp_huh.zzgrpnr,
          rcd_lads_exp_huh.delseq,
          rcd_lads_exp_huh.hdeseq,
          rcd_lads_exp_huh.huhseq,
          rcd_lads_exp_huh.exidv,
          rcd_lads_exp_huh.tarag,
          rcd_lads_exp_huh.gweit,
          rcd_lads_exp_huh.brgew,
          rcd_lads_exp_huh.ntgew,
          rcd_lads_exp_huh.magew,
          rcd_lads_exp_huh.gweim,
          rcd_lads_exp_huh.btvol,
          rcd_lads_exp_huh.ntvol,
          rcd_lads_exp_huh.mavol,
          rcd_lads_exp_huh.volem,
          rcd_lads_exp_huh.tavol,
          rcd_lads_exp_huh.volet,
          rcd_lads_exp_huh.vegr2,
          rcd_lads_exp_huh.vegr1,
          rcd_lads_exp_huh.vegr3,
          rcd_lads_exp_huh.vhilm,
          rcd_lads_exp_huh.vegr4,
          rcd_lads_exp_huh.laeng,
          rcd_lads_exp_huh.vegr5,
          rcd_lads_exp_huh.breit,
          rcd_lads_exp_huh.hoehe,
          rcd_lads_exp_huh.meabm,
          rcd_lads_exp_huh.inhalt,
          rcd_lads_exp_huh.vhart,
          rcd_lads_exp_huh.magrv,
          rcd_lads_exp_huh.ladlg,
          rcd_lads_exp_huh.ladeh,
          rcd_lads_exp_huh.farzt,
          rcd_lads_exp_huh.fareh,
          rcd_lads_exp_huh.entfe,
          rcd_lads_exp_huh.ehent,
          rcd_lads_exp_huh.veltp,
          rcd_lads_exp_huh.exidv2,
          rcd_lads_exp_huh.landt,
          rcd_lads_exp_huh.landf,
          rcd_lads_exp_huh.namef,
          rcd_lads_exp_huh.nambe,
          rcd_lads_exp_huh.vhilm_ku,
          rcd_lads_exp_huh.vebez,
          rcd_lads_exp_huh.smgkn,
          rcd_lads_exp_huh.kdmat35,
          rcd_lads_exp_huh.sortl,
          rcd_lads_exp_huh.ernam,
          rcd_lads_exp_huh.gewfx,
          rcd_lads_exp_huh.erlkz,
          rcd_lads_exp_huh.exida,
          rcd_lads_exp_huh.move_status,
          rcd_lads_exp_huh.packvorschr,
          rcd_lads_exp_huh.packvorschr_st,
          rcd_lads_exp_huh.labeltyp,
          rcd_lads_exp_huh.zul_aufl,
          rcd_lads_exp_huh.vhilm_external,
          rcd_lads_exp_huh.vhilm_version,
          rcd_lads_exp_huh.vhilm_guid,
          rcd_lads_exp_huh.vegr1_bez,
          rcd_lads_exp_huh.vegr2_bez,
          rcd_lads_exp_huh.vegr3_bez,
          rcd_lads_exp_huh.vegr4_bez,
          rcd_lads_exp_huh.vegr5_bez,
          rcd_lads_exp_huh.vhart_bez,
          rcd_lads_exp_huh.magrv_bez,
          rcd_lads_exp_huh.vebez1);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_huh;

   /**************************************************/
   /* This procedure performs the record HUC routine */
   /**************************************************/
   procedure process_record_huc(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HUC', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_huc.zzgrpnr := rcd_lads_exp_huh.zzgrpnr;
      rcd_lads_exp_huc.delseq := rcd_lads_exp_huh.delseq;
      rcd_lads_exp_huc.hdeseq := rcd_lads_exp_huh.hdeseq;
      rcd_lads_exp_huc.huhseq := rcd_lads_exp_huh.huhseq;
      rcd_lads_exp_huc.hucseq := rcd_lads_exp_huc.hucseq + 1;
      rcd_lads_exp_huc.velin := lics_inbound_utility.get_variable('VELIN');
      rcd_lads_exp_huc.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_lads_exp_huc.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_exp_huc.exidv := lics_inbound_utility.get_variable('EXIDV');
      rcd_lads_exp_huc.vemng := lics_inbound_utility.get_number('VEMNG',null);
      rcd_lads_exp_huc.vemeh := lics_inbound_utility.get_variable('VEMEH');
      rcd_lads_exp_huc.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_exp_huc.kdmat := lics_inbound_utility.get_variable('KDMAT');
      rcd_lads_exp_huc.charg := lics_inbound_utility.get_variable('CHARG');
      rcd_lads_exp_huc.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_exp_huc.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_exp_huc.cuobj := lics_inbound_utility.get_variable('CUOBJ');
      rcd_lads_exp_huc.bestq := lics_inbound_utility.get_variable('BESTQ');
      rcd_lads_exp_huc.sobkz := lics_inbound_utility.get_variable('SOBKZ');
      rcd_lads_exp_huc.sonum := lics_inbound_utility.get_variable('SONUM');
      rcd_lads_exp_huc.anzsn := lics_inbound_utility.get_number('ANZSN',null);
      rcd_lads_exp_huc.wdatu := lics_inbound_utility.get_variable('WDATU');
      rcd_lads_exp_huc.parid := lics_inbound_utility.get_variable('PARID');
      rcd_lads_exp_huc.matnr_external := lics_inbound_utility.get_variable('MATNR_EXTERNAL');
      rcd_lads_exp_huc.matnr_version := lics_inbound_utility.get_variable('MATNR_VERSION');
      rcd_lads_exp_huc.matnr_guid := lics_inbound_utility.get_variable('MATNR_GUID');

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
      if rcd_lads_exp_huc.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HUC - ZZGRPNR');
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

      insert into lads_exp_huc
         (zzgrpnr,
          delseq,
          hdeseq,
          huhseq,
          hucseq,
          velin,
          vbeln,
          posnr,
          exidv,
          vemng,
          vemeh,
          matnr,
          kdmat,
          charg,
          werks,
          lgort,
          cuobj,
          bestq,
          sobkz,
          sonum,
          anzsn,
          wdatu,
          parid,
          matnr_external,
          matnr_version,
          matnr_guid)
      values
         (rcd_lads_exp_huc.zzgrpnr,
          rcd_lads_exp_huc.delseq,
          rcd_lads_exp_huc.hdeseq,
          rcd_lads_exp_huc.huhseq,
          rcd_lads_exp_huc.hucseq,
          rcd_lads_exp_huc.velin,
          rcd_lads_exp_huc.vbeln,
          rcd_lads_exp_huc.posnr,
          rcd_lads_exp_huc.exidv,
          rcd_lads_exp_huc.vemng,
          rcd_lads_exp_huc.vemeh,
          rcd_lads_exp_huc.matnr,
          rcd_lads_exp_huc.kdmat,
          rcd_lads_exp_huc.charg,
          rcd_lads_exp_huc.werks,
          rcd_lads_exp_huc.lgort,
          rcd_lads_exp_huc.cuobj,
          rcd_lads_exp_huc.bestq,
          rcd_lads_exp_huc.sobkz,
          rcd_lads_exp_huc.sonum,
          rcd_lads_exp_huc.anzsn,
          rcd_lads_exp_huc.wdatu,
          rcd_lads_exp_huc.parid,
          rcd_lads_exp_huc.matnr_external,
          rcd_lads_exp_huc.matnr_version,
          rcd_lads_exp_huc.matnr_guid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_huc;

   /**************************************************/
   /* This procedure performs the record SHP routine */
   /**************************************************/
   procedure process_record_shp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SHP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_shp.zzgrpnr := rcd_lads_exp_hdr.zzgrpnr;
      rcd_lads_exp_shp.shpseq := rcd_lads_exp_shp.shpseq + 1;
      rcd_lads_exp_shp.znbshpmnt := lics_inbound_utility.get_variable('ZNBSHPMNT');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_hsh.hshseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_shp.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_SHP - ZZGRPNR');
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

      insert into lads_exp_shp
         (zzgrpnr,
          shpseq,
          znbshpmnt)
      values
         (rcd_lads_exp_shp.zzgrpnr,
          rcd_lads_exp_shp.shpseq,
          rcd_lads_exp_shp.znbshpmnt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_shp;

   /**************************************************/
   /* This procedure performs the record HSH routine */
   /**************************************************/
   procedure process_record_hsh(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HSH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hsh.zzgrpnr := rcd_lads_exp_shp.zzgrpnr;
      rcd_lads_exp_hsh.shpseq := rcd_lads_exp_shp.shpseq;
      rcd_lads_exp_hsh.hshseq := rcd_lads_exp_hsh.hshseq + 1;
      rcd_lads_exp_hsh.tknum := lics_inbound_utility.get_variable('TKNUM');
      rcd_lads_exp_hsh.shtyp := lics_inbound_utility.get_variable('SHTYP');
      rcd_lads_exp_hsh.abfer := lics_inbound_utility.get_variable('ABFER');
      rcd_lads_exp_hsh.abwst := lics_inbound_utility.get_variable('ABWST');
      rcd_lads_exp_hsh.bfart := lics_inbound_utility.get_variable('BFART');
      rcd_lads_exp_hsh.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_exp_hsh.laufk := lics_inbound_utility.get_variable('LAUFK');
      rcd_lads_exp_hsh.vsbed := lics_inbound_utility.get_variable('VSBED');
      rcd_lads_exp_hsh.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_exp_hsh.signi := lics_inbound_utility.get_variable('SIGNI');
      rcd_lads_exp_hsh.exti1 := lics_inbound_utility.get_variable('EXTI1');
      rcd_lads_exp_hsh.exti2 := lics_inbound_utility.get_variable('EXTI2');
      rcd_lads_exp_hsh.tpbez := lics_inbound_utility.get_variable('TPBEZ');
      rcd_lads_exp_hsh.sttrg := lics_inbound_utility.get_variable('STTRG');
      rcd_lads_exp_hsh.pkstk := lics_inbound_utility.get_variable('PKSTK');
      rcd_lads_exp_hsh.dtmeg := lics_inbound_utility.get_variable('DTMEG');
      rcd_lads_exp_hsh.dtmev := lics_inbound_utility.get_variable('DTMEV');
      rcd_lads_exp_hsh.distz := lics_inbound_utility.get_number('DISTZ',null);
      rcd_lads_exp_hsh.medst := lics_inbound_utility.get_variable('MEDST');
      rcd_lads_exp_hsh.fahzt := lics_inbound_utility.get_number('FAHZT',null);
      rcd_lads_exp_hsh.geszt := lics_inbound_utility.get_number('GESZT',null);
      rcd_lads_exp_hsh.meizt := lics_inbound_utility.get_variable('MEIZT');
      rcd_lads_exp_hsh.fbsta := lics_inbound_utility.get_variable('FBSTA');
      rcd_lads_exp_hsh.fbgst := lics_inbound_utility.get_variable('FBGST');
      rcd_lads_exp_hsh.arsta := lics_inbound_utility.get_variable('ARSTA');
      rcd_lads_exp_hsh.argst := lics_inbound_utility.get_variable('ARGST');
      rcd_lads_exp_hsh.sterm_done := lics_inbound_utility.get_variable('STERM_DONE');
      rcd_lads_exp_hsh.vse_frk := lics_inbound_utility.get_variable('VSE_FRK');
      rcd_lads_exp_hsh.kkalsm := lics_inbound_utility.get_variable('KKALSM');
      rcd_lads_exp_hsh.sdabw := lics_inbound_utility.get_variable('SDABW');
      rcd_lads_exp_hsh.frkrl := lics_inbound_utility.get_variable('FRKRL');
      rcd_lads_exp_hsh.gesztd := lics_inbound_utility.get_number('GESZTD',null);
      rcd_lads_exp_hsh.fahztd := lics_inbound_utility.get_number('FAHZTD',null);
      rcd_lads_exp_hsh.gesztda := lics_inbound_utility.get_number('GESZTDA',null);
      rcd_lads_exp_hsh.fahztda := lics_inbound_utility.get_number('FAHZTDA',null);
      rcd_lads_exp_hsh.warztd := lics_inbound_utility.get_number('WARZTD',null);
      rcd_lads_exp_hsh.warztda := lics_inbound_utility.get_number('WARZTDA',null);
      rcd_lads_exp_hsh.shtyp_bez := lics_inbound_utility.get_variable('SHTYP_BEZ');
      rcd_lads_exp_hsh.bfart_bez := lics_inbound_utility.get_variable('BFART_BEZ');
      rcd_lads_exp_hsh.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_exp_hsh.laufk_bez := lics_inbound_utility.get_variable('LAUFK_BEZ');
      rcd_lads_exp_hsh.vsbed_bez := lics_inbound_utility.get_variable('VSBED_BEZ');
      rcd_lads_exp_hsh.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_exp_hsh.sttrg_bez := lics_inbound_utility.get_variable('STTRG_BEZ');
      rcd_lads_exp_hsh.fbsta_bez := lics_inbound_utility.get_variable('FBSTA_BEZ');
      rcd_lads_exp_hsh.fbgst_bez := lics_inbound_utility.get_variable('FBGST_BEZ');
      rcd_lads_exp_hsh.arsta_bez := lics_inbound_utility.get_variable('ARSTA_BEZ');
      rcd_lads_exp_hsh.argst_bez := lics_inbound_utility.get_variable('ARGST_BEZ');
      rcd_lads_exp_hsh.tndrst := lics_inbound_utility.get_variable('TNDRST');
      rcd_lads_exp_hsh.tndrrc := lics_inbound_utility.get_variable('TNDRRC');
      rcd_lads_exp_hsh.tndr_text := lics_inbound_utility.get_variable('TNDR_TEXT');
      rcd_lads_exp_hsh.tndrdat := lics_inbound_utility.get_variable('TNDRDAT');
      rcd_lads_exp_hsh.tndrzet := lics_inbound_utility.get_variable('TNDRZET');
      rcd_lads_exp_hsh.tndr_maxp := lics_inbound_utility.get_number('TNDR_MAXP',null);
      rcd_lads_exp_hsh.tndr_maxc := lics_inbound_utility.get_variable('TNDR_MAXC');
      rcd_lads_exp_hsh.tndr_actp := lics_inbound_utility.get_number('TNDR_ACTP',null);
      rcd_lads_exp_hsh.tndr_actc := lics_inbound_utility.get_variable('TNDR_ACTC');
      rcd_lads_exp_hsh.tndr_carr := lics_inbound_utility.get_variable('TNDR_CARR');
      rcd_lads_exp_hsh.tndr_crnm := lics_inbound_utility.get_variable('TNDR_CRNM');
      rcd_lads_exp_hsh.tndr_trkid := lics_inbound_utility.get_variable('TNDR_TRKID');
      rcd_lads_exp_hsh.tndr_expd := lics_inbound_utility.get_variable('TNDR_EXPD');
      rcd_lads_exp_hsh.tndr_expt := lics_inbound_utility.get_variable('TNDR_EXPT');
      rcd_lads_exp_hsh.tndr_erpd := lics_inbound_utility.get_variable('TNDR_ERPD');
      rcd_lads_exp_hsh.tndr_erpt := lics_inbound_utility.get_variable('TNDR_ERPT');
      rcd_lads_exp_hsh.tndr_ltpd := lics_inbound_utility.get_variable('TNDR_LTPD');
      rcd_lads_exp_hsh.tndr_ltpt := lics_inbound_utility.get_variable('TNDR_LTPT');
      rcd_lads_exp_hsh.tndr_erdd := lics_inbound_utility.get_variable('TNDR_ERDD');
      rcd_lads_exp_hsh.tndr_erdt := lics_inbound_utility.get_variable('TNDR_ERDT');
      rcd_lads_exp_hsh.tndr_ltdd := lics_inbound_utility.get_variable('TNDR_LTDD');
      rcd_lads_exp_hsh.tndr_ltdt := lics_inbound_utility.get_variable('TNDR_LTDT');
      rcd_lads_exp_hsh.tndr_ldlg := lics_inbound_utility.get_number('TNDR_LDLG',null);
      rcd_lads_exp_hsh.tndr_ldlu := lics_inbound_utility.get_variable('TNDR_LDLU');
      rcd_lads_exp_hsh.tndrst_bez := lics_inbound_utility.get_variable('TNDRST_BEZ');
      rcd_lads_exp_hsh.tndrrc_bez := lics_inbound_utility.get_variable('TNDRRC_BEZ');
      rcd_lads_exp_hsh.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_lads_exp_hsh.shpmnt_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_hda.hdaseq := 0;
      rcd_lads_exp_har.harseq := 0;
      rcd_lads_exp_hst.hstseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_hsh.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HSH - ZZGRPNR');
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

      insert into lads_exp_hsh
         (zzgrpnr,
          shpseq,
          hshseq,
          tknum,
          shtyp,
          abfer,
          abwst,
          bfart,
          vsart,
          laufk,
          vsbed,
          route,
          signi,
          exti1,
          exti2,
          tpbez,
          sttrg,
          pkstk,
          dtmeg,
          dtmev,
          distz,
          medst,
          fahzt,
          geszt,
          meizt,
          fbsta,
          fbgst,
          arsta,
          argst,
          sterm_done,
          vse_frk,
          kkalsm,
          sdabw,
          frkrl,
          gesztd,
          fahztd,
          gesztda,
          fahztda,
          warztd,
          warztda,
          shtyp_bez,
          bfart_bez,
          vsart_bez,
          laufk_bez,
          vsbed_bez,
          route_bez,
          sttrg_bez,
          fbsta_bez,
          fbgst_bez,
          arsta_bez,
          argst_bez,
          tndrst,
          tndrrc,
          tndr_text,
          tndrdat,
          tndrzet,
          tndr_maxp,
          tndr_maxc,
          tndr_actp,
          tndr_actc,
          tndr_carr,
          tndr_crnm,
          tndr_trkid,
          tndr_expd,
          tndr_expt,
          tndr_erpd,
          tndr_erpt,
          tndr_ltpd,
          tndr_ltpt,
          tndr_erdd,
          tndr_erdt,
          tndr_ltdd,
          tndr_ltdt,
          tndr_ldlg,
          tndr_ldlu,
          tndrst_bez,
          tndrrc_bez,
          vbeln,
          shpmnt_status)
      values
         (rcd_lads_exp_hsh.zzgrpnr,
          rcd_lads_exp_hsh.shpseq,
          rcd_lads_exp_hsh.hshseq,
          rcd_lads_exp_hsh.tknum,
          rcd_lads_exp_hsh.shtyp,
          rcd_lads_exp_hsh.abfer,
          rcd_lads_exp_hsh.abwst,
          rcd_lads_exp_hsh.bfart,
          rcd_lads_exp_hsh.vsart,
          rcd_lads_exp_hsh.laufk,
          rcd_lads_exp_hsh.vsbed,
          rcd_lads_exp_hsh.route,
          rcd_lads_exp_hsh.signi,
          rcd_lads_exp_hsh.exti1,
          rcd_lads_exp_hsh.exti2,
          rcd_lads_exp_hsh.tpbez,
          rcd_lads_exp_hsh.sttrg,
          rcd_lads_exp_hsh.pkstk,
          rcd_lads_exp_hsh.dtmeg,
          rcd_lads_exp_hsh.dtmev,
          rcd_lads_exp_hsh.distz,
          rcd_lads_exp_hsh.medst,
          rcd_lads_exp_hsh.fahzt,
          rcd_lads_exp_hsh.geszt,
          rcd_lads_exp_hsh.meizt,
          rcd_lads_exp_hsh.fbsta,
          rcd_lads_exp_hsh.fbgst,
          rcd_lads_exp_hsh.arsta,
          rcd_lads_exp_hsh.argst,
          rcd_lads_exp_hsh.sterm_done,
          rcd_lads_exp_hsh.vse_frk,
          rcd_lads_exp_hsh.kkalsm,
          rcd_lads_exp_hsh.sdabw,
          rcd_lads_exp_hsh.frkrl,
          rcd_lads_exp_hsh.gesztd,
          rcd_lads_exp_hsh.fahztd,
          rcd_lads_exp_hsh.gesztda,
          rcd_lads_exp_hsh.fahztda,
          rcd_lads_exp_hsh.warztd,
          rcd_lads_exp_hsh.warztda,
          rcd_lads_exp_hsh.shtyp_bez,
          rcd_lads_exp_hsh.bfart_bez,
          rcd_lads_exp_hsh.vsart_bez,
          rcd_lads_exp_hsh.laufk_bez,
          rcd_lads_exp_hsh.vsbed_bez,
          rcd_lads_exp_hsh.route_bez,
          rcd_lads_exp_hsh.sttrg_bez,
          rcd_lads_exp_hsh.fbsta_bez,
          rcd_lads_exp_hsh.fbgst_bez,
          rcd_lads_exp_hsh.arsta_bez,
          rcd_lads_exp_hsh.argst_bez,
          rcd_lads_exp_hsh.tndrst,
          rcd_lads_exp_hsh.tndrrc,
          rcd_lads_exp_hsh.tndr_text,
          rcd_lads_exp_hsh.tndrdat,
          rcd_lads_exp_hsh.tndrzet,
          rcd_lads_exp_hsh.tndr_maxp,
          rcd_lads_exp_hsh.tndr_maxc,
          rcd_lads_exp_hsh.tndr_actp,
          rcd_lads_exp_hsh.tndr_actc,
          rcd_lads_exp_hsh.tndr_carr,
          rcd_lads_exp_hsh.tndr_crnm,
          rcd_lads_exp_hsh.tndr_trkid,
          rcd_lads_exp_hsh.tndr_expd,
          rcd_lads_exp_hsh.tndr_expt,
          rcd_lads_exp_hsh.tndr_erpd,
          rcd_lads_exp_hsh.tndr_erpt,
          rcd_lads_exp_hsh.tndr_ltpd,
          rcd_lads_exp_hsh.tndr_ltpt,
          rcd_lads_exp_hsh.tndr_erdd,
          rcd_lads_exp_hsh.tndr_erdt,
          rcd_lads_exp_hsh.tndr_ltdd,
          rcd_lads_exp_hsh.tndr_ltdt,
          rcd_lads_exp_hsh.tndr_ldlg,
          rcd_lads_exp_hsh.tndr_ldlu,
          rcd_lads_exp_hsh.tndrst_bez,
          rcd_lads_exp_hsh.tndrrc_bez,
          rcd_lads_exp_hsh.vbeln,
          rcd_lads_exp_hsh.shpmnt_status);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hsh;

   /**************************************************/
   /* This procedure performs the record HAR routine */
   /**************************************************/
   procedure process_record_har(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HAR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_har.zzgrpnr := rcd_lads_exp_hsh.zzgrpnr;
      rcd_lads_exp_har.shpseq := rcd_lads_exp_hsh.shpseq;
      rcd_lads_exp_har.hshseq := rcd_lads_exp_hsh.hshseq;
      rcd_lads_exp_har.harseq := rcd_lads_exp_har.harseq + 1;
      rcd_lads_exp_har.PARTNER_Q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_exp_har.ADDRESS_T := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_lads_exp_har.PARTNER_ID := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_exp_har.JURISDIC := lics_inbound_utility.get_variable('JURISDIC');
      rcd_lads_exp_har.LANGUAGE := lics_inbound_utility.get_variable('LANGUAGE');
      rcd_lads_exp_har.FORMOFADDR := lics_inbound_utility.get_variable('FORMOFADDR');
      rcd_lads_exp_har.NAME1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_exp_har.NAME2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_exp_har.NAME3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_exp_har.NAME4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_exp_har.NAME_TEXT := lics_inbound_utility.get_variable('NAME_TEXT');
      rcd_lads_exp_har.NAME_CO := lics_inbound_utility.get_variable('NAME_CO');
      rcd_lads_exp_har.LOCATION := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_exp_har.BUILDING := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_exp_har.FLOOR := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_exp_har.ROOM := lics_inbound_utility.get_variable('ROOM');
      rcd_lads_exp_har.STREET1 := lics_inbound_utility.get_variable('STREET1');
      rcd_lads_exp_har.STREET2 := lics_inbound_utility.get_variable('STREET2');
      rcd_lads_exp_har.STREET3 := lics_inbound_utility.get_variable('STREET3');
      rcd_lads_exp_har.HOUSE_SUPL := lics_inbound_utility.get_variable('HOUSE_SUPL');
      rcd_lads_exp_har.HOUSE_RANG := lics_inbound_utility.get_variable('HOUSE_RANG');
      rcd_lads_exp_har.POSTL_COD1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_lads_exp_har.POSTL_COD3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_lads_exp_har.POSTL_AREA := lics_inbound_utility.get_variable('POSTL_AREA');
      rcd_lads_exp_har.CITY1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_exp_har.CITY2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_exp_har.POSTL_PBOX := lics_inbound_utility.get_variable('POSTL_PBOX');
      rcd_lads_exp_har.POSTL_COD2 := lics_inbound_utility.get_variable('POSTL_COD2');
      rcd_lads_exp_har.POSTL_CITY := lics_inbound_utility.get_variable('POSTL_CITY');
      rcd_lads_exp_har.TELEPHONE1 := lics_inbound_utility.get_variable('TELEPHONE1');
      rcd_lads_exp_har.TELEPHONE2 := lics_inbound_utility.get_variable('TELEPHONE2');
      rcd_lads_exp_har.TELEFAX := lics_inbound_utility.get_variable('TELEFAX');
      rcd_lads_exp_har.TELEX := lics_inbound_utility.get_variable('TELEX');
      rcd_lads_exp_har.E_MAIL := lics_inbound_utility.get_variable('E_MAIL');
      rcd_lads_exp_har.COUNTRY1 := lics_inbound_utility.get_variable('COUNTRY1');
      rcd_lads_exp_har.COUNTRY2 := lics_inbound_utility.get_variable('COUNTRY2');
      rcd_lads_exp_har.REGION := lics_inbound_utility.get_variable('REGION');
      rcd_lads_exp_har.COUNTY_COD := lics_inbound_utility.get_variable('COUNTY_COD');
      rcd_lads_exp_har.COUNTY_TXT := lics_inbound_utility.get_variable('COUNTY_TXT');
      rcd_lads_exp_har.TZCODE := lics_inbound_utility.get_variable('TZCODE');
      rcd_lads_exp_har.TZDESC := lics_inbound_utility.get_variable('TZDESC');


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
      if rcd_lads_exp_har.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HAR - ZZGRPNR');
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

      insert into lads_exp_har
         (zzgrpnr,
          shpseq,
          hshseq,
          harseq,
          PARTNER_Q,
          ADDRESS_T,
          PARTNER_ID,
          JURISDIC,
          LANGUAGE,
          FORMOFADDR,
          NAME1,
          NAME2,
          NAME3,
          NAME4,
          NAME_TEXT,
          NAME_CO,
          LOCATION,
          BUILDING,
          FLOOR,
          ROOM,
          STREET1,
          STREET2,
          STREET3,
          HOUSE_SUPL,
          HOUSE_RANG,
          POSTL_COD1,
          POSTL_COD3,
          POSTL_AREA,
          CITY1,
          CITY2,
          POSTL_PBOX,
          POSTL_COD2,
          POSTL_CITY,
          TELEPHONE1,
          TELEPHONE2,
          TELEFAX,
          TELEX,
          E_MAIL,
          COUNTRY1,
          COUNTRY2,
          REGION,
          COUNTY_COD,
          COUNTY_TXT,
          TZCODE,
          TZDESC)
      values
         (rcd_lads_exp_har.zzgrpnr,
          rcd_lads_exp_har.shpseq,
          rcd_lads_exp_har.hshseq,
          rcd_lads_exp_har.harseq,
          rcd_lads_exp_har.PARTNER_Q,
          rcd_lads_exp_har.ADDRESS_T,
          rcd_lads_exp_har.PARTNER_ID,
          rcd_lads_exp_har.JURISDIC,
          rcd_lads_exp_har.LANGUAGE,
          rcd_lads_exp_har.FORMOFADDR,
          rcd_lads_exp_har.NAME1,
          rcd_lads_exp_har.NAME2,
          rcd_lads_exp_har.NAME3,
          rcd_lads_exp_har.NAME4,
          rcd_lads_exp_har.NAME_TEXT,
          rcd_lads_exp_har.NAME_CO,
          rcd_lads_exp_har.LOCATION,
          rcd_lads_exp_har.BUILDING,
          rcd_lads_exp_har.FLOOR,
          rcd_lads_exp_har.ROOM,
          rcd_lads_exp_har.STREET1,
          rcd_lads_exp_har.STREET2,
          rcd_lads_exp_har.STREET3,
          rcd_lads_exp_har.HOUSE_SUPL,
          rcd_lads_exp_har.HOUSE_RANG,
          rcd_lads_exp_har.POSTL_COD1,
          rcd_lads_exp_har.POSTL_COD3,
          rcd_lads_exp_har.POSTL_AREA,
          rcd_lads_exp_har.CITY1,
          rcd_lads_exp_har.CITY2,
          rcd_lads_exp_har.POSTL_PBOX,
          rcd_lads_exp_har.POSTL_COD2,
          rcd_lads_exp_har.POSTL_CITY,
          rcd_lads_exp_har.TELEPHONE1,
          rcd_lads_exp_har.TELEPHONE2,
          rcd_lads_exp_har.TELEFAX,
          rcd_lads_exp_har.TELEX,
          rcd_lads_exp_har.E_MAIL,
          rcd_lads_exp_har.COUNTRY1,
          rcd_lads_exp_har.COUNTRY2,
          rcd_lads_exp_har.REGION,
          rcd_lads_exp_har.COUNTY_COD,
          rcd_lads_exp_har.COUNTY_TXT,
          rcd_lads_exp_har.TZCODE,
          rcd_lads_exp_har.TZDESC);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_har;


   /**************************************************/
   /* This procedure performs the record HDA routine */
   /**************************************************/
   procedure process_record_hda(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HDA', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hda.zzgrpnr := rcd_lads_exp_hsh.zzgrpnr;
      rcd_lads_exp_hda.shpseq := rcd_lads_exp_hsh.shpseq;
      rcd_lads_exp_hda.hshseq := rcd_lads_exp_hsh.hshseq;
      rcd_lads_exp_hda.hdaseq := rcd_lads_exp_hda.hdaseq + 1;
      rcd_lads_exp_hda.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_exp_hda.vstzw := lics_inbound_utility.get_variable('VSTZW');
      rcd_lads_exp_hda.vstzw_bez := lics_inbound_utility.get_variable('VSTZW_BEZ');
      rcd_lads_exp_hda.ntanf := lics_inbound_utility.get_variable('NTANF');
      rcd_lads_exp_hda.ntanz := lics_inbound_utility.get_variable('NTANZ');
      rcd_lads_exp_hda.ntend := lics_inbound_utility.get_variable('NTEND');
      rcd_lads_exp_hda.ntenz := lics_inbound_utility.get_variable('NTENZ');
      rcd_lads_exp_hda.tzone_beg := lics_inbound_utility.get_variable('TZONE_BEG');
      rcd_lads_exp_hda.isdd := lics_inbound_utility.get_variable('ISDD');
      rcd_lads_exp_hda.isdz := lics_inbound_utility.get_variable('ISDZ');
      rcd_lads_exp_hda.iedd := lics_inbound_utility.get_variable('IEDD');
      rcd_lads_exp_hda.iedz := lics_inbound_utility.get_variable('IEDZ');
      rcd_lads_exp_hda.tzone_end := lics_inbound_utility.get_variable('TZONE_END');
      rcd_lads_exp_hda.vornr := lics_inbound_utility.get_variable('VORNR');
      rcd_lads_exp_hda.vstga := lics_inbound_utility.get_variable('VSTGA');
      rcd_lads_exp_hda.vstga_bez := lics_inbound_utility.get_variable('VSTGA_BEZ');
      rcd_lads_exp_hda.event := lics_inbound_utility.get_variable('EVENT');
      rcd_lads_exp_hda.event_ali := lics_inbound_utility.get_variable('EVENT_ALI');

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
      if rcd_lads_exp_hda.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HDA - ZZGRPNR');
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

      insert into lads_exp_hda
         (zzgrpnr,
          shpseq,
          hshseq,
          hdaseq,
          qualf,
          vstzw,
          vstzw_bez,
          ntanf,
          ntanz,
          ntend,
          ntenz,
          tzone_beg,
          isdd,
          isdz,
          iedd,
          iedz,
          tzone_end,
          vornr,
          vstga,
          vstga_bez,
          event,
          event_ali)
      values
         (rcd_lads_exp_hda.zzgrpnr,
          rcd_lads_exp_hda.shpseq,
          rcd_lads_exp_hda.hshseq,
          rcd_lads_exp_hda.hdaseq,
          rcd_lads_exp_hda.qualf,
          rcd_lads_exp_hda.vstzw,
          rcd_lads_exp_hda.vstzw_bez,
          rcd_lads_exp_hda.ntanf,
          rcd_lads_exp_hda.ntanz,
          rcd_lads_exp_hda.ntend,
          rcd_lads_exp_hda.ntenz,
          rcd_lads_exp_hda.tzone_beg,
          rcd_lads_exp_hda.isdd,
          rcd_lads_exp_hda.isdz,
          rcd_lads_exp_hda.iedd,
          rcd_lads_exp_hda.iedz,
          rcd_lads_exp_hda.tzone_end,
          rcd_lads_exp_hda.vornr,
          rcd_lads_exp_hda.vstga,
          rcd_lads_exp_hda.vstga_bez,
          rcd_lads_exp_hda.event,
          rcd_lads_exp_hda.event_ali);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hda;

   /**************************************************/
   /* This procedure performs the record HST routine */
   /**************************************************/
   procedure process_record_hst(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HST', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hst.zzgrpnr := rcd_lads_exp_hsh.zzgrpnr;
      rcd_lads_exp_hst.shpseq := rcd_lads_exp_hsh.shpseq;
      rcd_lads_exp_hst.hshseq := rcd_lads_exp_hsh.hshseq;
      rcd_lads_exp_hst.hstseq := rcd_lads_exp_hst.hstseq + 1;
      rcd_lads_exp_hst.tsnum := lics_inbound_utility.get_number('TSNUM',null);
      rcd_lads_exp_hst.tsrfo := lics_inbound_utility.get_number('TSRFO',null);
      rcd_lads_exp_hst.tstyp := lics_inbound_utility.get_variable('TSTYP');
      rcd_lads_exp_hst.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_exp_hst.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_lads_exp_hst.laufk := lics_inbound_utility.get_variable('LAUFK');
      rcd_lads_exp_hst.distz := lics_inbound_utility.get_number('DISTZ',null);
      rcd_lads_exp_hst.medst := lics_inbound_utility.get_variable('MEDST');
      rcd_lads_exp_hst.fahzt := lics_inbound_utility.get_number('FAHZT',null);
      rcd_lads_exp_hst.geszt := lics_inbound_utility.get_number('GESZT',null);
      rcd_lads_exp_hst.meizt := lics_inbound_utility.get_variable('MEIZT');
      rcd_lads_exp_hst.gesztd := lics_inbound_utility.get_number('GESZTD',null);
      rcd_lads_exp_hst.fahztd := lics_inbound_utility.get_number('FAHZTD',null);
      rcd_lads_exp_hst.gesztda := lics_inbound_utility.get_number('GESZTDA',null);
      rcd_lads_exp_hst.fahztda := lics_inbound_utility.get_number('FAHZTDA',null);
      rcd_lads_exp_hst.sdabw := lics_inbound_utility.get_variable('SDABW');
      rcd_lads_exp_hst.frkrl := lics_inbound_utility.get_variable('FRKRL');
      rcd_lads_exp_hst.skalsm := lics_inbound_utility.get_variable('SKALSM');
      rcd_lads_exp_hst.fbsta := lics_inbound_utility.get_variable('FBSTA');
      rcd_lads_exp_hst.arsta := lics_inbound_utility.get_variable('ARSTA');
      rcd_lads_exp_hst.warztd := lics_inbound_utility.get_number('WARZTD',null);
      rcd_lads_exp_hst.warztda := lics_inbound_utility.get_number('WARZTDA',null);
      rcd_lads_exp_hst.cont_dg := lics_inbound_utility.get_variable('CONT_DG');
      rcd_lads_exp_hst.tstyp_bez := lics_inbound_utility.get_variable('TSTYP_BEZ');
      rcd_lads_exp_hst.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_exp_hst.inco1_bez := lics_inbound_utility.get_variable('INCO1_BEZ');
      rcd_lads_exp_hst.laufk_bez := lics_inbound_utility.get_variable('LAUFK_BEZ');
      rcd_lads_exp_hst.fbsta_bez := lics_inbound_utility.get_variable('FBSTA_BEZ');
      rcd_lads_exp_hst.arsta_bez := lics_inbound_utility.get_variable('ARSTA_BEZ');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_hsp.hspseq := 0;
      rcd_lads_exp_hsd.hsdseq := 0;
      rcd_lads_exp_hsi.hsiseq := 0;
      rcd_lads_exp_hag.hagseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_hst.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HST - ZZGRPNR');
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

      insert into lads_exp_hst
         (zzgrpnr,
          shpseq,
          hshseq,
          hstseq,
          tsnum,
          tsrfo,
          tstyp,
          vsart,
          inco1,
          laufk,
          distz,
          medst,
          fahzt,
          geszt,
          meizt,
          gesztd,
          fahztd,
          gesztda,
          fahztda,
          sdabw,
          frkrl,
          skalsm,
          fbsta,
          arsta,
          warztd,
          warztda,
          cont_dg,
          tstyp_bez,
          vsart_bez,
          inco1_bez,
          laufk_bez,
          fbsta_bez,
          arsta_bez)
      values
         (rcd_lads_exp_hst.zzgrpnr,
          rcd_lads_exp_hst.shpseq,
          rcd_lads_exp_hst.hshseq,
          rcd_lads_exp_hst.hstseq,
          rcd_lads_exp_hst.tsnum,
          rcd_lads_exp_hst.tsrfo,
          rcd_lads_exp_hst.tstyp,
          rcd_lads_exp_hst.vsart,
          rcd_lads_exp_hst.inco1,
          rcd_lads_exp_hst.laufk,
          rcd_lads_exp_hst.distz,
          rcd_lads_exp_hst.medst,
          rcd_lads_exp_hst.fahzt,
          rcd_lads_exp_hst.geszt,
          rcd_lads_exp_hst.meizt,
          rcd_lads_exp_hst.gesztd,
          rcd_lads_exp_hst.fahztd,
          rcd_lads_exp_hst.gesztda,
          rcd_lads_exp_hst.fahztda,
          rcd_lads_exp_hst.sdabw,
          rcd_lads_exp_hst.frkrl,
          rcd_lads_exp_hst.skalsm,
          rcd_lads_exp_hst.fbsta,
          rcd_lads_exp_hst.arsta,
          rcd_lads_exp_hst.warztd,
          rcd_lads_exp_hst.warztda,
          rcd_lads_exp_hst.cont_dg,
          rcd_lads_exp_hst.tstyp_bez,
          rcd_lads_exp_hst.vsart_bez,
          rcd_lads_exp_hst.inco1_bez,
          rcd_lads_exp_hst.laufk_bez,
          rcd_lads_exp_hst.fbsta_bez,
          rcd_lads_exp_hst.arsta_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hst;

   /**************************************************/
   /* This procedure performs the record HSP routine */
   /**************************************************/
   procedure process_record_hsp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HSP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hsp.zzgrpnr := rcd_lads_exp_hst.zzgrpnr;
      rcd_lads_exp_hsp.shpseq := rcd_lads_exp_hst.shpseq;
      rcd_lads_exp_hsp.hshseq := rcd_lads_exp_hst.hshseq;
      rcd_lads_exp_hsp.hstseq := rcd_lads_exp_hst.hstseq;
      rcd_lads_exp_hsp.hspseq := rcd_lads_exp_hsp.hspseq + 1;
      rcd_lads_exp_hsp.quali := lics_inbound_utility.get_variable('QUALI');
      rcd_lads_exp_hsp.knote := lics_inbound_utility.get_variable('KNOTE');
      rcd_lads_exp_hsp.adrnr := lics_inbound_utility.get_variable('ADRNR');
      rcd_lads_exp_hsp.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_exp_hsp.lstel := lics_inbound_utility.get_variable('LSTEL');
      rcd_lads_exp_hsp.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_exp_hsp.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_exp_hsp.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_exp_hsp.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_exp_hsp.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_exp_hsp.lgnum := lics_inbound_utility.get_variable('LGNUM');
      rcd_lads_exp_hsp.lgtor := lics_inbound_utility.get_variable('LGTOR');
      rcd_lads_exp_hsp.bahnra := lics_inbound_utility.get_variable('BAHNRA');
      rcd_lads_exp_hsp.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_exp_hsp.address_t := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_lads_exp_hsp.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_exp_hsp.jurisdic := lics_inbound_utility.get_variable('JURISDIC');
      rcd_lads_exp_hsp.knote_bez := lics_inbound_utility.get_variable('KNOTE_BEZ');
      rcd_lads_exp_hsp.vstel_bez := lics_inbound_utility.get_variable('VSTEL_BEZ');
      rcd_lads_exp_hsp.lstel_bez := lics_inbound_utility.get_variable('LSTEL_BEZ');
      rcd_lads_exp_hsp.werks_bez := lics_inbound_utility.get_variable('WERKS_BEZ');
      rcd_lads_exp_hsp.lgort_bez := lics_inbound_utility.get_variable('LGORT_BEZ');
      rcd_lads_exp_hsp.lgnum_bez := lics_inbound_utility.get_variable('LGNUM_BEZ');
      rcd_lads_exp_hsp.lgtor_bez := lics_inbound_utility.get_variable('LGTOR_BEZ');

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
      if rcd_lads_exp_hsp.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HSP - ZZGRPNR');
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

      insert into lads_exp_hsp
         (zzgrpnr,
          shpseq,
          hshseq,
          hstseq,
          hspseq,
          quali,
          knote,
          adrnr,
          vstel,
          lstel,
          werks,
          lgort,
          kunnr,
          lifnr,
          ablad,
          lgnum,
          lgtor,
          bahnra,
          partner_q,
          address_t,
          partner_id,
          jurisdic,
          knote_bez,
          vstel_bez,
          lstel_bez,
          werks_bez,
          lgort_bez,
          lgnum_bez,
          lgtor_bez)
      values
         (rcd_lads_exp_hsp.zzgrpnr,
          rcd_lads_exp_hsp.shpseq,
          rcd_lads_exp_hsp.hshseq,
          rcd_lads_exp_hsp.hstseq,
          rcd_lads_exp_hsp.hspseq,
          rcd_lads_exp_hsp.quali,
          rcd_lads_exp_hsp.knote,
          rcd_lads_exp_hsp.adrnr,
          rcd_lads_exp_hsp.vstel,
          rcd_lads_exp_hsp.lstel,
          rcd_lads_exp_hsp.werks,
          rcd_lads_exp_hsp.lgort,
          rcd_lads_exp_hsp.kunnr,
          rcd_lads_exp_hsp.lifnr,
          rcd_lads_exp_hsp.ablad,
          rcd_lads_exp_hsp.lgnum,
          rcd_lads_exp_hsp.lgtor,
          rcd_lads_exp_hsp.bahnra,
          rcd_lads_exp_hsp.partner_q,
          rcd_lads_exp_hsp.address_t,
          rcd_lads_exp_hsp.partner_id,
          rcd_lads_exp_hsp.jurisdic,
          rcd_lads_exp_hsp.knote_bez,
          rcd_lads_exp_hsp.vstel_bez,
          rcd_lads_exp_hsp.lstel_bez,
          rcd_lads_exp_hsp.werks_bez,
          rcd_lads_exp_hsp.lgort_bez,
          rcd_lads_exp_hsp.lgnum_bez,
          rcd_lads_exp_hsp.lgtor_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hsp;

   /**************************************************/
   /* This procedure performs the record HSD routine */
   /**************************************************/
   procedure process_record_hsd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HSD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hsd.zzgrpnr := rcd_lads_exp_hst.zzgrpnr;
      rcd_lads_exp_hsd.shpseq := rcd_lads_exp_hst.shpseq;
      rcd_lads_exp_hsd.hshseq := rcd_lads_exp_hst.hshseq;
      rcd_lads_exp_hsd.hstseq := rcd_lads_exp_hst.hstseq;
      rcd_lads_exp_hsd.hsdseq := rcd_lads_exp_hsd.hsdseq + 1;
      rcd_lads_exp_hsd.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_exp_hsd.ntanf := lics_inbound_utility.get_variable('NTANF');
      rcd_lads_exp_hsd.ntanz := lics_inbound_utility.get_variable('NTANZ');
      rcd_lads_exp_hsd.ntend := lics_inbound_utility.get_variable('NTEND');
      rcd_lads_exp_hsd.ntenz := lics_inbound_utility.get_variable('NTENZ');
      rcd_lads_exp_hsd.isdd := lics_inbound_utility.get_variable('ISDD');
      rcd_lads_exp_hsd.isdz := lics_inbound_utility.get_variable('ISDZ');
      rcd_lads_exp_hsd.iedd := lics_inbound_utility.get_variable('IEDD');
      rcd_lads_exp_hsd.iedz := lics_inbound_utility.get_variable('IEDZ');
      rcd_lads_exp_hsd.vornr := lics_inbound_utility.get_variable('VORNR');
      rcd_lads_exp_hsd.vstga := lics_inbound_utility.get_variable('VSTGA');

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
      if rcd_lads_exp_hsd.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HSD - ZZGRPNR');
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

      insert into lads_exp_hsd
         (zzgrpnr,
          shpseq,
          hshseq,
          hstseq,
          hsdseq,
          qualf,
          ntanf,
          ntanz,
          ntend,
          ntenz,
          isdd,
          isdz,
          iedd,
          iedz,
          vornr,
          vstga)
      values
         (rcd_lads_exp_hsd.zzgrpnr,
          rcd_lads_exp_hsd.shpseq,
          rcd_lads_exp_hsd.hshseq,
          rcd_lads_exp_hsd.hstseq,
          rcd_lads_exp_hsd.hsdseq,
          rcd_lads_exp_hsd.qualf,
          rcd_lads_exp_hsd.ntanf,
          rcd_lads_exp_hsd.ntanz,
          rcd_lads_exp_hsd.ntend,
          rcd_lads_exp_hsd.ntenz,
          rcd_lads_exp_hsd.isdd,
          rcd_lads_exp_hsd.isdz,
          rcd_lads_exp_hsd.iedd,
          rcd_lads_exp_hsd.iedz,
          rcd_lads_exp_hsd.vornr,
          rcd_lads_exp_hsd.vstga);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hsd;

   /**************************************************/
   /* This procedure performs the record HSI routine */
   /**************************************************/
   procedure process_record_hsi(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HSI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hsi.zzgrpnr := rcd_lads_exp_hst.zzgrpnr;
      rcd_lads_exp_hsi.shpseq := rcd_lads_exp_hst.shpseq;
      rcd_lads_exp_hsi.hshseq := rcd_lads_exp_hst.hshseq;
      rcd_lads_exp_hsi.hstseq := rcd_lads_exp_hst.hstseq;
      rcd_lads_exp_hsi.hsiseq := rcd_lads_exp_hsi.hsiseq + 1;
      rcd_lads_exp_hsi.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_lads_exp_hsi.parid := lics_inbound_utility.get_variable('PARID');

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
      if rcd_lads_exp_hsi.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HSI - ZZGRPNR');
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

      insert into lads_exp_hsi
         (zzgrpnr,
          shpseq,
          hshseq,
          hstseq,
          hsiseq,
          vbeln,
          parid)
      values
         (rcd_lads_exp_hsi.zzgrpnr,
          rcd_lads_exp_hsi.shpseq,
          rcd_lads_exp_hsi.hshseq,
          rcd_lads_exp_hsi.hstseq,
          rcd_lads_exp_hsi.hsiseq,
          rcd_lads_exp_hsi.vbeln,
          rcd_lads_exp_hsi.parid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hsi;

   /**************************************************/
   /* This procedure performs the record HAG routine */
   /**************************************************/
   procedure process_record_hag(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HAG', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hag.zzgrpnr := rcd_lads_exp_hst.zzgrpnr;
      rcd_lads_exp_hag.shpseq := rcd_lads_exp_hst.shpseq;
      rcd_lads_exp_hag.hshseq := rcd_lads_exp_hst.hshseq;
      rcd_lads_exp_hag.hstseq := rcd_lads_exp_hst.hstseq;
      rcd_lads_exp_hag.hagseq := rcd_lads_exp_hag.hagseq + 1;
      rcd_lads_exp_hag.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_exp_hag.address_t := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_lads_exp_hag.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_exp_hag.jurisdic := lics_inbound_utility.get_variable('JURISDIC');

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
      if rcd_lads_exp_hag.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HAG - ZZGRPNR');
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

      insert into lads_exp_hag
         (zzgrpnr,
          shpseq,
          hshseq,
          hstseq,
          hagseq,
          partner_q,
          address_t,
          partner_id,
          jurisdic)
      values
         (rcd_lads_exp_hag.zzgrpnr,
          rcd_lads_exp_hag.shpseq,
          rcd_lads_exp_hag.hshseq,
          rcd_lads_exp_hag.hstseq,
          rcd_lads_exp_hag.hagseq,
          rcd_lads_exp_hag.partner_q,
          rcd_lads_exp_hag.address_t,
          rcd_lads_exp_hag.partner_id,
          rcd_lads_exp_hag.jurisdic);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hag;

   /**************************************************/
   /* This procedure performs the record INV routine */
   /**************************************************/
   procedure process_record_inv(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('INV', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_inv.zzgrpnr := rcd_lads_exp_hdr.zzgrpnr;
      rcd_lads_exp_inv.invseq := rcd_lads_exp_inv.invseq + 1;
      rcd_lads_exp_inv.znbinvoic := lics_inbound_utility.get_variable('ZNBINVOIC');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_hin.hinseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_inv.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_INV - ZZGRPNR');
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

      insert into lads_exp_inv
         (zzgrpnr,
          invseq,
          znbinvoic)
      values
         (rcd_lads_exp_inv.zzgrpnr,
          rcd_lads_exp_inv.invseq,
          rcd_lads_exp_inv.znbinvoic);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_inv;

   /**************************************************/
   /* This procedure performs the record HIN routine */
   /**************************************************/
   procedure process_record_hin(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HIN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_hin.zzgrpnr := rcd_lads_exp_inv.zzgrpnr;
      rcd_lads_exp_hin.invseq := rcd_lads_exp_inv.invseq;
      rcd_lads_exp_hin.hinseq := rcd_lads_exp_hin.hinseq + 1;
      rcd_lads_exp_hin.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_exp_hin.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_exp_hin.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_exp_hin.hwaer := lics_inbound_utility.get_variable('HWAER');
      rcd_lads_exp_hin.wkurs := lics_inbound_utility.get_variable('WKURS');
      rcd_lads_exp_hin.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_exp_hin.kundeuinr := lics_inbound_utility.get_variable('KUNDEUINR');
      rcd_lads_exp_hin.eigenuinr := lics_inbound_utility.get_variable('EIGENUINR');
      rcd_lads_exp_hin.bsart := lics_inbound_utility.get_variable('BSART');
      rcd_lads_exp_hin.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_exp_hin.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_exp_hin.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_exp_hin.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_exp_hin.fkart_rl := lics_inbound_utility.get_variable('FKART_RL');
      rcd_lads_exp_hin.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_exp_hin.bstzd := lics_inbound_utility.get_variable('BSTZD');
      rcd_lads_exp_hin.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_exp_hin.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_exp_hin.recipnt_no := lics_inbound_utility.get_variable('RECIPNT_NO');
      rcd_lads_exp_hin.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_exp_hin.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_lads_exp_hin.augru := lics_inbound_utility.get_variable('AUGRU');
      rcd_lads_exp_hin.augru_bez := lics_inbound_utility.get_variable('AUGRU_BEZ');
      rcd_lads_exp_hin.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_exp_hin.abrvw_bez := lics_inbound_utility.get_variable('ABRVW_BEZ');
      rcd_lads_exp_hin.fktyp := lics_inbound_utility.get_variable('FKTYP');
      rcd_lads_exp_hin.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_lads_exp_hin.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_lads_exp_hin.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_exp_hin.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_exp_hin.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_exp_hin.wkurs_m := lics_inbound_utility.get_variable('WKURS_M');
      rcd_lads_exp_hin.del_belnr := lics_inbound_utility.get_variable('DEL_BELNR');
      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_ign.ignseq := 0;
      rcd_lads_exp_sin.sinseq := 0;
      rcd_lads_exp_idt.idtseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_hin.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_HIN - ZZGRPNR');
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

      insert into lads_exp_hin
         (zzgrpnr,
          invseq,
          hinseq,
          action,
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
          del_belnr)
      values
         (rcd_lads_exp_hin.zzgrpnr,
          rcd_lads_exp_hin.invseq,
          rcd_lads_exp_hin.hinseq,
          rcd_lads_exp_hin.action,
          rcd_lads_exp_hin.kzabs,
          rcd_lads_exp_hin.curcy,
          rcd_lads_exp_hin.hwaer,
          rcd_lads_exp_hin.wkurs,
          rcd_lads_exp_hin.zterm,
          rcd_lads_exp_hin.kundeuinr,
          rcd_lads_exp_hin.eigenuinr,
          rcd_lads_exp_hin.bsart,
          rcd_lads_exp_hin.belnr,
          rcd_lads_exp_hin.ntgew,
          rcd_lads_exp_hin.brgew,
          rcd_lads_exp_hin.gewei,
          rcd_lads_exp_hin.fkart_rl,
          rcd_lads_exp_hin.ablad,
          rcd_lads_exp_hin.bstzd,
          rcd_lads_exp_hin.vsart,
          rcd_lads_exp_hin.vsart_bez,
          rcd_lads_exp_hin.recipnt_no,
          rcd_lads_exp_hin.kzazu,
          rcd_lads_exp_hin.autlf,
          rcd_lads_exp_hin.augru,
          rcd_lads_exp_hin.augru_bez,
          rcd_lads_exp_hin.abrvw,
          rcd_lads_exp_hin.abrvw_bez,
          rcd_lads_exp_hin.fktyp,
          rcd_lads_exp_hin.lifsk,
          rcd_lads_exp_hin.lifsk_bez,
          rcd_lads_exp_hin.empst,
          rcd_lads_exp_hin.abtnr,
          rcd_lads_exp_hin.delco,
          rcd_lads_exp_hin.wkurs_m,
          rcd_lads_exp_hin.del_belnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hin;

   /**************************************************/
   /* This procedure performs the record IGN routine */
   /**************************************************/
   procedure process_record_ign(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IGN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_ign.zzgrpnr := rcd_lads_exp_hin.zzgrpnr;
      rcd_lads_exp_ign.invseq := rcd_lads_exp_hin.invseq;
      rcd_lads_exp_ign.hinseq := rcd_lads_exp_hin.hinseq;
      rcd_lads_exp_ign.ignseq := rcd_lads_exp_ign.ignseq + 1;
      rcd_lads_exp_ign.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_lads_exp_ign.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_exp_ign.menee := lics_inbound_utility.get_variable('MENEE');
      rcd_lads_exp_ign.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_exp_ign.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_exp_ign.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_exp_ign.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_lads_exp_ign.werks := lics_inbound_utility.get_variable('WERKS');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_exp_ire.ireseq := 0;
      rcd_lads_exp_icn.icnseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_exp_ign.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_IGN - ZZGRPNR');
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

      insert into lads_exp_ign
         (zzgrpnr,
          invseq,
          hinseq,
          ignseq,
          posex,
          menge,
          menee,
          ntgew,
          gewei,
          brgew,
          pstyv,
          werks)
      values
         (rcd_lads_exp_ign.zzgrpnr,
          rcd_lads_exp_ign.invseq,
          rcd_lads_exp_ign.hinseq,
          rcd_lads_exp_ign.ignseq,
          rcd_lads_exp_ign.posex,
          rcd_lads_exp_ign.menge,
          rcd_lads_exp_ign.menee,
          rcd_lads_exp_ign.ntgew,
          rcd_lads_exp_ign.gewei,
          rcd_lads_exp_ign.brgew,
          rcd_lads_exp_ign.pstyv,
          rcd_lads_exp_ign.werks);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ign;

   /**************************************************/
   /* This procedure performs the record IRE routine */
   /**************************************************/
   procedure process_record_ire(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('IRE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_ire.zzgrpnr := rcd_lads_exp_ign.zzgrpnr;
      rcd_lads_exp_ire.invseq := rcd_lads_exp_ign.invseq;
      rcd_lads_exp_ire.hinseq := rcd_lads_exp_ign.hinseq;
      rcd_lads_exp_ire.ignseq := rcd_lads_exp_ign.ignseq;
      rcd_lads_exp_ire.ireseq := rcd_lads_exp_ire.ireseq + 1;
      rcd_lads_exp_ire.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_exp_ire.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_exp_ire.zeile := lics_inbound_utility.get_variable('ZEILE');
      rcd_lads_exp_ire.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_exp_ire.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_lads_exp_ire.bsark := lics_inbound_utility.get_variable('BSARK');
      rcd_lads_exp_ire.ihrez := lics_inbound_utility.get_variable('IHREZ');

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
      if rcd_lads_exp_ire.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_IRE - ZZGRPNR');
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

      insert into lads_exp_ire
         (zzgrpnr,
          invseq,
          hinseq,
          ignseq,
          ireseq,
          qualf,
          belnr,
          zeile,
          datum,
          uzeit,
          bsark,
          ihrez)
      values
         (rcd_lads_exp_ire.zzgrpnr,
          rcd_lads_exp_ire.invseq,
          rcd_lads_exp_ire.hinseq,
          rcd_lads_exp_ire.ignseq,
          rcd_lads_exp_ire.ireseq,
          rcd_lads_exp_ire.qualf,
          rcd_lads_exp_ire.belnr,
          rcd_lads_exp_ire.zeile,
          rcd_lads_exp_ire.datum,
          rcd_lads_exp_ire.uzeit,
          rcd_lads_exp_ire.bsark,
          rcd_lads_exp_ire.ihrez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ire;

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
      rcd_lads_exp_icn.zzgrpnr := rcd_lads_exp_ign.zzgrpnr;
      rcd_lads_exp_icn.invseq := rcd_lads_exp_ign.invseq;
      rcd_lads_exp_icn.hinseq := rcd_lads_exp_ign.hinseq;
      rcd_lads_exp_icn.ignseq := rcd_lads_exp_ign.ignseq;
      rcd_lads_exp_icn.icnseq := rcd_lads_exp_icn.icnseq + 1;
      rcd_lads_exp_icn.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_lads_exp_icn.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_exp_icn.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_lads_exp_icn.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_exp_icn.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_lads_exp_icn.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_lads_exp_icn.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_lads_exp_icn.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_lads_exp_icn.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_lads_exp_icn.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_exp_icn.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_exp_icn.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_exp_icn.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_exp_icn.koein := lics_inbound_utility.get_variable('KOEIN');
      rcd_lads_exp_icn.curtp := lics_inbound_utility.get_variable('CURTP');
      rcd_lads_exp_icn.kobas := lics_inbound_utility.get_variable('KOBAS');

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
      if rcd_lads_exp_icn.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_ICN - ZZGRPNR');
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

      insert into lads_exp_icn
         (zzgrpnr,
          invseq,
          hinseq,
          ignseq,
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
         (rcd_lads_exp_icn.zzgrpnr,
          rcd_lads_exp_icn.invseq,
          rcd_lads_exp_icn.hinseq,
          rcd_lads_exp_icn.ignseq,
          rcd_lads_exp_icn.icnseq,
          rcd_lads_exp_icn.alckz,
          rcd_lads_exp_icn.kschl,
          rcd_lads_exp_icn.kotxt,
          rcd_lads_exp_icn.betrg,
          rcd_lads_exp_icn.kperc,
          rcd_lads_exp_icn.krate,
          rcd_lads_exp_icn.uprbs,
          rcd_lads_exp_icn.meaun,
          rcd_lads_exp_icn.kobtr,
          rcd_lads_exp_icn.menge,
          rcd_lads_exp_icn.preis,
          rcd_lads_exp_icn.mwskz,
          rcd_lads_exp_icn.msatz,
          rcd_lads_exp_icn.koein,
          rcd_lads_exp_icn.curtp,
          rcd_lads_exp_icn.kobas);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_icn;

   /**************************************************/
   /* This procedure performs the record SIN routine */
   /**************************************************/
   procedure process_record_sin(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SIN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_exp_sin.zzgrpnr := rcd_lads_exp_hin.zzgrpnr;
      rcd_lads_exp_sin.invseq := rcd_lads_exp_hin.invseq;
      rcd_lads_exp_sin.hinseq := rcd_lads_exp_hin.hinseq;
      rcd_lads_exp_sin.sinseq := rcd_lads_exp_sin.sinseq + 1;
      rcd_lads_exp_sin.sumid := lics_inbound_utility.get_variable('SUMID');
      rcd_lads_exp_sin.summe := lics_inbound_utility.get_variable('SUMME');
      rcd_lads_exp_sin.sunit := lics_inbound_utility.get_variable('SUNIT');
      rcd_lads_exp_sin.waerq := lics_inbound_utility.get_variable('WAERQ');

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
      if rcd_lads_exp_sin.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_SIN - ZZGRPNR');
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

      insert into lads_exp_sin
         (zzgrpnr,
          invseq,
          hinseq,
          sinseq,
          sumid,
          summe,
          sunit,
          waerq)
      values
         (rcd_lads_exp_sin.zzgrpnr,
          rcd_lads_exp_sin.invseq,
          rcd_lads_exp_sin.hinseq,
          rcd_lads_exp_sin.sinseq,
          rcd_lads_exp_sin.sumid,
          rcd_lads_exp_sin.summe,
          rcd_lads_exp_sin.sunit,
          rcd_lads_exp_sin.waerq);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_sin;

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
      rcd_lads_exp_idt.zzgrpnr := rcd_lads_exp_hin.zzgrpnr;
      rcd_lads_exp_idt.invseq := rcd_lads_exp_hin.invseq;
      rcd_lads_exp_idt.hinseq := rcd_lads_exp_hin.hinseq;
      rcd_lads_exp_idt.idtseq := rcd_lads_exp_idt.idtseq + 1;
      rcd_lads_exp_idt.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_lads_exp_idt.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_exp_idt.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_exp_idt.zzgrpnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_EXP_IDT - ZZGRPNR');
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

      insert into lads_exp_idt
         (zzgrpnr,
          invseq,
          hinseq,
          idtseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_lads_exp_idt.zzgrpnr,
          rcd_lads_exp_idt.invseq,
          rcd_lads_exp_idt.hinseq,
          rcd_lads_exp_idt.idtseq,
          rcd_lads_exp_idt.iddat,
          rcd_lads_exp_idt.datum,
          rcd_lads_exp_idt.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_idt;


end lads_atllad25;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad25 for lads_app.lads_atllad25;
grant execute on lads_atllad25 to lics_app;
