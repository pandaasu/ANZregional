/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : temp_bom_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - temp_bom_hdr (TEMPORARY)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/02   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table temp_bom_hdr
   (msgfn                                        varchar2(3 char)                    null,
    stlnr                                        varchar2(8 char)                    null,
    stlal                                        varchar2(2 char)                    not null,
    matnr                                        varchar2(18 char)                   not null,
    werks                                        varchar2(4 char)                    not null,
    stlan                                        varchar2(1 char)                    null,
    datuv                                        varchar2(8 char)                    null,
    datub                                        varchar2(8 char)                    null,
    bmeng                                        number                              null,
    bmein                                        varchar2(3 char)                    null,
    stlst                                        varchar2(2 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table temp_bom_hdr is 'LADS Bill Of Material Header';
comment on column temp_bom_hdr.msgfn is 'Header Message Function';
comment on column temp_bom_hdr.stlnr is 'Bill of Material';
comment on column temp_bom_hdr.stlal is 'Alternative BOM';
comment on column temp_bom_hdr.matnr is 'Material Number';
comment on column temp_bom_hdr.werks is 'Plant';
comment on column temp_bom_hdr.stlan is 'BOM Usage';
comment on column temp_bom_hdr.datuv is 'BOM Valid From Date';
comment on column temp_bom_hdr.datub is 'BOM Valid To Date';
comment on column temp_bom_hdr.bmeng is 'Base Quantity';
comment on column temp_bom_hdr.bmein is 'UOM for Base Quantity';
comment on column temp_bom_hdr.stlst is 'BOM status';
comment on column temp_bom_hdr.idoc_name is 'IDOC name';
comment on column temp_bom_hdr.idoc_number is 'IDOC number';
comment on column temp_bom_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column temp_bom_hdr.lads_date is 'LADS date loaded';
comment on column temp_bom_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table temp_bom_hdr
   add constraint temp_bom_hdr_pk primary key (stlal, matnr, werks);

/**/
/* Authority
/**/
grant select, insert, update, delete on temp_bom_hdr to lads_app;
grant select on temp_bom_hdr to ics_reader with grant option;

/**/
/* Synonym
/**/
create public synonym temp_bom_hdr for lads.temp_bom_hdr;
