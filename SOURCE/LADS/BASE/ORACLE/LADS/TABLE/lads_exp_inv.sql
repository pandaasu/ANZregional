/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_inv
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_inv

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_inv
   (zzgrpnr                                      varchar2(40 char)                   not null,
    invseq                                       number                              not null,
    znbinvoic                                    varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_inv is 'Generic ICB Document - Invoice data';
comment on column lads_exp_inv.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_inv.invseq is 'INV - generated sequence number';
comment on column lads_exp_inv.znbinvoic is 'Total number of Invoice';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_inv
   add constraint lads_exp_inv_pk primary key (zzgrpnr, invseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_inv to lads_app;
grant select, insert, update, delete on lads_exp_inv to ics_app;
grant select on lads_exp_inv to ics_reader with grant option;
grant select on lads_exp_inv to ics_executor;
grant select on lads_exp_inv to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_inv for lads.lads_exp_inv;
