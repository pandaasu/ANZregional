/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_pfr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_pfr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_pfr
   (kunnr                                        varchar2(10 char)                   not null,
    sadseq                                       number                              not null,
    pfrseq                                       number                              not null,
    parvw                                        varchar2(2 char)                    null,
    kunn2                                        varchar2(10 char)                   null,
    defpa                                        varchar2(1 char)                    null,
    knref                                        varchar2(30 char)                   null,
    parza                                        number                              null,
    zz_parvw_txt                                 varchar2(20 char)                   null,
    zz_partn_nam                                 varchar2(80 char)                   null,
    zz_partn_nachn                               varchar2(40 char)                   null,
    zz_partn_vorna                               varchar2(40 char)                   null);

/**/
/* Comments
/**/
comment on table lads_cus_pfr is 'LADS Customer Partner Roles';
comment on column lads_cus_pfr.kunnr is 'Customer Number';
comment on column lads_cus_pfr.sadseq is 'SAD - generated sequence number';
comment on column lads_cus_pfr.pfrseq is 'PFR - generated sequence number';
comment on column lads_cus_pfr.parvw is 'Partner function';
comment on column lads_cus_pfr.kunn2 is 'Customer number of business partner';
comment on column lads_cus_pfr.defpa is 'Default partner';
comment on column lads_cus_pfr.knref is '"Customer description of partner (plant, storage location)"';
comment on column lads_cus_pfr.parza is 'Partner counter';
comment on column lads_cus_pfr.zz_parvw_txt is 'Description';
comment on column lads_cus_pfr.zz_partn_nam is 'Complete Name';
comment on column lads_cus_pfr.zz_partn_nachn is 'Last Name';
comment on column lads_cus_pfr.zz_partn_vorna is 'First Name';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_pfr
   add constraint lads_cus_pfr_pk primary key (kunnr, sadseq, pfrseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_pfr to lads_app;
grant select, insert, update, delete on lads_cus_pfr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_pfr for lads.lads_cus_pfr;
