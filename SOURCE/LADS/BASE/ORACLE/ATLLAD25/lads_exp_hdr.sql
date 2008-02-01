/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hdr
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hdr
   (zzgrpnr                                      varchar2(40 char)                   not null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_exp_hdr is 'Generic ICB Document - Header';
comment on column lads_exp_hdr.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hdr.idoc_name is 'IDOC name';
comment on column lads_exp_hdr.idoc_number is 'IDOC number';
comment on column lads_exp_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_exp_hdr.lads_date is 'LADS date loaded';
comment on column lads_exp_hdr.lads_status is 'LADS status (1=valid, 2=error)';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hdr
   add constraint lads_exp_hdr_pk primary key (zzgrpnr);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hdr to lads_app;
grant select, insert, update, delete on lads_exp_hdr to ics_app;
grant select on lads_exp_hdr to ics_reader with grant option;
grant select on lads_exp_hdr to ics_executor;
grant select on lads_exp_hdr to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hdr for lads.lads_exp_hdr;
