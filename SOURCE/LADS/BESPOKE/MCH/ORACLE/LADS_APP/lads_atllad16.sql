create or replace package lads_atllad16 as
/*****************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad16
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad16 - Inbound Delivery Interface

 NOTES
 -----
 1. The delivery is NOT acknowledged in LADS. The acknowledgement comes from
    the warehouse management system.
 2. The field LADS_DEL_HDR.MESFCT has 4 status'. They are :
       null : IDOC first send
       RSD  : IDOC resend
       PCK  : Delivery = Picked
       POD  : Delivery = Proof of Delivery received (final status)

    The logic ensures the status change from RSD -> PCK -> POD is enforced, and
    does not allow resetting of the field with a prior value. ie. PCK cannot be set
    to RSD.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/02   Linden Glen    Added logic to maintain LADS_DEL_HDR.MESFCT
                          as 'PCK' once set.
 2006/03   Linden Glen    MOD: combine STPPOD (POD) and SHPORD (Delivery) IDOCs
                               into single set of LADS_DEL_xxx tables.
 2006/04   Linden Glen    ADD: allow LADS_DEL_HDR.MESFCT to change (only in this sequence)
                               from RSD -> PCK -> POD.
 2006/06   Linden Glen    MOD: Include HIPOS and POSNR on LADS_DEL_POD and remove MATNR
 2006/06   Linden Glen    ADD: HIEVW column
 2008/05   Trevor Keon    Added calls to monitor before and after procedure

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad16;

create or replace package body lads_atllad16 as

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
   procedure process_record_add(par_record in varchar2);
   procedure process_record_adl(par_record in varchar2);
   procedure process_record_tim(par_record in varchar2);
   procedure process_record_htx(par_record in varchar2);
   procedure process_record_htp(par_record in varchar2);
   procedure process_record_rte(par_record in varchar2);
   procedure process_record_stg(par_record in varchar2);
   procedure process_record_nod(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);
   procedure process_record_pod(par_record in varchar2);
   procedure process_record_int(par_record in varchar2);
   procedure process_record_irf(par_record in varchar2);
   procedure process_record_erf(par_record in varchar2);
   procedure process_record_dtx(par_record in varchar2);
   procedure process_record_dtp(par_record in varchar2);
   procedure process_record_huh(par_record in varchar2);
   procedure process_record_huc(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_ctl_mescod varchar2(3);
   var_ctl_mesfct varchar2(3);
   var_ctl_mestyp varchar2(30);
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_del_hdr lads_del_hdr%rowtype;
   rcd_lads_del_add lads_del_add%rowtype;
   rcd_lads_del_adl lads_del_adl%rowtype;
   rcd_lads_del_tim lads_del_tim%rowtype;
   rcd_lads_del_htx lads_del_htx%rowtype;
   rcd_lads_del_htp lads_del_htp%rowtype;
   rcd_lads_del_rte lads_del_rte%rowtype;
   rcd_lads_del_stg lads_del_stg%rowtype;
   rcd_lads_del_nod lads_del_nod%rowtype;
   rcd_lads_del_det lads_del_det%rowtype;
   rcd_lads_del_pod lads_del_pod%rowtype;
   rcd_lads_del_int lads_del_int%rowtype;
   rcd_lads_del_irf lads_del_irf%rowtype;
   rcd_lads_del_erf lads_del_erf%rowtype;
   rcd_lads_del_dtx lads_del_dtx%rowtype;
   rcd_lads_del_dtp lads_del_dtp%rowtype;
   rcd_lads_del_huh lads_del_huh%rowtype;
   rcd_lads_del_huc lads_del_huc%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IDOC_MESTYP',30);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','VBELN',10);
      lics_inbound_utility.set_definition('HDR','VSTEL',4);
      lics_inbound_utility.set_definition('HDR','VKORG',4);
      lics_inbound_utility.set_definition('HDR','LSTEL',2);
      lics_inbound_utility.set_definition('HDR','VKBUR',4);
      lics_inbound_utility.set_definition('HDR','LGNUM',3);
      lics_inbound_utility.set_definition('HDR','ABLAD',25);
      lics_inbound_utility.set_definition('HDR','INCO1',3);
      lics_inbound_utility.set_definition('HDR','INCO2',28);
      lics_inbound_utility.set_definition('HDR','ROUTE',6);
      lics_inbound_utility.set_definition('HDR','VSBED',2);
      lics_inbound_utility.set_definition('HDR','BTGEW',17);
      lics_inbound_utility.set_definition('HDR','NTGEW',15);
      lics_inbound_utility.set_definition('HDR','GEWEI',3);
      lics_inbound_utility.set_definition('HDR','VOLUM',15);
      lics_inbound_utility.set_definition('HDR','VOLEH',3);
      lics_inbound_utility.set_definition('HDR','ANZPK',5);
      lics_inbound_utility.set_definition('HDR','BOLNR',35);
      lics_inbound_utility.set_definition('HDR','TRATY',4);
      lics_inbound_utility.set_definition('HDR','TRAID',20);
      lics_inbound_utility.set_definition('HDR','XABLN',10);
      lics_inbound_utility.set_definition('HDR','LIFEX',35);
      lics_inbound_utility.set_definition('HDR','PARID',35);
      lics_inbound_utility.set_definition('HDR','PODAT',8);
      lics_inbound_utility.set_definition('HDR','POTIM',6);
      lics_inbound_utility.set_definition('HDR','VSTEL_BEZ',30);
      lics_inbound_utility.set_definition('HDR','VKORG_BEZ',20);
      lics_inbound_utility.set_definition('HDR','LSTEL_BEZ',20);
      lics_inbound_utility.set_definition('HDR','VKBUR_BEZ',20);
      lics_inbound_utility.set_definition('HDR','LGNUM_BEZ',25);
      lics_inbound_utility.set_definition('HDR','INCO1_BEZ',30);
      lics_inbound_utility.set_definition('HDR','ROUTE_BEZ',40);
      lics_inbound_utility.set_definition('HDR','VSBED_BEZ',20);
      lics_inbound_utility.set_definition('HDR','TRATY_BEZ',20);
      lics_inbound_utility.set_definition('HDR','LFART',4);
      lics_inbound_utility.set_definition('HDR','BZIRK',6);
      lics_inbound_utility.set_definition('HDR','AUTLF',1);
      lics_inbound_utility.set_definition('HDR','LIFSK',2);
      lics_inbound_utility.set_definition('HDR','LPRIO',2);
      lics_inbound_utility.set_definition('HDR','KDGRP',2);
      lics_inbound_utility.set_definition('HDR','BEROT',20);
      lics_inbound_utility.set_definition('HDR','TRAGR',4);
      lics_inbound_utility.set_definition('HDR','TRSPG',2);
      lics_inbound_utility.set_definition('HDR','AULWE',10);
      lics_inbound_utility.set_definition('HDR','LFART_BEZ',20);
      lics_inbound_utility.set_definition('HDR','LPRIO_BEZ',20);
      lics_inbound_utility.set_definition('HDR','BZIRK_BEZ',20);
      lics_inbound_utility.set_definition('HDR','LIFSK_BEZ',20);
      lics_inbound_utility.set_definition('HDR','KDGRP_BEZ',20);
      lics_inbound_utility.set_definition('HDR','TRAGR_BEZ',20);
      lics_inbound_utility.set_definition('HDR','TRSPG_BEZ',20);
      lics_inbound_utility.set_definition('HDR','AULWE_BEZ',40);
      lics_inbound_utility.set_definition('HDR','ZZTARIF',3);
      lics_inbound_utility.set_definition('HDR','WERKS',4);
      lics_inbound_utility.set_definition('HDR','NAME1',30);
      lics_inbound_utility.set_definition('HDR','STRAS',30);
      lics_inbound_utility.set_definition('HDR','PSTLZ',10);
      lics_inbound_utility.set_definition('HDR','ORT01',25);
      lics_inbound_utility.set_definition('HDR','LAND1',3);
      lics_inbound_utility.set_definition('HDR','ZZTARIF1',3);
      lics_inbound_utility.set_definition('HDR','ZZBRGEW',15);
      lics_inbound_utility.set_definition('HDR','ZZWEIGHTUOM',3);
      lics_inbound_utility.set_definition('HDR','ZZPALSPACE',17);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS01',15);
      lics_inbound_utility.set_definition('HDR','ZZMEINS01',3);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS02',15);
      lics_inbound_utility.set_definition('HDR','ZZMEINS02',3);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS03',15);
      lics_inbound_utility.set_definition('HDR','ZZMEINS03',3);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS04',15);
      lics_inbound_utility.set_definition('HDR','ZZMEINS04',3);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS05',15);
      lics_inbound_utility.set_definition('HDR','ZZMEINS05',3);
      lics_inbound_utility.set_definition('HDR','ZZPALSPACE_F',17);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS01_F',15);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS02_F',15);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS03_F',15);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS04_F',15);
      lics_inbound_utility.set_definition('HDR','ZZPALBAS05_F',15);
      lics_inbound_utility.set_definition('HDR','ZZTKNUM',10);
      lics_inbound_utility.set_definition('HDR','ZZEXPECTPB',3);
      lics_inbound_utility.set_definition('HDR','ZZGARANTEEDBPR',3);
      lics_inbound_utility.set_definition('HDR','ZZGROUPBPR',3);
      lics_inbound_utility.set_definition('HDR','ZZORBDPR',3);
      lics_inbound_utility.set_definition('HDR','ZZMANBPR',3);
      lics_inbound_utility.set_definition('HDR','ZZDELBPR',3);
      lics_inbound_utility.set_definition('HDR','ZZPALSPACE_DELIV',17);
      lics_inbound_utility.set_definition('HDR','ZZPALBASE_DEL01',17);
      lics_inbound_utility.set_definition('HDR','ZZPALBASE_DEL02',17);
      lics_inbound_utility.set_definition('HDR','ZZPALBASE_DEL03',17);
      lics_inbound_utility.set_definition('HDR','ZZPALBASE_DEL04',17);
      lics_inbound_utility.set_definition('HDR','ZZPALBASE_DEL05',17);
      lics_inbound_utility.set_definition('HDR','ZZMEINS_DEL01',3);
      lics_inbound_utility.set_definition('HDR','ZZMEINS_DEL02',3);
      lics_inbound_utility.set_definition('HDR','ZZMEINS_DEL03',3);
      lics_inbound_utility.set_definition('HDR','ZZMEINS_DEL04',3);
      lics_inbound_utility.set_definition('HDR','ZZMEINS_DEL05',3);
      lics_inbound_utility.set_definition('HDR','ATWRT1',30);
      lics_inbound_utility.set_definition('HDR','ATWRT2',30);
      lics_inbound_utility.set_definition('HDR','MTIMEFROM',16);
      lics_inbound_utility.set_definition('HDR','MTIMETO',16);
      lics_inbound_utility.set_definition('HDR','ATIMEFROM',16);
      lics_inbound_utility.set_definition('HDR','ATIMETO',16);
      lics_inbound_utility.set_definition('HDR','WERKS2',4);
      lics_inbound_utility.set_definition('HDR','ZZBRGEW_F',15);
      lics_inbound_utility.set_definition('HDR','ZZWEIGHTPAL',15);
      lics_inbound_utility.set_definition('HDR','ZZWEIGHTPAL_F',15);
      /*-*/
      lics_inbound_utility.set_definition('ADD','IDOC_ADD',3);
      lics_inbound_utility.set_definition('ADD','PARTNER_Q',3);
      lics_inbound_utility.set_definition('ADD','ADDRESS_T',1);
      lics_inbound_utility.set_definition('ADD','PARTNER_ID',17);
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
      lics_inbound_utility.set_definition('ADL','IDOC_ADL',3);
      lics_inbound_utility.set_definition('ADL','NATION',1);
      lics_inbound_utility.set_definition('ADL','NAME1',40);
      lics_inbound_utility.set_definition('ADL','NAME2',40);
      lics_inbound_utility.set_definition('ADL','NAME3',40);
      lics_inbound_utility.set_definition('ADL','NAME4',40);
      lics_inbound_utility.set_definition('ADL','NAME_TXT',50);
      lics_inbound_utility.set_definition('ADL','NAME_CO',40);
      lics_inbound_utility.set_definition('ADL','CITY1',40);
      lics_inbound_utility.set_definition('ADL','CITY2',40);
      lics_inbound_utility.set_definition('ADL','CITY_CODE',12);
      lics_inbound_utility.set_definition('ADL','CITYP_CODE',8);
      lics_inbound_utility.set_definition('ADL','HOME_CITY',40);
      lics_inbound_utility.set_definition('ADL','CITYH_CODE',12);
      lics_inbound_utility.set_definition('ADL','CHCKSTATUS',1);
      lics_inbound_utility.set_definition('ADL','REGIOGROUP',8);
      lics_inbound_utility.set_definition('ADL','POST_CODE1',10);
      lics_inbound_utility.set_definition('ADL','POST_CODE2',10);
      lics_inbound_utility.set_definition('ADL','POST_CODE3',10);
      lics_inbound_utility.set_definition('ADL','PCODE1_EXT',10);
      lics_inbound_utility.set_definition('ADL','PCODE2_EXT',10);
      lics_inbound_utility.set_definition('ADL','PCODE3_EXT',10);
      lics_inbound_utility.set_definition('ADL','PO_BOX',10);
      lics_inbound_utility.set_definition('ADL','PO_BOX_NUM',1);
      lics_inbound_utility.set_definition('ADL','PO_BOX_LOC',40);
      lics_inbound_utility.set_definition('ADL','CITY_CODE2',12);
      lics_inbound_utility.set_definition('ADL','PO_BOX_REG',3);
      lics_inbound_utility.set_definition('ADL','PO_BOX_CTY',3);
      lics_inbound_utility.set_definition('ADL','POSTALAREA',15);
      lics_inbound_utility.set_definition('ADL','STREET',60);
      lics_inbound_utility.set_definition('ADL','STREETCODE',12);
      lics_inbound_utility.set_definition('ADL','STREETABBR',2);
      lics_inbound_utility.set_definition('ADL','HOUSE_NUM1',10);
      lics_inbound_utility.set_definition('ADL','HOUSE_NUM2',10);
      lics_inbound_utility.set_definition('ADL','HOUSE_NUM3',10);
      lics_inbound_utility.set_definition('ADL','STR_SUPPL1',40);
      lics_inbound_utility.set_definition('ADL','STR_SUPPL2',40);
      lics_inbound_utility.set_definition('ADL','STR_SUPPL3',40);
      lics_inbound_utility.set_definition('ADL','LOCATION',40);
      lics_inbound_utility.set_definition('ADL','BUILDING',20);
      lics_inbound_utility.set_definition('ADL','FLOOR',10);
      lics_inbound_utility.set_definition('ADL','COUNTRY',3);
      lics_inbound_utility.set_definition('ADL','REGION',3);
      /*-*/
      lics_inbound_utility.set_definition('TIM','IDOC_TIM',3);
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
      lics_inbound_utility.set_definition('TIM','IEDZ',6);
      lics_inbound_utility.set_definition('TIM','TZONE_END',6);
      lics_inbound_utility.set_definition('TIM','VORNR',4);
      lics_inbound_utility.set_definition('TIM','VSTGA',4);
      lics_inbound_utility.set_definition('TIM','VSTGA_BEZ',20);
      lics_inbound_utility.set_definition('TIM','EVENT',10);
      lics_inbound_utility.set_definition('TIM','EVENT_ALI',20);
      lics_inbound_utility.set_definition('TIM','QUALF1',3);
      lics_inbound_utility.set_definition('TIM','VDATU',8);
      /*-*/
      lics_inbound_utility.set_definition('HTX','IDOC_HTX',3);
      lics_inbound_utility.set_definition('HTX','TDOBJECT',10);
      lics_inbound_utility.set_definition('HTX','TDOBNAME',70);
      lics_inbound_utility.set_definition('HTX','TDID',4);
      lics_inbound_utility.set_definition('HTX','TDSPRAS',1);
      lics_inbound_utility.set_definition('HTX','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('HTX','LANGUA_ISO',2);
      /*-*/
      lics_inbound_utility.set_definition('HTP','IDOC_HTP',3);
      lics_inbound_utility.set_definition('HTP','TDFORMAT',2);
      lics_inbound_utility.set_definition('HTP','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('RTE','IDOC_RTE',3);
      lics_inbound_utility.set_definition('RTE','ROUTE',6);
      lics_inbound_utility.set_definition('RTE','VSART',2);
      lics_inbound_utility.set_definition('RTE','VSAVL',2);
      lics_inbound_utility.set_definition('RTE','VSANL',2);
      lics_inbound_utility.set_definition('RTE','ROUID',100);
      lics_inbound_utility.set_definition('RTE','DISTZ',15);
      lics_inbound_utility.set_definition('RTE','MEDST',3);
      lics_inbound_utility.set_definition('RTE','ROUTE_BEZ',40);
      lics_inbound_utility.set_definition('RTE','VSART_BEZ',20);
      lics_inbound_utility.set_definition('RTE','VSAVL_BEZ',20);
      lics_inbound_utility.set_definition('RTE','VSANL_BEZ',20);
      /*-*/
      lics_inbound_utility.set_definition('STG','IDOC_STG',3);
      lics_inbound_utility.set_definition('STG','ABNUM',4);
      lics_inbound_utility.set_definition('STG','ANFRF',3);
      lics_inbound_utility.set_definition('STG','VSART',2);
      lics_inbound_utility.set_definition('STG','DISTZ',15);
      lics_inbound_utility.set_definition('STG','MEDST',3);
      lics_inbound_utility.set_definition('STG','TSTYP',1);
      lics_inbound_utility.set_definition('STG','VSART_BEZ',20);
      /*-*/
      lics_inbound_utility.set_definition('NOD','IDOC_NOD',3);
      lics_inbound_utility.set_definition('NOD','QUALI',3);
      lics_inbound_utility.set_definition('NOD','KNOTE',10);
      lics_inbound_utility.set_definition('NOD','ADRNR',10);
      lics_inbound_utility.set_definition('NOD','VSTEL',4);
      lics_inbound_utility.set_definition('NOD','LSTEL',2);
      lics_inbound_utility.set_definition('NOD','WERKS',4);
      lics_inbound_utility.set_definition('NOD','LGORT',4);
      lics_inbound_utility.set_definition('NOD','KUNNR',10);
      lics_inbound_utility.set_definition('NOD','LIFNR',10);
      lics_inbound_utility.set_definition('NOD','ABLAD',25);
      lics_inbound_utility.set_definition('NOD','LGNUM',3);
      lics_inbound_utility.set_definition('NOD','LGTOR',3);
      lics_inbound_utility.set_definition('NOD','KNOTE_BEZ',30);
      lics_inbound_utility.set_definition('NOD','VSTEL_BEZ',30);
      lics_inbound_utility.set_definition('NOD','LSTEL_BEZ',20);
      lics_inbound_utility.set_definition('NOD','WERKS_BEZ',30);
      lics_inbound_utility.set_definition('NOD','LGORT_BEZ',16);
      lics_inbound_utility.set_definition('NOD','LGNUM_BEZ',25);
      lics_inbound_utility.set_definition('NOD','LGTOR_BEZ',25);
      lics_inbound_utility.set_definition('NOD','PARTNER_Q',3);
      lics_inbound_utility.set_definition('NOD','ADDRES_T',1);
      lics_inbound_utility.set_definition('NOD','PARTNER_ID',17);
      lics_inbound_utility.set_definition('NOD','LANGUAGE',2);
      lics_inbound_utility.set_definition('NOD','FORMOFADDR',15);
      lics_inbound_utility.set_definition('NOD','NAME1',40);
      lics_inbound_utility.set_definition('NOD','NAME2',40);
      lics_inbound_utility.set_definition('NOD','NAME3',40);
      lics_inbound_utility.set_definition('NOD','NAME4',40);
      lics_inbound_utility.set_definition('NOD','NAME_TEXT',50);
      lics_inbound_utility.set_definition('NOD','NAME_CO',40);
      lics_inbound_utility.set_definition('NOD','LOCATION',40);
      lics_inbound_utility.set_definition('NOD','BUILDING',10);
      lics_inbound_utility.set_definition('NOD','FLOOR',10);
      lics_inbound_utility.set_definition('NOD','ROOM',10);
      lics_inbound_utility.set_definition('NOD','STREET1',40);
      lics_inbound_utility.set_definition('NOD','STREET2',40);
      lics_inbound_utility.set_definition('NOD','STREET3',40);
      lics_inbound_utility.set_definition('NOD','HOUSE_SUPL',4);
      lics_inbound_utility.set_definition('NOD','HOUSE_RANG',10);
      lics_inbound_utility.set_definition('NOD','POSTL_COD1',10);
      lics_inbound_utility.set_definition('NOD','POSTL_COD3',10);
      lics_inbound_utility.set_definition('NOD','CITY1',40);
      lics_inbound_utility.set_definition('NOD','CITY2',40);
      lics_inbound_utility.set_definition('NOD','COUNTRY1',3);
      lics_inbound_utility.set_definition('NOD','COUNTRY2',3);
      lics_inbound_utility.set_definition('NOD','REGION',3);
      lics_inbound_utility.set_definition('NOD','COUNTY_COD',3);
      lics_inbound_utility.set_definition('NOD','COUNTY_TXT',25);
      lics_inbound_utility.set_definition('NOD','TZCODE',6);
      lics_inbound_utility.set_definition('NOD','TZDESC',35);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
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
      lics_inbound_utility.set_definition('DET','ZZMEINS01',3);
      lics_inbound_utility.set_definition('DET','ZZPALBAS01_F',15);
      lics_inbound_utility.set_definition('DET','VBELV',10);
      lics_inbound_utility.set_definition('DET','POSNV',6);
      lics_inbound_utility.set_definition('DET','ZZHALFPAL',1);
      lics_inbound_utility.set_definition('DET','ZZSTACKABLE',1);
      lics_inbound_utility.set_definition('DET','ZZNBRHOMPAL',12);
      lics_inbound_utility.set_definition('DET','ZZPALBASE_DELIV',17);
      lics_inbound_utility.set_definition('DET','ZZPALSPACE_DELIV',17);
      lics_inbound_utility.set_definition('DET','ZZMEINS_DELIV',3);
      lics_inbound_utility.set_definition('DET','VALUE1',17);
      lics_inbound_utility.set_definition('DET','ZRSP',17);
      lics_inbound_utility.set_definition('DET','RATE',17);
      lics_inbound_utility.set_definition('DET','KOSTL',10);
      lics_inbound_utility.set_definition('DET','VFDAT1',8);
      lics_inbound_utility.set_definition('DET','VALUE',17);
      lics_inbound_utility.set_definition('DET','ZZBB4',8);
      lics_inbound_utility.set_definition('DET','ZZPI_ID',20);
      lics_inbound_utility.set_definition('DET','INSMK',1);
      lics_inbound_utility.set_definition('DET','SPART1',2);
      lics_inbound_utility.set_definition('DET','LGORT_BEZ',16);
      lics_inbound_utility.set_definition('DET','LADGR_BEZ',20);
      lics_inbound_utility.set_definition('DET','TRAGR_BEZ',20);
      lics_inbound_utility.set_definition('DET','VKBUR_BEZ',20);
      lics_inbound_utility.set_definition('DET','VKGRP_BEZ',20);
      lics_inbound_utility.set_definition('DET','VTWEG_BEZ',20);
      lics_inbound_utility.set_definition('DET','SPART_BEZ',20);
      lics_inbound_utility.set_definition('DET','MFRGR_BEZ',20);
      lics_inbound_utility.set_definition('DET','PSTYV',4);
      lics_inbound_utility.set_definition('DET','MATKL1',9);
      lics_inbound_utility.set_definition('DET','PRODH',18);
      lics_inbound_utility.set_definition('DET','UMVKZ',6);
      lics_inbound_utility.set_definition('DET','UMVKN',6);
      lics_inbound_utility.set_definition('DET','KZTLF',1);
      lics_inbound_utility.set_definition('DET','UEBTK',1);
      lics_inbound_utility.set_definition('DET','UEBTO',5);
      lics_inbound_utility.set_definition('DET','UNTTO',5);
      lics_inbound_utility.set_definition('DET','CHSPL',1);
      lics_inbound_utility.set_definition('DET','XCHBW',1);
      lics_inbound_utility.set_definition('DET','POSAR',1);
      lics_inbound_utility.set_definition('DET','SOBKZ',1);
      lics_inbound_utility.set_definition('DET','PCKPF',1);
      lics_inbound_utility.set_definition('DET','MAGRV',4);
      lics_inbound_utility.set_definition('DET','SHKZG',1);
      lics_inbound_utility.set_definition('DET','KOQUI',1);
      lics_inbound_utility.set_definition('DET','AKTNR',10);
      lics_inbound_utility.set_definition('DET','KZUMW',1);
      lics_inbound_utility.set_definition('DET','KVGR1',3);
      lics_inbound_utility.set_definition('DET','KVGR2',3);
      lics_inbound_utility.set_definition('DET','KVGR3',3);
      lics_inbound_utility.set_definition('DET','KVGR4',3);
      lics_inbound_utility.set_definition('DET','KVGR5',3);
      lics_inbound_utility.set_definition('DET','MVGR1',3);
      lics_inbound_utility.set_definition('DET','MVGR2',3);
      lics_inbound_utility.set_definition('DET','MVGR3',3);
      lics_inbound_utility.set_definition('DET','MVGR4',3);
      lics_inbound_utility.set_definition('DET','MVGR5',3);
      lics_inbound_utility.set_definition('DET','PSTYV_BEZ',20);
      lics_inbound_utility.set_definition('DET','MATKL_BEZ',20);
      lics_inbound_utility.set_definition('DET','PRODH_BEZ',20);
      lics_inbound_utility.set_definition('DET','WERKS_BEZ',30);
      lics_inbound_utility.set_definition('DET','KVGR1_BEZ',20);
      lics_inbound_utility.set_definition('DET','KVGR2_BEZ',20);
      lics_inbound_utility.set_definition('DET','KVGR3_BEZ',20);
      lics_inbound_utility.set_definition('DET','KVGR4_BEZ',20);
      lics_inbound_utility.set_definition('DET','KVGR5_BEZ',20);
      lics_inbound_utility.set_definition('DET','MVGR1_BEZ',40);
      lics_inbound_utility.set_definition('DET','MVGR2_BEZ',40);
      lics_inbound_utility.set_definition('DET','MVGR3_BEZ',40);
      lics_inbound_utility.set_definition('DET','MVGR4_BEZ',40);
      lics_inbound_utility.set_definition('DET','MVGR5_BEZ',40);
      /*-*/
      lics_inbound_utility.set_definition('POD','IDOC_POD',3);
      lics_inbound_utility.set_definition('POD','GRUND',4);
      lics_inbound_utility.set_definition('POD','PODMG',15);
      lics_inbound_utility.set_definition('POD','LFIMG_DIFF',15);
      lics_inbound_utility.set_definition('POD','VRKME',3);
      lics_inbound_utility.set_definition('POD','LGMNG_DIFF',15);
      lics_inbound_utility.set_definition('POD','MEINS',3);
      /*-*/
      lics_inbound_utility.set_definition('INT','IDOC_INT',3);
      lics_inbound_utility.set_definition('INT','ATINN',10);
      lics_inbound_utility.set_definition('INT','ATNAM',30);
      lics_inbound_utility.set_definition('INT','ATBEZ',30);
      lics_inbound_utility.set_definition('INT','ATWRT',30);
      lics_inbound_utility.set_definition('INT','ATWTB',30);
      lics_inbound_utility.set_definition('INT','EWAHR',24);
      /*-*/
      lics_inbound_utility.set_definition('IRF','IDOC_IRF',3);
      lics_inbound_utility.set_definition('IRF','QUALF',1);
      lics_inbound_utility.set_definition('IRF','BELNR',35);
      lics_inbound_utility.set_definition('IRF','POSNR',6);
      lics_inbound_utility.set_definition('IRF','DATUM',8);
      lics_inbound_utility.set_definition('IRF','DOCTYPE',4);
      lics_inbound_utility.set_definition('IRF','REASON',3);
      /*-*/
      lics_inbound_utility.set_definition('ERF','IDOC_ERF',3);
      lics_inbound_utility.set_definition('ERF','QUALI',3);
      lics_inbound_utility.set_definition('ERF','BSTNR',35);
      lics_inbound_utility.set_definition('ERF','BSTDT',8);
      lics_inbound_utility.set_definition('ERF','BSARK',4);
      lics_inbound_utility.set_definition('ERF','IHREZ',12);
      lics_inbound_utility.set_definition('ERF','POSEX',6);
      lics_inbound_utility.set_definition('ERF','BSARK_BEZ',20);
      /*-*/
      lics_inbound_utility.set_definition('DTX','IDOC_DTX',3);
      lics_inbound_utility.set_definition('DTX','TDOBJECT',10);
      lics_inbound_utility.set_definition('DTX','TDOBNAME',70);
      lics_inbound_utility.set_definition('DTX','TDID',4);
      lics_inbound_utility.set_definition('DTX','TDSPRAS',1);
      lics_inbound_utility.set_definition('DTX','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('DTX','LANGUA_ISO',2);
      /*-*/
      lics_inbound_utility.set_definition('DTP','IDOC_DTP',3);
      lics_inbound_utility.set_definition('DTP','TDFORMAT',2);
      lics_inbound_utility.set_definition('DTP','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('HUH','IDOC_HUH',3);
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
      lics_inbound_utility.set_definition('HUC','IDOC_HUC',3);
      lics_inbound_utility.set_definition('HUC','VELIN',1);
      lics_inbound_utility.set_definition('HUC','VBELN1',10);
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

      if (var_record_identifier = 'CTL') then
         process_record_ctl(par_record);
      else

         case var_ctl_mestyp
            when 'SHPORD' then
               case var_record_identifier
                  when 'HDR' then process_record_hdr(par_record);
                  when 'ADD' then process_record_add(par_record);
                  when 'ADL' then process_record_adl(par_record);
                  when 'TIM' then process_record_tim(par_record);
                  when 'HTX' then process_record_htx(par_record);
                  when 'HTP' then process_record_htp(par_record);
                  when 'RTE' then process_record_rte(par_record);
                  when 'STG' then process_record_stg(par_record);
                  when 'NOD' then process_record_nod(par_record);
                  when 'DET' then process_record_det(par_record);
                  when 'POD' then null;
                  when 'INT' then process_record_int(par_record);
                  when 'IRF' then process_record_irf(par_record);
                  when 'ERF' then process_record_erf(par_record);
                  when 'DTX' then process_record_dtx(par_record);
                  when 'DTP' then process_record_dtp(par_record);
                  when 'HUH' then process_record_huh(par_record);
                  when 'HUC' then process_record_huc(par_record);
                  else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
               end case;
            when 'STPPOD' then
               case var_record_identifier
                  when 'HDR' then process_record_hdr(par_record);
                  when 'ADD' then null;
                  when 'ADL' then null;
                  when 'TIM' then null;
                  when 'HTX' then null;
                  when 'HTP' then null;
                  when 'RTE' then null;
                  when 'STG' then null;
                  when 'NOD' then null;
                  when 'DET' then process_record_det(par_record);
                  when 'POD' then process_record_pod(par_record);
                  when 'INT' then null;
                  when 'IRF' then null;
                  when 'ERF' then null;
                  when 'DTX' then null;
                  when 'DTP' then null;
                  when 'HUH' then null;
                  when 'HUC' then null;
                  else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
               end case;
            else raise_application_error(-20000, 'IDOC Message Type (' || var_ctl_mestyp || ') not recognised');
         end case;
      end if;

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
      con_ack_group constant varchar2(32) := 'LADS_IDOC_ACK';
      con_ack_code constant varchar2(32) := 'ATLLAD16';
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

         if (var_ctl_mestyp = 'SHPORD') then
            begin
               lads_atllad16_monitor.execute_before(rcd_lads_del_hdr.vbeln);
            exception
               when others then
                  lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
            end;
         end if;

         commit;
         
         if (var_ctl_mestyp = 'SHPORD') then
            begin
               lads_atllad16_monitor.execute_after(rcd_lads_del_hdr.vbeln);
            exception
               when others then
                  lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
            end;
         end if;
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
      var_ctl_mestyp := lics_inbound_utility.get_variable('IDOC_MESTYP');

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
      cursor csr_lads_del_hdr_01 is
         select
            t01.vbeln,
            t01.del_idoc_number,
            t01.del_idoc_timestamp,
            t01.pod_idoc_number,
            t01.pod_idoc_timestamp,
            t01.mesfct
         from lads_del_hdr t01
         where t01.vbeln = rcd_lads_del_hdr.vbeln;
      rcd_lads_del_hdr_01 csr_lads_del_hdr_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('HDR', par_record);

      if (var_ctl_mestyp = 'SHPORD') then

         /*-*/
         /* Retrieve field values
         /*-*/
         rcd_lads_del_hdr.vbeln := lics_inbound_utility.get_variable('VBELN');
         rcd_lads_del_hdr.vstel := lics_inbound_utility.get_variable('VSTEL');
         rcd_lads_del_hdr.vkorg := lics_inbound_utility.get_variable('VKORG');
         rcd_lads_del_hdr.lstel := lics_inbound_utility.get_variable('LSTEL');
         rcd_lads_del_hdr.vkbur := lics_inbound_utility.get_variable('VKBUR');
         rcd_lads_del_hdr.lgnum := lics_inbound_utility.get_variable('LGNUM');
         rcd_lads_del_hdr.ablad := lics_inbound_utility.get_variable('ABLAD');
         rcd_lads_del_hdr.inco1 := lics_inbound_utility.get_variable('INCO1');
         rcd_lads_del_hdr.inco2 := lics_inbound_utility.get_variable('INCO2');
         rcd_lads_del_hdr.route := lics_inbound_utility.get_variable('ROUTE');
         rcd_lads_del_hdr.vsbed := lics_inbound_utility.get_variable('VSBED');
         rcd_lads_del_hdr.btgew := lics_inbound_utility.get_number('BTGEW',null);
         rcd_lads_del_hdr.ntgew := lics_inbound_utility.get_number('NTGEW',null);
         rcd_lads_del_hdr.gewei := lics_inbound_utility.get_variable('GEWEI');
         rcd_lads_del_hdr.volum := lics_inbound_utility.get_number('VOLUM',null);
         rcd_lads_del_hdr.voleh := lics_inbound_utility.get_variable('VOLEH');
         rcd_lads_del_hdr.anzpk := lics_inbound_utility.get_number('ANZPK',null);
         rcd_lads_del_hdr.bolnr := lics_inbound_utility.get_variable('BOLNR');
         rcd_lads_del_hdr.traty := lics_inbound_utility.get_variable('TRATY');
         rcd_lads_del_hdr.traid := lics_inbound_utility.get_variable('TRAID');
         rcd_lads_del_hdr.xabln := lics_inbound_utility.get_variable('XABLN');
         rcd_lads_del_hdr.lifex := lics_inbound_utility.get_variable('LIFEX');
         rcd_lads_del_hdr.parid := lics_inbound_utility.get_variable('PARID');
         rcd_lads_del_hdr.podat := lics_inbound_utility.get_variable('PODAT');
         rcd_lads_del_hdr.potim := lics_inbound_utility.get_variable('POTIM');
         rcd_lads_del_hdr.vstel_bez := lics_inbound_utility.get_variable('VSTEL_BEZ');
         rcd_lads_del_hdr.vkorg_bez := lics_inbound_utility.get_variable('VKORG_BEZ');
         rcd_lads_del_hdr.lstel_bez := lics_inbound_utility.get_variable('LSTEL_BEZ');
         rcd_lads_del_hdr.vkbur_bez := lics_inbound_utility.get_variable('VKBUR_BEZ');
         rcd_lads_del_hdr.lgnum_bez := lics_inbound_utility.get_variable('LGNUM_BEZ');
         rcd_lads_del_hdr.inco1_bez := lics_inbound_utility.get_variable('INCO1_BEZ');
         rcd_lads_del_hdr.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
         rcd_lads_del_hdr.vsbed_bez := lics_inbound_utility.get_variable('VSBED_BEZ');
         rcd_lads_del_hdr.traty_bez := lics_inbound_utility.get_variable('TRATY_BEZ');
         rcd_lads_del_hdr.lfart := lics_inbound_utility.get_variable('LFART');
         rcd_lads_del_hdr.bzirk := lics_inbound_utility.get_variable('BZIRK');
         rcd_lads_del_hdr.autlf := lics_inbound_utility.get_variable('AUTLF');
         rcd_lads_del_hdr.lifsk := lics_inbound_utility.get_variable('LIFSK');
         rcd_lads_del_hdr.lprio := lics_inbound_utility.get_number('LPRIO',null);
         rcd_lads_del_hdr.kdgrp := lics_inbound_utility.get_variable('KDGRP');
         rcd_lads_del_hdr.berot := lics_inbound_utility.get_variable('BEROT');
         rcd_lads_del_hdr.tragr := lics_inbound_utility.get_variable('TRAGR');
         rcd_lads_del_hdr.trspg := lics_inbound_utility.get_variable('TRSPG');
         rcd_lads_del_hdr.aulwe := lics_inbound_utility.get_variable('AULWE');
         rcd_lads_del_hdr.lfart_bez := lics_inbound_utility.get_variable('LFART_BEZ');
         rcd_lads_del_hdr.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
         rcd_lads_del_hdr.bzirk_bez := lics_inbound_utility.get_variable('BZIRK_BEZ');
         rcd_lads_del_hdr.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
         rcd_lads_del_hdr.kdgrp_bez := lics_inbound_utility.get_variable('KDGRP_BEZ');
         rcd_lads_del_hdr.tragr_bez := lics_inbound_utility.get_variable('TRAGR_BEZ');
         rcd_lads_del_hdr.trspg_bez := lics_inbound_utility.get_variable('TRSPG_BEZ');
         rcd_lads_del_hdr.aulwe_bez := lics_inbound_utility.get_variable('AULWE_BEZ');
         rcd_lads_del_hdr.zztarif := lics_inbound_utility.get_variable('ZZTARIF');
         rcd_lads_del_hdr.werks := lics_inbound_utility.get_variable('WERKS');
         rcd_lads_del_hdr.name1 := lics_inbound_utility.get_variable('NAME1');
         rcd_lads_del_hdr.stras := lics_inbound_utility.get_variable('STRAS');
         rcd_lads_del_hdr.pstlz := lics_inbound_utility.get_variable('PSTLZ');
         rcd_lads_del_hdr.ort01 := lics_inbound_utility.get_variable('ORT01');
         rcd_lads_del_hdr.land1 := lics_inbound_utility.get_variable('LAND1');
         rcd_lads_del_hdr.zztarif1 := lics_inbound_utility.get_variable('ZZTARIF1');
         rcd_lads_del_hdr.zzbrgew := lics_inbound_utility.get_number('ZZBRGEW',null);
         rcd_lads_del_hdr.zzweightuom := lics_inbound_utility.get_variable('ZZWEIGHTUOM');
         rcd_lads_del_hdr.zzpalspace := lics_inbound_utility.get_number('ZZPALSPACE',null);
         rcd_lads_del_hdr.zzpalbas01 := lics_inbound_utility.get_number('ZZPALBAS01',null);
         rcd_lads_del_hdr.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
         rcd_lads_del_hdr.zzpalbas02 := lics_inbound_utility.get_number('ZZPALBAS02',null);
         rcd_lads_del_hdr.zzmeins02 := lics_inbound_utility.get_variable('ZZMEINS02');
         rcd_lads_del_hdr.zzpalbas03 := lics_inbound_utility.get_number('ZZPALBAS03',null);
         rcd_lads_del_hdr.zzmeins03 := lics_inbound_utility.get_variable('ZZMEINS03');
         rcd_lads_del_hdr.zzpalbas04 := lics_inbound_utility.get_number('ZZPALBAS04',null);
         rcd_lads_del_hdr.zzmeins04 := lics_inbound_utility.get_variable('ZZMEINS04');
         rcd_lads_del_hdr.zzpalbas05 := lics_inbound_utility.get_number('ZZPALBAS05',null);
         rcd_lads_del_hdr.zzmeins05 := lics_inbound_utility.get_variable('ZZMEINS05');
         rcd_lads_del_hdr.zzpalspace_f := lics_inbound_utility.get_number('ZZPALSPACE_F',null);
         rcd_lads_del_hdr.zzpalbas01_f := lics_inbound_utility.get_number('ZZPALBAS01_F',null);
         rcd_lads_del_hdr.zzpalbas02_f := lics_inbound_utility.get_number('ZZPALBAS02_F',null);
         rcd_lads_del_hdr.zzpalbas03_f := lics_inbound_utility.get_number('ZZPALBAS03_F',null);
         rcd_lads_del_hdr.zzpalbas04_f := lics_inbound_utility.get_number('ZZPALBAS04_F',null);
         rcd_lads_del_hdr.zzpalbas05_f := lics_inbound_utility.get_number('ZZPALBAS05_F',null);
         rcd_lads_del_hdr.zztknum := lics_inbound_utility.get_variable('ZZTKNUM');
         rcd_lads_del_hdr.zzexpectpb := lics_inbound_utility.get_variable('ZZEXPECTPB');
         rcd_lads_del_hdr.zzgaranteedbpr := lics_inbound_utility.get_variable('ZZGARANTEEDBPR');
         rcd_lads_del_hdr.zzgroupbpr := lics_inbound_utility.get_variable('ZZGROUPBPR');
         rcd_lads_del_hdr.zzorbdpr := lics_inbound_utility.get_variable('ZZORBDPR');
         rcd_lads_del_hdr.zzmanbpr := lics_inbound_utility.get_variable('ZZMANBPR');
         rcd_lads_del_hdr.zzdelbpr := lics_inbound_utility.get_variable('ZZDELBPR');
         rcd_lads_del_hdr.zzpalspace_deliv := lics_inbound_utility.get_number('ZZPALSPACE_DELIV',null);
         rcd_lads_del_hdr.zzpalbase_del01 := lics_inbound_utility.get_number('ZZPALBASE_DEL01',null);
         rcd_lads_del_hdr.zzpalbase_del02 := lics_inbound_utility.get_number('ZZPALBASE_DEL02',null);
         rcd_lads_del_hdr.zzpalbase_del03 := lics_inbound_utility.get_number('ZZPALBASE_DEL03',null);
         rcd_lads_del_hdr.zzpalbase_del04 := lics_inbound_utility.get_number('ZZPALBASE_DEL04',null);
         rcd_lads_del_hdr.zzpalbase_del05 := lics_inbound_utility.get_number('ZZPALBASE_DEL05',null);
         rcd_lads_del_hdr.zzmeins_del01 := lics_inbound_utility.get_variable('ZZMEINS_DEL01');
         rcd_lads_del_hdr.zzmeins_del02 := lics_inbound_utility.get_variable('ZZMEINS_DEL02');
         rcd_lads_del_hdr.zzmeins_del03 := lics_inbound_utility.get_variable('ZZMEINS_DEL03');
         rcd_lads_del_hdr.zzmeins_del04 := lics_inbound_utility.get_variable('ZZMEINS_DEL04');
         rcd_lads_del_hdr.zzmeins_del05 := lics_inbound_utility.get_variable('ZZMEINS_DEL05');
         rcd_lads_del_hdr.atwrt1 := lics_inbound_utility.get_variable('ATWRT1');
         rcd_lads_del_hdr.atwrt2 := lics_inbound_utility.get_variable('ATWRT2');
         rcd_lads_del_hdr.mtimefrom := lics_inbound_utility.get_variable('MTIMEFROM');
         rcd_lads_del_hdr.mtimeto := lics_inbound_utility.get_variable('MTIMETO');
         rcd_lads_del_hdr.atimefrom := lics_inbound_utility.get_variable('ATIMEFROM');
         rcd_lads_del_hdr.atimeto := lics_inbound_utility.get_variable('ATIMETO');
         rcd_lads_del_hdr.werks2 := lics_inbound_utility.get_variable('WERKS2');
         rcd_lads_del_hdr.zzbrgew_f := lics_inbound_utility.get_number('ZZBRGEW_F',null);
         rcd_lads_del_hdr.zzweightpal := lics_inbound_utility.get_number('ZZWEIGHTPAL',null);
         rcd_lads_del_hdr.zzweightpal_f := lics_inbound_utility.get_number('ZZWEIGHTPAL_F',null);
         rcd_lads_del_hdr.mescod := var_ctl_mescod;
         rcd_lads_del_hdr.mesfct := var_ctl_mesfct;
         rcd_lads_del_hdr.del_idoc_name := rcd_lads_control.idoc_name;
         rcd_lads_del_hdr.del_idoc_number := rcd_lads_control.idoc_number;
         rcd_lads_del_hdr.del_idoc_timestamp := rcd_lads_control.idoc_timestamp;
         rcd_lads_del_hdr.del_lads_date := sysdate;
         rcd_lads_del_hdr.lads_status := '1';

         /*-*/
         /* Retrieve exceptions raised
         /*-*/
         if lics_inbound_utility.has_errors = true then
            var_trn_error := true;
         end if;

         /*-*/
         /* Reset child sequences
         /*-*/
         rcd_lads_del_add.addseq := 0;
         rcd_lads_del_tim.timseq := 0;
         rcd_lads_del_htx.htxseq := 0;
         rcd_lads_del_rte.rteseq := 0;
         rcd_lads_del_det.detseq := 0;
         rcd_lads_del_huh.huhseq := 0;

         /*----------------------------------------*/
         /* VALIDATION - Validate the field values */
         /*----------------------------------------*/

         /*-*/
         /* Validate the primary keys
         /*-*/
         if rcd_lads_del_hdr.vbeln is null then
            lics_inbound_utility.add_exception('Missing Primary Key - HDR.VBELN');
            var_trn_error := true;
         end if;

         /*-*/
         /* Validate the IDOC sequence when primary key supplied
         /*-*/
         if not(rcd_lads_del_hdr.vbeln is null) then
            var_exists := true;
            open csr_lads_del_hdr_01;
            fetch csr_lads_del_hdr_01 into rcd_lads_del_hdr_01;
            if csr_lads_del_hdr_01%notfound then
               var_exists := false;
            else

               /*-*/
               /* CASE MESFCT = 'POD' : cannot be changed - must remain POD
               /* CASE MESFCT = 'PCK' : can only change to POD or remain PCK
               /*-*/
               case rcd_lads_del_hdr_01.mesfct
                  when 'POD' then rcd_lads_del_hdr.mesfct := 'POD';
                  when 'PCK' then
                     if (rcd_lads_del_hdr.mesfct not in ('PCK','POD')) then
                        rcd_lads_del_hdr.mesfct := rcd_lads_del_hdr_01.mesfct;
                     end if;
                  else null;
               end case;

            end if;
            close csr_lads_del_hdr_01;

            if var_exists = true then
               if rcd_lads_del_hdr.del_idoc_timestamp > nvl(rcd_lads_del_hdr_01.del_idoc_timestamp,'00000000000000') then
                  delete from lads_del_huc where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_huh where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_dtp where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_dtx where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_erf where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_irf where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_int where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_det where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_nod where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_stg where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_rte where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_htp where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_htx where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_tim where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_adl where vbeln = rcd_lads_del_hdr.vbeln;
                  delete from lads_del_add where vbeln = rcd_lads_del_hdr.vbeln;
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
         update lads_del_hdr set
            vstel = rcd_lads_del_hdr.vstel,
            vkorg = rcd_lads_del_hdr.vkorg,
            lstel = rcd_lads_del_hdr.lstel,
            vkbur = rcd_lads_del_hdr.vkbur,
            lgnum = rcd_lads_del_hdr.lgnum,
            ablad = rcd_lads_del_hdr.ablad,
            inco1 = rcd_lads_del_hdr.inco1,
            inco2 = rcd_lads_del_hdr.inco2,
            route = rcd_lads_del_hdr.route,
            vsbed = rcd_lads_del_hdr.vsbed,
            btgew = rcd_lads_del_hdr.btgew,
            ntgew = rcd_lads_del_hdr.ntgew,
            gewei = rcd_lads_del_hdr.gewei,
            volum = rcd_lads_del_hdr.volum,
            voleh = rcd_lads_del_hdr.voleh,
            anzpk = rcd_lads_del_hdr.anzpk,
            bolnr = rcd_lads_del_hdr.bolnr,
            traty = rcd_lads_del_hdr.traty,
            traid = rcd_lads_del_hdr.traid,
            xabln = rcd_lads_del_hdr.xabln,
            lifex = rcd_lads_del_hdr.lifex,
            parid = rcd_lads_del_hdr.parid,
            podat = rcd_lads_del_hdr.podat,
            potim = rcd_lads_del_hdr.potim,
            vstel_bez = rcd_lads_del_hdr.vstel_bez,
            vkorg_bez = rcd_lads_del_hdr.vkorg_bez,
            lstel_bez = rcd_lads_del_hdr.lstel_bez,
            vkbur_bez = rcd_lads_del_hdr.vkbur_bez,
            lgnum_bez = rcd_lads_del_hdr.lgnum_bez,
            inco1_bez = rcd_lads_del_hdr.inco1_bez,
            route_bez = rcd_lads_del_hdr.route_bez,
            vsbed_bez = rcd_lads_del_hdr.vsbed_bez,
            traty_bez = rcd_lads_del_hdr.traty_bez,
            lfart = rcd_lads_del_hdr.lfart,
            bzirk = rcd_lads_del_hdr.bzirk,
            autlf = rcd_lads_del_hdr.autlf,
            lifsk = rcd_lads_del_hdr.lifsk,
            lprio = rcd_lads_del_hdr.lprio,
            kdgrp = rcd_lads_del_hdr.kdgrp,
            berot = rcd_lads_del_hdr.berot,
            tragr = rcd_lads_del_hdr.tragr,
            trspg = rcd_lads_del_hdr.trspg,
            aulwe = rcd_lads_del_hdr.aulwe,
            lfart_bez = rcd_lads_del_hdr.lfart_bez,
            lprio_bez = rcd_lads_del_hdr.lprio_bez,
            bzirk_bez = rcd_lads_del_hdr.bzirk_bez,
            lifsk_bez = rcd_lads_del_hdr.lifsk_bez,
            kdgrp_bez = rcd_lads_del_hdr.kdgrp_bez,
            tragr_bez = rcd_lads_del_hdr.tragr_bez,
            trspg_bez = rcd_lads_del_hdr.trspg_bez,
            aulwe_bez = rcd_lads_del_hdr.aulwe_bez,
            zztarif = rcd_lads_del_hdr.zztarif,
            werks = rcd_lads_del_hdr.werks,
            name1 = rcd_lads_del_hdr.name1,
            stras = rcd_lads_del_hdr.stras,
            pstlz = rcd_lads_del_hdr.pstlz,
            ort01 = rcd_lads_del_hdr.ort01,
            land1 = rcd_lads_del_hdr.land1,
            zztarif1 = rcd_lads_del_hdr.zztarif1,
            zzbrgew = rcd_lads_del_hdr.zzbrgew,
            zzweightuom = rcd_lads_del_hdr.zzweightuom,
            zzpalspace = rcd_lads_del_hdr.zzpalspace,
            zzpalbas01 = rcd_lads_del_hdr.zzpalbas01,
            zzmeins01 = rcd_lads_del_hdr.zzmeins01,
            zzpalbas02 = rcd_lads_del_hdr.zzpalbas02,
            zzmeins02 = rcd_lads_del_hdr.zzmeins02,
            zzpalbas03 = rcd_lads_del_hdr.zzpalbas03,
            zzmeins03 = rcd_lads_del_hdr.zzmeins03,
            zzpalbas04 = rcd_lads_del_hdr.zzpalbas04,
            zzmeins04 = rcd_lads_del_hdr.zzmeins04,
            zzpalbas05 = rcd_lads_del_hdr.zzpalbas05,
            zzmeins05 = rcd_lads_del_hdr.zzmeins05,
            zzpalspace_f = rcd_lads_del_hdr.zzpalspace_f,
            zzpalbas01_f = rcd_lads_del_hdr.zzpalbas01_f,
            zzpalbas02_f = rcd_lads_del_hdr.zzpalbas02_f,
            zzpalbas03_f = rcd_lads_del_hdr.zzpalbas03_f,
            zzpalbas04_f = rcd_lads_del_hdr.zzpalbas04_f,
            zzpalbas05_f = rcd_lads_del_hdr.zzpalbas05_f,
            zztknum = rcd_lads_del_hdr.zztknum,
            zzexpectpb = rcd_lads_del_hdr.zzexpectpb,
            zzgaranteedbpr = rcd_lads_del_hdr.zzgaranteedbpr,
            zzgroupbpr = rcd_lads_del_hdr.zzgroupbpr,
            zzorbdpr = rcd_lads_del_hdr.zzorbdpr,
            zzmanbpr = rcd_lads_del_hdr.zzmanbpr,
            zzdelbpr = rcd_lads_del_hdr.zzdelbpr,
            zzpalspace_deliv = rcd_lads_del_hdr.zzpalspace_deliv,
            zzpalbase_del01 = rcd_lads_del_hdr.zzpalbase_del01,
            zzpalbase_del02 = rcd_lads_del_hdr.zzpalbase_del02,
            zzpalbase_del03 = rcd_lads_del_hdr.zzpalbase_del03,
            zzpalbase_del04 = rcd_lads_del_hdr.zzpalbase_del04,
            zzpalbase_del05 = rcd_lads_del_hdr.zzpalbase_del05,
            zzmeins_del01 = rcd_lads_del_hdr.zzmeins_del01,
            zzmeins_del02 = rcd_lads_del_hdr.zzmeins_del02,
            zzmeins_del03 = rcd_lads_del_hdr.zzmeins_del03,
            zzmeins_del04 = rcd_lads_del_hdr.zzmeins_del04,
            zzmeins_del05 = rcd_lads_del_hdr.zzmeins_del05,
            atwrt1 = rcd_lads_del_hdr.atwrt1,
            atwrt2 = rcd_lads_del_hdr.atwrt2,
            mtimefrom = rcd_lads_del_hdr.mtimefrom,
            mtimeto = rcd_lads_del_hdr.mtimeto,
            atimefrom = rcd_lads_del_hdr.atimefrom,
            atimeto = rcd_lads_del_hdr.atimeto,
            werks2 = rcd_lads_del_hdr.werks2,
            zzbrgew_f = rcd_lads_del_hdr.zzbrgew_f,
            zzweightpal = rcd_lads_del_hdr.zzweightpal,
            zzweightpal_f = rcd_lads_del_hdr.zzweightpal_f,
            mescod = rcd_lads_del_hdr.mescod,
            mesfct = rcd_lads_del_hdr.mesfct,
            del_idoc_name = rcd_lads_del_hdr.del_idoc_name,
            del_idoc_number = rcd_lads_del_hdr.del_idoc_number,
            del_idoc_timestamp = rcd_lads_del_hdr.del_idoc_timestamp,
            del_lads_date = rcd_lads_del_hdr.del_lads_date,
            lads_status = rcd_lads_del_hdr.lads_status
         where vbeln = rcd_lads_del_hdr.vbeln;
         if sql%notfound then
            insert into lads_del_hdr
               (vbeln,
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
                zztarif,
                werks,
                name1,
                stras,
                pstlz,
                ort01,
                land1,
                zztarif1,
                zzbrgew,
                zzweightuom,
                zzpalspace,
                zzpalbas01,
                zzmeins01,
                zzpalbas02,
                zzmeins02,
                zzpalbas03,
                zzmeins03,
                zzpalbas04,
                zzmeins04,
                zzpalbas05,
                zzmeins05,
                zzpalspace_f,
                zzpalbas01_f,
                zzpalbas02_f,
                zzpalbas03_f,
                zzpalbas04_f,
                zzpalbas05_f,
                zztknum,
                zzexpectpb,
                zzgaranteedbpr,
                zzgroupbpr,
                zzorbdpr,
                zzmanbpr,
                zzdelbpr,
                zzpalspace_deliv,
                zzpalbase_del01,
                zzpalbase_del02,
                zzpalbase_del03,
                zzpalbase_del04,
                zzpalbase_del05,
                zzmeins_del01,
                zzmeins_del02,
                zzmeins_del03,
                zzmeins_del04,
                zzmeins_del05,
                atwrt1,
                atwrt2,
                mtimefrom,
                mtimeto,
                atimefrom,
                atimeto,
                werks2,
                zzbrgew_f,
                zzweightpal,
                zzweightpal_f,
                mescod,
                mesfct,
                del_idoc_name,
                del_idoc_number,
                del_idoc_timestamp,
                del_lads_date,
                lads_status)
            values
               (rcd_lads_del_hdr.vbeln,
                rcd_lads_del_hdr.vstel,
                rcd_lads_del_hdr.vkorg,
                rcd_lads_del_hdr.lstel,
                rcd_lads_del_hdr.vkbur,
                rcd_lads_del_hdr.lgnum,
                rcd_lads_del_hdr.ablad,
                rcd_lads_del_hdr.inco1,
                rcd_lads_del_hdr.inco2,
                rcd_lads_del_hdr.route,
                rcd_lads_del_hdr.vsbed,
                rcd_lads_del_hdr.btgew,
                rcd_lads_del_hdr.ntgew,
                rcd_lads_del_hdr.gewei,
                rcd_lads_del_hdr.volum,
                rcd_lads_del_hdr.voleh,
                rcd_lads_del_hdr.anzpk,
                rcd_lads_del_hdr.bolnr,
                rcd_lads_del_hdr.traty,
                rcd_lads_del_hdr.traid,
                rcd_lads_del_hdr.xabln,
                rcd_lads_del_hdr.lifex,
                rcd_lads_del_hdr.parid,
                rcd_lads_del_hdr.podat,
                rcd_lads_del_hdr.potim,
                rcd_lads_del_hdr.vstel_bez,
                rcd_lads_del_hdr.vkorg_bez,
                rcd_lads_del_hdr.lstel_bez,
                rcd_lads_del_hdr.vkbur_bez,
                rcd_lads_del_hdr.lgnum_bez,
                rcd_lads_del_hdr.inco1_bez,
                rcd_lads_del_hdr.route_bez,
                rcd_lads_del_hdr.vsbed_bez,
                rcd_lads_del_hdr.traty_bez,
                rcd_lads_del_hdr.lfart,
                rcd_lads_del_hdr.bzirk,
                rcd_lads_del_hdr.autlf,
                rcd_lads_del_hdr.lifsk,
                rcd_lads_del_hdr.lprio,
                rcd_lads_del_hdr.kdgrp,
                rcd_lads_del_hdr.berot,
                rcd_lads_del_hdr.tragr,
                rcd_lads_del_hdr.trspg,
                rcd_lads_del_hdr.aulwe,
                rcd_lads_del_hdr.lfart_bez,
                rcd_lads_del_hdr.lprio_bez,
                rcd_lads_del_hdr.bzirk_bez,
                rcd_lads_del_hdr.lifsk_bez,
                rcd_lads_del_hdr.kdgrp_bez,
                rcd_lads_del_hdr.tragr_bez,
                rcd_lads_del_hdr.trspg_bez,
                rcd_lads_del_hdr.aulwe_bez,
                rcd_lads_del_hdr.zztarif,
                rcd_lads_del_hdr.werks,
                rcd_lads_del_hdr.name1,
                rcd_lads_del_hdr.stras,
                rcd_lads_del_hdr.pstlz,
                rcd_lads_del_hdr.ort01,
                rcd_lads_del_hdr.land1,
                rcd_lads_del_hdr.zztarif1,
                rcd_lads_del_hdr.zzbrgew,
                rcd_lads_del_hdr.zzweightuom,
                rcd_lads_del_hdr.zzpalspace,
                rcd_lads_del_hdr.zzpalbas01,
                rcd_lads_del_hdr.zzmeins01,
                rcd_lads_del_hdr.zzpalbas02,
                rcd_lads_del_hdr.zzmeins02,
                rcd_lads_del_hdr.zzpalbas03,
                rcd_lads_del_hdr.zzmeins03,
                rcd_lads_del_hdr.zzpalbas04,
                rcd_lads_del_hdr.zzmeins04,
                rcd_lads_del_hdr.zzpalbas05,
                rcd_lads_del_hdr.zzmeins05,
                rcd_lads_del_hdr.zzpalspace_f,
                rcd_lads_del_hdr.zzpalbas01_f,
                rcd_lads_del_hdr.zzpalbas02_f,
                rcd_lads_del_hdr.zzpalbas03_f,
                rcd_lads_del_hdr.zzpalbas04_f,
                rcd_lads_del_hdr.zzpalbas05_f,
                rcd_lads_del_hdr.zztknum,
                rcd_lads_del_hdr.zzexpectpb,
                rcd_lads_del_hdr.zzgaranteedbpr,
                rcd_lads_del_hdr.zzgroupbpr,
                rcd_lads_del_hdr.zzorbdpr,
                rcd_lads_del_hdr.zzmanbpr,
                rcd_lads_del_hdr.zzdelbpr,
                rcd_lads_del_hdr.zzpalspace_deliv,
                rcd_lads_del_hdr.zzpalbase_del01,
                rcd_lads_del_hdr.zzpalbase_del02,
                rcd_lads_del_hdr.zzpalbase_del03,
                rcd_lads_del_hdr.zzpalbase_del04,
                rcd_lads_del_hdr.zzpalbase_del05,
                rcd_lads_del_hdr.zzmeins_del01,
                rcd_lads_del_hdr.zzmeins_del02,
                rcd_lads_del_hdr.zzmeins_del03,
                rcd_lads_del_hdr.zzmeins_del04,
                rcd_lads_del_hdr.zzmeins_del05,
                rcd_lads_del_hdr.atwrt1,
                rcd_lads_del_hdr.atwrt2,
                rcd_lads_del_hdr.mtimefrom,
                rcd_lads_del_hdr.mtimeto,
                rcd_lads_del_hdr.atimefrom,
                rcd_lads_del_hdr.atimeto,
                rcd_lads_del_hdr.werks2,
                rcd_lads_del_hdr.zzbrgew_f,
                rcd_lads_del_hdr.zzweightpal,
                rcd_lads_del_hdr.zzweightpal_f,
                rcd_lads_del_hdr.mescod,
                rcd_lads_del_hdr.mesfct,
                rcd_lads_del_hdr.del_idoc_name,
                rcd_lads_del_hdr.del_idoc_number,
                rcd_lads_del_hdr.del_idoc_timestamp,
                rcd_lads_del_hdr.del_lads_date,
                rcd_lads_del_hdr.lads_status);
         end if;

      else

         /*-*/
         /* Retrieve field values
         /*-*/
         rcd_lads_del_hdr.vbeln := lics_inbound_utility.get_variable('VBELN');
         rcd_lads_del_hdr.pod_idoc_name := rcd_lads_control.idoc_name;
         rcd_lads_del_hdr.pod_idoc_number := rcd_lads_control.idoc_number;
         rcd_lads_del_hdr.pod_idoc_timestamp := rcd_lads_control.idoc_timestamp;
         rcd_lads_del_hdr.pod_lads_date := sysdate;
         rcd_lads_del_hdr.lads_status := '1';


         /*-*/
         /* Retrieve exceptions raised
         /*-*/
         if lics_inbound_utility.has_errors = true then
            var_trn_error := true;
         end if;

         /*-*/
         /* Reset child sequences
         /*-*/
         rcd_lads_del_pod.podseq := 0;

         /*----------------------------------------*/
         /* VALIDATION - Validate the field values */
         /*----------------------------------------*/

         /*-*/
         /* Validate the primary keys
         /*-*/
         if rcd_lads_del_hdr.vbeln is null then
            lics_inbound_utility.add_exception('Missing Primary Key - HDR.VBELN');
            var_trn_error := true;
         end if;

         /*-*/
         /* Validate the IDOC sequence when primary key supplied
         /*-*/
         if not(rcd_lads_del_hdr.vbeln is null) then
            var_exists := true;
            open csr_lads_del_hdr_01;
            fetch csr_lads_del_hdr_01 into rcd_lads_del_hdr_01;
            if csr_lads_del_hdr_01%notfound then
               var_exists := false;
               rcd_lads_del_hdr.lads_status := '4';
            end if;
            close csr_lads_del_hdr_01;

            if var_exists = true then
               if rcd_lads_del_hdr.pod_idoc_timestamp > nvl(rcd_lads_del_hdr_01.pod_idoc_timestamp,'00000000000000') then
                  delete from lads_del_pod where vbeln = rcd_lads_del_hdr.vbeln;
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
         update lads_del_hdr set
            pod_idoc_name = rcd_lads_del_hdr.pod_idoc_name,
            pod_idoc_number = rcd_lads_del_hdr.pod_idoc_number,
            pod_idoc_timestamp = rcd_lads_del_hdr.pod_idoc_timestamp,
            pod_lads_date = rcd_lads_del_hdr.pod_lads_date,
            lads_status = rcd_lads_del_hdr.lads_status
         where vbeln = rcd_lads_del_hdr.vbeln;
         if sql%notfound then
            insert into lads_del_hdr
               (vbeln,
                pod_idoc_name,
                pod_idoc_number,
                pod_idoc_timestamp,
                pod_lads_date,
                lads_status)
            values
               (rcd_lads_del_hdr.vbeln,
                rcd_lads_del_hdr.pod_idoc_name,
                rcd_lads_del_hdr.pod_idoc_number,
                rcd_lads_del_hdr.pod_idoc_timestamp,
                rcd_lads_del_hdr.pod_lads_date,
                rcd_lads_del_hdr.lads_status);
         end if;
      end if;


   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

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
      rcd_lads_del_add.vbeln := rcd_lads_del_hdr.vbeln;
      rcd_lads_del_add.addseq := rcd_lads_del_add.addseq + 1;
      rcd_lads_del_add.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_del_add.address_t := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_lads_del_add.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_del_add.language := lics_inbound_utility.get_variable('LANGUAGE');
      rcd_lads_del_add.formofaddr := lics_inbound_utility.get_variable('FORMOFADDR');
      rcd_lads_del_add.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_del_add.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_del_add.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_del_add.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_del_add.name_text := lics_inbound_utility.get_variable('NAME_TEXT');
      rcd_lads_del_add.name_co := lics_inbound_utility.get_variable('NAME_CO');
      rcd_lads_del_add.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_del_add.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_del_add.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_del_add.room := lics_inbound_utility.get_variable('ROOM');
      rcd_lads_del_add.street1 := lics_inbound_utility.get_variable('STREET1');
      rcd_lads_del_add.street2 := lics_inbound_utility.get_variable('STREET2');
      rcd_lads_del_add.street3 := lics_inbound_utility.get_variable('STREET3');
      rcd_lads_del_add.house_supl := lics_inbound_utility.get_variable('HOUSE_SUPL');
      rcd_lads_del_add.house_rang := lics_inbound_utility.get_variable('HOUSE_RANG');
      rcd_lads_del_add.postl_cod1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_lads_del_add.postl_cod3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_lads_del_add.postl_area := lics_inbound_utility.get_variable('POSTL_AREA');
      rcd_lads_del_add.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_del_add.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_del_add.postl_pbox := lics_inbound_utility.get_variable('POSTL_PBOX');
      rcd_lads_del_add.postl_cod2 := lics_inbound_utility.get_variable('POSTL_COD2');
      rcd_lads_del_add.postl_city := lics_inbound_utility.get_variable('POSTL_CITY');
      rcd_lads_del_add.telephone1 := lics_inbound_utility.get_variable('TELEPHONE1');
      rcd_lads_del_add.telephone2 := lics_inbound_utility.get_variable('TELEPHONE2');
      rcd_lads_del_add.telefax := lics_inbound_utility.get_variable('TELEFAX');
      rcd_lads_del_add.telex := lics_inbound_utility.get_variable('TELEX');
      rcd_lads_del_add.e_mail := lics_inbound_utility.get_variable('E_MAIL');
      rcd_lads_del_add.country1 := lics_inbound_utility.get_variable('COUNTRY1');
      rcd_lads_del_add.country2 := lics_inbound_utility.get_variable('COUNTRY2');
      rcd_lads_del_add.region := lics_inbound_utility.get_variable('REGION');
      rcd_lads_del_add.county_cod := lics_inbound_utility.get_variable('COUNTY_COD');
      rcd_lads_del_add.county_txt := lics_inbound_utility.get_variable('COUNTY_TXT');
      rcd_lads_del_add.tzcode := lics_inbound_utility.get_variable('TZCODE');
      rcd_lads_del_add.tzdesc := lics_inbound_utility.get_variable('TZDESC');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_del_adl.adlseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_del_add.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ADD.VBELN');
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

      insert into lads_del_add
         (vbeln,
          addseq,
          partner_q,
          address_t,
          partner_id,
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
         (rcd_lads_del_add.vbeln,
          rcd_lads_del_add.addseq,
          rcd_lads_del_add.partner_q,
          rcd_lads_del_add.address_t,
          rcd_lads_del_add.partner_id,
          rcd_lads_del_add.language,
          rcd_lads_del_add.formofaddr,
          rcd_lads_del_add.name1,
          rcd_lads_del_add.name2,
          rcd_lads_del_add.name3,
          rcd_lads_del_add.name4,
          rcd_lads_del_add.name_text,
          rcd_lads_del_add.name_co,
          rcd_lads_del_add.location,
          rcd_lads_del_add.building,
          rcd_lads_del_add.floor,
          rcd_lads_del_add.room,
          rcd_lads_del_add.street1,
          rcd_lads_del_add.street2,
          rcd_lads_del_add.street3,
          rcd_lads_del_add.house_supl,
          rcd_lads_del_add.house_rang,
          rcd_lads_del_add.postl_cod1,
          rcd_lads_del_add.postl_cod3,
          rcd_lads_del_add.postl_area,
          rcd_lads_del_add.city1,
          rcd_lads_del_add.city2,
          rcd_lads_del_add.postl_pbox,
          rcd_lads_del_add.postl_cod2,
          rcd_lads_del_add.postl_city,
          rcd_lads_del_add.telephone1,
          rcd_lads_del_add.telephone2,
          rcd_lads_del_add.telefax,
          rcd_lads_del_add.telex,
          rcd_lads_del_add.e_mail,
          rcd_lads_del_add.country1,
          rcd_lads_del_add.country2,
          rcd_lads_del_add.region,
          rcd_lads_del_add.county_cod,
          rcd_lads_del_add.county_txt,
          rcd_lads_del_add.tzcode,
          rcd_lads_del_add.tzdesc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_add;

   /**************************************************/
   /* This procedure performs the record ADL routine */
   /**************************************************/
   procedure process_record_adl(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ADL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_del_adl.vbeln := rcd_lads_del_add.vbeln;
      rcd_lads_del_adl.addseq := rcd_lads_del_add.addseq;
      rcd_lads_del_adl.adlseq := rcd_lads_del_adl.adlseq + 1;
      rcd_lads_del_adl.nation := lics_inbound_utility.get_variable('NATION');
      rcd_lads_del_adl.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_del_adl.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_del_adl.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_del_adl.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_del_adl.name_txt := lics_inbound_utility.get_variable('NAME_TXT');
      rcd_lads_del_adl.name_co := lics_inbound_utility.get_variable('NAME_CO');
      rcd_lads_del_adl.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_del_adl.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_del_adl.city_code := lics_inbound_utility.get_variable('CITY_CODE');
      rcd_lads_del_adl.cityp_code := lics_inbound_utility.get_variable('CITYP_CODE');
      rcd_lads_del_adl.home_city := lics_inbound_utility.get_variable('HOME_CITY');
      rcd_lads_del_adl.cityh_code := lics_inbound_utility.get_variable('CITYH_CODE');
      rcd_lads_del_adl.chckstatus := lics_inbound_utility.get_variable('CHCKSTATUS');
      rcd_lads_del_adl.regiogroup := lics_inbound_utility.get_variable('REGIOGROUP');
      rcd_lads_del_adl.post_code1 := lics_inbound_utility.get_variable('POST_CODE1');
      rcd_lads_del_adl.post_code2 := lics_inbound_utility.get_variable('POST_CODE2');
      rcd_lads_del_adl.post_code3 := lics_inbound_utility.get_variable('POST_CODE3');
      rcd_lads_del_adl.pcode1_ext := lics_inbound_utility.get_variable('PCODE1_EXT');
      rcd_lads_del_adl.pcode2_ext := lics_inbound_utility.get_variable('PCODE2_EXT');
      rcd_lads_del_adl.pcode3_ext := lics_inbound_utility.get_variable('PCODE3_EXT');
      rcd_lads_del_adl.po_box := lics_inbound_utility.get_variable('PO_BOX');
      rcd_lads_del_adl.po_box_num := lics_inbound_utility.get_variable('PO_BOX_NUM');
      rcd_lads_del_adl.po_box_loc := lics_inbound_utility.get_variable('PO_BOX_LOC');
      rcd_lads_del_adl.city_code2 := lics_inbound_utility.get_variable('CITY_CODE2');
      rcd_lads_del_adl.po_box_reg := lics_inbound_utility.get_variable('PO_BOX_REG');
      rcd_lads_del_adl.po_box_cty := lics_inbound_utility.get_variable('PO_BOX_CTY');
      rcd_lads_del_adl.postalarea := lics_inbound_utility.get_variable('POSTALAREA');
      rcd_lads_del_adl.street := lics_inbound_utility.get_variable('STREET');
      rcd_lads_del_adl.streetcode := lics_inbound_utility.get_variable('STREETCODE');
      rcd_lads_del_adl.streetabbr := lics_inbound_utility.get_variable('STREETABBR');
      rcd_lads_del_adl.house_num1 := lics_inbound_utility.get_variable('HOUSE_NUM1');
      rcd_lads_del_adl.house_num2 := lics_inbound_utility.get_variable('HOUSE_NUM2');
      rcd_lads_del_adl.house_num3 := lics_inbound_utility.get_variable('HOUSE_NUM3');
      rcd_lads_del_adl.str_suppl1 := lics_inbound_utility.get_variable('STR_SUPPL1');
      rcd_lads_del_adl.str_suppl2 := lics_inbound_utility.get_variable('STR_SUPPL2');
      rcd_lads_del_adl.str_suppl3 := lics_inbound_utility.get_variable('STR_SUPPL3');
      rcd_lads_del_adl.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_del_adl.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_del_adl.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_del_adl.country := lics_inbound_utility.get_variable('COUNTRY');
      rcd_lads_del_adl.region := lics_inbound_utility.get_variable('REGION');

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
      if rcd_lads_del_adl.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ADL.VBELN');
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

      insert into lads_del_adl
         (vbeln,
          addseq,
          adlseq,
          nation,
          name1,
          name2,
          name3,
          name4,
          name_txt,
          name_co,
          city1,
          city2,
          city_code,
          cityp_code,
          home_city,
          cityh_code,
          chckstatus,
          regiogroup,
          post_code1,
          post_code2,
          post_code3,
          pcode1_ext,
          pcode2_ext,
          pcode3_ext,
          po_box,
          po_box_num,
          po_box_loc,
          city_code2,
          po_box_reg,
          po_box_cty,
          postalarea,
          street,
          streetcode,
          streetabbr,
          house_num1,
          house_num2,
          house_num3,
          str_suppl1,
          str_suppl2,
          str_suppl3,
          location,
          building,
          floor,
          country,
          region)
      values
         (rcd_lads_del_adl.vbeln,
          rcd_lads_del_adl.addseq,
          rcd_lads_del_adl.adlseq,
          rcd_lads_del_adl.nation,
          rcd_lads_del_adl.name1,
          rcd_lads_del_adl.name2,
          rcd_lads_del_adl.name3,
          rcd_lads_del_adl.name4,
          rcd_lads_del_adl.name_txt,
          rcd_lads_del_adl.name_co,
          rcd_lads_del_adl.city1,
          rcd_lads_del_adl.city2,
          rcd_lads_del_adl.city_code,
          rcd_lads_del_adl.cityp_code,
          rcd_lads_del_adl.home_city,
          rcd_lads_del_adl.cityh_code,
          rcd_lads_del_adl.chckstatus,
          rcd_lads_del_adl.regiogroup,
          rcd_lads_del_adl.post_code1,
          rcd_lads_del_adl.post_code2,
          rcd_lads_del_adl.post_code3,
          rcd_lads_del_adl.pcode1_ext,
          rcd_lads_del_adl.pcode2_ext,
          rcd_lads_del_adl.pcode3_ext,
          rcd_lads_del_adl.po_box,
          rcd_lads_del_adl.po_box_num,
          rcd_lads_del_adl.po_box_loc,
          rcd_lads_del_adl.city_code2,
          rcd_lads_del_adl.po_box_reg,
          rcd_lads_del_adl.po_box_cty,
          rcd_lads_del_adl.postalarea,
          rcd_lads_del_adl.street,
          rcd_lads_del_adl.streetcode,
          rcd_lads_del_adl.streetabbr,
          rcd_lads_del_adl.house_num1,
          rcd_lads_del_adl.house_num2,
          rcd_lads_del_adl.house_num3,
          rcd_lads_del_adl.str_suppl1,
          rcd_lads_del_adl.str_suppl2,
          rcd_lads_del_adl.str_suppl3,
          rcd_lads_del_adl.location,
          rcd_lads_del_adl.building,
          rcd_lads_del_adl.floor,
          rcd_lads_del_adl.country,
          rcd_lads_del_adl.region);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_adl;

   /**************************************************/
   /* This procedure performs the record TIM routine */
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
      rcd_lads_del_tim.vbeln := rcd_lads_del_hdr.vbeln;
      rcd_lads_del_tim.timseq := rcd_lads_del_tim.timseq + 1;
      rcd_lads_del_tim.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_del_tim.vstzw := lics_inbound_utility.get_variable('VSTZW');
      rcd_lads_del_tim.vstzw_bez := lics_inbound_utility.get_variable('VSTZW_BEZ');
      rcd_lads_del_tim.ntanf := lics_inbound_utility.get_variable('NTANF');
      rcd_lads_del_tim.ntanz := lics_inbound_utility.get_variable('NTANZ');
      rcd_lads_del_tim.ntend := lics_inbound_utility.get_variable('NTEND');
      rcd_lads_del_tim.ntenz := lics_inbound_utility.get_variable('NTENZ');
      rcd_lads_del_tim.tzone_beg := lics_inbound_utility.get_variable('TZONE_BEG');
      rcd_lads_del_tim.isdd := lics_inbound_utility.get_variable('ISDD');
      rcd_lads_del_tim.isdz := lics_inbound_utility.get_variable('ISDZ');
      rcd_lads_del_tim.iedd := lics_inbound_utility.get_variable('IEDD');
      rcd_lads_del_tim.iedz := lics_inbound_utility.get_variable('IEDZ');
      rcd_lads_del_tim.tzone_end := lics_inbound_utility.get_variable('TZONE_END');
      rcd_lads_del_tim.vornr := lics_inbound_utility.get_variable('VORNR');
      rcd_lads_del_tim.vstga := lics_inbound_utility.get_variable('VSTGA');
      rcd_lads_del_tim.vstga_bez := lics_inbound_utility.get_variable('VSTGA_BEZ');
      rcd_lads_del_tim.event := lics_inbound_utility.get_variable('EVENT');
      rcd_lads_del_tim.event_ali := lics_inbound_utility.get_variable('EVENT_ALI');
      rcd_lads_del_tim.qualf1 := lics_inbound_utility.get_variable('QUALF1');
      rcd_lads_del_tim.vdatu := lics_inbound_utility.get_variable('VDATU');

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
      if rcd_lads_del_tim.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TIM.VBELN');
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

      insert into lads_del_tim
         (vbeln,
          timseq,
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
          qualf1,
          vdatu)
      values
         (rcd_lads_del_tim.vbeln,
          rcd_lads_del_tim.timseq,
          rcd_lads_del_tim.qualf,
          rcd_lads_del_tim.vstzw,
          rcd_lads_del_tim.vstzw_bez,
          rcd_lads_del_tim.ntanf,
          rcd_lads_del_tim.ntanz,
          rcd_lads_del_tim.ntend,
          rcd_lads_del_tim.ntenz,
          rcd_lads_del_tim.tzone_beg,
          rcd_lads_del_tim.isdd,
          rcd_lads_del_tim.isdz,
          rcd_lads_del_tim.iedd,
          rcd_lads_del_tim.iedz,
          rcd_lads_del_tim.tzone_end,
          rcd_lads_del_tim.vornr,
          rcd_lads_del_tim.vstga,
          rcd_lads_del_tim.vstga_bez,
          rcd_lads_del_tim.event,
          rcd_lads_del_tim.event_ali,
          rcd_lads_del_tim.qualf1,
          rcd_lads_del_tim.vdatu);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tim;

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
      rcd_lads_del_htx.vbeln := rcd_lads_del_hdr.vbeln;
      rcd_lads_del_htx.htxseq := rcd_lads_del_htx.htxseq + 1;
      rcd_lads_del_htx.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_del_htx.tdobname := lics_inbound_utility.get_variable('TDOBNAME');
      rcd_lads_del_htx.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_del_htx.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_del_htx.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_del_htx.langua_iso := lics_inbound_utility.get_variable('LANGUA_ISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_del_htp.htpseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_del_htx.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HTX.VBELN');
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

      insert into lads_del_htx
         (vbeln,
          htxseq,
          tdobject,
          tdobname,
          tdid,
          tdspras,
          tdtexttype,
          langua_iso)
      values
         (rcd_lads_del_htx.vbeln,
          rcd_lads_del_htx.htxseq,
          rcd_lads_del_htx.tdobject,
          rcd_lads_del_htx.tdobname,
          rcd_lads_del_htx.tdid,
          rcd_lads_del_htx.tdspras,
          rcd_lads_del_htx.tdtexttype,
          rcd_lads_del_htx.langua_iso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_htx;

   /**************************************************/
   /* This procedure performs the record HTP routine */
   /**************************************************/
   procedure process_record_htp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HTP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_del_htp.vbeln := rcd_lads_del_htx.vbeln;
      rcd_lads_del_htp.htxseq := rcd_lads_del_htx.htxseq;
      rcd_lads_del_htp.htpseq := rcd_lads_del_htp.htpseq + 1;
      rcd_lads_del_htp.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_del_htp.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_del_htp.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HTP.VBELN');
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

      insert into lads_del_htp
         (vbeln,
          htxseq,
          htpseq,
          tdformat,
          tdline)
      values
         (rcd_lads_del_htp.vbeln,
          rcd_lads_del_htp.htxseq,
          rcd_lads_del_htp.htpseq,
          rcd_lads_del_htp.tdformat,
          rcd_lads_del_htp.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_htp;

   /**************************************************/
   /* This procedure performs the record RTE routine */
   /**************************************************/
   procedure process_record_rte(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('RTE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_del_rte.vbeln := rcd_lads_del_hdr.vbeln;
      rcd_lads_del_rte.rteseq := rcd_lads_del_rte.rteseq + 1;
      rcd_lads_del_rte.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_del_rte.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_del_rte.vsavl := lics_inbound_utility.get_variable('VSAVL');
      rcd_lads_del_rte.vsanl := lics_inbound_utility.get_variable('VSANL');
      rcd_lads_del_rte.rouid := lics_inbound_utility.get_variable('ROUID');
      rcd_lads_del_rte.distz := lics_inbound_utility.get_number('DISTZ',null);
      rcd_lads_del_rte.medst := lics_inbound_utility.get_variable('MEDST');
      rcd_lads_del_rte.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_del_rte.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_del_rte.vsavl_bez := lics_inbound_utility.get_variable('VSAVL_BEZ');
      rcd_lads_del_rte.vsanl_bez := lics_inbound_utility.get_variable('VSANL_BEZ');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_del_stg.stgseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_del_rte.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - RTE.VBELN');
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

      insert into lads_del_rte
         (vbeln,
          rteseq,
          route,
          vsart,
          vsavl,
          vsanl,
          rouid,
          distz,
          medst,
          route_bez,
          vsart_bez,
          vsavl_bez,
          vsanl_bez)
      values
         (rcd_lads_del_rte.vbeln,
          rcd_lads_del_rte.rteseq,
          rcd_lads_del_rte.route,
          rcd_lads_del_rte.vsart,
          rcd_lads_del_rte.vsavl,
          rcd_lads_del_rte.vsanl,
          rcd_lads_del_rte.rouid,
          rcd_lads_del_rte.distz,
          rcd_lads_del_rte.medst,
          rcd_lads_del_rte.route_bez,
          rcd_lads_del_rte.vsart_bez,
          rcd_lads_del_rte.vsavl_bez,
          rcd_lads_del_rte.vsanl_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_rte;

   /**************************************************/
   /* This procedure performs the record STG routine */
   /**************************************************/
   procedure process_record_stg(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('STG', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_del_stg.vbeln := rcd_lads_del_rte.vbeln;
      rcd_lads_del_stg.rteseq := rcd_lads_del_rte.rteseq;
      rcd_lads_del_stg.stgseq := rcd_lads_del_stg.stgseq + 1;
      rcd_lads_del_stg.abnum := lics_inbound_utility.get_variable('ABNUM');
      rcd_lads_del_stg.anfrf := lics_inbound_utility.get_variable('ANFRF');
      rcd_lads_del_stg.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_del_stg.distz := lics_inbound_utility.get_number('DISTZ',null);
      rcd_lads_del_stg.medst := lics_inbound_utility.get_variable('MEDST');
      rcd_lads_del_stg.tstyp := lics_inbound_utility.get_variable('TSTYP');
      rcd_lads_del_stg.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_del_nod.nodseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_del_stg.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - STG.VBELN');
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

      insert into lads_del_stg
         (vbeln,
          rteseq,
          stgseq,
          abnum,
          anfrf,
          vsart,
          distz,
          medst,
          tstyp,
          vsart_bez)
      values
         (rcd_lads_del_stg.vbeln,
          rcd_lads_del_stg.rteseq,
          rcd_lads_del_stg.stgseq,
          rcd_lads_del_stg.abnum,
          rcd_lads_del_stg.anfrf,
          rcd_lads_del_stg.vsart,
          rcd_lads_del_stg.distz,
          rcd_lads_del_stg.medst,
          rcd_lads_del_stg.tstyp,
          rcd_lads_del_stg.vsart_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_stg;

   /**************************************************/
   /* This procedure performs the record NOD routine */
   /**************************************************/
   procedure process_record_nod(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('NOD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_del_nod.vbeln := rcd_lads_del_stg.vbeln;
      rcd_lads_del_nod.rteseq := rcd_lads_del_stg.rteseq;
      rcd_lads_del_nod.stgseq := rcd_lads_del_stg.stgseq;
      rcd_lads_del_nod.nodseq := rcd_lads_del_nod.nodseq + 1;
      rcd_lads_del_nod.quali := lics_inbound_utility.get_variable('QUALI');
      rcd_lads_del_nod.knote := lics_inbound_utility.get_variable('KNOTE');
      rcd_lads_del_nod.adrnr := lics_inbound_utility.get_variable('ADRNR');
      rcd_lads_del_nod.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_del_nod.lstel := lics_inbound_utility.get_variable('LSTEL');
      rcd_lads_del_nod.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_del_nod.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_del_nod.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_del_nod.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_del_nod.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_del_nod.lgnum := lics_inbound_utility.get_variable('LGNUM');
      rcd_lads_del_nod.lgtor := lics_inbound_utility.get_variable('LGTOR');
      rcd_lads_del_nod.knote_bez := lics_inbound_utility.get_variable('KNOTE_BEZ');
      rcd_lads_del_nod.vstel_bez := lics_inbound_utility.get_variable('VSTEL_BEZ');
      rcd_lads_del_nod.lstel_bez := lics_inbound_utility.get_variable('LSTEL_BEZ');
      rcd_lads_del_nod.werks_bez := lics_inbound_utility.get_variable('WERKS_BEZ');
      rcd_lads_del_nod.lgort_bez := lics_inbound_utility.get_variable('LGORT_BEZ');
      rcd_lads_del_nod.lgnum_bez := lics_inbound_utility.get_variable('LGNUM_BEZ');
      rcd_lads_del_nod.lgtor_bez := lics_inbound_utility.get_variable('LGTOR_BEZ');
      rcd_lads_del_nod.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_lads_del_nod.addres_t := lics_inbound_utility.get_variable('ADDRES_T');
      rcd_lads_del_nod.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_lads_del_nod.language := lics_inbound_utility.get_variable('LANGUAGE');
      rcd_lads_del_nod.formofaddr := lics_inbound_utility.get_variable('FORMOFADDR');
      rcd_lads_del_nod.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_del_nod.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_del_nod.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_del_nod.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_del_nod.name_text := lics_inbound_utility.get_variable('NAME_TEXT');
      rcd_lads_del_nod.name_co := lics_inbound_utility.get_variable('NAME_CO');
      rcd_lads_del_nod.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_del_nod.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_lads_del_nod.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_lads_del_nod.room := lics_inbound_utility.get_variable('ROOM');
      rcd_lads_del_nod.street1 := lics_inbound_utility.get_variable('STREET1');
      rcd_lads_del_nod.street2 := lics_inbound_utility.get_variable('STREET2');
      rcd_lads_del_nod.street3 := lics_inbound_utility.get_variable('STREET3');
      rcd_lads_del_nod.house_supl := lics_inbound_utility.get_variable('HOUSE_SUPL');
      rcd_lads_del_nod.house_rang := lics_inbound_utility.get_variable('HOUSE_RANG');
      rcd_lads_del_nod.postl_cod1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_lads_del_nod.postl_cod3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_lads_del_nod.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_lads_del_nod.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_lads_del_nod.country1 := lics_inbound_utility.get_variable('COUNTRY1');
      rcd_lads_del_nod.country2 := lics_inbound_utility.get_variable('COUNTRY2');
      rcd_lads_del_nod.region := lics_inbound_utility.get_variable('REGION');
      rcd_lads_del_nod.county_cod := lics_inbound_utility.get_variable('COUNTY_COD');
      rcd_lads_del_nod.county_txt := lics_inbound_utility.get_variable('COUNTY_TXT');
      rcd_lads_del_nod.tzcode := lics_inbound_utility.get_variable('TZCODE');
      rcd_lads_del_nod.tzdesc := lics_inbound_utility.get_variable('TZDESC');

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
      if rcd_lads_del_nod.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - NOD.VBELN');
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

      insert into lads_del_nod
         (vbeln,
          rteseq,
          stgseq,
          nodseq,
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
          knote_bez,
          vstel_bez,
          lstel_bez,
          werks_bez,
          lgort_bez,
          lgnum_bez,
          lgtor_bez,
          partner_q,
          addres_t,
          partner_id,
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
          city1,
          city2,
          country1,
          country2,
          region,
          county_cod,
          county_txt,
          tzcode,
          tzdesc)
      values
         (rcd_lads_del_nod.vbeln,
          rcd_lads_del_nod.rteseq,
          rcd_lads_del_nod.stgseq,
          rcd_lads_del_nod.nodseq,
          rcd_lads_del_nod.quali,
          rcd_lads_del_nod.knote,
          rcd_lads_del_nod.adrnr,
          rcd_lads_del_nod.vstel,
          rcd_lads_del_nod.lstel,
          rcd_lads_del_nod.werks,
          rcd_lads_del_nod.lgort,
          rcd_lads_del_nod.kunnr,
          rcd_lads_del_nod.lifnr,
          rcd_lads_del_nod.ablad,
          rcd_lads_del_nod.lgnum,
          rcd_lads_del_nod.lgtor,
          rcd_lads_del_nod.knote_bez,
          rcd_lads_del_nod.vstel_bez,
          rcd_lads_del_nod.lstel_bez,
          rcd_lads_del_nod.werks_bez,
          rcd_lads_del_nod.lgort_bez,
          rcd_lads_del_nod.lgnum_bez,
          rcd_lads_del_nod.lgtor_bez,
          rcd_lads_del_nod.partner_q,
          rcd_lads_del_nod.addres_t,
          rcd_lads_del_nod.partner_id,
          rcd_lads_del_nod.language,
          rcd_lads_del_nod.formofaddr,
          rcd_lads_del_nod.name1,
          rcd_lads_del_nod.name2,
          rcd_lads_del_nod.name3,
          rcd_lads_del_nod.name4,
          rcd_lads_del_nod.name_text,
          rcd_lads_del_nod.name_co,
          rcd_lads_del_nod.location,
          rcd_lads_del_nod.building,
          rcd_lads_del_nod.floor,
          rcd_lads_del_nod.room,
          rcd_lads_del_nod.street1,
          rcd_lads_del_nod.street2,
          rcd_lads_del_nod.street3,
          rcd_lads_del_nod.house_supl,
          rcd_lads_del_nod.house_rang,
          rcd_lads_del_nod.postl_cod1,
          rcd_lads_del_nod.postl_cod3,
          rcd_lads_del_nod.city1,
          rcd_lads_del_nod.city2,
          rcd_lads_del_nod.country1,
          rcd_lads_del_nod.country2,
          rcd_lads_del_nod.region,
          rcd_lads_del_nod.county_cod,
          rcd_lads_del_nod.county_txt,
          rcd_lads_del_nod.tzcode,
          rcd_lads_del_nod.tzdesc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_nod;

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


      if (var_ctl_mestyp = 'SHPORD') then

         /*-*/
         /* Retrieve field values
         /*-*/
         rcd_lads_del_det.vbeln := rcd_lads_del_hdr.vbeln;
         rcd_lads_del_det.detseq := rcd_lads_del_det.detseq + 1;
         rcd_lads_del_det.posnr := lics_inbound_utility.get_variable('POSNR');
         rcd_lads_del_det.matnr := lics_inbound_utility.get_variable('MATNR');
         rcd_lads_del_det.matwa := lics_inbound_utility.get_variable('MATWA');
         rcd_lads_del_det.arktx := lics_inbound_utility.get_variable('ARKTX');
         rcd_lads_del_det.orktx := lics_inbound_utility.get_variable('ORKTX');
         rcd_lads_del_det.sugrd := lics_inbound_utility.get_variable('SUGRD');
         rcd_lads_del_det.sudru := lics_inbound_utility.get_variable('SUDRU');
         rcd_lads_del_det.matkl := lics_inbound_utility.get_variable('MATKL');
         rcd_lads_del_det.werks := lics_inbound_utility.get_variable('WERKS');
         rcd_lads_del_det.lgort := lics_inbound_utility.get_variable('LGORT');
         rcd_lads_del_det.charg := lics_inbound_utility.get_variable('CHARG');
         rcd_lads_del_det.kdmat := lics_inbound_utility.get_variable('KDMAT');
         rcd_lads_del_det.lfimg := lics_inbound_utility.get_number('LFIMG',null);
         rcd_lads_del_det.vrkme := lics_inbound_utility.get_variable('VRKME');
         rcd_lads_del_det.lgmng := lics_inbound_utility.get_number('LGMNG',null);
         rcd_lads_del_det.meins := lics_inbound_utility.get_variable('MEINS');
         rcd_lads_del_det.ntgew := lics_inbound_utility.get_number('NTGEW',null);
         rcd_lads_del_det.brgew := lics_inbound_utility.get_number('BRGEW',null);
         rcd_lads_del_det.gewei := lics_inbound_utility.get_variable('GEWEI');
         rcd_lads_del_det.volum := lics_inbound_utility.get_number('VOLUM',null);
         rcd_lads_del_det.voleh := lics_inbound_utility.get_variable('VOLEH');
         rcd_lads_del_det.lgpbe := lics_inbound_utility.get_variable('LGPBE');
         rcd_lads_del_det.hipos := lics_inbound_utility.get_variable('HIPOS');
         rcd_lads_del_det.hievw := lics_inbound_utility.get_variable('HIEVW');
         rcd_lads_del_det.ladgr := lics_inbound_utility.get_variable('LADGR');
         rcd_lads_del_det.tragr := lics_inbound_utility.get_variable('TRAGR');
         rcd_lads_del_det.vkbur := lics_inbound_utility.get_variable('VKBUR');
         rcd_lads_del_det.vkgrp := lics_inbound_utility.get_variable('VKGRP');
         rcd_lads_del_det.vtweg := lics_inbound_utility.get_variable('VTWEG');
         rcd_lads_del_det.spart := lics_inbound_utility.get_variable('SPART');
         rcd_lads_del_det.grkor := lics_inbound_utility.get_variable('GRKOR');
         rcd_lads_del_det.ean11 := lics_inbound_utility.get_variable('EAN11');
         rcd_lads_del_det.sernr := lics_inbound_utility.get_variable('SERNR');
         rcd_lads_del_det.aeskd := lics_inbound_utility.get_variable('AESKD');
         rcd_lads_del_det.empst := lics_inbound_utility.get_variable('EMPST');
         rcd_lads_del_det.mfrgr := lics_inbound_utility.get_variable('MFRGR');
         rcd_lads_del_det.vbrst := lics_inbound_utility.get_variable('VBRST');
         rcd_lads_del_det.labnk := lics_inbound_utility.get_variable('LABNK');
         rcd_lads_del_det.abrdt := lics_inbound_utility.get_variable('ABRDT');
         rcd_lads_del_det.mfrpn := lics_inbound_utility.get_variable('MFRPN');
         rcd_lads_del_det.mfrnr := lics_inbound_utility.get_variable('MFRNR');
         rcd_lads_del_det.abrvw := lics_inbound_utility.get_variable('ABRVW');
         rcd_lads_del_det.kdmat35 := lics_inbound_utility.get_variable('KDMAT35');
         rcd_lads_del_det.kannr := lics_inbound_utility.get_variable('KANNR');
         rcd_lads_del_det.posex := lics_inbound_utility.get_variable('POSEX');
         rcd_lads_del_det.lieffz := lics_inbound_utility.get_number('LIEFFZ',null);
         rcd_lads_del_det.usr01 := lics_inbound_utility.get_variable('USR01');
         rcd_lads_del_det.usr02 := lics_inbound_utility.get_variable('USR02');
         rcd_lads_del_det.usr03 := lics_inbound_utility.get_variable('USR03');
         rcd_lads_del_det.usr04 := lics_inbound_utility.get_variable('USR04');
         rcd_lads_del_det.usr05 := lics_inbound_utility.get_variable('USR05');
         rcd_lads_del_det.matnr_external := lics_inbound_utility.get_variable('MATNR_EXTERNAL');
         rcd_lads_del_det.matnr_version := lics_inbound_utility.get_variable('MATNR_VERSION');
         rcd_lads_del_det.matnr_guid := lics_inbound_utility.get_variable('MATNR_GUID');
         rcd_lads_del_det.matwa_external := lics_inbound_utility.get_variable('MATWA_EXTERNAL');
         rcd_lads_del_det.matwa_version := lics_inbound_utility.get_variable('MATWA_VERSION');
         rcd_lads_del_det.matwa_guid := lics_inbound_utility.get_variable('MATWA_GUID');
         rcd_lads_del_det.zudat := lics_inbound_utility.get_variable('ZUDAT');
         rcd_lads_del_det.vfdat := lics_inbound_utility.get_variable('VFDAT');
         rcd_lads_del_det.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
         rcd_lads_del_det.zzpalbas01_f := lics_inbound_utility.get_number('ZZPALBAS01_F',null);
         rcd_lads_del_det.vbelv := lics_inbound_utility.get_variable('VBELV');
         rcd_lads_del_det.posnv := lics_inbound_utility.get_variable('POSNV');
         rcd_lads_del_det.zzhalfpal := lics_inbound_utility.get_variable('ZZHALFPAL');
         rcd_lads_del_det.zzstackable := lics_inbound_utility.get_variable('ZZSTACKABLE');
         rcd_lads_del_det.zznbrhompal := lics_inbound_utility.get_number('ZZNBRHOMPAL',null);
         rcd_lads_del_det.zzpalbase_deliv := lics_inbound_utility.get_number('ZZPALBASE_DELIV',null);
         rcd_lads_del_det.zzpalspace_deliv := lics_inbound_utility.get_number('ZZPALSPACE_DELIV',null);
         rcd_lads_del_det.zzmeins_deliv := lics_inbound_utility.get_variable('ZZMEINS_DELIV');
         rcd_lads_del_det.value1 := lics_inbound_utility.get_number('VALUE1',null);
         rcd_lads_del_det.zrsp := lics_inbound_utility.get_number('ZRSP',null);
         rcd_lads_del_det.rate := lics_inbound_utility.get_number('RATE',null);
         rcd_lads_del_det.kostl := lics_inbound_utility.get_variable('KOSTL');
         rcd_lads_del_det.vfdat1 := lics_inbound_utility.get_variable('VFDAT1');
         rcd_lads_del_det.value := lics_inbound_utility.get_number('VALUE',null);
         rcd_lads_del_det.zzbb4 := lics_inbound_utility.get_variable('ZZBB4');
         rcd_lads_del_det.zzpi_id := lics_inbound_utility.get_variable('ZZPI_ID');
         rcd_lads_del_det.insmk := lics_inbound_utility.get_variable('INSMK');
         rcd_lads_del_det.spart1 := lics_inbound_utility.get_variable('SPART1');
         rcd_lads_del_det.lgort_bez := lics_inbound_utility.get_variable('LGORT_BEZ');
         rcd_lads_del_det.ladgr_bez := lics_inbound_utility.get_variable('LADGR_BEZ');
         rcd_lads_del_det.tragr_bez := lics_inbound_utility.get_variable('TRAGR_BEZ');
         rcd_lads_del_det.vkbur_bez := lics_inbound_utility.get_variable('VKBUR_BEZ');
         rcd_lads_del_det.vkgrp_bez := lics_inbound_utility.get_variable('VKGRP_BEZ');
         rcd_lads_del_det.vtweg_bez := lics_inbound_utility.get_variable('VTWEG_BEZ');
         rcd_lads_del_det.spart_bez := lics_inbound_utility.get_variable('SPART_BEZ');
         rcd_lads_del_det.mfrgr_bez := lics_inbound_utility.get_variable('MFRGR_BEZ');
         rcd_lads_del_det.pstyv := lics_inbound_utility.get_variable('PSTYV');
         rcd_lads_del_det.matkl1 := lics_inbound_utility.get_variable('MATKL1');
         rcd_lads_del_det.prodh := lics_inbound_utility.get_variable('PRODH');
         rcd_lads_del_det.umvkz := lics_inbound_utility.get_number('UMVKZ',null);
         rcd_lads_del_det.umvkn := lics_inbound_utility.get_number('UMVKN',null);
         rcd_lads_del_det.kztlf := lics_inbound_utility.get_variable('KZTLF');
         rcd_lads_del_det.uebtk := lics_inbound_utility.get_variable('UEBTK');
         rcd_lads_del_det.uebto := lics_inbound_utility.get_number('UEBTO',null);
         rcd_lads_del_det.untto := lics_inbound_utility.get_number('UNTTO',null);
         rcd_lads_del_det.chspl := lics_inbound_utility.get_variable('CHSPL');
         rcd_lads_del_det.xchbw := lics_inbound_utility.get_variable('XCHBW');
         rcd_lads_del_det.posar := lics_inbound_utility.get_variable('POSAR');
         rcd_lads_del_det.sobkz := lics_inbound_utility.get_variable('SOBKZ');
         rcd_lads_del_det.pckpf := lics_inbound_utility.get_variable('PCKPF');
         rcd_lads_del_det.magrv := lics_inbound_utility.get_variable('MAGRV');
         rcd_lads_del_det.shkzg := lics_inbound_utility.get_variable('SHKZG');
         rcd_lads_del_det.koqui := lics_inbound_utility.get_variable('KOQUI');
         rcd_lads_del_det.aktnr := lics_inbound_utility.get_variable('AKTNR');
         rcd_lads_del_det.kzumw := lics_inbound_utility.get_variable('KZUMW');
         rcd_lads_del_det.kvgr1 := lics_inbound_utility.get_variable('KVGR1');
         rcd_lads_del_det.kvgr2 := lics_inbound_utility.get_variable('KVGR2');
         rcd_lads_del_det.kvgr3 := lics_inbound_utility.get_variable('KVGR3');
         rcd_lads_del_det.kvgr4 := lics_inbound_utility.get_variable('KVGR4');
         rcd_lads_del_det.kvgr5 := lics_inbound_utility.get_variable('KVGR5');
         rcd_lads_del_det.mvgr1 := lics_inbound_utility.get_variable('MVGR1');
         rcd_lads_del_det.mvgr2 := lics_inbound_utility.get_variable('MVGR2');
         rcd_lads_del_det.mvgr3 := lics_inbound_utility.get_variable('MVGR3');
         rcd_lads_del_det.mvgr4 := lics_inbound_utility.get_variable('MVGR4');
         rcd_lads_del_det.mvgr5 := lics_inbound_utility.get_variable('MVGR5');
         rcd_lads_del_det.pstyv_bez := lics_inbound_utility.get_variable('PSTYV_BEZ');
         rcd_lads_del_det.matkl_bez := lics_inbound_utility.get_variable('MATKL_BEZ');
         rcd_lads_del_det.prodh_bez := lics_inbound_utility.get_variable('PRODH_BEZ');
         rcd_lads_del_det.werks_bez := lics_inbound_utility.get_variable('WERKS_BEZ');
         rcd_lads_del_det.kvgr1_bez := lics_inbound_utility.get_variable('KVGR1_BEZ');
         rcd_lads_del_det.kvgr2_bez := lics_inbound_utility.get_variable('KVGR2_BEZ');
         rcd_lads_del_det.kvgr3_bez := lics_inbound_utility.get_variable('KVGR3_BEZ');
         rcd_lads_del_det.kvgr4_bez := lics_inbound_utility.get_variable('KVGR4_BEZ');
         rcd_lads_del_det.kvgr5_bez := lics_inbound_utility.get_variable('KVGR5_BEZ');
         rcd_lads_del_det.mvgr1_bez := lics_inbound_utility.get_variable('MVGR1_BEZ');
         rcd_lads_del_det.mvgr2_bez := lics_inbound_utility.get_variable('MVGR2_BEZ');
         rcd_lads_del_det.mvgr3_bez := lics_inbound_utility.get_variable('MVGR3_BEZ');
         rcd_lads_del_det.mvgr4_bez := lics_inbound_utility.get_variable('MVGR4_BEZ');
         rcd_lads_del_det.mvgr5_bez := lics_inbound_utility.get_variable('MVGR5_BEZ');

         /*-*/
         /* Retrieve exceptions raised
         /*-*/
         if lics_inbound_utility.has_errors = true then
            var_trn_error := true;
         end if;

         /*-*/
         /* Reset child sequences
         /*-*/
         rcd_lads_del_int.intseq := 0;
         rcd_lads_del_irf.irfseq := 0;
         rcd_lads_del_erf.erfseq := 0;
         rcd_lads_del_dtx.dtxseq := 0;

         /*----------------------------------------*/
         /* VALIDATION - Validate the field values */
         /*----------------------------------------*/

         /*-*/
         /* Validate the primary keys
         /*-*/
         if rcd_lads_del_det.vbeln is null then
            lics_inbound_utility.add_exception('Missing Primary Key - DET.VBELN');
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

         insert into lads_del_det
            (vbeln,
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
             vfdat,
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
             vfdat1,
             value,
             zzbb4,
             zzpi_id,
             insmk,
             spart1,
             lgort_bez,
             ladgr_bez,
             tragr_bez,
             vkbur_bez,
             vkgrp_bez,
             vtweg_bez,
             spart_bez,
             mfrgr_bez,
             pstyv,
             matkl1,
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
             kvgr1,
             kvgr2,
             kvgr3,
             kvgr4,
             kvgr5,
             mvgr1,
             mvgr2,
             mvgr3,
             mvgr4,
             mvgr5,
             pstyv_bez,
             matkl_bez,
             prodh_bez,
             werks_bez,
             kvgr1_bez,
             kvgr2_bez,
             kvgr3_bez,
             kvgr4_bez,
             kvgr5_bez,
             mvgr1_bez,
             mvgr2_bez,
             mvgr3_bez,
             mvgr4_bez,
             mvgr5_bez)
         values
            (rcd_lads_del_det.vbeln,
             rcd_lads_del_det.detseq,
             rcd_lads_del_det.posnr,
             rcd_lads_del_det.matnr,
             rcd_lads_del_det.matwa,
             rcd_lads_del_det.arktx,
             rcd_lads_del_det.orktx,
             rcd_lads_del_det.sugrd,
             rcd_lads_del_det.sudru,
             rcd_lads_del_det.matkl,
             rcd_lads_del_det.werks,
             rcd_lads_del_det.lgort,
             rcd_lads_del_det.charg,
             rcd_lads_del_det.kdmat,
             rcd_lads_del_det.lfimg,
             rcd_lads_del_det.vrkme,
             rcd_lads_del_det.lgmng,
             rcd_lads_del_det.meins,
             rcd_lads_del_det.ntgew,
             rcd_lads_del_det.brgew,
             rcd_lads_del_det.gewei,
             rcd_lads_del_det.volum,
             rcd_lads_del_det.voleh,
             rcd_lads_del_det.lgpbe,
             rcd_lads_del_det.hipos,
             rcd_lads_del_det.hievw,
             rcd_lads_del_det.ladgr,
             rcd_lads_del_det.tragr,
             rcd_lads_del_det.vkbur,
             rcd_lads_del_det.vkgrp,
             rcd_lads_del_det.vtweg,
             rcd_lads_del_det.spart,
             rcd_lads_del_det.grkor,
             rcd_lads_del_det.ean11,
             rcd_lads_del_det.sernr,
             rcd_lads_del_det.aeskd,
             rcd_lads_del_det.empst,
             rcd_lads_del_det.mfrgr,
             rcd_lads_del_det.vbrst,
             rcd_lads_del_det.labnk,
             rcd_lads_del_det.abrdt,
             rcd_lads_del_det.mfrpn,
             rcd_lads_del_det.mfrnr,
             rcd_lads_del_det.abrvw,
             rcd_lads_del_det.kdmat35,
             rcd_lads_del_det.kannr,
             rcd_lads_del_det.posex,
             rcd_lads_del_det.lieffz,
             rcd_lads_del_det.usr01,
             rcd_lads_del_det.usr02,
             rcd_lads_del_det.usr03,
             rcd_lads_del_det.usr04,
             rcd_lads_del_det.usr05,
             rcd_lads_del_det.matnr_external,
             rcd_lads_del_det.matnr_version,
             rcd_lads_del_det.matnr_guid,
             rcd_lads_del_det.matwa_external,
             rcd_lads_del_det.matwa_version,
             rcd_lads_del_det.matwa_guid,
             rcd_lads_del_det.zudat,
             rcd_lads_del_det.vfdat,
             rcd_lads_del_det.zzmeins01,
             rcd_lads_del_det.zzpalbas01_f,
             rcd_lads_del_det.vbelv,
             rcd_lads_del_det.posnv,
             rcd_lads_del_det.zzhalfpal,
             rcd_lads_del_det.zzstackable,
             rcd_lads_del_det.zznbrhompal,
             rcd_lads_del_det.zzpalbase_deliv,
             rcd_lads_del_det.zzpalspace_deliv,
             rcd_lads_del_det.zzmeins_deliv,
             rcd_lads_del_det.value1,
             rcd_lads_del_det.zrsp,
             rcd_lads_del_det.rate,
             rcd_lads_del_det.kostl,
             rcd_lads_del_det.vfdat1,
             rcd_lads_del_det.value,
             rcd_lads_del_det.zzbb4,
             rcd_lads_del_det.zzpi_id,
             rcd_lads_del_det.insmk,
             rcd_lads_del_det.spart1,
             rcd_lads_del_det.lgort_bez,
             rcd_lads_del_det.ladgr_bez,
             rcd_lads_del_det.tragr_bez,
             rcd_lads_del_det.vkbur_bez,
             rcd_lads_del_det.vkgrp_bez,
             rcd_lads_del_det.vtweg_bez,
             rcd_lads_del_det.spart_bez,
             rcd_lads_del_det.mfrgr_bez,
             rcd_lads_del_det.pstyv,
             rcd_lads_del_det.matkl1,
             rcd_lads_del_det.prodh,
             rcd_lads_del_det.umvkz,
             rcd_lads_del_det.umvkn,
             rcd_lads_del_det.kztlf,
             rcd_lads_del_det.uebtk,
             rcd_lads_del_det.uebto,
             rcd_lads_del_det.untto,
             rcd_lads_del_det.chspl,
             rcd_lads_del_det.xchbw,
             rcd_lads_del_det.posar,
             rcd_lads_del_det.sobkz,
             rcd_lads_del_det.pckpf,
             rcd_lads_del_det.magrv,
             rcd_lads_del_det.shkzg,
             rcd_lads_del_det.koqui,
             rcd_lads_del_det.aktnr,
             rcd_lads_del_det.kzumw,
             rcd_lads_del_det.kvgr1,
             rcd_lads_del_det.kvgr2,
             rcd_lads_del_det.kvgr3,
             rcd_lads_del_det.kvgr4,
             rcd_lads_del_det.kvgr5,
             rcd_lads_del_det.mvgr1,
             rcd_lads_del_det.mvgr2,
             rcd_lads_del_det.mvgr3,
             rcd_lads_del_det.mvgr4,
             rcd_lads_del_det.mvgr5,
             rcd_lads_del_det.pstyv_bez,
             rcd_lads_del_det.matkl_bez,
             rcd_lads_del_det.prodh_bez,
             rcd_lads_del_det.werks_bez,
             rcd_lads_del_det.kvgr1_bez,
             rcd_lads_del_det.kvgr2_bez,
             rcd_lads_del_det.kvgr3_bez,
             rcd_lads_del_det.kvgr4_bez,
             rcd_lads_del_det.kvgr5_bez,
             rcd_lads_del_det.mvgr1_bez,
             rcd_lads_del_det.mvgr2_bez,
             rcd_lads_del_det.mvgr3_bez,
             rcd_lads_del_det.mvgr4_bez,
             rcd_lads_del_det.mvgr5_bez);
      else

         /*-*/
         /* Retrieve field values
         /*-*/
         rcd_lads_del_det.posnr := lics_inbound_utility.get_variable('POSNR');
         rcd_lads_del_det.hipos := lics_inbound_utility.get_variable('HIPOS');
         rcd_lads_del_det.hievw := lics_inbound_utility.get_variable('HIEVW');

         /*-*/
         /* Retrieve exceptions raised
         /*-*/
         if lics_inbound_utility.has_errors = true then
            var_trn_error := true;
         end if;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record POD routine */
   /**************************************************/
   procedure process_record_pod(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('POD', par_record);


      if (var_ctl_mestyp = 'STPPOD') then

         /*-*/
         /* Retrieve field values
         /*-*/
         rcd_lads_del_pod.vbeln := rcd_lads_del_hdr.vbeln;
         rcd_lads_del_pod.posnr := rcd_lads_del_det.posnr;
         rcd_lads_del_pod.hipos := rcd_lads_del_det.hipos;
         rcd_lads_del_pod.hievw := rcd_lads_del_det.hievw;
         rcd_lads_del_pod.podseq := rcd_lads_del_pod.podseq + 1;
         rcd_lads_del_pod.grund := lics_inbound_utility.get_variable('GRUND');
         rcd_lads_del_pod.podmg := lics_inbound_utility.get_number('PODMG',null);
         rcd_lads_del_pod.lfimg_diff := lics_inbound_utility.get_number('LFIMG_DIFF',null);
         rcd_lads_del_pod.vrkme := lics_inbound_utility.get_variable('VRKME');
         rcd_lads_del_pod.lgmng_diff := lics_inbound_utility.get_number('LGMNG_DIFF',null);
         rcd_lads_del_pod.meins := lics_inbound_utility.get_variable('MEINS');

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
         if rcd_lads_del_pod.vbeln is null then
            lics_inbound_utility.add_exception('Missing Primary Key - POD.VBELN');
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
         insert into lads_del_pod
            (vbeln,
             posnr,
             hipos,
             hievw,
             podseq,
             grund,
             podmg,
             lfimg_diff,
             vrkme,
             lgmng_diff,
             meins)
         values
            (rcd_lads_del_pod.vbeln,
             rcd_lads_del_pod.posnr,
             rcd_lads_del_pod.hipos,
             rcd_lads_del_pod.hievw,
             rcd_lads_del_pod.podseq,
             rcd_lads_del_pod.grund,
             rcd_lads_del_pod.podmg,
             rcd_lads_del_pod.lfimg_diff,
             rcd_lads_del_pod.vrkme,
             rcd_lads_del_pod.lgmng_diff,
             rcd_lads_del_pod.meins);

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pod;

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
      rcd_lads_del_int.vbeln := rcd_lads_del_det.vbeln;
      rcd_lads_del_int.detseq := rcd_lads_del_det.detseq;
      rcd_lads_del_int.intseq := rcd_lads_del_int.intseq + 1;
      rcd_lads_del_int.atinn := lics_inbound_utility.get_number('ATINN',null);
      rcd_lads_del_int.atnam := lics_inbound_utility.get_variable('ATNAM');
      rcd_lads_del_int.atbez := lics_inbound_utility.get_variable('ATBEZ');
      rcd_lads_del_int.atwrt := lics_inbound_utility.get_variable('ATWRT');
      rcd_lads_del_int.atwtb := lics_inbound_utility.get_variable('ATWTB');
      rcd_lads_del_int.ewahr := lics_inbound_utility.get_number('EWAHR',null);

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
      if rcd_lads_del_int.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - INT.VBELN');
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

      insert into lads_del_int
         (vbeln,
          detseq,
          intseq,
          atinn,
          atnam,
          atbez,
          atwrt,
          atwtb,
          ewahr)
      values
         (rcd_lads_del_int.vbeln,
          rcd_lads_del_int.detseq,
          rcd_lads_del_int.intseq,
          rcd_lads_del_int.atinn,
          rcd_lads_del_int.atnam,
          rcd_lads_del_int.atbez,
          rcd_lads_del_int.atwrt,
          rcd_lads_del_int.atwtb,
          rcd_lads_del_int.ewahr);

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
      rcd_lads_del_irf.vbeln := rcd_lads_del_det.vbeln;
      rcd_lads_del_irf.detseq := rcd_lads_del_det.detseq;
      rcd_lads_del_irf.irfseq := rcd_lads_del_irf.irfseq + 1;
      rcd_lads_del_irf.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_del_irf.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_del_irf.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_del_irf.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_del_irf.doctype := lics_inbound_utility.get_variable('DOCTYPE');
      rcd_lads_del_irf.reason := lics_inbound_utility.get_variable('REASON');

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
      if rcd_lads_del_irf.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - IRF.VBELN');
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

      insert into lads_del_irf
         (vbeln,
          detseq,
          irfseq,
          qualf,
          belnr,
          posnr,
          datum,
          doctype,
          reason)
      values
         (rcd_lads_del_irf.vbeln,
          rcd_lads_del_irf.detseq,
          rcd_lads_del_irf.irfseq,
          rcd_lads_del_irf.qualf,
          rcd_lads_del_irf.belnr,
          rcd_lads_del_irf.posnr,
          rcd_lads_del_irf.datum,
          rcd_lads_del_irf.doctype,
          rcd_lads_del_irf.reason);

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
      rcd_lads_del_erf.vbeln := rcd_lads_del_det.vbeln;
      rcd_lads_del_erf.detseq := rcd_lads_del_det.detseq;
      rcd_lads_del_erf.erfseq := rcd_lads_del_erf.erfseq + 1;
      rcd_lads_del_erf.quali := lics_inbound_utility.get_variable('QUALI');
      rcd_lads_del_erf.bstnr := lics_inbound_utility.get_variable('BSTNR');
      rcd_lads_del_erf.bstdt := lics_inbound_utility.get_variable('BSTDT');
      rcd_lads_del_erf.bsark := lics_inbound_utility.get_variable('BSARK');
      rcd_lads_del_erf.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_del_erf.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_lads_del_erf.bsark_bez := lics_inbound_utility.get_variable('BSARK_BEZ');

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
      if rcd_lads_del_erf.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ERF.VBELN');
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

      insert into lads_del_erf
         (vbeln,
          detseq,
          erfseq,
          quali,
          bstnr,
          bstdt,
          bsark,
          ihrez,
          posex,
          bsark_bez)
      values
         (rcd_lads_del_erf.vbeln,
          rcd_lads_del_erf.detseq,
          rcd_lads_del_erf.erfseq,
          rcd_lads_del_erf.quali,
          rcd_lads_del_erf.bstnr,
          rcd_lads_del_erf.bstdt,
          rcd_lads_del_erf.bsark,
          rcd_lads_del_erf.ihrez,
          rcd_lads_del_erf.posex,
          rcd_lads_del_erf.bsark_bez);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_erf;

   /**************************************************/
   /* This procedure performs the record DTX routine */
   /**************************************************/
   procedure process_record_dtx(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DTX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_del_dtx.vbeln := rcd_lads_del_det.vbeln;
      rcd_lads_del_dtx.detseq := rcd_lads_del_det.detseq;
      rcd_lads_del_dtx.dtxseq := rcd_lads_del_dtx.dtxseq + 1;
      rcd_lads_del_dtx.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_del_dtx.tdobname := lics_inbound_utility.get_variable('TDOBNAME');
      rcd_lads_del_dtx.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_del_dtx.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_del_dtx.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_del_dtx.langua_iso := lics_inbound_utility.get_variable('LANGUA_ISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_del_dtp.dtpseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_del_dtx.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DTX.VBELN');
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

      insert into lads_del_dtx
         (vbeln,
          detseq,
          dtxseq,
          tdobject,
          tdobname,
          tdid,
          tdspras,
          tdtexttype,
          langua_iso)
      values
         (rcd_lads_del_dtx.vbeln,
          rcd_lads_del_dtx.detseq,
          rcd_lads_del_dtx.dtxseq,
          rcd_lads_del_dtx.tdobject,
          rcd_lads_del_dtx.tdobname,
          rcd_lads_del_dtx.tdid,
          rcd_lads_del_dtx.tdspras,
          rcd_lads_del_dtx.tdtexttype,
          rcd_lads_del_dtx.langua_iso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dtx;

   /**************************************************/
   /* This procedure performs the record DTP routine */
   /**************************************************/
   procedure process_record_dtp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('DTP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_del_dtp.vbeln := rcd_lads_del_dtx.vbeln;
      rcd_lads_del_dtp.detseq := rcd_lads_del_dtx.detseq;
      rcd_lads_del_dtp.dtxseq := rcd_lads_del_dtx.dtxseq;
      rcd_lads_del_dtp.dtpseq := rcd_lads_del_dtp.dtpseq + 1;
      rcd_lads_del_dtp.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_del_dtp.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_del_dtp.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DTP.VBELN');
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

      insert into lads_del_dtp
         (vbeln,
          detseq,
          dtxseq,
          dtpseq,
          tdformat,
          tdline)
      values
         (rcd_lads_del_dtp.vbeln,
          rcd_lads_del_dtp.detseq,
          rcd_lads_del_dtp.dtxseq,
          rcd_lads_del_dtp.dtpseq,
          rcd_lads_del_dtp.tdformat,
          rcd_lads_del_dtp.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dtp;

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
      rcd_lads_del_huh.vbeln := rcd_lads_del_hdr.vbeln;
      rcd_lads_del_huh.huhseq := rcd_lads_del_huh.huhseq + 1;
      rcd_lads_del_huh.exidv := lics_inbound_utility.get_variable('EXIDV');
      rcd_lads_del_huh.tarag := lics_inbound_utility.get_number('TARAG',null);
      rcd_lads_del_huh.gweit := lics_inbound_utility.get_variable('GWEIT');
      rcd_lads_del_huh.brgew := lics_inbound_utility.get_number('BRGEW',null);
      rcd_lads_del_huh.ntgew := lics_inbound_utility.get_number('NTGEW',null);
      rcd_lads_del_huh.magew := lics_inbound_utility.get_number('MAGEW',null);
      rcd_lads_del_huh.gweim := lics_inbound_utility.get_variable('GWEIM');
      rcd_lads_del_huh.btvol := lics_inbound_utility.get_number('BTVOL',null);
      rcd_lads_del_huh.ntvol := lics_inbound_utility.get_number('NTVOL',null);
      rcd_lads_del_huh.mavol := lics_inbound_utility.get_number('MAVOL',null);
      rcd_lads_del_huh.volem := lics_inbound_utility.get_variable('VOLEM');
      rcd_lads_del_huh.tavol := lics_inbound_utility.get_number('TAVOL',null);
      rcd_lads_del_huh.volet := lics_inbound_utility.get_variable('VOLET');
      rcd_lads_del_huh.vegr2 := lics_inbound_utility.get_variable('VEGR2');
      rcd_lads_del_huh.vegr1 := lics_inbound_utility.get_variable('VEGR1');
      rcd_lads_del_huh.vegr3 := lics_inbound_utility.get_variable('VEGR3');
      rcd_lads_del_huh.vhilm := lics_inbound_utility.get_variable('VHILM');
      rcd_lads_del_huh.vegr4 := lics_inbound_utility.get_variable('VEGR4');
      rcd_lads_del_huh.laeng := lics_inbound_utility.get_number('LAENG',null);
      rcd_lads_del_huh.vegr5 := lics_inbound_utility.get_variable('VEGR5');
      rcd_lads_del_huh.breit := lics_inbound_utility.get_number('BREIT',null);
      rcd_lads_del_huh.hoehe := lics_inbound_utility.get_number('HOEHE',null);
      rcd_lads_del_huh.meabm := lics_inbound_utility.get_variable('MEABM');
      rcd_lads_del_huh.inhalt := lics_inbound_utility.get_variable('INHALT');
      rcd_lads_del_huh.vhart := lics_inbound_utility.get_variable('VHART');
      rcd_lads_del_huh.magrv := lics_inbound_utility.get_variable('MAGRV');
      rcd_lads_del_huh.ladlg := lics_inbound_utility.get_number('LADLG',null);
      rcd_lads_del_huh.ladeh := lics_inbound_utility.get_variable('LADEH');
      rcd_lads_del_huh.farzt := lics_inbound_utility.get_number('FARZT',null);
      rcd_lads_del_huh.fareh := lics_inbound_utility.get_variable('FAREH');
      rcd_lads_del_huh.entfe := lics_inbound_utility.get_number('ENTFE',null);
      rcd_lads_del_huh.ehent := lics_inbound_utility.get_variable('EHENT');
      rcd_lads_del_huh.veltp := lics_inbound_utility.get_variable('VELTP');
      rcd_lads_del_huh.exidv2 := lics_inbound_utility.get_variable('EXIDV2');
      rcd_lads_del_huh.landt := lics_inbound_utility.get_variable('LANDT');
      rcd_lads_del_huh.landf := lics_inbound_utility.get_variable('LANDF');
      rcd_lads_del_huh.namef := lics_inbound_utility.get_variable('NAMEF');
      rcd_lads_del_huh.nambe := lics_inbound_utility.get_variable('NAMBE');
      rcd_lads_del_huh.vhilm_ku := lics_inbound_utility.get_variable('VHILM_KU');
      rcd_lads_del_huh.vebez := lics_inbound_utility.get_variable('VEBEZ');
      rcd_lads_del_huh.smgkn := lics_inbound_utility.get_variable('SMGKN');
      rcd_lads_del_huh.kdmat35 := lics_inbound_utility.get_variable('KDMAT35');
      rcd_lads_del_huh.sortl := lics_inbound_utility.get_variable('SORTL');
      rcd_lads_del_huh.ernam := lics_inbound_utility.get_variable('ERNAM');
      rcd_lads_del_huh.gewfx := lics_inbound_utility.get_variable('GEWFX');
      rcd_lads_del_huh.erlkz := lics_inbound_utility.get_variable('ERLKZ');
      rcd_lads_del_huh.exida := lics_inbound_utility.get_variable('EXIDA');
      rcd_lads_del_huh.move_status := lics_inbound_utility.get_variable('MOVE_STATUS');
      rcd_lads_del_huh.packvorschr := lics_inbound_utility.get_variable('PACKVORSCHR');
      rcd_lads_del_huh.packvorschr_st := lics_inbound_utility.get_variable('PACKVORSCHR_ST');
      rcd_lads_del_huh.labeltyp := lics_inbound_utility.get_variable('LABELTYP');
      rcd_lads_del_huh.zul_aufl := lics_inbound_utility.get_variable('ZUL_AUFL');
      rcd_lads_del_huh.vhilm_external := lics_inbound_utility.get_variable('VHILM_EXTERNAL');
      rcd_lads_del_huh.vhilm_version := lics_inbound_utility.get_variable('VHILM_VERSION');
      rcd_lads_del_huh.vhilm_guid := lics_inbound_utility.get_variable('VHILM_GUID');
      rcd_lads_del_huh.vegr1_bez := lics_inbound_utility.get_variable('VEGR1_BEZ');
      rcd_lads_del_huh.vegr2_bez := lics_inbound_utility.get_variable('VEGR2_BEZ');
      rcd_lads_del_huh.vegr3_bez := lics_inbound_utility.get_variable('VEGR3_BEZ');
      rcd_lads_del_huh.vegr4_bez := lics_inbound_utility.get_variable('VEGR4_BEZ');
      rcd_lads_del_huh.vegr5_bez := lics_inbound_utility.get_variable('VEGR5_BEZ');
      rcd_lads_del_huh.vhart_bez := lics_inbound_utility.get_variable('VHART_BEZ');
      rcd_lads_del_huh.magrv_bez := lics_inbound_utility.get_variable('MAGRV_BEZ');
      rcd_lads_del_huh.vebez1 := lics_inbound_utility.get_variable('VEBEZ1');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_del_huc.hucseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_del_huh.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HUH.VBELN');
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

      insert into lads_del_huh
         (vbeln,
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
         (rcd_lads_del_huh.vbeln,
          rcd_lads_del_huh.huhseq,
          rcd_lads_del_huh.exidv,
          rcd_lads_del_huh.tarag,
          rcd_lads_del_huh.gweit,
          rcd_lads_del_huh.brgew,
          rcd_lads_del_huh.ntgew,
          rcd_lads_del_huh.magew,
          rcd_lads_del_huh.gweim,
          rcd_lads_del_huh.btvol,
          rcd_lads_del_huh.ntvol,
          rcd_lads_del_huh.mavol,
          rcd_lads_del_huh.volem,
          rcd_lads_del_huh.tavol,
          rcd_lads_del_huh.volet,
          rcd_lads_del_huh.vegr2,
          rcd_lads_del_huh.vegr1,
          rcd_lads_del_huh.vegr3,
          rcd_lads_del_huh.vhilm,
          rcd_lads_del_huh.vegr4,
          rcd_lads_del_huh.laeng,
          rcd_lads_del_huh.vegr5,
          rcd_lads_del_huh.breit,
          rcd_lads_del_huh.hoehe,
          rcd_lads_del_huh.meabm,
          rcd_lads_del_huh.inhalt,
          rcd_lads_del_huh.vhart,
          rcd_lads_del_huh.magrv,
          rcd_lads_del_huh.ladlg,
          rcd_lads_del_huh.ladeh,
          rcd_lads_del_huh.farzt,
          rcd_lads_del_huh.fareh,
          rcd_lads_del_huh.entfe,
          rcd_lads_del_huh.ehent,
          rcd_lads_del_huh.veltp,
          rcd_lads_del_huh.exidv2,
          rcd_lads_del_huh.landt,
          rcd_lads_del_huh.landf,
          rcd_lads_del_huh.namef,
          rcd_lads_del_huh.nambe,
          rcd_lads_del_huh.vhilm_ku,
          rcd_lads_del_huh.vebez,
          rcd_lads_del_huh.smgkn,
          rcd_lads_del_huh.kdmat35,
          rcd_lads_del_huh.sortl,
          rcd_lads_del_huh.ernam,
          rcd_lads_del_huh.gewfx,
          rcd_lads_del_huh.erlkz,
          rcd_lads_del_huh.exida,
          rcd_lads_del_huh.move_status,
          rcd_lads_del_huh.packvorschr,
          rcd_lads_del_huh.packvorschr_st,
          rcd_lads_del_huh.labeltyp,
          rcd_lads_del_huh.zul_aufl,
          rcd_lads_del_huh.vhilm_external,
          rcd_lads_del_huh.vhilm_version,
          rcd_lads_del_huh.vhilm_guid,
          rcd_lads_del_huh.vegr1_bez,
          rcd_lads_del_huh.vegr2_bez,
          rcd_lads_del_huh.vegr3_bez,
          rcd_lads_del_huh.vegr4_bez,
          rcd_lads_del_huh.vegr5_bez,
          rcd_lads_del_huh.vhart_bez,
          rcd_lads_del_huh.magrv_bez,
          rcd_lads_del_huh.vebez1);

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
      rcd_lads_del_huc.vbeln := rcd_lads_del_huh.vbeln;
      rcd_lads_del_huc.huhseq := rcd_lads_del_huh.huhseq;
      rcd_lads_del_huc.hucseq := rcd_lads_del_huc.hucseq + 1;
      rcd_lads_del_huc.velin := lics_inbound_utility.get_variable('VELIN');
      rcd_lads_del_huc.vbeln1 := lics_inbound_utility.get_variable('VBELN1');
      rcd_lads_del_huc.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_del_huc.exidv := lics_inbound_utility.get_variable('EXIDV');
      rcd_lads_del_huc.vemng := lics_inbound_utility.get_number('VEMNG',null);
      rcd_lads_del_huc.vemeh := lics_inbound_utility.get_variable('VEMEH');
      rcd_lads_del_huc.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_del_huc.kdmat := lics_inbound_utility.get_variable('KDMAT');
      rcd_lads_del_huc.charg := lics_inbound_utility.get_variable('CHARG');
      rcd_lads_del_huc.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_del_huc.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_del_huc.cuobj := lics_inbound_utility.get_variable('CUOBJ');
      rcd_lads_del_huc.bestq := lics_inbound_utility.get_variable('BESTQ');
      rcd_lads_del_huc.sobkz := lics_inbound_utility.get_variable('SOBKZ');
      rcd_lads_del_huc.sonum := lics_inbound_utility.get_variable('SONUM');
      rcd_lads_del_huc.anzsn := lics_inbound_utility.get_number('ANZSN',null);
      rcd_lads_del_huc.wdatu := lics_inbound_utility.get_variable('WDATU');
      rcd_lads_del_huc.parid := lics_inbound_utility.get_variable('PARID');
      rcd_lads_del_huc.matnr_external := lics_inbound_utility.get_variable('MATNR_EXTERNAL');
      rcd_lads_del_huc.matnr_version := lics_inbound_utility.get_variable('MATNR_VERSION');
      rcd_lads_del_huc.matnr_guid := lics_inbound_utility.get_variable('MATNR_GUID');

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
      if rcd_lads_del_huc.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HUC.VBELN');
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

      insert into lads_del_huc
         (vbeln,
          huhseq,
          hucseq,
          velin,
          vbeln1,
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
         (rcd_lads_del_huc.vbeln,
          rcd_lads_del_huc.huhseq,
          rcd_lads_del_huc.hucseq,
          rcd_lads_del_huc.velin,
          rcd_lads_del_huc.vbeln1,
          rcd_lads_del_huc.posnr,
          rcd_lads_del_huc.exidv,
          rcd_lads_del_huc.vemng,
          rcd_lads_del_huc.vemeh,
          rcd_lads_del_huc.matnr,
          rcd_lads_del_huc.kdmat,
          rcd_lads_del_huc.charg,
          rcd_lads_del_huc.werks,
          rcd_lads_del_huc.lgort,
          rcd_lads_del_huc.cuobj,
          rcd_lads_del_huc.bestq,
          rcd_lads_del_huc.sobkz,
          rcd_lads_del_huc.sonum,
          rcd_lads_del_huc.anzsn,
          rcd_lads_del_huc.wdatu,
          rcd_lads_del_huc.parid,
          rcd_lads_del_huc.matnr_external,
          rcd_lads_del_huc.matnr_version,
          rcd_lads_del_huc.matnr_guid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_huc;

end lads_atllad16;

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad16 for lads_app.lads_atllad16;
grant execute on lads_atllad16 to lics_app;

