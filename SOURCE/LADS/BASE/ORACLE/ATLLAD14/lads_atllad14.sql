/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad14
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad14 - Inbound Shipment Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad14 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad14;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad14 as

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
   procedure process_record_hct(par_record in varchar2);
   procedure process_record_har(par_record in varchar2);
   procedure process_record_had(par_record in varchar2);
   procedure process_record_hda(par_record in varchar2);
   procedure process_record_htx(par_record in varchar2);
   procedure process_record_htg(par_record in varchar2);
   procedure process_record_hst(par_record in varchar2);
   procedure process_record_hsp(par_record in varchar2);
   procedure process_record_hsd(par_record in varchar2);
   procedure process_record_hsi(par_record in varchar2);
   procedure process_record_dlv(par_record in varchar2);
   procedure process_record_dad(par_record in varchar2);
   procedure process_record_das(par_record in varchar2);
   procedure process_record_ded(par_record in varchar2);
   procedure process_record_drs(par_record in varchar2);
   procedure process_record_dit(par_record in varchar2);
   procedure process_record_dib(par_record in varchar2);
   procedure process_record_dng(par_record in varchar2);
   procedure process_record_dbt(par_record in varchar2);
   procedure process_record_drf(par_record in varchar2);
   procedure process_record_dhu(par_record in varchar2);
   procedure process_record_dhi(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_shp_hdr lads_shp_hdr%rowtype;
   rcd_lads_shp_hct lads_shp_hct%rowtype;
   rcd_lads_shp_har lads_shp_har%rowtype;
   rcd_lads_shp_had lads_shp_had%rowtype;
   rcd_lads_shp_hda lads_shp_hda%rowtype;
   rcd_lads_shp_htx lads_shp_htx%rowtype;
   rcd_lads_shp_htg lads_shp_htg%rowtype;
   rcd_lads_shp_hst lads_shp_hst%rowtype;
   rcd_lads_shp_hsp lads_shp_hsp%rowtype;
   rcd_lads_shp_hsd lads_shp_hsd%rowtype;
   rcd_lads_shp_hsi lads_shp_hsi%rowtype;
   rcd_lads_shp_dlv lads_shp_dlv%rowtype;
   rcd_lads_shp_dad lads_shp_dad%rowtype;
   rcd_lads_shp_das lads_shp_das%rowtype;
   rcd_lads_shp_ded lads_shp_ded%rowtype;
   rcd_lads_shp_drs lads_shp_drs%rowtype;
   rcd_lads_shp_dit lads_shp_dit%rowtype;
   rcd_lads_shp_dib lads_shp_dib%rowtype;
   rcd_lads_shp_dng lads_shp_dng%rowtype;
   rcd_lads_shp_dbt lads_shp_dbt%rowtype;
   rcd_lads_shp_drf lads_shp_drf%rowtype;
   rcd_lads_shp_dhu lads_shp_dhu%rowtype;
   rcd_lads_shp_dhi lads_shp_dhi%rowtype;

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
      lics_inbound_utility.set_definition('HDR','TKNUM',10);
      lics_inbound_utility.set_definition('HDR','SHTYP',4);
      lics_inbound_utility.set_definition('HDR','ABFER',1);
      lics_inbound_utility.set_definition('HDR','ABWST',1);
      lics_inbound_utility.set_definition('HDR','BFART',1);
      lics_inbound_utility.set_definition('HDR','VSART',2);
      lics_inbound_utility.set_definition('HDR','LAUFK',1);
      lics_inbound_utility.set_definition('HDR','VSBED',2);
      lics_inbound_utility.set_definition('HDR','ROUTE',6);
      lics_inbound_utility.set_definition('HDR','SIGNI',20);
      lics_inbound_utility.set_definition('HDR','EXTI1',20);
      lics_inbound_utility.set_definition('HDR','EXTI2',20);
      lics_inbound_utility.set_definition('HDR','TPBEZ',20);
      lics_inbound_utility.set_definition('HDR','STTRG',1);
      lics_inbound_utility.set_definition('HDR','PKSTK',1);
      lics_inbound_utility.set_definition('HDR','DTMEG',3);
      lics_inbound_utility.set_definition('HDR','DTMEV',3);
      lics_inbound_utility.set_definition('HDR','DISTZ',16);
      lics_inbound_utility.set_definition('HDR','MEDST',3);
      lics_inbound_utility.set_definition('HDR','FAHZT',8);
      lics_inbound_utility.set_definition('HDR','GESZT',8);
      lics_inbound_utility.set_definition('HDR','MEIZT',3);
      lics_inbound_utility.set_definition('HDR','FBSTA',1);
      lics_inbound_utility.set_definition('HDR','FBGST',1);
      lics_inbound_utility.set_definition('HDR','ARSTA',1);
      lics_inbound_utility.set_definition('HDR','ARGST',1);
      lics_inbound_utility.set_definition('HDR','STERM_DONE',1);
      lics_inbound_utility.set_definition('HDR','VSE_FRK',1);
      lics_inbound_utility.set_definition('HDR','KKALSM',6);
      lics_inbound_utility.set_definition('HDR','SDABW',4);
      lics_inbound_utility.set_definition('HDR','FRKRL',1);
      lics_inbound_utility.set_definition('HDR','GESZTD',12);
      lics_inbound_utility.set_definition('HDR','FAHZTD',12);
      lics_inbound_utility.set_definition('HDR','GESZTDA',12);
      lics_inbound_utility.set_definition('HDR','FAHZTDA',12);
      lics_inbound_utility.set_definition('HDR','WARZTD',12);
      lics_inbound_utility.set_definition('HDR','WARZTDA',12);
      lics_inbound_utility.set_definition('HDR','SHTYP_BEZ',20);
      lics_inbound_utility.set_definition('HDR','BFART_BEZ',20);
      lics_inbound_utility.set_definition('HDR','VSART_BEZ',20);
      lics_inbound_utility.set_definition('HDR','LAUFK_BEZ',20);
      lics_inbound_utility.set_definition('HDR','VSBED_BEZ',20);
      lics_inbound_utility.set_definition('HDR','ROUTE_BEZ',40);
      lics_inbound_utility.set_definition('HDR','STTRG_BEZ',20);
      lics_inbound_utility.set_definition('HDR','FBSTA_BEZ',25);
      lics_inbound_utility.set_definition('HDR','FBGST_BEZ',25);
      lics_inbound_utility.set_definition('HDR','ARSTA_BEZ',25);
      lics_inbound_utility.set_definition('HDR','ARGST_BEZ',25);
      lics_inbound_utility.set_definition('HDR','TNDRST',2);
      lics_inbound_utility.set_definition('HDR','TNDRRC',2);
      lics_inbound_utility.set_definition('HDR','TNDR_TEXT',80);
      lics_inbound_utility.set_definition('HDR','TNDRDAT',8);
      lics_inbound_utility.set_definition('HDR','TNDRZET',6);
      lics_inbound_utility.set_definition('HDR','TNDR_MAXP',18);
      lics_inbound_utility.set_definition('HDR','TNDR_MAXC',5);
      lics_inbound_utility.set_definition('HDR','TNDR_ACTP',18);
      lics_inbound_utility.set_definition('HDR','TNDR_ACTC',5);
      lics_inbound_utility.set_definition('HDR','TNDR_CARR',10);
      lics_inbound_utility.set_definition('HDR','TNDR_CRNM',35);
      lics_inbound_utility.set_definition('HDR','TNDR_TRKID',35);
      lics_inbound_utility.set_definition('HDR','TNDR_EXPD',8);
      lics_inbound_utility.set_definition('HDR','TNDR_EXPT',6);
      lics_inbound_utility.set_definition('HDR','TNDR_ERPD',8);
      lics_inbound_utility.set_definition('HDR','TNDR_ERPT',6);
      lics_inbound_utility.set_definition('HDR','TNDR_LTPD',8);
      lics_inbound_utility.set_definition('HDR','TNDR_LTPT',6);
      lics_inbound_utility.set_definition('HDR','TNDR_ERDD',8);
      lics_inbound_utility.set_definition('HDR','TNDR_ERDT',6);
      lics_inbound_utility.set_definition('HDR','TNDR_LTDD',8);
      lics_inbound_utility.set_definition('HDR','TNDR_LTDT',6);
      lics_inbound_utility.set_definition('HDR','TNDR_LDLG',16);
      lics_inbound_utility.set_definition('HDR','TNDR_LDLU',3);
      lics_inbound_utility.set_definition('HDR','TNDRST_BEZ',60);
      lics_inbound_utility.set_definition('HDR','TNDRRC_BEZ',60);
      /*-*/
      lics_inbound_utility.set_definition('HCT','IDOC_HCT',3);
      lics_inbound_utility.set_definition('HCT','QUALF',3);
      lics_inbound_utility.set_definition('HCT','PARAM',20);
      /*-*/
      lics_inbound_utility.set_definition('HAR','IDOC_HAR',3);
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
      lics_inbound_utility.set_definition('HAD','IDOC_HAD',3);
      lics_inbound_utility.set_definition('HAD','EXTEND_Q',3);
      lics_inbound_utility.set_definition('HAD','EXTEND_D',70);
      /*-*/
      lics_inbound_utility.set_definition('HDA','IDOC_HDA',3);
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
      lics_inbound_utility.set_definition('HDA','KNOTE',10);
      lics_inbound_utility.set_definition('HDA','KNOTE_BEZ',30);
      /*-*/
      lics_inbound_utility.set_definition('HTX','IDOC_HTX',3);
      lics_inbound_utility.set_definition('HTX','FUNCTION',3);
      lics_inbound_utility.set_definition('HTX','TDOBJECT',10);
      lics_inbound_utility.set_definition('HTX','TDOBNAME',70);
      lics_inbound_utility.set_definition('HTX','TDID',4);
      lics_inbound_utility.set_definition('HTX','TDSPRAS',1);
      lics_inbound_utility.set_definition('HTX','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('HTX','LANGUA_ISO',2);
      /*-*/
      lics_inbound_utility.set_definition('HTG','IDOC_HTG',3);
      lics_inbound_utility.set_definition('HTG','TDFORMAT',2);
      lics_inbound_utility.set_definition('HTG','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('HST','IDOC_HST',3);
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
      lics_inbound_utility.set_definition('HSP','IDOC_HSP',3);
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
      lics_inbound_utility.set_definition('HSP','LANGUAGE',2);
      lics_inbound_utility.set_definition('HSP','FORMOFADDR',15);
      lics_inbound_utility.set_definition('HSP','NAME1',40);
      lics_inbound_utility.set_definition('HSP','NAME2',40);
      lics_inbound_utility.set_definition('HSP','NAME3',40);
      lics_inbound_utility.set_definition('HSP','NAME4',40);
      lics_inbound_utility.set_definition('HSP','NAME_TEXT',50);
      lics_inbound_utility.set_definition('HSP','NAME_CO',40);
      lics_inbound_utility.set_definition('HSP','LOCATION',40);
      lics_inbound_utility.set_definition('HSP','BUILDING',10);
      lics_inbound_utility.set_definition('HSP','FLOOR',10);
      lics_inbound_utility.set_definition('HSP','ROOM',10);
      lics_inbound_utility.set_definition('HSP','STREET1',40);
      lics_inbound_utility.set_definition('HSP','STREET2',40);
      lics_inbound_utility.set_definition('HSP','STREET3',40);
      lics_inbound_utility.set_definition('HSP','HOUSE_SUPL',4);
      lics_inbound_utility.set_definition('HSP','HOUSE_RANG',10);
      lics_inbound_utility.set_definition('HSP','POSTL_COD1',10);
      lics_inbound_utility.set_definition('HSP','POSTL_COD3',10);
      lics_inbound_utility.set_definition('HSP','POSTL_AREA',15);
      lics_inbound_utility.set_definition('HSP','CITY1',40);
      lics_inbound_utility.set_definition('HSP','CITY2',40);
      lics_inbound_utility.set_definition('HSP','POSTL_PBOX',10);
      lics_inbound_utility.set_definition('HSP','POSTL_COD2',10);
      lics_inbound_utility.set_definition('HSP','POSTL_CITY',40);
      lics_inbound_utility.set_definition('HSP','TELEPHONE1',30);
      lics_inbound_utility.set_definition('HSP','TELEPHONE2',30);
      lics_inbound_utility.set_definition('HSP','TELEFAX',30);
      lics_inbound_utility.set_definition('HSP','TELEX',30);
      lics_inbound_utility.set_definition('HSP','E_MAIL',70);
      lics_inbound_utility.set_definition('HSP','COUNTRY1',3);
      lics_inbound_utility.set_definition('HSP','COUNTRY2',3);
      lics_inbound_utility.set_definition('HSP','REGION',3);
      lics_inbound_utility.set_definition('HSP','COUNTY_COD',3);
      lics_inbound_utility.set_definition('HSP','COUNTY_TXT',25);
      lics_inbound_utility.set_definition('HSP','TZCODE',6);
      lics_inbound_utility.set_definition('HSP','TZDESC',35);
      lics_inbound_utility.set_definition('HSP','KNOTE_BEZ',30);
      lics_inbound_utility.set_definition('HSP','VSTEL_BEZ',30);
      lics_inbound_utility.set_definition('HSP','LSTEL_BEZ',20);
      lics_inbound_utility.set_definition('HSP','WERKS_BEZ',30);
      lics_inbound_utility.set_definition('HSP','LGORT_BEZ',16);
      lics_inbound_utility.set_definition('HSP','LGNUM_BEZ',25);
      lics_inbound_utility.set_definition('HSP','LGTOR_BEZ',25);
      /*-*/
      lics_inbound_utility.set_definition('HSD','IDOC_HSD',3);
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
      lics_inbound_utility.set_definition('HSI','IDOC_HSI',3);
      lics_inbound_utility.set_definition('HSI','VBELN',10);
      lics_inbound_utility.set_definition('HSI','PARID',35);
      /*-*/
      lics_inbound_utility.set_definition('DLV','IDOC_DLV',3);
      lics_inbound_utility.set_definition('DLV','VBELN',10);
      lics_inbound_utility.set_definition('DLV','VSTEL',4);
      lics_inbound_utility.set_definition('DLV','VKORG',4);
      lics_inbound_utility.set_definition('DLV','LSTEL',2);
      lics_inbound_utility.set_definition('DLV','VKBUR',4);
      lics_inbound_utility.set_definition('DLV','LGNUM',3);
      lics_inbound_utility.set_definition('DLV','ABLAD',25);
      lics_inbound_utility.set_definition('DLV','INCO1',3);
      lics_inbound_utility.set_definition('DLV','INCO2',28);
      lics_inbound_utility.set_definition('DLV','ROUTE',6);
      lics_inbound_utility.set_definition('DLV','VSBED',2);
      lics_inbound_utility.set_definition('DLV','BTGEW',18);
      lics_inbound_utility.set_definition('DLV','NTGEW',16);
      lics_inbound_utility.set_definition('DLV','GEWEI',3);
      lics_inbound_utility.set_definition('DLV','VOLUM',16);
      lics_inbound_utility.set_definition('DLV','VOLEH',3);
      lics_inbound_utility.set_definition('DLV','ANZPK',5);
      lics_inbound_utility.set_definition('DLV','BOLNR',35);
      lics_inbound_utility.set_definition('DLV','TRATY',4);
      lics_inbound_utility.set_definition('DLV','TRAID',20);
      lics_inbound_utility.set_definition('DLV','XABLN',10);
      lics_inbound_utility.set_definition('DLV','LIFEX',35);
      lics_inbound_utility.set_definition('DLV','PARID',35);
      lics_inbound_utility.set_definition('DLV','PODAT',8);
      lics_inbound_utility.set_definition('DLV','POTIM',6);
      lics_inbound_utility.set_definition('DLV','LFART',4);
      lics_inbound_utility.set_definition('DLV','BZIRK',6);
      lics_inbound_utility.set_definition('DLV','AUTLF',1);
      lics_inbound_utility.set_definition('DLV','EXPKZ',1);
      lics_inbound_utility.set_definition('DLV','LIFSK',2);
      lics_inbound_utility.set_definition('DLV','LPRIO',2);
      lics_inbound_utility.set_definition('DLV','KDGRP',2);
      lics_inbound_utility.set_definition('DLV','BEROT',20);
      lics_inbound_utility.set_definition('DLV','TRAGR',4);
      lics_inbound_utility.set_definition('DLV','TRSPG',2);
      lics_inbound_utility.set_definition('DLV','AULWE',10);
      lics_inbound_utility.set_definition('DLV','VSTEL_BEZ',30);
      lics_inbound_utility.set_definition('DLV','VKORG_BEZ',20);
      lics_inbound_utility.set_definition('DLV','LSTEL_BEZ',20);
      lics_inbound_utility.set_definition('DLV','VKBUR_BEZ',20);
      lics_inbound_utility.set_definition('DLV','LGNUM_BEZ',25);
      lics_inbound_utility.set_definition('DLV','INCO1_BEZ',30);
      lics_inbound_utility.set_definition('DLV','ROUTE_BEZ',40);
      lics_inbound_utility.set_definition('DLV','VSBED_BEZ',20);
      lics_inbound_utility.set_definition('DLV','TRATY_BEZ',20);
      lics_inbound_utility.set_definition('DLV','LFART_BEZ',20);
      lics_inbound_utility.set_definition('DLV','LPRIO_BEZ',20);
      lics_inbound_utility.set_definition('DLV','BZIRK_BEZ',20);
      lics_inbound_utility.set_definition('DLV','LIFSK_BEZ',20);
      lics_inbound_utility.set_definition('DLV','KDGRP_BEZ',20);
      lics_inbound_utility.set_definition('DLV','TRAGR_BEZ',20);
      lics_inbound_utility.set_definition('DLV','TRSPG_BEZ',20);
      lics_inbound_utility.set_definition('DLV','AULWE_BEZ',40);
      lics_inbound_utility.set_definition('DLV','ALAND',3);
      lics_inbound_utility.set_definition('DLV','EXPVZ',1);
      lics_inbound_utility.set_definition('DLV','ZOLLA',6);
      lics_inbound_utility.set_definition('DLV','ZOLLB',6);
      lics_inbound_utility.set_definition('DLV','KZGBE',30);
      lics_inbound_utility.set_definition('DLV','KZABE',30);
      lics_inbound_utility.set_definition('DLV','STGBE',3);
      lics_inbound_utility.set_definition('DLV','STABE',3);
      lics_inbound_utility.set_definition('DLV','CONTA',1);
      lics_inbound_utility.set_definition('DLV','GRWCU',5);
      lics_inbound_utility.set_definition('DLV','IEVER',1);
      lics_inbound_utility.set_definition('DLV','EXPVZ_BEZ',20);
      lics_inbound_utility.set_definition('DLV','ZOLLA_BEZ',30);
      lics_inbound_utility.set_definition('DLV','ZOLLB_BEZ',30);
      lics_inbound_utility.set_definition('DLV','IEVER_BEZ',20);
      lics_inbound_utility.set_definition('DLV','STGBE_BEZ',15);
      lics_inbound_utility.set_definition('DLV','STABE_BEZ',15);
      lics_inbound_utility.set_definition('DLV','VSART',2);
      lics_inbound_utility.set_definition('DLV','VSAVL',2);
      lics_inbound_utility.set_definition('DLV','VSANL',2);
      lics_inbound_utility.set_definition('DLV','ROUID',100);
      lics_inbound_utility.set_definition('DLV','DISTZ',16);
      lics_inbound_utility.set_definition('DLV','MEDST',3);
      lics_inbound_utility.set_definition('DLV','VSART_BEZ',20);
      lics_inbound_utility.set_definition('DLV','VSAVL_BEZ',20);
      lics_inbound_utility.set_definition('DLV','VSANL_BEZ',20);
      /*-*/
      lics_inbound_utility.set_definition('DAD','IDOC_DAD',3);
      lics_inbound_utility.set_definition('DAD','PARTNER_Q',3);
      lics_inbound_utility.set_definition('DAD','ADDRESS_T',1);
      lics_inbound_utility.set_definition('DAD','PARTNER_ID',17);
      lics_inbound_utility.set_definition('DAD','JURISDIC',17);
      lics_inbound_utility.set_definition('DAD','LANGUAGE',2);
      lics_inbound_utility.set_definition('DAD','FORMOFADDR',15);
      lics_inbound_utility.set_definition('DAD','NAME1',40);
      lics_inbound_utility.set_definition('DAD','NAME2',40);
      lics_inbound_utility.set_definition('DAD','NAME3',40);
      lics_inbound_utility.set_definition('DAD','NAME4',40);
      lics_inbound_utility.set_definition('DAD','NAME_TEXT',50);
      lics_inbound_utility.set_definition('DAD','NAME_CO',40);
      lics_inbound_utility.set_definition('DAD','LOCATION',40);
      lics_inbound_utility.set_definition('DAD','BUILDING',10);
      lics_inbound_utility.set_definition('DAD','FLOOR',10);
      lics_inbound_utility.set_definition('DAD','ROOM',10);
      lics_inbound_utility.set_definition('DAD','STREET1',40);
      lics_inbound_utility.set_definition('DAD','STREET2',40);
      lics_inbound_utility.set_definition('DAD','STREET3',40);
      lics_inbound_utility.set_definition('DAD','HOUSE_SUPL',4);
      lics_inbound_utility.set_definition('DAD','HOUSE_RANG',10);
      lics_inbound_utility.set_definition('DAD','POSTL_COD1',10);
      lics_inbound_utility.set_definition('DAD','POSTL_COD3',10);
      lics_inbound_utility.set_definition('DAD','POSTL_AREA',15);
      lics_inbound_utility.set_definition('DAD','CITY1',40);
      lics_inbound_utility.set_definition('DAD','CITY2',40);
      lics_inbound_utility.set_definition('DAD','POSTL_PBOX',10);
      lics_inbound_utility.set_definition('DAD','POSTL_COD2',10);
      lics_inbound_utility.set_definition('DAD','POSTL_CITY',40);
      lics_inbound_utility.set_definition('DAD','TELEPHONE1',30);
      lics_inbound_utility.set_definition('DAD','TELEPHONE2',30);
      lics_inbound_utility.set_definition('DAD','TELEFAX',30);
      lics_inbound_utility.set_definition('DAD','TELEX',30);
      lics_inbound_utility.set_definition('DAD','E_MAIL',70);
      lics_inbound_utility.set_definition('DAD','COUNTRY1',3);
      lics_inbound_utility.set_definition('DAD','COUNTRY2',3);
      lics_inbound_utility.set_definition('DAD','REGION',3);
      lics_inbound_utility.set_definition('DAD','COUNTY_COD',3);
      lics_inbound_utility.set_definition('DAD','COUNTY_TXT',25);
      lics_inbound_utility.set_definition('DAD','TZCODE',6);
      lics_inbound_utility.set_definition('DAD','TZDESC',35);
      /*-*/
      lics_inbound_utility.set_definition('DAS','IDOC_DAS',3);
      lics_inbound_utility.set_definition('DAS','EXTEND_Q',3);
      lics_inbound_utility.set_definition('DAS','EXTEND_D',70);
      /*-*/
      lics_inbound_utility.set_definition('DED','IDOC_DED',3);
      lics_inbound_utility.set_definition('DED','QUALF',3);
      lics_inbound_utility.set_definition('DED','VSTZW',4);
      lics_inbound_utility.set_definition('DED','VSTZW_BEZ',20);
      lics_inbound_utility.set_definition('DED','NTANF',8);
      lics_inbound_utility.set_definition('DED','NTANZ',6);
      lics_inbound_utility.set_definition('DED','NTEND',8);
      lics_inbound_utility.set_definition('DED','NTENZ',6);
      lics_inbound_utility.set_definition('DED','TZONE_BEG',6);
      lics_inbound_utility.set_definition('DED','ISDD',8);
      lics_inbound_utility.set_definition('DED','ISDZ',6);
      lics_inbound_utility.set_definition('DED','IEDD',8);
      lics_inbound_utility.set_definition('DED','IEDZ',6);
      lics_inbound_utility.set_definition('DED','TZONE_END',6);
      lics_inbound_utility.set_definition('DED','VORNR',4);
      lics_inbound_utility.set_definition('DED','VSTGA',4);
      lics_inbound_utility.set_definition('DED','VSTGA_BEZ',20);
      lics_inbound_utility.set_definition('DED','EVENT',10);
      lics_inbound_utility.set_definition('DED','EVENT_ALI',20);
      lics_inbound_utility.set_definition('DED','KNOTE',10);
      lics_inbound_utility.set_definition('DED','KNOTE_BEZ',30);
      /*-*/
      lics_inbound_utility.set_definition('DRS','IDOC_DRS',3);
      lics_inbound_utility.set_definition('DRS','ABNUM',4);
      lics_inbound_utility.set_definition('DRS','ANFRF',3);
      lics_inbound_utility.set_definition('DRS','VSART',2);
      lics_inbound_utility.set_definition('DRS','DISTZ',16);
      lics_inbound_utility.set_definition('DRS','MEDST',3);
      lics_inbound_utility.set_definition('DRS','TSTYP',1);
      lics_inbound_utility.set_definition('DRS','VSART_BEZ',20);
      /*-*/
      lics_inbound_utility.set_definition('DIT','IDOC_DIT',4);
      lics_inbound_utility.set_definition('DIT','POSNR',6);
      lics_inbound_utility.set_definition('DIT','MATNR',18);
      lics_inbound_utility.set_definition('DIT','MATWA',18);
      lics_inbound_utility.set_definition('DIT','ORKTX',40);
      lics_inbound_utility.set_definition('DIT','MATKL',9);
      lics_inbound_utility.set_definition('DIT','WERKS',4);
      lics_inbound_utility.set_definition('DIT','LGORT',4);
      lics_inbound_utility.set_definition('DIT','CHARG',10);
      lics_inbound_utility.set_definition('DIT','LGORT_BEZ',16);
      lics_inbound_utility.set_definition('DIT','LADGR_BEZ',20);
      lics_inbound_utility.set_definition('DIT','TRAGR_BEZ',20);
      lics_inbound_utility.set_definition('DIT','VKBUR_BEZ',20);
      lics_inbound_utility.set_definition('DIT','VKGRP_BEZ',20);
      lics_inbound_utility.set_definition('DIT','VTWEG_BEZ',20);
      lics_inbound_utility.set_definition('DIT','SPART_BEZ',20);
      lics_inbound_utility.set_definition('DIT','MFRGR_BEZ',20);
      lics_inbound_utility.set_definition('DIT','PSTYV',4);
      lics_inbound_utility.set_definition('DIT','MATKL_DUP',9);
      lics_inbound_utility.set_definition('DIT','PRODH',18);
      lics_inbound_utility.set_definition('DIT','UMVKZ',6);
      lics_inbound_utility.set_definition('DIT','UMVKN',6);
      lics_inbound_utility.set_definition('DIT','KZTLF',1);
      lics_inbound_utility.set_definition('DIT','UEBTK',1);
      lics_inbound_utility.set_definition('DIT','UEBTO',6);
      lics_inbound_utility.set_definition('DIT','UNTTO',6);
      lics_inbound_utility.set_definition('DIT','CHSPL',1);
      lics_inbound_utility.set_definition('DIT','XCHBW',1);
      lics_inbound_utility.set_definition('DIT','POSAR',1);
      lics_inbound_utility.set_definition('DIT','SOBKZ',1);
      lics_inbound_utility.set_definition('DIT','PCKPF',1);
      lics_inbound_utility.set_definition('DIT','MAGRV',4);
      lics_inbound_utility.set_definition('DIT','SHKZG',1);
      lics_inbound_utility.set_definition('DIT','KOQUI',1);
      lics_inbound_utility.set_definition('DIT','AKTNR',10);
      lics_inbound_utility.set_definition('DIT','KZUMW',1);
      lics_inbound_utility.set_definition('DIT','PSTYV_BEZ',20);
      lics_inbound_utility.set_definition('DIT','MATKL_BEZ',20);
      lics_inbound_utility.set_definition('DIT','PRODH_BEZ',20);
      lics_inbound_utility.set_definition('DIT','WERKS_BEZ',30);
      lics_inbound_utility.set_definition('DIT','STAWN',17);
      lics_inbound_utility.set_definition('DIT','EXPRF',5);
      lics_inbound_utility.set_definition('DIT','EXART',2);
      lics_inbound_utility.set_definition('DIT','HERKL',3);
      lics_inbound_utility.set_definition('DIT','HERKR',3);
      lics_inbound_utility.set_definition('DIT','GRWRT',16);
      lics_inbound_utility.set_definition('DIT','PREFE',1);
      lics_inbound_utility.set_definition('DIT','STXT1',40);
      lics_inbound_utility.set_definition('DIT','STXT2',40);
      lics_inbound_utility.set_definition('DIT','STXT3',40);
      lics_inbound_utility.set_definition('DIT','STXT4',40);
      lics_inbound_utility.set_definition('DIT','STXT5',40);
      lics_inbound_utility.set_definition('DIT','STXT6',40);
      lics_inbound_utility.set_definition('DIT','STXT7',40);
      lics_inbound_utility.set_definition('DIT','EXPRF_BEZ',30);
      lics_inbound_utility.set_definition('DIT','EXART_BEZ',30);
      lics_inbound_utility.set_definition('DIT','HERKL_BEZ',15);
      lics_inbound_utility.set_definition('DIT','HERKR_BEZ',20);
      /*-*/
      lics_inbound_utility.set_definition('DIB','IDOC_DIB',3);
      lics_inbound_utility.set_definition('DIB','ZZMEINS01',3);
      lics_inbound_utility.set_definition('DIB','ZZPALBAS01_F',16);
      lics_inbound_utility.set_definition('DIB','VBELV',10);
      lics_inbound_utility.set_definition('DIB','POSNV',6);
      lics_inbound_utility.set_definition('DIB','ZZHALFPAL',1);
      lics_inbound_utility.set_definition('DIB','ZZSTACKABLE',1);
      lics_inbound_utility.set_definition('DIB','ZZNBRHOMPAL',12);
      lics_inbound_utility.set_definition('DIB','ZZPALBASE_DELIV',18);
      lics_inbound_utility.set_definition('DIB','ZZPALSPACE_DELIV',18);
      lics_inbound_utility.set_definition('DIB','ZZMEINS_DELIV',3);
      lics_inbound_utility.set_definition('DIB','VALUE1',18);
      lics_inbound_utility.set_definition('DIB','ZRSP',18);
      lics_inbound_utility.set_definition('DIB','RATE',18);
      lics_inbound_utility.set_definition('DIB','KOSTL',10);
      lics_inbound_utility.set_definition('DIB','VFDAT',8);
      lics_inbound_utility.set_definition('DIB','VALUE',18);
      lics_inbound_utility.set_definition('DIB','ZZBB4',8);
      lics_inbound_utility.set_definition('DIB','ZZPI_ID',20);
      lics_inbound_utility.set_definition('DIB','INSMK',1);
      lics_inbound_utility.set_definition('DIB','SPART',2);
      lics_inbound_utility.set_definition('DIB','KWMENG',18);
      /*-*/
      lics_inbound_utility.set_definition('DNG','IDOC_DNG',3);
      lics_inbound_utility.set_definition('DNG','MOT',2);
      lics_inbound_utility.set_definition('DNG','VALDAT',8);
      lics_inbound_utility.set_definition('DNG','DGCAO',1);
      lics_inbound_utility.set_definition('DNG','DGNHM',1);
      lics_inbound_utility.set_definition('DNG','TKUI',3);
      lics_inbound_utility.set_definition('DNG','DGNU',4);
      /*-*/
      lics_inbound_utility.set_definition('DBT','IDOC_DBT',3);
      lics_inbound_utility.set_definition('DBT','ATINN',10);
      lics_inbound_utility.set_definition('DBT','ATNAM',30);
      lics_inbound_utility.set_definition('DBT','ATBEZ',30);
      lics_inbound_utility.set_definition('DBT','ATWRT',30);
      lics_inbound_utility.set_definition('DBT','ATWTB',30);
      lics_inbound_utility.set_definition('DBT','EWAHR',25);
      /*-*/
      lics_inbound_utility.set_definition('DRF','IDOC_DRF',3);
      lics_inbound_utility.set_definition('DRF','QUALF',1);
      lics_inbound_utility.set_definition('DRF','BELNR',35);
      lics_inbound_utility.set_definition('DRF','ITMNR',6);
      lics_inbound_utility.set_definition('DRF','DATUM',8);
      /*-*/
      lics_inbound_utility.set_definition('DHU','IDOC_DHU',4);
      lics_inbound_utility.set_definition('DHU','EXIDV',20);
      lics_inbound_utility.set_definition('DHU','BRGEW',18);
      lics_inbound_utility.set_definition('DHU','GWEIM',3);
      lics_inbound_utility.set_definition('DHU','BTVOL',18);
      lics_inbound_utility.set_definition('DHU','VOLEM',3);
      lics_inbound_utility.set_definition('DHU','LAENG',16);
      lics_inbound_utility.set_definition('DHU','BREIT',16);
      lics_inbound_utility.set_definition('DHU','HOEHE',16);
      lics_inbound_utility.set_definition('DHU','MEABM',3);
      lics_inbound_utility.set_definition('DHU','INHALT',40);
      lics_inbound_utility.set_definition('DHU','FARZT',4);
      lics_inbound_utility.set_definition('DHU','FAREH',3);
      lics_inbound_utility.set_definition('DHU','ENTFE',8);
      lics_inbound_utility.set_definition('DHU','EHENT',3);
      lics_inbound_utility.set_definition('DHU','EXIDV2',20);
      lics_inbound_utility.set_definition('DHU','LANDT',3);
      lics_inbound_utility.set_definition('DHU','MOVE_STATUS',4);
      lics_inbound_utility.set_definition('DHU','PACKVORSCHR',22);
      /*-*/
      lics_inbound_utility.set_definition('DHI','IDOC_DHI',3);
      lics_inbound_utility.set_definition('DHI','VELIN',1);
      lics_inbound_utility.set_definition('DHI','VBELN',10);
      lics_inbound_utility.set_definition('DHI','POSNR',6);
      lics_inbound_utility.set_definition('DHI','EXIDV',20);

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
         when 'HCT' then process_record_hct(par_record);
         when 'HAR' then process_record_har(par_record);
         when 'HAD' then process_record_had(par_record);
         when 'HDA' then process_record_hda(par_record);
         when 'HTX' then process_record_htx(par_record);
         when 'HTG' then process_record_htg(par_record);
         when 'HST' then process_record_hst(par_record);
         when 'HSP' then process_record_hsp(par_record);
         when 'HSD' then process_record_hsd(par_record);
         when 'HSI' then process_record_hsi(par_record);
         when 'DLV' then process_record_dlv(par_record);
         when 'DAD' then process_record_dad(par_record);
         when 'DAS' then process_record_das(par_record);
         when 'DED' then process_record_ded(par_record);
         when 'DRS' then process_record_drs(par_record);
         when 'DIT' then process_record_dit(par_record);
         when 'DIB' then process_record_dib(par_record);
         when 'DNG' then process_record_dng(par_record);
         when 'DBT' then process_record_dbt(par_record);
         when 'DRF' then process_record_drf(par_record);
         when 'DHU' then process_record_dhu(par_record);
         when 'DHI' then process_record_dhi(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD14';
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
            lads_atllad14_monitor.execute(rcd_lads_shp_hdr.tknum);
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
      cursor csr_lads_shp_hdr_01 is
         select
            t01.tknum,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_shp_hdr t01
         where t01.tknum = rcd_lads_shp_hdr.tknum;
      rcd_lads_shp_hdr_01 csr_lads_shp_hdr_01%rowtype;

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
      rcd_lads_shp_hdr.tknum := lics_inbound_utility.get_variable('TKNUM');
      rcd_lads_shp_hdr.shtyp := lics_inbound_utility.get_variable('SHTYP');
      rcd_lads_shp_hdr.abfer := lics_inbound_utility.get_variable('ABFER');
      rcd_lads_shp_hdr.abwst := lics_inbound_utility.get_variable('ABWST');
      rcd_lads_shp_hdr.bfart := lics_inbound_utility.get_variable('BFART');
      rcd_lads_shp_hdr.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_shp_hdr.laufk := lics_inbound_utility.get_variable('LAUFK');
      rcd_lads_shp_hdr.vsbed := lics_inbound_utility.get_variable('VSBED');
      rcd_lads_shp_hdr.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_shp_hdr.signi := lics_inbound_utility.get_variable('SIGNI');
      rcd_lads_shp_hdr.exti1 := lics_inbound_utility.get_variable('EXTI1');
      rcd_lads_shp_hdr.exti2 := lics_inbound_utility.get_variable('EXTI2');
      rcd_lads_shp_hdr.tpbez := lics_inbound_utility.get_variable('TPBEZ');
      rcd_lads_shp_hdr.sttrg := lics_inbound_utility.get_variable('STTRG');
      rcd_lads_shp_hdr.pkstk := lics_inbound_utility.get_variable('PKSTK');
      rcd_lads_shp_hdr.dtmeg := lics_inbound_utility.get_variable('DTMEG');
      rcd_lads_shp_hdr.dtmev := lics_inbound_utility.get_variable('DTMEV');
      rcd_lads_shp_hdr.distz := lics_inbound_utility.get_number('DISTZ',null);
      rcd_lads_shp_hdr.medst := lics_inbound_utility.get_variable('MEDST');
      rcd_lads_shp_hdr.fahzt := lics_inbound_utility.get_number('FAHZT',null);
      rcd_lads_shp_hdr.geszt := lics_inbound_utility.get_number('GESZT',null);
      rcd_lads_shp_hdr.meizt := lics_inbound_utility.get_variable('MEIZT');
      rcd_lads_shp_hdr.fbsta := lics_inbound_utility.get_variable('FBSTA');
      rcd_lads_shp_hdr.fbgst := lics_inbound_utility.get_variable('FBGST');
      rcd_lads_shp_hdr.arsta := lics_inbound_utility.get_variable('ARSTA');
      rcd_lads_shp_hdr.argst := lics_inbound_utility.get_variable('ARGST');
      rcd_lads_shp_hdr.sterm_done := lics_inbound_utility.get_variable('STERM_DONE');
      rcd_lads_shp_hdr.vse_frk := lics_inbound_utility.get_variable('VSE_FRK');
      rcd_lads_shp_hdr.kkalsm := lics_inbound_utility.get_variable('KKALSM');
      rcd_lads_shp_hdr.sdabw := lics_inbound_utility.get_variable('SDABW');
      rcd_lads_shp_hdr.frkrl := lics_inbound_utility.get_variable('FRKRL');
      rcd_lads_shp_hdr.gesztd := lics_inbound_utility.get_number('GESZTD',null);
      rcd_lads_shp_hdr.fahztd := lics_inbound_utility.get_number('FAHZTD',null);
      rcd_lads_shp_hdr.gesztda := lics_inbound_utility.get_number('GESZTDA',null);
      rcd_lads_shp_hdr.fahztda := lics_inbound_utility.get_number('FAHZTDA',null);
      rcd_lads_shp_hdr.warztd := lics_inbound_utility.get_number('WARZTD',null);
      rcd_lads_shp_hdr.warztda := lics_inbound_utility.get_number('WARZTDA',null);
      rcd_lads_shp_hdr.shtyp_bez := lics_inbound_utility.get_variable('SHTYP_BEZ');
      rcd_lads_shp_hdr.bfart_bez := lics_inbound_utility.get_variable('BFART_BEZ');
      rcd_lads_shp_hdr.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_shp_hdr.laufk_bez := lics_inbound_utility.get_variable('LAUFK_BEZ');
      rcd_lads_shp_hdr.vsbed_bez := lics_inbound_utility.get_variable('VSBED_BEZ');
      rcd_lads_shp_hdr.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_shp_hdr.sttrg_bez := lics_inbound_utility.get_variable('STTRG_BEZ');
      rcd_lads_shp_hdr.fbsta_bez := lics_inbound_utility.get_variable('FBSTA_BEZ');
      rcd_lads_shp_hdr.fbgst_bez := lics_inbound_utility.get_variable('FBGST_BEZ');
      rcd_lads_shp_hdr.arsta_bez := lics_inbound_utility.get_variable('ARSTA_BEZ');
      rcd_lads_shp_hdr.argst_bez := lics_inbound_utility.get_variable('ARGST_BEZ');
      rcd_lads_shp_hdr.tndrst := lics_inbound_utility.get_variable('TNDRST');
      rcd_lads_shp_hdr.tndrrc := lics_inbound_utility.get_variable('TNDRRC');
      rcd_lads_shp_hdr.tndr_text := lics_inbound_utility.get_variable('TNDR_TEXT');
      rcd_lads_shp_hdr.tndrdat := lics_inbound_utility.get_variable('TNDRDAT');
      rcd_lads_shp_hdr.tndrzet := lics_inbound_utility.get_variable('TNDRZET');
      rcd_lads_shp_hdr.tndr_maxp := lics_inbound_utility.get_number('TNDR_MAXP',null);
      rcd_lads_shp_hdr.tndr_maxc := lics_inbound_utility.get_variable('TNDR_MAXC');
      rcd_lads_shp_hdr.tndr_actp := lics_inbound_utility.get_number('TNDR_ACTP',null);
      rcd_lads_shp_hdr.tndr_actc := lics_inbound_utility.get_variable('TNDR_ACTC');
      rcd_lads_shp_hdr.tndr_carr := lics_inbound_utility.get_variable('TNDR_CARR');
      rcd_lads_shp_hdr.tndr_crnm := lics_inbound_utility.get_variable('TNDR_CRNM');
      rcd_lads_shp_hdr.tndr_trkid := lics_inbound_utility.get_variable('TNDR_TRKID');
      rcd_lads_shp_hdr.tndr_expd := lics_inbound_utility.get_variable('TNDR_EXPD');
      rcd_lads_shp_hdr.tndr_expt := lics_inbound_utility.get_variable('TNDR_EXPT');
      rcd_lads_shp_hdr.tndr_erpd := lics_inbound_utility.get_variable('TNDR_ERPD');
      rcd_lads_shp_hdr.tndr_erpt := lics_inbound_utility.get_variable('TNDR_ERPT');
      rcd_lads_shp_hdr.tndr_ltpd := lics_inbound_utility.get_variable('TNDR_LTPD');
      rcd_lads_shp_hdr.tndr_ltpt := lics_inbound_utility.get_variable('TNDR_LTPT');
      rcd_lads_shp_hdr.tndr_erdd := lics_inbound_utility.get_variable('TNDR_ERDD');
      rcd_lads_shp_hdr.tndr_erdt := lics_inbound_utility.get_variable('TNDR_ERDT');
      rcd_lads_shp_hdr.tndr_ltdd := lics_inbound_utility.get_variable('TNDR_LTDD');
      rcd_lads_shp_hdr.tndr_ltdt := lics_inbound_utility.get_variable('TNDR_LTDT');
      rcd_lads_shp_hdr.tndr_ldlg := lics_inbound_utility.get_number('TNDR_LDLG',null);
      rcd_lads_shp_hdr.tndr_ldlu := lics_inbound_utility.get_variable('TNDR_LDLU');
      rcd_lads_shp_hdr.tndrst_bez := lics_inbound_utility.get_variable('TNDRST_BEZ');
      rcd_lads_shp_hdr.tndrrc_bez := lics_inbound_utility.get_variable('TNDRRC_BEZ');
      rcd_lads_shp_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_shp_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_shp_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_shp_hdr.lads_date := sysdate;
      rcd_lads_shp_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_hct.hctseq := 0;
      rcd_lads_shp_har.harseq := 0;
      rcd_lads_shp_hda.hdaseq := 0;
      rcd_lads_shp_htx.htxseq := 0;
      rcd_lads_shp_hst.hstseq := 0;
      rcd_lads_shp_dlv.dlvseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_hdr.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.TKNUM');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_shp_hdr.tknum is null) then
         var_exists := true;
         open csr_lads_shp_hdr_01;
         fetch csr_lads_shp_hdr_01 into rcd_lads_shp_hdr_01;
         if csr_lads_shp_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_shp_hdr_01;
         if var_exists = true then
            if rcd_lads_shp_hdr.idoc_timestamp > rcd_lads_shp_hdr_01.idoc_timestamp then
               delete from lads_shp_dhi where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_dhu where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_drf where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_dbt where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_dng where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_dib where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_dit where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_drs where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_ded where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_das where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_dad where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_dlv where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_hsi where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_hsd where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_hsp where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_hst where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_htg where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_htx where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_hda where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_had where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_har where tknum = rcd_lads_shp_hdr.tknum;
               delete from lads_shp_hct where tknum = rcd_lads_shp_hdr.tknum;
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

      update lads_shp_hdr set
         shtyp = rcd_lads_shp_hdr.shtyp,
         abfer = rcd_lads_shp_hdr.abfer,
         abwst = rcd_lads_shp_hdr.abwst,
         bfart = rcd_lads_shp_hdr.bfart,
         vsart = rcd_lads_shp_hdr.vsart,
         laufk = rcd_lads_shp_hdr.laufk,
         vsbed = rcd_lads_shp_hdr.vsbed,
         route = rcd_lads_shp_hdr.route,
         signi = rcd_lads_shp_hdr.signi,
         exti1 = rcd_lads_shp_hdr.exti1,
         exti2 = rcd_lads_shp_hdr.exti2,
         tpbez = rcd_lads_shp_hdr.tpbez,
         sttrg = rcd_lads_shp_hdr.sttrg,
         pkstk = rcd_lads_shp_hdr.pkstk,
         dtmeg = rcd_lads_shp_hdr.dtmeg,
         dtmev = rcd_lads_shp_hdr.dtmev,
         distz = rcd_lads_shp_hdr.distz,
         medst = rcd_lads_shp_hdr.medst,
         fahzt = rcd_lads_shp_hdr.fahzt,
         geszt = rcd_lads_shp_hdr.geszt,
         meizt = rcd_lads_shp_hdr.meizt,
         fbsta = rcd_lads_shp_hdr.fbsta,
         fbgst = rcd_lads_shp_hdr.fbgst,
         arsta = rcd_lads_shp_hdr.arsta,
         argst = rcd_lads_shp_hdr.argst,
         sterm_done = rcd_lads_shp_hdr.sterm_done,
         vse_frk = rcd_lads_shp_hdr.vse_frk,
         kkalsm = rcd_lads_shp_hdr.kkalsm,
         sdabw = rcd_lads_shp_hdr.sdabw,
         frkrl = rcd_lads_shp_hdr.frkrl,
         gesztd = rcd_lads_shp_hdr.gesztd,
         fahztd = rcd_lads_shp_hdr.fahztd,
         gesztda = rcd_lads_shp_hdr.gesztda,
         fahztda = rcd_lads_shp_hdr.fahztda,
         warztd = rcd_lads_shp_hdr.warztd,
         warztda = rcd_lads_shp_hdr.warztda,
         shtyp_bez = rcd_lads_shp_hdr.shtyp_bez,
         bfart_bez = rcd_lads_shp_hdr.bfart_bez,
         vsart_bez = rcd_lads_shp_hdr.vsart_bez,
         laufk_bez = rcd_lads_shp_hdr.laufk_bez,
         vsbed_bez = rcd_lads_shp_hdr.vsbed_bez,
         route_bez = rcd_lads_shp_hdr.route_bez,
         sttrg_bez = rcd_lads_shp_hdr.sttrg_bez,
         fbsta_bez = rcd_lads_shp_hdr.fbsta_bez,
         fbgst_bez = rcd_lads_shp_hdr.fbgst_bez,
         arsta_bez = rcd_lads_shp_hdr.arsta_bez,
         argst_bez = rcd_lads_shp_hdr.argst_bez,
         tndrst = rcd_lads_shp_hdr.tndrst,
         tndrrc = rcd_lads_shp_hdr.tndrrc,
         tndr_text = rcd_lads_shp_hdr.tndr_text,
         tndrdat = rcd_lads_shp_hdr.tndrdat,
         tndrzet = rcd_lads_shp_hdr.tndrzet,
         tndr_maxp = rcd_lads_shp_hdr.tndr_maxp,
         tndr_maxc = rcd_lads_shp_hdr.tndr_maxc,
         tndr_actp = rcd_lads_shp_hdr.tndr_actp,
         tndr_actc = rcd_lads_shp_hdr.tndr_actc,
         tndr_carr = rcd_lads_shp_hdr.tndr_carr,
         tndr_crnm = rcd_lads_shp_hdr.tndr_crnm,
         tndr_trkid = rcd_lads_shp_hdr.tndr_trkid,
         tndr_expd = rcd_lads_shp_hdr.tndr_expd,
         tndr_expt = rcd_lads_shp_hdr.tndr_expt,
         tndr_erpd = rcd_lads_shp_hdr.tndr_erpd,
         tndr_erpt = rcd_lads_shp_hdr.tndr_erpt,
         tndr_ltpd = rcd_lads_shp_hdr.tndr_ltpd,
         tndr_ltpt = rcd_lads_shp_hdr.tndr_ltpt,
         tndr_erdd = rcd_lads_shp_hdr.tndr_erdd,
         tndr_erdt = rcd_lads_shp_hdr.tndr_erdt,
         tndr_ltdd = rcd_lads_shp_hdr.tndr_ltdd,
         tndr_ltdt = rcd_lads_shp_hdr.tndr_ltdt,
         tndr_ldlg = rcd_lads_shp_hdr.tndr_ldlg,
         tndr_ldlu = rcd_lads_shp_hdr.tndr_ldlu,
         tndrst_bez = rcd_lads_shp_hdr.tndrst_bez,
         tndrrc_bez = rcd_lads_shp_hdr.tndrrc_bez,
         idoc_name = rcd_lads_shp_hdr.idoc_name,
         idoc_number = rcd_lads_shp_hdr.idoc_number,
         idoc_timestamp = rcd_lads_shp_hdr.idoc_timestamp,
         lads_date = rcd_lads_shp_hdr.lads_date,
         lads_status = rcd_lads_shp_hdr.lads_status
      where tknum = rcd_lads_shp_hdr.tknum;
      if sql%notfound then
         insert into lads_shp_hdr
            (tknum,
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
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_shp_hdr.tknum,
             rcd_lads_shp_hdr.shtyp,
             rcd_lads_shp_hdr.abfer,
             rcd_lads_shp_hdr.abwst,
             rcd_lads_shp_hdr.bfart,
             rcd_lads_shp_hdr.vsart,
             rcd_lads_shp_hdr.laufk,
             rcd_lads_shp_hdr.vsbed,
             rcd_lads_shp_hdr.route,
             rcd_lads_shp_hdr.signi,
             rcd_lads_shp_hdr.exti1,
             rcd_lads_shp_hdr.exti2,
             rcd_lads_shp_hdr.tpbez,
             rcd_lads_shp_hdr.sttrg,
             rcd_lads_shp_hdr.pkstk,
             rcd_lads_shp_hdr.dtmeg,
             rcd_lads_shp_hdr.dtmev,
             rcd_lads_shp_hdr.distz,
             rcd_lads_shp_hdr.medst,
             rcd_lads_shp_hdr.fahzt,
             rcd_lads_shp_hdr.geszt,
             rcd_lads_shp_hdr.meizt,
             rcd_lads_shp_hdr.fbsta,
             rcd_lads_shp_hdr.fbgst,
             rcd_lads_shp_hdr.arsta,
             rcd_lads_shp_hdr.argst,
             rcd_lads_shp_hdr.sterm_done,
             rcd_lads_shp_hdr.vse_frk,
             rcd_lads_shp_hdr.kkalsm,
             rcd_lads_shp_hdr.sdabw,
             rcd_lads_shp_hdr.frkrl,
             rcd_lads_shp_hdr.gesztd,
             rcd_lads_shp_hdr.fahztd,
             rcd_lads_shp_hdr.gesztda,
             rcd_lads_shp_hdr.fahztda,
             rcd_lads_shp_hdr.warztd,
             rcd_lads_shp_hdr.warztda,
             rcd_lads_shp_hdr.shtyp_bez,
             rcd_lads_shp_hdr.bfart_bez,
             rcd_lads_shp_hdr.vsart_bez,
             rcd_lads_shp_hdr.laufk_bez,
             rcd_lads_shp_hdr.vsbed_bez,
             rcd_lads_shp_hdr.route_bez,
             rcd_lads_shp_hdr.sttrg_bez,
             rcd_lads_shp_hdr.fbsta_bez,
             rcd_lads_shp_hdr.fbgst_bez,
             rcd_lads_shp_hdr.arsta_bez,
             rcd_lads_shp_hdr.argst_bez,
             rcd_lads_shp_hdr.tndrst,
             rcd_lads_shp_hdr.tndrrc,
             rcd_lads_shp_hdr.tndr_text,
             rcd_lads_shp_hdr.tndrdat,
             rcd_lads_shp_hdr.tndrzet,
             rcd_lads_shp_hdr.tndr_maxp,
             rcd_lads_shp_hdr.tndr_maxc,
             rcd_lads_shp_hdr.tndr_actp,
             rcd_lads_shp_hdr.tndr_actc,
             rcd_lads_shp_hdr.tndr_carr,
             rcd_lads_shp_hdr.tndr_crnm,
             rcd_lads_shp_hdr.tndr_trkid,
             rcd_lads_shp_hdr.tndr_expd,
             rcd_lads_shp_hdr.tndr_expt,
             rcd_lads_shp_hdr.tndr_erpd,
             rcd_lads_shp_hdr.tndr_erpt,
             rcd_lads_shp_hdr.tndr_ltpd,
             rcd_lads_shp_hdr.tndr_ltpt,
             rcd_lads_shp_hdr.tndr_erdd,
             rcd_lads_shp_hdr.tndr_erdt,
             rcd_lads_shp_hdr.tndr_ltdd,
             rcd_lads_shp_hdr.tndr_ltdt,
             rcd_lads_shp_hdr.tndr_ldlg,
             rcd_lads_shp_hdr.tndr_ldlu,
             rcd_lads_shp_hdr.tndrst_bez,
             rcd_lads_shp_hdr.tndrrc_bez,
             rcd_lads_shp_hdr.idoc_name,
             rcd_lads_shp_hdr.idoc_number,
             rcd_lads_shp_hdr.idoc_timestamp,
             rcd_lads_shp_hdr.lads_date,
             rcd_lads_shp_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record HCT routine */
   /**************************************************/
   procedure process_record_hct(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HCT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_hct.tknum := rcd_lads_shp_hdr.tknum;
      rcd_lads_shp_hct.hctseq := rcd_lads_shp_hct.hctseq + 1;
      rcd_lads_shp_hct.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_shp_hct.param := lics_inbound_utility.get_variable('PARAM');

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
      if rcd_lads_shp_hct.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HCT.TKNUM');
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

      insert into lads_shp_hct
         (tknum,
          hctseq,
          qualf,
          param)
      values
         (rcd_lads_shp_hct.tknum,
          rcd_lads_shp_hct.hctseq,
          rcd_lads_shp_hct.qualf,
          rcd_lads_shp_hct.param);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hct;

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
      rcd_lads_shp_har.tknum := rcd_lads_shp_hdr.tknum;
      rcd_lads_shp_har.harseq := rcd_lads_shp_har.harseq + 1;
      rcd_lads_shp_har.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_shp_har.address_t := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_lads_shp_har.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_shp_har.jurisdic := lics_inbound_utility.get_variable('JURISDIC');
      rcd_lads_shp_har.language := lics_inbound_utility.get_variable('LANGUAGE');
      rcd_lads_shp_har.formofaddr := lics_inbound_utility.get_variable('FORMOFADDR');
      rcd_lads_shp_har.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_shp_har.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_shp_har.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_shp_har.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_shp_har.name_text := lics_inbound_utility.get_variable('NAME_TEXT');
      rcd_lads_shp_har.name_co := lics_inbound_utility.get_variable('NAME_CO');
      rcd_lads_shp_har.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_shp_har.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_shp_har.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_shp_har.room := lics_inbound_utility.get_variable('ROOM');
      rcd_lads_shp_har.street1 := lics_inbound_utility.get_variable('STREET1');
      rcd_lads_shp_har.street2 := lics_inbound_utility.get_variable('STREET2');
      rcd_lads_shp_har.street3 := lics_inbound_utility.get_variable('STREET3');
      rcd_lads_shp_har.house_supl := lics_inbound_utility.get_variable('HOUSE_SUPL');
      rcd_lads_shp_har.house_rang := lics_inbound_utility.get_variable('HOUSE_RANG');
      rcd_lads_shp_har.postl_cod1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_lads_shp_har.postl_cod3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_lads_shp_har.postl_area := lics_inbound_utility.get_variable('POSTL_AREA');
      rcd_lads_shp_har.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_shp_har.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_shp_har.postl_pbox := lics_inbound_utility.get_variable('POSTL_PBOX');
      rcd_lads_shp_har.postl_cod2 := lics_inbound_utility.get_variable('POSTL_COD2');
      rcd_lads_shp_har.postl_city := lics_inbound_utility.get_variable('POSTL_CITY');
      rcd_lads_shp_har.telephone1 := lics_inbound_utility.get_variable('TELEPHONE1');
      rcd_lads_shp_har.telephone2 := lics_inbound_utility.get_variable('TELEPHONE2');
      rcd_lads_shp_har.telefax := lics_inbound_utility.get_variable('TELEFAX');
      rcd_lads_shp_har.telex := lics_inbound_utility.get_variable('TELEX');
      rcd_lads_shp_har.e_mail := lics_inbound_utility.get_variable('E_MAIL');
      rcd_lads_shp_har.country1 := lics_inbound_utility.get_variable('COUNTRY1');
      rcd_lads_shp_har.country2 := lics_inbound_utility.get_variable('COUNTRY2');
      rcd_lads_shp_har.region := lics_inbound_utility.get_variable('REGION');
      rcd_lads_shp_har.county_cod := lics_inbound_utility.get_variable('COUNTY_COD');
      rcd_lads_shp_har.county_txt := lics_inbound_utility.get_variable('COUNTY_TXT');
      rcd_lads_shp_har.tzcode := lics_inbound_utility.get_variable('TZCODE');
      rcd_lads_shp_har.tzdesc := lics_inbound_utility.get_variable('TZDESC');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_had.hadseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_har.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HAR.TKNUM');
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

      insert into lads_shp_har
         (tknum,
          harseq,
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
         (rcd_lads_shp_har.tknum,
          rcd_lads_shp_har.harseq,
          rcd_lads_shp_har.partner_q,
          rcd_lads_shp_har.address_t,
          rcd_lads_shp_har.partner_id,
          rcd_lads_shp_har.jurisdic,
          rcd_lads_shp_har.language,
          rcd_lads_shp_har.formofaddr,
          rcd_lads_shp_har.name1,
          rcd_lads_shp_har.name2,
          rcd_lads_shp_har.name3,
          rcd_lads_shp_har.name4,
          rcd_lads_shp_har.name_text,
          rcd_lads_shp_har.name_co,
          rcd_lads_shp_har.location,
          rcd_lads_shp_har.building,
          rcd_lads_shp_har.floor,
          rcd_lads_shp_har.room,
          rcd_lads_shp_har.street1,
          rcd_lads_shp_har.street2,
          rcd_lads_shp_har.street3,
          rcd_lads_shp_har.house_supl,
          rcd_lads_shp_har.house_rang,
          rcd_lads_shp_har.postl_cod1,
          rcd_lads_shp_har.postl_cod3,
          rcd_lads_shp_har.postl_area,
          rcd_lads_shp_har.city1,
          rcd_lads_shp_har.city2,
          rcd_lads_shp_har.postl_pbox,
          rcd_lads_shp_har.postl_cod2,
          rcd_lads_shp_har.postl_city,
          rcd_lads_shp_har.telephone1,
          rcd_lads_shp_har.telephone2,
          rcd_lads_shp_har.telefax,
          rcd_lads_shp_har.telex,
          rcd_lads_shp_har.e_mail,
          rcd_lads_shp_har.country1,
          rcd_lads_shp_har.country2,
          rcd_lads_shp_har.region,
          rcd_lads_shp_har.county_cod,
          rcd_lads_shp_har.county_txt,
          rcd_lads_shp_har.tzcode,
          rcd_lads_shp_har.tzdesc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_har;

   /**************************************************/
   /* This procedure performs the record HAD routine */
   /**************************************************/
   procedure process_record_had(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HAD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_had.tknum := rcd_lads_shp_har.tknum;
      rcd_lads_shp_had.harseq := rcd_lads_shp_har.harseq;
      rcd_lads_shp_had.hadseq := rcd_lads_shp_had.hadseq + 1;
      rcd_lads_shp_had.extend_q := lics_inbound_utility.get_variable('EXTEND_Q');
      rcd_lads_shp_had.extend_d := lics_inbound_utility.get_variable('EXTEND_D');

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
      if rcd_lads_shp_had.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HAD.TKNUM');
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

      insert into lads_shp_had
         (tknum,
          harseq,
          hadseq,
          extend_q,
          extend_d)
      values
         (rcd_lads_shp_had.tknum,
          rcd_lads_shp_had.harseq,
          rcd_lads_shp_had.hadseq,
          rcd_lads_shp_had.extend_q,
          rcd_lads_shp_had.extend_d);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_had;

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
      rcd_lads_shp_hda.tknum := rcd_lads_shp_hdr.tknum;
      rcd_lads_shp_hda.hdaseq := rcd_lads_shp_hda.hdaseq + 1;
      rcd_lads_shp_hda.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_shp_hda.vstzw := lics_inbound_utility.get_variable('VSTZW');
      rcd_lads_shp_hda.vstzw_bez := lics_inbound_utility.get_variable('VSTZW_BEZ');
      rcd_lads_shp_hda.ntanf := lics_inbound_utility.get_variable('NTANF');
      rcd_lads_shp_hda.ntanz := lics_inbound_utility.get_variable('NTANZ');
      rcd_lads_shp_hda.ntend := lics_inbound_utility.get_variable('NTEND');
      rcd_lads_shp_hda.ntenz := lics_inbound_utility.get_variable('NTENZ');
      rcd_lads_shp_hda.tzone_beg := lics_inbound_utility.get_variable('TZONE_BEG');
      rcd_lads_shp_hda.isdd := lics_inbound_utility.get_variable('ISDD');
      rcd_lads_shp_hda.isdz := lics_inbound_utility.get_variable('ISDZ');
      rcd_lads_shp_hda.iedd := lics_inbound_utility.get_variable('IEDD');
      rcd_lads_shp_hda.iedz := lics_inbound_utility.get_variable('IEDZ');
      rcd_lads_shp_hda.tzone_end := lics_inbound_utility.get_variable('TZONE_END');
      rcd_lads_shp_hda.vornr := lics_inbound_utility.get_variable('VORNR');
      rcd_lads_shp_hda.vstga := lics_inbound_utility.get_variable('VSTGA');
      rcd_lads_shp_hda.vstga_bez := lics_inbound_utility.get_variable('VSTGA_BEZ');
      rcd_lads_shp_hda.event := lics_inbound_utility.get_variable('EVENT');
      rcd_lads_shp_hda.event_ali := lics_inbound_utility.get_variable('EVENT_ALI');
      rcd_lads_shp_hda.knote := lics_inbound_utility.get_variable('KNOTE');
      rcd_lads_shp_hda.knote_bez := lics_inbound_utility.get_variable('KNOTE_BEZ');

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
      if rcd_lads_shp_hda.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDA.TKNUM');
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

      insert into lads_shp_hda
         (tknum,
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
          event_ali,
          knote,
          knote_bez)
      values
         (rcd_lads_shp_hda.tknum,
          rcd_lads_shp_hda.hdaseq,
          rcd_lads_shp_hda.qualf,
          rcd_lads_shp_hda.vstzw,
          rcd_lads_shp_hda.vstzw_bez,
          rcd_lads_shp_hda.ntanf,
          rcd_lads_shp_hda.ntanz,
          rcd_lads_shp_hda.ntend,
          rcd_lads_shp_hda.ntenz,
          rcd_lads_shp_hda.tzone_beg,
          rcd_lads_shp_hda.isdd,
          rcd_lads_shp_hda.isdz,
          rcd_lads_shp_hda.iedd,
          rcd_lads_shp_hda.iedz,
          rcd_lads_shp_hda.tzone_end,
          rcd_lads_shp_hda.vornr,
          rcd_lads_shp_hda.vstga,
          rcd_lads_shp_hda.vstga_bez,
          rcd_lads_shp_hda.event,
          rcd_lads_shp_hda.event_ali,
          rcd_lads_shp_hda.knote,
          rcd_lads_shp_hda.knote_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hda;

   /**************************************************/
   /* This procedure performs the record HTX routine */
   /**************************************************/
   procedure process_record_htx(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HTX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_htx.tknum := rcd_lads_shp_hdr.tknum;
      rcd_lads_shp_htx.htxseq := rcd_lads_shp_htx.htxseq + 1;
      rcd_lads_shp_htx.function := lics_inbound_utility.get_variable('FUNCTION');
      rcd_lads_shp_htx.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_shp_htx.tdobname := lics_inbound_utility.get_variable('TDOBNAME');
      rcd_lads_shp_htx.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_shp_htx.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_shp_htx.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_shp_htx.langua_iso := lics_inbound_utility.get_variable('LANGUA_ISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_htg.htgseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_htx.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HTX.TKNUM');
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

      insert into lads_shp_htx
         (tknum,
          htxseq,
          function,
          tdobject,
          tdobname,
          tdid,
          tdspras,
          tdtexttype,
          langua_iso)
      values
         (rcd_lads_shp_htx.tknum,
          rcd_lads_shp_htx.htxseq,
          rcd_lads_shp_htx.function,
          rcd_lads_shp_htx.tdobject,
          rcd_lads_shp_htx.tdobname,
          rcd_lads_shp_htx.tdid,
          rcd_lads_shp_htx.tdspras,
          rcd_lads_shp_htx.tdtexttype,
          rcd_lads_shp_htx.langua_iso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_htx;

   /**************************************************/
   /* This procedure performs the record HTG routine */
   /**************************************************/
   procedure process_record_htg(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HTG', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_htg.tknum := rcd_lads_shp_htx.tknum;
      rcd_lads_shp_htg.htxseq := rcd_lads_shp_htx.htxseq;
      rcd_lads_shp_htg.htgseq := rcd_lads_shp_htg.htgseq + 1;
      rcd_lads_shp_htg.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_shp_htg.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_shp_htg.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HTG.TKNUM');
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

      insert into lads_shp_htg
         (tknum,
          htxseq,
          htgseq,
          tdformat,
          tdline)
      values
         (rcd_lads_shp_htg.tknum,
          rcd_lads_shp_htg.htxseq,
          rcd_lads_shp_htg.htgseq,
          rcd_lads_shp_htg.tdformat,
          rcd_lads_shp_htg.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_htg;

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
      rcd_lads_shp_hst.tknum := rcd_lads_shp_hdr.tknum;
      rcd_lads_shp_hst.hstseq := rcd_lads_shp_hst.hstseq + 1;
      rcd_lads_shp_hst.tsnum := lics_inbound_utility.get_number('TSNUM',null);
      rcd_lads_shp_hst.tsrfo := lics_inbound_utility.get_number('TSRFO',null);
      rcd_lads_shp_hst.tstyp := lics_inbound_utility.get_variable('TSTYP');
      rcd_lads_shp_hst.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_shp_hst.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_lads_shp_hst.laufk := lics_inbound_utility.get_variable('LAUFK');
      rcd_lads_shp_hst.distz := lics_inbound_utility.get_number('DISTZ',null);
      rcd_lads_shp_hst.medst := lics_inbound_utility.get_variable('MEDST');
      rcd_lads_shp_hst.fahzt := lics_inbound_utility.get_number('FAHZT',null);
      rcd_lads_shp_hst.geszt := lics_inbound_utility.get_number('GESZT',null);
      rcd_lads_shp_hst.meizt := lics_inbound_utility.get_variable('MEIZT');
      rcd_lads_shp_hst.gesztd := lics_inbound_utility.get_number('GESZTD',null);
      rcd_lads_shp_hst.fahztd := lics_inbound_utility.get_number('FAHZTD',null);
      rcd_lads_shp_hst.gesztda := lics_inbound_utility.get_number('GESZTDA',null);
      rcd_lads_shp_hst.fahztda := lics_inbound_utility.get_number('FAHZTDA',null);
      rcd_lads_shp_hst.sdabw := lics_inbound_utility.get_variable('SDABW');
      rcd_lads_shp_hst.frkrl := lics_inbound_utility.get_variable('FRKRL');
      rcd_lads_shp_hst.skalsm := lics_inbound_utility.get_variable('SKALSM');
      rcd_lads_shp_hst.fbsta := lics_inbound_utility.get_variable('FBSTA');
      rcd_lads_shp_hst.arsta := lics_inbound_utility.get_variable('ARSTA');
      rcd_lads_shp_hst.warztd := lics_inbound_utility.get_number('WARZTD',null);
      rcd_lads_shp_hst.warztda := lics_inbound_utility.get_number('WARZTDA',null);
      rcd_lads_shp_hst.cont_dg := lics_inbound_utility.get_variable('CONT_DG');
      rcd_lads_shp_hst.tstyp_bez := lics_inbound_utility.get_variable('TSTYP_BEZ');
      rcd_lads_shp_hst.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_shp_hst.inco1_bez := lics_inbound_utility.get_variable('INCO1_BEZ');
      rcd_lads_shp_hst.laufk_bez := lics_inbound_utility.get_variable('LAUFK_BEZ');
      rcd_lads_shp_hst.fbsta_bez := lics_inbound_utility.get_variable('FBSTA_BEZ');
      rcd_lads_shp_hst.arsta_bez := lics_inbound_utility.get_variable('ARSTA_BEZ');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_hsp.hspseq := 0;
      rcd_lads_shp_hsd.hsdseq := 0;
      rcd_lads_shp_hsi.hsiseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_hst.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HST.TKNUM');
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

      insert into lads_shp_hst
         (tknum,
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
         (rcd_lads_shp_hst.tknum,
          rcd_lads_shp_hst.hstseq,
          rcd_lads_shp_hst.tsnum,
          rcd_lads_shp_hst.tsrfo,
          rcd_lads_shp_hst.tstyp,
          rcd_lads_shp_hst.vsart,
          rcd_lads_shp_hst.inco1,
          rcd_lads_shp_hst.laufk,
          rcd_lads_shp_hst.distz,
          rcd_lads_shp_hst.medst,
          rcd_lads_shp_hst.fahzt,
          rcd_lads_shp_hst.geszt,
          rcd_lads_shp_hst.meizt,
          rcd_lads_shp_hst.gesztd,
          rcd_lads_shp_hst.fahztd,
          rcd_lads_shp_hst.gesztda,
          rcd_lads_shp_hst.fahztda,
          rcd_lads_shp_hst.sdabw,
          rcd_lads_shp_hst.frkrl,
          rcd_lads_shp_hst.skalsm,
          rcd_lads_shp_hst.fbsta,
          rcd_lads_shp_hst.arsta,
          rcd_lads_shp_hst.warztd,
          rcd_lads_shp_hst.warztda,
          rcd_lads_shp_hst.cont_dg,
          rcd_lads_shp_hst.tstyp_bez,
          rcd_lads_shp_hst.vsart_bez,
          rcd_lads_shp_hst.inco1_bez,
          rcd_lads_shp_hst.laufk_bez,
          rcd_lads_shp_hst.fbsta_bez,
          rcd_lads_shp_hst.arsta_bez);

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
      rcd_lads_shp_hsp.tknum := rcd_lads_shp_hst.tknum;
      rcd_lads_shp_hsp.hstseq := rcd_lads_shp_hst.hstseq;
      rcd_lads_shp_hsp.hspseq := rcd_lads_shp_hsp.hspseq + 1;
      rcd_lads_shp_hsp.quali := lics_inbound_utility.get_variable('QUALI');
      rcd_lads_shp_hsp.knote := lics_inbound_utility.get_variable('KNOTE');
      rcd_lads_shp_hsp.adrnr := lics_inbound_utility.get_variable('ADRNR');
      rcd_lads_shp_hsp.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_shp_hsp.lstel := lics_inbound_utility.get_variable('LSTEL');
      rcd_lads_shp_hsp.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_shp_hsp.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_shp_hsp.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_shp_hsp.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_shp_hsp.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_shp_hsp.lgnum := lics_inbound_utility.get_variable('LGNUM');
      rcd_lads_shp_hsp.lgtor := lics_inbound_utility.get_variable('LGTOR');
      rcd_lads_shp_hsp.bahnra := lics_inbound_utility.get_variable('BAHNRA');
      rcd_lads_shp_hsp.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_shp_hsp.address_t := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_lads_shp_hsp.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_shp_hsp.jurisdic := lics_inbound_utility.get_variable('JURISDIC');
      rcd_lads_shp_hsp.language := lics_inbound_utility.get_variable('LANGUAGE');
      rcd_lads_shp_hsp.formofaddr := lics_inbound_utility.get_variable('FORMOFADDR');
      rcd_lads_shp_hsp.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_shp_hsp.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_shp_hsp.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_shp_hsp.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_shp_hsp.name_text := lics_inbound_utility.get_variable('NAME_TEXT');
      rcd_lads_shp_hsp.name_co := lics_inbound_utility.get_variable('NAME_CO');
      rcd_lads_shp_hsp.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_shp_hsp.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_shp_hsp.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_shp_hsp.room := lics_inbound_utility.get_variable('ROOM');
      rcd_lads_shp_hsp.street1 := lics_inbound_utility.get_variable('STREET1');
      rcd_lads_shp_hsp.street2 := lics_inbound_utility.get_variable('STREET2');
      rcd_lads_shp_hsp.street3 := lics_inbound_utility.get_variable('STREET3');
      rcd_lads_shp_hsp.house_supl := lics_inbound_utility.get_variable('HOUSE_SUPL');
      rcd_lads_shp_hsp.house_rang := lics_inbound_utility.get_variable('HOUSE_RANG');
      rcd_lads_shp_hsp.postl_cod1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_lads_shp_hsp.postl_cod3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_lads_shp_hsp.postl_area := lics_inbound_utility.get_variable('POSTL_AREA');
      rcd_lads_shp_hsp.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_shp_hsp.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_shp_hsp.postl_pbox := lics_inbound_utility.get_variable('POSTL_PBOX');
      rcd_lads_shp_hsp.postl_cod2 := lics_inbound_utility.get_variable('POSTL_COD2');
      rcd_lads_shp_hsp.postl_city := lics_inbound_utility.get_variable('POSTL_CITY');
      rcd_lads_shp_hsp.telephone1 := lics_inbound_utility.get_variable('TELEPHONE1');
      rcd_lads_shp_hsp.telephone2 := lics_inbound_utility.get_variable('TELEPHONE2');
      rcd_lads_shp_hsp.telefax := lics_inbound_utility.get_variable('TELEFAX');
      rcd_lads_shp_hsp.telex := lics_inbound_utility.get_variable('TELEX');
      rcd_lads_shp_hsp.e_mail := lics_inbound_utility.get_variable('E_MAIL');
      rcd_lads_shp_hsp.country1 := lics_inbound_utility.get_variable('COUNTRY1');
      rcd_lads_shp_hsp.country2 := lics_inbound_utility.get_variable('COUNTRY2');
      rcd_lads_shp_hsp.region := lics_inbound_utility.get_variable('REGION');
      rcd_lads_shp_hsp.county_cod := lics_inbound_utility.get_variable('COUNTY_COD');
      rcd_lads_shp_hsp.county_txt := lics_inbound_utility.get_variable('COUNTY_TXT');
      rcd_lads_shp_hsp.tzcode := lics_inbound_utility.get_variable('TZCODE');
      rcd_lads_shp_hsp.tzdesc := lics_inbound_utility.get_variable('TZDESC');
      rcd_lads_shp_hsp.knote_bez := lics_inbound_utility.get_variable('KNOTE_BEZ');
      rcd_lads_shp_hsp.vstel_bez := lics_inbound_utility.get_variable('VSTEL_BEZ');
      rcd_lads_shp_hsp.lstel_bez := lics_inbound_utility.get_variable('LSTEL_BEZ');
      rcd_lads_shp_hsp.werks_bez := lics_inbound_utility.get_variable('WERKS_BEZ');
      rcd_lads_shp_hsp.lgort_bez := lics_inbound_utility.get_variable('LGORT_BEZ');
      rcd_lads_shp_hsp.lgnum_bez := lics_inbound_utility.get_variable('LGNUM_BEZ');
      rcd_lads_shp_hsp.lgtor_bez := lics_inbound_utility.get_variable('LGTOR_BEZ');

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
      if rcd_lads_shp_hsp.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HSP.TKNUM');
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

      insert into lads_shp_hsp
         (tknum,
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
          tzdesc,
          knote_bez,
          vstel_bez,
          lstel_bez,
          werks_bez,
          lgort_bez,
          lgnum_bez,
          lgtor_bez)
      values
         (rcd_lads_shp_hsp.tknum,
          rcd_lads_shp_hsp.hstseq,
          rcd_lads_shp_hsp.hspseq,
          rcd_lads_shp_hsp.quali,
          rcd_lads_shp_hsp.knote,
          rcd_lads_shp_hsp.adrnr,
          rcd_lads_shp_hsp.vstel,
          rcd_lads_shp_hsp.lstel,
          rcd_lads_shp_hsp.werks,
          rcd_lads_shp_hsp.lgort,
          rcd_lads_shp_hsp.kunnr,
          rcd_lads_shp_hsp.lifnr,
          rcd_lads_shp_hsp.ablad,
          rcd_lads_shp_hsp.lgnum,
          rcd_lads_shp_hsp.lgtor,
          rcd_lads_shp_hsp.bahnra,
          rcd_lads_shp_hsp.partner_q,
          rcd_lads_shp_hsp.address_t,
          rcd_lads_shp_hsp.partner_id,
          rcd_lads_shp_hsp.jurisdic,
          rcd_lads_shp_hsp.language,
          rcd_lads_shp_hsp.formofaddr,
          rcd_lads_shp_hsp.name1,
          rcd_lads_shp_hsp.name2,
          rcd_lads_shp_hsp.name3,
          rcd_lads_shp_hsp.name4,
          rcd_lads_shp_hsp.name_text,
          rcd_lads_shp_hsp.name_co,
          rcd_lads_shp_hsp.location,
          rcd_lads_shp_hsp.building,
          rcd_lads_shp_hsp.floor,
          rcd_lads_shp_hsp.room,
          rcd_lads_shp_hsp.street1,
          rcd_lads_shp_hsp.street2,
          rcd_lads_shp_hsp.street3,
          rcd_lads_shp_hsp.house_supl,
          rcd_lads_shp_hsp.house_rang,
          rcd_lads_shp_hsp.postl_cod1,
          rcd_lads_shp_hsp.postl_cod3,
          rcd_lads_shp_hsp.postl_area,
          rcd_lads_shp_hsp.city1,
          rcd_lads_shp_hsp.city2,
          rcd_lads_shp_hsp.postl_pbox,
          rcd_lads_shp_hsp.postl_cod2,
          rcd_lads_shp_hsp.postl_city,
          rcd_lads_shp_hsp.telephone1,
          rcd_lads_shp_hsp.telephone2,
          rcd_lads_shp_hsp.telefax,
          rcd_lads_shp_hsp.telex,
          rcd_lads_shp_hsp.e_mail,
          rcd_lads_shp_hsp.country1,
          rcd_lads_shp_hsp.country2,
          rcd_lads_shp_hsp.region,
          rcd_lads_shp_hsp.county_cod,
          rcd_lads_shp_hsp.county_txt,
          rcd_lads_shp_hsp.tzcode,
          rcd_lads_shp_hsp.tzdesc,
          rcd_lads_shp_hsp.knote_bez,
          rcd_lads_shp_hsp.vstel_bez,
          rcd_lads_shp_hsp.lstel_bez,
          rcd_lads_shp_hsp.werks_bez,
          rcd_lads_shp_hsp.lgort_bez,
          rcd_lads_shp_hsp.lgnum_bez,
          rcd_lads_shp_hsp.lgtor_bez);

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
      rcd_lads_shp_hsd.tknum := rcd_lads_shp_hst.tknum;
      rcd_lads_shp_hsd.hstseq := rcd_lads_shp_hst.hstseq;
      rcd_lads_shp_hsd.hsdseq := rcd_lads_shp_hsd.hsdseq + 1;
      rcd_lads_shp_hsd.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_shp_hsd.ntanf := lics_inbound_utility.get_variable('NTANF');
      rcd_lads_shp_hsd.ntanz := lics_inbound_utility.get_variable('NTANZ');
      rcd_lads_shp_hsd.ntend := lics_inbound_utility.get_variable('NTEND');
      rcd_lads_shp_hsd.ntenz := lics_inbound_utility.get_variable('NTENZ');
      rcd_lads_shp_hsd.isdd := lics_inbound_utility.get_variable('ISDD');
      rcd_lads_shp_hsd.isdz := lics_inbound_utility.get_variable('ISDZ');
      rcd_lads_shp_hsd.iedd := lics_inbound_utility.get_variable('IEDD');
      rcd_lads_shp_hsd.iedz := lics_inbound_utility.get_variable('IEDZ');
      rcd_lads_shp_hsd.vornr := lics_inbound_utility.get_variable('VORNR');
      rcd_lads_shp_hsd.vstga := lics_inbound_utility.get_variable('VSTGA');

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
      if rcd_lads_shp_hsd.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HSD.TKNUM');
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

      insert into lads_shp_hsd
         (tknum,
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
         (rcd_lads_shp_hsd.tknum,
          rcd_lads_shp_hsd.hstseq,
          rcd_lads_shp_hsd.hsdseq,
          rcd_lads_shp_hsd.qualf,
          rcd_lads_shp_hsd.ntanf,
          rcd_lads_shp_hsd.ntanz,
          rcd_lads_shp_hsd.ntend,
          rcd_lads_shp_hsd.ntenz,
          rcd_lads_shp_hsd.isdd,
          rcd_lads_shp_hsd.isdz,
          rcd_lads_shp_hsd.iedd,
          rcd_lads_shp_hsd.iedz,
          rcd_lads_shp_hsd.vornr,
          rcd_lads_shp_hsd.vstga);

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
      rcd_lads_shp_hsi.tknum := rcd_lads_shp_hst.tknum;
      rcd_lads_shp_hsi.hstseq := rcd_lads_shp_hst.hstseq;
      rcd_lads_shp_hsi.hsiseq := rcd_lads_shp_hsi.hsiseq + 1;
      rcd_lads_shp_hsi.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_lads_shp_hsi.parid := lics_inbound_utility.get_variable('PARID');

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
      if rcd_lads_shp_hsi.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HSI.TKNUM');
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

      insert into lads_shp_hsi
         (tknum,
          hstseq,
          hsiseq,
          vbeln,
          parid)
      values
         (rcd_lads_shp_hsi.tknum,
          rcd_lads_shp_hsi.hstseq,
          rcd_lads_shp_hsi.hsiseq,
          rcd_lads_shp_hsi.vbeln,
          rcd_lads_shp_hsi.parid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hsi;

   /**************************************************/
   /* This procedure performs the record DLV routine */
   /**************************************************/
   procedure process_record_dlv(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DLV', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_dlv.tknum := rcd_lads_shp_hdr.tknum;
      rcd_lads_shp_dlv.dlvseq := rcd_lads_shp_dlv.dlvseq + 1;
      rcd_lads_shp_dlv.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_lads_shp_dlv.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_shp_dlv.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_shp_dlv.lstel := lics_inbound_utility.get_variable('LSTEL');
      rcd_lads_shp_dlv.vkbur := lics_inbound_utility.get_variable('VKBUR');
      rcd_lads_shp_dlv.lgnum := lics_inbound_utility.get_variable('LGNUM');
      rcd_lads_shp_dlv.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_shp_dlv.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_lads_shp_dlv.inco2 := lics_inbound_utility.get_variable('INCO2');
      rcd_lads_shp_dlv.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_shp_dlv.vsbed := lics_inbound_utility.get_variable('VSBED');
      rcd_lads_shp_dlv.btgew := lics_inbound_utility.get_number('BTGEW',null);
      rcd_lads_shp_dlv.ntgew := lics_inbound_utility.get_number('NTGEW',null);
      rcd_lads_shp_dlv.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_shp_dlv.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_lads_shp_dlv.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_lads_shp_dlv.anzpk := lics_inbound_utility.get_variable('ANZPK');
      rcd_lads_shp_dlv.bolnr := lics_inbound_utility.get_variable('BOLNR');
      rcd_lads_shp_dlv.traty := lics_inbound_utility.get_variable('TRATY');
      rcd_lads_shp_dlv.traid := lics_inbound_utility.get_variable('TRAID');
      rcd_lads_shp_dlv.xabln := lics_inbound_utility.get_variable('XABLN');
      rcd_lads_shp_dlv.lifex := lics_inbound_utility.get_variable('LIFEX');
      rcd_lads_shp_dlv.parid := lics_inbound_utility.get_variable('PARID');
      rcd_lads_shp_dlv.podat := lics_inbound_utility.get_variable('PODAT');
      rcd_lads_shp_dlv.potim := lics_inbound_utility.get_variable('POTIM');
      rcd_lads_shp_dlv.lfart := lics_inbound_utility.get_variable('LFART');
      rcd_lads_shp_dlv.bzirk := lics_inbound_utility.get_variable('BZIRK');
      rcd_lads_shp_dlv.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_lads_shp_dlv.expkz := lics_inbound_utility.get_variable('EXPKZ');
      rcd_lads_shp_dlv.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_lads_shp_dlv.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_lads_shp_dlv.kdgrp := lics_inbound_utility.get_variable('KDGRP');
      rcd_lads_shp_dlv.berot := lics_inbound_utility.get_variable('BEROT');
      rcd_lads_shp_dlv.tragr := lics_inbound_utility.get_variable('TRAGR');
      rcd_lads_shp_dlv.trspg := lics_inbound_utility.get_variable('TRSPG');
      rcd_lads_shp_dlv.aulwe := lics_inbound_utility.get_variable('AULWE');
      rcd_lads_shp_dlv.vstel_bez := lics_inbound_utility.get_variable('VSTEL_BEZ');
      rcd_lads_shp_dlv.vkorg_bez := lics_inbound_utility.get_variable('VKORG_BEZ');
      rcd_lads_shp_dlv.lstel_bez := lics_inbound_utility.get_variable('LSTEL_BEZ');
      rcd_lads_shp_dlv.vkbur_bez := lics_inbound_utility.get_variable('VKBUR_BEZ');
      rcd_lads_shp_dlv.lgnum_bez := lics_inbound_utility.get_variable('LGNUM_BEZ');
      rcd_lads_shp_dlv.inco1_bez := lics_inbound_utility.get_variable('INCO1_BEZ');
      rcd_lads_shp_dlv.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_shp_dlv.vsbed_bez := lics_inbound_utility.get_variable('VSBED_BEZ');
      rcd_lads_shp_dlv.traty_bez := lics_inbound_utility.get_variable('TRATY_BEZ');
      rcd_lads_shp_dlv.lfart_bez := lics_inbound_utility.get_variable('LFART_BEZ');
      rcd_lads_shp_dlv.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_lads_shp_dlv.bzirk_bez := lics_inbound_utility.get_variable('BZIRK_BEZ');
      rcd_lads_shp_dlv.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_lads_shp_dlv.kdgrp_bez := lics_inbound_utility.get_variable('KDGRP_BEZ');
      rcd_lads_shp_dlv.tragr_bez := lics_inbound_utility.get_variable('TRAGR_BEZ');
      rcd_lads_shp_dlv.trspg_bez := lics_inbound_utility.get_variable('TRSPG_BEZ');
      rcd_lads_shp_dlv.aulwe_bez := lics_inbound_utility.get_variable('AULWE_BEZ');
      rcd_lads_shp_dlv.aland := lics_inbound_utility.get_variable('ALAND');
      rcd_lads_shp_dlv.expvz := lics_inbound_utility.get_variable('EXPVZ');
      rcd_lads_shp_dlv.zolla := lics_inbound_utility.get_variable('ZOLLA');
      rcd_lads_shp_dlv.zollb := lics_inbound_utility.get_variable('ZOLLB');
      rcd_lads_shp_dlv.kzgbe := lics_inbound_utility.get_variable('KZGBE');
      rcd_lads_shp_dlv.kzabe := lics_inbound_utility.get_variable('KZABE');
      rcd_lads_shp_dlv.stgbe := lics_inbound_utility.get_variable('STGBE');
      rcd_lads_shp_dlv.stabe := lics_inbound_utility.get_variable('STABE');
      rcd_lads_shp_dlv.conta := lics_inbound_utility.get_variable('CONTA');
      rcd_lads_shp_dlv.grwcu := lics_inbound_utility.get_variable('GRWCU');
      rcd_lads_shp_dlv.iever := lics_inbound_utility.get_variable('IEVER');
      rcd_lads_shp_dlv.expvz_bez := lics_inbound_utility.get_variable('EXPVZ_BEZ');
      rcd_lads_shp_dlv.zolla_bez := lics_inbound_utility.get_variable('ZOLLA_BEZ');
      rcd_lads_shp_dlv.zollb_bez := lics_inbound_utility.get_variable('ZOLLB_BEZ');
      rcd_lads_shp_dlv.iever_bez := lics_inbound_utility.get_variable('IEVER_BEZ');
      rcd_lads_shp_dlv.stgbe_bez := lics_inbound_utility.get_variable('STGBE_BEZ');
      rcd_lads_shp_dlv.stabe_bez := lics_inbound_utility.get_variable('STABE_BEZ');
      rcd_lads_shp_dlv.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_shp_dlv.vsavl := lics_inbound_utility.get_variable('VSAVL');
      rcd_lads_shp_dlv.vsanl := lics_inbound_utility.get_variable('VSANL');
      rcd_lads_shp_dlv.rouid := lics_inbound_utility.get_variable('ROUID');
      rcd_lads_shp_dlv.distz := lics_inbound_utility.get_number('DISTZ',null);
      rcd_lads_shp_dlv.medst := lics_inbound_utility.get_variable('MEDST');
      rcd_lads_shp_dlv.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_shp_dlv.vsavl_bez := lics_inbound_utility.get_variable('VSAVL_BEZ');
      rcd_lads_shp_dlv.vsanl_bez := lics_inbound_utility.get_variable('VSANL_BEZ');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_dad.dadseq := 0;
      rcd_lads_shp_ded.dedseq := 0;
      rcd_lads_shp_drs.drsseq := 0;
      rcd_lads_shp_dit.ditseq := 0;
      rcd_lads_shp_dhu.dhuseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_dlv.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DLV.TKNUM');
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

      insert into lads_shp_dlv
         (tknum,
          dlvseq,
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
          lfart,
          bzirk,
          autlf,
          expkz,
          lifsk,
          lprio,
          kdgrp,
          berot,
          tragr,
          trspg,
          aulwe,
          vstel_bez,
          vkorg_bez,
          lstel_bez,
          vkbur_bez,
          lgnum_bez,
          inco1_bez,
          route_bez,
          vsbed_bez,
          traty_bez,
          lfart_bez,
          lprio_bez,
          bzirk_bez,
          lifsk_bez,
          kdgrp_bez,
          tragr_bez,
          trspg_bez,
          aulwe_bez,
          aland,
          expvz,
          zolla,
          zollb,
          kzgbe,
          kzabe,
          stgbe,
          stabe,
          conta,
          grwcu,
          iever,
          expvz_bez,
          zolla_bez,
          zollb_bez,
          iever_bez,
          stgbe_bez,
          stabe_bez,
          vsart,
          vsavl,
          vsanl,
          rouid,
          distz,
          medst,
          vsart_bez,
          vsavl_bez,
          vsanl_bez)
      values
         (rcd_lads_shp_dlv.tknum,
          rcd_lads_shp_dlv.dlvseq,
          rcd_lads_shp_dlv.vbeln,
          rcd_lads_shp_dlv.vstel,
          rcd_lads_shp_dlv.vkorg,
          rcd_lads_shp_dlv.lstel,
          rcd_lads_shp_dlv.vkbur,
          rcd_lads_shp_dlv.lgnum,
          rcd_lads_shp_dlv.ablad,
          rcd_lads_shp_dlv.inco1,
          rcd_lads_shp_dlv.inco2,
          rcd_lads_shp_dlv.route,
          rcd_lads_shp_dlv.vsbed,
          rcd_lads_shp_dlv.btgew,
          rcd_lads_shp_dlv.ntgew,
          rcd_lads_shp_dlv.gewei,
          rcd_lads_shp_dlv.volum,
          rcd_lads_shp_dlv.voleh,
          rcd_lads_shp_dlv.anzpk,
          rcd_lads_shp_dlv.bolnr,
          rcd_lads_shp_dlv.traty,
          rcd_lads_shp_dlv.traid,
          rcd_lads_shp_dlv.xabln,
          rcd_lads_shp_dlv.lifex,
          rcd_lads_shp_dlv.parid,
          rcd_lads_shp_dlv.podat,
          rcd_lads_shp_dlv.potim,
          rcd_lads_shp_dlv.lfart,
          rcd_lads_shp_dlv.bzirk,
          rcd_lads_shp_dlv.autlf,
          rcd_lads_shp_dlv.expkz,
          rcd_lads_shp_dlv.lifsk,
          rcd_lads_shp_dlv.lprio,
          rcd_lads_shp_dlv.kdgrp,
          rcd_lads_shp_dlv.berot,
          rcd_lads_shp_dlv.tragr,
          rcd_lads_shp_dlv.trspg,
          rcd_lads_shp_dlv.aulwe,
          rcd_lads_shp_dlv.vstel_bez,
          rcd_lads_shp_dlv.vkorg_bez,
          rcd_lads_shp_dlv.lstel_bez,
          rcd_lads_shp_dlv.vkbur_bez,
          rcd_lads_shp_dlv.lgnum_bez,
          rcd_lads_shp_dlv.inco1_bez,
          rcd_lads_shp_dlv.route_bez,
          rcd_lads_shp_dlv.vsbed_bez,
          rcd_lads_shp_dlv.traty_bez,
          rcd_lads_shp_dlv.lfart_bez,
          rcd_lads_shp_dlv.lprio_bez,
          rcd_lads_shp_dlv.bzirk_bez,
          rcd_lads_shp_dlv.lifsk_bez,
          rcd_lads_shp_dlv.kdgrp_bez,
          rcd_lads_shp_dlv.tragr_bez,
          rcd_lads_shp_dlv.trspg_bez,
          rcd_lads_shp_dlv.aulwe_bez,
          rcd_lads_shp_dlv.aland,
          rcd_lads_shp_dlv.expvz,
          rcd_lads_shp_dlv.zolla,
          rcd_lads_shp_dlv.zollb,
          rcd_lads_shp_dlv.kzgbe,
          rcd_lads_shp_dlv.kzabe,
          rcd_lads_shp_dlv.stgbe,
          rcd_lads_shp_dlv.stabe,
          rcd_lads_shp_dlv.conta,
          rcd_lads_shp_dlv.grwcu,
          rcd_lads_shp_dlv.iever,
          rcd_lads_shp_dlv.expvz_bez,
          rcd_lads_shp_dlv.zolla_bez,
          rcd_lads_shp_dlv.zollb_bez,
          rcd_lads_shp_dlv.iever_bez,
          rcd_lads_shp_dlv.stgbe_bez,
          rcd_lads_shp_dlv.stabe_bez,
          rcd_lads_shp_dlv.vsart,
          rcd_lads_shp_dlv.vsavl,
          rcd_lads_shp_dlv.vsanl,
          rcd_lads_shp_dlv.rouid,
          rcd_lads_shp_dlv.distz,
          rcd_lads_shp_dlv.medst,
          rcd_lads_shp_dlv.vsart_bez,
          rcd_lads_shp_dlv.vsavl_bez,
          rcd_lads_shp_dlv.vsanl_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dlv;

   /**************************************************/
   /* This procedure performs the record DAD routine */
   /**************************************************/
   procedure process_record_dad(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DAD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_dad.tknum := rcd_lads_shp_dlv.tknum;
      rcd_lads_shp_dad.dlvseq := rcd_lads_shp_dlv.dlvseq;
      rcd_lads_shp_dad.dadseq := rcd_lads_shp_dad.dadseq + 1;
      rcd_lads_shp_dad.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_shp_dad.address_t := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_lads_shp_dad.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_shp_dad.jurisdic := lics_inbound_utility.get_variable('JURISDIC');
      rcd_lads_shp_dad.language := lics_inbound_utility.get_variable('LANGUAGE');
      rcd_lads_shp_dad.formofaddr := lics_inbound_utility.get_variable('FORMOFADDR');
      rcd_lads_shp_dad.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_shp_dad.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_shp_dad.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_shp_dad.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_shp_dad.name_text := lics_inbound_utility.get_variable('NAME_TEXT');
      rcd_lads_shp_dad.name_co := lics_inbound_utility.get_variable('NAME_CO');
      rcd_lads_shp_dad.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_shp_dad.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_shp_dad.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_shp_dad.room := lics_inbound_utility.get_variable('ROOM');
      rcd_lads_shp_dad.street1 := lics_inbound_utility.get_variable('STREET1');
      rcd_lads_shp_dad.street2 := lics_inbound_utility.get_variable('STREET2');
      rcd_lads_shp_dad.street3 := lics_inbound_utility.get_variable('STREET3');
      rcd_lads_shp_dad.house_supl := lics_inbound_utility.get_variable('HOUSE_SUPL');
      rcd_lads_shp_dad.house_rang := lics_inbound_utility.get_variable('HOUSE_RANG');
      rcd_lads_shp_dad.postl_cod1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_lads_shp_dad.postl_cod3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_lads_shp_dad.postl_area := lics_inbound_utility.get_variable('POSTL_AREA');
      rcd_lads_shp_dad.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_shp_dad.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_shp_dad.postl_pbox := lics_inbound_utility.get_variable('POSTL_PBOX');
      rcd_lads_shp_dad.postl_cod2 := lics_inbound_utility.get_variable('POSTL_COD2');
      rcd_lads_shp_dad.postl_city := lics_inbound_utility.get_variable('POSTL_CITY');
      rcd_lads_shp_dad.telephone1 := lics_inbound_utility.get_variable('TELEPHONE1');
      rcd_lads_shp_dad.telephone2 := lics_inbound_utility.get_variable('TELEPHONE2');
      rcd_lads_shp_dad.telefax := lics_inbound_utility.get_variable('TELEFAX');
      rcd_lads_shp_dad.telex := lics_inbound_utility.get_variable('TELEX');
      rcd_lads_shp_dad.e_mail := lics_inbound_utility.get_variable('E_MAIL');
      rcd_lads_shp_dad.country1 := lics_inbound_utility.get_variable('COUNTRY1');
      rcd_lads_shp_dad.country2 := lics_inbound_utility.get_variable('COUNTRY2');
      rcd_lads_shp_dad.region := lics_inbound_utility.get_variable('REGION');
      rcd_lads_shp_dad.county_cod := lics_inbound_utility.get_variable('COUNTY_COD');
      rcd_lads_shp_dad.county_txt := lics_inbound_utility.get_variable('COUNTY_TXT');
      rcd_lads_shp_dad.tzcode := lics_inbound_utility.get_variable('TZCODE');
      rcd_lads_shp_dad.tzdesc := lics_inbound_utility.get_variable('TZDESC');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_das.dasseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_dad.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAD.TKNUM');
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

      insert into lads_shp_dad
         (tknum,
          dlvseq,
          dadseq,
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
         (rcd_lads_shp_dad.tknum,
          rcd_lads_shp_dad.dlvseq,
          rcd_lads_shp_dad.dadseq,
          rcd_lads_shp_dad.partner_q,
          rcd_lads_shp_dad.address_t,
          rcd_lads_shp_dad.partner_id,
          rcd_lads_shp_dad.jurisdic,
          rcd_lads_shp_dad.language,
          rcd_lads_shp_dad.formofaddr,
          rcd_lads_shp_dad.name1,
          rcd_lads_shp_dad.name2,
          rcd_lads_shp_dad.name3,
          rcd_lads_shp_dad.name4,
          rcd_lads_shp_dad.name_text,
          rcd_lads_shp_dad.name_co,
          rcd_lads_shp_dad.location,
          rcd_lads_shp_dad.building,
          rcd_lads_shp_dad.floor,
          rcd_lads_shp_dad.room,
          rcd_lads_shp_dad.street1,
          rcd_lads_shp_dad.street2,
          rcd_lads_shp_dad.street3,
          rcd_lads_shp_dad.house_supl,
          rcd_lads_shp_dad.house_rang,
          rcd_lads_shp_dad.postl_cod1,
          rcd_lads_shp_dad.postl_cod3,
          rcd_lads_shp_dad.postl_area,
          rcd_lads_shp_dad.city1,
          rcd_lads_shp_dad.city2,
          rcd_lads_shp_dad.postl_pbox,
          rcd_lads_shp_dad.postl_cod2,
          rcd_lads_shp_dad.postl_city,
          rcd_lads_shp_dad.telephone1,
          rcd_lads_shp_dad.telephone2,
          rcd_lads_shp_dad.telefax,
          rcd_lads_shp_dad.telex,
          rcd_lads_shp_dad.e_mail,
          rcd_lads_shp_dad.country1,
          rcd_lads_shp_dad.country2,
          rcd_lads_shp_dad.region,
          rcd_lads_shp_dad.county_cod,
          rcd_lads_shp_dad.county_txt,
          rcd_lads_shp_dad.tzcode,
          rcd_lads_shp_dad.tzdesc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dad;

   /**************************************************/
   /* This procedure performs the record DAS routine */
   /**************************************************/
   procedure process_record_das(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DAS', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_das.tknum := rcd_lads_shp_dad.tknum;
      rcd_lads_shp_das.dlvseq := rcd_lads_shp_dad.dlvseq;
      rcd_lads_shp_das.dadseq := rcd_lads_shp_dad.dadseq;
      rcd_lads_shp_das.dasseq := rcd_lads_shp_das.dasseq + 1;
      rcd_lads_shp_das.extend_q := lics_inbound_utility.get_variable('EXTEND_Q');
      rcd_lads_shp_das.extend_d := lics_inbound_utility.get_variable('EXTEND_D');

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
      if rcd_lads_shp_das.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAS.TKNUM');
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

      insert into lads_shp_das
         (tknum,
          dlvseq,
          dadseq,
          dasseq,
          extend_q,
          extend_d)
      values
         (rcd_lads_shp_das.tknum,
          rcd_lads_shp_das.dlvseq,
          rcd_lads_shp_das.dadseq,
          rcd_lads_shp_das.dasseq,
          rcd_lads_shp_das.extend_q,
          rcd_lads_shp_das.extend_d);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_das;

   /**************************************************/
   /* This procedure performs the record DED routine */
   /**************************************************/
   procedure process_record_ded(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DED', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_ded.tknum := rcd_lads_shp_dlv.tknum;
      rcd_lads_shp_ded.dlvseq := rcd_lads_shp_dlv.dlvseq;
      rcd_lads_shp_ded.dedseq := rcd_lads_shp_ded.dedseq + 1;
      rcd_lads_shp_ded.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_shp_ded.vstzw := lics_inbound_utility.get_variable('VSTZW');
      rcd_lads_shp_ded.vstzw_bez := lics_inbound_utility.get_variable('VSTZW_BEZ');
      rcd_lads_shp_ded.ntanf := lics_inbound_utility.get_variable('NTANF');
      rcd_lads_shp_ded.ntanz := lics_inbound_utility.get_variable('NTANZ');
      rcd_lads_shp_ded.ntend := lics_inbound_utility.get_variable('NTEND');
      rcd_lads_shp_ded.ntenz := lics_inbound_utility.get_variable('NTENZ');
      rcd_lads_shp_ded.tzone_beg := lics_inbound_utility.get_variable('TZONE_BEG');
      rcd_lads_shp_ded.isdd := lics_inbound_utility.get_variable('ISDD');
      rcd_lads_shp_ded.isdz := lics_inbound_utility.get_variable('ISDZ');
      rcd_lads_shp_ded.iedd := lics_inbound_utility.get_variable('IEDD');
      rcd_lads_shp_ded.iedz := lics_inbound_utility.get_variable('IEDZ');
      rcd_lads_shp_ded.tzone_end := lics_inbound_utility.get_variable('TZONE_END');
      rcd_lads_shp_ded.vornr := lics_inbound_utility.get_variable('VORNR');
      rcd_lads_shp_ded.vstga := lics_inbound_utility.get_variable('VSTGA');
      rcd_lads_shp_ded.vstga_bez := lics_inbound_utility.get_variable('VSTGA_BEZ');
      rcd_lads_shp_ded.event := lics_inbound_utility.get_variable('EVENT');
      rcd_lads_shp_ded.event_ali := lics_inbound_utility.get_variable('EVENT_ALI');
      rcd_lads_shp_ded.knote := lics_inbound_utility.get_variable('KNOTE');
      rcd_lads_shp_ded.knote_bez := lics_inbound_utility.get_variable('KNOTE_BEZ');

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
      if rcd_lads_shp_ded.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DED.TKNUM');
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

      insert into lads_shp_ded
         (tknum,
          dlvseq,
          dedseq,
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
          event_ali,
          knote,
          knote_bez)
      values
         (rcd_lads_shp_ded.tknum,
          rcd_lads_shp_ded.dlvseq,
          rcd_lads_shp_ded.dedseq,
          rcd_lads_shp_ded.qualf,
          rcd_lads_shp_ded.vstzw,
          rcd_lads_shp_ded.vstzw_bez,
          rcd_lads_shp_ded.ntanf,
          rcd_lads_shp_ded.ntanz,
          rcd_lads_shp_ded.ntend,
          rcd_lads_shp_ded.ntenz,
          rcd_lads_shp_ded.tzone_beg,
          rcd_lads_shp_ded.isdd,
          rcd_lads_shp_ded.isdz,
          rcd_lads_shp_ded.iedd,
          rcd_lads_shp_ded.iedz,
          rcd_lads_shp_ded.tzone_end,
          rcd_lads_shp_ded.vornr,
          rcd_lads_shp_ded.vstga,
          rcd_lads_shp_ded.vstga_bez,
          rcd_lads_shp_ded.event,
          rcd_lads_shp_ded.event_ali,
          rcd_lads_shp_ded.knote,
          rcd_lads_shp_ded.knote_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ded;

   /**************************************************/
   /* This procedure performs the record DRS routine */
   /**************************************************/
   procedure process_record_drs(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DRS', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_drs.tknum := rcd_lads_shp_dlv.tknum;
      rcd_lads_shp_drs.dlvseq := rcd_lads_shp_dlv.dlvseq;
      rcd_lads_shp_drs.drsseq := rcd_lads_shp_drs.drsseq + 1;
      rcd_lads_shp_drs.abnum := lics_inbound_utility.get_number('ABNUM',null);
      rcd_lads_shp_drs.anfrf := lics_inbound_utility.get_number('ANFRF',null);
      rcd_lads_shp_drs.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_shp_drs.distz := lics_inbound_utility.get_number('DISTZ',null);
      rcd_lads_shp_drs.medst := lics_inbound_utility.get_variable('MEDST');
      rcd_lads_shp_drs.tstyp := lics_inbound_utility.get_variable('TSTYP');
      rcd_lads_shp_drs.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');

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
      if rcd_lads_shp_drs.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DRS.TKNUM');
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

      insert into lads_shp_drs
         (tknum,
          dlvseq,
          drsseq,
          abnum,
          anfrf,
          vsart,
          distz,
          medst,
          tstyp,
          vsart_bez)
      values
         (rcd_lads_shp_drs.tknum,
          rcd_lads_shp_drs.dlvseq,
          rcd_lads_shp_drs.drsseq,
          rcd_lads_shp_drs.abnum,
          rcd_lads_shp_drs.anfrf,
          rcd_lads_shp_drs.vsart,
          rcd_lads_shp_drs.distz,
          rcd_lads_shp_drs.medst,
          rcd_lads_shp_drs.tstyp,
          rcd_lads_shp_drs.vsart_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_drs;

   /**************************************************/
   /* This procedure performs the record DIT routine */
   /**************************************************/
   procedure process_record_dit(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DIT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_dit.tknum := rcd_lads_shp_dlv.tknum;
      rcd_lads_shp_dit.dlvseq := rcd_lads_shp_dlv.dlvseq;
      rcd_lads_shp_dit.ditseq := rcd_lads_shp_dit.ditseq + 1;
      rcd_lads_shp_dit.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_shp_dit.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_shp_dit.matwa := lics_inbound_utility.get_variable('MATWA');
      rcd_lads_shp_dit.orktx := lics_inbound_utility.get_variable('ORKTX');
      rcd_lads_shp_dit.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_shp_dit.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_shp_dit.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_shp_dit.charg := lics_inbound_utility.get_variable('CHARG');
      rcd_lads_shp_dit.lgort_bez := lics_inbound_utility.get_variable('LGORT_BEZ');
      rcd_lads_shp_dit.ladgr_bez := lics_inbound_utility.get_variable('LADGR_BEZ');
      rcd_lads_shp_dit.tragr_bez := lics_inbound_utility.get_variable('TRAGR_BEZ');
      rcd_lads_shp_dit.vkbur_bez := lics_inbound_utility.get_variable('VKBUR_BEZ');
      rcd_lads_shp_dit.vkgrp_bez := lics_inbound_utility.get_variable('VKGRP_BEZ');
      rcd_lads_shp_dit.vtweg_bez := lics_inbound_utility.get_variable('VTWEG_BEZ');
      rcd_lads_shp_dit.spart_bez := lics_inbound_utility.get_variable('SPART_BEZ');
      rcd_lads_shp_dit.mfrgr_bez := lics_inbound_utility.get_variable('MFRGR_BEZ');
      rcd_lads_shp_dit.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_lads_shp_dit.matkl_dup := lics_inbound_utility.get_variable('MATKL_DUP');
      rcd_lads_shp_dit.prodh := lics_inbound_utility.get_variable('PRODH');
      rcd_lads_shp_dit.umvkz := lics_inbound_utility.get_number('UMVKZ',null);
      rcd_lads_shp_dit.umvkn := lics_inbound_utility.get_number('UMVKN',null);
      rcd_lads_shp_dit.kztlf := lics_inbound_utility.get_variable('KZTLF');
      rcd_lads_shp_dit.uebtk := lics_inbound_utility.get_variable('UEBTK');
      rcd_lads_shp_dit.uebto := lics_inbound_utility.get_number('UEBTO',null);
      rcd_lads_shp_dit.untto := lics_inbound_utility.get_number('UNTTO',null);
      rcd_lads_shp_dit.chspl := lics_inbound_utility.get_variable('CHSPL');
      rcd_lads_shp_dit.xchbw := lics_inbound_utility.get_variable('XCHBW');
      rcd_lads_shp_dit.posar := lics_inbound_utility.get_variable('POSAR');
      rcd_lads_shp_dit.sobkz := lics_inbound_utility.get_variable('SOBKZ');
      rcd_lads_shp_dit.pckpf := lics_inbound_utility.get_variable('PCKPF');
      rcd_lads_shp_dit.magrv := lics_inbound_utility.get_variable('MAGRV');
      rcd_lads_shp_dit.shkzg := lics_inbound_utility.get_variable('SHKZG');
      rcd_lads_shp_dit.koqui := lics_inbound_utility.get_variable('KOQUI');
      rcd_lads_shp_dit.aktnr := lics_inbound_utility.get_variable('AKTNR');
      rcd_lads_shp_dit.kzumw := lics_inbound_utility.get_variable('KZUMW');
      rcd_lads_shp_dit.pstyv_bez := lics_inbound_utility.get_variable('PSTYV_BEZ');
      rcd_lads_shp_dit.matkl_bez := lics_inbound_utility.get_variable('MATKL_BEZ');
      rcd_lads_shp_dit.prodh_bez := lics_inbound_utility.get_variable('PRODH_BEZ');
      rcd_lads_shp_dit.werks_bez := lics_inbound_utility.get_variable('WERKS_BEZ');
      rcd_lads_shp_dit.stawn := lics_inbound_utility.get_variable('STAWN');
      rcd_lads_shp_dit.exprf := lics_inbound_utility.get_variable('EXPRF');
      rcd_lads_shp_dit.exart := lics_inbound_utility.get_variable('EXART');
      rcd_lads_shp_dit.herkl := lics_inbound_utility.get_variable('HERKL');
      rcd_lads_shp_dit.herkr := lics_inbound_utility.get_variable('HERKR');
      rcd_lads_shp_dit.grwrt := lics_inbound_utility.get_number('GRWRT',null);
      rcd_lads_shp_dit.prefe := lics_inbound_utility.get_variable('PREFE');
      rcd_lads_shp_dit.stxt1 := lics_inbound_utility.get_variable('STXT1');
      rcd_lads_shp_dit.stxt2 := lics_inbound_utility.get_variable('STXT2');
      rcd_lads_shp_dit.stxt3 := lics_inbound_utility.get_variable('STXT3');
      rcd_lads_shp_dit.stxt4 := lics_inbound_utility.get_variable('STXT4');
      rcd_lads_shp_dit.stxt5 := lics_inbound_utility.get_variable('STXT5');
      rcd_lads_shp_dit.stxt6 := lics_inbound_utility.get_variable('STXT6');
      rcd_lads_shp_dit.stxt7 := lics_inbound_utility.get_variable('STXT7');
      rcd_lads_shp_dit.exprf_bez := lics_inbound_utility.get_variable('EXPRF_BEZ');
      rcd_lads_shp_dit.exart_bez := lics_inbound_utility.get_variable('EXART_BEZ');
      rcd_lads_shp_dit.herkl_bez := lics_inbound_utility.get_variable('HERKL_BEZ');
      rcd_lads_shp_dit.herkr_bez := lics_inbound_utility.get_variable('HERKR_BEZ');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_dib.dibseq := 0;
      rcd_lads_shp_dng.dngseq := 0;
      rcd_lads_shp_drf.drfseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_dit.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DIT.TKNUM');
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

      insert into lads_shp_dit
         (tknum,
          dlvseq,
          ditseq,
          posnr,
          matnr,
          matwa,
          orktx,
          matkl,
          werks,
          lgort,
          charg,
          lgort_bez,
          ladgr_bez,
          tragr_bez,
          vkbur_bez,
          vkgrp_bez,
          vtweg_bez,
          spart_bez,
          mfrgr_bez,
          pstyv,
          matkl_dup,
          prodh,
          umvkz,
          umvkn,
          kztlf,
          uebtk,
          uebto,
          untto,
          chspl,
          xchbw,
          posar,
          sobkz,
          pckpf,
          magrv,
          shkzg,
          koqui,
          aktnr,
          kzumw,
          pstyv_bez,
          matkl_bez,
          prodh_bez,
          werks_bez,
          stawn,
          exprf,
          exart,
          herkl,
          herkr,
          grwrt,
          prefe,
          stxt1,
          stxt2,
          stxt3,
          stxt4,
          stxt5,
          stxt6,
          stxt7,
          exprf_bez,
          exart_bez,
          herkl_bez,
          herkr_bez)
      values
         (rcd_lads_shp_dit.tknum,
          rcd_lads_shp_dit.dlvseq,
          rcd_lads_shp_dit.ditseq,
          rcd_lads_shp_dit.posnr,
          rcd_lads_shp_dit.matnr,
          rcd_lads_shp_dit.matwa,
          rcd_lads_shp_dit.orktx,
          rcd_lads_shp_dit.matkl,
          rcd_lads_shp_dit.werks,
          rcd_lads_shp_dit.lgort,
          rcd_lads_shp_dit.charg,
          rcd_lads_shp_dit.lgort_bez,
          rcd_lads_shp_dit.ladgr_bez,
          rcd_lads_shp_dit.tragr_bez,
          rcd_lads_shp_dit.vkbur_bez,
          rcd_lads_shp_dit.vkgrp_bez,
          rcd_lads_shp_dit.vtweg_bez,
          rcd_lads_shp_dit.spart_bez,
          rcd_lads_shp_dit.mfrgr_bez,
          rcd_lads_shp_dit.pstyv,
          rcd_lads_shp_dit.matkl_dup,
          rcd_lads_shp_dit.prodh,
          rcd_lads_shp_dit.umvkz,
          rcd_lads_shp_dit.umvkn,
          rcd_lads_shp_dit.kztlf,
          rcd_lads_shp_dit.uebtk,
          rcd_lads_shp_dit.uebto,
          rcd_lads_shp_dit.untto,
          rcd_lads_shp_dit.chspl,
          rcd_lads_shp_dit.xchbw,
          rcd_lads_shp_dit.posar,
          rcd_lads_shp_dit.sobkz,
          rcd_lads_shp_dit.pckpf,
          rcd_lads_shp_dit.magrv,
          rcd_lads_shp_dit.shkzg,
          rcd_lads_shp_dit.koqui,
          rcd_lads_shp_dit.aktnr,
          rcd_lads_shp_dit.kzumw,
          rcd_lads_shp_dit.pstyv_bez,
          rcd_lads_shp_dit.matkl_bez,
          rcd_lads_shp_dit.prodh_bez,
          rcd_lads_shp_dit.werks_bez,
          rcd_lads_shp_dit.stawn,
          rcd_lads_shp_dit.exprf,
          rcd_lads_shp_dit.exart,
          rcd_lads_shp_dit.herkl,
          rcd_lads_shp_dit.herkr,
          rcd_lads_shp_dit.grwrt,
          rcd_lads_shp_dit.prefe,
          rcd_lads_shp_dit.stxt1,
          rcd_lads_shp_dit.stxt2,
          rcd_lads_shp_dit.stxt3,
          rcd_lads_shp_dit.stxt4,
          rcd_lads_shp_dit.stxt5,
          rcd_lads_shp_dit.stxt6,
          rcd_lads_shp_dit.stxt7,
          rcd_lads_shp_dit.exprf_bez,
          rcd_lads_shp_dit.exart_bez,
          rcd_lads_shp_dit.herkl_bez,
          rcd_lads_shp_dit.herkr_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dit;

   /**************************************************/
   /* This procedure performs the record DIB routine */
   /**************************************************/
   procedure process_record_dib(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DIB', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_dib.tknum := rcd_lads_shp_dit.tknum;
      rcd_lads_shp_dib.dlvseq := rcd_lads_shp_dit.dlvseq;
      rcd_lads_shp_dib.ditseq := rcd_lads_shp_dit.ditseq;
      rcd_lads_shp_dib.dibseq := rcd_lads_shp_dib.dibseq + 1;
      rcd_lads_shp_dib.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
      rcd_lads_shp_dib.zzpalbas01_f := lics_inbound_utility.get_number('ZZPALBAS01_F',null);
      rcd_lads_shp_dib.vbelv := lics_inbound_utility.get_variable('VBELV');
      rcd_lads_shp_dib.posnv := lics_inbound_utility.get_number('POSNV',null);
      rcd_lads_shp_dib.zzhalfpal := lics_inbound_utility.get_variable('ZZHALFPAL');
      rcd_lads_shp_dib.zzstackable := lics_inbound_utility.get_variable('ZZSTACKABLE');
      rcd_lads_shp_dib.zznbrhompal := lics_inbound_utility.get_number('ZZNBRHOMPAL',null);
      rcd_lads_shp_dib.zzpalbase_deliv := lics_inbound_utility.get_number('ZZPALBASE_DELIV',null);
      rcd_lads_shp_dib.zzpalspace_deliv := lics_inbound_utility.get_number('ZZPALSPACE_DELIV',null);
      rcd_lads_shp_dib.zzmeins_deliv := lics_inbound_utility.get_variable('ZZMEINS_DELIV');
      rcd_lads_shp_dib.value1 := lics_inbound_utility.get_number('VALUE1',null);
      rcd_lads_shp_dib.zrsp := lics_inbound_utility.get_number('ZRSP',null);
      rcd_lads_shp_dib.rate := lics_inbound_utility.get_number('RATE',null);
      rcd_lads_shp_dib.kostl := lics_inbound_utility.get_variable('KOSTL');
      rcd_lads_shp_dib.vfdat := lics_inbound_utility.get_variable('VFDAT');
      rcd_lads_shp_dib.value := lics_inbound_utility.get_number('VALUE',null);
      rcd_lads_shp_dib.zzbb4 := lics_inbound_utility.get_variable('ZZBB4');
      rcd_lads_shp_dib.zzpi_id := lics_inbound_utility.get_variable('ZZPI_ID');
      rcd_lads_shp_dib.insmk := lics_inbound_utility.get_variable('INSMK');
      rcd_lads_shp_dib.spart := lics_inbound_utility.get_variable('SPART');
      rcd_lads_shp_dib.kwmeng := lics_inbound_utility.get_number('KWMENG',null);

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
      if rcd_lads_shp_dib.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DIB.TKNUM');
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

      insert into lads_shp_dib
         (tknum,
          dlvseq,
          ditseq,
          dibseq,
          zzmeins01,
          zzpalbas01_f,
          vbelv,
          posnv,
          zzhalfpal,
          zzstackable,
          zznbrhompal,
          zzpalbase_deliv,
          zzpalspace_deliv,
          zzmeins_deliv,
          value1,
          zrsp,
          rate,
          kostl,
          vfdat,
          value,
          zzbb4,
          zzpi_id,
          insmk,
          spart,
          kwmeng)
      values
         (rcd_lads_shp_dib.tknum,
          rcd_lads_shp_dib.dlvseq,
          rcd_lads_shp_dib.ditseq,
          rcd_lads_shp_dib.dibseq,
          rcd_lads_shp_dib.zzmeins01,
          rcd_lads_shp_dib.zzpalbas01_f,
          rcd_lads_shp_dib.vbelv,
          rcd_lads_shp_dib.posnv,
          rcd_lads_shp_dib.zzhalfpal,
          rcd_lads_shp_dib.zzstackable,
          rcd_lads_shp_dib.zznbrhompal,
          rcd_lads_shp_dib.zzpalbase_deliv,
          rcd_lads_shp_dib.zzpalspace_deliv,
          rcd_lads_shp_dib.zzmeins_deliv,
          rcd_lads_shp_dib.value1,
          rcd_lads_shp_dib.zrsp,
          rcd_lads_shp_dib.rate,
          rcd_lads_shp_dib.kostl,
          rcd_lads_shp_dib.vfdat,
          rcd_lads_shp_dib.value,
          rcd_lads_shp_dib.zzbb4,
          rcd_lads_shp_dib.zzpi_id,
          rcd_lads_shp_dib.insmk,
          rcd_lads_shp_dib.spart,
          rcd_lads_shp_dib.kwmeng);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dib;

   /**************************************************/
   /* This procedure performs the record DNG routine */
   /**************************************************/
   procedure process_record_dng(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DNG', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_dng.tknum := rcd_lads_shp_dit.tknum;
      rcd_lads_shp_dng.dlvseq := rcd_lads_shp_dit.dlvseq;
      rcd_lads_shp_dng.ditseq := rcd_lads_shp_dit.ditseq;
      rcd_lads_shp_dng.dngseq := rcd_lads_shp_dng.dngseq + 1;
      rcd_lads_shp_dng.mot := lics_inbound_utility.get_number('MOT',null);
      rcd_lads_shp_dng.valdat := lics_inbound_utility.get_variable('VALDAT');
      rcd_lads_shp_dng.dgcao := lics_inbound_utility.get_variable('DGCAO');
      rcd_lads_shp_dng.dgnhm := lics_inbound_utility.get_variable('DGNHM');
      rcd_lads_shp_dng.tkui := lics_inbound_utility.get_variable('TKUI');
      rcd_lads_shp_dng.dgnu := lics_inbound_utility.get_variable('DGNU');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_dbt.dbtseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_dng.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DNG.TKNUM');
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

      insert into lads_shp_dng
         (tknum,
          dlvseq,
          ditseq,
          dngseq,
          mot,
          valdat,
          dgcao,
          dgnhm,
          tkui,
          dgnu)
      values
         (rcd_lads_shp_dng.tknum,
          rcd_lads_shp_dng.dlvseq,
          rcd_lads_shp_dng.ditseq,
          rcd_lads_shp_dng.dngseq,
          rcd_lads_shp_dng.mot,
          rcd_lads_shp_dng.valdat,
          rcd_lads_shp_dng.dgcao,
          rcd_lads_shp_dng.dgnhm,
          rcd_lads_shp_dng.tkui,
          rcd_lads_shp_dng.dgnu);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dng;

   /**************************************************/
   /* This procedure performs the record DBT routine */
   /**************************************************/
   procedure process_record_dbt(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DBT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_dbt.tknum := rcd_lads_shp_dng.tknum;
      rcd_lads_shp_dbt.dlvseq := rcd_lads_shp_dng.dlvseq;
      rcd_lads_shp_dbt.ditseq := rcd_lads_shp_dng.ditseq;
      rcd_lads_shp_dbt.dngseq := rcd_lads_shp_dng.dngseq;
      rcd_lads_shp_dbt.dbtseq := rcd_lads_shp_dbt.dbtseq + 1;
      rcd_lads_shp_dbt.atinn := lics_inbound_utility.get_number('ATINN',null);
      rcd_lads_shp_dbt.atnam := lics_inbound_utility.get_variable('ATNAM');
      rcd_lads_shp_dbt.atbez := lics_inbound_utility.get_variable('ATBEZ');
      rcd_lads_shp_dbt.atwrt := lics_inbound_utility.get_variable('ATWRT');
      rcd_lads_shp_dbt.atwtb := lics_inbound_utility.get_variable('ATWTB');
      rcd_lads_shp_dbt.ewahr := lics_inbound_utility.get_number('EWAHR',null);

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
      if rcd_lads_shp_dbt.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DBT.TKNUM');
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

      insert into lads_shp_dbt
         (tknum,
          dlvseq,
          ditseq,
          dngseq,
          dbtseq,
          atinn,
          atnam,
          atbez,
          atwrt,
          atwtb,
          ewahr)
      values
         (rcd_lads_shp_dbt.tknum,
          rcd_lads_shp_dbt.dlvseq,
          rcd_lads_shp_dbt.ditseq,
          rcd_lads_shp_dbt.dngseq,
          rcd_lads_shp_dbt.dbtseq,
          rcd_lads_shp_dbt.atinn,
          rcd_lads_shp_dbt.atnam,
          rcd_lads_shp_dbt.atbez,
          rcd_lads_shp_dbt.atwrt,
          rcd_lads_shp_dbt.atwtb,
          rcd_lads_shp_dbt.ewahr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dbt;

   /**************************************************/
   /* This procedure performs the record DRF routine */
   /**************************************************/
   procedure process_record_drf(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DRF', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_drf.tknum := rcd_lads_shp_dit.tknum;
      rcd_lads_shp_drf.dlvseq := rcd_lads_shp_dit.dlvseq;
      rcd_lads_shp_drf.ditseq := rcd_lads_shp_dit.ditseq;
      rcd_lads_shp_drf.drfseq := rcd_lads_shp_drf.drfseq + 1;
      rcd_lads_shp_drf.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_shp_drf.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_shp_drf.itmnr := lics_inbound_utility.get_variable('ITMNR');
      rcd_lads_shp_drf.datum := lics_inbound_utility.get_variable('DATUM');

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
      if rcd_lads_shp_drf.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DRF.TKNUM');
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

      insert into lads_shp_drf
         (tknum,
          dlvseq,
          ditseq,
          drfseq,
          qualf,
          belnr,
          itmnr,
          datum)
      values
         (rcd_lads_shp_drf.tknum,
          rcd_lads_shp_drf.dlvseq,
          rcd_lads_shp_drf.ditseq,
          rcd_lads_shp_drf.drfseq,
          rcd_lads_shp_drf.qualf,
          rcd_lads_shp_drf.belnr,
          rcd_lads_shp_drf.itmnr,
          rcd_lads_shp_drf.datum);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_drf;

   /**************************************************/
   /* This procedure performs the record DHU routine */
   /**************************************************/
   procedure process_record_dhu(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DHU', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_dhu.tknum := rcd_lads_shp_dlv.tknum;
      rcd_lads_shp_dhu.dlvseq := rcd_lads_shp_dlv.dlvseq;
      rcd_lads_shp_dhu.dhuseq := rcd_lads_shp_dhu.dhuseq + 1;
      rcd_lads_shp_dhu.exidv := lics_inbound_utility.get_variable('EXIDV');
      rcd_lads_shp_dhu.brgew := lics_inbound_utility.get_number('BRGEW',null);
      rcd_lads_shp_dhu.gweim := lics_inbound_utility.get_variable('GWEIM');
      rcd_lads_shp_dhu.btvol := lics_inbound_utility.get_number('BTVOL',null);
      rcd_lads_shp_dhu.volem := lics_inbound_utility.get_variable('VOLEM');
      rcd_lads_shp_dhu.laeng := lics_inbound_utility.get_number('LAENG',null);
      rcd_lads_shp_dhu.breit := lics_inbound_utility.get_number('BREIT',null);
      rcd_lads_shp_dhu.hoehe := lics_inbound_utility.get_number('HOEHE',null);
      rcd_lads_shp_dhu.meabm := lics_inbound_utility.get_variable('MEABM');
      rcd_lads_shp_dhu.inhalt := lics_inbound_utility.get_variable('INHALT');
      rcd_lads_shp_dhu.farzt := lics_inbound_utility.get_number('FARZT',null);
      rcd_lads_shp_dhu.fareh := lics_inbound_utility.get_variable('FAREH');
      rcd_lads_shp_dhu.entfe := lics_inbound_utility.get_number('ENTFE',null);
      rcd_lads_shp_dhu.ehent := lics_inbound_utility.get_variable('EHENT');
      rcd_lads_shp_dhu.exidv2 := lics_inbound_utility.get_variable('EXIDV2');
      rcd_lads_shp_dhu.landt := lics_inbound_utility.get_variable('LANDT');
      rcd_lads_shp_dhu.move_status := lics_inbound_utility.get_variable('MOVE_STATUS');
      rcd_lads_shp_dhu.packvorschr := lics_inbound_utility.get_variable('PACKVORSCHR');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_shp_dhi.dhiseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_shp_dhu.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DHU.TKNUM');
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

      insert into lads_shp_dhu
         (tknum,
          dlvseq,
          dhuseq,
          exidv,
          brgew,
          gweim,
          btvol,
          volem,
          laeng,
          breit,
          hoehe,
          meabm,
          inhalt,
          farzt,
          fareh,
          entfe,
          ehent,
          exidv2,
          landt,
          move_status,
          packvorschr)
      values
         (rcd_lads_shp_dhu.tknum,
          rcd_lads_shp_dhu.dlvseq,
          rcd_lads_shp_dhu.dhuseq,
          rcd_lads_shp_dhu.exidv,
          rcd_lads_shp_dhu.brgew,
          rcd_lads_shp_dhu.gweim,
          rcd_lads_shp_dhu.btvol,
          rcd_lads_shp_dhu.volem,
          rcd_lads_shp_dhu.laeng,
          rcd_lads_shp_dhu.breit,
          rcd_lads_shp_dhu.hoehe,
          rcd_lads_shp_dhu.meabm,
          rcd_lads_shp_dhu.inhalt,
          rcd_lads_shp_dhu.farzt,
          rcd_lads_shp_dhu.fareh,
          rcd_lads_shp_dhu.entfe,
          rcd_lads_shp_dhu.ehent,
          rcd_lads_shp_dhu.exidv2,
          rcd_lads_shp_dhu.landt,
          rcd_lads_shp_dhu.move_status,
          rcd_lads_shp_dhu.packvorschr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dhu;

   /**************************************************/
   /* This procedure performs the record DHI routine */
   /**************************************************/
   procedure process_record_dhi(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DHI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_shp_dhi.tknum := rcd_lads_shp_dhu.tknum;
      rcd_lads_shp_dhi.dlvseq := rcd_lads_shp_dhu.dlvseq;
      rcd_lads_shp_dhi.dhuseq := rcd_lads_shp_dhu.dhuseq;
      rcd_lads_shp_dhi.dhiseq := rcd_lads_shp_dhi.dhiseq + 1;
      rcd_lads_shp_dhi.velin := lics_inbound_utility.get_variable('VELIN');
      rcd_lads_shp_dhi.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_lads_shp_dhi.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_shp_dhi.exidv := lics_inbound_utility.get_variable('EXIDV');

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
      if rcd_lads_shp_dhi.tknum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DHI.TKNUM');
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

      insert into lads_shp_dhi
         (tknum,
          dlvseq,
          dhuseq,
          dhiseq,
          velin,
          vbeln,
          posnr,
          exidv)
      values
         (rcd_lads_shp_dhi.tknum,
          rcd_lads_shp_dhi.dlvseq,
          rcd_lads_shp_dhi.dhuseq,
          rcd_lads_shp_dhi.dhiseq,
          rcd_lads_shp_dhi.velin,
          rcd_lads_shp_dhi.vbeln,
          rcd_lads_shp_dhi.posnr,
          rcd_lads_shp_dhi.exidv);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dhi;

end lads_atllad14;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad14 for lads_app.lads_atllad14;
grant execute on lads_atllad14 to lics_app;
