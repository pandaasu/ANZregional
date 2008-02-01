/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_zsd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_zsd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_zsd
   (kunnr                                        varchar2(10 char)                   not null,
    sadseq                                       number                              not null,
    zsdseq                                       number                              not null,
    vkorg                                        varchar2(4 char)                    null,
    vtweg                                        varchar2(2 char)                    null,
    spart                                        varchar2(2 char)                    null,
    vmict                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_cus_zsd is 'LADS Customer VMI Type';
comment on column lads_cus_zsd.kunnr is 'Customer Number';
comment on column lads_cus_zsd.sadseq is 'SAD - generated sequence number';
comment on column lads_cus_zsd.zsdseq is 'ZSD - generated sequence number';
comment on column lads_cus_zsd.vkorg is 'Sales Organization';
comment on column lads_cus_zsd.vtweg is 'Distribution Channel';
comment on column lads_cus_zsd.spart is 'Division';
comment on column lads_cus_zsd.vmict is 'VMI Customer type';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_zsd
   add constraint lads_cus_zsd_pk primary key (kunnr, sadseq, zsdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_zsd to lads_app;
grant select, insert, update, delete on lads_cus_zsd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_zsd for lads.lads_cus_zsd;
