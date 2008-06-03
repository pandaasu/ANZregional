/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_far_det
 Owner   : lads
 Author  : Sunil Mandalika

 Description
 -----------
 Local Atlas Data Store - lads_far_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/06   Sunil Mandalika Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_far_det
   	(BELNR  	Varchar2 (10 Char) 	not null,
        DETSEQ  	number             	not null,
        BUZEI   	VarChar2(3 Char)   	Null,
        BUZID   	VarChar2(1 Char)   	Null,
        AUGDT   	VarChar2(8 Char)   	Null,
        AUGCP   	VarChar2(8 Char)   	Null,
        AUGBL   	VarChar2(10 Char)  	Null,
        BSCHL   	VarChar2(2 Char)   	Null,
        KOART   	VarChar2(1 Char)   	Null,
        SHKZG   	VarChar2(1 Char)   	Null,
        GSBER   	VarChar2(4 Char)   	Null,
        PARGB   	VarChar2(4 Char)   	Null,
        MWSKZ   	VarChar2(2 Char)   	Null,
        DMBTR   	VarChar2(15 Char)  	Null,
        DMBE2   	VarChar2(15 Char)  	Null,
        DMBE3   	VarChar2(15 Char)  	Null,
        WRBTR   	VarChar2(15 Char)  	Null,
        KZBTR   	VarChar2(15 Char)  	Null,
        PSWBT   	VarChar2(15 Char)  	Null,
        PSWSL   	VarChar2(5 Char)   	Null,
        HWBAS   	VarChar2(15 Char)  	Null,
        FWBAS   	VarChar2(15 Char)  	Null,
        MWART   	VarChar2(1 Char)   	Null,
        KTOSL   	VarChar2(3 Char)   	Null,
        VALUT   	VarChar2(8 Char)   	Null,
        ZUONR   	VarChar2(18 Char)  	Null,
        SGTXT   	VarChar2(50 Char)  	Null,
        VBUND   	VarChar2(6 Char)   	Null,
        BEWAR   	VarChar2(3 Char)   	Null,
        VORGN   	VarChar2(4 Char)   	Null,
        FDLEV   	VarChar2(2 Char)   	Null,
        FDGRP   	VarChar2(10 Char)  	Null,
        FDTAG   	VarChar2(8 Char)   	Null,
        KOKRS   	VarChar2(4 Char)   	Null,
        TXGRP   	Number             	Null,
        KOSTL   	VarChar2(10 Char)  	Null,
        AUFNR   	VarChar2(12 Char)  	Null,
        VBELN   	VarChar2(10 Char)  	Null,
        VBEL2   	VarChar2(10 Char)  	Null,
        POSN2   	Number             	Null,
        ANLN1   	VarChar2(12 Char)  	Null,
        ANLN2   	VarChar2(4 Char)   	Null,
        ANBWA   	VarChar2(3 Char)   	Null,
        BZDAT   	VarChar2(8 Char)   	Null,
        PERNR   	Number             	Null,
        XUMSW   	VarChar2(1 Char)   	Null,
        XSKRL   	VarChar2(1 Char)   	Null,
        XAUTO   	VarChar2(1 Char)   	Null,
        SAKNR   	VarChar2(10 Char)  	Null,
        HKONT   	VarChar2(10 Char)  	Null,
        ABPER   	VarChar2(6 Char)   	Null,
        MATNR   	VarChar2(18 Char)  	Null,
        WERKS   	VarChar2(4 Char)   	Null,
        MENGE   	Number             	Null,
        MEINS   	VarChar2(3 Char)   	Null,
        ERFMG   	Number             	Null,
        ERFME   	Number             	Null,
        BPMNG   	Number             	Null,
        BPRME   	VarChar2(3 Char)   	Null,
        EBELN   	VarChar2(10 Char)  	Null,
        EBELP   	Number             	Null,
        ZEKKN   	Number             	Null,
        BWKEY   	VarChar2(4 Char)   	Null,
        BWTAR   	VarChar2(10 Char)  	Null,
        BUSTW   	VarChar2(4 Char)   	Null,
        BUALT   	VarChar2(15 Char)  	Null,
        TBTKZ   	VarChar2(1 Char)   	Null,
        STCEG   	VarChar2(20 Char)  	Null,
        RSTGR   	VarChar2(3 Char)   	Null,
        PRCTR   	VarChar2(10 Char)  	Null,
        VNAME   	VarChar2(6 Char)   	Null,
        RECID   	VarChar2(2 Char)   	Null,
        EGRUP   	VarChar2(3 Char)   	Null,
        VPTNR   	VarChar2(10 Char)  	Null,
        VERTT   	VarChar2(1 Char)   	Null,
        VERTN   	VarChar2(13 Char)  	Null,
        VBEWA   	VarChar2(4 Char)   	Null,
        TXJCD   	VarChar2(15 Char)  	Null,
        IMKEY   	VarChar2(8 Char)   	Null,
        DABRZ   	VarChar2(8 Char)   	Null,
        FIPOS   	VarChar2(14 Char)  	Null,
        KSTRG   	VarChar2(12 Char)  	Null,
        NPLNR   	VarChar2(12 Char)  	Null,
        AUFPL   	Number             	Null,
        APLZL   	Number             	Null,
        PROJK   	Number             	Null,
        PAOBJNR 	Number             	Null,
        BTYPE   	VarChar2(2 Char)   	Null,
        ETYPE   	VarChar2(3 Char)   	Null,
        XEGDR   	VarChar2(1 Char)   	Null,
        HRKFT   	VarChar2(4 Char)   	Null,
        LOKKT   	VarChar2(10 Char)  	Null,
        FISTL   	VarChar2(16 Char)  	Null,
        GEBER   	VarChar2(10 Char)  	Null,
        STBUK   	VarChar2(4 Char)   	Null,
        ALTKT   	VarChar2(10 Char)  	Null,
        PPRCT   	VarChar2(10 Char)  	Null,
        XREF1   	VarChar2(12 Char)  	Null,
        XREF2   	VarChar2(12 Char)  	Null,
        KBLNR   	VarChar2(10 Char)  	Null,
        KBLPOS  	Number             	Null,
        FKBER   	VarChar2(4 Char)   	Null,
        OBZEI   	Number             	Null,
        XNEGP   	VarChar2(1 Char)   	Null,
        CACCT   	VarChar2(10 Char)  	Null,
        XREF3   	VarChar2(20 Char)  	Null,
        TXDAT   	VarChar2(8 Char)   	Null,
        BUPLA   	VarChar2(4 Char)   	Null,
        SECCO   	VarChar2(4 Char)   	Null,
        LSTAR   	VarChar2(6 Char)   	Null,
        PRZNR   	VarChar2(12 Char)  	Null,
        KURSR   	VarChar2(11 Char)  	Null,
        KURSR_M 	VarChar2(11 Char)  	Null,
        GBETR   	VarChar2(15 Char)  	Null,
        RESERVE 	VarChar2(50 Char)  	Null,
        XCPDD   	VarChar2(1 Char)   	Null);

/**/
/* Comments
/**/

comment on table lads_far_det is 'det - 'Document Item Detail Information'
comment on column lads_far_det.belnr is 'Accounting Document Number';
comment on column lads_far_det.detseq is 'DET - generated sequence number';
comment on column lads_far_det.buzei is 'Number of Line Item Within Accounting Document';
comment on column lads_far_det.buzid is 'Identification of the Line Item';
comment on column lads_far_det.augdt is 'Clearing Date';
comment on column lads_far_det.augcp is 'Clearing Entry Date';
comment on column lads_far_det.augbl is 'Document Number of the Clearing Document';
comment on column lads_far_det.bschl is 'Posting Key';
comment on column lads_far_det.koart is 'Account type';
comment on column lads_far_det.shkzg is 'Debit/Credit Indicator';
comment on column lads_far_det.gsber is 'Globally unique business area';
comment on column lads_far_det.pargb is 'Globally unique business area';
comment on column lads_far_det.mwskz is 'Tax on sales/purchases code';
comment on column lads_far_det.dmbtr is 'Amount in local currency';
comment on column lads_far_det.dmbe2 is 'Amount in Second Local Currency';
comment on column lads_far_det.dmbe3 is 'Amount in Third Local Currency';
comment on column lads_far_det.wrbtr is 'Amount in document currency';
comment on column lads_far_det.kzbtr is 'Original Reduction Amount in Local Currency';
comment on column lads_far_det.pswbt is 'Amount for Updating in General Ledger';
comment on column lads_far_det.pswsl is 'Update Currency for General Ledger Transaction Figures ';
comment on column lads_far_det.hwbas is 'Tax Base Amount in Local Currency';
comment on column lads_far_det.fwbas is 'Tax Base Amount in Document Currency';
comment on column lads_far_det.mwart is 'Tax Type';
comment on column lads_far_det.ktosl is 'Transaction Key';
comment on column lads_far_det.valut is 'Value date';
comment on column lads_far_det.zuonr is 'Assignment number';
comment on column lads_far_det.sgtxt is 'Item Text';
comment on column lads_far_det.vbund is 'Company ID of Trading Partner';
comment on column lads_far_det.bewar is 'Transaction Type';
comment on column lads_far_det.vorgn is 'Transaction Type for General Ledger';
comment on column lads_far_det.fdlev is 'Planning level';
comment on column lads_far_det.fdgrp is 'Planning group';
comment on column lads_far_det.fdtag is 'Planning date';
comment on column lads_far_det.kokrs is 'Controlling Area';
comment on column lads_far_det.txgrp is 'Group Indicator for Tax Line Items ';
comment on column lads_far_det.kostl is 'Cost Center';
comment on column lads_far_det.aufnr is 'Order Number';
comment on column lads_far_det.vbeln is 'Billing Document';
comment on column lads_far_det.vbel2 is 'Sales Document';
comment on column lads_far_det.posn2 is 'Sales Document Item';
comment on column lads_far_det.anln1 is 'Main Asset Number';
comment on column lads_far_det.anln2 is 'Asset Subnumber';
comment on column lads_far_det.anbwa is 'Asset Transaction Type';
comment on column lads_far_det.bzdat is 'Asset value date';
comment on column lads_far_det.pernr is 'Personnel Number';
comment on column lads_far_det.xumsw is 'Indicator: Sales-related item ?';
comment on column lads_far_det.xskrl is 'Indicator: Line item not liable to cash d is 'count?';
comment on column lads_far_det.xauto is 'Indicator: Line item automatically created';
comment on column lads_far_det.saknr is 'G/L Account Number';
comment on column lads_far_det.hkont is 'General Ledger Account';
comment on column lads_far_det.abper is 'Settlement period';
comment on column lads_far_det.matnr is 'Material Number';
comment on column lads_far_det.werks is 'Plant';
comment on column lads_far_det.menge is 'Quantity';
comment on column lads_far_det.meins is 'Base Unit of Measure';
comment on column lads_far_det.erfmg is 'Quantity in unit of entry';
comment on column lads_far_det.erfme is 'Unit of entry';
comment on column lads_far_det.bpmng is 'Quantity in purchase order price unit';
comment on column lads_far_det.bprme is 'Order price unit';
comment on column lads_far_det.ebeln is 'Purchasing Document Number';
comment on column lads_far_det.ebelp is 'Item Number of Purchasing Document';
comment on column lads_far_det.zekkn is 'Sequential number of account assignment';
comment on column lads_far_det.bwkey is 'Valuation area';
comment on column lads_far_det.bwtar is 'Valuation Type';
comment on column lads_far_det.bustw is 'Posting string for values ';
comment on column lads_far_det.bualt is 'Amount posted in alternative price control';
comment on column lads_far_det.tbtkz is 'Indicator: subsequent debit/credit';
comment on column lads_far_det.stceg is 'VAT reg is 'tration number';
comment on column lads_far_det.rstgr is 'Reason Code for Payments ';
comment on column lads_far_det.prctr is 'Profit Center';
comment on column lads_far_det.vname is 'Joint Venture';
comment on column lads_far_det.recid is 'Recovery Indicator';
comment on column lads_far_det.egrup is 'Equity Group';
comment on column lads_far_det.vptnr is 'Partner account number';
comment on column lads_far_det.vertt is 'Contract Type';
comment on column lads_far_det.vertn is 'Contract Number';
comment on column lads_far_det.vbewa is 'Flow Type';
comment on column lads_far_det.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_far_det.imkey is 'Internal Key for Real Estate Object';
comment on column lads_far_det.dabrz is 'Reference date for settlement';
comment on column lads_far_det.fipos is 'Commitment Item';
comment on column lads_far_det.kstrg is 'Cost Object';
comment on column lads_far_det.nplnr is 'Network Number for Account Assignment';
comment on column lads_far_det.aufpl is 'Task l is 't number for operations in order';
comment on column lads_far_det.aplzl is 'General counter for order';
comment on column lads_far_det.projk is 'Work Breakdown Structure Element (WBS Element)';
comment on column lads_far_det.paobjnr is 'Profitability Segment Number (CO-PA)';
comment on column lads_far_det.btype is 'Payroll Type';
comment on column lads_far_det.etype is 'Equity type';
comment on column lads_far_det.xegdr is 'Indicator: Triangular deal within the EU ?';
comment on column lads_far_det.hrkft is 'Origin Group as Subdiv is 'ion of Cost Element';
comment on column lads_far_det.lokkt is 'Alternative account number in company code';
comment on column lads_far_det.fistl is 'Funds Center';
comment on column lads_far_det.geber  is 'Fund';
comment on column lads_far_det.stbuk  is 'Tax Company Code';
comment on column lads_far_det.altkt  is 'Group account number';
comment on column lads_far_det.pprct  is 'Partner Profit Center';
comment on column lads_far_det.xref1  is 'Business partner reference key';
comment on column lads_far_det.xref2  is 'Business partner reference key';
comment on column lads_far_det.kblnr  is 'Document Number for Earmarked Funds ';
comment on column lads_far_det.kblpos is 'Earmarked Funds: Document Item';
comment on column lads_far_det.fkber  is 'Functional Area';
comment on column lads_far_det.obzei  is 'Number of Line Item in Original Document';
comment on column lads_far_det.xnegp  is 'Indicator: Negative posting';
comment on column lads_far_det.cacct  is 'G/L offsetting acct number';
comment on column lads_far_det.xref3  is 'Reference key for line item';
comment on column lads_far_det.txdat  is 'Date for defining tax rates ';
comment on column lads_far_det.bupla  is 'Business Place';
comment on column lads_far_det.secco  is 'Section Code';
comment on column lads_far_det.lstar  is 'Activity Type';
comment on column lads_far_det.prznr  is 'Business Process ';
comment on column lads_far_det.kursr  is 'Hedged Exchange Rate';
comment on column lads_far_det.kursr_m  is 'Hedged Exchange Rate';
comment on column lads_far_det.gbetr  is 'Hedged Amount in Foreign Currency';
comment on column lads_far_det.buzei is 'Number of Line Item Within Accounting Document';
comment on column lads_far_det.buzid is 'Identification of the Line Item';
comment on column lads_far_det.augdt is 'Clearing Date';
comment on column lads_far_det.augcp is 'Clearing Entry Date';
comment on column lads_far_det.augbl is 'Document Number of the Clearing Document';
comment on column lads_far_det.bschl is 'Posting Key';
comment on column lads_far_det.koart is 'Account type';
comment on column lads_far_det.shkzg is 'Debit/Credit Indicator';
comment on column lads_far_det.gsber is 'Globally unique business area';
comment on column lads_far_det.pargb is 'Globally unique business area';
comment on column lads_far_det.mwskz is 'Tax on sales/purchases code';
comment on column lads_far_det.dmbtr is 'Amount in local currency';
comment on column lads_far_det.dmbe2 is 'Amount in Second Local Currency';
comment on column lads_far_det.dmbe3 is 'Amount in Third Local Currency';
comment on column lads_far_det.wrbtr is 'Amount in document currency';
comment on column lads_far_det.kzbtr is 'Original Reduction Amount in Local Currency';
comment on column lads_far_det.pswbt is 'Amount for Updating in General Ledger';
comment on column lads_far_det.pswsl is 'Update Currency for General Ledger Transaction Figures ';
comment on column lads_far_det.hwbas is 'Tax Base Amount in Local Currency';
comment on column lads_far_det.fwbas is 'Tax Base Amount in Document Currency';
comment on column lads_far_det.mwart is 'Tax Type';
comment on column lads_far_det.ktosl is 'Transaction Key';
comment on column lads_far_det.valut is 'Value date';
comment on column lads_far_det.zuonr is 'Assignment number';
comment on column lads_far_det.sgtxt is 'Item Text';
comment on column lads_far_det.vbund is 'Company ID of Trading Partner';
comment on column lads_far_det.bewar is 'Transaction Type';
comment on column lads_far_det.vorgn is 'Transaction Type for General Ledger';
comment on column lads_far_det.fdlev is 'Planning level';
comment on column lads_far_det.fdgrp is 'Planning group';
comment on column lads_far_det.fdtag is 'Planning date';
comment on column lads_far_det.kokrs is 'Controlling Area';
comment on column lads_far_det.txgrp is 'Group Indicator for Tax Line Items ';
comment on column lads_far_det.kostl is 'Cost Center';
comment on column lads_far_det.aufnr is 'Order Number';
comment on column lads_far_det.vbeln is 'Billing Document';
comment on column lads_far_det.vbel2 is 'Sales Document';
comment on column lads_far_det.posn2 is 'Sales Document Item';
comment on column lads_far_det.anln1 is 'Main Asset Number';
comment on column lads_far_det.anln2 is 'Asset Subnumber';
comment on column lads_far_det.anbwa is 'Asset Transaction Type';
comment on column lads_far_det.bzdat is 'Asset value date';
comment on column lads_far_det.pernr is 'Personnel Number';
comment on column lads_far_det.xumsw is 'Indicator: Sales-related item ?';
comment on column lads_far_det.xskrl is 'Indicator: Line item not liable to cash discount';
comment on column lads_far_det.xauto is 'Indicator: Line item automatically created';
comment on column lads_far_det.saknr is 'G/L Account Number';
comment on column lads_far_det.hkont is 'General Ledger Account';
comment on column lads_far_det.abper is 'Settlement period';
comment on column lads_far_det.matnr is 'Material Number';
comment on column lads_far_det.werks is 'Plant';
comment on column lads_far_det.menge is 'Quantity';
comment on column lads_far_det.meins is 'Base Unit of Measure';
comment on column lads_far_det.erfmg is 'Quantity in unit of entry';
comment on column lads_far_det.erfme is 'Unit of entry';
comment on column lads_far_det.bpmng is 'Quantity in purchase order price unit';
comment on column lads_far_det.bprme is 'Order price unit';
comment on column lads_far_det.ebeln is 'Purchasing Document Number';
comment on column lads_far_det.ebelp is 'Item Number of Purchasing Document';
comment on column lads_far_det.zekkn is 'Sequential number of account assignment';
comment on column lads_far_det.bwkey is 'Valuation area';
comment on column lads_far_det.bwtar is 'Valuation Type';
comment on column lads_far_det.bustw is 'Posting string for values ';
comment on column lads_far_det.bualt is 'Amount posted in alternative price control';
comment on column lads_far_det.tbtkz is 'Indicator: subsequent debit/credit';
comment on column lads_far_det.stceg is 'VAT registration number';
comment on column lads_far_det.rstgr is 'Reason Code for Payments ';
comment on column lads_far_det.prctr is 'Profit Center';
comment on column lads_far_det.vname is 'Joint Venture';
comment on column lads_far_det.recid is 'Recovery Indicator';
comment on column lads_far_det.egrup is 'Equity Group';
comment on column lads_far_det.vptnr is 'Partner account number';
comment on column lads_far_det.vertt is 'Contract Type';
comment on column lads_far_det.vertn is 'Contract Number';
comment on column lads_far_det.vbewa is 'Flow Type';
comment on column lads_far_det.txjcd is 'Jur is 'diction for Tax Calculation - Tax Jur is 'diction Code';
comment on column lads_far_det.imkey is 'Internal Key for Real Estate Object';
comment on column lads_far_det.dabrz is 'Reference date for settlement';
comment on column lads_far_det.fipos is 'Commitment Item';
comment on column lads_far_det.kstrg is 'Cost Object';
comment on column lads_far_det.nplnr is 'Network Number for Account Assignment';
comment on column lads_far_det.aufpl is 'Task list number for operations in order';
comment on column lads_far_det.aplzl is 'General counter for order';
comment on column lads_far_det.projk is 'Work Breakdown Structure Element (WBS Element)';
comment on column lads_far_det.paobjnr is 'Profitability Segment Number (CO-PA)';
comment on column lads_far_det.btype is 'Payroll Type';
comment on column lads_far_det.etype is 'Equity type';
comment on column lads_far_det.xegdr is 'Indicator: Triangular deal within the EU ?';
comment on column lads_far_det.hrkft is 'Origin Group as Subdivision of Cost Element';
comment on column lads_far_det.lokkt is 'Alternative account number in company code';
comment on column lads_far_det.fistl is 'Funds Center';
comment on column lads_far_det.geber  is 'Fund';
comment on column lads_far_det.stbuk  is 'Tax Company Code';
comment on column lads_far_det.altkt  is 'Group account number';
comment on column lads_far_det.pprct  is 'Partner Profit Center';
comment on column lads_far_det.xref1  is 'Business partner reference key';
comment on column lads_far_det.xref2  is 'Business partner reference key';
comment on column lads_far_det.kblnr  is 'Document Number for Earmarked Funds ';
comment on column lads_far_det.kblpos is 'Earmarked Funds: Document Item';
comment on column lads_far_det.fkber  is 'Functional Area';
comment on column lads_far_det.obzei  is 'Number of Line Item in Original Document';
comment on column lads_far_det.xnegp  is 'Indicator: Negative posting';
comment on column lads_far_det.cacct  is 'G/L offsetting acct number';
comment on column lads_far_det.xref3  is 'Reference key for line item';
comment on column lads_far_det.txdat  is 'Date for defining tax rates ';
comment on column lads_far_det.bupla  is 'Business Place';
comment on column lads_far_det.secco  is 'Section Code';
comment on column lads_far_det.lstar  is 'Activity Type';
comment on column lads_far_det.prznr  is 'Business Process ';
comment on column lads_far_det.kursr  is 'Hedged Exchange Rate';
comment on column lads_far_det.kursr_m  is 'Hedged Exchange Rate';
comment on column lads_far_det.gbetr  is 'Hedged Amount in Foreign Currency';
comment on column lads_far_det.reserve is 'Character field length 50';
comment on column lads_far_det.xcpdd is 'Indicator: Address and bank data set individually';

/**/
/* Primary Key Constraint
/**/
alter table lads_far_det
   add constraint lads_far_det_pk primary key (BELNR,DETSEQ);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_far_det to lads_app;
grant select, insert, update, delete on lads_far_det to ics_app;
grant select on lads_far_det to ics_reader;
grant select on lads_far_det to site_app;
grant select, insert, update on lads_far_det to bds_app;

/**/
/* Synonym
/**/
create public synonym lads_far_det for lads.lads_far_det;
