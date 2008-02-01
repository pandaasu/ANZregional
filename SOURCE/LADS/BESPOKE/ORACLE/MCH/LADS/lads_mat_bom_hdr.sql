/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_bom_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_bom_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2007/03   Steve Gregan   Added LADS_FLATTENED

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_bom_hdr
   (stlnr                                        varchar2(8 char)                    not null,
    stlal                                        varchar2(2 char)                    not null,
    matnr                                        varchar2(18 char)                   null,
    werks                                        varchar2(4 char)                    null,
    stlan                                        varchar2(1 char)                    null,
    datuv                                        varchar2(8 char)                    null,
    stlst                                        number                              null,
    bmeng_c                                      number                              null,
    bmein                                        varchar2(3 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null,
    lads_flattened                               varchar2(1 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_mat_bom_hdr is 'LADS Material BOM Header';
comment on column lads_mat_bom_hdr.stlnr is 'Bill of Material';
comment on column lads_mat_bom_hdr.stlal is 'Alternative BOM';
comment on column lads_mat_bom_hdr.matnr is 'Material Number ';
comment on column lads_mat_bom_hdr.werks is 'Plant';
comment on column lads_mat_bom_hdr.stlan is 'BOM Usage';
comment on column lads_mat_bom_hdr.datuv is 'BOM Valid From Date';
comment on column lads_mat_bom_hdr.stlst is 'BOM Status';
comment on column lads_mat_bom_hdr.bmeng_c is 'Base Quantity';
comment on column lads_mat_bom_hdr.bmein is 'UOM for Base Quantity';
comment on column lads_mat_bom_hdr.idoc_name is 'IDOC name';
comment on column lads_mat_bom_hdr.idoc_number is 'IDOC number';
comment on column lads_mat_bom_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_mat_bom_hdr.lads_date is 'LADS date loaded';
comment on column lads_mat_bom_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';
comment on column lads_mat_bom_hdr.lads_flattened is 'LADS Flattened Status - 0 Unflattened, 1 Flattened to BDS, 2 Excluded/Skipped';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_bom_hdr
   add constraint lads_mat_bom_hdr_pk primary key (stlnr, stlal);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_bom_hdr to lads_app;
grant select, insert, update, delete on lads_mat_bom_hdr to ics_app;
grant select, update on lads_mat_bom_hdr to bds_app;


/**/
/* Synonym
/**/
create public synonym lads_mat_bom_hdr for lads.lads_mat_bom_hdr;
