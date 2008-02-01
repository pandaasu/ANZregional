/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad04
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad04 - Inbound Material Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad04 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad04;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad04 as

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
   procedure process_record_pch(par_record in varchar2);
   procedure process_record_pcr(par_record in varchar2);
   procedure process_record_pih(par_record in varchar2);
   procedure process_record_pie(par_record in varchar2);
   procedure process_record_pir(par_record in varchar2);
   procedure process_record_pit(par_record in varchar2);
   procedure process_record_pim(par_record in varchar2);
   procedure process_record_pid(par_record in varchar2);
   procedure process_record_moe(par_record in varchar2);
   procedure process_record_gme(par_record in varchar2);
   procedure process_record_lcd(par_record in varchar2);
   procedure process_record_mkt(par_record in varchar2);
   procedure process_record_mrc(par_record in varchar2);
   procedure process_record_zmc(par_record in varchar2);
   procedure process_record_mrd(par_record in varchar2);
   procedure process_record_mpm(par_record in varchar2);
   procedure process_record_mvm(par_record in varchar2);
   procedure process_record_mum(par_record in varchar2);
   procedure process_record_mpv(par_record in varchar2);
   procedure process_record_uom(par_record in varchar2);
   procedure process_record_uoe(par_record in varchar2);
   procedure process_record_mbe(par_record in varchar2);
   procedure process_record_mgn(par_record in varchar2);
   procedure process_record_mlg(par_record in varchar2);
   procedure process_record_sad(par_record in varchar2);
   procedure process_record_zsd(par_record in varchar2);
   procedure process_record_tax(par_record in varchar2);
   procedure process_record_txh(par_record in varchar2);
   procedure process_record_txl(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_mat_hdr lads_mat_hdr%rowtype;
   rcd_lads_mat_pch lads_mat_pch%rowtype;
   rcd_lads_mat_pcr lads_mat_pcr%rowtype;
   rcd_lads_mat_pih lads_mat_pih%rowtype;
   rcd_lads_mat_pie lads_mat_pie%rowtype;
   rcd_lads_mat_pir lads_mat_pir%rowtype;
   rcd_lads_mat_pit lads_mat_pit%rowtype;
   rcd_lads_mat_pim lads_mat_pim%rowtype;
   rcd_lads_mat_pid lads_mat_pid%rowtype;
   rcd_lads_mat_moe lads_mat_moe%rowtype;
   rcd_lads_mat_gme lads_mat_gme%rowtype;
   rcd_lads_mat_lcd lads_mat_lcd%rowtype;
   rcd_lads_mat_mkt lads_mat_mkt%rowtype;
   rcd_lads_mat_mrc lads_mat_mrc%rowtype;
   rcd_lads_mat_zmc lads_mat_zmc%rowtype;
   rcd_lads_mat_mrd lads_mat_mrd%rowtype;
   rcd_lads_mat_mpm lads_mat_mpm%rowtype;
   rcd_lads_mat_mvm lads_mat_mvm%rowtype;
   rcd_lads_mat_mum lads_mat_mum%rowtype;
   rcd_lads_mat_mpv lads_mat_mpv%rowtype;
   rcd_lads_mat_uom lads_mat_uom%rowtype;
   rcd_lads_mat_uoe lads_mat_uoe%rowtype;
   rcd_lads_mat_mbe lads_mat_mbe%rowtype;
   rcd_lads_mat_mgn lads_mat_mgn%rowtype;
   rcd_lads_mat_mlg lads_mat_mlg%rowtype;
   rcd_lads_mat_sad lads_mat_sad%rowtype;
   rcd_lads_mat_zsd lads_mat_zsd%rowtype;
   rcd_lads_mat_tax lads_mat_tax%rowtype;
   rcd_lads_mat_txh lads_mat_txh%rowtype;
   rcd_lads_mat_txl lads_mat_txl%rowtype;

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
      lics_inbound_utility.set_definition('HDR','MATNR',18);
      lics_inbound_utility.set_definition('HDR','ERSDA',8);
      lics_inbound_utility.set_definition('HDR','ERNAM',12);
      lics_inbound_utility.set_definition('HDR','LAEDA',8);
      lics_inbound_utility.set_definition('HDR','AENAM',12);
      lics_inbound_utility.set_definition('HDR','PSTAT',15);
      lics_inbound_utility.set_definition('HDR','LVORM',1);
      lics_inbound_utility.set_definition('HDR','MTART',4);
      lics_inbound_utility.set_definition('HDR','MBRSH',1);
      lics_inbound_utility.set_definition('HDR','MATKL',9);
      lics_inbound_utility.set_definition('HDR','BISMT',18);
      lics_inbound_utility.set_definition('HDR','MEINS',3);
      lics_inbound_utility.set_definition('HDR','BSTME',3);
      lics_inbound_utility.set_definition('HDR','ZEINR',22);
      lics_inbound_utility.set_definition('HDR','ZEIAR',3);
      lics_inbound_utility.set_definition('HDR','ZEIVR',2);
      lics_inbound_utility.set_definition('HDR','ZEIFO',4);
      lics_inbound_utility.set_definition('HDR','AESZN',6);
      lics_inbound_utility.set_definition('HDR','BLATT',3);
      lics_inbound_utility.set_definition('HDR','BLANZ',3);
      lics_inbound_utility.set_definition('HDR','FERTH',18);
      lics_inbound_utility.set_definition('HDR','FORMT',4);
      lics_inbound_utility.set_definition('HDR','GROES',32);
      lics_inbound_utility.set_definition('HDR','WRKST',14);
      lics_inbound_utility.set_definition('HDR','NORMT',18);
      lics_inbound_utility.set_definition('HDR','LABOR',3);
      lics_inbound_utility.set_definition('HDR','EKWSL',4);
      lics_inbound_utility.set_definition('HDR','BRGEW',14);
      lics_inbound_utility.set_definition('HDR','NTGEW',14);
      lics_inbound_utility.set_definition('HDR','GEWEI',3);
      lics_inbound_utility.set_definition('HDR','VOLUM',14);
      lics_inbound_utility.set_definition('HDR','VOLEH',3);
      lics_inbound_utility.set_definition('HDR','BEHVO',2);
      lics_inbound_utility.set_definition('HDR','RAUBE',2);
      lics_inbound_utility.set_definition('HDR','TEMPB',2);
      lics_inbound_utility.set_definition('HDR','TRAGR',4);
      lics_inbound_utility.set_definition('HDR','STOFF',18);
      lics_inbound_utility.set_definition('HDR','SPART',2);
      lics_inbound_utility.set_definition('HDR','KUNNR',10);
      lics_inbound_utility.set_definition('HDR','WESCH',14);
      lics_inbound_utility.set_definition('HDR','BWVOR',1);
      lics_inbound_utility.set_definition('HDR','BWSCL',1);
      lics_inbound_utility.set_definition('HDR','SAISO',4);
      lics_inbound_utility.set_definition('HDR','ETIAR',2);
      lics_inbound_utility.set_definition('HDR','ETIFO',2);
      lics_inbound_utility.set_definition('HDR','EAN11',18);
      lics_inbound_utility.set_definition('HDR','NUMTP',2);
      lics_inbound_utility.set_definition('HDR','LAENG',14);
      lics_inbound_utility.set_definition('HDR','BREIT',14);
      lics_inbound_utility.set_definition('HDR','HOEHE',14);
      lics_inbound_utility.set_definition('HDR','MEABM',3);
      lics_inbound_utility.set_definition('HDR','PRDHA',18);
      lics_inbound_utility.set_definition('HDR','CADKZ',1);
      lics_inbound_utility.set_definition('HDR','ERGEW',14);
      lics_inbound_utility.set_definition('HDR','ERGEI',3);
      lics_inbound_utility.set_definition('HDR','ERVOL',14);
      lics_inbound_utility.set_definition('HDR','ERVOE',3);
      lics_inbound_utility.set_definition('HDR','GEWTO',3);
      lics_inbound_utility.set_definition('HDR','VOLTO',3);
      lics_inbound_utility.set_definition('HDR','VABME',1);
      lics_inbound_utility.set_definition('HDR','KZKFG',1);
      lics_inbound_utility.set_definition('HDR','XCHPF',1);
      lics_inbound_utility.set_definition('HDR','VHART',4);
      lics_inbound_utility.set_definition('HDR','FUELG',3);
      lics_inbound_utility.set_definition('HDR','STFAK',5);
      lics_inbound_utility.set_definition('HDR','MAGRV',4);
      lics_inbound_utility.set_definition('HDR','BEGRU',4);
      lics_inbound_utility.set_definition('HDR','QMPUR',1);
      lics_inbound_utility.set_definition('HDR','RBNRM',9);
      lics_inbound_utility.set_definition('HDR','MHDRZ',6);
      lics_inbound_utility.set_definition('HDR','MHDHB',6);
      lics_inbound_utility.set_definition('HDR','MHDLP',5);
      lics_inbound_utility.set_definition('HDR','VPSTA',15);
      lics_inbound_utility.set_definition('HDR','EXTWG',18);
      lics_inbound_utility.set_definition('HDR','MSTAE',2);
      lics_inbound_utility.set_definition('HDR','MSTAV',2);
      lics_inbound_utility.set_definition('HDR','MSTDE',8);
      lics_inbound_utility.set_definition('HDR','MSTDV',8);
      lics_inbound_utility.set_definition('HDR','KZUMW',1);
      lics_inbound_utility.set_definition('HDR','KOSCH',18);
      lics_inbound_utility.set_definition('HDR','NRFHG',1);
      lics_inbound_utility.set_definition('HDR','MFRPN',40);
      lics_inbound_utility.set_definition('HDR','MFRNR',10);
      lics_inbound_utility.set_definition('HDR','BMATN',18);
      lics_inbound_utility.set_definition('HDR','MPROF',4);
      lics_inbound_utility.set_definition('HDR','PROFL',3);
      lics_inbound_utility.set_definition('HDR','IHIVI',1);
      lics_inbound_utility.set_definition('HDR','ILOOS',1);
      lics_inbound_utility.set_definition('HDR','KZGVH',1);
      lics_inbound_utility.set_definition('HDR','XGCHP',1);
      lics_inbound_utility.set_definition('HDR','COMPL',2);
      lics_inbound_utility.set_definition('HDR','KZEFF',1);
      lics_inbound_utility.set_definition('HDR','RDMHD',1);
      lics_inbound_utility.set_definition('HDR','IPRKZ',1);
      lics_inbound_utility.set_definition('HDR','PRZUS',1);
      lics_inbound_utility.set_definition('HDR','MTPOS_MARA',4);
      lics_inbound_utility.set_definition('HDR','GEWTO_NEW',5);
      lics_inbound_utility.set_definition('HDR','VOLTO_NEW',5);
      lics_inbound_utility.set_definition('HDR','WRKST_NEW',48);
      lics_inbound_utility.set_definition('HDR','AENNR',12);
      lics_inbound_utility.set_definition('HDR','MATFI',1);
      lics_inbound_utility.set_definition('HDR','CMREL',1);
      lics_inbound_utility.set_definition('HDR','SATNR',18);
      lics_inbound_utility.set_definition('HDR','SLED_BBD',1);
      lics_inbound_utility.set_definition('HDR','GTIN_VARIANT',2);
      lics_inbound_utility.set_definition('HDR','GENNR',18);
      lics_inbound_utility.set_definition('HDR','SERLV',1);
      lics_inbound_utility.set_definition('HDR','RMATP',18);
      lics_inbound_utility.set_definition('HDR','ZZDECVOLUM',15);
      lics_inbound_utility.set_definition('HDR','ZZDECVOLEH',3);
      lics_inbound_utility.set_definition('HDR','ZZDECCOUNT',15);
      lics_inbound_utility.set_definition('HDR','ZZDECCOUNIT',3);
      lics_inbound_utility.set_definition('HDR','ZZPPROWEIGHT',15);
      lics_inbound_utility.set_definition('HDR','ZZPPROWUNIT',3);
      lics_inbound_utility.set_definition('HDR','ZZPPROVOLUM',15);
      lics_inbound_utility.set_definition('HDR','ZZPPROVUNIT',3);
      lics_inbound_utility.set_definition('HDR','ZZPPROCOUNT',15);
      lics_inbound_utility.set_definition('HDR','ZZPPROCUNIT',3);
      lics_inbound_utility.set_definition('HDR','ZZALPHA01',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA02',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA03',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA04',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA05',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA06',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA07',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA08',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA09',8);
      lics_inbound_utility.set_definition('HDR','ZZALPHA10',8);
      lics_inbound_utility.set_definition('HDR','ZZNUM01',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM02',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM03',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM04',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM05',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM06',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM07',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM08',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM09',10);
      lics_inbound_utility.set_definition('HDR','ZZNUM10',10);
      lics_inbound_utility.set_definition('HDR','ZZCHECK01',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK02',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK03',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK04',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK05',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK06',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK07',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK08',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK09',1);
      lics_inbound_utility.set_definition('HDR','ZZCHECK10',1);
      lics_inbound_utility.set_definition('HDR','ZZPLAN_ITEM',6);
      lics_inbound_utility.set_definition('HDR','ZZISINT',1);
      lics_inbound_utility.set_definition('HDR','ZZISMCU',1);
      lics_inbound_utility.set_definition('HDR','ZZISPRO',1);
      lics_inbound_utility.set_definition('HDR','ZZISRSU',1);
      lics_inbound_utility.set_definition('HDR','ZZISSC',1);
      lics_inbound_utility.set_definition('HDR','ZZISSFP',1);
      lics_inbound_utility.set_definition('HDR','ZZISTDU',1);
      lics_inbound_utility.set_definition('HDR','ZZISTRA',1);
      lics_inbound_utility.set_definition('HDR','ZZSTATUSCODE',3);
      lics_inbound_utility.set_definition('HDR','ZZITEMOWNER',12);
      lics_inbound_utility.set_definition('HDR','ZZCHANGEDBY',12);
      lics_inbound_utility.set_definition('HDR','ZZMATTIM',3);
      lics_inbound_utility.set_definition('HDR','ZZREPMATNR',18);
      /*-*/
      lics_inbound_utility.set_definition('PCH','IDOC_PCH',3);
      lics_inbound_utility.set_definition('PCH','KVEWE',1);
      lics_inbound_utility.set_definition('PCH','KOTABNR',3);
      lics_inbound_utility.set_definition('PCH','KAPPL',2);
      lics_inbound_utility.set_definition('PCH','KSCHL',4);
      lics_inbound_utility.set_definition('PCH','VAKEY',100);
      lics_inbound_utility.set_definition('PCH','VKORG',4);
      /*-*/
      lics_inbound_utility.set_definition('PCR','IDOC_PCR',3);
      lics_inbound_utility.set_definition('PCR','KNUMH',10);
      lics_inbound_utility.set_definition('PCR','DATAB',8);
      lics_inbound_utility.set_definition('PCR','DATBI',8);
      lics_inbound_utility.set_definition('PCR','PACKNR',22);
      lics_inbound_utility.set_definition('PCR','PACKNR1',22);
      lics_inbound_utility.set_definition('PCR','PACKNR2',22);
      lics_inbound_utility.set_definition('PCR','PACKNR3',22);
      lics_inbound_utility.set_definition('PCR','PACKNR4',22);
      /*-*/
      lics_inbound_utility.set_definition('PIH','IDOC_PIH',3);
      lics_inbound_utility.set_definition('PIH','PACKNR',22);
      lics_inbound_utility.set_definition('PIH','HEIGHT',15);
      lics_inbound_utility.set_definition('PIH','WIDTH',15);
      lics_inbound_utility.set_definition('PIH','LENGTH',15);
      lics_inbound_utility.set_definition('PIH','TAREWEI',17);
      lics_inbound_utility.set_definition('PIH','LOADWEI',17);
      lics_inbound_utility.set_definition('PIH','TOTLWEI',17);
      lics_inbound_utility.set_definition('PIH','TAREVOL',17);
      lics_inbound_utility.set_definition('PIH','LOADVOL',17);
      lics_inbound_utility.set_definition('PIH','TOTLVOL',17);
      lics_inbound_utility.set_definition('PIH','POBJID',20);
      lics_inbound_utility.set_definition('PIH','STFAC',6);
      lics_inbound_utility.set_definition('PIH','CHDAT',8);
      lics_inbound_utility.set_definition('PIH','UNITDIM',3);
      lics_inbound_utility.set_definition('PIH','UNITWEI',3);
      lics_inbound_utility.set_definition('PIH','UNITWEI_MAX',3);
      lics_inbound_utility.set_definition('PIH','UNITVOL',3);
      lics_inbound_utility.set_definition('PIH','UNITVOL_MAX',3);
      /*-*/
      lics_inbound_utility.set_definition('PIE','IDOC_PIE',3);
      lics_inbound_utility.set_definition('PIE','EAN11',18);
      lics_inbound_utility.set_definition('PIE','EANTP',2);
      lics_inbound_utility.set_definition('PIE','HPEAN',1);
      /*-*/
      lics_inbound_utility.set_definition('PIR','IDOC_PIR',3);
      lics_inbound_utility.set_definition('PIR','Z_LCDID',5);
      lics_inbound_utility.set_definition('PIR','Z_LCDNR',18);
      /*-*/
      lics_inbound_utility.set_definition('PIT','IDOC_PIT',3);
      lics_inbound_utility.set_definition('PIT','SPRAS',1);
      lics_inbound_utility.set_definition('PIT','CONTENT',40);
      /*-*/
      lics_inbound_utility.set_definition('PIM','IDOC_PIM',3);
      lics_inbound_utility.set_definition('PIM','MOE',4);
      lics_inbound_utility.set_definition('PIM','USAGECODE',3);
      lics_inbound_utility.set_definition('PIM','DATAB',8);
      lics_inbound_utility.set_definition('PIM','DATED',8);
      /*-*/
      lics_inbound_utility.set_definition('PID','IDOC_PID',3);
      lics_inbound_utility.set_definition('PID','PACKITEM',6);
      lics_inbound_utility.set_definition('PID','DETAIL_ITEMTYPE',2);
      lics_inbound_utility.set_definition('PID','COMPONENT',20);
      lics_inbound_utility.set_definition('PID','TRGQTY',17);
      lics_inbound_utility.set_definition('PID','MINQTY',17);
      lics_inbound_utility.set_definition('PID','RNDQTY',17);
      lics_inbound_utility.set_definition('PID','UNITQTY',3);
      lics_inbound_utility.set_definition('PID','INDMAPACO',1);
      /*-*/
      lics_inbound_utility.set_definition('MOE','IDOC_MOE',3);
      lics_inbound_utility.set_definition('MOE','MATNR',18);
      lics_inbound_utility.set_definition('MOE','USAGECODE',3);
      lics_inbound_utility.set_definition('MOE','MOE',4);
      lics_inbound_utility.set_definition('MOE','DATAB',8);
      lics_inbound_utility.set_definition('MOE','DATED',8);
      /*-*/
      lics_inbound_utility.set_definition('GME','IDOC_GME',3);
      lics_inbound_utility.set_definition('GME','GROUPTYPE',2);
      lics_inbound_utility.set_definition('GME','GROUPMOE',4);
      lics_inbound_utility.set_definition('GME','USAGECODE',3);
      lics_inbound_utility.set_definition('GME','DATAB',8);
      lics_inbound_utility.set_definition('GME','DATED',8);
      /*-*/
      lics_inbound_utility.set_definition('LCD','IDOC_LCD',3);
      lics_inbound_utility.set_definition('LCD','Z_MATNR',18);
      lics_inbound_utility.set_definition('LCD','Z_LCDID',5);
      lics_inbound_utility.set_definition('LCD','Z_LCDNR',18);
      /*-*/
      lics_inbound_utility.set_definition('MKT','IDOC_MKT',3);
      lics_inbound_utility.set_definition('MKT','MSGFN',3);
      lics_inbound_utility.set_definition('MKT','SPRAS',1);
      lics_inbound_utility.set_definition('MKT','MAKTX',40);
      lics_inbound_utility.set_definition('MKT','SPRAS_ISO',2);
      /*-*/
      lics_inbound_utility.set_definition('MRC','IDOC_MRC',3);
      lics_inbound_utility.set_definition('MRC','MSGFN',3);
      lics_inbound_utility.set_definition('MRC','WERKS',4);
      lics_inbound_utility.set_definition('MRC','PSTAT',15);
      lics_inbound_utility.set_definition('MRC','LVORM',1);
      lics_inbound_utility.set_definition('MRC','BWTTY',1);
      lics_inbound_utility.set_definition('MRC','MAABC',1);
      lics_inbound_utility.set_definition('MRC','KZKRI',1);
      lics_inbound_utility.set_definition('MRC','EKGRP',3);
      lics_inbound_utility.set_definition('MRC','AUSME',3);
      lics_inbound_utility.set_definition('MRC','DISPR',4);
      lics_inbound_utility.set_definition('MRC','DISMM',2);
      lics_inbound_utility.set_definition('MRC','DISPO',3);
      lics_inbound_utility.set_definition('MRC','PLIFZ',3);
      lics_inbound_utility.set_definition('MRC','WEBAZ',3);
      lics_inbound_utility.set_definition('MRC','PERKZ',1);
      lics_inbound_utility.set_definition('MRC','AUSSS',5);
      lics_inbound_utility.set_definition('MRC','DISLS',2);
      lics_inbound_utility.set_definition('MRC','BESKZ',1);
      lics_inbound_utility.set_definition('MRC','SOBSL',2);
      lics_inbound_utility.set_definition('MRC','MINBE',14);
      lics_inbound_utility.set_definition('MRC','EISBE',14);
      lics_inbound_utility.set_definition('MRC','BSTMI',14);
      lics_inbound_utility.set_definition('MRC','BSTMA',14);
      lics_inbound_utility.set_definition('MRC','BSTFE',14);
      lics_inbound_utility.set_definition('MRC','BSTRF',14);
      lics_inbound_utility.set_definition('MRC','MABST',14);
      lics_inbound_utility.set_definition('MRC','LOSFX',12);
      lics_inbound_utility.set_definition('MRC','SBDKZ',1);
      lics_inbound_utility.set_definition('MRC','LAGPR',1);
      lics_inbound_utility.set_definition('MRC','ALTSL',1);
      lics_inbound_utility.set_definition('MRC','KZAUS',1);
      lics_inbound_utility.set_definition('MRC','AUSDT',8);
      lics_inbound_utility.set_definition('MRC','NFMAT',18);
      lics_inbound_utility.set_definition('MRC','KZBED',1);
      lics_inbound_utility.set_definition('MRC','MISKZ',1);
      lics_inbound_utility.set_definition('MRC','FHORI',3);
      lics_inbound_utility.set_definition('MRC','PFREI',1);
      lics_inbound_utility.set_definition('MRC','FFREI',1);
      lics_inbound_utility.set_definition('MRC','RGEKZ',1);
      lics_inbound_utility.set_definition('MRC','FEVOR',3);
      lics_inbound_utility.set_definition('MRC','BEARZ',6);
      lics_inbound_utility.set_definition('MRC','RUEZT',6);
      lics_inbound_utility.set_definition('MRC','TRANZ',6);
      lics_inbound_utility.set_definition('MRC','BASMG',14);
      lics_inbound_utility.set_definition('MRC','DZEIT',3);
      lics_inbound_utility.set_definition('MRC','MAXLZ',5);
      lics_inbound_utility.set_definition('MRC','LZEIH',3);
      lics_inbound_utility.set_definition('MRC','KZPRO',1);
      lics_inbound_utility.set_definition('MRC','GPMKZ',1);
      lics_inbound_utility.set_definition('MRC','UEETO',4);
      lics_inbound_utility.set_definition('MRC','UEETK',1);
      lics_inbound_utility.set_definition('MRC','UNETO',4);
      lics_inbound_utility.set_definition('MRC','WZEIT',3);
      lics_inbound_utility.set_definition('MRC','ATPKZ',1);
      lics_inbound_utility.set_definition('MRC','VZUSL',5);
      lics_inbound_utility.set_definition('MRC','HERBL',2);
      lics_inbound_utility.set_definition('MRC','INSMK',1);
      lics_inbound_utility.set_definition('MRC','SSQSS',8);
      lics_inbound_utility.set_definition('MRC','KZDKZ',1);
      lics_inbound_utility.set_definition('MRC','UMLMC',14);
      lics_inbound_utility.set_definition('MRC','LADGR',4);
      lics_inbound_utility.set_definition('MRC','XCHPF',1);
      lics_inbound_utility.set_definition('MRC','USEQU',1);
      lics_inbound_utility.set_definition('MRC','LGRAD',4);
      lics_inbound_utility.set_definition('MRC','AUFTL',1);
      lics_inbound_utility.set_definition('MRC','PLVAR',2);
      lics_inbound_utility.set_definition('MRC','OTYPE',2);
      lics_inbound_utility.set_definition('MRC','OBJID',8);
      lics_inbound_utility.set_definition('MRC','MTVFP',2);
      lics_inbound_utility.set_definition('MRC','PERIV',2);
      lics_inbound_utility.set_definition('MRC','KZKFK',1);
      lics_inbound_utility.set_definition('MRC','VRVEZ',6);
      lics_inbound_utility.set_definition('MRC','VBAMG',14);
      lics_inbound_utility.set_definition('MRC','VBEAZ',6);
      lics_inbound_utility.set_definition('MRC','LIZYK',4);
      lics_inbound_utility.set_definition('MRC','BWSCL',1);
      lics_inbound_utility.set_definition('MRC','KAUTB',1);
      lics_inbound_utility.set_definition('MRC','KORDB',1);
      lics_inbound_utility.set_definition('MRC','STAWN',17);
      lics_inbound_utility.set_definition('MRC','HERKL',3);
      lics_inbound_utility.set_definition('MRC','HERKR',3);
      lics_inbound_utility.set_definition('MRC','EXPME',3);
      lics_inbound_utility.set_definition('MRC','MTVER',4);
      lics_inbound_utility.set_definition('MRC','PRCTR',10);
      lics_inbound_utility.set_definition('MRC','TRAME',15);
      lics_inbound_utility.set_definition('MRC','MRPPP',3);
      lics_inbound_utility.set_definition('MRC','SAUFT',1);
      lics_inbound_utility.set_definition('MRC','FXHOR',3);
      lics_inbound_utility.set_definition('MRC','VRMOD',1);
      lics_inbound_utility.set_definition('MRC','VINT1',3);
      lics_inbound_utility.set_definition('MRC','VINT2',3);
      lics_inbound_utility.set_definition('MRC','STLAL',2);
      lics_inbound_utility.set_definition('MRC','STLAN',1);
      lics_inbound_utility.set_definition('MRC','PLNNR',8);
      lics_inbound_utility.set_definition('MRC','APLAL',2);
      lics_inbound_utility.set_definition('MRC','LOSGR',14);
      lics_inbound_utility.set_definition('MRC','SOBSK',2);
      lics_inbound_utility.set_definition('MRC','FRTME',3);
      lics_inbound_utility.set_definition('MRC','LGPRO',4);
      lics_inbound_utility.set_definition('MRC','DISGR',4);
      lics_inbound_utility.set_definition('MRC','KAUSF',5);
      lics_inbound_utility.set_definition('MRC','QZGTP',4);
      lics_inbound_utility.set_definition('MRC','TAKZT',3);
      lics_inbound_utility.set_definition('MRC','RWPRO',3);
      lics_inbound_utility.set_definition('MRC','COPAM',10);
      lics_inbound_utility.set_definition('MRC','ABCIN',1);
      lics_inbound_utility.set_definition('MRC','AWSLS',6);
      lics_inbound_utility.set_definition('MRC','SERNP',4);
      lics_inbound_utility.set_definition('MRC','STDPD',18);
      lics_inbound_utility.set_definition('MRC','SFEPR',4);
      lics_inbound_utility.set_definition('MRC','XMCNG',1);
      lics_inbound_utility.set_definition('MRC','QSSYS',4);
      lics_inbound_utility.set_definition('MRC','LFRHY',3);
      lics_inbound_utility.set_definition('MRC','RDPRF',4);
      lics_inbound_utility.set_definition('MRC','VRBMT',18);
      lics_inbound_utility.set_definition('MRC','VRBWK',4);
      lics_inbound_utility.set_definition('MRC','VRBDT',8);
      lics_inbound_utility.set_definition('MRC','VRBFK',5);
      lics_inbound_utility.set_definition('MRC','AUTRU',1);
      lics_inbound_utility.set_definition('MRC','PREFE',1);
      lics_inbound_utility.set_definition('MRC','PRENC',1);
      lics_inbound_utility.set_definition('MRC','PRENO',8);
      lics_inbound_utility.set_definition('MRC','PREND',8);
      lics_inbound_utility.set_definition('MRC','PRENE',1);
      lics_inbound_utility.set_definition('MRC','PRENG',8);
      lics_inbound_utility.set_definition('MRC','ITARK',1);
      lics_inbound_utility.set_definition('MRC','PRFRQ',7);
      lics_inbound_utility.set_definition('MRC','KZKUP',1);
      lics_inbound_utility.set_definition('MRC','STRGR',2);
      lics_inbound_utility.set_definition('MRC','LGFSB',4);
      lics_inbound_utility.set_definition('MRC','SCHGT',1);
      lics_inbound_utility.set_definition('MRC','CCFIX',1);
      lics_inbound_utility.set_definition('MRC','EPRIO',4);
      lics_inbound_utility.set_definition('MRC','QMATA',6);
      lics_inbound_utility.set_definition('MRC','PLNTY',1);
      lics_inbound_utility.set_definition('MRC','MMSTA',2);
      lics_inbound_utility.set_definition('MRC','SFCPF',6);
      lics_inbound_utility.set_definition('MRC','SHFLG',1);
      lics_inbound_utility.set_definition('MRC','SHZET',2);
      lics_inbound_utility.set_definition('MRC','MDACH',2);
      lics_inbound_utility.set_definition('MRC','KZECH',1);
      lics_inbound_utility.set_definition('MRC','MMSTD',8);
      lics_inbound_utility.set_definition('MRC','MFRGR',8);
      lics_inbound_utility.set_definition('MRC','FVIDK',4);
      lics_inbound_utility.set_definition('MRC','INDUS',2);
      lics_inbound_utility.set_definition('MRC','MOWNR',12);
      lics_inbound_utility.set_definition('MRC','MOGRU',6);
      lics_inbound_utility.set_definition('MRC','CASNR',15);
      lics_inbound_utility.set_definition('MRC','GPNUM',9);
      lics_inbound_utility.set_definition('MRC','STEUC',16);
      lics_inbound_utility.set_definition('MRC','FABKZ',1);
      lics_inbound_utility.set_definition('MRC','MATGR',20);
      lics_inbound_utility.set_definition('MRC','LOGGR',4);
      lics_inbound_utility.set_definition('MRC','VSPVB',10);
      lics_inbound_utility.set_definition('MRC','DPLFS',2);
      lics_inbound_utility.set_definition('MRC','DPLPU',1);
      lics_inbound_utility.set_definition('MRC','DPLHO',4);
      lics_inbound_utility.set_definition('MRC','MINLS',15);
      lics_inbound_utility.set_definition('MRC','MAXLS',15);
      lics_inbound_utility.set_definition('MRC','FIXLS',15);
      lics_inbound_utility.set_definition('MRC','LTINC',15);
      lics_inbound_utility.set_definition('MRC','COMPL',2);
      lics_inbound_utility.set_definition('MRC','CONVT',2);
      lics_inbound_utility.set_definition('MRC','FPRFM',3);
      lics_inbound_utility.set_definition('MRC','SHPRO',3);
      lics_inbound_utility.set_definition('MRC','FXPRU',1);
      lics_inbound_utility.set_definition('MRC','KZPSP',1);
      lics_inbound_utility.set_definition('MRC','OCMPF',6);
      lics_inbound_utility.set_definition('MRC','APOKZ',1);
      lics_inbound_utility.set_definition('MRC','AHDIS',1);
      lics_inbound_utility.set_definition('MRC','EISLO',15);
      lics_inbound_utility.set_definition('MRC','NCOST',1);
      lics_inbound_utility.set_definition('MRC','MEGRU',4);
      lics_inbound_utility.set_definition('MRC','ROTATION_DATE',1);
      lics_inbound_utility.set_definition('MRC','UCHKZ',1);
      lics_inbound_utility.set_definition('MRC','UCMAT',18);
      lics_inbound_utility.set_definition('MRC','MSGFN1',3);
      lics_inbound_utility.set_definition('MRC','OBJTY',2);
      lics_inbound_utility.set_definition('MRC','OBJID1',8);
      lics_inbound_utility.set_definition('MRC','ZAEHL',8);
      lics_inbound_utility.set_definition('MRC','OBJTY_V',2);
      lics_inbound_utility.set_definition('MRC','OBJID_V',8);
      lics_inbound_utility.set_definition('MRC','KZKBL',1);
      lics_inbound_utility.set_definition('MRC','STEUF',4);
      lics_inbound_utility.set_definition('MRC','STEUF_REF',1);
      lics_inbound_utility.set_definition('MRC','FGRU1',4);
      lics_inbound_utility.set_definition('MRC','FGRU2',4);
      lics_inbound_utility.set_definition('MRC','PLANV',3);
      lics_inbound_utility.set_definition('MRC','KTSCH',7);
      lics_inbound_utility.set_definition('MRC','KTSCH_REF',1);
      lics_inbound_utility.set_definition('MRC','BZOFFB',2);
      lics_inbound_utility.set_definition('MRC','BZOFFB_REF',1);
      lics_inbound_utility.set_definition('MRC','OFFSTB',7);
      lics_inbound_utility.set_definition('MRC','EHOFFB',3);
      lics_inbound_utility.set_definition('MRC','OFFSTB_REF',1);
      lics_inbound_utility.set_definition('MRC','BZOFFE',2);
      lics_inbound_utility.set_definition('MRC','BZOFFE_REF',1);
      lics_inbound_utility.set_definition('MRC','OFFSTE',7);
      lics_inbound_utility.set_definition('MRC','EHOFFE',3);
      lics_inbound_utility.set_definition('MRC','OFFSTE_REF',1);
      lics_inbound_utility.set_definition('MRC','MGFORM',6);
      lics_inbound_utility.set_definition('MRC','MGFORM_REF',1);
      lics_inbound_utility.set_definition('MRC','EWFORM',6);
      lics_inbound_utility.set_definition('MRC','EWFORM_REF',1);
      lics_inbound_utility.set_definition('MRC','PAR01',6);
      lics_inbound_utility.set_definition('MRC','PAR02',6);
      lics_inbound_utility.set_definition('MRC','PAR03',6);
      lics_inbound_utility.set_definition('MRC','PAR04',6);
      lics_inbound_utility.set_definition('MRC','PAR05',6);
      lics_inbound_utility.set_definition('MRC','PAR06',6);
      lics_inbound_utility.set_definition('MRC','PARU1',3);
      lics_inbound_utility.set_definition('MRC','PARU2',3);
      lics_inbound_utility.set_definition('MRC','PARU3',3);
      lics_inbound_utility.set_definition('MRC','PARU4',3);
      lics_inbound_utility.set_definition('MRC','PARU5',3);
      lics_inbound_utility.set_definition('MRC','PARU6',3);
      lics_inbound_utility.set_definition('MRC','PARV1',11);
      lics_inbound_utility.set_definition('MRC','PARV2',11);
      lics_inbound_utility.set_definition('MRC','PARV3',11);
      lics_inbound_utility.set_definition('MRC','PARV4',11);
      lics_inbound_utility.set_definition('MRC','PARV5',11);
      lics_inbound_utility.set_definition('MRC','PARV6',11);
      lics_inbound_utility.set_definition('MRC','MSGFN2',3);
      lics_inbound_utility.set_definition('MRC','PRGRP',18);
      lics_inbound_utility.set_definition('MRC','PRWRK',4);
      lics_inbound_utility.set_definition('MRC','UMREF',10);
      lics_inbound_utility.set_definition('MRC','PRGRP_EXTERNAL',40);
      lics_inbound_utility.set_definition('MRC','PRGRP_VERSION',10);
      lics_inbound_utility.set_definition('MRC','PRGRP_GUID',32);
      lics_inbound_utility.set_definition('MRC','MSGFN3',3);
      lics_inbound_utility.set_definition('MRC','VERSP',2);
      lics_inbound_utility.set_definition('MRC','PROPR',4);
      lics_inbound_utility.set_definition('MRC','MODAW',1);
      lics_inbound_utility.set_definition('MRC','MODAV',1);
      lics_inbound_utility.set_definition('MRC','KZPAR',1);
      lics_inbound_utility.set_definition('MRC','OPGRA',1);
      lics_inbound_utility.set_definition('MRC','KZINI',1);
      lics_inbound_utility.set_definition('MRC','PRMOD',1);
      lics_inbound_utility.set_definition('MRC','ALPHA',5);
      lics_inbound_utility.set_definition('MRC','BETA1',5);
      lics_inbound_utility.set_definition('MRC','GAMMA',5);
      lics_inbound_utility.set_definition('MRC','DELTA',5);
      lics_inbound_utility.set_definition('MRC','EPSIL',5);
      lics_inbound_utility.set_definition('MRC','SIGGR',7);
      lics_inbound_utility.set_definition('MRC','PERKZ1',1);
      lics_inbound_utility.set_definition('MRC','PRDAT',8);
      lics_inbound_utility.set_definition('MRC','PERAN',5);
      lics_inbound_utility.set_definition('MRC','PERIN',5);
      lics_inbound_utility.set_definition('MRC','PERIO',5);
      lics_inbound_utility.set_definition('MRC','PEREX',5);
      lics_inbound_utility.set_definition('MRC','ANZPR',5);
      lics_inbound_utility.set_definition('MRC','FIMON',5);
      lics_inbound_utility.set_definition('MRC','GWERT',15);
      lics_inbound_utility.set_definition('MRC','GWER1',15);
      lics_inbound_utility.set_definition('MRC','GWER2',15);
      lics_inbound_utility.set_definition('MRC','VMGWE',15);
      lics_inbound_utility.set_definition('MRC','VMGW1',15);
      lics_inbound_utility.set_definition('MRC','VMGW2',15);
      lics_inbound_utility.set_definition('MRC','TWERT',15);
      lics_inbound_utility.set_definition('MRC','VMTWE',15);
      lics_inbound_utility.set_definition('MRC','PRMAD',15);
      lics_inbound_utility.set_definition('MRC','VMMAD',15);
      lics_inbound_utility.set_definition('MRC','FSUMM',15);
      lics_inbound_utility.set_definition('MRC','VMFSU',15);
      lics_inbound_utility.set_definition('MRC','GEWGR',2);
      lics_inbound_utility.set_definition('MRC','THKOF',7);
      lics_inbound_utility.set_definition('MRC','AUSNA',30);
      lics_inbound_utility.set_definition('MRC','PROAB',10);
      /*-*/
      lics_inbound_utility.set_definition('ZMC','IDOC_ZMC',3);
      lics_inbound_utility.set_definition('ZMC','ZZMTART',2);
      lics_inbound_utility.set_definition('ZMC','ZZMATTIM_PL',3);
      lics_inbound_utility.set_definition('ZMC','ZZFPPSMOE',15);
      /*-*/
      lics_inbound_utility.set_definition('MRD','IDOC_MRD',3);
      lics_inbound_utility.set_definition('MRD','MSGFN',3);
      lics_inbound_utility.set_definition('MRD','LGORT',4);
      lics_inbound_utility.set_definition('MRD','PSTAT',15);
      lics_inbound_utility.set_definition('MRD','LVORM',1);
      lics_inbound_utility.set_definition('MRD','DISKZ',1);
      lics_inbound_utility.set_definition('MRD','LSOBS',2);
      lics_inbound_utility.set_definition('MRD','LMINB',14);
      lics_inbound_utility.set_definition('MRD','LBSTF',14);
      lics_inbound_utility.set_definition('MRD','HERKL',3);
      lics_inbound_utility.set_definition('MRD','EXPPG',1);
      lics_inbound_utility.set_definition('MRD','EXVER',2);
      lics_inbound_utility.set_definition('MRD','LGPBE',10);
      lics_inbound_utility.set_definition('MRD','PRCTL',10);
      lics_inbound_utility.set_definition('MRD','LWMKB',3);
      lics_inbound_utility.set_definition('MRD','BSKRF',24);
      /*-*/
      lics_inbound_utility.set_definition('MPM','IDOC_MPM',3);
      lics_inbound_utility.set_definition('MPM','MSGFN',3);
      lics_inbound_utility.set_definition('MPM','ERTAG',8);
      lics_inbound_utility.set_definition('MPM','PRWRT',15);
      lics_inbound_utility.set_definition('MPM','KOPRW',15);
      lics_inbound_utility.set_definition('MPM','SAIIN',7);
      lics_inbound_utility.set_definition('MPM','FIXKZ',1);
      lics_inbound_utility.set_definition('MPM','EXPRW',15);
      lics_inbound_utility.set_definition('MPM','ANTEI',6);
      /*-*/
      lics_inbound_utility.set_definition('MVM','IDOC_MVM',3);
      lics_inbound_utility.set_definition('MVM','MSGFN',3);
      lics_inbound_utility.set_definition('MVM','ERTAG',8);
      lics_inbound_utility.set_definition('MVM','VBWRT',15);
      lics_inbound_utility.set_definition('MVM','KOVBW',15);
      lics_inbound_utility.set_definition('MVM','KZEXI',1);
      lics_inbound_utility.set_definition('MVM','ANTEI',6);
      /*-*/
      lics_inbound_utility.set_definition('MUM','IDOC_MUM',3);
      lics_inbound_utility.set_definition('MUM','MSGFN',3);
      lics_inbound_utility.set_definition('MUM','ERTAG',8);
      lics_inbound_utility.set_definition('MUM','VBWRT',15);
      lics_inbound_utility.set_definition('MUM','KOVBW',15);
      lics_inbound_utility.set_definition('MUM','KZEXI',1);
      lics_inbound_utility.set_definition('MUM','ANTEI',6);
      /*-*/
      lics_inbound_utility.set_definition('MPV','IDOC_MPV',3);
      lics_inbound_utility.set_definition('MPV','MSGFN',3);
      lics_inbound_utility.set_definition('MPV','VERID',4);
      lics_inbound_utility.set_definition('MPV','BDATU',8);
      lics_inbound_utility.set_definition('MPV','ADATU',8);
      lics_inbound_utility.set_definition('MPV','STLAL',2);
      lics_inbound_utility.set_definition('MPV','STLAN',1);
      lics_inbound_utility.set_definition('MPV','PLNTY',1);
      lics_inbound_utility.set_definition('MPV','PLNNR',8);
      lics_inbound_utility.set_definition('MPV','ALNAL',2);
      lics_inbound_utility.set_definition('MPV','BESKZ',1);
      lics_inbound_utility.set_definition('MPV','SOBSL',2);
      lics_inbound_utility.set_definition('MPV','LOSGR',15);
      lics_inbound_utility.set_definition('MPV','MDV01',8);
      lics_inbound_utility.set_definition('MPV','MDV02',8);
      lics_inbound_utility.set_definition('MPV','TEXT1',40);
      lics_inbound_utility.set_definition('MPV','EWAHR',5);
      lics_inbound_utility.set_definition('MPV','VERTO',4);
      lics_inbound_utility.set_definition('MPV','SERKZ',1);
      lics_inbound_utility.set_definition('MPV','BSTMI',15);
      lics_inbound_utility.set_definition('MPV','BSTMA',15);
      lics_inbound_utility.set_definition('MPV','RGEKZ',1);
      lics_inbound_utility.set_definition('MPV','ALORT',4);
      lics_inbound_utility.set_definition('MPV','PLTYG',1);
      lics_inbound_utility.set_definition('MPV','PLNNG',8);
      lics_inbound_utility.set_definition('MPV','ALNAG',2);
      lics_inbound_utility.set_definition('MPV','PLTYM',1);
      lics_inbound_utility.set_definition('MPV','PLNNM',8);
      lics_inbound_utility.set_definition('MPV','ALNAM',2);
      lics_inbound_utility.set_definition('MPV','CSPLT',4);
      lics_inbound_utility.set_definition('MPV','MATKO',18);
      lics_inbound_utility.set_definition('MPV','ELPRO',4);
      lics_inbound_utility.set_definition('MPV','PRVBE',10);
      lics_inbound_utility.set_definition('MPV','MATKO_EXTERNAL',40);
      lics_inbound_utility.set_definition('MPV','MATKO_VERSION',10);
      lics_inbound_utility.set_definition('MPV','MATKO_GUID',32);
      /*-*/
      lics_inbound_utility.set_definition('UOM','IDOC_UOM',3);
      lics_inbound_utility.set_definition('UOM','MSGFN',3);
      lics_inbound_utility.set_definition('UOM','MEINH',3);
      lics_inbound_utility.set_definition('UOM','UMREZ',5);
      lics_inbound_utility.set_definition('UOM','UMREN',5);
      lics_inbound_utility.set_definition('UOM','EAN11',18);
      lics_inbound_utility.set_definition('UOM','NUMTP',2);
      lics_inbound_utility.set_definition('UOM','LAENG',14);
      lics_inbound_utility.set_definition('UOM','BREIT',14);
      lics_inbound_utility.set_definition('UOM','HOEHE',14);
      lics_inbound_utility.set_definition('UOM','MEABM',3);
      lics_inbound_utility.set_definition('UOM','VOLUM',14);
      lics_inbound_utility.set_definition('UOM','VOLEH',3);
      lics_inbound_utility.set_definition('UOM','BRGEW',14);
      lics_inbound_utility.set_definition('UOM','GEWEI',3);
      lics_inbound_utility.set_definition('UOM','MESUB',3);
      lics_inbound_utility.set_definition('UOM','GTIN_VARIANT',2);
      lics_inbound_utility.set_definition('UOM','ZZMULTITDU',1);
      lics_inbound_utility.set_definition('UOM','ZZPCITEM',18);
      lics_inbound_utility.set_definition('UOM','ZZPCLEVEL',2);
      lics_inbound_utility.set_definition('UOM','ZZPREFORDER',1);
      lics_inbound_utility.set_definition('UOM','ZZPREFSALES',1);
      lics_inbound_utility.set_definition('UOM','ZZPREFISSUE',1);
      lics_inbound_utility.set_definition('UOM','ZZPREFWM',1);
      lics_inbound_utility.set_definition('UOM','ZZREFMATNR',18);
      /*-*/
      lics_inbound_utility.set_definition('UOE','IDOC_UOE',3);
      lics_inbound_utility.set_definition('UOE','MSGFN',3);
      lics_inbound_utility.set_definition('UOE','MEINH',3);
      lics_inbound_utility.set_definition('UOE','LFNUM',5);
      lics_inbound_utility.set_definition('UOE','EAN11',18);
      lics_inbound_utility.set_definition('UOE','EANTP',2);
      lics_inbound_utility.set_definition('UOE','HPEAN',1);
      /*-*/
      lics_inbound_utility.set_definition('MBE','IDOC_MBE',3);
      lics_inbound_utility.set_definition('MBE','MSGFN',3);
      lics_inbound_utility.set_definition('MBE','BWKEY',4);
      lics_inbound_utility.set_definition('MBE','BWTAR',10);
      lics_inbound_utility.set_definition('MBE','LVORM',1);
      lics_inbound_utility.set_definition('MBE','VPRSV',1);
      lics_inbound_utility.set_definition('MBE','VERPR',12);
      lics_inbound_utility.set_definition('MBE','STPRS',12);
      lics_inbound_utility.set_definition('MBE','PEINH',5);
      lics_inbound_utility.set_definition('MBE','BKLAS',4);
      lics_inbound_utility.set_definition('MBE','VMVPR',1);
      lics_inbound_utility.set_definition('MBE','VMVER',12);
      lics_inbound_utility.set_definition('MBE','VMSTP',12);
      lics_inbound_utility.set_definition('MBE','VMPEI',5);
      lics_inbound_utility.set_definition('MBE','VMBKL',4);
      lics_inbound_utility.set_definition('MBE','VJVPR',1);
      lics_inbound_utility.set_definition('MBE','VJVER',12);
      lics_inbound_utility.set_definition('MBE','VJSTP',12);
      lics_inbound_utility.set_definition('MBE','LFGJA',4);
      lics_inbound_utility.set_definition('MBE','LFMON',2);
      lics_inbound_utility.set_definition('MBE','BWTTY',1);
      lics_inbound_utility.set_definition('MBE','ZKPRS',12);
      lics_inbound_utility.set_definition('MBE','ZKDAT',8);
      lics_inbound_utility.set_definition('MBE','BWPRS',12);
      lics_inbound_utility.set_definition('MBE','BWPRH',12);
      lics_inbound_utility.set_definition('MBE','VJBWS',12);
      lics_inbound_utility.set_definition('MBE','VJBWH',12);
      lics_inbound_utility.set_definition('MBE','VVJLB',15);
      lics_inbound_utility.set_definition('MBE','VVMLB',15);
      lics_inbound_utility.set_definition('MBE','VVSAL',15);
      lics_inbound_utility.set_definition('MBE','ZPLPR',12);
      lics_inbound_utility.set_definition('MBE','ZPLP1',12);
      lics_inbound_utility.set_definition('MBE','ZPLP2',12);
      lics_inbound_utility.set_definition('MBE','ZPLP3',12);
      lics_inbound_utility.set_definition('MBE','ZPLD1',8);
      lics_inbound_utility.set_definition('MBE','ZPLD2',8);
      lics_inbound_utility.set_definition('MBE','ZPLD3',8);
      lics_inbound_utility.set_definition('MBE','KALKZ',1);
      lics_inbound_utility.set_definition('MBE','KALKL',1);
      lics_inbound_utility.set_definition('MBE','XLIFO',1);
      lics_inbound_utility.set_definition('MBE','MYPOL',4);
      lics_inbound_utility.set_definition('MBE','BWPH1',12);
      lics_inbound_utility.set_definition('MBE','BWPS1',12);
      lics_inbound_utility.set_definition('MBE','ABWKZ',2);
      lics_inbound_utility.set_definition('MBE','PSTAT',15);
      lics_inbound_utility.set_definition('MBE','KALN1',12);
      lics_inbound_utility.set_definition('MBE','KALNR',12);
      lics_inbound_utility.set_definition('MBE','BWVA1',3);
      lics_inbound_utility.set_definition('MBE','BWVA2',3);
      lics_inbound_utility.set_definition('MBE','BWVA3',3);
      lics_inbound_utility.set_definition('MBE','VERS1',2);
      lics_inbound_utility.set_definition('MBE','VERS2',2);
      lics_inbound_utility.set_definition('MBE','VERS3',2);
      lics_inbound_utility.set_definition('MBE','HRKFT',4);
      lics_inbound_utility.set_definition('MBE','KOSGR',10);
      lics_inbound_utility.set_definition('MBE','PPRDZ',3);
      lics_inbound_utility.set_definition('MBE','PPRDL',3);
      lics_inbound_utility.set_definition('MBE','PPRDV',3);
      lics_inbound_utility.set_definition('MBE','PDATZ',4);
      lics_inbound_utility.set_definition('MBE','PDATL',4);
      lics_inbound_utility.set_definition('MBE','PDATV',4);
      lics_inbound_utility.set_definition('MBE','EKALR',1);
      lics_inbound_utility.set_definition('MBE','VPLPR',12);
      lics_inbound_utility.set_definition('MBE','MLMAA',1);
      lics_inbound_utility.set_definition('MBE','MLAST',1);
      lics_inbound_utility.set_definition('MBE','VJBKL',4);
      lics_inbound_utility.set_definition('MBE','VJPEI',7);
      lics_inbound_utility.set_definition('MBE','HKMAT',1);
      lics_inbound_utility.set_definition('MBE','EKLAS',4);
      lics_inbound_utility.set_definition('MBE','QKLAS',4);
      lics_inbound_utility.set_definition('MBE','MTUSE',1);
      lics_inbound_utility.set_definition('MBE','MTORG',1);
      lics_inbound_utility.set_definition('MBE','OWNPR',1);
      lics_inbound_utility.set_definition('MBE','BWPEI',6);
      /*-*/
      lics_inbound_utility.set_definition('MGN','IDOC_MGN',3);
      lics_inbound_utility.set_definition('MGN','MSGFN',3);
      lics_inbound_utility.set_definition('MGN','LGNUM',3);
      lics_inbound_utility.set_definition('MGN','LVORM',1);
      lics_inbound_utility.set_definition('MGN','LGBKZ',3);
      lics_inbound_utility.set_definition('MGN','LTKZE',3);
      lics_inbound_utility.set_definition('MGN','LTKZA',3);
      lics_inbound_utility.set_definition('MGN','LHMG1',14);
      lics_inbound_utility.set_definition('MGN','LHMG2',14);
      lics_inbound_utility.set_definition('MGN','LHMG3',14);
      lics_inbound_utility.set_definition('MGN','LHME1',3);
      lics_inbound_utility.set_definition('MGN','LHME2',3);
      lics_inbound_utility.set_definition('MGN','LHME3',3);
      lics_inbound_utility.set_definition('MGN','LETY1',3);
      lics_inbound_utility.set_definition('MGN','LETY2',3);
      lics_inbound_utility.set_definition('MGN','LETY3',3);
      lics_inbound_utility.set_definition('MGN','LVSME',3);
      lics_inbound_utility.set_definition('MGN','KZZUL',1);
      lics_inbound_utility.set_definition('MGN','BLOCK',2);
      lics_inbound_utility.set_definition('MGN','KZMBF',1);
      lics_inbound_utility.set_definition('MGN','BSSKZ',1);
      lics_inbound_utility.set_definition('MGN','MKAPV',13);
      lics_inbound_utility.set_definition('MGN','BEZME',3);
      lics_inbound_utility.set_definition('MGN','PLKPT',3);
      lics_inbound_utility.set_definition('MGN','VOMEM',1);
      lics_inbound_utility.set_definition('MGN','L2SKR',1);
      /*-*/
      lics_inbound_utility.set_definition('MLG','IDOC_MLG',3);
      lics_inbound_utility.set_definition('MLG','MSGFN',3);
      lics_inbound_utility.set_definition('MLG','LGTYP',3);
      lics_inbound_utility.set_definition('MLG','LVORM',1);
      lics_inbound_utility.set_definition('MLG','LGPLA',10);
      lics_inbound_utility.set_definition('MLG','LPMAX',15);
      lics_inbound_utility.set_definition('MLG','LPMIN',15);
      lics_inbound_utility.set_definition('MLG','MAMNG',15);
      lics_inbound_utility.set_definition('MLG','NSMNG',15);
      lics_inbound_utility.set_definition('MLG','KOBER',3);
      lics_inbound_utility.set_definition('MLG','RDMNG',15);
      /*-*/
      lics_inbound_utility.set_definition('SAD','IDOC_SAD',3);
      lics_inbound_utility.set_definition('SAD','MSGFN',3);
      lics_inbound_utility.set_definition('SAD','VKORG',4);
      lics_inbound_utility.set_definition('SAD','VTWEG',2);
      lics_inbound_utility.set_definition('SAD','LVORM',1);
      lics_inbound_utility.set_definition('SAD','VERSG',1);
      lics_inbound_utility.set_definition('SAD','BONUS',2);
      lics_inbound_utility.set_definition('SAD','PROVG',2);
      lics_inbound_utility.set_definition('SAD','SKTOF',1);
      lics_inbound_utility.set_definition('SAD','VMSTA',2);
      lics_inbound_utility.set_definition('SAD','VMSTD',8);
      lics_inbound_utility.set_definition('SAD','AUMNG',14);
      lics_inbound_utility.set_definition('SAD','LFMNG',14);
      lics_inbound_utility.set_definition('SAD','EFMNG',14);
      lics_inbound_utility.set_definition('SAD','SCMNG',14);
      lics_inbound_utility.set_definition('SAD','SCHME',3);
      lics_inbound_utility.set_definition('SAD','VRKME',3);
      lics_inbound_utility.set_definition('SAD','MTPOS',4);
      lics_inbound_utility.set_definition('SAD','DWERK',4);
      lics_inbound_utility.set_definition('SAD','PRODH',18);
      lics_inbound_utility.set_definition('SAD','PMATN',18);
      lics_inbound_utility.set_definition('SAD','KONDM',2);
      lics_inbound_utility.set_definition('SAD','KTGRM',2);
      lics_inbound_utility.set_definition('SAD','MVGR1',3);
      lics_inbound_utility.set_definition('SAD','MVGR2',3);
      lics_inbound_utility.set_definition('SAD','MVGR3',3);
      lics_inbound_utility.set_definition('SAD','MVGR4',3);
      lics_inbound_utility.set_definition('SAD','MVGR5',3);
      lics_inbound_utility.set_definition('SAD','SSTUF',2);
      lics_inbound_utility.set_definition('SAD','PFLKS',1);
      lics_inbound_utility.set_definition('SAD','LSTFL',2);
      lics_inbound_utility.set_definition('SAD','LSTVZ',2);
      lics_inbound_utility.set_definition('SAD','LSTAK',1);
      lics_inbound_utility.set_definition('SAD','PRAT1',1);
      lics_inbound_utility.set_definition('SAD','PRAT2',1);
      lics_inbound_utility.set_definition('SAD','PRAT3',1);
      lics_inbound_utility.set_definition('SAD','PRAT4',1);
      lics_inbound_utility.set_definition('SAD','PRAT5',1);
      lics_inbound_utility.set_definition('SAD','PRAT6',1);
      lics_inbound_utility.set_definition('SAD','PRAT7',1);
      lics_inbound_utility.set_definition('SAD','PRAT8',1);
      lics_inbound_utility.set_definition('SAD','PRAT9',1);
      lics_inbound_utility.set_definition('SAD','PRATA',1);
      lics_inbound_utility.set_definition('SAD','VAVME',1);
      lics_inbound_utility.set_definition('SAD','RDPRF',4);
      lics_inbound_utility.set_definition('SAD','MEGRU',4);
      lics_inbound_utility.set_definition('SAD','PMATN_EXTERNAL',40);
      lics_inbound_utility.set_definition('SAD','PMATN_VERSION',10);
      lics_inbound_utility.set_definition('SAD','PMATN_GUID',32);
      /*-*/
      lics_inbound_utility.set_definition('ZSD','IDOC_ZSD',3);
      lics_inbound_utility.set_definition('ZSD','ZZLOGIST_POINT',9);
      /*-*/
      lics_inbound_utility.set_definition('TAX','IDOC_TAX',3);
      lics_inbound_utility.set_definition('TAX','MSGFN',3);
      lics_inbound_utility.set_definition('TAX','ALAND',3);
      lics_inbound_utility.set_definition('TAX','TATY1',4);
      lics_inbound_utility.set_definition('TAX','TAXM1',1);
      lics_inbound_utility.set_definition('TAX','TATY2',4);
      lics_inbound_utility.set_definition('TAX','TAXM2',1);
      lics_inbound_utility.set_definition('TAX','TATY3',4);
      lics_inbound_utility.set_definition('TAX','TAXM3',1);
      lics_inbound_utility.set_definition('TAX','TATY4',4);
      lics_inbound_utility.set_definition('TAX','TAXM4',1);
      lics_inbound_utility.set_definition('TAX','TATY5',4);
      lics_inbound_utility.set_definition('TAX','TAXM5',1);
      lics_inbound_utility.set_definition('TAX','TATY6',4);
      lics_inbound_utility.set_definition('TAX','TAXM6',1);
      lics_inbound_utility.set_definition('TAX','TATY7',4);
      lics_inbound_utility.set_definition('TAX','TAXM7',1);
      lics_inbound_utility.set_definition('TAX','TATY8',4);
      lics_inbound_utility.set_definition('TAX','TAXM8',1);
      lics_inbound_utility.set_definition('TAX','TATY9',4);
      lics_inbound_utility.set_definition('TAX','TAXM9',1);
      lics_inbound_utility.set_definition('TAX','TAXIM',1);
      /*-*/
      lics_inbound_utility.set_definition('TXH','IDOC_TXH',3);
      lics_inbound_utility.set_definition('TXH','MSGFN',3);
      lics_inbound_utility.set_definition('TXH','TDOBJECT',10);
      lics_inbound_utility.set_definition('TXH','TDNAME',70);
      lics_inbound_utility.set_definition('TXH','TDID',4);
      lics_inbound_utility.set_definition('TXH','TDSPRAS',1);
      lics_inbound_utility.set_definition('TXH','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('TXH','SPRAS_ISO',2);
      /*-*/
      lics_inbound_utility.set_definition('TXL','IDOC_TXL',3);
      lics_inbound_utility.set_definition('TXL','MSGFN',3);
      lics_inbound_utility.set_definition('TXL','TDFORMAT',2);
      lics_inbound_utility.set_definition('TXL','TDLINE',132);

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
         when 'PCH' then process_record_pch(par_record);
         when 'PCR' then process_record_pcr(par_record);
         when 'PIH' then process_record_pih(par_record);
         when 'PIE' then process_record_pie(par_record);
         when 'PIR' then process_record_pir(par_record);
         when 'PIT' then process_record_pit(par_record);
         when 'PIM' then process_record_pim(par_record);
         when 'PID' then process_record_pid(par_record);
         when 'MOE' then process_record_moe(par_record);
         when 'GME' then process_record_gme(par_record);
         when 'LCD' then process_record_lcd(par_record);
         when 'MKT' then process_record_mkt(par_record);
         when 'MRC' then process_record_mrc(par_record);
         when 'ZMC' then process_record_zmc(par_record);
         when 'MRD' then process_record_mrd(par_record);
         when 'MPM' then process_record_mpm(par_record);
         when 'MVM' then process_record_mvm(par_record);
         when 'MUM' then process_record_mum(par_record);
         when 'MPV' then process_record_mpv(par_record);
         when 'UOM' then process_record_uom(par_record);
         when 'UOE' then process_record_uoe(par_record);
         when 'MBE' then process_record_mbe(par_record);
         when 'MGN' then process_record_mgn(par_record);
         when 'MLG' then process_record_mlg(par_record);
         when 'SAD' then process_record_sad(par_record);
         when 'ZSD' then process_record_zsd(par_record);
         when 'TAX' then process_record_tax(par_record);
         when 'TXH' then process_record_txh(par_record);
         when 'TXL' then process_record_txl(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD04';
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
            lads_atllad04_monitor.execute(rcd_lads_mat_hdr.matnr);
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
      cursor csr_lads_mat_hdr_01 is
         select
            t01.matnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_mat_hdr t01
         where t01.matnr = rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_hdr_01 csr_lads_mat_hdr_01%rowtype;

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
      rcd_lads_mat_hdr.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_mat_hdr.ersda := lics_inbound_utility.get_variable('ERSDA');
      rcd_lads_mat_hdr.ernam := lics_inbound_utility.get_variable('ERNAM');
      rcd_lads_mat_hdr.laeda := lics_inbound_utility.get_variable('LAEDA');
      rcd_lads_mat_hdr.aenam := lics_inbound_utility.get_variable('AENAM');
      rcd_lads_mat_hdr.pstat := lics_inbound_utility.get_variable('PSTAT');
      rcd_lads_mat_hdr.lvorm := lics_inbound_utility.get_variable('LVORM');
      rcd_lads_mat_hdr.mtart := lics_inbound_utility.get_variable('MTART');
      rcd_lads_mat_hdr.mbrsh := lics_inbound_utility.get_variable('MBRSH');
      rcd_lads_mat_hdr.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_mat_hdr.bismt := lics_inbound_utility.get_variable('BISMT');
      rcd_lads_mat_hdr.meins := lics_inbound_utility.get_variable('MEINS');
      rcd_lads_mat_hdr.bstme := lics_inbound_utility.get_variable('BSTME');
      rcd_lads_mat_hdr.zeinr := lics_inbound_utility.get_variable('ZEINR');
      rcd_lads_mat_hdr.zeiar := lics_inbound_utility.get_variable('ZEIAR');
      rcd_lads_mat_hdr.zeivr := lics_inbound_utility.get_variable('ZEIVR');
      rcd_lads_mat_hdr.zeifo := lics_inbound_utility.get_variable('ZEIFO');
      rcd_lads_mat_hdr.aeszn := lics_inbound_utility.get_variable('AESZN');
      rcd_lads_mat_hdr.blatt := lics_inbound_utility.get_variable('BLATT');
      rcd_lads_mat_hdr.blanz := lics_inbound_utility.get_number('BLANZ',null);
      rcd_lads_mat_hdr.ferth := lics_inbound_utility.get_variable('FERTH');
      rcd_lads_mat_hdr.formt := lics_inbound_utility.get_variable('FORMT');
      rcd_lads_mat_hdr.groes := lics_inbound_utility.get_variable('GROES');
      rcd_lads_mat_hdr.wrkst := lics_inbound_utility.get_variable('WRKST');
      rcd_lads_mat_hdr.normt := lics_inbound_utility.get_variable('NORMT');
      rcd_lads_mat_hdr.labor := lics_inbound_utility.get_variable('LABOR');
      rcd_lads_mat_hdr.ekwsl := lics_inbound_utility.get_variable('EKWSL');
      rcd_lads_mat_hdr.brgew := lics_inbound_utility.get_number('BRGEW',null);
      rcd_lads_mat_hdr.ntgew := lics_inbound_utility.get_number('NTGEW',null);
      rcd_lads_mat_hdr.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_mat_hdr.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_lads_mat_hdr.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_lads_mat_hdr.behvo := lics_inbound_utility.get_variable('BEHVO');
      rcd_lads_mat_hdr.raube := lics_inbound_utility.get_variable('RAUBE');
      rcd_lads_mat_hdr.tempb := lics_inbound_utility.get_variable('TEMPB');
      rcd_lads_mat_hdr.tragr := lics_inbound_utility.get_variable('TRAGR');
      rcd_lads_mat_hdr.stoff := lics_inbound_utility.get_variable('STOFF');
      rcd_lads_mat_hdr.spart := lics_inbound_utility.get_variable('SPART');
      rcd_lads_mat_hdr.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_mat_hdr.wesch := lics_inbound_utility.get_number('WESCH',null);
      rcd_lads_mat_hdr.bwvor := lics_inbound_utility.get_variable('BWVOR');
      rcd_lads_mat_hdr.bwscl := lics_inbound_utility.get_variable('BWSCL');
      rcd_lads_mat_hdr.saiso := lics_inbound_utility.get_variable('SAISO');
      rcd_lads_mat_hdr.etiar := lics_inbound_utility.get_variable('ETIAR');
      rcd_lads_mat_hdr.etifo := lics_inbound_utility.get_variable('ETIFO');
      rcd_lads_mat_hdr.ean11 := lics_inbound_utility.get_variable('EAN11');
      rcd_lads_mat_hdr.numtp := lics_inbound_utility.get_variable('NUMTP');
      rcd_lads_mat_hdr.laeng := lics_inbound_utility.get_number('LAENG',null);
      rcd_lads_mat_hdr.breit := lics_inbound_utility.get_number('BREIT',null);
      rcd_lads_mat_hdr.hoehe := lics_inbound_utility.get_number('HOEHE',null);
      rcd_lads_mat_hdr.meabm := lics_inbound_utility.get_variable('MEABM');
      rcd_lads_mat_hdr.prdha := lics_inbound_utility.get_variable('PRDHA');
      rcd_lads_mat_hdr.cadkz := lics_inbound_utility.get_variable('CADKZ');
      rcd_lads_mat_hdr.ergew := lics_inbound_utility.get_number('ERGEW',null);
      rcd_lads_mat_hdr.ergei := lics_inbound_utility.get_variable('ERGEI');
      rcd_lads_mat_hdr.ervol := lics_inbound_utility.get_number('ERVOL',null);
      rcd_lads_mat_hdr.ervoe := lics_inbound_utility.get_variable('ERVOE');
      rcd_lads_mat_hdr.gewto := lics_inbound_utility.get_number('GEWTO',null);
      rcd_lads_mat_hdr.volto := lics_inbound_utility.get_number('VOLTO',null);
      rcd_lads_mat_hdr.vabme := lics_inbound_utility.get_variable('VABME');
      rcd_lads_mat_hdr.kzkfg := lics_inbound_utility.get_variable('KZKFG');
      rcd_lads_mat_hdr.xchpf := lics_inbound_utility.get_variable('XCHPF');
      rcd_lads_mat_hdr.vhart := lics_inbound_utility.get_variable('VHART');
      rcd_lads_mat_hdr.fuelg := lics_inbound_utility.get_number('FUELG',null);
      rcd_lads_mat_hdr.stfak := lics_inbound_utility.get_number('STFAK',null);
      rcd_lads_mat_hdr.magrv := lics_inbound_utility.get_variable('MAGRV');
      rcd_lads_mat_hdr.begru := lics_inbound_utility.get_variable('BEGRU');
      rcd_lads_mat_hdr.qmpur := lics_inbound_utility.get_variable('QMPUR');
      rcd_lads_mat_hdr.rbnrm := lics_inbound_utility.get_variable('RBNRM');
      rcd_lads_mat_hdr.mhdrz := lics_inbound_utility.get_number('MHDRZ',null);
      rcd_lads_mat_hdr.mhdhb := lics_inbound_utility.get_number('MHDHB',null);
      rcd_lads_mat_hdr.mhdlp := lics_inbound_utility.get_number('MHDLP',null);
      rcd_lads_mat_hdr.vpsta := lics_inbound_utility.get_variable('VPSTA');
      rcd_lads_mat_hdr.extwg := lics_inbound_utility.get_variable('EXTWG');
      rcd_lads_mat_hdr.mstae := lics_inbound_utility.get_variable('MSTAE');
      rcd_lads_mat_hdr.mstav := lics_inbound_utility.get_variable('MSTAV');
      rcd_lads_mat_hdr.mstde := lics_inbound_utility.get_variable('MSTDE');
      rcd_lads_mat_hdr.mstdv := lics_inbound_utility.get_variable('MSTDV');
      rcd_lads_mat_hdr.kzumw := lics_inbound_utility.get_variable('KZUMW');
      rcd_lads_mat_hdr.kosch := lics_inbound_utility.get_variable('KOSCH');
      rcd_lads_mat_hdr.nrfhg := lics_inbound_utility.get_variable('NRFHG');
      rcd_lads_mat_hdr.mfrpn := lics_inbound_utility.get_variable('MFRPN');
      rcd_lads_mat_hdr.mfrnr := lics_inbound_utility.get_variable('MFRNR');
      rcd_lads_mat_hdr.bmatn := lics_inbound_utility.get_variable('BMATN');
      rcd_lads_mat_hdr.mprof := lics_inbound_utility.get_variable('MPROF');
      rcd_lads_mat_hdr.profl := lics_inbound_utility.get_variable('PROFL');
      rcd_lads_mat_hdr.ihivi := lics_inbound_utility.get_variable('IHIVI');
      rcd_lads_mat_hdr.iloos := lics_inbound_utility.get_variable('ILOOS');
      rcd_lads_mat_hdr.kzgvh := lics_inbound_utility.get_variable('KZGVH');
      rcd_lads_mat_hdr.xgchp := lics_inbound_utility.get_variable('XGCHP');
      rcd_lads_mat_hdr.compl := lics_inbound_utility.get_number('COMPL',null);
      rcd_lads_mat_hdr.kzeff := lics_inbound_utility.get_variable('KZEFF');
      rcd_lads_mat_hdr.rdmhd := lics_inbound_utility.get_variable('RDMHD');
      rcd_lads_mat_hdr.iprkz := lics_inbound_utility.get_variable('IPRKZ');
      rcd_lads_mat_hdr.przus := lics_inbound_utility.get_variable('PRZUS');
      rcd_lads_mat_hdr.mtpos_mara := lics_inbound_utility.get_variable('MTPOS_MARA');
      rcd_lads_mat_hdr.gewto_new := lics_inbound_utility.get_number('GEWTO_NEW',null);
      rcd_lads_mat_hdr.volto_new := lics_inbound_utility.get_number('VOLTO_NEW',null);
      rcd_lads_mat_hdr.wrkst_new := lics_inbound_utility.get_variable('WRKST_NEW');
      rcd_lads_mat_hdr.aennr := lics_inbound_utility.get_variable('AENNR');
      rcd_lads_mat_hdr.matfi := lics_inbound_utility.get_variable('MATFI');
      rcd_lads_mat_hdr.cmrel := lics_inbound_utility.get_variable('CMREL');
      rcd_lads_mat_hdr.satnr := lics_inbound_utility.get_variable('SATNR');
      rcd_lads_mat_hdr.sled_bbd := lics_inbound_utility.get_variable('SLED_BBD');
      rcd_lads_mat_hdr.gtin_variant := lics_inbound_utility.get_variable('GTIN_VARIANT');
      rcd_lads_mat_hdr.gennr := lics_inbound_utility.get_variable('GENNR');
      rcd_lads_mat_hdr.serlv := lics_inbound_utility.get_variable('SERLV');
      rcd_lads_mat_hdr.rmatp := lics_inbound_utility.get_variable('RMATP');
      rcd_lads_mat_hdr.zzdecvolum := lics_inbound_utility.get_number('ZZDECVOLUM',null);
      rcd_lads_mat_hdr.zzdecvoleh := lics_inbound_utility.get_variable('ZZDECVOLEH');
      rcd_lads_mat_hdr.zzdeccount := lics_inbound_utility.get_number('ZZDECCOUNT',null);
      rcd_lads_mat_hdr.zzdeccounit := lics_inbound_utility.get_variable('ZZDECCOUNIT');
      rcd_lads_mat_hdr.zzpproweight := lics_inbound_utility.get_number('ZZPPROWEIGHT',null);
      rcd_lads_mat_hdr.zzpprowunit := lics_inbound_utility.get_variable('ZZPPROWUNIT');
      rcd_lads_mat_hdr.zzpprovolum := lics_inbound_utility.get_number('ZZPPROVOLUM',null);
      rcd_lads_mat_hdr.zzpprovunit := lics_inbound_utility.get_variable('ZZPPROVUNIT');
      rcd_lads_mat_hdr.zzpprocount := lics_inbound_utility.get_number('ZZPPROCOUNT',null);
      rcd_lads_mat_hdr.zzpprocunit := lics_inbound_utility.get_variable('ZZPPROCUNIT');
      rcd_lads_mat_hdr.zzalpha01 := lics_inbound_utility.get_variable('ZZALPHA01');
      rcd_lads_mat_hdr.zzalpha02 := lics_inbound_utility.get_variable('ZZALPHA02');
      rcd_lads_mat_hdr.zzalpha03 := lics_inbound_utility.get_variable('ZZALPHA03');
      rcd_lads_mat_hdr.zzalpha04 := lics_inbound_utility.get_variable('ZZALPHA04');
      rcd_lads_mat_hdr.zzalpha05 := lics_inbound_utility.get_variable('ZZALPHA05');
      rcd_lads_mat_hdr.zzalpha06 := lics_inbound_utility.get_variable('ZZALPHA06');
      rcd_lads_mat_hdr.zzalpha07 := lics_inbound_utility.get_variable('ZZALPHA07');
      rcd_lads_mat_hdr.zzalpha08 := lics_inbound_utility.get_variable('ZZALPHA08');
      rcd_lads_mat_hdr.zzalpha09 := lics_inbound_utility.get_variable('ZZALPHA09');
      rcd_lads_mat_hdr.zzalpha10 := lics_inbound_utility.get_variable('ZZALPHA10');
      rcd_lads_mat_hdr.zznum01 := lics_inbound_utility.get_number('ZZNUM01',null);
      rcd_lads_mat_hdr.zznum02 := lics_inbound_utility.get_number('ZZNUM02',null);
      rcd_lads_mat_hdr.zznum03 := lics_inbound_utility.get_number('ZZNUM03',null);
      rcd_lads_mat_hdr.zznum04 := lics_inbound_utility.get_number('ZZNUM04',null);
      rcd_lads_mat_hdr.zznum05 := lics_inbound_utility.get_number('ZZNUM05',null);
      rcd_lads_mat_hdr.zznum06 := lics_inbound_utility.get_number('ZZNUM06',null);
      rcd_lads_mat_hdr.zznum07 := lics_inbound_utility.get_number('ZZNUM07',null);
      rcd_lads_mat_hdr.zznum08 := lics_inbound_utility.get_number('ZZNUM08',null);
      rcd_lads_mat_hdr.zznum09 := lics_inbound_utility.get_number('ZZNUM09',null);
      rcd_lads_mat_hdr.zznum10 := lics_inbound_utility.get_number('ZZNUM10',null);
      rcd_lads_mat_hdr.zzcheck01 := lics_inbound_utility.get_variable('ZZCHECK01');
      rcd_lads_mat_hdr.zzcheck02 := lics_inbound_utility.get_variable('ZZCHECK02');
      rcd_lads_mat_hdr.zzcheck03 := lics_inbound_utility.get_variable('ZZCHECK03');
      rcd_lads_mat_hdr.zzcheck04 := lics_inbound_utility.get_variable('ZZCHECK04');
      rcd_lads_mat_hdr.zzcheck05 := lics_inbound_utility.get_variable('ZZCHECK05');
      rcd_lads_mat_hdr.zzcheck06 := lics_inbound_utility.get_variable('ZZCHECK06');
      rcd_lads_mat_hdr.zzcheck07 := lics_inbound_utility.get_variable('ZZCHECK07');
      rcd_lads_mat_hdr.zzcheck08 := lics_inbound_utility.get_variable('ZZCHECK08');
      rcd_lads_mat_hdr.zzcheck09 := lics_inbound_utility.get_variable('ZZCHECK09');
      rcd_lads_mat_hdr.zzcheck10 := lics_inbound_utility.get_variable('ZZCHECK10');
      rcd_lads_mat_hdr.zzplan_item := lics_inbound_utility.get_variable('ZZPLAN_ITEM');
      rcd_lads_mat_hdr.zzisint := lics_inbound_utility.get_variable('ZZISINT');
      rcd_lads_mat_hdr.zzismcu := lics_inbound_utility.get_variable('ZZISMCU');
      rcd_lads_mat_hdr.zzispro := lics_inbound_utility.get_variable('ZZISPRO');
      rcd_lads_mat_hdr.zzisrsu := lics_inbound_utility.get_variable('ZZISRSU');
      rcd_lads_mat_hdr.zzissc := lics_inbound_utility.get_variable('ZZISSC');
      rcd_lads_mat_hdr.zzissfp := lics_inbound_utility.get_variable('ZZISSFP');
      rcd_lads_mat_hdr.zzistdu := lics_inbound_utility.get_variable('ZZISTDU');
      rcd_lads_mat_hdr.zzistra := lics_inbound_utility.get_variable('ZZISTRA');
      rcd_lads_mat_hdr.zzstatuscode := lics_inbound_utility.get_variable('ZZSTATUSCODE');
      rcd_lads_mat_hdr.zzitemowner := lics_inbound_utility.get_variable('ZZITEMOWNER');
      rcd_lads_mat_hdr.zzchangedby := lics_inbound_utility.get_variable('ZZCHANGEDBY');
      rcd_lads_mat_hdr.zzmattim := lics_inbound_utility.get_number('ZZMATTIM',null);
      rcd_lads_mat_hdr.zzrepmatnr := lics_inbound_utility.get_variable('ZZREPMATNR');
      rcd_lads_mat_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_mat_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_mat_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_mat_hdr.lads_date := sysdate;
      rcd_lads_mat_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_pch.pchseq := 0;
      rcd_lads_mat_moe.moeseq := 0;
      rcd_lads_mat_gme.gmeseq := 0;
      rcd_lads_mat_lcd.lcdseq := 0;
      rcd_lads_mat_mkt.mktseq := 0;
      rcd_lads_mat_mrc.mrcseq := 0;
      rcd_lads_mat_uom.uomseq := 0;
      rcd_lads_mat_mbe.mbeseq := 0;
      rcd_lads_mat_mgn.mgnseq := 0;
      rcd_lads_mat_sad.sadseq := 0;
      rcd_lads_mat_tax.taxseq := 0;
      rcd_lads_mat_txh.txhseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_hdr.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.MATNR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_mat_hdr.matnr is null) then
         var_exists := true;
         open csr_lads_mat_hdr_01;
         fetch csr_lads_mat_hdr_01 into rcd_lads_mat_hdr_01;
         if csr_lads_mat_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_mat_hdr_01;
         if var_exists = true then
            if rcd_lads_mat_hdr.idoc_timestamp > rcd_lads_mat_hdr_01.idoc_timestamp then
               delete from lads_mat_txl where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_txh where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_tax where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_zsd where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_sad where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mlg where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mgn where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mbe where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_uoe where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_uom where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mpv where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mum where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mvm where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mpm where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mrd where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_zmc where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mrc where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_mkt where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_lcd where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_gme where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_moe where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_pid where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_pim where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_pit where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_pir where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_pie where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_pih where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_pcr where matnr = rcd_lads_mat_hdr.matnr;
               delete from lads_mat_pch where matnr = rcd_lads_mat_hdr.matnr;
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

      update lads_mat_hdr set
         ersda = rcd_lads_mat_hdr.ersda,
         ernam = rcd_lads_mat_hdr.ernam,
         laeda = rcd_lads_mat_hdr.laeda,
         aenam = rcd_lads_mat_hdr.aenam,
         pstat = rcd_lads_mat_hdr.pstat,
         lvorm = rcd_lads_mat_hdr.lvorm,
         mtart = rcd_lads_mat_hdr.mtart,
         mbrsh = rcd_lads_mat_hdr.mbrsh,
         matkl = rcd_lads_mat_hdr.matkl,
         bismt = rcd_lads_mat_hdr.bismt,
         meins = rcd_lads_mat_hdr.meins,
         bstme = rcd_lads_mat_hdr.bstme,
         zeinr = rcd_lads_mat_hdr.zeinr,
         zeiar = rcd_lads_mat_hdr.zeiar,
         zeivr = rcd_lads_mat_hdr.zeivr,
         zeifo = rcd_lads_mat_hdr.zeifo,
         aeszn = rcd_lads_mat_hdr.aeszn,
         blatt = rcd_lads_mat_hdr.blatt,
         blanz = rcd_lads_mat_hdr.blanz,
         ferth = rcd_lads_mat_hdr.ferth,
         formt = rcd_lads_mat_hdr.formt,
         groes = rcd_lads_mat_hdr.groes,
         wrkst = rcd_lads_mat_hdr.wrkst,
         normt = rcd_lads_mat_hdr.normt,
         labor = rcd_lads_mat_hdr.labor,
         ekwsl = rcd_lads_mat_hdr.ekwsl,
         brgew = rcd_lads_mat_hdr.brgew,
         ntgew = rcd_lads_mat_hdr.ntgew,
         gewei = rcd_lads_mat_hdr.gewei,
         volum = rcd_lads_mat_hdr.volum,
         voleh = rcd_lads_mat_hdr.voleh,
         behvo = rcd_lads_mat_hdr.behvo,
         raube = rcd_lads_mat_hdr.raube,
         tempb = rcd_lads_mat_hdr.tempb,
         tragr = rcd_lads_mat_hdr.tragr,
         stoff = rcd_lads_mat_hdr.stoff,
         spart = rcd_lads_mat_hdr.spart,
         kunnr = rcd_lads_mat_hdr.kunnr,
         wesch = rcd_lads_mat_hdr.wesch,
         bwvor = rcd_lads_mat_hdr.bwvor,
         bwscl = rcd_lads_mat_hdr.bwscl,
         saiso = rcd_lads_mat_hdr.saiso,
         etiar = rcd_lads_mat_hdr.etiar,
         etifo = rcd_lads_mat_hdr.etifo,
         ean11 = rcd_lads_mat_hdr.ean11,
         numtp = rcd_lads_mat_hdr.numtp,
         laeng = rcd_lads_mat_hdr.laeng,
         breit = rcd_lads_mat_hdr.breit,
         hoehe = rcd_lads_mat_hdr.hoehe,
         meabm = rcd_lads_mat_hdr.meabm,
         prdha = rcd_lads_mat_hdr.prdha,
         cadkz = rcd_lads_mat_hdr.cadkz,
         ergew = rcd_lads_mat_hdr.ergew,
         ergei = rcd_lads_mat_hdr.ergei,
         ervol = rcd_lads_mat_hdr.ervol,
         ervoe = rcd_lads_mat_hdr.ervoe,
         gewto = rcd_lads_mat_hdr.gewto,
         volto = rcd_lads_mat_hdr.volto,
         vabme = rcd_lads_mat_hdr.vabme,
         kzkfg = rcd_lads_mat_hdr.kzkfg,
         xchpf = rcd_lads_mat_hdr.xchpf,
         vhart = rcd_lads_mat_hdr.vhart,
         fuelg = rcd_lads_mat_hdr.fuelg,
         stfak = rcd_lads_mat_hdr.stfak,
         magrv = rcd_lads_mat_hdr.magrv,
         begru = rcd_lads_mat_hdr.begru,
         qmpur = rcd_lads_mat_hdr.qmpur,
         rbnrm = rcd_lads_mat_hdr.rbnrm,
         mhdrz = rcd_lads_mat_hdr.mhdrz,
         mhdhb = rcd_lads_mat_hdr.mhdhb,
         mhdlp = rcd_lads_mat_hdr.mhdlp,
         vpsta = rcd_lads_mat_hdr.vpsta,
         extwg = rcd_lads_mat_hdr.extwg,
         mstae = rcd_lads_mat_hdr.mstae,
         mstav = rcd_lads_mat_hdr.mstav,
         mstde = rcd_lads_mat_hdr.mstde,
         mstdv = rcd_lads_mat_hdr.mstdv,
         kzumw = rcd_lads_mat_hdr.kzumw,
         kosch = rcd_lads_mat_hdr.kosch,
         nrfhg = rcd_lads_mat_hdr.nrfhg,
         mfrpn = rcd_lads_mat_hdr.mfrpn,
         mfrnr = rcd_lads_mat_hdr.mfrnr,
         bmatn = rcd_lads_mat_hdr.bmatn,
         mprof = rcd_lads_mat_hdr.mprof,
         profl = rcd_lads_mat_hdr.profl,
         ihivi = rcd_lads_mat_hdr.ihivi,
         iloos = rcd_lads_mat_hdr.iloos,
         kzgvh = rcd_lads_mat_hdr.kzgvh,
         xgchp = rcd_lads_mat_hdr.xgchp,
         compl = rcd_lads_mat_hdr.compl,
         kzeff = rcd_lads_mat_hdr.kzeff,
         rdmhd = rcd_lads_mat_hdr.rdmhd,
         iprkz = rcd_lads_mat_hdr.iprkz,
         przus = rcd_lads_mat_hdr.przus,
         mtpos_mara = rcd_lads_mat_hdr.mtpos_mara,
         gewto_new = rcd_lads_mat_hdr.gewto_new,
         volto_new = rcd_lads_mat_hdr.volto_new,
         wrkst_new = rcd_lads_mat_hdr.wrkst_new,
         aennr = rcd_lads_mat_hdr.aennr,
         matfi = rcd_lads_mat_hdr.matfi,
         cmrel = rcd_lads_mat_hdr.cmrel,
         satnr = rcd_lads_mat_hdr.satnr,
         sled_bbd = rcd_lads_mat_hdr.sled_bbd,
         gtin_variant = rcd_lads_mat_hdr.gtin_variant,
         gennr = rcd_lads_mat_hdr.gennr,
         serlv = rcd_lads_mat_hdr.serlv,
         rmatp = rcd_lads_mat_hdr.rmatp,
         zzdecvolum = rcd_lads_mat_hdr.zzdecvolum,
         zzdecvoleh = rcd_lads_mat_hdr.zzdecvoleh,
         zzdeccount = rcd_lads_mat_hdr.zzdeccount,
         zzdeccounit = rcd_lads_mat_hdr.zzdeccounit,
         zzpproweight = rcd_lads_mat_hdr.zzpproweight,
         zzpprowunit = rcd_lads_mat_hdr.zzpprowunit,
         zzpprovolum = rcd_lads_mat_hdr.zzpprovolum,
         zzpprovunit = rcd_lads_mat_hdr.zzpprovunit,
         zzpprocount = rcd_lads_mat_hdr.zzpprocount,
         zzpprocunit = rcd_lads_mat_hdr.zzpprocunit,
         zzalpha01 = rcd_lads_mat_hdr.zzalpha01,
         zzalpha02 = rcd_lads_mat_hdr.zzalpha02,
         zzalpha03 = rcd_lads_mat_hdr.zzalpha03,
         zzalpha04 = rcd_lads_mat_hdr.zzalpha04,
         zzalpha05 = rcd_lads_mat_hdr.zzalpha05,
         zzalpha06 = rcd_lads_mat_hdr.zzalpha06,
         zzalpha07 = rcd_lads_mat_hdr.zzalpha07,
         zzalpha08 = rcd_lads_mat_hdr.zzalpha08,
         zzalpha09 = rcd_lads_mat_hdr.zzalpha09,
         zzalpha10 = rcd_lads_mat_hdr.zzalpha10,
         zznum01 = rcd_lads_mat_hdr.zznum01,
         zznum02 = rcd_lads_mat_hdr.zznum02,
         zznum03 = rcd_lads_mat_hdr.zznum03,
         zznum04 = rcd_lads_mat_hdr.zznum04,
         zznum05 = rcd_lads_mat_hdr.zznum05,
         zznum06 = rcd_lads_mat_hdr.zznum06,
         zznum07 = rcd_lads_mat_hdr.zznum07,
         zznum08 = rcd_lads_mat_hdr.zznum08,
         zznum09 = rcd_lads_mat_hdr.zznum09,
         zznum10 = rcd_lads_mat_hdr.zznum10,
         zzcheck01 = rcd_lads_mat_hdr.zzcheck01,
         zzcheck02 = rcd_lads_mat_hdr.zzcheck02,
         zzcheck03 = rcd_lads_mat_hdr.zzcheck03,
         zzcheck04 = rcd_lads_mat_hdr.zzcheck04,
         zzcheck05 = rcd_lads_mat_hdr.zzcheck05,
         zzcheck06 = rcd_lads_mat_hdr.zzcheck06,
         zzcheck07 = rcd_lads_mat_hdr.zzcheck07,
         zzcheck08 = rcd_lads_mat_hdr.zzcheck08,
         zzcheck09 = rcd_lads_mat_hdr.zzcheck09,
         zzcheck10 = rcd_lads_mat_hdr.zzcheck10,
         zzplan_item = rcd_lads_mat_hdr.zzplan_item,
         zzisint = rcd_lads_mat_hdr.zzisint,
         zzismcu = rcd_lads_mat_hdr.zzismcu,
         zzispro = rcd_lads_mat_hdr.zzispro,
         zzisrsu = rcd_lads_mat_hdr.zzisrsu,
         zzissc = rcd_lads_mat_hdr.zzissc,
         zzissfp = rcd_lads_mat_hdr.zzissfp,
         zzistdu = rcd_lads_mat_hdr.zzistdu,
         zzistra = rcd_lads_mat_hdr.zzistra,
         zzstatuscode = rcd_lads_mat_hdr.zzstatuscode,
         zzitemowner = rcd_lads_mat_hdr.zzitemowner,
         zzchangedby = rcd_lads_mat_hdr.zzchangedby,
         zzmattim = rcd_lads_mat_hdr.zzmattim,
         zzrepmatnr = rcd_lads_mat_hdr.zzrepmatnr,
         idoc_name = rcd_lads_mat_hdr.idoc_name,
         idoc_number = rcd_lads_mat_hdr.idoc_number,
         idoc_timestamp = rcd_lads_mat_hdr.idoc_timestamp,
         lads_date = rcd_lads_mat_hdr.lads_date,
         lads_status = rcd_lads_mat_hdr.lads_status
      where matnr = rcd_lads_mat_hdr.matnr;
      if sql%notfound then
         insert into lads_mat_hdr
            (matnr,
             ersda,
             ernam,
             laeda,
             aenam,
             pstat,
             lvorm,
             mtart,
             mbrsh,
             matkl,
             bismt,
             meins,
             bstme,
             zeinr,
             zeiar,
             zeivr,
             zeifo,
             aeszn,
             blatt,
             blanz,
             ferth,
             formt,
             groes,
             wrkst,
             normt,
             labor,
             ekwsl,
             brgew,
             ntgew,
             gewei,
             volum,
             voleh,
             behvo,
             raube,
             tempb,
             tragr,
             stoff,
             spart,
             kunnr,
             wesch,
             bwvor,
             bwscl,
             saiso,
             etiar,
             etifo,
             ean11,
             numtp,
             laeng,
             breit,
             hoehe,
             meabm,
             prdha,
             cadkz,
             ergew,
             ergei,
             ervol,
             ervoe,
             gewto,
             volto,
             vabme,
             kzkfg,
             xchpf,
             vhart,
             fuelg,
             stfak,
             magrv,
             begru,
             qmpur,
             rbnrm,
             mhdrz,
             mhdhb,
             mhdlp,
             vpsta,
             extwg,
             mstae,
             mstav,
             mstde,
             mstdv,
             kzumw,
             kosch,
             nrfhg,
             mfrpn,
             mfrnr,
             bmatn,
             mprof,
             profl,
             ihivi,
             iloos,
             kzgvh,
             xgchp,
             compl,
             kzeff,
             rdmhd,
             iprkz,
             przus,
             mtpos_mara,
             gewto_new,
             volto_new,
             wrkst_new,
             aennr,
             matfi,
             cmrel,
             satnr,
             sled_bbd,
             gtin_variant,
             gennr,
             serlv,
             rmatp,
             zzdecvolum,
             zzdecvoleh,
             zzdeccount,
             zzdeccounit,
             zzpproweight,
             zzpprowunit,
             zzpprovolum,
             zzpprovunit,
             zzpprocount,
             zzpprocunit,
             zzalpha01,
             zzalpha02,
             zzalpha03,
             zzalpha04,
             zzalpha05,
             zzalpha06,
             zzalpha07,
             zzalpha08,
             zzalpha09,
             zzalpha10,
             zznum01,
             zznum02,
             zznum03,
             zznum04,
             zznum05,
             zznum06,
             zznum07,
             zznum08,
             zznum09,
             zznum10,
             zzcheck01,
             zzcheck02,
             zzcheck03,
             zzcheck04,
             zzcheck05,
             zzcheck06,
             zzcheck07,
             zzcheck08,
             zzcheck09,
             zzcheck10,
             zzplan_item,
             zzisint,
             zzismcu,
             zzispro,
             zzisrsu,
             zzissc,
             zzissfp,
             zzistdu,
             zzistra,
             zzstatuscode,
             zzitemowner,
             zzchangedby,
             zzmattim,
             zzrepmatnr,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_mat_hdr.matnr,
             rcd_lads_mat_hdr.ersda,
             rcd_lads_mat_hdr.ernam,
             rcd_lads_mat_hdr.laeda,
             rcd_lads_mat_hdr.aenam,
             rcd_lads_mat_hdr.pstat,
             rcd_lads_mat_hdr.lvorm,
             rcd_lads_mat_hdr.mtart,
             rcd_lads_mat_hdr.mbrsh,
             rcd_lads_mat_hdr.matkl,
             rcd_lads_mat_hdr.bismt,
             rcd_lads_mat_hdr.meins,
             rcd_lads_mat_hdr.bstme,
             rcd_lads_mat_hdr.zeinr,
             rcd_lads_mat_hdr.zeiar,
             rcd_lads_mat_hdr.zeivr,
             rcd_lads_mat_hdr.zeifo,
             rcd_lads_mat_hdr.aeszn,
             rcd_lads_mat_hdr.blatt,
             rcd_lads_mat_hdr.blanz,
             rcd_lads_mat_hdr.ferth,
             rcd_lads_mat_hdr.formt,
             rcd_lads_mat_hdr.groes,
             rcd_lads_mat_hdr.wrkst,
             rcd_lads_mat_hdr.normt,
             rcd_lads_mat_hdr.labor,
             rcd_lads_mat_hdr.ekwsl,
             rcd_lads_mat_hdr.brgew,
             rcd_lads_mat_hdr.ntgew,
             rcd_lads_mat_hdr.gewei,
             rcd_lads_mat_hdr.volum,
             rcd_lads_mat_hdr.voleh,
             rcd_lads_mat_hdr.behvo,
             rcd_lads_mat_hdr.raube,
             rcd_lads_mat_hdr.tempb,
             rcd_lads_mat_hdr.tragr,
             rcd_lads_mat_hdr.stoff,
             rcd_lads_mat_hdr.spart,
             rcd_lads_mat_hdr.kunnr,
             rcd_lads_mat_hdr.wesch,
             rcd_lads_mat_hdr.bwvor,
             rcd_lads_mat_hdr.bwscl,
             rcd_lads_mat_hdr.saiso,
             rcd_lads_mat_hdr.etiar,
             rcd_lads_mat_hdr.etifo,
             rcd_lads_mat_hdr.ean11,
             rcd_lads_mat_hdr.numtp,
             rcd_lads_mat_hdr.laeng,
             rcd_lads_mat_hdr.breit,
             rcd_lads_mat_hdr.hoehe,
             rcd_lads_mat_hdr.meabm,
             rcd_lads_mat_hdr.prdha,
             rcd_lads_mat_hdr.cadkz,
             rcd_lads_mat_hdr.ergew,
             rcd_lads_mat_hdr.ergei,
             rcd_lads_mat_hdr.ervol,
             rcd_lads_mat_hdr.ervoe,
             rcd_lads_mat_hdr.gewto,
             rcd_lads_mat_hdr.volto,
             rcd_lads_mat_hdr.vabme,
             rcd_lads_mat_hdr.kzkfg,
             rcd_lads_mat_hdr.xchpf,
             rcd_lads_mat_hdr.vhart,
             rcd_lads_mat_hdr.fuelg,
             rcd_lads_mat_hdr.stfak,
             rcd_lads_mat_hdr.magrv,
             rcd_lads_mat_hdr.begru,
             rcd_lads_mat_hdr.qmpur,
             rcd_lads_mat_hdr.rbnrm,
             rcd_lads_mat_hdr.mhdrz,
             rcd_lads_mat_hdr.mhdhb,
             rcd_lads_mat_hdr.mhdlp,
             rcd_lads_mat_hdr.vpsta,
             rcd_lads_mat_hdr.extwg,
             rcd_lads_mat_hdr.mstae,
             rcd_lads_mat_hdr.mstav,
             rcd_lads_mat_hdr.mstde,
             rcd_lads_mat_hdr.mstdv,
             rcd_lads_mat_hdr.kzumw,
             rcd_lads_mat_hdr.kosch,
             rcd_lads_mat_hdr.nrfhg,
             rcd_lads_mat_hdr.mfrpn,
             rcd_lads_mat_hdr.mfrnr,
             rcd_lads_mat_hdr.bmatn,
             rcd_lads_mat_hdr.mprof,
             rcd_lads_mat_hdr.profl,
             rcd_lads_mat_hdr.ihivi,
             rcd_lads_mat_hdr.iloos,
             rcd_lads_mat_hdr.kzgvh,
             rcd_lads_mat_hdr.xgchp,
             rcd_lads_mat_hdr.compl,
             rcd_lads_mat_hdr.kzeff,
             rcd_lads_mat_hdr.rdmhd,
             rcd_lads_mat_hdr.iprkz,
             rcd_lads_mat_hdr.przus,
             rcd_lads_mat_hdr.mtpos_mara,
             rcd_lads_mat_hdr.gewto_new,
             rcd_lads_mat_hdr.volto_new,
             rcd_lads_mat_hdr.wrkst_new,
             rcd_lads_mat_hdr.aennr,
             rcd_lads_mat_hdr.matfi,
             rcd_lads_mat_hdr.cmrel,
             rcd_lads_mat_hdr.satnr,
             rcd_lads_mat_hdr.sled_bbd,
             rcd_lads_mat_hdr.gtin_variant,
             rcd_lads_mat_hdr.gennr,
             rcd_lads_mat_hdr.serlv,
             rcd_lads_mat_hdr.rmatp,
             rcd_lads_mat_hdr.zzdecvolum,
             rcd_lads_mat_hdr.zzdecvoleh,
             rcd_lads_mat_hdr.zzdeccount,
             rcd_lads_mat_hdr.zzdeccounit,
             rcd_lads_mat_hdr.zzpproweight,
             rcd_lads_mat_hdr.zzpprowunit,
             rcd_lads_mat_hdr.zzpprovolum,
             rcd_lads_mat_hdr.zzpprovunit,
             rcd_lads_mat_hdr.zzpprocount,
             rcd_lads_mat_hdr.zzpprocunit,
             rcd_lads_mat_hdr.zzalpha01,
             rcd_lads_mat_hdr.zzalpha02,
             rcd_lads_mat_hdr.zzalpha03,
             rcd_lads_mat_hdr.zzalpha04,
             rcd_lads_mat_hdr.zzalpha05,
             rcd_lads_mat_hdr.zzalpha06,
             rcd_lads_mat_hdr.zzalpha07,
             rcd_lads_mat_hdr.zzalpha08,
             rcd_lads_mat_hdr.zzalpha09,
             rcd_lads_mat_hdr.zzalpha10,
             rcd_lads_mat_hdr.zznum01,
             rcd_lads_mat_hdr.zznum02,
             rcd_lads_mat_hdr.zznum03,
             rcd_lads_mat_hdr.zznum04,
             rcd_lads_mat_hdr.zznum05,
             rcd_lads_mat_hdr.zznum06,
             rcd_lads_mat_hdr.zznum07,
             rcd_lads_mat_hdr.zznum08,
             rcd_lads_mat_hdr.zznum09,
             rcd_lads_mat_hdr.zznum10,
             rcd_lads_mat_hdr.zzcheck01,
             rcd_lads_mat_hdr.zzcheck02,
             rcd_lads_mat_hdr.zzcheck03,
             rcd_lads_mat_hdr.zzcheck04,
             rcd_lads_mat_hdr.zzcheck05,
             rcd_lads_mat_hdr.zzcheck06,
             rcd_lads_mat_hdr.zzcheck07,
             rcd_lads_mat_hdr.zzcheck08,
             rcd_lads_mat_hdr.zzcheck09,
             rcd_lads_mat_hdr.zzcheck10,
             rcd_lads_mat_hdr.zzplan_item,
             rcd_lads_mat_hdr.zzisint,
             rcd_lads_mat_hdr.zzismcu,
             rcd_lads_mat_hdr.zzispro,
             rcd_lads_mat_hdr.zzisrsu,
             rcd_lads_mat_hdr.zzissc,
             rcd_lads_mat_hdr.zzissfp,
             rcd_lads_mat_hdr.zzistdu,
             rcd_lads_mat_hdr.zzistra,
             rcd_lads_mat_hdr.zzstatuscode,
             rcd_lads_mat_hdr.zzitemowner,
             rcd_lads_mat_hdr.zzchangedby,
             rcd_lads_mat_hdr.zzmattim,
             rcd_lads_mat_hdr.zzrepmatnr,
             rcd_lads_mat_hdr.idoc_name,
             rcd_lads_mat_hdr.idoc_number,
             rcd_lads_mat_hdr.idoc_timestamp,
             rcd_lads_mat_hdr.lads_date,
             rcd_lads_mat_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record PCH routine */
   /**************************************************/
   procedure process_record_pch(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PCH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_pch.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_pch.pchseq := rcd_lads_mat_pch.pchseq + 1;
      rcd_lads_mat_pch.kvewe := lics_inbound_utility.get_variable('KVEWE');
      rcd_lads_mat_pch.kotabnr := lics_inbound_utility.get_number('KOTABNR',null);
      rcd_lads_mat_pch.kappl := lics_inbound_utility.get_variable('KAPPL');
      rcd_lads_mat_pch.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_mat_pch.vakey := lics_inbound_utility.get_variable('VAKEY');
      rcd_lads_mat_pch.vkorg := lics_inbound_utility.get_variable('VKORG');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_pcr.pcrseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_pch.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PCH.MATNR');
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

      insert into lads_mat_pch
         (matnr,
          pchseq,
          kvewe,
          kotabnr,
          kappl,
          kschl,
          vakey,
          vkorg)
      values
         (rcd_lads_mat_pch.matnr,
          rcd_lads_mat_pch.pchseq,
          rcd_lads_mat_pch.kvewe,
          rcd_lads_mat_pch.kotabnr,
          rcd_lads_mat_pch.kappl,
          rcd_lads_mat_pch.kschl,
          rcd_lads_mat_pch.vakey,
          rcd_lads_mat_pch.vkorg);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pch;

   /**************************************************/
   /* This procedure performs the record PCR routine */
   /**************************************************/
   procedure process_record_pcr(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PCR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_pcr.matnr := rcd_lads_mat_pch.matnr;
      rcd_lads_mat_pcr.pchseq := rcd_lads_mat_pch.pchseq;
      rcd_lads_mat_pcr.pcrseq := rcd_lads_mat_pcr.pcrseq + 1;
      rcd_lads_mat_pcr.knumh := lics_inbound_utility.get_variable('KNUMH');
      rcd_lads_mat_pcr.datab := lics_inbound_utility.get_variable('DATAB');
      rcd_lads_mat_pcr.datbi := lics_inbound_utility.get_variable('DATBI');
      rcd_lads_mat_pcr.packnr := lics_inbound_utility.get_variable('PACKNR');
      rcd_lads_mat_pcr.packnr1 := lics_inbound_utility.get_variable('PACKNR1');
      rcd_lads_mat_pcr.packnr2 := lics_inbound_utility.get_variable('PACKNR2');
      rcd_lads_mat_pcr.packnr3 := lics_inbound_utility.get_variable('PACKNR3');
      rcd_lads_mat_pcr.packnr4 := lics_inbound_utility.get_variable('PACKNR4');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_pih.pihseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_pcr.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PCR.MATNR');
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

      insert into lads_mat_pcr
         (matnr,
          pchseq,
          pcrseq,
          knumh,
          datab,
          datbi,
          packnr,
          packnr1,
          packnr2,
          packnr3,
          packnr4)
      values
         (rcd_lads_mat_pcr.matnr,
          rcd_lads_mat_pcr.pchseq,
          rcd_lads_mat_pcr.pcrseq,
          rcd_lads_mat_pcr.knumh,
          rcd_lads_mat_pcr.datab,
          rcd_lads_mat_pcr.datbi,
          rcd_lads_mat_pcr.packnr,
          rcd_lads_mat_pcr.packnr1,
          rcd_lads_mat_pcr.packnr2,
          rcd_lads_mat_pcr.packnr3,
          rcd_lads_mat_pcr.packnr4);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pcr;

   /**************************************************/
   /* This procedure performs the record PIH routine */
   /**************************************************/
   procedure process_record_pih(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PIH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_pih.matnr := rcd_lads_mat_pcr.matnr;
      rcd_lads_mat_pih.pchseq := rcd_lads_mat_pcr.pchseq;
      rcd_lads_mat_pih.pcrseq := rcd_lads_mat_pcr.pcrseq;
      rcd_lads_mat_pih.pihseq:= rcd_lads_mat_pih.pihseq + 1;
      rcd_lads_mat_pih.packnr := lics_inbound_utility.get_variable('PACKNR');
      rcd_lads_mat_pih.height := lics_inbound_utility.get_number('HEIGHT',null);
      rcd_lads_mat_pih.width := lics_inbound_utility.get_number('WIDTH',null);
      rcd_lads_mat_pih.length := lics_inbound_utility.get_number('LENGTH',null);
      rcd_lads_mat_pih.tarewei := lics_inbound_utility.get_number('TAREWEI',null);
      rcd_lads_mat_pih.loadwei := lics_inbound_utility.get_number('LOADWEI',null);
      rcd_lads_mat_pih.totlwei := lics_inbound_utility.get_number('TOTLWEI',null);
      rcd_lads_mat_pih.tarevol := lics_inbound_utility.get_number('TAREVOL',null);
      rcd_lads_mat_pih.loadvol := lics_inbound_utility.get_number('LOADVOL',null);
      rcd_lads_mat_pih.totlvol := lics_inbound_utility.get_number('TOTLVOL',null);
      rcd_lads_mat_pih.pobjid := lics_inbound_utility.get_variable('POBJID');
      rcd_lads_mat_pih.stfac := lics_inbound_utility.get_number('STFAC',null);
      rcd_lads_mat_pih.chdat := lics_inbound_utility.get_variable('CHDAT');
      rcd_lads_mat_pih.unitdim := lics_inbound_utility.get_variable('UNITDIM');
      rcd_lads_mat_pih.unitwei := lics_inbound_utility.get_variable('UNITWEI');
      rcd_lads_mat_pih.unitwei_max := lics_inbound_utility.get_variable('UNITWEI_MAX');
      rcd_lads_mat_pih.unitvol := lics_inbound_utility.get_variable('UNITVOL');
      rcd_lads_mat_pih.unitvol_max := lics_inbound_utility.get_variable('UNITVOL_MAX');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_pie.pieseq := 0;
      rcd_lads_mat_pir.pirseq := 0;
      rcd_lads_mat_pit.pitseq := 0;
      rcd_lads_mat_pim.pimseq := 0;
      rcd_lads_mat_pid.pidseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_pih.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PIH.MATNR');
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

      insert into lads_mat_pih
         (matnr,
          pchseq,
          pcrseq,
          pihseq,
          packnr,
          height,
          width,
          length,
          tarewei,
          loadwei,
          totlwei,
          tarevol,
          loadvol,
          totlvol,
          pobjid,
          stfac,
          chdat,
          unitdim,
          unitwei,
          unitwei_max,
          unitvol,
          unitvol_max)
      values
         (rcd_lads_mat_pih.matnr,
          rcd_lads_mat_pih.pchseq,
          rcd_lads_mat_pih.pcrseq,
          rcd_lads_mat_pih.pihseq,
          rcd_lads_mat_pih.packnr,
          rcd_lads_mat_pih.height,
          rcd_lads_mat_pih.width,
          rcd_lads_mat_pih.length,
          rcd_lads_mat_pih.tarewei,
          rcd_lads_mat_pih.loadwei,
          rcd_lads_mat_pih.totlwei,
          rcd_lads_mat_pih.tarevol,
          rcd_lads_mat_pih.loadvol,
          rcd_lads_mat_pih.totlvol,
          rcd_lads_mat_pih.pobjid,
          rcd_lads_mat_pih.stfac,
          rcd_lads_mat_pih.chdat,
          rcd_lads_mat_pih.unitdim,
          rcd_lads_mat_pih.unitwei,
          rcd_lads_mat_pih.unitwei_max,
          rcd_lads_mat_pih.unitvol,
          rcd_lads_mat_pih.unitvol_max);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pih;

   /**************************************************/
   /* This procedure performs the record PIE routine */
   /**************************************************/
   procedure process_record_pie(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PIE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_pie.matnr := rcd_lads_mat_pih.matnr;
      rcd_lads_mat_pie.pchseq := rcd_lads_mat_pih.pchseq;
      rcd_lads_mat_pie.pcrseq := rcd_lads_mat_pih.pcrseq;
      rcd_lads_mat_pie.pihseq := rcd_lads_mat_pih.pihseq;
      rcd_lads_mat_pie.pieseq := rcd_lads_mat_pie.pieseq + 1;
      rcd_lads_mat_pie.ean11 := lics_inbound_utility.get_variable('EAN11');
      rcd_lads_mat_pie.eantp := lics_inbound_utility.get_variable('EANTP');
      rcd_lads_mat_pie.hpean := lics_inbound_utility.get_variable('HPEAN');

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
      if rcd_lads_mat_pie.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PIE.MATNR');
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

      insert into lads_mat_pie
         (matnr,
          pchseq,
          pcrseq,
          pihseq,
          pieseq,
          ean11,
          eantp,
          hpean)
      values
         (rcd_lads_mat_pie.matnr,
          rcd_lads_mat_pie.pchseq,
          rcd_lads_mat_pie.pcrseq,
          rcd_lads_mat_pie.pihseq,
          rcd_lads_mat_pie.pieseq,
          rcd_lads_mat_pie.ean11,
          rcd_lads_mat_pie.eantp,
          rcd_lads_mat_pie.hpean);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pie;

   /**************************************************/
   /* This procedure performs the record PIR routine */
   /**************************************************/
   procedure process_record_pir(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PIR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_pir.matnr := rcd_lads_mat_pih.matnr;
      rcd_lads_mat_pir.pchseq := rcd_lads_mat_pih.pchseq;
      rcd_lads_mat_pir.pcrseq := rcd_lads_mat_pih.pcrseq;
      rcd_lads_mat_pir.pihseq := rcd_lads_mat_pih.pihseq;
      rcd_lads_mat_pir.pirseq := rcd_lads_mat_pir.pirseq + 1;
      rcd_lads_mat_pir.z_lcdid := lics_inbound_utility.get_variable('Z_LCDID');
      rcd_lads_mat_pir.z_lcdnr := lics_inbound_utility.get_variable('Z_LCDNR');

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
      if rcd_lads_mat_pir.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PIR.MATNR');
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

      insert into lads_mat_pir
         (matnr,
          pchseq,
          pcrseq,
          pihseq,
          pirseq,
          z_lcdid,
          z_lcdnr)
      values
         (rcd_lads_mat_pir.matnr,
          rcd_lads_mat_pir.pchseq,
          rcd_lads_mat_pir.pcrseq,
          rcd_lads_mat_pir.pihseq,
          rcd_lads_mat_pir.pirseq,
          rcd_lads_mat_pir.z_lcdid,
          rcd_lads_mat_pir.z_lcdnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pir;

   /**************************************************/
   /* This procedure performs the record PIT routine */
   /**************************************************/
   procedure process_record_pit(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PIT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_pit.matnr := rcd_lads_mat_pih.matnr;
      rcd_lads_mat_pit.pchseq := rcd_lads_mat_pih.pchseq;
      rcd_lads_mat_pit.pcrseq := rcd_lads_mat_pih.pcrseq;
      rcd_lads_mat_pit.pihseq := rcd_lads_mat_pih.pihseq;
      rcd_lads_mat_pit.pitseq := rcd_lads_mat_pit.pitseq + 1;
      rcd_lads_mat_pit.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_mat_pit.content := lics_inbound_utility.get_variable('CONTENT');

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
      if rcd_lads_mat_pit.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PIT.MATNR');
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

      insert into lads_mat_pit
         (matnr,
          pchseq,
          pcrseq,
          pihseq,
          pitseq,
          spras,
          content)
      values
         (rcd_lads_mat_pit.matnr,
          rcd_lads_mat_pit.pchseq,
          rcd_lads_mat_pit.pcrseq,
          rcd_lads_mat_pit.pihseq,
          rcd_lads_mat_pit.pitseq,
          rcd_lads_mat_pit.spras,
          rcd_lads_mat_pit.content);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pit;

   /**************************************************/
   /* This procedure performs the record PIM routine */
   /**************************************************/
   procedure process_record_pim(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PIM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_pim.matnr := rcd_lads_mat_pih.matnr;
      rcd_lads_mat_pim.pchseq := rcd_lads_mat_pih.pchseq;
      rcd_lads_mat_pim.pcrseq := rcd_lads_mat_pih.pcrseq;
      rcd_lads_mat_pim.pihseq := rcd_lads_mat_pih.pihseq;
      rcd_lads_mat_pim.pimseq := rcd_lads_mat_pim.pimseq + 1;
      rcd_lads_mat_pim.moe := lics_inbound_utility.get_variable('MOE');
      rcd_lads_mat_pim.usagecode := lics_inbound_utility.get_variable('USAGECODE');
      rcd_lads_mat_pim.datab := lics_inbound_utility.get_variable('DATAB');
      rcd_lads_mat_pim.dated := lics_inbound_utility.get_variable('DATED');

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
      if rcd_lads_mat_pim.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PIM.MATNR');
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

      insert into lads_mat_pim
         (matnr,
          pchseq,
          pcrseq,
          pihseq,
          pimseq,
          moe,
          usagecode,
          datab,
          dated)
      values
         (rcd_lads_mat_pim.matnr,
          rcd_lads_mat_pim.pchseq,
          rcd_lads_mat_pim.pcrseq,
          rcd_lads_mat_pim.pihseq,
          rcd_lads_mat_pim.pimseq,
          rcd_lads_mat_pim.moe,
          rcd_lads_mat_pim.usagecode,
          rcd_lads_mat_pim.datab,
          rcd_lads_mat_pim.dated);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pim;

   /**************************************************/
   /* This procedure performs the record PID routine */
   /**************************************************/
   procedure process_record_pid(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PID', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_pid.matnr := rcd_lads_mat_pih.matnr;
      rcd_lads_mat_pid.pchseq := rcd_lads_mat_pih.pchseq;
      rcd_lads_mat_pid.pcrseq := rcd_lads_mat_pih.pcrseq;
      rcd_lads_mat_pid.pihseq := rcd_lads_mat_pih.pihseq;
      rcd_lads_mat_pid.pidseq := rcd_lads_mat_pid.pidseq + 1;
      rcd_lads_mat_pid.packitem := lics_inbound_utility.get_number('PACKITEM',null);
      rcd_lads_mat_pid.detail_itemtype := lics_inbound_utility.get_variable('DETAIL_ITEMTYPE');
      rcd_lads_mat_pid.component := lics_inbound_utility.get_variable('COMPONENT');
      rcd_lads_mat_pid.trgqty := lics_inbound_utility.get_number('TRGQTY',null);
      rcd_lads_mat_pid.minqty := lics_inbound_utility.get_number('MINQTY',null);
      rcd_lads_mat_pid.rndqty := lics_inbound_utility.get_number('RNDQTY',null);
      rcd_lads_mat_pid.unitqty := lics_inbound_utility.get_variable('UNITQTY');
      rcd_lads_mat_pid.indmapaco := lics_inbound_utility.get_variable('INDMAPACO');

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
      if rcd_lads_mat_pid.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PID.MATNR');
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

      insert into lads_mat_pid
         (matnr,
          pchseq,
          pcrseq,
          pihseq,
          pidseq,
          packitem,
          detail_itemtype,
          component,
          trgqty,
          minqty,
          rndqty,
          unitqty,
          indmapaco)
      values
         (rcd_lads_mat_pid.matnr,
          rcd_lads_mat_pid.pchseq,
          rcd_lads_mat_pid.pcrseq,
          rcd_lads_mat_pid.pihseq,
          rcd_lads_mat_pid.pidseq,
          rcd_lads_mat_pid.packitem,
          rcd_lads_mat_pid.detail_itemtype,
          rcd_lads_mat_pid.component,
          rcd_lads_mat_pid.trgqty,
          rcd_lads_mat_pid.minqty,
          rcd_lads_mat_pid.rndqty,
          rcd_lads_mat_pid.unitqty,
          rcd_lads_mat_pid.indmapaco);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pid;

   /**************************************************/
   /* This procedure performs the record MOE routine */
   /**************************************************/
   procedure process_record_moe(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MOE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_moe.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_moe.moeseq := rcd_lads_mat_moe.moeseq + 1;
      rcd_lads_mat_moe.usagecode := lics_inbound_utility.get_variable('USAGECODE');
      rcd_lads_mat_moe.moe := lics_inbound_utility.get_variable('MOE');
      rcd_lads_mat_moe.datab := lics_inbound_utility.get_variable('DATAB');
      rcd_lads_mat_moe.dated := lics_inbound_utility.get_variable('DATED');

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
      if rcd_lads_mat_moe.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MOE.MATNR');
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

      insert into lads_mat_moe
         (matnr,
          moeseq,
          usagecode,
          moe,
          datab,
          dated)
      values
         (rcd_lads_mat_moe.matnr,
          rcd_lads_mat_moe.moeseq,
          rcd_lads_mat_moe.usagecode,
          rcd_lads_mat_moe.moe,
          rcd_lads_mat_moe.datab,
          rcd_lads_mat_moe.dated);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_moe;

   /**************************************************/
   /* This procedure performs the record GME routine */
   /**************************************************/
   procedure process_record_gme(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('GME', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_gme.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_gme.gmeseq := rcd_lads_mat_gme.gmeseq + 1;
      rcd_lads_mat_gme.grouptype := lics_inbound_utility.get_variable('GROUPTYPE');
      rcd_lads_mat_gme.groupmoe := lics_inbound_utility.get_variable('GROUPMOE');
      rcd_lads_mat_gme.usagecode := lics_inbound_utility.get_variable('USAGECODE');
      rcd_lads_mat_gme.datab := lics_inbound_utility.get_variable('DATAB');
      rcd_lads_mat_gme.dated := lics_inbound_utility.get_variable('DATED');

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
      if rcd_lads_mat_gme.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - GME.MATNR');
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

      insert into lads_mat_gme
         (matnr,
          gmeseq,
          grouptype,
          groupmoe,
          usagecode,
          datab,
          dated)
      values
         (rcd_lads_mat_gme.matnr,
          rcd_lads_mat_gme.gmeseq,
          rcd_lads_mat_gme.grouptype,
          rcd_lads_mat_gme.groupmoe,
          rcd_lads_mat_gme.usagecode,
          rcd_lads_mat_gme.datab,
          rcd_lads_mat_gme.dated);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_gme;

   /**************************************************/
   /* This procedure performs the record LCD routine */
   /**************************************************/
   procedure process_record_lcd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('LCD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_lcd.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_lcd.lcdseq := rcd_lads_mat_lcd.lcdseq + 1;
      rcd_lads_mat_lcd.z_matnr := lics_inbound_utility.get_variable('Z_MATNR');
      rcd_lads_mat_lcd.z_lcdid := lics_inbound_utility.get_variable('Z_LCDID');
      rcd_lads_mat_lcd.z_lcdnr := lics_inbound_utility.get_variable('Z_LCDNR');

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
      if rcd_lads_mat_lcd.z_matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LCD.Z_MATNR');
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

      insert into lads_mat_lcd
         (matnr,
          lcdseq,
          z_matnr,
          z_lcdid,
          z_lcdnr)
      values
         (rcd_lads_mat_lcd.matnr,
          rcd_lads_mat_lcd.lcdseq,
          rcd_lads_mat_lcd.z_matnr,
          rcd_lads_mat_lcd.z_lcdid,
          rcd_lads_mat_lcd.z_lcdnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_lcd;

   /**************************************************/
   /* This procedure performs the record MKT routine */
   /**************************************************/
   procedure process_record_mkt(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MKT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mkt.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_mkt.mktseq := rcd_lads_mat_mkt.mktseq + 1;
      rcd_lads_mat_mkt.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mkt.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_mat_mkt.maktx := lics_inbound_utility.get_variable('MAKTX');
      rcd_lads_mat_mkt.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');

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
      if rcd_lads_mat_mkt.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MKT.MATNR');
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

      insert into lads_mat_mkt
         (matnr,
          mktseq,
          msgfn,
          spras,
          maktx,
          spras_iso)
      values
         (rcd_lads_mat_mkt.matnr,
          rcd_lads_mat_mkt.mktseq,
          rcd_lads_mat_mkt.msgfn,
          rcd_lads_mat_mkt.spras,
          rcd_lads_mat_mkt.maktx,
          rcd_lads_mat_mkt.spras_iso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mkt;

   /**************************************************/
   /* This procedure performs the record MRC routine */
   /**************************************************/
   procedure process_record_mrc(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MRC', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mrc.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_mrc.mrcseq := rcd_lads_mat_mrc.mrcseq + 1;
      rcd_lads_mat_mrc.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mrc.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_mat_mrc.pstat := lics_inbound_utility.get_variable('PSTAT');
      rcd_lads_mat_mrc.lvorm := lics_inbound_utility.get_variable('LVORM');
      rcd_lads_mat_mrc.bwtty := lics_inbound_utility.get_variable('BWTTY');
      rcd_lads_mat_mrc.maabc := lics_inbound_utility.get_variable('MAABC');
      rcd_lads_mat_mrc.kzkri := lics_inbound_utility.get_variable('KZKRI');
      rcd_lads_mat_mrc.ekgrp := lics_inbound_utility.get_variable('EKGRP');
      rcd_lads_mat_mrc.ausme := lics_inbound_utility.get_variable('AUSME');
      rcd_lads_mat_mrc.dispr := lics_inbound_utility.get_variable('DISPR');
      rcd_lads_mat_mrc.dismm := lics_inbound_utility.get_variable('DISMM');
      rcd_lads_mat_mrc.dispo := lics_inbound_utility.get_variable('DISPO');
      rcd_lads_mat_mrc.plifz := lics_inbound_utility.get_number('PLIFZ',null);
      rcd_lads_mat_mrc.webaz := lics_inbound_utility.get_number('WEBAZ',null);
      rcd_lads_mat_mrc.perkz := lics_inbound_utility.get_variable('PERKZ');
      rcd_lads_mat_mrc.ausss := lics_inbound_utility.get_number('AUSSS',null);
      rcd_lads_mat_mrc.disls := lics_inbound_utility.get_variable('DISLS');
      rcd_lads_mat_mrc.beskz := lics_inbound_utility.get_variable('BESKZ');
      rcd_lads_mat_mrc.sobsl := lics_inbound_utility.get_variable('SOBSL');
      rcd_lads_mat_mrc.minbe := lics_inbound_utility.get_number('MINBE',null);
      rcd_lads_mat_mrc.eisbe := lics_inbound_utility.get_number('EISBE',null);
      rcd_lads_mat_mrc.bstmi := lics_inbound_utility.get_number('BSTMI',null);
      rcd_lads_mat_mrc.bstma := lics_inbound_utility.get_number('BSTMA',null);
      rcd_lads_mat_mrc.bstfe := lics_inbound_utility.get_number('BSTFE',null);
      rcd_lads_mat_mrc.bstrf := lics_inbound_utility.get_number('BSTRF',null);
      rcd_lads_mat_mrc.mabst := lics_inbound_utility.get_number('MABST',null);
      rcd_lads_mat_mrc.losfx := lics_inbound_utility.get_number('LOSFX',null);
      rcd_lads_mat_mrc.sbdkz := lics_inbound_utility.get_variable('SBDKZ');
      rcd_lads_mat_mrc.lagpr := lics_inbound_utility.get_variable('LAGPR');
      rcd_lads_mat_mrc.altsl := lics_inbound_utility.get_variable('ALTSL');
      rcd_lads_mat_mrc.kzaus := lics_inbound_utility.get_variable('KZAUS');
      rcd_lads_mat_mrc.ausdt := lics_inbound_utility.get_variable('AUSDT');
      rcd_lads_mat_mrc.nfmat := lics_inbound_utility.get_variable('NFMAT');
      rcd_lads_mat_mrc.kzbed := lics_inbound_utility.get_variable('KZBED');
      rcd_lads_mat_mrc.miskz := lics_inbound_utility.get_variable('MISKZ');
      rcd_lads_mat_mrc.fhori := lics_inbound_utility.get_variable('FHORI');
      rcd_lads_mat_mrc.pfrei := lics_inbound_utility.get_variable('PFREI');
      rcd_lads_mat_mrc.ffrei := lics_inbound_utility.get_variable('FFREI');
      rcd_lads_mat_mrc.rgekz := lics_inbound_utility.get_variable('RGEKZ');
      rcd_lads_mat_mrc.fevor := lics_inbound_utility.get_variable('FEVOR');
      rcd_lads_mat_mrc.bearz := lics_inbound_utility.get_number('BEARZ',null);
      rcd_lads_mat_mrc.ruezt := lics_inbound_utility.get_number('RUEZT',null);
      rcd_lads_mat_mrc.tranz := lics_inbound_utility.get_number('TRANZ',null);
      rcd_lads_mat_mrc.basmg := lics_inbound_utility.get_number('BASMG',null);
      rcd_lads_mat_mrc.dzeit := lics_inbound_utility.get_number('DZEIT',null);
      rcd_lads_mat_mrc.maxlz := lics_inbound_utility.get_number('MAXLZ',null);
      rcd_lads_mat_mrc.lzeih := lics_inbound_utility.get_variable('LZEIH');
      rcd_lads_mat_mrc.kzpro := lics_inbound_utility.get_variable('KZPRO');
      rcd_lads_mat_mrc.gpmkz := lics_inbound_utility.get_variable('GPMKZ');
      rcd_lads_mat_mrc.ueeto := lics_inbound_utility.get_number('UEETO',null);
      rcd_lads_mat_mrc.ueetk := lics_inbound_utility.get_variable('UEETK');
      rcd_lads_mat_mrc.uneto := lics_inbound_utility.get_number('UNETO',null);
      rcd_lads_mat_mrc.wzeit := lics_inbound_utility.get_number('WZEIT',null);
      rcd_lads_mat_mrc.atpkz := lics_inbound_utility.get_variable('ATPKZ');
      rcd_lads_mat_mrc.vzusl := lics_inbound_utility.get_number('VZUSL',null);
      rcd_lads_mat_mrc.herbl := lics_inbound_utility.get_variable('HERBL');
      rcd_lads_mat_mrc.insmk := lics_inbound_utility.get_variable('INSMK');
      rcd_lads_mat_mrc.ssqss := lics_inbound_utility.get_variable('SSQSS');
      rcd_lads_mat_mrc.kzdkz := lics_inbound_utility.get_variable('KZDKZ');
      rcd_lads_mat_mrc.umlmc := lics_inbound_utility.get_number('UMLMC',null);
      rcd_lads_mat_mrc.ladgr := lics_inbound_utility.get_variable('LADGR');
      rcd_lads_mat_mrc.xchpf := lics_inbound_utility.get_variable('XCHPF');
      rcd_lads_mat_mrc.usequ := lics_inbound_utility.get_variable('USEQU');
      rcd_lads_mat_mrc.lgrad := lics_inbound_utility.get_number('LGRAD',null);
      rcd_lads_mat_mrc.auftl := lics_inbound_utility.get_variable('AUFTL');
      rcd_lads_mat_mrc.plvar := lics_inbound_utility.get_variable('PLVAR');
      rcd_lads_mat_mrc.otype := lics_inbound_utility.get_variable('OTYPE');
      rcd_lads_mat_mrc.objid := lics_inbound_utility.get_number('OBJID',null);
      rcd_lads_mat_mrc.mtvfp := lics_inbound_utility.get_variable('MTVFP');
      rcd_lads_mat_mrc.periv := lics_inbound_utility.get_variable('PERIV');
      rcd_lads_mat_mrc.kzkfk := lics_inbound_utility.get_variable('KZKFK');
      rcd_lads_mat_mrc.vrvez := lics_inbound_utility.get_number('VRVEZ',null);
      rcd_lads_mat_mrc.vbamg := lics_inbound_utility.get_number('VBAMG',null);
      rcd_lads_mat_mrc.vbeaz := lics_inbound_utility.get_number('VBEAZ',null);
      rcd_lads_mat_mrc.lizyk := lics_inbound_utility.get_variable('LIZYK');
      rcd_lads_mat_mrc.bwscl := lics_inbound_utility.get_variable('BWSCL');
      rcd_lads_mat_mrc.kautb := lics_inbound_utility.get_variable('KAUTB');
      rcd_lads_mat_mrc.kordb := lics_inbound_utility.get_variable('KORDB');
      rcd_lads_mat_mrc.stawn := lics_inbound_utility.get_variable('STAWN');
      rcd_lads_mat_mrc.herkl := lics_inbound_utility.get_variable('HERKL');
      rcd_lads_mat_mrc.herkr := lics_inbound_utility.get_variable('HERKR');
      rcd_lads_mat_mrc.expme := lics_inbound_utility.get_variable('EXPME');
      rcd_lads_mat_mrc.mtver := lics_inbound_utility.get_variable('MTVER');
      rcd_lads_mat_mrc.prctr := lics_inbound_utility.get_variable('PRCTR');
      rcd_lads_mat_mrc.trame := lics_inbound_utility.get_number('TRAME',null);
      rcd_lads_mat_mrc.mrppp := lics_inbound_utility.get_variable('MRPPP');
      rcd_lads_mat_mrc.sauft := lics_inbound_utility.get_variable('SAUFT');
      rcd_lads_mat_mrc.fxhor := lics_inbound_utility.get_number('FXHOR',null);
      rcd_lads_mat_mrc.vrmod := lics_inbound_utility.get_variable('VRMOD');
      rcd_lads_mat_mrc.vint1 := lics_inbound_utility.get_number('VINT1',null);
      rcd_lads_mat_mrc.vint2 := lics_inbound_utility.get_number('VINT2',null);
      rcd_lads_mat_mrc.stlal := lics_inbound_utility.get_variable('STLAL');
      rcd_lads_mat_mrc.stlan := lics_inbound_utility.get_variable('STLAN');
      rcd_lads_mat_mrc.plnnr := lics_inbound_utility.get_variable('PLNNR');
      rcd_lads_mat_mrc.aplal := lics_inbound_utility.get_variable('APLAL');
      rcd_lads_mat_mrc.losgr := lics_inbound_utility.get_number('LOSGR',null);
      rcd_lads_mat_mrc.sobsk := lics_inbound_utility.get_variable('SOBSK');
      rcd_lads_mat_mrc.frtme := lics_inbound_utility.get_variable('FRTME');
      rcd_lads_mat_mrc.lgpro := lics_inbound_utility.get_variable('LGPRO');
      rcd_lads_mat_mrc.disgr := lics_inbound_utility.get_variable('DISGR');
      rcd_lads_mat_mrc.kausf := lics_inbound_utility.get_number('KAUSF',null);
      rcd_lads_mat_mrc.qzgtp := lics_inbound_utility.get_variable('QZGTP');
      rcd_lads_mat_mrc.takzt := lics_inbound_utility.get_number('TAKZT',null);
      rcd_lads_mat_mrc.rwpro := lics_inbound_utility.get_variable('RWPRO');
      rcd_lads_mat_mrc.copam := lics_inbound_utility.get_variable('COPAM');
      rcd_lads_mat_mrc.abcin := lics_inbound_utility.get_variable('ABCIN');
      rcd_lads_mat_mrc.awsls := lics_inbound_utility.get_variable('AWSLS');
      rcd_lads_mat_mrc.sernp := lics_inbound_utility.get_variable('SERNP');
      rcd_lads_mat_mrc.stdpd := lics_inbound_utility.get_variable('STDPD');
      rcd_lads_mat_mrc.sfepr := lics_inbound_utility.get_variable('SFEPR');
      rcd_lads_mat_mrc.xmcng := lics_inbound_utility.get_variable('XMCNG');
      rcd_lads_mat_mrc.qssys := lics_inbound_utility.get_variable('QSSYS');
      rcd_lads_mat_mrc.lfrhy := lics_inbound_utility.get_variable('LFRHY');
      rcd_lads_mat_mrc.rdprf := lics_inbound_utility.get_variable('RDPRF');
      rcd_lads_mat_mrc.vrbmt := lics_inbound_utility.get_variable('VRBMT');
      rcd_lads_mat_mrc.vrbwk := lics_inbound_utility.get_variable('VRBWK');
      rcd_lads_mat_mrc.vrbdt := lics_inbound_utility.get_variable('VRBDT');
      rcd_lads_mat_mrc.vrbfk := lics_inbound_utility.get_number('VRBFK',null);
      rcd_lads_mat_mrc.autru := lics_inbound_utility.get_variable('AUTRU');
      rcd_lads_mat_mrc.prefe := lics_inbound_utility.get_variable('PREFE');
      rcd_lads_mat_mrc.prenc := lics_inbound_utility.get_variable('PRENC');
      rcd_lads_mat_mrc.preno := lics_inbound_utility.get_number('PRENO',null);
      rcd_lads_mat_mrc.prend := lics_inbound_utility.get_variable('PREND');
      rcd_lads_mat_mrc.prene := lics_inbound_utility.get_variable('PRENE');
      rcd_lads_mat_mrc.preng := lics_inbound_utility.get_variable('PRENG');
      rcd_lads_mat_mrc.itark := lics_inbound_utility.get_variable('ITARK');
      rcd_lads_mat_mrc.prfrq := lics_inbound_utility.get_variable('PRFRQ');
      rcd_lads_mat_mrc.kzkup := lics_inbound_utility.get_variable('KZKUP');
      rcd_lads_mat_mrc.strgr := lics_inbound_utility.get_variable('STRGR');
      rcd_lads_mat_mrc.lgfsb := lics_inbound_utility.get_variable('LGFSB');
      rcd_lads_mat_mrc.schgt := lics_inbound_utility.get_variable('SCHGT');
      rcd_lads_mat_mrc.ccfix := lics_inbound_utility.get_variable('CCFIX');
      rcd_lads_mat_mrc.eprio := lics_inbound_utility.get_variable('EPRIO');
      rcd_lads_mat_mrc.qmata := lics_inbound_utility.get_variable('QMATA');
      rcd_lads_mat_mrc.plnty := lics_inbound_utility.get_variable('PLNTY');
      rcd_lads_mat_mrc.mmsta := lics_inbound_utility.get_variable('MMSTA');
      rcd_lads_mat_mrc.sfcpf := lics_inbound_utility.get_variable('SFCPF');
      rcd_lads_mat_mrc.shflg := lics_inbound_utility.get_variable('SHFLG');
      rcd_lads_mat_mrc.shzet := lics_inbound_utility.get_number('SHZET',null);
      rcd_lads_mat_mrc.mdach := lics_inbound_utility.get_variable('MDACH');
      rcd_lads_mat_mrc.kzech := lics_inbound_utility.get_variable('KZECH');
      rcd_lads_mat_mrc.mmstd := lics_inbound_utility.get_variable('MMSTD');
      rcd_lads_mat_mrc.mfrgr := lics_inbound_utility.get_variable('MFRGR');
      rcd_lads_mat_mrc.fvidk := lics_inbound_utility.get_variable('FVIDK');
      rcd_lads_mat_mrc.indus := lics_inbound_utility.get_variable('INDUS');
      rcd_lads_mat_mrc.mownr := lics_inbound_utility.get_variable('MOWNR');
      rcd_lads_mat_mrc.mogru := lics_inbound_utility.get_variable('MOGRU');
      rcd_lads_mat_mrc.casnr := lics_inbound_utility.get_variable('CASNR');
      rcd_lads_mat_mrc.gpnum := lics_inbound_utility.get_variable('GPNUM');
      rcd_lads_mat_mrc.steuc := lics_inbound_utility.get_variable('STEUC');
      rcd_lads_mat_mrc.fabkz := lics_inbound_utility.get_variable('FABKZ');
      rcd_lads_mat_mrc.matgr := lics_inbound_utility.get_variable('MATGR');
      rcd_lads_mat_mrc.loggr := lics_inbound_utility.get_variable('LOGGR');
      rcd_lads_mat_mrc.vspvb := lics_inbound_utility.get_variable('VSPVB');
      rcd_lads_mat_mrc.dplfs := lics_inbound_utility.get_variable('DPLFS');
      rcd_lads_mat_mrc.dplpu := lics_inbound_utility.get_variable('DPLPU');
      rcd_lads_mat_mrc.dplho := lics_inbound_utility.get_number('DPLHO',null);
      rcd_lads_mat_mrc.minls := lics_inbound_utility.get_number('MINLS',null);
      rcd_lads_mat_mrc.maxls := lics_inbound_utility.get_number('MAXLS',null);
      rcd_lads_mat_mrc.fixls := lics_inbound_utility.get_number('FIXLS',null);
      rcd_lads_mat_mrc.ltinc := lics_inbound_utility.get_number('LTINC',null);
      rcd_lads_mat_mrc.compl := lics_inbound_utility.get_number('COMPL',null);
      rcd_lads_mat_mrc.convt := lics_inbound_utility.get_variable('CONVT');
      rcd_lads_mat_mrc.fprfm := lics_inbound_utility.get_variable('FPRFM');
      rcd_lads_mat_mrc.shpro := lics_inbound_utility.get_variable('SHPRO');
      rcd_lads_mat_mrc.fxpru := lics_inbound_utility.get_variable('FXPRU');
      rcd_lads_mat_mrc.kzpsp := lics_inbound_utility.get_variable('KZPSP');
      rcd_lads_mat_mrc.ocmpf := lics_inbound_utility.get_variable('OCMPF');
      rcd_lads_mat_mrc.apokz := lics_inbound_utility.get_variable('APOKZ');
      rcd_lads_mat_mrc.ahdis := lics_inbound_utility.get_variable('AHDIS');
      rcd_lads_mat_mrc.eislo := lics_inbound_utility.get_number('EISLO',null);
      rcd_lads_mat_mrc.ncost := lics_inbound_utility.get_variable('NCOST');
      rcd_lads_mat_mrc.megru := lics_inbound_utility.get_variable('MEGRU');
      rcd_lads_mat_mrc.rotation_date := lics_inbound_utility.get_variable('ROTATION_DATE');
      rcd_lads_mat_mrc.uchkz := lics_inbound_utility.get_variable('UCHKZ');
      rcd_lads_mat_mrc.ucmat := lics_inbound_utility.get_variable('UCMAT');
      rcd_lads_mat_mrc.msgfn1 := lics_inbound_utility.get_variable('MSGFN1');
      rcd_lads_mat_mrc.objty := lics_inbound_utility.get_variable('OBJTY');
      rcd_lads_mat_mrc.objid1 := lics_inbound_utility.get_number('OBJID1',null);
      rcd_lads_mat_mrc.zaehl := lics_inbound_utility.get_number('ZAEHL',null);
      rcd_lads_mat_mrc.objty_v := lics_inbound_utility.get_variable('OBJTY_V');
      rcd_lads_mat_mrc.objid_v := lics_inbound_utility.get_number('OBJID_V',null);
      rcd_lads_mat_mrc.kzkbl := lics_inbound_utility.get_variable('KZKBL');
      rcd_lads_mat_mrc.steuf := lics_inbound_utility.get_variable('STEUF');
      rcd_lads_mat_mrc.steuf_ref := lics_inbound_utility.get_variable('STEUF_REF');
      rcd_lads_mat_mrc.fgru1 := lics_inbound_utility.get_variable('FGRU1');
      rcd_lads_mat_mrc.fgru2 := lics_inbound_utility.get_variable('FGRU2');
      rcd_lads_mat_mrc.planv := lics_inbound_utility.get_variable('PLANV');
      rcd_lads_mat_mrc.ktsch := lics_inbound_utility.get_variable('KTSCH');
      rcd_lads_mat_mrc.ktsch_ref := lics_inbound_utility.get_variable('KTSCH_REF');
      rcd_lads_mat_mrc.bzoffb := lics_inbound_utility.get_variable('BZOFFB');
      rcd_lads_mat_mrc.bzoffb_ref := lics_inbound_utility.get_variable('BZOFFB_REF');
      rcd_lads_mat_mrc.offstb := lics_inbound_utility.get_number('OFFSTB',null);
      rcd_lads_mat_mrc.ehoffb := lics_inbound_utility.get_variable('EHOFFB');
      rcd_lads_mat_mrc.offstb_ref := lics_inbound_utility.get_variable('OFFSTB_REF');
      rcd_lads_mat_mrc.bzoffe := lics_inbound_utility.get_variable('BZOFFE');
      rcd_lads_mat_mrc.bzoffe_ref := lics_inbound_utility.get_variable('BZOFFE_REF');
      rcd_lads_mat_mrc.offste := lics_inbound_utility.get_number('OFFSTE',null);
      rcd_lads_mat_mrc.ehoffe := lics_inbound_utility.get_variable('EHOFFE');
      rcd_lads_mat_mrc.offste_ref := lics_inbound_utility.get_variable('OFFSTE_REF');
      rcd_lads_mat_mrc.mgform := lics_inbound_utility.get_variable('MGFORM');
      rcd_lads_mat_mrc.mgform_ref := lics_inbound_utility.get_variable('MGFORM_REF');
      rcd_lads_mat_mrc.ewform := lics_inbound_utility.get_variable('EWFORM');
      rcd_lads_mat_mrc.ewform_ref := lics_inbound_utility.get_variable('EWFORM_REF');
      rcd_lads_mat_mrc.par01 := lics_inbound_utility.get_variable('PAR01');
      rcd_lads_mat_mrc.par02 := lics_inbound_utility.get_variable('PAR02');
      rcd_lads_mat_mrc.par03 := lics_inbound_utility.get_variable('PAR03');
      rcd_lads_mat_mrc.par04 := lics_inbound_utility.get_variable('PAR04');
      rcd_lads_mat_mrc.par05 := lics_inbound_utility.get_variable('PAR05');
      rcd_lads_mat_mrc.par06 := lics_inbound_utility.get_variable('PAR06');
      rcd_lads_mat_mrc.paru1 := lics_inbound_utility.get_variable('PARU1');
      rcd_lads_mat_mrc.paru2 := lics_inbound_utility.get_variable('PARU2');
      rcd_lads_mat_mrc.paru3 := lics_inbound_utility.get_variable('PARU3');
      rcd_lads_mat_mrc.paru4 := lics_inbound_utility.get_variable('PARU4');
      rcd_lads_mat_mrc.paru5 := lics_inbound_utility.get_variable('PARU5');
      rcd_lads_mat_mrc.paru6 := lics_inbound_utility.get_variable('PARU6');
      rcd_lads_mat_mrc.parv1 := lics_inbound_utility.get_number('PARV1',null);
      rcd_lads_mat_mrc.parv2 := lics_inbound_utility.get_number('PARV2',null);
      rcd_lads_mat_mrc.parv3 := lics_inbound_utility.get_number('PARV3',null);
      rcd_lads_mat_mrc.parv4 := lics_inbound_utility.get_number('PARV4',null);
      rcd_lads_mat_mrc.parv5 := lics_inbound_utility.get_number('PARV5',null);
      rcd_lads_mat_mrc.parv6 := lics_inbound_utility.get_number('PARV6',null);
      rcd_lads_mat_mrc.msgfn2 := lics_inbound_utility.get_variable('MSGFN2');
      rcd_lads_mat_mrc.prgrp := lics_inbound_utility.get_variable('PRGRP');
      rcd_lads_mat_mrc.prwrk := lics_inbound_utility.get_variable('PRWRK');
      rcd_lads_mat_mrc.umref := lics_inbound_utility.get_variable('UMREF');
      rcd_lads_mat_mrc.prgrp_external := lics_inbound_utility.get_variable('PRGRP_EXTERNAL');
      rcd_lads_mat_mrc.prgrp_version := lics_inbound_utility.get_variable('PRGRP_VERSION');
      rcd_lads_mat_mrc.prgrp_guid := lics_inbound_utility.get_variable('PRGRP_GUID');
      rcd_lads_mat_mrc.msgfn3 := lics_inbound_utility.get_variable('MSGFN3');
      rcd_lads_mat_mrc.versp := lics_inbound_utility.get_variable('VERSP');
      rcd_lads_mat_mrc.propr := lics_inbound_utility.get_variable('PROPR');
      rcd_lads_mat_mrc.modaw := lics_inbound_utility.get_variable('MODAW');
      rcd_lads_mat_mrc.modav := lics_inbound_utility.get_variable('MODAV');
      rcd_lads_mat_mrc.kzpar := lics_inbound_utility.get_variable('KZPAR');
      rcd_lads_mat_mrc.opgra := lics_inbound_utility.get_variable('OPGRA');
      rcd_lads_mat_mrc.kzini := lics_inbound_utility.get_variable('KZINI');
      rcd_lads_mat_mrc.prmod := lics_inbound_utility.get_variable('PRMOD');
      rcd_lads_mat_mrc.alpha := lics_inbound_utility.get_number('ALPHA',null);
      rcd_lads_mat_mrc.beta1 := lics_inbound_utility.get_number('BETA1',null);
      rcd_lads_mat_mrc.gamma := lics_inbound_utility.get_number('GAMMA',null);
      rcd_lads_mat_mrc.delta := lics_inbound_utility.get_number('DELTA',null);
      rcd_lads_mat_mrc.epsil := lics_inbound_utility.get_number('EPSIL',null);
      rcd_lads_mat_mrc.siggr := lics_inbound_utility.get_number('SIGGR',null);
      rcd_lads_mat_mrc.perkz1 := lics_inbound_utility.get_variable('PERKZ1');
      rcd_lads_mat_mrc.prdat := lics_inbound_utility.get_variable('PRDAT');
      rcd_lads_mat_mrc.peran := lics_inbound_utility.get_number('PERAN',null);
      rcd_lads_mat_mrc.perin := lics_inbound_utility.get_number('PERIN',null);
      rcd_lads_mat_mrc.perio := lics_inbound_utility.get_number('PERIO',null);
      rcd_lads_mat_mrc.perex := lics_inbound_utility.get_number('PEREX',null);
      rcd_lads_mat_mrc.anzpr := lics_inbound_utility.get_number('ANZPR',null);
      rcd_lads_mat_mrc.fimon := lics_inbound_utility.get_number('FIMON',null);
      rcd_lads_mat_mrc.gwert := lics_inbound_utility.get_number('GWERT',null);
      rcd_lads_mat_mrc.gwer1 := lics_inbound_utility.get_number('GWER1',null);
      rcd_lads_mat_mrc.gwer2 := lics_inbound_utility.get_number('GWER2',null);
      rcd_lads_mat_mrc.vmgwe := lics_inbound_utility.get_number('VMGWE',null);
      rcd_lads_mat_mrc.vmgw1 := lics_inbound_utility.get_number('VMGW1',null);
      rcd_lads_mat_mrc.vmgw2 := lics_inbound_utility.get_number('VMGW2',null);
      rcd_lads_mat_mrc.twert := lics_inbound_utility.get_number('TWERT',null);
      rcd_lads_mat_mrc.vmtwe := lics_inbound_utility.get_number('VMTWE',null);
      rcd_lads_mat_mrc.prmad := lics_inbound_utility.get_number('PRMAD',null);
      rcd_lads_mat_mrc.vmmad := lics_inbound_utility.get_number('VMMAD',null);
      rcd_lads_mat_mrc.fsumm := lics_inbound_utility.get_number('FSUMM',null);
      rcd_lads_mat_mrc.vmfsu := lics_inbound_utility.get_number('VMFSU',null);
      rcd_lads_mat_mrc.gewgr := lics_inbound_utility.get_variable('GEWGR');
      rcd_lads_mat_mrc.thkof := lics_inbound_utility.get_number('THKOF',null);
      rcd_lads_mat_mrc.ausna := lics_inbound_utility.get_variable('AUSNA');
      rcd_lads_mat_mrc.proab := lics_inbound_utility.get_variable('PROAB');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_zmc.zmcseq := 0;
      rcd_lads_mat_mrd.mrdseq := 0;
      rcd_lads_mat_mpm.mpmseq := 0;
      rcd_lads_mat_mvm.mvmseq := 0;
      rcd_lads_mat_mum.mumseq := 0;
      rcd_lads_mat_mpv.mpvseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_mrc.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MRC.MATNR');
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

      insert into lads_mat_mrc
         (matnr,
          mrcseq,
          msgfn,
          werks,
          pstat,
          lvorm,
          bwtty,
          maabc,
          kzkri,
          ekgrp,
          ausme,
          dispr,
          dismm,
          dispo,
          plifz,
          webaz,
          perkz,
          ausss,
          disls,
          beskz,
          sobsl,
          minbe,
          eisbe,
          bstmi,
          bstma,
          bstfe,
          bstrf,
          mabst,
          losfx,
          sbdkz,
          lagpr,
          altsl,
          kzaus,
          ausdt,
          nfmat,
          kzbed,
          miskz,
          fhori,
          pfrei,
          ffrei,
          rgekz,
          fevor,
          bearz,
          ruezt,
          tranz,
          basmg,
          dzeit,
          maxlz,
          lzeih,
          kzpro,
          gpmkz,
          ueeto,
          ueetk,
          uneto,
          wzeit,
          atpkz,
          vzusl,
          herbl,
          insmk,
          ssqss,
          kzdkz,
          umlmc,
          ladgr,
          xchpf,
          usequ,
          lgrad,
          auftl,
          plvar,
          otype,
          objid,
          mtvfp,
          periv,
          kzkfk,
          vrvez,
          vbamg,
          vbeaz,
          lizyk,
          bwscl,
          kautb,
          kordb,
          stawn,
          herkl,
          herkr,
          expme,
          mtver,
          prctr,
          trame,
          mrppp,
          sauft,
          fxhor,
          vrmod,
          vint1,
          vint2,
          stlal,
          stlan,
          plnnr,
          aplal,
          losgr,
          sobsk,
          frtme,
          lgpro,
          disgr,
          kausf,
          qzgtp,
          takzt,
          rwpro,
          copam,
          abcin,
          awsls,
          sernp,
          stdpd,
          sfepr,
          xmcng,
          qssys,
          lfrhy,
          rdprf,
          vrbmt,
          vrbwk,
          vrbdt,
          vrbfk,
          autru,
          prefe,
          prenc,
          preno,
          prend,
          prene,
          preng,
          itark,
          prfrq,
          kzkup,
          strgr,
          lgfsb,
          schgt,
          ccfix,
          eprio,
          qmata,
          plnty,
          mmsta,
          sfcpf,
          shflg,
          shzet,
          mdach,
          kzech,
          mmstd,
          mfrgr,
          fvidk,
          indus,
          mownr,
          mogru,
          casnr,
          gpnum,
          steuc,
          fabkz,
          matgr,
          loggr,
          vspvb,
          dplfs,
          dplpu,
          dplho,
          minls,
          maxls,
          fixls,
          ltinc,
          compl,
          convt,
          fprfm,
          shpro,
          fxpru,
          kzpsp,
          ocmpf,
          apokz,
          ahdis,
          eislo,
          ncost,
          megru,
          rotation_date,
          uchkz,
          ucmat,
          msgfn1,
          objty,
          objid1,
          zaehl,
          objty_v,
          objid_v,
          kzkbl,
          steuf,
          steuf_ref,
          fgru1,
          fgru2,
          planv,
          ktsch,
          ktsch_ref,
          bzoffb,
          bzoffb_ref,
          offstb,
          ehoffb,
          offstb_ref,
          bzoffe,
          bzoffe_ref,
          offste,
          ehoffe,
          offste_ref,
          mgform,
          mgform_ref,
          ewform,
          ewform_ref,
          par01,
          par02,
          par03,
          par04,
          par05,
          par06,
          paru1,
          paru2,
          paru3,
          paru4,
          paru5,
          paru6,
          parv1,
          parv2,
          parv3,
          parv4,
          parv5,
          parv6,
          msgfn2,
          prgrp,
          prwrk,
          umref,
          prgrp_external,
          prgrp_version,
          prgrp_guid,
          msgfn3,
          versp,
          propr,
          modaw,
          modav,
          kzpar,
          opgra,
          kzini,
          prmod,
          alpha,
          beta1,
          gamma,
          delta,
          epsil,
          siggr,
          perkz1,
          prdat,
          peran,
          perin,
          perio,
          perex,
          anzpr,
          fimon,
          gwert,
          gwer1,
          gwer2,
          vmgwe,
          vmgw1,
          vmgw2,
          twert,
          vmtwe,
          prmad,
          vmmad,
          fsumm,
          vmfsu,
          gewgr,
          thkof,
          ausna,
          proab)
      values
         (rcd_lads_mat_mrc.matnr,
          rcd_lads_mat_mrc.mrcseq,
          rcd_lads_mat_mrc.msgfn,
          rcd_lads_mat_mrc.werks,
          rcd_lads_mat_mrc.pstat,
          rcd_lads_mat_mrc.lvorm,
          rcd_lads_mat_mrc.bwtty,
          rcd_lads_mat_mrc.maabc,
          rcd_lads_mat_mrc.kzkri,
          rcd_lads_mat_mrc.ekgrp,
          rcd_lads_mat_mrc.ausme,
          rcd_lads_mat_mrc.dispr,
          rcd_lads_mat_mrc.dismm,
          rcd_lads_mat_mrc.dispo,
          rcd_lads_mat_mrc.plifz,
          rcd_lads_mat_mrc.webaz,
          rcd_lads_mat_mrc.perkz,
          rcd_lads_mat_mrc.ausss,
          rcd_lads_mat_mrc.disls,
          rcd_lads_mat_mrc.beskz,
          rcd_lads_mat_mrc.sobsl,
          rcd_lads_mat_mrc.minbe,
          rcd_lads_mat_mrc.eisbe,
          rcd_lads_mat_mrc.bstmi,
          rcd_lads_mat_mrc.bstma,
          rcd_lads_mat_mrc.bstfe,
          rcd_lads_mat_mrc.bstrf,
          rcd_lads_mat_mrc.mabst,
          rcd_lads_mat_mrc.losfx,
          rcd_lads_mat_mrc.sbdkz,
          rcd_lads_mat_mrc.lagpr,
          rcd_lads_mat_mrc.altsl,
          rcd_lads_mat_mrc.kzaus,
          rcd_lads_mat_mrc.ausdt,
          rcd_lads_mat_mrc.nfmat,
          rcd_lads_mat_mrc.kzbed,
          rcd_lads_mat_mrc.miskz,
          rcd_lads_mat_mrc.fhori,
          rcd_lads_mat_mrc.pfrei,
          rcd_lads_mat_mrc.ffrei,
          rcd_lads_mat_mrc.rgekz,
          rcd_lads_mat_mrc.fevor,
          rcd_lads_mat_mrc.bearz,
          rcd_lads_mat_mrc.ruezt,
          rcd_lads_mat_mrc.tranz,
          rcd_lads_mat_mrc.basmg,
          rcd_lads_mat_mrc.dzeit,
          rcd_lads_mat_mrc.maxlz,
          rcd_lads_mat_mrc.lzeih,
          rcd_lads_mat_mrc.kzpro,
          rcd_lads_mat_mrc.gpmkz,
          rcd_lads_mat_mrc.ueeto,
          rcd_lads_mat_mrc.ueetk,
          rcd_lads_mat_mrc.uneto,
          rcd_lads_mat_mrc.wzeit,
          rcd_lads_mat_mrc.atpkz,
          rcd_lads_mat_mrc.vzusl,
          rcd_lads_mat_mrc.herbl,
          rcd_lads_mat_mrc.insmk,
          rcd_lads_mat_mrc.ssqss,
          rcd_lads_mat_mrc.kzdkz,
          rcd_lads_mat_mrc.umlmc,
          rcd_lads_mat_mrc.ladgr,
          rcd_lads_mat_mrc.xchpf,
          rcd_lads_mat_mrc.usequ,
          rcd_lads_mat_mrc.lgrad,
          rcd_lads_mat_mrc.auftl,
          rcd_lads_mat_mrc.plvar,
          rcd_lads_mat_mrc.otype,
          rcd_lads_mat_mrc.objid,
          rcd_lads_mat_mrc.mtvfp,
          rcd_lads_mat_mrc.periv,
          rcd_lads_mat_mrc.kzkfk,
          rcd_lads_mat_mrc.vrvez,
          rcd_lads_mat_mrc.vbamg,
          rcd_lads_mat_mrc.vbeaz,
          rcd_lads_mat_mrc.lizyk,
          rcd_lads_mat_mrc.bwscl,
          rcd_lads_mat_mrc.kautb,
          rcd_lads_mat_mrc.kordb,
          rcd_lads_mat_mrc.stawn,
          rcd_lads_mat_mrc.herkl,
          rcd_lads_mat_mrc.herkr,
          rcd_lads_mat_mrc.expme,
          rcd_lads_mat_mrc.mtver,
          rcd_lads_mat_mrc.prctr,
          rcd_lads_mat_mrc.trame,
          rcd_lads_mat_mrc.mrppp,
          rcd_lads_mat_mrc.sauft,
          rcd_lads_mat_mrc.fxhor,
          rcd_lads_mat_mrc.vrmod,
          rcd_lads_mat_mrc.vint1,
          rcd_lads_mat_mrc.vint2,
          rcd_lads_mat_mrc.stlal,
          rcd_lads_mat_mrc.stlan,
          rcd_lads_mat_mrc.plnnr,
          rcd_lads_mat_mrc.aplal,
          rcd_lads_mat_mrc.losgr,
          rcd_lads_mat_mrc.sobsk,
          rcd_lads_mat_mrc.frtme,
          rcd_lads_mat_mrc.lgpro,
          rcd_lads_mat_mrc.disgr,
          rcd_lads_mat_mrc.kausf,
          rcd_lads_mat_mrc.qzgtp,
          rcd_lads_mat_mrc.takzt,
          rcd_lads_mat_mrc.rwpro,
          rcd_lads_mat_mrc.copam,
          rcd_lads_mat_mrc.abcin,
          rcd_lads_mat_mrc.awsls,
          rcd_lads_mat_mrc.sernp,
          rcd_lads_mat_mrc.stdpd,
          rcd_lads_mat_mrc.sfepr,
          rcd_lads_mat_mrc.xmcng,
          rcd_lads_mat_mrc.qssys,
          rcd_lads_mat_mrc.lfrhy,
          rcd_lads_mat_mrc.rdprf,
          rcd_lads_mat_mrc.vrbmt,
          rcd_lads_mat_mrc.vrbwk,
          rcd_lads_mat_mrc.vrbdt,
          rcd_lads_mat_mrc.vrbfk,
          rcd_lads_mat_mrc.autru,
          rcd_lads_mat_mrc.prefe,
          rcd_lads_mat_mrc.prenc,
          rcd_lads_mat_mrc.preno,
          rcd_lads_mat_mrc.prend,
          rcd_lads_mat_mrc.prene,
          rcd_lads_mat_mrc.preng,
          rcd_lads_mat_mrc.itark,
          rcd_lads_mat_mrc.prfrq,
          rcd_lads_mat_mrc.kzkup,
          rcd_lads_mat_mrc.strgr,
          rcd_lads_mat_mrc.lgfsb,
          rcd_lads_mat_mrc.schgt,
          rcd_lads_mat_mrc.ccfix,
          rcd_lads_mat_mrc.eprio,
          rcd_lads_mat_mrc.qmata,
          rcd_lads_mat_mrc.plnty,
          rcd_lads_mat_mrc.mmsta,
          rcd_lads_mat_mrc.sfcpf,
          rcd_lads_mat_mrc.shflg,
          rcd_lads_mat_mrc.shzet,
          rcd_lads_mat_mrc.mdach,
          rcd_lads_mat_mrc.kzech,
          rcd_lads_mat_mrc.mmstd,
          rcd_lads_mat_mrc.mfrgr,
          rcd_lads_mat_mrc.fvidk,
          rcd_lads_mat_mrc.indus,
          rcd_lads_mat_mrc.mownr,
          rcd_lads_mat_mrc.mogru,
          rcd_lads_mat_mrc.casnr,
          rcd_lads_mat_mrc.gpnum,
          rcd_lads_mat_mrc.steuc,
          rcd_lads_mat_mrc.fabkz,
          rcd_lads_mat_mrc.matgr,
          rcd_lads_mat_mrc.loggr,
          rcd_lads_mat_mrc.vspvb,
          rcd_lads_mat_mrc.dplfs,
          rcd_lads_mat_mrc.dplpu,
          rcd_lads_mat_mrc.dplho,
          rcd_lads_mat_mrc.minls,
          rcd_lads_mat_mrc.maxls,
          rcd_lads_mat_mrc.fixls,
          rcd_lads_mat_mrc.ltinc,
          rcd_lads_mat_mrc.compl,
          rcd_lads_mat_mrc.convt,
          rcd_lads_mat_mrc.fprfm,
          rcd_lads_mat_mrc.shpro,
          rcd_lads_mat_mrc.fxpru,
          rcd_lads_mat_mrc.kzpsp,
          rcd_lads_mat_mrc.ocmpf,
          rcd_lads_mat_mrc.apokz,
          rcd_lads_mat_mrc.ahdis,
          rcd_lads_mat_mrc.eislo,
          rcd_lads_mat_mrc.ncost,
          rcd_lads_mat_mrc.megru,
          rcd_lads_mat_mrc.rotation_date,
          rcd_lads_mat_mrc.uchkz,
          rcd_lads_mat_mrc.ucmat,
          rcd_lads_mat_mrc.msgfn1,
          rcd_lads_mat_mrc.objty,
          rcd_lads_mat_mrc.objid1,
          rcd_lads_mat_mrc.zaehl,
          rcd_lads_mat_mrc.objty_v,
          rcd_lads_mat_mrc.objid_v,
          rcd_lads_mat_mrc.kzkbl,
          rcd_lads_mat_mrc.steuf,
          rcd_lads_mat_mrc.steuf_ref,
          rcd_lads_mat_mrc.fgru1,
          rcd_lads_mat_mrc.fgru2,
          rcd_lads_mat_mrc.planv,
          rcd_lads_mat_mrc.ktsch,
          rcd_lads_mat_mrc.ktsch_ref,
          rcd_lads_mat_mrc.bzoffb,
          rcd_lads_mat_mrc.bzoffb_ref,
          rcd_lads_mat_mrc.offstb,
          rcd_lads_mat_mrc.ehoffb,
          rcd_lads_mat_mrc.offstb_ref,
          rcd_lads_mat_mrc.bzoffe,
          rcd_lads_mat_mrc.bzoffe_ref,
          rcd_lads_mat_mrc.offste,
          rcd_lads_mat_mrc.ehoffe,
          rcd_lads_mat_mrc.offste_ref,
          rcd_lads_mat_mrc.mgform,
          rcd_lads_mat_mrc.mgform_ref,
          rcd_lads_mat_mrc.ewform,
          rcd_lads_mat_mrc.ewform_ref,
          rcd_lads_mat_mrc.par01,
          rcd_lads_mat_mrc.par02,
          rcd_lads_mat_mrc.par03,
          rcd_lads_mat_mrc.par04,
          rcd_lads_mat_mrc.par05,
          rcd_lads_mat_mrc.par06,
          rcd_lads_mat_mrc.paru1,
          rcd_lads_mat_mrc.paru2,
          rcd_lads_mat_mrc.paru3,
          rcd_lads_mat_mrc.paru4,
          rcd_lads_mat_mrc.paru5,
          rcd_lads_mat_mrc.paru6,
          rcd_lads_mat_mrc.parv1,
          rcd_lads_mat_mrc.parv2,
          rcd_lads_mat_mrc.parv3,
          rcd_lads_mat_mrc.parv4,
          rcd_lads_mat_mrc.parv5,
          rcd_lads_mat_mrc.parv6,
          rcd_lads_mat_mrc.msgfn2,
          rcd_lads_mat_mrc.prgrp,
          rcd_lads_mat_mrc.prwrk,
          rcd_lads_mat_mrc.umref,
          rcd_lads_mat_mrc.prgrp_external,
          rcd_lads_mat_mrc.prgrp_version,
          rcd_lads_mat_mrc.prgrp_guid,
          rcd_lads_mat_mrc.msgfn3,
          rcd_lads_mat_mrc.versp,
          rcd_lads_mat_mrc.propr,
          rcd_lads_mat_mrc.modaw,
          rcd_lads_mat_mrc.modav,
          rcd_lads_mat_mrc.kzpar,
          rcd_lads_mat_mrc.opgra,
          rcd_lads_mat_mrc.kzini,
          rcd_lads_mat_mrc.prmod,
          rcd_lads_mat_mrc.alpha,
          rcd_lads_mat_mrc.beta1,
          rcd_lads_mat_mrc.gamma,
          rcd_lads_mat_mrc.delta,
          rcd_lads_mat_mrc.epsil,
          rcd_lads_mat_mrc.siggr,
          rcd_lads_mat_mrc.perkz1,
          rcd_lads_mat_mrc.prdat,
          rcd_lads_mat_mrc.peran,
          rcd_lads_mat_mrc.perin,
          rcd_lads_mat_mrc.perio,
          rcd_lads_mat_mrc.perex,
          rcd_lads_mat_mrc.anzpr,
          rcd_lads_mat_mrc.fimon,
          rcd_lads_mat_mrc.gwert,
          rcd_lads_mat_mrc.gwer1,
          rcd_lads_mat_mrc.gwer2,
          rcd_lads_mat_mrc.vmgwe,
          rcd_lads_mat_mrc.vmgw1,
          rcd_lads_mat_mrc.vmgw2,
          rcd_lads_mat_mrc.twert,
          rcd_lads_mat_mrc.vmtwe,
          rcd_lads_mat_mrc.prmad,
          rcd_lads_mat_mrc.vmmad,
          rcd_lads_mat_mrc.fsumm,
          rcd_lads_mat_mrc.vmfsu,
          rcd_lads_mat_mrc.gewgr,
          rcd_lads_mat_mrc.thkof,
          rcd_lads_mat_mrc.ausna,
          rcd_lads_mat_mrc.proab);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mrc;

   /**************************************************/
   /* This procedure performs the record ZMC routine */
   /**************************************************/
   procedure process_record_zmc(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ZMC', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_zmc.matnr := rcd_lads_mat_mrc.matnr;
      rcd_lads_mat_zmc.mrcseq := rcd_lads_mat_mrc.mrcseq;
      rcd_lads_mat_zmc.zmcseq := rcd_lads_mat_zmc.zmcseq + 1;
      rcd_lads_mat_zmc.zzmtart := lics_inbound_utility.get_number('ZZMTART',null);
      rcd_lads_mat_zmc.zzmattim_pl := lics_inbound_utility.get_number('ZZMATTIM_PL',null);
      rcd_lads_mat_zmc.zzfppsmoe := lics_inbound_utility.get_variable('ZZFPPSMOE');

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
      if rcd_lads_mat_zmc.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ZMC.MATNR');
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

      insert into lads_mat_zmc
         (matnr,
          mrcseq,
          zmcseq,
          zzmtart,
          zzmattim_pl,
          zzfppsmoe)
      values
         (rcd_lads_mat_zmc.matnr,
          rcd_lads_mat_zmc.mrcseq,
          rcd_lads_mat_zmc.zmcseq,
          rcd_lads_mat_zmc.zzmtart,
          rcd_lads_mat_zmc.zzmattim_pl,
          rcd_lads_mat_zmc.zzfppsmoe);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_zmc;

   /**************************************************/
   /* This procedure performs the record MRD routine */
   /**************************************************/
   procedure process_record_mrd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MRD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mrd.matnr := rcd_lads_mat_mrc.matnr;
      rcd_lads_mat_mrd.mrcseq := rcd_lads_mat_mrc.mrcseq;
      rcd_lads_mat_mrd.mrdseq := rcd_lads_mat_mrd.mrdseq + 1;
      rcd_lads_mat_mrd.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mrd.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_mat_mrd.pstat := lics_inbound_utility.get_variable('PSTAT');
      rcd_lads_mat_mrd.lvorm := lics_inbound_utility.get_variable('LVORM');
      rcd_lads_mat_mrd.diskz := lics_inbound_utility.get_variable('DISKZ');
      rcd_lads_mat_mrd.lsobs := lics_inbound_utility.get_variable('LSOBS');
      rcd_lads_mat_mrd.lminb := lics_inbound_utility.get_number('LMINB',null);
      rcd_lads_mat_mrd.lbstf := lics_inbound_utility.get_number('LBSTF',null);
      rcd_lads_mat_mrd.herkl := lics_inbound_utility.get_variable('HERKL');
      rcd_lads_mat_mrd.exppg := lics_inbound_utility.get_variable('EXPPG');
      rcd_lads_mat_mrd.exver := lics_inbound_utility.get_variable('EXVER');
      rcd_lads_mat_mrd.lgpbe := lics_inbound_utility.get_variable('LGPBE');
      rcd_lads_mat_mrd.prctl := lics_inbound_utility.get_variable('PRCTL');
      rcd_lads_mat_mrd.lwmkb := lics_inbound_utility.get_variable('LWMKB');
      rcd_lads_mat_mrd.bskrf := lics_inbound_utility.get_number('BSKRF',null);

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
      if rcd_lads_mat_mrd.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MRD.MATNR');
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

      insert into lads_mat_mrd
         (matnr,
          mrcseq,
          mrdseq,
          msgfn,
          lgort,
          pstat,
          lvorm,
          diskz,
          lsobs,
          lminb,
          lbstf,
          herkl,
          exppg,
          exver,
          lgpbe,
          prctl,
          lwmkb,
          bskrf)
      values
         (rcd_lads_mat_mrd.matnr,
          rcd_lads_mat_mrd.mrcseq,
          rcd_lads_mat_mrd.mrdseq,
          rcd_lads_mat_mrd.msgfn,
          rcd_lads_mat_mrd.lgort,
          rcd_lads_mat_mrd.pstat,
          rcd_lads_mat_mrd.lvorm,
          rcd_lads_mat_mrd.diskz,
          rcd_lads_mat_mrd.lsobs,
          rcd_lads_mat_mrd.lminb,
          rcd_lads_mat_mrd.lbstf,
          rcd_lads_mat_mrd.herkl,
          rcd_lads_mat_mrd.exppg,
          rcd_lads_mat_mrd.exver,
          rcd_lads_mat_mrd.lgpbe,
          rcd_lads_mat_mrd.prctl,
          rcd_lads_mat_mrd.lwmkb,
          rcd_lads_mat_mrd.bskrf);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mrd;

   /**************************************************/
   /* This procedure performs the record MPM routine */
   /**************************************************/
   procedure process_record_mpm(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MPM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mpm.matnr := rcd_lads_mat_mrc.matnr;
      rcd_lads_mat_mpm.mrcseq := rcd_lads_mat_mrc.mrcseq;
      rcd_lads_mat_mpm.mpmseq := rcd_lads_mat_mpm.mpmseq + 1;
      rcd_lads_mat_mpm.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mpm.ertag := lics_inbound_utility.get_variable('ERTAG');
      rcd_lads_mat_mpm.prwrt := lics_inbound_utility.get_number('PRWRT',null);
      rcd_lads_mat_mpm.koprw := lics_inbound_utility.get_number('KOPRW',null);
      rcd_lads_mat_mpm.saiin := lics_inbound_utility.get_number('SAIIN',null);
      rcd_lads_mat_mpm.fixkz := lics_inbound_utility.get_variable('FIXKZ');
      rcd_lads_mat_mpm.exprw := lics_inbound_utility.get_number('EXPRW',null);
      rcd_lads_mat_mpm.antei := lics_inbound_utility.get_number('ANTEI',null);

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
      if rcd_lads_mat_mpm.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MPM.MATNR');
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

      insert into lads_mat_mpm
         (matnr,
          mrcseq,
          mpmseq,
          msgfn,
          ertag,
          prwrt,
          koprw,
          saiin,
          fixkz,
          exprw,
          antei)
      values
         (rcd_lads_mat_mpm.matnr,
          rcd_lads_mat_mpm.mrcseq,
          rcd_lads_mat_mpm.mpmseq,
          rcd_lads_mat_mpm.msgfn,
          rcd_lads_mat_mpm.ertag,
          rcd_lads_mat_mpm.prwrt,
          rcd_lads_mat_mpm.koprw,
          rcd_lads_mat_mpm.saiin,
          rcd_lads_mat_mpm.fixkz,
          rcd_lads_mat_mpm.exprw,
          rcd_lads_mat_mpm.antei);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mpm;

   /**************************************************/
   /* This procedure performs the record MVM routine */
   /**************************************************/
   procedure process_record_mvm(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MVM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mvm.matnr := rcd_lads_mat_mrc.matnr;
      rcd_lads_mat_mvm.mrcseq := rcd_lads_mat_mrc.mrcseq;
      rcd_lads_mat_mvm.mvmseq := rcd_lads_mat_mvm.mvmseq + 1;
      rcd_lads_mat_mvm.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mvm.ertag := lics_inbound_utility.get_variable('ERTAG');
      rcd_lads_mat_mvm.vbwrt := lics_inbound_utility.get_number('VBWRT',null);
      rcd_lads_mat_mvm.kovbw := lics_inbound_utility.get_number('KOVBW',null);
      rcd_lads_mat_mvm.kzexi := lics_inbound_utility.get_variable('KZEXI');
      rcd_lads_mat_mvm.antei := lics_inbound_utility.get_number('ANTEI',null);

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
      if rcd_lads_mat_mvm.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MVM.MATNR');
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

      insert into lads_mat_mvm
         (matnr,
          mrcseq,
          mvmseq,
          msgfn,
          ertag,
          vbwrt,
          kovbw,
          kzexi,
          antei)
      values
         (rcd_lads_mat_mvm.matnr,
          rcd_lads_mat_mvm.mrcseq,
          rcd_lads_mat_mvm.mvmseq,
          rcd_lads_mat_mvm.msgfn,
          rcd_lads_mat_mvm.ertag,
          rcd_lads_mat_mvm.vbwrt,
          rcd_lads_mat_mvm.kovbw,
          rcd_lads_mat_mvm.kzexi,
          rcd_lads_mat_mvm.antei);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mvm;

   /**************************************************/
   /* This procedure performs the record MUM routine */
   /**************************************************/
   procedure process_record_mum(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MUM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mum.matnr := rcd_lads_mat_mrc.matnr;
      rcd_lads_mat_mum.mrcseq := rcd_lads_mat_mrc.mrcseq;
      rcd_lads_mat_mum.mumseq := rcd_lads_mat_mum.mumseq + 1;
      rcd_lads_mat_mum.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mum.ertag := lics_inbound_utility.get_variable('ERTAG');
      rcd_lads_mat_mum.vbwrt := lics_inbound_utility.get_number('VBWRT',null);
      rcd_lads_mat_mum.kovbw := lics_inbound_utility.get_number('KOVBW',null);
      rcd_lads_mat_mum.kzexi := lics_inbound_utility.get_variable('KZEXI');
      rcd_lads_mat_mum.antei := lics_inbound_utility.get_number('ANTEI',null);

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
      if rcd_lads_mat_mum.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MUM.MATNR');
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

      insert into lads_mat_mum
         (matnr,
          mrcseq,
          mumseq,
          msgfn,
          ertag,
          vbwrt,
          kovbw,
          kzexi,
          antei)
      values
         (rcd_lads_mat_mum.matnr,
          rcd_lads_mat_mum.mrcseq,
          rcd_lads_mat_mum.mumseq,
          rcd_lads_mat_mum.msgfn,
          rcd_lads_mat_mum.ertag,
          rcd_lads_mat_mum.vbwrt,
          rcd_lads_mat_mum.kovbw,
          rcd_lads_mat_mum.kzexi,
          rcd_lads_mat_mum.antei);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mum;

   /**************************************************/
   /* This procedure performs the record MPV routine */
   /**************************************************/
   procedure process_record_mpv(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MPV', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mpv.matnr := rcd_lads_mat_mrc.matnr;
      rcd_lads_mat_mpv.mrcseq := rcd_lads_mat_mrc.mrcseq;
      rcd_lads_mat_mpv.mpvseq := rcd_lads_mat_mpv.mpvseq + 1;
      rcd_lads_mat_mpv.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mpv.verid := lics_inbound_utility.get_variable('VERID');
      rcd_lads_mat_mpv.bdatu := lics_inbound_utility.get_variable('BDATU');
      rcd_lads_mat_mpv.adatu := lics_inbound_utility.get_variable('ADATU');
      rcd_lads_mat_mpv.stlal := lics_inbound_utility.get_variable('STLAL');
      rcd_lads_mat_mpv.stlan := lics_inbound_utility.get_variable('STLAN');
      rcd_lads_mat_mpv.plnty := lics_inbound_utility.get_variable('PLNTY');
      rcd_lads_mat_mpv.plnnr := lics_inbound_utility.get_variable('PLNNR');
      rcd_lads_mat_mpv.alnal := lics_inbound_utility.get_variable('ALNAL');
      rcd_lads_mat_mpv.beskz := lics_inbound_utility.get_variable('BESKZ');
      rcd_lads_mat_mpv.sobsl := lics_inbound_utility.get_variable('SOBSL');
      rcd_lads_mat_mpv.losgr := lics_inbound_utility.get_number('LOSGR',null);
      rcd_lads_mat_mpv.mdv01 := lics_inbound_utility.get_variable('MDV01');
      rcd_lads_mat_mpv.mdv02 := lics_inbound_utility.get_variable('MDV02');
      rcd_lads_mat_mpv.text1 := lics_inbound_utility.get_variable('TEXT1');
      rcd_lads_mat_mpv.ewahr := lics_inbound_utility.get_number('EWAHR',null);
      rcd_lads_mat_mpv.verto := lics_inbound_utility.get_variable('VERTO');
      rcd_lads_mat_mpv.serkz := lics_inbound_utility.get_variable('SERKZ');
      rcd_lads_mat_mpv.bstmi := lics_inbound_utility.get_number('BSTMI',null);
      rcd_lads_mat_mpv.bstma := lics_inbound_utility.get_number('BSTMA',null);
      rcd_lads_mat_mpv.rgekz := lics_inbound_utility.get_variable('RGEKZ');
      rcd_lads_mat_mpv.alort := lics_inbound_utility.get_variable('ALORT');
      rcd_lads_mat_mpv.pltyg := lics_inbound_utility.get_variable('PLTYG');
      rcd_lads_mat_mpv.plnng := lics_inbound_utility.get_variable('PLNNG');
      rcd_lads_mat_mpv.alnag := lics_inbound_utility.get_variable('ALNAG');
      rcd_lads_mat_mpv.pltym := lics_inbound_utility.get_variable('PLTYM');
      rcd_lads_mat_mpv.plnnm := lics_inbound_utility.get_variable('PLNNM');
      rcd_lads_mat_mpv.alnam := lics_inbound_utility.get_variable('ALNAM');
      rcd_lads_mat_mpv.csplt := lics_inbound_utility.get_variable('CSPLT');
      rcd_lads_mat_mpv.matko := lics_inbound_utility.get_variable('MATKO');
      rcd_lads_mat_mpv.elpro := lics_inbound_utility.get_variable('ELPRO');
      rcd_lads_mat_mpv.prvbe := lics_inbound_utility.get_variable('PRVBE');
      rcd_lads_mat_mpv.matko_external := lics_inbound_utility.get_variable('MATKO_EXTERNAL');
      rcd_lads_mat_mpv.matko_version := lics_inbound_utility.get_variable('MATKO_VERSION');
      rcd_lads_mat_mpv.matko_guid := lics_inbound_utility.get_variable('MATKO_GUID');

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
      if rcd_lads_mat_mpv.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MPV.MATNR');
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

      insert into lads_mat_mpv
         (matnr,
          mrcseq,
          mpvseq,
          msgfn,
          verid,
          bdatu,
          adatu,
          stlal,
          stlan,
          plnty,
          plnnr,
          alnal,
          beskz,
          sobsl,
          losgr,
          mdv01,
          mdv02,
          text1,
          ewahr,
          verto,
          serkz,
          bstmi,
          bstma,
          rgekz,
          alort,
          pltyg,
          plnng,
          alnag,
          pltym,
          plnnm,
          alnam,
          csplt,
          matko,
          elpro,
          prvbe,
          matko_external,
          matko_version,
          matko_guid)
      values
         (rcd_lads_mat_mpv.matnr,
          rcd_lads_mat_mpv.mrcseq,
          rcd_lads_mat_mpv.mpvseq,
          rcd_lads_mat_mpv.msgfn,
          rcd_lads_mat_mpv.verid,
          rcd_lads_mat_mpv.bdatu,
          rcd_lads_mat_mpv.adatu,
          rcd_lads_mat_mpv.stlal,
          rcd_lads_mat_mpv.stlan,
          rcd_lads_mat_mpv.plnty,
          rcd_lads_mat_mpv.plnnr,
          rcd_lads_mat_mpv.alnal,
          rcd_lads_mat_mpv.beskz,
          rcd_lads_mat_mpv.sobsl,
          rcd_lads_mat_mpv.losgr,
          rcd_lads_mat_mpv.mdv01,
          rcd_lads_mat_mpv.mdv02,
          rcd_lads_mat_mpv.text1,
          rcd_lads_mat_mpv.ewahr,
          rcd_lads_mat_mpv.verto,
          rcd_lads_mat_mpv.serkz,
          rcd_lads_mat_mpv.bstmi,
          rcd_lads_mat_mpv.bstma,
          rcd_lads_mat_mpv.rgekz,
          rcd_lads_mat_mpv.alort,
          rcd_lads_mat_mpv.pltyg,
          rcd_lads_mat_mpv.plnng,
          rcd_lads_mat_mpv.alnag,
          rcd_lads_mat_mpv.pltym,
          rcd_lads_mat_mpv.plnnm,
          rcd_lads_mat_mpv.alnam,
          rcd_lads_mat_mpv.csplt,
          rcd_lads_mat_mpv.matko,
          rcd_lads_mat_mpv.elpro,
          rcd_lads_mat_mpv.prvbe,
          rcd_lads_mat_mpv.matko_external,
          rcd_lads_mat_mpv.matko_version,
          rcd_lads_mat_mpv.matko_guid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mpv;

   /**************************************************/
   /* This procedure performs the record UOM routine */
   /**************************************************/
   procedure process_record_uom(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('UOM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_uom.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_uom.uomseq := rcd_lads_mat_uom.uomseq + 1;
      rcd_lads_mat_uom.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_uom.meinh := lics_inbound_utility.get_variable('MEINH');
      rcd_lads_mat_uom.umrez := lics_inbound_utility.get_number('UMREZ',null);
      rcd_lads_mat_uom.umren := lics_inbound_utility.get_number('UMREN',null);
      rcd_lads_mat_uom.ean11 := lics_inbound_utility.get_variable('EAN11');
      rcd_lads_mat_uom.numtp := lics_inbound_utility.get_variable('NUMTP');
      rcd_lads_mat_uom.laeng := lics_inbound_utility.get_number('LAENG',null);
      rcd_lads_mat_uom.breit := lics_inbound_utility.get_number('BREIT',null);
      rcd_lads_mat_uom.hoehe := lics_inbound_utility.get_number('HOEHE',null);
      rcd_lads_mat_uom.meabm := lics_inbound_utility.get_variable('MEABM');
      rcd_lads_mat_uom.volum := lics_inbound_utility.get_number('VOLUM',null);
      rcd_lads_mat_uom.voleh := lics_inbound_utility.get_variable('VOLEH');
      rcd_lads_mat_uom.brgew := lics_inbound_utility.get_number('BRGEW',null);
      rcd_lads_mat_uom.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_mat_uom.mesub := lics_inbound_utility.get_variable('MESUB');
      rcd_lads_mat_uom.gtin_variant := lics_inbound_utility.get_variable('GTIN_VARIANT');
      rcd_lads_mat_uom.zzmultitdu := lics_inbound_utility.get_variable('ZZMULTITDU');
      rcd_lads_mat_uom.zzpcitem := lics_inbound_utility.get_variable('ZZPCITEM');
      rcd_lads_mat_uom.zzpclevel := lics_inbound_utility.get_number('ZZPCLEVEL',null);
      rcd_lads_mat_uom.zzpreforder := lics_inbound_utility.get_variable('ZZPREFORDER');
      rcd_lads_mat_uom.zzprefsales := lics_inbound_utility.get_variable('ZZPREFSALES');
      rcd_lads_mat_uom.zzprefissue := lics_inbound_utility.get_variable('ZZPREFISSUE');
      rcd_lads_mat_uom.zzprefwm := lics_inbound_utility.get_variable('ZZPREFWM');
      rcd_lads_mat_uom.zzrefmatnr := lics_inbound_utility.get_variable('ZZREFMATNR');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_uoe.uoeseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_uom.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - UOM.MATNR');
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

      insert into lads_mat_uom
         (matnr,
          uomseq,
          msgfn,
          meinh,
          umrez,
          umren,
          ean11,
          numtp,
          laeng,
          breit,
          hoehe,
          meabm,
          volum,
          voleh,
          brgew,
          gewei,
          mesub,
          gtin_variant,
          zzmultitdu,
          zzpcitem,
          zzpclevel,
          zzpreforder,
          zzprefsales,
          zzprefissue,
          zzprefwm,
          zzrefmatnr)
      values
         (rcd_lads_mat_uom.matnr,
          rcd_lads_mat_uom.uomseq,
          rcd_lads_mat_uom.msgfn,
          rcd_lads_mat_uom.meinh,
          rcd_lads_mat_uom.umrez,
          rcd_lads_mat_uom.umren,
          rcd_lads_mat_uom.ean11,
          rcd_lads_mat_uom.numtp,
          rcd_lads_mat_uom.laeng,
          rcd_lads_mat_uom.breit,
          rcd_lads_mat_uom.hoehe,
          rcd_lads_mat_uom.meabm,
          rcd_lads_mat_uom.volum,
          rcd_lads_mat_uom.voleh,
          rcd_lads_mat_uom.brgew,
          rcd_lads_mat_uom.gewei,
          rcd_lads_mat_uom.mesub,
          rcd_lads_mat_uom.gtin_variant,
          rcd_lads_mat_uom.zzmultitdu,
          rcd_lads_mat_uom.zzpcitem,
          rcd_lads_mat_uom.zzpclevel,
          rcd_lads_mat_uom.zzpreforder,
          rcd_lads_mat_uom.zzprefsales,
          rcd_lads_mat_uom.zzprefissue,
          rcd_lads_mat_uom.zzprefwm,
          rcd_lads_mat_uom.zzrefmatnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_uom;

   /**************************************************/
   /* This procedure performs the record UOE routine */
   /**************************************************/
   procedure process_record_uoe(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('UOE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_uoe.matnr := rcd_lads_mat_uom.matnr;
      rcd_lads_mat_uoe.uomseq := rcd_lads_mat_uom.uomseq;
      rcd_lads_mat_uoe.uoeseq := rcd_lads_mat_uoe.uoeseq + 1;
      rcd_lads_mat_uoe.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_uoe.meinh := lics_inbound_utility.get_variable('MEINH');
      rcd_lads_mat_uoe.lfnum := lics_inbound_utility.get_variable('LFNUM');
      rcd_lads_mat_uoe.ean11 := lics_inbound_utility.get_variable('EAN11');
      rcd_lads_mat_uoe.eantp := lics_inbound_utility.get_variable('EANTP');
      rcd_lads_mat_uoe.hpean := lics_inbound_utility.get_variable('HPEAN');

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
      if rcd_lads_mat_uoe.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - UOE.MATNR');
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

      insert into lads_mat_uoe
         (matnr,
          uomseq,
          uoeseq,
          msgfn,
          meinh,
          lfnum,
          ean11,
          eantp,
          hpean)
      values
         (rcd_lads_mat_uoe.matnr,
          rcd_lads_mat_uoe.uomseq,
          rcd_lads_mat_uoe.uoeseq,
          rcd_lads_mat_uoe.msgfn,
          rcd_lads_mat_uoe.meinh,
          rcd_lads_mat_uoe.lfnum,
          rcd_lads_mat_uoe.ean11,
          rcd_lads_mat_uoe.eantp,
          rcd_lads_mat_uoe.hpean);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_uoe;

   /**************************************************/
   /* This procedure performs the record MBE routine */
   /**************************************************/
   procedure process_record_mbe(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MBE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mbe.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_mbe.mbeseq := rcd_lads_mat_mbe.mbeseq + 1;
      rcd_lads_mat_mbe.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mbe.bwkey := lics_inbound_utility.get_variable('BWKEY');
      rcd_lads_mat_mbe.bwtar := lics_inbound_utility.get_variable('BWTAR');
      rcd_lads_mat_mbe.lvorm := lics_inbound_utility.get_variable('LVORM');
      rcd_lads_mat_mbe.vprsv := lics_inbound_utility.get_variable('VPRSV');
      rcd_lads_mat_mbe.verpr := lics_inbound_utility.get_number('VERPR',null);
      rcd_lads_mat_mbe.stprs := lics_inbound_utility.get_number('STPRS',null);
      rcd_lads_mat_mbe.peinh := lics_inbound_utility.get_number('PEINH',null);
      rcd_lads_mat_mbe.bklas := lics_inbound_utility.get_variable('BKLAS');
      rcd_lads_mat_mbe.vmvpr := lics_inbound_utility.get_variable('VMVPR');
      rcd_lads_mat_mbe.vmver := lics_inbound_utility.get_number('VMVER',null);
      rcd_lads_mat_mbe.vmstp := lics_inbound_utility.get_number('VMSTP',null);
      rcd_lads_mat_mbe.vmpei := lics_inbound_utility.get_number('VMPEI',null);
      rcd_lads_mat_mbe.vmbkl := lics_inbound_utility.get_variable('VMBKL');
      rcd_lads_mat_mbe.vjvpr := lics_inbound_utility.get_variable('VJVPR');
      rcd_lads_mat_mbe.vjver := lics_inbound_utility.get_number('VJVER',null);
      rcd_lads_mat_mbe.vjstp := lics_inbound_utility.get_number('VJSTP',null);
      rcd_lads_mat_mbe.lfgja := lics_inbound_utility.get_number('LFGJA',null);
      rcd_lads_mat_mbe.lfmon := lics_inbound_utility.get_number('LFMON',null);
      rcd_lads_mat_mbe.bwtty := lics_inbound_utility.get_variable('BWTTY');
      rcd_lads_mat_mbe.zkprs := lics_inbound_utility.get_number('ZKPRS',null);
      rcd_lads_mat_mbe.zkdat := lics_inbound_utility.get_variable('ZKDAT');
      rcd_lads_mat_mbe.bwprs := lics_inbound_utility.get_number('BWPRS',null);
      rcd_lads_mat_mbe.bwprh := lics_inbound_utility.get_number('BWPRH',null);
      rcd_lads_mat_mbe.vjbws := lics_inbound_utility.get_number('VJBWS',null);
      rcd_lads_mat_mbe.vjbwh := lics_inbound_utility.get_number('VJBWH',null);
      rcd_lads_mat_mbe.vvjlb := lics_inbound_utility.get_number('VVJLB',null);
      rcd_lads_mat_mbe.vvmlb := lics_inbound_utility.get_number('VVMLB',null);
      rcd_lads_mat_mbe.vvsal := lics_inbound_utility.get_number('VVSAL',null);
      rcd_lads_mat_mbe.zplpr := lics_inbound_utility.get_number('ZPLPR',null);
      rcd_lads_mat_mbe.zplp1 := lics_inbound_utility.get_number('ZPLP1',null);
      rcd_lads_mat_mbe.zplp2 := lics_inbound_utility.get_number('ZPLP2',null);
      rcd_lads_mat_mbe.zplp3 := lics_inbound_utility.get_number('ZPLP3',null);
      rcd_lads_mat_mbe.zpld1 := lics_inbound_utility.get_variable('ZPLD1');
      rcd_lads_mat_mbe.zpld2 := lics_inbound_utility.get_variable('ZPLD2');
      rcd_lads_mat_mbe.zpld3 := lics_inbound_utility.get_variable('ZPLD3');
      rcd_lads_mat_mbe.kalkz := lics_inbound_utility.get_variable('KALKZ');
      rcd_lads_mat_mbe.kalkl := lics_inbound_utility.get_variable('KALKL');
      rcd_lads_mat_mbe.xlifo := lics_inbound_utility.get_variable('XLIFO');
      rcd_lads_mat_mbe.mypol := lics_inbound_utility.get_variable('MYPOL');
      rcd_lads_mat_mbe.bwph1 := lics_inbound_utility.get_number('BWPH1',null);
      rcd_lads_mat_mbe.bwps1 := lics_inbound_utility.get_number('BWPS1',null);
      rcd_lads_mat_mbe.abwkz := lics_inbound_utility.get_number('ABWKZ',null);
      rcd_lads_mat_mbe.pstat := lics_inbound_utility.get_variable('PSTAT');
      rcd_lads_mat_mbe.kaln1 := lics_inbound_utility.get_number('KALN1',null);
      rcd_lads_mat_mbe.kalnr := lics_inbound_utility.get_number('KALNR',null);
      rcd_lads_mat_mbe.bwva1 := lics_inbound_utility.get_variable('BWVA1');
      rcd_lads_mat_mbe.bwva2 := lics_inbound_utility.get_variable('BWVA2');
      rcd_lads_mat_mbe.bwva3 := lics_inbound_utility.get_variable('BWVA3');
      rcd_lads_mat_mbe.vers1 := lics_inbound_utility.get_number('VERS1',null);
      rcd_lads_mat_mbe.vers2 := lics_inbound_utility.get_number('VERS2',null);
      rcd_lads_mat_mbe.vers3 := lics_inbound_utility.get_number('VERS3',null);
      rcd_lads_mat_mbe.hrkft := lics_inbound_utility.get_variable('HRKFT');
      rcd_lads_mat_mbe.kosgr := lics_inbound_utility.get_variable('KOSGR');
      rcd_lads_mat_mbe.pprdz := lics_inbound_utility.get_number('PPRDZ',null);
      rcd_lads_mat_mbe.pprdl := lics_inbound_utility.get_number('PPRDL',null);
      rcd_lads_mat_mbe.pprdv := lics_inbound_utility.get_number('PPRDV',null);
      rcd_lads_mat_mbe.pdatz := lics_inbound_utility.get_number('PDATZ',null);
      rcd_lads_mat_mbe.pdatl := lics_inbound_utility.get_number('PDATL',null);
      rcd_lads_mat_mbe.pdatv := lics_inbound_utility.get_number('PDATV',null);
      rcd_lads_mat_mbe.ekalr := lics_inbound_utility.get_variable('EKALR');
      rcd_lads_mat_mbe.vplpr := lics_inbound_utility.get_number('VPLPR',null);
      rcd_lads_mat_mbe.mlmaa := lics_inbound_utility.get_variable('MLMAA');
      rcd_lads_mat_mbe.mlast := lics_inbound_utility.get_variable('MLAST');
      rcd_lads_mat_mbe.vjbkl := lics_inbound_utility.get_variable('VJBKL');
      rcd_lads_mat_mbe.vjpei := lics_inbound_utility.get_number('VJPEI',null);
      rcd_lads_mat_mbe.hkmat := lics_inbound_utility.get_variable('HKMAT');
      rcd_lads_mat_mbe.eklas := lics_inbound_utility.get_variable('EKLAS');
      rcd_lads_mat_mbe.qklas := lics_inbound_utility.get_variable('QKLAS');
      rcd_lads_mat_mbe.mtuse := lics_inbound_utility.get_variable('MTUSE');
      rcd_lads_mat_mbe.mtorg := lics_inbound_utility.get_variable('MTORG');
      rcd_lads_mat_mbe.ownpr := lics_inbound_utility.get_variable('OWNPR');
      rcd_lads_mat_mbe.bwpei := lics_inbound_utility.get_number('BWPEI',null);

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
      if rcd_lads_mat_mbe.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MBE.MATNR');
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

      insert into lads_mat_mbe
         (matnr,
          mbeseq,
          msgfn,
          bwkey,
          bwtar,
          lvorm,
          vprsv,
          verpr,
          stprs,
          peinh,
          bklas,
          vmvpr,
          vmver,
          vmstp,
          vmpei,
          vmbkl,
          vjvpr,
          vjver,
          vjstp,
          lfgja,
          lfmon,
          bwtty,
          zkprs,
          zkdat,
          bwprs,
          bwprh,
          vjbws,
          vjbwh,
          vvjlb,
          vvmlb,
          vvsal,
          zplpr,
          zplp1,
          zplp2,
          zplp3,
          zpld1,
          zpld2,
          zpld3,
          kalkz,
          kalkl,
          xlifo,
          mypol,
          bwph1,
          bwps1,
          abwkz,
          pstat,
          kaln1,
          kalnr,
          bwva1,
          bwva2,
          bwva3,
          vers1,
          vers2,
          vers3,
          hrkft,
          kosgr,
          pprdz,
          pprdl,
          pprdv,
          pdatz,
          pdatl,
          pdatv,
          ekalr,
          vplpr,
          mlmaa,
          mlast,
          vjbkl,
          vjpei,
          hkmat,
          eklas,
          qklas,
          mtuse,
          mtorg,
          ownpr,
          bwpei)
      values
         (rcd_lads_mat_mbe.matnr,
          rcd_lads_mat_mbe.mbeseq,
          rcd_lads_mat_mbe.msgfn,
          rcd_lads_mat_mbe.bwkey,
          rcd_lads_mat_mbe.bwtar,
          rcd_lads_mat_mbe.lvorm,
          rcd_lads_mat_mbe.vprsv,
          rcd_lads_mat_mbe.verpr,
          rcd_lads_mat_mbe.stprs,
          rcd_lads_mat_mbe.peinh,
          rcd_lads_mat_mbe.bklas,
          rcd_lads_mat_mbe.vmvpr,
          rcd_lads_mat_mbe.vmver,
          rcd_lads_mat_mbe.vmstp,
          rcd_lads_mat_mbe.vmpei,
          rcd_lads_mat_mbe.vmbkl,
          rcd_lads_mat_mbe.vjvpr,
          rcd_lads_mat_mbe.vjver,
          rcd_lads_mat_mbe.vjstp,
          rcd_lads_mat_mbe.lfgja,
          rcd_lads_mat_mbe.lfmon,
          rcd_lads_mat_mbe.bwtty,
          rcd_lads_mat_mbe.zkprs,
          rcd_lads_mat_mbe.zkdat,
          rcd_lads_mat_mbe.bwprs,
          rcd_lads_mat_mbe.bwprh,
          rcd_lads_mat_mbe.vjbws,
          rcd_lads_mat_mbe.vjbwh,
          rcd_lads_mat_mbe.vvjlb,
          rcd_lads_mat_mbe.vvmlb,
          rcd_lads_mat_mbe.vvsal,
          rcd_lads_mat_mbe.zplpr,
          rcd_lads_mat_mbe.zplp1,
          rcd_lads_mat_mbe.zplp2,
          rcd_lads_mat_mbe.zplp3,
          rcd_lads_mat_mbe.zpld1,
          rcd_lads_mat_mbe.zpld2,
          rcd_lads_mat_mbe.zpld3,
          rcd_lads_mat_mbe.kalkz,
          rcd_lads_mat_mbe.kalkl,
          rcd_lads_mat_mbe.xlifo,
          rcd_lads_mat_mbe.mypol,
          rcd_lads_mat_mbe.bwph1,
          rcd_lads_mat_mbe.bwps1,
          rcd_lads_mat_mbe.abwkz,
          rcd_lads_mat_mbe.pstat,
          rcd_lads_mat_mbe.kaln1,
          rcd_lads_mat_mbe.kalnr,
          rcd_lads_mat_mbe.bwva1,
          rcd_lads_mat_mbe.bwva2,
          rcd_lads_mat_mbe.bwva3,
          rcd_lads_mat_mbe.vers1,
          rcd_lads_mat_mbe.vers2,
          rcd_lads_mat_mbe.vers3,
          rcd_lads_mat_mbe.hrkft,
          rcd_lads_mat_mbe.kosgr,
          rcd_lads_mat_mbe.pprdz,
          rcd_lads_mat_mbe.pprdl,
          rcd_lads_mat_mbe.pprdv,
          rcd_lads_mat_mbe.pdatz,
          rcd_lads_mat_mbe.pdatl,
          rcd_lads_mat_mbe.pdatv,
          rcd_lads_mat_mbe.ekalr,
          rcd_lads_mat_mbe.vplpr,
          rcd_lads_mat_mbe.mlmaa,
          rcd_lads_mat_mbe.mlast,
          rcd_lads_mat_mbe.vjbkl,
          rcd_lads_mat_mbe.vjpei,
          rcd_lads_mat_mbe.hkmat,
          rcd_lads_mat_mbe.eklas,
          rcd_lads_mat_mbe.qklas,
          rcd_lads_mat_mbe.mtuse,
          rcd_lads_mat_mbe.mtorg,
          rcd_lads_mat_mbe.ownpr,
          rcd_lads_mat_mbe.bwpei);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mbe;

   /**************************************************/
   /* This procedure performs the record MGN routine */
   /**************************************************/
   procedure process_record_mgn(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MGN', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mgn.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_mgn.mgnseq := rcd_lads_mat_mgn.mgnseq + 1;
      rcd_lads_mat_mgn.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mgn.lgnum := lics_inbound_utility.get_variable('LGNUM');
      rcd_lads_mat_mgn.lvorm := lics_inbound_utility.get_variable('LVORM');
      rcd_lads_mat_mgn.lgbkz := lics_inbound_utility.get_variable('LGBKZ');
      rcd_lads_mat_mgn.ltkze := lics_inbound_utility.get_variable('LTKZE');
      rcd_lads_mat_mgn.ltkza := lics_inbound_utility.get_variable('LTKZA');
      rcd_lads_mat_mgn.lhmg1 := lics_inbound_utility.get_number('LHMG1',null);
      rcd_lads_mat_mgn.lhmg2 := lics_inbound_utility.get_number('LHMG2',null);
      rcd_lads_mat_mgn.lhmg3 := lics_inbound_utility.get_number('LHMG3',null);
      rcd_lads_mat_mgn.lhme1 := lics_inbound_utility.get_variable('LHME1');
      rcd_lads_mat_mgn.lhme2 := lics_inbound_utility.get_variable('LHME2');
      rcd_lads_mat_mgn.lhme3 := lics_inbound_utility.get_variable('LHME3');
      rcd_lads_mat_mgn.lety1 := lics_inbound_utility.get_variable('LETY1');
      rcd_lads_mat_mgn.lety2 := lics_inbound_utility.get_variable('LETY2');
      rcd_lads_mat_mgn.lety3 := lics_inbound_utility.get_variable('LETY3');
      rcd_lads_mat_mgn.lvsme := lics_inbound_utility.get_variable('LVSME');
      rcd_lads_mat_mgn.kzzul := lics_inbound_utility.get_variable('KZZUL');
      rcd_lads_mat_mgn.block := lics_inbound_utility.get_variable('BLOCK');
      rcd_lads_mat_mgn.kzmbf := lics_inbound_utility.get_variable('KZMBF');
      rcd_lads_mat_mgn.bsskz := lics_inbound_utility.get_variable('BSSKZ');
      rcd_lads_mat_mgn.mkapv := lics_inbound_utility.get_number('MKAPV',null);
      rcd_lads_mat_mgn.bezme := lics_inbound_utility.get_variable('BEZME');
      rcd_lads_mat_mgn.plkpt := lics_inbound_utility.get_variable('PLKPT');
      rcd_lads_mat_mgn.vomem := lics_inbound_utility.get_variable('VOMEM');
      rcd_lads_mat_mgn.l2skr := lics_inbound_utility.get_variable('L2SKR');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_mlg.mlgseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_mgn.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MGN.MATNR');
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

      insert into lads_mat_mgn
         (matnr,
          mgnseq,
          msgfn,
          lgnum,
          lvorm,
          lgbkz,
          ltkze,
          ltkza,
          lhmg1,
          lhmg2,
          lhmg3,
          lhme1,
          lhme2,
          lhme3,
          lety1,
          lety2,
          lety3,
          lvsme,
          kzzul,
          block,
          kzmbf,
          bsskz,
          mkapv,
          bezme,
          plkpt,
          vomem,
          l2skr)
      values
         (rcd_lads_mat_mgn.matnr,
          rcd_lads_mat_mgn.mgnseq,
          rcd_lads_mat_mgn.msgfn,
          rcd_lads_mat_mgn.lgnum,
          rcd_lads_mat_mgn.lvorm,
          rcd_lads_mat_mgn.lgbkz,
          rcd_lads_mat_mgn.ltkze,
          rcd_lads_mat_mgn.ltkza,
          rcd_lads_mat_mgn.lhmg1,
          rcd_lads_mat_mgn.lhmg2,
          rcd_lads_mat_mgn.lhmg3,
          rcd_lads_mat_mgn.lhme1,
          rcd_lads_mat_mgn.lhme2,
          rcd_lads_mat_mgn.lhme3,
          rcd_lads_mat_mgn.lety1,
          rcd_lads_mat_mgn.lety2,
          rcd_lads_mat_mgn.lety3,
          rcd_lads_mat_mgn.lvsme,
          rcd_lads_mat_mgn.kzzul,
          rcd_lads_mat_mgn.block,
          rcd_lads_mat_mgn.kzmbf,
          rcd_lads_mat_mgn.bsskz,
          rcd_lads_mat_mgn.mkapv,
          rcd_lads_mat_mgn.bezme,
          rcd_lads_mat_mgn.plkpt,
          rcd_lads_mat_mgn.vomem,
          rcd_lads_mat_mgn.l2skr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mgn;

   /**************************************************/
   /* This procedure performs the record MLG routine */
   /**************************************************/
   procedure process_record_mlg(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MLG', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_mlg.matnr := rcd_lads_mat_mgn.matnr;
      rcd_lads_mat_mlg.mgnseq := rcd_lads_mat_mgn.mgnseq;
      rcd_lads_mat_mlg.mlgseq := rcd_lads_mat_mlg.mlgseq + 1;
      rcd_lads_mat_mlg.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_mlg.lgtyp := lics_inbound_utility.get_variable('LGTYP');
      rcd_lads_mat_mlg.lvorm := lics_inbound_utility.get_variable('LVORM');
      rcd_lads_mat_mlg.lgpla := lics_inbound_utility.get_variable('LGPLA');
      rcd_lads_mat_mlg.lpmax := lics_inbound_utility.get_number('LPMAX',null);
      rcd_lads_mat_mlg.lpmin := lics_inbound_utility.get_number('LPMIN',null);
      rcd_lads_mat_mlg.mamng := lics_inbound_utility.get_number('MAMNG',null);
      rcd_lads_mat_mlg.nsmng := lics_inbound_utility.get_number('NSMNG',null);
      rcd_lads_mat_mlg.kober := lics_inbound_utility.get_variable('KOBER');
      rcd_lads_mat_mlg.rdmng := lics_inbound_utility.get_number('RDMNG',null);

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
      if rcd_lads_mat_mlg.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MLG.MATNR');
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

      insert into lads_mat_mlg
         (matnr,
          mgnseq,
          mlgseq,
          msgfn,
          lgtyp,
          lvorm,
          lgpla,
          lpmax,
          lpmin,
          mamng,
          nsmng,
          kober,
          rdmng)
      values
         (rcd_lads_mat_mlg.matnr,
          rcd_lads_mat_mlg.mgnseq,
          rcd_lads_mat_mlg.mlgseq,
          rcd_lads_mat_mlg.msgfn,
          rcd_lads_mat_mlg.lgtyp,
          rcd_lads_mat_mlg.lvorm,
          rcd_lads_mat_mlg.lgpla,
          rcd_lads_mat_mlg.lpmax,
          rcd_lads_mat_mlg.lpmin,
          rcd_lads_mat_mlg.mamng,
          rcd_lads_mat_mlg.nsmng,
          rcd_lads_mat_mlg.kober,
          rcd_lads_mat_mlg.rdmng);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mlg;

   /**************************************************/
   /* This procedure performs the record SAD routine */
   /**************************************************/
   procedure process_record_sad(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SAD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_sad.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_sad.sadseq := rcd_lads_mat_sad.sadseq + 1;
      rcd_lads_mat_sad.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_sad.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_mat_sad.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_lads_mat_sad.lvorm := lics_inbound_utility.get_variable('LVORM');
      rcd_lads_mat_sad.versg := lics_inbound_utility.get_variable('VERSG');
      rcd_lads_mat_sad.bonus := lics_inbound_utility.get_variable('BONUS');
      rcd_lads_mat_sad.provg := lics_inbound_utility.get_variable('PROVG');
      rcd_lads_mat_sad.sktof := lics_inbound_utility.get_variable('SKTOF');
      rcd_lads_mat_sad.vmsta := lics_inbound_utility.get_variable('VMSTA');
      rcd_lads_mat_sad.vmstd := lics_inbound_utility.get_variable('VMSTD');
      rcd_lads_mat_sad.aumng := lics_inbound_utility.get_number('AUMNG',null);
      rcd_lads_mat_sad.lfmng := lics_inbound_utility.get_number('LFMNG',null);
      rcd_lads_mat_sad.efmng := lics_inbound_utility.get_number('EFMNG',null);
      rcd_lads_mat_sad.scmng := lics_inbound_utility.get_number('SCMNG',null);
      rcd_lads_mat_sad.schme := lics_inbound_utility.get_variable('SCHME');
      rcd_lads_mat_sad.vrkme := lics_inbound_utility.get_variable('VRKME');
      rcd_lads_mat_sad.mtpos := lics_inbound_utility.get_variable('MTPOS');
      rcd_lads_mat_sad.dwerk := lics_inbound_utility.get_variable('DWERK');
      rcd_lads_mat_sad.prodh := lics_inbound_utility.get_variable('PRODH');
      rcd_lads_mat_sad.pmatn := lics_inbound_utility.get_variable('PMATN');
      rcd_lads_mat_sad.kondm := lics_inbound_utility.get_variable('KONDM');
      rcd_lads_mat_sad.ktgrm := lics_inbound_utility.get_variable('KTGRM');
      rcd_lads_mat_sad.mvgr1 := lics_inbound_utility.get_variable('MVGR1');
      rcd_lads_mat_sad.mvgr2 := lics_inbound_utility.get_variable('MVGR2');
      rcd_lads_mat_sad.mvgr3 := lics_inbound_utility.get_variable('MVGR3');
      rcd_lads_mat_sad.mvgr4 := lics_inbound_utility.get_variable('MVGR4');
      rcd_lads_mat_sad.mvgr5 := lics_inbound_utility.get_variable('MVGR5');
      rcd_lads_mat_sad.sstuf := lics_inbound_utility.get_variable('SSTUF');
      rcd_lads_mat_sad.pflks := lics_inbound_utility.get_variable('PFLKS');
      rcd_lads_mat_sad.lstfl := lics_inbound_utility.get_variable('LSTFL');
      rcd_lads_mat_sad.lstvz := lics_inbound_utility.get_variable('LSTVZ');
      rcd_lads_mat_sad.lstak := lics_inbound_utility.get_variable('LSTAK');
      rcd_lads_mat_sad.prat1 := lics_inbound_utility.get_variable('PRAT1');
      rcd_lads_mat_sad.prat2 := lics_inbound_utility.get_variable('PRAT2');
      rcd_lads_mat_sad.prat3 := lics_inbound_utility.get_variable('PRAT3');
      rcd_lads_mat_sad.prat4 := lics_inbound_utility.get_variable('PRAT4');
      rcd_lads_mat_sad.prat5 := lics_inbound_utility.get_variable('PRAT5');
      rcd_lads_mat_sad.prat6 := lics_inbound_utility.get_variable('PRAT6');
      rcd_lads_mat_sad.prat7 := lics_inbound_utility.get_variable('PRAT7');
      rcd_lads_mat_sad.prat8 := lics_inbound_utility.get_variable('PRAT8');
      rcd_lads_mat_sad.prat9 := lics_inbound_utility.get_variable('PRAT9');
      rcd_lads_mat_sad.prata := lics_inbound_utility.get_variable('PRATA');
      rcd_lads_mat_sad.vavme := lics_inbound_utility.get_variable('VAVME');
      rcd_lads_mat_sad.rdprf := lics_inbound_utility.get_variable('RDPRF');
      rcd_lads_mat_sad.megru := lics_inbound_utility.get_variable('MEGRU');
      rcd_lads_mat_sad.pmatn_external := lics_inbound_utility.get_variable('PMATN_EXTERNAL');
      rcd_lads_mat_sad.pmatn_version := lics_inbound_utility.get_variable('PMATN_VERSION');
      rcd_lads_mat_sad.pmatn_guid := lics_inbound_utility.get_variable('PMATN_GUID');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_zsd.zsdseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_sad.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - SAD.MATNR');
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

      insert into lads_mat_sad
         (matnr,
          sadseq,
          msgfn,
          vkorg,
          vtweg,
          lvorm,
          versg,
          bonus,
          provg,
          sktof,
          vmsta,
          vmstd,
          aumng,
          lfmng,
          efmng,
          scmng,
          schme,
          vrkme,
          mtpos,
          dwerk,
          prodh,
          pmatn,
          kondm,
          ktgrm,
          mvgr1,
          mvgr2,
          mvgr3,
          mvgr4,
          mvgr5,
          sstuf,
          pflks,
          lstfl,
          lstvz,
          lstak,
          prat1,
          prat2,
          prat3,
          prat4,
          prat5,
          prat6,
          prat7,
          prat8,
          prat9,
          prata,
          vavme,
          rdprf,
          megru,
          pmatn_external,
          pmatn_version,
          pmatn_guid)
      values
         (rcd_lads_mat_sad.matnr,
          rcd_lads_mat_sad.sadseq,
          rcd_lads_mat_sad.msgfn,
          rcd_lads_mat_sad.vkorg,
          rcd_lads_mat_sad.vtweg,
          rcd_lads_mat_sad.lvorm,
          rcd_lads_mat_sad.versg,
          rcd_lads_mat_sad.bonus,
          rcd_lads_mat_sad.provg,
          rcd_lads_mat_sad.sktof,
          rcd_lads_mat_sad.vmsta,
          rcd_lads_mat_sad.vmstd,
          rcd_lads_mat_sad.aumng,
          rcd_lads_mat_sad.lfmng,
          rcd_lads_mat_sad.efmng,
          rcd_lads_mat_sad.scmng,
          rcd_lads_mat_sad.schme,
          rcd_lads_mat_sad.vrkme,
          rcd_lads_mat_sad.mtpos,
          rcd_lads_mat_sad.dwerk,
          rcd_lads_mat_sad.prodh,
          rcd_lads_mat_sad.pmatn,
          rcd_lads_mat_sad.kondm,
          rcd_lads_mat_sad.ktgrm,
          rcd_lads_mat_sad.mvgr1,
          rcd_lads_mat_sad.mvgr2,
          rcd_lads_mat_sad.mvgr3,
          rcd_lads_mat_sad.mvgr4,
          rcd_lads_mat_sad.mvgr5,
          rcd_lads_mat_sad.sstuf,
          rcd_lads_mat_sad.pflks,
          rcd_lads_mat_sad.lstfl,
          rcd_lads_mat_sad.lstvz,
          rcd_lads_mat_sad.lstak,
          rcd_lads_mat_sad.prat1,
          rcd_lads_mat_sad.prat2,
          rcd_lads_mat_sad.prat3,
          rcd_lads_mat_sad.prat4,
          rcd_lads_mat_sad.prat5,
          rcd_lads_mat_sad.prat6,
          rcd_lads_mat_sad.prat7,
          rcd_lads_mat_sad.prat8,
          rcd_lads_mat_sad.prat9,
          rcd_lads_mat_sad.prata,
          rcd_lads_mat_sad.vavme,
          rcd_lads_mat_sad.rdprf,
          rcd_lads_mat_sad.megru,
          rcd_lads_mat_sad.pmatn_external,
          rcd_lads_mat_sad.pmatn_version,
          rcd_lads_mat_sad.pmatn_guid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_sad;

   /**************************************************/
   /* This procedure performs the record ZSD routine */
   /**************************************************/
   procedure process_record_zsd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ZSD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_zsd.matnr := rcd_lads_mat_sad.matnr;
      rcd_lads_mat_zsd.sadseq := rcd_lads_mat_sad.sadseq;
      rcd_lads_mat_zsd.zsdseq := rcd_lads_mat_zsd.zsdseq + 1;
      rcd_lads_mat_zsd.zzlogist_point := lics_inbound_utility.get_number('ZZLOGIST_POINT',null);

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
      if rcd_lads_mat_zsd.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ZSD.MATNR');
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

      insert into lads_mat_zsd
         (matnr,
          sadseq,
          zsdseq,
          zzlogist_point)
      values
         (rcd_lads_mat_zsd.matnr,
          rcd_lads_mat_zsd.sadseq,
          rcd_lads_mat_zsd.zsdseq,
          rcd_lads_mat_zsd.zzlogist_point);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_zsd;

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
      rcd_lads_mat_tax.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_tax.taxseq := rcd_lads_mat_tax.taxseq + 1;
      rcd_lads_mat_tax.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_tax.aland := lics_inbound_utility.get_variable('ALAND');
      rcd_lads_mat_tax.taty1 := lics_inbound_utility.get_variable('TATY1');
      rcd_lads_mat_tax.taxm1 := lics_inbound_utility.get_variable('TAXM1');
      rcd_lads_mat_tax.taty2 := lics_inbound_utility.get_variable('TATY2');
      rcd_lads_mat_tax.taxm2 := lics_inbound_utility.get_variable('TAXM2');
      rcd_lads_mat_tax.taty3 := lics_inbound_utility.get_variable('TATY3');
      rcd_lads_mat_tax.taxm3 := lics_inbound_utility.get_variable('TAXM3');
      rcd_lads_mat_tax.taty4 := lics_inbound_utility.get_variable('TATY4');
      rcd_lads_mat_tax.taxm4 := lics_inbound_utility.get_variable('TAXM4');
      rcd_lads_mat_tax.taty5 := lics_inbound_utility.get_variable('TATY5');
      rcd_lads_mat_tax.taxm5 := lics_inbound_utility.get_variable('TAXM5');
      rcd_lads_mat_tax.taty6 := lics_inbound_utility.get_variable('TATY6');
      rcd_lads_mat_tax.taxm6 := lics_inbound_utility.get_variable('TAXM6');
      rcd_lads_mat_tax.taty7 := lics_inbound_utility.get_variable('TATY7');
      rcd_lads_mat_tax.taxm7 := lics_inbound_utility.get_variable('TAXM7');
      rcd_lads_mat_tax.taty8 := lics_inbound_utility.get_variable('TATY8');
      rcd_lads_mat_tax.taxm8 := lics_inbound_utility.get_variable('TAXM8');
      rcd_lads_mat_tax.taty9 := lics_inbound_utility.get_variable('TATY9');
      rcd_lads_mat_tax.taxm9 := lics_inbound_utility.get_variable('TAXM9');
      rcd_lads_mat_tax.taxim := lics_inbound_utility.get_variable('TAXIM');

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
      if rcd_lads_mat_tax.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TAX.MATNR');
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

      insert into lads_mat_tax
         (matnr,
          taxseq,
          msgfn,
          aland,
          taty1,
          taxm1,
          taty2,
          taxm2,
          taty3,
          taxm3,
          taty4,
          taxm4,
          taty5,
          taxm5,
          taty6,
          taxm6,
          taty7,
          taxm7,
          taty8,
          taxm8,
          taty9,
          taxm9,
          taxim)
      values
         (rcd_lads_mat_tax.matnr,
          rcd_lads_mat_tax.taxseq,
          rcd_lads_mat_tax.msgfn,
          rcd_lads_mat_tax.aland,
          rcd_lads_mat_tax.taty1,
          rcd_lads_mat_tax.taxm1,
          rcd_lads_mat_tax.taty2,
          rcd_lads_mat_tax.taxm2,
          rcd_lads_mat_tax.taty3,
          rcd_lads_mat_tax.taxm3,
          rcd_lads_mat_tax.taty4,
          rcd_lads_mat_tax.taxm4,
          rcd_lads_mat_tax.taty5,
          rcd_lads_mat_tax.taxm5,
          rcd_lads_mat_tax.taty6,
          rcd_lads_mat_tax.taxm6,
          rcd_lads_mat_tax.taty7,
          rcd_lads_mat_tax.taxm7,
          rcd_lads_mat_tax.taty8,
          rcd_lads_mat_tax.taxm8,
          rcd_lads_mat_tax.taty9,
          rcd_lads_mat_tax.taxm9,
          rcd_lads_mat_tax.taxim);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tax;

   /**************************************************/
   /* This procedure performs the record TXH routine */
   /**************************************************/
   procedure process_record_txh(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TXH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_txh.matnr := rcd_lads_mat_hdr.matnr;
      rcd_lads_mat_txh.txhseq := rcd_lads_mat_txh.txhseq + 1;
      rcd_lads_mat_txh.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_txh.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_mat_txh.tdname := lics_inbound_utility.get_variable('TDNAME');
      rcd_lads_mat_txh.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_mat_txh.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_mat_txh.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_mat_txh.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_mat_txl.txlseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_mat_txh.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXH.MATNR');
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

      insert into lads_mat_txh
         (matnr,
          txhseq,
          msgfn,
          tdobject,
          tdname,
          tdid,
          tdspras,
          tdtexttype,
          spras_iso)
      values
         (rcd_lads_mat_txh.matnr,
          rcd_lads_mat_txh.txhseq,
          rcd_lads_mat_txh.msgfn,
          rcd_lads_mat_txh.tdobject,
          rcd_lads_mat_txh.tdname,
          rcd_lads_mat_txh.tdid,
          rcd_lads_mat_txh.tdspras,
          rcd_lads_mat_txh.tdtexttype,
          rcd_lads_mat_txh.spras_iso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_txh;

   /**************************************************/
   /* This procedure performs the record TXL routine */
   /**************************************************/
   procedure process_record_txl(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TXL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_mat_txl.matnr := rcd_lads_mat_txh.matnr;
      rcd_lads_mat_txl.txhseq := rcd_lads_mat_txh.txhseq;
      rcd_lads_mat_txl.txlseq := rcd_lads_mat_txl.txlseq + 1;
      rcd_lads_mat_txl.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_mat_txl.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_mat_txl.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_mat_txl.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXL.MATNR');
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

      insert into lads_mat_txl
         (matnr,
          txhseq,
          txlseq,
          msgfn,
          tdformat,
          tdline)
      values
         (rcd_lads_mat_txl.matnr,
          rcd_lads_mat_txl.txhseq,
          rcd_lads_mat_txl.txlseq,
          rcd_lads_mat_txl.msgfn,
          rcd_lads_mat_txl.tdformat,
          rcd_lads_mat_txl.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_txl;

end lads_atllad04;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad04 for lads_app.lads_atllad04;
grant execute on lads_atllad04 to lics_app;
