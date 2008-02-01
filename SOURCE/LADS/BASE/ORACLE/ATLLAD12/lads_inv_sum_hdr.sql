/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_sum_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_sum_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_sum_hdr
   (fkdat                                        varchar2(8 char)                    not null,
    bukrs                                        varchar2(4 char)                    not null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_inv_sum_hdr is 'LADS Invoice Summary Header';
comment on column lads_inv_sum_hdr.fkdat is 'Invoice Create Date';
comment on column lads_inv_sum_hdr.bukrs is 'Company Code';
comment on column lads_inv_sum_hdr.datum is 'Idoc Create Date';
comment on column lads_inv_sum_hdr.uzeit is 'Idoc Create Time';
comment on column lads_inv_sum_hdr.idoc_name is 'IDOC name';
comment on column lads_inv_sum_hdr.idoc_number is 'IDOC number';
comment on column lads_inv_sum_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_inv_sum_hdr.lads_date is 'LADS date loaded';
comment on column lads_inv_sum_hdr.lads_status is 'LADS status (1=valid, 2=error)';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_sum_hdr
   add constraint lads_inv_sum_hdr_pk primary key (fkdat, bukrs);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_sum_hdr to lads_app;
grant select, insert, update, delete on lads_inv_sum_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_sum_hdr for lads.lads_inv_sum_hdr;
