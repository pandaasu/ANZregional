/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_far_tax
 Owner   : lads
 Author  : Sunil Mandalika

 Description
 -----------
 Local Atlas Data Store - lads_far_tax

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/06   Sunil Mandalika Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_far_tax
	(BELNR		VarChar2 (10 Char)	 not null,
	TAXSEQ  	number            	not null,
	BUZEI		VarChar2(3 char)  	null,
	MWSKZ		VarChar2(2 char)  	null,
	HKONT		VarChar2(10 char) 	null,
	TXGRP		VarChar2(3 char)  	null,
	SHKZG		VarChar2(1 char)  	null,
	HWBAS		VarChar2(17 char) 	null,
	FWBAS		VarChar2(17 char) 	null,
	HWSTE		VarChar2(15 char) 	null,
	FWSTE		VarChar2(15 char) 	null,
	KTOSL		VarChar2(3 char)  	null,
	KNUMH		VarChar2(10 char) 	null,
	STCEG		VarChar2(20 char) 	null,
	EGBLD		VarChar2(3 char)  	null,
	EGLLD		VarChar2(3 char)  	null,
	TXJCD		VarChar2(15 char) 	null,
	H2STE		VarChar2(15 char) 	null,
	H3STE		VarChar2(15 char) 	null,
	H2BAS		VarChar2(17 char) 	null,
	H3BAS		VarChar2(17 char) 	null,
	KSCHL		VarChar2(4 char)  	null,
	STMDT		VarChar2(8 char)  	null,
	STMTI		VarChar2(6 char)  	null,
	MLDDT		VarChar2(8 char)  	null,
	KBETR		VarChar2(13 char) 	null,
	STBKZ		VarChar2(1 char)  	null,
	LSTML		VarChar2(3 char)  	null,
	LWSTE		VarChar2(15 char) 	null,
	LWBAS		VarChar2(17 char) 	null,
	TXDAT		VarChar2(8 char)  	null,
	BUPLA		VarChar2(4 char)  	null,
	TXJDP		VarChar2(15 char) 	null,
	TXJLV		VarChar2(1 char)  	null,
	RESERVE		VarChar2(50 char) 	null,
	TAXPS		VarChar2(6 char)  	null,
	TXMOD		VarChar2(3 char)  	null);

/**/
/* Comments
/**/
comment on table lads_far_tax is 'tax  - Document Item Tax Information'
comment on column lads_far_tax.belnr is 'Accounting Document Number';
comment on column lads_far_tax.taxseq is 'TAX - generated sequence number';
comment on column lads_far_tax.buzei is 'Number of Line Item Within Accounting Document';
comment on column lads_far_tax.mwskz is 'Tax on sales/purchases code';
comment on column lads_far_tax.hkont is 'General Ledger Account';
comment on column lads_far_tax.txgrp is 'Group Indicator for Tax Line Items';
comment on column lads_far_tax.shkzg is 'Debit/Credit Indicator';
comment on column lads_far_tax.hwbas is 'Tax Base Amount in Local Currency';
comment on column lads_far_tax.fwbas is 'Tax base amount in document currency';
comment on column lads_far_tax.hwste is 'Tax Amount in Local Currency';
comment on column lads_far_tax.fwste is 'Tax Amount in Document Currency';
comment on column lads_far_tax.ktosl is 'Transaction Key';
comment on column lads_far_tax.knumh is 'Condition record number';
comment on column lads_far_tax.stceg is 'VAT registration number';
comment on column lads_far_tax.egbld is 'Country of Destination for Delivery of Goods';
comment on column lads_far_tax.eglld is 'Supplying Country for Delivery of Goods';
comment on column lads_far_tax.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_far_tax.h2ste is 'Tax Amount in Local Currency 2';
comment on column lads_far_tax.h3ste is 'Tax Amount in Local Currency 3';
comment on column lads_far_tax.h2bas is 'Tax Base Amount in Local Currency 2';
comment on column lads_far_tax.h3bas is 'Tax Base Amount in Local Currency 3';
comment on column lads_far_tax.kschl is 'Condition type';
comment on column lads_far_tax.stmdt is 'Date on Which the Tax Return Was Made';
comment on column lads_far_tax.stmti is 'Time of Program Run for the Tax Return';
comment on column lads_far_tax.mlddt is 'Reporting Date for Tax Report';
comment on column lads_far_tax.kbetr is 'Rate (condition amount or percentage) where no scale exists';
comment on column lads_far_tax.stbkz is 'Posting indicator';
comment on column lads_far_tax.lstml is 'Country for Tax Return';
comment on column lads_far_tax.lwste is 'Tax Amount in Country Currency';
comment on column lads_far_tax.lwbas is 'Tax Base in Country Currency';
comment on column lads_far_tax.txdat is 'Date for defining tax rates';
comment on column lads_far_tax.bupla is 'Business Place';
comment on column lads_far_tax.txjdp is 'Tax Jurisdiction Code - Jurisdiction for Lowest Level Tax';
comment on column lads_far_tax.txjlv is 'Tax jurisdiction code level';
comment on column lads_far_tax.reserve is 'Character field length 50';
comment on column lads_far_tax.taxps is 'Tax document item number';
comment on column lads_far_tax.txmod is 'Tax Result Has Been Modified Manually';

/**/
/* Primary Key Constraint
/**/
alter table lads_far_tax
   add constraint lads_far_tax_pk primary key (BELNR, TAXSEQ);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_far_tax to lads_app;
grant select, insert, update, delete on lads_far_tax to ics_app;
grant select on lads_far_tax to ics_reader;
grant select on lads_far_tax to site_app;
grant select, insert, update on lads_far_tax to bds_app;

/**/
/* Synonym
/**/
create public synonym lads_far_tax for lads.lads_far_tax;