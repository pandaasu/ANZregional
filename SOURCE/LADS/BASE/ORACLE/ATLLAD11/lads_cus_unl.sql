/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_unl
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_unl

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_unl
   (kunnr                                        varchar2(10 char)                   not null,
    unlseq                                       number                              not null,
    ablad                                        varchar2(25 char)                   null,
    knfak                                        varchar2(2 char)                    null,
    wanid                                        varchar2(3 char)                    null,
    defab                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_unl is 'LADS Customer Unloading Point';
comment on column lads_cus_unl.kunnr is 'Customer Number';
comment on column lads_cus_unl.unlseq is 'UNL - generated sequence number';
comment on column lads_cus_unl.ablad is 'Unloading Point';
comment on column lads_cus_unl.knfak is 'Customers factory calendar';
comment on column lads_cus_unl.wanid is 'Goods receiving hours ID (default value)';
comment on column lads_cus_unl.defab is 'Default unloading point';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_unl
   add constraint lads_cus_unl_pk primary key (kunnr, unlseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_unl to lads_app;
grant select, insert, update, delete on lads_cus_unl to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_unl for lads.lads_cus_unl;
