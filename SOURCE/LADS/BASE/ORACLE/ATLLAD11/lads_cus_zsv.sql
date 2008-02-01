/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_zsv
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_zsv

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_zsv
   (kunnr                                        varchar2(10 char)                   not null,
    sadseq                                       number                              not null,
    zsvseq                                       number                              not null,
    vkorg                                        varchar2(4 char)                    null,
    vtweg                                        varchar2(2 char)                    null,
    spart                                        varchar2(2 char)                    null,
    vmifds                                       number                              null);

/**/
/* Comments
/**/
comment on table lads_cus_zsv is 'LADS Customer VMI Forecast';
comment on column lads_cus_zsv.kunnr is 'Customer Number';
comment on column lads_cus_zsv.sadseq is 'SAD - generated sequence number';
comment on column lads_cus_zsv.zsvseq is 'ZSV - generated sequence number';
comment on column lads_cus_zsv.vkorg is 'Sales Organization';
comment on column lads_cus_zsv.vtweg is 'Distribution Channel';
comment on column lads_cus_zsv.spart is 'Division';
comment on column lads_cus_zsv.vmifds is 'VMI Forecast Data Source';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_zsv
   add constraint lads_cus_zsv_pk primary key (kunnr, sadseq, zsvseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_zsv to lads_app;
grant select, insert, update, delete on lads_cus_zsv to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_zsv for lads.lads_cus_zsv;
