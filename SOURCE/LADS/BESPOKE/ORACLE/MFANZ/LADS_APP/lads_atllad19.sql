/******************/
/* Package Header */
/******************/
create or replace package lads_atllad19 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_atllad19
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - atllad19 - Inbound Vendor Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2007/03   Steve Gregan   Updated locking strategy
                             Changed IDOC timestamp check from < to <=
    2008/05   Trevor Keon    Added calls to monitor before and after procedure

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad19;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad19 as

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
   procedure process_record_txh(par_record in varchar2);
   procedure process_record_txl(par_record in varchar2);
   procedure process_record_ccd(par_record in varchar2);
   procedure process_record_zcc(par_record in varchar2);
   procedure process_record_wtx(par_record in varchar2);
   procedure process_record_ctx(par_record in varchar2);
   procedure process_record_ctd(par_record in varchar2);
   procedure process_record_poh(par_record in varchar2);
   procedure process_record_pom(par_record in varchar2);
   procedure process_record_ptx(par_record in varchar2);
   procedure process_record_ptd(par_record in varchar2);
   procedure process_record_bnk(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_ven_hdr lads_ven_hdr%rowtype;
   rcd_lads_ven_txh lads_ven_txh%rowtype;
   rcd_lads_ven_txl lads_ven_txl%rowtype;
   rcd_lads_ven_ccd lads_ven_ccd%rowtype;
   rcd_lads_ven_zcc lads_ven_zcc%rowtype;
   rcd_lads_ven_wtx lads_ven_wtx%rowtype;
   rcd_lads_ven_ctx lads_ven_ctx%rowtype;
   rcd_lads_ven_ctd lads_ven_ctd%rowtype;
   rcd_lads_ven_poh lads_ven_poh%rowtype;
   rcd_lads_ven_pom lads_ven_pom%rowtype;
   rcd_lads_ven_ptx lads_ven_ptx%rowtype;
   rcd_lads_ven_ptd lads_ven_ptd%rowtype;
   rcd_lads_ven_bnk lads_ven_bnk%rowtype;

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
      lics_inbound_utility.set_definition('HDR','LIFNR',10);
      lics_inbound_utility.set_definition('HDR','BEGRU',4);
      lics_inbound_utility.set_definition('HDR','BRSCH',4);
      lics_inbound_utility.set_definition('HDR','ERDAT',8);
      lics_inbound_utility.set_definition('HDR','ERNAM',12);
      lics_inbound_utility.set_definition('HDR','KONZS',10);
      lics_inbound_utility.set_definition('HDR','KTOKK',4);
      lics_inbound_utility.set_definition('HDR','KUNNR',10);
      lics_inbound_utility.set_definition('HDR','LNRZA',10);
      lics_inbound_utility.set_definition('HDR','LOEVM',1);
      lics_inbound_utility.set_definition('HDR','NAME1',35);
      lics_inbound_utility.set_definition('HDR','NAME2',35);
      lics_inbound_utility.set_definition('HDR','NAME3',35);
      lics_inbound_utility.set_definition('HDR','NAME4',35);
      lics_inbound_utility.set_definition('HDR','SORTL',10);
      lics_inbound_utility.set_definition('HDR','SPERR',1);
      lics_inbound_utility.set_definition('HDR','SPERM',1);
      lics_inbound_utility.set_definition('HDR','SPRAS',1);
      lics_inbound_utility.set_definition('HDR','STCD1',16);
      lics_inbound_utility.set_definition('HDR','STCD2',11);
      lics_inbound_utility.set_definition('HDR','STKZA',1);
      lics_inbound_utility.set_definition('HDR','STKZU',1);
      lics_inbound_utility.set_definition('HDR','XCPDK',1);
      lics_inbound_utility.set_definition('HDR','XZEMP',1);
      lics_inbound_utility.set_definition('HDR','VBUND',6);
      lics_inbound_utility.set_definition('HDR','FISKN',10);
      lics_inbound_utility.set_definition('HDR','STCEG',20);
      lics_inbound_utility.set_definition('HDR','STKZN',1);
      lics_inbound_utility.set_definition('HDR','SPERQ',2);
      lics_inbound_utility.set_definition('HDR','ADRNR',10);
      lics_inbound_utility.set_definition('HDR','GBORT',25);
      lics_inbound_utility.set_definition('HDR','GBDAT',8);
      lics_inbound_utility.set_definition('HDR','SEXKZ',1);
      lics_inbound_utility.set_definition('HDR','KRAUS',11);
      lics_inbound_utility.set_definition('HDR','REVDB',8);
      lics_inbound_utility.set_definition('HDR','QSSYS',4);
      lics_inbound_utility.set_definition('HDR','KTOCK',4);
      lics_inbound_utility.set_definition('HDR','WERKS',4);
      lics_inbound_utility.set_definition('HDR','LTSNA',1);
      lics_inbound_utility.set_definition('HDR','WERKR',1);
      lics_inbound_utility.set_definition('HDR','PLKAL',2);
      lics_inbound_utility.set_definition('HDR','DUEFL',1);
      lics_inbound_utility.set_definition('HDR','TXJCD',15);
      lics_inbound_utility.set_definition('HDR','SCACD',4);
      lics_inbound_utility.set_definition('HDR','SFRGR',4);
      lics_inbound_utility.set_definition('HDR','LZONE',10);
      lics_inbound_utility.set_definition('HDR','DLGRP',4);
      lics_inbound_utility.set_definition('HDR','FITYP',2);
      lics_inbound_utility.set_definition('HDR','STCDT',2);
      lics_inbound_utility.set_definition('HDR','REGSS',1);
      lics_inbound_utility.set_definition('HDR','ACTSS',3);
      lics_inbound_utility.set_definition('HDR','STCD3',18);
      lics_inbound_utility.set_definition('HDR','STCD4',18);
      lics_inbound_utility.set_definition('HDR','IPISP',1);
      lics_inbound_utility.set_definition('HDR','PROFS',30);
      lics_inbound_utility.set_definition('HDR','STGDL',2);
      lics_inbound_utility.set_definition('HDR','EMNFR',10);
      lics_inbound_utility.set_definition('HDR','NODEL',1);
      lics_inbound_utility.set_definition('HDR','LFURL',132);
      lics_inbound_utility.set_definition('HDR','J_1KFREPRE',10);
      lics_inbound_utility.set_definition('HDR','J_1KFTBUS',30);
      lics_inbound_utility.set_definition('HDR','J_1KFTIND',30);
      lics_inbound_utility.set_definition('HDR','QSSYSDAT',8);
      lics_inbound_utility.set_definition('HDR','PODKZB',1);
      lics_inbound_utility.set_definition('HDR','FISKU',10);
      lics_inbound_utility.set_definition('HDR','STENR',18);
      lics_inbound_utility.set_definition('HDR','PSOIS',20);
      lics_inbound_utility.set_definition('HDR','PSON1',35);
      lics_inbound_utility.set_definition('HDR','PSON2',35);
      lics_inbound_utility.set_definition('HDR','PSON3',35);
      lics_inbound_utility.set_definition('HDR','PSOVN',35);
      /*-*/
      lics_inbound_utility.set_definition('TXH','IDOC_TXH',3);
      lics_inbound_utility.set_definition('TXH','TDOBJECT',10);
      lics_inbound_utility.set_definition('TXH','TDNAME',70);
      lics_inbound_utility.set_definition('TXH','TDID',4);
      lics_inbound_utility.set_definition('TXH','TDSPRAS',1);
      lics_inbound_utility.set_definition('TXH','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('TXH','TDSPRASISO',2);
      /*-*/
      lics_inbound_utility.set_definition('TXL','IDOC_TXL',3);
      lics_inbound_utility.set_definition('TXL','TDFORMAT',2);
      lics_inbound_utility.set_definition('TXL','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('CCD','IDOC_CCD',3);
      lics_inbound_utility.set_definition('CCD','LIFNR',10);
      lics_inbound_utility.set_definition('CCD','BUKRS',6);
      lics_inbound_utility.set_definition('CCD','ERDAT',8);
      lics_inbound_utility.set_definition('CCD','ERNAM',12);
      lics_inbound_utility.set_definition('CCD','SPERR',1);
      lics_inbound_utility.set_definition('CCD','LOEVM',1);
      lics_inbound_utility.set_definition('CCD','ZUAWA',3);
      lics_inbound_utility.set_definition('CCD','AKONT',10);
      lics_inbound_utility.set_definition('CCD','BEGRU',4);
      lics_inbound_utility.set_definition('CCD','VZSKZ',2);
      lics_inbound_utility.set_definition('CCD','ZWELS',10);
      lics_inbound_utility.set_definition('CCD','XVERR',1);
      lics_inbound_utility.set_definition('CCD','ZAHLS',1);
      lics_inbound_utility.set_definition('CCD','ZTERM',4);
      lics_inbound_utility.set_definition('CCD','EIKTO',12);
      lics_inbound_utility.set_definition('CCD','ZSABE',15);
      lics_inbound_utility.set_definition('CCD','FDGRV',10);
      lics_inbound_utility.set_definition('CCD','BUSAB',2);
      lics_inbound_utility.set_definition('CCD','LNRZE',10);
      lics_inbound_utility.set_definition('CCD','LNRZB',10);
      lics_inbound_utility.set_definition('CCD','ZINDT',8);
      lics_inbound_utility.set_definition('CCD','ZINRT',8);
      lics_inbound_utility.set_definition('CCD','DATLZ',8);
      lics_inbound_utility.set_definition('CCD','XDEZV',1);
      lics_inbound_utility.set_definition('CCD','WEBTR',15);
      lics_inbound_utility.set_definition('CCD','KULTG',3);
      lics_inbound_utility.set_definition('CCD','REPRF',1);
      lics_inbound_utility.set_definition('CCD','TOGRU',4);
      lics_inbound_utility.set_definition('CCD','HBKID',5);
      lics_inbound_utility.set_definition('CCD','XPORE',1);
      lics_inbound_utility.set_definition('CCD','QSZNR',10);
      lics_inbound_utility.set_definition('CCD','QSZDT',8);
      lics_inbound_utility.set_definition('CCD','QSSKZ',2);
      lics_inbound_utility.set_definition('CCD','BLNKZ',2);
      lics_inbound_utility.set_definition('CCD','MINDK',3);
      lics_inbound_utility.set_definition('CCD','ALTKN',10);
      lics_inbound_utility.set_definition('CCD','ZGRUP',2);
      lics_inbound_utility.set_definition('CCD','MGRUP',2);
      lics_inbound_utility.set_definition('CCD','QSREC',2);
      lics_inbound_utility.set_definition('CCD','QSBGR',1);
      lics_inbound_utility.set_definition('CCD','QLAND',3);
      lics_inbound_utility.set_definition('CCD','XEDIP',1);
      lics_inbound_utility.set_definition('CCD','FRGRP',4);
      lics_inbound_utility.set_definition('CCD','TLFXS',31);
      lics_inbound_utility.set_definition('CCD','INTAD',130);
      lics_inbound_utility.set_definition('CCD','GUZTE',4);
      lics_inbound_utility.set_definition('CCD','GRICD',2);
      lics_inbound_utility.set_definition('CCD','GRIDT',2);
      lics_inbound_utility.set_definition('CCD','XAUSZ',1);
      lics_inbound_utility.set_definition('CCD','CERDT',8);
      lics_inbound_utility.set_definition('CCD','TOGRR',4);
      lics_inbound_utility.set_definition('CCD','PERNR',8);
      lics_inbound_utility.set_definition('CCD','NODEL',1);
      lics_inbound_utility.set_definition('CCD','TLFNS',30);
      lics_inbound_utility.set_definition('CCD','GMVKZK',1);
      /*-*/
      lics_inbound_utility.set_definition('ZCC','IDOC_ZCC',3);
      lics_inbound_utility.set_definition('ZCC','ZPYTADV',2);
      /*-*/
      lics_inbound_utility.set_definition('WTX','IDOC_WTX',3);
      lics_inbound_utility.set_definition('WTX','WITHT',2);
      lics_inbound_utility.set_definition('WTX','WT_SUBJCT',1);
      lics_inbound_utility.set_definition('WTX','QSREC',2);
      lics_inbound_utility.set_definition('WTX','WT_WTSTCD',16);
      lics_inbound_utility.set_definition('WTX','WT_WITHCD',2);
      lics_inbound_utility.set_definition('WTX','WT_EXNR',15);
      lics_inbound_utility.set_definition('WTX','WT_EXRT',7);
      lics_inbound_utility.set_definition('WTX','WT_EXDF',8);
      lics_inbound_utility.set_definition('WTX','WT_EXDT',8);
      lics_inbound_utility.set_definition('WTX','WT_WTEXRS',2);
      /*-*/
      lics_inbound_utility.set_definition('CTX','IDOC_CTX',3);
      lics_inbound_utility.set_definition('CTX','TDOBJECT',10);
      lics_inbound_utility.set_definition('CTX','TDNAME',70);
      lics_inbound_utility.set_definition('CTX','TDID',4);
      lics_inbound_utility.set_definition('CTX','TDSPRAS',1);
      lics_inbound_utility.set_definition('CTX','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('CTX','TDSPRASISO',2);
      /*-*/
      lics_inbound_utility.set_definition('CTD','IDOC_CTD',3);
      lics_inbound_utility.set_definition('CTD','TDFORMAT',2);
      lics_inbound_utility.set_definition('CTD','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('POH','IDOC_POH',3);
      lics_inbound_utility.set_definition('POH','LIFNR',10);
      lics_inbound_utility.set_definition('POH','EKORG',6);
      lics_inbound_utility.set_definition('POH','ERDAT',8);
      lics_inbound_utility.set_definition('POH','ERNAM',12);
      lics_inbound_utility.set_definition('POH','SPERM',1);
      lics_inbound_utility.set_definition('POH','LOEVM',1);
      lics_inbound_utility.set_definition('POH','LFABC',1);
      lics_inbound_utility.set_definition('POH','WAERS',5);
      lics_inbound_utility.set_definition('POH','VERKF',30);
      lics_inbound_utility.set_definition('POH','TELF1',16);
      lics_inbound_utility.set_definition('POH','MINBW',13);
      lics_inbound_utility.set_definition('POH','ZTERM',4);
      lics_inbound_utility.set_definition('POH','INCO1',3);
      lics_inbound_utility.set_definition('POH','INCO2',28);
      lics_inbound_utility.set_definition('POH','WEBRE',1);
      lics_inbound_utility.set_definition('POH','KZABS',1);
      lics_inbound_utility.set_definition('POH','KALSK',2);
      lics_inbound_utility.set_definition('POH','KZAUT',1);
      lics_inbound_utility.set_definition('POH','EXPVZ',1);
      lics_inbound_utility.set_definition('POH','ZOLLA',6);
      lics_inbound_utility.set_definition('POH','MEPRF',1);
      lics_inbound_utility.set_definition('POH','EKGRP',3);
      lics_inbound_utility.set_definition('POH','BOLRE',1);
      lics_inbound_utility.set_definition('POH','UMSAE',1);
      lics_inbound_utility.set_definition('POH','XERSY',1);
      lics_inbound_utility.set_definition('POH','PLIFZ',5);
      lics_inbound_utility.set_definition('POH','MRPPP',3);
      lics_inbound_utility.set_definition('POH','LFRHY',3);
      lics_inbound_utility.set_definition('POH','LIEFR',4);
      lics_inbound_utility.set_definition('POH','LIBES',1);
      lics_inbound_utility.set_definition('POH','LIPRE',2);
      lics_inbound_utility.set_definition('POH','LISER',1);
      lics_inbound_utility.set_definition('POH','BOIND',1);
      lics_inbound_utility.set_definition('POH','PRFRE',1);
      lics_inbound_utility.set_definition('POH','NRGEW',1);
      lics_inbound_utility.set_definition('POH','BLIND',1);
      lics_inbound_utility.set_definition('POH','KZRET',1);
      lics_inbound_utility.set_definition('POH','SKRIT',1);
      lics_inbound_utility.set_definition('POH','BSTAE',4);
      lics_inbound_utility.set_definition('POH','RDPRF',4);
      lics_inbound_utility.set_definition('POH','MEGRU',4);
      lics_inbound_utility.set_definition('POH','VENSL',7);
      lics_inbound_utility.set_definition('POH','BOPNR',4);
      lics_inbound_utility.set_definition('POH','XERSR',1);
      lics_inbound_utility.set_definition('POH','EIKTO',12);
      lics_inbound_utility.set_definition('POH','PAPRF',4);
      lics_inbound_utility.set_definition('POH','AGREL',1);
      lics_inbound_utility.set_definition('POH','XNBWY',1);
      lics_inbound_utility.set_definition('POH','VSBED',2);
      lics_inbound_utility.set_definition('POH','LEBRE',1);
      lics_inbound_utility.set_definition('POH','MINBW2',16);
      /*-*/
      lics_inbound_utility.set_definition('POM','IDOC_POM',3);
      lics_inbound_utility.set_definition('POM','LIFNR',10);
      lics_inbound_utility.set_definition('POM','EKORG',6);
      lics_inbound_utility.set_definition('POM','LTSNR',6);
      lics_inbound_utility.set_definition('POM','WERKS',6);
      lics_inbound_utility.set_definition('POM','ERDAT',8);
      lics_inbound_utility.set_definition('POM','ERNAM',12);
      lics_inbound_utility.set_definition('POM','SPERM',1);
      lics_inbound_utility.set_definition('POM','LOEVM',1);
      lics_inbound_utility.set_definition('POM','LFABC',1);
      lics_inbound_utility.set_definition('POM','WAERS',13);
      lics_inbound_utility.set_definition('POM','VERKF',30);
      lics_inbound_utility.set_definition('POM','TELF1',16);
      lics_inbound_utility.set_definition('POM','MINBW',13);
      lics_inbound_utility.set_definition('POM','ZTERM',4);
      lics_inbound_utility.set_definition('POM','INCO1',3);
      lics_inbound_utility.set_definition('POM','INCO2',28);
      lics_inbound_utility.set_definition('POM','WEBRE',1);
      lics_inbound_utility.set_definition('POM','KZABS',1);
      lics_inbound_utility.set_definition('POM','KALSK',2);
      lics_inbound_utility.set_definition('POM','KZAUT',1);
      lics_inbound_utility.set_definition('POM','EXPVZ',1);
      lics_inbound_utility.set_definition('POM','ZOLLA',6);
      lics_inbound_utility.set_definition('POM','MEPRF',1);
      lics_inbound_utility.set_definition('POM','EKGRP',3);
      lics_inbound_utility.set_definition('POM','BOLRE',1);
      lics_inbound_utility.set_definition('POM','UMSAE',1);
      lics_inbound_utility.set_definition('POM','XERSY',1);
      lics_inbound_utility.set_definition('POM','PLIFZ',5);
      lics_inbound_utility.set_definition('POM','MRPPP',3);
      lics_inbound_utility.set_definition('POM','LFRHY',3);
      lics_inbound_utility.set_definition('POM','LIEFR',4);
      lics_inbound_utility.set_definition('POM','LIBES',1);
      lics_inbound_utility.set_definition('POM','LIPRE',2);
      lics_inbound_utility.set_definition('POM','LISER',1);
      lics_inbound_utility.set_definition('POM','DISPO',3);
      lics_inbound_utility.set_definition('POM','BSTAE',4);
      lics_inbound_utility.set_definition('POM','RDPRF',4);
      lics_inbound_utility.set_definition('POM','MEGRU',4);
      lics_inbound_utility.set_definition('POM','BOPNR',4);
      lics_inbound_utility.set_definition('POM','XERSR',1);
      lics_inbound_utility.set_definition('POM','ABUEB',4);
      lics_inbound_utility.set_definition('POM','PAPRF',4);
      lics_inbound_utility.set_definition('POM','XNBWY',1);
      lics_inbound_utility.set_definition('POM','LEBRE',1);
      lics_inbound_utility.set_definition('POM','MINBW2',16);
      /*-*/
      lics_inbound_utility.set_definition('PTX','IDOC_PTX',3);
      lics_inbound_utility.set_definition('PTX','TDOBJECT',10);
      lics_inbound_utility.set_definition('PTX','TDNAME',70);
      lics_inbound_utility.set_definition('PTX','TDID',4);
      lics_inbound_utility.set_definition('PTX','TDSPRAS',1);
      lics_inbound_utility.set_definition('PTX','TDTEXTTYPE',6);
      lics_inbound_utility.set_definition('PTX','TDSPRASISO',2);
      /*-*/
      lics_inbound_utility.set_definition('PTD','IDOC_PTD',3);
      lics_inbound_utility.set_definition('PTD','TDFORMAT',2);
      lics_inbound_utility.set_definition('PTD','TDLINE',132);
      /*-*/
      lics_inbound_utility.set_definition('BNK','IDOC_BNK',3);
      lics_inbound_utility.set_definition('BNK','LIFNR',10);
      lics_inbound_utility.set_definition('BNK','BANKS',3);
      lics_inbound_utility.set_definition('BNK','BANKL',15);
      lics_inbound_utility.set_definition('BNK','BANKN',18);
      lics_inbound_utility.set_definition('BNK','BKONT',2);
      lics_inbound_utility.set_definition('BNK','BVTYP',4);
      lics_inbound_utility.set_definition('BNK','XEZER',1);
      lics_inbound_utility.set_definition('BNK','BANKA',60);
      lics_inbound_utility.set_definition('BNK','ORT01',25);
      lics_inbound_utility.set_definition('BNK','SWIFT',11);
      lics_inbound_utility.set_definition('BNK','BGRUP',2);
      lics_inbound_utility.set_definition('BNK','XPGRO',1);
      lics_inbound_utility.set_definition('BNK','BNKLZ',15);
      lics_inbound_utility.set_definition('BNK','PSKTO',16);
      lics_inbound_utility.set_definition('BNK','BKREF',20);
      lics_inbound_utility.set_definition('BNK','BRNCH',40);
      lics_inbound_utility.set_definition('BNK','PROV2',3);
      lics_inbound_utility.set_definition('BNK','STRA2',35);
      lics_inbound_utility.set_definition('BNK','ORT02',35);
      lics_inbound_utility.set_definition('BNK','KOINH',60);
      lics_inbound_utility.set_definition('BNK','KOVON',8);
      lics_inbound_utility.set_definition('BNK','KOBIS',8);

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
         when 'TXH' then process_record_txh(par_record);
         when 'TXL' then process_record_txl(par_record);
         when 'CCD' then process_record_ccd(par_record);
         when 'ZCC' then process_record_zcc(par_record);
         when 'WTX' then process_record_wtx(par_record);
         when 'CTX' then process_record_ctx(par_record);
         when 'CTD' then process_record_ctd(par_record);
         when 'POH' then process_record_poh(par_record);
         when 'POM' then process_record_pom(par_record);
         when 'PTX' then process_record_ptx(par_record);
         when 'PTD' then process_record_ptd(par_record);
         when 'BNK' then process_record_bnk(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD19';
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
      /* Execute the interface monitor/flattening when required
      /*-*/
      if var_trn_ignore = true then

         /*-*/
         /* Set the transaction accepted indicator and rollback the IDOC transaction
         /* **note** - releases transaction lock
         /*-*/
         var_accepted := true;
         rollback;

      elsif var_trn_error = true then

         /*-*/
         /* Set the transaction accepted indicator and rollback the IDOC transaction
         /* **note** - releases transaction lock
         /*-*/
         var_accepted := false;
         rollback;

      else

         /*-*/
         /* Set the transaction accepted indicator
         /*-*/
         var_accepted := true;

         /*-*/
         /* Execute the interface monitor/flattening
         /* **note** - savepoint is established to ensure IDOC transaction commit
         /*          - child procedure can see IDOC transaction data as part of same commit cycle
         /*          - child procedure must NOT issue commit/rollback
         /*          - child procedure must raise an exception on failure
         /*          - update the LADS flattened flag on success
         /*          - savepoint is used for child procedure failure
         /*-*/
         savepoint transaction_savepoint;
         begin
            lads_atllad19_monitor.execute_before(rcd_lads_ven_hdr.lifnr);
         exception
            when others then
               rollback to transaction_savepoint;
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;

         /*-*/
         /* Commit the IDOC transaction and successful monitor code
         /* **note** - releases transaction lock
         /*-*/
         commit;

         begin
            lads_atllad19_monitor.execute_after(rcd_lads_ven_hdr.lifnr);
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
      var_idoc_timestamp lads_ven_hdr.idoc_timestamp%type;

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
      rcd_lads_ven_hdr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_ven_hdr.begru := lics_inbound_utility.get_variable('BEGRU');
      rcd_lads_ven_hdr.brsch := lics_inbound_utility.get_variable('BRSCH');
      rcd_lads_ven_hdr.erdat := lics_inbound_utility.get_variable('ERDAT');
      rcd_lads_ven_hdr.ernam := lics_inbound_utility.get_variable('ERNAM');
      rcd_lads_ven_hdr.konzs := lics_inbound_utility.get_variable('KONZS');
      rcd_lads_ven_hdr.ktokk := lics_inbound_utility.get_variable('KTOKK');
      rcd_lads_ven_hdr.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_ven_hdr.lnrza := lics_inbound_utility.get_variable('LNRZA');
      rcd_lads_ven_hdr.loevm := lics_inbound_utility.get_variable('LOEVM');
      rcd_lads_ven_hdr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_ven_hdr.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_ven_hdr.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_ven_hdr.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_ven_hdr.sortl := lics_inbound_utility.get_variable('SORTL');
      rcd_lads_ven_hdr.sperr := lics_inbound_utility.get_variable('SPERR');
      rcd_lads_ven_hdr.sperm := lics_inbound_utility.get_variable('SPERM');
      rcd_lads_ven_hdr.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_ven_hdr.stcd1 := lics_inbound_utility.get_variable('STCD1');
      rcd_lads_ven_hdr.stcd2 := lics_inbound_utility.get_variable('STCD2');
      rcd_lads_ven_hdr.stkza := lics_inbound_utility.get_variable('STKZA');
      rcd_lads_ven_hdr.stkzu := lics_inbound_utility.get_variable('STKZU');
      rcd_lads_ven_hdr.xcpdk := lics_inbound_utility.get_variable('XCPDK');
      rcd_lads_ven_hdr.xzemp := lics_inbound_utility.get_variable('XZEMP');
      rcd_lads_ven_hdr.vbund := lics_inbound_utility.get_variable('VBUND');
      rcd_lads_ven_hdr.fiskn := lics_inbound_utility.get_variable('FISKN');
      rcd_lads_ven_hdr.stceg := lics_inbound_utility.get_variable('STCEG');
      rcd_lads_ven_hdr.stkzn := lics_inbound_utility.get_variable('STKZN');
      rcd_lads_ven_hdr.sperq := lics_inbound_utility.get_variable('SPERQ');
      rcd_lads_ven_hdr.adrnr := lics_inbound_utility.get_variable('ADRNR');
      rcd_lads_ven_hdr.gbort := lics_inbound_utility.get_variable('GBORT');
      rcd_lads_ven_hdr.gbdat := lics_inbound_utility.get_variable('GBDAT');
      rcd_lads_ven_hdr.sexkz := lics_inbound_utility.get_variable('SEXKZ');
      rcd_lads_ven_hdr.kraus := lics_inbound_utility.get_variable('KRAUS');
      rcd_lads_ven_hdr.revdb := lics_inbound_utility.get_variable('REVDB');
      rcd_lads_ven_hdr.qssys := lics_inbound_utility.get_variable('QSSYS');
      rcd_lads_ven_hdr.ktock := lics_inbound_utility.get_variable('KTOCK');
      rcd_lads_ven_hdr.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_ven_hdr.ltsna := lics_inbound_utility.get_variable('LTSNA');
      rcd_lads_ven_hdr.werkr := lics_inbound_utility.get_variable('WERKR');
      rcd_lads_ven_hdr.plkal := lics_inbound_utility.get_variable('PLKAL');
      rcd_lads_ven_hdr.duefl := lics_inbound_utility.get_variable('DUEFL');
      rcd_lads_ven_hdr.txjcd := lics_inbound_utility.get_variable('TXJCD');
      rcd_lads_ven_hdr.scacd := lics_inbound_utility.get_variable('SCACD');
      rcd_lads_ven_hdr.sfrgr := lics_inbound_utility.get_variable('SFRGR');
      rcd_lads_ven_hdr.lzone := lics_inbound_utility.get_variable('LZONE');
      rcd_lads_ven_hdr.dlgrp := lics_inbound_utility.get_variable('DLGRP');
      rcd_lads_ven_hdr.fityp := lics_inbound_utility.get_variable('FITYP');
      rcd_lads_ven_hdr.stcdt := lics_inbound_utility.get_variable('STCDT');
      rcd_lads_ven_hdr.regss := lics_inbound_utility.get_variable('REGSS');
      rcd_lads_ven_hdr.actss := lics_inbound_utility.get_variable('ACTSS');
      rcd_lads_ven_hdr.stcd3 := lics_inbound_utility.get_variable('STCD3');
      rcd_lads_ven_hdr.stcd4 := lics_inbound_utility.get_variable('STCD4');
      rcd_lads_ven_hdr.ipisp := lics_inbound_utility.get_variable('IPISP');
      rcd_lads_ven_hdr.profs := lics_inbound_utility.get_variable('PROFS');
      rcd_lads_ven_hdr.stgdl := lics_inbound_utility.get_variable('STGDL');
      rcd_lads_ven_hdr.emnfr := lics_inbound_utility.get_variable('EMNFR');
      rcd_lads_ven_hdr.nodel := lics_inbound_utility.get_variable('NODEL');
      rcd_lads_ven_hdr.lfurl := lics_inbound_utility.get_variable('LFURL');
      rcd_lads_ven_hdr.j_1kfrepre := lics_inbound_utility.get_variable('J_1KFREPRE');
      rcd_lads_ven_hdr.j_1kftbus := lics_inbound_utility.get_variable('J_1KFTBUS');
      rcd_lads_ven_hdr.j_1kftind := lics_inbound_utility.get_variable('J_1KFTIND');
      rcd_lads_ven_hdr.qssysdat := lics_inbound_utility.get_variable('QSSYSDAT');
      rcd_lads_ven_hdr.podkzb := lics_inbound_utility.get_variable('PODKZB');
      rcd_lads_ven_hdr.fisku := lics_inbound_utility.get_variable('FISKU');
      rcd_lads_ven_hdr.stenr := lics_inbound_utility.get_variable('STENR');
      rcd_lads_ven_hdr.psois := lics_inbound_utility.get_variable('PSOIS');
      rcd_lads_ven_hdr.pson1 := lics_inbound_utility.get_variable('PSON1');
      rcd_lads_ven_hdr.pson2 := lics_inbound_utility.get_variable('PSON2');
      rcd_lads_ven_hdr.pson3 := lics_inbound_utility.get_variable('PSON3');
      rcd_lads_ven_hdr.psovn := lics_inbound_utility.get_variable('PSOVN');
      rcd_lads_ven_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_ven_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_ven_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_ven_hdr.lads_date := sysdate;
      rcd_lads_ven_hdr.lads_status := '1';
      rcd_lads_ven_hdr.lads_flattened := '0';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_ven_txh.txhseq := 0;
      rcd_lads_ven_ccd.ccdseq := 0;
      rcd_lads_ven_poh.pohseq := 0;
      rcd_lads_ven_bnk.bnkseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_ven_hdr.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.LIFNR');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*----------------------------------------*/
      /* LOCK- Lock the interface transaction   */
      /*----------------------------------------*/

      /*-*/
      /* Lock the IDOC transaction
      /* **note** - attempt to lock the transaction header row (oracle default wait behaviour)
      /*              - insert/insert (not exists) - first holds lock and second fails on first commit with duplicate index
      /*              - update/update (exists) - logic goes to update and default wait behaviour
      /*          - validate the IDOC sequence when locking row exists
      /*          - lock and commit cycle encompasses transaction child procedure execution
      /*-*/
      begin
         insert into lads_ven_hdr
            (lifnr,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status,
             lads_flattened)
         values
            (rcd_lads_ven_hdr.lifnr,
             rcd_lads_ven_hdr.idoc_name,
             rcd_lads_ven_hdr.idoc_number,
             rcd_lads_ven_hdr.idoc_timestamp,
             rcd_lads_ven_hdr.lads_date,
             rcd_lads_ven_hdr.lads_status,
             rcd_lads_ven_hdr.lads_flattened);
      exception
         when dup_val_on_index then
            update lads_ven_hdr
               set lads_status = lads_status
             where lifnr = rcd_lads_ven_hdr.lifnr
             returning idoc_timestamp into var_idoc_timestamp;
            if sql%found and var_idoc_timestamp <= rcd_lads_ven_hdr.idoc_timestamp then
               delete from lads_ven_bnk where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_ptd where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_ptx where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_pom where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_poh where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_ctd where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_ctx where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_wtx where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_zcc where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_ccd where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_txl where lifnr = rcd_lads_ven_hdr.lifnr;
               delete from lads_ven_txh where lifnr = rcd_lads_ven_hdr.lifnr;
            else
               var_trn_ignore := true;
            end if;
      end;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      update lads_ven_hdr set
         begru = rcd_lads_ven_hdr.begru,
         brsch = rcd_lads_ven_hdr.brsch,
         erdat = rcd_lads_ven_hdr.erdat,
         ernam = rcd_lads_ven_hdr.ernam,
         konzs = rcd_lads_ven_hdr.konzs,
         ktokk = rcd_lads_ven_hdr.ktokk,
         kunnr = rcd_lads_ven_hdr.kunnr,
         lnrza = rcd_lads_ven_hdr.lnrza,
         loevm = rcd_lads_ven_hdr.loevm,
         name1 = rcd_lads_ven_hdr.name1,
         name2 = rcd_lads_ven_hdr.name2,
         name3 = rcd_lads_ven_hdr.name3,
         name4 = rcd_lads_ven_hdr.name4,
         sortl = rcd_lads_ven_hdr.sortl,
         sperr = rcd_lads_ven_hdr.sperr,
         sperm = rcd_lads_ven_hdr.sperm,
         spras = rcd_lads_ven_hdr.spras,
         stcd1 = rcd_lads_ven_hdr.stcd1,
         stcd2 = rcd_lads_ven_hdr.stcd2,
         stkza = rcd_lads_ven_hdr.stkza,
         stkzu = rcd_lads_ven_hdr.stkzu,
         xcpdk = rcd_lads_ven_hdr.xcpdk,
         xzemp = rcd_lads_ven_hdr.xzemp,
         vbund = rcd_lads_ven_hdr.vbund,
         fiskn = rcd_lads_ven_hdr.fiskn,
         stceg = rcd_lads_ven_hdr.stceg,
         stkzn = rcd_lads_ven_hdr.stkzn,
         sperq = rcd_lads_ven_hdr.sperq,
         adrnr = rcd_lads_ven_hdr.adrnr,
         gbort = rcd_lads_ven_hdr.gbort,
         gbdat = rcd_lads_ven_hdr.gbdat,
         sexkz = rcd_lads_ven_hdr.sexkz,
         kraus = rcd_lads_ven_hdr.kraus,
         revdb = rcd_lads_ven_hdr.revdb,
         qssys = rcd_lads_ven_hdr.qssys,
         ktock = rcd_lads_ven_hdr.ktock,
         werks = rcd_lads_ven_hdr.werks,
         ltsna = rcd_lads_ven_hdr.ltsna,
         werkr = rcd_lads_ven_hdr.werkr,
         plkal = rcd_lads_ven_hdr.plkal,
         duefl = rcd_lads_ven_hdr.duefl,
         txjcd = rcd_lads_ven_hdr.txjcd,
         scacd = rcd_lads_ven_hdr.scacd,
         sfrgr = rcd_lads_ven_hdr.sfrgr,
         lzone = rcd_lads_ven_hdr.lzone,
         dlgrp = rcd_lads_ven_hdr.dlgrp,
         fityp = rcd_lads_ven_hdr.fityp,
         stcdt = rcd_lads_ven_hdr.stcdt,
         regss = rcd_lads_ven_hdr.regss,
         actss = rcd_lads_ven_hdr.actss,
         stcd3 = rcd_lads_ven_hdr.stcd3,
         stcd4 = rcd_lads_ven_hdr.stcd4,
         ipisp = rcd_lads_ven_hdr.ipisp,
         profs = rcd_lads_ven_hdr.profs,
         stgdl = rcd_lads_ven_hdr.stgdl,
         emnfr = rcd_lads_ven_hdr.emnfr,
         nodel = rcd_lads_ven_hdr.nodel,
         lfurl = rcd_lads_ven_hdr.lfurl,
         j_1kfrepre = rcd_lads_ven_hdr.j_1kfrepre,
         j_1kftbus = rcd_lads_ven_hdr.j_1kftbus,
         j_1kftind = rcd_lads_ven_hdr.j_1kftind,
         qssysdat = rcd_lads_ven_hdr.qssysdat,
         podkzb = rcd_lads_ven_hdr.podkzb,
         fisku = rcd_lads_ven_hdr.fisku,
         stenr = rcd_lads_ven_hdr.stenr,
         psois = rcd_lads_ven_hdr.psois,
         pson1 = rcd_lads_ven_hdr.pson1,
         pson2 = rcd_lads_ven_hdr.pson2,
         pson3 = rcd_lads_ven_hdr.pson3,
         psovn = rcd_lads_ven_hdr.psovn,
         idoc_name = rcd_lads_ven_hdr.idoc_name,
         idoc_number = rcd_lads_ven_hdr.idoc_number,
         idoc_timestamp = rcd_lads_ven_hdr.idoc_timestamp,
         lads_date = rcd_lads_ven_hdr.lads_date,
         lads_status = rcd_lads_ven_hdr.lads_status,
         lads_flattened = rcd_lads_ven_hdr.lads_flattened
      where lifnr = rcd_lads_ven_hdr.lifnr;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

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
      rcd_lads_ven_txh.lifnr := rcd_lads_ven_hdr.lifnr;
      rcd_lads_ven_txh.txhseq := rcd_lads_ven_txh.txhseq + 1;
      rcd_lads_ven_txh.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_ven_txh.tdname := lics_inbound_utility.get_variable('TDNAME');
      rcd_lads_ven_txh.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_ven_txh.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_ven_txh.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_ven_txh.tdsprasiso := lics_inbound_utility.get_variable('TDSPRASISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_ven_txl.txlseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_ven_txh.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXH.LIFNR');
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

      insert into lads_ven_txh
         (lifnr,
          txhseq,
          tdobject,
          tdname,
          tdid,
          tdspras,
          tdtexttype,
          tdsprasiso)
      values
         (rcd_lads_ven_txh.lifnr,
          rcd_lads_ven_txh.txhseq,
          rcd_lads_ven_txh.tdobject,
          rcd_lads_ven_txh.tdname,
          rcd_lads_ven_txh.tdid,
          rcd_lads_ven_txh.tdspras,
          rcd_lads_ven_txh.tdtexttype,
          rcd_lads_ven_txh.tdsprasiso);

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
      rcd_lads_ven_txl.lifnr := rcd_lads_ven_txh.lifnr;
      rcd_lads_ven_txl.txhseq := rcd_lads_ven_txh.txhseq;
      rcd_lads_ven_txl.txlseq := rcd_lads_ven_txl.txlseq + 1;
      rcd_lads_ven_txl.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_ven_txl.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_ven_txl.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXL.LIFNR');
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

      insert into lads_ven_txl
         (lifnr,
          txhseq,
          txlseq,
          tdformat,
          tdline)
      values
         (rcd_lads_ven_txl.lifnr,
          rcd_lads_ven_txl.txhseq,
          rcd_lads_ven_txl.txlseq,
          rcd_lads_ven_txl.tdformat,
          rcd_lads_ven_txl.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_txl;

   /**************************************************/
   /* This procedure performs the record CCD routine */
   /**************************************************/
   procedure process_record_ccd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('CCD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ven_ccd.lifnr := rcd_lads_ven_hdr.lifnr;
      rcd_lads_ven_ccd.ccdseq := rcd_lads_ven_ccd.ccdseq + 1;
      rcd_lads_ven_ccd.bukrs := lics_inbound_utility.get_variable('BUKRS');
      rcd_lads_ven_ccd.erdat := lics_inbound_utility.get_variable('ERDAT');
      rcd_lads_ven_ccd.ernam := lics_inbound_utility.get_variable('ERNAM');
      rcd_lads_ven_ccd.sperr := lics_inbound_utility.get_variable('SPERR');
      rcd_lads_ven_ccd.loevm := lics_inbound_utility.get_variable('LOEVM');
      rcd_lads_ven_ccd.zuawa := lics_inbound_utility.get_variable('ZUAWA');
      rcd_lads_ven_ccd.akont := lics_inbound_utility.get_variable('AKONT');
      rcd_lads_ven_ccd.begru := lics_inbound_utility.get_variable('BEGRU');
      rcd_lads_ven_ccd.vzskz := lics_inbound_utility.get_variable('VZSKZ');
      rcd_lads_ven_ccd.zwels := lics_inbound_utility.get_variable('ZWELS');
      rcd_lads_ven_ccd.xverr := lics_inbound_utility.get_variable('XVERR');
      rcd_lads_ven_ccd.zahls := lics_inbound_utility.get_variable('ZAHLS');
      rcd_lads_ven_ccd.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_ven_ccd.eikto := lics_inbound_utility.get_variable('EIKTO');
      rcd_lads_ven_ccd.zsabe := lics_inbound_utility.get_variable('ZSABE');
      rcd_lads_ven_ccd.fdgrv := lics_inbound_utility.get_variable('FDGRV');
      rcd_lads_ven_ccd.busab := lics_inbound_utility.get_variable('BUSAB');
      rcd_lads_ven_ccd.lnrze := lics_inbound_utility.get_variable('LNRZE');
      rcd_lads_ven_ccd.lnrzb := lics_inbound_utility.get_variable('LNRZB');
      rcd_lads_ven_ccd.zindt := lics_inbound_utility.get_variable('ZINDT');
      rcd_lads_ven_ccd.zinrt := lics_inbound_utility.get_number('ZINRT',null);
      rcd_lads_ven_ccd.datlz := lics_inbound_utility.get_variable('DATLZ');
      rcd_lads_ven_ccd.xdezv := lics_inbound_utility.get_variable('XDEZV');
      rcd_lads_ven_ccd.webtr := lics_inbound_utility.get_number('WEBTR',null);
      rcd_lads_ven_ccd.kultg := lics_inbound_utility.get_number('KULTG',null);
      rcd_lads_ven_ccd.reprf := lics_inbound_utility.get_variable('REPRF');
      rcd_lads_ven_ccd.togru := lics_inbound_utility.get_variable('TOGRU');
      rcd_lads_ven_ccd.hbkid := lics_inbound_utility.get_variable('HBKID');
      rcd_lads_ven_ccd.xpore := lics_inbound_utility.get_variable('XPORE');
      rcd_lads_ven_ccd.qsznr := lics_inbound_utility.get_variable('QSZNR');
      rcd_lads_ven_ccd.qszdt := lics_inbound_utility.get_variable('QSZDT');
      rcd_lads_ven_ccd.qsskz := lics_inbound_utility.get_variable('QSSKZ');
      rcd_lads_ven_ccd.blnkz := lics_inbound_utility.get_variable('BLNKZ');
      rcd_lads_ven_ccd.mindk := lics_inbound_utility.get_variable('MINDK');
      rcd_lads_ven_ccd.altkn := lics_inbound_utility.get_variable('ALTKN');
      rcd_lads_ven_ccd.zgrup := lics_inbound_utility.get_variable('ZGRUP');
      rcd_lads_ven_ccd.mgrup := lics_inbound_utility.get_variable('MGRUP');
      rcd_lads_ven_ccd.qsrec := lics_inbound_utility.get_variable('QSREC');
      rcd_lads_ven_ccd.qsbgr := lics_inbound_utility.get_variable('QSBGR');
      rcd_lads_ven_ccd.qland := lics_inbound_utility.get_variable('QLAND');
      rcd_lads_ven_ccd.xedip := lics_inbound_utility.get_variable('XEDIP');
      rcd_lads_ven_ccd.frgrp := lics_inbound_utility.get_variable('FRGRP');
      rcd_lads_ven_ccd.tlfxs := lics_inbound_utility.get_variable('TLFXS');
      rcd_lads_ven_ccd.intad := lics_inbound_utility.get_variable('INTAD');
      rcd_lads_ven_ccd.guzte := lics_inbound_utility.get_variable('GUZTE');
      rcd_lads_ven_ccd.gricd := lics_inbound_utility.get_variable('GRICD');
      rcd_lads_ven_ccd.gridt := lics_inbound_utility.get_variable('GRIDT');
      rcd_lads_ven_ccd.xausz := lics_inbound_utility.get_variable('XAUSZ');
      rcd_lads_ven_ccd.cerdt := lics_inbound_utility.get_variable('CERDT');
      rcd_lads_ven_ccd.togrr := lics_inbound_utility.get_variable('TOGRR');
      rcd_lads_ven_ccd.pernr := lics_inbound_utility.get_number('PERNR',null);
      rcd_lads_ven_ccd.nodel := lics_inbound_utility.get_variable('NODEL');
      rcd_lads_ven_ccd.tlfns := lics_inbound_utility.get_variable('TLFNS');
      rcd_lads_ven_ccd.gmvkzk := lics_inbound_utility.get_variable('GMVKZK');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_ven_zcc.zccseq := 0;
      rcd_lads_ven_wtx.wtxseq := 0;
      rcd_lads_ven_ctx.ctxseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_ven_ccd.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CCD.LIFNR');
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

      insert into lads_ven_ccd
         (lifnr,
          ccdseq,
          bukrs,
          erdat,
          ernam,
          sperr,
          loevm,
          zuawa,
          akont,
          begru,
          vzskz,
          zwels,
          xverr,
          zahls,
          zterm,
          eikto,
          zsabe,
          fdgrv,
          busab,
          lnrze,
          lnrzb,
          zindt,
          zinrt,
          datlz,
          xdezv,
          webtr,
          kultg,
          reprf,
          togru,
          hbkid,
          xpore,
          qsznr,
          qszdt,
          qsskz,
          blnkz,
          mindk,
          altkn,
          zgrup,
          mgrup,
          qsrec,
          qsbgr,
          qland,
          xedip,
          frgrp,
          tlfxs,
          intad,
          guzte,
          gricd,
          gridt,
          xausz,
          cerdt,
          togrr,
          pernr,
          nodel,
          tlfns,
          gmvkzk)
      values
         (rcd_lads_ven_ccd.lifnr,
          rcd_lads_ven_ccd.ccdseq,
          rcd_lads_ven_ccd.bukrs,
          rcd_lads_ven_ccd.erdat,
          rcd_lads_ven_ccd.ernam,
          rcd_lads_ven_ccd.sperr,
          rcd_lads_ven_ccd.loevm,
          rcd_lads_ven_ccd.zuawa,
          rcd_lads_ven_ccd.akont,
          rcd_lads_ven_ccd.begru,
          rcd_lads_ven_ccd.vzskz,
          rcd_lads_ven_ccd.zwels,
          rcd_lads_ven_ccd.xverr,
          rcd_lads_ven_ccd.zahls,
          rcd_lads_ven_ccd.zterm,
          rcd_lads_ven_ccd.eikto,
          rcd_lads_ven_ccd.zsabe,
          rcd_lads_ven_ccd.fdgrv,
          rcd_lads_ven_ccd.busab,
          rcd_lads_ven_ccd.lnrze,
          rcd_lads_ven_ccd.lnrzb,
          rcd_lads_ven_ccd.zindt,
          rcd_lads_ven_ccd.zinrt,
          rcd_lads_ven_ccd.datlz,
          rcd_lads_ven_ccd.xdezv,
          rcd_lads_ven_ccd.webtr,
          rcd_lads_ven_ccd.kultg,
          rcd_lads_ven_ccd.reprf,
          rcd_lads_ven_ccd.togru,
          rcd_lads_ven_ccd.hbkid,
          rcd_lads_ven_ccd.xpore,
          rcd_lads_ven_ccd.qsznr,
          rcd_lads_ven_ccd.qszdt,
          rcd_lads_ven_ccd.qsskz,
          rcd_lads_ven_ccd.blnkz,
          rcd_lads_ven_ccd.mindk,
          rcd_lads_ven_ccd.altkn,
          rcd_lads_ven_ccd.zgrup,
          rcd_lads_ven_ccd.mgrup,
          rcd_lads_ven_ccd.qsrec,
          rcd_lads_ven_ccd.qsbgr,
          rcd_lads_ven_ccd.qland,
          rcd_lads_ven_ccd.xedip,
          rcd_lads_ven_ccd.frgrp,
          rcd_lads_ven_ccd.tlfxs,
          rcd_lads_ven_ccd.intad,
          rcd_lads_ven_ccd.guzte,
          rcd_lads_ven_ccd.gricd,
          rcd_lads_ven_ccd.gridt,
          rcd_lads_ven_ccd.xausz,
          rcd_lads_ven_ccd.cerdt,
          rcd_lads_ven_ccd.togrr,
          rcd_lads_ven_ccd.pernr,
          rcd_lads_ven_ccd.nodel,
          rcd_lads_ven_ccd.tlfns,
          rcd_lads_ven_ccd.gmvkzk);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ccd;

   /**************************************************/
   /* This procedure performs the record ZCC routine */
   /**************************************************/
   procedure process_record_zcc(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('ZCC', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ven_zcc.lifnr := rcd_lads_ven_ccd.lifnr;
      rcd_lads_ven_zcc.ccdseq := rcd_lads_ven_ccd.ccdseq;
      rcd_lads_ven_zcc.zccseq := rcd_lads_ven_zcc.zccseq + 1;
      rcd_lads_ven_zcc.zpytadv := lics_inbound_utility.get_variable('ZPYTADV');

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
      if rcd_lads_ven_zcc.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - ZCC.LIFNR');
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

      insert into lads_ven_zcc
         (lifnr,
          ccdseq,
          zccseq,
          zpytadv)
      values
         (rcd_lads_ven_zcc.lifnr,
          rcd_lads_ven_zcc.ccdseq,
          rcd_lads_ven_zcc.zccseq,
          rcd_lads_ven_zcc.zpytadv);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_zcc;

   /**************************************************/
   /* This procedure performs the record WTX routine */
   /**************************************************/
   procedure process_record_wtx(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('WTX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ven_wtx.lifnr := rcd_lads_ven_ccd.lifnr;
      rcd_lads_ven_wtx.ccdseq := rcd_lads_ven_ccd.ccdseq;
      rcd_lads_ven_wtx.wtxseq := rcd_lads_ven_wtx.wtxseq + 1;
      rcd_lads_ven_wtx.witht := lics_inbound_utility.get_variable('WITHT');
      rcd_lads_ven_wtx.wt_subjct := lics_inbound_utility.get_variable('WT_SUBJCT');
      rcd_lads_ven_wtx.qsrec := lics_inbound_utility.get_variable('QSREC');
      rcd_lads_ven_wtx.wt_wtstcd := lics_inbound_utility.get_variable('WT_WTSTCD');
      rcd_lads_ven_wtx.wt_withcd := lics_inbound_utility.get_variable('WT_WITHCD');
      rcd_lads_ven_wtx.wt_exnr := lics_inbound_utility.get_variable('WT_EXNR');
      rcd_lads_ven_wtx.wt_exrt := lics_inbound_utility.get_variable('WT_EXRT');
      rcd_lads_ven_wtx.wt_exdf := lics_inbound_utility.get_variable('WT_EXDF');
      rcd_lads_ven_wtx.wt_exdt := lics_inbound_utility.get_variable('WT_EXDT');
      rcd_lads_ven_wtx.wt_wtexrs := lics_inbound_utility.get_variable('WT_WTEXRS');

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
      if rcd_lads_ven_wtx.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - WTX.LIFNR');
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

      insert into lads_ven_wtx
         (lifnr,
          ccdseq,
          wtxseq,
          witht,
          wt_subjct,
          qsrec,
          wt_wtstcd,
          wt_withcd,
          wt_exnr,
          wt_exrt,
          wt_exdf,
          wt_exdt,
          wt_wtexrs)
      values
         (rcd_lads_ven_wtx.lifnr,
          rcd_lads_ven_wtx.ccdseq,
          rcd_lads_ven_wtx.wtxseq,
          rcd_lads_ven_wtx.witht,
          rcd_lads_ven_wtx.wt_subjct,
          rcd_lads_ven_wtx.qsrec,
          rcd_lads_ven_wtx.wt_wtstcd,
          rcd_lads_ven_wtx.wt_withcd,
          rcd_lads_ven_wtx.wt_exnr,
          rcd_lads_ven_wtx.wt_exrt,
          rcd_lads_ven_wtx.wt_exdf,
          rcd_lads_ven_wtx.wt_exdt,
          rcd_lads_ven_wtx.wt_wtexrs);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_wtx;

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
      rcd_lads_ven_ctx.lifnr := rcd_lads_ven_ccd.lifnr;
      rcd_lads_ven_ctx.ccdseq := rcd_lads_ven_ccd.ccdseq;
      rcd_lads_ven_ctx.ctxseq := rcd_lads_ven_ctx.ctxseq + 1;
      rcd_lads_ven_ctx.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_ven_ctx.tdname := lics_inbound_utility.get_variable('TDNAME');
      rcd_lads_ven_ctx.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_ven_ctx.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_ven_ctx.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_ven_ctx.tdsprasiso := lics_inbound_utility.get_variable('TDSPRASISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_ven_ctd.ctdseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_ven_ctx.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CTX.LIFNR');
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

      insert into lads_ven_ctx
         (lifnr,
          ccdseq,
          ctxseq,
          tdobject,
          tdname,
          tdid,
          tdspras,
          tdtexttype,
          tdsprasiso)
      values
         (rcd_lads_ven_ctx.lifnr,
          rcd_lads_ven_ctx.ccdseq,
          rcd_lads_ven_ctx.ctxseq,
          rcd_lads_ven_ctx.tdobject,
          rcd_lads_ven_ctx.tdname,
          rcd_lads_ven_ctx.tdid,
          rcd_lads_ven_ctx.tdspras,
          rcd_lads_ven_ctx.tdtexttype,
          rcd_lads_ven_ctx.tdsprasiso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctx;

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
      rcd_lads_ven_ctd.lifnr := rcd_lads_ven_ctx.lifnr;
      rcd_lads_ven_ctd.ccdseq := rcd_lads_ven_ctx.ccdseq;
      rcd_lads_ven_ctd.ctxseq := rcd_lads_ven_ctx.ctxseq;
      rcd_lads_ven_ctd.ctdseq := rcd_lads_ven_ctd.ctdseq + 1;
      rcd_lads_ven_ctd.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_ven_ctd.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_ven_ctd.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - CTD.LIFNR');
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

      insert into lads_ven_ctd
         (lifnr,
          ccdseq,
          ctxseq,
          ctdseq,
          tdformat,
          tdline)
      values
         (rcd_lads_ven_ctd.lifnr,
          rcd_lads_ven_ctd.ccdseq,
          rcd_lads_ven_ctd.ctxseq,
          rcd_lads_ven_ctd.ctdseq,
          rcd_lads_ven_ctd.tdformat,
          rcd_lads_ven_ctd.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctd;

   /**************************************************/
   /* This procedure performs the record POH routine */
   /**************************************************/
   procedure process_record_poh(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('POH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ven_poh.lifnr := rcd_lads_ven_hdr.lifnr;
      rcd_lads_ven_poh.pohseq := rcd_lads_ven_poh.pohseq + 1;
      rcd_lads_ven_poh.ekorg := lics_inbound_utility.get_variable('EKORG');
      rcd_lads_ven_poh.erdat := lics_inbound_utility.get_variable('ERDAT');
      rcd_lads_ven_poh.ernam := lics_inbound_utility.get_variable('ERNAM');
      rcd_lads_ven_poh.sperm := lics_inbound_utility.get_variable('SPERM');
      rcd_lads_ven_poh.loevm := lics_inbound_utility.get_variable('LOEVM');
      rcd_lads_ven_poh.lfabc := lics_inbound_utility.get_variable('LFABC');
      rcd_lads_ven_poh.waers := lics_inbound_utility.get_variable('WAERS');
      rcd_lads_ven_poh.verkf := lics_inbound_utility.get_variable('VERKF');
      rcd_lads_ven_poh.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_ven_poh.minbw := lics_inbound_utility.get_number('MINBW',null);
      rcd_lads_ven_poh.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_ven_poh.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_lads_ven_poh.inco2 := lics_inbound_utility.get_variable('INCO2');
      rcd_lads_ven_poh.webre := lics_inbound_utility.get_variable('WEBRE');
      rcd_lads_ven_poh.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_ven_poh.kalsk := lics_inbound_utility.get_variable('KALSK');
      rcd_lads_ven_poh.kzaut := lics_inbound_utility.get_variable('KZAUT');
      rcd_lads_ven_poh.expvz := lics_inbound_utility.get_variable('EXPVZ');
      rcd_lads_ven_poh.zolla := lics_inbound_utility.get_variable('ZOLLA');
      rcd_lads_ven_poh.meprf := lics_inbound_utility.get_variable('MEPRF');
      rcd_lads_ven_poh.ekgrp := lics_inbound_utility.get_variable('EKGRP');
      rcd_lads_ven_poh.bolre := lics_inbound_utility.get_variable('BOLRE');
      rcd_lads_ven_poh.umsae := lics_inbound_utility.get_variable('UMSAE');
      rcd_lads_ven_poh.xersy := lics_inbound_utility.get_variable('XERSY');
      rcd_lads_ven_poh.plifz := lics_inbound_utility.get_number('PLIFZ',null);
      rcd_lads_ven_poh.mrppp := lics_inbound_utility.get_variable('MRPPP');
      rcd_lads_ven_poh.lfrhy := lics_inbound_utility.get_variable('LFRHY');
      rcd_lads_ven_poh.liefr := lics_inbound_utility.get_variable('LIEFR');
      rcd_lads_ven_poh.libes := lics_inbound_utility.get_variable('LIBES');
      rcd_lads_ven_poh.lipre := lics_inbound_utility.get_variable('LIPRE');
      rcd_lads_ven_poh.liser := lics_inbound_utility.get_variable('LISER');
      rcd_lads_ven_poh.boind := lics_inbound_utility.get_variable('BOIND');
      rcd_lads_ven_poh.prfre := lics_inbound_utility.get_variable('PRFRE');
      rcd_lads_ven_poh.nrgew := lics_inbound_utility.get_variable('NRGEW');
      rcd_lads_ven_poh.blind := lics_inbound_utility.get_variable('BLIND');
      rcd_lads_ven_poh.kzret := lics_inbound_utility.get_variable('KZRET');
      rcd_lads_ven_poh.skrit := lics_inbound_utility.get_variable('SKRIT');
      rcd_lads_ven_poh.bstae := lics_inbound_utility.get_variable('BSTAE');
      rcd_lads_ven_poh.rdprf := lics_inbound_utility.get_variable('RDPRF');
      rcd_lads_ven_poh.megru := lics_inbound_utility.get_variable('MEGRU');
      rcd_lads_ven_poh.vensl := lics_inbound_utility.get_number('VENSL',null);
      rcd_lads_ven_poh.bopnr := lics_inbound_utility.get_variable('BOPNR');
      rcd_lads_ven_poh.xersr := lics_inbound_utility.get_variable('XERSR');
      rcd_lads_ven_poh.eikto := lics_inbound_utility.get_variable('EIKTO');
      rcd_lads_ven_poh.paprf := lics_inbound_utility.get_variable('PAPRF');
      rcd_lads_ven_poh.agrel := lics_inbound_utility.get_variable('AGREL');
      rcd_lads_ven_poh.xnbwy := lics_inbound_utility.get_variable('XNBWY');
      rcd_lads_ven_poh.vsbed := lics_inbound_utility.get_variable('VSBED');
      rcd_lads_ven_poh.lebre := lics_inbound_utility.get_variable('LEBRE');
      rcd_lads_ven_poh.minbw2 := lics_inbound_utility.get_variable('MINBW2');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_ven_pom.pomseq := 0;
      rcd_lads_ven_ptx.ptxseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_ven_poh.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - POH.LIFNR');
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

      insert into lads_ven_poh
         (lifnr,
          pohseq,
          ekorg,
          erdat,
          ernam,
          sperm,
          loevm,
          lfabc,
          waers,
          verkf,
          telf1,
          minbw,
          zterm,
          inco1,
          inco2,
          webre,
          kzabs,
          kalsk,
          kzaut,
          expvz,
          zolla,
          meprf,
          ekgrp,
          bolre,
          umsae,
          xersy,
          plifz,
          mrppp,
          lfrhy,
          liefr,
          libes,
          lipre,
          liser,
          boind,
          prfre,
          nrgew,
          blind,
          kzret,
          skrit,
          bstae,
          rdprf,
          megru,
          vensl,
          bopnr,
          xersr,
          eikto,
          paprf,
          agrel,
          xnbwy,
          vsbed,
          lebre,
          minbw2)
      values
         (rcd_lads_ven_poh.lifnr,
          rcd_lads_ven_poh.pohseq,
          rcd_lads_ven_poh.ekorg,
          rcd_lads_ven_poh.erdat,
          rcd_lads_ven_poh.ernam,
          rcd_lads_ven_poh.sperm,
          rcd_lads_ven_poh.loevm,
          rcd_lads_ven_poh.lfabc,
          rcd_lads_ven_poh.waers,
          rcd_lads_ven_poh.verkf,
          rcd_lads_ven_poh.telf1,
          rcd_lads_ven_poh.minbw,
          rcd_lads_ven_poh.zterm,
          rcd_lads_ven_poh.inco1,
          rcd_lads_ven_poh.inco2,
          rcd_lads_ven_poh.webre,
          rcd_lads_ven_poh.kzabs,
          rcd_lads_ven_poh.kalsk,
          rcd_lads_ven_poh.kzaut,
          rcd_lads_ven_poh.expvz,
          rcd_lads_ven_poh.zolla,
          rcd_lads_ven_poh.meprf,
          rcd_lads_ven_poh.ekgrp,
          rcd_lads_ven_poh.bolre,
          rcd_lads_ven_poh.umsae,
          rcd_lads_ven_poh.xersy,
          rcd_lads_ven_poh.plifz,
          rcd_lads_ven_poh.mrppp,
          rcd_lads_ven_poh.lfrhy,
          rcd_lads_ven_poh.liefr,
          rcd_lads_ven_poh.libes,
          rcd_lads_ven_poh.lipre,
          rcd_lads_ven_poh.liser,
          rcd_lads_ven_poh.boind,
          rcd_lads_ven_poh.prfre,
          rcd_lads_ven_poh.nrgew,
          rcd_lads_ven_poh.blind,
          rcd_lads_ven_poh.kzret,
          rcd_lads_ven_poh.skrit,
          rcd_lads_ven_poh.bstae,
          rcd_lads_ven_poh.rdprf,
          rcd_lads_ven_poh.megru,
          rcd_lads_ven_poh.vensl,
          rcd_lads_ven_poh.bopnr,
          rcd_lads_ven_poh.xersr,
          rcd_lads_ven_poh.eikto,
          rcd_lads_ven_poh.paprf,
          rcd_lads_ven_poh.agrel,
          rcd_lads_ven_poh.xnbwy,
          rcd_lads_ven_poh.vsbed,
          rcd_lads_ven_poh.lebre,
          rcd_lads_ven_poh.minbw2);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_poh;

   /**************************************************/
   /* This procedure performs the record POM routine */
   /**************************************************/
   procedure process_record_pom(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('POM', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ven_pom.lifnr := rcd_lads_ven_poh.lifnr;
      rcd_lads_ven_pom.pohseq := rcd_lads_ven_poh.pohseq;
      rcd_lads_ven_pom.pomseq := rcd_lads_ven_pom.pomseq + 1;
      rcd_lads_ven_pom.ltsnr := lics_inbound_utility.get_variable('LTSNR');
      rcd_lads_ven_pom.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_ven_pom.erdat := lics_inbound_utility.get_variable('ERDAT');
      rcd_lads_ven_pom.ernam := lics_inbound_utility.get_variable('ERNAM');
      rcd_lads_ven_pom.sperm := lics_inbound_utility.get_variable('SPERM');
      rcd_lads_ven_pom.loevm := lics_inbound_utility.get_variable('LOEVM');
      rcd_lads_ven_pom.lfabc := lics_inbound_utility.get_variable('LFABC');
      rcd_lads_ven_pom.waers := lics_inbound_utility.get_variable('WAERS');
      rcd_lads_ven_pom.verkf := lics_inbound_utility.get_variable('VERKF');
      rcd_lads_ven_pom.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_ven_pom.minbw := lics_inbound_utility.get_number('MINBW',null);
      rcd_lads_ven_pom.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_ven_pom.inco1 := lics_inbound_utility.get_variable('INCO1');
      rcd_lads_ven_pom.inco2 := lics_inbound_utility.get_variable('INCO2');
      rcd_lads_ven_pom.webre := lics_inbound_utility.get_variable('WEBRE');
      rcd_lads_ven_pom.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_ven_pom.kalsk := lics_inbound_utility.get_variable('KALSK');
      rcd_lads_ven_pom.kzaut := lics_inbound_utility.get_variable('KZAUT');
      rcd_lads_ven_pom.expvz := lics_inbound_utility.get_variable('EXPVZ');
      rcd_lads_ven_pom.zolla := lics_inbound_utility.get_variable('ZOLLA');
      rcd_lads_ven_pom.meprf := lics_inbound_utility.get_variable('MEPRF');
      rcd_lads_ven_pom.ekgrp := lics_inbound_utility.get_variable('EKGRP');
      rcd_lads_ven_pom.bolre := lics_inbound_utility.get_variable('BOLRE');
      rcd_lads_ven_pom.umsae := lics_inbound_utility.get_variable('UMSAE');
      rcd_lads_ven_pom.xersy := lics_inbound_utility.get_variable('XERSY');
      rcd_lads_ven_pom.plifz := lics_inbound_utility.get_number('PLIFZ',null);
      rcd_lads_ven_pom.mrppp := lics_inbound_utility.get_variable('MRPPP');
      rcd_lads_ven_pom.lfrhy := lics_inbound_utility.get_variable('LFRHY');
      rcd_lads_ven_pom.liefr := lics_inbound_utility.get_variable('LIEFR');
      rcd_lads_ven_pom.libes := lics_inbound_utility.get_variable('LIBES');
      rcd_lads_ven_pom.lipre := lics_inbound_utility.get_variable('LIPRE');
      rcd_lads_ven_pom.liser := lics_inbound_utility.get_variable('LISER');
      rcd_lads_ven_pom.dispo := lics_inbound_utility.get_variable('DISPO');
      rcd_lads_ven_pom.bstae := lics_inbound_utility.get_variable('BSTAE');
      rcd_lads_ven_pom.rdprf := lics_inbound_utility.get_variable('RDPRF');
      rcd_lads_ven_pom.megru := lics_inbound_utility.get_variable('MEGRU');
      rcd_lads_ven_pom.bopnr := lics_inbound_utility.get_variable('BOPNR');
      rcd_lads_ven_pom.xersr := lics_inbound_utility.get_variable('XERSR');
      rcd_lads_ven_pom.abueb := lics_inbound_utility.get_variable('ABUEB');
      rcd_lads_ven_pom.paprf := lics_inbound_utility.get_variable('PAPRF');
      rcd_lads_ven_pom.xnbwy := lics_inbound_utility.get_variable('XNBWY');
      rcd_lads_ven_pom.lebre := lics_inbound_utility.get_variable('LEBRE');
      rcd_lads_ven_pom.minbw2 := lics_inbound_utility.get_variable('MINBW2');

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
      if rcd_lads_ven_pom.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - POM.LIFNR');
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

      insert into lads_ven_pom
         (lifnr,
          pohseq,
          pomseq,
          ltsnr,
          werks,
          erdat,
          ernam,
          sperm,
          loevm,
          lfabc,
          waers,
          verkf,
          telf1,
          minbw,
          zterm,
          inco1,
          inco2,
          webre,
          kzabs,
          kalsk,
          kzaut,
          expvz,
          zolla,
          meprf,
          ekgrp,
          bolre,
          umsae,
          xersy,
          plifz,
          mrppp,
          lfrhy,
          liefr,
          libes,
          lipre,
          liser,
          dispo,
          bstae,
          rdprf,
          megru,
          bopnr,
          xersr,
          abueb,
          paprf,
          xnbwy,
          lebre,
          minbw2)
      values
         (rcd_lads_ven_pom.lifnr,
          rcd_lads_ven_pom.pohseq,
          rcd_lads_ven_pom.pomseq,
          rcd_lads_ven_pom.ltsnr,
          rcd_lads_ven_pom.werks,
          rcd_lads_ven_pom.erdat,
          rcd_lads_ven_pom.ernam,
          rcd_lads_ven_pom.sperm,
          rcd_lads_ven_pom.loevm,
          rcd_lads_ven_pom.lfabc,
          rcd_lads_ven_pom.waers,
          rcd_lads_ven_pom.verkf,
          rcd_lads_ven_pom.telf1,
          rcd_lads_ven_pom.minbw,
          rcd_lads_ven_pom.zterm,
          rcd_lads_ven_pom.inco1,
          rcd_lads_ven_pom.inco2,
          rcd_lads_ven_pom.webre,
          rcd_lads_ven_pom.kzabs,
          rcd_lads_ven_pom.kalsk,
          rcd_lads_ven_pom.kzaut,
          rcd_lads_ven_pom.expvz,
          rcd_lads_ven_pom.zolla,
          rcd_lads_ven_pom.meprf,
          rcd_lads_ven_pom.ekgrp,
          rcd_lads_ven_pom.bolre,
          rcd_lads_ven_pom.umsae,
          rcd_lads_ven_pom.xersy,
          rcd_lads_ven_pom.plifz,
          rcd_lads_ven_pom.mrppp,
          rcd_lads_ven_pom.lfrhy,
          rcd_lads_ven_pom.liefr,
          rcd_lads_ven_pom.libes,
          rcd_lads_ven_pom.lipre,
          rcd_lads_ven_pom.liser,
          rcd_lads_ven_pom.dispo,
          rcd_lads_ven_pom.bstae,
          rcd_lads_ven_pom.rdprf,
          rcd_lads_ven_pom.megru,
          rcd_lads_ven_pom.bopnr,
          rcd_lads_ven_pom.xersr,
          rcd_lads_ven_pom.abueb,
          rcd_lads_ven_pom.paprf,
          rcd_lads_ven_pom.xnbwy,
          rcd_lads_ven_pom.lebre,
          rcd_lads_ven_pom.minbw2);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pom;

   /**************************************************/
   /* This procedure performs the record PTX routine */
   /**************************************************/
   procedure process_record_ptx(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PTX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ven_ptx.lifnr := rcd_lads_ven_poh.lifnr;
      rcd_lads_ven_ptx.pohseq := rcd_lads_ven_poh.pohseq;
      rcd_lads_ven_ptx.ptxseq := rcd_lads_ven_ptx.ptxseq + 1;
      rcd_lads_ven_ptx.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_ven_ptx.tdname := lics_inbound_utility.get_variable('TDNAME');
      rcd_lads_ven_ptx.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_ven_ptx.tdspras := lics_inbound_utility.get_variable('TDSPRAS');
      rcd_lads_ven_ptx.tdtexttype := lics_inbound_utility.get_variable('TDTEXTTYPE');
      rcd_lads_ven_ptx.tdsprasiso := lics_inbound_utility.get_variable('TDSPRASISO');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_ven_ptd.ptdseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_ven_ptx.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PTX.LIFNR');
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

      insert into lads_ven_ptx
         (lifnr,
          pohseq,
          ptxseq,
          tdobject,
          tdname,
          tdid,
          tdspras,
          tdtexttype,
          tdsprasiso)
      values
         (rcd_lads_ven_ptx.lifnr,
          rcd_lads_ven_ptx.pohseq,
          rcd_lads_ven_ptx.ptxseq,
          rcd_lads_ven_ptx.tdobject,
          rcd_lads_ven_ptx.tdname,
          rcd_lads_ven_ptx.tdid,
          rcd_lads_ven_ptx.tdspras,
          rcd_lads_ven_ptx.tdtexttype,
          rcd_lads_ven_ptx.tdsprasiso);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ptx;

   /**************************************************/
   /* This procedure performs the record PTD routine */
   /**************************************************/
   procedure process_record_ptd(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PTD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ven_ptd.lifnr := rcd_lads_ven_ptx.lifnr;
      rcd_lads_ven_ptd.pohseq := rcd_lads_ven_ptx.pohseq;
      rcd_lads_ven_ptd.ptxseq := rcd_lads_ven_ptx.ptxseq;
      rcd_lads_ven_ptd.ptdseq := rcd_lads_ven_ptd.ptdseq + 1;
      rcd_lads_ven_ptd.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_ven_ptd.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_ven_ptd.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PTD.LIFNR');
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

      insert into lads_ven_ptd
         (lifnr,
          pohseq,
          ptxseq,
          ptdseq,
          tdformat,
          tdline)
      values
         (rcd_lads_ven_ptd.lifnr,
          rcd_lads_ven_ptd.pohseq,
          rcd_lads_ven_ptd.ptxseq,
          rcd_lads_ven_ptd.ptdseq,
          rcd_lads_ven_ptd.tdformat,
          rcd_lads_ven_ptd.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ptd;

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
      rcd_lads_ven_bnk.lifnr := rcd_lads_ven_hdr.lifnr;
      rcd_lads_ven_bnk.bnkseq := rcd_lads_ven_bnk.bnkseq + 1;
      rcd_lads_ven_bnk.banks := lics_inbound_utility.get_variable('BANKS');
      rcd_lads_ven_bnk.bankl := lics_inbound_utility.get_variable('BANKL');
      rcd_lads_ven_bnk.bankn := lics_inbound_utility.get_variable('BANKN');
      rcd_lads_ven_bnk.bkont := lics_inbound_utility.get_variable('BKONT');
      rcd_lads_ven_bnk.bvtyp := lics_inbound_utility.get_variable('BVTYP');
      rcd_lads_ven_bnk.xezer := lics_inbound_utility.get_variable('XEZER');
      rcd_lads_ven_bnk.banka := lics_inbound_utility.get_variable('BANKA');
      rcd_lads_ven_bnk.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_ven_bnk.swift := lics_inbound_utility.get_variable('SWIFT');
      rcd_lads_ven_bnk.bgrup := lics_inbound_utility.get_variable('BGRUP');
      rcd_lads_ven_bnk.xpgro := lics_inbound_utility.get_variable('XPGRO');
      rcd_lads_ven_bnk.bnklz := lics_inbound_utility.get_variable('BNKLZ');
      rcd_lads_ven_bnk.pskto := lics_inbound_utility.get_variable('PSKTO');
      rcd_lads_ven_bnk.bkref := lics_inbound_utility.get_variable('BKREF');
      rcd_lads_ven_bnk.brnch := lics_inbound_utility.get_variable('BRNCH');
      rcd_lads_ven_bnk.prov2 := lics_inbound_utility.get_variable('PROV2');
      rcd_lads_ven_bnk.stra2 := lics_inbound_utility.get_variable('STRA2');
      rcd_lads_ven_bnk.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_ven_bnk.koinh := lics_inbound_utility.get_variable('KOINH');
      rcd_lads_ven_bnk.kovon := lics_inbound_utility.get_variable('KOVON');
      rcd_lads_ven_bnk.kobis := lics_inbound_utility.get_variable('KOBIS');

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
      if rcd_lads_ven_bnk.lifnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - BNK.LIFNR');
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

      insert into lads_ven_bnk
         (lifnr,
          bnkseq,
          banks,
          bankl,
          bankn,
          bkont,
          bvtyp,
          xezer,
          banka,
          ort01,
          swift,
          bgrup,
          xpgro,
          bnklz,
          pskto,
          bkref,
          brnch,
          prov2,
          stra2,
          ort02,
          koinh,
          kovon,
          kobis)
      values
         (rcd_lads_ven_bnk.lifnr,
          rcd_lads_ven_bnk.bnkseq,
          rcd_lads_ven_bnk.banks,
          rcd_lads_ven_bnk.bankl,
          rcd_lads_ven_bnk.bankn,
          rcd_lads_ven_bnk.bkont,
          rcd_lads_ven_bnk.bvtyp,
          rcd_lads_ven_bnk.xezer,
          rcd_lads_ven_bnk.banka,
          rcd_lads_ven_bnk.ort01,
          rcd_lads_ven_bnk.swift,
          rcd_lads_ven_bnk.bgrup,
          rcd_lads_ven_bnk.xpgro,
          rcd_lads_ven_bnk.bnklz,
          rcd_lads_ven_bnk.pskto,
          rcd_lads_ven_bnk.bkref,
          rcd_lads_ven_bnk.brnch,
          rcd_lads_ven_bnk.prov2,
          rcd_lads_ven_bnk.stra2,
          rcd_lads_ven_bnk.ort02,
          rcd_lads_ven_bnk.koinh,
          rcd_lads_ven_bnk.kovon,
          rcd_lads_ven_bnk.kobis);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_bnk;

end lads_atllad19;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad19 for lads_app.lads_atllad19;
grant execute on lads_atllad19 to lics_app;
