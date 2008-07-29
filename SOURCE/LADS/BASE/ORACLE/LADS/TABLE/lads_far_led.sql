/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_far_led
 Owner   : lads
 Author  : Sunil Mandalika

 Description
 -----------
 Local Atlas Data Store - lads_far_led

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/06   Sunil Mandalika Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_far_led
	(BELNR		Varchar2 (10 Char)	not null,
	DETSEQ  	Number                  not null,
	LEDSEQ  	Number                  not null,
	UMSKZ		VarChar2(1 Char)	null,
	MWSTS		VarChar2(15 Char)	null,
	WMWST		VarChar2(15 Char)	null,
	KUNNR		VarChar2(10 Char)	null,
	FILKD		VarChar2(10 Char)	null,
	ZFBDT		VarChar2(8 Char)	null,
	ZTERM		VarChar2(4 Char)	null,
	ZBD1T		VarChar2(5 Char)	null,
	ZBD2T		VarChar2(5 Char)	null,
	ZBD3T		VarChar2(5 Char)	null,
	ZBD1P		VarChar2(7 Char)	null,
	ZBD2P		VarChar2(7 Char)	null,
	SKFBT		VarChar2(15 Char)	null,
	SKNTO		VarChar2(15 Char)	null,
	WSKTO		VarChar2(15 Char)	null,
	ZLSCH		VarChar2(1 Char)	null,
	ZLSPR		VarChar2(1 Char)	null,
	UZAWE		VarChar2(2 Char)	null,
	HBKID		VarChar2(5 Char)	null,
	BVTYP		VarChar2(4 Char)	null,
	REBZG		VarChar2(10 Char)	null,
	REBZJ		Number 			null,
	REBZZ		Number 			null,
	REBZT		VarChar2(1 Char)	null,
	LZBKZ		VarChar2(3 Char)	null,
	LANDL		VarChar2(3 Char)	null,
	DIEKZ		VarChar2(1 Char)	null,
	VRSKZ		VarChar2(1 Char)	null,
	VRSDT		VarChar2(8 Char)	null,
	MSCHL		VarChar2(1 Char)	null,
	MANSP		VarChar2(1 Char)	null,
	MABER		VarChar2(2 Char)	null,
	MADAT		VarChar2(8 Char)	null,
	MANST		Number 			null,
	QSSKZ		VarChar2(2 Char)	null,
	QSSHB		VarChar2(15 Char)	null,
	QSFBT		VarChar2(15 Char)	null,
	LIFNR		VarChar2(10 Char)	null,
	ESRNR		VarChar2(11 Char)	null,
	ESRRE		VarChar2(27 Char)	null,
	ESRPZ		VarChar2(2 Char)	null,
	ZBFIX		VarChar2(1 Char)	null,
	KIDNO		VarChar2(30 Char)	null,
	EMPFB		VarChar2(10 Char)	null,
	SKNT2		VarChar2(15 Char)	null,
	SKNT3		VarChar2(15 Char)	null,
	PYCUR		VarChar2(5 Char)	null,
	PYAMT		VarChar2(15 Char)	null,
	KKBER		VarChar2(4 Char)	null,
	ABSBT		VarChar2(15 Char)	null,
	ZUMSK		VarChar2(1 Char)	null,
	CESSION_KZ	VarChar2(2 Char)	null,
	DTWS1		Number 			null,
	DTWS2		Number 			null,
	DTWS3		Number 			null,
	DTWS4		Number 			null,
	AWTYP_REB	VarChar2(5 Char)	null,
	AWREF_REB	VarChar2(10 Char)	null,
	AWORG_REB	VarChar2(10 Char)	null,
	RESERVE		VarChar2(50 Char)	null);

/**/
/* Comments
/**/
comment on table lads_far_led is 'led - Subsidiary Ledger Detail Information';
comment on column lads_far_led.belnr is 'Accounting Doc Number';
comment on column lads_far_led.detseq is 'DAT - generated sequence number';
comment on column lads_far_led.ledseq is 'LED - generated sequence number';
comment on column lads_far_led.umskz is 'Special G/L Indicator';
comment on column lads_far_led.mwsts is 'Tax Amt in Local Curr';
comment on column lads_far_led.wmwst is 'Tax Amt in Doc Curr';
comment on column lads_far_led.kunnr is 'Customer Number 1';
comment on column lads_far_led.filkd is 'Account Number of the Branch';
comment on column lads_far_led.zfbdt is 'Baseline date for due date calculation';
comment on column lads_far_led.zterm is 'Terms of Paymt key';
comment on column lads_far_led.zbd1t is 'Cash disc days 1';
comment on column lads_far_led.zbd2t is 'Cash disc days 2';
comment on column lads_far_led.zbd3t is 'Net Paymt Terms Period';
comment on column lads_far_led.zbd1p is 'Cash disc percentage 1';
comment on column lads_far_led.zbd2p is 'Cash disc Percentage 2';
comment on column lads_far_led.skfbt is 'Amt Eligible for Cash disc in Doc Curr';
comment on column lads_far_led.sknto is 'Cash disc Amt in local Curr';
comment on column lads_far_led.wskto is 'Cash disc Amt in Doc Curr';
comment on column lads_far_led.zlsch is 'Paymt method';
comment on column lads_far_led.zlspr is 'Paymt Block Key';
comment on column lads_far_led.uzawe is 'Paymt method supplement';
comment on column lads_far_led.hbkid is 'Short key for a house bank';
comment on column lads_far_led.bvtyp is 'Partner bank type';
comment on column lads_far_led.rebzg is 'Number of the Invoice the Trans Belongs to';
comment on column lads_far_led.rebzj is 'Fiscal Year of the Relevant Invoice (for Credit Memo)';
comment on column lads_far_led.rebzz is 'Line Item in the Relevant Invoice';
comment on column lads_far_led.rebzt is 'Follow-On Doc Type';
comment on column lads_far_led.lzbkz is 'State central bank indicator';
comment on column lads_far_led.landl is 'Supplying Country';
comment on column lads_far_led.diekz is 'Service indicator (foreign Paymt)';
comment on column lads_far_led.vrskz is 'Insurance indicator';
comment on column lads_far_led.vrsdt is 'Insurance date';
comment on column lads_far_led.mschl is 'Dunning key';
comment on column lads_far_led.mansp is 'Dunning block';
comment on column lads_far_led.maber is 'Dunning Area';
comment on column lads_far_led.madat is 'Last dunned on';
comment on column lads_far_led.manst is 'Dunning level';
comment on column lads_far_led.qsskz is 'WithHold Tax Code';
comment on column lads_far_led.qsshb is 'WithHold Tax Base Amt';
comment on column lads_far_led.qsfbt is 'WithHold Tax-Exempt Amt (in Doc Curr)';
comment on column lads_far_led.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_far_led.esrnr is 'POR subscriber number';
comment on column lads_far_led.esrre is 'POR reference number';
comment on column lads_far_led.esrpz is 'POR check digit';
comment on column lads_far_led.zbfix is 'Fixed Paymt Terms';
comment on column lads_far_led.kidno is 'Paymt Reference';
comment on column lads_far_led.empfb is 'Payee/Payer';
comment on column lads_far_led.sknt2 is 'Cash disc Amt in Second Local Curr';
comment on column lads_far_led.sknt3 is 'Cash disc Amt in Third Local Curr';
comment on column lads_far_led.pycur is 'Curr for Automatic Paymt';
comment on column lads_far_led.pyamt is 'Amt in Paymt Curr';
comment on column lads_far_led.kkber is 'Credit control area';
comment on column lads_far_led.absbt is 'Credit management: Hedged Amt';
comment on column lads_far_led.zumsk is 'Target Special G/L Indicator';
comment on column lads_far_led.cession_kz is 'Accounts Receivable Pledging Indicator';
comment on column lads_far_led.dtws1 is 'Instruction key 1';
comment on column lads_far_led.dtws2 is 'Instruction key 2';
comment on column lads_far_led.dtws3 is 'Instruction key 3';
comment on column lads_far_led.dtws4 is 'Instruction key 4';
comment on column lads_far_led.awtyp_reb is 'Reference procedure';
comment on column lads_far_led.awref_reb is 'Doc number for invoice reference';
comment on column lads_far_led.aworg_reb is 'Reference organization for inv. reference';
comment on column lads_far_led.reserve is 'Character field length 50';


/**/
/* Primary Key Constraint
/**/
alter table lads_far_led
   add constraint lads_far_led_pk primary key (BELNR,DETSEQ,LEDSEQ);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_far_led to lads_app;
grant select, insert, update, delete on lads_far_led to ics_app;
grant select on lads_far_led to ics_reader;
grant select on lads_far_led to site_app;
grant select, insert, update on lads_far_led to bds_app;

/**/
/* Synonym
/**/
create public synonym lads_far_led for lads.lads_far_led;
