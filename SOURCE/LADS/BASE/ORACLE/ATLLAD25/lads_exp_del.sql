/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_del
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_del

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_del
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    znbdelvry                                    varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_del is 'Generic ICB Document - Delivery data';
comment on column lads_exp_del.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_del.delseq is 'DEL - generated sequence number';
comment on column lads_exp_del.znbdelvry is 'Total number of Delivery';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_del
   add constraint lads_exp_del_pk primary key (zzgrpnr, delseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_del to lads_app;
grant select, insert, update, delete on lads_exp_del to ics_app;
grant select on lads_exp_del to ics_reader with grant option;
grant select on lads_exp_del to ics_executor;
grant select on lads_exp_del to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_del for lads.lads_exp_del;
