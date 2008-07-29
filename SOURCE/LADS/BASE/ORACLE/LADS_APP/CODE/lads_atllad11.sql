/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad11
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad11 - Inbound Customer Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/04   Linden Glen    Removed columns : ZZKATR11, ZZKATR12, ,ZZKATR15, 
                                            ZZKATR16, ZZKATR17,  ZZKATR18, 
                                            ZZKATR19, ZZKATR20
                          Added columns   : ZZCUSTSTAT, ZZRETSTORE
 2006/01   Linden Glen    Added column    : LOCCO
 2006/11   Steve Gregan   Added columns (HDR): ZZDEMPLAN
 2006/11   Steve Gregan   Added columns (SAD): ZZCURRENTFLAG
                                               ZZFUTUREFLAG
                                               ZZMARKETACCTFLAG
 2007/08   Steve Gregan   Added columns (SAD) for Atlas 3.2.1 upgrade
 2008/05   Trevor Keon    Added calls to monitor before and after procedure

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad11 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad11;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad11 as

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
   procedure process_record_hth(par_record in varchar2);
   procedure process_record_htd(par_record in varchar2);
   procedure process_record_sad(par_record in varchar2);
   procedure process_record_zsd(par_record in varchar2);
   procedure process_record_zsv(par_record in varchar2);
   procedure process_record_pfr(par_record in varchar2);
   procedure process_record_stx(par_record in varchar2);
   procedure process_record_lid(par_record in varchar2);
   procedure process_record_sat(par_record in varchar2);
   procedure process_record_std(par_record in varchar2);
   procedure process_record_cud(par_record in varchar2);
   procedure process_record_ctx(par_record in varchar2);
   procedure process_record_cte(par_record in varchar2);
   procedure process_record_ctd(par_record in varchar2);
   procedure process_record_bnk(par_record in varchar2);
   procedure process_record_unl(par_record in varchar2);
   procedure process_record_prp(par_record in varchar2);
   procedure process_record_pdp(par_record in varchar2);
   procedure process_record_cnt(par_record in varchar2);
   procedure process_record_vat(par_record in varchar2);
   procedure process_record_plm(par_record in varchar2);
   procedure process_record_mgv(par_record in varchar2);
   procedure process_record_mge(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_cus_hdr lads_cus_hdr%rowtype;
   rcd_lads_cus_hth lads_cus_hth%rowtype;
   rcd_lads_cus_htd lads_cus_htd%rowtype;
   rcd_lads_cus_sad lads_cus_sad%rowtype;
   rcd_lads_cus_zsd lads_cus_zsd%rowtype;
   rcd_lads_cus_zsv lads_cus_zsv%rowtype;
   rcd_lads_cus_pfr lads_cus_pfr%rowtype;
   rcd_lads_cus_stx lads_cus_stx%rowtype;
   rcd_lads_cus_lid lads_cus_lid%rowtype;
   rcd_lads_cus_sat lads_cus_sat%rowtype;
   rcd_lads_cus_std lads_cus_std%rowtype;
   rcd_lads_cus_cud lads_cus_cud%rowtype;
   rcd_lads_cus_ctx lads_cus_ctx%rowtype;
   rcd_lads_cus_cte lads_cus_cte%rowtype;
   rcd_lads_cus_ctd lads_cus_ctd%rowtype;
   rcd_lads_cus_bnk lads_cus_bnk%rowtype;
   rcd_lads_cus_unl lads_cus_unl%rowtype;
   rcd_lads_cus_prp lads_cus_prp%rowtype;
   rcd_lads_cus_pdp lads_cus_pdp%rowtype;
   rcd_lads_cus_cnt lads_cus_cnt%rowtype;
   rcd_lads_cus_vat lads_cus_vat%rowtype;
   rcd_lads_cus_plm lads_cus_plm%rowtype;
   rcd_lads_cus_mgv lads_cus_mgv%rowtype;
   rcd_lads_cus_mge lads_cus_mge%rowtype;

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
      lics_inbound_utility.set_definition('HDR','KUNNR',10);
      lics_inbound_utility.set_definition('HDR','AUFSD',2);
      lics_inbound_utility.set_definition('HDR','BEGRU',4);
      lics_inbound_utility.set_definition('HDR','BRSCH',4);
      lics_inbound_utility.set_definition('HDR','FAKSD',2);
      lics_inbound_utility.set_definition('HDR','FISKN',10);
      lics_inbound_utility.set_definition('HDR','KNRZA',10);
      lics_inbound_utility.set_definition('HDR','KONZS',10);
      lics_inbound_utility.set_definition('HDR','KTOKD',4);
      lics_inbound_utility.set_definition('HDR','KUKLA',2);
      lics_inbound_utility.set_definition('HDR','LIFNR',10);
      lics_inbound_utility.set_definition('HDR','LIFSD',2);
      lics_inbound_utility.set_definition('HDR','LOEVM',1);
      lics_inbound_utility.set_definition('HDR','SPERR',1);
      lics_inbound_utility.set_definition('HDR','STCD1',16);
      lics_inbound_utility.set_definition('HDR','STCD2',11);
      lics_inbound_utility.set_definition('HDR','STKZA',1);
      lics_inbound_utility.set_definition('HDR','STKZU',1);
      lics_inbound_utility.set_definition('HDR','XZEMP',1);
      lics_inbound_utility.set_definition('HDR','VBUND',6);
      lics_inbound_utility.set_definition('HDR','STCEG',20);
      lics_inbound_utility.set_definition('HDR','GFORM',2);
      lics_inbound_utility.set_definition('HDR','UMJAH',4);
      lics_inbound_utility.set_definition('HDR','UWAER',5);
      lics_inbound_utility.set_definition('HDR','KATR2',2);
      lics_inbound_utility.set_definition('HDR','KATR3',2);
      lics_inbound_utility.set_definition('HDR','KATR4',2);
      lics_inbound_utility.set_definition('HDR','KATR5',2);
      lics_inbound_utility.set_definition('HDR','KATR6',3);
      lics_inbound_utility.set_definition('HDR','KATR7',3);
      lics_inbound_utility.set_definition('HDR','KATR8',3);
      lics_inbound_utility.set_definition('HDR','KATR9',3);
      lics_inbound_utility.set_definition('HDR','KATR10',3);
      lics_inbound_utility.set_definition('HDR','STKZN',1);
      lics_inbound_utility.set_definition('HDR','UMSA1',16);
      lics_inbound_utility.set_definition('HDR','PERIV',2);
      lics_inbound_utility.set_definition('HDR','KTOCD',4);
      lics_inbound_utility.set_definition('HDR','FITYP',2);
      lics_inbound_utility.set_definition('HDR','STCDT',2);
      lics_inbound_utility.set_definition('HDR','STCD3',18);
      lics_inbound_utility.set_definition('HDR','STCD4',18);
      lics_inbound_utility.set_definition('HDR','CASSD',2);
      lics_inbound_utility.set_definition('HDR','KDKG1',2);
      lics_inbound_utility.set_definition('HDR','KDKG2',2);
      lics_inbound_utility.set_definition('HDR','KDKG3',2);
      lics_inbound_utility.set_definition('HDR','KDKG4',2);
      lics_inbound_utility.set_definition('HDR','KDKG5',2);
      lics_inbound_utility.set_definition('HDR','NODEL',1);
      lics_inbound_utility.set_definition('HDR','XSUB2',3);
      lics_inbound_utility.set_definition('HDR','WERKS',4);
      lics_inbound_utility.set_definition('HDR','ZZCUSTOM01',1);
      lics_inbound_utility.set_definition('HDR','ZZKATR13',3);
      lics_inbound_utility.set_definition('HDR','ZZKATR14',3);
      lics_inbound_utility.set_definition('HDR','J_1KFREPRE',10);
      lics_inbound_utility.set_definition('HDR','J_1KFTBUS',30);
      lics_inbound_utility.set_definition('HDR','J_1KFTIND',30);
      lics_inbound_utility.set_definition('HDR','PSOIS',20);
      lics_inbound_utility.set_definition('HDR','KATR1',2);
      lics_inbound_utility.set_definition('HDR','ZZCUSTSTAT',2);
      lics_inbound_utility.set_definition('HDR','ZZRETSTORE',8);
      lics_inbound_utility.set_definition('HDR','LOCCO',10);
      lics_inbound_utility.set_definition('HDR','ZZDEMPLAN',10);
      /*-*/
      lics_inbound_utility.set_definition('HTH','IDOC_HTH',3);
      lics_inbound_utility.set_definition('HTH','TDOBJECT',10);
      lics_inbound_utility.set_definition('HTH','TDNAME',70);
      lics_inbound_utility.set_definition('HTH','TDID',4);
      lics_inbound_utility.set_definition('HTH','TDSPRAS',1);
      lics_inbound_utility.set_definition('HTH','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('HTH','TDSPRASISO',2);
      /*-*/
      lics_inbound_utility.set_definition('HTD','IDOC_HTD',3);
      lics_inbound_utility.set_definition('HTD','TDFORMAT',2);
      lics_inbound_utility.set_definition('HTD','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('SAD','IDOC_SAD',3);
      lics_inbound_utility.set_definition('SAD','VKORG',4);
      lics_inbound_utility.set_definition('SAD','VTWEG',2);
      lics_inbound_utility.set_definition('SAD','SPART',2);
      lics_inbound_utility.set_definition('SAD','BEGRU',4);
      lics_inbound_utility.set_definition('SAD','LOEVM',1);
      lics_inbound_utility.set_definition('SAD','VERSG',1);
      lics_inbound_utility.set_definition('SAD','AUFSD',2);
      lics_inbound_utility.set_definition('SAD','KALKS',1);
      lics_inbound_utility.set_definition('SAD','KDGRP',2);
      lics_inbound_utility.set_definition('SAD','BZIRK',6);
      lics_inbound_utility.set_definition('SAD','KONDA',2);
      lics_inbound_utility.set_definition('SAD','PLTYP',2);
      lics_inbound_utility.set_definition('SAD','AWAHR',3);
      lics_inbound_utility.set_definition('SAD','INCO1',3);
      lics_inbound_utility.set_definition('SAD','INCO2',28);
      lics_inbound_utility.set_definition('SAD','LIFSD',2);
      lics_inbound_utility.set_definition('SAD','AUTLF',1);
      lics_inbound_utility.set_definition('SAD','ANTLF',2);
      lics_inbound_utility.set_definition('SAD','KZTLF',1);
      lics_inbound_utility.set_definition('SAD','KZAZU',1);
      lics_inbound_utility.set_definition('SAD','CHSPL',1);
      lics_inbound_utility.set_definition('SAD','LPRIO',2);
      lics_inbound_utility.set_definition('SAD','EIKTO',12);
      lics_inbound_utility.set_definition('SAD','VSBED',2);
      lics_inbound_utility.set_definition('SAD','FAKSD',2);
      lics_inbound_utility.set_definition('SAD','MRNKZ',1);
      lics_inbound_utility.set_definition('SAD','PERFK',2);
      lics_inbound_utility.set_definition('SAD','PERRL',2);
      lics_inbound_utility.set_definition('SAD','WAERS',5);
      lics_inbound_utility.set_definition('SAD','KTGRD',2);
      lics_inbound_utility.set_definition('SAD','ZTERM',4);
      lics_inbound_utility.set_definition('SAD','VWERK',4);
      lics_inbound_utility.set_definition('SAD','VKGRP',3);
      lics_inbound_utility.set_definition('SAD','VKBUR',4);
      lics_inbound_utility.set_definition('SAD','VSORT',10);
      lics_inbound_utility.set_definition('SAD','KVGR1',3);
      lics_inbound_utility.set_definition('SAD','KVGR2',3);
      lics_inbound_utility.set_definition('SAD','KVGR3',3);
      lics_inbound_utility.set_definition('SAD','KVGR4',3);
      lics_inbound_utility.set_definition('SAD','KVGR5',3);
      lics_inbound_utility.set_definition('SAD','BOKRE',1);
      lics_inbound_utility.set_definition('SAD','KURST',4);
      lics_inbound_utility.set_definition('SAD','PRFRE',1);
      lics_inbound_utility.set_definition('SAD','KLABC',2);
      lics_inbound_utility.set_definition('SAD','KABSS',4);
      lics_inbound_utility.set_definition('SAD','KKBER',4);
      lics_inbound_utility.set_definition('SAD','CASSD',2);
      lics_inbound_utility.set_definition('SAD','RDOFF',1);
      lics_inbound_utility.set_definition('SAD','AGREL',1);
      lics_inbound_utility.set_definition('SAD','MEGRU',4);
      lics_inbound_utility.set_definition('SAD','UEBTO',4);
      lics_inbound_utility.set_definition('SAD','UNTTO',4);
      lics_inbound_utility.set_definition('SAD','UEBTK',1);
      lics_inbound_utility.set_definition('SAD','PVKSM',2);
      lics_inbound_utility.set_definition('SAD','PODKZ',1);
      lics_inbound_utility.set_definition('SAD','PODTG',11);
      lics_inbound_utility.set_definition('SAD','BLIND',1);
      lics_inbound_utility.set_definition('SAD','ZZSHELFGRP',2);
      lics_inbound_utility.set_definition('SAD','ZZVMICDIM',2);
      lics_inbound_utility.set_definition('SAD','ZZCURRENTFLAG',1);
      lics_inbound_utility.set_definition('SAD','ZZFUTUREFLAG',1);
      lics_inbound_utility.set_definition('SAD','ZZMARKETACCTFLAG',1);
      lics_inbound_utility.set_definition('SAD','ZZCSPIV',1);
      lics_inbound_utility.set_definition('SAD','ZZCMPH',17);
      lics_inbound_utility.set_definition('SAD','ZZCMPH_UOM',3);
      lics_inbound_utility.set_definition('SAD','ZZHPPL',1);
      lics_inbound_utility.set_definition('SAD','ZZHPPC',1);
      lics_inbound_utility.set_definition('SAD','ZZTMR',1);
      lics_inbound_utility.set_definition('SAD','ZZPPPM',18);
      lics_inbound_utility.set_definition('SAD','ZZMPPH',17);
      lics_inbound_utility.set_definition('SAD','ZZMPPH_UOM',3);
      /*-*/
      lics_inbound_utility.set_definition('ZSD','IDOC_ZSD',3);
      lics_inbound_utility.set_definition('ZSD','VKORG',4);
      lics_inbound_utility.set_definition('ZSD','VTWEG',2);
      lics_inbound_utility.set_definition('ZSD','SPART',2);
      lics_inbound_utility.set_definition('ZSD','VMICT',2);
      /*-*/
      lics_inbound_utility.set_definition('ZSV','IDOC_ZSV',3);
      lics_inbound_utility.set_definition('ZSV','VKORG',4);
      lics_inbound_utility.set_definition('ZSV','VTWEG',2);
      lics_inbound_utility.set_definition('ZSV','SPART',2);
      lics_inbound_utility.set_definition('ZSV','VMIFDS',2);
      /*-*/
      lics_inbound_utility.set_definition('PFR','IDOC_PFR',3);
      lics_inbound_utility.set_definition('PFR','PARVW',2);
      lics_inbound_utility.set_definition('PFR','KUNN2',10);
      lics_inbound_utility.set_definition('PFR','DEFPA',1);
      lics_inbound_utility.set_definition('PFR','KNREF',30);
      lics_inbound_utility.set_definition('PFR','PARZA',3);
      lics_inbound_utility.set_definition('PFR','ZZ_PARVW_TXT',20);
      lics_inbound_utility.set_definition('PFR','ZZ_PARTN_NAM',80);
      lics_inbound_utility.set_definition('PFR','ZZ_PARTN_NACHN',40);
      lics_inbound_utility.set_definition('PFR','ZZ_PARTN_VORNA',40);
      /*-*/
      lics_inbound_utility.set_definition('STX','IDOC_STX',3);
      lics_inbound_utility.set_definition('STX','ALAND',3);
      lics_inbound_utility.set_definition('STX','TATYP',4);
      lics_inbound_utility.set_definition('STX','TAXKD',1);
      /*-*/
      lics_inbound_utility.set_definition('LID','IDOC_LID',3);
      lics_inbound_utility.set_definition('LID','ALAND',3);
      lics_inbound_utility.set_definition('LID','TATYP',4);
      lics_inbound_utility.set_definition('LID','LICNR',15);
      lics_inbound_utility.set_definition('LID','DATAB',8);
      lics_inbound_utility.set_definition('LID','DATBI',8);
      lics_inbound_utility.set_definition('LID','BELIC',1);
      /*-*/
      lics_inbound_utility.set_definition('SAT','IDOC_SAT',3);
      lics_inbound_utility.set_definition('SAT','TDOBJECT',10);
      lics_inbound_utility.set_definition('SAT','TDNAME',70);
      lics_inbound_utility.set_definition('SAT','TDID',4);
      lics_inbound_utility.set_definition('SAT','TDSPRAS',1);
      lics_inbound_utility.set_definition('SAT','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('SAT','TDSPRASISO',2);
      /*-*/
      lics_inbound_utility.set_definition('STD','IDOC_STD',3);
      lics_inbound_utility.set_definition('STD','TDFORMAT',2);
      lics_inbound_utility.set_definition('STD','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('CUD','IDOC_CUD',3);
      lics_inbound_utility.set_definition('CUD','BUKRS',6);
      lics_inbound_utility.set_definition('CUD','SPERR',1);
      lics_inbound_utility.set_definition('CUD','LOEVM',1);
      lics_inbound_utility.set_definition('CUD','ZUAWA',3);
      lics_inbound_utility.set_definition('CUD','BUSAB',2);
      lics_inbound_utility.set_definition('CUD','AKONT',10);
      lics_inbound_utility.set_definition('CUD','BEGRU',4);
      lics_inbound_utility.set_definition('CUD','KNRZE',10);
      lics_inbound_utility.set_definition('CUD','KNRZB',10);
      lics_inbound_utility.set_definition('CUD','ZAMIM',1);
      lics_inbound_utility.set_definition('CUD','ZAMIV',1);
      lics_inbound_utility.set_definition('CUD','ZAMIR',1);
      lics_inbound_utility.set_definition('CUD','ZAMIB',1);
      lics_inbound_utility.set_definition('CUD','ZAMIO',1);
      lics_inbound_utility.set_definition('CUD','ZWELS',10);
      lics_inbound_utility.set_definition('CUD','XVERR',1);
      lics_inbound_utility.set_definition('CUD','ZAHLS',1);
      lics_inbound_utility.set_definition('CUD','ZTERM',4);
      lics_inbound_utility.set_definition('CUD','WAKON',4);
      lics_inbound_utility.set_definition('CUD','VZSKZ',2);
      lics_inbound_utility.set_definition('CUD','ZINDT',8);
      lics_inbound_utility.set_definition('CUD','ZINRT',2);
      lics_inbound_utility.set_definition('CUD','EIKTO',12);
      lics_inbound_utility.set_definition('CUD','ZSABE',15);
      lics_inbound_utility.set_definition('CUD','KVERM',30);
      lics_inbound_utility.set_definition('CUD','FDGRV',10);
      lics_inbound_utility.set_definition('CUD','VRBKZ',2);
      lics_inbound_utility.set_definition('CUD','VLIBB',14);
      lics_inbound_utility.set_definition('CUD','VRSZL',4);
      lics_inbound_utility.set_definition('CUD','VRSPR',4);
      lics_inbound_utility.set_definition('CUD','VRSNR',10);
      lics_inbound_utility.set_definition('CUD','VERDT',8);
      lics_inbound_utility.set_definition('CUD','PERKZ',1);
      lics_inbound_utility.set_definition('CUD','XDEZV',1);
      lics_inbound_utility.set_definition('CUD','XAUSZ',1);
      lics_inbound_utility.set_definition('CUD','WEBTR',14);
      lics_inbound_utility.set_definition('CUD','REMIT',10);
      lics_inbound_utility.set_definition('CUD','DATLZ',8);
      lics_inbound_utility.set_definition('CUD','XZVER',1);
      lics_inbound_utility.set_definition('CUD','TOGRU',4);
      lics_inbound_utility.set_definition('CUD','KULTG',4);
      lics_inbound_utility.set_definition('CUD','HBKID',5);
      lics_inbound_utility.set_definition('CUD','XPORE',1);
      lics_inbound_utility.set_definition('CUD','BLNKZ',2);
      lics_inbound_utility.set_definition('CUD','ALTKN',10);
      lics_inbound_utility.set_definition('CUD','ZGRUP',2);
      lics_inbound_utility.set_definition('CUD','URLID',4);
      lics_inbound_utility.set_definition('CUD','MGRUP',2);
      lics_inbound_utility.set_definition('CUD','LOCKB',7);
      lics_inbound_utility.set_definition('CUD','UZAWE',2);
      lics_inbound_utility.set_definition('CUD','EKVBD',10);
      lics_inbound_utility.set_definition('CUD','SREGL',3);
      lics_inbound_utility.set_definition('CUD','XEDIP',1);
      lics_inbound_utility.set_definition('CUD','FRGRP',4);
      lics_inbound_utility.set_definition('CUD','VRSDG',3);
      lics_inbound_utility.set_definition('CUD','TLFXS',31);
      lics_inbound_utility.set_definition('CUD','PERNR',8);
      lics_inbound_utility.set_definition('CUD','INTAD',130);
      lics_inbound_utility.set_definition('CUD','GUZTE',4);
      lics_inbound_utility.set_definition('CUD','GRICD',2);
      lics_inbound_utility.set_definition('CUD','GRIDT',2);
      lics_inbound_utility.set_definition('CUD','WBRSL',2);
      lics_inbound_utility.set_definition('CUD','NODEL',1);
      lics_inbound_utility.set_definition('CUD','TLFNS',30);
      lics_inbound_utility.set_definition('CUD','CESSION_KZ',2);
      lics_inbound_utility.set_definition('CUD','GMVKZD',1);
      /*-*/
      lics_inbound_utility.set_definition('CTX','IDOC_CTX',3);
      lics_inbound_utility.set_definition('CTX','WITHT',2);
      lics_inbound_utility.set_definition('CTX','WT_WITHCD',2);
      lics_inbound_utility.set_definition('CTX','WT_AGENT',1);
      lics_inbound_utility.set_definition('CTX','WT_AGTDF',8);
      lics_inbound_utility.set_definition('CTX','WT_AGTDT',8);
      lics_inbound_utility.set_definition('CTX','WT_WTSTCD',16);
      lics_inbound_utility.set_definition('CTX','BUKRS',4);
      /*-*/
      lics_inbound_utility.set_definition('CTE','IDOC_CTE',3);
      lics_inbound_utility.set_definition('CTE','TDOBJECT',10);
      lics_inbound_utility.set_definition('CTE','TDNAME',70);
      lics_inbound_utility.set_definition('CTE','TDID',4);
      lics_inbound_utility.set_definition('CTE','TDSPRAS',1);
      lics_inbound_utility.set_definition('CTE','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('CTE','TDSPRASISO',2);
      /*-*/
      lics_inbound_utility.set_definition('CTD','IDOC_CTD',3);
      lics_inbound_utility.set_definition('CTD','TDFORMAT',2);
      lics_inbound_utility.set_definition('CTD','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('BNK','IDOC_BNK',3);
      lics_inbound_utility.set_definition('BNK','BANKS',3);
      lics_inbound_utility.set_definition('BNK','BANKL',15);
      lics_inbound_utility.set_definition('BNK','BANKN',18);
      lics_inbound_utility.set_definition('BNK','BKONT',2);
      lics_inbound_utility.set_definition('BNK','BVTYP',4);
      lics_inbound_utility.set_definition('BNK','XEZER',1);
      lics_inbound_utility.set_definition('BNK','BKREF',20);
      lics_inbound_utility.set_definition('BNK','BANKA',60);
      lics_inbound_utility.set_definition('BNK','STRAS',35);
      lics_inbound_utility.set_definition('BNK','ORT01',35);
      lics_inbound_utility.set_definition('BNK','SWIFT',11);
      lics_inbound_utility.set_definition('BNK','BGRUP',2);
      lics_inbound_utility.set_definition('BNK','XPGRO',1);
      lics_inbound_utility.set_definition('BNK','BNKLZ',15);
      lics_inbound_utility.set_definition('BNK','PSKTO',16);
      lics_inbound_utility.set_definition('BNK','BRNCH',40);
      lics_inbound_utility.set_definition('BNK','PROVZ',3);
      lics_inbound_utility.set_definition('BNK','KOINH',35);
      lics_inbound_utility.set_definition('BNK','KOINH_N',60);
      lics_inbound_utility.set_definition('BNK','KOVON',8);
      lics_inbound_utility.set_definition('BNK','KOBIS',8);
      /*-*/
      lics_inbound_utility.set_definition('UNL','IDOC_UNL',3);
      lics_inbound_utility.set_definition('UNL','ABLAD',25);
      lics_inbound_utility.set_definition('UNL','KNFAK',2);
      lics_inbound_utility.set_definition('UNL','WANID',3);
      lics_inbound_utility.set_definition('UNL','DEFAB',1);
      /*-*/
      lics_inbound_utility.set_definition('PRP','IDOC_PRP',3);
      lics_inbound_utility.set_definition('PRP','LOCNR',10);
      lics_inbound_utility.set_definition('PRP','EMPST',25);
      lics_inbound_utility.set_definition('PRP','KUNN2',10);
      lics_inbound_utility.set_definition('PRP','ABLAD',25);
      /*-*/
      lics_inbound_utility.set_definition('PDP','IDOC_PDP',3);
      lics_inbound_utility.set_definition('PDP','LOCNR',10);
      lics_inbound_utility.set_definition('PDP','ABTNR',4);
      lics_inbound_utility.set_definition('PDP','EMPST',25);
      lics_inbound_utility.set_definition('PDP','VERFL',6);
      lics_inbound_utility.set_definition('PDP','VERFE',3);
      lics_inbound_utility.set_definition('PDP','LAYVR',10);
      lics_inbound_utility.set_definition('PDP','FLVAR',4);
      /*-*/
      lics_inbound_utility.set_definition('CNT','IDOC_CNT',3);
      lics_inbound_utility.set_definition('CNT','PARNR',10);
      lics_inbound_utility.set_definition('CNT','NAMEV',35);
      lics_inbound_utility.set_definition('CNT','NAME1',35);
      lics_inbound_utility.set_definition('CNT','ABTPA',12);
      lics_inbound_utility.set_definition('CNT','ABTNR',4);
      lics_inbound_utility.set_definition('CNT','UEPAR',10);
      lics_inbound_utility.set_definition('CNT','TELF1',16);
      lics_inbound_utility.set_definition('CNT','ANRED',30);
      lics_inbound_utility.set_definition('CNT','PAFKT',2);
      lics_inbound_utility.set_definition('CNT','SORTL',10);
      lics_inbound_utility.set_definition('CNT','ZZ_TEL_EXTENS',10);
      lics_inbound_utility.set_definition('CNT','ZZ_FAX_NUMBER',30);
      lics_inbound_utility.set_definition('CNT','ZZ_FAX_EXTENS',10);
      /*-*/
      lics_inbound_utility.set_definition('VAT','IDOC_VAT',3);
      lics_inbound_utility.set_definition('VAT','LAND1',3);
      lics_inbound_utility.set_definition('VAT','STCEG',20);
      /*-*/
      lics_inbound_utility.set_definition('PLM','IDOC_PLM',3);
      lics_inbound_utility.set_definition('PLM','LOCNR',10);
      lics_inbound_utility.set_definition('PLM','EROED',8);
      lics_inbound_utility.set_definition('PLM','SCHLD',8);
      lics_inbound_utility.set_definition('PLM','SPDAB',8);
      lics_inbound_utility.set_definition('PLM','SPDBI',8);
      lics_inbound_utility.set_definition('PLM','AUTOB',1);
      lics_inbound_utility.set_definition('PLM','KOPRO',4);
      lics_inbound_utility.set_definition('PLM','LAYVR',10);
      lics_inbound_utility.set_definition('PLM','FLVAR',4);
      lics_inbound_utility.set_definition('PLM','STFAK',2);
      lics_inbound_utility.set_definition('PLM','WANID',3);
      lics_inbound_utility.set_definition('PLM','VERFL',8);
      lics_inbound_utility.set_definition('PLM','VERFE',3);
      lics_inbound_utility.set_definition('PLM','SPGR1',2);
      lics_inbound_utility.set_definition('PLM','INPRO',4);
      lics_inbound_utility.set_definition('PLM','EKOAR',4);
      lics_inbound_utility.set_definition('PLM','KZLIK',1);
      lics_inbound_utility.set_definition('PLM','BETRP',4);
      lics_inbound_utility.set_definition('PLM','ERDAT',8);
      lics_inbound_utility.set_definition('PLM','ERNAM',12);
      lics_inbound_utility.set_definition('PLM','NLMATFB',1);
      lics_inbound_utility.set_definition('PLM','BWWRK',4);
      lics_inbound_utility.set_definition('PLM','BWVKO',4);
      lics_inbound_utility.set_definition('PLM','BWVTW',2);
      lics_inbound_utility.set_definition('PLM','BBPRO',4);
      lics_inbound_utility.set_definition('PLM','VKBUR_WRK',4);
      lics_inbound_utility.set_definition('PLM','VLFKZ',1);
      lics_inbound_utility.set_definition('PLM','LSTFL',2);
      lics_inbound_utility.set_definition('PLM','LIGRD',1);
      lics_inbound_utility.set_definition('PLM','VKORG',4);
      lics_inbound_utility.set_definition('PLM','VTWEG',2);
      lics_inbound_utility.set_definition('PLM','DESROI',7);
      lics_inbound_utility.set_definition('PLM','TIMINC',6);
      lics_inbound_utility.set_definition('PLM','POSWS',5);
      lics_inbound_utility.set_definition('PLM','SSOPT_PRO',4);
      lics_inbound_utility.set_definition('PLM','WBPRO',4);
      /*-*/
      lics_inbound_utility.set_definition('MGV','IDOC_MGV',3);
      lics_inbound_utility.set_definition('MGV','LOCNR',10);
      lics_inbound_utility.set_definition('MGV','MATKL',9);
      lics_inbound_utility.set_definition('MGV','WWGPA',18);
      lics_inbound_utility.set_definition('MGV','KEDET',1);
      /*-*/
      lics_inbound_utility.set_definition('MGE','IDOC_MGE',3);
      lics_inbound_utility.set_definition('MGE','LOCNR',10);
      lics_inbound_utility.set_definition('MGE','MATNR',18);
      lics_inbound_utility.set_definition('MGE','WMATN',18);
      lics_inbound_utility.set_definition('MGE','MATKL',9);

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
         when 'HTH' then process_record_hth(par_record);
         when 'HTD' then process_record_htd(par_record);
         when 'SAD' then process_record_sad(par_record);
         when 'ZSD' then process_record_zsd(par_record);
         when 'ZSV' then process_record_zsv(par_record);
         when 'PFR' then process_record_pfr(par_record);
         when 'STX' then process_record_stx(par_record);
         when 'LID' then process_record_lid(par_record);
         when 'SAT' then process_record_sat(par_record);
         when 'STD' then process_record_std(par_record);
         when 'CUD' then process_record_cud(par_record);
         when 'CTX' then process_record_ctx(par_record);
         when 'CTE' then process_record_cte(par_record);
         when 'CTD' then process_record_ctd(par_record);
         when 'BNK' then process_record_bnk(par_record);
         when 'UNL' then process_record_unl(par_record);
         when 'PRP' then process_record_prp(par_record);
         when 'PDP' then process_record_pdp(par_record);
         when 'CNT' then process_record_cnt(par_record);
         when 'VAT' then process_record_vat(par_record);
         when 'PLM' then process_record_plm(par_record);
         when 'MGV' then process_record_mgv(par_record);
         when 'MGE' then process_record_mge(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD11';
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
            lads_atllad11_monitor.execute_before(rcd_lads_cus_hdr.kunnr);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
         
         commit;
         
         begin
            lads_atllad11_monitor.execute_after(rcd_lads_cus_hdr.kunnr);
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
      cursor csr_lads_cus_hdr_01 is
         select
            t01.kunnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_cus_hdr t01
         where t01.kunnr= rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_hdr_01 csr_lads_cus_hdr_01%rowtype;

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
      rcd_lads_cus_hdr.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_cus_hdr.aufsd := lics_inbound_utility.get_variable('AUFSD');
      rcd_lads_cus_hdr.begru := lics_inbound_utility.get_variable('BEGRU');
      rcd_lads_cus_hdr.brsch := lics_inbound_utility.get_variable('BRSCH');
      rcd_lads_cus_hdr.faksd := lics_inbound_utility.get_variable('FAKSD');
      rcd_lads_cus_hdr.fiskn := lics_inbound_utility.get_variable('FISKN');
      rcd_lads_cus_hdr.knrza := lics_inbound_utility.get_variable('KNRZA');
      rcd_lads_cus_hdr.konzs := lics_inbound_utility.get_variable('KONZS');
      rcd_lads_cus_hdr.ktokd := lics_inbound_utility.get_variable('KTOKD');
      rcd_lads_cus_hdr.kukla := lics_inbound_utility.get_variable('KUKLA');
      rcd_lads_cus_hdr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_cus_hdr.lifsd := lics_inbound_utility.get_variable('LIFSD');
      rcd_lads_cus_hdr.loevm := lics_inbound_utility.get_variable('LOEVM');
      rcd_lads_cus_hdr.sperr := lics_inbound_utility.get_variable('SPERR');
      rcd_lads_cus_hdr.stcd1 := lics_inbound_utility.get_variable('STCD1');
      rcd_lads_cus_hdr.stcd2 := lics_inbound_utility.get_variable('STCD2');
      rcd_lads_cus_hdr.stkza := lics_inbound_utility.get_variable('STKZA');
      rcd_lads_cus_hdr.stkzu := lics_inbound_utility.get_variable('STKZU');
      rcd_lads_cus_hdr.xzemp := lics_inbound_utility.get_variable('XZEMP');
      rcd_lads_cus_hdr.vbund := lics_inbound_utility.get_variable('VBUND');
      rcd_lads_cus_hdr.stceg := lics_inbound_utility.get_variable('STCEG');
      rcd_lads_cus_hdr.gform := lics_inbound_utility.get_variable('GFORM');
      rcd_lads_cus_hdr.umjah := lics_inbound_utility.get_number('UMJAH',null);
      rcd_lads_cus_hdr.uwaer := lics_inbound_utility.get_variable('UWAER');
      rcd_lads_cus_hdr.katr2 := lics_inbound_utility.get_variable('KATR2');
      rcd_lads_cus_hdr.katr3 := lics_inbound_utility.get_variable('KATR3');
      rcd_lads_cus_hdr.katr4 := lics_inbound_utility.get_variable('KATR4');
      rcd_lads_cus_hdr.katr5 := lics_inbound_utility.get_variable('KATR5');
      rcd_lads_cus_hdr.katr6 := lics_inbound_utility.get_variable('KATR6');
      rcd_lads_cus_hdr.katr7 := lics_inbound_utility.get_variable('KATR7');
      rcd_lads_cus_hdr.katr8 := lics_inbound_utility.get_variable('KATR8');
      rcd_lads_cus_hdr.katr9 := lics_inbound_utility.get_variable('KATR9');
      rcd_lads_cus_hdr.katr10 := lics_inbound_utility.get_variable('KATR10');
      rcd_lads_cus_hdr.stkzn := lics_inbound_utility.get_variable('STKZN');
      rcd_lads_cus_hdr.umsa1 := lics_inbound_utility.get_variable('UMSA1');
      rcd_lads_cus_hdr.periv := lics_inbound_utility.get_variable('PERIV');
      rcd_lads_cus_hdr.ktocd := lics_inbound_utility.get_variable('KTOCD');
      rcd_lads_cus_hdr.fityp := lics_inbound_utility.get_variable('FITYP');
      rcd_lads_cus_hdr.stcdt := lics_inbound_utility.get_variable('STCDT');
      rcd_lads_cus_hdr.stcd3 := lics_inbound_utility.get_variable('STCD3');
      rcd_lads_cus_hdr.stcd4 := lics_inbound_utility.get_variable('STCD4');
      rcd_lads_cus_hdr.cassd := lics_inbound_utility.get_variable('CASSD');
      rcd_lads_cus_hdr.kdkg1 := lics_inbound_utility.get_variable('KDKG1');
      rcd_lads_cus_hdr.kdkg2 := lics_inbound_utility.get_variable('KDKG2');
      rcd_lads_cus_hdr.kdkg3 := lics_inbound_utility.get_variable('KDKG3');
      rcd_lads_cus_hdr.kdkg4 := lics_inbound_utility.get_variable('KDKG4');
      rcd_lads_cus_hdr.kdkg5 := lics_inbound_utility.get_variable('KDKG5');
      rcd_lads_cus_hdr.nodel := lics_inbound_utility.get_variable('NODEL');
      rcd_lads_cus_hdr.xsub2 := lics_inbound_utility.get_variable('XSUB2');
      rcd_lads_cus_hdr.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_cus_hdr.zzcustom01 := lics_inbound_utility.get_variable('ZZCUSTOM01');
      rcd_lads_cus_hdr.zzkatr13 := lics_inbound_utility.get_variable('ZZKATR13');
      rcd_lads_cus_hdr.zzkatr14 := lics_inbound_utility.get_variable('ZZKATR14');
      rcd_lads_cus_hdr.j_1kfrepre := lics_inbound_utility.get_variable('J_1KFREPRE');
      rcd_lads_cus_hdr.j_1kftbus := lics_inbound_utility.get_variable('J_1KFTBUS');
      rcd_lads_cus_hdr.j_1kftind := lics_inbound_utility.get_variable('J_1KFTIND');
      rcd_lads_cus_hdr.psois := lics_inbound_utility.get_variable('PSOIS');
      rcd_lads_cus_hdr.katr1 := lics_inbound_utility.get_variable('KATR1');
      rcd_lads_cus_hdr.zzcuststat := lics_inbound_utility.get_variable('ZZCUSTSTAT');
      rcd_lads_cus_hdr.zzretstore := lics_inbound_utility.get_variable('ZZRETSTORE');
      rcd_lads_cus_hdr.locco := lics_inbound_utility.get_variable('LOCCO');
      rcd_lads_cus_hdr.zzdemplan := lics_inbound_utility.get_variable('ZZDEMPLAN');
      rcd_lads_cus_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_cus_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_cus_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_cus_hdr.lads_date := sysdate;
      rcd_lads_cus_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_cus_hth.hthseq := 0;
      rcd_lads_cus_sad.sadseq := 0;
      rcd_lads_cus_cud.cudseq := 0;
      rcd_lads_cus_bnk.bnkseq := 0;
      rcd_lads_cus_unl.unlseq := 0;
      rcd_lads_cus_prp.prpseq := 0;
      rcd_lads_cus_pdp.pdpseq := 0;
      rcd_lads_cus_cnt.cntseq := 0;
      rcd_lads_cus_vat.vatseq := 0;
      rcd_lads_cus_plm.plmseq := 0;
      rcd_lads_cus_mgv.mgvseq := 0;
      rcd_lads_cus_mge.mgeseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_cus_hdr.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.KUNNR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_cus_hdr.kunnr is null) then
         var_exists := true;
         open csr_lads_cus_hdr_01;
         fetch csr_lads_cus_hdr_01 into rcd_lads_cus_hdr_01;
         if csr_lads_cus_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_cus_hdr_01;
         if var_exists = true then
            if rcd_lads_cus_hdr.idoc_timestamp > rcd_lads_cus_hdr_01.idoc_timestamp then
               delete from lads_cus_mge where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_mgv where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_plm where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_vat where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_cnt where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_pdp where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_prp where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_unl where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_bnk where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_ctd where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_cte where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_ctx where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_cud where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_std where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_sat where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_lid where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_stx where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_pfr where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_zsv where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_zsd where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_sad where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_htd where kunnr = rcd_lads_cus_hdr.kunnr;
               delete from lads_cus_hth where kunnr = rcd_lads_cus_hdr.kunnr;
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

      update lads_cus_hdr set
         aufsd = rcd_lads_cus_hdr.aufsd,
         begru = rcd_lads_cus_hdr.begru,
         brsch = rcd_lads_cus_hdr.brsch,
         faksd = rcd_lads_cus_hdr.faksd,
         fiskn = rcd_lads_cus_hdr.fiskn,
         knrza = rcd_lads_cus_hdr.knrza,
         konzs = rcd_lads_cus_hdr.konzs,
         ktokd = rcd_lads_cus_hdr.ktokd,
         kukla = rcd_lads_cus_hdr.kukla,
         lifnr = rcd_lads_cus_hdr.lifnr,
         lifsd = rcd_lads_cus_hdr.lifsd,
         loevm = rcd_lads_cus_hdr.loevm,
         sperr = rcd_lads_cus_hdr.sperr,
         stcd1 = rcd_lads_cus_hdr.stcd1,
         stcd2 = rcd_lads_cus_hdr.stcd2,
         stkza = rcd_lads_cus_hdr.stkza,
         stkzu = rcd_lads_cus_hdr.stkzu,
         xzemp = rcd_lads_cus_hdr.xzemp,
         vbund = rcd_lads_cus_hdr.vbund,
         stceg = rcd_lads_cus_hdr.stceg,
         gform = rcd_lads_cus_hdr.gform,
         umjah = rcd_lads_cus_hdr.umjah,
         uwaer = rcd_lads_cus_hdr.uwaer,
         katr2 = rcd_lads_cus_hdr.katr2,
         katr3 = rcd_lads_cus_hdr.katr3,
         katr4 = rcd_lads_cus_hdr.katr4,
         katr5 = rcd_lads_cus_hdr.katr5,
         katr6 = rcd_lads_cus_hdr.katr6,
         katr7 = rcd_lads_cus_hdr.katr7,
         katr8 = rcd_lads_cus_hdr.katr8,
         katr9 = rcd_lads_cus_hdr.katr9,
         katr10 = rcd_lads_cus_hdr.katr10,
         stkzn = rcd_lads_cus_hdr.stkzn,
         umsa1 = rcd_lads_cus_hdr.umsa1,
         periv = rcd_lads_cus_hdr.periv,
         ktocd = rcd_lads_cus_hdr.ktocd,
         fityp = rcd_lads_cus_hdr.fityp,
         stcdt = rcd_lads_cus_hdr.stcdt,
         stcd3 = rcd_lads_cus_hdr.stcd3,
         stcd4 = rcd_lads_cus_hdr.stcd4,
         cassd = rcd_lads_cus_hdr.cassd,
         kdkg1 = rcd_lads_cus_hdr.kdkg1,
         kdkg2 = rcd_lads_cus_hdr.kdkg2,
         kdkg3 = rcd_lads_cus_hdr.kdkg3,
         kdkg4 = rcd_lads_cus_hdr.kdkg4,
         kdkg5 = rcd_lads_cus_hdr.kdkg5,
         nodel = rcd_lads_cus_hdr.nodel,
         xsub2 = rcd_lads_cus_hdr.xsub2,
         werks = rcd_lads_cus_hdr.werks,
         zzcustom01 = rcd_lads_cus_hdr.zzcustom01,
         zzkatr13 = rcd_lads_cus_hdr.zzkatr13,
         zzkatr14 = rcd_lads_cus_hdr.zzkatr14,
         j_1kfrepre = rcd_lads_cus_hdr.j_1kfrepre,
         j_1kftbus = rcd_lads_cus_hdr.j_1kftbus,
         j_1kftind = rcd_lads_cus_hdr.j_1kftind,
         psois = rcd_lads_cus_hdr.psois,
         katr1 = rcd_lads_cus_hdr.katr1,
         zzcuststat = rcd_lads_cus_hdr.zzcuststat,
         zzretstore = rcd_lads_cus_hdr.zzretstore,
         locco = rcd_lads_cus_hdr.locco,
         zzdemplan = rcd_lads_cus_hdr.zzdemplan,
         idoc_name = rcd_lads_cus_hdr.idoc_name,
         idoc_number = rcd_lads_cus_hdr.idoc_number,
         idoc_timestamp = rcd_lads_cus_hdr.idoc_timestamp,
         lads_date = rcd_lads_cus_hdr.lads_date,
         lads_status = rcd_lads_cus_hdr.lads_status
      where kunnr = rcd_lads_cus_hdr.kunnr;
      if sql%notfound then
         insert into lads_cus_hdr
            (kunnr,
             aufsd,
             begru,
             brsch,
             faksd,
             fiskn,
             knrza,
             konzs,
             ktokd,
             kukla,
             lifnr,
             lifsd,
             loevm,
             sperr,
             stcd1,
             stcd2,
             stkza,
             stkzu,
             xzemp,
             vbund,
             stceg,
             gform,
             umjah,
             uwaer,
             katr2,
             katr3,
             katr4,
             katr5,
             katr6,
             katr7,
             katr8,
             katr9,
             katr10,
             stkzn,
             umsa1,
             periv,
             ktocd,
             fityp,
             stcdt,
             stcd3,
             stcd4,
             cassd,
             kdkg1,
             kdkg2,
             kdkg3,
             kdkg4,
             kdkg5,
             nodel,
             xsub2,
             werks,
             zzcustom01,
             zzkatr13,
             zzkatr14,
             j_1kfrepre,
             j_1kftbus,
             j_1kftind,
             psois,
             katr1,
             zzcuststat,
             zzretstore,
             locco,
             zzdemplan,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_cus_hdr.kunnr,
             rcd_lads_cus_hdr.aufsd,
             rcd_lads_cus_hdr.begru,
             rcd_lads_cus_hdr.brsch,
             rcd_lads_cus_hdr.faksd,
             rcd_lads_cus_hdr.fiskn,
             rcd_lads_cus_hdr.knrza,
             rcd_lads_cus_hdr.konzs,
             rcd_lads_cus_hdr.ktokd,
             rcd_lads_cus_hdr.kukla,
             rcd_lads_cus_hdr.lifnr,
             rcd_lads_cus_hdr.lifsd,
             rcd_lads_cus_hdr.loevm,
             rcd_lads_cus_hdr.sperr,
             rcd_lads_cus_hdr.stcd1,
             rcd_lads_cus_hdr.stcd2,
             rcd_lads_cus_hdr.stkza,
             rcd_lads_cus_hdr.stkzu,
             rcd_lads_cus_hdr.xzemp,
             rcd_lads_cus_hdr.vbund,
             rcd_lads_cus_hdr.stceg,
             rcd_lads_cus_hdr.gform,
             rcd_lads_cus_hdr.umjah,
             rcd_lads_cus_hdr.uwaer,
             rcd_lads_cus_hdr.katr2,
             rcd_lads_cus_hdr.katr3,
             rcd_lads_cus_hdr.katr4,
             rcd_lads_cus_hdr.katr5,
             rcd_lads_cus_hdr.katr6,
             rcd_lads_cus_hdr.katr7,
             rcd_lads_cus_hdr.katr8,
             rcd_lads_cus_hdr.katr9,
             rcd_lads_cus_hdr.katr10,
             rcd_lads_cus_hdr.stkzn,
             rcd_lads_cus_hdr.umsa1,
             rcd_lads_cus_hdr.periv,
             rcd_lads_cus_hdr.ktocd,
             rcd_lads_cus_hdr.fityp,
             rcd_lads_cus_hdr.stcdt,
             rcd_lads_cus_hdr.stcd3,
             rcd_lads_cus_hdr.stcd4,
             rcd_lads_cus_hdr.cassd,
             rcd_lads_cus_hdr.kdkg1,
             rcd_lads_cus_hdr.kdkg2,
             rcd_lads_cus_hdr.kdkg3,
             rcd_lads_cus_hdr.kdkg4,
             rcd_lads_cus_hdr.kdkg5,
             rcd_lads_cus_hdr.nodel,
             rcd_lads_cus_hdr.xsub2,
             rcd_lads_cus_hdr.werks,
             rcd_lads_cus_hdr.zzcustom01,
             rcd_lads_cus_hdr.zzkatr13,
             rcd_lads_cus_hdr.zzkatr14,
             rcd_lads_cus_hdr.j_1kfrepre,
             rcd_lads_cus_hdr.j_1kftbus,
             rcd_lads_cus_hdr.j_1kftind,
             rcd_lads_cus_hdr.psois,
             rcd_lads_cus_hdr.katr1,
             rcd_lads_cus_hdr.zzcuststat,
             rcd_lads_cus_hdr.zzretstore,
             rcd_lads_cus_hdr.locco,
             rcd_lads_cus_hdr.zzdemplan,
             rcd_lads_cus_hdr.idoc_name,
             rcd_lads_cus_hdr.idoc_number,
             rcd_lads_cus_hdr.idoc_timestamp,
             rcd_lads_cus_hdr.lads_date,
             rcd_lads_cus_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record HTH routine */
   /**************************************************/
   procedure process_record_hth(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HTH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_hth.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_hth.hthseq := rcd_lads_cus_hth.hthseq + 1;
      rcd_lads_cus_hth.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_cus_hth.tdname := lics_inbound_utility.get_variable('TDNAME');
      rcd_lads_cus_hth.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_cus_hth.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_cus_hth.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_cus_hth.tdsprasiso := lics_inbound_utility.get_variable('TDSPRASISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_cus_htd.htdseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_cus_hth.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HTH.KUNNR');
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

      insert into lads_cus_hth
         (kunnr,
          hthseq,
          tdobject,
          tdname,
          tdid,
          tdspras,
          tdtexttype,
          tdsprasiso)
      values
         (rcd_lads_cus_hth.kunnr,
          rcd_lads_cus_hth.hthseq,
          rcd_lads_cus_hth.tdobject,
          rcd_lads_cus_hth.tdname,
          rcd_lads_cus_hth.tdid,
          rcd_lads_cus_hth.tdspras,
          rcd_lads_cus_hth.tdtexttype,
          rcd_lads_cus_hth.tdsprasiso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hth;

   /**************************************************/
   /* This procedure performs the record HTD routine */
   /**************************************************/
   procedure process_record_htd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HTD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_htd.kunnr := rcd_lads_cus_hth.kunnr;
      rcd_lads_cus_htd.hthseq := rcd_lads_cus_hth.hthseq;
      rcd_lads_cus_htd.htdseq := rcd_lads_cus_htd.htdseq + 1;
      rcd_lads_cus_htd.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_cus_htd.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_cus_htd.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HTD.KUNNR');
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

      insert into lads_cus_htd
         (kunnr,
          hthseq,
          htdseq,
          tdformat,
          tdline)
      values
         (rcd_lads_cus_htd.kunnr,
          rcd_lads_cus_htd.hthseq,
          rcd_lads_cus_htd.htdseq,
          rcd_lads_cus_htd.tdformat,
          rcd_lads_cus_htd.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_htd;

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
      rcd_lads_cus_sad.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_sad.sadseq := rcd_lads_cus_sad.sadseq + 1;
      rcd_lads_cus_sad.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_cus_sad.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_lads_cus_sad.spart := lics_inbound_utility.get_variable('SPART');
      rcd_lads_cus_sad.begru := lics_inbound_utility.get_variable('BEGRU');
      rcd_lads_cus_sad.loevm := lics_inbound_utility.get_variable('LOEVM');
      rcd_lads_cus_sad.versg := lics_inbound_utility.get_variable('VERSG');
      rcd_lads_cus_sad.aufsd := lics_inbound_utility.get_variable('AUFSD');
      rcd_lads_cus_sad.kalks := lics_inbound_utility.get_variable('KALKS');
      rcd_lads_cus_sad.kdgrp := lics_inbound_utility.get_variable('KDGRP');
      rcd_lads_cus_sad.bzirk := lics_inbound_utility.get_variable('BZIRK');
      rcd_lads_cus_sad.konda := lics_inbound_utility.get_variable('KONDA');
      rcd_lads_cus_sad.pltyp := lics_inbound_utility.get_variable('PLTYP');
      rcd_lads_cus_sad.awahr := lics_inbound_utility.get_number('AWAHR',null);
      rcd_lads_cus_sad.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_lads_cus_sad.inco2 := lics_inbound_utility.get_variable('INCO2');
      rcd_lads_cus_sad.lifsd := lics_inbound_utility.get_variable('LIFSD');
      rcd_lads_cus_sad.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_lads_cus_sad.antlf := lics_inbound_utility.get_number('ANTLF',null);
      rcd_lads_cus_sad.kztlf := lics_inbound_utility.get_variable('KZTLF');
      rcd_lads_cus_sad.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_cus_sad.chspl := lics_inbound_utility.get_variable('CHSPL');
      rcd_lads_cus_sad.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_lads_cus_sad.eikto := lics_inbound_utility.get_variable('EIKTO');
      rcd_lads_cus_sad.vsbed := lics_inbound_utility.get_variable('VSBED');
      rcd_lads_cus_sad.faksd := lics_inbound_utility.get_variable('FAKSD');
      rcd_lads_cus_sad.mrnkz := lics_inbound_utility.get_variable('MRNKZ');
      rcd_lads_cus_sad.perfk := lics_inbound_utility.get_variable('PERFK');
      rcd_lads_cus_sad.perrl := lics_inbound_utility.get_variable('PERRL');
      rcd_lads_cus_sad.waers := lics_inbound_utility.get_variable('WAERS');
      rcd_lads_cus_sad.ktgrd := lics_inbound_utility.get_variable('KTGRD');
      rcd_lads_cus_sad.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_cus_sad.vwerk := lics_inbound_utility.get_variable('VWERK');
      rcd_lads_cus_sad.vkgrp := lics_inbound_utility.get_variable('VKGRP');
      rcd_lads_cus_sad.vkbur := lics_inbound_utility.get_variable('VKBUR');
      rcd_lads_cus_sad.vsort := lics_inbound_utility.get_variable('VSORT');
      rcd_lads_cus_sad.kvgr1 := lics_inbound_utility.get_variable('KVGR1');
      rcd_lads_cus_sad.kvgr2 := lics_inbound_utility.get_variable('KVGR2');
      rcd_lads_cus_sad.kvgr3 := lics_inbound_utility.get_variable('KVGR3');
      rcd_lads_cus_sad.kvgr4 := lics_inbound_utility.get_variable('KVGR4');
      rcd_lads_cus_sad.kvgr5 := lics_inbound_utility.get_variable('KVGR5');
      rcd_lads_cus_sad.bokre := lics_inbound_utility.get_variable('BOKRE');
      rcd_lads_cus_sad.kurst := lics_inbound_utility.get_variable('KURST');
      rcd_lads_cus_sad.prfre := lics_inbound_utility.get_variable('PRFRE');
      rcd_lads_cus_sad.klabc := lics_inbound_utility.get_variable('KLABC');
      rcd_lads_cus_sad.kabss := lics_inbound_utility.get_variable('KABSS');
      rcd_lads_cus_sad.kkber := lics_inbound_utility.get_variable('KKBER');
      rcd_lads_cus_sad.cassd := lics_inbound_utility.get_variable('CASSD');
      rcd_lads_cus_sad.rdoff := lics_inbound_utility.get_variable('RDOFF');
      rcd_lads_cus_sad.agrel := lics_inbound_utility.get_variable('AGREL');
      rcd_lads_cus_sad.megru := lics_inbound_utility.get_variable('MEGRU');
      rcd_lads_cus_sad.uebto := lics_inbound_utility.get_variable('UEBTO');
      rcd_lads_cus_sad.untto := lics_inbound_utility.get_variable('UNTTO');
      rcd_lads_cus_sad.uebtk := lics_inbound_utility.get_variable('UEBTK');
      rcd_lads_cus_sad.pvksm := lics_inbound_utility.get_variable('PVKSM');
      rcd_lads_cus_sad.podkz := lics_inbound_utility.get_variable('PODKZ');
      rcd_lads_cus_sad.podtg := lics_inbound_utility.get_variable('PODTG');
      rcd_lads_cus_sad.blind := lics_inbound_utility.get_variable('BLIND');
      rcd_lads_cus_sad.zzshelfgrp := lics_inbound_utility.get_number('ZZSHELFGRP',null);
      rcd_lads_cus_sad.zzvmicdim := lics_inbound_utility.get_number('ZZVMICDIM',null);
      rcd_lads_cus_sad.zzcurrentflag := lics_inbound_utility.get_variable('ZZCURRENTFLAG');
      rcd_lads_cus_sad.zzfutureflag := lics_inbound_utility.get_variable('ZZFUTUREFLAG');
      rcd_lads_cus_sad.zzmarketacctflag := lics_inbound_utility.get_variable('ZZMARKETACCTFLAG');
      rcd_lads_cus_sad.zzcspiv := lics_inbound_utility.get_variable('ZZCSPIV');
      rcd_lads_cus_sad.zzcmph := lics_inbound_utility.get_number('ZZCMPH',null);
      rcd_lads_cus_sad.zzcmph_uom := lics_inbound_utility.get_variable('ZZCMPH_UOM');
      rcd_lads_cus_sad.zzhppl := lics_inbound_utility.get_variable('ZZHPPL');
      rcd_lads_cus_sad.zzhppc := lics_inbound_utility.get_variable('ZZHPPC');
      rcd_lads_cus_sad.zztmr := lics_inbound_utility.get_variable('ZZTMR');
      rcd_lads_cus_sad.zzpppm := lics_inbound_utility.get_variable('ZZPPPM');
      rcd_lads_cus_sad.zzmpph  := lics_inbound_utility.get_number('ZZMPPH',null);
      rcd_lads_cus_sad.zzmpph_uom := lics_inbound_utility.get_variable('ZZMPPH_UOM');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_cus_zsd.zsdseq := 0;
      rcd_lads_cus_zsv.zsvseq := 0;
      rcd_lads_cus_pfr.pfrseq := 0;
      rcd_lads_cus_stx.stxseq := 0;
      rcd_lads_cus_lid.lidseq := 0;
      rcd_lads_cus_sat.satseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_cus_sad.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - SAD.KUNNR');
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

      insert into lads_cus_sad
         (kunnr,
          sadseq,
          vkorg,
          vtweg,
          spart,
          begru,
          loevm,
          versg,
          aufsd,
          kalks,
          kdgrp,
          bzirk,
          konda,
          pltyp,
          awahr,
          inco1,
          inco2,
          lifsd,
          autlf,
          antlf,
          kztlf,
          kzazu,
          chspl,
          lprio,
          eikto,
          vsbed,
          faksd,
          mrnkz,
          perfk,
          perrl,
          waers,
          ktgrd,
          zterm,
          vwerk,
          vkgrp,
          vkbur,
          vsort,
          kvgr1,
          kvgr2,
          kvgr3,
          kvgr4,
          kvgr5,
          bokre,
          kurst,
          prfre,
          klabc,
          kabss,
          kkber,
          cassd,
          rdoff,
          agrel,
          megru,
          uebto,
          untto,
          uebtk,
          pvksm,
          podkz,
          podtg,
          blind,
          zzshelfgrp,
          zzvmicdim,
          zzcurrentflag,
          zzfutureflag,
          zzmarketacctflag,
          zzcspiv,
          zzcmph,
          zzcmph_uom,
          zzhppl,
          zzhppc,
          zztmr,
          zzpppm,
          zzmpph,
          zzmpph_uom)
      values
         (rcd_lads_cus_sad.kunnr,
          rcd_lads_cus_sad.sadseq,
          rcd_lads_cus_sad.vkorg,
          rcd_lads_cus_sad.vtweg,
          rcd_lads_cus_sad.spart,
          rcd_lads_cus_sad.begru,
          rcd_lads_cus_sad.loevm,
          rcd_lads_cus_sad.versg,
          rcd_lads_cus_sad.aufsd,
          rcd_lads_cus_sad.kalks,
          rcd_lads_cus_sad.kdgrp,
          rcd_lads_cus_sad.bzirk,
          rcd_lads_cus_sad.konda,
          rcd_lads_cus_sad.pltyp,
          rcd_lads_cus_sad.awahr,
          rcd_lads_cus_sad.inco1,
          rcd_lads_cus_sad.inco2,
          rcd_lads_cus_sad.lifsd,
          rcd_lads_cus_sad.autlf,
          rcd_lads_cus_sad.antlf,
          rcd_lads_cus_sad.kztlf,
          rcd_lads_cus_sad.kzazu,
          rcd_lads_cus_sad.chspl,
          rcd_lads_cus_sad.lprio,
          rcd_lads_cus_sad.eikto,
          rcd_lads_cus_sad.vsbed,
          rcd_lads_cus_sad.faksd,
          rcd_lads_cus_sad.mrnkz,
          rcd_lads_cus_sad.perfk,
          rcd_lads_cus_sad.perrl,
          rcd_lads_cus_sad.waers,
          rcd_lads_cus_sad.ktgrd,
          rcd_lads_cus_sad.zterm,
          rcd_lads_cus_sad.vwerk,
          rcd_lads_cus_sad.vkgrp,
          rcd_lads_cus_sad.vkbur,
          rcd_lads_cus_sad.vsort,
          rcd_lads_cus_sad.kvgr1,
          rcd_lads_cus_sad.kvgr2,
          rcd_lads_cus_sad.kvgr3,
          rcd_lads_cus_sad.kvgr4,
          rcd_lads_cus_sad.kvgr5,
          rcd_lads_cus_sad.bokre,
          rcd_lads_cus_sad.kurst,
          rcd_lads_cus_sad.prfre,
          rcd_lads_cus_sad.klabc,
          rcd_lads_cus_sad.kabss,
          rcd_lads_cus_sad.kkber,
          rcd_lads_cus_sad.cassd,
          rcd_lads_cus_sad.rdoff,
          rcd_lads_cus_sad.agrel,
          rcd_lads_cus_sad.megru,
          rcd_lads_cus_sad.uebto,
          rcd_lads_cus_sad.untto,
          rcd_lads_cus_sad.uebtk,
          rcd_lads_cus_sad.pvksm,
          rcd_lads_cus_sad.podkz,
          rcd_lads_cus_sad.podtg,
          rcd_lads_cus_sad.blind,
          rcd_lads_cus_sad.zzshelfgrp,
          rcd_lads_cus_sad.zzvmicdim,
          rcd_lads_cus_sad.zzcurrentflag,
          rcd_lads_cus_sad.zzfutureflag,
          rcd_lads_cus_sad.zzmarketacctflag,
          rcd_lads_cus_sad.zzcspiv,
          rcd_lads_cus_sad.zzcmph,
          rcd_lads_cus_sad.zzcmph_uom,
          rcd_lads_cus_sad.zzhppl,
          rcd_lads_cus_sad.zzhppc,
          rcd_lads_cus_sad.zztmr,
          rcd_lads_cus_sad.zzpppm,
          rcd_lads_cus_sad.zzmpph,
          rcd_lads_cus_sad.zzmpph_uom);

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
      rcd_lads_cus_zsd.kunnr := rcd_lads_cus_sad.kunnr;
      rcd_lads_cus_zsd.sadseq := rcd_lads_cus_sad.sadseq;
      rcd_lads_cus_zsd.zsdseq := rcd_lads_cus_zsd.zsdseq + 1;
      rcd_lads_cus_zsd.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_cus_zsd.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_lads_cus_zsd.spart := lics_inbound_utility.get_variable('SPART');
      rcd_lads_cus_zsd.vmict := lics_inbound_utility.get_number('VMICT',null);

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
      if rcd_lads_cus_zsd.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ZSD.KUNNR');
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

      insert into lads_cus_zsd
         (kunnr,
          sadseq,
          zsdseq,
          vkorg,
          vtweg,
          spart,
          vmict)
      values
         (rcd_lads_cus_zsd.kunnr,
          rcd_lads_cus_zsd.sadseq,
          rcd_lads_cus_zsd.zsdseq,
          rcd_lads_cus_zsd.vkorg,
          rcd_lads_cus_zsd.vtweg,
          rcd_lads_cus_zsd.spart,
          rcd_lads_cus_zsd.vmict);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_zsd;

   /**************************************************/
   /* This procedure performs the record ZSV routine */
   /**************************************************/
   procedure process_record_zsv(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ZSV', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_zsv.kunnr := rcd_lads_cus_sad.kunnr;
      rcd_lads_cus_zsv.sadseq := rcd_lads_cus_sad.sadseq;
      rcd_lads_cus_zsv.zsvseq := rcd_lads_cus_zsv.zsvseq + 1;
      rcd_lads_cus_zsv.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_cus_zsv.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_lads_cus_zsv.spart := lics_inbound_utility.get_variable('SPART');
      rcd_lads_cus_zsv.vmifds := lics_inbound_utility.get_number('VMIFDS',null);

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
      if rcd_lads_cus_zsv.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ZSV.KUNNR');
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

      insert into lads_cus_zsv
         (kunnr,
          sadseq,
          zsvseq,
          vkorg,
          vtweg,
          spart,
          vmifds)
      values
         (rcd_lads_cus_zsv.kunnr,
          rcd_lads_cus_zsv.sadseq,
          rcd_lads_cus_zsv.zsvseq,
          rcd_lads_cus_zsv.vkorg,
          rcd_lads_cus_zsv.vtweg,
          rcd_lads_cus_zsv.spart,
          rcd_lads_cus_zsv.vmifds);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_zsv;

   /**************************************************/
   /* This procedure performs the record PFR routine */
   /**************************************************/
   procedure process_record_pfr(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PFR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_pfr.kunnr := rcd_lads_cus_sad.kunnr;
      rcd_lads_cus_pfr.sadseq := rcd_lads_cus_sad.sadseq;
      rcd_lads_cus_pfr.pfrseq := rcd_lads_cus_pfr.pfrseq + 1;
      rcd_lads_cus_pfr.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_cus_pfr.kunn2 := lics_inbound_utility.get_variable('KUNN2');
      rcd_lads_cus_pfr.defpa := lics_inbound_utility.get_variable('DEFPA');
      rcd_lads_cus_pfr.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_cus_pfr.parza := lics_inbound_utility.get_number('PARZA',null);
      rcd_lads_cus_pfr.zz_parvw_txt := lics_inbound_utility.get_variable('ZZ_PARVW_TXT');
      rcd_lads_cus_pfr.zz_partn_nam := lics_inbound_utility.get_variable('ZZ_PARTN_NAM');
      rcd_lads_cus_pfr.zz_partn_nachn := lics_inbound_utility.get_variable('ZZ_PARTN_NACHN');
      rcd_lads_cus_pfr.zz_partn_vorna := lics_inbound_utility.get_variable('ZZ_PARTN_VORNA');

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
      if rcd_lads_cus_pfr.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PFR.KUNNR');
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

      insert into lads_cus_pfr
         (kunnr,
          sadseq,
          pfrseq,
          parvw,
          kunn2,
          defpa,
          knref,
          parza,
          zz_parvw_txt,
          zz_partn_nam,
          zz_partn_nachn,
          zz_partn_vorna)
      values
         (rcd_lads_cus_pfr.kunnr,
          rcd_lads_cus_pfr.sadseq,
          rcd_lads_cus_pfr.pfrseq,
          rcd_lads_cus_pfr.parvw,
          rcd_lads_cus_pfr.kunn2,
          rcd_lads_cus_pfr.defpa,
          rcd_lads_cus_pfr.knref,
          rcd_lads_cus_pfr.parza,
          rcd_lads_cus_pfr.zz_parvw_txt,
          rcd_lads_cus_pfr.zz_partn_nam,
          rcd_lads_cus_pfr.zz_partn_nachn,
          rcd_lads_cus_pfr.zz_partn_vorna);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pfr;

   /**************************************************/
   /* This procedure performs the record STX routine */
   /**************************************************/
   procedure process_record_stx(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('STX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_stx.kunnr := rcd_lads_cus_sad.kunnr;
      rcd_lads_cus_stx.sadseq := rcd_lads_cus_sad.sadseq;
      rcd_lads_cus_stx.stxseq := rcd_lads_cus_stx.stxseq + 1;
      rcd_lads_cus_stx.aland := lics_inbound_utility.get_variable('ALAND');
      rcd_lads_cus_stx.tatyp := lics_inbound_utility.get_variable('TATYP');
      rcd_lads_cus_stx.taxkd := lics_inbound_utility.get_variable('TAXKD');

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
      if rcd_lads_cus_stx.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - STX.KUNNR');
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

      insert into lads_cus_stx
         (kunnr,
          sadseq,
          stxseq,
          aland,
          tatyp,
          taxkd)
      values
         (rcd_lads_cus_stx.kunnr,
          rcd_lads_cus_stx.sadseq,
          rcd_lads_cus_stx.stxseq,
          rcd_lads_cus_stx.aland,
          rcd_lads_cus_stx.tatyp,
          rcd_lads_cus_stx.taxkd);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_stx;

   /**************************************************/
   /* This procedure performs the record LID routine */
   /**************************************************/
   procedure process_record_lid(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('LID', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_lid.kunnr := rcd_lads_cus_sad.kunnr;
      rcd_lads_cus_lid.sadseq := rcd_lads_cus_sad.sadseq;
      rcd_lads_cus_lid.lidseq := rcd_lads_cus_lid.lidseq + 1;
      rcd_lads_cus_lid.aland := lics_inbound_utility.get_variable('ALAND');
      rcd_lads_cus_lid.tatyp := lics_inbound_utility.get_variable('TATYP');
      rcd_lads_cus_lid.licnr := lics_inbound_utility.get_variable('LICNR');
      rcd_lads_cus_lid.datab := lics_inbound_utility.get_variable('DATAB');
      rcd_lads_cus_lid.datbi := lics_inbound_utility.get_variable('DATBI');
      rcd_lads_cus_lid.belic := lics_inbound_utility.get_variable('BELIC');

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
      if rcd_lads_cus_lid.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LID.KUNNR');
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

      insert into lads_cus_lid
         (kunnr,
          sadseq,
          lidseq,
          aland,
          tatyp,
          licnr,
          datab,
          datbi,
          belic)
      values
         (rcd_lads_cus_lid.kunnr,
          rcd_lads_cus_lid.sadseq,
          rcd_lads_cus_lid.lidseq,
          rcd_lads_cus_lid.aland,
          rcd_lads_cus_lid.tatyp,
          rcd_lads_cus_lid.licnr,
          rcd_lads_cus_lid.datab,
          rcd_lads_cus_lid.datbi,
          rcd_lads_cus_lid.belic);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_lid;

   /**************************************************/
   /* This procedure performs the record SAT routine */
   /**************************************************/
   procedure process_record_sat(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SAT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_sat.kunnr := rcd_lads_cus_sad.kunnr;
      rcd_lads_cus_sat.sadseq := rcd_lads_cus_sad.sadseq;
      rcd_lads_cus_sat.satseq := rcd_lads_cus_sat.satseq + 1;
      rcd_lads_cus_sat.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_cus_sat.tdname := lics_inbound_utility.get_variable('TDNAME');
      rcd_lads_cus_sat.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_cus_sat.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_cus_sat.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_cus_sat.tdsprasiso := lics_inbound_utility.get_variable('TDSPRASISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_cus_std.stdseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_cus_sat.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - SAT.KUNNR');
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

      insert into lads_cus_sat
         (kunnr,
          sadseq,
          satseq,
          tdobject,
          tdname,
          tdid,
          tdspras,
          tdtexttype,
          tdsprasiso)
      values
         (rcd_lads_cus_sat.kunnr,
          rcd_lads_cus_sat.sadseq,
          rcd_lads_cus_sat.satseq,
          rcd_lads_cus_sat.tdobject,
          rcd_lads_cus_sat.tdname,
          rcd_lads_cus_sat.tdid,
          rcd_lads_cus_sat.tdspras,
          rcd_lads_cus_sat.tdtexttype,
          rcd_lads_cus_sat.tdsprasiso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_sat;

   /**************************************************/
   /* This procedure performs the record STD routine */
   /**************************************************/
   procedure process_record_std(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('STD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_std.kunnr := rcd_lads_cus_sat.kunnr;
      rcd_lads_cus_std.sadseq := rcd_lads_cus_sat.sadseq;
      rcd_lads_cus_std.satseq := rcd_lads_cus_sat.satseq;
      rcd_lads_cus_std.stdseq := rcd_lads_cus_std.stdseq + 1;
      rcd_lads_cus_std.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_cus_std.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_cus_std.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - STD.KUNNR');
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

      insert into lads_cus_std
         (kunnr,
          sadseq,
          satseq,
          stdseq,
          tdformat,
          tdline)
      values
         (rcd_lads_cus_std.kunnr,
          rcd_lads_cus_std.sadseq,
          rcd_lads_cus_std.satseq,
          rcd_lads_cus_std.stdseq,
          rcd_lads_cus_std.tdformat,
          rcd_lads_cus_std.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_std;

   /**************************************************/
   /* This procedure performs the record CUD routine */
   /**************************************************/
   procedure process_record_cud(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CUD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_cud.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_cud.cudseq := rcd_lads_cus_cud.cudseq + 1;
      rcd_lads_cus_cud.bukrs := lics_inbound_utility.get_variable('BUKRS');
      rcd_lads_cus_cud.sperr := lics_inbound_utility.get_variable('SPERR');
      rcd_lads_cus_cud.loevm := lics_inbound_utility.get_variable('LOEVM');
      rcd_lads_cus_cud.zuawa := lics_inbound_utility.get_variable('ZUAWA');
      rcd_lads_cus_cud.busab := lics_inbound_utility.get_variable('BUSAB');
      rcd_lads_cus_cud.akont := lics_inbound_utility.get_variable('AKONT');
      rcd_lads_cus_cud.begru := lics_inbound_utility.get_variable('BEGRU');
      rcd_lads_cus_cud.knrze := lics_inbound_utility.get_variable('KNRZE');
      rcd_lads_cus_cud.knrzb := lics_inbound_utility.get_variable('KNRZB');
      rcd_lads_cus_cud.zamim := lics_inbound_utility.get_variable('ZAMIM');
      rcd_lads_cus_cud.zamiv := lics_inbound_utility.get_variable('ZAMIV');
      rcd_lads_cus_cud.zamir := lics_inbound_utility.get_variable('ZAMIR');
      rcd_lads_cus_cud.zamib := lics_inbound_utility.get_variable('ZAMIB');
      rcd_lads_cus_cud.zamio := lics_inbound_utility.get_variable('ZAMIO');
      rcd_lads_cus_cud.zwels := lics_inbound_utility.get_variable('ZWELS');
      rcd_lads_cus_cud.xverr := lics_inbound_utility.get_variable('XVERR');
      rcd_lads_cus_cud.zahls := lics_inbound_utility.get_variable('ZAHLS');
      rcd_lads_cus_cud.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_cus_cud.wakon := lics_inbound_utility.get_variable('WAKON');
      rcd_lads_cus_cud.vzskz := lics_inbound_utility.get_variable('VZSKZ');
      rcd_lads_cus_cud.zindt := lics_inbound_utility.get_variable('ZINDT');
      rcd_lads_cus_cud.zinrt := lics_inbound_utility.get_number('ZINRT',null);
      rcd_lads_cus_cud.eikto := lics_inbound_utility.get_variable('EIKTO');
      rcd_lads_cus_cud.zsabe := lics_inbound_utility.get_variable('ZSABE');
      rcd_lads_cus_cud.kverm := lics_inbound_utility.get_variable('KVERM');
      rcd_lads_cus_cud.fdgrv := lics_inbound_utility.get_variable('FDGRV');
      rcd_lads_cus_cud.vrbkz := lics_inbound_utility.get_variable('VRBKZ');
      rcd_lads_cus_cud.vlibb := lics_inbound_utility.get_number('VLIBB',null);
      rcd_lads_cus_cud.vrszl := lics_inbound_utility.get_number('VRSZL',null);
      rcd_lads_cus_cud.vrspr := lics_inbound_utility.get_number('VRSPR',null);
      rcd_lads_cus_cud.vrsnr := lics_inbound_utility.get_variable('VRSNR');
      rcd_lads_cus_cud.verdt := lics_inbound_utility.get_variable('VERDT');
      rcd_lads_cus_cud.perkz := lics_inbound_utility.get_variable('PERKZ');
      rcd_lads_cus_cud.xdezv := lics_inbound_utility.get_variable('XDEZV');
      rcd_lads_cus_cud.xausz := lics_inbound_utility.get_variable('XAUSZ');
      rcd_lads_cus_cud.webtr := lics_inbound_utility.get_number('WEBTR',null);
      rcd_lads_cus_cud.remit := lics_inbound_utility.get_variable('REMIT');
      rcd_lads_cus_cud.datlz := lics_inbound_utility.get_variable('DATLZ');
      rcd_lads_cus_cud.xzver := lics_inbound_utility.get_variable('XZVER');
      rcd_lads_cus_cud.togru := lics_inbound_utility.get_variable('TOGRU');
      rcd_lads_cus_cud.kultg := lics_inbound_utility.get_number('KULTG',null);
      rcd_lads_cus_cud.hbkid := lics_inbound_utility.get_variable('HBKID');
      rcd_lads_cus_cud.xpore := lics_inbound_utility.get_variable('XPORE');
      rcd_lads_cus_cud.blnkz := lics_inbound_utility.get_variable('BLNKZ');
      rcd_lads_cus_cud.altkn := lics_inbound_utility.get_variable('ALTKN');
      rcd_lads_cus_cud.zgrup := lics_inbound_utility.get_variable('ZGRUP');
      rcd_lads_cus_cud.urlid := lics_inbound_utility.get_variable('URLID');
      rcd_lads_cus_cud.mgrup := lics_inbound_utility.get_variable('MGRUP');
      rcd_lads_cus_cud.lockb := lics_inbound_utility.get_variable('LOCKB');
      rcd_lads_cus_cud.uzawe := lics_inbound_utility.get_variable('UZAWE');
      rcd_lads_cus_cud.ekvbd := lics_inbound_utility.get_variable('EKVBD');
      rcd_lads_cus_cud.sregl := lics_inbound_utility.get_variable('SREGL');
      rcd_lads_cus_cud.xedip := lics_inbound_utility.get_variable('XEDIP');
      rcd_lads_cus_cud.frgrp := lics_inbound_utility.get_variable('FRGRP');
      rcd_lads_cus_cud.vrsdg := lics_inbound_utility.get_variable('VRSDG');
      rcd_lads_cus_cud.tlfxs := lics_inbound_utility.get_variable('TLFXS');
      rcd_lads_cus_cud.pernr := lics_inbound_utility.get_number('PERNR',null);
      rcd_lads_cus_cud.intad := lics_inbound_utility.get_variable('INTAD');
      rcd_lads_cus_cud.guzte := lics_inbound_utility.get_variable('GUZTE');
      rcd_lads_cus_cud.gricd := lics_inbound_utility.get_variable('GRICD');
      rcd_lads_cus_cud.gridt := lics_inbound_utility.get_variable('GRIDT');
      rcd_lads_cus_cud.wbrsl := lics_inbound_utility.get_variable('WBRSL');
      rcd_lads_cus_cud.nodel := lics_inbound_utility.get_variable('NODEL');
      rcd_lads_cus_cud.tlfns := lics_inbound_utility.get_variable('TLFNS');
      rcd_lads_cus_cud.cession_kz := lics_inbound_utility.get_variable('CESSION_KZ');
      rcd_lads_cus_cud.gmvkzd := lics_inbound_utility.get_variable('GMVKZD');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_cus_ctx.ctxseq := 0;
      rcd_lads_cus_cte.cteseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_cus_cud.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CUD.KUNNR');
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

      insert into lads_cus_cud
         (kunnr,
          cudseq,
          bukrs,
          sperr,
          loevm,
          zuawa,
          busab,
          akont,
          begru,
          knrze,
          knrzb,
          zamim,
          zamiv,
          zamir,
          zamib,
          zamio,
          zwels,
          xverr,
          zahls,
          zterm,
          wakon,
          vzskz,
          zindt,
          zinrt,
          eikto,
          zsabe,
          kverm,
          fdgrv,
          vrbkz,
          vlibb,
          vrszl,
          vrspr,
          vrsnr,
          verdt,
          perkz,
          xdezv,
          xausz,
          webtr,
          remit,
          datlz,
          xzver,
          togru,
          kultg,
          hbkid,
          xpore,
          blnkz,
          altkn,
          zgrup,
          urlid,
          mgrup,
          lockb,
          uzawe,
          ekvbd,
          sregl,
          xedip,
          frgrp,
          vrsdg,
          tlfxs,
          pernr,
          intad,
          guzte,
          gricd,
          gridt,
          wbrsl,
          nodel,
          tlfns,
          cession_kz,
          gmvkzd)
      values
         (rcd_lads_cus_cud.kunnr,
          rcd_lads_cus_cud.cudseq,
          rcd_lads_cus_cud.bukrs,
          rcd_lads_cus_cud.sperr,
          rcd_lads_cus_cud.loevm,
          rcd_lads_cus_cud.zuawa,
          rcd_lads_cus_cud.busab,
          rcd_lads_cus_cud.akont,
          rcd_lads_cus_cud.begru,
          rcd_lads_cus_cud.knrze,
          rcd_lads_cus_cud.knrzb,
          rcd_lads_cus_cud.zamim,
          rcd_lads_cus_cud.zamiv,
          rcd_lads_cus_cud.zamir,
          rcd_lads_cus_cud.zamib,
          rcd_lads_cus_cud.zamio,
          rcd_lads_cus_cud.zwels,
          rcd_lads_cus_cud.xverr,
          rcd_lads_cus_cud.zahls,
          rcd_lads_cus_cud.zterm,
          rcd_lads_cus_cud.wakon,
          rcd_lads_cus_cud.vzskz,
          rcd_lads_cus_cud.zindt,
          rcd_lads_cus_cud.zinrt,
          rcd_lads_cus_cud.eikto,
          rcd_lads_cus_cud.zsabe,
          rcd_lads_cus_cud.kverm,
          rcd_lads_cus_cud.fdgrv,
          rcd_lads_cus_cud.vrbkz,
          rcd_lads_cus_cud.vlibb,
          rcd_lads_cus_cud.vrszl,
          rcd_lads_cus_cud.vrspr,
          rcd_lads_cus_cud.vrsnr,
          rcd_lads_cus_cud.verdt,
          rcd_lads_cus_cud.perkz,
          rcd_lads_cus_cud.xdezv,
          rcd_lads_cus_cud.xausz,
          rcd_lads_cus_cud.webtr,
          rcd_lads_cus_cud.remit,
          rcd_lads_cus_cud.datlz,
          rcd_lads_cus_cud.xzver,
          rcd_lads_cus_cud.togru,
          rcd_lads_cus_cud.kultg,
          rcd_lads_cus_cud.hbkid,
          rcd_lads_cus_cud.xpore,
          rcd_lads_cus_cud.blnkz,
          rcd_lads_cus_cud.altkn,
          rcd_lads_cus_cud.zgrup,
          rcd_lads_cus_cud.urlid,
          rcd_lads_cus_cud.mgrup,
          rcd_lads_cus_cud.lockb,
          rcd_lads_cus_cud.uzawe,
          rcd_lads_cus_cud.ekvbd,
          rcd_lads_cus_cud.sregl,
          rcd_lads_cus_cud.xedip,
          rcd_lads_cus_cud.frgrp,
          rcd_lads_cus_cud.vrsdg,
          rcd_lads_cus_cud.tlfxs,
          rcd_lads_cus_cud.pernr,
          rcd_lads_cus_cud.intad,
          rcd_lads_cus_cud.guzte,
          rcd_lads_cus_cud.gricd,
          rcd_lads_cus_cud.gridt,
          rcd_lads_cus_cud.wbrsl,
          rcd_lads_cus_cud.nodel,
          rcd_lads_cus_cud.tlfns,
          rcd_lads_cus_cud.cession_kz,
          rcd_lads_cus_cud.gmvkzd);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_cud;

   /**************************************************/
   /* This procedure performs the record CTX routine */
   /**************************************************/
   procedure process_record_ctx(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CTX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_ctx.kunnr := rcd_lads_cus_cud.kunnr;
      rcd_lads_cus_ctx.cudseq := rcd_lads_cus_cud.cudseq;
      rcd_lads_cus_ctx.ctxseq := rcd_lads_cus_ctx.ctxseq + 1;
      rcd_lads_cus_ctx.witht := lics_inbound_utility.get_variable('WITHT');
      rcd_lads_cus_ctx.wt_withcd := lics_inbound_utility.get_variable('WT_WITHCD');
      rcd_lads_cus_ctx.wt_agent := lics_inbound_utility.get_variable('WT_AGENT');
      rcd_lads_cus_ctx.wt_agtdf := lics_inbound_utility.get_variable('WT_AGTDF');
      rcd_lads_cus_ctx.wt_agtdt := lics_inbound_utility.get_variable('WT_AGTDT');
      rcd_lads_cus_ctx.wt_wtstcd := lics_inbound_utility.get_variable('WT_WTSTCD');
      rcd_lads_cus_ctx.bukrs := lics_inbound_utility.get_variable('BUKRS');

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
      if rcd_lads_cus_ctx.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CTX.KUNNR');
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

      insert into lads_cus_ctx
         (kunnr,
          cudseq,
          ctxseq,
          witht,
          wt_withcd,
          wt_agent,
          wt_agtdf,
          wt_agtdt,
          wt_wtstcd,
          bukrs)
      values
         (rcd_lads_cus_ctx.kunnr,
          rcd_lads_cus_ctx.cudseq,
          rcd_lads_cus_ctx.ctxseq,
          rcd_lads_cus_ctx.witht,
          rcd_lads_cus_ctx.wt_withcd,
          rcd_lads_cus_ctx.wt_agent,
          rcd_lads_cus_ctx.wt_agtdf,
          rcd_lads_cus_ctx.wt_agtdt,
          rcd_lads_cus_ctx.wt_wtstcd,
          rcd_lads_cus_ctx.bukrs);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctx;

   /**************************************************/
   /* This procedure performs the record CTE routine */
   /**************************************************/
   procedure process_record_cte(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CTE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_cte.kunnr := rcd_lads_cus_cud.kunnr;
      rcd_lads_cus_cte.cudseq := rcd_lads_cus_cud.cudseq;
      rcd_lads_cus_cte.cteseq := rcd_lads_cus_cte.cteseq + 1;
      rcd_lads_cus_cte.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_cus_cte.tdname := lics_inbound_utility.get_variable('TDNAME');
      rcd_lads_cus_cte.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_cus_cte.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_cus_cte.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_cus_cte.tdsprasiso := lics_inbound_utility.get_variable('TDSPRASISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_cus_ctd.ctdseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_cus_cte.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CTE.KUNNR');
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

      insert into lads_cus_cte
         (kunnr,
          cudseq,
          cteseq,
          tdobject,
          tdname,
          tdid,
          tdspras,
          tdtexttype,
          tdsprasiso)
      values
         (rcd_lads_cus_cte.kunnr,
          rcd_lads_cus_cte.cudseq,
          rcd_lads_cus_cte.cteseq,
          rcd_lads_cus_cte.tdobject,
          rcd_lads_cus_cte.tdname,
          rcd_lads_cus_cte.tdid,
          rcd_lads_cus_cte.tdspras,
          rcd_lads_cus_cte.tdtexttype,
          rcd_lads_cus_cte.tdsprasiso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_cte;

   /**************************************************/
   /* This procedure performs the record CTD routine */
   /**************************************************/
   procedure process_record_ctd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CTD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_ctd.kunnr := rcd_lads_cus_cte.kunnr;
      rcd_lads_cus_ctd.cudseq := rcd_lads_cus_cte.cudseq;
      rcd_lads_cus_ctd.cteseq := rcd_lads_cus_cte.cteseq;
      rcd_lads_cus_ctd.ctdseq := rcd_lads_cus_ctd.ctdseq + 1;
      rcd_lads_cus_ctd.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_cus_ctd.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_cus_ctd.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CTD.KUNNR');
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

      insert into lads_cus_ctd
         (kunnr,
          cudseq,
          cteseq,
          ctdseq,
          tdformat,
          tdline)
      values
         (rcd_lads_cus_ctd.kunnr,
          rcd_lads_cus_ctd.cudseq,
          rcd_lads_cus_ctd.cteseq,
          rcd_lads_cus_ctd.ctdseq,
          rcd_lads_cus_ctd.tdformat,
          rcd_lads_cus_ctd.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctd;

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
      rcd_lads_cus_bnk.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_bnk.bnkseq := rcd_lads_cus_bnk.bnkseq + 1;
      rcd_lads_cus_bnk.banks := lics_inbound_utility.get_variable('BANKS');
      rcd_lads_cus_bnk.bankl := lics_inbound_utility.get_variable('BANKL');
      rcd_lads_cus_bnk.bankn := lics_inbound_utility.get_variable('BANKN');
      rcd_lads_cus_bnk.bkont := lics_inbound_utility.get_variable('BKONT');
      rcd_lads_cus_bnk.bvtyp := lics_inbound_utility.get_variable('BVTYP');
      rcd_lads_cus_bnk.xezer := lics_inbound_utility.get_variable('XEZER');
      rcd_lads_cus_bnk.bkref := lics_inbound_utility.get_variable('BKREF');
      rcd_lads_cus_bnk.banka := lics_inbound_utility.get_variable('BANKA');
      rcd_lads_cus_bnk.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_cus_bnk.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_cus_bnk.swift := lics_inbound_utility.get_variable('SWIFT');
      rcd_lads_cus_bnk.bgrup := lics_inbound_utility.get_variable('BGRUP');
      rcd_lads_cus_bnk.xpgro := lics_inbound_utility.get_variable('XPGRO');
      rcd_lads_cus_bnk.bnklz := lics_inbound_utility.get_variable('BNKLZ');
      rcd_lads_cus_bnk.pskto := lics_inbound_utility.get_variable('PSKTO');
      rcd_lads_cus_bnk.brnch := lics_inbound_utility.get_variable('BRNCH');
      rcd_lads_cus_bnk.provz := lics_inbound_utility.get_variable('PROVZ');
      rcd_lads_cus_bnk.koinh := lics_inbound_utility.get_variable('KOINH');
      rcd_lads_cus_bnk.koinh_n := lics_inbound_utility.get_variable('KOINH_N');
      rcd_lads_cus_bnk.kovon := lics_inbound_utility.get_variable('KOVON');
      rcd_lads_cus_bnk.kobis := lics_inbound_utility.get_variable('KOBIS');

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
      if rcd_lads_cus_bnk.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - BNK.KUNNR');
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

      insert into lads_cus_bnk
         (kunnr,
          bnkseq,
          banks,
          bankl,
          bankn,
          bkont,
          bvtyp,
          xezer,
          bkref,
          banka,
          stras,
          ort01,
          swift,
          bgrup,
          xpgro,
          bnklz,
          pskto,
          brnch,
          provz,
          koinh,
          koinh_n,
          kovon,
          kobis)
      values
         (rcd_lads_cus_bnk.kunnr,
          rcd_lads_cus_bnk.bnkseq,
          rcd_lads_cus_bnk.banks,
          rcd_lads_cus_bnk.bankl,
          rcd_lads_cus_bnk.bankn,
          rcd_lads_cus_bnk.bkont,
          rcd_lads_cus_bnk.bvtyp,
          rcd_lads_cus_bnk.xezer,
          rcd_lads_cus_bnk.bkref,
          rcd_lads_cus_bnk.banka,
          rcd_lads_cus_bnk.stras,
          rcd_lads_cus_bnk.ort01,
          rcd_lads_cus_bnk.swift,
          rcd_lads_cus_bnk.bgrup,
          rcd_lads_cus_bnk.xpgro,
          rcd_lads_cus_bnk.bnklz,
          rcd_lads_cus_bnk.pskto,
          rcd_lads_cus_bnk.brnch,
          rcd_lads_cus_bnk.provz,
          rcd_lads_cus_bnk.koinh,
          rcd_lads_cus_bnk.koinh_n,
          rcd_lads_cus_bnk.kovon,
          rcd_lads_cus_bnk.kobis);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_bnk;

   /**************************************************/
   /* This procedure performs the record UNL routine */
   /**************************************************/
   procedure process_record_unl(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('UNL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_unl.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_unl.unlseq := rcd_lads_cus_unl.unlseq + 1;
      rcd_lads_cus_unl.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_cus_unl.knfak := lics_inbound_utility.get_variable('KNFAK');
      rcd_lads_cus_unl.wanid := lics_inbound_utility.get_variable('WANID');
      rcd_lads_cus_unl.defab := lics_inbound_utility.get_variable('DEFAB');

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
      if rcd_lads_cus_unl.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - UNL.KUNNR');
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

      insert into lads_cus_unl
         (kunnr,
          unlseq,
          ablad,
          knfak,
          wanid,
          defab)
      values
         (rcd_lads_cus_unl.kunnr,
          rcd_lads_cus_unl.unlseq,
          rcd_lads_cus_unl.ablad,
          rcd_lads_cus_unl.knfak,
          rcd_lads_cus_unl.wanid,
          rcd_lads_cus_unl.defab);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_unl;

   /**************************************************/
   /* This procedure performs the record PRP routine */
   /**************************************************/
   procedure process_record_prp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PRP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_prp.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_prp.prpseq := rcd_lads_cus_prp.prpseq + 1;
      rcd_lads_cus_prp.locnr := lics_inbound_utility.get_variable('LOCNR');
      rcd_lads_cus_prp.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_cus_prp.kunn2 := lics_inbound_utility.get_variable('KUNN2');
      rcd_lads_cus_prp.ablad := lics_inbound_utility.get_variable('ABLAD');

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
      if rcd_lads_cus_prp.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PRP.KUNNR');
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

      insert into lads_cus_prp
         (kunnr,
          prpseq,
          locnr,
          empst,
          kunn2,
          ablad)
      values
         (rcd_lads_cus_prp.kunnr,
          rcd_lads_cus_prp.prpseq,
          rcd_lads_cus_prp.locnr,
          rcd_lads_cus_prp.empst,
          rcd_lads_cus_prp.kunn2,
          rcd_lads_cus_prp.ablad);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_prp;

   /**************************************************/
   /* This procedure performs the record PDP routine */
   /**************************************************/
   procedure process_record_pdp(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PDP', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_pdp.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_pdp.pdpseq := rcd_lads_cus_pdp.pdpseq + 1;
      rcd_lads_cus_pdp.locnr := lics_inbound_utility.get_variable('LOCNR');
      rcd_lads_cus_pdp.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_cus_pdp.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_cus_pdp.verfl := lics_inbound_utility.get_number('VERFL',null);
      rcd_lads_cus_pdp.verfe := lics_inbound_utility.get_variable('VERFE');
      rcd_lads_cus_pdp.layvr := lics_inbound_utility.get_variable('LAYVR');
      rcd_lads_cus_pdp.flvar := lics_inbound_utility.get_variable('FLVAR');

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
      if rcd_lads_cus_pdp.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PDP.KUNNR');
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

      insert into lads_cus_pdp
         (kunnr,
          pdpseq,
          locnr,
          abtnr,
          empst,
          verfl,
          verfe,
          layvr,
          flvar)
      values
         (rcd_lads_cus_pdp.kunnr,
          rcd_lads_cus_pdp.pdpseq,
          rcd_lads_cus_pdp.locnr,
          rcd_lads_cus_pdp.abtnr,
          rcd_lads_cus_pdp.empst,
          rcd_lads_cus_pdp.verfl,
          rcd_lads_cus_pdp.verfe,
          rcd_lads_cus_pdp.layvr,
          rcd_lads_cus_pdp.flvar);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pdp;

   /**************************************************/
   /* This procedure performs the record CNT routine */
   /**************************************************/
   procedure process_record_cnt(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CNT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_cnt.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_cnt.cntseq := rcd_lads_cus_cnt.cntseq + 1;
      rcd_lads_cus_cnt.parnr := lics_inbound_utility.get_number('PARNR',null);
      rcd_lads_cus_cnt.namev := lics_inbound_utility.get_variable('NAMEV');
      rcd_lads_cus_cnt.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_cus_cnt.abtpa := lics_inbound_utility.get_variable('ABTPA');
      rcd_lads_cus_cnt.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_cus_cnt.uepar := lics_inbound_utility.get_number('UEPAR',null);
      rcd_lads_cus_cnt.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_cus_cnt.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_cus_cnt.pafkt := lics_inbound_utility.get_variable('PAFKT');
      rcd_lads_cus_cnt.sortl := lics_inbound_utility.get_variable('SORTL');
      rcd_lads_cus_cnt.zz_tel_extens := lics_inbound_utility.get_variable('ZZ_TEL_EXTENS');
      rcd_lads_cus_cnt.zz_fax_number := lics_inbound_utility.get_variable('ZZ_FAX_NUMBER');
      rcd_lads_cus_cnt.zz_fax_extens := lics_inbound_utility.get_variable('ZZ_FAX_EXTENS');

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
      if rcd_lads_cus_cnt.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CNT.KUNNR');
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

      insert into lads_cus_cnt
         (kunnr,
          cntseq,
          parnr,
          namev,
          name1,
          abtpa,
          abtnr,
          uepar,
          telf1,
          anred,
          pafkt,
          sortl,
          zz_tel_extens,
          zz_fax_number,
          zz_fax_extens)
      values
         (rcd_lads_cus_cnt.kunnr,
          rcd_lads_cus_cnt.cntseq,
          rcd_lads_cus_cnt.parnr,
          rcd_lads_cus_cnt.namev,
          rcd_lads_cus_cnt.name1,
          rcd_lads_cus_cnt.abtpa,
          rcd_lads_cus_cnt.abtnr,
          rcd_lads_cus_cnt.uepar,
          rcd_lads_cus_cnt.telf1,
          rcd_lads_cus_cnt.anred,
          rcd_lads_cus_cnt.pafkt,
          rcd_lads_cus_cnt.sortl,
          rcd_lads_cus_cnt.zz_tel_extens,
          rcd_lads_cus_cnt.zz_fax_number,
          rcd_lads_cus_cnt.zz_fax_extens);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_cnt;

   /**************************************************/
   /* This procedure performs the record VAT routine */
   /**************************************************/
   procedure process_record_vat(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('VAT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_vat.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_vat.vatseq := rcd_lads_cus_vat.vatseq + 1;
      rcd_lads_cus_vat.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_cus_vat.stceg := lics_inbound_utility.get_variable('STCEG');

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
      if rcd_lads_cus_vat.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - VAT.KUNNR');
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

      insert into lads_cus_vat
         (kunnr,
          vatseq,
          land1,
          stceg)
      values
         (rcd_lads_cus_vat.kunnr,
          rcd_lads_cus_vat.vatseq,
          rcd_lads_cus_vat.land1,
          rcd_lads_cus_vat.stceg);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_vat;

   /**************************************************/
   /* This procedure performs the record PLM routine */
   /**************************************************/
   procedure process_record_plm(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PLM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_plm.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_plm.plmseq := rcd_lads_cus_plm.plmseq + 1;
      rcd_lads_cus_plm.locnr := lics_inbound_utility.get_variable('LOCNR');
      rcd_lads_cus_plm.eroed := lics_inbound_utility.get_variable('EROED');
      rcd_lads_cus_plm.schld := lics_inbound_utility.get_variable('SCHLD');
      rcd_lads_cus_plm.spdab := lics_inbound_utility.get_variable('SPDAB');
      rcd_lads_cus_plm.spdbi := lics_inbound_utility.get_variable('SPDBI');
      rcd_lads_cus_plm.autob := lics_inbound_utility.get_variable('AUTOB');
      rcd_lads_cus_plm.kopro := lics_inbound_utility.get_variable('KOPRO');
      rcd_lads_cus_plm.layvr := lics_inbound_utility.get_variable('LAYVR');
      rcd_lads_cus_plm.flvar := lics_inbound_utility.get_variable('FLVAR');
      rcd_lads_cus_plm.stfak := lics_inbound_utility.get_variable('STFAK');
      rcd_lads_cus_plm.wanid := lics_inbound_utility.get_variable('WANID');
      rcd_lads_cus_plm.verfl := lics_inbound_utility.get_number('VERFL',null);
      rcd_lads_cus_plm.verfe := lics_inbound_utility.get_variable('VERFE');
      rcd_lads_cus_plm.spgr1 := lics_inbound_utility.get_variable('SPGR1');
      rcd_lads_cus_plm.inpro := lics_inbound_utility.get_variable('INPRO');
      rcd_lads_cus_plm.ekoar := lics_inbound_utility.get_variable('EKOAR');
      rcd_lads_cus_plm.kzlik := lics_inbound_utility.get_variable('KZLIK');
      rcd_lads_cus_plm.betrp := lics_inbound_utility.get_variable('BETRP');
      rcd_lads_cus_plm.erdat := lics_inbound_utility.get_variable('ERDAT');
      rcd_lads_cus_plm.ernam := lics_inbound_utility.get_variable('ERNAM');
      rcd_lads_cus_plm.nlmatfb := lics_inbound_utility.get_variable('NLMATFB');
      rcd_lads_cus_plm.bwwrk := lics_inbound_utility.get_variable('BWWRK');
      rcd_lads_cus_plm.bwvko := lics_inbound_utility.get_variable('BWVKO');
      rcd_lads_cus_plm.bwvtw := lics_inbound_utility.get_variable('BWVTW');
      rcd_lads_cus_plm.bbpro := lics_inbound_utility.get_variable('BBPRO');
      rcd_lads_cus_plm.vkbur_wrk := lics_inbound_utility.get_variable('VKBUR_WRK');
      rcd_lads_cus_plm.vlfkz := lics_inbound_utility.get_variable('VLFKZ');
      rcd_lads_cus_plm.lstfl := lics_inbound_utility.get_variable('LSTFL');
      rcd_lads_cus_plm.ligrd := lics_inbound_utility.get_variable('LIGRD');
      rcd_lads_cus_plm.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_cus_plm.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_lads_cus_plm.desroi := lics_inbound_utility.get_variable('DESROI');
      rcd_lads_cus_plm.timinc := lics_inbound_utility.get_variable('TIMINC');
      rcd_lads_cus_plm.posws := lics_inbound_utility.get_variable('POSWS');
      rcd_lads_cus_plm.ssopt_pro := lics_inbound_utility.get_variable('SSOPT_PRO');
      rcd_lads_cus_plm.wbpro := lics_inbound_utility.get_variable('WBPRO');

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
      if rcd_lads_cus_plm.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PLM.KUNNR');
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

      insert into lads_cus_plm
         (kunnr,
          plmseq,
          locnr,
          eroed,
          schld,
          spdab,
          spdbi,
          autob,
          kopro,
          layvr,
          flvar,
          stfak,
          wanid,
          verfl,
          verfe,
          spgr1,
          inpro,
          ekoar,
          kzlik,
          betrp,
          erdat,
          ernam,
          nlmatfb,
          bwwrk,
          bwvko,
          bwvtw,
          bbpro,
          vkbur_wrk,
          vlfkz,
          lstfl,
          ligrd,
          vkorg,
          vtweg,
          desroi,
          timinc,
          posws,
          ssopt_pro,
          wbpro)
      values
         (rcd_lads_cus_plm.kunnr,
          rcd_lads_cus_plm.plmseq,
          rcd_lads_cus_plm.locnr,
          rcd_lads_cus_plm.eroed,
          rcd_lads_cus_plm.schld,
          rcd_lads_cus_plm.spdab,
          rcd_lads_cus_plm.spdbi,
          rcd_lads_cus_plm.autob,
          rcd_lads_cus_plm.kopro,
          rcd_lads_cus_plm.layvr,
          rcd_lads_cus_plm.flvar,
          rcd_lads_cus_plm.stfak,
          rcd_lads_cus_plm.wanid,
          rcd_lads_cus_plm.verfl,
          rcd_lads_cus_plm.verfe,
          rcd_lads_cus_plm.spgr1,
          rcd_lads_cus_plm.inpro,
          rcd_lads_cus_plm.ekoar,
          rcd_lads_cus_plm.kzlik,
          rcd_lads_cus_plm.betrp,
          rcd_lads_cus_plm.erdat,
          rcd_lads_cus_plm.ernam,
          rcd_lads_cus_plm.nlmatfb,
          rcd_lads_cus_plm.bwwrk,
          rcd_lads_cus_plm.bwvko,
          rcd_lads_cus_plm.bwvtw,
          rcd_lads_cus_plm.bbpro,
          rcd_lads_cus_plm.vkbur_wrk,
          rcd_lads_cus_plm.vlfkz,
          rcd_lads_cus_plm.lstfl,
          rcd_lads_cus_plm.ligrd,
          rcd_lads_cus_plm.vkorg,
          rcd_lads_cus_plm.vtweg,
          rcd_lads_cus_plm.desroi,
          rcd_lads_cus_plm.timinc,
          rcd_lads_cus_plm.posws,
          rcd_lads_cus_plm.ssopt_pro,
          rcd_lads_cus_plm.wbpro);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_plm;

   /**************************************************/
   /* This procedure performs the record MGV routine */
   /**************************************************/
   procedure process_record_mgv(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MGV', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_mgv.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_mgv.mgvseq := rcd_lads_cus_mgv.mgvseq + 1;
      rcd_lads_cus_mgv.locnr := lics_inbound_utility.get_variable('LOCNR');
      rcd_lads_cus_mgv.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_cus_mgv.wwgpa := lics_inbound_utility.get_variable('WWGPA');
      rcd_lads_cus_mgv.kedet := lics_inbound_utility.get_variable('KEDET');

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
      if rcd_lads_cus_mgv.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MGV.KUNNR');
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

      insert into lads_cus_mgv
         (kunnr,
          mgvseq,
          locnr,
          matkl,
          wwgpa,
          kedet)
      values
         (rcd_lads_cus_mgv.kunnr,
          rcd_lads_cus_mgv.mgvseq,
          rcd_lads_cus_mgv.locnr,
          rcd_lads_cus_mgv.matkl,
          rcd_lads_cus_mgv.wwgpa,
          rcd_lads_cus_mgv.kedet);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mgv;

   /**************************************************/
   /* This procedure performs the record MGE routine */
   /**************************************************/
   procedure process_record_mge(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('MGE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_cus_mge.kunnr := rcd_lads_cus_hdr.kunnr;
      rcd_lads_cus_mge.mgeseq := rcd_lads_cus_mge.mgeseq + 1;
      rcd_lads_cus_mge.locnr := lics_inbound_utility.get_variable('LOCNR');
      rcd_lads_cus_mge.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_cus_mge.wmatn := lics_inbound_utility.get_variable('WMATN');
      rcd_lads_cus_mge.matkl := lics_inbound_utility.get_variable('MATKL');

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
      if rcd_lads_cus_mge.kunnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - MGE.KUNNR');
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

      insert into lads_cus_mge
         (kunnr,
          mgeseq,
          locnr,
          matnr,
          wmatn,
          matkl)
      values
         (rcd_lads_cus_mge.kunnr,
          rcd_lads_cus_mge.mgeseq,
          rcd_lads_cus_mge.locnr,
          rcd_lads_cus_mge.matnr,
          rcd_lads_cus_mge.wmatn,
          rcd_lads_cus_mge.matkl);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_mge;

end lads_atllad11;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad11 for lads_app.lads_atllad11;
grant execute on lads_atllad11 to lics_app;
