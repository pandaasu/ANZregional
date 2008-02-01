/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_prp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_prp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_prp
   (kunnr                                        varchar2(10 char)                   not null,
    prpseq                                       number                              not null,
    locnr                                        varchar2(10 char)                   null,
    empst                                        varchar2(25 char)                   null,
    kunn2                                        varchar2(10 char)                   null,
    ablad                                        varchar2(25 char)                   null);

/**/
/* Comments
/**/
comment on table lads_cus_prp is 'LADS Customer Plant Receiving Point';
comment on column lads_cus_prp.kunnr is 'Customer Number';
comment on column lads_cus_prp.prpseq is 'PRP - generated sequence number';
comment on column lads_cus_prp.locnr is 'Customer number for plant';
comment on column lads_cus_prp.empst is 'Receiving point';
comment on column lads_cus_prp.kunn2 is 'Customer number of business partner';
comment on column lads_cus_prp.ablad is 'Unloading Point';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_prp
   add constraint lads_cus_prp_pk primary key (kunnr, prpseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_prp to lads_app;
grant select, insert, update, delete on lads_cus_prp to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_prp for lads.lads_cus_prp;
