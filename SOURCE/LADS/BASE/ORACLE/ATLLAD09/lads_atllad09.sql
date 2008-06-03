/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad09
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad09 - Inbound Stock Transfer and Purchase Order Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2008/05   Trevor Keon    Added calls to monitor before and after procedure

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad09 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad09;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad09 as

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
   procedure process_record_con(par_record in varchar2);
   procedure process_record_pnr(par_record in varchar2);
   procedure process_record_ref(par_record in varchar2);
   procedure process_record_del(par_record in varchar2);
   procedure process_record_pay(par_record in varchar2);
   procedure process_record_hti(par_record in varchar2);
   procedure process_record_htx(par_record in varchar2);
   procedure process_record_gen(par_record in varchar2);
   procedure process_record_sch(par_record in varchar2);
   procedure process_record_itp(par_record in varchar2);
   procedure process_record_pad(par_record in varchar2);
   procedure process_record_oid(par_record in varchar2);
   procedure process_record_smy(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_sto_po_hdr lads_sto_po_hdr%rowtype;
   rcd_lads_sto_po_org lads_sto_po_org%rowtype;
   rcd_lads_sto_po_dat lads_sto_po_dat%rowtype;
   rcd_lads_sto_po_con lads_sto_po_con%rowtype;
   rcd_lads_sto_po_pnr lads_sto_po_pnr%rowtype;
   rcd_lads_sto_po_ref lads_sto_po_ref%rowtype;
   rcd_lads_sto_po_del lads_sto_po_del%rowtype;
   rcd_lads_sto_po_pay lads_sto_po_pay%rowtype;
   rcd_lads_sto_po_hti lads_sto_po_hti%rowtype;
   rcd_lads_sto_po_htx lads_sto_po_htx%rowtype;
   rcd_lads_sto_po_gen lads_sto_po_gen%rowtype;
   rcd_lads_sto_po_sch lads_sto_po_sch%rowtype;
   rcd_lads_sto_po_itp lads_sto_po_itp%rowtype;
   rcd_lads_sto_po_pad lads_sto_po_pad%rowtype;
   rcd_lads_sto_po_oid lads_sto_po_oid%rowtype;
   rcd_lads_sto_po_smy lads_sto_po_smy%rowtype;

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
      lics_inbound_utility.set_definition('HDR','BELNR',35);
      lics_inbound_utility.set_definition('HDR','BSART',4);
      lics_inbound_utility.set_definition('HDR','CURCY',3);
      lics_inbound_utility.set_definition('HDR','WKURS',12);
      lics_inbound_utility.set_definition('HDR','ZTERM',17);
      lics_inbound_utility.set_definition('HDR','RECIPNT_NO',10);
      lics_inbound_utility.set_definition('HDR','ACTION',3);
      lics_inbound_utility.set_definition('HDR','KZABS',1);
      lics_inbound_utility.set_definition('HDR','HWAER',3);
      lics_inbound_utility.set_definition('HDR','KUNDEUINR',20);
      lics_inbound_utility.set_definition('HDR','EIGENUINR',20);
      lics_inbound_utility.set_definition('HDR','NTGEW',18);
      lics_inbound_utility.set_definition('HDR','BRGEW',18);
      lics_inbound_utility.set_definition('HDR','GEWEI',3);
      lics_inbound_utility.set_definition('HDR','FKART_RL',4);
      lics_inbound_utility.set_definition('HDR','ABLAD',25);
      lics_inbound_utility.set_definition('HDR','BSTZD',4);
      lics_inbound_utility.set_definition('HDR','VSART',2);
      lics_inbound_utility.set_definition('HDR','VSART_BEZ',20);
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
      lics_inbound_utility.set_definition('PNR','PARTN',17);
      lics_inbound_utility.set_definition('PNR','PARVW',3);
      lics_inbound_utility.set_definition('PNR','BNAME',35);
      lics_inbound_utility.set_definition('PNR','PAORG',30);
      lics_inbound_utility.set_definition('PNR','ORGTX',35);
      lics_inbound_utility.set_definition('PNR','PAGRU',30);
      lics_inbound_utility.set_definition('PNR','ILNNR',70);
      lics_inbound_utility.set_definition('PNR','LIFNR',17);
      lics_inbound_utility.set_definition('PNR','NAME1',35);
      lics_inbound_utility.set_definition('PNR','NAME2',35);
      lics_inbound_utility.set_definition('PNR','NAME3',35);
      lics_inbound_utility.set_definition('PNR','NAME4',35);
      lics_inbound_utility.set_definition('PNR','ANRED',15);
      lics_inbound_utility.set_definition('PNR','STOCK',6);
      lics_inbound_utility.set_definition('PNR','HAUSN',6);
      lics_inbound_utility.set_definition('PNR','STRAS',35);
      lics_inbound_utility.set_definition('PNR','STRS2',35);
      lics_inbound_utility.set_definition('PNR','ORT02',35);
      lics_inbound_utility.set_definition('PNR','REGIO',3);
      lics_inbound_utility.set_definition('PNR','PSTLZ',9);
      lics_inbound_utility.set_definition('PNR','ORT01',35);
      lics_inbound_utility.set_definition('PNR','PFACH',35);
      lics_inbound_utility.set_definition('PNR','PFORT',35);
      lics_inbound_utility.set_definition('PNR','PSTL2',9);
      lics_inbound_utility.set_definition('PNR','COUNC',9);
      lics_inbound_utility.set_definition('PNR','LAND1',3);
      lics_inbound_utility.set_definition('PNR','ISOAL',2);
      lics_inbound_utility.set_definition('PNR','SPRAS',1);
      lics_inbound_utility.set_definition('PNR','SPRAS_ISO',2);
      lics_inbound_utility.set_definition('PNR','PARNR',30);
      lics_inbound_utility.set_definition('PNR','TELF1',25);
      lics_inbound_utility.set_definition('PNR','TELF2',25);
      lics_inbound_utility.set_definition('PNR','PERNR',30);
      lics_inbound_utility.set_definition('PNR','TELFX',25);
      lics_inbound_utility.set_definition('PNR','ABLAD',35);
      lics_inbound_utility.set_definition('PNR','IHREZ',30);
      lics_inbound_utility.set_definition('PNR','KNREF',30);
      lics_inbound_utility.set_definition('PNR','TITLE',15);
      /*-*/
      lics_inbound_utility.set_definition('REF','IDOC_REF',3);
      lics_inbound_utility.set_definition('REF','QUALF',3);
      lics_inbound_utility.set_definition('REF','REFNR',35);
      lics_inbound_utility.set_definition('REF','DATUM',8);
      lics_inbound_utility.set_definition('REF','UZEIT',6);
      lics_inbound_utility.set_definition('REF','POSNR',6);
      /*-*/
      lics_inbound_utility.set_definition('DEL','IDOC_DEL',3);
      lics_inbound_utility.set_definition('DEL','QUALF',3);
      lics_inbound_utility.set_definition('DEL','LKOND',3);
      lics_inbound_utility.set_definition('DEL','LKTEXT',70);
      /*-*/
      lics_inbound_utility.set_definition('PAY','IDOC_PAY',3);
      lics_inbound_utility.set_definition('PAY','QUALF',3);
      lics_inbound_utility.set_definition('PAY','TAGE',8);
      lics_inbound_utility.set_definition('PAY','PRZNT',8);
      lics_inbound_utility.set_definition('PAY','ZTERM_TXT',70);
      /*-*/
      lics_inbound_utility.set_definition('HTI','IDOC_HTI',3);
      lics_inbound_utility.set_definition('HTI','TDID',4);
      lics_inbound_utility.set_definition('HTI','TSSPRAS',3);
      lics_inbound_utility.set_definition('HTI','TSSPRAS_ISO',2);
      lics_inbound_utility.set_definition('HTI','TDOBJECT',10);
      lics_inbound_utility.set_definition('HTI','TDOBNAME',70);
      /*-*/
      lics_inbound_utility.set_definition('HTX','IDOC_HTX',3);
      lics_inbound_utility.set_definition('HTX','TDFORMAT',2);
      lics_inbound_utility.set_definition('HTX','TDLINE',70);
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
      lics_inbound_utility.set_definition('SCH','IDOC_SCH',3);
      lics_inbound_utility.set_definition('SCH','WMENG',15);
      lics_inbound_utility.set_definition('SCH','AMENG',15);
      lics_inbound_utility.set_definition('SCH','EDATU',8);
      lics_inbound_utility.set_definition('SCH','EZEIT',6);
      lics_inbound_utility.set_definition('SCH','EDATU_OLD',8);
      lics_inbound_utility.set_definition('SCH','EZEIT_OLD',6);
      lics_inbound_utility.set_definition('SCH','ACTION',3);
      /*-*/
      lics_inbound_utility.set_definition('ITP','IDOC_ITP',3);
      lics_inbound_utility.set_definition('ITP','PARVW',3);
      lics_inbound_utility.set_definition('ITP','PARTN',17);
      lics_inbound_utility.set_definition('ITP','LIFNR',17);
      lics_inbound_utility.set_definition('ITP','NAME1',35);
      lics_inbound_utility.set_definition('ITP','NAME2',35);
      lics_inbound_utility.set_definition('ITP','NAME3',35);
      lics_inbound_utility.set_definition('ITP','NAME4',35);
      lics_inbound_utility.set_definition('ITP','ANRED',15);
      lics_inbound_utility.set_definition('ITP','HAUSN',6);
      lics_inbound_utility.set_definition('ITP','STOCK',6);
      lics_inbound_utility.set_definition('ITP','STRAS',35);
      lics_inbound_utility.set_definition('ITP','STRS2',35);
      lics_inbound_utility.set_definition('ITP','ORT02',35);
      lics_inbound_utility.set_definition('ITP','REGIO',3);
      lics_inbound_utility.set_definition('ITP','ORT01',35);
      lics_inbound_utility.set_definition('ITP','PSTLZ',9);
      lics_inbound_utility.set_definition('ITP','PFACH',35);
      lics_inbound_utility.set_definition('ITP','PFORT',35);
      lics_inbound_utility.set_definition('ITP','PSTL2',9);
      lics_inbound_utility.set_definition('ITP','COUNC',9);
      lics_inbound_utility.set_definition('ITP','LAND1',3);
      lics_inbound_utility.set_definition('ITP','ISOAL',2);
      lics_inbound_utility.set_definition('ITP','ISONU',2);
      lics_inbound_utility.set_definition('ITP','ABLAD',35);
      lics_inbound_utility.set_definition('ITP','PARNR',30);
      lics_inbound_utility.set_definition('ITP','TELF1',25);
      lics_inbound_utility.set_definition('ITP','TELF2',25);
      lics_inbound_utility.set_definition('ITP','PERNR',30);
      lics_inbound_utility.set_definition('ITP','TELBX',25);
      lics_inbound_utility.set_definition('ITP','TELFX',25);
      lics_inbound_utility.set_definition('ITP','TELTX',25);
      lics_inbound_utility.set_definition('ITP','TELX1',25);
      lics_inbound_utility.set_definition('ITP','PARGE',1);
      lics_inbound_utility.set_definition('ITP','FCODE',20);
      lics_inbound_utility.set_definition('ITP','IHREZ',30);
      lics_inbound_utility.set_definition('ITP','BNAME',35);
      lics_inbound_utility.set_definition('ITP','PAORG',30);
      lics_inbound_utility.set_definition('ITP','ORGTX',35);
      lics_inbound_utility.set_definition('ITP','PAGRU',30);
      lics_inbound_utility.set_definition('ITP','KNREF',30);
      lics_inbound_utility.set_definition('ITP','ILNNR',70);
      lics_inbound_utility.set_definition('ITP','SPRAS',1);
      lics_inbound_utility.set_definition('ITP','SPRAS_ISO',2);
      lics_inbound_utility.set_definition('ITP','TITLE',15);
      /*-*/
      lics_inbound_utility.set_definition('PAD','IDOC_PAD',3);
      lics_inbound_utility.set_definition('PAD','QUALP',3);
      lics_inbound_utility.set_definition('PAD','STDPN',70);
      /*-*/
      lics_inbound_utility.set_definition('OID','IDOC_OID',3);
      lics_inbound_utility.set_definition('OID','QUALF',3);
      lics_inbound_utility.set_definition('OID','IDTNR',35);
      lics_inbound_utility.set_definition('OID','KTEXT',70);
      lics_inbound_utility.set_definition('OID','MFRNR',10);
      lics_inbound_utility.set_definition('OID','MFRPN',42);
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
         when 'CON' then process_record_con(par_record);
         when 'PNR' then process_record_pnr(par_record);
         when 'REF' then process_record_ref(par_record);
         when 'DEL' then process_record_del(par_record);
         when 'PAY' then process_record_pay(par_record);
         when 'HTI' then process_record_hti(par_record);
         when 'HTX' then process_record_htx(par_record);
         when 'GEN' then process_record_gen(par_record);
         when 'SCH' then process_record_sch(par_record);
         when 'ITP' then process_record_itp(par_record);
         when 'PAD' then process_record_pad(par_record);
         when 'OID' then process_record_oid(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD09';
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
            lads_atllad09_monitor.execute_before(rcd_lads_sto_po_hdr.belnr);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
         
         commit;
         
         begin
            lads_atllad09_monitor.execute_after(rcd_lads_sto_po_hdr.belnr);
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
      cursor csr_lads_sto_po_hdr_01 is
         select
            t01.belnr,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_sto_po_hdr t01
         where t01.belnr = rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_hdr_01 csr_lads_sto_po_hdr_01%rowtype;

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
      rcd_lads_sto_po_hdr.belnr := lics_inbound_utility.get_variable('BELNR');
      rcd_lads_sto_po_hdr.bsart := lics_inbound_utility.get_variable('BSART');
      rcd_lads_sto_po_hdr.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_sto_po_hdr.wkurs := lics_inbound_utility.get_variable('WKURS');
      rcd_lads_sto_po_hdr.zterm := lics_inbound_utility.get_variable('ZTERM');
      rcd_lads_sto_po_hdr.recipnt_no := lics_inbound_utility.get_variable('RECIPNT_NO');
      rcd_lads_sto_po_hdr.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_sto_po_hdr.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_sto_po_hdr.hwaer := lics_inbound_utility.get_variable('HWAER');
      rcd_lads_sto_po_hdr.kundeuinr := lics_inbound_utility.get_variable('KUNDEUINR');
      rcd_lads_sto_po_hdr.eigenuinr := lics_inbound_utility.get_variable('EIGENUINR');
      rcd_lads_sto_po_hdr.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_sto_po_hdr.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_sto_po_hdr.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_sto_po_hdr.fkart_rl := lics_inbound_utility.get_variable('FKART_RL');
      rcd_lads_sto_po_hdr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_sto_po_hdr.bstzd := lics_inbound_utility.get_variable('BSTZD');
      rcd_lads_sto_po_hdr.vsart := lics_inbound_utility.get_variable('VSART');
      rcd_lads_sto_po_hdr.vsart_bez := lics_inbound_utility.get_variable('VSART_BEZ');
      rcd_lads_sto_po_hdr.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_sto_po_hdr.autlf := lics_inbound_utility.get_variable('AUTLF');
      rcd_lads_sto_po_hdr.augru := lics_inbound_utility.get_variable('AUGRU');
      rcd_lads_sto_po_hdr.augru_bez := lics_inbound_utility.get_variable('AUGRU_BEZ');
      rcd_lads_sto_po_hdr.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_sto_po_hdr.abrvw_bez := lics_inbound_utility.get_variable('ABRVW_BEZ');
      rcd_lads_sto_po_hdr.fktyp := lics_inbound_utility.get_variable('FKTYP');
      rcd_lads_sto_po_hdr.lifsk := lics_inbound_utility.get_variable('LIFSK');
      rcd_lads_sto_po_hdr.lifsk_bez := lics_inbound_utility.get_variable('LIFSK_BEZ');
      rcd_lads_sto_po_hdr.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_sto_po_hdr.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_sto_po_hdr.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_sto_po_hdr.wkurs_m := lics_inbound_utility.get_variable('WKURS_M');
      rcd_lads_sto_po_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_sto_po_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_sto_po_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_sto_po_hdr.lads_date := sysdate;
      rcd_lads_sto_po_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sto_po_org.orgseq := 0;
      rcd_lads_sto_po_dat.datseq := 0;
      rcd_lads_sto_po_con.conseq := 0;
      rcd_lads_sto_po_pnr.pnrseq := 0;
      rcd_lads_sto_po_ref.refseq := 0;
      rcd_lads_sto_po_del.delseq := 0;
      rcd_lads_sto_po_pay.payseq := 0;
      rcd_lads_sto_po_hti.htiseq := 0;
      rcd_lads_sto_po_gen.genseq := 0;
      rcd_lads_sto_po_smy.smyseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sto_po_hdr.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BELNR');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_sto_po_hdr.belnr is null) then
         var_exists := true;
         open csr_lads_sto_po_hdr_01;
         fetch csr_lads_sto_po_hdr_01 into rcd_lads_sto_po_hdr_01;
         if csr_lads_sto_po_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_sto_po_hdr_01;
         if var_exists = true then
            if rcd_lads_sto_po_hdr.idoc_timestamp > rcd_lads_sto_po_hdr_01.idoc_timestamp then
               delete from lads_sto_po_smy where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_oid where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_pad where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_itp where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_sch where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_gen where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_htx where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_hti where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_pay where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_del where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_ref where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_pnr where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_con where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_dat where belnr = rcd_lads_sto_po_hdr.belnr;
               delete from lads_sto_po_org where belnr = rcd_lads_sto_po_hdr.belnr;
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

      update lads_sto_po_hdr set
         bsart = rcd_lads_sto_po_hdr.bsart,
         curcy = rcd_lads_sto_po_hdr.curcy,
         wkurs = rcd_lads_sto_po_hdr.wkurs,
         zterm = rcd_lads_sto_po_hdr.zterm,
         recipnt_no = rcd_lads_sto_po_hdr.recipnt_no,
         action = rcd_lads_sto_po_hdr.action,
         kzabs = rcd_lads_sto_po_hdr.kzabs,
         hwaer = rcd_lads_sto_po_hdr.hwaer,
         kundeuinr = rcd_lads_sto_po_hdr.kundeuinr,
         eigenuinr = rcd_lads_sto_po_hdr.eigenuinr,
         ntgew = rcd_lads_sto_po_hdr.ntgew,
         brgew = rcd_lads_sto_po_hdr.brgew,
         gewei = rcd_lads_sto_po_hdr.gewei,
         fkart_rl = rcd_lads_sto_po_hdr.fkart_rl,
         ablad = rcd_lads_sto_po_hdr.ablad,
         bstzd = rcd_lads_sto_po_hdr.bstzd,
         vsart = rcd_lads_sto_po_hdr.vsart,
         vsart_bez = rcd_lads_sto_po_hdr.vsart_bez,
         kzazu = rcd_lads_sto_po_hdr.kzazu,
         autlf = rcd_lads_sto_po_hdr.autlf,
         augru = rcd_lads_sto_po_hdr.augru,
         augru_bez = rcd_lads_sto_po_hdr.augru_bez,
         abrvw = rcd_lads_sto_po_hdr.abrvw,
         abrvw_bez = rcd_lads_sto_po_hdr.abrvw_bez,
         fktyp = rcd_lads_sto_po_hdr.fktyp,
         lifsk = rcd_lads_sto_po_hdr.lifsk,
         lifsk_bez = rcd_lads_sto_po_hdr.lifsk_bez,
         empst = rcd_lads_sto_po_hdr.empst,
         abtnr = rcd_lads_sto_po_hdr.abtnr,
         delco = rcd_lads_sto_po_hdr.delco,
         wkurs_m = rcd_lads_sto_po_hdr.wkurs_m,
         idoc_name = rcd_lads_sto_po_hdr.idoc_name,
         idoc_number = rcd_lads_sto_po_hdr.idoc_number,
         idoc_timestamp = rcd_lads_sto_po_hdr.idoc_timestamp,
         lads_date = rcd_lads_sto_po_hdr.lads_date,
         lads_status = rcd_lads_sto_po_hdr.lads_status
      where belnr = rcd_lads_sto_po_hdr.belnr;
      if sql%notfound then
         insert into lads_sto_po_hdr
            (belnr,
             bsart,
             curcy,
             wkurs,
             zterm,
             recipnt_no,
             action,
             kzabs,
             hwaer,
             kundeuinr,
             eigenuinr,
             ntgew,
             brgew,
             gewei,
             fkart_rl,
             ablad,
             bstzd,
             vsart,
             vsart_bez,
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
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_sto_po_hdr.belnr,
             rcd_lads_sto_po_hdr.bsart,
             rcd_lads_sto_po_hdr.curcy,
             rcd_lads_sto_po_hdr.wkurs,
             rcd_lads_sto_po_hdr.zterm,
             rcd_lads_sto_po_hdr.recipnt_no,
             rcd_lads_sto_po_hdr.action,
             rcd_lads_sto_po_hdr.kzabs,
             rcd_lads_sto_po_hdr.hwaer,
             rcd_lads_sto_po_hdr.kundeuinr,
             rcd_lads_sto_po_hdr.eigenuinr,
             rcd_lads_sto_po_hdr.ntgew,
             rcd_lads_sto_po_hdr.brgew,
             rcd_lads_sto_po_hdr.gewei,
             rcd_lads_sto_po_hdr.fkart_rl,
             rcd_lads_sto_po_hdr.ablad,
             rcd_lads_sto_po_hdr.bstzd,
             rcd_lads_sto_po_hdr.vsart,
             rcd_lads_sto_po_hdr.vsart_bez,
             rcd_lads_sto_po_hdr.kzazu,
             rcd_lads_sto_po_hdr.autlf,
             rcd_lads_sto_po_hdr.augru,
             rcd_lads_sto_po_hdr.augru_bez,
             rcd_lads_sto_po_hdr.abrvw,
             rcd_lads_sto_po_hdr.abrvw_bez,
             rcd_lads_sto_po_hdr.fktyp,
             rcd_lads_sto_po_hdr.lifsk,
             rcd_lads_sto_po_hdr.lifsk_bez,
             rcd_lads_sto_po_hdr.empst,
             rcd_lads_sto_po_hdr.abtnr,
             rcd_lads_sto_po_hdr.delco,
             rcd_lads_sto_po_hdr.wkurs_m,
             rcd_lads_sto_po_hdr.idoc_name,
             rcd_lads_sto_po_hdr.idoc_number,
             rcd_lads_sto_po_hdr.idoc_timestamp,
             rcd_lads_sto_po_hdr.lads_date,
             rcd_lads_sto_po_hdr.lads_status);
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
      rcd_lads_sto_po_org.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_org.orgseq := rcd_lads_sto_po_org.orgseq + 1;
      rcd_lads_sto_po_org.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sto_po_org.orgid := lics_inbound_utility.get_variable('ORGID');

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
      if rcd_lads_sto_po_org.belnr is null then
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

      insert into lads_sto_po_org
         (belnr,
          orgseq,
          qualf,
          orgid)
      values
         (rcd_lads_sto_po_org.belnr,
          rcd_lads_sto_po_org.orgseq,
          rcd_lads_sto_po_org.qualf,
          rcd_lads_sto_po_org.orgid);

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
      rcd_lads_sto_po_dat.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_dat.datseq := rcd_lads_sto_po_dat.datseq + 1;
      rcd_lads_sto_po_dat.iddat := lics_inbound_utility.get_variable('IDDAT');
      rcd_lads_sto_po_dat.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_sto_po_dat.uzeit := lics_inbound_utility.get_variable('UZEIT');

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
      if rcd_lads_sto_po_dat.belnr is null then
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

      insert into lads_sto_po_dat
         (belnr,
          datseq,
          iddat,
          datum,
          uzeit)
      values
         (rcd_lads_sto_po_dat.belnr,
          rcd_lads_sto_po_dat.datseq,
          rcd_lads_sto_po_dat.iddat,
          rcd_lads_sto_po_dat.datum,
          rcd_lads_sto_po_dat.uzeit);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

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
      rcd_lads_sto_po_con.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_con.conseq := rcd_lads_sto_po_con.conseq + 1;
      rcd_lads_sto_po_con.alckz := lics_inbound_utility.get_variable('ALCKZ');
      rcd_lads_sto_po_con.kschl := lics_inbound_utility.get_variable('KSCHL');
      rcd_lads_sto_po_con.kotxt := lics_inbound_utility.get_variable('KOTXT');
      rcd_lads_sto_po_con.betrg := lics_inbound_utility.get_variable('BETRG');
      rcd_lads_sto_po_con.kperc := lics_inbound_utility.get_variable('KPERC');
      rcd_lads_sto_po_con.krate := lics_inbound_utility.get_variable('KRATE');
      rcd_lads_sto_po_con.uprbs := lics_inbound_utility.get_variable('UPRBS');
      rcd_lads_sto_po_con.meaun := lics_inbound_utility.get_variable('MEAUN');
      rcd_lads_sto_po_con.kobtr := lics_inbound_utility.get_variable('KOBTR');
      rcd_lads_sto_po_con.mwskz := lics_inbound_utility.get_variable('MWSKZ');
      rcd_lads_sto_po_con.msatz := lics_inbound_utility.get_variable('MSATZ');
      rcd_lads_sto_po_con.koein := lics_inbound_utility.get_variable('KOEIN');

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
      if rcd_lads_sto_po_con.belnr is null then
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

      insert into lads_sto_po_con
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
         (rcd_lads_sto_po_con.belnr,
          rcd_lads_sto_po_con.conseq,
          rcd_lads_sto_po_con.alckz,
          rcd_lads_sto_po_con.kschl,
          rcd_lads_sto_po_con.kotxt,
          rcd_lads_sto_po_con.betrg,
          rcd_lads_sto_po_con.kperc,
          rcd_lads_sto_po_con.krate,
          rcd_lads_sto_po_con.uprbs,
          rcd_lads_sto_po_con.meaun,
          rcd_lads_sto_po_con.kobtr,
          rcd_lads_sto_po_con.mwskz,
          rcd_lads_sto_po_con.msatz,
          rcd_lads_sto_po_con.koein);

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
      rcd_lads_sto_po_pnr.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_pnr.pnrseq := rcd_lads_sto_po_pnr.pnrseq + 1;
      rcd_lads_sto_po_pnr.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_lads_sto_po_pnr.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_sto_po_pnr.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_sto_po_pnr.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_lads_sto_po_pnr.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_lads_sto_po_pnr.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_lads_sto_po_pnr.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_lads_sto_po_pnr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_sto_po_pnr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_sto_po_pnr.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_sto_po_pnr.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_sto_po_pnr.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_sto_po_pnr.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_sto_po_pnr.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_lads_sto_po_pnr.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_lads_sto_po_pnr.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_sto_po_pnr.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_lads_sto_po_pnr.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_sto_po_pnr.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_lads_sto_po_pnr.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_lads_sto_po_pnr.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_sto_po_pnr.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_lads_sto_po_pnr.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_lads_sto_po_pnr.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_lads_sto_po_pnr.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_lads_sto_po_pnr.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_sto_po_pnr.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_lads_sto_po_pnr.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_sto_po_pnr.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_lads_sto_po_pnr.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_lads_sto_po_pnr.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_sto_po_pnr.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_lads_sto_po_pnr.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_lads_sto_po_pnr.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_lads_sto_po_pnr.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_sto_po_pnr.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_sto_po_pnr.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_sto_po_pnr.title := lics_inbound_utility.get_variable('TITLE');

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
      if rcd_lads_sto_po_pnr.belnr is null then
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

      insert into lads_sto_po_pnr
         (belnr,
          pnrseq,
          partn,
          parvw,
          bname,
          paorg,
          orgtx,
          pagru,
          ilnnr,
          lifnr,
          name1,
          name2,
          name3,
          name4,
          anred,
          stock,
          hausn,
          stras,
          strs2,
          ort02,
          regio,
          pstlz,
          ort01,
          pfach,
          pfort,
          pstl2,
          counc,
          land1,
          isoal,
          spras,
          spras_iso,
          parnr,
          telf1,
          telf2,
          pernr,
          telfx,
          ablad,
          ihrez,
          knref,
          title)
      values
         (rcd_lads_sto_po_pnr.belnr,
          rcd_lads_sto_po_pnr.pnrseq,
          rcd_lads_sto_po_pnr.partn,
          rcd_lads_sto_po_pnr.parvw,
          rcd_lads_sto_po_pnr.bname,
          rcd_lads_sto_po_pnr.paorg,
          rcd_lads_sto_po_pnr.orgtx,
          rcd_lads_sto_po_pnr.pagru,
          rcd_lads_sto_po_pnr.ilnnr,
          rcd_lads_sto_po_pnr.lifnr,
          rcd_lads_sto_po_pnr.name1,
          rcd_lads_sto_po_pnr.name2,
          rcd_lads_sto_po_pnr.name3,
          rcd_lads_sto_po_pnr.name4,
          rcd_lads_sto_po_pnr.anred,
          rcd_lads_sto_po_pnr.stock,
          rcd_lads_sto_po_pnr.hausn,
          rcd_lads_sto_po_pnr.stras,
          rcd_lads_sto_po_pnr.strs2,
          rcd_lads_sto_po_pnr.ort02,
          rcd_lads_sto_po_pnr.regio,
          rcd_lads_sto_po_pnr.pstlz,
          rcd_lads_sto_po_pnr.ort01,
          rcd_lads_sto_po_pnr.pfach,
          rcd_lads_sto_po_pnr.pfort,
          rcd_lads_sto_po_pnr.pstl2,
          rcd_lads_sto_po_pnr.counc,
          rcd_lads_sto_po_pnr.land1,
          rcd_lads_sto_po_pnr.isoal,
          rcd_lads_sto_po_pnr.spras,
          rcd_lads_sto_po_pnr.spras_iso,
          rcd_lads_sto_po_pnr.parnr,
          rcd_lads_sto_po_pnr.telf1,
          rcd_lads_sto_po_pnr.telf2,
          rcd_lads_sto_po_pnr.pernr,
          rcd_lads_sto_po_pnr.telfx,
          rcd_lads_sto_po_pnr.ablad,
          rcd_lads_sto_po_pnr.ihrez,
          rcd_lads_sto_po_pnr.knref,
          rcd_lads_sto_po_pnr.title);

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
      rcd_lads_sto_po_ref.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_ref.refseq := rcd_lads_sto_po_ref.refseq + 1;
      rcd_lads_sto_po_ref.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sto_po_ref.refnr := lics_inbound_utility.get_variable('REFNR');
      rcd_lads_sto_po_ref.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_sto_po_ref.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_lads_sto_po_ref.posnr := lics_inbound_utility.get_variable('POSNR');

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
      if rcd_lads_sto_po_ref.belnr is null then
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

      insert into lads_sto_po_ref
         (belnr,
          refseq,
          qualf,
          refnr,
          datum,
          uzeit,
          posnr)
      values
         (rcd_lads_sto_po_ref.belnr,
          rcd_lads_sto_po_ref.refseq,
          rcd_lads_sto_po_ref.qualf,
          rcd_lads_sto_po_ref.refnr,
          rcd_lads_sto_po_ref.datum,
          rcd_lads_sto_po_ref.uzeit,
          rcd_lads_sto_po_ref.posnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ref;

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
      rcd_lads_sto_po_del.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_del.delseq := rcd_lads_sto_po_del.delseq + 1;
      rcd_lads_sto_po_del.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sto_po_del.lkond := lics_inbound_utility.get_variable('LKOND');
      rcd_lads_sto_po_del.lktext := lics_inbound_utility.get_variable('LKTEXT');

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
      if rcd_lads_sto_po_del.belnr is null then
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

      insert into lads_sto_po_del
         (belnr,
          delseq,
          qualf,
          lkond,
          lktext)
      values
         (rcd_lads_sto_po_del.belnr,
          rcd_lads_sto_po_del.delseq,
          rcd_lads_sto_po_del.qualf,
          rcd_lads_sto_po_del.lkond,
          rcd_lads_sto_po_del.lktext);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_del;

   /**************************************************/
   /* This procedure performs the record PAY routine */
   /**************************************************/
   procedure process_record_pay(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('PAY', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sto_po_pay.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_pay.payseq := rcd_lads_sto_po_pay.payseq + 1;
      rcd_lads_sto_po_pay.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sto_po_pay.tage := lics_inbound_utility.get_variable('TAGE');
      rcd_lads_sto_po_pay.prznt := lics_inbound_utility.get_variable('PRZNT');
      rcd_lads_sto_po_pay.zterm_txt := lics_inbound_utility.get_variable('ZTERM_TXT');

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
      if rcd_lads_sto_po_pay.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - PAY.BELNR');
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

      insert into lads_sto_po_pay
         (belnr,
          payseq,
          qualf,
          tage,
          prznt,
          zterm_txt)
      values
         (rcd_lads_sto_po_pay.belnr,
          rcd_lads_sto_po_pay.payseq,
          rcd_lads_sto_po_pay.qualf,
          rcd_lads_sto_po_pay.tage,
          rcd_lads_sto_po_pay.prznt,
          rcd_lads_sto_po_pay.zterm_txt);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pay;

   /**************************************************/
   /* This procedure performs the record HTI routine */
   /**************************************************/
   procedure process_record_hti(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('HTI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sto_po_hti.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_hti.htiseq := rcd_lads_sto_po_hti.htiseq + 1;
      rcd_lads_sto_po_hti.tdid := lics_inbound_utility.get_variable('TDID');
      rcd_lads_sto_po_hti.tsspras := lics_inbound_utility.get_variable('TSSPRAS');
      rcd_lads_sto_po_hti.tsspras_iso := lics_inbound_utility.get_variable('TSSPRAS_ISO');
      rcd_lads_sto_po_hti.tdobject := lics_inbound_utility.get_variable('TDOBJECT');
      rcd_lads_sto_po_hti.tdobname := lics_inbound_utility.get_variable('TDOBNAME');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sto_po_htx.htxseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sto_po_hti.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HTI.BELNR');
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

      insert into lads_sto_po_hti
         (belnr,
          htiseq,
          tdid,
          tsspras,
          tsspras_iso,
          tdobject,
          tdobname)
      values
         (rcd_lads_sto_po_hti.belnr,
          rcd_lads_sto_po_hti.htiseq,
          rcd_lads_sto_po_hti.tdid,
          rcd_lads_sto_po_hti.tsspras,
          rcd_lads_sto_po_hti.tsspras_iso,
          rcd_lads_sto_po_hti.tdobject,
          rcd_lads_sto_po_hti.tdobname);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hti;

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
      rcd_lads_sto_po_htx.belnr := rcd_lads_sto_po_hti.belnr;
      rcd_lads_sto_po_htx.htiseq := rcd_lads_sto_po_hti.htiseq;
      rcd_lads_sto_po_htx.htxseq := rcd_lads_sto_po_htx.htxseq + 1;
      rcd_lads_sto_po_htx.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_sto_po_htx.tdline := lics_inbound_utility.get_variable('TDLINE');

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
      if rcd_lads_sto_po_htx.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HTX.BELNR');
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

      insert into lads_sto_po_htx
         (belnr,
          htiseq,
          htxseq,
          tdformat,
          tdline)
      values
         (rcd_lads_sto_po_htx.belnr,
          rcd_lads_sto_po_htx.htiseq,
          rcd_lads_sto_po_htx.htxseq,
          rcd_lads_sto_po_htx.tdformat,
          rcd_lads_sto_po_htx.tdline);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_htx;

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
      rcd_lads_sto_po_gen.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_gen.genseq := rcd_lads_sto_po_gen.genseq + 1;
      rcd_lads_sto_po_gen.posex := lics_inbound_utility.get_variable('POSEX');
      rcd_lads_sto_po_gen.action := lics_inbound_utility.get_variable('ACTION');
      rcd_lads_sto_po_gen.pstyp := lics_inbound_utility.get_variable('PSTYP');
      rcd_lads_sto_po_gen.kzabs := lics_inbound_utility.get_variable('KZABS');
      rcd_lads_sto_po_gen.menge := lics_inbound_utility.get_variable('MENGE');
      rcd_lads_sto_po_gen.menee := lics_inbound_utility.get_variable('MENEE');
      rcd_lads_sto_po_gen.bmng2 := lics_inbound_utility.get_variable('BMNG2');
      rcd_lads_sto_po_gen.pmene := lics_inbound_utility.get_variable('PMENE');
      rcd_lads_sto_po_gen.abftz := lics_inbound_utility.get_variable('ABFTZ');
      rcd_lads_sto_po_gen.vprei := lics_inbound_utility.get_variable('VPREI');
      rcd_lads_sto_po_gen.peinh := lics_inbound_utility.get_variable('PEINH');
      rcd_lads_sto_po_gen.netwr := lics_inbound_utility.get_variable('NETWR');
      rcd_lads_sto_po_gen.anetw := lics_inbound_utility.get_variable('ANETW');
      rcd_lads_sto_po_gen.skfbp := lics_inbound_utility.get_variable('SKFBP');
      rcd_lads_sto_po_gen.ntgew := lics_inbound_utility.get_variable('NTGEW');
      rcd_lads_sto_po_gen.gewei := lics_inbound_utility.get_variable('GEWEI');
      rcd_lads_sto_po_gen.einkz := lics_inbound_utility.get_variable('EINKZ');
      rcd_lads_sto_po_gen.curcy := lics_inbound_utility.get_variable('CURCY');
      rcd_lads_sto_po_gen.preis := lics_inbound_utility.get_variable('PREIS');
      rcd_lads_sto_po_gen.matkl := lics_inbound_utility.get_variable('MATKL');
      rcd_lads_sto_po_gen.uepos := lics_inbound_utility.get_variable('UEPOS');
      rcd_lads_sto_po_gen.grkor := lics_inbound_utility.get_variable('GRKOR');
      rcd_lads_sto_po_gen.evers := lics_inbound_utility.get_variable('EVERS');
      rcd_lads_sto_po_gen.bpumn := lics_inbound_utility.get_number('BPUMN',null);
      rcd_lads_sto_po_gen.bpumz := lics_inbound_utility.get_number('BPUMZ',null);
      rcd_lads_sto_po_gen.abgru := lics_inbound_utility.get_variable('ABGRU');
      rcd_lads_sto_po_gen.abgrt := lics_inbound_utility.get_variable('ABGRT');
      rcd_lads_sto_po_gen.antlf := lics_inbound_utility.get_variable('ANTLF');
      rcd_lads_sto_po_gen.fixmg := lics_inbound_utility.get_variable('FIXMG');
      rcd_lads_sto_po_gen.kzazu := lics_inbound_utility.get_variable('KZAZU');
      rcd_lads_sto_po_gen.brgew := lics_inbound_utility.get_variable('BRGEW');
      rcd_lads_sto_po_gen.pstyv := lics_inbound_utility.get_variable('PSTYV');
      rcd_lads_sto_po_gen.empst := lics_inbound_utility.get_variable('EMPST');
      rcd_lads_sto_po_gen.abtnr := lics_inbound_utility.get_variable('ABTNR');
      rcd_lads_sto_po_gen.abrvw := lics_inbound_utility.get_variable('ABRVW');
      rcd_lads_sto_po_gen.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_sto_po_gen.lprio := lics_inbound_utility.get_number('LPRIO',null);
      rcd_lads_sto_po_gen.lprio_bez := lics_inbound_utility.get_variable('LPRIO_BEZ');
      rcd_lads_sto_po_gen.route := lics_inbound_utility.get_variable('ROUTE');
      rcd_lads_sto_po_gen.route_bez := lics_inbound_utility.get_variable('ROUTE_BEZ');
      rcd_lads_sto_po_gen.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_sto_po_gen.vstel := lics_inbound_utility.get_variable('VSTEL');
      rcd_lads_sto_po_gen.delco := lics_inbound_utility.get_variable('DELCO');
      rcd_lads_sto_po_gen.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_sto_po_gen.valtg := lics_inbound_utility.get_number('VALTG',null);
      rcd_lads_sto_po_gen.hipos := lics_inbound_utility.get_number('HIPOS',null);
      rcd_lads_sto_po_gen.hievw := lics_inbound_utility.get_variable('HIEVW');
      rcd_lads_sto_po_gen.posguid := lics_inbound_utility.get_variable('POSGUID');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sto_po_sch.schseq := 0;
      rcd_lads_sto_po_itp.itpseq := 0;
      rcd_lads_sto_po_oid.oidseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sto_po_gen.belnr is null then
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

      insert into lads_sto_po_gen
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
          posguid)
      values
         (rcd_lads_sto_po_gen.belnr,
          rcd_lads_sto_po_gen.genseq,
          rcd_lads_sto_po_gen.posex,
          rcd_lads_sto_po_gen.action,
          rcd_lads_sto_po_gen.pstyp,
          rcd_lads_sto_po_gen.kzabs,
          rcd_lads_sto_po_gen.menge,
          rcd_lads_sto_po_gen.menee,
          rcd_lads_sto_po_gen.bmng2,
          rcd_lads_sto_po_gen.pmene,
          rcd_lads_sto_po_gen.abftz,
          rcd_lads_sto_po_gen.vprei,
          rcd_lads_sto_po_gen.peinh,
          rcd_lads_sto_po_gen.netwr,
          rcd_lads_sto_po_gen.anetw,
          rcd_lads_sto_po_gen.skfbp,
          rcd_lads_sto_po_gen.ntgew,
          rcd_lads_sto_po_gen.gewei,
          rcd_lads_sto_po_gen.einkz,
          rcd_lads_sto_po_gen.curcy,
          rcd_lads_sto_po_gen.preis,
          rcd_lads_sto_po_gen.matkl,
          rcd_lads_sto_po_gen.uepos,
          rcd_lads_sto_po_gen.grkor,
          rcd_lads_sto_po_gen.evers,
          rcd_lads_sto_po_gen.bpumn,
          rcd_lads_sto_po_gen.bpumz,
          rcd_lads_sto_po_gen.abgru,
          rcd_lads_sto_po_gen.abgrt,
          rcd_lads_sto_po_gen.antlf,
          rcd_lads_sto_po_gen.fixmg,
          rcd_lads_sto_po_gen.kzazu,
          rcd_lads_sto_po_gen.brgew,
          rcd_lads_sto_po_gen.pstyv,
          rcd_lads_sto_po_gen.empst,
          rcd_lads_sto_po_gen.abtnr,
          rcd_lads_sto_po_gen.abrvw,
          rcd_lads_sto_po_gen.werks,
          rcd_lads_sto_po_gen.lprio,
          rcd_lads_sto_po_gen.lprio_bez,
          rcd_lads_sto_po_gen.route,
          rcd_lads_sto_po_gen.route_bez,
          rcd_lads_sto_po_gen.lgort,
          rcd_lads_sto_po_gen.vstel,
          rcd_lads_sto_po_gen.delco,
          rcd_lads_sto_po_gen.matnr,
          rcd_lads_sto_po_gen.valtg,
          rcd_lads_sto_po_gen.hipos,
          rcd_lads_sto_po_gen.hievw,
          rcd_lads_sto_po_gen.posguid);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_gen;

   /**************************************************/
   /* This procedure performs the record SCH routine */
   /**************************************************/
   procedure process_record_sch(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('SCH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sto_po_sch.belnr := rcd_lads_sto_po_gen.belnr;
      rcd_lads_sto_po_sch.genseq := rcd_lads_sto_po_gen.genseq;
      rcd_lads_sto_po_sch.schseq := rcd_lads_sto_po_sch.schseq + 1;
      rcd_lads_sto_po_sch.wmeng := lics_inbound_utility.get_variable('WMENG');
      rcd_lads_sto_po_sch.ameng := lics_inbound_utility.get_variable('AMENG');
      rcd_lads_sto_po_sch.edatu := lics_inbound_utility.get_variable('EDATU');
      rcd_lads_sto_po_sch.ezeit := lics_inbound_utility.get_variable('EZEIT');
      rcd_lads_sto_po_sch.edatu_old := lics_inbound_utility.get_variable('EDATU_OLD');
      rcd_lads_sto_po_sch.ezeit_old := lics_inbound_utility.get_variable('EZEIT_OLD');
      rcd_lads_sto_po_sch.action := lics_inbound_utility.get_variable('ACTION');

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
      if rcd_lads_sto_po_sch.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - SCH.BELNR');
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

      insert into lads_sto_po_sch
         (belnr,
          genseq,
          schseq,
          wmeng,
          ameng,
          edatu,
          ezeit,
          edatu_old,
          ezeit_old,
          action)
      values
         (rcd_lads_sto_po_sch.belnr,
          rcd_lads_sto_po_sch.genseq,
          rcd_lads_sto_po_sch.schseq,
          rcd_lads_sto_po_sch.wmeng,
          rcd_lads_sto_po_sch.ameng,
          rcd_lads_sto_po_sch.edatu,
          rcd_lads_sto_po_sch.ezeit,
          rcd_lads_sto_po_sch.edatu_old,
          rcd_lads_sto_po_sch.ezeit_old,
          rcd_lads_sto_po_sch.action);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_sch;

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
      rcd_lads_sto_po_itp.belnr := rcd_lads_sto_po_gen.belnr;
      rcd_lads_sto_po_itp.genseq := rcd_lads_sto_po_gen.genseq;
      rcd_lads_sto_po_itp.itpseq := rcd_lads_sto_po_itp.itpseq + 1;
      rcd_lads_sto_po_itp.parvw := lics_inbound_utility.get_variable('PARVW');
      rcd_lads_sto_po_itp.partn := lics_inbound_utility.get_variable('PARTN');
      rcd_lads_sto_po_itp.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_sto_po_itp.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_sto_po_itp.name2 := lics_inbound_utility.get_variable('NAME2');
      rcd_lads_sto_po_itp.name3 := lics_inbound_utility.get_variable('NAME3');
      rcd_lads_sto_po_itp.name4 := lics_inbound_utility.get_variable('NAME4');
      rcd_lads_sto_po_itp.anred := lics_inbound_utility.get_variable('ANRED');
      rcd_lads_sto_po_itp.hausn := lics_inbound_utility.get_variable('HAUSN');
      rcd_lads_sto_po_itp.stock := lics_inbound_utility.get_variable('STOCK');
      rcd_lads_sto_po_itp.stras := lics_inbound_utility.get_variable('STRAS');
      rcd_lads_sto_po_itp.strs2 := lics_inbound_utility.get_variable('STRS2');
      rcd_lads_sto_po_itp.ort02 := lics_inbound_utility.get_variable('ORT02');
      rcd_lads_sto_po_itp.regio := lics_inbound_utility.get_variable('REGIO');
      rcd_lads_sto_po_itp.ort01 := lics_inbound_utility.get_variable('ORT01');
      rcd_lads_sto_po_itp.pstlz := lics_inbound_utility.get_variable('PSTLZ');
      rcd_lads_sto_po_itp.pfach := lics_inbound_utility.get_variable('PFACH');
      rcd_lads_sto_po_itp.pfort := lics_inbound_utility.get_variable('PFORT');
      rcd_lads_sto_po_itp.pstl2 := lics_inbound_utility.get_variable('PSTL2');
      rcd_lads_sto_po_itp.counc := lics_inbound_utility.get_variable('COUNC');
      rcd_lads_sto_po_itp.land1 := lics_inbound_utility.get_variable('LAND1');
      rcd_lads_sto_po_itp.isoal := lics_inbound_utility.get_variable('ISOAL');
      rcd_lads_sto_po_itp.isonu := lics_inbound_utility.get_variable('ISONU');
      rcd_lads_sto_po_itp.ablad := lics_inbound_utility.get_variable('ABLAD');
      rcd_lads_sto_po_itp.parnr := lics_inbound_utility.get_variable('PARNR');
      rcd_lads_sto_po_itp.telf1 := lics_inbound_utility.get_variable('TELF1');
      rcd_lads_sto_po_itp.telf2 := lics_inbound_utility.get_variable('TELF2');
      rcd_lads_sto_po_itp.pernr := lics_inbound_utility.get_variable('PERNR');
      rcd_lads_sto_po_itp.telbx := lics_inbound_utility.get_variable('TELBX');
      rcd_lads_sto_po_itp.telfx := lics_inbound_utility.get_variable('TELFX');
      rcd_lads_sto_po_itp.teltx := lics_inbound_utility.get_variable('TELTX');
      rcd_lads_sto_po_itp.telx1 := lics_inbound_utility.get_variable('TELX1');
      rcd_lads_sto_po_itp.parge := lics_inbound_utility.get_variable('PARGE');
      rcd_lads_sto_po_itp.fcode := lics_inbound_utility.get_variable('FCODE');
      rcd_lads_sto_po_itp.ihrez := lics_inbound_utility.get_variable('IHREZ');
      rcd_lads_sto_po_itp.bname := lics_inbound_utility.get_variable('BNAME');
      rcd_lads_sto_po_itp.paorg := lics_inbound_utility.get_variable('PAORG');
      rcd_lads_sto_po_itp.orgtx := lics_inbound_utility.get_variable('ORGTX');
      rcd_lads_sto_po_itp.pagru := lics_inbound_utility.get_variable('PAGRU');
      rcd_lads_sto_po_itp.knref := lics_inbound_utility.get_variable('KNREF');
      rcd_lads_sto_po_itp.ilnnr := lics_inbound_utility.get_variable('ILNNR');
      rcd_lads_sto_po_itp.spras := lics_inbound_utility.get_variable('SPRAS');
      rcd_lads_sto_po_itp.spras_iso := lics_inbound_utility.get_variable('SPRAS_ISO');
      rcd_lads_sto_po_itp.title := lics_inbound_utility.get_variable('TITLE');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_sto_po_pad.padseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_sto_po_itp.belnr is null then
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

      insert into lads_sto_po_itp
         (belnr,
          genseq,
          itpseq,
          parvw,
          partn,
          lifnr,
          name1,
          name2,
          name3,
          name4,
          anred,
          hausn,
          stock,
          stras,
          strs2,
          ort02,
          regio,
          ort01,
          pstlz,
          pfach,
          pfort,
          pstl2,
          counc,
          land1,
          isoal,
          isonu,
          ablad,
          parnr,
          telf1,
          telf2,
          pernr,
          telbx,
          telfx,
          teltx,
          telx1,
          parge,
          fcode,
          ihrez,
          bname,
          paorg,
          orgtx,
          pagru,
          knref,
          ilnnr,
          spras,
          spras_iso,
          title)
      values
         (rcd_lads_sto_po_itp.belnr,
          rcd_lads_sto_po_itp.genseq,
          rcd_lads_sto_po_itp.itpseq,
          rcd_lads_sto_po_itp.parvw,
          rcd_lads_sto_po_itp.partn,
          rcd_lads_sto_po_itp.lifnr,
          rcd_lads_sto_po_itp.name1,
          rcd_lads_sto_po_itp.name2,
          rcd_lads_sto_po_itp.name3,
          rcd_lads_sto_po_itp.name4,
          rcd_lads_sto_po_itp.anred,
          rcd_lads_sto_po_itp.hausn,
          rcd_lads_sto_po_itp.stock,
          rcd_lads_sto_po_itp.stras,
          rcd_lads_sto_po_itp.strs2,
          rcd_lads_sto_po_itp.ort02,
          rcd_lads_sto_po_itp.regio,
          rcd_lads_sto_po_itp.ort01,
          rcd_lads_sto_po_itp.pstlz,
          rcd_lads_sto_po_itp.pfach,
          rcd_lads_sto_po_itp.pfort,
          rcd_lads_sto_po_itp.pstl2,
          rcd_lads_sto_po_itp.counc,
          rcd_lads_sto_po_itp.land1,
          rcd_lads_sto_po_itp.isoal,
          rcd_lads_sto_po_itp.isonu,
          rcd_lads_sto_po_itp.ablad,
          rcd_lads_sto_po_itp.parnr,
          rcd_lads_sto_po_itp.telf1,
          rcd_lads_sto_po_itp.telf2,
          rcd_lads_sto_po_itp.pernr,
          rcd_lads_sto_po_itp.telbx,
          rcd_lads_sto_po_itp.telfx,
          rcd_lads_sto_po_itp.teltx,
          rcd_lads_sto_po_itp.telx1,
          rcd_lads_sto_po_itp.parge,
          rcd_lads_sto_po_itp.fcode,
          rcd_lads_sto_po_itp.ihrez,
          rcd_lads_sto_po_itp.bname,
          rcd_lads_sto_po_itp.paorg,
          rcd_lads_sto_po_itp.orgtx,
          rcd_lads_sto_po_itp.pagru,
          rcd_lads_sto_po_itp.knref,
          rcd_lads_sto_po_itp.ilnnr,
          rcd_lads_sto_po_itp.spras,
          rcd_lads_sto_po_itp.spras_iso,
          rcd_lads_sto_po_itp.title);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_itp;

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
      rcd_lads_sto_po_pad.belnr := rcd_lads_sto_po_itp.belnr;
      rcd_lads_sto_po_pad.genseq := rcd_lads_sto_po_itp.genseq;
      rcd_lads_sto_po_pad.itpseq := rcd_lads_sto_po_itp.itpseq;
      rcd_lads_sto_po_pad.padseq := rcd_lads_sto_po_pad.padseq + 1;
      rcd_lads_sto_po_pad.qualp := lics_inbound_utility.get_variable('QUALP');
      rcd_lads_sto_po_pad.stdpn := lics_inbound_utility.get_variable('STDPN');

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
      if rcd_lads_sto_po_pad.belnr is null then
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

      insert into lads_sto_po_pad
         (belnr,
          genseq,
          itpseq,
          padseq,
          qualp,
          stdpn)
      values
         (rcd_lads_sto_po_pad.belnr,
          rcd_lads_sto_po_pad.genseq,
          rcd_lads_sto_po_pad.itpseq,
          rcd_lads_sto_po_pad.padseq,
          rcd_lads_sto_po_pad.qualp,
          rcd_lads_sto_po_pad.stdpn);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_pad;

   /**************************************************/
   /* This procedure performs the record OID routine */
   /**************************************************/
   procedure process_record_oid(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('OID', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_sto_po_oid.belnr := rcd_lads_sto_po_gen.belnr;
      rcd_lads_sto_po_oid.genseq := rcd_lads_sto_po_gen.genseq;
      rcd_lads_sto_po_oid.oidseq := rcd_lads_sto_po_oid.oidseq + 1;
      rcd_lads_sto_po_oid.qualf := lics_inbound_utility.get_variable('QUALF');
      rcd_lads_sto_po_oid.idtnr := lics_inbound_utility.get_variable('IDTNR');
      rcd_lads_sto_po_oid.ktext := lics_inbound_utility.get_variable('KTEXT');
      rcd_lads_sto_po_oid.mfrnr := lics_inbound_utility.get_variable('MFRNR');
      rcd_lads_sto_po_oid.mfrpn := lics_inbound_utility.get_variable('MFRPN');

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
      if rcd_lads_sto_po_oid.belnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - OID.BELNR');
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

      insert into lads_sto_po_oid
         (belnr,
          genseq,
          oidseq,
          qualf,
          idtnr,
          ktext,
          mfrnr,
          mfrpn)
      values
         (rcd_lads_sto_po_oid.belnr,
          rcd_lads_sto_po_oid.genseq,
          rcd_lads_sto_po_oid.oidseq,
          rcd_lads_sto_po_oid.qualf,
          rcd_lads_sto_po_oid.idtnr,
          rcd_lads_sto_po_oid.ktext,
          rcd_lads_sto_po_oid.mfrnr,
          rcd_lads_sto_po_oid.mfrpn);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_oid;

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
      rcd_lads_sto_po_smy.belnr := rcd_lads_sto_po_hdr.belnr;
      rcd_lads_sto_po_smy.smyseq := rcd_lads_sto_po_smy.smyseq + 1;
      rcd_lads_sto_po_smy.sumid := lics_inbound_utility.get_variable('SUMID');
      rcd_lads_sto_po_smy.summe := lics_inbound_utility.get_variable('SUMME');
      rcd_lads_sto_po_smy.sunit := lics_inbound_utility.get_variable('SUNIT');
      rcd_lads_sto_po_smy.waerq := lics_inbound_utility.get_variable('WAERQ');

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
      if rcd_lads_sto_po_smy.belnr is null then
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

      insert into lads_sto_po_smy
         (belnr,
          smyseq,
          sumid,
          summe,
          sunit,
          waerq)
      values
         (rcd_lads_sto_po_smy.belnr,
          rcd_lads_sto_po_smy.smyseq,
          rcd_lads_sto_po_smy.sumid,
          rcd_lads_sto_po_smy.summe,
          rcd_lads_sto_po_smy.sunit,
          rcd_lads_sto_po_smy.waerq);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_smy;

end lads_atllad09;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad09 for lads_app.lads_atllad09;
grant execute on lads_atllad09 to lics_app;
