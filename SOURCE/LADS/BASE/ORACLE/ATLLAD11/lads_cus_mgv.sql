/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_mgv
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_mgv

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_mgv
   (kunnr                                        varchar2(10 char)                   not null,
    mgvseq                                       number                              not null,
    locnr                                        varchar2(10 char)                   null,
    matkl                                        varchar2(9 char)                    null,
    wwgpa                                        varchar2(18 char)                   null,
    kedet                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_mgv is 'LADS Customer Value Only Material Determination';
comment on column lads_cus_mgv.kunnr is 'Customer Number';
comment on column lads_cus_mgv.mgvseq is 'MGV - generated sequence number';
comment on column lads_cus_mgv.locnr is 'Customer number for plant';
comment on column lads_cus_mgv.matkl is 'Material Group';
comment on column lads_cus_mgv.wwgpa is 'Material group material';
comment on column lads_cus_mgv.kedet is 'Indicates exceptions to type of Inventory Management';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_mgv
   add constraint lads_cus_mgv_pk primary key (kunnr, mgvseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_mgv to lads_app;
grant select, insert, update, delete on lads_cus_mgv to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_mgv for lads.lads_cus_mgv;
