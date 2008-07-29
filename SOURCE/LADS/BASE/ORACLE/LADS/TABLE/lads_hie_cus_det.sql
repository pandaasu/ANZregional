/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_hie_cus_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_hie_cus_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_hie_cus_det
   (hdrdat                                       varchar2(8 char)                    not null,
    hdrseq                                       number                              not null,
    detseq                                       number                              not null,
    kunnr                                        varchar2(10 char)                   null,
    vkorg                                        varchar2(4 char)                    null,
    vtweg                                        varchar2(2 char)                    null,
    spart                                        varchar2(2 char)                    null,
    hzuor                                        varchar2(2 char)                    null,
    datab                                        varchar2(8 char)                    null,
    datbi                                        varchar2(8 char)                    null,
    ktokd                                        varchar2(4 char)                    null,
    sortl                                        varchar2(10 char)                   null,
    hielv                                        varchar2(2 char)                    null,
    zzcurrentflag                                varchar2(1 char)                    null,
    zzfutureflag                                 varchar2(1 char)                    null,
    zzmarketacctflag                             varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_hie_cus_det is 'LADS Hierarchy Customer Detail';
comment on column lads_hie_cus_det.hdrdat is 'HDR - Date';
comment on column lads_hie_cus_det.hdrseq is 'HDR - generated sequence number';
comment on column lads_hie_cus_det.detseq is 'DET - generated sequence number';
comment on column lads_hie_cus_det.kunnr is 'Customer';
comment on column lads_hie_cus_det.vkorg is 'Sales Organisation';
comment on column lads_hie_cus_det.vtweg is 'Distribution Channel';
comment on column lads_hie_cus_det.spart is 'Division';
comment on column lads_hie_cus_det.hzuor is 'Assignment to Hierarchy';
comment on column lads_hie_cus_det.datab is 'Start of Validity Period for Assignment';
comment on column lads_hie_cus_det.datbi is 'End of Validity Period for Assignment';
comment on column lads_hie_cus_det.ktokd is 'Customer Account Group';
comment on column lads_hie_cus_det.sortl is 'Sort Field';
comment on column lads_hie_cus_det.hielv is 'Assignment to Hierarchy';
comment on column lads_hie_cus_det.zzcurrentflag is 'Current Planning Flag';
comment on column lads_hie_cus_det.zzfutureflag is 'Future Planning Flag';
comment on column lads_hie_cus_det.zzmarketacctflag is 'Market Headquarter Account Flag';

/**/
/* Primary Key Constraint
/**/
alter table lads_hie_cus_det
   add constraint lads_hie_cus_det_pk primary key (hdrdat, hdrseq, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_hie_cus_det to lads_app;
grant select, insert, update, delete on lads_hie_cus_det to ics_app;
grant select on lads_hie_cus_det to ics_executor;
grant select on lads_hie_cus_det to ics_reader with grant option;
grant select on lads_hie_cus_det to lads_reader;
grant select on lads_hie_cus_det to rap_app with grant option;
grant select on lads_hie_cus_det to site_app;

/**/
/* Synonym
/**/
create public synonym lads_hie_cus_det for lads.lads_hie_cus_det;
