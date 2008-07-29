/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_far_hdr
 Owner   : lads
 Author  : Sunil Mandalika

 Description
 -----------
 Local Atlas Data Store - lads_far_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/06   Sunil Mandalika Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_far_hdr			
	(BELNR		Varchar2(10 Char)	not null,
	BUKRS		Varchar2(6 Char)	null,	
	GJAHR		Number			null,
	BLART		Varchar2(2 Char)	null,
	BLDAT		Varchar2(8 Char)	null,
	BUDAT		Varchar2(8 Char)	null,
	MONAT		Number			null,
	WWERT		Varchar2(8 Char)	null,
	USNAM		Varchar2(12 Char)	null,
	TCODE		Varchar2(4 Char)	null,
	BVORG		Varchar2(16 Char)	null,
	XBLNR		Varchar2(16 Char)	null,
	BKTXT		Varchar2(25 Char)	null,
	WAERS		Varchar2(5 Char)	null,
	KURSF		Number			null,
	GLVOR		Varchar2(4 Char)	null,
	AWTYP		Varchar2(5 Char)	null,
	AWREF		Varchar2(10 Char)	null,
	AWORG		Varchar2(10 Char)	null,
	FIKRS		Varchar2(4 Char)	null,
	HWAER		Varchar2(5 Char)	null,
	HWAE2		Varchar2(5 Char)	null,
	HWAE3		Varchar2(5 Char)	null,
	KURS2		Number			null,
	KURS3		Number			null,
	BASW2		Varchar2(1 Char)	null,
	BASW3		Varchar2(1 Char)	null,
	UMRD2		Varchar2(1 Char)	null,
	UMRD3		Varchar2(2 Char)	null,
	CURT2		Varchar2(2 Char)	null,
	CURT3		Varchar2(2 Char)	null,
	AUSBK		Varchar2(4 Char)	null,
	AWSYS		Varchar2(10 Char)	null,
	LOTKZ		Varchar2(10 Char)	null,
	BUKRS_SND	Varchar2(4 Char)	null,
	FILTER		Varchar2(1 Char)	null,
	KURSF_M		Varchar2(12 Char)	null,
	KURS2_M		Varchar2(12 Char)	null,
	KURS3_M		Varchar2(12 Char)	null,
	BSTAT		Varchar2(1 Char)	null,
	BRNCH		Varchar2(4 Char)	null,
	NUMPG		Number			null,
	ADISC		Varchar2(1 Char)	null,
	STBLG		Varchar2(10 Char)	null,
	STJAH		Number			null,
	AWTYP_REV	Varchar2(5 Char)	null,
	AWREF_REV	Varchar2(10 Char)	null,
	AWORG_REV	Varchar2(10 Char)	null,
	RESERVE		Varchar2(50 Char)	null,
	XREF1_HD	Varchar2(20 Char)	null,
	XREF2_HD	Varchar2(20 Char)	null,
	XBLNR_LONG	Varchar2(35 Char)	null,
	Idoc_Name       Varchar2(30 char)       not null,
	Idoc_Number     Number                  not null,
	Idoc_Timestamp  Varchar2(14 char)       not null,
	Lads_Date       Date                    not null,
        Lads_Status     Varchar2(2 char)        not null,
	Lads_Flattened  Varchar2(2 char)        not null);

/**/
/* Comments
/**/
 comment on table lads_far_hdr is 'lads reference Header';
 comment on column lads_far_hdr.belnr is 'Accounting Document Number';
 comment on column lads_far_hdr.bukrs is 'Name of global company code';
 comment on column lads_far_hdr.gjahr is 'Fiscal Year';
 comment on column lads_far_hdr.blart is 'Document type';
 comment on column lads_far_hdr.bldat is 'Document Date in Document';
 comment on column lads_far_hdr.budat is 'Posting Date in the Document';
 comment on column lads_far_hdr.monat is 'Fiscal Period';
 comment on column lads_far_hdr.wwert is 'Translation date';
 comment on column lads_far_hdr.usnam is 'User name';
 comment on column lads_far_hdr.tcode is 'Transaction Code';
 comment on column lads_far_hdr.bvorg is 'Number of Cross-Company Code Posting Transaction';
 comment on column lads_far_hdr.xblnr is 'Reference Document Number'';
 comment on column lads_far_hdr.bktxt is 'Document Header Text';
 comment on column lads_far_hdr.waers is 'Currency Key';
 comment on column lads_far_hdr.kursf is 'Exchange rate';
 comment on column lads_far_hdr.glvor is 'Business Transaction';
 comment on column lads_far_hdr.awtyp is 'Reference procedure';
 comment on column lads_far_hdr.awref is 'Reference document number';
 comment on column lads_far_hdr.aworg is 'Reference organisational units';
 comment on column lads_far_hdr.fikrs is 'Financial Management Area';
 comment on column lads_far_hdr.hwaer is 'Local Currency';
 comment on column lads_far_hdr.hwae2 is 'Currency Key of Second Local Currency';
 comment on column lads_far_hdr.hwae3 is 'Currency Key of Third Local Currency';
 comment on column lads_far_hdr.kurs2 is 'Exchange Rate for the Second Local Currency';
 comment on column lads_far_hdr.kurs3 is 'Exchange Rate for the Third Local Currency';
 comment on column lads_far_hdr.basw2 is 'Source Currency for Currency Translation';
 comment on column lads_far_hdr.basw3 is 'Source Currency for Currency Translation';
 comment on column lads_far_hdr.umrd2 is 'Translation Date Type for Second Local Currency';
 comment on column lads_far_hdr.umrd3 is 'Translation Date Type for Third Local Currency';
 comment on column lads_far_hdr.curt2 is 'Currency Type of Second Local Currency';
 comment on column lads_far_hdr.curt3 is 'Currency Type of Third Local Currency';
 comment on column lads_far_hdr.ausbk is 'Source Company Code';
 comment on column lads_far_hdr.awsys is 'Logical System';
 comment on column lads_far_hdr.lotkz is 'Lot Number for Documents';
 comment on column lads_far_hdr.bukrs_snd is 'Company Code';
 comment on column lads_far_hdr.filter is 'Data element for domain';
 comment on column lads_far_hdr.kursf_m is 'Indirectly quoted exchange rate in an IDoc segment';
 comment on column lads_far_hdr.kurs2_m is 'Indirectly quoted exchange rate in an IDoc segment';
 comment on column lads_far_hdr.kurs3_m is 'Indirectly quoted exchange rate in an IDoc segment';
 comment on column lads_far_hdr.bstat is 'Document Status';
 comment on column lads_far_hdr.brnch is 'Branch Number';
 comment on column lads_far_hdr.numpg is 'Number of pages of invoice';
 comment on column lads_far_hdr.adisc is 'Indicator: entry represents a discount document';
 comment on column lads_far_hdr.stblg is 'Reverse Document Number';
 comment on column lads_far_hdr.stjah is 'Reverse document fiscal year';
 comment on column lads_far_hdr.awtyp_rev is 'Reference procedure';
 comment on column lads_far_hdr.awref_rev is 'Reversal: Reverse Document Reference Document Number';
 comment on column lads_far_hdr.aworg_rev is 'Reversal: Reverse Document Reference Organization';
 comment on column lads_far_hdr.reserve is 'Character field length 50';
 comment on column lads_far_hdr.xref1_hd is 'Reference Key 1 Internal for Document Header';
 comment on column lads_far_hdr.xref2_hd is 'Reference Key 2 Internal for Document Header';
 comment on column lads_far_hdr.xblnr_long is 'Reference Document Number (for Dependencies see Long Text char)';
 comment on column lads_far_hdr.idoc_name is 'IDOC name';
 comment on column lads_far_hdr.idoc_number is 'IDOC number';
 comment on column lads_far_hdr.idoc_timestamp IS 'IDOC timestamp';
 comment on column lads_far_hdr.lads_date is 'LADS date loaded';
 comment on column lads_far_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';
 comment on column lads_far_hdr.lads_flattened is 'LADS Flattened Status - 0 Unflattened, 1 Flattened to BDS, 2 Excluded/Skipped';


 
/**/
/* Primary Key Constraint
/**/
alter table lads_far_hdr
   add constraint lads_far_hdr_pk primary key (BELNR);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_far_hdr to lads_app;
grant select, insert, update, delete on lads_far_hdr to ics_app;
grant select on lads_far_hdr to ics_reader;
grant select on lads_far_hdr to site_app;
grant select, insert, update on lads_far_hdr to bds_app;

/**/
/* Synonym
/**/
create public synonym lads_far_hdr for lads.lads_far_hdr;
