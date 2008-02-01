/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_ord
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_ord

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_ord
   (zzgrpnr                                      varchar2(40 char)                   not null,
    ordseq                                       number                              not null,
    znborders                                    varchar2(10 char)                   null,
    ztypord                                      varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_ord is 'Generic ICB Document - Order data';
comment on column lads_exp_ord.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_ord.ordseq is 'ORD - generated sequence number';
comment on column lads_exp_ord.znborders is 'Total order number';
comment on column lads_exp_ord.ztypord is 'Order Type (SO/PO)';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_ord
   add constraint lads_exp_ord_pk primary key (zzgrpnr, ordseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_ord to lads_app;
grant select, insert, update, delete on lads_exp_ord to ics_app;
grant select on lads_exp_ord to ics_reader with grant option;
grant select on lads_exp_ord to ics_executor;
grant select on lads_exp_ord to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_ord for lads.lads_exp_ord;
