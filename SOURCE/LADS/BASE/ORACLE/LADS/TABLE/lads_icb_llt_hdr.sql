/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_icb_llt_hdr
 Owner   : lads
 Author  : Matthew Hardinge

 Description
 -----------
 Local Atlas Data Store - lads_icb_llt_hdr

 YYYY/MM   Author            Description
 -------   ------            -----------
 2006/05   Matthew Hardinge  Created

*******************************************************************************/


drop table lads_icb_llt_hdr;

/**/
/* Table creation
/**/
create table lads_icb_llt_hdr
   (venum                                        varchar2(10 char)                   not null,	
    exidv                                        varchar2(20 char)                   null,
    bukrs                                        varchar2(4 char)                    null,
    exidv2                                       varchar2(20 char)                   null,
    slfdt                                        varchar2(8 char)                    null,
    eindt                                        varchar2(8 char)                    null,
    zfwrd                                        varchar2(10 char)                   null,
    exti1                                        varchar2(20 char)                   null,
    signi                                        varchar2(20 char)                   null,
    zfnam                                        varchar2(35 char)                   null,
    lifnr                                        varchar2(10 char)                   null,
    ebeln                                        varchar2(10 char)                   null,
    zhustat                                      varchar2(1 char)                    null,
    hudat                                        varchar2(8 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null,
    whardat					 varchar2(8 char)		     null,
    name1					 varchar2(35 char)		     null,
    zzseal					 varchar2(40 char)		     null,
    vhilm					 number				     null,
    zcount					 number				     null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_icb_llt_hdr is 'LADS ICB LLT Intransit Header';
comment on column lads_icb_llt_hdr.venum is 'Internal Handling Unit Number';
comment on column lads_icb_llt_hdr.exidv is 'External Handling Unit Identification';
comment on column lads_icb_llt_hdr.bukrs is 'Company Code';
comment on column lads_icb_llt_hdr.exidv2 is 'Handling Units 2nd External Identification';
comment on column lads_icb_llt_hdr.slfdt is 'Statistics-relevant delivery date (YYYYMMDD)';
comment on column lads_icb_llt_hdr.eindt is 'Item delivery date (YYYYMMDD)';
comment on column lads_icb_llt_hdr.zfwrd is 'Forwarder number (account ID)';
comment on column lads_icb_llt_hdr.exti1 is 'External identification 1';
comment on column lads_icb_llt_hdr.signi is 'Container ID';
comment on column lads_icb_llt_hdr.zfnam is 'Forwarding Agent Name';
comment on column lads_icb_llt_hdr.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_icb_llt_hdr.ebeln is 'Purchasing Document Number';
comment on column lads_icb_llt_hdr.zhustat is 'Handling Unit Status';
comment on column lads_icb_llt_hdr.hudat is 'Date on which the record was created (YYYYMMDD)';
comment on column lads_icb_llt_hdr.datum is 'Date (YYYYMMDD)';
comment on column lads_icb_llt_hdr.uzeit is 'Time';
comment on column lads_icb_llt_hdr.whardat is '';
comment on column lads_icb_llt_hdr.name1 is 'Supplier Name';
comment on column lads_icb_llt_hdr.zzseal is 'Container Seal Number';
comment on column lads_icb_llt_hdr.vhilm is 'Packaging Materials';
comment on column lads_icb_llt_hdr.zcount is 'Messages Counter';
comment on column lads_icb_llt_hdr.idoc_name is 'IDOC name';
comment on column lads_icb_llt_hdr.idoc_number is 'IDOC number';
comment on column lads_icb_llt_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_icb_llt_hdr.lads_date is 'LADS date loaded';
comment on column lads_icb_llt_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan, 4=deleted)';

/**/
/* Primary Key Constraint
/**/
alter table lads_icb_llt_hdr
   add constraint lads_icb_llt_hdr_pk primary key (venum);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_icb_llt_hdr to lads_app;
grant select, insert, update, delete on lads_icb_llt_hdr to ics_app;
grant select on lads_icb_llt_hdr to site_app;
grant select on lads_icb_llt_hdr to ics_reader;

/**/
/* Synonym
/**/
create or replace public synonym lads_icb_llt_hdr for lads.lads_icb_llt_hdr;
