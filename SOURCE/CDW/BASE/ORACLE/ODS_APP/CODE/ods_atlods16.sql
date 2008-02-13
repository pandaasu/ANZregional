/******************/
/* Package Header */
/******************/
create or replace package ods_atlods16 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_atlods16
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - atlods16 - Inbound Delivery Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004      ISI            Created
    2007/10   Steve Gregan   Included SAP_DEL_TRACE table
    2007/10   Steve Gregan   Added columns (DET) for Atlas 3.2.1 upgrade

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_atlods16;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_atlods16 as

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
   procedure process_record_tim(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);
   procedure process_record_irf(par_record in varchar2);
   procedure load_trace(par_vbeln in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_ctl_mescod varchar2(3);
   var_ctl_mesfct varchar2(3);
   rcd_ods_control ods_definition.idoc_control;
   rcd_sap_del_hdr sap_del_hdr%rowtype;
   rcd_sap_del_add sap_del_add%rowtype;
   rcd_sap_del_tim sap_del_tim%rowtype;
   rcd_sap_del_det sap_del_det%rowtype;
   rcd_sap_del_irf sap_del_irf%rowtype;

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
      lics_inbound_utility.set_definition('DET','ZNEWITEM',1);
      lics_inbound_utility.set_definition('DET','KWMENG',17);
      lics_inbound_utility.set_definition('DET','REPMATNR',18);
      lics_inbound_utility.set_definition('DET','LIFNR',10); 
      lics_inbound_utility.set_definition('DET','LICHN',15); 
      lics_inbound_utility.set_definition('DET','ZZTDU_PER_PALET',14); 
      lics_inbound_utility.set_definition('DET','ZZTDU_PER_LAYER',14); 
      lics_inbound_utility.set_definition('DET','ZZLFIMG',15); 
      lics_inbound_utility.set_definition('DET','ZZPLQTY',15);
      /*-*/
      lics_inbound_utility.set_definition('IRF','IDOC_IRF',3);
      lics_inbound_utility.set_definition('IRF','QUALF',1);
      lics_inbound_utility.set_definition('IRF','BELNR',35);
      lics_inbound_utility.set_definition('IRF','POSNR',6);
      lics_inbound_utility.set_definition('IRF','DATUM',8);
      lics_inbound_utility.set_definition('IRF','DOCTYPE',4);
      lics_inbound_utility.set_definition('IRF','REASON',3);

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
         when 'ADD' then process_record_add(par_record);
         when 'ADL' then null; -- Ignore record
         when 'TIM' then process_record_tim(par_record);
         when 'HTX' then null; -- Ignore record
         when 'HTP' then null; -- Ignore record
         when 'RTE' then null; -- Ignore record
         when 'STG' then null; -- Ignore record
         when 'NOD' then null; -- Ignore record
         when 'DET' then process_record_det(par_record);
         when 'POD' then null; -- Ignore record
         when 'INT' then null; -- Ignore record
         when 'IRF' then process_record_irf(par_record);
         when 'ERF' then null; -- Ignore record
         when 'DTX' then null; -- Ignore record
         when 'DTP' then null; -- Ignore record
         when 'HUH' then null; -- Ignore record
         when 'HUC' then null; -- Ignore record
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
            load_trace(rcd_sap_del_hdr.vbeln);
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
            ods_atlods16_monitor.execute(rcd_sap_del_hdr.vbeln);
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
      cursor csr_sap_del_hdr_01 is
         select
            t01.vbeln,
            t01.idoc_number,
            t01.idoc_timestamp,
            t01.mesfct
         from sap_del_hdr t01
         where t01.vbeln = rcd_sap_del_hdr.vbeln;
      rcd_sap_del_hdr_01 csr_sap_del_hdr_01%rowtype;

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
      rcd_sap_del_hdr.vbeln := lics_inbound_utility.get_variable('VBELN');
      rcd_sap_del_hdr.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_sap_del_hdr.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_sap_del_hdr.lstel := lics_inbound_utility.get_variable('LSTEL');
      rcd_sap_del_hdr.vkbur := lics_inbound_utility.get_variable('VKBUR');
      rcd_sap_del_hdr.lgnum := lics_inbound_utility.get_variable('LGNUM');
      rcd_sap_del_hdr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_sap_del_hdr.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_sap_del_hdr.inco2 := lics_inbound_utility.get_variable('INCO2');
      rcd_sap_del_hdr.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_sap_del_hdr.vsbed := lics_inbound_utility.get_variable('VSBED');
      rcd_sap_del_hdr.btgew := lics_inbound_utility.get_number('BTGEW',null);
      rcd_sap_del_hdr.ntgew := lics_inbound_utility.get_number('NTGEW',null);
      rcd_sap_del_hdr.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_sap_del_hdr.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_sap_del_hdr.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_sap_del_hdr.anzpk := lics_inbound_utility.get_number('ANZPK',null);
      rcd_sap_del_hdr.bolnr := lics_inbound_utility.get_variable('BOLNR');
      rcd_sap_del_hdr.traty := lics_inbound_utility.get_variable('TRATY');
      rcd_sap_del_hdr.traid := lics_inbound_utility.get_variable('TRAID');
      rcd_sap_del_hdr.xabln := lics_inbound_utility.get_variable('XABLN');
      rcd_sap_del_hdr.lifex := lics_inbound_utility.get_variable('LIFEX');
      rcd_sap_del_hdr.parid := lics_inbound_utility.get_variable('PARID');
      rcd_sap_del_hdr.podat := lics_inbound_utility.get_variable('PODAT');
      rcd_sap_del_hdr.potim := lics_inbound_utility.get_variable('POTIM');
      rcd_sap_del_hdr.vstel_bez := lics_inbound_utility.get_variable('VSTEL_BEZ');
      rcd_sap_del_hdr.vkorg_bez := lics_inbound_utility.get_variable('VKORG_BEZ');
      rcd_sap_del_hdr.lstel_bez := lics_inbound_utility.get_variable('LSTEL_BEZ');
      rcd_sap_del_hdr.vkbur_bez := lics_inbound_utility.get_variable('VKBUR_BEZ');
      rcd_sap_del_hdr.lgnum_bez := lics_inbound_utility.get_variable('LGNUM_BEZ');
      rcd_sap_del_hdr.inco1_bez := lics_inbound_utility.get_variable('INCO1_BEZ');
      rcd_sap_del_hdr.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_sap_del_hdr.vsbed_bez := lics_inbound_utility.get_variable('VSBED_BEZ');
      rcd_sap_del_hdr.traty_bez := lics_inbound_utility.get_variable('TRATY_BEZ');
      rcd_sap_del_hdr.lfart := lics_inbound_utility.get_variable('LFART');
      rcd_sap_del_hdr.bzirk := lics_inbound_utility.get_variable('BZIRK');
      rcd_sap_del_hdr.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_sap_del_hdr.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_sap_del_hdr.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_sap_del_hdr.kdgrp := lics_inbound_utility.get_variable('KDGRP');
      rcd_sap_del_hdr.berot := lics_inbound_utility.get_variable('BEROT');
      rcd_sap_del_hdr.tragr := lics_inbound_utility.get_variable('TRAGR');
      rcd_sap_del_hdr.trspg := lics_inbound_utility.get_variable('TRSPG');
      rcd_sap_del_hdr.aulwe := lics_inbound_utility.get_variable('AULWE');
      rcd_sap_del_hdr.lfart_bez := lics_inbound_utility.get_variable('LFART_BEZ');
      rcd_sap_del_hdr.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_sap_del_hdr.bzirk_bez := lics_inbound_utility.get_variable('BZIRK_BEZ');
      rcd_sap_del_hdr.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_sap_del_hdr.kdgrp_bez := lics_inbound_utility.get_variable('KDGRP_BEZ');
      rcd_sap_del_hdr.tragr_bez := lics_inbound_utility.get_variable('TRAGR_BEZ');
      rcd_sap_del_hdr.trspg_bez := lics_inbound_utility.get_variable('TRSPG_BEZ');
      rcd_sap_del_hdr.aulwe_bez := lics_inbound_utility.get_variable('AULWE_BEZ');
      rcd_sap_del_hdr.zztarif := lics_inbound_utility.get_variable('ZZTARIF');
      rcd_sap_del_hdr.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_sap_del_hdr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_sap_del_hdr.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_sap_del_hdr.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_sap_del_hdr.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_sap_del_hdr.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_sap_del_hdr.zztarif1 := lics_inbound_utility.get_variable('ZZTARIF1');
      rcd_sap_del_hdr.zzbrgew := lics_inbound_utility.get_number('ZZBRGEW',null);
      rcd_sap_del_hdr.zzweightuom := lics_inbound_utility.get_variable('ZZWEIGHTUOM');
      rcd_sap_del_hdr.zzpalspace := lics_inbound_utility.get_number('ZZPALSPACE',null);
      rcd_sap_del_hdr.zzpalbas01 := lics_inbound_utility.get_number('ZZPALBAS01',null);
      rcd_sap_del_hdr.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
      rcd_sap_del_hdr.zzpalbas02 := lics_inbound_utility.get_number('ZZPALBAS02',null);
      rcd_sap_del_hdr.zzmeins02 := lics_inbound_utility.get_variable('ZZMEINS02');
      rcd_sap_del_hdr.zzpalbas03 := lics_inbound_utility.get_number('ZZPALBAS03',null);
      rcd_sap_del_hdr.zzmeins03 := lics_inbound_utility.get_variable('ZZMEINS03');
      rcd_sap_del_hdr.zzpalbas04 := lics_inbound_utility.get_number('ZZPALBAS04',null);
      rcd_sap_del_hdr.zzmeins04 := lics_inbound_utility.get_variable('ZZMEINS04');
      rcd_sap_del_hdr.zzpalbas05 := lics_inbound_utility.get_number('ZZPALBAS05',null);
      rcd_sap_del_hdr.zzmeins05 := lics_inbound_utility.get_variable('ZZMEINS05');
      rcd_sap_del_hdr.zzpalspace_f := lics_inbound_utility.get_number('ZZPALSPACE_F',null);
      rcd_sap_del_hdr.zzpalbas01_f := lics_inbound_utility.get_number('ZZPALBAS01_F',null);
      rcd_sap_del_hdr.zzpalbas02_f := lics_inbound_utility.get_number('ZZPALBAS02_F',null);
      rcd_sap_del_hdr.zzpalbas03_f := lics_inbound_utility.get_number('ZZPALBAS03_F',null);
      rcd_sap_del_hdr.zzpalbas04_f := lics_inbound_utility.get_number('ZZPALBAS04_F',null);
      rcd_sap_del_hdr.zzpalbas05_f := lics_inbound_utility.get_number('ZZPALBAS05_F',null);
      rcd_sap_del_hdr.zztknum := lics_inbound_utility.get_variable('ZZTKNUM');
      rcd_sap_del_hdr.zzexpectpb := lics_inbound_utility.get_variable('ZZEXPECTPB');
      rcd_sap_del_hdr.zzgaranteedbpr := lics_inbound_utility.get_variable('ZZGARANTEEDBPR');
      rcd_sap_del_hdr.zzgroupbpr := lics_inbound_utility.get_variable('ZZGROUPBPR');
      rcd_sap_del_hdr.zzorbdpr := lics_inbound_utility.get_variable('ZZORBDPR');
      rcd_sap_del_hdr.zzmanbpr := lics_inbound_utility.get_variable('ZZMANBPR');
      rcd_sap_del_hdr.zzdelbpr := lics_inbound_utility.get_variable('ZZDELBPR');
      rcd_sap_del_hdr.zzpalspace_deliv := lics_inbound_utility.get_number('ZZPALSPACE_DELIV',null);
      rcd_sap_del_hdr.zzpalbase_del01 := lics_inbound_utility.get_number('ZZPALBASE_DEL01',null);
      rcd_sap_del_hdr.zzpalbase_del02 := lics_inbound_utility.get_number('ZZPALBASE_DEL02',null);
      rcd_sap_del_hdr.zzpalbase_del03 := lics_inbound_utility.get_number('ZZPALBASE_DEL03',null);
      rcd_sap_del_hdr.zzpalbase_del04 := lics_inbound_utility.get_number('ZZPALBASE_DEL04',null);
      rcd_sap_del_hdr.zzpalbase_del05 := lics_inbound_utility.get_number('ZZPALBASE_DEL05',null);
      rcd_sap_del_hdr.zzmeins_del01 := lics_inbound_utility.get_variable('ZZMEINS_DEL01');
      rcd_sap_del_hdr.zzmeins_del02 := lics_inbound_utility.get_variable('ZZMEINS_DEL02');
      rcd_sap_del_hdr.zzmeins_del03 := lics_inbound_utility.get_variable('ZZMEINS_DEL03');
      rcd_sap_del_hdr.zzmeins_del04 := lics_inbound_utility.get_variable('ZZMEINS_DEL04');
      rcd_sap_del_hdr.zzmeins_del05 := lics_inbound_utility.get_variable('ZZMEINS_DEL05');
      rcd_sap_del_hdr.atwrt1 := lics_inbound_utility.get_variable('ATWRT1');
      rcd_sap_del_hdr.atwrt2 := lics_inbound_utility.get_variable('ATWRT2');
      rcd_sap_del_hdr.mtimefrom := lics_inbound_utility.get_variable('MTIMEFROM');
      rcd_sap_del_hdr.mtimeto := lics_inbound_utility.get_variable('MTIMETO');
      rcd_sap_del_hdr.atimefrom := lics_inbound_utility.get_variable('ATIMEFROM');
      rcd_sap_del_hdr.atimeto := lics_inbound_utility.get_variable('ATIMETO');
      rcd_sap_del_hdr.werks2 := lics_inbound_utility.get_variable('WERKS2');
      rcd_sap_del_hdr.zzbrgew_f := lics_inbound_utility.get_number('ZZBRGEW_F',null);
      rcd_sap_del_hdr.zzweightpal := lics_inbound_utility.get_number('ZZWEIGHTPAL',null);
      rcd_sap_del_hdr.zzweightpal_f := lics_inbound_utility.get_number('ZZWEIGHTPAL_F',null);
      rcd_sap_del_hdr.mescod := var_ctl_mescod;
      rcd_sap_del_hdr.mesfct := var_ctl_mesfct;
      rcd_sap_del_hdr.idoc_name := rcd_ods_control.idoc_name;
      rcd_sap_del_hdr.idoc_number := rcd_ods_control.idoc_number;
      rcd_sap_del_hdr.idoc_timestamp := rcd_ods_control.idoc_timestamp;
      rcd_sap_del_hdr.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_sap_del_hdr.dlvry_procg_stage := CASE WHEN rcd_sap_del_hdr.mesfct = ods_constants.delivery_pick_flag THEN ods_constants.delivery_status_confirmed ELSE ods_constants.delivery_status_request END;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_del_add.addseq := 0;
      rcd_sap_del_tim.timseq := 0;
      rcd_sap_del_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_del_hdr.vbeln is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.VBELN');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_sap_del_hdr.vbeln is null) then
         var_exists := true;
         open csr_sap_del_hdr_01;
         fetch csr_sap_del_hdr_01 into rcd_sap_del_hdr_01;
         if csr_sap_del_hdr_01%notfound then
            var_exists := false;
         else

           /*-*/
           /* IF the MESFCT field is already set to PCK, don't overwrite with
           /* incoming field value, which could be RSD if IDOC is resent.
           /*-*/
           if (rcd_sap_del_hdr_01.mesfct = 'PCK') then
             rcd_sap_del_hdr.mesfct := rcd_sap_del_hdr_01.mesfct;
           end if;

         end if;
         close csr_sap_del_hdr_01;
         if var_exists = true then
            if rcd_sap_del_hdr.idoc_timestamp > rcd_sap_del_hdr_01.idoc_timestamp then
               delete from sap_del_irf where vbeln = rcd_sap_del_hdr.vbeln;
               delete from sap_del_det where vbeln = rcd_sap_del_hdr.vbeln;
               delete from sap_del_tim where vbeln = rcd_sap_del_hdr.vbeln;
               delete from sap_del_add where vbeln = rcd_sap_del_hdr.vbeln;
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

      update sap_del_hdr set
         vstel = rcd_sap_del_hdr.vstel,
         vkorg = rcd_sap_del_hdr.vkorg,
         lstel = rcd_sap_del_hdr.lstel,
         vkbur = rcd_sap_del_hdr.vkbur,
         lgnum = rcd_sap_del_hdr.lgnum,
         ablad = rcd_sap_del_hdr.ablad,
         inco1 = rcd_sap_del_hdr.inco1,
         inco2 = rcd_sap_del_hdr.inco2,
         route = rcd_sap_del_hdr.route,
         vsbed = rcd_sap_del_hdr.vsbed,
         btgew = rcd_sap_del_hdr.btgew,
         ntgew = rcd_sap_del_hdr.ntgew,
         gewei = rcd_sap_del_hdr.gewei,
         volum = rcd_sap_del_hdr.volum,
         voleh = rcd_sap_del_hdr.voleh,
         anzpk = rcd_sap_del_hdr.anzpk,
         bolnr = rcd_sap_del_hdr.bolnr,
         traty = rcd_sap_del_hdr.traty,
         traid = rcd_sap_del_hdr.traid,
         xabln = rcd_sap_del_hdr.xabln,
         lifex = rcd_sap_del_hdr.lifex,
         parid = rcd_sap_del_hdr.parid,
         podat = rcd_sap_del_hdr.podat,
         potim = rcd_sap_del_hdr.potim,
         vstel_bez = rcd_sap_del_hdr.vstel_bez,
         vkorg_bez = rcd_sap_del_hdr.vkorg_bez,
         lstel_bez = rcd_sap_del_hdr.lstel_bez,
         vkbur_bez = rcd_sap_del_hdr.vkbur_bez,
         lgnum_bez = rcd_sap_del_hdr.lgnum_bez,
         inco1_bez = rcd_sap_del_hdr.inco1_bez,
         route_bez = rcd_sap_del_hdr.route_bez,
         vsbed_bez = rcd_sap_del_hdr.vsbed_bez,
         traty_bez = rcd_sap_del_hdr.traty_bez,
         lfart = rcd_sap_del_hdr.lfart,
         bzirk = rcd_sap_del_hdr.bzirk,
         autlf = rcd_sap_del_hdr.autlf,
         lifsk = rcd_sap_del_hdr.lifsk,
         lprio = rcd_sap_del_hdr.lprio,
         kdgrp = rcd_sap_del_hdr.kdgrp,
         berot = rcd_sap_del_hdr.berot,
         tragr = rcd_sap_del_hdr.tragr,
         trspg = rcd_sap_del_hdr.trspg,
         aulwe = rcd_sap_del_hdr.aulwe,
         lfart_bez = rcd_sap_del_hdr.lfart_bez,
         lprio_bez = rcd_sap_del_hdr.lprio_bez,
         bzirk_bez = rcd_sap_del_hdr.bzirk_bez,
         lifsk_bez = rcd_sap_del_hdr.lifsk_bez,
         kdgrp_bez = rcd_sap_del_hdr.kdgrp_bez,
         tragr_bez = rcd_sap_del_hdr.tragr_bez,
         trspg_bez = rcd_sap_del_hdr.trspg_bez,
         aulwe_bez = rcd_sap_del_hdr.aulwe_bez,
         zztarif = rcd_sap_del_hdr.zztarif,
         werks = rcd_sap_del_hdr.werks,
         name1 = rcd_sap_del_hdr.name1,
         stras = rcd_sap_del_hdr.stras,
         pstlz = rcd_sap_del_hdr.pstlz,
         ort01 = rcd_sap_del_hdr.ort01,
         land1 = rcd_sap_del_hdr.land1,
         zztarif1 = rcd_sap_del_hdr.zztarif1,
         zzbrgew = rcd_sap_del_hdr.zzbrgew,
         zzweightuom = rcd_sap_del_hdr.zzweightuom,
         zzpalspace = rcd_sap_del_hdr.zzpalspace,
         zzpalbas01 = rcd_sap_del_hdr.zzpalbas01,
         zzmeins01 = rcd_sap_del_hdr.zzmeins01,
         zzpalbas02 = rcd_sap_del_hdr.zzpalbas02,
         zzmeins02 = rcd_sap_del_hdr.zzmeins02,
         zzpalbas03 = rcd_sap_del_hdr.zzpalbas03,
         zzmeins03 = rcd_sap_del_hdr.zzmeins03,
         zzpalbas04 = rcd_sap_del_hdr.zzpalbas04,
         zzmeins04 = rcd_sap_del_hdr.zzmeins04,
         zzpalbas05 = rcd_sap_del_hdr.zzpalbas05,
         zzmeins05 = rcd_sap_del_hdr.zzmeins05,
         zzpalspace_f = rcd_sap_del_hdr.zzpalspace_f,
         zzpalbas01_f = rcd_sap_del_hdr.zzpalbas01_f,
         zzpalbas02_f = rcd_sap_del_hdr.zzpalbas02_f,
         zzpalbas03_f = rcd_sap_del_hdr.zzpalbas03_f,
         zzpalbas04_f = rcd_sap_del_hdr.zzpalbas04_f,
         zzpalbas05_f = rcd_sap_del_hdr.zzpalbas05_f,
         zztknum = rcd_sap_del_hdr.zztknum,
         zzexpectpb = rcd_sap_del_hdr.zzexpectpb,
         zzgaranteedbpr = rcd_sap_del_hdr.zzgaranteedbpr,
         zzgroupbpr = rcd_sap_del_hdr.zzgroupbpr,
         zzorbdpr = rcd_sap_del_hdr.zzorbdpr,
         zzmanbpr = rcd_sap_del_hdr.zzmanbpr,
         zzdelbpr = rcd_sap_del_hdr.zzdelbpr,
         zzpalspace_deliv = rcd_sap_del_hdr.zzpalspace_deliv,
         zzpalbase_del01 = rcd_sap_del_hdr.zzpalbase_del01,
         zzpalbase_del02 = rcd_sap_del_hdr.zzpalbase_del02,
         zzpalbase_del03 = rcd_sap_del_hdr.zzpalbase_del03,
         zzpalbase_del04 = rcd_sap_del_hdr.zzpalbase_del04,
         zzpalbase_del05 = rcd_sap_del_hdr.zzpalbase_del05,
         zzmeins_del01 = rcd_sap_del_hdr.zzmeins_del01,
         zzmeins_del02 = rcd_sap_del_hdr.zzmeins_del02,
         zzmeins_del03 = rcd_sap_del_hdr.zzmeins_del03,
         zzmeins_del04 = rcd_sap_del_hdr.zzmeins_del04,
         zzmeins_del05 = rcd_sap_del_hdr.zzmeins_del05,
         atwrt1 = rcd_sap_del_hdr.atwrt1,
         atwrt2 = rcd_sap_del_hdr.atwrt2,
         mtimefrom = rcd_sap_del_hdr.mtimefrom,
         mtimeto = rcd_sap_del_hdr.mtimeto,
         atimefrom = rcd_sap_del_hdr.atimefrom,
         atimeto = rcd_sap_del_hdr.atimeto,
         werks2 = rcd_sap_del_hdr.werks2,
         zzbrgew_f = rcd_sap_del_hdr.zzbrgew_f,
         zzweightpal = rcd_sap_del_hdr.zzweightpal,
         zzweightpal_f = rcd_sap_del_hdr.zzweightpal_f,
         mescod = rcd_sap_del_hdr.mescod,
         mesfct = rcd_sap_del_hdr.mesfct,
         idoc_name = rcd_sap_del_hdr.idoc_name,
         idoc_number = rcd_sap_del_hdr.idoc_number,
         idoc_timestamp = rcd_sap_del_hdr.idoc_timestamp,
         valdtn_status = rcd_sap_del_hdr.valdtn_status,
         dlvry_procg_stage = rcd_sap_del_hdr.dlvry_procg_stage
      where vbeln = rcd_sap_del_hdr.vbeln;
      if sql%notfound then
         insert into sap_del_hdr
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
             idoc_name,
             idoc_number,
             idoc_timestamp,
             valdtn_status,
             dlvry_procg_stage)
         values
            (rcd_sap_del_hdr.vbeln,
             rcd_sap_del_hdr.vstel,
             rcd_sap_del_hdr.vkorg,
             rcd_sap_del_hdr.lstel,
             rcd_sap_del_hdr.vkbur,
             rcd_sap_del_hdr.lgnum,
             rcd_sap_del_hdr.ablad,
             rcd_sap_del_hdr.inco1,
             rcd_sap_del_hdr.inco2,
             rcd_sap_del_hdr.route,
             rcd_sap_del_hdr.vsbed,
             rcd_sap_del_hdr.btgew,
             rcd_sap_del_hdr.ntgew,
             rcd_sap_del_hdr.gewei,
             rcd_sap_del_hdr.volum,
             rcd_sap_del_hdr.voleh,
             rcd_sap_del_hdr.anzpk,
             rcd_sap_del_hdr.bolnr,
             rcd_sap_del_hdr.traty,
             rcd_sap_del_hdr.traid,
             rcd_sap_del_hdr.xabln,
             rcd_sap_del_hdr.lifex,
             rcd_sap_del_hdr.parid,
             rcd_sap_del_hdr.podat,
             rcd_sap_del_hdr.potim,
             rcd_sap_del_hdr.vstel_bez,
             rcd_sap_del_hdr.vkorg_bez,
             rcd_sap_del_hdr.lstel_bez,
             rcd_sap_del_hdr.vkbur_bez,
             rcd_sap_del_hdr.lgnum_bez,
             rcd_sap_del_hdr.inco1_bez,
             rcd_sap_del_hdr.route_bez,
             rcd_sap_del_hdr.vsbed_bez,
             rcd_sap_del_hdr.traty_bez,
             rcd_sap_del_hdr.lfart,
             rcd_sap_del_hdr.bzirk,
             rcd_sap_del_hdr.autlf,
             rcd_sap_del_hdr.lifsk,
             rcd_sap_del_hdr.lprio,
             rcd_sap_del_hdr.kdgrp,
             rcd_sap_del_hdr.berot,
             rcd_sap_del_hdr.tragr,
             rcd_sap_del_hdr.trspg,
             rcd_sap_del_hdr.aulwe,
             rcd_sap_del_hdr.lfart_bez,
             rcd_sap_del_hdr.lprio_bez,
             rcd_sap_del_hdr.bzirk_bez,
             rcd_sap_del_hdr.lifsk_bez,
             rcd_sap_del_hdr.kdgrp_bez,
             rcd_sap_del_hdr.tragr_bez,
             rcd_sap_del_hdr.trspg_bez,
             rcd_sap_del_hdr.aulwe_bez,
             rcd_sap_del_hdr.zztarif,
             rcd_sap_del_hdr.werks,
             rcd_sap_del_hdr.name1,
             rcd_sap_del_hdr.stras,
             rcd_sap_del_hdr.pstlz,
             rcd_sap_del_hdr.ort01,
             rcd_sap_del_hdr.land1,
             rcd_sap_del_hdr.zztarif1,
             rcd_sap_del_hdr.zzbrgew,
             rcd_sap_del_hdr.zzweightuom,
             rcd_sap_del_hdr.zzpalspace,
             rcd_sap_del_hdr.zzpalbas01,
             rcd_sap_del_hdr.zzmeins01,
             rcd_sap_del_hdr.zzpalbas02,
             rcd_sap_del_hdr.zzmeins02,
             rcd_sap_del_hdr.zzpalbas03,
             rcd_sap_del_hdr.zzmeins03,
             rcd_sap_del_hdr.zzpalbas04,
             rcd_sap_del_hdr.zzmeins04,
             rcd_sap_del_hdr.zzpalbas05,
             rcd_sap_del_hdr.zzmeins05,
             rcd_sap_del_hdr.zzpalspace_f,
             rcd_sap_del_hdr.zzpalbas01_f,
             rcd_sap_del_hdr.zzpalbas02_f,
             rcd_sap_del_hdr.zzpalbas03_f,
             rcd_sap_del_hdr.zzpalbas04_f,
             rcd_sap_del_hdr.zzpalbas05_f,
             rcd_sap_del_hdr.zztknum,
             rcd_sap_del_hdr.zzexpectpb,
             rcd_sap_del_hdr.zzgaranteedbpr,
             rcd_sap_del_hdr.zzgroupbpr,
             rcd_sap_del_hdr.zzorbdpr,
             rcd_sap_del_hdr.zzmanbpr,
             rcd_sap_del_hdr.zzdelbpr,
             rcd_sap_del_hdr.zzpalspace_deliv,
             rcd_sap_del_hdr.zzpalbase_del01,
             rcd_sap_del_hdr.zzpalbase_del02,
             rcd_sap_del_hdr.zzpalbase_del03,
             rcd_sap_del_hdr.zzpalbase_del04,
             rcd_sap_del_hdr.zzpalbase_del05,
             rcd_sap_del_hdr.zzmeins_del01,
             rcd_sap_del_hdr.zzmeins_del02,
             rcd_sap_del_hdr.zzmeins_del03,
             rcd_sap_del_hdr.zzmeins_del04,
             rcd_sap_del_hdr.zzmeins_del05,
             rcd_sap_del_hdr.atwrt1,
             rcd_sap_del_hdr.atwrt2,
             rcd_sap_del_hdr.mtimefrom,
             rcd_sap_del_hdr.mtimeto,
             rcd_sap_del_hdr.atimefrom,
             rcd_sap_del_hdr.atimeto,
             rcd_sap_del_hdr.werks2,
             rcd_sap_del_hdr.zzbrgew_f,
             rcd_sap_del_hdr.zzweightpal,
             rcd_sap_del_hdr.zzweightpal_f,
             rcd_sap_del_hdr.mescod,
             rcd_sap_del_hdr.mesfct,
             rcd_sap_del_hdr.idoc_name,
             rcd_sap_del_hdr.idoc_number,
             rcd_sap_del_hdr.idoc_timestamp,
             rcd_sap_del_hdr.valdtn_status,
             rcd_sap_del_hdr.dlvry_procg_stage);
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
      rcd_sap_del_add.vbeln := rcd_sap_del_hdr.vbeln;
      rcd_sap_del_add.addseq := rcd_sap_del_add.addseq + 1;
      rcd_sap_del_add.partner_q := lics_inbound_utility.get_variable('PARTNER_Q');
      rcd_sap_del_add.address_t := lics_inbound_utility.get_variable('ADDRESS_T');
      rcd_sap_del_add.partner_id := lics_inbound_utility.get_variable('PARTNER_ID');
      rcd_sap_del_add.language := lics_inbound_utility.get_variable('LANGUAGE');
      rcd_sap_del_add.formofaddr := lics_inbound_utility.get_variable('FORMOFADDR');
      rcd_sap_del_add.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_sap_del_add.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_sap_del_add.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_sap_del_add.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_sap_del_add.name_text := lics_inbound_utility.get_variable('NAME_TEXT');
      rcd_sap_del_add.name_co := lics_inbound_utility.get_variable('NAME_CO');
      rcd_sap_del_add.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_sap_del_add.building := lics_inbound_utility.get_variable('BUILDING');
      rcd_sap_del_add.floor := lics_inbound_utility.get_variable('FLOOR');
      rcd_sap_del_add.room := lics_inbound_utility.get_variable('ROOM');
      rcd_sap_del_add.street1 := lics_inbound_utility.get_variable('STREET1');
      rcd_sap_del_add.street2 := lics_inbound_utility.get_variable('STREET2');
      rcd_sap_del_add.street3 := lics_inbound_utility.get_variable('STREET3');
      rcd_sap_del_add.house_supl := lics_inbound_utility.get_variable('HOUSE_SUPL');
      rcd_sap_del_add.house_rang := lics_inbound_utility.get_variable('HOUSE_RANG');
      rcd_sap_del_add.postl_cod1 := lics_inbound_utility.get_variable('POSTL_COD1');
      rcd_sap_del_add.postl_cod3 := lics_inbound_utility.get_variable('POSTL_COD3');
      rcd_sap_del_add.postl_area := lics_inbound_utility.get_variable('POSTL_AREA');
      rcd_sap_del_add.city1 := lics_inbound_utility.get_variable('CITY1');
      rcd_sap_del_add.city2 := lics_inbound_utility.get_variable('CITY2');
      rcd_sap_del_add.postl_pbox := lics_inbound_utility.get_variable('POSTL_PBOX');
      rcd_sap_del_add.postl_cod2 := lics_inbound_utility.get_variable('POSTL_COD2');
      rcd_sap_del_add.postl_city := lics_inbound_utility.get_variable('POSTL_CITY');
      rcd_sap_del_add.telephone1 := lics_inbound_utility.get_variable('TELEPHONE1');
      rcd_sap_del_add.telephone2 := lics_inbound_utility.get_variable('TELEPHONE2');
      rcd_sap_del_add.telefax := lics_inbound_utility.get_variable('TELEFAX');
      rcd_sap_del_add.telex := lics_inbound_utility.get_variable('TELEX');
      rcd_sap_del_add.e_mail := lics_inbound_utility.get_variable('E_MAIL');
      rcd_sap_del_add.country1 := lics_inbound_utility.get_variable('COUNTRY1');
      rcd_sap_del_add.country2 := lics_inbound_utility.get_variable('COUNTRY2');
      rcd_sap_del_add.region := lics_inbound_utility.get_variable('REGION');
      rcd_sap_del_add.county_cod := lics_inbound_utility.get_variable('COUNTY_COD');
      rcd_sap_del_add.county_txt := lics_inbound_utility.get_variable('COUNTY_TXT');
      rcd_sap_del_add.tzcode := lics_inbound_utility.get_variable('TZCODE');
      rcd_sap_del_add.tzdesc := lics_inbound_utility.get_variable('TZDESC');

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
      if rcd_sap_del_add.vbeln is null then
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

      insert into sap_del_add
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
         (rcd_sap_del_add.vbeln,
          rcd_sap_del_add.addseq,
          rcd_sap_del_add.partner_q,
          rcd_sap_del_add.address_t,
          rcd_sap_del_add.partner_id,
          rcd_sap_del_add.language,
          rcd_sap_del_add.formofaddr,
          rcd_sap_del_add.name1,
          rcd_sap_del_add.name2,
          rcd_sap_del_add.name3,
          rcd_sap_del_add.name4,
          rcd_sap_del_add.name_text,
          rcd_sap_del_add.name_co,
          rcd_sap_del_add.location,
          rcd_sap_del_add.building,
          rcd_sap_del_add.floor,
          rcd_sap_del_add.room,
          rcd_sap_del_add.street1,
          rcd_sap_del_add.street2,
          rcd_sap_del_add.street3,
          rcd_sap_del_add.house_supl,
          rcd_sap_del_add.house_rang,
          rcd_sap_del_add.postl_cod1,
          rcd_sap_del_add.postl_cod3,
          rcd_sap_del_add.postl_area,
          rcd_sap_del_add.city1,
          rcd_sap_del_add.city2,
          rcd_sap_del_add.postl_pbox,
          rcd_sap_del_add.postl_cod2,
          rcd_sap_del_add.postl_city,
          rcd_sap_del_add.telephone1,
          rcd_sap_del_add.telephone2,
          rcd_sap_del_add.telefax,
          rcd_sap_del_add.telex,
          rcd_sap_del_add.e_mail,
          rcd_sap_del_add.country1,
          rcd_sap_del_add.country2,
          rcd_sap_del_add.region,
          rcd_sap_del_add.county_cod,
          rcd_sap_del_add.county_txt,
          rcd_sap_del_add.tzcode,
          rcd_sap_del_add.tzdesc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_add;

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
      rcd_sap_del_tim.vbeln := rcd_sap_del_hdr.vbeln;
      rcd_sap_del_tim.timseq := rcd_sap_del_tim.timseq + 1;
      rcd_sap_del_tim.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_del_tim.vstzw := lics_inbound_utility.get_variable('VSTZW');
      rcd_sap_del_tim.vstzw_bez := lics_inbound_utility.get_variable('VSTZW_BEZ');
      rcd_sap_del_tim.ntanf := lics_inbound_utility.get_variable('NTANF');
      rcd_sap_del_tim.ntanz := lics_inbound_utility.get_variable('NTANZ');
      rcd_sap_del_tim.ntend := lics_inbound_utility.get_variable('NTEND');
      rcd_sap_del_tim.ntenz := lics_inbound_utility.get_variable('NTENZ');
      rcd_sap_del_tim.tzone_beg := lics_inbound_utility.get_variable('TZONE_BEG');
      rcd_sap_del_tim.isdd := lics_inbound_utility.get_variable('ISDD');
      rcd_sap_del_tim.isdz := lics_inbound_utility.get_variable('ISDZ');
      rcd_sap_del_tim.iedd := lics_inbound_utility.get_variable('IEDD');
      rcd_sap_del_tim.iedz := lics_inbound_utility.get_variable('IEDZ');
      rcd_sap_del_tim.tzone_end := lics_inbound_utility.get_variable('TZONE_END');
      rcd_sap_del_tim.vornr := lics_inbound_utility.get_variable('VORNR');
      rcd_sap_del_tim.vstga := lics_inbound_utility.get_variable('VSTGA');
      rcd_sap_del_tim.vstga_bez := lics_inbound_utility.get_variable('VSTGA_BEZ');
      rcd_sap_del_tim.event := lics_inbound_utility.get_variable('EVENT');
      rcd_sap_del_tim.event_ali := lics_inbound_utility.get_variable('EVENT_ALI');
      rcd_sap_del_tim.qualf1 := lics_inbound_utility.get_variable('QUALF1');
      rcd_sap_del_tim.vdatu := lics_inbound_utility.get_variable('VDATU');

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
      if rcd_sap_del_tim.vbeln is null then
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

      insert into sap_del_tim
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
         (rcd_sap_del_tim.vbeln,
          rcd_sap_del_tim.timseq,
          rcd_sap_del_tim.qualf,
          rcd_sap_del_tim.vstzw,
          rcd_sap_del_tim.vstzw_bez,
          rcd_sap_del_tim.ntanf,
          rcd_sap_del_tim.ntanz,
          rcd_sap_del_tim.ntend,
          rcd_sap_del_tim.ntenz,
          rcd_sap_del_tim.tzone_beg,
          rcd_sap_del_tim.isdd,
          rcd_sap_del_tim.isdz,
          rcd_sap_del_tim.iedd,
          rcd_sap_del_tim.iedz,
          rcd_sap_del_tim.tzone_end,
          rcd_sap_del_tim.vornr,
          rcd_sap_del_tim.vstga,
          rcd_sap_del_tim.vstga_bez,
          rcd_sap_del_tim.event,
          rcd_sap_del_tim.event_ali,
          rcd_sap_del_tim.qualf1,
          rcd_sap_del_tim.vdatu);

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
      rcd_sap_del_det.vbeln := rcd_sap_del_hdr.vbeln;
      rcd_sap_del_det.detseq := rcd_sap_del_det.detseq + 1;
      rcd_sap_del_det.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_sap_del_det.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_sap_del_det.matwa := lics_inbound_utility.get_variable('MATWA');
      rcd_sap_del_det.arktx := lics_inbound_utility.get_variable('ARKTX');
      rcd_sap_del_det.orktx := lics_inbound_utility.get_variable('ORKTX');
      rcd_sap_del_det.sugrd := lics_inbound_utility.get_variable('SUGRD');
      rcd_sap_del_det.sudru := lics_inbound_utility.get_variable('SUDRU');
      rcd_sap_del_det.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_sap_del_det.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_sap_del_det.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_sap_del_det.charg := lics_inbound_utility.get_variable('CHARG');
      rcd_sap_del_det.kdmat := lics_inbound_utility.get_variable('KDMAT');
      rcd_sap_del_det.lfimg := lics_inbound_utility.get_number('LFIMG',null);
      rcd_sap_del_det.vrkme := lics_inbound_utility.get_variable('VRKME');
      rcd_sap_del_det.lgmng := lics_inbound_utility.get_number('LGMNG',null);
      rcd_sap_del_det.meins := lics_inbound_utility.get_variable('MEINS');
      rcd_sap_del_det.ntgew := lics_inbound_utility.get_number('NTGEW',null);
      rcd_sap_del_det.brgew := lics_inbound_utility.get_number('BRGEW',null);
      rcd_sap_del_det.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_sap_del_det.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_sap_del_det.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_sap_del_det.lgpbe := lics_inbound_utility.get_variable('LGPBE');
      rcd_sap_del_det.hipos := lics_inbound_utility.get_variable('HIPOS');
      rcd_sap_del_det.hievw := lics_inbound_utility.get_variable('HIEVW');
      rcd_sap_del_det.ladgr := lics_inbound_utility.get_variable('LADGR');
      rcd_sap_del_det.tragr := lics_inbound_utility.get_variable('TRAGR');
      rcd_sap_del_det.vkbur := lics_inbound_utility.get_variable('VKBUR');
      rcd_sap_del_det.vkgrp := lics_inbound_utility.get_variable('VKGRP');
      rcd_sap_del_det.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_sap_del_det.spart := lics_inbound_utility.get_variable('SPART');
      rcd_sap_del_det.grkor := lics_inbound_utility.get_variable('GRKOR');
      rcd_sap_del_det.ean11 := lics_inbound_utility.get_variable('EAN11');
      rcd_sap_del_det.sernr := lics_inbound_utility.get_variable('SERNR');
      rcd_sap_del_det.aeskd := lics_inbound_utility.get_variable('AESKD');
      rcd_sap_del_det.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_sap_del_det.mfrgr := lics_inbound_utility.get_variable('MFRGR');
      rcd_sap_del_det.vbrst := lics_inbound_utility.get_variable('VBRST');
      rcd_sap_del_det.labnk := lics_inbound_utility.get_variable('LABNK');
      rcd_sap_del_det.abrdt := lics_inbound_utility.get_variable('ABRDT');
      rcd_sap_del_det.mfrpn := lics_inbound_utility.get_variable('MFRPN');
      rcd_sap_del_det.mfrnr := lics_inbound_utility.get_variable('MFRNR');
      rcd_sap_del_det.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_sap_del_det.kdmat35 := lics_inbound_utility.get_variable('KDMAT35');
      rcd_sap_del_det.kannr := lics_inbound_utility.get_variable('KANNR');
      rcd_sap_del_det.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_sap_del_det.lieffz := lics_inbound_utility.get_number('LIEFFZ',null);
      rcd_sap_del_det.usr01 := lics_inbound_utility.get_variable('USR01');
      rcd_sap_del_det.usr02 := lics_inbound_utility.get_variable('USR02');
      rcd_sap_del_det.usr03 := lics_inbound_utility.get_variable('USR03');
      rcd_sap_del_det.usr04 := lics_inbound_utility.get_variable('USR04');
      rcd_sap_del_det.usr05 := lics_inbound_utility.get_variable('USR05');
      rcd_sap_del_det.matnr_external := lics_inbound_utility.get_variable('MATNR_EXTERNAL');
      rcd_sap_del_det.matnr_version := lics_inbound_utility.get_variable('MATNR_VERSION');
      rcd_sap_del_det.matnr_guid := lics_inbound_utility.get_variable('MATNR_GUID');
      rcd_sap_del_det.matwa_external := lics_inbound_utility.get_variable('MATWA_EXTERNAL');
      rcd_sap_del_det.matwa_version := lics_inbound_utility.get_variable('MATWA_VERSION');
      rcd_sap_del_det.matwa_guid := lics_inbound_utility.get_variable('MATWA_GUID');
      rcd_sap_del_det.zudat := lics_inbound_utility.get_variable('ZUDAT');
      rcd_sap_del_det.vfdat := lics_inbound_utility.get_variable('VFDAT');
      rcd_sap_del_det.zzmeins01 := lics_inbound_utility.get_variable('ZZMEINS01');
      rcd_sap_del_det.zzpalbas01_f := lics_inbound_utility.get_number('ZZPALBAS01_F',null);
      rcd_sap_del_det.vbelv := lics_inbound_utility.get_variable('VBELV');
      rcd_sap_del_det.posnv := lics_inbound_utility.get_variable('POSNV');
      rcd_sap_del_det.zzhalfpal := lics_inbound_utility.get_variable('ZZHALFPAL');
      rcd_sap_del_det.zzstackable := lics_inbound_utility.get_variable('ZZSTACKABLE');
      rcd_sap_del_det.zznbrhompal := lics_inbound_utility.get_number('ZZNBRHOMPAL',null);
      rcd_sap_del_det.zzpalbase_deliv := lics_inbound_utility.get_number('ZZPALBASE_DELIV',null);
      rcd_sap_del_det.zzpalspace_deliv := lics_inbound_utility.get_number('ZZPALSPACE_DELIV',null);
      rcd_sap_del_det.zzmeins_deliv := lics_inbound_utility.get_variable('ZZMEINS_DELIV');
      rcd_sap_del_det.value1 := lics_inbound_utility.get_number('VALUE1',null);
      rcd_sap_del_det.zrsp := lics_inbound_utility.get_number('ZRSP',null);
      rcd_sap_del_det.rate := lics_inbound_utility.get_number('RATE',null);
      rcd_sap_del_det.kostl := lics_inbound_utility.get_variable('KOSTL');
      rcd_sap_del_det.vfdat1 := lics_inbound_utility.get_variable('VFDAT1');
      rcd_sap_del_det.value := lics_inbound_utility.get_number('VALUE',null);
      rcd_sap_del_det.zzbb4 := lics_inbound_utility.get_variable('ZZBB4');
      rcd_sap_del_det.zzpi_id := lics_inbound_utility.get_variable('ZZPI_ID');
      rcd_sap_del_det.insmk := lics_inbound_utility.get_variable('INSMK');
      rcd_sap_del_det.spart1 := lics_inbound_utility.get_variable('SPART1');
      rcd_sap_del_det.lgort_bez := lics_inbound_utility.get_variable('LGORT_BEZ');
      rcd_sap_del_det.ladgr_bez := lics_inbound_utility.get_variable('LADGR_BEZ');
      rcd_sap_del_det.tragr_bez := lics_inbound_utility.get_variable('TRAGR_BEZ');
      rcd_sap_del_det.vkbur_bez := lics_inbound_utility.get_variable('VKBUR_BEZ');
      rcd_sap_del_det.vkgrp_bez := lics_inbound_utility.get_variable('VKGRP_BEZ');
      rcd_sap_del_det.vtweg_bez := lics_inbound_utility.get_variable('VTWEG_BEZ');
      rcd_sap_del_det.spart_bez := lics_inbound_utility.get_variable('SPART_BEZ');
      rcd_sap_del_det.mfrgr_bez := lics_inbound_utility.get_variable('MFRGR_BEZ');
      rcd_sap_del_det.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_sap_del_det.matkl1 := lics_inbound_utility.get_variable('MATKL1');
      rcd_sap_del_det.prodh := lics_inbound_utility.get_variable('PRODH');
      rcd_sap_del_det.umvkz := lics_inbound_utility.get_number('UMVKZ',null);
      rcd_sap_del_det.umvkn := lics_inbound_utility.get_number('UMVKN',null);
      rcd_sap_del_det.kztlf := lics_inbound_utility.get_variable('KZTLF');
      rcd_sap_del_det.uebtk := lics_inbound_utility.get_variable('UEBTK');
      rcd_sap_del_det.uebto := lics_inbound_utility.get_number('UEBTO',null);
      rcd_sap_del_det.untto := lics_inbound_utility.get_number('UNTTO',null);
      rcd_sap_del_det.chspl := lics_inbound_utility.get_variable('CHSPL');
      rcd_sap_del_det.xchbw := lics_inbound_utility.get_variable('XCHBW');
      rcd_sap_del_det.posar := lics_inbound_utility.get_variable('POSAR');
      rcd_sap_del_det.sobkz := lics_inbound_utility.get_variable('SOBKZ');
      rcd_sap_del_det.pckpf := lics_inbound_utility.get_variable('PCKPF');
      rcd_sap_del_det.magrv := lics_inbound_utility.get_variable('MAGRV');
      rcd_sap_del_det.shkzg := lics_inbound_utility.get_variable('SHKZG');
      rcd_sap_del_det.koqui := lics_inbound_utility.get_variable('KOQUI');
      rcd_sap_del_det.aktnr := lics_inbound_utility.get_variable('AKTNR');
      rcd_sap_del_det.kzumw := lics_inbound_utility.get_variable('KZUMW');
      rcd_sap_del_det.kvgr1 := lics_inbound_utility.get_variable('KVGR1');
      rcd_sap_del_det.kvgr2 := lics_inbound_utility.get_variable('KVGR2');
      rcd_sap_del_det.kvgr3 := lics_inbound_utility.get_variable('KVGR3');
      rcd_sap_del_det.kvgr4 := lics_inbound_utility.get_variable('KVGR4');
      rcd_sap_del_det.kvgr5 := lics_inbound_utility.get_variable('KVGR5');
      rcd_sap_del_det.mvgr1 := lics_inbound_utility.get_variable('MVGR1');
      rcd_sap_del_det.mvgr2 := lics_inbound_utility.get_variable('MVGR2');
      rcd_sap_del_det.mvgr3 := lics_inbound_utility.get_variable('MVGR3');
      rcd_sap_del_det.mvgr4 := lics_inbound_utility.get_variable('MVGR4');
      rcd_sap_del_det.mvgr5 := lics_inbound_utility.get_variable('MVGR5');
      rcd_sap_del_det.pstyv_bez := lics_inbound_utility.get_variable('PSTYV_BEZ');
      rcd_sap_del_det.matkl_bez := lics_inbound_utility.get_variable('MATKL_BEZ');
      rcd_sap_del_det.prodh_bez := lics_inbound_utility.get_variable('PRODH_BEZ');
      rcd_sap_del_det.werks_bez := lics_inbound_utility.get_variable('WERKS_BEZ');
      rcd_sap_del_det.kvgr1_bez := lics_inbound_utility.get_variable('KVGR1_BEZ');
      rcd_sap_del_det.kvgr2_bez := lics_inbound_utility.get_variable('KVGR2_BEZ');
      rcd_sap_del_det.kvgr3_bez := lics_inbound_utility.get_variable('KVGR3_BEZ');
      rcd_sap_del_det.kvgr4_bez := lics_inbound_utility.get_variable('KVGR4_BEZ');
      rcd_sap_del_det.kvgr5_bez := lics_inbound_utility.get_variable('KVGR5_BEZ');
      rcd_sap_del_det.mvgr1_bez := lics_inbound_utility.get_variable('MVGR1_BEZ');
      rcd_sap_del_det.mvgr2_bez := lics_inbound_utility.get_variable('MVGR2_BEZ');
      rcd_sap_del_det.mvgr3_bez := lics_inbound_utility.get_variable('MVGR3_BEZ');
      rcd_sap_del_det.mvgr4_bez := lics_inbound_utility.get_variable('MVGR4_BEZ');
      rcd_sap_del_det.mvgr5_bez := lics_inbound_utility.get_variable('MVGR5_BEZ');
      rcd_sap_del_det.znewitem := lics_inbound_utility.get_variable('ZNEWITEM');
      rcd_sap_del_det.kwmeng := lics_inbound_utility.get_number('KWMENG',null);
      rcd_sap_del_det.repmatnr := lics_inbound_utility.get_variable('REPMATNR');
      rcd_sap_del_det.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_sap_del_det.lichn := lics_inbound_utility.get_variable('LICHN');
      rcd_sap_del_det.zztdu_per_palet := lics_inbound_utility.get_number('ZZTDU_PER_PALET',null);
      rcd_sap_del_det.zztdu_per_layer := lics_inbound_utility.get_number('ZZTDU_PER_LAYER',null);
      rcd_sap_del_det.zzlfimg := lics_inbound_utility.get_number('ZZLFIMG',null);
      rcd_sap_del_det.zzplqty := lics_inbound_utility.get_number('ZZPLQTY',null);
      rcd_sap_del_det.dlvry_line_status := ods_constants.delivery_status_outstanding;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_del_irf.irfseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_del_det.vbeln is null then
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

      insert into sap_del_det
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
          mvgr5_bez,
          dlvry_line_status,
          znewitem,
          kwmeng,
          repmatnr,
          lifnr,
          lichn,
          zztdu_per_palet,
          zztdu_per_layer,
          zzlfimg,
          zzplqty)
      values
         (rcd_sap_del_det.vbeln,
          rcd_sap_del_det.detseq,
          rcd_sap_del_det.posnr,
          rcd_sap_del_det.matnr,
          rcd_sap_del_det.matwa,
          rcd_sap_del_det.arktx,
          rcd_sap_del_det.orktx,
          rcd_sap_del_det.sugrd,
          rcd_sap_del_det.sudru,
          rcd_sap_del_det.matkl,
          rcd_sap_del_det.werks,
          rcd_sap_del_det.lgort,
          rcd_sap_del_det.charg,
          rcd_sap_del_det.kdmat,
          rcd_sap_del_det.lfimg,
          rcd_sap_del_det.vrkme,
          rcd_sap_del_det.lgmng,
          rcd_sap_del_det.meins,
          rcd_sap_del_det.ntgew,
          rcd_sap_del_det.brgew,
          rcd_sap_del_det.gewei,
          rcd_sap_del_det.volum,
          rcd_sap_del_det.voleh,
          rcd_sap_del_det.lgpbe,
          rcd_sap_del_det.hipos,
          rcd_sap_del_det.hievw,
          rcd_sap_del_det.ladgr,
          rcd_sap_del_det.tragr,
          rcd_sap_del_det.vkbur,
          rcd_sap_del_det.vkgrp,
          rcd_sap_del_det.vtweg,
          rcd_sap_del_det.spart,
          rcd_sap_del_det.grkor,
          rcd_sap_del_det.ean11,
          rcd_sap_del_det.sernr,
          rcd_sap_del_det.aeskd,
          rcd_sap_del_det.empst,
          rcd_sap_del_det.mfrgr,
          rcd_sap_del_det.vbrst,
          rcd_sap_del_det.labnk,
          rcd_sap_del_det.abrdt,
          rcd_sap_del_det.mfrpn,
          rcd_sap_del_det.mfrnr,
          rcd_sap_del_det.abrvw,
          rcd_sap_del_det.kdmat35,
          rcd_sap_del_det.kannr,
          rcd_sap_del_det.posex,
          rcd_sap_del_det.lieffz,
          rcd_sap_del_det.usr01,
          rcd_sap_del_det.usr02,
          rcd_sap_del_det.usr03,
          rcd_sap_del_det.usr04,
          rcd_sap_del_det.usr05,
          rcd_sap_del_det.matnr_external,
          rcd_sap_del_det.matnr_version,
          rcd_sap_del_det.matnr_guid,
          rcd_sap_del_det.matwa_external,
          rcd_sap_del_det.matwa_version,
          rcd_sap_del_det.matwa_guid,
          rcd_sap_del_det.zudat,
          rcd_sap_del_det.vfdat,
          rcd_sap_del_det.zzmeins01,
          rcd_sap_del_det.zzpalbas01_f,
          rcd_sap_del_det.vbelv,
          rcd_sap_del_det.posnv,
          rcd_sap_del_det.zzhalfpal,
          rcd_sap_del_det.zzstackable,
          rcd_sap_del_det.zznbrhompal,
          rcd_sap_del_det.zzpalbase_deliv,
          rcd_sap_del_det.zzpalspace_deliv,
          rcd_sap_del_det.zzmeins_deliv,
          rcd_sap_del_det.value1,
          rcd_sap_del_det.zrsp,
          rcd_sap_del_det.rate,
          rcd_sap_del_det.kostl,
          rcd_sap_del_det.vfdat1,
          rcd_sap_del_det.value,
          rcd_sap_del_det.zzbb4,
          rcd_sap_del_det.zzpi_id,
          rcd_sap_del_det.insmk,
          rcd_sap_del_det.spart1,
          rcd_sap_del_det.lgort_bez,
          rcd_sap_del_det.ladgr_bez,
          rcd_sap_del_det.tragr_bez,
          rcd_sap_del_det.vkbur_bez,
          rcd_sap_del_det.vkgrp_bez,
          rcd_sap_del_det.vtweg_bez,
          rcd_sap_del_det.spart_bez,
          rcd_sap_del_det.mfrgr_bez,
          rcd_sap_del_det.pstyv,
          rcd_sap_del_det.matkl1,
          rcd_sap_del_det.prodh,
          rcd_sap_del_det.umvkz,
          rcd_sap_del_det.umvkn,
          rcd_sap_del_det.kztlf,
          rcd_sap_del_det.uebtk,
          rcd_sap_del_det.uebto,
          rcd_sap_del_det.untto,
          rcd_sap_del_det.chspl,
          rcd_sap_del_det.xchbw,
          rcd_sap_del_det.posar,
          rcd_sap_del_det.sobkz,
          rcd_sap_del_det.pckpf,
          rcd_sap_del_det.magrv,
          rcd_sap_del_det.shkzg,
          rcd_sap_del_det.koqui,
          rcd_sap_del_det.aktnr,
          rcd_sap_del_det.kzumw,
          rcd_sap_del_det.kvgr1,
          rcd_sap_del_det.kvgr2,
          rcd_sap_del_det.kvgr3,
          rcd_sap_del_det.kvgr4,
          rcd_sap_del_det.kvgr5,
          rcd_sap_del_det.mvgr1,
          rcd_sap_del_det.mvgr2,
          rcd_sap_del_det.mvgr3,
          rcd_sap_del_det.mvgr4,
          rcd_sap_del_det.mvgr5,
          rcd_sap_del_det.pstyv_bez,
          rcd_sap_del_det.matkl_bez,
          rcd_sap_del_det.prodh_bez,
          rcd_sap_del_det.werks_bez,
          rcd_sap_del_det.kvgr1_bez,
          rcd_sap_del_det.kvgr2_bez,
          rcd_sap_del_det.kvgr3_bez,
          rcd_sap_del_det.kvgr4_bez,
          rcd_sap_del_det.kvgr5_bez,
          rcd_sap_del_det.mvgr1_bez,
          rcd_sap_del_det.mvgr2_bez,
          rcd_sap_del_det.mvgr3_bez,
          rcd_sap_del_det.mvgr4_bez,
          rcd_sap_del_det.mvgr5_bez,
          rcd_sap_del_det.dlvry_line_status,
          rcd_sap_del_det.znewitem,
          rcd_sap_del_det.kwmeng,
          rcd_sap_del_det.repmatnr,
          rcd_sap_del_det.lifnr,
          rcd_sap_del_det.lichn,
          rcd_sap_del_det.zztdu_per_palet,
          rcd_sap_del_det.zztdu_per_layer,
          rcd_sap_del_det.zzlfimg,
          rcd_sap_del_det.zzplqty);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

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
      rcd_sap_del_irf.vbeln := rcd_sap_del_det.vbeln;
      rcd_sap_del_irf.detseq := rcd_sap_del_det.detseq;
      rcd_sap_del_irf.irfseq := rcd_sap_del_irf.irfseq + 1;
      rcd_sap_del_irf.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_sap_del_irf.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_sap_del_irf.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_sap_del_irf.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_del_irf.doctype := lics_inbound_utility.get_variable('DOCTYPE');
      rcd_sap_del_irf.reason := lics_inbound_utility.get_variable('REASON');

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
      if rcd_sap_del_irf.vbeln is null then
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

      insert into sap_del_irf
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
         (rcd_sap_del_irf.vbeln,
          rcd_sap_del_irf.detseq,
          rcd_sap_del_irf.irfseq,
          rcd_sap_del_irf.qualf,
          rcd_sap_del_irf.belnr,
          rcd_sap_del_irf.posnr,
          rcd_sap_del_irf.datum,
          rcd_sap_del_irf.doctype,
          rcd_sap_del_irf.reason);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_irf;

   /**************************************************/
   /* This procedure performs the load trace routine */
   /**************************************************/
   procedure load_trace(par_vbeln in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_sequence number;
      rcd_sap_del_trace sap_del_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_data is
         select t01.dlvry_doc_num,
                t01.dlvry_type_code,
                t01.dlvry_procg_stage,
                t01.sales_org_code,
                t02.creatn_date,
                t02.creatn_yyyyppdd,
                t02.creatn_yyyyppw,
                t02.creatn_yyyypp,
                t02.creatn_yyyymm,
                t02.dlvry_eff_date,
                t02.dlvry_eff_yyyyppdd,
                t02.dlvry_eff_yyyyppw,
                t02.dlvry_eff_yyyypp,
                t02.dlvry_eff_yyyymm,
                t02.goods_issue_date,
                t02.goods_issue_yyyyppdd,
                t02.goods_issue_yyyyppw,
                t02.goods_issue_yyyypp,
                t02.goods_issue_yyyymm,
                t03.sold_to_cust_code,
                t03.bill_to_cust_code,
                t03.payer_cust_code,
                t03.ship_to_cust_code,
                t04.dlvry_doc_line_num,
                t04.matl_code,
                t04.matl_entd,
                t04.dlvry_uom_code,
                t04.dlvry_base_uom_code,
                t04.plant_code,
                t04.storage_locn_code,
                t04.distbn_chnl_code,
                t04.dlvry_qty,
                t04.allocated_qty,
                t04.ordered_qty,
                t04.dlvry_gross_weight,
                t04.dlvry_net_weight,
                t04.dlvry_weight_unit,
                t05.order_doc_num,
                t05.order_doc_line_num,
                t06.purch_order_doc_num,
                t06.purch_order_doc_line_num
          from --
               -- Delivery header information
               --
               (select t01.vbeln,
                       t01.vbeln as dlvry_doc_num,
                       t01.lfart as dlvry_type_code,
                       t01.dlvry_procg_stage as dlvry_procg_stage,
                       t01.vkorg as sales_org_code
                  from sap_del_hdr t01
                 where t01.vbeln = par_vbeln) t01,
               --
               -- Delivery time information
               --
               (select t01.vbeln,
                       t01.creatn_date as creatn_date,
                       t02.mars_yyyyppdd as creatn_yyyyppdd,
                       t02.mars_week as creatn_yyyyppw,
                       t02.mars_period as creatn_yyyypp,
                       (t02.year_num * 100) + t02.month_num as creatn_yyyymm,
                       t01.dlvry_eff_date as dlvry_eff_date,
                       t03.mars_yyyyppdd as dlvry_eff_yyyyppdd,
                       t03.mars_week as dlvry_eff_yyyyppw,
                       t03.mars_period as dlvry_eff_yyyypp,
                       (t03.year_num * 100) + t03.month_num as dlvry_eff_yyyymm,
                       t01.goods_issue_date as goods_issue_date,
                       t04.mars_yyyyppdd as goods_issue_yyyyppdd,
                       t04.mars_week as goods_issue_yyyyppw,
                       t04.mars_period as goods_issue_yyyypp,
                       (t04.year_num * 100) + t04.month_num as goods_issue_yyyymm
                  from (select t01.vbeln,
                               max(case when t01.qualf = '015' then dw_to_date(nvl(ltrim(t01.isdd,'0'),ltrim(t01.ntanf,'0')),'yyyymmdd') end) as creatn_date,
                               max(case when t01.qualf = '007' then dw_to_date(nvl(ltrim(t01.isdd,'0'),ltrim(t01.ntanf,'0')),'yyyymmdd') end) as dlvry_eff_date,
                               max(case when t01.qualf = '006' then dw_to_date(nvl(ltrim(t01.isdd,'0'),ltrim(t01.ntanf,'0')),'yyyymmdd') end) as goods_issue_date
                          from sap_del_tim t01
                         where vbeln = par_vbeln
                           and t01.qualf in ('006','007','015')
                         group by t01.vbeln) t01,
                       mars_date t02,
                       mars_date t03,
                       mars_date t04
                 where t01.creatn_date = t02.calendar_date(+)
                   and t01.dlvry_eff_date = t03.calendar_date(+)
                   and t01.goods_issue_date = t04.calendar_date(+)) t02,
               --
               -- Delivery partner information
               --
               (select t01.vbeln,
                       max(case when t01.partner_q = 'AG' then t01.partner_id end) as sold_to_cust_code,
                       max(case when t01.partner_q = 'RE' then t01.partner_id end) as bill_to_cust_code,
                       max(case when t01.partner_q = 'RG' then t01.partner_id end) as payer_cust_code,
                       max(case when t01.partner_q = 'WE' then t01.partner_id end) as ship_to_cust_code
                  from sap_del_add t01
                 where t01.vbeln = par_vbeln
                   and t01.partner_q in ('AG','RE','RG','WE')
                 group by t01.vbeln) t03,
               --
               -- Delivery line information
               --
               (select t01.vbeln,
                       t01.detseq,
                       t01.posnr as dlvry_doc_line_num,
                       t01.matnr as matl_code,
                       t01.matwa as matl_entd,
                       t01.vrkme as dlvry_uom_code,
                       t01.meins as dlvry_base_uom_code,
                       t01.werks as plant_code,
                       t01.lgort as storage_locn_code,
                       t01.vtweg as distbn_chnl_code,
                       t01.lfimg as dlvry_qty,
                       nvl(t01.kwmeng,0) as ordered_qty,
                       t02.allocated_qty,
                       t02.dlvry_gross_weight,
                       t02.dlvry_net_weight,
                       t02.dlvry_weight_unit
                  from sap_del_det t01,
                       (select t01.vbeln,
                               t01.hipos,
                               sum(nvl(t01.zzlfimg,0)) as allocated_qty,
                               sum(nvl(t01.brgew,0)) as dlvry_gross_weight,
                               sum(nvl(t01.ntgew,0)) as dlvry_net_weight,
                               max(t01.gewei) as dlvry_weight_unit
                          from sap_del_det t01
                         where t01.vbeln = par_vbeln
                           and t01.posnr > '900000'
                         group by t01.vbeln, t01.hipos) t02
                 where t01.vbeln = t02.vbeln(+)
                   and t01.posnr = t02.hipos(+)
                   and t01.vbeln = par_vbeln
                   and nvl(t01.lfimg,0) != 0
                   and t01.posnr < '900000') t04,
               --
               -- Delivery line reference information - sales order
               --
               (select t01.vbeln,
                       t01.detseq,
                       t01.order_doc_num,
                       t01.order_doc_line_num
                  from (select t01.vbeln as vbeln,
                               t01.detseq as detseq,
                               t01.belnr as order_doc_num,
                               t01.posnr as order_doc_line_num,
                               rank() over (partition by t01.vbeln, t01.detseq order by t01.irfseq asc) as rnkseq
                          from sap_del_irf t01
                         where t01.vbeln = par_vbeln
                           and t01.qualf in ('C','H','I','K','L')
                           and not(t01.belnr is null)
                           and not(t01.datum is null)) t01
                 where t01.rnkseq = 1) t05,
               --
               -- Delivery line reference information - purchase order
               --
               (select t01.vbeln,
                       t01.detseq,
                       t01.purch_order_doc_num,
                       t01.purch_order_doc_line_num
                  from (select t01.vbeln as vbeln,
                               t01.detseq as detseq,
                               t01.belnr as purch_order_doc_num,
                               t01.posnr as purch_order_doc_line_num,
                               rank() over (partition by t01.vbeln, t01.detseq order by t01.irfseq asc) as rnkseq
                          from sap_del_irf t01
                         where t01.vbeln = par_vbeln
                           and t01.qualf in ('V')
                           and not(t01.belnr is null)) t01
                 where t01.rnkseq = 1) t06
         --
         -- Joins
         --
         where t01.vbeln = t02.vbeln(+)
           and t01.vbeln = t03.vbeln(+)
           and t01.vbeln = t04.vbeln(+)
           and t04.vbeln = t05.vbeln(+)
           and t04.detseq = t05.detseq(+)
           and t04.vbeln = t06.vbeln(+)
           and t04.detseq = t06.detseq(+);
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
      /* Initialise the delivery trace data
      /*-*/
      rcd_sap_del_trace.trace_seqn := var_sequence;
      rcd_sap_del_trace.trace_date := sysdate;
      rcd_sap_del_trace.trace_status := '*ACTIVE';

      /*-*/
      /* Retrieve the delivery trace data
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
         rcd_sap_del_trace.trace_status := '*ACTIVE';

         /*-*/
         /* Deleted delivery line
         /* **notes** no delivery lines found
         /*-*/
         if rcd_ods_data.dlvry_doc_line_num is null then
            rcd_sap_del_trace.trace_status := '*DELETED';
         end if;

         /*-*/
         /* Initialise the delivery trace row
         /*-*/
         rcd_sap_del_trace.company_code := rcd_ods_data.sales_org_code;
         rcd_sap_del_trace.dlvry_doc_num := rcd_ods_data.dlvry_doc_num;
         rcd_sap_del_trace.dlvry_type_code := rcd_ods_data.dlvry_type_code;
         rcd_sap_del_trace.dlvry_procg_stage := rcd_ods_data.dlvry_procg_stage;
         rcd_sap_del_trace.sales_org_code := rcd_ods_data.sales_org_code;
         rcd_sap_del_trace.creatn_date := rcd_ods_data.creatn_date;
         rcd_sap_del_trace.creatn_yyyyppdd := rcd_ods_data.creatn_yyyyppdd;
         rcd_sap_del_trace.creatn_yyyyppw := rcd_ods_data.creatn_yyyyppw;
         rcd_sap_del_trace.creatn_yyyypp := rcd_ods_data.creatn_yyyypp;
         rcd_sap_del_trace.creatn_yyyymm := rcd_ods_data.creatn_yyyymm;
         rcd_sap_del_trace.dlvry_eff_date := rcd_ods_data.dlvry_eff_date;
         rcd_sap_del_trace.dlvry_eff_yyyyppdd := rcd_ods_data.dlvry_eff_yyyyppdd;
         rcd_sap_del_trace.dlvry_eff_yyyyppw := rcd_ods_data.dlvry_eff_yyyyppw;
         rcd_sap_del_trace.dlvry_eff_yyyypp := rcd_ods_data.dlvry_eff_yyyypp;
         rcd_sap_del_trace.dlvry_eff_yyyymm := rcd_ods_data.dlvry_eff_yyyymm;
         rcd_sap_del_trace.goods_issue_date := rcd_ods_data.goods_issue_date;
         rcd_sap_del_trace.goods_issue_yyyyppdd := rcd_ods_data.goods_issue_yyyyppdd;
         rcd_sap_del_trace.goods_issue_yyyyppw := rcd_ods_data.goods_issue_yyyyppw;
         rcd_sap_del_trace.goods_issue_yyyypp := rcd_ods_data.goods_issue_yyyypp;
         rcd_sap_del_trace.goods_issue_yyyymm := rcd_ods_data.goods_issue_yyyymm;
         rcd_sap_del_trace.sold_to_cust_code := rcd_ods_data.sold_to_cust_code;
         rcd_sap_del_trace.bill_to_cust_code := rcd_ods_data.bill_to_cust_code;
         rcd_sap_del_trace.payer_cust_code := rcd_ods_data.payer_cust_code;
         rcd_sap_del_trace.ship_to_cust_code := rcd_ods_data.ship_to_cust_code;
         rcd_sap_del_trace.dlvry_doc_line_num := rcd_ods_data.dlvry_doc_line_num;
         rcd_sap_del_trace.matl_code := rcd_ods_data.matl_code;
         rcd_sap_del_trace.matl_entd := rcd_ods_data.matl_entd;
         rcd_sap_del_trace.dlvry_uom_code := rcd_ods_data.dlvry_uom_code;
         rcd_sap_del_trace.dlvry_base_uom_code := rcd_ods_data.dlvry_base_uom_code;
         rcd_sap_del_trace.plant_code := rcd_ods_data.plant_code;
         rcd_sap_del_trace.storage_locn_code := rcd_ods_data.storage_locn_code;
         rcd_sap_del_trace.distbn_chnl_code := rcd_ods_data.distbn_chnl_code;
         rcd_sap_del_trace.dlvry_qty := rcd_ods_data.dlvry_qty;
         rcd_sap_del_trace.allocated_qty := rcd_ods_data.allocated_qty;
         rcd_sap_del_trace.ordered_qty := rcd_ods_data.ordered_qty;
         rcd_sap_del_trace.dlvry_gross_weight := rcd_ods_data.dlvry_gross_weight;
         rcd_sap_del_trace.dlvry_net_weight := rcd_ods_data.dlvry_net_weight;
         rcd_sap_del_trace.dlvry_weight_unit := rcd_ods_data.dlvry_weight_unit;
         rcd_sap_del_trace.order_doc_num := rcd_ods_data.order_doc_num;
         rcd_sap_del_trace.order_doc_line_num := rcd_ods_data.order_doc_line_num;
         rcd_sap_del_trace.purch_order_doc_num := rcd_ods_data.purch_order_doc_num;
         rcd_sap_del_trace.purch_order_doc_line_num := rcd_ods_data.purch_order_doc_line_num;
         if not(rcd_sap_del_trace.purch_order_doc_line_num is null) then 
            rcd_sap_del_trace.purch_order_doc_line_num := lpad(ltrim(rcd_ods_data.purch_order_doc_line_num,'0'),5,'0');
         end if;

         /*-*/
         /* Insert the delivery trace row
         /*-*/
         insert into sap_del_trace values rcd_sap_del_trace;

      end loop;
      close csr_ods_data;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_trace;

end ods_atlods16;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_atlods16 for ods_app.ods_atlods16;
grant execute on ods_atlods16 to lics_app;